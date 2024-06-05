
kernelmemfs:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <wait_main>:
8010000c:	00 00                	add    %al,(%eax)
	...

80100010 <entry>:
  .long 0
# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  #Set Data Segment
  mov $0x10,%ax
80100010:	66 b8 10 00          	mov    $0x10,%ax
  mov %ax,%ds
80100014:	8e d8                	mov    %eax,%ds
  mov %ax,%es
80100016:	8e c0                	mov    %eax,%es
  mov %ax,%ss
80100018:	8e d0                	mov    %eax,%ss
  mov $0,%ax
8010001a:	66 b8 00 00          	mov    $0x0,%ax
  mov %ax,%fs
8010001e:	8e e0                	mov    %eax,%fs
  mov %ax,%gs
80100020:	8e e8                	mov    %eax,%gs

  #Turn off paing
  movl %cr0,%eax
80100022:	0f 20 c0             	mov    %cr0,%eax
  andl $0x7fffffff,%eax
80100025:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
  movl %eax,%cr0 
8010002a:	0f 22 c0             	mov    %eax,%cr0

  #Set Page Table Base Address
  movl    $(V2P_WO(entrypgdir)), %eax
8010002d:	b8 00 e0 10 00       	mov    $0x10e000,%eax
  movl    %eax, %cr3
80100032:	0f 22 d8             	mov    %eax,%cr3
  
  #Disable IA32e mode
  movl $0x0c0000080,%ecx
80100035:	b9 80 00 00 c0       	mov    $0xc0000080,%ecx
  rdmsr
8010003a:	0f 32                	rdmsr  
  andl $0xFFFFFEFF,%eax
8010003c:	25 ff fe ff ff       	and    $0xfffffeff,%eax
  wrmsr
80100041:	0f 30                	wrmsr  

  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
80100043:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
80100046:	83 c8 10             	or     $0x10,%eax
  andl    $0xFFFFFFDF, %eax
80100049:	83 e0 df             	and    $0xffffffdf,%eax
  movl    %eax, %cr4
8010004c:	0f 22 e0             	mov    %eax,%cr4

  #Turn on Paging
  movl    %cr0, %eax
8010004f:	0f 20 c0             	mov    %cr0,%eax
  orl     $0x80010001, %eax
80100052:	0d 01 00 01 80       	or     $0x80010001,%eax
  movl    %eax, %cr0
80100057:	0f 22 c0             	mov    %eax,%cr0




  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
8010005a:	bc 80 80 19 80       	mov    $0x80198080,%esp
  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
#  jz .waiting_main
  movl $main, %edx
8010005f:	ba 52 33 10 80       	mov    $0x80103352,%edx
  jmp %edx
80100064:	ff e2                	jmp    *%edx

80100066 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100066:	55                   	push   %ebp
80100067:	89 e5                	mov    %esp,%ebp
80100069:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010006c:	83 ec 08             	sub    $0x8,%esp
8010006f:	68 20 a3 10 80       	push   $0x8010a320
80100074:	68 00 d0 18 80       	push   $0x8018d000
80100079:	e8 fb 47 00 00       	call   80104879 <initlock>
8010007e:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100081:	c7 05 4c 17 19 80 fc 	movl   $0x801916fc,0x8019174c
80100088:	16 19 80 
  bcache.head.next = &bcache.head;
8010008b:	c7 05 50 17 19 80 fc 	movl   $0x801916fc,0x80191750
80100092:	16 19 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100095:	c7 45 f4 34 d0 18 80 	movl   $0x8018d034,-0xc(%ebp)
8010009c:	eb 47                	jmp    801000e5 <binit+0x7f>
    b->next = bcache.head.next;
8010009e:	8b 15 50 17 19 80    	mov    0x80191750,%edx
801000a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a7:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801000aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ad:	c7 40 50 fc 16 19 80 	movl   $0x801916fc,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
801000b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000b7:	83 c0 0c             	add    $0xc,%eax
801000ba:	83 ec 08             	sub    $0x8,%esp
801000bd:	68 27 a3 10 80       	push   $0x8010a327
801000c2:	50                   	push   %eax
801000c3:	e8 54 46 00 00       	call   8010471c <initsleeplock>
801000c8:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000cb:	a1 50 17 19 80       	mov    0x80191750,%eax
801000d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000d3:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d9:	a3 50 17 19 80       	mov    %eax,0x80191750
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000de:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000e5:	b8 fc 16 19 80       	mov    $0x801916fc,%eax
801000ea:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ed:	72 af                	jb     8010009e <binit+0x38>
  }
}
801000ef:	90                   	nop
801000f0:	90                   	nop
801000f1:	c9                   	leave  
801000f2:	c3                   	ret    

801000f3 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000f3:	55                   	push   %ebp
801000f4:	89 e5                	mov    %esp,%ebp
801000f6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000f9:	83 ec 0c             	sub    $0xc,%esp
801000fc:	68 00 d0 18 80       	push   $0x8018d000
80100101:	e8 95 47 00 00       	call   8010489b <acquire>
80100106:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100109:	a1 50 17 19 80       	mov    0x80191750,%eax
8010010e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100111:	eb 58                	jmp    8010016b <bget+0x78>
    if(b->dev == dev && b->blockno == blockno){
80100113:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100116:	8b 40 04             	mov    0x4(%eax),%eax
80100119:	39 45 08             	cmp    %eax,0x8(%ebp)
8010011c:	75 44                	jne    80100162 <bget+0x6f>
8010011e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100121:	8b 40 08             	mov    0x8(%eax),%eax
80100124:	39 45 0c             	cmp    %eax,0xc(%ebp)
80100127:	75 39                	jne    80100162 <bget+0x6f>
      b->refcnt++;
80100129:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010012c:	8b 40 4c             	mov    0x4c(%eax),%eax
8010012f:	8d 50 01             	lea    0x1(%eax),%edx
80100132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100135:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
80100138:	83 ec 0c             	sub    $0xc,%esp
8010013b:	68 00 d0 18 80       	push   $0x8018d000
80100140:	e8 c4 47 00 00       	call   80104909 <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 01 46 00 00       	call   80104758 <acquiresleep>
80100157:	83 c4 10             	add    $0x10,%esp
      return b;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	e9 9d 00 00 00       	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	8b 40 54             	mov    0x54(%eax),%eax
80100168:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010016b:	81 7d f4 fc 16 19 80 	cmpl   $0x801916fc,-0xc(%ebp)
80100172:	75 9f                	jne    80100113 <bget+0x20>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100174:	a1 4c 17 19 80       	mov    0x8019174c,%eax
80100179:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010017c:	eb 6b                	jmp    801001e9 <bget+0xf6>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010017e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100181:	8b 40 4c             	mov    0x4c(%eax),%eax
80100184:	85 c0                	test   %eax,%eax
80100186:	75 58                	jne    801001e0 <bget+0xed>
80100188:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010018b:	8b 00                	mov    (%eax),%eax
8010018d:	83 e0 04             	and    $0x4,%eax
80100190:	85 c0                	test   %eax,%eax
80100192:	75 4c                	jne    801001e0 <bget+0xed>
      b->dev = dev;
80100194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100197:	8b 55 08             	mov    0x8(%ebp),%edx
8010019a:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010019d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801001a3:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
801001a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
801001af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b2:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
801001b9:	83 ec 0c             	sub    $0xc,%esp
801001bc:	68 00 d0 18 80       	push   $0x8018d000
801001c1:	e8 43 47 00 00       	call   80104909 <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 80 45 00 00       	call   80104758 <acquiresleep>
801001d8:	83 c4 10             	add    $0x10,%esp
      return b;
801001db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001de:	eb 1f                	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001e3:	8b 40 50             	mov    0x50(%eax),%eax
801001e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001e9:	81 7d f4 fc 16 19 80 	cmpl   $0x801916fc,-0xc(%ebp)
801001f0:	75 8c                	jne    8010017e <bget+0x8b>
    }
  }
  panic("bget: no buffers");
801001f2:	83 ec 0c             	sub    $0xc,%esp
801001f5:	68 2e a3 10 80       	push   $0x8010a32e
801001fa:	e8 aa 03 00 00       	call   801005a9 <panic>
}
801001ff:	c9                   	leave  
80100200:	c3                   	ret    

80100201 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
80100201:	55                   	push   %ebp
80100202:	89 e5                	mov    %esp,%ebp
80100204:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100207:	83 ec 08             	sub    $0x8,%esp
8010020a:	ff 75 0c             	push   0xc(%ebp)
8010020d:	ff 75 08             	push   0x8(%ebp)
80100210:	e8 de fe ff ff       	call   801000f3 <bget>
80100215:	83 c4 10             	add    $0x10,%esp
80100218:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
8010021b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010021e:	8b 00                	mov    (%eax),%eax
80100220:	83 e0 02             	and    $0x2,%eax
80100223:	85 c0                	test   %eax,%eax
80100225:	75 0e                	jne    80100235 <bread+0x34>
    iderw(b);
80100227:	83 ec 0c             	sub    $0xc,%esp
8010022a:	ff 75 f4             	push   -0xc(%ebp)
8010022d:	e8 f3 9f 00 00       	call   8010a225 <iderw>
80100232:	83 c4 10             	add    $0x10,%esp
  }
  return b;
80100235:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100238:	c9                   	leave  
80100239:	c3                   	ret    

8010023a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
8010023a:	55                   	push   %ebp
8010023b:	89 e5                	mov    %esp,%ebp
8010023d:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100240:	8b 45 08             	mov    0x8(%ebp),%eax
80100243:	83 c0 0c             	add    $0xc,%eax
80100246:	83 ec 0c             	sub    $0xc,%esp
80100249:	50                   	push   %eax
8010024a:	e8 bb 45 00 00       	call   8010480a <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 3f a3 10 80       	push   $0x8010a33f
8010025e:	e8 46 03 00 00       	call   801005a9 <panic>
  b->flags |= B_DIRTY;
80100263:	8b 45 08             	mov    0x8(%ebp),%eax
80100266:	8b 00                	mov    (%eax),%eax
80100268:	83 c8 04             	or     $0x4,%eax
8010026b:	89 c2                	mov    %eax,%edx
8010026d:	8b 45 08             	mov    0x8(%ebp),%eax
80100270:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100272:	83 ec 0c             	sub    $0xc,%esp
80100275:	ff 75 08             	push   0x8(%ebp)
80100278:	e8 a8 9f 00 00       	call   8010a225 <iderw>
8010027d:	83 c4 10             	add    $0x10,%esp
}
80100280:	90                   	nop
80100281:	c9                   	leave  
80100282:	c3                   	ret    

80100283 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100283:	55                   	push   %ebp
80100284:	89 e5                	mov    %esp,%ebp
80100286:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100289:	8b 45 08             	mov    0x8(%ebp),%eax
8010028c:	83 c0 0c             	add    $0xc,%eax
8010028f:	83 ec 0c             	sub    $0xc,%esp
80100292:	50                   	push   %eax
80100293:	e8 72 45 00 00       	call   8010480a <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 46 a3 10 80       	push   $0x8010a346
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 01 45 00 00       	call   801047bc <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 d0 45 00 00       	call   8010489b <acquire>
801002cb:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
801002ce:	8b 45 08             	mov    0x8(%ebp),%eax
801002d1:	8b 40 4c             	mov    0x4c(%eax),%eax
801002d4:	8d 50 ff             	lea    -0x1(%eax),%edx
801002d7:	8b 45 08             	mov    0x8(%ebp),%eax
801002da:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002dd:	8b 45 08             	mov    0x8(%ebp),%eax
801002e0:	8b 40 4c             	mov    0x4c(%eax),%eax
801002e3:	85 c0                	test   %eax,%eax
801002e5:	75 47                	jne    8010032e <brelse+0xab>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002e7:	8b 45 08             	mov    0x8(%ebp),%eax
801002ea:	8b 40 54             	mov    0x54(%eax),%eax
801002ed:	8b 55 08             	mov    0x8(%ebp),%edx
801002f0:	8b 52 50             	mov    0x50(%edx),%edx
801002f3:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801002f6:	8b 45 08             	mov    0x8(%ebp),%eax
801002f9:	8b 40 50             	mov    0x50(%eax),%eax
801002fc:	8b 55 08             	mov    0x8(%ebp),%edx
801002ff:	8b 52 54             	mov    0x54(%edx),%edx
80100302:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100305:	8b 15 50 17 19 80    	mov    0x80191750,%edx
8010030b:	8b 45 08             	mov    0x8(%ebp),%eax
8010030e:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	c7 40 50 fc 16 19 80 	movl   $0x801916fc,0x50(%eax)
    bcache.head.next->prev = b;
8010031b:	a1 50 17 19 80       	mov    0x80191750,%eax
80100320:	8b 55 08             	mov    0x8(%ebp),%edx
80100323:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
80100326:	8b 45 08             	mov    0x8(%ebp),%eax
80100329:	a3 50 17 19 80       	mov    %eax,0x80191750
  }
  
  release(&bcache.lock);
8010032e:	83 ec 0c             	sub    $0xc,%esp
80100331:	68 00 d0 18 80       	push   $0x8018d000
80100336:	e8 ce 45 00 00       	call   80104909 <release>
8010033b:	83 c4 10             	add    $0x10,%esp
}
8010033e:	90                   	nop
8010033f:	c9                   	leave  
80100340:	c3                   	ret    

80100341 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100341:	55                   	push   %ebp
80100342:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100344:	fa                   	cli    
}
80100345:	90                   	nop
80100346:	5d                   	pop    %ebp
80100347:	c3                   	ret    

80100348 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100348:	55                   	push   %ebp
80100349:	89 e5                	mov    %esp,%ebp
8010034b:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010034e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100352:	74 1c                	je     80100370 <printint+0x28>
80100354:	8b 45 08             	mov    0x8(%ebp),%eax
80100357:	c1 e8 1f             	shr    $0x1f,%eax
8010035a:	0f b6 c0             	movzbl %al,%eax
8010035d:	89 45 10             	mov    %eax,0x10(%ebp)
80100360:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100364:	74 0a                	je     80100370 <printint+0x28>
    x = -xx;
80100366:	8b 45 08             	mov    0x8(%ebp),%eax
80100369:	f7 d8                	neg    %eax
8010036b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010036e:	eb 06                	jmp    80100376 <printint+0x2e>
  else
    x = xx;
80100370:	8b 45 08             	mov    0x8(%ebp),%eax
80100373:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100376:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010037d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100380:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100383:	ba 00 00 00 00       	mov    $0x0,%edx
80100388:	f7 f1                	div    %ecx
8010038a:	89 d1                	mov    %edx,%ecx
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	0f b6 91 04 d0 10 80 	movzbl -0x7fef2ffc(%ecx),%edx
8010039c:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003a6:	ba 00 00 00 00       	mov    $0x0,%edx
801003ab:	f7 f1                	div    %ecx
801003ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003b4:	75 c7                	jne    8010037d <printint+0x35>

  if(sign)
801003b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003ba:	74 2a                	je     801003e6 <printint+0x9e>
    buf[i++] = '-';
801003bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003bf:	8d 50 01             	lea    0x1(%eax),%edx
801003c2:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003c5:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003ca:	eb 1a                	jmp    801003e6 <printint+0x9e>
    consputc(buf[i]);
801003cc:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003d2:	01 d0                	add    %edx,%eax
801003d4:	0f b6 00             	movzbl (%eax),%eax
801003d7:	0f be c0             	movsbl %al,%eax
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	50                   	push   %eax
801003de:	e8 8c 03 00 00       	call   8010076f <consputc>
801003e3:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003e6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003ee:	79 dc                	jns    801003cc <printint+0x84>
}
801003f0:	90                   	nop
801003f1:	90                   	nop
801003f2:	c9                   	leave  
801003f3:	c3                   	ret    

801003f4 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003f4:	55                   	push   %ebp
801003f5:	89 e5                	mov    %esp,%ebp
801003f7:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003fa:	a1 34 1a 19 80       	mov    0x80191a34,%eax
801003ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
80100402:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100406:	74 10                	je     80100418 <cprintf+0x24>
    acquire(&cons.lock);
80100408:	83 ec 0c             	sub    $0xc,%esp
8010040b:	68 00 1a 19 80       	push   $0x80191a00
80100410:	e8 86 44 00 00       	call   8010489b <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 4d a3 10 80       	push   $0x8010a34d
80100427:	e8 7d 01 00 00       	call   801005a9 <panic>


  argp = (uint*)(void*)(&fmt + 1);
8010042c:	8d 45 0c             	lea    0xc(%ebp),%eax
8010042f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100432:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100439:	e9 2f 01 00 00       	jmp    8010056d <cprintf+0x179>
    if(c != '%'){
8010043e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100442:	74 13                	je     80100457 <cprintf+0x63>
      consputc(c);
80100444:	83 ec 0c             	sub    $0xc,%esp
80100447:	ff 75 e4             	push   -0x1c(%ebp)
8010044a:	e8 20 03 00 00       	call   8010076f <consputc>
8010044f:	83 c4 10             	add    $0x10,%esp
      continue;
80100452:	e9 12 01 00 00       	jmp    80100569 <cprintf+0x175>
    }
    c = fmt[++i] & 0xff;
80100457:	8b 55 08             	mov    0x8(%ebp),%edx
8010045a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010045e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100461:	01 d0                	add    %edx,%eax
80100463:	0f b6 00             	movzbl (%eax),%eax
80100466:	0f be c0             	movsbl %al,%eax
80100469:	25 ff 00 00 00       	and    $0xff,%eax
8010046e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100471:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100475:	0f 84 14 01 00 00    	je     8010058f <cprintf+0x19b>
      break;
    switch(c){
8010047b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
8010047f:	74 5e                	je     801004df <cprintf+0xeb>
80100481:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
80100485:	0f 8f c2 00 00 00    	jg     8010054d <cprintf+0x159>
8010048b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
8010048f:	74 6b                	je     801004fc <cprintf+0x108>
80100491:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
80100495:	0f 8f b2 00 00 00    	jg     8010054d <cprintf+0x159>
8010049b:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
8010049f:	74 3e                	je     801004df <cprintf+0xeb>
801004a1:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004a5:	0f 8f a2 00 00 00    	jg     8010054d <cprintf+0x159>
801004ab:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004af:	0f 84 89 00 00 00    	je     8010053e <cprintf+0x14a>
801004b5:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
801004b9:	0f 85 8e 00 00 00    	jne    8010054d <cprintf+0x159>
    case 'd':
      printint(*argp++, 10, 1);
801004bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004c2:	8d 50 04             	lea    0x4(%eax),%edx
801004c5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c8:	8b 00                	mov    (%eax),%eax
801004ca:	83 ec 04             	sub    $0x4,%esp
801004cd:	6a 01                	push   $0x1
801004cf:	6a 0a                	push   $0xa
801004d1:	50                   	push   %eax
801004d2:	e8 71 fe ff ff       	call   80100348 <printint>
801004d7:	83 c4 10             	add    $0x10,%esp
      break;
801004da:	e9 8a 00 00 00       	jmp    80100569 <cprintf+0x175>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004e2:	8d 50 04             	lea    0x4(%eax),%edx
801004e5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004e8:	8b 00                	mov    (%eax),%eax
801004ea:	83 ec 04             	sub    $0x4,%esp
801004ed:	6a 00                	push   $0x0
801004ef:	6a 10                	push   $0x10
801004f1:	50                   	push   %eax
801004f2:	e8 51 fe ff ff       	call   80100348 <printint>
801004f7:	83 c4 10             	add    $0x10,%esp
      break;
801004fa:	eb 6d                	jmp    80100569 <cprintf+0x175>
    case 's':
      if((s = (char*)*argp++) == 0)
801004fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004ff:	8d 50 04             	lea    0x4(%eax),%edx
80100502:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100505:	8b 00                	mov    (%eax),%eax
80100507:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010050a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010050e:	75 22                	jne    80100532 <cprintf+0x13e>
        s = "(null)";
80100510:	c7 45 ec 56 a3 10 80 	movl   $0x8010a356,-0x14(%ebp)
      for(; *s; s++)
80100517:	eb 19                	jmp    80100532 <cprintf+0x13e>
        consputc(*s);
80100519:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010051c:	0f b6 00             	movzbl (%eax),%eax
8010051f:	0f be c0             	movsbl %al,%eax
80100522:	83 ec 0c             	sub    $0xc,%esp
80100525:	50                   	push   %eax
80100526:	e8 44 02 00 00       	call   8010076f <consputc>
8010052b:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010052e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100532:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100535:	0f b6 00             	movzbl (%eax),%eax
80100538:	84 c0                	test   %al,%al
8010053a:	75 dd                	jne    80100519 <cprintf+0x125>
      break;
8010053c:	eb 2b                	jmp    80100569 <cprintf+0x175>
    case '%':
      consputc('%');
8010053e:	83 ec 0c             	sub    $0xc,%esp
80100541:	6a 25                	push   $0x25
80100543:	e8 27 02 00 00       	call   8010076f <consputc>
80100548:	83 c4 10             	add    $0x10,%esp
      break;
8010054b:	eb 1c                	jmp    80100569 <cprintf+0x175>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010054d:	83 ec 0c             	sub    $0xc,%esp
80100550:	6a 25                	push   $0x25
80100552:	e8 18 02 00 00       	call   8010076f <consputc>
80100557:	83 c4 10             	add    $0x10,%esp
      consputc(c);
8010055a:	83 ec 0c             	sub    $0xc,%esp
8010055d:	ff 75 e4             	push   -0x1c(%ebp)
80100560:	e8 0a 02 00 00       	call   8010076f <consputc>
80100565:	83 c4 10             	add    $0x10,%esp
      break;
80100568:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100569:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010056d:	8b 55 08             	mov    0x8(%ebp),%edx
80100570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100573:	01 d0                	add    %edx,%eax
80100575:	0f b6 00             	movzbl (%eax),%eax
80100578:	0f be c0             	movsbl %al,%eax
8010057b:	25 ff 00 00 00       	and    $0xff,%eax
80100580:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100583:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100587:	0f 85 b1 fe ff ff    	jne    8010043e <cprintf+0x4a>
8010058d:	eb 01                	jmp    80100590 <cprintf+0x19c>
      break;
8010058f:	90                   	nop
    }
  }

  if(locking)
80100590:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100594:	74 10                	je     801005a6 <cprintf+0x1b2>
    release(&cons.lock);
80100596:	83 ec 0c             	sub    $0xc,%esp
80100599:	68 00 1a 19 80       	push   $0x80191a00
8010059e:	e8 66 43 00 00       	call   80104909 <release>
801005a3:	83 c4 10             	add    $0x10,%esp
}
801005a6:	90                   	nop
801005a7:	c9                   	leave  
801005a8:	c3                   	ret    

801005a9 <panic>:

void
panic(char *s)
{
801005a9:	55                   	push   %ebp
801005aa:	89 e5                	mov    %esp,%ebp
801005ac:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
801005af:	e8 8d fd ff ff       	call   80100341 <cli>
  cons.locking = 0;
801005b4:	c7 05 34 1a 19 80 00 	movl   $0x0,0x80191a34
801005bb:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005be:	e8 24 25 00 00       	call   80102ae7 <lapicid>
801005c3:	83 ec 08             	sub    $0x8,%esp
801005c6:	50                   	push   %eax
801005c7:	68 5d a3 10 80       	push   $0x8010a35d
801005cc:	e8 23 fe ff ff       	call   801003f4 <cprintf>
801005d1:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005d4:	8b 45 08             	mov    0x8(%ebp),%eax
801005d7:	83 ec 0c             	sub    $0xc,%esp
801005da:	50                   	push   %eax
801005db:	e8 14 fe ff ff       	call   801003f4 <cprintf>
801005e0:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005e3:	83 ec 0c             	sub    $0xc,%esp
801005e6:	68 71 a3 10 80       	push   $0x8010a371
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 58 43 00 00       	call   8010495b <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 73 a3 10 80       	push   $0x8010a373
8010061f:	e8 d0 fd ff ff       	call   801003f4 <cprintf>
80100624:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100627:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010062b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010062f:	7e de                	jle    8010060f <panic+0x66>
  panicked = 1; // freeze other CPU
80100631:	c7 05 ec 19 19 80 01 	movl   $0x1,0x801919ec
80100638:	00 00 00 
  for(;;)
8010063b:	eb fe                	jmp    8010063b <panic+0x92>

8010063d <graphic_putc>:

#define CONSOLE_HORIZONTAL_MAX 53
#define CONSOLE_VERTICAL_MAX 20
int console_pos = CONSOLE_HORIZONTAL_MAX*(CONSOLE_VERTICAL_MAX);
//int console_pos = 0;
void graphic_putc(int c){
8010063d:	55                   	push   %ebp
8010063e:	89 e5                	mov    %esp,%ebp
80100640:	83 ec 18             	sub    $0x18,%esp
  if(c == '\n'){
80100643:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100647:	75 64                	jne    801006ad <graphic_putc+0x70>
    console_pos += CONSOLE_HORIZONTAL_MAX - console_pos%CONSOLE_HORIZONTAL_MAX;
80100649:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
8010064f:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100654:	89 c8                	mov    %ecx,%eax
80100656:	f7 ea                	imul   %edx
80100658:	89 d0                	mov    %edx,%eax
8010065a:	c1 f8 04             	sar    $0x4,%eax
8010065d:	89 ca                	mov    %ecx,%edx
8010065f:	c1 fa 1f             	sar    $0x1f,%edx
80100662:	29 d0                	sub    %edx,%eax
80100664:	6b d0 35             	imul   $0x35,%eax,%edx
80100667:	89 c8                	mov    %ecx,%eax
80100669:	29 d0                	sub    %edx,%eax
8010066b:	ba 35 00 00 00       	mov    $0x35,%edx
80100670:	29 c2                	sub    %eax,%edx
80100672:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100677:	01 d0                	add    %edx,%eax
80100679:	a3 00 d0 10 80       	mov    %eax,0x8010d000
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
8010067e:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100683:	3d 23 04 00 00       	cmp    $0x423,%eax
80100688:	0f 8e de 00 00 00    	jle    8010076c <graphic_putc+0x12f>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
8010068e:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100693:	83 e8 35             	sub    $0x35,%eax
80100696:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
8010069b:	83 ec 0c             	sub    $0xc,%esp
8010069e:	6a 1e                	push   $0x1e
801006a0:	e8 d7 7a 00 00       	call   8010817c <graphic_scroll_up>
801006a5:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
    font_render(x,y,c);
    console_pos++;
  }
}
801006a8:	e9 bf 00 00 00       	jmp    8010076c <graphic_putc+0x12f>
  }else if(c == BACKSPACE){
801006ad:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006b4:	75 1f                	jne    801006d5 <graphic_putc+0x98>
    if(console_pos>0) --console_pos;
801006b6:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006bb:	85 c0                	test   %eax,%eax
801006bd:	0f 8e a9 00 00 00    	jle    8010076c <graphic_putc+0x12f>
801006c3:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006c8:	83 e8 01             	sub    $0x1,%eax
801006cb:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
801006d0:	e9 97 00 00 00       	jmp    8010076c <graphic_putc+0x12f>
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
801006d5:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006da:	3d 23 04 00 00       	cmp    $0x423,%eax
801006df:	7e 1a                	jle    801006fb <graphic_putc+0xbe>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
801006e1:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006e6:	83 e8 35             	sub    $0x35,%eax
801006e9:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
801006ee:	83 ec 0c             	sub    $0xc,%esp
801006f1:	6a 1e                	push   $0x1e
801006f3:	e8 84 7a 00 00       	call   8010817c <graphic_scroll_up>
801006f8:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
801006fb:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100701:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100706:	89 c8                	mov    %ecx,%eax
80100708:	f7 ea                	imul   %edx
8010070a:	89 d0                	mov    %edx,%eax
8010070c:	c1 f8 04             	sar    $0x4,%eax
8010070f:	89 ca                	mov    %ecx,%edx
80100711:	c1 fa 1f             	sar    $0x1f,%edx
80100714:	29 d0                	sub    %edx,%eax
80100716:	6b d0 35             	imul   $0x35,%eax,%edx
80100719:	89 c8                	mov    %ecx,%eax
8010071b:	29 d0                	sub    %edx,%eax
8010071d:	89 c2                	mov    %eax,%edx
8010071f:	c1 e2 04             	shl    $0x4,%edx
80100722:	29 c2                	sub    %eax,%edx
80100724:	8d 42 02             	lea    0x2(%edx),%eax
80100727:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
8010072a:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100730:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100735:	89 c8                	mov    %ecx,%eax
80100737:	f7 ea                	imul   %edx
80100739:	89 d0                	mov    %edx,%eax
8010073b:	c1 f8 04             	sar    $0x4,%eax
8010073e:	c1 f9 1f             	sar    $0x1f,%ecx
80100741:	89 ca                	mov    %ecx,%edx
80100743:	29 d0                	sub    %edx,%eax
80100745:	6b c0 1e             	imul   $0x1e,%eax,%eax
80100748:	89 45 f0             	mov    %eax,-0x10(%ebp)
    font_render(x,y,c);
8010074b:	83 ec 04             	sub    $0x4,%esp
8010074e:	ff 75 08             	push   0x8(%ebp)
80100751:	ff 75 f0             	push   -0x10(%ebp)
80100754:	ff 75 f4             	push   -0xc(%ebp)
80100757:	e8 8b 7a 00 00       	call   801081e7 <font_render>
8010075c:	83 c4 10             	add    $0x10,%esp
    console_pos++;
8010075f:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100764:	83 c0 01             	add    $0x1,%eax
80100767:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
8010076c:	90                   	nop
8010076d:	c9                   	leave  
8010076e:	c3                   	ret    

8010076f <consputc>:


void
consputc(int c)
{
8010076f:	55                   	push   %ebp
80100770:	89 e5                	mov    %esp,%ebp
80100772:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100775:	a1 ec 19 19 80       	mov    0x801919ec,%eax
8010077a:	85 c0                	test   %eax,%eax
8010077c:	74 07                	je     80100785 <consputc+0x16>
    cli();
8010077e:	e8 be fb ff ff       	call   80100341 <cli>
    for(;;)
80100783:	eb fe                	jmp    80100783 <consputc+0x14>
      ;
  }

  if(c == BACKSPACE){
80100785:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010078c:	75 29                	jne    801007b7 <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010078e:	83 ec 0c             	sub    $0xc,%esp
80100791:	6a 08                	push   $0x8
80100793:	e8 70 5d 00 00       	call   80106508 <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 63 5d 00 00       	call   80106508 <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 56 5d 00 00       	call   80106508 <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x56>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 46 5d 00 00       	call   80106508 <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
  }
  graphic_putc(c);
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	ff 75 08             	push   0x8(%ebp)
801007cb:	e8 6d fe ff ff       	call   8010063d <graphic_putc>
801007d0:	83 c4 10             	add    $0x10,%esp
}
801007d3:	90                   	nop
801007d4:	c9                   	leave  
801007d5:	c3                   	ret    

801007d6 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007d6:	55                   	push   %ebp
801007d7:	89 e5                	mov    %esp,%ebp
801007d9:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801007dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801007e3:	83 ec 0c             	sub    $0xc,%esp
801007e6:	68 00 1a 19 80       	push   $0x80191a00
801007eb:	e8 ab 40 00 00       	call   8010489b <acquire>
801007f0:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801007f3:	e9 50 01 00 00       	jmp    80100948 <consoleintr+0x172>
    switch(c){
801007f8:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801007fc:	0f 84 81 00 00 00    	je     80100883 <consoleintr+0xad>
80100802:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100806:	0f 8f ac 00 00 00    	jg     801008b8 <consoleintr+0xe2>
8010080c:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100810:	74 43                	je     80100855 <consoleintr+0x7f>
80100812:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100816:	0f 8f 9c 00 00 00    	jg     801008b8 <consoleintr+0xe2>
8010081c:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
80100820:	74 61                	je     80100883 <consoleintr+0xad>
80100822:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
80100826:	0f 85 8c 00 00 00    	jne    801008b8 <consoleintr+0xe2>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
8010082c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100833:	e9 10 01 00 00       	jmp    80100948 <consoleintr+0x172>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100838:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010083d:	83 e8 01             	sub    $0x1,%eax
80100840:	a3 e8 19 19 80       	mov    %eax,0x801919e8
        consputc(BACKSPACE);
80100845:	83 ec 0c             	sub    $0xc,%esp
80100848:	68 00 01 00 00       	push   $0x100
8010084d:	e8 1d ff ff ff       	call   8010076f <consputc>
80100852:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100855:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
8010085b:	a1 e4 19 19 80       	mov    0x801919e4,%eax
80100860:	39 c2                	cmp    %eax,%edx
80100862:	0f 84 e0 00 00 00    	je     80100948 <consoleintr+0x172>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100868:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010086d:	83 e8 01             	sub    $0x1,%eax
80100870:	83 e0 7f             	and    $0x7f,%eax
80100873:	0f b6 80 60 19 19 80 	movzbl -0x7fe6e6a0(%eax),%eax
      while(input.e != input.w &&
8010087a:	3c 0a                	cmp    $0xa,%al
8010087c:	75 ba                	jne    80100838 <consoleintr+0x62>
      }
      break;
8010087e:	e9 c5 00 00 00       	jmp    80100948 <consoleintr+0x172>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100883:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
80100889:	a1 e4 19 19 80       	mov    0x801919e4,%eax
8010088e:	39 c2                	cmp    %eax,%edx
80100890:	0f 84 b2 00 00 00    	je     80100948 <consoleintr+0x172>
        input.e--;
80100896:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010089b:	83 e8 01             	sub    $0x1,%eax
8010089e:	a3 e8 19 19 80       	mov    %eax,0x801919e8
        consputc(BACKSPACE);
801008a3:	83 ec 0c             	sub    $0xc,%esp
801008a6:	68 00 01 00 00       	push   $0x100
801008ab:	e8 bf fe ff ff       	call   8010076f <consputc>
801008b0:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008b3:	e9 90 00 00 00       	jmp    80100948 <consoleintr+0x172>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008bc:	0f 84 85 00 00 00    	je     80100947 <consoleintr+0x171>
801008c2:	a1 e8 19 19 80       	mov    0x801919e8,%eax
801008c7:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
801008cd:	29 d0                	sub    %edx,%eax
801008cf:	83 f8 7f             	cmp    $0x7f,%eax
801008d2:	77 73                	ja     80100947 <consoleintr+0x171>
        c = (c == '\r') ? '\n' : c;
801008d4:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008d8:	74 05                	je     801008df <consoleintr+0x109>
801008da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008dd:	eb 05                	jmp    801008e4 <consoleintr+0x10e>
801008df:	b8 0a 00 00 00       	mov    $0xa,%eax
801008e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008e7:	a1 e8 19 19 80       	mov    0x801919e8,%eax
801008ec:	8d 50 01             	lea    0x1(%eax),%edx
801008ef:	89 15 e8 19 19 80    	mov    %edx,0x801919e8
801008f5:	83 e0 7f             	and    $0x7f,%eax
801008f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801008fb:	88 90 60 19 19 80    	mov    %dl,-0x7fe6e6a0(%eax)
        consputc(c);
80100901:	83 ec 0c             	sub    $0xc,%esp
80100904:	ff 75 f0             	push   -0x10(%ebp)
80100907:	e8 63 fe ff ff       	call   8010076f <consputc>
8010090c:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
8010090f:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100913:	74 18                	je     8010092d <consoleintr+0x157>
80100915:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100919:	74 12                	je     8010092d <consoleintr+0x157>
8010091b:	a1 e8 19 19 80       	mov    0x801919e8,%eax
80100920:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
80100926:	83 ea 80             	sub    $0xffffff80,%edx
80100929:	39 d0                	cmp    %edx,%eax
8010092b:	75 1a                	jne    80100947 <consoleintr+0x171>
          input.w = input.e;
8010092d:	a1 e8 19 19 80       	mov    0x801919e8,%eax
80100932:	a3 e4 19 19 80       	mov    %eax,0x801919e4
          wakeup(&input.r);
80100937:	83 ec 0c             	sub    $0xc,%esp
8010093a:	68 e0 19 19 80       	push   $0x801919e0
8010093f:	e8 75 3a 00 00       	call   801043b9 <wakeup>
80100944:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100947:	90                   	nop
  while((c = getc()) >= 0){
80100948:	8b 45 08             	mov    0x8(%ebp),%eax
8010094b:	ff d0                	call   *%eax
8010094d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100950:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100954:	0f 89 9e fe ff ff    	jns    801007f8 <consoleintr+0x22>
    }
  }
  release(&cons.lock);
8010095a:	83 ec 0c             	sub    $0xc,%esp
8010095d:	68 00 1a 19 80       	push   $0x80191a00
80100962:	e8 a2 3f 00 00       	call   80104909 <release>
80100967:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010096a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010096e:	74 05                	je     80100975 <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
80100970:	e8 ff 3a 00 00       	call   80104474 <procdump>
  }
}
80100975:	90                   	nop
80100976:	c9                   	leave  
80100977:	c3                   	ret    

80100978 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100978:	55                   	push   %ebp
80100979:	89 e5                	mov    %esp,%ebp
8010097b:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
8010097e:	83 ec 0c             	sub    $0xc,%esp
80100981:	ff 75 08             	push   0x8(%ebp)
80100984:	e8 61 11 00 00       	call   80101aea <iunlock>
80100989:	83 c4 10             	add    $0x10,%esp
  target = n;
8010098c:	8b 45 10             	mov    0x10(%ebp),%eax
8010098f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100992:	83 ec 0c             	sub    $0xc,%esp
80100995:	68 00 1a 19 80       	push   $0x80191a00
8010099a:	e8 fc 3e 00 00       	call   8010489b <acquire>
8010099f:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009a2:	e9 ab 00 00 00       	jmp    80100a52 <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009a7:	e8 7d 30 00 00       	call   80103a29 <myproc>
801009ac:	8b 40 24             	mov    0x24(%eax),%eax
801009af:	85 c0                	test   %eax,%eax
801009b1:	74 28                	je     801009db <consoleread+0x63>
        release(&cons.lock);
801009b3:	83 ec 0c             	sub    $0xc,%esp
801009b6:	68 00 1a 19 80       	push   $0x80191a00
801009bb:	e8 49 3f 00 00       	call   80104909 <release>
801009c0:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009c3:	83 ec 0c             	sub    $0xc,%esp
801009c6:	ff 75 08             	push   0x8(%ebp)
801009c9:	e8 09 10 00 00       	call   801019d7 <ilock>
801009ce:	83 c4 10             	add    $0x10,%esp
        return -1;
801009d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009d6:	e9 a9 00 00 00       	jmp    80100a84 <consoleread+0x10c>
      }
      sleep(&input.r, &cons.lock);
801009db:	83 ec 08             	sub    $0x8,%esp
801009de:	68 00 1a 19 80       	push   $0x80191a00
801009e3:	68 e0 19 19 80       	push   $0x801919e0
801009e8:	e8 e5 38 00 00       	call   801042d2 <sleep>
801009ed:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
801009f0:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
801009f6:	a1 e4 19 19 80       	mov    0x801919e4,%eax
801009fb:	39 c2                	cmp    %eax,%edx
801009fd:	74 a8                	je     801009a7 <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009ff:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100a04:	8d 50 01             	lea    0x1(%eax),%edx
80100a07:	89 15 e0 19 19 80    	mov    %edx,0x801919e0
80100a0d:	83 e0 7f             	and    $0x7f,%eax
80100a10:	0f b6 80 60 19 19 80 	movzbl -0x7fe6e6a0(%eax),%eax
80100a17:	0f be c0             	movsbl %al,%eax
80100a1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a1d:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a21:	75 17                	jne    80100a3a <consoleread+0xc2>
      if(n < target){
80100a23:	8b 45 10             	mov    0x10(%ebp),%eax
80100a26:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100a29:	76 2f                	jbe    80100a5a <consoleread+0xe2>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a2b:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100a30:	83 e8 01             	sub    $0x1,%eax
80100a33:	a3 e0 19 19 80       	mov    %eax,0x801919e0
      }
      break;
80100a38:	eb 20                	jmp    80100a5a <consoleread+0xe2>
    }
    *dst++ = c;
80100a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a3d:	8d 50 01             	lea    0x1(%eax),%edx
80100a40:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a43:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a46:	88 10                	mov    %dl,(%eax)
    --n;
80100a48:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a4c:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a50:	74 0b                	je     80100a5d <consoleread+0xe5>
  while(n > 0){
80100a52:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a56:	7f 98                	jg     801009f0 <consoleread+0x78>
80100a58:	eb 04                	jmp    80100a5e <consoleread+0xe6>
      break;
80100a5a:	90                   	nop
80100a5b:	eb 01                	jmp    80100a5e <consoleread+0xe6>
      break;
80100a5d:	90                   	nop
  }
  release(&cons.lock);
80100a5e:	83 ec 0c             	sub    $0xc,%esp
80100a61:	68 00 1a 19 80       	push   $0x80191a00
80100a66:	e8 9e 3e 00 00       	call   80104909 <release>
80100a6b:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a6e:	83 ec 0c             	sub    $0xc,%esp
80100a71:	ff 75 08             	push   0x8(%ebp)
80100a74:	e8 5e 0f 00 00       	call   801019d7 <ilock>
80100a79:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a7c:	8b 55 10             	mov    0x10(%ebp),%edx
80100a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a82:	29 d0                	sub    %edx,%eax
}
80100a84:	c9                   	leave  
80100a85:	c3                   	ret    

80100a86 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a86:	55                   	push   %ebp
80100a87:	89 e5                	mov    %esp,%ebp
80100a89:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100a8c:	83 ec 0c             	sub    $0xc,%esp
80100a8f:	ff 75 08             	push   0x8(%ebp)
80100a92:	e8 53 10 00 00       	call   80101aea <iunlock>
80100a97:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100a9a:	83 ec 0c             	sub    $0xc,%esp
80100a9d:	68 00 1a 19 80       	push   $0x80191a00
80100aa2:	e8 f4 3d 00 00       	call   8010489b <acquire>
80100aa7:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100aaa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100ab1:	eb 21                	jmp    80100ad4 <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100ab3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ab6:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ab9:	01 d0                	add    %edx,%eax
80100abb:	0f b6 00             	movzbl (%eax),%eax
80100abe:	0f be c0             	movsbl %al,%eax
80100ac1:	0f b6 c0             	movzbl %al,%eax
80100ac4:	83 ec 0c             	sub    $0xc,%esp
80100ac7:	50                   	push   %eax
80100ac8:	e8 a2 fc ff ff       	call   8010076f <consputc>
80100acd:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ad0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ad7:	3b 45 10             	cmp    0x10(%ebp),%eax
80100ada:	7c d7                	jl     80100ab3 <consolewrite+0x2d>
  release(&cons.lock);
80100adc:	83 ec 0c             	sub    $0xc,%esp
80100adf:	68 00 1a 19 80       	push   $0x80191a00
80100ae4:	e8 20 3e 00 00       	call   80104909 <release>
80100ae9:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100aec:	83 ec 0c             	sub    $0xc,%esp
80100aef:	ff 75 08             	push   0x8(%ebp)
80100af2:	e8 e0 0e 00 00       	call   801019d7 <ilock>
80100af7:	83 c4 10             	add    $0x10,%esp

  return n;
80100afa:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100afd:	c9                   	leave  
80100afe:	c3                   	ret    

80100aff <consoleinit>:

void
consoleinit(void)
{
80100aff:	55                   	push   %ebp
80100b00:	89 e5                	mov    %esp,%ebp
80100b02:	83 ec 18             	sub    $0x18,%esp
  panicked = 0;
80100b05:	c7 05 ec 19 19 80 00 	movl   $0x0,0x801919ec
80100b0c:	00 00 00 
  initlock(&cons.lock, "console");
80100b0f:	83 ec 08             	sub    $0x8,%esp
80100b12:	68 77 a3 10 80       	push   $0x8010a377
80100b17:	68 00 1a 19 80       	push   $0x80191a00
80100b1c:	e8 58 3d 00 00       	call   80104879 <initlock>
80100b21:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b24:	c7 05 4c 1a 19 80 86 	movl   $0x80100a86,0x80191a4c
80100b2b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b2e:	c7 05 48 1a 19 80 78 	movl   $0x80100978,0x80191a48
80100b35:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b38:	c7 45 f4 7f a3 10 80 	movl   $0x8010a37f,-0xc(%ebp)
80100b3f:	eb 19                	jmp    80100b5a <consoleinit+0x5b>
    graphic_putc(*p);
80100b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b44:	0f b6 00             	movzbl (%eax),%eax
80100b47:	0f be c0             	movsbl %al,%eax
80100b4a:	83 ec 0c             	sub    $0xc,%esp
80100b4d:	50                   	push   %eax
80100b4e:	e8 ea fa ff ff       	call   8010063d <graphic_putc>
80100b53:	83 c4 10             	add    $0x10,%esp
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b56:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b5d:	0f b6 00             	movzbl (%eax),%eax
80100b60:	84 c0                	test   %al,%al
80100b62:	75 dd                	jne    80100b41 <consoleinit+0x42>
  
  cons.locking = 1;
80100b64:	c7 05 34 1a 19 80 01 	movl   $0x1,0x80191a34
80100b6b:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100b6e:	83 ec 08             	sub    $0x8,%esp
80100b71:	6a 00                	push   $0x0
80100b73:	6a 01                	push   $0x1
80100b75:	e8 a1 1a 00 00       	call   8010261b <ioapicenable>
80100b7a:	83 c4 10             	add    $0x10,%esp
}
80100b7d:	90                   	nop
80100b7e:	c9                   	leave  
80100b7f:	c3                   	ret    

80100b80 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b80:	55                   	push   %ebp
80100b81:	89 e5                	mov    %esp,%ebp
80100b83:	81 ec 18 01 00 00    	sub    $0x118,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100b89:	e8 9b 2e 00 00       	call   80103a29 <myproc>
80100b8e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100b91:	e8 93 24 00 00       	call   80103029 <begin_op>

  if((ip = namei(path)) == 0){
80100b96:	83 ec 0c             	sub    $0xc,%esp
80100b99:	ff 75 08             	push   0x8(%ebp)
80100b9c:	e8 69 19 00 00       	call   8010250a <namei>
80100ba1:	83 c4 10             	add    $0x10,%esp
80100ba4:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100ba7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bab:	75 1f                	jne    80100bcc <exec+0x4c>
    end_op();
80100bad:	e8 03 25 00 00       	call   801030b5 <end_op>
    cprintf("exec: fail\n");
80100bb2:	83 ec 0c             	sub    $0xc,%esp
80100bb5:	68 95 a3 10 80       	push   $0x8010a395
80100bba:	e8 35 f8 ff ff       	call   801003f4 <cprintf>
80100bbf:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bc7:	e9 de 03 00 00       	jmp    80100faa <exec+0x42a>
  }
  ilock(ip);
80100bcc:	83 ec 0c             	sub    $0xc,%esp
80100bcf:	ff 75 d8             	push   -0x28(%ebp)
80100bd2:	e8 00 0e 00 00       	call   801019d7 <ilock>
80100bd7:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100bda:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100be1:	6a 34                	push   $0x34
80100be3:	6a 00                	push   $0x0
80100be5:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100beb:	50                   	push   %eax
80100bec:	ff 75 d8             	push   -0x28(%ebp)
80100bef:	e8 cf 12 00 00       	call   80101ec3 <readi>
80100bf4:	83 c4 10             	add    $0x10,%esp
80100bf7:	83 f8 34             	cmp    $0x34,%eax
80100bfa:	0f 85 53 03 00 00    	jne    80100f53 <exec+0x3d3>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c00:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c06:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c0b:	0f 85 45 03 00 00    	jne    80100f56 <exec+0x3d6>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c11:	e8 ee 68 00 00       	call   80107504 <setupkvm>
80100c16:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c19:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c1d:	0f 84 36 03 00 00    	je     80100f59 <exec+0x3d9>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c23:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c2a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c31:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100c37:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c3a:	e9 de 00 00 00       	jmp    80100d1d <exec+0x19d>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c3f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c42:	6a 20                	push   $0x20
80100c44:	50                   	push   %eax
80100c45:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100c4b:	50                   	push   %eax
80100c4c:	ff 75 d8             	push   -0x28(%ebp)
80100c4f:	e8 6f 12 00 00       	call   80101ec3 <readi>
80100c54:	83 c4 10             	add    $0x10,%esp
80100c57:	83 f8 20             	cmp    $0x20,%eax
80100c5a:	0f 85 fc 02 00 00    	jne    80100f5c <exec+0x3dc>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c60:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100c66:	83 f8 01             	cmp    $0x1,%eax
80100c69:	0f 85 a0 00 00 00    	jne    80100d0f <exec+0x18f>
      continue;
    if(ph.memsz < ph.filesz)
80100c6f:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c75:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100c7b:	39 c2                	cmp    %eax,%edx
80100c7d:	0f 82 dc 02 00 00    	jb     80100f5f <exec+0x3df>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c83:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c89:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c8f:	01 c2                	add    %eax,%edx
80100c91:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c97:	39 c2                	cmp    %eax,%edx
80100c99:	0f 82 c3 02 00 00    	jb     80100f62 <exec+0x3e2>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c9f:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ca5:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cab:	01 d0                	add    %edx,%eax
80100cad:	83 ec 04             	sub    $0x4,%esp
80100cb0:	50                   	push   %eax
80100cb1:	ff 75 e0             	push   -0x20(%ebp)
80100cb4:	ff 75 d4             	push   -0x2c(%ebp)
80100cb7:	e8 41 6c 00 00       	call   801078fd <allocuvm>
80100cbc:	83 c4 10             	add    $0x10,%esp
80100cbf:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cc2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cc6:	0f 84 99 02 00 00    	je     80100f65 <exec+0x3e5>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100ccc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cd2:	25 ff 0f 00 00       	and    $0xfff,%eax
80100cd7:	85 c0                	test   %eax,%eax
80100cd9:	0f 85 89 02 00 00    	jne    80100f68 <exec+0x3e8>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100cdf:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100ce5:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100ceb:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100cf1:	83 ec 0c             	sub    $0xc,%esp
80100cf4:	52                   	push   %edx
80100cf5:	50                   	push   %eax
80100cf6:	ff 75 d8             	push   -0x28(%ebp)
80100cf9:	51                   	push   %ecx
80100cfa:	ff 75 d4             	push   -0x2c(%ebp)
80100cfd:	e8 2e 6b 00 00       	call   80107830 <loaduvm>
80100d02:	83 c4 20             	add    $0x20,%esp
80100d05:	85 c0                	test   %eax,%eax
80100d07:	0f 88 5e 02 00 00    	js     80100f6b <exec+0x3eb>
80100d0d:	eb 01                	jmp    80100d10 <exec+0x190>
      continue;
80100d0f:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d10:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d14:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d17:	83 c0 20             	add    $0x20,%eax
80100d1a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d1d:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100d24:	0f b7 c0             	movzwl %ax,%eax
80100d27:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d2a:	0f 8c 0f ff ff ff    	jl     80100c3f <exec+0xbf>
      goto bad;
  }
  iunlockput(ip);
80100d30:	83 ec 0c             	sub    $0xc,%esp
80100d33:	ff 75 d8             	push   -0x28(%ebp)
80100d36:	e8 cd 0e 00 00       	call   80101c08 <iunlockput>
80100d3b:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d3e:	e8 72 23 00 00       	call   801030b5 <end_op>
  ip = 0;
80100d43:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  sz = PGROUNDUP(sz);
80100d4a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d4d:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d52:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d57:	89 45 e0             	mov    %eax,-0x20(%ebp)
  sp = KERNBASE - 4;
80100d5a:	c7 45 dc fc ff ff 7f 	movl   $0x7ffffffc,-0x24(%ebp)
  curproc->stack_size = PGSIZE;
80100d61:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100d64:	c7 40 7c 00 10 00 00 	movl   $0x1000,0x7c(%eax)

  if((allocuvm(pgdir, KERNBASE - PGSIZE, KERNBASE-1)) == 0)
80100d6b:	83 ec 04             	sub    $0x4,%esp
80100d6e:	68 ff ff ff 7f       	push   $0x7fffffff
80100d73:	68 00 f0 ff 7f       	push   $0x7ffff000
80100d78:	ff 75 d4             	push   -0x2c(%ebp)
80100d7b:	e8 7d 6b 00 00       	call   801078fd <allocuvm>
80100d80:	83 c4 10             	add    $0x10,%esp
80100d83:	85 c0                	test   %eax,%eax
80100d85:	0f 84 e3 01 00 00    	je     80100f6e <exec+0x3ee>
    goto bad;


  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d8b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d92:	e9 96 00 00 00       	jmp    80100e2d <exec+0x2ad>
    if(argc >= MAXARG)
80100d97:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d9b:	0f 87 d0 01 00 00    	ja     80100f71 <exec+0x3f1>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100da1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100da4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dab:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dae:	01 d0                	add    %edx,%eax
80100db0:	8b 00                	mov    (%eax),%eax
80100db2:	83 ec 0c             	sub    $0xc,%esp
80100db5:	50                   	push   %eax
80100db6:	e8 a4 3f 00 00       	call   80104d5f <strlen>
80100dbb:	83 c4 10             	add    $0x10,%esp
80100dbe:	89 c2                	mov    %eax,%edx
80100dc0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dc3:	29 d0                	sub    %edx,%eax
80100dc5:	83 e8 01             	sub    $0x1,%eax
80100dc8:	83 e0 fc             	and    $0xfffffffc,%eax
80100dcb:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100dce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dd1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dd8:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ddb:	01 d0                	add    %edx,%eax
80100ddd:	8b 00                	mov    (%eax),%eax
80100ddf:	83 ec 0c             	sub    $0xc,%esp
80100de2:	50                   	push   %eax
80100de3:	e8 77 3f 00 00       	call   80104d5f <strlen>
80100de8:	83 c4 10             	add    $0x10,%esp
80100deb:	83 c0 01             	add    $0x1,%eax
80100dee:	89 c2                	mov    %eax,%edx
80100df0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100df3:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100dfa:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dfd:	01 c8                	add    %ecx,%eax
80100dff:	8b 00                	mov    (%eax),%eax
80100e01:	52                   	push   %edx
80100e02:	50                   	push   %eax
80100e03:	ff 75 dc             	push   -0x24(%ebp)
80100e06:	ff 75 d4             	push   -0x2c(%ebp)
80100e09:	e8 db 6f 00 00       	call   80107de9 <copyout>
80100e0e:	83 c4 10             	add    $0x10,%esp
80100e11:	85 c0                	test   %eax,%eax
80100e13:	0f 88 5b 01 00 00    	js     80100f74 <exec+0x3f4>
      goto bad;
    ustack[3+argc] = sp;
80100e19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e1c:	8d 50 03             	lea    0x3(%eax),%edx
80100e1f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e22:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e29:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e2d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e30:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e37:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e3a:	01 d0                	add    %edx,%eax
80100e3c:	8b 00                	mov    (%eax),%eax
80100e3e:	85 c0                	test   %eax,%eax
80100e40:	0f 85 51 ff ff ff    	jne    80100d97 <exec+0x217>
  }
  ustack[3+argc] = 0;
80100e46:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e49:	83 c0 03             	add    $0x3,%eax
80100e4c:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100e53:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e57:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100e5e:	ff ff ff 
  ustack[1] = argc;
80100e61:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e64:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e6a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e6d:	83 c0 01             	add    $0x1,%eax
80100e70:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e77:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e7a:	29 d0                	sub    %edx,%eax
80100e7c:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100e82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e85:	83 c0 04             	add    $0x4,%eax
80100e88:	c1 e0 02             	shl    $0x2,%eax
80100e8b:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e91:	83 c0 04             	add    $0x4,%eax
80100e94:	c1 e0 02             	shl    $0x2,%eax
80100e97:	50                   	push   %eax
80100e98:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100e9e:	50                   	push   %eax
80100e9f:	ff 75 dc             	push   -0x24(%ebp)
80100ea2:	ff 75 d4             	push   -0x2c(%ebp)
80100ea5:	e8 3f 6f 00 00       	call   80107de9 <copyout>
80100eaa:	83 c4 10             	add    $0x10,%esp
80100ead:	85 c0                	test   %eax,%eax
80100eaf:	0f 88 c2 00 00 00    	js     80100f77 <exec+0x3f7>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100eb5:	8b 45 08             	mov    0x8(%ebp),%eax
80100eb8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ebe:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100ec1:	eb 17                	jmp    80100eda <exec+0x35a>
    if(*s == '/')
80100ec3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ec6:	0f b6 00             	movzbl (%eax),%eax
80100ec9:	3c 2f                	cmp    $0x2f,%al
80100ecb:	75 09                	jne    80100ed6 <exec+0x356>
      last = s+1;
80100ecd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ed0:	83 c0 01             	add    $0x1,%eax
80100ed3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100ed6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100eda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100edd:	0f b6 00             	movzbl (%eax),%eax
80100ee0:	84 c0                	test   %al,%al
80100ee2:	75 df                	jne    80100ec3 <exec+0x343>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100ee4:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ee7:	83 c0 6c             	add    $0x6c,%eax
80100eea:	83 ec 04             	sub    $0x4,%esp
80100eed:	6a 10                	push   $0x10
80100eef:	ff 75 f0             	push   -0x10(%ebp)
80100ef2:	50                   	push   %eax
80100ef3:	e8 1c 3e 00 00       	call   80104d14 <safestrcpy>
80100ef8:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100efb:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100efe:	8b 40 04             	mov    0x4(%eax),%eax
80100f01:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f04:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f07:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f0a:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f0d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f10:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f13:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f15:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f18:	8b 40 18             	mov    0x18(%eax),%eax
80100f1b:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f21:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f24:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f27:	8b 40 18             	mov    0x18(%eax),%eax
80100f2a:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f2d:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f30:	83 ec 0c             	sub    $0xc,%esp
80100f33:	ff 75 d0             	push   -0x30(%ebp)
80100f36:	e8 e6 66 00 00       	call   80107621 <switchuvm>
80100f3b:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f3e:	83 ec 0c             	sub    $0xc,%esp
80100f41:	ff 75 cc             	push   -0x34(%ebp)
80100f44:	e8 7d 6b 00 00       	call   80107ac6 <freevm>
80100f49:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f4c:	b8 00 00 00 00       	mov    $0x0,%eax
80100f51:	eb 57                	jmp    80100faa <exec+0x42a>
    goto bad;
80100f53:	90                   	nop
80100f54:	eb 22                	jmp    80100f78 <exec+0x3f8>
    goto bad;
80100f56:	90                   	nop
80100f57:	eb 1f                	jmp    80100f78 <exec+0x3f8>
    goto bad;
80100f59:	90                   	nop
80100f5a:	eb 1c                	jmp    80100f78 <exec+0x3f8>
      goto bad;
80100f5c:	90                   	nop
80100f5d:	eb 19                	jmp    80100f78 <exec+0x3f8>
      goto bad;
80100f5f:	90                   	nop
80100f60:	eb 16                	jmp    80100f78 <exec+0x3f8>
      goto bad;
80100f62:	90                   	nop
80100f63:	eb 13                	jmp    80100f78 <exec+0x3f8>
      goto bad;
80100f65:	90                   	nop
80100f66:	eb 10                	jmp    80100f78 <exec+0x3f8>
      goto bad;
80100f68:	90                   	nop
80100f69:	eb 0d                	jmp    80100f78 <exec+0x3f8>
      goto bad;
80100f6b:	90                   	nop
80100f6c:	eb 0a                	jmp    80100f78 <exec+0x3f8>
    goto bad;
80100f6e:	90                   	nop
80100f6f:	eb 07                	jmp    80100f78 <exec+0x3f8>
      goto bad;
80100f71:	90                   	nop
80100f72:	eb 04                	jmp    80100f78 <exec+0x3f8>
      goto bad;
80100f74:	90                   	nop
80100f75:	eb 01                	jmp    80100f78 <exec+0x3f8>
    goto bad;
80100f77:	90                   	nop

 bad:
  if(pgdir)
80100f78:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f7c:	74 0e                	je     80100f8c <exec+0x40c>
    freevm(pgdir);
80100f7e:	83 ec 0c             	sub    $0xc,%esp
80100f81:	ff 75 d4             	push   -0x2c(%ebp)
80100f84:	e8 3d 6b 00 00       	call   80107ac6 <freevm>
80100f89:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f8c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f90:	74 13                	je     80100fa5 <exec+0x425>
    iunlockput(ip);
80100f92:	83 ec 0c             	sub    $0xc,%esp
80100f95:	ff 75 d8             	push   -0x28(%ebp)
80100f98:	e8 6b 0c 00 00       	call   80101c08 <iunlockput>
80100f9d:	83 c4 10             	add    $0x10,%esp
    end_op();
80100fa0:	e8 10 21 00 00       	call   801030b5 <end_op>
  }
  return -1;
80100fa5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100faa:	c9                   	leave  
80100fab:	c3                   	ret    

80100fac <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fac:	55                   	push   %ebp
80100fad:	89 e5                	mov    %esp,%ebp
80100faf:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fb2:	83 ec 08             	sub    $0x8,%esp
80100fb5:	68 a1 a3 10 80       	push   $0x8010a3a1
80100fba:	68 a0 1a 19 80       	push   $0x80191aa0
80100fbf:	e8 b5 38 00 00       	call   80104879 <initlock>
80100fc4:	83 c4 10             	add    $0x10,%esp
}
80100fc7:	90                   	nop
80100fc8:	c9                   	leave  
80100fc9:	c3                   	ret    

80100fca <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fca:	55                   	push   %ebp
80100fcb:	89 e5                	mov    %esp,%ebp
80100fcd:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fd0:	83 ec 0c             	sub    $0xc,%esp
80100fd3:	68 a0 1a 19 80       	push   $0x80191aa0
80100fd8:	e8 be 38 00 00       	call   8010489b <acquire>
80100fdd:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fe0:	c7 45 f4 d4 1a 19 80 	movl   $0x80191ad4,-0xc(%ebp)
80100fe7:	eb 2d                	jmp    80101016 <filealloc+0x4c>
    if(f->ref == 0){
80100fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fec:	8b 40 04             	mov    0x4(%eax),%eax
80100fef:	85 c0                	test   %eax,%eax
80100ff1:	75 1f                	jne    80101012 <filealloc+0x48>
      f->ref = 1;
80100ff3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ff6:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100ffd:	83 ec 0c             	sub    $0xc,%esp
80101000:	68 a0 1a 19 80       	push   $0x80191aa0
80101005:	e8 ff 38 00 00       	call   80104909 <release>
8010100a:	83 c4 10             	add    $0x10,%esp
      return f;
8010100d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101010:	eb 23                	jmp    80101035 <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101012:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101016:	b8 34 24 19 80       	mov    $0x80192434,%eax
8010101b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010101e:	72 c9                	jb     80100fe9 <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
80101020:	83 ec 0c             	sub    $0xc,%esp
80101023:	68 a0 1a 19 80       	push   $0x80191aa0
80101028:	e8 dc 38 00 00       	call   80104909 <release>
8010102d:	83 c4 10             	add    $0x10,%esp
  return 0;
80101030:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101035:	c9                   	leave  
80101036:	c3                   	ret    

80101037 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101037:	55                   	push   %ebp
80101038:	89 e5                	mov    %esp,%ebp
8010103a:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
8010103d:	83 ec 0c             	sub    $0xc,%esp
80101040:	68 a0 1a 19 80       	push   $0x80191aa0
80101045:	e8 51 38 00 00       	call   8010489b <acquire>
8010104a:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010104d:	8b 45 08             	mov    0x8(%ebp),%eax
80101050:	8b 40 04             	mov    0x4(%eax),%eax
80101053:	85 c0                	test   %eax,%eax
80101055:	7f 0d                	jg     80101064 <filedup+0x2d>
    panic("filedup");
80101057:	83 ec 0c             	sub    $0xc,%esp
8010105a:	68 a8 a3 10 80       	push   $0x8010a3a8
8010105f:	e8 45 f5 ff ff       	call   801005a9 <panic>
  f->ref++;
80101064:	8b 45 08             	mov    0x8(%ebp),%eax
80101067:	8b 40 04             	mov    0x4(%eax),%eax
8010106a:	8d 50 01             	lea    0x1(%eax),%edx
8010106d:	8b 45 08             	mov    0x8(%ebp),%eax
80101070:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101073:	83 ec 0c             	sub    $0xc,%esp
80101076:	68 a0 1a 19 80       	push   $0x80191aa0
8010107b:	e8 89 38 00 00       	call   80104909 <release>
80101080:	83 c4 10             	add    $0x10,%esp
  return f;
80101083:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101086:	c9                   	leave  
80101087:	c3                   	ret    

80101088 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101088:	55                   	push   %ebp
80101089:	89 e5                	mov    %esp,%ebp
8010108b:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
8010108e:	83 ec 0c             	sub    $0xc,%esp
80101091:	68 a0 1a 19 80       	push   $0x80191aa0
80101096:	e8 00 38 00 00       	call   8010489b <acquire>
8010109b:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010109e:	8b 45 08             	mov    0x8(%ebp),%eax
801010a1:	8b 40 04             	mov    0x4(%eax),%eax
801010a4:	85 c0                	test   %eax,%eax
801010a6:	7f 0d                	jg     801010b5 <fileclose+0x2d>
    panic("fileclose");
801010a8:	83 ec 0c             	sub    $0xc,%esp
801010ab:	68 b0 a3 10 80       	push   $0x8010a3b0
801010b0:	e8 f4 f4 ff ff       	call   801005a9 <panic>
  if(--f->ref > 0){
801010b5:	8b 45 08             	mov    0x8(%ebp),%eax
801010b8:	8b 40 04             	mov    0x4(%eax),%eax
801010bb:	8d 50 ff             	lea    -0x1(%eax),%edx
801010be:	8b 45 08             	mov    0x8(%ebp),%eax
801010c1:	89 50 04             	mov    %edx,0x4(%eax)
801010c4:	8b 45 08             	mov    0x8(%ebp),%eax
801010c7:	8b 40 04             	mov    0x4(%eax),%eax
801010ca:	85 c0                	test   %eax,%eax
801010cc:	7e 15                	jle    801010e3 <fileclose+0x5b>
    release(&ftable.lock);
801010ce:	83 ec 0c             	sub    $0xc,%esp
801010d1:	68 a0 1a 19 80       	push   $0x80191aa0
801010d6:	e8 2e 38 00 00       	call   80104909 <release>
801010db:	83 c4 10             	add    $0x10,%esp
801010de:	e9 8b 00 00 00       	jmp    8010116e <fileclose+0xe6>
    return;
  }
  ff = *f;
801010e3:	8b 45 08             	mov    0x8(%ebp),%eax
801010e6:	8b 10                	mov    (%eax),%edx
801010e8:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010eb:	8b 50 04             	mov    0x4(%eax),%edx
801010ee:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801010f1:	8b 50 08             	mov    0x8(%eax),%edx
801010f4:	89 55 e8             	mov    %edx,-0x18(%ebp)
801010f7:	8b 50 0c             	mov    0xc(%eax),%edx
801010fa:	89 55 ec             	mov    %edx,-0x14(%ebp)
801010fd:	8b 50 10             	mov    0x10(%eax),%edx
80101100:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101103:	8b 40 14             	mov    0x14(%eax),%eax
80101106:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101109:	8b 45 08             	mov    0x8(%ebp),%eax
8010110c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101113:	8b 45 08             	mov    0x8(%ebp),%eax
80101116:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010111c:	83 ec 0c             	sub    $0xc,%esp
8010111f:	68 a0 1a 19 80       	push   $0x80191aa0
80101124:	e8 e0 37 00 00       	call   80104909 <release>
80101129:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
8010112c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010112f:	83 f8 01             	cmp    $0x1,%eax
80101132:	75 19                	jne    8010114d <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
80101134:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101138:	0f be d0             	movsbl %al,%edx
8010113b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010113e:	83 ec 08             	sub    $0x8,%esp
80101141:	52                   	push   %edx
80101142:	50                   	push   %eax
80101143:	e8 64 25 00 00       	call   801036ac <pipeclose>
80101148:	83 c4 10             	add    $0x10,%esp
8010114b:	eb 21                	jmp    8010116e <fileclose+0xe6>
  else if(ff.type == FD_INODE){
8010114d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101150:	83 f8 02             	cmp    $0x2,%eax
80101153:	75 19                	jne    8010116e <fileclose+0xe6>
    begin_op();
80101155:	e8 cf 1e 00 00       	call   80103029 <begin_op>
    iput(ff.ip);
8010115a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010115d:	83 ec 0c             	sub    $0xc,%esp
80101160:	50                   	push   %eax
80101161:	e8 d2 09 00 00       	call   80101b38 <iput>
80101166:	83 c4 10             	add    $0x10,%esp
    end_op();
80101169:	e8 47 1f 00 00       	call   801030b5 <end_op>
  }
}
8010116e:	c9                   	leave  
8010116f:	c3                   	ret    

80101170 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101170:	55                   	push   %ebp
80101171:	89 e5                	mov    %esp,%ebp
80101173:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101176:	8b 45 08             	mov    0x8(%ebp),%eax
80101179:	8b 00                	mov    (%eax),%eax
8010117b:	83 f8 02             	cmp    $0x2,%eax
8010117e:	75 40                	jne    801011c0 <filestat+0x50>
    ilock(f->ip);
80101180:	8b 45 08             	mov    0x8(%ebp),%eax
80101183:	8b 40 10             	mov    0x10(%eax),%eax
80101186:	83 ec 0c             	sub    $0xc,%esp
80101189:	50                   	push   %eax
8010118a:	e8 48 08 00 00       	call   801019d7 <ilock>
8010118f:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
80101192:	8b 45 08             	mov    0x8(%ebp),%eax
80101195:	8b 40 10             	mov    0x10(%eax),%eax
80101198:	83 ec 08             	sub    $0x8,%esp
8010119b:	ff 75 0c             	push   0xc(%ebp)
8010119e:	50                   	push   %eax
8010119f:	e8 d9 0c 00 00       	call   80101e7d <stati>
801011a4:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011a7:	8b 45 08             	mov    0x8(%ebp),%eax
801011aa:	8b 40 10             	mov    0x10(%eax),%eax
801011ad:	83 ec 0c             	sub    $0xc,%esp
801011b0:	50                   	push   %eax
801011b1:	e8 34 09 00 00       	call   80101aea <iunlock>
801011b6:	83 c4 10             	add    $0x10,%esp
    return 0;
801011b9:	b8 00 00 00 00       	mov    $0x0,%eax
801011be:	eb 05                	jmp    801011c5 <filestat+0x55>
  }
  return -1;
801011c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011c5:	c9                   	leave  
801011c6:	c3                   	ret    

801011c7 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011c7:	55                   	push   %ebp
801011c8:	89 e5                	mov    %esp,%ebp
801011ca:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011cd:	8b 45 08             	mov    0x8(%ebp),%eax
801011d0:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011d4:	84 c0                	test   %al,%al
801011d6:	75 0a                	jne    801011e2 <fileread+0x1b>
    return -1;
801011d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011dd:	e9 9b 00 00 00       	jmp    8010127d <fileread+0xb6>
  if(f->type == FD_PIPE)
801011e2:	8b 45 08             	mov    0x8(%ebp),%eax
801011e5:	8b 00                	mov    (%eax),%eax
801011e7:	83 f8 01             	cmp    $0x1,%eax
801011ea:	75 1a                	jne    80101206 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801011ec:	8b 45 08             	mov    0x8(%ebp),%eax
801011ef:	8b 40 0c             	mov    0xc(%eax),%eax
801011f2:	83 ec 04             	sub    $0x4,%esp
801011f5:	ff 75 10             	push   0x10(%ebp)
801011f8:	ff 75 0c             	push   0xc(%ebp)
801011fb:	50                   	push   %eax
801011fc:	e8 58 26 00 00       	call   80103859 <piperead>
80101201:	83 c4 10             	add    $0x10,%esp
80101204:	eb 77                	jmp    8010127d <fileread+0xb6>
  if(f->type == FD_INODE){
80101206:	8b 45 08             	mov    0x8(%ebp),%eax
80101209:	8b 00                	mov    (%eax),%eax
8010120b:	83 f8 02             	cmp    $0x2,%eax
8010120e:	75 60                	jne    80101270 <fileread+0xa9>
    ilock(f->ip);
80101210:	8b 45 08             	mov    0x8(%ebp),%eax
80101213:	8b 40 10             	mov    0x10(%eax),%eax
80101216:	83 ec 0c             	sub    $0xc,%esp
80101219:	50                   	push   %eax
8010121a:	e8 b8 07 00 00       	call   801019d7 <ilock>
8010121f:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101222:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101225:	8b 45 08             	mov    0x8(%ebp),%eax
80101228:	8b 50 14             	mov    0x14(%eax),%edx
8010122b:	8b 45 08             	mov    0x8(%ebp),%eax
8010122e:	8b 40 10             	mov    0x10(%eax),%eax
80101231:	51                   	push   %ecx
80101232:	52                   	push   %edx
80101233:	ff 75 0c             	push   0xc(%ebp)
80101236:	50                   	push   %eax
80101237:	e8 87 0c 00 00       	call   80101ec3 <readi>
8010123c:	83 c4 10             	add    $0x10,%esp
8010123f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101242:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101246:	7e 11                	jle    80101259 <fileread+0x92>
      f->off += r;
80101248:	8b 45 08             	mov    0x8(%ebp),%eax
8010124b:	8b 50 14             	mov    0x14(%eax),%edx
8010124e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101251:	01 c2                	add    %eax,%edx
80101253:	8b 45 08             	mov    0x8(%ebp),%eax
80101256:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101259:	8b 45 08             	mov    0x8(%ebp),%eax
8010125c:	8b 40 10             	mov    0x10(%eax),%eax
8010125f:	83 ec 0c             	sub    $0xc,%esp
80101262:	50                   	push   %eax
80101263:	e8 82 08 00 00       	call   80101aea <iunlock>
80101268:	83 c4 10             	add    $0x10,%esp
    return r;
8010126b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010126e:	eb 0d                	jmp    8010127d <fileread+0xb6>
  }
  panic("fileread");
80101270:	83 ec 0c             	sub    $0xc,%esp
80101273:	68 ba a3 10 80       	push   $0x8010a3ba
80101278:	e8 2c f3 ff ff       	call   801005a9 <panic>
}
8010127d:	c9                   	leave  
8010127e:	c3                   	ret    

8010127f <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010127f:	55                   	push   %ebp
80101280:	89 e5                	mov    %esp,%ebp
80101282:	53                   	push   %ebx
80101283:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101286:	8b 45 08             	mov    0x8(%ebp),%eax
80101289:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010128d:	84 c0                	test   %al,%al
8010128f:	75 0a                	jne    8010129b <filewrite+0x1c>
    return -1;
80101291:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101296:	e9 1b 01 00 00       	jmp    801013b6 <filewrite+0x137>
  if(f->type == FD_PIPE)
8010129b:	8b 45 08             	mov    0x8(%ebp),%eax
8010129e:	8b 00                	mov    (%eax),%eax
801012a0:	83 f8 01             	cmp    $0x1,%eax
801012a3:	75 1d                	jne    801012c2 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801012a5:	8b 45 08             	mov    0x8(%ebp),%eax
801012a8:	8b 40 0c             	mov    0xc(%eax),%eax
801012ab:	83 ec 04             	sub    $0x4,%esp
801012ae:	ff 75 10             	push   0x10(%ebp)
801012b1:	ff 75 0c             	push   0xc(%ebp)
801012b4:	50                   	push   %eax
801012b5:	e8 9d 24 00 00       	call   80103757 <pipewrite>
801012ba:	83 c4 10             	add    $0x10,%esp
801012bd:	e9 f4 00 00 00       	jmp    801013b6 <filewrite+0x137>
  if(f->type == FD_INODE){
801012c2:	8b 45 08             	mov    0x8(%ebp),%eax
801012c5:	8b 00                	mov    (%eax),%eax
801012c7:	83 f8 02             	cmp    $0x2,%eax
801012ca:	0f 85 d9 00 00 00    	jne    801013a9 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801012d0:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801012d7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012de:	e9 a3 00 00 00       	jmp    80101386 <filewrite+0x107>
      int n1 = n - i;
801012e3:	8b 45 10             	mov    0x10(%ebp),%eax
801012e6:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801012ef:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801012f2:	7e 06                	jle    801012fa <filewrite+0x7b>
        n1 = max;
801012f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801012f7:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801012fa:	e8 2a 1d 00 00       	call   80103029 <begin_op>
      ilock(f->ip);
801012ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101302:	8b 40 10             	mov    0x10(%eax),%eax
80101305:	83 ec 0c             	sub    $0xc,%esp
80101308:	50                   	push   %eax
80101309:	e8 c9 06 00 00       	call   801019d7 <ilock>
8010130e:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101311:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101314:	8b 45 08             	mov    0x8(%ebp),%eax
80101317:	8b 50 14             	mov    0x14(%eax),%edx
8010131a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010131d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101320:	01 c3                	add    %eax,%ebx
80101322:	8b 45 08             	mov    0x8(%ebp),%eax
80101325:	8b 40 10             	mov    0x10(%eax),%eax
80101328:	51                   	push   %ecx
80101329:	52                   	push   %edx
8010132a:	53                   	push   %ebx
8010132b:	50                   	push   %eax
8010132c:	e8 e7 0c 00 00       	call   80102018 <writei>
80101331:	83 c4 10             	add    $0x10,%esp
80101334:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101337:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010133b:	7e 11                	jle    8010134e <filewrite+0xcf>
        f->off += r;
8010133d:	8b 45 08             	mov    0x8(%ebp),%eax
80101340:	8b 50 14             	mov    0x14(%eax),%edx
80101343:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101346:	01 c2                	add    %eax,%edx
80101348:	8b 45 08             	mov    0x8(%ebp),%eax
8010134b:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010134e:	8b 45 08             	mov    0x8(%ebp),%eax
80101351:	8b 40 10             	mov    0x10(%eax),%eax
80101354:	83 ec 0c             	sub    $0xc,%esp
80101357:	50                   	push   %eax
80101358:	e8 8d 07 00 00       	call   80101aea <iunlock>
8010135d:	83 c4 10             	add    $0x10,%esp
      end_op();
80101360:	e8 50 1d 00 00       	call   801030b5 <end_op>

      if(r < 0)
80101365:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101369:	78 29                	js     80101394 <filewrite+0x115>
        break;
      if(r != n1)
8010136b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010136e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101371:	74 0d                	je     80101380 <filewrite+0x101>
        panic("short filewrite");
80101373:	83 ec 0c             	sub    $0xc,%esp
80101376:	68 c3 a3 10 80       	push   $0x8010a3c3
8010137b:	e8 29 f2 ff ff       	call   801005a9 <panic>
      i += r;
80101380:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101383:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
80101386:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101389:	3b 45 10             	cmp    0x10(%ebp),%eax
8010138c:	0f 8c 51 ff ff ff    	jl     801012e3 <filewrite+0x64>
80101392:	eb 01                	jmp    80101395 <filewrite+0x116>
        break;
80101394:	90                   	nop
    }
    return i == n ? n : -1;
80101395:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101398:	3b 45 10             	cmp    0x10(%ebp),%eax
8010139b:	75 05                	jne    801013a2 <filewrite+0x123>
8010139d:	8b 45 10             	mov    0x10(%ebp),%eax
801013a0:	eb 14                	jmp    801013b6 <filewrite+0x137>
801013a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013a7:	eb 0d                	jmp    801013b6 <filewrite+0x137>
  }
  panic("filewrite");
801013a9:	83 ec 0c             	sub    $0xc,%esp
801013ac:	68 d3 a3 10 80       	push   $0x8010a3d3
801013b1:	e8 f3 f1 ff ff       	call   801005a9 <panic>
}
801013b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013b9:	c9                   	leave  
801013ba:	c3                   	ret    

801013bb <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013bb:	55                   	push   %ebp
801013bc:	89 e5                	mov    %esp,%ebp
801013be:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801013c1:	8b 45 08             	mov    0x8(%ebp),%eax
801013c4:	83 ec 08             	sub    $0x8,%esp
801013c7:	6a 01                	push   $0x1
801013c9:	50                   	push   %eax
801013ca:	e8 32 ee ff ff       	call   80100201 <bread>
801013cf:	83 c4 10             	add    $0x10,%esp
801013d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013d8:	83 c0 5c             	add    $0x5c,%eax
801013db:	83 ec 04             	sub    $0x4,%esp
801013de:	6a 1c                	push   $0x1c
801013e0:	50                   	push   %eax
801013e1:	ff 75 0c             	push   0xc(%ebp)
801013e4:	e8 e7 37 00 00       	call   80104bd0 <memmove>
801013e9:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013ec:	83 ec 0c             	sub    $0xc,%esp
801013ef:	ff 75 f4             	push   -0xc(%ebp)
801013f2:	e8 8c ee ff ff       	call   80100283 <brelse>
801013f7:	83 c4 10             	add    $0x10,%esp
}
801013fa:	90                   	nop
801013fb:	c9                   	leave  
801013fc:	c3                   	ret    

801013fd <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801013fd:	55                   	push   %ebp
801013fe:	89 e5                	mov    %esp,%ebp
80101400:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101403:	8b 55 0c             	mov    0xc(%ebp),%edx
80101406:	8b 45 08             	mov    0x8(%ebp),%eax
80101409:	83 ec 08             	sub    $0x8,%esp
8010140c:	52                   	push   %edx
8010140d:	50                   	push   %eax
8010140e:	e8 ee ed ff ff       	call   80100201 <bread>
80101413:	83 c4 10             	add    $0x10,%esp
80101416:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101419:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010141c:	83 c0 5c             	add    $0x5c,%eax
8010141f:	83 ec 04             	sub    $0x4,%esp
80101422:	68 00 02 00 00       	push   $0x200
80101427:	6a 00                	push   $0x0
80101429:	50                   	push   %eax
8010142a:	e8 e2 36 00 00       	call   80104b11 <memset>
8010142f:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101432:	83 ec 0c             	sub    $0xc,%esp
80101435:	ff 75 f4             	push   -0xc(%ebp)
80101438:	e8 25 1e 00 00       	call   80103262 <log_write>
8010143d:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101440:	83 ec 0c             	sub    $0xc,%esp
80101443:	ff 75 f4             	push   -0xc(%ebp)
80101446:	e8 38 ee ff ff       	call   80100283 <brelse>
8010144b:	83 c4 10             	add    $0x10,%esp
}
8010144e:	90                   	nop
8010144f:	c9                   	leave  
80101450:	c3                   	ret    

80101451 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101451:	55                   	push   %ebp
80101452:	89 e5                	mov    %esp,%ebp
80101454:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101457:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
8010145e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101465:	e9 0b 01 00 00       	jmp    80101575 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
8010146a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010146d:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101473:	85 c0                	test   %eax,%eax
80101475:	0f 48 c2             	cmovs  %edx,%eax
80101478:	c1 f8 0c             	sar    $0xc,%eax
8010147b:	89 c2                	mov    %eax,%edx
8010147d:	a1 58 24 19 80       	mov    0x80192458,%eax
80101482:	01 d0                	add    %edx,%eax
80101484:	83 ec 08             	sub    $0x8,%esp
80101487:	50                   	push   %eax
80101488:	ff 75 08             	push   0x8(%ebp)
8010148b:	e8 71 ed ff ff       	call   80100201 <bread>
80101490:	83 c4 10             	add    $0x10,%esp
80101493:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101496:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010149d:	e9 9e 00 00 00       	jmp    80101540 <balloc+0xef>
      m = 1 << (bi % 8);
801014a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014a5:	83 e0 07             	and    $0x7,%eax
801014a8:	ba 01 00 00 00       	mov    $0x1,%edx
801014ad:	89 c1                	mov    %eax,%ecx
801014af:	d3 e2                	shl    %cl,%edx
801014b1:	89 d0                	mov    %edx,%eax
801014b3:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014b9:	8d 50 07             	lea    0x7(%eax),%edx
801014bc:	85 c0                	test   %eax,%eax
801014be:	0f 48 c2             	cmovs  %edx,%eax
801014c1:	c1 f8 03             	sar    $0x3,%eax
801014c4:	89 c2                	mov    %eax,%edx
801014c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014c9:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801014ce:	0f b6 c0             	movzbl %al,%eax
801014d1:	23 45 e8             	and    -0x18(%ebp),%eax
801014d4:	85 c0                	test   %eax,%eax
801014d6:	75 64                	jne    8010153c <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
801014d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014db:	8d 50 07             	lea    0x7(%eax),%edx
801014de:	85 c0                	test   %eax,%eax
801014e0:	0f 48 c2             	cmovs  %edx,%eax
801014e3:	c1 f8 03             	sar    $0x3,%eax
801014e6:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014e9:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801014ee:	89 d1                	mov    %edx,%ecx
801014f0:	8b 55 e8             	mov    -0x18(%ebp),%edx
801014f3:	09 ca                	or     %ecx,%edx
801014f5:	89 d1                	mov    %edx,%ecx
801014f7:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014fa:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
801014fe:	83 ec 0c             	sub    $0xc,%esp
80101501:	ff 75 ec             	push   -0x14(%ebp)
80101504:	e8 59 1d 00 00       	call   80103262 <log_write>
80101509:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
8010150c:	83 ec 0c             	sub    $0xc,%esp
8010150f:	ff 75 ec             	push   -0x14(%ebp)
80101512:	e8 6c ed ff ff       	call   80100283 <brelse>
80101517:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010151a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010151d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101520:	01 c2                	add    %eax,%edx
80101522:	8b 45 08             	mov    0x8(%ebp),%eax
80101525:	83 ec 08             	sub    $0x8,%esp
80101528:	52                   	push   %edx
80101529:	50                   	push   %eax
8010152a:	e8 ce fe ff ff       	call   801013fd <bzero>
8010152f:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101532:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101535:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101538:	01 d0                	add    %edx,%eax
8010153a:	eb 57                	jmp    80101593 <balloc+0x142>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010153c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101540:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101547:	7f 17                	jg     80101560 <balloc+0x10f>
80101549:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010154c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010154f:	01 d0                	add    %edx,%eax
80101551:	89 c2                	mov    %eax,%edx
80101553:	a1 40 24 19 80       	mov    0x80192440,%eax
80101558:	39 c2                	cmp    %eax,%edx
8010155a:	0f 82 42 ff ff ff    	jb     801014a2 <balloc+0x51>
      }
    }
    brelse(bp);
80101560:	83 ec 0c             	sub    $0xc,%esp
80101563:	ff 75 ec             	push   -0x14(%ebp)
80101566:	e8 18 ed ff ff       	call   80100283 <brelse>
8010156b:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
8010156e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101575:	8b 15 40 24 19 80    	mov    0x80192440,%edx
8010157b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010157e:	39 c2                	cmp    %eax,%edx
80101580:	0f 87 e4 fe ff ff    	ja     8010146a <balloc+0x19>
  }
  panic("balloc: out of blocks");
80101586:	83 ec 0c             	sub    $0xc,%esp
80101589:	68 e0 a3 10 80       	push   $0x8010a3e0
8010158e:	e8 16 f0 ff ff       	call   801005a9 <panic>
}
80101593:	c9                   	leave  
80101594:	c3                   	ret    

80101595 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101595:	55                   	push   %ebp
80101596:	89 e5                	mov    %esp,%ebp
80101598:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
8010159b:	83 ec 08             	sub    $0x8,%esp
8010159e:	68 40 24 19 80       	push   $0x80192440
801015a3:	ff 75 08             	push   0x8(%ebp)
801015a6:	e8 10 fe ff ff       	call   801013bb <readsb>
801015ab:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801015b1:	c1 e8 0c             	shr    $0xc,%eax
801015b4:	89 c2                	mov    %eax,%edx
801015b6:	a1 58 24 19 80       	mov    0x80192458,%eax
801015bb:	01 c2                	add    %eax,%edx
801015bd:	8b 45 08             	mov    0x8(%ebp),%eax
801015c0:	83 ec 08             	sub    $0x8,%esp
801015c3:	52                   	push   %edx
801015c4:	50                   	push   %eax
801015c5:	e8 37 ec ff ff       	call   80100201 <bread>
801015ca:	83 c4 10             	add    $0x10,%esp
801015cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015d0:	8b 45 0c             	mov    0xc(%ebp),%eax
801015d3:	25 ff 0f 00 00       	and    $0xfff,%eax
801015d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015de:	83 e0 07             	and    $0x7,%eax
801015e1:	ba 01 00 00 00       	mov    $0x1,%edx
801015e6:	89 c1                	mov    %eax,%ecx
801015e8:	d3 e2                	shl    %cl,%edx
801015ea:	89 d0                	mov    %edx,%eax
801015ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801015ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015f2:	8d 50 07             	lea    0x7(%eax),%edx
801015f5:	85 c0                	test   %eax,%eax
801015f7:	0f 48 c2             	cmovs  %edx,%eax
801015fa:	c1 f8 03             	sar    $0x3,%eax
801015fd:	89 c2                	mov    %eax,%edx
801015ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101602:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101607:	0f b6 c0             	movzbl %al,%eax
8010160a:	23 45 ec             	and    -0x14(%ebp),%eax
8010160d:	85 c0                	test   %eax,%eax
8010160f:	75 0d                	jne    8010161e <bfree+0x89>
    panic("freeing free block");
80101611:	83 ec 0c             	sub    $0xc,%esp
80101614:	68 f6 a3 10 80       	push   $0x8010a3f6
80101619:	e8 8b ef ff ff       	call   801005a9 <panic>
  bp->data[bi/8] &= ~m;
8010161e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101621:	8d 50 07             	lea    0x7(%eax),%edx
80101624:	85 c0                	test   %eax,%eax
80101626:	0f 48 c2             	cmovs  %edx,%eax
80101629:	c1 f8 03             	sar    $0x3,%eax
8010162c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010162f:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101634:	89 d1                	mov    %edx,%ecx
80101636:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101639:	f7 d2                	not    %edx
8010163b:	21 ca                	and    %ecx,%edx
8010163d:	89 d1                	mov    %edx,%ecx
8010163f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101642:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101646:	83 ec 0c             	sub    $0xc,%esp
80101649:	ff 75 f4             	push   -0xc(%ebp)
8010164c:	e8 11 1c 00 00       	call   80103262 <log_write>
80101651:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101654:	83 ec 0c             	sub    $0xc,%esp
80101657:	ff 75 f4             	push   -0xc(%ebp)
8010165a:	e8 24 ec ff ff       	call   80100283 <brelse>
8010165f:	83 c4 10             	add    $0x10,%esp
}
80101662:	90                   	nop
80101663:	c9                   	leave  
80101664:	c3                   	ret    

80101665 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101665:	55                   	push   %ebp
80101666:	89 e5                	mov    %esp,%ebp
80101668:	57                   	push   %edi
80101669:	56                   	push   %esi
8010166a:	53                   	push   %ebx
8010166b:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
8010166e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101675:	83 ec 08             	sub    $0x8,%esp
80101678:	68 09 a4 10 80       	push   $0x8010a409
8010167d:	68 60 24 19 80       	push   $0x80192460
80101682:	e8 f2 31 00 00       	call   80104879 <initlock>
80101687:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
8010168a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101691:	eb 2d                	jmp    801016c0 <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
80101693:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101696:	89 d0                	mov    %edx,%eax
80101698:	c1 e0 03             	shl    $0x3,%eax
8010169b:	01 d0                	add    %edx,%eax
8010169d:	c1 e0 04             	shl    $0x4,%eax
801016a0:	83 c0 30             	add    $0x30,%eax
801016a3:	05 60 24 19 80       	add    $0x80192460,%eax
801016a8:	83 c0 10             	add    $0x10,%eax
801016ab:	83 ec 08             	sub    $0x8,%esp
801016ae:	68 10 a4 10 80       	push   $0x8010a410
801016b3:	50                   	push   %eax
801016b4:	e8 63 30 00 00       	call   8010471c <initsleeplock>
801016b9:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016bc:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016c0:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016c4:	7e cd                	jle    80101693 <iinit+0x2e>
  }

  readsb(dev, &sb);
801016c6:	83 ec 08             	sub    $0x8,%esp
801016c9:	68 40 24 19 80       	push   $0x80192440
801016ce:	ff 75 08             	push   0x8(%ebp)
801016d1:	e8 e5 fc ff ff       	call   801013bb <readsb>
801016d6:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016d9:	a1 58 24 19 80       	mov    0x80192458,%eax
801016de:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801016e1:	8b 3d 54 24 19 80    	mov    0x80192454,%edi
801016e7:	8b 35 50 24 19 80    	mov    0x80192450,%esi
801016ed:	8b 1d 4c 24 19 80    	mov    0x8019244c,%ebx
801016f3:	8b 0d 48 24 19 80    	mov    0x80192448,%ecx
801016f9:	8b 15 44 24 19 80    	mov    0x80192444,%edx
801016ff:	a1 40 24 19 80       	mov    0x80192440,%eax
80101704:	ff 75 d4             	push   -0x2c(%ebp)
80101707:	57                   	push   %edi
80101708:	56                   	push   %esi
80101709:	53                   	push   %ebx
8010170a:	51                   	push   %ecx
8010170b:	52                   	push   %edx
8010170c:	50                   	push   %eax
8010170d:	68 18 a4 10 80       	push   $0x8010a418
80101712:	e8 dd ec ff ff       	call   801003f4 <cprintf>
80101717:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
8010171a:	90                   	nop
8010171b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010171e:	5b                   	pop    %ebx
8010171f:	5e                   	pop    %esi
80101720:	5f                   	pop    %edi
80101721:	5d                   	pop    %ebp
80101722:	c3                   	ret    

80101723 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101723:	55                   	push   %ebp
80101724:	89 e5                	mov    %esp,%ebp
80101726:	83 ec 28             	sub    $0x28,%esp
80101729:	8b 45 0c             	mov    0xc(%ebp),%eax
8010172c:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101730:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101737:	e9 9e 00 00 00       	jmp    801017da <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
8010173c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010173f:	c1 e8 03             	shr    $0x3,%eax
80101742:	89 c2                	mov    %eax,%edx
80101744:	a1 54 24 19 80       	mov    0x80192454,%eax
80101749:	01 d0                	add    %edx,%eax
8010174b:	83 ec 08             	sub    $0x8,%esp
8010174e:	50                   	push   %eax
8010174f:	ff 75 08             	push   0x8(%ebp)
80101752:	e8 aa ea ff ff       	call   80100201 <bread>
80101757:	83 c4 10             	add    $0x10,%esp
8010175a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
8010175d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101760:	8d 50 5c             	lea    0x5c(%eax),%edx
80101763:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101766:	83 e0 07             	and    $0x7,%eax
80101769:	c1 e0 06             	shl    $0x6,%eax
8010176c:	01 d0                	add    %edx,%eax
8010176e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101771:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101774:	0f b7 00             	movzwl (%eax),%eax
80101777:	66 85 c0             	test   %ax,%ax
8010177a:	75 4c                	jne    801017c8 <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
8010177c:	83 ec 04             	sub    $0x4,%esp
8010177f:	6a 40                	push   $0x40
80101781:	6a 00                	push   $0x0
80101783:	ff 75 ec             	push   -0x14(%ebp)
80101786:	e8 86 33 00 00       	call   80104b11 <memset>
8010178b:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
8010178e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101791:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
80101795:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101798:	83 ec 0c             	sub    $0xc,%esp
8010179b:	ff 75 f0             	push   -0x10(%ebp)
8010179e:	e8 bf 1a 00 00       	call   80103262 <log_write>
801017a3:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017a6:	83 ec 0c             	sub    $0xc,%esp
801017a9:	ff 75 f0             	push   -0x10(%ebp)
801017ac:	e8 d2 ea ff ff       	call   80100283 <brelse>
801017b1:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017b7:	83 ec 08             	sub    $0x8,%esp
801017ba:	50                   	push   %eax
801017bb:	ff 75 08             	push   0x8(%ebp)
801017be:	e8 f8 00 00 00       	call   801018bb <iget>
801017c3:	83 c4 10             	add    $0x10,%esp
801017c6:	eb 30                	jmp    801017f8 <ialloc+0xd5>
    }
    brelse(bp);
801017c8:	83 ec 0c             	sub    $0xc,%esp
801017cb:	ff 75 f0             	push   -0x10(%ebp)
801017ce:	e8 b0 ea ff ff       	call   80100283 <brelse>
801017d3:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801017d6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801017da:	8b 15 48 24 19 80    	mov    0x80192448,%edx
801017e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017e3:	39 c2                	cmp    %eax,%edx
801017e5:	0f 87 51 ff ff ff    	ja     8010173c <ialloc+0x19>
  }
  panic("ialloc: no inodes");
801017eb:	83 ec 0c             	sub    $0xc,%esp
801017ee:	68 6b a4 10 80       	push   $0x8010a46b
801017f3:	e8 b1 ed ff ff       	call   801005a9 <panic>
}
801017f8:	c9                   	leave  
801017f9:	c3                   	ret    

801017fa <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
801017fa:	55                   	push   %ebp
801017fb:	89 e5                	mov    %esp,%ebp
801017fd:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101800:	8b 45 08             	mov    0x8(%ebp),%eax
80101803:	8b 40 04             	mov    0x4(%eax),%eax
80101806:	c1 e8 03             	shr    $0x3,%eax
80101809:	89 c2                	mov    %eax,%edx
8010180b:	a1 54 24 19 80       	mov    0x80192454,%eax
80101810:	01 c2                	add    %eax,%edx
80101812:	8b 45 08             	mov    0x8(%ebp),%eax
80101815:	8b 00                	mov    (%eax),%eax
80101817:	83 ec 08             	sub    $0x8,%esp
8010181a:	52                   	push   %edx
8010181b:	50                   	push   %eax
8010181c:	e8 e0 e9 ff ff       	call   80100201 <bread>
80101821:	83 c4 10             	add    $0x10,%esp
80101824:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101827:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010182a:	8d 50 5c             	lea    0x5c(%eax),%edx
8010182d:	8b 45 08             	mov    0x8(%ebp),%eax
80101830:	8b 40 04             	mov    0x4(%eax),%eax
80101833:	83 e0 07             	and    $0x7,%eax
80101836:	c1 e0 06             	shl    $0x6,%eax
80101839:	01 d0                	add    %edx,%eax
8010183b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
8010183e:	8b 45 08             	mov    0x8(%ebp),%eax
80101841:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101845:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101848:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010184b:	8b 45 08             	mov    0x8(%ebp),%eax
8010184e:	0f b7 50 52          	movzwl 0x52(%eax),%edx
80101852:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101855:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101859:	8b 45 08             	mov    0x8(%ebp),%eax
8010185c:	0f b7 50 54          	movzwl 0x54(%eax),%edx
80101860:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101863:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101867:	8b 45 08             	mov    0x8(%ebp),%eax
8010186a:	0f b7 50 56          	movzwl 0x56(%eax),%edx
8010186e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101871:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101875:	8b 45 08             	mov    0x8(%ebp),%eax
80101878:	8b 50 58             	mov    0x58(%eax),%edx
8010187b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010187e:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101881:	8b 45 08             	mov    0x8(%ebp),%eax
80101884:	8d 50 5c             	lea    0x5c(%eax),%edx
80101887:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010188a:	83 c0 0c             	add    $0xc,%eax
8010188d:	83 ec 04             	sub    $0x4,%esp
80101890:	6a 34                	push   $0x34
80101892:	52                   	push   %edx
80101893:	50                   	push   %eax
80101894:	e8 37 33 00 00       	call   80104bd0 <memmove>
80101899:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010189c:	83 ec 0c             	sub    $0xc,%esp
8010189f:	ff 75 f4             	push   -0xc(%ebp)
801018a2:	e8 bb 19 00 00       	call   80103262 <log_write>
801018a7:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018aa:	83 ec 0c             	sub    $0xc,%esp
801018ad:	ff 75 f4             	push   -0xc(%ebp)
801018b0:	e8 ce e9 ff ff       	call   80100283 <brelse>
801018b5:	83 c4 10             	add    $0x10,%esp
}
801018b8:	90                   	nop
801018b9:	c9                   	leave  
801018ba:	c3                   	ret    

801018bb <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018bb:	55                   	push   %ebp
801018bc:	89 e5                	mov    %esp,%ebp
801018be:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801018c1:	83 ec 0c             	sub    $0xc,%esp
801018c4:	68 60 24 19 80       	push   $0x80192460
801018c9:	e8 cd 2f 00 00       	call   8010489b <acquire>
801018ce:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018d1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018d8:	c7 45 f4 94 24 19 80 	movl   $0x80192494,-0xc(%ebp)
801018df:	eb 60                	jmp    80101941 <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801018e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018e4:	8b 40 08             	mov    0x8(%eax),%eax
801018e7:	85 c0                	test   %eax,%eax
801018e9:	7e 39                	jle    80101924 <iget+0x69>
801018eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ee:	8b 00                	mov    (%eax),%eax
801018f0:	39 45 08             	cmp    %eax,0x8(%ebp)
801018f3:	75 2f                	jne    80101924 <iget+0x69>
801018f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f8:	8b 40 04             	mov    0x4(%eax),%eax
801018fb:	39 45 0c             	cmp    %eax,0xc(%ebp)
801018fe:	75 24                	jne    80101924 <iget+0x69>
      ip->ref++;
80101900:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101903:	8b 40 08             	mov    0x8(%eax),%eax
80101906:	8d 50 01             	lea    0x1(%eax),%edx
80101909:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190c:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
8010190f:	83 ec 0c             	sub    $0xc,%esp
80101912:	68 60 24 19 80       	push   $0x80192460
80101917:	e8 ed 2f 00 00       	call   80104909 <release>
8010191c:	83 c4 10             	add    $0x10,%esp
      return ip;
8010191f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101922:	eb 77                	jmp    8010199b <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101924:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101928:	75 10                	jne    8010193a <iget+0x7f>
8010192a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010192d:	8b 40 08             	mov    0x8(%eax),%eax
80101930:	85 c0                	test   %eax,%eax
80101932:	75 06                	jne    8010193a <iget+0x7f>
      empty = ip;
80101934:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101937:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010193a:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101941:	81 7d f4 b4 40 19 80 	cmpl   $0x801940b4,-0xc(%ebp)
80101948:	72 97                	jb     801018e1 <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010194a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010194e:	75 0d                	jne    8010195d <iget+0xa2>
    panic("iget: no inodes");
80101950:	83 ec 0c             	sub    $0xc,%esp
80101953:	68 7d a4 10 80       	push   $0x8010a47d
80101958:	e8 4c ec ff ff       	call   801005a9 <panic>

  ip = empty;
8010195d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101960:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101963:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101966:	8b 55 08             	mov    0x8(%ebp),%edx
80101969:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
8010196b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010196e:	8b 55 0c             	mov    0xc(%ebp),%edx
80101971:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101974:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101977:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
8010197e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101981:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101988:	83 ec 0c             	sub    $0xc,%esp
8010198b:	68 60 24 19 80       	push   $0x80192460
80101990:	e8 74 2f 00 00       	call   80104909 <release>
80101995:	83 c4 10             	add    $0x10,%esp

  return ip;
80101998:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010199b:	c9                   	leave  
8010199c:	c3                   	ret    

8010199d <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
8010199d:	55                   	push   %ebp
8010199e:	89 e5                	mov    %esp,%ebp
801019a0:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019a3:	83 ec 0c             	sub    $0xc,%esp
801019a6:	68 60 24 19 80       	push   $0x80192460
801019ab:	e8 eb 2e 00 00       	call   8010489b <acquire>
801019b0:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019b3:	8b 45 08             	mov    0x8(%ebp),%eax
801019b6:	8b 40 08             	mov    0x8(%eax),%eax
801019b9:	8d 50 01             	lea    0x1(%eax),%edx
801019bc:	8b 45 08             	mov    0x8(%ebp),%eax
801019bf:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019c2:	83 ec 0c             	sub    $0xc,%esp
801019c5:	68 60 24 19 80       	push   $0x80192460
801019ca:	e8 3a 2f 00 00       	call   80104909 <release>
801019cf:	83 c4 10             	add    $0x10,%esp
  return ip;
801019d2:	8b 45 08             	mov    0x8(%ebp),%eax
}
801019d5:	c9                   	leave  
801019d6:	c3                   	ret    

801019d7 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801019d7:	55                   	push   %ebp
801019d8:	89 e5                	mov    %esp,%ebp
801019da:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801019dd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019e1:	74 0a                	je     801019ed <ilock+0x16>
801019e3:	8b 45 08             	mov    0x8(%ebp),%eax
801019e6:	8b 40 08             	mov    0x8(%eax),%eax
801019e9:	85 c0                	test   %eax,%eax
801019eb:	7f 0d                	jg     801019fa <ilock+0x23>
    panic("ilock");
801019ed:	83 ec 0c             	sub    $0xc,%esp
801019f0:	68 8d a4 10 80       	push   $0x8010a48d
801019f5:	e8 af eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
801019fa:	8b 45 08             	mov    0x8(%ebp),%eax
801019fd:	83 c0 0c             	add    $0xc,%eax
80101a00:	83 ec 0c             	sub    $0xc,%esp
80101a03:	50                   	push   %eax
80101a04:	e8 4f 2d 00 00       	call   80104758 <acquiresleep>
80101a09:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101a0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a0f:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a12:	85 c0                	test   %eax,%eax
80101a14:	0f 85 cd 00 00 00    	jne    80101ae7 <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a1d:	8b 40 04             	mov    0x4(%eax),%eax
80101a20:	c1 e8 03             	shr    $0x3,%eax
80101a23:	89 c2                	mov    %eax,%edx
80101a25:	a1 54 24 19 80       	mov    0x80192454,%eax
80101a2a:	01 c2                	add    %eax,%edx
80101a2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a2f:	8b 00                	mov    (%eax),%eax
80101a31:	83 ec 08             	sub    $0x8,%esp
80101a34:	52                   	push   %edx
80101a35:	50                   	push   %eax
80101a36:	e8 c6 e7 ff ff       	call   80100201 <bread>
80101a3b:	83 c4 10             	add    $0x10,%esp
80101a3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a44:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a47:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4a:	8b 40 04             	mov    0x4(%eax),%eax
80101a4d:	83 e0 07             	and    $0x7,%eax
80101a50:	c1 e0 06             	shl    $0x6,%eax
80101a53:	01 d0                	add    %edx,%eax
80101a55:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a5b:	0f b7 10             	movzwl (%eax),%edx
80101a5e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a61:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101a65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a68:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a6c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6f:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101a73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a76:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a7a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7d:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101a81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a84:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a88:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8b:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101a8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a92:	8b 50 08             	mov    0x8(%eax),%edx
80101a95:	8b 45 08             	mov    0x8(%ebp),%eax
80101a98:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a9e:	8d 50 0c             	lea    0xc(%eax),%edx
80101aa1:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa4:	83 c0 5c             	add    $0x5c,%eax
80101aa7:	83 ec 04             	sub    $0x4,%esp
80101aaa:	6a 34                	push   $0x34
80101aac:	52                   	push   %edx
80101aad:	50                   	push   %eax
80101aae:	e8 1d 31 00 00       	call   80104bd0 <memmove>
80101ab3:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ab6:	83 ec 0c             	sub    $0xc,%esp
80101ab9:	ff 75 f4             	push   -0xc(%ebp)
80101abc:	e8 c2 e7 ff ff       	call   80100283 <brelse>
80101ac1:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101ac4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac7:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101ace:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad1:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ad5:	66 85 c0             	test   %ax,%ax
80101ad8:	75 0d                	jne    80101ae7 <ilock+0x110>
      panic("ilock: no type");
80101ada:	83 ec 0c             	sub    $0xc,%esp
80101add:	68 93 a4 10 80       	push   $0x8010a493
80101ae2:	e8 c2 ea ff ff       	call   801005a9 <panic>
  }
}
80101ae7:	90                   	nop
80101ae8:	c9                   	leave  
80101ae9:	c3                   	ret    

80101aea <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101aea:	55                   	push   %ebp
80101aeb:	89 e5                	mov    %esp,%ebp
80101aed:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101af0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101af4:	74 20                	je     80101b16 <iunlock+0x2c>
80101af6:	8b 45 08             	mov    0x8(%ebp),%eax
80101af9:	83 c0 0c             	add    $0xc,%eax
80101afc:	83 ec 0c             	sub    $0xc,%esp
80101aff:	50                   	push   %eax
80101b00:	e8 05 2d 00 00       	call   8010480a <holdingsleep>
80101b05:	83 c4 10             	add    $0x10,%esp
80101b08:	85 c0                	test   %eax,%eax
80101b0a:	74 0a                	je     80101b16 <iunlock+0x2c>
80101b0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0f:	8b 40 08             	mov    0x8(%eax),%eax
80101b12:	85 c0                	test   %eax,%eax
80101b14:	7f 0d                	jg     80101b23 <iunlock+0x39>
    panic("iunlock");
80101b16:	83 ec 0c             	sub    $0xc,%esp
80101b19:	68 a2 a4 10 80       	push   $0x8010a4a2
80101b1e:	e8 86 ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b23:	8b 45 08             	mov    0x8(%ebp),%eax
80101b26:	83 c0 0c             	add    $0xc,%eax
80101b29:	83 ec 0c             	sub    $0xc,%esp
80101b2c:	50                   	push   %eax
80101b2d:	e8 8a 2c 00 00       	call   801047bc <releasesleep>
80101b32:	83 c4 10             	add    $0x10,%esp
}
80101b35:	90                   	nop
80101b36:	c9                   	leave  
80101b37:	c3                   	ret    

80101b38 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b38:	55                   	push   %ebp
80101b39:	89 e5                	mov    %esp,%ebp
80101b3b:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b41:	83 c0 0c             	add    $0xc,%eax
80101b44:	83 ec 0c             	sub    $0xc,%esp
80101b47:	50                   	push   %eax
80101b48:	e8 0b 2c 00 00       	call   80104758 <acquiresleep>
80101b4d:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101b50:	8b 45 08             	mov    0x8(%ebp),%eax
80101b53:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b56:	85 c0                	test   %eax,%eax
80101b58:	74 6a                	je     80101bc4 <iput+0x8c>
80101b5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5d:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101b61:	66 85 c0             	test   %ax,%ax
80101b64:	75 5e                	jne    80101bc4 <iput+0x8c>
    acquire(&icache.lock);
80101b66:	83 ec 0c             	sub    $0xc,%esp
80101b69:	68 60 24 19 80       	push   $0x80192460
80101b6e:	e8 28 2d 00 00       	call   8010489b <acquire>
80101b73:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b76:	8b 45 08             	mov    0x8(%ebp),%eax
80101b79:	8b 40 08             	mov    0x8(%eax),%eax
80101b7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b7f:	83 ec 0c             	sub    $0xc,%esp
80101b82:	68 60 24 19 80       	push   $0x80192460
80101b87:	e8 7d 2d 00 00       	call   80104909 <release>
80101b8c:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101b8f:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101b93:	75 2f                	jne    80101bc4 <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101b95:	83 ec 0c             	sub    $0xc,%esp
80101b98:	ff 75 08             	push   0x8(%ebp)
80101b9b:	e8 ad 01 00 00       	call   80101d4d <itrunc>
80101ba0:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101ba3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba6:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101bac:	83 ec 0c             	sub    $0xc,%esp
80101baf:	ff 75 08             	push   0x8(%ebp)
80101bb2:	e8 43 fc ff ff       	call   801017fa <iupdate>
80101bb7:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101bba:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbd:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101bc4:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc7:	83 c0 0c             	add    $0xc,%eax
80101bca:	83 ec 0c             	sub    $0xc,%esp
80101bcd:	50                   	push   %eax
80101bce:	e8 e9 2b 00 00       	call   801047bc <releasesleep>
80101bd3:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101bd6:	83 ec 0c             	sub    $0xc,%esp
80101bd9:	68 60 24 19 80       	push   $0x80192460
80101bde:	e8 b8 2c 00 00       	call   8010489b <acquire>
80101be3:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101be6:	8b 45 08             	mov    0x8(%ebp),%eax
80101be9:	8b 40 08             	mov    0x8(%eax),%eax
80101bec:	8d 50 ff             	lea    -0x1(%eax),%edx
80101bef:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf2:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101bf5:	83 ec 0c             	sub    $0xc,%esp
80101bf8:	68 60 24 19 80       	push   $0x80192460
80101bfd:	e8 07 2d 00 00       	call   80104909 <release>
80101c02:	83 c4 10             	add    $0x10,%esp
}
80101c05:	90                   	nop
80101c06:	c9                   	leave  
80101c07:	c3                   	ret    

80101c08 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c08:	55                   	push   %ebp
80101c09:	89 e5                	mov    %esp,%ebp
80101c0b:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c0e:	83 ec 0c             	sub    $0xc,%esp
80101c11:	ff 75 08             	push   0x8(%ebp)
80101c14:	e8 d1 fe ff ff       	call   80101aea <iunlock>
80101c19:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c1c:	83 ec 0c             	sub    $0xc,%esp
80101c1f:	ff 75 08             	push   0x8(%ebp)
80101c22:	e8 11 ff ff ff       	call   80101b38 <iput>
80101c27:	83 c4 10             	add    $0x10,%esp
}
80101c2a:	90                   	nop
80101c2b:	c9                   	leave  
80101c2c:	c3                   	ret    

80101c2d <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c2d:	55                   	push   %ebp
80101c2e:	89 e5                	mov    %esp,%ebp
80101c30:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c33:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c37:	77 42                	ja     80101c7b <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101c39:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3c:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c3f:	83 c2 14             	add    $0x14,%edx
80101c42:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c46:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c49:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c4d:	75 24                	jne    80101c73 <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c52:	8b 00                	mov    (%eax),%eax
80101c54:	83 ec 0c             	sub    $0xc,%esp
80101c57:	50                   	push   %eax
80101c58:	e8 f4 f7 ff ff       	call   80101451 <balloc>
80101c5d:	83 c4 10             	add    $0x10,%esp
80101c60:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c63:	8b 45 08             	mov    0x8(%ebp),%eax
80101c66:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c69:	8d 4a 14             	lea    0x14(%edx),%ecx
80101c6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c6f:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c76:	e9 d0 00 00 00       	jmp    80101d4b <bmap+0x11e>
  }
  bn -= NDIRECT;
80101c7b:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c7f:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c83:	0f 87 b5 00 00 00    	ja     80101d3e <bmap+0x111>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101c89:	8b 45 08             	mov    0x8(%ebp),%eax
80101c8c:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101c92:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c95:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c99:	75 20                	jne    80101cbb <bmap+0x8e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101c9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9e:	8b 00                	mov    (%eax),%eax
80101ca0:	83 ec 0c             	sub    $0xc,%esp
80101ca3:	50                   	push   %eax
80101ca4:	e8 a8 f7 ff ff       	call   80101451 <balloc>
80101ca9:	83 c4 10             	add    $0x10,%esp
80101cac:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101caf:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cb5:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101cbb:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbe:	8b 00                	mov    (%eax),%eax
80101cc0:	83 ec 08             	sub    $0x8,%esp
80101cc3:	ff 75 f4             	push   -0xc(%ebp)
80101cc6:	50                   	push   %eax
80101cc7:	e8 35 e5 ff ff       	call   80100201 <bread>
80101ccc:	83 c4 10             	add    $0x10,%esp
80101ccf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101cd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cd5:	83 c0 5c             	add    $0x5c,%eax
80101cd8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cdb:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cde:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ce5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ce8:	01 d0                	add    %edx,%eax
80101cea:	8b 00                	mov    (%eax),%eax
80101cec:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cf3:	75 36                	jne    80101d2b <bmap+0xfe>
      a[bn] = addr = balloc(ip->dev);
80101cf5:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf8:	8b 00                	mov    (%eax),%eax
80101cfa:	83 ec 0c             	sub    $0xc,%esp
80101cfd:	50                   	push   %eax
80101cfe:	e8 4e f7 ff ff       	call   80101451 <balloc>
80101d03:	83 c4 10             	add    $0x10,%esp
80101d06:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d09:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d0c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d13:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d16:	01 c2                	add    %eax,%edx
80101d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d1b:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d1d:	83 ec 0c             	sub    $0xc,%esp
80101d20:	ff 75 f0             	push   -0x10(%ebp)
80101d23:	e8 3a 15 00 00       	call   80103262 <log_write>
80101d28:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d2b:	83 ec 0c             	sub    $0xc,%esp
80101d2e:	ff 75 f0             	push   -0x10(%ebp)
80101d31:	e8 4d e5 ff ff       	call   80100283 <brelse>
80101d36:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d3c:	eb 0d                	jmp    80101d4b <bmap+0x11e>
  }

  panic("bmap: out of range");
80101d3e:	83 ec 0c             	sub    $0xc,%esp
80101d41:	68 aa a4 10 80       	push   $0x8010a4aa
80101d46:	e8 5e e8 ff ff       	call   801005a9 <panic>
}
80101d4b:	c9                   	leave  
80101d4c:	c3                   	ret    

80101d4d <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d4d:	55                   	push   %ebp
80101d4e:	89 e5                	mov    %esp,%ebp
80101d50:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d53:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d5a:	eb 45                	jmp    80101da1 <itrunc+0x54>
    if(ip->addrs[i]){
80101d5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d62:	83 c2 14             	add    $0x14,%edx
80101d65:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d69:	85 c0                	test   %eax,%eax
80101d6b:	74 30                	je     80101d9d <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d70:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d73:	83 c2 14             	add    $0x14,%edx
80101d76:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d7a:	8b 55 08             	mov    0x8(%ebp),%edx
80101d7d:	8b 12                	mov    (%edx),%edx
80101d7f:	83 ec 08             	sub    $0x8,%esp
80101d82:	50                   	push   %eax
80101d83:	52                   	push   %edx
80101d84:	e8 0c f8 ff ff       	call   80101595 <bfree>
80101d89:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101d8c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d92:	83 c2 14             	add    $0x14,%edx
80101d95:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101d9c:	00 
  for(i = 0; i < NDIRECT; i++){
80101d9d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101da1:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101da5:	7e b5                	jle    80101d5c <itrunc+0xf>
    }
  }

  if(ip->addrs[NDIRECT]){
80101da7:	8b 45 08             	mov    0x8(%ebp),%eax
80101daa:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101db0:	85 c0                	test   %eax,%eax
80101db2:	0f 84 aa 00 00 00    	je     80101e62 <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101db8:	8b 45 08             	mov    0x8(%ebp),%eax
80101dbb:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101dc1:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc4:	8b 00                	mov    (%eax),%eax
80101dc6:	83 ec 08             	sub    $0x8,%esp
80101dc9:	52                   	push   %edx
80101dca:	50                   	push   %eax
80101dcb:	e8 31 e4 ff ff       	call   80100201 <bread>
80101dd0:	83 c4 10             	add    $0x10,%esp
80101dd3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101dd6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dd9:	83 c0 5c             	add    $0x5c,%eax
80101ddc:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101ddf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101de6:	eb 3c                	jmp    80101e24 <itrunc+0xd7>
      if(a[j])
80101de8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101deb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101df2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101df5:	01 d0                	add    %edx,%eax
80101df7:	8b 00                	mov    (%eax),%eax
80101df9:	85 c0                	test   %eax,%eax
80101dfb:	74 23                	je     80101e20 <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101dfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e00:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e07:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e0a:	01 d0                	add    %edx,%eax
80101e0c:	8b 00                	mov    (%eax),%eax
80101e0e:	8b 55 08             	mov    0x8(%ebp),%edx
80101e11:	8b 12                	mov    (%edx),%edx
80101e13:	83 ec 08             	sub    $0x8,%esp
80101e16:	50                   	push   %eax
80101e17:	52                   	push   %edx
80101e18:	e8 78 f7 ff ff       	call   80101595 <bfree>
80101e1d:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e20:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e27:	83 f8 7f             	cmp    $0x7f,%eax
80101e2a:	76 bc                	jbe    80101de8 <itrunc+0x9b>
    }
    brelse(bp);
80101e2c:	83 ec 0c             	sub    $0xc,%esp
80101e2f:	ff 75 ec             	push   -0x14(%ebp)
80101e32:	e8 4c e4 ff ff       	call   80100283 <brelse>
80101e37:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e3a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e3d:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e43:	8b 55 08             	mov    0x8(%ebp),%edx
80101e46:	8b 12                	mov    (%edx),%edx
80101e48:	83 ec 08             	sub    $0x8,%esp
80101e4b:	50                   	push   %eax
80101e4c:	52                   	push   %edx
80101e4d:	e8 43 f7 ff ff       	call   80101595 <bfree>
80101e52:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e55:	8b 45 08             	mov    0x8(%ebp),%eax
80101e58:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101e5f:	00 00 00 
  }

  ip->size = 0;
80101e62:	8b 45 08             	mov    0x8(%ebp),%eax
80101e65:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101e6c:	83 ec 0c             	sub    $0xc,%esp
80101e6f:	ff 75 08             	push   0x8(%ebp)
80101e72:	e8 83 f9 ff ff       	call   801017fa <iupdate>
80101e77:	83 c4 10             	add    $0x10,%esp
}
80101e7a:	90                   	nop
80101e7b:	c9                   	leave  
80101e7c:	c3                   	ret    

80101e7d <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101e7d:	55                   	push   %ebp
80101e7e:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e80:	8b 45 08             	mov    0x8(%ebp),%eax
80101e83:	8b 00                	mov    (%eax),%eax
80101e85:	89 c2                	mov    %eax,%edx
80101e87:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e8a:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101e8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e90:	8b 50 04             	mov    0x4(%eax),%edx
80101e93:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e96:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101e99:	8b 45 08             	mov    0x8(%ebp),%eax
80101e9c:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101ea0:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ea3:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101ea6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea9:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101ead:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb0:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101eb4:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb7:	8b 50 58             	mov    0x58(%eax),%edx
80101eba:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ebd:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ec0:	90                   	nop
80101ec1:	5d                   	pop    %ebp
80101ec2:	c3                   	ret    

80101ec3 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ec3:	55                   	push   %ebp
80101ec4:	89 e5                	mov    %esp,%ebp
80101ec6:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ec9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ecc:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ed0:	66 83 f8 03          	cmp    $0x3,%ax
80101ed4:	75 5c                	jne    80101f32 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101ed6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed9:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101edd:	66 85 c0             	test   %ax,%ax
80101ee0:	78 20                	js     80101f02 <readi+0x3f>
80101ee2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee5:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101ee9:	66 83 f8 09          	cmp    $0x9,%ax
80101eed:	7f 13                	jg     80101f02 <readi+0x3f>
80101eef:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef2:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101ef6:	98                   	cwtl   
80101ef7:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101efe:	85 c0                	test   %eax,%eax
80101f00:	75 0a                	jne    80101f0c <readi+0x49>
      return -1;
80101f02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f07:	e9 0a 01 00 00       	jmp    80102016 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0f:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f13:	98                   	cwtl   
80101f14:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f1b:	8b 55 14             	mov    0x14(%ebp),%edx
80101f1e:	83 ec 04             	sub    $0x4,%esp
80101f21:	52                   	push   %edx
80101f22:	ff 75 0c             	push   0xc(%ebp)
80101f25:	ff 75 08             	push   0x8(%ebp)
80101f28:	ff d0                	call   *%eax
80101f2a:	83 c4 10             	add    $0x10,%esp
80101f2d:	e9 e4 00 00 00       	jmp    80102016 <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101f32:	8b 45 08             	mov    0x8(%ebp),%eax
80101f35:	8b 40 58             	mov    0x58(%eax),%eax
80101f38:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f3b:	77 0d                	ja     80101f4a <readi+0x87>
80101f3d:	8b 55 10             	mov    0x10(%ebp),%edx
80101f40:	8b 45 14             	mov    0x14(%ebp),%eax
80101f43:	01 d0                	add    %edx,%eax
80101f45:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f48:	76 0a                	jbe    80101f54 <readi+0x91>
    return -1;
80101f4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f4f:	e9 c2 00 00 00       	jmp    80102016 <readi+0x153>
  if(off + n > ip->size)
80101f54:	8b 55 10             	mov    0x10(%ebp),%edx
80101f57:	8b 45 14             	mov    0x14(%ebp),%eax
80101f5a:	01 c2                	add    %eax,%edx
80101f5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f5f:	8b 40 58             	mov    0x58(%eax),%eax
80101f62:	39 c2                	cmp    %eax,%edx
80101f64:	76 0c                	jbe    80101f72 <readi+0xaf>
    n = ip->size - off;
80101f66:	8b 45 08             	mov    0x8(%ebp),%eax
80101f69:	8b 40 58             	mov    0x58(%eax),%eax
80101f6c:	2b 45 10             	sub    0x10(%ebp),%eax
80101f6f:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f72:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f79:	e9 89 00 00 00       	jmp    80102007 <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f7e:	8b 45 10             	mov    0x10(%ebp),%eax
80101f81:	c1 e8 09             	shr    $0x9,%eax
80101f84:	83 ec 08             	sub    $0x8,%esp
80101f87:	50                   	push   %eax
80101f88:	ff 75 08             	push   0x8(%ebp)
80101f8b:	e8 9d fc ff ff       	call   80101c2d <bmap>
80101f90:	83 c4 10             	add    $0x10,%esp
80101f93:	8b 55 08             	mov    0x8(%ebp),%edx
80101f96:	8b 12                	mov    (%edx),%edx
80101f98:	83 ec 08             	sub    $0x8,%esp
80101f9b:	50                   	push   %eax
80101f9c:	52                   	push   %edx
80101f9d:	e8 5f e2 ff ff       	call   80100201 <bread>
80101fa2:	83 c4 10             	add    $0x10,%esp
80101fa5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fa8:	8b 45 10             	mov    0x10(%ebp),%eax
80101fab:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fb0:	ba 00 02 00 00       	mov    $0x200,%edx
80101fb5:	29 c2                	sub    %eax,%edx
80101fb7:	8b 45 14             	mov    0x14(%ebp),%eax
80101fba:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fbd:	39 c2                	cmp    %eax,%edx
80101fbf:	0f 46 c2             	cmovbe %edx,%eax
80101fc2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fc8:	8d 50 5c             	lea    0x5c(%eax),%edx
80101fcb:	8b 45 10             	mov    0x10(%ebp),%eax
80101fce:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fd3:	01 d0                	add    %edx,%eax
80101fd5:	83 ec 04             	sub    $0x4,%esp
80101fd8:	ff 75 ec             	push   -0x14(%ebp)
80101fdb:	50                   	push   %eax
80101fdc:	ff 75 0c             	push   0xc(%ebp)
80101fdf:	e8 ec 2b 00 00       	call   80104bd0 <memmove>
80101fe4:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101fe7:	83 ec 0c             	sub    $0xc,%esp
80101fea:	ff 75 f0             	push   -0x10(%ebp)
80101fed:	e8 91 e2 ff ff       	call   80100283 <brelse>
80101ff2:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101ff5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ff8:	01 45 f4             	add    %eax,-0xc(%ebp)
80101ffb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ffe:	01 45 10             	add    %eax,0x10(%ebp)
80102001:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102004:	01 45 0c             	add    %eax,0xc(%ebp)
80102007:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010200a:	3b 45 14             	cmp    0x14(%ebp),%eax
8010200d:	0f 82 6b ff ff ff    	jb     80101f7e <readi+0xbb>
  }
  return n;
80102013:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102016:	c9                   	leave  
80102017:	c3                   	ret    

80102018 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102018:	55                   	push   %ebp
80102019:	89 e5                	mov    %esp,%ebp
8010201b:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010201e:	8b 45 08             	mov    0x8(%ebp),%eax
80102021:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102025:	66 83 f8 03          	cmp    $0x3,%ax
80102029:	75 5c                	jne    80102087 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010202b:	8b 45 08             	mov    0x8(%ebp),%eax
8010202e:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102032:	66 85 c0             	test   %ax,%ax
80102035:	78 20                	js     80102057 <writei+0x3f>
80102037:	8b 45 08             	mov    0x8(%ebp),%eax
8010203a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010203e:	66 83 f8 09          	cmp    $0x9,%ax
80102042:	7f 13                	jg     80102057 <writei+0x3f>
80102044:	8b 45 08             	mov    0x8(%ebp),%eax
80102047:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010204b:	98                   	cwtl   
8010204c:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
80102053:	85 c0                	test   %eax,%eax
80102055:	75 0a                	jne    80102061 <writei+0x49>
      return -1;
80102057:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010205c:	e9 3b 01 00 00       	jmp    8010219c <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
80102061:	8b 45 08             	mov    0x8(%ebp),%eax
80102064:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102068:	98                   	cwtl   
80102069:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
80102070:	8b 55 14             	mov    0x14(%ebp),%edx
80102073:	83 ec 04             	sub    $0x4,%esp
80102076:	52                   	push   %edx
80102077:	ff 75 0c             	push   0xc(%ebp)
8010207a:	ff 75 08             	push   0x8(%ebp)
8010207d:	ff d0                	call   *%eax
8010207f:	83 c4 10             	add    $0x10,%esp
80102082:	e9 15 01 00 00       	jmp    8010219c <writei+0x184>
  }

  if(off > ip->size || off + n < off)
80102087:	8b 45 08             	mov    0x8(%ebp),%eax
8010208a:	8b 40 58             	mov    0x58(%eax),%eax
8010208d:	39 45 10             	cmp    %eax,0x10(%ebp)
80102090:	77 0d                	ja     8010209f <writei+0x87>
80102092:	8b 55 10             	mov    0x10(%ebp),%edx
80102095:	8b 45 14             	mov    0x14(%ebp),%eax
80102098:	01 d0                	add    %edx,%eax
8010209a:	39 45 10             	cmp    %eax,0x10(%ebp)
8010209d:	76 0a                	jbe    801020a9 <writei+0x91>
    return -1;
8010209f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020a4:	e9 f3 00 00 00       	jmp    8010219c <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801020a9:	8b 55 10             	mov    0x10(%ebp),%edx
801020ac:	8b 45 14             	mov    0x14(%ebp),%eax
801020af:	01 d0                	add    %edx,%eax
801020b1:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020b6:	76 0a                	jbe    801020c2 <writei+0xaa>
    return -1;
801020b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020bd:	e9 da 00 00 00       	jmp    8010219c <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020c9:	e9 97 00 00 00       	jmp    80102165 <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020ce:	8b 45 10             	mov    0x10(%ebp),%eax
801020d1:	c1 e8 09             	shr    $0x9,%eax
801020d4:	83 ec 08             	sub    $0x8,%esp
801020d7:	50                   	push   %eax
801020d8:	ff 75 08             	push   0x8(%ebp)
801020db:	e8 4d fb ff ff       	call   80101c2d <bmap>
801020e0:	83 c4 10             	add    $0x10,%esp
801020e3:	8b 55 08             	mov    0x8(%ebp),%edx
801020e6:	8b 12                	mov    (%edx),%edx
801020e8:	83 ec 08             	sub    $0x8,%esp
801020eb:	50                   	push   %eax
801020ec:	52                   	push   %edx
801020ed:	e8 0f e1 ff ff       	call   80100201 <bread>
801020f2:	83 c4 10             	add    $0x10,%esp
801020f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801020f8:	8b 45 10             	mov    0x10(%ebp),%eax
801020fb:	25 ff 01 00 00       	and    $0x1ff,%eax
80102100:	ba 00 02 00 00       	mov    $0x200,%edx
80102105:	29 c2                	sub    %eax,%edx
80102107:	8b 45 14             	mov    0x14(%ebp),%eax
8010210a:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010210d:	39 c2                	cmp    %eax,%edx
8010210f:	0f 46 c2             	cmovbe %edx,%eax
80102112:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102115:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102118:	8d 50 5c             	lea    0x5c(%eax),%edx
8010211b:	8b 45 10             	mov    0x10(%ebp),%eax
8010211e:	25 ff 01 00 00       	and    $0x1ff,%eax
80102123:	01 d0                	add    %edx,%eax
80102125:	83 ec 04             	sub    $0x4,%esp
80102128:	ff 75 ec             	push   -0x14(%ebp)
8010212b:	ff 75 0c             	push   0xc(%ebp)
8010212e:	50                   	push   %eax
8010212f:	e8 9c 2a 00 00       	call   80104bd0 <memmove>
80102134:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102137:	83 ec 0c             	sub    $0xc,%esp
8010213a:	ff 75 f0             	push   -0x10(%ebp)
8010213d:	e8 20 11 00 00       	call   80103262 <log_write>
80102142:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102145:	83 ec 0c             	sub    $0xc,%esp
80102148:	ff 75 f0             	push   -0x10(%ebp)
8010214b:	e8 33 e1 ff ff       	call   80100283 <brelse>
80102150:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102153:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102156:	01 45 f4             	add    %eax,-0xc(%ebp)
80102159:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010215c:	01 45 10             	add    %eax,0x10(%ebp)
8010215f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102162:	01 45 0c             	add    %eax,0xc(%ebp)
80102165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102168:	3b 45 14             	cmp    0x14(%ebp),%eax
8010216b:	0f 82 5d ff ff ff    	jb     801020ce <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
80102171:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102175:	74 22                	je     80102199 <writei+0x181>
80102177:	8b 45 08             	mov    0x8(%ebp),%eax
8010217a:	8b 40 58             	mov    0x58(%eax),%eax
8010217d:	39 45 10             	cmp    %eax,0x10(%ebp)
80102180:	76 17                	jbe    80102199 <writei+0x181>
    ip->size = off;
80102182:	8b 45 08             	mov    0x8(%ebp),%eax
80102185:	8b 55 10             	mov    0x10(%ebp),%edx
80102188:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
8010218b:	83 ec 0c             	sub    $0xc,%esp
8010218e:	ff 75 08             	push   0x8(%ebp)
80102191:	e8 64 f6 ff ff       	call   801017fa <iupdate>
80102196:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102199:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010219c:	c9                   	leave  
8010219d:	c3                   	ret    

8010219e <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010219e:	55                   	push   %ebp
8010219f:	89 e5                	mov    %esp,%ebp
801021a1:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021a4:	83 ec 04             	sub    $0x4,%esp
801021a7:	6a 0e                	push   $0xe
801021a9:	ff 75 0c             	push   0xc(%ebp)
801021ac:	ff 75 08             	push   0x8(%ebp)
801021af:	e8 b2 2a 00 00       	call   80104c66 <strncmp>
801021b4:	83 c4 10             	add    $0x10,%esp
}
801021b7:	c9                   	leave  
801021b8:	c3                   	ret    

801021b9 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021b9:	55                   	push   %ebp
801021ba:	89 e5                	mov    %esp,%ebp
801021bc:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021bf:	8b 45 08             	mov    0x8(%ebp),%eax
801021c2:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021c6:	66 83 f8 01          	cmp    $0x1,%ax
801021ca:	74 0d                	je     801021d9 <dirlookup+0x20>
    panic("dirlookup not DIR");
801021cc:	83 ec 0c             	sub    $0xc,%esp
801021cf:	68 bd a4 10 80       	push   $0x8010a4bd
801021d4:	e8 d0 e3 ff ff       	call   801005a9 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021e0:	eb 7b                	jmp    8010225d <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021e2:	6a 10                	push   $0x10
801021e4:	ff 75 f4             	push   -0xc(%ebp)
801021e7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021ea:	50                   	push   %eax
801021eb:	ff 75 08             	push   0x8(%ebp)
801021ee:	e8 d0 fc ff ff       	call   80101ec3 <readi>
801021f3:	83 c4 10             	add    $0x10,%esp
801021f6:	83 f8 10             	cmp    $0x10,%eax
801021f9:	74 0d                	je     80102208 <dirlookup+0x4f>
      panic("dirlookup read");
801021fb:	83 ec 0c             	sub    $0xc,%esp
801021fe:	68 cf a4 10 80       	push   $0x8010a4cf
80102203:	e8 a1 e3 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
80102208:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010220c:	66 85 c0             	test   %ax,%ax
8010220f:	74 47                	je     80102258 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
80102211:	83 ec 08             	sub    $0x8,%esp
80102214:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102217:	83 c0 02             	add    $0x2,%eax
8010221a:	50                   	push   %eax
8010221b:	ff 75 0c             	push   0xc(%ebp)
8010221e:	e8 7b ff ff ff       	call   8010219e <namecmp>
80102223:	83 c4 10             	add    $0x10,%esp
80102226:	85 c0                	test   %eax,%eax
80102228:	75 2f                	jne    80102259 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
8010222a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010222e:	74 08                	je     80102238 <dirlookup+0x7f>
        *poff = off;
80102230:	8b 45 10             	mov    0x10(%ebp),%eax
80102233:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102236:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102238:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010223c:	0f b7 c0             	movzwl %ax,%eax
8010223f:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102242:	8b 45 08             	mov    0x8(%ebp),%eax
80102245:	8b 00                	mov    (%eax),%eax
80102247:	83 ec 08             	sub    $0x8,%esp
8010224a:	ff 75 f0             	push   -0x10(%ebp)
8010224d:	50                   	push   %eax
8010224e:	e8 68 f6 ff ff       	call   801018bb <iget>
80102253:	83 c4 10             	add    $0x10,%esp
80102256:	eb 19                	jmp    80102271 <dirlookup+0xb8>
      continue;
80102258:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
80102259:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010225d:	8b 45 08             	mov    0x8(%ebp),%eax
80102260:	8b 40 58             	mov    0x58(%eax),%eax
80102263:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102266:	0f 82 76 ff ff ff    	jb     801021e2 <dirlookup+0x29>
    }
  }

  return 0;
8010226c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102271:	c9                   	leave  
80102272:	c3                   	ret    

80102273 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102273:	55                   	push   %ebp
80102274:	89 e5                	mov    %esp,%ebp
80102276:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102279:	83 ec 04             	sub    $0x4,%esp
8010227c:	6a 00                	push   $0x0
8010227e:	ff 75 0c             	push   0xc(%ebp)
80102281:	ff 75 08             	push   0x8(%ebp)
80102284:	e8 30 ff ff ff       	call   801021b9 <dirlookup>
80102289:	83 c4 10             	add    $0x10,%esp
8010228c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010228f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102293:	74 18                	je     801022ad <dirlink+0x3a>
    iput(ip);
80102295:	83 ec 0c             	sub    $0xc,%esp
80102298:	ff 75 f0             	push   -0x10(%ebp)
8010229b:	e8 98 f8 ff ff       	call   80101b38 <iput>
801022a0:	83 c4 10             	add    $0x10,%esp
    return -1;
801022a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022a8:	e9 9c 00 00 00       	jmp    80102349 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022b4:	eb 39                	jmp    801022ef <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022b9:	6a 10                	push   $0x10
801022bb:	50                   	push   %eax
801022bc:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022bf:	50                   	push   %eax
801022c0:	ff 75 08             	push   0x8(%ebp)
801022c3:	e8 fb fb ff ff       	call   80101ec3 <readi>
801022c8:	83 c4 10             	add    $0x10,%esp
801022cb:	83 f8 10             	cmp    $0x10,%eax
801022ce:	74 0d                	je     801022dd <dirlink+0x6a>
      panic("dirlink read");
801022d0:	83 ec 0c             	sub    $0xc,%esp
801022d3:	68 de a4 10 80       	push   $0x8010a4de
801022d8:	e8 cc e2 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
801022dd:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022e1:	66 85 c0             	test   %ax,%ax
801022e4:	74 18                	je     801022fe <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
801022e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022e9:	83 c0 10             	add    $0x10,%eax
801022ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
801022ef:	8b 45 08             	mov    0x8(%ebp),%eax
801022f2:	8b 50 58             	mov    0x58(%eax),%edx
801022f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022f8:	39 c2                	cmp    %eax,%edx
801022fa:	77 ba                	ja     801022b6 <dirlink+0x43>
801022fc:	eb 01                	jmp    801022ff <dirlink+0x8c>
      break;
801022fe:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801022ff:	83 ec 04             	sub    $0x4,%esp
80102302:	6a 0e                	push   $0xe
80102304:	ff 75 0c             	push   0xc(%ebp)
80102307:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010230a:	83 c0 02             	add    $0x2,%eax
8010230d:	50                   	push   %eax
8010230e:	e8 a9 29 00 00       	call   80104cbc <strncpy>
80102313:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102316:	8b 45 10             	mov    0x10(%ebp),%eax
80102319:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010231d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102320:	6a 10                	push   $0x10
80102322:	50                   	push   %eax
80102323:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102326:	50                   	push   %eax
80102327:	ff 75 08             	push   0x8(%ebp)
8010232a:	e8 e9 fc ff ff       	call   80102018 <writei>
8010232f:	83 c4 10             	add    $0x10,%esp
80102332:	83 f8 10             	cmp    $0x10,%eax
80102335:	74 0d                	je     80102344 <dirlink+0xd1>
    panic("dirlink");
80102337:	83 ec 0c             	sub    $0xc,%esp
8010233a:	68 eb a4 10 80       	push   $0x8010a4eb
8010233f:	e8 65 e2 ff ff       	call   801005a9 <panic>

  return 0;
80102344:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102349:	c9                   	leave  
8010234a:	c3                   	ret    

8010234b <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010234b:	55                   	push   %ebp
8010234c:	89 e5                	mov    %esp,%ebp
8010234e:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102351:	eb 04                	jmp    80102357 <skipelem+0xc>
    path++;
80102353:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102357:	8b 45 08             	mov    0x8(%ebp),%eax
8010235a:	0f b6 00             	movzbl (%eax),%eax
8010235d:	3c 2f                	cmp    $0x2f,%al
8010235f:	74 f2                	je     80102353 <skipelem+0x8>
  if(*path == 0)
80102361:	8b 45 08             	mov    0x8(%ebp),%eax
80102364:	0f b6 00             	movzbl (%eax),%eax
80102367:	84 c0                	test   %al,%al
80102369:	75 07                	jne    80102372 <skipelem+0x27>
    return 0;
8010236b:	b8 00 00 00 00       	mov    $0x0,%eax
80102370:	eb 77                	jmp    801023e9 <skipelem+0x9e>
  s = path;
80102372:	8b 45 08             	mov    0x8(%ebp),%eax
80102375:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102378:	eb 04                	jmp    8010237e <skipelem+0x33>
    path++;
8010237a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
8010237e:	8b 45 08             	mov    0x8(%ebp),%eax
80102381:	0f b6 00             	movzbl (%eax),%eax
80102384:	3c 2f                	cmp    $0x2f,%al
80102386:	74 0a                	je     80102392 <skipelem+0x47>
80102388:	8b 45 08             	mov    0x8(%ebp),%eax
8010238b:	0f b6 00             	movzbl (%eax),%eax
8010238e:	84 c0                	test   %al,%al
80102390:	75 e8                	jne    8010237a <skipelem+0x2f>
  len = path - s;
80102392:	8b 45 08             	mov    0x8(%ebp),%eax
80102395:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102398:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
8010239b:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
8010239f:	7e 15                	jle    801023b6 <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
801023a1:	83 ec 04             	sub    $0x4,%esp
801023a4:	6a 0e                	push   $0xe
801023a6:	ff 75 f4             	push   -0xc(%ebp)
801023a9:	ff 75 0c             	push   0xc(%ebp)
801023ac:	e8 1f 28 00 00       	call   80104bd0 <memmove>
801023b1:	83 c4 10             	add    $0x10,%esp
801023b4:	eb 26                	jmp    801023dc <skipelem+0x91>
  else {
    memmove(name, s, len);
801023b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023b9:	83 ec 04             	sub    $0x4,%esp
801023bc:	50                   	push   %eax
801023bd:	ff 75 f4             	push   -0xc(%ebp)
801023c0:	ff 75 0c             	push   0xc(%ebp)
801023c3:	e8 08 28 00 00       	call   80104bd0 <memmove>
801023c8:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023cb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801023d1:	01 d0                	add    %edx,%eax
801023d3:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023d6:	eb 04                	jmp    801023dc <skipelem+0x91>
    path++;
801023d8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801023dc:	8b 45 08             	mov    0x8(%ebp),%eax
801023df:	0f b6 00             	movzbl (%eax),%eax
801023e2:	3c 2f                	cmp    $0x2f,%al
801023e4:	74 f2                	je     801023d8 <skipelem+0x8d>
  return path;
801023e6:	8b 45 08             	mov    0x8(%ebp),%eax
}
801023e9:	c9                   	leave  
801023ea:	c3                   	ret    

801023eb <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801023eb:	55                   	push   %ebp
801023ec:	89 e5                	mov    %esp,%ebp
801023ee:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801023f1:	8b 45 08             	mov    0x8(%ebp),%eax
801023f4:	0f b6 00             	movzbl (%eax),%eax
801023f7:	3c 2f                	cmp    $0x2f,%al
801023f9:	75 17                	jne    80102412 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
801023fb:	83 ec 08             	sub    $0x8,%esp
801023fe:	6a 01                	push   $0x1
80102400:	6a 01                	push   $0x1
80102402:	e8 b4 f4 ff ff       	call   801018bb <iget>
80102407:	83 c4 10             	add    $0x10,%esp
8010240a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010240d:	e9 ba 00 00 00       	jmp    801024cc <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
80102412:	e8 12 16 00 00       	call   80103a29 <myproc>
80102417:	8b 40 68             	mov    0x68(%eax),%eax
8010241a:	83 ec 0c             	sub    $0xc,%esp
8010241d:	50                   	push   %eax
8010241e:	e8 7a f5 ff ff       	call   8010199d <idup>
80102423:	83 c4 10             	add    $0x10,%esp
80102426:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102429:	e9 9e 00 00 00       	jmp    801024cc <namex+0xe1>
    ilock(ip);
8010242e:	83 ec 0c             	sub    $0xc,%esp
80102431:	ff 75 f4             	push   -0xc(%ebp)
80102434:	e8 9e f5 ff ff       	call   801019d7 <ilock>
80102439:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010243c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010243f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102443:	66 83 f8 01          	cmp    $0x1,%ax
80102447:	74 18                	je     80102461 <namex+0x76>
      iunlockput(ip);
80102449:	83 ec 0c             	sub    $0xc,%esp
8010244c:	ff 75 f4             	push   -0xc(%ebp)
8010244f:	e8 b4 f7 ff ff       	call   80101c08 <iunlockput>
80102454:	83 c4 10             	add    $0x10,%esp
      return 0;
80102457:	b8 00 00 00 00       	mov    $0x0,%eax
8010245c:	e9 a7 00 00 00       	jmp    80102508 <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
80102461:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102465:	74 20                	je     80102487 <namex+0x9c>
80102467:	8b 45 08             	mov    0x8(%ebp),%eax
8010246a:	0f b6 00             	movzbl (%eax),%eax
8010246d:	84 c0                	test   %al,%al
8010246f:	75 16                	jne    80102487 <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
80102471:	83 ec 0c             	sub    $0xc,%esp
80102474:	ff 75 f4             	push   -0xc(%ebp)
80102477:	e8 6e f6 ff ff       	call   80101aea <iunlock>
8010247c:	83 c4 10             	add    $0x10,%esp
      return ip;
8010247f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102482:	e9 81 00 00 00       	jmp    80102508 <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102487:	83 ec 04             	sub    $0x4,%esp
8010248a:	6a 00                	push   $0x0
8010248c:	ff 75 10             	push   0x10(%ebp)
8010248f:	ff 75 f4             	push   -0xc(%ebp)
80102492:	e8 22 fd ff ff       	call   801021b9 <dirlookup>
80102497:	83 c4 10             	add    $0x10,%esp
8010249a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010249d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024a1:	75 15                	jne    801024b8 <namex+0xcd>
      iunlockput(ip);
801024a3:	83 ec 0c             	sub    $0xc,%esp
801024a6:	ff 75 f4             	push   -0xc(%ebp)
801024a9:	e8 5a f7 ff ff       	call   80101c08 <iunlockput>
801024ae:	83 c4 10             	add    $0x10,%esp
      return 0;
801024b1:	b8 00 00 00 00       	mov    $0x0,%eax
801024b6:	eb 50                	jmp    80102508 <namex+0x11d>
    }
    iunlockput(ip);
801024b8:	83 ec 0c             	sub    $0xc,%esp
801024bb:	ff 75 f4             	push   -0xc(%ebp)
801024be:	e8 45 f7 ff ff       	call   80101c08 <iunlockput>
801024c3:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801024cc:	83 ec 08             	sub    $0x8,%esp
801024cf:	ff 75 10             	push   0x10(%ebp)
801024d2:	ff 75 08             	push   0x8(%ebp)
801024d5:	e8 71 fe ff ff       	call   8010234b <skipelem>
801024da:	83 c4 10             	add    $0x10,%esp
801024dd:	89 45 08             	mov    %eax,0x8(%ebp)
801024e0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024e4:	0f 85 44 ff ff ff    	jne    8010242e <namex+0x43>
  }
  if(nameiparent){
801024ea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801024ee:	74 15                	je     80102505 <namex+0x11a>
    iput(ip);
801024f0:	83 ec 0c             	sub    $0xc,%esp
801024f3:	ff 75 f4             	push   -0xc(%ebp)
801024f6:	e8 3d f6 ff ff       	call   80101b38 <iput>
801024fb:	83 c4 10             	add    $0x10,%esp
    return 0;
801024fe:	b8 00 00 00 00       	mov    $0x0,%eax
80102503:	eb 03                	jmp    80102508 <namex+0x11d>
  }
  return ip;
80102505:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102508:	c9                   	leave  
80102509:	c3                   	ret    

8010250a <namei>:

struct inode*
namei(char *path)
{
8010250a:	55                   	push   %ebp
8010250b:	89 e5                	mov    %esp,%ebp
8010250d:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102510:	83 ec 04             	sub    $0x4,%esp
80102513:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102516:	50                   	push   %eax
80102517:	6a 00                	push   $0x0
80102519:	ff 75 08             	push   0x8(%ebp)
8010251c:	e8 ca fe ff ff       	call   801023eb <namex>
80102521:	83 c4 10             	add    $0x10,%esp
}
80102524:	c9                   	leave  
80102525:	c3                   	ret    

80102526 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102526:	55                   	push   %ebp
80102527:	89 e5                	mov    %esp,%ebp
80102529:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010252c:	83 ec 04             	sub    $0x4,%esp
8010252f:	ff 75 0c             	push   0xc(%ebp)
80102532:	6a 01                	push   $0x1
80102534:	ff 75 08             	push   0x8(%ebp)
80102537:	e8 af fe ff ff       	call   801023eb <namex>
8010253c:	83 c4 10             	add    $0x10,%esp
}
8010253f:	c9                   	leave  
80102540:	c3                   	ret    

80102541 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102541:	55                   	push   %ebp
80102542:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102544:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102549:	8b 55 08             	mov    0x8(%ebp),%edx
8010254c:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
8010254e:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102553:	8b 40 10             	mov    0x10(%eax),%eax
}
80102556:	5d                   	pop    %ebp
80102557:	c3                   	ret    

80102558 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102558:	55                   	push   %ebp
80102559:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010255b:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102560:	8b 55 08             	mov    0x8(%ebp),%edx
80102563:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102565:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010256a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010256d:	89 50 10             	mov    %edx,0x10(%eax)
}
80102570:	90                   	nop
80102571:	5d                   	pop    %ebp
80102572:	c3                   	ret    

80102573 <ioapicinit>:

void
ioapicinit(void)
{
80102573:	55                   	push   %ebp
80102574:	89 e5                	mov    %esp,%ebp
80102576:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102579:	c7 05 b4 40 19 80 00 	movl   $0xfec00000,0x801940b4
80102580:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102583:	6a 01                	push   $0x1
80102585:	e8 b7 ff ff ff       	call   80102541 <ioapicread>
8010258a:	83 c4 04             	add    $0x4,%esp
8010258d:	c1 e8 10             	shr    $0x10,%eax
80102590:	25 ff 00 00 00       	and    $0xff,%eax
80102595:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102598:	6a 00                	push   $0x0
8010259a:	e8 a2 ff ff ff       	call   80102541 <ioapicread>
8010259f:	83 c4 04             	add    $0x4,%esp
801025a2:	c1 e8 18             	shr    $0x18,%eax
801025a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801025a8:	0f b6 05 44 6d 19 80 	movzbl 0x80196d44,%eax
801025af:	0f b6 c0             	movzbl %al,%eax
801025b2:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801025b5:	74 10                	je     801025c7 <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801025b7:	83 ec 0c             	sub    $0xc,%esp
801025ba:	68 f4 a4 10 80       	push   $0x8010a4f4
801025bf:	e8 30 de ff ff       	call   801003f4 <cprintf>
801025c4:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801025c7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025ce:	eb 3f                	jmp    8010260f <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801025d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025d3:	83 c0 20             	add    $0x20,%eax
801025d6:	0d 00 00 01 00       	or     $0x10000,%eax
801025db:	89 c2                	mov    %eax,%edx
801025dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025e0:	83 c0 08             	add    $0x8,%eax
801025e3:	01 c0                	add    %eax,%eax
801025e5:	83 ec 08             	sub    $0x8,%esp
801025e8:	52                   	push   %edx
801025e9:	50                   	push   %eax
801025ea:	e8 69 ff ff ff       	call   80102558 <ioapicwrite>
801025ef:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
801025f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025f5:	83 c0 08             	add    $0x8,%eax
801025f8:	01 c0                	add    %eax,%eax
801025fa:	83 c0 01             	add    $0x1,%eax
801025fd:	83 ec 08             	sub    $0x8,%esp
80102600:	6a 00                	push   $0x0
80102602:	50                   	push   %eax
80102603:	e8 50 ff ff ff       	call   80102558 <ioapicwrite>
80102608:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
8010260b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010260f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102612:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102615:	7e b9                	jle    801025d0 <ioapicinit+0x5d>
  }
}
80102617:	90                   	nop
80102618:	90                   	nop
80102619:	c9                   	leave  
8010261a:	c3                   	ret    

8010261b <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010261b:	55                   	push   %ebp
8010261c:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
8010261e:	8b 45 08             	mov    0x8(%ebp),%eax
80102621:	83 c0 20             	add    $0x20,%eax
80102624:	89 c2                	mov    %eax,%edx
80102626:	8b 45 08             	mov    0x8(%ebp),%eax
80102629:	83 c0 08             	add    $0x8,%eax
8010262c:	01 c0                	add    %eax,%eax
8010262e:	52                   	push   %edx
8010262f:	50                   	push   %eax
80102630:	e8 23 ff ff ff       	call   80102558 <ioapicwrite>
80102635:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102638:	8b 45 0c             	mov    0xc(%ebp),%eax
8010263b:	c1 e0 18             	shl    $0x18,%eax
8010263e:	89 c2                	mov    %eax,%edx
80102640:	8b 45 08             	mov    0x8(%ebp),%eax
80102643:	83 c0 08             	add    $0x8,%eax
80102646:	01 c0                	add    %eax,%eax
80102648:	83 c0 01             	add    $0x1,%eax
8010264b:	52                   	push   %edx
8010264c:	50                   	push   %eax
8010264d:	e8 06 ff ff ff       	call   80102558 <ioapicwrite>
80102652:	83 c4 08             	add    $0x8,%esp
}
80102655:	90                   	nop
80102656:	c9                   	leave  
80102657:	c3                   	ret    

80102658 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102658:	55                   	push   %ebp
80102659:	89 e5                	mov    %esp,%ebp
8010265b:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
8010265e:	83 ec 08             	sub    $0x8,%esp
80102661:	68 26 a5 10 80       	push   $0x8010a526
80102666:	68 c0 40 19 80       	push   $0x801940c0
8010266b:	e8 09 22 00 00       	call   80104879 <initlock>
80102670:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102673:	c7 05 f4 40 19 80 00 	movl   $0x0,0x801940f4
8010267a:	00 00 00 
  freerange(vstart, vend);
8010267d:	83 ec 08             	sub    $0x8,%esp
80102680:	ff 75 0c             	push   0xc(%ebp)
80102683:	ff 75 08             	push   0x8(%ebp)
80102686:	e8 2a 00 00 00       	call   801026b5 <freerange>
8010268b:	83 c4 10             	add    $0x10,%esp
}
8010268e:	90                   	nop
8010268f:	c9                   	leave  
80102690:	c3                   	ret    

80102691 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102691:	55                   	push   %ebp
80102692:	89 e5                	mov    %esp,%ebp
80102694:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102697:	83 ec 08             	sub    $0x8,%esp
8010269a:	ff 75 0c             	push   0xc(%ebp)
8010269d:	ff 75 08             	push   0x8(%ebp)
801026a0:	e8 10 00 00 00       	call   801026b5 <freerange>
801026a5:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
801026a8:	c7 05 f4 40 19 80 01 	movl   $0x1,0x801940f4
801026af:	00 00 00 
}
801026b2:	90                   	nop
801026b3:	c9                   	leave  
801026b4:	c3                   	ret    

801026b5 <freerange>:

void
freerange(void *vstart, void *vend)
{
801026b5:	55                   	push   %ebp
801026b6:	89 e5                	mov    %esp,%ebp
801026b8:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801026bb:	8b 45 08             	mov    0x8(%ebp),%eax
801026be:	05 ff 0f 00 00       	add    $0xfff,%eax
801026c3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801026c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026cb:	eb 15                	jmp    801026e2 <freerange+0x2d>
    kfree(p);
801026cd:	83 ec 0c             	sub    $0xc,%esp
801026d0:	ff 75 f4             	push   -0xc(%ebp)
801026d3:	e8 1b 00 00 00       	call   801026f3 <kfree>
801026d8:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026db:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801026e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026e5:	05 00 10 00 00       	add    $0x1000,%eax
801026ea:	39 45 0c             	cmp    %eax,0xc(%ebp)
801026ed:	73 de                	jae    801026cd <freerange+0x18>
}
801026ef:	90                   	nop
801026f0:	90                   	nop
801026f1:	c9                   	leave  
801026f2:	c3                   	ret    

801026f3 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
801026f3:	55                   	push   %ebp
801026f4:	89 e5                	mov    %esp,%ebp
801026f6:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
801026f9:	8b 45 08             	mov    0x8(%ebp),%eax
801026fc:	25 ff 0f 00 00       	and    $0xfff,%eax
80102701:	85 c0                	test   %eax,%eax
80102703:	75 18                	jne    8010271d <kfree+0x2a>
80102705:	81 7d 08 00 90 19 80 	cmpl   $0x80199000,0x8(%ebp)
8010270c:	72 0f                	jb     8010271d <kfree+0x2a>
8010270e:	8b 45 08             	mov    0x8(%ebp),%eax
80102711:	05 00 00 00 80       	add    $0x80000000,%eax
80102716:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
8010271b:	76 0d                	jbe    8010272a <kfree+0x37>
    panic("kfree");
8010271d:	83 ec 0c             	sub    $0xc,%esp
80102720:	68 2b a5 10 80       	push   $0x8010a52b
80102725:	e8 7f de ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010272a:	83 ec 04             	sub    $0x4,%esp
8010272d:	68 00 10 00 00       	push   $0x1000
80102732:	6a 01                	push   $0x1
80102734:	ff 75 08             	push   0x8(%ebp)
80102737:	e8 d5 23 00 00       	call   80104b11 <memset>
8010273c:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
8010273f:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102744:	85 c0                	test   %eax,%eax
80102746:	74 10                	je     80102758 <kfree+0x65>
    acquire(&kmem.lock);
80102748:	83 ec 0c             	sub    $0xc,%esp
8010274b:	68 c0 40 19 80       	push   $0x801940c0
80102750:	e8 46 21 00 00       	call   8010489b <acquire>
80102755:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102758:	8b 45 08             	mov    0x8(%ebp),%eax
8010275b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
8010275e:	8b 15 f8 40 19 80    	mov    0x801940f8,%edx
80102764:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102767:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102769:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010276c:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
80102771:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102776:	85 c0                	test   %eax,%eax
80102778:	74 10                	je     8010278a <kfree+0x97>
    release(&kmem.lock);
8010277a:	83 ec 0c             	sub    $0xc,%esp
8010277d:	68 c0 40 19 80       	push   $0x801940c0
80102782:	e8 82 21 00 00       	call   80104909 <release>
80102787:	83 c4 10             	add    $0x10,%esp
}
8010278a:	90                   	nop
8010278b:	c9                   	leave  
8010278c:	c3                   	ret    

8010278d <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
8010278d:	55                   	push   %ebp
8010278e:	89 e5                	mov    %esp,%ebp
80102790:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102793:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102798:	85 c0                	test   %eax,%eax
8010279a:	74 10                	je     801027ac <kalloc+0x1f>
    acquire(&kmem.lock);
8010279c:	83 ec 0c             	sub    $0xc,%esp
8010279f:	68 c0 40 19 80       	push   $0x801940c0
801027a4:	e8 f2 20 00 00       	call   8010489b <acquire>
801027a9:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801027ac:	a1 f8 40 19 80       	mov    0x801940f8,%eax
801027b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801027b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027b8:	74 0a                	je     801027c4 <kalloc+0x37>
    kmem.freelist = r->next;
801027ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027bd:	8b 00                	mov    (%eax),%eax
801027bf:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
801027c4:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027c9:	85 c0                	test   %eax,%eax
801027cb:	74 10                	je     801027dd <kalloc+0x50>
    release(&kmem.lock);
801027cd:	83 ec 0c             	sub    $0xc,%esp
801027d0:	68 c0 40 19 80       	push   $0x801940c0
801027d5:	e8 2f 21 00 00       	call   80104909 <release>
801027da:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801027dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801027e0:	c9                   	leave  
801027e1:	c3                   	ret    

801027e2 <inb>:
{
801027e2:	55                   	push   %ebp
801027e3:	89 e5                	mov    %esp,%ebp
801027e5:	83 ec 14             	sub    $0x14,%esp
801027e8:	8b 45 08             	mov    0x8(%ebp),%eax
801027eb:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801027ef:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801027f3:	89 c2                	mov    %eax,%edx
801027f5:	ec                   	in     (%dx),%al
801027f6:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801027f9:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801027fd:	c9                   	leave  
801027fe:	c3                   	ret    

801027ff <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
801027ff:	55                   	push   %ebp
80102800:	89 e5                	mov    %esp,%ebp
80102802:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102805:	6a 64                	push   $0x64
80102807:	e8 d6 ff ff ff       	call   801027e2 <inb>
8010280c:	83 c4 04             	add    $0x4,%esp
8010280f:	0f b6 c0             	movzbl %al,%eax
80102812:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102815:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102818:	83 e0 01             	and    $0x1,%eax
8010281b:	85 c0                	test   %eax,%eax
8010281d:	75 0a                	jne    80102829 <kbdgetc+0x2a>
    return -1;
8010281f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102824:	e9 23 01 00 00       	jmp    8010294c <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102829:	6a 60                	push   $0x60
8010282b:	e8 b2 ff ff ff       	call   801027e2 <inb>
80102830:	83 c4 04             	add    $0x4,%esp
80102833:	0f b6 c0             	movzbl %al,%eax
80102836:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102839:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102840:	75 17                	jne    80102859 <kbdgetc+0x5a>
    shift |= E0ESC;
80102842:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102847:	83 c8 40             	or     $0x40,%eax
8010284a:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
8010284f:	b8 00 00 00 00       	mov    $0x0,%eax
80102854:	e9 f3 00 00 00       	jmp    8010294c <kbdgetc+0x14d>
  } else if(data & 0x80){
80102859:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010285c:	25 80 00 00 00       	and    $0x80,%eax
80102861:	85 c0                	test   %eax,%eax
80102863:	74 45                	je     801028aa <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102865:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010286a:	83 e0 40             	and    $0x40,%eax
8010286d:	85 c0                	test   %eax,%eax
8010286f:	75 08                	jne    80102879 <kbdgetc+0x7a>
80102871:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102874:	83 e0 7f             	and    $0x7f,%eax
80102877:	eb 03                	jmp    8010287c <kbdgetc+0x7d>
80102879:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010287c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
8010287f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102882:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102887:	0f b6 00             	movzbl (%eax),%eax
8010288a:	83 c8 40             	or     $0x40,%eax
8010288d:	0f b6 c0             	movzbl %al,%eax
80102890:	f7 d0                	not    %eax
80102892:	89 c2                	mov    %eax,%edx
80102894:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102899:	21 d0                	and    %edx,%eax
8010289b:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
801028a0:	b8 00 00 00 00       	mov    $0x0,%eax
801028a5:	e9 a2 00 00 00       	jmp    8010294c <kbdgetc+0x14d>
  } else if(shift & E0ESC){
801028aa:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028af:	83 e0 40             	and    $0x40,%eax
801028b2:	85 c0                	test   %eax,%eax
801028b4:	74 14                	je     801028ca <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801028b6:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801028bd:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028c2:	83 e0 bf             	and    $0xffffffbf,%eax
801028c5:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  }

  shift |= shiftcode[data];
801028ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028cd:	05 20 d0 10 80       	add    $0x8010d020,%eax
801028d2:	0f b6 00             	movzbl (%eax),%eax
801028d5:	0f b6 d0             	movzbl %al,%edx
801028d8:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028dd:	09 d0                	or     %edx,%eax
801028df:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  shift ^= togglecode[data];
801028e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028e7:	05 20 d1 10 80       	add    $0x8010d120,%eax
801028ec:	0f b6 00             	movzbl (%eax),%eax
801028ef:	0f b6 d0             	movzbl %al,%edx
801028f2:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028f7:	31 d0                	xor    %edx,%eax
801028f9:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  c = charcode[shift & (CTL | SHIFT)][data];
801028fe:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102903:	83 e0 03             	and    $0x3,%eax
80102906:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
8010290d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102910:	01 d0                	add    %edx,%eax
80102912:	0f b6 00             	movzbl (%eax),%eax
80102915:	0f b6 c0             	movzbl %al,%eax
80102918:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
8010291b:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102920:	83 e0 08             	and    $0x8,%eax
80102923:	85 c0                	test   %eax,%eax
80102925:	74 22                	je     80102949 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102927:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
8010292b:	76 0c                	jbe    80102939 <kbdgetc+0x13a>
8010292d:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102931:	77 06                	ja     80102939 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102933:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102937:	eb 10                	jmp    80102949 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102939:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
8010293d:	76 0a                	jbe    80102949 <kbdgetc+0x14a>
8010293f:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102943:	77 04                	ja     80102949 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102945:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102949:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010294c:	c9                   	leave  
8010294d:	c3                   	ret    

8010294e <kbdintr>:

void
kbdintr(void)
{
8010294e:	55                   	push   %ebp
8010294f:	89 e5                	mov    %esp,%ebp
80102951:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102954:	83 ec 0c             	sub    $0xc,%esp
80102957:	68 ff 27 10 80       	push   $0x801027ff
8010295c:	e8 75 de ff ff       	call   801007d6 <consoleintr>
80102961:	83 c4 10             	add    $0x10,%esp
}
80102964:	90                   	nop
80102965:	c9                   	leave  
80102966:	c3                   	ret    

80102967 <inb>:
{
80102967:	55                   	push   %ebp
80102968:	89 e5                	mov    %esp,%ebp
8010296a:	83 ec 14             	sub    $0x14,%esp
8010296d:	8b 45 08             	mov    0x8(%ebp),%eax
80102970:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102974:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102978:	89 c2                	mov    %eax,%edx
8010297a:	ec                   	in     (%dx),%al
8010297b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010297e:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102982:	c9                   	leave  
80102983:	c3                   	ret    

80102984 <outb>:
{
80102984:	55                   	push   %ebp
80102985:	89 e5                	mov    %esp,%ebp
80102987:	83 ec 08             	sub    $0x8,%esp
8010298a:	8b 45 08             	mov    0x8(%ebp),%eax
8010298d:	8b 55 0c             	mov    0xc(%ebp),%edx
80102990:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102994:	89 d0                	mov    %edx,%eax
80102996:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102999:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010299d:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801029a1:	ee                   	out    %al,(%dx)
}
801029a2:	90                   	nop
801029a3:	c9                   	leave  
801029a4:	c3                   	ret    

801029a5 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
801029a5:	55                   	push   %ebp
801029a6:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801029a8:	8b 15 00 41 19 80    	mov    0x80194100,%edx
801029ae:	8b 45 08             	mov    0x8(%ebp),%eax
801029b1:	c1 e0 02             	shl    $0x2,%eax
801029b4:	01 c2                	add    %eax,%edx
801029b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801029b9:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801029bb:	a1 00 41 19 80       	mov    0x80194100,%eax
801029c0:	83 c0 20             	add    $0x20,%eax
801029c3:	8b 00                	mov    (%eax),%eax
}
801029c5:	90                   	nop
801029c6:	5d                   	pop    %ebp
801029c7:	c3                   	ret    

801029c8 <lapicinit>:

void
lapicinit(void)
{
801029c8:	55                   	push   %ebp
801029c9:	89 e5                	mov    %esp,%ebp
  if(!lapic)
801029cb:	a1 00 41 19 80       	mov    0x80194100,%eax
801029d0:	85 c0                	test   %eax,%eax
801029d2:	0f 84 0c 01 00 00    	je     80102ae4 <lapicinit+0x11c>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801029d8:	68 3f 01 00 00       	push   $0x13f
801029dd:	6a 3c                	push   $0x3c
801029df:	e8 c1 ff ff ff       	call   801029a5 <lapicw>
801029e4:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801029e7:	6a 0b                	push   $0xb
801029e9:	68 f8 00 00 00       	push   $0xf8
801029ee:	e8 b2 ff ff ff       	call   801029a5 <lapicw>
801029f3:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801029f6:	68 20 00 02 00       	push   $0x20020
801029fb:	68 c8 00 00 00       	push   $0xc8
80102a00:	e8 a0 ff ff ff       	call   801029a5 <lapicw>
80102a05:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102a08:	68 80 96 98 00       	push   $0x989680
80102a0d:	68 e0 00 00 00       	push   $0xe0
80102a12:	e8 8e ff ff ff       	call   801029a5 <lapicw>
80102a17:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102a1a:	68 00 00 01 00       	push   $0x10000
80102a1f:	68 d4 00 00 00       	push   $0xd4
80102a24:	e8 7c ff ff ff       	call   801029a5 <lapicw>
80102a29:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102a2c:	68 00 00 01 00       	push   $0x10000
80102a31:	68 d8 00 00 00       	push   $0xd8
80102a36:	e8 6a ff ff ff       	call   801029a5 <lapicw>
80102a3b:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102a3e:	a1 00 41 19 80       	mov    0x80194100,%eax
80102a43:	83 c0 30             	add    $0x30,%eax
80102a46:	8b 00                	mov    (%eax),%eax
80102a48:	c1 e8 10             	shr    $0x10,%eax
80102a4b:	25 fc 00 00 00       	and    $0xfc,%eax
80102a50:	85 c0                	test   %eax,%eax
80102a52:	74 12                	je     80102a66 <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80102a54:	68 00 00 01 00       	push   $0x10000
80102a59:	68 d0 00 00 00       	push   $0xd0
80102a5e:	e8 42 ff ff ff       	call   801029a5 <lapicw>
80102a63:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102a66:	6a 33                	push   $0x33
80102a68:	68 dc 00 00 00       	push   $0xdc
80102a6d:	e8 33 ff ff ff       	call   801029a5 <lapicw>
80102a72:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102a75:	6a 00                	push   $0x0
80102a77:	68 a0 00 00 00       	push   $0xa0
80102a7c:	e8 24 ff ff ff       	call   801029a5 <lapicw>
80102a81:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102a84:	6a 00                	push   $0x0
80102a86:	68 a0 00 00 00       	push   $0xa0
80102a8b:	e8 15 ff ff ff       	call   801029a5 <lapicw>
80102a90:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102a93:	6a 00                	push   $0x0
80102a95:	6a 2c                	push   $0x2c
80102a97:	e8 09 ff ff ff       	call   801029a5 <lapicw>
80102a9c:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102a9f:	6a 00                	push   $0x0
80102aa1:	68 c4 00 00 00       	push   $0xc4
80102aa6:	e8 fa fe ff ff       	call   801029a5 <lapicw>
80102aab:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102aae:	68 00 85 08 00       	push   $0x88500
80102ab3:	68 c0 00 00 00       	push   $0xc0
80102ab8:	e8 e8 fe ff ff       	call   801029a5 <lapicw>
80102abd:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102ac0:	90                   	nop
80102ac1:	a1 00 41 19 80       	mov    0x80194100,%eax
80102ac6:	05 00 03 00 00       	add    $0x300,%eax
80102acb:	8b 00                	mov    (%eax),%eax
80102acd:	25 00 10 00 00       	and    $0x1000,%eax
80102ad2:	85 c0                	test   %eax,%eax
80102ad4:	75 eb                	jne    80102ac1 <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102ad6:	6a 00                	push   $0x0
80102ad8:	6a 20                	push   $0x20
80102ada:	e8 c6 fe ff ff       	call   801029a5 <lapicw>
80102adf:	83 c4 08             	add    $0x8,%esp
80102ae2:	eb 01                	jmp    80102ae5 <lapicinit+0x11d>
    return;
80102ae4:	90                   	nop
}
80102ae5:	c9                   	leave  
80102ae6:	c3                   	ret    

80102ae7 <lapicid>:

int
lapicid(void)
{
80102ae7:	55                   	push   %ebp
80102ae8:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102aea:	a1 00 41 19 80       	mov    0x80194100,%eax
80102aef:	85 c0                	test   %eax,%eax
80102af1:	75 07                	jne    80102afa <lapicid+0x13>
    return 0;
80102af3:	b8 00 00 00 00       	mov    $0x0,%eax
80102af8:	eb 0d                	jmp    80102b07 <lapicid+0x20>
  }
  return lapic[ID] >> 24;
80102afa:	a1 00 41 19 80       	mov    0x80194100,%eax
80102aff:	83 c0 20             	add    $0x20,%eax
80102b02:	8b 00                	mov    (%eax),%eax
80102b04:	c1 e8 18             	shr    $0x18,%eax
}
80102b07:	5d                   	pop    %ebp
80102b08:	c3                   	ret    

80102b09 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102b09:	55                   	push   %ebp
80102b0a:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102b0c:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b11:	85 c0                	test   %eax,%eax
80102b13:	74 0c                	je     80102b21 <lapiceoi+0x18>
    lapicw(EOI, 0);
80102b15:	6a 00                	push   $0x0
80102b17:	6a 2c                	push   $0x2c
80102b19:	e8 87 fe ff ff       	call   801029a5 <lapicw>
80102b1e:	83 c4 08             	add    $0x8,%esp
}
80102b21:	90                   	nop
80102b22:	c9                   	leave  
80102b23:	c3                   	ret    

80102b24 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102b24:	55                   	push   %ebp
80102b25:	89 e5                	mov    %esp,%ebp
}
80102b27:	90                   	nop
80102b28:	5d                   	pop    %ebp
80102b29:	c3                   	ret    

80102b2a <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102b2a:	55                   	push   %ebp
80102b2b:	89 e5                	mov    %esp,%ebp
80102b2d:	83 ec 14             	sub    $0x14,%esp
80102b30:	8b 45 08             	mov    0x8(%ebp),%eax
80102b33:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102b36:	6a 0f                	push   $0xf
80102b38:	6a 70                	push   $0x70
80102b3a:	e8 45 fe ff ff       	call   80102984 <outb>
80102b3f:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102b42:	6a 0a                	push   $0xa
80102b44:	6a 71                	push   $0x71
80102b46:	e8 39 fe ff ff       	call   80102984 <outb>
80102b4b:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102b4e:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102b55:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b58:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102b5d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b60:	c1 e8 04             	shr    $0x4,%eax
80102b63:	89 c2                	mov    %eax,%edx
80102b65:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b68:	83 c0 02             	add    $0x2,%eax
80102b6b:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102b6e:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102b72:	c1 e0 18             	shl    $0x18,%eax
80102b75:	50                   	push   %eax
80102b76:	68 c4 00 00 00       	push   $0xc4
80102b7b:	e8 25 fe ff ff       	call   801029a5 <lapicw>
80102b80:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102b83:	68 00 c5 00 00       	push   $0xc500
80102b88:	68 c0 00 00 00       	push   $0xc0
80102b8d:	e8 13 fe ff ff       	call   801029a5 <lapicw>
80102b92:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102b95:	68 c8 00 00 00       	push   $0xc8
80102b9a:	e8 85 ff ff ff       	call   80102b24 <microdelay>
80102b9f:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102ba2:	68 00 85 00 00       	push   $0x8500
80102ba7:	68 c0 00 00 00       	push   $0xc0
80102bac:	e8 f4 fd ff ff       	call   801029a5 <lapicw>
80102bb1:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102bb4:	6a 64                	push   $0x64
80102bb6:	e8 69 ff ff ff       	call   80102b24 <microdelay>
80102bbb:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102bbe:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102bc5:	eb 3d                	jmp    80102c04 <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
80102bc7:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102bcb:	c1 e0 18             	shl    $0x18,%eax
80102bce:	50                   	push   %eax
80102bcf:	68 c4 00 00 00       	push   $0xc4
80102bd4:	e8 cc fd ff ff       	call   801029a5 <lapicw>
80102bd9:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102bdc:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bdf:	c1 e8 0c             	shr    $0xc,%eax
80102be2:	80 cc 06             	or     $0x6,%ah
80102be5:	50                   	push   %eax
80102be6:	68 c0 00 00 00       	push   $0xc0
80102beb:	e8 b5 fd ff ff       	call   801029a5 <lapicw>
80102bf0:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102bf3:	68 c8 00 00 00       	push   $0xc8
80102bf8:	e8 27 ff ff ff       	call   80102b24 <microdelay>
80102bfd:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102c00:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102c04:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102c08:	7e bd                	jle    80102bc7 <lapicstartap+0x9d>
  }
}
80102c0a:	90                   	nop
80102c0b:	90                   	nop
80102c0c:	c9                   	leave  
80102c0d:	c3                   	ret    

80102c0e <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102c0e:	55                   	push   %ebp
80102c0f:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102c11:	8b 45 08             	mov    0x8(%ebp),%eax
80102c14:	0f b6 c0             	movzbl %al,%eax
80102c17:	50                   	push   %eax
80102c18:	6a 70                	push   $0x70
80102c1a:	e8 65 fd ff ff       	call   80102984 <outb>
80102c1f:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102c22:	68 c8 00 00 00       	push   $0xc8
80102c27:	e8 f8 fe ff ff       	call   80102b24 <microdelay>
80102c2c:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102c2f:	6a 71                	push   $0x71
80102c31:	e8 31 fd ff ff       	call   80102967 <inb>
80102c36:	83 c4 04             	add    $0x4,%esp
80102c39:	0f b6 c0             	movzbl %al,%eax
}
80102c3c:	c9                   	leave  
80102c3d:	c3                   	ret    

80102c3e <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102c3e:	55                   	push   %ebp
80102c3f:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102c41:	6a 00                	push   $0x0
80102c43:	e8 c6 ff ff ff       	call   80102c0e <cmos_read>
80102c48:	83 c4 04             	add    $0x4,%esp
80102c4b:	8b 55 08             	mov    0x8(%ebp),%edx
80102c4e:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102c50:	6a 02                	push   $0x2
80102c52:	e8 b7 ff ff ff       	call   80102c0e <cmos_read>
80102c57:	83 c4 04             	add    $0x4,%esp
80102c5a:	8b 55 08             	mov    0x8(%ebp),%edx
80102c5d:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102c60:	6a 04                	push   $0x4
80102c62:	e8 a7 ff ff ff       	call   80102c0e <cmos_read>
80102c67:	83 c4 04             	add    $0x4,%esp
80102c6a:	8b 55 08             	mov    0x8(%ebp),%edx
80102c6d:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102c70:	6a 07                	push   $0x7
80102c72:	e8 97 ff ff ff       	call   80102c0e <cmos_read>
80102c77:	83 c4 04             	add    $0x4,%esp
80102c7a:	8b 55 08             	mov    0x8(%ebp),%edx
80102c7d:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102c80:	6a 08                	push   $0x8
80102c82:	e8 87 ff ff ff       	call   80102c0e <cmos_read>
80102c87:	83 c4 04             	add    $0x4,%esp
80102c8a:	8b 55 08             	mov    0x8(%ebp),%edx
80102c8d:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102c90:	6a 09                	push   $0x9
80102c92:	e8 77 ff ff ff       	call   80102c0e <cmos_read>
80102c97:	83 c4 04             	add    $0x4,%esp
80102c9a:	8b 55 08             	mov    0x8(%ebp),%edx
80102c9d:	89 42 14             	mov    %eax,0x14(%edx)
}
80102ca0:	90                   	nop
80102ca1:	c9                   	leave  
80102ca2:	c3                   	ret    

80102ca3 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102ca3:	55                   	push   %ebp
80102ca4:	89 e5                	mov    %esp,%ebp
80102ca6:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102ca9:	6a 0b                	push   $0xb
80102cab:	e8 5e ff ff ff       	call   80102c0e <cmos_read>
80102cb0:	83 c4 04             	add    $0x4,%esp
80102cb3:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cb9:	83 e0 04             	and    $0x4,%eax
80102cbc:	85 c0                	test   %eax,%eax
80102cbe:	0f 94 c0             	sete   %al
80102cc1:	0f b6 c0             	movzbl %al,%eax
80102cc4:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102cc7:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102cca:	50                   	push   %eax
80102ccb:	e8 6e ff ff ff       	call   80102c3e <fill_rtcdate>
80102cd0:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102cd3:	6a 0a                	push   $0xa
80102cd5:	e8 34 ff ff ff       	call   80102c0e <cmos_read>
80102cda:	83 c4 04             	add    $0x4,%esp
80102cdd:	25 80 00 00 00       	and    $0x80,%eax
80102ce2:	85 c0                	test   %eax,%eax
80102ce4:	75 27                	jne    80102d0d <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80102ce6:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102ce9:	50                   	push   %eax
80102cea:	e8 4f ff ff ff       	call   80102c3e <fill_rtcdate>
80102cef:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102cf2:	83 ec 04             	sub    $0x4,%esp
80102cf5:	6a 18                	push   $0x18
80102cf7:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102cfa:	50                   	push   %eax
80102cfb:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102cfe:	50                   	push   %eax
80102cff:	e8 74 1e 00 00       	call   80104b78 <memcmp>
80102d04:	83 c4 10             	add    $0x10,%esp
80102d07:	85 c0                	test   %eax,%eax
80102d09:	74 05                	je     80102d10 <cmostime+0x6d>
80102d0b:	eb ba                	jmp    80102cc7 <cmostime+0x24>
        continue;
80102d0d:	90                   	nop
    fill_rtcdate(&t1);
80102d0e:	eb b7                	jmp    80102cc7 <cmostime+0x24>
      break;
80102d10:	90                   	nop
  }

  // convert
  if(bcd) {
80102d11:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102d15:	0f 84 b4 00 00 00    	je     80102dcf <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102d1b:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d1e:	c1 e8 04             	shr    $0x4,%eax
80102d21:	89 c2                	mov    %eax,%edx
80102d23:	89 d0                	mov    %edx,%eax
80102d25:	c1 e0 02             	shl    $0x2,%eax
80102d28:	01 d0                	add    %edx,%eax
80102d2a:	01 c0                	add    %eax,%eax
80102d2c:	89 c2                	mov    %eax,%edx
80102d2e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d31:	83 e0 0f             	and    $0xf,%eax
80102d34:	01 d0                	add    %edx,%eax
80102d36:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102d39:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d3c:	c1 e8 04             	shr    $0x4,%eax
80102d3f:	89 c2                	mov    %eax,%edx
80102d41:	89 d0                	mov    %edx,%eax
80102d43:	c1 e0 02             	shl    $0x2,%eax
80102d46:	01 d0                	add    %edx,%eax
80102d48:	01 c0                	add    %eax,%eax
80102d4a:	89 c2                	mov    %eax,%edx
80102d4c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d4f:	83 e0 0f             	and    $0xf,%eax
80102d52:	01 d0                	add    %edx,%eax
80102d54:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102d57:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d5a:	c1 e8 04             	shr    $0x4,%eax
80102d5d:	89 c2                	mov    %eax,%edx
80102d5f:	89 d0                	mov    %edx,%eax
80102d61:	c1 e0 02             	shl    $0x2,%eax
80102d64:	01 d0                	add    %edx,%eax
80102d66:	01 c0                	add    %eax,%eax
80102d68:	89 c2                	mov    %eax,%edx
80102d6a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d6d:	83 e0 0f             	and    $0xf,%eax
80102d70:	01 d0                	add    %edx,%eax
80102d72:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102d75:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d78:	c1 e8 04             	shr    $0x4,%eax
80102d7b:	89 c2                	mov    %eax,%edx
80102d7d:	89 d0                	mov    %edx,%eax
80102d7f:	c1 e0 02             	shl    $0x2,%eax
80102d82:	01 d0                	add    %edx,%eax
80102d84:	01 c0                	add    %eax,%eax
80102d86:	89 c2                	mov    %eax,%edx
80102d88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d8b:	83 e0 0f             	and    $0xf,%eax
80102d8e:	01 d0                	add    %edx,%eax
80102d90:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102d93:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102d96:	c1 e8 04             	shr    $0x4,%eax
80102d99:	89 c2                	mov    %eax,%edx
80102d9b:	89 d0                	mov    %edx,%eax
80102d9d:	c1 e0 02             	shl    $0x2,%eax
80102da0:	01 d0                	add    %edx,%eax
80102da2:	01 c0                	add    %eax,%eax
80102da4:	89 c2                	mov    %eax,%edx
80102da6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102da9:	83 e0 0f             	and    $0xf,%eax
80102dac:	01 d0                	add    %edx,%eax
80102dae:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102db1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102db4:	c1 e8 04             	shr    $0x4,%eax
80102db7:	89 c2                	mov    %eax,%edx
80102db9:	89 d0                	mov    %edx,%eax
80102dbb:	c1 e0 02             	shl    $0x2,%eax
80102dbe:	01 d0                	add    %edx,%eax
80102dc0:	01 c0                	add    %eax,%eax
80102dc2:	89 c2                	mov    %eax,%edx
80102dc4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dc7:	83 e0 0f             	and    $0xf,%eax
80102dca:	01 d0                	add    %edx,%eax
80102dcc:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102dcf:	8b 45 08             	mov    0x8(%ebp),%eax
80102dd2:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102dd5:	89 10                	mov    %edx,(%eax)
80102dd7:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102dda:	89 50 04             	mov    %edx,0x4(%eax)
80102ddd:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102de0:	89 50 08             	mov    %edx,0x8(%eax)
80102de3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102de6:	89 50 0c             	mov    %edx,0xc(%eax)
80102de9:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102dec:	89 50 10             	mov    %edx,0x10(%eax)
80102def:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102df2:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102df5:	8b 45 08             	mov    0x8(%ebp),%eax
80102df8:	8b 40 14             	mov    0x14(%eax),%eax
80102dfb:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102e01:	8b 45 08             	mov    0x8(%ebp),%eax
80102e04:	89 50 14             	mov    %edx,0x14(%eax)
}
80102e07:	90                   	nop
80102e08:	c9                   	leave  
80102e09:	c3                   	ret    

80102e0a <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102e0a:	55                   	push   %ebp
80102e0b:	89 e5                	mov    %esp,%ebp
80102e0d:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102e10:	83 ec 08             	sub    $0x8,%esp
80102e13:	68 31 a5 10 80       	push   $0x8010a531
80102e18:	68 20 41 19 80       	push   $0x80194120
80102e1d:	e8 57 1a 00 00       	call   80104879 <initlock>
80102e22:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102e25:	83 ec 08             	sub    $0x8,%esp
80102e28:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102e2b:	50                   	push   %eax
80102e2c:	ff 75 08             	push   0x8(%ebp)
80102e2f:	e8 87 e5 ff ff       	call   801013bb <readsb>
80102e34:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102e37:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102e3a:	a3 54 41 19 80       	mov    %eax,0x80194154
  log.size = sb.nlog;
80102e3f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102e42:	a3 58 41 19 80       	mov    %eax,0x80194158
  log.dev = dev;
80102e47:	8b 45 08             	mov    0x8(%ebp),%eax
80102e4a:	a3 64 41 19 80       	mov    %eax,0x80194164
  recover_from_log();
80102e4f:	e8 b3 01 00 00       	call   80103007 <recover_from_log>
}
80102e54:	90                   	nop
80102e55:	c9                   	leave  
80102e56:	c3                   	ret    

80102e57 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102e57:	55                   	push   %ebp
80102e58:	89 e5                	mov    %esp,%ebp
80102e5a:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102e5d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e64:	e9 95 00 00 00       	jmp    80102efe <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102e69:	8b 15 54 41 19 80    	mov    0x80194154,%edx
80102e6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e72:	01 d0                	add    %edx,%eax
80102e74:	83 c0 01             	add    $0x1,%eax
80102e77:	89 c2                	mov    %eax,%edx
80102e79:	a1 64 41 19 80       	mov    0x80194164,%eax
80102e7e:	83 ec 08             	sub    $0x8,%esp
80102e81:	52                   	push   %edx
80102e82:	50                   	push   %eax
80102e83:	e8 79 d3 ff ff       	call   80100201 <bread>
80102e88:	83 c4 10             	add    $0x10,%esp
80102e8b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102e8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e91:	83 c0 10             	add    $0x10,%eax
80102e94:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
80102e9b:	89 c2                	mov    %eax,%edx
80102e9d:	a1 64 41 19 80       	mov    0x80194164,%eax
80102ea2:	83 ec 08             	sub    $0x8,%esp
80102ea5:	52                   	push   %edx
80102ea6:	50                   	push   %eax
80102ea7:	e8 55 d3 ff ff       	call   80100201 <bread>
80102eac:	83 c4 10             	add    $0x10,%esp
80102eaf:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102eb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102eb5:	8d 50 5c             	lea    0x5c(%eax),%edx
80102eb8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ebb:	83 c0 5c             	add    $0x5c,%eax
80102ebe:	83 ec 04             	sub    $0x4,%esp
80102ec1:	68 00 02 00 00       	push   $0x200
80102ec6:	52                   	push   %edx
80102ec7:	50                   	push   %eax
80102ec8:	e8 03 1d 00 00       	call   80104bd0 <memmove>
80102ecd:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80102ed0:	83 ec 0c             	sub    $0xc,%esp
80102ed3:	ff 75 ec             	push   -0x14(%ebp)
80102ed6:	e8 5f d3 ff ff       	call   8010023a <bwrite>
80102edb:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80102ede:	83 ec 0c             	sub    $0xc,%esp
80102ee1:	ff 75 f0             	push   -0x10(%ebp)
80102ee4:	e8 9a d3 ff ff       	call   80100283 <brelse>
80102ee9:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80102eec:	83 ec 0c             	sub    $0xc,%esp
80102eef:	ff 75 ec             	push   -0x14(%ebp)
80102ef2:	e8 8c d3 ff ff       	call   80100283 <brelse>
80102ef7:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80102efa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102efe:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f03:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f06:	0f 8c 5d ff ff ff    	jl     80102e69 <install_trans+0x12>
  }
}
80102f0c:	90                   	nop
80102f0d:	90                   	nop
80102f0e:	c9                   	leave  
80102f0f:	c3                   	ret    

80102f10 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80102f10:	55                   	push   %ebp
80102f11:	89 e5                	mov    %esp,%ebp
80102f13:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f16:	a1 54 41 19 80       	mov    0x80194154,%eax
80102f1b:	89 c2                	mov    %eax,%edx
80102f1d:	a1 64 41 19 80       	mov    0x80194164,%eax
80102f22:	83 ec 08             	sub    $0x8,%esp
80102f25:	52                   	push   %edx
80102f26:	50                   	push   %eax
80102f27:	e8 d5 d2 ff ff       	call   80100201 <bread>
80102f2c:	83 c4 10             	add    $0x10,%esp
80102f2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80102f32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f35:	83 c0 5c             	add    $0x5c,%eax
80102f38:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80102f3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f3e:	8b 00                	mov    (%eax),%eax
80102f40:	a3 68 41 19 80       	mov    %eax,0x80194168
  for (i = 0; i < log.lh.n; i++) {
80102f45:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102f4c:	eb 1b                	jmp    80102f69 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80102f4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f51:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f54:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80102f58:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f5b:	83 c2 10             	add    $0x10,%edx
80102f5e:	89 04 95 2c 41 19 80 	mov    %eax,-0x7fe6bed4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102f65:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f69:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f6e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f71:	7c db                	jl     80102f4e <read_head+0x3e>
  }
  brelse(buf);
80102f73:	83 ec 0c             	sub    $0xc,%esp
80102f76:	ff 75 f0             	push   -0x10(%ebp)
80102f79:	e8 05 d3 ff ff       	call   80100283 <brelse>
80102f7e:	83 c4 10             	add    $0x10,%esp
}
80102f81:	90                   	nop
80102f82:	c9                   	leave  
80102f83:	c3                   	ret    

80102f84 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102f84:	55                   	push   %ebp
80102f85:	89 e5                	mov    %esp,%ebp
80102f87:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f8a:	a1 54 41 19 80       	mov    0x80194154,%eax
80102f8f:	89 c2                	mov    %eax,%edx
80102f91:	a1 64 41 19 80       	mov    0x80194164,%eax
80102f96:	83 ec 08             	sub    $0x8,%esp
80102f99:	52                   	push   %edx
80102f9a:	50                   	push   %eax
80102f9b:	e8 61 d2 ff ff       	call   80100201 <bread>
80102fa0:	83 c4 10             	add    $0x10,%esp
80102fa3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80102fa6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fa9:	83 c0 5c             	add    $0x5c,%eax
80102fac:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80102faf:	8b 15 68 41 19 80    	mov    0x80194168,%edx
80102fb5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fb8:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102fba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102fc1:	eb 1b                	jmp    80102fde <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80102fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fc6:	83 c0 10             	add    $0x10,%eax
80102fc9:	8b 0c 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%ecx
80102fd0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fd3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102fd6:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102fda:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102fde:	a1 68 41 19 80       	mov    0x80194168,%eax
80102fe3:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102fe6:	7c db                	jl     80102fc3 <write_head+0x3f>
  }
  bwrite(buf);
80102fe8:	83 ec 0c             	sub    $0xc,%esp
80102feb:	ff 75 f0             	push   -0x10(%ebp)
80102fee:	e8 47 d2 ff ff       	call   8010023a <bwrite>
80102ff3:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80102ff6:	83 ec 0c             	sub    $0xc,%esp
80102ff9:	ff 75 f0             	push   -0x10(%ebp)
80102ffc:	e8 82 d2 ff ff       	call   80100283 <brelse>
80103001:	83 c4 10             	add    $0x10,%esp
}
80103004:	90                   	nop
80103005:	c9                   	leave  
80103006:	c3                   	ret    

80103007 <recover_from_log>:

static void
recover_from_log(void)
{
80103007:	55                   	push   %ebp
80103008:	89 e5                	mov    %esp,%ebp
8010300a:	83 ec 08             	sub    $0x8,%esp
  read_head();
8010300d:	e8 fe fe ff ff       	call   80102f10 <read_head>
  install_trans(); // if committed, copy from log to disk
80103012:	e8 40 fe ff ff       	call   80102e57 <install_trans>
  log.lh.n = 0;
80103017:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
8010301e:	00 00 00 
  write_head(); // clear the log
80103021:	e8 5e ff ff ff       	call   80102f84 <write_head>
}
80103026:	90                   	nop
80103027:	c9                   	leave  
80103028:	c3                   	ret    

80103029 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103029:	55                   	push   %ebp
8010302a:	89 e5                	mov    %esp,%ebp
8010302c:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
8010302f:	83 ec 0c             	sub    $0xc,%esp
80103032:	68 20 41 19 80       	push   $0x80194120
80103037:	e8 5f 18 00 00       	call   8010489b <acquire>
8010303c:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
8010303f:	a1 60 41 19 80       	mov    0x80194160,%eax
80103044:	85 c0                	test   %eax,%eax
80103046:	74 17                	je     8010305f <begin_op+0x36>
      sleep(&log, &log.lock);
80103048:	83 ec 08             	sub    $0x8,%esp
8010304b:	68 20 41 19 80       	push   $0x80194120
80103050:	68 20 41 19 80       	push   $0x80194120
80103055:	e8 78 12 00 00       	call   801042d2 <sleep>
8010305a:	83 c4 10             	add    $0x10,%esp
8010305d:	eb e0                	jmp    8010303f <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010305f:	8b 0d 68 41 19 80    	mov    0x80194168,%ecx
80103065:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010306a:	8d 50 01             	lea    0x1(%eax),%edx
8010306d:	89 d0                	mov    %edx,%eax
8010306f:	c1 e0 02             	shl    $0x2,%eax
80103072:	01 d0                	add    %edx,%eax
80103074:	01 c0                	add    %eax,%eax
80103076:	01 c8                	add    %ecx,%eax
80103078:	83 f8 1e             	cmp    $0x1e,%eax
8010307b:	7e 17                	jle    80103094 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
8010307d:	83 ec 08             	sub    $0x8,%esp
80103080:	68 20 41 19 80       	push   $0x80194120
80103085:	68 20 41 19 80       	push   $0x80194120
8010308a:	e8 43 12 00 00       	call   801042d2 <sleep>
8010308f:	83 c4 10             	add    $0x10,%esp
80103092:	eb ab                	jmp    8010303f <begin_op+0x16>
    } else {
      log.outstanding += 1;
80103094:	a1 5c 41 19 80       	mov    0x8019415c,%eax
80103099:	83 c0 01             	add    $0x1,%eax
8010309c:	a3 5c 41 19 80       	mov    %eax,0x8019415c
      release(&log.lock);
801030a1:	83 ec 0c             	sub    $0xc,%esp
801030a4:	68 20 41 19 80       	push   $0x80194120
801030a9:	e8 5b 18 00 00       	call   80104909 <release>
801030ae:	83 c4 10             	add    $0x10,%esp
      break;
801030b1:	90                   	nop
    }
  }
}
801030b2:	90                   	nop
801030b3:	c9                   	leave  
801030b4:	c3                   	ret    

801030b5 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801030b5:	55                   	push   %ebp
801030b6:	89 e5                	mov    %esp,%ebp
801030b8:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801030bb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801030c2:	83 ec 0c             	sub    $0xc,%esp
801030c5:	68 20 41 19 80       	push   $0x80194120
801030ca:	e8 cc 17 00 00       	call   8010489b <acquire>
801030cf:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801030d2:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030d7:	83 e8 01             	sub    $0x1,%eax
801030da:	a3 5c 41 19 80       	mov    %eax,0x8019415c
  if(log.committing)
801030df:	a1 60 41 19 80       	mov    0x80194160,%eax
801030e4:	85 c0                	test   %eax,%eax
801030e6:	74 0d                	je     801030f5 <end_op+0x40>
    panic("log.committing");
801030e8:	83 ec 0c             	sub    $0xc,%esp
801030eb:	68 35 a5 10 80       	push   $0x8010a535
801030f0:	e8 b4 d4 ff ff       	call   801005a9 <panic>
  if(log.outstanding == 0){
801030f5:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030fa:	85 c0                	test   %eax,%eax
801030fc:	75 13                	jne    80103111 <end_op+0x5c>
    do_commit = 1;
801030fe:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103105:	c7 05 60 41 19 80 01 	movl   $0x1,0x80194160
8010310c:	00 00 00 
8010310f:	eb 10                	jmp    80103121 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103111:	83 ec 0c             	sub    $0xc,%esp
80103114:	68 20 41 19 80       	push   $0x80194120
80103119:	e8 9b 12 00 00       	call   801043b9 <wakeup>
8010311e:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103121:	83 ec 0c             	sub    $0xc,%esp
80103124:	68 20 41 19 80       	push   $0x80194120
80103129:	e8 db 17 00 00       	call   80104909 <release>
8010312e:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103131:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103135:	74 3f                	je     80103176 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103137:	e8 f6 00 00 00       	call   80103232 <commit>
    acquire(&log.lock);
8010313c:	83 ec 0c             	sub    $0xc,%esp
8010313f:	68 20 41 19 80       	push   $0x80194120
80103144:	e8 52 17 00 00       	call   8010489b <acquire>
80103149:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010314c:	c7 05 60 41 19 80 00 	movl   $0x0,0x80194160
80103153:	00 00 00 
    wakeup(&log);
80103156:	83 ec 0c             	sub    $0xc,%esp
80103159:	68 20 41 19 80       	push   $0x80194120
8010315e:	e8 56 12 00 00       	call   801043b9 <wakeup>
80103163:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103166:	83 ec 0c             	sub    $0xc,%esp
80103169:	68 20 41 19 80       	push   $0x80194120
8010316e:	e8 96 17 00 00       	call   80104909 <release>
80103173:	83 c4 10             	add    $0x10,%esp
  }
}
80103176:	90                   	nop
80103177:	c9                   	leave  
80103178:	c3                   	ret    

80103179 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103179:	55                   	push   %ebp
8010317a:	89 e5                	mov    %esp,%ebp
8010317c:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010317f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103186:	e9 95 00 00 00       	jmp    80103220 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010318b:	8b 15 54 41 19 80    	mov    0x80194154,%edx
80103191:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103194:	01 d0                	add    %edx,%eax
80103196:	83 c0 01             	add    $0x1,%eax
80103199:	89 c2                	mov    %eax,%edx
8010319b:	a1 64 41 19 80       	mov    0x80194164,%eax
801031a0:	83 ec 08             	sub    $0x8,%esp
801031a3:	52                   	push   %edx
801031a4:	50                   	push   %eax
801031a5:	e8 57 d0 ff ff       	call   80100201 <bread>
801031aa:	83 c4 10             	add    $0x10,%esp
801031ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801031b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031b3:	83 c0 10             	add    $0x10,%eax
801031b6:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801031bd:	89 c2                	mov    %eax,%edx
801031bf:	a1 64 41 19 80       	mov    0x80194164,%eax
801031c4:	83 ec 08             	sub    $0x8,%esp
801031c7:	52                   	push   %edx
801031c8:	50                   	push   %eax
801031c9:	e8 33 d0 ff ff       	call   80100201 <bread>
801031ce:	83 c4 10             	add    $0x10,%esp
801031d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801031d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031d7:	8d 50 5c             	lea    0x5c(%eax),%edx
801031da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031dd:	83 c0 5c             	add    $0x5c,%eax
801031e0:	83 ec 04             	sub    $0x4,%esp
801031e3:	68 00 02 00 00       	push   $0x200
801031e8:	52                   	push   %edx
801031e9:	50                   	push   %eax
801031ea:	e8 e1 19 00 00       	call   80104bd0 <memmove>
801031ef:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801031f2:	83 ec 0c             	sub    $0xc,%esp
801031f5:	ff 75 f0             	push   -0x10(%ebp)
801031f8:	e8 3d d0 ff ff       	call   8010023a <bwrite>
801031fd:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103200:	83 ec 0c             	sub    $0xc,%esp
80103203:	ff 75 ec             	push   -0x14(%ebp)
80103206:	e8 78 d0 ff ff       	call   80100283 <brelse>
8010320b:	83 c4 10             	add    $0x10,%esp
    brelse(to);
8010320e:	83 ec 0c             	sub    $0xc,%esp
80103211:	ff 75 f0             	push   -0x10(%ebp)
80103214:	e8 6a d0 ff ff       	call   80100283 <brelse>
80103219:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
8010321c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103220:	a1 68 41 19 80       	mov    0x80194168,%eax
80103225:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103228:	0f 8c 5d ff ff ff    	jl     8010318b <write_log+0x12>
  }
}
8010322e:	90                   	nop
8010322f:	90                   	nop
80103230:	c9                   	leave  
80103231:	c3                   	ret    

80103232 <commit>:

static void
commit()
{
80103232:	55                   	push   %ebp
80103233:	89 e5                	mov    %esp,%ebp
80103235:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103238:	a1 68 41 19 80       	mov    0x80194168,%eax
8010323d:	85 c0                	test   %eax,%eax
8010323f:	7e 1e                	jle    8010325f <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103241:	e8 33 ff ff ff       	call   80103179 <write_log>
    write_head();    // Write header to disk -- the real commit
80103246:	e8 39 fd ff ff       	call   80102f84 <write_head>
    install_trans(); // Now install writes to home locations
8010324b:	e8 07 fc ff ff       	call   80102e57 <install_trans>
    log.lh.n = 0;
80103250:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
80103257:	00 00 00 
    write_head();    // Erase the transaction from the log
8010325a:	e8 25 fd ff ff       	call   80102f84 <write_head>
  }
}
8010325f:	90                   	nop
80103260:	c9                   	leave  
80103261:	c3                   	ret    

80103262 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103262:	55                   	push   %ebp
80103263:	89 e5                	mov    %esp,%ebp
80103265:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103268:	a1 68 41 19 80       	mov    0x80194168,%eax
8010326d:	83 f8 1d             	cmp    $0x1d,%eax
80103270:	7f 12                	jg     80103284 <log_write+0x22>
80103272:	a1 68 41 19 80       	mov    0x80194168,%eax
80103277:	8b 15 58 41 19 80    	mov    0x80194158,%edx
8010327d:	83 ea 01             	sub    $0x1,%edx
80103280:	39 d0                	cmp    %edx,%eax
80103282:	7c 0d                	jl     80103291 <log_write+0x2f>
    panic("too big a transaction");
80103284:	83 ec 0c             	sub    $0xc,%esp
80103287:	68 44 a5 10 80       	push   $0x8010a544
8010328c:	e8 18 d3 ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
80103291:	a1 5c 41 19 80       	mov    0x8019415c,%eax
80103296:	85 c0                	test   %eax,%eax
80103298:	7f 0d                	jg     801032a7 <log_write+0x45>
    panic("log_write outside of trans");
8010329a:	83 ec 0c             	sub    $0xc,%esp
8010329d:	68 5a a5 10 80       	push   $0x8010a55a
801032a2:	e8 02 d3 ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
801032a7:	83 ec 0c             	sub    $0xc,%esp
801032aa:	68 20 41 19 80       	push   $0x80194120
801032af:	e8 e7 15 00 00       	call   8010489b <acquire>
801032b4:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801032b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032be:	eb 1d                	jmp    801032dd <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801032c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032c3:	83 c0 10             	add    $0x10,%eax
801032c6:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801032cd:	89 c2                	mov    %eax,%edx
801032cf:	8b 45 08             	mov    0x8(%ebp),%eax
801032d2:	8b 40 08             	mov    0x8(%eax),%eax
801032d5:	39 c2                	cmp    %eax,%edx
801032d7:	74 10                	je     801032e9 <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801032d9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032dd:	a1 68 41 19 80       	mov    0x80194168,%eax
801032e2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801032e5:	7c d9                	jl     801032c0 <log_write+0x5e>
801032e7:	eb 01                	jmp    801032ea <log_write+0x88>
      break;
801032e9:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801032ea:	8b 45 08             	mov    0x8(%ebp),%eax
801032ed:	8b 40 08             	mov    0x8(%eax),%eax
801032f0:	89 c2                	mov    %eax,%edx
801032f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032f5:	83 c0 10             	add    $0x10,%eax
801032f8:	89 14 85 2c 41 19 80 	mov    %edx,-0x7fe6bed4(,%eax,4)
  if (i == log.lh.n)
801032ff:	a1 68 41 19 80       	mov    0x80194168,%eax
80103304:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103307:	75 0d                	jne    80103316 <log_write+0xb4>
    log.lh.n++;
80103309:	a1 68 41 19 80       	mov    0x80194168,%eax
8010330e:	83 c0 01             	add    $0x1,%eax
80103311:	a3 68 41 19 80       	mov    %eax,0x80194168
  b->flags |= B_DIRTY; // prevent eviction
80103316:	8b 45 08             	mov    0x8(%ebp),%eax
80103319:	8b 00                	mov    (%eax),%eax
8010331b:	83 c8 04             	or     $0x4,%eax
8010331e:	89 c2                	mov    %eax,%edx
80103320:	8b 45 08             	mov    0x8(%ebp),%eax
80103323:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103325:	83 ec 0c             	sub    $0xc,%esp
80103328:	68 20 41 19 80       	push   $0x80194120
8010332d:	e8 d7 15 00 00       	call   80104909 <release>
80103332:	83 c4 10             	add    $0x10,%esp
}
80103335:	90                   	nop
80103336:	c9                   	leave  
80103337:	c3                   	ret    

80103338 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103338:	55                   	push   %ebp
80103339:	89 e5                	mov    %esp,%ebp
8010333b:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010333e:	8b 55 08             	mov    0x8(%ebp),%edx
80103341:	8b 45 0c             	mov    0xc(%ebp),%eax
80103344:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103347:	f0 87 02             	lock xchg %eax,(%edx)
8010334a:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010334d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103350:	c9                   	leave  
80103351:	c3                   	ret    

80103352 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103352:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103356:	83 e4 f0             	and    $0xfffffff0,%esp
80103359:	ff 71 fc             	push   -0x4(%ecx)
8010335c:	55                   	push   %ebp
8010335d:	89 e5                	mov    %esp,%ebp
8010335f:	51                   	push   %ecx
80103360:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
80103363:	e8 59 4d 00 00       	call   801080c1 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103368:	83 ec 08             	sub    $0x8,%esp
8010336b:	68 00 00 40 80       	push   $0x80400000
80103370:	68 00 90 19 80       	push   $0x80199000
80103375:	e8 de f2 ff ff       	call   80102658 <kinit1>
8010337a:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
8010337d:	e8 6e 42 00 00       	call   801075f0 <kvmalloc>
  mpinit_uefi();
80103382:	e8 00 4b 00 00       	call   80107e87 <mpinit_uefi>
  lapicinit();     // interrupt controller
80103387:	e8 3c f6 ff ff       	call   801029c8 <lapicinit>
  seginit();       // segment descriptors
8010338c:	e8 f7 3c 00 00       	call   80107088 <seginit>
  picinit();    // disable pic
80103391:	e8 9d 01 00 00       	call   80103533 <picinit>
  ioapicinit();    // another interrupt controller
80103396:	e8 d8 f1 ff ff       	call   80102573 <ioapicinit>
  consoleinit();   // console hardware
8010339b:	e8 5f d7 ff ff       	call   80100aff <consoleinit>
  uartinit();      // serial port
801033a0:	e8 7c 30 00 00       	call   80106421 <uartinit>
  pinit();         // process table
801033a5:	e8 ce 05 00 00       	call   80103978 <pinit>
  tvinit();        // trap vectors
801033aa:	e8 45 2b 00 00       	call   80105ef4 <tvinit>
  binit();         // buffer cache
801033af:	e8 b2 cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033b4:	e8 f3 db ff ff       	call   80100fac <fileinit>
  ideinit();       // disk 
801033b9:	e8 44 6e 00 00       	call   8010a202 <ideinit>
  startothers();   // start other processors
801033be:	e8 8a 00 00 00       	call   8010344d <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033c3:	83 ec 08             	sub    $0x8,%esp
801033c6:	68 00 00 00 a0       	push   $0xa0000000
801033cb:	68 00 00 40 80       	push   $0x80400000
801033d0:	e8 bc f2 ff ff       	call   80102691 <kinit2>
801033d5:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033d8:	e8 3d 4f 00 00       	call   8010831a <pci_init>
  arp_scan();
801033dd:	e8 74 5c 00 00       	call   80109056 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801033e2:	e8 6f 07 00 00       	call   80103b56 <userinit>

  mpmain();        // finish this processor's setup
801033e7:	e8 1a 00 00 00       	call   80103406 <mpmain>

801033ec <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801033ec:	55                   	push   %ebp
801033ed:	89 e5                	mov    %esp,%ebp
801033ef:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801033f2:	e8 11 42 00 00       	call   80107608 <switchkvm>
  seginit();
801033f7:	e8 8c 3c 00 00       	call   80107088 <seginit>
  lapicinit();
801033fc:	e8 c7 f5 ff ff       	call   801029c8 <lapicinit>
  mpmain();
80103401:	e8 00 00 00 00       	call   80103406 <mpmain>

80103406 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103406:	55                   	push   %ebp
80103407:	89 e5                	mov    %esp,%ebp
80103409:	53                   	push   %ebx
8010340a:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
8010340d:	e8 84 05 00 00       	call   80103996 <cpuid>
80103412:	89 c3                	mov    %eax,%ebx
80103414:	e8 7d 05 00 00       	call   80103996 <cpuid>
80103419:	83 ec 04             	sub    $0x4,%esp
8010341c:	53                   	push   %ebx
8010341d:	50                   	push   %eax
8010341e:	68 75 a5 10 80       	push   $0x8010a575
80103423:	e8 cc cf ff ff       	call   801003f4 <cprintf>
80103428:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
8010342b:	e8 3a 2c 00 00       	call   8010606a <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103430:	e8 7c 05 00 00       	call   801039b1 <mycpu>
80103435:	05 a0 00 00 00       	add    $0xa0,%eax
8010343a:	83 ec 08             	sub    $0x8,%esp
8010343d:	6a 01                	push   $0x1
8010343f:	50                   	push   %eax
80103440:	e8 f3 fe ff ff       	call   80103338 <xchg>
80103445:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103448:	e8 94 0c 00 00       	call   801040e1 <scheduler>

8010344d <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
8010344d:	55                   	push   %ebp
8010344e:	89 e5                	mov    %esp,%ebp
80103450:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103453:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010345a:	b8 8a 00 00 00       	mov    $0x8a,%eax
8010345f:	83 ec 04             	sub    $0x4,%esp
80103462:	50                   	push   %eax
80103463:	68 18 f5 10 80       	push   $0x8010f518
80103468:	ff 75 f0             	push   -0x10(%ebp)
8010346b:	e8 60 17 00 00       	call   80104bd0 <memmove>
80103470:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103473:	c7 45 f4 80 6a 19 80 	movl   $0x80196a80,-0xc(%ebp)
8010347a:	eb 79                	jmp    801034f5 <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
8010347c:	e8 30 05 00 00       	call   801039b1 <mycpu>
80103481:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103484:	74 67                	je     801034ed <startothers+0xa0>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103486:	e8 02 f3 ff ff       	call   8010278d <kalloc>
8010348b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
8010348e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103491:	83 e8 04             	sub    $0x4,%eax
80103494:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103497:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010349d:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
8010349f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034a2:	83 e8 08             	sub    $0x8,%eax
801034a5:	c7 00 ec 33 10 80    	movl   $0x801033ec,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801034ab:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
801034b0:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034b9:	83 e8 0c             	sub    $0xc,%eax
801034bc:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801034be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034c1:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034ca:	0f b6 00             	movzbl (%eax),%eax
801034cd:	0f b6 c0             	movzbl %al,%eax
801034d0:	83 ec 08             	sub    $0x8,%esp
801034d3:	52                   	push   %edx
801034d4:	50                   	push   %eax
801034d5:	e8 50 f6 ff ff       	call   80102b2a <lapicstartap>
801034da:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801034dd:	90                   	nop
801034de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034e1:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801034e7:	85 c0                	test   %eax,%eax
801034e9:	74 f3                	je     801034de <startothers+0x91>
801034eb:	eb 01                	jmp    801034ee <startothers+0xa1>
      continue;
801034ed:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
801034ee:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
801034f5:	a1 40 6d 19 80       	mov    0x80196d40,%eax
801034fa:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103500:	05 80 6a 19 80       	add    $0x80196a80,%eax
80103505:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103508:	0f 82 6e ff ff ff    	jb     8010347c <startothers+0x2f>
      ;
  }
}
8010350e:	90                   	nop
8010350f:	90                   	nop
80103510:	c9                   	leave  
80103511:	c3                   	ret    

80103512 <outb>:
{
80103512:	55                   	push   %ebp
80103513:	89 e5                	mov    %esp,%ebp
80103515:	83 ec 08             	sub    $0x8,%esp
80103518:	8b 45 08             	mov    0x8(%ebp),%eax
8010351b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010351e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103522:	89 d0                	mov    %edx,%eax
80103524:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103527:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010352b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010352f:	ee                   	out    %al,(%dx)
}
80103530:	90                   	nop
80103531:	c9                   	leave  
80103532:	c3                   	ret    

80103533 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103533:	55                   	push   %ebp
80103534:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103536:	68 ff 00 00 00       	push   $0xff
8010353b:	6a 21                	push   $0x21
8010353d:	e8 d0 ff ff ff       	call   80103512 <outb>
80103542:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103545:	68 ff 00 00 00       	push   $0xff
8010354a:	68 a1 00 00 00       	push   $0xa1
8010354f:	e8 be ff ff ff       	call   80103512 <outb>
80103554:	83 c4 08             	add    $0x8,%esp
}
80103557:	90                   	nop
80103558:	c9                   	leave  
80103559:	c3                   	ret    

8010355a <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
8010355a:	55                   	push   %ebp
8010355b:	89 e5                	mov    %esp,%ebp
8010355d:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103560:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103567:	8b 45 0c             	mov    0xc(%ebp),%eax
8010356a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103570:	8b 45 0c             	mov    0xc(%ebp),%eax
80103573:	8b 10                	mov    (%eax),%edx
80103575:	8b 45 08             	mov    0x8(%ebp),%eax
80103578:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010357a:	e8 4b da ff ff       	call   80100fca <filealloc>
8010357f:	8b 55 08             	mov    0x8(%ebp),%edx
80103582:	89 02                	mov    %eax,(%edx)
80103584:	8b 45 08             	mov    0x8(%ebp),%eax
80103587:	8b 00                	mov    (%eax),%eax
80103589:	85 c0                	test   %eax,%eax
8010358b:	0f 84 c8 00 00 00    	je     80103659 <pipealloc+0xff>
80103591:	e8 34 da ff ff       	call   80100fca <filealloc>
80103596:	8b 55 0c             	mov    0xc(%ebp),%edx
80103599:	89 02                	mov    %eax,(%edx)
8010359b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010359e:	8b 00                	mov    (%eax),%eax
801035a0:	85 c0                	test   %eax,%eax
801035a2:	0f 84 b1 00 00 00    	je     80103659 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801035a8:	e8 e0 f1 ff ff       	call   8010278d <kalloc>
801035ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
801035b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035b4:	0f 84 a2 00 00 00    	je     8010365c <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
801035ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035bd:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801035c4:	00 00 00 
  p->writeopen = 1;
801035c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035ca:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801035d1:	00 00 00 
  p->nwrite = 0;
801035d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035d7:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801035de:	00 00 00 
  p->nread = 0;
801035e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035e4:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801035eb:	00 00 00 
  initlock(&p->lock, "pipe");
801035ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035f1:	83 ec 08             	sub    $0x8,%esp
801035f4:	68 89 a5 10 80       	push   $0x8010a589
801035f9:	50                   	push   %eax
801035fa:	e8 7a 12 00 00       	call   80104879 <initlock>
801035ff:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103602:	8b 45 08             	mov    0x8(%ebp),%eax
80103605:	8b 00                	mov    (%eax),%eax
80103607:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
8010360d:	8b 45 08             	mov    0x8(%ebp),%eax
80103610:	8b 00                	mov    (%eax),%eax
80103612:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103616:	8b 45 08             	mov    0x8(%ebp),%eax
80103619:	8b 00                	mov    (%eax),%eax
8010361b:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
8010361f:	8b 45 08             	mov    0x8(%ebp),%eax
80103622:	8b 00                	mov    (%eax),%eax
80103624:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103627:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010362a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010362d:	8b 00                	mov    (%eax),%eax
8010362f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103635:	8b 45 0c             	mov    0xc(%ebp),%eax
80103638:	8b 00                	mov    (%eax),%eax
8010363a:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
8010363e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103641:	8b 00                	mov    (%eax),%eax
80103643:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103647:	8b 45 0c             	mov    0xc(%ebp),%eax
8010364a:	8b 00                	mov    (%eax),%eax
8010364c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010364f:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103652:	b8 00 00 00 00       	mov    $0x0,%eax
80103657:	eb 51                	jmp    801036aa <pipealloc+0x150>
    goto bad;
80103659:	90                   	nop
8010365a:	eb 01                	jmp    8010365d <pipealloc+0x103>
    goto bad;
8010365c:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
8010365d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103661:	74 0e                	je     80103671 <pipealloc+0x117>
    kfree((char*)p);
80103663:	83 ec 0c             	sub    $0xc,%esp
80103666:	ff 75 f4             	push   -0xc(%ebp)
80103669:	e8 85 f0 ff ff       	call   801026f3 <kfree>
8010366e:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103671:	8b 45 08             	mov    0x8(%ebp),%eax
80103674:	8b 00                	mov    (%eax),%eax
80103676:	85 c0                	test   %eax,%eax
80103678:	74 11                	je     8010368b <pipealloc+0x131>
    fileclose(*f0);
8010367a:	8b 45 08             	mov    0x8(%ebp),%eax
8010367d:	8b 00                	mov    (%eax),%eax
8010367f:	83 ec 0c             	sub    $0xc,%esp
80103682:	50                   	push   %eax
80103683:	e8 00 da ff ff       	call   80101088 <fileclose>
80103688:	83 c4 10             	add    $0x10,%esp
  if(*f1)
8010368b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010368e:	8b 00                	mov    (%eax),%eax
80103690:	85 c0                	test   %eax,%eax
80103692:	74 11                	je     801036a5 <pipealloc+0x14b>
    fileclose(*f1);
80103694:	8b 45 0c             	mov    0xc(%ebp),%eax
80103697:	8b 00                	mov    (%eax),%eax
80103699:	83 ec 0c             	sub    $0xc,%esp
8010369c:	50                   	push   %eax
8010369d:	e8 e6 d9 ff ff       	call   80101088 <fileclose>
801036a2:	83 c4 10             	add    $0x10,%esp
  return -1;
801036a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801036aa:	c9                   	leave  
801036ab:	c3                   	ret    

801036ac <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801036ac:	55                   	push   %ebp
801036ad:	89 e5                	mov    %esp,%ebp
801036af:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801036b2:	8b 45 08             	mov    0x8(%ebp),%eax
801036b5:	83 ec 0c             	sub    $0xc,%esp
801036b8:	50                   	push   %eax
801036b9:	e8 dd 11 00 00       	call   8010489b <acquire>
801036be:	83 c4 10             	add    $0x10,%esp
  if(writable){
801036c1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801036c5:	74 23                	je     801036ea <pipeclose+0x3e>
    p->writeopen = 0;
801036c7:	8b 45 08             	mov    0x8(%ebp),%eax
801036ca:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801036d1:	00 00 00 
    wakeup(&p->nread);
801036d4:	8b 45 08             	mov    0x8(%ebp),%eax
801036d7:	05 34 02 00 00       	add    $0x234,%eax
801036dc:	83 ec 0c             	sub    $0xc,%esp
801036df:	50                   	push   %eax
801036e0:	e8 d4 0c 00 00       	call   801043b9 <wakeup>
801036e5:	83 c4 10             	add    $0x10,%esp
801036e8:	eb 21                	jmp    8010370b <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801036ea:	8b 45 08             	mov    0x8(%ebp),%eax
801036ed:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801036f4:	00 00 00 
    wakeup(&p->nwrite);
801036f7:	8b 45 08             	mov    0x8(%ebp),%eax
801036fa:	05 38 02 00 00       	add    $0x238,%eax
801036ff:	83 ec 0c             	sub    $0xc,%esp
80103702:	50                   	push   %eax
80103703:	e8 b1 0c 00 00       	call   801043b9 <wakeup>
80103708:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010370b:	8b 45 08             	mov    0x8(%ebp),%eax
8010370e:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103714:	85 c0                	test   %eax,%eax
80103716:	75 2c                	jne    80103744 <pipeclose+0x98>
80103718:	8b 45 08             	mov    0x8(%ebp),%eax
8010371b:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103721:	85 c0                	test   %eax,%eax
80103723:	75 1f                	jne    80103744 <pipeclose+0x98>
    release(&p->lock);
80103725:	8b 45 08             	mov    0x8(%ebp),%eax
80103728:	83 ec 0c             	sub    $0xc,%esp
8010372b:	50                   	push   %eax
8010372c:	e8 d8 11 00 00       	call   80104909 <release>
80103731:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103734:	83 ec 0c             	sub    $0xc,%esp
80103737:	ff 75 08             	push   0x8(%ebp)
8010373a:	e8 b4 ef ff ff       	call   801026f3 <kfree>
8010373f:	83 c4 10             	add    $0x10,%esp
80103742:	eb 10                	jmp    80103754 <pipeclose+0xa8>
  } else
    release(&p->lock);
80103744:	8b 45 08             	mov    0x8(%ebp),%eax
80103747:	83 ec 0c             	sub    $0xc,%esp
8010374a:	50                   	push   %eax
8010374b:	e8 b9 11 00 00       	call   80104909 <release>
80103750:	83 c4 10             	add    $0x10,%esp
}
80103753:	90                   	nop
80103754:	90                   	nop
80103755:	c9                   	leave  
80103756:	c3                   	ret    

80103757 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103757:	55                   	push   %ebp
80103758:	89 e5                	mov    %esp,%ebp
8010375a:	53                   	push   %ebx
8010375b:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
8010375e:	8b 45 08             	mov    0x8(%ebp),%eax
80103761:	83 ec 0c             	sub    $0xc,%esp
80103764:	50                   	push   %eax
80103765:	e8 31 11 00 00       	call   8010489b <acquire>
8010376a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
8010376d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103774:	e9 ad 00 00 00       	jmp    80103826 <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80103779:	8b 45 08             	mov    0x8(%ebp),%eax
8010377c:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103782:	85 c0                	test   %eax,%eax
80103784:	74 0c                	je     80103792 <pipewrite+0x3b>
80103786:	e8 9e 02 00 00       	call   80103a29 <myproc>
8010378b:	8b 40 24             	mov    0x24(%eax),%eax
8010378e:	85 c0                	test   %eax,%eax
80103790:	74 19                	je     801037ab <pipewrite+0x54>
        release(&p->lock);
80103792:	8b 45 08             	mov    0x8(%ebp),%eax
80103795:	83 ec 0c             	sub    $0xc,%esp
80103798:	50                   	push   %eax
80103799:	e8 6b 11 00 00       	call   80104909 <release>
8010379e:	83 c4 10             	add    $0x10,%esp
        return -1;
801037a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801037a6:	e9 a9 00 00 00       	jmp    80103854 <pipewrite+0xfd>
      }
      wakeup(&p->nread);
801037ab:	8b 45 08             	mov    0x8(%ebp),%eax
801037ae:	05 34 02 00 00       	add    $0x234,%eax
801037b3:	83 ec 0c             	sub    $0xc,%esp
801037b6:	50                   	push   %eax
801037b7:	e8 fd 0b 00 00       	call   801043b9 <wakeup>
801037bc:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037bf:	8b 45 08             	mov    0x8(%ebp),%eax
801037c2:	8b 55 08             	mov    0x8(%ebp),%edx
801037c5:	81 c2 38 02 00 00    	add    $0x238,%edx
801037cb:	83 ec 08             	sub    $0x8,%esp
801037ce:	50                   	push   %eax
801037cf:	52                   	push   %edx
801037d0:	e8 fd 0a 00 00       	call   801042d2 <sleep>
801037d5:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801037d8:	8b 45 08             	mov    0x8(%ebp),%eax
801037db:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801037e1:	8b 45 08             	mov    0x8(%ebp),%eax
801037e4:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801037ea:	05 00 02 00 00       	add    $0x200,%eax
801037ef:	39 c2                	cmp    %eax,%edx
801037f1:	74 86                	je     80103779 <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801037f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801037f6:	8b 45 0c             	mov    0xc(%ebp),%eax
801037f9:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801037fc:	8b 45 08             	mov    0x8(%ebp),%eax
801037ff:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103805:	8d 48 01             	lea    0x1(%eax),%ecx
80103808:	8b 55 08             	mov    0x8(%ebp),%edx
8010380b:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103811:	25 ff 01 00 00       	and    $0x1ff,%eax
80103816:	89 c1                	mov    %eax,%ecx
80103818:	0f b6 13             	movzbl (%ebx),%edx
8010381b:	8b 45 08             	mov    0x8(%ebp),%eax
8010381e:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103822:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103826:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103829:	3b 45 10             	cmp    0x10(%ebp),%eax
8010382c:	7c aa                	jl     801037d8 <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
8010382e:	8b 45 08             	mov    0x8(%ebp),%eax
80103831:	05 34 02 00 00       	add    $0x234,%eax
80103836:	83 ec 0c             	sub    $0xc,%esp
80103839:	50                   	push   %eax
8010383a:	e8 7a 0b 00 00       	call   801043b9 <wakeup>
8010383f:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103842:	8b 45 08             	mov    0x8(%ebp),%eax
80103845:	83 ec 0c             	sub    $0xc,%esp
80103848:	50                   	push   %eax
80103849:	e8 bb 10 00 00       	call   80104909 <release>
8010384e:	83 c4 10             	add    $0x10,%esp
  return n;
80103851:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103854:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103857:	c9                   	leave  
80103858:	c3                   	ret    

80103859 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103859:	55                   	push   %ebp
8010385a:	89 e5                	mov    %esp,%ebp
8010385c:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
8010385f:	8b 45 08             	mov    0x8(%ebp),%eax
80103862:	83 ec 0c             	sub    $0xc,%esp
80103865:	50                   	push   %eax
80103866:	e8 30 10 00 00       	call   8010489b <acquire>
8010386b:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010386e:	eb 3e                	jmp    801038ae <piperead+0x55>
    if(myproc()->killed){
80103870:	e8 b4 01 00 00       	call   80103a29 <myproc>
80103875:	8b 40 24             	mov    0x24(%eax),%eax
80103878:	85 c0                	test   %eax,%eax
8010387a:	74 19                	je     80103895 <piperead+0x3c>
      release(&p->lock);
8010387c:	8b 45 08             	mov    0x8(%ebp),%eax
8010387f:	83 ec 0c             	sub    $0xc,%esp
80103882:	50                   	push   %eax
80103883:	e8 81 10 00 00       	call   80104909 <release>
80103888:	83 c4 10             	add    $0x10,%esp
      return -1;
8010388b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103890:	e9 be 00 00 00       	jmp    80103953 <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103895:	8b 45 08             	mov    0x8(%ebp),%eax
80103898:	8b 55 08             	mov    0x8(%ebp),%edx
8010389b:	81 c2 34 02 00 00    	add    $0x234,%edx
801038a1:	83 ec 08             	sub    $0x8,%esp
801038a4:	50                   	push   %eax
801038a5:	52                   	push   %edx
801038a6:	e8 27 0a 00 00       	call   801042d2 <sleep>
801038ab:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801038ae:	8b 45 08             	mov    0x8(%ebp),%eax
801038b1:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038b7:	8b 45 08             	mov    0x8(%ebp),%eax
801038ba:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038c0:	39 c2                	cmp    %eax,%edx
801038c2:	75 0d                	jne    801038d1 <piperead+0x78>
801038c4:	8b 45 08             	mov    0x8(%ebp),%eax
801038c7:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801038cd:	85 c0                	test   %eax,%eax
801038cf:	75 9f                	jne    80103870 <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801038d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038d8:	eb 48                	jmp    80103922 <piperead+0xc9>
    if(p->nread == p->nwrite)
801038da:	8b 45 08             	mov    0x8(%ebp),%eax
801038dd:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038e3:	8b 45 08             	mov    0x8(%ebp),%eax
801038e6:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038ec:	39 c2                	cmp    %eax,%edx
801038ee:	74 3c                	je     8010392c <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801038f0:	8b 45 08             	mov    0x8(%ebp),%eax
801038f3:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801038f9:	8d 48 01             	lea    0x1(%eax),%ecx
801038fc:	8b 55 08             	mov    0x8(%ebp),%edx
801038ff:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103905:	25 ff 01 00 00       	and    $0x1ff,%eax
8010390a:	89 c1                	mov    %eax,%ecx
8010390c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010390f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103912:	01 c2                	add    %eax,%edx
80103914:	8b 45 08             	mov    0x8(%ebp),%eax
80103917:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
8010391c:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010391e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103922:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103925:	3b 45 10             	cmp    0x10(%ebp),%eax
80103928:	7c b0                	jl     801038da <piperead+0x81>
8010392a:	eb 01                	jmp    8010392d <piperead+0xd4>
      break;
8010392c:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010392d:	8b 45 08             	mov    0x8(%ebp),%eax
80103930:	05 38 02 00 00       	add    $0x238,%eax
80103935:	83 ec 0c             	sub    $0xc,%esp
80103938:	50                   	push   %eax
80103939:	e8 7b 0a 00 00       	call   801043b9 <wakeup>
8010393e:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103941:	8b 45 08             	mov    0x8(%ebp),%eax
80103944:	83 ec 0c             	sub    $0xc,%esp
80103947:	50                   	push   %eax
80103948:	e8 bc 0f 00 00       	call   80104909 <release>
8010394d:	83 c4 10             	add    $0x10,%esp
  return i;
80103950:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103953:	c9                   	leave  
80103954:	c3                   	ret    

80103955 <readeflags>:
{
80103955:	55                   	push   %ebp
80103956:	89 e5                	mov    %esp,%ebp
80103958:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010395b:	9c                   	pushf  
8010395c:	58                   	pop    %eax
8010395d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103960:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103963:	c9                   	leave  
80103964:	c3                   	ret    

80103965 <sti>:
{
80103965:	55                   	push   %ebp
80103966:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103968:	fb                   	sti    
}
80103969:	90                   	nop
8010396a:	5d                   	pop    %ebp
8010396b:	c3                   	ret    

8010396c <lcr3>:
  return val;
}

static inline void
lcr3(uint val)
{
8010396c:	55                   	push   %ebp
8010396d:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010396f:	8b 45 08             	mov    0x8(%ebp),%eax
80103972:	0f 22 d8             	mov    %eax,%cr3
}
80103975:	90                   	nop
80103976:	5d                   	pop    %ebp
80103977:	c3                   	ret    

80103978 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80103978:	55                   	push   %ebp
80103979:	89 e5                	mov    %esp,%ebp
8010397b:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
8010397e:	83 ec 08             	sub    $0x8,%esp
80103981:	68 90 a5 10 80       	push   $0x8010a590
80103986:	68 00 42 19 80       	push   $0x80194200
8010398b:	e8 e9 0e 00 00       	call   80104879 <initlock>
80103990:	83 c4 10             	add    $0x10,%esp
}
80103993:	90                   	nop
80103994:	c9                   	leave  
80103995:	c3                   	ret    

80103996 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80103996:	55                   	push   %ebp
80103997:	89 e5                	mov    %esp,%ebp
80103999:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
8010399c:	e8 10 00 00 00       	call   801039b1 <mycpu>
801039a1:	2d 80 6a 19 80       	sub    $0x80196a80,%eax
801039a6:	c1 f8 04             	sar    $0x4,%eax
801039a9:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801039af:	c9                   	leave  
801039b0:	c3                   	ret    

801039b1 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801039b1:	55                   	push   %ebp
801039b2:	89 e5                	mov    %esp,%ebp
801039b4:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
801039b7:	e8 99 ff ff ff       	call   80103955 <readeflags>
801039bc:	25 00 02 00 00       	and    $0x200,%eax
801039c1:	85 c0                	test   %eax,%eax
801039c3:	74 0d                	je     801039d2 <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
801039c5:	83 ec 0c             	sub    $0xc,%esp
801039c8:	68 98 a5 10 80       	push   $0x8010a598
801039cd:	e8 d7 cb ff ff       	call   801005a9 <panic>
  }

  apicid = lapicid();
801039d2:	e8 10 f1 ff ff       	call   80102ae7 <lapicid>
801039d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801039da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801039e1:	eb 2d                	jmp    80103a10 <mycpu+0x5f>
    if (cpus[i].apicid == apicid){
801039e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039e6:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801039ec:	05 80 6a 19 80       	add    $0x80196a80,%eax
801039f1:	0f b6 00             	movzbl (%eax),%eax
801039f4:	0f b6 c0             	movzbl %al,%eax
801039f7:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801039fa:	75 10                	jne    80103a0c <mycpu+0x5b>
      return &cpus[i];
801039fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039ff:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103a05:	05 80 6a 19 80       	add    $0x80196a80,%eax
80103a0a:	eb 1b                	jmp    80103a27 <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103a0c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a10:	a1 40 6d 19 80       	mov    0x80196d40,%eax
80103a15:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a18:	7c c9                	jl     801039e3 <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103a1a:	83 ec 0c             	sub    $0xc,%esp
80103a1d:	68 be a5 10 80       	push   $0x8010a5be
80103a22:	e8 82 cb ff ff       	call   801005a9 <panic>
}
80103a27:	c9                   	leave  
80103a28:	c3                   	ret    

80103a29 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103a29:	55                   	push   %ebp
80103a2a:	89 e5                	mov    %esp,%ebp
80103a2c:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103a2f:	e8 d2 0f 00 00       	call   80104a06 <pushcli>
  c = mycpu();
80103a34:	e8 78 ff ff ff       	call   801039b1 <mycpu>
80103a39:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103a3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a3f:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a45:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103a48:	e8 06 10 00 00       	call   80104a53 <popcli>
  return p;
80103a4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103a50:	c9                   	leave  
80103a51:	c3                   	ret    

80103a52 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103a52:	55                   	push   %ebp
80103a53:	89 e5                	mov    %esp,%ebp
80103a55:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103a58:	83 ec 0c             	sub    $0xc,%esp
80103a5b:	68 00 42 19 80       	push   $0x80194200
80103a60:	e8 36 0e 00 00       	call   8010489b <acquire>
80103a65:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a68:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103a6f:	eb 0e                	jmp    80103a7f <allocproc+0x2d>
    if(p->state == UNUSED){
80103a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a74:	8b 40 0c             	mov    0xc(%eax),%eax
80103a77:	85 c0                	test   %eax,%eax
80103a79:	74 27                	je     80103aa2 <allocproc+0x50>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a7b:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80103a7f:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
80103a86:	72 e9                	jb     80103a71 <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103a88:	83 ec 0c             	sub    $0xc,%esp
80103a8b:	68 00 42 19 80       	push   $0x80194200
80103a90:	e8 74 0e 00 00       	call   80104909 <release>
80103a95:	83 c4 10             	add    $0x10,%esp
  return 0;
80103a98:	b8 00 00 00 00       	mov    $0x0,%eax
80103a9d:	e9 b2 00 00 00       	jmp    80103b54 <allocproc+0x102>
      goto found;
80103aa2:	90                   	nop

found:
  p->state = EMBRYO;
80103aa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aa6:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103aad:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103ab2:	8d 50 01             	lea    0x1(%eax),%edx
80103ab5:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103abb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103abe:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103ac1:	83 ec 0c             	sub    $0xc,%esp
80103ac4:	68 00 42 19 80       	push   $0x80194200
80103ac9:	e8 3b 0e 00 00       	call   80104909 <release>
80103ace:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103ad1:	e8 b7 ec ff ff       	call   8010278d <kalloc>
80103ad6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ad9:	89 42 08             	mov    %eax,0x8(%edx)
80103adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103adf:	8b 40 08             	mov    0x8(%eax),%eax
80103ae2:	85 c0                	test   %eax,%eax
80103ae4:	75 11                	jne    80103af7 <allocproc+0xa5>
    p->state = UNUSED;
80103ae6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103af0:	b8 00 00 00 00       	mov    $0x0,%eax
80103af5:	eb 5d                	jmp    80103b54 <allocproc+0x102>
  }
  sp = p->kstack + KSTACKSIZE;
80103af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103afa:	8b 40 08             	mov    0x8(%eax),%eax
80103afd:	05 00 10 00 00       	add    $0x1000,%eax
80103b02:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103b05:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103b09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b0c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b0f:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103b12:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103b16:	ba a2 5e 10 80       	mov    $0x80105ea2,%edx
80103b1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b1e:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103b20:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103b24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b27:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b2a:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103b2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b30:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b33:	83 ec 04             	sub    $0x4,%esp
80103b36:	6a 14                	push   $0x14
80103b38:	6a 00                	push   $0x0
80103b3a:	50                   	push   %eax
80103b3b:	e8 d1 0f 00 00       	call   80104b11 <memset>
80103b40:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103b43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b46:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b49:	ba 8c 42 10 80       	mov    $0x8010428c,%edx
80103b4e:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103b54:	c9                   	leave  
80103b55:	c3                   	ret    

80103b56 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103b56:	55                   	push   %ebp
80103b57:	89 e5                	mov    %esp,%ebp
80103b59:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103b5c:	e8 f1 fe ff ff       	call   80103a52 <allocproc>
80103b61:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b67:	a3 34 62 19 80       	mov    %eax,0x80196234
  if((p->pgdir = setupkvm()) == 0){
80103b6c:	e8 93 39 00 00       	call   80107504 <setupkvm>
80103b71:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b74:	89 42 04             	mov    %eax,0x4(%edx)
80103b77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b7a:	8b 40 04             	mov    0x4(%eax),%eax
80103b7d:	85 c0                	test   %eax,%eax
80103b7f:	75 0d                	jne    80103b8e <userinit+0x38>
    panic("userinit: out of memory?");
80103b81:	83 ec 0c             	sub    $0xc,%esp
80103b84:	68 ce a5 10 80       	push   $0x8010a5ce
80103b89:	e8 1b ca ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103b8e:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103b93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b96:	8b 40 04             	mov    0x4(%eax),%eax
80103b99:	83 ec 04             	sub    $0x4,%esp
80103b9c:	52                   	push   %edx
80103b9d:	68 ec f4 10 80       	push   $0x8010f4ec
80103ba2:	50                   	push   %eax
80103ba3:	e8 18 3c 00 00       	call   801077c0 <inituvm>
80103ba8:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bae:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103bb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb7:	8b 40 18             	mov    0x18(%eax),%eax
80103bba:	83 ec 04             	sub    $0x4,%esp
80103bbd:	6a 4c                	push   $0x4c
80103bbf:	6a 00                	push   $0x0
80103bc1:	50                   	push   %eax
80103bc2:	e8 4a 0f 00 00       	call   80104b11 <memset>
80103bc7:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103bca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bcd:	8b 40 18             	mov    0x18(%eax),%eax
80103bd0:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd9:	8b 40 18             	mov    0x18(%eax),%eax
80103bdc:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be5:	8b 50 18             	mov    0x18(%eax),%edx
80103be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103beb:	8b 40 18             	mov    0x18(%eax),%eax
80103bee:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103bf2:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf9:	8b 50 18             	mov    0x18(%eax),%edx
80103bfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bff:	8b 40 18             	mov    0x18(%eax),%eax
80103c02:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c06:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c0d:	8b 40 18             	mov    0x18(%eax),%eax
80103c10:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c1a:	8b 40 18             	mov    0x18(%eax),%eax
80103c1d:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103c24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c27:	8b 40 18             	mov    0x18(%eax),%eax
80103c2a:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103c31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c34:	83 c0 6c             	add    $0x6c,%eax
80103c37:	83 ec 04             	sub    $0x4,%esp
80103c3a:	6a 10                	push   $0x10
80103c3c:	68 e7 a5 10 80       	push   $0x8010a5e7
80103c41:	50                   	push   %eax
80103c42:	e8 cd 10 00 00       	call   80104d14 <safestrcpy>
80103c47:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103c4a:	83 ec 0c             	sub    $0xc,%esp
80103c4d:	68 f0 a5 10 80       	push   $0x8010a5f0
80103c52:	e8 b3 e8 ff ff       	call   8010250a <namei>
80103c57:	83 c4 10             	add    $0x10,%esp
80103c5a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c5d:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103c60:	83 ec 0c             	sub    $0xc,%esp
80103c63:	68 00 42 19 80       	push   $0x80194200
80103c68:	e8 2e 0c 00 00       	call   8010489b <acquire>
80103c6d:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103c70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c73:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103c7a:	83 ec 0c             	sub    $0xc,%esp
80103c7d:	68 00 42 19 80       	push   $0x80194200
80103c82:	e8 82 0c 00 00       	call   80104909 <release>
80103c87:	83 c4 10             	add    $0x10,%esp
}
80103c8a:	90                   	nop
80103c8b:	c9                   	leave  
80103c8c:	c3                   	ret    

80103c8d <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103c8d:	55                   	push   %ebp
80103c8e:	89 e5                	mov    %esp,%ebp
80103c90:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103c93:	e8 91 fd ff ff       	call   80103a29 <myproc>
80103c98:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103c9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c9e:	8b 00                	mov    (%eax),%eax
80103ca0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103ca3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103ca7:	7e 2e                	jle    80103cd7 <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103ca9:	8b 55 08             	mov    0x8(%ebp),%edx
80103cac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103caf:	01 c2                	add    %eax,%edx
80103cb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cb4:	8b 40 04             	mov    0x4(%eax),%eax
80103cb7:	83 ec 04             	sub    $0x4,%esp
80103cba:	52                   	push   %edx
80103cbb:	ff 75 f4             	push   -0xc(%ebp)
80103cbe:	50                   	push   %eax
80103cbf:	e8 39 3c 00 00       	call   801078fd <allocuvm>
80103cc4:	83 c4 10             	add    $0x10,%esp
80103cc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103cce:	75 3b                	jne    80103d0b <growproc+0x7e>
      return -1;
80103cd0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103cd5:	eb 4f                	jmp    80103d26 <growproc+0x99>
  } else if(n < 0){
80103cd7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103cdb:	79 2e                	jns    80103d0b <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103cdd:	8b 55 08             	mov    0x8(%ebp),%edx
80103ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ce3:	01 c2                	add    %eax,%edx
80103ce5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ce8:	8b 40 04             	mov    0x4(%eax),%eax
80103ceb:	83 ec 04             	sub    $0x4,%esp
80103cee:	52                   	push   %edx
80103cef:	ff 75 f4             	push   -0xc(%ebp)
80103cf2:	50                   	push   %eax
80103cf3:	e8 0a 3d 00 00       	call   80107a02 <deallocuvm>
80103cf8:	83 c4 10             	add    $0x10,%esp
80103cfb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cfe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d02:	75 07                	jne    80103d0b <growproc+0x7e>
      return -1;
80103d04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d09:	eb 1b                	jmp    80103d26 <growproc+0x99>
  }
  curproc->sz = sz;
80103d0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d0e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d11:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103d13:	83 ec 0c             	sub    $0xc,%esp
80103d16:	ff 75 f0             	push   -0x10(%ebp)
80103d19:	e8 03 39 00 00       	call   80107621 <switchuvm>
80103d1e:	83 c4 10             	add    $0x10,%esp
  return 0;
80103d21:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103d26:	c9                   	leave  
80103d27:	c3                   	ret    

80103d28 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103d28:	55                   	push   %ebp
80103d29:	89 e5                	mov    %esp,%ebp
80103d2b:	57                   	push   %edi
80103d2c:	56                   	push   %esi
80103d2d:	53                   	push   %ebx
80103d2e:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103d31:	e8 f3 fc ff ff       	call   80103a29 <myproc>
80103d36:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103d39:	e8 14 fd ff ff       	call   80103a52 <allocproc>
80103d3e:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103d41:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103d45:	75 0a                	jne    80103d51 <fork+0x29>
    return -1;
80103d47:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d4c:	e9 48 01 00 00       	jmp    80103e99 <fork+0x171>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103d51:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d54:	8b 10                	mov    (%eax),%edx
80103d56:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d59:	8b 40 04             	mov    0x4(%eax),%eax
80103d5c:	83 ec 08             	sub    $0x8,%esp
80103d5f:	52                   	push   %edx
80103d60:	50                   	push   %eax
80103d61:	e8 3a 3e 00 00       	call   80107ba0 <copyuvm>
80103d66:	83 c4 10             	add    $0x10,%esp
80103d69:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103d6c:	89 42 04             	mov    %eax,0x4(%edx)
80103d6f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d72:	8b 40 04             	mov    0x4(%eax),%eax
80103d75:	85 c0                	test   %eax,%eax
80103d77:	75 30                	jne    80103da9 <fork+0x81>
    kfree(np->kstack);
80103d79:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d7c:	8b 40 08             	mov    0x8(%eax),%eax
80103d7f:	83 ec 0c             	sub    $0xc,%esp
80103d82:	50                   	push   %eax
80103d83:	e8 6b e9 ff ff       	call   801026f3 <kfree>
80103d88:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103d8b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d8e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103d95:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d98:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103d9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103da4:	e9 f0 00 00 00       	jmp    80103e99 <fork+0x171>
  }
  np->sz = curproc->sz;
80103da9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dac:	8b 10                	mov    (%eax),%edx
80103dae:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103db1:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103db3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103db6:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103db9:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103dbc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dbf:	8b 48 18             	mov    0x18(%eax),%ecx
80103dc2:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dc5:	8b 40 18             	mov    0x18(%eax),%eax
80103dc8:	89 c2                	mov    %eax,%edx
80103dca:	89 cb                	mov    %ecx,%ebx
80103dcc:	b8 13 00 00 00       	mov    $0x13,%eax
80103dd1:	89 d7                	mov    %edx,%edi
80103dd3:	89 de                	mov    %ebx,%esi
80103dd5:	89 c1                	mov    %eax,%ecx
80103dd7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103dd9:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ddc:	8b 40 18             	mov    0x18(%eax),%eax
80103ddf:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80103de6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103ded:	eb 3b                	jmp    80103e2a <fork+0x102>
    if(curproc->ofile[i])
80103def:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103df2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103df5:	83 c2 08             	add    $0x8,%edx
80103df8:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103dfc:	85 c0                	test   %eax,%eax
80103dfe:	74 26                	je     80103e26 <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103e00:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e03:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e06:	83 c2 08             	add    $0x8,%edx
80103e09:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e0d:	83 ec 0c             	sub    $0xc,%esp
80103e10:	50                   	push   %eax
80103e11:	e8 21 d2 ff ff       	call   80101037 <filedup>
80103e16:	83 c4 10             	add    $0x10,%esp
80103e19:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e1c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103e1f:	83 c1 08             	add    $0x8,%ecx
80103e22:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80103e26:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103e2a:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103e2e:	7e bf                	jle    80103def <fork+0xc7>
  np->cwd = idup(curproc->cwd);
80103e30:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e33:	8b 40 68             	mov    0x68(%eax),%eax
80103e36:	83 ec 0c             	sub    $0xc,%esp
80103e39:	50                   	push   %eax
80103e3a:	e8 5e db ff ff       	call   8010199d <idup>
80103e3f:	83 c4 10             	add    $0x10,%esp
80103e42:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e45:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103e48:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e4b:	8d 50 6c             	lea    0x6c(%eax),%edx
80103e4e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e51:	83 c0 6c             	add    $0x6c,%eax
80103e54:	83 ec 04             	sub    $0x4,%esp
80103e57:	6a 10                	push   $0x10
80103e59:	52                   	push   %edx
80103e5a:	50                   	push   %eax
80103e5b:	e8 b4 0e 00 00       	call   80104d14 <safestrcpy>
80103e60:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103e63:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e66:	8b 40 10             	mov    0x10(%eax),%eax
80103e69:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103e6c:	83 ec 0c             	sub    $0xc,%esp
80103e6f:	68 00 42 19 80       	push   $0x80194200
80103e74:	e8 22 0a 00 00       	call   8010489b <acquire>
80103e79:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103e7c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e7f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e86:	83 ec 0c             	sub    $0xc,%esp
80103e89:	68 00 42 19 80       	push   $0x80194200
80103e8e:	e8 76 0a 00 00       	call   80104909 <release>
80103e93:	83 c4 10             	add    $0x10,%esp

  return pid;
80103e96:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80103e99:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103e9c:	5b                   	pop    %ebx
80103e9d:	5e                   	pop    %esi
80103e9e:	5f                   	pop    %edi
80103e9f:	5d                   	pop    %ebp
80103ea0:	c3                   	ret    

80103ea1 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80103ea1:	55                   	push   %ebp
80103ea2:	89 e5                	mov    %esp,%ebp
80103ea4:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80103ea7:	e8 7d fb ff ff       	call   80103a29 <myproc>
80103eac:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80103eaf:	a1 34 62 19 80       	mov    0x80196234,%eax
80103eb4:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103eb7:	75 0d                	jne    80103ec6 <exit+0x25>
    panic("init exiting");
80103eb9:	83 ec 0c             	sub    $0xc,%esp
80103ebc:	68 f2 a5 10 80       	push   $0x8010a5f2
80103ec1:	e8 e3 c6 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80103ec6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103ecd:	eb 3f                	jmp    80103f0e <exit+0x6d>
    if(curproc->ofile[fd]){
80103ecf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ed2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103ed5:	83 c2 08             	add    $0x8,%edx
80103ed8:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103edc:	85 c0                	test   %eax,%eax
80103ede:	74 2a                	je     80103f0a <exit+0x69>
      fileclose(curproc->ofile[fd]);
80103ee0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ee3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103ee6:	83 c2 08             	add    $0x8,%edx
80103ee9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103eed:	83 ec 0c             	sub    $0xc,%esp
80103ef0:	50                   	push   %eax
80103ef1:	e8 92 d1 ff ff       	call   80101088 <fileclose>
80103ef6:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80103ef9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103efc:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103eff:	83 c2 08             	add    $0x8,%edx
80103f02:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80103f09:	00 
  for(fd = 0; fd < NOFILE; fd++){
80103f0a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80103f0e:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80103f12:	7e bb                	jle    80103ecf <exit+0x2e>
    }
  }

  begin_op();
80103f14:	e8 10 f1 ff ff       	call   80103029 <begin_op>
  iput(curproc->cwd);
80103f19:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f1c:	8b 40 68             	mov    0x68(%eax),%eax
80103f1f:	83 ec 0c             	sub    $0xc,%esp
80103f22:	50                   	push   %eax
80103f23:	e8 10 dc ff ff       	call   80101b38 <iput>
80103f28:	83 c4 10             	add    $0x10,%esp
  end_op();
80103f2b:	e8 85 f1 ff ff       	call   801030b5 <end_op>
  curproc->cwd = 0;
80103f30:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f33:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80103f3a:	83 ec 0c             	sub    $0xc,%esp
80103f3d:	68 00 42 19 80       	push   $0x80194200
80103f42:	e8 54 09 00 00       	call   8010489b <acquire>
80103f47:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80103f4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f4d:	8b 40 14             	mov    0x14(%eax),%eax
80103f50:	83 ec 0c             	sub    $0xc,%esp
80103f53:	50                   	push   %eax
80103f54:	e8 20 04 00 00       	call   80104379 <wakeup1>
80103f59:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f5c:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103f63:	eb 37                	jmp    80103f9c <exit+0xfb>
    if(p->parent == curproc){
80103f65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f68:	8b 40 14             	mov    0x14(%eax),%eax
80103f6b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103f6e:	75 28                	jne    80103f98 <exit+0xf7>
      p->parent = initproc;
80103f70:	8b 15 34 62 19 80    	mov    0x80196234,%edx
80103f76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f79:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80103f7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f7f:	8b 40 0c             	mov    0xc(%eax),%eax
80103f82:	83 f8 05             	cmp    $0x5,%eax
80103f85:	75 11                	jne    80103f98 <exit+0xf7>
        wakeup1(initproc);
80103f87:	a1 34 62 19 80       	mov    0x80196234,%eax
80103f8c:	83 ec 0c             	sub    $0xc,%esp
80103f8f:	50                   	push   %eax
80103f90:	e8 e4 03 00 00       	call   80104379 <wakeup1>
80103f95:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f98:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80103f9c:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
80103fa3:	72 c0                	jb     80103f65 <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80103fa5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fa8:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80103faf:	e8 e5 01 00 00       	call   80104199 <sched>
  panic("zombie exit");
80103fb4:	83 ec 0c             	sub    $0xc,%esp
80103fb7:	68 ff a5 10 80       	push   $0x8010a5ff
80103fbc:	e8 e8 c5 ff ff       	call   801005a9 <panic>

80103fc1 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80103fc1:	55                   	push   %ebp
80103fc2:	89 e5                	mov    %esp,%ebp
80103fc4:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80103fc7:	e8 5d fa ff ff       	call   80103a29 <myproc>
80103fcc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80103fcf:	83 ec 0c             	sub    $0xc,%esp
80103fd2:	68 00 42 19 80       	push   $0x80194200
80103fd7:	e8 bf 08 00 00       	call   8010489b <acquire>
80103fdc:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80103fdf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103fe6:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103fed:	e9 a1 00 00 00       	jmp    80104093 <wait+0xd2>
      if(p->parent != curproc)
80103ff2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ff5:	8b 40 14             	mov    0x14(%eax),%eax
80103ff8:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103ffb:	0f 85 8d 00 00 00    	jne    8010408e <wait+0xcd>
        continue;
      havekids = 1;
80104001:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104008:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010400b:	8b 40 0c             	mov    0xc(%eax),%eax
8010400e:	83 f8 05             	cmp    $0x5,%eax
80104011:	75 7c                	jne    8010408f <wait+0xce>
        // Found one.
        pid = p->pid;
80104013:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104016:	8b 40 10             	mov    0x10(%eax),%eax
80104019:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
8010401c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010401f:	8b 40 08             	mov    0x8(%eax),%eax
80104022:	83 ec 0c             	sub    $0xc,%esp
80104025:	50                   	push   %eax
80104026:	e8 c8 e6 ff ff       	call   801026f3 <kfree>
8010402b:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
8010402e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104031:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104038:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010403b:	8b 40 04             	mov    0x4(%eax),%eax
8010403e:	83 ec 0c             	sub    $0xc,%esp
80104041:	50                   	push   %eax
80104042:	e8 7f 3a 00 00       	call   80107ac6 <freevm>
80104047:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
8010404a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010404d:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104054:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104057:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010405e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104061:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104065:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104068:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
8010406f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104072:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104079:	83 ec 0c             	sub    $0xc,%esp
8010407c:	68 00 42 19 80       	push   $0x80194200
80104081:	e8 83 08 00 00       	call   80104909 <release>
80104086:	83 c4 10             	add    $0x10,%esp
        return pid;
80104089:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010408c:	eb 51                	jmp    801040df <wait+0x11e>
        continue;
8010408e:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010408f:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104093:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
8010409a:	0f 82 52 ff ff ff    	jb     80103ff2 <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801040a0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801040a4:	74 0a                	je     801040b0 <wait+0xef>
801040a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040a9:	8b 40 24             	mov    0x24(%eax),%eax
801040ac:	85 c0                	test   %eax,%eax
801040ae:	74 17                	je     801040c7 <wait+0x106>
      release(&ptable.lock);
801040b0:	83 ec 0c             	sub    $0xc,%esp
801040b3:	68 00 42 19 80       	push   $0x80194200
801040b8:	e8 4c 08 00 00       	call   80104909 <release>
801040bd:	83 c4 10             	add    $0x10,%esp
      return -1;
801040c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040c5:	eb 18                	jmp    801040df <wait+0x11e>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801040c7:	83 ec 08             	sub    $0x8,%esp
801040ca:	68 00 42 19 80       	push   $0x80194200
801040cf:	ff 75 ec             	push   -0x14(%ebp)
801040d2:	e8 fb 01 00 00       	call   801042d2 <sleep>
801040d7:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801040da:	e9 00 ff ff ff       	jmp    80103fdf <wait+0x1e>
  }
}
801040df:	c9                   	leave  
801040e0:	c3                   	ret    

801040e1 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801040e1:	55                   	push   %ebp
801040e2:	89 e5                	mov    %esp,%ebp
801040e4:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801040e7:	e8 c5 f8 ff ff       	call   801039b1 <mycpu>
801040ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
801040ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040f2:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801040f9:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
801040fc:	e8 64 f8 ff ff       	call   80103965 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104101:	83 ec 0c             	sub    $0xc,%esp
80104104:	68 00 42 19 80       	push   $0x80194200
80104109:	e8 8d 07 00 00       	call   8010489b <acquire>
8010410e:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104111:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104118:	eb 61                	jmp    8010417b <scheduler+0x9a>
      if(p->state != RUNNABLE)
8010411a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010411d:	8b 40 0c             	mov    0xc(%eax),%eax
80104120:	83 f8 03             	cmp    $0x3,%eax
80104123:	75 51                	jne    80104176 <scheduler+0x95>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104125:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104128:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010412b:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104131:	83 ec 0c             	sub    $0xc,%esp
80104134:	ff 75 f4             	push   -0xc(%ebp)
80104137:	e8 e5 34 00 00       	call   80107621 <switchuvm>
8010413c:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
8010413f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104142:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104149:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010414c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010414f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104152:	83 c2 04             	add    $0x4,%edx
80104155:	83 ec 08             	sub    $0x8,%esp
80104158:	50                   	push   %eax
80104159:	52                   	push   %edx
8010415a:	e8 27 0c 00 00       	call   80104d86 <swtch>
8010415f:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104162:	e8 a1 34 00 00       	call   80107608 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104167:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010416a:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104171:	00 00 00 
80104174:	eb 01                	jmp    80104177 <scheduler+0x96>
        continue;
80104176:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104177:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
8010417b:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
80104182:	72 96                	jb     8010411a <scheduler+0x39>
    }
    release(&ptable.lock);
80104184:	83 ec 0c             	sub    $0xc,%esp
80104187:	68 00 42 19 80       	push   $0x80194200
8010418c:	e8 78 07 00 00       	call   80104909 <release>
80104191:	83 c4 10             	add    $0x10,%esp
    sti();
80104194:	e9 63 ff ff ff       	jmp    801040fc <scheduler+0x1b>

80104199 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104199:	55                   	push   %ebp
8010419a:	89 e5                	mov    %esp,%ebp
8010419c:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
8010419f:	e8 85 f8 ff ff       	call   80103a29 <myproc>
801041a4:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
801041a7:	83 ec 0c             	sub    $0xc,%esp
801041aa:	68 00 42 19 80       	push   $0x80194200
801041af:	e8 22 08 00 00       	call   801049d6 <holding>
801041b4:	83 c4 10             	add    $0x10,%esp
801041b7:	85 c0                	test   %eax,%eax
801041b9:	75 0d                	jne    801041c8 <sched+0x2f>
    panic("sched ptable.lock");
801041bb:	83 ec 0c             	sub    $0xc,%esp
801041be:	68 0b a6 10 80       	push   $0x8010a60b
801041c3:	e8 e1 c3 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
801041c8:	e8 e4 f7 ff ff       	call   801039b1 <mycpu>
801041cd:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801041d3:	83 f8 01             	cmp    $0x1,%eax
801041d6:	74 0d                	je     801041e5 <sched+0x4c>
    panic("sched locks");
801041d8:	83 ec 0c             	sub    $0xc,%esp
801041db:	68 1d a6 10 80       	push   $0x8010a61d
801041e0:	e8 c4 c3 ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
801041e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041e8:	8b 40 0c             	mov    0xc(%eax),%eax
801041eb:	83 f8 04             	cmp    $0x4,%eax
801041ee:	75 0d                	jne    801041fd <sched+0x64>
    panic("sched running");
801041f0:	83 ec 0c             	sub    $0xc,%esp
801041f3:	68 29 a6 10 80       	push   $0x8010a629
801041f8:	e8 ac c3 ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
801041fd:	e8 53 f7 ff ff       	call   80103955 <readeflags>
80104202:	25 00 02 00 00       	and    $0x200,%eax
80104207:	85 c0                	test   %eax,%eax
80104209:	74 0d                	je     80104218 <sched+0x7f>
    panic("sched interruptible");
8010420b:	83 ec 0c             	sub    $0xc,%esp
8010420e:	68 37 a6 10 80       	push   $0x8010a637
80104213:	e8 91 c3 ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
80104218:	e8 94 f7 ff ff       	call   801039b1 <mycpu>
8010421d:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104223:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104226:	e8 86 f7 ff ff       	call   801039b1 <mycpu>
8010422b:	8b 40 04             	mov    0x4(%eax),%eax
8010422e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104231:	83 c2 1c             	add    $0x1c,%edx
80104234:	83 ec 08             	sub    $0x8,%esp
80104237:	50                   	push   %eax
80104238:	52                   	push   %edx
80104239:	e8 48 0b 00 00       	call   80104d86 <swtch>
8010423e:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104241:	e8 6b f7 ff ff       	call   801039b1 <mycpu>
80104246:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104249:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
8010424f:	90                   	nop
80104250:	c9                   	leave  
80104251:	c3                   	ret    

80104252 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104252:	55                   	push   %ebp
80104253:	89 e5                	mov    %esp,%ebp
80104255:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104258:	83 ec 0c             	sub    $0xc,%esp
8010425b:	68 00 42 19 80       	push   $0x80194200
80104260:	e8 36 06 00 00       	call   8010489b <acquire>
80104265:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104268:	e8 bc f7 ff ff       	call   80103a29 <myproc>
8010426d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104274:	e8 20 ff ff ff       	call   80104199 <sched>
  release(&ptable.lock);
80104279:	83 ec 0c             	sub    $0xc,%esp
8010427c:	68 00 42 19 80       	push   $0x80194200
80104281:	e8 83 06 00 00       	call   80104909 <release>
80104286:	83 c4 10             	add    $0x10,%esp
}
80104289:	90                   	nop
8010428a:	c9                   	leave  
8010428b:	c3                   	ret    

8010428c <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010428c:	55                   	push   %ebp
8010428d:	89 e5                	mov    %esp,%ebp
8010428f:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104292:	83 ec 0c             	sub    $0xc,%esp
80104295:	68 00 42 19 80       	push   $0x80194200
8010429a:	e8 6a 06 00 00       	call   80104909 <release>
8010429f:	83 c4 10             	add    $0x10,%esp

  if (first) {
801042a2:	a1 04 f0 10 80       	mov    0x8010f004,%eax
801042a7:	85 c0                	test   %eax,%eax
801042a9:	74 24                	je     801042cf <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801042ab:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
801042b2:	00 00 00 
    iinit(ROOTDEV);
801042b5:	83 ec 0c             	sub    $0xc,%esp
801042b8:	6a 01                	push   $0x1
801042ba:	e8 a6 d3 ff ff       	call   80101665 <iinit>
801042bf:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801042c2:	83 ec 0c             	sub    $0xc,%esp
801042c5:	6a 01                	push   $0x1
801042c7:	e8 3e eb ff ff       	call   80102e0a <initlog>
801042cc:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801042cf:	90                   	nop
801042d0:	c9                   	leave  
801042d1:	c3                   	ret    

801042d2 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801042d2:	55                   	push   %ebp
801042d3:	89 e5                	mov    %esp,%ebp
801042d5:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
801042d8:	e8 4c f7 ff ff       	call   80103a29 <myproc>
801042dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801042e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801042e4:	75 0d                	jne    801042f3 <sleep+0x21>
    panic("sleep");
801042e6:	83 ec 0c             	sub    $0xc,%esp
801042e9:	68 4b a6 10 80       	push   $0x8010a64b
801042ee:	e8 b6 c2 ff ff       	call   801005a9 <panic>

  if(lk == 0)
801042f3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801042f7:	75 0d                	jne    80104306 <sleep+0x34>
    panic("sleep without lk");
801042f9:	83 ec 0c             	sub    $0xc,%esp
801042fc:	68 51 a6 10 80       	push   $0x8010a651
80104301:	e8 a3 c2 ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104306:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
8010430d:	74 1e                	je     8010432d <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
8010430f:	83 ec 0c             	sub    $0xc,%esp
80104312:	68 00 42 19 80       	push   $0x80194200
80104317:	e8 7f 05 00 00       	call   8010489b <acquire>
8010431c:	83 c4 10             	add    $0x10,%esp
    release(lk);
8010431f:	83 ec 0c             	sub    $0xc,%esp
80104322:	ff 75 0c             	push   0xc(%ebp)
80104325:	e8 df 05 00 00       	call   80104909 <release>
8010432a:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
8010432d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104330:	8b 55 08             	mov    0x8(%ebp),%edx
80104333:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104336:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104339:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104340:	e8 54 fe ff ff       	call   80104199 <sched>

  // Tidy up.
  p->chan = 0;
80104345:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104348:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
8010434f:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
80104356:	74 1e                	je     80104376 <sleep+0xa4>
    release(&ptable.lock);
80104358:	83 ec 0c             	sub    $0xc,%esp
8010435b:	68 00 42 19 80       	push   $0x80194200
80104360:	e8 a4 05 00 00       	call   80104909 <release>
80104365:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104368:	83 ec 0c             	sub    $0xc,%esp
8010436b:	ff 75 0c             	push   0xc(%ebp)
8010436e:	e8 28 05 00 00       	call   8010489b <acquire>
80104373:	83 c4 10             	add    $0x10,%esp
  }
}
80104376:	90                   	nop
80104377:	c9                   	leave  
80104378:	c3                   	ret    

80104379 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104379:	55                   	push   %ebp
8010437a:	89 e5                	mov    %esp,%ebp
8010437c:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010437f:	c7 45 fc 34 42 19 80 	movl   $0x80194234,-0x4(%ebp)
80104386:	eb 24                	jmp    801043ac <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104388:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010438b:	8b 40 0c             	mov    0xc(%eax),%eax
8010438e:	83 f8 02             	cmp    $0x2,%eax
80104391:	75 15                	jne    801043a8 <wakeup1+0x2f>
80104393:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104396:	8b 40 20             	mov    0x20(%eax),%eax
80104399:	39 45 08             	cmp    %eax,0x8(%ebp)
8010439c:	75 0a                	jne    801043a8 <wakeup1+0x2f>
      p->state = RUNNABLE;
8010439e:	8b 45 fc             	mov    -0x4(%ebp),%eax
801043a1:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043a8:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
801043ac:	81 7d fc 34 62 19 80 	cmpl   $0x80196234,-0x4(%ebp)
801043b3:	72 d3                	jb     80104388 <wakeup1+0xf>
}
801043b5:	90                   	nop
801043b6:	90                   	nop
801043b7:	c9                   	leave  
801043b8:	c3                   	ret    

801043b9 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801043b9:	55                   	push   %ebp
801043ba:	89 e5                	mov    %esp,%ebp
801043bc:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801043bf:	83 ec 0c             	sub    $0xc,%esp
801043c2:	68 00 42 19 80       	push   $0x80194200
801043c7:	e8 cf 04 00 00       	call   8010489b <acquire>
801043cc:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801043cf:	83 ec 0c             	sub    $0xc,%esp
801043d2:	ff 75 08             	push   0x8(%ebp)
801043d5:	e8 9f ff ff ff       	call   80104379 <wakeup1>
801043da:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801043dd:	83 ec 0c             	sub    $0xc,%esp
801043e0:	68 00 42 19 80       	push   $0x80194200
801043e5:	e8 1f 05 00 00       	call   80104909 <release>
801043ea:	83 c4 10             	add    $0x10,%esp
}
801043ed:	90                   	nop
801043ee:	c9                   	leave  
801043ef:	c3                   	ret    

801043f0 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801043f0:	55                   	push   %ebp
801043f1:	89 e5                	mov    %esp,%ebp
801043f3:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801043f6:	83 ec 0c             	sub    $0xc,%esp
801043f9:	68 00 42 19 80       	push   $0x80194200
801043fe:	e8 98 04 00 00       	call   8010489b <acquire>
80104403:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104406:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
8010440d:	eb 45                	jmp    80104454 <kill+0x64>
    if(p->pid == pid){
8010440f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104412:	8b 40 10             	mov    0x10(%eax),%eax
80104415:	39 45 08             	cmp    %eax,0x8(%ebp)
80104418:	75 36                	jne    80104450 <kill+0x60>
      p->killed = 1;
8010441a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010441d:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104424:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104427:	8b 40 0c             	mov    0xc(%eax),%eax
8010442a:	83 f8 02             	cmp    $0x2,%eax
8010442d:	75 0a                	jne    80104439 <kill+0x49>
        p->state = RUNNABLE;
8010442f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104432:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104439:	83 ec 0c             	sub    $0xc,%esp
8010443c:	68 00 42 19 80       	push   $0x80194200
80104441:	e8 c3 04 00 00       	call   80104909 <release>
80104446:	83 c4 10             	add    $0x10,%esp
      return 0;
80104449:	b8 00 00 00 00       	mov    $0x0,%eax
8010444e:	eb 22                	jmp    80104472 <kill+0x82>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104450:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104454:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
8010445b:	72 b2                	jb     8010440f <kill+0x1f>
    }
  }
  release(&ptable.lock);
8010445d:	83 ec 0c             	sub    $0xc,%esp
80104460:	68 00 42 19 80       	push   $0x80194200
80104465:	e8 9f 04 00 00       	call   80104909 <release>
8010446a:	83 c4 10             	add    $0x10,%esp
  return -1;
8010446d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104472:	c9                   	leave  
80104473:	c3                   	ret    

80104474 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104474:	55                   	push   %ebp
80104475:	89 e5                	mov    %esp,%ebp
80104477:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010447a:	c7 45 f0 34 42 19 80 	movl   $0x80194234,-0x10(%ebp)
80104481:	e9 d7 00 00 00       	jmp    8010455d <procdump+0xe9>
    if(p->state == UNUSED)
80104486:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104489:	8b 40 0c             	mov    0xc(%eax),%eax
8010448c:	85 c0                	test   %eax,%eax
8010448e:	0f 84 c4 00 00 00    	je     80104558 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104494:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104497:	8b 40 0c             	mov    0xc(%eax),%eax
8010449a:	83 f8 05             	cmp    $0x5,%eax
8010449d:	77 23                	ja     801044c2 <procdump+0x4e>
8010449f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044a2:	8b 40 0c             	mov    0xc(%eax),%eax
801044a5:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801044ac:	85 c0                	test   %eax,%eax
801044ae:	74 12                	je     801044c2 <procdump+0x4e>
      state = states[p->state];
801044b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044b3:	8b 40 0c             	mov    0xc(%eax),%eax
801044b6:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801044bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
801044c0:	eb 07                	jmp    801044c9 <procdump+0x55>
    else
      state = "???";
801044c2:	c7 45 ec 62 a6 10 80 	movl   $0x8010a662,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801044c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044cc:	8d 50 6c             	lea    0x6c(%eax),%edx
801044cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044d2:	8b 40 10             	mov    0x10(%eax),%eax
801044d5:	52                   	push   %edx
801044d6:	ff 75 ec             	push   -0x14(%ebp)
801044d9:	50                   	push   %eax
801044da:	68 66 a6 10 80       	push   $0x8010a666
801044df:	e8 10 bf ff ff       	call   801003f4 <cprintf>
801044e4:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801044e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044ea:	8b 40 0c             	mov    0xc(%eax),%eax
801044ed:	83 f8 02             	cmp    $0x2,%eax
801044f0:	75 54                	jne    80104546 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801044f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044f5:	8b 40 1c             	mov    0x1c(%eax),%eax
801044f8:	8b 40 0c             	mov    0xc(%eax),%eax
801044fb:	83 c0 08             	add    $0x8,%eax
801044fe:	89 c2                	mov    %eax,%edx
80104500:	83 ec 08             	sub    $0x8,%esp
80104503:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104506:	50                   	push   %eax
80104507:	52                   	push   %edx
80104508:	e8 4e 04 00 00       	call   8010495b <getcallerpcs>
8010450d:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104510:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104517:	eb 1c                	jmp    80104535 <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104519:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451c:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104520:	83 ec 08             	sub    $0x8,%esp
80104523:	50                   	push   %eax
80104524:	68 6f a6 10 80       	push   $0x8010a66f
80104529:	e8 c6 be ff ff       	call   801003f4 <cprintf>
8010452e:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104531:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104535:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104539:	7f 0b                	jg     80104546 <procdump+0xd2>
8010453b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010453e:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104542:	85 c0                	test   %eax,%eax
80104544:	75 d3                	jne    80104519 <procdump+0xa5>
    }
    cprintf("\n");
80104546:	83 ec 0c             	sub    $0xc,%esp
80104549:	68 73 a6 10 80       	push   $0x8010a673
8010454e:	e8 a1 be ff ff       	call   801003f4 <cprintf>
80104553:	83 c4 10             	add    $0x10,%esp
80104556:	eb 01                	jmp    80104559 <procdump+0xe5>
      continue;
80104558:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104559:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
8010455d:	81 7d f0 34 62 19 80 	cmpl   $0x80196234,-0x10(%ebp)
80104564:	0f 82 1c ff ff ff    	jb     80104486 <procdump+0x12>
  }
}
8010456a:	90                   	nop
8010456b:	90                   	nop
8010456c:	c9                   	leave  
8010456d:	c3                   	ret    

8010456e <printpt>:

int
printpt(int pid)
{
8010456e:	55                   	push   %ebp
8010456f:	89 e5                	mov    %esp,%ebp
80104571:	56                   	push   %esi
80104572:	53                   	push   %ebx
80104573:	83 ec 20             	sub    $0x20,%esp

  struct proc *p;
  pte_t *pgdir = 0;
80104576:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  acquire(&ptable.lock);
8010457d:	83 ec 0c             	sub    $0xc,%esp
80104580:	68 00 42 19 80       	push   $0x80194200
80104585:	e8 11 03 00 00       	call   8010489b <acquire>
8010458a:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010458d:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104594:	eb 1a                	jmp    801045b0 <printpt+0x42>
    if(p->pid == pid) {
80104596:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104599:	8b 40 10             	mov    0x10(%eax),%eax
8010459c:	39 45 08             	cmp    %eax,0x8(%ebp)
8010459f:	75 0b                	jne    801045ac <printpt+0x3e>
      pgdir = p->pgdir;
801045a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a4:	8b 40 04             	mov    0x4(%eax),%eax
801045a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
      break;
801045aa:	eb 0d                	jmp    801045b9 <printpt+0x4b>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801045ac:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801045b0:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
801045b7:	72 dd                	jb     80104596 <printpt+0x28>
    }
  }
  release(&ptable.lock);
801045b9:	83 ec 0c             	sub    $0xc,%esp
801045bc:	68 00 42 19 80       	push   $0x80194200
801045c1:	e8 43 03 00 00       	call   80104909 <release>
801045c6:	83 c4 10             	add    $0x10,%esp

  
  cprintf("START PAGE TABLE (pid %d)\n", pid);
801045c9:	83 ec 08             	sub    $0x8,%esp
801045cc:	ff 75 08             	push   0x8(%ebp)
801045cf:	68 75 a6 10 80       	push   $0x8010a675
801045d4:	e8 1b be ff ff       	call   801003f4 <cprintf>
801045d9:	83 c4 10             	add    $0x10,%esp

  for (int i = 0; i < 512; i++) { // pgdir[512] 부턴 커널 영역이므로 512로 제한
801045dc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801045e3:	e9 f2 00 00 00       	jmp    801046da <printpt+0x16c>
      if (pgdir[i] & PTE_P) {   // PTE_P = 현재 PTE
801045e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801045eb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801045f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045f5:	01 d0                	add    %edx,%eax
801045f7:	8b 00                	mov    (%eax),%eax
801045f9:	83 e0 01             	and    $0x1,%eax
801045fc:	85 c0                	test   %eax,%eax
801045fe:	0f 84 d2 00 00 00    	je     801046d6 <printpt+0x168>
          pte_t *pte = (pte_t *)P2V(PTE_ADDR(pgdir[i]));
80104604:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104607:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010460e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104611:	01 d0                	add    %edx,%eax
80104613:	8b 00                	mov    (%eax),%eax
80104615:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010461a:	05 00 00 00 80       	add    $0x80000000,%eax
8010461f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
          for (int j = 0; j < NPTENTRIES; j++) {
80104622:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
80104629:	e9 9b 00 00 00       	jmp    801046c9 <printpt+0x15b>
              if (pte[j] & PTE_P) {
8010462e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104631:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104638:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010463b:	01 d0                	add    %edx,%eax
8010463d:	8b 00                	mov    (%eax),%eax
8010463f:	83 e0 01             	and    $0x1,%eax
80104642:	85 c0                	test   %eax,%eax
80104644:	74 7f                	je     801046c5 <printpt+0x157>
                  cprintf("%x P %s %s %x\n", 
                          i * NPTENTRIES + j,
                          (pte[j] & PTE_U) ? "U" : "K",
                          (pte[j] & PTE_W) ? "W" : "-",
                          PTE_ADDR(pte[j]) >> PTXSHIFT);
80104646:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104649:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104650:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104653:	01 d0                	add    %edx,%eax
80104655:	8b 00                	mov    (%eax),%eax
                  cprintf("%x P %s %s %x\n", 
80104657:	c1 e8 0c             	shr    $0xc,%eax
8010465a:	89 c2                	mov    %eax,%edx
                          (pte[j] & PTE_W) ? "W" : "-",
8010465c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010465f:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80104666:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104669:	01 c8                	add    %ecx,%eax
8010466b:	8b 00                	mov    (%eax),%eax
8010466d:	83 e0 02             	and    $0x2,%eax
                  cprintf("%x P %s %s %x\n", 
80104670:	85 c0                	test   %eax,%eax
80104672:	74 07                	je     8010467b <printpt+0x10d>
80104674:	bb 90 a6 10 80       	mov    $0x8010a690,%ebx
80104679:	eb 05                	jmp    80104680 <printpt+0x112>
8010467b:	bb 92 a6 10 80       	mov    $0x8010a692,%ebx
                          (pte[j] & PTE_U) ? "U" : "K",
80104680:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104683:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
8010468a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010468d:	01 c8                	add    %ecx,%eax
8010468f:	8b 00                	mov    (%eax),%eax
80104691:	83 e0 04             	and    $0x4,%eax
                  cprintf("%x P %s %s %x\n", 
80104694:	85 c0                	test   %eax,%eax
80104696:	74 07                	je     8010469f <printpt+0x131>
80104698:	b9 94 a6 10 80       	mov    $0x8010a694,%ecx
8010469d:	eb 05                	jmp    801046a4 <printpt+0x136>
8010469f:	b9 96 a6 10 80       	mov    $0x8010a696,%ecx
                          i * NPTENTRIES + j,
801046a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801046a7:	c1 e0 0a             	shl    $0xa,%eax
801046aa:	89 c6                	mov    %eax,%esi
                  cprintf("%x P %s %s %x\n", 
801046ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
801046af:	01 f0                	add    %esi,%eax
801046b1:	83 ec 0c             	sub    $0xc,%esp
801046b4:	52                   	push   %edx
801046b5:	53                   	push   %ebx
801046b6:	51                   	push   %ecx
801046b7:	50                   	push   %eax
801046b8:	68 98 a6 10 80       	push   $0x8010a698
801046bd:	e8 32 bd ff ff       	call   801003f4 <cprintf>
801046c2:	83 c4 20             	add    $0x20,%esp
          for (int j = 0; j < NPTENTRIES; j++) {
801046c5:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
801046c9:	81 7d e8 ff 03 00 00 	cmpl   $0x3ff,-0x18(%ebp)
801046d0:	0f 8e 58 ff ff ff    	jle    8010462e <printpt+0xc0>
  for (int i = 0; i < 512; i++) { // pgdir[512] 부턴 커널 영역이므로 512로 제한
801046d6:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801046da:	81 7d ec ff 01 00 00 	cmpl   $0x1ff,-0x14(%ebp)
801046e1:	0f 8e 01 ff ff ff    	jle    801045e8 <printpt+0x7a>
                          // PTXSHIFT = 페이지 크기에 대한 시프트 값 > 페이지 크기가 4KB면 12비트
              }
          }
      }
  } 
  cprintf("END PAGE TABLE\n");
801046e7:	83 ec 0c             	sub    $0xc,%esp
801046ea:	68 a7 a6 10 80       	push   $0x8010a6a7
801046ef:	e8 00 bd ff ff       	call   801003f4 <cprintf>
801046f4:	83 c4 10             	add    $0x10,%esp

  lcr3(V2P(myproc()->pgdir)); // Flushing TLBs
801046f7:	e8 2d f3 ff ff       	call   80103a29 <myproc>
801046fc:	8b 40 04             	mov    0x4(%eax),%eax
801046ff:	05 00 00 00 80       	add    $0x80000000,%eax
80104704:	83 ec 0c             	sub    $0xc,%esp
80104707:	50                   	push   %eax
80104708:	e8 5f f2 ff ff       	call   8010396c <lcr3>
8010470d:	83 c4 10             	add    $0x10,%esp

  return 0;
80104710:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104715:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104718:	5b                   	pop    %ebx
80104719:	5e                   	pop    %esi
8010471a:	5d                   	pop    %ebp
8010471b:	c3                   	ret    

8010471c <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
8010471c:	55                   	push   %ebp
8010471d:	89 e5                	mov    %esp,%ebp
8010471f:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104722:	8b 45 08             	mov    0x8(%ebp),%eax
80104725:	83 c0 04             	add    $0x4,%eax
80104728:	83 ec 08             	sub    $0x8,%esp
8010472b:	68 e1 a6 10 80       	push   $0x8010a6e1
80104730:	50                   	push   %eax
80104731:	e8 43 01 00 00       	call   80104879 <initlock>
80104736:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104739:	8b 45 08             	mov    0x8(%ebp),%eax
8010473c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010473f:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104742:	8b 45 08             	mov    0x8(%ebp),%eax
80104745:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010474b:	8b 45 08             	mov    0x8(%ebp),%eax
8010474e:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104755:	90                   	nop
80104756:	c9                   	leave  
80104757:	c3                   	ret    

80104758 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104758:	55                   	push   %ebp
80104759:	89 e5                	mov    %esp,%ebp
8010475b:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
8010475e:	8b 45 08             	mov    0x8(%ebp),%eax
80104761:	83 c0 04             	add    $0x4,%eax
80104764:	83 ec 0c             	sub    $0xc,%esp
80104767:	50                   	push   %eax
80104768:	e8 2e 01 00 00       	call   8010489b <acquire>
8010476d:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104770:	eb 15                	jmp    80104787 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104772:	8b 45 08             	mov    0x8(%ebp),%eax
80104775:	83 c0 04             	add    $0x4,%eax
80104778:	83 ec 08             	sub    $0x8,%esp
8010477b:	50                   	push   %eax
8010477c:	ff 75 08             	push   0x8(%ebp)
8010477f:	e8 4e fb ff ff       	call   801042d2 <sleep>
80104784:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104787:	8b 45 08             	mov    0x8(%ebp),%eax
8010478a:	8b 00                	mov    (%eax),%eax
8010478c:	85 c0                	test   %eax,%eax
8010478e:	75 e2                	jne    80104772 <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104790:	8b 45 08             	mov    0x8(%ebp),%eax
80104793:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104799:	e8 8b f2 ff ff       	call   80103a29 <myproc>
8010479e:	8b 50 10             	mov    0x10(%eax),%edx
801047a1:	8b 45 08             	mov    0x8(%ebp),%eax
801047a4:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
801047a7:	8b 45 08             	mov    0x8(%ebp),%eax
801047aa:	83 c0 04             	add    $0x4,%eax
801047ad:	83 ec 0c             	sub    $0xc,%esp
801047b0:	50                   	push   %eax
801047b1:	e8 53 01 00 00       	call   80104909 <release>
801047b6:	83 c4 10             	add    $0x10,%esp
}
801047b9:	90                   	nop
801047ba:	c9                   	leave  
801047bb:	c3                   	ret    

801047bc <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801047bc:	55                   	push   %ebp
801047bd:	89 e5                	mov    %esp,%ebp
801047bf:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801047c2:	8b 45 08             	mov    0x8(%ebp),%eax
801047c5:	83 c0 04             	add    $0x4,%eax
801047c8:	83 ec 0c             	sub    $0xc,%esp
801047cb:	50                   	push   %eax
801047cc:	e8 ca 00 00 00       	call   8010489b <acquire>
801047d1:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
801047d4:	8b 45 08             	mov    0x8(%ebp),%eax
801047d7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801047dd:	8b 45 08             	mov    0x8(%ebp),%eax
801047e0:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
801047e7:	83 ec 0c             	sub    $0xc,%esp
801047ea:	ff 75 08             	push   0x8(%ebp)
801047ed:	e8 c7 fb ff ff       	call   801043b9 <wakeup>
801047f2:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
801047f5:	8b 45 08             	mov    0x8(%ebp),%eax
801047f8:	83 c0 04             	add    $0x4,%eax
801047fb:	83 ec 0c             	sub    $0xc,%esp
801047fe:	50                   	push   %eax
801047ff:	e8 05 01 00 00       	call   80104909 <release>
80104804:	83 c4 10             	add    $0x10,%esp
}
80104807:	90                   	nop
80104808:	c9                   	leave  
80104809:	c3                   	ret    

8010480a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
8010480a:	55                   	push   %ebp
8010480b:	89 e5                	mov    %esp,%ebp
8010480d:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104810:	8b 45 08             	mov    0x8(%ebp),%eax
80104813:	83 c0 04             	add    $0x4,%eax
80104816:	83 ec 0c             	sub    $0xc,%esp
80104819:	50                   	push   %eax
8010481a:	e8 7c 00 00 00       	call   8010489b <acquire>
8010481f:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104822:	8b 45 08             	mov    0x8(%ebp),%eax
80104825:	8b 00                	mov    (%eax),%eax
80104827:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
8010482a:	8b 45 08             	mov    0x8(%ebp),%eax
8010482d:	83 c0 04             	add    $0x4,%eax
80104830:	83 ec 0c             	sub    $0xc,%esp
80104833:	50                   	push   %eax
80104834:	e8 d0 00 00 00       	call   80104909 <release>
80104839:	83 c4 10             	add    $0x10,%esp
  return r;
8010483c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010483f:	c9                   	leave  
80104840:	c3                   	ret    

80104841 <readeflags>:
{
80104841:	55                   	push   %ebp
80104842:	89 e5                	mov    %esp,%ebp
80104844:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104847:	9c                   	pushf  
80104848:	58                   	pop    %eax
80104849:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010484c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010484f:	c9                   	leave  
80104850:	c3                   	ret    

80104851 <cli>:
{
80104851:	55                   	push   %ebp
80104852:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104854:	fa                   	cli    
}
80104855:	90                   	nop
80104856:	5d                   	pop    %ebp
80104857:	c3                   	ret    

80104858 <sti>:
{
80104858:	55                   	push   %ebp
80104859:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010485b:	fb                   	sti    
}
8010485c:	90                   	nop
8010485d:	5d                   	pop    %ebp
8010485e:	c3                   	ret    

8010485f <xchg>:
{
8010485f:	55                   	push   %ebp
80104860:	89 e5                	mov    %esp,%ebp
80104862:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104865:	8b 55 08             	mov    0x8(%ebp),%edx
80104868:	8b 45 0c             	mov    0xc(%ebp),%eax
8010486b:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010486e:	f0 87 02             	lock xchg %eax,(%edx)
80104871:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104874:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104877:	c9                   	leave  
80104878:	c3                   	ret    

80104879 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104879:	55                   	push   %ebp
8010487a:	89 e5                	mov    %esp,%ebp
  lk->name = name;
8010487c:	8b 45 08             	mov    0x8(%ebp),%eax
8010487f:	8b 55 0c             	mov    0xc(%ebp),%edx
80104882:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104885:	8b 45 08             	mov    0x8(%ebp),%eax
80104888:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010488e:	8b 45 08             	mov    0x8(%ebp),%eax
80104891:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104898:	90                   	nop
80104899:	5d                   	pop    %ebp
8010489a:	c3                   	ret    

8010489b <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010489b:	55                   	push   %ebp
8010489c:	89 e5                	mov    %esp,%ebp
8010489e:	53                   	push   %ebx
8010489f:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801048a2:	e8 5f 01 00 00       	call   80104a06 <pushcli>
  if(holding(lk)){
801048a7:	8b 45 08             	mov    0x8(%ebp),%eax
801048aa:	83 ec 0c             	sub    $0xc,%esp
801048ad:	50                   	push   %eax
801048ae:	e8 23 01 00 00       	call   801049d6 <holding>
801048b3:	83 c4 10             	add    $0x10,%esp
801048b6:	85 c0                	test   %eax,%eax
801048b8:	74 0d                	je     801048c7 <acquire+0x2c>
    panic("acquire");
801048ba:	83 ec 0c             	sub    $0xc,%esp
801048bd:	68 ec a6 10 80       	push   $0x8010a6ec
801048c2:	e8 e2 bc ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
801048c7:	90                   	nop
801048c8:	8b 45 08             	mov    0x8(%ebp),%eax
801048cb:	83 ec 08             	sub    $0x8,%esp
801048ce:	6a 01                	push   $0x1
801048d0:	50                   	push   %eax
801048d1:	e8 89 ff ff ff       	call   8010485f <xchg>
801048d6:	83 c4 10             	add    $0x10,%esp
801048d9:	85 c0                	test   %eax,%eax
801048db:	75 eb                	jne    801048c8 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
801048dd:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
801048e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
801048e5:	e8 c7 f0 ff ff       	call   801039b1 <mycpu>
801048ea:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
801048ed:	8b 45 08             	mov    0x8(%ebp),%eax
801048f0:	83 c0 0c             	add    $0xc,%eax
801048f3:	83 ec 08             	sub    $0x8,%esp
801048f6:	50                   	push   %eax
801048f7:	8d 45 08             	lea    0x8(%ebp),%eax
801048fa:	50                   	push   %eax
801048fb:	e8 5b 00 00 00       	call   8010495b <getcallerpcs>
80104900:	83 c4 10             	add    $0x10,%esp
}
80104903:	90                   	nop
80104904:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104907:	c9                   	leave  
80104908:	c3                   	ret    

80104909 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104909:	55                   	push   %ebp
8010490a:	89 e5                	mov    %esp,%ebp
8010490c:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
8010490f:	83 ec 0c             	sub    $0xc,%esp
80104912:	ff 75 08             	push   0x8(%ebp)
80104915:	e8 bc 00 00 00       	call   801049d6 <holding>
8010491a:	83 c4 10             	add    $0x10,%esp
8010491d:	85 c0                	test   %eax,%eax
8010491f:	75 0d                	jne    8010492e <release+0x25>
    panic("release");
80104921:	83 ec 0c             	sub    $0xc,%esp
80104924:	68 f4 a6 10 80       	push   $0x8010a6f4
80104929:	e8 7b bc ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
8010492e:	8b 45 08             	mov    0x8(%ebp),%eax
80104931:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104938:	8b 45 08             	mov    0x8(%ebp),%eax
8010493b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104942:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104947:	8b 45 08             	mov    0x8(%ebp),%eax
8010494a:	8b 55 08             	mov    0x8(%ebp),%edx
8010494d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104953:	e8 fb 00 00 00       	call   80104a53 <popcli>
}
80104958:	90                   	nop
80104959:	c9                   	leave  
8010495a:	c3                   	ret    

8010495b <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010495b:	55                   	push   %ebp
8010495c:	89 e5                	mov    %esp,%ebp
8010495e:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104961:	8b 45 08             	mov    0x8(%ebp),%eax
80104964:	83 e8 08             	sub    $0x8,%eax
80104967:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010496a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104971:	eb 38                	jmp    801049ab <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104973:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104977:	74 53                	je     801049cc <getcallerpcs+0x71>
80104979:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104980:	76 4a                	jbe    801049cc <getcallerpcs+0x71>
80104982:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104986:	74 44                	je     801049cc <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104988:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010498b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104992:	8b 45 0c             	mov    0xc(%ebp),%eax
80104995:	01 c2                	add    %eax,%edx
80104997:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010499a:	8b 40 04             	mov    0x4(%eax),%eax
8010499d:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
8010499f:	8b 45 fc             	mov    -0x4(%ebp),%eax
801049a2:	8b 00                	mov    (%eax),%eax
801049a4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801049a7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801049ab:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801049af:	7e c2                	jle    80104973 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
801049b1:	eb 19                	jmp    801049cc <getcallerpcs+0x71>
    pcs[i] = 0;
801049b3:	8b 45 f8             	mov    -0x8(%ebp),%eax
801049b6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801049bd:	8b 45 0c             	mov    0xc(%ebp),%eax
801049c0:	01 d0                	add    %edx,%eax
801049c2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
801049c8:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801049cc:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801049d0:	7e e1                	jle    801049b3 <getcallerpcs+0x58>
}
801049d2:	90                   	nop
801049d3:	90                   	nop
801049d4:	c9                   	leave  
801049d5:	c3                   	ret    

801049d6 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801049d6:	55                   	push   %ebp
801049d7:	89 e5                	mov    %esp,%ebp
801049d9:	53                   	push   %ebx
801049da:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
801049dd:	8b 45 08             	mov    0x8(%ebp),%eax
801049e0:	8b 00                	mov    (%eax),%eax
801049e2:	85 c0                	test   %eax,%eax
801049e4:	74 16                	je     801049fc <holding+0x26>
801049e6:	8b 45 08             	mov    0x8(%ebp),%eax
801049e9:	8b 58 08             	mov    0x8(%eax),%ebx
801049ec:	e8 c0 ef ff ff       	call   801039b1 <mycpu>
801049f1:	39 c3                	cmp    %eax,%ebx
801049f3:	75 07                	jne    801049fc <holding+0x26>
801049f5:	b8 01 00 00 00       	mov    $0x1,%eax
801049fa:	eb 05                	jmp    80104a01 <holding+0x2b>
801049fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a01:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104a04:	c9                   	leave  
80104a05:	c3                   	ret    

80104a06 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104a06:	55                   	push   %ebp
80104a07:	89 e5                	mov    %esp,%ebp
80104a09:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104a0c:	e8 30 fe ff ff       	call   80104841 <readeflags>
80104a11:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104a14:	e8 38 fe ff ff       	call   80104851 <cli>
  if(mycpu()->ncli == 0)
80104a19:	e8 93 ef ff ff       	call   801039b1 <mycpu>
80104a1e:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104a24:	85 c0                	test   %eax,%eax
80104a26:	75 14                	jne    80104a3c <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80104a28:	e8 84 ef ff ff       	call   801039b1 <mycpu>
80104a2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a30:	81 e2 00 02 00 00    	and    $0x200,%edx
80104a36:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104a3c:	e8 70 ef ff ff       	call   801039b1 <mycpu>
80104a41:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104a47:	83 c2 01             	add    $0x1,%edx
80104a4a:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104a50:	90                   	nop
80104a51:	c9                   	leave  
80104a52:	c3                   	ret    

80104a53 <popcli>:

void
popcli(void)
{
80104a53:	55                   	push   %ebp
80104a54:	89 e5                	mov    %esp,%ebp
80104a56:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104a59:	e8 e3 fd ff ff       	call   80104841 <readeflags>
80104a5e:	25 00 02 00 00       	and    $0x200,%eax
80104a63:	85 c0                	test   %eax,%eax
80104a65:	74 0d                	je     80104a74 <popcli+0x21>
    panic("popcli - interruptible");
80104a67:	83 ec 0c             	sub    $0xc,%esp
80104a6a:	68 fc a6 10 80       	push   $0x8010a6fc
80104a6f:	e8 35 bb ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
80104a74:	e8 38 ef ff ff       	call   801039b1 <mycpu>
80104a79:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104a7f:	83 ea 01             	sub    $0x1,%edx
80104a82:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104a88:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104a8e:	85 c0                	test   %eax,%eax
80104a90:	79 0d                	jns    80104a9f <popcli+0x4c>
    panic("popcli");
80104a92:	83 ec 0c             	sub    $0xc,%esp
80104a95:	68 13 a7 10 80       	push   $0x8010a713
80104a9a:	e8 0a bb ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104a9f:	e8 0d ef ff ff       	call   801039b1 <mycpu>
80104aa4:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104aaa:	85 c0                	test   %eax,%eax
80104aac:	75 14                	jne    80104ac2 <popcli+0x6f>
80104aae:	e8 fe ee ff ff       	call   801039b1 <mycpu>
80104ab3:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104ab9:	85 c0                	test   %eax,%eax
80104abb:	74 05                	je     80104ac2 <popcli+0x6f>
    sti();
80104abd:	e8 96 fd ff ff       	call   80104858 <sti>
}
80104ac2:	90                   	nop
80104ac3:	c9                   	leave  
80104ac4:	c3                   	ret    

80104ac5 <stosb>:
{
80104ac5:	55                   	push   %ebp
80104ac6:	89 e5                	mov    %esp,%ebp
80104ac8:	57                   	push   %edi
80104ac9:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104aca:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104acd:	8b 55 10             	mov    0x10(%ebp),%edx
80104ad0:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ad3:	89 cb                	mov    %ecx,%ebx
80104ad5:	89 df                	mov    %ebx,%edi
80104ad7:	89 d1                	mov    %edx,%ecx
80104ad9:	fc                   	cld    
80104ada:	f3 aa                	rep stos %al,%es:(%edi)
80104adc:	89 ca                	mov    %ecx,%edx
80104ade:	89 fb                	mov    %edi,%ebx
80104ae0:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104ae3:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104ae6:	90                   	nop
80104ae7:	5b                   	pop    %ebx
80104ae8:	5f                   	pop    %edi
80104ae9:	5d                   	pop    %ebp
80104aea:	c3                   	ret    

80104aeb <stosl>:
{
80104aeb:	55                   	push   %ebp
80104aec:	89 e5                	mov    %esp,%ebp
80104aee:	57                   	push   %edi
80104aef:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104af0:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104af3:	8b 55 10             	mov    0x10(%ebp),%edx
80104af6:	8b 45 0c             	mov    0xc(%ebp),%eax
80104af9:	89 cb                	mov    %ecx,%ebx
80104afb:	89 df                	mov    %ebx,%edi
80104afd:	89 d1                	mov    %edx,%ecx
80104aff:	fc                   	cld    
80104b00:	f3 ab                	rep stos %eax,%es:(%edi)
80104b02:	89 ca                	mov    %ecx,%edx
80104b04:	89 fb                	mov    %edi,%ebx
80104b06:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104b09:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104b0c:	90                   	nop
80104b0d:	5b                   	pop    %ebx
80104b0e:	5f                   	pop    %edi
80104b0f:	5d                   	pop    %ebp
80104b10:	c3                   	ret    

80104b11 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104b11:	55                   	push   %ebp
80104b12:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104b14:	8b 45 08             	mov    0x8(%ebp),%eax
80104b17:	83 e0 03             	and    $0x3,%eax
80104b1a:	85 c0                	test   %eax,%eax
80104b1c:	75 43                	jne    80104b61 <memset+0x50>
80104b1e:	8b 45 10             	mov    0x10(%ebp),%eax
80104b21:	83 e0 03             	and    $0x3,%eax
80104b24:	85 c0                	test   %eax,%eax
80104b26:	75 39                	jne    80104b61 <memset+0x50>
    c &= 0xFF;
80104b28:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104b2f:	8b 45 10             	mov    0x10(%ebp),%eax
80104b32:	c1 e8 02             	shr    $0x2,%eax
80104b35:	89 c2                	mov    %eax,%edx
80104b37:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b3a:	c1 e0 18             	shl    $0x18,%eax
80104b3d:	89 c1                	mov    %eax,%ecx
80104b3f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b42:	c1 e0 10             	shl    $0x10,%eax
80104b45:	09 c1                	or     %eax,%ecx
80104b47:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b4a:	c1 e0 08             	shl    $0x8,%eax
80104b4d:	09 c8                	or     %ecx,%eax
80104b4f:	0b 45 0c             	or     0xc(%ebp),%eax
80104b52:	52                   	push   %edx
80104b53:	50                   	push   %eax
80104b54:	ff 75 08             	push   0x8(%ebp)
80104b57:	e8 8f ff ff ff       	call   80104aeb <stosl>
80104b5c:	83 c4 0c             	add    $0xc,%esp
80104b5f:	eb 12                	jmp    80104b73 <memset+0x62>
  } else
    stosb(dst, c, n);
80104b61:	8b 45 10             	mov    0x10(%ebp),%eax
80104b64:	50                   	push   %eax
80104b65:	ff 75 0c             	push   0xc(%ebp)
80104b68:	ff 75 08             	push   0x8(%ebp)
80104b6b:	e8 55 ff ff ff       	call   80104ac5 <stosb>
80104b70:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104b73:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104b76:	c9                   	leave  
80104b77:	c3                   	ret    

80104b78 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104b78:	55                   	push   %ebp
80104b79:	89 e5                	mov    %esp,%ebp
80104b7b:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104b7e:	8b 45 08             	mov    0x8(%ebp),%eax
80104b81:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104b84:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b87:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104b8a:	eb 30                	jmp    80104bbc <memcmp+0x44>
    if(*s1 != *s2)
80104b8c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b8f:	0f b6 10             	movzbl (%eax),%edx
80104b92:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104b95:	0f b6 00             	movzbl (%eax),%eax
80104b98:	38 c2                	cmp    %al,%dl
80104b9a:	74 18                	je     80104bb4 <memcmp+0x3c>
      return *s1 - *s2;
80104b9c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b9f:	0f b6 00             	movzbl (%eax),%eax
80104ba2:	0f b6 d0             	movzbl %al,%edx
80104ba5:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ba8:	0f b6 00             	movzbl (%eax),%eax
80104bab:	0f b6 c8             	movzbl %al,%ecx
80104bae:	89 d0                	mov    %edx,%eax
80104bb0:	29 c8                	sub    %ecx,%eax
80104bb2:	eb 1a                	jmp    80104bce <memcmp+0x56>
    s1++, s2++;
80104bb4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104bb8:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104bbc:	8b 45 10             	mov    0x10(%ebp),%eax
80104bbf:	8d 50 ff             	lea    -0x1(%eax),%edx
80104bc2:	89 55 10             	mov    %edx,0x10(%ebp)
80104bc5:	85 c0                	test   %eax,%eax
80104bc7:	75 c3                	jne    80104b8c <memcmp+0x14>
  }

  return 0;
80104bc9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104bce:	c9                   	leave  
80104bcf:	c3                   	ret    

80104bd0 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104bd0:	55                   	push   %ebp
80104bd1:	89 e5                	mov    %esp,%ebp
80104bd3:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104bd6:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bd9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104bdc:	8b 45 08             	mov    0x8(%ebp),%eax
80104bdf:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104be2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104be5:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104be8:	73 54                	jae    80104c3e <memmove+0x6e>
80104bea:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104bed:	8b 45 10             	mov    0x10(%ebp),%eax
80104bf0:	01 d0                	add    %edx,%eax
80104bf2:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104bf5:	73 47                	jae    80104c3e <memmove+0x6e>
    s += n;
80104bf7:	8b 45 10             	mov    0x10(%ebp),%eax
80104bfa:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104bfd:	8b 45 10             	mov    0x10(%ebp),%eax
80104c00:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104c03:	eb 13                	jmp    80104c18 <memmove+0x48>
      *--d = *--s;
80104c05:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104c09:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104c0d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c10:	0f b6 10             	movzbl (%eax),%edx
80104c13:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c16:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104c18:	8b 45 10             	mov    0x10(%ebp),%eax
80104c1b:	8d 50 ff             	lea    -0x1(%eax),%edx
80104c1e:	89 55 10             	mov    %edx,0x10(%ebp)
80104c21:	85 c0                	test   %eax,%eax
80104c23:	75 e0                	jne    80104c05 <memmove+0x35>
  if(s < d && s + n > d){
80104c25:	eb 24                	jmp    80104c4b <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104c27:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104c2a:	8d 42 01             	lea    0x1(%edx),%eax
80104c2d:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104c30:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c33:	8d 48 01             	lea    0x1(%eax),%ecx
80104c36:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104c39:	0f b6 12             	movzbl (%edx),%edx
80104c3c:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104c3e:	8b 45 10             	mov    0x10(%ebp),%eax
80104c41:	8d 50 ff             	lea    -0x1(%eax),%edx
80104c44:	89 55 10             	mov    %edx,0x10(%ebp)
80104c47:	85 c0                	test   %eax,%eax
80104c49:	75 dc                	jne    80104c27 <memmove+0x57>

  return dst;
80104c4b:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104c4e:	c9                   	leave  
80104c4f:	c3                   	ret    

80104c50 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104c50:	55                   	push   %ebp
80104c51:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104c53:	ff 75 10             	push   0x10(%ebp)
80104c56:	ff 75 0c             	push   0xc(%ebp)
80104c59:	ff 75 08             	push   0x8(%ebp)
80104c5c:	e8 6f ff ff ff       	call   80104bd0 <memmove>
80104c61:	83 c4 0c             	add    $0xc,%esp
}
80104c64:	c9                   	leave  
80104c65:	c3                   	ret    

80104c66 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104c66:	55                   	push   %ebp
80104c67:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104c69:	eb 0c                	jmp    80104c77 <strncmp+0x11>
    n--, p++, q++;
80104c6b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104c6f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104c73:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104c77:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104c7b:	74 1a                	je     80104c97 <strncmp+0x31>
80104c7d:	8b 45 08             	mov    0x8(%ebp),%eax
80104c80:	0f b6 00             	movzbl (%eax),%eax
80104c83:	84 c0                	test   %al,%al
80104c85:	74 10                	je     80104c97 <strncmp+0x31>
80104c87:	8b 45 08             	mov    0x8(%ebp),%eax
80104c8a:	0f b6 10             	movzbl (%eax),%edx
80104c8d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c90:	0f b6 00             	movzbl (%eax),%eax
80104c93:	38 c2                	cmp    %al,%dl
80104c95:	74 d4                	je     80104c6b <strncmp+0x5>
  if(n == 0)
80104c97:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104c9b:	75 07                	jne    80104ca4 <strncmp+0x3e>
    return 0;
80104c9d:	b8 00 00 00 00       	mov    $0x0,%eax
80104ca2:	eb 16                	jmp    80104cba <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80104ca4:	8b 45 08             	mov    0x8(%ebp),%eax
80104ca7:	0f b6 00             	movzbl (%eax),%eax
80104caa:	0f b6 d0             	movzbl %al,%edx
80104cad:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cb0:	0f b6 00             	movzbl (%eax),%eax
80104cb3:	0f b6 c8             	movzbl %al,%ecx
80104cb6:	89 d0                	mov    %edx,%eax
80104cb8:	29 c8                	sub    %ecx,%eax
}
80104cba:	5d                   	pop    %ebp
80104cbb:	c3                   	ret    

80104cbc <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104cbc:	55                   	push   %ebp
80104cbd:	89 e5                	mov    %esp,%ebp
80104cbf:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104cc2:	8b 45 08             	mov    0x8(%ebp),%eax
80104cc5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104cc8:	90                   	nop
80104cc9:	8b 45 10             	mov    0x10(%ebp),%eax
80104ccc:	8d 50 ff             	lea    -0x1(%eax),%edx
80104ccf:	89 55 10             	mov    %edx,0x10(%ebp)
80104cd2:	85 c0                	test   %eax,%eax
80104cd4:	7e 2c                	jle    80104d02 <strncpy+0x46>
80104cd6:	8b 55 0c             	mov    0xc(%ebp),%edx
80104cd9:	8d 42 01             	lea    0x1(%edx),%eax
80104cdc:	89 45 0c             	mov    %eax,0xc(%ebp)
80104cdf:	8b 45 08             	mov    0x8(%ebp),%eax
80104ce2:	8d 48 01             	lea    0x1(%eax),%ecx
80104ce5:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104ce8:	0f b6 12             	movzbl (%edx),%edx
80104ceb:	88 10                	mov    %dl,(%eax)
80104ced:	0f b6 00             	movzbl (%eax),%eax
80104cf0:	84 c0                	test   %al,%al
80104cf2:	75 d5                	jne    80104cc9 <strncpy+0xd>
    ;
  while(n-- > 0)
80104cf4:	eb 0c                	jmp    80104d02 <strncpy+0x46>
    *s++ = 0;
80104cf6:	8b 45 08             	mov    0x8(%ebp),%eax
80104cf9:	8d 50 01             	lea    0x1(%eax),%edx
80104cfc:	89 55 08             	mov    %edx,0x8(%ebp)
80104cff:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104d02:	8b 45 10             	mov    0x10(%ebp),%eax
80104d05:	8d 50 ff             	lea    -0x1(%eax),%edx
80104d08:	89 55 10             	mov    %edx,0x10(%ebp)
80104d0b:	85 c0                	test   %eax,%eax
80104d0d:	7f e7                	jg     80104cf6 <strncpy+0x3a>
  return os;
80104d0f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d12:	c9                   	leave  
80104d13:	c3                   	ret    

80104d14 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104d14:	55                   	push   %ebp
80104d15:	89 e5                	mov    %esp,%ebp
80104d17:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104d1a:	8b 45 08             	mov    0x8(%ebp),%eax
80104d1d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104d20:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104d24:	7f 05                	jg     80104d2b <safestrcpy+0x17>
    return os;
80104d26:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d29:	eb 32                	jmp    80104d5d <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80104d2b:	90                   	nop
80104d2c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104d30:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104d34:	7e 1e                	jle    80104d54 <safestrcpy+0x40>
80104d36:	8b 55 0c             	mov    0xc(%ebp),%edx
80104d39:	8d 42 01             	lea    0x1(%edx),%eax
80104d3c:	89 45 0c             	mov    %eax,0xc(%ebp)
80104d3f:	8b 45 08             	mov    0x8(%ebp),%eax
80104d42:	8d 48 01             	lea    0x1(%eax),%ecx
80104d45:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104d48:	0f b6 12             	movzbl (%edx),%edx
80104d4b:	88 10                	mov    %dl,(%eax)
80104d4d:	0f b6 00             	movzbl (%eax),%eax
80104d50:	84 c0                	test   %al,%al
80104d52:	75 d8                	jne    80104d2c <safestrcpy+0x18>
    ;
  *s = 0;
80104d54:	8b 45 08             	mov    0x8(%ebp),%eax
80104d57:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104d5a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d5d:	c9                   	leave  
80104d5e:	c3                   	ret    

80104d5f <strlen>:

int
strlen(const char *s)
{
80104d5f:	55                   	push   %ebp
80104d60:	89 e5                	mov    %esp,%ebp
80104d62:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104d65:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104d6c:	eb 04                	jmp    80104d72 <strlen+0x13>
80104d6e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104d72:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104d75:	8b 45 08             	mov    0x8(%ebp),%eax
80104d78:	01 d0                	add    %edx,%eax
80104d7a:	0f b6 00             	movzbl (%eax),%eax
80104d7d:	84 c0                	test   %al,%al
80104d7f:	75 ed                	jne    80104d6e <strlen+0xf>
    ;
  return n;
80104d81:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d84:	c9                   	leave  
80104d85:	c3                   	ret    

80104d86 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104d86:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104d8a:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104d8e:	55                   	push   %ebp
  pushl %ebx
80104d8f:	53                   	push   %ebx
  pushl %esi
80104d90:	56                   	push   %esi
  pushl %edi
80104d91:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104d92:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104d94:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104d96:	5f                   	pop    %edi
  popl %esi
80104d97:	5e                   	pop    %esi
  popl %ebx
80104d98:	5b                   	pop    %ebx
  popl %ebp
80104d99:	5d                   	pop    %ebp
  ret
80104d9a:	c3                   	ret    

80104d9b <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104d9b:	55                   	push   %ebp
80104d9c:	89 e5                	mov    %esp,%ebp

  if(addr >= KERNBASE || addr+4 > KERNBASE)
80104d9e:	8b 45 08             	mov    0x8(%ebp),%eax
80104da1:	85 c0                	test   %eax,%eax
80104da3:	78 0d                	js     80104db2 <fetchint+0x17>
80104da5:	8b 45 08             	mov    0x8(%ebp),%eax
80104da8:	83 c0 04             	add    $0x4,%eax
80104dab:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80104db0:	76 07                	jbe    80104db9 <fetchint+0x1e>
    return -1;
80104db2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104db7:	eb 0f                	jmp    80104dc8 <fetchint+0x2d>
  *ip = *(int*)(addr);
80104db9:	8b 45 08             	mov    0x8(%ebp),%eax
80104dbc:	8b 10                	mov    (%eax),%edx
80104dbe:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dc1:	89 10                	mov    %edx,(%eax)
  return 0;
80104dc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104dc8:	5d                   	pop    %ebp
80104dc9:	c3                   	ret    

80104dca <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104dca:	55                   	push   %ebp
80104dcb:	89 e5                	mov    %esp,%ebp
80104dcd:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= KERNBASE)
80104dd0:	8b 45 08             	mov    0x8(%ebp),%eax
80104dd3:	85 c0                	test   %eax,%eax
80104dd5:	79 07                	jns    80104dde <fetchstr+0x14>
    return -1;
80104dd7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ddc:	eb 40                	jmp    80104e1e <fetchstr+0x54>
  *pp = (char*)addr;
80104dde:	8b 55 08             	mov    0x8(%ebp),%edx
80104de1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104de4:	89 10                	mov    %edx,(%eax)
  ep = (char*)KERNBASE;
80104de6:	c7 45 f8 00 00 00 80 	movl   $0x80000000,-0x8(%ebp)
  for(s = *pp; s < ep; s++){
80104ded:	8b 45 0c             	mov    0xc(%ebp),%eax
80104df0:	8b 00                	mov    (%eax),%eax
80104df2:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104df5:	eb 1a                	jmp    80104e11 <fetchstr+0x47>
    if(*s == 0)
80104df7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104dfa:	0f b6 00             	movzbl (%eax),%eax
80104dfd:	84 c0                	test   %al,%al
80104dff:	75 0c                	jne    80104e0d <fetchstr+0x43>
      return s - *pp;
80104e01:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e04:	8b 10                	mov    (%eax),%edx
80104e06:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e09:	29 d0                	sub    %edx,%eax
80104e0b:	eb 11                	jmp    80104e1e <fetchstr+0x54>
  for(s = *pp; s < ep; s++){
80104e0d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104e11:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e14:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104e17:	72 de                	jb     80104df7 <fetchstr+0x2d>
  }
  return -1;
80104e19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104e1e:	c9                   	leave  
80104e1f:	c3                   	ret    

80104e20 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104e20:	55                   	push   %ebp
80104e21:	89 e5                	mov    %esp,%ebp
80104e23:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104e26:	e8 fe eb ff ff       	call   80103a29 <myproc>
80104e2b:	8b 40 18             	mov    0x18(%eax),%eax
80104e2e:	8b 50 44             	mov    0x44(%eax),%edx
80104e31:	8b 45 08             	mov    0x8(%ebp),%eax
80104e34:	c1 e0 02             	shl    $0x2,%eax
80104e37:	01 d0                	add    %edx,%eax
80104e39:	83 c0 04             	add    $0x4,%eax
80104e3c:	83 ec 08             	sub    $0x8,%esp
80104e3f:	ff 75 0c             	push   0xc(%ebp)
80104e42:	50                   	push   %eax
80104e43:	e8 53 ff ff ff       	call   80104d9b <fetchint>
80104e48:	83 c4 10             	add    $0x10,%esp
}
80104e4b:	c9                   	leave  
80104e4c:	c3                   	ret    

80104e4d <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104e4d:	55                   	push   %ebp
80104e4e:	89 e5                	mov    %esp,%ebp
80104e50:	83 ec 18             	sub    $0x18,%esp
  int i;
 
  if(argint(n, &i) < 0)
80104e53:	83 ec 08             	sub    $0x8,%esp
80104e56:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e59:	50                   	push   %eax
80104e5a:	ff 75 08             	push   0x8(%ebp)
80104e5d:	e8 be ff ff ff       	call   80104e20 <argint>
80104e62:	83 c4 10             	add    $0x10,%esp
80104e65:	85 c0                	test   %eax,%eax
80104e67:	79 07                	jns    80104e70 <argptr+0x23>
    return -1;
80104e69:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e6e:	eb 34                	jmp    80104ea4 <argptr+0x57>
  if(size < 0 || (uint)i >= KERNBASE || (uint)i+size > KERNBASE)
80104e70:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104e74:	78 18                	js     80104e8e <argptr+0x41>
80104e76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e79:	85 c0                	test   %eax,%eax
80104e7b:	78 11                	js     80104e8e <argptr+0x41>
80104e7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e80:	89 c2                	mov    %eax,%edx
80104e82:	8b 45 10             	mov    0x10(%ebp),%eax
80104e85:	01 d0                	add    %edx,%eax
80104e87:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80104e8c:	76 07                	jbe    80104e95 <argptr+0x48>
    return -1;
80104e8e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e93:	eb 0f                	jmp    80104ea4 <argptr+0x57>
  *pp = (char*)i;
80104e95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e98:	89 c2                	mov    %eax,%edx
80104e9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e9d:	89 10                	mov    %edx,(%eax)
  return 0;
80104e9f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104ea4:	c9                   	leave  
80104ea5:	c3                   	ret    

80104ea6 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104ea6:	55                   	push   %ebp
80104ea7:	89 e5                	mov    %esp,%ebp
80104ea9:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104eac:	83 ec 08             	sub    $0x8,%esp
80104eaf:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104eb2:	50                   	push   %eax
80104eb3:	ff 75 08             	push   0x8(%ebp)
80104eb6:	e8 65 ff ff ff       	call   80104e20 <argint>
80104ebb:	83 c4 10             	add    $0x10,%esp
80104ebe:	85 c0                	test   %eax,%eax
80104ec0:	79 07                	jns    80104ec9 <argstr+0x23>
    return -1;
80104ec2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ec7:	eb 12                	jmp    80104edb <argstr+0x35>
  return fetchstr(addr, pp);
80104ec9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ecc:	83 ec 08             	sub    $0x8,%esp
80104ecf:	ff 75 0c             	push   0xc(%ebp)
80104ed2:	50                   	push   %eax
80104ed3:	e8 f2 fe ff ff       	call   80104dca <fetchstr>
80104ed8:	83 c4 10             	add    $0x10,%esp
}
80104edb:	c9                   	leave  
80104edc:	c3                   	ret    

80104edd <syscall>:
[SYS_printpt] sys_printpt,
};

void
syscall(void)
{
80104edd:	55                   	push   %ebp
80104ede:	89 e5                	mov    %esp,%ebp
80104ee0:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80104ee3:	e8 41 eb ff ff       	call   80103a29 <myproc>
80104ee8:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80104eeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eee:	8b 40 18             	mov    0x18(%eax),%eax
80104ef1:	8b 40 1c             	mov    0x1c(%eax),%eax
80104ef4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104ef7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104efb:	7e 2f                	jle    80104f2c <syscall+0x4f>
80104efd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f00:	83 f8 16             	cmp    $0x16,%eax
80104f03:	77 27                	ja     80104f2c <syscall+0x4f>
80104f05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f08:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104f0f:	85 c0                	test   %eax,%eax
80104f11:	74 19                	je     80104f2c <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80104f13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f16:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104f1d:	ff d0                	call   *%eax
80104f1f:	89 c2                	mov    %eax,%edx
80104f21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f24:	8b 40 18             	mov    0x18(%eax),%eax
80104f27:	89 50 1c             	mov    %edx,0x1c(%eax)
80104f2a:	eb 2c                	jmp    80104f58 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80104f2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f2f:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104f32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f35:	8b 40 10             	mov    0x10(%eax),%eax
80104f38:	ff 75 f0             	push   -0x10(%ebp)
80104f3b:	52                   	push   %edx
80104f3c:	50                   	push   %eax
80104f3d:	68 1a a7 10 80       	push   $0x8010a71a
80104f42:	e8 ad b4 ff ff       	call   801003f4 <cprintf>
80104f47:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80104f4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f4d:	8b 40 18             	mov    0x18(%eax),%eax
80104f50:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80104f57:	90                   	nop
80104f58:	90                   	nop
80104f59:	c9                   	leave  
80104f5a:	c3                   	ret    

80104f5b <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104f5b:	55                   	push   %ebp
80104f5c:	89 e5                	mov    %esp,%ebp
80104f5e:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104f61:	83 ec 08             	sub    $0x8,%esp
80104f64:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104f67:	50                   	push   %eax
80104f68:	ff 75 08             	push   0x8(%ebp)
80104f6b:	e8 b0 fe ff ff       	call   80104e20 <argint>
80104f70:	83 c4 10             	add    $0x10,%esp
80104f73:	85 c0                	test   %eax,%eax
80104f75:	79 07                	jns    80104f7e <argfd+0x23>
    return -1;
80104f77:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f7c:	eb 4f                	jmp    80104fcd <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104f7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f81:	85 c0                	test   %eax,%eax
80104f83:	78 20                	js     80104fa5 <argfd+0x4a>
80104f85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f88:	83 f8 0f             	cmp    $0xf,%eax
80104f8b:	7f 18                	jg     80104fa5 <argfd+0x4a>
80104f8d:	e8 97 ea ff ff       	call   80103a29 <myproc>
80104f92:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f95:	83 c2 08             	add    $0x8,%edx
80104f98:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104f9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104f9f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104fa3:	75 07                	jne    80104fac <argfd+0x51>
    return -1;
80104fa5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104faa:	eb 21                	jmp    80104fcd <argfd+0x72>
  if(pfd)
80104fac:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104fb0:	74 08                	je     80104fba <argfd+0x5f>
    *pfd = fd;
80104fb2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104fb5:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fb8:	89 10                	mov    %edx,(%eax)
  if(pf)
80104fba:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104fbe:	74 08                	je     80104fc8 <argfd+0x6d>
    *pf = f;
80104fc0:	8b 45 10             	mov    0x10(%ebp),%eax
80104fc3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104fc6:	89 10                	mov    %edx,(%eax)
  return 0;
80104fc8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104fcd:	c9                   	leave  
80104fce:	c3                   	ret    

80104fcf <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80104fcf:	55                   	push   %ebp
80104fd0:	89 e5                	mov    %esp,%ebp
80104fd2:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80104fd5:	e8 4f ea ff ff       	call   80103a29 <myproc>
80104fda:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80104fdd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104fe4:	eb 2a                	jmp    80105010 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80104fe6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fe9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104fec:	83 c2 08             	add    $0x8,%edx
80104fef:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104ff3:	85 c0                	test   %eax,%eax
80104ff5:	75 15                	jne    8010500c <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80104ff7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ffa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ffd:	8d 4a 08             	lea    0x8(%edx),%ecx
80105000:	8b 55 08             	mov    0x8(%ebp),%edx
80105003:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105007:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010500a:	eb 0f                	jmp    8010501b <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
8010500c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105010:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105014:	7e d0                	jle    80104fe6 <fdalloc+0x17>
    }
  }
  return -1;
80105016:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010501b:	c9                   	leave  
8010501c:	c3                   	ret    

8010501d <sys_dup>:

int
sys_dup(void)
{
8010501d:	55                   	push   %ebp
8010501e:	89 e5                	mov    %esp,%ebp
80105020:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105023:	83 ec 04             	sub    $0x4,%esp
80105026:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105029:	50                   	push   %eax
8010502a:	6a 00                	push   $0x0
8010502c:	6a 00                	push   $0x0
8010502e:	e8 28 ff ff ff       	call   80104f5b <argfd>
80105033:	83 c4 10             	add    $0x10,%esp
80105036:	85 c0                	test   %eax,%eax
80105038:	79 07                	jns    80105041 <sys_dup+0x24>
    return -1;
8010503a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010503f:	eb 31                	jmp    80105072 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105041:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105044:	83 ec 0c             	sub    $0xc,%esp
80105047:	50                   	push   %eax
80105048:	e8 82 ff ff ff       	call   80104fcf <fdalloc>
8010504d:	83 c4 10             	add    $0x10,%esp
80105050:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105053:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105057:	79 07                	jns    80105060 <sys_dup+0x43>
    return -1;
80105059:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010505e:	eb 12                	jmp    80105072 <sys_dup+0x55>
  filedup(f);
80105060:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105063:	83 ec 0c             	sub    $0xc,%esp
80105066:	50                   	push   %eax
80105067:	e8 cb bf ff ff       	call   80101037 <filedup>
8010506c:	83 c4 10             	add    $0x10,%esp
  return fd;
8010506f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105072:	c9                   	leave  
80105073:	c3                   	ret    

80105074 <sys_read>:

int
sys_read(void)
{
80105074:	55                   	push   %ebp
80105075:	89 e5                	mov    %esp,%ebp
80105077:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010507a:	83 ec 04             	sub    $0x4,%esp
8010507d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105080:	50                   	push   %eax
80105081:	6a 00                	push   $0x0
80105083:	6a 00                	push   $0x0
80105085:	e8 d1 fe ff ff       	call   80104f5b <argfd>
8010508a:	83 c4 10             	add    $0x10,%esp
8010508d:	85 c0                	test   %eax,%eax
8010508f:	78 2e                	js     801050bf <sys_read+0x4b>
80105091:	83 ec 08             	sub    $0x8,%esp
80105094:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105097:	50                   	push   %eax
80105098:	6a 02                	push   $0x2
8010509a:	e8 81 fd ff ff       	call   80104e20 <argint>
8010509f:	83 c4 10             	add    $0x10,%esp
801050a2:	85 c0                	test   %eax,%eax
801050a4:	78 19                	js     801050bf <sys_read+0x4b>
801050a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050a9:	83 ec 04             	sub    $0x4,%esp
801050ac:	50                   	push   %eax
801050ad:	8d 45 ec             	lea    -0x14(%ebp),%eax
801050b0:	50                   	push   %eax
801050b1:	6a 01                	push   $0x1
801050b3:	e8 95 fd ff ff       	call   80104e4d <argptr>
801050b8:	83 c4 10             	add    $0x10,%esp
801050bb:	85 c0                	test   %eax,%eax
801050bd:	79 07                	jns    801050c6 <sys_read+0x52>
    return -1;
801050bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050c4:	eb 17                	jmp    801050dd <sys_read+0x69>
  return fileread(f, p, n);
801050c6:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801050c9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801050cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050cf:	83 ec 04             	sub    $0x4,%esp
801050d2:	51                   	push   %ecx
801050d3:	52                   	push   %edx
801050d4:	50                   	push   %eax
801050d5:	e8 ed c0 ff ff       	call   801011c7 <fileread>
801050da:	83 c4 10             	add    $0x10,%esp
}
801050dd:	c9                   	leave  
801050de:	c3                   	ret    

801050df <sys_write>:

int
sys_write(void)
{
801050df:	55                   	push   %ebp
801050e0:	89 e5                	mov    %esp,%ebp
801050e2:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801050e5:	83 ec 04             	sub    $0x4,%esp
801050e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801050eb:	50                   	push   %eax
801050ec:	6a 00                	push   $0x0
801050ee:	6a 00                	push   $0x0
801050f0:	e8 66 fe ff ff       	call   80104f5b <argfd>
801050f5:	83 c4 10             	add    $0x10,%esp
801050f8:	85 c0                	test   %eax,%eax
801050fa:	78 2e                	js     8010512a <sys_write+0x4b>
801050fc:	83 ec 08             	sub    $0x8,%esp
801050ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105102:	50                   	push   %eax
80105103:	6a 02                	push   $0x2
80105105:	e8 16 fd ff ff       	call   80104e20 <argint>
8010510a:	83 c4 10             	add    $0x10,%esp
8010510d:	85 c0                	test   %eax,%eax
8010510f:	78 19                	js     8010512a <sys_write+0x4b>
80105111:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105114:	83 ec 04             	sub    $0x4,%esp
80105117:	50                   	push   %eax
80105118:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010511b:	50                   	push   %eax
8010511c:	6a 01                	push   $0x1
8010511e:	e8 2a fd ff ff       	call   80104e4d <argptr>
80105123:	83 c4 10             	add    $0x10,%esp
80105126:	85 c0                	test   %eax,%eax
80105128:	79 07                	jns    80105131 <sys_write+0x52>
    return -1;
8010512a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010512f:	eb 17                	jmp    80105148 <sys_write+0x69>
  return filewrite(f, p, n);
80105131:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105134:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105137:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010513a:	83 ec 04             	sub    $0x4,%esp
8010513d:	51                   	push   %ecx
8010513e:	52                   	push   %edx
8010513f:	50                   	push   %eax
80105140:	e8 3a c1 ff ff       	call   8010127f <filewrite>
80105145:	83 c4 10             	add    $0x10,%esp
}
80105148:	c9                   	leave  
80105149:	c3                   	ret    

8010514a <sys_close>:

int
sys_close(void)
{
8010514a:	55                   	push   %ebp
8010514b:	89 e5                	mov    %esp,%ebp
8010514d:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105150:	83 ec 04             	sub    $0x4,%esp
80105153:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105156:	50                   	push   %eax
80105157:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010515a:	50                   	push   %eax
8010515b:	6a 00                	push   $0x0
8010515d:	e8 f9 fd ff ff       	call   80104f5b <argfd>
80105162:	83 c4 10             	add    $0x10,%esp
80105165:	85 c0                	test   %eax,%eax
80105167:	79 07                	jns    80105170 <sys_close+0x26>
    return -1;
80105169:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010516e:	eb 27                	jmp    80105197 <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
80105170:	e8 b4 e8 ff ff       	call   80103a29 <myproc>
80105175:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105178:	83 c2 08             	add    $0x8,%edx
8010517b:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105182:	00 
  fileclose(f);
80105183:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105186:	83 ec 0c             	sub    $0xc,%esp
80105189:	50                   	push   %eax
8010518a:	e8 f9 be ff ff       	call   80101088 <fileclose>
8010518f:	83 c4 10             	add    $0x10,%esp
  return 0;
80105192:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105197:	c9                   	leave  
80105198:	c3                   	ret    

80105199 <sys_fstat>:

int
sys_fstat(void)
{
80105199:	55                   	push   %ebp
8010519a:	89 e5                	mov    %esp,%ebp
8010519c:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010519f:	83 ec 04             	sub    $0x4,%esp
801051a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801051a5:	50                   	push   %eax
801051a6:	6a 00                	push   $0x0
801051a8:	6a 00                	push   $0x0
801051aa:	e8 ac fd ff ff       	call   80104f5b <argfd>
801051af:	83 c4 10             	add    $0x10,%esp
801051b2:	85 c0                	test   %eax,%eax
801051b4:	78 17                	js     801051cd <sys_fstat+0x34>
801051b6:	83 ec 04             	sub    $0x4,%esp
801051b9:	6a 14                	push   $0x14
801051bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801051be:	50                   	push   %eax
801051bf:	6a 01                	push   $0x1
801051c1:	e8 87 fc ff ff       	call   80104e4d <argptr>
801051c6:	83 c4 10             	add    $0x10,%esp
801051c9:	85 c0                	test   %eax,%eax
801051cb:	79 07                	jns    801051d4 <sys_fstat+0x3b>
    return -1;
801051cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051d2:	eb 13                	jmp    801051e7 <sys_fstat+0x4e>
  return filestat(f, st);
801051d4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801051d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051da:	83 ec 08             	sub    $0x8,%esp
801051dd:	52                   	push   %edx
801051de:	50                   	push   %eax
801051df:	e8 8c bf ff ff       	call   80101170 <filestat>
801051e4:	83 c4 10             	add    $0x10,%esp
}
801051e7:	c9                   	leave  
801051e8:	c3                   	ret    

801051e9 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801051e9:	55                   	push   %ebp
801051ea:	89 e5                	mov    %esp,%ebp
801051ec:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801051ef:	83 ec 08             	sub    $0x8,%esp
801051f2:	8d 45 d8             	lea    -0x28(%ebp),%eax
801051f5:	50                   	push   %eax
801051f6:	6a 00                	push   $0x0
801051f8:	e8 a9 fc ff ff       	call   80104ea6 <argstr>
801051fd:	83 c4 10             	add    $0x10,%esp
80105200:	85 c0                	test   %eax,%eax
80105202:	78 15                	js     80105219 <sys_link+0x30>
80105204:	83 ec 08             	sub    $0x8,%esp
80105207:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010520a:	50                   	push   %eax
8010520b:	6a 01                	push   $0x1
8010520d:	e8 94 fc ff ff       	call   80104ea6 <argstr>
80105212:	83 c4 10             	add    $0x10,%esp
80105215:	85 c0                	test   %eax,%eax
80105217:	79 0a                	jns    80105223 <sys_link+0x3a>
    return -1;
80105219:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010521e:	e9 68 01 00 00       	jmp    8010538b <sys_link+0x1a2>

  begin_op();
80105223:	e8 01 de ff ff       	call   80103029 <begin_op>
  if((ip = namei(old)) == 0){
80105228:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010522b:	83 ec 0c             	sub    $0xc,%esp
8010522e:	50                   	push   %eax
8010522f:	e8 d6 d2 ff ff       	call   8010250a <namei>
80105234:	83 c4 10             	add    $0x10,%esp
80105237:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010523a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010523e:	75 0f                	jne    8010524f <sys_link+0x66>
    end_op();
80105240:	e8 70 de ff ff       	call   801030b5 <end_op>
    return -1;
80105245:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010524a:	e9 3c 01 00 00       	jmp    8010538b <sys_link+0x1a2>
  }

  ilock(ip);
8010524f:	83 ec 0c             	sub    $0xc,%esp
80105252:	ff 75 f4             	push   -0xc(%ebp)
80105255:	e8 7d c7 ff ff       	call   801019d7 <ilock>
8010525a:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
8010525d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105260:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105264:	66 83 f8 01          	cmp    $0x1,%ax
80105268:	75 1d                	jne    80105287 <sys_link+0x9e>
    iunlockput(ip);
8010526a:	83 ec 0c             	sub    $0xc,%esp
8010526d:	ff 75 f4             	push   -0xc(%ebp)
80105270:	e8 93 c9 ff ff       	call   80101c08 <iunlockput>
80105275:	83 c4 10             	add    $0x10,%esp
    end_op();
80105278:	e8 38 de ff ff       	call   801030b5 <end_op>
    return -1;
8010527d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105282:	e9 04 01 00 00       	jmp    8010538b <sys_link+0x1a2>
  }

  ip->nlink++;
80105287:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010528a:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010528e:	83 c0 01             	add    $0x1,%eax
80105291:	89 c2                	mov    %eax,%edx
80105293:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105296:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010529a:	83 ec 0c             	sub    $0xc,%esp
8010529d:	ff 75 f4             	push   -0xc(%ebp)
801052a0:	e8 55 c5 ff ff       	call   801017fa <iupdate>
801052a5:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
801052a8:	83 ec 0c             	sub    $0xc,%esp
801052ab:	ff 75 f4             	push   -0xc(%ebp)
801052ae:	e8 37 c8 ff ff       	call   80101aea <iunlock>
801052b3:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
801052b6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801052b9:	83 ec 08             	sub    $0x8,%esp
801052bc:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801052bf:	52                   	push   %edx
801052c0:	50                   	push   %eax
801052c1:	e8 60 d2 ff ff       	call   80102526 <nameiparent>
801052c6:	83 c4 10             	add    $0x10,%esp
801052c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801052cc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801052d0:	74 71                	je     80105343 <sys_link+0x15a>
    goto bad;
  ilock(dp);
801052d2:	83 ec 0c             	sub    $0xc,%esp
801052d5:	ff 75 f0             	push   -0x10(%ebp)
801052d8:	e8 fa c6 ff ff       	call   801019d7 <ilock>
801052dd:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801052e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052e3:	8b 10                	mov    (%eax),%edx
801052e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052e8:	8b 00                	mov    (%eax),%eax
801052ea:	39 c2                	cmp    %eax,%edx
801052ec:	75 1d                	jne    8010530b <sys_link+0x122>
801052ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052f1:	8b 40 04             	mov    0x4(%eax),%eax
801052f4:	83 ec 04             	sub    $0x4,%esp
801052f7:	50                   	push   %eax
801052f8:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801052fb:	50                   	push   %eax
801052fc:	ff 75 f0             	push   -0x10(%ebp)
801052ff:	e8 6f cf ff ff       	call   80102273 <dirlink>
80105304:	83 c4 10             	add    $0x10,%esp
80105307:	85 c0                	test   %eax,%eax
80105309:	79 10                	jns    8010531b <sys_link+0x132>
    iunlockput(dp);
8010530b:	83 ec 0c             	sub    $0xc,%esp
8010530e:	ff 75 f0             	push   -0x10(%ebp)
80105311:	e8 f2 c8 ff ff       	call   80101c08 <iunlockput>
80105316:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105319:	eb 29                	jmp    80105344 <sys_link+0x15b>
  }
  iunlockput(dp);
8010531b:	83 ec 0c             	sub    $0xc,%esp
8010531e:	ff 75 f0             	push   -0x10(%ebp)
80105321:	e8 e2 c8 ff ff       	call   80101c08 <iunlockput>
80105326:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105329:	83 ec 0c             	sub    $0xc,%esp
8010532c:	ff 75 f4             	push   -0xc(%ebp)
8010532f:	e8 04 c8 ff ff       	call   80101b38 <iput>
80105334:	83 c4 10             	add    $0x10,%esp

  end_op();
80105337:	e8 79 dd ff ff       	call   801030b5 <end_op>

  return 0;
8010533c:	b8 00 00 00 00       	mov    $0x0,%eax
80105341:	eb 48                	jmp    8010538b <sys_link+0x1a2>
    goto bad;
80105343:	90                   	nop

bad:
  ilock(ip);
80105344:	83 ec 0c             	sub    $0xc,%esp
80105347:	ff 75 f4             	push   -0xc(%ebp)
8010534a:	e8 88 c6 ff ff       	call   801019d7 <ilock>
8010534f:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105352:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105355:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105359:	83 e8 01             	sub    $0x1,%eax
8010535c:	89 c2                	mov    %eax,%edx
8010535e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105361:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105365:	83 ec 0c             	sub    $0xc,%esp
80105368:	ff 75 f4             	push   -0xc(%ebp)
8010536b:	e8 8a c4 ff ff       	call   801017fa <iupdate>
80105370:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105373:	83 ec 0c             	sub    $0xc,%esp
80105376:	ff 75 f4             	push   -0xc(%ebp)
80105379:	e8 8a c8 ff ff       	call   80101c08 <iunlockput>
8010537e:	83 c4 10             	add    $0x10,%esp
  end_op();
80105381:	e8 2f dd ff ff       	call   801030b5 <end_op>
  return -1;
80105386:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010538b:	c9                   	leave  
8010538c:	c3                   	ret    

8010538d <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010538d:	55                   	push   %ebp
8010538e:	89 e5                	mov    %esp,%ebp
80105390:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105393:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
8010539a:	eb 40                	jmp    801053dc <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010539c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010539f:	6a 10                	push   $0x10
801053a1:	50                   	push   %eax
801053a2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801053a5:	50                   	push   %eax
801053a6:	ff 75 08             	push   0x8(%ebp)
801053a9:	e8 15 cb ff ff       	call   80101ec3 <readi>
801053ae:	83 c4 10             	add    $0x10,%esp
801053b1:	83 f8 10             	cmp    $0x10,%eax
801053b4:	74 0d                	je     801053c3 <isdirempty+0x36>
      panic("isdirempty: readi");
801053b6:	83 ec 0c             	sub    $0xc,%esp
801053b9:	68 36 a7 10 80       	push   $0x8010a736
801053be:	e8 e6 b1 ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
801053c3:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801053c7:	66 85 c0             	test   %ax,%ax
801053ca:	74 07                	je     801053d3 <isdirempty+0x46>
      return 0;
801053cc:	b8 00 00 00 00       	mov    $0x0,%eax
801053d1:	eb 1b                	jmp    801053ee <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801053d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053d6:	83 c0 10             	add    $0x10,%eax
801053d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801053dc:	8b 45 08             	mov    0x8(%ebp),%eax
801053df:	8b 50 58             	mov    0x58(%eax),%edx
801053e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053e5:	39 c2                	cmp    %eax,%edx
801053e7:	77 b3                	ja     8010539c <isdirempty+0xf>
  }
  return 1;
801053e9:	b8 01 00 00 00       	mov    $0x1,%eax
}
801053ee:	c9                   	leave  
801053ef:	c3                   	ret    

801053f0 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801053f0:	55                   	push   %ebp
801053f1:	89 e5                	mov    %esp,%ebp
801053f3:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801053f6:	83 ec 08             	sub    $0x8,%esp
801053f9:	8d 45 cc             	lea    -0x34(%ebp),%eax
801053fc:	50                   	push   %eax
801053fd:	6a 00                	push   $0x0
801053ff:	e8 a2 fa ff ff       	call   80104ea6 <argstr>
80105404:	83 c4 10             	add    $0x10,%esp
80105407:	85 c0                	test   %eax,%eax
80105409:	79 0a                	jns    80105415 <sys_unlink+0x25>
    return -1;
8010540b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105410:	e9 bf 01 00 00       	jmp    801055d4 <sys_unlink+0x1e4>

  begin_op();
80105415:	e8 0f dc ff ff       	call   80103029 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
8010541a:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010541d:	83 ec 08             	sub    $0x8,%esp
80105420:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105423:	52                   	push   %edx
80105424:	50                   	push   %eax
80105425:	e8 fc d0 ff ff       	call   80102526 <nameiparent>
8010542a:	83 c4 10             	add    $0x10,%esp
8010542d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105430:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105434:	75 0f                	jne    80105445 <sys_unlink+0x55>
    end_op();
80105436:	e8 7a dc ff ff       	call   801030b5 <end_op>
    return -1;
8010543b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105440:	e9 8f 01 00 00       	jmp    801055d4 <sys_unlink+0x1e4>
  }

  ilock(dp);
80105445:	83 ec 0c             	sub    $0xc,%esp
80105448:	ff 75 f4             	push   -0xc(%ebp)
8010544b:	e8 87 c5 ff ff       	call   801019d7 <ilock>
80105450:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105453:	83 ec 08             	sub    $0x8,%esp
80105456:	68 48 a7 10 80       	push   $0x8010a748
8010545b:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010545e:	50                   	push   %eax
8010545f:	e8 3a cd ff ff       	call   8010219e <namecmp>
80105464:	83 c4 10             	add    $0x10,%esp
80105467:	85 c0                	test   %eax,%eax
80105469:	0f 84 49 01 00 00    	je     801055b8 <sys_unlink+0x1c8>
8010546f:	83 ec 08             	sub    $0x8,%esp
80105472:	68 4a a7 10 80       	push   $0x8010a74a
80105477:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010547a:	50                   	push   %eax
8010547b:	e8 1e cd ff ff       	call   8010219e <namecmp>
80105480:	83 c4 10             	add    $0x10,%esp
80105483:	85 c0                	test   %eax,%eax
80105485:	0f 84 2d 01 00 00    	je     801055b8 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
8010548b:	83 ec 04             	sub    $0x4,%esp
8010548e:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105491:	50                   	push   %eax
80105492:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105495:	50                   	push   %eax
80105496:	ff 75 f4             	push   -0xc(%ebp)
80105499:	e8 1b cd ff ff       	call   801021b9 <dirlookup>
8010549e:	83 c4 10             	add    $0x10,%esp
801054a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801054a4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801054a8:	0f 84 0d 01 00 00    	je     801055bb <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
801054ae:	83 ec 0c             	sub    $0xc,%esp
801054b1:	ff 75 f0             	push   -0x10(%ebp)
801054b4:	e8 1e c5 ff ff       	call   801019d7 <ilock>
801054b9:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
801054bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054bf:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801054c3:	66 85 c0             	test   %ax,%ax
801054c6:	7f 0d                	jg     801054d5 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
801054c8:	83 ec 0c             	sub    $0xc,%esp
801054cb:	68 4d a7 10 80       	push   $0x8010a74d
801054d0:	e8 d4 b0 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801054d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054d8:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801054dc:	66 83 f8 01          	cmp    $0x1,%ax
801054e0:	75 25                	jne    80105507 <sys_unlink+0x117>
801054e2:	83 ec 0c             	sub    $0xc,%esp
801054e5:	ff 75 f0             	push   -0x10(%ebp)
801054e8:	e8 a0 fe ff ff       	call   8010538d <isdirempty>
801054ed:	83 c4 10             	add    $0x10,%esp
801054f0:	85 c0                	test   %eax,%eax
801054f2:	75 13                	jne    80105507 <sys_unlink+0x117>
    iunlockput(ip);
801054f4:	83 ec 0c             	sub    $0xc,%esp
801054f7:	ff 75 f0             	push   -0x10(%ebp)
801054fa:	e8 09 c7 ff ff       	call   80101c08 <iunlockput>
801054ff:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105502:	e9 b5 00 00 00       	jmp    801055bc <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80105507:	83 ec 04             	sub    $0x4,%esp
8010550a:	6a 10                	push   $0x10
8010550c:	6a 00                	push   $0x0
8010550e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105511:	50                   	push   %eax
80105512:	e8 fa f5 ff ff       	call   80104b11 <memset>
80105517:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010551a:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010551d:	6a 10                	push   $0x10
8010551f:	50                   	push   %eax
80105520:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105523:	50                   	push   %eax
80105524:	ff 75 f4             	push   -0xc(%ebp)
80105527:	e8 ec ca ff ff       	call   80102018 <writei>
8010552c:	83 c4 10             	add    $0x10,%esp
8010552f:	83 f8 10             	cmp    $0x10,%eax
80105532:	74 0d                	je     80105541 <sys_unlink+0x151>
    panic("unlink: writei");
80105534:	83 ec 0c             	sub    $0xc,%esp
80105537:	68 5f a7 10 80       	push   $0x8010a75f
8010553c:	e8 68 b0 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
80105541:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105544:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105548:	66 83 f8 01          	cmp    $0x1,%ax
8010554c:	75 21                	jne    8010556f <sys_unlink+0x17f>
    dp->nlink--;
8010554e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105551:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105555:	83 e8 01             	sub    $0x1,%eax
80105558:	89 c2                	mov    %eax,%edx
8010555a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010555d:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105561:	83 ec 0c             	sub    $0xc,%esp
80105564:	ff 75 f4             	push   -0xc(%ebp)
80105567:	e8 8e c2 ff ff       	call   801017fa <iupdate>
8010556c:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
8010556f:	83 ec 0c             	sub    $0xc,%esp
80105572:	ff 75 f4             	push   -0xc(%ebp)
80105575:	e8 8e c6 ff ff       	call   80101c08 <iunlockput>
8010557a:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
8010557d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105580:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105584:	83 e8 01             	sub    $0x1,%eax
80105587:	89 c2                	mov    %eax,%edx
80105589:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010558c:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105590:	83 ec 0c             	sub    $0xc,%esp
80105593:	ff 75 f0             	push   -0x10(%ebp)
80105596:	e8 5f c2 ff ff       	call   801017fa <iupdate>
8010559b:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010559e:	83 ec 0c             	sub    $0xc,%esp
801055a1:	ff 75 f0             	push   -0x10(%ebp)
801055a4:	e8 5f c6 ff ff       	call   80101c08 <iunlockput>
801055a9:	83 c4 10             	add    $0x10,%esp

  end_op();
801055ac:	e8 04 db ff ff       	call   801030b5 <end_op>

  return 0;
801055b1:	b8 00 00 00 00       	mov    $0x0,%eax
801055b6:	eb 1c                	jmp    801055d4 <sys_unlink+0x1e4>
    goto bad;
801055b8:	90                   	nop
801055b9:	eb 01                	jmp    801055bc <sys_unlink+0x1cc>
    goto bad;
801055bb:	90                   	nop

bad:
  iunlockput(dp);
801055bc:	83 ec 0c             	sub    $0xc,%esp
801055bf:	ff 75 f4             	push   -0xc(%ebp)
801055c2:	e8 41 c6 ff ff       	call   80101c08 <iunlockput>
801055c7:	83 c4 10             	add    $0x10,%esp
  end_op();
801055ca:	e8 e6 da ff ff       	call   801030b5 <end_op>
  return -1;
801055cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801055d4:	c9                   	leave  
801055d5:	c3                   	ret    

801055d6 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801055d6:	55                   	push   %ebp
801055d7:	89 e5                	mov    %esp,%ebp
801055d9:	83 ec 38             	sub    $0x38,%esp
801055dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801055df:	8b 55 10             	mov    0x10(%ebp),%edx
801055e2:	8b 45 14             	mov    0x14(%ebp),%eax
801055e5:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801055e9:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801055ed:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801055f1:	83 ec 08             	sub    $0x8,%esp
801055f4:	8d 45 de             	lea    -0x22(%ebp),%eax
801055f7:	50                   	push   %eax
801055f8:	ff 75 08             	push   0x8(%ebp)
801055fb:	e8 26 cf ff ff       	call   80102526 <nameiparent>
80105600:	83 c4 10             	add    $0x10,%esp
80105603:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105606:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010560a:	75 0a                	jne    80105616 <create+0x40>
    return 0;
8010560c:	b8 00 00 00 00       	mov    $0x0,%eax
80105611:	e9 90 01 00 00       	jmp    801057a6 <create+0x1d0>
  ilock(dp);
80105616:	83 ec 0c             	sub    $0xc,%esp
80105619:	ff 75 f4             	push   -0xc(%ebp)
8010561c:	e8 b6 c3 ff ff       	call   801019d7 <ilock>
80105621:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105624:	83 ec 04             	sub    $0x4,%esp
80105627:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010562a:	50                   	push   %eax
8010562b:	8d 45 de             	lea    -0x22(%ebp),%eax
8010562e:	50                   	push   %eax
8010562f:	ff 75 f4             	push   -0xc(%ebp)
80105632:	e8 82 cb ff ff       	call   801021b9 <dirlookup>
80105637:	83 c4 10             	add    $0x10,%esp
8010563a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010563d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105641:	74 50                	je     80105693 <create+0xbd>
    iunlockput(dp);
80105643:	83 ec 0c             	sub    $0xc,%esp
80105646:	ff 75 f4             	push   -0xc(%ebp)
80105649:	e8 ba c5 ff ff       	call   80101c08 <iunlockput>
8010564e:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105651:	83 ec 0c             	sub    $0xc,%esp
80105654:	ff 75 f0             	push   -0x10(%ebp)
80105657:	e8 7b c3 ff ff       	call   801019d7 <ilock>
8010565c:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
8010565f:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105664:	75 15                	jne    8010567b <create+0xa5>
80105666:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105669:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010566d:	66 83 f8 02          	cmp    $0x2,%ax
80105671:	75 08                	jne    8010567b <create+0xa5>
      return ip;
80105673:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105676:	e9 2b 01 00 00       	jmp    801057a6 <create+0x1d0>
    iunlockput(ip);
8010567b:	83 ec 0c             	sub    $0xc,%esp
8010567e:	ff 75 f0             	push   -0x10(%ebp)
80105681:	e8 82 c5 ff ff       	call   80101c08 <iunlockput>
80105686:	83 c4 10             	add    $0x10,%esp
    return 0;
80105689:	b8 00 00 00 00       	mov    $0x0,%eax
8010568e:	e9 13 01 00 00       	jmp    801057a6 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105693:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105697:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010569a:	8b 00                	mov    (%eax),%eax
8010569c:	83 ec 08             	sub    $0x8,%esp
8010569f:	52                   	push   %edx
801056a0:	50                   	push   %eax
801056a1:	e8 7d c0 ff ff       	call   80101723 <ialloc>
801056a6:	83 c4 10             	add    $0x10,%esp
801056a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801056ac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801056b0:	75 0d                	jne    801056bf <create+0xe9>
    panic("create: ialloc");
801056b2:	83 ec 0c             	sub    $0xc,%esp
801056b5:	68 6e a7 10 80       	push   $0x8010a76e
801056ba:	e8 ea ae ff ff       	call   801005a9 <panic>

  ilock(ip);
801056bf:	83 ec 0c             	sub    $0xc,%esp
801056c2:	ff 75 f0             	push   -0x10(%ebp)
801056c5:	e8 0d c3 ff ff       	call   801019d7 <ilock>
801056ca:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801056cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056d0:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801056d4:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
801056d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056db:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801056df:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
801056e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056e6:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
801056ec:	83 ec 0c             	sub    $0xc,%esp
801056ef:	ff 75 f0             	push   -0x10(%ebp)
801056f2:	e8 03 c1 ff ff       	call   801017fa <iupdate>
801056f7:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801056fa:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801056ff:	75 6a                	jne    8010576b <create+0x195>
    dp->nlink++;  // for ".."
80105701:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105704:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105708:	83 c0 01             	add    $0x1,%eax
8010570b:	89 c2                	mov    %eax,%edx
8010570d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105710:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105714:	83 ec 0c             	sub    $0xc,%esp
80105717:	ff 75 f4             	push   -0xc(%ebp)
8010571a:	e8 db c0 ff ff       	call   801017fa <iupdate>
8010571f:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105722:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105725:	8b 40 04             	mov    0x4(%eax),%eax
80105728:	83 ec 04             	sub    $0x4,%esp
8010572b:	50                   	push   %eax
8010572c:	68 48 a7 10 80       	push   $0x8010a748
80105731:	ff 75 f0             	push   -0x10(%ebp)
80105734:	e8 3a cb ff ff       	call   80102273 <dirlink>
80105739:	83 c4 10             	add    $0x10,%esp
8010573c:	85 c0                	test   %eax,%eax
8010573e:	78 1e                	js     8010575e <create+0x188>
80105740:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105743:	8b 40 04             	mov    0x4(%eax),%eax
80105746:	83 ec 04             	sub    $0x4,%esp
80105749:	50                   	push   %eax
8010574a:	68 4a a7 10 80       	push   $0x8010a74a
8010574f:	ff 75 f0             	push   -0x10(%ebp)
80105752:	e8 1c cb ff ff       	call   80102273 <dirlink>
80105757:	83 c4 10             	add    $0x10,%esp
8010575a:	85 c0                	test   %eax,%eax
8010575c:	79 0d                	jns    8010576b <create+0x195>
      panic("create dots");
8010575e:	83 ec 0c             	sub    $0xc,%esp
80105761:	68 7d a7 10 80       	push   $0x8010a77d
80105766:	e8 3e ae ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
8010576b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010576e:	8b 40 04             	mov    0x4(%eax),%eax
80105771:	83 ec 04             	sub    $0x4,%esp
80105774:	50                   	push   %eax
80105775:	8d 45 de             	lea    -0x22(%ebp),%eax
80105778:	50                   	push   %eax
80105779:	ff 75 f4             	push   -0xc(%ebp)
8010577c:	e8 f2 ca ff ff       	call   80102273 <dirlink>
80105781:	83 c4 10             	add    $0x10,%esp
80105784:	85 c0                	test   %eax,%eax
80105786:	79 0d                	jns    80105795 <create+0x1bf>
    panic("create: dirlink");
80105788:	83 ec 0c             	sub    $0xc,%esp
8010578b:	68 89 a7 10 80       	push   $0x8010a789
80105790:	e8 14 ae ff ff       	call   801005a9 <panic>

  iunlockput(dp);
80105795:	83 ec 0c             	sub    $0xc,%esp
80105798:	ff 75 f4             	push   -0xc(%ebp)
8010579b:	e8 68 c4 ff ff       	call   80101c08 <iunlockput>
801057a0:	83 c4 10             	add    $0x10,%esp

  return ip;
801057a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801057a6:	c9                   	leave  
801057a7:	c3                   	ret    

801057a8 <sys_open>:

int
sys_open(void)
{
801057a8:	55                   	push   %ebp
801057a9:	89 e5                	mov    %esp,%ebp
801057ab:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801057ae:	83 ec 08             	sub    $0x8,%esp
801057b1:	8d 45 e8             	lea    -0x18(%ebp),%eax
801057b4:	50                   	push   %eax
801057b5:	6a 00                	push   $0x0
801057b7:	e8 ea f6 ff ff       	call   80104ea6 <argstr>
801057bc:	83 c4 10             	add    $0x10,%esp
801057bf:	85 c0                	test   %eax,%eax
801057c1:	78 15                	js     801057d8 <sys_open+0x30>
801057c3:	83 ec 08             	sub    $0x8,%esp
801057c6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801057c9:	50                   	push   %eax
801057ca:	6a 01                	push   $0x1
801057cc:	e8 4f f6 ff ff       	call   80104e20 <argint>
801057d1:	83 c4 10             	add    $0x10,%esp
801057d4:	85 c0                	test   %eax,%eax
801057d6:	79 0a                	jns    801057e2 <sys_open+0x3a>
    return -1;
801057d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057dd:	e9 61 01 00 00       	jmp    80105943 <sys_open+0x19b>

  begin_op();
801057e2:	e8 42 d8 ff ff       	call   80103029 <begin_op>

  if(omode & O_CREATE){
801057e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801057ea:	25 00 02 00 00       	and    $0x200,%eax
801057ef:	85 c0                	test   %eax,%eax
801057f1:	74 2a                	je     8010581d <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
801057f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801057f6:	6a 00                	push   $0x0
801057f8:	6a 00                	push   $0x0
801057fa:	6a 02                	push   $0x2
801057fc:	50                   	push   %eax
801057fd:	e8 d4 fd ff ff       	call   801055d6 <create>
80105802:	83 c4 10             	add    $0x10,%esp
80105805:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105808:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010580c:	75 75                	jne    80105883 <sys_open+0xdb>
      end_op();
8010580e:	e8 a2 d8 ff ff       	call   801030b5 <end_op>
      return -1;
80105813:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105818:	e9 26 01 00 00       	jmp    80105943 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
8010581d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105820:	83 ec 0c             	sub    $0xc,%esp
80105823:	50                   	push   %eax
80105824:	e8 e1 cc ff ff       	call   8010250a <namei>
80105829:	83 c4 10             	add    $0x10,%esp
8010582c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010582f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105833:	75 0f                	jne    80105844 <sys_open+0x9c>
      end_op();
80105835:	e8 7b d8 ff ff       	call   801030b5 <end_op>
      return -1;
8010583a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010583f:	e9 ff 00 00 00       	jmp    80105943 <sys_open+0x19b>
    }
    ilock(ip);
80105844:	83 ec 0c             	sub    $0xc,%esp
80105847:	ff 75 f4             	push   -0xc(%ebp)
8010584a:	e8 88 c1 ff ff       	call   801019d7 <ilock>
8010584f:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105852:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105855:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105859:	66 83 f8 01          	cmp    $0x1,%ax
8010585d:	75 24                	jne    80105883 <sys_open+0xdb>
8010585f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105862:	85 c0                	test   %eax,%eax
80105864:	74 1d                	je     80105883 <sys_open+0xdb>
      iunlockput(ip);
80105866:	83 ec 0c             	sub    $0xc,%esp
80105869:	ff 75 f4             	push   -0xc(%ebp)
8010586c:	e8 97 c3 ff ff       	call   80101c08 <iunlockput>
80105871:	83 c4 10             	add    $0x10,%esp
      end_op();
80105874:	e8 3c d8 ff ff       	call   801030b5 <end_op>
      return -1;
80105879:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010587e:	e9 c0 00 00 00       	jmp    80105943 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105883:	e8 42 b7 ff ff       	call   80100fca <filealloc>
80105888:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010588b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010588f:	74 17                	je     801058a8 <sys_open+0x100>
80105891:	83 ec 0c             	sub    $0xc,%esp
80105894:	ff 75 f0             	push   -0x10(%ebp)
80105897:	e8 33 f7 ff ff       	call   80104fcf <fdalloc>
8010589c:	83 c4 10             	add    $0x10,%esp
8010589f:	89 45 ec             	mov    %eax,-0x14(%ebp)
801058a2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801058a6:	79 2e                	jns    801058d6 <sys_open+0x12e>
    if(f)
801058a8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801058ac:	74 0e                	je     801058bc <sys_open+0x114>
      fileclose(f);
801058ae:	83 ec 0c             	sub    $0xc,%esp
801058b1:	ff 75 f0             	push   -0x10(%ebp)
801058b4:	e8 cf b7 ff ff       	call   80101088 <fileclose>
801058b9:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801058bc:	83 ec 0c             	sub    $0xc,%esp
801058bf:	ff 75 f4             	push   -0xc(%ebp)
801058c2:	e8 41 c3 ff ff       	call   80101c08 <iunlockput>
801058c7:	83 c4 10             	add    $0x10,%esp
    end_op();
801058ca:	e8 e6 d7 ff ff       	call   801030b5 <end_op>
    return -1;
801058cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058d4:	eb 6d                	jmp    80105943 <sys_open+0x19b>
  }
  iunlock(ip);
801058d6:	83 ec 0c             	sub    $0xc,%esp
801058d9:	ff 75 f4             	push   -0xc(%ebp)
801058dc:	e8 09 c2 ff ff       	call   80101aea <iunlock>
801058e1:	83 c4 10             	add    $0x10,%esp
  end_op();
801058e4:	e8 cc d7 ff ff       	call   801030b5 <end_op>

  f->type = FD_INODE;
801058e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058ec:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801058f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058f8:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801058fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058fe:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105905:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105908:	83 e0 01             	and    $0x1,%eax
8010590b:	85 c0                	test   %eax,%eax
8010590d:	0f 94 c0             	sete   %al
80105910:	89 c2                	mov    %eax,%edx
80105912:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105915:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105918:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010591b:	83 e0 01             	and    $0x1,%eax
8010591e:	85 c0                	test   %eax,%eax
80105920:	75 0a                	jne    8010592c <sys_open+0x184>
80105922:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105925:	83 e0 02             	and    $0x2,%eax
80105928:	85 c0                	test   %eax,%eax
8010592a:	74 07                	je     80105933 <sys_open+0x18b>
8010592c:	b8 01 00 00 00       	mov    $0x1,%eax
80105931:	eb 05                	jmp    80105938 <sys_open+0x190>
80105933:	b8 00 00 00 00       	mov    $0x0,%eax
80105938:	89 c2                	mov    %eax,%edx
8010593a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010593d:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105940:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105943:	c9                   	leave  
80105944:	c3                   	ret    

80105945 <sys_mkdir>:

int
sys_mkdir(void)
{
80105945:	55                   	push   %ebp
80105946:	89 e5                	mov    %esp,%ebp
80105948:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010594b:	e8 d9 d6 ff ff       	call   80103029 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105950:	83 ec 08             	sub    $0x8,%esp
80105953:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105956:	50                   	push   %eax
80105957:	6a 00                	push   $0x0
80105959:	e8 48 f5 ff ff       	call   80104ea6 <argstr>
8010595e:	83 c4 10             	add    $0x10,%esp
80105961:	85 c0                	test   %eax,%eax
80105963:	78 1b                	js     80105980 <sys_mkdir+0x3b>
80105965:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105968:	6a 00                	push   $0x0
8010596a:	6a 00                	push   $0x0
8010596c:	6a 01                	push   $0x1
8010596e:	50                   	push   %eax
8010596f:	e8 62 fc ff ff       	call   801055d6 <create>
80105974:	83 c4 10             	add    $0x10,%esp
80105977:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010597a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010597e:	75 0c                	jne    8010598c <sys_mkdir+0x47>
    end_op();
80105980:	e8 30 d7 ff ff       	call   801030b5 <end_op>
    return -1;
80105985:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010598a:	eb 18                	jmp    801059a4 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
8010598c:	83 ec 0c             	sub    $0xc,%esp
8010598f:	ff 75 f4             	push   -0xc(%ebp)
80105992:	e8 71 c2 ff ff       	call   80101c08 <iunlockput>
80105997:	83 c4 10             	add    $0x10,%esp
  end_op();
8010599a:	e8 16 d7 ff ff       	call   801030b5 <end_op>
  return 0;
8010599f:	b8 00 00 00 00       	mov    $0x0,%eax
}
801059a4:	c9                   	leave  
801059a5:	c3                   	ret    

801059a6 <sys_mknod>:

int
sys_mknod(void)
{
801059a6:	55                   	push   %ebp
801059a7:	89 e5                	mov    %esp,%ebp
801059a9:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
801059ac:	e8 78 d6 ff ff       	call   80103029 <begin_op>
  if((argstr(0, &path)) < 0 ||
801059b1:	83 ec 08             	sub    $0x8,%esp
801059b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059b7:	50                   	push   %eax
801059b8:	6a 00                	push   $0x0
801059ba:	e8 e7 f4 ff ff       	call   80104ea6 <argstr>
801059bf:	83 c4 10             	add    $0x10,%esp
801059c2:	85 c0                	test   %eax,%eax
801059c4:	78 4f                	js     80105a15 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
801059c6:	83 ec 08             	sub    $0x8,%esp
801059c9:	8d 45 ec             	lea    -0x14(%ebp),%eax
801059cc:	50                   	push   %eax
801059cd:	6a 01                	push   $0x1
801059cf:	e8 4c f4 ff ff       	call   80104e20 <argint>
801059d4:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
801059d7:	85 c0                	test   %eax,%eax
801059d9:	78 3a                	js     80105a15 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
801059db:	83 ec 08             	sub    $0x8,%esp
801059de:	8d 45 e8             	lea    -0x18(%ebp),%eax
801059e1:	50                   	push   %eax
801059e2:	6a 02                	push   $0x2
801059e4:	e8 37 f4 ff ff       	call   80104e20 <argint>
801059e9:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
801059ec:	85 c0                	test   %eax,%eax
801059ee:	78 25                	js     80105a15 <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
801059f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801059f3:	0f bf c8             	movswl %ax,%ecx
801059f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801059f9:	0f bf d0             	movswl %ax,%edx
801059fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059ff:	51                   	push   %ecx
80105a00:	52                   	push   %edx
80105a01:	6a 03                	push   $0x3
80105a03:	50                   	push   %eax
80105a04:	e8 cd fb ff ff       	call   801055d6 <create>
80105a09:	83 c4 10             	add    $0x10,%esp
80105a0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105a0f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a13:	75 0c                	jne    80105a21 <sys_mknod+0x7b>
    end_op();
80105a15:	e8 9b d6 ff ff       	call   801030b5 <end_op>
    return -1;
80105a1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a1f:	eb 18                	jmp    80105a39 <sys_mknod+0x93>
  }
  iunlockput(ip);
80105a21:	83 ec 0c             	sub    $0xc,%esp
80105a24:	ff 75 f4             	push   -0xc(%ebp)
80105a27:	e8 dc c1 ff ff       	call   80101c08 <iunlockput>
80105a2c:	83 c4 10             	add    $0x10,%esp
  end_op();
80105a2f:	e8 81 d6 ff ff       	call   801030b5 <end_op>
  return 0;
80105a34:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a39:	c9                   	leave  
80105a3a:	c3                   	ret    

80105a3b <sys_chdir>:

int
sys_chdir(void)
{
80105a3b:	55                   	push   %ebp
80105a3c:	89 e5                	mov    %esp,%ebp
80105a3e:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105a41:	e8 e3 df ff ff       	call   80103a29 <myproc>
80105a46:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105a49:	e8 db d5 ff ff       	call   80103029 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105a4e:	83 ec 08             	sub    $0x8,%esp
80105a51:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105a54:	50                   	push   %eax
80105a55:	6a 00                	push   $0x0
80105a57:	e8 4a f4 ff ff       	call   80104ea6 <argstr>
80105a5c:	83 c4 10             	add    $0x10,%esp
80105a5f:	85 c0                	test   %eax,%eax
80105a61:	78 18                	js     80105a7b <sys_chdir+0x40>
80105a63:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105a66:	83 ec 0c             	sub    $0xc,%esp
80105a69:	50                   	push   %eax
80105a6a:	e8 9b ca ff ff       	call   8010250a <namei>
80105a6f:	83 c4 10             	add    $0x10,%esp
80105a72:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a75:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a79:	75 0c                	jne    80105a87 <sys_chdir+0x4c>
    end_op();
80105a7b:	e8 35 d6 ff ff       	call   801030b5 <end_op>
    return -1;
80105a80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a85:	eb 68                	jmp    80105aef <sys_chdir+0xb4>
  }
  ilock(ip);
80105a87:	83 ec 0c             	sub    $0xc,%esp
80105a8a:	ff 75 f0             	push   -0x10(%ebp)
80105a8d:	e8 45 bf ff ff       	call   801019d7 <ilock>
80105a92:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105a95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a98:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105a9c:	66 83 f8 01          	cmp    $0x1,%ax
80105aa0:	74 1a                	je     80105abc <sys_chdir+0x81>
    iunlockput(ip);
80105aa2:	83 ec 0c             	sub    $0xc,%esp
80105aa5:	ff 75 f0             	push   -0x10(%ebp)
80105aa8:	e8 5b c1 ff ff       	call   80101c08 <iunlockput>
80105aad:	83 c4 10             	add    $0x10,%esp
    end_op();
80105ab0:	e8 00 d6 ff ff       	call   801030b5 <end_op>
    return -1;
80105ab5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aba:	eb 33                	jmp    80105aef <sys_chdir+0xb4>
  }
  iunlock(ip);
80105abc:	83 ec 0c             	sub    $0xc,%esp
80105abf:	ff 75 f0             	push   -0x10(%ebp)
80105ac2:	e8 23 c0 ff ff       	call   80101aea <iunlock>
80105ac7:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105acd:	8b 40 68             	mov    0x68(%eax),%eax
80105ad0:	83 ec 0c             	sub    $0xc,%esp
80105ad3:	50                   	push   %eax
80105ad4:	e8 5f c0 ff ff       	call   80101b38 <iput>
80105ad9:	83 c4 10             	add    $0x10,%esp
  end_op();
80105adc:	e8 d4 d5 ff ff       	call   801030b5 <end_op>
  curproc->cwd = ip;
80105ae1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ae4:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ae7:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105aea:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105aef:	c9                   	leave  
80105af0:	c3                   	ret    

80105af1 <sys_exec>:

int
sys_exec(void)
{
80105af1:	55                   	push   %ebp
80105af2:	89 e5                	mov    %esp,%ebp
80105af4:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105afa:	83 ec 08             	sub    $0x8,%esp
80105afd:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b00:	50                   	push   %eax
80105b01:	6a 00                	push   $0x0
80105b03:	e8 9e f3 ff ff       	call   80104ea6 <argstr>
80105b08:	83 c4 10             	add    $0x10,%esp
80105b0b:	85 c0                	test   %eax,%eax
80105b0d:	78 18                	js     80105b27 <sys_exec+0x36>
80105b0f:	83 ec 08             	sub    $0x8,%esp
80105b12:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105b18:	50                   	push   %eax
80105b19:	6a 01                	push   $0x1
80105b1b:	e8 00 f3 ff ff       	call   80104e20 <argint>
80105b20:	83 c4 10             	add    $0x10,%esp
80105b23:	85 c0                	test   %eax,%eax
80105b25:	79 0a                	jns    80105b31 <sys_exec+0x40>
    return -1;
80105b27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b2c:	e9 c6 00 00 00       	jmp    80105bf7 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80105b31:	83 ec 04             	sub    $0x4,%esp
80105b34:	68 80 00 00 00       	push   $0x80
80105b39:	6a 00                	push   $0x0
80105b3b:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105b41:	50                   	push   %eax
80105b42:	e8 ca ef ff ff       	call   80104b11 <memset>
80105b47:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105b4a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b54:	83 f8 1f             	cmp    $0x1f,%eax
80105b57:	76 0a                	jbe    80105b63 <sys_exec+0x72>
      return -1;
80105b59:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b5e:	e9 94 00 00 00       	jmp    80105bf7 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105b63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b66:	c1 e0 02             	shl    $0x2,%eax
80105b69:	89 c2                	mov    %eax,%edx
80105b6b:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105b71:	01 c2                	add    %eax,%edx
80105b73:	83 ec 08             	sub    $0x8,%esp
80105b76:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105b7c:	50                   	push   %eax
80105b7d:	52                   	push   %edx
80105b7e:	e8 18 f2 ff ff       	call   80104d9b <fetchint>
80105b83:	83 c4 10             	add    $0x10,%esp
80105b86:	85 c0                	test   %eax,%eax
80105b88:	79 07                	jns    80105b91 <sys_exec+0xa0>
      return -1;
80105b8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b8f:	eb 66                	jmp    80105bf7 <sys_exec+0x106>
    if(uarg == 0){
80105b91:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105b97:	85 c0                	test   %eax,%eax
80105b99:	75 27                	jne    80105bc2 <sys_exec+0xd1>
      argv[i] = 0;
80105b9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b9e:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105ba5:	00 00 00 00 
      break;
80105ba9:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105baa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bad:	83 ec 08             	sub    $0x8,%esp
80105bb0:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105bb6:	52                   	push   %edx
80105bb7:	50                   	push   %eax
80105bb8:	e8 c3 af ff ff       	call   80100b80 <exec>
80105bbd:	83 c4 10             	add    $0x10,%esp
80105bc0:	eb 35                	jmp    80105bf7 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105bc2:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105bc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bcb:	c1 e0 02             	shl    $0x2,%eax
80105bce:	01 c2                	add    %eax,%edx
80105bd0:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105bd6:	83 ec 08             	sub    $0x8,%esp
80105bd9:	52                   	push   %edx
80105bda:	50                   	push   %eax
80105bdb:	e8 ea f1 ff ff       	call   80104dca <fetchstr>
80105be0:	83 c4 10             	add    $0x10,%esp
80105be3:	85 c0                	test   %eax,%eax
80105be5:	79 07                	jns    80105bee <sys_exec+0xfd>
      return -1;
80105be7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bec:	eb 09                	jmp    80105bf7 <sys_exec+0x106>
  for(i=0;; i++){
80105bee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105bf2:	e9 5a ff ff ff       	jmp    80105b51 <sys_exec+0x60>
}
80105bf7:	c9                   	leave  
80105bf8:	c3                   	ret    

80105bf9 <sys_pipe>:

int
sys_pipe(void)
{
80105bf9:	55                   	push   %ebp
80105bfa:	89 e5                	mov    %esp,%ebp
80105bfc:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105bff:	83 ec 04             	sub    $0x4,%esp
80105c02:	6a 08                	push   $0x8
80105c04:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c07:	50                   	push   %eax
80105c08:	6a 00                	push   $0x0
80105c0a:	e8 3e f2 ff ff       	call   80104e4d <argptr>
80105c0f:	83 c4 10             	add    $0x10,%esp
80105c12:	85 c0                	test   %eax,%eax
80105c14:	79 0a                	jns    80105c20 <sys_pipe+0x27>
    return -1;
80105c16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c1b:	e9 ae 00 00 00       	jmp    80105cce <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105c20:	83 ec 08             	sub    $0x8,%esp
80105c23:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105c26:	50                   	push   %eax
80105c27:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105c2a:	50                   	push   %eax
80105c2b:	e8 2a d9 ff ff       	call   8010355a <pipealloc>
80105c30:	83 c4 10             	add    $0x10,%esp
80105c33:	85 c0                	test   %eax,%eax
80105c35:	79 0a                	jns    80105c41 <sys_pipe+0x48>
    return -1;
80105c37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c3c:	e9 8d 00 00 00       	jmp    80105cce <sys_pipe+0xd5>
  fd0 = -1;
80105c41:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105c48:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105c4b:	83 ec 0c             	sub    $0xc,%esp
80105c4e:	50                   	push   %eax
80105c4f:	e8 7b f3 ff ff       	call   80104fcf <fdalloc>
80105c54:	83 c4 10             	add    $0x10,%esp
80105c57:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c5a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c5e:	78 18                	js     80105c78 <sys_pipe+0x7f>
80105c60:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c63:	83 ec 0c             	sub    $0xc,%esp
80105c66:	50                   	push   %eax
80105c67:	e8 63 f3 ff ff       	call   80104fcf <fdalloc>
80105c6c:	83 c4 10             	add    $0x10,%esp
80105c6f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c72:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c76:	79 3e                	jns    80105cb6 <sys_pipe+0xbd>
    if(fd0 >= 0)
80105c78:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c7c:	78 13                	js     80105c91 <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105c7e:	e8 a6 dd ff ff       	call   80103a29 <myproc>
80105c83:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c86:	83 c2 08             	add    $0x8,%edx
80105c89:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105c90:	00 
    fileclose(rf);
80105c91:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105c94:	83 ec 0c             	sub    $0xc,%esp
80105c97:	50                   	push   %eax
80105c98:	e8 eb b3 ff ff       	call   80101088 <fileclose>
80105c9d:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105ca0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ca3:	83 ec 0c             	sub    $0xc,%esp
80105ca6:	50                   	push   %eax
80105ca7:	e8 dc b3 ff ff       	call   80101088 <fileclose>
80105cac:	83 c4 10             	add    $0x10,%esp
    return -1;
80105caf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cb4:	eb 18                	jmp    80105cce <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80105cb6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105cb9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105cbc:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105cbe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105cc1:	8d 50 04             	lea    0x4(%eax),%edx
80105cc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cc7:	89 02                	mov    %eax,(%edx)
  return 0;
80105cc9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cce:	c9                   	leave  
80105ccf:	c3                   	ret    

80105cd0 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80105cd0:	55                   	push   %ebp
80105cd1:	89 e5                	mov    %esp,%ebp
80105cd3:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105cd6:	e8 4d e0 ff ff       	call   80103d28 <fork>
}
80105cdb:	c9                   	leave  
80105cdc:	c3                   	ret    

80105cdd <sys_exit>:

int
sys_exit(void)
{
80105cdd:	55                   	push   %ebp
80105cde:	89 e5                	mov    %esp,%ebp
80105ce0:	83 ec 08             	sub    $0x8,%esp
  exit();
80105ce3:	e8 b9 e1 ff ff       	call   80103ea1 <exit>
  return 0;  // not reached
80105ce8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ced:	c9                   	leave  
80105cee:	c3                   	ret    

80105cef <sys_wait>:

int
sys_wait(void)
{
80105cef:	55                   	push   %ebp
80105cf0:	89 e5                	mov    %esp,%ebp
80105cf2:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105cf5:	e8 c7 e2 ff ff       	call   80103fc1 <wait>
}
80105cfa:	c9                   	leave  
80105cfb:	c3                   	ret    

80105cfc <sys_kill>:

int
sys_kill(void)
{
80105cfc:	55                   	push   %ebp
80105cfd:	89 e5                	mov    %esp,%ebp
80105cff:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105d02:	83 ec 08             	sub    $0x8,%esp
80105d05:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d08:	50                   	push   %eax
80105d09:	6a 00                	push   $0x0
80105d0b:	e8 10 f1 ff ff       	call   80104e20 <argint>
80105d10:	83 c4 10             	add    $0x10,%esp
80105d13:	85 c0                	test   %eax,%eax
80105d15:	79 07                	jns    80105d1e <sys_kill+0x22>
    return -1;
80105d17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d1c:	eb 0f                	jmp    80105d2d <sys_kill+0x31>
  return kill(pid);
80105d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d21:	83 ec 0c             	sub    $0xc,%esp
80105d24:	50                   	push   %eax
80105d25:	e8 c6 e6 ff ff       	call   801043f0 <kill>
80105d2a:	83 c4 10             	add    $0x10,%esp
}
80105d2d:	c9                   	leave  
80105d2e:	c3                   	ret    

80105d2f <sys_getpid>:

int
sys_getpid(void)
{
80105d2f:	55                   	push   %ebp
80105d30:	89 e5                	mov    %esp,%ebp
80105d32:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105d35:	e8 ef dc ff ff       	call   80103a29 <myproc>
80105d3a:	8b 40 10             	mov    0x10(%eax),%eax
}
80105d3d:	c9                   	leave  
80105d3e:	c3                   	ret    

80105d3f <sys_sbrk>:

int
sys_sbrk(void)
{
80105d3f:	55                   	push   %ebp
80105d40:	89 e5                	mov    %esp,%ebp
80105d42:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105d45:	83 ec 08             	sub    $0x8,%esp
80105d48:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d4b:	50                   	push   %eax
80105d4c:	6a 00                	push   $0x0
80105d4e:	e8 cd f0 ff ff       	call   80104e20 <argint>
80105d53:	83 c4 10             	add    $0x10,%esp
80105d56:	85 c0                	test   %eax,%eax
80105d58:	79 07                	jns    80105d61 <sys_sbrk+0x22>
    return -1;
80105d5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d5f:	eb 27                	jmp    80105d88 <sys_sbrk+0x49>
  addr = myproc()->sz;
80105d61:	e8 c3 dc ff ff       	call   80103a29 <myproc>
80105d66:	8b 00                	mov    (%eax),%eax
80105d68:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80105d6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d6e:	83 ec 0c             	sub    $0xc,%esp
80105d71:	50                   	push   %eax
80105d72:	e8 16 df ff ff       	call   80103c8d <growproc>
80105d77:	83 c4 10             	add    $0x10,%esp
80105d7a:	85 c0                	test   %eax,%eax
80105d7c:	79 07                	jns    80105d85 <sys_sbrk+0x46>
    return -1;
80105d7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d83:	eb 03                	jmp    80105d88 <sys_sbrk+0x49>
  return addr;
80105d85:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105d88:	c9                   	leave  
80105d89:	c3                   	ret    

80105d8a <sys_sleep>:

int
sys_sleep(void)
{
80105d8a:	55                   	push   %ebp
80105d8b:	89 e5                	mov    %esp,%ebp
80105d8d:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105d90:	83 ec 08             	sub    $0x8,%esp
80105d93:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d96:	50                   	push   %eax
80105d97:	6a 00                	push   $0x0
80105d99:	e8 82 f0 ff ff       	call   80104e20 <argint>
80105d9e:	83 c4 10             	add    $0x10,%esp
80105da1:	85 c0                	test   %eax,%eax
80105da3:	79 07                	jns    80105dac <sys_sleep+0x22>
    return -1;
80105da5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105daa:	eb 76                	jmp    80105e22 <sys_sleep+0x98>
  acquire(&tickslock);
80105dac:	83 ec 0c             	sub    $0xc,%esp
80105daf:	68 40 6a 19 80       	push   $0x80196a40
80105db4:	e8 e2 ea ff ff       	call   8010489b <acquire>
80105db9:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80105dbc:	a1 74 6a 19 80       	mov    0x80196a74,%eax
80105dc1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80105dc4:	eb 38                	jmp    80105dfe <sys_sleep+0x74>
    if(myproc()->killed){
80105dc6:	e8 5e dc ff ff       	call   80103a29 <myproc>
80105dcb:	8b 40 24             	mov    0x24(%eax),%eax
80105dce:	85 c0                	test   %eax,%eax
80105dd0:	74 17                	je     80105de9 <sys_sleep+0x5f>
      release(&tickslock);
80105dd2:	83 ec 0c             	sub    $0xc,%esp
80105dd5:	68 40 6a 19 80       	push   $0x80196a40
80105dda:	e8 2a eb ff ff       	call   80104909 <release>
80105ddf:	83 c4 10             	add    $0x10,%esp
      return -1;
80105de2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105de7:	eb 39                	jmp    80105e22 <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80105de9:	83 ec 08             	sub    $0x8,%esp
80105dec:	68 40 6a 19 80       	push   $0x80196a40
80105df1:	68 74 6a 19 80       	push   $0x80196a74
80105df6:	e8 d7 e4 ff ff       	call   801042d2 <sleep>
80105dfb:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80105dfe:	a1 74 6a 19 80       	mov    0x80196a74,%eax
80105e03:	2b 45 f4             	sub    -0xc(%ebp),%eax
80105e06:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105e09:	39 d0                	cmp    %edx,%eax
80105e0b:	72 b9                	jb     80105dc6 <sys_sleep+0x3c>
  }
  release(&tickslock);
80105e0d:	83 ec 0c             	sub    $0xc,%esp
80105e10:	68 40 6a 19 80       	push   $0x80196a40
80105e15:	e8 ef ea ff ff       	call   80104909 <release>
80105e1a:	83 c4 10             	add    $0x10,%esp
  return 0;
80105e1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e22:	c9                   	leave  
80105e23:	c3                   	ret    

80105e24 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105e24:	55                   	push   %ebp
80105e25:	89 e5                	mov    %esp,%ebp
80105e27:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80105e2a:	83 ec 0c             	sub    $0xc,%esp
80105e2d:	68 40 6a 19 80       	push   $0x80196a40
80105e32:	e8 64 ea ff ff       	call   8010489b <acquire>
80105e37:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80105e3a:	a1 74 6a 19 80       	mov    0x80196a74,%eax
80105e3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80105e42:	83 ec 0c             	sub    $0xc,%esp
80105e45:	68 40 6a 19 80       	push   $0x80196a40
80105e4a:	e8 ba ea ff ff       	call   80104909 <release>
80105e4f:	83 c4 10             	add    $0x10,%esp
  return xticks;
80105e52:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105e55:	c9                   	leave  
80105e56:	c3                   	ret    

80105e57 <sys_printpt>:

int
sys_printpt(void)
{
80105e57:	55                   	push   %ebp
80105e58:	89 e5                	mov    %esp,%ebp
80105e5a:	83 ec 18             	sub    $0x18,%esp
    int pid;
    if (argint(0, &pid) < 0)
80105e5d:	83 ec 08             	sub    $0x8,%esp
80105e60:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e63:	50                   	push   %eax
80105e64:	6a 00                	push   $0x0
80105e66:	e8 b5 ef ff ff       	call   80104e20 <argint>
80105e6b:	83 c4 10             	add    $0x10,%esp
80105e6e:	85 c0                	test   %eax,%eax
80105e70:	79 07                	jns    80105e79 <sys_printpt+0x22>
        return -1;
80105e72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e77:	eb 0f                	jmp    80105e88 <sys_printpt+0x31>
    return printpt(pid);
80105e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e7c:	83 ec 0c             	sub    $0xc,%esp
80105e7f:	50                   	push   %eax
80105e80:	e8 e9 e6 ff ff       	call   8010456e <printpt>
80105e85:	83 c4 10             	add    $0x10,%esp
80105e88:	c9                   	leave  
80105e89:	c3                   	ret    

80105e8a <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105e8a:	1e                   	push   %ds
  pushl %es
80105e8b:	06                   	push   %es
  pushl %fs
80105e8c:	0f a0                	push   %fs
  pushl %gs
80105e8e:	0f a8                	push   %gs
  pushal
80105e90:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80105e91:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105e95:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80105e97:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80105e99:	54                   	push   %esp
  call trap
80105e9a:	e8 e3 01 00 00       	call   80106082 <trap>
  addl $4, %esp
80105e9f:	83 c4 04             	add    $0x4,%esp

80105ea2 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105ea2:	61                   	popa   
  popl %gs
80105ea3:	0f a9                	pop    %gs
  popl %fs
80105ea5:	0f a1                	pop    %fs
  popl %es
80105ea7:	07                   	pop    %es
  popl %ds
80105ea8:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105ea9:	83 c4 08             	add    $0x8,%esp
  iret
80105eac:	cf                   	iret   

80105ead <lidt>:
{
80105ead:	55                   	push   %ebp
80105eae:	89 e5                	mov    %esp,%ebp
80105eb0:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80105eb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80105eb6:	83 e8 01             	sub    $0x1,%eax
80105eb9:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80105ebd:	8b 45 08             	mov    0x8(%ebp),%eax
80105ec0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105ec4:	8b 45 08             	mov    0x8(%ebp),%eax
80105ec7:	c1 e8 10             	shr    $0x10,%eax
80105eca:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105ece:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105ed1:	0f 01 18             	lidtl  (%eax)
}
80105ed4:	90                   	nop
80105ed5:	c9                   	leave  
80105ed6:	c3                   	ret    

80105ed7 <rcr2>:
{
80105ed7:	55                   	push   %ebp
80105ed8:	89 e5                	mov    %esp,%ebp
80105eda:	83 ec 10             	sub    $0x10,%esp
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105edd:	0f 20 d0             	mov    %cr2,%eax
80105ee0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80105ee3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105ee6:	c9                   	leave  
80105ee7:	c3                   	ret    

80105ee8 <lcr3>:
{
80105ee8:	55                   	push   %ebp
80105ee9:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80105eeb:	8b 45 08             	mov    0x8(%ebp),%eax
80105eee:	0f 22 d8             	mov    %eax,%cr3
}
80105ef1:	90                   	nop
80105ef2:	5d                   	pop    %ebp
80105ef3:	c3                   	ret    

80105ef4 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105ef4:	55                   	push   %ebp
80105ef5:	89 e5                	mov    %esp,%ebp
80105ef7:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80105efa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105f01:	e9 c3 00 00 00       	jmp    80105fc9 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105f06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f09:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80105f10:	89 c2                	mov    %eax,%edx
80105f12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f15:	66 89 14 c5 40 62 19 	mov    %dx,-0x7fe69dc0(,%eax,8)
80105f1c:	80 
80105f1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f20:	66 c7 04 c5 42 62 19 	movw   $0x8,-0x7fe69dbe(,%eax,8)
80105f27:	80 08 00 
80105f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f2d:	0f b6 14 c5 44 62 19 	movzbl -0x7fe69dbc(,%eax,8),%edx
80105f34:	80 
80105f35:	83 e2 e0             	and    $0xffffffe0,%edx
80105f38:	88 14 c5 44 62 19 80 	mov    %dl,-0x7fe69dbc(,%eax,8)
80105f3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f42:	0f b6 14 c5 44 62 19 	movzbl -0x7fe69dbc(,%eax,8),%edx
80105f49:	80 
80105f4a:	83 e2 1f             	and    $0x1f,%edx
80105f4d:	88 14 c5 44 62 19 80 	mov    %dl,-0x7fe69dbc(,%eax,8)
80105f54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f57:	0f b6 14 c5 45 62 19 	movzbl -0x7fe69dbb(,%eax,8),%edx
80105f5e:	80 
80105f5f:	83 e2 f0             	and    $0xfffffff0,%edx
80105f62:	83 ca 0e             	or     $0xe,%edx
80105f65:	88 14 c5 45 62 19 80 	mov    %dl,-0x7fe69dbb(,%eax,8)
80105f6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f6f:	0f b6 14 c5 45 62 19 	movzbl -0x7fe69dbb(,%eax,8),%edx
80105f76:	80 
80105f77:	83 e2 ef             	and    $0xffffffef,%edx
80105f7a:	88 14 c5 45 62 19 80 	mov    %dl,-0x7fe69dbb(,%eax,8)
80105f81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f84:	0f b6 14 c5 45 62 19 	movzbl -0x7fe69dbb(,%eax,8),%edx
80105f8b:	80 
80105f8c:	83 e2 9f             	and    $0xffffff9f,%edx
80105f8f:	88 14 c5 45 62 19 80 	mov    %dl,-0x7fe69dbb(,%eax,8)
80105f96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f99:	0f b6 14 c5 45 62 19 	movzbl -0x7fe69dbb(,%eax,8),%edx
80105fa0:	80 
80105fa1:	83 ca 80             	or     $0xffffff80,%edx
80105fa4:	88 14 c5 45 62 19 80 	mov    %dl,-0x7fe69dbb(,%eax,8)
80105fab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fae:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80105fb5:	c1 e8 10             	shr    $0x10,%eax
80105fb8:	89 c2                	mov    %eax,%edx
80105fba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fbd:	66 89 14 c5 46 62 19 	mov    %dx,-0x7fe69dba(,%eax,8)
80105fc4:	80 
  for(i = 0; i < 256; i++)
80105fc5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105fc9:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80105fd0:	0f 8e 30 ff ff ff    	jle    80105f06 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105fd6:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
80105fdb:	66 a3 40 64 19 80    	mov    %ax,0x80196440
80105fe1:	66 c7 05 42 64 19 80 	movw   $0x8,0x80196442
80105fe8:	08 00 
80105fea:	0f b6 05 44 64 19 80 	movzbl 0x80196444,%eax
80105ff1:	83 e0 e0             	and    $0xffffffe0,%eax
80105ff4:	a2 44 64 19 80       	mov    %al,0x80196444
80105ff9:	0f b6 05 44 64 19 80 	movzbl 0x80196444,%eax
80106000:	83 e0 1f             	and    $0x1f,%eax
80106003:	a2 44 64 19 80       	mov    %al,0x80196444
80106008:	0f b6 05 45 64 19 80 	movzbl 0x80196445,%eax
8010600f:	83 c8 0f             	or     $0xf,%eax
80106012:	a2 45 64 19 80       	mov    %al,0x80196445
80106017:	0f b6 05 45 64 19 80 	movzbl 0x80196445,%eax
8010601e:	83 e0 ef             	and    $0xffffffef,%eax
80106021:	a2 45 64 19 80       	mov    %al,0x80196445
80106026:	0f b6 05 45 64 19 80 	movzbl 0x80196445,%eax
8010602d:	83 c8 60             	or     $0x60,%eax
80106030:	a2 45 64 19 80       	mov    %al,0x80196445
80106035:	0f b6 05 45 64 19 80 	movzbl 0x80196445,%eax
8010603c:	83 c8 80             	or     $0xffffff80,%eax
8010603f:	a2 45 64 19 80       	mov    %al,0x80196445
80106044:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
80106049:	c1 e8 10             	shr    $0x10,%eax
8010604c:	66 a3 46 64 19 80    	mov    %ax,0x80196446

  initlock(&tickslock, "time");
80106052:	83 ec 08             	sub    $0x8,%esp
80106055:	68 9c a7 10 80       	push   $0x8010a79c
8010605a:	68 40 6a 19 80       	push   $0x80196a40
8010605f:	e8 15 e8 ff ff       	call   80104879 <initlock>
80106064:	83 c4 10             	add    $0x10,%esp
}
80106067:	90                   	nop
80106068:	c9                   	leave  
80106069:	c3                   	ret    

8010606a <idtinit>:

void
idtinit(void)
{
8010606a:	55                   	push   %ebp
8010606b:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
8010606d:	68 00 08 00 00       	push   $0x800
80106072:	68 40 62 19 80       	push   $0x80196240
80106077:	e8 31 fe ff ff       	call   80105ead <lidt>
8010607c:	83 c4 08             	add    $0x8,%esp
}
8010607f:	90                   	nop
80106080:	c9                   	leave  
80106081:	c3                   	ret    

80106082 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106082:	55                   	push   %ebp
80106083:	89 e5                	mov    %esp,%ebp
80106085:	57                   	push   %edi
80106086:	56                   	push   %esi
80106087:	53                   	push   %ebx
80106088:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
8010608b:	8b 45 08             	mov    0x8(%ebp),%eax
8010608e:	8b 40 30             	mov    0x30(%eax),%eax
80106091:	83 f8 40             	cmp    $0x40,%eax
80106094:	75 3b                	jne    801060d1 <trap+0x4f>
    if(myproc()->killed)
80106096:	e8 8e d9 ff ff       	call   80103a29 <myproc>
8010609b:	8b 40 24             	mov    0x24(%eax),%eax
8010609e:	85 c0                	test   %eax,%eax
801060a0:	74 05                	je     801060a7 <trap+0x25>
      exit();
801060a2:	e8 fa dd ff ff       	call   80103ea1 <exit>
    myproc()->tf = tf;
801060a7:	e8 7d d9 ff ff       	call   80103a29 <myproc>
801060ac:	8b 55 08             	mov    0x8(%ebp),%edx
801060af:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801060b2:	e8 26 ee ff ff       	call   80104edd <syscall>
    if(myproc()->killed)
801060b7:	e8 6d d9 ff ff       	call   80103a29 <myproc>
801060bc:	8b 40 24             	mov    0x24(%eax),%eax
801060bf:	85 c0                	test   %eax,%eax
801060c1:	0f 84 13 03 00 00    	je     801063da <trap+0x358>
      exit();
801060c7:	e8 d5 dd ff ff       	call   80103ea1 <exit>
    return;
801060cc:	e9 09 03 00 00       	jmp    801063da <trap+0x358>
  }

  switch(tf->trapno){
801060d1:	8b 45 08             	mov    0x8(%ebp),%eax
801060d4:	8b 40 30             	mov    0x30(%eax),%eax
801060d7:	83 e8 0e             	sub    $0xe,%eax
801060da:	83 f8 31             	cmp    $0x31,%eax
801060dd:	0f 87 c2 01 00 00    	ja     801062a5 <trap+0x223>
801060e3:	8b 04 85 a8 a8 10 80 	mov    -0x7fef5758(,%eax,4),%eax
801060ea:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801060ec:	e8 a5 d8 ff ff       	call   80103996 <cpuid>
801060f1:	85 c0                	test   %eax,%eax
801060f3:	75 3d                	jne    80106132 <trap+0xb0>
      acquire(&tickslock);
801060f5:	83 ec 0c             	sub    $0xc,%esp
801060f8:	68 40 6a 19 80       	push   $0x80196a40
801060fd:	e8 99 e7 ff ff       	call   8010489b <acquire>
80106102:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106105:	a1 74 6a 19 80       	mov    0x80196a74,%eax
8010610a:	83 c0 01             	add    $0x1,%eax
8010610d:	a3 74 6a 19 80       	mov    %eax,0x80196a74
      wakeup(&ticks);
80106112:	83 ec 0c             	sub    $0xc,%esp
80106115:	68 74 6a 19 80       	push   $0x80196a74
8010611a:	e8 9a e2 ff ff       	call   801043b9 <wakeup>
8010611f:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106122:	83 ec 0c             	sub    $0xc,%esp
80106125:	68 40 6a 19 80       	push   $0x80196a40
8010612a:	e8 da e7 ff ff       	call   80104909 <release>
8010612f:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106132:	e8 d2 c9 ff ff       	call   80102b09 <lapiceoi>
    break;
80106137:	e9 1e 02 00 00       	jmp    8010635a <trap+0x2d8>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010613c:	e8 de 40 00 00       	call   8010a21f <ideintr>
    lapiceoi();
80106141:	e8 c3 c9 ff ff       	call   80102b09 <lapiceoi>
    break;
80106146:	e9 0f 02 00 00       	jmp    8010635a <trap+0x2d8>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010614b:	e8 fe c7 ff ff       	call   8010294e <kbdintr>
    lapiceoi();
80106150:	e8 b4 c9 ff ff       	call   80102b09 <lapiceoi>
    break;
80106155:	e9 00 02 00 00       	jmp    8010635a <trap+0x2d8>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010615a:	e8 51 04 00 00       	call   801065b0 <uartintr>
    lapiceoi();
8010615f:	e8 a5 c9 ff ff       	call   80102b09 <lapiceoi>
    break;
80106164:	e9 f1 01 00 00       	jmp    8010635a <trap+0x2d8>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106169:	e8 64 2d 00 00       	call   80108ed2 <i8254_intr>
    lapiceoi();
8010616e:	e8 96 c9 ff ff       	call   80102b09 <lapiceoi>
    break;
80106173:	e9 e2 01 00 00       	jmp    8010635a <trap+0x2d8>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106178:	8b 45 08             	mov    0x8(%ebp),%eax
8010617b:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
8010617e:	8b 45 08             	mov    0x8(%ebp),%eax
80106181:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106185:	0f b7 d8             	movzwl %ax,%ebx
80106188:	e8 09 d8 ff ff       	call   80103996 <cpuid>
8010618d:	56                   	push   %esi
8010618e:	53                   	push   %ebx
8010618f:	50                   	push   %eax
80106190:	68 a4 a7 10 80       	push   $0x8010a7a4
80106195:	e8 5a a2 ff ff       	call   801003f4 <cprintf>
8010619a:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
8010619d:	e8 67 c9 ff ff       	call   80102b09 <lapiceoi>
    break;
801061a2:	e9 b3 01 00 00       	jmp    8010635a <trap+0x2d8>

case T_PGFLT:
{
    uint addr = rcr2();
801061a7:	e8 2b fd ff ff       	call   80105ed7 <rcr2>
801061ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    struct proc *curproc = myproc();
801061af:	e8 75 d8 ff ff       	call   80103a29 <myproc>
801061b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
    uint a = PGROUNDDOWN(addr);
801061b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061ba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801061bf:	89 45 dc             	mov    %eax,-0x24(%ebp)

    // 스택 영역인지 확인
    if (addr < KERNBASE) {
801061c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061c5:	85 c0                	test   %eax,%eax
801061c7:	0f 88 b7 00 00 00    	js     80106284 <trap+0x202>
        char *mem = kalloc();
801061cd:	e8 bb c5 ff ff       	call   8010278d <kalloc>
801061d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
        if (mem == 0) {
801061d5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
801061d9:	75 15                	jne    801061f0 <trap+0x16e>
            cprintf("allocuvm out of memory\n");
801061db:	83 ec 0c             	sub    $0xc,%esp
801061de:	68 c8 a7 10 80       	push   $0x8010a7c8
801061e3:	e8 0c a2 ff ff       	call   801003f4 <cprintf>
801061e8:	83 c4 10             	add    $0x10,%esp
            return;
801061eb:	e9 eb 01 00 00       	jmp    801063db <trap+0x359>
        }
        memset(mem, 0, PGSIZE);
801061f0:	83 ec 04             	sub    $0x4,%esp
801061f3:	68 00 10 00 00       	push   $0x1000
801061f8:	6a 00                	push   $0x0
801061fa:	ff 75 d8             	push   -0x28(%ebp)
801061fd:	e8 0f e9 ff ff       	call   80104b11 <memset>
80106202:	83 c4 10             	add    $0x10,%esp
        if (mappages(curproc->pgdir, (char *)a, PGSIZE, V2P(mem), PTE_W | PTE_U) < 0) {
80106205:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106208:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
8010620e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80106211:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106214:	8b 40 04             	mov    0x4(%eax),%eax
80106217:	83 ec 0c             	sub    $0xc,%esp
8010621a:	6a 06                	push   $0x6
8010621c:	51                   	push   %ecx
8010621d:	68 00 10 00 00       	push   $0x1000
80106222:	52                   	push   %edx
80106223:	50                   	push   %eax
80106224:	e8 4b 12 00 00       	call   80107474 <mappages>
80106229:	83 c4 20             	add    $0x20,%esp
8010622c:	85 c0                	test   %eax,%eax
8010622e:	79 13                	jns    80106243 <trap+0x1c1>
            kfree(mem);
80106230:	83 ec 0c             	sub    $0xc,%esp
80106233:	ff 75 d8             	push   -0x28(%ebp)
80106236:	e8 b8 c4 ff ff       	call   801026f3 <kfree>
8010623b:	83 c4 10             	add    $0x10,%esp
            return;
8010623e:	e9 98 01 00 00       	jmp    801063db <trap+0x359>
        }
        curproc->stack_size += PGSIZE; // 스택 크기 증가
80106243:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106246:	8b 40 7c             	mov    0x7c(%eax),%eax
80106249:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
8010624f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106252:	89 50 7c             	mov    %edx,0x7c(%eax)
        lcr3(V2P(curproc->pgdir)); // TLB 플러시
80106255:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106258:	8b 40 04             	mov    0x4(%eax),%eax
8010625b:	05 00 00 00 80       	add    $0x80000000,%eax
80106260:	83 ec 0c             	sub    $0xc,%esp
80106263:	50                   	push   %eax
80106264:	e8 7f fc ff ff       	call   80105ee8 <lcr3>
80106269:	83 c4 10             	add    $0x10,%esp
        cprintf("[PageFault] Allocated new stack page at %p\n", a);
8010626c:	83 ec 08             	sub    $0x8,%esp
8010626f:	ff 75 dc             	push   -0x24(%ebp)
80106272:	68 e0 a7 10 80       	push   $0x8010a7e0
80106277:	e8 78 a1 ff ff       	call   801003f4 <cprintf>
8010627c:	83 c4 10             	add    $0x10,%esp
    } else {
        cprintf("[PageFault] Invalid access!\n");
        myproc()->killed = 1;
    }
    break;
8010627f:	e9 d6 00 00 00       	jmp    8010635a <trap+0x2d8>
        cprintf("[PageFault] Invalid access!\n");
80106284:	83 ec 0c             	sub    $0xc,%esp
80106287:	68 0c a8 10 80       	push   $0x8010a80c
8010628c:	e8 63 a1 ff ff       	call   801003f4 <cprintf>
80106291:	83 c4 10             	add    $0x10,%esp
        myproc()->killed = 1;
80106294:	e8 90 d7 ff ff       	call   80103a29 <myproc>
80106299:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
    break;
801062a0:	e9 b5 00 00 00       	jmp    8010635a <trap+0x2d8>
}

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
801062a5:	e8 7f d7 ff ff       	call   80103a29 <myproc>
801062aa:	85 c0                	test   %eax,%eax
801062ac:	74 11                	je     801062bf <trap+0x23d>
801062ae:	8b 45 08             	mov    0x8(%ebp),%eax
801062b1:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801062b5:	0f b7 c0             	movzwl %ax,%eax
801062b8:	83 e0 03             	and    $0x3,%eax
801062bb:	85 c0                	test   %eax,%eax
801062bd:	75 39                	jne    801062f8 <trap+0x276>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801062bf:	e8 13 fc ff ff       	call   80105ed7 <rcr2>
801062c4:	89 c3                	mov    %eax,%ebx
801062c6:	8b 45 08             	mov    0x8(%ebp),%eax
801062c9:	8b 70 38             	mov    0x38(%eax),%esi
801062cc:	e8 c5 d6 ff ff       	call   80103996 <cpuid>
801062d1:	8b 55 08             	mov    0x8(%ebp),%edx
801062d4:	8b 52 30             	mov    0x30(%edx),%edx
801062d7:	83 ec 0c             	sub    $0xc,%esp
801062da:	53                   	push   %ebx
801062db:	56                   	push   %esi
801062dc:	50                   	push   %eax
801062dd:	52                   	push   %edx
801062de:	68 2c a8 10 80       	push   $0x8010a82c
801062e3:	e8 0c a1 ff ff       	call   801003f4 <cprintf>
801062e8:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
801062eb:	83 ec 0c             	sub    $0xc,%esp
801062ee:	68 5e a8 10 80       	push   $0x8010a85e
801062f3:	e8 b1 a2 ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801062f8:	e8 da fb ff ff       	call   80105ed7 <rcr2>
801062fd:	89 c6                	mov    %eax,%esi
801062ff:	8b 45 08             	mov    0x8(%ebp),%eax
80106302:	8b 40 38             	mov    0x38(%eax),%eax
80106305:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106308:	e8 89 d6 ff ff       	call   80103996 <cpuid>
8010630d:	89 c3                	mov    %eax,%ebx
8010630f:	8b 45 08             	mov    0x8(%ebp),%eax
80106312:	8b 48 34             	mov    0x34(%eax),%ecx
80106315:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106318:	8b 45 08             	mov    0x8(%ebp),%eax
8010631b:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
8010631e:	e8 06 d7 ff ff       	call   80103a29 <myproc>
80106323:	8d 50 6c             	lea    0x6c(%eax),%edx
80106326:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106329:	e8 fb d6 ff ff       	call   80103a29 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010632e:	8b 40 10             	mov    0x10(%eax),%eax
80106331:	56                   	push   %esi
80106332:	ff 75 d4             	push   -0x2c(%ebp)
80106335:	53                   	push   %ebx
80106336:	ff 75 d0             	push   -0x30(%ebp)
80106339:	57                   	push   %edi
8010633a:	ff 75 cc             	push   -0x34(%ebp)
8010633d:	50                   	push   %eax
8010633e:	68 64 a8 10 80       	push   $0x8010a864
80106343:	e8 ac a0 ff ff       	call   801003f4 <cprintf>
80106348:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
8010634b:	e8 d9 d6 ff ff       	call   80103a29 <myproc>
80106350:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106357:	eb 01                	jmp    8010635a <trap+0x2d8>
    break;
80106359:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010635a:	e8 ca d6 ff ff       	call   80103a29 <myproc>
8010635f:	85 c0                	test   %eax,%eax
80106361:	74 23                	je     80106386 <trap+0x304>
80106363:	e8 c1 d6 ff ff       	call   80103a29 <myproc>
80106368:	8b 40 24             	mov    0x24(%eax),%eax
8010636b:	85 c0                	test   %eax,%eax
8010636d:	74 17                	je     80106386 <trap+0x304>
8010636f:	8b 45 08             	mov    0x8(%ebp),%eax
80106372:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106376:	0f b7 c0             	movzwl %ax,%eax
80106379:	83 e0 03             	and    $0x3,%eax
8010637c:	83 f8 03             	cmp    $0x3,%eax
8010637f:	75 05                	jne    80106386 <trap+0x304>
    exit();
80106381:	e8 1b db ff ff       	call   80103ea1 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106386:	e8 9e d6 ff ff       	call   80103a29 <myproc>
8010638b:	85 c0                	test   %eax,%eax
8010638d:	74 1d                	je     801063ac <trap+0x32a>
8010638f:	e8 95 d6 ff ff       	call   80103a29 <myproc>
80106394:	8b 40 0c             	mov    0xc(%eax),%eax
80106397:	83 f8 04             	cmp    $0x4,%eax
8010639a:	75 10                	jne    801063ac <trap+0x32a>
     tf->trapno == T_IRQ0+IRQ_TIMER)
8010639c:	8b 45 08             	mov    0x8(%ebp),%eax
8010639f:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
801063a2:	83 f8 20             	cmp    $0x20,%eax
801063a5:	75 05                	jne    801063ac <trap+0x32a>
    yield();
801063a7:	e8 a6 de ff ff       	call   80104252 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801063ac:	e8 78 d6 ff ff       	call   80103a29 <myproc>
801063b1:	85 c0                	test   %eax,%eax
801063b3:	74 26                	je     801063db <trap+0x359>
801063b5:	e8 6f d6 ff ff       	call   80103a29 <myproc>
801063ba:	8b 40 24             	mov    0x24(%eax),%eax
801063bd:	85 c0                	test   %eax,%eax
801063bf:	74 1a                	je     801063db <trap+0x359>
801063c1:	8b 45 08             	mov    0x8(%ebp),%eax
801063c4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801063c8:	0f b7 c0             	movzwl %ax,%eax
801063cb:	83 e0 03             	and    $0x3,%eax
801063ce:	83 f8 03             	cmp    $0x3,%eax
801063d1:	75 08                	jne    801063db <trap+0x359>
    exit();
801063d3:	e8 c9 da ff ff       	call   80103ea1 <exit>
801063d8:	eb 01                	jmp    801063db <trap+0x359>
    return;
801063da:	90                   	nop
}
801063db:	8d 65 f4             	lea    -0xc(%ebp),%esp
801063de:	5b                   	pop    %ebx
801063df:	5e                   	pop    %esi
801063e0:	5f                   	pop    %edi
801063e1:	5d                   	pop    %ebp
801063e2:	c3                   	ret    

801063e3 <inb>:
{
801063e3:	55                   	push   %ebp
801063e4:	89 e5                	mov    %esp,%ebp
801063e6:	83 ec 14             	sub    $0x14,%esp
801063e9:	8b 45 08             	mov    0x8(%ebp),%eax
801063ec:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801063f0:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801063f4:	89 c2                	mov    %eax,%edx
801063f6:	ec                   	in     (%dx),%al
801063f7:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801063fa:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801063fe:	c9                   	leave  
801063ff:	c3                   	ret    

80106400 <outb>:
{
80106400:	55                   	push   %ebp
80106401:	89 e5                	mov    %esp,%ebp
80106403:	83 ec 08             	sub    $0x8,%esp
80106406:	8b 45 08             	mov    0x8(%ebp),%eax
80106409:	8b 55 0c             	mov    0xc(%ebp),%edx
8010640c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106410:	89 d0                	mov    %edx,%eax
80106412:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106415:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106419:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010641d:	ee                   	out    %al,(%dx)
}
8010641e:	90                   	nop
8010641f:	c9                   	leave  
80106420:	c3                   	ret    

80106421 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106421:	55                   	push   %ebp
80106422:	89 e5                	mov    %esp,%ebp
80106424:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106427:	6a 00                	push   $0x0
80106429:	68 fa 03 00 00       	push   $0x3fa
8010642e:	e8 cd ff ff ff       	call   80106400 <outb>
80106433:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106436:	68 80 00 00 00       	push   $0x80
8010643b:	68 fb 03 00 00       	push   $0x3fb
80106440:	e8 bb ff ff ff       	call   80106400 <outb>
80106445:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106448:	6a 0c                	push   $0xc
8010644a:	68 f8 03 00 00       	push   $0x3f8
8010644f:	e8 ac ff ff ff       	call   80106400 <outb>
80106454:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106457:	6a 00                	push   $0x0
80106459:	68 f9 03 00 00       	push   $0x3f9
8010645e:	e8 9d ff ff ff       	call   80106400 <outb>
80106463:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106466:	6a 03                	push   $0x3
80106468:	68 fb 03 00 00       	push   $0x3fb
8010646d:	e8 8e ff ff ff       	call   80106400 <outb>
80106472:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106475:	6a 00                	push   $0x0
80106477:	68 fc 03 00 00       	push   $0x3fc
8010647c:	e8 7f ff ff ff       	call   80106400 <outb>
80106481:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106484:	6a 01                	push   $0x1
80106486:	68 f9 03 00 00       	push   $0x3f9
8010648b:	e8 70 ff ff ff       	call   80106400 <outb>
80106490:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106493:	68 fd 03 00 00       	push   $0x3fd
80106498:	e8 46 ff ff ff       	call   801063e3 <inb>
8010649d:	83 c4 04             	add    $0x4,%esp
801064a0:	3c ff                	cmp    $0xff,%al
801064a2:	74 61                	je     80106505 <uartinit+0xe4>
    return;
  uart = 1;
801064a4:	c7 05 78 6a 19 80 01 	movl   $0x1,0x80196a78
801064ab:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801064ae:	68 fa 03 00 00       	push   $0x3fa
801064b3:	e8 2b ff ff ff       	call   801063e3 <inb>
801064b8:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801064bb:	68 f8 03 00 00       	push   $0x3f8
801064c0:	e8 1e ff ff ff       	call   801063e3 <inb>
801064c5:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
801064c8:	83 ec 08             	sub    $0x8,%esp
801064cb:	6a 00                	push   $0x0
801064cd:	6a 04                	push   $0x4
801064cf:	e8 47 c1 ff ff       	call   8010261b <ioapicenable>
801064d4:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801064d7:	c7 45 f4 70 a9 10 80 	movl   $0x8010a970,-0xc(%ebp)
801064de:	eb 19                	jmp    801064f9 <uartinit+0xd8>
    uartputc(*p);
801064e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064e3:	0f b6 00             	movzbl (%eax),%eax
801064e6:	0f be c0             	movsbl %al,%eax
801064e9:	83 ec 0c             	sub    $0xc,%esp
801064ec:	50                   	push   %eax
801064ed:	e8 16 00 00 00       	call   80106508 <uartputc>
801064f2:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
801064f5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801064f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064fc:	0f b6 00             	movzbl (%eax),%eax
801064ff:	84 c0                	test   %al,%al
80106501:	75 dd                	jne    801064e0 <uartinit+0xbf>
80106503:	eb 01                	jmp    80106506 <uartinit+0xe5>
    return;
80106505:	90                   	nop
}
80106506:	c9                   	leave  
80106507:	c3                   	ret    

80106508 <uartputc>:

void
uartputc(int c)
{
80106508:	55                   	push   %ebp
80106509:	89 e5                	mov    %esp,%ebp
8010650b:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
8010650e:	a1 78 6a 19 80       	mov    0x80196a78,%eax
80106513:	85 c0                	test   %eax,%eax
80106515:	74 53                	je     8010656a <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106517:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010651e:	eb 11                	jmp    80106531 <uartputc+0x29>
    microdelay(10);
80106520:	83 ec 0c             	sub    $0xc,%esp
80106523:	6a 0a                	push   $0xa
80106525:	e8 fa c5 ff ff       	call   80102b24 <microdelay>
8010652a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010652d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106531:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106535:	7f 1a                	jg     80106551 <uartputc+0x49>
80106537:	83 ec 0c             	sub    $0xc,%esp
8010653a:	68 fd 03 00 00       	push   $0x3fd
8010653f:	e8 9f fe ff ff       	call   801063e3 <inb>
80106544:	83 c4 10             	add    $0x10,%esp
80106547:	0f b6 c0             	movzbl %al,%eax
8010654a:	83 e0 20             	and    $0x20,%eax
8010654d:	85 c0                	test   %eax,%eax
8010654f:	74 cf                	je     80106520 <uartputc+0x18>
  outb(COM1+0, c);
80106551:	8b 45 08             	mov    0x8(%ebp),%eax
80106554:	0f b6 c0             	movzbl %al,%eax
80106557:	83 ec 08             	sub    $0x8,%esp
8010655a:	50                   	push   %eax
8010655b:	68 f8 03 00 00       	push   $0x3f8
80106560:	e8 9b fe ff ff       	call   80106400 <outb>
80106565:	83 c4 10             	add    $0x10,%esp
80106568:	eb 01                	jmp    8010656b <uartputc+0x63>
    return;
8010656a:	90                   	nop
}
8010656b:	c9                   	leave  
8010656c:	c3                   	ret    

8010656d <uartgetc>:

static int
uartgetc(void)
{
8010656d:	55                   	push   %ebp
8010656e:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106570:	a1 78 6a 19 80       	mov    0x80196a78,%eax
80106575:	85 c0                	test   %eax,%eax
80106577:	75 07                	jne    80106580 <uartgetc+0x13>
    return -1;
80106579:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010657e:	eb 2e                	jmp    801065ae <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106580:	68 fd 03 00 00       	push   $0x3fd
80106585:	e8 59 fe ff ff       	call   801063e3 <inb>
8010658a:	83 c4 04             	add    $0x4,%esp
8010658d:	0f b6 c0             	movzbl %al,%eax
80106590:	83 e0 01             	and    $0x1,%eax
80106593:	85 c0                	test   %eax,%eax
80106595:	75 07                	jne    8010659e <uartgetc+0x31>
    return -1;
80106597:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010659c:	eb 10                	jmp    801065ae <uartgetc+0x41>
  return inb(COM1+0);
8010659e:	68 f8 03 00 00       	push   $0x3f8
801065a3:	e8 3b fe ff ff       	call   801063e3 <inb>
801065a8:	83 c4 04             	add    $0x4,%esp
801065ab:	0f b6 c0             	movzbl %al,%eax
}
801065ae:	c9                   	leave  
801065af:	c3                   	ret    

801065b0 <uartintr>:

void
uartintr(void)
{
801065b0:	55                   	push   %ebp
801065b1:	89 e5                	mov    %esp,%ebp
801065b3:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
801065b6:	83 ec 0c             	sub    $0xc,%esp
801065b9:	68 6d 65 10 80       	push   $0x8010656d
801065be:	e8 13 a2 ff ff       	call   801007d6 <consoleintr>
801065c3:	83 c4 10             	add    $0x10,%esp
}
801065c6:	90                   	nop
801065c7:	c9                   	leave  
801065c8:	c3                   	ret    

801065c9 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801065c9:	6a 00                	push   $0x0
  pushl $0
801065cb:	6a 00                	push   $0x0
  jmp alltraps
801065cd:	e9 b8 f8 ff ff       	jmp    80105e8a <alltraps>

801065d2 <vector1>:
.globl vector1
vector1:
  pushl $0
801065d2:	6a 00                	push   $0x0
  pushl $1
801065d4:	6a 01                	push   $0x1
  jmp alltraps
801065d6:	e9 af f8 ff ff       	jmp    80105e8a <alltraps>

801065db <vector2>:
.globl vector2
vector2:
  pushl $0
801065db:	6a 00                	push   $0x0
  pushl $2
801065dd:	6a 02                	push   $0x2
  jmp alltraps
801065df:	e9 a6 f8 ff ff       	jmp    80105e8a <alltraps>

801065e4 <vector3>:
.globl vector3
vector3:
  pushl $0
801065e4:	6a 00                	push   $0x0
  pushl $3
801065e6:	6a 03                	push   $0x3
  jmp alltraps
801065e8:	e9 9d f8 ff ff       	jmp    80105e8a <alltraps>

801065ed <vector4>:
.globl vector4
vector4:
  pushl $0
801065ed:	6a 00                	push   $0x0
  pushl $4
801065ef:	6a 04                	push   $0x4
  jmp alltraps
801065f1:	e9 94 f8 ff ff       	jmp    80105e8a <alltraps>

801065f6 <vector5>:
.globl vector5
vector5:
  pushl $0
801065f6:	6a 00                	push   $0x0
  pushl $5
801065f8:	6a 05                	push   $0x5
  jmp alltraps
801065fa:	e9 8b f8 ff ff       	jmp    80105e8a <alltraps>

801065ff <vector6>:
.globl vector6
vector6:
  pushl $0
801065ff:	6a 00                	push   $0x0
  pushl $6
80106601:	6a 06                	push   $0x6
  jmp alltraps
80106603:	e9 82 f8 ff ff       	jmp    80105e8a <alltraps>

80106608 <vector7>:
.globl vector7
vector7:
  pushl $0
80106608:	6a 00                	push   $0x0
  pushl $7
8010660a:	6a 07                	push   $0x7
  jmp alltraps
8010660c:	e9 79 f8 ff ff       	jmp    80105e8a <alltraps>

80106611 <vector8>:
.globl vector8
vector8:
  pushl $8
80106611:	6a 08                	push   $0x8
  jmp alltraps
80106613:	e9 72 f8 ff ff       	jmp    80105e8a <alltraps>

80106618 <vector9>:
.globl vector9
vector9:
  pushl $0
80106618:	6a 00                	push   $0x0
  pushl $9
8010661a:	6a 09                	push   $0x9
  jmp alltraps
8010661c:	e9 69 f8 ff ff       	jmp    80105e8a <alltraps>

80106621 <vector10>:
.globl vector10
vector10:
  pushl $10
80106621:	6a 0a                	push   $0xa
  jmp alltraps
80106623:	e9 62 f8 ff ff       	jmp    80105e8a <alltraps>

80106628 <vector11>:
.globl vector11
vector11:
  pushl $11
80106628:	6a 0b                	push   $0xb
  jmp alltraps
8010662a:	e9 5b f8 ff ff       	jmp    80105e8a <alltraps>

8010662f <vector12>:
.globl vector12
vector12:
  pushl $12
8010662f:	6a 0c                	push   $0xc
  jmp alltraps
80106631:	e9 54 f8 ff ff       	jmp    80105e8a <alltraps>

80106636 <vector13>:
.globl vector13
vector13:
  pushl $13
80106636:	6a 0d                	push   $0xd
  jmp alltraps
80106638:	e9 4d f8 ff ff       	jmp    80105e8a <alltraps>

8010663d <vector14>:
.globl vector14
vector14:
  pushl $14
8010663d:	6a 0e                	push   $0xe
  jmp alltraps
8010663f:	e9 46 f8 ff ff       	jmp    80105e8a <alltraps>

80106644 <vector15>:
.globl vector15
vector15:
  pushl $0
80106644:	6a 00                	push   $0x0
  pushl $15
80106646:	6a 0f                	push   $0xf
  jmp alltraps
80106648:	e9 3d f8 ff ff       	jmp    80105e8a <alltraps>

8010664d <vector16>:
.globl vector16
vector16:
  pushl $0
8010664d:	6a 00                	push   $0x0
  pushl $16
8010664f:	6a 10                	push   $0x10
  jmp alltraps
80106651:	e9 34 f8 ff ff       	jmp    80105e8a <alltraps>

80106656 <vector17>:
.globl vector17
vector17:
  pushl $17
80106656:	6a 11                	push   $0x11
  jmp alltraps
80106658:	e9 2d f8 ff ff       	jmp    80105e8a <alltraps>

8010665d <vector18>:
.globl vector18
vector18:
  pushl $0
8010665d:	6a 00                	push   $0x0
  pushl $18
8010665f:	6a 12                	push   $0x12
  jmp alltraps
80106661:	e9 24 f8 ff ff       	jmp    80105e8a <alltraps>

80106666 <vector19>:
.globl vector19
vector19:
  pushl $0
80106666:	6a 00                	push   $0x0
  pushl $19
80106668:	6a 13                	push   $0x13
  jmp alltraps
8010666a:	e9 1b f8 ff ff       	jmp    80105e8a <alltraps>

8010666f <vector20>:
.globl vector20
vector20:
  pushl $0
8010666f:	6a 00                	push   $0x0
  pushl $20
80106671:	6a 14                	push   $0x14
  jmp alltraps
80106673:	e9 12 f8 ff ff       	jmp    80105e8a <alltraps>

80106678 <vector21>:
.globl vector21
vector21:
  pushl $0
80106678:	6a 00                	push   $0x0
  pushl $21
8010667a:	6a 15                	push   $0x15
  jmp alltraps
8010667c:	e9 09 f8 ff ff       	jmp    80105e8a <alltraps>

80106681 <vector22>:
.globl vector22
vector22:
  pushl $0
80106681:	6a 00                	push   $0x0
  pushl $22
80106683:	6a 16                	push   $0x16
  jmp alltraps
80106685:	e9 00 f8 ff ff       	jmp    80105e8a <alltraps>

8010668a <vector23>:
.globl vector23
vector23:
  pushl $0
8010668a:	6a 00                	push   $0x0
  pushl $23
8010668c:	6a 17                	push   $0x17
  jmp alltraps
8010668e:	e9 f7 f7 ff ff       	jmp    80105e8a <alltraps>

80106693 <vector24>:
.globl vector24
vector24:
  pushl $0
80106693:	6a 00                	push   $0x0
  pushl $24
80106695:	6a 18                	push   $0x18
  jmp alltraps
80106697:	e9 ee f7 ff ff       	jmp    80105e8a <alltraps>

8010669c <vector25>:
.globl vector25
vector25:
  pushl $0
8010669c:	6a 00                	push   $0x0
  pushl $25
8010669e:	6a 19                	push   $0x19
  jmp alltraps
801066a0:	e9 e5 f7 ff ff       	jmp    80105e8a <alltraps>

801066a5 <vector26>:
.globl vector26
vector26:
  pushl $0
801066a5:	6a 00                	push   $0x0
  pushl $26
801066a7:	6a 1a                	push   $0x1a
  jmp alltraps
801066a9:	e9 dc f7 ff ff       	jmp    80105e8a <alltraps>

801066ae <vector27>:
.globl vector27
vector27:
  pushl $0
801066ae:	6a 00                	push   $0x0
  pushl $27
801066b0:	6a 1b                	push   $0x1b
  jmp alltraps
801066b2:	e9 d3 f7 ff ff       	jmp    80105e8a <alltraps>

801066b7 <vector28>:
.globl vector28
vector28:
  pushl $0
801066b7:	6a 00                	push   $0x0
  pushl $28
801066b9:	6a 1c                	push   $0x1c
  jmp alltraps
801066bb:	e9 ca f7 ff ff       	jmp    80105e8a <alltraps>

801066c0 <vector29>:
.globl vector29
vector29:
  pushl $0
801066c0:	6a 00                	push   $0x0
  pushl $29
801066c2:	6a 1d                	push   $0x1d
  jmp alltraps
801066c4:	e9 c1 f7 ff ff       	jmp    80105e8a <alltraps>

801066c9 <vector30>:
.globl vector30
vector30:
  pushl $0
801066c9:	6a 00                	push   $0x0
  pushl $30
801066cb:	6a 1e                	push   $0x1e
  jmp alltraps
801066cd:	e9 b8 f7 ff ff       	jmp    80105e8a <alltraps>

801066d2 <vector31>:
.globl vector31
vector31:
  pushl $0
801066d2:	6a 00                	push   $0x0
  pushl $31
801066d4:	6a 1f                	push   $0x1f
  jmp alltraps
801066d6:	e9 af f7 ff ff       	jmp    80105e8a <alltraps>

801066db <vector32>:
.globl vector32
vector32:
  pushl $0
801066db:	6a 00                	push   $0x0
  pushl $32
801066dd:	6a 20                	push   $0x20
  jmp alltraps
801066df:	e9 a6 f7 ff ff       	jmp    80105e8a <alltraps>

801066e4 <vector33>:
.globl vector33
vector33:
  pushl $0
801066e4:	6a 00                	push   $0x0
  pushl $33
801066e6:	6a 21                	push   $0x21
  jmp alltraps
801066e8:	e9 9d f7 ff ff       	jmp    80105e8a <alltraps>

801066ed <vector34>:
.globl vector34
vector34:
  pushl $0
801066ed:	6a 00                	push   $0x0
  pushl $34
801066ef:	6a 22                	push   $0x22
  jmp alltraps
801066f1:	e9 94 f7 ff ff       	jmp    80105e8a <alltraps>

801066f6 <vector35>:
.globl vector35
vector35:
  pushl $0
801066f6:	6a 00                	push   $0x0
  pushl $35
801066f8:	6a 23                	push   $0x23
  jmp alltraps
801066fa:	e9 8b f7 ff ff       	jmp    80105e8a <alltraps>

801066ff <vector36>:
.globl vector36
vector36:
  pushl $0
801066ff:	6a 00                	push   $0x0
  pushl $36
80106701:	6a 24                	push   $0x24
  jmp alltraps
80106703:	e9 82 f7 ff ff       	jmp    80105e8a <alltraps>

80106708 <vector37>:
.globl vector37
vector37:
  pushl $0
80106708:	6a 00                	push   $0x0
  pushl $37
8010670a:	6a 25                	push   $0x25
  jmp alltraps
8010670c:	e9 79 f7 ff ff       	jmp    80105e8a <alltraps>

80106711 <vector38>:
.globl vector38
vector38:
  pushl $0
80106711:	6a 00                	push   $0x0
  pushl $38
80106713:	6a 26                	push   $0x26
  jmp alltraps
80106715:	e9 70 f7 ff ff       	jmp    80105e8a <alltraps>

8010671a <vector39>:
.globl vector39
vector39:
  pushl $0
8010671a:	6a 00                	push   $0x0
  pushl $39
8010671c:	6a 27                	push   $0x27
  jmp alltraps
8010671e:	e9 67 f7 ff ff       	jmp    80105e8a <alltraps>

80106723 <vector40>:
.globl vector40
vector40:
  pushl $0
80106723:	6a 00                	push   $0x0
  pushl $40
80106725:	6a 28                	push   $0x28
  jmp alltraps
80106727:	e9 5e f7 ff ff       	jmp    80105e8a <alltraps>

8010672c <vector41>:
.globl vector41
vector41:
  pushl $0
8010672c:	6a 00                	push   $0x0
  pushl $41
8010672e:	6a 29                	push   $0x29
  jmp alltraps
80106730:	e9 55 f7 ff ff       	jmp    80105e8a <alltraps>

80106735 <vector42>:
.globl vector42
vector42:
  pushl $0
80106735:	6a 00                	push   $0x0
  pushl $42
80106737:	6a 2a                	push   $0x2a
  jmp alltraps
80106739:	e9 4c f7 ff ff       	jmp    80105e8a <alltraps>

8010673e <vector43>:
.globl vector43
vector43:
  pushl $0
8010673e:	6a 00                	push   $0x0
  pushl $43
80106740:	6a 2b                	push   $0x2b
  jmp alltraps
80106742:	e9 43 f7 ff ff       	jmp    80105e8a <alltraps>

80106747 <vector44>:
.globl vector44
vector44:
  pushl $0
80106747:	6a 00                	push   $0x0
  pushl $44
80106749:	6a 2c                	push   $0x2c
  jmp alltraps
8010674b:	e9 3a f7 ff ff       	jmp    80105e8a <alltraps>

80106750 <vector45>:
.globl vector45
vector45:
  pushl $0
80106750:	6a 00                	push   $0x0
  pushl $45
80106752:	6a 2d                	push   $0x2d
  jmp alltraps
80106754:	e9 31 f7 ff ff       	jmp    80105e8a <alltraps>

80106759 <vector46>:
.globl vector46
vector46:
  pushl $0
80106759:	6a 00                	push   $0x0
  pushl $46
8010675b:	6a 2e                	push   $0x2e
  jmp alltraps
8010675d:	e9 28 f7 ff ff       	jmp    80105e8a <alltraps>

80106762 <vector47>:
.globl vector47
vector47:
  pushl $0
80106762:	6a 00                	push   $0x0
  pushl $47
80106764:	6a 2f                	push   $0x2f
  jmp alltraps
80106766:	e9 1f f7 ff ff       	jmp    80105e8a <alltraps>

8010676b <vector48>:
.globl vector48
vector48:
  pushl $0
8010676b:	6a 00                	push   $0x0
  pushl $48
8010676d:	6a 30                	push   $0x30
  jmp alltraps
8010676f:	e9 16 f7 ff ff       	jmp    80105e8a <alltraps>

80106774 <vector49>:
.globl vector49
vector49:
  pushl $0
80106774:	6a 00                	push   $0x0
  pushl $49
80106776:	6a 31                	push   $0x31
  jmp alltraps
80106778:	e9 0d f7 ff ff       	jmp    80105e8a <alltraps>

8010677d <vector50>:
.globl vector50
vector50:
  pushl $0
8010677d:	6a 00                	push   $0x0
  pushl $50
8010677f:	6a 32                	push   $0x32
  jmp alltraps
80106781:	e9 04 f7 ff ff       	jmp    80105e8a <alltraps>

80106786 <vector51>:
.globl vector51
vector51:
  pushl $0
80106786:	6a 00                	push   $0x0
  pushl $51
80106788:	6a 33                	push   $0x33
  jmp alltraps
8010678a:	e9 fb f6 ff ff       	jmp    80105e8a <alltraps>

8010678f <vector52>:
.globl vector52
vector52:
  pushl $0
8010678f:	6a 00                	push   $0x0
  pushl $52
80106791:	6a 34                	push   $0x34
  jmp alltraps
80106793:	e9 f2 f6 ff ff       	jmp    80105e8a <alltraps>

80106798 <vector53>:
.globl vector53
vector53:
  pushl $0
80106798:	6a 00                	push   $0x0
  pushl $53
8010679a:	6a 35                	push   $0x35
  jmp alltraps
8010679c:	e9 e9 f6 ff ff       	jmp    80105e8a <alltraps>

801067a1 <vector54>:
.globl vector54
vector54:
  pushl $0
801067a1:	6a 00                	push   $0x0
  pushl $54
801067a3:	6a 36                	push   $0x36
  jmp alltraps
801067a5:	e9 e0 f6 ff ff       	jmp    80105e8a <alltraps>

801067aa <vector55>:
.globl vector55
vector55:
  pushl $0
801067aa:	6a 00                	push   $0x0
  pushl $55
801067ac:	6a 37                	push   $0x37
  jmp alltraps
801067ae:	e9 d7 f6 ff ff       	jmp    80105e8a <alltraps>

801067b3 <vector56>:
.globl vector56
vector56:
  pushl $0
801067b3:	6a 00                	push   $0x0
  pushl $56
801067b5:	6a 38                	push   $0x38
  jmp alltraps
801067b7:	e9 ce f6 ff ff       	jmp    80105e8a <alltraps>

801067bc <vector57>:
.globl vector57
vector57:
  pushl $0
801067bc:	6a 00                	push   $0x0
  pushl $57
801067be:	6a 39                	push   $0x39
  jmp alltraps
801067c0:	e9 c5 f6 ff ff       	jmp    80105e8a <alltraps>

801067c5 <vector58>:
.globl vector58
vector58:
  pushl $0
801067c5:	6a 00                	push   $0x0
  pushl $58
801067c7:	6a 3a                	push   $0x3a
  jmp alltraps
801067c9:	e9 bc f6 ff ff       	jmp    80105e8a <alltraps>

801067ce <vector59>:
.globl vector59
vector59:
  pushl $0
801067ce:	6a 00                	push   $0x0
  pushl $59
801067d0:	6a 3b                	push   $0x3b
  jmp alltraps
801067d2:	e9 b3 f6 ff ff       	jmp    80105e8a <alltraps>

801067d7 <vector60>:
.globl vector60
vector60:
  pushl $0
801067d7:	6a 00                	push   $0x0
  pushl $60
801067d9:	6a 3c                	push   $0x3c
  jmp alltraps
801067db:	e9 aa f6 ff ff       	jmp    80105e8a <alltraps>

801067e0 <vector61>:
.globl vector61
vector61:
  pushl $0
801067e0:	6a 00                	push   $0x0
  pushl $61
801067e2:	6a 3d                	push   $0x3d
  jmp alltraps
801067e4:	e9 a1 f6 ff ff       	jmp    80105e8a <alltraps>

801067e9 <vector62>:
.globl vector62
vector62:
  pushl $0
801067e9:	6a 00                	push   $0x0
  pushl $62
801067eb:	6a 3e                	push   $0x3e
  jmp alltraps
801067ed:	e9 98 f6 ff ff       	jmp    80105e8a <alltraps>

801067f2 <vector63>:
.globl vector63
vector63:
  pushl $0
801067f2:	6a 00                	push   $0x0
  pushl $63
801067f4:	6a 3f                	push   $0x3f
  jmp alltraps
801067f6:	e9 8f f6 ff ff       	jmp    80105e8a <alltraps>

801067fb <vector64>:
.globl vector64
vector64:
  pushl $0
801067fb:	6a 00                	push   $0x0
  pushl $64
801067fd:	6a 40                	push   $0x40
  jmp alltraps
801067ff:	e9 86 f6 ff ff       	jmp    80105e8a <alltraps>

80106804 <vector65>:
.globl vector65
vector65:
  pushl $0
80106804:	6a 00                	push   $0x0
  pushl $65
80106806:	6a 41                	push   $0x41
  jmp alltraps
80106808:	e9 7d f6 ff ff       	jmp    80105e8a <alltraps>

8010680d <vector66>:
.globl vector66
vector66:
  pushl $0
8010680d:	6a 00                	push   $0x0
  pushl $66
8010680f:	6a 42                	push   $0x42
  jmp alltraps
80106811:	e9 74 f6 ff ff       	jmp    80105e8a <alltraps>

80106816 <vector67>:
.globl vector67
vector67:
  pushl $0
80106816:	6a 00                	push   $0x0
  pushl $67
80106818:	6a 43                	push   $0x43
  jmp alltraps
8010681a:	e9 6b f6 ff ff       	jmp    80105e8a <alltraps>

8010681f <vector68>:
.globl vector68
vector68:
  pushl $0
8010681f:	6a 00                	push   $0x0
  pushl $68
80106821:	6a 44                	push   $0x44
  jmp alltraps
80106823:	e9 62 f6 ff ff       	jmp    80105e8a <alltraps>

80106828 <vector69>:
.globl vector69
vector69:
  pushl $0
80106828:	6a 00                	push   $0x0
  pushl $69
8010682a:	6a 45                	push   $0x45
  jmp alltraps
8010682c:	e9 59 f6 ff ff       	jmp    80105e8a <alltraps>

80106831 <vector70>:
.globl vector70
vector70:
  pushl $0
80106831:	6a 00                	push   $0x0
  pushl $70
80106833:	6a 46                	push   $0x46
  jmp alltraps
80106835:	e9 50 f6 ff ff       	jmp    80105e8a <alltraps>

8010683a <vector71>:
.globl vector71
vector71:
  pushl $0
8010683a:	6a 00                	push   $0x0
  pushl $71
8010683c:	6a 47                	push   $0x47
  jmp alltraps
8010683e:	e9 47 f6 ff ff       	jmp    80105e8a <alltraps>

80106843 <vector72>:
.globl vector72
vector72:
  pushl $0
80106843:	6a 00                	push   $0x0
  pushl $72
80106845:	6a 48                	push   $0x48
  jmp alltraps
80106847:	e9 3e f6 ff ff       	jmp    80105e8a <alltraps>

8010684c <vector73>:
.globl vector73
vector73:
  pushl $0
8010684c:	6a 00                	push   $0x0
  pushl $73
8010684e:	6a 49                	push   $0x49
  jmp alltraps
80106850:	e9 35 f6 ff ff       	jmp    80105e8a <alltraps>

80106855 <vector74>:
.globl vector74
vector74:
  pushl $0
80106855:	6a 00                	push   $0x0
  pushl $74
80106857:	6a 4a                	push   $0x4a
  jmp alltraps
80106859:	e9 2c f6 ff ff       	jmp    80105e8a <alltraps>

8010685e <vector75>:
.globl vector75
vector75:
  pushl $0
8010685e:	6a 00                	push   $0x0
  pushl $75
80106860:	6a 4b                	push   $0x4b
  jmp alltraps
80106862:	e9 23 f6 ff ff       	jmp    80105e8a <alltraps>

80106867 <vector76>:
.globl vector76
vector76:
  pushl $0
80106867:	6a 00                	push   $0x0
  pushl $76
80106869:	6a 4c                	push   $0x4c
  jmp alltraps
8010686b:	e9 1a f6 ff ff       	jmp    80105e8a <alltraps>

80106870 <vector77>:
.globl vector77
vector77:
  pushl $0
80106870:	6a 00                	push   $0x0
  pushl $77
80106872:	6a 4d                	push   $0x4d
  jmp alltraps
80106874:	e9 11 f6 ff ff       	jmp    80105e8a <alltraps>

80106879 <vector78>:
.globl vector78
vector78:
  pushl $0
80106879:	6a 00                	push   $0x0
  pushl $78
8010687b:	6a 4e                	push   $0x4e
  jmp alltraps
8010687d:	e9 08 f6 ff ff       	jmp    80105e8a <alltraps>

80106882 <vector79>:
.globl vector79
vector79:
  pushl $0
80106882:	6a 00                	push   $0x0
  pushl $79
80106884:	6a 4f                	push   $0x4f
  jmp alltraps
80106886:	e9 ff f5 ff ff       	jmp    80105e8a <alltraps>

8010688b <vector80>:
.globl vector80
vector80:
  pushl $0
8010688b:	6a 00                	push   $0x0
  pushl $80
8010688d:	6a 50                	push   $0x50
  jmp alltraps
8010688f:	e9 f6 f5 ff ff       	jmp    80105e8a <alltraps>

80106894 <vector81>:
.globl vector81
vector81:
  pushl $0
80106894:	6a 00                	push   $0x0
  pushl $81
80106896:	6a 51                	push   $0x51
  jmp alltraps
80106898:	e9 ed f5 ff ff       	jmp    80105e8a <alltraps>

8010689d <vector82>:
.globl vector82
vector82:
  pushl $0
8010689d:	6a 00                	push   $0x0
  pushl $82
8010689f:	6a 52                	push   $0x52
  jmp alltraps
801068a1:	e9 e4 f5 ff ff       	jmp    80105e8a <alltraps>

801068a6 <vector83>:
.globl vector83
vector83:
  pushl $0
801068a6:	6a 00                	push   $0x0
  pushl $83
801068a8:	6a 53                	push   $0x53
  jmp alltraps
801068aa:	e9 db f5 ff ff       	jmp    80105e8a <alltraps>

801068af <vector84>:
.globl vector84
vector84:
  pushl $0
801068af:	6a 00                	push   $0x0
  pushl $84
801068b1:	6a 54                	push   $0x54
  jmp alltraps
801068b3:	e9 d2 f5 ff ff       	jmp    80105e8a <alltraps>

801068b8 <vector85>:
.globl vector85
vector85:
  pushl $0
801068b8:	6a 00                	push   $0x0
  pushl $85
801068ba:	6a 55                	push   $0x55
  jmp alltraps
801068bc:	e9 c9 f5 ff ff       	jmp    80105e8a <alltraps>

801068c1 <vector86>:
.globl vector86
vector86:
  pushl $0
801068c1:	6a 00                	push   $0x0
  pushl $86
801068c3:	6a 56                	push   $0x56
  jmp alltraps
801068c5:	e9 c0 f5 ff ff       	jmp    80105e8a <alltraps>

801068ca <vector87>:
.globl vector87
vector87:
  pushl $0
801068ca:	6a 00                	push   $0x0
  pushl $87
801068cc:	6a 57                	push   $0x57
  jmp alltraps
801068ce:	e9 b7 f5 ff ff       	jmp    80105e8a <alltraps>

801068d3 <vector88>:
.globl vector88
vector88:
  pushl $0
801068d3:	6a 00                	push   $0x0
  pushl $88
801068d5:	6a 58                	push   $0x58
  jmp alltraps
801068d7:	e9 ae f5 ff ff       	jmp    80105e8a <alltraps>

801068dc <vector89>:
.globl vector89
vector89:
  pushl $0
801068dc:	6a 00                	push   $0x0
  pushl $89
801068de:	6a 59                	push   $0x59
  jmp alltraps
801068e0:	e9 a5 f5 ff ff       	jmp    80105e8a <alltraps>

801068e5 <vector90>:
.globl vector90
vector90:
  pushl $0
801068e5:	6a 00                	push   $0x0
  pushl $90
801068e7:	6a 5a                	push   $0x5a
  jmp alltraps
801068e9:	e9 9c f5 ff ff       	jmp    80105e8a <alltraps>

801068ee <vector91>:
.globl vector91
vector91:
  pushl $0
801068ee:	6a 00                	push   $0x0
  pushl $91
801068f0:	6a 5b                	push   $0x5b
  jmp alltraps
801068f2:	e9 93 f5 ff ff       	jmp    80105e8a <alltraps>

801068f7 <vector92>:
.globl vector92
vector92:
  pushl $0
801068f7:	6a 00                	push   $0x0
  pushl $92
801068f9:	6a 5c                	push   $0x5c
  jmp alltraps
801068fb:	e9 8a f5 ff ff       	jmp    80105e8a <alltraps>

80106900 <vector93>:
.globl vector93
vector93:
  pushl $0
80106900:	6a 00                	push   $0x0
  pushl $93
80106902:	6a 5d                	push   $0x5d
  jmp alltraps
80106904:	e9 81 f5 ff ff       	jmp    80105e8a <alltraps>

80106909 <vector94>:
.globl vector94
vector94:
  pushl $0
80106909:	6a 00                	push   $0x0
  pushl $94
8010690b:	6a 5e                	push   $0x5e
  jmp alltraps
8010690d:	e9 78 f5 ff ff       	jmp    80105e8a <alltraps>

80106912 <vector95>:
.globl vector95
vector95:
  pushl $0
80106912:	6a 00                	push   $0x0
  pushl $95
80106914:	6a 5f                	push   $0x5f
  jmp alltraps
80106916:	e9 6f f5 ff ff       	jmp    80105e8a <alltraps>

8010691b <vector96>:
.globl vector96
vector96:
  pushl $0
8010691b:	6a 00                	push   $0x0
  pushl $96
8010691d:	6a 60                	push   $0x60
  jmp alltraps
8010691f:	e9 66 f5 ff ff       	jmp    80105e8a <alltraps>

80106924 <vector97>:
.globl vector97
vector97:
  pushl $0
80106924:	6a 00                	push   $0x0
  pushl $97
80106926:	6a 61                	push   $0x61
  jmp alltraps
80106928:	e9 5d f5 ff ff       	jmp    80105e8a <alltraps>

8010692d <vector98>:
.globl vector98
vector98:
  pushl $0
8010692d:	6a 00                	push   $0x0
  pushl $98
8010692f:	6a 62                	push   $0x62
  jmp alltraps
80106931:	e9 54 f5 ff ff       	jmp    80105e8a <alltraps>

80106936 <vector99>:
.globl vector99
vector99:
  pushl $0
80106936:	6a 00                	push   $0x0
  pushl $99
80106938:	6a 63                	push   $0x63
  jmp alltraps
8010693a:	e9 4b f5 ff ff       	jmp    80105e8a <alltraps>

8010693f <vector100>:
.globl vector100
vector100:
  pushl $0
8010693f:	6a 00                	push   $0x0
  pushl $100
80106941:	6a 64                	push   $0x64
  jmp alltraps
80106943:	e9 42 f5 ff ff       	jmp    80105e8a <alltraps>

80106948 <vector101>:
.globl vector101
vector101:
  pushl $0
80106948:	6a 00                	push   $0x0
  pushl $101
8010694a:	6a 65                	push   $0x65
  jmp alltraps
8010694c:	e9 39 f5 ff ff       	jmp    80105e8a <alltraps>

80106951 <vector102>:
.globl vector102
vector102:
  pushl $0
80106951:	6a 00                	push   $0x0
  pushl $102
80106953:	6a 66                	push   $0x66
  jmp alltraps
80106955:	e9 30 f5 ff ff       	jmp    80105e8a <alltraps>

8010695a <vector103>:
.globl vector103
vector103:
  pushl $0
8010695a:	6a 00                	push   $0x0
  pushl $103
8010695c:	6a 67                	push   $0x67
  jmp alltraps
8010695e:	e9 27 f5 ff ff       	jmp    80105e8a <alltraps>

80106963 <vector104>:
.globl vector104
vector104:
  pushl $0
80106963:	6a 00                	push   $0x0
  pushl $104
80106965:	6a 68                	push   $0x68
  jmp alltraps
80106967:	e9 1e f5 ff ff       	jmp    80105e8a <alltraps>

8010696c <vector105>:
.globl vector105
vector105:
  pushl $0
8010696c:	6a 00                	push   $0x0
  pushl $105
8010696e:	6a 69                	push   $0x69
  jmp alltraps
80106970:	e9 15 f5 ff ff       	jmp    80105e8a <alltraps>

80106975 <vector106>:
.globl vector106
vector106:
  pushl $0
80106975:	6a 00                	push   $0x0
  pushl $106
80106977:	6a 6a                	push   $0x6a
  jmp alltraps
80106979:	e9 0c f5 ff ff       	jmp    80105e8a <alltraps>

8010697e <vector107>:
.globl vector107
vector107:
  pushl $0
8010697e:	6a 00                	push   $0x0
  pushl $107
80106980:	6a 6b                	push   $0x6b
  jmp alltraps
80106982:	e9 03 f5 ff ff       	jmp    80105e8a <alltraps>

80106987 <vector108>:
.globl vector108
vector108:
  pushl $0
80106987:	6a 00                	push   $0x0
  pushl $108
80106989:	6a 6c                	push   $0x6c
  jmp alltraps
8010698b:	e9 fa f4 ff ff       	jmp    80105e8a <alltraps>

80106990 <vector109>:
.globl vector109
vector109:
  pushl $0
80106990:	6a 00                	push   $0x0
  pushl $109
80106992:	6a 6d                	push   $0x6d
  jmp alltraps
80106994:	e9 f1 f4 ff ff       	jmp    80105e8a <alltraps>

80106999 <vector110>:
.globl vector110
vector110:
  pushl $0
80106999:	6a 00                	push   $0x0
  pushl $110
8010699b:	6a 6e                	push   $0x6e
  jmp alltraps
8010699d:	e9 e8 f4 ff ff       	jmp    80105e8a <alltraps>

801069a2 <vector111>:
.globl vector111
vector111:
  pushl $0
801069a2:	6a 00                	push   $0x0
  pushl $111
801069a4:	6a 6f                	push   $0x6f
  jmp alltraps
801069a6:	e9 df f4 ff ff       	jmp    80105e8a <alltraps>

801069ab <vector112>:
.globl vector112
vector112:
  pushl $0
801069ab:	6a 00                	push   $0x0
  pushl $112
801069ad:	6a 70                	push   $0x70
  jmp alltraps
801069af:	e9 d6 f4 ff ff       	jmp    80105e8a <alltraps>

801069b4 <vector113>:
.globl vector113
vector113:
  pushl $0
801069b4:	6a 00                	push   $0x0
  pushl $113
801069b6:	6a 71                	push   $0x71
  jmp alltraps
801069b8:	e9 cd f4 ff ff       	jmp    80105e8a <alltraps>

801069bd <vector114>:
.globl vector114
vector114:
  pushl $0
801069bd:	6a 00                	push   $0x0
  pushl $114
801069bf:	6a 72                	push   $0x72
  jmp alltraps
801069c1:	e9 c4 f4 ff ff       	jmp    80105e8a <alltraps>

801069c6 <vector115>:
.globl vector115
vector115:
  pushl $0
801069c6:	6a 00                	push   $0x0
  pushl $115
801069c8:	6a 73                	push   $0x73
  jmp alltraps
801069ca:	e9 bb f4 ff ff       	jmp    80105e8a <alltraps>

801069cf <vector116>:
.globl vector116
vector116:
  pushl $0
801069cf:	6a 00                	push   $0x0
  pushl $116
801069d1:	6a 74                	push   $0x74
  jmp alltraps
801069d3:	e9 b2 f4 ff ff       	jmp    80105e8a <alltraps>

801069d8 <vector117>:
.globl vector117
vector117:
  pushl $0
801069d8:	6a 00                	push   $0x0
  pushl $117
801069da:	6a 75                	push   $0x75
  jmp alltraps
801069dc:	e9 a9 f4 ff ff       	jmp    80105e8a <alltraps>

801069e1 <vector118>:
.globl vector118
vector118:
  pushl $0
801069e1:	6a 00                	push   $0x0
  pushl $118
801069e3:	6a 76                	push   $0x76
  jmp alltraps
801069e5:	e9 a0 f4 ff ff       	jmp    80105e8a <alltraps>

801069ea <vector119>:
.globl vector119
vector119:
  pushl $0
801069ea:	6a 00                	push   $0x0
  pushl $119
801069ec:	6a 77                	push   $0x77
  jmp alltraps
801069ee:	e9 97 f4 ff ff       	jmp    80105e8a <alltraps>

801069f3 <vector120>:
.globl vector120
vector120:
  pushl $0
801069f3:	6a 00                	push   $0x0
  pushl $120
801069f5:	6a 78                	push   $0x78
  jmp alltraps
801069f7:	e9 8e f4 ff ff       	jmp    80105e8a <alltraps>

801069fc <vector121>:
.globl vector121
vector121:
  pushl $0
801069fc:	6a 00                	push   $0x0
  pushl $121
801069fe:	6a 79                	push   $0x79
  jmp alltraps
80106a00:	e9 85 f4 ff ff       	jmp    80105e8a <alltraps>

80106a05 <vector122>:
.globl vector122
vector122:
  pushl $0
80106a05:	6a 00                	push   $0x0
  pushl $122
80106a07:	6a 7a                	push   $0x7a
  jmp alltraps
80106a09:	e9 7c f4 ff ff       	jmp    80105e8a <alltraps>

80106a0e <vector123>:
.globl vector123
vector123:
  pushl $0
80106a0e:	6a 00                	push   $0x0
  pushl $123
80106a10:	6a 7b                	push   $0x7b
  jmp alltraps
80106a12:	e9 73 f4 ff ff       	jmp    80105e8a <alltraps>

80106a17 <vector124>:
.globl vector124
vector124:
  pushl $0
80106a17:	6a 00                	push   $0x0
  pushl $124
80106a19:	6a 7c                	push   $0x7c
  jmp alltraps
80106a1b:	e9 6a f4 ff ff       	jmp    80105e8a <alltraps>

80106a20 <vector125>:
.globl vector125
vector125:
  pushl $0
80106a20:	6a 00                	push   $0x0
  pushl $125
80106a22:	6a 7d                	push   $0x7d
  jmp alltraps
80106a24:	e9 61 f4 ff ff       	jmp    80105e8a <alltraps>

80106a29 <vector126>:
.globl vector126
vector126:
  pushl $0
80106a29:	6a 00                	push   $0x0
  pushl $126
80106a2b:	6a 7e                	push   $0x7e
  jmp alltraps
80106a2d:	e9 58 f4 ff ff       	jmp    80105e8a <alltraps>

80106a32 <vector127>:
.globl vector127
vector127:
  pushl $0
80106a32:	6a 00                	push   $0x0
  pushl $127
80106a34:	6a 7f                	push   $0x7f
  jmp alltraps
80106a36:	e9 4f f4 ff ff       	jmp    80105e8a <alltraps>

80106a3b <vector128>:
.globl vector128
vector128:
  pushl $0
80106a3b:	6a 00                	push   $0x0
  pushl $128
80106a3d:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106a42:	e9 43 f4 ff ff       	jmp    80105e8a <alltraps>

80106a47 <vector129>:
.globl vector129
vector129:
  pushl $0
80106a47:	6a 00                	push   $0x0
  pushl $129
80106a49:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106a4e:	e9 37 f4 ff ff       	jmp    80105e8a <alltraps>

80106a53 <vector130>:
.globl vector130
vector130:
  pushl $0
80106a53:	6a 00                	push   $0x0
  pushl $130
80106a55:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106a5a:	e9 2b f4 ff ff       	jmp    80105e8a <alltraps>

80106a5f <vector131>:
.globl vector131
vector131:
  pushl $0
80106a5f:	6a 00                	push   $0x0
  pushl $131
80106a61:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106a66:	e9 1f f4 ff ff       	jmp    80105e8a <alltraps>

80106a6b <vector132>:
.globl vector132
vector132:
  pushl $0
80106a6b:	6a 00                	push   $0x0
  pushl $132
80106a6d:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106a72:	e9 13 f4 ff ff       	jmp    80105e8a <alltraps>

80106a77 <vector133>:
.globl vector133
vector133:
  pushl $0
80106a77:	6a 00                	push   $0x0
  pushl $133
80106a79:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106a7e:	e9 07 f4 ff ff       	jmp    80105e8a <alltraps>

80106a83 <vector134>:
.globl vector134
vector134:
  pushl $0
80106a83:	6a 00                	push   $0x0
  pushl $134
80106a85:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106a8a:	e9 fb f3 ff ff       	jmp    80105e8a <alltraps>

80106a8f <vector135>:
.globl vector135
vector135:
  pushl $0
80106a8f:	6a 00                	push   $0x0
  pushl $135
80106a91:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106a96:	e9 ef f3 ff ff       	jmp    80105e8a <alltraps>

80106a9b <vector136>:
.globl vector136
vector136:
  pushl $0
80106a9b:	6a 00                	push   $0x0
  pushl $136
80106a9d:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106aa2:	e9 e3 f3 ff ff       	jmp    80105e8a <alltraps>

80106aa7 <vector137>:
.globl vector137
vector137:
  pushl $0
80106aa7:	6a 00                	push   $0x0
  pushl $137
80106aa9:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106aae:	e9 d7 f3 ff ff       	jmp    80105e8a <alltraps>

80106ab3 <vector138>:
.globl vector138
vector138:
  pushl $0
80106ab3:	6a 00                	push   $0x0
  pushl $138
80106ab5:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106aba:	e9 cb f3 ff ff       	jmp    80105e8a <alltraps>

80106abf <vector139>:
.globl vector139
vector139:
  pushl $0
80106abf:	6a 00                	push   $0x0
  pushl $139
80106ac1:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106ac6:	e9 bf f3 ff ff       	jmp    80105e8a <alltraps>

80106acb <vector140>:
.globl vector140
vector140:
  pushl $0
80106acb:	6a 00                	push   $0x0
  pushl $140
80106acd:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106ad2:	e9 b3 f3 ff ff       	jmp    80105e8a <alltraps>

80106ad7 <vector141>:
.globl vector141
vector141:
  pushl $0
80106ad7:	6a 00                	push   $0x0
  pushl $141
80106ad9:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106ade:	e9 a7 f3 ff ff       	jmp    80105e8a <alltraps>

80106ae3 <vector142>:
.globl vector142
vector142:
  pushl $0
80106ae3:	6a 00                	push   $0x0
  pushl $142
80106ae5:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106aea:	e9 9b f3 ff ff       	jmp    80105e8a <alltraps>

80106aef <vector143>:
.globl vector143
vector143:
  pushl $0
80106aef:	6a 00                	push   $0x0
  pushl $143
80106af1:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106af6:	e9 8f f3 ff ff       	jmp    80105e8a <alltraps>

80106afb <vector144>:
.globl vector144
vector144:
  pushl $0
80106afb:	6a 00                	push   $0x0
  pushl $144
80106afd:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106b02:	e9 83 f3 ff ff       	jmp    80105e8a <alltraps>

80106b07 <vector145>:
.globl vector145
vector145:
  pushl $0
80106b07:	6a 00                	push   $0x0
  pushl $145
80106b09:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106b0e:	e9 77 f3 ff ff       	jmp    80105e8a <alltraps>

80106b13 <vector146>:
.globl vector146
vector146:
  pushl $0
80106b13:	6a 00                	push   $0x0
  pushl $146
80106b15:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106b1a:	e9 6b f3 ff ff       	jmp    80105e8a <alltraps>

80106b1f <vector147>:
.globl vector147
vector147:
  pushl $0
80106b1f:	6a 00                	push   $0x0
  pushl $147
80106b21:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106b26:	e9 5f f3 ff ff       	jmp    80105e8a <alltraps>

80106b2b <vector148>:
.globl vector148
vector148:
  pushl $0
80106b2b:	6a 00                	push   $0x0
  pushl $148
80106b2d:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106b32:	e9 53 f3 ff ff       	jmp    80105e8a <alltraps>

80106b37 <vector149>:
.globl vector149
vector149:
  pushl $0
80106b37:	6a 00                	push   $0x0
  pushl $149
80106b39:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106b3e:	e9 47 f3 ff ff       	jmp    80105e8a <alltraps>

80106b43 <vector150>:
.globl vector150
vector150:
  pushl $0
80106b43:	6a 00                	push   $0x0
  pushl $150
80106b45:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106b4a:	e9 3b f3 ff ff       	jmp    80105e8a <alltraps>

80106b4f <vector151>:
.globl vector151
vector151:
  pushl $0
80106b4f:	6a 00                	push   $0x0
  pushl $151
80106b51:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106b56:	e9 2f f3 ff ff       	jmp    80105e8a <alltraps>

80106b5b <vector152>:
.globl vector152
vector152:
  pushl $0
80106b5b:	6a 00                	push   $0x0
  pushl $152
80106b5d:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106b62:	e9 23 f3 ff ff       	jmp    80105e8a <alltraps>

80106b67 <vector153>:
.globl vector153
vector153:
  pushl $0
80106b67:	6a 00                	push   $0x0
  pushl $153
80106b69:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106b6e:	e9 17 f3 ff ff       	jmp    80105e8a <alltraps>

80106b73 <vector154>:
.globl vector154
vector154:
  pushl $0
80106b73:	6a 00                	push   $0x0
  pushl $154
80106b75:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106b7a:	e9 0b f3 ff ff       	jmp    80105e8a <alltraps>

80106b7f <vector155>:
.globl vector155
vector155:
  pushl $0
80106b7f:	6a 00                	push   $0x0
  pushl $155
80106b81:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106b86:	e9 ff f2 ff ff       	jmp    80105e8a <alltraps>

80106b8b <vector156>:
.globl vector156
vector156:
  pushl $0
80106b8b:	6a 00                	push   $0x0
  pushl $156
80106b8d:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106b92:	e9 f3 f2 ff ff       	jmp    80105e8a <alltraps>

80106b97 <vector157>:
.globl vector157
vector157:
  pushl $0
80106b97:	6a 00                	push   $0x0
  pushl $157
80106b99:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106b9e:	e9 e7 f2 ff ff       	jmp    80105e8a <alltraps>

80106ba3 <vector158>:
.globl vector158
vector158:
  pushl $0
80106ba3:	6a 00                	push   $0x0
  pushl $158
80106ba5:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106baa:	e9 db f2 ff ff       	jmp    80105e8a <alltraps>

80106baf <vector159>:
.globl vector159
vector159:
  pushl $0
80106baf:	6a 00                	push   $0x0
  pushl $159
80106bb1:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106bb6:	e9 cf f2 ff ff       	jmp    80105e8a <alltraps>

80106bbb <vector160>:
.globl vector160
vector160:
  pushl $0
80106bbb:	6a 00                	push   $0x0
  pushl $160
80106bbd:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106bc2:	e9 c3 f2 ff ff       	jmp    80105e8a <alltraps>

80106bc7 <vector161>:
.globl vector161
vector161:
  pushl $0
80106bc7:	6a 00                	push   $0x0
  pushl $161
80106bc9:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106bce:	e9 b7 f2 ff ff       	jmp    80105e8a <alltraps>

80106bd3 <vector162>:
.globl vector162
vector162:
  pushl $0
80106bd3:	6a 00                	push   $0x0
  pushl $162
80106bd5:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106bda:	e9 ab f2 ff ff       	jmp    80105e8a <alltraps>

80106bdf <vector163>:
.globl vector163
vector163:
  pushl $0
80106bdf:	6a 00                	push   $0x0
  pushl $163
80106be1:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106be6:	e9 9f f2 ff ff       	jmp    80105e8a <alltraps>

80106beb <vector164>:
.globl vector164
vector164:
  pushl $0
80106beb:	6a 00                	push   $0x0
  pushl $164
80106bed:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106bf2:	e9 93 f2 ff ff       	jmp    80105e8a <alltraps>

80106bf7 <vector165>:
.globl vector165
vector165:
  pushl $0
80106bf7:	6a 00                	push   $0x0
  pushl $165
80106bf9:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106bfe:	e9 87 f2 ff ff       	jmp    80105e8a <alltraps>

80106c03 <vector166>:
.globl vector166
vector166:
  pushl $0
80106c03:	6a 00                	push   $0x0
  pushl $166
80106c05:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106c0a:	e9 7b f2 ff ff       	jmp    80105e8a <alltraps>

80106c0f <vector167>:
.globl vector167
vector167:
  pushl $0
80106c0f:	6a 00                	push   $0x0
  pushl $167
80106c11:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106c16:	e9 6f f2 ff ff       	jmp    80105e8a <alltraps>

80106c1b <vector168>:
.globl vector168
vector168:
  pushl $0
80106c1b:	6a 00                	push   $0x0
  pushl $168
80106c1d:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106c22:	e9 63 f2 ff ff       	jmp    80105e8a <alltraps>

80106c27 <vector169>:
.globl vector169
vector169:
  pushl $0
80106c27:	6a 00                	push   $0x0
  pushl $169
80106c29:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106c2e:	e9 57 f2 ff ff       	jmp    80105e8a <alltraps>

80106c33 <vector170>:
.globl vector170
vector170:
  pushl $0
80106c33:	6a 00                	push   $0x0
  pushl $170
80106c35:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106c3a:	e9 4b f2 ff ff       	jmp    80105e8a <alltraps>

80106c3f <vector171>:
.globl vector171
vector171:
  pushl $0
80106c3f:	6a 00                	push   $0x0
  pushl $171
80106c41:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106c46:	e9 3f f2 ff ff       	jmp    80105e8a <alltraps>

80106c4b <vector172>:
.globl vector172
vector172:
  pushl $0
80106c4b:	6a 00                	push   $0x0
  pushl $172
80106c4d:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106c52:	e9 33 f2 ff ff       	jmp    80105e8a <alltraps>

80106c57 <vector173>:
.globl vector173
vector173:
  pushl $0
80106c57:	6a 00                	push   $0x0
  pushl $173
80106c59:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106c5e:	e9 27 f2 ff ff       	jmp    80105e8a <alltraps>

80106c63 <vector174>:
.globl vector174
vector174:
  pushl $0
80106c63:	6a 00                	push   $0x0
  pushl $174
80106c65:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106c6a:	e9 1b f2 ff ff       	jmp    80105e8a <alltraps>

80106c6f <vector175>:
.globl vector175
vector175:
  pushl $0
80106c6f:	6a 00                	push   $0x0
  pushl $175
80106c71:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106c76:	e9 0f f2 ff ff       	jmp    80105e8a <alltraps>

80106c7b <vector176>:
.globl vector176
vector176:
  pushl $0
80106c7b:	6a 00                	push   $0x0
  pushl $176
80106c7d:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106c82:	e9 03 f2 ff ff       	jmp    80105e8a <alltraps>

80106c87 <vector177>:
.globl vector177
vector177:
  pushl $0
80106c87:	6a 00                	push   $0x0
  pushl $177
80106c89:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106c8e:	e9 f7 f1 ff ff       	jmp    80105e8a <alltraps>

80106c93 <vector178>:
.globl vector178
vector178:
  pushl $0
80106c93:	6a 00                	push   $0x0
  pushl $178
80106c95:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106c9a:	e9 eb f1 ff ff       	jmp    80105e8a <alltraps>

80106c9f <vector179>:
.globl vector179
vector179:
  pushl $0
80106c9f:	6a 00                	push   $0x0
  pushl $179
80106ca1:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106ca6:	e9 df f1 ff ff       	jmp    80105e8a <alltraps>

80106cab <vector180>:
.globl vector180
vector180:
  pushl $0
80106cab:	6a 00                	push   $0x0
  pushl $180
80106cad:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106cb2:	e9 d3 f1 ff ff       	jmp    80105e8a <alltraps>

80106cb7 <vector181>:
.globl vector181
vector181:
  pushl $0
80106cb7:	6a 00                	push   $0x0
  pushl $181
80106cb9:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106cbe:	e9 c7 f1 ff ff       	jmp    80105e8a <alltraps>

80106cc3 <vector182>:
.globl vector182
vector182:
  pushl $0
80106cc3:	6a 00                	push   $0x0
  pushl $182
80106cc5:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106cca:	e9 bb f1 ff ff       	jmp    80105e8a <alltraps>

80106ccf <vector183>:
.globl vector183
vector183:
  pushl $0
80106ccf:	6a 00                	push   $0x0
  pushl $183
80106cd1:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106cd6:	e9 af f1 ff ff       	jmp    80105e8a <alltraps>

80106cdb <vector184>:
.globl vector184
vector184:
  pushl $0
80106cdb:	6a 00                	push   $0x0
  pushl $184
80106cdd:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106ce2:	e9 a3 f1 ff ff       	jmp    80105e8a <alltraps>

80106ce7 <vector185>:
.globl vector185
vector185:
  pushl $0
80106ce7:	6a 00                	push   $0x0
  pushl $185
80106ce9:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106cee:	e9 97 f1 ff ff       	jmp    80105e8a <alltraps>

80106cf3 <vector186>:
.globl vector186
vector186:
  pushl $0
80106cf3:	6a 00                	push   $0x0
  pushl $186
80106cf5:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106cfa:	e9 8b f1 ff ff       	jmp    80105e8a <alltraps>

80106cff <vector187>:
.globl vector187
vector187:
  pushl $0
80106cff:	6a 00                	push   $0x0
  pushl $187
80106d01:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106d06:	e9 7f f1 ff ff       	jmp    80105e8a <alltraps>

80106d0b <vector188>:
.globl vector188
vector188:
  pushl $0
80106d0b:	6a 00                	push   $0x0
  pushl $188
80106d0d:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106d12:	e9 73 f1 ff ff       	jmp    80105e8a <alltraps>

80106d17 <vector189>:
.globl vector189
vector189:
  pushl $0
80106d17:	6a 00                	push   $0x0
  pushl $189
80106d19:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106d1e:	e9 67 f1 ff ff       	jmp    80105e8a <alltraps>

80106d23 <vector190>:
.globl vector190
vector190:
  pushl $0
80106d23:	6a 00                	push   $0x0
  pushl $190
80106d25:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106d2a:	e9 5b f1 ff ff       	jmp    80105e8a <alltraps>

80106d2f <vector191>:
.globl vector191
vector191:
  pushl $0
80106d2f:	6a 00                	push   $0x0
  pushl $191
80106d31:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106d36:	e9 4f f1 ff ff       	jmp    80105e8a <alltraps>

80106d3b <vector192>:
.globl vector192
vector192:
  pushl $0
80106d3b:	6a 00                	push   $0x0
  pushl $192
80106d3d:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106d42:	e9 43 f1 ff ff       	jmp    80105e8a <alltraps>

80106d47 <vector193>:
.globl vector193
vector193:
  pushl $0
80106d47:	6a 00                	push   $0x0
  pushl $193
80106d49:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106d4e:	e9 37 f1 ff ff       	jmp    80105e8a <alltraps>

80106d53 <vector194>:
.globl vector194
vector194:
  pushl $0
80106d53:	6a 00                	push   $0x0
  pushl $194
80106d55:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106d5a:	e9 2b f1 ff ff       	jmp    80105e8a <alltraps>

80106d5f <vector195>:
.globl vector195
vector195:
  pushl $0
80106d5f:	6a 00                	push   $0x0
  pushl $195
80106d61:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106d66:	e9 1f f1 ff ff       	jmp    80105e8a <alltraps>

80106d6b <vector196>:
.globl vector196
vector196:
  pushl $0
80106d6b:	6a 00                	push   $0x0
  pushl $196
80106d6d:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106d72:	e9 13 f1 ff ff       	jmp    80105e8a <alltraps>

80106d77 <vector197>:
.globl vector197
vector197:
  pushl $0
80106d77:	6a 00                	push   $0x0
  pushl $197
80106d79:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106d7e:	e9 07 f1 ff ff       	jmp    80105e8a <alltraps>

80106d83 <vector198>:
.globl vector198
vector198:
  pushl $0
80106d83:	6a 00                	push   $0x0
  pushl $198
80106d85:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106d8a:	e9 fb f0 ff ff       	jmp    80105e8a <alltraps>

80106d8f <vector199>:
.globl vector199
vector199:
  pushl $0
80106d8f:	6a 00                	push   $0x0
  pushl $199
80106d91:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106d96:	e9 ef f0 ff ff       	jmp    80105e8a <alltraps>

80106d9b <vector200>:
.globl vector200
vector200:
  pushl $0
80106d9b:	6a 00                	push   $0x0
  pushl $200
80106d9d:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106da2:	e9 e3 f0 ff ff       	jmp    80105e8a <alltraps>

80106da7 <vector201>:
.globl vector201
vector201:
  pushl $0
80106da7:	6a 00                	push   $0x0
  pushl $201
80106da9:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106dae:	e9 d7 f0 ff ff       	jmp    80105e8a <alltraps>

80106db3 <vector202>:
.globl vector202
vector202:
  pushl $0
80106db3:	6a 00                	push   $0x0
  pushl $202
80106db5:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106dba:	e9 cb f0 ff ff       	jmp    80105e8a <alltraps>

80106dbf <vector203>:
.globl vector203
vector203:
  pushl $0
80106dbf:	6a 00                	push   $0x0
  pushl $203
80106dc1:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106dc6:	e9 bf f0 ff ff       	jmp    80105e8a <alltraps>

80106dcb <vector204>:
.globl vector204
vector204:
  pushl $0
80106dcb:	6a 00                	push   $0x0
  pushl $204
80106dcd:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106dd2:	e9 b3 f0 ff ff       	jmp    80105e8a <alltraps>

80106dd7 <vector205>:
.globl vector205
vector205:
  pushl $0
80106dd7:	6a 00                	push   $0x0
  pushl $205
80106dd9:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106dde:	e9 a7 f0 ff ff       	jmp    80105e8a <alltraps>

80106de3 <vector206>:
.globl vector206
vector206:
  pushl $0
80106de3:	6a 00                	push   $0x0
  pushl $206
80106de5:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106dea:	e9 9b f0 ff ff       	jmp    80105e8a <alltraps>

80106def <vector207>:
.globl vector207
vector207:
  pushl $0
80106def:	6a 00                	push   $0x0
  pushl $207
80106df1:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106df6:	e9 8f f0 ff ff       	jmp    80105e8a <alltraps>

80106dfb <vector208>:
.globl vector208
vector208:
  pushl $0
80106dfb:	6a 00                	push   $0x0
  pushl $208
80106dfd:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106e02:	e9 83 f0 ff ff       	jmp    80105e8a <alltraps>

80106e07 <vector209>:
.globl vector209
vector209:
  pushl $0
80106e07:	6a 00                	push   $0x0
  pushl $209
80106e09:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106e0e:	e9 77 f0 ff ff       	jmp    80105e8a <alltraps>

80106e13 <vector210>:
.globl vector210
vector210:
  pushl $0
80106e13:	6a 00                	push   $0x0
  pushl $210
80106e15:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106e1a:	e9 6b f0 ff ff       	jmp    80105e8a <alltraps>

80106e1f <vector211>:
.globl vector211
vector211:
  pushl $0
80106e1f:	6a 00                	push   $0x0
  pushl $211
80106e21:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106e26:	e9 5f f0 ff ff       	jmp    80105e8a <alltraps>

80106e2b <vector212>:
.globl vector212
vector212:
  pushl $0
80106e2b:	6a 00                	push   $0x0
  pushl $212
80106e2d:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106e32:	e9 53 f0 ff ff       	jmp    80105e8a <alltraps>

80106e37 <vector213>:
.globl vector213
vector213:
  pushl $0
80106e37:	6a 00                	push   $0x0
  pushl $213
80106e39:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80106e3e:	e9 47 f0 ff ff       	jmp    80105e8a <alltraps>

80106e43 <vector214>:
.globl vector214
vector214:
  pushl $0
80106e43:	6a 00                	push   $0x0
  pushl $214
80106e45:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106e4a:	e9 3b f0 ff ff       	jmp    80105e8a <alltraps>

80106e4f <vector215>:
.globl vector215
vector215:
  pushl $0
80106e4f:	6a 00                	push   $0x0
  pushl $215
80106e51:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106e56:	e9 2f f0 ff ff       	jmp    80105e8a <alltraps>

80106e5b <vector216>:
.globl vector216
vector216:
  pushl $0
80106e5b:	6a 00                	push   $0x0
  pushl $216
80106e5d:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106e62:	e9 23 f0 ff ff       	jmp    80105e8a <alltraps>

80106e67 <vector217>:
.globl vector217
vector217:
  pushl $0
80106e67:	6a 00                	push   $0x0
  pushl $217
80106e69:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80106e6e:	e9 17 f0 ff ff       	jmp    80105e8a <alltraps>

80106e73 <vector218>:
.globl vector218
vector218:
  pushl $0
80106e73:	6a 00                	push   $0x0
  pushl $218
80106e75:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106e7a:	e9 0b f0 ff ff       	jmp    80105e8a <alltraps>

80106e7f <vector219>:
.globl vector219
vector219:
  pushl $0
80106e7f:	6a 00                	push   $0x0
  pushl $219
80106e81:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106e86:	e9 ff ef ff ff       	jmp    80105e8a <alltraps>

80106e8b <vector220>:
.globl vector220
vector220:
  pushl $0
80106e8b:	6a 00                	push   $0x0
  pushl $220
80106e8d:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80106e92:	e9 f3 ef ff ff       	jmp    80105e8a <alltraps>

80106e97 <vector221>:
.globl vector221
vector221:
  pushl $0
80106e97:	6a 00                	push   $0x0
  pushl $221
80106e99:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80106e9e:	e9 e7 ef ff ff       	jmp    80105e8a <alltraps>

80106ea3 <vector222>:
.globl vector222
vector222:
  pushl $0
80106ea3:	6a 00                	push   $0x0
  pushl $222
80106ea5:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106eaa:	e9 db ef ff ff       	jmp    80105e8a <alltraps>

80106eaf <vector223>:
.globl vector223
vector223:
  pushl $0
80106eaf:	6a 00                	push   $0x0
  pushl $223
80106eb1:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106eb6:	e9 cf ef ff ff       	jmp    80105e8a <alltraps>

80106ebb <vector224>:
.globl vector224
vector224:
  pushl $0
80106ebb:	6a 00                	push   $0x0
  pushl $224
80106ebd:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80106ec2:	e9 c3 ef ff ff       	jmp    80105e8a <alltraps>

80106ec7 <vector225>:
.globl vector225
vector225:
  pushl $0
80106ec7:	6a 00                	push   $0x0
  pushl $225
80106ec9:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80106ece:	e9 b7 ef ff ff       	jmp    80105e8a <alltraps>

80106ed3 <vector226>:
.globl vector226
vector226:
  pushl $0
80106ed3:	6a 00                	push   $0x0
  pushl $226
80106ed5:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106eda:	e9 ab ef ff ff       	jmp    80105e8a <alltraps>

80106edf <vector227>:
.globl vector227
vector227:
  pushl $0
80106edf:	6a 00                	push   $0x0
  pushl $227
80106ee1:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80106ee6:	e9 9f ef ff ff       	jmp    80105e8a <alltraps>

80106eeb <vector228>:
.globl vector228
vector228:
  pushl $0
80106eeb:	6a 00                	push   $0x0
  pushl $228
80106eed:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80106ef2:	e9 93 ef ff ff       	jmp    80105e8a <alltraps>

80106ef7 <vector229>:
.globl vector229
vector229:
  pushl $0
80106ef7:	6a 00                	push   $0x0
  pushl $229
80106ef9:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80106efe:	e9 87 ef ff ff       	jmp    80105e8a <alltraps>

80106f03 <vector230>:
.globl vector230
vector230:
  pushl $0
80106f03:	6a 00                	push   $0x0
  pushl $230
80106f05:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80106f0a:	e9 7b ef ff ff       	jmp    80105e8a <alltraps>

80106f0f <vector231>:
.globl vector231
vector231:
  pushl $0
80106f0f:	6a 00                	push   $0x0
  pushl $231
80106f11:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106f16:	e9 6f ef ff ff       	jmp    80105e8a <alltraps>

80106f1b <vector232>:
.globl vector232
vector232:
  pushl $0
80106f1b:	6a 00                	push   $0x0
  pushl $232
80106f1d:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80106f22:	e9 63 ef ff ff       	jmp    80105e8a <alltraps>

80106f27 <vector233>:
.globl vector233
vector233:
  pushl $0
80106f27:	6a 00                	push   $0x0
  pushl $233
80106f29:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80106f2e:	e9 57 ef ff ff       	jmp    80105e8a <alltraps>

80106f33 <vector234>:
.globl vector234
vector234:
  pushl $0
80106f33:	6a 00                	push   $0x0
  pushl $234
80106f35:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80106f3a:	e9 4b ef ff ff       	jmp    80105e8a <alltraps>

80106f3f <vector235>:
.globl vector235
vector235:
  pushl $0
80106f3f:	6a 00                	push   $0x0
  pushl $235
80106f41:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106f46:	e9 3f ef ff ff       	jmp    80105e8a <alltraps>

80106f4b <vector236>:
.globl vector236
vector236:
  pushl $0
80106f4b:	6a 00                	push   $0x0
  pushl $236
80106f4d:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80106f52:	e9 33 ef ff ff       	jmp    80105e8a <alltraps>

80106f57 <vector237>:
.globl vector237
vector237:
  pushl $0
80106f57:	6a 00                	push   $0x0
  pushl $237
80106f59:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80106f5e:	e9 27 ef ff ff       	jmp    80105e8a <alltraps>

80106f63 <vector238>:
.globl vector238
vector238:
  pushl $0
80106f63:	6a 00                	push   $0x0
  pushl $238
80106f65:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80106f6a:	e9 1b ef ff ff       	jmp    80105e8a <alltraps>

80106f6f <vector239>:
.globl vector239
vector239:
  pushl $0
80106f6f:	6a 00                	push   $0x0
  pushl $239
80106f71:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80106f76:	e9 0f ef ff ff       	jmp    80105e8a <alltraps>

80106f7b <vector240>:
.globl vector240
vector240:
  pushl $0
80106f7b:	6a 00                	push   $0x0
  pushl $240
80106f7d:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80106f82:	e9 03 ef ff ff       	jmp    80105e8a <alltraps>

80106f87 <vector241>:
.globl vector241
vector241:
  pushl $0
80106f87:	6a 00                	push   $0x0
  pushl $241
80106f89:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80106f8e:	e9 f7 ee ff ff       	jmp    80105e8a <alltraps>

80106f93 <vector242>:
.globl vector242
vector242:
  pushl $0
80106f93:	6a 00                	push   $0x0
  pushl $242
80106f95:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80106f9a:	e9 eb ee ff ff       	jmp    80105e8a <alltraps>

80106f9f <vector243>:
.globl vector243
vector243:
  pushl $0
80106f9f:	6a 00                	push   $0x0
  pushl $243
80106fa1:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80106fa6:	e9 df ee ff ff       	jmp    80105e8a <alltraps>

80106fab <vector244>:
.globl vector244
vector244:
  pushl $0
80106fab:	6a 00                	push   $0x0
  pushl $244
80106fad:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80106fb2:	e9 d3 ee ff ff       	jmp    80105e8a <alltraps>

80106fb7 <vector245>:
.globl vector245
vector245:
  pushl $0
80106fb7:	6a 00                	push   $0x0
  pushl $245
80106fb9:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80106fbe:	e9 c7 ee ff ff       	jmp    80105e8a <alltraps>

80106fc3 <vector246>:
.globl vector246
vector246:
  pushl $0
80106fc3:	6a 00                	push   $0x0
  pushl $246
80106fc5:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80106fca:	e9 bb ee ff ff       	jmp    80105e8a <alltraps>

80106fcf <vector247>:
.globl vector247
vector247:
  pushl $0
80106fcf:	6a 00                	push   $0x0
  pushl $247
80106fd1:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80106fd6:	e9 af ee ff ff       	jmp    80105e8a <alltraps>

80106fdb <vector248>:
.globl vector248
vector248:
  pushl $0
80106fdb:	6a 00                	push   $0x0
  pushl $248
80106fdd:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80106fe2:	e9 a3 ee ff ff       	jmp    80105e8a <alltraps>

80106fe7 <vector249>:
.globl vector249
vector249:
  pushl $0
80106fe7:	6a 00                	push   $0x0
  pushl $249
80106fe9:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80106fee:	e9 97 ee ff ff       	jmp    80105e8a <alltraps>

80106ff3 <vector250>:
.globl vector250
vector250:
  pushl $0
80106ff3:	6a 00                	push   $0x0
  pushl $250
80106ff5:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80106ffa:	e9 8b ee ff ff       	jmp    80105e8a <alltraps>

80106fff <vector251>:
.globl vector251
vector251:
  pushl $0
80106fff:	6a 00                	push   $0x0
  pushl $251
80107001:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107006:	e9 7f ee ff ff       	jmp    80105e8a <alltraps>

8010700b <vector252>:
.globl vector252
vector252:
  pushl $0
8010700b:	6a 00                	push   $0x0
  pushl $252
8010700d:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107012:	e9 73 ee ff ff       	jmp    80105e8a <alltraps>

80107017 <vector253>:
.globl vector253
vector253:
  pushl $0
80107017:	6a 00                	push   $0x0
  pushl $253
80107019:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010701e:	e9 67 ee ff ff       	jmp    80105e8a <alltraps>

80107023 <vector254>:
.globl vector254
vector254:
  pushl $0
80107023:	6a 00                	push   $0x0
  pushl $254
80107025:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010702a:	e9 5b ee ff ff       	jmp    80105e8a <alltraps>

8010702f <vector255>:
.globl vector255
vector255:
  pushl $0
8010702f:	6a 00                	push   $0x0
  pushl $255
80107031:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107036:	e9 4f ee ff ff       	jmp    80105e8a <alltraps>

8010703b <lgdt>:
{
8010703b:	55                   	push   %ebp
8010703c:	89 e5                	mov    %esp,%ebp
8010703e:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107041:	8b 45 0c             	mov    0xc(%ebp),%eax
80107044:	83 e8 01             	sub    $0x1,%eax
80107047:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010704b:	8b 45 08             	mov    0x8(%ebp),%eax
8010704e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107052:	8b 45 08             	mov    0x8(%ebp),%eax
80107055:	c1 e8 10             	shr    $0x10,%eax
80107058:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
8010705c:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010705f:	0f 01 10             	lgdtl  (%eax)
}
80107062:	90                   	nop
80107063:	c9                   	leave  
80107064:	c3                   	ret    

80107065 <ltr>:
{
80107065:	55                   	push   %ebp
80107066:	89 e5                	mov    %esp,%ebp
80107068:	83 ec 04             	sub    $0x4,%esp
8010706b:	8b 45 08             	mov    0x8(%ebp),%eax
8010706e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107072:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107076:	0f 00 d8             	ltr    %ax
}
80107079:	90                   	nop
8010707a:	c9                   	leave  
8010707b:	c3                   	ret    

8010707c <lcr3>:
{
8010707c:	55                   	push   %ebp
8010707d:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010707f:	8b 45 08             	mov    0x8(%ebp),%eax
80107082:	0f 22 d8             	mov    %eax,%cr3
}
80107085:	90                   	nop
80107086:	5d                   	pop    %ebp
80107087:	c3                   	ret    

80107088 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107088:	55                   	push   %ebp
80107089:	89 e5                	mov    %esp,%ebp
8010708b:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
8010708e:	e8 03 c9 ff ff       	call   80103996 <cpuid>
80107093:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107099:	05 80 6a 19 80       	add    $0x80196a80,%eax
8010709e:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801070a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070a4:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801070aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070ad:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801070b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070b6:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801070ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070bd:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801070c1:	83 e2 f0             	and    $0xfffffff0,%edx
801070c4:	83 ca 0a             	or     $0xa,%edx
801070c7:	88 50 7d             	mov    %dl,0x7d(%eax)
801070ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070cd:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801070d1:	83 ca 10             	or     $0x10,%edx
801070d4:	88 50 7d             	mov    %dl,0x7d(%eax)
801070d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070da:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801070de:	83 e2 9f             	and    $0xffffff9f,%edx
801070e1:	88 50 7d             	mov    %dl,0x7d(%eax)
801070e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070e7:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801070eb:	83 ca 80             	or     $0xffffff80,%edx
801070ee:	88 50 7d             	mov    %dl,0x7d(%eax)
801070f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070f4:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801070f8:	83 ca 0f             	or     $0xf,%edx
801070fb:	88 50 7e             	mov    %dl,0x7e(%eax)
801070fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107101:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107105:	83 e2 ef             	and    $0xffffffef,%edx
80107108:	88 50 7e             	mov    %dl,0x7e(%eax)
8010710b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010710e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107112:	83 e2 df             	and    $0xffffffdf,%edx
80107115:	88 50 7e             	mov    %dl,0x7e(%eax)
80107118:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010711b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010711f:	83 ca 40             	or     $0x40,%edx
80107122:	88 50 7e             	mov    %dl,0x7e(%eax)
80107125:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107128:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010712c:	83 ca 80             	or     $0xffffff80,%edx
8010712f:	88 50 7e             	mov    %dl,0x7e(%eax)
80107132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107135:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107139:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010713c:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107143:	ff ff 
80107145:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107148:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010714f:	00 00 
80107151:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107154:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010715b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010715e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107165:	83 e2 f0             	and    $0xfffffff0,%edx
80107168:	83 ca 02             	or     $0x2,%edx
8010716b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107171:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107174:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010717b:	83 ca 10             	or     $0x10,%edx
8010717e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107184:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107187:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010718e:	83 e2 9f             	and    $0xffffff9f,%edx
80107191:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107197:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010719a:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801071a1:	83 ca 80             	or     $0xffffff80,%edx
801071a4:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801071aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071ad:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801071b4:	83 ca 0f             	or     $0xf,%edx
801071b7:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801071bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071c0:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801071c7:	83 e2 ef             	and    $0xffffffef,%edx
801071ca:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801071d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071d3:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801071da:	83 e2 df             	and    $0xffffffdf,%edx
801071dd:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801071e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071e6:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801071ed:	83 ca 40             	or     $0x40,%edx
801071f0:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801071f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071f9:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107200:	83 ca 80             	or     $0xffffff80,%edx
80107203:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107209:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010720c:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107213:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107216:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
8010721d:	ff ff 
8010721f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107222:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107229:	00 00 
8010722b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010722e:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107235:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107238:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010723f:	83 e2 f0             	and    $0xfffffff0,%edx
80107242:	83 ca 0a             	or     $0xa,%edx
80107245:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010724b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010724e:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107255:	83 ca 10             	or     $0x10,%edx
80107258:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010725e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107261:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107268:	83 ca 60             	or     $0x60,%edx
8010726b:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107271:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107274:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010727b:	83 ca 80             	or     $0xffffff80,%edx
8010727e:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107284:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107287:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010728e:	83 ca 0f             	or     $0xf,%edx
80107291:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107297:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010729a:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801072a1:	83 e2 ef             	and    $0xffffffef,%edx
801072a4:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801072aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072ad:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801072b4:	83 e2 df             	and    $0xffffffdf,%edx
801072b7:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801072bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072c0:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801072c7:	83 ca 40             	or     $0x40,%edx
801072ca:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801072d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072d3:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801072da:	83 ca 80             	or     $0xffffff80,%edx
801072dd:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801072e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072e6:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801072ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072f0:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801072f7:	ff ff 
801072f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072fc:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107303:	00 00 
80107305:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107308:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010730f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107312:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107319:	83 e2 f0             	and    $0xfffffff0,%edx
8010731c:	83 ca 02             	or     $0x2,%edx
8010731f:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107325:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107328:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010732f:	83 ca 10             	or     $0x10,%edx
80107332:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107338:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010733b:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107342:	83 ca 60             	or     $0x60,%edx
80107345:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010734b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010734e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107355:	83 ca 80             	or     $0xffffff80,%edx
80107358:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010735e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107361:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107368:	83 ca 0f             	or     $0xf,%edx
8010736b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107371:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107374:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010737b:	83 e2 ef             	and    $0xffffffef,%edx
8010737e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107384:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107387:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010738e:	83 e2 df             	and    $0xffffffdf,%edx
80107391:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107397:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010739a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801073a1:	83 ca 40             	or     $0x40,%edx
801073a4:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801073aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073ad:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801073b4:	83 ca 80             	or     $0xffffff80,%edx
801073b7:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801073bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073c0:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801073c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073ca:	83 c0 70             	add    $0x70,%eax
801073cd:	83 ec 08             	sub    $0x8,%esp
801073d0:	6a 30                	push   $0x30
801073d2:	50                   	push   %eax
801073d3:	e8 63 fc ff ff       	call   8010703b <lgdt>
801073d8:	83 c4 10             	add    $0x10,%esp
}
801073db:	90                   	nop
801073dc:	c9                   	leave  
801073dd:	c3                   	ret    

801073de <walkpgdir>:

// that corresponds to virtual address va.  If alloc!=0,
// create any required page tables pages.
pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801073de:	55                   	push   %ebp
801073df:	89 e5                	mov    %esp,%ebp
801073e1:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801073e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801073e7:	c1 e8 16             	shr    $0x16,%eax
801073ea:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801073f1:	8b 45 08             	mov    0x8(%ebp),%eax
801073f4:	01 d0                	add    %edx,%eax
801073f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801073f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801073fc:	8b 00                	mov    (%eax),%eax
801073fe:	83 e0 01             	and    $0x1,%eax
80107401:	85 c0                	test   %eax,%eax
80107403:	74 14                	je     80107419 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107405:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107408:	8b 00                	mov    (%eax),%eax
8010740a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010740f:	05 00 00 00 80       	add    $0x80000000,%eax
80107414:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107417:	eb 42                	jmp    8010745b <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107419:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010741d:	74 0e                	je     8010742d <walkpgdir+0x4f>
8010741f:	e8 69 b3 ff ff       	call   8010278d <kalloc>
80107424:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107427:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010742b:	75 07                	jne    80107434 <walkpgdir+0x56>
      return 0;
8010742d:	b8 00 00 00 00       	mov    $0x0,%eax
80107432:	eb 3e                	jmp    80107472 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107434:	83 ec 04             	sub    $0x4,%esp
80107437:	68 00 10 00 00       	push   $0x1000
8010743c:	6a 00                	push   $0x0
8010743e:	ff 75 f4             	push   -0xc(%ebp)
80107441:	e8 cb d6 ff ff       	call   80104b11 <memset>
80107446:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107449:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010744c:	05 00 00 00 80       	add    $0x80000000,%eax
80107451:	83 c8 07             	or     $0x7,%eax
80107454:	89 c2                	mov    %eax,%edx
80107456:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107459:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
8010745b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010745e:	c1 e8 0c             	shr    $0xc,%eax
80107461:	25 ff 03 00 00       	and    $0x3ff,%eax
80107466:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010746d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107470:	01 d0                	add    %edx,%eax
}
80107472:	c9                   	leave  
80107473:	c3                   	ret    

80107474 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107474:	55                   	push   %ebp
80107475:	89 e5                	mov    %esp,%ebp
80107477:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
8010747a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010747d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107482:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107485:	8b 55 0c             	mov    0xc(%ebp),%edx
80107488:	8b 45 10             	mov    0x10(%ebp),%eax
8010748b:	01 d0                	add    %edx,%eax
8010748d:	83 e8 01             	sub    $0x1,%eax
80107490:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107495:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107498:	83 ec 04             	sub    $0x4,%esp
8010749b:	6a 01                	push   $0x1
8010749d:	ff 75 f4             	push   -0xc(%ebp)
801074a0:	ff 75 08             	push   0x8(%ebp)
801074a3:	e8 36 ff ff ff       	call   801073de <walkpgdir>
801074a8:	83 c4 10             	add    $0x10,%esp
801074ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
801074ae:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801074b2:	75 07                	jne    801074bb <mappages+0x47>
      return -1;
801074b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801074b9:	eb 47                	jmp    80107502 <mappages+0x8e>
    if(*pte & PTE_P)
801074bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801074be:	8b 00                	mov    (%eax),%eax
801074c0:	83 e0 01             	and    $0x1,%eax
801074c3:	85 c0                	test   %eax,%eax
801074c5:	74 0d                	je     801074d4 <mappages+0x60>
      panic("remap");
801074c7:	83 ec 0c             	sub    $0xc,%esp
801074ca:	68 78 a9 10 80       	push   $0x8010a978
801074cf:	e8 d5 90 ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
801074d4:	8b 45 18             	mov    0x18(%ebp),%eax
801074d7:	0b 45 14             	or     0x14(%ebp),%eax
801074da:	83 c8 01             	or     $0x1,%eax
801074dd:	89 c2                	mov    %eax,%edx
801074df:	8b 45 ec             	mov    -0x14(%ebp),%eax
801074e2:	89 10                	mov    %edx,(%eax)
    if(a == last)
801074e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074e7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801074ea:	74 10                	je     801074fc <mappages+0x88>
      break;
    a += PGSIZE;
801074ec:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801074f3:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801074fa:	eb 9c                	jmp    80107498 <mappages+0x24>
      break;
801074fc:	90                   	nop
  }
  return 0;
801074fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107502:	c9                   	leave  
80107503:	c3                   	ret    

80107504 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107504:	55                   	push   %ebp
80107505:	89 e5                	mov    %esp,%ebp
80107507:	53                   	push   %ebx
80107508:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
8010750b:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107512:	8b 15 50 6d 19 80    	mov    0x80196d50,%edx
80107518:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
8010751d:	29 d0                	sub    %edx,%eax
8010751f:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107522:	a1 48 6d 19 80       	mov    0x80196d48,%eax
80107527:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010752a:	8b 15 48 6d 19 80    	mov    0x80196d48,%edx
80107530:	a1 50 6d 19 80       	mov    0x80196d50,%eax
80107535:	01 d0                	add    %edx,%eax
80107537:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010753a:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107541:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107544:	83 c0 30             	add    $0x30,%eax
80107547:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010754a:	89 10                	mov    %edx,(%eax)
8010754c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010754f:	89 50 04             	mov    %edx,0x4(%eax)
80107552:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107555:	89 50 08             	mov    %edx,0x8(%eax)
80107558:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010755b:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
8010755e:	e8 2a b2 ff ff       	call   8010278d <kalloc>
80107563:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107566:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010756a:	75 07                	jne    80107573 <setupkvm+0x6f>
    return 0;
8010756c:	b8 00 00 00 00       	mov    $0x0,%eax
80107571:	eb 78                	jmp    801075eb <setupkvm+0xe7>
  }
  memset(pgdir, 0, PGSIZE);
80107573:	83 ec 04             	sub    $0x4,%esp
80107576:	68 00 10 00 00       	push   $0x1000
8010757b:	6a 00                	push   $0x0
8010757d:	ff 75 f0             	push   -0x10(%ebp)
80107580:	e8 8c d5 ff ff       	call   80104b11 <memset>
80107585:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107588:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
8010758f:	eb 4e                	jmp    801075df <setupkvm+0xdb>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107591:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107594:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107597:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010759a:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010759d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075a0:	8b 58 08             	mov    0x8(%eax),%ebx
801075a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075a6:	8b 40 04             	mov    0x4(%eax),%eax
801075a9:	29 c3                	sub    %eax,%ebx
801075ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ae:	8b 00                	mov    (%eax),%eax
801075b0:	83 ec 0c             	sub    $0xc,%esp
801075b3:	51                   	push   %ecx
801075b4:	52                   	push   %edx
801075b5:	53                   	push   %ebx
801075b6:	50                   	push   %eax
801075b7:	ff 75 f0             	push   -0x10(%ebp)
801075ba:	e8 b5 fe ff ff       	call   80107474 <mappages>
801075bf:	83 c4 20             	add    $0x20,%esp
801075c2:	85 c0                	test   %eax,%eax
801075c4:	79 15                	jns    801075db <setupkvm+0xd7>
      freevm(pgdir);
801075c6:	83 ec 0c             	sub    $0xc,%esp
801075c9:	ff 75 f0             	push   -0x10(%ebp)
801075cc:	e8 f5 04 00 00       	call   80107ac6 <freevm>
801075d1:	83 c4 10             	add    $0x10,%esp
      return 0;
801075d4:	b8 00 00 00 00       	mov    $0x0,%eax
801075d9:	eb 10                	jmp    801075eb <setupkvm+0xe7>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801075db:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801075df:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
801075e6:	72 a9                	jb     80107591 <setupkvm+0x8d>
    }
  return pgdir;
801075e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801075eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801075ee:	c9                   	leave  
801075ef:	c3                   	ret    

801075f0 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801075f0:	55                   	push   %ebp
801075f1:	89 e5                	mov    %esp,%ebp
801075f3:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801075f6:	e8 09 ff ff ff       	call   80107504 <setupkvm>
801075fb:	a3 7c 6a 19 80       	mov    %eax,0x80196a7c
  switchkvm();
80107600:	e8 03 00 00 00       	call   80107608 <switchkvm>
}
80107605:	90                   	nop
80107606:	c9                   	leave  
80107607:	c3                   	ret    

80107608 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107608:	55                   	push   %ebp
80107609:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
8010760b:	a1 7c 6a 19 80       	mov    0x80196a7c,%eax
80107610:	05 00 00 00 80       	add    $0x80000000,%eax
80107615:	50                   	push   %eax
80107616:	e8 61 fa ff ff       	call   8010707c <lcr3>
8010761b:	83 c4 04             	add    $0x4,%esp
}
8010761e:	90                   	nop
8010761f:	c9                   	leave  
80107620:	c3                   	ret    

80107621 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107621:	55                   	push   %ebp
80107622:	89 e5                	mov    %esp,%ebp
80107624:	56                   	push   %esi
80107625:	53                   	push   %ebx
80107626:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107629:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010762d:	75 0d                	jne    8010763c <switchuvm+0x1b>
    panic("switchuvm: no process");
8010762f:	83 ec 0c             	sub    $0xc,%esp
80107632:	68 7e a9 10 80       	push   $0x8010a97e
80107637:	e8 6d 8f ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
8010763c:	8b 45 08             	mov    0x8(%ebp),%eax
8010763f:	8b 40 08             	mov    0x8(%eax),%eax
80107642:	85 c0                	test   %eax,%eax
80107644:	75 0d                	jne    80107653 <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107646:	83 ec 0c             	sub    $0xc,%esp
80107649:	68 94 a9 10 80       	push   $0x8010a994
8010764e:	e8 56 8f ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
80107653:	8b 45 08             	mov    0x8(%ebp),%eax
80107656:	8b 40 04             	mov    0x4(%eax),%eax
80107659:	85 c0                	test   %eax,%eax
8010765b:	75 0d                	jne    8010766a <switchuvm+0x49>
    panic("switchuvm: no pgdir");
8010765d:	83 ec 0c             	sub    $0xc,%esp
80107660:	68 a9 a9 10 80       	push   $0x8010a9a9
80107665:	e8 3f 8f ff ff       	call   801005a9 <panic>

  pushcli();
8010766a:	e8 97 d3 ff ff       	call   80104a06 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
8010766f:	e8 3d c3 ff ff       	call   801039b1 <mycpu>
80107674:	89 c3                	mov    %eax,%ebx
80107676:	e8 36 c3 ff ff       	call   801039b1 <mycpu>
8010767b:	83 c0 08             	add    $0x8,%eax
8010767e:	89 c6                	mov    %eax,%esi
80107680:	e8 2c c3 ff ff       	call   801039b1 <mycpu>
80107685:	83 c0 08             	add    $0x8,%eax
80107688:	c1 e8 10             	shr    $0x10,%eax
8010768b:	88 45 f7             	mov    %al,-0x9(%ebp)
8010768e:	e8 1e c3 ff ff       	call   801039b1 <mycpu>
80107693:	83 c0 08             	add    $0x8,%eax
80107696:	c1 e8 18             	shr    $0x18,%eax
80107699:	89 c2                	mov    %eax,%edx
8010769b:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801076a2:	67 00 
801076a4:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
801076ab:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
801076af:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
801076b5:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801076bc:	83 e0 f0             	and    $0xfffffff0,%eax
801076bf:	83 c8 09             	or     $0x9,%eax
801076c2:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801076c8:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801076cf:	83 c8 10             	or     $0x10,%eax
801076d2:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801076d8:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801076df:	83 e0 9f             	and    $0xffffff9f,%eax
801076e2:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801076e8:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801076ef:	83 c8 80             	or     $0xffffff80,%eax
801076f2:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801076f8:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801076ff:	83 e0 f0             	and    $0xfffffff0,%eax
80107702:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107708:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010770f:	83 e0 ef             	and    $0xffffffef,%eax
80107712:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107718:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010771f:	83 e0 df             	and    $0xffffffdf,%eax
80107722:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107728:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010772f:	83 c8 40             	or     $0x40,%eax
80107732:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107738:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010773f:	83 e0 7f             	and    $0x7f,%eax
80107742:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107748:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
8010774e:	e8 5e c2 ff ff       	call   801039b1 <mycpu>
80107753:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010775a:	83 e2 ef             	and    $0xffffffef,%edx
8010775d:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107763:	e8 49 c2 ff ff       	call   801039b1 <mycpu>
80107768:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
8010776e:	8b 45 08             	mov    0x8(%ebp),%eax
80107771:	8b 40 08             	mov    0x8(%eax),%eax
80107774:	89 c3                	mov    %eax,%ebx
80107776:	e8 36 c2 ff ff       	call   801039b1 <mycpu>
8010777b:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107781:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107784:	e8 28 c2 ff ff       	call   801039b1 <mycpu>
80107789:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
8010778f:	83 ec 0c             	sub    $0xc,%esp
80107792:	6a 28                	push   $0x28
80107794:	e8 cc f8 ff ff       	call   80107065 <ltr>
80107799:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
8010779c:	8b 45 08             	mov    0x8(%ebp),%eax
8010779f:	8b 40 04             	mov    0x4(%eax),%eax
801077a2:	05 00 00 00 80       	add    $0x80000000,%eax
801077a7:	83 ec 0c             	sub    $0xc,%esp
801077aa:	50                   	push   %eax
801077ab:	e8 cc f8 ff ff       	call   8010707c <lcr3>
801077b0:	83 c4 10             	add    $0x10,%esp
  popcli();
801077b3:	e8 9b d2 ff ff       	call   80104a53 <popcli>
}
801077b8:	90                   	nop
801077b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
801077bc:	5b                   	pop    %ebx
801077bd:	5e                   	pop    %esi
801077be:	5d                   	pop    %ebp
801077bf:	c3                   	ret    

801077c0 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801077c0:	55                   	push   %ebp
801077c1:	89 e5                	mov    %esp,%ebp
801077c3:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
801077c6:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801077cd:	76 0d                	jbe    801077dc <inituvm+0x1c>
    panic("inituvm: more than a page");
801077cf:	83 ec 0c             	sub    $0xc,%esp
801077d2:	68 bd a9 10 80       	push   $0x8010a9bd
801077d7:	e8 cd 8d ff ff       	call   801005a9 <panic>
  mem = kalloc();
801077dc:	e8 ac af ff ff       	call   8010278d <kalloc>
801077e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801077e4:	83 ec 04             	sub    $0x4,%esp
801077e7:	68 00 10 00 00       	push   $0x1000
801077ec:	6a 00                	push   $0x0
801077ee:	ff 75 f4             	push   -0xc(%ebp)
801077f1:	e8 1b d3 ff ff       	call   80104b11 <memset>
801077f6:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801077f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077fc:	05 00 00 00 80       	add    $0x80000000,%eax
80107801:	83 ec 0c             	sub    $0xc,%esp
80107804:	6a 06                	push   $0x6
80107806:	50                   	push   %eax
80107807:	68 00 10 00 00       	push   $0x1000
8010780c:	6a 00                	push   $0x0
8010780e:	ff 75 08             	push   0x8(%ebp)
80107811:	e8 5e fc ff ff       	call   80107474 <mappages>
80107816:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107819:	83 ec 04             	sub    $0x4,%esp
8010781c:	ff 75 10             	push   0x10(%ebp)
8010781f:	ff 75 0c             	push   0xc(%ebp)
80107822:	ff 75 f4             	push   -0xc(%ebp)
80107825:	e8 a6 d3 ff ff       	call   80104bd0 <memmove>
8010782a:	83 c4 10             	add    $0x10,%esp
}
8010782d:	90                   	nop
8010782e:	c9                   	leave  
8010782f:	c3                   	ret    

80107830 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107830:	55                   	push   %ebp
80107831:	89 e5                	mov    %esp,%ebp
80107833:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107836:	8b 45 0c             	mov    0xc(%ebp),%eax
80107839:	25 ff 0f 00 00       	and    $0xfff,%eax
8010783e:	85 c0                	test   %eax,%eax
80107840:	74 0d                	je     8010784f <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107842:	83 ec 0c             	sub    $0xc,%esp
80107845:	68 d8 a9 10 80       	push   $0x8010a9d8
8010784a:	e8 5a 8d ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010784f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107856:	e9 8f 00 00 00       	jmp    801078ea <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
8010785b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010785e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107861:	01 d0                	add    %edx,%eax
80107863:	83 ec 04             	sub    $0x4,%esp
80107866:	6a 00                	push   $0x0
80107868:	50                   	push   %eax
80107869:	ff 75 08             	push   0x8(%ebp)
8010786c:	e8 6d fb ff ff       	call   801073de <walkpgdir>
80107871:	83 c4 10             	add    $0x10,%esp
80107874:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107877:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010787b:	75 0d                	jne    8010788a <loaduvm+0x5a>
      panic("loaduvm: address should exist");
8010787d:	83 ec 0c             	sub    $0xc,%esp
80107880:	68 fb a9 10 80       	push   $0x8010a9fb
80107885:	e8 1f 8d ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
8010788a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010788d:	8b 00                	mov    (%eax),%eax
8010788f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107894:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107897:	8b 45 18             	mov    0x18(%ebp),%eax
8010789a:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010789d:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801078a2:	77 0b                	ja     801078af <loaduvm+0x7f>
      n = sz - i;
801078a4:	8b 45 18             	mov    0x18(%ebp),%eax
801078a7:	2b 45 f4             	sub    -0xc(%ebp),%eax
801078aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
801078ad:	eb 07                	jmp    801078b6 <loaduvm+0x86>
    else
      n = PGSIZE;
801078af:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
801078b6:	8b 55 14             	mov    0x14(%ebp),%edx
801078b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078bc:	01 d0                	add    %edx,%eax
801078be:	8b 55 e8             	mov    -0x18(%ebp),%edx
801078c1:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801078c7:	ff 75 f0             	push   -0x10(%ebp)
801078ca:	50                   	push   %eax
801078cb:	52                   	push   %edx
801078cc:	ff 75 10             	push   0x10(%ebp)
801078cf:	e8 ef a5 ff ff       	call   80101ec3 <readi>
801078d4:	83 c4 10             	add    $0x10,%esp
801078d7:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801078da:	74 07                	je     801078e3 <loaduvm+0xb3>
      return -1;
801078dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801078e1:	eb 18                	jmp    801078fb <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
801078e3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801078ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ed:	3b 45 18             	cmp    0x18(%ebp),%eax
801078f0:	0f 82 65 ff ff ff    	jb     8010785b <loaduvm+0x2b>
  }
  return 0;
801078f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801078fb:	c9                   	leave  
801078fc:	c3                   	ret    

801078fd <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801078fd:	55                   	push   %ebp
801078fe:	89 e5                	mov    %esp,%ebp
80107900:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107903:	8b 45 10             	mov    0x10(%ebp),%eax
80107906:	85 c0                	test   %eax,%eax
80107908:	79 0a                	jns    80107914 <allocuvm+0x17>
    return 0;
8010790a:	b8 00 00 00 00       	mov    $0x0,%eax
8010790f:	e9 ec 00 00 00       	jmp    80107a00 <allocuvm+0x103>
  if(newsz < oldsz)
80107914:	8b 45 10             	mov    0x10(%ebp),%eax
80107917:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010791a:	73 08                	jae    80107924 <allocuvm+0x27>
    return oldsz;
8010791c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010791f:	e9 dc 00 00 00       	jmp    80107a00 <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80107924:	8b 45 0c             	mov    0xc(%ebp),%eax
80107927:	05 ff 0f 00 00       	add    $0xfff,%eax
8010792c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107931:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107934:	e9 b8 00 00 00       	jmp    801079f1 <allocuvm+0xf4>
    mem = kalloc();
80107939:	e8 4f ae ff ff       	call   8010278d <kalloc>
8010793e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107941:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107945:	75 2e                	jne    80107975 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80107947:	83 ec 0c             	sub    $0xc,%esp
8010794a:	68 19 aa 10 80       	push   $0x8010aa19
8010794f:	e8 a0 8a ff ff       	call   801003f4 <cprintf>
80107954:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107957:	83 ec 04             	sub    $0x4,%esp
8010795a:	ff 75 0c             	push   0xc(%ebp)
8010795d:	ff 75 10             	push   0x10(%ebp)
80107960:	ff 75 08             	push   0x8(%ebp)
80107963:	e8 9a 00 00 00       	call   80107a02 <deallocuvm>
80107968:	83 c4 10             	add    $0x10,%esp
      return 0;
8010796b:	b8 00 00 00 00       	mov    $0x0,%eax
80107970:	e9 8b 00 00 00       	jmp    80107a00 <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80107975:	83 ec 04             	sub    $0x4,%esp
80107978:	68 00 10 00 00       	push   $0x1000
8010797d:	6a 00                	push   $0x0
8010797f:	ff 75 f0             	push   -0x10(%ebp)
80107982:	e8 8a d1 ff ff       	call   80104b11 <memset>
80107987:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
8010798a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010798d:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107993:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107996:	83 ec 0c             	sub    $0xc,%esp
80107999:	6a 06                	push   $0x6
8010799b:	52                   	push   %edx
8010799c:	68 00 10 00 00       	push   $0x1000
801079a1:	50                   	push   %eax
801079a2:	ff 75 08             	push   0x8(%ebp)
801079a5:	e8 ca fa ff ff       	call   80107474 <mappages>
801079aa:	83 c4 20             	add    $0x20,%esp
801079ad:	85 c0                	test   %eax,%eax
801079af:	79 39                	jns    801079ea <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
801079b1:	83 ec 0c             	sub    $0xc,%esp
801079b4:	68 31 aa 10 80       	push   $0x8010aa31
801079b9:	e8 36 8a ff ff       	call   801003f4 <cprintf>
801079be:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801079c1:	83 ec 04             	sub    $0x4,%esp
801079c4:	ff 75 0c             	push   0xc(%ebp)
801079c7:	ff 75 10             	push   0x10(%ebp)
801079ca:	ff 75 08             	push   0x8(%ebp)
801079cd:	e8 30 00 00 00       	call   80107a02 <deallocuvm>
801079d2:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
801079d5:	83 ec 0c             	sub    $0xc,%esp
801079d8:	ff 75 f0             	push   -0x10(%ebp)
801079db:	e8 13 ad ff ff       	call   801026f3 <kfree>
801079e0:	83 c4 10             	add    $0x10,%esp
      return 0;
801079e3:	b8 00 00 00 00       	mov    $0x0,%eax
801079e8:	eb 16                	jmp    80107a00 <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
801079ea:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801079f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f4:	3b 45 10             	cmp    0x10(%ebp),%eax
801079f7:	0f 82 3c ff ff ff    	jb     80107939 <allocuvm+0x3c>
    }
  }
  return newsz;
801079fd:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107a00:	c9                   	leave  
80107a01:	c3                   	ret    

80107a02 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107a02:	55                   	push   %ebp
80107a03:	89 e5                	mov    %esp,%ebp
80107a05:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107a08:	8b 45 10             	mov    0x10(%ebp),%eax
80107a0b:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107a0e:	72 08                	jb     80107a18 <deallocuvm+0x16>
    return oldsz;
80107a10:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a13:	e9 ac 00 00 00       	jmp    80107ac4 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80107a18:	8b 45 10             	mov    0x10(%ebp),%eax
80107a1b:	05 ff 0f 00 00       	add    $0xfff,%eax
80107a20:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a25:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107a28:	e9 88 00 00 00       	jmp    80107ab5 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107a2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a30:	83 ec 04             	sub    $0x4,%esp
80107a33:	6a 00                	push   $0x0
80107a35:	50                   	push   %eax
80107a36:	ff 75 08             	push   0x8(%ebp)
80107a39:	e8 a0 f9 ff ff       	call   801073de <walkpgdir>
80107a3e:	83 c4 10             	add    $0x10,%esp
80107a41:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107a44:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107a48:	75 16                	jne    80107a60 <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a4d:	c1 e8 16             	shr    $0x16,%eax
80107a50:	83 c0 01             	add    $0x1,%eax
80107a53:	c1 e0 16             	shl    $0x16,%eax
80107a56:	2d 00 10 00 00       	sub    $0x1000,%eax
80107a5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107a5e:	eb 4e                	jmp    80107aae <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80107a60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a63:	8b 00                	mov    (%eax),%eax
80107a65:	83 e0 01             	and    $0x1,%eax
80107a68:	85 c0                	test   %eax,%eax
80107a6a:	74 42                	je     80107aae <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80107a6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a6f:	8b 00                	mov    (%eax),%eax
80107a71:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a76:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107a79:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107a7d:	75 0d                	jne    80107a8c <deallocuvm+0x8a>
        panic("kfree");
80107a7f:	83 ec 0c             	sub    $0xc,%esp
80107a82:	68 4d aa 10 80       	push   $0x8010aa4d
80107a87:	e8 1d 8b ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
80107a8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107a8f:	05 00 00 00 80       	add    $0x80000000,%eax
80107a94:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107a97:	83 ec 0c             	sub    $0xc,%esp
80107a9a:	ff 75 e8             	push   -0x18(%ebp)
80107a9d:	e8 51 ac ff ff       	call   801026f3 <kfree>
80107aa2:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107aa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107aa8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107aae:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab8:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107abb:	0f 82 6c ff ff ff    	jb     80107a2d <deallocuvm+0x2b>
    }
  }
  return newsz;
80107ac1:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107ac4:	c9                   	leave  
80107ac5:	c3                   	ret    

80107ac6 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107ac6:	55                   	push   %ebp
80107ac7:	89 e5                	mov    %esp,%ebp
80107ac9:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107acc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107ad0:	75 0d                	jne    80107adf <freevm+0x19>
    panic("freevm: no pgdir");
80107ad2:	83 ec 0c             	sub    $0xc,%esp
80107ad5:	68 53 aa 10 80       	push   $0x8010aa53
80107ada:	e8 ca 8a ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107adf:	83 ec 04             	sub    $0x4,%esp
80107ae2:	6a 00                	push   $0x0
80107ae4:	68 00 00 00 80       	push   $0x80000000
80107ae9:	ff 75 08             	push   0x8(%ebp)
80107aec:	e8 11 ff ff ff       	call   80107a02 <deallocuvm>
80107af1:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107af4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107afb:	eb 48                	jmp    80107b45 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80107afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b00:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107b07:	8b 45 08             	mov    0x8(%ebp),%eax
80107b0a:	01 d0                	add    %edx,%eax
80107b0c:	8b 00                	mov    (%eax),%eax
80107b0e:	83 e0 01             	and    $0x1,%eax
80107b11:	85 c0                	test   %eax,%eax
80107b13:	74 2c                	je     80107b41 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b18:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80107b22:	01 d0                	add    %edx,%eax
80107b24:	8b 00                	mov    (%eax),%eax
80107b26:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b2b:	05 00 00 00 80       	add    $0x80000000,%eax
80107b30:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107b33:	83 ec 0c             	sub    $0xc,%esp
80107b36:	ff 75 f0             	push   -0x10(%ebp)
80107b39:	e8 b5 ab ff ff       	call   801026f3 <kfree>
80107b3e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107b41:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107b45:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107b4c:	76 af                	jbe    80107afd <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80107b4e:	83 ec 0c             	sub    $0xc,%esp
80107b51:	ff 75 08             	push   0x8(%ebp)
80107b54:	e8 9a ab ff ff       	call   801026f3 <kfree>
80107b59:	83 c4 10             	add    $0x10,%esp
}
80107b5c:	90                   	nop
80107b5d:	c9                   	leave  
80107b5e:	c3                   	ret    

80107b5f <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107b5f:	55                   	push   %ebp
80107b60:	89 e5                	mov    %esp,%ebp
80107b62:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107b65:	83 ec 04             	sub    $0x4,%esp
80107b68:	6a 00                	push   $0x0
80107b6a:	ff 75 0c             	push   0xc(%ebp)
80107b6d:	ff 75 08             	push   0x8(%ebp)
80107b70:	e8 69 f8 ff ff       	call   801073de <walkpgdir>
80107b75:	83 c4 10             	add    $0x10,%esp
80107b78:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107b7b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107b7f:	75 0d                	jne    80107b8e <clearpteu+0x2f>
    panic("clearpteu");
80107b81:	83 ec 0c             	sub    $0xc,%esp
80107b84:	68 64 aa 10 80       	push   $0x8010aa64
80107b89:	e8 1b 8a ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
80107b8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b91:	8b 00                	mov    (%eax),%eax
80107b93:	83 e0 fb             	and    $0xfffffffb,%eax
80107b96:	89 c2                	mov    %eax,%edx
80107b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b9b:	89 10                	mov    %edx,(%eax)
}
80107b9d:	90                   	nop
80107b9e:	c9                   	leave  
80107b9f:	c3                   	ret    

80107ba0 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107ba0:	55                   	push   %ebp
80107ba1:	89 e5                	mov    %esp,%ebp
80107ba3:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107ba6:	e8 59 f9 ff ff       	call   80107504 <setupkvm>
80107bab:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107bae:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107bb2:	75 0a                	jne    80107bbe <copyuvm+0x1e>
    return 0;
80107bb4:	b8 00 00 00 00       	mov    $0x0,%eax
80107bb9:	e9 d6 01 00 00       	jmp    80107d94 <copyuvm+0x1f4>
  for(i = 0; i < sz; i += PGSIZE){
80107bbe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107bc5:	e9 b5 00 00 00       	jmp    80107c7f <copyuvm+0xdf>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107bca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bcd:	83 ec 04             	sub    $0x4,%esp
80107bd0:	6a 00                	push   $0x0
80107bd2:	50                   	push   %eax
80107bd3:	ff 75 08             	push   0x8(%ebp)
80107bd6:	e8 03 f8 ff ff       	call   801073de <walkpgdir>
80107bdb:	83 c4 10             	add    $0x10,%esp
80107bde:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107be1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107be5:	75 0d                	jne    80107bf4 <copyuvm+0x54>
      panic("copyuvm: pte should exist");
80107be7:	83 ec 0c             	sub    $0xc,%esp
80107bea:	68 6e aa 10 80       	push   $0x8010aa6e
80107bef:	e8 b5 89 ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
80107bf4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107bf7:	8b 00                	mov    (%eax),%eax
80107bf9:	83 e0 01             	and    $0x1,%eax
80107bfc:	85 c0                	test   %eax,%eax
80107bfe:	74 77                	je     80107c77 <copyuvm+0xd7>
      continue;
    pa = PTE_ADDR(*pte);
80107c00:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c03:	8b 00                	mov    (%eax),%eax
80107c05:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c0a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107c0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c10:	8b 00                	mov    (%eax),%eax
80107c12:	25 ff 0f 00 00       	and    $0xfff,%eax
80107c17:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107c1a:	e8 6e ab ff ff       	call   8010278d <kalloc>
80107c1f:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107c22:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107c26:	0f 84 4b 01 00 00    	je     80107d77 <copyuvm+0x1d7>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107c2c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107c2f:	05 00 00 00 80       	add    $0x80000000,%eax
80107c34:	83 ec 04             	sub    $0x4,%esp
80107c37:	68 00 10 00 00       	push   $0x1000
80107c3c:	50                   	push   %eax
80107c3d:	ff 75 e0             	push   -0x20(%ebp)
80107c40:	e8 8b cf ff ff       	call   80104bd0 <memmove>
80107c45:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107c48:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107c4b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107c4e:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107c54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c57:	83 ec 0c             	sub    $0xc,%esp
80107c5a:	52                   	push   %edx
80107c5b:	51                   	push   %ecx
80107c5c:	68 00 10 00 00       	push   $0x1000
80107c61:	50                   	push   %eax
80107c62:	ff 75 f0             	push   -0x10(%ebp)
80107c65:	e8 0a f8 ff ff       	call   80107474 <mappages>
80107c6a:	83 c4 20             	add    $0x20,%esp
80107c6d:	85 c0                	test   %eax,%eax
80107c6f:	0f 88 05 01 00 00    	js     80107d7a <copyuvm+0x1da>
80107c75:	eb 01                	jmp    80107c78 <copyuvm+0xd8>
      continue;
80107c77:	90                   	nop
  for(i = 0; i < sz; i += PGSIZE){
80107c78:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107c7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c82:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107c85:	0f 82 3f ff ff ff    	jb     80107bca <copyuvm+0x2a>
      goto bad;
  }
  for(i = KERNBASE-PGSIZE; i < KERNBASE; i += PGSIZE){
80107c8b:	c7 45 f4 00 f0 ff 7f 	movl   $0x7ffff000,-0xc(%ebp)
80107c92:	e9 b7 00 00 00       	jmp    80107d4e <copyuvm+0x1ae>
    if((pte = walkpgdir(pgdir, (void *) i, 1)) == 0)
80107c97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9a:	83 ec 04             	sub    $0x4,%esp
80107c9d:	6a 01                	push   $0x1
80107c9f:	50                   	push   %eax
80107ca0:	ff 75 08             	push   0x8(%ebp)
80107ca3:	e8 36 f7 ff ff       	call   801073de <walkpgdir>
80107ca8:	83 c4 10             	add    $0x10,%esp
80107cab:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107cae:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107cb2:	75 0d                	jne    80107cc1 <copyuvm+0x121>
      panic("copyuvm: pte should exist");
80107cb4:	83 ec 0c             	sub    $0xc,%esp
80107cb7:	68 6e aa 10 80       	push   $0x8010aa6e
80107cbc:	e8 e8 88 ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
80107cc1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107cc4:	8b 00                	mov    (%eax),%eax
80107cc6:	83 e0 01             	and    $0x1,%eax
80107cc9:	85 c0                	test   %eax,%eax
80107ccb:	75 0d                	jne    80107cda <copyuvm+0x13a>
      panic("copyuvm: page not present");
80107ccd:	83 ec 0c             	sub    $0xc,%esp
80107cd0:	68 88 aa 10 80       	push   $0x8010aa88
80107cd5:	e8 cf 88 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107cda:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107cdd:	8b 00                	mov    (%eax),%eax
80107cdf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ce4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107ce7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107cea:	8b 00                	mov    (%eax),%eax
80107cec:	25 ff 0f 00 00       	and    $0xfff,%eax
80107cf1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107cf4:	e8 94 aa ff ff       	call   8010278d <kalloc>
80107cf9:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107cfc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107d00:	74 7b                	je     80107d7d <copyuvm+0x1dd>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107d02:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107d05:	05 00 00 00 80       	add    $0x80000000,%eax
80107d0a:	83 ec 04             	sub    $0x4,%esp
80107d0d:	68 00 10 00 00       	push   $0x1000
80107d12:	50                   	push   %eax
80107d13:	ff 75 e0             	push   -0x20(%ebp)
80107d16:	e8 b5 ce ff ff       	call   80104bd0 <memmove>
80107d1b:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107d1e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107d21:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107d24:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d2d:	83 ec 0c             	sub    $0xc,%esp
80107d30:	52                   	push   %edx
80107d31:	51                   	push   %ecx
80107d32:	68 00 10 00 00       	push   $0x1000
80107d37:	50                   	push   %eax
80107d38:	ff 75 f0             	push   -0x10(%ebp)
80107d3b:	e8 34 f7 ff ff       	call   80107474 <mappages>
80107d40:	83 c4 20             	add    $0x20,%esp
80107d43:	85 c0                	test   %eax,%eax
80107d45:	78 39                	js     80107d80 <copyuvm+0x1e0>
  for(i = KERNBASE-PGSIZE; i < KERNBASE; i += PGSIZE){
80107d47:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107d4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d51:	85 c0                	test   %eax,%eax
80107d53:	0f 89 3e ff ff ff    	jns    80107c97 <copyuvm+0xf7>
      goto bad;
  }

  lcr3(V2P(myproc()->pgdir));
80107d59:	e8 cb bc ff ff       	call   80103a29 <myproc>
80107d5e:	8b 40 04             	mov    0x4(%eax),%eax
80107d61:	05 00 00 00 80       	add    $0x80000000,%eax
80107d66:	83 ec 0c             	sub    $0xc,%esp
80107d69:	50                   	push   %eax
80107d6a:	e8 0d f3 ff ff       	call   8010707c <lcr3>
80107d6f:	83 c4 10             	add    $0x10,%esp

  return d;
80107d72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d75:	eb 1d                	jmp    80107d94 <copyuvm+0x1f4>
      goto bad;
80107d77:	90                   	nop
80107d78:	eb 07                	jmp    80107d81 <copyuvm+0x1e1>
      goto bad;
80107d7a:	90                   	nop
80107d7b:	eb 04                	jmp    80107d81 <copyuvm+0x1e1>
      goto bad;
80107d7d:	90                   	nop
80107d7e:	eb 01                	jmp    80107d81 <copyuvm+0x1e1>
      goto bad;
80107d80:	90                   	nop

bad:
  freevm(d);
80107d81:	83 ec 0c             	sub    $0xc,%esp
80107d84:	ff 75 f0             	push   -0x10(%ebp)
80107d87:	e8 3a fd ff ff       	call   80107ac6 <freevm>
80107d8c:	83 c4 10             	add    $0x10,%esp
  return 0;
80107d8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107d94:	c9                   	leave  
80107d95:	c3                   	ret    

80107d96 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107d96:	55                   	push   %ebp
80107d97:	89 e5                	mov    %esp,%ebp
80107d99:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107d9c:	83 ec 04             	sub    $0x4,%esp
80107d9f:	6a 00                	push   $0x0
80107da1:	ff 75 0c             	push   0xc(%ebp)
80107da4:	ff 75 08             	push   0x8(%ebp)
80107da7:	e8 32 f6 ff ff       	call   801073de <walkpgdir>
80107dac:	83 c4 10             	add    $0x10,%esp
80107daf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107db2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db5:	8b 00                	mov    (%eax),%eax
80107db7:	83 e0 01             	and    $0x1,%eax
80107dba:	85 c0                	test   %eax,%eax
80107dbc:	75 07                	jne    80107dc5 <uva2ka+0x2f>
    return 0;
80107dbe:	b8 00 00 00 00       	mov    $0x0,%eax
80107dc3:	eb 22                	jmp    80107de7 <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80107dc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc8:	8b 00                	mov    (%eax),%eax
80107dca:	83 e0 04             	and    $0x4,%eax
80107dcd:	85 c0                	test   %eax,%eax
80107dcf:	75 07                	jne    80107dd8 <uva2ka+0x42>
    return 0;
80107dd1:	b8 00 00 00 00       	mov    $0x0,%eax
80107dd6:	eb 0f                	jmp    80107de7 <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80107dd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ddb:	8b 00                	mov    (%eax),%eax
80107ddd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107de2:	05 00 00 00 80       	add    $0x80000000,%eax
}
80107de7:	c9                   	leave  
80107de8:	c3                   	ret    

80107de9 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107de9:	55                   	push   %ebp
80107dea:	89 e5                	mov    %esp,%ebp
80107dec:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80107def:	8b 45 10             	mov    0x10(%ebp),%eax
80107df2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80107df5:	eb 7f                	jmp    80107e76 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80107df7:	8b 45 0c             	mov    0xc(%ebp),%eax
80107dfa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107dff:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80107e02:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e05:	83 ec 08             	sub    $0x8,%esp
80107e08:	50                   	push   %eax
80107e09:	ff 75 08             	push   0x8(%ebp)
80107e0c:	e8 85 ff ff ff       	call   80107d96 <uva2ka>
80107e11:	83 c4 10             	add    $0x10,%esp
80107e14:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80107e17:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80107e1b:	75 07                	jne    80107e24 <copyout+0x3b>
      return -1;
80107e1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e22:	eb 61                	jmp    80107e85 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80107e24:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e27:	2b 45 0c             	sub    0xc(%ebp),%eax
80107e2a:	05 00 10 00 00       	add    $0x1000,%eax
80107e2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80107e32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e35:	3b 45 14             	cmp    0x14(%ebp),%eax
80107e38:	76 06                	jbe    80107e40 <copyout+0x57>
      n = len;
80107e3a:	8b 45 14             	mov    0x14(%ebp),%eax
80107e3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80107e40:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e43:	2b 45 ec             	sub    -0x14(%ebp),%eax
80107e46:	89 c2                	mov    %eax,%edx
80107e48:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107e4b:	01 d0                	add    %edx,%eax
80107e4d:	83 ec 04             	sub    $0x4,%esp
80107e50:	ff 75 f0             	push   -0x10(%ebp)
80107e53:	ff 75 f4             	push   -0xc(%ebp)
80107e56:	50                   	push   %eax
80107e57:	e8 74 cd ff ff       	call   80104bd0 <memmove>
80107e5c:	83 c4 10             	add    $0x10,%esp
    len -= n;
80107e5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e62:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80107e65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e68:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80107e6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e6e:	05 00 10 00 00       	add    $0x1000,%eax
80107e73:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80107e76:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80107e7a:	0f 85 77 ff ff ff    	jne    80107df7 <copyout+0xe>
  }
  return 0;
80107e80:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107e85:	c9                   	leave  
80107e86:	c3                   	ret    

80107e87 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80107e87:	55                   	push   %ebp
80107e88:	89 e5                	mov    %esp,%ebp
80107e8a:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107e8d:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80107e94:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107e97:	8b 40 08             	mov    0x8(%eax),%eax
80107e9a:	05 00 00 00 80       	add    $0x80000000,%eax
80107e9f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80107ea2:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80107ea9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eac:	8b 40 24             	mov    0x24(%eax),%eax
80107eaf:	a3 00 41 19 80       	mov    %eax,0x80194100
  ncpu = 0;
80107eb4:	c7 05 40 6d 19 80 00 	movl   $0x0,0x80196d40
80107ebb:	00 00 00 

  while(i<madt->len){
80107ebe:	90                   	nop
80107ebf:	e9 bd 00 00 00       	jmp    80107f81 <mpinit_uefi+0xfa>
    uchar *entry_type = ((uchar *)madt)+i;
80107ec4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107ec7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107eca:	01 d0                	add    %edx,%eax
80107ecc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80107ecf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ed2:	0f b6 00             	movzbl (%eax),%eax
80107ed5:	0f b6 c0             	movzbl %al,%eax
80107ed8:	83 f8 05             	cmp    $0x5,%eax
80107edb:	0f 87 a0 00 00 00    	ja     80107f81 <mpinit_uefi+0xfa>
80107ee1:	8b 04 85 a4 aa 10 80 	mov    -0x7fef555c(,%eax,4),%eax
80107ee8:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80107eea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107eed:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80107ef0:	a1 40 6d 19 80       	mov    0x80196d40,%eax
80107ef5:	83 f8 03             	cmp    $0x3,%eax
80107ef8:	7f 28                	jg     80107f22 <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80107efa:	8b 15 40 6d 19 80    	mov    0x80196d40,%edx
80107f00:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107f03:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80107f07:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80107f0d:	81 c2 80 6a 19 80    	add    $0x80196a80,%edx
80107f13:	88 02                	mov    %al,(%edx)
          ncpu++;
80107f15:	a1 40 6d 19 80       	mov    0x80196d40,%eax
80107f1a:	83 c0 01             	add    $0x1,%eax
80107f1d:	a3 40 6d 19 80       	mov    %eax,0x80196d40
        }
        i += lapic_entry->record_len;
80107f22:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107f25:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107f29:	0f b6 c0             	movzbl %al,%eax
80107f2c:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107f2f:	eb 50                	jmp    80107f81 <mpinit_uefi+0xfa>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80107f31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f34:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80107f37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107f3a:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80107f3e:	a2 44 6d 19 80       	mov    %al,0x80196d44
        i += ioapic->record_len;
80107f43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107f46:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107f4a:	0f b6 c0             	movzbl %al,%eax
80107f4d:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107f50:	eb 2f                	jmp    80107f81 <mpinit_uefi+0xfa>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80107f52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f55:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80107f58:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107f5b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107f5f:	0f b6 c0             	movzbl %al,%eax
80107f62:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107f65:	eb 1a                	jmp    80107f81 <mpinit_uefi+0xfa>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80107f67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f6a:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80107f6d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f70:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107f74:	0f b6 c0             	movzbl %al,%eax
80107f77:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107f7a:	eb 05                	jmp    80107f81 <mpinit_uefi+0xfa>

      case 5:
        i = i + 0xC;
80107f7c:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80107f80:	90                   	nop
  while(i<madt->len){
80107f81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f84:	8b 40 04             	mov    0x4(%eax),%eax
80107f87:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80107f8a:	0f 82 34 ff ff ff    	jb     80107ec4 <mpinit_uefi+0x3d>
    }
  }

}
80107f90:	90                   	nop
80107f91:	90                   	nop
80107f92:	c9                   	leave  
80107f93:	c3                   	ret    

80107f94 <inb>:
{
80107f94:	55                   	push   %ebp
80107f95:	89 e5                	mov    %esp,%ebp
80107f97:	83 ec 14             	sub    $0x14,%esp
80107f9a:	8b 45 08             	mov    0x8(%ebp),%eax
80107f9d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107fa1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107fa5:	89 c2                	mov    %eax,%edx
80107fa7:	ec                   	in     (%dx),%al
80107fa8:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107fab:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107faf:	c9                   	leave  
80107fb0:	c3                   	ret    

80107fb1 <outb>:
{
80107fb1:	55                   	push   %ebp
80107fb2:	89 e5                	mov    %esp,%ebp
80107fb4:	83 ec 08             	sub    $0x8,%esp
80107fb7:	8b 45 08             	mov    0x8(%ebp),%eax
80107fba:	8b 55 0c             	mov    0xc(%ebp),%edx
80107fbd:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80107fc1:	89 d0                	mov    %edx,%eax
80107fc3:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107fc6:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107fca:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107fce:	ee                   	out    %al,(%dx)
}
80107fcf:	90                   	nop
80107fd0:	c9                   	leave  
80107fd1:	c3                   	ret    

80107fd2 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80107fd2:	55                   	push   %ebp
80107fd3:	89 e5                	mov    %esp,%ebp
80107fd5:	83 ec 28             	sub    $0x28,%esp
80107fd8:	8b 45 08             	mov    0x8(%ebp),%eax
80107fdb:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80107fde:	6a 00                	push   $0x0
80107fe0:	68 fa 03 00 00       	push   $0x3fa
80107fe5:	e8 c7 ff ff ff       	call   80107fb1 <outb>
80107fea:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107fed:	68 80 00 00 00       	push   $0x80
80107ff2:	68 fb 03 00 00       	push   $0x3fb
80107ff7:	e8 b5 ff ff ff       	call   80107fb1 <outb>
80107ffc:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107fff:	6a 0c                	push   $0xc
80108001:	68 f8 03 00 00       	push   $0x3f8
80108006:	e8 a6 ff ff ff       	call   80107fb1 <outb>
8010800b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
8010800e:	6a 00                	push   $0x0
80108010:	68 f9 03 00 00       	push   $0x3f9
80108015:	e8 97 ff ff ff       	call   80107fb1 <outb>
8010801a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010801d:	6a 03                	push   $0x3
8010801f:	68 fb 03 00 00       	push   $0x3fb
80108024:	e8 88 ff ff ff       	call   80107fb1 <outb>
80108029:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010802c:	6a 00                	push   $0x0
8010802e:	68 fc 03 00 00       	push   $0x3fc
80108033:	e8 79 ff ff ff       	call   80107fb1 <outb>
80108038:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
8010803b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108042:	eb 11                	jmp    80108055 <uart_debug+0x83>
80108044:	83 ec 0c             	sub    $0xc,%esp
80108047:	6a 0a                	push   $0xa
80108049:	e8 d6 aa ff ff       	call   80102b24 <microdelay>
8010804e:	83 c4 10             	add    $0x10,%esp
80108051:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108055:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80108059:	7f 1a                	jg     80108075 <uart_debug+0xa3>
8010805b:	83 ec 0c             	sub    $0xc,%esp
8010805e:	68 fd 03 00 00       	push   $0x3fd
80108063:	e8 2c ff ff ff       	call   80107f94 <inb>
80108068:	83 c4 10             	add    $0x10,%esp
8010806b:	0f b6 c0             	movzbl %al,%eax
8010806e:	83 e0 20             	and    $0x20,%eax
80108071:	85 c0                	test   %eax,%eax
80108073:	74 cf                	je     80108044 <uart_debug+0x72>
  outb(COM1+0, p);
80108075:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80108079:	0f b6 c0             	movzbl %al,%eax
8010807c:	83 ec 08             	sub    $0x8,%esp
8010807f:	50                   	push   %eax
80108080:	68 f8 03 00 00       	push   $0x3f8
80108085:	e8 27 ff ff ff       	call   80107fb1 <outb>
8010808a:	83 c4 10             	add    $0x10,%esp
}
8010808d:	90                   	nop
8010808e:	c9                   	leave  
8010808f:	c3                   	ret    

80108090 <uart_debugs>:

void uart_debugs(char *p){
80108090:	55                   	push   %ebp
80108091:	89 e5                	mov    %esp,%ebp
80108093:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80108096:	eb 1b                	jmp    801080b3 <uart_debugs+0x23>
    uart_debug(*p++);
80108098:	8b 45 08             	mov    0x8(%ebp),%eax
8010809b:	8d 50 01             	lea    0x1(%eax),%edx
8010809e:	89 55 08             	mov    %edx,0x8(%ebp)
801080a1:	0f b6 00             	movzbl (%eax),%eax
801080a4:	0f be c0             	movsbl %al,%eax
801080a7:	83 ec 0c             	sub    $0xc,%esp
801080aa:	50                   	push   %eax
801080ab:	e8 22 ff ff ff       	call   80107fd2 <uart_debug>
801080b0:	83 c4 10             	add    $0x10,%esp
  while(*p){
801080b3:	8b 45 08             	mov    0x8(%ebp),%eax
801080b6:	0f b6 00             	movzbl (%eax),%eax
801080b9:	84 c0                	test   %al,%al
801080bb:	75 db                	jne    80108098 <uart_debugs+0x8>
  }
}
801080bd:	90                   	nop
801080be:	90                   	nop
801080bf:	c9                   	leave  
801080c0:	c3                   	ret    

801080c1 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
801080c1:	55                   	push   %ebp
801080c2:	89 e5                	mov    %esp,%ebp
801080c4:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801080c7:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
801080ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
801080d1:	8b 50 14             	mov    0x14(%eax),%edx
801080d4:	8b 40 10             	mov    0x10(%eax),%eax
801080d7:	a3 48 6d 19 80       	mov    %eax,0x80196d48
  gpu.vram_size = boot_param->graphic_config.frame_size;
801080dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801080df:	8b 50 1c             	mov    0x1c(%eax),%edx
801080e2:	8b 40 18             	mov    0x18(%eax),%eax
801080e5:	a3 50 6d 19 80       	mov    %eax,0x80196d50
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
801080ea:	8b 15 50 6d 19 80    	mov    0x80196d50,%edx
801080f0:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
801080f5:	29 d0                	sub    %edx,%eax
801080f7:	a3 4c 6d 19 80       	mov    %eax,0x80196d4c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
801080fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801080ff:	8b 50 24             	mov    0x24(%eax),%edx
80108102:	8b 40 20             	mov    0x20(%eax),%eax
80108105:	a3 54 6d 19 80       	mov    %eax,0x80196d54
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
8010810a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010810d:	8b 50 2c             	mov    0x2c(%eax),%edx
80108110:	8b 40 28             	mov    0x28(%eax),%eax
80108113:	a3 58 6d 19 80       	mov    %eax,0x80196d58
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80108118:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010811b:	8b 50 34             	mov    0x34(%eax),%edx
8010811e:	8b 40 30             	mov    0x30(%eax),%eax
80108121:	a3 5c 6d 19 80       	mov    %eax,0x80196d5c
}
80108126:	90                   	nop
80108127:	c9                   	leave  
80108128:	c3                   	ret    

80108129 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80108129:	55                   	push   %ebp
8010812a:	89 e5                	mov    %esp,%ebp
8010812c:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
8010812f:	8b 15 5c 6d 19 80    	mov    0x80196d5c,%edx
80108135:	8b 45 0c             	mov    0xc(%ebp),%eax
80108138:	0f af d0             	imul   %eax,%edx
8010813b:	8b 45 08             	mov    0x8(%ebp),%eax
8010813e:	01 d0                	add    %edx,%eax
80108140:	c1 e0 02             	shl    $0x2,%eax
80108143:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80108146:	8b 15 4c 6d 19 80    	mov    0x80196d4c,%edx
8010814c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010814f:	01 d0                	add    %edx,%eax
80108151:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80108154:	8b 45 10             	mov    0x10(%ebp),%eax
80108157:	0f b6 10             	movzbl (%eax),%edx
8010815a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010815d:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
8010815f:	8b 45 10             	mov    0x10(%ebp),%eax
80108162:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80108166:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108169:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
8010816c:	8b 45 10             	mov    0x10(%ebp),%eax
8010816f:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80108173:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108176:	88 50 02             	mov    %dl,0x2(%eax)
}
80108179:	90                   	nop
8010817a:	c9                   	leave  
8010817b:	c3                   	ret    

8010817c <graphic_scroll_up>:

void graphic_scroll_up(int height){
8010817c:	55                   	push   %ebp
8010817d:	89 e5                	mov    %esp,%ebp
8010817f:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80108182:	8b 15 5c 6d 19 80    	mov    0x80196d5c,%edx
80108188:	8b 45 08             	mov    0x8(%ebp),%eax
8010818b:	0f af c2             	imul   %edx,%eax
8010818e:	c1 e0 02             	shl    $0x2,%eax
80108191:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108194:	a1 50 6d 19 80       	mov    0x80196d50,%eax
80108199:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010819c:	29 d0                	sub    %edx,%eax
8010819e:	8b 0d 4c 6d 19 80    	mov    0x80196d4c,%ecx
801081a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801081a7:	01 ca                	add    %ecx,%edx
801081a9:	89 d1                	mov    %edx,%ecx
801081ab:	8b 15 4c 6d 19 80    	mov    0x80196d4c,%edx
801081b1:	83 ec 04             	sub    $0x4,%esp
801081b4:	50                   	push   %eax
801081b5:	51                   	push   %ecx
801081b6:	52                   	push   %edx
801081b7:	e8 14 ca ff ff       	call   80104bd0 <memmove>
801081bc:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
801081bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081c2:	8b 0d 4c 6d 19 80    	mov    0x80196d4c,%ecx
801081c8:	8b 15 50 6d 19 80    	mov    0x80196d50,%edx
801081ce:	01 ca                	add    %ecx,%edx
801081d0:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801081d3:	29 ca                	sub    %ecx,%edx
801081d5:	83 ec 04             	sub    $0x4,%esp
801081d8:	50                   	push   %eax
801081d9:	6a 00                	push   $0x0
801081db:	52                   	push   %edx
801081dc:	e8 30 c9 ff ff       	call   80104b11 <memset>
801081e1:	83 c4 10             	add    $0x10,%esp
}
801081e4:	90                   	nop
801081e5:	c9                   	leave  
801081e6:	c3                   	ret    

801081e7 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
801081e7:	55                   	push   %ebp
801081e8:	89 e5                	mov    %esp,%ebp
801081ea:	53                   	push   %ebx
801081eb:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
801081ee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801081f5:	e9 b1 00 00 00       	jmp    801082ab <font_render+0xc4>
    for(int j=14;j>-1;j--){
801081fa:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80108201:	e9 97 00 00 00       	jmp    8010829d <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
80108206:	8b 45 10             	mov    0x10(%ebp),%eax
80108209:	83 e8 20             	sub    $0x20,%eax
8010820c:	6b d0 1e             	imul   $0x1e,%eax,%edx
8010820f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108212:	01 d0                	add    %edx,%eax
80108214:	0f b7 84 00 c0 aa 10 	movzwl -0x7fef5540(%eax,%eax,1),%eax
8010821b:	80 
8010821c:	0f b7 d0             	movzwl %ax,%edx
8010821f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108222:	bb 01 00 00 00       	mov    $0x1,%ebx
80108227:	89 c1                	mov    %eax,%ecx
80108229:	d3 e3                	shl    %cl,%ebx
8010822b:	89 d8                	mov    %ebx,%eax
8010822d:	21 d0                	and    %edx,%eax
8010822f:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80108232:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108235:	ba 01 00 00 00       	mov    $0x1,%edx
8010823a:	89 c1                	mov    %eax,%ecx
8010823c:	d3 e2                	shl    %cl,%edx
8010823e:	89 d0                	mov    %edx,%eax
80108240:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80108243:	75 2b                	jne    80108270 <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108245:	8b 55 0c             	mov    0xc(%ebp),%edx
80108248:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010824b:	01 c2                	add    %eax,%edx
8010824d:	b8 0e 00 00 00       	mov    $0xe,%eax
80108252:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108255:	89 c1                	mov    %eax,%ecx
80108257:	8b 45 08             	mov    0x8(%ebp),%eax
8010825a:	01 c8                	add    %ecx,%eax
8010825c:	83 ec 04             	sub    $0x4,%esp
8010825f:	68 e0 f4 10 80       	push   $0x8010f4e0
80108264:	52                   	push   %edx
80108265:	50                   	push   %eax
80108266:	e8 be fe ff ff       	call   80108129 <graphic_draw_pixel>
8010826b:	83 c4 10             	add    $0x10,%esp
8010826e:	eb 29                	jmp    80108299 <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80108270:	8b 55 0c             	mov    0xc(%ebp),%edx
80108273:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108276:	01 c2                	add    %eax,%edx
80108278:	b8 0e 00 00 00       	mov    $0xe,%eax
8010827d:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108280:	89 c1                	mov    %eax,%ecx
80108282:	8b 45 08             	mov    0x8(%ebp),%eax
80108285:	01 c8                	add    %ecx,%eax
80108287:	83 ec 04             	sub    $0x4,%esp
8010828a:	68 60 6d 19 80       	push   $0x80196d60
8010828f:	52                   	push   %edx
80108290:	50                   	push   %eax
80108291:	e8 93 fe ff ff       	call   80108129 <graphic_draw_pixel>
80108296:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108299:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
8010829d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801082a1:	0f 89 5f ff ff ff    	jns    80108206 <font_render+0x1f>
  for(int i=0;i<30;i++){
801082a7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801082ab:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
801082af:	0f 8e 45 ff ff ff    	jle    801081fa <font_render+0x13>
      }
    }
  }
}
801082b5:	90                   	nop
801082b6:	90                   	nop
801082b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801082ba:	c9                   	leave  
801082bb:	c3                   	ret    

801082bc <font_render_string>:

void font_render_string(char *string,int row){
801082bc:	55                   	push   %ebp
801082bd:	89 e5                	mov    %esp,%ebp
801082bf:	53                   	push   %ebx
801082c0:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
801082c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
801082ca:	eb 33                	jmp    801082ff <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
801082cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801082cf:	8b 45 08             	mov    0x8(%ebp),%eax
801082d2:	01 d0                	add    %edx,%eax
801082d4:	0f b6 00             	movzbl (%eax),%eax
801082d7:	0f be c8             	movsbl %al,%ecx
801082da:	8b 45 0c             	mov    0xc(%ebp),%eax
801082dd:	6b d0 1e             	imul   $0x1e,%eax,%edx
801082e0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801082e3:	89 d8                	mov    %ebx,%eax
801082e5:	c1 e0 04             	shl    $0x4,%eax
801082e8:	29 d8                	sub    %ebx,%eax
801082ea:	83 c0 02             	add    $0x2,%eax
801082ed:	83 ec 04             	sub    $0x4,%esp
801082f0:	51                   	push   %ecx
801082f1:	52                   	push   %edx
801082f2:	50                   	push   %eax
801082f3:	e8 ef fe ff ff       	call   801081e7 <font_render>
801082f8:	83 c4 10             	add    $0x10,%esp
    i++;
801082fb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
801082ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108302:	8b 45 08             	mov    0x8(%ebp),%eax
80108305:	01 d0                	add    %edx,%eax
80108307:	0f b6 00             	movzbl (%eax),%eax
8010830a:	84 c0                	test   %al,%al
8010830c:	74 06                	je     80108314 <font_render_string+0x58>
8010830e:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108312:	7e b8                	jle    801082cc <font_render_string+0x10>
  }
}
80108314:	90                   	nop
80108315:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108318:	c9                   	leave  
80108319:	c3                   	ret    

8010831a <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
8010831a:	55                   	push   %ebp
8010831b:	89 e5                	mov    %esp,%ebp
8010831d:	53                   	push   %ebx
8010831e:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108321:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108328:	eb 6b                	jmp    80108395 <pci_init+0x7b>
    for(int j=0;j<32;j++){
8010832a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108331:	eb 58                	jmp    8010838b <pci_init+0x71>
      for(int k=0;k<8;k++){
80108333:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010833a:	eb 45                	jmp    80108381 <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
8010833c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010833f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108342:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108345:	83 ec 0c             	sub    $0xc,%esp
80108348:	8d 5d e8             	lea    -0x18(%ebp),%ebx
8010834b:	53                   	push   %ebx
8010834c:	6a 00                	push   $0x0
8010834e:	51                   	push   %ecx
8010834f:	52                   	push   %edx
80108350:	50                   	push   %eax
80108351:	e8 b0 00 00 00       	call   80108406 <pci_access_config>
80108356:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
80108359:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010835c:	0f b7 c0             	movzwl %ax,%eax
8010835f:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108364:	74 17                	je     8010837d <pci_init+0x63>
        pci_init_device(i,j,k);
80108366:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108369:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010836c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010836f:	83 ec 04             	sub    $0x4,%esp
80108372:	51                   	push   %ecx
80108373:	52                   	push   %edx
80108374:	50                   	push   %eax
80108375:	e8 37 01 00 00       	call   801084b1 <pci_init_device>
8010837a:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
8010837d:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108381:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108385:	7e b5                	jle    8010833c <pci_init+0x22>
    for(int j=0;j<32;j++){
80108387:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010838b:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
8010838f:	7e a2                	jle    80108333 <pci_init+0x19>
  for(int i=0;i<256;i++){
80108391:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108395:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010839c:	7e 8c                	jle    8010832a <pci_init+0x10>
      }
      }
    }
  }
}
8010839e:	90                   	nop
8010839f:	90                   	nop
801083a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801083a3:	c9                   	leave  
801083a4:	c3                   	ret    

801083a5 <pci_write_config>:

void pci_write_config(uint config){
801083a5:	55                   	push   %ebp
801083a6:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
801083a8:	8b 45 08             	mov    0x8(%ebp),%eax
801083ab:	ba f8 0c 00 00       	mov    $0xcf8,%edx
801083b0:	89 c0                	mov    %eax,%eax
801083b2:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801083b3:	90                   	nop
801083b4:	5d                   	pop    %ebp
801083b5:	c3                   	ret    

801083b6 <pci_write_data>:

void pci_write_data(uint config){
801083b6:	55                   	push   %ebp
801083b7:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
801083b9:	8b 45 08             	mov    0x8(%ebp),%eax
801083bc:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801083c1:	89 c0                	mov    %eax,%eax
801083c3:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801083c4:	90                   	nop
801083c5:	5d                   	pop    %ebp
801083c6:	c3                   	ret    

801083c7 <pci_read_config>:
uint pci_read_config(){
801083c7:	55                   	push   %ebp
801083c8:	89 e5                	mov    %esp,%ebp
801083ca:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
801083cd:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801083d2:	ed                   	in     (%dx),%eax
801083d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
801083d6:	83 ec 0c             	sub    $0xc,%esp
801083d9:	68 c8 00 00 00       	push   $0xc8
801083de:	e8 41 a7 ff ff       	call   80102b24 <microdelay>
801083e3:	83 c4 10             	add    $0x10,%esp
  return data;
801083e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801083e9:	c9                   	leave  
801083ea:	c3                   	ret    

801083eb <pci_test>:


void pci_test(){
801083eb:	55                   	push   %ebp
801083ec:	89 e5                	mov    %esp,%ebp
801083ee:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
801083f1:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
801083f8:	ff 75 fc             	push   -0x4(%ebp)
801083fb:	e8 a5 ff ff ff       	call   801083a5 <pci_write_config>
80108400:	83 c4 04             	add    $0x4,%esp
}
80108403:	90                   	nop
80108404:	c9                   	leave  
80108405:	c3                   	ret    

80108406 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108406:	55                   	push   %ebp
80108407:	89 e5                	mov    %esp,%ebp
80108409:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010840c:	8b 45 08             	mov    0x8(%ebp),%eax
8010840f:	c1 e0 10             	shl    $0x10,%eax
80108412:	25 00 00 ff 00       	and    $0xff0000,%eax
80108417:	89 c2                	mov    %eax,%edx
80108419:	8b 45 0c             	mov    0xc(%ebp),%eax
8010841c:	c1 e0 0b             	shl    $0xb,%eax
8010841f:	0f b7 c0             	movzwl %ax,%eax
80108422:	09 c2                	or     %eax,%edx
80108424:	8b 45 10             	mov    0x10(%ebp),%eax
80108427:	c1 e0 08             	shl    $0x8,%eax
8010842a:	25 00 07 00 00       	and    $0x700,%eax
8010842f:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108431:	8b 45 14             	mov    0x14(%ebp),%eax
80108434:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108439:	09 d0                	or     %edx,%eax
8010843b:	0d 00 00 00 80       	or     $0x80000000,%eax
80108440:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80108443:	ff 75 f4             	push   -0xc(%ebp)
80108446:	e8 5a ff ff ff       	call   801083a5 <pci_write_config>
8010844b:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
8010844e:	e8 74 ff ff ff       	call   801083c7 <pci_read_config>
80108453:	8b 55 18             	mov    0x18(%ebp),%edx
80108456:	89 02                	mov    %eax,(%edx)
}
80108458:	90                   	nop
80108459:	c9                   	leave  
8010845a:	c3                   	ret    

8010845b <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
8010845b:	55                   	push   %ebp
8010845c:	89 e5                	mov    %esp,%ebp
8010845e:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108461:	8b 45 08             	mov    0x8(%ebp),%eax
80108464:	c1 e0 10             	shl    $0x10,%eax
80108467:	25 00 00 ff 00       	and    $0xff0000,%eax
8010846c:	89 c2                	mov    %eax,%edx
8010846e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108471:	c1 e0 0b             	shl    $0xb,%eax
80108474:	0f b7 c0             	movzwl %ax,%eax
80108477:	09 c2                	or     %eax,%edx
80108479:	8b 45 10             	mov    0x10(%ebp),%eax
8010847c:	c1 e0 08             	shl    $0x8,%eax
8010847f:	25 00 07 00 00       	and    $0x700,%eax
80108484:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108486:	8b 45 14             	mov    0x14(%ebp),%eax
80108489:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010848e:	09 d0                	or     %edx,%eax
80108490:	0d 00 00 00 80       	or     $0x80000000,%eax
80108495:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108498:	ff 75 fc             	push   -0x4(%ebp)
8010849b:	e8 05 ff ff ff       	call   801083a5 <pci_write_config>
801084a0:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
801084a3:	ff 75 18             	push   0x18(%ebp)
801084a6:	e8 0b ff ff ff       	call   801083b6 <pci_write_data>
801084ab:	83 c4 04             	add    $0x4,%esp
}
801084ae:	90                   	nop
801084af:	c9                   	leave  
801084b0:	c3                   	ret    

801084b1 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
801084b1:	55                   	push   %ebp
801084b2:	89 e5                	mov    %esp,%ebp
801084b4:	53                   	push   %ebx
801084b5:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
801084b8:	8b 45 08             	mov    0x8(%ebp),%eax
801084bb:	a2 64 6d 19 80       	mov    %al,0x80196d64
  dev.device_num = device_num;
801084c0:	8b 45 0c             	mov    0xc(%ebp),%eax
801084c3:	a2 65 6d 19 80       	mov    %al,0x80196d65
  dev.function_num = function_num;
801084c8:	8b 45 10             	mov    0x10(%ebp),%eax
801084cb:	a2 66 6d 19 80       	mov    %al,0x80196d66
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
801084d0:	ff 75 10             	push   0x10(%ebp)
801084d3:	ff 75 0c             	push   0xc(%ebp)
801084d6:	ff 75 08             	push   0x8(%ebp)
801084d9:	68 04 c1 10 80       	push   $0x8010c104
801084de:	e8 11 7f ff ff       	call   801003f4 <cprintf>
801084e3:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
801084e6:	83 ec 0c             	sub    $0xc,%esp
801084e9:	8d 45 ec             	lea    -0x14(%ebp),%eax
801084ec:	50                   	push   %eax
801084ed:	6a 00                	push   $0x0
801084ef:	ff 75 10             	push   0x10(%ebp)
801084f2:	ff 75 0c             	push   0xc(%ebp)
801084f5:	ff 75 08             	push   0x8(%ebp)
801084f8:	e8 09 ff ff ff       	call   80108406 <pci_access_config>
801084fd:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108500:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108503:	c1 e8 10             	shr    $0x10,%eax
80108506:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
80108509:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010850c:	25 ff ff 00 00       	and    $0xffff,%eax
80108511:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108514:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108517:	a3 68 6d 19 80       	mov    %eax,0x80196d68
  dev.vendor_id = vendor_id;
8010851c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010851f:	a3 6c 6d 19 80       	mov    %eax,0x80196d6c
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108524:	83 ec 04             	sub    $0x4,%esp
80108527:	ff 75 f0             	push   -0x10(%ebp)
8010852a:	ff 75 f4             	push   -0xc(%ebp)
8010852d:	68 38 c1 10 80       	push   $0x8010c138
80108532:	e8 bd 7e ff ff       	call   801003f4 <cprintf>
80108537:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
8010853a:	83 ec 0c             	sub    $0xc,%esp
8010853d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108540:	50                   	push   %eax
80108541:	6a 08                	push   $0x8
80108543:	ff 75 10             	push   0x10(%ebp)
80108546:	ff 75 0c             	push   0xc(%ebp)
80108549:	ff 75 08             	push   0x8(%ebp)
8010854c:	e8 b5 fe ff ff       	call   80108406 <pci_access_config>
80108551:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108554:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108557:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
8010855a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010855d:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108560:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108563:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108566:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108569:	0f b6 c0             	movzbl %al,%eax
8010856c:	8b 5d ec             	mov    -0x14(%ebp),%ebx
8010856f:	c1 eb 18             	shr    $0x18,%ebx
80108572:	83 ec 0c             	sub    $0xc,%esp
80108575:	51                   	push   %ecx
80108576:	52                   	push   %edx
80108577:	50                   	push   %eax
80108578:	53                   	push   %ebx
80108579:	68 5c c1 10 80       	push   $0x8010c15c
8010857e:	e8 71 7e ff ff       	call   801003f4 <cprintf>
80108583:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108586:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108589:	c1 e8 18             	shr    $0x18,%eax
8010858c:	a2 70 6d 19 80       	mov    %al,0x80196d70
  dev.sub_class = (data>>16)&0xFF;
80108591:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108594:	c1 e8 10             	shr    $0x10,%eax
80108597:	a2 71 6d 19 80       	mov    %al,0x80196d71
  dev.interface = (data>>8)&0xFF;
8010859c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010859f:	c1 e8 08             	shr    $0x8,%eax
801085a2:	a2 72 6d 19 80       	mov    %al,0x80196d72
  dev.revision_id = data&0xFF;
801085a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085aa:	a2 73 6d 19 80       	mov    %al,0x80196d73
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
801085af:	83 ec 0c             	sub    $0xc,%esp
801085b2:	8d 45 ec             	lea    -0x14(%ebp),%eax
801085b5:	50                   	push   %eax
801085b6:	6a 10                	push   $0x10
801085b8:	ff 75 10             	push   0x10(%ebp)
801085bb:	ff 75 0c             	push   0xc(%ebp)
801085be:	ff 75 08             	push   0x8(%ebp)
801085c1:	e8 40 fe ff ff       	call   80108406 <pci_access_config>
801085c6:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
801085c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085cc:	a3 74 6d 19 80       	mov    %eax,0x80196d74
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
801085d1:	83 ec 0c             	sub    $0xc,%esp
801085d4:	8d 45 ec             	lea    -0x14(%ebp),%eax
801085d7:	50                   	push   %eax
801085d8:	6a 14                	push   $0x14
801085da:	ff 75 10             	push   0x10(%ebp)
801085dd:	ff 75 0c             	push   0xc(%ebp)
801085e0:	ff 75 08             	push   0x8(%ebp)
801085e3:	e8 1e fe ff ff       	call   80108406 <pci_access_config>
801085e8:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
801085eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085ee:	a3 78 6d 19 80       	mov    %eax,0x80196d78
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
801085f3:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
801085fa:	75 5a                	jne    80108656 <pci_init_device+0x1a5>
801085fc:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108603:	75 51                	jne    80108656 <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
80108605:	83 ec 0c             	sub    $0xc,%esp
80108608:	68 a1 c1 10 80       	push   $0x8010c1a1
8010860d:	e8 e2 7d ff ff       	call   801003f4 <cprintf>
80108612:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108615:	83 ec 0c             	sub    $0xc,%esp
80108618:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010861b:	50                   	push   %eax
8010861c:	68 f0 00 00 00       	push   $0xf0
80108621:	ff 75 10             	push   0x10(%ebp)
80108624:	ff 75 0c             	push   0xc(%ebp)
80108627:	ff 75 08             	push   0x8(%ebp)
8010862a:	e8 d7 fd ff ff       	call   80108406 <pci_access_config>
8010862f:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108632:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108635:	83 ec 08             	sub    $0x8,%esp
80108638:	50                   	push   %eax
80108639:	68 bb c1 10 80       	push   $0x8010c1bb
8010863e:	e8 b1 7d ff ff       	call   801003f4 <cprintf>
80108643:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108646:	83 ec 0c             	sub    $0xc,%esp
80108649:	68 64 6d 19 80       	push   $0x80196d64
8010864e:	e8 09 00 00 00       	call   8010865c <i8254_init>
80108653:	83 c4 10             	add    $0x10,%esp
  }
}
80108656:	90                   	nop
80108657:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010865a:	c9                   	leave  
8010865b:	c3                   	ret    

8010865c <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
8010865c:	55                   	push   %ebp
8010865d:	89 e5                	mov    %esp,%ebp
8010865f:	53                   	push   %ebx
80108660:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108663:	8b 45 08             	mov    0x8(%ebp),%eax
80108666:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010866a:	0f b6 c8             	movzbl %al,%ecx
8010866d:	8b 45 08             	mov    0x8(%ebp),%eax
80108670:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108674:	0f b6 d0             	movzbl %al,%edx
80108677:	8b 45 08             	mov    0x8(%ebp),%eax
8010867a:	0f b6 00             	movzbl (%eax),%eax
8010867d:	0f b6 c0             	movzbl %al,%eax
80108680:	83 ec 0c             	sub    $0xc,%esp
80108683:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108686:	53                   	push   %ebx
80108687:	6a 04                	push   $0x4
80108689:	51                   	push   %ecx
8010868a:	52                   	push   %edx
8010868b:	50                   	push   %eax
8010868c:	e8 75 fd ff ff       	call   80108406 <pci_access_config>
80108691:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108694:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108697:	83 c8 04             	or     $0x4,%eax
8010869a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
8010869d:	8b 5d ec             	mov    -0x14(%ebp),%ebx
801086a0:	8b 45 08             	mov    0x8(%ebp),%eax
801086a3:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801086a7:	0f b6 c8             	movzbl %al,%ecx
801086aa:	8b 45 08             	mov    0x8(%ebp),%eax
801086ad:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801086b1:	0f b6 d0             	movzbl %al,%edx
801086b4:	8b 45 08             	mov    0x8(%ebp),%eax
801086b7:	0f b6 00             	movzbl (%eax),%eax
801086ba:	0f b6 c0             	movzbl %al,%eax
801086bd:	83 ec 0c             	sub    $0xc,%esp
801086c0:	53                   	push   %ebx
801086c1:	6a 04                	push   $0x4
801086c3:	51                   	push   %ecx
801086c4:	52                   	push   %edx
801086c5:	50                   	push   %eax
801086c6:	e8 90 fd ff ff       	call   8010845b <pci_write_config_register>
801086cb:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
801086ce:	8b 45 08             	mov    0x8(%ebp),%eax
801086d1:	8b 40 10             	mov    0x10(%eax),%eax
801086d4:	05 00 00 00 40       	add    $0x40000000,%eax
801086d9:	a3 7c 6d 19 80       	mov    %eax,0x80196d7c
  uint *ctrl = (uint *)base_addr;
801086de:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801086e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
801086e6:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801086eb:	05 d8 00 00 00       	add    $0xd8,%eax
801086f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
801086f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086f6:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
801086fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ff:	8b 00                	mov    (%eax),%eax
80108701:	0d 00 00 00 04       	or     $0x4000000,%eax
80108706:	89 c2                	mov    %eax,%edx
80108708:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010870b:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
8010870d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108710:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108716:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108719:	8b 00                	mov    (%eax),%eax
8010871b:	83 c8 40             	or     $0x40,%eax
8010871e:	89 c2                	mov    %eax,%edx
80108720:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108723:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108725:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108728:	8b 10                	mov    (%eax),%edx
8010872a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010872d:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
8010872f:	83 ec 0c             	sub    $0xc,%esp
80108732:	68 d0 c1 10 80       	push   $0x8010c1d0
80108737:	e8 b8 7c ff ff       	call   801003f4 <cprintf>
8010873c:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
8010873f:	e8 49 a0 ff ff       	call   8010278d <kalloc>
80108744:	a3 88 6d 19 80       	mov    %eax,0x80196d88
  *intr_addr = 0;
80108749:	a1 88 6d 19 80       	mov    0x80196d88,%eax
8010874e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108754:	a1 88 6d 19 80       	mov    0x80196d88,%eax
80108759:	83 ec 08             	sub    $0x8,%esp
8010875c:	50                   	push   %eax
8010875d:	68 f2 c1 10 80       	push   $0x8010c1f2
80108762:	e8 8d 7c ff ff       	call   801003f4 <cprintf>
80108767:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
8010876a:	e8 50 00 00 00       	call   801087bf <i8254_init_recv>
  i8254_init_send();
8010876f:	e8 69 03 00 00       	call   80108add <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108774:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010877b:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
8010877e:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108785:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108788:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010878f:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108792:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108799:	0f b6 c0             	movzbl %al,%eax
8010879c:	83 ec 0c             	sub    $0xc,%esp
8010879f:	53                   	push   %ebx
801087a0:	51                   	push   %ecx
801087a1:	52                   	push   %edx
801087a2:	50                   	push   %eax
801087a3:	68 00 c2 10 80       	push   $0x8010c200
801087a8:	e8 47 7c ff ff       	call   801003f4 <cprintf>
801087ad:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
801087b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087b3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
801087b9:	90                   	nop
801087ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801087bd:	c9                   	leave  
801087be:	c3                   	ret    

801087bf <i8254_init_recv>:

void i8254_init_recv(){
801087bf:	55                   	push   %ebp
801087c0:	89 e5                	mov    %esp,%ebp
801087c2:	57                   	push   %edi
801087c3:	56                   	push   %esi
801087c4:	53                   	push   %ebx
801087c5:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
801087c8:	83 ec 0c             	sub    $0xc,%esp
801087cb:	6a 00                	push   $0x0
801087cd:	e8 e8 04 00 00       	call   80108cba <i8254_read_eeprom>
801087d2:	83 c4 10             	add    $0x10,%esp
801087d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
801087d8:	8b 45 d8             	mov    -0x28(%ebp),%eax
801087db:	a2 80 6d 19 80       	mov    %al,0x80196d80
  mac_addr[1] = data_l>>8;
801087e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
801087e3:	c1 e8 08             	shr    $0x8,%eax
801087e6:	a2 81 6d 19 80       	mov    %al,0x80196d81
  uint data_m = i8254_read_eeprom(0x1);
801087eb:	83 ec 0c             	sub    $0xc,%esp
801087ee:	6a 01                	push   $0x1
801087f0:	e8 c5 04 00 00       	call   80108cba <i8254_read_eeprom>
801087f5:	83 c4 10             	add    $0x10,%esp
801087f8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
801087fb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801087fe:	a2 82 6d 19 80       	mov    %al,0x80196d82
  mac_addr[3] = data_m>>8;
80108803:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108806:	c1 e8 08             	shr    $0x8,%eax
80108809:	a2 83 6d 19 80       	mov    %al,0x80196d83
  uint data_h = i8254_read_eeprom(0x2);
8010880e:	83 ec 0c             	sub    $0xc,%esp
80108811:	6a 02                	push   $0x2
80108813:	e8 a2 04 00 00       	call   80108cba <i8254_read_eeprom>
80108818:	83 c4 10             	add    $0x10,%esp
8010881b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
8010881e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108821:	a2 84 6d 19 80       	mov    %al,0x80196d84
  mac_addr[5] = data_h>>8;
80108826:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108829:	c1 e8 08             	shr    $0x8,%eax
8010882c:	a2 85 6d 19 80       	mov    %al,0x80196d85
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108831:	0f b6 05 85 6d 19 80 	movzbl 0x80196d85,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108838:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
8010883b:	0f b6 05 84 6d 19 80 	movzbl 0x80196d84,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108842:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108845:	0f b6 05 83 6d 19 80 	movzbl 0x80196d83,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010884c:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
8010884f:	0f b6 05 82 6d 19 80 	movzbl 0x80196d82,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108856:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108859:	0f b6 05 81 6d 19 80 	movzbl 0x80196d81,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108860:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108863:	0f b6 05 80 6d 19 80 	movzbl 0x80196d80,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010886a:	0f b6 c0             	movzbl %al,%eax
8010886d:	83 ec 04             	sub    $0x4,%esp
80108870:	57                   	push   %edi
80108871:	56                   	push   %esi
80108872:	53                   	push   %ebx
80108873:	51                   	push   %ecx
80108874:	52                   	push   %edx
80108875:	50                   	push   %eax
80108876:	68 18 c2 10 80       	push   $0x8010c218
8010887b:	e8 74 7b ff ff       	call   801003f4 <cprintf>
80108880:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108883:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108888:	05 00 54 00 00       	add    $0x5400,%eax
8010888d:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108890:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108895:	05 04 54 00 00       	add    $0x5404,%eax
8010889a:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
8010889d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801088a0:	c1 e0 10             	shl    $0x10,%eax
801088a3:	0b 45 d8             	or     -0x28(%ebp),%eax
801088a6:	89 c2                	mov    %eax,%edx
801088a8:	8b 45 cc             	mov    -0x34(%ebp),%eax
801088ab:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
801088ad:	8b 45 d0             	mov    -0x30(%ebp),%eax
801088b0:	0d 00 00 00 80       	or     $0x80000000,%eax
801088b5:	89 c2                	mov    %eax,%edx
801088b7:	8b 45 c8             	mov    -0x38(%ebp),%eax
801088ba:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
801088bc:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801088c1:	05 00 52 00 00       	add    $0x5200,%eax
801088c6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
801088c9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801088d0:	eb 19                	jmp    801088eb <i8254_init_recv+0x12c>
    mta[i] = 0;
801088d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801088d5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801088dc:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801088df:	01 d0                	add    %edx,%eax
801088e1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
801088e7:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801088eb:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
801088ef:	7e e1                	jle    801088d2 <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
801088f1:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801088f6:	05 d0 00 00 00       	add    $0xd0,%eax
801088fb:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
801088fe:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108901:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108907:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
8010890c:	05 c8 00 00 00       	add    $0xc8,%eax
80108911:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108914:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108917:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
8010891d:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108922:	05 28 28 00 00       	add    $0x2828,%eax
80108927:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
8010892a:	8b 45 b8             	mov    -0x48(%ebp),%eax
8010892d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108933:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108938:	05 00 01 00 00       	add    $0x100,%eax
8010893d:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108940:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108943:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108949:	e8 3f 9e ff ff       	call   8010278d <kalloc>
8010894e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108951:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108956:	05 00 28 00 00       	add    $0x2800,%eax
8010895b:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
8010895e:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108963:	05 04 28 00 00       	add    $0x2804,%eax
80108968:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
8010896b:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108970:	05 08 28 00 00       	add    $0x2808,%eax
80108975:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108978:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
8010897d:	05 10 28 00 00       	add    $0x2810,%eax
80108982:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108985:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
8010898a:	05 18 28 00 00       	add    $0x2818,%eax
8010898f:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108992:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108995:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010899b:	8b 45 ac             	mov    -0x54(%ebp),%eax
8010899e:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
801089a0:	8b 45 a8             	mov    -0x58(%ebp),%eax
801089a3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
801089a9:	8b 45 a4             	mov    -0x5c(%ebp),%eax
801089ac:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
801089b2:	8b 45 a0             	mov    -0x60(%ebp),%eax
801089b5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
801089bb:	8b 45 9c             	mov    -0x64(%ebp),%eax
801089be:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
801089c4:	8b 45 b0             	mov    -0x50(%ebp),%eax
801089c7:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
801089ca:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801089d1:	eb 73                	jmp    80108a46 <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
801089d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801089d6:	c1 e0 04             	shl    $0x4,%eax
801089d9:	89 c2                	mov    %eax,%edx
801089db:	8b 45 98             	mov    -0x68(%ebp),%eax
801089de:	01 d0                	add    %edx,%eax
801089e0:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
801089e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801089ea:	c1 e0 04             	shl    $0x4,%eax
801089ed:	89 c2                	mov    %eax,%edx
801089ef:	8b 45 98             	mov    -0x68(%ebp),%eax
801089f2:	01 d0                	add    %edx,%eax
801089f4:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
801089fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
801089fd:	c1 e0 04             	shl    $0x4,%eax
80108a00:	89 c2                	mov    %eax,%edx
80108a02:	8b 45 98             	mov    -0x68(%ebp),%eax
80108a05:	01 d0                	add    %edx,%eax
80108a07:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108a0d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108a10:	c1 e0 04             	shl    $0x4,%eax
80108a13:	89 c2                	mov    %eax,%edx
80108a15:	8b 45 98             	mov    -0x68(%ebp),%eax
80108a18:	01 d0                	add    %edx,%eax
80108a1a:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108a1e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108a21:	c1 e0 04             	shl    $0x4,%eax
80108a24:	89 c2                	mov    %eax,%edx
80108a26:	8b 45 98             	mov    -0x68(%ebp),%eax
80108a29:	01 d0                	add    %edx,%eax
80108a2b:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108a2f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108a32:	c1 e0 04             	shl    $0x4,%eax
80108a35:	89 c2                	mov    %eax,%edx
80108a37:	8b 45 98             	mov    -0x68(%ebp),%eax
80108a3a:	01 d0                	add    %edx,%eax
80108a3c:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108a42:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108a46:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108a4d:	7e 84                	jle    801089d3 <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108a4f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108a56:	eb 57                	jmp    80108aaf <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
80108a58:	e8 30 9d ff ff       	call   8010278d <kalloc>
80108a5d:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108a60:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108a64:	75 12                	jne    80108a78 <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80108a66:	83 ec 0c             	sub    $0xc,%esp
80108a69:	68 38 c2 10 80       	push   $0x8010c238
80108a6e:	e8 81 79 ff ff       	call   801003f4 <cprintf>
80108a73:	83 c4 10             	add    $0x10,%esp
      break;
80108a76:	eb 3d                	jmp    80108ab5 <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108a78:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108a7b:	c1 e0 04             	shl    $0x4,%eax
80108a7e:	89 c2                	mov    %eax,%edx
80108a80:	8b 45 98             	mov    -0x68(%ebp),%eax
80108a83:	01 d0                	add    %edx,%eax
80108a85:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108a88:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108a8e:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108a90:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108a93:	83 c0 01             	add    $0x1,%eax
80108a96:	c1 e0 04             	shl    $0x4,%eax
80108a99:	89 c2                	mov    %eax,%edx
80108a9b:	8b 45 98             	mov    -0x68(%ebp),%eax
80108a9e:	01 d0                	add    %edx,%eax
80108aa0:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108aa3:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108aa9:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108aab:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108aaf:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108ab3:	7e a3                	jle    80108a58 <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
80108ab5:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108ab8:	8b 00                	mov    (%eax),%eax
80108aba:	83 c8 02             	or     $0x2,%eax
80108abd:	89 c2                	mov    %eax,%edx
80108abf:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108ac2:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108ac4:	83 ec 0c             	sub    $0xc,%esp
80108ac7:	68 58 c2 10 80       	push   $0x8010c258
80108acc:	e8 23 79 ff ff       	call   801003f4 <cprintf>
80108ad1:	83 c4 10             	add    $0x10,%esp
}
80108ad4:	90                   	nop
80108ad5:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108ad8:	5b                   	pop    %ebx
80108ad9:	5e                   	pop    %esi
80108ada:	5f                   	pop    %edi
80108adb:	5d                   	pop    %ebp
80108adc:	c3                   	ret    

80108add <i8254_init_send>:

void i8254_init_send(){
80108add:	55                   	push   %ebp
80108ade:	89 e5                	mov    %esp,%ebp
80108ae0:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108ae3:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108ae8:	05 28 38 00 00       	add    $0x3828,%eax
80108aed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108af0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108af3:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108af9:	e8 8f 9c ff ff       	call   8010278d <kalloc>
80108afe:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108b01:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108b06:	05 00 38 00 00       	add    $0x3800,%eax
80108b0b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108b0e:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108b13:	05 04 38 00 00       	add    $0x3804,%eax
80108b18:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108b1b:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108b20:	05 08 38 00 00       	add    $0x3808,%eax
80108b25:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108b28:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b2b:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108b31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108b34:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108b36:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b39:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108b3f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108b42:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108b48:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108b4d:	05 10 38 00 00       	add    $0x3810,%eax
80108b52:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108b55:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108b5a:	05 18 38 00 00       	add    $0x3818,%eax
80108b5f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108b62:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108b65:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108b6b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108b6e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108b74:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b77:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108b7a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108b81:	e9 82 00 00 00       	jmp    80108c08 <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80108b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b89:	c1 e0 04             	shl    $0x4,%eax
80108b8c:	89 c2                	mov    %eax,%edx
80108b8e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b91:	01 d0                	add    %edx,%eax
80108b93:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108b9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b9d:	c1 e0 04             	shl    $0x4,%eax
80108ba0:	89 c2                	mov    %eax,%edx
80108ba2:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ba5:	01 d0                	add    %edx,%eax
80108ba7:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108bad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bb0:	c1 e0 04             	shl    $0x4,%eax
80108bb3:	89 c2                	mov    %eax,%edx
80108bb5:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108bb8:	01 d0                	add    %edx,%eax
80108bba:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bc1:	c1 e0 04             	shl    $0x4,%eax
80108bc4:	89 c2                	mov    %eax,%edx
80108bc6:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108bc9:	01 d0                	add    %edx,%eax
80108bcb:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bd2:	c1 e0 04             	shl    $0x4,%eax
80108bd5:	89 c2                	mov    %eax,%edx
80108bd7:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108bda:	01 d0                	add    %edx,%eax
80108bdc:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108be0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108be3:	c1 e0 04             	shl    $0x4,%eax
80108be6:	89 c2                	mov    %eax,%edx
80108be8:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108beb:	01 d0                	add    %edx,%eax
80108bed:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108bf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bf4:	c1 e0 04             	shl    $0x4,%eax
80108bf7:	89 c2                	mov    %eax,%edx
80108bf9:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108bfc:	01 d0                	add    %edx,%eax
80108bfe:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108c04:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108c08:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108c0f:	0f 8e 71 ff ff ff    	jle    80108b86 <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108c15:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108c1c:	eb 57                	jmp    80108c75 <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
80108c1e:	e8 6a 9b ff ff       	call   8010278d <kalloc>
80108c23:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108c26:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108c2a:	75 12                	jne    80108c3e <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
80108c2c:	83 ec 0c             	sub    $0xc,%esp
80108c2f:	68 38 c2 10 80       	push   $0x8010c238
80108c34:	e8 bb 77 ff ff       	call   801003f4 <cprintf>
80108c39:	83 c4 10             	add    $0x10,%esp
      break;
80108c3c:	eb 3d                	jmp    80108c7b <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108c3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c41:	c1 e0 04             	shl    $0x4,%eax
80108c44:	89 c2                	mov    %eax,%edx
80108c46:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c49:	01 d0                	add    %edx,%eax
80108c4b:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108c4e:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108c54:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108c56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c59:	83 c0 01             	add    $0x1,%eax
80108c5c:	c1 e0 04             	shl    $0x4,%eax
80108c5f:	89 c2                	mov    %eax,%edx
80108c61:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c64:	01 d0                	add    %edx,%eax
80108c66:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108c69:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108c6f:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108c71:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108c75:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108c79:	7e a3                	jle    80108c1e <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108c7b:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108c80:	05 00 04 00 00       	add    $0x400,%eax
80108c85:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108c88:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108c8b:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108c91:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108c96:	05 10 04 00 00       	add    $0x410,%eax
80108c9b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108c9e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108ca1:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108ca7:	83 ec 0c             	sub    $0xc,%esp
80108caa:	68 78 c2 10 80       	push   $0x8010c278
80108caf:	e8 40 77 ff ff       	call   801003f4 <cprintf>
80108cb4:	83 c4 10             	add    $0x10,%esp

}
80108cb7:	90                   	nop
80108cb8:	c9                   	leave  
80108cb9:	c3                   	ret    

80108cba <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108cba:	55                   	push   %ebp
80108cbb:	89 e5                	mov    %esp,%ebp
80108cbd:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108cc0:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108cc5:	83 c0 14             	add    $0x14,%eax
80108cc8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108ccb:	8b 45 08             	mov    0x8(%ebp),%eax
80108cce:	c1 e0 08             	shl    $0x8,%eax
80108cd1:	0f b7 c0             	movzwl %ax,%eax
80108cd4:	83 c8 01             	or     $0x1,%eax
80108cd7:	89 c2                	mov    %eax,%edx
80108cd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cdc:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108cde:	83 ec 0c             	sub    $0xc,%esp
80108ce1:	68 98 c2 10 80       	push   $0x8010c298
80108ce6:	e8 09 77 ff ff       	call   801003f4 <cprintf>
80108ceb:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cf1:	8b 00                	mov    (%eax),%eax
80108cf3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80108cf6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cf9:	83 e0 10             	and    $0x10,%eax
80108cfc:	85 c0                	test   %eax,%eax
80108cfe:	75 02                	jne    80108d02 <i8254_read_eeprom+0x48>
  while(1){
80108d00:	eb dc                	jmp    80108cde <i8254_read_eeprom+0x24>
      break;
80108d02:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108d03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d06:	8b 00                	mov    (%eax),%eax
80108d08:	c1 e8 10             	shr    $0x10,%eax
}
80108d0b:	c9                   	leave  
80108d0c:	c3                   	ret    

80108d0d <i8254_recv>:
void i8254_recv(){
80108d0d:	55                   	push   %ebp
80108d0e:	89 e5                	mov    %esp,%ebp
80108d10:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108d13:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108d18:	05 10 28 00 00       	add    $0x2810,%eax
80108d1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108d20:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108d25:	05 18 28 00 00       	add    $0x2818,%eax
80108d2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108d2d:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108d32:	05 00 28 00 00       	add    $0x2800,%eax
80108d37:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108d3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d3d:	8b 00                	mov    (%eax),%eax
80108d3f:	05 00 00 00 80       	add    $0x80000000,%eax
80108d44:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108d47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d4a:	8b 10                	mov    (%eax),%edx
80108d4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d4f:	8b 08                	mov    (%eax),%ecx
80108d51:	89 d0                	mov    %edx,%eax
80108d53:	29 c8                	sub    %ecx,%eax
80108d55:	25 ff 00 00 00       	and    $0xff,%eax
80108d5a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108d5d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108d61:	7e 37                	jle    80108d9a <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108d63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d66:	8b 00                	mov    (%eax),%eax
80108d68:	c1 e0 04             	shl    $0x4,%eax
80108d6b:	89 c2                	mov    %eax,%edx
80108d6d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d70:	01 d0                	add    %edx,%eax
80108d72:	8b 00                	mov    (%eax),%eax
80108d74:	05 00 00 00 80       	add    $0x80000000,%eax
80108d79:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108d7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d7f:	8b 00                	mov    (%eax),%eax
80108d81:	83 c0 01             	add    $0x1,%eax
80108d84:	0f b6 d0             	movzbl %al,%edx
80108d87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d8a:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80108d8c:	83 ec 0c             	sub    $0xc,%esp
80108d8f:	ff 75 e0             	push   -0x20(%ebp)
80108d92:	e8 15 09 00 00       	call   801096ac <eth_proc>
80108d97:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80108d9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d9d:	8b 10                	mov    (%eax),%edx
80108d9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108da2:	8b 00                	mov    (%eax),%eax
80108da4:	39 c2                	cmp    %eax,%edx
80108da6:	75 9f                	jne    80108d47 <i8254_recv+0x3a>
      (*rdt)--;
80108da8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108dab:	8b 00                	mov    (%eax),%eax
80108dad:	8d 50 ff             	lea    -0x1(%eax),%edx
80108db0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108db3:	89 10                	mov    %edx,(%eax)
  while(1){
80108db5:	eb 90                	jmp    80108d47 <i8254_recv+0x3a>

80108db7 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80108db7:	55                   	push   %ebp
80108db8:	89 e5                	mov    %esp,%ebp
80108dba:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80108dbd:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108dc2:	05 10 38 00 00       	add    $0x3810,%eax
80108dc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108dca:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108dcf:	05 18 38 00 00       	add    $0x3818,%eax
80108dd4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108dd7:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108ddc:	05 00 38 00 00       	add    $0x3800,%eax
80108de1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80108de4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108de7:	8b 00                	mov    (%eax),%eax
80108de9:	05 00 00 00 80       	add    $0x80000000,%eax
80108dee:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80108df1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108df4:	8b 10                	mov    (%eax),%edx
80108df6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108df9:	8b 08                	mov    (%eax),%ecx
80108dfb:	89 d0                	mov    %edx,%eax
80108dfd:	29 c8                	sub    %ecx,%eax
80108dff:	0f b6 d0             	movzbl %al,%edx
80108e02:	b8 00 01 00 00       	mov    $0x100,%eax
80108e07:	29 d0                	sub    %edx,%eax
80108e09:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80108e0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e0f:	8b 00                	mov    (%eax),%eax
80108e11:	25 ff 00 00 00       	and    $0xff,%eax
80108e16:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80108e19:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108e1d:	0f 8e a8 00 00 00    	jle    80108ecb <i8254_send+0x114>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80108e23:	8b 45 08             	mov    0x8(%ebp),%eax
80108e26:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108e29:	89 d1                	mov    %edx,%ecx
80108e2b:	c1 e1 04             	shl    $0x4,%ecx
80108e2e:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108e31:	01 ca                	add    %ecx,%edx
80108e33:	8b 12                	mov    (%edx),%edx
80108e35:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108e3b:	83 ec 04             	sub    $0x4,%esp
80108e3e:	ff 75 0c             	push   0xc(%ebp)
80108e41:	50                   	push   %eax
80108e42:	52                   	push   %edx
80108e43:	e8 88 bd ff ff       	call   80104bd0 <memmove>
80108e48:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80108e4b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e4e:	c1 e0 04             	shl    $0x4,%eax
80108e51:	89 c2                	mov    %eax,%edx
80108e53:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e56:	01 d0                	add    %edx,%eax
80108e58:	8b 55 0c             	mov    0xc(%ebp),%edx
80108e5b:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80108e5f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e62:	c1 e0 04             	shl    $0x4,%eax
80108e65:	89 c2                	mov    %eax,%edx
80108e67:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e6a:	01 d0                	add    %edx,%eax
80108e6c:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80108e70:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e73:	c1 e0 04             	shl    $0x4,%eax
80108e76:	89 c2                	mov    %eax,%edx
80108e78:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e7b:	01 d0                	add    %edx,%eax
80108e7d:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80108e81:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e84:	c1 e0 04             	shl    $0x4,%eax
80108e87:	89 c2                	mov    %eax,%edx
80108e89:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e8c:	01 d0                	add    %edx,%eax
80108e8e:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80108e92:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e95:	c1 e0 04             	shl    $0x4,%eax
80108e98:	89 c2                	mov    %eax,%edx
80108e9a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e9d:	01 d0                	add    %edx,%eax
80108e9f:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80108ea5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ea8:	c1 e0 04             	shl    $0x4,%eax
80108eab:	89 c2                	mov    %eax,%edx
80108ead:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108eb0:	01 d0                	add    %edx,%eax
80108eb2:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80108eb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108eb9:	8b 00                	mov    (%eax),%eax
80108ebb:	83 c0 01             	add    $0x1,%eax
80108ebe:	0f b6 d0             	movzbl %al,%edx
80108ec1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ec4:	89 10                	mov    %edx,(%eax)
    return len;
80108ec6:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ec9:	eb 05                	jmp    80108ed0 <i8254_send+0x119>
  }else{
    return -1;
80108ecb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80108ed0:	c9                   	leave  
80108ed1:	c3                   	ret    

80108ed2 <i8254_intr>:

void i8254_intr(){
80108ed2:	55                   	push   %ebp
80108ed3:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80108ed5:	a1 88 6d 19 80       	mov    0x80196d88,%eax
80108eda:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80108ee0:	90                   	nop
80108ee1:	5d                   	pop    %ebp
80108ee2:	c3                   	ret    

80108ee3 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80108ee3:	55                   	push   %ebp
80108ee4:	89 e5                	mov    %esp,%ebp
80108ee6:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80108ee9:	8b 45 08             	mov    0x8(%ebp),%eax
80108eec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80108eef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ef2:	0f b7 00             	movzwl (%eax),%eax
80108ef5:	66 3d 00 01          	cmp    $0x100,%ax
80108ef9:	74 0a                	je     80108f05 <arp_proc+0x22>
80108efb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108f00:	e9 4f 01 00 00       	jmp    80109054 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80108f05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f08:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80108f0c:	66 83 f8 08          	cmp    $0x8,%ax
80108f10:	74 0a                	je     80108f1c <arp_proc+0x39>
80108f12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108f17:	e9 38 01 00 00       	jmp    80109054 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
80108f1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f1f:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80108f23:	3c 06                	cmp    $0x6,%al
80108f25:	74 0a                	je     80108f31 <arp_proc+0x4e>
80108f27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108f2c:	e9 23 01 00 00       	jmp    80109054 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80108f31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f34:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80108f38:	3c 04                	cmp    $0x4,%al
80108f3a:	74 0a                	je     80108f46 <arp_proc+0x63>
80108f3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108f41:	e9 0e 01 00 00       	jmp    80109054 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80108f46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f49:	83 c0 18             	add    $0x18,%eax
80108f4c:	83 ec 04             	sub    $0x4,%esp
80108f4f:	6a 04                	push   $0x4
80108f51:	50                   	push   %eax
80108f52:	68 e4 f4 10 80       	push   $0x8010f4e4
80108f57:	e8 1c bc ff ff       	call   80104b78 <memcmp>
80108f5c:	83 c4 10             	add    $0x10,%esp
80108f5f:	85 c0                	test   %eax,%eax
80108f61:	74 27                	je     80108f8a <arp_proc+0xa7>
80108f63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f66:	83 c0 0e             	add    $0xe,%eax
80108f69:	83 ec 04             	sub    $0x4,%esp
80108f6c:	6a 04                	push   $0x4
80108f6e:	50                   	push   %eax
80108f6f:	68 e4 f4 10 80       	push   $0x8010f4e4
80108f74:	e8 ff bb ff ff       	call   80104b78 <memcmp>
80108f79:	83 c4 10             	add    $0x10,%esp
80108f7c:	85 c0                	test   %eax,%eax
80108f7e:	74 0a                	je     80108f8a <arp_proc+0xa7>
80108f80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108f85:	e9 ca 00 00 00       	jmp    80109054 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108f8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f8d:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108f91:	66 3d 00 01          	cmp    $0x100,%ax
80108f95:	75 69                	jne    80109000 <arp_proc+0x11d>
80108f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f9a:	83 c0 18             	add    $0x18,%eax
80108f9d:	83 ec 04             	sub    $0x4,%esp
80108fa0:	6a 04                	push   $0x4
80108fa2:	50                   	push   %eax
80108fa3:	68 e4 f4 10 80       	push   $0x8010f4e4
80108fa8:	e8 cb bb ff ff       	call   80104b78 <memcmp>
80108fad:	83 c4 10             	add    $0x10,%esp
80108fb0:	85 c0                	test   %eax,%eax
80108fb2:	75 4c                	jne    80109000 <arp_proc+0x11d>
    uint send = (uint)kalloc();
80108fb4:	e8 d4 97 ff ff       	call   8010278d <kalloc>
80108fb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80108fbc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80108fc3:	83 ec 04             	sub    $0x4,%esp
80108fc6:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108fc9:	50                   	push   %eax
80108fca:	ff 75 f0             	push   -0x10(%ebp)
80108fcd:	ff 75 f4             	push   -0xc(%ebp)
80108fd0:	e8 1f 04 00 00       	call   801093f4 <arp_reply_pkt_create>
80108fd5:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80108fd8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fdb:	83 ec 08             	sub    $0x8,%esp
80108fde:	50                   	push   %eax
80108fdf:	ff 75 f0             	push   -0x10(%ebp)
80108fe2:	e8 d0 fd ff ff       	call   80108db7 <i8254_send>
80108fe7:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
80108fea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fed:	83 ec 0c             	sub    $0xc,%esp
80108ff0:	50                   	push   %eax
80108ff1:	e8 fd 96 ff ff       	call   801026f3 <kfree>
80108ff6:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
80108ff9:	b8 02 00 00 00       	mov    $0x2,%eax
80108ffe:	eb 54                	jmp    80109054 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109000:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109003:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109007:	66 3d 00 02          	cmp    $0x200,%ax
8010900b:	75 42                	jne    8010904f <arp_proc+0x16c>
8010900d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109010:	83 c0 18             	add    $0x18,%eax
80109013:	83 ec 04             	sub    $0x4,%esp
80109016:	6a 04                	push   $0x4
80109018:	50                   	push   %eax
80109019:	68 e4 f4 10 80       	push   $0x8010f4e4
8010901e:	e8 55 bb ff ff       	call   80104b78 <memcmp>
80109023:	83 c4 10             	add    $0x10,%esp
80109026:	85 c0                	test   %eax,%eax
80109028:	75 25                	jne    8010904f <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
8010902a:	83 ec 0c             	sub    $0xc,%esp
8010902d:	68 9c c2 10 80       	push   $0x8010c29c
80109032:	e8 bd 73 ff ff       	call   801003f4 <cprintf>
80109037:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
8010903a:	83 ec 0c             	sub    $0xc,%esp
8010903d:	ff 75 f4             	push   -0xc(%ebp)
80109040:	e8 af 01 00 00       	call   801091f4 <arp_table_update>
80109045:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80109048:	b8 01 00 00 00       	mov    $0x1,%eax
8010904d:	eb 05                	jmp    80109054 <arp_proc+0x171>
  }else{
    return -1;
8010904f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80109054:	c9                   	leave  
80109055:	c3                   	ret    

80109056 <arp_scan>:

void arp_scan(){
80109056:	55                   	push   %ebp
80109057:	89 e5                	mov    %esp,%ebp
80109059:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
8010905c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109063:	eb 6f                	jmp    801090d4 <arp_scan+0x7e>
    uint send = (uint)kalloc();
80109065:	e8 23 97 ff ff       	call   8010278d <kalloc>
8010906a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
8010906d:	83 ec 04             	sub    $0x4,%esp
80109070:	ff 75 f4             	push   -0xc(%ebp)
80109073:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109076:	50                   	push   %eax
80109077:	ff 75 ec             	push   -0x14(%ebp)
8010907a:	e8 62 00 00 00       	call   801090e1 <arp_broadcast>
8010907f:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80109082:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109085:	83 ec 08             	sub    $0x8,%esp
80109088:	50                   	push   %eax
80109089:	ff 75 ec             	push   -0x14(%ebp)
8010908c:	e8 26 fd ff ff       	call   80108db7 <i8254_send>
80109091:	83 c4 10             	add    $0x10,%esp
80109094:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109097:	eb 22                	jmp    801090bb <arp_scan+0x65>
      microdelay(1);
80109099:	83 ec 0c             	sub    $0xc,%esp
8010909c:	6a 01                	push   $0x1
8010909e:	e8 81 9a ff ff       	call   80102b24 <microdelay>
801090a3:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
801090a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090a9:	83 ec 08             	sub    $0x8,%esp
801090ac:	50                   	push   %eax
801090ad:	ff 75 ec             	push   -0x14(%ebp)
801090b0:	e8 02 fd ff ff       	call   80108db7 <i8254_send>
801090b5:	83 c4 10             	add    $0x10,%esp
801090b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
801090bb:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
801090bf:	74 d8                	je     80109099 <arp_scan+0x43>
    }
    kfree((char *)send);
801090c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090c4:	83 ec 0c             	sub    $0xc,%esp
801090c7:	50                   	push   %eax
801090c8:	e8 26 96 ff ff       	call   801026f3 <kfree>
801090cd:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
801090d0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801090d4:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801090db:	7e 88                	jle    80109065 <arp_scan+0xf>
  }
}
801090dd:	90                   	nop
801090de:	90                   	nop
801090df:	c9                   	leave  
801090e0:	c3                   	ret    

801090e1 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
801090e1:	55                   	push   %ebp
801090e2:	89 e5                	mov    %esp,%ebp
801090e4:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
801090e7:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
801090eb:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
801090ef:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
801090f3:	8b 45 10             	mov    0x10(%ebp),%eax
801090f6:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
801090f9:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80109100:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80109106:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
8010910d:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109113:	8b 45 0c             	mov    0xc(%ebp),%eax
80109116:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
8010911c:	8b 45 08             	mov    0x8(%ebp),%eax
8010911f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109122:	8b 45 08             	mov    0x8(%ebp),%eax
80109125:	83 c0 0e             	add    $0xe,%eax
80109128:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
8010912b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010912e:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109135:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80109139:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010913c:	83 ec 04             	sub    $0x4,%esp
8010913f:	6a 06                	push   $0x6
80109141:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80109144:	52                   	push   %edx
80109145:	50                   	push   %eax
80109146:	e8 85 ba ff ff       	call   80104bd0 <memmove>
8010914b:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
8010914e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109151:	83 c0 06             	add    $0x6,%eax
80109154:	83 ec 04             	sub    $0x4,%esp
80109157:	6a 06                	push   $0x6
80109159:	68 80 6d 19 80       	push   $0x80196d80
8010915e:	50                   	push   %eax
8010915f:	e8 6c ba ff ff       	call   80104bd0 <memmove>
80109164:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109167:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010916a:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
8010916f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109172:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109178:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010917b:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
8010917f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109182:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80109186:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109189:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
8010918f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109192:	8d 50 12             	lea    0x12(%eax),%edx
80109195:	83 ec 04             	sub    $0x4,%esp
80109198:	6a 06                	push   $0x6
8010919a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010919d:	50                   	push   %eax
8010919e:	52                   	push   %edx
8010919f:	e8 2c ba ff ff       	call   80104bd0 <memmove>
801091a4:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
801091a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091aa:	8d 50 18             	lea    0x18(%eax),%edx
801091ad:	83 ec 04             	sub    $0x4,%esp
801091b0:	6a 04                	push   $0x4
801091b2:	8d 45 ec             	lea    -0x14(%ebp),%eax
801091b5:	50                   	push   %eax
801091b6:	52                   	push   %edx
801091b7:	e8 14 ba ff ff       	call   80104bd0 <memmove>
801091bc:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801091bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091c2:	83 c0 08             	add    $0x8,%eax
801091c5:	83 ec 04             	sub    $0x4,%esp
801091c8:	6a 06                	push   $0x6
801091ca:	68 80 6d 19 80       	push   $0x80196d80
801091cf:	50                   	push   %eax
801091d0:	e8 fb b9 ff ff       	call   80104bd0 <memmove>
801091d5:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801091d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091db:	83 c0 0e             	add    $0xe,%eax
801091de:	83 ec 04             	sub    $0x4,%esp
801091e1:	6a 04                	push   $0x4
801091e3:	68 e4 f4 10 80       	push   $0x8010f4e4
801091e8:	50                   	push   %eax
801091e9:	e8 e2 b9 ff ff       	call   80104bd0 <memmove>
801091ee:	83 c4 10             	add    $0x10,%esp
}
801091f1:	90                   	nop
801091f2:	c9                   	leave  
801091f3:	c3                   	ret    

801091f4 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
801091f4:	55                   	push   %ebp
801091f5:	89 e5                	mov    %esp,%ebp
801091f7:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
801091fa:	8b 45 08             	mov    0x8(%ebp),%eax
801091fd:	83 c0 0e             	add    $0xe,%eax
80109200:	83 ec 0c             	sub    $0xc,%esp
80109203:	50                   	push   %eax
80109204:	e8 bc 00 00 00       	call   801092c5 <arp_table_search>
80109209:	83 c4 10             	add    $0x10,%esp
8010920c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
8010920f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109213:	78 2d                	js     80109242 <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109215:	8b 45 08             	mov    0x8(%ebp),%eax
80109218:	8d 48 08             	lea    0x8(%eax),%ecx
8010921b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010921e:	89 d0                	mov    %edx,%eax
80109220:	c1 e0 02             	shl    $0x2,%eax
80109223:	01 d0                	add    %edx,%eax
80109225:	01 c0                	add    %eax,%eax
80109227:	01 d0                	add    %edx,%eax
80109229:	05 a0 6d 19 80       	add    $0x80196da0,%eax
8010922e:	83 c0 04             	add    $0x4,%eax
80109231:	83 ec 04             	sub    $0x4,%esp
80109234:	6a 06                	push   $0x6
80109236:	51                   	push   %ecx
80109237:	50                   	push   %eax
80109238:	e8 93 b9 ff ff       	call   80104bd0 <memmove>
8010923d:	83 c4 10             	add    $0x10,%esp
80109240:	eb 70                	jmp    801092b2 <arp_table_update+0xbe>
  }else{
    index += 1;
80109242:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109246:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109249:	8b 45 08             	mov    0x8(%ebp),%eax
8010924c:	8d 48 08             	lea    0x8(%eax),%ecx
8010924f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109252:	89 d0                	mov    %edx,%eax
80109254:	c1 e0 02             	shl    $0x2,%eax
80109257:	01 d0                	add    %edx,%eax
80109259:	01 c0                	add    %eax,%eax
8010925b:	01 d0                	add    %edx,%eax
8010925d:	05 a0 6d 19 80       	add    $0x80196da0,%eax
80109262:	83 c0 04             	add    $0x4,%eax
80109265:	83 ec 04             	sub    $0x4,%esp
80109268:	6a 06                	push   $0x6
8010926a:	51                   	push   %ecx
8010926b:	50                   	push   %eax
8010926c:	e8 5f b9 ff ff       	call   80104bd0 <memmove>
80109271:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109274:	8b 45 08             	mov    0x8(%ebp),%eax
80109277:	8d 48 0e             	lea    0xe(%eax),%ecx
8010927a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010927d:	89 d0                	mov    %edx,%eax
8010927f:	c1 e0 02             	shl    $0x2,%eax
80109282:	01 d0                	add    %edx,%eax
80109284:	01 c0                	add    %eax,%eax
80109286:	01 d0                	add    %edx,%eax
80109288:	05 a0 6d 19 80       	add    $0x80196da0,%eax
8010928d:	83 ec 04             	sub    $0x4,%esp
80109290:	6a 04                	push   $0x4
80109292:	51                   	push   %ecx
80109293:	50                   	push   %eax
80109294:	e8 37 b9 ff ff       	call   80104bd0 <memmove>
80109299:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
8010929c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010929f:	89 d0                	mov    %edx,%eax
801092a1:	c1 e0 02             	shl    $0x2,%eax
801092a4:	01 d0                	add    %edx,%eax
801092a6:	01 c0                	add    %eax,%eax
801092a8:	01 d0                	add    %edx,%eax
801092aa:	05 aa 6d 19 80       	add    $0x80196daa,%eax
801092af:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
801092b2:	83 ec 0c             	sub    $0xc,%esp
801092b5:	68 a0 6d 19 80       	push   $0x80196da0
801092ba:	e8 83 00 00 00       	call   80109342 <print_arp_table>
801092bf:	83 c4 10             	add    $0x10,%esp
}
801092c2:	90                   	nop
801092c3:	c9                   	leave  
801092c4:	c3                   	ret    

801092c5 <arp_table_search>:

int arp_table_search(uchar *ip){
801092c5:	55                   	push   %ebp
801092c6:	89 e5                	mov    %esp,%ebp
801092c8:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
801092cb:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801092d2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801092d9:	eb 59                	jmp    80109334 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
801092db:	8b 55 f0             	mov    -0x10(%ebp),%edx
801092de:	89 d0                	mov    %edx,%eax
801092e0:	c1 e0 02             	shl    $0x2,%eax
801092e3:	01 d0                	add    %edx,%eax
801092e5:	01 c0                	add    %eax,%eax
801092e7:	01 d0                	add    %edx,%eax
801092e9:	05 a0 6d 19 80       	add    $0x80196da0,%eax
801092ee:	83 ec 04             	sub    $0x4,%esp
801092f1:	6a 04                	push   $0x4
801092f3:	ff 75 08             	push   0x8(%ebp)
801092f6:	50                   	push   %eax
801092f7:	e8 7c b8 ff ff       	call   80104b78 <memcmp>
801092fc:	83 c4 10             	add    $0x10,%esp
801092ff:	85 c0                	test   %eax,%eax
80109301:	75 05                	jne    80109308 <arp_table_search+0x43>
      return i;
80109303:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109306:	eb 38                	jmp    80109340 <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
80109308:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010930b:	89 d0                	mov    %edx,%eax
8010930d:	c1 e0 02             	shl    $0x2,%eax
80109310:	01 d0                	add    %edx,%eax
80109312:	01 c0                	add    %eax,%eax
80109314:	01 d0                	add    %edx,%eax
80109316:	05 aa 6d 19 80       	add    $0x80196daa,%eax
8010931b:	0f b6 00             	movzbl (%eax),%eax
8010931e:	84 c0                	test   %al,%al
80109320:	75 0e                	jne    80109330 <arp_table_search+0x6b>
80109322:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109326:	75 08                	jne    80109330 <arp_table_search+0x6b>
      empty = -i;
80109328:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010932b:	f7 d8                	neg    %eax
8010932d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109330:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109334:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80109338:	7e a1                	jle    801092db <arp_table_search+0x16>
    }
  }
  return empty-1;
8010933a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010933d:	83 e8 01             	sub    $0x1,%eax
}
80109340:	c9                   	leave  
80109341:	c3                   	ret    

80109342 <print_arp_table>:

void print_arp_table(){
80109342:	55                   	push   %ebp
80109343:	89 e5                	mov    %esp,%ebp
80109345:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109348:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010934f:	e9 92 00 00 00       	jmp    801093e6 <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
80109354:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109357:	89 d0                	mov    %edx,%eax
80109359:	c1 e0 02             	shl    $0x2,%eax
8010935c:	01 d0                	add    %edx,%eax
8010935e:	01 c0                	add    %eax,%eax
80109360:	01 d0                	add    %edx,%eax
80109362:	05 aa 6d 19 80       	add    $0x80196daa,%eax
80109367:	0f b6 00             	movzbl (%eax),%eax
8010936a:	84 c0                	test   %al,%al
8010936c:	74 74                	je     801093e2 <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
8010936e:	83 ec 08             	sub    $0x8,%esp
80109371:	ff 75 f4             	push   -0xc(%ebp)
80109374:	68 af c2 10 80       	push   $0x8010c2af
80109379:	e8 76 70 ff ff       	call   801003f4 <cprintf>
8010937e:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109381:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109384:	89 d0                	mov    %edx,%eax
80109386:	c1 e0 02             	shl    $0x2,%eax
80109389:	01 d0                	add    %edx,%eax
8010938b:	01 c0                	add    %eax,%eax
8010938d:	01 d0                	add    %edx,%eax
8010938f:	05 a0 6d 19 80       	add    $0x80196da0,%eax
80109394:	83 ec 0c             	sub    $0xc,%esp
80109397:	50                   	push   %eax
80109398:	e8 54 02 00 00       	call   801095f1 <print_ipv4>
8010939d:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
801093a0:	83 ec 0c             	sub    $0xc,%esp
801093a3:	68 be c2 10 80       	push   $0x8010c2be
801093a8:	e8 47 70 ff ff       	call   801003f4 <cprintf>
801093ad:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
801093b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801093b3:	89 d0                	mov    %edx,%eax
801093b5:	c1 e0 02             	shl    $0x2,%eax
801093b8:	01 d0                	add    %edx,%eax
801093ba:	01 c0                	add    %eax,%eax
801093bc:	01 d0                	add    %edx,%eax
801093be:	05 a0 6d 19 80       	add    $0x80196da0,%eax
801093c3:	83 c0 04             	add    $0x4,%eax
801093c6:	83 ec 0c             	sub    $0xc,%esp
801093c9:	50                   	push   %eax
801093ca:	e8 70 02 00 00       	call   8010963f <print_mac>
801093cf:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
801093d2:	83 ec 0c             	sub    $0xc,%esp
801093d5:	68 c0 c2 10 80       	push   $0x8010c2c0
801093da:	e8 15 70 ff ff       	call   801003f4 <cprintf>
801093df:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801093e2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801093e6:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801093ea:	0f 8e 64 ff ff ff    	jle    80109354 <print_arp_table+0x12>
    }
  }
}
801093f0:	90                   	nop
801093f1:	90                   	nop
801093f2:	c9                   	leave  
801093f3:	c3                   	ret    

801093f4 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
801093f4:	55                   	push   %ebp
801093f5:	89 e5                	mov    %esp,%ebp
801093f7:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801093fa:	8b 45 10             	mov    0x10(%ebp),%eax
801093fd:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109403:	8b 45 0c             	mov    0xc(%ebp),%eax
80109406:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109409:	8b 45 0c             	mov    0xc(%ebp),%eax
8010940c:	83 c0 0e             	add    $0xe,%eax
8010940f:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109412:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109415:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109419:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010941c:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109420:	8b 45 08             	mov    0x8(%ebp),%eax
80109423:	8d 50 08             	lea    0x8(%eax),%edx
80109426:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109429:	83 ec 04             	sub    $0x4,%esp
8010942c:	6a 06                	push   $0x6
8010942e:	52                   	push   %edx
8010942f:	50                   	push   %eax
80109430:	e8 9b b7 ff ff       	call   80104bd0 <memmove>
80109435:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109438:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010943b:	83 c0 06             	add    $0x6,%eax
8010943e:	83 ec 04             	sub    $0x4,%esp
80109441:	6a 06                	push   $0x6
80109443:	68 80 6d 19 80       	push   $0x80196d80
80109448:	50                   	push   %eax
80109449:	e8 82 b7 ff ff       	call   80104bd0 <memmove>
8010944e:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109451:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109454:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109459:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010945c:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109462:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109465:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109469:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010946c:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109470:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109473:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109479:	8b 45 08             	mov    0x8(%ebp),%eax
8010947c:	8d 50 08             	lea    0x8(%eax),%edx
8010947f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109482:	83 c0 12             	add    $0x12,%eax
80109485:	83 ec 04             	sub    $0x4,%esp
80109488:	6a 06                	push   $0x6
8010948a:	52                   	push   %edx
8010948b:	50                   	push   %eax
8010948c:	e8 3f b7 ff ff       	call   80104bd0 <memmove>
80109491:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109494:	8b 45 08             	mov    0x8(%ebp),%eax
80109497:	8d 50 0e             	lea    0xe(%eax),%edx
8010949a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010949d:	83 c0 18             	add    $0x18,%eax
801094a0:	83 ec 04             	sub    $0x4,%esp
801094a3:	6a 04                	push   $0x4
801094a5:	52                   	push   %edx
801094a6:	50                   	push   %eax
801094a7:	e8 24 b7 ff ff       	call   80104bd0 <memmove>
801094ac:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801094af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094b2:	83 c0 08             	add    $0x8,%eax
801094b5:	83 ec 04             	sub    $0x4,%esp
801094b8:	6a 06                	push   $0x6
801094ba:	68 80 6d 19 80       	push   $0x80196d80
801094bf:	50                   	push   %eax
801094c0:	e8 0b b7 ff ff       	call   80104bd0 <memmove>
801094c5:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801094c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094cb:	83 c0 0e             	add    $0xe,%eax
801094ce:	83 ec 04             	sub    $0x4,%esp
801094d1:	6a 04                	push   $0x4
801094d3:	68 e4 f4 10 80       	push   $0x8010f4e4
801094d8:	50                   	push   %eax
801094d9:	e8 f2 b6 ff ff       	call   80104bd0 <memmove>
801094de:	83 c4 10             	add    $0x10,%esp
}
801094e1:	90                   	nop
801094e2:	c9                   	leave  
801094e3:	c3                   	ret    

801094e4 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
801094e4:	55                   	push   %ebp
801094e5:	89 e5                	mov    %esp,%ebp
801094e7:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
801094ea:	83 ec 0c             	sub    $0xc,%esp
801094ed:	68 c2 c2 10 80       	push   $0x8010c2c2
801094f2:	e8 fd 6e ff ff       	call   801003f4 <cprintf>
801094f7:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
801094fa:	8b 45 08             	mov    0x8(%ebp),%eax
801094fd:	83 c0 0e             	add    $0xe,%eax
80109500:	83 ec 0c             	sub    $0xc,%esp
80109503:	50                   	push   %eax
80109504:	e8 e8 00 00 00       	call   801095f1 <print_ipv4>
80109509:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010950c:	83 ec 0c             	sub    $0xc,%esp
8010950f:	68 c0 c2 10 80       	push   $0x8010c2c0
80109514:	e8 db 6e ff ff       	call   801003f4 <cprintf>
80109519:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
8010951c:	8b 45 08             	mov    0x8(%ebp),%eax
8010951f:	83 c0 08             	add    $0x8,%eax
80109522:	83 ec 0c             	sub    $0xc,%esp
80109525:	50                   	push   %eax
80109526:	e8 14 01 00 00       	call   8010963f <print_mac>
8010952b:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010952e:	83 ec 0c             	sub    $0xc,%esp
80109531:	68 c0 c2 10 80       	push   $0x8010c2c0
80109536:	e8 b9 6e ff ff       	call   801003f4 <cprintf>
8010953b:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
8010953e:	83 ec 0c             	sub    $0xc,%esp
80109541:	68 d9 c2 10 80       	push   $0x8010c2d9
80109546:	e8 a9 6e ff ff       	call   801003f4 <cprintf>
8010954b:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
8010954e:	8b 45 08             	mov    0x8(%ebp),%eax
80109551:	83 c0 18             	add    $0x18,%eax
80109554:	83 ec 0c             	sub    $0xc,%esp
80109557:	50                   	push   %eax
80109558:	e8 94 00 00 00       	call   801095f1 <print_ipv4>
8010955d:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109560:	83 ec 0c             	sub    $0xc,%esp
80109563:	68 c0 c2 10 80       	push   $0x8010c2c0
80109568:	e8 87 6e ff ff       	call   801003f4 <cprintf>
8010956d:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109570:	8b 45 08             	mov    0x8(%ebp),%eax
80109573:	83 c0 12             	add    $0x12,%eax
80109576:	83 ec 0c             	sub    $0xc,%esp
80109579:	50                   	push   %eax
8010957a:	e8 c0 00 00 00       	call   8010963f <print_mac>
8010957f:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109582:	83 ec 0c             	sub    $0xc,%esp
80109585:	68 c0 c2 10 80       	push   $0x8010c2c0
8010958a:	e8 65 6e ff ff       	call   801003f4 <cprintf>
8010958f:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109592:	83 ec 0c             	sub    $0xc,%esp
80109595:	68 f0 c2 10 80       	push   $0x8010c2f0
8010959a:	e8 55 6e ff ff       	call   801003f4 <cprintf>
8010959f:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
801095a2:	8b 45 08             	mov    0x8(%ebp),%eax
801095a5:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801095a9:	66 3d 00 01          	cmp    $0x100,%ax
801095ad:	75 12                	jne    801095c1 <print_arp_info+0xdd>
801095af:	83 ec 0c             	sub    $0xc,%esp
801095b2:	68 fc c2 10 80       	push   $0x8010c2fc
801095b7:	e8 38 6e ff ff       	call   801003f4 <cprintf>
801095bc:	83 c4 10             	add    $0x10,%esp
801095bf:	eb 1d                	jmp    801095de <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
801095c1:	8b 45 08             	mov    0x8(%ebp),%eax
801095c4:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801095c8:	66 3d 00 02          	cmp    $0x200,%ax
801095cc:	75 10                	jne    801095de <print_arp_info+0xfa>
    cprintf("Reply\n");
801095ce:	83 ec 0c             	sub    $0xc,%esp
801095d1:	68 05 c3 10 80       	push   $0x8010c305
801095d6:	e8 19 6e ff ff       	call   801003f4 <cprintf>
801095db:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
801095de:	83 ec 0c             	sub    $0xc,%esp
801095e1:	68 c0 c2 10 80       	push   $0x8010c2c0
801095e6:	e8 09 6e ff ff       	call   801003f4 <cprintf>
801095eb:	83 c4 10             	add    $0x10,%esp
}
801095ee:	90                   	nop
801095ef:	c9                   	leave  
801095f0:	c3                   	ret    

801095f1 <print_ipv4>:

void print_ipv4(uchar *ip){
801095f1:	55                   	push   %ebp
801095f2:	89 e5                	mov    %esp,%ebp
801095f4:	53                   	push   %ebx
801095f5:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
801095f8:	8b 45 08             	mov    0x8(%ebp),%eax
801095fb:	83 c0 03             	add    $0x3,%eax
801095fe:	0f b6 00             	movzbl (%eax),%eax
80109601:	0f b6 d8             	movzbl %al,%ebx
80109604:	8b 45 08             	mov    0x8(%ebp),%eax
80109607:	83 c0 02             	add    $0x2,%eax
8010960a:	0f b6 00             	movzbl (%eax),%eax
8010960d:	0f b6 c8             	movzbl %al,%ecx
80109610:	8b 45 08             	mov    0x8(%ebp),%eax
80109613:	83 c0 01             	add    $0x1,%eax
80109616:	0f b6 00             	movzbl (%eax),%eax
80109619:	0f b6 d0             	movzbl %al,%edx
8010961c:	8b 45 08             	mov    0x8(%ebp),%eax
8010961f:	0f b6 00             	movzbl (%eax),%eax
80109622:	0f b6 c0             	movzbl %al,%eax
80109625:	83 ec 0c             	sub    $0xc,%esp
80109628:	53                   	push   %ebx
80109629:	51                   	push   %ecx
8010962a:	52                   	push   %edx
8010962b:	50                   	push   %eax
8010962c:	68 0c c3 10 80       	push   $0x8010c30c
80109631:	e8 be 6d ff ff       	call   801003f4 <cprintf>
80109636:	83 c4 20             	add    $0x20,%esp
}
80109639:	90                   	nop
8010963a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010963d:	c9                   	leave  
8010963e:	c3                   	ret    

8010963f <print_mac>:

void print_mac(uchar *mac){
8010963f:	55                   	push   %ebp
80109640:	89 e5                	mov    %esp,%ebp
80109642:	57                   	push   %edi
80109643:	56                   	push   %esi
80109644:	53                   	push   %ebx
80109645:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109648:	8b 45 08             	mov    0x8(%ebp),%eax
8010964b:	83 c0 05             	add    $0x5,%eax
8010964e:	0f b6 00             	movzbl (%eax),%eax
80109651:	0f b6 f8             	movzbl %al,%edi
80109654:	8b 45 08             	mov    0x8(%ebp),%eax
80109657:	83 c0 04             	add    $0x4,%eax
8010965a:	0f b6 00             	movzbl (%eax),%eax
8010965d:	0f b6 f0             	movzbl %al,%esi
80109660:	8b 45 08             	mov    0x8(%ebp),%eax
80109663:	83 c0 03             	add    $0x3,%eax
80109666:	0f b6 00             	movzbl (%eax),%eax
80109669:	0f b6 d8             	movzbl %al,%ebx
8010966c:	8b 45 08             	mov    0x8(%ebp),%eax
8010966f:	83 c0 02             	add    $0x2,%eax
80109672:	0f b6 00             	movzbl (%eax),%eax
80109675:	0f b6 c8             	movzbl %al,%ecx
80109678:	8b 45 08             	mov    0x8(%ebp),%eax
8010967b:	83 c0 01             	add    $0x1,%eax
8010967e:	0f b6 00             	movzbl (%eax),%eax
80109681:	0f b6 d0             	movzbl %al,%edx
80109684:	8b 45 08             	mov    0x8(%ebp),%eax
80109687:	0f b6 00             	movzbl (%eax),%eax
8010968a:	0f b6 c0             	movzbl %al,%eax
8010968d:	83 ec 04             	sub    $0x4,%esp
80109690:	57                   	push   %edi
80109691:	56                   	push   %esi
80109692:	53                   	push   %ebx
80109693:	51                   	push   %ecx
80109694:	52                   	push   %edx
80109695:	50                   	push   %eax
80109696:	68 24 c3 10 80       	push   $0x8010c324
8010969b:	e8 54 6d ff ff       	call   801003f4 <cprintf>
801096a0:	83 c4 20             	add    $0x20,%esp
}
801096a3:	90                   	nop
801096a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801096a7:	5b                   	pop    %ebx
801096a8:	5e                   	pop    %esi
801096a9:	5f                   	pop    %edi
801096aa:	5d                   	pop    %ebp
801096ab:	c3                   	ret    

801096ac <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
801096ac:	55                   	push   %ebp
801096ad:	89 e5                	mov    %esp,%ebp
801096af:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
801096b2:	8b 45 08             	mov    0x8(%ebp),%eax
801096b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
801096b8:	8b 45 08             	mov    0x8(%ebp),%eax
801096bb:	83 c0 0e             	add    $0xe,%eax
801096be:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
801096c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096c4:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801096c8:	3c 08                	cmp    $0x8,%al
801096ca:	75 1b                	jne    801096e7 <eth_proc+0x3b>
801096cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096cf:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801096d3:	3c 06                	cmp    $0x6,%al
801096d5:	75 10                	jne    801096e7 <eth_proc+0x3b>
    arp_proc(pkt_addr);
801096d7:	83 ec 0c             	sub    $0xc,%esp
801096da:	ff 75 f0             	push   -0x10(%ebp)
801096dd:	e8 01 f8 ff ff       	call   80108ee3 <arp_proc>
801096e2:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
801096e5:	eb 24                	jmp    8010970b <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
801096e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096ea:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801096ee:	3c 08                	cmp    $0x8,%al
801096f0:	75 19                	jne    8010970b <eth_proc+0x5f>
801096f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096f5:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801096f9:	84 c0                	test   %al,%al
801096fb:	75 0e                	jne    8010970b <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
801096fd:	83 ec 0c             	sub    $0xc,%esp
80109700:	ff 75 08             	push   0x8(%ebp)
80109703:	e8 a3 00 00 00       	call   801097ab <ipv4_proc>
80109708:	83 c4 10             	add    $0x10,%esp
}
8010970b:	90                   	nop
8010970c:	c9                   	leave  
8010970d:	c3                   	ret    

8010970e <N2H_ushort>:

ushort N2H_ushort(ushort value){
8010970e:	55                   	push   %ebp
8010970f:	89 e5                	mov    %esp,%ebp
80109711:	83 ec 04             	sub    $0x4,%esp
80109714:	8b 45 08             	mov    0x8(%ebp),%eax
80109717:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
8010971b:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010971f:	c1 e0 08             	shl    $0x8,%eax
80109722:	89 c2                	mov    %eax,%edx
80109724:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109728:	66 c1 e8 08          	shr    $0x8,%ax
8010972c:	01 d0                	add    %edx,%eax
}
8010972e:	c9                   	leave  
8010972f:	c3                   	ret    

80109730 <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109730:	55                   	push   %ebp
80109731:	89 e5                	mov    %esp,%ebp
80109733:	83 ec 04             	sub    $0x4,%esp
80109736:	8b 45 08             	mov    0x8(%ebp),%eax
80109739:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
8010973d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109741:	c1 e0 08             	shl    $0x8,%eax
80109744:	89 c2                	mov    %eax,%edx
80109746:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010974a:	66 c1 e8 08          	shr    $0x8,%ax
8010974e:	01 d0                	add    %edx,%eax
}
80109750:	c9                   	leave  
80109751:	c3                   	ret    

80109752 <H2N_uint>:

uint H2N_uint(uint value){
80109752:	55                   	push   %ebp
80109753:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109755:	8b 45 08             	mov    0x8(%ebp),%eax
80109758:	c1 e0 18             	shl    $0x18,%eax
8010975b:	25 00 00 00 0f       	and    $0xf000000,%eax
80109760:	89 c2                	mov    %eax,%edx
80109762:	8b 45 08             	mov    0x8(%ebp),%eax
80109765:	c1 e0 08             	shl    $0x8,%eax
80109768:	25 00 f0 00 00       	and    $0xf000,%eax
8010976d:	09 c2                	or     %eax,%edx
8010976f:	8b 45 08             	mov    0x8(%ebp),%eax
80109772:	c1 e8 08             	shr    $0x8,%eax
80109775:	83 e0 0f             	and    $0xf,%eax
80109778:	01 d0                	add    %edx,%eax
}
8010977a:	5d                   	pop    %ebp
8010977b:	c3                   	ret    

8010977c <N2H_uint>:

uint N2H_uint(uint value){
8010977c:	55                   	push   %ebp
8010977d:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
8010977f:	8b 45 08             	mov    0x8(%ebp),%eax
80109782:	c1 e0 18             	shl    $0x18,%eax
80109785:	89 c2                	mov    %eax,%edx
80109787:	8b 45 08             	mov    0x8(%ebp),%eax
8010978a:	c1 e0 08             	shl    $0x8,%eax
8010978d:	25 00 00 ff 00       	and    $0xff0000,%eax
80109792:	01 c2                	add    %eax,%edx
80109794:	8b 45 08             	mov    0x8(%ebp),%eax
80109797:	c1 e8 08             	shr    $0x8,%eax
8010979a:	25 00 ff 00 00       	and    $0xff00,%eax
8010979f:	01 c2                	add    %eax,%edx
801097a1:	8b 45 08             	mov    0x8(%ebp),%eax
801097a4:	c1 e8 18             	shr    $0x18,%eax
801097a7:	01 d0                	add    %edx,%eax
}
801097a9:	5d                   	pop    %ebp
801097aa:	c3                   	ret    

801097ab <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
801097ab:	55                   	push   %ebp
801097ac:	89 e5                	mov    %esp,%ebp
801097ae:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
801097b1:	8b 45 08             	mov    0x8(%ebp),%eax
801097b4:	83 c0 0e             	add    $0xe,%eax
801097b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
801097ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097bd:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801097c1:	0f b7 d0             	movzwl %ax,%edx
801097c4:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
801097c9:	39 c2                	cmp    %eax,%edx
801097cb:	74 60                	je     8010982d <ipv4_proc+0x82>
801097cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097d0:	83 c0 0c             	add    $0xc,%eax
801097d3:	83 ec 04             	sub    $0x4,%esp
801097d6:	6a 04                	push   $0x4
801097d8:	50                   	push   %eax
801097d9:	68 e4 f4 10 80       	push   $0x8010f4e4
801097de:	e8 95 b3 ff ff       	call   80104b78 <memcmp>
801097e3:	83 c4 10             	add    $0x10,%esp
801097e6:	85 c0                	test   %eax,%eax
801097e8:	74 43                	je     8010982d <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
801097ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097ed:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801097f1:	0f b7 c0             	movzwl %ax,%eax
801097f4:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
801097f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097fc:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109800:	3c 01                	cmp    $0x1,%al
80109802:	75 10                	jne    80109814 <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
80109804:	83 ec 0c             	sub    $0xc,%esp
80109807:	ff 75 08             	push   0x8(%ebp)
8010980a:	e8 a3 00 00 00       	call   801098b2 <icmp_proc>
8010980f:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109812:	eb 19                	jmp    8010982d <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109814:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109817:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010981b:	3c 06                	cmp    $0x6,%al
8010981d:	75 0e                	jne    8010982d <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
8010981f:	83 ec 0c             	sub    $0xc,%esp
80109822:	ff 75 08             	push   0x8(%ebp)
80109825:	e8 b3 03 00 00       	call   80109bdd <tcp_proc>
8010982a:	83 c4 10             	add    $0x10,%esp
}
8010982d:	90                   	nop
8010982e:	c9                   	leave  
8010982f:	c3                   	ret    

80109830 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109830:	55                   	push   %ebp
80109831:	89 e5                	mov    %esp,%ebp
80109833:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109836:	8b 45 08             	mov    0x8(%ebp),%eax
80109839:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
8010983c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010983f:	0f b6 00             	movzbl (%eax),%eax
80109842:	83 e0 0f             	and    $0xf,%eax
80109845:	01 c0                	add    %eax,%eax
80109847:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
8010984a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109851:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109858:	eb 48                	jmp    801098a2 <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010985a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010985d:	01 c0                	add    %eax,%eax
8010985f:	89 c2                	mov    %eax,%edx
80109861:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109864:	01 d0                	add    %edx,%eax
80109866:	0f b6 00             	movzbl (%eax),%eax
80109869:	0f b6 c0             	movzbl %al,%eax
8010986c:	c1 e0 08             	shl    $0x8,%eax
8010986f:	89 c2                	mov    %eax,%edx
80109871:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109874:	01 c0                	add    %eax,%eax
80109876:	8d 48 01             	lea    0x1(%eax),%ecx
80109879:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010987c:	01 c8                	add    %ecx,%eax
8010987e:	0f b6 00             	movzbl (%eax),%eax
80109881:	0f b6 c0             	movzbl %al,%eax
80109884:	01 d0                	add    %edx,%eax
80109886:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109889:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109890:	76 0c                	jbe    8010989e <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
80109892:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109895:	0f b7 c0             	movzwl %ax,%eax
80109898:	83 c0 01             	add    $0x1,%eax
8010989b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010989e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801098a2:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
801098a6:	39 45 f8             	cmp    %eax,-0x8(%ebp)
801098a9:	7c af                	jl     8010985a <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
801098ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
801098ae:	f7 d0                	not    %eax
}
801098b0:	c9                   	leave  
801098b1:	c3                   	ret    

801098b2 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
801098b2:	55                   	push   %ebp
801098b3:	89 e5                	mov    %esp,%ebp
801098b5:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
801098b8:	8b 45 08             	mov    0x8(%ebp),%eax
801098bb:	83 c0 0e             	add    $0xe,%eax
801098be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
801098c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098c4:	0f b6 00             	movzbl (%eax),%eax
801098c7:	0f b6 c0             	movzbl %al,%eax
801098ca:	83 e0 0f             	and    $0xf,%eax
801098cd:	c1 e0 02             	shl    $0x2,%eax
801098d0:	89 c2                	mov    %eax,%edx
801098d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098d5:	01 d0                	add    %edx,%eax
801098d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
801098da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098dd:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801098e1:	84 c0                	test   %al,%al
801098e3:	75 4f                	jne    80109934 <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
801098e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098e8:	0f b6 00             	movzbl (%eax),%eax
801098eb:	3c 08                	cmp    $0x8,%al
801098ed:	75 45                	jne    80109934 <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
801098ef:	e8 99 8e ff ff       	call   8010278d <kalloc>
801098f4:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
801098f7:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
801098fe:	83 ec 04             	sub    $0x4,%esp
80109901:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109904:	50                   	push   %eax
80109905:	ff 75 ec             	push   -0x14(%ebp)
80109908:	ff 75 08             	push   0x8(%ebp)
8010990b:	e8 78 00 00 00       	call   80109988 <icmp_reply_pkt_create>
80109910:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109913:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109916:	83 ec 08             	sub    $0x8,%esp
80109919:	50                   	push   %eax
8010991a:	ff 75 ec             	push   -0x14(%ebp)
8010991d:	e8 95 f4 ff ff       	call   80108db7 <i8254_send>
80109922:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109925:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109928:	83 ec 0c             	sub    $0xc,%esp
8010992b:	50                   	push   %eax
8010992c:	e8 c2 8d ff ff       	call   801026f3 <kfree>
80109931:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109934:	90                   	nop
80109935:	c9                   	leave  
80109936:	c3                   	ret    

80109937 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109937:	55                   	push   %ebp
80109938:	89 e5                	mov    %esp,%ebp
8010993a:	53                   	push   %ebx
8010993b:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
8010993e:	8b 45 08             	mov    0x8(%ebp),%eax
80109941:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109945:	0f b7 c0             	movzwl %ax,%eax
80109948:	83 ec 0c             	sub    $0xc,%esp
8010994b:	50                   	push   %eax
8010994c:	e8 bd fd ff ff       	call   8010970e <N2H_ushort>
80109951:	83 c4 10             	add    $0x10,%esp
80109954:	0f b7 d8             	movzwl %ax,%ebx
80109957:	8b 45 08             	mov    0x8(%ebp),%eax
8010995a:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010995e:	0f b7 c0             	movzwl %ax,%eax
80109961:	83 ec 0c             	sub    $0xc,%esp
80109964:	50                   	push   %eax
80109965:	e8 a4 fd ff ff       	call   8010970e <N2H_ushort>
8010996a:	83 c4 10             	add    $0x10,%esp
8010996d:	0f b7 c0             	movzwl %ax,%eax
80109970:	83 ec 04             	sub    $0x4,%esp
80109973:	53                   	push   %ebx
80109974:	50                   	push   %eax
80109975:	68 43 c3 10 80       	push   $0x8010c343
8010997a:	e8 75 6a ff ff       	call   801003f4 <cprintf>
8010997f:	83 c4 10             	add    $0x10,%esp
}
80109982:	90                   	nop
80109983:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109986:	c9                   	leave  
80109987:	c3                   	ret    

80109988 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109988:	55                   	push   %ebp
80109989:	89 e5                	mov    %esp,%ebp
8010998b:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010998e:	8b 45 08             	mov    0x8(%ebp),%eax
80109991:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109994:	8b 45 08             	mov    0x8(%ebp),%eax
80109997:	83 c0 0e             	add    $0xe,%eax
8010999a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
8010999d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099a0:	0f b6 00             	movzbl (%eax),%eax
801099a3:	0f b6 c0             	movzbl %al,%eax
801099a6:	83 e0 0f             	and    $0xf,%eax
801099a9:	c1 e0 02             	shl    $0x2,%eax
801099ac:	89 c2                	mov    %eax,%edx
801099ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099b1:	01 d0                	add    %edx,%eax
801099b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
801099b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801099b9:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
801099bc:	8b 45 0c             	mov    0xc(%ebp),%eax
801099bf:	83 c0 0e             	add    $0xe,%eax
801099c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
801099c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801099c8:	83 c0 14             	add    $0x14,%eax
801099cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
801099ce:	8b 45 10             	mov    0x10(%ebp),%eax
801099d1:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
801099d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099da:	8d 50 06             	lea    0x6(%eax),%edx
801099dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801099e0:	83 ec 04             	sub    $0x4,%esp
801099e3:	6a 06                	push   $0x6
801099e5:	52                   	push   %edx
801099e6:	50                   	push   %eax
801099e7:	e8 e4 b1 ff ff       	call   80104bd0 <memmove>
801099ec:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
801099ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
801099f2:	83 c0 06             	add    $0x6,%eax
801099f5:	83 ec 04             	sub    $0x4,%esp
801099f8:	6a 06                	push   $0x6
801099fa:	68 80 6d 19 80       	push   $0x80196d80
801099ff:	50                   	push   %eax
80109a00:	e8 cb b1 ff ff       	call   80104bd0 <memmove>
80109a05:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109a08:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a0b:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109a0f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a12:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109a16:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109a19:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109a1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109a1f:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109a23:	83 ec 0c             	sub    $0xc,%esp
80109a26:	6a 54                	push   $0x54
80109a28:	e8 03 fd ff ff       	call   80109730 <H2N_ushort>
80109a2d:	83 c4 10             	add    $0x10,%esp
80109a30:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109a33:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109a37:	0f b7 15 60 70 19 80 	movzwl 0x80197060,%edx
80109a3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109a41:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109a45:	0f b7 05 60 70 19 80 	movzwl 0x80197060,%eax
80109a4c:	83 c0 01             	add    $0x1,%eax
80109a4f:	66 a3 60 70 19 80    	mov    %ax,0x80197060
  ipv4_send->fragment = H2N_ushort(0x4000);
80109a55:	83 ec 0c             	sub    $0xc,%esp
80109a58:	68 00 40 00 00       	push   $0x4000
80109a5d:	e8 ce fc ff ff       	call   80109730 <H2N_ushort>
80109a62:	83 c4 10             	add    $0x10,%esp
80109a65:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109a68:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109a6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109a6f:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109a73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109a76:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109a7a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109a7d:	83 c0 0c             	add    $0xc,%eax
80109a80:	83 ec 04             	sub    $0x4,%esp
80109a83:	6a 04                	push   $0x4
80109a85:	68 e4 f4 10 80       	push   $0x8010f4e4
80109a8a:	50                   	push   %eax
80109a8b:	e8 40 b1 ff ff       	call   80104bd0 <memmove>
80109a90:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109a93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a96:	8d 50 0c             	lea    0xc(%eax),%edx
80109a99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109a9c:	83 c0 10             	add    $0x10,%eax
80109a9f:	83 ec 04             	sub    $0x4,%esp
80109aa2:	6a 04                	push   $0x4
80109aa4:	52                   	push   %edx
80109aa5:	50                   	push   %eax
80109aa6:	e8 25 b1 ff ff       	call   80104bd0 <memmove>
80109aab:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109aae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ab1:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109ab7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109aba:	83 ec 0c             	sub    $0xc,%esp
80109abd:	50                   	push   %eax
80109abe:	e8 6d fd ff ff       	call   80109830 <ipv4_chksum>
80109ac3:	83 c4 10             	add    $0x10,%esp
80109ac6:	0f b7 c0             	movzwl %ax,%eax
80109ac9:	83 ec 0c             	sub    $0xc,%esp
80109acc:	50                   	push   %eax
80109acd:	e8 5e fc ff ff       	call   80109730 <H2N_ushort>
80109ad2:	83 c4 10             	add    $0x10,%esp
80109ad5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109ad8:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109adc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109adf:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109ae2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ae5:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109ae9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109aec:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109af0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109af3:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109af7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109afa:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109afe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109b01:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109b05:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109b08:	8d 50 08             	lea    0x8(%eax),%edx
80109b0b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109b0e:	83 c0 08             	add    $0x8,%eax
80109b11:	83 ec 04             	sub    $0x4,%esp
80109b14:	6a 08                	push   $0x8
80109b16:	52                   	push   %edx
80109b17:	50                   	push   %eax
80109b18:	e8 b3 b0 ff ff       	call   80104bd0 <memmove>
80109b1d:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109b20:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109b23:	8d 50 10             	lea    0x10(%eax),%edx
80109b26:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109b29:	83 c0 10             	add    $0x10,%eax
80109b2c:	83 ec 04             	sub    $0x4,%esp
80109b2f:	6a 30                	push   $0x30
80109b31:	52                   	push   %edx
80109b32:	50                   	push   %eax
80109b33:	e8 98 b0 ff ff       	call   80104bd0 <memmove>
80109b38:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109b3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109b3e:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109b44:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109b47:	83 ec 0c             	sub    $0xc,%esp
80109b4a:	50                   	push   %eax
80109b4b:	e8 1c 00 00 00       	call   80109b6c <icmp_chksum>
80109b50:	83 c4 10             	add    $0x10,%esp
80109b53:	0f b7 c0             	movzwl %ax,%eax
80109b56:	83 ec 0c             	sub    $0xc,%esp
80109b59:	50                   	push   %eax
80109b5a:	e8 d1 fb ff ff       	call   80109730 <H2N_ushort>
80109b5f:	83 c4 10             	add    $0x10,%esp
80109b62:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109b65:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109b69:	90                   	nop
80109b6a:	c9                   	leave  
80109b6b:	c3                   	ret    

80109b6c <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109b6c:	55                   	push   %ebp
80109b6d:	89 e5                	mov    %esp,%ebp
80109b6f:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109b72:	8b 45 08             	mov    0x8(%ebp),%eax
80109b75:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109b78:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109b7f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109b86:	eb 48                	jmp    80109bd0 <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109b88:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109b8b:	01 c0                	add    %eax,%eax
80109b8d:	89 c2                	mov    %eax,%edx
80109b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b92:	01 d0                	add    %edx,%eax
80109b94:	0f b6 00             	movzbl (%eax),%eax
80109b97:	0f b6 c0             	movzbl %al,%eax
80109b9a:	c1 e0 08             	shl    $0x8,%eax
80109b9d:	89 c2                	mov    %eax,%edx
80109b9f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109ba2:	01 c0                	add    %eax,%eax
80109ba4:	8d 48 01             	lea    0x1(%eax),%ecx
80109ba7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109baa:	01 c8                	add    %ecx,%eax
80109bac:	0f b6 00             	movzbl (%eax),%eax
80109baf:	0f b6 c0             	movzbl %al,%eax
80109bb2:	01 d0                	add    %edx,%eax
80109bb4:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109bb7:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109bbe:	76 0c                	jbe    80109bcc <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
80109bc0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109bc3:	0f b7 c0             	movzwl %ax,%eax
80109bc6:	83 c0 01             	add    $0x1,%eax
80109bc9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109bcc:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109bd0:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109bd4:	7e b2                	jle    80109b88 <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
80109bd6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109bd9:	f7 d0                	not    %eax
}
80109bdb:	c9                   	leave  
80109bdc:	c3                   	ret    

80109bdd <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109bdd:	55                   	push   %ebp
80109bde:	89 e5                	mov    %esp,%ebp
80109be0:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109be3:	8b 45 08             	mov    0x8(%ebp),%eax
80109be6:	83 c0 0e             	add    $0xe,%eax
80109be9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109bec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bef:	0f b6 00             	movzbl (%eax),%eax
80109bf2:	0f b6 c0             	movzbl %al,%eax
80109bf5:	83 e0 0f             	and    $0xf,%eax
80109bf8:	c1 e0 02             	shl    $0x2,%eax
80109bfb:	89 c2                	mov    %eax,%edx
80109bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c00:	01 d0                	add    %edx,%eax
80109c02:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109c05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c08:	83 c0 14             	add    $0x14,%eax
80109c0b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109c0e:	e8 7a 8b ff ff       	call   8010278d <kalloc>
80109c13:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109c16:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109c1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c20:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109c24:	0f b6 c0             	movzbl %al,%eax
80109c27:	83 e0 02             	and    $0x2,%eax
80109c2a:	85 c0                	test   %eax,%eax
80109c2c:	74 3d                	je     80109c6b <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109c2e:	83 ec 0c             	sub    $0xc,%esp
80109c31:	6a 00                	push   $0x0
80109c33:	6a 12                	push   $0x12
80109c35:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109c38:	50                   	push   %eax
80109c39:	ff 75 e8             	push   -0x18(%ebp)
80109c3c:	ff 75 08             	push   0x8(%ebp)
80109c3f:	e8 a2 01 00 00       	call   80109de6 <tcp_pkt_create>
80109c44:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109c47:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109c4a:	83 ec 08             	sub    $0x8,%esp
80109c4d:	50                   	push   %eax
80109c4e:	ff 75 e8             	push   -0x18(%ebp)
80109c51:	e8 61 f1 ff ff       	call   80108db7 <i8254_send>
80109c56:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109c59:	a1 64 70 19 80       	mov    0x80197064,%eax
80109c5e:	83 c0 01             	add    $0x1,%eax
80109c61:	a3 64 70 19 80       	mov    %eax,0x80197064
80109c66:	e9 69 01 00 00       	jmp    80109dd4 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109c6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c6e:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109c72:	3c 18                	cmp    $0x18,%al
80109c74:	0f 85 10 01 00 00    	jne    80109d8a <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
80109c7a:	83 ec 04             	sub    $0x4,%esp
80109c7d:	6a 03                	push   $0x3
80109c7f:	68 5e c3 10 80       	push   $0x8010c35e
80109c84:	ff 75 ec             	push   -0x14(%ebp)
80109c87:	e8 ec ae ff ff       	call   80104b78 <memcmp>
80109c8c:	83 c4 10             	add    $0x10,%esp
80109c8f:	85 c0                	test   %eax,%eax
80109c91:	74 74                	je     80109d07 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
80109c93:	83 ec 0c             	sub    $0xc,%esp
80109c96:	68 62 c3 10 80       	push   $0x8010c362
80109c9b:	e8 54 67 ff ff       	call   801003f4 <cprintf>
80109ca0:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109ca3:	83 ec 0c             	sub    $0xc,%esp
80109ca6:	6a 00                	push   $0x0
80109ca8:	6a 10                	push   $0x10
80109caa:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109cad:	50                   	push   %eax
80109cae:	ff 75 e8             	push   -0x18(%ebp)
80109cb1:	ff 75 08             	push   0x8(%ebp)
80109cb4:	e8 2d 01 00 00       	call   80109de6 <tcp_pkt_create>
80109cb9:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109cbc:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109cbf:	83 ec 08             	sub    $0x8,%esp
80109cc2:	50                   	push   %eax
80109cc3:	ff 75 e8             	push   -0x18(%ebp)
80109cc6:	e8 ec f0 ff ff       	call   80108db7 <i8254_send>
80109ccb:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109cce:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109cd1:	83 c0 36             	add    $0x36,%eax
80109cd4:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109cd7:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109cda:	50                   	push   %eax
80109cdb:	ff 75 e0             	push   -0x20(%ebp)
80109cde:	6a 00                	push   $0x0
80109ce0:	6a 00                	push   $0x0
80109ce2:	e8 5a 04 00 00       	call   8010a141 <http_proc>
80109ce7:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109cea:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109ced:	83 ec 0c             	sub    $0xc,%esp
80109cf0:	50                   	push   %eax
80109cf1:	6a 18                	push   $0x18
80109cf3:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109cf6:	50                   	push   %eax
80109cf7:	ff 75 e8             	push   -0x18(%ebp)
80109cfa:	ff 75 08             	push   0x8(%ebp)
80109cfd:	e8 e4 00 00 00       	call   80109de6 <tcp_pkt_create>
80109d02:	83 c4 20             	add    $0x20,%esp
80109d05:	eb 62                	jmp    80109d69 <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109d07:	83 ec 0c             	sub    $0xc,%esp
80109d0a:	6a 00                	push   $0x0
80109d0c:	6a 10                	push   $0x10
80109d0e:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109d11:	50                   	push   %eax
80109d12:	ff 75 e8             	push   -0x18(%ebp)
80109d15:	ff 75 08             	push   0x8(%ebp)
80109d18:	e8 c9 00 00 00       	call   80109de6 <tcp_pkt_create>
80109d1d:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
80109d20:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109d23:	83 ec 08             	sub    $0x8,%esp
80109d26:	50                   	push   %eax
80109d27:	ff 75 e8             	push   -0x18(%ebp)
80109d2a:	e8 88 f0 ff ff       	call   80108db7 <i8254_send>
80109d2f:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109d32:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d35:	83 c0 36             	add    $0x36,%eax
80109d38:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109d3b:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109d3e:	50                   	push   %eax
80109d3f:	ff 75 e4             	push   -0x1c(%ebp)
80109d42:	6a 00                	push   $0x0
80109d44:	6a 00                	push   $0x0
80109d46:	e8 f6 03 00 00       	call   8010a141 <http_proc>
80109d4b:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109d4e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109d51:	83 ec 0c             	sub    $0xc,%esp
80109d54:	50                   	push   %eax
80109d55:	6a 18                	push   $0x18
80109d57:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109d5a:	50                   	push   %eax
80109d5b:	ff 75 e8             	push   -0x18(%ebp)
80109d5e:	ff 75 08             	push   0x8(%ebp)
80109d61:	e8 80 00 00 00       	call   80109de6 <tcp_pkt_create>
80109d66:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
80109d69:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109d6c:	83 ec 08             	sub    $0x8,%esp
80109d6f:	50                   	push   %eax
80109d70:	ff 75 e8             	push   -0x18(%ebp)
80109d73:	e8 3f f0 ff ff       	call   80108db7 <i8254_send>
80109d78:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109d7b:	a1 64 70 19 80       	mov    0x80197064,%eax
80109d80:	83 c0 01             	add    $0x1,%eax
80109d83:	a3 64 70 19 80       	mov    %eax,0x80197064
80109d88:	eb 4a                	jmp    80109dd4 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
80109d8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d8d:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109d91:	3c 10                	cmp    $0x10,%al
80109d93:	75 3f                	jne    80109dd4 <tcp_proc+0x1f7>
    if(fin_flag == 1){
80109d95:	a1 68 70 19 80       	mov    0x80197068,%eax
80109d9a:	83 f8 01             	cmp    $0x1,%eax
80109d9d:	75 35                	jne    80109dd4 <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
80109d9f:	83 ec 0c             	sub    $0xc,%esp
80109da2:	6a 00                	push   $0x0
80109da4:	6a 01                	push   $0x1
80109da6:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109da9:	50                   	push   %eax
80109daa:	ff 75 e8             	push   -0x18(%ebp)
80109dad:	ff 75 08             	push   0x8(%ebp)
80109db0:	e8 31 00 00 00       	call   80109de6 <tcp_pkt_create>
80109db5:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109db8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109dbb:	83 ec 08             	sub    $0x8,%esp
80109dbe:	50                   	push   %eax
80109dbf:	ff 75 e8             	push   -0x18(%ebp)
80109dc2:	e8 f0 ef ff ff       	call   80108db7 <i8254_send>
80109dc7:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
80109dca:	c7 05 68 70 19 80 00 	movl   $0x0,0x80197068
80109dd1:	00 00 00 
    }
  }
  kfree((char *)send_addr);
80109dd4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109dd7:	83 ec 0c             	sub    $0xc,%esp
80109dda:	50                   	push   %eax
80109ddb:	e8 13 89 ff ff       	call   801026f3 <kfree>
80109de0:	83 c4 10             	add    $0x10,%esp
}
80109de3:	90                   	nop
80109de4:	c9                   	leave  
80109de5:	c3                   	ret    

80109de6 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
80109de6:	55                   	push   %ebp
80109de7:	89 e5                	mov    %esp,%ebp
80109de9:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109dec:	8b 45 08             	mov    0x8(%ebp),%eax
80109def:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109df2:	8b 45 08             	mov    0x8(%ebp),%eax
80109df5:	83 c0 0e             	add    $0xe,%eax
80109df8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
80109dfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109dfe:	0f b6 00             	movzbl (%eax),%eax
80109e01:	0f b6 c0             	movzbl %al,%eax
80109e04:	83 e0 0f             	and    $0xf,%eax
80109e07:	c1 e0 02             	shl    $0x2,%eax
80109e0a:	89 c2                	mov    %eax,%edx
80109e0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e0f:	01 d0                	add    %edx,%eax
80109e11:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109e14:	8b 45 0c             	mov    0xc(%ebp),%eax
80109e17:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
80109e1a:	8b 45 0c             	mov    0xc(%ebp),%eax
80109e1d:	83 c0 0e             	add    $0xe,%eax
80109e20:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
80109e23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e26:	83 c0 14             	add    $0x14,%eax
80109e29:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
80109e2c:	8b 45 18             	mov    0x18(%ebp),%eax
80109e2f:	8d 50 36             	lea    0x36(%eax),%edx
80109e32:	8b 45 10             	mov    0x10(%ebp),%eax
80109e35:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109e37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e3a:	8d 50 06             	lea    0x6(%eax),%edx
80109e3d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e40:	83 ec 04             	sub    $0x4,%esp
80109e43:	6a 06                	push   $0x6
80109e45:	52                   	push   %edx
80109e46:	50                   	push   %eax
80109e47:	e8 84 ad ff ff       	call   80104bd0 <memmove>
80109e4c:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109e4f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e52:	83 c0 06             	add    $0x6,%eax
80109e55:	83 ec 04             	sub    $0x4,%esp
80109e58:	6a 06                	push   $0x6
80109e5a:	68 80 6d 19 80       	push   $0x80196d80
80109e5f:	50                   	push   %eax
80109e60:	e8 6b ad ff ff       	call   80104bd0 <memmove>
80109e65:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109e68:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e6b:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109e6f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e72:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109e76:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e79:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109e7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e7f:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
80109e83:	8b 45 18             	mov    0x18(%ebp),%eax
80109e86:	83 c0 28             	add    $0x28,%eax
80109e89:	0f b7 c0             	movzwl %ax,%eax
80109e8c:	83 ec 0c             	sub    $0xc,%esp
80109e8f:	50                   	push   %eax
80109e90:	e8 9b f8 ff ff       	call   80109730 <H2N_ushort>
80109e95:	83 c4 10             	add    $0x10,%esp
80109e98:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109e9b:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109e9f:	0f b7 15 60 70 19 80 	movzwl 0x80197060,%edx
80109ea6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ea9:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109ead:	0f b7 05 60 70 19 80 	movzwl 0x80197060,%eax
80109eb4:	83 c0 01             	add    $0x1,%eax
80109eb7:	66 a3 60 70 19 80    	mov    %ax,0x80197060
  ipv4_send->fragment = H2N_ushort(0x0000);
80109ebd:	83 ec 0c             	sub    $0xc,%esp
80109ec0:	6a 00                	push   $0x0
80109ec2:	e8 69 f8 ff ff       	call   80109730 <H2N_ushort>
80109ec7:	83 c4 10             	add    $0x10,%esp
80109eca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109ecd:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109ed1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ed4:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
80109ed8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109edb:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109edf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ee2:	83 c0 0c             	add    $0xc,%eax
80109ee5:	83 ec 04             	sub    $0x4,%esp
80109ee8:	6a 04                	push   $0x4
80109eea:	68 e4 f4 10 80       	push   $0x8010f4e4
80109eef:	50                   	push   %eax
80109ef0:	e8 db ac ff ff       	call   80104bd0 <memmove>
80109ef5:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109ef8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109efb:	8d 50 0c             	lea    0xc(%eax),%edx
80109efe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f01:	83 c0 10             	add    $0x10,%eax
80109f04:	83 ec 04             	sub    $0x4,%esp
80109f07:	6a 04                	push   $0x4
80109f09:	52                   	push   %edx
80109f0a:	50                   	push   %eax
80109f0b:	e8 c0 ac ff ff       	call   80104bd0 <memmove>
80109f10:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109f13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f16:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109f1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f1f:	83 ec 0c             	sub    $0xc,%esp
80109f22:	50                   	push   %eax
80109f23:	e8 08 f9 ff ff       	call   80109830 <ipv4_chksum>
80109f28:	83 c4 10             	add    $0x10,%esp
80109f2b:	0f b7 c0             	movzwl %ax,%eax
80109f2e:	83 ec 0c             	sub    $0xc,%esp
80109f31:	50                   	push   %eax
80109f32:	e8 f9 f7 ff ff       	call   80109730 <H2N_ushort>
80109f37:	83 c4 10             	add    $0x10,%esp
80109f3a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109f3d:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
80109f41:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f44:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80109f48:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f4b:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
80109f4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f51:	0f b7 10             	movzwl (%eax),%edx
80109f54:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f57:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
80109f5b:	a1 64 70 19 80       	mov    0x80197064,%eax
80109f60:	83 ec 0c             	sub    $0xc,%esp
80109f63:	50                   	push   %eax
80109f64:	e8 e9 f7 ff ff       	call   80109752 <H2N_uint>
80109f69:	83 c4 10             	add    $0x10,%esp
80109f6c:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109f6f:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
80109f72:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f75:	8b 40 04             	mov    0x4(%eax),%eax
80109f78:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
80109f7e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f81:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
80109f84:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f87:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
80109f8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f8e:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
80109f92:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f95:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
80109f99:	8b 45 14             	mov    0x14(%ebp),%eax
80109f9c:	89 c2                	mov    %eax,%edx
80109f9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109fa1:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
80109fa4:	83 ec 0c             	sub    $0xc,%esp
80109fa7:	68 90 38 00 00       	push   $0x3890
80109fac:	e8 7f f7 ff ff       	call   80109730 <H2N_ushort>
80109fb1:	83 c4 10             	add    $0x10,%esp
80109fb4:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109fb7:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
80109fbb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109fbe:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
80109fc4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109fc7:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
80109fcd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109fd0:	83 ec 0c             	sub    $0xc,%esp
80109fd3:	50                   	push   %eax
80109fd4:	e8 1f 00 00 00       	call   80109ff8 <tcp_chksum>
80109fd9:	83 c4 10             	add    $0x10,%esp
80109fdc:	83 c0 08             	add    $0x8,%eax
80109fdf:	0f b7 c0             	movzwl %ax,%eax
80109fe2:	83 ec 0c             	sub    $0xc,%esp
80109fe5:	50                   	push   %eax
80109fe6:	e8 45 f7 ff ff       	call   80109730 <H2N_ushort>
80109feb:	83 c4 10             	add    $0x10,%esp
80109fee:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109ff1:	66 89 42 10          	mov    %ax,0x10(%edx)


}
80109ff5:	90                   	nop
80109ff6:	c9                   	leave  
80109ff7:	c3                   	ret    

80109ff8 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
80109ff8:	55                   	push   %ebp
80109ff9:	89 e5                	mov    %esp,%ebp
80109ffb:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
80109ffe:	8b 45 08             	mov    0x8(%ebp),%eax
8010a001:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a004:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a007:	83 c0 14             	add    $0x14,%eax
8010a00a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a00d:	83 ec 04             	sub    $0x4,%esp
8010a010:	6a 04                	push   $0x4
8010a012:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a017:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a01a:	50                   	push   %eax
8010a01b:	e8 b0 ab ff ff       	call   80104bd0 <memmove>
8010a020:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a023:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a026:	83 c0 0c             	add    $0xc,%eax
8010a029:	83 ec 04             	sub    $0x4,%esp
8010a02c:	6a 04                	push   $0x4
8010a02e:	50                   	push   %eax
8010a02f:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a032:	83 c0 04             	add    $0x4,%eax
8010a035:	50                   	push   %eax
8010a036:	e8 95 ab ff ff       	call   80104bd0 <memmove>
8010a03b:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a03e:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a042:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a046:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a049:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a04d:	0f b7 c0             	movzwl %ax,%eax
8010a050:	83 ec 0c             	sub    $0xc,%esp
8010a053:	50                   	push   %eax
8010a054:	e8 b5 f6 ff ff       	call   8010970e <N2H_ushort>
8010a059:	83 c4 10             	add    $0x10,%esp
8010a05c:	83 e8 14             	sub    $0x14,%eax
8010a05f:	0f b7 c0             	movzwl %ax,%eax
8010a062:	83 ec 0c             	sub    $0xc,%esp
8010a065:	50                   	push   %eax
8010a066:	e8 c5 f6 ff ff       	call   80109730 <H2N_ushort>
8010a06b:	83 c4 10             	add    $0x10,%esp
8010a06e:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a072:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a079:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a07c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a07f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a086:	eb 33                	jmp    8010a0bb <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a088:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a08b:	01 c0                	add    %eax,%eax
8010a08d:	89 c2                	mov    %eax,%edx
8010a08f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a092:	01 d0                	add    %edx,%eax
8010a094:	0f b6 00             	movzbl (%eax),%eax
8010a097:	0f b6 c0             	movzbl %al,%eax
8010a09a:	c1 e0 08             	shl    $0x8,%eax
8010a09d:	89 c2                	mov    %eax,%edx
8010a09f:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0a2:	01 c0                	add    %eax,%eax
8010a0a4:	8d 48 01             	lea    0x1(%eax),%ecx
8010a0a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0aa:	01 c8                	add    %ecx,%eax
8010a0ac:	0f b6 00             	movzbl (%eax),%eax
8010a0af:	0f b6 c0             	movzbl %al,%eax
8010a0b2:	01 d0                	add    %edx,%eax
8010a0b4:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a0b7:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a0bb:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a0bf:	7e c7                	jle    8010a088 <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
8010a0c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a0c7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a0ce:	eb 33                	jmp    8010a103 <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a0d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a0d3:	01 c0                	add    %eax,%eax
8010a0d5:	89 c2                	mov    %eax,%edx
8010a0d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0da:	01 d0                	add    %edx,%eax
8010a0dc:	0f b6 00             	movzbl (%eax),%eax
8010a0df:	0f b6 c0             	movzbl %al,%eax
8010a0e2:	c1 e0 08             	shl    $0x8,%eax
8010a0e5:	89 c2                	mov    %eax,%edx
8010a0e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a0ea:	01 c0                	add    %eax,%eax
8010a0ec:	8d 48 01             	lea    0x1(%eax),%ecx
8010a0ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0f2:	01 c8                	add    %ecx,%eax
8010a0f4:	0f b6 00             	movzbl (%eax),%eax
8010a0f7:	0f b6 c0             	movzbl %al,%eax
8010a0fa:	01 d0                	add    %edx,%eax
8010a0fc:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a0ff:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a103:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a107:	0f b7 c0             	movzwl %ax,%eax
8010a10a:	83 ec 0c             	sub    $0xc,%esp
8010a10d:	50                   	push   %eax
8010a10e:	e8 fb f5 ff ff       	call   8010970e <N2H_ushort>
8010a113:	83 c4 10             	add    $0x10,%esp
8010a116:	66 d1 e8             	shr    %ax
8010a119:	0f b7 c0             	movzwl %ax,%eax
8010a11c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a11f:	7c af                	jl     8010a0d0 <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a121:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a124:	c1 e8 10             	shr    $0x10,%eax
8010a127:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a12a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a12d:	f7 d0                	not    %eax
}
8010a12f:	c9                   	leave  
8010a130:	c3                   	ret    

8010a131 <tcp_fin>:

void tcp_fin(){
8010a131:	55                   	push   %ebp
8010a132:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a134:	c7 05 68 70 19 80 01 	movl   $0x1,0x80197068
8010a13b:	00 00 00 
}
8010a13e:	90                   	nop
8010a13f:	5d                   	pop    %ebp
8010a140:	c3                   	ret    

8010a141 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a141:	55                   	push   %ebp
8010a142:	89 e5                	mov    %esp,%ebp
8010a144:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a147:	8b 45 10             	mov    0x10(%ebp),%eax
8010a14a:	83 ec 04             	sub    $0x4,%esp
8010a14d:	6a 00                	push   $0x0
8010a14f:	68 6b c3 10 80       	push   $0x8010c36b
8010a154:	50                   	push   %eax
8010a155:	e8 65 00 00 00       	call   8010a1bf <http_strcpy>
8010a15a:	83 c4 10             	add    $0x10,%esp
8010a15d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a160:	8b 45 10             	mov    0x10(%ebp),%eax
8010a163:	83 ec 04             	sub    $0x4,%esp
8010a166:	ff 75 f4             	push   -0xc(%ebp)
8010a169:	68 7e c3 10 80       	push   $0x8010c37e
8010a16e:	50                   	push   %eax
8010a16f:	e8 4b 00 00 00       	call   8010a1bf <http_strcpy>
8010a174:	83 c4 10             	add    $0x10,%esp
8010a177:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a17a:	8b 45 10             	mov    0x10(%ebp),%eax
8010a17d:	83 ec 04             	sub    $0x4,%esp
8010a180:	ff 75 f4             	push   -0xc(%ebp)
8010a183:	68 99 c3 10 80       	push   $0x8010c399
8010a188:	50                   	push   %eax
8010a189:	e8 31 00 00 00       	call   8010a1bf <http_strcpy>
8010a18e:	83 c4 10             	add    $0x10,%esp
8010a191:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a194:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a197:	83 e0 01             	and    $0x1,%eax
8010a19a:	85 c0                	test   %eax,%eax
8010a19c:	74 11                	je     8010a1af <http_proc+0x6e>
    char *payload = (char *)send;
8010a19e:	8b 45 10             	mov    0x10(%ebp),%eax
8010a1a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a1a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a1a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a1aa:	01 d0                	add    %edx,%eax
8010a1ac:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a1af:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a1b2:	8b 45 14             	mov    0x14(%ebp),%eax
8010a1b5:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a1b7:	e8 75 ff ff ff       	call   8010a131 <tcp_fin>
}
8010a1bc:	90                   	nop
8010a1bd:	c9                   	leave  
8010a1be:	c3                   	ret    

8010a1bf <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a1bf:	55                   	push   %ebp
8010a1c0:	89 e5                	mov    %esp,%ebp
8010a1c2:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a1c5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a1cc:	eb 20                	jmp    8010a1ee <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010a1ce:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a1d1:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a1d4:	01 d0                	add    %edx,%eax
8010a1d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a1d9:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a1dc:	01 ca                	add    %ecx,%edx
8010a1de:	89 d1                	mov    %edx,%ecx
8010a1e0:	8b 55 08             	mov    0x8(%ebp),%edx
8010a1e3:	01 ca                	add    %ecx,%edx
8010a1e5:	0f b6 00             	movzbl (%eax),%eax
8010a1e8:	88 02                	mov    %al,(%edx)
    i++;
8010a1ea:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a1ee:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a1f1:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a1f4:	01 d0                	add    %edx,%eax
8010a1f6:	0f b6 00             	movzbl (%eax),%eax
8010a1f9:	84 c0                	test   %al,%al
8010a1fb:	75 d1                	jne    8010a1ce <http_strcpy+0xf>
  }
  return i;
8010a1fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a200:	c9                   	leave  
8010a201:	c3                   	ret    

8010a202 <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a202:	55                   	push   %ebp
8010a203:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a205:	c7 05 70 70 19 80 a2 	movl   $0x8010f5a2,0x80197070
8010a20c:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a20f:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a214:	c1 e8 09             	shr    $0x9,%eax
8010a217:	a3 6c 70 19 80       	mov    %eax,0x8019706c
}
8010a21c:	90                   	nop
8010a21d:	5d                   	pop    %ebp
8010a21e:	c3                   	ret    

8010a21f <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a21f:	55                   	push   %ebp
8010a220:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a222:	90                   	nop
8010a223:	5d                   	pop    %ebp
8010a224:	c3                   	ret    

8010a225 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a225:	55                   	push   %ebp
8010a226:	89 e5                	mov    %esp,%ebp
8010a228:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a22b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a22e:	83 c0 0c             	add    $0xc,%eax
8010a231:	83 ec 0c             	sub    $0xc,%esp
8010a234:	50                   	push   %eax
8010a235:	e8 d0 a5 ff ff       	call   8010480a <holdingsleep>
8010a23a:	83 c4 10             	add    $0x10,%esp
8010a23d:	85 c0                	test   %eax,%eax
8010a23f:	75 0d                	jne    8010a24e <iderw+0x29>
    panic("iderw: buf not locked");
8010a241:	83 ec 0c             	sub    $0xc,%esp
8010a244:	68 aa c3 10 80       	push   $0x8010c3aa
8010a249:	e8 5b 63 ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a24e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a251:	8b 00                	mov    (%eax),%eax
8010a253:	83 e0 06             	and    $0x6,%eax
8010a256:	83 f8 02             	cmp    $0x2,%eax
8010a259:	75 0d                	jne    8010a268 <iderw+0x43>
    panic("iderw: nothing to do");
8010a25b:	83 ec 0c             	sub    $0xc,%esp
8010a25e:	68 c0 c3 10 80       	push   $0x8010c3c0
8010a263:	e8 41 63 ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
8010a268:	8b 45 08             	mov    0x8(%ebp),%eax
8010a26b:	8b 40 04             	mov    0x4(%eax),%eax
8010a26e:	83 f8 01             	cmp    $0x1,%eax
8010a271:	74 0d                	je     8010a280 <iderw+0x5b>
    panic("iderw: request not for disk 1");
8010a273:	83 ec 0c             	sub    $0xc,%esp
8010a276:	68 d5 c3 10 80       	push   $0x8010c3d5
8010a27b:	e8 29 63 ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
8010a280:	8b 45 08             	mov    0x8(%ebp),%eax
8010a283:	8b 40 08             	mov    0x8(%eax),%eax
8010a286:	8b 15 6c 70 19 80    	mov    0x8019706c,%edx
8010a28c:	39 d0                	cmp    %edx,%eax
8010a28e:	72 0d                	jb     8010a29d <iderw+0x78>
    panic("iderw: block out of range");
8010a290:	83 ec 0c             	sub    $0xc,%esp
8010a293:	68 f3 c3 10 80       	push   $0x8010c3f3
8010a298:	e8 0c 63 ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a29d:	8b 15 70 70 19 80    	mov    0x80197070,%edx
8010a2a3:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2a6:	8b 40 08             	mov    0x8(%eax),%eax
8010a2a9:	c1 e0 09             	shl    $0x9,%eax
8010a2ac:	01 d0                	add    %edx,%eax
8010a2ae:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a2b1:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2b4:	8b 00                	mov    (%eax),%eax
8010a2b6:	83 e0 04             	and    $0x4,%eax
8010a2b9:	85 c0                	test   %eax,%eax
8010a2bb:	74 2b                	je     8010a2e8 <iderw+0xc3>
    b->flags &= ~B_DIRTY;
8010a2bd:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2c0:	8b 00                	mov    (%eax),%eax
8010a2c2:	83 e0 fb             	and    $0xfffffffb,%eax
8010a2c5:	89 c2                	mov    %eax,%edx
8010a2c7:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2ca:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a2cc:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2cf:	83 c0 5c             	add    $0x5c,%eax
8010a2d2:	83 ec 04             	sub    $0x4,%esp
8010a2d5:	68 00 02 00 00       	push   $0x200
8010a2da:	50                   	push   %eax
8010a2db:	ff 75 f4             	push   -0xc(%ebp)
8010a2de:	e8 ed a8 ff ff       	call   80104bd0 <memmove>
8010a2e3:	83 c4 10             	add    $0x10,%esp
8010a2e6:	eb 1a                	jmp    8010a302 <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
8010a2e8:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2eb:	83 c0 5c             	add    $0x5c,%eax
8010a2ee:	83 ec 04             	sub    $0x4,%esp
8010a2f1:	68 00 02 00 00       	push   $0x200
8010a2f6:	ff 75 f4             	push   -0xc(%ebp)
8010a2f9:	50                   	push   %eax
8010a2fa:	e8 d1 a8 ff ff       	call   80104bd0 <memmove>
8010a2ff:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a302:	8b 45 08             	mov    0x8(%ebp),%eax
8010a305:	8b 00                	mov    (%eax),%eax
8010a307:	83 c8 02             	or     $0x2,%eax
8010a30a:	89 c2                	mov    %eax,%edx
8010a30c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a30f:	89 10                	mov    %edx,(%eax)
}
8010a311:	90                   	nop
8010a312:	c9                   	leave  
8010a313:	c3                   	ret    
