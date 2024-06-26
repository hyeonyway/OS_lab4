7500 // The local APIC manages internal (non-I/O) interrupts.
7501 // See Chapter 8 & Appendix C of Intel processor manual volume 3.
7502 
7503 #include "param.h"
7504 #include "types.h"
7505 #include "defs.h"
7506 #include "date.h"
7507 #include "memlayout.h"
7508 #include "traps.h"
7509 #include "mmu.h"
7510 #include "x86.h"
7511 #include "debug.h"
7512 // Local APIC registers, divided by 4 for use as uint[] indices.
7513 #define ID      (0x0020/4)   // ID
7514 #define VER     (0x0030/4)   // Version
7515 #define TPR     (0x0080/4)   // Task Priority
7516 #define EOI     (0x00B0/4)   // EOI
7517 #define SVR     (0x00F0/4)   // Spurious Interrupt Vector
7518   #define ENABLE     0x00000100   // Unit Enable
7519 #define ESR     (0x0280/4)   // Error Status
7520 #define ICRLO   (0x0300/4)   // Interrupt Command
7521   #define INIT       0x00000500   // INIT/RESET
7522   #define STARTUP    0x00000600   // Startup IPI
7523   #define DELIVS     0x00001000   // Delivery status
7524   #define ASSERT     0x00004000   // Assert interrupt (vs deassert)
7525   #define DEASSERT   0x00000000
7526   #define LEVEL      0x00008000   // Level triggered
7527   #define BCAST      0x00080000   // Send to all APICs, including self.
7528   #define BUSY       0x00001000
7529   #define FIXED      0x00000000
7530 #define ICRHI   (0x0310/4)   // Interrupt Command [63:32]
7531 #define TIMER   (0x0320/4)   // Local Vector Table 0 (TIMER)
7532   #define X1         0x0000000B   // divide counts by 1
7533   #define PERIODIC   0x00020000   // Periodic
7534 #define PCINT   (0x0340/4)   // Performance Counter LVT
7535 #define LINT0   (0x0350/4)   // Local Vector Table 1 (LINT0)
7536 #define LINT1   (0x0360/4)   // Local Vector Table 2 (LINT1)
7537 #define ERROR   (0x0370/4)   // Local Vector Table 3 (ERROR)
7538   #define MASKED     0x00010000   // Interrupt masked
7539 #define TICR    (0x0380/4)   // Timer Initial Count
7540 #define TCCR    (0x0390/4)   // Timer Current Count
7541 #define TDCR    (0x03E0/4)   // Timer Divide Configuration
7542 
7543 volatile uint *lapic;  // Initialized in mp.c
7544 
7545 
7546 
7547 
7548 
7549 
7550 static void
7551 lapicw(int index, int value)
7552 {
7553   lapic[index] = value;
7554   lapic[ID];  // wait for write to finish, by reading
7555 }
7556 
7557 void
7558 lapicinit(void)
7559 {
7560   if(!lapic)
7561     return;
7562 
7563   // Enable local APIC; set spurious interrupt vector.
7564   lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
7565 
7566   // The timer repeatedly counts down at bus frequency
7567   // from lapic[TICR] and then issues an interrupt.
7568   // If xv6 cared more about precise timekeeping,
7569   // TICR would be calibrated using an external time source.
7570   lapicw(TDCR, X1);
7571   lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
7572   lapicw(TICR, 10000000);
7573 
7574   // Disable logical interrupt lines.
7575   lapicw(LINT0, MASKED);
7576   lapicw(LINT1, MASKED);
7577 
7578   // Disable performance counter overflow interrupts
7579   // on machines that provide that interrupt entry.
7580   if(((lapic[VER]>>16) & 0xFF) >= 4)
7581     lapicw(PCINT, MASKED);
7582 
7583   // Map error interrupt to IRQ_ERROR.
7584   lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
7585 
7586   // Clear error status register (requires back-to-back writes).
7587   lapicw(ESR, 0);
7588   lapicw(ESR, 0);
7589 
7590   // Ack any outstanding interrupts.
7591   lapicw(EOI, 0);
7592 
7593   // Send an Init Level De-Assert to synchronise arbitration ID's.
7594   lapicw(ICRHI, 0);
7595   lapicw(ICRLO, BCAST | INIT | LEVEL);
7596   while(lapic[ICRLO] & DELIVS)
7597     ;
7598 
7599 
7600   // Enable interrupts on the APIC (but not on the processor).
7601   lapicw(TPR, 0);
7602 }
7603 
7604 int
7605 lapicid(void)
7606 {
7607 
7608   if (!lapic){
7609     return 0;
7610   }
7611   return lapic[ID] >> 24;
7612 }
7613 
7614 // Acknowledge interrupt.
7615 void
7616 lapiceoi(void)
7617 {
7618   if(lapic)
7619     lapicw(EOI, 0);
7620 }
7621 
7622 // Spin for a given number of microseconds.
7623 // On real hardware would want to tune this dynamically.
7624 void
7625 microdelay(int us)
7626 {
7627 }
7628 
7629 #define CMOS_PORT    0x70
7630 #define CMOS_RETURN  0x71
7631 
7632 // Start additional processor running entry code at addr.
7633 // See Appendix B of MultiProcessor Specification.
7634 void
7635 lapicstartap(uchar apicid, uint addr)
7636 {
7637   int i;
7638   ushort *wrv;
7639 
7640   // "The BSP must initialize CMOS shutdown code to 0AH
7641   // and the warm reset vector (DWORD based at 40:67) to point at
7642   // the AP startup code prior to the [universal startup algorithm]."
7643   outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
7644   outb(CMOS_PORT+1, 0x0A);
7645   wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
7646   wrv[0] = 0;
7647   wrv[1] = addr >> 4;
7648 
7649 
7650   // "Universal startup algorithm."
7651   // Send INIT (level-triggered) interrupt to reset other CPU.
7652   lapicw(ICRHI, apicid<<24);
7653   lapicw(ICRLO, INIT | LEVEL | ASSERT);
7654   microdelay(200);
7655   lapicw(ICRLO, INIT | LEVEL);
7656   microdelay(100);    // should be 10ms, but too slow in Bochs!
7657 
7658   // Send startup IPI (twice!) to enter code.
7659   // Regular hardware is supposed to only accept a STARTUP
7660   // when it is in the halted state due to an INIT.  So the second
7661   // should be ignored, but it is part of the official Intel algorithm.
7662   // Bochs complains about the second one.  Too bad for Bochs.
7663   for(i = 0; i < 2; i++){
7664     lapicw(ICRHI, apicid<<24);
7665     lapicw(ICRLO, STARTUP | (addr>>12));
7666     microdelay(200);
7667   }
7668 }
7669 
7670 #define CMOS_STATA   0x0a
7671 #define CMOS_STATB   0x0b
7672 #define CMOS_UIP    (1 << 7)        // RTC update in progress
7673 
7674 #define SECS    0x00
7675 #define MINS    0x02
7676 #define HOURS   0x04
7677 #define DAY     0x07
7678 #define MONTH   0x08
7679 #define YEAR    0x09
7680 
7681 static uint cmos_read(uint reg)
7682 {
7683   outb(CMOS_PORT,  reg);
7684   microdelay(200);
7685 
7686   return inb(CMOS_RETURN);
7687 }
7688 
7689 static void fill_rtcdate(struct rtcdate *r)
7690 {
7691   r->second = cmos_read(SECS);
7692   r->minute = cmos_read(MINS);
7693   r->hour   = cmos_read(HOURS);
7694   r->day    = cmos_read(DAY);
7695   r->month  = cmos_read(MONTH);
7696   r->year   = cmos_read(YEAR);
7697 }
7698 
7699 
7700 // qemu seems to use 24-hour GWT and the values are BCD encoded
7701 void cmostime(struct rtcdate *r)
7702 {
7703   struct rtcdate t1, t2;
7704   int sb, bcd;
7705 
7706   sb = cmos_read(CMOS_STATB);
7707 
7708   bcd = (sb & (1 << 2)) == 0;
7709 
7710   // make sure CMOS doesn't modify time while we read it
7711   for(;;) {
7712     fill_rtcdate(&t1);
7713     if(cmos_read(CMOS_STATA) & CMOS_UIP)
7714         continue;
7715     fill_rtcdate(&t2);
7716     if(memcmp(&t1, &t2, sizeof(t1)) == 0)
7717       break;
7718   }
7719 
7720   // convert
7721   if(bcd) {
7722 #define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
7723     CONV(second);
7724     CONV(minute);
7725     CONV(hour  );
7726     CONV(day   );
7727     CONV(month );
7728     CONV(year  );
7729 #undef     CONV
7730   }
7731 
7732   *r = t1;
7733   r->year += 2000;
7734 }
7735 
7736 
7737 
7738 
7739 
7740 
7741 
7742 
7743 
7744 
7745 
7746 
7747 
7748 
7749 
