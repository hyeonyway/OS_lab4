1700 #include "param.h"
1701 #include "types.h"
1702 #include "defs.h"
1703 #include "x86.h"
1704 #include "memlayout.h"
1705 #include "mmu.h"
1706 #include "proc.h"
1707 #include "elf.h"
1708 #include "graphic.h"
1709 
1710 extern char data[];  // defined by kernel.ld
1711 pde_t *kpgdir;  // for use in scheduler()
1712 
1713 extern struct gpu gpu;
1714 // Set up CPU's kernel segment descriptors.
1715 // Run once on entry on each CPU.
1716 void
1717 seginit(void)
1718 {
1719   struct cpu *c;
1720 
1721   // Map "logical" addresses to virtual addresses using identity map.
1722   // Cannot share a CODE descriptor for both kernel and user
1723   // because it would have to have DPL_USR, but the CPU forbids
1724   // an interrupt from CPL=0 to DPL=3.
1725   c = &cpus[cpuid()];
1726 
1727   c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
1728   c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
1729   c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
1730   c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
1731   lgdt(c->gdt, sizeof(c->gdt));
1732 }
1733 
1734 // that corresponds to virtual address va.  If alloc!=0,
1735 // create any required page tables pages.
1736 pte_t *
1737 walkpgdir(pde_t *pgdir, const void *va, int alloc)
1738 {
1739   pde_t *pde;
1740   pte_t *pgtab;
1741 
1742   pde = &pgdir[PDX(va)];
1743   if(*pde & PTE_P){
1744     pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
1745   } else {
1746     if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
1747       return 0;
1748     // Make sure all those PTE_P bits are zero.
1749     memset(pgtab, 0, PGSIZE);
1750     // The permissions here are overly generous, but they can
1751     // be further restricted by the permissions in the page table
1752     // entries, if necessary.
1753     *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
1754   }
1755   return &pgtab[PTX(va)];
1756 }
1757 
1758 // Create PTEs for virtual addresses starting at va that refer to
1759 // physical addresses starting at pa. va and size might not
1760 // be page-aligned.
1761 int
1762 mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
1763 {
1764   char *a, *last;
1765   pte_t *pte;
1766 
1767   a = (char*)PGROUNDDOWN((uint)va);
1768   last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
1769   for(;;){
1770     if((pte = walkpgdir(pgdir, a, 1)) == 0)
1771       return -1;
1772     if(*pte & PTE_P)
1773       panic("remap");
1774     *pte = pa | perm | PTE_P;
1775     if(a == last)
1776       break;
1777     a += PGSIZE;
1778     pa += PGSIZE;
1779   }
1780   return 0;
1781 }
1782 
1783 // There is one page table per process, plus one that's used when
1784 // a CPU is not running any process (kpgdir). The kernel uses the
1785 // current process's page table during system calls and interrupts;
1786 // page protection bits prevent user code from using the kernel's
1787 // mappings.
1788 //
1789 // setupkvm() and exec() set up every page table like this:
1790 //
1791 //   0..KERNBASE: user memory (text+data+stack+heap), mapped to
1792 //                phys memory allocated by the kernel
1793 //   KERNBASE..KERNBASE+EXTMEM: mapped to 0..EXTMEM (for I/O space)
1794 //   KERNBASE+EXTMEM..data: mapped to EXTMEM..V2P(data)
1795 //                for the kernel's instructions and r/o data
1796 //   data..KERNBASE+PHYSTOP: mapped to V2P(data)..PHYSTOP,
1797 //                                  rw data + free physical memory
1798 //   0xfe000000..0: mapped direct (devices such as ioapic)
1799 //
1800 // The kernel allocates physical memory for its heap and for user memory
1801 // between V2P(end) and the end of physical memory (PHYSTOP)
1802 // (directly addressable from end..P2V(PHYSTOP)).
1803 
1804 // This table defines the kernel's mappings, which are present in
1805 // every process's page table.
1806 static struct kmap {
1807   void *virt;
1808   uint phys_start;
1809   uint phys_end;
1810   int perm;
1811 } kmap[] = {
1812  { (void*)KERNBASE, 0,             EXTMEM,    PTE_W}, // I/O space
1813  { (void*)KERNLINK, V2P(KERNLINK), V2P(data), 0},     // kern text+rodata
1814  { (void*)data,     V2P(data),     PHYSTOP,   PTE_W}, // kern data+memory
1815  { 0,0,0,0},
1816  { (void*)(PCI_BAR_BASE + PCI_VP_OFFSET),PCI_BAR_BASE,0x10000000+PCI_BAR_BASE,PTE_W},
1817  { (void*)DEVSPACE, DEVSPACE, 0, PTE_W}, // more devices
1818 };
1819 
1820 // Set up kernel part of a page table.
1821 pde_t*
1822 setupkvm(void)
1823 {
1824   pde_t *pgdir;
1825   struct kmap *k;
1826   k = kmap;
1827   struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
1828   k[3] = vram;
1829   if((pgdir = (pde_t*)kalloc()) == 0){
1830     return 0;
1831   }
1832   memset(pgdir, 0, PGSIZE);
1833   if (P2V(PHYSTOP) > (void*)DEVSPACE)
1834     panic("PHYSTOP too high");
1835   for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
1836     if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
1837                 (uint)k->phys_start, k->perm) < 0) {
1838       freevm(pgdir);
1839       return 0;
1840     }
1841   return pgdir;
1842 }
1843 
1844 
1845 
1846 
1847 
1848 
1849 
1850 // Allocate one page table for the machine for the kernel address
1851 // space for scheduler processes.
1852 void
1853 kvmalloc(void)
1854 {
1855   kpgdir = setupkvm();
1856   switchkvm();
1857 }
1858 
1859 // Switch h/w page table register to the kernel-only page table,
1860 // for when no process is running.
1861 void
1862 switchkvm(void)
1863 {
1864   lcr3(V2P(kpgdir));   // switch to the kernel page table
1865 }
1866 
1867 // Switch TSS and h/w page table to correspond to process p.
1868 void
1869 switchuvm(struct proc *p)
1870 {
1871   if(p == 0)
1872     panic("switchuvm: no process");
1873   if(p->kstack == 0)
1874     panic("switchuvm: no kstack");
1875   if(p->pgdir == 0)
1876     panic("switchuvm: no pgdir");
1877 
1878   pushcli();
1879   mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
1880                                 sizeof(mycpu()->ts)-1, 0);
1881   mycpu()->gdt[SEG_TSS].s = 0;
1882   mycpu()->ts.ss0 = SEG_KDATA << 3;
1883   mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
1884   // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
1885   // forbids I/O instructions (e.g., inb and outb) from user space
1886   mycpu()->ts.iomb = (ushort) 0xFFFF;
1887   ltr(SEG_TSS << 3);
1888   lcr3(V2P(p->pgdir));  // switch to process's address space
1889   popcli();
1890 }
1891 
1892 
1893 
1894 
1895 
1896 
1897 
1898 
1899 
1900 // Load the initcode into address 0 of pgdir.
1901 // sz must be less than a page.
1902 void
1903 inituvm(pde_t *pgdir, char *init, uint sz)
1904 {
1905   char *mem;
1906 
1907   if(sz >= PGSIZE)
1908     panic("inituvm: more than a page");
1909   mem = kalloc();
1910   memset(mem, 0, PGSIZE);
1911   mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
1912   memmove(mem, init, sz);
1913 }
1914 
1915 // Load a program segment into pgdir.  addr must be page-aligned
1916 // and the pages from addr to addr+sz must already be mapped.
1917 int
1918 loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
1919 {
1920   uint i, pa, n;
1921   pte_t *pte;
1922 
1923   if((uint) addr % PGSIZE != 0)
1924     panic("loaduvm: addr must be page aligned");
1925   for(i = 0; i < sz; i += PGSIZE){
1926     if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
1927       panic("loaduvm: address should exist");
1928     pa = PTE_ADDR(*pte);
1929     if(sz - i < PGSIZE)
1930       n = sz - i;
1931     else
1932       n = PGSIZE;
1933     if(readi(ip, P2V(pa), offset+i, n) != n)
1934       return -1;
1935   }
1936   return 0;
1937 }
1938 
1939 
1940 
1941 
1942 
1943 
1944 
1945 
1946 
1947 
1948 
1949 
1950 // Allocate page tables and physical memory to grow process from oldsz to
1951 // newsz, which need not be page aligned.  Returns new size or 0 on error.
1952 int
1953 allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
1954 {
1955   char *mem;
1956   uint a;
1957 
1958   if(newsz >= KERNBASE)
1959     return 0;
1960   if(newsz < oldsz)
1961     return oldsz;
1962 
1963   a = PGROUNDUP(oldsz);
1964   for(; a < newsz; a += PGSIZE){
1965     mem = kalloc();
1966     if(mem == 0){
1967       cprintf("allocuvm out of memory\n");
1968       deallocuvm(pgdir, newsz, oldsz);
1969       return 0;
1970     }
1971     memset(mem, 0, PGSIZE);
1972     if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
1973       cprintf("allocuvm out of memory (2)\n");
1974       deallocuvm(pgdir, newsz, oldsz);
1975       kfree(mem);
1976       return 0;
1977     }
1978   }
1979   return newsz;
1980 }
1981 
1982 // Deallocate user pages to bring the process size from oldsz to
1983 // newsz.  oldsz and newsz need not be page-aligned, nor does newsz
1984 // need to be less than oldsz.  oldsz can be larger than the actual
1985 // process size.  Returns the new process size.
1986 int
1987 deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
1988 {
1989   pte_t *pte;
1990   uint a, pa;
1991 
1992   if(newsz >= oldsz)
1993     return oldsz;
1994 
1995   a = PGROUNDUP(newsz);
1996   for(; a  < oldsz; a += PGSIZE){
1997     pte = walkpgdir(pgdir, (char*)a, 0);
1998     if(!pte)
1999       a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
2000     else if((*pte & PTE_P) != 0){
2001       pa = PTE_ADDR(*pte);
2002       if(pa == 0)
2003         panic("kfree");
2004       char *v = P2V(pa);
2005       kfree(v);
2006       *pte = 0;
2007     }
2008   }
2009   return newsz;
2010 }
2011 
2012 // Free a page table and all the physical memory pages
2013 // in the user part.
2014 void
2015 freevm(pde_t *pgdir)
2016 {
2017   uint i;
2018 
2019   if(pgdir == 0)
2020     panic("freevm: no pgdir");
2021   deallocuvm(pgdir, KERNBASE, 0);
2022   for(i = 0; i < NPDENTRIES; i++){
2023     if(pgdir[i] & PTE_P){
2024       char * v = P2V(PTE_ADDR(pgdir[i]));
2025       kfree(v);
2026     }
2027   }
2028   kfree((char*)pgdir);
2029 }
2030 
2031 // Clear PTE_U on a page. Used to create an inaccessible
2032 // page beneath the user stack.
2033 void
2034 clearpteu(pde_t *pgdir, char *uva)
2035 {
2036   pte_t *pte;
2037 
2038   pte = walkpgdir(pgdir, uva, 0);
2039   if(pte == 0)
2040     panic("clearpteu");
2041   *pte &= ~PTE_U;
2042 }
2043 
2044 
2045 
2046 
2047 
2048 
2049 
2050 // Given a parent process's page table, create a copy
2051 // of it for a child.
2052 pde_t*
2053 copyuvm(pde_t *pgdir, uint sz)
2054 {
2055   pde_t *d;
2056   pte_t *pte;
2057   uint pa, i, flags;
2058   char *mem;
2059 
2060   if((d = setupkvm()) == 0)
2061     return 0;
2062   for(i = 0; i < sz; i += PGSIZE){
2063     if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
2064       panic("copyuvm: pte should exist");
2065     if(!(*pte & PTE_P))
2066       panic("copyuvm: page not present");
2067     pa = PTE_ADDR(*pte);
2068     flags = PTE_FLAGS(*pte);
2069     if((mem = kalloc()) == 0)
2070       goto bad;
2071     memmove(mem, (char*)P2V(pa), PGSIZE);
2072     if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
2073       goto bad;
2074   }
2075   return d;
2076 
2077 bad:
2078   freevm(d);
2079   return 0;
2080 }
2081 
2082 
2083 
2084 
2085 
2086 
2087 
2088 
2089 
2090 
2091 
2092 
2093 
2094 
2095 
2096 
2097 
2098 
2099 
2100 // Map user virtual address to kernel address.
2101 char*
2102 uva2ka(pde_t *pgdir, char *uva)
2103 {
2104   pte_t *pte;
2105 
2106   pte = walkpgdir(pgdir, uva, 0);
2107   if((*pte & PTE_P) == 0)
2108     return 0;
2109   if((*pte & PTE_U) == 0)
2110     return 0;
2111   return (char*)P2V(PTE_ADDR(*pte));
2112 }
2113 
2114 // Copy len bytes from p to user address va in page table pgdir.
2115 // Most useful when pgdir is not the current page table.
2116 // uva2ka ensures this only works for PTE_U pages.
2117 int
2118 copyout(pde_t *pgdir, uint va, void *p, uint len)
2119 {
2120   char *buf, *pa0;
2121   uint n, va0;
2122 
2123   buf = (char*)p;
2124   while(len > 0){
2125     va0 = (uint)PGROUNDDOWN(va);
2126     pa0 = uva2ka(pgdir, (char*)va0);
2127     if(pa0 == 0)
2128       return -1;
2129     n = PGSIZE - (va - va0);
2130     if(n > len)
2131       n = len;
2132     memmove(pa0 + (va - va0), buf, n);
2133     len -= n;
2134     buf += n;
2135     va = va0 + PGSIZE;
2136   }
2137   return 0;
2138 }
2139 
2140 
2141 
2142 
2143 
2144 
2145 
2146 
2147 
2148 
2149 
2150 // Blank page.
2151 
2152 
2153 
2154 
2155 
2156 
2157 
2158 
2159 
2160 
2161 
2162 
2163 
2164 
2165 
2166 
2167 
2168 
2169 
2170 
2171 
2172 
2173 
2174 
2175 
2176 
2177 
2178 
2179 
2180 
2181 
2182 
2183 
2184 
2185 
2186 
2187 
2188 
2189 
2190 
2191 
2192 
2193 
2194 
2195 
2196 
2197 
2198 
2199 
2200 // Blank page.
2201 
2202 
2203 
2204 
2205 
2206 
2207 
2208 
2209 
2210 
2211 
2212 
2213 
2214 
2215 
2216 
2217 
2218 
2219 
2220 
2221 
2222 
2223 
2224 
2225 
2226 
2227 
2228 
2229 
2230 
2231 
2232 
2233 
2234 
2235 
2236 
2237 
2238 
2239 
2240 
2241 
2242 
2243 
2244 
2245 
2246 
2247 
2248 
2249 
2250 // Blank page.
2251 
2252 
2253 
2254 
2255 
2256 
2257 
2258 
2259 
2260 
2261 
2262 
2263 
2264 
2265 
2266 
2267 
2268 
2269 
2270 
2271 
2272 
2273 
2274 
2275 
2276 
2277 
2278 
2279 
2280 
2281 
2282 
2283 
2284 
2285 
2286 
2287 
2288 
2289 
2290 
2291 
2292 
2293 
2294 
2295 
2296 
2297 
2298 
2299 
