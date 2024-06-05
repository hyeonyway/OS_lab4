0200 // Memory layout
0201 
0202 #define EXTMEM  0x100000            // Start of extended memory
0203 #define PHYSTOP 0x20000000         // Top physical memory
0204 #define DEVSPACE 0xFE000000         // Other devices are at high addresses
0205 #define BOOTPARAM 0x50000
0206 
0207 // Key addresses for address space layout (see kmap in vm.c for layout)
0208 #define KERNBASE 0x80000000         // First kernel virtual address
0209 //#define KERNBASE 0x0000000         // First kernel virtual address
0210 #define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked
0211 
0212 #define PCI_BAR_BASE 0x80000000
0213 #define PCI_VP_OFFSET 0x40000000
0214 #define PCI_P2V(a) (((uint)(a)) + PCI_VP_OFFSET)
0215 #define V2P(a) (((uint) (a)) - KERNBASE)
0216 #define P2V(a) (((void *) (a)) + KERNBASE)
0217 
0218 #define V2P_WO(x) ((x) - KERNBASE)    // same as V2P, but without casts
0219 #define P2V_WO(x) ((x) + KERNBASE)    // same as P2V, but without casts
0220 
0221 
0222 
0223 
0224 
0225 
0226 
0227 
0228 
0229 
0230 
0231 
0232 
0233 
0234 
0235 
0236 
0237 
0238 
0239 
0240 
0241 
0242 
0243 
0244 
0245 
0246 
0247 
0248 
0249 
