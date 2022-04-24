
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 b0 10 00       	mov    $0x10b000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 50 d6 10 80       	mov    $0x8010d650,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 7e 3a 10 80       	mov    $0x80103a7e,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	f3 0f 1e fb          	endbr32 
80100038:	55                   	push   %ebp
80100039:	89 e5                	mov    %esp,%ebp
8010003b:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003e:	83 ec 08             	sub    $0x8,%esp
80100041:	68 f4 91 10 80       	push   $0x801091f4
80100046:	68 60 d6 10 80       	push   $0x8010d660
8010004b:	e8 2a 52 00 00       	call   8010527a <initlock>
80100050:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100053:	c7 05 ac 1d 11 80 5c 	movl   $0x80111d5c,0x80111dac
8010005a:	1d 11 80 
  bcache.head.next = &bcache.head;
8010005d:	c7 05 b0 1d 11 80 5c 	movl   $0x80111d5c,0x80111db0
80100064:	1d 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100067:	c7 45 f4 94 d6 10 80 	movl   $0x8010d694,-0xc(%ebp)
8010006e:	eb 47                	jmp    801000b7 <binit+0x83>
    b->next = bcache.head.next;
80100070:	8b 15 b0 1d 11 80    	mov    0x80111db0,%edx
80100076:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100079:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
8010007c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007f:	c7 40 50 5c 1d 11 80 	movl   $0x80111d5c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
80100086:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100089:	83 c0 0c             	add    $0xc,%eax
8010008c:	83 ec 08             	sub    $0x8,%esp
8010008f:	68 fb 91 10 80       	push   $0x801091fb
80100094:	50                   	push   %eax
80100095:	e8 4d 50 00 00       	call   801050e7 <initsleeplock>
8010009a:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
8010009d:	a1 b0 1d 11 80       	mov    0x80111db0,%eax
801000a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000a5:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ab:	a3 b0 1d 11 80       	mov    %eax,0x80111db0
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000b0:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000b7:	b8 5c 1d 11 80       	mov    $0x80111d5c,%eax
801000bc:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000bf:	72 af                	jb     80100070 <binit+0x3c>
  }
}
801000c1:	90                   	nop
801000c2:	90                   	nop
801000c3:	c9                   	leave  
801000c4:	c3                   	ret    

801000c5 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000c5:	f3 0f 1e fb          	endbr32 
801000c9:	55                   	push   %ebp
801000ca:	89 e5                	mov    %esp,%ebp
801000cc:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000cf:	83 ec 0c             	sub    $0xc,%esp
801000d2:	68 60 d6 10 80       	push   $0x8010d660
801000d7:	e8 c4 51 00 00       	call   801052a0 <acquire>
801000dc:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000df:	a1 b0 1d 11 80       	mov    0x80111db0,%eax
801000e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000e7:	eb 58                	jmp    80100141 <bget+0x7c>
    if(b->dev == dev && b->blockno == blockno){
801000e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ec:	8b 40 04             	mov    0x4(%eax),%eax
801000ef:	39 45 08             	cmp    %eax,0x8(%ebp)
801000f2:	75 44                	jne    80100138 <bget+0x73>
801000f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f7:	8b 40 08             	mov    0x8(%eax),%eax
801000fa:	39 45 0c             	cmp    %eax,0xc(%ebp)
801000fd:	75 39                	jne    80100138 <bget+0x73>
      b->refcnt++;
801000ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100102:	8b 40 4c             	mov    0x4c(%eax),%eax
80100105:	8d 50 01             	lea    0x1(%eax),%edx
80100108:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010b:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
8010010e:	83 ec 0c             	sub    $0xc,%esp
80100111:	68 60 d6 10 80       	push   $0x8010d660
80100116:	e8 f7 51 00 00       	call   80105312 <release>
8010011b:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
8010011e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100121:	83 c0 0c             	add    $0xc,%eax
80100124:	83 ec 0c             	sub    $0xc,%esp
80100127:	50                   	push   %eax
80100128:	e8 fa 4f 00 00       	call   80105127 <acquiresleep>
8010012d:	83 c4 10             	add    $0x10,%esp
      return b;
80100130:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100133:	e9 9d 00 00 00       	jmp    801001d5 <bget+0x110>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100138:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010013b:	8b 40 54             	mov    0x54(%eax),%eax
8010013e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100141:	81 7d f4 5c 1d 11 80 	cmpl   $0x80111d5c,-0xc(%ebp)
80100148:	75 9f                	jne    801000e9 <bget+0x24>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
8010014a:	a1 ac 1d 11 80       	mov    0x80111dac,%eax
8010014f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100152:	eb 6b                	jmp    801001bf <bget+0xfa>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
80100154:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100157:	8b 40 4c             	mov    0x4c(%eax),%eax
8010015a:	85 c0                	test   %eax,%eax
8010015c:	75 58                	jne    801001b6 <bget+0xf1>
8010015e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100161:	8b 00                	mov    (%eax),%eax
80100163:	83 e0 04             	and    $0x4,%eax
80100166:	85 c0                	test   %eax,%eax
80100168:	75 4c                	jne    801001b6 <bget+0xf1>
      b->dev = dev;
8010016a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016d:	8b 55 08             	mov    0x8(%ebp),%edx
80100170:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
80100173:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100176:	8b 55 0c             	mov    0xc(%ebp),%edx
80100179:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
8010017c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
80100185:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100188:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
8010018f:	83 ec 0c             	sub    $0xc,%esp
80100192:	68 60 d6 10 80       	push   $0x8010d660
80100197:	e8 76 51 00 00       	call   80105312 <release>
8010019c:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
8010019f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a2:	83 c0 0c             	add    $0xc,%eax
801001a5:	83 ec 0c             	sub    $0xc,%esp
801001a8:	50                   	push   %eax
801001a9:	e8 79 4f 00 00       	call   80105127 <acquiresleep>
801001ae:	83 c4 10             	add    $0x10,%esp
      return b;
801001b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b4:	eb 1f                	jmp    801001d5 <bget+0x110>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b9:	8b 40 50             	mov    0x50(%eax),%eax
801001bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001bf:	81 7d f4 5c 1d 11 80 	cmpl   $0x80111d5c,-0xc(%ebp)
801001c6:	75 8c                	jne    80100154 <bget+0x8f>
    }
  }
  panic("bget: no buffers");
801001c8:	83 ec 0c             	sub    $0xc,%esp
801001cb:	68 02 92 10 80       	push   $0x80109202
801001d0:	e8 33 04 00 00       	call   80100608 <panic>
}
801001d5:	c9                   	leave  
801001d6:	c3                   	ret    

801001d7 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001d7:	f3 0f 1e fb          	endbr32 
801001db:	55                   	push   %ebp
801001dc:	89 e5                	mov    %esp,%ebp
801001de:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001e1:	83 ec 08             	sub    $0x8,%esp
801001e4:	ff 75 0c             	pushl  0xc(%ebp)
801001e7:	ff 75 08             	pushl  0x8(%ebp)
801001ea:	e8 d6 fe ff ff       	call   801000c5 <bget>
801001ef:	83 c4 10             	add    $0x10,%esp
801001f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
801001f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001f8:	8b 00                	mov    (%eax),%eax
801001fa:	83 e0 02             	and    $0x2,%eax
801001fd:	85 c0                	test   %eax,%eax
801001ff:	75 0e                	jne    8010020f <bread+0x38>
    iderw(b);
80100201:	83 ec 0c             	sub    $0xc,%esp
80100204:	ff 75 f4             	pushl  -0xc(%ebp)
80100207:	e8 f7 28 00 00       	call   80102b03 <iderw>
8010020c:	83 c4 10             	add    $0x10,%esp
  }
  return b;
8010020f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100212:	c9                   	leave  
80100213:	c3                   	ret    

80100214 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
80100214:	f3 0f 1e fb          	endbr32 
80100218:	55                   	push   %ebp
80100219:	89 e5                	mov    %esp,%ebp
8010021b:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
8010021e:	8b 45 08             	mov    0x8(%ebp),%eax
80100221:	83 c0 0c             	add    $0xc,%eax
80100224:	83 ec 0c             	sub    $0xc,%esp
80100227:	50                   	push   %eax
80100228:	e8 b4 4f 00 00       	call   801051e1 <holdingsleep>
8010022d:	83 c4 10             	add    $0x10,%esp
80100230:	85 c0                	test   %eax,%eax
80100232:	75 0d                	jne    80100241 <bwrite+0x2d>
    panic("bwrite");
80100234:	83 ec 0c             	sub    $0xc,%esp
80100237:	68 13 92 10 80       	push   $0x80109213
8010023c:	e8 c7 03 00 00       	call   80100608 <panic>
  b->flags |= B_DIRTY;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 00                	mov    (%eax),%eax
80100246:	83 c8 04             	or     $0x4,%eax
80100249:	89 c2                	mov    %eax,%edx
8010024b:	8b 45 08             	mov    0x8(%ebp),%eax
8010024e:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100250:	83 ec 0c             	sub    $0xc,%esp
80100253:	ff 75 08             	pushl  0x8(%ebp)
80100256:	e8 a8 28 00 00       	call   80102b03 <iderw>
8010025b:	83 c4 10             	add    $0x10,%esp
}
8010025e:	90                   	nop
8010025f:	c9                   	leave  
80100260:	c3                   	ret    

80100261 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100261:	f3 0f 1e fb          	endbr32 
80100265:	55                   	push   %ebp
80100266:	89 e5                	mov    %esp,%ebp
80100268:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	83 c0 0c             	add    $0xc,%eax
80100271:	83 ec 0c             	sub    $0xc,%esp
80100274:	50                   	push   %eax
80100275:	e8 67 4f 00 00       	call   801051e1 <holdingsleep>
8010027a:	83 c4 10             	add    $0x10,%esp
8010027d:	85 c0                	test   %eax,%eax
8010027f:	75 0d                	jne    8010028e <brelse+0x2d>
    panic("brelse");
80100281:	83 ec 0c             	sub    $0xc,%esp
80100284:	68 1a 92 10 80       	push   $0x8010921a
80100289:	e8 7a 03 00 00       	call   80100608 <panic>

  releasesleep(&b->lock);
8010028e:	8b 45 08             	mov    0x8(%ebp),%eax
80100291:	83 c0 0c             	add    $0xc,%eax
80100294:	83 ec 0c             	sub    $0xc,%esp
80100297:	50                   	push   %eax
80100298:	e8 f2 4e 00 00       	call   8010518f <releasesleep>
8010029d:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002a0:	83 ec 0c             	sub    $0xc,%esp
801002a3:	68 60 d6 10 80       	push   $0x8010d660
801002a8:	e8 f3 4f 00 00       	call   801052a0 <acquire>
801002ad:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
801002b0:	8b 45 08             	mov    0x8(%ebp),%eax
801002b3:	8b 40 4c             	mov    0x4c(%eax),%eax
801002b6:	8d 50 ff             	lea    -0x1(%eax),%edx
801002b9:	8b 45 08             	mov    0x8(%ebp),%eax
801002bc:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002bf:	8b 45 08             	mov    0x8(%ebp),%eax
801002c2:	8b 40 4c             	mov    0x4c(%eax),%eax
801002c5:	85 c0                	test   %eax,%eax
801002c7:	75 47                	jne    80100310 <brelse+0xaf>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002c9:	8b 45 08             	mov    0x8(%ebp),%eax
801002cc:	8b 40 54             	mov    0x54(%eax),%eax
801002cf:	8b 55 08             	mov    0x8(%ebp),%edx
801002d2:	8b 52 50             	mov    0x50(%edx),%edx
801002d5:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801002d8:	8b 45 08             	mov    0x8(%ebp),%eax
801002db:	8b 40 50             	mov    0x50(%eax),%eax
801002de:	8b 55 08             	mov    0x8(%ebp),%edx
801002e1:	8b 52 54             	mov    0x54(%edx),%edx
801002e4:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
801002e7:	8b 15 b0 1d 11 80    	mov    0x80111db0,%edx
801002ed:	8b 45 08             	mov    0x8(%ebp),%eax
801002f0:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801002f3:	8b 45 08             	mov    0x8(%ebp),%eax
801002f6:	c7 40 50 5c 1d 11 80 	movl   $0x80111d5c,0x50(%eax)
    bcache.head.next->prev = b;
801002fd:	a1 b0 1d 11 80       	mov    0x80111db0,%eax
80100302:	8b 55 08             	mov    0x8(%ebp),%edx
80100305:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
80100308:	8b 45 08             	mov    0x8(%ebp),%eax
8010030b:	a3 b0 1d 11 80       	mov    %eax,0x80111db0
  }
  
  release(&bcache.lock);
80100310:	83 ec 0c             	sub    $0xc,%esp
80100313:	68 60 d6 10 80       	push   $0x8010d660
80100318:	e8 f5 4f 00 00       	call   80105312 <release>
8010031d:	83 c4 10             	add    $0x10,%esp
}
80100320:	90                   	nop
80100321:	c9                   	leave  
80100322:	c3                   	ret    

80100323 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80100323:	55                   	push   %ebp
80100324:	89 e5                	mov    %esp,%ebp
80100326:	83 ec 14             	sub    $0x14,%esp
80100329:	8b 45 08             	mov    0x8(%ebp),%eax
8010032c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80100330:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80100334:	89 c2                	mov    %eax,%edx
80100336:	ec                   	in     (%dx),%al
80100337:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010033a:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010033e:	c9                   	leave  
8010033f:	c3                   	ret    

80100340 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80100340:	55                   	push   %ebp
80100341:	89 e5                	mov    %esp,%ebp
80100343:	83 ec 08             	sub    $0x8,%esp
80100346:	8b 45 08             	mov    0x8(%ebp),%eax
80100349:	8b 55 0c             	mov    0xc(%ebp),%edx
8010034c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80100350:	89 d0                	mov    %edx,%eax
80100352:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100355:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100359:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010035d:	ee                   	out    %al,(%dx)
}
8010035e:	90                   	nop
8010035f:	c9                   	leave  
80100360:	c3                   	ret    

80100361 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100361:	55                   	push   %ebp
80100362:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100364:	fa                   	cli    
}
80100365:	90                   	nop
80100366:	5d                   	pop    %ebp
80100367:	c3                   	ret    

80100368 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100368:	f3 0f 1e fb          	endbr32 
8010036c:	55                   	push   %ebp
8010036d:	89 e5                	mov    %esp,%ebp
8010036f:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100372:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100376:	74 1c                	je     80100394 <printint+0x2c>
80100378:	8b 45 08             	mov    0x8(%ebp),%eax
8010037b:	c1 e8 1f             	shr    $0x1f,%eax
8010037e:	0f b6 c0             	movzbl %al,%eax
80100381:	89 45 10             	mov    %eax,0x10(%ebp)
80100384:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100388:	74 0a                	je     80100394 <printint+0x2c>
    x = -xx;
8010038a:	8b 45 08             	mov    0x8(%ebp),%eax
8010038d:	f7 d8                	neg    %eax
8010038f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100392:	eb 06                	jmp    8010039a <printint+0x32>
  else
    x = xx;
80100394:	8b 45 08             	mov    0x8(%ebp),%eax
80100397:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
8010039a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
801003a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003a7:	ba 00 00 00 00       	mov    $0x0,%edx
801003ac:	f7 f1                	div    %ecx
801003ae:	89 d1                	mov    %edx,%ecx
801003b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003b3:	8d 50 01             	lea    0x1(%eax),%edx
801003b6:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003b9:	0f b6 91 04 a0 10 80 	movzbl -0x7fef5ffc(%ecx),%edx
801003c0:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003ca:	ba 00 00 00 00       	mov    $0x0,%edx
801003cf:	f7 f1                	div    %ecx
801003d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003d4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003d8:	75 c7                	jne    801003a1 <printint+0x39>

  if(sign)
801003da:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003de:	74 2a                	je     8010040a <printint+0xa2>
    buf[i++] = '-';
801003e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003e3:	8d 50 01             	lea    0x1(%eax),%edx
801003e6:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003e9:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003ee:	eb 1a                	jmp    8010040a <printint+0xa2>
    consputc(buf[i]);
801003f0:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003f6:	01 d0                	add    %edx,%eax
801003f8:	0f b6 00             	movzbl (%eax),%eax
801003fb:	0f be c0             	movsbl %al,%eax
801003fe:	83 ec 0c             	sub    $0xc,%esp
80100401:	50                   	push   %eax
80100402:	e8 36 04 00 00       	call   8010083d <consputc>
80100407:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
8010040a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
8010040e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100412:	79 dc                	jns    801003f0 <printint+0x88>
}
80100414:	90                   	nop
80100415:	90                   	nop
80100416:	c9                   	leave  
80100417:	c3                   	ret    

80100418 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
80100418:	f3 0f 1e fb          	endbr32 
8010041c:	55                   	push   %ebp
8010041d:	89 e5                	mov    %esp,%ebp
8010041f:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
80100422:	a1 f4 c5 10 80       	mov    0x8010c5f4,%eax
80100427:	89 45 e8             	mov    %eax,-0x18(%ebp)
  //changed: added holding check
  if(locking && !holding(&cons.lock))
8010042a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010042e:	74 24                	je     80100454 <cprintf+0x3c>
80100430:	83 ec 0c             	sub    $0xc,%esp
80100433:	68 c0 c5 10 80       	push   $0x8010c5c0
80100438:	e8 aa 4f 00 00       	call   801053e7 <holding>
8010043d:	83 c4 10             	add    $0x10,%esp
80100440:	85 c0                	test   %eax,%eax
80100442:	75 10                	jne    80100454 <cprintf+0x3c>
    acquire(&cons.lock);
80100444:	83 ec 0c             	sub    $0xc,%esp
80100447:	68 c0 c5 10 80       	push   $0x8010c5c0
8010044c:	e8 4f 4e 00 00       	call   801052a0 <acquire>
80100451:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100454:	8b 45 08             	mov    0x8(%ebp),%eax
80100457:	85 c0                	test   %eax,%eax
80100459:	75 0d                	jne    80100468 <cprintf+0x50>
    panic("null fmt");
8010045b:	83 ec 0c             	sub    $0xc,%esp
8010045e:	68 24 92 10 80       	push   $0x80109224
80100463:	e8 a0 01 00 00       	call   80100608 <panic>

  argp = (uint*)(void*)(&fmt + 1);
80100468:	8d 45 0c             	lea    0xc(%ebp),%eax
8010046b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010046e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100475:	e9 52 01 00 00       	jmp    801005cc <cprintf+0x1b4>
    if(c != '%'){
8010047a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010047e:	74 13                	je     80100493 <cprintf+0x7b>
      consputc(c);
80100480:	83 ec 0c             	sub    $0xc,%esp
80100483:	ff 75 e4             	pushl  -0x1c(%ebp)
80100486:	e8 b2 03 00 00       	call   8010083d <consputc>
8010048b:	83 c4 10             	add    $0x10,%esp
      continue;
8010048e:	e9 35 01 00 00       	jmp    801005c8 <cprintf+0x1b0>
    }
    c = fmt[++i] & 0xff;
80100493:	8b 55 08             	mov    0x8(%ebp),%edx
80100496:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010049a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010049d:	01 d0                	add    %edx,%eax
8010049f:	0f b6 00             	movzbl (%eax),%eax
801004a2:	0f be c0             	movsbl %al,%eax
801004a5:	25 ff 00 00 00       	and    $0xff,%eax
801004aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
801004ad:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801004b1:	0f 84 37 01 00 00    	je     801005ee <cprintf+0x1d6>
      break;
    switch(c){
801004b7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004bb:	0f 84 dc 00 00 00    	je     8010059d <cprintf+0x185>
801004c1:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004c5:	0f 8c e1 00 00 00    	jl     801005ac <cprintf+0x194>
801004cb:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
801004cf:	0f 8f d7 00 00 00    	jg     801005ac <cprintf+0x194>
801004d5:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
801004d9:	0f 8c cd 00 00 00    	jl     801005ac <cprintf+0x194>
801004df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004e2:	83 e8 63             	sub    $0x63,%eax
801004e5:	83 f8 15             	cmp    $0x15,%eax
801004e8:	0f 87 be 00 00 00    	ja     801005ac <cprintf+0x194>
801004ee:	8b 04 85 34 92 10 80 	mov    -0x7fef6dcc(,%eax,4),%eax
801004f5:	3e ff e0             	notrack jmp *%eax
    case 'd':
      printint(*argp++, 10, 1);
801004f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004fb:	8d 50 04             	lea    0x4(%eax),%edx
801004fe:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100501:	8b 00                	mov    (%eax),%eax
80100503:	83 ec 04             	sub    $0x4,%esp
80100506:	6a 01                	push   $0x1
80100508:	6a 0a                	push   $0xa
8010050a:	50                   	push   %eax
8010050b:	e8 58 fe ff ff       	call   80100368 <printint>
80100510:	83 c4 10             	add    $0x10,%esp
      break;
80100513:	e9 b0 00 00 00       	jmp    801005c8 <cprintf+0x1b0>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100518:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010051b:	8d 50 04             	lea    0x4(%eax),%edx
8010051e:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100521:	8b 00                	mov    (%eax),%eax
80100523:	83 ec 04             	sub    $0x4,%esp
80100526:	6a 00                	push   $0x0
80100528:	6a 10                	push   $0x10
8010052a:	50                   	push   %eax
8010052b:	e8 38 fe ff ff       	call   80100368 <printint>
80100530:	83 c4 10             	add    $0x10,%esp
      break;
80100533:	e9 90 00 00 00       	jmp    801005c8 <cprintf+0x1b0>
    case 's':
      if((s = (char*)*argp++) == 0)
80100538:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010053b:	8d 50 04             	lea    0x4(%eax),%edx
8010053e:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100541:	8b 00                	mov    (%eax),%eax
80100543:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100546:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010054a:	75 22                	jne    8010056e <cprintf+0x156>
        s = "(null)";
8010054c:	c7 45 ec 2d 92 10 80 	movl   $0x8010922d,-0x14(%ebp)
      for(; *s; s++)
80100553:	eb 19                	jmp    8010056e <cprintf+0x156>
        consputc(*s);
80100555:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100558:	0f b6 00             	movzbl (%eax),%eax
8010055b:	0f be c0             	movsbl %al,%eax
8010055e:	83 ec 0c             	sub    $0xc,%esp
80100561:	50                   	push   %eax
80100562:	e8 d6 02 00 00       	call   8010083d <consputc>
80100567:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010056a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010056e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100571:	0f b6 00             	movzbl (%eax),%eax
80100574:	84 c0                	test   %al,%al
80100576:	75 dd                	jne    80100555 <cprintf+0x13d>
      break;
80100578:	eb 4e                	jmp    801005c8 <cprintf+0x1b0>
    case 'c':
      s = (char*)argp++;
8010057a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010057d:	8d 50 04             	lea    0x4(%eax),%edx
80100580:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100583:	89 45 ec             	mov    %eax,-0x14(%ebp)
      consputc(*(s));
80100586:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100589:	0f b6 00             	movzbl (%eax),%eax
8010058c:	0f be c0             	movsbl %al,%eax
8010058f:	83 ec 0c             	sub    $0xc,%esp
80100592:	50                   	push   %eax
80100593:	e8 a5 02 00 00       	call   8010083d <consputc>
80100598:	83 c4 10             	add    $0x10,%esp
      break;
8010059b:	eb 2b                	jmp    801005c8 <cprintf+0x1b0>
    case '%':
      consputc('%');
8010059d:	83 ec 0c             	sub    $0xc,%esp
801005a0:	6a 25                	push   $0x25
801005a2:	e8 96 02 00 00       	call   8010083d <consputc>
801005a7:	83 c4 10             	add    $0x10,%esp
      break;
801005aa:	eb 1c                	jmp    801005c8 <cprintf+0x1b0>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801005ac:	83 ec 0c             	sub    $0xc,%esp
801005af:	6a 25                	push   $0x25
801005b1:	e8 87 02 00 00       	call   8010083d <consputc>
801005b6:	83 c4 10             	add    $0x10,%esp
      consputc(c);
801005b9:	83 ec 0c             	sub    $0xc,%esp
801005bc:	ff 75 e4             	pushl  -0x1c(%ebp)
801005bf:	e8 79 02 00 00       	call   8010083d <consputc>
801005c4:	83 c4 10             	add    $0x10,%esp
      break;
801005c7:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801005c8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005cc:	8b 55 08             	mov    0x8(%ebp),%edx
801005cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d2:	01 d0                	add    %edx,%eax
801005d4:	0f b6 00             	movzbl (%eax),%eax
801005d7:	0f be c0             	movsbl %al,%eax
801005da:	25 ff 00 00 00       	and    $0xff,%eax
801005df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801005e2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801005e6:	0f 85 8e fe ff ff    	jne    8010047a <cprintf+0x62>
801005ec:	eb 01                	jmp    801005ef <cprintf+0x1d7>
      break;
801005ee:	90                   	nop
    }
  }

  if(locking)
801005ef:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801005f3:	74 10                	je     80100605 <cprintf+0x1ed>
    release(&cons.lock);
801005f5:	83 ec 0c             	sub    $0xc,%esp
801005f8:	68 c0 c5 10 80       	push   $0x8010c5c0
801005fd:	e8 10 4d 00 00       	call   80105312 <release>
80100602:	83 c4 10             	add    $0x10,%esp
}
80100605:	90                   	nop
80100606:	c9                   	leave  
80100607:	c3                   	ret    

80100608 <panic>:

void
panic(char *s)
{
80100608:	f3 0f 1e fb          	endbr32 
8010060c:	55                   	push   %ebp
8010060d:	89 e5                	mov    %esp,%ebp
8010060f:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
80100612:	e8 4a fd ff ff       	call   80100361 <cli>
  cons.locking = 0;
80100617:	c7 05 f4 c5 10 80 00 	movl   $0x0,0x8010c5f4
8010061e:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
80100621:	e8 a9 2b 00 00       	call   801031cf <lapicid>
80100626:	83 ec 08             	sub    $0x8,%esp
80100629:	50                   	push   %eax
8010062a:	68 8c 92 10 80       	push   $0x8010928c
8010062f:	e8 e4 fd ff ff       	call   80100418 <cprintf>
80100634:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
80100637:	8b 45 08             	mov    0x8(%ebp),%eax
8010063a:	83 ec 0c             	sub    $0xc,%esp
8010063d:	50                   	push   %eax
8010063e:	e8 d5 fd ff ff       	call   80100418 <cprintf>
80100643:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80100646:	83 ec 0c             	sub    $0xc,%esp
80100649:	68 a0 92 10 80       	push   $0x801092a0
8010064e:	e8 c5 fd ff ff       	call   80100418 <cprintf>
80100653:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
80100656:	83 ec 08             	sub    $0x8,%esp
80100659:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010065c:	50                   	push   %eax
8010065d:	8d 45 08             	lea    0x8(%ebp),%eax
80100660:	50                   	push   %eax
80100661:	e8 02 4d 00 00       	call   80105368 <getcallerpcs>
80100666:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100669:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100670:	eb 1c                	jmp    8010068e <panic+0x86>
    cprintf(" %p", pcs[i]);
80100672:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100675:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100679:	83 ec 08             	sub    $0x8,%esp
8010067c:	50                   	push   %eax
8010067d:	68 a2 92 10 80       	push   $0x801092a2
80100682:	e8 91 fd ff ff       	call   80100418 <cprintf>
80100687:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
8010068a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010068e:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80100692:	7e de                	jle    80100672 <panic+0x6a>
  panicked = 1; // freeze other CPU
80100694:	c7 05 a0 c5 10 80 01 	movl   $0x1,0x8010c5a0
8010069b:	00 00 00 
  for(;;)
8010069e:	eb fe                	jmp    8010069e <panic+0x96>

801006a0 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801006a0:	f3 0f 1e fb          	endbr32 
801006a4:	55                   	push   %ebp
801006a5:	89 e5                	mov    %esp,%ebp
801006a7:	53                   	push   %ebx
801006a8:	83 ec 14             	sub    $0x14,%esp
  int pos;

  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801006ab:	6a 0e                	push   $0xe
801006ad:	68 d4 03 00 00       	push   $0x3d4
801006b2:	e8 89 fc ff ff       	call   80100340 <outb>
801006b7:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
801006ba:	68 d5 03 00 00       	push   $0x3d5
801006bf:	e8 5f fc ff ff       	call   80100323 <inb>
801006c4:	83 c4 04             	add    $0x4,%esp
801006c7:	0f b6 c0             	movzbl %al,%eax
801006ca:	c1 e0 08             	shl    $0x8,%eax
801006cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
801006d0:	6a 0f                	push   $0xf
801006d2:	68 d4 03 00 00       	push   $0x3d4
801006d7:	e8 64 fc ff ff       	call   80100340 <outb>
801006dc:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
801006df:	68 d5 03 00 00       	push   $0x3d5
801006e4:	e8 3a fc ff ff       	call   80100323 <inb>
801006e9:	83 c4 04             	add    $0x4,%esp
801006ec:	0f b6 c0             	movzbl %al,%eax
801006ef:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
801006f2:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
801006f6:	75 30                	jne    80100728 <cgaputc+0x88>
    pos += 80 - pos%80;
801006f8:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006fb:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100700:	89 c8                	mov    %ecx,%eax
80100702:	f7 ea                	imul   %edx
80100704:	c1 fa 05             	sar    $0x5,%edx
80100707:	89 c8                	mov    %ecx,%eax
80100709:	c1 f8 1f             	sar    $0x1f,%eax
8010070c:	29 c2                	sub    %eax,%edx
8010070e:	89 d0                	mov    %edx,%eax
80100710:	c1 e0 02             	shl    $0x2,%eax
80100713:	01 d0                	add    %edx,%eax
80100715:	c1 e0 04             	shl    $0x4,%eax
80100718:	29 c1                	sub    %eax,%ecx
8010071a:	89 ca                	mov    %ecx,%edx
8010071c:	b8 50 00 00 00       	mov    $0x50,%eax
80100721:	29 d0                	sub    %edx,%eax
80100723:	01 45 f4             	add    %eax,-0xc(%ebp)
80100726:	eb 38                	jmp    80100760 <cgaputc+0xc0>
  else if(c == BACKSPACE){
80100728:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010072f:	75 0c                	jne    8010073d <cgaputc+0x9d>
    if(pos > 0) --pos;
80100731:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100735:	7e 29                	jle    80100760 <cgaputc+0xc0>
80100737:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
8010073b:	eb 23                	jmp    80100760 <cgaputc+0xc0>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010073d:	8b 45 08             	mov    0x8(%ebp),%eax
80100740:	0f b6 c0             	movzbl %al,%eax
80100743:	80 cc 07             	or     $0x7,%ah
80100746:	89 c3                	mov    %eax,%ebx
80100748:	8b 0d 00 a0 10 80    	mov    0x8010a000,%ecx
8010074e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100751:	8d 50 01             	lea    0x1(%eax),%edx
80100754:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100757:	01 c0                	add    %eax,%eax
80100759:	01 c8                	add    %ecx,%eax
8010075b:	89 da                	mov    %ebx,%edx
8010075d:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
80100760:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100764:	78 09                	js     8010076f <cgaputc+0xcf>
80100766:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
8010076d:	7e 0d                	jle    8010077c <cgaputc+0xdc>
    panic("pos under/overflow");
8010076f:	83 ec 0c             	sub    $0xc,%esp
80100772:	68 a6 92 10 80       	push   $0x801092a6
80100777:	e8 8c fe ff ff       	call   80100608 <panic>

  if((pos/80) >= 24){  // Scroll up.
8010077c:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
80100783:	7e 4c                	jle    801007d1 <cgaputc+0x131>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100785:	a1 00 a0 10 80       	mov    0x8010a000,%eax
8010078a:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
80100790:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100795:	83 ec 04             	sub    $0x4,%esp
80100798:	68 60 0e 00 00       	push   $0xe60
8010079d:	52                   	push   %edx
8010079e:	50                   	push   %eax
8010079f:	e8 62 4e 00 00       	call   80105606 <memmove>
801007a4:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801007a7:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801007ab:	b8 80 07 00 00       	mov    $0x780,%eax
801007b0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801007b3:	8d 14 00             	lea    (%eax,%eax,1),%edx
801007b6:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801007bb:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801007be:	01 c9                	add    %ecx,%ecx
801007c0:	01 c8                	add    %ecx,%eax
801007c2:	83 ec 04             	sub    $0x4,%esp
801007c5:	52                   	push   %edx
801007c6:	6a 00                	push   $0x0
801007c8:	50                   	push   %eax
801007c9:	e8 71 4d 00 00       	call   8010553f <memset>
801007ce:	83 c4 10             	add    $0x10,%esp
  }

  outb(CRTPORT, 14);
801007d1:	83 ec 08             	sub    $0x8,%esp
801007d4:	6a 0e                	push   $0xe
801007d6:	68 d4 03 00 00       	push   $0x3d4
801007db:	e8 60 fb ff ff       	call   80100340 <outb>
801007e0:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
801007e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007e6:	c1 f8 08             	sar    $0x8,%eax
801007e9:	0f b6 c0             	movzbl %al,%eax
801007ec:	83 ec 08             	sub    $0x8,%esp
801007ef:	50                   	push   %eax
801007f0:	68 d5 03 00 00       	push   $0x3d5
801007f5:	e8 46 fb ff ff       	call   80100340 <outb>
801007fa:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
801007fd:	83 ec 08             	sub    $0x8,%esp
80100800:	6a 0f                	push   $0xf
80100802:	68 d4 03 00 00       	push   $0x3d4
80100807:	e8 34 fb ff ff       	call   80100340 <outb>
8010080c:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
8010080f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100812:	0f b6 c0             	movzbl %al,%eax
80100815:	83 ec 08             	sub    $0x8,%esp
80100818:	50                   	push   %eax
80100819:	68 d5 03 00 00       	push   $0x3d5
8010081e:	e8 1d fb ff ff       	call   80100340 <outb>
80100823:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
80100826:	a1 00 a0 10 80       	mov    0x8010a000,%eax
8010082b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010082e:	01 d2                	add    %edx,%edx
80100830:	01 d0                	add    %edx,%eax
80100832:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100837:	90                   	nop
80100838:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010083b:	c9                   	leave  
8010083c:	c3                   	ret    

8010083d <consputc>:

void
consputc(int c)
{
8010083d:	f3 0f 1e fb          	endbr32 
80100841:	55                   	push   %ebp
80100842:	89 e5                	mov    %esp,%ebp
80100844:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100847:	a1 a0 c5 10 80       	mov    0x8010c5a0,%eax
8010084c:	85 c0                	test   %eax,%eax
8010084e:	74 07                	je     80100857 <consputc+0x1a>
    cli();
80100850:	e8 0c fb ff ff       	call   80100361 <cli>
    for(;;)
80100855:	eb fe                	jmp    80100855 <consputc+0x18>
      ;
  }

  if(c == BACKSPACE){
80100857:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010085e:	75 29                	jne    80100889 <consputc+0x4c>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100860:	83 ec 0c             	sub    $0xc,%esp
80100863:	6a 08                	push   $0x8
80100865:	e8 e4 67 00 00       	call   8010704e <uartputc>
8010086a:	83 c4 10             	add    $0x10,%esp
8010086d:	83 ec 0c             	sub    $0xc,%esp
80100870:	6a 20                	push   $0x20
80100872:	e8 d7 67 00 00       	call   8010704e <uartputc>
80100877:	83 c4 10             	add    $0x10,%esp
8010087a:	83 ec 0c             	sub    $0xc,%esp
8010087d:	6a 08                	push   $0x8
8010087f:	e8 ca 67 00 00       	call   8010704e <uartputc>
80100884:	83 c4 10             	add    $0x10,%esp
80100887:	eb 0e                	jmp    80100897 <consputc+0x5a>
  } else
    uartputc(c);
80100889:	83 ec 0c             	sub    $0xc,%esp
8010088c:	ff 75 08             	pushl  0x8(%ebp)
8010088f:	e8 ba 67 00 00       	call   8010704e <uartputc>
80100894:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
80100897:	83 ec 0c             	sub    $0xc,%esp
8010089a:	ff 75 08             	pushl  0x8(%ebp)
8010089d:	e8 fe fd ff ff       	call   801006a0 <cgaputc>
801008a2:	83 c4 10             	add    $0x10,%esp
}
801008a5:	90                   	nop
801008a6:	c9                   	leave  
801008a7:	c3                   	ret    

801008a8 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801008a8:	f3 0f 1e fb          	endbr32 
801008ac:	55                   	push   %ebp
801008ad:	89 e5                	mov    %esp,%ebp
801008af:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801008b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801008b9:	83 ec 0c             	sub    $0xc,%esp
801008bc:	68 c0 c5 10 80       	push   $0x8010c5c0
801008c1:	e8 da 49 00 00       	call   801052a0 <acquire>
801008c6:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801008c9:	e9 52 01 00 00       	jmp    80100a20 <consoleintr+0x178>
    switch(c){
801008ce:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801008d2:	0f 84 81 00 00 00    	je     80100959 <consoleintr+0xb1>
801008d8:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801008dc:	0f 8f ac 00 00 00    	jg     8010098e <consoleintr+0xe6>
801008e2:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
801008e6:	74 43                	je     8010092b <consoleintr+0x83>
801008e8:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
801008ec:	0f 8f 9c 00 00 00    	jg     8010098e <consoleintr+0xe6>
801008f2:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
801008f6:	74 61                	je     80100959 <consoleintr+0xb1>
801008f8:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
801008fc:	0f 85 8c 00 00 00    	jne    8010098e <consoleintr+0xe6>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
80100902:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100909:	e9 12 01 00 00       	jmp    80100a20 <consoleintr+0x178>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
8010090e:	a1 48 20 11 80       	mov    0x80112048,%eax
80100913:	83 e8 01             	sub    $0x1,%eax
80100916:	a3 48 20 11 80       	mov    %eax,0x80112048
        consputc(BACKSPACE);
8010091b:	83 ec 0c             	sub    $0xc,%esp
8010091e:	68 00 01 00 00       	push   $0x100
80100923:	e8 15 ff ff ff       	call   8010083d <consputc>
80100928:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
8010092b:	8b 15 48 20 11 80    	mov    0x80112048,%edx
80100931:	a1 44 20 11 80       	mov    0x80112044,%eax
80100936:	39 c2                	cmp    %eax,%edx
80100938:	0f 84 e2 00 00 00    	je     80100a20 <consoleintr+0x178>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010093e:	a1 48 20 11 80       	mov    0x80112048,%eax
80100943:	83 e8 01             	sub    $0x1,%eax
80100946:	83 e0 7f             	and    $0x7f,%eax
80100949:	0f b6 80 c0 1f 11 80 	movzbl -0x7feee040(%eax),%eax
      while(input.e != input.w &&
80100950:	3c 0a                	cmp    $0xa,%al
80100952:	75 ba                	jne    8010090e <consoleintr+0x66>
      }
      break;
80100954:	e9 c7 00 00 00       	jmp    80100a20 <consoleintr+0x178>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100959:	8b 15 48 20 11 80    	mov    0x80112048,%edx
8010095f:	a1 44 20 11 80       	mov    0x80112044,%eax
80100964:	39 c2                	cmp    %eax,%edx
80100966:	0f 84 b4 00 00 00    	je     80100a20 <consoleintr+0x178>
        input.e--;
8010096c:	a1 48 20 11 80       	mov    0x80112048,%eax
80100971:	83 e8 01             	sub    $0x1,%eax
80100974:	a3 48 20 11 80       	mov    %eax,0x80112048
        consputc(BACKSPACE);
80100979:	83 ec 0c             	sub    $0xc,%esp
8010097c:	68 00 01 00 00       	push   $0x100
80100981:	e8 b7 fe ff ff       	call   8010083d <consputc>
80100986:	83 c4 10             	add    $0x10,%esp
      }
      break;
80100989:	e9 92 00 00 00       	jmp    80100a20 <consoleintr+0x178>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010098e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100992:	0f 84 87 00 00 00    	je     80100a1f <consoleintr+0x177>
80100998:	8b 15 48 20 11 80    	mov    0x80112048,%edx
8010099e:	a1 40 20 11 80       	mov    0x80112040,%eax
801009a3:	29 c2                	sub    %eax,%edx
801009a5:	89 d0                	mov    %edx,%eax
801009a7:	83 f8 7f             	cmp    $0x7f,%eax
801009aa:	77 73                	ja     80100a1f <consoleintr+0x177>
        c = (c == '\r') ? '\n' : c;
801009ac:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801009b0:	74 05                	je     801009b7 <consoleintr+0x10f>
801009b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801009b5:	eb 05                	jmp    801009bc <consoleintr+0x114>
801009b7:	b8 0a 00 00 00       	mov    $0xa,%eax
801009bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801009bf:	a1 48 20 11 80       	mov    0x80112048,%eax
801009c4:	8d 50 01             	lea    0x1(%eax),%edx
801009c7:	89 15 48 20 11 80    	mov    %edx,0x80112048
801009cd:	83 e0 7f             	and    $0x7f,%eax
801009d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801009d3:	88 90 c0 1f 11 80    	mov    %dl,-0x7feee040(%eax)
        consputc(c);
801009d9:	83 ec 0c             	sub    $0xc,%esp
801009dc:	ff 75 f0             	pushl  -0x10(%ebp)
801009df:	e8 59 fe ff ff       	call   8010083d <consputc>
801009e4:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801009e7:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
801009eb:	74 18                	je     80100a05 <consoleintr+0x15d>
801009ed:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801009f1:	74 12                	je     80100a05 <consoleintr+0x15d>
801009f3:	a1 48 20 11 80       	mov    0x80112048,%eax
801009f8:	8b 15 40 20 11 80    	mov    0x80112040,%edx
801009fe:	83 ea 80             	sub    $0xffffff80,%edx
80100a01:	39 d0                	cmp    %edx,%eax
80100a03:	75 1a                	jne    80100a1f <consoleintr+0x177>
          input.w = input.e;
80100a05:	a1 48 20 11 80       	mov    0x80112048,%eax
80100a0a:	a3 44 20 11 80       	mov    %eax,0x80112044
          wakeup(&input.r);
80100a0f:	83 ec 0c             	sub    $0xc,%esp
80100a12:	68 40 20 11 80       	push   $0x80112040
80100a17:	e8 04 45 00 00       	call   80104f20 <wakeup>
80100a1c:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100a1f:	90                   	nop
  while((c = getc()) >= 0){
80100a20:	8b 45 08             	mov    0x8(%ebp),%eax
80100a23:	ff d0                	call   *%eax
80100a25:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100a28:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100a2c:	0f 89 9c fe ff ff    	jns    801008ce <consoleintr+0x26>
    }
  }
  release(&cons.lock);
80100a32:	83 ec 0c             	sub    $0xc,%esp
80100a35:	68 c0 c5 10 80       	push   $0x8010c5c0
80100a3a:	e8 d3 48 00 00       	call   80105312 <release>
80100a3f:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100a42:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100a46:	74 05                	je     80100a4d <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
80100a48:	e8 99 45 00 00       	call   80104fe6 <procdump>
  }
}
80100a4d:	90                   	nop
80100a4e:	c9                   	leave  
80100a4f:	c3                   	ret    

80100a50 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100a50:	f3 0f 1e fb          	endbr32 
80100a54:	55                   	push   %ebp
80100a55:	89 e5                	mov    %esp,%ebp
80100a57:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100a5a:	83 ec 0c             	sub    $0xc,%esp
80100a5d:	ff 75 08             	pushl  0x8(%ebp)
80100a60:	e8 24 12 00 00       	call   80101c89 <iunlock>
80100a65:	83 c4 10             	add    $0x10,%esp
  target = n;
80100a68:	8b 45 10             	mov    0x10(%ebp),%eax
80100a6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a6e:	83 ec 0c             	sub    $0xc,%esp
80100a71:	68 c0 c5 10 80       	push   $0x8010c5c0
80100a76:	e8 25 48 00 00       	call   801052a0 <acquire>
80100a7b:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100a7e:	e9 ab 00 00 00       	jmp    80100b2e <consoleread+0xde>
    while(input.r == input.w){
      if(myproc()->killed){
80100a83:	e8 78 3a 00 00       	call   80104500 <myproc>
80100a88:	8b 40 24             	mov    0x24(%eax),%eax
80100a8b:	85 c0                	test   %eax,%eax
80100a8d:	74 28                	je     80100ab7 <consoleread+0x67>
        release(&cons.lock);
80100a8f:	83 ec 0c             	sub    $0xc,%esp
80100a92:	68 c0 c5 10 80       	push   $0x8010c5c0
80100a97:	e8 76 48 00 00       	call   80105312 <release>
80100a9c:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a9f:	83 ec 0c             	sub    $0xc,%esp
80100aa2:	ff 75 08             	pushl  0x8(%ebp)
80100aa5:	e8 c8 10 00 00       	call   80101b72 <ilock>
80100aaa:	83 c4 10             	add    $0x10,%esp
        return -1;
80100aad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ab2:	e9 ab 00 00 00       	jmp    80100b62 <consoleread+0x112>
      }
      sleep(&input.r, &cons.lock);
80100ab7:	83 ec 08             	sub    $0x8,%esp
80100aba:	68 c0 c5 10 80       	push   $0x8010c5c0
80100abf:	68 40 20 11 80       	push   $0x80112040
80100ac4:	e8 65 43 00 00       	call   80104e2e <sleep>
80100ac9:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
80100acc:	8b 15 40 20 11 80    	mov    0x80112040,%edx
80100ad2:	a1 44 20 11 80       	mov    0x80112044,%eax
80100ad7:	39 c2                	cmp    %eax,%edx
80100ad9:	74 a8                	je     80100a83 <consoleread+0x33>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100adb:	a1 40 20 11 80       	mov    0x80112040,%eax
80100ae0:	8d 50 01             	lea    0x1(%eax),%edx
80100ae3:	89 15 40 20 11 80    	mov    %edx,0x80112040
80100ae9:	83 e0 7f             	and    $0x7f,%eax
80100aec:	0f b6 80 c0 1f 11 80 	movzbl -0x7feee040(%eax),%eax
80100af3:	0f be c0             	movsbl %al,%eax
80100af6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100af9:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100afd:	75 17                	jne    80100b16 <consoleread+0xc6>
      if(n < target){
80100aff:	8b 45 10             	mov    0x10(%ebp),%eax
80100b02:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100b05:	76 2f                	jbe    80100b36 <consoleread+0xe6>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100b07:	a1 40 20 11 80       	mov    0x80112040,%eax
80100b0c:	83 e8 01             	sub    $0x1,%eax
80100b0f:	a3 40 20 11 80       	mov    %eax,0x80112040
      }
      break;
80100b14:	eb 20                	jmp    80100b36 <consoleread+0xe6>
    }
    *dst++ = c;
80100b16:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b19:	8d 50 01             	lea    0x1(%eax),%edx
80100b1c:	89 55 0c             	mov    %edx,0xc(%ebp)
80100b1f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100b22:	88 10                	mov    %dl,(%eax)
    --n;
80100b24:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100b28:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100b2c:	74 0b                	je     80100b39 <consoleread+0xe9>
  while(n > 0){
80100b2e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100b32:	7f 98                	jg     80100acc <consoleread+0x7c>
80100b34:	eb 04                	jmp    80100b3a <consoleread+0xea>
      break;
80100b36:	90                   	nop
80100b37:	eb 01                	jmp    80100b3a <consoleread+0xea>
      break;
80100b39:	90                   	nop
  }
  release(&cons.lock);
80100b3a:	83 ec 0c             	sub    $0xc,%esp
80100b3d:	68 c0 c5 10 80       	push   $0x8010c5c0
80100b42:	e8 cb 47 00 00       	call   80105312 <release>
80100b47:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b4a:	83 ec 0c             	sub    $0xc,%esp
80100b4d:	ff 75 08             	pushl  0x8(%ebp)
80100b50:	e8 1d 10 00 00       	call   80101b72 <ilock>
80100b55:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100b58:	8b 45 10             	mov    0x10(%ebp),%eax
80100b5b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b5e:	29 c2                	sub    %eax,%edx
80100b60:	89 d0                	mov    %edx,%eax
}
80100b62:	c9                   	leave  
80100b63:	c3                   	ret    

80100b64 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100b64:	f3 0f 1e fb          	endbr32 
80100b68:	55                   	push   %ebp
80100b69:	89 e5                	mov    %esp,%ebp
80100b6b:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100b6e:	83 ec 0c             	sub    $0xc,%esp
80100b71:	ff 75 08             	pushl  0x8(%ebp)
80100b74:	e8 10 11 00 00       	call   80101c89 <iunlock>
80100b79:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100b7c:	83 ec 0c             	sub    $0xc,%esp
80100b7f:	68 c0 c5 10 80       	push   $0x8010c5c0
80100b84:	e8 17 47 00 00       	call   801052a0 <acquire>
80100b89:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b8c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100b93:	eb 21                	jmp    80100bb6 <consolewrite+0x52>
    consputc(buf[i] & 0xff);
80100b95:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b98:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b9b:	01 d0                	add    %edx,%eax
80100b9d:	0f b6 00             	movzbl (%eax),%eax
80100ba0:	0f be c0             	movsbl %al,%eax
80100ba3:	0f b6 c0             	movzbl %al,%eax
80100ba6:	83 ec 0c             	sub    $0xc,%esp
80100ba9:	50                   	push   %eax
80100baa:	e8 8e fc ff ff       	call   8010083d <consputc>
80100baf:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100bb2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100bb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100bb9:	3b 45 10             	cmp    0x10(%ebp),%eax
80100bbc:	7c d7                	jl     80100b95 <consolewrite+0x31>
  release(&cons.lock);
80100bbe:	83 ec 0c             	sub    $0xc,%esp
80100bc1:	68 c0 c5 10 80       	push   $0x8010c5c0
80100bc6:	e8 47 47 00 00       	call   80105312 <release>
80100bcb:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100bce:	83 ec 0c             	sub    $0xc,%esp
80100bd1:	ff 75 08             	pushl  0x8(%ebp)
80100bd4:	e8 99 0f 00 00       	call   80101b72 <ilock>
80100bd9:	83 c4 10             	add    $0x10,%esp

  return n;
80100bdc:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100bdf:	c9                   	leave  
80100be0:	c3                   	ret    

80100be1 <consoleinit>:

void
consoleinit(void)
{
80100be1:	f3 0f 1e fb          	endbr32 
80100be5:	55                   	push   %ebp
80100be6:	89 e5                	mov    %esp,%ebp
80100be8:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100beb:	83 ec 08             	sub    $0x8,%esp
80100bee:	68 b9 92 10 80       	push   $0x801092b9
80100bf3:	68 c0 c5 10 80       	push   $0x8010c5c0
80100bf8:	e8 7d 46 00 00       	call   8010527a <initlock>
80100bfd:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100c00:	c7 05 0c 2a 11 80 64 	movl   $0x80100b64,0x80112a0c
80100c07:	0b 10 80 
  devsw[CONSOLE].read = consoleread;
80100c0a:	c7 05 08 2a 11 80 50 	movl   $0x80100a50,0x80112a08
80100c11:	0a 10 80 
  cons.locking = 1;
80100c14:	c7 05 f4 c5 10 80 01 	movl   $0x1,0x8010c5f4
80100c1b:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100c1e:	83 ec 08             	sub    $0x8,%esp
80100c21:	6a 00                	push   $0x0
80100c23:	6a 01                	push   $0x1
80100c25:	e8 b2 20 00 00       	call   80102cdc <ioapicenable>
80100c2a:	83 c4 10             	add    $0x10,%esp
}
80100c2d:	90                   	nop
80100c2e:	c9                   	leave  
80100c2f:	c3                   	ret    

80100c30 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100c30:	f3 0f 1e fb          	endbr32 
80100c34:	55                   	push   %ebp
80100c35:	89 e5                	mov    %esp,%ebp
80100c37:	81 ec 28 01 00 00    	sub    $0x128,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100c3d:	e8 be 38 00 00       	call   80104500 <myproc>
80100c42:	89 45 c8             	mov    %eax,-0x38(%ebp)
  //pte_t pages[CLOCKSIZE];

  //struct clock_q clock;

  int len=0;
80100c45:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
  int clock_hand = 0;
80100c4c:	c7 45 c0 00 00 00 00 	movl   $0x0,-0x40(%ebp)
  for(int i=0;i<CLOCKSIZE;i++){
80100c53:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
80100c5a:	eb 15                	jmp    80100c71 <exec+0x41>
     curproc->pages[i]=0;
80100c5c:	8b 45 c8             	mov    -0x38(%ebp),%eax
80100c5f:	8b 55 d0             	mov    -0x30(%ebp),%edx
80100c62:	83 c2 1c             	add    $0x1c,%edx
80100c65:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80100c6c:	00 
  for(int i=0;i<CLOCKSIZE;i++){
80100c6d:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
80100c71:	83 7d d0 07          	cmpl   $0x7,-0x30(%ebp)
80100c75:	7e e5                	jle    80100c5c <exec+0x2c>
  }
  curproc->cl_len = len;
80100c77:	8b 45 c8             	mov    -0x38(%ebp),%eax
80100c7a:	8b 55 c4             	mov    -0x3c(%ebp),%edx
80100c7d:	89 90 a0 00 00 00    	mov    %edx,0xa0(%eax)
  curproc->clock_hand = clock_hand;
80100c83:	8b 45 c8             	mov    -0x38(%ebp),%eax
80100c86:	8b 55 c0             	mov    -0x40(%ebp),%edx
80100c89:	89 90 9c 00 00 00    	mov    %edx,0x9c(%eax)
  // }
  // curproc->clock = &clock;
  
  

  begin_op();
80100c8f:	e8 ad 2a 00 00       	call   80103741 <begin_op>

  if((ip = namei(path)) == 0){
80100c94:	83 ec 0c             	sub    $0xc,%esp
80100c97:	ff 75 08             	pushl  0x8(%ebp)
80100c9a:	e8 3e 1a 00 00       	call   801026dd <namei>
80100c9f:	83 c4 10             	add    $0x10,%esp
80100ca2:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100ca5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100ca9:	75 1f                	jne    80100cca <exec+0x9a>
    end_op();
80100cab:	e8 21 2b 00 00       	call   801037d1 <end_op>
    cprintf("exec: fail\n");
80100cb0:	83 ec 0c             	sub    $0xc,%esp
80100cb3:	68 c1 92 10 80       	push   $0x801092c1
80100cb8:	e8 5b f7 ff ff       	call   80100418 <cprintf>
80100cbd:	83 c4 10             	add    $0x10,%esp
    return -1;
80100cc0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100cc5:	e9 3e 04 00 00       	jmp    80101108 <exec+0x4d8>
  }
  ilock(ip);
80100cca:	83 ec 0c             	sub    $0xc,%esp
80100ccd:	ff 75 d8             	pushl  -0x28(%ebp)
80100cd0:	e8 9d 0e 00 00       	call   80101b72 <ilock>
80100cd5:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100cd8:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100cdf:	6a 34                	push   $0x34
80100ce1:	6a 00                	push   $0x0
80100ce3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
80100ce9:	50                   	push   %eax
80100cea:	ff 75 d8             	pushl  -0x28(%ebp)
80100ced:	e8 88 13 00 00       	call   8010207a <readi>
80100cf2:	83 c4 10             	add    $0x10,%esp
80100cf5:	83 f8 34             	cmp    $0x34,%eax
80100cf8:	0f 85 b3 03 00 00    	jne    801010b1 <exec+0x481>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100cfe:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100d04:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100d09:	0f 85 a5 03 00 00    	jne    801010b4 <exec+0x484>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100d0f:	e8 71 73 00 00       	call   80108085 <setupkvm>
80100d14:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100d17:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100d1b:	0f 84 96 03 00 00    	je     801010b7 <exec+0x487>
    goto bad;

  // Load program into memory.
  sz = 0;
80100d21:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d28:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100d2f:	8b 85 14 ff ff ff    	mov    -0xec(%ebp),%eax
80100d35:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d38:	e9 de 00 00 00       	jmp    80100e1b <exec+0x1eb>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100d3d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d40:	6a 20                	push   $0x20
80100d42:	50                   	push   %eax
80100d43:	8d 85 d8 fe ff ff    	lea    -0x128(%ebp),%eax
80100d49:	50                   	push   %eax
80100d4a:	ff 75 d8             	pushl  -0x28(%ebp)
80100d4d:	e8 28 13 00 00       	call   8010207a <readi>
80100d52:	83 c4 10             	add    $0x10,%esp
80100d55:	83 f8 20             	cmp    $0x20,%eax
80100d58:	0f 85 5c 03 00 00    	jne    801010ba <exec+0x48a>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100d5e:	8b 85 d8 fe ff ff    	mov    -0x128(%ebp),%eax
80100d64:	83 f8 01             	cmp    $0x1,%eax
80100d67:	0f 85 a0 00 00 00    	jne    80100e0d <exec+0x1dd>
      continue;
    if(ph.memsz < ph.filesz)
80100d6d:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100d73:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100d79:	39 c2                	cmp    %eax,%edx
80100d7b:	0f 82 3c 03 00 00    	jb     801010bd <exec+0x48d>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100d81:	8b 95 e0 fe ff ff    	mov    -0x120(%ebp),%edx
80100d87:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100d8d:	01 c2                	add    %eax,%edx
80100d8f:	8b 85 e0 fe ff ff    	mov    -0x120(%ebp),%eax
80100d95:	39 c2                	cmp    %eax,%edx
80100d97:	0f 82 23 03 00 00    	jb     801010c0 <exec+0x490>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100d9d:	8b 95 e0 fe ff ff    	mov    -0x120(%ebp),%edx
80100da3:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100da9:	01 d0                	add    %edx,%eax
80100dab:	83 ec 04             	sub    $0x4,%esp
80100dae:	50                   	push   %eax
80100daf:	ff 75 e0             	pushl  -0x20(%ebp)
80100db2:	ff 75 d4             	pushl  -0x2c(%ebp)
80100db5:	e8 89 76 00 00       	call   80108443 <allocuvm>
80100dba:	83 c4 10             	add    $0x10,%esp
80100dbd:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100dc0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100dc4:	0f 84 f9 02 00 00    	je     801010c3 <exec+0x493>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100dca:	8b 85 e0 fe ff ff    	mov    -0x120(%ebp),%eax
80100dd0:	25 ff 0f 00 00       	and    $0xfff,%eax
80100dd5:	85 c0                	test   %eax,%eax
80100dd7:	0f 85 e9 02 00 00    	jne    801010c6 <exec+0x496>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100ddd:	8b 95 e8 fe ff ff    	mov    -0x118(%ebp),%edx
80100de3:	8b 85 dc fe ff ff    	mov    -0x124(%ebp),%eax
80100de9:	8b 8d e0 fe ff ff    	mov    -0x120(%ebp),%ecx
80100def:	83 ec 0c             	sub    $0xc,%esp
80100df2:	52                   	push   %edx
80100df3:	50                   	push   %eax
80100df4:	ff 75 d8             	pushl  -0x28(%ebp)
80100df7:	51                   	push   %ecx
80100df8:	ff 75 d4             	pushl  -0x2c(%ebp)
80100dfb:	e8 72 75 00 00       	call   80108372 <loaduvm>
80100e00:	83 c4 20             	add    $0x20,%esp
80100e03:	85 c0                	test   %eax,%eax
80100e05:	0f 88 be 02 00 00    	js     801010c9 <exec+0x499>
80100e0b:	eb 01                	jmp    80100e0e <exec+0x1de>
      continue;
80100e0d:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100e0e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100e12:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100e15:	83 c0 20             	add    $0x20,%eax
80100e18:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100e1b:	0f b7 85 24 ff ff ff 	movzwl -0xdc(%ebp),%eax
80100e22:	0f b7 c0             	movzwl %ax,%eax
80100e25:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100e28:	0f 8c 0f ff ff ff    	jl     80100d3d <exec+0x10d>
      goto bad;
  }
  iunlockput(ip);
80100e2e:	83 ec 0c             	sub    $0xc,%esp
80100e31:	ff 75 d8             	pushl  -0x28(%ebp)
80100e34:	e8 76 0f 00 00       	call   80101daf <iunlockput>
80100e39:	83 c4 10             	add    $0x10,%esp
  end_op();
80100e3c:	e8 90 29 00 00       	call   801037d1 <end_op>
  ip = 0;
80100e41:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100e48:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e4b:	05 ff 0f 00 00       	add    $0xfff,%eax
80100e50:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100e55:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100e58:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e5b:	05 00 20 00 00       	add    $0x2000,%eax
80100e60:	83 ec 04             	sub    $0x4,%esp
80100e63:	50                   	push   %eax
80100e64:	ff 75 e0             	pushl  -0x20(%ebp)
80100e67:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e6a:	e8 d4 75 00 00       	call   80108443 <allocuvm>
80100e6f:	83 c4 10             	add    $0x10,%esp
80100e72:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100e75:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100e79:	0f 84 4d 02 00 00    	je     801010cc <exec+0x49c>
    goto bad;
  
  //cprintf("worked\n");


  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100e7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e82:	2d 00 20 00 00       	sub    $0x2000,%eax
80100e87:	83 ec 08             	sub    $0x8,%esp
80100e8a:	50                   	push   %eax
80100e8b:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e8e:	e8 22 78 00 00       	call   801086b5 <clearpteu>
80100e93:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100e96:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e99:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e9c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100ea3:	e9 96 00 00 00       	jmp    80100f3e <exec+0x30e>
    if(argc >= MAXARG)
80100ea8:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100eac:	0f 87 1d 02 00 00    	ja     801010cf <exec+0x49f>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100eb2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eb5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ebc:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ebf:	01 d0                	add    %edx,%eax
80100ec1:	8b 00                	mov    (%eax),%eax
80100ec3:	83 ec 0c             	sub    $0xc,%esp
80100ec6:	50                   	push   %eax
80100ec7:	e8 dc 48 00 00       	call   801057a8 <strlen>
80100ecc:	83 c4 10             	add    $0x10,%esp
80100ecf:	89 c2                	mov    %eax,%edx
80100ed1:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ed4:	29 d0                	sub    %edx,%eax
80100ed6:	83 e8 01             	sub    $0x1,%eax
80100ed9:	83 e0 fc             	and    $0xfffffffc,%eax
80100edc:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100edf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ee2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ee9:	8b 45 0c             	mov    0xc(%ebp),%eax
80100eec:	01 d0                	add    %edx,%eax
80100eee:	8b 00                	mov    (%eax),%eax
80100ef0:	83 ec 0c             	sub    $0xc,%esp
80100ef3:	50                   	push   %eax
80100ef4:	e8 af 48 00 00       	call   801057a8 <strlen>
80100ef9:	83 c4 10             	add    $0x10,%esp
80100efc:	83 c0 01             	add    $0x1,%eax
80100eff:	89 c1                	mov    %eax,%ecx
80100f01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f04:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f0b:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f0e:	01 d0                	add    %edx,%eax
80100f10:	8b 00                	mov    (%eax),%eax
80100f12:	51                   	push   %ecx
80100f13:	50                   	push   %eax
80100f14:	ff 75 dc             	pushl  -0x24(%ebp)
80100f17:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f1a:	e8 52 79 00 00       	call   80108871 <copyout>
80100f1f:	83 c4 10             	add    $0x10,%esp
80100f22:	85 c0                	test   %eax,%eax
80100f24:	0f 88 a8 01 00 00    	js     801010d2 <exec+0x4a2>
      goto bad;
    ustack[3+argc] = sp;
80100f2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f2d:	8d 50 03             	lea    0x3(%eax),%edx
80100f30:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f33:	89 84 95 2c ff ff ff 	mov    %eax,-0xd4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100f3a:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100f3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f41:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f48:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f4b:	01 d0                	add    %edx,%eax
80100f4d:	8b 00                	mov    (%eax),%eax
80100f4f:	85 c0                	test   %eax,%eax
80100f51:	0f 85 51 ff ff ff    	jne    80100ea8 <exec+0x278>
  }
  ustack[3+argc] = 0;
80100f57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f5a:	83 c0 03             	add    $0x3,%eax
80100f5d:	c7 84 85 2c ff ff ff 	movl   $0x0,-0xd4(%ebp,%eax,4)
80100f64:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100f68:	c7 85 2c ff ff ff ff 	movl   $0xffffffff,-0xd4(%ebp)
80100f6f:	ff ff ff 
  ustack[1] = argc;
80100f72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f75:	89 85 30 ff ff ff    	mov    %eax,-0xd0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100f7b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f7e:	83 c0 01             	add    $0x1,%eax
80100f81:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f88:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f8b:	29 d0                	sub    %edx,%eax
80100f8d:	89 85 34 ff ff ff    	mov    %eax,-0xcc(%ebp)

  sp -= (3+argc+1) * 4;
80100f93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f96:	83 c0 04             	add    $0x4,%eax
80100f99:	c1 e0 02             	shl    $0x2,%eax
80100f9c:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100f9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100fa2:	83 c0 04             	add    $0x4,%eax
80100fa5:	c1 e0 02             	shl    $0x2,%eax
80100fa8:	50                   	push   %eax
80100fa9:	8d 85 2c ff ff ff    	lea    -0xd4(%ebp),%eax
80100faf:	50                   	push   %eax
80100fb0:	ff 75 dc             	pushl  -0x24(%ebp)
80100fb3:	ff 75 d4             	pushl  -0x2c(%ebp)
80100fb6:	e8 b6 78 00 00       	call   80108871 <copyout>
80100fbb:	83 c4 10             	add    $0x10,%esp
80100fbe:	85 c0                	test   %eax,%eax
80100fc0:	0f 88 0f 01 00 00    	js     801010d5 <exec+0x4a5>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100fc6:	8b 45 08             	mov    0x8(%ebp),%eax
80100fc9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100fcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fcf:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100fd2:	eb 17                	jmp    80100feb <exec+0x3bb>
    if(*s == '/')
80100fd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fd7:	0f b6 00             	movzbl (%eax),%eax
80100fda:	3c 2f                	cmp    $0x2f,%al
80100fdc:	75 09                	jne    80100fe7 <exec+0x3b7>
      last = s+1;
80100fde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fe1:	83 c0 01             	add    $0x1,%eax
80100fe4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100fe7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100feb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fee:	0f b6 00             	movzbl (%eax),%eax
80100ff1:	84 c0                	test   %al,%al
80100ff3:	75 df                	jne    80100fd4 <exec+0x3a4>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100ff5:	8b 45 c8             	mov    -0x38(%ebp),%eax
80100ff8:	83 c0 6c             	add    $0x6c,%eax
80100ffb:	83 ec 04             	sub    $0x4,%esp
80100ffe:	6a 10                	push   $0x10
80101000:	ff 75 f0             	pushl  -0x10(%ebp)
80101003:	50                   	push   %eax
80101004:	e8 51 47 00 00       	call   8010575a <safestrcpy>
80101009:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
8010100c:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010100f:	8b 40 04             	mov    0x4(%eax),%eax
80101012:	89 45 bc             	mov    %eax,-0x44(%ebp)
  curproc->pgdir = pgdir;
80101015:	8b 45 c8             	mov    -0x38(%ebp),%eax
80101018:	8b 55 d4             	mov    -0x2c(%ebp),%edx
8010101b:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
8010101e:	8b 45 c8             	mov    -0x38(%ebp),%eax
80101021:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101024:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80101026:	8b 45 c8             	mov    -0x38(%ebp),%eax
80101029:	8b 40 18             	mov    0x18(%eax),%eax
8010102c:	8b 95 10 ff ff ff    	mov    -0xf0(%ebp),%edx
80101032:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80101035:	8b 45 c8             	mov    -0x38(%ebp),%eax
80101038:	8b 40 18             	mov    0x18(%eax),%eax
8010103b:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010103e:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80101041:	83 ec 0c             	sub    $0xc,%esp
80101044:	ff 75 c8             	pushl  -0x38(%ebp)
80101047:	e8 0f 71 00 00       	call   8010815b <switchuvm>
8010104c:	83 c4 10             	add    $0x10,%esp
  // if(mencrypt(0,sz/(int)PGSIZE)!=0){
  //   // cprintf("encryption error\n");
  //   cprintf("PPPPPAAAAAAAANNNNNNNNNIIIIIIIICCCCCCC\n");
  // }
  uint a;
  a = 0;
8010104f:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  for(; a < sz ; a += PGSIZE){
80101056:	eb 3c                	jmp    80101094 <exec+0x464>
      cprintf("encrypt in exec\n");
80101058:	83 ec 0c             	sub    $0xc,%esp
8010105b:	68 cd 92 10 80       	push   $0x801092cd
80101060:	e8 b3 f3 ff ff       	call   80100418 <cprintf>
80101065:	83 c4 10             	add    $0x10,%esp
      if(mencrypt((char *)a,1)!=0){
80101068:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010106b:	83 ec 08             	sub    $0x8,%esp
8010106e:	6a 01                	push   $0x1
80101070:	50                   	push   %eax
80101071:	e8 11 7b 00 00       	call   80108b87 <mencrypt>
80101076:	83 c4 10             	add    $0x10,%esp
80101079:	85 c0                	test   %eax,%eax
8010107b:	74 10                	je     8010108d <exec+0x45d>
       cprintf("encryption error\n");
8010107d:	83 ec 0c             	sub    $0xc,%esp
80101080:	68 de 92 10 80       	push   $0x801092de
80101085:	e8 8e f3 ff ff       	call   80100418 <cprintf>
8010108a:	83 c4 10             	add    $0x10,%esp
  for(; a < sz ; a += PGSIZE){
8010108d:	81 45 cc 00 10 00 00 	addl   $0x1000,-0x34(%ebp)
80101094:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101097:	3b 45 e0             	cmp    -0x20(%ebp),%eax
8010109a:	72 bc                	jb     80101058 <exec+0x428>
      }
    }


  freevm(oldpgdir);
8010109c:	83 ec 0c             	sub    $0xc,%esp
8010109f:	ff 75 bc             	pushl  -0x44(%ebp)
801010a2:	e8 6f 75 00 00       	call   80108616 <freevm>
801010a7:	83 c4 10             	add    $0x10,%esp
  return 0;
801010aa:	b8 00 00 00 00       	mov    $0x0,%eax
801010af:	eb 57                	jmp    80101108 <exec+0x4d8>
    goto bad;
801010b1:	90                   	nop
801010b2:	eb 22                	jmp    801010d6 <exec+0x4a6>
    goto bad;
801010b4:	90                   	nop
801010b5:	eb 1f                	jmp    801010d6 <exec+0x4a6>
    goto bad;
801010b7:	90                   	nop
801010b8:	eb 1c                	jmp    801010d6 <exec+0x4a6>
      goto bad;
801010ba:	90                   	nop
801010bb:	eb 19                	jmp    801010d6 <exec+0x4a6>
      goto bad;
801010bd:	90                   	nop
801010be:	eb 16                	jmp    801010d6 <exec+0x4a6>
      goto bad;
801010c0:	90                   	nop
801010c1:	eb 13                	jmp    801010d6 <exec+0x4a6>
      goto bad;
801010c3:	90                   	nop
801010c4:	eb 10                	jmp    801010d6 <exec+0x4a6>
      goto bad;
801010c6:	90                   	nop
801010c7:	eb 0d                	jmp    801010d6 <exec+0x4a6>
      goto bad;
801010c9:	90                   	nop
801010ca:	eb 0a                	jmp    801010d6 <exec+0x4a6>
    goto bad;
801010cc:	90                   	nop
801010cd:	eb 07                	jmp    801010d6 <exec+0x4a6>
      goto bad;
801010cf:	90                   	nop
801010d0:	eb 04                	jmp    801010d6 <exec+0x4a6>
      goto bad;
801010d2:	90                   	nop
801010d3:	eb 01                	jmp    801010d6 <exec+0x4a6>
    goto bad;
801010d5:	90                   	nop

 bad:
  if(pgdir)
801010d6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
801010da:	74 0e                	je     801010ea <exec+0x4ba>
    freevm(pgdir);
801010dc:	83 ec 0c             	sub    $0xc,%esp
801010df:	ff 75 d4             	pushl  -0x2c(%ebp)
801010e2:	e8 2f 75 00 00       	call   80108616 <freevm>
801010e7:	83 c4 10             	add    $0x10,%esp
  if(ip){
801010ea:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
801010ee:	74 13                	je     80101103 <exec+0x4d3>
    iunlockput(ip);
801010f0:	83 ec 0c             	sub    $0xc,%esp
801010f3:	ff 75 d8             	pushl  -0x28(%ebp)
801010f6:	e8 b4 0c 00 00       	call   80101daf <iunlockput>
801010fb:	83 c4 10             	add    $0x10,%esp
    end_op();
801010fe:	e8 ce 26 00 00       	call   801037d1 <end_op>
  }
  return -1;
80101103:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101108:	c9                   	leave  
80101109:	c3                   	ret    

8010110a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
8010110a:	f3 0f 1e fb          	endbr32 
8010110e:	55                   	push   %ebp
8010110f:	89 e5                	mov    %esp,%ebp
80101111:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80101114:	83 ec 08             	sub    $0x8,%esp
80101117:	68 f0 92 10 80       	push   $0x801092f0
8010111c:	68 60 20 11 80       	push   $0x80112060
80101121:	e8 54 41 00 00       	call   8010527a <initlock>
80101126:	83 c4 10             	add    $0x10,%esp
}
80101129:	90                   	nop
8010112a:	c9                   	leave  
8010112b:	c3                   	ret    

8010112c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
8010112c:	f3 0f 1e fb          	endbr32 
80101130:	55                   	push   %ebp
80101131:	89 e5                	mov    %esp,%ebp
80101133:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80101136:	83 ec 0c             	sub    $0xc,%esp
80101139:	68 60 20 11 80       	push   $0x80112060
8010113e:	e8 5d 41 00 00       	call   801052a0 <acquire>
80101143:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101146:	c7 45 f4 94 20 11 80 	movl   $0x80112094,-0xc(%ebp)
8010114d:	eb 2d                	jmp    8010117c <filealloc+0x50>
    if(f->ref == 0){
8010114f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101152:	8b 40 04             	mov    0x4(%eax),%eax
80101155:	85 c0                	test   %eax,%eax
80101157:	75 1f                	jne    80101178 <filealloc+0x4c>
      f->ref = 1;
80101159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010115c:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101163:	83 ec 0c             	sub    $0xc,%esp
80101166:	68 60 20 11 80       	push   $0x80112060
8010116b:	e8 a2 41 00 00       	call   80105312 <release>
80101170:	83 c4 10             	add    $0x10,%esp
      return f;
80101173:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101176:	eb 23                	jmp    8010119b <filealloc+0x6f>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101178:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
8010117c:	b8 f4 29 11 80       	mov    $0x801129f4,%eax
80101181:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101184:	72 c9                	jb     8010114f <filealloc+0x23>
    }
  }
  release(&ftable.lock);
80101186:	83 ec 0c             	sub    $0xc,%esp
80101189:	68 60 20 11 80       	push   $0x80112060
8010118e:	e8 7f 41 00 00       	call   80105312 <release>
80101193:	83 c4 10             	add    $0x10,%esp
  return 0;
80101196:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010119b:	c9                   	leave  
8010119c:	c3                   	ret    

8010119d <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010119d:	f3 0f 1e fb          	endbr32 
801011a1:	55                   	push   %ebp
801011a2:	89 e5                	mov    %esp,%ebp
801011a4:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
801011a7:	83 ec 0c             	sub    $0xc,%esp
801011aa:	68 60 20 11 80       	push   $0x80112060
801011af:	e8 ec 40 00 00       	call   801052a0 <acquire>
801011b4:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801011b7:	8b 45 08             	mov    0x8(%ebp),%eax
801011ba:	8b 40 04             	mov    0x4(%eax),%eax
801011bd:	85 c0                	test   %eax,%eax
801011bf:	7f 0d                	jg     801011ce <filedup+0x31>
    panic("filedup");
801011c1:	83 ec 0c             	sub    $0xc,%esp
801011c4:	68 f7 92 10 80       	push   $0x801092f7
801011c9:	e8 3a f4 ff ff       	call   80100608 <panic>
  f->ref++;
801011ce:	8b 45 08             	mov    0x8(%ebp),%eax
801011d1:	8b 40 04             	mov    0x4(%eax),%eax
801011d4:	8d 50 01             	lea    0x1(%eax),%edx
801011d7:	8b 45 08             	mov    0x8(%ebp),%eax
801011da:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801011dd:	83 ec 0c             	sub    $0xc,%esp
801011e0:	68 60 20 11 80       	push   $0x80112060
801011e5:	e8 28 41 00 00       	call   80105312 <release>
801011ea:	83 c4 10             	add    $0x10,%esp
  return f;
801011ed:	8b 45 08             	mov    0x8(%ebp),%eax
}
801011f0:	c9                   	leave  
801011f1:	c3                   	ret    

801011f2 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801011f2:	f3 0f 1e fb          	endbr32 
801011f6:	55                   	push   %ebp
801011f7:	89 e5                	mov    %esp,%ebp
801011f9:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801011fc:	83 ec 0c             	sub    $0xc,%esp
801011ff:	68 60 20 11 80       	push   $0x80112060
80101204:	e8 97 40 00 00       	call   801052a0 <acquire>
80101209:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010120c:	8b 45 08             	mov    0x8(%ebp),%eax
8010120f:	8b 40 04             	mov    0x4(%eax),%eax
80101212:	85 c0                	test   %eax,%eax
80101214:	7f 0d                	jg     80101223 <fileclose+0x31>
    panic("fileclose");
80101216:	83 ec 0c             	sub    $0xc,%esp
80101219:	68 ff 92 10 80       	push   $0x801092ff
8010121e:	e8 e5 f3 ff ff       	call   80100608 <panic>
  if(--f->ref > 0){
80101223:	8b 45 08             	mov    0x8(%ebp),%eax
80101226:	8b 40 04             	mov    0x4(%eax),%eax
80101229:	8d 50 ff             	lea    -0x1(%eax),%edx
8010122c:	8b 45 08             	mov    0x8(%ebp),%eax
8010122f:	89 50 04             	mov    %edx,0x4(%eax)
80101232:	8b 45 08             	mov    0x8(%ebp),%eax
80101235:	8b 40 04             	mov    0x4(%eax),%eax
80101238:	85 c0                	test   %eax,%eax
8010123a:	7e 15                	jle    80101251 <fileclose+0x5f>
    release(&ftable.lock);
8010123c:	83 ec 0c             	sub    $0xc,%esp
8010123f:	68 60 20 11 80       	push   $0x80112060
80101244:	e8 c9 40 00 00       	call   80105312 <release>
80101249:	83 c4 10             	add    $0x10,%esp
8010124c:	e9 8b 00 00 00       	jmp    801012dc <fileclose+0xea>
    return;
  }
  ff = *f;
80101251:	8b 45 08             	mov    0x8(%ebp),%eax
80101254:	8b 10                	mov    (%eax),%edx
80101256:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101259:	8b 50 04             	mov    0x4(%eax),%edx
8010125c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010125f:	8b 50 08             	mov    0x8(%eax),%edx
80101262:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101265:	8b 50 0c             	mov    0xc(%eax),%edx
80101268:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010126b:	8b 50 10             	mov    0x10(%eax),%edx
8010126e:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101271:	8b 40 14             	mov    0x14(%eax),%eax
80101274:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101277:	8b 45 08             	mov    0x8(%ebp),%eax
8010127a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101281:	8b 45 08             	mov    0x8(%ebp),%eax
80101284:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010128a:	83 ec 0c             	sub    $0xc,%esp
8010128d:	68 60 20 11 80       	push   $0x80112060
80101292:	e8 7b 40 00 00       	call   80105312 <release>
80101297:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
8010129a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010129d:	83 f8 01             	cmp    $0x1,%eax
801012a0:	75 19                	jne    801012bb <fileclose+0xc9>
    pipeclose(ff.pipe, ff.writable);
801012a2:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801012a6:	0f be d0             	movsbl %al,%edx
801012a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801012ac:	83 ec 08             	sub    $0x8,%esp
801012af:	52                   	push   %edx
801012b0:	50                   	push   %eax
801012b1:	e8 c1 2e 00 00       	call   80104177 <pipeclose>
801012b6:	83 c4 10             	add    $0x10,%esp
801012b9:	eb 21                	jmp    801012dc <fileclose+0xea>
  else if(ff.type == FD_INODE){
801012bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801012be:	83 f8 02             	cmp    $0x2,%eax
801012c1:	75 19                	jne    801012dc <fileclose+0xea>
    begin_op();
801012c3:	e8 79 24 00 00       	call   80103741 <begin_op>
    iput(ff.ip);
801012c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801012cb:	83 ec 0c             	sub    $0xc,%esp
801012ce:	50                   	push   %eax
801012cf:	e8 07 0a 00 00       	call   80101cdb <iput>
801012d4:	83 c4 10             	add    $0x10,%esp
    end_op();
801012d7:	e8 f5 24 00 00       	call   801037d1 <end_op>
  }
}
801012dc:	c9                   	leave  
801012dd:	c3                   	ret    

801012de <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801012de:	f3 0f 1e fb          	endbr32 
801012e2:	55                   	push   %ebp
801012e3:	89 e5                	mov    %esp,%ebp
801012e5:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
801012e8:	8b 45 08             	mov    0x8(%ebp),%eax
801012eb:	8b 00                	mov    (%eax),%eax
801012ed:	83 f8 02             	cmp    $0x2,%eax
801012f0:	75 40                	jne    80101332 <filestat+0x54>
    ilock(f->ip);
801012f2:	8b 45 08             	mov    0x8(%ebp),%eax
801012f5:	8b 40 10             	mov    0x10(%eax),%eax
801012f8:	83 ec 0c             	sub    $0xc,%esp
801012fb:	50                   	push   %eax
801012fc:	e8 71 08 00 00       	call   80101b72 <ilock>
80101301:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
80101304:	8b 45 08             	mov    0x8(%ebp),%eax
80101307:	8b 40 10             	mov    0x10(%eax),%eax
8010130a:	83 ec 08             	sub    $0x8,%esp
8010130d:	ff 75 0c             	pushl  0xc(%ebp)
80101310:	50                   	push   %eax
80101311:	e8 1a 0d 00 00       	call   80102030 <stati>
80101316:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101319:	8b 45 08             	mov    0x8(%ebp),%eax
8010131c:	8b 40 10             	mov    0x10(%eax),%eax
8010131f:	83 ec 0c             	sub    $0xc,%esp
80101322:	50                   	push   %eax
80101323:	e8 61 09 00 00       	call   80101c89 <iunlock>
80101328:	83 c4 10             	add    $0x10,%esp
    return 0;
8010132b:	b8 00 00 00 00       	mov    $0x0,%eax
80101330:	eb 05                	jmp    80101337 <filestat+0x59>
  }
  return -1;
80101332:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101337:	c9                   	leave  
80101338:	c3                   	ret    

80101339 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101339:	f3 0f 1e fb          	endbr32 
8010133d:	55                   	push   %ebp
8010133e:	89 e5                	mov    %esp,%ebp
80101340:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101343:	8b 45 08             	mov    0x8(%ebp),%eax
80101346:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010134a:	84 c0                	test   %al,%al
8010134c:	75 0a                	jne    80101358 <fileread+0x1f>
    return -1;
8010134e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101353:	e9 9b 00 00 00       	jmp    801013f3 <fileread+0xba>
  if(f->type == FD_PIPE)
80101358:	8b 45 08             	mov    0x8(%ebp),%eax
8010135b:	8b 00                	mov    (%eax),%eax
8010135d:	83 f8 01             	cmp    $0x1,%eax
80101360:	75 1a                	jne    8010137c <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101362:	8b 45 08             	mov    0x8(%ebp),%eax
80101365:	8b 40 0c             	mov    0xc(%eax),%eax
80101368:	83 ec 04             	sub    $0x4,%esp
8010136b:	ff 75 10             	pushl  0x10(%ebp)
8010136e:	ff 75 0c             	pushl  0xc(%ebp)
80101371:	50                   	push   %eax
80101372:	e8 b5 2f 00 00       	call   8010432c <piperead>
80101377:	83 c4 10             	add    $0x10,%esp
8010137a:	eb 77                	jmp    801013f3 <fileread+0xba>
  if(f->type == FD_INODE){
8010137c:	8b 45 08             	mov    0x8(%ebp),%eax
8010137f:	8b 00                	mov    (%eax),%eax
80101381:	83 f8 02             	cmp    $0x2,%eax
80101384:	75 60                	jne    801013e6 <fileread+0xad>
    ilock(f->ip);
80101386:	8b 45 08             	mov    0x8(%ebp),%eax
80101389:	8b 40 10             	mov    0x10(%eax),%eax
8010138c:	83 ec 0c             	sub    $0xc,%esp
8010138f:	50                   	push   %eax
80101390:	e8 dd 07 00 00       	call   80101b72 <ilock>
80101395:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101398:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010139b:	8b 45 08             	mov    0x8(%ebp),%eax
8010139e:	8b 50 14             	mov    0x14(%eax),%edx
801013a1:	8b 45 08             	mov    0x8(%ebp),%eax
801013a4:	8b 40 10             	mov    0x10(%eax),%eax
801013a7:	51                   	push   %ecx
801013a8:	52                   	push   %edx
801013a9:	ff 75 0c             	pushl  0xc(%ebp)
801013ac:	50                   	push   %eax
801013ad:	e8 c8 0c 00 00       	call   8010207a <readi>
801013b2:	83 c4 10             	add    $0x10,%esp
801013b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801013b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801013bc:	7e 11                	jle    801013cf <fileread+0x96>
      f->off += r;
801013be:	8b 45 08             	mov    0x8(%ebp),%eax
801013c1:	8b 50 14             	mov    0x14(%eax),%edx
801013c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013c7:	01 c2                	add    %eax,%edx
801013c9:	8b 45 08             	mov    0x8(%ebp),%eax
801013cc:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801013cf:	8b 45 08             	mov    0x8(%ebp),%eax
801013d2:	8b 40 10             	mov    0x10(%eax),%eax
801013d5:	83 ec 0c             	sub    $0xc,%esp
801013d8:	50                   	push   %eax
801013d9:	e8 ab 08 00 00       	call   80101c89 <iunlock>
801013de:	83 c4 10             	add    $0x10,%esp
    return r;
801013e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013e4:	eb 0d                	jmp    801013f3 <fileread+0xba>
  }
  panic("fileread");
801013e6:	83 ec 0c             	sub    $0xc,%esp
801013e9:	68 09 93 10 80       	push   $0x80109309
801013ee:	e8 15 f2 ff ff       	call   80100608 <panic>
}
801013f3:	c9                   	leave  
801013f4:	c3                   	ret    

801013f5 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801013f5:	f3 0f 1e fb          	endbr32 
801013f9:	55                   	push   %ebp
801013fa:	89 e5                	mov    %esp,%ebp
801013fc:	53                   	push   %ebx
801013fd:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101400:	8b 45 08             	mov    0x8(%ebp),%eax
80101403:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101407:	84 c0                	test   %al,%al
80101409:	75 0a                	jne    80101415 <filewrite+0x20>
    return -1;
8010140b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101410:	e9 1b 01 00 00       	jmp    80101530 <filewrite+0x13b>
  if(f->type == FD_PIPE)
80101415:	8b 45 08             	mov    0x8(%ebp),%eax
80101418:	8b 00                	mov    (%eax),%eax
8010141a:	83 f8 01             	cmp    $0x1,%eax
8010141d:	75 1d                	jne    8010143c <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
8010141f:	8b 45 08             	mov    0x8(%ebp),%eax
80101422:	8b 40 0c             	mov    0xc(%eax),%eax
80101425:	83 ec 04             	sub    $0x4,%esp
80101428:	ff 75 10             	pushl  0x10(%ebp)
8010142b:	ff 75 0c             	pushl  0xc(%ebp)
8010142e:	50                   	push   %eax
8010142f:	e8 f2 2d 00 00       	call   80104226 <pipewrite>
80101434:	83 c4 10             	add    $0x10,%esp
80101437:	e9 f4 00 00 00       	jmp    80101530 <filewrite+0x13b>
  if(f->type == FD_INODE){
8010143c:	8b 45 08             	mov    0x8(%ebp),%eax
8010143f:	8b 00                	mov    (%eax),%eax
80101441:	83 f8 02             	cmp    $0x2,%eax
80101444:	0f 85 d9 00 00 00    	jne    80101523 <filewrite+0x12e>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
8010144a:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
80101451:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101458:	e9 a3 00 00 00       	jmp    80101500 <filewrite+0x10b>
      int n1 = n - i;
8010145d:	8b 45 10             	mov    0x10(%ebp),%eax
80101460:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101463:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101466:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101469:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010146c:	7e 06                	jle    80101474 <filewrite+0x7f>
        n1 = max;
8010146e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101471:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101474:	e8 c8 22 00 00       	call   80103741 <begin_op>
      ilock(f->ip);
80101479:	8b 45 08             	mov    0x8(%ebp),%eax
8010147c:	8b 40 10             	mov    0x10(%eax),%eax
8010147f:	83 ec 0c             	sub    $0xc,%esp
80101482:	50                   	push   %eax
80101483:	e8 ea 06 00 00       	call   80101b72 <ilock>
80101488:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010148b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010148e:	8b 45 08             	mov    0x8(%ebp),%eax
80101491:	8b 50 14             	mov    0x14(%eax),%edx
80101494:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101497:	8b 45 0c             	mov    0xc(%ebp),%eax
8010149a:	01 c3                	add    %eax,%ebx
8010149c:	8b 45 08             	mov    0x8(%ebp),%eax
8010149f:	8b 40 10             	mov    0x10(%eax),%eax
801014a2:	51                   	push   %ecx
801014a3:	52                   	push   %edx
801014a4:	53                   	push   %ebx
801014a5:	50                   	push   %eax
801014a6:	e8 28 0d 00 00       	call   801021d3 <writei>
801014ab:	83 c4 10             	add    $0x10,%esp
801014ae:	89 45 e8             	mov    %eax,-0x18(%ebp)
801014b1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801014b5:	7e 11                	jle    801014c8 <filewrite+0xd3>
        f->off += r;
801014b7:	8b 45 08             	mov    0x8(%ebp),%eax
801014ba:	8b 50 14             	mov    0x14(%eax),%edx
801014bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801014c0:	01 c2                	add    %eax,%edx
801014c2:	8b 45 08             	mov    0x8(%ebp),%eax
801014c5:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801014c8:	8b 45 08             	mov    0x8(%ebp),%eax
801014cb:	8b 40 10             	mov    0x10(%eax),%eax
801014ce:	83 ec 0c             	sub    $0xc,%esp
801014d1:	50                   	push   %eax
801014d2:	e8 b2 07 00 00       	call   80101c89 <iunlock>
801014d7:	83 c4 10             	add    $0x10,%esp
      end_op();
801014da:	e8 f2 22 00 00       	call   801037d1 <end_op>

      if(r < 0)
801014df:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801014e3:	78 29                	js     8010150e <filewrite+0x119>
        break;
      if(r != n1)
801014e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801014e8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801014eb:	74 0d                	je     801014fa <filewrite+0x105>
        panic("short filewrite");
801014ed:	83 ec 0c             	sub    $0xc,%esp
801014f0:	68 12 93 10 80       	push   $0x80109312
801014f5:	e8 0e f1 ff ff       	call   80100608 <panic>
      i += r;
801014fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
801014fd:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
80101500:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101503:	3b 45 10             	cmp    0x10(%ebp),%eax
80101506:	0f 8c 51 ff ff ff    	jl     8010145d <filewrite+0x68>
8010150c:	eb 01                	jmp    8010150f <filewrite+0x11a>
        break;
8010150e:	90                   	nop
    }
    return i == n ? n : -1;
8010150f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101512:	3b 45 10             	cmp    0x10(%ebp),%eax
80101515:	75 05                	jne    8010151c <filewrite+0x127>
80101517:	8b 45 10             	mov    0x10(%ebp),%eax
8010151a:	eb 14                	jmp    80101530 <filewrite+0x13b>
8010151c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101521:	eb 0d                	jmp    80101530 <filewrite+0x13b>
  }
  panic("filewrite");
80101523:	83 ec 0c             	sub    $0xc,%esp
80101526:	68 22 93 10 80       	push   $0x80109322
8010152b:	e8 d8 f0 ff ff       	call   80100608 <panic>
}
80101530:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101533:	c9                   	leave  
80101534:	c3                   	ret    

80101535 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101535:	f3 0f 1e fb          	endbr32 
80101539:	55                   	push   %ebp
8010153a:	89 e5                	mov    %esp,%ebp
8010153c:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
8010153f:	8b 45 08             	mov    0x8(%ebp),%eax
80101542:	83 ec 08             	sub    $0x8,%esp
80101545:	6a 01                	push   $0x1
80101547:	50                   	push   %eax
80101548:	e8 8a ec ff ff       	call   801001d7 <bread>
8010154d:	83 c4 10             	add    $0x10,%esp
80101550:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101553:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101556:	83 c0 5c             	add    $0x5c,%eax
80101559:	83 ec 04             	sub    $0x4,%esp
8010155c:	6a 1c                	push   $0x1c
8010155e:	50                   	push   %eax
8010155f:	ff 75 0c             	pushl  0xc(%ebp)
80101562:	e8 9f 40 00 00       	call   80105606 <memmove>
80101567:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010156a:	83 ec 0c             	sub    $0xc,%esp
8010156d:	ff 75 f4             	pushl  -0xc(%ebp)
80101570:	e8 ec ec ff ff       	call   80100261 <brelse>
80101575:	83 c4 10             	add    $0x10,%esp
}
80101578:	90                   	nop
80101579:	c9                   	leave  
8010157a:	c3                   	ret    

8010157b <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010157b:	f3 0f 1e fb          	endbr32 
8010157f:	55                   	push   %ebp
80101580:	89 e5                	mov    %esp,%ebp
80101582:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101585:	8b 55 0c             	mov    0xc(%ebp),%edx
80101588:	8b 45 08             	mov    0x8(%ebp),%eax
8010158b:	83 ec 08             	sub    $0x8,%esp
8010158e:	52                   	push   %edx
8010158f:	50                   	push   %eax
80101590:	e8 42 ec ff ff       	call   801001d7 <bread>
80101595:	83 c4 10             	add    $0x10,%esp
80101598:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010159b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010159e:	83 c0 5c             	add    $0x5c,%eax
801015a1:	83 ec 04             	sub    $0x4,%esp
801015a4:	68 00 02 00 00       	push   $0x200
801015a9:	6a 00                	push   $0x0
801015ab:	50                   	push   %eax
801015ac:	e8 8e 3f 00 00       	call   8010553f <memset>
801015b1:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801015b4:	83 ec 0c             	sub    $0xc,%esp
801015b7:	ff 75 f4             	pushl  -0xc(%ebp)
801015ba:	e8 cb 23 00 00       	call   8010398a <log_write>
801015bf:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801015c2:	83 ec 0c             	sub    $0xc,%esp
801015c5:	ff 75 f4             	pushl  -0xc(%ebp)
801015c8:	e8 94 ec ff ff       	call   80100261 <brelse>
801015cd:	83 c4 10             	add    $0x10,%esp
}
801015d0:	90                   	nop
801015d1:	c9                   	leave  
801015d2:	c3                   	ret    

801015d3 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801015d3:	f3 0f 1e fb          	endbr32 
801015d7:	55                   	push   %ebp
801015d8:	89 e5                	mov    %esp,%ebp
801015da:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801015dd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801015e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801015eb:	e9 13 01 00 00       	jmp    80101703 <balloc+0x130>
    bp = bread(dev, BBLOCK(b, sb));
801015f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015f3:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801015f9:	85 c0                	test   %eax,%eax
801015fb:	0f 48 c2             	cmovs  %edx,%eax
801015fe:	c1 f8 0c             	sar    $0xc,%eax
80101601:	89 c2                	mov    %eax,%edx
80101603:	a1 78 2a 11 80       	mov    0x80112a78,%eax
80101608:	01 d0                	add    %edx,%eax
8010160a:	83 ec 08             	sub    $0x8,%esp
8010160d:	50                   	push   %eax
8010160e:	ff 75 08             	pushl  0x8(%ebp)
80101611:	e8 c1 eb ff ff       	call   801001d7 <bread>
80101616:	83 c4 10             	add    $0x10,%esp
80101619:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010161c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101623:	e9 a6 00 00 00       	jmp    801016ce <balloc+0xfb>
      m = 1 << (bi % 8);
80101628:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010162b:	99                   	cltd   
8010162c:	c1 ea 1d             	shr    $0x1d,%edx
8010162f:	01 d0                	add    %edx,%eax
80101631:	83 e0 07             	and    $0x7,%eax
80101634:	29 d0                	sub    %edx,%eax
80101636:	ba 01 00 00 00       	mov    $0x1,%edx
8010163b:	89 c1                	mov    %eax,%ecx
8010163d:	d3 e2                	shl    %cl,%edx
8010163f:	89 d0                	mov    %edx,%eax
80101641:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101644:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101647:	8d 50 07             	lea    0x7(%eax),%edx
8010164a:	85 c0                	test   %eax,%eax
8010164c:	0f 48 c2             	cmovs  %edx,%eax
8010164f:	c1 f8 03             	sar    $0x3,%eax
80101652:	89 c2                	mov    %eax,%edx
80101654:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101657:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
8010165c:	0f b6 c0             	movzbl %al,%eax
8010165f:	23 45 e8             	and    -0x18(%ebp),%eax
80101662:	85 c0                	test   %eax,%eax
80101664:	75 64                	jne    801016ca <balloc+0xf7>
        bp->data[bi/8] |= m;  // Mark block in use.
80101666:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101669:	8d 50 07             	lea    0x7(%eax),%edx
8010166c:	85 c0                	test   %eax,%eax
8010166e:	0f 48 c2             	cmovs  %edx,%eax
80101671:	c1 f8 03             	sar    $0x3,%eax
80101674:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101677:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
8010167c:	89 d1                	mov    %edx,%ecx
8010167e:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101681:	09 ca                	or     %ecx,%edx
80101683:	89 d1                	mov    %edx,%ecx
80101685:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101688:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
8010168c:	83 ec 0c             	sub    $0xc,%esp
8010168f:	ff 75 ec             	pushl  -0x14(%ebp)
80101692:	e8 f3 22 00 00       	call   8010398a <log_write>
80101697:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
8010169a:	83 ec 0c             	sub    $0xc,%esp
8010169d:	ff 75 ec             	pushl  -0x14(%ebp)
801016a0:	e8 bc eb ff ff       	call   80100261 <brelse>
801016a5:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
801016a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016ae:	01 c2                	add    %eax,%edx
801016b0:	8b 45 08             	mov    0x8(%ebp),%eax
801016b3:	83 ec 08             	sub    $0x8,%esp
801016b6:	52                   	push   %edx
801016b7:	50                   	push   %eax
801016b8:	e8 be fe ff ff       	call   8010157b <bzero>
801016bd:	83 c4 10             	add    $0x10,%esp
        return b + bi;
801016c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016c6:	01 d0                	add    %edx,%eax
801016c8:	eb 57                	jmp    80101721 <balloc+0x14e>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801016ca:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801016ce:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801016d5:	7f 17                	jg     801016ee <balloc+0x11b>
801016d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016dd:	01 d0                	add    %edx,%eax
801016df:	89 c2                	mov    %eax,%edx
801016e1:	a1 60 2a 11 80       	mov    0x80112a60,%eax
801016e6:	39 c2                	cmp    %eax,%edx
801016e8:	0f 82 3a ff ff ff    	jb     80101628 <balloc+0x55>
      }
    }
    brelse(bp);
801016ee:	83 ec 0c             	sub    $0xc,%esp
801016f1:	ff 75 ec             	pushl  -0x14(%ebp)
801016f4:	e8 68 eb ff ff       	call   80100261 <brelse>
801016f9:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
801016fc:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101703:	8b 15 60 2a 11 80    	mov    0x80112a60,%edx
80101709:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010170c:	39 c2                	cmp    %eax,%edx
8010170e:	0f 87 dc fe ff ff    	ja     801015f0 <balloc+0x1d>
  }
  panic("balloc: out of blocks");
80101714:	83 ec 0c             	sub    $0xc,%esp
80101717:	68 2c 93 10 80       	push   $0x8010932c
8010171c:	e8 e7 ee ff ff       	call   80100608 <panic>
}
80101721:	c9                   	leave  
80101722:	c3                   	ret    

80101723 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101723:	f3 0f 1e fb          	endbr32 
80101727:	55                   	push   %ebp
80101728:	89 e5                	mov    %esp,%ebp
8010172a:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
8010172d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101730:	c1 e8 0c             	shr    $0xc,%eax
80101733:	89 c2                	mov    %eax,%edx
80101735:	a1 78 2a 11 80       	mov    0x80112a78,%eax
8010173a:	01 c2                	add    %eax,%edx
8010173c:	8b 45 08             	mov    0x8(%ebp),%eax
8010173f:	83 ec 08             	sub    $0x8,%esp
80101742:	52                   	push   %edx
80101743:	50                   	push   %eax
80101744:	e8 8e ea ff ff       	call   801001d7 <bread>
80101749:	83 c4 10             	add    $0x10,%esp
8010174c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
8010174f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101752:	25 ff 0f 00 00       	and    $0xfff,%eax
80101757:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010175a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010175d:	99                   	cltd   
8010175e:	c1 ea 1d             	shr    $0x1d,%edx
80101761:	01 d0                	add    %edx,%eax
80101763:	83 e0 07             	and    $0x7,%eax
80101766:	29 d0                	sub    %edx,%eax
80101768:	ba 01 00 00 00       	mov    $0x1,%edx
8010176d:	89 c1                	mov    %eax,%ecx
8010176f:	d3 e2                	shl    %cl,%edx
80101771:	89 d0                	mov    %edx,%eax
80101773:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101776:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101779:	8d 50 07             	lea    0x7(%eax),%edx
8010177c:	85 c0                	test   %eax,%eax
8010177e:	0f 48 c2             	cmovs  %edx,%eax
80101781:	c1 f8 03             	sar    $0x3,%eax
80101784:	89 c2                	mov    %eax,%edx
80101786:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101789:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
8010178e:	0f b6 c0             	movzbl %al,%eax
80101791:	23 45 ec             	and    -0x14(%ebp),%eax
80101794:	85 c0                	test   %eax,%eax
80101796:	75 0d                	jne    801017a5 <bfree+0x82>
    panic("freeing free block");
80101798:	83 ec 0c             	sub    $0xc,%esp
8010179b:	68 42 93 10 80       	push   $0x80109342
801017a0:	e8 63 ee ff ff       	call   80100608 <panic>
  bp->data[bi/8] &= ~m;
801017a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017a8:	8d 50 07             	lea    0x7(%eax),%edx
801017ab:	85 c0                	test   %eax,%eax
801017ad:	0f 48 c2             	cmovs  %edx,%eax
801017b0:	c1 f8 03             	sar    $0x3,%eax
801017b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017b6:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801017bb:	89 d1                	mov    %edx,%ecx
801017bd:	8b 55 ec             	mov    -0x14(%ebp),%edx
801017c0:	f7 d2                	not    %edx
801017c2:	21 ca                	and    %ecx,%edx
801017c4:	89 d1                	mov    %edx,%ecx
801017c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017c9:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
801017cd:	83 ec 0c             	sub    $0xc,%esp
801017d0:	ff 75 f4             	pushl  -0xc(%ebp)
801017d3:	e8 b2 21 00 00       	call   8010398a <log_write>
801017d8:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801017db:	83 ec 0c             	sub    $0xc,%esp
801017de:	ff 75 f4             	pushl  -0xc(%ebp)
801017e1:	e8 7b ea ff ff       	call   80100261 <brelse>
801017e6:	83 c4 10             	add    $0x10,%esp
}
801017e9:	90                   	nop
801017ea:	c9                   	leave  
801017eb:	c3                   	ret    

801017ec <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801017ec:	f3 0f 1e fb          	endbr32 
801017f0:	55                   	push   %ebp
801017f1:	89 e5                	mov    %esp,%ebp
801017f3:	57                   	push   %edi
801017f4:	56                   	push   %esi
801017f5:	53                   	push   %ebx
801017f6:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
801017f9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101800:	83 ec 08             	sub    $0x8,%esp
80101803:	68 55 93 10 80       	push   $0x80109355
80101808:	68 80 2a 11 80       	push   $0x80112a80
8010180d:	e8 68 3a 00 00       	call   8010527a <initlock>
80101812:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
80101815:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010181c:	eb 2d                	jmp    8010184b <iinit+0x5f>
    initsleeplock(&icache.inode[i].lock, "inode");
8010181e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101821:	89 d0                	mov    %edx,%eax
80101823:	c1 e0 03             	shl    $0x3,%eax
80101826:	01 d0                	add    %edx,%eax
80101828:	c1 e0 04             	shl    $0x4,%eax
8010182b:	83 c0 30             	add    $0x30,%eax
8010182e:	05 80 2a 11 80       	add    $0x80112a80,%eax
80101833:	83 c0 10             	add    $0x10,%eax
80101836:	83 ec 08             	sub    $0x8,%esp
80101839:	68 5c 93 10 80       	push   $0x8010935c
8010183e:	50                   	push   %eax
8010183f:	e8 a3 38 00 00       	call   801050e7 <initsleeplock>
80101844:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
80101847:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010184b:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
8010184f:	7e cd                	jle    8010181e <iinit+0x32>
  }

  readsb(dev, &sb);
80101851:	83 ec 08             	sub    $0x8,%esp
80101854:	68 60 2a 11 80       	push   $0x80112a60
80101859:	ff 75 08             	pushl  0x8(%ebp)
8010185c:	e8 d4 fc ff ff       	call   80101535 <readsb>
80101861:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101864:	a1 78 2a 11 80       	mov    0x80112a78,%eax
80101869:	89 45 d4             	mov    %eax,-0x2c(%ebp)
8010186c:	8b 3d 74 2a 11 80    	mov    0x80112a74,%edi
80101872:	8b 35 70 2a 11 80    	mov    0x80112a70,%esi
80101878:	8b 1d 6c 2a 11 80    	mov    0x80112a6c,%ebx
8010187e:	8b 0d 68 2a 11 80    	mov    0x80112a68,%ecx
80101884:	8b 15 64 2a 11 80    	mov    0x80112a64,%edx
8010188a:	a1 60 2a 11 80       	mov    0x80112a60,%eax
8010188f:	ff 75 d4             	pushl  -0x2c(%ebp)
80101892:	57                   	push   %edi
80101893:	56                   	push   %esi
80101894:	53                   	push   %ebx
80101895:	51                   	push   %ecx
80101896:	52                   	push   %edx
80101897:	50                   	push   %eax
80101898:	68 64 93 10 80       	push   $0x80109364
8010189d:	e8 76 eb ff ff       	call   80100418 <cprintf>
801018a2:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
801018a5:	90                   	nop
801018a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801018a9:	5b                   	pop    %ebx
801018aa:	5e                   	pop    %esi
801018ab:	5f                   	pop    %edi
801018ac:	5d                   	pop    %ebp
801018ad:	c3                   	ret    

801018ae <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
801018ae:	f3 0f 1e fb          	endbr32 
801018b2:	55                   	push   %ebp
801018b3:	89 e5                	mov    %esp,%ebp
801018b5:	83 ec 28             	sub    $0x28,%esp
801018b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801018bb:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801018bf:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801018c6:	e9 9e 00 00 00       	jmp    80101969 <ialloc+0xbb>
    bp = bread(dev, IBLOCK(inum, sb));
801018cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ce:	c1 e8 03             	shr    $0x3,%eax
801018d1:	89 c2                	mov    %eax,%edx
801018d3:	a1 74 2a 11 80       	mov    0x80112a74,%eax
801018d8:	01 d0                	add    %edx,%eax
801018da:	83 ec 08             	sub    $0x8,%esp
801018dd:	50                   	push   %eax
801018de:	ff 75 08             	pushl  0x8(%ebp)
801018e1:	e8 f1 e8 ff ff       	call   801001d7 <bread>
801018e6:	83 c4 10             	add    $0x10,%esp
801018e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801018ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018ef:	8d 50 5c             	lea    0x5c(%eax),%edx
801018f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f5:	83 e0 07             	and    $0x7,%eax
801018f8:	c1 e0 06             	shl    $0x6,%eax
801018fb:	01 d0                	add    %edx,%eax
801018fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101900:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101903:	0f b7 00             	movzwl (%eax),%eax
80101906:	66 85 c0             	test   %ax,%ax
80101909:	75 4c                	jne    80101957 <ialloc+0xa9>
      memset(dip, 0, sizeof(*dip));
8010190b:	83 ec 04             	sub    $0x4,%esp
8010190e:	6a 40                	push   $0x40
80101910:	6a 00                	push   $0x0
80101912:	ff 75 ec             	pushl  -0x14(%ebp)
80101915:	e8 25 3c 00 00       	call   8010553f <memset>
8010191a:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
8010191d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101920:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
80101924:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101927:	83 ec 0c             	sub    $0xc,%esp
8010192a:	ff 75 f0             	pushl  -0x10(%ebp)
8010192d:	e8 58 20 00 00       	call   8010398a <log_write>
80101932:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
80101935:	83 ec 0c             	sub    $0xc,%esp
80101938:	ff 75 f0             	pushl  -0x10(%ebp)
8010193b:	e8 21 e9 ff ff       	call   80100261 <brelse>
80101940:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
80101943:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101946:	83 ec 08             	sub    $0x8,%esp
80101949:	50                   	push   %eax
8010194a:	ff 75 08             	pushl  0x8(%ebp)
8010194d:	e8 fc 00 00 00       	call   80101a4e <iget>
80101952:	83 c4 10             	add    $0x10,%esp
80101955:	eb 30                	jmp    80101987 <ialloc+0xd9>
    }
    brelse(bp);
80101957:	83 ec 0c             	sub    $0xc,%esp
8010195a:	ff 75 f0             	pushl  -0x10(%ebp)
8010195d:	e8 ff e8 ff ff       	call   80100261 <brelse>
80101962:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
80101965:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101969:	8b 15 68 2a 11 80    	mov    0x80112a68,%edx
8010196f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101972:	39 c2                	cmp    %eax,%edx
80101974:	0f 87 51 ff ff ff    	ja     801018cb <ialloc+0x1d>
  }
  panic("ialloc: no inodes");
8010197a:	83 ec 0c             	sub    $0xc,%esp
8010197d:	68 b7 93 10 80       	push   $0x801093b7
80101982:	e8 81 ec ff ff       	call   80100608 <panic>
}
80101987:	c9                   	leave  
80101988:	c3                   	ret    

80101989 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101989:	f3 0f 1e fb          	endbr32 
8010198d:	55                   	push   %ebp
8010198e:	89 e5                	mov    %esp,%ebp
80101990:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101993:	8b 45 08             	mov    0x8(%ebp),%eax
80101996:	8b 40 04             	mov    0x4(%eax),%eax
80101999:	c1 e8 03             	shr    $0x3,%eax
8010199c:	89 c2                	mov    %eax,%edx
8010199e:	a1 74 2a 11 80       	mov    0x80112a74,%eax
801019a3:	01 c2                	add    %eax,%edx
801019a5:	8b 45 08             	mov    0x8(%ebp),%eax
801019a8:	8b 00                	mov    (%eax),%eax
801019aa:	83 ec 08             	sub    $0x8,%esp
801019ad:	52                   	push   %edx
801019ae:	50                   	push   %eax
801019af:	e8 23 e8 ff ff       	call   801001d7 <bread>
801019b4:	83 c4 10             	add    $0x10,%esp
801019b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801019ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019bd:	8d 50 5c             	lea    0x5c(%eax),%edx
801019c0:	8b 45 08             	mov    0x8(%ebp),%eax
801019c3:	8b 40 04             	mov    0x4(%eax),%eax
801019c6:	83 e0 07             	and    $0x7,%eax
801019c9:	c1 e0 06             	shl    $0x6,%eax
801019cc:	01 d0                	add    %edx,%eax
801019ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801019d1:	8b 45 08             	mov    0x8(%ebp),%eax
801019d4:	0f b7 50 50          	movzwl 0x50(%eax),%edx
801019d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019db:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801019de:	8b 45 08             	mov    0x8(%ebp),%eax
801019e1:	0f b7 50 52          	movzwl 0x52(%eax),%edx
801019e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019e8:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801019ec:	8b 45 08             	mov    0x8(%ebp),%eax
801019ef:	0f b7 50 54          	movzwl 0x54(%eax),%edx
801019f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019f6:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801019fa:	8b 45 08             	mov    0x8(%ebp),%eax
801019fd:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101a01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a04:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101a08:	8b 45 08             	mov    0x8(%ebp),%eax
80101a0b:	8b 50 58             	mov    0x58(%eax),%edx
80101a0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a11:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101a14:	8b 45 08             	mov    0x8(%ebp),%eax
80101a17:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a1d:	83 c0 0c             	add    $0xc,%eax
80101a20:	83 ec 04             	sub    $0x4,%esp
80101a23:	6a 34                	push   $0x34
80101a25:	52                   	push   %edx
80101a26:	50                   	push   %eax
80101a27:	e8 da 3b 00 00       	call   80105606 <memmove>
80101a2c:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101a2f:	83 ec 0c             	sub    $0xc,%esp
80101a32:	ff 75 f4             	pushl  -0xc(%ebp)
80101a35:	e8 50 1f 00 00       	call   8010398a <log_write>
80101a3a:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101a3d:	83 ec 0c             	sub    $0xc,%esp
80101a40:	ff 75 f4             	pushl  -0xc(%ebp)
80101a43:	e8 19 e8 ff ff       	call   80100261 <brelse>
80101a48:	83 c4 10             	add    $0x10,%esp
}
80101a4b:	90                   	nop
80101a4c:	c9                   	leave  
80101a4d:	c3                   	ret    

80101a4e <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101a4e:	f3 0f 1e fb          	endbr32 
80101a52:	55                   	push   %ebp
80101a53:	89 e5                	mov    %esp,%ebp
80101a55:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101a58:	83 ec 0c             	sub    $0xc,%esp
80101a5b:	68 80 2a 11 80       	push   $0x80112a80
80101a60:	e8 3b 38 00 00       	call   801052a0 <acquire>
80101a65:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101a68:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a6f:	c7 45 f4 b4 2a 11 80 	movl   $0x80112ab4,-0xc(%ebp)
80101a76:	eb 60                	jmp    80101ad8 <iget+0x8a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a7b:	8b 40 08             	mov    0x8(%eax),%eax
80101a7e:	85 c0                	test   %eax,%eax
80101a80:	7e 39                	jle    80101abb <iget+0x6d>
80101a82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a85:	8b 00                	mov    (%eax),%eax
80101a87:	39 45 08             	cmp    %eax,0x8(%ebp)
80101a8a:	75 2f                	jne    80101abb <iget+0x6d>
80101a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a8f:	8b 40 04             	mov    0x4(%eax),%eax
80101a92:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101a95:	75 24                	jne    80101abb <iget+0x6d>
      ip->ref++;
80101a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a9a:	8b 40 08             	mov    0x8(%eax),%eax
80101a9d:	8d 50 01             	lea    0x1(%eax),%edx
80101aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aa3:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101aa6:	83 ec 0c             	sub    $0xc,%esp
80101aa9:	68 80 2a 11 80       	push   $0x80112a80
80101aae:	e8 5f 38 00 00       	call   80105312 <release>
80101ab3:	83 c4 10             	add    $0x10,%esp
      return ip;
80101ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ab9:	eb 77                	jmp    80101b32 <iget+0xe4>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101abb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101abf:	75 10                	jne    80101ad1 <iget+0x83>
80101ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ac4:	8b 40 08             	mov    0x8(%eax),%eax
80101ac7:	85 c0                	test   %eax,%eax
80101ac9:	75 06                	jne    80101ad1 <iget+0x83>
      empty = ip;
80101acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ace:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101ad1:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101ad8:	81 7d f4 d4 46 11 80 	cmpl   $0x801146d4,-0xc(%ebp)
80101adf:	72 97                	jb     80101a78 <iget+0x2a>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101ae1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101ae5:	75 0d                	jne    80101af4 <iget+0xa6>
    panic("iget: no inodes");
80101ae7:	83 ec 0c             	sub    $0xc,%esp
80101aea:	68 c9 93 10 80       	push   $0x801093c9
80101aef:	e8 14 eb ff ff       	call   80100608 <panic>

  ip = empty;
80101af4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101af7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101afd:	8b 55 08             	mov    0x8(%ebp),%edx
80101b00:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b05:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b08:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b0e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b18:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101b1f:	83 ec 0c             	sub    $0xc,%esp
80101b22:	68 80 2a 11 80       	push   $0x80112a80
80101b27:	e8 e6 37 00 00       	call   80105312 <release>
80101b2c:	83 c4 10             	add    $0x10,%esp

  return ip;
80101b2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101b32:	c9                   	leave  
80101b33:	c3                   	ret    

80101b34 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101b34:	f3 0f 1e fb          	endbr32 
80101b38:	55                   	push   %ebp
80101b39:	89 e5                	mov    %esp,%ebp
80101b3b:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101b3e:	83 ec 0c             	sub    $0xc,%esp
80101b41:	68 80 2a 11 80       	push   $0x80112a80
80101b46:	e8 55 37 00 00       	call   801052a0 <acquire>
80101b4b:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101b4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b51:	8b 40 08             	mov    0x8(%eax),%eax
80101b54:	8d 50 01             	lea    0x1(%eax),%edx
80101b57:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5a:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b5d:	83 ec 0c             	sub    $0xc,%esp
80101b60:	68 80 2a 11 80       	push   $0x80112a80
80101b65:	e8 a8 37 00 00       	call   80105312 <release>
80101b6a:	83 c4 10             	add    $0x10,%esp
  return ip;
80101b6d:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101b70:	c9                   	leave  
80101b71:	c3                   	ret    

80101b72 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101b72:	f3 0f 1e fb          	endbr32 
80101b76:	55                   	push   %ebp
80101b77:	89 e5                	mov    %esp,%ebp
80101b79:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101b7c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b80:	74 0a                	je     80101b8c <ilock+0x1a>
80101b82:	8b 45 08             	mov    0x8(%ebp),%eax
80101b85:	8b 40 08             	mov    0x8(%eax),%eax
80101b88:	85 c0                	test   %eax,%eax
80101b8a:	7f 0d                	jg     80101b99 <ilock+0x27>
    panic("ilock");
80101b8c:	83 ec 0c             	sub    $0xc,%esp
80101b8f:	68 d9 93 10 80       	push   $0x801093d9
80101b94:	e8 6f ea ff ff       	call   80100608 <panic>

  acquiresleep(&ip->lock);
80101b99:	8b 45 08             	mov    0x8(%ebp),%eax
80101b9c:	83 c0 0c             	add    $0xc,%eax
80101b9f:	83 ec 0c             	sub    $0xc,%esp
80101ba2:	50                   	push   %eax
80101ba3:	e8 7f 35 00 00       	call   80105127 <acquiresleep>
80101ba8:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101bab:	8b 45 08             	mov    0x8(%ebp),%eax
80101bae:	8b 40 4c             	mov    0x4c(%eax),%eax
80101bb1:	85 c0                	test   %eax,%eax
80101bb3:	0f 85 cd 00 00 00    	jne    80101c86 <ilock+0x114>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbc:	8b 40 04             	mov    0x4(%eax),%eax
80101bbf:	c1 e8 03             	shr    $0x3,%eax
80101bc2:	89 c2                	mov    %eax,%edx
80101bc4:	a1 74 2a 11 80       	mov    0x80112a74,%eax
80101bc9:	01 c2                	add    %eax,%edx
80101bcb:	8b 45 08             	mov    0x8(%ebp),%eax
80101bce:	8b 00                	mov    (%eax),%eax
80101bd0:	83 ec 08             	sub    $0x8,%esp
80101bd3:	52                   	push   %edx
80101bd4:	50                   	push   %eax
80101bd5:	e8 fd e5 ff ff       	call   801001d7 <bread>
80101bda:	83 c4 10             	add    $0x10,%esp
80101bdd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101be0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101be3:	8d 50 5c             	lea    0x5c(%eax),%edx
80101be6:	8b 45 08             	mov    0x8(%ebp),%eax
80101be9:	8b 40 04             	mov    0x4(%eax),%eax
80101bec:	83 e0 07             	and    $0x7,%eax
80101bef:	c1 e0 06             	shl    $0x6,%eax
80101bf2:	01 d0                	add    %edx,%eax
80101bf4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101bf7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bfa:	0f b7 10             	movzwl (%eax),%edx
80101bfd:	8b 45 08             	mov    0x8(%ebp),%eax
80101c00:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101c04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c07:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101c0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0e:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101c12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c15:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101c19:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1c:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101c20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c23:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101c27:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2a:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101c2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c31:	8b 50 08             	mov    0x8(%eax),%edx
80101c34:	8b 45 08             	mov    0x8(%ebp),%eax
80101c37:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101c3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c3d:	8d 50 0c             	lea    0xc(%eax),%edx
80101c40:	8b 45 08             	mov    0x8(%ebp),%eax
80101c43:	83 c0 5c             	add    $0x5c,%eax
80101c46:	83 ec 04             	sub    $0x4,%esp
80101c49:	6a 34                	push   $0x34
80101c4b:	52                   	push   %edx
80101c4c:	50                   	push   %eax
80101c4d:	e8 b4 39 00 00       	call   80105606 <memmove>
80101c52:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101c55:	83 ec 0c             	sub    $0xc,%esp
80101c58:	ff 75 f4             	pushl  -0xc(%ebp)
80101c5b:	e8 01 e6 ff ff       	call   80100261 <brelse>
80101c60:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101c63:	8b 45 08             	mov    0x8(%ebp),%eax
80101c66:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101c6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c70:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101c74:	66 85 c0             	test   %ax,%ax
80101c77:	75 0d                	jne    80101c86 <ilock+0x114>
      panic("ilock: no type");
80101c79:	83 ec 0c             	sub    $0xc,%esp
80101c7c:	68 df 93 10 80       	push   $0x801093df
80101c81:	e8 82 e9 ff ff       	call   80100608 <panic>
  }
}
80101c86:	90                   	nop
80101c87:	c9                   	leave  
80101c88:	c3                   	ret    

80101c89 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101c89:	f3 0f 1e fb          	endbr32 
80101c8d:	55                   	push   %ebp
80101c8e:	89 e5                	mov    %esp,%ebp
80101c90:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101c93:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101c97:	74 20                	je     80101cb9 <iunlock+0x30>
80101c99:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9c:	83 c0 0c             	add    $0xc,%eax
80101c9f:	83 ec 0c             	sub    $0xc,%esp
80101ca2:	50                   	push   %eax
80101ca3:	e8 39 35 00 00       	call   801051e1 <holdingsleep>
80101ca8:	83 c4 10             	add    $0x10,%esp
80101cab:	85 c0                	test   %eax,%eax
80101cad:	74 0a                	je     80101cb9 <iunlock+0x30>
80101caf:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb2:	8b 40 08             	mov    0x8(%eax),%eax
80101cb5:	85 c0                	test   %eax,%eax
80101cb7:	7f 0d                	jg     80101cc6 <iunlock+0x3d>
    panic("iunlock");
80101cb9:	83 ec 0c             	sub    $0xc,%esp
80101cbc:	68 ee 93 10 80       	push   $0x801093ee
80101cc1:	e8 42 e9 ff ff       	call   80100608 <panic>

  releasesleep(&ip->lock);
80101cc6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc9:	83 c0 0c             	add    $0xc,%eax
80101ccc:	83 ec 0c             	sub    $0xc,%esp
80101ccf:	50                   	push   %eax
80101cd0:	e8 ba 34 00 00       	call   8010518f <releasesleep>
80101cd5:	83 c4 10             	add    $0x10,%esp
}
80101cd8:	90                   	nop
80101cd9:	c9                   	leave  
80101cda:	c3                   	ret    

80101cdb <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101cdb:	f3 0f 1e fb          	endbr32 
80101cdf:	55                   	push   %ebp
80101ce0:	89 e5                	mov    %esp,%ebp
80101ce2:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101ce5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce8:	83 c0 0c             	add    $0xc,%eax
80101ceb:	83 ec 0c             	sub    $0xc,%esp
80101cee:	50                   	push   %eax
80101cef:	e8 33 34 00 00       	call   80105127 <acquiresleep>
80101cf4:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101cf7:	8b 45 08             	mov    0x8(%ebp),%eax
80101cfa:	8b 40 4c             	mov    0x4c(%eax),%eax
80101cfd:	85 c0                	test   %eax,%eax
80101cff:	74 6a                	je     80101d6b <iput+0x90>
80101d01:	8b 45 08             	mov    0x8(%ebp),%eax
80101d04:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101d08:	66 85 c0             	test   %ax,%ax
80101d0b:	75 5e                	jne    80101d6b <iput+0x90>
    acquire(&icache.lock);
80101d0d:	83 ec 0c             	sub    $0xc,%esp
80101d10:	68 80 2a 11 80       	push   $0x80112a80
80101d15:	e8 86 35 00 00       	call   801052a0 <acquire>
80101d1a:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101d1d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d20:	8b 40 08             	mov    0x8(%eax),%eax
80101d23:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101d26:	83 ec 0c             	sub    $0xc,%esp
80101d29:	68 80 2a 11 80       	push   $0x80112a80
80101d2e:	e8 df 35 00 00       	call   80105312 <release>
80101d33:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101d36:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101d3a:	75 2f                	jne    80101d6b <iput+0x90>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101d3c:	83 ec 0c             	sub    $0xc,%esp
80101d3f:	ff 75 08             	pushl  0x8(%ebp)
80101d42:	e8 b5 01 00 00       	call   80101efc <itrunc>
80101d47:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101d4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d4d:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101d53:	83 ec 0c             	sub    $0xc,%esp
80101d56:	ff 75 08             	pushl  0x8(%ebp)
80101d59:	e8 2b fc ff ff       	call   80101989 <iupdate>
80101d5e:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101d61:	8b 45 08             	mov    0x8(%ebp),%eax
80101d64:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101d6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6e:	83 c0 0c             	add    $0xc,%eax
80101d71:	83 ec 0c             	sub    $0xc,%esp
80101d74:	50                   	push   %eax
80101d75:	e8 15 34 00 00       	call   8010518f <releasesleep>
80101d7a:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101d7d:	83 ec 0c             	sub    $0xc,%esp
80101d80:	68 80 2a 11 80       	push   $0x80112a80
80101d85:	e8 16 35 00 00       	call   801052a0 <acquire>
80101d8a:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101d8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d90:	8b 40 08             	mov    0x8(%eax),%eax
80101d93:	8d 50 ff             	lea    -0x1(%eax),%edx
80101d96:	8b 45 08             	mov    0x8(%ebp),%eax
80101d99:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101d9c:	83 ec 0c             	sub    $0xc,%esp
80101d9f:	68 80 2a 11 80       	push   $0x80112a80
80101da4:	e8 69 35 00 00       	call   80105312 <release>
80101da9:	83 c4 10             	add    $0x10,%esp
}
80101dac:	90                   	nop
80101dad:	c9                   	leave  
80101dae:	c3                   	ret    

80101daf <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101daf:	f3 0f 1e fb          	endbr32 
80101db3:	55                   	push   %ebp
80101db4:	89 e5                	mov    %esp,%ebp
80101db6:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101db9:	83 ec 0c             	sub    $0xc,%esp
80101dbc:	ff 75 08             	pushl  0x8(%ebp)
80101dbf:	e8 c5 fe ff ff       	call   80101c89 <iunlock>
80101dc4:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101dc7:	83 ec 0c             	sub    $0xc,%esp
80101dca:	ff 75 08             	pushl  0x8(%ebp)
80101dcd:	e8 09 ff ff ff       	call   80101cdb <iput>
80101dd2:	83 c4 10             	add    $0x10,%esp
}
80101dd5:	90                   	nop
80101dd6:	c9                   	leave  
80101dd7:	c3                   	ret    

80101dd8 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101dd8:	f3 0f 1e fb          	endbr32 
80101ddc:	55                   	push   %ebp
80101ddd:	89 e5                	mov    %esp,%ebp
80101ddf:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101de2:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101de6:	77 42                	ja     80101e2a <bmap+0x52>
    if((addr = ip->addrs[bn]) == 0)
80101de8:	8b 45 08             	mov    0x8(%ebp),%eax
80101deb:	8b 55 0c             	mov    0xc(%ebp),%edx
80101dee:	83 c2 14             	add    $0x14,%edx
80101df1:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101df5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101df8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101dfc:	75 24                	jne    80101e22 <bmap+0x4a>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101dfe:	8b 45 08             	mov    0x8(%ebp),%eax
80101e01:	8b 00                	mov    (%eax),%eax
80101e03:	83 ec 0c             	sub    $0xc,%esp
80101e06:	50                   	push   %eax
80101e07:	e8 c7 f7 ff ff       	call   801015d3 <balloc>
80101e0c:	83 c4 10             	add    $0x10,%esp
80101e0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e12:	8b 45 08             	mov    0x8(%ebp),%eax
80101e15:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e18:	8d 4a 14             	lea    0x14(%edx),%ecx
80101e1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e1e:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101e22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e25:	e9 d0 00 00 00       	jmp    80101efa <bmap+0x122>
  }
  bn -= NDIRECT;
80101e2a:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101e2e:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101e32:	0f 87 b5 00 00 00    	ja     80101eed <bmap+0x115>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101e38:	8b 45 08             	mov    0x8(%ebp),%eax
80101e3b:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e41:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e44:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e48:	75 20                	jne    80101e6a <bmap+0x92>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101e4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e4d:	8b 00                	mov    (%eax),%eax
80101e4f:	83 ec 0c             	sub    $0xc,%esp
80101e52:	50                   	push   %eax
80101e53:	e8 7b f7 ff ff       	call   801015d3 <balloc>
80101e58:	83 c4 10             	add    $0x10,%esp
80101e5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e5e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e61:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e64:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101e6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6d:	8b 00                	mov    (%eax),%eax
80101e6f:	83 ec 08             	sub    $0x8,%esp
80101e72:	ff 75 f4             	pushl  -0xc(%ebp)
80101e75:	50                   	push   %eax
80101e76:	e8 5c e3 ff ff       	call   801001d7 <bread>
80101e7b:	83 c4 10             	add    $0x10,%esp
80101e7e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101e81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e84:	83 c0 5c             	add    $0x5c,%eax
80101e87:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101e8a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e8d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e94:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e97:	01 d0                	add    %edx,%eax
80101e99:	8b 00                	mov    (%eax),%eax
80101e9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e9e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101ea2:	75 36                	jne    80101eda <bmap+0x102>
      a[bn] = addr = balloc(ip->dev);
80101ea4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea7:	8b 00                	mov    (%eax),%eax
80101ea9:	83 ec 0c             	sub    $0xc,%esp
80101eac:	50                   	push   %eax
80101ead:	e8 21 f7 ff ff       	call   801015d3 <balloc>
80101eb2:	83 c4 10             	add    $0x10,%esp
80101eb5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101eb8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ebb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ec2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ec5:	01 c2                	add    %eax,%edx
80101ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101eca:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101ecc:	83 ec 0c             	sub    $0xc,%esp
80101ecf:	ff 75 f0             	pushl  -0x10(%ebp)
80101ed2:	e8 b3 1a 00 00       	call   8010398a <log_write>
80101ed7:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101eda:	83 ec 0c             	sub    $0xc,%esp
80101edd:	ff 75 f0             	pushl  -0x10(%ebp)
80101ee0:	e8 7c e3 ff ff       	call   80100261 <brelse>
80101ee5:	83 c4 10             	add    $0x10,%esp
    return addr;
80101ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101eeb:	eb 0d                	jmp    80101efa <bmap+0x122>
  }

  panic("bmap: out of range");
80101eed:	83 ec 0c             	sub    $0xc,%esp
80101ef0:	68 f6 93 10 80       	push   $0x801093f6
80101ef5:	e8 0e e7 ff ff       	call   80100608 <panic>
}
80101efa:	c9                   	leave  
80101efb:	c3                   	ret    

80101efc <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101efc:	f3 0f 1e fb          	endbr32 
80101f00:	55                   	push   %ebp
80101f01:	89 e5                	mov    %esp,%ebp
80101f03:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101f06:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f0d:	eb 45                	jmp    80101f54 <itrunc+0x58>
    if(ip->addrs[i]){
80101f0f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f12:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f15:	83 c2 14             	add    $0x14,%edx
80101f18:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101f1c:	85 c0                	test   %eax,%eax
80101f1e:	74 30                	je     80101f50 <itrunc+0x54>
      bfree(ip->dev, ip->addrs[i]);
80101f20:	8b 45 08             	mov    0x8(%ebp),%eax
80101f23:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f26:	83 c2 14             	add    $0x14,%edx
80101f29:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101f2d:	8b 55 08             	mov    0x8(%ebp),%edx
80101f30:	8b 12                	mov    (%edx),%edx
80101f32:	83 ec 08             	sub    $0x8,%esp
80101f35:	50                   	push   %eax
80101f36:	52                   	push   %edx
80101f37:	e8 e7 f7 ff ff       	call   80101723 <bfree>
80101f3c:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101f3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f42:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f45:	83 c2 14             	add    $0x14,%edx
80101f48:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101f4f:	00 
  for(i = 0; i < NDIRECT; i++){
80101f50:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101f54:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101f58:	7e b5                	jle    80101f0f <itrunc+0x13>
    }
  }

  if(ip->addrs[NDIRECT]){
80101f5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f5d:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101f63:	85 c0                	test   %eax,%eax
80101f65:	0f 84 aa 00 00 00    	je     80102015 <itrunc+0x119>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101f6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f6e:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101f74:	8b 45 08             	mov    0x8(%ebp),%eax
80101f77:	8b 00                	mov    (%eax),%eax
80101f79:	83 ec 08             	sub    $0x8,%esp
80101f7c:	52                   	push   %edx
80101f7d:	50                   	push   %eax
80101f7e:	e8 54 e2 ff ff       	call   801001d7 <bread>
80101f83:	83 c4 10             	add    $0x10,%esp
80101f86:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101f89:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f8c:	83 c0 5c             	add    $0x5c,%eax
80101f8f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101f92:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101f99:	eb 3c                	jmp    80101fd7 <itrunc+0xdb>
      if(a[j])
80101f9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f9e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101fa5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101fa8:	01 d0                	add    %edx,%eax
80101faa:	8b 00                	mov    (%eax),%eax
80101fac:	85 c0                	test   %eax,%eax
80101fae:	74 23                	je     80101fd3 <itrunc+0xd7>
        bfree(ip->dev, a[j]);
80101fb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fb3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101fba:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101fbd:	01 d0                	add    %edx,%eax
80101fbf:	8b 00                	mov    (%eax),%eax
80101fc1:	8b 55 08             	mov    0x8(%ebp),%edx
80101fc4:	8b 12                	mov    (%edx),%edx
80101fc6:	83 ec 08             	sub    $0x8,%esp
80101fc9:	50                   	push   %eax
80101fca:	52                   	push   %edx
80101fcb:	e8 53 f7 ff ff       	call   80101723 <bfree>
80101fd0:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101fd3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101fd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fda:	83 f8 7f             	cmp    $0x7f,%eax
80101fdd:	76 bc                	jbe    80101f9b <itrunc+0x9f>
    }
    brelse(bp);
80101fdf:	83 ec 0c             	sub    $0xc,%esp
80101fe2:	ff 75 ec             	pushl  -0x14(%ebp)
80101fe5:	e8 77 e2 ff ff       	call   80100261 <brelse>
80101fea:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101fed:	8b 45 08             	mov    0x8(%ebp),%eax
80101ff0:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101ff6:	8b 55 08             	mov    0x8(%ebp),%edx
80101ff9:	8b 12                	mov    (%edx),%edx
80101ffb:	83 ec 08             	sub    $0x8,%esp
80101ffe:	50                   	push   %eax
80101fff:	52                   	push   %edx
80102000:	e8 1e f7 ff ff       	call   80101723 <bfree>
80102005:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80102008:	8b 45 08             	mov    0x8(%ebp),%eax
8010200b:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80102012:	00 00 00 
  }

  ip->size = 0;
80102015:	8b 45 08             	mov    0x8(%ebp),%eax
80102018:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
8010201f:	83 ec 0c             	sub    $0xc,%esp
80102022:	ff 75 08             	pushl  0x8(%ebp)
80102025:	e8 5f f9 ff ff       	call   80101989 <iupdate>
8010202a:	83 c4 10             	add    $0x10,%esp
}
8010202d:	90                   	nop
8010202e:	c9                   	leave  
8010202f:	c3                   	ret    

80102030 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80102030:	f3 0f 1e fb          	endbr32 
80102034:	55                   	push   %ebp
80102035:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80102037:	8b 45 08             	mov    0x8(%ebp),%eax
8010203a:	8b 00                	mov    (%eax),%eax
8010203c:	89 c2                	mov    %eax,%edx
8010203e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102041:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80102044:	8b 45 08             	mov    0x8(%ebp),%eax
80102047:	8b 50 04             	mov    0x4(%eax),%edx
8010204a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010204d:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80102050:	8b 45 08             	mov    0x8(%ebp),%eax
80102053:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80102057:	8b 45 0c             	mov    0xc(%ebp),%eax
8010205a:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
8010205d:	8b 45 08             	mov    0x8(%ebp),%eax
80102060:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80102064:	8b 45 0c             	mov    0xc(%ebp),%eax
80102067:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
8010206b:	8b 45 08             	mov    0x8(%ebp),%eax
8010206e:	8b 50 58             	mov    0x58(%eax),%edx
80102071:	8b 45 0c             	mov    0xc(%ebp),%eax
80102074:	89 50 10             	mov    %edx,0x10(%eax)
}
80102077:	90                   	nop
80102078:	5d                   	pop    %ebp
80102079:	c3                   	ret    

8010207a <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
8010207a:	f3 0f 1e fb          	endbr32 
8010207e:	55                   	push   %ebp
8010207f:	89 e5                	mov    %esp,%ebp
80102081:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102084:	8b 45 08             	mov    0x8(%ebp),%eax
80102087:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010208b:	66 83 f8 03          	cmp    $0x3,%ax
8010208f:	75 5c                	jne    801020ed <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80102091:	8b 45 08             	mov    0x8(%ebp),%eax
80102094:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102098:	66 85 c0             	test   %ax,%ax
8010209b:	78 20                	js     801020bd <readi+0x43>
8010209d:	8b 45 08             	mov    0x8(%ebp),%eax
801020a0:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020a4:	66 83 f8 09          	cmp    $0x9,%ax
801020a8:	7f 13                	jg     801020bd <readi+0x43>
801020aa:	8b 45 08             	mov    0x8(%ebp),%eax
801020ad:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020b1:	98                   	cwtl   
801020b2:	8b 04 c5 00 2a 11 80 	mov    -0x7feed600(,%eax,8),%eax
801020b9:	85 c0                	test   %eax,%eax
801020bb:	75 0a                	jne    801020c7 <readi+0x4d>
      return -1;
801020bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020c2:	e9 0a 01 00 00       	jmp    801021d1 <readi+0x157>
    return devsw[ip->major].read(ip, dst, n);
801020c7:	8b 45 08             	mov    0x8(%ebp),%eax
801020ca:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020ce:	98                   	cwtl   
801020cf:	8b 04 c5 00 2a 11 80 	mov    -0x7feed600(,%eax,8),%eax
801020d6:	8b 55 14             	mov    0x14(%ebp),%edx
801020d9:	83 ec 04             	sub    $0x4,%esp
801020dc:	52                   	push   %edx
801020dd:	ff 75 0c             	pushl  0xc(%ebp)
801020e0:	ff 75 08             	pushl  0x8(%ebp)
801020e3:	ff d0                	call   *%eax
801020e5:	83 c4 10             	add    $0x10,%esp
801020e8:	e9 e4 00 00 00       	jmp    801021d1 <readi+0x157>
  }

  if(off > ip->size || off + n < off)
801020ed:	8b 45 08             	mov    0x8(%ebp),%eax
801020f0:	8b 40 58             	mov    0x58(%eax),%eax
801020f3:	39 45 10             	cmp    %eax,0x10(%ebp)
801020f6:	77 0d                	ja     80102105 <readi+0x8b>
801020f8:	8b 55 10             	mov    0x10(%ebp),%edx
801020fb:	8b 45 14             	mov    0x14(%ebp),%eax
801020fe:	01 d0                	add    %edx,%eax
80102100:	39 45 10             	cmp    %eax,0x10(%ebp)
80102103:	76 0a                	jbe    8010210f <readi+0x95>
    return -1;
80102105:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010210a:	e9 c2 00 00 00       	jmp    801021d1 <readi+0x157>
  if(off + n > ip->size)
8010210f:	8b 55 10             	mov    0x10(%ebp),%edx
80102112:	8b 45 14             	mov    0x14(%ebp),%eax
80102115:	01 c2                	add    %eax,%edx
80102117:	8b 45 08             	mov    0x8(%ebp),%eax
8010211a:	8b 40 58             	mov    0x58(%eax),%eax
8010211d:	39 c2                	cmp    %eax,%edx
8010211f:	76 0c                	jbe    8010212d <readi+0xb3>
    n = ip->size - off;
80102121:	8b 45 08             	mov    0x8(%ebp),%eax
80102124:	8b 40 58             	mov    0x58(%eax),%eax
80102127:	2b 45 10             	sub    0x10(%ebp),%eax
8010212a:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010212d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102134:	e9 89 00 00 00       	jmp    801021c2 <readi+0x148>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102139:	8b 45 10             	mov    0x10(%ebp),%eax
8010213c:	c1 e8 09             	shr    $0x9,%eax
8010213f:	83 ec 08             	sub    $0x8,%esp
80102142:	50                   	push   %eax
80102143:	ff 75 08             	pushl  0x8(%ebp)
80102146:	e8 8d fc ff ff       	call   80101dd8 <bmap>
8010214b:	83 c4 10             	add    $0x10,%esp
8010214e:	8b 55 08             	mov    0x8(%ebp),%edx
80102151:	8b 12                	mov    (%edx),%edx
80102153:	83 ec 08             	sub    $0x8,%esp
80102156:	50                   	push   %eax
80102157:	52                   	push   %edx
80102158:	e8 7a e0 ff ff       	call   801001d7 <bread>
8010215d:	83 c4 10             	add    $0x10,%esp
80102160:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102163:	8b 45 10             	mov    0x10(%ebp),%eax
80102166:	25 ff 01 00 00       	and    $0x1ff,%eax
8010216b:	ba 00 02 00 00       	mov    $0x200,%edx
80102170:	29 c2                	sub    %eax,%edx
80102172:	8b 45 14             	mov    0x14(%ebp),%eax
80102175:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102178:	39 c2                	cmp    %eax,%edx
8010217a:	0f 46 c2             	cmovbe %edx,%eax
8010217d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80102180:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102183:	8d 50 5c             	lea    0x5c(%eax),%edx
80102186:	8b 45 10             	mov    0x10(%ebp),%eax
80102189:	25 ff 01 00 00       	and    $0x1ff,%eax
8010218e:	01 d0                	add    %edx,%eax
80102190:	83 ec 04             	sub    $0x4,%esp
80102193:	ff 75 ec             	pushl  -0x14(%ebp)
80102196:	50                   	push   %eax
80102197:	ff 75 0c             	pushl  0xc(%ebp)
8010219a:	e8 67 34 00 00       	call   80105606 <memmove>
8010219f:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801021a2:	83 ec 0c             	sub    $0xc,%esp
801021a5:	ff 75 f0             	pushl  -0x10(%ebp)
801021a8:	e8 b4 e0 ff ff       	call   80100261 <brelse>
801021ad:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801021b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021b3:	01 45 f4             	add    %eax,-0xc(%ebp)
801021b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021b9:	01 45 10             	add    %eax,0x10(%ebp)
801021bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021bf:	01 45 0c             	add    %eax,0xc(%ebp)
801021c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021c5:	3b 45 14             	cmp    0x14(%ebp),%eax
801021c8:	0f 82 6b ff ff ff    	jb     80102139 <readi+0xbf>
  }
  return n;
801021ce:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021d1:	c9                   	leave  
801021d2:	c3                   	ret    

801021d3 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801021d3:	f3 0f 1e fb          	endbr32 
801021d7:	55                   	push   %ebp
801021d8:	89 e5                	mov    %esp,%ebp
801021da:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801021dd:	8b 45 08             	mov    0x8(%ebp),%eax
801021e0:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021e4:	66 83 f8 03          	cmp    $0x3,%ax
801021e8:	75 5c                	jne    80102246 <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801021ea:	8b 45 08             	mov    0x8(%ebp),%eax
801021ed:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801021f1:	66 85 c0             	test   %ax,%ax
801021f4:	78 20                	js     80102216 <writei+0x43>
801021f6:	8b 45 08             	mov    0x8(%ebp),%eax
801021f9:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801021fd:	66 83 f8 09          	cmp    $0x9,%ax
80102201:	7f 13                	jg     80102216 <writei+0x43>
80102203:	8b 45 08             	mov    0x8(%ebp),%eax
80102206:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010220a:	98                   	cwtl   
8010220b:	8b 04 c5 04 2a 11 80 	mov    -0x7feed5fc(,%eax,8),%eax
80102212:	85 c0                	test   %eax,%eax
80102214:	75 0a                	jne    80102220 <writei+0x4d>
      return -1;
80102216:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010221b:	e9 3b 01 00 00       	jmp    8010235b <writei+0x188>
    return devsw[ip->major].write(ip, src, n);
80102220:	8b 45 08             	mov    0x8(%ebp),%eax
80102223:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102227:	98                   	cwtl   
80102228:	8b 04 c5 04 2a 11 80 	mov    -0x7feed5fc(,%eax,8),%eax
8010222f:	8b 55 14             	mov    0x14(%ebp),%edx
80102232:	83 ec 04             	sub    $0x4,%esp
80102235:	52                   	push   %edx
80102236:	ff 75 0c             	pushl  0xc(%ebp)
80102239:	ff 75 08             	pushl  0x8(%ebp)
8010223c:	ff d0                	call   *%eax
8010223e:	83 c4 10             	add    $0x10,%esp
80102241:	e9 15 01 00 00       	jmp    8010235b <writei+0x188>
  }

  if(off > ip->size || off + n < off)
80102246:	8b 45 08             	mov    0x8(%ebp),%eax
80102249:	8b 40 58             	mov    0x58(%eax),%eax
8010224c:	39 45 10             	cmp    %eax,0x10(%ebp)
8010224f:	77 0d                	ja     8010225e <writei+0x8b>
80102251:	8b 55 10             	mov    0x10(%ebp),%edx
80102254:	8b 45 14             	mov    0x14(%ebp),%eax
80102257:	01 d0                	add    %edx,%eax
80102259:	39 45 10             	cmp    %eax,0x10(%ebp)
8010225c:	76 0a                	jbe    80102268 <writei+0x95>
    return -1;
8010225e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102263:	e9 f3 00 00 00       	jmp    8010235b <writei+0x188>
  if(off + n > MAXFILE*BSIZE)
80102268:	8b 55 10             	mov    0x10(%ebp),%edx
8010226b:	8b 45 14             	mov    0x14(%ebp),%eax
8010226e:	01 d0                	add    %edx,%eax
80102270:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102275:	76 0a                	jbe    80102281 <writei+0xae>
    return -1;
80102277:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010227c:	e9 da 00 00 00       	jmp    8010235b <writei+0x188>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102281:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102288:	e9 97 00 00 00       	jmp    80102324 <writei+0x151>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010228d:	8b 45 10             	mov    0x10(%ebp),%eax
80102290:	c1 e8 09             	shr    $0x9,%eax
80102293:	83 ec 08             	sub    $0x8,%esp
80102296:	50                   	push   %eax
80102297:	ff 75 08             	pushl  0x8(%ebp)
8010229a:	e8 39 fb ff ff       	call   80101dd8 <bmap>
8010229f:	83 c4 10             	add    $0x10,%esp
801022a2:	8b 55 08             	mov    0x8(%ebp),%edx
801022a5:	8b 12                	mov    (%edx),%edx
801022a7:	83 ec 08             	sub    $0x8,%esp
801022aa:	50                   	push   %eax
801022ab:	52                   	push   %edx
801022ac:	e8 26 df ff ff       	call   801001d7 <bread>
801022b1:	83 c4 10             	add    $0x10,%esp
801022b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801022b7:	8b 45 10             	mov    0x10(%ebp),%eax
801022ba:	25 ff 01 00 00       	and    $0x1ff,%eax
801022bf:	ba 00 02 00 00       	mov    $0x200,%edx
801022c4:	29 c2                	sub    %eax,%edx
801022c6:	8b 45 14             	mov    0x14(%ebp),%eax
801022c9:	2b 45 f4             	sub    -0xc(%ebp),%eax
801022cc:	39 c2                	cmp    %eax,%edx
801022ce:	0f 46 c2             	cmovbe %edx,%eax
801022d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801022d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022d7:	8d 50 5c             	lea    0x5c(%eax),%edx
801022da:	8b 45 10             	mov    0x10(%ebp),%eax
801022dd:	25 ff 01 00 00       	and    $0x1ff,%eax
801022e2:	01 d0                	add    %edx,%eax
801022e4:	83 ec 04             	sub    $0x4,%esp
801022e7:	ff 75 ec             	pushl  -0x14(%ebp)
801022ea:	ff 75 0c             	pushl  0xc(%ebp)
801022ed:	50                   	push   %eax
801022ee:	e8 13 33 00 00       	call   80105606 <memmove>
801022f3:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
801022f6:	83 ec 0c             	sub    $0xc,%esp
801022f9:	ff 75 f0             	pushl  -0x10(%ebp)
801022fc:	e8 89 16 00 00       	call   8010398a <log_write>
80102301:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102304:	83 ec 0c             	sub    $0xc,%esp
80102307:	ff 75 f0             	pushl  -0x10(%ebp)
8010230a:	e8 52 df ff ff       	call   80100261 <brelse>
8010230f:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102312:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102315:	01 45 f4             	add    %eax,-0xc(%ebp)
80102318:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010231b:	01 45 10             	add    %eax,0x10(%ebp)
8010231e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102321:	01 45 0c             	add    %eax,0xc(%ebp)
80102324:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102327:	3b 45 14             	cmp    0x14(%ebp),%eax
8010232a:	0f 82 5d ff ff ff    	jb     8010228d <writei+0xba>
  }

  if(n > 0 && off > ip->size){
80102330:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102334:	74 22                	je     80102358 <writei+0x185>
80102336:	8b 45 08             	mov    0x8(%ebp),%eax
80102339:	8b 40 58             	mov    0x58(%eax),%eax
8010233c:	39 45 10             	cmp    %eax,0x10(%ebp)
8010233f:	76 17                	jbe    80102358 <writei+0x185>
    ip->size = off;
80102341:	8b 45 08             	mov    0x8(%ebp),%eax
80102344:	8b 55 10             	mov    0x10(%ebp),%edx
80102347:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
8010234a:	83 ec 0c             	sub    $0xc,%esp
8010234d:	ff 75 08             	pushl  0x8(%ebp)
80102350:	e8 34 f6 ff ff       	call   80101989 <iupdate>
80102355:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102358:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010235b:	c9                   	leave  
8010235c:	c3                   	ret    

8010235d <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010235d:	f3 0f 1e fb          	endbr32 
80102361:	55                   	push   %ebp
80102362:	89 e5                	mov    %esp,%ebp
80102364:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102367:	83 ec 04             	sub    $0x4,%esp
8010236a:	6a 0e                	push   $0xe
8010236c:	ff 75 0c             	pushl  0xc(%ebp)
8010236f:	ff 75 08             	pushl  0x8(%ebp)
80102372:	e8 2d 33 00 00       	call   801056a4 <strncmp>
80102377:	83 c4 10             	add    $0x10,%esp
}
8010237a:	c9                   	leave  
8010237b:	c3                   	ret    

8010237c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010237c:	f3 0f 1e fb          	endbr32 
80102380:	55                   	push   %ebp
80102381:	89 e5                	mov    %esp,%ebp
80102383:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102386:	8b 45 08             	mov    0x8(%ebp),%eax
80102389:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010238d:	66 83 f8 01          	cmp    $0x1,%ax
80102391:	74 0d                	je     801023a0 <dirlookup+0x24>
    panic("dirlookup not DIR");
80102393:	83 ec 0c             	sub    $0xc,%esp
80102396:	68 09 94 10 80       	push   $0x80109409
8010239b:	e8 68 e2 ff ff       	call   80100608 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801023a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801023a7:	eb 7b                	jmp    80102424 <dirlookup+0xa8>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023a9:	6a 10                	push   $0x10
801023ab:	ff 75 f4             	pushl  -0xc(%ebp)
801023ae:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023b1:	50                   	push   %eax
801023b2:	ff 75 08             	pushl  0x8(%ebp)
801023b5:	e8 c0 fc ff ff       	call   8010207a <readi>
801023ba:	83 c4 10             	add    $0x10,%esp
801023bd:	83 f8 10             	cmp    $0x10,%eax
801023c0:	74 0d                	je     801023cf <dirlookup+0x53>
      panic("dirlookup read");
801023c2:	83 ec 0c             	sub    $0xc,%esp
801023c5:	68 1b 94 10 80       	push   $0x8010941b
801023ca:	e8 39 e2 ff ff       	call   80100608 <panic>
    if(de.inum == 0)
801023cf:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023d3:	66 85 c0             	test   %ax,%ax
801023d6:	74 47                	je     8010241f <dirlookup+0xa3>
      continue;
    if(namecmp(name, de.name) == 0){
801023d8:	83 ec 08             	sub    $0x8,%esp
801023db:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023de:	83 c0 02             	add    $0x2,%eax
801023e1:	50                   	push   %eax
801023e2:	ff 75 0c             	pushl  0xc(%ebp)
801023e5:	e8 73 ff ff ff       	call   8010235d <namecmp>
801023ea:	83 c4 10             	add    $0x10,%esp
801023ed:	85 c0                	test   %eax,%eax
801023ef:	75 2f                	jne    80102420 <dirlookup+0xa4>
      // entry matches path element
      if(poff)
801023f1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801023f5:	74 08                	je     801023ff <dirlookup+0x83>
        *poff = off;
801023f7:	8b 45 10             	mov    0x10(%ebp),%eax
801023fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801023fd:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801023ff:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102403:	0f b7 c0             	movzwl %ax,%eax
80102406:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102409:	8b 45 08             	mov    0x8(%ebp),%eax
8010240c:	8b 00                	mov    (%eax),%eax
8010240e:	83 ec 08             	sub    $0x8,%esp
80102411:	ff 75 f0             	pushl  -0x10(%ebp)
80102414:	50                   	push   %eax
80102415:	e8 34 f6 ff ff       	call   80101a4e <iget>
8010241a:	83 c4 10             	add    $0x10,%esp
8010241d:	eb 19                	jmp    80102438 <dirlookup+0xbc>
      continue;
8010241f:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
80102420:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102424:	8b 45 08             	mov    0x8(%ebp),%eax
80102427:	8b 40 58             	mov    0x58(%eax),%eax
8010242a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010242d:	0f 82 76 ff ff ff    	jb     801023a9 <dirlookup+0x2d>
    }
  }

  return 0;
80102433:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102438:	c9                   	leave  
80102439:	c3                   	ret    

8010243a <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010243a:	f3 0f 1e fb          	endbr32 
8010243e:	55                   	push   %ebp
8010243f:	89 e5                	mov    %esp,%ebp
80102441:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102444:	83 ec 04             	sub    $0x4,%esp
80102447:	6a 00                	push   $0x0
80102449:	ff 75 0c             	pushl  0xc(%ebp)
8010244c:	ff 75 08             	pushl  0x8(%ebp)
8010244f:	e8 28 ff ff ff       	call   8010237c <dirlookup>
80102454:	83 c4 10             	add    $0x10,%esp
80102457:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010245a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010245e:	74 18                	je     80102478 <dirlink+0x3e>
    iput(ip);
80102460:	83 ec 0c             	sub    $0xc,%esp
80102463:	ff 75 f0             	pushl  -0x10(%ebp)
80102466:	e8 70 f8 ff ff       	call   80101cdb <iput>
8010246b:	83 c4 10             	add    $0x10,%esp
    return -1;
8010246e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102473:	e9 9c 00 00 00       	jmp    80102514 <dirlink+0xda>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102478:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010247f:	eb 39                	jmp    801024ba <dirlink+0x80>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102481:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102484:	6a 10                	push   $0x10
80102486:	50                   	push   %eax
80102487:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010248a:	50                   	push   %eax
8010248b:	ff 75 08             	pushl  0x8(%ebp)
8010248e:	e8 e7 fb ff ff       	call   8010207a <readi>
80102493:	83 c4 10             	add    $0x10,%esp
80102496:	83 f8 10             	cmp    $0x10,%eax
80102499:	74 0d                	je     801024a8 <dirlink+0x6e>
      panic("dirlink read");
8010249b:	83 ec 0c             	sub    $0xc,%esp
8010249e:	68 2a 94 10 80       	push   $0x8010942a
801024a3:	e8 60 e1 ff ff       	call   80100608 <panic>
    if(de.inum == 0)
801024a8:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801024ac:	66 85 c0             	test   %ax,%ax
801024af:	74 18                	je     801024c9 <dirlink+0x8f>
  for(off = 0; off < dp->size; off += sizeof(de)){
801024b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024b4:	83 c0 10             	add    $0x10,%eax
801024b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024ba:	8b 45 08             	mov    0x8(%ebp),%eax
801024bd:	8b 50 58             	mov    0x58(%eax),%edx
801024c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024c3:	39 c2                	cmp    %eax,%edx
801024c5:	77 ba                	ja     80102481 <dirlink+0x47>
801024c7:	eb 01                	jmp    801024ca <dirlink+0x90>
      break;
801024c9:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801024ca:	83 ec 04             	sub    $0x4,%esp
801024cd:	6a 0e                	push   $0xe
801024cf:	ff 75 0c             	pushl  0xc(%ebp)
801024d2:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024d5:	83 c0 02             	add    $0x2,%eax
801024d8:	50                   	push   %eax
801024d9:	e8 20 32 00 00       	call   801056fe <strncpy>
801024de:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
801024e1:	8b 45 10             	mov    0x10(%ebp),%eax
801024e4:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801024e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024eb:	6a 10                	push   $0x10
801024ed:	50                   	push   %eax
801024ee:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024f1:	50                   	push   %eax
801024f2:	ff 75 08             	pushl  0x8(%ebp)
801024f5:	e8 d9 fc ff ff       	call   801021d3 <writei>
801024fa:	83 c4 10             	add    $0x10,%esp
801024fd:	83 f8 10             	cmp    $0x10,%eax
80102500:	74 0d                	je     8010250f <dirlink+0xd5>
    panic("dirlink");
80102502:	83 ec 0c             	sub    $0xc,%esp
80102505:	68 37 94 10 80       	push   $0x80109437
8010250a:	e8 f9 e0 ff ff       	call   80100608 <panic>

  return 0;
8010250f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102514:	c9                   	leave  
80102515:	c3                   	ret    

80102516 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102516:	f3 0f 1e fb          	endbr32 
8010251a:	55                   	push   %ebp
8010251b:	89 e5                	mov    %esp,%ebp
8010251d:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102520:	eb 04                	jmp    80102526 <skipelem+0x10>
    path++;
80102522:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102526:	8b 45 08             	mov    0x8(%ebp),%eax
80102529:	0f b6 00             	movzbl (%eax),%eax
8010252c:	3c 2f                	cmp    $0x2f,%al
8010252e:	74 f2                	je     80102522 <skipelem+0xc>
  if(*path == 0)
80102530:	8b 45 08             	mov    0x8(%ebp),%eax
80102533:	0f b6 00             	movzbl (%eax),%eax
80102536:	84 c0                	test   %al,%al
80102538:	75 07                	jne    80102541 <skipelem+0x2b>
    return 0;
8010253a:	b8 00 00 00 00       	mov    $0x0,%eax
8010253f:	eb 77                	jmp    801025b8 <skipelem+0xa2>
  s = path;
80102541:	8b 45 08             	mov    0x8(%ebp),%eax
80102544:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102547:	eb 04                	jmp    8010254d <skipelem+0x37>
    path++;
80102549:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
8010254d:	8b 45 08             	mov    0x8(%ebp),%eax
80102550:	0f b6 00             	movzbl (%eax),%eax
80102553:	3c 2f                	cmp    $0x2f,%al
80102555:	74 0a                	je     80102561 <skipelem+0x4b>
80102557:	8b 45 08             	mov    0x8(%ebp),%eax
8010255a:	0f b6 00             	movzbl (%eax),%eax
8010255d:	84 c0                	test   %al,%al
8010255f:	75 e8                	jne    80102549 <skipelem+0x33>
  len = path - s;
80102561:	8b 45 08             	mov    0x8(%ebp),%eax
80102564:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102567:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
8010256a:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
8010256e:	7e 15                	jle    80102585 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
80102570:	83 ec 04             	sub    $0x4,%esp
80102573:	6a 0e                	push   $0xe
80102575:	ff 75 f4             	pushl  -0xc(%ebp)
80102578:	ff 75 0c             	pushl  0xc(%ebp)
8010257b:	e8 86 30 00 00       	call   80105606 <memmove>
80102580:	83 c4 10             	add    $0x10,%esp
80102583:	eb 26                	jmp    801025ab <skipelem+0x95>
  else {
    memmove(name, s, len);
80102585:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102588:	83 ec 04             	sub    $0x4,%esp
8010258b:	50                   	push   %eax
8010258c:	ff 75 f4             	pushl  -0xc(%ebp)
8010258f:	ff 75 0c             	pushl  0xc(%ebp)
80102592:	e8 6f 30 00 00       	call   80105606 <memmove>
80102597:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
8010259a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010259d:	8b 45 0c             	mov    0xc(%ebp),%eax
801025a0:	01 d0                	add    %edx,%eax
801025a2:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801025a5:	eb 04                	jmp    801025ab <skipelem+0x95>
    path++;
801025a7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801025ab:	8b 45 08             	mov    0x8(%ebp),%eax
801025ae:	0f b6 00             	movzbl (%eax),%eax
801025b1:	3c 2f                	cmp    $0x2f,%al
801025b3:	74 f2                	je     801025a7 <skipelem+0x91>
  return path;
801025b5:	8b 45 08             	mov    0x8(%ebp),%eax
}
801025b8:	c9                   	leave  
801025b9:	c3                   	ret    

801025ba <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801025ba:	f3 0f 1e fb          	endbr32 
801025be:	55                   	push   %ebp
801025bf:	89 e5                	mov    %esp,%ebp
801025c1:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801025c4:	8b 45 08             	mov    0x8(%ebp),%eax
801025c7:	0f b6 00             	movzbl (%eax),%eax
801025ca:	3c 2f                	cmp    $0x2f,%al
801025cc:	75 17                	jne    801025e5 <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
801025ce:	83 ec 08             	sub    $0x8,%esp
801025d1:	6a 01                	push   $0x1
801025d3:	6a 01                	push   $0x1
801025d5:	e8 74 f4 ff ff       	call   80101a4e <iget>
801025da:	83 c4 10             	add    $0x10,%esp
801025dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
801025e0:	e9 ba 00 00 00       	jmp    8010269f <namex+0xe5>
  else
    ip = idup(myproc()->cwd);
801025e5:	e8 16 1f 00 00       	call   80104500 <myproc>
801025ea:	8b 40 68             	mov    0x68(%eax),%eax
801025ed:	83 ec 0c             	sub    $0xc,%esp
801025f0:	50                   	push   %eax
801025f1:	e8 3e f5 ff ff       	call   80101b34 <idup>
801025f6:	83 c4 10             	add    $0x10,%esp
801025f9:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801025fc:	e9 9e 00 00 00       	jmp    8010269f <namex+0xe5>
    ilock(ip);
80102601:	83 ec 0c             	sub    $0xc,%esp
80102604:	ff 75 f4             	pushl  -0xc(%ebp)
80102607:	e8 66 f5 ff ff       	call   80101b72 <ilock>
8010260c:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010260f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102612:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102616:	66 83 f8 01          	cmp    $0x1,%ax
8010261a:	74 18                	je     80102634 <namex+0x7a>
      iunlockput(ip);
8010261c:	83 ec 0c             	sub    $0xc,%esp
8010261f:	ff 75 f4             	pushl  -0xc(%ebp)
80102622:	e8 88 f7 ff ff       	call   80101daf <iunlockput>
80102627:	83 c4 10             	add    $0x10,%esp
      return 0;
8010262a:	b8 00 00 00 00       	mov    $0x0,%eax
8010262f:	e9 a7 00 00 00       	jmp    801026db <namex+0x121>
    }
    if(nameiparent && *path == '\0'){
80102634:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102638:	74 20                	je     8010265a <namex+0xa0>
8010263a:	8b 45 08             	mov    0x8(%ebp),%eax
8010263d:	0f b6 00             	movzbl (%eax),%eax
80102640:	84 c0                	test   %al,%al
80102642:	75 16                	jne    8010265a <namex+0xa0>
      // Stop one level early.
      iunlock(ip);
80102644:	83 ec 0c             	sub    $0xc,%esp
80102647:	ff 75 f4             	pushl  -0xc(%ebp)
8010264a:	e8 3a f6 ff ff       	call   80101c89 <iunlock>
8010264f:	83 c4 10             	add    $0x10,%esp
      return ip;
80102652:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102655:	e9 81 00 00 00       	jmp    801026db <namex+0x121>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010265a:	83 ec 04             	sub    $0x4,%esp
8010265d:	6a 00                	push   $0x0
8010265f:	ff 75 10             	pushl  0x10(%ebp)
80102662:	ff 75 f4             	pushl  -0xc(%ebp)
80102665:	e8 12 fd ff ff       	call   8010237c <dirlookup>
8010266a:	83 c4 10             	add    $0x10,%esp
8010266d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102670:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102674:	75 15                	jne    8010268b <namex+0xd1>
      iunlockput(ip);
80102676:	83 ec 0c             	sub    $0xc,%esp
80102679:	ff 75 f4             	pushl  -0xc(%ebp)
8010267c:	e8 2e f7 ff ff       	call   80101daf <iunlockput>
80102681:	83 c4 10             	add    $0x10,%esp
      return 0;
80102684:	b8 00 00 00 00       	mov    $0x0,%eax
80102689:	eb 50                	jmp    801026db <namex+0x121>
    }
    iunlockput(ip);
8010268b:	83 ec 0c             	sub    $0xc,%esp
8010268e:	ff 75 f4             	pushl  -0xc(%ebp)
80102691:	e8 19 f7 ff ff       	call   80101daf <iunlockput>
80102696:	83 c4 10             	add    $0x10,%esp
    ip = next;
80102699:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010269c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
8010269f:	83 ec 08             	sub    $0x8,%esp
801026a2:	ff 75 10             	pushl  0x10(%ebp)
801026a5:	ff 75 08             	pushl  0x8(%ebp)
801026a8:	e8 69 fe ff ff       	call   80102516 <skipelem>
801026ad:	83 c4 10             	add    $0x10,%esp
801026b0:	89 45 08             	mov    %eax,0x8(%ebp)
801026b3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026b7:	0f 85 44 ff ff ff    	jne    80102601 <namex+0x47>
  }
  if(nameiparent){
801026bd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801026c1:	74 15                	je     801026d8 <namex+0x11e>
    iput(ip);
801026c3:	83 ec 0c             	sub    $0xc,%esp
801026c6:	ff 75 f4             	pushl  -0xc(%ebp)
801026c9:	e8 0d f6 ff ff       	call   80101cdb <iput>
801026ce:	83 c4 10             	add    $0x10,%esp
    return 0;
801026d1:	b8 00 00 00 00       	mov    $0x0,%eax
801026d6:	eb 03                	jmp    801026db <namex+0x121>
  }
  return ip;
801026d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801026db:	c9                   	leave  
801026dc:	c3                   	ret    

801026dd <namei>:

struct inode*
namei(char *path)
{
801026dd:	f3 0f 1e fb          	endbr32 
801026e1:	55                   	push   %ebp
801026e2:	89 e5                	mov    %esp,%ebp
801026e4:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801026e7:	83 ec 04             	sub    $0x4,%esp
801026ea:	8d 45 ea             	lea    -0x16(%ebp),%eax
801026ed:	50                   	push   %eax
801026ee:	6a 00                	push   $0x0
801026f0:	ff 75 08             	pushl  0x8(%ebp)
801026f3:	e8 c2 fe ff ff       	call   801025ba <namex>
801026f8:	83 c4 10             	add    $0x10,%esp
}
801026fb:	c9                   	leave  
801026fc:	c3                   	ret    

801026fd <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801026fd:	f3 0f 1e fb          	endbr32 
80102701:	55                   	push   %ebp
80102702:	89 e5                	mov    %esp,%ebp
80102704:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102707:	83 ec 04             	sub    $0x4,%esp
8010270a:	ff 75 0c             	pushl  0xc(%ebp)
8010270d:	6a 01                	push   $0x1
8010270f:	ff 75 08             	pushl  0x8(%ebp)
80102712:	e8 a3 fe ff ff       	call   801025ba <namex>
80102717:	83 c4 10             	add    $0x10,%esp
}
8010271a:	c9                   	leave  
8010271b:	c3                   	ret    

8010271c <inb>:
{
8010271c:	55                   	push   %ebp
8010271d:	89 e5                	mov    %esp,%ebp
8010271f:	83 ec 14             	sub    $0x14,%esp
80102722:	8b 45 08             	mov    0x8(%ebp),%eax
80102725:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102729:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010272d:	89 c2                	mov    %eax,%edx
8010272f:	ec                   	in     (%dx),%al
80102730:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102733:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102737:	c9                   	leave  
80102738:	c3                   	ret    

80102739 <insl>:
{
80102739:	55                   	push   %ebp
8010273a:	89 e5                	mov    %esp,%ebp
8010273c:	57                   	push   %edi
8010273d:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010273e:	8b 55 08             	mov    0x8(%ebp),%edx
80102741:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102744:	8b 45 10             	mov    0x10(%ebp),%eax
80102747:	89 cb                	mov    %ecx,%ebx
80102749:	89 df                	mov    %ebx,%edi
8010274b:	89 c1                	mov    %eax,%ecx
8010274d:	fc                   	cld    
8010274e:	f3 6d                	rep insl (%dx),%es:(%edi)
80102750:	89 c8                	mov    %ecx,%eax
80102752:	89 fb                	mov    %edi,%ebx
80102754:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102757:	89 45 10             	mov    %eax,0x10(%ebp)
}
8010275a:	90                   	nop
8010275b:	5b                   	pop    %ebx
8010275c:	5f                   	pop    %edi
8010275d:	5d                   	pop    %ebp
8010275e:	c3                   	ret    

8010275f <outb>:
{
8010275f:	55                   	push   %ebp
80102760:	89 e5                	mov    %esp,%ebp
80102762:	83 ec 08             	sub    $0x8,%esp
80102765:	8b 45 08             	mov    0x8(%ebp),%eax
80102768:	8b 55 0c             	mov    0xc(%ebp),%edx
8010276b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010276f:	89 d0                	mov    %edx,%eax
80102771:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102774:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102778:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010277c:	ee                   	out    %al,(%dx)
}
8010277d:	90                   	nop
8010277e:	c9                   	leave  
8010277f:	c3                   	ret    

80102780 <outsl>:
{
80102780:	55                   	push   %ebp
80102781:	89 e5                	mov    %esp,%ebp
80102783:	56                   	push   %esi
80102784:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102785:	8b 55 08             	mov    0x8(%ebp),%edx
80102788:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010278b:	8b 45 10             	mov    0x10(%ebp),%eax
8010278e:	89 cb                	mov    %ecx,%ebx
80102790:	89 de                	mov    %ebx,%esi
80102792:	89 c1                	mov    %eax,%ecx
80102794:	fc                   	cld    
80102795:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102797:	89 c8                	mov    %ecx,%eax
80102799:	89 f3                	mov    %esi,%ebx
8010279b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010279e:	89 45 10             	mov    %eax,0x10(%ebp)
}
801027a1:	90                   	nop
801027a2:	5b                   	pop    %ebx
801027a3:	5e                   	pop    %esi
801027a4:	5d                   	pop    %ebp
801027a5:	c3                   	ret    

801027a6 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801027a6:	f3 0f 1e fb          	endbr32 
801027aa:	55                   	push   %ebp
801027ab:	89 e5                	mov    %esp,%ebp
801027ad:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801027b0:	90                   	nop
801027b1:	68 f7 01 00 00       	push   $0x1f7
801027b6:	e8 61 ff ff ff       	call   8010271c <inb>
801027bb:	83 c4 04             	add    $0x4,%esp
801027be:	0f b6 c0             	movzbl %al,%eax
801027c1:	89 45 fc             	mov    %eax,-0x4(%ebp)
801027c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801027c7:	25 c0 00 00 00       	and    $0xc0,%eax
801027cc:	83 f8 40             	cmp    $0x40,%eax
801027cf:	75 e0                	jne    801027b1 <idewait+0xb>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801027d1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801027d5:	74 11                	je     801027e8 <idewait+0x42>
801027d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801027da:	83 e0 21             	and    $0x21,%eax
801027dd:	85 c0                	test   %eax,%eax
801027df:	74 07                	je     801027e8 <idewait+0x42>
    return -1;
801027e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801027e6:	eb 05                	jmp    801027ed <idewait+0x47>
  return 0;
801027e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801027ed:	c9                   	leave  
801027ee:	c3                   	ret    

801027ef <ideinit>:

void
ideinit(void)
{
801027ef:	f3 0f 1e fb          	endbr32 
801027f3:	55                   	push   %ebp
801027f4:	89 e5                	mov    %esp,%ebp
801027f6:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
801027f9:	83 ec 08             	sub    $0x8,%esp
801027fc:	68 3f 94 10 80       	push   $0x8010943f
80102801:	68 00 c6 10 80       	push   $0x8010c600
80102806:	e8 6f 2a 00 00       	call   8010527a <initlock>
8010280b:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
8010280e:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80102813:	83 e8 01             	sub    $0x1,%eax
80102816:	83 ec 08             	sub    $0x8,%esp
80102819:	50                   	push   %eax
8010281a:	6a 0e                	push   $0xe
8010281c:	e8 bb 04 00 00       	call   80102cdc <ioapicenable>
80102821:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102824:	83 ec 0c             	sub    $0xc,%esp
80102827:	6a 00                	push   $0x0
80102829:	e8 78 ff ff ff       	call   801027a6 <idewait>
8010282e:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102831:	83 ec 08             	sub    $0x8,%esp
80102834:	68 f0 00 00 00       	push   $0xf0
80102839:	68 f6 01 00 00       	push   $0x1f6
8010283e:	e8 1c ff ff ff       	call   8010275f <outb>
80102843:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102846:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010284d:	eb 24                	jmp    80102873 <ideinit+0x84>
    if(inb(0x1f7) != 0){
8010284f:	83 ec 0c             	sub    $0xc,%esp
80102852:	68 f7 01 00 00       	push   $0x1f7
80102857:	e8 c0 fe ff ff       	call   8010271c <inb>
8010285c:	83 c4 10             	add    $0x10,%esp
8010285f:	84 c0                	test   %al,%al
80102861:	74 0c                	je     8010286f <ideinit+0x80>
      havedisk1 = 1;
80102863:	c7 05 38 c6 10 80 01 	movl   $0x1,0x8010c638
8010286a:	00 00 00 
      break;
8010286d:	eb 0d                	jmp    8010287c <ideinit+0x8d>
  for(i=0; i<1000; i++){
8010286f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102873:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
8010287a:	7e d3                	jle    8010284f <ideinit+0x60>
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
8010287c:	83 ec 08             	sub    $0x8,%esp
8010287f:	68 e0 00 00 00       	push   $0xe0
80102884:	68 f6 01 00 00       	push   $0x1f6
80102889:	e8 d1 fe ff ff       	call   8010275f <outb>
8010288e:	83 c4 10             	add    $0x10,%esp
}
80102891:	90                   	nop
80102892:	c9                   	leave  
80102893:	c3                   	ret    

80102894 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102894:	f3 0f 1e fb          	endbr32 
80102898:	55                   	push   %ebp
80102899:	89 e5                	mov    %esp,%ebp
8010289b:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
8010289e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801028a2:	75 0d                	jne    801028b1 <idestart+0x1d>
    panic("idestart");
801028a4:	83 ec 0c             	sub    $0xc,%esp
801028a7:	68 43 94 10 80       	push   $0x80109443
801028ac:	e8 57 dd ff ff       	call   80100608 <panic>
  if(b->blockno >= FSSIZE)
801028b1:	8b 45 08             	mov    0x8(%ebp),%eax
801028b4:	8b 40 08             	mov    0x8(%eax),%eax
801028b7:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801028bc:	76 0d                	jbe    801028cb <idestart+0x37>
    panic("incorrect blockno");
801028be:	83 ec 0c             	sub    $0xc,%esp
801028c1:	68 4c 94 10 80       	push   $0x8010944c
801028c6:	e8 3d dd ff ff       	call   80100608 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
801028cb:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
801028d2:	8b 45 08             	mov    0x8(%ebp),%eax
801028d5:	8b 50 08             	mov    0x8(%eax),%edx
801028d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028db:	0f af c2             	imul   %edx,%eax
801028de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
801028e1:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801028e5:	75 07                	jne    801028ee <idestart+0x5a>
801028e7:	b8 20 00 00 00       	mov    $0x20,%eax
801028ec:	eb 05                	jmp    801028f3 <idestart+0x5f>
801028ee:	b8 c4 00 00 00       	mov    $0xc4,%eax
801028f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
801028f6:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801028fa:	75 07                	jne    80102903 <idestart+0x6f>
801028fc:	b8 30 00 00 00       	mov    $0x30,%eax
80102901:	eb 05                	jmp    80102908 <idestart+0x74>
80102903:	b8 c5 00 00 00       	mov    $0xc5,%eax
80102908:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
8010290b:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
8010290f:	7e 0d                	jle    8010291e <idestart+0x8a>
80102911:	83 ec 0c             	sub    $0xc,%esp
80102914:	68 43 94 10 80       	push   $0x80109443
80102919:	e8 ea dc ff ff       	call   80100608 <panic>

  idewait(0);
8010291e:	83 ec 0c             	sub    $0xc,%esp
80102921:	6a 00                	push   $0x0
80102923:	e8 7e fe ff ff       	call   801027a6 <idewait>
80102928:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
8010292b:	83 ec 08             	sub    $0x8,%esp
8010292e:	6a 00                	push   $0x0
80102930:	68 f6 03 00 00       	push   $0x3f6
80102935:	e8 25 fe ff ff       	call   8010275f <outb>
8010293a:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
8010293d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102940:	0f b6 c0             	movzbl %al,%eax
80102943:	83 ec 08             	sub    $0x8,%esp
80102946:	50                   	push   %eax
80102947:	68 f2 01 00 00       	push   $0x1f2
8010294c:	e8 0e fe ff ff       	call   8010275f <outb>
80102951:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102954:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102957:	0f b6 c0             	movzbl %al,%eax
8010295a:	83 ec 08             	sub    $0x8,%esp
8010295d:	50                   	push   %eax
8010295e:	68 f3 01 00 00       	push   $0x1f3
80102963:	e8 f7 fd ff ff       	call   8010275f <outb>
80102968:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
8010296b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010296e:	c1 f8 08             	sar    $0x8,%eax
80102971:	0f b6 c0             	movzbl %al,%eax
80102974:	83 ec 08             	sub    $0x8,%esp
80102977:	50                   	push   %eax
80102978:	68 f4 01 00 00       	push   $0x1f4
8010297d:	e8 dd fd ff ff       	call   8010275f <outb>
80102982:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
80102985:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102988:	c1 f8 10             	sar    $0x10,%eax
8010298b:	0f b6 c0             	movzbl %al,%eax
8010298e:	83 ec 08             	sub    $0x8,%esp
80102991:	50                   	push   %eax
80102992:	68 f5 01 00 00       	push   $0x1f5
80102997:	e8 c3 fd ff ff       	call   8010275f <outb>
8010299c:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
8010299f:	8b 45 08             	mov    0x8(%ebp),%eax
801029a2:	8b 40 04             	mov    0x4(%eax),%eax
801029a5:	c1 e0 04             	shl    $0x4,%eax
801029a8:	83 e0 10             	and    $0x10,%eax
801029ab:	89 c2                	mov    %eax,%edx
801029ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801029b0:	c1 f8 18             	sar    $0x18,%eax
801029b3:	83 e0 0f             	and    $0xf,%eax
801029b6:	09 d0                	or     %edx,%eax
801029b8:	83 c8 e0             	or     $0xffffffe0,%eax
801029bb:	0f b6 c0             	movzbl %al,%eax
801029be:	83 ec 08             	sub    $0x8,%esp
801029c1:	50                   	push   %eax
801029c2:	68 f6 01 00 00       	push   $0x1f6
801029c7:	e8 93 fd ff ff       	call   8010275f <outb>
801029cc:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
801029cf:	8b 45 08             	mov    0x8(%ebp),%eax
801029d2:	8b 00                	mov    (%eax),%eax
801029d4:	83 e0 04             	and    $0x4,%eax
801029d7:	85 c0                	test   %eax,%eax
801029d9:	74 35                	je     80102a10 <idestart+0x17c>
    outb(0x1f7, write_cmd);
801029db:	8b 45 e8             	mov    -0x18(%ebp),%eax
801029de:	0f b6 c0             	movzbl %al,%eax
801029e1:	83 ec 08             	sub    $0x8,%esp
801029e4:	50                   	push   %eax
801029e5:	68 f7 01 00 00       	push   $0x1f7
801029ea:	e8 70 fd ff ff       	call   8010275f <outb>
801029ef:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
801029f2:	8b 45 08             	mov    0x8(%ebp),%eax
801029f5:	83 c0 5c             	add    $0x5c,%eax
801029f8:	83 ec 04             	sub    $0x4,%esp
801029fb:	68 80 00 00 00       	push   $0x80
80102a00:	50                   	push   %eax
80102a01:	68 f0 01 00 00       	push   $0x1f0
80102a06:	e8 75 fd ff ff       	call   80102780 <outsl>
80102a0b:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
80102a0e:	eb 17                	jmp    80102a27 <idestart+0x193>
    outb(0x1f7, read_cmd);
80102a10:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102a13:	0f b6 c0             	movzbl %al,%eax
80102a16:	83 ec 08             	sub    $0x8,%esp
80102a19:	50                   	push   %eax
80102a1a:	68 f7 01 00 00       	push   $0x1f7
80102a1f:	e8 3b fd ff ff       	call   8010275f <outb>
80102a24:	83 c4 10             	add    $0x10,%esp
}
80102a27:	90                   	nop
80102a28:	c9                   	leave  
80102a29:	c3                   	ret    

80102a2a <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102a2a:	f3 0f 1e fb          	endbr32 
80102a2e:	55                   	push   %ebp
80102a2f:	89 e5                	mov    %esp,%ebp
80102a31:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102a34:	83 ec 0c             	sub    $0xc,%esp
80102a37:	68 00 c6 10 80       	push   $0x8010c600
80102a3c:	e8 5f 28 00 00       	call   801052a0 <acquire>
80102a41:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
80102a44:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102a49:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a4c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102a50:	75 15                	jne    80102a67 <ideintr+0x3d>
    release(&idelock);
80102a52:	83 ec 0c             	sub    $0xc,%esp
80102a55:	68 00 c6 10 80       	push   $0x8010c600
80102a5a:	e8 b3 28 00 00       	call   80105312 <release>
80102a5f:	83 c4 10             	add    $0x10,%esp
    return;
80102a62:	e9 9a 00 00 00       	jmp    80102b01 <ideintr+0xd7>
  }
  idequeue = b->qnext;
80102a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a6a:	8b 40 58             	mov    0x58(%eax),%eax
80102a6d:	a3 34 c6 10 80       	mov    %eax,0x8010c634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102a72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a75:	8b 00                	mov    (%eax),%eax
80102a77:	83 e0 04             	and    $0x4,%eax
80102a7a:	85 c0                	test   %eax,%eax
80102a7c:	75 2d                	jne    80102aab <ideintr+0x81>
80102a7e:	83 ec 0c             	sub    $0xc,%esp
80102a81:	6a 01                	push   $0x1
80102a83:	e8 1e fd ff ff       	call   801027a6 <idewait>
80102a88:	83 c4 10             	add    $0x10,%esp
80102a8b:	85 c0                	test   %eax,%eax
80102a8d:	78 1c                	js     80102aab <ideintr+0x81>
    insl(0x1f0, b->data, BSIZE/4);
80102a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a92:	83 c0 5c             	add    $0x5c,%eax
80102a95:	83 ec 04             	sub    $0x4,%esp
80102a98:	68 80 00 00 00       	push   $0x80
80102a9d:	50                   	push   %eax
80102a9e:	68 f0 01 00 00       	push   $0x1f0
80102aa3:	e8 91 fc ff ff       	call   80102739 <insl>
80102aa8:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aae:	8b 00                	mov    (%eax),%eax
80102ab0:	83 c8 02             	or     $0x2,%eax
80102ab3:	89 c2                	mov    %eax,%edx
80102ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab8:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102abd:	8b 00                	mov    (%eax),%eax
80102abf:	83 e0 fb             	and    $0xfffffffb,%eax
80102ac2:	89 c2                	mov    %eax,%edx
80102ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac7:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102ac9:	83 ec 0c             	sub    $0xc,%esp
80102acc:	ff 75 f4             	pushl  -0xc(%ebp)
80102acf:	e8 4c 24 00 00       	call   80104f20 <wakeup>
80102ad4:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102ad7:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102adc:	85 c0                	test   %eax,%eax
80102ade:	74 11                	je     80102af1 <ideintr+0xc7>
    idestart(idequeue);
80102ae0:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102ae5:	83 ec 0c             	sub    $0xc,%esp
80102ae8:	50                   	push   %eax
80102ae9:	e8 a6 fd ff ff       	call   80102894 <idestart>
80102aee:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102af1:	83 ec 0c             	sub    $0xc,%esp
80102af4:	68 00 c6 10 80       	push   $0x8010c600
80102af9:	e8 14 28 00 00       	call   80105312 <release>
80102afe:	83 c4 10             	add    $0x10,%esp
}
80102b01:	c9                   	leave  
80102b02:	c3                   	ret    

80102b03 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102b03:	f3 0f 1e fb          	endbr32 
80102b07:	55                   	push   %ebp
80102b08:	89 e5                	mov    %esp,%ebp
80102b0a:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102b0d:	8b 45 08             	mov    0x8(%ebp),%eax
80102b10:	83 c0 0c             	add    $0xc,%eax
80102b13:	83 ec 0c             	sub    $0xc,%esp
80102b16:	50                   	push   %eax
80102b17:	e8 c5 26 00 00       	call   801051e1 <holdingsleep>
80102b1c:	83 c4 10             	add    $0x10,%esp
80102b1f:	85 c0                	test   %eax,%eax
80102b21:	75 0d                	jne    80102b30 <iderw+0x2d>
    panic("iderw: buf not locked");
80102b23:	83 ec 0c             	sub    $0xc,%esp
80102b26:	68 5e 94 10 80       	push   $0x8010945e
80102b2b:	e8 d8 da ff ff       	call   80100608 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102b30:	8b 45 08             	mov    0x8(%ebp),%eax
80102b33:	8b 00                	mov    (%eax),%eax
80102b35:	83 e0 06             	and    $0x6,%eax
80102b38:	83 f8 02             	cmp    $0x2,%eax
80102b3b:	75 0d                	jne    80102b4a <iderw+0x47>
    panic("iderw: nothing to do");
80102b3d:	83 ec 0c             	sub    $0xc,%esp
80102b40:	68 74 94 10 80       	push   $0x80109474
80102b45:	e8 be da ff ff       	call   80100608 <panic>
  if(b->dev != 0 && !havedisk1)
80102b4a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b4d:	8b 40 04             	mov    0x4(%eax),%eax
80102b50:	85 c0                	test   %eax,%eax
80102b52:	74 16                	je     80102b6a <iderw+0x67>
80102b54:	a1 38 c6 10 80       	mov    0x8010c638,%eax
80102b59:	85 c0                	test   %eax,%eax
80102b5b:	75 0d                	jne    80102b6a <iderw+0x67>
    panic("iderw: ide disk 1 not present");
80102b5d:	83 ec 0c             	sub    $0xc,%esp
80102b60:	68 89 94 10 80       	push   $0x80109489
80102b65:	e8 9e da ff ff       	call   80100608 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102b6a:	83 ec 0c             	sub    $0xc,%esp
80102b6d:	68 00 c6 10 80       	push   $0x8010c600
80102b72:	e8 29 27 00 00       	call   801052a0 <acquire>
80102b77:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102b7a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b7d:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102b84:	c7 45 f4 34 c6 10 80 	movl   $0x8010c634,-0xc(%ebp)
80102b8b:	eb 0b                	jmp    80102b98 <iderw+0x95>
80102b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b90:	8b 00                	mov    (%eax),%eax
80102b92:	83 c0 58             	add    $0x58,%eax
80102b95:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b9b:	8b 00                	mov    (%eax),%eax
80102b9d:	85 c0                	test   %eax,%eax
80102b9f:	75 ec                	jne    80102b8d <iderw+0x8a>
    ;
  *pp = b;
80102ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ba4:	8b 55 08             	mov    0x8(%ebp),%edx
80102ba7:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102ba9:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102bae:	39 45 08             	cmp    %eax,0x8(%ebp)
80102bb1:	75 23                	jne    80102bd6 <iderw+0xd3>
    idestart(b);
80102bb3:	83 ec 0c             	sub    $0xc,%esp
80102bb6:	ff 75 08             	pushl  0x8(%ebp)
80102bb9:	e8 d6 fc ff ff       	call   80102894 <idestart>
80102bbe:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102bc1:	eb 13                	jmp    80102bd6 <iderw+0xd3>
    sleep(b, &idelock);
80102bc3:	83 ec 08             	sub    $0x8,%esp
80102bc6:	68 00 c6 10 80       	push   $0x8010c600
80102bcb:	ff 75 08             	pushl  0x8(%ebp)
80102bce:	e8 5b 22 00 00       	call   80104e2e <sleep>
80102bd3:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102bd6:	8b 45 08             	mov    0x8(%ebp),%eax
80102bd9:	8b 00                	mov    (%eax),%eax
80102bdb:	83 e0 06             	and    $0x6,%eax
80102bde:	83 f8 02             	cmp    $0x2,%eax
80102be1:	75 e0                	jne    80102bc3 <iderw+0xc0>
  }


  release(&idelock);
80102be3:	83 ec 0c             	sub    $0xc,%esp
80102be6:	68 00 c6 10 80       	push   $0x8010c600
80102beb:	e8 22 27 00 00       	call   80105312 <release>
80102bf0:	83 c4 10             	add    $0x10,%esp
}
80102bf3:	90                   	nop
80102bf4:	c9                   	leave  
80102bf5:	c3                   	ret    

80102bf6 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102bf6:	f3 0f 1e fb          	endbr32 
80102bfa:	55                   	push   %ebp
80102bfb:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102bfd:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102c02:	8b 55 08             	mov    0x8(%ebp),%edx
80102c05:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102c07:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102c0c:	8b 40 10             	mov    0x10(%eax),%eax
}
80102c0f:	5d                   	pop    %ebp
80102c10:	c3                   	ret    

80102c11 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102c11:	f3 0f 1e fb          	endbr32 
80102c15:	55                   	push   %ebp
80102c16:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102c18:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102c1d:	8b 55 08             	mov    0x8(%ebp),%edx
80102c20:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102c22:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102c27:	8b 55 0c             	mov    0xc(%ebp),%edx
80102c2a:	89 50 10             	mov    %edx,0x10(%eax)
}
80102c2d:	90                   	nop
80102c2e:	5d                   	pop    %ebp
80102c2f:	c3                   	ret    

80102c30 <ioapicinit>:

void
ioapicinit(void)
{
80102c30:	f3 0f 1e fb          	endbr32 
80102c34:	55                   	push   %ebp
80102c35:	89 e5                	mov    %esp,%ebp
80102c37:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102c3a:	c7 05 d4 46 11 80 00 	movl   $0xfec00000,0x801146d4
80102c41:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102c44:	6a 01                	push   $0x1
80102c46:	e8 ab ff ff ff       	call   80102bf6 <ioapicread>
80102c4b:	83 c4 04             	add    $0x4,%esp
80102c4e:	c1 e8 10             	shr    $0x10,%eax
80102c51:	25 ff 00 00 00       	and    $0xff,%eax
80102c56:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102c59:	6a 00                	push   $0x0
80102c5b:	e8 96 ff ff ff       	call   80102bf6 <ioapicread>
80102c60:	83 c4 04             	add    $0x4,%esp
80102c63:	c1 e8 18             	shr    $0x18,%eax
80102c66:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102c69:	0f b6 05 00 48 11 80 	movzbl 0x80114800,%eax
80102c70:	0f b6 c0             	movzbl %al,%eax
80102c73:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102c76:	74 10                	je     80102c88 <ioapicinit+0x58>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102c78:	83 ec 0c             	sub    $0xc,%esp
80102c7b:	68 a8 94 10 80       	push   $0x801094a8
80102c80:	e8 93 d7 ff ff       	call   80100418 <cprintf>
80102c85:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c88:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102c8f:	eb 3f                	jmp    80102cd0 <ioapicinit+0xa0>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102c91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c94:	83 c0 20             	add    $0x20,%eax
80102c97:	0d 00 00 01 00       	or     $0x10000,%eax
80102c9c:	89 c2                	mov    %eax,%edx
80102c9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ca1:	83 c0 08             	add    $0x8,%eax
80102ca4:	01 c0                	add    %eax,%eax
80102ca6:	83 ec 08             	sub    $0x8,%esp
80102ca9:	52                   	push   %edx
80102caa:	50                   	push   %eax
80102cab:	e8 61 ff ff ff       	call   80102c11 <ioapicwrite>
80102cb0:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cb6:	83 c0 08             	add    $0x8,%eax
80102cb9:	01 c0                	add    %eax,%eax
80102cbb:	83 c0 01             	add    $0x1,%eax
80102cbe:	83 ec 08             	sub    $0x8,%esp
80102cc1:	6a 00                	push   $0x0
80102cc3:	50                   	push   %eax
80102cc4:	e8 48 ff ff ff       	call   80102c11 <ioapicwrite>
80102cc9:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102ccc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102cd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cd3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102cd6:	7e b9                	jle    80102c91 <ioapicinit+0x61>
  }
}
80102cd8:	90                   	nop
80102cd9:	90                   	nop
80102cda:	c9                   	leave  
80102cdb:	c3                   	ret    

80102cdc <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102cdc:	f3 0f 1e fb          	endbr32 
80102ce0:	55                   	push   %ebp
80102ce1:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102ce3:	8b 45 08             	mov    0x8(%ebp),%eax
80102ce6:	83 c0 20             	add    $0x20,%eax
80102ce9:	89 c2                	mov    %eax,%edx
80102ceb:	8b 45 08             	mov    0x8(%ebp),%eax
80102cee:	83 c0 08             	add    $0x8,%eax
80102cf1:	01 c0                	add    %eax,%eax
80102cf3:	52                   	push   %edx
80102cf4:	50                   	push   %eax
80102cf5:	e8 17 ff ff ff       	call   80102c11 <ioapicwrite>
80102cfa:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102cfd:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d00:	c1 e0 18             	shl    $0x18,%eax
80102d03:	89 c2                	mov    %eax,%edx
80102d05:	8b 45 08             	mov    0x8(%ebp),%eax
80102d08:	83 c0 08             	add    $0x8,%eax
80102d0b:	01 c0                	add    %eax,%eax
80102d0d:	83 c0 01             	add    $0x1,%eax
80102d10:	52                   	push   %edx
80102d11:	50                   	push   %eax
80102d12:	e8 fa fe ff ff       	call   80102c11 <ioapicwrite>
80102d17:	83 c4 08             	add    $0x8,%esp
}
80102d1a:	90                   	nop
80102d1b:	c9                   	leave  
80102d1c:	c3                   	ret    

80102d1d <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102d1d:	f3 0f 1e fb          	endbr32 
80102d21:	55                   	push   %ebp
80102d22:	89 e5                	mov    %esp,%ebp
80102d24:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102d27:	83 ec 08             	sub    $0x8,%esp
80102d2a:	68 da 94 10 80       	push   $0x801094da
80102d2f:	68 e0 46 11 80       	push   $0x801146e0
80102d34:	e8 41 25 00 00       	call   8010527a <initlock>
80102d39:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102d3c:	c7 05 14 47 11 80 00 	movl   $0x0,0x80114714
80102d43:	00 00 00 
  freerange(vstart, vend);
80102d46:	83 ec 08             	sub    $0x8,%esp
80102d49:	ff 75 0c             	pushl  0xc(%ebp)
80102d4c:	ff 75 08             	pushl  0x8(%ebp)
80102d4f:	e8 2e 00 00 00       	call   80102d82 <freerange>
80102d54:	83 c4 10             	add    $0x10,%esp
}
80102d57:	90                   	nop
80102d58:	c9                   	leave  
80102d59:	c3                   	ret    

80102d5a <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102d5a:	f3 0f 1e fb          	endbr32 
80102d5e:	55                   	push   %ebp
80102d5f:	89 e5                	mov    %esp,%ebp
80102d61:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102d64:	83 ec 08             	sub    $0x8,%esp
80102d67:	ff 75 0c             	pushl  0xc(%ebp)
80102d6a:	ff 75 08             	pushl  0x8(%ebp)
80102d6d:	e8 10 00 00 00       	call   80102d82 <freerange>
80102d72:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102d75:	c7 05 14 47 11 80 01 	movl   $0x1,0x80114714
80102d7c:	00 00 00 
}
80102d7f:	90                   	nop
80102d80:	c9                   	leave  
80102d81:	c3                   	ret    

80102d82 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102d82:	f3 0f 1e fb          	endbr32 
80102d86:	55                   	push   %ebp
80102d87:	89 e5                	mov    %esp,%ebp
80102d89:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102d8c:	8b 45 08             	mov    0x8(%ebp),%eax
80102d8f:	05 ff 0f 00 00       	add    $0xfff,%eax
80102d94:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102d99:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d9c:	eb 15                	jmp    80102db3 <freerange+0x31>
    kfree(p);
80102d9e:	83 ec 0c             	sub    $0xc,%esp
80102da1:	ff 75 f4             	pushl  -0xc(%ebp)
80102da4:	e8 1b 00 00 00       	call   80102dc4 <kfree>
80102da9:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102dac:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102db3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102db6:	05 00 10 00 00       	add    $0x1000,%eax
80102dbb:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102dbe:	73 de                	jae    80102d9e <freerange+0x1c>
}
80102dc0:	90                   	nop
80102dc1:	90                   	nop
80102dc2:	c9                   	leave  
80102dc3:	c3                   	ret    

80102dc4 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102dc4:	f3 0f 1e fb          	endbr32 
80102dc8:	55                   	push   %ebp
80102dc9:	89 e5                	mov    %esp,%ebp
80102dcb:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102dce:	8b 45 08             	mov    0x8(%ebp),%eax
80102dd1:	25 ff 0f 00 00       	and    $0xfff,%eax
80102dd6:	85 c0                	test   %eax,%eax
80102dd8:	75 18                	jne    80102df2 <kfree+0x2e>
80102dda:	81 7d 08 48 7f 11 80 	cmpl   $0x80117f48,0x8(%ebp)
80102de1:	72 0f                	jb     80102df2 <kfree+0x2e>
80102de3:	8b 45 08             	mov    0x8(%ebp),%eax
80102de6:	05 00 00 00 80       	add    $0x80000000,%eax
80102deb:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102df0:	76 0d                	jbe    80102dff <kfree+0x3b>
    panic("kfree");
80102df2:	83 ec 0c             	sub    $0xc,%esp
80102df5:	68 df 94 10 80       	push   $0x801094df
80102dfa:	e8 09 d8 ff ff       	call   80100608 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102dff:	83 ec 04             	sub    $0x4,%esp
80102e02:	68 00 10 00 00       	push   $0x1000
80102e07:	6a 01                	push   $0x1
80102e09:	ff 75 08             	pushl  0x8(%ebp)
80102e0c:	e8 2e 27 00 00       	call   8010553f <memset>
80102e11:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102e14:	a1 14 47 11 80       	mov    0x80114714,%eax
80102e19:	85 c0                	test   %eax,%eax
80102e1b:	74 10                	je     80102e2d <kfree+0x69>
    acquire(&kmem.lock);
80102e1d:	83 ec 0c             	sub    $0xc,%esp
80102e20:	68 e0 46 11 80       	push   $0x801146e0
80102e25:	e8 76 24 00 00       	call   801052a0 <acquire>
80102e2a:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102e2d:	8b 45 08             	mov    0x8(%ebp),%eax
80102e30:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102e33:	8b 15 18 47 11 80    	mov    0x80114718,%edx
80102e39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e3c:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e41:	a3 18 47 11 80       	mov    %eax,0x80114718
  if(kmem.use_lock)
80102e46:	a1 14 47 11 80       	mov    0x80114714,%eax
80102e4b:	85 c0                	test   %eax,%eax
80102e4d:	74 10                	je     80102e5f <kfree+0x9b>
    release(&kmem.lock);
80102e4f:	83 ec 0c             	sub    $0xc,%esp
80102e52:	68 e0 46 11 80       	push   $0x801146e0
80102e57:	e8 b6 24 00 00       	call   80105312 <release>
80102e5c:	83 c4 10             	add    $0x10,%esp
}
80102e5f:	90                   	nop
80102e60:	c9                   	leave  
80102e61:	c3                   	ret    

80102e62 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102e62:	f3 0f 1e fb          	endbr32 
80102e66:	55                   	push   %ebp
80102e67:	89 e5                	mov    %esp,%ebp
80102e69:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102e6c:	a1 14 47 11 80       	mov    0x80114714,%eax
80102e71:	85 c0                	test   %eax,%eax
80102e73:	74 10                	je     80102e85 <kalloc+0x23>
    acquire(&kmem.lock);
80102e75:	83 ec 0c             	sub    $0xc,%esp
80102e78:	68 e0 46 11 80       	push   $0x801146e0
80102e7d:	e8 1e 24 00 00       	call   801052a0 <acquire>
80102e82:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102e85:	a1 18 47 11 80       	mov    0x80114718,%eax
80102e8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102e8d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102e91:	74 0a                	je     80102e9d <kalloc+0x3b>
    kmem.freelist = r->next;
80102e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e96:	8b 00                	mov    (%eax),%eax
80102e98:	a3 18 47 11 80       	mov    %eax,0x80114718
  if(kmem.use_lock)
80102e9d:	a1 14 47 11 80       	mov    0x80114714,%eax
80102ea2:	85 c0                	test   %eax,%eax
80102ea4:	74 10                	je     80102eb6 <kalloc+0x54>
    release(&kmem.lock);
80102ea6:	83 ec 0c             	sub    $0xc,%esp
80102ea9:	68 e0 46 11 80       	push   $0x801146e0
80102eae:	e8 5f 24 00 00       	call   80105312 <release>
80102eb3:	83 c4 10             	add    $0x10,%esp
  //printf("p4Debug : kalloc returns %d %x\n", PPN(V2P(r)), V2P(r));
  return (char*)r;
80102eb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102eb9:	c9                   	leave  
80102eba:	c3                   	ret    

80102ebb <inb>:
{
80102ebb:	55                   	push   %ebp
80102ebc:	89 e5                	mov    %esp,%ebp
80102ebe:	83 ec 14             	sub    $0x14,%esp
80102ec1:	8b 45 08             	mov    0x8(%ebp),%eax
80102ec4:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ec8:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102ecc:	89 c2                	mov    %eax,%edx
80102ece:	ec                   	in     (%dx),%al
80102ecf:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102ed2:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102ed6:	c9                   	leave  
80102ed7:	c3                   	ret    

80102ed8 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102ed8:	f3 0f 1e fb          	endbr32 
80102edc:	55                   	push   %ebp
80102edd:	89 e5                	mov    %esp,%ebp
80102edf:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102ee2:	6a 64                	push   $0x64
80102ee4:	e8 d2 ff ff ff       	call   80102ebb <inb>
80102ee9:	83 c4 04             	add    $0x4,%esp
80102eec:	0f b6 c0             	movzbl %al,%eax
80102eef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ef5:	83 e0 01             	and    $0x1,%eax
80102ef8:	85 c0                	test   %eax,%eax
80102efa:	75 0a                	jne    80102f06 <kbdgetc+0x2e>
    return -1;
80102efc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102f01:	e9 23 01 00 00       	jmp    80103029 <kbdgetc+0x151>
  data = inb(KBDATAP);
80102f06:	6a 60                	push   $0x60
80102f08:	e8 ae ff ff ff       	call   80102ebb <inb>
80102f0d:	83 c4 04             	add    $0x4,%esp
80102f10:	0f b6 c0             	movzbl %al,%eax
80102f13:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102f16:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102f1d:	75 17                	jne    80102f36 <kbdgetc+0x5e>
    shift |= E0ESC;
80102f1f:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f24:	83 c8 40             	or     $0x40,%eax
80102f27:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80102f2c:	b8 00 00 00 00       	mov    $0x0,%eax
80102f31:	e9 f3 00 00 00       	jmp    80103029 <kbdgetc+0x151>
  } else if(data & 0x80){
80102f36:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f39:	25 80 00 00 00       	and    $0x80,%eax
80102f3e:	85 c0                	test   %eax,%eax
80102f40:	74 45                	je     80102f87 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102f42:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f47:	83 e0 40             	and    $0x40,%eax
80102f4a:	85 c0                	test   %eax,%eax
80102f4c:	75 08                	jne    80102f56 <kbdgetc+0x7e>
80102f4e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f51:	83 e0 7f             	and    $0x7f,%eax
80102f54:	eb 03                	jmp    80102f59 <kbdgetc+0x81>
80102f56:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f59:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102f5c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f5f:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102f64:	0f b6 00             	movzbl (%eax),%eax
80102f67:	83 c8 40             	or     $0x40,%eax
80102f6a:	0f b6 c0             	movzbl %al,%eax
80102f6d:	f7 d0                	not    %eax
80102f6f:	89 c2                	mov    %eax,%edx
80102f71:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f76:	21 d0                	and    %edx,%eax
80102f78:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80102f7d:	b8 00 00 00 00       	mov    $0x0,%eax
80102f82:	e9 a2 00 00 00       	jmp    80103029 <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102f87:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f8c:	83 e0 40             	and    $0x40,%eax
80102f8f:	85 c0                	test   %eax,%eax
80102f91:	74 14                	je     80102fa7 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102f93:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102f9a:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f9f:	83 e0 bf             	and    $0xffffffbf,%eax
80102fa2:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  }

  shift |= shiftcode[data];
80102fa7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102faa:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102faf:	0f b6 00             	movzbl (%eax),%eax
80102fb2:	0f b6 d0             	movzbl %al,%edx
80102fb5:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102fba:	09 d0                	or     %edx,%eax
80102fbc:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  shift ^= togglecode[data];
80102fc1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102fc4:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102fc9:	0f b6 00             	movzbl (%eax),%eax
80102fcc:	0f b6 d0             	movzbl %al,%edx
80102fcf:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102fd4:	31 d0                	xor    %edx,%eax
80102fd6:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102fdb:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102fe0:	83 e0 03             	and    $0x3,%eax
80102fe3:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102fea:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102fed:	01 d0                	add    %edx,%eax
80102fef:	0f b6 00             	movzbl (%eax),%eax
80102ff2:	0f b6 c0             	movzbl %al,%eax
80102ff5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102ff8:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102ffd:	83 e0 08             	and    $0x8,%eax
80103000:	85 c0                	test   %eax,%eax
80103002:	74 22                	je     80103026 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80103004:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80103008:	76 0c                	jbe    80103016 <kbdgetc+0x13e>
8010300a:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
8010300e:	77 06                	ja     80103016 <kbdgetc+0x13e>
      c += 'A' - 'a';
80103010:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80103014:	eb 10                	jmp    80103026 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80103016:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
8010301a:	76 0a                	jbe    80103026 <kbdgetc+0x14e>
8010301c:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80103020:	77 04                	ja     80103026 <kbdgetc+0x14e>
      c += 'a' - 'A';
80103022:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80103026:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103029:	c9                   	leave  
8010302a:	c3                   	ret    

8010302b <kbdintr>:

void
kbdintr(void)
{
8010302b:	f3 0f 1e fb          	endbr32 
8010302f:	55                   	push   %ebp
80103030:	89 e5                	mov    %esp,%ebp
80103032:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80103035:	83 ec 0c             	sub    $0xc,%esp
80103038:	68 d8 2e 10 80       	push   $0x80102ed8
8010303d:	e8 66 d8 ff ff       	call   801008a8 <consoleintr>
80103042:	83 c4 10             	add    $0x10,%esp
}
80103045:	90                   	nop
80103046:	c9                   	leave  
80103047:	c3                   	ret    

80103048 <inb>:
{
80103048:	55                   	push   %ebp
80103049:	89 e5                	mov    %esp,%ebp
8010304b:	83 ec 14             	sub    $0x14,%esp
8010304e:	8b 45 08             	mov    0x8(%ebp),%eax
80103051:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103055:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103059:	89 c2                	mov    %eax,%edx
8010305b:	ec                   	in     (%dx),%al
8010305c:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010305f:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103063:	c9                   	leave  
80103064:	c3                   	ret    

80103065 <outb>:
{
80103065:	55                   	push   %ebp
80103066:	89 e5                	mov    %esp,%ebp
80103068:	83 ec 08             	sub    $0x8,%esp
8010306b:	8b 45 08             	mov    0x8(%ebp),%eax
8010306e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103071:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103075:	89 d0                	mov    %edx,%eax
80103077:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010307a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010307e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103082:	ee                   	out    %al,(%dx)
}
80103083:	90                   	nop
80103084:	c9                   	leave  
80103085:	c3                   	ret    

80103086 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80103086:	f3 0f 1e fb          	endbr32 
8010308a:	55                   	push   %ebp
8010308b:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
8010308d:	a1 1c 47 11 80       	mov    0x8011471c,%eax
80103092:	8b 55 08             	mov    0x8(%ebp),%edx
80103095:	c1 e2 02             	shl    $0x2,%edx
80103098:	01 c2                	add    %eax,%edx
8010309a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010309d:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
8010309f:	a1 1c 47 11 80       	mov    0x8011471c,%eax
801030a4:	83 c0 20             	add    $0x20,%eax
801030a7:	8b 00                	mov    (%eax),%eax
}
801030a9:	90                   	nop
801030aa:	5d                   	pop    %ebp
801030ab:	c3                   	ret    

801030ac <lapicinit>:

void
lapicinit(void)
{
801030ac:	f3 0f 1e fb          	endbr32 
801030b0:	55                   	push   %ebp
801030b1:	89 e5                	mov    %esp,%ebp
  if(!lapic)
801030b3:	a1 1c 47 11 80       	mov    0x8011471c,%eax
801030b8:	85 c0                	test   %eax,%eax
801030ba:	0f 84 0c 01 00 00    	je     801031cc <lapicinit+0x120>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801030c0:	68 3f 01 00 00       	push   $0x13f
801030c5:	6a 3c                	push   $0x3c
801030c7:	e8 ba ff ff ff       	call   80103086 <lapicw>
801030cc:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801030cf:	6a 0b                	push   $0xb
801030d1:	68 f8 00 00 00       	push   $0xf8
801030d6:	e8 ab ff ff ff       	call   80103086 <lapicw>
801030db:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801030de:	68 20 00 02 00       	push   $0x20020
801030e3:	68 c8 00 00 00       	push   $0xc8
801030e8:	e8 99 ff ff ff       	call   80103086 <lapicw>
801030ed:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
801030f0:	68 80 96 98 00       	push   $0x989680
801030f5:	68 e0 00 00 00       	push   $0xe0
801030fa:	e8 87 ff ff ff       	call   80103086 <lapicw>
801030ff:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80103102:	68 00 00 01 00       	push   $0x10000
80103107:	68 d4 00 00 00       	push   $0xd4
8010310c:	e8 75 ff ff ff       	call   80103086 <lapicw>
80103111:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80103114:	68 00 00 01 00       	push   $0x10000
80103119:	68 d8 00 00 00       	push   $0xd8
8010311e:	e8 63 ff ff ff       	call   80103086 <lapicw>
80103123:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80103126:	a1 1c 47 11 80       	mov    0x8011471c,%eax
8010312b:	83 c0 30             	add    $0x30,%eax
8010312e:	8b 00                	mov    (%eax),%eax
80103130:	c1 e8 10             	shr    $0x10,%eax
80103133:	25 fc 00 00 00       	and    $0xfc,%eax
80103138:	85 c0                	test   %eax,%eax
8010313a:	74 12                	je     8010314e <lapicinit+0xa2>
    lapicw(PCINT, MASKED);
8010313c:	68 00 00 01 00       	push   $0x10000
80103141:	68 d0 00 00 00       	push   $0xd0
80103146:	e8 3b ff ff ff       	call   80103086 <lapicw>
8010314b:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
8010314e:	6a 33                	push   $0x33
80103150:	68 dc 00 00 00       	push   $0xdc
80103155:	e8 2c ff ff ff       	call   80103086 <lapicw>
8010315a:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
8010315d:	6a 00                	push   $0x0
8010315f:	68 a0 00 00 00       	push   $0xa0
80103164:	e8 1d ff ff ff       	call   80103086 <lapicw>
80103169:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
8010316c:	6a 00                	push   $0x0
8010316e:	68 a0 00 00 00       	push   $0xa0
80103173:	e8 0e ff ff ff       	call   80103086 <lapicw>
80103178:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
8010317b:	6a 00                	push   $0x0
8010317d:	6a 2c                	push   $0x2c
8010317f:	e8 02 ff ff ff       	call   80103086 <lapicw>
80103184:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103187:	6a 00                	push   $0x0
80103189:	68 c4 00 00 00       	push   $0xc4
8010318e:	e8 f3 fe ff ff       	call   80103086 <lapicw>
80103193:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103196:	68 00 85 08 00       	push   $0x88500
8010319b:	68 c0 00 00 00       	push   $0xc0
801031a0:	e8 e1 fe ff ff       	call   80103086 <lapicw>
801031a5:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
801031a8:	90                   	nop
801031a9:	a1 1c 47 11 80       	mov    0x8011471c,%eax
801031ae:	05 00 03 00 00       	add    $0x300,%eax
801031b3:	8b 00                	mov    (%eax),%eax
801031b5:	25 00 10 00 00       	and    $0x1000,%eax
801031ba:	85 c0                	test   %eax,%eax
801031bc:	75 eb                	jne    801031a9 <lapicinit+0xfd>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801031be:	6a 00                	push   $0x0
801031c0:	6a 20                	push   $0x20
801031c2:	e8 bf fe ff ff       	call   80103086 <lapicw>
801031c7:	83 c4 08             	add    $0x8,%esp
801031ca:	eb 01                	jmp    801031cd <lapicinit+0x121>
    return;
801031cc:	90                   	nop
}
801031cd:	c9                   	leave  
801031ce:	c3                   	ret    

801031cf <lapicid>:

int
lapicid(void)
{
801031cf:	f3 0f 1e fb          	endbr32 
801031d3:	55                   	push   %ebp
801031d4:	89 e5                	mov    %esp,%ebp
  if (!lapic)
801031d6:	a1 1c 47 11 80       	mov    0x8011471c,%eax
801031db:	85 c0                	test   %eax,%eax
801031dd:	75 07                	jne    801031e6 <lapicid+0x17>
    return 0;
801031df:	b8 00 00 00 00       	mov    $0x0,%eax
801031e4:	eb 0d                	jmp    801031f3 <lapicid+0x24>
  return lapic[ID] >> 24;
801031e6:	a1 1c 47 11 80       	mov    0x8011471c,%eax
801031eb:	83 c0 20             	add    $0x20,%eax
801031ee:	8b 00                	mov    (%eax),%eax
801031f0:	c1 e8 18             	shr    $0x18,%eax
}
801031f3:	5d                   	pop    %ebp
801031f4:	c3                   	ret    

801031f5 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801031f5:	f3 0f 1e fb          	endbr32 
801031f9:	55                   	push   %ebp
801031fa:	89 e5                	mov    %esp,%ebp
  if(lapic)
801031fc:	a1 1c 47 11 80       	mov    0x8011471c,%eax
80103201:	85 c0                	test   %eax,%eax
80103203:	74 0c                	je     80103211 <lapiceoi+0x1c>
    lapicw(EOI, 0);
80103205:	6a 00                	push   $0x0
80103207:	6a 2c                	push   $0x2c
80103209:	e8 78 fe ff ff       	call   80103086 <lapicw>
8010320e:	83 c4 08             	add    $0x8,%esp
}
80103211:	90                   	nop
80103212:	c9                   	leave  
80103213:	c3                   	ret    

80103214 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103214:	f3 0f 1e fb          	endbr32 
80103218:	55                   	push   %ebp
80103219:	89 e5                	mov    %esp,%ebp
}
8010321b:	90                   	nop
8010321c:	5d                   	pop    %ebp
8010321d:	c3                   	ret    

8010321e <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
8010321e:	f3 0f 1e fb          	endbr32 
80103222:	55                   	push   %ebp
80103223:	89 e5                	mov    %esp,%ebp
80103225:	83 ec 14             	sub    $0x14,%esp
80103228:	8b 45 08             	mov    0x8(%ebp),%eax
8010322b:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
8010322e:	6a 0f                	push   $0xf
80103230:	6a 70                	push   $0x70
80103232:	e8 2e fe ff ff       	call   80103065 <outb>
80103237:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
8010323a:	6a 0a                	push   $0xa
8010323c:	6a 71                	push   $0x71
8010323e:	e8 22 fe ff ff       	call   80103065 <outb>
80103243:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103246:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010324d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103250:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103255:	8b 45 0c             	mov    0xc(%ebp),%eax
80103258:	c1 e8 04             	shr    $0x4,%eax
8010325b:	89 c2                	mov    %eax,%edx
8010325d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103260:	83 c0 02             	add    $0x2,%eax
80103263:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103266:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010326a:	c1 e0 18             	shl    $0x18,%eax
8010326d:	50                   	push   %eax
8010326e:	68 c4 00 00 00       	push   $0xc4
80103273:	e8 0e fe ff ff       	call   80103086 <lapicw>
80103278:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010327b:	68 00 c5 00 00       	push   $0xc500
80103280:	68 c0 00 00 00       	push   $0xc0
80103285:	e8 fc fd ff ff       	call   80103086 <lapicw>
8010328a:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010328d:	68 c8 00 00 00       	push   $0xc8
80103292:	e8 7d ff ff ff       	call   80103214 <microdelay>
80103297:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
8010329a:	68 00 85 00 00       	push   $0x8500
8010329f:	68 c0 00 00 00       	push   $0xc0
801032a4:	e8 dd fd ff ff       	call   80103086 <lapicw>
801032a9:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801032ac:	6a 64                	push   $0x64
801032ae:	e8 61 ff ff ff       	call   80103214 <microdelay>
801032b3:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801032b6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801032bd:	eb 3d                	jmp    801032fc <lapicstartap+0xde>
    lapicw(ICRHI, apicid<<24);
801032bf:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801032c3:	c1 e0 18             	shl    $0x18,%eax
801032c6:	50                   	push   %eax
801032c7:	68 c4 00 00 00       	push   $0xc4
801032cc:	e8 b5 fd ff ff       	call   80103086 <lapicw>
801032d1:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801032d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801032d7:	c1 e8 0c             	shr    $0xc,%eax
801032da:	80 cc 06             	or     $0x6,%ah
801032dd:	50                   	push   %eax
801032de:	68 c0 00 00 00       	push   $0xc0
801032e3:	e8 9e fd ff ff       	call   80103086 <lapicw>
801032e8:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
801032eb:	68 c8 00 00 00       	push   $0xc8
801032f0:	e8 1f ff ff ff       	call   80103214 <microdelay>
801032f5:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
801032f8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801032fc:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103300:	7e bd                	jle    801032bf <lapicstartap+0xa1>
  }
}
80103302:	90                   	nop
80103303:	90                   	nop
80103304:	c9                   	leave  
80103305:	c3                   	ret    

80103306 <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
80103306:	f3 0f 1e fb          	endbr32 
8010330a:	55                   	push   %ebp
8010330b:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
8010330d:	8b 45 08             	mov    0x8(%ebp),%eax
80103310:	0f b6 c0             	movzbl %al,%eax
80103313:	50                   	push   %eax
80103314:	6a 70                	push   $0x70
80103316:	e8 4a fd ff ff       	call   80103065 <outb>
8010331b:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010331e:	68 c8 00 00 00       	push   $0xc8
80103323:	e8 ec fe ff ff       	call   80103214 <microdelay>
80103328:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
8010332b:	6a 71                	push   $0x71
8010332d:	e8 16 fd ff ff       	call   80103048 <inb>
80103332:	83 c4 04             	add    $0x4,%esp
80103335:	0f b6 c0             	movzbl %al,%eax
}
80103338:	c9                   	leave  
80103339:	c3                   	ret    

8010333a <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
8010333a:	f3 0f 1e fb          	endbr32 
8010333e:	55                   	push   %ebp
8010333f:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103341:	6a 00                	push   $0x0
80103343:	e8 be ff ff ff       	call   80103306 <cmos_read>
80103348:	83 c4 04             	add    $0x4,%esp
8010334b:	8b 55 08             	mov    0x8(%ebp),%edx
8010334e:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103350:	6a 02                	push   $0x2
80103352:	e8 af ff ff ff       	call   80103306 <cmos_read>
80103357:	83 c4 04             	add    $0x4,%esp
8010335a:	8b 55 08             	mov    0x8(%ebp),%edx
8010335d:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103360:	6a 04                	push   $0x4
80103362:	e8 9f ff ff ff       	call   80103306 <cmos_read>
80103367:	83 c4 04             	add    $0x4,%esp
8010336a:	8b 55 08             	mov    0x8(%ebp),%edx
8010336d:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103370:	6a 07                	push   $0x7
80103372:	e8 8f ff ff ff       	call   80103306 <cmos_read>
80103377:	83 c4 04             	add    $0x4,%esp
8010337a:	8b 55 08             	mov    0x8(%ebp),%edx
8010337d:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103380:	6a 08                	push   $0x8
80103382:	e8 7f ff ff ff       	call   80103306 <cmos_read>
80103387:	83 c4 04             	add    $0x4,%esp
8010338a:	8b 55 08             	mov    0x8(%ebp),%edx
8010338d:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103390:	6a 09                	push   $0x9
80103392:	e8 6f ff ff ff       	call   80103306 <cmos_read>
80103397:	83 c4 04             	add    $0x4,%esp
8010339a:	8b 55 08             	mov    0x8(%ebp),%edx
8010339d:	89 42 14             	mov    %eax,0x14(%edx)
}
801033a0:	90                   	nop
801033a1:	c9                   	leave  
801033a2:	c3                   	ret    

801033a3 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
801033a3:	f3 0f 1e fb          	endbr32 
801033a7:	55                   	push   %ebp
801033a8:	89 e5                	mov    %esp,%ebp
801033aa:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801033ad:	6a 0b                	push   $0xb
801033af:	e8 52 ff ff ff       	call   80103306 <cmos_read>
801033b4:	83 c4 04             	add    $0x4,%esp
801033b7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801033ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033bd:	83 e0 04             	and    $0x4,%eax
801033c0:	85 c0                	test   %eax,%eax
801033c2:	0f 94 c0             	sete   %al
801033c5:	0f b6 c0             	movzbl %al,%eax
801033c8:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801033cb:	8d 45 d8             	lea    -0x28(%ebp),%eax
801033ce:	50                   	push   %eax
801033cf:	e8 66 ff ff ff       	call   8010333a <fill_rtcdate>
801033d4:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801033d7:	6a 0a                	push   $0xa
801033d9:	e8 28 ff ff ff       	call   80103306 <cmos_read>
801033de:	83 c4 04             	add    $0x4,%esp
801033e1:	25 80 00 00 00       	and    $0x80,%eax
801033e6:	85 c0                	test   %eax,%eax
801033e8:	75 27                	jne    80103411 <cmostime+0x6e>
        continue;
    fill_rtcdate(&t2);
801033ea:	8d 45 c0             	lea    -0x40(%ebp),%eax
801033ed:	50                   	push   %eax
801033ee:	e8 47 ff ff ff       	call   8010333a <fill_rtcdate>
801033f3:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801033f6:	83 ec 04             	sub    $0x4,%esp
801033f9:	6a 18                	push   $0x18
801033fb:	8d 45 c0             	lea    -0x40(%ebp),%eax
801033fe:	50                   	push   %eax
801033ff:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103402:	50                   	push   %eax
80103403:	e8 a2 21 00 00       	call   801055aa <memcmp>
80103408:	83 c4 10             	add    $0x10,%esp
8010340b:	85 c0                	test   %eax,%eax
8010340d:	74 05                	je     80103414 <cmostime+0x71>
8010340f:	eb ba                	jmp    801033cb <cmostime+0x28>
        continue;
80103411:	90                   	nop
    fill_rtcdate(&t1);
80103412:	eb b7                	jmp    801033cb <cmostime+0x28>
      break;
80103414:	90                   	nop
  }

  // convert
  if(bcd) {
80103415:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103419:	0f 84 b4 00 00 00    	je     801034d3 <cmostime+0x130>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
8010341f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103422:	c1 e8 04             	shr    $0x4,%eax
80103425:	89 c2                	mov    %eax,%edx
80103427:	89 d0                	mov    %edx,%eax
80103429:	c1 e0 02             	shl    $0x2,%eax
8010342c:	01 d0                	add    %edx,%eax
8010342e:	01 c0                	add    %eax,%eax
80103430:	89 c2                	mov    %eax,%edx
80103432:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103435:	83 e0 0f             	and    $0xf,%eax
80103438:	01 d0                	add    %edx,%eax
8010343a:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
8010343d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103440:	c1 e8 04             	shr    $0x4,%eax
80103443:	89 c2                	mov    %eax,%edx
80103445:	89 d0                	mov    %edx,%eax
80103447:	c1 e0 02             	shl    $0x2,%eax
8010344a:	01 d0                	add    %edx,%eax
8010344c:	01 c0                	add    %eax,%eax
8010344e:	89 c2                	mov    %eax,%edx
80103450:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103453:	83 e0 0f             	and    $0xf,%eax
80103456:	01 d0                	add    %edx,%eax
80103458:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010345b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010345e:	c1 e8 04             	shr    $0x4,%eax
80103461:	89 c2                	mov    %eax,%edx
80103463:	89 d0                	mov    %edx,%eax
80103465:	c1 e0 02             	shl    $0x2,%eax
80103468:	01 d0                	add    %edx,%eax
8010346a:	01 c0                	add    %eax,%eax
8010346c:	89 c2                	mov    %eax,%edx
8010346e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103471:	83 e0 0f             	and    $0xf,%eax
80103474:	01 d0                	add    %edx,%eax
80103476:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103479:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010347c:	c1 e8 04             	shr    $0x4,%eax
8010347f:	89 c2                	mov    %eax,%edx
80103481:	89 d0                	mov    %edx,%eax
80103483:	c1 e0 02             	shl    $0x2,%eax
80103486:	01 d0                	add    %edx,%eax
80103488:	01 c0                	add    %eax,%eax
8010348a:	89 c2                	mov    %eax,%edx
8010348c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010348f:	83 e0 0f             	and    $0xf,%eax
80103492:	01 d0                	add    %edx,%eax
80103494:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103497:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010349a:	c1 e8 04             	shr    $0x4,%eax
8010349d:	89 c2                	mov    %eax,%edx
8010349f:	89 d0                	mov    %edx,%eax
801034a1:	c1 e0 02             	shl    $0x2,%eax
801034a4:	01 d0                	add    %edx,%eax
801034a6:	01 c0                	add    %eax,%eax
801034a8:	89 c2                	mov    %eax,%edx
801034aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
801034ad:	83 e0 0f             	and    $0xf,%eax
801034b0:	01 d0                	add    %edx,%eax
801034b2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801034b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034b8:	c1 e8 04             	shr    $0x4,%eax
801034bb:	89 c2                	mov    %eax,%edx
801034bd:	89 d0                	mov    %edx,%eax
801034bf:	c1 e0 02             	shl    $0x2,%eax
801034c2:	01 d0                	add    %edx,%eax
801034c4:	01 c0                	add    %eax,%eax
801034c6:	89 c2                	mov    %eax,%edx
801034c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034cb:	83 e0 0f             	and    $0xf,%eax
801034ce:	01 d0                	add    %edx,%eax
801034d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801034d3:	8b 45 08             	mov    0x8(%ebp),%eax
801034d6:	8b 55 d8             	mov    -0x28(%ebp),%edx
801034d9:	89 10                	mov    %edx,(%eax)
801034db:	8b 55 dc             	mov    -0x24(%ebp),%edx
801034de:	89 50 04             	mov    %edx,0x4(%eax)
801034e1:	8b 55 e0             	mov    -0x20(%ebp),%edx
801034e4:	89 50 08             	mov    %edx,0x8(%eax)
801034e7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801034ea:	89 50 0c             	mov    %edx,0xc(%eax)
801034ed:	8b 55 e8             	mov    -0x18(%ebp),%edx
801034f0:	89 50 10             	mov    %edx,0x10(%eax)
801034f3:	8b 55 ec             	mov    -0x14(%ebp),%edx
801034f6:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801034f9:	8b 45 08             	mov    0x8(%ebp),%eax
801034fc:	8b 40 14             	mov    0x14(%eax),%eax
801034ff:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103505:	8b 45 08             	mov    0x8(%ebp),%eax
80103508:	89 50 14             	mov    %edx,0x14(%eax)
}
8010350b:	90                   	nop
8010350c:	c9                   	leave  
8010350d:	c3                   	ret    

8010350e <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
8010350e:	f3 0f 1e fb          	endbr32 
80103512:	55                   	push   %ebp
80103513:	89 e5                	mov    %esp,%ebp
80103515:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103518:	83 ec 08             	sub    $0x8,%esp
8010351b:	68 e5 94 10 80       	push   $0x801094e5
80103520:	68 20 47 11 80       	push   $0x80114720
80103525:	e8 50 1d 00 00       	call   8010527a <initlock>
8010352a:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010352d:	83 ec 08             	sub    $0x8,%esp
80103530:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103533:	50                   	push   %eax
80103534:	ff 75 08             	pushl  0x8(%ebp)
80103537:	e8 f9 df ff ff       	call   80101535 <readsb>
8010353c:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
8010353f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103542:	a3 54 47 11 80       	mov    %eax,0x80114754
  log.size = sb.nlog;
80103547:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010354a:	a3 58 47 11 80       	mov    %eax,0x80114758
  log.dev = dev;
8010354f:	8b 45 08             	mov    0x8(%ebp),%eax
80103552:	a3 64 47 11 80       	mov    %eax,0x80114764
  recover_from_log();
80103557:	e8 bf 01 00 00       	call   8010371b <recover_from_log>
}
8010355c:	90                   	nop
8010355d:	c9                   	leave  
8010355e:	c3                   	ret    

8010355f <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
8010355f:	f3 0f 1e fb          	endbr32 
80103563:	55                   	push   %ebp
80103564:	89 e5                	mov    %esp,%ebp
80103566:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103569:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103570:	e9 95 00 00 00       	jmp    8010360a <install_trans+0xab>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103575:	8b 15 54 47 11 80    	mov    0x80114754,%edx
8010357b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010357e:	01 d0                	add    %edx,%eax
80103580:	83 c0 01             	add    $0x1,%eax
80103583:	89 c2                	mov    %eax,%edx
80103585:	a1 64 47 11 80       	mov    0x80114764,%eax
8010358a:	83 ec 08             	sub    $0x8,%esp
8010358d:	52                   	push   %edx
8010358e:	50                   	push   %eax
8010358f:	e8 43 cc ff ff       	call   801001d7 <bread>
80103594:	83 c4 10             	add    $0x10,%esp
80103597:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
8010359a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010359d:	83 c0 10             	add    $0x10,%eax
801035a0:	8b 04 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%eax
801035a7:	89 c2                	mov    %eax,%edx
801035a9:	a1 64 47 11 80       	mov    0x80114764,%eax
801035ae:	83 ec 08             	sub    $0x8,%esp
801035b1:	52                   	push   %edx
801035b2:	50                   	push   %eax
801035b3:	e8 1f cc ff ff       	call   801001d7 <bread>
801035b8:	83 c4 10             	add    $0x10,%esp
801035bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801035be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035c1:	8d 50 5c             	lea    0x5c(%eax),%edx
801035c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035c7:	83 c0 5c             	add    $0x5c,%eax
801035ca:	83 ec 04             	sub    $0x4,%esp
801035cd:	68 00 02 00 00       	push   $0x200
801035d2:	52                   	push   %edx
801035d3:	50                   	push   %eax
801035d4:	e8 2d 20 00 00       	call   80105606 <memmove>
801035d9:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
801035dc:	83 ec 0c             	sub    $0xc,%esp
801035df:	ff 75 ec             	pushl  -0x14(%ebp)
801035e2:	e8 2d cc ff ff       	call   80100214 <bwrite>
801035e7:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
801035ea:	83 ec 0c             	sub    $0xc,%esp
801035ed:	ff 75 f0             	pushl  -0x10(%ebp)
801035f0:	e8 6c cc ff ff       	call   80100261 <brelse>
801035f5:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
801035f8:	83 ec 0c             	sub    $0xc,%esp
801035fb:	ff 75 ec             	pushl  -0x14(%ebp)
801035fe:	e8 5e cc ff ff       	call   80100261 <brelse>
80103603:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103606:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010360a:	a1 68 47 11 80       	mov    0x80114768,%eax
8010360f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103612:	0f 8c 5d ff ff ff    	jl     80103575 <install_trans+0x16>
  }
}
80103618:	90                   	nop
80103619:	90                   	nop
8010361a:	c9                   	leave  
8010361b:	c3                   	ret    

8010361c <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010361c:	f3 0f 1e fb          	endbr32 
80103620:	55                   	push   %ebp
80103621:	89 e5                	mov    %esp,%ebp
80103623:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103626:	a1 54 47 11 80       	mov    0x80114754,%eax
8010362b:	89 c2                	mov    %eax,%edx
8010362d:	a1 64 47 11 80       	mov    0x80114764,%eax
80103632:	83 ec 08             	sub    $0x8,%esp
80103635:	52                   	push   %edx
80103636:	50                   	push   %eax
80103637:	e8 9b cb ff ff       	call   801001d7 <bread>
8010363c:	83 c4 10             	add    $0x10,%esp
8010363f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103642:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103645:	83 c0 5c             	add    $0x5c,%eax
80103648:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010364b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010364e:	8b 00                	mov    (%eax),%eax
80103650:	a3 68 47 11 80       	mov    %eax,0x80114768
  for (i = 0; i < log.lh.n; i++) {
80103655:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010365c:	eb 1b                	jmp    80103679 <read_head+0x5d>
    log.lh.block[i] = lh->block[i];
8010365e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103661:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103664:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103668:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010366b:	83 c2 10             	add    $0x10,%edx
8010366e:	89 04 95 2c 47 11 80 	mov    %eax,-0x7feeb8d4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103675:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103679:	a1 68 47 11 80       	mov    0x80114768,%eax
8010367e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103681:	7c db                	jl     8010365e <read_head+0x42>
  }
  brelse(buf);
80103683:	83 ec 0c             	sub    $0xc,%esp
80103686:	ff 75 f0             	pushl  -0x10(%ebp)
80103689:	e8 d3 cb ff ff       	call   80100261 <brelse>
8010368e:	83 c4 10             	add    $0x10,%esp
}
80103691:	90                   	nop
80103692:	c9                   	leave  
80103693:	c3                   	ret    

80103694 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103694:	f3 0f 1e fb          	endbr32 
80103698:	55                   	push   %ebp
80103699:	89 e5                	mov    %esp,%ebp
8010369b:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010369e:	a1 54 47 11 80       	mov    0x80114754,%eax
801036a3:	89 c2                	mov    %eax,%edx
801036a5:	a1 64 47 11 80       	mov    0x80114764,%eax
801036aa:	83 ec 08             	sub    $0x8,%esp
801036ad:	52                   	push   %edx
801036ae:	50                   	push   %eax
801036af:	e8 23 cb ff ff       	call   801001d7 <bread>
801036b4:	83 c4 10             	add    $0x10,%esp
801036b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801036ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036bd:	83 c0 5c             	add    $0x5c,%eax
801036c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801036c3:	8b 15 68 47 11 80    	mov    0x80114768,%edx
801036c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036cc:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801036ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036d5:	eb 1b                	jmp    801036f2 <write_head+0x5e>
    hb->block[i] = log.lh.block[i];
801036d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036da:	83 c0 10             	add    $0x10,%eax
801036dd:	8b 0c 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%ecx
801036e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801036ea:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801036ee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801036f2:	a1 68 47 11 80       	mov    0x80114768,%eax
801036f7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801036fa:	7c db                	jl     801036d7 <write_head+0x43>
  }
  bwrite(buf);
801036fc:	83 ec 0c             	sub    $0xc,%esp
801036ff:	ff 75 f0             	pushl  -0x10(%ebp)
80103702:	e8 0d cb ff ff       	call   80100214 <bwrite>
80103707:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
8010370a:	83 ec 0c             	sub    $0xc,%esp
8010370d:	ff 75 f0             	pushl  -0x10(%ebp)
80103710:	e8 4c cb ff ff       	call   80100261 <brelse>
80103715:	83 c4 10             	add    $0x10,%esp
}
80103718:	90                   	nop
80103719:	c9                   	leave  
8010371a:	c3                   	ret    

8010371b <recover_from_log>:

static void
recover_from_log(void)
{
8010371b:	f3 0f 1e fb          	endbr32 
8010371f:	55                   	push   %ebp
80103720:	89 e5                	mov    %esp,%ebp
80103722:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103725:	e8 f2 fe ff ff       	call   8010361c <read_head>
  install_trans(); // if committed, copy from log to disk
8010372a:	e8 30 fe ff ff       	call   8010355f <install_trans>
  log.lh.n = 0;
8010372f:	c7 05 68 47 11 80 00 	movl   $0x0,0x80114768
80103736:	00 00 00 
  write_head(); // clear the log
80103739:	e8 56 ff ff ff       	call   80103694 <write_head>
}
8010373e:	90                   	nop
8010373f:	c9                   	leave  
80103740:	c3                   	ret    

80103741 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103741:	f3 0f 1e fb          	endbr32 
80103745:	55                   	push   %ebp
80103746:	89 e5                	mov    %esp,%ebp
80103748:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
8010374b:	83 ec 0c             	sub    $0xc,%esp
8010374e:	68 20 47 11 80       	push   $0x80114720
80103753:	e8 48 1b 00 00       	call   801052a0 <acquire>
80103758:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
8010375b:	a1 60 47 11 80       	mov    0x80114760,%eax
80103760:	85 c0                	test   %eax,%eax
80103762:	74 17                	je     8010377b <begin_op+0x3a>
      sleep(&log, &log.lock);
80103764:	83 ec 08             	sub    $0x8,%esp
80103767:	68 20 47 11 80       	push   $0x80114720
8010376c:	68 20 47 11 80       	push   $0x80114720
80103771:	e8 b8 16 00 00       	call   80104e2e <sleep>
80103776:	83 c4 10             	add    $0x10,%esp
80103779:	eb e0                	jmp    8010375b <begin_op+0x1a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010377b:	8b 0d 68 47 11 80    	mov    0x80114768,%ecx
80103781:	a1 5c 47 11 80       	mov    0x8011475c,%eax
80103786:	8d 50 01             	lea    0x1(%eax),%edx
80103789:	89 d0                	mov    %edx,%eax
8010378b:	c1 e0 02             	shl    $0x2,%eax
8010378e:	01 d0                	add    %edx,%eax
80103790:	01 c0                	add    %eax,%eax
80103792:	01 c8                	add    %ecx,%eax
80103794:	83 f8 1e             	cmp    $0x1e,%eax
80103797:	7e 17                	jle    801037b0 <begin_op+0x6f>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103799:	83 ec 08             	sub    $0x8,%esp
8010379c:	68 20 47 11 80       	push   $0x80114720
801037a1:	68 20 47 11 80       	push   $0x80114720
801037a6:	e8 83 16 00 00       	call   80104e2e <sleep>
801037ab:	83 c4 10             	add    $0x10,%esp
801037ae:	eb ab                	jmp    8010375b <begin_op+0x1a>
    } else {
      log.outstanding += 1;
801037b0:	a1 5c 47 11 80       	mov    0x8011475c,%eax
801037b5:	83 c0 01             	add    $0x1,%eax
801037b8:	a3 5c 47 11 80       	mov    %eax,0x8011475c
      release(&log.lock);
801037bd:	83 ec 0c             	sub    $0xc,%esp
801037c0:	68 20 47 11 80       	push   $0x80114720
801037c5:	e8 48 1b 00 00       	call   80105312 <release>
801037ca:	83 c4 10             	add    $0x10,%esp
      break;
801037cd:	90                   	nop
    }
  }
}
801037ce:	90                   	nop
801037cf:	c9                   	leave  
801037d0:	c3                   	ret    

801037d1 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801037d1:	f3 0f 1e fb          	endbr32 
801037d5:	55                   	push   %ebp
801037d6:	89 e5                	mov    %esp,%ebp
801037d8:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801037db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801037e2:	83 ec 0c             	sub    $0xc,%esp
801037e5:	68 20 47 11 80       	push   $0x80114720
801037ea:	e8 b1 1a 00 00       	call   801052a0 <acquire>
801037ef:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801037f2:	a1 5c 47 11 80       	mov    0x8011475c,%eax
801037f7:	83 e8 01             	sub    $0x1,%eax
801037fa:	a3 5c 47 11 80       	mov    %eax,0x8011475c
  if(log.committing)
801037ff:	a1 60 47 11 80       	mov    0x80114760,%eax
80103804:	85 c0                	test   %eax,%eax
80103806:	74 0d                	je     80103815 <end_op+0x44>
    panic("log.committing");
80103808:	83 ec 0c             	sub    $0xc,%esp
8010380b:	68 e9 94 10 80       	push   $0x801094e9
80103810:	e8 f3 cd ff ff       	call   80100608 <panic>
  if(log.outstanding == 0){
80103815:	a1 5c 47 11 80       	mov    0x8011475c,%eax
8010381a:	85 c0                	test   %eax,%eax
8010381c:	75 13                	jne    80103831 <end_op+0x60>
    do_commit = 1;
8010381e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103825:	c7 05 60 47 11 80 01 	movl   $0x1,0x80114760
8010382c:	00 00 00 
8010382f:	eb 10                	jmp    80103841 <end_op+0x70>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103831:	83 ec 0c             	sub    $0xc,%esp
80103834:	68 20 47 11 80       	push   $0x80114720
80103839:	e8 e2 16 00 00       	call   80104f20 <wakeup>
8010383e:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103841:	83 ec 0c             	sub    $0xc,%esp
80103844:	68 20 47 11 80       	push   $0x80114720
80103849:	e8 c4 1a 00 00       	call   80105312 <release>
8010384e:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103851:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103855:	74 3f                	je     80103896 <end_op+0xc5>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103857:	e8 fa 00 00 00       	call   80103956 <commit>
    acquire(&log.lock);
8010385c:	83 ec 0c             	sub    $0xc,%esp
8010385f:	68 20 47 11 80       	push   $0x80114720
80103864:	e8 37 1a 00 00       	call   801052a0 <acquire>
80103869:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010386c:	c7 05 60 47 11 80 00 	movl   $0x0,0x80114760
80103873:	00 00 00 
    wakeup(&log);
80103876:	83 ec 0c             	sub    $0xc,%esp
80103879:	68 20 47 11 80       	push   $0x80114720
8010387e:	e8 9d 16 00 00       	call   80104f20 <wakeup>
80103883:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103886:	83 ec 0c             	sub    $0xc,%esp
80103889:	68 20 47 11 80       	push   $0x80114720
8010388e:	e8 7f 1a 00 00       	call   80105312 <release>
80103893:	83 c4 10             	add    $0x10,%esp
  }
}
80103896:	90                   	nop
80103897:	c9                   	leave  
80103898:	c3                   	ret    

80103899 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103899:	f3 0f 1e fb          	endbr32 
8010389d:	55                   	push   %ebp
8010389e:	89 e5                	mov    %esp,%ebp
801038a0:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801038a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038aa:	e9 95 00 00 00       	jmp    80103944 <write_log+0xab>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801038af:	8b 15 54 47 11 80    	mov    0x80114754,%edx
801038b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038b8:	01 d0                	add    %edx,%eax
801038ba:	83 c0 01             	add    $0x1,%eax
801038bd:	89 c2                	mov    %eax,%edx
801038bf:	a1 64 47 11 80       	mov    0x80114764,%eax
801038c4:	83 ec 08             	sub    $0x8,%esp
801038c7:	52                   	push   %edx
801038c8:	50                   	push   %eax
801038c9:	e8 09 c9 ff ff       	call   801001d7 <bread>
801038ce:	83 c4 10             	add    $0x10,%esp
801038d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801038d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038d7:	83 c0 10             	add    $0x10,%eax
801038da:	8b 04 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%eax
801038e1:	89 c2                	mov    %eax,%edx
801038e3:	a1 64 47 11 80       	mov    0x80114764,%eax
801038e8:	83 ec 08             	sub    $0x8,%esp
801038eb:	52                   	push   %edx
801038ec:	50                   	push   %eax
801038ed:	e8 e5 c8 ff ff       	call   801001d7 <bread>
801038f2:	83 c4 10             	add    $0x10,%esp
801038f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801038f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801038fb:	8d 50 5c             	lea    0x5c(%eax),%edx
801038fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103901:	83 c0 5c             	add    $0x5c,%eax
80103904:	83 ec 04             	sub    $0x4,%esp
80103907:	68 00 02 00 00       	push   $0x200
8010390c:	52                   	push   %edx
8010390d:	50                   	push   %eax
8010390e:	e8 f3 1c 00 00       	call   80105606 <memmove>
80103913:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103916:	83 ec 0c             	sub    $0xc,%esp
80103919:	ff 75 f0             	pushl  -0x10(%ebp)
8010391c:	e8 f3 c8 ff ff       	call   80100214 <bwrite>
80103921:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103924:	83 ec 0c             	sub    $0xc,%esp
80103927:	ff 75 ec             	pushl  -0x14(%ebp)
8010392a:	e8 32 c9 ff ff       	call   80100261 <brelse>
8010392f:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103932:	83 ec 0c             	sub    $0xc,%esp
80103935:	ff 75 f0             	pushl  -0x10(%ebp)
80103938:	e8 24 c9 ff ff       	call   80100261 <brelse>
8010393d:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103940:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103944:	a1 68 47 11 80       	mov    0x80114768,%eax
80103949:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010394c:	0f 8c 5d ff ff ff    	jl     801038af <write_log+0x16>
  }
}
80103952:	90                   	nop
80103953:	90                   	nop
80103954:	c9                   	leave  
80103955:	c3                   	ret    

80103956 <commit>:

static void
commit()
{
80103956:	f3 0f 1e fb          	endbr32 
8010395a:	55                   	push   %ebp
8010395b:	89 e5                	mov    %esp,%ebp
8010395d:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103960:	a1 68 47 11 80       	mov    0x80114768,%eax
80103965:	85 c0                	test   %eax,%eax
80103967:	7e 1e                	jle    80103987 <commit+0x31>
    write_log();     // Write modified blocks from cache to log
80103969:	e8 2b ff ff ff       	call   80103899 <write_log>
    write_head();    // Write header to disk -- the real commit
8010396e:	e8 21 fd ff ff       	call   80103694 <write_head>
    install_trans(); // Now install writes to home locations
80103973:	e8 e7 fb ff ff       	call   8010355f <install_trans>
    log.lh.n = 0;
80103978:	c7 05 68 47 11 80 00 	movl   $0x0,0x80114768
8010397f:	00 00 00 
    write_head();    // Erase the transaction from the log
80103982:	e8 0d fd ff ff       	call   80103694 <write_head>
  }
}
80103987:	90                   	nop
80103988:	c9                   	leave  
80103989:	c3                   	ret    

8010398a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010398a:	f3 0f 1e fb          	endbr32 
8010398e:	55                   	push   %ebp
8010398f:	89 e5                	mov    %esp,%ebp
80103991:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103994:	a1 68 47 11 80       	mov    0x80114768,%eax
80103999:	83 f8 1d             	cmp    $0x1d,%eax
8010399c:	7f 12                	jg     801039b0 <log_write+0x26>
8010399e:	a1 68 47 11 80       	mov    0x80114768,%eax
801039a3:	8b 15 58 47 11 80    	mov    0x80114758,%edx
801039a9:	83 ea 01             	sub    $0x1,%edx
801039ac:	39 d0                	cmp    %edx,%eax
801039ae:	7c 0d                	jl     801039bd <log_write+0x33>
    panic("too big a transaction");
801039b0:	83 ec 0c             	sub    $0xc,%esp
801039b3:	68 f8 94 10 80       	push   $0x801094f8
801039b8:	e8 4b cc ff ff       	call   80100608 <panic>
  if (log.outstanding < 1)
801039bd:	a1 5c 47 11 80       	mov    0x8011475c,%eax
801039c2:	85 c0                	test   %eax,%eax
801039c4:	7f 0d                	jg     801039d3 <log_write+0x49>
    panic("log_write outside of trans");
801039c6:	83 ec 0c             	sub    $0xc,%esp
801039c9:	68 0e 95 10 80       	push   $0x8010950e
801039ce:	e8 35 cc ff ff       	call   80100608 <panic>

  acquire(&log.lock);
801039d3:	83 ec 0c             	sub    $0xc,%esp
801039d6:	68 20 47 11 80       	push   $0x80114720
801039db:	e8 c0 18 00 00       	call   801052a0 <acquire>
801039e0:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801039e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801039ea:	eb 1d                	jmp    80103a09 <log_write+0x7f>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801039ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039ef:	83 c0 10             	add    $0x10,%eax
801039f2:	8b 04 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%eax
801039f9:	89 c2                	mov    %eax,%edx
801039fb:	8b 45 08             	mov    0x8(%ebp),%eax
801039fe:	8b 40 08             	mov    0x8(%eax),%eax
80103a01:	39 c2                	cmp    %eax,%edx
80103a03:	74 10                	je     80103a15 <log_write+0x8b>
  for (i = 0; i < log.lh.n; i++) {
80103a05:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a09:	a1 68 47 11 80       	mov    0x80114768,%eax
80103a0e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a11:	7c d9                	jl     801039ec <log_write+0x62>
80103a13:	eb 01                	jmp    80103a16 <log_write+0x8c>
      break;
80103a15:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103a16:	8b 45 08             	mov    0x8(%ebp),%eax
80103a19:	8b 40 08             	mov    0x8(%eax),%eax
80103a1c:	89 c2                	mov    %eax,%edx
80103a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a21:	83 c0 10             	add    $0x10,%eax
80103a24:	89 14 85 2c 47 11 80 	mov    %edx,-0x7feeb8d4(,%eax,4)
  if (i == log.lh.n)
80103a2b:	a1 68 47 11 80       	mov    0x80114768,%eax
80103a30:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a33:	75 0d                	jne    80103a42 <log_write+0xb8>
    log.lh.n++;
80103a35:	a1 68 47 11 80       	mov    0x80114768,%eax
80103a3a:	83 c0 01             	add    $0x1,%eax
80103a3d:	a3 68 47 11 80       	mov    %eax,0x80114768
  b->flags |= B_DIRTY; // prevent eviction
80103a42:	8b 45 08             	mov    0x8(%ebp),%eax
80103a45:	8b 00                	mov    (%eax),%eax
80103a47:	83 c8 04             	or     $0x4,%eax
80103a4a:	89 c2                	mov    %eax,%edx
80103a4c:	8b 45 08             	mov    0x8(%ebp),%eax
80103a4f:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103a51:	83 ec 0c             	sub    $0xc,%esp
80103a54:	68 20 47 11 80       	push   $0x80114720
80103a59:	e8 b4 18 00 00       	call   80105312 <release>
80103a5e:	83 c4 10             	add    $0x10,%esp
}
80103a61:	90                   	nop
80103a62:	c9                   	leave  
80103a63:	c3                   	ret    

80103a64 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103a64:	55                   	push   %ebp
80103a65:	89 e5                	mov    %esp,%ebp
80103a67:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103a6a:	8b 55 08             	mov    0x8(%ebp),%edx
80103a6d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a70:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103a73:	f0 87 02             	lock xchg %eax,(%edx)
80103a76:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103a79:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103a7c:	c9                   	leave  
80103a7d:	c3                   	ret    

80103a7e <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103a7e:	f3 0f 1e fb          	endbr32 
80103a82:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103a86:	83 e4 f0             	and    $0xfffffff0,%esp
80103a89:	ff 71 fc             	pushl  -0x4(%ecx)
80103a8c:	55                   	push   %ebp
80103a8d:	89 e5                	mov    %esp,%ebp
80103a8f:	51                   	push   %ecx
80103a90:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103a93:	83 ec 08             	sub    $0x8,%esp
80103a96:	68 00 00 40 80       	push   $0x80400000
80103a9b:	68 48 7f 11 80       	push   $0x80117f48
80103aa0:	e8 78 f2 ff ff       	call   80102d1d <kinit1>
80103aa5:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103aa8:	e8 75 46 00 00       	call   80108122 <kvmalloc>
  mpinit();        // detect other processors
80103aad:	e8 d9 03 00 00       	call   80103e8b <mpinit>
  lapicinit();     // interrupt controller
80103ab2:	e8 f5 f5 ff ff       	call   801030ac <lapicinit>
  seginit();       // segment descriptors
80103ab7:	e8 1e 41 00 00       	call   80107bda <seginit>
  picinit();       // disable pic
80103abc:	e8 35 05 00 00       	call   80103ff6 <picinit>
  ioapicinit();    // another interrupt controller
80103ac1:	e8 6a f1 ff ff       	call   80102c30 <ioapicinit>
  consoleinit();   // console hardware
80103ac6:	e8 16 d1 ff ff       	call   80100be1 <consoleinit>
  uartinit();      // serial port
80103acb:	e8 93 34 00 00       	call   80106f63 <uartinit>
  pinit();         // process table
80103ad0:	e8 6e 09 00 00       	call   80104443 <pinit>
  tvinit();        // trap vectors
80103ad5:	e8 21 30 00 00       	call   80106afb <tvinit>
  binit();         // buffer cache
80103ada:	e8 55 c5 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103adf:	e8 26 d6 ff ff       	call   8010110a <fileinit>
  ideinit();       // disk 
80103ae4:	e8 06 ed ff ff       	call   801027ef <ideinit>
  startothers();   // start other processors
80103ae9:	e8 88 00 00 00       	call   80103b76 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103aee:	83 ec 08             	sub    $0x8,%esp
80103af1:	68 00 00 00 8e       	push   $0x8e000000
80103af6:	68 00 00 40 80       	push   $0x80400000
80103afb:	e8 5a f2 ff ff       	call   80102d5a <kinit2>
80103b00:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80103b03:	e8 34 0b 00 00       	call   8010463c <userinit>
  mpmain();        // finish this processor's setup
80103b08:	e8 1e 00 00 00       	call   80103b2b <mpmain>

80103b0d <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103b0d:	f3 0f 1e fb          	endbr32 
80103b11:	55                   	push   %ebp
80103b12:	89 e5                	mov    %esp,%ebp
80103b14:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103b17:	e8 22 46 00 00       	call   8010813e <switchkvm>
  seginit();
80103b1c:	e8 b9 40 00 00       	call   80107bda <seginit>
  lapicinit();
80103b21:	e8 86 f5 ff ff       	call   801030ac <lapicinit>
  mpmain();
80103b26:	e8 00 00 00 00       	call   80103b2b <mpmain>

80103b2b <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103b2b:	f3 0f 1e fb          	endbr32 
80103b2f:	55                   	push   %ebp
80103b30:	89 e5                	mov    %esp,%ebp
80103b32:	53                   	push   %ebx
80103b33:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103b36:	e8 2a 09 00 00       	call   80104465 <cpuid>
80103b3b:	89 c3                	mov    %eax,%ebx
80103b3d:	e8 23 09 00 00       	call   80104465 <cpuid>
80103b42:	83 ec 04             	sub    $0x4,%esp
80103b45:	53                   	push   %ebx
80103b46:	50                   	push   %eax
80103b47:	68 29 95 10 80       	push   $0x80109529
80103b4c:	e8 c7 c8 ff ff       	call   80100418 <cprintf>
80103b51:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103b54:	e8 1c 31 00 00       	call   80106c75 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103b59:	e8 26 09 00 00       	call   80104484 <mycpu>
80103b5e:	05 a0 00 00 00       	add    $0xa0,%eax
80103b63:	83 ec 08             	sub    $0x8,%esp
80103b66:	6a 01                	push   $0x1
80103b68:	50                   	push   %eax
80103b69:	e8 f6 fe ff ff       	call   80103a64 <xchg>
80103b6e:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103b71:	e8 b4 10 00 00       	call   80104c2a <scheduler>

80103b76 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103b76:	f3 0f 1e fb          	endbr32 
80103b7a:	55                   	push   %ebp
80103b7b:	89 e5                	mov    %esp,%ebp
80103b7d:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103b80:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103b87:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103b8c:	83 ec 04             	sub    $0x4,%esp
80103b8f:	50                   	push   %eax
80103b90:	68 0c c5 10 80       	push   $0x8010c50c
80103b95:	ff 75 f0             	pushl  -0x10(%ebp)
80103b98:	e8 69 1a 00 00       	call   80105606 <memmove>
80103b9d:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103ba0:	c7 45 f4 20 48 11 80 	movl   $0x80114820,-0xc(%ebp)
80103ba7:	eb 79                	jmp    80103c22 <startothers+0xac>
    if(c == mycpu())  // We've started already.
80103ba9:	e8 d6 08 00 00       	call   80104484 <mycpu>
80103bae:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103bb1:	74 67                	je     80103c1a <startothers+0xa4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103bb3:	e8 aa f2 ff ff       	call   80102e62 <kalloc>
80103bb8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103bbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bbe:	83 e8 04             	sub    $0x4,%eax
80103bc1:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103bc4:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103bca:	89 10                	mov    %edx,(%eax)
    *(void(**)(void))(code-8) = mpenter;
80103bcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bcf:	83 e8 08             	sub    $0x8,%eax
80103bd2:	c7 00 0d 3b 10 80    	movl   $0x80103b0d,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103bd8:	b8 00 b0 10 80       	mov    $0x8010b000,%eax
80103bdd:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103be3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103be6:	83 e8 0c             	sub    $0xc,%eax
80103be9:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
80103beb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bee:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103bf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf7:	0f b6 00             	movzbl (%eax),%eax
80103bfa:	0f b6 c0             	movzbl %al,%eax
80103bfd:	83 ec 08             	sub    $0x8,%esp
80103c00:	52                   	push   %edx
80103c01:	50                   	push   %eax
80103c02:	e8 17 f6 ff ff       	call   8010321e <lapicstartap>
80103c07:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103c0a:	90                   	nop
80103c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c0e:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103c14:	85 c0                	test   %eax,%eax
80103c16:	74 f3                	je     80103c0b <startothers+0x95>
80103c18:	eb 01                	jmp    80103c1b <startothers+0xa5>
      continue;
80103c1a:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103c1b:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103c22:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80103c27:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103c2d:	05 20 48 11 80       	add    $0x80114820,%eax
80103c32:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103c35:	0f 82 6e ff ff ff    	jb     80103ba9 <startothers+0x33>
      ;
  }
}
80103c3b:	90                   	nop
80103c3c:	90                   	nop
80103c3d:	c9                   	leave  
80103c3e:	c3                   	ret    

80103c3f <inb>:
{
80103c3f:	55                   	push   %ebp
80103c40:	89 e5                	mov    %esp,%ebp
80103c42:	83 ec 14             	sub    $0x14,%esp
80103c45:	8b 45 08             	mov    0x8(%ebp),%eax
80103c48:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103c4c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103c50:	89 c2                	mov    %eax,%edx
80103c52:	ec                   	in     (%dx),%al
80103c53:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103c56:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103c5a:	c9                   	leave  
80103c5b:	c3                   	ret    

80103c5c <outb>:
{
80103c5c:	55                   	push   %ebp
80103c5d:	89 e5                	mov    %esp,%ebp
80103c5f:	83 ec 08             	sub    $0x8,%esp
80103c62:	8b 45 08             	mov    0x8(%ebp),%eax
80103c65:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c68:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103c6c:	89 d0                	mov    %edx,%eax
80103c6e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103c71:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103c75:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103c79:	ee                   	out    %al,(%dx)
}
80103c7a:	90                   	nop
80103c7b:	c9                   	leave  
80103c7c:	c3                   	ret    

80103c7d <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103c7d:	f3 0f 1e fb          	endbr32 
80103c81:	55                   	push   %ebp
80103c82:	89 e5                	mov    %esp,%ebp
80103c84:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103c87:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103c8e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103c95:	eb 15                	jmp    80103cac <sum+0x2f>
    sum += addr[i];
80103c97:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103c9a:	8b 45 08             	mov    0x8(%ebp),%eax
80103c9d:	01 d0                	add    %edx,%eax
80103c9f:	0f b6 00             	movzbl (%eax),%eax
80103ca2:	0f b6 c0             	movzbl %al,%eax
80103ca5:	01 45 f8             	add    %eax,-0x8(%ebp)
  for(i=0; i<len; i++)
80103ca8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103cac:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103caf:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103cb2:	7c e3                	jl     80103c97 <sum+0x1a>
  return sum;
80103cb4:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103cb7:	c9                   	leave  
80103cb8:	c3                   	ret    

80103cb9 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103cb9:	f3 0f 1e fb          	endbr32 
80103cbd:	55                   	push   %ebp
80103cbe:	89 e5                	mov    %esp,%ebp
80103cc0:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103cc3:	8b 45 08             	mov    0x8(%ebp),%eax
80103cc6:	05 00 00 00 80       	add    $0x80000000,%eax
80103ccb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103cce:	8b 55 0c             	mov    0xc(%ebp),%edx
80103cd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cd4:	01 d0                	add    %edx,%eax
80103cd6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103cd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cdc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cdf:	eb 36                	jmp    80103d17 <mpsearch1+0x5e>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103ce1:	83 ec 04             	sub    $0x4,%esp
80103ce4:	6a 04                	push   $0x4
80103ce6:	68 40 95 10 80       	push   $0x80109540
80103ceb:	ff 75 f4             	pushl  -0xc(%ebp)
80103cee:	e8 b7 18 00 00       	call   801055aa <memcmp>
80103cf3:	83 c4 10             	add    $0x10,%esp
80103cf6:	85 c0                	test   %eax,%eax
80103cf8:	75 19                	jne    80103d13 <mpsearch1+0x5a>
80103cfa:	83 ec 08             	sub    $0x8,%esp
80103cfd:	6a 10                	push   $0x10
80103cff:	ff 75 f4             	pushl  -0xc(%ebp)
80103d02:	e8 76 ff ff ff       	call   80103c7d <sum>
80103d07:	83 c4 10             	add    $0x10,%esp
80103d0a:	84 c0                	test   %al,%al
80103d0c:	75 05                	jne    80103d13 <mpsearch1+0x5a>
      return (struct mp*)p;
80103d0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d11:	eb 11                	jmp    80103d24 <mpsearch1+0x6b>
  for(p = addr; p < e; p += sizeof(struct mp))
80103d13:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103d17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d1a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103d1d:	72 c2                	jb     80103ce1 <mpsearch1+0x28>
  return 0;
80103d1f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103d24:	c9                   	leave  
80103d25:	c3                   	ret    

80103d26 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103d26:	f3 0f 1e fb          	endbr32 
80103d2a:	55                   	push   %ebp
80103d2b:	89 e5                	mov    %esp,%ebp
80103d2d:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103d30:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103d37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d3a:	83 c0 0f             	add    $0xf,%eax
80103d3d:	0f b6 00             	movzbl (%eax),%eax
80103d40:	0f b6 c0             	movzbl %al,%eax
80103d43:	c1 e0 08             	shl    $0x8,%eax
80103d46:	89 c2                	mov    %eax,%edx
80103d48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d4b:	83 c0 0e             	add    $0xe,%eax
80103d4e:	0f b6 00             	movzbl (%eax),%eax
80103d51:	0f b6 c0             	movzbl %al,%eax
80103d54:	09 d0                	or     %edx,%eax
80103d56:	c1 e0 04             	shl    $0x4,%eax
80103d59:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103d5c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d60:	74 21                	je     80103d83 <mpsearch+0x5d>
    if((mp = mpsearch1(p, 1024)))
80103d62:	83 ec 08             	sub    $0x8,%esp
80103d65:	68 00 04 00 00       	push   $0x400
80103d6a:	ff 75 f0             	pushl  -0x10(%ebp)
80103d6d:	e8 47 ff ff ff       	call   80103cb9 <mpsearch1>
80103d72:	83 c4 10             	add    $0x10,%esp
80103d75:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d78:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103d7c:	74 51                	je     80103dcf <mpsearch+0xa9>
      return mp;
80103d7e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d81:	eb 61                	jmp    80103de4 <mpsearch+0xbe>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103d83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d86:	83 c0 14             	add    $0x14,%eax
80103d89:	0f b6 00             	movzbl (%eax),%eax
80103d8c:	0f b6 c0             	movzbl %al,%eax
80103d8f:	c1 e0 08             	shl    $0x8,%eax
80103d92:	89 c2                	mov    %eax,%edx
80103d94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d97:	83 c0 13             	add    $0x13,%eax
80103d9a:	0f b6 00             	movzbl (%eax),%eax
80103d9d:	0f b6 c0             	movzbl %al,%eax
80103da0:	09 d0                	or     %edx,%eax
80103da2:	c1 e0 0a             	shl    $0xa,%eax
80103da5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103da8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dab:	2d 00 04 00 00       	sub    $0x400,%eax
80103db0:	83 ec 08             	sub    $0x8,%esp
80103db3:	68 00 04 00 00       	push   $0x400
80103db8:	50                   	push   %eax
80103db9:	e8 fb fe ff ff       	call   80103cb9 <mpsearch1>
80103dbe:	83 c4 10             	add    $0x10,%esp
80103dc1:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103dc4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103dc8:	74 05                	je     80103dcf <mpsearch+0xa9>
      return mp;
80103dca:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103dcd:	eb 15                	jmp    80103de4 <mpsearch+0xbe>
  }
  return mpsearch1(0xF0000, 0x10000);
80103dcf:	83 ec 08             	sub    $0x8,%esp
80103dd2:	68 00 00 01 00       	push   $0x10000
80103dd7:	68 00 00 0f 00       	push   $0xf0000
80103ddc:	e8 d8 fe ff ff       	call   80103cb9 <mpsearch1>
80103de1:	83 c4 10             	add    $0x10,%esp
}
80103de4:	c9                   	leave  
80103de5:	c3                   	ret    

80103de6 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103de6:	f3 0f 1e fb          	endbr32 
80103dea:	55                   	push   %ebp
80103deb:	89 e5                	mov    %esp,%ebp
80103ded:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103df0:	e8 31 ff ff ff       	call   80103d26 <mpsearch>
80103df5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103df8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103dfc:	74 0a                	je     80103e08 <mpconfig+0x22>
80103dfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e01:	8b 40 04             	mov    0x4(%eax),%eax
80103e04:	85 c0                	test   %eax,%eax
80103e06:	75 07                	jne    80103e0f <mpconfig+0x29>
    return 0;
80103e08:	b8 00 00 00 00       	mov    $0x0,%eax
80103e0d:	eb 7a                	jmp    80103e89 <mpconfig+0xa3>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103e0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e12:	8b 40 04             	mov    0x4(%eax),%eax
80103e15:	05 00 00 00 80       	add    $0x80000000,%eax
80103e1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103e1d:	83 ec 04             	sub    $0x4,%esp
80103e20:	6a 04                	push   $0x4
80103e22:	68 45 95 10 80       	push   $0x80109545
80103e27:	ff 75 f0             	pushl  -0x10(%ebp)
80103e2a:	e8 7b 17 00 00       	call   801055aa <memcmp>
80103e2f:	83 c4 10             	add    $0x10,%esp
80103e32:	85 c0                	test   %eax,%eax
80103e34:	74 07                	je     80103e3d <mpconfig+0x57>
    return 0;
80103e36:	b8 00 00 00 00       	mov    $0x0,%eax
80103e3b:	eb 4c                	jmp    80103e89 <mpconfig+0xa3>
  if(conf->version != 1 && conf->version != 4)
80103e3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e40:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103e44:	3c 01                	cmp    $0x1,%al
80103e46:	74 12                	je     80103e5a <mpconfig+0x74>
80103e48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e4b:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103e4f:	3c 04                	cmp    $0x4,%al
80103e51:	74 07                	je     80103e5a <mpconfig+0x74>
    return 0;
80103e53:	b8 00 00 00 00       	mov    $0x0,%eax
80103e58:	eb 2f                	jmp    80103e89 <mpconfig+0xa3>
  if(sum((uchar*)conf, conf->length) != 0)
80103e5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e5d:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103e61:	0f b7 c0             	movzwl %ax,%eax
80103e64:	83 ec 08             	sub    $0x8,%esp
80103e67:	50                   	push   %eax
80103e68:	ff 75 f0             	pushl  -0x10(%ebp)
80103e6b:	e8 0d fe ff ff       	call   80103c7d <sum>
80103e70:	83 c4 10             	add    $0x10,%esp
80103e73:	84 c0                	test   %al,%al
80103e75:	74 07                	je     80103e7e <mpconfig+0x98>
    return 0;
80103e77:	b8 00 00 00 00       	mov    $0x0,%eax
80103e7c:	eb 0b                	jmp    80103e89 <mpconfig+0xa3>
  *pmp = mp;
80103e7e:	8b 45 08             	mov    0x8(%ebp),%eax
80103e81:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e84:	89 10                	mov    %edx,(%eax)
  return conf;
80103e86:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103e89:	c9                   	leave  
80103e8a:	c3                   	ret    

80103e8b <mpinit>:

void
mpinit(void)
{
80103e8b:	f3 0f 1e fb          	endbr32 
80103e8f:	55                   	push   %ebp
80103e90:	89 e5                	mov    %esp,%ebp
80103e92:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103e95:	83 ec 0c             	sub    $0xc,%esp
80103e98:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103e9b:	50                   	push   %eax
80103e9c:	e8 45 ff ff ff       	call   80103de6 <mpconfig>
80103ea1:	83 c4 10             	add    $0x10,%esp
80103ea4:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ea7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103eab:	75 0d                	jne    80103eba <mpinit+0x2f>
    panic("Expect to run on an SMP");
80103ead:	83 ec 0c             	sub    $0xc,%esp
80103eb0:	68 4a 95 10 80       	push   $0x8010954a
80103eb5:	e8 4e c7 ff ff       	call   80100608 <panic>
  ismp = 1;
80103eba:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103ec1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ec4:	8b 40 24             	mov    0x24(%eax),%eax
80103ec7:	a3 1c 47 11 80       	mov    %eax,0x8011471c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103ecc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ecf:	83 c0 2c             	add    $0x2c,%eax
80103ed2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ed5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ed8:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103edc:	0f b7 d0             	movzwl %ax,%edx
80103edf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ee2:	01 d0                	add    %edx,%eax
80103ee4:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103ee7:	e9 8c 00 00 00       	jmp    80103f78 <mpinit+0xed>
    switch(*p){
80103eec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eef:	0f b6 00             	movzbl (%eax),%eax
80103ef2:	0f b6 c0             	movzbl %al,%eax
80103ef5:	83 f8 04             	cmp    $0x4,%eax
80103ef8:	7f 76                	jg     80103f70 <mpinit+0xe5>
80103efa:	83 f8 03             	cmp    $0x3,%eax
80103efd:	7d 6b                	jge    80103f6a <mpinit+0xdf>
80103eff:	83 f8 02             	cmp    $0x2,%eax
80103f02:	74 4e                	je     80103f52 <mpinit+0xc7>
80103f04:	83 f8 02             	cmp    $0x2,%eax
80103f07:	7f 67                	jg     80103f70 <mpinit+0xe5>
80103f09:	85 c0                	test   %eax,%eax
80103f0b:	74 07                	je     80103f14 <mpinit+0x89>
80103f0d:	83 f8 01             	cmp    $0x1,%eax
80103f10:	74 58                	je     80103f6a <mpinit+0xdf>
80103f12:	eb 5c                	jmp    80103f70 <mpinit+0xe5>
    case MPPROC:
      proc = (struct mpproc*)p;
80103f14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f17:	89 45 e0             	mov    %eax,-0x20(%ebp)
      if(ncpu < NCPU) {
80103f1a:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80103f1f:	83 f8 07             	cmp    $0x7,%eax
80103f22:	7f 28                	jg     80103f4c <mpinit+0xc1>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103f24:	8b 15 a0 4d 11 80    	mov    0x80114da0,%edx
80103f2a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f2d:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103f31:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80103f37:	81 c2 20 48 11 80    	add    $0x80114820,%edx
80103f3d:	88 02                	mov    %al,(%edx)
        ncpu++;
80103f3f:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80103f44:	83 c0 01             	add    $0x1,%eax
80103f47:	a3 a0 4d 11 80       	mov    %eax,0x80114da0
      }
      p += sizeof(struct mpproc);
80103f4c:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103f50:	eb 26                	jmp    80103f78 <mpinit+0xed>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103f52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f55:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103f58:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103f5b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103f5f:	a2 00 48 11 80       	mov    %al,0x80114800
      p += sizeof(struct mpioapic);
80103f64:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103f68:	eb 0e                	jmp    80103f78 <mpinit+0xed>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103f6a:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103f6e:	eb 08                	jmp    80103f78 <mpinit+0xed>
    default:
      ismp = 0;
80103f70:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103f77:	90                   	nop
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103f78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f7b:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103f7e:	0f 82 68 ff ff ff    	jb     80103eec <mpinit+0x61>
    }
  }
  if(!ismp)
80103f84:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103f88:	75 0d                	jne    80103f97 <mpinit+0x10c>
    panic("Didn't find a suitable machine");
80103f8a:	83 ec 0c             	sub    $0xc,%esp
80103f8d:	68 64 95 10 80       	push   $0x80109564
80103f92:	e8 71 c6 ff ff       	call   80100608 <panic>

  if(mp->imcrp){
80103f97:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f9a:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103f9e:	84 c0                	test   %al,%al
80103fa0:	74 30                	je     80103fd2 <mpinit+0x147>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103fa2:	83 ec 08             	sub    $0x8,%esp
80103fa5:	6a 70                	push   $0x70
80103fa7:	6a 22                	push   $0x22
80103fa9:	e8 ae fc ff ff       	call   80103c5c <outb>
80103fae:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103fb1:	83 ec 0c             	sub    $0xc,%esp
80103fb4:	6a 23                	push   $0x23
80103fb6:	e8 84 fc ff ff       	call   80103c3f <inb>
80103fbb:	83 c4 10             	add    $0x10,%esp
80103fbe:	83 c8 01             	or     $0x1,%eax
80103fc1:	0f b6 c0             	movzbl %al,%eax
80103fc4:	83 ec 08             	sub    $0x8,%esp
80103fc7:	50                   	push   %eax
80103fc8:	6a 23                	push   $0x23
80103fca:	e8 8d fc ff ff       	call   80103c5c <outb>
80103fcf:	83 c4 10             	add    $0x10,%esp
  }
}
80103fd2:	90                   	nop
80103fd3:	c9                   	leave  
80103fd4:	c3                   	ret    

80103fd5 <outb>:
{
80103fd5:	55                   	push   %ebp
80103fd6:	89 e5                	mov    %esp,%ebp
80103fd8:	83 ec 08             	sub    $0x8,%esp
80103fdb:	8b 45 08             	mov    0x8(%ebp),%eax
80103fde:	8b 55 0c             	mov    0xc(%ebp),%edx
80103fe1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103fe5:	89 d0                	mov    %edx,%eax
80103fe7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103fea:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103fee:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103ff2:	ee                   	out    %al,(%dx)
}
80103ff3:	90                   	nop
80103ff4:	c9                   	leave  
80103ff5:	c3                   	ret    

80103ff6 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103ff6:	f3 0f 1e fb          	endbr32 
80103ffa:	55                   	push   %ebp
80103ffb:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103ffd:	68 ff 00 00 00       	push   $0xff
80104002:	6a 21                	push   $0x21
80104004:	e8 cc ff ff ff       	call   80103fd5 <outb>
80104009:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
8010400c:	68 ff 00 00 00       	push   $0xff
80104011:	68 a1 00 00 00       	push   $0xa1
80104016:	e8 ba ff ff ff       	call   80103fd5 <outb>
8010401b:	83 c4 08             	add    $0x8,%esp
}
8010401e:	90                   	nop
8010401f:	c9                   	leave  
80104020:	c3                   	ret    

80104021 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104021:	f3 0f 1e fb          	endbr32 
80104025:	55                   	push   %ebp
80104026:	89 e5                	mov    %esp,%ebp
80104028:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
8010402b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104032:	8b 45 0c             	mov    0xc(%ebp),%eax
80104035:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
8010403b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010403e:	8b 10                	mov    (%eax),%edx
80104040:	8b 45 08             	mov    0x8(%ebp),%eax
80104043:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104045:	e8 e2 d0 ff ff       	call   8010112c <filealloc>
8010404a:	8b 55 08             	mov    0x8(%ebp),%edx
8010404d:	89 02                	mov    %eax,(%edx)
8010404f:	8b 45 08             	mov    0x8(%ebp),%eax
80104052:	8b 00                	mov    (%eax),%eax
80104054:	85 c0                	test   %eax,%eax
80104056:	0f 84 c8 00 00 00    	je     80104124 <pipealloc+0x103>
8010405c:	e8 cb d0 ff ff       	call   8010112c <filealloc>
80104061:	8b 55 0c             	mov    0xc(%ebp),%edx
80104064:	89 02                	mov    %eax,(%edx)
80104066:	8b 45 0c             	mov    0xc(%ebp),%eax
80104069:	8b 00                	mov    (%eax),%eax
8010406b:	85 c0                	test   %eax,%eax
8010406d:	0f 84 b1 00 00 00    	je     80104124 <pipealloc+0x103>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104073:	e8 ea ed ff ff       	call   80102e62 <kalloc>
80104078:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010407b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010407f:	0f 84 a2 00 00 00    	je     80104127 <pipealloc+0x106>
    goto bad;
  p->readopen = 1;
80104085:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104088:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010408f:	00 00 00 
  p->writeopen = 1;
80104092:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104095:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
8010409c:	00 00 00 
  p->nwrite = 0;
8010409f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040a2:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801040a9:	00 00 00 
  p->nread = 0;
801040ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040af:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801040b6:	00 00 00 
  initlock(&p->lock, "pipe");
801040b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040bc:	83 ec 08             	sub    $0x8,%esp
801040bf:	68 83 95 10 80       	push   $0x80109583
801040c4:	50                   	push   %eax
801040c5:	e8 b0 11 00 00       	call   8010527a <initlock>
801040ca:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801040cd:	8b 45 08             	mov    0x8(%ebp),%eax
801040d0:	8b 00                	mov    (%eax),%eax
801040d2:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801040d8:	8b 45 08             	mov    0x8(%ebp),%eax
801040db:	8b 00                	mov    (%eax),%eax
801040dd:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801040e1:	8b 45 08             	mov    0x8(%ebp),%eax
801040e4:	8b 00                	mov    (%eax),%eax
801040e6:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801040ea:	8b 45 08             	mov    0x8(%ebp),%eax
801040ed:	8b 00                	mov    (%eax),%eax
801040ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040f2:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
801040f5:	8b 45 0c             	mov    0xc(%ebp),%eax
801040f8:	8b 00                	mov    (%eax),%eax
801040fa:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104100:	8b 45 0c             	mov    0xc(%ebp),%eax
80104103:	8b 00                	mov    (%eax),%eax
80104105:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104109:	8b 45 0c             	mov    0xc(%ebp),%eax
8010410c:	8b 00                	mov    (%eax),%eax
8010410e:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104112:	8b 45 0c             	mov    0xc(%ebp),%eax
80104115:	8b 00                	mov    (%eax),%eax
80104117:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010411a:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
8010411d:	b8 00 00 00 00       	mov    $0x0,%eax
80104122:	eb 51                	jmp    80104175 <pipealloc+0x154>
    goto bad;
80104124:	90                   	nop
80104125:	eb 01                	jmp    80104128 <pipealloc+0x107>
    goto bad;
80104127:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80104128:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010412c:	74 0e                	je     8010413c <pipealloc+0x11b>
    kfree((char*)p);
8010412e:	83 ec 0c             	sub    $0xc,%esp
80104131:	ff 75 f4             	pushl  -0xc(%ebp)
80104134:	e8 8b ec ff ff       	call   80102dc4 <kfree>
80104139:	83 c4 10             	add    $0x10,%esp
  if(*f0)
8010413c:	8b 45 08             	mov    0x8(%ebp),%eax
8010413f:	8b 00                	mov    (%eax),%eax
80104141:	85 c0                	test   %eax,%eax
80104143:	74 11                	je     80104156 <pipealloc+0x135>
    fileclose(*f0);
80104145:	8b 45 08             	mov    0x8(%ebp),%eax
80104148:	8b 00                	mov    (%eax),%eax
8010414a:	83 ec 0c             	sub    $0xc,%esp
8010414d:	50                   	push   %eax
8010414e:	e8 9f d0 ff ff       	call   801011f2 <fileclose>
80104153:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104156:	8b 45 0c             	mov    0xc(%ebp),%eax
80104159:	8b 00                	mov    (%eax),%eax
8010415b:	85 c0                	test   %eax,%eax
8010415d:	74 11                	je     80104170 <pipealloc+0x14f>
    fileclose(*f1);
8010415f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104162:	8b 00                	mov    (%eax),%eax
80104164:	83 ec 0c             	sub    $0xc,%esp
80104167:	50                   	push   %eax
80104168:	e8 85 d0 ff ff       	call   801011f2 <fileclose>
8010416d:	83 c4 10             	add    $0x10,%esp
  return -1;
80104170:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104175:	c9                   	leave  
80104176:	c3                   	ret    

80104177 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104177:	f3 0f 1e fb          	endbr32 
8010417b:	55                   	push   %ebp
8010417c:	89 e5                	mov    %esp,%ebp
8010417e:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80104181:	8b 45 08             	mov    0x8(%ebp),%eax
80104184:	83 ec 0c             	sub    $0xc,%esp
80104187:	50                   	push   %eax
80104188:	e8 13 11 00 00       	call   801052a0 <acquire>
8010418d:	83 c4 10             	add    $0x10,%esp
  if(writable){
80104190:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104194:	74 23                	je     801041b9 <pipeclose+0x42>
    p->writeopen = 0;
80104196:	8b 45 08             	mov    0x8(%ebp),%eax
80104199:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801041a0:	00 00 00 
    wakeup(&p->nread);
801041a3:	8b 45 08             	mov    0x8(%ebp),%eax
801041a6:	05 34 02 00 00       	add    $0x234,%eax
801041ab:	83 ec 0c             	sub    $0xc,%esp
801041ae:	50                   	push   %eax
801041af:	e8 6c 0d 00 00       	call   80104f20 <wakeup>
801041b4:	83 c4 10             	add    $0x10,%esp
801041b7:	eb 21                	jmp    801041da <pipeclose+0x63>
  } else {
    p->readopen = 0;
801041b9:	8b 45 08             	mov    0x8(%ebp),%eax
801041bc:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801041c3:	00 00 00 
    wakeup(&p->nwrite);
801041c6:	8b 45 08             	mov    0x8(%ebp),%eax
801041c9:	05 38 02 00 00       	add    $0x238,%eax
801041ce:	83 ec 0c             	sub    $0xc,%esp
801041d1:	50                   	push   %eax
801041d2:	e8 49 0d 00 00       	call   80104f20 <wakeup>
801041d7:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
801041da:	8b 45 08             	mov    0x8(%ebp),%eax
801041dd:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801041e3:	85 c0                	test   %eax,%eax
801041e5:	75 2c                	jne    80104213 <pipeclose+0x9c>
801041e7:	8b 45 08             	mov    0x8(%ebp),%eax
801041ea:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801041f0:	85 c0                	test   %eax,%eax
801041f2:	75 1f                	jne    80104213 <pipeclose+0x9c>
    release(&p->lock);
801041f4:	8b 45 08             	mov    0x8(%ebp),%eax
801041f7:	83 ec 0c             	sub    $0xc,%esp
801041fa:	50                   	push   %eax
801041fb:	e8 12 11 00 00       	call   80105312 <release>
80104200:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104203:	83 ec 0c             	sub    $0xc,%esp
80104206:	ff 75 08             	pushl  0x8(%ebp)
80104209:	e8 b6 eb ff ff       	call   80102dc4 <kfree>
8010420e:	83 c4 10             	add    $0x10,%esp
80104211:	eb 10                	jmp    80104223 <pipeclose+0xac>
  } else
    release(&p->lock);
80104213:	8b 45 08             	mov    0x8(%ebp),%eax
80104216:	83 ec 0c             	sub    $0xc,%esp
80104219:	50                   	push   %eax
8010421a:	e8 f3 10 00 00       	call   80105312 <release>
8010421f:	83 c4 10             	add    $0x10,%esp
}
80104222:	90                   	nop
80104223:	90                   	nop
80104224:	c9                   	leave  
80104225:	c3                   	ret    

80104226 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104226:	f3 0f 1e fb          	endbr32 
8010422a:	55                   	push   %ebp
8010422b:	89 e5                	mov    %esp,%ebp
8010422d:	53                   	push   %ebx
8010422e:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104231:	8b 45 08             	mov    0x8(%ebp),%eax
80104234:	83 ec 0c             	sub    $0xc,%esp
80104237:	50                   	push   %eax
80104238:	e8 63 10 00 00       	call   801052a0 <acquire>
8010423d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104240:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104247:	e9 ad 00 00 00       	jmp    801042f9 <pipewrite+0xd3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
8010424c:	8b 45 08             	mov    0x8(%ebp),%eax
8010424f:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104255:	85 c0                	test   %eax,%eax
80104257:	74 0c                	je     80104265 <pipewrite+0x3f>
80104259:	e8 a2 02 00 00       	call   80104500 <myproc>
8010425e:	8b 40 24             	mov    0x24(%eax),%eax
80104261:	85 c0                	test   %eax,%eax
80104263:	74 19                	je     8010427e <pipewrite+0x58>
        release(&p->lock);
80104265:	8b 45 08             	mov    0x8(%ebp),%eax
80104268:	83 ec 0c             	sub    $0xc,%esp
8010426b:	50                   	push   %eax
8010426c:	e8 a1 10 00 00       	call   80105312 <release>
80104271:	83 c4 10             	add    $0x10,%esp
        return -1;
80104274:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104279:	e9 a9 00 00 00       	jmp    80104327 <pipewrite+0x101>
      }
      wakeup(&p->nread);
8010427e:	8b 45 08             	mov    0x8(%ebp),%eax
80104281:	05 34 02 00 00       	add    $0x234,%eax
80104286:	83 ec 0c             	sub    $0xc,%esp
80104289:	50                   	push   %eax
8010428a:	e8 91 0c 00 00       	call   80104f20 <wakeup>
8010428f:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104292:	8b 45 08             	mov    0x8(%ebp),%eax
80104295:	8b 55 08             	mov    0x8(%ebp),%edx
80104298:	81 c2 38 02 00 00    	add    $0x238,%edx
8010429e:	83 ec 08             	sub    $0x8,%esp
801042a1:	50                   	push   %eax
801042a2:	52                   	push   %edx
801042a3:	e8 86 0b 00 00       	call   80104e2e <sleep>
801042a8:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801042ab:	8b 45 08             	mov    0x8(%ebp),%eax
801042ae:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801042b4:	8b 45 08             	mov    0x8(%ebp),%eax
801042b7:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801042bd:	05 00 02 00 00       	add    $0x200,%eax
801042c2:	39 c2                	cmp    %eax,%edx
801042c4:	74 86                	je     8010424c <pipewrite+0x26>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801042c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801042cc:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801042cf:	8b 45 08             	mov    0x8(%ebp),%eax
801042d2:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042d8:	8d 48 01             	lea    0x1(%eax),%ecx
801042db:	8b 55 08             	mov    0x8(%ebp),%edx
801042de:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801042e4:	25 ff 01 00 00       	and    $0x1ff,%eax
801042e9:	89 c1                	mov    %eax,%ecx
801042eb:	0f b6 13             	movzbl (%ebx),%edx
801042ee:	8b 45 08             	mov    0x8(%ebp),%eax
801042f1:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
801042f5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801042f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042fc:	3b 45 10             	cmp    0x10(%ebp),%eax
801042ff:	7c aa                	jl     801042ab <pipewrite+0x85>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104301:	8b 45 08             	mov    0x8(%ebp),%eax
80104304:	05 34 02 00 00       	add    $0x234,%eax
80104309:	83 ec 0c             	sub    $0xc,%esp
8010430c:	50                   	push   %eax
8010430d:	e8 0e 0c 00 00       	call   80104f20 <wakeup>
80104312:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104315:	8b 45 08             	mov    0x8(%ebp),%eax
80104318:	83 ec 0c             	sub    $0xc,%esp
8010431b:	50                   	push   %eax
8010431c:	e8 f1 0f 00 00       	call   80105312 <release>
80104321:	83 c4 10             	add    $0x10,%esp
  return n;
80104324:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104327:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010432a:	c9                   	leave  
8010432b:	c3                   	ret    

8010432c <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010432c:	f3 0f 1e fb          	endbr32 
80104330:	55                   	push   %ebp
80104331:	89 e5                	mov    %esp,%ebp
80104333:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104336:	8b 45 08             	mov    0x8(%ebp),%eax
80104339:	83 ec 0c             	sub    $0xc,%esp
8010433c:	50                   	push   %eax
8010433d:	e8 5e 0f 00 00       	call   801052a0 <acquire>
80104342:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104345:	eb 3e                	jmp    80104385 <piperead+0x59>
    if(myproc()->killed){
80104347:	e8 b4 01 00 00       	call   80104500 <myproc>
8010434c:	8b 40 24             	mov    0x24(%eax),%eax
8010434f:	85 c0                	test   %eax,%eax
80104351:	74 19                	je     8010436c <piperead+0x40>
      release(&p->lock);
80104353:	8b 45 08             	mov    0x8(%ebp),%eax
80104356:	83 ec 0c             	sub    $0xc,%esp
80104359:	50                   	push   %eax
8010435a:	e8 b3 0f 00 00       	call   80105312 <release>
8010435f:	83 c4 10             	add    $0x10,%esp
      return -1;
80104362:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104367:	e9 be 00 00 00       	jmp    8010442a <piperead+0xfe>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010436c:	8b 45 08             	mov    0x8(%ebp),%eax
8010436f:	8b 55 08             	mov    0x8(%ebp),%edx
80104372:	81 c2 34 02 00 00    	add    $0x234,%edx
80104378:	83 ec 08             	sub    $0x8,%esp
8010437b:	50                   	push   %eax
8010437c:	52                   	push   %edx
8010437d:	e8 ac 0a 00 00       	call   80104e2e <sleep>
80104382:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104385:	8b 45 08             	mov    0x8(%ebp),%eax
80104388:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010438e:	8b 45 08             	mov    0x8(%ebp),%eax
80104391:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104397:	39 c2                	cmp    %eax,%edx
80104399:	75 0d                	jne    801043a8 <piperead+0x7c>
8010439b:	8b 45 08             	mov    0x8(%ebp),%eax
8010439e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801043a4:	85 c0                	test   %eax,%eax
801043a6:	75 9f                	jne    80104347 <piperead+0x1b>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801043a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801043af:	eb 48                	jmp    801043f9 <piperead+0xcd>
    if(p->nread == p->nwrite)
801043b1:	8b 45 08             	mov    0x8(%ebp),%eax
801043b4:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801043ba:	8b 45 08             	mov    0x8(%ebp),%eax
801043bd:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043c3:	39 c2                	cmp    %eax,%edx
801043c5:	74 3c                	je     80104403 <piperead+0xd7>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801043c7:	8b 45 08             	mov    0x8(%ebp),%eax
801043ca:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801043d0:	8d 48 01             	lea    0x1(%eax),%ecx
801043d3:	8b 55 08             	mov    0x8(%ebp),%edx
801043d6:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801043dc:	25 ff 01 00 00       	and    $0x1ff,%eax
801043e1:	89 c1                	mov    %eax,%ecx
801043e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043e6:	8b 45 0c             	mov    0xc(%ebp),%eax
801043e9:	01 c2                	add    %eax,%edx
801043eb:	8b 45 08             	mov    0x8(%ebp),%eax
801043ee:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
801043f3:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801043f5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801043f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043fc:	3b 45 10             	cmp    0x10(%ebp),%eax
801043ff:	7c b0                	jl     801043b1 <piperead+0x85>
80104401:	eb 01                	jmp    80104404 <piperead+0xd8>
      break;
80104403:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104404:	8b 45 08             	mov    0x8(%ebp),%eax
80104407:	05 38 02 00 00       	add    $0x238,%eax
8010440c:	83 ec 0c             	sub    $0xc,%esp
8010440f:	50                   	push   %eax
80104410:	e8 0b 0b 00 00       	call   80104f20 <wakeup>
80104415:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104418:	8b 45 08             	mov    0x8(%ebp),%eax
8010441b:	83 ec 0c             	sub    $0xc,%esp
8010441e:	50                   	push   %eax
8010441f:	e8 ee 0e 00 00       	call   80105312 <release>
80104424:	83 c4 10             	add    $0x10,%esp
  return i;
80104427:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010442a:	c9                   	leave  
8010442b:	c3                   	ret    

8010442c <readeflags>:
{
8010442c:	55                   	push   %ebp
8010442d:	89 e5                	mov    %esp,%ebp
8010442f:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104432:	9c                   	pushf  
80104433:	58                   	pop    %eax
80104434:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104437:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010443a:	c9                   	leave  
8010443b:	c3                   	ret    

8010443c <sti>:
{
8010443c:	55                   	push   %ebp
8010443d:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010443f:	fb                   	sti    
}
80104440:	90                   	nop
80104441:	5d                   	pop    %ebp
80104442:	c3                   	ret    

80104443 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104443:	f3 0f 1e fb          	endbr32 
80104447:	55                   	push   %ebp
80104448:	89 e5                	mov    %esp,%ebp
8010444a:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
8010444d:	83 ec 08             	sub    $0x8,%esp
80104450:	68 88 95 10 80       	push   $0x80109588
80104455:	68 c0 4d 11 80       	push   $0x80114dc0
8010445a:	e8 1b 0e 00 00       	call   8010527a <initlock>
8010445f:	83 c4 10             	add    $0x10,%esp
}
80104462:	90                   	nop
80104463:	c9                   	leave  
80104464:	c3                   	ret    

80104465 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80104465:	f3 0f 1e fb          	endbr32 
80104469:	55                   	push   %ebp
8010446a:	89 e5                	mov    %esp,%ebp
8010446c:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
8010446f:	e8 10 00 00 00       	call   80104484 <mycpu>
80104474:	2d 20 48 11 80       	sub    $0x80114820,%eax
80104479:	c1 f8 04             	sar    $0x4,%eax
8010447c:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80104482:	c9                   	leave  
80104483:	c3                   	ret    

80104484 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80104484:	f3 0f 1e fb          	endbr32 
80104488:	55                   	push   %ebp
80104489:	89 e5                	mov    %esp,%ebp
8010448b:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
8010448e:	e8 99 ff ff ff       	call   8010442c <readeflags>
80104493:	25 00 02 00 00       	and    $0x200,%eax
80104498:	85 c0                	test   %eax,%eax
8010449a:	74 0d                	je     801044a9 <mycpu+0x25>
    panic("mycpu called with interrupts enabled\n");
8010449c:	83 ec 0c             	sub    $0xc,%esp
8010449f:	68 90 95 10 80       	push   $0x80109590
801044a4:	e8 5f c1 ff ff       	call   80100608 <panic>
  
  apicid = lapicid();
801044a9:	e8 21 ed ff ff       	call   801031cf <lapicid>
801044ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801044b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801044b8:	eb 2d                	jmp    801044e7 <mycpu+0x63>
    if (cpus[i].apicid == apicid)
801044ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044bd:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801044c3:	05 20 48 11 80       	add    $0x80114820,%eax
801044c8:	0f b6 00             	movzbl (%eax),%eax
801044cb:	0f b6 c0             	movzbl %al,%eax
801044ce:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801044d1:	75 10                	jne    801044e3 <mycpu+0x5f>
      return &cpus[i];
801044d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d6:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801044dc:	05 20 48 11 80       	add    $0x80114820,%eax
801044e1:	eb 1b                	jmp    801044fe <mycpu+0x7a>
  for (i = 0; i < ncpu; ++i) {
801044e3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801044e7:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
801044ec:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801044ef:	7c c9                	jl     801044ba <mycpu+0x36>
  }
  panic("unknown apicid\n");
801044f1:	83 ec 0c             	sub    $0xc,%esp
801044f4:	68 b6 95 10 80       	push   $0x801095b6
801044f9:	e8 0a c1 ff ff       	call   80100608 <panic>
}
801044fe:	c9                   	leave  
801044ff:	c3                   	ret    

80104500 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80104500:	f3 0f 1e fb          	endbr32 
80104504:	55                   	push   %ebp
80104505:	89 e5                	mov    %esp,%ebp
80104507:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
8010450a:	e8 1d 0f 00 00       	call   8010542c <pushcli>
  c = mycpu();
8010450f:	e8 70 ff ff ff       	call   80104484 <mycpu>
80104514:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80104517:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451a:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104520:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80104523:	e8 55 0f 00 00       	call   8010547d <popcli>
  return p;
80104528:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010452b:	c9                   	leave  
8010452c:	c3                   	ret    

8010452d <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010452d:	f3 0f 1e fb          	endbr32 
80104531:	55                   	push   %ebp
80104532:	89 e5                	mov    %esp,%ebp
80104534:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104537:	83 ec 0c             	sub    $0xc,%esp
8010453a:	68 c0 4d 11 80       	push   $0x80114dc0
8010453f:	e8 5c 0d 00 00       	call   801052a0 <acquire>
80104544:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104547:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
8010454e:	eb 11                	jmp    80104561 <allocproc+0x34>
    if(p->state == UNUSED)
80104550:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104553:	8b 40 0c             	mov    0xc(%eax),%eax
80104556:	85 c0                	test   %eax,%eax
80104558:	74 2a                	je     80104584 <allocproc+0x57>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010455a:	81 45 f4 a4 00 00 00 	addl   $0xa4,-0xc(%ebp)
80104561:	81 7d f4 f4 76 11 80 	cmpl   $0x801176f4,-0xc(%ebp)
80104568:	72 e6                	jb     80104550 <allocproc+0x23>
      goto found;

  release(&ptable.lock);
8010456a:	83 ec 0c             	sub    $0xc,%esp
8010456d:	68 c0 4d 11 80       	push   $0x80114dc0
80104572:	e8 9b 0d 00 00       	call   80105312 <release>
80104577:	83 c4 10             	add    $0x10,%esp
  return 0;
8010457a:	b8 00 00 00 00       	mov    $0x0,%eax
8010457f:	e9 b6 00 00 00       	jmp    8010463a <allocproc+0x10d>
      goto found;
80104584:	90                   	nop
80104585:	f3 0f 1e fb          	endbr32 

found:
  p->state = EMBRYO;
80104589:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010458c:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104593:	a1 00 c0 10 80       	mov    0x8010c000,%eax
80104598:	8d 50 01             	lea    0x1(%eax),%edx
8010459b:	89 15 00 c0 10 80    	mov    %edx,0x8010c000
801045a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045a4:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
801045a7:	83 ec 0c             	sub    $0xc,%esp
801045aa:	68 c0 4d 11 80       	push   $0x80114dc0
801045af:	e8 5e 0d 00 00       	call   80105312 <release>
801045b4:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801045b7:	e8 a6 e8 ff ff       	call   80102e62 <kalloc>
801045bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045bf:	89 42 08             	mov    %eax,0x8(%edx)
801045c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c5:	8b 40 08             	mov    0x8(%eax),%eax
801045c8:	85 c0                	test   %eax,%eax
801045ca:	75 11                	jne    801045dd <allocproc+0xb0>
    p->state = UNUSED;
801045cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045cf:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801045d6:	b8 00 00 00 00       	mov    $0x0,%eax
801045db:	eb 5d                	jmp    8010463a <allocproc+0x10d>
  }
  sp = p->kstack + KSTACKSIZE;
801045dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e0:	8b 40 08             	mov    0x8(%eax),%eax
801045e3:	05 00 10 00 00       	add    $0x1000,%eax
801045e8:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801045eb:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801045ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045f5:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801045f8:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801045fc:	ba b5 6a 10 80       	mov    $0x80106ab5,%edx
80104601:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104604:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104606:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010460a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010460d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104610:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104613:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104616:	8b 40 1c             	mov    0x1c(%eax),%eax
80104619:	83 ec 04             	sub    $0x4,%esp
8010461c:	6a 14                	push   $0x14
8010461e:	6a 00                	push   $0x0
80104620:	50                   	push   %eax
80104621:	e8 19 0f 00 00       	call   8010553f <memset>
80104626:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104629:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010462c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010462f:	ba e4 4d 10 80       	mov    $0x80104de4,%edx
80104634:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104637:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010463a:	c9                   	leave  
8010463b:	c3                   	ret    

8010463c <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
8010463c:	f3 0f 1e fb          	endbr32 
80104640:	55                   	push   %ebp
80104641:	89 e5                	mov    %esp,%ebp
80104643:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80104646:	e8 e2 fe ff ff       	call   8010452d <allocproc>
8010464b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
8010464e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104651:	a3 40 c6 10 80       	mov    %eax,0x8010c640
  if((p->pgdir = setupkvm()) == 0)
80104656:	e8 2a 3a 00 00       	call   80108085 <setupkvm>
8010465b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010465e:	89 42 04             	mov    %eax,0x4(%edx)
80104661:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104664:	8b 40 04             	mov    0x4(%eax),%eax
80104667:	85 c0                	test   %eax,%eax
80104669:	75 0d                	jne    80104678 <userinit+0x3c>
    panic("userinit: out of memory?");
8010466b:	83 ec 0c             	sub    $0xc,%esp
8010466e:	68 c6 95 10 80       	push   $0x801095c6
80104673:	e8 90 bf ff ff       	call   80100608 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104678:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010467d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104680:	8b 40 04             	mov    0x4(%eax),%eax
80104683:	83 ec 04             	sub    $0x4,%esp
80104686:	52                   	push   %edx
80104687:	68 e0 c4 10 80       	push   $0x8010c4e0
8010468c:	50                   	push   %eax
8010468d:	e8 6c 3c 00 00       	call   801082fe <inituvm>
80104692:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104695:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104698:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010469e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a1:	8b 40 18             	mov    0x18(%eax),%eax
801046a4:	83 ec 04             	sub    $0x4,%esp
801046a7:	6a 4c                	push   $0x4c
801046a9:	6a 00                	push   $0x0
801046ab:	50                   	push   %eax
801046ac:	e8 8e 0e 00 00       	call   8010553f <memset>
801046b1:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801046b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046b7:	8b 40 18             	mov    0x18(%eax),%eax
801046ba:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801046c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c3:	8b 40 18             	mov    0x18(%eax),%eax
801046c6:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801046cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046cf:	8b 50 18             	mov    0x18(%eax),%edx
801046d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d5:	8b 40 18             	mov    0x18(%eax),%eax
801046d8:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801046dc:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801046e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046e3:	8b 50 18             	mov    0x18(%eax),%edx
801046e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046e9:	8b 40 18             	mov    0x18(%eax),%eax
801046ec:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801046f0:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801046f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f7:	8b 40 18             	mov    0x18(%eax),%eax
801046fa:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104701:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104704:	8b 40 18             	mov    0x18(%eax),%eax
80104707:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010470e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104711:	8b 40 18             	mov    0x18(%eax),%eax
80104714:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010471b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010471e:	83 c0 6c             	add    $0x6c,%eax
80104721:	83 ec 04             	sub    $0x4,%esp
80104724:	6a 10                	push   $0x10
80104726:	68 df 95 10 80       	push   $0x801095df
8010472b:	50                   	push   %eax
8010472c:	e8 29 10 00 00       	call   8010575a <safestrcpy>
80104731:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104734:	83 ec 0c             	sub    $0xc,%esp
80104737:	68 e8 95 10 80       	push   $0x801095e8
8010473c:	e8 9c df ff ff       	call   801026dd <namei>
80104741:	83 c4 10             	add    $0x10,%esp
80104744:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104747:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
8010474a:	83 ec 0c             	sub    $0xc,%esp
8010474d:	68 c0 4d 11 80       	push   $0x80114dc0
80104752:	e8 49 0b 00 00       	call   801052a0 <acquire>
80104757:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
8010475a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010475d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104764:	83 ec 0c             	sub    $0xc,%esp
80104767:	68 c0 4d 11 80       	push   $0x80114dc0
8010476c:	e8 a1 0b 00 00       	call   80105312 <release>
80104771:	83 c4 10             	add    $0x10,%esp
}
80104774:	90                   	nop
80104775:	c9                   	leave  
80104776:	c3                   	ret    

80104777 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104777:	f3 0f 1e fb          	endbr32 
8010477b:	55                   	push   %ebp
8010477c:	89 e5                	mov    %esp,%ebp
8010477e:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80104781:	e8 7a fd ff ff       	call   80104500 <myproc>
80104786:	89 45 ec             	mov    %eax,-0x14(%ebp)

  sz = curproc->sz;
80104789:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010478c:	8b 00                	mov    (%eax),%eax
8010478e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104791:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104795:	7e 77                	jle    8010480e <growproc+0x97>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0){
80104797:	8b 55 08             	mov    0x8(%ebp),%edx
8010479a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010479d:	01 c2                	add    %eax,%edx
8010479f:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047a2:	8b 40 04             	mov    0x4(%eax),%eax
801047a5:	83 ec 04             	sub    $0x4,%esp
801047a8:	52                   	push   %edx
801047a9:	ff 75 f4             	pushl  -0xc(%ebp)
801047ac:	50                   	push   %eax
801047ad:	e8 91 3c 00 00       	call   80108443 <allocuvm>
801047b2:	83 c4 10             	add    $0x10,%esp
801047b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801047b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801047bc:	75 0a                	jne    801047c8 <growproc+0x51>
      return -1;
801047be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047c3:	e9 95 00 00 00       	jmp    8010485d <growproc+0xe6>
    // // for (; a < sz + n; a += PGSIZE){
    // //   cprintf("growth in ecrypt \n");
    // // 	mencrypt((char*)a, 1);
    // // }
    // mencrypt((char*) a, n/PGSIZE);
    int r = sz/PGSIZE;
801047c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047cb:	c1 e8 0c             	shr    $0xc,%eax
801047ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if (sz%PGSIZE)
801047d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047d4:	25 ff 0f 00 00       	and    $0xfff,%eax
801047d9:	85 c0                	test   %eax,%eax
801047db:	74 04                	je     801047e1 <growproc+0x6a>
    r++;
801047dd:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  mencrypt(0,r-2);
801047e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047e4:	83 e8 02             	sub    $0x2,%eax
801047e7:	83 ec 08             	sub    $0x8,%esp
801047ea:	50                   	push   %eax
801047eb:	6a 00                	push   $0x0
801047ed:	e8 95 43 00 00       	call   80108b87 <mencrypt>
801047f2:	83 c4 10             	add    $0x10,%esp
  mencrypt((char*)((r-1)*PGSIZE),1);
801047f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047f8:	83 e8 01             	sub    $0x1,%eax
801047fb:	c1 e0 0c             	shl    $0xc,%eax
801047fe:	83 ec 08             	sub    $0x8,%esp
80104801:	6a 01                	push   $0x1
80104803:	50                   	push   %eax
80104804:	e8 7e 43 00 00       	call   80108b87 <mencrypt>
80104809:	83 c4 10             	add    $0x10,%esp
8010480c:	eb 34                	jmp    80104842 <growproc+0xcb>
    
  } else if(n < 0){
8010480e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104812:	79 2e                	jns    80104842 <growproc+0xcb>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104814:	8b 55 08             	mov    0x8(%ebp),%edx
80104817:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010481a:	01 c2                	add    %eax,%edx
8010481c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010481f:	8b 40 04             	mov    0x4(%eax),%eax
80104822:	83 ec 04             	sub    $0x4,%esp
80104825:	52                   	push   %edx
80104826:	ff 75 f4             	pushl  -0xc(%ebp)
80104829:	50                   	push   %eax
8010482a:	e8 1d 3d 00 00       	call   8010854c <deallocuvm>
8010482f:	83 c4 10             	add    $0x10,%esp
80104832:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104835:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104839:	75 07                	jne    80104842 <growproc+0xcb>
      return -1;
8010483b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104840:	eb 1b                	jmp    8010485d <growproc+0xe6>
  }

  curproc->sz = sz;
80104842:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104845:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104848:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
8010484a:	83 ec 0c             	sub    $0xc,%esp
8010484d:	ff 75 ec             	pushl  -0x14(%ebp)
80104850:	e8 06 39 00 00       	call   8010815b <switchuvm>
80104855:	83 c4 10             	add    $0x10,%esp
  return 0;
80104858:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010485d:	c9                   	leave  
8010485e:	c3                   	ret    

8010485f <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010485f:	f3 0f 1e fb          	endbr32 
80104863:	55                   	push   %ebp
80104864:	89 e5                	mov    %esp,%ebp
80104866:	57                   	push   %edi
80104867:	56                   	push   %esi
80104868:	53                   	push   %ebx
80104869:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
8010486c:	e8 8f fc ff ff       	call   80104500 <myproc>
80104871:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80104874:	e8 b4 fc ff ff       	call   8010452d <allocproc>
80104879:	89 45 dc             	mov    %eax,-0x24(%ebp)
8010487c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80104880:	75 0a                	jne    8010488c <fork+0x2d>
    return -1;
80104882:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104887:	e9 48 01 00 00       	jmp    801049d4 <fork+0x175>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
8010488c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010488f:	8b 10                	mov    (%eax),%edx
80104891:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104894:	8b 40 04             	mov    0x4(%eax),%eax
80104897:	83 ec 08             	sub    $0x8,%esp
8010489a:	52                   	push   %edx
8010489b:	50                   	push   %eax
8010489c:	e8 59 3e 00 00       	call   801086fa <copyuvm>
801048a1:	83 c4 10             	add    $0x10,%esp
801048a4:	8b 55 dc             	mov    -0x24(%ebp),%edx
801048a7:	89 42 04             	mov    %eax,0x4(%edx)
801048aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048ad:	8b 40 04             	mov    0x4(%eax),%eax
801048b0:	85 c0                	test   %eax,%eax
801048b2:	75 30                	jne    801048e4 <fork+0x85>
    kfree(np->kstack);
801048b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048b7:	8b 40 08             	mov    0x8(%eax),%eax
801048ba:	83 ec 0c             	sub    $0xc,%esp
801048bd:	50                   	push   %eax
801048be:	e8 01 e5 ff ff       	call   80102dc4 <kfree>
801048c3:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
801048c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048c9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801048d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048d3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801048da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048df:	e9 f0 00 00 00       	jmp    801049d4 <fork+0x175>
  }
  np->sz = curproc->sz;
801048e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048e7:	8b 10                	mov    (%eax),%edx
801048e9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048ec:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
801048ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048f1:	8b 55 e0             	mov    -0x20(%ebp),%edx
801048f4:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
801048f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048fa:	8b 48 18             	mov    0x18(%eax),%ecx
801048fd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104900:	8b 40 18             	mov    0x18(%eax),%eax
80104903:	89 c2                	mov    %eax,%edx
80104905:	89 cb                	mov    %ecx,%ebx
80104907:	b8 13 00 00 00       	mov    $0x13,%eax
8010490c:	89 d7                	mov    %edx,%edi
8010490e:	89 de                	mov    %ebx,%esi
80104910:	89 c1                	mov    %eax,%ecx
80104912:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104914:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104917:	8b 40 18             	mov    0x18(%eax),%eax
8010491a:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104921:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104928:	eb 3b                	jmp    80104965 <fork+0x106>
    if(curproc->ofile[i])
8010492a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010492d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104930:	83 c2 08             	add    $0x8,%edx
80104933:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104937:	85 c0                	test   %eax,%eax
80104939:	74 26                	je     80104961 <fork+0x102>
      np->ofile[i] = filedup(curproc->ofile[i]);
8010493b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010493e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104941:	83 c2 08             	add    $0x8,%edx
80104944:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104948:	83 ec 0c             	sub    $0xc,%esp
8010494b:	50                   	push   %eax
8010494c:	e8 4c c8 ff ff       	call   8010119d <filedup>
80104951:	83 c4 10             	add    $0x10,%esp
80104954:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104957:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010495a:	83 c1 08             	add    $0x8,%ecx
8010495d:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80104961:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104965:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104969:	7e bf                	jle    8010492a <fork+0xcb>
  np->cwd = idup(curproc->cwd);
8010496b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010496e:	8b 40 68             	mov    0x68(%eax),%eax
80104971:	83 ec 0c             	sub    $0xc,%esp
80104974:	50                   	push   %eax
80104975:	e8 ba d1 ff ff       	call   80101b34 <idup>
8010497a:	83 c4 10             	add    $0x10,%esp
8010497d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104980:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104983:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104986:	8d 50 6c             	lea    0x6c(%eax),%edx
80104989:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010498c:	83 c0 6c             	add    $0x6c,%eax
8010498f:	83 ec 04             	sub    $0x4,%esp
80104992:	6a 10                	push   $0x10
80104994:	52                   	push   %edx
80104995:	50                   	push   %eax
80104996:	e8 bf 0d 00 00       	call   8010575a <safestrcpy>
8010499b:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
8010499e:	8b 45 dc             	mov    -0x24(%ebp),%eax
801049a1:	8b 40 10             	mov    0x10(%eax),%eax
801049a4:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
801049a7:	83 ec 0c             	sub    $0xc,%esp
801049aa:	68 c0 4d 11 80       	push   $0x80114dc0
801049af:	e8 ec 08 00 00       	call   801052a0 <acquire>
801049b4:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
801049b7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801049ba:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801049c1:	83 ec 0c             	sub    $0xc,%esp
801049c4:	68 c0 4d 11 80       	push   $0x80114dc0
801049c9:	e8 44 09 00 00       	call   80105312 <release>
801049ce:	83 c4 10             	add    $0x10,%esp

  return pid;
801049d1:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
801049d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801049d7:	5b                   	pop    %ebx
801049d8:	5e                   	pop    %esi
801049d9:	5f                   	pop    %edi
801049da:	5d                   	pop    %ebp
801049db:	c3                   	ret    

801049dc <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801049dc:	f3 0f 1e fb          	endbr32 
801049e0:	55                   	push   %ebp
801049e1:	89 e5                	mov    %esp,%ebp
801049e3:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801049e6:	e8 15 fb ff ff       	call   80104500 <myproc>
801049eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
801049ee:	a1 40 c6 10 80       	mov    0x8010c640,%eax
801049f3:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801049f6:	75 0d                	jne    80104a05 <exit+0x29>
    panic("init exiting");
801049f8:	83 ec 0c             	sub    $0xc,%esp
801049fb:	68 ea 95 10 80       	push   $0x801095ea
80104a00:	e8 03 bc ff ff       	call   80100608 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104a05:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104a0c:	eb 3f                	jmp    80104a4d <exit+0x71>
    if(curproc->ofile[fd]){
80104a0e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a11:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a14:	83 c2 08             	add    $0x8,%edx
80104a17:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a1b:	85 c0                	test   %eax,%eax
80104a1d:	74 2a                	je     80104a49 <exit+0x6d>
      fileclose(curproc->ofile[fd]);
80104a1f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a22:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a25:	83 c2 08             	add    $0x8,%edx
80104a28:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a2c:	83 ec 0c             	sub    $0xc,%esp
80104a2f:	50                   	push   %eax
80104a30:	e8 bd c7 ff ff       	call   801011f2 <fileclose>
80104a35:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80104a38:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a3b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a3e:	83 c2 08             	add    $0x8,%edx
80104a41:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104a48:	00 
  for(fd = 0; fd < NOFILE; fd++){
80104a49:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104a4d:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104a51:	7e bb                	jle    80104a0e <exit+0x32>
    }
  }

  begin_op();
80104a53:	e8 e9 ec ff ff       	call   80103741 <begin_op>
  iput(curproc->cwd);
80104a58:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a5b:	8b 40 68             	mov    0x68(%eax),%eax
80104a5e:	83 ec 0c             	sub    $0xc,%esp
80104a61:	50                   	push   %eax
80104a62:	e8 74 d2 ff ff       	call   80101cdb <iput>
80104a67:	83 c4 10             	add    $0x10,%esp
  end_op();
80104a6a:	e8 62 ed ff ff       	call   801037d1 <end_op>
  curproc->cwd = 0;
80104a6f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a72:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104a79:	83 ec 0c             	sub    $0xc,%esp
80104a7c:	68 c0 4d 11 80       	push   $0x80114dc0
80104a81:	e8 1a 08 00 00       	call   801052a0 <acquire>
80104a86:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104a89:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a8c:	8b 40 14             	mov    0x14(%eax),%eax
80104a8f:	83 ec 0c             	sub    $0xc,%esp
80104a92:	50                   	push   %eax
80104a93:	e8 41 04 00 00       	call   80104ed9 <wakeup1>
80104a98:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a9b:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104aa2:	eb 3a                	jmp    80104ade <exit+0x102>
    if(p->parent == curproc){
80104aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa7:	8b 40 14             	mov    0x14(%eax),%eax
80104aaa:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104aad:	75 28                	jne    80104ad7 <exit+0xfb>
      p->parent = initproc;
80104aaf:	8b 15 40 c6 10 80    	mov    0x8010c640,%edx
80104ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab8:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104abb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104abe:	8b 40 0c             	mov    0xc(%eax),%eax
80104ac1:	83 f8 05             	cmp    $0x5,%eax
80104ac4:	75 11                	jne    80104ad7 <exit+0xfb>
        wakeup1(initproc);
80104ac6:	a1 40 c6 10 80       	mov    0x8010c640,%eax
80104acb:	83 ec 0c             	sub    $0xc,%esp
80104ace:	50                   	push   %eax
80104acf:	e8 05 04 00 00       	call   80104ed9 <wakeup1>
80104ad4:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ad7:	81 45 f4 a4 00 00 00 	addl   $0xa4,-0xc(%ebp)
80104ade:	81 7d f4 f4 76 11 80 	cmpl   $0x801176f4,-0xc(%ebp)
80104ae5:	72 bd                	jb     80104aa4 <exit+0xc8>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104ae7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104aea:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104af1:	e8 f3 01 00 00       	call   80104ce9 <sched>
  panic("zombie exit");
80104af6:	83 ec 0c             	sub    $0xc,%esp
80104af9:	68 f7 95 10 80       	push   $0x801095f7
80104afe:	e8 05 bb ff ff       	call   80100608 <panic>

80104b03 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104b03:	f3 0f 1e fb          	endbr32 
80104b07:	55                   	push   %ebp
80104b08:	89 e5                	mov    %esp,%ebp
80104b0a:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104b0d:	e8 ee f9 ff ff       	call   80104500 <myproc>
80104b12:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104b15:	83 ec 0c             	sub    $0xc,%esp
80104b18:	68 c0 4d 11 80       	push   $0x80114dc0
80104b1d:	e8 7e 07 00 00       	call   801052a0 <acquire>
80104b22:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104b25:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b2c:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104b33:	e9 a4 00 00 00       	jmp    80104bdc <wait+0xd9>
      if(p->parent != curproc)
80104b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b3b:	8b 40 14             	mov    0x14(%eax),%eax
80104b3e:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104b41:	0f 85 8d 00 00 00    	jne    80104bd4 <wait+0xd1>
        continue;
      havekids = 1;
80104b47:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b51:	8b 40 0c             	mov    0xc(%eax),%eax
80104b54:	83 f8 05             	cmp    $0x5,%eax
80104b57:	75 7c                	jne    80104bd5 <wait+0xd2>
        // Found one.
        pid = p->pid;
80104b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b5c:	8b 40 10             	mov    0x10(%eax),%eax
80104b5f:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b65:	8b 40 08             	mov    0x8(%eax),%eax
80104b68:	83 ec 0c             	sub    $0xc,%esp
80104b6b:	50                   	push   %eax
80104b6c:	e8 53 e2 ff ff       	call   80102dc4 <kfree>
80104b71:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104b74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b77:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b81:	8b 40 04             	mov    0x4(%eax),%eax
80104b84:	83 ec 0c             	sub    $0xc,%esp
80104b87:	50                   	push   %eax
80104b88:	e8 89 3a 00 00       	call   80108616 <freevm>
80104b8d:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b93:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104b9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b9d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104ba4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba7:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bae:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bb8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104bbf:	83 ec 0c             	sub    $0xc,%esp
80104bc2:	68 c0 4d 11 80       	push   $0x80114dc0
80104bc7:	e8 46 07 00 00       	call   80105312 <release>
80104bcc:	83 c4 10             	add    $0x10,%esp
        return pid;
80104bcf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104bd2:	eb 54                	jmp    80104c28 <wait+0x125>
        continue;
80104bd4:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bd5:	81 45 f4 a4 00 00 00 	addl   $0xa4,-0xc(%ebp)
80104bdc:	81 7d f4 f4 76 11 80 	cmpl   $0x801176f4,-0xc(%ebp)
80104be3:	0f 82 4f ff ff ff    	jb     80104b38 <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104be9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104bed:	74 0a                	je     80104bf9 <wait+0xf6>
80104bef:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104bf2:	8b 40 24             	mov    0x24(%eax),%eax
80104bf5:	85 c0                	test   %eax,%eax
80104bf7:	74 17                	je     80104c10 <wait+0x10d>
      release(&ptable.lock);
80104bf9:	83 ec 0c             	sub    $0xc,%esp
80104bfc:	68 c0 4d 11 80       	push   $0x80114dc0
80104c01:	e8 0c 07 00 00       	call   80105312 <release>
80104c06:	83 c4 10             	add    $0x10,%esp
      return -1;
80104c09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c0e:	eb 18                	jmp    80104c28 <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104c10:	83 ec 08             	sub    $0x8,%esp
80104c13:	68 c0 4d 11 80       	push   $0x80114dc0
80104c18:	ff 75 ec             	pushl  -0x14(%ebp)
80104c1b:	e8 0e 02 00 00       	call   80104e2e <sleep>
80104c20:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104c23:	e9 fd fe ff ff       	jmp    80104b25 <wait+0x22>
  }
}
80104c28:	c9                   	leave  
80104c29:	c3                   	ret    

80104c2a <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104c2a:	f3 0f 1e fb          	endbr32 
80104c2e:	55                   	push   %ebp
80104c2f:	89 e5                	mov    %esp,%ebp
80104c31:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104c34:	e8 4b f8 ff ff       	call   80104484 <mycpu>
80104c39:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104c3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c3f:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104c46:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104c49:	e8 ee f7 ff ff       	call   8010443c <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104c4e:	83 ec 0c             	sub    $0xc,%esp
80104c51:	68 c0 4d 11 80       	push   $0x80114dc0
80104c56:	e8 45 06 00 00       	call   801052a0 <acquire>
80104c5b:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c5e:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104c65:	eb 64                	jmp    80104ccb <scheduler+0xa1>
      if(p->state != RUNNABLE)
80104c67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c6a:	8b 40 0c             	mov    0xc(%eax),%eax
80104c6d:	83 f8 03             	cmp    $0x3,%eax
80104c70:	75 51                	jne    80104cc3 <scheduler+0x99>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104c72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c75:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c78:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104c7e:	83 ec 0c             	sub    $0xc,%esp
80104c81:	ff 75 f4             	pushl  -0xc(%ebp)
80104c84:	e8 d2 34 00 00       	call   8010815b <switchuvm>
80104c89:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104c8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c8f:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104c96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c99:	8b 40 1c             	mov    0x1c(%eax),%eax
80104c9c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104c9f:	83 c2 04             	add    $0x4,%edx
80104ca2:	83 ec 08             	sub    $0x8,%esp
80104ca5:	50                   	push   %eax
80104ca6:	52                   	push   %edx
80104ca7:	e8 27 0b 00 00       	call   801057d3 <swtch>
80104cac:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104caf:	e8 8a 34 00 00       	call   8010813e <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104cb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cb7:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104cbe:	00 00 00 
80104cc1:	eb 01                	jmp    80104cc4 <scheduler+0x9a>
        continue;
80104cc3:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104cc4:	81 45 f4 a4 00 00 00 	addl   $0xa4,-0xc(%ebp)
80104ccb:	81 7d f4 f4 76 11 80 	cmpl   $0x801176f4,-0xc(%ebp)
80104cd2:	72 93                	jb     80104c67 <scheduler+0x3d>
    }
    release(&ptable.lock);
80104cd4:	83 ec 0c             	sub    $0xc,%esp
80104cd7:	68 c0 4d 11 80       	push   $0x80114dc0
80104cdc:	e8 31 06 00 00       	call   80105312 <release>
80104ce1:	83 c4 10             	add    $0x10,%esp
    sti();
80104ce4:	e9 60 ff ff ff       	jmp    80104c49 <scheduler+0x1f>

80104ce9 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104ce9:	f3 0f 1e fb          	endbr32 
80104ced:	55                   	push   %ebp
80104cee:	89 e5                	mov    %esp,%ebp
80104cf0:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104cf3:	e8 08 f8 ff ff       	call   80104500 <myproc>
80104cf8:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104cfb:	83 ec 0c             	sub    $0xc,%esp
80104cfe:	68 c0 4d 11 80       	push   $0x80114dc0
80104d03:	e8 df 06 00 00       	call   801053e7 <holding>
80104d08:	83 c4 10             	add    $0x10,%esp
80104d0b:	85 c0                	test   %eax,%eax
80104d0d:	75 0d                	jne    80104d1c <sched+0x33>
    panic("sched ptable.lock");
80104d0f:	83 ec 0c             	sub    $0xc,%esp
80104d12:	68 03 96 10 80       	push   $0x80109603
80104d17:	e8 ec b8 ff ff       	call   80100608 <panic>
  if(mycpu()->ncli != 1)
80104d1c:	e8 63 f7 ff ff       	call   80104484 <mycpu>
80104d21:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d27:	83 f8 01             	cmp    $0x1,%eax
80104d2a:	74 0d                	je     80104d39 <sched+0x50>
    panic("sched locks");
80104d2c:	83 ec 0c             	sub    $0xc,%esp
80104d2f:	68 15 96 10 80       	push   $0x80109615
80104d34:	e8 cf b8 ff ff       	call   80100608 <panic>
  if(p->state == RUNNING)
80104d39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d3c:	8b 40 0c             	mov    0xc(%eax),%eax
80104d3f:	83 f8 04             	cmp    $0x4,%eax
80104d42:	75 0d                	jne    80104d51 <sched+0x68>
    panic("sched running");
80104d44:	83 ec 0c             	sub    $0xc,%esp
80104d47:	68 21 96 10 80       	push   $0x80109621
80104d4c:	e8 b7 b8 ff ff       	call   80100608 <panic>
  if(readeflags()&FL_IF)
80104d51:	e8 d6 f6 ff ff       	call   8010442c <readeflags>
80104d56:	25 00 02 00 00       	and    $0x200,%eax
80104d5b:	85 c0                	test   %eax,%eax
80104d5d:	74 0d                	je     80104d6c <sched+0x83>
    panic("sched interruptible");
80104d5f:	83 ec 0c             	sub    $0xc,%esp
80104d62:	68 2f 96 10 80       	push   $0x8010962f
80104d67:	e8 9c b8 ff ff       	call   80100608 <panic>
  intena = mycpu()->intena;
80104d6c:	e8 13 f7 ff ff       	call   80104484 <mycpu>
80104d71:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104d77:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104d7a:	e8 05 f7 ff ff       	call   80104484 <mycpu>
80104d7f:	8b 40 04             	mov    0x4(%eax),%eax
80104d82:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d85:	83 c2 1c             	add    $0x1c,%edx
80104d88:	83 ec 08             	sub    $0x8,%esp
80104d8b:	50                   	push   %eax
80104d8c:	52                   	push   %edx
80104d8d:	e8 41 0a 00 00       	call   801057d3 <swtch>
80104d92:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104d95:	e8 ea f6 ff ff       	call   80104484 <mycpu>
80104d9a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d9d:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104da3:	90                   	nop
80104da4:	c9                   	leave  
80104da5:	c3                   	ret    

80104da6 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104da6:	f3 0f 1e fb          	endbr32 
80104daa:	55                   	push   %ebp
80104dab:	89 e5                	mov    %esp,%ebp
80104dad:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104db0:	83 ec 0c             	sub    $0xc,%esp
80104db3:	68 c0 4d 11 80       	push   $0x80114dc0
80104db8:	e8 e3 04 00 00       	call   801052a0 <acquire>
80104dbd:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104dc0:	e8 3b f7 ff ff       	call   80104500 <myproc>
80104dc5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104dcc:	e8 18 ff ff ff       	call   80104ce9 <sched>
  release(&ptable.lock);
80104dd1:	83 ec 0c             	sub    $0xc,%esp
80104dd4:	68 c0 4d 11 80       	push   $0x80114dc0
80104dd9:	e8 34 05 00 00       	call   80105312 <release>
80104dde:	83 c4 10             	add    $0x10,%esp
}
80104de1:	90                   	nop
80104de2:	c9                   	leave  
80104de3:	c3                   	ret    

80104de4 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104de4:	f3 0f 1e fb          	endbr32 
80104de8:	55                   	push   %ebp
80104de9:	89 e5                	mov    %esp,%ebp
80104deb:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104dee:	83 ec 0c             	sub    $0xc,%esp
80104df1:	68 c0 4d 11 80       	push   $0x80114dc0
80104df6:	e8 17 05 00 00       	call   80105312 <release>
80104dfb:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104dfe:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104e03:	85 c0                	test   %eax,%eax
80104e05:	74 24                	je     80104e2b <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104e07:	c7 05 04 c0 10 80 00 	movl   $0x0,0x8010c004
80104e0e:	00 00 00 
    iinit(ROOTDEV);
80104e11:	83 ec 0c             	sub    $0xc,%esp
80104e14:	6a 01                	push   $0x1
80104e16:	e8 d1 c9 ff ff       	call   801017ec <iinit>
80104e1b:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104e1e:	83 ec 0c             	sub    $0xc,%esp
80104e21:	6a 01                	push   $0x1
80104e23:	e8 e6 e6 ff ff       	call   8010350e <initlog>
80104e28:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104e2b:	90                   	nop
80104e2c:	c9                   	leave  
80104e2d:	c3                   	ret    

80104e2e <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104e2e:	f3 0f 1e fb          	endbr32 
80104e32:	55                   	push   %ebp
80104e33:	89 e5                	mov    %esp,%ebp
80104e35:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104e38:	e8 c3 f6 ff ff       	call   80104500 <myproc>
80104e3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104e40:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104e44:	75 0d                	jne    80104e53 <sleep+0x25>
    panic("sleep");
80104e46:	83 ec 0c             	sub    $0xc,%esp
80104e49:	68 43 96 10 80       	push   $0x80109643
80104e4e:	e8 b5 b7 ff ff       	call   80100608 <panic>

  if(lk == 0)
80104e53:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104e57:	75 0d                	jne    80104e66 <sleep+0x38>
    panic("sleep without lk");
80104e59:	83 ec 0c             	sub    $0xc,%esp
80104e5c:	68 49 96 10 80       	push   $0x80109649
80104e61:	e8 a2 b7 ff ff       	call   80100608 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104e66:	81 7d 0c c0 4d 11 80 	cmpl   $0x80114dc0,0xc(%ebp)
80104e6d:	74 1e                	je     80104e8d <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104e6f:	83 ec 0c             	sub    $0xc,%esp
80104e72:	68 c0 4d 11 80       	push   $0x80114dc0
80104e77:	e8 24 04 00 00       	call   801052a0 <acquire>
80104e7c:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104e7f:	83 ec 0c             	sub    $0xc,%esp
80104e82:	ff 75 0c             	pushl  0xc(%ebp)
80104e85:	e8 88 04 00 00       	call   80105312 <release>
80104e8a:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104e8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e90:	8b 55 08             	mov    0x8(%ebp),%edx
80104e93:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e99:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104ea0:	e8 44 fe ff ff       	call   80104ce9 <sched>

  // Tidy up.
  p->chan = 0;
80104ea5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ea8:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104eaf:	81 7d 0c c0 4d 11 80 	cmpl   $0x80114dc0,0xc(%ebp)
80104eb6:	74 1e                	je     80104ed6 <sleep+0xa8>
    release(&ptable.lock);
80104eb8:	83 ec 0c             	sub    $0xc,%esp
80104ebb:	68 c0 4d 11 80       	push   $0x80114dc0
80104ec0:	e8 4d 04 00 00       	call   80105312 <release>
80104ec5:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104ec8:	83 ec 0c             	sub    $0xc,%esp
80104ecb:	ff 75 0c             	pushl  0xc(%ebp)
80104ece:	e8 cd 03 00 00       	call   801052a0 <acquire>
80104ed3:	83 c4 10             	add    $0x10,%esp
  }
}
80104ed6:	90                   	nop
80104ed7:	c9                   	leave  
80104ed8:	c3                   	ret    

80104ed9 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104ed9:	f3 0f 1e fb          	endbr32 
80104edd:	55                   	push   %ebp
80104ede:	89 e5                	mov    %esp,%ebp
80104ee0:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104ee3:	c7 45 fc f4 4d 11 80 	movl   $0x80114df4,-0x4(%ebp)
80104eea:	eb 27                	jmp    80104f13 <wakeup1+0x3a>
    if(p->state == SLEEPING && p->chan == chan)
80104eec:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104eef:	8b 40 0c             	mov    0xc(%eax),%eax
80104ef2:	83 f8 02             	cmp    $0x2,%eax
80104ef5:	75 15                	jne    80104f0c <wakeup1+0x33>
80104ef7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104efa:	8b 40 20             	mov    0x20(%eax),%eax
80104efd:	39 45 08             	cmp    %eax,0x8(%ebp)
80104f00:	75 0a                	jne    80104f0c <wakeup1+0x33>
      p->state = RUNNABLE;
80104f02:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f05:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f0c:	81 45 fc a4 00 00 00 	addl   $0xa4,-0x4(%ebp)
80104f13:	81 7d fc f4 76 11 80 	cmpl   $0x801176f4,-0x4(%ebp)
80104f1a:	72 d0                	jb     80104eec <wakeup1+0x13>
}
80104f1c:	90                   	nop
80104f1d:	90                   	nop
80104f1e:	c9                   	leave  
80104f1f:	c3                   	ret    

80104f20 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104f20:	f3 0f 1e fb          	endbr32 
80104f24:	55                   	push   %ebp
80104f25:	89 e5                	mov    %esp,%ebp
80104f27:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104f2a:	83 ec 0c             	sub    $0xc,%esp
80104f2d:	68 c0 4d 11 80       	push   $0x80114dc0
80104f32:	e8 69 03 00 00       	call   801052a0 <acquire>
80104f37:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104f3a:	83 ec 0c             	sub    $0xc,%esp
80104f3d:	ff 75 08             	pushl  0x8(%ebp)
80104f40:	e8 94 ff ff ff       	call   80104ed9 <wakeup1>
80104f45:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104f48:	83 ec 0c             	sub    $0xc,%esp
80104f4b:	68 c0 4d 11 80       	push   $0x80114dc0
80104f50:	e8 bd 03 00 00       	call   80105312 <release>
80104f55:	83 c4 10             	add    $0x10,%esp
}
80104f58:	90                   	nop
80104f59:	c9                   	leave  
80104f5a:	c3                   	ret    

80104f5b <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104f5b:	f3 0f 1e fb          	endbr32 
80104f5f:	55                   	push   %ebp
80104f60:	89 e5                	mov    %esp,%ebp
80104f62:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104f65:	83 ec 0c             	sub    $0xc,%esp
80104f68:	68 c0 4d 11 80       	push   $0x80114dc0
80104f6d:	e8 2e 03 00 00       	call   801052a0 <acquire>
80104f72:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f75:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104f7c:	eb 48                	jmp    80104fc6 <kill+0x6b>
    if(p->pid == pid){
80104f7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f81:	8b 40 10             	mov    0x10(%eax),%eax
80104f84:	39 45 08             	cmp    %eax,0x8(%ebp)
80104f87:	75 36                	jne    80104fbf <kill+0x64>
      p->killed = 1;
80104f89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f8c:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104f93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f96:	8b 40 0c             	mov    0xc(%eax),%eax
80104f99:	83 f8 02             	cmp    $0x2,%eax
80104f9c:	75 0a                	jne    80104fa8 <kill+0x4d>
        p->state = RUNNABLE;
80104f9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fa1:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104fa8:	83 ec 0c             	sub    $0xc,%esp
80104fab:	68 c0 4d 11 80       	push   $0x80114dc0
80104fb0:	e8 5d 03 00 00       	call   80105312 <release>
80104fb5:	83 c4 10             	add    $0x10,%esp
      return 0;
80104fb8:	b8 00 00 00 00       	mov    $0x0,%eax
80104fbd:	eb 25                	jmp    80104fe4 <kill+0x89>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fbf:	81 45 f4 a4 00 00 00 	addl   $0xa4,-0xc(%ebp)
80104fc6:	81 7d f4 f4 76 11 80 	cmpl   $0x801176f4,-0xc(%ebp)
80104fcd:	72 af                	jb     80104f7e <kill+0x23>
    }
  }
  release(&ptable.lock);
80104fcf:	83 ec 0c             	sub    $0xc,%esp
80104fd2:	68 c0 4d 11 80       	push   $0x80114dc0
80104fd7:	e8 36 03 00 00       	call   80105312 <release>
80104fdc:	83 c4 10             	add    $0x10,%esp
  return -1;
80104fdf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104fe4:	c9                   	leave  
80104fe5:	c3                   	ret    

80104fe6 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104fe6:	f3 0f 1e fb          	endbr32 
80104fea:	55                   	push   %ebp
80104feb:	89 e5                	mov    %esp,%ebp
80104fed:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ff0:	c7 45 f0 f4 4d 11 80 	movl   $0x80114df4,-0x10(%ebp)
80104ff7:	e9 da 00 00 00       	jmp    801050d6 <procdump+0xf0>
    if(p->state == UNUSED)
80104ffc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fff:	8b 40 0c             	mov    0xc(%eax),%eax
80105002:	85 c0                	test   %eax,%eax
80105004:	0f 84 c4 00 00 00    	je     801050ce <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010500a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010500d:	8b 40 0c             	mov    0xc(%eax),%eax
80105010:	83 f8 05             	cmp    $0x5,%eax
80105013:	77 23                	ja     80105038 <procdump+0x52>
80105015:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105018:	8b 40 0c             	mov    0xc(%eax),%eax
8010501b:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80105022:	85 c0                	test   %eax,%eax
80105024:	74 12                	je     80105038 <procdump+0x52>
      state = states[p->state];
80105026:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105029:	8b 40 0c             	mov    0xc(%eax),%eax
8010502c:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80105033:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105036:	eb 07                	jmp    8010503f <procdump+0x59>
    else
      state = "???";
80105038:	c7 45 ec 5a 96 10 80 	movl   $0x8010965a,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
8010503f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105042:	8d 50 6c             	lea    0x6c(%eax),%edx
80105045:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105048:	8b 40 10             	mov    0x10(%eax),%eax
8010504b:	52                   	push   %edx
8010504c:	ff 75 ec             	pushl  -0x14(%ebp)
8010504f:	50                   	push   %eax
80105050:	68 5e 96 10 80       	push   $0x8010965e
80105055:	e8 be b3 ff ff       	call   80100418 <cprintf>
8010505a:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
8010505d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105060:	8b 40 0c             	mov    0xc(%eax),%eax
80105063:	83 f8 02             	cmp    $0x2,%eax
80105066:	75 54                	jne    801050bc <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105068:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010506b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010506e:	8b 40 0c             	mov    0xc(%eax),%eax
80105071:	83 c0 08             	add    $0x8,%eax
80105074:	89 c2                	mov    %eax,%edx
80105076:	83 ec 08             	sub    $0x8,%esp
80105079:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010507c:	50                   	push   %eax
8010507d:	52                   	push   %edx
8010507e:	e8 e5 02 00 00       	call   80105368 <getcallerpcs>
80105083:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105086:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010508d:	eb 1c                	jmp    801050ab <procdump+0xc5>
        cprintf(" %p", pc[i]);
8010508f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105092:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105096:	83 ec 08             	sub    $0x8,%esp
80105099:	50                   	push   %eax
8010509a:	68 67 96 10 80       	push   $0x80109667
8010509f:	e8 74 b3 ff ff       	call   80100418 <cprintf>
801050a4:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801050a7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801050ab:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801050af:	7f 0b                	jg     801050bc <procdump+0xd6>
801050b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050b4:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801050b8:	85 c0                	test   %eax,%eax
801050ba:	75 d3                	jne    8010508f <procdump+0xa9>
    }
    cprintf("\n");
801050bc:	83 ec 0c             	sub    $0xc,%esp
801050bf:	68 6b 96 10 80       	push   $0x8010966b
801050c4:	e8 4f b3 ff ff       	call   80100418 <cprintf>
801050c9:	83 c4 10             	add    $0x10,%esp
801050cc:	eb 01                	jmp    801050cf <procdump+0xe9>
      continue;
801050ce:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801050cf:	81 45 f0 a4 00 00 00 	addl   $0xa4,-0x10(%ebp)
801050d6:	81 7d f0 f4 76 11 80 	cmpl   $0x801176f4,-0x10(%ebp)
801050dd:	0f 82 19 ff ff ff    	jb     80104ffc <procdump+0x16>
  }
}
801050e3:	90                   	nop
801050e4:	90                   	nop
801050e5:	c9                   	leave  
801050e6:	c3                   	ret    

801050e7 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801050e7:	f3 0f 1e fb          	endbr32 
801050eb:	55                   	push   %ebp
801050ec:	89 e5                	mov    %esp,%ebp
801050ee:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
801050f1:	8b 45 08             	mov    0x8(%ebp),%eax
801050f4:	83 c0 04             	add    $0x4,%eax
801050f7:	83 ec 08             	sub    $0x8,%esp
801050fa:	68 97 96 10 80       	push   $0x80109697
801050ff:	50                   	push   %eax
80105100:	e8 75 01 00 00       	call   8010527a <initlock>
80105105:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80105108:	8b 45 08             	mov    0x8(%ebp),%eax
8010510b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010510e:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80105111:	8b 45 08             	mov    0x8(%ebp),%eax
80105114:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010511a:	8b 45 08             	mov    0x8(%ebp),%eax
8010511d:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80105124:	90                   	nop
80105125:	c9                   	leave  
80105126:	c3                   	ret    

80105127 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80105127:	f3 0f 1e fb          	endbr32 
8010512b:	55                   	push   %ebp
8010512c:	89 e5                	mov    %esp,%ebp
8010512e:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80105131:	8b 45 08             	mov    0x8(%ebp),%eax
80105134:	83 c0 04             	add    $0x4,%eax
80105137:	83 ec 0c             	sub    $0xc,%esp
8010513a:	50                   	push   %eax
8010513b:	e8 60 01 00 00       	call   801052a0 <acquire>
80105140:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80105143:	eb 15                	jmp    8010515a <acquiresleep+0x33>
    sleep(lk, &lk->lk);
80105145:	8b 45 08             	mov    0x8(%ebp),%eax
80105148:	83 c0 04             	add    $0x4,%eax
8010514b:	83 ec 08             	sub    $0x8,%esp
8010514e:	50                   	push   %eax
8010514f:	ff 75 08             	pushl  0x8(%ebp)
80105152:	e8 d7 fc ff ff       	call   80104e2e <sleep>
80105157:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
8010515a:	8b 45 08             	mov    0x8(%ebp),%eax
8010515d:	8b 00                	mov    (%eax),%eax
8010515f:	85 c0                	test   %eax,%eax
80105161:	75 e2                	jne    80105145 <acquiresleep+0x1e>
  }
  lk->locked = 1;
80105163:	8b 45 08             	mov    0x8(%ebp),%eax
80105166:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
8010516c:	e8 8f f3 ff ff       	call   80104500 <myproc>
80105171:	8b 50 10             	mov    0x10(%eax),%edx
80105174:	8b 45 08             	mov    0x8(%ebp),%eax
80105177:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
8010517a:	8b 45 08             	mov    0x8(%ebp),%eax
8010517d:	83 c0 04             	add    $0x4,%eax
80105180:	83 ec 0c             	sub    $0xc,%esp
80105183:	50                   	push   %eax
80105184:	e8 89 01 00 00       	call   80105312 <release>
80105189:	83 c4 10             	add    $0x10,%esp
}
8010518c:	90                   	nop
8010518d:	c9                   	leave  
8010518e:	c3                   	ret    

8010518f <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
8010518f:	f3 0f 1e fb          	endbr32 
80105193:	55                   	push   %ebp
80105194:	89 e5                	mov    %esp,%ebp
80105196:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80105199:	8b 45 08             	mov    0x8(%ebp),%eax
8010519c:	83 c0 04             	add    $0x4,%eax
8010519f:	83 ec 0c             	sub    $0xc,%esp
801051a2:	50                   	push   %eax
801051a3:	e8 f8 00 00 00       	call   801052a0 <acquire>
801051a8:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
801051ab:	8b 45 08             	mov    0x8(%ebp),%eax
801051ae:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801051b4:	8b 45 08             	mov    0x8(%ebp),%eax
801051b7:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
801051be:	83 ec 0c             	sub    $0xc,%esp
801051c1:	ff 75 08             	pushl  0x8(%ebp)
801051c4:	e8 57 fd ff ff       	call   80104f20 <wakeup>
801051c9:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
801051cc:	8b 45 08             	mov    0x8(%ebp),%eax
801051cf:	83 c0 04             	add    $0x4,%eax
801051d2:	83 ec 0c             	sub    $0xc,%esp
801051d5:	50                   	push   %eax
801051d6:	e8 37 01 00 00       	call   80105312 <release>
801051db:	83 c4 10             	add    $0x10,%esp
}
801051de:	90                   	nop
801051df:	c9                   	leave  
801051e0:	c3                   	ret    

801051e1 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801051e1:	f3 0f 1e fb          	endbr32 
801051e5:	55                   	push   %ebp
801051e6:	89 e5                	mov    %esp,%ebp
801051e8:	53                   	push   %ebx
801051e9:	83 ec 14             	sub    $0x14,%esp
  int r;
  
  acquire(&lk->lk);
801051ec:	8b 45 08             	mov    0x8(%ebp),%eax
801051ef:	83 c0 04             	add    $0x4,%eax
801051f2:	83 ec 0c             	sub    $0xc,%esp
801051f5:	50                   	push   %eax
801051f6:	e8 a5 00 00 00       	call   801052a0 <acquire>
801051fb:	83 c4 10             	add    $0x10,%esp
  r = lk->locked && (lk->pid == myproc()->pid);
801051fe:	8b 45 08             	mov    0x8(%ebp),%eax
80105201:	8b 00                	mov    (%eax),%eax
80105203:	85 c0                	test   %eax,%eax
80105205:	74 19                	je     80105220 <holdingsleep+0x3f>
80105207:	8b 45 08             	mov    0x8(%ebp),%eax
8010520a:	8b 58 3c             	mov    0x3c(%eax),%ebx
8010520d:	e8 ee f2 ff ff       	call   80104500 <myproc>
80105212:	8b 40 10             	mov    0x10(%eax),%eax
80105215:	39 c3                	cmp    %eax,%ebx
80105217:	75 07                	jne    80105220 <holdingsleep+0x3f>
80105219:	b8 01 00 00 00       	mov    $0x1,%eax
8010521e:	eb 05                	jmp    80105225 <holdingsleep+0x44>
80105220:	b8 00 00 00 00       	mov    $0x0,%eax
80105225:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80105228:	8b 45 08             	mov    0x8(%ebp),%eax
8010522b:	83 c0 04             	add    $0x4,%eax
8010522e:	83 ec 0c             	sub    $0xc,%esp
80105231:	50                   	push   %eax
80105232:	e8 db 00 00 00       	call   80105312 <release>
80105237:	83 c4 10             	add    $0x10,%esp
  return r;
8010523a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010523d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105240:	c9                   	leave  
80105241:	c3                   	ret    

80105242 <readeflags>:
{
80105242:	55                   	push   %ebp
80105243:	89 e5                	mov    %esp,%ebp
80105245:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105248:	9c                   	pushf  
80105249:	58                   	pop    %eax
8010524a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010524d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105250:	c9                   	leave  
80105251:	c3                   	ret    

80105252 <cli>:
{
80105252:	55                   	push   %ebp
80105253:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105255:	fa                   	cli    
}
80105256:	90                   	nop
80105257:	5d                   	pop    %ebp
80105258:	c3                   	ret    

80105259 <sti>:
{
80105259:	55                   	push   %ebp
8010525a:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010525c:	fb                   	sti    
}
8010525d:	90                   	nop
8010525e:	5d                   	pop    %ebp
8010525f:	c3                   	ret    

80105260 <xchg>:
{
80105260:	55                   	push   %ebp
80105261:	89 e5                	mov    %esp,%ebp
80105263:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80105266:	8b 55 08             	mov    0x8(%ebp),%edx
80105269:	8b 45 0c             	mov    0xc(%ebp),%eax
8010526c:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010526f:	f0 87 02             	lock xchg %eax,(%edx)
80105272:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80105275:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105278:	c9                   	leave  
80105279:	c3                   	ret    

8010527a <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010527a:	f3 0f 1e fb          	endbr32 
8010527e:	55                   	push   %ebp
8010527f:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105281:	8b 45 08             	mov    0x8(%ebp),%eax
80105284:	8b 55 0c             	mov    0xc(%ebp),%edx
80105287:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
8010528a:	8b 45 08             	mov    0x8(%ebp),%eax
8010528d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105293:	8b 45 08             	mov    0x8(%ebp),%eax
80105296:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
8010529d:	90                   	nop
8010529e:	5d                   	pop    %ebp
8010529f:	c3                   	ret    

801052a0 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801052a0:	f3 0f 1e fb          	endbr32 
801052a4:	55                   	push   %ebp
801052a5:	89 e5                	mov    %esp,%ebp
801052a7:	53                   	push   %ebx
801052a8:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801052ab:	e8 7c 01 00 00       	call   8010542c <pushcli>
  if(holding(lk))
801052b0:	8b 45 08             	mov    0x8(%ebp),%eax
801052b3:	83 ec 0c             	sub    $0xc,%esp
801052b6:	50                   	push   %eax
801052b7:	e8 2b 01 00 00       	call   801053e7 <holding>
801052bc:	83 c4 10             	add    $0x10,%esp
801052bf:	85 c0                	test   %eax,%eax
801052c1:	74 0d                	je     801052d0 <acquire+0x30>
    panic("acquire");
801052c3:	83 ec 0c             	sub    $0xc,%esp
801052c6:	68 a2 96 10 80       	push   $0x801096a2
801052cb:	e8 38 b3 ff ff       	call   80100608 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
801052d0:	90                   	nop
801052d1:	8b 45 08             	mov    0x8(%ebp),%eax
801052d4:	83 ec 08             	sub    $0x8,%esp
801052d7:	6a 01                	push   $0x1
801052d9:	50                   	push   %eax
801052da:	e8 81 ff ff ff       	call   80105260 <xchg>
801052df:	83 c4 10             	add    $0x10,%esp
801052e2:	85 c0                	test   %eax,%eax
801052e4:	75 eb                	jne    801052d1 <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
801052e6:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
801052eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
801052ee:	e8 91 f1 ff ff       	call   80104484 <mycpu>
801052f3:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
801052f6:	8b 45 08             	mov    0x8(%ebp),%eax
801052f9:	83 c0 0c             	add    $0xc,%eax
801052fc:	83 ec 08             	sub    $0x8,%esp
801052ff:	50                   	push   %eax
80105300:	8d 45 08             	lea    0x8(%ebp),%eax
80105303:	50                   	push   %eax
80105304:	e8 5f 00 00 00       	call   80105368 <getcallerpcs>
80105309:	83 c4 10             	add    $0x10,%esp
}
8010530c:	90                   	nop
8010530d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105310:	c9                   	leave  
80105311:	c3                   	ret    

80105312 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105312:	f3 0f 1e fb          	endbr32 
80105316:	55                   	push   %ebp
80105317:	89 e5                	mov    %esp,%ebp
80105319:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
8010531c:	83 ec 0c             	sub    $0xc,%esp
8010531f:	ff 75 08             	pushl  0x8(%ebp)
80105322:	e8 c0 00 00 00       	call   801053e7 <holding>
80105327:	83 c4 10             	add    $0x10,%esp
8010532a:	85 c0                	test   %eax,%eax
8010532c:	75 0d                	jne    8010533b <release+0x29>
    panic("release");
8010532e:	83 ec 0c             	sub    $0xc,%esp
80105331:	68 aa 96 10 80       	push   $0x801096aa
80105336:	e8 cd b2 ff ff       	call   80100608 <panic>

  lk->pcs[0] = 0;
8010533b:	8b 45 08             	mov    0x8(%ebp),%eax
8010533e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105345:	8b 45 08             	mov    0x8(%ebp),%eax
80105348:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
8010534f:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80105354:	8b 45 08             	mov    0x8(%ebp),%eax
80105357:	8b 55 08             	mov    0x8(%ebp),%edx
8010535a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80105360:	e8 18 01 00 00       	call   8010547d <popcli>
}
80105365:	90                   	nop
80105366:	c9                   	leave  
80105367:	c3                   	ret    

80105368 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105368:	f3 0f 1e fb          	endbr32 
8010536c:	55                   	push   %ebp
8010536d:	89 e5                	mov    %esp,%ebp
8010536f:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80105372:	8b 45 08             	mov    0x8(%ebp),%eax
80105375:	83 e8 08             	sub    $0x8,%eax
80105378:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010537b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105382:	eb 38                	jmp    801053bc <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105384:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105388:	74 53                	je     801053dd <getcallerpcs+0x75>
8010538a:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105391:	76 4a                	jbe    801053dd <getcallerpcs+0x75>
80105393:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105397:	74 44                	je     801053dd <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105399:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010539c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801053a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801053a6:	01 c2                	add    %eax,%edx
801053a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053ab:	8b 40 04             	mov    0x4(%eax),%eax
801053ae:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801053b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053b3:	8b 00                	mov    (%eax),%eax
801053b5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801053b8:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801053bc:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801053c0:	7e c2                	jle    80105384 <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
801053c2:	eb 19                	jmp    801053dd <getcallerpcs+0x75>
    pcs[i] = 0;
801053c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053c7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801053ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801053d1:	01 d0                	add    %edx,%eax
801053d3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
801053d9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801053dd:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801053e1:	7e e1                	jle    801053c4 <getcallerpcs+0x5c>
}
801053e3:	90                   	nop
801053e4:	90                   	nop
801053e5:	c9                   	leave  
801053e6:	c3                   	ret    

801053e7 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801053e7:	f3 0f 1e fb          	endbr32 
801053eb:	55                   	push   %ebp
801053ec:	89 e5                	mov    %esp,%ebp
801053ee:	53                   	push   %ebx
801053ef:	83 ec 14             	sub    $0x14,%esp
  int r;
  pushcli();
801053f2:	e8 35 00 00 00       	call   8010542c <pushcli>
  r = lock->locked && lock->cpu == mycpu();
801053f7:	8b 45 08             	mov    0x8(%ebp),%eax
801053fa:	8b 00                	mov    (%eax),%eax
801053fc:	85 c0                	test   %eax,%eax
801053fe:	74 16                	je     80105416 <holding+0x2f>
80105400:	8b 45 08             	mov    0x8(%ebp),%eax
80105403:	8b 58 08             	mov    0x8(%eax),%ebx
80105406:	e8 79 f0 ff ff       	call   80104484 <mycpu>
8010540b:	39 c3                	cmp    %eax,%ebx
8010540d:	75 07                	jne    80105416 <holding+0x2f>
8010540f:	b8 01 00 00 00       	mov    $0x1,%eax
80105414:	eb 05                	jmp    8010541b <holding+0x34>
80105416:	b8 00 00 00 00       	mov    $0x0,%eax
8010541b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  popcli();
8010541e:	e8 5a 00 00 00       	call   8010547d <popcli>
  return r;
80105423:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105426:	83 c4 14             	add    $0x14,%esp
80105429:	5b                   	pop    %ebx
8010542a:	5d                   	pop    %ebp
8010542b:	c3                   	ret    

8010542c <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
8010542c:	f3 0f 1e fb          	endbr32 
80105430:	55                   	push   %ebp
80105431:	89 e5                	mov    %esp,%ebp
80105433:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80105436:	e8 07 fe ff ff       	call   80105242 <readeflags>
8010543b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
8010543e:	e8 0f fe ff ff       	call   80105252 <cli>
  if(mycpu()->ncli == 0)
80105443:	e8 3c f0 ff ff       	call   80104484 <mycpu>
80105448:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010544e:	85 c0                	test   %eax,%eax
80105450:	75 14                	jne    80105466 <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
80105452:	e8 2d f0 ff ff       	call   80104484 <mycpu>
80105457:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010545a:	81 e2 00 02 00 00    	and    $0x200,%edx
80105460:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80105466:	e8 19 f0 ff ff       	call   80104484 <mycpu>
8010546b:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105471:	83 c2 01             	add    $0x1,%edx
80105474:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
8010547a:	90                   	nop
8010547b:	c9                   	leave  
8010547c:	c3                   	ret    

8010547d <popcli>:

void
popcli(void)
{
8010547d:	f3 0f 1e fb          	endbr32 
80105481:	55                   	push   %ebp
80105482:	89 e5                	mov    %esp,%ebp
80105484:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105487:	e8 b6 fd ff ff       	call   80105242 <readeflags>
8010548c:	25 00 02 00 00       	and    $0x200,%eax
80105491:	85 c0                	test   %eax,%eax
80105493:	74 0d                	je     801054a2 <popcli+0x25>
    panic("popcli - interruptible");
80105495:	83 ec 0c             	sub    $0xc,%esp
80105498:	68 b2 96 10 80       	push   $0x801096b2
8010549d:	e8 66 b1 ff ff       	call   80100608 <panic>
  if(--mycpu()->ncli < 0)
801054a2:	e8 dd ef ff ff       	call   80104484 <mycpu>
801054a7:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801054ad:	83 ea 01             	sub    $0x1,%edx
801054b0:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
801054b6:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801054bc:	85 c0                	test   %eax,%eax
801054be:	79 0d                	jns    801054cd <popcli+0x50>
    panic("popcli");
801054c0:	83 ec 0c             	sub    $0xc,%esp
801054c3:	68 c9 96 10 80       	push   $0x801096c9
801054c8:	e8 3b b1 ff ff       	call   80100608 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
801054cd:	e8 b2 ef ff ff       	call   80104484 <mycpu>
801054d2:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801054d8:	85 c0                	test   %eax,%eax
801054da:	75 14                	jne    801054f0 <popcli+0x73>
801054dc:	e8 a3 ef ff ff       	call   80104484 <mycpu>
801054e1:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801054e7:	85 c0                	test   %eax,%eax
801054e9:	74 05                	je     801054f0 <popcli+0x73>
    sti();
801054eb:	e8 69 fd ff ff       	call   80105259 <sti>
}
801054f0:	90                   	nop
801054f1:	c9                   	leave  
801054f2:	c3                   	ret    

801054f3 <stosb>:
{
801054f3:	55                   	push   %ebp
801054f4:	89 e5                	mov    %esp,%ebp
801054f6:	57                   	push   %edi
801054f7:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801054f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
801054fb:	8b 55 10             	mov    0x10(%ebp),%edx
801054fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80105501:	89 cb                	mov    %ecx,%ebx
80105503:	89 df                	mov    %ebx,%edi
80105505:	89 d1                	mov    %edx,%ecx
80105507:	fc                   	cld    
80105508:	f3 aa                	rep stos %al,%es:(%edi)
8010550a:	89 ca                	mov    %ecx,%edx
8010550c:	89 fb                	mov    %edi,%ebx
8010550e:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105511:	89 55 10             	mov    %edx,0x10(%ebp)
}
80105514:	90                   	nop
80105515:	5b                   	pop    %ebx
80105516:	5f                   	pop    %edi
80105517:	5d                   	pop    %ebp
80105518:	c3                   	ret    

80105519 <stosl>:
{
80105519:	55                   	push   %ebp
8010551a:	89 e5                	mov    %esp,%ebp
8010551c:	57                   	push   %edi
8010551d:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010551e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105521:	8b 55 10             	mov    0x10(%ebp),%edx
80105524:	8b 45 0c             	mov    0xc(%ebp),%eax
80105527:	89 cb                	mov    %ecx,%ebx
80105529:	89 df                	mov    %ebx,%edi
8010552b:	89 d1                	mov    %edx,%ecx
8010552d:	fc                   	cld    
8010552e:	f3 ab                	rep stos %eax,%es:(%edi)
80105530:	89 ca                	mov    %ecx,%edx
80105532:	89 fb                	mov    %edi,%ebx
80105534:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105537:	89 55 10             	mov    %edx,0x10(%ebp)
}
8010553a:	90                   	nop
8010553b:	5b                   	pop    %ebx
8010553c:	5f                   	pop    %edi
8010553d:	5d                   	pop    %ebp
8010553e:	c3                   	ret    

8010553f <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
8010553f:	f3 0f 1e fb          	endbr32 
80105543:	55                   	push   %ebp
80105544:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105546:	8b 45 08             	mov    0x8(%ebp),%eax
80105549:	83 e0 03             	and    $0x3,%eax
8010554c:	85 c0                	test   %eax,%eax
8010554e:	75 43                	jne    80105593 <memset+0x54>
80105550:	8b 45 10             	mov    0x10(%ebp),%eax
80105553:	83 e0 03             	and    $0x3,%eax
80105556:	85 c0                	test   %eax,%eax
80105558:	75 39                	jne    80105593 <memset+0x54>
    c &= 0xFF;
8010555a:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105561:	8b 45 10             	mov    0x10(%ebp),%eax
80105564:	c1 e8 02             	shr    $0x2,%eax
80105567:	89 c1                	mov    %eax,%ecx
80105569:	8b 45 0c             	mov    0xc(%ebp),%eax
8010556c:	c1 e0 18             	shl    $0x18,%eax
8010556f:	89 c2                	mov    %eax,%edx
80105571:	8b 45 0c             	mov    0xc(%ebp),%eax
80105574:	c1 e0 10             	shl    $0x10,%eax
80105577:	09 c2                	or     %eax,%edx
80105579:	8b 45 0c             	mov    0xc(%ebp),%eax
8010557c:	c1 e0 08             	shl    $0x8,%eax
8010557f:	09 d0                	or     %edx,%eax
80105581:	0b 45 0c             	or     0xc(%ebp),%eax
80105584:	51                   	push   %ecx
80105585:	50                   	push   %eax
80105586:	ff 75 08             	pushl  0x8(%ebp)
80105589:	e8 8b ff ff ff       	call   80105519 <stosl>
8010558e:	83 c4 0c             	add    $0xc,%esp
80105591:	eb 12                	jmp    801055a5 <memset+0x66>
  } else
    stosb(dst, c, n);
80105593:	8b 45 10             	mov    0x10(%ebp),%eax
80105596:	50                   	push   %eax
80105597:	ff 75 0c             	pushl  0xc(%ebp)
8010559a:	ff 75 08             	pushl  0x8(%ebp)
8010559d:	e8 51 ff ff ff       	call   801054f3 <stosb>
801055a2:	83 c4 0c             	add    $0xc,%esp
  return dst;
801055a5:	8b 45 08             	mov    0x8(%ebp),%eax
}
801055a8:	c9                   	leave  
801055a9:	c3                   	ret    

801055aa <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801055aa:	f3 0f 1e fb          	endbr32 
801055ae:	55                   	push   %ebp
801055af:	89 e5                	mov    %esp,%ebp
801055b1:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
801055b4:	8b 45 08             	mov    0x8(%ebp),%eax
801055b7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801055ba:	8b 45 0c             	mov    0xc(%ebp),%eax
801055bd:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801055c0:	eb 30                	jmp    801055f2 <memcmp+0x48>
    if(*s1 != *s2)
801055c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055c5:	0f b6 10             	movzbl (%eax),%edx
801055c8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801055cb:	0f b6 00             	movzbl (%eax),%eax
801055ce:	38 c2                	cmp    %al,%dl
801055d0:	74 18                	je     801055ea <memcmp+0x40>
      return *s1 - *s2;
801055d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055d5:	0f b6 00             	movzbl (%eax),%eax
801055d8:	0f b6 d0             	movzbl %al,%edx
801055db:	8b 45 f8             	mov    -0x8(%ebp),%eax
801055de:	0f b6 00             	movzbl (%eax),%eax
801055e1:	0f b6 c0             	movzbl %al,%eax
801055e4:	29 c2                	sub    %eax,%edx
801055e6:	89 d0                	mov    %edx,%eax
801055e8:	eb 1a                	jmp    80105604 <memcmp+0x5a>
    s1++, s2++;
801055ea:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801055ee:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
801055f2:	8b 45 10             	mov    0x10(%ebp),%eax
801055f5:	8d 50 ff             	lea    -0x1(%eax),%edx
801055f8:	89 55 10             	mov    %edx,0x10(%ebp)
801055fb:	85 c0                	test   %eax,%eax
801055fd:	75 c3                	jne    801055c2 <memcmp+0x18>
  }

  return 0;
801055ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105604:	c9                   	leave  
80105605:	c3                   	ret    

80105606 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105606:	f3 0f 1e fb          	endbr32 
8010560a:	55                   	push   %ebp
8010560b:	89 e5                	mov    %esp,%ebp
8010560d:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105610:	8b 45 0c             	mov    0xc(%ebp),%eax
80105613:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105616:	8b 45 08             	mov    0x8(%ebp),%eax
80105619:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
8010561c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010561f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105622:	73 54                	jae    80105678 <memmove+0x72>
80105624:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105627:	8b 45 10             	mov    0x10(%ebp),%eax
8010562a:	01 d0                	add    %edx,%eax
8010562c:	39 45 f8             	cmp    %eax,-0x8(%ebp)
8010562f:	73 47                	jae    80105678 <memmove+0x72>
    s += n;
80105631:	8b 45 10             	mov    0x10(%ebp),%eax
80105634:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105637:	8b 45 10             	mov    0x10(%ebp),%eax
8010563a:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
8010563d:	eb 13                	jmp    80105652 <memmove+0x4c>
      *--d = *--s;
8010563f:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105643:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105647:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010564a:	0f b6 10             	movzbl (%eax),%edx
8010564d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105650:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105652:	8b 45 10             	mov    0x10(%ebp),%eax
80105655:	8d 50 ff             	lea    -0x1(%eax),%edx
80105658:	89 55 10             	mov    %edx,0x10(%ebp)
8010565b:	85 c0                	test   %eax,%eax
8010565d:	75 e0                	jne    8010563f <memmove+0x39>
  if(s < d && s + n > d){
8010565f:	eb 24                	jmp    80105685 <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
80105661:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105664:	8d 42 01             	lea    0x1(%edx),%eax
80105667:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010566a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010566d:	8d 48 01             	lea    0x1(%eax),%ecx
80105670:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80105673:	0f b6 12             	movzbl (%edx),%edx
80105676:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105678:	8b 45 10             	mov    0x10(%ebp),%eax
8010567b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010567e:	89 55 10             	mov    %edx,0x10(%ebp)
80105681:	85 c0                	test   %eax,%eax
80105683:	75 dc                	jne    80105661 <memmove+0x5b>

  return dst;
80105685:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105688:	c9                   	leave  
80105689:	c3                   	ret    

8010568a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
8010568a:	f3 0f 1e fb          	endbr32 
8010568e:	55                   	push   %ebp
8010568f:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105691:	ff 75 10             	pushl  0x10(%ebp)
80105694:	ff 75 0c             	pushl  0xc(%ebp)
80105697:	ff 75 08             	pushl  0x8(%ebp)
8010569a:	e8 67 ff ff ff       	call   80105606 <memmove>
8010569f:	83 c4 0c             	add    $0xc,%esp
}
801056a2:	c9                   	leave  
801056a3:	c3                   	ret    

801056a4 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801056a4:	f3 0f 1e fb          	endbr32 
801056a8:	55                   	push   %ebp
801056a9:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801056ab:	eb 0c                	jmp    801056b9 <strncmp+0x15>
    n--, p++, q++;
801056ad:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801056b1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801056b5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
801056b9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801056bd:	74 1a                	je     801056d9 <strncmp+0x35>
801056bf:	8b 45 08             	mov    0x8(%ebp),%eax
801056c2:	0f b6 00             	movzbl (%eax),%eax
801056c5:	84 c0                	test   %al,%al
801056c7:	74 10                	je     801056d9 <strncmp+0x35>
801056c9:	8b 45 08             	mov    0x8(%ebp),%eax
801056cc:	0f b6 10             	movzbl (%eax),%edx
801056cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801056d2:	0f b6 00             	movzbl (%eax),%eax
801056d5:	38 c2                	cmp    %al,%dl
801056d7:	74 d4                	je     801056ad <strncmp+0x9>
  if(n == 0)
801056d9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801056dd:	75 07                	jne    801056e6 <strncmp+0x42>
    return 0;
801056df:	b8 00 00 00 00       	mov    $0x0,%eax
801056e4:	eb 16                	jmp    801056fc <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
801056e6:	8b 45 08             	mov    0x8(%ebp),%eax
801056e9:	0f b6 00             	movzbl (%eax),%eax
801056ec:	0f b6 d0             	movzbl %al,%edx
801056ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801056f2:	0f b6 00             	movzbl (%eax),%eax
801056f5:	0f b6 c0             	movzbl %al,%eax
801056f8:	29 c2                	sub    %eax,%edx
801056fa:	89 d0                	mov    %edx,%eax
}
801056fc:	5d                   	pop    %ebp
801056fd:	c3                   	ret    

801056fe <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801056fe:	f3 0f 1e fb          	endbr32 
80105702:	55                   	push   %ebp
80105703:	89 e5                	mov    %esp,%ebp
80105705:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105708:	8b 45 08             	mov    0x8(%ebp),%eax
8010570b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010570e:	90                   	nop
8010570f:	8b 45 10             	mov    0x10(%ebp),%eax
80105712:	8d 50 ff             	lea    -0x1(%eax),%edx
80105715:	89 55 10             	mov    %edx,0x10(%ebp)
80105718:	85 c0                	test   %eax,%eax
8010571a:	7e 2c                	jle    80105748 <strncpy+0x4a>
8010571c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010571f:	8d 42 01             	lea    0x1(%edx),%eax
80105722:	89 45 0c             	mov    %eax,0xc(%ebp)
80105725:	8b 45 08             	mov    0x8(%ebp),%eax
80105728:	8d 48 01             	lea    0x1(%eax),%ecx
8010572b:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010572e:	0f b6 12             	movzbl (%edx),%edx
80105731:	88 10                	mov    %dl,(%eax)
80105733:	0f b6 00             	movzbl (%eax),%eax
80105736:	84 c0                	test   %al,%al
80105738:	75 d5                	jne    8010570f <strncpy+0x11>
    ;
  while(n-- > 0)
8010573a:	eb 0c                	jmp    80105748 <strncpy+0x4a>
    *s++ = 0;
8010573c:	8b 45 08             	mov    0x8(%ebp),%eax
8010573f:	8d 50 01             	lea    0x1(%eax),%edx
80105742:	89 55 08             	mov    %edx,0x8(%ebp)
80105745:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80105748:	8b 45 10             	mov    0x10(%ebp),%eax
8010574b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010574e:	89 55 10             	mov    %edx,0x10(%ebp)
80105751:	85 c0                	test   %eax,%eax
80105753:	7f e7                	jg     8010573c <strncpy+0x3e>
  return os;
80105755:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105758:	c9                   	leave  
80105759:	c3                   	ret    

8010575a <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010575a:	f3 0f 1e fb          	endbr32 
8010575e:	55                   	push   %ebp
8010575f:	89 e5                	mov    %esp,%ebp
80105761:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105764:	8b 45 08             	mov    0x8(%ebp),%eax
80105767:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010576a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010576e:	7f 05                	jg     80105775 <safestrcpy+0x1b>
    return os;
80105770:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105773:	eb 31                	jmp    801057a6 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80105775:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105779:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010577d:	7e 1e                	jle    8010579d <safestrcpy+0x43>
8010577f:	8b 55 0c             	mov    0xc(%ebp),%edx
80105782:	8d 42 01             	lea    0x1(%edx),%eax
80105785:	89 45 0c             	mov    %eax,0xc(%ebp)
80105788:	8b 45 08             	mov    0x8(%ebp),%eax
8010578b:	8d 48 01             	lea    0x1(%eax),%ecx
8010578e:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105791:	0f b6 12             	movzbl (%edx),%edx
80105794:	88 10                	mov    %dl,(%eax)
80105796:	0f b6 00             	movzbl (%eax),%eax
80105799:	84 c0                	test   %al,%al
8010579b:	75 d8                	jne    80105775 <safestrcpy+0x1b>
    ;
  *s = 0;
8010579d:	8b 45 08             	mov    0x8(%ebp),%eax
801057a0:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801057a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801057a6:	c9                   	leave  
801057a7:	c3                   	ret    

801057a8 <strlen>:

int
strlen(const char *s)
{
801057a8:	f3 0f 1e fb          	endbr32 
801057ac:	55                   	push   %ebp
801057ad:	89 e5                	mov    %esp,%ebp
801057af:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801057b2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801057b9:	eb 04                	jmp    801057bf <strlen+0x17>
801057bb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801057bf:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057c2:	8b 45 08             	mov    0x8(%ebp),%eax
801057c5:	01 d0                	add    %edx,%eax
801057c7:	0f b6 00             	movzbl (%eax),%eax
801057ca:	84 c0                	test   %al,%al
801057cc:	75 ed                	jne    801057bb <strlen+0x13>
    ;
  return n;
801057ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801057d1:	c9                   	leave  
801057d2:	c3                   	ret    

801057d3 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801057d3:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801057d7:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
801057db:	55                   	push   %ebp
  pushl %ebx
801057dc:	53                   	push   %ebx
  pushl %esi
801057dd:	56                   	push   %esi
  pushl %edi
801057de:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801057df:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801057e1:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
801057e3:	5f                   	pop    %edi
  popl %esi
801057e4:	5e                   	pop    %esi
  popl %ebx
801057e5:	5b                   	pop    %ebx
  popl %ebp
801057e6:	5d                   	pop    %ebp
  ret
801057e7:	c3                   	ret    

801057e8 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801057e8:	f3 0f 1e fb          	endbr32 
801057ec:	55                   	push   %ebp
801057ed:	89 e5                	mov    %esp,%ebp
801057ef:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801057f2:	e8 09 ed ff ff       	call   80104500 <myproc>
801057f7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801057fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057fd:	8b 00                	mov    (%eax),%eax
801057ff:	39 45 08             	cmp    %eax,0x8(%ebp)
80105802:	73 0f                	jae    80105813 <fetchint+0x2b>
80105804:	8b 45 08             	mov    0x8(%ebp),%eax
80105807:	8d 50 04             	lea    0x4(%eax),%edx
8010580a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010580d:	8b 00                	mov    (%eax),%eax
8010580f:	39 c2                	cmp    %eax,%edx
80105811:	76 07                	jbe    8010581a <fetchint+0x32>
    return -1;
80105813:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105818:	eb 0f                	jmp    80105829 <fetchint+0x41>
  *ip = *(int*)(addr);
8010581a:	8b 45 08             	mov    0x8(%ebp),%eax
8010581d:	8b 10                	mov    (%eax),%edx
8010581f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105822:	89 10                	mov    %edx,(%eax)
  return 0;
80105824:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105829:	c9                   	leave  
8010582a:	c3                   	ret    

8010582b <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010582b:	f3 0f 1e fb          	endbr32 
8010582f:	55                   	push   %ebp
80105830:	89 e5                	mov    %esp,%ebp
80105832:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105835:	e8 c6 ec ff ff       	call   80104500 <myproc>
8010583a:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
8010583d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105840:	8b 00                	mov    (%eax),%eax
80105842:	39 45 08             	cmp    %eax,0x8(%ebp)
80105845:	72 07                	jb     8010584e <fetchstr+0x23>
    return -1;
80105847:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010584c:	eb 43                	jmp    80105891 <fetchstr+0x66>
  *pp = (char*)addr;
8010584e:	8b 55 08             	mov    0x8(%ebp),%edx
80105851:	8b 45 0c             	mov    0xc(%ebp),%eax
80105854:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105856:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105859:	8b 00                	mov    (%eax),%eax
8010585b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
8010585e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105861:	8b 00                	mov    (%eax),%eax
80105863:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105866:	eb 1c                	jmp    80105884 <fetchstr+0x59>
    if(*s == 0)
80105868:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010586b:	0f b6 00             	movzbl (%eax),%eax
8010586e:	84 c0                	test   %al,%al
80105870:	75 0e                	jne    80105880 <fetchstr+0x55>
      return s - *pp;
80105872:	8b 45 0c             	mov    0xc(%ebp),%eax
80105875:	8b 00                	mov    (%eax),%eax
80105877:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010587a:	29 c2                	sub    %eax,%edx
8010587c:	89 d0                	mov    %edx,%eax
8010587e:	eb 11                	jmp    80105891 <fetchstr+0x66>
  for(s = *pp; s < ep; s++){
80105880:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105884:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105887:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010588a:	72 dc                	jb     80105868 <fetchstr+0x3d>
  }
  return -1;
8010588c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105891:	c9                   	leave  
80105892:	c3                   	ret    

80105893 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105893:	f3 0f 1e fb          	endbr32 
80105897:	55                   	push   %ebp
80105898:	89 e5                	mov    %esp,%ebp
8010589a:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
8010589d:	e8 5e ec ff ff       	call   80104500 <myproc>
801058a2:	8b 40 18             	mov    0x18(%eax),%eax
801058a5:	8b 40 44             	mov    0x44(%eax),%eax
801058a8:	8b 55 08             	mov    0x8(%ebp),%edx
801058ab:	c1 e2 02             	shl    $0x2,%edx
801058ae:	01 d0                	add    %edx,%eax
801058b0:	83 c0 04             	add    $0x4,%eax
801058b3:	83 ec 08             	sub    $0x8,%esp
801058b6:	ff 75 0c             	pushl  0xc(%ebp)
801058b9:	50                   	push   %eax
801058ba:	e8 29 ff ff ff       	call   801057e8 <fetchint>
801058bf:	83 c4 10             	add    $0x10,%esp
}
801058c2:	c9                   	leave  
801058c3:	c3                   	ret    

801058c4 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801058c4:	f3 0f 1e fb          	endbr32 
801058c8:	55                   	push   %ebp
801058c9:	89 e5                	mov    %esp,%ebp
801058cb:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
801058ce:	e8 2d ec ff ff       	call   80104500 <myproc>
801058d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
801058d6:	83 ec 08             	sub    $0x8,%esp
801058d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058dc:	50                   	push   %eax
801058dd:	ff 75 08             	pushl  0x8(%ebp)
801058e0:	e8 ae ff ff ff       	call   80105893 <argint>
801058e5:	83 c4 10             	add    $0x10,%esp
801058e8:	85 c0                	test   %eax,%eax
801058ea:	79 07                	jns    801058f3 <argptr+0x2f>
    return -1;
801058ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058f1:	eb 3b                	jmp    8010592e <argptr+0x6a>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
801058f3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801058f7:	78 1f                	js     80105918 <argptr+0x54>
801058f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058fc:	8b 00                	mov    (%eax),%eax
801058fe:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105901:	39 d0                	cmp    %edx,%eax
80105903:	76 13                	jbe    80105918 <argptr+0x54>
80105905:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105908:	89 c2                	mov    %eax,%edx
8010590a:	8b 45 10             	mov    0x10(%ebp),%eax
8010590d:	01 c2                	add    %eax,%edx
8010590f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105912:	8b 00                	mov    (%eax),%eax
80105914:	39 c2                	cmp    %eax,%edx
80105916:	76 07                	jbe    8010591f <argptr+0x5b>
    return -1;
80105918:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010591d:	eb 0f                	jmp    8010592e <argptr+0x6a>
  *pp = (char*)i;
8010591f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105922:	89 c2                	mov    %eax,%edx
80105924:	8b 45 0c             	mov    0xc(%ebp),%eax
80105927:	89 10                	mov    %edx,(%eax)
  return 0;
80105929:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010592e:	c9                   	leave  
8010592f:	c3                   	ret    

80105930 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105930:	f3 0f 1e fb          	endbr32 
80105934:	55                   	push   %ebp
80105935:	89 e5                	mov    %esp,%ebp
80105937:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010593a:	83 ec 08             	sub    $0x8,%esp
8010593d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105940:	50                   	push   %eax
80105941:	ff 75 08             	pushl  0x8(%ebp)
80105944:	e8 4a ff ff ff       	call   80105893 <argint>
80105949:	83 c4 10             	add    $0x10,%esp
8010594c:	85 c0                	test   %eax,%eax
8010594e:	79 07                	jns    80105957 <argstr+0x27>
    return -1;
80105950:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105955:	eb 12                	jmp    80105969 <argstr+0x39>
  return fetchstr(addr, pp);
80105957:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010595a:	83 ec 08             	sub    $0x8,%esp
8010595d:	ff 75 0c             	pushl  0xc(%ebp)
80105960:	50                   	push   %eax
80105961:	e8 c5 fe ff ff       	call   8010582b <fetchstr>
80105966:	83 c4 10             	add    $0x10,%esp
}
80105969:	c9                   	leave  
8010596a:	c3                   	ret    

8010596b <syscall>:
[SYS_dump_rawphymem] sys_dump_rawphymem,
};

void
syscall(void)
{
8010596b:	f3 0f 1e fb          	endbr32 
8010596f:	55                   	push   %ebp
80105970:	89 e5                	mov    %esp,%ebp
80105972:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80105975:	e8 86 eb ff ff       	call   80104500 <myproc>
8010597a:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
8010597d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105980:	8b 40 18             	mov    0x18(%eax),%eax
80105983:	8b 40 1c             	mov    0x1c(%eax),%eax
80105986:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105989:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010598d:	7e 2f                	jle    801059be <syscall+0x53>
8010598f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105992:	83 f8 18             	cmp    $0x18,%eax
80105995:	77 27                	ja     801059be <syscall+0x53>
80105997:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010599a:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
801059a1:	85 c0                	test   %eax,%eax
801059a3:	74 19                	je     801059be <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
801059a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059a8:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
801059af:	ff d0                	call   *%eax
801059b1:	89 c2                	mov    %eax,%edx
801059b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059b6:	8b 40 18             	mov    0x18(%eax),%eax
801059b9:	89 50 1c             	mov    %edx,0x1c(%eax)
801059bc:	eb 2c                	jmp    801059ea <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
801059be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059c1:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
801059c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059c7:	8b 40 10             	mov    0x10(%eax),%eax
801059ca:	ff 75 f0             	pushl  -0x10(%ebp)
801059cd:	52                   	push   %edx
801059ce:	50                   	push   %eax
801059cf:	68 d0 96 10 80       	push   $0x801096d0
801059d4:	e8 3f aa ff ff       	call   80100418 <cprintf>
801059d9:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
801059dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059df:	8b 40 18             	mov    0x18(%eax),%eax
801059e2:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801059e9:	90                   	nop
801059ea:	90                   	nop
801059eb:	c9                   	leave  
801059ec:	c3                   	ret    

801059ed <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801059ed:	f3 0f 1e fb          	endbr32 
801059f1:	55                   	push   %ebp
801059f2:	89 e5                	mov    %esp,%ebp
801059f4:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801059f7:	83 ec 08             	sub    $0x8,%esp
801059fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059fd:	50                   	push   %eax
801059fe:	ff 75 08             	pushl  0x8(%ebp)
80105a01:	e8 8d fe ff ff       	call   80105893 <argint>
80105a06:	83 c4 10             	add    $0x10,%esp
80105a09:	85 c0                	test   %eax,%eax
80105a0b:	79 07                	jns    80105a14 <argfd+0x27>
    return -1;
80105a0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a12:	eb 4f                	jmp    80105a63 <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105a14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a17:	85 c0                	test   %eax,%eax
80105a19:	78 20                	js     80105a3b <argfd+0x4e>
80105a1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a1e:	83 f8 0f             	cmp    $0xf,%eax
80105a21:	7f 18                	jg     80105a3b <argfd+0x4e>
80105a23:	e8 d8 ea ff ff       	call   80104500 <myproc>
80105a28:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a2b:	83 c2 08             	add    $0x8,%edx
80105a2e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105a32:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a35:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a39:	75 07                	jne    80105a42 <argfd+0x55>
    return -1;
80105a3b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a40:	eb 21                	jmp    80105a63 <argfd+0x76>
  if(pfd)
80105a42:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105a46:	74 08                	je     80105a50 <argfd+0x63>
    *pfd = fd;
80105a48:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a4b:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a4e:	89 10                	mov    %edx,(%eax)
  if(pf)
80105a50:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105a54:	74 08                	je     80105a5e <argfd+0x71>
    *pf = f;
80105a56:	8b 45 10             	mov    0x10(%ebp),%eax
80105a59:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a5c:	89 10                	mov    %edx,(%eax)
  return 0;
80105a5e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a63:	c9                   	leave  
80105a64:	c3                   	ret    

80105a65 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105a65:	f3 0f 1e fb          	endbr32 
80105a69:	55                   	push   %ebp
80105a6a:	89 e5                	mov    %esp,%ebp
80105a6c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105a6f:	e8 8c ea ff ff       	call   80104500 <myproc>
80105a74:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105a77:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105a7e:	eb 2a                	jmp    80105aaa <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
80105a80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a83:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a86:	83 c2 08             	add    $0x8,%edx
80105a89:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105a8d:	85 c0                	test   %eax,%eax
80105a8f:	75 15                	jne    80105aa6 <fdalloc+0x41>
      curproc->ofile[fd] = f;
80105a91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a94:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a97:	8d 4a 08             	lea    0x8(%edx),%ecx
80105a9a:	8b 55 08             	mov    0x8(%ebp),%edx
80105a9d:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105aa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aa4:	eb 0f                	jmp    80105ab5 <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
80105aa6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105aaa:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105aae:	7e d0                	jle    80105a80 <fdalloc+0x1b>
    }
  }
  return -1;
80105ab0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ab5:	c9                   	leave  
80105ab6:	c3                   	ret    

80105ab7 <sys_dup>:

int
sys_dup(void)
{
80105ab7:	f3 0f 1e fb          	endbr32 
80105abb:	55                   	push   %ebp
80105abc:	89 e5                	mov    %esp,%ebp
80105abe:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105ac1:	83 ec 04             	sub    $0x4,%esp
80105ac4:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ac7:	50                   	push   %eax
80105ac8:	6a 00                	push   $0x0
80105aca:	6a 00                	push   $0x0
80105acc:	e8 1c ff ff ff       	call   801059ed <argfd>
80105ad1:	83 c4 10             	add    $0x10,%esp
80105ad4:	85 c0                	test   %eax,%eax
80105ad6:	79 07                	jns    80105adf <sys_dup+0x28>
    return -1;
80105ad8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105add:	eb 31                	jmp    80105b10 <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
80105adf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ae2:	83 ec 0c             	sub    $0xc,%esp
80105ae5:	50                   	push   %eax
80105ae6:	e8 7a ff ff ff       	call   80105a65 <fdalloc>
80105aeb:	83 c4 10             	add    $0x10,%esp
80105aee:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105af1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105af5:	79 07                	jns    80105afe <sys_dup+0x47>
    return -1;
80105af7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105afc:	eb 12                	jmp    80105b10 <sys_dup+0x59>
  filedup(f);
80105afe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b01:	83 ec 0c             	sub    $0xc,%esp
80105b04:	50                   	push   %eax
80105b05:	e8 93 b6 ff ff       	call   8010119d <filedup>
80105b0a:	83 c4 10             	add    $0x10,%esp
  return fd;
80105b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105b10:	c9                   	leave  
80105b11:	c3                   	ret    

80105b12 <sys_read>:

int
sys_read(void)
{
80105b12:	f3 0f 1e fb          	endbr32 
80105b16:	55                   	push   %ebp
80105b17:	89 e5                	mov    %esp,%ebp
80105b19:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105b1c:	83 ec 04             	sub    $0x4,%esp
80105b1f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b22:	50                   	push   %eax
80105b23:	6a 00                	push   $0x0
80105b25:	6a 00                	push   $0x0
80105b27:	e8 c1 fe ff ff       	call   801059ed <argfd>
80105b2c:	83 c4 10             	add    $0x10,%esp
80105b2f:	85 c0                	test   %eax,%eax
80105b31:	78 2e                	js     80105b61 <sys_read+0x4f>
80105b33:	83 ec 08             	sub    $0x8,%esp
80105b36:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b39:	50                   	push   %eax
80105b3a:	6a 02                	push   $0x2
80105b3c:	e8 52 fd ff ff       	call   80105893 <argint>
80105b41:	83 c4 10             	add    $0x10,%esp
80105b44:	85 c0                	test   %eax,%eax
80105b46:	78 19                	js     80105b61 <sys_read+0x4f>
80105b48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b4b:	83 ec 04             	sub    $0x4,%esp
80105b4e:	50                   	push   %eax
80105b4f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b52:	50                   	push   %eax
80105b53:	6a 01                	push   $0x1
80105b55:	e8 6a fd ff ff       	call   801058c4 <argptr>
80105b5a:	83 c4 10             	add    $0x10,%esp
80105b5d:	85 c0                	test   %eax,%eax
80105b5f:	79 07                	jns    80105b68 <sys_read+0x56>
    return -1;
80105b61:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b66:	eb 17                	jmp    80105b7f <sys_read+0x6d>
  return fileread(f, p, n);
80105b68:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105b6b:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105b6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b71:	83 ec 04             	sub    $0x4,%esp
80105b74:	51                   	push   %ecx
80105b75:	52                   	push   %edx
80105b76:	50                   	push   %eax
80105b77:	e8 bd b7 ff ff       	call   80101339 <fileread>
80105b7c:	83 c4 10             	add    $0x10,%esp
}
80105b7f:	c9                   	leave  
80105b80:	c3                   	ret    

80105b81 <sys_write>:

int
sys_write(void)
{
80105b81:	f3 0f 1e fb          	endbr32 
80105b85:	55                   	push   %ebp
80105b86:	89 e5                	mov    %esp,%ebp
80105b88:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105b8b:	83 ec 04             	sub    $0x4,%esp
80105b8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b91:	50                   	push   %eax
80105b92:	6a 00                	push   $0x0
80105b94:	6a 00                	push   $0x0
80105b96:	e8 52 fe ff ff       	call   801059ed <argfd>
80105b9b:	83 c4 10             	add    $0x10,%esp
80105b9e:	85 c0                	test   %eax,%eax
80105ba0:	78 2e                	js     80105bd0 <sys_write+0x4f>
80105ba2:	83 ec 08             	sub    $0x8,%esp
80105ba5:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ba8:	50                   	push   %eax
80105ba9:	6a 02                	push   $0x2
80105bab:	e8 e3 fc ff ff       	call   80105893 <argint>
80105bb0:	83 c4 10             	add    $0x10,%esp
80105bb3:	85 c0                	test   %eax,%eax
80105bb5:	78 19                	js     80105bd0 <sys_write+0x4f>
80105bb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bba:	83 ec 04             	sub    $0x4,%esp
80105bbd:	50                   	push   %eax
80105bbe:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105bc1:	50                   	push   %eax
80105bc2:	6a 01                	push   $0x1
80105bc4:	e8 fb fc ff ff       	call   801058c4 <argptr>
80105bc9:	83 c4 10             	add    $0x10,%esp
80105bcc:	85 c0                	test   %eax,%eax
80105bce:	79 07                	jns    80105bd7 <sys_write+0x56>
    return -1;
80105bd0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bd5:	eb 17                	jmp    80105bee <sys_write+0x6d>
  return filewrite(f, p, n);
80105bd7:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105bda:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105be0:	83 ec 04             	sub    $0x4,%esp
80105be3:	51                   	push   %ecx
80105be4:	52                   	push   %edx
80105be5:	50                   	push   %eax
80105be6:	e8 0a b8 ff ff       	call   801013f5 <filewrite>
80105beb:	83 c4 10             	add    $0x10,%esp
}
80105bee:	c9                   	leave  
80105bef:	c3                   	ret    

80105bf0 <sys_close>:

int
sys_close(void)
{
80105bf0:	f3 0f 1e fb          	endbr32 
80105bf4:	55                   	push   %ebp
80105bf5:	89 e5                	mov    %esp,%ebp
80105bf7:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105bfa:	83 ec 04             	sub    $0x4,%esp
80105bfd:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c00:	50                   	push   %eax
80105c01:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c04:	50                   	push   %eax
80105c05:	6a 00                	push   $0x0
80105c07:	e8 e1 fd ff ff       	call   801059ed <argfd>
80105c0c:	83 c4 10             	add    $0x10,%esp
80105c0f:	85 c0                	test   %eax,%eax
80105c11:	79 07                	jns    80105c1a <sys_close+0x2a>
    return -1;
80105c13:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c18:	eb 27                	jmp    80105c41 <sys_close+0x51>
  myproc()->ofile[fd] = 0;
80105c1a:	e8 e1 e8 ff ff       	call   80104500 <myproc>
80105c1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c22:	83 c2 08             	add    $0x8,%edx
80105c25:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105c2c:	00 
  fileclose(f);
80105c2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c30:	83 ec 0c             	sub    $0xc,%esp
80105c33:	50                   	push   %eax
80105c34:	e8 b9 b5 ff ff       	call   801011f2 <fileclose>
80105c39:	83 c4 10             	add    $0x10,%esp
  return 0;
80105c3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c41:	c9                   	leave  
80105c42:	c3                   	ret    

80105c43 <sys_fstat>:

int
sys_fstat(void)
{
80105c43:	f3 0f 1e fb          	endbr32 
80105c47:	55                   	push   %ebp
80105c48:	89 e5                	mov    %esp,%ebp
80105c4a:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105c4d:	83 ec 04             	sub    $0x4,%esp
80105c50:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c53:	50                   	push   %eax
80105c54:	6a 00                	push   $0x0
80105c56:	6a 00                	push   $0x0
80105c58:	e8 90 fd ff ff       	call   801059ed <argfd>
80105c5d:	83 c4 10             	add    $0x10,%esp
80105c60:	85 c0                	test   %eax,%eax
80105c62:	78 17                	js     80105c7b <sys_fstat+0x38>
80105c64:	83 ec 04             	sub    $0x4,%esp
80105c67:	6a 14                	push   $0x14
80105c69:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c6c:	50                   	push   %eax
80105c6d:	6a 01                	push   $0x1
80105c6f:	e8 50 fc ff ff       	call   801058c4 <argptr>
80105c74:	83 c4 10             	add    $0x10,%esp
80105c77:	85 c0                	test   %eax,%eax
80105c79:	79 07                	jns    80105c82 <sys_fstat+0x3f>
    return -1;
80105c7b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c80:	eb 13                	jmp    80105c95 <sys_fstat+0x52>
  return filestat(f, st);
80105c82:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c88:	83 ec 08             	sub    $0x8,%esp
80105c8b:	52                   	push   %edx
80105c8c:	50                   	push   %eax
80105c8d:	e8 4c b6 ff ff       	call   801012de <filestat>
80105c92:	83 c4 10             	add    $0x10,%esp
}
80105c95:	c9                   	leave  
80105c96:	c3                   	ret    

80105c97 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105c97:	f3 0f 1e fb          	endbr32 
80105c9b:	55                   	push   %ebp
80105c9c:	89 e5                	mov    %esp,%ebp
80105c9e:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105ca1:	83 ec 08             	sub    $0x8,%esp
80105ca4:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105ca7:	50                   	push   %eax
80105ca8:	6a 00                	push   $0x0
80105caa:	e8 81 fc ff ff       	call   80105930 <argstr>
80105caf:	83 c4 10             	add    $0x10,%esp
80105cb2:	85 c0                	test   %eax,%eax
80105cb4:	78 15                	js     80105ccb <sys_link+0x34>
80105cb6:	83 ec 08             	sub    $0x8,%esp
80105cb9:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105cbc:	50                   	push   %eax
80105cbd:	6a 01                	push   $0x1
80105cbf:	e8 6c fc ff ff       	call   80105930 <argstr>
80105cc4:	83 c4 10             	add    $0x10,%esp
80105cc7:	85 c0                	test   %eax,%eax
80105cc9:	79 0a                	jns    80105cd5 <sys_link+0x3e>
    return -1;
80105ccb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cd0:	e9 68 01 00 00       	jmp    80105e3d <sys_link+0x1a6>

  begin_op();
80105cd5:	e8 67 da ff ff       	call   80103741 <begin_op>
  if((ip = namei(old)) == 0){
80105cda:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105cdd:	83 ec 0c             	sub    $0xc,%esp
80105ce0:	50                   	push   %eax
80105ce1:	e8 f7 c9 ff ff       	call   801026dd <namei>
80105ce6:	83 c4 10             	add    $0x10,%esp
80105ce9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105cec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cf0:	75 0f                	jne    80105d01 <sys_link+0x6a>
    end_op();
80105cf2:	e8 da da ff ff       	call   801037d1 <end_op>
    return -1;
80105cf7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cfc:	e9 3c 01 00 00       	jmp    80105e3d <sys_link+0x1a6>
  }

  ilock(ip);
80105d01:	83 ec 0c             	sub    $0xc,%esp
80105d04:	ff 75 f4             	pushl  -0xc(%ebp)
80105d07:	e8 66 be ff ff       	call   80101b72 <ilock>
80105d0c:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d12:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d16:	66 83 f8 01          	cmp    $0x1,%ax
80105d1a:	75 1d                	jne    80105d39 <sys_link+0xa2>
    iunlockput(ip);
80105d1c:	83 ec 0c             	sub    $0xc,%esp
80105d1f:	ff 75 f4             	pushl  -0xc(%ebp)
80105d22:	e8 88 c0 ff ff       	call   80101daf <iunlockput>
80105d27:	83 c4 10             	add    $0x10,%esp
    end_op();
80105d2a:	e8 a2 da ff ff       	call   801037d1 <end_op>
    return -1;
80105d2f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d34:	e9 04 01 00 00       	jmp    80105e3d <sys_link+0x1a6>
  }

  ip->nlink++;
80105d39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d3c:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105d40:	83 c0 01             	add    $0x1,%eax
80105d43:	89 c2                	mov    %eax,%edx
80105d45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d48:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105d4c:	83 ec 0c             	sub    $0xc,%esp
80105d4f:	ff 75 f4             	pushl  -0xc(%ebp)
80105d52:	e8 32 bc ff ff       	call   80101989 <iupdate>
80105d57:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105d5a:	83 ec 0c             	sub    $0xc,%esp
80105d5d:	ff 75 f4             	pushl  -0xc(%ebp)
80105d60:	e8 24 bf ff ff       	call   80101c89 <iunlock>
80105d65:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105d68:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105d6b:	83 ec 08             	sub    $0x8,%esp
80105d6e:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105d71:	52                   	push   %edx
80105d72:	50                   	push   %eax
80105d73:	e8 85 c9 ff ff       	call   801026fd <nameiparent>
80105d78:	83 c4 10             	add    $0x10,%esp
80105d7b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d7e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d82:	74 71                	je     80105df5 <sys_link+0x15e>
    goto bad;
  ilock(dp);
80105d84:	83 ec 0c             	sub    $0xc,%esp
80105d87:	ff 75 f0             	pushl  -0x10(%ebp)
80105d8a:	e8 e3 bd ff ff       	call   80101b72 <ilock>
80105d8f:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105d92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d95:	8b 10                	mov    (%eax),%edx
80105d97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d9a:	8b 00                	mov    (%eax),%eax
80105d9c:	39 c2                	cmp    %eax,%edx
80105d9e:	75 1d                	jne    80105dbd <sys_link+0x126>
80105da0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105da3:	8b 40 04             	mov    0x4(%eax),%eax
80105da6:	83 ec 04             	sub    $0x4,%esp
80105da9:	50                   	push   %eax
80105daa:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105dad:	50                   	push   %eax
80105dae:	ff 75 f0             	pushl  -0x10(%ebp)
80105db1:	e8 84 c6 ff ff       	call   8010243a <dirlink>
80105db6:	83 c4 10             	add    $0x10,%esp
80105db9:	85 c0                	test   %eax,%eax
80105dbb:	79 10                	jns    80105dcd <sys_link+0x136>
    iunlockput(dp);
80105dbd:	83 ec 0c             	sub    $0xc,%esp
80105dc0:	ff 75 f0             	pushl  -0x10(%ebp)
80105dc3:	e8 e7 bf ff ff       	call   80101daf <iunlockput>
80105dc8:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105dcb:	eb 29                	jmp    80105df6 <sys_link+0x15f>
  }
  iunlockput(dp);
80105dcd:	83 ec 0c             	sub    $0xc,%esp
80105dd0:	ff 75 f0             	pushl  -0x10(%ebp)
80105dd3:	e8 d7 bf ff ff       	call   80101daf <iunlockput>
80105dd8:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105ddb:	83 ec 0c             	sub    $0xc,%esp
80105dde:	ff 75 f4             	pushl  -0xc(%ebp)
80105de1:	e8 f5 be ff ff       	call   80101cdb <iput>
80105de6:	83 c4 10             	add    $0x10,%esp

  end_op();
80105de9:	e8 e3 d9 ff ff       	call   801037d1 <end_op>

  return 0;
80105dee:	b8 00 00 00 00       	mov    $0x0,%eax
80105df3:	eb 48                	jmp    80105e3d <sys_link+0x1a6>
    goto bad;
80105df5:	90                   	nop

bad:
  ilock(ip);
80105df6:	83 ec 0c             	sub    $0xc,%esp
80105df9:	ff 75 f4             	pushl  -0xc(%ebp)
80105dfc:	e8 71 bd ff ff       	call   80101b72 <ilock>
80105e01:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105e04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e07:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105e0b:	83 e8 01             	sub    $0x1,%eax
80105e0e:	89 c2                	mov    %eax,%edx
80105e10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e13:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105e17:	83 ec 0c             	sub    $0xc,%esp
80105e1a:	ff 75 f4             	pushl  -0xc(%ebp)
80105e1d:	e8 67 bb ff ff       	call   80101989 <iupdate>
80105e22:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105e25:	83 ec 0c             	sub    $0xc,%esp
80105e28:	ff 75 f4             	pushl  -0xc(%ebp)
80105e2b:	e8 7f bf ff ff       	call   80101daf <iunlockput>
80105e30:	83 c4 10             	add    $0x10,%esp
  end_op();
80105e33:	e8 99 d9 ff ff       	call   801037d1 <end_op>
  return -1;
80105e38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e3d:	c9                   	leave  
80105e3e:	c3                   	ret    

80105e3f <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105e3f:	f3 0f 1e fb          	endbr32 
80105e43:	55                   	push   %ebp
80105e44:	89 e5                	mov    %esp,%ebp
80105e46:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105e49:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105e50:	eb 40                	jmp    80105e92 <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105e52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e55:	6a 10                	push   $0x10
80105e57:	50                   	push   %eax
80105e58:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105e5b:	50                   	push   %eax
80105e5c:	ff 75 08             	pushl  0x8(%ebp)
80105e5f:	e8 16 c2 ff ff       	call   8010207a <readi>
80105e64:	83 c4 10             	add    $0x10,%esp
80105e67:	83 f8 10             	cmp    $0x10,%eax
80105e6a:	74 0d                	je     80105e79 <isdirempty+0x3a>
      panic("isdirempty: readi");
80105e6c:	83 ec 0c             	sub    $0xc,%esp
80105e6f:	68 ec 96 10 80       	push   $0x801096ec
80105e74:	e8 8f a7 ff ff       	call   80100608 <panic>
    if(de.inum != 0)
80105e79:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105e7d:	66 85 c0             	test   %ax,%ax
80105e80:	74 07                	je     80105e89 <isdirempty+0x4a>
      return 0;
80105e82:	b8 00 00 00 00       	mov    $0x0,%eax
80105e87:	eb 1b                	jmp    80105ea4 <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105e89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e8c:	83 c0 10             	add    $0x10,%eax
80105e8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e92:	8b 45 08             	mov    0x8(%ebp),%eax
80105e95:	8b 50 58             	mov    0x58(%eax),%edx
80105e98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e9b:	39 c2                	cmp    %eax,%edx
80105e9d:	77 b3                	ja     80105e52 <isdirempty+0x13>
  }
  return 1;
80105e9f:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105ea4:	c9                   	leave  
80105ea5:	c3                   	ret    

80105ea6 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105ea6:	f3 0f 1e fb          	endbr32 
80105eaa:	55                   	push   %ebp
80105eab:	89 e5                	mov    %esp,%ebp
80105ead:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105eb0:	83 ec 08             	sub    $0x8,%esp
80105eb3:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105eb6:	50                   	push   %eax
80105eb7:	6a 00                	push   $0x0
80105eb9:	e8 72 fa ff ff       	call   80105930 <argstr>
80105ebe:	83 c4 10             	add    $0x10,%esp
80105ec1:	85 c0                	test   %eax,%eax
80105ec3:	79 0a                	jns    80105ecf <sys_unlink+0x29>
    return -1;
80105ec5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105eca:	e9 bf 01 00 00       	jmp    8010608e <sys_unlink+0x1e8>

  begin_op();
80105ecf:	e8 6d d8 ff ff       	call   80103741 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105ed4:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105ed7:	83 ec 08             	sub    $0x8,%esp
80105eda:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105edd:	52                   	push   %edx
80105ede:	50                   	push   %eax
80105edf:	e8 19 c8 ff ff       	call   801026fd <nameiparent>
80105ee4:	83 c4 10             	add    $0x10,%esp
80105ee7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105eea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105eee:	75 0f                	jne    80105eff <sys_unlink+0x59>
    end_op();
80105ef0:	e8 dc d8 ff ff       	call   801037d1 <end_op>
    return -1;
80105ef5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105efa:	e9 8f 01 00 00       	jmp    8010608e <sys_unlink+0x1e8>
  }

  ilock(dp);
80105eff:	83 ec 0c             	sub    $0xc,%esp
80105f02:	ff 75 f4             	pushl  -0xc(%ebp)
80105f05:	e8 68 bc ff ff       	call   80101b72 <ilock>
80105f0a:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105f0d:	83 ec 08             	sub    $0x8,%esp
80105f10:	68 fe 96 10 80       	push   $0x801096fe
80105f15:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f18:	50                   	push   %eax
80105f19:	e8 3f c4 ff ff       	call   8010235d <namecmp>
80105f1e:	83 c4 10             	add    $0x10,%esp
80105f21:	85 c0                	test   %eax,%eax
80105f23:	0f 84 49 01 00 00    	je     80106072 <sys_unlink+0x1cc>
80105f29:	83 ec 08             	sub    $0x8,%esp
80105f2c:	68 00 97 10 80       	push   $0x80109700
80105f31:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f34:	50                   	push   %eax
80105f35:	e8 23 c4 ff ff       	call   8010235d <namecmp>
80105f3a:	83 c4 10             	add    $0x10,%esp
80105f3d:	85 c0                	test   %eax,%eax
80105f3f:	0f 84 2d 01 00 00    	je     80106072 <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105f45:	83 ec 04             	sub    $0x4,%esp
80105f48:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105f4b:	50                   	push   %eax
80105f4c:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f4f:	50                   	push   %eax
80105f50:	ff 75 f4             	pushl  -0xc(%ebp)
80105f53:	e8 24 c4 ff ff       	call   8010237c <dirlookup>
80105f58:	83 c4 10             	add    $0x10,%esp
80105f5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f5e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f62:	0f 84 0d 01 00 00    	je     80106075 <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
80105f68:	83 ec 0c             	sub    $0xc,%esp
80105f6b:	ff 75 f0             	pushl  -0x10(%ebp)
80105f6e:	e8 ff bb ff ff       	call   80101b72 <ilock>
80105f73:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105f76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f79:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105f7d:	66 85 c0             	test   %ax,%ax
80105f80:	7f 0d                	jg     80105f8f <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
80105f82:	83 ec 0c             	sub    $0xc,%esp
80105f85:	68 03 97 10 80       	push   $0x80109703
80105f8a:	e8 79 a6 ff ff       	call   80100608 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105f8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f92:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105f96:	66 83 f8 01          	cmp    $0x1,%ax
80105f9a:	75 25                	jne    80105fc1 <sys_unlink+0x11b>
80105f9c:	83 ec 0c             	sub    $0xc,%esp
80105f9f:	ff 75 f0             	pushl  -0x10(%ebp)
80105fa2:	e8 98 fe ff ff       	call   80105e3f <isdirempty>
80105fa7:	83 c4 10             	add    $0x10,%esp
80105faa:	85 c0                	test   %eax,%eax
80105fac:	75 13                	jne    80105fc1 <sys_unlink+0x11b>
    iunlockput(ip);
80105fae:	83 ec 0c             	sub    $0xc,%esp
80105fb1:	ff 75 f0             	pushl  -0x10(%ebp)
80105fb4:	e8 f6 bd ff ff       	call   80101daf <iunlockput>
80105fb9:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105fbc:	e9 b5 00 00 00       	jmp    80106076 <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
80105fc1:	83 ec 04             	sub    $0x4,%esp
80105fc4:	6a 10                	push   $0x10
80105fc6:	6a 00                	push   $0x0
80105fc8:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105fcb:	50                   	push   %eax
80105fcc:	e8 6e f5 ff ff       	call   8010553f <memset>
80105fd1:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105fd4:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105fd7:	6a 10                	push   $0x10
80105fd9:	50                   	push   %eax
80105fda:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105fdd:	50                   	push   %eax
80105fde:	ff 75 f4             	pushl  -0xc(%ebp)
80105fe1:	e8 ed c1 ff ff       	call   801021d3 <writei>
80105fe6:	83 c4 10             	add    $0x10,%esp
80105fe9:	83 f8 10             	cmp    $0x10,%eax
80105fec:	74 0d                	je     80105ffb <sys_unlink+0x155>
    panic("unlink: writei");
80105fee:	83 ec 0c             	sub    $0xc,%esp
80105ff1:	68 15 97 10 80       	push   $0x80109715
80105ff6:	e8 0d a6 ff ff       	call   80100608 <panic>
  if(ip->type == T_DIR){
80105ffb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ffe:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106002:	66 83 f8 01          	cmp    $0x1,%ax
80106006:	75 21                	jne    80106029 <sys_unlink+0x183>
    dp->nlink--;
80106008:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010600b:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010600f:	83 e8 01             	sub    $0x1,%eax
80106012:	89 c2                	mov    %eax,%edx
80106014:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106017:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
8010601b:	83 ec 0c             	sub    $0xc,%esp
8010601e:	ff 75 f4             	pushl  -0xc(%ebp)
80106021:	e8 63 b9 ff ff       	call   80101989 <iupdate>
80106026:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80106029:	83 ec 0c             	sub    $0xc,%esp
8010602c:	ff 75 f4             	pushl  -0xc(%ebp)
8010602f:	e8 7b bd ff ff       	call   80101daf <iunlockput>
80106034:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80106037:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010603a:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010603e:	83 e8 01             	sub    $0x1,%eax
80106041:	89 c2                	mov    %eax,%edx
80106043:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106046:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010604a:	83 ec 0c             	sub    $0xc,%esp
8010604d:	ff 75 f0             	pushl  -0x10(%ebp)
80106050:	e8 34 b9 ff ff       	call   80101989 <iupdate>
80106055:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80106058:	83 ec 0c             	sub    $0xc,%esp
8010605b:	ff 75 f0             	pushl  -0x10(%ebp)
8010605e:	e8 4c bd ff ff       	call   80101daf <iunlockput>
80106063:	83 c4 10             	add    $0x10,%esp

  end_op();
80106066:	e8 66 d7 ff ff       	call   801037d1 <end_op>

  return 0;
8010606b:	b8 00 00 00 00       	mov    $0x0,%eax
80106070:	eb 1c                	jmp    8010608e <sys_unlink+0x1e8>
    goto bad;
80106072:	90                   	nop
80106073:	eb 01                	jmp    80106076 <sys_unlink+0x1d0>
    goto bad;
80106075:	90                   	nop

bad:
  iunlockput(dp);
80106076:	83 ec 0c             	sub    $0xc,%esp
80106079:	ff 75 f4             	pushl  -0xc(%ebp)
8010607c:	e8 2e bd ff ff       	call   80101daf <iunlockput>
80106081:	83 c4 10             	add    $0x10,%esp
  end_op();
80106084:	e8 48 d7 ff ff       	call   801037d1 <end_op>
  return -1;
80106089:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010608e:	c9                   	leave  
8010608f:	c3                   	ret    

80106090 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80106090:	f3 0f 1e fb          	endbr32 
80106094:	55                   	push   %ebp
80106095:	89 e5                	mov    %esp,%ebp
80106097:	83 ec 38             	sub    $0x38,%esp
8010609a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010609d:	8b 55 10             	mov    0x10(%ebp),%edx
801060a0:	8b 45 14             	mov    0x14(%ebp),%eax
801060a3:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801060a7:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801060ab:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801060af:	83 ec 08             	sub    $0x8,%esp
801060b2:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801060b5:	50                   	push   %eax
801060b6:	ff 75 08             	pushl  0x8(%ebp)
801060b9:	e8 3f c6 ff ff       	call   801026fd <nameiparent>
801060be:	83 c4 10             	add    $0x10,%esp
801060c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060c4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060c8:	75 0a                	jne    801060d4 <create+0x44>
    return 0;
801060ca:	b8 00 00 00 00       	mov    $0x0,%eax
801060cf:	e9 8e 01 00 00       	jmp    80106262 <create+0x1d2>
  ilock(dp);
801060d4:	83 ec 0c             	sub    $0xc,%esp
801060d7:	ff 75 f4             	pushl  -0xc(%ebp)
801060da:	e8 93 ba ff ff       	call   80101b72 <ilock>
801060df:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, 0)) != 0){
801060e2:	83 ec 04             	sub    $0x4,%esp
801060e5:	6a 00                	push   $0x0
801060e7:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801060ea:	50                   	push   %eax
801060eb:	ff 75 f4             	pushl  -0xc(%ebp)
801060ee:	e8 89 c2 ff ff       	call   8010237c <dirlookup>
801060f3:	83 c4 10             	add    $0x10,%esp
801060f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801060f9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801060fd:	74 50                	je     8010614f <create+0xbf>
    iunlockput(dp);
801060ff:	83 ec 0c             	sub    $0xc,%esp
80106102:	ff 75 f4             	pushl  -0xc(%ebp)
80106105:	e8 a5 bc ff ff       	call   80101daf <iunlockput>
8010610a:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
8010610d:	83 ec 0c             	sub    $0xc,%esp
80106110:	ff 75 f0             	pushl  -0x10(%ebp)
80106113:	e8 5a ba ff ff       	call   80101b72 <ilock>
80106118:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
8010611b:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106120:	75 15                	jne    80106137 <create+0xa7>
80106122:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106125:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106129:	66 83 f8 02          	cmp    $0x2,%ax
8010612d:	75 08                	jne    80106137 <create+0xa7>
      return ip;
8010612f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106132:	e9 2b 01 00 00       	jmp    80106262 <create+0x1d2>
    iunlockput(ip);
80106137:	83 ec 0c             	sub    $0xc,%esp
8010613a:	ff 75 f0             	pushl  -0x10(%ebp)
8010613d:	e8 6d bc ff ff       	call   80101daf <iunlockput>
80106142:	83 c4 10             	add    $0x10,%esp
    return 0;
80106145:	b8 00 00 00 00       	mov    $0x0,%eax
8010614a:	e9 13 01 00 00       	jmp    80106262 <create+0x1d2>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
8010614f:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106153:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106156:	8b 00                	mov    (%eax),%eax
80106158:	83 ec 08             	sub    $0x8,%esp
8010615b:	52                   	push   %edx
8010615c:	50                   	push   %eax
8010615d:	e8 4c b7 ff ff       	call   801018ae <ialloc>
80106162:	83 c4 10             	add    $0x10,%esp
80106165:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106168:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010616c:	75 0d                	jne    8010617b <create+0xeb>
    panic("create: ialloc");
8010616e:	83 ec 0c             	sub    $0xc,%esp
80106171:	68 24 97 10 80       	push   $0x80109724
80106176:	e8 8d a4 ff ff       	call   80100608 <panic>

  ilock(ip);
8010617b:	83 ec 0c             	sub    $0xc,%esp
8010617e:	ff 75 f0             	pushl  -0x10(%ebp)
80106181:	e8 ec b9 ff ff       	call   80101b72 <ilock>
80106186:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80106189:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010618c:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106190:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80106194:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106197:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
8010619b:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
8010619f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061a2:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
801061a8:	83 ec 0c             	sub    $0xc,%esp
801061ab:	ff 75 f0             	pushl  -0x10(%ebp)
801061ae:	e8 d6 b7 ff ff       	call   80101989 <iupdate>
801061b3:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801061b6:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801061bb:	75 6a                	jne    80106227 <create+0x197>
    dp->nlink++;  // for ".."
801061bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061c0:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801061c4:	83 c0 01             	add    $0x1,%eax
801061c7:	89 c2                	mov    %eax,%edx
801061c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061cc:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801061d0:	83 ec 0c             	sub    $0xc,%esp
801061d3:	ff 75 f4             	pushl  -0xc(%ebp)
801061d6:	e8 ae b7 ff ff       	call   80101989 <iupdate>
801061db:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801061de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061e1:	8b 40 04             	mov    0x4(%eax),%eax
801061e4:	83 ec 04             	sub    $0x4,%esp
801061e7:	50                   	push   %eax
801061e8:	68 fe 96 10 80       	push   $0x801096fe
801061ed:	ff 75 f0             	pushl  -0x10(%ebp)
801061f0:	e8 45 c2 ff ff       	call   8010243a <dirlink>
801061f5:	83 c4 10             	add    $0x10,%esp
801061f8:	85 c0                	test   %eax,%eax
801061fa:	78 1e                	js     8010621a <create+0x18a>
801061fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061ff:	8b 40 04             	mov    0x4(%eax),%eax
80106202:	83 ec 04             	sub    $0x4,%esp
80106205:	50                   	push   %eax
80106206:	68 00 97 10 80       	push   $0x80109700
8010620b:	ff 75 f0             	pushl  -0x10(%ebp)
8010620e:	e8 27 c2 ff ff       	call   8010243a <dirlink>
80106213:	83 c4 10             	add    $0x10,%esp
80106216:	85 c0                	test   %eax,%eax
80106218:	79 0d                	jns    80106227 <create+0x197>
      panic("create dots");
8010621a:	83 ec 0c             	sub    $0xc,%esp
8010621d:	68 33 97 10 80       	push   $0x80109733
80106222:	e8 e1 a3 ff ff       	call   80100608 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106227:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010622a:	8b 40 04             	mov    0x4(%eax),%eax
8010622d:	83 ec 04             	sub    $0x4,%esp
80106230:	50                   	push   %eax
80106231:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106234:	50                   	push   %eax
80106235:	ff 75 f4             	pushl  -0xc(%ebp)
80106238:	e8 fd c1 ff ff       	call   8010243a <dirlink>
8010623d:	83 c4 10             	add    $0x10,%esp
80106240:	85 c0                	test   %eax,%eax
80106242:	79 0d                	jns    80106251 <create+0x1c1>
    panic("create: dirlink");
80106244:	83 ec 0c             	sub    $0xc,%esp
80106247:	68 3f 97 10 80       	push   $0x8010973f
8010624c:	e8 b7 a3 ff ff       	call   80100608 <panic>

  iunlockput(dp);
80106251:	83 ec 0c             	sub    $0xc,%esp
80106254:	ff 75 f4             	pushl  -0xc(%ebp)
80106257:	e8 53 bb ff ff       	call   80101daf <iunlockput>
8010625c:	83 c4 10             	add    $0x10,%esp

  return ip;
8010625f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106262:	c9                   	leave  
80106263:	c3                   	ret    

80106264 <sys_open>:

int
sys_open(void)
{
80106264:	f3 0f 1e fb          	endbr32 
80106268:	55                   	push   %ebp
80106269:	89 e5                	mov    %esp,%ebp
8010626b:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010626e:	83 ec 08             	sub    $0x8,%esp
80106271:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106274:	50                   	push   %eax
80106275:	6a 00                	push   $0x0
80106277:	e8 b4 f6 ff ff       	call   80105930 <argstr>
8010627c:	83 c4 10             	add    $0x10,%esp
8010627f:	85 c0                	test   %eax,%eax
80106281:	78 15                	js     80106298 <sys_open+0x34>
80106283:	83 ec 08             	sub    $0x8,%esp
80106286:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106289:	50                   	push   %eax
8010628a:	6a 01                	push   $0x1
8010628c:	e8 02 f6 ff ff       	call   80105893 <argint>
80106291:	83 c4 10             	add    $0x10,%esp
80106294:	85 c0                	test   %eax,%eax
80106296:	79 0a                	jns    801062a2 <sys_open+0x3e>
    return -1;
80106298:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010629d:	e9 61 01 00 00       	jmp    80106403 <sys_open+0x19f>

  begin_op();
801062a2:	e8 9a d4 ff ff       	call   80103741 <begin_op>

  if(omode & O_CREATE){
801062a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062aa:	25 00 02 00 00       	and    $0x200,%eax
801062af:	85 c0                	test   %eax,%eax
801062b1:	74 2a                	je     801062dd <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
801062b3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062b6:	6a 00                	push   $0x0
801062b8:	6a 00                	push   $0x0
801062ba:	6a 02                	push   $0x2
801062bc:	50                   	push   %eax
801062bd:	e8 ce fd ff ff       	call   80106090 <create>
801062c2:	83 c4 10             	add    $0x10,%esp
801062c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801062c8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062cc:	75 75                	jne    80106343 <sys_open+0xdf>
      end_op();
801062ce:	e8 fe d4 ff ff       	call   801037d1 <end_op>
      return -1;
801062d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062d8:	e9 26 01 00 00       	jmp    80106403 <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
801062dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062e0:	83 ec 0c             	sub    $0xc,%esp
801062e3:	50                   	push   %eax
801062e4:	e8 f4 c3 ff ff       	call   801026dd <namei>
801062e9:	83 c4 10             	add    $0x10,%esp
801062ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062ef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062f3:	75 0f                	jne    80106304 <sys_open+0xa0>
      end_op();
801062f5:	e8 d7 d4 ff ff       	call   801037d1 <end_op>
      return -1;
801062fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062ff:	e9 ff 00 00 00       	jmp    80106403 <sys_open+0x19f>
    }
    ilock(ip);
80106304:	83 ec 0c             	sub    $0xc,%esp
80106307:	ff 75 f4             	pushl  -0xc(%ebp)
8010630a:	e8 63 b8 ff ff       	call   80101b72 <ilock>
8010630f:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106312:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106315:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106319:	66 83 f8 01          	cmp    $0x1,%ax
8010631d:	75 24                	jne    80106343 <sys_open+0xdf>
8010631f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106322:	85 c0                	test   %eax,%eax
80106324:	74 1d                	je     80106343 <sys_open+0xdf>
      iunlockput(ip);
80106326:	83 ec 0c             	sub    $0xc,%esp
80106329:	ff 75 f4             	pushl  -0xc(%ebp)
8010632c:	e8 7e ba ff ff       	call   80101daf <iunlockput>
80106331:	83 c4 10             	add    $0x10,%esp
      end_op();
80106334:	e8 98 d4 ff ff       	call   801037d1 <end_op>
      return -1;
80106339:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010633e:	e9 c0 00 00 00       	jmp    80106403 <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106343:	e8 e4 ad ff ff       	call   8010112c <filealloc>
80106348:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010634b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010634f:	74 17                	je     80106368 <sys_open+0x104>
80106351:	83 ec 0c             	sub    $0xc,%esp
80106354:	ff 75 f0             	pushl  -0x10(%ebp)
80106357:	e8 09 f7 ff ff       	call   80105a65 <fdalloc>
8010635c:	83 c4 10             	add    $0x10,%esp
8010635f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106362:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106366:	79 2e                	jns    80106396 <sys_open+0x132>
    if(f)
80106368:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010636c:	74 0e                	je     8010637c <sys_open+0x118>
      fileclose(f);
8010636e:	83 ec 0c             	sub    $0xc,%esp
80106371:	ff 75 f0             	pushl  -0x10(%ebp)
80106374:	e8 79 ae ff ff       	call   801011f2 <fileclose>
80106379:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010637c:	83 ec 0c             	sub    $0xc,%esp
8010637f:	ff 75 f4             	pushl  -0xc(%ebp)
80106382:	e8 28 ba ff ff       	call   80101daf <iunlockput>
80106387:	83 c4 10             	add    $0x10,%esp
    end_op();
8010638a:	e8 42 d4 ff ff       	call   801037d1 <end_op>
    return -1;
8010638f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106394:	eb 6d                	jmp    80106403 <sys_open+0x19f>
  }
  iunlock(ip);
80106396:	83 ec 0c             	sub    $0xc,%esp
80106399:	ff 75 f4             	pushl  -0xc(%ebp)
8010639c:	e8 e8 b8 ff ff       	call   80101c89 <iunlock>
801063a1:	83 c4 10             	add    $0x10,%esp
  end_op();
801063a4:	e8 28 d4 ff ff       	call   801037d1 <end_op>

  f->type = FD_INODE;
801063a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063ac:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801063b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063b8:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801063bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063be:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801063c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063c8:	83 e0 01             	and    $0x1,%eax
801063cb:	85 c0                	test   %eax,%eax
801063cd:	0f 94 c0             	sete   %al
801063d0:	89 c2                	mov    %eax,%edx
801063d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063d5:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801063d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063db:	83 e0 01             	and    $0x1,%eax
801063de:	85 c0                	test   %eax,%eax
801063e0:	75 0a                	jne    801063ec <sys_open+0x188>
801063e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063e5:	83 e0 02             	and    $0x2,%eax
801063e8:	85 c0                	test   %eax,%eax
801063ea:	74 07                	je     801063f3 <sys_open+0x18f>
801063ec:	b8 01 00 00 00       	mov    $0x1,%eax
801063f1:	eb 05                	jmp    801063f8 <sys_open+0x194>
801063f3:	b8 00 00 00 00       	mov    $0x0,%eax
801063f8:	89 c2                	mov    %eax,%edx
801063fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063fd:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106400:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106403:	c9                   	leave  
80106404:	c3                   	ret    

80106405 <sys_mkdir>:

int
sys_mkdir(void)
{
80106405:	f3 0f 1e fb          	endbr32 
80106409:	55                   	push   %ebp
8010640a:	89 e5                	mov    %esp,%ebp
8010640c:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010640f:	e8 2d d3 ff ff       	call   80103741 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106414:	83 ec 08             	sub    $0x8,%esp
80106417:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010641a:	50                   	push   %eax
8010641b:	6a 00                	push   $0x0
8010641d:	e8 0e f5 ff ff       	call   80105930 <argstr>
80106422:	83 c4 10             	add    $0x10,%esp
80106425:	85 c0                	test   %eax,%eax
80106427:	78 1b                	js     80106444 <sys_mkdir+0x3f>
80106429:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010642c:	6a 00                	push   $0x0
8010642e:	6a 00                	push   $0x0
80106430:	6a 01                	push   $0x1
80106432:	50                   	push   %eax
80106433:	e8 58 fc ff ff       	call   80106090 <create>
80106438:	83 c4 10             	add    $0x10,%esp
8010643b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010643e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106442:	75 0c                	jne    80106450 <sys_mkdir+0x4b>
    end_op();
80106444:	e8 88 d3 ff ff       	call   801037d1 <end_op>
    return -1;
80106449:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010644e:	eb 18                	jmp    80106468 <sys_mkdir+0x63>
  }
  iunlockput(ip);
80106450:	83 ec 0c             	sub    $0xc,%esp
80106453:	ff 75 f4             	pushl  -0xc(%ebp)
80106456:	e8 54 b9 ff ff       	call   80101daf <iunlockput>
8010645b:	83 c4 10             	add    $0x10,%esp
  end_op();
8010645e:	e8 6e d3 ff ff       	call   801037d1 <end_op>
  return 0;
80106463:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106468:	c9                   	leave  
80106469:	c3                   	ret    

8010646a <sys_mknod>:

int
sys_mknod(void)
{
8010646a:	f3 0f 1e fb          	endbr32 
8010646e:	55                   	push   %ebp
8010646f:	89 e5                	mov    %esp,%ebp
80106471:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80106474:	e8 c8 d2 ff ff       	call   80103741 <begin_op>
  if((argstr(0, &path)) < 0 ||
80106479:	83 ec 08             	sub    $0x8,%esp
8010647c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010647f:	50                   	push   %eax
80106480:	6a 00                	push   $0x0
80106482:	e8 a9 f4 ff ff       	call   80105930 <argstr>
80106487:	83 c4 10             	add    $0x10,%esp
8010648a:	85 c0                	test   %eax,%eax
8010648c:	78 4f                	js     801064dd <sys_mknod+0x73>
     argint(1, &major) < 0 ||
8010648e:	83 ec 08             	sub    $0x8,%esp
80106491:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106494:	50                   	push   %eax
80106495:	6a 01                	push   $0x1
80106497:	e8 f7 f3 ff ff       	call   80105893 <argint>
8010649c:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
8010649f:	85 c0                	test   %eax,%eax
801064a1:	78 3a                	js     801064dd <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
801064a3:	83 ec 08             	sub    $0x8,%esp
801064a6:	8d 45 e8             	lea    -0x18(%ebp),%eax
801064a9:	50                   	push   %eax
801064aa:	6a 02                	push   $0x2
801064ac:	e8 e2 f3 ff ff       	call   80105893 <argint>
801064b1:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
801064b4:	85 c0                	test   %eax,%eax
801064b6:	78 25                	js     801064dd <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
801064b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064bb:	0f bf c8             	movswl %ax,%ecx
801064be:	8b 45 ec             	mov    -0x14(%ebp),%eax
801064c1:	0f bf d0             	movswl %ax,%edx
801064c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064c7:	51                   	push   %ecx
801064c8:	52                   	push   %edx
801064c9:	6a 03                	push   $0x3
801064cb:	50                   	push   %eax
801064cc:	e8 bf fb ff ff       	call   80106090 <create>
801064d1:	83 c4 10             	add    $0x10,%esp
801064d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
801064d7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064db:	75 0c                	jne    801064e9 <sys_mknod+0x7f>
    end_op();
801064dd:	e8 ef d2 ff ff       	call   801037d1 <end_op>
    return -1;
801064e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064e7:	eb 18                	jmp    80106501 <sys_mknod+0x97>
  }
  iunlockput(ip);
801064e9:	83 ec 0c             	sub    $0xc,%esp
801064ec:	ff 75 f4             	pushl  -0xc(%ebp)
801064ef:	e8 bb b8 ff ff       	call   80101daf <iunlockput>
801064f4:	83 c4 10             	add    $0x10,%esp
  end_op();
801064f7:	e8 d5 d2 ff ff       	call   801037d1 <end_op>
  return 0;
801064fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106501:	c9                   	leave  
80106502:	c3                   	ret    

80106503 <sys_chdir>:

int
sys_chdir(void)
{
80106503:	f3 0f 1e fb          	endbr32 
80106507:	55                   	push   %ebp
80106508:	89 e5                	mov    %esp,%ebp
8010650a:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
8010650d:	e8 ee df ff ff       	call   80104500 <myproc>
80106512:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80106515:	e8 27 d2 ff ff       	call   80103741 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
8010651a:	83 ec 08             	sub    $0x8,%esp
8010651d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106520:	50                   	push   %eax
80106521:	6a 00                	push   $0x0
80106523:	e8 08 f4 ff ff       	call   80105930 <argstr>
80106528:	83 c4 10             	add    $0x10,%esp
8010652b:	85 c0                	test   %eax,%eax
8010652d:	78 18                	js     80106547 <sys_chdir+0x44>
8010652f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106532:	83 ec 0c             	sub    $0xc,%esp
80106535:	50                   	push   %eax
80106536:	e8 a2 c1 ff ff       	call   801026dd <namei>
8010653b:	83 c4 10             	add    $0x10,%esp
8010653e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106541:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106545:	75 0c                	jne    80106553 <sys_chdir+0x50>
    end_op();
80106547:	e8 85 d2 ff ff       	call   801037d1 <end_op>
    return -1;
8010654c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106551:	eb 68                	jmp    801065bb <sys_chdir+0xb8>
  }
  ilock(ip);
80106553:	83 ec 0c             	sub    $0xc,%esp
80106556:	ff 75 f0             	pushl  -0x10(%ebp)
80106559:	e8 14 b6 ff ff       	call   80101b72 <ilock>
8010655e:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106561:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106564:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106568:	66 83 f8 01          	cmp    $0x1,%ax
8010656c:	74 1a                	je     80106588 <sys_chdir+0x85>
    iunlockput(ip);
8010656e:	83 ec 0c             	sub    $0xc,%esp
80106571:	ff 75 f0             	pushl  -0x10(%ebp)
80106574:	e8 36 b8 ff ff       	call   80101daf <iunlockput>
80106579:	83 c4 10             	add    $0x10,%esp
    end_op();
8010657c:	e8 50 d2 ff ff       	call   801037d1 <end_op>
    return -1;
80106581:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106586:	eb 33                	jmp    801065bb <sys_chdir+0xb8>
  }
  iunlock(ip);
80106588:	83 ec 0c             	sub    $0xc,%esp
8010658b:	ff 75 f0             	pushl  -0x10(%ebp)
8010658e:	e8 f6 b6 ff ff       	call   80101c89 <iunlock>
80106593:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80106596:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106599:	8b 40 68             	mov    0x68(%eax),%eax
8010659c:	83 ec 0c             	sub    $0xc,%esp
8010659f:	50                   	push   %eax
801065a0:	e8 36 b7 ff ff       	call   80101cdb <iput>
801065a5:	83 c4 10             	add    $0x10,%esp
  end_op();
801065a8:	e8 24 d2 ff ff       	call   801037d1 <end_op>
  curproc->cwd = ip;
801065ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065b0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801065b3:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801065b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065bb:	c9                   	leave  
801065bc:	c3                   	ret    

801065bd <sys_exec>:

int
sys_exec(void)
{
801065bd:	f3 0f 1e fb          	endbr32 
801065c1:	55                   	push   %ebp
801065c2:	89 e5                	mov    %esp,%ebp
801065c4:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801065ca:	83 ec 08             	sub    $0x8,%esp
801065cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065d0:	50                   	push   %eax
801065d1:	6a 00                	push   $0x0
801065d3:	e8 58 f3 ff ff       	call   80105930 <argstr>
801065d8:	83 c4 10             	add    $0x10,%esp
801065db:	85 c0                	test   %eax,%eax
801065dd:	78 18                	js     801065f7 <sys_exec+0x3a>
801065df:	83 ec 08             	sub    $0x8,%esp
801065e2:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801065e8:	50                   	push   %eax
801065e9:	6a 01                	push   $0x1
801065eb:	e8 a3 f2 ff ff       	call   80105893 <argint>
801065f0:	83 c4 10             	add    $0x10,%esp
801065f3:	85 c0                	test   %eax,%eax
801065f5:	79 0a                	jns    80106601 <sys_exec+0x44>
    return -1;
801065f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065fc:	e9 c6 00 00 00       	jmp    801066c7 <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
80106601:	83 ec 04             	sub    $0x4,%esp
80106604:	68 80 00 00 00       	push   $0x80
80106609:	6a 00                	push   $0x0
8010660b:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106611:	50                   	push   %eax
80106612:	e8 28 ef ff ff       	call   8010553f <memset>
80106617:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
8010661a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106621:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106624:	83 f8 1f             	cmp    $0x1f,%eax
80106627:	76 0a                	jbe    80106633 <sys_exec+0x76>
      return -1;
80106629:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010662e:	e9 94 00 00 00       	jmp    801066c7 <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106633:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106636:	c1 e0 02             	shl    $0x2,%eax
80106639:	89 c2                	mov    %eax,%edx
8010663b:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106641:	01 c2                	add    %eax,%edx
80106643:	83 ec 08             	sub    $0x8,%esp
80106646:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
8010664c:	50                   	push   %eax
8010664d:	52                   	push   %edx
8010664e:	e8 95 f1 ff ff       	call   801057e8 <fetchint>
80106653:	83 c4 10             	add    $0x10,%esp
80106656:	85 c0                	test   %eax,%eax
80106658:	79 07                	jns    80106661 <sys_exec+0xa4>
      return -1;
8010665a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010665f:	eb 66                	jmp    801066c7 <sys_exec+0x10a>
    if(uarg == 0){
80106661:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106667:	85 c0                	test   %eax,%eax
80106669:	75 27                	jne    80106692 <sys_exec+0xd5>
      argv[i] = 0;
8010666b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010666e:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106675:	00 00 00 00 
      break;
80106679:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
8010667a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010667d:	83 ec 08             	sub    $0x8,%esp
80106680:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106686:	52                   	push   %edx
80106687:	50                   	push   %eax
80106688:	e8 a3 a5 ff ff       	call   80100c30 <exec>
8010668d:	83 c4 10             	add    $0x10,%esp
80106690:	eb 35                	jmp    801066c7 <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
80106692:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106698:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010669b:	c1 e2 02             	shl    $0x2,%edx
8010669e:	01 c2                	add    %eax,%edx
801066a0:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801066a6:	83 ec 08             	sub    $0x8,%esp
801066a9:	52                   	push   %edx
801066aa:	50                   	push   %eax
801066ab:	e8 7b f1 ff ff       	call   8010582b <fetchstr>
801066b0:	83 c4 10             	add    $0x10,%esp
801066b3:	85 c0                	test   %eax,%eax
801066b5:	79 07                	jns    801066be <sys_exec+0x101>
      return -1;
801066b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066bc:	eb 09                	jmp    801066c7 <sys_exec+0x10a>
  for(i=0;; i++){
801066be:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
801066c2:	e9 5a ff ff ff       	jmp    80106621 <sys_exec+0x64>
}
801066c7:	c9                   	leave  
801066c8:	c3                   	ret    

801066c9 <sys_pipe>:

int
sys_pipe(void)
{
801066c9:	f3 0f 1e fb          	endbr32 
801066cd:	55                   	push   %ebp
801066ce:	89 e5                	mov    %esp,%ebp
801066d0:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801066d3:	83 ec 04             	sub    $0x4,%esp
801066d6:	6a 08                	push   $0x8
801066d8:	8d 45 ec             	lea    -0x14(%ebp),%eax
801066db:	50                   	push   %eax
801066dc:	6a 00                	push   $0x0
801066de:	e8 e1 f1 ff ff       	call   801058c4 <argptr>
801066e3:	83 c4 10             	add    $0x10,%esp
801066e6:	85 c0                	test   %eax,%eax
801066e8:	79 0a                	jns    801066f4 <sys_pipe+0x2b>
    return -1;
801066ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066ef:	e9 ae 00 00 00       	jmp    801067a2 <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
801066f4:	83 ec 08             	sub    $0x8,%esp
801066f7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801066fa:	50                   	push   %eax
801066fb:	8d 45 e8             	lea    -0x18(%ebp),%eax
801066fe:	50                   	push   %eax
801066ff:	e8 1d d9 ff ff       	call   80104021 <pipealloc>
80106704:	83 c4 10             	add    $0x10,%esp
80106707:	85 c0                	test   %eax,%eax
80106709:	79 0a                	jns    80106715 <sys_pipe+0x4c>
    return -1;
8010670b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106710:	e9 8d 00 00 00       	jmp    801067a2 <sys_pipe+0xd9>
  fd0 = -1;
80106715:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010671c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010671f:	83 ec 0c             	sub    $0xc,%esp
80106722:	50                   	push   %eax
80106723:	e8 3d f3 ff ff       	call   80105a65 <fdalloc>
80106728:	83 c4 10             	add    $0x10,%esp
8010672b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010672e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106732:	78 18                	js     8010674c <sys_pipe+0x83>
80106734:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106737:	83 ec 0c             	sub    $0xc,%esp
8010673a:	50                   	push   %eax
8010673b:	e8 25 f3 ff ff       	call   80105a65 <fdalloc>
80106740:	83 c4 10             	add    $0x10,%esp
80106743:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106746:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010674a:	79 3e                	jns    8010678a <sys_pipe+0xc1>
    if(fd0 >= 0)
8010674c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106750:	78 13                	js     80106765 <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
80106752:	e8 a9 dd ff ff       	call   80104500 <myproc>
80106757:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010675a:	83 c2 08             	add    $0x8,%edx
8010675d:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106764:	00 
    fileclose(rf);
80106765:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106768:	83 ec 0c             	sub    $0xc,%esp
8010676b:	50                   	push   %eax
8010676c:	e8 81 aa ff ff       	call   801011f2 <fileclose>
80106771:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106774:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106777:	83 ec 0c             	sub    $0xc,%esp
8010677a:	50                   	push   %eax
8010677b:	e8 72 aa ff ff       	call   801011f2 <fileclose>
80106780:	83 c4 10             	add    $0x10,%esp
    return -1;
80106783:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106788:	eb 18                	jmp    801067a2 <sys_pipe+0xd9>
  }
  fd[0] = fd0;
8010678a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010678d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106790:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106792:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106795:	8d 50 04             	lea    0x4(%eax),%edx
80106798:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010679b:	89 02                	mov    %eax,(%edx)
  return 0;
8010679d:	b8 00 00 00 00       	mov    $0x0,%eax
}
801067a2:	c9                   	leave  
801067a3:	c3                   	ret    

801067a4 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801067a4:	f3 0f 1e fb          	endbr32 
801067a8:	55                   	push   %ebp
801067a9:	89 e5                	mov    %esp,%ebp
801067ab:	83 ec 08             	sub    $0x8,%esp
  return fork();
801067ae:	e8 ac e0 ff ff       	call   8010485f <fork>
}
801067b3:	c9                   	leave  
801067b4:	c3                   	ret    

801067b5 <sys_exit>:

int
sys_exit(void)
{
801067b5:	f3 0f 1e fb          	endbr32 
801067b9:	55                   	push   %ebp
801067ba:	89 e5                	mov    %esp,%ebp
801067bc:	83 ec 08             	sub    $0x8,%esp
  exit();
801067bf:	e8 18 e2 ff ff       	call   801049dc <exit>
  return 0;  // not reached
801067c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801067c9:	c9                   	leave  
801067ca:	c3                   	ret    

801067cb <sys_wait>:

int
sys_wait(void)
{
801067cb:	f3 0f 1e fb          	endbr32 
801067cf:	55                   	push   %ebp
801067d0:	89 e5                	mov    %esp,%ebp
801067d2:	83 ec 08             	sub    $0x8,%esp
  return wait();
801067d5:	e8 29 e3 ff ff       	call   80104b03 <wait>
}
801067da:	c9                   	leave  
801067db:	c3                   	ret    

801067dc <sys_kill>:

int
sys_kill(void)
{
801067dc:	f3 0f 1e fb          	endbr32 
801067e0:	55                   	push   %ebp
801067e1:	89 e5                	mov    %esp,%ebp
801067e3:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801067e6:	83 ec 08             	sub    $0x8,%esp
801067e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801067ec:	50                   	push   %eax
801067ed:	6a 00                	push   $0x0
801067ef:	e8 9f f0 ff ff       	call   80105893 <argint>
801067f4:	83 c4 10             	add    $0x10,%esp
801067f7:	85 c0                	test   %eax,%eax
801067f9:	79 07                	jns    80106802 <sys_kill+0x26>
    return -1;
801067fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106800:	eb 0f                	jmp    80106811 <sys_kill+0x35>
  return kill(pid);
80106802:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106805:	83 ec 0c             	sub    $0xc,%esp
80106808:	50                   	push   %eax
80106809:	e8 4d e7 ff ff       	call   80104f5b <kill>
8010680e:	83 c4 10             	add    $0x10,%esp
}
80106811:	c9                   	leave  
80106812:	c3                   	ret    

80106813 <sys_getpid>:

int
sys_getpid(void)
{
80106813:	f3 0f 1e fb          	endbr32 
80106817:	55                   	push   %ebp
80106818:	89 e5                	mov    %esp,%ebp
8010681a:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
8010681d:	e8 de dc ff ff       	call   80104500 <myproc>
80106822:	8b 40 10             	mov    0x10(%eax),%eax
}
80106825:	c9                   	leave  
80106826:	c3                   	ret    

80106827 <sys_sbrk>:

int
sys_sbrk(void)
{
80106827:	f3 0f 1e fb          	endbr32 
8010682b:	55                   	push   %ebp
8010682c:	89 e5                	mov    %esp,%ebp
8010682e:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106831:	83 ec 08             	sub    $0x8,%esp
80106834:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106837:	50                   	push   %eax
80106838:	6a 00                	push   $0x0
8010683a:	e8 54 f0 ff ff       	call   80105893 <argint>
8010683f:	83 c4 10             	add    $0x10,%esp
80106842:	85 c0                	test   %eax,%eax
80106844:	79 07                	jns    8010684d <sys_sbrk+0x26>
    return -1;
80106846:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010684b:	eb 27                	jmp    80106874 <sys_sbrk+0x4d>
  addr = myproc()->sz;
8010684d:	e8 ae dc ff ff       	call   80104500 <myproc>
80106852:	8b 00                	mov    (%eax),%eax
80106854:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106857:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010685a:	83 ec 0c             	sub    $0xc,%esp
8010685d:	50                   	push   %eax
8010685e:	e8 14 df ff ff       	call   80104777 <growproc>
80106863:	83 c4 10             	add    $0x10,%esp
80106866:	85 c0                	test   %eax,%eax
80106868:	79 07                	jns    80106871 <sys_sbrk+0x4a>
    return -1;
8010686a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010686f:	eb 03                	jmp    80106874 <sys_sbrk+0x4d>
  return addr;
80106871:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106874:	c9                   	leave  
80106875:	c3                   	ret    

80106876 <sys_sleep>:

int
sys_sleep(void)
{
80106876:	f3 0f 1e fb          	endbr32 
8010687a:	55                   	push   %ebp
8010687b:	89 e5                	mov    %esp,%ebp
8010687d:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106880:	83 ec 08             	sub    $0x8,%esp
80106883:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106886:	50                   	push   %eax
80106887:	6a 00                	push   $0x0
80106889:	e8 05 f0 ff ff       	call   80105893 <argint>
8010688e:	83 c4 10             	add    $0x10,%esp
80106891:	85 c0                	test   %eax,%eax
80106893:	79 07                	jns    8010689c <sys_sleep+0x26>
    return -1;
80106895:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010689a:	eb 76                	jmp    80106912 <sys_sleep+0x9c>
  acquire(&tickslock);
8010689c:	83 ec 0c             	sub    $0xc,%esp
8010689f:	68 00 77 11 80       	push   $0x80117700
801068a4:	e8 f7 e9 ff ff       	call   801052a0 <acquire>
801068a9:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801068ac:	a1 40 7f 11 80       	mov    0x80117f40,%eax
801068b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801068b4:	eb 38                	jmp    801068ee <sys_sleep+0x78>
    if(myproc()->killed){
801068b6:	e8 45 dc ff ff       	call   80104500 <myproc>
801068bb:	8b 40 24             	mov    0x24(%eax),%eax
801068be:	85 c0                	test   %eax,%eax
801068c0:	74 17                	je     801068d9 <sys_sleep+0x63>
      release(&tickslock);
801068c2:	83 ec 0c             	sub    $0xc,%esp
801068c5:	68 00 77 11 80       	push   $0x80117700
801068ca:	e8 43 ea ff ff       	call   80105312 <release>
801068cf:	83 c4 10             	add    $0x10,%esp
      return -1;
801068d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068d7:	eb 39                	jmp    80106912 <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
801068d9:	83 ec 08             	sub    $0x8,%esp
801068dc:	68 00 77 11 80       	push   $0x80117700
801068e1:	68 40 7f 11 80       	push   $0x80117f40
801068e6:	e8 43 e5 ff ff       	call   80104e2e <sleep>
801068eb:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
801068ee:	a1 40 7f 11 80       	mov    0x80117f40,%eax
801068f3:	2b 45 f4             	sub    -0xc(%ebp),%eax
801068f6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801068f9:	39 d0                	cmp    %edx,%eax
801068fb:	72 b9                	jb     801068b6 <sys_sleep+0x40>
  }
  release(&tickslock);
801068fd:	83 ec 0c             	sub    $0xc,%esp
80106900:	68 00 77 11 80       	push   $0x80117700
80106905:	e8 08 ea ff ff       	call   80105312 <release>
8010690a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010690d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106912:	c9                   	leave  
80106913:	c3                   	ret    

80106914 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106914:	f3 0f 1e fb          	endbr32 
80106918:	55                   	push   %ebp
80106919:	89 e5                	mov    %esp,%ebp
8010691b:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
8010691e:	83 ec 0c             	sub    $0xc,%esp
80106921:	68 00 77 11 80       	push   $0x80117700
80106926:	e8 75 e9 ff ff       	call   801052a0 <acquire>
8010692b:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
8010692e:	a1 40 7f 11 80       	mov    0x80117f40,%eax
80106933:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106936:	83 ec 0c             	sub    $0xc,%esp
80106939:	68 00 77 11 80       	push   $0x80117700
8010693e:	e8 cf e9 ff ff       	call   80105312 <release>
80106943:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106946:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106949:	c9                   	leave  
8010694a:	c3                   	ret    

8010694b <sys_mencrypt>:

//changed: added wrapper here
int sys_mencrypt(void) {
8010694b:	f3 0f 1e fb          	endbr32 
8010694f:	55                   	push   %ebp
80106950:	89 e5                	mov    %esp,%ebp
80106952:	83 ec 18             	sub    $0x18,%esp
  int len;
  char * virtual_addr;

  if(argint(1, &len) < 0)
80106955:	83 ec 08             	sub    $0x8,%esp
80106958:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010695b:	50                   	push   %eax
8010695c:	6a 01                	push   $0x1
8010695e:	e8 30 ef ff ff       	call   80105893 <argint>
80106963:	83 c4 10             	add    $0x10,%esp
80106966:	85 c0                	test   %eax,%eax
80106968:	79 07                	jns    80106971 <sys_mencrypt+0x26>
    return -1;
8010696a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010696f:	eb 50                	jmp    801069c1 <sys_mencrypt+0x76>
  if (len <= 0) {
80106971:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106974:	85 c0                	test   %eax,%eax
80106976:	7f 07                	jg     8010697f <sys_mencrypt+0x34>
    return -1;
80106978:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010697d:	eb 42                	jmp    801069c1 <sys_mencrypt+0x76>
  }
  if(argptr(0, &virtual_addr, 1) < 0)
8010697f:	83 ec 04             	sub    $0x4,%esp
80106982:	6a 01                	push   $0x1
80106984:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106987:	50                   	push   %eax
80106988:	6a 00                	push   $0x0
8010698a:	e8 35 ef ff ff       	call   801058c4 <argptr>
8010698f:	83 c4 10             	add    $0x10,%esp
80106992:	85 c0                	test   %eax,%eax
80106994:	79 07                	jns    8010699d <sys_mencrypt+0x52>
    return -1;
80106996:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010699b:	eb 24                	jmp    801069c1 <sys_mencrypt+0x76>
  if ((void *) virtual_addr >= P2V(PHYSTOP)) {
8010699d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069a0:	3d ff ff ff 8d       	cmp    $0x8dffffff,%eax
801069a5:	76 07                	jbe    801069ae <sys_mencrypt+0x63>
    return -1;
801069a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069ac:	eb 13                	jmp    801069c1 <sys_mencrypt+0x76>
  }
  return mencrypt(virtual_addr, len);
801069ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
801069b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069b4:	83 ec 08             	sub    $0x8,%esp
801069b7:	52                   	push   %edx
801069b8:	50                   	push   %eax
801069b9:	e8 c9 21 00 00       	call   80108b87 <mencrypt>
801069be:	83 c4 10             	add    $0x10,%esp
}
801069c1:	c9                   	leave  
801069c2:	c3                   	ret    

801069c3 <sys_getpgtable>:

int sys_getpgtable(void) {
801069c3:	f3 0f 1e fb          	endbr32 
801069c7:	55                   	push   %ebp
801069c8:	89 e5                	mov    %esp,%ebp
801069ca:	83 ec 18             	sub    $0x18,%esp
  struct pt_entry * entries; 
  int num,wsetOnly;

  if(argint(1, &num) < 0){
801069cd:	83 ec 08             	sub    $0x8,%esp
801069d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801069d3:	50                   	push   %eax
801069d4:	6a 01                	push   $0x1
801069d6:	e8 b8 ee ff ff       	call   80105893 <argint>
801069db:	83 c4 10             	add    $0x10,%esp
801069de:	85 c0                	test   %eax,%eax
801069e0:	79 07                	jns    801069e9 <sys_getpgtable+0x26>
    return -1;
801069e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069e7:	eb 56                	jmp    80106a3f <sys_getpgtable+0x7c>
  }
  if(argint(2, &wsetOnly) < 0){
801069e9:	83 ec 08             	sub    $0x8,%esp
801069ec:	8d 45 ec             	lea    -0x14(%ebp),%eax
801069ef:	50                   	push   %eax
801069f0:	6a 02                	push   $0x2
801069f2:	e8 9c ee ff ff       	call   80105893 <argint>
801069f7:	83 c4 10             	add    $0x10,%esp
801069fa:	85 c0                	test   %eax,%eax
801069fc:	79 07                	jns    80106a05 <sys_getpgtable+0x42>
    return -1;
801069fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a03:	eb 3a                	jmp    80106a3f <sys_getpgtable+0x7c>
  }
  if(argptr(0, (char**)&entries, num*sizeof(struct pt_entry)) < 0){
80106a05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a08:	c1 e0 03             	shl    $0x3,%eax
80106a0b:	83 ec 04             	sub    $0x4,%esp
80106a0e:	50                   	push   %eax
80106a0f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a12:	50                   	push   %eax
80106a13:	6a 00                	push   $0x0
80106a15:	e8 aa ee ff ff       	call   801058c4 <argptr>
80106a1a:	83 c4 10             	add    $0x10,%esp
80106a1d:	85 c0                	test   %eax,%eax
80106a1f:	79 07                	jns    80106a28 <sys_getpgtable+0x65>
    return -1;
80106a21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a26:	eb 17                	jmp    80106a3f <sys_getpgtable+0x7c>
  }
  return getpgtable(entries, num,wsetOnly);
80106a28:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80106a2b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a31:	83 ec 04             	sub    $0x4,%esp
80106a34:	51                   	push   %ecx
80106a35:	52                   	push   %edx
80106a36:	50                   	push   %eax
80106a37:	e8 40 23 00 00       	call   80108d7c <getpgtable>
80106a3c:	83 c4 10             	add    $0x10,%esp
}
80106a3f:	c9                   	leave  
80106a40:	c3                   	ret    

80106a41 <sys_dump_rawphymem>:


int sys_dump_rawphymem(void) {
80106a41:	f3 0f 1e fb          	endbr32 
80106a45:	55                   	push   %ebp
80106a46:	89 e5                	mov    %esp,%ebp
80106a48:	83 ec 18             	sub    $0x18,%esp
  char * physical_addr; 
  char * buffer;

  if(argptr(1, &buffer, PGSIZE) < 0)
80106a4b:	83 ec 04             	sub    $0x4,%esp
80106a4e:	68 00 10 00 00       	push   $0x1000
80106a53:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a56:	50                   	push   %eax
80106a57:	6a 01                	push   $0x1
80106a59:	e8 66 ee ff ff       	call   801058c4 <argptr>
80106a5e:	83 c4 10             	add    $0x10,%esp
80106a61:	85 c0                	test   %eax,%eax
80106a63:	79 07                	jns    80106a6c <sys_dump_rawphymem+0x2b>
    return -1;
80106a65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a6a:	eb 2f                	jmp    80106a9b <sys_dump_rawphymem+0x5a>
  if(argint(0, (int*)&physical_addr) < 0)
80106a6c:	83 ec 08             	sub    $0x8,%esp
80106a6f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a72:	50                   	push   %eax
80106a73:	6a 00                	push   $0x0
80106a75:	e8 19 ee ff ff       	call   80105893 <argint>
80106a7a:	83 c4 10             	add    $0x10,%esp
80106a7d:	85 c0                	test   %eax,%eax
80106a7f:	79 07                	jns    80106a88 <sys_dump_rawphymem+0x47>
    return -1;
80106a81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a86:	eb 13                	jmp    80106a9b <sys_dump_rawphymem+0x5a>
  return dump_rawphymem(physical_addr,buffer);
80106a88:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a8e:	83 ec 08             	sub    $0x8,%esp
80106a91:	52                   	push   %edx
80106a92:	50                   	push   %eax
80106a93:	e8 57 25 00 00       	call   80108fef <dump_rawphymem>
80106a98:	83 c4 10             	add    $0x10,%esp
80106a9b:	c9                   	leave  
80106a9c:	c3                   	ret    

80106a9d <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106a9d:	1e                   	push   %ds
  pushl %es
80106a9e:	06                   	push   %es
  pushl %fs
80106a9f:	0f a0                	push   %fs
  pushl %gs
80106aa1:	0f a8                	push   %gs
  pushal
80106aa3:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106aa4:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106aa8:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106aaa:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106aac:	54                   	push   %esp
  call trap
80106aad:	e8 df 01 00 00       	call   80106c91 <trap>
  addl $4, %esp
80106ab2:	83 c4 04             	add    $0x4,%esp

80106ab5 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106ab5:	61                   	popa   
  popl %gs
80106ab6:	0f a9                	pop    %gs
  popl %fs
80106ab8:	0f a1                	pop    %fs
  popl %es
80106aba:	07                   	pop    %es
  popl %ds
80106abb:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106abc:	83 c4 08             	add    $0x8,%esp
  iret
80106abf:	cf                   	iret   

80106ac0 <lidt>:
{
80106ac0:	55                   	push   %ebp
80106ac1:	89 e5                	mov    %esp,%ebp
80106ac3:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106ac6:	8b 45 0c             	mov    0xc(%ebp),%eax
80106ac9:	83 e8 01             	sub    $0x1,%eax
80106acc:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106ad0:	8b 45 08             	mov    0x8(%ebp),%eax
80106ad3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106ad7:	8b 45 08             	mov    0x8(%ebp),%eax
80106ada:	c1 e8 10             	shr    $0x10,%eax
80106add:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106ae1:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106ae4:	0f 01 18             	lidtl  (%eax)
}
80106ae7:	90                   	nop
80106ae8:	c9                   	leave  
80106ae9:	c3                   	ret    

80106aea <rcr2>:

static inline uint
rcr2(void)
{
80106aea:	55                   	push   %ebp
80106aeb:	89 e5                	mov    %esp,%ebp
80106aed:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106af0:	0f 20 d0             	mov    %cr2,%eax
80106af3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106af6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106af9:	c9                   	leave  
80106afa:	c3                   	ret    

80106afb <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106afb:	f3 0f 1e fb          	endbr32 
80106aff:	55                   	push   %ebp
80106b00:	89 e5                	mov    %esp,%ebp
80106b02:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106b05:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106b0c:	e9 c3 00 00 00       	jmp    80106bd4 <tvinit+0xd9>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b14:	8b 04 85 84 c0 10 80 	mov    -0x7fef3f7c(,%eax,4),%eax
80106b1b:	89 c2                	mov    %eax,%edx
80106b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b20:	66 89 14 c5 40 77 11 	mov    %dx,-0x7fee88c0(,%eax,8)
80106b27:	80 
80106b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b2b:	66 c7 04 c5 42 77 11 	movw   $0x8,-0x7fee88be(,%eax,8)
80106b32:	80 08 00 
80106b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b38:	0f b6 14 c5 44 77 11 	movzbl -0x7fee88bc(,%eax,8),%edx
80106b3f:	80 
80106b40:	83 e2 e0             	and    $0xffffffe0,%edx
80106b43:	88 14 c5 44 77 11 80 	mov    %dl,-0x7fee88bc(,%eax,8)
80106b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b4d:	0f b6 14 c5 44 77 11 	movzbl -0x7fee88bc(,%eax,8),%edx
80106b54:	80 
80106b55:	83 e2 1f             	and    $0x1f,%edx
80106b58:	88 14 c5 44 77 11 80 	mov    %dl,-0x7fee88bc(,%eax,8)
80106b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b62:	0f b6 14 c5 45 77 11 	movzbl -0x7fee88bb(,%eax,8),%edx
80106b69:	80 
80106b6a:	83 e2 f0             	and    $0xfffffff0,%edx
80106b6d:	83 ca 0e             	or     $0xe,%edx
80106b70:	88 14 c5 45 77 11 80 	mov    %dl,-0x7fee88bb(,%eax,8)
80106b77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b7a:	0f b6 14 c5 45 77 11 	movzbl -0x7fee88bb(,%eax,8),%edx
80106b81:	80 
80106b82:	83 e2 ef             	and    $0xffffffef,%edx
80106b85:	88 14 c5 45 77 11 80 	mov    %dl,-0x7fee88bb(,%eax,8)
80106b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b8f:	0f b6 14 c5 45 77 11 	movzbl -0x7fee88bb(,%eax,8),%edx
80106b96:	80 
80106b97:	83 e2 9f             	and    $0xffffff9f,%edx
80106b9a:	88 14 c5 45 77 11 80 	mov    %dl,-0x7fee88bb(,%eax,8)
80106ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ba4:	0f b6 14 c5 45 77 11 	movzbl -0x7fee88bb(,%eax,8),%edx
80106bab:	80 
80106bac:	83 ca 80             	or     $0xffffff80,%edx
80106baf:	88 14 c5 45 77 11 80 	mov    %dl,-0x7fee88bb(,%eax,8)
80106bb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bb9:	8b 04 85 84 c0 10 80 	mov    -0x7fef3f7c(,%eax,4),%eax
80106bc0:	c1 e8 10             	shr    $0x10,%eax
80106bc3:	89 c2                	mov    %eax,%edx
80106bc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bc8:	66 89 14 c5 46 77 11 	mov    %dx,-0x7fee88ba(,%eax,8)
80106bcf:	80 
  for(i = 0; i < 256; i++)
80106bd0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106bd4:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106bdb:	0f 8e 30 ff ff ff    	jle    80106b11 <tvinit+0x16>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106be1:	a1 84 c1 10 80       	mov    0x8010c184,%eax
80106be6:	66 a3 40 79 11 80    	mov    %ax,0x80117940
80106bec:	66 c7 05 42 79 11 80 	movw   $0x8,0x80117942
80106bf3:	08 00 
80106bf5:	0f b6 05 44 79 11 80 	movzbl 0x80117944,%eax
80106bfc:	83 e0 e0             	and    $0xffffffe0,%eax
80106bff:	a2 44 79 11 80       	mov    %al,0x80117944
80106c04:	0f b6 05 44 79 11 80 	movzbl 0x80117944,%eax
80106c0b:	83 e0 1f             	and    $0x1f,%eax
80106c0e:	a2 44 79 11 80       	mov    %al,0x80117944
80106c13:	0f b6 05 45 79 11 80 	movzbl 0x80117945,%eax
80106c1a:	83 c8 0f             	or     $0xf,%eax
80106c1d:	a2 45 79 11 80       	mov    %al,0x80117945
80106c22:	0f b6 05 45 79 11 80 	movzbl 0x80117945,%eax
80106c29:	83 e0 ef             	and    $0xffffffef,%eax
80106c2c:	a2 45 79 11 80       	mov    %al,0x80117945
80106c31:	0f b6 05 45 79 11 80 	movzbl 0x80117945,%eax
80106c38:	83 c8 60             	or     $0x60,%eax
80106c3b:	a2 45 79 11 80       	mov    %al,0x80117945
80106c40:	0f b6 05 45 79 11 80 	movzbl 0x80117945,%eax
80106c47:	83 c8 80             	or     $0xffffff80,%eax
80106c4a:	a2 45 79 11 80       	mov    %al,0x80117945
80106c4f:	a1 84 c1 10 80       	mov    0x8010c184,%eax
80106c54:	c1 e8 10             	shr    $0x10,%eax
80106c57:	66 a3 46 79 11 80    	mov    %ax,0x80117946

  initlock(&tickslock, "time");
80106c5d:	83 ec 08             	sub    $0x8,%esp
80106c60:	68 50 97 10 80       	push   $0x80109750
80106c65:	68 00 77 11 80       	push   $0x80117700
80106c6a:	e8 0b e6 ff ff       	call   8010527a <initlock>
80106c6f:	83 c4 10             	add    $0x10,%esp
}
80106c72:	90                   	nop
80106c73:	c9                   	leave  
80106c74:	c3                   	ret    

80106c75 <idtinit>:

void
idtinit(void)
{
80106c75:	f3 0f 1e fb          	endbr32 
80106c79:	55                   	push   %ebp
80106c7a:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106c7c:	68 00 08 00 00       	push   $0x800
80106c81:	68 40 77 11 80       	push   $0x80117740
80106c86:	e8 35 fe ff ff       	call   80106ac0 <lidt>
80106c8b:	83 c4 08             	add    $0x8,%esp
}
80106c8e:	90                   	nop
80106c8f:	c9                   	leave  
80106c90:	c3                   	ret    

80106c91 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106c91:	f3 0f 1e fb          	endbr32 
80106c95:	55                   	push   %ebp
80106c96:	89 e5                	mov    %esp,%ebp
80106c98:	57                   	push   %edi
80106c99:	56                   	push   %esi
80106c9a:	53                   	push   %ebx
80106c9b:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
80106c9e:	8b 45 08             	mov    0x8(%ebp),%eax
80106ca1:	8b 40 30             	mov    0x30(%eax),%eax
80106ca4:	83 f8 40             	cmp    $0x40,%eax
80106ca7:	75 3b                	jne    80106ce4 <trap+0x53>
    if(myproc()->killed)
80106ca9:	e8 52 d8 ff ff       	call   80104500 <myproc>
80106cae:	8b 40 24             	mov    0x24(%eax),%eax
80106cb1:	85 c0                	test   %eax,%eax
80106cb3:	74 05                	je     80106cba <trap+0x29>
      exit();
80106cb5:	e8 22 dd ff ff       	call   801049dc <exit>
    myproc()->tf = tf;
80106cba:	e8 41 d8 ff ff       	call   80104500 <myproc>
80106cbf:	8b 55 08             	mov    0x8(%ebp),%edx
80106cc2:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106cc5:	e8 a1 ec ff ff       	call   8010596b <syscall>
    if(myproc()->killed)
80106cca:	e8 31 d8 ff ff       	call   80104500 <myproc>
80106ccf:	8b 40 24             	mov    0x24(%eax),%eax
80106cd2:	85 c0                	test   %eax,%eax
80106cd4:	0f 84 42 02 00 00    	je     80106f1c <trap+0x28b>
      exit();
80106cda:	e8 fd dc ff ff       	call   801049dc <exit>
    return;
80106cdf:	e9 38 02 00 00       	jmp    80106f1c <trap+0x28b>
  }
  char *addr;
  switch(tf->trapno){
80106ce4:	8b 45 08             	mov    0x8(%ebp),%eax
80106ce7:	8b 40 30             	mov    0x30(%eax),%eax
80106cea:	83 e8 0e             	sub    $0xe,%eax
80106ced:	83 f8 31             	cmp    $0x31,%eax
80106cf0:	0f 87 ee 00 00 00    	ja     80106de4 <trap+0x153>
80106cf6:	8b 04 85 10 98 10 80 	mov    -0x7fef67f0(,%eax,4),%eax
80106cfd:	3e ff e0             	notrack jmp *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106d00:	e8 60 d7 ff ff       	call   80104465 <cpuid>
80106d05:	85 c0                	test   %eax,%eax
80106d07:	75 3d                	jne    80106d46 <trap+0xb5>
      acquire(&tickslock);
80106d09:	83 ec 0c             	sub    $0xc,%esp
80106d0c:	68 00 77 11 80       	push   $0x80117700
80106d11:	e8 8a e5 ff ff       	call   801052a0 <acquire>
80106d16:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106d19:	a1 40 7f 11 80       	mov    0x80117f40,%eax
80106d1e:	83 c0 01             	add    $0x1,%eax
80106d21:	a3 40 7f 11 80       	mov    %eax,0x80117f40
      wakeup(&ticks);
80106d26:	83 ec 0c             	sub    $0xc,%esp
80106d29:	68 40 7f 11 80       	push   $0x80117f40
80106d2e:	e8 ed e1 ff ff       	call   80104f20 <wakeup>
80106d33:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106d36:	83 ec 0c             	sub    $0xc,%esp
80106d39:	68 00 77 11 80       	push   $0x80117700
80106d3e:	e8 cf e5 ff ff       	call   80105312 <release>
80106d43:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106d46:	e8 aa c4 ff ff       	call   801031f5 <lapiceoi>
    break;
80106d4b:	e9 4c 01 00 00       	jmp    80106e9c <trap+0x20b>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106d50:	e8 d5 bc ff ff       	call   80102a2a <ideintr>
    lapiceoi();
80106d55:	e8 9b c4 ff ff       	call   801031f5 <lapiceoi>
    break;
80106d5a:	e9 3d 01 00 00       	jmp    80106e9c <trap+0x20b>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106d5f:	e8 c7 c2 ff ff       	call   8010302b <kbdintr>
    lapiceoi();
80106d64:	e8 8c c4 ff ff       	call   801031f5 <lapiceoi>
    break;
80106d69:	e9 2e 01 00 00       	jmp    80106e9c <trap+0x20b>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106d6e:	e8 8b 03 00 00       	call   801070fe <uartintr>
    lapiceoi();
80106d73:	e8 7d c4 ff ff       	call   801031f5 <lapiceoi>
    break;
80106d78:	e9 1f 01 00 00       	jmp    80106e9c <trap+0x20b>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106d7d:	8b 45 08             	mov    0x8(%ebp),%eax
80106d80:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106d83:	8b 45 08             	mov    0x8(%ebp),%eax
80106d86:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106d8a:	0f b7 d8             	movzwl %ax,%ebx
80106d8d:	e8 d3 d6 ff ff       	call   80104465 <cpuid>
80106d92:	56                   	push   %esi
80106d93:	53                   	push   %ebx
80106d94:	50                   	push   %eax
80106d95:	68 58 97 10 80       	push   $0x80109758
80106d9a:	e8 79 96 ff ff       	call   80100418 <cprintf>
80106d9f:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106da2:	e8 4e c4 ff ff       	call   801031f5 <lapiceoi>
    break;
80106da7:	e9 f0 00 00 00       	jmp    80106e9c <trap+0x20b>
  case T_PGFLT:
    //Food for thought: How can one distinguish between a regular page fault and a decryption request?
    cprintf("p4Debug : Page fault !\n");
80106dac:	83 ec 0c             	sub    $0xc,%esp
80106daf:	68 7c 97 10 80       	push   $0x8010977c
80106db4:	e8 5f 96 ff ff       	call   80100418 <cprintf>
80106db9:	83 c4 10             	add    $0x10,%esp
    addr = (char*)rcr2();
80106dbc:	e8 29 fd ff ff       	call   80106aea <rcr2>
80106dc1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (mdecrypt(addr))
80106dc4:	83 ec 0c             	sub    $0xc,%esp
80106dc7:	ff 75 e4             	pushl  -0x1c(%ebp)
80106dca:	e8 28 1c 00 00       	call   801089f7 <mdecrypt>
80106dcf:	83 c4 10             	add    $0x10,%esp
80106dd2:	85 c0                	test   %eax,%eax
80106dd4:	0f 84 c1 00 00 00    	je     80106e9b <trap+0x20a>
    {
       
       // panic("p4Debug: Memory fault");
        exit();
80106dda:	e8 fd db ff ff       	call   801049dc <exit>
    };
    break;
80106ddf:	e9 b7 00 00 00       	jmp    80106e9b <trap+0x20a>
  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106de4:	e8 17 d7 ff ff       	call   80104500 <myproc>
80106de9:	85 c0                	test   %eax,%eax
80106deb:	74 11                	je     80106dfe <trap+0x16d>
80106ded:	8b 45 08             	mov    0x8(%ebp),%eax
80106df0:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106df4:	0f b7 c0             	movzwl %ax,%eax
80106df7:	83 e0 03             	and    $0x3,%eax
80106dfa:	85 c0                	test   %eax,%eax
80106dfc:	75 39                	jne    80106e37 <trap+0x1a6>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106dfe:	e8 e7 fc ff ff       	call   80106aea <rcr2>
80106e03:	89 c3                	mov    %eax,%ebx
80106e05:	8b 45 08             	mov    0x8(%ebp),%eax
80106e08:	8b 70 38             	mov    0x38(%eax),%esi
80106e0b:	e8 55 d6 ff ff       	call   80104465 <cpuid>
80106e10:	8b 55 08             	mov    0x8(%ebp),%edx
80106e13:	8b 52 30             	mov    0x30(%edx),%edx
80106e16:	83 ec 0c             	sub    $0xc,%esp
80106e19:	53                   	push   %ebx
80106e1a:	56                   	push   %esi
80106e1b:	50                   	push   %eax
80106e1c:	52                   	push   %edx
80106e1d:	68 94 97 10 80       	push   $0x80109794
80106e22:	e8 f1 95 ff ff       	call   80100418 <cprintf>
80106e27:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106e2a:	83 ec 0c             	sub    $0xc,%esp
80106e2d:	68 c6 97 10 80       	push   $0x801097c6
80106e32:	e8 d1 97 ff ff       	call   80100608 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e37:	e8 ae fc ff ff       	call   80106aea <rcr2>
80106e3c:	89 c6                	mov    %eax,%esi
80106e3e:	8b 45 08             	mov    0x8(%ebp),%eax
80106e41:	8b 40 38             	mov    0x38(%eax),%eax
80106e44:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106e47:	e8 19 d6 ff ff       	call   80104465 <cpuid>
80106e4c:	89 c3                	mov    %eax,%ebx
80106e4e:	8b 45 08             	mov    0x8(%ebp),%eax
80106e51:	8b 48 34             	mov    0x34(%eax),%ecx
80106e54:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106e57:	8b 45 08             	mov    0x8(%ebp),%eax
80106e5a:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106e5d:	e8 9e d6 ff ff       	call   80104500 <myproc>
80106e62:	8d 50 6c             	lea    0x6c(%eax),%edx
80106e65:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106e68:	e8 93 d6 ff ff       	call   80104500 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e6d:	8b 40 10             	mov    0x10(%eax),%eax
80106e70:	56                   	push   %esi
80106e71:	ff 75 d4             	pushl  -0x2c(%ebp)
80106e74:	53                   	push   %ebx
80106e75:	ff 75 d0             	pushl  -0x30(%ebp)
80106e78:	57                   	push   %edi
80106e79:	ff 75 cc             	pushl  -0x34(%ebp)
80106e7c:	50                   	push   %eax
80106e7d:	68 cc 97 10 80       	push   $0x801097cc
80106e82:	e8 91 95 ff ff       	call   80100418 <cprintf>
80106e87:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106e8a:	e8 71 d6 ff ff       	call   80104500 <myproc>
80106e8f:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106e96:	eb 04                	jmp    80106e9c <trap+0x20b>
    break;
80106e98:	90                   	nop
80106e99:	eb 01                	jmp    80106e9c <trap+0x20b>
    break;
80106e9b:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106e9c:	e8 5f d6 ff ff       	call   80104500 <myproc>
80106ea1:	85 c0                	test   %eax,%eax
80106ea3:	74 23                	je     80106ec8 <trap+0x237>
80106ea5:	e8 56 d6 ff ff       	call   80104500 <myproc>
80106eaa:	8b 40 24             	mov    0x24(%eax),%eax
80106ead:	85 c0                	test   %eax,%eax
80106eaf:	74 17                	je     80106ec8 <trap+0x237>
80106eb1:	8b 45 08             	mov    0x8(%ebp),%eax
80106eb4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106eb8:	0f b7 c0             	movzwl %ax,%eax
80106ebb:	83 e0 03             	and    $0x3,%eax
80106ebe:	83 f8 03             	cmp    $0x3,%eax
80106ec1:	75 05                	jne    80106ec8 <trap+0x237>
    exit();
80106ec3:	e8 14 db ff ff       	call   801049dc <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106ec8:	e8 33 d6 ff ff       	call   80104500 <myproc>
80106ecd:	85 c0                	test   %eax,%eax
80106ecf:	74 1d                	je     80106eee <trap+0x25d>
80106ed1:	e8 2a d6 ff ff       	call   80104500 <myproc>
80106ed6:	8b 40 0c             	mov    0xc(%eax),%eax
80106ed9:	83 f8 04             	cmp    $0x4,%eax
80106edc:	75 10                	jne    80106eee <trap+0x25d>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106ede:	8b 45 08             	mov    0x8(%ebp),%eax
80106ee1:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106ee4:	83 f8 20             	cmp    $0x20,%eax
80106ee7:	75 05                	jne    80106eee <trap+0x25d>
    yield();
80106ee9:	e8 b8 de ff ff       	call   80104da6 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106eee:	e8 0d d6 ff ff       	call   80104500 <myproc>
80106ef3:	85 c0                	test   %eax,%eax
80106ef5:	74 26                	je     80106f1d <trap+0x28c>
80106ef7:	e8 04 d6 ff ff       	call   80104500 <myproc>
80106efc:	8b 40 24             	mov    0x24(%eax),%eax
80106eff:	85 c0                	test   %eax,%eax
80106f01:	74 1a                	je     80106f1d <trap+0x28c>
80106f03:	8b 45 08             	mov    0x8(%ebp),%eax
80106f06:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106f0a:	0f b7 c0             	movzwl %ax,%eax
80106f0d:	83 e0 03             	and    $0x3,%eax
80106f10:	83 f8 03             	cmp    $0x3,%eax
80106f13:	75 08                	jne    80106f1d <trap+0x28c>
    exit();
80106f15:	e8 c2 da ff ff       	call   801049dc <exit>
80106f1a:	eb 01                	jmp    80106f1d <trap+0x28c>
    return;
80106f1c:	90                   	nop
}
80106f1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106f20:	5b                   	pop    %ebx
80106f21:	5e                   	pop    %esi
80106f22:	5f                   	pop    %edi
80106f23:	5d                   	pop    %ebp
80106f24:	c3                   	ret    

80106f25 <inb>:
{
80106f25:	55                   	push   %ebp
80106f26:	89 e5                	mov    %esp,%ebp
80106f28:	83 ec 14             	sub    $0x14,%esp
80106f2b:	8b 45 08             	mov    0x8(%ebp),%eax
80106f2e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106f32:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106f36:	89 c2                	mov    %eax,%edx
80106f38:	ec                   	in     (%dx),%al
80106f39:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106f3c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106f40:	c9                   	leave  
80106f41:	c3                   	ret    

80106f42 <outb>:
{
80106f42:	55                   	push   %ebp
80106f43:	89 e5                	mov    %esp,%ebp
80106f45:	83 ec 08             	sub    $0x8,%esp
80106f48:	8b 45 08             	mov    0x8(%ebp),%eax
80106f4b:	8b 55 0c             	mov    0xc(%ebp),%edx
80106f4e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106f52:	89 d0                	mov    %edx,%eax
80106f54:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106f57:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106f5b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106f5f:	ee                   	out    %al,(%dx)
}
80106f60:	90                   	nop
80106f61:	c9                   	leave  
80106f62:	c3                   	ret    

80106f63 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106f63:	f3 0f 1e fb          	endbr32 
80106f67:	55                   	push   %ebp
80106f68:	89 e5                	mov    %esp,%ebp
80106f6a:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106f6d:	6a 00                	push   $0x0
80106f6f:	68 fa 03 00 00       	push   $0x3fa
80106f74:	e8 c9 ff ff ff       	call   80106f42 <outb>
80106f79:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106f7c:	68 80 00 00 00       	push   $0x80
80106f81:	68 fb 03 00 00       	push   $0x3fb
80106f86:	e8 b7 ff ff ff       	call   80106f42 <outb>
80106f8b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106f8e:	6a 0c                	push   $0xc
80106f90:	68 f8 03 00 00       	push   $0x3f8
80106f95:	e8 a8 ff ff ff       	call   80106f42 <outb>
80106f9a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106f9d:	6a 00                	push   $0x0
80106f9f:	68 f9 03 00 00       	push   $0x3f9
80106fa4:	e8 99 ff ff ff       	call   80106f42 <outb>
80106fa9:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106fac:	6a 03                	push   $0x3
80106fae:	68 fb 03 00 00       	push   $0x3fb
80106fb3:	e8 8a ff ff ff       	call   80106f42 <outb>
80106fb8:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106fbb:	6a 00                	push   $0x0
80106fbd:	68 fc 03 00 00       	push   $0x3fc
80106fc2:	e8 7b ff ff ff       	call   80106f42 <outb>
80106fc7:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106fca:	6a 01                	push   $0x1
80106fcc:	68 f9 03 00 00       	push   $0x3f9
80106fd1:	e8 6c ff ff ff       	call   80106f42 <outb>
80106fd6:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106fd9:	68 fd 03 00 00       	push   $0x3fd
80106fde:	e8 42 ff ff ff       	call   80106f25 <inb>
80106fe3:	83 c4 04             	add    $0x4,%esp
80106fe6:	3c ff                	cmp    $0xff,%al
80106fe8:	74 61                	je     8010704b <uartinit+0xe8>
    return;
  uart = 1;
80106fea:	c7 05 44 c6 10 80 01 	movl   $0x1,0x8010c644
80106ff1:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106ff4:	68 fa 03 00 00       	push   $0x3fa
80106ff9:	e8 27 ff ff ff       	call   80106f25 <inb>
80106ffe:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80107001:	68 f8 03 00 00       	push   $0x3f8
80107006:	e8 1a ff ff ff       	call   80106f25 <inb>
8010700b:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
8010700e:	83 ec 08             	sub    $0x8,%esp
80107011:	6a 00                	push   $0x0
80107013:	6a 04                	push   $0x4
80107015:	e8 c2 bc ff ff       	call   80102cdc <ioapicenable>
8010701a:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010701d:	c7 45 f4 d8 98 10 80 	movl   $0x801098d8,-0xc(%ebp)
80107024:	eb 19                	jmp    8010703f <uartinit+0xdc>
    uartputc(*p);
80107026:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107029:	0f b6 00             	movzbl (%eax),%eax
8010702c:	0f be c0             	movsbl %al,%eax
8010702f:	83 ec 0c             	sub    $0xc,%esp
80107032:	50                   	push   %eax
80107033:	e8 16 00 00 00       	call   8010704e <uartputc>
80107038:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
8010703b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010703f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107042:	0f b6 00             	movzbl (%eax),%eax
80107045:	84 c0                	test   %al,%al
80107047:	75 dd                	jne    80107026 <uartinit+0xc3>
80107049:	eb 01                	jmp    8010704c <uartinit+0xe9>
    return;
8010704b:	90                   	nop
}
8010704c:	c9                   	leave  
8010704d:	c3                   	ret    

8010704e <uartputc>:

void
uartputc(int c)
{
8010704e:	f3 0f 1e fb          	endbr32 
80107052:	55                   	push   %ebp
80107053:	89 e5                	mov    %esp,%ebp
80107055:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80107058:	a1 44 c6 10 80       	mov    0x8010c644,%eax
8010705d:	85 c0                	test   %eax,%eax
8010705f:	74 53                	je     801070b4 <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107061:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107068:	eb 11                	jmp    8010707b <uartputc+0x2d>
    microdelay(10);
8010706a:	83 ec 0c             	sub    $0xc,%esp
8010706d:	6a 0a                	push   $0xa
8010706f:	e8 a0 c1 ff ff       	call   80103214 <microdelay>
80107074:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107077:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010707b:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010707f:	7f 1a                	jg     8010709b <uartputc+0x4d>
80107081:	83 ec 0c             	sub    $0xc,%esp
80107084:	68 fd 03 00 00       	push   $0x3fd
80107089:	e8 97 fe ff ff       	call   80106f25 <inb>
8010708e:	83 c4 10             	add    $0x10,%esp
80107091:	0f b6 c0             	movzbl %al,%eax
80107094:	83 e0 20             	and    $0x20,%eax
80107097:	85 c0                	test   %eax,%eax
80107099:	74 cf                	je     8010706a <uartputc+0x1c>
  outb(COM1+0, c);
8010709b:	8b 45 08             	mov    0x8(%ebp),%eax
8010709e:	0f b6 c0             	movzbl %al,%eax
801070a1:	83 ec 08             	sub    $0x8,%esp
801070a4:	50                   	push   %eax
801070a5:	68 f8 03 00 00       	push   $0x3f8
801070aa:	e8 93 fe ff ff       	call   80106f42 <outb>
801070af:	83 c4 10             	add    $0x10,%esp
801070b2:	eb 01                	jmp    801070b5 <uartputc+0x67>
    return;
801070b4:	90                   	nop
}
801070b5:	c9                   	leave  
801070b6:	c3                   	ret    

801070b7 <uartgetc>:

static int
uartgetc(void)
{
801070b7:	f3 0f 1e fb          	endbr32 
801070bb:	55                   	push   %ebp
801070bc:	89 e5                	mov    %esp,%ebp
  if(!uart)
801070be:	a1 44 c6 10 80       	mov    0x8010c644,%eax
801070c3:	85 c0                	test   %eax,%eax
801070c5:	75 07                	jne    801070ce <uartgetc+0x17>
    return -1;
801070c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070cc:	eb 2e                	jmp    801070fc <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
801070ce:	68 fd 03 00 00       	push   $0x3fd
801070d3:	e8 4d fe ff ff       	call   80106f25 <inb>
801070d8:	83 c4 04             	add    $0x4,%esp
801070db:	0f b6 c0             	movzbl %al,%eax
801070de:	83 e0 01             	and    $0x1,%eax
801070e1:	85 c0                	test   %eax,%eax
801070e3:	75 07                	jne    801070ec <uartgetc+0x35>
    return -1;
801070e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070ea:	eb 10                	jmp    801070fc <uartgetc+0x45>
  return inb(COM1+0);
801070ec:	68 f8 03 00 00       	push   $0x3f8
801070f1:	e8 2f fe ff ff       	call   80106f25 <inb>
801070f6:	83 c4 04             	add    $0x4,%esp
801070f9:	0f b6 c0             	movzbl %al,%eax
}
801070fc:	c9                   	leave  
801070fd:	c3                   	ret    

801070fe <uartintr>:

void
uartintr(void)
{
801070fe:	f3 0f 1e fb          	endbr32 
80107102:	55                   	push   %ebp
80107103:	89 e5                	mov    %esp,%ebp
80107105:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107108:	83 ec 0c             	sub    $0xc,%esp
8010710b:	68 b7 70 10 80       	push   $0x801070b7
80107110:	e8 93 97 ff ff       	call   801008a8 <consoleintr>
80107115:	83 c4 10             	add    $0x10,%esp
}
80107118:	90                   	nop
80107119:	c9                   	leave  
8010711a:	c3                   	ret    

8010711b <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010711b:	6a 00                	push   $0x0
  pushl $0
8010711d:	6a 00                	push   $0x0
  jmp alltraps
8010711f:	e9 79 f9 ff ff       	jmp    80106a9d <alltraps>

80107124 <vector1>:
.globl vector1
vector1:
  pushl $0
80107124:	6a 00                	push   $0x0
  pushl $1
80107126:	6a 01                	push   $0x1
  jmp alltraps
80107128:	e9 70 f9 ff ff       	jmp    80106a9d <alltraps>

8010712d <vector2>:
.globl vector2
vector2:
  pushl $0
8010712d:	6a 00                	push   $0x0
  pushl $2
8010712f:	6a 02                	push   $0x2
  jmp alltraps
80107131:	e9 67 f9 ff ff       	jmp    80106a9d <alltraps>

80107136 <vector3>:
.globl vector3
vector3:
  pushl $0
80107136:	6a 00                	push   $0x0
  pushl $3
80107138:	6a 03                	push   $0x3
  jmp alltraps
8010713a:	e9 5e f9 ff ff       	jmp    80106a9d <alltraps>

8010713f <vector4>:
.globl vector4
vector4:
  pushl $0
8010713f:	6a 00                	push   $0x0
  pushl $4
80107141:	6a 04                	push   $0x4
  jmp alltraps
80107143:	e9 55 f9 ff ff       	jmp    80106a9d <alltraps>

80107148 <vector5>:
.globl vector5
vector5:
  pushl $0
80107148:	6a 00                	push   $0x0
  pushl $5
8010714a:	6a 05                	push   $0x5
  jmp alltraps
8010714c:	e9 4c f9 ff ff       	jmp    80106a9d <alltraps>

80107151 <vector6>:
.globl vector6
vector6:
  pushl $0
80107151:	6a 00                	push   $0x0
  pushl $6
80107153:	6a 06                	push   $0x6
  jmp alltraps
80107155:	e9 43 f9 ff ff       	jmp    80106a9d <alltraps>

8010715a <vector7>:
.globl vector7
vector7:
  pushl $0
8010715a:	6a 00                	push   $0x0
  pushl $7
8010715c:	6a 07                	push   $0x7
  jmp alltraps
8010715e:	e9 3a f9 ff ff       	jmp    80106a9d <alltraps>

80107163 <vector8>:
.globl vector8
vector8:
  pushl $8
80107163:	6a 08                	push   $0x8
  jmp alltraps
80107165:	e9 33 f9 ff ff       	jmp    80106a9d <alltraps>

8010716a <vector9>:
.globl vector9
vector9:
  pushl $0
8010716a:	6a 00                	push   $0x0
  pushl $9
8010716c:	6a 09                	push   $0x9
  jmp alltraps
8010716e:	e9 2a f9 ff ff       	jmp    80106a9d <alltraps>

80107173 <vector10>:
.globl vector10
vector10:
  pushl $10
80107173:	6a 0a                	push   $0xa
  jmp alltraps
80107175:	e9 23 f9 ff ff       	jmp    80106a9d <alltraps>

8010717a <vector11>:
.globl vector11
vector11:
  pushl $11
8010717a:	6a 0b                	push   $0xb
  jmp alltraps
8010717c:	e9 1c f9 ff ff       	jmp    80106a9d <alltraps>

80107181 <vector12>:
.globl vector12
vector12:
  pushl $12
80107181:	6a 0c                	push   $0xc
  jmp alltraps
80107183:	e9 15 f9 ff ff       	jmp    80106a9d <alltraps>

80107188 <vector13>:
.globl vector13
vector13:
  pushl $13
80107188:	6a 0d                	push   $0xd
  jmp alltraps
8010718a:	e9 0e f9 ff ff       	jmp    80106a9d <alltraps>

8010718f <vector14>:
.globl vector14
vector14:
  pushl $14
8010718f:	6a 0e                	push   $0xe
  jmp alltraps
80107191:	e9 07 f9 ff ff       	jmp    80106a9d <alltraps>

80107196 <vector15>:
.globl vector15
vector15:
  pushl $0
80107196:	6a 00                	push   $0x0
  pushl $15
80107198:	6a 0f                	push   $0xf
  jmp alltraps
8010719a:	e9 fe f8 ff ff       	jmp    80106a9d <alltraps>

8010719f <vector16>:
.globl vector16
vector16:
  pushl $0
8010719f:	6a 00                	push   $0x0
  pushl $16
801071a1:	6a 10                	push   $0x10
  jmp alltraps
801071a3:	e9 f5 f8 ff ff       	jmp    80106a9d <alltraps>

801071a8 <vector17>:
.globl vector17
vector17:
  pushl $17
801071a8:	6a 11                	push   $0x11
  jmp alltraps
801071aa:	e9 ee f8 ff ff       	jmp    80106a9d <alltraps>

801071af <vector18>:
.globl vector18
vector18:
  pushl $0
801071af:	6a 00                	push   $0x0
  pushl $18
801071b1:	6a 12                	push   $0x12
  jmp alltraps
801071b3:	e9 e5 f8 ff ff       	jmp    80106a9d <alltraps>

801071b8 <vector19>:
.globl vector19
vector19:
  pushl $0
801071b8:	6a 00                	push   $0x0
  pushl $19
801071ba:	6a 13                	push   $0x13
  jmp alltraps
801071bc:	e9 dc f8 ff ff       	jmp    80106a9d <alltraps>

801071c1 <vector20>:
.globl vector20
vector20:
  pushl $0
801071c1:	6a 00                	push   $0x0
  pushl $20
801071c3:	6a 14                	push   $0x14
  jmp alltraps
801071c5:	e9 d3 f8 ff ff       	jmp    80106a9d <alltraps>

801071ca <vector21>:
.globl vector21
vector21:
  pushl $0
801071ca:	6a 00                	push   $0x0
  pushl $21
801071cc:	6a 15                	push   $0x15
  jmp alltraps
801071ce:	e9 ca f8 ff ff       	jmp    80106a9d <alltraps>

801071d3 <vector22>:
.globl vector22
vector22:
  pushl $0
801071d3:	6a 00                	push   $0x0
  pushl $22
801071d5:	6a 16                	push   $0x16
  jmp alltraps
801071d7:	e9 c1 f8 ff ff       	jmp    80106a9d <alltraps>

801071dc <vector23>:
.globl vector23
vector23:
  pushl $0
801071dc:	6a 00                	push   $0x0
  pushl $23
801071de:	6a 17                	push   $0x17
  jmp alltraps
801071e0:	e9 b8 f8 ff ff       	jmp    80106a9d <alltraps>

801071e5 <vector24>:
.globl vector24
vector24:
  pushl $0
801071e5:	6a 00                	push   $0x0
  pushl $24
801071e7:	6a 18                	push   $0x18
  jmp alltraps
801071e9:	e9 af f8 ff ff       	jmp    80106a9d <alltraps>

801071ee <vector25>:
.globl vector25
vector25:
  pushl $0
801071ee:	6a 00                	push   $0x0
  pushl $25
801071f0:	6a 19                	push   $0x19
  jmp alltraps
801071f2:	e9 a6 f8 ff ff       	jmp    80106a9d <alltraps>

801071f7 <vector26>:
.globl vector26
vector26:
  pushl $0
801071f7:	6a 00                	push   $0x0
  pushl $26
801071f9:	6a 1a                	push   $0x1a
  jmp alltraps
801071fb:	e9 9d f8 ff ff       	jmp    80106a9d <alltraps>

80107200 <vector27>:
.globl vector27
vector27:
  pushl $0
80107200:	6a 00                	push   $0x0
  pushl $27
80107202:	6a 1b                	push   $0x1b
  jmp alltraps
80107204:	e9 94 f8 ff ff       	jmp    80106a9d <alltraps>

80107209 <vector28>:
.globl vector28
vector28:
  pushl $0
80107209:	6a 00                	push   $0x0
  pushl $28
8010720b:	6a 1c                	push   $0x1c
  jmp alltraps
8010720d:	e9 8b f8 ff ff       	jmp    80106a9d <alltraps>

80107212 <vector29>:
.globl vector29
vector29:
  pushl $0
80107212:	6a 00                	push   $0x0
  pushl $29
80107214:	6a 1d                	push   $0x1d
  jmp alltraps
80107216:	e9 82 f8 ff ff       	jmp    80106a9d <alltraps>

8010721b <vector30>:
.globl vector30
vector30:
  pushl $0
8010721b:	6a 00                	push   $0x0
  pushl $30
8010721d:	6a 1e                	push   $0x1e
  jmp alltraps
8010721f:	e9 79 f8 ff ff       	jmp    80106a9d <alltraps>

80107224 <vector31>:
.globl vector31
vector31:
  pushl $0
80107224:	6a 00                	push   $0x0
  pushl $31
80107226:	6a 1f                	push   $0x1f
  jmp alltraps
80107228:	e9 70 f8 ff ff       	jmp    80106a9d <alltraps>

8010722d <vector32>:
.globl vector32
vector32:
  pushl $0
8010722d:	6a 00                	push   $0x0
  pushl $32
8010722f:	6a 20                	push   $0x20
  jmp alltraps
80107231:	e9 67 f8 ff ff       	jmp    80106a9d <alltraps>

80107236 <vector33>:
.globl vector33
vector33:
  pushl $0
80107236:	6a 00                	push   $0x0
  pushl $33
80107238:	6a 21                	push   $0x21
  jmp alltraps
8010723a:	e9 5e f8 ff ff       	jmp    80106a9d <alltraps>

8010723f <vector34>:
.globl vector34
vector34:
  pushl $0
8010723f:	6a 00                	push   $0x0
  pushl $34
80107241:	6a 22                	push   $0x22
  jmp alltraps
80107243:	e9 55 f8 ff ff       	jmp    80106a9d <alltraps>

80107248 <vector35>:
.globl vector35
vector35:
  pushl $0
80107248:	6a 00                	push   $0x0
  pushl $35
8010724a:	6a 23                	push   $0x23
  jmp alltraps
8010724c:	e9 4c f8 ff ff       	jmp    80106a9d <alltraps>

80107251 <vector36>:
.globl vector36
vector36:
  pushl $0
80107251:	6a 00                	push   $0x0
  pushl $36
80107253:	6a 24                	push   $0x24
  jmp alltraps
80107255:	e9 43 f8 ff ff       	jmp    80106a9d <alltraps>

8010725a <vector37>:
.globl vector37
vector37:
  pushl $0
8010725a:	6a 00                	push   $0x0
  pushl $37
8010725c:	6a 25                	push   $0x25
  jmp alltraps
8010725e:	e9 3a f8 ff ff       	jmp    80106a9d <alltraps>

80107263 <vector38>:
.globl vector38
vector38:
  pushl $0
80107263:	6a 00                	push   $0x0
  pushl $38
80107265:	6a 26                	push   $0x26
  jmp alltraps
80107267:	e9 31 f8 ff ff       	jmp    80106a9d <alltraps>

8010726c <vector39>:
.globl vector39
vector39:
  pushl $0
8010726c:	6a 00                	push   $0x0
  pushl $39
8010726e:	6a 27                	push   $0x27
  jmp alltraps
80107270:	e9 28 f8 ff ff       	jmp    80106a9d <alltraps>

80107275 <vector40>:
.globl vector40
vector40:
  pushl $0
80107275:	6a 00                	push   $0x0
  pushl $40
80107277:	6a 28                	push   $0x28
  jmp alltraps
80107279:	e9 1f f8 ff ff       	jmp    80106a9d <alltraps>

8010727e <vector41>:
.globl vector41
vector41:
  pushl $0
8010727e:	6a 00                	push   $0x0
  pushl $41
80107280:	6a 29                	push   $0x29
  jmp alltraps
80107282:	e9 16 f8 ff ff       	jmp    80106a9d <alltraps>

80107287 <vector42>:
.globl vector42
vector42:
  pushl $0
80107287:	6a 00                	push   $0x0
  pushl $42
80107289:	6a 2a                	push   $0x2a
  jmp alltraps
8010728b:	e9 0d f8 ff ff       	jmp    80106a9d <alltraps>

80107290 <vector43>:
.globl vector43
vector43:
  pushl $0
80107290:	6a 00                	push   $0x0
  pushl $43
80107292:	6a 2b                	push   $0x2b
  jmp alltraps
80107294:	e9 04 f8 ff ff       	jmp    80106a9d <alltraps>

80107299 <vector44>:
.globl vector44
vector44:
  pushl $0
80107299:	6a 00                	push   $0x0
  pushl $44
8010729b:	6a 2c                	push   $0x2c
  jmp alltraps
8010729d:	e9 fb f7 ff ff       	jmp    80106a9d <alltraps>

801072a2 <vector45>:
.globl vector45
vector45:
  pushl $0
801072a2:	6a 00                	push   $0x0
  pushl $45
801072a4:	6a 2d                	push   $0x2d
  jmp alltraps
801072a6:	e9 f2 f7 ff ff       	jmp    80106a9d <alltraps>

801072ab <vector46>:
.globl vector46
vector46:
  pushl $0
801072ab:	6a 00                	push   $0x0
  pushl $46
801072ad:	6a 2e                	push   $0x2e
  jmp alltraps
801072af:	e9 e9 f7 ff ff       	jmp    80106a9d <alltraps>

801072b4 <vector47>:
.globl vector47
vector47:
  pushl $0
801072b4:	6a 00                	push   $0x0
  pushl $47
801072b6:	6a 2f                	push   $0x2f
  jmp alltraps
801072b8:	e9 e0 f7 ff ff       	jmp    80106a9d <alltraps>

801072bd <vector48>:
.globl vector48
vector48:
  pushl $0
801072bd:	6a 00                	push   $0x0
  pushl $48
801072bf:	6a 30                	push   $0x30
  jmp alltraps
801072c1:	e9 d7 f7 ff ff       	jmp    80106a9d <alltraps>

801072c6 <vector49>:
.globl vector49
vector49:
  pushl $0
801072c6:	6a 00                	push   $0x0
  pushl $49
801072c8:	6a 31                	push   $0x31
  jmp alltraps
801072ca:	e9 ce f7 ff ff       	jmp    80106a9d <alltraps>

801072cf <vector50>:
.globl vector50
vector50:
  pushl $0
801072cf:	6a 00                	push   $0x0
  pushl $50
801072d1:	6a 32                	push   $0x32
  jmp alltraps
801072d3:	e9 c5 f7 ff ff       	jmp    80106a9d <alltraps>

801072d8 <vector51>:
.globl vector51
vector51:
  pushl $0
801072d8:	6a 00                	push   $0x0
  pushl $51
801072da:	6a 33                	push   $0x33
  jmp alltraps
801072dc:	e9 bc f7 ff ff       	jmp    80106a9d <alltraps>

801072e1 <vector52>:
.globl vector52
vector52:
  pushl $0
801072e1:	6a 00                	push   $0x0
  pushl $52
801072e3:	6a 34                	push   $0x34
  jmp alltraps
801072e5:	e9 b3 f7 ff ff       	jmp    80106a9d <alltraps>

801072ea <vector53>:
.globl vector53
vector53:
  pushl $0
801072ea:	6a 00                	push   $0x0
  pushl $53
801072ec:	6a 35                	push   $0x35
  jmp alltraps
801072ee:	e9 aa f7 ff ff       	jmp    80106a9d <alltraps>

801072f3 <vector54>:
.globl vector54
vector54:
  pushl $0
801072f3:	6a 00                	push   $0x0
  pushl $54
801072f5:	6a 36                	push   $0x36
  jmp alltraps
801072f7:	e9 a1 f7 ff ff       	jmp    80106a9d <alltraps>

801072fc <vector55>:
.globl vector55
vector55:
  pushl $0
801072fc:	6a 00                	push   $0x0
  pushl $55
801072fe:	6a 37                	push   $0x37
  jmp alltraps
80107300:	e9 98 f7 ff ff       	jmp    80106a9d <alltraps>

80107305 <vector56>:
.globl vector56
vector56:
  pushl $0
80107305:	6a 00                	push   $0x0
  pushl $56
80107307:	6a 38                	push   $0x38
  jmp alltraps
80107309:	e9 8f f7 ff ff       	jmp    80106a9d <alltraps>

8010730e <vector57>:
.globl vector57
vector57:
  pushl $0
8010730e:	6a 00                	push   $0x0
  pushl $57
80107310:	6a 39                	push   $0x39
  jmp alltraps
80107312:	e9 86 f7 ff ff       	jmp    80106a9d <alltraps>

80107317 <vector58>:
.globl vector58
vector58:
  pushl $0
80107317:	6a 00                	push   $0x0
  pushl $58
80107319:	6a 3a                	push   $0x3a
  jmp alltraps
8010731b:	e9 7d f7 ff ff       	jmp    80106a9d <alltraps>

80107320 <vector59>:
.globl vector59
vector59:
  pushl $0
80107320:	6a 00                	push   $0x0
  pushl $59
80107322:	6a 3b                	push   $0x3b
  jmp alltraps
80107324:	e9 74 f7 ff ff       	jmp    80106a9d <alltraps>

80107329 <vector60>:
.globl vector60
vector60:
  pushl $0
80107329:	6a 00                	push   $0x0
  pushl $60
8010732b:	6a 3c                	push   $0x3c
  jmp alltraps
8010732d:	e9 6b f7 ff ff       	jmp    80106a9d <alltraps>

80107332 <vector61>:
.globl vector61
vector61:
  pushl $0
80107332:	6a 00                	push   $0x0
  pushl $61
80107334:	6a 3d                	push   $0x3d
  jmp alltraps
80107336:	e9 62 f7 ff ff       	jmp    80106a9d <alltraps>

8010733b <vector62>:
.globl vector62
vector62:
  pushl $0
8010733b:	6a 00                	push   $0x0
  pushl $62
8010733d:	6a 3e                	push   $0x3e
  jmp alltraps
8010733f:	e9 59 f7 ff ff       	jmp    80106a9d <alltraps>

80107344 <vector63>:
.globl vector63
vector63:
  pushl $0
80107344:	6a 00                	push   $0x0
  pushl $63
80107346:	6a 3f                	push   $0x3f
  jmp alltraps
80107348:	e9 50 f7 ff ff       	jmp    80106a9d <alltraps>

8010734d <vector64>:
.globl vector64
vector64:
  pushl $0
8010734d:	6a 00                	push   $0x0
  pushl $64
8010734f:	6a 40                	push   $0x40
  jmp alltraps
80107351:	e9 47 f7 ff ff       	jmp    80106a9d <alltraps>

80107356 <vector65>:
.globl vector65
vector65:
  pushl $0
80107356:	6a 00                	push   $0x0
  pushl $65
80107358:	6a 41                	push   $0x41
  jmp alltraps
8010735a:	e9 3e f7 ff ff       	jmp    80106a9d <alltraps>

8010735f <vector66>:
.globl vector66
vector66:
  pushl $0
8010735f:	6a 00                	push   $0x0
  pushl $66
80107361:	6a 42                	push   $0x42
  jmp alltraps
80107363:	e9 35 f7 ff ff       	jmp    80106a9d <alltraps>

80107368 <vector67>:
.globl vector67
vector67:
  pushl $0
80107368:	6a 00                	push   $0x0
  pushl $67
8010736a:	6a 43                	push   $0x43
  jmp alltraps
8010736c:	e9 2c f7 ff ff       	jmp    80106a9d <alltraps>

80107371 <vector68>:
.globl vector68
vector68:
  pushl $0
80107371:	6a 00                	push   $0x0
  pushl $68
80107373:	6a 44                	push   $0x44
  jmp alltraps
80107375:	e9 23 f7 ff ff       	jmp    80106a9d <alltraps>

8010737a <vector69>:
.globl vector69
vector69:
  pushl $0
8010737a:	6a 00                	push   $0x0
  pushl $69
8010737c:	6a 45                	push   $0x45
  jmp alltraps
8010737e:	e9 1a f7 ff ff       	jmp    80106a9d <alltraps>

80107383 <vector70>:
.globl vector70
vector70:
  pushl $0
80107383:	6a 00                	push   $0x0
  pushl $70
80107385:	6a 46                	push   $0x46
  jmp alltraps
80107387:	e9 11 f7 ff ff       	jmp    80106a9d <alltraps>

8010738c <vector71>:
.globl vector71
vector71:
  pushl $0
8010738c:	6a 00                	push   $0x0
  pushl $71
8010738e:	6a 47                	push   $0x47
  jmp alltraps
80107390:	e9 08 f7 ff ff       	jmp    80106a9d <alltraps>

80107395 <vector72>:
.globl vector72
vector72:
  pushl $0
80107395:	6a 00                	push   $0x0
  pushl $72
80107397:	6a 48                	push   $0x48
  jmp alltraps
80107399:	e9 ff f6 ff ff       	jmp    80106a9d <alltraps>

8010739e <vector73>:
.globl vector73
vector73:
  pushl $0
8010739e:	6a 00                	push   $0x0
  pushl $73
801073a0:	6a 49                	push   $0x49
  jmp alltraps
801073a2:	e9 f6 f6 ff ff       	jmp    80106a9d <alltraps>

801073a7 <vector74>:
.globl vector74
vector74:
  pushl $0
801073a7:	6a 00                	push   $0x0
  pushl $74
801073a9:	6a 4a                	push   $0x4a
  jmp alltraps
801073ab:	e9 ed f6 ff ff       	jmp    80106a9d <alltraps>

801073b0 <vector75>:
.globl vector75
vector75:
  pushl $0
801073b0:	6a 00                	push   $0x0
  pushl $75
801073b2:	6a 4b                	push   $0x4b
  jmp alltraps
801073b4:	e9 e4 f6 ff ff       	jmp    80106a9d <alltraps>

801073b9 <vector76>:
.globl vector76
vector76:
  pushl $0
801073b9:	6a 00                	push   $0x0
  pushl $76
801073bb:	6a 4c                	push   $0x4c
  jmp alltraps
801073bd:	e9 db f6 ff ff       	jmp    80106a9d <alltraps>

801073c2 <vector77>:
.globl vector77
vector77:
  pushl $0
801073c2:	6a 00                	push   $0x0
  pushl $77
801073c4:	6a 4d                	push   $0x4d
  jmp alltraps
801073c6:	e9 d2 f6 ff ff       	jmp    80106a9d <alltraps>

801073cb <vector78>:
.globl vector78
vector78:
  pushl $0
801073cb:	6a 00                	push   $0x0
  pushl $78
801073cd:	6a 4e                	push   $0x4e
  jmp alltraps
801073cf:	e9 c9 f6 ff ff       	jmp    80106a9d <alltraps>

801073d4 <vector79>:
.globl vector79
vector79:
  pushl $0
801073d4:	6a 00                	push   $0x0
  pushl $79
801073d6:	6a 4f                	push   $0x4f
  jmp alltraps
801073d8:	e9 c0 f6 ff ff       	jmp    80106a9d <alltraps>

801073dd <vector80>:
.globl vector80
vector80:
  pushl $0
801073dd:	6a 00                	push   $0x0
  pushl $80
801073df:	6a 50                	push   $0x50
  jmp alltraps
801073e1:	e9 b7 f6 ff ff       	jmp    80106a9d <alltraps>

801073e6 <vector81>:
.globl vector81
vector81:
  pushl $0
801073e6:	6a 00                	push   $0x0
  pushl $81
801073e8:	6a 51                	push   $0x51
  jmp alltraps
801073ea:	e9 ae f6 ff ff       	jmp    80106a9d <alltraps>

801073ef <vector82>:
.globl vector82
vector82:
  pushl $0
801073ef:	6a 00                	push   $0x0
  pushl $82
801073f1:	6a 52                	push   $0x52
  jmp alltraps
801073f3:	e9 a5 f6 ff ff       	jmp    80106a9d <alltraps>

801073f8 <vector83>:
.globl vector83
vector83:
  pushl $0
801073f8:	6a 00                	push   $0x0
  pushl $83
801073fa:	6a 53                	push   $0x53
  jmp alltraps
801073fc:	e9 9c f6 ff ff       	jmp    80106a9d <alltraps>

80107401 <vector84>:
.globl vector84
vector84:
  pushl $0
80107401:	6a 00                	push   $0x0
  pushl $84
80107403:	6a 54                	push   $0x54
  jmp alltraps
80107405:	e9 93 f6 ff ff       	jmp    80106a9d <alltraps>

8010740a <vector85>:
.globl vector85
vector85:
  pushl $0
8010740a:	6a 00                	push   $0x0
  pushl $85
8010740c:	6a 55                	push   $0x55
  jmp alltraps
8010740e:	e9 8a f6 ff ff       	jmp    80106a9d <alltraps>

80107413 <vector86>:
.globl vector86
vector86:
  pushl $0
80107413:	6a 00                	push   $0x0
  pushl $86
80107415:	6a 56                	push   $0x56
  jmp alltraps
80107417:	e9 81 f6 ff ff       	jmp    80106a9d <alltraps>

8010741c <vector87>:
.globl vector87
vector87:
  pushl $0
8010741c:	6a 00                	push   $0x0
  pushl $87
8010741e:	6a 57                	push   $0x57
  jmp alltraps
80107420:	e9 78 f6 ff ff       	jmp    80106a9d <alltraps>

80107425 <vector88>:
.globl vector88
vector88:
  pushl $0
80107425:	6a 00                	push   $0x0
  pushl $88
80107427:	6a 58                	push   $0x58
  jmp alltraps
80107429:	e9 6f f6 ff ff       	jmp    80106a9d <alltraps>

8010742e <vector89>:
.globl vector89
vector89:
  pushl $0
8010742e:	6a 00                	push   $0x0
  pushl $89
80107430:	6a 59                	push   $0x59
  jmp alltraps
80107432:	e9 66 f6 ff ff       	jmp    80106a9d <alltraps>

80107437 <vector90>:
.globl vector90
vector90:
  pushl $0
80107437:	6a 00                	push   $0x0
  pushl $90
80107439:	6a 5a                	push   $0x5a
  jmp alltraps
8010743b:	e9 5d f6 ff ff       	jmp    80106a9d <alltraps>

80107440 <vector91>:
.globl vector91
vector91:
  pushl $0
80107440:	6a 00                	push   $0x0
  pushl $91
80107442:	6a 5b                	push   $0x5b
  jmp alltraps
80107444:	e9 54 f6 ff ff       	jmp    80106a9d <alltraps>

80107449 <vector92>:
.globl vector92
vector92:
  pushl $0
80107449:	6a 00                	push   $0x0
  pushl $92
8010744b:	6a 5c                	push   $0x5c
  jmp alltraps
8010744d:	e9 4b f6 ff ff       	jmp    80106a9d <alltraps>

80107452 <vector93>:
.globl vector93
vector93:
  pushl $0
80107452:	6a 00                	push   $0x0
  pushl $93
80107454:	6a 5d                	push   $0x5d
  jmp alltraps
80107456:	e9 42 f6 ff ff       	jmp    80106a9d <alltraps>

8010745b <vector94>:
.globl vector94
vector94:
  pushl $0
8010745b:	6a 00                	push   $0x0
  pushl $94
8010745d:	6a 5e                	push   $0x5e
  jmp alltraps
8010745f:	e9 39 f6 ff ff       	jmp    80106a9d <alltraps>

80107464 <vector95>:
.globl vector95
vector95:
  pushl $0
80107464:	6a 00                	push   $0x0
  pushl $95
80107466:	6a 5f                	push   $0x5f
  jmp alltraps
80107468:	e9 30 f6 ff ff       	jmp    80106a9d <alltraps>

8010746d <vector96>:
.globl vector96
vector96:
  pushl $0
8010746d:	6a 00                	push   $0x0
  pushl $96
8010746f:	6a 60                	push   $0x60
  jmp alltraps
80107471:	e9 27 f6 ff ff       	jmp    80106a9d <alltraps>

80107476 <vector97>:
.globl vector97
vector97:
  pushl $0
80107476:	6a 00                	push   $0x0
  pushl $97
80107478:	6a 61                	push   $0x61
  jmp alltraps
8010747a:	e9 1e f6 ff ff       	jmp    80106a9d <alltraps>

8010747f <vector98>:
.globl vector98
vector98:
  pushl $0
8010747f:	6a 00                	push   $0x0
  pushl $98
80107481:	6a 62                	push   $0x62
  jmp alltraps
80107483:	e9 15 f6 ff ff       	jmp    80106a9d <alltraps>

80107488 <vector99>:
.globl vector99
vector99:
  pushl $0
80107488:	6a 00                	push   $0x0
  pushl $99
8010748a:	6a 63                	push   $0x63
  jmp alltraps
8010748c:	e9 0c f6 ff ff       	jmp    80106a9d <alltraps>

80107491 <vector100>:
.globl vector100
vector100:
  pushl $0
80107491:	6a 00                	push   $0x0
  pushl $100
80107493:	6a 64                	push   $0x64
  jmp alltraps
80107495:	e9 03 f6 ff ff       	jmp    80106a9d <alltraps>

8010749a <vector101>:
.globl vector101
vector101:
  pushl $0
8010749a:	6a 00                	push   $0x0
  pushl $101
8010749c:	6a 65                	push   $0x65
  jmp alltraps
8010749e:	e9 fa f5 ff ff       	jmp    80106a9d <alltraps>

801074a3 <vector102>:
.globl vector102
vector102:
  pushl $0
801074a3:	6a 00                	push   $0x0
  pushl $102
801074a5:	6a 66                	push   $0x66
  jmp alltraps
801074a7:	e9 f1 f5 ff ff       	jmp    80106a9d <alltraps>

801074ac <vector103>:
.globl vector103
vector103:
  pushl $0
801074ac:	6a 00                	push   $0x0
  pushl $103
801074ae:	6a 67                	push   $0x67
  jmp alltraps
801074b0:	e9 e8 f5 ff ff       	jmp    80106a9d <alltraps>

801074b5 <vector104>:
.globl vector104
vector104:
  pushl $0
801074b5:	6a 00                	push   $0x0
  pushl $104
801074b7:	6a 68                	push   $0x68
  jmp alltraps
801074b9:	e9 df f5 ff ff       	jmp    80106a9d <alltraps>

801074be <vector105>:
.globl vector105
vector105:
  pushl $0
801074be:	6a 00                	push   $0x0
  pushl $105
801074c0:	6a 69                	push   $0x69
  jmp alltraps
801074c2:	e9 d6 f5 ff ff       	jmp    80106a9d <alltraps>

801074c7 <vector106>:
.globl vector106
vector106:
  pushl $0
801074c7:	6a 00                	push   $0x0
  pushl $106
801074c9:	6a 6a                	push   $0x6a
  jmp alltraps
801074cb:	e9 cd f5 ff ff       	jmp    80106a9d <alltraps>

801074d0 <vector107>:
.globl vector107
vector107:
  pushl $0
801074d0:	6a 00                	push   $0x0
  pushl $107
801074d2:	6a 6b                	push   $0x6b
  jmp alltraps
801074d4:	e9 c4 f5 ff ff       	jmp    80106a9d <alltraps>

801074d9 <vector108>:
.globl vector108
vector108:
  pushl $0
801074d9:	6a 00                	push   $0x0
  pushl $108
801074db:	6a 6c                	push   $0x6c
  jmp alltraps
801074dd:	e9 bb f5 ff ff       	jmp    80106a9d <alltraps>

801074e2 <vector109>:
.globl vector109
vector109:
  pushl $0
801074e2:	6a 00                	push   $0x0
  pushl $109
801074e4:	6a 6d                	push   $0x6d
  jmp alltraps
801074e6:	e9 b2 f5 ff ff       	jmp    80106a9d <alltraps>

801074eb <vector110>:
.globl vector110
vector110:
  pushl $0
801074eb:	6a 00                	push   $0x0
  pushl $110
801074ed:	6a 6e                	push   $0x6e
  jmp alltraps
801074ef:	e9 a9 f5 ff ff       	jmp    80106a9d <alltraps>

801074f4 <vector111>:
.globl vector111
vector111:
  pushl $0
801074f4:	6a 00                	push   $0x0
  pushl $111
801074f6:	6a 6f                	push   $0x6f
  jmp alltraps
801074f8:	e9 a0 f5 ff ff       	jmp    80106a9d <alltraps>

801074fd <vector112>:
.globl vector112
vector112:
  pushl $0
801074fd:	6a 00                	push   $0x0
  pushl $112
801074ff:	6a 70                	push   $0x70
  jmp alltraps
80107501:	e9 97 f5 ff ff       	jmp    80106a9d <alltraps>

80107506 <vector113>:
.globl vector113
vector113:
  pushl $0
80107506:	6a 00                	push   $0x0
  pushl $113
80107508:	6a 71                	push   $0x71
  jmp alltraps
8010750a:	e9 8e f5 ff ff       	jmp    80106a9d <alltraps>

8010750f <vector114>:
.globl vector114
vector114:
  pushl $0
8010750f:	6a 00                	push   $0x0
  pushl $114
80107511:	6a 72                	push   $0x72
  jmp alltraps
80107513:	e9 85 f5 ff ff       	jmp    80106a9d <alltraps>

80107518 <vector115>:
.globl vector115
vector115:
  pushl $0
80107518:	6a 00                	push   $0x0
  pushl $115
8010751a:	6a 73                	push   $0x73
  jmp alltraps
8010751c:	e9 7c f5 ff ff       	jmp    80106a9d <alltraps>

80107521 <vector116>:
.globl vector116
vector116:
  pushl $0
80107521:	6a 00                	push   $0x0
  pushl $116
80107523:	6a 74                	push   $0x74
  jmp alltraps
80107525:	e9 73 f5 ff ff       	jmp    80106a9d <alltraps>

8010752a <vector117>:
.globl vector117
vector117:
  pushl $0
8010752a:	6a 00                	push   $0x0
  pushl $117
8010752c:	6a 75                	push   $0x75
  jmp alltraps
8010752e:	e9 6a f5 ff ff       	jmp    80106a9d <alltraps>

80107533 <vector118>:
.globl vector118
vector118:
  pushl $0
80107533:	6a 00                	push   $0x0
  pushl $118
80107535:	6a 76                	push   $0x76
  jmp alltraps
80107537:	e9 61 f5 ff ff       	jmp    80106a9d <alltraps>

8010753c <vector119>:
.globl vector119
vector119:
  pushl $0
8010753c:	6a 00                	push   $0x0
  pushl $119
8010753e:	6a 77                	push   $0x77
  jmp alltraps
80107540:	e9 58 f5 ff ff       	jmp    80106a9d <alltraps>

80107545 <vector120>:
.globl vector120
vector120:
  pushl $0
80107545:	6a 00                	push   $0x0
  pushl $120
80107547:	6a 78                	push   $0x78
  jmp alltraps
80107549:	e9 4f f5 ff ff       	jmp    80106a9d <alltraps>

8010754e <vector121>:
.globl vector121
vector121:
  pushl $0
8010754e:	6a 00                	push   $0x0
  pushl $121
80107550:	6a 79                	push   $0x79
  jmp alltraps
80107552:	e9 46 f5 ff ff       	jmp    80106a9d <alltraps>

80107557 <vector122>:
.globl vector122
vector122:
  pushl $0
80107557:	6a 00                	push   $0x0
  pushl $122
80107559:	6a 7a                	push   $0x7a
  jmp alltraps
8010755b:	e9 3d f5 ff ff       	jmp    80106a9d <alltraps>

80107560 <vector123>:
.globl vector123
vector123:
  pushl $0
80107560:	6a 00                	push   $0x0
  pushl $123
80107562:	6a 7b                	push   $0x7b
  jmp alltraps
80107564:	e9 34 f5 ff ff       	jmp    80106a9d <alltraps>

80107569 <vector124>:
.globl vector124
vector124:
  pushl $0
80107569:	6a 00                	push   $0x0
  pushl $124
8010756b:	6a 7c                	push   $0x7c
  jmp alltraps
8010756d:	e9 2b f5 ff ff       	jmp    80106a9d <alltraps>

80107572 <vector125>:
.globl vector125
vector125:
  pushl $0
80107572:	6a 00                	push   $0x0
  pushl $125
80107574:	6a 7d                	push   $0x7d
  jmp alltraps
80107576:	e9 22 f5 ff ff       	jmp    80106a9d <alltraps>

8010757b <vector126>:
.globl vector126
vector126:
  pushl $0
8010757b:	6a 00                	push   $0x0
  pushl $126
8010757d:	6a 7e                	push   $0x7e
  jmp alltraps
8010757f:	e9 19 f5 ff ff       	jmp    80106a9d <alltraps>

80107584 <vector127>:
.globl vector127
vector127:
  pushl $0
80107584:	6a 00                	push   $0x0
  pushl $127
80107586:	6a 7f                	push   $0x7f
  jmp alltraps
80107588:	e9 10 f5 ff ff       	jmp    80106a9d <alltraps>

8010758d <vector128>:
.globl vector128
vector128:
  pushl $0
8010758d:	6a 00                	push   $0x0
  pushl $128
8010758f:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107594:	e9 04 f5 ff ff       	jmp    80106a9d <alltraps>

80107599 <vector129>:
.globl vector129
vector129:
  pushl $0
80107599:	6a 00                	push   $0x0
  pushl $129
8010759b:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801075a0:	e9 f8 f4 ff ff       	jmp    80106a9d <alltraps>

801075a5 <vector130>:
.globl vector130
vector130:
  pushl $0
801075a5:	6a 00                	push   $0x0
  pushl $130
801075a7:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801075ac:	e9 ec f4 ff ff       	jmp    80106a9d <alltraps>

801075b1 <vector131>:
.globl vector131
vector131:
  pushl $0
801075b1:	6a 00                	push   $0x0
  pushl $131
801075b3:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801075b8:	e9 e0 f4 ff ff       	jmp    80106a9d <alltraps>

801075bd <vector132>:
.globl vector132
vector132:
  pushl $0
801075bd:	6a 00                	push   $0x0
  pushl $132
801075bf:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801075c4:	e9 d4 f4 ff ff       	jmp    80106a9d <alltraps>

801075c9 <vector133>:
.globl vector133
vector133:
  pushl $0
801075c9:	6a 00                	push   $0x0
  pushl $133
801075cb:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801075d0:	e9 c8 f4 ff ff       	jmp    80106a9d <alltraps>

801075d5 <vector134>:
.globl vector134
vector134:
  pushl $0
801075d5:	6a 00                	push   $0x0
  pushl $134
801075d7:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801075dc:	e9 bc f4 ff ff       	jmp    80106a9d <alltraps>

801075e1 <vector135>:
.globl vector135
vector135:
  pushl $0
801075e1:	6a 00                	push   $0x0
  pushl $135
801075e3:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801075e8:	e9 b0 f4 ff ff       	jmp    80106a9d <alltraps>

801075ed <vector136>:
.globl vector136
vector136:
  pushl $0
801075ed:	6a 00                	push   $0x0
  pushl $136
801075ef:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801075f4:	e9 a4 f4 ff ff       	jmp    80106a9d <alltraps>

801075f9 <vector137>:
.globl vector137
vector137:
  pushl $0
801075f9:	6a 00                	push   $0x0
  pushl $137
801075fb:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107600:	e9 98 f4 ff ff       	jmp    80106a9d <alltraps>

80107605 <vector138>:
.globl vector138
vector138:
  pushl $0
80107605:	6a 00                	push   $0x0
  pushl $138
80107607:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010760c:	e9 8c f4 ff ff       	jmp    80106a9d <alltraps>

80107611 <vector139>:
.globl vector139
vector139:
  pushl $0
80107611:	6a 00                	push   $0x0
  pushl $139
80107613:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107618:	e9 80 f4 ff ff       	jmp    80106a9d <alltraps>

8010761d <vector140>:
.globl vector140
vector140:
  pushl $0
8010761d:	6a 00                	push   $0x0
  pushl $140
8010761f:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107624:	e9 74 f4 ff ff       	jmp    80106a9d <alltraps>

80107629 <vector141>:
.globl vector141
vector141:
  pushl $0
80107629:	6a 00                	push   $0x0
  pushl $141
8010762b:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107630:	e9 68 f4 ff ff       	jmp    80106a9d <alltraps>

80107635 <vector142>:
.globl vector142
vector142:
  pushl $0
80107635:	6a 00                	push   $0x0
  pushl $142
80107637:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010763c:	e9 5c f4 ff ff       	jmp    80106a9d <alltraps>

80107641 <vector143>:
.globl vector143
vector143:
  pushl $0
80107641:	6a 00                	push   $0x0
  pushl $143
80107643:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107648:	e9 50 f4 ff ff       	jmp    80106a9d <alltraps>

8010764d <vector144>:
.globl vector144
vector144:
  pushl $0
8010764d:	6a 00                	push   $0x0
  pushl $144
8010764f:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107654:	e9 44 f4 ff ff       	jmp    80106a9d <alltraps>

80107659 <vector145>:
.globl vector145
vector145:
  pushl $0
80107659:	6a 00                	push   $0x0
  pushl $145
8010765b:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107660:	e9 38 f4 ff ff       	jmp    80106a9d <alltraps>

80107665 <vector146>:
.globl vector146
vector146:
  pushl $0
80107665:	6a 00                	push   $0x0
  pushl $146
80107667:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010766c:	e9 2c f4 ff ff       	jmp    80106a9d <alltraps>

80107671 <vector147>:
.globl vector147
vector147:
  pushl $0
80107671:	6a 00                	push   $0x0
  pushl $147
80107673:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107678:	e9 20 f4 ff ff       	jmp    80106a9d <alltraps>

8010767d <vector148>:
.globl vector148
vector148:
  pushl $0
8010767d:	6a 00                	push   $0x0
  pushl $148
8010767f:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107684:	e9 14 f4 ff ff       	jmp    80106a9d <alltraps>

80107689 <vector149>:
.globl vector149
vector149:
  pushl $0
80107689:	6a 00                	push   $0x0
  pushl $149
8010768b:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107690:	e9 08 f4 ff ff       	jmp    80106a9d <alltraps>

80107695 <vector150>:
.globl vector150
vector150:
  pushl $0
80107695:	6a 00                	push   $0x0
  pushl $150
80107697:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010769c:	e9 fc f3 ff ff       	jmp    80106a9d <alltraps>

801076a1 <vector151>:
.globl vector151
vector151:
  pushl $0
801076a1:	6a 00                	push   $0x0
  pushl $151
801076a3:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801076a8:	e9 f0 f3 ff ff       	jmp    80106a9d <alltraps>

801076ad <vector152>:
.globl vector152
vector152:
  pushl $0
801076ad:	6a 00                	push   $0x0
  pushl $152
801076af:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801076b4:	e9 e4 f3 ff ff       	jmp    80106a9d <alltraps>

801076b9 <vector153>:
.globl vector153
vector153:
  pushl $0
801076b9:	6a 00                	push   $0x0
  pushl $153
801076bb:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801076c0:	e9 d8 f3 ff ff       	jmp    80106a9d <alltraps>

801076c5 <vector154>:
.globl vector154
vector154:
  pushl $0
801076c5:	6a 00                	push   $0x0
  pushl $154
801076c7:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801076cc:	e9 cc f3 ff ff       	jmp    80106a9d <alltraps>

801076d1 <vector155>:
.globl vector155
vector155:
  pushl $0
801076d1:	6a 00                	push   $0x0
  pushl $155
801076d3:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801076d8:	e9 c0 f3 ff ff       	jmp    80106a9d <alltraps>

801076dd <vector156>:
.globl vector156
vector156:
  pushl $0
801076dd:	6a 00                	push   $0x0
  pushl $156
801076df:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801076e4:	e9 b4 f3 ff ff       	jmp    80106a9d <alltraps>

801076e9 <vector157>:
.globl vector157
vector157:
  pushl $0
801076e9:	6a 00                	push   $0x0
  pushl $157
801076eb:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801076f0:	e9 a8 f3 ff ff       	jmp    80106a9d <alltraps>

801076f5 <vector158>:
.globl vector158
vector158:
  pushl $0
801076f5:	6a 00                	push   $0x0
  pushl $158
801076f7:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801076fc:	e9 9c f3 ff ff       	jmp    80106a9d <alltraps>

80107701 <vector159>:
.globl vector159
vector159:
  pushl $0
80107701:	6a 00                	push   $0x0
  pushl $159
80107703:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107708:	e9 90 f3 ff ff       	jmp    80106a9d <alltraps>

8010770d <vector160>:
.globl vector160
vector160:
  pushl $0
8010770d:	6a 00                	push   $0x0
  pushl $160
8010770f:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107714:	e9 84 f3 ff ff       	jmp    80106a9d <alltraps>

80107719 <vector161>:
.globl vector161
vector161:
  pushl $0
80107719:	6a 00                	push   $0x0
  pushl $161
8010771b:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107720:	e9 78 f3 ff ff       	jmp    80106a9d <alltraps>

80107725 <vector162>:
.globl vector162
vector162:
  pushl $0
80107725:	6a 00                	push   $0x0
  pushl $162
80107727:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010772c:	e9 6c f3 ff ff       	jmp    80106a9d <alltraps>

80107731 <vector163>:
.globl vector163
vector163:
  pushl $0
80107731:	6a 00                	push   $0x0
  pushl $163
80107733:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107738:	e9 60 f3 ff ff       	jmp    80106a9d <alltraps>

8010773d <vector164>:
.globl vector164
vector164:
  pushl $0
8010773d:	6a 00                	push   $0x0
  pushl $164
8010773f:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107744:	e9 54 f3 ff ff       	jmp    80106a9d <alltraps>

80107749 <vector165>:
.globl vector165
vector165:
  pushl $0
80107749:	6a 00                	push   $0x0
  pushl $165
8010774b:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107750:	e9 48 f3 ff ff       	jmp    80106a9d <alltraps>

80107755 <vector166>:
.globl vector166
vector166:
  pushl $0
80107755:	6a 00                	push   $0x0
  pushl $166
80107757:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010775c:	e9 3c f3 ff ff       	jmp    80106a9d <alltraps>

80107761 <vector167>:
.globl vector167
vector167:
  pushl $0
80107761:	6a 00                	push   $0x0
  pushl $167
80107763:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107768:	e9 30 f3 ff ff       	jmp    80106a9d <alltraps>

8010776d <vector168>:
.globl vector168
vector168:
  pushl $0
8010776d:	6a 00                	push   $0x0
  pushl $168
8010776f:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107774:	e9 24 f3 ff ff       	jmp    80106a9d <alltraps>

80107779 <vector169>:
.globl vector169
vector169:
  pushl $0
80107779:	6a 00                	push   $0x0
  pushl $169
8010777b:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107780:	e9 18 f3 ff ff       	jmp    80106a9d <alltraps>

80107785 <vector170>:
.globl vector170
vector170:
  pushl $0
80107785:	6a 00                	push   $0x0
  pushl $170
80107787:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010778c:	e9 0c f3 ff ff       	jmp    80106a9d <alltraps>

80107791 <vector171>:
.globl vector171
vector171:
  pushl $0
80107791:	6a 00                	push   $0x0
  pushl $171
80107793:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107798:	e9 00 f3 ff ff       	jmp    80106a9d <alltraps>

8010779d <vector172>:
.globl vector172
vector172:
  pushl $0
8010779d:	6a 00                	push   $0x0
  pushl $172
8010779f:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801077a4:	e9 f4 f2 ff ff       	jmp    80106a9d <alltraps>

801077a9 <vector173>:
.globl vector173
vector173:
  pushl $0
801077a9:	6a 00                	push   $0x0
  pushl $173
801077ab:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801077b0:	e9 e8 f2 ff ff       	jmp    80106a9d <alltraps>

801077b5 <vector174>:
.globl vector174
vector174:
  pushl $0
801077b5:	6a 00                	push   $0x0
  pushl $174
801077b7:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801077bc:	e9 dc f2 ff ff       	jmp    80106a9d <alltraps>

801077c1 <vector175>:
.globl vector175
vector175:
  pushl $0
801077c1:	6a 00                	push   $0x0
  pushl $175
801077c3:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801077c8:	e9 d0 f2 ff ff       	jmp    80106a9d <alltraps>

801077cd <vector176>:
.globl vector176
vector176:
  pushl $0
801077cd:	6a 00                	push   $0x0
  pushl $176
801077cf:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801077d4:	e9 c4 f2 ff ff       	jmp    80106a9d <alltraps>

801077d9 <vector177>:
.globl vector177
vector177:
  pushl $0
801077d9:	6a 00                	push   $0x0
  pushl $177
801077db:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801077e0:	e9 b8 f2 ff ff       	jmp    80106a9d <alltraps>

801077e5 <vector178>:
.globl vector178
vector178:
  pushl $0
801077e5:	6a 00                	push   $0x0
  pushl $178
801077e7:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801077ec:	e9 ac f2 ff ff       	jmp    80106a9d <alltraps>

801077f1 <vector179>:
.globl vector179
vector179:
  pushl $0
801077f1:	6a 00                	push   $0x0
  pushl $179
801077f3:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801077f8:	e9 a0 f2 ff ff       	jmp    80106a9d <alltraps>

801077fd <vector180>:
.globl vector180
vector180:
  pushl $0
801077fd:	6a 00                	push   $0x0
  pushl $180
801077ff:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107804:	e9 94 f2 ff ff       	jmp    80106a9d <alltraps>

80107809 <vector181>:
.globl vector181
vector181:
  pushl $0
80107809:	6a 00                	push   $0x0
  pushl $181
8010780b:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107810:	e9 88 f2 ff ff       	jmp    80106a9d <alltraps>

80107815 <vector182>:
.globl vector182
vector182:
  pushl $0
80107815:	6a 00                	push   $0x0
  pushl $182
80107817:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010781c:	e9 7c f2 ff ff       	jmp    80106a9d <alltraps>

80107821 <vector183>:
.globl vector183
vector183:
  pushl $0
80107821:	6a 00                	push   $0x0
  pushl $183
80107823:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107828:	e9 70 f2 ff ff       	jmp    80106a9d <alltraps>

8010782d <vector184>:
.globl vector184
vector184:
  pushl $0
8010782d:	6a 00                	push   $0x0
  pushl $184
8010782f:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107834:	e9 64 f2 ff ff       	jmp    80106a9d <alltraps>

80107839 <vector185>:
.globl vector185
vector185:
  pushl $0
80107839:	6a 00                	push   $0x0
  pushl $185
8010783b:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107840:	e9 58 f2 ff ff       	jmp    80106a9d <alltraps>

80107845 <vector186>:
.globl vector186
vector186:
  pushl $0
80107845:	6a 00                	push   $0x0
  pushl $186
80107847:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010784c:	e9 4c f2 ff ff       	jmp    80106a9d <alltraps>

80107851 <vector187>:
.globl vector187
vector187:
  pushl $0
80107851:	6a 00                	push   $0x0
  pushl $187
80107853:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107858:	e9 40 f2 ff ff       	jmp    80106a9d <alltraps>

8010785d <vector188>:
.globl vector188
vector188:
  pushl $0
8010785d:	6a 00                	push   $0x0
  pushl $188
8010785f:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107864:	e9 34 f2 ff ff       	jmp    80106a9d <alltraps>

80107869 <vector189>:
.globl vector189
vector189:
  pushl $0
80107869:	6a 00                	push   $0x0
  pushl $189
8010786b:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107870:	e9 28 f2 ff ff       	jmp    80106a9d <alltraps>

80107875 <vector190>:
.globl vector190
vector190:
  pushl $0
80107875:	6a 00                	push   $0x0
  pushl $190
80107877:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010787c:	e9 1c f2 ff ff       	jmp    80106a9d <alltraps>

80107881 <vector191>:
.globl vector191
vector191:
  pushl $0
80107881:	6a 00                	push   $0x0
  pushl $191
80107883:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107888:	e9 10 f2 ff ff       	jmp    80106a9d <alltraps>

8010788d <vector192>:
.globl vector192
vector192:
  pushl $0
8010788d:	6a 00                	push   $0x0
  pushl $192
8010788f:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107894:	e9 04 f2 ff ff       	jmp    80106a9d <alltraps>

80107899 <vector193>:
.globl vector193
vector193:
  pushl $0
80107899:	6a 00                	push   $0x0
  pushl $193
8010789b:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801078a0:	e9 f8 f1 ff ff       	jmp    80106a9d <alltraps>

801078a5 <vector194>:
.globl vector194
vector194:
  pushl $0
801078a5:	6a 00                	push   $0x0
  pushl $194
801078a7:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801078ac:	e9 ec f1 ff ff       	jmp    80106a9d <alltraps>

801078b1 <vector195>:
.globl vector195
vector195:
  pushl $0
801078b1:	6a 00                	push   $0x0
  pushl $195
801078b3:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801078b8:	e9 e0 f1 ff ff       	jmp    80106a9d <alltraps>

801078bd <vector196>:
.globl vector196
vector196:
  pushl $0
801078bd:	6a 00                	push   $0x0
  pushl $196
801078bf:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801078c4:	e9 d4 f1 ff ff       	jmp    80106a9d <alltraps>

801078c9 <vector197>:
.globl vector197
vector197:
  pushl $0
801078c9:	6a 00                	push   $0x0
  pushl $197
801078cb:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801078d0:	e9 c8 f1 ff ff       	jmp    80106a9d <alltraps>

801078d5 <vector198>:
.globl vector198
vector198:
  pushl $0
801078d5:	6a 00                	push   $0x0
  pushl $198
801078d7:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801078dc:	e9 bc f1 ff ff       	jmp    80106a9d <alltraps>

801078e1 <vector199>:
.globl vector199
vector199:
  pushl $0
801078e1:	6a 00                	push   $0x0
  pushl $199
801078e3:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801078e8:	e9 b0 f1 ff ff       	jmp    80106a9d <alltraps>

801078ed <vector200>:
.globl vector200
vector200:
  pushl $0
801078ed:	6a 00                	push   $0x0
  pushl $200
801078ef:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801078f4:	e9 a4 f1 ff ff       	jmp    80106a9d <alltraps>

801078f9 <vector201>:
.globl vector201
vector201:
  pushl $0
801078f9:	6a 00                	push   $0x0
  pushl $201
801078fb:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107900:	e9 98 f1 ff ff       	jmp    80106a9d <alltraps>

80107905 <vector202>:
.globl vector202
vector202:
  pushl $0
80107905:	6a 00                	push   $0x0
  pushl $202
80107907:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010790c:	e9 8c f1 ff ff       	jmp    80106a9d <alltraps>

80107911 <vector203>:
.globl vector203
vector203:
  pushl $0
80107911:	6a 00                	push   $0x0
  pushl $203
80107913:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107918:	e9 80 f1 ff ff       	jmp    80106a9d <alltraps>

8010791d <vector204>:
.globl vector204
vector204:
  pushl $0
8010791d:	6a 00                	push   $0x0
  pushl $204
8010791f:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107924:	e9 74 f1 ff ff       	jmp    80106a9d <alltraps>

80107929 <vector205>:
.globl vector205
vector205:
  pushl $0
80107929:	6a 00                	push   $0x0
  pushl $205
8010792b:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107930:	e9 68 f1 ff ff       	jmp    80106a9d <alltraps>

80107935 <vector206>:
.globl vector206
vector206:
  pushl $0
80107935:	6a 00                	push   $0x0
  pushl $206
80107937:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010793c:	e9 5c f1 ff ff       	jmp    80106a9d <alltraps>

80107941 <vector207>:
.globl vector207
vector207:
  pushl $0
80107941:	6a 00                	push   $0x0
  pushl $207
80107943:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107948:	e9 50 f1 ff ff       	jmp    80106a9d <alltraps>

8010794d <vector208>:
.globl vector208
vector208:
  pushl $0
8010794d:	6a 00                	push   $0x0
  pushl $208
8010794f:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107954:	e9 44 f1 ff ff       	jmp    80106a9d <alltraps>

80107959 <vector209>:
.globl vector209
vector209:
  pushl $0
80107959:	6a 00                	push   $0x0
  pushl $209
8010795b:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107960:	e9 38 f1 ff ff       	jmp    80106a9d <alltraps>

80107965 <vector210>:
.globl vector210
vector210:
  pushl $0
80107965:	6a 00                	push   $0x0
  pushl $210
80107967:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010796c:	e9 2c f1 ff ff       	jmp    80106a9d <alltraps>

80107971 <vector211>:
.globl vector211
vector211:
  pushl $0
80107971:	6a 00                	push   $0x0
  pushl $211
80107973:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107978:	e9 20 f1 ff ff       	jmp    80106a9d <alltraps>

8010797d <vector212>:
.globl vector212
vector212:
  pushl $0
8010797d:	6a 00                	push   $0x0
  pushl $212
8010797f:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107984:	e9 14 f1 ff ff       	jmp    80106a9d <alltraps>

80107989 <vector213>:
.globl vector213
vector213:
  pushl $0
80107989:	6a 00                	push   $0x0
  pushl $213
8010798b:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107990:	e9 08 f1 ff ff       	jmp    80106a9d <alltraps>

80107995 <vector214>:
.globl vector214
vector214:
  pushl $0
80107995:	6a 00                	push   $0x0
  pushl $214
80107997:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010799c:	e9 fc f0 ff ff       	jmp    80106a9d <alltraps>

801079a1 <vector215>:
.globl vector215
vector215:
  pushl $0
801079a1:	6a 00                	push   $0x0
  pushl $215
801079a3:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801079a8:	e9 f0 f0 ff ff       	jmp    80106a9d <alltraps>

801079ad <vector216>:
.globl vector216
vector216:
  pushl $0
801079ad:	6a 00                	push   $0x0
  pushl $216
801079af:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801079b4:	e9 e4 f0 ff ff       	jmp    80106a9d <alltraps>

801079b9 <vector217>:
.globl vector217
vector217:
  pushl $0
801079b9:	6a 00                	push   $0x0
  pushl $217
801079bb:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801079c0:	e9 d8 f0 ff ff       	jmp    80106a9d <alltraps>

801079c5 <vector218>:
.globl vector218
vector218:
  pushl $0
801079c5:	6a 00                	push   $0x0
  pushl $218
801079c7:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801079cc:	e9 cc f0 ff ff       	jmp    80106a9d <alltraps>

801079d1 <vector219>:
.globl vector219
vector219:
  pushl $0
801079d1:	6a 00                	push   $0x0
  pushl $219
801079d3:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801079d8:	e9 c0 f0 ff ff       	jmp    80106a9d <alltraps>

801079dd <vector220>:
.globl vector220
vector220:
  pushl $0
801079dd:	6a 00                	push   $0x0
  pushl $220
801079df:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801079e4:	e9 b4 f0 ff ff       	jmp    80106a9d <alltraps>

801079e9 <vector221>:
.globl vector221
vector221:
  pushl $0
801079e9:	6a 00                	push   $0x0
  pushl $221
801079eb:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801079f0:	e9 a8 f0 ff ff       	jmp    80106a9d <alltraps>

801079f5 <vector222>:
.globl vector222
vector222:
  pushl $0
801079f5:	6a 00                	push   $0x0
  pushl $222
801079f7:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801079fc:	e9 9c f0 ff ff       	jmp    80106a9d <alltraps>

80107a01 <vector223>:
.globl vector223
vector223:
  pushl $0
80107a01:	6a 00                	push   $0x0
  pushl $223
80107a03:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107a08:	e9 90 f0 ff ff       	jmp    80106a9d <alltraps>

80107a0d <vector224>:
.globl vector224
vector224:
  pushl $0
80107a0d:	6a 00                	push   $0x0
  pushl $224
80107a0f:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107a14:	e9 84 f0 ff ff       	jmp    80106a9d <alltraps>

80107a19 <vector225>:
.globl vector225
vector225:
  pushl $0
80107a19:	6a 00                	push   $0x0
  pushl $225
80107a1b:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107a20:	e9 78 f0 ff ff       	jmp    80106a9d <alltraps>

80107a25 <vector226>:
.globl vector226
vector226:
  pushl $0
80107a25:	6a 00                	push   $0x0
  pushl $226
80107a27:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107a2c:	e9 6c f0 ff ff       	jmp    80106a9d <alltraps>

80107a31 <vector227>:
.globl vector227
vector227:
  pushl $0
80107a31:	6a 00                	push   $0x0
  pushl $227
80107a33:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107a38:	e9 60 f0 ff ff       	jmp    80106a9d <alltraps>

80107a3d <vector228>:
.globl vector228
vector228:
  pushl $0
80107a3d:	6a 00                	push   $0x0
  pushl $228
80107a3f:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107a44:	e9 54 f0 ff ff       	jmp    80106a9d <alltraps>

80107a49 <vector229>:
.globl vector229
vector229:
  pushl $0
80107a49:	6a 00                	push   $0x0
  pushl $229
80107a4b:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107a50:	e9 48 f0 ff ff       	jmp    80106a9d <alltraps>

80107a55 <vector230>:
.globl vector230
vector230:
  pushl $0
80107a55:	6a 00                	push   $0x0
  pushl $230
80107a57:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107a5c:	e9 3c f0 ff ff       	jmp    80106a9d <alltraps>

80107a61 <vector231>:
.globl vector231
vector231:
  pushl $0
80107a61:	6a 00                	push   $0x0
  pushl $231
80107a63:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107a68:	e9 30 f0 ff ff       	jmp    80106a9d <alltraps>

80107a6d <vector232>:
.globl vector232
vector232:
  pushl $0
80107a6d:	6a 00                	push   $0x0
  pushl $232
80107a6f:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107a74:	e9 24 f0 ff ff       	jmp    80106a9d <alltraps>

80107a79 <vector233>:
.globl vector233
vector233:
  pushl $0
80107a79:	6a 00                	push   $0x0
  pushl $233
80107a7b:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107a80:	e9 18 f0 ff ff       	jmp    80106a9d <alltraps>

80107a85 <vector234>:
.globl vector234
vector234:
  pushl $0
80107a85:	6a 00                	push   $0x0
  pushl $234
80107a87:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107a8c:	e9 0c f0 ff ff       	jmp    80106a9d <alltraps>

80107a91 <vector235>:
.globl vector235
vector235:
  pushl $0
80107a91:	6a 00                	push   $0x0
  pushl $235
80107a93:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107a98:	e9 00 f0 ff ff       	jmp    80106a9d <alltraps>

80107a9d <vector236>:
.globl vector236
vector236:
  pushl $0
80107a9d:	6a 00                	push   $0x0
  pushl $236
80107a9f:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107aa4:	e9 f4 ef ff ff       	jmp    80106a9d <alltraps>

80107aa9 <vector237>:
.globl vector237
vector237:
  pushl $0
80107aa9:	6a 00                	push   $0x0
  pushl $237
80107aab:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107ab0:	e9 e8 ef ff ff       	jmp    80106a9d <alltraps>

80107ab5 <vector238>:
.globl vector238
vector238:
  pushl $0
80107ab5:	6a 00                	push   $0x0
  pushl $238
80107ab7:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107abc:	e9 dc ef ff ff       	jmp    80106a9d <alltraps>

80107ac1 <vector239>:
.globl vector239
vector239:
  pushl $0
80107ac1:	6a 00                	push   $0x0
  pushl $239
80107ac3:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107ac8:	e9 d0 ef ff ff       	jmp    80106a9d <alltraps>

80107acd <vector240>:
.globl vector240
vector240:
  pushl $0
80107acd:	6a 00                	push   $0x0
  pushl $240
80107acf:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107ad4:	e9 c4 ef ff ff       	jmp    80106a9d <alltraps>

80107ad9 <vector241>:
.globl vector241
vector241:
  pushl $0
80107ad9:	6a 00                	push   $0x0
  pushl $241
80107adb:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107ae0:	e9 b8 ef ff ff       	jmp    80106a9d <alltraps>

80107ae5 <vector242>:
.globl vector242
vector242:
  pushl $0
80107ae5:	6a 00                	push   $0x0
  pushl $242
80107ae7:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107aec:	e9 ac ef ff ff       	jmp    80106a9d <alltraps>

80107af1 <vector243>:
.globl vector243
vector243:
  pushl $0
80107af1:	6a 00                	push   $0x0
  pushl $243
80107af3:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107af8:	e9 a0 ef ff ff       	jmp    80106a9d <alltraps>

80107afd <vector244>:
.globl vector244
vector244:
  pushl $0
80107afd:	6a 00                	push   $0x0
  pushl $244
80107aff:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107b04:	e9 94 ef ff ff       	jmp    80106a9d <alltraps>

80107b09 <vector245>:
.globl vector245
vector245:
  pushl $0
80107b09:	6a 00                	push   $0x0
  pushl $245
80107b0b:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107b10:	e9 88 ef ff ff       	jmp    80106a9d <alltraps>

80107b15 <vector246>:
.globl vector246
vector246:
  pushl $0
80107b15:	6a 00                	push   $0x0
  pushl $246
80107b17:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107b1c:	e9 7c ef ff ff       	jmp    80106a9d <alltraps>

80107b21 <vector247>:
.globl vector247
vector247:
  pushl $0
80107b21:	6a 00                	push   $0x0
  pushl $247
80107b23:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107b28:	e9 70 ef ff ff       	jmp    80106a9d <alltraps>

80107b2d <vector248>:
.globl vector248
vector248:
  pushl $0
80107b2d:	6a 00                	push   $0x0
  pushl $248
80107b2f:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107b34:	e9 64 ef ff ff       	jmp    80106a9d <alltraps>

80107b39 <vector249>:
.globl vector249
vector249:
  pushl $0
80107b39:	6a 00                	push   $0x0
  pushl $249
80107b3b:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107b40:	e9 58 ef ff ff       	jmp    80106a9d <alltraps>

80107b45 <vector250>:
.globl vector250
vector250:
  pushl $0
80107b45:	6a 00                	push   $0x0
  pushl $250
80107b47:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107b4c:	e9 4c ef ff ff       	jmp    80106a9d <alltraps>

80107b51 <vector251>:
.globl vector251
vector251:
  pushl $0
80107b51:	6a 00                	push   $0x0
  pushl $251
80107b53:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107b58:	e9 40 ef ff ff       	jmp    80106a9d <alltraps>

80107b5d <vector252>:
.globl vector252
vector252:
  pushl $0
80107b5d:	6a 00                	push   $0x0
  pushl $252
80107b5f:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107b64:	e9 34 ef ff ff       	jmp    80106a9d <alltraps>

80107b69 <vector253>:
.globl vector253
vector253:
  pushl $0
80107b69:	6a 00                	push   $0x0
  pushl $253
80107b6b:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107b70:	e9 28 ef ff ff       	jmp    80106a9d <alltraps>

80107b75 <vector254>:
.globl vector254
vector254:
  pushl $0
80107b75:	6a 00                	push   $0x0
  pushl $254
80107b77:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107b7c:	e9 1c ef ff ff       	jmp    80106a9d <alltraps>

80107b81 <vector255>:
.globl vector255
vector255:
  pushl $0
80107b81:	6a 00                	push   $0x0
  pushl $255
80107b83:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107b88:	e9 10 ef ff ff       	jmp    80106a9d <alltraps>

80107b8d <lgdt>:
{
80107b8d:	55                   	push   %ebp
80107b8e:	89 e5                	mov    %esp,%ebp
80107b90:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107b93:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b96:	83 e8 01             	sub    $0x1,%eax
80107b99:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107b9d:	8b 45 08             	mov    0x8(%ebp),%eax
80107ba0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107ba4:	8b 45 08             	mov    0x8(%ebp),%eax
80107ba7:	c1 e8 10             	shr    $0x10,%eax
80107baa:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107bae:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107bb1:	0f 01 10             	lgdtl  (%eax)
}
80107bb4:	90                   	nop
80107bb5:	c9                   	leave  
80107bb6:	c3                   	ret    

80107bb7 <ltr>:
{
80107bb7:	55                   	push   %ebp
80107bb8:	89 e5                	mov    %esp,%ebp
80107bba:	83 ec 04             	sub    $0x4,%esp
80107bbd:	8b 45 08             	mov    0x8(%ebp),%eax
80107bc0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107bc4:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107bc8:	0f 00 d8             	ltr    %ax
}
80107bcb:	90                   	nop
80107bcc:	c9                   	leave  
80107bcd:	c3                   	ret    

80107bce <lcr3>:

static inline void
lcr3(uint val)
{
80107bce:	55                   	push   %ebp
80107bcf:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107bd1:	8b 45 08             	mov    0x8(%ebp),%eax
80107bd4:	0f 22 d8             	mov    %eax,%cr3
}
80107bd7:	90                   	nop
80107bd8:	5d                   	pop    %ebp
80107bd9:	c3                   	ret    

80107bda <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107bda:	f3 0f 1e fb          	endbr32 
80107bde:	55                   	push   %ebp
80107bdf:	89 e5                	mov    %esp,%ebp
80107be1:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107be4:	e8 7c c8 ff ff       	call   80104465 <cpuid>
80107be9:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107bef:	05 20 48 11 80       	add    $0x80114820,%eax
80107bf4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bfa:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c03:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107c09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c0c:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107c10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c13:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c17:	83 e2 f0             	and    $0xfffffff0,%edx
80107c1a:	83 ca 0a             	or     $0xa,%edx
80107c1d:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c23:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c27:	83 ca 10             	or     $0x10,%edx
80107c2a:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c30:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c34:	83 e2 9f             	and    $0xffffff9f,%edx
80107c37:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c3d:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c41:	83 ca 80             	or     $0xffffff80,%edx
80107c44:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107c4e:	83 ca 0f             	or     $0xf,%edx
80107c51:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c57:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107c5b:	83 e2 ef             	and    $0xffffffef,%edx
80107c5e:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c64:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107c68:	83 e2 df             	and    $0xffffffdf,%edx
80107c6b:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c71:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107c75:	83 ca 40             	or     $0x40,%edx
80107c78:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c7e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107c82:	83 ca 80             	or     $0xffffff80,%edx
80107c85:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c8b:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107c8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c92:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107c99:	ff ff 
80107c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9e:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107ca5:	00 00 
80107ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107caa:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107cb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb4:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107cbb:	83 e2 f0             	and    $0xfffffff0,%edx
80107cbe:	83 ca 02             	or     $0x2,%edx
80107cc1:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107cc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cca:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107cd1:	83 ca 10             	or     $0x10,%edx
80107cd4:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cdd:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107ce4:	83 e2 9f             	and    $0xffffff9f,%edx
80107ce7:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107ced:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf0:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107cf7:	83 ca 80             	or     $0xffffff80,%edx
80107cfa:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d03:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d0a:	83 ca 0f             	or     $0xf,%edx
80107d0d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d16:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d1d:	83 e2 ef             	and    $0xffffffef,%edx
80107d20:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d29:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d30:	83 e2 df             	and    $0xffffffdf,%edx
80107d33:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d3c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d43:	83 ca 40             	or     $0x40,%edx
80107d46:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d4f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d56:	83 ca 80             	or     $0xffffff80,%edx
80107d59:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d62:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107d69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d6c:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107d73:	ff ff 
80107d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d78:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107d7f:	00 00 
80107d81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d84:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107d8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d8e:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107d95:	83 e2 f0             	and    $0xfffffff0,%edx
80107d98:	83 ca 0a             	or     $0xa,%edx
80107d9b:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107da1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da4:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107dab:	83 ca 10             	or     $0x10,%edx
80107dae:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107db4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db7:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107dbe:	83 ca 60             	or     $0x60,%edx
80107dc1:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107dc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dca:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107dd1:	83 ca 80             	or     $0xffffff80,%edx
80107dd4:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107dda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ddd:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107de4:	83 ca 0f             	or     $0xf,%edx
80107de7:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107ded:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df0:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107df7:	83 e2 ef             	and    $0xffffffef,%edx
80107dfa:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e03:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e0a:	83 e2 df             	and    $0xffffffdf,%edx
80107e0d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e16:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e1d:	83 ca 40             	or     $0x40,%edx
80107e20:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e29:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e30:	83 ca 80             	or     $0xffffff80,%edx
80107e33:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e3c:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107e43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e46:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107e4d:	ff ff 
80107e4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e52:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107e59:	00 00 
80107e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5e:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107e65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e68:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107e6f:	83 e2 f0             	and    $0xfffffff0,%edx
80107e72:	83 ca 02             	or     $0x2,%edx
80107e75:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e7e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107e85:	83 ca 10             	or     $0x10,%edx
80107e88:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107e8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e91:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107e98:	83 ca 60             	or     $0x60,%edx
80107e9b:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea4:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107eab:	83 ca 80             	or     $0xffffff80,%edx
80107eae:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107eb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eb7:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107ebe:	83 ca 0f             	or     $0xf,%edx
80107ec1:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eca:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107ed1:	83 e2 ef             	and    $0xffffffef,%edx
80107ed4:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107eda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107edd:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107ee4:	83 e2 df             	and    $0xffffffdf,%edx
80107ee7:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ef0:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107ef7:	83 ca 40             	or     $0x40,%edx
80107efa:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f03:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f0a:	83 ca 80             	or     $0xffffff80,%edx
80107f0d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f16:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107f1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f20:	83 c0 70             	add    $0x70,%eax
80107f23:	83 ec 08             	sub    $0x8,%esp
80107f26:	6a 30                	push   $0x30
80107f28:	50                   	push   %eax
80107f29:	e8 5f fc ff ff       	call   80107b8d <lgdt>
80107f2e:	83 c4 10             	add    $0x10,%esp
}
80107f31:	90                   	nop
80107f32:	c9                   	leave  
80107f33:	c3                   	ret    

80107f34 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107f34:	f3 0f 1e fb          	endbr32 
80107f38:	55                   	push   %ebp
80107f39:	89 e5                	mov    %esp,%ebp
80107f3b:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107f3e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f41:	c1 e8 16             	shr    $0x16,%eax
80107f44:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107f4b:	8b 45 08             	mov    0x8(%ebp),%eax
80107f4e:	01 d0                	add    %edx,%eax
80107f50:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107f53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f56:	8b 00                	mov    (%eax),%eax
80107f58:	83 e0 01             	and    $0x1,%eax
80107f5b:	85 c0                	test   %eax,%eax
80107f5d:	74 14                	je     80107f73 <walkpgdir+0x3f>
    //if (!alloc)
      //cprintf("page directory is good\n");
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107f5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f62:	8b 00                	mov    (%eax),%eax
80107f64:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f69:	05 00 00 00 80       	add    $0x80000000,%eax
80107f6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107f71:	eb 42                	jmp    80107fb5 <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107f73:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107f77:	74 0e                	je     80107f87 <walkpgdir+0x53>
80107f79:	e8 e4 ae ff ff       	call   80102e62 <kalloc>
80107f7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107f81:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107f85:	75 07                	jne    80107f8e <walkpgdir+0x5a>
      return 0;
80107f87:	b8 00 00 00 00       	mov    $0x0,%eax
80107f8c:	eb 3e                	jmp    80107fcc <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107f8e:	83 ec 04             	sub    $0x4,%esp
80107f91:	68 00 10 00 00       	push   $0x1000
80107f96:	6a 00                	push   $0x0
80107f98:	ff 75 f4             	pushl  -0xc(%ebp)
80107f9b:	e8 9f d5 ff ff       	call   8010553f <memset>
80107fa0:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107fa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fa6:	05 00 00 00 80       	add    $0x80000000,%eax
80107fab:	83 c8 07             	or     $0x7,%eax
80107fae:	89 c2                	mov    %eax,%edx
80107fb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fb3:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107fb5:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fb8:	c1 e8 0c             	shr    $0xc,%eax
80107fbb:	25 ff 03 00 00       	and    $0x3ff,%eax
80107fc0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107fc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fca:	01 d0                	add    %edx,%eax
}
80107fcc:	c9                   	leave  
80107fcd:	c3                   	ret    

80107fce <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107fce:	f3 0f 1e fb          	endbr32 
80107fd2:	55                   	push   %ebp
80107fd3:	89 e5                	mov    %esp,%ebp
80107fd5:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107fd8:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fdb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fe0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107fe3:	8b 55 0c             	mov    0xc(%ebp),%edx
80107fe6:	8b 45 10             	mov    0x10(%ebp),%eax
80107fe9:	01 d0                	add    %edx,%eax
80107feb:	83 e8 01             	sub    $0x1,%eax
80107fee:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ff3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107ff6:	83 ec 04             	sub    $0x4,%esp
80107ff9:	6a 01                	push   $0x1
80107ffb:	ff 75 f4             	pushl  -0xc(%ebp)
80107ffe:	ff 75 08             	pushl  0x8(%ebp)
80108001:	e8 2e ff ff ff       	call   80107f34 <walkpgdir>
80108006:	83 c4 10             	add    $0x10,%esp
80108009:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010800c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108010:	75 07                	jne    80108019 <mappages+0x4b>
      return -1;
80108012:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108017:	eb 6a                	jmp    80108083 <mappages+0xb5>
    if(*pte & (PTE_P | PTE_E))
80108019:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010801c:	8b 00                	mov    (%eax),%eax
8010801e:	25 01 04 00 00       	and    $0x401,%eax
80108023:	85 c0                	test   %eax,%eax
80108025:	74 0d                	je     80108034 <mappages+0x66>
      panic("p4Debug, remapping page");
80108027:	83 ec 0c             	sub    $0xc,%esp
8010802a:	68 e0 98 10 80       	push   $0x801098e0
8010802f:	e8 d4 85 ff ff       	call   80100608 <panic>

    if (perm & PTE_E)
80108034:	8b 45 18             	mov    0x18(%ebp),%eax
80108037:	25 00 04 00 00       	and    $0x400,%eax
8010803c:	85 c0                	test   %eax,%eax
8010803e:	74 12                	je     80108052 <mappages+0x84>
      *pte = pa | perm | PTE_E;
80108040:	8b 45 18             	mov    0x18(%ebp),%eax
80108043:	0b 45 14             	or     0x14(%ebp),%eax
80108046:	80 cc 04             	or     $0x4,%ah
80108049:	89 c2                	mov    %eax,%edx
8010804b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010804e:	89 10                	mov    %edx,(%eax)
80108050:	eb 10                	jmp    80108062 <mappages+0x94>
    else
      *pte = pa | perm | PTE_P;
80108052:	8b 45 18             	mov    0x18(%ebp),%eax
80108055:	0b 45 14             	or     0x14(%ebp),%eax
80108058:	83 c8 01             	or     $0x1,%eax
8010805b:	89 c2                	mov    %eax,%edx
8010805d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108060:	89 10                	mov    %edx,(%eax)


    if(a == last)
80108062:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108065:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108068:	74 13                	je     8010807d <mappages+0xaf>
      break;
    a += PGSIZE;
8010806a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108071:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108078:	e9 79 ff ff ff       	jmp    80107ff6 <mappages+0x28>
      break;
8010807d:	90                   	nop
  }
  return 0;
8010807e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108083:	c9                   	leave  
80108084:	c3                   	ret    

80108085 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108085:	f3 0f 1e fb          	endbr32 
80108089:	55                   	push   %ebp
8010808a:	89 e5                	mov    %esp,%ebp
8010808c:	53                   	push   %ebx
8010808d:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108090:	e8 cd ad ff ff       	call   80102e62 <kalloc>
80108095:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108098:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010809c:	75 07                	jne    801080a5 <setupkvm+0x20>
    return 0;
8010809e:	b8 00 00 00 00       	mov    $0x0,%eax
801080a3:	eb 78                	jmp    8010811d <setupkvm+0x98>
  memset(pgdir, 0, PGSIZE);
801080a5:	83 ec 04             	sub    $0x4,%esp
801080a8:	68 00 10 00 00       	push   $0x1000
801080ad:	6a 00                	push   $0x0
801080af:	ff 75 f0             	pushl  -0x10(%ebp)
801080b2:	e8 88 d4 ff ff       	call   8010553f <memset>
801080b7:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801080ba:	c7 45 f4 a0 c4 10 80 	movl   $0x8010c4a0,-0xc(%ebp)
801080c1:	eb 4e                	jmp    80108111 <setupkvm+0x8c>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801080c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080c6:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
801080c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080cc:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801080cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080d2:	8b 58 08             	mov    0x8(%eax),%ebx
801080d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080d8:	8b 40 04             	mov    0x4(%eax),%eax
801080db:	29 c3                	sub    %eax,%ebx
801080dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080e0:	8b 00                	mov    (%eax),%eax
801080e2:	83 ec 0c             	sub    $0xc,%esp
801080e5:	51                   	push   %ecx
801080e6:	52                   	push   %edx
801080e7:	53                   	push   %ebx
801080e8:	50                   	push   %eax
801080e9:	ff 75 f0             	pushl  -0x10(%ebp)
801080ec:	e8 dd fe ff ff       	call   80107fce <mappages>
801080f1:	83 c4 20             	add    $0x20,%esp
801080f4:	85 c0                	test   %eax,%eax
801080f6:	79 15                	jns    8010810d <setupkvm+0x88>
      freevm(pgdir);
801080f8:	83 ec 0c             	sub    $0xc,%esp
801080fb:	ff 75 f0             	pushl  -0x10(%ebp)
801080fe:	e8 13 05 00 00       	call   80108616 <freevm>
80108103:	83 c4 10             	add    $0x10,%esp
      return 0;
80108106:	b8 00 00 00 00       	mov    $0x0,%eax
8010810b:	eb 10                	jmp    8010811d <setupkvm+0x98>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010810d:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108111:	81 7d f4 e0 c4 10 80 	cmpl   $0x8010c4e0,-0xc(%ebp)
80108118:	72 a9                	jb     801080c3 <setupkvm+0x3e>
    }
  return pgdir;
8010811a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010811d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108120:	c9                   	leave  
80108121:	c3                   	ret    

80108122 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108122:	f3 0f 1e fb          	endbr32 
80108126:	55                   	push   %ebp
80108127:	89 e5                	mov    %esp,%ebp
80108129:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010812c:	e8 54 ff ff ff       	call   80108085 <setupkvm>
80108131:	a3 44 7f 11 80       	mov    %eax,0x80117f44
  switchkvm();
80108136:	e8 03 00 00 00       	call   8010813e <switchkvm>
}
8010813b:	90                   	nop
8010813c:	c9                   	leave  
8010813d:	c3                   	ret    

8010813e <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
8010813e:	f3 0f 1e fb          	endbr32 
80108142:	55                   	push   %ebp
80108143:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80108145:	a1 44 7f 11 80       	mov    0x80117f44,%eax
8010814a:	05 00 00 00 80       	add    $0x80000000,%eax
8010814f:	50                   	push   %eax
80108150:	e8 79 fa ff ff       	call   80107bce <lcr3>
80108155:	83 c4 04             	add    $0x4,%esp
}
80108158:	90                   	nop
80108159:	c9                   	leave  
8010815a:	c3                   	ret    

8010815b <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
8010815b:	f3 0f 1e fb          	endbr32 
8010815f:	55                   	push   %ebp
80108160:	89 e5                	mov    %esp,%ebp
80108162:	56                   	push   %esi
80108163:	53                   	push   %ebx
80108164:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80108167:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010816b:	75 0d                	jne    8010817a <switchuvm+0x1f>
    panic("switchuvm: no process");
8010816d:	83 ec 0c             	sub    $0xc,%esp
80108170:	68 f8 98 10 80       	push   $0x801098f8
80108175:	e8 8e 84 ff ff       	call   80100608 <panic>
  if(p->kstack == 0)
8010817a:	8b 45 08             	mov    0x8(%ebp),%eax
8010817d:	8b 40 08             	mov    0x8(%eax),%eax
80108180:	85 c0                	test   %eax,%eax
80108182:	75 0d                	jne    80108191 <switchuvm+0x36>
    panic("switchuvm: no kstack");
80108184:	83 ec 0c             	sub    $0xc,%esp
80108187:	68 0e 99 10 80       	push   $0x8010990e
8010818c:	e8 77 84 ff ff       	call   80100608 <panic>
  if(p->pgdir == 0)
80108191:	8b 45 08             	mov    0x8(%ebp),%eax
80108194:	8b 40 04             	mov    0x4(%eax),%eax
80108197:	85 c0                	test   %eax,%eax
80108199:	75 0d                	jne    801081a8 <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
8010819b:	83 ec 0c             	sub    $0xc,%esp
8010819e:	68 23 99 10 80       	push   $0x80109923
801081a3:	e8 60 84 ff ff       	call   80100608 <panic>

  pushcli();
801081a8:	e8 7f d2 ff ff       	call   8010542c <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801081ad:	e8 d2 c2 ff ff       	call   80104484 <mycpu>
801081b2:	89 c3                	mov    %eax,%ebx
801081b4:	e8 cb c2 ff ff       	call   80104484 <mycpu>
801081b9:	83 c0 08             	add    $0x8,%eax
801081bc:	89 c6                	mov    %eax,%esi
801081be:	e8 c1 c2 ff ff       	call   80104484 <mycpu>
801081c3:	83 c0 08             	add    $0x8,%eax
801081c6:	c1 e8 10             	shr    $0x10,%eax
801081c9:	88 45 f7             	mov    %al,-0x9(%ebp)
801081cc:	e8 b3 c2 ff ff       	call   80104484 <mycpu>
801081d1:	83 c0 08             	add    $0x8,%eax
801081d4:	c1 e8 18             	shr    $0x18,%eax
801081d7:	89 c2                	mov    %eax,%edx
801081d9:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801081e0:	67 00 
801081e2:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
801081e9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
801081ed:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
801081f3:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801081fa:	83 e0 f0             	and    $0xfffffff0,%eax
801081fd:	83 c8 09             	or     $0x9,%eax
80108200:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108206:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010820d:	83 c8 10             	or     $0x10,%eax
80108210:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108216:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010821d:	83 e0 9f             	and    $0xffffff9f,%eax
80108220:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108226:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010822d:	83 c8 80             	or     $0xffffff80,%eax
80108230:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108236:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010823d:	83 e0 f0             	and    $0xfffffff0,%eax
80108240:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108246:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010824d:	83 e0 ef             	and    $0xffffffef,%eax
80108250:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108256:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010825d:	83 e0 df             	and    $0xffffffdf,%eax
80108260:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108266:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010826d:	83 c8 40             	or     $0x40,%eax
80108270:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108276:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010827d:	83 e0 7f             	and    $0x7f,%eax
80108280:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108286:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
8010828c:	e8 f3 c1 ff ff       	call   80104484 <mycpu>
80108291:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108298:	83 e2 ef             	and    $0xffffffef,%edx
8010829b:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801082a1:	e8 de c1 ff ff       	call   80104484 <mycpu>
801082a6:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801082ac:	8b 45 08             	mov    0x8(%ebp),%eax
801082af:	8b 40 08             	mov    0x8(%eax),%eax
801082b2:	89 c3                	mov    %eax,%ebx
801082b4:	e8 cb c1 ff ff       	call   80104484 <mycpu>
801082b9:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
801082bf:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801082c2:	e8 bd c1 ff ff       	call   80104484 <mycpu>
801082c7:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
801082cd:	83 ec 0c             	sub    $0xc,%esp
801082d0:	6a 28                	push   $0x28
801082d2:	e8 e0 f8 ff ff       	call   80107bb7 <ltr>
801082d7:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
801082da:	8b 45 08             	mov    0x8(%ebp),%eax
801082dd:	8b 40 04             	mov    0x4(%eax),%eax
801082e0:	05 00 00 00 80       	add    $0x80000000,%eax
801082e5:	83 ec 0c             	sub    $0xc,%esp
801082e8:	50                   	push   %eax
801082e9:	e8 e0 f8 ff ff       	call   80107bce <lcr3>
801082ee:	83 c4 10             	add    $0x10,%esp
  popcli();
801082f1:	e8 87 d1 ff ff       	call   8010547d <popcli>
}
801082f6:	90                   	nop
801082f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
801082fa:	5b                   	pop    %ebx
801082fb:	5e                   	pop    %esi
801082fc:	5d                   	pop    %ebp
801082fd:	c3                   	ret    

801082fe <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801082fe:	f3 0f 1e fb          	endbr32 
80108302:	55                   	push   %ebp
80108303:	89 e5                	mov    %esp,%ebp
80108305:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80108308:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
8010830f:	76 0d                	jbe    8010831e <inituvm+0x20>
    panic("inituvm: more than a page");
80108311:	83 ec 0c             	sub    $0xc,%esp
80108314:	68 37 99 10 80       	push   $0x80109937
80108319:	e8 ea 82 ff ff       	call   80100608 <panic>
  mem = kalloc();
8010831e:	e8 3f ab ff ff       	call   80102e62 <kalloc>
80108323:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108326:	83 ec 04             	sub    $0x4,%esp
80108329:	68 00 10 00 00       	push   $0x1000
8010832e:	6a 00                	push   $0x0
80108330:	ff 75 f4             	pushl  -0xc(%ebp)
80108333:	e8 07 d2 ff ff       	call   8010553f <memset>
80108338:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
8010833b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010833e:	05 00 00 00 80       	add    $0x80000000,%eax
80108343:	83 ec 0c             	sub    $0xc,%esp
80108346:	6a 06                	push   $0x6
80108348:	50                   	push   %eax
80108349:	68 00 10 00 00       	push   $0x1000
8010834e:	6a 00                	push   $0x0
80108350:	ff 75 08             	pushl  0x8(%ebp)
80108353:	e8 76 fc ff ff       	call   80107fce <mappages>
80108358:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
8010835b:	83 ec 04             	sub    $0x4,%esp
8010835e:	ff 75 10             	pushl  0x10(%ebp)
80108361:	ff 75 0c             	pushl  0xc(%ebp)
80108364:	ff 75 f4             	pushl  -0xc(%ebp)
80108367:	e8 9a d2 ff ff       	call   80105606 <memmove>
8010836c:	83 c4 10             	add    $0x10,%esp
}
8010836f:	90                   	nop
80108370:	c9                   	leave  
80108371:	c3                   	ret    

80108372 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108372:	f3 0f 1e fb          	endbr32 
80108376:	55                   	push   %ebp
80108377:	89 e5                	mov    %esp,%ebp
80108379:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010837c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010837f:	25 ff 0f 00 00       	and    $0xfff,%eax
80108384:	85 c0                	test   %eax,%eax
80108386:	74 0d                	je     80108395 <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
80108388:	83 ec 0c             	sub    $0xc,%esp
8010838b:	68 54 99 10 80       	push   $0x80109954
80108390:	e8 73 82 ff ff       	call   80100608 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108395:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010839c:	e9 8f 00 00 00       	jmp    80108430 <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801083a1:	8b 55 0c             	mov    0xc(%ebp),%edx
801083a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083a7:	01 d0                	add    %edx,%eax
801083a9:	83 ec 04             	sub    $0x4,%esp
801083ac:	6a 00                	push   $0x0
801083ae:	50                   	push   %eax
801083af:	ff 75 08             	pushl  0x8(%ebp)
801083b2:	e8 7d fb ff ff       	call   80107f34 <walkpgdir>
801083b7:	83 c4 10             	add    $0x10,%esp
801083ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
801083bd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801083c1:	75 0d                	jne    801083d0 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
801083c3:	83 ec 0c             	sub    $0xc,%esp
801083c6:	68 77 99 10 80       	push   $0x80109977
801083cb:	e8 38 82 ff ff       	call   80100608 <panic>
    pa = PTE_ADDR(*pte);
801083d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083d3:	8b 00                	mov    (%eax),%eax
801083d5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083da:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801083dd:	8b 45 18             	mov    0x18(%ebp),%eax
801083e0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801083e3:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801083e8:	77 0b                	ja     801083f5 <loaduvm+0x83>
      n = sz - i;
801083ea:	8b 45 18             	mov    0x18(%ebp),%eax
801083ed:	2b 45 f4             	sub    -0xc(%ebp),%eax
801083f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801083f3:	eb 07                	jmp    801083fc <loaduvm+0x8a>
    else
      n = PGSIZE;
801083f5:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
801083fc:	8b 55 14             	mov    0x14(%ebp),%edx
801083ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108402:	01 d0                	add    %edx,%eax
80108404:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108407:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010840d:	ff 75 f0             	pushl  -0x10(%ebp)
80108410:	50                   	push   %eax
80108411:	52                   	push   %edx
80108412:	ff 75 10             	pushl  0x10(%ebp)
80108415:	e8 60 9c ff ff       	call   8010207a <readi>
8010841a:	83 c4 10             	add    $0x10,%esp
8010841d:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80108420:	74 07                	je     80108429 <loaduvm+0xb7>
      return -1;
80108422:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108427:	eb 18                	jmp    80108441 <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
80108429:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108433:	3b 45 18             	cmp    0x18(%ebp),%eax
80108436:	0f 82 65 ff ff ff    	jb     801083a1 <loaduvm+0x2f>
  }
  return 0;
8010843c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108441:	c9                   	leave  
80108442:	c3                   	ret    

80108443 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108443:	f3 0f 1e fb          	endbr32 
80108447:	55                   	push   %ebp
80108448:	89 e5                	mov    %esp,%ebp
8010844a:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010844d:	8b 45 10             	mov    0x10(%ebp),%eax
80108450:	85 c0                	test   %eax,%eax
80108452:	79 0a                	jns    8010845e <allocuvm+0x1b>
    return 0;
80108454:	b8 00 00 00 00       	mov    $0x0,%eax
80108459:	e9 ec 00 00 00       	jmp    8010854a <allocuvm+0x107>
  if(newsz < oldsz)
8010845e:	8b 45 10             	mov    0x10(%ebp),%eax
80108461:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108464:	73 08                	jae    8010846e <allocuvm+0x2b>
    return oldsz;
80108466:	8b 45 0c             	mov    0xc(%ebp),%eax
80108469:	e9 dc 00 00 00       	jmp    8010854a <allocuvm+0x107>

  a = PGROUNDUP(oldsz);
8010846e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108471:	05 ff 0f 00 00       	add    $0xfff,%eax
80108476:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010847b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010847e:	e9 b8 00 00 00       	jmp    8010853b <allocuvm+0xf8>
    mem = kalloc();
80108483:	e8 da a9 ff ff       	call   80102e62 <kalloc>
80108488:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010848b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010848f:	75 2e                	jne    801084bf <allocuvm+0x7c>
      cprintf("allocuvm out of memory\n");
80108491:	83 ec 0c             	sub    $0xc,%esp
80108494:	68 95 99 10 80       	push   $0x80109995
80108499:	e8 7a 7f ff ff       	call   80100418 <cprintf>
8010849e:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801084a1:	83 ec 04             	sub    $0x4,%esp
801084a4:	ff 75 0c             	pushl  0xc(%ebp)
801084a7:	ff 75 10             	pushl  0x10(%ebp)
801084aa:	ff 75 08             	pushl  0x8(%ebp)
801084ad:	e8 9a 00 00 00       	call   8010854c <deallocuvm>
801084b2:	83 c4 10             	add    $0x10,%esp
      return 0;
801084b5:	b8 00 00 00 00       	mov    $0x0,%eax
801084ba:	e9 8b 00 00 00       	jmp    8010854a <allocuvm+0x107>
    }
    memset(mem, 0, PGSIZE);
801084bf:	83 ec 04             	sub    $0x4,%esp
801084c2:	68 00 10 00 00       	push   $0x1000
801084c7:	6a 00                	push   $0x0
801084c9:	ff 75 f0             	pushl  -0x10(%ebp)
801084cc:	e8 6e d0 ff ff       	call   8010553f <memset>
801084d1:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801084d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084d7:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801084dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084e0:	83 ec 0c             	sub    $0xc,%esp
801084e3:	6a 06                	push   $0x6
801084e5:	52                   	push   %edx
801084e6:	68 00 10 00 00       	push   $0x1000
801084eb:	50                   	push   %eax
801084ec:	ff 75 08             	pushl  0x8(%ebp)
801084ef:	e8 da fa ff ff       	call   80107fce <mappages>
801084f4:	83 c4 20             	add    $0x20,%esp
801084f7:	85 c0                	test   %eax,%eax
801084f9:	79 39                	jns    80108534 <allocuvm+0xf1>
      cprintf("allocuvm out of memory (2)\n");
801084fb:	83 ec 0c             	sub    $0xc,%esp
801084fe:	68 ad 99 10 80       	push   $0x801099ad
80108503:	e8 10 7f ff ff       	call   80100418 <cprintf>
80108508:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
8010850b:	83 ec 04             	sub    $0x4,%esp
8010850e:	ff 75 0c             	pushl  0xc(%ebp)
80108511:	ff 75 10             	pushl  0x10(%ebp)
80108514:	ff 75 08             	pushl  0x8(%ebp)
80108517:	e8 30 00 00 00       	call   8010854c <deallocuvm>
8010851c:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
8010851f:	83 ec 0c             	sub    $0xc,%esp
80108522:	ff 75 f0             	pushl  -0x10(%ebp)
80108525:	e8 9a a8 ff ff       	call   80102dc4 <kfree>
8010852a:	83 c4 10             	add    $0x10,%esp
      return 0;
8010852d:	b8 00 00 00 00       	mov    $0x0,%eax
80108532:	eb 16                	jmp    8010854a <allocuvm+0x107>
  for(; a < newsz; a += PGSIZE){
80108534:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010853b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010853e:	3b 45 10             	cmp    0x10(%ebp),%eax
80108541:	0f 82 3c ff ff ff    	jb     80108483 <allocuvm+0x40>
    }
  }
  return newsz;
80108547:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010854a:	c9                   	leave  
8010854b:	c3                   	ret    

8010854c <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010854c:	f3 0f 1e fb          	endbr32 
80108550:	55                   	push   %ebp
80108551:	89 e5                	mov    %esp,%ebp
80108553:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108556:	8b 45 10             	mov    0x10(%ebp),%eax
80108559:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010855c:	72 08                	jb     80108566 <deallocuvm+0x1a>
    return oldsz;
8010855e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108561:	e9 ae 00 00 00       	jmp    80108614 <deallocuvm+0xc8>

  a = PGROUNDUP(newsz);
80108566:	8b 45 10             	mov    0x10(%ebp),%eax
80108569:	05 ff 0f 00 00       	add    $0xfff,%eax
8010856e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108573:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108576:	e9 8a 00 00 00       	jmp    80108605 <deallocuvm+0xb9>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010857b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010857e:	83 ec 04             	sub    $0x4,%esp
80108581:	6a 00                	push   $0x0
80108583:	50                   	push   %eax
80108584:	ff 75 08             	pushl  0x8(%ebp)
80108587:	e8 a8 f9 ff ff       	call   80107f34 <walkpgdir>
8010858c:	83 c4 10             	add    $0x10,%esp
8010858f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108592:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108596:	75 16                	jne    801085ae <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80108598:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010859b:	c1 e8 16             	shr    $0x16,%eax
8010859e:	83 c0 01             	add    $0x1,%eax
801085a1:	c1 e0 16             	shl    $0x16,%eax
801085a4:	2d 00 10 00 00       	sub    $0x1000,%eax
801085a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801085ac:	eb 50                	jmp    801085fe <deallocuvm+0xb2>
    else if((*pte & (PTE_P | PTE_E)) != 0){
801085ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085b1:	8b 00                	mov    (%eax),%eax
801085b3:	25 01 04 00 00       	and    $0x401,%eax
801085b8:	85 c0                	test   %eax,%eax
801085ba:	74 42                	je     801085fe <deallocuvm+0xb2>
      pa = PTE_ADDR(*pte);
801085bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085bf:	8b 00                	mov    (%eax),%eax
801085c1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801085c9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801085cd:	75 0d                	jne    801085dc <deallocuvm+0x90>
        panic("kfree");
801085cf:	83 ec 0c             	sub    $0xc,%esp
801085d2:	68 c9 99 10 80       	push   $0x801099c9
801085d7:	e8 2c 80 ff ff       	call   80100608 <panic>
      char *v = P2V(pa);
801085dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085df:	05 00 00 00 80       	add    $0x80000000,%eax
801085e4:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801085e7:	83 ec 0c             	sub    $0xc,%esp
801085ea:	ff 75 e8             	pushl  -0x18(%ebp)
801085ed:	e8 d2 a7 ff ff       	call   80102dc4 <kfree>
801085f2:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
801085f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085f8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
801085fe:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108605:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108608:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010860b:	0f 82 6a ff ff ff    	jb     8010857b <deallocuvm+0x2f>
    }
  }
  return newsz;
80108611:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108614:	c9                   	leave  
80108615:	c3                   	ret    

80108616 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108616:	f3 0f 1e fb          	endbr32 
8010861a:	55                   	push   %ebp
8010861b:	89 e5                	mov    %esp,%ebp
8010861d:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108620:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108624:	75 0d                	jne    80108633 <freevm+0x1d>
    panic("freevm: no pgdir");
80108626:	83 ec 0c             	sub    $0xc,%esp
80108629:	68 cf 99 10 80       	push   $0x801099cf
8010862e:	e8 d5 7f ff ff       	call   80100608 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108633:	83 ec 04             	sub    $0x4,%esp
80108636:	6a 00                	push   $0x0
80108638:	68 00 00 00 80       	push   $0x80000000
8010863d:	ff 75 08             	pushl  0x8(%ebp)
80108640:	e8 07 ff ff ff       	call   8010854c <deallocuvm>
80108645:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108648:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010864f:	eb 4a                	jmp    8010869b <freevm+0x85>
    if(pgdir[i] & (PTE_P | PTE_E)){
80108651:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108654:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010865b:	8b 45 08             	mov    0x8(%ebp),%eax
8010865e:	01 d0                	add    %edx,%eax
80108660:	8b 00                	mov    (%eax),%eax
80108662:	25 01 04 00 00       	and    $0x401,%eax
80108667:	85 c0                	test   %eax,%eax
80108669:	74 2c                	je     80108697 <freevm+0x81>
      char * v = P2V(PTE_ADDR(pgdir[i]));
8010866b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010866e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108675:	8b 45 08             	mov    0x8(%ebp),%eax
80108678:	01 d0                	add    %edx,%eax
8010867a:	8b 00                	mov    (%eax),%eax
8010867c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108681:	05 00 00 00 80       	add    $0x80000000,%eax
80108686:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108689:	83 ec 0c             	sub    $0xc,%esp
8010868c:	ff 75 f0             	pushl  -0x10(%ebp)
8010868f:	e8 30 a7 ff ff       	call   80102dc4 <kfree>
80108694:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108697:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010869b:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801086a2:	76 ad                	jbe    80108651 <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
801086a4:	83 ec 0c             	sub    $0xc,%esp
801086a7:	ff 75 08             	pushl  0x8(%ebp)
801086aa:	e8 15 a7 ff ff       	call   80102dc4 <kfree>
801086af:	83 c4 10             	add    $0x10,%esp
}
801086b2:	90                   	nop
801086b3:	c9                   	leave  
801086b4:	c3                   	ret    

801086b5 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801086b5:	f3 0f 1e fb          	endbr32 
801086b9:	55                   	push   %ebp
801086ba:	89 e5                	mov    %esp,%ebp
801086bc:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801086bf:	83 ec 04             	sub    $0x4,%esp
801086c2:	6a 00                	push   $0x0
801086c4:	ff 75 0c             	pushl  0xc(%ebp)
801086c7:	ff 75 08             	pushl  0x8(%ebp)
801086ca:	e8 65 f8 ff ff       	call   80107f34 <walkpgdir>
801086cf:	83 c4 10             	add    $0x10,%esp
801086d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801086d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801086d9:	75 0d                	jne    801086e8 <clearpteu+0x33>
    panic("clearpteu");
801086db:	83 ec 0c             	sub    $0xc,%esp
801086de:	68 e0 99 10 80       	push   $0x801099e0
801086e3:	e8 20 7f ff ff       	call   80100608 <panic>
  *pte &= ~PTE_U;
801086e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086eb:	8b 00                	mov    (%eax),%eax
801086ed:	83 e0 fb             	and    $0xfffffffb,%eax
801086f0:	89 c2                	mov    %eax,%edx
801086f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f5:	89 10                	mov    %edx,(%eax)
}
801086f7:	90                   	nop
801086f8:	c9                   	leave  
801086f9:	c3                   	ret    

801086fa <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801086fa:	f3 0f 1e fb          	endbr32 
801086fe:	55                   	push   %ebp
801086ff:	89 e5                	mov    %esp,%ebp
80108701:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108704:	e8 7c f9 ff ff       	call   80108085 <setupkvm>
80108709:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010870c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108710:	75 0a                	jne    8010871c <copyuvm+0x22>
    return 0;
80108712:	b8 00 00 00 00       	mov    $0x0,%eax
80108717:	e9 fa 00 00 00       	jmp    80108816 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
8010871c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108723:	e9 c9 00 00 00       	jmp    801087f1 <copyuvm+0xf7>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108728:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010872b:	83 ec 04             	sub    $0x4,%esp
8010872e:	6a 00                	push   $0x0
80108730:	50                   	push   %eax
80108731:	ff 75 08             	pushl  0x8(%ebp)
80108734:	e8 fb f7 ff ff       	call   80107f34 <walkpgdir>
80108739:	83 c4 10             	add    $0x10,%esp
8010873c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010873f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108743:	75 0d                	jne    80108752 <copyuvm+0x58>
      panic("p4Debug: inside copyuvm, pte should exist");
80108745:	83 ec 0c             	sub    $0xc,%esp
80108748:	68 ec 99 10 80       	push   $0x801099ec
8010874d:	e8 b6 7e ff ff       	call   80100608 <panic>
    if(!(*pte & (PTE_P | PTE_E)))
80108752:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108755:	8b 00                	mov    (%eax),%eax
80108757:	25 01 04 00 00       	and    $0x401,%eax
8010875c:	85 c0                	test   %eax,%eax
8010875e:	75 0d                	jne    8010876d <copyuvm+0x73>
      panic("p4Debug: inside copyuvm, page not present");
80108760:	83 ec 0c             	sub    $0xc,%esp
80108763:	68 18 9a 10 80       	push   $0x80109a18
80108768:	e8 9b 7e ff ff       	call   80100608 <panic>
    pa = PTE_ADDR(*pte);
8010876d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108770:	8b 00                	mov    (%eax),%eax
80108772:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108777:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010877a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010877d:	8b 00                	mov    (%eax),%eax
8010877f:	25 ff 0f 00 00       	and    $0xfff,%eax
80108784:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108787:	e8 d6 a6 ff ff       	call   80102e62 <kalloc>
8010878c:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010878f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108793:	74 6d                	je     80108802 <copyuvm+0x108>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108795:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108798:	05 00 00 00 80       	add    $0x80000000,%eax
8010879d:	83 ec 04             	sub    $0x4,%esp
801087a0:	68 00 10 00 00       	push   $0x1000
801087a5:	50                   	push   %eax
801087a6:	ff 75 e0             	pushl  -0x20(%ebp)
801087a9:	e8 58 ce ff ff       	call   80105606 <memmove>
801087ae:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
801087b1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801087b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801087b7:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801087bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087c0:	83 ec 0c             	sub    $0xc,%esp
801087c3:	52                   	push   %edx
801087c4:	51                   	push   %ecx
801087c5:	68 00 10 00 00       	push   $0x1000
801087ca:	50                   	push   %eax
801087cb:	ff 75 f0             	pushl  -0x10(%ebp)
801087ce:	e8 fb f7 ff ff       	call   80107fce <mappages>
801087d3:	83 c4 20             	add    $0x20,%esp
801087d6:	85 c0                	test   %eax,%eax
801087d8:	79 10                	jns    801087ea <copyuvm+0xf0>
      kfree(mem);
801087da:	83 ec 0c             	sub    $0xc,%esp
801087dd:	ff 75 e0             	pushl  -0x20(%ebp)
801087e0:	e8 df a5 ff ff       	call   80102dc4 <kfree>
801087e5:	83 c4 10             	add    $0x10,%esp
      goto bad;
801087e8:	eb 19                	jmp    80108803 <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
801087ea:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801087f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801087f7:	0f 82 2b ff ff ff    	jb     80108728 <copyuvm+0x2e>
    }
  }
  return d;
801087fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108800:	eb 14                	jmp    80108816 <copyuvm+0x11c>
      goto bad;
80108802:	90                   	nop

bad:
  freevm(d);
80108803:	83 ec 0c             	sub    $0xc,%esp
80108806:	ff 75 f0             	pushl  -0x10(%ebp)
80108809:	e8 08 fe ff ff       	call   80108616 <freevm>
8010880e:	83 c4 10             	add    $0x10,%esp
  return 0;
80108811:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108816:	c9                   	leave  
80108817:	c3                   	ret    

80108818 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108818:	f3 0f 1e fb          	endbr32 
8010881c:	55                   	push   %ebp
8010881d:	89 e5                	mov    %esp,%ebp
8010881f:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108822:	83 ec 04             	sub    $0x4,%esp
80108825:	6a 00                	push   $0x0
80108827:	ff 75 0c             	pushl  0xc(%ebp)
8010882a:	ff 75 08             	pushl  0x8(%ebp)
8010882d:	e8 02 f7 ff ff       	call   80107f34 <walkpgdir>
80108832:	83 c4 10             	add    $0x10,%esp
80108835:	89 45 f4             	mov    %eax,-0xc(%ebp)
  // p4Debug: Check for page's present and encrypted flags.
  if(((*pte & PTE_P) | (*pte & PTE_E)) == 0)
80108838:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010883b:	8b 00                	mov    (%eax),%eax
8010883d:	25 01 04 00 00       	and    $0x401,%eax
80108842:	85 c0                	test   %eax,%eax
80108844:	75 07                	jne    8010884d <uva2ka+0x35>
    return 0;
80108846:	b8 00 00 00 00       	mov    $0x0,%eax
8010884b:	eb 22                	jmp    8010886f <uva2ka+0x57>
  if((*pte & PTE_U) == 0)
8010884d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108850:	8b 00                	mov    (%eax),%eax
80108852:	83 e0 04             	and    $0x4,%eax
80108855:	85 c0                	test   %eax,%eax
80108857:	75 07                	jne    80108860 <uva2ka+0x48>
    return 0;
80108859:	b8 00 00 00 00       	mov    $0x0,%eax
8010885e:	eb 0f                	jmp    8010886f <uva2ka+0x57>
  return (char*)P2V(PTE_ADDR(*pte));
80108860:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108863:	8b 00                	mov    (%eax),%eax
80108865:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010886a:	05 00 00 00 80       	add    $0x80000000,%eax
}
8010886f:	c9                   	leave  
80108870:	c3                   	ret    

80108871 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108871:	f3 0f 1e fb          	endbr32 
80108875:	55                   	push   %ebp
80108876:	89 e5                	mov    %esp,%ebp
80108878:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010887b:	8b 45 10             	mov    0x10(%ebp),%eax
8010887e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108881:	eb 7f                	jmp    80108902 <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
80108883:	8b 45 0c             	mov    0xc(%ebp),%eax
80108886:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010888b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010888e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108891:	83 ec 08             	sub    $0x8,%esp
80108894:	50                   	push   %eax
80108895:	ff 75 08             	pushl  0x8(%ebp)
80108898:	e8 7b ff ff ff       	call   80108818 <uva2ka>
8010889d:	83 c4 10             	add    $0x10,%esp
801088a0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801088a3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801088a7:	75 07                	jne    801088b0 <copyout+0x3f>
    {
      //p4Debug : Cannot find page in kernel space.
      return -1;
801088a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801088ae:	eb 61                	jmp    80108911 <copyout+0xa0>
    }
    n = PGSIZE - (va - va0);
801088b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088b3:	2b 45 0c             	sub    0xc(%ebp),%eax
801088b6:	05 00 10 00 00       	add    $0x1000,%eax
801088bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801088be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088c1:	3b 45 14             	cmp    0x14(%ebp),%eax
801088c4:	76 06                	jbe    801088cc <copyout+0x5b>
      n = len;
801088c6:	8b 45 14             	mov    0x14(%ebp),%eax
801088c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801088cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801088cf:	2b 45 ec             	sub    -0x14(%ebp),%eax
801088d2:	89 c2                	mov    %eax,%edx
801088d4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801088d7:	01 d0                	add    %edx,%eax
801088d9:	83 ec 04             	sub    $0x4,%esp
801088dc:	ff 75 f0             	pushl  -0x10(%ebp)
801088df:	ff 75 f4             	pushl  -0xc(%ebp)
801088e2:	50                   	push   %eax
801088e3:	e8 1e cd ff ff       	call   80105606 <memmove>
801088e8:	83 c4 10             	add    $0x10,%esp
    len -= n;
801088eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088ee:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801088f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088f4:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801088f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088fa:	05 00 10 00 00       	add    $0x1000,%eax
801088ff:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108902:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108906:	0f 85 77 ff ff ff    	jne    80108883 <copyout+0x12>
  }
  return 0;
8010890c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108911:	c9                   	leave  
80108912:	c3                   	ret    

80108913 <translate_and_set>:

//This function is just like uva2ka but sets the PTE_E bit and clears PTE_P
char* translate_and_set(pde_t *pgdir, char *uva) {
80108913:	f3 0f 1e fb          	endbr32 
80108917:	55                   	push   %ebp
80108918:	89 e5                	mov    %esp,%ebp
8010891a:	83 ec 18             	sub    $0x18,%esp
  cprintf("p4Debug: setting PTE_E for %p, VPN %d\n", uva, PPN(uva));
8010891d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108920:	c1 e8 0c             	shr    $0xc,%eax
80108923:	83 ec 04             	sub    $0x4,%esp
80108926:	50                   	push   %eax
80108927:	ff 75 0c             	pushl  0xc(%ebp)
8010892a:	68 44 9a 10 80       	push   $0x80109a44
8010892f:	e8 e4 7a ff ff       	call   80100418 <cprintf>
80108934:	83 c4 10             	add    $0x10,%esp
  pte_t *pte;
  pte = walkpgdir(pgdir, uva, 0);
80108937:	83 ec 04             	sub    $0x4,%esp
8010893a:	6a 00                	push   $0x0
8010893c:	ff 75 0c             	pushl  0xc(%ebp)
8010893f:	ff 75 08             	pushl  0x8(%ebp)
80108942:	e8 ed f5 ff ff       	call   80107f34 <walkpgdir>
80108947:	83 c4 10             	add    $0x10,%esp
8010894a:	89 45 f4             	mov    %eax,-0xc(%ebp)

  //p4Debug: If page is not present AND it is not encrypted.
  if((*pte & PTE_P) == 0 && (*pte & PTE_E) == 0)
8010894d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108950:	8b 00                	mov    (%eax),%eax
80108952:	83 e0 01             	and    $0x1,%eax
80108955:	85 c0                	test   %eax,%eax
80108957:	75 18                	jne    80108971 <translate_and_set+0x5e>
80108959:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010895c:	8b 00                	mov    (%eax),%eax
8010895e:	25 00 04 00 00       	and    $0x400,%eax
80108963:	85 c0                	test   %eax,%eax
80108965:	75 0a                	jne    80108971 <translate_and_set+0x5e>
    return 0;
80108967:	b8 00 00 00 00       	mov    $0x0,%eax
8010896c:	e9 84 00 00 00       	jmp    801089f5 <translate_and_set+0xe2>
  //p4Debug: If page is already encrypted, i.e. PTE_E is set, return NULL as error;
  if((*pte & PTE_E)) {
80108971:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108974:	8b 00                	mov    (%eax),%eax
80108976:	25 00 04 00 00       	and    $0x400,%eax
8010897b:	85 c0                	test   %eax,%eax
8010897d:	74 07                	je     80108986 <translate_and_set+0x73>
    return 0;
8010897f:	b8 00 00 00 00       	mov    $0x0,%eax
80108984:	eb 6f                	jmp    801089f5 <translate_and_set+0xe2>
  }
  // p4Debug: Check if users are allowed to use this page
  if((*pte & PTE_U) == 0)
80108986:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108989:	8b 00                	mov    (%eax),%eax
8010898b:	83 e0 04             	and    $0x4,%eax
8010898e:	85 c0                	test   %eax,%eax
80108990:	75 07                	jne    80108999 <translate_and_set+0x86>
    return 0;
80108992:	b8 00 00 00 00       	mov    $0x0,%eax
80108997:	eb 5c                	jmp    801089f5 <translate_and_set+0xe2>
  //p4Debug: Set Page as encrypted and not present so that we can trap(see trap.c) to decrypt page
  cprintf("p4Debug: PTE was %x and its pointer %p\n", *pte, pte);
80108999:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010899c:	8b 00                	mov    (%eax),%eax
8010899e:	83 ec 04             	sub    $0x4,%esp
801089a1:	ff 75 f4             	pushl  -0xc(%ebp)
801089a4:	50                   	push   %eax
801089a5:	68 6c 9a 10 80       	push   $0x80109a6c
801089aa:	e8 69 7a ff ff       	call   80100418 <cprintf>
801089af:	83 c4 10             	add    $0x10,%esp
  *pte = *pte | PTE_E;
801089b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089b5:	8b 00                	mov    (%eax),%eax
801089b7:	80 cc 04             	or     $0x4,%ah
801089ba:	89 c2                	mov    %eax,%edx
801089bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089bf:	89 10                	mov    %edx,(%eax)
  *pte = *pte & ~PTE_P;
801089c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089c4:	8b 00                	mov    (%eax),%eax
801089c6:	83 e0 fe             	and    $0xfffffffe,%eax
801089c9:	89 c2                	mov    %eax,%edx
801089cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ce:	89 10                	mov    %edx,(%eax)
  cprintf("p4Debug: PTE is now %x\n", *pte);
801089d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089d3:	8b 00                	mov    (%eax),%eax
801089d5:	83 ec 08             	sub    $0x8,%esp
801089d8:	50                   	push   %eax
801089d9:	68 94 9a 10 80       	push   $0x80109a94
801089de:	e8 35 7a ff ff       	call   80100418 <cprintf>
801089e3:	83 c4 10             	add    $0x10,%esp
  return (char*)P2V(PTE_ADDR(*pte));
801089e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089e9:	8b 00                	mov    (%eax),%eax
801089eb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801089f0:	05 00 00 00 80       	add    $0x80000000,%eax
}
801089f5:	c9                   	leave  
801089f6:	c3                   	ret    

801089f7 <mdecrypt>:


int mdecrypt(char *virtual_addr) {
801089f7:	f3 0f 1e fb          	endbr32 
801089fb:	55                   	push   %ebp
801089fc:	89 e5                	mov    %esp,%ebp
801089fe:	83 ec 28             	sub    $0x28,%esp

  cprintf("p4Debug:  mdecrypt VPN %d, %p, pid %d\n", PPN(virtual_addr), virtual_addr, myproc()->pid);
80108a01:	e8 fa ba ff ff       	call   80104500 <myproc>
80108a06:	8b 40 10             	mov    0x10(%eax),%eax
80108a09:	8b 55 08             	mov    0x8(%ebp),%edx
80108a0c:	c1 ea 0c             	shr    $0xc,%edx
80108a0f:	50                   	push   %eax
80108a10:	ff 75 08             	pushl  0x8(%ebp)
80108a13:	52                   	push   %edx
80108a14:	68 ac 9a 10 80       	push   $0x80109aac
80108a19:	e8 fa 79 ff ff       	call   80100418 <cprintf>
80108a1e:	83 c4 10             	add    $0x10,%esp
  //p4Debug: virtual_addr is a virtual address in this PID's userspace.
  struct proc * p = myproc();
80108a21:	e8 da ba ff ff       	call   80104500 <myproc>
80108a26:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pde_t* mypd = p->pgdir;
80108a29:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a2c:	8b 40 04             	mov    0x4(%eax),%eax
80108a2f:	89 45 e8             	mov    %eax,-0x18(%ebp)


  
  //set the present bit to true and encrypt bit to false
  pte_t * pte = walkpgdir(mypd, virtual_addr, 0);
80108a32:	83 ec 04             	sub    $0x4,%esp
80108a35:	6a 00                	push   $0x0
80108a37:	ff 75 08             	pushl  0x8(%ebp)
80108a3a:	ff 75 e8             	pushl  -0x18(%ebp)
80108a3d:	e8 f2 f4 ff ff       	call   80107f34 <walkpgdir>
80108a42:	83 c4 10             	add    $0x10,%esp
80108a45:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if (!pte || *pte == 0) {
80108a48:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108a4c:	74 09                	je     80108a57 <mdecrypt+0x60>
80108a4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108a51:	8b 00                	mov    (%eax),%eax
80108a53:	85 c0                	test   %eax,%eax
80108a55:	75 1a                	jne    80108a71 <mdecrypt+0x7a>
    cprintf("p4Debug: walkpgdir failed\n");
80108a57:	83 ec 0c             	sub    $0xc,%esp
80108a5a:	68 d3 9a 10 80       	push   $0x80109ad3
80108a5f:	e8 b4 79 ff ff       	call   80100418 <cprintf>
80108a64:	83 c4 10             	add    $0x10,%esp
    return -1;
80108a67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108a6c:	e9 14 01 00 00       	jmp    80108b85 <mdecrypt+0x18e>
  }
  cprintf("p4Debug: pte was %x\n", *pte);
80108a71:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108a74:	8b 00                	mov    (%eax),%eax
80108a76:	83 ec 08             	sub    $0x8,%esp
80108a79:	50                   	push   %eax
80108a7a:	68 ee 9a 10 80       	push   $0x80109aee
80108a7f:	e8 94 79 ff ff       	call   80100418 <cprintf>
80108a84:	83 c4 10             	add    $0x10,%esp
  *pte = *pte & ~PTE_E;
80108a87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108a8a:	8b 00                	mov    (%eax),%eax
80108a8c:	80 e4 fb             	and    $0xfb,%ah
80108a8f:	89 c2                	mov    %eax,%edx
80108a91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108a94:	89 10                	mov    %edx,(%eax)
  *pte = *pte | PTE_P;
80108a96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108a99:	8b 00                	mov    (%eax),%eax
80108a9b:	83 c8 01             	or     $0x1,%eax
80108a9e:	89 c2                	mov    %eax,%edx
80108aa0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108aa3:	89 10                	mov    %edx,(%eax)
  cprintf("p4Debug: pte is %x\n", *pte);
80108aa5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108aa8:	8b 00                	mov    (%eax),%eax
80108aaa:	83 ec 08             	sub    $0x8,%esp
80108aad:	50                   	push   %eax
80108aae:	68 03 9b 10 80       	push   $0x80109b03
80108ab3:	e8 60 79 ff ff       	call   80100418 <cprintf>
80108ab8:	83 c4 10             	add    $0x10,%esp
  clock_add((char*)P2V(PTE_ADDR(*pte)));
80108abb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108abe:	8b 00                	mov    (%eax),%eax
80108ac0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ac5:	05 00 00 00 80       	add    $0x80000000,%eax
80108aca:	83 ec 0c             	sub    $0xc,%esp
80108acd:	50                   	push   %eax
80108ace:	e8 8f 05 00 00       	call   80109062 <clock_add>
80108ad3:	83 c4 10             	add    $0x10,%esp

  

  char * original = uva2ka(mypd, virtual_addr) + OFFSET(virtual_addr);
80108ad6:	83 ec 08             	sub    $0x8,%esp
80108ad9:	ff 75 08             	pushl  0x8(%ebp)
80108adc:	ff 75 e8             	pushl  -0x18(%ebp)
80108adf:	e8 34 fd ff ff       	call   80108818 <uva2ka>
80108ae4:	83 c4 10             	add    $0x10,%esp
80108ae7:	8b 55 08             	mov    0x8(%ebp),%edx
80108aea:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
80108af0:	01 d0                	add    %edx,%eax
80108af2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  cprintf("p4Debug: Original in decrypt was %p\n", original);
80108af5:	83 ec 08             	sub    $0x8,%esp
80108af8:	ff 75 e0             	pushl  -0x20(%ebp)
80108afb:	68 18 9b 10 80       	push   $0x80109b18
80108b00:	e8 13 79 ff ff       	call   80100418 <cprintf>
80108b05:	83 c4 10             	add    $0x10,%esp
  virtual_addr = (char *)PGROUNDDOWN((uint)virtual_addr);
80108b08:	8b 45 08             	mov    0x8(%ebp),%eax
80108b0b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108b10:	89 45 08             	mov    %eax,0x8(%ebp)
  cprintf("p4Debug: mdecrypt: rounded down va is %p\n", virtual_addr);
80108b13:	83 ec 08             	sub    $0x8,%esp
80108b16:	ff 75 08             	pushl  0x8(%ebp)
80108b19:	68 40 9b 10 80       	push   $0x80109b40
80108b1e:	e8 f5 78 ff ff       	call   80100418 <cprintf>
80108b23:	83 c4 10             	add    $0x10,%esp

  char * kvp = uva2ka(mypd, virtual_addr);
80108b26:	83 ec 08             	sub    $0x8,%esp
80108b29:	ff 75 08             	pushl  0x8(%ebp)
80108b2c:	ff 75 e8             	pushl  -0x18(%ebp)
80108b2f:	e8 e4 fc ff ff       	call   80108818 <uva2ka>
80108b34:	83 c4 10             	add    $0x10,%esp
80108b37:	89 45 dc             	mov    %eax,-0x24(%ebp)
  if (!kvp || *kvp == 0) {
80108b3a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80108b3e:	74 0a                	je     80108b4a <mdecrypt+0x153>
80108b40:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108b43:	0f b6 00             	movzbl (%eax),%eax
80108b46:	84 c0                	test   %al,%al
80108b48:	75 07                	jne    80108b51 <mdecrypt+0x15a>
    return -1;
80108b4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108b4f:	eb 34                	jmp    80108b85 <mdecrypt+0x18e>
  }
  
  char * slider = virtual_addr;
80108b51:	8b 45 08             	mov    0x8(%ebp),%eax
80108b54:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int offset = 0; offset < PGSIZE; offset++) {
80108b57:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108b5e:	eb 17                	jmp    80108b77 <mdecrypt+0x180>
    *slider = *slider ^ 0xFF;
80108b60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b63:	0f b6 00             	movzbl (%eax),%eax
80108b66:	f7 d0                	not    %eax
80108b68:	89 c2                	mov    %eax,%edx
80108b6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b6d:	88 10                	mov    %dl,(%eax)
    slider++;
80108b6f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  for (int offset = 0; offset < PGSIZE; offset++) {
80108b73:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108b77:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80108b7e:	7e e0                	jle    80108b60 <mdecrypt+0x169>
  }
  
  return 0;
80108b80:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108b85:	c9                   	leave  
80108b86:	c3                   	ret    

80108b87 <mencrypt>:

int mencrypt(char *virtual_addr, int len) {
80108b87:	f3 0f 1e fb          	endbr32 
80108b8b:	55                   	push   %ebp
80108b8c:	89 e5                	mov    %esp,%ebp
80108b8e:	83 ec 38             	sub    $0x38,%esp
  if(len == 0){
80108b91:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80108b95:	75 0a                	jne    80108ba1 <mencrypt+0x1a>
    return 0;
80108b97:	b8 00 00 00 00       	mov    $0x0,%eax
80108b9c:	e9 d9 01 00 00       	jmp    80108d7a <mencrypt+0x1f3>
  }
  cprintf("p4Debug: mencrypt-: %p %d\n", virtual_addr, len);
80108ba1:	83 ec 04             	sub    $0x4,%esp
80108ba4:	ff 75 0c             	pushl  0xc(%ebp)
80108ba7:	ff 75 08             	pushl  0x8(%ebp)
80108baa:	68 6a 9b 10 80       	push   $0x80109b6a
80108baf:	e8 64 78 ff ff       	call   80100418 <cprintf>
80108bb4:	83 c4 10             	add    $0x10,%esp
  //the given pointer is a virtual address in this pid's userspace
  struct proc * p = myproc();
80108bb7:	e8 44 b9 ff ff       	call   80104500 <myproc>
80108bbc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  pde_t* mypd = p->pgdir;
80108bbf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108bc2:	8b 40 04             	mov    0x4(%eax),%eax
80108bc5:	89 45 e0             	mov    %eax,-0x20(%ebp)

  virtual_addr = (char *)PGROUNDDOWN((uint)virtual_addr);
80108bc8:	8b 45 08             	mov    0x8(%ebp),%eax
80108bcb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108bd0:	89 45 08             	mov    %eax,0x8(%ebp)

  //error checking first. all or nothing.
  char * slider = virtual_addr;
80108bd3:	8b 45 08             	mov    0x8(%ebp),%eax
80108bd6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int i = 0; i < len; i++) { 
80108bd9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108be0:	eb 55                	jmp    80108c37 <mencrypt+0xb0>
    //check page table for each translation first
    char * kvp = uva2ka(mypd, slider);
80108be2:	83 ec 08             	sub    $0x8,%esp
80108be5:	ff 75 f4             	pushl  -0xc(%ebp)
80108be8:	ff 75 e0             	pushl  -0x20(%ebp)
80108beb:	e8 28 fc ff ff       	call   80108818 <uva2ka>
80108bf0:	83 c4 10             	add    $0x10,%esp
80108bf3:	89 45 d0             	mov    %eax,-0x30(%ebp)
    cprintf("p4Debug: slider %p, kvp for err check is %p\n",slider, kvp);
80108bf6:	83 ec 04             	sub    $0x4,%esp
80108bf9:	ff 75 d0             	pushl  -0x30(%ebp)
80108bfc:	ff 75 f4             	pushl  -0xc(%ebp)
80108bff:	68 88 9b 10 80       	push   $0x80109b88
80108c04:	e8 0f 78 ff ff       	call   80100418 <cprintf>
80108c09:	83 c4 10             	add    $0x10,%esp
    if (!kvp) {
80108c0c:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
80108c10:	75 1a                	jne    80108c2c <mencrypt+0xa5>
      cprintf("p4Debug: mencrypt: kvp = NULL\n");
80108c12:	83 ec 0c             	sub    $0xc,%esp
80108c15:	68 b8 9b 10 80       	push   $0x80109bb8
80108c1a:	e8 f9 77 ff ff       	call   80100418 <cprintf>
80108c1f:	83 c4 10             	add    $0x10,%esp
      return -1;
80108c22:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c27:	e9 4e 01 00 00       	jmp    80108d7a <mencrypt+0x1f3>
    }
    slider = slider + PGSIZE;
80108c2c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  for (int i = 0; i < len; i++) { 
80108c33:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108c37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c3a:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108c3d:	7c a3                	jl     80108be2 <mencrypt+0x5b>
  }
  //encrypt stage. Have to do this before setting flag 
  //or else we'll page fault
  slider = virtual_addr;
80108c3f:	8b 45 08             	mov    0x8(%ebp),%eax
80108c42:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int i = 0; i < len; i++) {
80108c45:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108c4c:	e9 07 01 00 00       	jmp    80108d58 <mencrypt+0x1d1>
    cprintf("p4Debug: mencryptr: VPN %d, %p\n", PPN(slider), slider);
80108c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c54:	c1 e8 0c             	shr    $0xc,%eax
80108c57:	83 ec 04             	sub    $0x4,%esp
80108c5a:	ff 75 f4             	pushl  -0xc(%ebp)
80108c5d:	50                   	push   %eax
80108c5e:	68 d8 9b 10 80       	push   $0x80109bd8
80108c63:	e8 b0 77 ff ff       	call   80100418 <cprintf>
80108c68:	83 c4 10             	add    $0x10,%esp
    //kvp = kernel virtual pointer
    //virtual address in kernel space that maps to the given pointer
    char * kvp = uva2ka(mypd, slider);
80108c6b:	83 ec 08             	sub    $0x8,%esp
80108c6e:	ff 75 f4             	pushl  -0xc(%ebp)
80108c71:	ff 75 e0             	pushl  -0x20(%ebp)
80108c74:	e8 9f fb ff ff       	call   80108818 <uva2ka>
80108c79:	83 c4 10             	add    $0x10,%esp
80108c7c:	89 45 dc             	mov    %eax,-0x24(%ebp)
    cprintf("p4Debug: kvp for encrypt stage is %p\n", kvp);
80108c7f:	83 ec 08             	sub    $0x8,%esp
80108c82:	ff 75 dc             	pushl  -0x24(%ebp)
80108c85:	68 f8 9b 10 80       	push   $0x80109bf8
80108c8a:	e8 89 77 ff ff       	call   80100418 <cprintf>
80108c8f:	83 c4 10             	add    $0x10,%esp
    pte_t * mypte = walkpgdir(mypd, slider, 0);
80108c92:	83 ec 04             	sub    $0x4,%esp
80108c95:	6a 00                	push   $0x0
80108c97:	ff 75 f4             	pushl  -0xc(%ebp)
80108c9a:	ff 75 e0             	pushl  -0x20(%ebp)
80108c9d:	e8 92 f2 ff ff       	call   80107f34 <walkpgdir>
80108ca2:	83 c4 10             	add    $0x10,%esp
80108ca5:	89 45 d8             	mov    %eax,-0x28(%ebp)
    cprintf("p4Debug: pte is %x\n", *mypte);
80108ca8:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108cab:	8b 00                	mov    (%eax),%eax
80108cad:	83 ec 08             	sub    $0x8,%esp
80108cb0:	50                   	push   %eax
80108cb1:	68 03 9b 10 80       	push   $0x80109b03
80108cb6:	e8 5d 77 ff ff       	call   80100418 <cprintf>
80108cbb:	83 c4 10             	add    $0x10,%esp
    if (*mypte & PTE_E) {
80108cbe:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108cc1:	8b 00                	mov    (%eax),%eax
80108cc3:	25 00 04 00 00       	and    $0x400,%eax
80108cc8:	85 c0                	test   %eax,%eax
80108cca:	74 19                	je     80108ce5 <mencrypt+0x15e>
      cprintf("p4Debug: already encrypted\n");
80108ccc:	83 ec 0c             	sub    $0xc,%esp
80108ccf:	68 1e 9c 10 80       	push   $0x80109c1e
80108cd4:	e8 3f 77 ff ff       	call   80100418 <cprintf>
80108cd9:	83 c4 10             	add    $0x10,%esp
      slider += PGSIZE;
80108cdc:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
      continue;
80108ce3:	eb 6f                	jmp    80108d54 <mencrypt+0x1cd>
    }
    //change reference bit 
    
    for (int offset = 0; offset < PGSIZE; offset++) {
80108ce5:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
80108cec:	eb 17                	jmp    80108d05 <mencrypt+0x17e>
      *slider = *slider ^ 0xFF;
80108cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cf1:	0f b6 00             	movzbl (%eax),%eax
80108cf4:	f7 d0                	not    %eax
80108cf6:	89 c2                	mov    %eax,%edx
80108cf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cfb:	88 10                	mov    %dl,(%eax)
      slider++;
80108cfd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    for (int offset = 0; offset < PGSIZE; offset++) {
80108d01:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
80108d05:	81 7d e8 ff 0f 00 00 	cmpl   $0xfff,-0x18(%ebp)
80108d0c:	7e e0                	jle    80108cee <mencrypt+0x167>
    }
    char * kvp_translated = translate_and_set(mypd, slider-PGSIZE);
80108d0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d11:	2d 00 10 00 00       	sub    $0x1000,%eax
80108d16:	83 ec 08             	sub    $0x8,%esp
80108d19:	50                   	push   %eax
80108d1a:	ff 75 e0             	pushl  -0x20(%ebp)
80108d1d:	e8 f1 fb ff ff       	call   80108913 <translate_and_set>
80108d22:	83 c4 10             	add    $0x10,%esp
80108d25:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    if (!kvp_translated) {
80108d28:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80108d2c:	75 17                	jne    80108d45 <mencrypt+0x1be>
      cprintf("p4Debug: translate failed!");
80108d2e:	83 ec 0c             	sub    $0xc,%esp
80108d31:	68 3a 9c 10 80       	push   $0x80109c3a
80108d36:	e8 dd 76 ff ff       	call   80100418 <cprintf>
80108d3b:	83 c4 10             	add    $0x10,%esp
      return -1;
80108d3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d43:	eb 35                	jmp    80108d7a <mencrypt+0x1f3>
    }
    *mypte = *mypte & ~PTE_A;
80108d45:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108d48:	8b 00                	mov    (%eax),%eax
80108d4a:	83 e0 df             	and    $0xffffffdf,%eax
80108d4d:	89 c2                	mov    %eax,%edx
80108d4f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108d52:	89 10                	mov    %edx,(%eax)
  for (int i = 0; i < len; i++) {
80108d54:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108d58:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d5b:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108d5e:	0f 8c ed fe ff ff    	jl     80108c51 <mencrypt+0xca>
  }
  switchuvm(myproc());
80108d64:	e8 97 b7 ff ff       	call   80104500 <myproc>
80108d69:	83 ec 0c             	sub    $0xc,%esp
80108d6c:	50                   	push   %eax
80108d6d:	e8 e9 f3 ff ff       	call   8010815b <switchuvm>
80108d72:	83 c4 10             	add    $0x10,%esp
  return 0;
80108d75:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108d7a:	c9                   	leave  
80108d7b:	c3                   	ret    

80108d7c <getpgtable>:

int getpgtable(struct pt_entry* pt_entries, int num,int wsetOnly) {
80108d7c:	f3 0f 1e fb          	endbr32 
80108d80:	55                   	push   %ebp
80108d81:	89 e5                	mov    %esp,%ebp
80108d83:	83 ec 28             	sub    $0x28,%esp

  cprintf("p4Debug: getpgtable: %p, %d\n", pt_entries, num);
80108d86:	83 ec 04             	sub    $0x4,%esp
80108d89:	ff 75 0c             	pushl  0xc(%ebp)
80108d8c:	ff 75 08             	pushl  0x8(%ebp)
80108d8f:	68 55 9c 10 80       	push   $0x80109c55
80108d94:	e8 7f 76 ff ff       	call   80100418 <cprintf>
80108d99:	83 c4 10             	add    $0x10,%esp
  

  struct proc *curproc = myproc();
80108d9c:	e8 5f b7 ff ff       	call   80104500 <myproc>
80108da1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pde_t *pgdir = curproc->pgdir;
80108da4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108da7:	8b 40 04             	mov    0x4(%eax),%eax
80108daa:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint uva = 0;
80108dad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  if (curproc->sz % PGSIZE == 0)
80108db4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108db7:	8b 00                	mov    (%eax),%eax
80108db9:	25 ff 0f 00 00       	and    $0xfff,%eax
80108dbe:	85 c0                	test   %eax,%eax
80108dc0:	75 0f                	jne    80108dd1 <getpgtable+0x55>
    uva = curproc->sz - PGSIZE;
80108dc2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108dc5:	8b 00                	mov    (%eax),%eax
80108dc7:	2d 00 10 00 00       	sub    $0x1000,%eax
80108dcc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108dcf:	eb 0d                	jmp    80108dde <getpgtable+0x62>
  else 
    uva = PGROUNDDOWN(curproc->sz);
80108dd1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108dd4:	8b 00                	mov    (%eax),%eax
80108dd6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ddb:	89 45 f4             	mov    %eax,-0xc(%ebp)

  int i = 0;
80108dde:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for (;;uva -=PGSIZE)
  {
    
    pte_t *pte = walkpgdir(pgdir, (const void *)uva, 0);
80108de5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108de8:	83 ec 04             	sub    $0x4,%esp
80108deb:	6a 00                	push   $0x0
80108ded:	50                   	push   %eax
80108dee:	ff 75 e8             	pushl  -0x18(%ebp)
80108df1:	e8 3e f1 ff ff       	call   80107f34 <walkpgdir>
80108df6:	83 c4 10             	add    $0x10,%esp
80108df9:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    // if (wsetOnly) {
    //   continue;
    // }

    if (wsetOnly &&  notinq((char*)P2V(PTE_ADDR(*pte)))) {
80108dfc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108e00:	74 3a                	je     80108e3c <getpgtable+0xc0>
80108e02:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108e05:	8b 00                	mov    (%eax),%eax
80108e07:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108e0c:	05 00 00 00 80       	add    $0x80000000,%eax
80108e11:	83 ec 0c             	sub    $0xc,%esp
80108e14:	50                   	push   %eax
80108e15:	e8 8d 03 00 00       	call   801091a7 <notinq>
80108e1a:	83 c4 10             	add    $0x10,%esp
80108e1d:	85 c0                	test   %eax,%eax
80108e1f:	74 1b                	je     80108e3c <getpgtable+0xc0>
      if (uva == 0 || i == num) break;
80108e21:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108e25:	0f 84 bf 01 00 00    	je     80108fea <getpgtable+0x26e>
80108e2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e2e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108e31:	0f 84 b3 01 00 00    	je     80108fea <getpgtable+0x26e>
      continue;
80108e37:	e9 a2 01 00 00       	jmp    80108fde <getpgtable+0x262>
    }
    //cprintf("is this a freaking infinite loop??????\n");

    if (!(*pte & PTE_U) || !(*pte & (PTE_P | PTE_E)))
80108e3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108e3f:	8b 00                	mov    (%eax),%eax
80108e41:	83 e0 04             	and    $0x4,%eax
80108e44:	85 c0                	test   %eax,%eax
80108e46:	0f 84 91 01 00 00    	je     80108fdd <getpgtable+0x261>
80108e4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108e4f:	8b 00                	mov    (%eax),%eax
80108e51:	25 01 04 00 00       	and    $0x401,%eax
80108e56:	85 c0                	test   %eax,%eax
80108e58:	0f 84 7f 01 00 00    	je     80108fdd <getpgtable+0x261>
      continue;

    
    

    pt_entries[i].pdx = PDX(uva);
80108e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e61:	c1 e8 16             	shr    $0x16,%eax
80108e64:	89 c1                	mov    %eax,%ecx
80108e66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e69:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80108e70:	8b 45 08             	mov    0x8(%ebp),%eax
80108e73:	01 c2                	add    %eax,%edx
80108e75:	89 c8                	mov    %ecx,%eax
80108e77:	66 25 ff 03          	and    $0x3ff,%ax
80108e7b:	66 25 ff 03          	and    $0x3ff,%ax
80108e7f:	89 c1                	mov    %eax,%ecx
80108e81:	0f b7 02             	movzwl (%edx),%eax
80108e84:	66 25 00 fc          	and    $0xfc00,%ax
80108e88:	09 c8                	or     %ecx,%eax
80108e8a:	66 89 02             	mov    %ax,(%edx)
    pt_entries[i].ptx = PTX(uva);
80108e8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e90:	c1 e8 0c             	shr    $0xc,%eax
80108e93:	89 c1                	mov    %eax,%ecx
80108e95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e98:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80108e9f:	8b 45 08             	mov    0x8(%ebp),%eax
80108ea2:	01 c2                	add    %eax,%edx
80108ea4:	89 c8                	mov    %ecx,%eax
80108ea6:	66 25 ff 03          	and    $0x3ff,%ax
80108eaa:	0f b7 c0             	movzwl %ax,%eax
80108ead:	25 ff 03 00 00       	and    $0x3ff,%eax
80108eb2:	c1 e0 0a             	shl    $0xa,%eax
80108eb5:	89 c1                	mov    %eax,%ecx
80108eb7:	8b 02                	mov    (%edx),%eax
80108eb9:	25 ff 03 f0 ff       	and    $0xfff003ff,%eax
80108ebe:	09 c8                	or     %ecx,%eax
80108ec0:	89 02                	mov    %eax,(%edx)
    pt_entries[i].ppage = *pte >> PTXSHIFT;
80108ec2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108ec5:	8b 00                	mov    (%eax),%eax
80108ec7:	c1 e8 0c             	shr    $0xc,%eax
80108eca:	89 c2                	mov    %eax,%edx
80108ecc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ecf:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80108ed6:	8b 45 08             	mov    0x8(%ebp),%eax
80108ed9:	01 c8                	add    %ecx,%eax
80108edb:	81 e2 ff ff 0f 00    	and    $0xfffff,%edx
80108ee1:	89 d1                	mov    %edx,%ecx
80108ee3:	81 e1 ff ff 0f 00    	and    $0xfffff,%ecx
80108ee9:	8b 50 04             	mov    0x4(%eax),%edx
80108eec:	81 e2 00 00 f0 ff    	and    $0xfff00000,%edx
80108ef2:	09 ca                	or     %ecx,%edx
80108ef4:	89 50 04             	mov    %edx,0x4(%eax)
    pt_entries[i].present = *pte & PTE_P;
80108ef7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108efa:	8b 08                	mov    (%eax),%ecx
80108efc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108eff:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80108f06:	8b 45 08             	mov    0x8(%ebp),%eax
80108f09:	01 c2                	add    %eax,%edx
80108f0b:	89 c8                	mov    %ecx,%eax
80108f0d:	83 e0 01             	and    $0x1,%eax
80108f10:	83 e0 01             	and    $0x1,%eax
80108f13:	c1 e0 04             	shl    $0x4,%eax
80108f16:	89 c1                	mov    %eax,%ecx
80108f18:	0f b6 42 06          	movzbl 0x6(%edx),%eax
80108f1c:	83 e0 ef             	and    $0xffffffef,%eax
80108f1f:	09 c8                	or     %ecx,%eax
80108f21:	88 42 06             	mov    %al,0x6(%edx)
    pt_entries[i].writable = (*pte & PTE_W) > 0;
80108f24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108f27:	8b 00                	mov    (%eax),%eax
80108f29:	83 e0 02             	and    $0x2,%eax
80108f2c:	89 c2                	mov    %eax,%edx
80108f2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f31:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80108f38:	8b 45 08             	mov    0x8(%ebp),%eax
80108f3b:	01 c8                	add    %ecx,%eax
80108f3d:	85 d2                	test   %edx,%edx
80108f3f:	0f 95 c2             	setne  %dl
80108f42:	83 e2 01             	and    $0x1,%edx
80108f45:	89 d1                	mov    %edx,%ecx
80108f47:	c1 e1 05             	shl    $0x5,%ecx
80108f4a:	0f b6 50 06          	movzbl 0x6(%eax),%edx
80108f4e:	83 e2 df             	and    $0xffffffdf,%edx
80108f51:	09 ca                	or     %ecx,%edx
80108f53:	88 50 06             	mov    %dl,0x6(%eax)
    pt_entries[i].encrypted = (*pte & PTE_E) > 0;
80108f56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108f59:	8b 00                	mov    (%eax),%eax
80108f5b:	25 00 04 00 00       	and    $0x400,%eax
80108f60:	89 c2                	mov    %eax,%edx
80108f62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f65:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80108f6c:	8b 45 08             	mov    0x8(%ebp),%eax
80108f6f:	01 c8                	add    %ecx,%eax
80108f71:	85 d2                	test   %edx,%edx
80108f73:	0f 95 c2             	setne  %dl
80108f76:	89 d1                	mov    %edx,%ecx
80108f78:	c1 e1 07             	shl    $0x7,%ecx
80108f7b:	0f b6 50 06          	movzbl 0x6(%eax),%edx
80108f7f:	83 e2 7f             	and    $0x7f,%edx
80108f82:	09 ca                	or     %ecx,%edx
80108f84:	88 50 06             	mov    %dl,0x6(%eax)
    pt_entries[i].ref = (*pte & PTE_A) > 0;
80108f87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108f8a:	8b 00                	mov    (%eax),%eax
80108f8c:	83 e0 20             	and    $0x20,%eax
80108f8f:	89 c2                	mov    %eax,%edx
80108f91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f94:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80108f9b:	8b 45 08             	mov    0x8(%ebp),%eax
80108f9e:	01 c8                	add    %ecx,%eax
80108fa0:	85 d2                	test   %edx,%edx
80108fa2:	0f 95 c2             	setne  %dl
80108fa5:	89 d1                	mov    %edx,%ecx
80108fa7:	83 e1 01             	and    $0x1,%ecx
80108faa:	0f b6 50 07          	movzbl 0x7(%eax),%edx
80108fae:	83 e2 fe             	and    $0xfffffffe,%edx
80108fb1:	09 ca                	or     %ecx,%edx
80108fb3:	88 50 07             	mov    %dl,0x7(%eax)
    //PT_A flag needs to be modified as per clock algo.
    i ++;
80108fb6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    cprintf("i is :%d\n",uva);
80108fba:	83 ec 08             	sub    $0x8,%esp
80108fbd:	ff 75 f4             	pushl  -0xc(%ebp)
80108fc0:	68 72 9c 10 80       	push   $0x80109c72
80108fc5:	e8 4e 74 ff ff       	call   80100418 <cprintf>
80108fca:	83 c4 10             	add    $0x10,%esp

    if (uva == 0 || i == num) break;
80108fcd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108fd1:	74 17                	je     80108fea <getpgtable+0x26e>
80108fd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fd6:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108fd9:	74 0f                	je     80108fea <getpgtable+0x26e>
80108fdb:	eb 01                	jmp    80108fde <getpgtable+0x262>
      continue;
80108fdd:	90                   	nop
  for (;;uva -=PGSIZE)
80108fde:	81 6d f4 00 10 00 00 	subl   $0x1000,-0xc(%ebp)
  {
80108fe5:	e9 fb fd ff ff       	jmp    80108de5 <getpgtable+0x69>
    // if (uva < 0 || i == num) break;

  }

  return i;
80108fea:	8b 45 f0             	mov    -0x10(%ebp),%eax

}
80108fed:	c9                   	leave  
80108fee:	c3                   	ret    

80108fef <dump_rawphymem>:


int dump_rawphymem(char *physical_addr, char * buffer) {
80108fef:	f3 0f 1e fb          	endbr32 
80108ff3:	55                   	push   %ebp
80108ff4:	89 e5                	mov    %esp,%ebp
80108ff6:	56                   	push   %esi
80108ff7:	53                   	push   %ebx
80108ff8:	83 ec 10             	sub    $0x10,%esp
  
  *buffer = *buffer;
80108ffb:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ffe:	0f b6 10             	movzbl (%eax),%edx
80109001:	8b 45 0c             	mov    0xc(%ebp),%eax
80109004:	88 10                	mov    %dl,(%eax)
  cprintf("p4Debug: dump_rawphymem: %p, %p\n", physical_addr, buffer);
80109006:	83 ec 04             	sub    $0x4,%esp
80109009:	ff 75 0c             	pushl  0xc(%ebp)
8010900c:	ff 75 08             	pushl  0x8(%ebp)
8010900f:	68 7c 9c 10 80       	push   $0x80109c7c
80109014:	e8 ff 73 ff ff       	call   80100418 <cprintf>
80109019:	83 c4 10             	add    $0x10,%esp
  int retval = copyout(myproc()->pgdir, (uint) buffer, (void *) PGROUNDDOWN((int)P2V(physical_addr)), PGSIZE);
8010901c:	8b 45 08             	mov    0x8(%ebp),%eax
8010901f:	05 00 00 00 80       	add    $0x80000000,%eax
80109024:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109029:	89 c6                	mov    %eax,%esi
8010902b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
8010902e:	e8 cd b4 ff ff       	call   80104500 <myproc>
80109033:	8b 40 04             	mov    0x4(%eax),%eax
80109036:	68 00 10 00 00       	push   $0x1000
8010903b:	56                   	push   %esi
8010903c:	53                   	push   %ebx
8010903d:	50                   	push   %eax
8010903e:	e8 2e f8 ff ff       	call   80108871 <copyout>
80109043:	83 c4 10             	add    $0x10,%esp
80109046:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (retval)
80109049:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010904d:	74 07                	je     80109056 <dump_rawphymem+0x67>
    return -1;
8010904f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109054:	eb 05                	jmp    8010905b <dump_rawphymem+0x6c>
  return 0;
80109056:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010905b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010905e:	5b                   	pop    %ebx
8010905f:	5e                   	pop    %esi
80109060:	5d                   	pop    %ebp
80109061:	c3                   	ret    

80109062 <clock_add>:

//add clock algo here 
void clock_add(char *virtual_address){
80109062:	f3 0f 1e fb          	endbr32 
80109066:	55                   	push   %ebp
80109067:	89 e5                	mov    %esp,%ebp
80109069:	83 ec 28             	sub    $0x28,%esp
  cprintf("addd tooo cloockk is called \n");
8010906c:	83 ec 0c             	sub    $0xc,%esp
8010906f:	68 9d 9c 10 80       	push   $0x80109c9d
80109074:	e8 9f 73 ff ff       	call   80100418 <cprintf>
80109079:	83 c4 10             	add    $0x10,%esp
  struct proc *curproc = myproc();
8010907c:	e8 7f b4 ff ff       	call   80104500 <myproc>
80109081:	89 45 ec             	mov    %eax,-0x14(%ebp)
  // char* pages[] = curproc->pages;

  if(curproc->cl_len < CLOCKSIZE){
80109084:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109087:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
8010908d:	83 f8 07             	cmp    $0x7,%eax
80109090:	7f 30                	jg     801090c2 <clock_add+0x60>
    curproc->pages[curproc->cl_len] = virtual_address;
80109092:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109095:	8b 90 a0 00 00 00    	mov    0xa0(%eax),%edx
8010909b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010909e:	8d 4a 1c             	lea    0x1c(%edx),%ecx
801090a1:	8b 55 08             	mov    0x8(%ebp),%edx
801090a4:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    curproc->cl_len = curproc->cl_len + 1;
801090a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090ab:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801090b1:	8d 50 01             	lea    0x1(%eax),%edx
801090b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090b7:	89 90 a0 00 00 00    	mov    %edx,0xa0(%eax)
      curproc->clock_hand = curproc->clock_hand+1;
      cur_va = curproc->pages[(curproc->clock_hand)%CLOCKSIZE];
    }
  }
  }
}
801090bd:	e9 e2 00 00 00       	jmp    801091a4 <clock_add+0x142>
  char* cur_va = curproc->pages[curproc->clock_hand];
801090c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090c5:	8b 90 9c 00 00 00    	mov    0x9c(%eax),%edx
801090cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090ce:	83 c2 1c             	add    $0x1c,%edx
801090d1:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
801090d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pde_t* mypd = curproc->pgdir;
801090d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090db:	8b 40 04             	mov    0x4(%eax),%eax
801090de:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int found =0;
801090e1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  while(!found){
801090e8:	e9 ad 00 00 00       	jmp    8010919a <clock_add+0x138>
    pte_t * pte = walkpgdir(mypd, cur_va, 0);
801090ed:	83 ec 04             	sub    $0x4,%esp
801090f0:	6a 00                	push   $0x0
801090f2:	ff 75 f4             	pushl  -0xc(%ebp)
801090f5:	ff 75 e8             	pushl  -0x18(%ebp)
801090f8:	e8 37 ee ff ff       	call   80107f34 <walkpgdir>
801090fd:	83 c4 10             	add    $0x10,%esp
80109100:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(!(*pte & PTE_A)){
80109103:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109106:	8b 00                	mov    (%eax),%eax
80109108:	83 e0 20             	and    $0x20,%eax
8010910b:	85 c0                	test   %eax,%eax
8010910d:	75 44                	jne    80109153 <clock_add+0xf1>
      curproc->pages[curproc->clock_hand] = virtual_address;
8010910f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109112:	8b 90 9c 00 00 00    	mov    0x9c(%eax),%edx
80109118:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010911b:	8d 4a 1c             	lea    0x1c(%edx),%ecx
8010911e:	8b 55 08             	mov    0x8(%ebp),%edx
80109121:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
      mencrypt(cur_va,1);
80109125:	83 ec 08             	sub    $0x8,%esp
80109128:	6a 01                	push   $0x1
8010912a:	ff 75 f4             	pushl  -0xc(%ebp)
8010912d:	e8 55 fa ff ff       	call   80108b87 <mencrypt>
80109132:	83 c4 10             	add    $0x10,%esp
      curproc->clock_hand = curproc->clock_hand+1;
80109135:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109138:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
8010913e:	8d 50 01             	lea    0x1(%eax),%edx
80109141:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109144:	89 90 9c 00 00 00    	mov    %edx,0x9c(%eax)
      found =1;
8010914a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
80109151:	eb 47                	jmp    8010919a <clock_add+0x138>
      *pte = *pte & ~PTE_A;
80109153:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109156:	8b 00                	mov    (%eax),%eax
80109158:	83 e0 df             	and    $0xffffffdf,%eax
8010915b:	89 c2                	mov    %eax,%edx
8010915d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109160:	89 10                	mov    %edx,(%eax)
      curproc->clock_hand = curproc->clock_hand+1;
80109162:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109165:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
8010916b:	8d 50 01             	lea    0x1(%eax),%edx
8010916e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109171:	89 90 9c 00 00 00    	mov    %edx,0x9c(%eax)
      cur_va = curproc->pages[(curproc->clock_hand)%CLOCKSIZE];
80109177:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010917a:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80109180:	99                   	cltd   
80109181:	c1 ea 1d             	shr    $0x1d,%edx
80109184:	01 d0                	add    %edx,%eax
80109186:	83 e0 07             	and    $0x7,%eax
80109189:	29 d0                	sub    %edx,%eax
8010918b:	89 c2                	mov    %eax,%edx
8010918d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109190:	83 c2 1c             	add    $0x1c,%edx
80109193:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80109197:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(!found){
8010919a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010919e:	0f 84 49 ff ff ff    	je     801090ed <clock_add+0x8b>
}
801091a4:	90                   	nop
801091a5:	c9                   	leave  
801091a6:	c3                   	ret    

801091a7 <notinq>:


int notinq(char *virtual_address){
801091a7:	f3 0f 1e fb          	endbr32 
801091ab:	55                   	push   %ebp
801091ac:	89 e5                	mov    %esp,%ebp
801091ae:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801091b1:	e8 4a b3 ff ff       	call   80104500 <myproc>
801091b6:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(int i=0; i < curproc->cl_len;i++){
801091b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801091c0:	eb 1d                	jmp    801091df <notinq+0x38>
    if(virtual_address == curproc->pages[i]){
801091c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801091c8:	83 c2 1c             	add    $0x1c,%edx
801091cb:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
801091cf:	39 45 08             	cmp    %eax,0x8(%ebp)
801091d2:	75 07                	jne    801091db <notinq+0x34>
      return 0;
801091d4:	b8 00 00 00 00       	mov    $0x0,%eax
801091d9:	eb 17                	jmp    801091f2 <notinq+0x4b>
  for(int i=0; i < curproc->cl_len;i++){
801091db:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801091df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091e2:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801091e8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801091eb:	7c d5                	jl     801091c2 <notinq+0x1b>
    }
  }

  //cprintf("return ======\n");
  return 1;
801091ed:	b8 01 00 00 00       	mov    $0x1,%eax
  //   if(pte == &clock->pages[i]){
  //     return 0;
  //   }
  // }
  // return 1;
}
801091f2:	c9                   	leave  
801091f3:	c3                   	ret    
