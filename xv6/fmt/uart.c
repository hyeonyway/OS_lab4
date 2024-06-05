8500 // Intel 8250 serial port (UART).
8501 
8502 #include "types.h"
8503 #include "defs.h"
8504 #include "param.h"
8505 #include "traps.h"
8506 #include "spinlock.h"
8507 #include "sleeplock.h"
8508 #include "fs.h"
8509 #include "file.h"
8510 #include "mmu.h"
8511 #include "proc.h"
8512 #include "x86.h"
8513 
8514 #define COM1    0x3f8
8515 
8516 static int uart;    // is there a uart?
8517 
8518 void
8519 uartinit(void)
8520 {
8521   char *p;
8522 
8523   // Turn off the FIFO
8524   outb(COM1+2, 0);
8525 
8526   // 9600 baud, 8 data bits, 1 stop bit, parity off.
8527   outb(COM1+3, 0x80);    // Unlock divisor
8528   outb(COM1+0, 115200/9600);
8529   outb(COM1+1, 0);
8530   outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8531   outb(COM1+4, 0);
8532   outb(COM1+1, 0x01);    // Enable receive interrupts.
8533 
8534   // If status is 0xFF, no serial port.
8535   if(inb(COM1+5) == 0xFF)
8536     return;
8537   uart = 1;
8538 
8539   // Acknowledge pre-existing interrupt conditions;
8540   // enable interrupts.
8541   inb(COM1+2);
8542   inb(COM1+0);
8543   ioapicenable(IRQ_COM1, 0);
8544 
8545   // Announce that we're here.
8546   for(p="xv6...\n"; *p; p++)
8547     uartputc(*p);
8548 }
8549 
8550 void
8551 uartputc(int c)
8552 {
8553   int i;
8554 
8555   if(!uart)
8556     return;
8557   for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8558     microdelay(10);
8559   outb(COM1+0, c);
8560 }
8561 
8562 static int
8563 uartgetc(void)
8564 {
8565   if(!uart)
8566     return -1;
8567   if(!(inb(COM1+5) & 0x01))
8568     return -1;
8569   return inb(COM1+0);
8570 }
8571 
8572 void
8573 uartintr(void)
8574 {
8575   consoleintr(uartgetc);
8576 }
8577 
8578 
8579 
8580 
8581 
8582 
8583 
8584 
8585 
8586 
8587 
8588 
8589 
8590 
8591 
8592 
8593 
8594 
8595 
8596 
8597 
8598 
8599 
