6750 #include "types.h"
6751 #include "param.h"
6752 #include "memlayout.h"
6753 #include "mmu.h"
6754 #include "proc.h"
6755 #include "defs.h"
6756 #include "x86.h"
6757 #include "elf.h"
6758 
6759 int
6760 exec(char *path, char **argv)
6761 {
6762   char *s, *last;
6763   int i, off;
6764   uint argc, sz, sp, ustack[3+MAXARG+1];
6765   struct elfhdr elf;
6766   struct inode *ip;
6767   struct proghdr ph;
6768   pde_t *pgdir, *oldpgdir;
6769   struct proc *curproc = myproc();
6770 
6771   begin_op();
6772 
6773   if((ip = namei(path)) == 0){
6774     end_op();
6775     cprintf("exec: fail\n");
6776     return -1;
6777   }
6778   ilock(ip);
6779   pgdir = 0;
6780 
6781   // Check ELF header
6782   if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
6783     goto bad;
6784   if(elf.magic != ELF_MAGIC)
6785     goto bad;
6786 
6787   if((pgdir = setupkvm()) == 0)
6788     goto bad;
6789 
6790   // Load program into memory.
6791   sz = 0;
6792   for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
6793     if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
6794       goto bad;
6795     if(ph.type != ELF_PROG_LOAD)
6796       continue;
6797     if(ph.memsz < ph.filesz)
6798       goto bad;
6799     if(ph.vaddr + ph.memsz < ph.vaddr)
6800       goto bad;
6801     if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
6802       goto bad;
6803     if(ph.vaddr % PGSIZE != 0)
6804       goto bad;
6805     if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
6806       goto bad;
6807   }
6808   iunlockput(ip);
6809   end_op();
6810   ip = 0;
6811 
6812   // Allocate two pages at the next page boundary.
6813   // Make the first inaccessible.  Use the second as the user stack.
6814 /*   sz = PGROUNDUP(sz);
6815   cprintf(" after PGROUNDUP sz = %d \n", sz);
6816   if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
6817     goto bad;
6818   cprintf(" after allocuvm sz = %d \n", sz);
6819   clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
6820   sp = sz; */
6821 
6822     // 스택을 KERNBASE 바로 아래에 할당
6823   // sz = 프로세스의 메모리 크기
6824   sz = PGROUNDDOWN(sz) + PGSIZE;
6825   sp = KERNBASE - 1;
6826   if((allocuvm(pgdir, sp - PGSIZE, sp)) == 0)
6827     goto bad;
6828   curproc->stack_size = PGSIZE;
6829 
6830   // Push argument strings, prepare rest of stack in ustack.
6831   for(argc = 0; argv[argc]; argc++) {
6832     if(argc >= MAXARG)
6833       goto bad;
6834     sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
6835     if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
6836       goto bad;
6837     ustack[3+argc] = sp;
6838   }
6839   ustack[3+argc] = 0;
6840 
6841   ustack[0] = 0xffffffff;  // fake return PC
6842   ustack[1] = argc;
6843   ustack[2] = sp - (argc+1)*4;  // argv pointer
6844 
6845   sp -= (3+argc+1) * 4;
6846   if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
6847     goto bad;
6848 
6849 
6850   // Save program name for debugging.
6851   for(last=s=path; *s; s++)
6852     if(*s == '/')
6853       last = s+1;
6854   safestrcpy(curproc->name, last, sizeof(curproc->name));
6855 
6856   // Commit to the user image.
6857   oldpgdir = curproc->pgdir;
6858   curproc->pgdir = pgdir;
6859   curproc->sz = sz;
6860   curproc->tf->eip = elf.entry;  // main
6861   curproc->tf->esp = sp;
6862   switchuvm(curproc);
6863   freevm(oldpgdir);
6864   return 0;
6865 
6866  bad:
6867   if(pgdir)
6868     freevm(pgdir);
6869   if(ip){
6870     iunlockput(ip);
6871     end_op();
6872   }
6873   return -1;
6874 }
6875 
6876 
6877 
6878 
6879 
6880 
6881 
6882 
6883 
6884 
6885 
6886 
6887 
6888 
6889 
6890 
6891 
6892 
6893 
6894 
6895 
6896 
6897 
6898 
6899 
