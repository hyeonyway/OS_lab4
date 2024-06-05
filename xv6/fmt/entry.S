1000 # The xv6 kernel starts executing in this file. This file is linked with
1001 # the kernel C code, so it can refer to kernel symbols such as main().
1002 # The boot block (bootasm.S and bootmain.c) jumps to entry below.
1003 
1004 # Multiboot header, for multiboot boot loaders like GNU Grub.
1005 # http://www.gnu.org/software/grub/manual/multiboot/multiboot.html
1006 #
1007 # Using GRUB 2, you can boot xv6 from a file stored in a
1008 # Linux file system by copying kernel or kernelmemfs to /boot
1009 # and then adding this menu entry:
1010 #
1011 # menuentry "xv6" {
1012 # 	insmod ext2
1013 # 	set root='(hd0,msdos1)'
1014 # 	set kernel='/boot/kernel'
1015 # 	echo "Loading ${kernel}..."
1016 # 	multiboot ${kernel} ${kernel}
1017 # 	boot
1018 # }
1019 
1020 #include "asm.h"
1021 #include "memlayout.h"
1022 #include "mmu.h"
1023 #include "param.h"
1024 
1025 # Multiboot header.  Data to direct multiboot loader.
1026 .p2align 2
1027 .text
1028 .globl multiboot_header
1029 multiboot_header:
1030   #define magic 0x1badb002
1031   #define flags 0
1032   .long magic
1033   .long flags
1034   .long (-magic-flags)
1035 
1036 # By convention, the _start symbol specifies the ELF entry point.
1037 # Since we haven't set up virtual memory yet, our entry point is
1038 # the physical address of 'entry'.
1039 .globl _start
1040 _start = V2P_WO(entry)
1041 
1042 .globl wait_main
1043 wait_main:
1044   .long 0
1045 # Entering xv6 on boot processor, with paging off.
1046 .globl entry
1047 entry:
1048   #Set Data Segment
1049   mov $0x10,%ax
1050   mov %ax,%ds
1051   mov %ax,%es
1052   mov %ax,%ss
1053   mov $0,%ax
1054   mov %ax,%fs
1055   mov %ax,%gs
1056 
1057   #Turn off paing
1058   movl %cr0,%eax
1059   andl $0x7fffffff,%eax
1060   movl %eax,%cr0
1061 
1062   #Set Page Table Base Address
1063   movl    $(V2P_WO(entrypgdir)), %eax
1064   movl    %eax, %cr3
1065 
1066   #Disable IA32e mode
1067   movl $0x0c0000080,%ecx
1068   rdmsr
1069   andl $0xFFFFFEFF,%eax
1070   wrmsr
1071 
1072   # Turn on page size extension for 4Mbyte pages
1073   movl    %cr4, %eax
1074   orl     $(CR4_PSE), %eax
1075   andl    $0xFFFFFFDF, %eax
1076   movl    %eax, %cr4
1077 
1078   #Turn on Paging
1079   movl    %cr0, %eax
1080   orl     $0x80010001, %eax
1081   movl    %eax, %cr0
1082 
1083 
1084 
1085 
1086   # Set up the stack pointer.
1087   movl $(stack + KSTACKSIZE), %esp
1088   # Jump to main(), and switch to executing at
1089   # high addresses. The indirect call is needed because
1090   # the assembler produces a PC-relative instruction
1091   # for a direct jump.
1092 #  jz .waiting_main
1093   movl $main, %edx
1094   jmp %edx
1095 
1096 .comm stack, KSTACKSIZE
1097 
1098 
1099 
