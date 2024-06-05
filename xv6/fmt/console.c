8050 // Console input and output.
8051 // Input is from the keyboard or serial port.
8052 // Output is written to the screen and serial port.
8053 
8054 #include "types.h"
8055 #include "defs.h"
8056 #include "param.h"
8057 #include "traps.h"
8058 #include "spinlock.h"
8059 #include "sleeplock.h"
8060 #include "fs.h"
8061 #include "file.h"
8062 #include "memlayout.h"
8063 #include "mmu.h"
8064 #include "proc.h"
8065 #include "x86.h"
8066 #include "font.h"
8067 #include "graphic.h"
8068 
8069 static void consputc(int);
8070 
8071 static int panicked = 0;
8072 
8073 static struct {
8074   struct spinlock lock;
8075   int locking;
8076 } cons;
8077 
8078 static void
8079 printint(int xx, int base, int sign)
8080 {
8081   static char digits[] = "0123456789abcdef";
8082   char buf[16];
8083   int i;
8084   uint x;
8085 
8086   if(sign && (sign = xx < 0))
8087     x = -xx;
8088   else
8089     x = xx;
8090 
8091   i = 0;
8092   do{
8093     buf[i++] = digits[x % base];
8094   }while((x /= base) != 0);
8095 
8096   if(sign)
8097     buf[i++] = '-';
8098 
8099 
8100   while(--i >= 0)
8101     consputc(buf[i]);
8102 }
8103 
8104 
8105 
8106 
8107 
8108 
8109 
8110 
8111 
8112 
8113 
8114 
8115 
8116 
8117 
8118 
8119 
8120 
8121 
8122 
8123 
8124 
8125 
8126 
8127 
8128 
8129 
8130 
8131 
8132 
8133 
8134 
8135 
8136 
8137 
8138 
8139 
8140 
8141 
8142 
8143 
8144 
8145 
8146 
8147 
8148 
8149 
8150 // Print to the console. only understands %d, %x, %p, %s.
8151 void
8152 cprintf(char *fmt, ...)
8153 {
8154   int i, c, locking;
8155   uint *argp;
8156   char *s;
8157 
8158   locking = cons.locking;
8159   if(locking)
8160     acquire(&cons.lock);
8161 
8162   if (fmt == 0)
8163     panic("null fmt");
8164 
8165 
8166   argp = (uint*)(void*)(&fmt + 1);
8167   for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8168     if(c != '%'){
8169       consputc(c);
8170       continue;
8171     }
8172     c = fmt[++i] & 0xff;
8173     if(c == 0)
8174       break;
8175     switch(c){
8176     case 'd':
8177       printint(*argp++, 10, 1);
8178       break;
8179     case 'x':
8180     case 'p':
8181       printint(*argp++, 16, 0);
8182       break;
8183     case 's':
8184       if((s = (char*)*argp++) == 0)
8185         s = "(null)";
8186       for(; *s; s++)
8187         consputc(*s);
8188       break;
8189     case '%':
8190       consputc('%');
8191       break;
8192     default:
8193       // Print unknown % sequence to draw attention.
8194       consputc('%');
8195       consputc(c);
8196       break;
8197     }
8198   }
8199 
8200   if(locking)
8201     release(&cons.lock);
8202 }
8203 
8204 void
8205 panic(char *s)
8206 {
8207   int i;
8208   uint pcs[10];
8209 
8210   cli();
8211   cons.locking = 0;
8212   // use lapiccpunum so that we can call panic from mycpu()
8213   cprintf("lapicid %d: panic: ", lapicid());
8214   cprintf(s);
8215   cprintf("\n");
8216   getcallerpcs(&s, pcs);
8217   for(i=0; i<10; i++)
8218     cprintf(" %p", pcs[i]);
8219   panicked = 1; // freeze other CPU
8220   for(;;)
8221     ;
8222 }
8223 
8224 
8225 
8226 
8227 
8228 
8229 
8230 
8231 
8232 
8233 
8234 
8235 
8236 
8237 
8238 
8239 
8240 
8241 
8242 
8243 
8244 
8245 
8246 
8247 
8248 
8249 
8250 #define BACKSPACE 0x100
8251 #define CRTPORT 0x3d4
8252 /*static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory
8253 
8254 static void
8255 cgaputc(int c)
8256 {
8257   int pos;
8258 
8259   // Cursor position: col + 80*row.
8260   outb(CRTPORT, 14);
8261   pos = inb(CRTPORT+1) << 8;
8262   outb(CRTPORT, 15);
8263   pos |= inb(CRTPORT+1);
8264 
8265   if(c == '\n')
8266     pos += 80 - pos%80;
8267   else if(c == BACKSPACE){
8268     if(pos > 0) --pos;
8269   } else
8270     crt[pos++] = (c&0xff) | 0x0700;  // black on white
8271 
8272   if(pos < 0 || pos > 25*80)
8273     panic("pos under/overflow");
8274 
8275   if((pos/80) >= 24){  // Scroll up.
8276     memmove(crt, crt+80, sizeof(crt[0])*23*80);
8277     pos -= 80;
8278     memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
8279   }
8280 
8281   outb(CRTPORT, 14);
8282   outb(CRTPORT+1, pos>>8);
8283   outb(CRTPORT, 15);
8284   outb(CRTPORT+1, pos);
8285   crt[pos] = ' ' | 0x0700;
8286 }*/
8287 
8288 
8289 #define CONSOLE_HORIZONTAL_MAX 53
8290 #define CONSOLE_VERTICAL_MAX 20
8291 int console_pos = CONSOLE_HORIZONTAL_MAX*(CONSOLE_VERTICAL_MAX);
8292 //int console_pos = 0;
8293 void graphic_putc(int c){
8294   if(c == '\n'){
8295     console_pos += CONSOLE_HORIZONTAL_MAX - console_pos%CONSOLE_HORIZONTAL_MAX;
8296     if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
8297       console_pos -= CONSOLE_HORIZONTAL_MAX;
8298       graphic_scroll_up(30);
8299     }
8300   }else if(c == BACKSPACE){
8301     if(console_pos>0) --console_pos;
8302   }else{
8303     if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
8304       console_pos -= CONSOLE_HORIZONTAL_MAX;
8305       graphic_scroll_up(30);
8306     }
8307     int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
8308     int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
8309     font_render(x,y,c);
8310     console_pos++;
8311   }
8312 }
8313 
8314 
8315 void
8316 consputc(int c)
8317 {
8318   if(panicked){
8319     cli();
8320     for(;;)
8321       ;
8322   }
8323 
8324   if(c == BACKSPACE){
8325     uartputc('\b'); uartputc(' '); uartputc('\b');
8326   } else {
8327     uartputc(c);
8328   }
8329   graphic_putc(c);
8330 }
8331 
8332 #define INPUT_BUF 128
8333 struct {
8334   char buf[INPUT_BUF];
8335   uint r;  // Read index
8336   uint w;  // Write index
8337   uint e;  // Edit index
8338 } input;
8339 
8340 #define C(x)  ((x)-'@')  // Control-x
8341 
8342 void
8343 consoleintr(int (*getc)(void))
8344 {
8345   int c, doprocdump = 0;
8346 
8347   acquire(&cons.lock);
8348   while((c = getc()) >= 0){
8349     switch(c){
8350     case C('P'):  // Process listing.
8351       // procdump() locks cons.lock indirectly; invoke later
8352       doprocdump = 1;
8353       break;
8354     case C('U'):  // Kill line.
8355       while(input.e != input.w &&
8356             input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8357         input.e--;
8358         consputc(BACKSPACE);
8359       }
8360       break;
8361     case C('H'): case '\x7f':  // Backspace
8362       if(input.e != input.w){
8363         input.e--;
8364         consputc(BACKSPACE);
8365       }
8366       break;
8367     default:
8368       if(c != 0 && input.e-input.r < INPUT_BUF){
8369         c = (c == '\r') ? '\n' : c;
8370         input.buf[input.e++ % INPUT_BUF] = c;
8371         consputc(c);
8372         if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
8373           input.w = input.e;
8374           wakeup(&input.r);
8375         }
8376       }
8377       break;
8378     }
8379   }
8380   release(&cons.lock);
8381   if(doprocdump) {
8382     procdump();  // now call procdump() wo. cons.lock held
8383   }
8384 }
8385 
8386 
8387 
8388 
8389 
8390 
8391 
8392 
8393 
8394 
8395 
8396 
8397 
8398 
8399 
8400 int
8401 consoleread(struct inode *ip, char *dst, int n)
8402 {
8403   uint target;
8404   int c;
8405 
8406   iunlock(ip);
8407   target = n;
8408   acquire(&cons.lock);
8409   while(n > 0){
8410     while(input.r == input.w){
8411       if(myproc()->killed){
8412         release(&cons.lock);
8413         ilock(ip);
8414         return -1;
8415       }
8416       sleep(&input.r, &cons.lock);
8417     }
8418     c = input.buf[input.r++ % INPUT_BUF];
8419     if(c == C('D')){  // EOF
8420       if(n < target){
8421         // Save ^D for next time, to make sure
8422         // caller gets a 0-byte result.
8423         input.r--;
8424       }
8425       break;
8426     }
8427     *dst++ = c;
8428     --n;
8429     if(c == '\n')
8430       break;
8431   }
8432   release(&cons.lock);
8433   ilock(ip);
8434 
8435   return target - n;
8436 }
8437 
8438 
8439 
8440 
8441 
8442 
8443 
8444 
8445 
8446 
8447 
8448 
8449 
8450 int
8451 consolewrite(struct inode *ip, char *buf, int n)
8452 {
8453   int i;
8454 
8455   iunlock(ip);
8456   acquire(&cons.lock);
8457   for(i = 0; i < n; i++)
8458     consputc(buf[i] & 0xff);
8459   release(&cons.lock);
8460   ilock(ip);
8461 
8462   return n;
8463 }
8464 
8465 void
8466 consoleinit(void)
8467 {
8468   panicked = 0;
8469   initlock(&cons.lock, "console");
8470 
8471   devsw[CONSOLE].write = consolewrite;
8472   devsw[CONSOLE].read = consoleread;
8473 
8474   char *p;
8475   for(p="Starting XV6_UEFI...\n"; *p; p++)
8476     graphic_putc(*p);
8477 
8478   cons.locking = 1;
8479 
8480   ioapicenable(IRQ_KBD, 0);
8481 }
8482 
8483 
8484 
8485 
8486 
8487 
8488 
8489 
8490 
8491 
8492 
8493 
8494 
8495 
8496 
8497 
8498 
8499 
