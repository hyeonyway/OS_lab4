3450 #include "types.h"
3451 #include "defs.h"
3452 #include "param.h"
3453 #include "memlayout.h"
3454 #include "mmu.h"
3455 #include "proc.h"
3456 #include "x86.h"
3457 #include "traps.h"
3458 #include "spinlock.h"
3459 #include "i8254.h"
3460 
3461 // Interrupt descriptor table (shared by all CPUs).
3462 struct gatedesc idt[256];
3463 extern uint vectors[];  // in vectors.S: array of 256 entry pointers
3464 struct spinlock tickslock;
3465 uint ticks;
3466 
3467 void
3468 tvinit(void)
3469 {
3470   int i;
3471 
3472   for(i = 0; i < 256; i++)
3473     SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
3474   SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
3475 
3476   initlock(&tickslock, "time");
3477 }
3478 
3479 void
3480 idtinit(void)
3481 {
3482   lidt(idt, sizeof(idt));
3483 }
3484 
3485 
3486 
3487 
3488 
3489 
3490 
3491 
3492 
3493 
3494 
3495 
3496 
3497 
3498 
3499 
3500 void
3501 trap(struct trapframe *tf)
3502 {
3503   if(tf->trapno == T_SYSCALL){
3504     if(myproc()->killed)
3505       exit();
3506     myproc()->tf = tf;
3507     syscall();
3508     if(myproc()->killed)
3509       exit();
3510     return;
3511   }
3512 
3513   switch(tf->trapno){
3514   case T_IRQ0 + IRQ_TIMER:
3515     if(cpuid() == 0){
3516       acquire(&tickslock);
3517       ticks++;
3518       wakeup(&ticks);
3519       release(&tickslock);
3520     }
3521     lapiceoi();
3522     break;
3523   case T_IRQ0 + IRQ_IDE:
3524     ideintr();
3525     lapiceoi();
3526     break;
3527   case T_IRQ0 + IRQ_IDE+1:
3528     // Bochs generates spurious IDE1 interrupts.
3529     break;
3530   case T_IRQ0 + IRQ_KBD:
3531     kbdintr();
3532     lapiceoi();
3533     break;
3534   case T_IRQ0 + IRQ_COM1:
3535     uartintr();
3536     lapiceoi();
3537     break;
3538   case T_IRQ0 + 0xB:
3539     i8254_intr();
3540     lapiceoi();
3541     break;
3542   case T_IRQ0 + IRQ_SPURIOUS:
3543     cprintf("cpu%d: spurious interrupt at %x:%x\n",
3544             cpuid(), tf->cs, tf->eip);
3545     lapiceoi();
3546     break;
3547 
3548 
3549 
3550   case T_PGFLT:
3551     uint va = PGROUNDDOWN(rcr2());
3552     struct proc *curproc = myproc();
3553 
3554     if(va >= KERNBASE - curproc->stack_size - PGSIZE) {
3555       if(allocuvm(curproc->pgdir, va, va + PGSIZE) == 0) {
3556         cprintf("trap: page fault at 0x%x, process killed\n", rcr2());
3557         curproc->killed = 1;
3558       } else {
3559         curproc->stack_size += PGSIZE;
3560         lcr3(V2P(myproc()->pgdir)); // Flushing TLBs
3561       }
3562       return;
3563     }
3564 
3565 
3566   default:
3567     if(myproc() == 0 || (tf->cs&3) == 0){
3568       // In kernel, it must be our mistake.
3569       cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
3570               tf->trapno, cpuid(), tf->eip, rcr2());
3571       panic("trap");
3572     }
3573     // In user space, assume process misbehaved.
3574     cprintf("pid %d %s: trap %d err %d on cpu %d "
3575             "eip 0x%x addr 0x%x--kill proc\n",
3576             myproc()->pid, myproc()->name, tf->trapno,
3577             tf->err, cpuid(), tf->eip, rcr2());
3578     myproc()->killed = 1;
3579   }
3580 
3581   // Force process exit if it has been killed and is in user space.
3582   // (If it is still executing in the kernel, let it keep running
3583   // until it gets to the regular system call return.)
3584   if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
3585     exit();
3586 
3587   // Force process to give up CPU on clock tick.
3588   // If interrupts were on while locks held, would need to check nlock.
3589   if(myproc() && myproc()->state == RUNNING &&
3590      tf->trapno == T_IRQ0+IRQ_TIMER)
3591     yield();
3592 
3593   // Check if the process has been killed since we yielded
3594   if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
3595     exit();
3596 }
3597 
3598 
3599 
