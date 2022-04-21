
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 10 12 00       	mov    $0x121000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 10 12 f0       	mov    $0xf0121000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 62 00 00 00       	call   f01000a0 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	f3 0f 1e fb          	endbr32 
f0100044:	55                   	push   %ebp
f0100045:	89 e5                	mov    %esp,%ebp
f0100047:	56                   	push   %esi
f0100048:	53                   	push   %ebx
f0100049:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010004c:	83 3d 80 be 3b f0 00 	cmpl   $0x0,0xf03bbe80
f0100053:	74 0f                	je     f0100064 <_panic+0x24>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100055:	83 ec 0c             	sub    $0xc,%esp
f0100058:	6a 00                	push   $0x0
f010005a:	e8 7d 09 00 00       	call   f01009dc <monitor>
f010005f:	83 c4 10             	add    $0x10,%esp
f0100062:	eb f1                	jmp    f0100055 <_panic+0x15>
	panicstr = fmt;
f0100064:	89 35 80 be 3b f0    	mov    %esi,0xf03bbe80
	asm volatile("cli; cld");
f010006a:	fa                   	cli    
f010006b:	fc                   	cld    
	va_start(ap, fmt);
f010006c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010006f:	e8 16 63 00 00       	call   f010638a <cpunum>
f0100074:	ff 75 0c             	pushl  0xc(%ebp)
f0100077:	ff 75 08             	pushl  0x8(%ebp)
f010007a:	50                   	push   %eax
f010007b:	68 00 6a 10 f0       	push   $0xf0106a00
f0100080:	e8 a8 3a 00 00       	call   f0103b2d <cprintf>
	vcprintf(fmt, ap);
f0100085:	83 c4 08             	add    $0x8,%esp
f0100088:	53                   	push   %ebx
f0100089:	56                   	push   %esi
f010008a:	e8 74 3a 00 00       	call   f0103b03 <vcprintf>
	cprintf("\n");
f010008f:	c7 04 24 e0 7b 10 f0 	movl   $0xf0107be0,(%esp)
f0100096:	e8 92 3a 00 00       	call   f0103b2d <cprintf>
f010009b:	83 c4 10             	add    $0x10,%esp
f010009e:	eb b5                	jmp    f0100055 <_panic+0x15>

f01000a0 <i386_init>:
{
f01000a0:	f3 0f 1e fb          	endbr32 
f01000a4:	55                   	push   %ebp
f01000a5:	89 e5                	mov    %esp,%ebp
f01000a7:	53                   	push   %ebx
f01000a8:	83 ec 04             	sub    $0x4,%esp
	cons_init();
f01000ab:	e8 a9 05 00 00       	call   f0100659 <cons_init>
	cprintf("444544 decimal is %o octal!\n", 444544);
f01000b0:	83 ec 08             	sub    $0x8,%esp
f01000b3:	68 80 c8 06 00       	push   $0x6c880
f01000b8:	68 6c 6a 10 f0       	push   $0xf0106a6c
f01000bd:	e8 6b 3a 00 00       	call   f0103b2d <cprintf>
	mem_init();
f01000c2:	e8 da 12 00 00       	call   f01013a1 <mem_init>
	env_init();
f01000c7:	e8 fa 31 00 00       	call   f01032c6 <env_init>
	trap_init();
f01000cc:	e8 56 3b 00 00       	call   f0103c27 <trap_init>
	mp_init();
f01000d1:	e8 b5 5f 00 00       	call   f010608b <mp_init>
	lapic_init();
f01000d6:	e8 c9 62 00 00       	call   f01063a4 <lapic_init>
	pic_init();
f01000db:	e8 62 39 00 00       	call   f0103a42 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000e0:	c7 04 24 c0 33 12 f0 	movl   $0xf01233c0,(%esp)
f01000e7:	e8 26 65 00 00       	call   f0106612 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000ec:	83 c4 10             	add    $0x10,%esp
f01000ef:	83 3d 88 be 3b f0 07 	cmpl   $0x7,0xf03bbe88
f01000f6:	76 27                	jbe    f010011f <i386_init+0x7f>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01000f8:	83 ec 04             	sub    $0x4,%esp
f01000fb:	b8 ee 5f 10 f0       	mov    $0xf0105fee,%eax
f0100100:	2d 74 5f 10 f0       	sub    $0xf0105f74,%eax
f0100105:	50                   	push   %eax
f0100106:	68 74 5f 10 f0       	push   $0xf0105f74
f010010b:	68 00 70 00 f0       	push   $0xf0007000
f0100110:	e8 a3 5c 00 00       	call   f0105db8 <memmove>
	for (c = cpus; c < cpus + ncpu; c++) {
f0100115:	83 c4 10             	add    $0x10,%esp
f0100118:	bb 20 c0 3b f0       	mov    $0xf03bc020,%ebx
f010011d:	eb 53                	jmp    f0100172 <i386_init+0xd2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010011f:	68 00 70 00 00       	push   $0x7000
f0100124:	68 24 6a 10 f0       	push   $0xf0106a24
f0100129:	6a 53                	push   $0x53
f010012b:	68 89 6a 10 f0       	push   $0xf0106a89
f0100130:	e8 0b ff ff ff       	call   f0100040 <_panic>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100135:	89 d8                	mov    %ebx,%eax
f0100137:	2d 20 c0 3b f0       	sub    $0xf03bc020,%eax
f010013c:	c1 f8 02             	sar    $0x2,%eax
f010013f:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100145:	c1 e0 0f             	shl    $0xf,%eax
f0100148:	8d 80 00 50 3c f0    	lea    -0xfc3b000(%eax),%eax
f010014e:	a3 84 be 3b f0       	mov    %eax,0xf03bbe84
		lapic_startap(c->cpu_id, PADDR(code));
f0100153:	83 ec 08             	sub    $0x8,%esp
f0100156:	68 00 70 00 00       	push   $0x7000
f010015b:	0f b6 03             	movzbl (%ebx),%eax
f010015e:	50                   	push   %eax
f010015f:	e8 9a 63 00 00       	call   f01064fe <lapic_startap>
		while(c->cpu_status != CPU_STARTED)
f0100164:	83 c4 10             	add    $0x10,%esp
f0100167:	8b 43 04             	mov    0x4(%ebx),%eax
f010016a:	83 f8 01             	cmp    $0x1,%eax
f010016d:	75 f8                	jne    f0100167 <i386_init+0xc7>
	for (c = cpus; c < cpus + ncpu; c++) {
f010016f:	83 c3 74             	add    $0x74,%ebx
f0100172:	6b 05 c4 c3 3b f0 74 	imul   $0x74,0xf03bc3c4,%eax
f0100179:	05 20 c0 3b f0       	add    $0xf03bc020,%eax
f010017e:	39 c3                	cmp    %eax,%ebx
f0100180:	73 13                	jae    f0100195 <i386_init+0xf5>
		if (c == cpus + cpunum())  // We've started already.
f0100182:	e8 03 62 00 00       	call   f010638a <cpunum>
f0100187:	6b c0 74             	imul   $0x74,%eax,%eax
f010018a:	05 20 c0 3b f0       	add    $0xf03bc020,%eax
f010018f:	39 c3                	cmp    %eax,%ebx
f0100191:	74 dc                	je     f010016f <i386_init+0xcf>
f0100193:	eb a0                	jmp    f0100135 <i386_init+0x95>
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f0100195:	83 ec 08             	sub    $0x8,%esp
f0100198:	6a 01                	push   $0x1
f010019a:	68 00 80 32 f0       	push   $0xf0328000
f010019f:	e8 1b 33 00 00       	call   f01034bf <env_create>
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001a4:	83 c4 08             	add    $0x8,%esp
f01001a7:	6a 00                	push   $0x0
f01001a9:	68 d4 b2 38 f0       	push   $0xf038b2d4
f01001ae:	e8 0c 33 00 00       	call   f01034bf <env_create>
	kbd_intr();
f01001b3:	e8 45 04 00 00       	call   f01005fd <kbd_intr>
	sched_yield();
f01001b8:	e8 2d 48 00 00       	call   f01049ea <sched_yield>

f01001bd <mp_main>:
{
f01001bd:	f3 0f 1e fb          	endbr32 
f01001c1:	55                   	push   %ebp
f01001c2:	89 e5                	mov    %esp,%ebp
f01001c4:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f01001c7:	a1 8c be 3b f0       	mov    0xf03bbe8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01001cc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001d1:	76 52                	jbe    f0100225 <mp_main+0x68>
	return (physaddr_t)kva - KERNBASE;
f01001d3:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001d8:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001db:	e8 aa 61 00 00       	call   f010638a <cpunum>
f01001e0:	83 ec 08             	sub    $0x8,%esp
f01001e3:	50                   	push   %eax
f01001e4:	68 95 6a 10 f0       	push   $0xf0106a95
f01001e9:	e8 3f 39 00 00       	call   f0103b2d <cprintf>
	lapic_init();
f01001ee:	e8 b1 61 00 00       	call   f01063a4 <lapic_init>
	env_init_percpu();
f01001f3:	e8 9e 30 00 00       	call   f0103296 <env_init_percpu>
	trap_init_percpu();
f01001f8:	e8 48 39 00 00       	call   f0103b45 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01001fd:	e8 88 61 00 00       	call   f010638a <cpunum>
f0100202:	6b d0 74             	imul   $0x74,%eax,%edx
f0100205:	83 c2 04             	add    $0x4,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100208:	b8 01 00 00 00       	mov    $0x1,%eax
f010020d:	f0 87 82 20 c0 3b f0 	lock xchg %eax,-0xfc43fe0(%edx)
f0100214:	c7 04 24 c0 33 12 f0 	movl   $0xf01233c0,(%esp)
f010021b:	e8 f2 63 00 00       	call   f0106612 <spin_lock>
    sched_yield();
f0100220:	e8 c5 47 00 00       	call   f01049ea <sched_yield>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100225:	50                   	push   %eax
f0100226:	68 48 6a 10 f0       	push   $0xf0106a48
f010022b:	6a 6a                	push   $0x6a
f010022d:	68 89 6a 10 f0       	push   $0xf0106a89
f0100232:	e8 09 fe ff ff       	call   f0100040 <_panic>

f0100237 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100237:	f3 0f 1e fb          	endbr32 
f010023b:	55                   	push   %ebp
f010023c:	89 e5                	mov    %esp,%ebp
f010023e:	53                   	push   %ebx
f010023f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100242:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100245:	ff 75 0c             	pushl  0xc(%ebp)
f0100248:	ff 75 08             	pushl  0x8(%ebp)
f010024b:	68 ab 6a 10 f0       	push   $0xf0106aab
f0100250:	e8 d8 38 00 00       	call   f0103b2d <cprintf>
	vcprintf(fmt, ap);
f0100255:	83 c4 08             	add    $0x8,%esp
f0100258:	53                   	push   %ebx
f0100259:	ff 75 10             	pushl  0x10(%ebp)
f010025c:	e8 a2 38 00 00       	call   f0103b03 <vcprintf>
	cprintf("\n");
f0100261:	c7 04 24 e0 7b 10 f0 	movl   $0xf0107be0,(%esp)
f0100268:	e8 c0 38 00 00       	call   f0103b2d <cprintf>
	va_end(ap);
}
f010026d:	83 c4 10             	add    $0x10,%esp
f0100270:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100273:	c9                   	leave  
f0100274:	c3                   	ret    

f0100275 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100275:	f3 0f 1e fb          	endbr32 
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100279:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010027e:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010027f:	a8 01                	test   $0x1,%al
f0100281:	74 0a                	je     f010028d <serial_proc_data+0x18>
f0100283:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100288:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100289:	0f b6 c0             	movzbl %al,%eax
f010028c:	c3                   	ret    
		return -1;
f010028d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100292:	c3                   	ret    

f0100293 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100293:	55                   	push   %ebp
f0100294:	89 e5                	mov    %esp,%ebp
f0100296:	53                   	push   %ebx
f0100297:	83 ec 04             	sub    $0x4,%esp
f010029a:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010029c:	ff d3                	call   *%ebx
f010029e:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002a1:	74 29                	je     f01002cc <cons_intr+0x39>
		if (c == 0)
f01002a3:	85 c0                	test   %eax,%eax
f01002a5:	74 f5                	je     f010029c <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f01002a7:	8b 0d 24 b2 3b f0    	mov    0xf03bb224,%ecx
f01002ad:	8d 51 01             	lea    0x1(%ecx),%edx
f01002b0:	88 81 20 b0 3b f0    	mov    %al,-0xfc44fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002b6:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f01002bc:	b8 00 00 00 00       	mov    $0x0,%eax
f01002c1:	0f 44 d0             	cmove  %eax,%edx
f01002c4:	89 15 24 b2 3b f0    	mov    %edx,0xf03bb224
f01002ca:	eb d0                	jmp    f010029c <cons_intr+0x9>
	}
}
f01002cc:	83 c4 04             	add    $0x4,%esp
f01002cf:	5b                   	pop    %ebx
f01002d0:	5d                   	pop    %ebp
f01002d1:	c3                   	ret    

f01002d2 <kbd_proc_data>:
{
f01002d2:	f3 0f 1e fb          	endbr32 
f01002d6:	55                   	push   %ebp
f01002d7:	89 e5                	mov    %esp,%ebp
f01002d9:	53                   	push   %ebx
f01002da:	83 ec 04             	sub    $0x4,%esp
f01002dd:	ba 64 00 00 00       	mov    $0x64,%edx
f01002e2:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01002e3:	a8 01                	test   $0x1,%al
f01002e5:	0f 84 f2 00 00 00    	je     f01003dd <kbd_proc_data+0x10b>
	if (stat & KBS_TERR)
f01002eb:	a8 20                	test   $0x20,%al
f01002ed:	0f 85 f1 00 00 00    	jne    f01003e4 <kbd_proc_data+0x112>
f01002f3:	ba 60 00 00 00       	mov    $0x60,%edx
f01002f8:	ec                   	in     (%dx),%al
f01002f9:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f01002fb:	3c e0                	cmp    $0xe0,%al
f01002fd:	74 61                	je     f0100360 <kbd_proc_data+0x8e>
	} else if (data & 0x80) {
f01002ff:	84 c0                	test   %al,%al
f0100301:	78 70                	js     f0100373 <kbd_proc_data+0xa1>
	} else if (shift & E0ESC) {
f0100303:	8b 0d 00 b0 3b f0    	mov    0xf03bb000,%ecx
f0100309:	f6 c1 40             	test   $0x40,%cl
f010030c:	74 0e                	je     f010031c <kbd_proc_data+0x4a>
		data |= 0x80;
f010030e:	83 c8 80             	or     $0xffffff80,%eax
f0100311:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100313:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100316:	89 0d 00 b0 3b f0    	mov    %ecx,0xf03bb000
	shift |= shiftcode[data];
f010031c:	0f b6 d2             	movzbl %dl,%edx
f010031f:	0f b6 82 20 6c 10 f0 	movzbl -0xfef93e0(%edx),%eax
f0100326:	0b 05 00 b0 3b f0    	or     0xf03bb000,%eax
	shift ^= togglecode[data];
f010032c:	0f b6 8a 20 6b 10 f0 	movzbl -0xfef94e0(%edx),%ecx
f0100333:	31 c8                	xor    %ecx,%eax
f0100335:	a3 00 b0 3b f0       	mov    %eax,0xf03bb000
	c = charcode[shift & (CTL | SHIFT)][data];
f010033a:	89 c1                	mov    %eax,%ecx
f010033c:	83 e1 03             	and    $0x3,%ecx
f010033f:	8b 0c 8d 00 6b 10 f0 	mov    -0xfef9500(,%ecx,4),%ecx
f0100346:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010034a:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f010034d:	a8 08                	test   $0x8,%al
f010034f:	74 61                	je     f01003b2 <kbd_proc_data+0xe0>
		if ('a' <= c && c <= 'z')
f0100351:	89 da                	mov    %ebx,%edx
f0100353:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100356:	83 f9 19             	cmp    $0x19,%ecx
f0100359:	77 4b                	ja     f01003a6 <kbd_proc_data+0xd4>
			c += 'A' - 'a';
f010035b:	83 eb 20             	sub    $0x20,%ebx
f010035e:	eb 0c                	jmp    f010036c <kbd_proc_data+0x9a>
		shift |= E0ESC;
f0100360:	83 0d 00 b0 3b f0 40 	orl    $0x40,0xf03bb000
		return 0;
f0100367:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f010036c:	89 d8                	mov    %ebx,%eax
f010036e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100371:	c9                   	leave  
f0100372:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100373:	8b 0d 00 b0 3b f0    	mov    0xf03bb000,%ecx
f0100379:	89 cb                	mov    %ecx,%ebx
f010037b:	83 e3 40             	and    $0x40,%ebx
f010037e:	83 e0 7f             	and    $0x7f,%eax
f0100381:	85 db                	test   %ebx,%ebx
f0100383:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100386:	0f b6 d2             	movzbl %dl,%edx
f0100389:	0f b6 82 20 6c 10 f0 	movzbl -0xfef93e0(%edx),%eax
f0100390:	83 c8 40             	or     $0x40,%eax
f0100393:	0f b6 c0             	movzbl %al,%eax
f0100396:	f7 d0                	not    %eax
f0100398:	21 c8                	and    %ecx,%eax
f010039a:	a3 00 b0 3b f0       	mov    %eax,0xf03bb000
		return 0;
f010039f:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003a4:	eb c6                	jmp    f010036c <kbd_proc_data+0x9a>
		else if ('A' <= c && c <= 'Z')
f01003a6:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003a9:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003ac:	83 fa 1a             	cmp    $0x1a,%edx
f01003af:	0f 42 d9             	cmovb  %ecx,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003b2:	f7 d0                	not    %eax
f01003b4:	a8 06                	test   $0x6,%al
f01003b6:	75 b4                	jne    f010036c <kbd_proc_data+0x9a>
f01003b8:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003be:	75 ac                	jne    f010036c <kbd_proc_data+0x9a>
		cprintf("Rebooting!\n");
f01003c0:	83 ec 0c             	sub    $0xc,%esp
f01003c3:	68 c5 6a 10 f0       	push   $0xf0106ac5
f01003c8:	e8 60 37 00 00       	call   f0103b2d <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003cd:	b8 03 00 00 00       	mov    $0x3,%eax
f01003d2:	ba 92 00 00 00       	mov    $0x92,%edx
f01003d7:	ee                   	out    %al,(%dx)
}
f01003d8:	83 c4 10             	add    $0x10,%esp
f01003db:	eb 8f                	jmp    f010036c <kbd_proc_data+0x9a>
		return -1;
f01003dd:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003e2:	eb 88                	jmp    f010036c <kbd_proc_data+0x9a>
		return -1;
f01003e4:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003e9:	eb 81                	jmp    f010036c <kbd_proc_data+0x9a>

f01003eb <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003eb:	55                   	push   %ebp
f01003ec:	89 e5                	mov    %esp,%ebp
f01003ee:	57                   	push   %edi
f01003ef:	56                   	push   %esi
f01003f0:	53                   	push   %ebx
f01003f1:	83 ec 1c             	sub    $0x1c,%esp
f01003f4:	89 c1                	mov    %eax,%ecx
	for (i = 0;
f01003f6:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003fb:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100400:	bb 84 00 00 00       	mov    $0x84,%ebx
f0100405:	89 fa                	mov    %edi,%edx
f0100407:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100408:	a8 20                	test   $0x20,%al
f010040a:	75 13                	jne    f010041f <cons_putc+0x34>
f010040c:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100412:	7f 0b                	jg     f010041f <cons_putc+0x34>
f0100414:	89 da                	mov    %ebx,%edx
f0100416:	ec                   	in     (%dx),%al
f0100417:	ec                   	in     (%dx),%al
f0100418:	ec                   	in     (%dx),%al
f0100419:	ec                   	in     (%dx),%al
	     i++)
f010041a:	83 c6 01             	add    $0x1,%esi
f010041d:	eb e6                	jmp    f0100405 <cons_putc+0x1a>
	outb(COM1 + COM_TX, c);
f010041f:	88 4d e7             	mov    %cl,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100422:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100427:	89 c8                	mov    %ecx,%eax
f0100429:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010042a:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010042f:	bf 79 03 00 00       	mov    $0x379,%edi
f0100434:	bb 84 00 00 00       	mov    $0x84,%ebx
f0100439:	89 fa                	mov    %edi,%edx
f010043b:	ec                   	in     (%dx),%al
f010043c:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100442:	7f 0f                	jg     f0100453 <cons_putc+0x68>
f0100444:	84 c0                	test   %al,%al
f0100446:	78 0b                	js     f0100453 <cons_putc+0x68>
f0100448:	89 da                	mov    %ebx,%edx
f010044a:	ec                   	in     (%dx),%al
f010044b:	ec                   	in     (%dx),%al
f010044c:	ec                   	in     (%dx),%al
f010044d:	ec                   	in     (%dx),%al
f010044e:	83 c6 01             	add    $0x1,%esi
f0100451:	eb e6                	jmp    f0100439 <cons_putc+0x4e>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100453:	ba 78 03 00 00       	mov    $0x378,%edx
f0100458:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010045c:	ee                   	out    %al,(%dx)
f010045d:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100462:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100467:	ee                   	out    %al,(%dx)
f0100468:	b8 08 00 00 00       	mov    $0x8,%eax
f010046d:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f010046e:	89 c8                	mov    %ecx,%eax
f0100470:	80 cc 07             	or     $0x7,%ah
f0100473:	f7 c1 00 ff ff ff    	test   $0xffffff00,%ecx
f0100479:	0f 44 c8             	cmove  %eax,%ecx
	switch (c & 0xff) {
f010047c:	0f b6 c1             	movzbl %cl,%eax
f010047f:	80 f9 0a             	cmp    $0xa,%cl
f0100482:	0f 84 dd 00 00 00    	je     f0100565 <cons_putc+0x17a>
f0100488:	83 f8 0a             	cmp    $0xa,%eax
f010048b:	7f 46                	jg     f01004d3 <cons_putc+0xe8>
f010048d:	83 f8 08             	cmp    $0x8,%eax
f0100490:	0f 84 a7 00 00 00    	je     f010053d <cons_putc+0x152>
f0100496:	83 f8 09             	cmp    $0x9,%eax
f0100499:	0f 85 d3 00 00 00    	jne    f0100572 <cons_putc+0x187>
		cons_putc(' ');
f010049f:	b8 20 00 00 00       	mov    $0x20,%eax
f01004a4:	e8 42 ff ff ff       	call   f01003eb <cons_putc>
		cons_putc(' ');
f01004a9:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ae:	e8 38 ff ff ff       	call   f01003eb <cons_putc>
		cons_putc(' ');
f01004b3:	b8 20 00 00 00       	mov    $0x20,%eax
f01004b8:	e8 2e ff ff ff       	call   f01003eb <cons_putc>
		cons_putc(' ');
f01004bd:	b8 20 00 00 00       	mov    $0x20,%eax
f01004c2:	e8 24 ff ff ff       	call   f01003eb <cons_putc>
		cons_putc(' ');
f01004c7:	b8 20 00 00 00       	mov    $0x20,%eax
f01004cc:	e8 1a ff ff ff       	call   f01003eb <cons_putc>
		break;
f01004d1:	eb 25                	jmp    f01004f8 <cons_putc+0x10d>
	switch (c & 0xff) {
f01004d3:	83 f8 0d             	cmp    $0xd,%eax
f01004d6:	0f 85 96 00 00 00    	jne    f0100572 <cons_putc+0x187>
		crt_pos -= (crt_pos % CRT_COLS);
f01004dc:	0f b7 05 28 b2 3b f0 	movzwl 0xf03bb228,%eax
f01004e3:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004e9:	c1 e8 16             	shr    $0x16,%eax
f01004ec:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004ef:	c1 e0 04             	shl    $0x4,%eax
f01004f2:	66 a3 28 b2 3b f0    	mov    %ax,0xf03bb228
	if (crt_pos >= CRT_SIZE) {
f01004f8:	66 81 3d 28 b2 3b f0 	cmpw   $0x7cf,0xf03bb228
f01004ff:	cf 07 
f0100501:	0f 87 8e 00 00 00    	ja     f0100595 <cons_putc+0x1aa>
	outb(addr_6845, 14);
f0100507:	8b 0d 30 b2 3b f0    	mov    0xf03bb230,%ecx
f010050d:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100512:	89 ca                	mov    %ecx,%edx
f0100514:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100515:	0f b7 1d 28 b2 3b f0 	movzwl 0xf03bb228,%ebx
f010051c:	8d 71 01             	lea    0x1(%ecx),%esi
f010051f:	89 d8                	mov    %ebx,%eax
f0100521:	66 c1 e8 08          	shr    $0x8,%ax
f0100525:	89 f2                	mov    %esi,%edx
f0100527:	ee                   	out    %al,(%dx)
f0100528:	b8 0f 00 00 00       	mov    $0xf,%eax
f010052d:	89 ca                	mov    %ecx,%edx
f010052f:	ee                   	out    %al,(%dx)
f0100530:	89 d8                	mov    %ebx,%eax
f0100532:	89 f2                	mov    %esi,%edx
f0100534:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100535:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100538:	5b                   	pop    %ebx
f0100539:	5e                   	pop    %esi
f010053a:	5f                   	pop    %edi
f010053b:	5d                   	pop    %ebp
f010053c:	c3                   	ret    
		if (crt_pos > 0) {
f010053d:	0f b7 05 28 b2 3b f0 	movzwl 0xf03bb228,%eax
f0100544:	66 85 c0             	test   %ax,%ax
f0100547:	74 be                	je     f0100507 <cons_putc+0x11c>
			crt_pos--;
f0100549:	83 e8 01             	sub    $0x1,%eax
f010054c:	66 a3 28 b2 3b f0    	mov    %ax,0xf03bb228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100552:	0f b7 d0             	movzwl %ax,%edx
f0100555:	b1 00                	mov    $0x0,%cl
f0100557:	83 c9 20             	or     $0x20,%ecx
f010055a:	a1 2c b2 3b f0       	mov    0xf03bb22c,%eax
f010055f:	66 89 0c 50          	mov    %cx,(%eax,%edx,2)
f0100563:	eb 93                	jmp    f01004f8 <cons_putc+0x10d>
		crt_pos += CRT_COLS;
f0100565:	66 83 05 28 b2 3b f0 	addw   $0x50,0xf03bb228
f010056c:	50 
f010056d:	e9 6a ff ff ff       	jmp    f01004dc <cons_putc+0xf1>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100572:	0f b7 05 28 b2 3b f0 	movzwl 0xf03bb228,%eax
f0100579:	8d 50 01             	lea    0x1(%eax),%edx
f010057c:	66 89 15 28 b2 3b f0 	mov    %dx,0xf03bb228
f0100583:	0f b7 c0             	movzwl %ax,%eax
f0100586:	8b 15 2c b2 3b f0    	mov    0xf03bb22c,%edx
f010058c:	66 89 0c 42          	mov    %cx,(%edx,%eax,2)
		break;
f0100590:	e9 63 ff ff ff       	jmp    f01004f8 <cons_putc+0x10d>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100595:	a1 2c b2 3b f0       	mov    0xf03bb22c,%eax
f010059a:	83 ec 04             	sub    $0x4,%esp
f010059d:	68 00 0f 00 00       	push   $0xf00
f01005a2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005a8:	52                   	push   %edx
f01005a9:	50                   	push   %eax
f01005aa:	e8 09 58 00 00       	call   f0105db8 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01005af:	8b 15 2c b2 3b f0    	mov    0xf03bb22c,%edx
f01005b5:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01005bb:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01005c1:	83 c4 10             	add    $0x10,%esp
f01005c4:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01005c9:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005cc:	39 d0                	cmp    %edx,%eax
f01005ce:	75 f4                	jne    f01005c4 <cons_putc+0x1d9>
		crt_pos -= CRT_COLS;
f01005d0:	66 83 2d 28 b2 3b f0 	subw   $0x50,0xf03bb228
f01005d7:	50 
f01005d8:	e9 2a ff ff ff       	jmp    f0100507 <cons_putc+0x11c>

f01005dd <serial_intr>:
{
f01005dd:	f3 0f 1e fb          	endbr32 
	if (serial_exists)
f01005e1:	80 3d 34 b2 3b f0 00 	cmpb   $0x0,0xf03bb234
f01005e8:	75 01                	jne    f01005eb <serial_intr+0xe>
f01005ea:	c3                   	ret    
{
f01005eb:	55                   	push   %ebp
f01005ec:	89 e5                	mov    %esp,%ebp
f01005ee:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01005f1:	b8 75 02 10 f0       	mov    $0xf0100275,%eax
f01005f6:	e8 98 fc ff ff       	call   f0100293 <cons_intr>
}
f01005fb:	c9                   	leave  
f01005fc:	c3                   	ret    

f01005fd <kbd_intr>:
{
f01005fd:	f3 0f 1e fb          	endbr32 
f0100601:	55                   	push   %ebp
f0100602:	89 e5                	mov    %esp,%ebp
f0100604:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100607:	b8 d2 02 10 f0       	mov    $0xf01002d2,%eax
f010060c:	e8 82 fc ff ff       	call   f0100293 <cons_intr>
}
f0100611:	c9                   	leave  
f0100612:	c3                   	ret    

f0100613 <cons_getc>:
{
f0100613:	f3 0f 1e fb          	endbr32 
f0100617:	55                   	push   %ebp
f0100618:	89 e5                	mov    %esp,%ebp
f010061a:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f010061d:	e8 bb ff ff ff       	call   f01005dd <serial_intr>
	kbd_intr();
f0100622:	e8 d6 ff ff ff       	call   f01005fd <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100627:	a1 20 b2 3b f0       	mov    0xf03bb220,%eax
	return 0;
f010062c:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f0100631:	3b 05 24 b2 3b f0    	cmp    0xf03bb224,%eax
f0100637:	74 1c                	je     f0100655 <cons_getc+0x42>
		c = cons.buf[cons.rpos++];
f0100639:	8d 48 01             	lea    0x1(%eax),%ecx
f010063c:	0f b6 90 20 b0 3b f0 	movzbl -0xfc44fe0(%eax),%edx
			cons.rpos = 0;
f0100643:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f0100648:	b8 00 00 00 00       	mov    $0x0,%eax
f010064d:	0f 45 c1             	cmovne %ecx,%eax
f0100650:	a3 20 b2 3b f0       	mov    %eax,0xf03bb220
}
f0100655:	89 d0                	mov    %edx,%eax
f0100657:	c9                   	leave  
f0100658:	c3                   	ret    

f0100659 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100659:	f3 0f 1e fb          	endbr32 
f010065d:	55                   	push   %ebp
f010065e:	89 e5                	mov    %esp,%ebp
f0100660:	57                   	push   %edi
f0100661:	56                   	push   %esi
f0100662:	53                   	push   %ebx
f0100663:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f0100666:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010066d:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100674:	5a a5 
	if (*cp != 0xA55A) {
f0100676:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010067d:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100681:	0f 84 de 00 00 00    	je     f0100765 <cons_init+0x10c>
		addr_6845 = MONO_BASE;
f0100687:	c7 05 30 b2 3b f0 b4 	movl   $0x3b4,0xf03bb230
f010068e:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100691:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f0100696:	8b 3d 30 b2 3b f0    	mov    0xf03bb230,%edi
f010069c:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006a1:	89 fa                	mov    %edi,%edx
f01006a3:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006a4:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006a7:	89 ca                	mov    %ecx,%edx
f01006a9:	ec                   	in     (%dx),%al
f01006aa:	0f b6 c0             	movzbl %al,%eax
f01006ad:	c1 e0 08             	shl    $0x8,%eax
f01006b0:	89 c3                	mov    %eax,%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006b2:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006b7:	89 fa                	mov    %edi,%edx
f01006b9:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006ba:	89 ca                	mov    %ecx,%edx
f01006bc:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f01006bd:	89 35 2c b2 3b f0    	mov    %esi,0xf03bb22c
	pos |= inb(addr_6845 + 1);
f01006c3:	0f b6 c0             	movzbl %al,%eax
f01006c6:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f01006c8:	66 a3 28 b2 3b f0    	mov    %ax,0xf03bb228
	kbd_intr();
f01006ce:	e8 2a ff ff ff       	call   f01005fd <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006d3:	83 ec 0c             	sub    $0xc,%esp
f01006d6:	0f b7 05 a8 33 12 f0 	movzwl 0xf01233a8,%eax
f01006dd:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006e2:	50                   	push   %eax
f01006e3:	e8 d8 32 00 00       	call   f01039c0 <irq_setmask_8259A>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006e8:	bb 00 00 00 00       	mov    $0x0,%ebx
f01006ed:	b9 fa 03 00 00       	mov    $0x3fa,%ecx
f01006f2:	89 d8                	mov    %ebx,%eax
f01006f4:	89 ca                	mov    %ecx,%edx
f01006f6:	ee                   	out    %al,(%dx)
f01006f7:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006fc:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100701:	89 fa                	mov    %edi,%edx
f0100703:	ee                   	out    %al,(%dx)
f0100704:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100709:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010070e:	ee                   	out    %al,(%dx)
f010070f:	be f9 03 00 00       	mov    $0x3f9,%esi
f0100714:	89 d8                	mov    %ebx,%eax
f0100716:	89 f2                	mov    %esi,%edx
f0100718:	ee                   	out    %al,(%dx)
f0100719:	b8 03 00 00 00       	mov    $0x3,%eax
f010071e:	89 fa                	mov    %edi,%edx
f0100720:	ee                   	out    %al,(%dx)
f0100721:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100726:	89 d8                	mov    %ebx,%eax
f0100728:	ee                   	out    %al,(%dx)
f0100729:	b8 01 00 00 00       	mov    $0x1,%eax
f010072e:	89 f2                	mov    %esi,%edx
f0100730:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100731:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100736:	ec                   	in     (%dx),%al
f0100737:	89 c3                	mov    %eax,%ebx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100739:	83 c4 10             	add    $0x10,%esp
f010073c:	3c ff                	cmp    $0xff,%al
f010073e:	0f 95 05 34 b2 3b f0 	setne  0xf03bb234
f0100745:	89 ca                	mov    %ecx,%edx
f0100747:	ec                   	in     (%dx),%al
f0100748:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010074d:	ec                   	in     (%dx),%al
	if (serial_exists)
f010074e:	80 fb ff             	cmp    $0xff,%bl
f0100751:	75 2d                	jne    f0100780 <cons_init+0x127>
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
		cprintf("Serial port does not exist!\n");
f0100753:	83 ec 0c             	sub    $0xc,%esp
f0100756:	68 d1 6a 10 f0       	push   $0xf0106ad1
f010075b:	e8 cd 33 00 00       	call   f0103b2d <cprintf>
f0100760:	83 c4 10             	add    $0x10,%esp
}
f0100763:	eb 3c                	jmp    f01007a1 <cons_init+0x148>
		*cp = was;
f0100765:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010076c:	c7 05 30 b2 3b f0 d4 	movl   $0x3d4,0xf03bb230
f0100773:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100776:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f010077b:	e9 16 ff ff ff       	jmp    f0100696 <cons_init+0x3d>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_SERIAL));
f0100780:	83 ec 0c             	sub    $0xc,%esp
f0100783:	0f b7 05 a8 33 12 f0 	movzwl 0xf01233a8,%eax
f010078a:	25 ef ff 00 00       	and    $0xffef,%eax
f010078f:	50                   	push   %eax
f0100790:	e8 2b 32 00 00       	call   f01039c0 <irq_setmask_8259A>
	if (!serial_exists)
f0100795:	83 c4 10             	add    $0x10,%esp
f0100798:	80 3d 34 b2 3b f0 00 	cmpb   $0x0,0xf03bb234
f010079f:	74 b2                	je     f0100753 <cons_init+0xfa>
}
f01007a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01007a4:	5b                   	pop    %ebx
f01007a5:	5e                   	pop    %esi
f01007a6:	5f                   	pop    %edi
f01007a7:	5d                   	pop    %ebp
f01007a8:	c3                   	ret    

f01007a9 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01007a9:	f3 0f 1e fb          	endbr32 
f01007ad:	55                   	push   %ebp
f01007ae:	89 e5                	mov    %esp,%ebp
f01007b0:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007b3:	8b 45 08             	mov    0x8(%ebp),%eax
f01007b6:	e8 30 fc ff ff       	call   f01003eb <cons_putc>
}
f01007bb:	c9                   	leave  
f01007bc:	c3                   	ret    

f01007bd <getchar>:

int
getchar(void)
{
f01007bd:	f3 0f 1e fb          	endbr32 
f01007c1:	55                   	push   %ebp
f01007c2:	89 e5                	mov    %esp,%ebp
f01007c4:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007c7:	e8 47 fe ff ff       	call   f0100613 <cons_getc>
f01007cc:	85 c0                	test   %eax,%eax
f01007ce:	74 f7                	je     f01007c7 <getchar+0xa>
		/* do nothing */;
	return c;
}
f01007d0:	c9                   	leave  
f01007d1:	c3                   	ret    

f01007d2 <iscons>:

int
iscons(int fdnum)
{
f01007d2:	f3 0f 1e fb          	endbr32 
	// used by readline
	return 1;
}
f01007d6:	b8 01 00 00 00       	mov    $0x1,%eax
f01007db:	c3                   	ret    

f01007dc <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007dc:	f3 0f 1e fb          	endbr32 
f01007e0:	55                   	push   %ebp
f01007e1:	89 e5                	mov    %esp,%ebp
f01007e3:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007e6:	68 20 6d 10 f0       	push   $0xf0106d20
f01007eb:	68 3e 6d 10 f0       	push   $0xf0106d3e
f01007f0:	68 43 6d 10 f0       	push   $0xf0106d43
f01007f5:	e8 33 33 00 00       	call   f0103b2d <cprintf>
f01007fa:	83 c4 0c             	add    $0xc,%esp
f01007fd:	68 fc 6d 10 f0       	push   $0xf0106dfc
f0100802:	68 4c 6d 10 f0       	push   $0xf0106d4c
f0100807:	68 43 6d 10 f0       	push   $0xf0106d43
f010080c:	e8 1c 33 00 00       	call   f0103b2d <cprintf>
f0100811:	83 c4 0c             	add    $0xc,%esp
f0100814:	68 24 6e 10 f0       	push   $0xf0106e24
f0100819:	68 55 6d 10 f0       	push   $0xf0106d55
f010081e:	68 43 6d 10 f0       	push   $0xf0106d43
f0100823:	e8 05 33 00 00       	call   f0103b2d <cprintf>
	return 0;
}
f0100828:	b8 00 00 00 00       	mov    $0x0,%eax
f010082d:	c9                   	leave  
f010082e:	c3                   	ret    

f010082f <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010082f:	f3 0f 1e fb          	endbr32 
f0100833:	55                   	push   %ebp
f0100834:	89 e5                	mov    %esp,%ebp
f0100836:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100839:	68 5f 6d 10 f0       	push   $0xf0106d5f
f010083e:	e8 ea 32 00 00       	call   f0103b2d <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100843:	83 c4 08             	add    $0x8,%esp
f0100846:	68 0c 00 10 00       	push   $0x10000c
f010084b:	68 54 6e 10 f0       	push   $0xf0106e54
f0100850:	e8 d8 32 00 00       	call   f0103b2d <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100855:	83 c4 0c             	add    $0xc,%esp
f0100858:	68 0c 00 10 00       	push   $0x10000c
f010085d:	68 0c 00 10 f0       	push   $0xf010000c
f0100862:	68 7c 6e 10 f0       	push   $0xf0106e7c
f0100867:	e8 c1 32 00 00       	call   f0103b2d <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010086c:	83 c4 0c             	add    $0xc,%esp
f010086f:	68 fd 69 10 00       	push   $0x1069fd
f0100874:	68 fd 69 10 f0       	push   $0xf01069fd
f0100879:	68 a0 6e 10 f0       	push   $0xf0106ea0
f010087e:	e8 aa 32 00 00       	call   f0103b2d <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100883:	83 c4 0c             	add    $0xc,%esp
f0100886:	68 00 b0 3b 00       	push   $0x3bb000
f010088b:	68 00 b0 3b f0       	push   $0xf03bb000
f0100890:	68 c4 6e 10 f0       	push   $0xf0106ec4
f0100895:	e8 93 32 00 00       	call   f0103b2d <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010089a:	83 c4 0c             	add    $0xc,%esp
f010089d:	68 08 d0 3f 00       	push   $0x3fd008
f01008a2:	68 08 d0 3f f0       	push   $0xf03fd008
f01008a7:	68 e8 6e 10 f0       	push   $0xf0106ee8
f01008ac:	e8 7c 32 00 00       	call   f0103b2d <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008b1:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01008b4:	b8 08 d0 3f f0       	mov    $0xf03fd008,%eax
f01008b9:	2d 0d fc 0f f0       	sub    $0xf00ffc0d,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008be:	c1 f8 0a             	sar    $0xa,%eax
f01008c1:	50                   	push   %eax
f01008c2:	68 0c 6f 10 f0       	push   $0xf0106f0c
f01008c7:	e8 61 32 00 00       	call   f0103b2d <cprintf>
	return 0;
}
f01008cc:	b8 00 00 00 00       	mov    $0x0,%eax
f01008d1:	c9                   	leave  
f01008d2:	c3                   	ret    

f01008d3 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008d3:	f3 0f 1e fb          	endbr32 
f01008d7:	55                   	push   %ebp
f01008d8:	89 e5                	mov    %esp,%ebp
f01008da:	57                   	push   %edi
f01008db:	56                   	push   %esi
f01008dc:	53                   	push   %ebx
f01008dd:	83 ec 38             	sub    $0x38,%esp
	// Your code here.

    cprintf("Stack backtrace:\n");
f01008e0:	68 78 6d 10 f0       	push   $0xf0106d78
f01008e5:	e8 43 32 00 00       	call   f0103b2d <cprintf>
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008ea:	89 ee                	mov    %ebp,%esi

    uint32_t c_ebp = read_ebp();

    while (c_ebp != 0) {
f01008ec:	83 c4 10             	add    $0x10,%esp
f01008ef:	e9 84 00 00 00       	jmp    f0100978 <mon_backtrace+0xa5>
        cprintf("  eip %08x", ebp[1]);
        cprintf("  args");
        for(int i = 0; i < 5; ++i) {
            cprintf(" %08x", ebp[2+i]);
        }
        cprintf("\n");
f01008f4:	83 ec 0c             	sub    $0xc,%esp
f01008f7:	68 e0 7b 10 f0       	push   $0xf0107be0
f01008fc:	e8 2c 32 00 00       	call   f0103b2d <cprintf>

        struct Eipdebuginfo info;
        memset(&info, 0, sizeof(struct Eipdebuginfo));
f0100901:	83 c4 0c             	add    $0xc,%esp
f0100904:	6a 18                	push   $0x18
f0100906:	6a 00                	push   $0x0
f0100908:	8d 45 d0             	lea    -0x30(%ebp),%eax
f010090b:	50                   	push   %eax
f010090c:	e8 5b 54 00 00       	call   f0105d6c <memset>

        int ret = debuginfo_eip((uintptr_t)ebp[1], &info);
f0100911:	83 c4 08             	add    $0x8,%esp
f0100914:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100917:	50                   	push   %eax
f0100918:	ff 77 04             	pushl  0x4(%edi)
f010091b:	e8 0e 49 00 00       	call   f010522e <debuginfo_eip>
        cprintf("         ");
f0100920:	c7 04 24 a7 6d 10 f0 	movl   $0xf0106da7,(%esp)
f0100927:	e8 01 32 00 00       	call   f0103b2d <cprintf>
        cprintf("%s:", info.eip_file);
f010092c:	83 c4 08             	add    $0x8,%esp
f010092f:	ff 75 d0             	pushl  -0x30(%ebp)
f0100932:	68 b1 6d 10 f0       	push   $0xf0106db1
f0100937:	e8 f1 31 00 00       	call   f0103b2d <cprintf>
        cprintf("%d: ", info.eip_line);
f010093c:	83 c4 08             	add    $0x8,%esp
f010093f:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100942:	68 c0 6a 10 f0       	push   $0xf0106ac0
f0100947:	e8 e1 31 00 00       	call   f0103b2d <cprintf>
        cprintf("%.*s", info.eip_fn_namelen, info.eip_fn_name);
f010094c:	83 c4 0c             	add    $0xc,%esp
f010094f:	ff 75 d8             	pushl  -0x28(%ebp)
f0100952:	ff 75 dc             	pushl  -0x24(%ebp)
f0100955:	68 b5 6d 10 f0       	push   $0xf0106db5
f010095a:	e8 ce 31 00 00       	call   f0103b2d <cprintf>

        uintptr_t addr = ebp[1] - info.eip_fn_addr;

        cprintf("+%d\n", addr);
f010095f:	83 c4 08             	add    $0x8,%esp
        uintptr_t addr = ebp[1] - info.eip_fn_addr;
f0100962:	8b 47 04             	mov    0x4(%edi),%eax
f0100965:	2b 45 e0             	sub    -0x20(%ebp),%eax
        cprintf("+%d\n", addr);
f0100968:	50                   	push   %eax
f0100969:	68 ba 6d 10 f0       	push   $0xf0106dba
f010096e:	e8 ba 31 00 00       	call   f0103b2d <cprintf>

        c_ebp = ebp[0];
f0100973:	8b 37                	mov    (%edi),%esi
f0100975:	83 c4 10             	add    $0x10,%esp
    while (c_ebp != 0) {
f0100978:	85 f6                	test   %esi,%esi
f010097a:	74 53                	je     f01009cf <mon_backtrace+0xfc>
        uint32_t *ebp = (uint32_t *)c_ebp;
f010097c:	89 f7                	mov    %esi,%edi
        cprintf("  ebp %08x", c_ebp);
f010097e:	83 ec 08             	sub    $0x8,%esp
f0100981:	56                   	push   %esi
f0100982:	68 8a 6d 10 f0       	push   $0xf0106d8a
f0100987:	e8 a1 31 00 00       	call   f0103b2d <cprintf>
        cprintf("  eip %08x", ebp[1]);
f010098c:	83 c4 08             	add    $0x8,%esp
f010098f:	ff 76 04             	pushl  0x4(%esi)
f0100992:	68 95 6d 10 f0       	push   $0xf0106d95
f0100997:	e8 91 31 00 00       	call   f0103b2d <cprintf>
        cprintf("  args");
f010099c:	c7 04 24 a0 6d 10 f0 	movl   $0xf0106da0,(%esp)
f01009a3:	e8 85 31 00 00       	call   f0103b2d <cprintf>
f01009a8:	8d 5e 08             	lea    0x8(%esi),%ebx
f01009ab:	83 c6 1c             	add    $0x1c,%esi
f01009ae:	83 c4 10             	add    $0x10,%esp
            cprintf(" %08x", ebp[2+i]);
f01009b1:	83 ec 08             	sub    $0x8,%esp
f01009b4:	ff 33                	pushl  (%ebx)
f01009b6:	68 8f 6d 10 f0       	push   $0xf0106d8f
f01009bb:	e8 6d 31 00 00       	call   f0103b2d <cprintf>
f01009c0:	83 c3 04             	add    $0x4,%ebx
        for(int i = 0; i < 5; ++i) {
f01009c3:	83 c4 10             	add    $0x10,%esp
f01009c6:	39 f3                	cmp    %esi,%ebx
f01009c8:	75 e7                	jne    f01009b1 <mon_backtrace+0xde>
f01009ca:	e9 25 ff ff ff       	jmp    f01008f4 <mon_backtrace+0x21>
    }
	return 0;
}
f01009cf:	b8 00 00 00 00       	mov    $0x0,%eax
f01009d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009d7:	5b                   	pop    %ebx
f01009d8:	5e                   	pop    %esi
f01009d9:	5f                   	pop    %edi
f01009da:	5d                   	pop    %ebp
f01009db:	c3                   	ret    

f01009dc <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01009dc:	f3 0f 1e fb          	endbr32 
f01009e0:	55                   	push   %ebp
f01009e1:	89 e5                	mov    %esp,%ebp
f01009e3:	57                   	push   %edi
f01009e4:	56                   	push   %esi
f01009e5:	53                   	push   %ebx
f01009e6:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01009e9:	68 38 6f 10 f0       	push   $0xf0106f38
f01009ee:	e8 3a 31 00 00       	call   f0103b2d <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009f3:	c7 04 24 5c 6f 10 f0 	movl   $0xf0106f5c,(%esp)
f01009fa:	e8 2e 31 00 00       	call   f0103b2d <cprintf>

	if (tf != NULL)
f01009ff:	83 c4 10             	add    $0x10,%esp
f0100a02:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100a06:	0f 84 d9 00 00 00    	je     f0100ae5 <monitor+0x109>
		print_trapframe(tf);
f0100a0c:	83 ec 0c             	sub    $0xc,%esp
f0100a0f:	ff 75 08             	pushl  0x8(%ebp)
f0100a12:	e8 94 38 00 00       	call   f01042ab <print_trapframe>
f0100a17:	83 c4 10             	add    $0x10,%esp
f0100a1a:	e9 c6 00 00 00       	jmp    f0100ae5 <monitor+0x109>
		while (*buf && strchr(WHITESPACE, *buf))
f0100a1f:	83 ec 08             	sub    $0x8,%esp
f0100a22:	0f be c0             	movsbl %al,%eax
f0100a25:	50                   	push   %eax
f0100a26:	68 c3 6d 10 f0       	push   $0xf0106dc3
f0100a2b:	e8 f7 52 00 00       	call   f0105d27 <strchr>
f0100a30:	83 c4 10             	add    $0x10,%esp
f0100a33:	85 c0                	test   %eax,%eax
f0100a35:	74 63                	je     f0100a9a <monitor+0xbe>
			*buf++ = 0;
f0100a37:	c6 03 00             	movb   $0x0,(%ebx)
f0100a3a:	89 f7                	mov    %esi,%edi
f0100a3c:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100a3f:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100a41:	0f b6 03             	movzbl (%ebx),%eax
f0100a44:	84 c0                	test   %al,%al
f0100a46:	75 d7                	jne    f0100a1f <monitor+0x43>
	argv[argc] = 0;
f0100a48:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a4f:	00 
	if (argc == 0)
f0100a50:	85 f6                	test   %esi,%esi
f0100a52:	0f 84 8d 00 00 00    	je     f0100ae5 <monitor+0x109>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a58:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a5d:	83 ec 08             	sub    $0x8,%esp
f0100a60:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a63:	ff 34 85 a0 6f 10 f0 	pushl  -0xfef9060(,%eax,4)
f0100a6a:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a6d:	e8 4f 52 00 00       	call   f0105cc1 <strcmp>
f0100a72:	83 c4 10             	add    $0x10,%esp
f0100a75:	85 c0                	test   %eax,%eax
f0100a77:	0f 84 8f 00 00 00    	je     f0100b0c <monitor+0x130>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a7d:	83 c3 01             	add    $0x1,%ebx
f0100a80:	83 fb 03             	cmp    $0x3,%ebx
f0100a83:	75 d8                	jne    f0100a5d <monitor+0x81>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a85:	83 ec 08             	sub    $0x8,%esp
f0100a88:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a8b:	68 e5 6d 10 f0       	push   $0xf0106de5
f0100a90:	e8 98 30 00 00       	call   f0103b2d <cprintf>
	return 0;
f0100a95:	83 c4 10             	add    $0x10,%esp
f0100a98:	eb 4b                	jmp    f0100ae5 <monitor+0x109>
		if (*buf == 0)
f0100a9a:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100a9d:	74 a9                	je     f0100a48 <monitor+0x6c>
		if (argc == MAXARGS-1) {
f0100a9f:	83 fe 0f             	cmp    $0xf,%esi
f0100aa2:	74 2f                	je     f0100ad3 <monitor+0xf7>
		argv[argc++] = buf;
f0100aa4:	8d 7e 01             	lea    0x1(%esi),%edi
f0100aa7:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100aab:	0f b6 03             	movzbl (%ebx),%eax
f0100aae:	84 c0                	test   %al,%al
f0100ab0:	74 8d                	je     f0100a3f <monitor+0x63>
f0100ab2:	83 ec 08             	sub    $0x8,%esp
f0100ab5:	0f be c0             	movsbl %al,%eax
f0100ab8:	50                   	push   %eax
f0100ab9:	68 c3 6d 10 f0       	push   $0xf0106dc3
f0100abe:	e8 64 52 00 00       	call   f0105d27 <strchr>
f0100ac3:	83 c4 10             	add    $0x10,%esp
f0100ac6:	85 c0                	test   %eax,%eax
f0100ac8:	0f 85 71 ff ff ff    	jne    f0100a3f <monitor+0x63>
			buf++;
f0100ace:	83 c3 01             	add    $0x1,%ebx
f0100ad1:	eb d8                	jmp    f0100aab <monitor+0xcf>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100ad3:	83 ec 08             	sub    $0x8,%esp
f0100ad6:	6a 10                	push   $0x10
f0100ad8:	68 c8 6d 10 f0       	push   $0xf0106dc8
f0100add:	e8 4b 30 00 00       	call   f0103b2d <cprintf>
			return 0;
f0100ae2:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100ae5:	83 ec 0c             	sub    $0xc,%esp
f0100ae8:	68 bf 6d 10 f0       	push   $0xf0106dbf
f0100aed:	e8 db 4f 00 00       	call   f0105acd <readline>
f0100af2:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100af4:	83 c4 10             	add    $0x10,%esp
f0100af7:	85 c0                	test   %eax,%eax
f0100af9:	74 ea                	je     f0100ae5 <monitor+0x109>
	argv[argc] = 0;
f0100afb:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100b02:	be 00 00 00 00       	mov    $0x0,%esi
f0100b07:	e9 35 ff ff ff       	jmp    f0100a41 <monitor+0x65>
			return commands[i].func(argc, argv, tf);
f0100b0c:	83 ec 04             	sub    $0x4,%esp
f0100b0f:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100b12:	ff 75 08             	pushl  0x8(%ebp)
f0100b15:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100b18:	52                   	push   %edx
f0100b19:	56                   	push   %esi
f0100b1a:	ff 14 85 a8 6f 10 f0 	call   *-0xfef9058(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100b21:	83 c4 10             	add    $0x10,%esp
f0100b24:	85 c0                	test   %eax,%eax
f0100b26:	79 bd                	jns    f0100ae5 <monitor+0x109>
				break;
	}
}
f0100b28:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100b2b:	5b                   	pop    %ebx
f0100b2c:	5e                   	pop    %esi
f0100b2d:	5f                   	pop    %edi
f0100b2e:	5d                   	pop    %ebp
f0100b2f:	c3                   	ret    

f0100b30 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100b30:	55                   	push   %ebp
f0100b31:	89 e5                	mov    %esp,%ebp
f0100b33:	56                   	push   %esi
f0100b34:	53                   	push   %ebx
f0100b35:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100b37:	83 ec 0c             	sub    $0xc,%esp
f0100b3a:	50                   	push   %eax
f0100b3b:	e8 4a 2e 00 00       	call   f010398a <mc146818_read>
f0100b40:	89 c6                	mov    %eax,%esi
f0100b42:	83 c3 01             	add    $0x1,%ebx
f0100b45:	89 1c 24             	mov    %ebx,(%esp)
f0100b48:	e8 3d 2e 00 00       	call   f010398a <mc146818_read>
f0100b4d:	c1 e0 08             	shl    $0x8,%eax
f0100b50:	09 f0                	or     %esi,%eax
}
f0100b52:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100b55:	5b                   	pop    %ebx
f0100b56:	5e                   	pop    %esi
f0100b57:	5d                   	pop    %ebp
f0100b58:	c3                   	ret    

f0100b59 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100b59:	89 d1                	mov    %edx,%ecx
f0100b5b:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100b5e:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b61:	a8 01                	test   $0x1,%al
f0100b63:	74 51                	je     f0100bb6 <check_va2pa+0x5d>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b65:	89 c1                	mov    %eax,%ecx
f0100b67:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	if (PGNUM(pa) >= npages)
f0100b6d:	c1 e8 0c             	shr    $0xc,%eax
f0100b70:	3b 05 88 be 3b f0    	cmp    0xf03bbe88,%eax
f0100b76:	73 23                	jae    f0100b9b <check_va2pa+0x42>
	if (!(p[PTX(va)] & PTE_P))
f0100b78:	c1 ea 0c             	shr    $0xc,%edx
f0100b7b:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b81:	8b 94 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b88:	89 d0                	mov    %edx,%eax
f0100b8a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b8f:	f6 c2 01             	test   $0x1,%dl
f0100b92:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b97:	0f 44 c2             	cmove  %edx,%eax
f0100b9a:	c3                   	ret    
{
f0100b9b:	55                   	push   %ebp
f0100b9c:	89 e5                	mov    %esp,%ebp
f0100b9e:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ba1:	51                   	push   %ecx
f0100ba2:	68 24 6a 10 f0       	push   $0xf0106a24
f0100ba7:	68 d6 03 00 00       	push   $0x3d6
f0100bac:	68 e5 78 10 f0       	push   $0xf01078e5
f0100bb1:	e8 8a f4 ff ff       	call   f0100040 <_panic>
		return ~0;
f0100bb6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100bbb:	c3                   	ret    

f0100bbc <boot_alloc>:
	if (!nextfree) {
f0100bbc:	83 3d 38 b2 3b f0 00 	cmpl   $0x0,0xf03bb238
f0100bc3:	74 3d                	je     f0100c02 <boot_alloc+0x46>
    if (n == 0) {
f0100bc5:	85 c0                	test   %eax,%eax
f0100bc7:	74 4c                	je     f0100c15 <boot_alloc+0x59>
{
f0100bc9:	55                   	push   %ebp
f0100bca:	89 e5                	mov    %esp,%ebp
f0100bcc:	83 ec 08             	sub    $0x8,%esp
            (uintptr_t) ROUNDUP((char *)nextfree + n, PGSIZE);
f0100bcf:	8b 15 38 b2 3b f0    	mov    0xf03bb238,%edx
f0100bd5:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100bdc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if ((uint32_t)kva < KERNBASE)
f0100be1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100be6:	76 36                	jbe    f0100c1e <boot_alloc+0x62>
	return (physaddr_t)kva - KERNBASE;
f0100be8:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
    if ( PADDR((void *)next_nextfree)/PGSIZE < npages ) {
f0100bee:	c1 e9 0c             	shr    $0xc,%ecx
f0100bf1:	3b 0d 88 be 3b f0    	cmp    0xf03bbe88,%ecx
f0100bf7:	73 37                	jae    f0100c30 <boot_alloc+0x74>
        nextfree = (char *)next_nextfree;
f0100bf9:	a3 38 b2 3b f0       	mov    %eax,0xf03bb238
}
f0100bfe:	89 d0                	mov    %edx,%eax
f0100c00:	c9                   	leave  
f0100c01:	c3                   	ret    
		nextfree = ROUNDUP((char *) end + 1, PGSIZE);
f0100c02:	ba 08 e0 3f f0       	mov    $0xf03fe008,%edx
f0100c07:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100c0d:	89 15 38 b2 3b f0    	mov    %edx,0xf03bb238
f0100c13:	eb b0                	jmp    f0100bc5 <boot_alloc+0x9>
        return nextfree;
f0100c15:	8b 15 38 b2 3b f0    	mov    0xf03bb238,%edx
}
f0100c1b:	89 d0                	mov    %edx,%eax
f0100c1d:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100c1e:	50                   	push   %eax
f0100c1f:	68 48 6a 10 f0       	push   $0xf0106a48
f0100c24:	6a 76                	push   $0x76
f0100c26:	68 e5 78 10 f0       	push   $0xf01078e5
f0100c2b:	e8 10 f4 ff ff       	call   f0100040 <_panic>
        panic("Out of memory");
f0100c30:	83 ec 04             	sub    $0x4,%esp
f0100c33:	68 f1 78 10 f0       	push   $0xf01078f1
f0100c38:	6a 7c                	push   $0x7c
f0100c3a:	68 e5 78 10 f0       	push   $0xf01078e5
f0100c3f:	e8 fc f3 ff ff       	call   f0100040 <_panic>

f0100c44 <check_page_free_list>:
{
f0100c44:	55                   	push   %ebp
f0100c45:	89 e5                	mov    %esp,%ebp
f0100c47:	57                   	push   %edi
f0100c48:	56                   	push   %esi
f0100c49:	53                   	push   %ebx
f0100c4a:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c4d:	84 c0                	test   %al,%al
f0100c4f:	0f 85 77 02 00 00    	jne    f0100ecc <check_page_free_list+0x288>
	if (!page_free_list)
f0100c55:	83 3d 40 b2 3b f0 00 	cmpl   $0x0,0xf03bb240
f0100c5c:	74 0a                	je     f0100c68 <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c5e:	be 00 04 00 00       	mov    $0x400,%esi
f0100c63:	e9 bf 02 00 00       	jmp    f0100f27 <check_page_free_list+0x2e3>
		panic("'page_free_list' is a null pointer!");
f0100c68:	83 ec 04             	sub    $0x4,%esp
f0100c6b:	68 c4 6f 10 f0       	push   $0xf0106fc4
f0100c70:	68 08 03 00 00       	push   $0x308
f0100c75:	68 e5 78 10 f0       	push   $0xf01078e5
f0100c7a:	e8 c1 f3 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c7f:	50                   	push   %eax
f0100c80:	68 24 6a 10 f0       	push   $0xf0106a24
f0100c85:	6a 58                	push   $0x58
f0100c87:	68 ff 78 10 f0       	push   $0xf01078ff
f0100c8c:	e8 af f3 ff ff       	call   f0100040 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c91:	8b 1b                	mov    (%ebx),%ebx
f0100c93:	85 db                	test   %ebx,%ebx
f0100c95:	74 41                	je     f0100cd8 <check_page_free_list+0x94>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c97:	89 d8                	mov    %ebx,%eax
f0100c99:	2b 05 90 be 3b f0    	sub    0xf03bbe90,%eax
f0100c9f:	c1 f8 03             	sar    $0x3,%eax
f0100ca2:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100ca5:	89 c2                	mov    %eax,%edx
f0100ca7:	c1 ea 16             	shr    $0x16,%edx
f0100caa:	39 f2                	cmp    %esi,%edx
f0100cac:	73 e3                	jae    f0100c91 <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f0100cae:	89 c2                	mov    %eax,%edx
f0100cb0:	c1 ea 0c             	shr    $0xc,%edx
f0100cb3:	3b 15 88 be 3b f0    	cmp    0xf03bbe88,%edx
f0100cb9:	73 c4                	jae    f0100c7f <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100cbb:	83 ec 04             	sub    $0x4,%esp
f0100cbe:	68 80 00 00 00       	push   $0x80
f0100cc3:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100cc8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ccd:	50                   	push   %eax
f0100cce:	e8 99 50 00 00       	call   f0105d6c <memset>
f0100cd3:	83 c4 10             	add    $0x10,%esp
f0100cd6:	eb b9                	jmp    f0100c91 <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f0100cd8:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cdd:	e8 da fe ff ff       	call   f0100bbc <boot_alloc>
f0100ce2:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ce5:	8b 15 40 b2 3b f0    	mov    0xf03bb240,%edx
		assert(pp >= pages);
f0100ceb:	8b 0d 90 be 3b f0    	mov    0xf03bbe90,%ecx
		assert(pp < pages + npages);
f0100cf1:	a1 88 be 3b f0       	mov    0xf03bbe88,%eax
f0100cf6:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100cf9:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100cfc:	bf 00 00 00 00       	mov    $0x0,%edi
f0100d01:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d04:	e9 f9 00 00 00       	jmp    f0100e02 <check_page_free_list+0x1be>
		assert(pp >= pages);
f0100d09:	68 0d 79 10 f0       	push   $0xf010790d
f0100d0e:	68 19 79 10 f0       	push   $0xf0107919
f0100d13:	68 22 03 00 00       	push   $0x322
f0100d18:	68 e5 78 10 f0       	push   $0xf01078e5
f0100d1d:	e8 1e f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100d22:	68 2e 79 10 f0       	push   $0xf010792e
f0100d27:	68 19 79 10 f0       	push   $0xf0107919
f0100d2c:	68 23 03 00 00       	push   $0x323
f0100d31:	68 e5 78 10 f0       	push   $0xf01078e5
f0100d36:	e8 05 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d3b:	68 e8 6f 10 f0       	push   $0xf0106fe8
f0100d40:	68 19 79 10 f0       	push   $0xf0107919
f0100d45:	68 24 03 00 00       	push   $0x324
f0100d4a:	68 e5 78 10 f0       	push   $0xf01078e5
f0100d4f:	e8 ec f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != 0);
f0100d54:	68 42 79 10 f0       	push   $0xf0107942
f0100d59:	68 19 79 10 f0       	push   $0xf0107919
f0100d5e:	68 27 03 00 00       	push   $0x327
f0100d63:	68 e5 78 10 f0       	push   $0xf01078e5
f0100d68:	e8 d3 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d6d:	68 53 79 10 f0       	push   $0xf0107953
f0100d72:	68 19 79 10 f0       	push   $0xf0107919
f0100d77:	68 28 03 00 00       	push   $0x328
f0100d7c:	68 e5 78 10 f0       	push   $0xf01078e5
f0100d81:	e8 ba f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d86:	68 1c 70 10 f0       	push   $0xf010701c
f0100d8b:	68 19 79 10 f0       	push   $0xf0107919
f0100d90:	68 29 03 00 00       	push   $0x329
f0100d95:	68 e5 78 10 f0       	push   $0xf01078e5
f0100d9a:	e8 a1 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d9f:	68 6c 79 10 f0       	push   $0xf010796c
f0100da4:	68 19 79 10 f0       	push   $0xf0107919
f0100da9:	68 2a 03 00 00       	push   $0x32a
f0100dae:	68 e5 78 10 f0       	push   $0xf01078e5
f0100db3:	e8 88 f2 ff ff       	call   f0100040 <_panic>
	if (PGNUM(pa) >= npages)
f0100db8:	89 c3                	mov    %eax,%ebx
f0100dba:	c1 eb 0c             	shr    $0xc,%ebx
f0100dbd:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0100dc0:	76 0f                	jbe    f0100dd1 <check_page_free_list+0x18d>
	return (void *)(pa + KERNBASE);
f0100dc2:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100dc7:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100dca:	77 17                	ja     f0100de3 <check_page_free_list+0x19f>
			++nfree_extmem;
f0100dcc:	83 c7 01             	add    $0x1,%edi
f0100dcf:	eb 2f                	jmp    f0100e00 <check_page_free_list+0x1bc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100dd1:	50                   	push   %eax
f0100dd2:	68 24 6a 10 f0       	push   $0xf0106a24
f0100dd7:	6a 58                	push   $0x58
f0100dd9:	68 ff 78 10 f0       	push   $0xf01078ff
f0100dde:	e8 5d f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100de3:	68 40 70 10 f0       	push   $0xf0107040
f0100de8:	68 19 79 10 f0       	push   $0xf0107919
f0100ded:	68 2b 03 00 00       	push   $0x32b
f0100df2:	68 e5 78 10 f0       	push   $0xf01078e5
f0100df7:	e8 44 f2 ff ff       	call   f0100040 <_panic>
			++nfree_basemem;
f0100dfc:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e00:	8b 12                	mov    (%edx),%edx
f0100e02:	85 d2                	test   %edx,%edx
f0100e04:	74 74                	je     f0100e7a <check_page_free_list+0x236>
		assert(pp >= pages);
f0100e06:	39 d1                	cmp    %edx,%ecx
f0100e08:	0f 87 fb fe ff ff    	ja     f0100d09 <check_page_free_list+0xc5>
		assert(pp < pages + npages);
f0100e0e:	39 d6                	cmp    %edx,%esi
f0100e10:	0f 86 0c ff ff ff    	jbe    f0100d22 <check_page_free_list+0xde>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100e16:	89 d0                	mov    %edx,%eax
f0100e18:	29 c8                	sub    %ecx,%eax
f0100e1a:	a8 07                	test   $0x7,%al
f0100e1c:	0f 85 19 ff ff ff    	jne    f0100d3b <check_page_free_list+0xf7>
	return (pp - pages) << PGSHIFT;
f0100e22:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100e25:	c1 e0 0c             	shl    $0xc,%eax
f0100e28:	0f 84 26 ff ff ff    	je     f0100d54 <check_page_free_list+0x110>
		assert(page2pa(pp) != IOPHYSMEM);
f0100e2e:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100e33:	0f 84 34 ff ff ff    	je     f0100d6d <check_page_free_list+0x129>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100e39:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100e3e:	0f 84 42 ff ff ff    	je     f0100d86 <check_page_free_list+0x142>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100e44:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100e49:	0f 84 50 ff ff ff    	je     f0100d9f <check_page_free_list+0x15b>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e4f:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100e54:	0f 87 5e ff ff ff    	ja     f0100db8 <check_page_free_list+0x174>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e5a:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e5f:	75 9b                	jne    f0100dfc <check_page_free_list+0x1b8>
f0100e61:	68 86 79 10 f0       	push   $0xf0107986
f0100e66:	68 19 79 10 f0       	push   $0xf0107919
f0100e6b:	68 2d 03 00 00       	push   $0x32d
f0100e70:	68 e5 78 10 f0       	push   $0xf01078e5
f0100e75:	e8 c6 f1 ff ff       	call   f0100040 <_panic>
f0100e7a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
	assert(nfree_basemem > 0);
f0100e7d:	85 db                	test   %ebx,%ebx
f0100e7f:	7e 19                	jle    f0100e9a <check_page_free_list+0x256>
	assert(nfree_extmem > 0);
f0100e81:	85 ff                	test   %edi,%edi
f0100e83:	7e 2e                	jle    f0100eb3 <check_page_free_list+0x26f>
	cprintf("check_page_free_list() succeeded!\n");
f0100e85:	83 ec 0c             	sub    $0xc,%esp
f0100e88:	68 88 70 10 f0       	push   $0xf0107088
f0100e8d:	e8 9b 2c 00 00       	call   f0103b2d <cprintf>
}
f0100e92:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e95:	5b                   	pop    %ebx
f0100e96:	5e                   	pop    %esi
f0100e97:	5f                   	pop    %edi
f0100e98:	5d                   	pop    %ebp
f0100e99:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100e9a:	68 a3 79 10 f0       	push   $0xf01079a3
f0100e9f:	68 19 79 10 f0       	push   $0xf0107919
f0100ea4:	68 35 03 00 00       	push   $0x335
f0100ea9:	68 e5 78 10 f0       	push   $0xf01078e5
f0100eae:	e8 8d f1 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100eb3:	68 b5 79 10 f0       	push   $0xf01079b5
f0100eb8:	68 19 79 10 f0       	push   $0xf0107919
f0100ebd:	68 36 03 00 00       	push   $0x336
f0100ec2:	68 e5 78 10 f0       	push   $0xf01078e5
f0100ec7:	e8 74 f1 ff ff       	call   f0100040 <_panic>
	if (!page_free_list)
f0100ecc:	a1 40 b2 3b f0       	mov    0xf03bb240,%eax
f0100ed1:	85 c0                	test   %eax,%eax
f0100ed3:	0f 84 8f fd ff ff    	je     f0100c68 <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100ed9:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100edc:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100edf:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100ee2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100ee5:	89 c2                	mov    %eax,%edx
f0100ee7:	2b 15 90 be 3b f0    	sub    0xf03bbe90,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100eed:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100ef3:	0f 95 c2             	setne  %dl
f0100ef6:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100ef9:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100efd:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100eff:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f03:	8b 00                	mov    (%eax),%eax
f0100f05:	85 c0                	test   %eax,%eax
f0100f07:	75 dc                	jne    f0100ee5 <check_page_free_list+0x2a1>
		*tp[1] = 0;
f0100f09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f0c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100f12:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100f15:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f18:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100f1a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100f1d:	a3 40 b2 3b f0       	mov    %eax,0xf03bb240
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100f22:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100f27:	8b 1d 40 b2 3b f0    	mov    0xf03bb240,%ebx
f0100f2d:	e9 61 fd ff ff       	jmp    f0100c93 <check_page_free_list+0x4f>

f0100f32 <page_init>:
{
f0100f32:	f3 0f 1e fb          	endbr32 
f0100f36:	55                   	push   %ebp
f0100f37:	89 e5                	mov    %esp,%ebp
f0100f39:	57                   	push   %edi
f0100f3a:	56                   	push   %esi
f0100f3b:	53                   	push   %ebx
f0100f3c:	83 ec 1c             	sub    $0x1c,%esp
    physaddr_t free_phy = PADDR((void *)boot_alloc(0));
f0100f3f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f44:	e8 73 fc ff ff       	call   f0100bbc <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0100f49:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100f4e:	76 1d                	jbe    f0100f6d <page_init+0x3b>
	return (physaddr_t)kva - KERNBASE;
f0100f50:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
    size_t free_phy_pgnum = PGNUM(free_phy);
f0100f56:	c1 e9 0c             	shr    $0xc,%ecx
f0100f59:	8b 3d 40 b2 3b f0    	mov    0xf03bb240,%edi
    for (int i=0; i<npages; ++i) {
f0100f5f:	c6 45 e3 00          	movb   $0x0,-0x1d(%ebp)
f0100f63:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f68:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100f6b:	eb 32                	jmp    f0100f9f <page_init+0x6d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f6d:	50                   	push   %eax
f0100f6e:	68 48 6a 10 f0       	push   $0xf0106a48
f0100f73:	68 5f 01 00 00       	push   $0x15f
f0100f78:	68 e5 78 10 f0       	push   $0xf01078e5
f0100f7d:	e8 be f0 ff ff       	call   f0100040 <_panic>
            pages[i].pp_link = NULL;
f0100f82:	8b 1d 90 be 3b f0    	mov    0xf03bbe90,%ebx
f0100f88:	c7 04 d3 00 00 00 00 	movl   $0x0,(%ebx,%edx,8)
            pages[i].pp_ref = 1;
f0100f8f:	8b 1d 90 be 3b f0    	mov    0xf03bbe90,%ebx
f0100f95:	66 c7 44 d3 04 01 00 	movw   $0x1,0x4(%ebx,%edx,8)
    for (int i=0; i<npages; ++i) {
f0100f9c:	83 c0 01             	add    $0x1,%eax
f0100f9f:	89 c2                	mov    %eax,%edx
f0100fa1:	39 05 88 be 3b f0    	cmp    %eax,0xf03bbe88
f0100fa7:	76 41                	jbe    f0100fea <page_init+0xb8>
        if (i == 0 || ( i >= PGNUM(IOPHYSMEM) && i < free_phy_pgnum ) ||
f0100fa9:	85 c0                	test   %eax,%eax
f0100fab:	74 d5                	je     f0100f82 <page_init+0x50>
f0100fad:	81 fa 9f 00 00 00    	cmp    $0x9f,%edx
f0100fb3:	0f 97 c3             	seta   %bl
f0100fb6:	89 de                	mov    %ebx,%esi
f0100fb8:	39 55 e4             	cmp    %edx,-0x1c(%ebp)
f0100fbb:	0f 97 c3             	seta   %bl
f0100fbe:	89 f1                	mov    %esi,%ecx
f0100fc0:	84 d9                	test   %bl,%cl
f0100fc2:	75 be                	jne    f0100f82 <page_init+0x50>
f0100fc4:	83 f8 07             	cmp    $0x7,%eax
f0100fc7:	74 b9                	je     f0100f82 <page_init+0x50>
f0100fc9:	c1 e2 03             	shl    $0x3,%edx
            pages[i].pp_ref = 0;
f0100fcc:	89 d3                	mov    %edx,%ebx
f0100fce:	03 1d 90 be 3b f0    	add    0xf03bbe90,%ebx
f0100fd4:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
            pages[i].pp_link = page_free_list;
f0100fda:	89 3b                	mov    %edi,(%ebx)
            page_free_list = &pages[i];
f0100fdc:	89 d7                	mov    %edx,%edi
f0100fde:	03 3d 90 be 3b f0    	add    0xf03bbe90,%edi
f0100fe4:	c6 45 e3 01          	movb   $0x1,-0x1d(%ebp)
f0100fe8:	eb b2                	jmp    f0100f9c <page_init+0x6a>
f0100fea:	80 7d e3 00          	cmpb   $0x0,-0x1d(%ebp)
f0100fee:	74 06                	je     f0100ff6 <page_init+0xc4>
f0100ff0:	89 3d 40 b2 3b f0    	mov    %edi,0xf03bb240
}
f0100ff6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ff9:	5b                   	pop    %ebx
f0100ffa:	5e                   	pop    %esi
f0100ffb:	5f                   	pop    %edi
f0100ffc:	5d                   	pop    %ebp
f0100ffd:	c3                   	ret    

f0100ffe <page_alloc>:
{
f0100ffe:	f3 0f 1e fb          	endbr32 
f0101002:	55                   	push   %ebp
f0101003:	89 e5                	mov    %esp,%ebp
f0101005:	53                   	push   %ebx
f0101006:	83 ec 04             	sub    $0x4,%esp
    if (page_free_list == NULL) {
f0101009:	8b 1d 40 b2 3b f0    	mov    0xf03bb240,%ebx
f010100f:	85 db                	test   %ebx,%ebx
f0101011:	74 13                	je     f0101026 <page_alloc+0x28>
    page_free_list = ret->pp_link;
f0101013:	8b 03                	mov    (%ebx),%eax
f0101015:	a3 40 b2 3b f0       	mov    %eax,0xf03bb240
    ret->pp_link = NULL;
f010101a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (alloc_flags & ALLOC_ZERO) {
f0101020:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101024:	75 07                	jne    f010102d <page_alloc+0x2f>
}
f0101026:	89 d8                	mov    %ebx,%eax
f0101028:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010102b:	c9                   	leave  
f010102c:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f010102d:	89 d8                	mov    %ebx,%eax
f010102f:	2b 05 90 be 3b f0    	sub    0xf03bbe90,%eax
f0101035:	c1 f8 03             	sar    $0x3,%eax
f0101038:	89 c2                	mov    %eax,%edx
f010103a:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010103d:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101042:	3b 05 88 be 3b f0    	cmp    0xf03bbe88,%eax
f0101048:	73 1b                	jae    f0101065 <page_alloc+0x67>
        memset(p, 0, PGSIZE);
f010104a:	83 ec 04             	sub    $0x4,%esp
f010104d:	68 00 10 00 00       	push   $0x1000
f0101052:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0101054:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010105a:	52                   	push   %edx
f010105b:	e8 0c 4d 00 00       	call   f0105d6c <memset>
f0101060:	83 c4 10             	add    $0x10,%esp
f0101063:	eb c1                	jmp    f0101026 <page_alloc+0x28>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101065:	52                   	push   %edx
f0101066:	68 24 6a 10 f0       	push   $0xf0106a24
f010106b:	6a 58                	push   $0x58
f010106d:	68 ff 78 10 f0       	push   $0xf01078ff
f0101072:	e8 c9 ef ff ff       	call   f0100040 <_panic>

f0101077 <page_free>:
{
f0101077:	f3 0f 1e fb          	endbr32 
f010107b:	55                   	push   %ebp
f010107c:	89 e5                	mov    %esp,%ebp
f010107e:	83 ec 08             	sub    $0x8,%esp
f0101081:	8b 45 08             	mov    0x8(%ebp),%eax
    if (pp->pp_ref != 0 || pp->pp_link != NULL) {
f0101084:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101089:	75 14                	jne    f010109f <page_free+0x28>
f010108b:	83 38 00             	cmpl   $0x0,(%eax)
f010108e:	75 0f                	jne    f010109f <page_free+0x28>
    pp->pp_link = page_free_list;
f0101090:	8b 15 40 b2 3b f0    	mov    0xf03bb240,%edx
f0101096:	89 10                	mov    %edx,(%eax)
    page_free_list = pp;
f0101098:	a3 40 b2 3b f0       	mov    %eax,0xf03bb240
}
f010109d:	c9                   	leave  
f010109e:	c3                   	ret    
        panic("Double free!");
f010109f:	83 ec 04             	sub    $0x4,%esp
f01010a2:	68 c6 79 10 f0       	push   $0xf01079c6
f01010a7:	68 9f 01 00 00       	push   $0x19f
f01010ac:	68 e5 78 10 f0       	push   $0xf01078e5
f01010b1:	e8 8a ef ff ff       	call   f0100040 <_panic>

f01010b6 <page_decref>:
{
f01010b6:	f3 0f 1e fb          	endbr32 
f01010ba:	55                   	push   %ebp
f01010bb:	89 e5                	mov    %esp,%ebp
f01010bd:	83 ec 08             	sub    $0x8,%esp
f01010c0:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f01010c3:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f01010c7:	83 e8 01             	sub    $0x1,%eax
f01010ca:	66 89 42 04          	mov    %ax,0x4(%edx)
f01010ce:	66 85 c0             	test   %ax,%ax
f01010d1:	74 02                	je     f01010d5 <page_decref+0x1f>
}
f01010d3:	c9                   	leave  
f01010d4:	c3                   	ret    
		page_free(pp);
f01010d5:	83 ec 0c             	sub    $0xc,%esp
f01010d8:	52                   	push   %edx
f01010d9:	e8 99 ff ff ff       	call   f0101077 <page_free>
f01010de:	83 c4 10             	add    $0x10,%esp
}
f01010e1:	eb f0                	jmp    f01010d3 <page_decref+0x1d>

f01010e3 <pgdir_walk>:
{
f01010e3:	f3 0f 1e fb          	endbr32 
f01010e7:	55                   	push   %ebp
f01010e8:	89 e5                	mov    %esp,%ebp
f01010ea:	56                   	push   %esi
f01010eb:	53                   	push   %ebx
f01010ec:	8b 75 0c             	mov    0xc(%ebp),%esi
    pde_t pde = pgdir[PDX(va)];
f01010ef:	89 f3                	mov    %esi,%ebx
f01010f1:	c1 eb 16             	shr    $0x16,%ebx
f01010f4:	c1 e3 02             	shl    $0x2,%ebx
f01010f7:	03 5d 08             	add    0x8(%ebp),%ebx
    if (!(pde & PTE_P)) {
f01010fa:	f6 03 01             	testb  $0x1,(%ebx)
f01010fd:	75 2d                	jne    f010112c <pgdir_walk+0x49>
        if (create) {
f01010ff:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101103:	74 67                	je     f010116c <pgdir_walk+0x89>
            struct PageInfo *pp = page_alloc(ALLOC_ZERO);
f0101105:	83 ec 0c             	sub    $0xc,%esp
f0101108:	6a 01                	push   $0x1
f010110a:	e8 ef fe ff ff       	call   f0100ffe <page_alloc>
            if (pp == NULL) {
f010110f:	83 c4 10             	add    $0x10,%esp
f0101112:	85 c0                	test   %eax,%eax
f0101114:	74 3a                	je     f0101150 <pgdir_walk+0x6d>
            pp->pp_ref += 1;
f0101116:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f010111b:	2b 05 90 be 3b f0    	sub    0xf03bbe90,%eax
f0101121:	c1 f8 03             	sar    $0x3,%eax
f0101124:	c1 e0 0c             	shl    $0xc,%eax
            pgdir[PDX(va)] = pa_pt | PTE_W | PTE_U | PTE_P;
f0101127:	83 c8 07             	or     $0x7,%eax
f010112a:	89 03                	mov    %eax,(%ebx)
    pte_t *pt = (pte_t *) PTE_ADDR(pgdir[PDX(va)]);
f010112c:	8b 13                	mov    (%ebx),%edx
f010112e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
    return KADDR((physaddr_t)(pt + PTX(va)));
f0101134:	c1 ee 0a             	shr    $0xa,%esi
f0101137:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f010113d:	8d 04 32             	lea    (%edx,%esi,1),%eax
	if (PGNUM(pa) >= npages)
f0101140:	c1 ea 0c             	shr    $0xc,%edx
f0101143:	3b 15 88 be 3b f0    	cmp    0xf03bbe88,%edx
f0101149:	73 0c                	jae    f0101157 <pgdir_walk+0x74>
	return (void *)(pa + KERNBASE);
f010114b:	2d 00 00 00 10       	sub    $0x10000000,%eax
}
f0101150:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101153:	5b                   	pop    %ebx
f0101154:	5e                   	pop    %esi
f0101155:	5d                   	pop    %ebp
f0101156:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101157:	50                   	push   %eax
f0101158:	68 24 6a 10 f0       	push   $0xf0106a24
f010115d:	68 df 01 00 00       	push   $0x1df
f0101162:	68 e5 78 10 f0       	push   $0xf01078e5
f0101167:	e8 d4 ee ff ff       	call   f0100040 <_panic>
            return NULL;
f010116c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101171:	eb dd                	jmp    f0101150 <pgdir_walk+0x6d>

f0101173 <boot_map_region>:
{
f0101173:	55                   	push   %ebp
f0101174:	89 e5                	mov    %esp,%ebp
f0101176:	57                   	push   %edi
f0101177:	56                   	push   %esi
f0101178:	53                   	push   %ebx
f0101179:	83 ec 1c             	sub    $0x1c,%esp
f010117c:	89 45 dc             	mov    %eax,-0x24(%ebp)
f010117f:	8b 5d 08             	mov    0x8(%ebp),%ebx
    uint64_t e_va = (uint64_t)va + (uint64_t)size;
f0101182:	89 d6                	mov    %edx,%esi
f0101184:	bf 00 00 00 00       	mov    $0x0,%edi
f0101189:	89 c8                	mov    %ecx,%eax
f010118b:	ba 00 00 00 00       	mov    $0x0,%edx
f0101190:	01 f0                	add    %esi,%eax
f0101192:	11 fa                	adc    %edi,%edx
f0101194:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101197:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    while (c_va < e_va) {
f010119a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010119d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01011a0:	39 c6                	cmp    %eax,%esi
f01011a2:	89 f9                	mov    %edi,%ecx
f01011a4:	19 d1                	sbb    %edx,%ecx
f01011a6:	73 33                	jae    f01011db <boot_map_region+0x68>
        pte_t *p_pte = pgdir_walk(pgdir, (void *)((uintptr_t)c_va), 1);
f01011a8:	83 ec 04             	sub    $0x4,%esp
f01011ab:	6a 01                	push   $0x1
f01011ad:	56                   	push   %esi
f01011ae:	ff 75 dc             	pushl  -0x24(%ebp)
f01011b1:	e8 2d ff ff ff       	call   f01010e3 <pgdir_walk>
f01011b6:	89 c2                	mov    %eax,%edx
        *p_pte = PTE_ADDR(c_pa) | perm | PTE_P;
f01011b8:	89 d8                	mov    %ebx,%eax
f01011ba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01011bf:	0b 45 0c             	or     0xc(%ebp),%eax
f01011c2:	83 c8 01             	or     $0x1,%eax
f01011c5:	89 02                	mov    %eax,(%edx)
        c_va += PGSIZE;
f01011c7:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01011cd:	83 d7 00             	adc    $0x0,%edi
        c_pa += PGSIZE;
f01011d0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01011d6:	83 c4 10             	add    $0x10,%esp
f01011d9:	eb bf                	jmp    f010119a <boot_map_region+0x27>
}
f01011db:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011de:	5b                   	pop    %ebx
f01011df:	5e                   	pop    %esi
f01011e0:	5f                   	pop    %edi
f01011e1:	5d                   	pop    %ebp
f01011e2:	c3                   	ret    

f01011e3 <page_lookup>:
{
f01011e3:	f3 0f 1e fb          	endbr32 
f01011e7:	55                   	push   %ebp
f01011e8:	89 e5                	mov    %esp,%ebp
f01011ea:	53                   	push   %ebx
f01011eb:	83 ec 08             	sub    $0x8,%esp
f01011ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
    pte_t *p_pte = pgdir_walk(pgdir, va, 0);
f01011f1:	6a 00                	push   $0x0
f01011f3:	ff 75 0c             	pushl  0xc(%ebp)
f01011f6:	ff 75 08             	pushl  0x8(%ebp)
f01011f9:	e8 e5 fe ff ff       	call   f01010e3 <pgdir_walk>
    if (pte_store != NULL) {
f01011fe:	83 c4 10             	add    $0x10,%esp
f0101201:	85 db                	test   %ebx,%ebx
f0101203:	74 02                	je     f0101207 <page_lookup+0x24>
        *pte_store = p_pte;
f0101205:	89 03                	mov    %eax,(%ebx)
    if (p_pte == NULL) {
f0101207:	85 c0                	test   %eax,%eax
f0101209:	74 1a                	je     f0101225 <page_lookup+0x42>
    if (!(*p_pte & PTE_P)) {
f010120b:	8b 00                	mov    (%eax),%eax
f010120d:	a8 01                	test   $0x1,%al
f010120f:	74 2d                	je     f010123e <page_lookup+0x5b>
f0101211:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101214:	39 05 88 be 3b f0    	cmp    %eax,0xf03bbe88
f010121a:	76 0e                	jbe    f010122a <page_lookup+0x47>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f010121c:	8b 15 90 be 3b f0    	mov    0xf03bbe90,%edx
f0101222:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f0101225:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101228:	c9                   	leave  
f0101229:	c3                   	ret    
		panic("pa2page called with invalid pa");
f010122a:	83 ec 04             	sub    $0x4,%esp
f010122d:	68 ac 70 10 f0       	push   $0xf01070ac
f0101232:	6a 51                	push   $0x51
f0101234:	68 ff 78 10 f0       	push   $0xf01078ff
f0101239:	e8 02 ee ff ff       	call   f0100040 <_panic>
        return NULL;
f010123e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101243:	eb e0                	jmp    f0101225 <page_lookup+0x42>

f0101245 <tlb_invalidate>:
{
f0101245:	f3 0f 1e fb          	endbr32 
f0101249:	55                   	push   %ebp
f010124a:	89 e5                	mov    %esp,%ebp
f010124c:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f010124f:	e8 36 51 00 00       	call   f010638a <cpunum>
f0101254:	6b c0 74             	imul   $0x74,%eax,%eax
f0101257:	83 b8 28 c0 3b f0 00 	cmpl   $0x0,-0xfc43fd8(%eax)
f010125e:	74 16                	je     f0101276 <tlb_invalidate+0x31>
f0101260:	e8 25 51 00 00       	call   f010638a <cpunum>
f0101265:	6b c0 74             	imul   $0x74,%eax,%eax
f0101268:	8b 80 28 c0 3b f0    	mov    -0xfc43fd8(%eax),%eax
f010126e:	8b 55 08             	mov    0x8(%ebp),%edx
f0101271:	39 50 60             	cmp    %edx,0x60(%eax)
f0101274:	75 06                	jne    f010127c <tlb_invalidate+0x37>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101276:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101279:	0f 01 38             	invlpg (%eax)
}
f010127c:	c9                   	leave  
f010127d:	c3                   	ret    

f010127e <page_remove>:
{
f010127e:	f3 0f 1e fb          	endbr32 
f0101282:	55                   	push   %ebp
f0101283:	89 e5                	mov    %esp,%ebp
f0101285:	56                   	push   %esi
f0101286:	53                   	push   %ebx
f0101287:	83 ec 14             	sub    $0x14,%esp
f010128a:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010128d:	8b 75 0c             	mov    0xc(%ebp),%esi
    struct PageInfo *pp = page_lookup(pgdir, va, &p_pte);
f0101290:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101293:	50                   	push   %eax
f0101294:	56                   	push   %esi
f0101295:	53                   	push   %ebx
f0101296:	e8 48 ff ff ff       	call   f01011e3 <page_lookup>
    if ( pp == NULL ) {
f010129b:	83 c4 10             	add    $0x10,%esp
f010129e:	85 c0                	test   %eax,%eax
f01012a0:	74 23                	je     f01012c5 <page_remove+0x47>
    if (p_pte != NULL) {
f01012a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01012a5:	85 d2                	test   %edx,%edx
f01012a7:	74 06                	je     f01012af <page_remove+0x31>
        *p_pte = 0;
f01012a9:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
    page_decref(pp);
f01012af:	83 ec 0c             	sub    $0xc,%esp
f01012b2:	50                   	push   %eax
f01012b3:	e8 fe fd ff ff       	call   f01010b6 <page_decref>
    tlb_invalidate(pgdir, va);
f01012b8:	83 c4 08             	add    $0x8,%esp
f01012bb:	56                   	push   %esi
f01012bc:	53                   	push   %ebx
f01012bd:	e8 83 ff ff ff       	call   f0101245 <tlb_invalidate>
f01012c2:	83 c4 10             	add    $0x10,%esp
}
f01012c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01012c8:	5b                   	pop    %ebx
f01012c9:	5e                   	pop    %esi
f01012ca:	5d                   	pop    %ebp
f01012cb:	c3                   	ret    

f01012cc <page_insert>:
{
f01012cc:	f3 0f 1e fb          	endbr32 
f01012d0:	55                   	push   %ebp
f01012d1:	89 e5                	mov    %esp,%ebp
f01012d3:	57                   	push   %edi
f01012d4:	56                   	push   %esi
f01012d5:	53                   	push   %ebx
f01012d6:	83 ec 10             	sub    $0x10,%esp
f01012d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01012dc:	8b 7d 10             	mov    0x10(%ebp),%edi
    pte_t *p_pte = pgdir_walk(pgdir, va, 1);
f01012df:	6a 01                	push   $0x1
f01012e1:	57                   	push   %edi
f01012e2:	ff 75 08             	pushl  0x8(%ebp)
f01012e5:	e8 f9 fd ff ff       	call   f01010e3 <pgdir_walk>
    if (p_pte == NULL) {
f01012ea:	83 c4 10             	add    $0x10,%esp
f01012ed:	85 c0                	test   %eax,%eax
f01012ef:	74 4e                	je     f010133f <page_insert+0x73>
f01012f1:	89 c6                	mov    %eax,%esi
    pte_t pte = *p_pte;
f01012f3:	8b 00                	mov    (%eax),%eax
    pp->pp_ref += 1;
f01012f5:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
    if (pte & PTE_P) {
f01012fa:	a8 01                	test   $0x1,%al
f01012fc:	75 30                	jne    f010132e <page_insert+0x62>
	return (pp - pages) << PGSHIFT;
f01012fe:	2b 1d 90 be 3b f0    	sub    0xf03bbe90,%ebx
f0101304:	c1 fb 03             	sar    $0x3,%ebx
f0101307:	c1 e3 0c             	shl    $0xc,%ebx
    *p_pte = (page2pa(pp) | perm | PTE_P);
f010130a:	0b 5d 14             	or     0x14(%ebp),%ebx
f010130d:	83 cb 01             	or     $0x1,%ebx
f0101310:	89 1e                	mov    %ebx,(%esi)
    tlb_invalidate(pgdir, va);
f0101312:	83 ec 08             	sub    $0x8,%esp
f0101315:	57                   	push   %edi
f0101316:	ff 75 08             	pushl  0x8(%ebp)
f0101319:	e8 27 ff ff ff       	call   f0101245 <tlb_invalidate>
	return 0;
f010131e:	83 c4 10             	add    $0x10,%esp
f0101321:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101326:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101329:	5b                   	pop    %ebx
f010132a:	5e                   	pop    %esi
f010132b:	5f                   	pop    %edi
f010132c:	5d                   	pop    %ebp
f010132d:	c3                   	ret    
        page_remove(pgdir, va);
f010132e:	83 ec 08             	sub    $0x8,%esp
f0101331:	57                   	push   %edi
f0101332:	ff 75 08             	pushl  0x8(%ebp)
f0101335:	e8 44 ff ff ff       	call   f010127e <page_remove>
f010133a:	83 c4 10             	add    $0x10,%esp
f010133d:	eb bf                	jmp    f01012fe <page_insert+0x32>
        return -E_NO_MEM;
f010133f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101344:	eb e0                	jmp    f0101326 <page_insert+0x5a>

f0101346 <mmio_map_region>:
{
f0101346:	f3 0f 1e fb          	endbr32 
f010134a:	55                   	push   %ebp
f010134b:	89 e5                	mov    %esp,%ebp
f010134d:	56                   	push   %esi
f010134e:	53                   	push   %ebx
f010134f:	8b 75 08             	mov    0x8(%ebp),%esi
    physaddr_t start_pa = ROUNDDOWN(pa, PGSIZE);
f0101352:	89 f0                	mov    %esi,%eax
f0101354:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    physaddr_t end_pa = ROUNDUP(pa + size, PGSIZE);
f0101359:	8b 55 0c             	mov    0xc(%ebp),%edx
f010135c:	8d 9c 16 ff 0f 00 00 	lea    0xfff(%esi,%edx,1),%ebx
    size_t alloc_size = end_pa - start_pa;
f0101363:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0101369:	29 c3                	sub    %eax,%ebx
    boot_map_region(kern_pgdir, base, alloc_size, start_pa,
f010136b:	83 ec 08             	sub    $0x8,%esp
f010136e:	6a 1b                	push   $0x1b
f0101370:	50                   	push   %eax
f0101371:	89 d9                	mov    %ebx,%ecx
f0101373:	8b 15 00 33 12 f0    	mov    0xf0123300,%edx
f0101379:	a1 8c be 3b f0       	mov    0xf03bbe8c,%eax
f010137e:	e8 f0 fd ff ff       	call   f0101173 <boot_map_region>
    uintptr_t ret = base + pa_offset;
f0101383:	8b 15 00 33 12 f0    	mov    0xf0123300,%edx
    base = base + alloc_size;
f0101389:	01 d3                	add    %edx,%ebx
f010138b:	89 1d 00 33 12 f0    	mov    %ebx,0xf0123300
    physaddr_t pa_offset = pa & 0xfff;
f0101391:	89 f0                	mov    %esi,%eax
f0101393:	25 ff 0f 00 00       	and    $0xfff,%eax
    uintptr_t ret = base + pa_offset;
f0101398:	01 d0                	add    %edx,%eax
}
f010139a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010139d:	5b                   	pop    %ebx
f010139e:	5e                   	pop    %esi
f010139f:	5d                   	pop    %ebp
f01013a0:	c3                   	ret    

f01013a1 <mem_init>:
{
f01013a1:	f3 0f 1e fb          	endbr32 
f01013a5:	55                   	push   %ebp
f01013a6:	89 e5                	mov    %esp,%ebp
f01013a8:	57                   	push   %edi
f01013a9:	56                   	push   %esi
f01013aa:	53                   	push   %ebx
f01013ab:	83 ec 3c             	sub    $0x3c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f01013ae:	b8 15 00 00 00       	mov    $0x15,%eax
f01013b3:	e8 78 f7 ff ff       	call   f0100b30 <nvram_read>
f01013b8:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f01013ba:	b8 17 00 00 00       	mov    $0x17,%eax
f01013bf:	e8 6c f7 ff ff       	call   f0100b30 <nvram_read>
f01013c4:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01013c6:	b8 34 00 00 00       	mov    $0x34,%eax
f01013cb:	e8 60 f7 ff ff       	call   f0100b30 <nvram_read>
	if (ext16mem)
f01013d0:	c1 e0 06             	shl    $0x6,%eax
f01013d3:	0f 84 de 00 00 00    	je     f01014b7 <mem_init+0x116>
		totalmem = 16 * 1024 + ext16mem;
f01013d9:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f01013de:	89 c2                	mov    %eax,%edx
f01013e0:	c1 ea 02             	shr    $0x2,%edx
f01013e3:	89 15 88 be 3b f0    	mov    %edx,0xf03bbe88
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013e9:	89 c2                	mov    %eax,%edx
f01013eb:	29 da                	sub    %ebx,%edx
f01013ed:	52                   	push   %edx
f01013ee:	53                   	push   %ebx
f01013ef:	50                   	push   %eax
f01013f0:	68 cc 70 10 f0       	push   $0xf01070cc
f01013f5:	e8 33 27 00 00       	call   f0103b2d <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01013fa:	b8 00 10 00 00       	mov    $0x1000,%eax
f01013ff:	e8 b8 f7 ff ff       	call   f0100bbc <boot_alloc>
f0101404:	a3 8c be 3b f0       	mov    %eax,0xf03bbe8c
	memset(kern_pgdir, 0, PGSIZE);
f0101409:	83 c4 0c             	add    $0xc,%esp
f010140c:	68 00 10 00 00       	push   $0x1000
f0101411:	6a 00                	push   $0x0
f0101413:	50                   	push   %eax
f0101414:	e8 53 49 00 00       	call   f0105d6c <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101419:	a1 8c be 3b f0       	mov    0xf03bbe8c,%eax
	if ((uint32_t)kva < KERNBASE)
f010141e:	83 c4 10             	add    $0x10,%esp
f0101421:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101426:	0f 86 9b 00 00 00    	jbe    f01014c7 <mem_init+0x126>
	return (physaddr_t)kva - KERNBASE;
f010142c:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101432:	83 ca 05             	or     $0x5,%edx
f0101435:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
    size_t alloc_size = ROUNDUP(sizeof(struct PageInfo) * npages, PGSIZE);
f010143b:	a1 88 be 3b f0       	mov    0xf03bbe88,%eax
f0101440:	8d 1c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ebx
f0101447:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    pages = (struct PageInfo *) boot_alloc(alloc_size);
f010144d:	89 d8                	mov    %ebx,%eax
f010144f:	e8 68 f7 ff ff       	call   f0100bbc <boot_alloc>
f0101454:	a3 90 be 3b f0       	mov    %eax,0xf03bbe90
    memset(pages, 0, alloc_size);
f0101459:	83 ec 04             	sub    $0x4,%esp
f010145c:	53                   	push   %ebx
f010145d:	6a 00                	push   $0x0
f010145f:	50                   	push   %eax
f0101460:	e8 07 49 00 00       	call   f0105d6c <memset>
    envs = (struct Env *) boot_alloc(alloc_size);
f0101465:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f010146a:	e8 4d f7 ff ff       	call   f0100bbc <boot_alloc>
f010146f:	a3 44 b2 3b f0       	mov    %eax,0xf03bb244
    memset(envs, 0, alloc_size);
f0101474:	83 c4 0c             	add    $0xc,%esp
f0101477:	68 00 f0 01 00       	push   $0x1f000
f010147c:	6a 00                	push   $0x0
f010147e:	50                   	push   %eax
f010147f:	e8 e8 48 00 00       	call   f0105d6c <memset>
	page_init();
f0101484:	e8 a9 fa ff ff       	call   f0100f32 <page_init>
	check_page_free_list(1);
f0101489:	b8 01 00 00 00       	mov    $0x1,%eax
f010148e:	e8 b1 f7 ff ff       	call   f0100c44 <check_page_free_list>
	if (!pages)
f0101493:	83 c4 10             	add    $0x10,%esp
f0101496:	83 3d 90 be 3b f0 00 	cmpl   $0x0,0xf03bbe90
f010149d:	74 3d                	je     f01014dc <mem_init+0x13b>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010149f:	a1 40 b2 3b f0       	mov    0xf03bb240,%eax
f01014a4:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f01014ab:	85 c0                	test   %eax,%eax
f01014ad:	74 44                	je     f01014f3 <mem_init+0x152>
		++nfree;
f01014af:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014b3:	8b 00                	mov    (%eax),%eax
f01014b5:	eb f4                	jmp    f01014ab <mem_init+0x10a>
		totalmem = 1 * 1024 + extmem;
f01014b7:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01014bd:	85 f6                	test   %esi,%esi
f01014bf:	0f 44 c3             	cmove  %ebx,%eax
f01014c2:	e9 17 ff ff ff       	jmp    f01013de <mem_init+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01014c7:	50                   	push   %eax
f01014c8:	68 48 6a 10 f0       	push   $0xf0106a48
f01014cd:	68 a5 00 00 00       	push   $0xa5
f01014d2:	68 e5 78 10 f0       	push   $0xf01078e5
f01014d7:	e8 64 eb ff ff       	call   f0100040 <_panic>
		panic("'pages' is a null pointer!");
f01014dc:	83 ec 04             	sub    $0x4,%esp
f01014df:	68 d3 79 10 f0       	push   $0xf01079d3
f01014e4:	68 49 03 00 00       	push   $0x349
f01014e9:	68 e5 78 10 f0       	push   $0xf01078e5
f01014ee:	e8 4d eb ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f01014f3:	83 ec 0c             	sub    $0xc,%esp
f01014f6:	6a 00                	push   $0x0
f01014f8:	e8 01 fb ff ff       	call   f0100ffe <page_alloc>
f01014fd:	89 c3                	mov    %eax,%ebx
f01014ff:	83 c4 10             	add    $0x10,%esp
f0101502:	85 c0                	test   %eax,%eax
f0101504:	0f 84 11 02 00 00    	je     f010171b <mem_init+0x37a>
	assert((pp1 = page_alloc(0)));
f010150a:	83 ec 0c             	sub    $0xc,%esp
f010150d:	6a 00                	push   $0x0
f010150f:	e8 ea fa ff ff       	call   f0100ffe <page_alloc>
f0101514:	89 c6                	mov    %eax,%esi
f0101516:	83 c4 10             	add    $0x10,%esp
f0101519:	85 c0                	test   %eax,%eax
f010151b:	0f 84 13 02 00 00    	je     f0101734 <mem_init+0x393>
	assert((pp2 = page_alloc(0)));
f0101521:	83 ec 0c             	sub    $0xc,%esp
f0101524:	6a 00                	push   $0x0
f0101526:	e8 d3 fa ff ff       	call   f0100ffe <page_alloc>
f010152b:	89 c7                	mov    %eax,%edi
f010152d:	83 c4 10             	add    $0x10,%esp
f0101530:	85 c0                	test   %eax,%eax
f0101532:	0f 84 15 02 00 00    	je     f010174d <mem_init+0x3ac>
	assert(pp1 && pp1 != pp0);
f0101538:	39 f3                	cmp    %esi,%ebx
f010153a:	0f 84 26 02 00 00    	je     f0101766 <mem_init+0x3c5>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101540:	39 c3                	cmp    %eax,%ebx
f0101542:	0f 84 37 02 00 00    	je     f010177f <mem_init+0x3de>
f0101548:	39 c6                	cmp    %eax,%esi
f010154a:	0f 84 2f 02 00 00    	je     f010177f <mem_init+0x3de>
	return (pp - pages) << PGSHIFT;
f0101550:	8b 0d 90 be 3b f0    	mov    0xf03bbe90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101556:	8b 15 88 be 3b f0    	mov    0xf03bbe88,%edx
f010155c:	c1 e2 0c             	shl    $0xc,%edx
f010155f:	89 d8                	mov    %ebx,%eax
f0101561:	29 c8                	sub    %ecx,%eax
f0101563:	c1 f8 03             	sar    $0x3,%eax
f0101566:	c1 e0 0c             	shl    $0xc,%eax
f0101569:	39 d0                	cmp    %edx,%eax
f010156b:	0f 83 27 02 00 00    	jae    f0101798 <mem_init+0x3f7>
f0101571:	89 f0                	mov    %esi,%eax
f0101573:	29 c8                	sub    %ecx,%eax
f0101575:	c1 f8 03             	sar    $0x3,%eax
f0101578:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f010157b:	39 c2                	cmp    %eax,%edx
f010157d:	0f 86 2e 02 00 00    	jbe    f01017b1 <mem_init+0x410>
f0101583:	89 f8                	mov    %edi,%eax
f0101585:	29 c8                	sub    %ecx,%eax
f0101587:	c1 f8 03             	sar    $0x3,%eax
f010158a:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f010158d:	39 c2                	cmp    %eax,%edx
f010158f:	0f 86 35 02 00 00    	jbe    f01017ca <mem_init+0x429>
	fl = page_free_list;
f0101595:	a1 40 b2 3b f0       	mov    0xf03bb240,%eax
f010159a:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010159d:	c7 05 40 b2 3b f0 00 	movl   $0x0,0xf03bb240
f01015a4:	00 00 00 
	assert(!page_alloc(0));
f01015a7:	83 ec 0c             	sub    $0xc,%esp
f01015aa:	6a 00                	push   $0x0
f01015ac:	e8 4d fa ff ff       	call   f0100ffe <page_alloc>
f01015b1:	83 c4 10             	add    $0x10,%esp
f01015b4:	85 c0                	test   %eax,%eax
f01015b6:	0f 85 27 02 00 00    	jne    f01017e3 <mem_init+0x442>
	page_free(pp0);
f01015bc:	83 ec 0c             	sub    $0xc,%esp
f01015bf:	53                   	push   %ebx
f01015c0:	e8 b2 fa ff ff       	call   f0101077 <page_free>
	page_free(pp1);
f01015c5:	89 34 24             	mov    %esi,(%esp)
f01015c8:	e8 aa fa ff ff       	call   f0101077 <page_free>
	page_free(pp2);
f01015cd:	89 3c 24             	mov    %edi,(%esp)
f01015d0:	e8 a2 fa ff ff       	call   f0101077 <page_free>
	assert((pp0 = page_alloc(0)));
f01015d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015dc:	e8 1d fa ff ff       	call   f0100ffe <page_alloc>
f01015e1:	89 c3                	mov    %eax,%ebx
f01015e3:	83 c4 10             	add    $0x10,%esp
f01015e6:	85 c0                	test   %eax,%eax
f01015e8:	0f 84 0e 02 00 00    	je     f01017fc <mem_init+0x45b>
	assert((pp1 = page_alloc(0)));
f01015ee:	83 ec 0c             	sub    $0xc,%esp
f01015f1:	6a 00                	push   $0x0
f01015f3:	e8 06 fa ff ff       	call   f0100ffe <page_alloc>
f01015f8:	89 c6                	mov    %eax,%esi
f01015fa:	83 c4 10             	add    $0x10,%esp
f01015fd:	85 c0                	test   %eax,%eax
f01015ff:	0f 84 10 02 00 00    	je     f0101815 <mem_init+0x474>
	assert((pp2 = page_alloc(0)));
f0101605:	83 ec 0c             	sub    $0xc,%esp
f0101608:	6a 00                	push   $0x0
f010160a:	e8 ef f9 ff ff       	call   f0100ffe <page_alloc>
f010160f:	89 c7                	mov    %eax,%edi
f0101611:	83 c4 10             	add    $0x10,%esp
f0101614:	85 c0                	test   %eax,%eax
f0101616:	0f 84 12 02 00 00    	je     f010182e <mem_init+0x48d>
	assert(pp1 && pp1 != pp0);
f010161c:	39 f3                	cmp    %esi,%ebx
f010161e:	0f 84 23 02 00 00    	je     f0101847 <mem_init+0x4a6>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101624:	39 c6                	cmp    %eax,%esi
f0101626:	0f 84 34 02 00 00    	je     f0101860 <mem_init+0x4bf>
f010162c:	39 c3                	cmp    %eax,%ebx
f010162e:	0f 84 2c 02 00 00    	je     f0101860 <mem_init+0x4bf>
	assert(!page_alloc(0));
f0101634:	83 ec 0c             	sub    $0xc,%esp
f0101637:	6a 00                	push   $0x0
f0101639:	e8 c0 f9 ff ff       	call   f0100ffe <page_alloc>
f010163e:	83 c4 10             	add    $0x10,%esp
f0101641:	85 c0                	test   %eax,%eax
f0101643:	0f 85 30 02 00 00    	jne    f0101879 <mem_init+0x4d8>
f0101649:	89 d8                	mov    %ebx,%eax
f010164b:	2b 05 90 be 3b f0    	sub    0xf03bbe90,%eax
f0101651:	c1 f8 03             	sar    $0x3,%eax
f0101654:	89 c2                	mov    %eax,%edx
f0101656:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101659:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010165e:	3b 05 88 be 3b f0    	cmp    0xf03bbe88,%eax
f0101664:	0f 83 28 02 00 00    	jae    f0101892 <mem_init+0x4f1>
	memset(page2kva(pp0), 1, PGSIZE);
f010166a:	83 ec 04             	sub    $0x4,%esp
f010166d:	68 00 10 00 00       	push   $0x1000
f0101672:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101674:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010167a:	52                   	push   %edx
f010167b:	e8 ec 46 00 00       	call   f0105d6c <memset>
	page_free(pp0);
f0101680:	89 1c 24             	mov    %ebx,(%esp)
f0101683:	e8 ef f9 ff ff       	call   f0101077 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101688:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010168f:	e8 6a f9 ff ff       	call   f0100ffe <page_alloc>
f0101694:	83 c4 10             	add    $0x10,%esp
f0101697:	85 c0                	test   %eax,%eax
f0101699:	0f 84 05 02 00 00    	je     f01018a4 <mem_init+0x503>
	assert(pp && pp0 == pp);
f010169f:	39 c3                	cmp    %eax,%ebx
f01016a1:	0f 85 16 02 00 00    	jne    f01018bd <mem_init+0x51c>
	return (pp - pages) << PGSHIFT;
f01016a7:	2b 05 90 be 3b f0    	sub    0xf03bbe90,%eax
f01016ad:	c1 f8 03             	sar    $0x3,%eax
f01016b0:	89 c2                	mov    %eax,%edx
f01016b2:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01016b5:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01016ba:	3b 05 88 be 3b f0    	cmp    0xf03bbe88,%eax
f01016c0:	0f 83 10 02 00 00    	jae    f01018d6 <mem_init+0x535>
	return (void *)(pa + KERNBASE);
f01016c6:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f01016cc:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f01016d2:	80 38 00             	cmpb   $0x0,(%eax)
f01016d5:	0f 85 0d 02 00 00    	jne    f01018e8 <mem_init+0x547>
f01016db:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f01016de:	39 d0                	cmp    %edx,%eax
f01016e0:	75 f0                	jne    f01016d2 <mem_init+0x331>
	page_free_list = fl;
f01016e2:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01016e5:	a3 40 b2 3b f0       	mov    %eax,0xf03bb240
	page_free(pp0);
f01016ea:	83 ec 0c             	sub    $0xc,%esp
f01016ed:	53                   	push   %ebx
f01016ee:	e8 84 f9 ff ff       	call   f0101077 <page_free>
	page_free(pp1);
f01016f3:	89 34 24             	mov    %esi,(%esp)
f01016f6:	e8 7c f9 ff ff       	call   f0101077 <page_free>
	page_free(pp2);
f01016fb:	89 3c 24             	mov    %edi,(%esp)
f01016fe:	e8 74 f9 ff ff       	call   f0101077 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101703:	a1 40 b2 3b f0       	mov    0xf03bb240,%eax
f0101708:	83 c4 10             	add    $0x10,%esp
f010170b:	85 c0                	test   %eax,%eax
f010170d:	0f 84 ee 01 00 00    	je     f0101901 <mem_init+0x560>
		--nfree;
f0101713:	83 6d d4 01          	subl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101717:	8b 00                	mov    (%eax),%eax
f0101719:	eb f0                	jmp    f010170b <mem_init+0x36a>
	assert((pp0 = page_alloc(0)));
f010171b:	68 ee 79 10 f0       	push   $0xf01079ee
f0101720:	68 19 79 10 f0       	push   $0xf0107919
f0101725:	68 51 03 00 00       	push   $0x351
f010172a:	68 e5 78 10 f0       	push   $0xf01078e5
f010172f:	e8 0c e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101734:	68 04 7a 10 f0       	push   $0xf0107a04
f0101739:	68 19 79 10 f0       	push   $0xf0107919
f010173e:	68 52 03 00 00       	push   $0x352
f0101743:	68 e5 78 10 f0       	push   $0xf01078e5
f0101748:	e8 f3 e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010174d:	68 1a 7a 10 f0       	push   $0xf0107a1a
f0101752:	68 19 79 10 f0       	push   $0xf0107919
f0101757:	68 53 03 00 00       	push   $0x353
f010175c:	68 e5 78 10 f0       	push   $0xf01078e5
f0101761:	e8 da e8 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101766:	68 30 7a 10 f0       	push   $0xf0107a30
f010176b:	68 19 79 10 f0       	push   $0xf0107919
f0101770:	68 56 03 00 00       	push   $0x356
f0101775:	68 e5 78 10 f0       	push   $0xf01078e5
f010177a:	e8 c1 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010177f:	68 08 71 10 f0       	push   $0xf0107108
f0101784:	68 19 79 10 f0       	push   $0xf0107919
f0101789:	68 57 03 00 00       	push   $0x357
f010178e:	68 e5 78 10 f0       	push   $0xf01078e5
f0101793:	e8 a8 e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101798:	68 42 7a 10 f0       	push   $0xf0107a42
f010179d:	68 19 79 10 f0       	push   $0xf0107919
f01017a2:	68 58 03 00 00       	push   $0x358
f01017a7:	68 e5 78 10 f0       	push   $0xf01078e5
f01017ac:	e8 8f e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01017b1:	68 5f 7a 10 f0       	push   $0xf0107a5f
f01017b6:	68 19 79 10 f0       	push   $0xf0107919
f01017bb:	68 59 03 00 00       	push   $0x359
f01017c0:	68 e5 78 10 f0       	push   $0xf01078e5
f01017c5:	e8 76 e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01017ca:	68 7c 7a 10 f0       	push   $0xf0107a7c
f01017cf:	68 19 79 10 f0       	push   $0xf0107919
f01017d4:	68 5a 03 00 00       	push   $0x35a
f01017d9:	68 e5 78 10 f0       	push   $0xf01078e5
f01017de:	e8 5d e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01017e3:	68 99 7a 10 f0       	push   $0xf0107a99
f01017e8:	68 19 79 10 f0       	push   $0xf0107919
f01017ed:	68 61 03 00 00       	push   $0x361
f01017f2:	68 e5 78 10 f0       	push   $0xf01078e5
f01017f7:	e8 44 e8 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f01017fc:	68 ee 79 10 f0       	push   $0xf01079ee
f0101801:	68 19 79 10 f0       	push   $0xf0107919
f0101806:	68 68 03 00 00       	push   $0x368
f010180b:	68 e5 78 10 f0       	push   $0xf01078e5
f0101810:	e8 2b e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101815:	68 04 7a 10 f0       	push   $0xf0107a04
f010181a:	68 19 79 10 f0       	push   $0xf0107919
f010181f:	68 69 03 00 00       	push   $0x369
f0101824:	68 e5 78 10 f0       	push   $0xf01078e5
f0101829:	e8 12 e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010182e:	68 1a 7a 10 f0       	push   $0xf0107a1a
f0101833:	68 19 79 10 f0       	push   $0xf0107919
f0101838:	68 6a 03 00 00       	push   $0x36a
f010183d:	68 e5 78 10 f0       	push   $0xf01078e5
f0101842:	e8 f9 e7 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101847:	68 30 7a 10 f0       	push   $0xf0107a30
f010184c:	68 19 79 10 f0       	push   $0xf0107919
f0101851:	68 6c 03 00 00       	push   $0x36c
f0101856:	68 e5 78 10 f0       	push   $0xf01078e5
f010185b:	e8 e0 e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101860:	68 08 71 10 f0       	push   $0xf0107108
f0101865:	68 19 79 10 f0       	push   $0xf0107919
f010186a:	68 6d 03 00 00       	push   $0x36d
f010186f:	68 e5 78 10 f0       	push   $0xf01078e5
f0101874:	e8 c7 e7 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101879:	68 99 7a 10 f0       	push   $0xf0107a99
f010187e:	68 19 79 10 f0       	push   $0xf0107919
f0101883:	68 6e 03 00 00       	push   $0x36e
f0101888:	68 e5 78 10 f0       	push   $0xf01078e5
f010188d:	e8 ae e7 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101892:	52                   	push   %edx
f0101893:	68 24 6a 10 f0       	push   $0xf0106a24
f0101898:	6a 58                	push   $0x58
f010189a:	68 ff 78 10 f0       	push   $0xf01078ff
f010189f:	e8 9c e7 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01018a4:	68 a8 7a 10 f0       	push   $0xf0107aa8
f01018a9:	68 19 79 10 f0       	push   $0xf0107919
f01018ae:	68 73 03 00 00       	push   $0x373
f01018b3:	68 e5 78 10 f0       	push   $0xf01078e5
f01018b8:	e8 83 e7 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01018bd:	68 c6 7a 10 f0       	push   $0xf0107ac6
f01018c2:	68 19 79 10 f0       	push   $0xf0107919
f01018c7:	68 74 03 00 00       	push   $0x374
f01018cc:	68 e5 78 10 f0       	push   $0xf01078e5
f01018d1:	e8 6a e7 ff ff       	call   f0100040 <_panic>
f01018d6:	52                   	push   %edx
f01018d7:	68 24 6a 10 f0       	push   $0xf0106a24
f01018dc:	6a 58                	push   $0x58
f01018de:	68 ff 78 10 f0       	push   $0xf01078ff
f01018e3:	e8 58 e7 ff ff       	call   f0100040 <_panic>
		assert(c[i] == 0);
f01018e8:	68 d6 7a 10 f0       	push   $0xf0107ad6
f01018ed:	68 19 79 10 f0       	push   $0xf0107919
f01018f2:	68 77 03 00 00       	push   $0x377
f01018f7:	68 e5 78 10 f0       	push   $0xf01078e5
f01018fc:	e8 3f e7 ff ff       	call   f0100040 <_panic>
	assert(nfree == 0);
f0101901:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0101905:	0f 85 e4 09 00 00    	jne    f01022ef <mem_init+0xf4e>
	cprintf("check_page_alloc() succeeded!\n");
f010190b:	83 ec 0c             	sub    $0xc,%esp
f010190e:	68 28 71 10 f0       	push   $0xf0107128
f0101913:	e8 15 22 00 00       	call   f0103b2d <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101918:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010191f:	e8 da f6 ff ff       	call   f0100ffe <page_alloc>
f0101924:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101927:	83 c4 10             	add    $0x10,%esp
f010192a:	85 c0                	test   %eax,%eax
f010192c:	0f 84 d6 09 00 00    	je     f0102308 <mem_init+0xf67>
	assert((pp1 = page_alloc(0)));
f0101932:	83 ec 0c             	sub    $0xc,%esp
f0101935:	6a 00                	push   $0x0
f0101937:	e8 c2 f6 ff ff       	call   f0100ffe <page_alloc>
f010193c:	89 c7                	mov    %eax,%edi
f010193e:	83 c4 10             	add    $0x10,%esp
f0101941:	85 c0                	test   %eax,%eax
f0101943:	0f 84 d8 09 00 00    	je     f0102321 <mem_init+0xf80>
	assert((pp2 = page_alloc(0)));
f0101949:	83 ec 0c             	sub    $0xc,%esp
f010194c:	6a 00                	push   $0x0
f010194e:	e8 ab f6 ff ff       	call   f0100ffe <page_alloc>
f0101953:	89 c3                	mov    %eax,%ebx
f0101955:	83 c4 10             	add    $0x10,%esp
f0101958:	85 c0                	test   %eax,%eax
f010195a:	0f 84 da 09 00 00    	je     f010233a <mem_init+0xf99>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101960:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f0101963:	0f 84 ea 09 00 00    	je     f0102353 <mem_init+0xfb2>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101969:	39 c7                	cmp    %eax,%edi
f010196b:	0f 84 fb 09 00 00    	je     f010236c <mem_init+0xfcb>
f0101971:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101974:	0f 84 f2 09 00 00    	je     f010236c <mem_init+0xfcb>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010197a:	a1 40 b2 3b f0       	mov    0xf03bb240,%eax
f010197f:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f0101982:	c7 05 40 b2 3b f0 00 	movl   $0x0,0xf03bb240
f0101989:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010198c:	83 ec 0c             	sub    $0xc,%esp
f010198f:	6a 00                	push   $0x0
f0101991:	e8 68 f6 ff ff       	call   f0100ffe <page_alloc>
f0101996:	83 c4 10             	add    $0x10,%esp
f0101999:	85 c0                	test   %eax,%eax
f010199b:	0f 85 e4 09 00 00    	jne    f0102385 <mem_init+0xfe4>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01019a1:	83 ec 04             	sub    $0x4,%esp
f01019a4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01019a7:	50                   	push   %eax
f01019a8:	6a 00                	push   $0x0
f01019aa:	ff 35 8c be 3b f0    	pushl  0xf03bbe8c
f01019b0:	e8 2e f8 ff ff       	call   f01011e3 <page_lookup>
f01019b5:	83 c4 10             	add    $0x10,%esp
f01019b8:	85 c0                	test   %eax,%eax
f01019ba:	0f 85 de 09 00 00    	jne    f010239e <mem_init+0xffd>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01019c0:	6a 02                	push   $0x2
f01019c2:	6a 00                	push   $0x0
f01019c4:	57                   	push   %edi
f01019c5:	ff 35 8c be 3b f0    	pushl  0xf03bbe8c
f01019cb:	e8 fc f8 ff ff       	call   f01012cc <page_insert>
f01019d0:	83 c4 10             	add    $0x10,%esp
f01019d3:	85 c0                	test   %eax,%eax
f01019d5:	0f 89 dc 09 00 00    	jns    f01023b7 <mem_init+0x1016>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01019db:	83 ec 0c             	sub    $0xc,%esp
f01019de:	ff 75 d4             	pushl  -0x2c(%ebp)
f01019e1:	e8 91 f6 ff ff       	call   f0101077 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01019e6:	6a 02                	push   $0x2
f01019e8:	6a 00                	push   $0x0
f01019ea:	57                   	push   %edi
f01019eb:	ff 35 8c be 3b f0    	pushl  0xf03bbe8c
f01019f1:	e8 d6 f8 ff ff       	call   f01012cc <page_insert>
f01019f6:	83 c4 20             	add    $0x20,%esp
f01019f9:	85 c0                	test   %eax,%eax
f01019fb:	0f 85 cf 09 00 00    	jne    f01023d0 <mem_init+0x102f>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101a01:	8b 35 8c be 3b f0    	mov    0xf03bbe8c,%esi
	return (pp - pages) << PGSHIFT;
f0101a07:	8b 0d 90 be 3b f0    	mov    0xf03bbe90,%ecx
f0101a0d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0101a10:	8b 16                	mov    (%esi),%edx
f0101a12:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101a18:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a1b:	29 c8                	sub    %ecx,%eax
f0101a1d:	c1 f8 03             	sar    $0x3,%eax
f0101a20:	c1 e0 0c             	shl    $0xc,%eax
f0101a23:	39 c2                	cmp    %eax,%edx
f0101a25:	0f 85 be 09 00 00    	jne    f01023e9 <mem_init+0x1048>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101a2b:	ba 00 00 00 00       	mov    $0x0,%edx
f0101a30:	89 f0                	mov    %esi,%eax
f0101a32:	e8 22 f1 ff ff       	call   f0100b59 <check_va2pa>
f0101a37:	89 c2                	mov    %eax,%edx
f0101a39:	89 f8                	mov    %edi,%eax
f0101a3b:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101a3e:	c1 f8 03             	sar    $0x3,%eax
f0101a41:	c1 e0 0c             	shl    $0xc,%eax
f0101a44:	39 c2                	cmp    %eax,%edx
f0101a46:	0f 85 b6 09 00 00    	jne    f0102402 <mem_init+0x1061>
	assert(pp1->pp_ref == 1);
f0101a4c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101a51:	0f 85 c4 09 00 00    	jne    f010241b <mem_init+0x107a>
	assert(pp0->pp_ref == 1);
f0101a57:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a5a:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101a5f:	0f 85 cf 09 00 00    	jne    f0102434 <mem_init+0x1093>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a65:	6a 02                	push   $0x2
f0101a67:	68 00 10 00 00       	push   $0x1000
f0101a6c:	53                   	push   %ebx
f0101a6d:	56                   	push   %esi
f0101a6e:	e8 59 f8 ff ff       	call   f01012cc <page_insert>
f0101a73:	83 c4 10             	add    $0x10,%esp
f0101a76:	85 c0                	test   %eax,%eax
f0101a78:	0f 85 cf 09 00 00    	jne    f010244d <mem_init+0x10ac>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a7e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a83:	a1 8c be 3b f0       	mov    0xf03bbe8c,%eax
f0101a88:	e8 cc f0 ff ff       	call   f0100b59 <check_va2pa>
f0101a8d:	89 c2                	mov    %eax,%edx
f0101a8f:	89 d8                	mov    %ebx,%eax
f0101a91:	2b 05 90 be 3b f0    	sub    0xf03bbe90,%eax
f0101a97:	c1 f8 03             	sar    $0x3,%eax
f0101a9a:	c1 e0 0c             	shl    $0xc,%eax
f0101a9d:	39 c2                	cmp    %eax,%edx
f0101a9f:	0f 85 c1 09 00 00    	jne    f0102466 <mem_init+0x10c5>
	assert(pp2->pp_ref == 1);
f0101aa5:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101aaa:	0f 85 cf 09 00 00    	jne    f010247f <mem_init+0x10de>

	// should be no free memory
	assert(!page_alloc(0));
f0101ab0:	83 ec 0c             	sub    $0xc,%esp
f0101ab3:	6a 00                	push   $0x0
f0101ab5:	e8 44 f5 ff ff       	call   f0100ffe <page_alloc>
f0101aba:	83 c4 10             	add    $0x10,%esp
f0101abd:	85 c0                	test   %eax,%eax
f0101abf:	0f 85 d3 09 00 00    	jne    f0102498 <mem_init+0x10f7>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ac5:	6a 02                	push   $0x2
f0101ac7:	68 00 10 00 00       	push   $0x1000
f0101acc:	53                   	push   %ebx
f0101acd:	ff 35 8c be 3b f0    	pushl  0xf03bbe8c
f0101ad3:	e8 f4 f7 ff ff       	call   f01012cc <page_insert>
f0101ad8:	83 c4 10             	add    $0x10,%esp
f0101adb:	85 c0                	test   %eax,%eax
f0101add:	0f 85 ce 09 00 00    	jne    f01024b1 <mem_init+0x1110>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ae3:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ae8:	a1 8c be 3b f0       	mov    0xf03bbe8c,%eax
f0101aed:	e8 67 f0 ff ff       	call   f0100b59 <check_va2pa>
f0101af2:	89 c2                	mov    %eax,%edx
f0101af4:	89 d8                	mov    %ebx,%eax
f0101af6:	2b 05 90 be 3b f0    	sub    0xf03bbe90,%eax
f0101afc:	c1 f8 03             	sar    $0x3,%eax
f0101aff:	c1 e0 0c             	shl    $0xc,%eax
f0101b02:	39 c2                	cmp    %eax,%edx
f0101b04:	0f 85 c0 09 00 00    	jne    f01024ca <mem_init+0x1129>
	assert(pp2->pp_ref == 1);
f0101b0a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101b0f:	0f 85 ce 09 00 00    	jne    f01024e3 <mem_init+0x1142>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101b15:	83 ec 0c             	sub    $0xc,%esp
f0101b18:	6a 00                	push   $0x0
f0101b1a:	e8 df f4 ff ff       	call   f0100ffe <page_alloc>
f0101b1f:	83 c4 10             	add    $0x10,%esp
f0101b22:	85 c0                	test   %eax,%eax
f0101b24:	0f 85 d2 09 00 00    	jne    f01024fc <mem_init+0x115b>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101b2a:	8b 0d 8c be 3b f0    	mov    0xf03bbe8c,%ecx
f0101b30:	8b 01                	mov    (%ecx),%eax
f0101b32:	89 c2                	mov    %eax,%edx
f0101b34:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101b3a:	c1 e8 0c             	shr    $0xc,%eax
f0101b3d:	3b 05 88 be 3b f0    	cmp    0xf03bbe88,%eax
f0101b43:	0f 83 cc 09 00 00    	jae    f0102515 <mem_init+0x1174>
	return (void *)(pa + KERNBASE);
f0101b49:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101b4f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101b52:	83 ec 04             	sub    $0x4,%esp
f0101b55:	6a 00                	push   $0x0
f0101b57:	68 00 10 00 00       	push   $0x1000
f0101b5c:	51                   	push   %ecx
f0101b5d:	e8 81 f5 ff ff       	call   f01010e3 <pgdir_walk>
f0101b62:	89 c2                	mov    %eax,%edx
f0101b64:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101b67:	83 c0 04             	add    $0x4,%eax
f0101b6a:	83 c4 10             	add    $0x10,%esp
f0101b6d:	39 d0                	cmp    %edx,%eax
f0101b6f:	0f 85 b5 09 00 00    	jne    f010252a <mem_init+0x1189>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101b75:	6a 06                	push   $0x6
f0101b77:	68 00 10 00 00       	push   $0x1000
f0101b7c:	53                   	push   %ebx
f0101b7d:	ff 35 8c be 3b f0    	pushl  0xf03bbe8c
f0101b83:	e8 44 f7 ff ff       	call   f01012cc <page_insert>
f0101b88:	83 c4 10             	add    $0x10,%esp
f0101b8b:	85 c0                	test   %eax,%eax
f0101b8d:	0f 85 b0 09 00 00    	jne    f0102543 <mem_init+0x11a2>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b93:	8b 35 8c be 3b f0    	mov    0xf03bbe8c,%esi
f0101b99:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b9e:	89 f0                	mov    %esi,%eax
f0101ba0:	e8 b4 ef ff ff       	call   f0100b59 <check_va2pa>
f0101ba5:	89 c2                	mov    %eax,%edx
	return (pp - pages) << PGSHIFT;
f0101ba7:	89 d8                	mov    %ebx,%eax
f0101ba9:	2b 05 90 be 3b f0    	sub    0xf03bbe90,%eax
f0101baf:	c1 f8 03             	sar    $0x3,%eax
f0101bb2:	c1 e0 0c             	shl    $0xc,%eax
f0101bb5:	39 c2                	cmp    %eax,%edx
f0101bb7:	0f 85 9f 09 00 00    	jne    f010255c <mem_init+0x11bb>
	assert(pp2->pp_ref == 1);
f0101bbd:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101bc2:	0f 85 ad 09 00 00    	jne    f0102575 <mem_init+0x11d4>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101bc8:	83 ec 04             	sub    $0x4,%esp
f0101bcb:	6a 00                	push   $0x0
f0101bcd:	68 00 10 00 00       	push   $0x1000
f0101bd2:	56                   	push   %esi
f0101bd3:	e8 0b f5 ff ff       	call   f01010e3 <pgdir_walk>
f0101bd8:	83 c4 10             	add    $0x10,%esp
f0101bdb:	f6 00 04             	testb  $0x4,(%eax)
f0101bde:	0f 84 aa 09 00 00    	je     f010258e <mem_init+0x11ed>
	assert(kern_pgdir[0] & PTE_U);
f0101be4:	a1 8c be 3b f0       	mov    0xf03bbe8c,%eax
f0101be9:	f6 00 04             	testb  $0x4,(%eax)
f0101bec:	0f 84 b5 09 00 00    	je     f01025a7 <mem_init+0x1206>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101bf2:	6a 02                	push   $0x2
f0101bf4:	68 00 10 00 00       	push   $0x1000
f0101bf9:	53                   	push   %ebx
f0101bfa:	50                   	push   %eax
f0101bfb:	e8 cc f6 ff ff       	call   f01012cc <page_insert>
f0101c00:	83 c4 10             	add    $0x10,%esp
f0101c03:	85 c0                	test   %eax,%eax
f0101c05:	0f 85 b5 09 00 00    	jne    f01025c0 <mem_init+0x121f>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101c0b:	83 ec 04             	sub    $0x4,%esp
f0101c0e:	6a 00                	push   $0x0
f0101c10:	68 00 10 00 00       	push   $0x1000
f0101c15:	ff 35 8c be 3b f0    	pushl  0xf03bbe8c
f0101c1b:	e8 c3 f4 ff ff       	call   f01010e3 <pgdir_walk>
f0101c20:	83 c4 10             	add    $0x10,%esp
f0101c23:	f6 00 02             	testb  $0x2,(%eax)
f0101c26:	0f 84 ad 09 00 00    	je     f01025d9 <mem_init+0x1238>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c2c:	83 ec 04             	sub    $0x4,%esp
f0101c2f:	6a 00                	push   $0x0
f0101c31:	68 00 10 00 00       	push   $0x1000
f0101c36:	ff 35 8c be 3b f0    	pushl  0xf03bbe8c
f0101c3c:	e8 a2 f4 ff ff       	call   f01010e3 <pgdir_walk>
f0101c41:	83 c4 10             	add    $0x10,%esp
f0101c44:	f6 00 04             	testb  $0x4,(%eax)
f0101c47:	0f 85 a5 09 00 00    	jne    f01025f2 <mem_init+0x1251>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101c4d:	6a 02                	push   $0x2
f0101c4f:	68 00 00 40 00       	push   $0x400000
f0101c54:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101c57:	ff 35 8c be 3b f0    	pushl  0xf03bbe8c
f0101c5d:	e8 6a f6 ff ff       	call   f01012cc <page_insert>
f0101c62:	83 c4 10             	add    $0x10,%esp
f0101c65:	85 c0                	test   %eax,%eax
f0101c67:	0f 89 9e 09 00 00    	jns    f010260b <mem_init+0x126a>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101c6d:	6a 02                	push   $0x2
f0101c6f:	68 00 10 00 00       	push   $0x1000
f0101c74:	57                   	push   %edi
f0101c75:	ff 35 8c be 3b f0    	pushl  0xf03bbe8c
f0101c7b:	e8 4c f6 ff ff       	call   f01012cc <page_insert>
f0101c80:	83 c4 10             	add    $0x10,%esp
f0101c83:	85 c0                	test   %eax,%eax
f0101c85:	0f 85 99 09 00 00    	jne    f0102624 <mem_init+0x1283>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c8b:	83 ec 04             	sub    $0x4,%esp
f0101c8e:	6a 00                	push   $0x0
f0101c90:	68 00 10 00 00       	push   $0x1000
f0101c95:	ff 35 8c be 3b f0    	pushl  0xf03bbe8c
f0101c9b:	e8 43 f4 ff ff       	call   f01010e3 <pgdir_walk>
f0101ca0:	83 c4 10             	add    $0x10,%esp
f0101ca3:	f6 00 04             	testb  $0x4,(%eax)
f0101ca6:	0f 85 91 09 00 00    	jne    f010263d <mem_init+0x129c>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101cac:	a1 8c be 3b f0       	mov    0xf03bbe8c,%eax
f0101cb1:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101cb4:	ba 00 00 00 00       	mov    $0x0,%edx
f0101cb9:	e8 9b ee ff ff       	call   f0100b59 <check_va2pa>
f0101cbe:	89 fe                	mov    %edi,%esi
f0101cc0:	2b 35 90 be 3b f0    	sub    0xf03bbe90,%esi
f0101cc6:	c1 fe 03             	sar    $0x3,%esi
f0101cc9:	c1 e6 0c             	shl    $0xc,%esi
f0101ccc:	39 f0                	cmp    %esi,%eax
f0101cce:	0f 85 82 09 00 00    	jne    f0102656 <mem_init+0x12b5>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101cd4:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cd9:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101cdc:	e8 78 ee ff ff       	call   f0100b59 <check_va2pa>
f0101ce1:	39 c6                	cmp    %eax,%esi
f0101ce3:	0f 85 86 09 00 00    	jne    f010266f <mem_init+0x12ce>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101ce9:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0101cee:	0f 85 94 09 00 00    	jne    f0102688 <mem_init+0x12e7>
	assert(pp2->pp_ref == 0);
f0101cf4:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101cf9:	0f 85 a2 09 00 00    	jne    f01026a1 <mem_init+0x1300>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101cff:	83 ec 0c             	sub    $0xc,%esp
f0101d02:	6a 00                	push   $0x0
f0101d04:	e8 f5 f2 ff ff       	call   f0100ffe <page_alloc>
f0101d09:	83 c4 10             	add    $0x10,%esp
f0101d0c:	39 c3                	cmp    %eax,%ebx
f0101d0e:	0f 85 a6 09 00 00    	jne    f01026ba <mem_init+0x1319>
f0101d14:	85 c0                	test   %eax,%eax
f0101d16:	0f 84 9e 09 00 00    	je     f01026ba <mem_init+0x1319>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101d1c:	83 ec 08             	sub    $0x8,%esp
f0101d1f:	6a 00                	push   $0x0
f0101d21:	ff 35 8c be 3b f0    	pushl  0xf03bbe8c
f0101d27:	e8 52 f5 ff ff       	call   f010127e <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d2c:	8b 35 8c be 3b f0    	mov    0xf03bbe8c,%esi
f0101d32:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d37:	89 f0                	mov    %esi,%eax
f0101d39:	e8 1b ee ff ff       	call   f0100b59 <check_va2pa>
f0101d3e:	83 c4 10             	add    $0x10,%esp
f0101d41:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d44:	0f 85 89 09 00 00    	jne    f01026d3 <mem_init+0x1332>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101d4a:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d4f:	89 f0                	mov    %esi,%eax
f0101d51:	e8 03 ee ff ff       	call   f0100b59 <check_va2pa>
f0101d56:	89 c2                	mov    %eax,%edx
f0101d58:	89 f8                	mov    %edi,%eax
f0101d5a:	2b 05 90 be 3b f0    	sub    0xf03bbe90,%eax
f0101d60:	c1 f8 03             	sar    $0x3,%eax
f0101d63:	c1 e0 0c             	shl    $0xc,%eax
f0101d66:	39 c2                	cmp    %eax,%edx
f0101d68:	0f 85 7e 09 00 00    	jne    f01026ec <mem_init+0x134b>
	assert(pp1->pp_ref == 1);
f0101d6e:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101d73:	0f 85 8c 09 00 00    	jne    f0102705 <mem_init+0x1364>
	assert(pp2->pp_ref == 0);
f0101d79:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d7e:	0f 85 9a 09 00 00    	jne    f010271e <mem_init+0x137d>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101d84:	6a 00                	push   $0x0
f0101d86:	68 00 10 00 00       	push   $0x1000
f0101d8b:	57                   	push   %edi
f0101d8c:	56                   	push   %esi
f0101d8d:	e8 3a f5 ff ff       	call   f01012cc <page_insert>
f0101d92:	83 c4 10             	add    $0x10,%esp
f0101d95:	85 c0                	test   %eax,%eax
f0101d97:	0f 85 9a 09 00 00    	jne    f0102737 <mem_init+0x1396>
	assert(pp1->pp_ref);
f0101d9d:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101da2:	0f 84 a8 09 00 00    	je     f0102750 <mem_init+0x13af>
	assert(pp1->pp_link == NULL);
f0101da8:	83 3f 00             	cmpl   $0x0,(%edi)
f0101dab:	0f 85 b8 09 00 00    	jne    f0102769 <mem_init+0x13c8>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101db1:	83 ec 08             	sub    $0x8,%esp
f0101db4:	68 00 10 00 00       	push   $0x1000
f0101db9:	ff 35 8c be 3b f0    	pushl  0xf03bbe8c
f0101dbf:	e8 ba f4 ff ff       	call   f010127e <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101dc4:	8b 35 8c be 3b f0    	mov    0xf03bbe8c,%esi
f0101dca:	ba 00 00 00 00       	mov    $0x0,%edx
f0101dcf:	89 f0                	mov    %esi,%eax
f0101dd1:	e8 83 ed ff ff       	call   f0100b59 <check_va2pa>
f0101dd6:	83 c4 10             	add    $0x10,%esp
f0101dd9:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101ddc:	0f 85 a0 09 00 00    	jne    f0102782 <mem_init+0x13e1>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101de2:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101de7:	89 f0                	mov    %esi,%eax
f0101de9:	e8 6b ed ff ff       	call   f0100b59 <check_va2pa>
f0101dee:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101df1:	0f 85 a4 09 00 00    	jne    f010279b <mem_init+0x13fa>
	assert(pp1->pp_ref == 0);
f0101df7:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101dfc:	0f 85 b2 09 00 00    	jne    f01027b4 <mem_init+0x1413>
	assert(pp2->pp_ref == 0);
f0101e02:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101e07:	0f 85 c0 09 00 00    	jne    f01027cd <mem_init+0x142c>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101e0d:	83 ec 0c             	sub    $0xc,%esp
f0101e10:	6a 00                	push   $0x0
f0101e12:	e8 e7 f1 ff ff       	call   f0100ffe <page_alloc>
f0101e17:	83 c4 10             	add    $0x10,%esp
f0101e1a:	85 c0                	test   %eax,%eax
f0101e1c:	0f 84 c4 09 00 00    	je     f01027e6 <mem_init+0x1445>
f0101e22:	39 c7                	cmp    %eax,%edi
f0101e24:	0f 85 bc 09 00 00    	jne    f01027e6 <mem_init+0x1445>

	// should be no free memory
	assert(!page_alloc(0));
f0101e2a:	83 ec 0c             	sub    $0xc,%esp
f0101e2d:	6a 00                	push   $0x0
f0101e2f:	e8 ca f1 ff ff       	call   f0100ffe <page_alloc>
f0101e34:	83 c4 10             	add    $0x10,%esp
f0101e37:	85 c0                	test   %eax,%eax
f0101e39:	0f 85 c0 09 00 00    	jne    f01027ff <mem_init+0x145e>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101e3f:	8b 0d 8c be 3b f0    	mov    0xf03bbe8c,%ecx
f0101e45:	8b 11                	mov    (%ecx),%edx
f0101e47:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101e4d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e50:	2b 05 90 be 3b f0    	sub    0xf03bbe90,%eax
f0101e56:	c1 f8 03             	sar    $0x3,%eax
f0101e59:	c1 e0 0c             	shl    $0xc,%eax
f0101e5c:	39 c2                	cmp    %eax,%edx
f0101e5e:	0f 85 b4 09 00 00    	jne    f0102818 <mem_init+0x1477>
	kern_pgdir[0] = 0;
f0101e64:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101e6a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e6d:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101e72:	0f 85 b9 09 00 00    	jne    f0102831 <mem_init+0x1490>
	pp0->pp_ref = 0;
f0101e78:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e7b:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101e81:	83 ec 0c             	sub    $0xc,%esp
f0101e84:	50                   	push   %eax
f0101e85:	e8 ed f1 ff ff       	call   f0101077 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101e8a:	83 c4 0c             	add    $0xc,%esp
f0101e8d:	6a 01                	push   $0x1
f0101e8f:	68 00 10 40 00       	push   $0x401000
f0101e94:	ff 35 8c be 3b f0    	pushl  0xf03bbe8c
f0101e9a:	e8 44 f2 ff ff       	call   f01010e3 <pgdir_walk>
f0101e9f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101ea2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101ea5:	8b 0d 8c be 3b f0    	mov    0xf03bbe8c,%ecx
f0101eab:	8b 41 04             	mov    0x4(%ecx),%eax
f0101eae:	89 c6                	mov    %eax,%esi
f0101eb0:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f0101eb6:	8b 15 88 be 3b f0    	mov    0xf03bbe88,%edx
f0101ebc:	c1 e8 0c             	shr    $0xc,%eax
f0101ebf:	83 c4 10             	add    $0x10,%esp
f0101ec2:	39 d0                	cmp    %edx,%eax
f0101ec4:	0f 83 80 09 00 00    	jae    f010284a <mem_init+0x14a9>
	assert(ptep == ptep1 + PTX(va));
f0101eca:	81 ee fc ff ff 0f    	sub    $0xffffffc,%esi
f0101ed0:	39 75 d0             	cmp    %esi,-0x30(%ebp)
f0101ed3:	0f 85 86 09 00 00    	jne    f010285f <mem_init+0x14be>
	kern_pgdir[PDX(va)] = 0;
f0101ed9:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0101ee0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ee3:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101ee9:	2b 05 90 be 3b f0    	sub    0xf03bbe90,%eax
f0101eef:	c1 f8 03             	sar    $0x3,%eax
f0101ef2:	89 c1                	mov    %eax,%ecx
f0101ef4:	c1 e1 0c             	shl    $0xc,%ecx
	if (PGNUM(pa) >= npages)
f0101ef7:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101efc:	39 c2                	cmp    %eax,%edx
f0101efe:	0f 86 74 09 00 00    	jbe    f0102878 <mem_init+0x14d7>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101f04:	83 ec 04             	sub    $0x4,%esp
f0101f07:	68 00 10 00 00       	push   $0x1000
f0101f0c:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101f11:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0101f17:	51                   	push   %ecx
f0101f18:	e8 4f 3e 00 00       	call   f0105d6c <memset>
	page_free(pp0);
f0101f1d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101f20:	89 34 24             	mov    %esi,(%esp)
f0101f23:	e8 4f f1 ff ff       	call   f0101077 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101f28:	83 c4 0c             	add    $0xc,%esp
f0101f2b:	6a 01                	push   $0x1
f0101f2d:	6a 00                	push   $0x0
f0101f2f:	ff 35 8c be 3b f0    	pushl  0xf03bbe8c
f0101f35:	e8 a9 f1 ff ff       	call   f01010e3 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101f3a:	89 f0                	mov    %esi,%eax
f0101f3c:	2b 05 90 be 3b f0    	sub    0xf03bbe90,%eax
f0101f42:	c1 f8 03             	sar    $0x3,%eax
f0101f45:	89 c2                	mov    %eax,%edx
f0101f47:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101f4a:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101f4f:	83 c4 10             	add    $0x10,%esp
f0101f52:	3b 05 88 be 3b f0    	cmp    0xf03bbe88,%eax
f0101f58:	0f 83 2c 09 00 00    	jae    f010288a <mem_init+0x14e9>
	return (void *)(pa + KERNBASE);
f0101f5e:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0101f64:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101f67:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101f6d:	f6 00 01             	testb  $0x1,(%eax)
f0101f70:	0f 85 26 09 00 00    	jne    f010289c <mem_init+0x14fb>
f0101f76:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0101f79:	39 d0                	cmp    %edx,%eax
f0101f7b:	75 f0                	jne    f0101f6d <mem_init+0xbcc>
	kern_pgdir[0] = 0;
f0101f7d:	a1 8c be 3b f0       	mov    0xf03bbe8c,%eax
f0101f82:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101f88:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f8b:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101f91:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101f94:	89 0d 40 b2 3b f0    	mov    %ecx,0xf03bb240

	// free the pages we took
	page_free(pp0);
f0101f9a:	83 ec 0c             	sub    $0xc,%esp
f0101f9d:	50                   	push   %eax
f0101f9e:	e8 d4 f0 ff ff       	call   f0101077 <page_free>
	page_free(pp1);
f0101fa3:	89 3c 24             	mov    %edi,(%esp)
f0101fa6:	e8 cc f0 ff ff       	call   f0101077 <page_free>
	page_free(pp2);
f0101fab:	89 1c 24             	mov    %ebx,(%esp)
f0101fae:	e8 c4 f0 ff ff       	call   f0101077 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0101fb3:	83 c4 08             	add    $0x8,%esp
f0101fb6:	68 01 10 00 00       	push   $0x1001
f0101fbb:	6a 00                	push   $0x0
f0101fbd:	e8 84 f3 ff ff       	call   f0101346 <mmio_map_region>
f0101fc2:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0101fc4:	83 c4 08             	add    $0x8,%esp
f0101fc7:	68 00 10 00 00       	push   $0x1000
f0101fcc:	6a 00                	push   $0x0
f0101fce:	e8 73 f3 ff ff       	call   f0101346 <mmio_map_region>
f0101fd3:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0101fd5:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f0101fdb:	83 c4 10             	add    $0x10,%esp
f0101fde:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0101fe4:	0f 86 cb 08 00 00    	jbe    f01028b5 <mem_init+0x1514>
f0101fea:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101fef:	0f 87 c0 08 00 00    	ja     f01028b5 <mem_init+0x1514>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0101ff5:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f0101ffb:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102001:	0f 87 c7 08 00 00    	ja     f01028ce <mem_init+0x152d>
f0102007:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010200d:	0f 86 bb 08 00 00    	jbe    f01028ce <mem_init+0x152d>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102013:	89 da                	mov    %ebx,%edx
f0102015:	09 f2                	or     %esi,%edx
f0102017:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f010201d:	0f 85 c4 08 00 00    	jne    f01028e7 <mem_init+0x1546>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f0102023:	39 c6                	cmp    %eax,%esi
f0102025:	0f 82 d5 08 00 00    	jb     f0102900 <mem_init+0x155f>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f010202b:	8b 3d 8c be 3b f0    	mov    0xf03bbe8c,%edi
f0102031:	89 da                	mov    %ebx,%edx
f0102033:	89 f8                	mov    %edi,%eax
f0102035:	e8 1f eb ff ff       	call   f0100b59 <check_va2pa>
f010203a:	85 c0                	test   %eax,%eax
f010203c:	0f 85 d7 08 00 00    	jne    f0102919 <mem_init+0x1578>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102042:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102048:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010204b:	89 c2                	mov    %eax,%edx
f010204d:	89 f8                	mov    %edi,%eax
f010204f:	e8 05 eb ff ff       	call   f0100b59 <check_va2pa>
f0102054:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102059:	0f 85 d3 08 00 00    	jne    f0102932 <mem_init+0x1591>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f010205f:	89 f2                	mov    %esi,%edx
f0102061:	89 f8                	mov    %edi,%eax
f0102063:	e8 f1 ea ff ff       	call   f0100b59 <check_va2pa>
f0102068:	85 c0                	test   %eax,%eax
f010206a:	0f 85 db 08 00 00    	jne    f010294b <mem_init+0x15aa>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102070:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102076:	89 f8                	mov    %edi,%eax
f0102078:	e8 dc ea ff ff       	call   f0100b59 <check_va2pa>
f010207d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102080:	0f 85 de 08 00 00    	jne    f0102964 <mem_init+0x15c3>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102086:	83 ec 04             	sub    $0x4,%esp
f0102089:	6a 00                	push   $0x0
f010208b:	53                   	push   %ebx
f010208c:	57                   	push   %edi
f010208d:	e8 51 f0 ff ff       	call   f01010e3 <pgdir_walk>
f0102092:	83 c4 10             	add    $0x10,%esp
f0102095:	f6 00 1a             	testb  $0x1a,(%eax)
f0102098:	0f 84 df 08 00 00    	je     f010297d <mem_init+0x15dc>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f010209e:	83 ec 04             	sub    $0x4,%esp
f01020a1:	6a 00                	push   $0x0
f01020a3:	53                   	push   %ebx
f01020a4:	ff 35 8c be 3b f0    	pushl  0xf03bbe8c
f01020aa:	e8 34 f0 ff ff       	call   f01010e3 <pgdir_walk>
f01020af:	8b 00                	mov    (%eax),%eax
f01020b1:	83 c4 10             	add    $0x10,%esp
f01020b4:	83 e0 04             	and    $0x4,%eax
f01020b7:	89 c7                	mov    %eax,%edi
f01020b9:	0f 85 d7 08 00 00    	jne    f0102996 <mem_init+0x15f5>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f01020bf:	83 ec 04             	sub    $0x4,%esp
f01020c2:	6a 00                	push   $0x0
f01020c4:	53                   	push   %ebx
f01020c5:	ff 35 8c be 3b f0    	pushl  0xf03bbe8c
f01020cb:	e8 13 f0 ff ff       	call   f01010e3 <pgdir_walk>
f01020d0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f01020d6:	83 c4 0c             	add    $0xc,%esp
f01020d9:	6a 00                	push   $0x0
f01020db:	ff 75 d4             	pushl  -0x2c(%ebp)
f01020de:	ff 35 8c be 3b f0    	pushl  0xf03bbe8c
f01020e4:	e8 fa ef ff ff       	call   f01010e3 <pgdir_walk>
f01020e9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f01020ef:	83 c4 0c             	add    $0xc,%esp
f01020f2:	6a 00                	push   $0x0
f01020f4:	56                   	push   %esi
f01020f5:	ff 35 8c be 3b f0    	pushl  0xf03bbe8c
f01020fb:	e8 e3 ef ff ff       	call   f01010e3 <pgdir_walk>
f0102100:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102106:	c7 04 24 c9 7b 10 f0 	movl   $0xf0107bc9,(%esp)
f010210d:	e8 1b 1a 00 00       	call   f0103b2d <cprintf>
    size_t pages_size = ROUNDUP(sizeof(struct PageInfo) * npages, PGSIZE);
f0102112:	a1 88 be 3b f0       	mov    0xf03bbe88,%eax
f0102117:	8d 1c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ebx
f010211e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    boot_map_region(kern_pgdir, UPAGES, pages_size,
f0102124:	a1 90 be 3b f0       	mov    0xf03bbe90,%eax
	if ((uint32_t)kva < KERNBASE)
f0102129:	83 c4 10             	add    $0x10,%esp
f010212c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102131:	0f 86 78 08 00 00    	jbe    f01029af <mem_init+0x160e>
f0102137:	83 ec 08             	sub    $0x8,%esp
f010213a:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f010213c:	05 00 00 00 10       	add    $0x10000000,%eax
f0102141:	50                   	push   %eax
f0102142:	89 d9                	mov    %ebx,%ecx
f0102144:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102149:	a1 8c be 3b f0       	mov    0xf03bbe8c,%eax
f010214e:	e8 20 f0 ff ff       	call   f0101173 <boot_map_region>
    boot_map_region(kern_pgdir, (uintptr_t)pages, pages_size,
f0102153:	8b 15 90 be 3b f0    	mov    0xf03bbe90,%edx
	if ((uint32_t)kva < KERNBASE)
f0102159:	83 c4 10             	add    $0x10,%esp
f010215c:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102162:	0f 86 5c 08 00 00    	jbe    f01029c4 <mem_init+0x1623>
f0102168:	83 ec 08             	sub    $0x8,%esp
f010216b:	6a 03                	push   $0x3
	return (physaddr_t)kva - KERNBASE;
f010216d:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
f0102173:	50                   	push   %eax
f0102174:	89 d9                	mov    %ebx,%ecx
f0102176:	a1 8c be 3b f0       	mov    0xf03bbe8c,%eax
f010217b:	e8 f3 ef ff ff       	call   f0101173 <boot_map_region>
    boot_map_region(kern_pgdir, UENVS, alloc_size,
f0102180:	a1 44 b2 3b f0       	mov    0xf03bb244,%eax
	if ((uint32_t)kva < KERNBASE)
f0102185:	83 c4 10             	add    $0x10,%esp
f0102188:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010218d:	0f 86 46 08 00 00    	jbe    f01029d9 <mem_init+0x1638>
f0102193:	83 ec 08             	sub    $0x8,%esp
f0102196:	6a 07                	push   $0x7
	return (physaddr_t)kva - KERNBASE;
f0102198:	05 00 00 00 10       	add    $0x10000000,%eax
f010219d:	50                   	push   %eax
f010219e:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f01021a3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01021a8:	a1 8c be 3b f0       	mov    0xf03bbe8c,%eax
f01021ad:	e8 c1 ef ff ff       	call   f0101173 <boot_map_region>
    boot_map_region(kern_pgdir, (uintptr_t)envs, alloc_size,
f01021b2:	8b 15 44 b2 3b f0    	mov    0xf03bb244,%edx
	if ((uint32_t)kva < KERNBASE)
f01021b8:	83 c4 10             	add    $0x10,%esp
f01021bb:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01021c1:	0f 86 27 08 00 00    	jbe    f01029ee <mem_init+0x164d>
f01021c7:	83 ec 08             	sub    $0x8,%esp
f01021ca:	6a 03                	push   $0x3
	return (physaddr_t)kva - KERNBASE;
f01021cc:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
f01021d2:	50                   	push   %eax
f01021d3:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f01021d8:	a1 8c be 3b f0       	mov    0xf03bbe8c,%eax
f01021dd:	e8 91 ef ff ff       	call   f0101173 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f01021e2:	83 c4 10             	add    $0x10,%esp
f01021e5:	b8 00 90 11 f0       	mov    $0xf0119000,%eax
f01021ea:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01021ef:	0f 86 0e 08 00 00    	jbe    f0102a03 <mem_init+0x1662>
    boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE,
f01021f5:	83 ec 08             	sub    $0x8,%esp
f01021f8:	6a 03                	push   $0x3
f01021fa:	68 00 90 11 00       	push   $0x119000
f01021ff:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102204:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102209:	a1 8c be 3b f0       	mov    0xf03bbe8c,%eax
f010220e:	e8 60 ef ff ff       	call   f0101173 <boot_map_region>
    boot_map_region(kern_pgdir, KERNBASE, -KERNBASE,
f0102213:	83 c4 08             	add    $0x8,%esp
f0102216:	6a 03                	push   $0x3
f0102218:	6a 00                	push   $0x0
f010221a:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f010221f:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102224:	a1 8c be 3b f0       	mov    0xf03bbe8c,%eax
f0102229:	e8 45 ef ff ff       	call   f0101173 <boot_map_region>
f010222e:	c7 45 d0 00 d0 3b f0 	movl   $0xf03bd000,-0x30(%ebp)
f0102235:	83 c4 10             	add    $0x10,%esp
f0102238:	bb 00 d0 3b f0       	mov    $0xf03bd000,%ebx
f010223d:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102242:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102248:	0f 86 ca 07 00 00    	jbe    f0102a18 <mem_init+0x1677>
        boot_map_region(kern_pgdir, ith_top - KSTKSIZE, KSTKSIZE,
f010224e:	83 ec 08             	sub    $0x8,%esp
f0102251:	6a 03                	push   $0x3
f0102253:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102259:	50                   	push   %eax
f010225a:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010225f:	89 f2                	mov    %esi,%edx
f0102261:	a1 8c be 3b f0       	mov    0xf03bbe8c,%eax
f0102266:	e8 08 ef ff ff       	call   f0101173 <boot_map_region>
f010226b:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102271:	81 ee 00 00 01 00    	sub    $0x10000,%esi
    for (int i = 0; i < NCPU; ++i) {
f0102277:	83 c4 10             	add    $0x10,%esp
f010227a:	81 fb 00 d0 3f f0    	cmp    $0xf03fd000,%ebx
f0102280:	75 c0                	jne    f0102242 <mem_init+0xea1>
	pgdir = kern_pgdir;
f0102282:	a1 8c be 3b f0       	mov    0xf03bbe8c,%eax
f0102287:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010228a:	a1 88 be 3b f0       	mov    0xf03bbe88,%eax
f010228f:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0102292:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102299:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010229e:	89 45 cc             	mov    %eax,-0x34(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01022a1:	8b 35 90 be 3b f0    	mov    0xf03bbe90,%esi
f01022a7:	89 75 c8             	mov    %esi,-0x38(%ebp)
	return (physaddr_t)kva - KERNBASE;
f01022aa:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f01022b0:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f01022b3:	89 fb                	mov    %edi,%ebx
f01022b5:	39 5d cc             	cmp    %ebx,-0x34(%ebp)
f01022b8:	0f 86 9d 07 00 00    	jbe    f0102a5b <mem_init+0x16ba>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01022be:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01022c4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022c7:	e8 8d e8 ff ff       	call   f0100b59 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f01022cc:	81 7d c8 ff ff ff ef 	cmpl   $0xefffffff,-0x38(%ebp)
f01022d3:	0f 86 54 07 00 00    	jbe    f0102a2d <mem_init+0x168c>
f01022d9:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01022dc:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f01022df:	39 d0                	cmp    %edx,%eax
f01022e1:	0f 85 5b 07 00 00    	jne    f0102a42 <mem_init+0x16a1>
	for (i = 0; i < n; i += PGSIZE)
f01022e7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01022ed:	eb c6                	jmp    f01022b5 <mem_init+0xf14>
	assert(nfree == 0);
f01022ef:	68 e0 7a 10 f0       	push   $0xf0107ae0
f01022f4:	68 19 79 10 f0       	push   $0xf0107919
f01022f9:	68 84 03 00 00       	push   $0x384
f01022fe:	68 e5 78 10 f0       	push   $0xf01078e5
f0102303:	e8 38 dd ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0102308:	68 ee 79 10 f0       	push   $0xf01079ee
f010230d:	68 19 79 10 f0       	push   $0xf0107919
f0102312:	68 eb 03 00 00       	push   $0x3eb
f0102317:	68 e5 78 10 f0       	push   $0xf01078e5
f010231c:	e8 1f dd ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102321:	68 04 7a 10 f0       	push   $0xf0107a04
f0102326:	68 19 79 10 f0       	push   $0xf0107919
f010232b:	68 ec 03 00 00       	push   $0x3ec
f0102330:	68 e5 78 10 f0       	push   $0xf01078e5
f0102335:	e8 06 dd ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010233a:	68 1a 7a 10 f0       	push   $0xf0107a1a
f010233f:	68 19 79 10 f0       	push   $0xf0107919
f0102344:	68 ed 03 00 00       	push   $0x3ed
f0102349:	68 e5 78 10 f0       	push   $0xf01078e5
f010234e:	e8 ed dc ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0102353:	68 30 7a 10 f0       	push   $0xf0107a30
f0102358:	68 19 79 10 f0       	push   $0xf0107919
f010235d:	68 f0 03 00 00       	push   $0x3f0
f0102362:	68 e5 78 10 f0       	push   $0xf01078e5
f0102367:	e8 d4 dc ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010236c:	68 08 71 10 f0       	push   $0xf0107108
f0102371:	68 19 79 10 f0       	push   $0xf0107919
f0102376:	68 f1 03 00 00       	push   $0x3f1
f010237b:	68 e5 78 10 f0       	push   $0xf01078e5
f0102380:	e8 bb dc ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102385:	68 99 7a 10 f0       	push   $0xf0107a99
f010238a:	68 19 79 10 f0       	push   $0xf0107919
f010238f:	68 f8 03 00 00       	push   $0x3f8
f0102394:	68 e5 78 10 f0       	push   $0xf01078e5
f0102399:	e8 a2 dc ff ff       	call   f0100040 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010239e:	68 48 71 10 f0       	push   $0xf0107148
f01023a3:	68 19 79 10 f0       	push   $0xf0107919
f01023a8:	68 fb 03 00 00       	push   $0x3fb
f01023ad:	68 e5 78 10 f0       	push   $0xf01078e5
f01023b2:	e8 89 dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01023b7:	68 80 71 10 f0       	push   $0xf0107180
f01023bc:	68 19 79 10 f0       	push   $0xf0107919
f01023c1:	68 fe 03 00 00       	push   $0x3fe
f01023c6:	68 e5 78 10 f0       	push   $0xf01078e5
f01023cb:	e8 70 dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01023d0:	68 b0 71 10 f0       	push   $0xf01071b0
f01023d5:	68 19 79 10 f0       	push   $0xf0107919
f01023da:	68 02 04 00 00       	push   $0x402
f01023df:	68 e5 78 10 f0       	push   $0xf01078e5
f01023e4:	e8 57 dc ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01023e9:	68 e0 71 10 f0       	push   $0xf01071e0
f01023ee:	68 19 79 10 f0       	push   $0xf0107919
f01023f3:	68 03 04 00 00       	push   $0x403
f01023f8:	68 e5 78 10 f0       	push   $0xf01078e5
f01023fd:	e8 3e dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102402:	68 08 72 10 f0       	push   $0xf0107208
f0102407:	68 19 79 10 f0       	push   $0xf0107919
f010240c:	68 04 04 00 00       	push   $0x404
f0102411:	68 e5 78 10 f0       	push   $0xf01078e5
f0102416:	e8 25 dc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010241b:	68 eb 7a 10 f0       	push   $0xf0107aeb
f0102420:	68 19 79 10 f0       	push   $0xf0107919
f0102425:	68 05 04 00 00       	push   $0x405
f010242a:	68 e5 78 10 f0       	push   $0xf01078e5
f010242f:	e8 0c dc ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102434:	68 fc 7a 10 f0       	push   $0xf0107afc
f0102439:	68 19 79 10 f0       	push   $0xf0107919
f010243e:	68 06 04 00 00       	push   $0x406
f0102443:	68 e5 78 10 f0       	push   $0xf01078e5
f0102448:	e8 f3 db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010244d:	68 38 72 10 f0       	push   $0xf0107238
f0102452:	68 19 79 10 f0       	push   $0xf0107919
f0102457:	68 09 04 00 00       	push   $0x409
f010245c:	68 e5 78 10 f0       	push   $0xf01078e5
f0102461:	e8 da db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102466:	68 74 72 10 f0       	push   $0xf0107274
f010246b:	68 19 79 10 f0       	push   $0xf0107919
f0102470:	68 0a 04 00 00       	push   $0x40a
f0102475:	68 e5 78 10 f0       	push   $0xf01078e5
f010247a:	e8 c1 db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010247f:	68 0d 7b 10 f0       	push   $0xf0107b0d
f0102484:	68 19 79 10 f0       	push   $0xf0107919
f0102489:	68 0b 04 00 00       	push   $0x40b
f010248e:	68 e5 78 10 f0       	push   $0xf01078e5
f0102493:	e8 a8 db ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102498:	68 99 7a 10 f0       	push   $0xf0107a99
f010249d:	68 19 79 10 f0       	push   $0xf0107919
f01024a2:	68 0e 04 00 00       	push   $0x40e
f01024a7:	68 e5 78 10 f0       	push   $0xf01078e5
f01024ac:	e8 8f db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01024b1:	68 38 72 10 f0       	push   $0xf0107238
f01024b6:	68 19 79 10 f0       	push   $0xf0107919
f01024bb:	68 11 04 00 00       	push   $0x411
f01024c0:	68 e5 78 10 f0       	push   $0xf01078e5
f01024c5:	e8 76 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01024ca:	68 74 72 10 f0       	push   $0xf0107274
f01024cf:	68 19 79 10 f0       	push   $0xf0107919
f01024d4:	68 12 04 00 00       	push   $0x412
f01024d9:	68 e5 78 10 f0       	push   $0xf01078e5
f01024de:	e8 5d db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01024e3:	68 0d 7b 10 f0       	push   $0xf0107b0d
f01024e8:	68 19 79 10 f0       	push   $0xf0107919
f01024ed:	68 13 04 00 00       	push   $0x413
f01024f2:	68 e5 78 10 f0       	push   $0xf01078e5
f01024f7:	e8 44 db ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01024fc:	68 99 7a 10 f0       	push   $0xf0107a99
f0102501:	68 19 79 10 f0       	push   $0xf0107919
f0102506:	68 17 04 00 00       	push   $0x417
f010250b:	68 e5 78 10 f0       	push   $0xf01078e5
f0102510:	e8 2b db ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102515:	52                   	push   %edx
f0102516:	68 24 6a 10 f0       	push   $0xf0106a24
f010251b:	68 1a 04 00 00       	push   $0x41a
f0102520:	68 e5 78 10 f0       	push   $0xf01078e5
f0102525:	e8 16 db ff ff       	call   f0100040 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010252a:	68 a4 72 10 f0       	push   $0xf01072a4
f010252f:	68 19 79 10 f0       	push   $0xf0107919
f0102534:	68 1b 04 00 00       	push   $0x41b
f0102539:	68 e5 78 10 f0       	push   $0xf01078e5
f010253e:	e8 fd da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102543:	68 e4 72 10 f0       	push   $0xf01072e4
f0102548:	68 19 79 10 f0       	push   $0xf0107919
f010254d:	68 1e 04 00 00       	push   $0x41e
f0102552:	68 e5 78 10 f0       	push   $0xf01078e5
f0102557:	e8 e4 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010255c:	68 74 72 10 f0       	push   $0xf0107274
f0102561:	68 19 79 10 f0       	push   $0xf0107919
f0102566:	68 1f 04 00 00       	push   $0x41f
f010256b:	68 e5 78 10 f0       	push   $0xf01078e5
f0102570:	e8 cb da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102575:	68 0d 7b 10 f0       	push   $0xf0107b0d
f010257a:	68 19 79 10 f0       	push   $0xf0107919
f010257f:	68 20 04 00 00       	push   $0x420
f0102584:	68 e5 78 10 f0       	push   $0xf01078e5
f0102589:	e8 b2 da ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010258e:	68 24 73 10 f0       	push   $0xf0107324
f0102593:	68 19 79 10 f0       	push   $0xf0107919
f0102598:	68 21 04 00 00       	push   $0x421
f010259d:	68 e5 78 10 f0       	push   $0xf01078e5
f01025a2:	e8 99 da ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01025a7:	68 1e 7b 10 f0       	push   $0xf0107b1e
f01025ac:	68 19 79 10 f0       	push   $0xf0107919
f01025b1:	68 22 04 00 00       	push   $0x422
f01025b6:	68 e5 78 10 f0       	push   $0xf01078e5
f01025bb:	e8 80 da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01025c0:	68 38 72 10 f0       	push   $0xf0107238
f01025c5:	68 19 79 10 f0       	push   $0xf0107919
f01025ca:	68 25 04 00 00       	push   $0x425
f01025cf:	68 e5 78 10 f0       	push   $0xf01078e5
f01025d4:	e8 67 da ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01025d9:	68 58 73 10 f0       	push   $0xf0107358
f01025de:	68 19 79 10 f0       	push   $0xf0107919
f01025e3:	68 26 04 00 00       	push   $0x426
f01025e8:	68 e5 78 10 f0       	push   $0xf01078e5
f01025ed:	e8 4e da ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01025f2:	68 8c 73 10 f0       	push   $0xf010738c
f01025f7:	68 19 79 10 f0       	push   $0xf0107919
f01025fc:	68 27 04 00 00       	push   $0x427
f0102601:	68 e5 78 10 f0       	push   $0xf01078e5
f0102606:	e8 35 da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010260b:	68 c4 73 10 f0       	push   $0xf01073c4
f0102610:	68 19 79 10 f0       	push   $0xf0107919
f0102615:	68 2a 04 00 00       	push   $0x42a
f010261a:	68 e5 78 10 f0       	push   $0xf01078e5
f010261f:	e8 1c da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102624:	68 fc 73 10 f0       	push   $0xf01073fc
f0102629:	68 19 79 10 f0       	push   $0xf0107919
f010262e:	68 2d 04 00 00       	push   $0x42d
f0102633:	68 e5 78 10 f0       	push   $0xf01078e5
f0102638:	e8 03 da ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010263d:	68 8c 73 10 f0       	push   $0xf010738c
f0102642:	68 19 79 10 f0       	push   $0xf0107919
f0102647:	68 2e 04 00 00       	push   $0x42e
f010264c:	68 e5 78 10 f0       	push   $0xf01078e5
f0102651:	e8 ea d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102656:	68 38 74 10 f0       	push   $0xf0107438
f010265b:	68 19 79 10 f0       	push   $0xf0107919
f0102660:	68 31 04 00 00       	push   $0x431
f0102665:	68 e5 78 10 f0       	push   $0xf01078e5
f010266a:	e8 d1 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010266f:	68 64 74 10 f0       	push   $0xf0107464
f0102674:	68 19 79 10 f0       	push   $0xf0107919
f0102679:	68 32 04 00 00       	push   $0x432
f010267e:	68 e5 78 10 f0       	push   $0xf01078e5
f0102683:	e8 b8 d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 2);
f0102688:	68 34 7b 10 f0       	push   $0xf0107b34
f010268d:	68 19 79 10 f0       	push   $0xf0107919
f0102692:	68 34 04 00 00       	push   $0x434
f0102697:	68 e5 78 10 f0       	push   $0xf01078e5
f010269c:	e8 9f d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01026a1:	68 45 7b 10 f0       	push   $0xf0107b45
f01026a6:	68 19 79 10 f0       	push   $0xf0107919
f01026ab:	68 35 04 00 00       	push   $0x435
f01026b0:	68 e5 78 10 f0       	push   $0xf01078e5
f01026b5:	e8 86 d9 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f01026ba:	68 94 74 10 f0       	push   $0xf0107494
f01026bf:	68 19 79 10 f0       	push   $0xf0107919
f01026c4:	68 38 04 00 00       	push   $0x438
f01026c9:	68 e5 78 10 f0       	push   $0xf01078e5
f01026ce:	e8 6d d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01026d3:	68 b8 74 10 f0       	push   $0xf01074b8
f01026d8:	68 19 79 10 f0       	push   $0xf0107919
f01026dd:	68 3c 04 00 00       	push   $0x43c
f01026e2:	68 e5 78 10 f0       	push   $0xf01078e5
f01026e7:	e8 54 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01026ec:	68 64 74 10 f0       	push   $0xf0107464
f01026f1:	68 19 79 10 f0       	push   $0xf0107919
f01026f6:	68 3d 04 00 00       	push   $0x43d
f01026fb:	68 e5 78 10 f0       	push   $0xf01078e5
f0102700:	e8 3b d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102705:	68 eb 7a 10 f0       	push   $0xf0107aeb
f010270a:	68 19 79 10 f0       	push   $0xf0107919
f010270f:	68 3e 04 00 00       	push   $0x43e
f0102714:	68 e5 78 10 f0       	push   $0xf01078e5
f0102719:	e8 22 d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010271e:	68 45 7b 10 f0       	push   $0xf0107b45
f0102723:	68 19 79 10 f0       	push   $0xf0107919
f0102728:	68 3f 04 00 00       	push   $0x43f
f010272d:	68 e5 78 10 f0       	push   $0xf01078e5
f0102732:	e8 09 d9 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102737:	68 dc 74 10 f0       	push   $0xf01074dc
f010273c:	68 19 79 10 f0       	push   $0xf0107919
f0102741:	68 42 04 00 00       	push   $0x442
f0102746:	68 e5 78 10 f0       	push   $0xf01078e5
f010274b:	e8 f0 d8 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0102750:	68 56 7b 10 f0       	push   $0xf0107b56
f0102755:	68 19 79 10 f0       	push   $0xf0107919
f010275a:	68 43 04 00 00       	push   $0x443
f010275f:	68 e5 78 10 f0       	push   $0xf01078e5
f0102764:	e8 d7 d8 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102769:	68 62 7b 10 f0       	push   $0xf0107b62
f010276e:	68 19 79 10 f0       	push   $0xf0107919
f0102773:	68 44 04 00 00       	push   $0x444
f0102778:	68 e5 78 10 f0       	push   $0xf01078e5
f010277d:	e8 be d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102782:	68 b8 74 10 f0       	push   $0xf01074b8
f0102787:	68 19 79 10 f0       	push   $0xf0107919
f010278c:	68 48 04 00 00       	push   $0x448
f0102791:	68 e5 78 10 f0       	push   $0xf01078e5
f0102796:	e8 a5 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010279b:	68 14 75 10 f0       	push   $0xf0107514
f01027a0:	68 19 79 10 f0       	push   $0xf0107919
f01027a5:	68 49 04 00 00       	push   $0x449
f01027aa:	68 e5 78 10 f0       	push   $0xf01078e5
f01027af:	e8 8c d8 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01027b4:	68 77 7b 10 f0       	push   $0xf0107b77
f01027b9:	68 19 79 10 f0       	push   $0xf0107919
f01027be:	68 4a 04 00 00       	push   $0x44a
f01027c3:	68 e5 78 10 f0       	push   $0xf01078e5
f01027c8:	e8 73 d8 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01027cd:	68 45 7b 10 f0       	push   $0xf0107b45
f01027d2:	68 19 79 10 f0       	push   $0xf0107919
f01027d7:	68 4b 04 00 00       	push   $0x44b
f01027dc:	68 e5 78 10 f0       	push   $0xf01078e5
f01027e1:	e8 5a d8 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f01027e6:	68 3c 75 10 f0       	push   $0xf010753c
f01027eb:	68 19 79 10 f0       	push   $0xf0107919
f01027f0:	68 4e 04 00 00       	push   $0x44e
f01027f5:	68 e5 78 10 f0       	push   $0xf01078e5
f01027fa:	e8 41 d8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01027ff:	68 99 7a 10 f0       	push   $0xf0107a99
f0102804:	68 19 79 10 f0       	push   $0xf0107919
f0102809:	68 51 04 00 00       	push   $0x451
f010280e:	68 e5 78 10 f0       	push   $0xf01078e5
f0102813:	e8 28 d8 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102818:	68 e0 71 10 f0       	push   $0xf01071e0
f010281d:	68 19 79 10 f0       	push   $0xf0107919
f0102822:	68 54 04 00 00       	push   $0x454
f0102827:	68 e5 78 10 f0       	push   $0xf01078e5
f010282c:	e8 0f d8 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102831:	68 fc 7a 10 f0       	push   $0xf0107afc
f0102836:	68 19 79 10 f0       	push   $0xf0107919
f010283b:	68 56 04 00 00       	push   $0x456
f0102840:	68 e5 78 10 f0       	push   $0xf01078e5
f0102845:	e8 f6 d7 ff ff       	call   f0100040 <_panic>
f010284a:	56                   	push   %esi
f010284b:	68 24 6a 10 f0       	push   $0xf0106a24
f0102850:	68 5d 04 00 00       	push   $0x45d
f0102855:	68 e5 78 10 f0       	push   $0xf01078e5
f010285a:	e8 e1 d7 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010285f:	68 88 7b 10 f0       	push   $0xf0107b88
f0102864:	68 19 79 10 f0       	push   $0xf0107919
f0102869:	68 5e 04 00 00       	push   $0x45e
f010286e:	68 e5 78 10 f0       	push   $0xf01078e5
f0102873:	e8 c8 d7 ff ff       	call   f0100040 <_panic>
f0102878:	51                   	push   %ecx
f0102879:	68 24 6a 10 f0       	push   $0xf0106a24
f010287e:	6a 58                	push   $0x58
f0102880:	68 ff 78 10 f0       	push   $0xf01078ff
f0102885:	e8 b6 d7 ff ff       	call   f0100040 <_panic>
f010288a:	52                   	push   %edx
f010288b:	68 24 6a 10 f0       	push   $0xf0106a24
f0102890:	6a 58                	push   $0x58
f0102892:	68 ff 78 10 f0       	push   $0xf01078ff
f0102897:	e8 a4 d7 ff ff       	call   f0100040 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f010289c:	68 a0 7b 10 f0       	push   $0xf0107ba0
f01028a1:	68 19 79 10 f0       	push   $0xf0107919
f01028a6:	68 68 04 00 00       	push   $0x468
f01028ab:	68 e5 78 10 f0       	push   $0xf01078e5
f01028b0:	e8 8b d7 ff ff       	call   f0100040 <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f01028b5:	68 60 75 10 f0       	push   $0xf0107560
f01028ba:	68 19 79 10 f0       	push   $0xf0107919
f01028bf:	68 78 04 00 00       	push   $0x478
f01028c4:	68 e5 78 10 f0       	push   $0xf01078e5
f01028c9:	e8 72 d7 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f01028ce:	68 88 75 10 f0       	push   $0xf0107588
f01028d3:	68 19 79 10 f0       	push   $0xf0107919
f01028d8:	68 79 04 00 00       	push   $0x479
f01028dd:	68 e5 78 10 f0       	push   $0xf01078e5
f01028e2:	e8 59 d7 ff ff       	call   f0100040 <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01028e7:	68 b0 75 10 f0       	push   $0xf01075b0
f01028ec:	68 19 79 10 f0       	push   $0xf0107919
f01028f1:	68 7b 04 00 00       	push   $0x47b
f01028f6:	68 e5 78 10 f0       	push   $0xf01078e5
f01028fb:	e8 40 d7 ff ff       	call   f0100040 <_panic>
	assert(mm1 + 8192 <= mm2);
f0102900:	68 b7 7b 10 f0       	push   $0xf0107bb7
f0102905:	68 19 79 10 f0       	push   $0xf0107919
f010290a:	68 7d 04 00 00       	push   $0x47d
f010290f:	68 e5 78 10 f0       	push   $0xf01078e5
f0102914:	e8 27 d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102919:	68 d8 75 10 f0       	push   $0xf01075d8
f010291e:	68 19 79 10 f0       	push   $0xf0107919
f0102923:	68 7f 04 00 00       	push   $0x47f
f0102928:	68 e5 78 10 f0       	push   $0xf01078e5
f010292d:	e8 0e d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102932:	68 fc 75 10 f0       	push   $0xf01075fc
f0102937:	68 19 79 10 f0       	push   $0xf0107919
f010293c:	68 80 04 00 00       	push   $0x480
f0102941:	68 e5 78 10 f0       	push   $0xf01078e5
f0102946:	e8 f5 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f010294b:	68 2c 76 10 f0       	push   $0xf010762c
f0102950:	68 19 79 10 f0       	push   $0xf0107919
f0102955:	68 81 04 00 00       	push   $0x481
f010295a:	68 e5 78 10 f0       	push   $0xf01078e5
f010295f:	e8 dc d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102964:	68 50 76 10 f0       	push   $0xf0107650
f0102969:	68 19 79 10 f0       	push   $0xf0107919
f010296e:	68 82 04 00 00       	push   $0x482
f0102973:	68 e5 78 10 f0       	push   $0xf01078e5
f0102978:	e8 c3 d6 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f010297d:	68 7c 76 10 f0       	push   $0xf010767c
f0102982:	68 19 79 10 f0       	push   $0xf0107919
f0102987:	68 84 04 00 00       	push   $0x484
f010298c:	68 e5 78 10 f0       	push   $0xf01078e5
f0102991:	e8 aa d6 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102996:	68 c0 76 10 f0       	push   $0xf01076c0
f010299b:	68 19 79 10 f0       	push   $0xf0107919
f01029a0:	68 85 04 00 00       	push   $0x485
f01029a5:	68 e5 78 10 f0       	push   $0xf01078e5
f01029aa:	e8 91 d6 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029af:	50                   	push   %eax
f01029b0:	68 48 6a 10 f0       	push   $0xf0106a48
f01029b5:	68 d1 00 00 00       	push   $0xd1
f01029ba:	68 e5 78 10 f0       	push   $0xf01078e5
f01029bf:	e8 7c d6 ff ff       	call   f0100040 <_panic>
f01029c4:	52                   	push   %edx
f01029c5:	68 48 6a 10 f0       	push   $0xf0106a48
f01029ca:	68 d4 00 00 00       	push   $0xd4
f01029cf:	68 e5 78 10 f0       	push   $0xf01078e5
f01029d4:	e8 67 d6 ff ff       	call   f0100040 <_panic>
f01029d9:	50                   	push   %eax
f01029da:	68 48 6a 10 f0       	push   $0xf0106a48
f01029df:	68 e0 00 00 00       	push   $0xe0
f01029e4:	68 e5 78 10 f0       	push   $0xf01078e5
f01029e9:	e8 52 d6 ff ff       	call   f0100040 <_panic>
f01029ee:	52                   	push   %edx
f01029ef:	68 48 6a 10 f0       	push   $0xf0106a48
f01029f4:	68 e2 00 00 00       	push   $0xe2
f01029f9:	68 e5 78 10 f0       	push   $0xf01078e5
f01029fe:	e8 3d d6 ff ff       	call   f0100040 <_panic>
f0102a03:	50                   	push   %eax
f0102a04:	68 48 6a 10 f0       	push   $0xf0106a48
f0102a09:	68 f0 00 00 00       	push   $0xf0
f0102a0e:	68 e5 78 10 f0       	push   $0xf01078e5
f0102a13:	e8 28 d6 ff ff       	call   f0100040 <_panic>
f0102a18:	53                   	push   %ebx
f0102a19:	68 48 6a 10 f0       	push   $0xf0106a48
f0102a1e:	68 34 01 00 00       	push   $0x134
f0102a23:	68 e5 78 10 f0       	push   $0xf01078e5
f0102a28:	e8 13 d6 ff ff       	call   f0100040 <_panic>
f0102a2d:	56                   	push   %esi
f0102a2e:	68 48 6a 10 f0       	push   $0xf0106a48
f0102a33:	68 9c 03 00 00       	push   $0x39c
f0102a38:	68 e5 78 10 f0       	push   $0xf01078e5
f0102a3d:	e8 fe d5 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102a42:	68 f4 76 10 f0       	push   $0xf01076f4
f0102a47:	68 19 79 10 f0       	push   $0xf0107919
f0102a4c:	68 9c 03 00 00       	push   $0x39c
f0102a51:	68 e5 78 10 f0       	push   $0xf01078e5
f0102a56:	e8 e5 d5 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102a5b:	a1 44 b2 3b f0       	mov    0xf03bb244,%eax
f0102a60:	89 45 c8             	mov    %eax,-0x38(%ebp)
	if ((uint32_t)kva < KERNBASE)
f0102a63:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102a66:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102a6b:	8d b0 00 00 40 21    	lea    0x21400000(%eax),%esi
f0102a71:	89 da                	mov    %ebx,%edx
f0102a73:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a76:	e8 de e0 ff ff       	call   f0100b59 <check_va2pa>
f0102a7b:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102a82:	76 3b                	jbe    f0102abf <mem_init+0x171e>
f0102a84:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102a87:	39 d0                	cmp    %edx,%eax
f0102a89:	75 4b                	jne    f0102ad6 <mem_init+0x1735>
f0102a8b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
f0102a91:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102a97:	75 d8                	jne    f0102a71 <mem_init+0x16d0>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE) {
f0102a99:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0102a9c:	c1 e6 0c             	shl    $0xc,%esi
f0102a9f:	89 fb                	mov    %edi,%ebx
f0102aa1:	39 f3                	cmp    %esi,%ebx
f0102aa3:	73 63                	jae    f0102b08 <mem_init+0x1767>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102aa5:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102aab:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102aae:	e8 a6 e0 ff ff       	call   f0100b59 <check_va2pa>
f0102ab3:	39 c3                	cmp    %eax,%ebx
f0102ab5:	75 38                	jne    f0102aef <mem_init+0x174e>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE) {
f0102ab7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102abd:	eb e2                	jmp    f0102aa1 <mem_init+0x1700>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102abf:	ff 75 c8             	pushl  -0x38(%ebp)
f0102ac2:	68 48 6a 10 f0       	push   $0xf0106a48
f0102ac7:	68 a1 03 00 00       	push   $0x3a1
f0102acc:	68 e5 78 10 f0       	push   $0xf01078e5
f0102ad1:	e8 6a d5 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102ad6:	68 28 77 10 f0       	push   $0xf0107728
f0102adb:	68 19 79 10 f0       	push   $0xf0107919
f0102ae0:	68 a1 03 00 00       	push   $0x3a1
f0102ae5:	68 e5 78 10 f0       	push   $0xf01078e5
f0102aea:	e8 51 d5 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102aef:	68 5c 77 10 f0       	push   $0xf010775c
f0102af4:	68 19 79 10 f0       	push   $0xf0107919
f0102af9:	68 a5 03 00 00       	push   $0x3a5
f0102afe:	68 e5 78 10 f0       	push   $0xf01078e5
f0102b03:	e8 38 d5 ff ff       	call   f0100040 <_panic>
f0102b08:	c7 45 cc 00 d0 3c 00 	movl   $0x3cd000,-0x34(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE) {
f0102b0f:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
f0102b14:	89 7d c0             	mov    %edi,-0x40(%ebp)
f0102b17:	8d bb 00 80 ff ff    	lea    -0x8000(%ebx),%edi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102b1d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102b20:	89 45 bc             	mov    %eax,-0x44(%ebp)
f0102b23:	89 de                	mov    %ebx,%esi
f0102b25:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102b28:	05 00 80 ff 0f       	add    $0xfff8000,%eax
f0102b2d:	89 45 c8             	mov    %eax,-0x38(%ebp)
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102b30:	8d 83 00 80 00 00    	lea    0x8000(%ebx),%eax
f0102b36:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102b39:	89 f2                	mov    %esi,%edx
f0102b3b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b3e:	e8 16 e0 ff ff       	call   f0100b59 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102b43:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102b4a:	76 58                	jbe    f0102ba4 <mem_init+0x1803>
f0102b4c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102b4f:	8d 14 31             	lea    (%ecx,%esi,1),%edx
f0102b52:	39 d0                	cmp    %edx,%eax
f0102b54:	75 65                	jne    f0102bbb <mem_init+0x181a>
f0102b56:	81 c6 00 10 00 00    	add    $0x1000,%esi
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102b5c:	3b 75 c4             	cmp    -0x3c(%ebp),%esi
f0102b5f:	75 d8                	jne    f0102b39 <mem_init+0x1798>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102b61:	89 fa                	mov    %edi,%edx
f0102b63:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b66:	e8 ee df ff ff       	call   f0100b59 <check_va2pa>
f0102b6b:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102b6e:	75 64                	jne    f0102bd4 <mem_init+0x1833>
f0102b70:	81 c7 00 10 00 00    	add    $0x1000,%edi
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102b76:	39 df                	cmp    %ebx,%edi
f0102b78:	75 e7                	jne    f0102b61 <mem_init+0x17c0>
f0102b7a:	81 eb 00 00 01 00    	sub    $0x10000,%ebx
f0102b80:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
f0102b87:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102b8a:	81 45 cc 00 80 01 00 	addl   $0x18000,-0x34(%ebp)
	for (n = 0; n < NCPU; n++) {
f0102b91:	3d 00 d0 3f f0       	cmp    $0xf03fd000,%eax
f0102b96:	0f 85 7b ff ff ff    	jne    f0102b17 <mem_init+0x1776>
f0102b9c:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0102b9f:	e9 84 00 00 00       	jmp    f0102c28 <mem_init+0x1887>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ba4:	ff 75 bc             	pushl  -0x44(%ebp)
f0102ba7:	68 48 6a 10 f0       	push   $0xf0106a48
f0102bac:	68 ae 03 00 00       	push   $0x3ae
f0102bb1:	68 e5 78 10 f0       	push   $0xf01078e5
f0102bb6:	e8 85 d4 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102bbb:	68 84 77 10 f0       	push   $0xf0107784
f0102bc0:	68 19 79 10 f0       	push   $0xf0107919
f0102bc5:	68 ad 03 00 00       	push   $0x3ad
f0102bca:	68 e5 78 10 f0       	push   $0xf01078e5
f0102bcf:	e8 6c d4 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102bd4:	68 cc 77 10 f0       	push   $0xf01077cc
f0102bd9:	68 19 79 10 f0       	push   $0xf0107919
f0102bde:	68 b0 03 00 00       	push   $0x3b0
f0102be3:	68 e5 78 10 f0       	push   $0xf01078e5
f0102be8:	e8 53 d4 ff ff       	call   f0100040 <_panic>
			assert(pgdir[i] & PTE_P);
f0102bed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102bf0:	f6 04 b8 01          	testb  $0x1,(%eax,%edi,4)
f0102bf4:	75 4e                	jne    f0102c44 <mem_init+0x18a3>
f0102bf6:	68 e2 7b 10 f0       	push   $0xf0107be2
f0102bfb:	68 19 79 10 f0       	push   $0xf0107919
f0102c00:	68 bb 03 00 00       	push   $0x3bb
f0102c05:	68 e5 78 10 f0       	push   $0xf01078e5
f0102c0a:	e8 31 d4 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_P);
f0102c0f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c12:	8b 04 b8             	mov    (%eax,%edi,4),%eax
f0102c15:	a8 01                	test   $0x1,%al
f0102c17:	74 30                	je     f0102c49 <mem_init+0x18a8>
				assert(pgdir[i] & PTE_W);
f0102c19:	a8 02                	test   $0x2,%al
f0102c1b:	74 45                	je     f0102c62 <mem_init+0x18c1>
	for (i = 0; i < NPDENTRIES; i++) {
f0102c1d:	83 c7 01             	add    $0x1,%edi
f0102c20:	81 ff 00 04 00 00    	cmp    $0x400,%edi
f0102c26:	74 6c                	je     f0102c94 <mem_init+0x18f3>
		switch (i) {
f0102c28:	8d 87 45 fc ff ff    	lea    -0x3bb(%edi),%eax
f0102c2e:	83 f8 04             	cmp    $0x4,%eax
f0102c31:	76 ba                	jbe    f0102bed <mem_init+0x184c>
			if (i >= PDX(KERNBASE)) {
f0102c33:	81 ff bf 03 00 00    	cmp    $0x3bf,%edi
f0102c39:	77 d4                	ja     f0102c0f <mem_init+0x186e>
				assert(pgdir[i] == 0);
f0102c3b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c3e:	83 3c b8 00          	cmpl   $0x0,(%eax,%edi,4)
f0102c42:	75 37                	jne    f0102c7b <mem_init+0x18da>
	for (i = 0; i < NPDENTRIES; i++) {
f0102c44:	83 c7 01             	add    $0x1,%edi
f0102c47:	eb df                	jmp    f0102c28 <mem_init+0x1887>
				assert(pgdir[i] & PTE_P);
f0102c49:	68 e2 7b 10 f0       	push   $0xf0107be2
f0102c4e:	68 19 79 10 f0       	push   $0xf0107919
f0102c53:	68 bf 03 00 00       	push   $0x3bf
f0102c58:	68 e5 78 10 f0       	push   $0xf01078e5
f0102c5d:	e8 de d3 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102c62:	68 f3 7b 10 f0       	push   $0xf0107bf3
f0102c67:	68 19 79 10 f0       	push   $0xf0107919
f0102c6c:	68 c0 03 00 00       	push   $0x3c0
f0102c71:	68 e5 78 10 f0       	push   $0xf01078e5
f0102c76:	e8 c5 d3 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] == 0);
f0102c7b:	68 04 7c 10 f0       	push   $0xf0107c04
f0102c80:	68 19 79 10 f0       	push   $0xf0107919
f0102c85:	68 c2 03 00 00       	push   $0x3c2
f0102c8a:	68 e5 78 10 f0       	push   $0xf01078e5
f0102c8f:	e8 ac d3 ff ff       	call   f0100040 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102c94:	83 ec 0c             	sub    $0xc,%esp
f0102c97:	68 f0 77 10 f0       	push   $0xf01077f0
f0102c9c:	e8 8c 0e 00 00       	call   f0103b2d <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102ca1:	a1 8c be 3b f0       	mov    0xf03bbe8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0102ca6:	83 c4 10             	add    $0x10,%esp
f0102ca9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102cae:	0f 86 03 02 00 00    	jbe    f0102eb7 <mem_init+0x1b16>
	return (physaddr_t)kva - KERNBASE;
f0102cb4:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102cb9:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102cbc:	b8 00 00 00 00       	mov    $0x0,%eax
f0102cc1:	e8 7e df ff ff       	call   f0100c44 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102cc6:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102cc9:	83 e0 f3             	and    $0xfffffff3,%eax
f0102ccc:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102cd1:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102cd4:	83 ec 0c             	sub    $0xc,%esp
f0102cd7:	6a 00                	push   $0x0
f0102cd9:	e8 20 e3 ff ff       	call   f0100ffe <page_alloc>
f0102cde:	89 c6                	mov    %eax,%esi
f0102ce0:	83 c4 10             	add    $0x10,%esp
f0102ce3:	85 c0                	test   %eax,%eax
f0102ce5:	0f 84 e1 01 00 00    	je     f0102ecc <mem_init+0x1b2b>
	assert((pp1 = page_alloc(0)));
f0102ceb:	83 ec 0c             	sub    $0xc,%esp
f0102cee:	6a 00                	push   $0x0
f0102cf0:	e8 09 e3 ff ff       	call   f0100ffe <page_alloc>
f0102cf5:	89 c7                	mov    %eax,%edi
f0102cf7:	83 c4 10             	add    $0x10,%esp
f0102cfa:	85 c0                	test   %eax,%eax
f0102cfc:	0f 84 e3 01 00 00    	je     f0102ee5 <mem_init+0x1b44>
	assert((pp2 = page_alloc(0)));
f0102d02:	83 ec 0c             	sub    $0xc,%esp
f0102d05:	6a 00                	push   $0x0
f0102d07:	e8 f2 e2 ff ff       	call   f0100ffe <page_alloc>
f0102d0c:	89 c3                	mov    %eax,%ebx
f0102d0e:	83 c4 10             	add    $0x10,%esp
f0102d11:	85 c0                	test   %eax,%eax
f0102d13:	0f 84 e5 01 00 00    	je     f0102efe <mem_init+0x1b5d>
	page_free(pp0);
f0102d19:	83 ec 0c             	sub    $0xc,%esp
f0102d1c:	56                   	push   %esi
f0102d1d:	e8 55 e3 ff ff       	call   f0101077 <page_free>
	return (pp - pages) << PGSHIFT;
f0102d22:	89 f8                	mov    %edi,%eax
f0102d24:	2b 05 90 be 3b f0    	sub    0xf03bbe90,%eax
f0102d2a:	c1 f8 03             	sar    $0x3,%eax
f0102d2d:	89 c2                	mov    %eax,%edx
f0102d2f:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102d32:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102d37:	83 c4 10             	add    $0x10,%esp
f0102d3a:	3b 05 88 be 3b f0    	cmp    0xf03bbe88,%eax
f0102d40:	0f 83 d1 01 00 00    	jae    f0102f17 <mem_init+0x1b76>
	memset(page2kva(pp1), 1, PGSIZE);
f0102d46:	83 ec 04             	sub    $0x4,%esp
f0102d49:	68 00 10 00 00       	push   $0x1000
f0102d4e:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102d50:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102d56:	52                   	push   %edx
f0102d57:	e8 10 30 00 00       	call   f0105d6c <memset>
	return (pp - pages) << PGSHIFT;
f0102d5c:	89 d8                	mov    %ebx,%eax
f0102d5e:	2b 05 90 be 3b f0    	sub    0xf03bbe90,%eax
f0102d64:	c1 f8 03             	sar    $0x3,%eax
f0102d67:	89 c2                	mov    %eax,%edx
f0102d69:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102d6c:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102d71:	83 c4 10             	add    $0x10,%esp
f0102d74:	3b 05 88 be 3b f0    	cmp    0xf03bbe88,%eax
f0102d7a:	0f 83 a9 01 00 00    	jae    f0102f29 <mem_init+0x1b88>
	memset(page2kva(pp2), 2, PGSIZE);
f0102d80:	83 ec 04             	sub    $0x4,%esp
f0102d83:	68 00 10 00 00       	push   $0x1000
f0102d88:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102d8a:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102d90:	52                   	push   %edx
f0102d91:	e8 d6 2f 00 00       	call   f0105d6c <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102d96:	6a 02                	push   $0x2
f0102d98:	68 00 10 00 00       	push   $0x1000
f0102d9d:	57                   	push   %edi
f0102d9e:	ff 35 8c be 3b f0    	pushl  0xf03bbe8c
f0102da4:	e8 23 e5 ff ff       	call   f01012cc <page_insert>
	assert(pp1->pp_ref == 1);
f0102da9:	83 c4 20             	add    $0x20,%esp
f0102dac:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102db1:	0f 85 84 01 00 00    	jne    f0102f3b <mem_init+0x1b9a>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102db7:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102dbe:	01 01 01 
f0102dc1:	0f 85 8d 01 00 00    	jne    f0102f54 <mem_init+0x1bb3>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102dc7:	6a 02                	push   $0x2
f0102dc9:	68 00 10 00 00       	push   $0x1000
f0102dce:	53                   	push   %ebx
f0102dcf:	ff 35 8c be 3b f0    	pushl  0xf03bbe8c
f0102dd5:	e8 f2 e4 ff ff       	call   f01012cc <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102dda:	83 c4 10             	add    $0x10,%esp
f0102ddd:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102de4:	02 02 02 
f0102de7:	0f 85 80 01 00 00    	jne    f0102f6d <mem_init+0x1bcc>
	assert(pp2->pp_ref == 1);
f0102ded:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102df2:	0f 85 8e 01 00 00    	jne    f0102f86 <mem_init+0x1be5>
	assert(pp1->pp_ref == 0);
f0102df8:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102dfd:	0f 85 9c 01 00 00    	jne    f0102f9f <mem_init+0x1bfe>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102e03:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102e0a:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102e0d:	89 d8                	mov    %ebx,%eax
f0102e0f:	2b 05 90 be 3b f0    	sub    0xf03bbe90,%eax
f0102e15:	c1 f8 03             	sar    $0x3,%eax
f0102e18:	89 c2                	mov    %eax,%edx
f0102e1a:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102e1d:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102e22:	3b 05 88 be 3b f0    	cmp    0xf03bbe88,%eax
f0102e28:	0f 83 8a 01 00 00    	jae    f0102fb8 <mem_init+0x1c17>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102e2e:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f0102e35:	03 03 03 
f0102e38:	0f 85 8c 01 00 00    	jne    f0102fca <mem_init+0x1c29>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102e3e:	83 ec 08             	sub    $0x8,%esp
f0102e41:	68 00 10 00 00       	push   $0x1000
f0102e46:	ff 35 8c be 3b f0    	pushl  0xf03bbe8c
f0102e4c:	e8 2d e4 ff ff       	call   f010127e <page_remove>
	assert(pp2->pp_ref == 0);
f0102e51:	83 c4 10             	add    $0x10,%esp
f0102e54:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102e59:	0f 85 84 01 00 00    	jne    f0102fe3 <mem_init+0x1c42>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102e5f:	8b 0d 8c be 3b f0    	mov    0xf03bbe8c,%ecx
f0102e65:	8b 11                	mov    (%ecx),%edx
f0102e67:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102e6d:	89 f0                	mov    %esi,%eax
f0102e6f:	2b 05 90 be 3b f0    	sub    0xf03bbe90,%eax
f0102e75:	c1 f8 03             	sar    $0x3,%eax
f0102e78:	c1 e0 0c             	shl    $0xc,%eax
f0102e7b:	39 c2                	cmp    %eax,%edx
f0102e7d:	0f 85 79 01 00 00    	jne    f0102ffc <mem_init+0x1c5b>
	kern_pgdir[0] = 0;
f0102e83:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102e89:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102e8e:	0f 85 81 01 00 00    	jne    f0103015 <mem_init+0x1c74>
	pp0->pp_ref = 0;
f0102e94:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102e9a:	83 ec 0c             	sub    $0xc,%esp
f0102e9d:	56                   	push   %esi
f0102e9e:	e8 d4 e1 ff ff       	call   f0101077 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102ea3:	c7 04 24 84 78 10 f0 	movl   $0xf0107884,(%esp)
f0102eaa:	e8 7e 0c 00 00       	call   f0103b2d <cprintf>
}
f0102eaf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102eb2:	5b                   	pop    %ebx
f0102eb3:	5e                   	pop    %esi
f0102eb4:	5f                   	pop    %edi
f0102eb5:	5d                   	pop    %ebp
f0102eb6:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102eb7:	50                   	push   %eax
f0102eb8:	68 48 6a 10 f0       	push   $0xf0106a48
f0102ebd:	68 0a 01 00 00       	push   $0x10a
f0102ec2:	68 e5 78 10 f0       	push   $0xf01078e5
f0102ec7:	e8 74 d1 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0102ecc:	68 ee 79 10 f0       	push   $0xf01079ee
f0102ed1:	68 19 79 10 f0       	push   $0xf0107919
f0102ed6:	68 9a 04 00 00       	push   $0x49a
f0102edb:	68 e5 78 10 f0       	push   $0xf01078e5
f0102ee0:	e8 5b d1 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102ee5:	68 04 7a 10 f0       	push   $0xf0107a04
f0102eea:	68 19 79 10 f0       	push   $0xf0107919
f0102eef:	68 9b 04 00 00       	push   $0x49b
f0102ef4:	68 e5 78 10 f0       	push   $0xf01078e5
f0102ef9:	e8 42 d1 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102efe:	68 1a 7a 10 f0       	push   $0xf0107a1a
f0102f03:	68 19 79 10 f0       	push   $0xf0107919
f0102f08:	68 9c 04 00 00       	push   $0x49c
f0102f0d:	68 e5 78 10 f0       	push   $0xf01078e5
f0102f12:	e8 29 d1 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f17:	52                   	push   %edx
f0102f18:	68 24 6a 10 f0       	push   $0xf0106a24
f0102f1d:	6a 58                	push   $0x58
f0102f1f:	68 ff 78 10 f0       	push   $0xf01078ff
f0102f24:	e8 17 d1 ff ff       	call   f0100040 <_panic>
f0102f29:	52                   	push   %edx
f0102f2a:	68 24 6a 10 f0       	push   $0xf0106a24
f0102f2f:	6a 58                	push   $0x58
f0102f31:	68 ff 78 10 f0       	push   $0xf01078ff
f0102f36:	e8 05 d1 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102f3b:	68 eb 7a 10 f0       	push   $0xf0107aeb
f0102f40:	68 19 79 10 f0       	push   $0xf0107919
f0102f45:	68 a1 04 00 00       	push   $0x4a1
f0102f4a:	68 e5 78 10 f0       	push   $0xf01078e5
f0102f4f:	e8 ec d0 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102f54:	68 10 78 10 f0       	push   $0xf0107810
f0102f59:	68 19 79 10 f0       	push   $0xf0107919
f0102f5e:	68 a2 04 00 00       	push   $0x4a2
f0102f63:	68 e5 78 10 f0       	push   $0xf01078e5
f0102f68:	e8 d3 d0 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102f6d:	68 34 78 10 f0       	push   $0xf0107834
f0102f72:	68 19 79 10 f0       	push   $0xf0107919
f0102f77:	68 a4 04 00 00       	push   $0x4a4
f0102f7c:	68 e5 78 10 f0       	push   $0xf01078e5
f0102f81:	e8 ba d0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102f86:	68 0d 7b 10 f0       	push   $0xf0107b0d
f0102f8b:	68 19 79 10 f0       	push   $0xf0107919
f0102f90:	68 a5 04 00 00       	push   $0x4a5
f0102f95:	68 e5 78 10 f0       	push   $0xf01078e5
f0102f9a:	e8 a1 d0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102f9f:	68 77 7b 10 f0       	push   $0xf0107b77
f0102fa4:	68 19 79 10 f0       	push   $0xf0107919
f0102fa9:	68 a6 04 00 00       	push   $0x4a6
f0102fae:	68 e5 78 10 f0       	push   $0xf01078e5
f0102fb3:	e8 88 d0 ff ff       	call   f0100040 <_panic>
f0102fb8:	52                   	push   %edx
f0102fb9:	68 24 6a 10 f0       	push   $0xf0106a24
f0102fbe:	6a 58                	push   $0x58
f0102fc0:	68 ff 78 10 f0       	push   $0xf01078ff
f0102fc5:	e8 76 d0 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102fca:	68 58 78 10 f0       	push   $0xf0107858
f0102fcf:	68 19 79 10 f0       	push   $0xf0107919
f0102fd4:	68 a8 04 00 00       	push   $0x4a8
f0102fd9:	68 e5 78 10 f0       	push   $0xf01078e5
f0102fde:	e8 5d d0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102fe3:	68 45 7b 10 f0       	push   $0xf0107b45
f0102fe8:	68 19 79 10 f0       	push   $0xf0107919
f0102fed:	68 aa 04 00 00       	push   $0x4aa
f0102ff2:	68 e5 78 10 f0       	push   $0xf01078e5
f0102ff7:	e8 44 d0 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102ffc:	68 e0 71 10 f0       	push   $0xf01071e0
f0103001:	68 19 79 10 f0       	push   $0xf0107919
f0103006:	68 ad 04 00 00       	push   $0x4ad
f010300b:	68 e5 78 10 f0       	push   $0xf01078e5
f0103010:	e8 2b d0 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0103015:	68 fc 7a 10 f0       	push   $0xf0107afc
f010301a:	68 19 79 10 f0       	push   $0xf0107919
f010301f:	68 af 04 00 00       	push   $0x4af
f0103024:	68 e5 78 10 f0       	push   $0xf01078e5
f0103029:	e8 12 d0 ff ff       	call   f0100040 <_panic>

f010302e <do_user_mem_check>:
do_user_mem_check(struct Env *env, uintptr_t va, int perm) {
f010302e:	f3 0f 1e fb          	endbr32 
f0103032:	55                   	push   %ebp
f0103033:	89 e5                	mov    %esp,%ebp
f0103035:	83 ec 0c             	sub    $0xc,%esp
    pte_t *p_pte = pgdir_walk(env->env_pgdir, (void *)va, 0);
f0103038:	6a 00                	push   $0x0
f010303a:	ff 75 0c             	pushl  0xc(%ebp)
f010303d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103040:	ff 70 60             	pushl  0x60(%eax)
f0103043:	e8 9b e0 ff ff       	call   f01010e3 <pgdir_walk>
    if ( p_pte == NULL || (*p_pte & (perm|PTE_P)) != (perm|PTE_P)) {
f0103048:	83 c4 10             	add    $0x10,%esp
f010304b:	85 c0                	test   %eax,%eax
f010304d:	74 1b                	je     f010306a <do_user_mem_check+0x3c>
f010304f:	8b 55 10             	mov    0x10(%ebp),%edx
f0103052:	83 ca 01             	or     $0x1,%edx
f0103055:	89 d1                	mov    %edx,%ecx
f0103057:	23 08                	and    (%eax),%ecx
        return -E_FAULT;
f0103059:	39 ca                	cmp    %ecx,%edx
f010305b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103060:	ba fa ff ff ff       	mov    $0xfffffffa,%edx
f0103065:	0f 45 c2             	cmovne %edx,%eax
}
f0103068:	c9                   	leave  
f0103069:	c3                   	ret    
        return -E_FAULT;
f010306a:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010306f:	eb f7                	jmp    f0103068 <do_user_mem_check+0x3a>

f0103071 <user_mem_check>:
{
f0103071:	f3 0f 1e fb          	endbr32 
f0103075:	55                   	push   %ebp
f0103076:	89 e5                	mov    %esp,%ebp
f0103078:	57                   	push   %edi
f0103079:	56                   	push   %esi
f010307a:	53                   	push   %ebx
f010307b:	83 ec 0c             	sub    $0xc,%esp
f010307e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103081:	8b 45 0c             	mov    0xc(%ebp),%eax
    uintptr_t low_addr = (uintptr_t)va;
f0103084:	89 c3                	mov    %eax,%ebx
    uintptr_t end_addr = ROUNDUP(((uintptr_t)va) + len, PGSIZE);
f0103086:	8b 55 10             	mov    0x10(%ebp),%edx
f0103089:	8d b4 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%esi
f0103090:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    while (low_addr < end_addr) {
f0103096:	eb 19                	jmp    f01030b1 <user_mem_check+0x40>
            user_mem_check_addr = low_addr;
f0103098:	89 1d 3c b2 3b f0    	mov    %ebx,0xf03bb23c
            return -E_FAULT;
f010309e:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01030a3:	eb 3e                	jmp    f01030e3 <user_mem_check+0x72>
        low_addr += PGSIZE;
f01030a5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
        low_addr &= 0xfffff000;
f01030ab:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    while (low_addr < end_addr) {
f01030b1:	39 f3                	cmp    %esi,%ebx
f01030b3:	73 29                	jae    f01030de <user_mem_check+0x6d>
        if (low_addr >= ULIM) {
f01030b5:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01030bb:	77 db                	ja     f0103098 <user_mem_check+0x27>
        if (do_user_mem_check(env, low_addr, perm) < 0) {
f01030bd:	83 ec 04             	sub    $0x4,%esp
f01030c0:	ff 75 14             	pushl  0x14(%ebp)
f01030c3:	53                   	push   %ebx
f01030c4:	57                   	push   %edi
f01030c5:	e8 64 ff ff ff       	call   f010302e <do_user_mem_check>
f01030ca:	83 c4 10             	add    $0x10,%esp
f01030cd:	85 c0                	test   %eax,%eax
f01030cf:	79 d4                	jns    f01030a5 <user_mem_check+0x34>
            user_mem_check_addr = low_addr;
f01030d1:	89 1d 3c b2 3b f0    	mov    %ebx,0xf03bb23c
            return -E_FAULT;
f01030d7:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01030dc:	eb 05                	jmp    f01030e3 <user_mem_check+0x72>
	return 0;
f01030de:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01030e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01030e6:	5b                   	pop    %ebx
f01030e7:	5e                   	pop    %esi
f01030e8:	5f                   	pop    %edi
f01030e9:	5d                   	pop    %ebp
f01030ea:	c3                   	ret    

f01030eb <user_mem_assert>:
{
f01030eb:	f3 0f 1e fb          	endbr32 
f01030ef:	55                   	push   %ebp
f01030f0:	89 e5                	mov    %esp,%ebp
f01030f2:	53                   	push   %ebx
f01030f3:	83 ec 04             	sub    $0x4,%esp
f01030f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01030f9:	8b 45 14             	mov    0x14(%ebp),%eax
f01030fc:	83 c8 04             	or     $0x4,%eax
f01030ff:	50                   	push   %eax
f0103100:	ff 75 10             	pushl  0x10(%ebp)
f0103103:	ff 75 0c             	pushl  0xc(%ebp)
f0103106:	53                   	push   %ebx
f0103107:	e8 65 ff ff ff       	call   f0103071 <user_mem_check>
f010310c:	83 c4 10             	add    $0x10,%esp
f010310f:	85 c0                	test   %eax,%eax
f0103111:	78 05                	js     f0103118 <user_mem_assert+0x2d>
}
f0103113:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103116:	c9                   	leave  
f0103117:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f0103118:	83 ec 04             	sub    $0x4,%esp
f010311b:	ff 35 3c b2 3b f0    	pushl  0xf03bb23c
f0103121:	ff 73 48             	pushl  0x48(%ebx)
f0103124:	68 b0 78 10 f0       	push   $0xf01078b0
f0103129:	e8 ff 09 00 00       	call   f0103b2d <cprintf>
		env_destroy(env);	// may not return
f010312e:	89 1c 24             	mov    %ebx,(%esp)
f0103131:	e8 c0 06 00 00       	call   f01037f6 <env_destroy>
f0103136:	83 c4 10             	add    $0x10,%esp
}
f0103139:	eb d8                	jmp    f0103113 <user_mem_assert+0x28>

f010313b <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f010313b:	55                   	push   %ebp
f010313c:	89 e5                	mov    %esp,%ebp
f010313e:	57                   	push   %edi
f010313f:	56                   	push   %esi
f0103140:	53                   	push   %ebx
f0103141:	83 ec 1c             	sub    $0x1c,%esp
f0103144:	89 c6                	mov    %eax,%esi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)

    char *start_addr    = (char *) ROUNDDOWN(va, PGSIZE);
f0103146:	89 d3                	mov    %edx,%ebx
f0103148:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    char *end_addr      = (char *) ROUNDUP((char *)va + len, PGSIZE);
f010314e:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f0103155:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010315a:	89 c7                	mov    %eax,%edi

    if ((uintptr_t)end_addr > UTOP) {
f010315c:	3d 00 00 c0 ee       	cmp    $0xeec00000,%eax
f0103161:	76 34                	jbe    f0103197 <region_alloc+0x5c>
        panic("region_alloc: allocating above UTOP is not allowed\n");
f0103163:	83 ec 04             	sub    $0x4,%esp
f0103166:	68 14 7c 10 f0       	push   $0xf0107c14
f010316b:	68 2c 01 00 00       	push   $0x12c
f0103170:	68 c0 7c 10 f0       	push   $0xf0107cc0
f0103175:	e8 c6 ce ff ff       	call   f0100040 <_panic>
        }

        pp = page_alloc(0);

        if (pp == NULL) {
            panic("region_alloc: out-of-memory!\n");
f010317a:	83 ec 04             	sub    $0x4,%esp
f010317d:	68 cb 7c 10 f0       	push   $0xf0107ccb
f0103182:	68 3a 01 00 00       	push   $0x13a
f0103187:	68 c0 7c 10 f0       	push   $0xf0107cc0
f010318c:	e8 af ce ff ff       	call   f0100040 <_panic>
f0103191:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103197:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
    while (start_addr < end_addr) {
f010319a:	39 fb                	cmp    %edi,%ebx
f010319c:	73 52                	jae    f01031f0 <region_alloc+0xb5>
        struct PageInfo *pp = page_lookup(e->env_pgdir, start_addr, NULL);
f010319e:	83 ec 04             	sub    $0x4,%esp
f01031a1:	6a 00                	push   $0x0
f01031a3:	53                   	push   %ebx
f01031a4:	ff 76 60             	pushl  0x60(%esi)
f01031a7:	e8 37 e0 ff ff       	call   f01011e3 <page_lookup>
        if (pp != NULL) {
f01031ac:	83 c4 10             	add    $0x10,%esp
f01031af:	85 c0                	test   %eax,%eax
f01031b1:	75 de                	jne    f0103191 <region_alloc+0x56>
        pp = page_alloc(0);
f01031b3:	83 ec 0c             	sub    $0xc,%esp
f01031b6:	6a 00                	push   $0x0
f01031b8:	e8 41 de ff ff       	call   f0100ffe <page_alloc>
        if (pp == NULL) {
f01031bd:	83 c4 10             	add    $0x10,%esp
f01031c0:	85 c0                	test   %eax,%eax
f01031c2:	74 b6                	je     f010317a <region_alloc+0x3f>
        }

        if (page_insert(e->env_pgdir, pp, start_addr, PTE_W | PTE_U | PTE_P) < 0) {
f01031c4:	6a 07                	push   $0x7
f01031c6:	ff 75 e4             	pushl  -0x1c(%ebp)
f01031c9:	50                   	push   %eax
f01031ca:	ff 76 60             	pushl  0x60(%esi)
f01031cd:	e8 fa e0 ff ff       	call   f01012cc <page_insert>
f01031d2:	83 c4 10             	add    $0x10,%esp
f01031d5:	85 c0                	test   %eax,%eax
f01031d7:	79 b8                	jns    f0103191 <region_alloc+0x56>
            panic("region_alloc: page table allocation failed!\n");
f01031d9:	83 ec 04             	sub    $0x4,%esp
f01031dc:	68 48 7c 10 f0       	push   $0xf0107c48
f01031e1:	68 3e 01 00 00       	push   $0x13e
f01031e6:	68 c0 7c 10 f0       	push   $0xf0107cc0
f01031eb:	e8 50 ce ff ff       	call   f0100040 <_panic>
        }
        start_addr += PGSIZE;
    }
}
f01031f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01031f3:	5b                   	pop    %ebx
f01031f4:	5e                   	pop    %esi
f01031f5:	5f                   	pop    %edi
f01031f6:	5d                   	pop    %ebp
f01031f7:	c3                   	ret    

f01031f8 <envid2env>:
{
f01031f8:	f3 0f 1e fb          	endbr32 
f01031fc:	55                   	push   %ebp
f01031fd:	89 e5                	mov    %esp,%ebp
f01031ff:	56                   	push   %esi
f0103200:	53                   	push   %ebx
f0103201:	8b 75 08             	mov    0x8(%ebp),%esi
f0103204:	8b 45 10             	mov    0x10(%ebp),%eax
	if (envid == 0) {
f0103207:	85 f6                	test   %esi,%esi
f0103209:	74 2e                	je     f0103239 <envid2env+0x41>
	e = &envs[ENVX(envid)];
f010320b:	89 f3                	mov    %esi,%ebx
f010320d:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103213:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0103216:	03 1d 44 b2 3b f0    	add    0xf03bb244,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010321c:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103220:	74 2e                	je     f0103250 <envid2env+0x58>
f0103222:	39 73 48             	cmp    %esi,0x48(%ebx)
f0103225:	75 29                	jne    f0103250 <envid2env+0x58>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103227:	84 c0                	test   %al,%al
f0103229:	75 35                	jne    f0103260 <envid2env+0x68>
	*env_store = e;
f010322b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010322e:	89 18                	mov    %ebx,(%eax)
	return 0;
f0103230:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103235:	5b                   	pop    %ebx
f0103236:	5e                   	pop    %esi
f0103237:	5d                   	pop    %ebp
f0103238:	c3                   	ret    
		*env_store = curenv;
f0103239:	e8 4c 31 00 00       	call   f010638a <cpunum>
f010323e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103241:	8b 80 28 c0 3b f0    	mov    -0xfc43fd8(%eax),%eax
f0103247:	8b 55 0c             	mov    0xc(%ebp),%edx
f010324a:	89 02                	mov    %eax,(%edx)
		return 0;
f010324c:	89 f0                	mov    %esi,%eax
f010324e:	eb e5                	jmp    f0103235 <envid2env+0x3d>
		*env_store = 0;
f0103250:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103253:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103259:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010325e:	eb d5                	jmp    f0103235 <envid2env+0x3d>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103260:	e8 25 31 00 00       	call   f010638a <cpunum>
f0103265:	6b c0 74             	imul   $0x74,%eax,%eax
f0103268:	39 98 28 c0 3b f0    	cmp    %ebx,-0xfc43fd8(%eax)
f010326e:	74 bb                	je     f010322b <envid2env+0x33>
f0103270:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103273:	e8 12 31 00 00       	call   f010638a <cpunum>
f0103278:	6b c0 74             	imul   $0x74,%eax,%eax
f010327b:	8b 80 28 c0 3b f0    	mov    -0xfc43fd8(%eax),%eax
f0103281:	3b 70 48             	cmp    0x48(%eax),%esi
f0103284:	74 a5                	je     f010322b <envid2env+0x33>
		*env_store = 0;
f0103286:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103289:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010328f:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103294:	eb 9f                	jmp    f0103235 <envid2env+0x3d>

f0103296 <env_init_percpu>:
{
f0103296:	f3 0f 1e fb          	endbr32 
	asm volatile("lgdt (%0)" : : "r" (p));
f010329a:	b8 20 33 12 f0       	mov    $0xf0123320,%eax
f010329f:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f01032a2:	b8 23 00 00 00       	mov    $0x23,%eax
f01032a7:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f01032a9:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f01032ab:	b8 10 00 00 00       	mov    $0x10,%eax
f01032b0:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f01032b2:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f01032b4:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f01032b6:	ea bd 32 10 f0 08 00 	ljmp   $0x8,$0xf01032bd
	asm volatile("lldt %0" : : "r" (sel));
f01032bd:	b8 00 00 00 00       	mov    $0x0,%eax
f01032c2:	0f 00 d0             	lldt   %ax
}
f01032c5:	c3                   	ret    

f01032c6 <env_init>:
{
f01032c6:	f3 0f 1e fb          	endbr32 
f01032ca:	55                   	push   %ebp
f01032cb:	89 e5                	mov    %esp,%ebp
f01032cd:	56                   	push   %esi
f01032ce:	53                   	push   %ebx
    memset(envs, 0, sizeof(struct Env) * NENV);
f01032cf:	83 ec 04             	sub    $0x4,%esp
f01032d2:	68 00 f0 01 00       	push   $0x1f000
f01032d7:	6a 00                	push   $0x0
f01032d9:	ff 35 44 b2 3b f0    	pushl  0xf03bb244
f01032df:	e8 88 2a 00 00       	call   f0105d6c <memset>
        envs[i].env_link = env_free_list;
f01032e4:	8b 35 44 b2 3b f0    	mov    0xf03bb244,%esi
f01032ea:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f01032f0:	89 f3                	mov    %esi,%ebx
f01032f2:	83 c4 10             	add    $0x10,%esp
f01032f5:	ba 00 00 00 00       	mov    $0x0,%edx
f01032fa:	89 d1                	mov    %edx,%ecx
f01032fc:	89 c2                	mov    %eax,%edx
f01032fe:	89 48 44             	mov    %ecx,0x44(%eax)
f0103301:	83 e8 7c             	sub    $0x7c,%eax
    for (int i=NENV-1; i>=0; --i) {
f0103304:	39 da                	cmp    %ebx,%edx
f0103306:	75 f2                	jne    f01032fa <env_init+0x34>
f0103308:	89 35 48 b2 3b f0    	mov    %esi,0xf03bb248
	env_init_percpu();
f010330e:	e8 83 ff ff ff       	call   f0103296 <env_init_percpu>
}
f0103313:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103316:	5b                   	pop    %ebx
f0103317:	5e                   	pop    %esi
f0103318:	5d                   	pop    %ebp
f0103319:	c3                   	ret    

f010331a <env_alloc>:
{
f010331a:	f3 0f 1e fb          	endbr32 
f010331e:	55                   	push   %ebp
f010331f:	89 e5                	mov    %esp,%ebp
f0103321:	53                   	push   %ebx
f0103322:	83 ec 04             	sub    $0x4,%esp
	if (!(e = env_free_list))
f0103325:	8b 1d 48 b2 3b f0    	mov    0xf03bb248,%ebx
f010332b:	85 db                	test   %ebx,%ebx
f010332d:	0f 84 7e 01 00 00    	je     f01034b1 <env_alloc+0x197>
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103333:	83 ec 0c             	sub    $0xc,%esp
f0103336:	6a 01                	push   $0x1
f0103338:	e8 c1 dc ff ff       	call   f0100ffe <page_alloc>
f010333d:	83 c4 10             	add    $0x10,%esp
f0103340:	85 c0                	test   %eax,%eax
f0103342:	0f 84 70 01 00 00    	je     f01034b8 <env_alloc+0x19e>
    p->pp_ref += 1;
f0103348:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f010334d:	2b 05 90 be 3b f0    	sub    0xf03bbe90,%eax
f0103353:	c1 f8 03             	sar    $0x3,%eax
f0103356:	89 c2                	mov    %eax,%edx
f0103358:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010335b:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0103360:	3b 05 88 be 3b f0    	cmp    0xf03bbe88,%eax
f0103366:	0f 83 1e 01 00 00    	jae    f010348a <env_alloc+0x170>
	return (void *)(pa + KERNBASE);
f010336c:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103372:	89 53 60             	mov    %edx,0x60(%ebx)
    e->env_pgdir = page2kva(p);
f0103375:	b8 ec 0e 00 00       	mov    $0xeec,%eax
        e->env_pgdir[i] = kern_pgdir[i];
f010337a:	8b 15 8c be 3b f0    	mov    0xf03bbe8c,%edx
f0103380:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0103383:	8b 53 60             	mov    0x60(%ebx),%edx
f0103386:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0103389:	83 c0 04             	add    $0x4,%eax
    for(int i=PDX(UTOP); i<NPDENTRIES; ++i) {
f010338c:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0103391:	75 e7                	jne    f010337a <env_alloc+0x60>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103393:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0103396:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010339b:	0f 86 fb 00 00 00    	jbe    f010349c <env_alloc+0x182>
	return (physaddr_t)kva - KERNBASE;
f01033a1:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01033a7:	83 ca 05             	or     $0x5,%edx
f01033aa:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01033b0:	8b 43 48             	mov    0x48(%ebx),%eax
f01033b3:	05 00 10 00 00       	add    $0x1000,%eax
		generation = 1 << ENVGENSHIFT;
f01033b8:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01033bd:	ba 00 10 00 00       	mov    $0x1000,%edx
f01033c2:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01033c5:	89 da                	mov    %ebx,%edx
f01033c7:	2b 15 44 b2 3b f0    	sub    0xf03bb244,%edx
f01033cd:	c1 fa 02             	sar    $0x2,%edx
f01033d0:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f01033d6:	09 d0                	or     %edx,%eax
f01033d8:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f01033db:	8b 45 0c             	mov    0xc(%ebp),%eax
f01033de:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01033e1:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01033e8:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01033ef:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01033f6:	83 ec 04             	sub    $0x4,%esp
f01033f9:	6a 44                	push   $0x44
f01033fb:	6a 00                	push   $0x0
f01033fd:	53                   	push   %ebx
f01033fe:	e8 69 29 00 00       	call   f0105d6c <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f0103403:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103409:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010340f:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103415:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010341c:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
    e->env_tf.tf_eflags = FL_IF;
f0103422:	c7 43 38 00 02 00 00 	movl   $0x200,0x38(%ebx)
	e->env_pgfault_upcall = 0;
f0103429:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_ipc_recving = 0;
f0103430:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_free_list = e->env_link;
f0103434:	8b 43 44             	mov    0x44(%ebx),%eax
f0103437:	a3 48 b2 3b f0       	mov    %eax,0xf03bb248
	*newenv_store = e;
f010343c:	8b 45 08             	mov    0x8(%ebp),%eax
f010343f:	89 18                	mov    %ebx,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103441:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103444:	e8 41 2f 00 00       	call   f010638a <cpunum>
f0103449:	6b c0 74             	imul   $0x74,%eax,%eax
f010344c:	83 c4 10             	add    $0x10,%esp
f010344f:	ba 00 00 00 00       	mov    $0x0,%edx
f0103454:	83 b8 28 c0 3b f0 00 	cmpl   $0x0,-0xfc43fd8(%eax)
f010345b:	74 11                	je     f010346e <env_alloc+0x154>
f010345d:	e8 28 2f 00 00       	call   f010638a <cpunum>
f0103462:	6b c0 74             	imul   $0x74,%eax,%eax
f0103465:	8b 80 28 c0 3b f0    	mov    -0xfc43fd8(%eax),%eax
f010346b:	8b 50 48             	mov    0x48(%eax),%edx
f010346e:	83 ec 04             	sub    $0x4,%esp
f0103471:	53                   	push   %ebx
f0103472:	52                   	push   %edx
f0103473:	68 e9 7c 10 f0       	push   $0xf0107ce9
f0103478:	e8 b0 06 00 00       	call   f0103b2d <cprintf>
	return 0;
f010347d:	83 c4 10             	add    $0x10,%esp
f0103480:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103485:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103488:	c9                   	leave  
f0103489:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010348a:	52                   	push   %edx
f010348b:	68 24 6a 10 f0       	push   $0xf0106a24
f0103490:	6a 58                	push   $0x58
f0103492:	68 ff 78 10 f0       	push   $0xf01078ff
f0103497:	e8 a4 cb ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010349c:	50                   	push   %eax
f010349d:	68 48 6a 10 f0       	push   $0xf0106a48
f01034a2:	68 c8 00 00 00       	push   $0xc8
f01034a7:	68 c0 7c 10 f0       	push   $0xf0107cc0
f01034ac:	e8 8f cb ff ff       	call   f0100040 <_panic>
		return -E_NO_FREE_ENV;
f01034b1:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01034b6:	eb cd                	jmp    f0103485 <env_alloc+0x16b>
		return -E_NO_MEM;
f01034b8:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01034bd:	eb c6                	jmp    f0103485 <env_alloc+0x16b>

f01034bf <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01034bf:	f3 0f 1e fb          	endbr32 
f01034c3:	55                   	push   %ebp
f01034c4:	89 e5                	mov    %esp,%ebp
f01034c6:	57                   	push   %edi
f01034c7:	56                   	push   %esi
f01034c8:	53                   	push   %ebx
f01034c9:	83 ec 34             	sub    $0x34,%esp
f01034cc:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.

	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.
    struct Env *new_env = NULL;
f01034cf:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    int ret = env_alloc(&new_env, 0);
f01034d6:	6a 00                	push   $0x0
f01034d8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01034db:	50                   	push   %eax
f01034dc:	e8 39 fe ff ff       	call   f010331a <env_alloc>
    if (ret == -E_NO_FREE_ENV) {
f01034e1:	83 c4 10             	add    $0x10,%esp
f01034e4:	83 f8 fb             	cmp    $0xfffffffb,%eax
f01034e7:	74 4b                	je     f0103534 <env_create+0x75>
        panic("all NENV environments are allocated!\n");
    }
    else if (ret == -E_NO_MEM) {
f01034e9:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01034ec:	74 5d                	je     f010354b <env_create+0x8c>
        panic("not enouth memory!\n");
    }
    else if (new_env == NULL) {
f01034ee:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01034f1:	85 f6                	test   %esi,%esi
f01034f3:	74 6d                	je     f0103562 <env_create+0xa3>
        panic("new env is not allocated!\n");
    }

    new_env->env_type = type;
f01034f5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034f8:	89 46 50             	mov    %eax,0x50(%esi)
	asm volatile("movl %%cr3,%0" : "=r" (val));
f01034fb:	0f 20 d8             	mov    %cr3,%eax
f01034fe:	89 45 cc             	mov    %eax,-0x34(%ebp)
    lcr3(PADDR(e->env_pgdir));
f0103501:	8b 46 60             	mov    0x60(%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f0103504:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103509:	76 6e                	jbe    f0103579 <env_create+0xba>
	return (physaddr_t)kva - KERNBASE;
f010350b:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103510:	0f 22 d8             	mov    %eax,%cr3
    if (elf->e_magic != ELF_MAGIC) {
f0103513:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0103519:	75 73                	jne    f010358e <env_create+0xcf>
    uintptr_t elf_base = (uintptr_t) elf;
f010351b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
    ph = (struct Proghdr *) (elf_base + elf->e_phoff);
f010351e:	89 fb                	mov    %edi,%ebx
f0103520:	03 5f 1c             	add    0x1c(%edi),%ebx
    eph = ph + elf->e_phnum;
f0103523:	0f b7 47 2c          	movzwl 0x2c(%edi),%eax
f0103527:	c1 e0 05             	shl    $0x5,%eax
f010352a:	01 d8                	add    %ebx,%eax
f010352c:	89 45 d0             	mov    %eax,-0x30(%ebp)
    for (; ph < eph; ++ph) {
f010352f:	e9 a9 00 00 00       	jmp    f01035dd <env_create+0x11e>
        panic("all NENV environments are allocated!\n");
f0103534:	83 ec 04             	sub    $0x4,%esp
f0103537:	68 78 7c 10 f0       	push   $0xf0107c78
f010353c:	68 b1 01 00 00       	push   $0x1b1
f0103541:	68 c0 7c 10 f0       	push   $0xf0107cc0
f0103546:	e8 f5 ca ff ff       	call   f0100040 <_panic>
        panic("not enouth memory!\n");
f010354b:	83 ec 04             	sub    $0x4,%esp
f010354e:	68 fe 7c 10 f0       	push   $0xf0107cfe
f0103553:	68 b4 01 00 00       	push   $0x1b4
f0103558:	68 c0 7c 10 f0       	push   $0xf0107cc0
f010355d:	e8 de ca ff ff       	call   f0100040 <_panic>
        panic("new env is not allocated!\n");
f0103562:	83 ec 04             	sub    $0x4,%esp
f0103565:	68 12 7d 10 f0       	push   $0xf0107d12
f010356a:	68 b7 01 00 00       	push   $0x1b7
f010356f:	68 c0 7c 10 f0       	push   $0xf0107cc0
f0103574:	e8 c7 ca ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103579:	50                   	push   %eax
f010357a:	68 48 6a 10 f0       	push   $0xf0106a48
f010357f:	68 7b 01 00 00       	push   $0x17b
f0103584:	68 c0 7c 10 f0       	push   $0xf0107cc0
f0103589:	e8 b2 ca ff ff       	call   f0100040 <_panic>
        panic("load_icode: not an ELF binary!\n");
f010358e:	83 ec 04             	sub    $0x4,%esp
f0103591:	68 a0 7c 10 f0       	push   $0xf0107ca0
f0103596:	68 81 01 00 00       	push   $0x181
f010359b:	68 c0 7c 10 f0       	push   $0xf0107cc0
f01035a0:	e8 9b ca ff ff       	call   f0100040 <_panic>
            region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f01035a5:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01035a8:	8b 53 08             	mov    0x8(%ebx),%edx
f01035ab:	89 f0                	mov    %esi,%eax
f01035ad:	e8 89 fb ff ff       	call   f010313b <region_alloc>
            memset((void *)ph->p_va, 0, ph->p_memsz);
f01035b2:	83 ec 04             	sub    $0x4,%esp
f01035b5:	ff 73 14             	pushl  0x14(%ebx)
f01035b8:	6a 00                	push   $0x0
f01035ba:	ff 73 08             	pushl  0x8(%ebx)
f01035bd:	e8 aa 27 00 00       	call   f0105d6c <memset>
            memcpy((void *)ph->p_va, (void *)(elf_base + ph->p_offset), ph->p_filesz);
f01035c2:	83 c4 0c             	add    $0xc,%esp
f01035c5:	ff 73 10             	pushl  0x10(%ebx)
f01035c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01035cb:	03 43 04             	add    0x4(%ebx),%eax
f01035ce:	50                   	push   %eax
f01035cf:	ff 73 08             	pushl  0x8(%ebx)
f01035d2:	e8 47 28 00 00       	call   f0105e1e <memcpy>
f01035d7:	83 c4 10             	add    $0x10,%esp
    for (; ph < eph; ++ph) {
f01035da:	83 c3 20             	add    $0x20,%ebx
f01035dd:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f01035e0:	76 07                	jbe    f01035e9 <env_create+0x12a>
        if (ph->p_type == ELF_PROG_LOAD) {
f01035e2:	83 3b 01             	cmpl   $0x1,(%ebx)
f01035e5:	75 f3                	jne    f01035da <env_create+0x11b>
f01035e7:	eb bc                	jmp    f01035a5 <env_create+0xe6>
    e->env_tf.tf_eip = elf->e_entry;
f01035e9:	8b 47 18             	mov    0x18(%edi),%eax
f01035ec:	89 46 30             	mov    %eax,0x30(%esi)
    region_alloc(e, (void *)(USTACKTOP-PGSIZE), PGSIZE);
f01035ef:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01035f4:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01035f9:	89 f0                	mov    %esi,%eax
f01035fb:	e8 3b fb ff ff       	call   f010313b <region_alloc>
    e->env_tf.tf_esp = USTACKTOP;
f0103600:	c7 46 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%esi)
f0103607:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010360a:	0f 22 d8             	mov    %eax,%cr3
    load_icode(new_env, binary);

}
f010360d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103610:	5b                   	pop    %ebx
f0103611:	5e                   	pop    %esi
f0103612:	5f                   	pop    %edi
f0103613:	5d                   	pop    %ebp
f0103614:	c3                   	ret    

f0103615 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103615:	f3 0f 1e fb          	endbr32 
f0103619:	55                   	push   %ebp
f010361a:	89 e5                	mov    %esp,%ebp
f010361c:	57                   	push   %edi
f010361d:	56                   	push   %esi
f010361e:	53                   	push   %ebx
f010361f:	83 ec 1c             	sub    $0x1c,%esp
f0103622:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103625:	e8 60 2d 00 00       	call   f010638a <cpunum>
f010362a:	6b c0 74             	imul   $0x74,%eax,%eax
f010362d:	39 b8 28 c0 3b f0    	cmp    %edi,-0xfc43fd8(%eax)
f0103633:	74 48                	je     f010367d <env_free+0x68>
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103635:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103638:	e8 4d 2d 00 00       	call   f010638a <cpunum>
f010363d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103640:	ba 00 00 00 00       	mov    $0x0,%edx
f0103645:	83 b8 28 c0 3b f0 00 	cmpl   $0x0,-0xfc43fd8(%eax)
f010364c:	74 11                	je     f010365f <env_free+0x4a>
f010364e:	e8 37 2d 00 00       	call   f010638a <cpunum>
f0103653:	6b c0 74             	imul   $0x74,%eax,%eax
f0103656:	8b 80 28 c0 3b f0    	mov    -0xfc43fd8(%eax),%eax
f010365c:	8b 50 48             	mov    0x48(%eax),%edx
f010365f:	83 ec 04             	sub    $0x4,%esp
f0103662:	53                   	push   %ebx
f0103663:	52                   	push   %edx
f0103664:	68 2d 7d 10 f0       	push   $0xf0107d2d
f0103669:	e8 bf 04 00 00       	call   f0103b2d <cprintf>
f010366e:	83 c4 10             	add    $0x10,%esp
f0103671:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103678:	e9 a9 00 00 00       	jmp    f0103726 <env_free+0x111>
		lcr3(PADDR(kern_pgdir));
f010367d:	a1 8c be 3b f0       	mov    0xf03bbe8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0103682:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103687:	76 0a                	jbe    f0103693 <env_free+0x7e>
	return (physaddr_t)kva - KERNBASE;
f0103689:	05 00 00 00 10       	add    $0x10000000,%eax
f010368e:	0f 22 d8             	mov    %eax,%cr3
}
f0103691:	eb a2                	jmp    f0103635 <env_free+0x20>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103693:	50                   	push   %eax
f0103694:	68 48 6a 10 f0       	push   $0xf0106a48
f0103699:	68 cd 01 00 00       	push   $0x1cd
f010369e:	68 c0 7c 10 f0       	push   $0xf0107cc0
f01036a3:	e8 98 c9 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01036a8:	56                   	push   %esi
f01036a9:	68 24 6a 10 f0       	push   $0xf0106a24
f01036ae:	68 dc 01 00 00       	push   $0x1dc
f01036b3:	68 c0 7c 10 f0       	push   $0xf0107cc0
f01036b8:	e8 83 c9 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01036bd:	83 ec 08             	sub    $0x8,%esp
f01036c0:	89 d8                	mov    %ebx,%eax
f01036c2:	c1 e0 0c             	shl    $0xc,%eax
f01036c5:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01036c8:	50                   	push   %eax
f01036c9:	ff 77 60             	pushl  0x60(%edi)
f01036cc:	e8 ad db ff ff       	call   f010127e <page_remove>
f01036d1:	83 c4 10             	add    $0x10,%esp
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01036d4:	83 c3 01             	add    $0x1,%ebx
f01036d7:	83 c6 04             	add    $0x4,%esi
f01036da:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01036e0:	74 07                	je     f01036e9 <env_free+0xd4>
			if (pt[pteno] & PTE_P)
f01036e2:	f6 06 01             	testb  $0x1,(%esi)
f01036e5:	74 ed                	je     f01036d4 <env_free+0xbf>
f01036e7:	eb d4                	jmp    f01036bd <env_free+0xa8>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01036e9:	8b 47 60             	mov    0x60(%edi),%eax
f01036ec:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01036ef:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f01036f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01036f9:	3b 05 88 be 3b f0    	cmp    0xf03bbe88,%eax
f01036ff:	73 65                	jae    f0103766 <env_free+0x151>
		page_decref(pa2page(pa));
f0103701:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103704:	a1 90 be 3b f0       	mov    0xf03bbe90,%eax
f0103709:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010370c:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f010370f:	50                   	push   %eax
f0103710:	e8 a1 d9 ff ff       	call   f01010b6 <page_decref>
f0103715:	83 c4 10             	add    $0x10,%esp
f0103718:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f010371c:	8b 45 e0             	mov    -0x20(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010371f:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0103724:	74 54                	je     f010377a <env_free+0x165>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103726:	8b 47 60             	mov    0x60(%edi),%eax
f0103729:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010372c:	8b 04 10             	mov    (%eax,%edx,1),%eax
f010372f:	a8 01                	test   $0x1,%al
f0103731:	74 e5                	je     f0103718 <env_free+0x103>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103733:	89 c6                	mov    %eax,%esi
f0103735:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f010373b:	c1 e8 0c             	shr    $0xc,%eax
f010373e:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103741:	39 05 88 be 3b f0    	cmp    %eax,0xf03bbe88
f0103747:	0f 86 5b ff ff ff    	jbe    f01036a8 <env_free+0x93>
	return (void *)(pa + KERNBASE);
f010374d:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f0103753:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103756:	c1 e0 14             	shl    $0x14,%eax
f0103759:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010375c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103761:	e9 7c ff ff ff       	jmp    f01036e2 <env_free+0xcd>
		panic("pa2page called with invalid pa");
f0103766:	83 ec 04             	sub    $0x4,%esp
f0103769:	68 ac 70 10 f0       	push   $0xf01070ac
f010376e:	6a 51                	push   $0x51
f0103770:	68 ff 78 10 f0       	push   $0xf01078ff
f0103775:	e8 c6 c8 ff ff       	call   f0100040 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010377a:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f010377d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103782:	76 49                	jbe    f01037cd <env_free+0x1b8>
	e->env_pgdir = 0;
f0103784:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f010378b:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0103790:	c1 e8 0c             	shr    $0xc,%eax
f0103793:	3b 05 88 be 3b f0    	cmp    0xf03bbe88,%eax
f0103799:	73 47                	jae    f01037e2 <env_free+0x1cd>
	page_decref(pa2page(pa));
f010379b:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f010379e:	8b 15 90 be 3b f0    	mov    0xf03bbe90,%edx
f01037a4:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01037a7:	50                   	push   %eax
f01037a8:	e8 09 d9 ff ff       	call   f01010b6 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01037ad:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01037b4:	a1 48 b2 3b f0       	mov    0xf03bb248,%eax
f01037b9:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01037bc:	89 3d 48 b2 3b f0    	mov    %edi,0xf03bb248
}
f01037c2:	83 c4 10             	add    $0x10,%esp
f01037c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01037c8:	5b                   	pop    %ebx
f01037c9:	5e                   	pop    %esi
f01037ca:	5f                   	pop    %edi
f01037cb:	5d                   	pop    %ebp
f01037cc:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037cd:	50                   	push   %eax
f01037ce:	68 48 6a 10 f0       	push   $0xf0106a48
f01037d3:	68 ea 01 00 00       	push   $0x1ea
f01037d8:	68 c0 7c 10 f0       	push   $0xf0107cc0
f01037dd:	e8 5e c8 ff ff       	call   f0100040 <_panic>
		panic("pa2page called with invalid pa");
f01037e2:	83 ec 04             	sub    $0x4,%esp
f01037e5:	68 ac 70 10 f0       	push   $0xf01070ac
f01037ea:	6a 51                	push   $0x51
f01037ec:	68 ff 78 10 f0       	push   $0xf01078ff
f01037f1:	e8 4a c8 ff ff       	call   f0100040 <_panic>

f01037f6 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01037f6:	f3 0f 1e fb          	endbr32 
f01037fa:	55                   	push   %ebp
f01037fb:	89 e5                	mov    %esp,%ebp
f01037fd:	53                   	push   %ebx
f01037fe:	83 ec 04             	sub    $0x4,%esp
f0103801:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103804:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103808:	74 21                	je     f010382b <env_destroy+0x35>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f010380a:	83 ec 0c             	sub    $0xc,%esp
f010380d:	53                   	push   %ebx
f010380e:	e8 02 fe ff ff       	call   f0103615 <env_free>

	if (curenv == e) {
f0103813:	e8 72 2b 00 00       	call   f010638a <cpunum>
f0103818:	6b c0 74             	imul   $0x74,%eax,%eax
f010381b:	83 c4 10             	add    $0x10,%esp
f010381e:	39 98 28 c0 3b f0    	cmp    %ebx,-0xfc43fd8(%eax)
f0103824:	74 1e                	je     f0103844 <env_destroy+0x4e>
		curenv = NULL;
		sched_yield();
	}
}
f0103826:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103829:	c9                   	leave  
f010382a:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f010382b:	e8 5a 2b 00 00       	call   f010638a <cpunum>
f0103830:	6b c0 74             	imul   $0x74,%eax,%eax
f0103833:	39 98 28 c0 3b f0    	cmp    %ebx,-0xfc43fd8(%eax)
f0103839:	74 cf                	je     f010380a <env_destroy+0x14>
		e->env_status = ENV_DYING;
f010383b:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103842:	eb e2                	jmp    f0103826 <env_destroy+0x30>
		curenv = NULL;
f0103844:	e8 41 2b 00 00       	call   f010638a <cpunum>
f0103849:	6b c0 74             	imul   $0x74,%eax,%eax
f010384c:	c7 80 28 c0 3b f0 00 	movl   $0x0,-0xfc43fd8(%eax)
f0103853:	00 00 00 
		sched_yield();
f0103856:	e8 8f 11 00 00       	call   f01049ea <sched_yield>

f010385b <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f010385b:	f3 0f 1e fb          	endbr32 
f010385f:	55                   	push   %ebp
f0103860:	89 e5                	mov    %esp,%ebp
f0103862:	56                   	push   %esi
f0103863:	53                   	push   %ebx
f0103864:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103867:	e8 1e 2b 00 00       	call   f010638a <cpunum>
f010386c:	6b c0 74             	imul   $0x74,%eax,%eax
f010386f:	8b b0 28 c0 3b f0    	mov    -0xfc43fd8(%eax),%esi
f0103875:	e8 10 2b 00 00       	call   f010638a <cpunum>
f010387a:	89 46 5c             	mov    %eax,0x5c(%esi)
    assert(tf->tf_eflags & FL_IF);
f010387d:	f6 43 39 02          	testb  $0x2,0x39(%ebx)
f0103881:	75 19                	jne    f010389c <env_pop_tf+0x41>
f0103883:	68 43 7d 10 f0       	push   $0xf0107d43
f0103888:	68 19 79 10 f0       	push   $0xf0107919
f010388d:	68 18 02 00 00       	push   $0x218
f0103892:	68 c0 7c 10 f0       	push   $0xf0107cc0
f0103897:	e8 a4 c7 ff ff       	call   f0100040 <_panic>

	asm volatile(
f010389c:	89 dc                	mov    %ebx,%esp
f010389e:	61                   	popa   
f010389f:	07                   	pop    %es
f01038a0:	1f                   	pop    %ds
f01038a1:	83 c4 08             	add    $0x8,%esp
f01038a4:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01038a5:	83 ec 04             	sub    $0x4,%esp
f01038a8:	68 59 7d 10 f0       	push   $0xf0107d59
f01038ad:	68 22 02 00 00       	push   $0x222
f01038b2:	68 c0 7c 10 f0       	push   $0xf0107cc0
f01038b7:	e8 84 c7 ff ff       	call   f0100040 <_panic>

f01038bc <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01038bc:	f3 0f 1e fb          	endbr32 
f01038c0:	55                   	push   %ebp
f01038c1:	89 e5                	mov    %esp,%ebp
f01038c3:	53                   	push   %ebx
f01038c4:	83 ec 04             	sub    $0x4,%esp
f01038c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

    // 1.
    if (curenv != NULL && curenv->env_status == ENV_RUNNING) {
f01038ca:	e8 bb 2a 00 00       	call   f010638a <cpunum>
f01038cf:	6b c0 74             	imul   $0x74,%eax,%eax
f01038d2:	83 b8 28 c0 3b f0 00 	cmpl   $0x0,-0xfc43fd8(%eax)
f01038d9:	74 14                	je     f01038ef <env_run+0x33>
f01038db:	e8 aa 2a 00 00       	call   f010638a <cpunum>
f01038e0:	6b c0 74             	imul   $0x74,%eax,%eax
f01038e3:	8b 80 28 c0 3b f0    	mov    -0xfc43fd8(%eax),%eax
f01038e9:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01038ed:	74 6c                	je     f010395b <env_run+0x9f>
        curenv->env_status = ENV_RUNNABLE;
    }
    // 2.
    curenv = e;
f01038ef:	e8 96 2a 00 00       	call   f010638a <cpunum>
f01038f4:	6b c0 74             	imul   $0x74,%eax,%eax
f01038f7:	89 98 28 c0 3b f0    	mov    %ebx,-0xfc43fd8(%eax)
    // 3.
    curenv->env_status = ENV_RUNNING;
f01038fd:	e8 88 2a 00 00       	call   f010638a <cpunum>
f0103902:	6b c0 74             	imul   $0x74,%eax,%eax
f0103905:	8b 80 28 c0 3b f0    	mov    -0xfc43fd8(%eax),%eax
f010390b:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
    // 4.
    curenv->env_runs += 1;
f0103912:	e8 73 2a 00 00       	call   f010638a <cpunum>
f0103917:	6b c0 74             	imul   $0x74,%eax,%eax
f010391a:	8b 80 28 c0 3b f0    	mov    -0xfc43fd8(%eax),%eax
f0103920:	83 40 58 01          	addl   $0x1,0x58(%eax)
    // 5.
    lcr3(PADDR(e->env_pgdir));
f0103924:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0103927:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010392c:	76 47                	jbe    f0103975 <env_run+0xb9>
	return (physaddr_t)kva - KERNBASE;
f010392e:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103933:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103936:	83 ec 0c             	sub    $0xc,%esp
f0103939:	68 c0 33 12 f0       	push   $0xf01233c0
f010393e:	e8 6d 2d 00 00       	call   f01066b0 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103943:	f3 90                	pause  

    unlock_kernel();

    env_pop_tf(&curenv->env_tf);
f0103945:	e8 40 2a 00 00       	call   f010638a <cpunum>
f010394a:	83 c4 04             	add    $0x4,%esp
f010394d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103950:	ff b0 28 c0 3b f0    	pushl  -0xfc43fd8(%eax)
f0103956:	e8 00 ff ff ff       	call   f010385b <env_pop_tf>
        curenv->env_status = ENV_RUNNABLE;
f010395b:	e8 2a 2a 00 00       	call   f010638a <cpunum>
f0103960:	6b c0 74             	imul   $0x74,%eax,%eax
f0103963:	8b 80 28 c0 3b f0    	mov    -0xfc43fd8(%eax),%eax
f0103969:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f0103970:	e9 7a ff ff ff       	jmp    f01038ef <env_run+0x33>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103975:	50                   	push   %eax
f0103976:	68 48 6a 10 f0       	push   $0xf0106a48
f010397b:	68 4c 02 00 00       	push   $0x24c
f0103980:	68 c0 7c 10 f0       	push   $0xf0107cc0
f0103985:	e8 b6 c6 ff ff       	call   f0100040 <_panic>

f010398a <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f010398a:	f3 0f 1e fb          	endbr32 
f010398e:	55                   	push   %ebp
f010398f:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103991:	8b 45 08             	mov    0x8(%ebp),%eax
f0103994:	ba 70 00 00 00       	mov    $0x70,%edx
f0103999:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010399a:	ba 71 00 00 00       	mov    $0x71,%edx
f010399f:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01039a0:	0f b6 c0             	movzbl %al,%eax
}
f01039a3:	5d                   	pop    %ebp
f01039a4:	c3                   	ret    

f01039a5 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01039a5:	f3 0f 1e fb          	endbr32 
f01039a9:	55                   	push   %ebp
f01039aa:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01039ac:	8b 45 08             	mov    0x8(%ebp),%eax
f01039af:	ba 70 00 00 00       	mov    $0x70,%edx
f01039b4:	ee                   	out    %al,(%dx)
f01039b5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01039b8:	ba 71 00 00 00       	mov    $0x71,%edx
f01039bd:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01039be:	5d                   	pop    %ebp
f01039bf:	c3                   	ret    

f01039c0 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01039c0:	f3 0f 1e fb          	endbr32 
f01039c4:	55                   	push   %ebp
f01039c5:	89 e5                	mov    %esp,%ebp
f01039c7:	56                   	push   %esi
f01039c8:	53                   	push   %ebx
f01039c9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f01039cc:	66 a3 a8 33 12 f0    	mov    %ax,0xf01233a8
	if (!didinit)
f01039d2:	80 3d 4c b2 3b f0 00 	cmpb   $0x0,0xf03bb24c
f01039d9:	75 07                	jne    f01039e2 <irq_setmask_8259A+0x22>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f01039db:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01039de:	5b                   	pop    %ebx
f01039df:	5e                   	pop    %esi
f01039e0:	5d                   	pop    %ebp
f01039e1:	c3                   	ret    
f01039e2:	89 c6                	mov    %eax,%esi
f01039e4:	ba 21 00 00 00       	mov    $0x21,%edx
f01039e9:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f01039ea:	66 c1 e8 08          	shr    $0x8,%ax
f01039ee:	ba a1 00 00 00       	mov    $0xa1,%edx
f01039f3:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f01039f4:	83 ec 0c             	sub    $0xc,%esp
f01039f7:	68 65 7d 10 f0       	push   $0xf0107d65
f01039fc:	e8 2c 01 00 00       	call   f0103b2d <cprintf>
f0103a01:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103a04:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103a09:	0f b7 f6             	movzwl %si,%esi
f0103a0c:	f7 d6                	not    %esi
f0103a0e:	eb 19                	jmp    f0103a29 <irq_setmask_8259A+0x69>
			cprintf(" %d", i);
f0103a10:	83 ec 08             	sub    $0x8,%esp
f0103a13:	53                   	push   %ebx
f0103a14:	68 73 82 10 f0       	push   $0xf0108273
f0103a19:	e8 0f 01 00 00       	call   f0103b2d <cprintf>
f0103a1e:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103a21:	83 c3 01             	add    $0x1,%ebx
f0103a24:	83 fb 10             	cmp    $0x10,%ebx
f0103a27:	74 07                	je     f0103a30 <irq_setmask_8259A+0x70>
		if (~mask & (1<<i))
f0103a29:	0f a3 de             	bt     %ebx,%esi
f0103a2c:	73 f3                	jae    f0103a21 <irq_setmask_8259A+0x61>
f0103a2e:	eb e0                	jmp    f0103a10 <irq_setmask_8259A+0x50>
	cprintf("\n");
f0103a30:	83 ec 0c             	sub    $0xc,%esp
f0103a33:	68 e0 7b 10 f0       	push   $0xf0107be0
f0103a38:	e8 f0 00 00 00       	call   f0103b2d <cprintf>
f0103a3d:	83 c4 10             	add    $0x10,%esp
f0103a40:	eb 99                	jmp    f01039db <irq_setmask_8259A+0x1b>

f0103a42 <pic_init>:
{
f0103a42:	f3 0f 1e fb          	endbr32 
f0103a46:	55                   	push   %ebp
f0103a47:	89 e5                	mov    %esp,%ebp
f0103a49:	57                   	push   %edi
f0103a4a:	56                   	push   %esi
f0103a4b:	53                   	push   %ebx
f0103a4c:	83 ec 0c             	sub    $0xc,%esp
	didinit = 1;
f0103a4f:	c6 05 4c b2 3b f0 01 	movb   $0x1,0xf03bb24c
f0103a56:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103a5b:	bb 21 00 00 00       	mov    $0x21,%ebx
f0103a60:	89 da                	mov    %ebx,%edx
f0103a62:	ee                   	out    %al,(%dx)
f0103a63:	b9 a1 00 00 00       	mov    $0xa1,%ecx
f0103a68:	89 ca                	mov    %ecx,%edx
f0103a6a:	ee                   	out    %al,(%dx)
f0103a6b:	bf 11 00 00 00       	mov    $0x11,%edi
f0103a70:	be 20 00 00 00       	mov    $0x20,%esi
f0103a75:	89 f8                	mov    %edi,%eax
f0103a77:	89 f2                	mov    %esi,%edx
f0103a79:	ee                   	out    %al,(%dx)
f0103a7a:	b8 20 00 00 00       	mov    $0x20,%eax
f0103a7f:	89 da                	mov    %ebx,%edx
f0103a81:	ee                   	out    %al,(%dx)
f0103a82:	b8 04 00 00 00       	mov    $0x4,%eax
f0103a87:	ee                   	out    %al,(%dx)
f0103a88:	b8 03 00 00 00       	mov    $0x3,%eax
f0103a8d:	ee                   	out    %al,(%dx)
f0103a8e:	bb a0 00 00 00       	mov    $0xa0,%ebx
f0103a93:	89 f8                	mov    %edi,%eax
f0103a95:	89 da                	mov    %ebx,%edx
f0103a97:	ee                   	out    %al,(%dx)
f0103a98:	b8 28 00 00 00       	mov    $0x28,%eax
f0103a9d:	89 ca                	mov    %ecx,%edx
f0103a9f:	ee                   	out    %al,(%dx)
f0103aa0:	b8 02 00 00 00       	mov    $0x2,%eax
f0103aa5:	ee                   	out    %al,(%dx)
f0103aa6:	b8 01 00 00 00       	mov    $0x1,%eax
f0103aab:	ee                   	out    %al,(%dx)
f0103aac:	bf 68 00 00 00       	mov    $0x68,%edi
f0103ab1:	89 f8                	mov    %edi,%eax
f0103ab3:	89 f2                	mov    %esi,%edx
f0103ab5:	ee                   	out    %al,(%dx)
f0103ab6:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0103abb:	89 c8                	mov    %ecx,%eax
f0103abd:	ee                   	out    %al,(%dx)
f0103abe:	89 f8                	mov    %edi,%eax
f0103ac0:	89 da                	mov    %ebx,%edx
f0103ac2:	ee                   	out    %al,(%dx)
f0103ac3:	89 c8                	mov    %ecx,%eax
f0103ac5:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f0103ac6:	0f b7 05 a8 33 12 f0 	movzwl 0xf01233a8,%eax
f0103acd:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103ad1:	75 08                	jne    f0103adb <pic_init+0x99>
}
f0103ad3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103ad6:	5b                   	pop    %ebx
f0103ad7:	5e                   	pop    %esi
f0103ad8:	5f                   	pop    %edi
f0103ad9:	5d                   	pop    %ebp
f0103ada:	c3                   	ret    
		irq_setmask_8259A(irq_mask_8259A);
f0103adb:	83 ec 0c             	sub    $0xc,%esp
f0103ade:	0f b7 c0             	movzwl %ax,%eax
f0103ae1:	50                   	push   %eax
f0103ae2:	e8 d9 fe ff ff       	call   f01039c0 <irq_setmask_8259A>
f0103ae7:	83 c4 10             	add    $0x10,%esp
}
f0103aea:	eb e7                	jmp    f0103ad3 <pic_init+0x91>

f0103aec <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103aec:	f3 0f 1e fb          	endbr32 
f0103af0:	55                   	push   %ebp
f0103af1:	89 e5                	mov    %esp,%ebp
f0103af3:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103af6:	ff 75 08             	pushl  0x8(%ebp)
f0103af9:	e8 ab cc ff ff       	call   f01007a9 <cputchar>
	*cnt++;
}
f0103afe:	83 c4 10             	add    $0x10,%esp
f0103b01:	c9                   	leave  
f0103b02:	c3                   	ret    

f0103b03 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103b03:	f3 0f 1e fb          	endbr32 
f0103b07:	55                   	push   %ebp
f0103b08:	89 e5                	mov    %esp,%ebp
f0103b0a:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103b0d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103b14:	ff 75 0c             	pushl  0xc(%ebp)
f0103b17:	ff 75 08             	pushl  0x8(%ebp)
f0103b1a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103b1d:	50                   	push   %eax
f0103b1e:	68 ec 3a 10 f0       	push   $0xf0103aec
f0103b23:	e8 e2 1a 00 00       	call   f010560a <vprintfmt>
	return cnt;
}
f0103b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103b2b:	c9                   	leave  
f0103b2c:	c3                   	ret    

f0103b2d <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103b2d:	f3 0f 1e fb          	endbr32 
f0103b31:	55                   	push   %ebp
f0103b32:	89 e5                	mov    %esp,%ebp
f0103b34:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103b37:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103b3a:	50                   	push   %eax
f0103b3b:	ff 75 08             	pushl  0x8(%ebp)
f0103b3e:	e8 c0 ff ff ff       	call   f0103b03 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103b43:	c9                   	leave  
f0103b44:	c3                   	ret    

f0103b45 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103b45:	f3 0f 1e fb          	endbr32 
f0103b49:	55                   	push   %ebp
f0103b4a:	89 e5                	mov    %esp,%ebp
f0103b4c:	57                   	push   %edi
f0103b4d:	56                   	push   %esi
f0103b4e:	53                   	push   %ebx
f0103b4f:	83 ec 1c             	sub    $0x1c,%esp
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
    uint32_t cpu_id = thiscpu->cpu_id;
f0103b52:	e8 33 28 00 00       	call   f010638a <cpunum>
f0103b57:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b5a:	0f b6 b8 20 c0 3b f0 	movzbl -0xfc43fe0(%eax),%edi
f0103b61:	89 f8                	mov    %edi,%eax
f0103b63:	0f b6 d8             	movzbl %al,%ebx
    thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - (KSTKSIZE + KSTKGAP) * cpu_id;
f0103b66:	e8 1f 28 00 00       	call   f010638a <cpunum>
f0103b6b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b6e:	ba 00 f0 00 00       	mov    $0xf000,%edx
f0103b73:	29 da                	sub    %ebx,%edx
f0103b75:	c1 e2 10             	shl    $0x10,%edx
f0103b78:	89 90 30 c0 3b f0    	mov    %edx,-0xfc43fd0(%eax)
    thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103b7e:	e8 07 28 00 00       	call   f010638a <cpunum>
f0103b83:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b86:	66 c7 80 34 c0 3b f0 	movw   $0x10,-0xfc43fcc(%eax)
f0103b8d:	10 00 
    thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f0103b8f:	e8 f6 27 00 00       	call   f010638a <cpunum>
f0103b94:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b97:	66 c7 80 92 c0 3b f0 	movw   $0x68,-0xfc43f6e(%eax)
f0103b9e:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cpu_id] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f0103ba0:	83 c3 05             	add    $0x5,%ebx
f0103ba3:	e8 e2 27 00 00       	call   f010638a <cpunum>
f0103ba8:	89 c6                	mov    %eax,%esi
f0103baa:	e8 db 27 00 00       	call   f010638a <cpunum>
f0103baf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103bb2:	e8 d3 27 00 00       	call   f010638a <cpunum>
f0103bb7:	66 c7 04 dd 40 33 12 	movw   $0x67,-0xfedccc0(,%ebx,8)
f0103bbe:	f0 67 00 
f0103bc1:	6b f6 74             	imul   $0x74,%esi,%esi
f0103bc4:	81 c6 2c c0 3b f0    	add    $0xf03bc02c,%esi
f0103bca:	66 89 34 dd 42 33 12 	mov    %si,-0xfedccbe(,%ebx,8)
f0103bd1:	f0 
f0103bd2:	6b 55 e4 74          	imul   $0x74,-0x1c(%ebp),%edx
f0103bd6:	81 c2 2c c0 3b f0    	add    $0xf03bc02c,%edx
f0103bdc:	c1 ea 10             	shr    $0x10,%edx
f0103bdf:	88 14 dd 44 33 12 f0 	mov    %dl,-0xfedccbc(,%ebx,8)
f0103be6:	c6 04 dd 46 33 12 f0 	movb   $0x40,-0xfedccba(,%ebx,8)
f0103bed:	40 
f0103bee:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bf1:	05 2c c0 3b f0       	add    $0xf03bc02c,%eax
f0103bf6:	c1 e8 18             	shr    $0x18,%eax
f0103bf9:	88 04 dd 47 33 12 f0 	mov    %al,-0xfedccb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpu_id].sd_s = 0;
f0103c00:	c6 04 dd 45 33 12 f0 	movb   $0x89,-0xfedccbb(,%ebx,8)
f0103c07:	89 

    ltr(GD_TSS0 + (cpu_id << 3));
f0103c08:	89 f8                	mov    %edi,%eax
f0103c0a:	0f b6 f8             	movzbl %al,%edi
f0103c0d:	8d 3c fd 28 00 00 00 	lea    0x28(,%edi,8),%edi
	asm volatile("ltr %0" : : "r" (sel));
f0103c14:	0f 00 df             	ltr    %di
	asm volatile("lidt (%0)" : : "r" (p));
f0103c17:	b8 ac 33 12 f0       	mov    $0xf01233ac,%eax
f0103c1c:	0f 01 18             	lidtl  (%eax)
    lidt(&idt_pd);


}
f0103c1f:	83 c4 1c             	add    $0x1c,%esp
f0103c22:	5b                   	pop    %ebx
f0103c23:	5e                   	pop    %esi
f0103c24:	5f                   	pop    %edi
f0103c25:	5d                   	pop    %ebp
f0103c26:	c3                   	ret    

f0103c27 <trap_init>:
{
f0103c27:	f3 0f 1e fb          	endbr32 
f0103c2b:	55                   	push   %ebp
f0103c2c:	89 e5                	mov    %esp,%ebp
f0103c2e:	83 ec 08             	sub    $0x8,%esp
    SETGATE(idt[T_DIVIDE], 0, GD_KT, t_divide, 0);
f0103c31:	b8 12 48 10 f0       	mov    $0xf0104812,%eax
f0103c36:	66 a3 60 b2 3b f0    	mov    %ax,0xf03bb260
f0103c3c:	66 c7 05 62 b2 3b f0 	movw   $0x8,0xf03bb262
f0103c43:	08 00 
f0103c45:	c6 05 64 b2 3b f0 00 	movb   $0x0,0xf03bb264
f0103c4c:	c6 05 65 b2 3b f0 8e 	movb   $0x8e,0xf03bb265
f0103c53:	c1 e8 10             	shr    $0x10,%eax
f0103c56:	66 a3 66 b2 3b f0    	mov    %ax,0xf03bb266
    SETGATE(idt[T_DEBUG], 0, GD_KT, t_debug, 0);
f0103c5c:	b8 1c 48 10 f0       	mov    $0xf010481c,%eax
f0103c61:	66 a3 68 b2 3b f0    	mov    %ax,0xf03bb268
f0103c67:	66 c7 05 6a b2 3b f0 	movw   $0x8,0xf03bb26a
f0103c6e:	08 00 
f0103c70:	c6 05 6c b2 3b f0 00 	movb   $0x0,0xf03bb26c
f0103c77:	c6 05 6d b2 3b f0 8e 	movb   $0x8e,0xf03bb26d
f0103c7e:	c1 e8 10             	shr    $0x10,%eax
f0103c81:	66 a3 6e b2 3b f0    	mov    %ax,0xf03bb26e
    SETGATE(idt[T_NMI], 0, GD_KT, t_nmi, 0);
f0103c87:	b8 26 48 10 f0       	mov    $0xf0104826,%eax
f0103c8c:	66 a3 70 b2 3b f0    	mov    %ax,0xf03bb270
f0103c92:	66 c7 05 72 b2 3b f0 	movw   $0x8,0xf03bb272
f0103c99:	08 00 
f0103c9b:	c6 05 74 b2 3b f0 00 	movb   $0x0,0xf03bb274
f0103ca2:	c6 05 75 b2 3b f0 8e 	movb   $0x8e,0xf03bb275
f0103ca9:	c1 e8 10             	shr    $0x10,%eax
f0103cac:	66 a3 76 b2 3b f0    	mov    %ax,0xf03bb276
    SETGATE(idt[T_BRKPT], 0, GD_KT, t_brkpt, 3);
f0103cb2:	b8 30 48 10 f0       	mov    $0xf0104830,%eax
f0103cb7:	66 a3 78 b2 3b f0    	mov    %ax,0xf03bb278
f0103cbd:	66 c7 05 7a b2 3b f0 	movw   $0x8,0xf03bb27a
f0103cc4:	08 00 
f0103cc6:	c6 05 7c b2 3b f0 00 	movb   $0x0,0xf03bb27c
f0103ccd:	c6 05 7d b2 3b f0 ee 	movb   $0xee,0xf03bb27d
f0103cd4:	c1 e8 10             	shr    $0x10,%eax
f0103cd7:	66 a3 7e b2 3b f0    	mov    %ax,0xf03bb27e
    SETGATE(idt[T_OFLOW], 0, GD_KT, t_oflow, 0);
f0103cdd:	b8 3a 48 10 f0       	mov    $0xf010483a,%eax
f0103ce2:	66 a3 80 b2 3b f0    	mov    %ax,0xf03bb280
f0103ce8:	66 c7 05 82 b2 3b f0 	movw   $0x8,0xf03bb282
f0103cef:	08 00 
f0103cf1:	c6 05 84 b2 3b f0 00 	movb   $0x0,0xf03bb284
f0103cf8:	c6 05 85 b2 3b f0 8e 	movb   $0x8e,0xf03bb285
f0103cff:	c1 e8 10             	shr    $0x10,%eax
f0103d02:	66 a3 86 b2 3b f0    	mov    %ax,0xf03bb286
    SETGATE(idt[T_BOUND], 0, GD_KT, t_bound, 0);
f0103d08:	b8 44 48 10 f0       	mov    $0xf0104844,%eax
f0103d0d:	66 a3 88 b2 3b f0    	mov    %ax,0xf03bb288
f0103d13:	66 c7 05 8a b2 3b f0 	movw   $0x8,0xf03bb28a
f0103d1a:	08 00 
f0103d1c:	c6 05 8c b2 3b f0 00 	movb   $0x0,0xf03bb28c
f0103d23:	c6 05 8d b2 3b f0 8e 	movb   $0x8e,0xf03bb28d
f0103d2a:	c1 e8 10             	shr    $0x10,%eax
f0103d2d:	66 a3 8e b2 3b f0    	mov    %ax,0xf03bb28e
    SETGATE(idt[T_ILLOP], 0, GD_KT, t_illop, 0);
f0103d33:	b8 4e 48 10 f0       	mov    $0xf010484e,%eax
f0103d38:	66 a3 90 b2 3b f0    	mov    %ax,0xf03bb290
f0103d3e:	66 c7 05 92 b2 3b f0 	movw   $0x8,0xf03bb292
f0103d45:	08 00 
f0103d47:	c6 05 94 b2 3b f0 00 	movb   $0x0,0xf03bb294
f0103d4e:	c6 05 95 b2 3b f0 8e 	movb   $0x8e,0xf03bb295
f0103d55:	c1 e8 10             	shr    $0x10,%eax
f0103d58:	66 a3 96 b2 3b f0    	mov    %ax,0xf03bb296
    SETGATE(idt[T_DEVICE], 0, GD_KT, t_device, 0);
f0103d5e:	b8 58 48 10 f0       	mov    $0xf0104858,%eax
f0103d63:	66 a3 98 b2 3b f0    	mov    %ax,0xf03bb298
f0103d69:	66 c7 05 9a b2 3b f0 	movw   $0x8,0xf03bb29a
f0103d70:	08 00 
f0103d72:	c6 05 9c b2 3b f0 00 	movb   $0x0,0xf03bb29c
f0103d79:	c6 05 9d b2 3b f0 8e 	movb   $0x8e,0xf03bb29d
f0103d80:	c1 e8 10             	shr    $0x10,%eax
f0103d83:	66 a3 9e b2 3b f0    	mov    %ax,0xf03bb29e
    SETGATE(idt[T_DBLFLT], 0, GD_KT, t_dblflt, 0);
f0103d89:	b8 62 48 10 f0       	mov    $0xf0104862,%eax
f0103d8e:	66 a3 a0 b2 3b f0    	mov    %ax,0xf03bb2a0
f0103d94:	66 c7 05 a2 b2 3b f0 	movw   $0x8,0xf03bb2a2
f0103d9b:	08 00 
f0103d9d:	c6 05 a4 b2 3b f0 00 	movb   $0x0,0xf03bb2a4
f0103da4:	c6 05 a5 b2 3b f0 8e 	movb   $0x8e,0xf03bb2a5
f0103dab:	c1 e8 10             	shr    $0x10,%eax
f0103dae:	66 a3 a6 b2 3b f0    	mov    %ax,0xf03bb2a6
    SETGATE(idt[T_TSS], 0, GD_KT, t_tss, 0);
f0103db4:	b8 6a 48 10 f0       	mov    $0xf010486a,%eax
f0103db9:	66 a3 b0 b2 3b f0    	mov    %ax,0xf03bb2b0
f0103dbf:	66 c7 05 b2 b2 3b f0 	movw   $0x8,0xf03bb2b2
f0103dc6:	08 00 
f0103dc8:	c6 05 b4 b2 3b f0 00 	movb   $0x0,0xf03bb2b4
f0103dcf:	c6 05 b5 b2 3b f0 8e 	movb   $0x8e,0xf03bb2b5
f0103dd6:	c1 e8 10             	shr    $0x10,%eax
f0103dd9:	66 a3 b6 b2 3b f0    	mov    %ax,0xf03bb2b6
    SETGATE(idt[T_SEGNP], 0, GD_KT, t_segnp, 0);
f0103ddf:	b8 72 48 10 f0       	mov    $0xf0104872,%eax
f0103de4:	66 a3 b8 b2 3b f0    	mov    %ax,0xf03bb2b8
f0103dea:	66 c7 05 ba b2 3b f0 	movw   $0x8,0xf03bb2ba
f0103df1:	08 00 
f0103df3:	c6 05 bc b2 3b f0 00 	movb   $0x0,0xf03bb2bc
f0103dfa:	c6 05 bd b2 3b f0 8e 	movb   $0x8e,0xf03bb2bd
f0103e01:	c1 e8 10             	shr    $0x10,%eax
f0103e04:	66 a3 be b2 3b f0    	mov    %ax,0xf03bb2be
    SETGATE(idt[T_STACK], 0, GD_KT, t_stack, 0);
f0103e0a:	b8 7a 48 10 f0       	mov    $0xf010487a,%eax
f0103e0f:	66 a3 c0 b2 3b f0    	mov    %ax,0xf03bb2c0
f0103e15:	66 c7 05 c2 b2 3b f0 	movw   $0x8,0xf03bb2c2
f0103e1c:	08 00 
f0103e1e:	c6 05 c4 b2 3b f0 00 	movb   $0x0,0xf03bb2c4
f0103e25:	c6 05 c5 b2 3b f0 8e 	movb   $0x8e,0xf03bb2c5
f0103e2c:	c1 e8 10             	shr    $0x10,%eax
f0103e2f:	66 a3 c6 b2 3b f0    	mov    %ax,0xf03bb2c6
    SETGATE(idt[T_GPFLT], 0, GD_KT, t_gpflt, 0);
f0103e35:	b8 82 48 10 f0       	mov    $0xf0104882,%eax
f0103e3a:	66 a3 c8 b2 3b f0    	mov    %ax,0xf03bb2c8
f0103e40:	66 c7 05 ca b2 3b f0 	movw   $0x8,0xf03bb2ca
f0103e47:	08 00 
f0103e49:	c6 05 cc b2 3b f0 00 	movb   $0x0,0xf03bb2cc
f0103e50:	c6 05 cd b2 3b f0 8e 	movb   $0x8e,0xf03bb2cd
f0103e57:	c1 e8 10             	shr    $0x10,%eax
f0103e5a:	66 a3 ce b2 3b f0    	mov    %ax,0xf03bb2ce
    SETGATE(idt[T_PGFLT], 0, GD_KT, t_pgflt, 0);
f0103e60:	b8 8a 48 10 f0       	mov    $0xf010488a,%eax
f0103e65:	66 a3 d0 b2 3b f0    	mov    %ax,0xf03bb2d0
f0103e6b:	66 c7 05 d2 b2 3b f0 	movw   $0x8,0xf03bb2d2
f0103e72:	08 00 
f0103e74:	c6 05 d4 b2 3b f0 00 	movb   $0x0,0xf03bb2d4
f0103e7b:	c6 05 d5 b2 3b f0 8e 	movb   $0x8e,0xf03bb2d5
f0103e82:	c1 e8 10             	shr    $0x10,%eax
f0103e85:	66 a3 d6 b2 3b f0    	mov    %ax,0xf03bb2d6
    SETGATE(idt[T_FPERR], 0, GD_KT, t_fperr, 0);
f0103e8b:	b8 8e 48 10 f0       	mov    $0xf010488e,%eax
f0103e90:	66 a3 e0 b2 3b f0    	mov    %ax,0xf03bb2e0
f0103e96:	66 c7 05 e2 b2 3b f0 	movw   $0x8,0xf03bb2e2
f0103e9d:	08 00 
f0103e9f:	c6 05 e4 b2 3b f0 00 	movb   $0x0,0xf03bb2e4
f0103ea6:	c6 05 e5 b2 3b f0 8e 	movb   $0x8e,0xf03bb2e5
f0103ead:	c1 e8 10             	shr    $0x10,%eax
f0103eb0:	66 a3 e6 b2 3b f0    	mov    %ax,0xf03bb2e6
    SETGATE(idt[T_ALIGN], 0, GD_KT, t_align, 0);
f0103eb6:	b8 94 48 10 f0       	mov    $0xf0104894,%eax
f0103ebb:	66 a3 e8 b2 3b f0    	mov    %ax,0xf03bb2e8
f0103ec1:	66 c7 05 ea b2 3b f0 	movw   $0x8,0xf03bb2ea
f0103ec8:	08 00 
f0103eca:	c6 05 ec b2 3b f0 00 	movb   $0x0,0xf03bb2ec
f0103ed1:	c6 05 ed b2 3b f0 8e 	movb   $0x8e,0xf03bb2ed
f0103ed8:	c1 e8 10             	shr    $0x10,%eax
f0103edb:	66 a3 ee b2 3b f0    	mov    %ax,0xf03bb2ee
    SETGATE(idt[T_MCHK], 0, GD_KT, t_mchk, 0);
f0103ee1:	b8 98 48 10 f0       	mov    $0xf0104898,%eax
f0103ee6:	66 a3 f0 b2 3b f0    	mov    %ax,0xf03bb2f0
f0103eec:	66 c7 05 f2 b2 3b f0 	movw   $0x8,0xf03bb2f2
f0103ef3:	08 00 
f0103ef5:	c6 05 f4 b2 3b f0 00 	movb   $0x0,0xf03bb2f4
f0103efc:	c6 05 f5 b2 3b f0 8e 	movb   $0x8e,0xf03bb2f5
f0103f03:	c1 e8 10             	shr    $0x10,%eax
f0103f06:	66 a3 f6 b2 3b f0    	mov    %ax,0xf03bb2f6
    SETGATE(idt[T_SIMDERR], 0, GD_KT, t_simderr, 0);
f0103f0c:	b8 9e 48 10 f0       	mov    $0xf010489e,%eax
f0103f11:	66 a3 f8 b2 3b f0    	mov    %ax,0xf03bb2f8
f0103f17:	66 c7 05 fa b2 3b f0 	movw   $0x8,0xf03bb2fa
f0103f1e:	08 00 
f0103f20:	c6 05 fc b2 3b f0 00 	movb   $0x0,0xf03bb2fc
f0103f27:	c6 05 fd b2 3b f0 8e 	movb   $0x8e,0xf03bb2fd
f0103f2e:	c1 e8 10             	shr    $0x10,%eax
f0103f31:	66 a3 fe b2 3b f0    	mov    %ax,0xf03bb2fe
    SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, t_irq_timer, 0);
f0103f37:	b8 a4 48 10 f0       	mov    $0xf01048a4,%eax
f0103f3c:	66 a3 60 b3 3b f0    	mov    %ax,0xf03bb360
f0103f42:	66 c7 05 62 b3 3b f0 	movw   $0x8,0xf03bb362
f0103f49:	08 00 
f0103f4b:	c6 05 64 b3 3b f0 00 	movb   $0x0,0xf03bb364
f0103f52:	c6 05 65 b3 3b f0 8e 	movb   $0x8e,0xf03bb365
f0103f59:	c1 e8 10             	shr    $0x10,%eax
f0103f5c:	66 a3 66 b3 3b f0    	mov    %ax,0xf03bb366
    SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0, GD_KT, t_irq_kbd, 0);
f0103f62:	b8 aa 48 10 f0       	mov    $0xf01048aa,%eax
f0103f67:	66 a3 68 b3 3b f0    	mov    %ax,0xf03bb368
f0103f6d:	66 c7 05 6a b3 3b f0 	movw   $0x8,0xf03bb36a
f0103f74:	08 00 
f0103f76:	c6 05 6c b3 3b f0 00 	movb   $0x0,0xf03bb36c
f0103f7d:	c6 05 6d b3 3b f0 8e 	movb   $0x8e,0xf03bb36d
f0103f84:	c1 e8 10             	shr    $0x10,%eax
f0103f87:	66 a3 6e b3 3b f0    	mov    %ax,0xf03bb36e
    SETGATE(idt[IRQ_OFFSET + 2], 0, GD_KT, t_irq_2, 0);
f0103f8d:	b8 b0 48 10 f0       	mov    $0xf01048b0,%eax
f0103f92:	66 a3 70 b3 3b f0    	mov    %ax,0xf03bb370
f0103f98:	66 c7 05 72 b3 3b f0 	movw   $0x8,0xf03bb372
f0103f9f:	08 00 
f0103fa1:	c6 05 74 b3 3b f0 00 	movb   $0x0,0xf03bb374
f0103fa8:	c6 05 75 b3 3b f0 8e 	movb   $0x8e,0xf03bb375
f0103faf:	c1 e8 10             	shr    $0x10,%eax
f0103fb2:	66 a3 76 b3 3b f0    	mov    %ax,0xf03bb376
    SETGATE(idt[IRQ_OFFSET + 3], 0, GD_KT, t_irq_3, 0);
f0103fb8:	b8 b6 48 10 f0       	mov    $0xf01048b6,%eax
f0103fbd:	66 a3 78 b3 3b f0    	mov    %ax,0xf03bb378
f0103fc3:	66 c7 05 7a b3 3b f0 	movw   $0x8,0xf03bb37a
f0103fca:	08 00 
f0103fcc:	c6 05 7c b3 3b f0 00 	movb   $0x0,0xf03bb37c
f0103fd3:	c6 05 7d b3 3b f0 8e 	movb   $0x8e,0xf03bb37d
f0103fda:	c1 e8 10             	shr    $0x10,%eax
f0103fdd:	66 a3 7e b3 3b f0    	mov    %ax,0xf03bb37e
    SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0, GD_KT, t_irq_serial, 0);
f0103fe3:	b8 bc 48 10 f0       	mov    $0xf01048bc,%eax
f0103fe8:	66 a3 80 b3 3b f0    	mov    %ax,0xf03bb380
f0103fee:	66 c7 05 82 b3 3b f0 	movw   $0x8,0xf03bb382
f0103ff5:	08 00 
f0103ff7:	c6 05 84 b3 3b f0 00 	movb   $0x0,0xf03bb384
f0103ffe:	c6 05 85 b3 3b f0 8e 	movb   $0x8e,0xf03bb385
f0104005:	c1 e8 10             	shr    $0x10,%eax
f0104008:	66 a3 86 b3 3b f0    	mov    %ax,0xf03bb386
    SETGATE(idt[IRQ_OFFSET + 5], 0, GD_KT, t_irq_5, 0);
f010400e:	b8 c2 48 10 f0       	mov    $0xf01048c2,%eax
f0104013:	66 a3 88 b3 3b f0    	mov    %ax,0xf03bb388
f0104019:	66 c7 05 8a b3 3b f0 	movw   $0x8,0xf03bb38a
f0104020:	08 00 
f0104022:	c6 05 8c b3 3b f0 00 	movb   $0x0,0xf03bb38c
f0104029:	c6 05 8d b3 3b f0 8e 	movb   $0x8e,0xf03bb38d
f0104030:	c1 e8 10             	shr    $0x10,%eax
f0104033:	66 a3 8e b3 3b f0    	mov    %ax,0xf03bb38e
    SETGATE(idt[IRQ_OFFSET + 6], 0, GD_KT, t_irq_6, 0);
f0104039:	b8 c8 48 10 f0       	mov    $0xf01048c8,%eax
f010403e:	66 a3 90 b3 3b f0    	mov    %ax,0xf03bb390
f0104044:	66 c7 05 92 b3 3b f0 	movw   $0x8,0xf03bb392
f010404b:	08 00 
f010404d:	c6 05 94 b3 3b f0 00 	movb   $0x0,0xf03bb394
f0104054:	c6 05 95 b3 3b f0 8e 	movb   $0x8e,0xf03bb395
f010405b:	c1 e8 10             	shr    $0x10,%eax
f010405e:	66 a3 96 b3 3b f0    	mov    %ax,0xf03bb396
    SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, t_irq_spurious, 0);
f0104064:	b8 ce 48 10 f0       	mov    $0xf01048ce,%eax
f0104069:	66 a3 98 b3 3b f0    	mov    %ax,0xf03bb398
f010406f:	66 c7 05 9a b3 3b f0 	movw   $0x8,0xf03bb39a
f0104076:	08 00 
f0104078:	c6 05 9c b3 3b f0 00 	movb   $0x0,0xf03bb39c
f010407f:	c6 05 9d b3 3b f0 8e 	movb   $0x8e,0xf03bb39d
f0104086:	c1 e8 10             	shr    $0x10,%eax
f0104089:	66 a3 9e b3 3b f0    	mov    %ax,0xf03bb39e
    SETGATE(idt[IRQ_OFFSET + 8], 0, GD_KT, t_irq_8, 0);
f010408f:	b8 d4 48 10 f0       	mov    $0xf01048d4,%eax
f0104094:	66 a3 a0 b3 3b f0    	mov    %ax,0xf03bb3a0
f010409a:	66 c7 05 a2 b3 3b f0 	movw   $0x8,0xf03bb3a2
f01040a1:	08 00 
f01040a3:	c6 05 a4 b3 3b f0 00 	movb   $0x0,0xf03bb3a4
f01040aa:	c6 05 a5 b3 3b f0 8e 	movb   $0x8e,0xf03bb3a5
f01040b1:	c1 e8 10             	shr    $0x10,%eax
f01040b4:	66 a3 a6 b3 3b f0    	mov    %ax,0xf03bb3a6
    SETGATE(idt[IRQ_OFFSET + 9], 0, GD_KT, t_irq_9, 0);
f01040ba:	b8 da 48 10 f0       	mov    $0xf01048da,%eax
f01040bf:	66 a3 a8 b3 3b f0    	mov    %ax,0xf03bb3a8
f01040c5:	66 c7 05 aa b3 3b f0 	movw   $0x8,0xf03bb3aa
f01040cc:	08 00 
f01040ce:	c6 05 ac b3 3b f0 00 	movb   $0x0,0xf03bb3ac
f01040d5:	c6 05 ad b3 3b f0 8e 	movb   $0x8e,0xf03bb3ad
f01040dc:	c1 e8 10             	shr    $0x10,%eax
f01040df:	66 a3 ae b3 3b f0    	mov    %ax,0xf03bb3ae
    SETGATE(idt[IRQ_OFFSET + 10], 0, GD_KT, t_irq_10, 0);
f01040e5:	b8 e0 48 10 f0       	mov    $0xf01048e0,%eax
f01040ea:	66 a3 b0 b3 3b f0    	mov    %ax,0xf03bb3b0
f01040f0:	66 c7 05 b2 b3 3b f0 	movw   $0x8,0xf03bb3b2
f01040f7:	08 00 
f01040f9:	c6 05 b4 b3 3b f0 00 	movb   $0x0,0xf03bb3b4
f0104100:	c6 05 b5 b3 3b f0 8e 	movb   $0x8e,0xf03bb3b5
f0104107:	c1 e8 10             	shr    $0x10,%eax
f010410a:	66 a3 b6 b3 3b f0    	mov    %ax,0xf03bb3b6
    SETGATE(idt[IRQ_OFFSET + 11], 0, GD_KT, t_irq_11, 0);
f0104110:	b8 e6 48 10 f0       	mov    $0xf01048e6,%eax
f0104115:	66 a3 b8 b3 3b f0    	mov    %ax,0xf03bb3b8
f010411b:	66 c7 05 ba b3 3b f0 	movw   $0x8,0xf03bb3ba
f0104122:	08 00 
f0104124:	c6 05 bc b3 3b f0 00 	movb   $0x0,0xf03bb3bc
f010412b:	c6 05 bd b3 3b f0 8e 	movb   $0x8e,0xf03bb3bd
f0104132:	c1 e8 10             	shr    $0x10,%eax
f0104135:	66 a3 be b3 3b f0    	mov    %ax,0xf03bb3be
    SETGATE(idt[IRQ_OFFSET + 12], 0, GD_KT, t_irq_12, 0);
f010413b:	b8 ec 48 10 f0       	mov    $0xf01048ec,%eax
f0104140:	66 a3 c0 b3 3b f0    	mov    %ax,0xf03bb3c0
f0104146:	66 c7 05 c2 b3 3b f0 	movw   $0x8,0xf03bb3c2
f010414d:	08 00 
f010414f:	c6 05 c4 b3 3b f0 00 	movb   $0x0,0xf03bb3c4
f0104156:	c6 05 c5 b3 3b f0 8e 	movb   $0x8e,0xf03bb3c5
f010415d:	c1 e8 10             	shr    $0x10,%eax
f0104160:	66 a3 c6 b3 3b f0    	mov    %ax,0xf03bb3c6
    SETGATE(idt[IRQ_OFFSET + 13], 0, GD_KT, t_irq_13, 0);
f0104166:	b8 f2 48 10 f0       	mov    $0xf01048f2,%eax
f010416b:	66 a3 c8 b3 3b f0    	mov    %ax,0xf03bb3c8
f0104171:	66 c7 05 ca b3 3b f0 	movw   $0x8,0xf03bb3ca
f0104178:	08 00 
f010417a:	c6 05 cc b3 3b f0 00 	movb   $0x0,0xf03bb3cc
f0104181:	c6 05 cd b3 3b f0 8e 	movb   $0x8e,0xf03bb3cd
f0104188:	c1 e8 10             	shr    $0x10,%eax
f010418b:	66 a3 ce b3 3b f0    	mov    %ax,0xf03bb3ce
    SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 0, GD_KT, t_irq_ide, 0);
f0104191:	b8 f8 48 10 f0       	mov    $0xf01048f8,%eax
f0104196:	66 a3 d0 b3 3b f0    	mov    %ax,0xf03bb3d0
f010419c:	66 c7 05 d2 b3 3b f0 	movw   $0x8,0xf03bb3d2
f01041a3:	08 00 
f01041a5:	c6 05 d4 b3 3b f0 00 	movb   $0x0,0xf03bb3d4
f01041ac:	c6 05 d5 b3 3b f0 8e 	movb   $0x8e,0xf03bb3d5
f01041b3:	c1 e8 10             	shr    $0x10,%eax
f01041b6:	66 a3 d6 b3 3b f0    	mov    %ax,0xf03bb3d6
    SETGATE(idt[IRQ_OFFSET + 15], 0, GD_KT, t_irq_15, 0);
f01041bc:	b8 fe 48 10 f0       	mov    $0xf01048fe,%eax
f01041c1:	66 a3 d8 b3 3b f0    	mov    %ax,0xf03bb3d8
f01041c7:	66 c7 05 da b3 3b f0 	movw   $0x8,0xf03bb3da
f01041ce:	08 00 
f01041d0:	c6 05 dc b3 3b f0 00 	movb   $0x0,0xf03bb3dc
f01041d7:	c6 05 dd b3 3b f0 8e 	movb   $0x8e,0xf03bb3dd
f01041de:	c1 e8 10             	shr    $0x10,%eax
f01041e1:	66 a3 de b3 3b f0    	mov    %ax,0xf03bb3de
    SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall, 3);
f01041e7:	b8 04 49 10 f0       	mov    $0xf0104904,%eax
f01041ec:	66 a3 e0 b3 3b f0    	mov    %ax,0xf03bb3e0
f01041f2:	66 c7 05 e2 b3 3b f0 	movw   $0x8,0xf03bb3e2
f01041f9:	08 00 
f01041fb:	c6 05 e4 b3 3b f0 00 	movb   $0x0,0xf03bb3e4
f0104202:	c6 05 e5 b3 3b f0 ee 	movb   $0xee,0xf03bb3e5
f0104209:	c1 e8 10             	shr    $0x10,%eax
f010420c:	66 a3 e6 b3 3b f0    	mov    %ax,0xf03bb3e6
	trap_init_percpu();
f0104212:	e8 2e f9 ff ff       	call   f0103b45 <trap_init_percpu>
}
f0104217:	c9                   	leave  
f0104218:	c3                   	ret    

f0104219 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0104219:	f3 0f 1e fb          	endbr32 
f010421d:	55                   	push   %ebp
f010421e:	89 e5                	mov    %esp,%ebp
f0104220:	53                   	push   %ebx
f0104221:	83 ec 0c             	sub    $0xc,%esp
f0104224:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0104227:	ff 33                	pushl  (%ebx)
f0104229:	68 79 7d 10 f0       	push   $0xf0107d79
f010422e:	e8 fa f8 ff ff       	call   f0103b2d <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0104233:	83 c4 08             	add    $0x8,%esp
f0104236:	ff 73 04             	pushl  0x4(%ebx)
f0104239:	68 88 7d 10 f0       	push   $0xf0107d88
f010423e:	e8 ea f8 ff ff       	call   f0103b2d <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0104243:	83 c4 08             	add    $0x8,%esp
f0104246:	ff 73 08             	pushl  0x8(%ebx)
f0104249:	68 97 7d 10 f0       	push   $0xf0107d97
f010424e:	e8 da f8 ff ff       	call   f0103b2d <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104253:	83 c4 08             	add    $0x8,%esp
f0104256:	ff 73 0c             	pushl  0xc(%ebx)
f0104259:	68 a6 7d 10 f0       	push   $0xf0107da6
f010425e:	e8 ca f8 ff ff       	call   f0103b2d <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104263:	83 c4 08             	add    $0x8,%esp
f0104266:	ff 73 10             	pushl  0x10(%ebx)
f0104269:	68 b5 7d 10 f0       	push   $0xf0107db5
f010426e:	e8 ba f8 ff ff       	call   f0103b2d <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104273:	83 c4 08             	add    $0x8,%esp
f0104276:	ff 73 14             	pushl  0x14(%ebx)
f0104279:	68 c4 7d 10 f0       	push   $0xf0107dc4
f010427e:	e8 aa f8 ff ff       	call   f0103b2d <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0104283:	83 c4 08             	add    $0x8,%esp
f0104286:	ff 73 18             	pushl  0x18(%ebx)
f0104289:	68 d3 7d 10 f0       	push   $0xf0107dd3
f010428e:	e8 9a f8 ff ff       	call   f0103b2d <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0104293:	83 c4 08             	add    $0x8,%esp
f0104296:	ff 73 1c             	pushl  0x1c(%ebx)
f0104299:	68 e2 7d 10 f0       	push   $0xf0107de2
f010429e:	e8 8a f8 ff ff       	call   f0103b2d <cprintf>
}
f01042a3:	83 c4 10             	add    $0x10,%esp
f01042a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01042a9:	c9                   	leave  
f01042aa:	c3                   	ret    

f01042ab <print_trapframe>:
{
f01042ab:	f3 0f 1e fb          	endbr32 
f01042af:	55                   	push   %ebp
f01042b0:	89 e5                	mov    %esp,%ebp
f01042b2:	56                   	push   %esi
f01042b3:	53                   	push   %ebx
f01042b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01042b7:	e8 ce 20 00 00       	call   f010638a <cpunum>
f01042bc:	83 ec 04             	sub    $0x4,%esp
f01042bf:	50                   	push   %eax
f01042c0:	53                   	push   %ebx
f01042c1:	68 46 7e 10 f0       	push   $0xf0107e46
f01042c6:	e8 62 f8 ff ff       	call   f0103b2d <cprintf>
	print_regs(&tf->tf_regs);
f01042cb:	89 1c 24             	mov    %ebx,(%esp)
f01042ce:	e8 46 ff ff ff       	call   f0104219 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01042d3:	83 c4 08             	add    $0x8,%esp
f01042d6:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01042da:	50                   	push   %eax
f01042db:	68 64 7e 10 f0       	push   $0xf0107e64
f01042e0:	e8 48 f8 ff ff       	call   f0103b2d <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01042e5:	83 c4 08             	add    $0x8,%esp
f01042e8:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01042ec:	50                   	push   %eax
f01042ed:	68 77 7e 10 f0       	push   $0xf0107e77
f01042f2:	e8 36 f8 ff ff       	call   f0103b2d <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01042f7:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f01042fa:	83 c4 10             	add    $0x10,%esp
f01042fd:	83 f8 13             	cmp    $0x13,%eax
f0104300:	0f 86 da 00 00 00    	jbe    f01043e0 <print_trapframe+0x135>
		return "System call";
f0104306:	ba f1 7d 10 f0       	mov    $0xf0107df1,%edx
	if (trapno == T_SYSCALL)
f010430b:	83 f8 30             	cmp    $0x30,%eax
f010430e:	74 13                	je     f0104323 <print_trapframe+0x78>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104310:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f0104313:	83 fa 0f             	cmp    $0xf,%edx
f0104316:	ba fd 7d 10 f0       	mov    $0xf0107dfd,%edx
f010431b:	b9 0c 7e 10 f0       	mov    $0xf0107e0c,%ecx
f0104320:	0f 46 d1             	cmovbe %ecx,%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104323:	83 ec 04             	sub    $0x4,%esp
f0104326:	52                   	push   %edx
f0104327:	50                   	push   %eax
f0104328:	68 8a 7e 10 f0       	push   $0xf0107e8a
f010432d:	e8 fb f7 ff ff       	call   f0103b2d <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104332:	83 c4 10             	add    $0x10,%esp
f0104335:	39 1d 60 ba 3b f0    	cmp    %ebx,0xf03bba60
f010433b:	0f 84 ab 00 00 00    	je     f01043ec <print_trapframe+0x141>
	cprintf("  err  0x%08x", tf->tf_err);
f0104341:	83 ec 08             	sub    $0x8,%esp
f0104344:	ff 73 2c             	pushl  0x2c(%ebx)
f0104347:	68 ab 7e 10 f0       	push   $0xf0107eab
f010434c:	e8 dc f7 ff ff       	call   f0103b2d <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0104351:	83 c4 10             	add    $0x10,%esp
f0104354:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104358:	0f 85 b1 00 00 00    	jne    f010440f <print_trapframe+0x164>
			tf->tf_err & 1 ? "protection" : "not-present");
f010435e:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f0104361:	a8 01                	test   $0x1,%al
f0104363:	b9 1f 7e 10 f0       	mov    $0xf0107e1f,%ecx
f0104368:	ba 2a 7e 10 f0       	mov    $0xf0107e2a,%edx
f010436d:	0f 44 ca             	cmove  %edx,%ecx
f0104370:	a8 02                	test   $0x2,%al
f0104372:	be 36 7e 10 f0       	mov    $0xf0107e36,%esi
f0104377:	ba 3c 7e 10 f0       	mov    $0xf0107e3c,%edx
f010437c:	0f 45 d6             	cmovne %esi,%edx
f010437f:	a8 04                	test   $0x4,%al
f0104381:	b8 41 7e 10 f0       	mov    $0xf0107e41,%eax
f0104386:	be 76 7f 10 f0       	mov    $0xf0107f76,%esi
f010438b:	0f 44 c6             	cmove  %esi,%eax
f010438e:	51                   	push   %ecx
f010438f:	52                   	push   %edx
f0104390:	50                   	push   %eax
f0104391:	68 b9 7e 10 f0       	push   $0xf0107eb9
f0104396:	e8 92 f7 ff ff       	call   f0103b2d <cprintf>
f010439b:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f010439e:	83 ec 08             	sub    $0x8,%esp
f01043a1:	ff 73 30             	pushl  0x30(%ebx)
f01043a4:	68 c8 7e 10 f0       	push   $0xf0107ec8
f01043a9:	e8 7f f7 ff ff       	call   f0103b2d <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01043ae:	83 c4 08             	add    $0x8,%esp
f01043b1:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01043b5:	50                   	push   %eax
f01043b6:	68 d7 7e 10 f0       	push   $0xf0107ed7
f01043bb:	e8 6d f7 ff ff       	call   f0103b2d <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01043c0:	83 c4 08             	add    $0x8,%esp
f01043c3:	ff 73 38             	pushl  0x38(%ebx)
f01043c6:	68 ea 7e 10 f0       	push   $0xf0107eea
f01043cb:	e8 5d f7 ff ff       	call   f0103b2d <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01043d0:	83 c4 10             	add    $0x10,%esp
f01043d3:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01043d7:	75 4b                	jne    f0104424 <print_trapframe+0x179>
}
f01043d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01043dc:	5b                   	pop    %ebx
f01043dd:	5e                   	pop    %esi
f01043de:	5d                   	pop    %ebp
f01043df:	c3                   	ret    
		return excnames[trapno];
f01043e0:	8b 14 85 20 81 10 f0 	mov    -0xfef7ee0(,%eax,4),%edx
f01043e7:	e9 37 ff ff ff       	jmp    f0104323 <print_trapframe+0x78>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01043ec:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01043f0:	0f 85 4b ff ff ff    	jne    f0104341 <print_trapframe+0x96>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f01043f6:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01043f9:	83 ec 08             	sub    $0x8,%esp
f01043fc:	50                   	push   %eax
f01043fd:	68 9c 7e 10 f0       	push   $0xf0107e9c
f0104402:	e8 26 f7 ff ff       	call   f0103b2d <cprintf>
f0104407:	83 c4 10             	add    $0x10,%esp
f010440a:	e9 32 ff ff ff       	jmp    f0104341 <print_trapframe+0x96>
		cprintf("\n");
f010440f:	83 ec 0c             	sub    $0xc,%esp
f0104412:	68 e0 7b 10 f0       	push   $0xf0107be0
f0104417:	e8 11 f7 ff ff       	call   f0103b2d <cprintf>
f010441c:	83 c4 10             	add    $0x10,%esp
f010441f:	e9 7a ff ff ff       	jmp    f010439e <print_trapframe+0xf3>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104424:	83 ec 08             	sub    $0x8,%esp
f0104427:	ff 73 3c             	pushl  0x3c(%ebx)
f010442a:	68 f9 7e 10 f0       	push   $0xf0107ef9
f010442f:	e8 f9 f6 ff ff       	call   f0103b2d <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104434:	83 c4 08             	add    $0x8,%esp
f0104437:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010443b:	50                   	push   %eax
f010443c:	68 08 7f 10 f0       	push   $0xf0107f08
f0104441:	e8 e7 f6 ff ff       	call   f0103b2d <cprintf>
f0104446:	83 c4 10             	add    $0x10,%esp
}
f0104449:	eb 8e                	jmp    f01043d9 <print_trapframe+0x12e>

f010444b <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010444b:	f3 0f 1e fb          	endbr32 
f010444f:	55                   	push   %ebp
f0104450:	89 e5                	mov    %esp,%ebp
f0104452:	57                   	push   %edi
f0104453:	56                   	push   %esi
f0104454:	53                   	push   %ebx
f0104455:	83 ec 3c             	sub    $0x3c,%esp
f0104458:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010445b:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
    if ((tf->tf_cs&0x3) == 0) {
f010445e:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104462:	74 5a                	je     f01044be <page_fault_handler+0x73>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
    if (curenv->env_pgfault_upcall == NULL) {
f0104464:	e8 21 1f 00 00       	call   f010638a <cpunum>
f0104469:	6b c0 74             	imul   $0x74,%eax,%eax
f010446c:	8b 80 28 c0 3b f0    	mov    -0xfc43fd8(%eax),%eax
f0104472:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104476:	75 64                	jne    f01044dc <page_fault_handler+0x91>
        // no pgfault handler!
        // Destroy the environment that caused the fault.
        cprintf("[%08x] user fault va %08x ip %08x\n",
f0104478:	8b 7b 30             	mov    0x30(%ebx),%edi
                curenv->env_id, fault_va, tf->tf_eip);
f010447b:	e8 0a 1f 00 00       	call   f010638a <cpunum>
        cprintf("[%08x] user fault va %08x ip %08x\n",
f0104480:	57                   	push   %edi
f0104481:	56                   	push   %esi
                curenv->env_id, fault_va, tf->tf_eip);
f0104482:	6b c0 74             	imul   $0x74,%eax,%eax
        cprintf("[%08x] user fault va %08x ip %08x\n",
f0104485:	8b 80 28 c0 3b f0    	mov    -0xfc43fd8(%eax),%eax
f010448b:	ff 70 48             	pushl  0x48(%eax)
f010448e:	68 f0 80 10 f0       	push   $0xf01080f0
f0104493:	e8 95 f6 ff ff       	call   f0103b2d <cprintf>
        print_trapframe(tf);
f0104498:	89 1c 24             	mov    %ebx,(%esp)
f010449b:	e8 0b fe ff ff       	call   f01042ab <print_trapframe>
        env_destroy(curenv);
f01044a0:	e8 e5 1e 00 00       	call   f010638a <cpunum>
f01044a5:	83 c4 04             	add    $0x4,%esp
f01044a8:	6b c0 74             	imul   $0x74,%eax,%eax
f01044ab:	ff b0 28 c0 3b f0    	pushl  -0xfc43fd8(%eax)
f01044b1:	e8 40 f3 ff ff       	call   f01037f6 <env_destroy>

    tf->tf_eip = (uintptr_t) curenv->env_pgfault_upcall;

    env_run(curenv);

}
f01044b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01044b9:	5b                   	pop    %ebx
f01044ba:	5e                   	pop    %esi
f01044bb:	5f                   	pop    %edi
f01044bc:	5d                   	pop    %ebp
f01044bd:	c3                   	ret    
        print_trapframe(tf);
f01044be:	83 ec 0c             	sub    $0xc,%esp
f01044c1:	53                   	push   %ebx
f01044c2:	e8 e4 fd ff ff       	call   f01042ab <print_trapframe>
        panic("page_fault_handler: kernel page fault at %p\n", fault_va);
f01044c7:	56                   	push   %esi
f01044c8:	68 c0 80 10 f0       	push   $0xf01080c0
f01044cd:	68 90 01 00 00       	push   $0x190
f01044d2:	68 1b 7f 10 f0       	push   $0xf0107f1b
f01044d7:	e8 64 bb ff ff       	call   f0100040 <_panic>
    utf.utf_err = tf->tf_err;
f01044dc:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01044df:	89 45 e0             	mov    %eax,-0x20(%ebp)
    utf.utf_regs = tf->tf_regs;
f01044e2:	8b 03                	mov    (%ebx),%eax
f01044e4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01044e7:	8b 43 04             	mov    0x4(%ebx),%eax
f01044ea:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01044ed:	8b 43 08             	mov    0x8(%ebx),%eax
f01044f0:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01044f3:	8b 43 0c             	mov    0xc(%ebx),%eax
f01044f6:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01044f9:	8b 43 10             	mov    0x10(%ebx),%eax
f01044fc:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01044ff:	8b 43 14             	mov    0x14(%ebx),%eax
f0104502:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0104505:	8b 43 18             	mov    0x18(%ebx),%eax
f0104508:	89 45 bc             	mov    %eax,-0x44(%ebp)
f010450b:	8b 43 1c             	mov    0x1c(%ebx),%eax
f010450e:	89 45 b8             	mov    %eax,-0x48(%ebp)
    utf.utf_eip = tf->tf_eip;
f0104511:	8b 43 30             	mov    0x30(%ebx),%eax
f0104514:	89 45 dc             	mov    %eax,-0x24(%ebp)
    utf.utf_eflags = tf->tf_eflags;
f0104517:	8b 43 38             	mov    0x38(%ebx),%eax
f010451a:	89 45 d8             	mov    %eax,-0x28(%ebp)
    utf.utf_esp = tf->tf_esp;
f010451d:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104520:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (ROUNDUP(utf.utf_esp, PGSIZE) == UXSTACKTOP) {
f0104523:	05 ff 0f 00 00       	add    $0xfff,%eax
f0104528:	25 00 f0 ff ff       	and    $0xfffff000,%eax
        tf->tf_esp = UXSTACKTOP;
f010452d:	bf 00 00 c0 ee       	mov    $0xeec00000,%edi
    if (ROUNDUP(utf.utf_esp, PGSIZE) == UXSTACKTOP) {
f0104532:	3d 00 00 c0 ee       	cmp    $0xeec00000,%eax
f0104537:	0f 84 95 00 00 00    	je     f01045d2 <page_fault_handler+0x187>
    tf->tf_esp -= sizeof(struct UTrapframe);
f010453d:	83 ef 34             	sub    $0x34,%edi
f0104540:	89 7b 3c             	mov    %edi,0x3c(%ebx)
    user_mem_assert(curenv, (void *) tf->tf_esp, sizeof(struct UTrapframe),
f0104543:	e8 42 1e 00 00       	call   f010638a <cpunum>
f0104548:	6a 07                	push   $0x7
f010454a:	6a 34                	push   $0x34
f010454c:	57                   	push   %edi
f010454d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104550:	ff b0 28 c0 3b f0    	pushl  -0xfc43fd8(%eax)
f0104556:	e8 90 eb ff ff       	call   f01030eb <user_mem_assert>
    *((struct UTrapframe *) tf->tf_esp) = utf;
f010455b:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010455e:	89 30                	mov    %esi,(%eax)
f0104560:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104563:	89 50 04             	mov    %edx,0x4(%eax)
f0104566:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104569:	89 48 08             	mov    %ecx,0x8(%eax)
f010456c:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010456f:	89 50 0c             	mov    %edx,0xc(%eax)
f0104572:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0104575:	89 48 10             	mov    %ecx,0x10(%eax)
f0104578:	8b 55 c8             	mov    -0x38(%ebp),%edx
f010457b:	89 50 14             	mov    %edx,0x14(%eax)
f010457e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0104581:	89 48 18             	mov    %ecx,0x18(%eax)
f0104584:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0104587:	89 50 1c             	mov    %edx,0x1c(%eax)
f010458a:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f010458d:	89 48 20             	mov    %ecx,0x20(%eax)
f0104590:	8b 55 b8             	mov    -0x48(%ebp),%edx
f0104593:	89 50 24             	mov    %edx,0x24(%eax)
f0104596:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0104599:	89 48 28             	mov    %ecx,0x28(%eax)
f010459c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010459f:	89 50 2c             	mov    %edx,0x2c(%eax)
f01045a2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01045a5:	89 48 30             	mov    %ecx,0x30(%eax)
    tf->tf_eip = (uintptr_t) curenv->env_pgfault_upcall;
f01045a8:	e8 dd 1d 00 00       	call   f010638a <cpunum>
f01045ad:	6b c0 74             	imul   $0x74,%eax,%eax
f01045b0:	8b 80 28 c0 3b f0    	mov    -0xfc43fd8(%eax),%eax
f01045b6:	8b 40 64             	mov    0x64(%eax),%eax
f01045b9:	89 43 30             	mov    %eax,0x30(%ebx)
    env_run(curenv);
f01045bc:	e8 c9 1d 00 00       	call   f010638a <cpunum>
f01045c1:	83 c4 04             	add    $0x4,%esp
f01045c4:	6b c0 74             	imul   $0x74,%eax,%eax
f01045c7:	ff b0 28 c0 3b f0    	pushl  -0xfc43fd8(%eax)
f01045cd:	e8 ea f2 ff ff       	call   f01038bc <env_run>
        tf->tf_esp -= 4;
f01045d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01045d5:	8d 78 fc             	lea    -0x4(%eax),%edi
f01045d8:	e9 60 ff ff ff       	jmp    f010453d <page_fault_handler+0xf2>

f01045dd <trap>:
{
f01045dd:	f3 0f 1e fb          	endbr32 
f01045e1:	55                   	push   %ebp
f01045e2:	89 e5                	mov    %esp,%ebp
f01045e4:	57                   	push   %edi
f01045e5:	56                   	push   %esi
f01045e6:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f01045e9:	fc                   	cld    
	if (panicstr)
f01045ea:	83 3d 80 be 3b f0 00 	cmpl   $0x0,0xf03bbe80
f01045f1:	74 01                	je     f01045f4 <trap+0x17>
		asm volatile("hlt");
f01045f3:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01045f4:	e8 91 1d 00 00       	call   f010638a <cpunum>
f01045f9:	6b d0 74             	imul   $0x74,%eax,%edx
f01045fc:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f01045ff:	b8 01 00 00 00       	mov    $0x1,%eax
f0104604:	f0 87 82 20 c0 3b f0 	lock xchg %eax,-0xfc43fe0(%edx)
f010460b:	83 f8 02             	cmp    $0x2,%eax
f010460e:	74 62                	je     f0104672 <trap+0x95>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104610:	9c                   	pushf  
f0104611:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f0104612:	f6 c4 02             	test   $0x2,%ah
f0104615:	75 6d                	jne    f0104684 <trap+0xa7>
	if ((tf->tf_cs & 3) == 3) {
f0104617:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010461b:	83 e0 03             	and    $0x3,%eax
f010461e:	66 83 f8 03          	cmp    $0x3,%ax
f0104622:	74 79                	je     f010469d <trap+0xc0>
	last_tf = tf;
f0104624:	89 35 60 ba 3b f0    	mov    %esi,0xf03bba60
    switch (tf->tf_trapno) {
f010462a:	8b 46 28             	mov    0x28(%esi),%eax
f010462d:	83 f8 0e             	cmp    $0xe,%eax
f0104630:	0f 84 1f 01 00 00    	je     f0104755 <trap+0x178>
f0104636:	0f 86 06 01 00 00    	jbe    f0104742 <trap+0x165>
f010463c:	83 f8 20             	cmp    $0x20,%eax
f010463f:	0f 84 46 01 00 00    	je     f010478b <trap+0x1ae>
f0104645:	83 f8 30             	cmp    $0x30,%eax
f0104648:	0f 85 47 01 00 00    	jne    f0104795 <trap+0x1b8>
            int32_t ret = syscall(tf->tf_regs.reg_eax,
f010464e:	83 ec 08             	sub    $0x8,%esp
f0104651:	ff 76 04             	pushl  0x4(%esi)
f0104654:	ff 36                	pushl  (%esi)
f0104656:	ff 76 10             	pushl  0x10(%esi)
f0104659:	ff 76 18             	pushl  0x18(%esi)
f010465c:	ff 76 14             	pushl  0x14(%esi)
f010465f:	ff 76 1c             	pushl  0x1c(%esi)
f0104662:	e8 19 04 00 00       	call   f0104a80 <syscall>
            tf->tf_regs.reg_eax = ret;
f0104667:	89 46 1c             	mov    %eax,0x1c(%esi)
            return;
f010466a:	83 c4 20             	add    $0x20,%esp
f010466d:	e9 ef 00 00 00       	jmp    f0104761 <trap+0x184>
	spin_lock(&kernel_lock);
f0104672:	83 ec 0c             	sub    $0xc,%esp
f0104675:	68 c0 33 12 f0       	push   $0xf01233c0
f010467a:	e8 93 1f 00 00       	call   f0106612 <spin_lock>
}
f010467f:	83 c4 10             	add    $0x10,%esp
f0104682:	eb 8c                	jmp    f0104610 <trap+0x33>
	assert(!(read_eflags() & FL_IF));
f0104684:	68 27 7f 10 f0       	push   $0xf0107f27
f0104689:	68 19 79 10 f0       	push   $0xf0107919
f010468e:	68 58 01 00 00       	push   $0x158
f0104693:	68 1b 7f 10 f0       	push   $0xf0107f1b
f0104698:	e8 a3 b9 ff ff       	call   f0100040 <_panic>
	spin_lock(&kernel_lock);
f010469d:	83 ec 0c             	sub    $0xc,%esp
f01046a0:	68 c0 33 12 f0       	push   $0xf01233c0
f01046a5:	e8 68 1f 00 00       	call   f0106612 <spin_lock>
		assert(curenv);
f01046aa:	e8 db 1c 00 00       	call   f010638a <cpunum>
f01046af:	6b c0 74             	imul   $0x74,%eax,%eax
f01046b2:	83 c4 10             	add    $0x10,%esp
f01046b5:	83 b8 28 c0 3b f0 00 	cmpl   $0x0,-0xfc43fd8(%eax)
f01046bc:	74 3e                	je     f01046fc <trap+0x11f>
		if (curenv->env_status == ENV_DYING) {
f01046be:	e8 c7 1c 00 00       	call   f010638a <cpunum>
f01046c3:	6b c0 74             	imul   $0x74,%eax,%eax
f01046c6:	8b 80 28 c0 3b f0    	mov    -0xfc43fd8(%eax),%eax
f01046cc:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01046d0:	74 43                	je     f0104715 <trap+0x138>
		curenv->env_tf = *tf;
f01046d2:	e8 b3 1c 00 00       	call   f010638a <cpunum>
f01046d7:	6b c0 74             	imul   $0x74,%eax,%eax
f01046da:	8b 80 28 c0 3b f0    	mov    -0xfc43fd8(%eax),%eax
f01046e0:	b9 11 00 00 00       	mov    $0x11,%ecx
f01046e5:	89 c7                	mov    %eax,%edi
f01046e7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f01046e9:	e8 9c 1c 00 00       	call   f010638a <cpunum>
f01046ee:	6b c0 74             	imul   $0x74,%eax,%eax
f01046f1:	8b b0 28 c0 3b f0    	mov    -0xfc43fd8(%eax),%esi
f01046f7:	e9 28 ff ff ff       	jmp    f0104624 <trap+0x47>
		assert(curenv);
f01046fc:	68 40 7f 10 f0       	push   $0xf0107f40
f0104701:	68 19 79 10 f0       	push   $0xf0107919
f0104706:	68 60 01 00 00       	push   $0x160
f010470b:	68 1b 7f 10 f0       	push   $0xf0107f1b
f0104710:	e8 2b b9 ff ff       	call   f0100040 <_panic>
			env_free(curenv);
f0104715:	e8 70 1c 00 00       	call   f010638a <cpunum>
f010471a:	83 ec 0c             	sub    $0xc,%esp
f010471d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104720:	ff b0 28 c0 3b f0    	pushl  -0xfc43fd8(%eax)
f0104726:	e8 ea ee ff ff       	call   f0103615 <env_free>
			curenv = NULL;
f010472b:	e8 5a 1c 00 00       	call   f010638a <cpunum>
f0104730:	6b c0 74             	imul   $0x74,%eax,%eax
f0104733:	c7 80 28 c0 3b f0 00 	movl   $0x0,-0xfc43fd8(%eax)
f010473a:	00 00 00 
			sched_yield();
f010473d:	e8 a8 02 00 00       	call   f01049ea <sched_yield>
    switch (tf->tf_trapno) {
f0104742:	83 f8 03             	cmp    $0x3,%eax
f0104745:	75 6d                	jne    f01047b4 <trap+0x1d7>
            return monitor(tf);
f0104747:	83 ec 0c             	sub    $0xc,%esp
f010474a:	56                   	push   %esi
f010474b:	e8 8c c2 ff ff       	call   f01009dc <monitor>
f0104750:	83 c4 10             	add    $0x10,%esp
f0104753:	eb 0c                	jmp    f0104761 <trap+0x184>
            return page_fault_handler(tf);
f0104755:	83 ec 0c             	sub    $0xc,%esp
f0104758:	56                   	push   %esi
f0104759:	e8 ed fc ff ff       	call   f010444b <page_fault_handler>
f010475e:	83 c4 10             	add    $0x10,%esp
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104761:	e8 24 1c 00 00       	call   f010638a <cpunum>
f0104766:	6b c0 74             	imul   $0x74,%eax,%eax
f0104769:	83 b8 28 c0 3b f0 00 	cmpl   $0x0,-0xfc43fd8(%eax)
f0104770:	74 14                	je     f0104786 <trap+0x1a9>
f0104772:	e8 13 1c 00 00       	call   f010638a <cpunum>
f0104777:	6b c0 74             	imul   $0x74,%eax,%eax
f010477a:	8b 80 28 c0 3b f0    	mov    -0xfc43fd8(%eax),%eax
f0104780:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104784:	74 76                	je     f01047fc <trap+0x21f>
		sched_yield();
f0104786:	e8 5f 02 00 00       	call   f01049ea <sched_yield>
            lapic_eoi();
f010478b:	e8 49 1d 00 00       	call   f01064d9 <lapic_eoi>
            sched_yield();
f0104790:	e8 55 02 00 00       	call   f01049ea <sched_yield>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104795:	83 f8 27             	cmp    $0x27,%eax
f0104798:	75 1a                	jne    f01047b4 <trap+0x1d7>
		cprintf("Spurious interrupt on irq 7\n");
f010479a:	83 ec 0c             	sub    $0xc,%esp
f010479d:	68 47 7f 10 f0       	push   $0xf0107f47
f01047a2:	e8 86 f3 ff ff       	call   f0103b2d <cprintf>
		print_trapframe(tf);
f01047a7:	89 34 24             	mov    %esi,(%esp)
f01047aa:	e8 fc fa ff ff       	call   f01042ab <print_trapframe>
		return;
f01047af:	83 c4 10             	add    $0x10,%esp
f01047b2:	eb ad                	jmp    f0104761 <trap+0x184>
	print_trapframe(tf);
f01047b4:	83 ec 0c             	sub    $0xc,%esp
f01047b7:	56                   	push   %esi
f01047b8:	e8 ee fa ff ff       	call   f01042ab <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01047bd:	83 c4 10             	add    $0x10,%esp
f01047c0:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01047c5:	74 1e                	je     f01047e5 <trap+0x208>
		env_destroy(curenv);
f01047c7:	e8 be 1b 00 00       	call   f010638a <cpunum>
f01047cc:	83 ec 0c             	sub    $0xc,%esp
f01047cf:	6b c0 74             	imul   $0x74,%eax,%eax
f01047d2:	ff b0 28 c0 3b f0    	pushl  -0xfc43fd8(%eax)
f01047d8:	e8 19 f0 ff ff       	call   f01037f6 <env_destroy>
		return;
f01047dd:	83 c4 10             	add    $0x10,%esp
f01047e0:	e9 7c ff ff ff       	jmp    f0104761 <trap+0x184>
		panic("unhandled trap in kernel");
f01047e5:	83 ec 04             	sub    $0x4,%esp
f01047e8:	68 64 7f 10 f0       	push   $0xf0107f64
f01047ed:	68 3e 01 00 00       	push   $0x13e
f01047f2:	68 1b 7f 10 f0       	push   $0xf0107f1b
f01047f7:	e8 44 b8 ff ff       	call   f0100040 <_panic>
		env_run(curenv);
f01047fc:	e8 89 1b 00 00       	call   f010638a <cpunum>
f0104801:	83 ec 0c             	sub    $0xc,%esp
f0104804:	6b c0 74             	imul   $0x74,%eax,%eax
f0104807:	ff b0 28 c0 3b f0    	pushl  -0xfc43fd8(%eax)
f010480d:	e8 aa f0 ff ff       	call   f01038bc <env_run>

f0104812 <t_divide>:
// HINT 2 : TRAPHANDLER(t_dblflt, T_DBLFLT);
//          Do something like this if the trap includes an error code..
// HINT 3 : READ Intel's manual to check if the trap includes an error code
//          or not...

TRAPHANDLER_NOEC(t_divide, T_DIVIDE);    // 0
f0104812:	6a 00                	push   $0x0
f0104814:	6a 00                	push   $0x0
f0104816:	e9 ef 00 00 00       	jmp    f010490a <_alltraps>
f010481b:	90                   	nop

f010481c <t_debug>:
TRAPHANDLER_NOEC(t_debug, T_DEBUG);      // 1
f010481c:	6a 00                	push   $0x0
f010481e:	6a 01                	push   $0x1
f0104820:	e9 e5 00 00 00       	jmp    f010490a <_alltraps>
f0104825:	90                   	nop

f0104826 <t_nmi>:
TRAPHANDLER_NOEC(t_nmi, T_NMI);          // 2
f0104826:	6a 00                	push   $0x0
f0104828:	6a 02                	push   $0x2
f010482a:	e9 db 00 00 00       	jmp    f010490a <_alltraps>
f010482f:	90                   	nop

f0104830 <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT);      // 3
f0104830:	6a 00                	push   $0x0
f0104832:	6a 03                	push   $0x3
f0104834:	e9 d1 00 00 00       	jmp    f010490a <_alltraps>
f0104839:	90                   	nop

f010483a <t_oflow>:
TRAPHANDLER_NOEC(t_oflow, T_OFLOW);      // 4
f010483a:	6a 00                	push   $0x0
f010483c:	6a 04                	push   $0x4
f010483e:	e9 c7 00 00 00       	jmp    f010490a <_alltraps>
f0104843:	90                   	nop

f0104844 <t_bound>:
TRAPHANDLER_NOEC(t_bound, T_BOUND);      // 5
f0104844:	6a 00                	push   $0x0
f0104846:	6a 05                	push   $0x5
f0104848:	e9 bd 00 00 00       	jmp    f010490a <_alltraps>
f010484d:	90                   	nop

f010484e <t_illop>:
TRAPHANDLER_NOEC(t_illop, T_ILLOP);      // 6
f010484e:	6a 00                	push   $0x0
f0104850:	6a 06                	push   $0x6
f0104852:	e9 b3 00 00 00       	jmp    f010490a <_alltraps>
f0104857:	90                   	nop

f0104858 <t_device>:
TRAPHANDLER_NOEC(t_device, T_DEVICE);    // 7
f0104858:	6a 00                	push   $0x0
f010485a:	6a 07                	push   $0x7
f010485c:	e9 a9 00 00 00       	jmp    f010490a <_alltraps>
f0104861:	90                   	nop

f0104862 <t_dblflt>:

TRAPHANDLER(t_dblflt, T_DBLFLT);    // 8
f0104862:	6a 08                	push   $0x8
f0104864:	e9 a1 00 00 00       	jmp    f010490a <_alltraps>
f0104869:	90                   	nop

f010486a <t_tss>:

TRAPHANDLER(t_tss, T_TSS);          // 10
f010486a:	6a 0a                	push   $0xa
f010486c:	e9 99 00 00 00       	jmp    f010490a <_alltraps>
f0104871:	90                   	nop

f0104872 <t_segnp>:
TRAPHANDLER(t_segnp, T_SEGNP);      // 11
f0104872:	6a 0b                	push   $0xb
f0104874:	e9 91 00 00 00       	jmp    f010490a <_alltraps>
f0104879:	90                   	nop

f010487a <t_stack>:
TRAPHANDLER(t_stack, T_STACK);      // 12
f010487a:	6a 0c                	push   $0xc
f010487c:	e9 89 00 00 00       	jmp    f010490a <_alltraps>
f0104881:	90                   	nop

f0104882 <t_gpflt>:
TRAPHANDLER(t_gpflt, T_GPFLT);      // 13
f0104882:	6a 0d                	push   $0xd
f0104884:	e9 81 00 00 00       	jmp    f010490a <_alltraps>
f0104889:	90                   	nop

f010488a <t_pgflt>:
TRAPHANDLER(t_pgflt, T_PGFLT);      // 14
f010488a:	6a 0e                	push   $0xe
f010488c:	eb 7c                	jmp    f010490a <_alltraps>

f010488e <t_fperr>:

TRAPHANDLER_NOEC(t_fperr, T_FPERR);      // 16
f010488e:	6a 00                	push   $0x0
f0104890:	6a 10                	push   $0x10
f0104892:	eb 76                	jmp    f010490a <_alltraps>

f0104894 <t_align>:

TRAPHANDLER(t_align, T_ALIGN);      // 17
f0104894:	6a 11                	push   $0x11
f0104896:	eb 72                	jmp    f010490a <_alltraps>

f0104898 <t_mchk>:

TRAPHANDLER_NOEC(t_mchk, T_MCHK);        // 18
f0104898:	6a 00                	push   $0x0
f010489a:	6a 12                	push   $0x12
f010489c:	eb 6c                	jmp    f010490a <_alltraps>

f010489e <t_simderr>:
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR);  // 19
f010489e:	6a 00                	push   $0x0
f01048a0:	6a 13                	push   $0x13
f01048a2:	eb 66                	jmp    f010490a <_alltraps>

f01048a4 <t_irq_timer>:


TRAPHANDLER_NOEC(t_irq_timer, IRQ_OFFSET + IRQ_TIMER); // 32 + 0
f01048a4:	6a 00                	push   $0x0
f01048a6:	6a 20                	push   $0x20
f01048a8:	eb 60                	jmp    f010490a <_alltraps>

f01048aa <t_irq_kbd>:
TRAPHANDLER_NOEC(t_irq_kbd, IRQ_OFFSET + IRQ_KBD); // 32 + 1
f01048aa:	6a 00                	push   $0x0
f01048ac:	6a 21                	push   $0x21
f01048ae:	eb 5a                	jmp    f010490a <_alltraps>

f01048b0 <t_irq_2>:
TRAPHANDLER_NOEC(t_irq_2, IRQ_OFFSET + 2); // 32 + 2
f01048b0:	6a 00                	push   $0x0
f01048b2:	6a 22                	push   $0x22
f01048b4:	eb 54                	jmp    f010490a <_alltraps>

f01048b6 <t_irq_3>:
TRAPHANDLER_NOEC(t_irq_3, IRQ_OFFSET + 3); // 32 + 3
f01048b6:	6a 00                	push   $0x0
f01048b8:	6a 23                	push   $0x23
f01048ba:	eb 4e                	jmp    f010490a <_alltraps>

f01048bc <t_irq_serial>:
TRAPHANDLER_NOEC(t_irq_serial, IRQ_OFFSET + IRQ_SERIAL); // 32 + 4
f01048bc:	6a 00                	push   $0x0
f01048be:	6a 24                	push   $0x24
f01048c0:	eb 48                	jmp    f010490a <_alltraps>

f01048c2 <t_irq_5>:
TRAPHANDLER_NOEC(t_irq_5, IRQ_OFFSET + 5); // 32 + 5
f01048c2:	6a 00                	push   $0x0
f01048c4:	6a 25                	push   $0x25
f01048c6:	eb 42                	jmp    f010490a <_alltraps>

f01048c8 <t_irq_6>:
TRAPHANDLER_NOEC(t_irq_6, IRQ_OFFSET + 6); // 32 + 6
f01048c8:	6a 00                	push   $0x0
f01048ca:	6a 26                	push   $0x26
f01048cc:	eb 3c                	jmp    f010490a <_alltraps>

f01048ce <t_irq_spurious>:
TRAPHANDLER_NOEC(t_irq_spurious, IRQ_OFFSET + IRQ_SPURIOUS); // 32 + 7
f01048ce:	6a 00                	push   $0x0
f01048d0:	6a 27                	push   $0x27
f01048d2:	eb 36                	jmp    f010490a <_alltraps>

f01048d4 <t_irq_8>:
TRAPHANDLER_NOEC(t_irq_8, IRQ_OFFSET + 8); // 32 + 8
f01048d4:	6a 00                	push   $0x0
f01048d6:	6a 28                	push   $0x28
f01048d8:	eb 30                	jmp    f010490a <_alltraps>

f01048da <t_irq_9>:
TRAPHANDLER_NOEC(t_irq_9, IRQ_OFFSET + 9); // 32 + 9
f01048da:	6a 00                	push   $0x0
f01048dc:	6a 29                	push   $0x29
f01048de:	eb 2a                	jmp    f010490a <_alltraps>

f01048e0 <t_irq_10>:
TRAPHANDLER_NOEC(t_irq_10, IRQ_OFFSET + 10); // 32 + 10
f01048e0:	6a 00                	push   $0x0
f01048e2:	6a 2a                	push   $0x2a
f01048e4:	eb 24                	jmp    f010490a <_alltraps>

f01048e6 <t_irq_11>:
TRAPHANDLER_NOEC(t_irq_11, IRQ_OFFSET + 11); // 32 + 11
f01048e6:	6a 00                	push   $0x0
f01048e8:	6a 2b                	push   $0x2b
f01048ea:	eb 1e                	jmp    f010490a <_alltraps>

f01048ec <t_irq_12>:
TRAPHANDLER_NOEC(t_irq_12, IRQ_OFFSET + 12); // 32 + 12
f01048ec:	6a 00                	push   $0x0
f01048ee:	6a 2c                	push   $0x2c
f01048f0:	eb 18                	jmp    f010490a <_alltraps>

f01048f2 <t_irq_13>:
TRAPHANDLER_NOEC(t_irq_13, IRQ_OFFSET + 13); // 32 + 13
f01048f2:	6a 00                	push   $0x0
f01048f4:	6a 2d                	push   $0x2d
f01048f6:	eb 12                	jmp    f010490a <_alltraps>

f01048f8 <t_irq_ide>:
TRAPHANDLER_NOEC(t_irq_ide, IRQ_OFFSET + IRQ_IDE); // 32 + 14
f01048f8:	6a 00                	push   $0x0
f01048fa:	6a 2e                	push   $0x2e
f01048fc:	eb 0c                	jmp    f010490a <_alltraps>

f01048fe <t_irq_15>:
TRAPHANDLER_NOEC(t_irq_15, IRQ_OFFSET + 15); // 32 + 15
f01048fe:	6a 00                	push   $0x0
f0104900:	6a 2f                	push   $0x2f
f0104902:	eb 06                	jmp    f010490a <_alltraps>

f0104904 <t_syscall>:

TRAPHANDLER_NOEC(t_syscall, T_SYSCALL);  // 48, 0x30
f0104904:	6a 00                	push   $0x0
f0104906:	6a 30                	push   $0x30
f0104908:	eb 00                	jmp    f010490a <_alltraps>

f010490a <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */

_alltraps:
    pushl %ds
f010490a:	1e                   	push   %ds
    pushl %es
f010490b:	06                   	push   %es
    pushal
f010490c:	60                   	pusha  

    movl $GD_KD, %eax
f010490d:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
f0104912:	8e d8                	mov    %eax,%ds
    movw %ax, %es
f0104914:	8e c0                	mov    %eax,%es

    pushl %esp
f0104916:	54                   	push   %esp

    call trap
f0104917:	e8 c1 fc ff ff       	call   f01045dd <trap>

f010491c <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f010491c:	f3 0f 1e fb          	endbr32 
f0104920:	55                   	push   %ebp
f0104921:	89 e5                	mov    %esp,%ebp
f0104923:	83 ec 08             	sub    $0x8,%esp
f0104926:	a1 44 b2 3b f0       	mov    0xf03bb244,%eax
f010492b:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010492e:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104933:	8b 02                	mov    (%edx),%eax
f0104935:	83 e8 01             	sub    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104938:	83 f8 02             	cmp    $0x2,%eax
f010493b:	76 2d                	jbe    f010496a <sched_halt+0x4e>
	for (i = 0; i < NENV; i++) {
f010493d:	83 c1 01             	add    $0x1,%ecx
f0104940:	83 c2 7c             	add    $0x7c,%edx
f0104943:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104949:	75 e8                	jne    f0104933 <sched_halt+0x17>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f010494b:	83 ec 0c             	sub    $0xc,%esp
f010494e:	68 70 81 10 f0       	push   $0xf0108170
f0104953:	e8 d5 f1 ff ff       	call   f0103b2d <cprintf>
f0104958:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f010495b:	83 ec 0c             	sub    $0xc,%esp
f010495e:	6a 00                	push   $0x0
f0104960:	e8 77 c0 ff ff       	call   f01009dc <monitor>
f0104965:	83 c4 10             	add    $0x10,%esp
f0104968:	eb f1                	jmp    f010495b <sched_halt+0x3f>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f010496a:	e8 1b 1a 00 00       	call   f010638a <cpunum>
f010496f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104972:	c7 80 28 c0 3b f0 00 	movl   $0x0,-0xfc43fd8(%eax)
f0104979:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f010497c:	a1 8c be 3b f0       	mov    0xf03bbe8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0104981:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104986:	76 50                	jbe    f01049d8 <sched_halt+0xbc>
	return (physaddr_t)kva - KERNBASE;
f0104988:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010498d:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104990:	e8 f5 19 00 00       	call   f010638a <cpunum>
f0104995:	6b d0 74             	imul   $0x74,%eax,%edx
f0104998:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f010499b:	b8 02 00 00 00       	mov    $0x2,%eax
f01049a0:	f0 87 82 20 c0 3b f0 	lock xchg %eax,-0xfc43fe0(%edx)
	spin_unlock(&kernel_lock);
f01049a7:	83 ec 0c             	sub    $0xc,%esp
f01049aa:	68 c0 33 12 f0       	push   $0xf01233c0
f01049af:	e8 fc 1c 00 00       	call   f01066b0 <spin_unlock>
	asm volatile("pause");
f01049b4:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f01049b6:	e8 cf 19 00 00       	call   f010638a <cpunum>
f01049bb:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile (
f01049be:	8b 80 30 c0 3b f0    	mov    -0xfc43fd0(%eax),%eax
f01049c4:	bd 00 00 00 00       	mov    $0x0,%ebp
f01049c9:	89 c4                	mov    %eax,%esp
f01049cb:	6a 00                	push   $0x0
f01049cd:	6a 00                	push   $0x0
f01049cf:	fb                   	sti    
f01049d0:	f4                   	hlt    
f01049d1:	eb fd                	jmp    f01049d0 <sched_halt+0xb4>
}
f01049d3:	83 c4 10             	add    $0x10,%esp
f01049d6:	c9                   	leave  
f01049d7:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01049d8:	50                   	push   %eax
f01049d9:	68 48 6a 10 f0       	push   $0xf0106a48
f01049de:	6a 50                	push   $0x50
f01049e0:	68 99 81 10 f0       	push   $0xf0108199
f01049e5:	e8 56 b6 ff ff       	call   f0100040 <_panic>

f01049ea <sched_yield>:
{
f01049ea:	f3 0f 1e fb          	endbr32 
f01049ee:	55                   	push   %ebp
f01049ef:	89 e5                	mov    %esp,%ebp
f01049f1:	56                   	push   %esi
f01049f2:	53                   	push   %ebx
    for (uint32_t i = probing_env_idx; i < (probing_env_idx + NENV); ++i) {
f01049f3:	8b 1d 64 ba 3b f0    	mov    0xf03bba64,%ebx
        if (envs[env_idx].env_status == ENV_RUNNABLE) {
f01049f9:	8b 35 44 b2 3b f0    	mov    0xf03bb244,%esi
    for (uint32_t i = probing_env_idx; i < (probing_env_idx + NENV); ++i) {
f01049ff:	89 d8                	mov    %ebx,%eax
f0104a01:	81 c3 00 04 00 00    	add    $0x400,%ebx
f0104a07:	39 c3                	cmp    %eax,%ebx
f0104a09:	76 2e                	jbe    f0104a39 <sched_yield+0x4f>
        uint32_t env_idx = i % NENV;
f0104a0b:	89 c1                	mov    %eax,%ecx
f0104a0d:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
        if (envs[env_idx].env_status == ENV_RUNNABLE) {
f0104a13:	6b d1 7c             	imul   $0x7c,%ecx,%edx
f0104a16:	01 f2                	add    %esi,%edx
f0104a18:	83 7a 54 02          	cmpl   $0x2,0x54(%edx)
f0104a1c:	74 05                	je     f0104a23 <sched_yield+0x39>
    for (uint32_t i = probing_env_idx; i < (probing_env_idx + NENV); ++i) {
f0104a1e:	83 c0 01             	add    $0x1,%eax
f0104a21:	eb e4                	jmp    f0104a07 <sched_yield+0x1d>
            probing_env_idx = (env_idx + 1) % NENV;
f0104a23:	8d 41 01             	lea    0x1(%ecx),%eax
f0104a26:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104a2b:	a3 64 ba 3b f0       	mov    %eax,0xf03bba64
            env_run(target_env);
f0104a30:	83 ec 0c             	sub    $0xc,%esp
f0104a33:	52                   	push   %edx
f0104a34:	e8 83 ee ff ff       	call   f01038bc <env_run>
    if (curenv && curenv->env_status == ENV_RUNNING) {
f0104a39:	e8 4c 19 00 00       	call   f010638a <cpunum>
f0104a3e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a41:	83 b8 28 c0 3b f0 00 	cmpl   $0x0,-0xfc43fd8(%eax)
f0104a48:	74 14                	je     f0104a5e <sched_yield+0x74>
f0104a4a:	e8 3b 19 00 00       	call   f010638a <cpunum>
f0104a4f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a52:	8b 80 28 c0 3b f0    	mov    -0xfc43fd8(%eax),%eax
f0104a58:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104a5c:	74 0c                	je     f0104a6a <sched_yield+0x80>
	sched_halt();
f0104a5e:	e8 b9 fe ff ff       	call   f010491c <sched_halt>
}
f0104a63:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104a66:	5b                   	pop    %ebx
f0104a67:	5e                   	pop    %esi
f0104a68:	5d                   	pop    %ebp
f0104a69:	c3                   	ret    
        env_run(curenv);
f0104a6a:	e8 1b 19 00 00       	call   f010638a <cpunum>
f0104a6f:	83 ec 0c             	sub    $0xc,%esp
f0104a72:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a75:	ff b0 28 c0 3b f0    	pushl  -0xfc43fd8(%eax)
f0104a7b:	e8 3c ee ff ff       	call   f01038bc <env_run>

f0104a80 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104a80:	f3 0f 1e fb          	endbr32 
f0104a84:	55                   	push   %ebp
f0104a85:	89 e5                	mov    %esp,%ebp
f0104a87:	57                   	push   %edi
f0104a88:	56                   	push   %esi
f0104a89:	53                   	push   %ebx
f0104a8a:	83 ec 1c             	sub    $0x1c,%esp
f0104a8d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a90:	83 f8 0d             	cmp    $0xd,%eax
f0104a93:	0f 87 81 06 00 00    	ja     f010511a <syscall+0x69a>
f0104a99:	3e ff 24 85 14 82 10 	notrack jmp *-0xfef7dec(,%eax,4)
f0104aa0:	f0 
    user_mem_assert(curenv, s, len, PTE_U|PTE_P);
f0104aa1:	e8 e4 18 00 00       	call   f010638a <cpunum>
f0104aa6:	6a 05                	push   $0x5
f0104aa8:	ff 75 10             	pushl  0x10(%ebp)
f0104aab:	ff 75 0c             	pushl  0xc(%ebp)
f0104aae:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ab1:	ff b0 28 c0 3b f0    	pushl  -0xfc43fd8(%eax)
f0104ab7:	e8 2f e6 ff ff       	call   f01030eb <user_mem_assert>
	cprintf("%.*s", len, s);
f0104abc:	83 c4 0c             	add    $0xc,%esp
f0104abf:	ff 75 0c             	pushl  0xc(%ebp)
f0104ac2:	ff 75 10             	pushl  0x10(%ebp)
f0104ac5:	68 b5 6d 10 f0       	push   $0xf0106db5
f0104aca:	e8 5e f0 ff ff       	call   f0103b2d <cprintf>
}
f0104acf:	83 c4 10             	add    $0x10,%esp

	switch (syscallno) {
    case SYS_cputs:
    {
        sys_cputs((const char *)a1, (size_t) a2);
        return 0;
f0104ad2:	b8 00 00 00 00       	mov    $0x0,%eax
	default:
	    panic("syscall %d not implemented", syscallno);
		return -E_INVAL;
	}

}
f0104ad7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104ada:	5b                   	pop    %ebx
f0104adb:	5e                   	pop    %esi
f0104adc:	5f                   	pop    %edi
f0104add:	5d                   	pop    %ebp
f0104ade:	c3                   	ret    
	return cons_getc();
f0104adf:	e8 2f bb ff ff       	call   f0100613 <cons_getc>
        return sys_cgetc();
f0104ae4:	eb f1                	jmp    f0104ad7 <syscall+0x57>
	return curenv->env_id;
f0104ae6:	e8 9f 18 00 00       	call   f010638a <cpunum>
f0104aeb:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aee:	8b 80 28 c0 3b f0    	mov    -0xfc43fd8(%eax),%eax
f0104af4:	8b 40 48             	mov    0x48(%eax),%eax
        return (int32_t) sys_getenvid();
f0104af7:	eb de                	jmp    f0104ad7 <syscall+0x57>
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104af9:	83 ec 04             	sub    $0x4,%esp
f0104afc:	6a 01                	push   $0x1
f0104afe:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104b01:	50                   	push   %eax
f0104b02:	ff 75 0c             	pushl  0xc(%ebp)
f0104b05:	e8 ee e6 ff ff       	call   f01031f8 <envid2env>
f0104b0a:	83 c4 10             	add    $0x10,%esp
f0104b0d:	85 c0                	test   %eax,%eax
f0104b0f:	78 c6                	js     f0104ad7 <syscall+0x57>
	if (e == curenv)
f0104b11:	e8 74 18 00 00       	call   f010638a <cpunum>
f0104b16:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104b19:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b1c:	39 90 28 c0 3b f0    	cmp    %edx,-0xfc43fd8(%eax)
f0104b22:	74 3d                	je     f0104b61 <syscall+0xe1>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104b24:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104b27:	e8 5e 18 00 00       	call   f010638a <cpunum>
f0104b2c:	83 ec 04             	sub    $0x4,%esp
f0104b2f:	53                   	push   %ebx
f0104b30:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b33:	8b 80 28 c0 3b f0    	mov    -0xfc43fd8(%eax),%eax
f0104b39:	ff 70 48             	pushl  0x48(%eax)
f0104b3c:	68 c1 81 10 f0       	push   $0xf01081c1
f0104b41:	e8 e7 ef ff ff       	call   f0103b2d <cprintf>
f0104b46:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104b49:	83 ec 0c             	sub    $0xc,%esp
f0104b4c:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104b4f:	e8 a2 ec ff ff       	call   f01037f6 <env_destroy>
	return 0;
f0104b54:	83 c4 10             	add    $0x10,%esp
f0104b57:	b8 00 00 00 00       	mov    $0x0,%eax
        return sys_env_destroy((envid_t) a1);
f0104b5c:	e9 76 ff ff ff       	jmp    f0104ad7 <syscall+0x57>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104b61:	e8 24 18 00 00       	call   f010638a <cpunum>
f0104b66:	83 ec 08             	sub    $0x8,%esp
f0104b69:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b6c:	8b 80 28 c0 3b f0    	mov    -0xfc43fd8(%eax),%eax
f0104b72:	ff 70 48             	pushl  0x48(%eax)
f0104b75:	68 a6 81 10 f0       	push   $0xf01081a6
f0104b7a:	e8 ae ef ff ff       	call   f0103b2d <cprintf>
f0104b7f:	83 c4 10             	add    $0x10,%esp
f0104b82:	eb c5                	jmp    f0104b49 <syscall+0xc9>
	sched_yield();
f0104b84:	e8 61 fe ff ff       	call   f01049ea <sched_yield>
    struct Env *e = NULL;
f0104b89:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    if (envid2env(envid, &e, 1) < 0) {
f0104b90:	83 ec 04             	sub    $0x4,%esp
f0104b93:	6a 01                	push   $0x1
f0104b95:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104b98:	50                   	push   %eax
f0104b99:	ff 75 0c             	pushl  0xc(%ebp)
f0104b9c:	e8 57 e6 ff ff       	call   f01031f8 <envid2env>
f0104ba1:	83 c4 10             	add    $0x10,%esp
f0104ba4:	85 c0                	test   %eax,%eax
f0104ba6:	0f 88 8c 00 00 00    	js     f0104c38 <syscall+0x1b8>
    if (e == NULL) {
f0104bac:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104bb0:	0f 84 8c 00 00 00    	je     f0104c42 <syscall+0x1c2>
    if (((uintptr_t)va) >= UTOP) {
f0104bb6:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104bbd:	0f 87 89 00 00 00    	ja     f0104c4c <syscall+0x1cc>
    if (!(PTE_P & perm)) {
f0104bc3:	8b 45 14             	mov    0x14(%ebp),%eax
f0104bc6:	83 e0 05             	and    $0x5,%eax
f0104bc9:	83 f8 05             	cmp    $0x5,%eax
f0104bcc:	0f 85 84 00 00 00    	jne    f0104c56 <syscall+0x1d6>
    struct PageInfo *pp = page_alloc(ALLOC_ZERO);
f0104bd2:	83 ec 0c             	sub    $0xc,%esp
f0104bd5:	6a 01                	push   $0x1
f0104bd7:	e8 22 c4 ff ff       	call   f0100ffe <page_alloc>
f0104bdc:	89 c3                	mov    %eax,%ebx
    if (pp == NULL) {
f0104bde:	83 c4 10             	add    $0x10,%esp
f0104be1:	85 c0                	test   %eax,%eax
f0104be3:	74 7b                	je     f0104c60 <syscall+0x1e0>
    if (page_insert(e->env_pgdir, pp, va, perm) != 0) {
f0104be5:	ff 75 14             	pushl  0x14(%ebp)
f0104be8:	ff 75 10             	pushl  0x10(%ebp)
f0104beb:	50                   	push   %eax
f0104bec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104bef:	ff 70 60             	pushl  0x60(%eax)
f0104bf2:	e8 d5 c6 ff ff       	call   f01012cc <page_insert>
f0104bf7:	83 c4 10             	add    $0x10,%esp
f0104bfa:	85 c0                	test   %eax,%eax
f0104bfc:	0f 84 d5 fe ff ff    	je     f0104ad7 <syscall+0x57>
        assert(pp->pp_ref == 0);
f0104c02:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0104c07:	75 16                	jne    f0104c1f <syscall+0x19f>
        page_free(pp);
f0104c09:	83 ec 0c             	sub    $0xc,%esp
f0104c0c:	53                   	push   %ebx
f0104c0d:	e8 65 c4 ff ff       	call   f0101077 <page_free>
        return -E_NO_MEM;
f0104c12:	83 c4 10             	add    $0x10,%esp
f0104c15:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104c1a:	e9 b8 fe ff ff       	jmp    f0104ad7 <syscall+0x57>
        assert(pp->pp_ref == 0);
f0104c1f:	68 d9 81 10 f0       	push   $0xf01081d9
f0104c24:	68 19 79 10 f0       	push   $0xf0107919
f0104c29:	68 f3 00 00 00       	push   $0xf3
f0104c2e:	68 e9 81 10 f0       	push   $0xf01081e9
f0104c33:	e8 08 b4 ff ff       	call   f0100040 <_panic>
        return -E_BAD_ENV;
f0104c38:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104c3d:	e9 95 fe ff ff       	jmp    f0104ad7 <syscall+0x57>
        return -E_BAD_ENV;
f0104c42:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104c47:	e9 8b fe ff ff       	jmp    f0104ad7 <syscall+0x57>
        return -E_INVAL;
f0104c4c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104c51:	e9 81 fe ff ff       	jmp    f0104ad7 <syscall+0x57>
        return -E_INVAL;
f0104c56:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104c5b:	e9 77 fe ff ff       	jmp    f0104ad7 <syscall+0x57>
        return -E_NO_MEM;
f0104c60:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
        return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
f0104c65:	e9 6d fe ff ff       	jmp    f0104ad7 <syscall+0x57>
    struct Env *srcenv = NULL;
f0104c6a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
    if (envid2env(srcenvid, &srcenv, 1) < 0)
f0104c71:	83 ec 04             	sub    $0x4,%esp
f0104c74:	6a 01                	push   $0x1
f0104c76:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0104c79:	50                   	push   %eax
f0104c7a:	ff 75 0c             	pushl  0xc(%ebp)
f0104c7d:	e8 76 e5 ff ff       	call   f01031f8 <envid2env>
f0104c82:	83 c4 10             	add    $0x10,%esp
f0104c85:	85 c0                	test   %eax,%eax
f0104c87:	0f 88 09 01 00 00    	js     f0104d96 <syscall+0x316>
    if (srcenv == NULL)
f0104c8d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104c91:	0f 84 09 01 00 00    	je     f0104da0 <syscall+0x320>
    struct Env *dstenv = NULL;
f0104c97:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    if (envid2env(dstenvid, &dstenv, 1) < 0)
f0104c9e:	83 ec 04             	sub    $0x4,%esp
f0104ca1:	6a 01                	push   $0x1
f0104ca3:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104ca6:	50                   	push   %eax
f0104ca7:	ff 75 14             	pushl  0x14(%ebp)
f0104caa:	e8 49 e5 ff ff       	call   f01031f8 <envid2env>
f0104caf:	83 c4 10             	add    $0x10,%esp
f0104cb2:	85 c0                	test   %eax,%eax
f0104cb4:	0f 88 f0 00 00 00    	js     f0104daa <syscall+0x32a>
    if (dstenv == NULL)
f0104cba:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0104cbe:	0f 84 f0 00 00 00    	je     f0104db4 <syscall+0x334>
    if ( ((uintptr_t)dstva) >= UTOP )
f0104cc4:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104ccb:	0f 87 ed 00 00 00    	ja     f0104dbe <syscall+0x33e>
f0104cd1:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104cd8:	0f 87 e0 00 00 00    	ja     f0104dbe <syscall+0x33e>
    if (!(PTE_P & perm)) {
f0104cde:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0104ce1:	83 e0 05             	and    $0x5,%eax
f0104ce4:	83 f8 05             	cmp    $0x5,%eax
f0104ce7:	0f 85 db 00 00 00    	jne    f0104dc8 <syscall+0x348>
    pte_t *src_pte = NULL, *dst_pte = NULL;
f0104ced:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0104cf4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    struct PageInfo *src_pp = page_lookup(srcenv->env_pgdir, srcva, &src_pte);
f0104cfb:	83 ec 04             	sub    $0x4,%esp
f0104cfe:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104d01:	50                   	push   %eax
f0104d02:	ff 75 10             	pushl  0x10(%ebp)
f0104d05:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104d08:	ff 70 60             	pushl  0x60(%eax)
f0104d0b:	e8 d3 c4 ff ff       	call   f01011e3 <page_lookup>
f0104d10:	89 c3                	mov    %eax,%ebx
    if (src_pte == NULL)
f0104d12:	83 c4 10             	add    $0x10,%esp
f0104d15:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104d19:	0f 84 b3 00 00 00    	je     f0104dd2 <syscall+0x352>
    struct PageInfo *dst_pp = page_lookup(dstenv->env_pgdir, dstva, &dst_pte);
f0104d1f:	83 ec 04             	sub    $0x4,%esp
f0104d22:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104d25:	50                   	push   %eax
f0104d26:	ff 75 18             	pushl  0x18(%ebp)
f0104d29:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104d2c:	ff 70 60             	pushl  0x60(%eax)
f0104d2f:	e8 af c4 ff ff       	call   f01011e3 <page_lookup>
    if (dst_pte == NULL) {
f0104d34:	83 c4 10             	add    $0x10,%esp
f0104d37:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104d3b:	74 32                	je     f0104d6f <syscall+0x2ef>
    if ( (perm&PTE_W) && ((*src_pte & PTE_W) == 0) ) {
f0104d3d:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104d41:	74 0c                	je     f0104d4f <syscall+0x2cf>
f0104d43:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d46:	f6 00 02             	testb  $0x2,(%eax)
f0104d49:	0f 84 8d 00 00 00    	je     f0104ddc <syscall+0x35c>
    if (page_insert(dstenv->env_pgdir, src_pp, dstva, perm) < 0)
f0104d4f:	ff 75 1c             	pushl  0x1c(%ebp)
f0104d52:	ff 75 18             	pushl  0x18(%ebp)
f0104d55:	53                   	push   %ebx
f0104d56:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104d59:	ff 70 60             	pushl  0x60(%eax)
f0104d5c:	e8 6b c5 ff ff       	call   f01012cc <page_insert>
f0104d61:	83 c4 10             	add    $0x10,%esp
        return -E_NO_MEM;
f0104d64:	c1 f8 1f             	sar    $0x1f,%eax
f0104d67:	83 e0 fc             	and    $0xfffffffc,%eax
f0104d6a:	e9 68 fd ff ff       	jmp    f0104ad7 <syscall+0x57>
        dst_pte = pgdir_walk(dstenv->env_pgdir, dstva, 1);
f0104d6f:	83 ec 04             	sub    $0x4,%esp
f0104d72:	6a 01                	push   $0x1
f0104d74:	ff 75 18             	pushl  0x18(%ebp)
f0104d77:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104d7a:	ff 70 60             	pushl  0x60(%eax)
f0104d7d:	e8 61 c3 ff ff       	call   f01010e3 <pgdir_walk>
f0104d82:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if (dst_pte == NULL) {
f0104d85:	83 c4 10             	add    $0x10,%esp
f0104d88:	85 c0                	test   %eax,%eax
f0104d8a:	75 b1                	jne    f0104d3d <syscall+0x2bd>
            return -E_NO_MEM;
f0104d8c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104d91:	e9 41 fd ff ff       	jmp    f0104ad7 <syscall+0x57>
        return -E_BAD_ENV;
f0104d96:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104d9b:	e9 37 fd ff ff       	jmp    f0104ad7 <syscall+0x57>
        return -E_BAD_ENV;
f0104da0:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104da5:	e9 2d fd ff ff       	jmp    f0104ad7 <syscall+0x57>
        return -E_BAD_ENV;
f0104daa:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104daf:	e9 23 fd ff ff       	jmp    f0104ad7 <syscall+0x57>
        return -E_BAD_ENV;
f0104db4:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104db9:	e9 19 fd ff ff       	jmp    f0104ad7 <syscall+0x57>
        return -E_INVAL;
f0104dbe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104dc3:	e9 0f fd ff ff       	jmp    f0104ad7 <syscall+0x57>
        return -E_INVAL;
f0104dc8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104dcd:	e9 05 fd ff ff       	jmp    f0104ad7 <syscall+0x57>
        return -E_NO_MEM;
f0104dd2:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104dd7:	e9 fb fc ff ff       	jmp    f0104ad7 <syscall+0x57>
        return -E_INVAL;
f0104ddc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104de1:	e9 f1 fc ff ff       	jmp    f0104ad7 <syscall+0x57>
    struct Env *e = NULL;
f0104de6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    if (envid2env(envid, &e, 1) < 0)
f0104ded:	83 ec 04             	sub    $0x4,%esp
f0104df0:	6a 01                	push   $0x1
f0104df2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104df5:	50                   	push   %eax
f0104df6:	ff 75 0c             	pushl  0xc(%ebp)
f0104df9:	e8 fa e3 ff ff       	call   f01031f8 <envid2env>
f0104dfe:	83 c4 10             	add    $0x10,%esp
f0104e01:	85 c0                	test   %eax,%eax
f0104e03:	78 2b                	js     f0104e30 <syscall+0x3b0>
    if (e == NULL)
f0104e05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e08:	85 c0                	test   %eax,%eax
f0104e0a:	74 2e                	je     f0104e3a <syscall+0x3ba>
    if (((uintptr_t)va) >= UTOP) {
f0104e0c:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104e13:	77 2f                	ja     f0104e44 <syscall+0x3c4>
    page_remove(e->env_pgdir, va);
f0104e15:	83 ec 08             	sub    $0x8,%esp
f0104e18:	ff 75 10             	pushl  0x10(%ebp)
f0104e1b:	ff 70 60             	pushl  0x60(%eax)
f0104e1e:	e8 5b c4 ff ff       	call   f010127e <page_remove>
    return 0;
f0104e23:	83 c4 10             	add    $0x10,%esp
f0104e26:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e2b:	e9 a7 fc ff ff       	jmp    f0104ad7 <syscall+0x57>
        return -E_BAD_ENV;
f0104e30:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104e35:	e9 9d fc ff ff       	jmp    f0104ad7 <syscall+0x57>
        return -E_BAD_ENV;
f0104e3a:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104e3f:	e9 93 fc ff ff       	jmp    f0104ad7 <syscall+0x57>
        return -E_INVAL;
f0104e44:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
        return sys_page_unmap((envid_t)a1, (void *)a2);
f0104e49:	e9 89 fc ff ff       	jmp    f0104ad7 <syscall+0x57>
    if (env_alloc(&newenv, curenv->env_id) < 0) {
f0104e4e:	e8 37 15 00 00       	call   f010638a <cpunum>
f0104e53:	83 ec 08             	sub    $0x8,%esp
f0104e56:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e59:	8b 80 28 c0 3b f0    	mov    -0xfc43fd8(%eax),%eax
f0104e5f:	ff 70 48             	pushl  0x48(%eax)
f0104e62:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104e65:	50                   	push   %eax
f0104e66:	e8 af e4 ff ff       	call   f010331a <env_alloc>
f0104e6b:	83 c4 10             	add    $0x10,%esp
f0104e6e:	85 c0                	test   %eax,%eax
f0104e70:	78 31                	js     f0104ea3 <syscall+0x423>
    newenv->env_tf = curenv->env_tf;
f0104e72:	e8 13 15 00 00       	call   f010638a <cpunum>
f0104e77:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e7a:	8b b0 28 c0 3b f0    	mov    -0xfc43fd8(%eax),%esi
f0104e80:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104e85:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104e88:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
    newenv->env_tf.tf_regs.reg_eax = 0;
f0104e8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e8d:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    newenv->env_status = ENV_NOT_RUNNABLE;
f0104e94:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
    return newenv->env_id;
f0104e9b:	8b 40 48             	mov    0x48(%eax),%eax
f0104e9e:	e9 34 fc ff ff       	jmp    f0104ad7 <syscall+0x57>
        return -E_NO_FREE_ENV;
f0104ea3:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
        return sys_exofork();
f0104ea8:	e9 2a fc ff ff       	jmp    f0104ad7 <syscall+0x57>
    struct Env *e = NULL;
f0104ead:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    if (envid2env(envid, &e, 1) < 0) {
f0104eb4:	83 ec 04             	sub    $0x4,%esp
f0104eb7:	6a 01                	push   $0x1
f0104eb9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104ebc:	50                   	push   %eax
f0104ebd:	ff 75 0c             	pushl  0xc(%ebp)
f0104ec0:	e8 33 e3 ff ff       	call   f01031f8 <envid2env>
f0104ec5:	83 c4 10             	add    $0x10,%esp
f0104ec8:	85 c0                	test   %eax,%eax
f0104eca:	78 1d                	js     f0104ee9 <syscall+0x469>
    if (e == NULL) {
f0104ecc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104ecf:	85 c0                	test   %eax,%eax
f0104ed1:	74 20                	je     f0104ef3 <syscall+0x473>
    if (status > ENV_NOT_RUNNABLE || status < ENV_FREE) {
f0104ed3:	83 7d 10 04          	cmpl   $0x4,0x10(%ebp)
f0104ed7:	77 24                	ja     f0104efd <syscall+0x47d>
    e->env_status = status;
f0104ed9:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104edc:	89 48 54             	mov    %ecx,0x54(%eax)
    return 0;
f0104edf:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ee4:	e9 ee fb ff ff       	jmp    f0104ad7 <syscall+0x57>
        return -E_BAD_ENV;
f0104ee9:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104eee:	e9 e4 fb ff ff       	jmp    f0104ad7 <syscall+0x57>
        return -E_BAD_ENV;
f0104ef3:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104ef8:	e9 da fb ff ff       	jmp    f0104ad7 <syscall+0x57>
        return -E_INVAL;
f0104efd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
        return sys_env_set_status((envid_t)a1, (int)a2);
f0104f02:	e9 d0 fb ff ff       	jmp    f0104ad7 <syscall+0x57>
    struct Env *e = NULL;
f0104f07:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    if (envid2env(envid, &e, 1) < 0) {
f0104f0e:	83 ec 04             	sub    $0x4,%esp
f0104f11:	6a 01                	push   $0x1
f0104f13:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104f16:	50                   	push   %eax
f0104f17:	ff 75 0c             	pushl  0xc(%ebp)
f0104f1a:	e8 d9 e2 ff ff       	call   f01031f8 <envid2env>
f0104f1f:	83 c4 10             	add    $0x10,%esp
f0104f22:	85 c0                	test   %eax,%eax
f0104f24:	78 55                	js     f0104f7b <syscall+0x4fb>
    if (e == NULL) {
f0104f26:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104f2a:	74 59                	je     f0104f85 <syscall+0x505>
    if (curenv->env_id != e->env_id &&
f0104f2c:	e8 59 14 00 00       	call   f010638a <cpunum>
f0104f31:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f34:	8b 90 28 c0 3b f0    	mov    -0xfc43fd8(%eax),%edx
f0104f3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f3d:	8b 40 48             	mov    0x48(%eax),%eax
f0104f40:	39 42 48             	cmp    %eax,0x48(%edx)
f0104f43:	75 13                	jne    f0104f58 <syscall+0x4d8>
    e->env_pgfault_upcall = func;
f0104f45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f48:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104f4b:	89 78 64             	mov    %edi,0x64(%eax)
    return 0;
f0104f4e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f53:	e9 7f fb ff ff       	jmp    f0104ad7 <syscall+0x57>
            curenv->env_id != e->env_parent_id) {
f0104f58:	e8 2d 14 00 00       	call   f010638a <cpunum>
f0104f5d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f60:	8b 90 28 c0 3b f0    	mov    -0xfc43fd8(%eax),%edx
    if (curenv->env_id != e->env_id &&
f0104f66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f69:	8b 40 4c             	mov    0x4c(%eax),%eax
f0104f6c:	39 42 48             	cmp    %eax,0x48(%edx)
f0104f6f:	74 d4                	je     f0104f45 <syscall+0x4c5>
        return -E_BAD_ENV;
f0104f71:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
        return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
f0104f76:	e9 5c fb ff ff       	jmp    f0104ad7 <syscall+0x57>
        return -E_BAD_ENV;
f0104f7b:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104f80:	e9 52 fb ff ff       	jmp    f0104ad7 <syscall+0x57>
        return -E_BAD_ENV;
f0104f85:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104f8a:	e9 48 fb ff ff       	jmp    f0104ad7 <syscall+0x57>
    struct Env *dstenv = NULL;
f0104f8f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
    envid2env(envid, &dstenv, 0);
f0104f96:	83 ec 04             	sub    $0x4,%esp
f0104f99:	6a 00                	push   $0x0
f0104f9b:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104f9e:	50                   	push   %eax
f0104f9f:	ff 75 0c             	pushl  0xc(%ebp)
f0104fa2:	e8 51 e2 ff ff       	call   f01031f8 <envid2env>
    if (dstenv == NULL) {
f0104fa7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104faa:	83 c4 10             	add    $0x10,%esp
f0104fad:	85 c0                	test   %eax,%eax
f0104faf:	0f 84 bb 00 00 00    	je     f0105070 <syscall+0x5f0>
    if (!dstenv->env_ipc_recving) {
f0104fb5:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104fb9:	0f 84 bb 00 00 00    	je     f010507a <syscall+0x5fa>
    pte_t *pte = NULL;
f0104fbf:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    if (va < UTOP) {
f0104fc6:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104fcd:	77 6c                	ja     f010503b <syscall+0x5bb>
        if (va & 0xfff) {
f0104fcf:	8b 55 14             	mov    0x14(%ebp),%edx
f0104fd2:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
        if (perm & perm_check) {
f0104fd8:	8b 45 18             	mov    0x18(%ebp),%eax
f0104fdb:	83 e0 f8             	and    $0xfffffff8,%eax
f0104fde:	09 c2                	or     %eax,%edx
f0104fe0:	0f 85 9e 00 00 00    	jne    f0105084 <syscall+0x604>
        pp = page_lookup(curenv->env_pgdir, srcva, &pte);
f0104fe6:	e8 9f 13 00 00       	call   f010638a <cpunum>
f0104feb:	83 ec 04             	sub    $0x4,%esp
f0104fee:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104ff1:	52                   	push   %edx
f0104ff2:	ff 75 14             	pushl  0x14(%ebp)
f0104ff5:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ff8:	8b 80 28 c0 3b f0    	mov    -0xfc43fd8(%eax),%eax
f0104ffe:	ff 70 60             	pushl  0x60(%eax)
f0105001:	e8 dd c1 ff ff       	call   f01011e3 <page_lookup>
        if (!(*pte & PTE_P)) {
f0105006:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105009:	8b 12                	mov    (%edx),%edx
f010500b:	83 c4 10             	add    $0x10,%esp
f010500e:	f6 c2 01             	test   $0x1,%dl
f0105011:	74 7b                	je     f010508e <syscall+0x60e>
        if (perm & PTE_W) {
f0105013:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0105017:	74 05                	je     f010501e <syscall+0x59e>
            if ((*pte & PTE_W) == 0) {
f0105019:	f6 c2 02             	test   $0x2,%dl
f010501c:	74 7a                	je     f0105098 <syscall+0x618>
    if (pp != NULL) {
f010501e:	85 c0                	test   %eax,%eax
f0105020:	74 19                	je     f010503b <syscall+0x5bb>
                    dstenv->env_ipc_dstva, perm) < 0) {
f0105022:	8b 55 e0             	mov    -0x20(%ebp),%edx
        if (page_insert(dstenv->env_pgdir, pp,
f0105025:	ff 75 18             	pushl  0x18(%ebp)
f0105028:	ff 72 6c             	pushl  0x6c(%edx)
f010502b:	50                   	push   %eax
f010502c:	ff 72 60             	pushl  0x60(%edx)
f010502f:	e8 98 c2 ff ff       	call   f01012cc <page_insert>
f0105034:	83 c4 10             	add    $0x10,%esp
f0105037:	85 c0                	test   %eax,%eax
f0105039:	78 67                	js     f01050a2 <syscall+0x622>
    dstenv->env_ipc_value = value;
f010503b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010503e:	8b 75 10             	mov    0x10(%ebp),%esi
f0105041:	89 70 70             	mov    %esi,0x70(%eax)
    dstenv->env_ipc_from = curenv->env_id;
f0105044:	e8 41 13 00 00       	call   f010638a <cpunum>
f0105049:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010504c:	6b c0 74             	imul   $0x74,%eax,%eax
f010504f:	8b 80 28 c0 3b f0    	mov    -0xfc43fd8(%eax),%eax
f0105055:	8b 40 48             	mov    0x48(%eax),%eax
f0105058:	89 42 74             	mov    %eax,0x74(%edx)
    dstenv->env_ipc_recving = false;
f010505b:	c6 42 68 00          	movb   $0x0,0x68(%edx)
    dstenv->env_status = ENV_RUNNABLE;
f010505f:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
    return 0;
f0105066:	b8 00 00 00 00       	mov    $0x0,%eax
f010506b:	e9 67 fa ff ff       	jmp    f0104ad7 <syscall+0x57>
        return -E_BAD_ENV;
f0105070:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0105075:	e9 5d fa ff ff       	jmp    f0104ad7 <syscall+0x57>
        return -E_IPC_NOT_RECV;
f010507a:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
f010507f:	e9 53 fa ff ff       	jmp    f0104ad7 <syscall+0x57>
            return -E_INVAL;
f0105084:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105089:	e9 49 fa ff ff       	jmp    f0104ad7 <syscall+0x57>
            return -E_INVAL;
f010508e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105093:	e9 3f fa ff ff       	jmp    f0104ad7 <syscall+0x57>
                return -E_INVAL;
f0105098:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010509d:	e9 35 fa ff ff       	jmp    f0104ad7 <syscall+0x57>
            return -E_NO_MEM;
f01050a2:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
        return sys_ipc_try_send((envid_t) a1, (uint32_t) a2,
f01050a7:	e9 2b fa ff ff       	jmp    f0104ad7 <syscall+0x57>
    if (va < UTOP) {
f01050ac:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f01050b3:	77 4e                	ja     f0105103 <syscall+0x683>
        if (va & 0xfff) {
f01050b5:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f01050bc:	75 71                	jne    f010512f <syscall+0x6af>
        curenv->env_ipc_dstva = dstva;
f01050be:	e8 c7 12 00 00       	call   f010638a <cpunum>
f01050c3:	6b c0 74             	imul   $0x74,%eax,%eax
f01050c6:	8b 80 28 c0 3b f0    	mov    -0xfc43fd8(%eax),%eax
f01050cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01050cf:	89 48 6c             	mov    %ecx,0x6c(%eax)
    curenv->env_ipc_recving = true;
f01050d2:	e8 b3 12 00 00       	call   f010638a <cpunum>
f01050d7:	6b c0 74             	imul   $0x74,%eax,%eax
f01050da:	8b 80 28 c0 3b f0    	mov    -0xfc43fd8(%eax),%eax
f01050e0:	c6 40 68 01          	movb   $0x1,0x68(%eax)
    curenv->env_status = ENV_NOT_RUNNABLE;
f01050e4:	e8 a1 12 00 00       	call   f010638a <cpunum>
f01050e9:	6b c0 74             	imul   $0x74,%eax,%eax
f01050ec:	8b 80 28 c0 3b f0    	mov    -0xfc43fd8(%eax),%eax
f01050f2:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	return 0;
f01050f9:	b8 00 00 00 00       	mov    $0x0,%eax
f01050fe:	e9 d4 f9 ff ff       	jmp    f0104ad7 <syscall+0x57>
        curenv->env_ipc_dstva = NULL;
f0105103:	e8 82 12 00 00       	call   f010638a <cpunum>
f0105108:	6b c0 74             	imul   $0x74,%eax,%eax
f010510b:	8b 80 28 c0 3b f0    	mov    -0xfc43fd8(%eax),%eax
f0105111:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)
f0105118:	eb b8                	jmp    f01050d2 <syscall+0x652>
	    panic("syscall %d not implemented", syscallno);
f010511a:	50                   	push   %eax
f010511b:	68 f8 81 10 f0       	push   $0xf01081f8
f0105120:	68 3c 02 00 00       	push   $0x23c
f0105125:	68 e9 81 10 f0       	push   $0xf01081e9
f010512a:	e8 11 af ff ff       	call   f0100040 <_panic>
            return -E_INVAL;
f010512f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105134:	e9 9e f9 ff ff       	jmp    f0104ad7 <syscall+0x57>

f0105139 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0105139:	55                   	push   %ebp
f010513a:	89 e5                	mov    %esp,%ebp
f010513c:	57                   	push   %edi
f010513d:	56                   	push   %esi
f010513e:	53                   	push   %ebx
f010513f:	83 ec 14             	sub    $0x14,%esp
f0105142:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105145:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0105148:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010514b:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f010514e:	8b 1a                	mov    (%edx),%ebx
f0105150:	8b 01                	mov    (%ecx),%eax
f0105152:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105155:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f010515c:	eb 23                	jmp    f0105181 <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010515e:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0105161:	eb 1e                	jmp    f0105181 <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0105163:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105166:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105169:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010516d:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0105170:	73 46                	jae    f01051b8 <stab_binsearch+0x7f>
			*region_left = m;
f0105172:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105175:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0105177:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f010517a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0105181:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0105184:	7f 5f                	jg     f01051e5 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0105186:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105189:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f010518c:	89 d0                	mov    %edx,%eax
f010518e:	c1 e8 1f             	shr    $0x1f,%eax
f0105191:	01 d0                	add    %edx,%eax
f0105193:	89 c7                	mov    %eax,%edi
f0105195:	d1 ff                	sar    %edi
f0105197:	83 e0 fe             	and    $0xfffffffe,%eax
f010519a:	01 f8                	add    %edi,%eax
f010519c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010519f:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f01051a3:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f01051a5:	39 c3                	cmp    %eax,%ebx
f01051a7:	7f b5                	jg     f010515e <stab_binsearch+0x25>
f01051a9:	0f b6 0a             	movzbl (%edx),%ecx
f01051ac:	83 ea 0c             	sub    $0xc,%edx
f01051af:	39 f1                	cmp    %esi,%ecx
f01051b1:	74 b0                	je     f0105163 <stab_binsearch+0x2a>
			m--;
f01051b3:	83 e8 01             	sub    $0x1,%eax
f01051b6:	eb ed                	jmp    f01051a5 <stab_binsearch+0x6c>
		} else if (stabs[m].n_value > addr) {
f01051b8:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01051bb:	76 14                	jbe    f01051d1 <stab_binsearch+0x98>
			*region_right = m - 1;
f01051bd:	83 e8 01             	sub    $0x1,%eax
f01051c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01051c3:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01051c6:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f01051c8:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01051cf:	eb b0                	jmp    f0105181 <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01051d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01051d4:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f01051d6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01051da:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f01051dc:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01051e3:	eb 9c                	jmp    f0105181 <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f01051e5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01051e9:	75 15                	jne    f0105200 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f01051eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01051ee:	8b 00                	mov    (%eax),%eax
f01051f0:	83 e8 01             	sub    $0x1,%eax
f01051f3:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01051f6:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f01051f8:	83 c4 14             	add    $0x14,%esp
f01051fb:	5b                   	pop    %ebx
f01051fc:	5e                   	pop    %esi
f01051fd:	5f                   	pop    %edi
f01051fe:	5d                   	pop    %ebp
f01051ff:	c3                   	ret    
		for (l = *region_right;
f0105200:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105203:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0105205:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105208:	8b 0f                	mov    (%edi),%ecx
f010520a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010520d:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0105210:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f0105214:	eb 03                	jmp    f0105219 <stab_binsearch+0xe0>
		     l--)
f0105216:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0105219:	39 c1                	cmp    %eax,%ecx
f010521b:	7d 0a                	jge    f0105227 <stab_binsearch+0xee>
		     l > *region_left && stabs[l].n_type != type;
f010521d:	0f b6 1a             	movzbl (%edx),%ebx
f0105220:	83 ea 0c             	sub    $0xc,%edx
f0105223:	39 f3                	cmp    %esi,%ebx
f0105225:	75 ef                	jne    f0105216 <stab_binsearch+0xdd>
		*region_left = l;
f0105227:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010522a:	89 07                	mov    %eax,(%edi)
}
f010522c:	eb ca                	jmp    f01051f8 <stab_binsearch+0xbf>

f010522e <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010522e:	f3 0f 1e fb          	endbr32 
f0105232:	55                   	push   %ebp
f0105233:	89 e5                	mov    %esp,%ebp
f0105235:	57                   	push   %edi
f0105236:	56                   	push   %esi
f0105237:	53                   	push   %ebx
f0105238:	83 ec 4c             	sub    $0x4c,%esp
f010523b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010523e:	c7 03 4c 82 10 f0    	movl   $0xf010824c,(%ebx)
	info->eip_line = 0;
f0105244:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f010524b:	c7 43 08 4c 82 10 f0 	movl   $0xf010824c,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0105252:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0105259:	8b 45 08             	mov    0x8(%ebp),%eax
f010525c:	89 43 10             	mov    %eax,0x10(%ebx)
	info->eip_fn_narg = 0;
f010525f:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0105266:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f010526b:	0f 86 1b 01 00 00    	jbe    f010538c <debuginfo_eip+0x15e>
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0105271:	c7 45 bc 2c 8f 11 f0 	movl   $0xf0118f2c,-0x44(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0105278:	c7 45 b4 c1 56 11 f0 	movl   $0xf01156c1,-0x4c(%ebp)
		stab_end = __STAB_END__;
f010527f:	bf c0 56 11 f0       	mov    $0xf01156c0,%edi
		stabs = __STAB_BEGIN__;
f0105284:	c7 45 b8 f0 87 10 f0 	movl   $0xf01087f0,-0x48(%ebp)
            return -1;
        }
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010528b:	8b 75 bc             	mov    -0x44(%ebp),%esi
f010528e:	39 75 b4             	cmp    %esi,-0x4c(%ebp)
f0105291:	0f 83 5d 02 00 00    	jae    f01054f4 <debuginfo_eip+0x2c6>
f0105297:	80 7e ff 00          	cmpb   $0x0,-0x1(%esi)
f010529b:	0f 85 5a 02 00 00    	jne    f01054fb <debuginfo_eip+0x2cd>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01052a1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01052a8:	8b 75 b8             	mov    -0x48(%ebp),%esi
f01052ab:	29 f7                	sub    %esi,%edi
f01052ad:	c1 ff 02             	sar    $0x2,%edi
f01052b0:	69 c7 ab aa aa aa    	imul   $0xaaaaaaab,%edi,%eax
f01052b6:	83 e8 01             	sub    $0x1,%eax
f01052b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01052bc:	83 ec 08             	sub    $0x8,%esp
f01052bf:	ff 75 08             	pushl  0x8(%ebp)
f01052c2:	6a 64                	push   $0x64
f01052c4:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01052c7:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01052ca:	89 f0                	mov    %esi,%eax
f01052cc:	e8 68 fe ff ff       	call   f0105139 <stab_binsearch>
	if (lfile == 0)
f01052d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01052d4:	83 c4 10             	add    $0x10,%esp
f01052d7:	85 c0                	test   %eax,%eax
f01052d9:	0f 84 23 02 00 00    	je     f0105502 <debuginfo_eip+0x2d4>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01052df:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01052e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01052e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01052e8:	83 ec 08             	sub    $0x8,%esp
f01052eb:	ff 75 08             	pushl  0x8(%ebp)
f01052ee:	6a 24                	push   $0x24
f01052f0:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01052f3:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01052f6:	89 f0                	mov    %esi,%eax
f01052f8:	e8 3c fe ff ff       	call   f0105139 <stab_binsearch>

	if (lfun <= rfun) {
f01052fd:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105300:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105303:	83 c4 10             	add    $0x10,%esp
f0105306:	39 d0                	cmp    %edx,%eax
f0105308:	0f 8f 2b 01 00 00    	jg     f0105439 <debuginfo_eip+0x20b>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010530e:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0105311:	8d 3c 8e             	lea    (%esi,%ecx,4),%edi
f0105314:	8b 0f                	mov    (%edi),%ecx
f0105316:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0105319:	2b 75 b4             	sub    -0x4c(%ebp),%esi
f010531c:	39 f1                	cmp    %esi,%ecx
f010531e:	73 06                	jae    f0105326 <debuginfo_eip+0xf8>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105320:	03 4d b4             	add    -0x4c(%ebp),%ecx
f0105323:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0105326:	8b 4f 08             	mov    0x8(%edi),%ecx
f0105329:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f010532c:	29 4d 08             	sub    %ecx,0x8(%ebp)
		// Search within the function definition for the line number.
		lline = lfun;
f010532f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0105332:	89 55 d0             	mov    %edx,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0105335:	83 ec 08             	sub    $0x8,%esp
f0105338:	6a 3a                	push   $0x3a
f010533a:	ff 73 08             	pushl  0x8(%ebx)
f010533d:	e8 0a 0a 00 00       	call   f0105d4c <strfind>
f0105342:	2b 43 08             	sub    0x8(%ebx),%eax
f0105345:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0105348:	83 c4 08             	add    $0x8,%esp
f010534b:	ff 75 08             	pushl  0x8(%ebp)
f010534e:	6a 44                	push   $0x44
f0105350:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0105353:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0105356:	8b 75 b8             	mov    -0x48(%ebp),%esi
f0105359:	89 f0                	mov    %esi,%eax
f010535b:	e8 d9 fd ff ff       	call   f0105139 <stab_binsearch>

    if (lline <= rline) {
f0105360:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0105363:	83 c4 10             	add    $0x10,%esp
f0105366:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0105369:	0f 8f 9a 01 00 00    	jg     f0105509 <debuginfo_eip+0x2db>
        info->eip_line = stabs[lline].n_desc;
f010536f:	89 d0                	mov    %edx,%eax
f0105371:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0105374:	0f b7 4c 96 06       	movzwl 0x6(%esi,%edx,4),%ecx
f0105379:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010537c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010537f:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
f0105383:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0105387:	e9 ce 00 00 00       	jmp    f010545a <debuginfo_eip+0x22c>
        if (user_mem_check(curenv, usd, sizeof(const struct UserStabData),
f010538c:	e8 f9 0f 00 00       	call   f010638a <cpunum>
f0105391:	6a 05                	push   $0x5
f0105393:	6a 10                	push   $0x10
f0105395:	68 00 00 20 00       	push   $0x200000
f010539a:	6b c0 74             	imul   $0x74,%eax,%eax
f010539d:	ff b0 28 c0 3b f0    	pushl  -0xfc43fd8(%eax)
f01053a3:	e8 c9 dc ff ff       	call   f0103071 <user_mem_check>
f01053a8:	83 c4 10             	add    $0x10,%esp
f01053ab:	85 c0                	test   %eax,%eax
f01053ad:	0f 88 33 01 00 00    	js     f01054e6 <debuginfo_eip+0x2b8>
		stabs = usd->stabs;
f01053b3:	a1 00 00 20 00       	mov    0x200000,%eax
f01053b8:	89 45 b8             	mov    %eax,-0x48(%ebp)
		stab_end = usd->stab_end;
f01053bb:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f01053c1:	8b 35 08 00 20 00    	mov    0x200008,%esi
f01053c7:	89 75 b4             	mov    %esi,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f01053ca:	8b 0d 0c 00 20 00    	mov    0x20000c,%ecx
f01053d0:	89 4d bc             	mov    %ecx,-0x44(%ebp)
        size_t stabs_size = ((uintptr_t)stab_end) - ((uintptr_t) stabs);
f01053d3:	89 fa                	mov    %edi,%edx
f01053d5:	89 c6                	mov    %eax,%esi
f01053d7:	29 c2                	sub    %eax,%edx
f01053d9:	89 55 c4             	mov    %edx,-0x3c(%ebp)
        if (user_mem_check(curenv, stabs, stabs_size,
f01053dc:	e8 a9 0f 00 00       	call   f010638a <cpunum>
f01053e1:	6a 05                	push   $0x5
f01053e3:	ff 75 c4             	pushl  -0x3c(%ebp)
f01053e6:	56                   	push   %esi
f01053e7:	6b c0 74             	imul   $0x74,%eax,%eax
f01053ea:	ff b0 28 c0 3b f0    	pushl  -0xfc43fd8(%eax)
f01053f0:	e8 7c dc ff ff       	call   f0103071 <user_mem_check>
f01053f5:	83 c4 10             	add    $0x10,%esp
f01053f8:	85 c0                	test   %eax,%eax
f01053fa:	0f 88 ed 00 00 00    	js     f01054ed <debuginfo_eip+0x2bf>
        size_t stabstr_size = ((uintptr_t)stabstr_end) - ((uintptr_t) stabstr);
f0105400:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0105403:	8b 75 b4             	mov    -0x4c(%ebp),%esi
f0105406:	29 f0                	sub    %esi,%eax
f0105408:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        if (user_mem_check(curenv, stabstr, stabstr_size,
f010540b:	e8 7a 0f 00 00       	call   f010638a <cpunum>
f0105410:	6a 05                	push   $0x5
f0105412:	ff 75 c4             	pushl  -0x3c(%ebp)
f0105415:	56                   	push   %esi
f0105416:	6b c0 74             	imul   $0x74,%eax,%eax
f0105419:	ff b0 28 c0 3b f0    	pushl  -0xfc43fd8(%eax)
f010541f:	e8 4d dc ff ff       	call   f0103071 <user_mem_check>
f0105424:	83 c4 10             	add    $0x10,%esp
f0105427:	85 c0                	test   %eax,%eax
f0105429:	0f 89 5c fe ff ff    	jns    f010528b <debuginfo_eip+0x5d>
            return -1;
f010542f:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0105434:	e9 dc 00 00 00       	jmp    f0105515 <debuginfo_eip+0x2e7>
		info->eip_fn_addr = addr;
f0105439:	8b 45 08             	mov    0x8(%ebp),%eax
f010543c:	89 43 10             	mov    %eax,0x10(%ebx)
		lline = lfile;
f010543f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105442:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0105445:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105448:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010544b:	e9 e5 fe ff ff       	jmp    f0105335 <debuginfo_eip+0x107>
f0105450:	83 e8 01             	sub    $0x1,%eax
f0105453:	83 ea 0c             	sub    $0xc,%edx
	while (lline >= lfile
f0105456:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f010545a:	89 45 c0             	mov    %eax,-0x40(%ebp)
f010545d:	39 c7                	cmp    %eax,%edi
f010545f:	7f 45                	jg     f01054a6 <debuginfo_eip+0x278>
	       && stabs[lline].n_type != N_SOL
f0105461:	0f b6 0a             	movzbl (%edx),%ecx
f0105464:	80 f9 84             	cmp    $0x84,%cl
f0105467:	74 19                	je     f0105482 <debuginfo_eip+0x254>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105469:	80 f9 64             	cmp    $0x64,%cl
f010546c:	75 e2                	jne    f0105450 <debuginfo_eip+0x222>
f010546e:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f0105472:	74 dc                	je     f0105450 <debuginfo_eip+0x222>
f0105474:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0105478:	74 11                	je     f010548b <debuginfo_eip+0x25d>
f010547a:	8b 7d c0             	mov    -0x40(%ebp),%edi
f010547d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105480:	eb 09                	jmp    f010548b <debuginfo_eip+0x25d>
f0105482:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0105486:	74 03                	je     f010548b <debuginfo_eip+0x25d>
f0105488:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010548b:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010548e:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0105491:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0105494:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0105497:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f010549a:	29 f8                	sub    %edi,%eax
f010549c:	39 c2                	cmp    %eax,%edx
f010549e:	73 06                	jae    f01054a6 <debuginfo_eip+0x278>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01054a0:	89 f8                	mov    %edi,%eax
f01054a2:	01 d0                	add    %edx,%eax
f01054a4:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01054a6:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01054a9:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01054ac:	ba 00 00 00 00       	mov    $0x0,%edx
	if (lfun < rfun)
f01054b1:	39 f0                	cmp    %esi,%eax
f01054b3:	7d 60                	jge    f0105515 <debuginfo_eip+0x2e7>
		for (lline = lfun + 1;
f01054b5:	8d 50 01             	lea    0x1(%eax),%edx
f01054b8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01054bb:	89 d0                	mov    %edx,%eax
f01054bd:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01054c0:	8b 7d b8             	mov    -0x48(%ebp),%edi
f01054c3:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f01054c7:	eb 04                	jmp    f01054cd <debuginfo_eip+0x29f>
			info->eip_fn_narg++;
f01054c9:	83 43 14 01          	addl   $0x1,0x14(%ebx)
		for (lline = lfun + 1;
f01054cd:	39 c6                	cmp    %eax,%esi
f01054cf:	7e 3f                	jle    f0105510 <debuginfo_eip+0x2e2>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01054d1:	0f b6 0a             	movzbl (%edx),%ecx
f01054d4:	83 c0 01             	add    $0x1,%eax
f01054d7:	83 c2 0c             	add    $0xc,%edx
f01054da:	80 f9 a0             	cmp    $0xa0,%cl
f01054dd:	74 ea                	je     f01054c9 <debuginfo_eip+0x29b>
	return 0;
f01054df:	ba 00 00 00 00       	mov    $0x0,%edx
f01054e4:	eb 2f                	jmp    f0105515 <debuginfo_eip+0x2e7>
            return -1;
f01054e6:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01054eb:	eb 28                	jmp    f0105515 <debuginfo_eip+0x2e7>
            return -1;
f01054ed:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01054f2:	eb 21                	jmp    f0105515 <debuginfo_eip+0x2e7>
		return -1;
f01054f4:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01054f9:	eb 1a                	jmp    f0105515 <debuginfo_eip+0x2e7>
f01054fb:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0105500:	eb 13                	jmp    f0105515 <debuginfo_eip+0x2e7>
		return -1;
f0105502:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0105507:	eb 0c                	jmp    f0105515 <debuginfo_eip+0x2e7>
        return -1;
f0105509:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f010550e:	eb 05                	jmp    f0105515 <debuginfo_eip+0x2e7>
	return 0;
f0105510:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105515:	89 d0                	mov    %edx,%eax
f0105517:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010551a:	5b                   	pop    %ebx
f010551b:	5e                   	pop    %esi
f010551c:	5f                   	pop    %edi
f010551d:	5d                   	pop    %ebp
f010551e:	c3                   	ret    

f010551f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010551f:	55                   	push   %ebp
f0105520:	89 e5                	mov    %esp,%ebp
f0105522:	57                   	push   %edi
f0105523:	56                   	push   %esi
f0105524:	53                   	push   %ebx
f0105525:	83 ec 1c             	sub    $0x1c,%esp
f0105528:	89 c7                	mov    %eax,%edi
f010552a:	89 d6                	mov    %edx,%esi
f010552c:	8b 45 08             	mov    0x8(%ebp),%eax
f010552f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105532:	89 d1                	mov    %edx,%ecx
f0105534:	89 c2                	mov    %eax,%edx
f0105536:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105539:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010553c:	8b 45 10             	mov    0x10(%ebp),%eax
f010553f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105542:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105545:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f010554c:	39 c2                	cmp    %eax,%edx
f010554e:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0105551:	72 3e                	jb     f0105591 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105553:	83 ec 0c             	sub    $0xc,%esp
f0105556:	ff 75 18             	pushl  0x18(%ebp)
f0105559:	83 eb 01             	sub    $0x1,%ebx
f010555c:	53                   	push   %ebx
f010555d:	50                   	push   %eax
f010555e:	83 ec 08             	sub    $0x8,%esp
f0105561:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105564:	ff 75 e0             	pushl  -0x20(%ebp)
f0105567:	ff 75 dc             	pushl  -0x24(%ebp)
f010556a:	ff 75 d8             	pushl  -0x28(%ebp)
f010556d:	e8 2e 12 00 00       	call   f01067a0 <__udivdi3>
f0105572:	83 c4 18             	add    $0x18,%esp
f0105575:	52                   	push   %edx
f0105576:	50                   	push   %eax
f0105577:	89 f2                	mov    %esi,%edx
f0105579:	89 f8                	mov    %edi,%eax
f010557b:	e8 9f ff ff ff       	call   f010551f <printnum>
f0105580:	83 c4 20             	add    $0x20,%esp
f0105583:	eb 13                	jmp    f0105598 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105585:	83 ec 08             	sub    $0x8,%esp
f0105588:	56                   	push   %esi
f0105589:	ff 75 18             	pushl  0x18(%ebp)
f010558c:	ff d7                	call   *%edi
f010558e:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0105591:	83 eb 01             	sub    $0x1,%ebx
f0105594:	85 db                	test   %ebx,%ebx
f0105596:	7f ed                	jg     f0105585 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105598:	83 ec 08             	sub    $0x8,%esp
f010559b:	56                   	push   %esi
f010559c:	83 ec 04             	sub    $0x4,%esp
f010559f:	ff 75 e4             	pushl  -0x1c(%ebp)
f01055a2:	ff 75 e0             	pushl  -0x20(%ebp)
f01055a5:	ff 75 dc             	pushl  -0x24(%ebp)
f01055a8:	ff 75 d8             	pushl  -0x28(%ebp)
f01055ab:	e8 00 13 00 00       	call   f01068b0 <__umoddi3>
f01055b0:	83 c4 14             	add    $0x14,%esp
f01055b3:	0f be 80 56 82 10 f0 	movsbl -0xfef7daa(%eax),%eax
f01055ba:	50                   	push   %eax
f01055bb:	ff d7                	call   *%edi
}
f01055bd:	83 c4 10             	add    $0x10,%esp
f01055c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01055c3:	5b                   	pop    %ebx
f01055c4:	5e                   	pop    %esi
f01055c5:	5f                   	pop    %edi
f01055c6:	5d                   	pop    %ebp
f01055c7:	c3                   	ret    

f01055c8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01055c8:	f3 0f 1e fb          	endbr32 
f01055cc:	55                   	push   %ebp
f01055cd:	89 e5                	mov    %esp,%ebp
f01055cf:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01055d2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01055d6:	8b 10                	mov    (%eax),%edx
f01055d8:	3b 50 04             	cmp    0x4(%eax),%edx
f01055db:	73 0a                	jae    f01055e7 <sprintputch+0x1f>
		*b->buf++ = ch;
f01055dd:	8d 4a 01             	lea    0x1(%edx),%ecx
f01055e0:	89 08                	mov    %ecx,(%eax)
f01055e2:	8b 45 08             	mov    0x8(%ebp),%eax
f01055e5:	88 02                	mov    %al,(%edx)
}
f01055e7:	5d                   	pop    %ebp
f01055e8:	c3                   	ret    

f01055e9 <printfmt>:
{
f01055e9:	f3 0f 1e fb          	endbr32 
f01055ed:	55                   	push   %ebp
f01055ee:	89 e5                	mov    %esp,%ebp
f01055f0:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01055f3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01055f6:	50                   	push   %eax
f01055f7:	ff 75 10             	pushl  0x10(%ebp)
f01055fa:	ff 75 0c             	pushl  0xc(%ebp)
f01055fd:	ff 75 08             	pushl  0x8(%ebp)
f0105600:	e8 05 00 00 00       	call   f010560a <vprintfmt>
}
f0105605:	83 c4 10             	add    $0x10,%esp
f0105608:	c9                   	leave  
f0105609:	c3                   	ret    

f010560a <vprintfmt>:
{
f010560a:	f3 0f 1e fb          	endbr32 
f010560e:	55                   	push   %ebp
f010560f:	89 e5                	mov    %esp,%ebp
f0105611:	57                   	push   %edi
f0105612:	56                   	push   %esi
f0105613:	53                   	push   %ebx
f0105614:	83 ec 3c             	sub    $0x3c,%esp
f0105617:	8b 75 08             	mov    0x8(%ebp),%esi
f010561a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010561d:	8b 7d 10             	mov    0x10(%ebp),%edi
f0105620:	e9 4a 03 00 00       	jmp    f010596f <vprintfmt+0x365>
		padc = ' ';
f0105625:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
f0105629:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f0105630:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0105637:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f010563e:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0105643:	8d 47 01             	lea    0x1(%edi),%eax
f0105646:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105649:	0f b6 17             	movzbl (%edi),%edx
f010564c:	8d 42 dd             	lea    -0x23(%edx),%eax
f010564f:	3c 55                	cmp    $0x55,%al
f0105651:	0f 87 de 03 00 00    	ja     f0105a35 <vprintfmt+0x42b>
f0105657:	0f b6 c0             	movzbl %al,%eax
f010565a:	3e ff 24 85 a0 83 10 	notrack jmp *-0xfef7c60(,%eax,4)
f0105661:	f0 
f0105662:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0105665:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
f0105669:	eb d8                	jmp    f0105643 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
f010566b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010566e:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
f0105672:	eb cf                	jmp    f0105643 <vprintfmt+0x39>
f0105674:	0f b6 d2             	movzbl %dl,%edx
f0105677:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f010567a:	b8 00 00 00 00       	mov    $0x0,%eax
f010567f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0105682:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0105685:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0105689:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f010568c:	8d 4a d0             	lea    -0x30(%edx),%ecx
f010568f:	83 f9 09             	cmp    $0x9,%ecx
f0105692:	77 55                	ja     f01056e9 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
f0105694:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0105697:	eb e9                	jmp    f0105682 <vprintfmt+0x78>
			precision = va_arg(ap, int);
f0105699:	8b 45 14             	mov    0x14(%ebp),%eax
f010569c:	8b 00                	mov    (%eax),%eax
f010569e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01056a1:	8b 45 14             	mov    0x14(%ebp),%eax
f01056a4:	8d 40 04             	lea    0x4(%eax),%eax
f01056a7:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01056aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f01056ad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01056b1:	79 90                	jns    f0105643 <vprintfmt+0x39>
				width = precision, precision = -1;
f01056b3:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01056b6:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01056b9:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f01056c0:	eb 81                	jmp    f0105643 <vprintfmt+0x39>
f01056c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01056c5:	85 c0                	test   %eax,%eax
f01056c7:	ba 00 00 00 00       	mov    $0x0,%edx
f01056cc:	0f 49 d0             	cmovns %eax,%edx
f01056cf:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01056d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01056d5:	e9 69 ff ff ff       	jmp    f0105643 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
f01056da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f01056dd:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f01056e4:	e9 5a ff ff ff       	jmp    f0105643 <vprintfmt+0x39>
f01056e9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01056ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01056ef:	eb bc                	jmp    f01056ad <vprintfmt+0xa3>
			lflag++;
f01056f1:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f01056f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01056f7:	e9 47 ff ff ff       	jmp    f0105643 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
f01056fc:	8b 45 14             	mov    0x14(%ebp),%eax
f01056ff:	8d 78 04             	lea    0x4(%eax),%edi
f0105702:	83 ec 08             	sub    $0x8,%esp
f0105705:	53                   	push   %ebx
f0105706:	ff 30                	pushl  (%eax)
f0105708:	ff d6                	call   *%esi
			break;
f010570a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f010570d:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0105710:	e9 57 02 00 00       	jmp    f010596c <vprintfmt+0x362>
			err = va_arg(ap, int);
f0105715:	8b 45 14             	mov    0x14(%ebp),%eax
f0105718:	8d 78 04             	lea    0x4(%eax),%edi
f010571b:	8b 00                	mov    (%eax),%eax
f010571d:	99                   	cltd   
f010571e:	31 d0                	xor    %edx,%eax
f0105720:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105722:	83 f8 0f             	cmp    $0xf,%eax
f0105725:	7f 23                	jg     f010574a <vprintfmt+0x140>
f0105727:	8b 14 85 00 85 10 f0 	mov    -0xfef7b00(,%eax,4),%edx
f010572e:	85 d2                	test   %edx,%edx
f0105730:	74 18                	je     f010574a <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
f0105732:	52                   	push   %edx
f0105733:	68 2b 79 10 f0       	push   $0xf010792b
f0105738:	53                   	push   %ebx
f0105739:	56                   	push   %esi
f010573a:	e8 aa fe ff ff       	call   f01055e9 <printfmt>
f010573f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0105742:	89 7d 14             	mov    %edi,0x14(%ebp)
f0105745:	e9 22 02 00 00       	jmp    f010596c <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
f010574a:	50                   	push   %eax
f010574b:	68 6e 82 10 f0       	push   $0xf010826e
f0105750:	53                   	push   %ebx
f0105751:	56                   	push   %esi
f0105752:	e8 92 fe ff ff       	call   f01055e9 <printfmt>
f0105757:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010575a:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f010575d:	e9 0a 02 00 00       	jmp    f010596c <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
f0105762:	8b 45 14             	mov    0x14(%ebp),%eax
f0105765:	83 c0 04             	add    $0x4,%eax
f0105768:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010576b:	8b 45 14             	mov    0x14(%ebp),%eax
f010576e:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f0105770:	85 d2                	test   %edx,%edx
f0105772:	b8 67 82 10 f0       	mov    $0xf0108267,%eax
f0105777:	0f 45 c2             	cmovne %edx,%eax
f010577a:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
f010577d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105781:	7e 06                	jle    f0105789 <vprintfmt+0x17f>
f0105783:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
f0105787:	75 0d                	jne    f0105796 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105789:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010578c:	89 c7                	mov    %eax,%edi
f010578e:	03 45 e0             	add    -0x20(%ebp),%eax
f0105791:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105794:	eb 55                	jmp    f01057eb <vprintfmt+0x1e1>
f0105796:	83 ec 08             	sub    $0x8,%esp
f0105799:	ff 75 d8             	pushl  -0x28(%ebp)
f010579c:	ff 75 cc             	pushl  -0x34(%ebp)
f010579f:	e8 37 04 00 00       	call   f0105bdb <strnlen>
f01057a4:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01057a7:	29 c2                	sub    %eax,%edx
f01057a9:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f01057ac:	83 c4 10             	add    $0x10,%esp
f01057af:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
f01057b1:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f01057b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f01057b8:	85 ff                	test   %edi,%edi
f01057ba:	7e 11                	jle    f01057cd <vprintfmt+0x1c3>
					putch(padc, putdat);
f01057bc:	83 ec 08             	sub    $0x8,%esp
f01057bf:	53                   	push   %ebx
f01057c0:	ff 75 e0             	pushl  -0x20(%ebp)
f01057c3:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f01057c5:	83 ef 01             	sub    $0x1,%edi
f01057c8:	83 c4 10             	add    $0x10,%esp
f01057cb:	eb eb                	jmp    f01057b8 <vprintfmt+0x1ae>
f01057cd:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01057d0:	85 d2                	test   %edx,%edx
f01057d2:	b8 00 00 00 00       	mov    $0x0,%eax
f01057d7:	0f 49 c2             	cmovns %edx,%eax
f01057da:	29 c2                	sub    %eax,%edx
f01057dc:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01057df:	eb a8                	jmp    f0105789 <vprintfmt+0x17f>
					putch(ch, putdat);
f01057e1:	83 ec 08             	sub    $0x8,%esp
f01057e4:	53                   	push   %ebx
f01057e5:	52                   	push   %edx
f01057e6:	ff d6                	call   *%esi
f01057e8:	83 c4 10             	add    $0x10,%esp
f01057eb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01057ee:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01057f0:	83 c7 01             	add    $0x1,%edi
f01057f3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01057f7:	0f be d0             	movsbl %al,%edx
f01057fa:	85 d2                	test   %edx,%edx
f01057fc:	74 4b                	je     f0105849 <vprintfmt+0x23f>
f01057fe:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105802:	78 06                	js     f010580a <vprintfmt+0x200>
f0105804:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0105808:	78 1e                	js     f0105828 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
f010580a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010580e:	74 d1                	je     f01057e1 <vprintfmt+0x1d7>
f0105810:	0f be c0             	movsbl %al,%eax
f0105813:	83 e8 20             	sub    $0x20,%eax
f0105816:	83 f8 5e             	cmp    $0x5e,%eax
f0105819:	76 c6                	jbe    f01057e1 <vprintfmt+0x1d7>
					putch('?', putdat);
f010581b:	83 ec 08             	sub    $0x8,%esp
f010581e:	53                   	push   %ebx
f010581f:	6a 3f                	push   $0x3f
f0105821:	ff d6                	call   *%esi
f0105823:	83 c4 10             	add    $0x10,%esp
f0105826:	eb c3                	jmp    f01057eb <vprintfmt+0x1e1>
f0105828:	89 cf                	mov    %ecx,%edi
f010582a:	eb 0e                	jmp    f010583a <vprintfmt+0x230>
				putch(' ', putdat);
f010582c:	83 ec 08             	sub    $0x8,%esp
f010582f:	53                   	push   %ebx
f0105830:	6a 20                	push   $0x20
f0105832:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0105834:	83 ef 01             	sub    $0x1,%edi
f0105837:	83 c4 10             	add    $0x10,%esp
f010583a:	85 ff                	test   %edi,%edi
f010583c:	7f ee                	jg     f010582c <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
f010583e:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0105841:	89 45 14             	mov    %eax,0x14(%ebp)
f0105844:	e9 23 01 00 00       	jmp    f010596c <vprintfmt+0x362>
f0105849:	89 cf                	mov    %ecx,%edi
f010584b:	eb ed                	jmp    f010583a <vprintfmt+0x230>
	if (lflag >= 2)
f010584d:	83 f9 01             	cmp    $0x1,%ecx
f0105850:	7f 1b                	jg     f010586d <vprintfmt+0x263>
	else if (lflag)
f0105852:	85 c9                	test   %ecx,%ecx
f0105854:	74 63                	je     f01058b9 <vprintfmt+0x2af>
		return va_arg(*ap, long);
f0105856:	8b 45 14             	mov    0x14(%ebp),%eax
f0105859:	8b 00                	mov    (%eax),%eax
f010585b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010585e:	99                   	cltd   
f010585f:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105862:	8b 45 14             	mov    0x14(%ebp),%eax
f0105865:	8d 40 04             	lea    0x4(%eax),%eax
f0105868:	89 45 14             	mov    %eax,0x14(%ebp)
f010586b:	eb 17                	jmp    f0105884 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
f010586d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105870:	8b 50 04             	mov    0x4(%eax),%edx
f0105873:	8b 00                	mov    (%eax),%eax
f0105875:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105878:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010587b:	8b 45 14             	mov    0x14(%ebp),%eax
f010587e:	8d 40 08             	lea    0x8(%eax),%eax
f0105881:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0105884:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105887:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f010588a:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f010588f:	85 c9                	test   %ecx,%ecx
f0105891:	0f 89 bb 00 00 00    	jns    f0105952 <vprintfmt+0x348>
				putch('-', putdat);
f0105897:	83 ec 08             	sub    $0x8,%esp
f010589a:	53                   	push   %ebx
f010589b:	6a 2d                	push   $0x2d
f010589d:	ff d6                	call   *%esi
				num = -(long long) num;
f010589f:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01058a2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01058a5:	f7 da                	neg    %edx
f01058a7:	83 d1 00             	adc    $0x0,%ecx
f01058aa:	f7 d9                	neg    %ecx
f01058ac:	83 c4 10             	add    $0x10,%esp
			base = 10;
f01058af:	b8 0a 00 00 00       	mov    $0xa,%eax
f01058b4:	e9 99 00 00 00       	jmp    f0105952 <vprintfmt+0x348>
		return va_arg(*ap, int);
f01058b9:	8b 45 14             	mov    0x14(%ebp),%eax
f01058bc:	8b 00                	mov    (%eax),%eax
f01058be:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01058c1:	99                   	cltd   
f01058c2:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01058c5:	8b 45 14             	mov    0x14(%ebp),%eax
f01058c8:	8d 40 04             	lea    0x4(%eax),%eax
f01058cb:	89 45 14             	mov    %eax,0x14(%ebp)
f01058ce:	eb b4                	jmp    f0105884 <vprintfmt+0x27a>
	if (lflag >= 2)
f01058d0:	83 f9 01             	cmp    $0x1,%ecx
f01058d3:	7f 1b                	jg     f01058f0 <vprintfmt+0x2e6>
	else if (lflag)
f01058d5:	85 c9                	test   %ecx,%ecx
f01058d7:	74 2c                	je     f0105905 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
f01058d9:	8b 45 14             	mov    0x14(%ebp),%eax
f01058dc:	8b 10                	mov    (%eax),%edx
f01058de:	b9 00 00 00 00       	mov    $0x0,%ecx
f01058e3:	8d 40 04             	lea    0x4(%eax),%eax
f01058e6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01058e9:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
f01058ee:	eb 62                	jmp    f0105952 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
f01058f0:	8b 45 14             	mov    0x14(%ebp),%eax
f01058f3:	8b 10                	mov    (%eax),%edx
f01058f5:	8b 48 04             	mov    0x4(%eax),%ecx
f01058f8:	8d 40 08             	lea    0x8(%eax),%eax
f01058fb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01058fe:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
f0105903:	eb 4d                	jmp    f0105952 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
f0105905:	8b 45 14             	mov    0x14(%ebp),%eax
f0105908:	8b 10                	mov    (%eax),%edx
f010590a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010590f:	8d 40 04             	lea    0x4(%eax),%eax
f0105912:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105915:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
f010591a:	eb 36                	jmp    f0105952 <vprintfmt+0x348>
	if (lflag >= 2)
f010591c:	83 f9 01             	cmp    $0x1,%ecx
f010591f:	7f 17                	jg     f0105938 <vprintfmt+0x32e>
	else if (lflag)
f0105921:	85 c9                	test   %ecx,%ecx
f0105923:	74 6e                	je     f0105993 <vprintfmt+0x389>
		return va_arg(*ap, long);
f0105925:	8b 45 14             	mov    0x14(%ebp),%eax
f0105928:	8b 10                	mov    (%eax),%edx
f010592a:	89 d0                	mov    %edx,%eax
f010592c:	99                   	cltd   
f010592d:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0105930:	8d 49 04             	lea    0x4(%ecx),%ecx
f0105933:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105936:	eb 11                	jmp    f0105949 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
f0105938:	8b 45 14             	mov    0x14(%ebp),%eax
f010593b:	8b 50 04             	mov    0x4(%eax),%edx
f010593e:	8b 00                	mov    (%eax),%eax
f0105940:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0105943:	8d 49 08             	lea    0x8(%ecx),%ecx
f0105946:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
f0105949:	89 d1                	mov    %edx,%ecx
f010594b:	89 c2                	mov    %eax,%edx
            base = 8;
f010594d:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
f0105952:	83 ec 0c             	sub    $0xc,%esp
f0105955:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
f0105959:	57                   	push   %edi
f010595a:	ff 75 e0             	pushl  -0x20(%ebp)
f010595d:	50                   	push   %eax
f010595e:	51                   	push   %ecx
f010595f:	52                   	push   %edx
f0105960:	89 da                	mov    %ebx,%edx
f0105962:	89 f0                	mov    %esi,%eax
f0105964:	e8 b6 fb ff ff       	call   f010551f <printnum>
			break;
f0105969:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f010596c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010596f:	83 c7 01             	add    $0x1,%edi
f0105972:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105976:	83 f8 25             	cmp    $0x25,%eax
f0105979:	0f 84 a6 fc ff ff    	je     f0105625 <vprintfmt+0x1b>
			if (ch == '\0')
f010597f:	85 c0                	test   %eax,%eax
f0105981:	0f 84 ce 00 00 00    	je     f0105a55 <vprintfmt+0x44b>
			putch(ch, putdat);
f0105987:	83 ec 08             	sub    $0x8,%esp
f010598a:	53                   	push   %ebx
f010598b:	50                   	push   %eax
f010598c:	ff d6                	call   *%esi
f010598e:	83 c4 10             	add    $0x10,%esp
f0105991:	eb dc                	jmp    f010596f <vprintfmt+0x365>
		return va_arg(*ap, int);
f0105993:	8b 45 14             	mov    0x14(%ebp),%eax
f0105996:	8b 10                	mov    (%eax),%edx
f0105998:	89 d0                	mov    %edx,%eax
f010599a:	99                   	cltd   
f010599b:	8b 4d 14             	mov    0x14(%ebp),%ecx
f010599e:	8d 49 04             	lea    0x4(%ecx),%ecx
f01059a1:	89 4d 14             	mov    %ecx,0x14(%ebp)
f01059a4:	eb a3                	jmp    f0105949 <vprintfmt+0x33f>
			putch('0', putdat);
f01059a6:	83 ec 08             	sub    $0x8,%esp
f01059a9:	53                   	push   %ebx
f01059aa:	6a 30                	push   $0x30
f01059ac:	ff d6                	call   *%esi
			putch('x', putdat);
f01059ae:	83 c4 08             	add    $0x8,%esp
f01059b1:	53                   	push   %ebx
f01059b2:	6a 78                	push   $0x78
f01059b4:	ff d6                	call   *%esi
			num = (unsigned long long)
f01059b6:	8b 45 14             	mov    0x14(%ebp),%eax
f01059b9:	8b 10                	mov    (%eax),%edx
f01059bb:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f01059c0:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f01059c3:	8d 40 04             	lea    0x4(%eax),%eax
f01059c6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01059c9:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f01059ce:	eb 82                	jmp    f0105952 <vprintfmt+0x348>
	if (lflag >= 2)
f01059d0:	83 f9 01             	cmp    $0x1,%ecx
f01059d3:	7f 1e                	jg     f01059f3 <vprintfmt+0x3e9>
	else if (lflag)
f01059d5:	85 c9                	test   %ecx,%ecx
f01059d7:	74 32                	je     f0105a0b <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
f01059d9:	8b 45 14             	mov    0x14(%ebp),%eax
f01059dc:	8b 10                	mov    (%eax),%edx
f01059de:	b9 00 00 00 00       	mov    $0x0,%ecx
f01059e3:	8d 40 04             	lea    0x4(%eax),%eax
f01059e6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01059e9:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
f01059ee:	e9 5f ff ff ff       	jmp    f0105952 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
f01059f3:	8b 45 14             	mov    0x14(%ebp),%eax
f01059f6:	8b 10                	mov    (%eax),%edx
f01059f8:	8b 48 04             	mov    0x4(%eax),%ecx
f01059fb:	8d 40 08             	lea    0x8(%eax),%eax
f01059fe:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105a01:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
f0105a06:	e9 47 ff ff ff       	jmp    f0105952 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
f0105a0b:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a0e:	8b 10                	mov    (%eax),%edx
f0105a10:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105a15:	8d 40 04             	lea    0x4(%eax),%eax
f0105a18:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105a1b:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
f0105a20:	e9 2d ff ff ff       	jmp    f0105952 <vprintfmt+0x348>
			putch(ch, putdat);
f0105a25:	83 ec 08             	sub    $0x8,%esp
f0105a28:	53                   	push   %ebx
f0105a29:	6a 25                	push   $0x25
f0105a2b:	ff d6                	call   *%esi
			break;
f0105a2d:	83 c4 10             	add    $0x10,%esp
f0105a30:	e9 37 ff ff ff       	jmp    f010596c <vprintfmt+0x362>
			putch('%', putdat);
f0105a35:	83 ec 08             	sub    $0x8,%esp
f0105a38:	53                   	push   %ebx
f0105a39:	6a 25                	push   $0x25
f0105a3b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105a3d:	83 c4 10             	add    $0x10,%esp
f0105a40:	89 f8                	mov    %edi,%eax
f0105a42:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0105a46:	74 05                	je     f0105a4d <vprintfmt+0x443>
f0105a48:	83 e8 01             	sub    $0x1,%eax
f0105a4b:	eb f5                	jmp    f0105a42 <vprintfmt+0x438>
f0105a4d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105a50:	e9 17 ff ff ff       	jmp    f010596c <vprintfmt+0x362>
}
f0105a55:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105a58:	5b                   	pop    %ebx
f0105a59:	5e                   	pop    %esi
f0105a5a:	5f                   	pop    %edi
f0105a5b:	5d                   	pop    %ebp
f0105a5c:	c3                   	ret    

f0105a5d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105a5d:	f3 0f 1e fb          	endbr32 
f0105a61:	55                   	push   %ebp
f0105a62:	89 e5                	mov    %esp,%ebp
f0105a64:	83 ec 18             	sub    $0x18,%esp
f0105a67:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a6a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105a6d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105a70:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105a74:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105a77:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105a7e:	85 c0                	test   %eax,%eax
f0105a80:	74 26                	je     f0105aa8 <vsnprintf+0x4b>
f0105a82:	85 d2                	test   %edx,%edx
f0105a84:	7e 22                	jle    f0105aa8 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105a86:	ff 75 14             	pushl  0x14(%ebp)
f0105a89:	ff 75 10             	pushl  0x10(%ebp)
f0105a8c:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105a8f:	50                   	push   %eax
f0105a90:	68 c8 55 10 f0       	push   $0xf01055c8
f0105a95:	e8 70 fb ff ff       	call   f010560a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105a9a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105a9d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105aa3:	83 c4 10             	add    $0x10,%esp
}
f0105aa6:	c9                   	leave  
f0105aa7:	c3                   	ret    
		return -E_INVAL;
f0105aa8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105aad:	eb f7                	jmp    f0105aa6 <vsnprintf+0x49>

f0105aaf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105aaf:	f3 0f 1e fb          	endbr32 
f0105ab3:	55                   	push   %ebp
f0105ab4:	89 e5                	mov    %esp,%ebp
f0105ab6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105ab9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105abc:	50                   	push   %eax
f0105abd:	ff 75 10             	pushl  0x10(%ebp)
f0105ac0:	ff 75 0c             	pushl  0xc(%ebp)
f0105ac3:	ff 75 08             	pushl  0x8(%ebp)
f0105ac6:	e8 92 ff ff ff       	call   f0105a5d <vsnprintf>
	va_end(ap);

	return rc;
}
f0105acb:	c9                   	leave  
f0105acc:	c3                   	ret    

f0105acd <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105acd:	f3 0f 1e fb          	endbr32 
f0105ad1:	55                   	push   %ebp
f0105ad2:	89 e5                	mov    %esp,%ebp
f0105ad4:	57                   	push   %edi
f0105ad5:	56                   	push   %esi
f0105ad6:	53                   	push   %ebx
f0105ad7:	83 ec 0c             	sub    $0xc,%esp
f0105ada:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105add:	85 c0                	test   %eax,%eax
f0105adf:	74 11                	je     f0105af2 <readline+0x25>
		cprintf("%s", prompt);
f0105ae1:	83 ec 08             	sub    $0x8,%esp
f0105ae4:	50                   	push   %eax
f0105ae5:	68 2b 79 10 f0       	push   $0xf010792b
f0105aea:	e8 3e e0 ff ff       	call   f0103b2d <cprintf>
f0105aef:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105af2:	83 ec 0c             	sub    $0xc,%esp
f0105af5:	6a 00                	push   $0x0
f0105af7:	e8 d6 ac ff ff       	call   f01007d2 <iscons>
f0105afc:	89 c7                	mov    %eax,%edi
f0105afe:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0105b01:	be 00 00 00 00       	mov    $0x0,%esi
f0105b06:	eb 57                	jmp    f0105b5f <readline+0x92>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f0105b08:	b8 00 00 00 00       	mov    $0x0,%eax
			if (c != -E_EOF)
f0105b0d:	83 fb f8             	cmp    $0xfffffff8,%ebx
f0105b10:	75 08                	jne    f0105b1a <readline+0x4d>
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0105b12:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105b15:	5b                   	pop    %ebx
f0105b16:	5e                   	pop    %esi
f0105b17:	5f                   	pop    %edi
f0105b18:	5d                   	pop    %ebp
f0105b19:	c3                   	ret    
				cprintf("read error: %e\n", c);
f0105b1a:	83 ec 08             	sub    $0x8,%esp
f0105b1d:	53                   	push   %ebx
f0105b1e:	68 5f 85 10 f0       	push   $0xf010855f
f0105b23:	e8 05 e0 ff ff       	call   f0103b2d <cprintf>
f0105b28:	83 c4 10             	add    $0x10,%esp
			return NULL;
f0105b2b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b30:	eb e0                	jmp    f0105b12 <readline+0x45>
			if (echoing)
f0105b32:	85 ff                	test   %edi,%edi
f0105b34:	75 05                	jne    f0105b3b <readline+0x6e>
			i--;
f0105b36:	83 ee 01             	sub    $0x1,%esi
f0105b39:	eb 24                	jmp    f0105b5f <readline+0x92>
				cputchar('\b');
f0105b3b:	83 ec 0c             	sub    $0xc,%esp
f0105b3e:	6a 08                	push   $0x8
f0105b40:	e8 64 ac ff ff       	call   f01007a9 <cputchar>
f0105b45:	83 c4 10             	add    $0x10,%esp
f0105b48:	eb ec                	jmp    f0105b36 <readline+0x69>
				cputchar(c);
f0105b4a:	83 ec 0c             	sub    $0xc,%esp
f0105b4d:	53                   	push   %ebx
f0105b4e:	e8 56 ac ff ff       	call   f01007a9 <cputchar>
f0105b53:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105b56:	88 9e 80 ba 3b f0    	mov    %bl,-0xfc44580(%esi)
f0105b5c:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f0105b5f:	e8 59 ac ff ff       	call   f01007bd <getchar>
f0105b64:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105b66:	85 c0                	test   %eax,%eax
f0105b68:	78 9e                	js     f0105b08 <readline+0x3b>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105b6a:	83 f8 08             	cmp    $0x8,%eax
f0105b6d:	0f 94 c2             	sete   %dl
f0105b70:	83 f8 7f             	cmp    $0x7f,%eax
f0105b73:	0f 94 c0             	sete   %al
f0105b76:	08 c2                	or     %al,%dl
f0105b78:	74 04                	je     f0105b7e <readline+0xb1>
f0105b7a:	85 f6                	test   %esi,%esi
f0105b7c:	7f b4                	jg     f0105b32 <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105b7e:	83 fb 1f             	cmp    $0x1f,%ebx
f0105b81:	7e 0e                	jle    f0105b91 <readline+0xc4>
f0105b83:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105b89:	7f 06                	jg     f0105b91 <readline+0xc4>
			if (echoing)
f0105b8b:	85 ff                	test   %edi,%edi
f0105b8d:	74 c7                	je     f0105b56 <readline+0x89>
f0105b8f:	eb b9                	jmp    f0105b4a <readline+0x7d>
		} else if (c == '\n' || c == '\r') {
f0105b91:	83 fb 0a             	cmp    $0xa,%ebx
f0105b94:	74 05                	je     f0105b9b <readline+0xce>
f0105b96:	83 fb 0d             	cmp    $0xd,%ebx
f0105b99:	75 c4                	jne    f0105b5f <readline+0x92>
			if (echoing)
f0105b9b:	85 ff                	test   %edi,%edi
f0105b9d:	75 11                	jne    f0105bb0 <readline+0xe3>
			buf[i] = 0;
f0105b9f:	c6 86 80 ba 3b f0 00 	movb   $0x0,-0xfc44580(%esi)
			return buf;
f0105ba6:	b8 80 ba 3b f0       	mov    $0xf03bba80,%eax
f0105bab:	e9 62 ff ff ff       	jmp    f0105b12 <readline+0x45>
				cputchar('\n');
f0105bb0:	83 ec 0c             	sub    $0xc,%esp
f0105bb3:	6a 0a                	push   $0xa
f0105bb5:	e8 ef ab ff ff       	call   f01007a9 <cputchar>
f0105bba:	83 c4 10             	add    $0x10,%esp
f0105bbd:	eb e0                	jmp    f0105b9f <readline+0xd2>

f0105bbf <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105bbf:	f3 0f 1e fb          	endbr32 
f0105bc3:	55                   	push   %ebp
f0105bc4:	89 e5                	mov    %esp,%ebp
f0105bc6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105bc9:	b8 00 00 00 00       	mov    $0x0,%eax
f0105bce:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105bd2:	74 05                	je     f0105bd9 <strlen+0x1a>
		n++;
f0105bd4:	83 c0 01             	add    $0x1,%eax
f0105bd7:	eb f5                	jmp    f0105bce <strlen+0xf>
	return n;
}
f0105bd9:	5d                   	pop    %ebp
f0105bda:	c3                   	ret    

f0105bdb <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105bdb:	f3 0f 1e fb          	endbr32 
f0105bdf:	55                   	push   %ebp
f0105be0:	89 e5                	mov    %esp,%ebp
f0105be2:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105be5:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105be8:	b8 00 00 00 00       	mov    $0x0,%eax
f0105bed:	39 d0                	cmp    %edx,%eax
f0105bef:	74 0d                	je     f0105bfe <strnlen+0x23>
f0105bf1:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0105bf5:	74 05                	je     f0105bfc <strnlen+0x21>
		n++;
f0105bf7:	83 c0 01             	add    $0x1,%eax
f0105bfa:	eb f1                	jmp    f0105bed <strnlen+0x12>
f0105bfc:	89 c2                	mov    %eax,%edx
	return n;
}
f0105bfe:	89 d0                	mov    %edx,%eax
f0105c00:	5d                   	pop    %ebp
f0105c01:	c3                   	ret    

f0105c02 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105c02:	f3 0f 1e fb          	endbr32 
f0105c06:	55                   	push   %ebp
f0105c07:	89 e5                	mov    %esp,%ebp
f0105c09:	53                   	push   %ebx
f0105c0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105c0d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105c10:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c15:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f0105c19:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f0105c1c:	83 c0 01             	add    $0x1,%eax
f0105c1f:	84 d2                	test   %dl,%dl
f0105c21:	75 f2                	jne    f0105c15 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
f0105c23:	89 c8                	mov    %ecx,%eax
f0105c25:	5b                   	pop    %ebx
f0105c26:	5d                   	pop    %ebp
f0105c27:	c3                   	ret    

f0105c28 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105c28:	f3 0f 1e fb          	endbr32 
f0105c2c:	55                   	push   %ebp
f0105c2d:	89 e5                	mov    %esp,%ebp
f0105c2f:	53                   	push   %ebx
f0105c30:	83 ec 10             	sub    $0x10,%esp
f0105c33:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105c36:	53                   	push   %ebx
f0105c37:	e8 83 ff ff ff       	call   f0105bbf <strlen>
f0105c3c:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0105c3f:	ff 75 0c             	pushl  0xc(%ebp)
f0105c42:	01 d8                	add    %ebx,%eax
f0105c44:	50                   	push   %eax
f0105c45:	e8 b8 ff ff ff       	call   f0105c02 <strcpy>
	return dst;
}
f0105c4a:	89 d8                	mov    %ebx,%eax
f0105c4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105c4f:	c9                   	leave  
f0105c50:	c3                   	ret    

f0105c51 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105c51:	f3 0f 1e fb          	endbr32 
f0105c55:	55                   	push   %ebp
f0105c56:	89 e5                	mov    %esp,%ebp
f0105c58:	56                   	push   %esi
f0105c59:	53                   	push   %ebx
f0105c5a:	8b 75 08             	mov    0x8(%ebp),%esi
f0105c5d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105c60:	89 f3                	mov    %esi,%ebx
f0105c62:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105c65:	89 f0                	mov    %esi,%eax
f0105c67:	39 d8                	cmp    %ebx,%eax
f0105c69:	74 11                	je     f0105c7c <strncpy+0x2b>
		*dst++ = *src;
f0105c6b:	83 c0 01             	add    $0x1,%eax
f0105c6e:	0f b6 0a             	movzbl (%edx),%ecx
f0105c71:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105c74:	80 f9 01             	cmp    $0x1,%cl
f0105c77:	83 da ff             	sbb    $0xffffffff,%edx
f0105c7a:	eb eb                	jmp    f0105c67 <strncpy+0x16>
	}
	return ret;
}
f0105c7c:	89 f0                	mov    %esi,%eax
f0105c7e:	5b                   	pop    %ebx
f0105c7f:	5e                   	pop    %esi
f0105c80:	5d                   	pop    %ebp
f0105c81:	c3                   	ret    

f0105c82 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105c82:	f3 0f 1e fb          	endbr32 
f0105c86:	55                   	push   %ebp
f0105c87:	89 e5                	mov    %esp,%ebp
f0105c89:	56                   	push   %esi
f0105c8a:	53                   	push   %ebx
f0105c8b:	8b 75 08             	mov    0x8(%ebp),%esi
f0105c8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105c91:	8b 55 10             	mov    0x10(%ebp),%edx
f0105c94:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105c96:	85 d2                	test   %edx,%edx
f0105c98:	74 21                	je     f0105cbb <strlcpy+0x39>
f0105c9a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105c9e:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f0105ca0:	39 c2                	cmp    %eax,%edx
f0105ca2:	74 14                	je     f0105cb8 <strlcpy+0x36>
f0105ca4:	0f b6 19             	movzbl (%ecx),%ebx
f0105ca7:	84 db                	test   %bl,%bl
f0105ca9:	74 0b                	je     f0105cb6 <strlcpy+0x34>
			*dst++ = *src++;
f0105cab:	83 c1 01             	add    $0x1,%ecx
f0105cae:	83 c2 01             	add    $0x1,%edx
f0105cb1:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105cb4:	eb ea                	jmp    f0105ca0 <strlcpy+0x1e>
f0105cb6:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0105cb8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105cbb:	29 f0                	sub    %esi,%eax
}
f0105cbd:	5b                   	pop    %ebx
f0105cbe:	5e                   	pop    %esi
f0105cbf:	5d                   	pop    %ebp
f0105cc0:	c3                   	ret    

f0105cc1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105cc1:	f3 0f 1e fb          	endbr32 
f0105cc5:	55                   	push   %ebp
f0105cc6:	89 e5                	mov    %esp,%ebp
f0105cc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105ccb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105cce:	0f b6 01             	movzbl (%ecx),%eax
f0105cd1:	84 c0                	test   %al,%al
f0105cd3:	74 0c                	je     f0105ce1 <strcmp+0x20>
f0105cd5:	3a 02                	cmp    (%edx),%al
f0105cd7:	75 08                	jne    f0105ce1 <strcmp+0x20>
		p++, q++;
f0105cd9:	83 c1 01             	add    $0x1,%ecx
f0105cdc:	83 c2 01             	add    $0x1,%edx
f0105cdf:	eb ed                	jmp    f0105cce <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105ce1:	0f b6 c0             	movzbl %al,%eax
f0105ce4:	0f b6 12             	movzbl (%edx),%edx
f0105ce7:	29 d0                	sub    %edx,%eax
}
f0105ce9:	5d                   	pop    %ebp
f0105cea:	c3                   	ret    

f0105ceb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105ceb:	f3 0f 1e fb          	endbr32 
f0105cef:	55                   	push   %ebp
f0105cf0:	89 e5                	mov    %esp,%ebp
f0105cf2:	53                   	push   %ebx
f0105cf3:	8b 45 08             	mov    0x8(%ebp),%eax
f0105cf6:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105cf9:	89 c3                	mov    %eax,%ebx
f0105cfb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105cfe:	eb 06                	jmp    f0105d06 <strncmp+0x1b>
		n--, p++, q++;
f0105d00:	83 c0 01             	add    $0x1,%eax
f0105d03:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0105d06:	39 d8                	cmp    %ebx,%eax
f0105d08:	74 16                	je     f0105d20 <strncmp+0x35>
f0105d0a:	0f b6 08             	movzbl (%eax),%ecx
f0105d0d:	84 c9                	test   %cl,%cl
f0105d0f:	74 04                	je     f0105d15 <strncmp+0x2a>
f0105d11:	3a 0a                	cmp    (%edx),%cl
f0105d13:	74 eb                	je     f0105d00 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105d15:	0f b6 00             	movzbl (%eax),%eax
f0105d18:	0f b6 12             	movzbl (%edx),%edx
f0105d1b:	29 d0                	sub    %edx,%eax
}
f0105d1d:	5b                   	pop    %ebx
f0105d1e:	5d                   	pop    %ebp
f0105d1f:	c3                   	ret    
		return 0;
f0105d20:	b8 00 00 00 00       	mov    $0x0,%eax
f0105d25:	eb f6                	jmp    f0105d1d <strncmp+0x32>

f0105d27 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105d27:	f3 0f 1e fb          	endbr32 
f0105d2b:	55                   	push   %ebp
f0105d2c:	89 e5                	mov    %esp,%ebp
f0105d2e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d31:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105d35:	0f b6 10             	movzbl (%eax),%edx
f0105d38:	84 d2                	test   %dl,%dl
f0105d3a:	74 09                	je     f0105d45 <strchr+0x1e>
		if (*s == c)
f0105d3c:	38 ca                	cmp    %cl,%dl
f0105d3e:	74 0a                	je     f0105d4a <strchr+0x23>
	for (; *s; s++)
f0105d40:	83 c0 01             	add    $0x1,%eax
f0105d43:	eb f0                	jmp    f0105d35 <strchr+0xe>
			return (char *) s;
	return 0;
f0105d45:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105d4a:	5d                   	pop    %ebp
f0105d4b:	c3                   	ret    

f0105d4c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105d4c:	f3 0f 1e fb          	endbr32 
f0105d50:	55                   	push   %ebp
f0105d51:	89 e5                	mov    %esp,%ebp
f0105d53:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d56:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105d5a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105d5d:	38 ca                	cmp    %cl,%dl
f0105d5f:	74 09                	je     f0105d6a <strfind+0x1e>
f0105d61:	84 d2                	test   %dl,%dl
f0105d63:	74 05                	je     f0105d6a <strfind+0x1e>
	for (; *s; s++)
f0105d65:	83 c0 01             	add    $0x1,%eax
f0105d68:	eb f0                	jmp    f0105d5a <strfind+0xe>
			break;
	return (char *) s;
}
f0105d6a:	5d                   	pop    %ebp
f0105d6b:	c3                   	ret    

f0105d6c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105d6c:	f3 0f 1e fb          	endbr32 
f0105d70:	55                   	push   %ebp
f0105d71:	89 e5                	mov    %esp,%ebp
f0105d73:	57                   	push   %edi
f0105d74:	56                   	push   %esi
f0105d75:	53                   	push   %ebx
f0105d76:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105d79:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105d7c:	85 c9                	test   %ecx,%ecx
f0105d7e:	74 31                	je     f0105db1 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105d80:	89 f8                	mov    %edi,%eax
f0105d82:	09 c8                	or     %ecx,%eax
f0105d84:	a8 03                	test   $0x3,%al
f0105d86:	75 23                	jne    f0105dab <memset+0x3f>
		c &= 0xFF;
f0105d88:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105d8c:	89 d3                	mov    %edx,%ebx
f0105d8e:	c1 e3 08             	shl    $0x8,%ebx
f0105d91:	89 d0                	mov    %edx,%eax
f0105d93:	c1 e0 18             	shl    $0x18,%eax
f0105d96:	89 d6                	mov    %edx,%esi
f0105d98:	c1 e6 10             	shl    $0x10,%esi
f0105d9b:	09 f0                	or     %esi,%eax
f0105d9d:	09 c2                	or     %eax,%edx
f0105d9f:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105da1:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0105da4:	89 d0                	mov    %edx,%eax
f0105da6:	fc                   	cld    
f0105da7:	f3 ab                	rep stos %eax,%es:(%edi)
f0105da9:	eb 06                	jmp    f0105db1 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105dab:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105dae:	fc                   	cld    
f0105daf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105db1:	89 f8                	mov    %edi,%eax
f0105db3:	5b                   	pop    %ebx
f0105db4:	5e                   	pop    %esi
f0105db5:	5f                   	pop    %edi
f0105db6:	5d                   	pop    %ebp
f0105db7:	c3                   	ret    

f0105db8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105db8:	f3 0f 1e fb          	endbr32 
f0105dbc:	55                   	push   %ebp
f0105dbd:	89 e5                	mov    %esp,%ebp
f0105dbf:	57                   	push   %edi
f0105dc0:	56                   	push   %esi
f0105dc1:	8b 45 08             	mov    0x8(%ebp),%eax
f0105dc4:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105dc7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105dca:	39 c6                	cmp    %eax,%esi
f0105dcc:	73 32                	jae    f0105e00 <memmove+0x48>
f0105dce:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105dd1:	39 c2                	cmp    %eax,%edx
f0105dd3:	76 2b                	jbe    f0105e00 <memmove+0x48>
		s += n;
		d += n;
f0105dd5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105dd8:	89 fe                	mov    %edi,%esi
f0105dda:	09 ce                	or     %ecx,%esi
f0105ddc:	09 d6                	or     %edx,%esi
f0105dde:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105de4:	75 0e                	jne    f0105df4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105de6:	83 ef 04             	sub    $0x4,%edi
f0105de9:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105dec:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0105def:	fd                   	std    
f0105df0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105df2:	eb 09                	jmp    f0105dfd <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105df4:	83 ef 01             	sub    $0x1,%edi
f0105df7:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0105dfa:	fd                   	std    
f0105dfb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105dfd:	fc                   	cld    
f0105dfe:	eb 1a                	jmp    f0105e1a <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105e00:	89 c2                	mov    %eax,%edx
f0105e02:	09 ca                	or     %ecx,%edx
f0105e04:	09 f2                	or     %esi,%edx
f0105e06:	f6 c2 03             	test   $0x3,%dl
f0105e09:	75 0a                	jne    f0105e15 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105e0b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0105e0e:	89 c7                	mov    %eax,%edi
f0105e10:	fc                   	cld    
f0105e11:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105e13:	eb 05                	jmp    f0105e1a <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
f0105e15:	89 c7                	mov    %eax,%edi
f0105e17:	fc                   	cld    
f0105e18:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105e1a:	5e                   	pop    %esi
f0105e1b:	5f                   	pop    %edi
f0105e1c:	5d                   	pop    %ebp
f0105e1d:	c3                   	ret    

f0105e1e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105e1e:	f3 0f 1e fb          	endbr32 
f0105e22:	55                   	push   %ebp
f0105e23:	89 e5                	mov    %esp,%ebp
f0105e25:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105e28:	ff 75 10             	pushl  0x10(%ebp)
f0105e2b:	ff 75 0c             	pushl  0xc(%ebp)
f0105e2e:	ff 75 08             	pushl  0x8(%ebp)
f0105e31:	e8 82 ff ff ff       	call   f0105db8 <memmove>
}
f0105e36:	c9                   	leave  
f0105e37:	c3                   	ret    

f0105e38 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105e38:	f3 0f 1e fb          	endbr32 
f0105e3c:	55                   	push   %ebp
f0105e3d:	89 e5                	mov    %esp,%ebp
f0105e3f:	56                   	push   %esi
f0105e40:	53                   	push   %ebx
f0105e41:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e44:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105e47:	89 c6                	mov    %eax,%esi
f0105e49:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105e4c:	39 f0                	cmp    %esi,%eax
f0105e4e:	74 1c                	je     f0105e6c <memcmp+0x34>
		if (*s1 != *s2)
f0105e50:	0f b6 08             	movzbl (%eax),%ecx
f0105e53:	0f b6 1a             	movzbl (%edx),%ebx
f0105e56:	38 d9                	cmp    %bl,%cl
f0105e58:	75 08                	jne    f0105e62 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0105e5a:	83 c0 01             	add    $0x1,%eax
f0105e5d:	83 c2 01             	add    $0x1,%edx
f0105e60:	eb ea                	jmp    f0105e4c <memcmp+0x14>
			return (int) *s1 - (int) *s2;
f0105e62:	0f b6 c1             	movzbl %cl,%eax
f0105e65:	0f b6 db             	movzbl %bl,%ebx
f0105e68:	29 d8                	sub    %ebx,%eax
f0105e6a:	eb 05                	jmp    f0105e71 <memcmp+0x39>
	}

	return 0;
f0105e6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105e71:	5b                   	pop    %ebx
f0105e72:	5e                   	pop    %esi
f0105e73:	5d                   	pop    %ebp
f0105e74:	c3                   	ret    

f0105e75 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105e75:	f3 0f 1e fb          	endbr32 
f0105e79:	55                   	push   %ebp
f0105e7a:	89 e5                	mov    %esp,%ebp
f0105e7c:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105e82:	89 c2                	mov    %eax,%edx
f0105e84:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105e87:	39 d0                	cmp    %edx,%eax
f0105e89:	73 09                	jae    f0105e94 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105e8b:	38 08                	cmp    %cl,(%eax)
f0105e8d:	74 05                	je     f0105e94 <memfind+0x1f>
	for (; s < ends; s++)
f0105e8f:	83 c0 01             	add    $0x1,%eax
f0105e92:	eb f3                	jmp    f0105e87 <memfind+0x12>
			break;
	return (void *) s;
}
f0105e94:	5d                   	pop    %ebp
f0105e95:	c3                   	ret    

f0105e96 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105e96:	f3 0f 1e fb          	endbr32 
f0105e9a:	55                   	push   %ebp
f0105e9b:	89 e5                	mov    %esp,%ebp
f0105e9d:	57                   	push   %edi
f0105e9e:	56                   	push   %esi
f0105e9f:	53                   	push   %ebx
f0105ea0:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105ea3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105ea6:	eb 03                	jmp    f0105eab <strtol+0x15>
		s++;
f0105ea8:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0105eab:	0f b6 01             	movzbl (%ecx),%eax
f0105eae:	3c 20                	cmp    $0x20,%al
f0105eb0:	74 f6                	je     f0105ea8 <strtol+0x12>
f0105eb2:	3c 09                	cmp    $0x9,%al
f0105eb4:	74 f2                	je     f0105ea8 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
f0105eb6:	3c 2b                	cmp    $0x2b,%al
f0105eb8:	74 2a                	je     f0105ee4 <strtol+0x4e>
	int neg = 0;
f0105eba:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0105ebf:	3c 2d                	cmp    $0x2d,%al
f0105ec1:	74 2b                	je     f0105eee <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105ec3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105ec9:	75 0f                	jne    f0105eda <strtol+0x44>
f0105ecb:	80 39 30             	cmpb   $0x30,(%ecx)
f0105ece:	74 28                	je     f0105ef8 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105ed0:	85 db                	test   %ebx,%ebx
f0105ed2:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105ed7:	0f 44 d8             	cmove  %eax,%ebx
f0105eda:	b8 00 00 00 00       	mov    $0x0,%eax
f0105edf:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105ee2:	eb 46                	jmp    f0105f2a <strtol+0x94>
		s++;
f0105ee4:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0105ee7:	bf 00 00 00 00       	mov    $0x0,%edi
f0105eec:	eb d5                	jmp    f0105ec3 <strtol+0x2d>
		s++, neg = 1;
f0105eee:	83 c1 01             	add    $0x1,%ecx
f0105ef1:	bf 01 00 00 00       	mov    $0x1,%edi
f0105ef6:	eb cb                	jmp    f0105ec3 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105ef8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105efc:	74 0e                	je     f0105f0c <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0105efe:	85 db                	test   %ebx,%ebx
f0105f00:	75 d8                	jne    f0105eda <strtol+0x44>
		s++, base = 8;
f0105f02:	83 c1 01             	add    $0x1,%ecx
f0105f05:	bb 08 00 00 00       	mov    $0x8,%ebx
f0105f0a:	eb ce                	jmp    f0105eda <strtol+0x44>
		s += 2, base = 16;
f0105f0c:	83 c1 02             	add    $0x2,%ecx
f0105f0f:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105f14:	eb c4                	jmp    f0105eda <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f0105f16:	0f be d2             	movsbl %dl,%edx
f0105f19:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105f1c:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105f1f:	7d 3a                	jge    f0105f5b <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f0105f21:	83 c1 01             	add    $0x1,%ecx
f0105f24:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105f28:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0105f2a:	0f b6 11             	movzbl (%ecx),%edx
f0105f2d:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105f30:	89 f3                	mov    %esi,%ebx
f0105f32:	80 fb 09             	cmp    $0x9,%bl
f0105f35:	76 df                	jbe    f0105f16 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
f0105f37:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105f3a:	89 f3                	mov    %esi,%ebx
f0105f3c:	80 fb 19             	cmp    $0x19,%bl
f0105f3f:	77 08                	ja     f0105f49 <strtol+0xb3>
			dig = *s - 'a' + 10;
f0105f41:	0f be d2             	movsbl %dl,%edx
f0105f44:	83 ea 57             	sub    $0x57,%edx
f0105f47:	eb d3                	jmp    f0105f1c <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
f0105f49:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105f4c:	89 f3                	mov    %esi,%ebx
f0105f4e:	80 fb 19             	cmp    $0x19,%bl
f0105f51:	77 08                	ja     f0105f5b <strtol+0xc5>
			dig = *s - 'A' + 10;
f0105f53:	0f be d2             	movsbl %dl,%edx
f0105f56:	83 ea 37             	sub    $0x37,%edx
f0105f59:	eb c1                	jmp    f0105f1c <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
f0105f5b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105f5f:	74 05                	je     f0105f66 <strtol+0xd0>
		*endptr = (char *) s;
f0105f61:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105f64:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0105f66:	89 c2                	mov    %eax,%edx
f0105f68:	f7 da                	neg    %edx
f0105f6a:	85 ff                	test   %edi,%edi
f0105f6c:	0f 45 c2             	cmovne %edx,%eax
}
f0105f6f:	5b                   	pop    %ebx
f0105f70:	5e                   	pop    %esi
f0105f71:	5f                   	pop    %edi
f0105f72:	5d                   	pop    %ebp
f0105f73:	c3                   	ret    

f0105f74 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105f74:	fa                   	cli    

	xorw    %ax, %ax
f0105f75:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105f77:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105f79:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105f7b:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105f7d:	0f 01 16             	lgdtl  (%esi)
f0105f80:	74 70                	je     f0105ff2 <mpsearch1+0x3>
	movl    %cr0, %eax
f0105f82:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105f85:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105f89:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105f8c:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105f92:	08 00                	or     %al,(%eax)

f0105f94 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105f94:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105f98:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105f9a:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105f9c:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105f9e:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105fa2:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105fa4:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105fa6:	b8 00 10 12 00       	mov    $0x121000,%eax
	movl    %eax, %cr3
f0105fab:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105fae:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105fb1:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105fb6:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105fb9:	8b 25 84 be 3b f0    	mov    0xf03bbe84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105fbf:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105fc4:	b8 bd 01 10 f0       	mov    $0xf01001bd,%eax
	call    *%eax
f0105fc9:	ff d0                	call   *%eax

f0105fcb <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105fcb:	eb fe                	jmp    f0105fcb <spin>
f0105fcd:	8d 76 00             	lea    0x0(%esi),%esi

f0105fd0 <gdt>:
	...
f0105fd8:	ff                   	(bad)  
f0105fd9:	ff 00                	incl   (%eax)
f0105fdb:	00 00                	add    %al,(%eax)
f0105fdd:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105fe4:	00                   	.byte 0x0
f0105fe5:	92                   	xchg   %eax,%edx
f0105fe6:	cf                   	iret   
	...

f0105fe8 <gdtdesc>:
f0105fe8:	17                   	pop    %ss
f0105fe9:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105fee <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105fee:	90                   	nop

f0105fef <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105fef:	55                   	push   %ebp
f0105ff0:	89 e5                	mov    %esp,%ebp
f0105ff2:	57                   	push   %edi
f0105ff3:	56                   	push   %esi
f0105ff4:	53                   	push   %ebx
f0105ff5:	83 ec 0c             	sub    $0xc,%esp
f0105ff8:	89 c7                	mov    %eax,%edi
	if (PGNUM(pa) >= npages)
f0105ffa:	a1 88 be 3b f0       	mov    0xf03bbe88,%eax
f0105fff:	89 f9                	mov    %edi,%ecx
f0106001:	c1 e9 0c             	shr    $0xc,%ecx
f0106004:	39 c1                	cmp    %eax,%ecx
f0106006:	73 19                	jae    f0106021 <mpsearch1+0x32>
	return (void *)(pa + KERNBASE);
f0106008:	8d 9f 00 00 00 f0    	lea    -0x10000000(%edi),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f010600e:	01 d7                	add    %edx,%edi
	if (PGNUM(pa) >= npages)
f0106010:	89 fa                	mov    %edi,%edx
f0106012:	c1 ea 0c             	shr    $0xc,%edx
f0106015:	39 c2                	cmp    %eax,%edx
f0106017:	73 1a                	jae    f0106033 <mpsearch1+0x44>
	return (void *)(pa + KERNBASE);
f0106019:	81 ef 00 00 00 10    	sub    $0x10000000,%edi

	for (; mp < end; mp++)
f010601f:	eb 27                	jmp    f0106048 <mpsearch1+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106021:	57                   	push   %edi
f0106022:	68 24 6a 10 f0       	push   $0xf0106a24
f0106027:	6a 57                	push   $0x57
f0106029:	68 fd 86 10 f0       	push   $0xf01086fd
f010602e:	e8 0d a0 ff ff       	call   f0100040 <_panic>
f0106033:	57                   	push   %edi
f0106034:	68 24 6a 10 f0       	push   $0xf0106a24
f0106039:	6a 57                	push   $0x57
f010603b:	68 fd 86 10 f0       	push   $0xf01086fd
f0106040:	e8 fb 9f ff ff       	call   f0100040 <_panic>
f0106045:	83 c3 10             	add    $0x10,%ebx
f0106048:	39 fb                	cmp    %edi,%ebx
f010604a:	73 30                	jae    f010607c <mpsearch1+0x8d>
f010604c:	89 de                	mov    %ebx,%esi
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010604e:	83 ec 04             	sub    $0x4,%esp
f0106051:	6a 04                	push   $0x4
f0106053:	68 0d 87 10 f0       	push   $0xf010870d
f0106058:	53                   	push   %ebx
f0106059:	e8 da fd ff ff       	call   f0105e38 <memcmp>
f010605e:	83 c4 10             	add    $0x10,%esp
f0106061:	85 c0                	test   %eax,%eax
f0106063:	75 e0                	jne    f0106045 <mpsearch1+0x56>
f0106065:	89 da                	mov    %ebx,%edx
	for (i = 0; i < len; i++)
f0106067:	83 c6 10             	add    $0x10,%esi
		sum += ((uint8_t *)addr)[i];
f010606a:	0f b6 0a             	movzbl (%edx),%ecx
f010606d:	01 c8                	add    %ecx,%eax
f010606f:	83 c2 01             	add    $0x1,%edx
	for (i = 0; i < len; i++)
f0106072:	39 f2                	cmp    %esi,%edx
f0106074:	75 f4                	jne    f010606a <mpsearch1+0x7b>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106076:	84 c0                	test   %al,%al
f0106078:	75 cb                	jne    f0106045 <mpsearch1+0x56>
f010607a:	eb 05                	jmp    f0106081 <mpsearch1+0x92>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f010607c:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0106081:	89 d8                	mov    %ebx,%eax
f0106083:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106086:	5b                   	pop    %ebx
f0106087:	5e                   	pop    %esi
f0106088:	5f                   	pop    %edi
f0106089:	5d                   	pop    %ebp
f010608a:	c3                   	ret    

f010608b <mp_init>:
	return conf;
}

void
mp_init(void)
{
f010608b:	f3 0f 1e fb          	endbr32 
f010608f:	55                   	push   %ebp
f0106090:	89 e5                	mov    %esp,%ebp
f0106092:	57                   	push   %edi
f0106093:	56                   	push   %esi
f0106094:	53                   	push   %ebx
f0106095:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0106098:	c7 05 c0 c3 3b f0 20 	movl   $0xf03bc020,0xf03bc3c0
f010609f:	c0 3b f0 
	if (PGNUM(pa) >= npages)
f01060a2:	83 3d 88 be 3b f0 00 	cmpl   $0x0,0xf03bbe88
f01060a9:	0f 84 a3 00 00 00    	je     f0106152 <mp_init+0xc7>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f01060af:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f01060b6:	85 c0                	test   %eax,%eax
f01060b8:	0f 84 aa 00 00 00    	je     f0106168 <mp_init+0xdd>
		p <<= 4;	// Translate from segment to PA
f01060be:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f01060c1:	ba 00 04 00 00       	mov    $0x400,%edx
f01060c6:	e8 24 ff ff ff       	call   f0105fef <mpsearch1>
f01060cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01060ce:	85 c0                	test   %eax,%eax
f01060d0:	75 1a                	jne    f01060ec <mp_init+0x61>
	return mpsearch1(0xF0000, 0x10000);
f01060d2:	ba 00 00 01 00       	mov    $0x10000,%edx
f01060d7:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f01060dc:	e8 0e ff ff ff       	call   f0105fef <mpsearch1>
f01060e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((mp = mpsearch()) == 0)
f01060e4:	85 c0                	test   %eax,%eax
f01060e6:	0f 84 35 02 00 00    	je     f0106321 <mp_init+0x296>
	if (mp->physaddr == 0 || mp->type != 0) {
f01060ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01060ef:	8b 58 04             	mov    0x4(%eax),%ebx
f01060f2:	85 db                	test   %ebx,%ebx
f01060f4:	0f 84 97 00 00 00    	je     f0106191 <mp_init+0x106>
f01060fa:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f01060fe:	0f 85 8d 00 00 00    	jne    f0106191 <mp_init+0x106>
f0106104:	89 d8                	mov    %ebx,%eax
f0106106:	c1 e8 0c             	shr    $0xc,%eax
f0106109:	3b 05 88 be 3b f0    	cmp    0xf03bbe88,%eax
f010610f:	0f 83 91 00 00 00    	jae    f01061a6 <mp_init+0x11b>
	return (void *)(pa + KERNBASE);
f0106115:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
f010611b:	89 de                	mov    %ebx,%esi
	if (memcmp(conf, "PCMP", 4) != 0) {
f010611d:	83 ec 04             	sub    $0x4,%esp
f0106120:	6a 04                	push   $0x4
f0106122:	68 12 87 10 f0       	push   $0xf0108712
f0106127:	53                   	push   %ebx
f0106128:	e8 0b fd ff ff       	call   f0105e38 <memcmp>
f010612d:	83 c4 10             	add    $0x10,%esp
f0106130:	85 c0                	test   %eax,%eax
f0106132:	0f 85 83 00 00 00    	jne    f01061bb <mp_init+0x130>
f0106138:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
f010613c:	01 df                	add    %ebx,%edi
	sum = 0;
f010613e:	89 c2                	mov    %eax,%edx
	for (i = 0; i < len; i++)
f0106140:	39 fb                	cmp    %edi,%ebx
f0106142:	0f 84 88 00 00 00    	je     f01061d0 <mp_init+0x145>
		sum += ((uint8_t *)addr)[i];
f0106148:	0f b6 0b             	movzbl (%ebx),%ecx
f010614b:	01 ca                	add    %ecx,%edx
f010614d:	83 c3 01             	add    $0x1,%ebx
f0106150:	eb ee                	jmp    f0106140 <mp_init+0xb5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106152:	68 00 04 00 00       	push   $0x400
f0106157:	68 24 6a 10 f0       	push   $0xf0106a24
f010615c:	6a 6f                	push   $0x6f
f010615e:	68 fd 86 10 f0       	push   $0xf01086fd
f0106163:	e8 d8 9e ff ff       	call   f0100040 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0106168:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f010616f:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0106172:	2d 00 04 00 00       	sub    $0x400,%eax
f0106177:	ba 00 04 00 00       	mov    $0x400,%edx
f010617c:	e8 6e fe ff ff       	call   f0105fef <mpsearch1>
f0106181:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106184:	85 c0                	test   %eax,%eax
f0106186:	0f 85 60 ff ff ff    	jne    f01060ec <mp_init+0x61>
f010618c:	e9 41 ff ff ff       	jmp    f01060d2 <mp_init+0x47>
		cprintf("SMP: Default configurations not implemented\n");
f0106191:	83 ec 0c             	sub    $0xc,%esp
f0106194:	68 70 85 10 f0       	push   $0xf0108570
f0106199:	e8 8f d9 ff ff       	call   f0103b2d <cprintf>
		return NULL;
f010619e:	83 c4 10             	add    $0x10,%esp
f01061a1:	e9 7b 01 00 00       	jmp    f0106321 <mp_init+0x296>
f01061a6:	53                   	push   %ebx
f01061a7:	68 24 6a 10 f0       	push   $0xf0106a24
f01061ac:	68 90 00 00 00       	push   $0x90
f01061b1:	68 fd 86 10 f0       	push   $0xf01086fd
f01061b6:	e8 85 9e ff ff       	call   f0100040 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f01061bb:	83 ec 0c             	sub    $0xc,%esp
f01061be:	68 a0 85 10 f0       	push   $0xf01085a0
f01061c3:	e8 65 d9 ff ff       	call   f0103b2d <cprintf>
		return NULL;
f01061c8:	83 c4 10             	add    $0x10,%esp
f01061cb:	e9 51 01 00 00       	jmp    f0106321 <mp_init+0x296>
	if (sum(conf, conf->length) != 0) {
f01061d0:	84 d2                	test   %dl,%dl
f01061d2:	75 22                	jne    f01061f6 <mp_init+0x16b>
	if (conf->version != 1 && conf->version != 4) {
f01061d4:	0f b6 56 06          	movzbl 0x6(%esi),%edx
f01061d8:	80 fa 01             	cmp    $0x1,%dl
f01061db:	74 05                	je     f01061e2 <mp_init+0x157>
f01061dd:	80 fa 04             	cmp    $0x4,%dl
f01061e0:	75 29                	jne    f010620b <mp_init+0x180>
f01061e2:	0f b7 4e 28          	movzwl 0x28(%esi),%ecx
f01061e6:	01 d9                	add    %ebx,%ecx
	for (i = 0; i < len; i++)
f01061e8:	39 d9                	cmp    %ebx,%ecx
f01061ea:	74 38                	je     f0106224 <mp_init+0x199>
		sum += ((uint8_t *)addr)[i];
f01061ec:	0f b6 13             	movzbl (%ebx),%edx
f01061ef:	01 d0                	add    %edx,%eax
f01061f1:	83 c3 01             	add    $0x1,%ebx
f01061f4:	eb f2                	jmp    f01061e8 <mp_init+0x15d>
		cprintf("SMP: Bad MP configuration checksum\n");
f01061f6:	83 ec 0c             	sub    $0xc,%esp
f01061f9:	68 d4 85 10 f0       	push   $0xf01085d4
f01061fe:	e8 2a d9 ff ff       	call   f0103b2d <cprintf>
		return NULL;
f0106203:	83 c4 10             	add    $0x10,%esp
f0106206:	e9 16 01 00 00       	jmp    f0106321 <mp_init+0x296>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f010620b:	83 ec 08             	sub    $0x8,%esp
f010620e:	0f b6 d2             	movzbl %dl,%edx
f0106211:	52                   	push   %edx
f0106212:	68 f8 85 10 f0       	push   $0xf01085f8
f0106217:	e8 11 d9 ff ff       	call   f0103b2d <cprintf>
		return NULL;
f010621c:	83 c4 10             	add    $0x10,%esp
f010621f:	e9 fd 00 00 00       	jmp    f0106321 <mp_init+0x296>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0106224:	02 46 2a             	add    0x2a(%esi),%al
f0106227:	75 1c                	jne    f0106245 <mp_init+0x1ba>
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
f0106229:	c7 05 00 c0 3b f0 01 	movl   $0x1,0xf03bc000
f0106230:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0106233:	8b 46 24             	mov    0x24(%esi),%eax
f0106236:	a3 00 d0 3f f0       	mov    %eax,0xf03fd000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010623b:	8d 7e 2c             	lea    0x2c(%esi),%edi
f010623e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0106243:	eb 4d                	jmp    f0106292 <mp_init+0x207>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0106245:	83 ec 0c             	sub    $0xc,%esp
f0106248:	68 18 86 10 f0       	push   $0xf0108618
f010624d:	e8 db d8 ff ff       	call   f0103b2d <cprintf>
		return NULL;
f0106252:	83 c4 10             	add    $0x10,%esp
f0106255:	e9 c7 00 00 00       	jmp    f0106321 <mp_init+0x296>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f010625a:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f010625e:	74 11                	je     f0106271 <mp_init+0x1e6>
				bootcpu = &cpus[ncpu];
f0106260:	6b 05 c4 c3 3b f0 74 	imul   $0x74,0xf03bc3c4,%eax
f0106267:	05 20 c0 3b f0       	add    $0xf03bc020,%eax
f010626c:	a3 c0 c3 3b f0       	mov    %eax,0xf03bc3c0
			if (ncpu < NCPU) {
f0106271:	a1 c4 c3 3b f0       	mov    0xf03bc3c4,%eax
f0106276:	83 f8 07             	cmp    $0x7,%eax
f0106279:	7f 33                	jg     f01062ae <mp_init+0x223>
				cpus[ncpu].cpu_id = ncpu;
f010627b:	6b d0 74             	imul   $0x74,%eax,%edx
f010627e:	88 82 20 c0 3b f0    	mov    %al,-0xfc43fe0(%edx)
				ncpu++;
f0106284:	83 c0 01             	add    $0x1,%eax
f0106287:	a3 c4 c3 3b f0       	mov    %eax,0xf03bc3c4
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f010628c:	83 c7 14             	add    $0x14,%edi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010628f:	83 c3 01             	add    $0x1,%ebx
f0106292:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f0106296:	39 d8                	cmp    %ebx,%eax
f0106298:	76 4f                	jbe    f01062e9 <mp_init+0x25e>
		switch (*p) {
f010629a:	0f b6 07             	movzbl (%edi),%eax
f010629d:	84 c0                	test   %al,%al
f010629f:	74 b9                	je     f010625a <mp_init+0x1cf>
f01062a1:	8d 50 ff             	lea    -0x1(%eax),%edx
f01062a4:	80 fa 03             	cmp    $0x3,%dl
f01062a7:	77 1c                	ja     f01062c5 <mp_init+0x23a>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f01062a9:	83 c7 08             	add    $0x8,%edi
			continue;
f01062ac:	eb e1                	jmp    f010628f <mp_init+0x204>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f01062ae:	83 ec 08             	sub    $0x8,%esp
f01062b1:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f01062b5:	50                   	push   %eax
f01062b6:	68 48 86 10 f0       	push   $0xf0108648
f01062bb:	e8 6d d8 ff ff       	call   f0103b2d <cprintf>
f01062c0:	83 c4 10             	add    $0x10,%esp
f01062c3:	eb c7                	jmp    f010628c <mp_init+0x201>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f01062c5:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f01062c8:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f01062cb:	50                   	push   %eax
f01062cc:	68 70 86 10 f0       	push   $0xf0108670
f01062d1:	e8 57 d8 ff ff       	call   f0103b2d <cprintf>
			ismp = 0;
f01062d6:	c7 05 00 c0 3b f0 00 	movl   $0x0,0xf03bc000
f01062dd:	00 00 00 
			i = conf->entry;
f01062e0:	0f b7 5e 22          	movzwl 0x22(%esi),%ebx
f01062e4:	83 c4 10             	add    $0x10,%esp
f01062e7:	eb a6                	jmp    f010628f <mp_init+0x204>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f01062e9:	a1 c0 c3 3b f0       	mov    0xf03bc3c0,%eax
f01062ee:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f01062f5:	83 3d 00 c0 3b f0 00 	cmpl   $0x0,0xf03bc000
f01062fc:	74 2b                	je     f0106329 <mp_init+0x29e>
		ncpu = 1;
		lapicaddr = 0;
		cprintf("SMP: configuration not found, SMP disabled\n");
		return;
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01062fe:	83 ec 04             	sub    $0x4,%esp
f0106301:	ff 35 c4 c3 3b f0    	pushl  0xf03bc3c4
f0106307:	0f b6 00             	movzbl (%eax),%eax
f010630a:	50                   	push   %eax
f010630b:	68 17 87 10 f0       	push   $0xf0108717
f0106310:	e8 18 d8 ff ff       	call   f0103b2d <cprintf>

	if (mp->imcrp) {
f0106315:	83 c4 10             	add    $0x10,%esp
f0106318:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010631b:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f010631f:	75 2e                	jne    f010634f <mp_init+0x2c4>
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0106321:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106324:	5b                   	pop    %ebx
f0106325:	5e                   	pop    %esi
f0106326:	5f                   	pop    %edi
f0106327:	5d                   	pop    %ebp
f0106328:	c3                   	ret    
		ncpu = 1;
f0106329:	c7 05 c4 c3 3b f0 01 	movl   $0x1,0xf03bc3c4
f0106330:	00 00 00 
		lapicaddr = 0;
f0106333:	c7 05 00 d0 3f f0 00 	movl   $0x0,0xf03fd000
f010633a:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f010633d:	83 ec 0c             	sub    $0xc,%esp
f0106340:	68 90 86 10 f0       	push   $0xf0108690
f0106345:	e8 e3 d7 ff ff       	call   f0103b2d <cprintf>
		return;
f010634a:	83 c4 10             	add    $0x10,%esp
f010634d:	eb d2                	jmp    f0106321 <mp_init+0x296>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f010634f:	83 ec 0c             	sub    $0xc,%esp
f0106352:	68 bc 86 10 f0       	push   $0xf01086bc
f0106357:	e8 d1 d7 ff ff       	call   f0103b2d <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010635c:	b8 70 00 00 00       	mov    $0x70,%eax
f0106361:	ba 22 00 00 00       	mov    $0x22,%edx
f0106366:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0106367:	ba 23 00 00 00       	mov    $0x23,%edx
f010636c:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f010636d:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106370:	ee                   	out    %al,(%dx)
}
f0106371:	83 c4 10             	add    $0x10,%esp
f0106374:	eb ab                	jmp    f0106321 <mp_init+0x296>

f0106376 <lapicw>:
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
	lapic[index] = value;
f0106376:	8b 0d 04 d0 3f f0    	mov    0xf03fd004,%ecx
f010637c:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f010637f:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106381:	a1 04 d0 3f f0       	mov    0xf03fd004,%eax
f0106386:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106389:	c3                   	ret    

f010638a <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f010638a:	f3 0f 1e fb          	endbr32 
	if (lapic)
f010638e:	8b 15 04 d0 3f f0    	mov    0xf03fd004,%edx
		return lapic[ID] >> 24;
	return 0;
f0106394:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lapic)
f0106399:	85 d2                	test   %edx,%edx
f010639b:	74 06                	je     f01063a3 <cpunum+0x19>
		return lapic[ID] >> 24;
f010639d:	8b 42 20             	mov    0x20(%edx),%eax
f01063a0:	c1 e8 18             	shr    $0x18,%eax
}
f01063a3:	c3                   	ret    

f01063a4 <lapic_init>:
{
f01063a4:	f3 0f 1e fb          	endbr32 
	if (!lapicaddr)
f01063a8:	a1 00 d0 3f f0       	mov    0xf03fd000,%eax
f01063ad:	85 c0                	test   %eax,%eax
f01063af:	75 01                	jne    f01063b2 <lapic_init+0xe>
f01063b1:	c3                   	ret    
{
f01063b2:	55                   	push   %ebp
f01063b3:	89 e5                	mov    %esp,%ebp
f01063b5:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f01063b8:	68 00 10 00 00       	push   $0x1000
f01063bd:	50                   	push   %eax
f01063be:	e8 83 af ff ff       	call   f0101346 <mmio_map_region>
f01063c3:	a3 04 d0 3f f0       	mov    %eax,0xf03fd004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f01063c8:	ba 27 01 00 00       	mov    $0x127,%edx
f01063cd:	b8 3c 00 00 00       	mov    $0x3c,%eax
f01063d2:	e8 9f ff ff ff       	call   f0106376 <lapicw>
	lapicw(TDCR, X1);
f01063d7:	ba 0b 00 00 00       	mov    $0xb,%edx
f01063dc:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01063e1:	e8 90 ff ff ff       	call   f0106376 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01063e6:	ba 20 00 02 00       	mov    $0x20020,%edx
f01063eb:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01063f0:	e8 81 ff ff ff       	call   f0106376 <lapicw>
	lapicw(TICR, 10000000); 
f01063f5:	ba 80 96 98 00       	mov    $0x989680,%edx
f01063fa:	b8 e0 00 00 00       	mov    $0xe0,%eax
f01063ff:	e8 72 ff ff ff       	call   f0106376 <lapicw>
	if (thiscpu != bootcpu)
f0106404:	e8 81 ff ff ff       	call   f010638a <cpunum>
f0106409:	6b c0 74             	imul   $0x74,%eax,%eax
f010640c:	05 20 c0 3b f0       	add    $0xf03bc020,%eax
f0106411:	83 c4 10             	add    $0x10,%esp
f0106414:	39 05 c0 c3 3b f0    	cmp    %eax,0xf03bc3c0
f010641a:	74 0f                	je     f010642b <lapic_init+0x87>
		lapicw(LINT0, MASKED);
f010641c:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106421:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0106426:	e8 4b ff ff ff       	call   f0106376 <lapicw>
	lapicw(LINT1, MASKED);
f010642b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106430:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0106435:	e8 3c ff ff ff       	call   f0106376 <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f010643a:	a1 04 d0 3f f0       	mov    0xf03fd004,%eax
f010643f:	8b 40 30             	mov    0x30(%eax),%eax
f0106442:	c1 e8 10             	shr    $0x10,%eax
f0106445:	a8 fc                	test   $0xfc,%al
f0106447:	75 7c                	jne    f01064c5 <lapic_init+0x121>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0106449:	ba 33 00 00 00       	mov    $0x33,%edx
f010644e:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106453:	e8 1e ff ff ff       	call   f0106376 <lapicw>
	lapicw(ESR, 0);
f0106458:	ba 00 00 00 00       	mov    $0x0,%edx
f010645d:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106462:	e8 0f ff ff ff       	call   f0106376 <lapicw>
	lapicw(ESR, 0);
f0106467:	ba 00 00 00 00       	mov    $0x0,%edx
f010646c:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106471:	e8 00 ff ff ff       	call   f0106376 <lapicw>
	lapicw(EOI, 0);
f0106476:	ba 00 00 00 00       	mov    $0x0,%edx
f010647b:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106480:	e8 f1 fe ff ff       	call   f0106376 <lapicw>
	lapicw(ICRHI, 0);
f0106485:	ba 00 00 00 00       	mov    $0x0,%edx
f010648a:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010648f:	e8 e2 fe ff ff       	call   f0106376 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0106494:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106499:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010649e:	e8 d3 fe ff ff       	call   f0106376 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01064a3:	8b 15 04 d0 3f f0    	mov    0xf03fd004,%edx
f01064a9:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01064af:	f6 c4 10             	test   $0x10,%ah
f01064b2:	75 f5                	jne    f01064a9 <lapic_init+0x105>
	lapicw(TPR, 0);
f01064b4:	ba 00 00 00 00       	mov    $0x0,%edx
f01064b9:	b8 20 00 00 00       	mov    $0x20,%eax
f01064be:	e8 b3 fe ff ff       	call   f0106376 <lapicw>
}
f01064c3:	c9                   	leave  
f01064c4:	c3                   	ret    
		lapicw(PCINT, MASKED);
f01064c5:	ba 00 00 01 00       	mov    $0x10000,%edx
f01064ca:	b8 d0 00 00 00       	mov    $0xd0,%eax
f01064cf:	e8 a2 fe ff ff       	call   f0106376 <lapicw>
f01064d4:	e9 70 ff ff ff       	jmp    f0106449 <lapic_init+0xa5>

f01064d9 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f01064d9:	f3 0f 1e fb          	endbr32 
	if (lapic)
f01064dd:	83 3d 04 d0 3f f0 00 	cmpl   $0x0,0xf03fd004
f01064e4:	74 17                	je     f01064fd <lapic_eoi+0x24>
{
f01064e6:	55                   	push   %ebp
f01064e7:	89 e5                	mov    %esp,%ebp
f01064e9:	83 ec 08             	sub    $0x8,%esp
		lapicw(EOI, 0);
f01064ec:	ba 00 00 00 00       	mov    $0x0,%edx
f01064f1:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01064f6:	e8 7b fe ff ff       	call   f0106376 <lapicw>
}
f01064fb:	c9                   	leave  
f01064fc:	c3                   	ret    
f01064fd:	c3                   	ret    

f01064fe <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01064fe:	f3 0f 1e fb          	endbr32 
f0106502:	55                   	push   %ebp
f0106503:	89 e5                	mov    %esp,%ebp
f0106505:	56                   	push   %esi
f0106506:	53                   	push   %ebx
f0106507:	8b 75 08             	mov    0x8(%ebp),%esi
f010650a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010650d:	b8 0f 00 00 00       	mov    $0xf,%eax
f0106512:	ba 70 00 00 00       	mov    $0x70,%edx
f0106517:	ee                   	out    %al,(%dx)
f0106518:	b8 0a 00 00 00       	mov    $0xa,%eax
f010651d:	ba 71 00 00 00       	mov    $0x71,%edx
f0106522:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f0106523:	83 3d 88 be 3b f0 00 	cmpl   $0x0,0xf03bbe88
f010652a:	74 7e                	je     f01065aa <lapic_startap+0xac>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f010652c:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106533:	00 00 
	wrv[1] = addr >> 4;
f0106535:	89 d8                	mov    %ebx,%eax
f0106537:	c1 e8 04             	shr    $0x4,%eax
f010653a:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106540:	c1 e6 18             	shl    $0x18,%esi
f0106543:	89 f2                	mov    %esi,%edx
f0106545:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010654a:	e8 27 fe ff ff       	call   f0106376 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f010654f:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106554:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106559:	e8 18 fe ff ff       	call   f0106376 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f010655e:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106563:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106568:	e8 09 fe ff ff       	call   f0106376 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010656d:	c1 eb 0c             	shr    $0xc,%ebx
f0106570:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f0106573:	89 f2                	mov    %esi,%edx
f0106575:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010657a:	e8 f7 fd ff ff       	call   f0106376 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010657f:	89 da                	mov    %ebx,%edx
f0106581:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106586:	e8 eb fd ff ff       	call   f0106376 <lapicw>
		lapicw(ICRHI, apicid << 24);
f010658b:	89 f2                	mov    %esi,%edx
f010658d:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106592:	e8 df fd ff ff       	call   f0106376 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106597:	89 da                	mov    %ebx,%edx
f0106599:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010659e:	e8 d3 fd ff ff       	call   f0106376 <lapicw>
		microdelay(200);
	}
}
f01065a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01065a6:	5b                   	pop    %ebx
f01065a7:	5e                   	pop    %esi
f01065a8:	5d                   	pop    %ebp
f01065a9:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01065aa:	68 67 04 00 00       	push   $0x467
f01065af:	68 24 6a 10 f0       	push   $0xf0106a24
f01065b4:	68 98 00 00 00       	push   $0x98
f01065b9:	68 34 87 10 f0       	push   $0xf0108734
f01065be:	e8 7d 9a ff ff       	call   f0100040 <_panic>

f01065c3 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01065c3:	f3 0f 1e fb          	endbr32 
f01065c7:	55                   	push   %ebp
f01065c8:	89 e5                	mov    %esp,%ebp
f01065ca:	83 ec 08             	sub    $0x8,%esp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01065cd:	8b 55 08             	mov    0x8(%ebp),%edx
f01065d0:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f01065d6:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01065db:	e8 96 fd ff ff       	call   f0106376 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01065e0:	8b 15 04 d0 3f f0    	mov    0xf03fd004,%edx
f01065e6:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01065ec:	f6 c4 10             	test   $0x10,%ah
f01065ef:	75 f5                	jne    f01065e6 <lapic_ipi+0x23>
		;
}
f01065f1:	c9                   	leave  
f01065f2:	c3                   	ret    

f01065f3 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01065f3:	f3 0f 1e fb          	endbr32 
f01065f7:	55                   	push   %ebp
f01065f8:	89 e5                	mov    %esp,%ebp
f01065fa:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01065fd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106603:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106606:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106609:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106610:	5d                   	pop    %ebp
f0106611:	c3                   	ret    

f0106612 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106612:	f3 0f 1e fb          	endbr32 
f0106616:	55                   	push   %ebp
f0106617:	89 e5                	mov    %esp,%ebp
f0106619:	56                   	push   %esi
f010661a:	53                   	push   %ebx
f010661b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f010661e:	83 3b 00             	cmpl   $0x0,(%ebx)
f0106621:	75 07                	jne    f010662a <spin_lock+0x18>
	asm volatile("lock; xchgl %0, %1"
f0106623:	ba 01 00 00 00       	mov    $0x1,%edx
f0106628:	eb 34                	jmp    f010665e <spin_lock+0x4c>
f010662a:	8b 73 08             	mov    0x8(%ebx),%esi
f010662d:	e8 58 fd ff ff       	call   f010638a <cpunum>
f0106632:	6b c0 74             	imul   $0x74,%eax,%eax
f0106635:	05 20 c0 3b f0       	add    $0xf03bc020,%eax
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f010663a:	39 c6                	cmp    %eax,%esi
f010663c:	75 e5                	jne    f0106623 <spin_lock+0x11>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f010663e:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106641:	e8 44 fd ff ff       	call   f010638a <cpunum>
f0106646:	83 ec 0c             	sub    $0xc,%esp
f0106649:	53                   	push   %ebx
f010664a:	50                   	push   %eax
f010664b:	68 44 87 10 f0       	push   $0xf0108744
f0106650:	6a 41                	push   $0x41
f0106652:	68 a6 87 10 f0       	push   $0xf01087a6
f0106657:	e8 e4 99 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f010665c:	f3 90                	pause  
f010665e:	89 d0                	mov    %edx,%eax
f0106660:	f0 87 03             	lock xchg %eax,(%ebx)
	while (xchg(&lk->locked, 1) != 0)
f0106663:	85 c0                	test   %eax,%eax
f0106665:	75 f5                	jne    f010665c <spin_lock+0x4a>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106667:	e8 1e fd ff ff       	call   f010638a <cpunum>
f010666c:	6b c0 74             	imul   $0x74,%eax,%eax
f010666f:	05 20 c0 3b f0       	add    $0xf03bc020,%eax
f0106674:	89 43 08             	mov    %eax,0x8(%ebx)
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0106677:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f0106679:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f010667e:	83 f8 09             	cmp    $0x9,%eax
f0106681:	7f 21                	jg     f01066a4 <spin_lock+0x92>
f0106683:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106689:	76 19                	jbe    f01066a4 <spin_lock+0x92>
		pcs[i] = ebp[1];          // saved %eip
f010668b:	8b 4a 04             	mov    0x4(%edx),%ecx
f010668e:	89 4c 83 0c          	mov    %ecx,0xc(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106692:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f0106694:	83 c0 01             	add    $0x1,%eax
f0106697:	eb e5                	jmp    f010667e <spin_lock+0x6c>
		pcs[i] = 0;
f0106699:	c7 44 83 0c 00 00 00 	movl   $0x0,0xc(%ebx,%eax,4)
f01066a0:	00 
	for (; i < 10; i++)
f01066a1:	83 c0 01             	add    $0x1,%eax
f01066a4:	83 f8 09             	cmp    $0x9,%eax
f01066a7:	7e f0                	jle    f0106699 <spin_lock+0x87>
	get_caller_pcs(lk->pcs);
#endif
}
f01066a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01066ac:	5b                   	pop    %ebx
f01066ad:	5e                   	pop    %esi
f01066ae:	5d                   	pop    %ebp
f01066af:	c3                   	ret    

f01066b0 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01066b0:	f3 0f 1e fb          	endbr32 
f01066b4:	55                   	push   %ebp
f01066b5:	89 e5                	mov    %esp,%ebp
f01066b7:	57                   	push   %edi
f01066b8:	56                   	push   %esi
f01066b9:	53                   	push   %ebx
f01066ba:	83 ec 4c             	sub    $0x4c,%esp
f01066bd:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f01066c0:	83 3e 00             	cmpl   $0x0,(%esi)
f01066c3:	75 35                	jne    f01066fa <spin_unlock+0x4a>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01066c5:	83 ec 04             	sub    $0x4,%esp
f01066c8:	6a 28                	push   $0x28
f01066ca:	8d 46 0c             	lea    0xc(%esi),%eax
f01066cd:	50                   	push   %eax
f01066ce:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f01066d1:	53                   	push   %ebx
f01066d2:	e8 e1 f6 ff ff       	call   f0105db8 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f01066d7:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01066da:	0f b6 38             	movzbl (%eax),%edi
f01066dd:	8b 76 04             	mov    0x4(%esi),%esi
f01066e0:	e8 a5 fc ff ff       	call   f010638a <cpunum>
f01066e5:	57                   	push   %edi
f01066e6:	56                   	push   %esi
f01066e7:	50                   	push   %eax
f01066e8:	68 70 87 10 f0       	push   $0xf0108770
f01066ed:	e8 3b d4 ff ff       	call   f0103b2d <cprintf>
f01066f2:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01066f5:	8d 7d a8             	lea    -0x58(%ebp),%edi
f01066f8:	eb 4e                	jmp    f0106748 <spin_unlock+0x98>
	return lock->locked && lock->cpu == thiscpu;
f01066fa:	8b 5e 08             	mov    0x8(%esi),%ebx
f01066fd:	e8 88 fc ff ff       	call   f010638a <cpunum>
f0106702:	6b c0 74             	imul   $0x74,%eax,%eax
f0106705:	05 20 c0 3b f0       	add    $0xf03bc020,%eax
	if (!holding(lk)) {
f010670a:	39 c3                	cmp    %eax,%ebx
f010670c:	75 b7                	jne    f01066c5 <spin_unlock+0x15>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f010670e:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0106715:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f010671c:	b8 00 00 00 00       	mov    $0x0,%eax
f0106721:	f0 87 06             	lock xchg %eax,(%esi)
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
    //lk->locked = 0;
}
f0106724:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106727:	5b                   	pop    %ebx
f0106728:	5e                   	pop    %esi
f0106729:	5f                   	pop    %edi
f010672a:	5d                   	pop    %ebp
f010672b:	c3                   	ret    
				cprintf("  %08x\n", pcs[i]);
f010672c:	83 ec 08             	sub    $0x8,%esp
f010672f:	ff 36                	pushl  (%esi)
f0106731:	68 cd 87 10 f0       	push   $0xf01087cd
f0106736:	e8 f2 d3 ff ff       	call   f0103b2d <cprintf>
f010673b:	83 c4 10             	add    $0x10,%esp
f010673e:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106741:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106744:	39 c3                	cmp    %eax,%ebx
f0106746:	74 40                	je     f0106788 <spin_unlock+0xd8>
f0106748:	89 de                	mov    %ebx,%esi
f010674a:	8b 03                	mov    (%ebx),%eax
f010674c:	85 c0                	test   %eax,%eax
f010674e:	74 38                	je     f0106788 <spin_unlock+0xd8>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106750:	83 ec 08             	sub    $0x8,%esp
f0106753:	57                   	push   %edi
f0106754:	50                   	push   %eax
f0106755:	e8 d4 ea ff ff       	call   f010522e <debuginfo_eip>
f010675a:	83 c4 10             	add    $0x10,%esp
f010675d:	85 c0                	test   %eax,%eax
f010675f:	78 cb                	js     f010672c <spin_unlock+0x7c>
					pcs[i] - info.eip_fn_addr);
f0106761:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106763:	83 ec 04             	sub    $0x4,%esp
f0106766:	89 c2                	mov    %eax,%edx
f0106768:	2b 55 b8             	sub    -0x48(%ebp),%edx
f010676b:	52                   	push   %edx
f010676c:	ff 75 b0             	pushl  -0x50(%ebp)
f010676f:	ff 75 b4             	pushl  -0x4c(%ebp)
f0106772:	ff 75 ac             	pushl  -0x54(%ebp)
f0106775:	ff 75 a8             	pushl  -0x58(%ebp)
f0106778:	50                   	push   %eax
f0106779:	68 b6 87 10 f0       	push   $0xf01087b6
f010677e:	e8 aa d3 ff ff       	call   f0103b2d <cprintf>
f0106783:	83 c4 20             	add    $0x20,%esp
f0106786:	eb b6                	jmp    f010673e <spin_unlock+0x8e>
		panic("spin_unlock");
f0106788:	83 ec 04             	sub    $0x4,%esp
f010678b:	68 d5 87 10 f0       	push   $0xf01087d5
f0106790:	6a 67                	push   $0x67
f0106792:	68 a6 87 10 f0       	push   $0xf01087a6
f0106797:	e8 a4 98 ff ff       	call   f0100040 <_panic>
f010679c:	66 90                	xchg   %ax,%ax
f010679e:	66 90                	xchg   %ax,%ax

f01067a0 <__udivdi3>:
f01067a0:	f3 0f 1e fb          	endbr32 
f01067a4:	55                   	push   %ebp
f01067a5:	57                   	push   %edi
f01067a6:	56                   	push   %esi
f01067a7:	53                   	push   %ebx
f01067a8:	83 ec 1c             	sub    $0x1c,%esp
f01067ab:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01067af:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f01067b3:	8b 74 24 34          	mov    0x34(%esp),%esi
f01067b7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f01067bb:	85 d2                	test   %edx,%edx
f01067bd:	75 19                	jne    f01067d8 <__udivdi3+0x38>
f01067bf:	39 f3                	cmp    %esi,%ebx
f01067c1:	76 4d                	jbe    f0106810 <__udivdi3+0x70>
f01067c3:	31 ff                	xor    %edi,%edi
f01067c5:	89 e8                	mov    %ebp,%eax
f01067c7:	89 f2                	mov    %esi,%edx
f01067c9:	f7 f3                	div    %ebx
f01067cb:	89 fa                	mov    %edi,%edx
f01067cd:	83 c4 1c             	add    $0x1c,%esp
f01067d0:	5b                   	pop    %ebx
f01067d1:	5e                   	pop    %esi
f01067d2:	5f                   	pop    %edi
f01067d3:	5d                   	pop    %ebp
f01067d4:	c3                   	ret    
f01067d5:	8d 76 00             	lea    0x0(%esi),%esi
f01067d8:	39 f2                	cmp    %esi,%edx
f01067da:	76 14                	jbe    f01067f0 <__udivdi3+0x50>
f01067dc:	31 ff                	xor    %edi,%edi
f01067de:	31 c0                	xor    %eax,%eax
f01067e0:	89 fa                	mov    %edi,%edx
f01067e2:	83 c4 1c             	add    $0x1c,%esp
f01067e5:	5b                   	pop    %ebx
f01067e6:	5e                   	pop    %esi
f01067e7:	5f                   	pop    %edi
f01067e8:	5d                   	pop    %ebp
f01067e9:	c3                   	ret    
f01067ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01067f0:	0f bd fa             	bsr    %edx,%edi
f01067f3:	83 f7 1f             	xor    $0x1f,%edi
f01067f6:	75 48                	jne    f0106840 <__udivdi3+0xa0>
f01067f8:	39 f2                	cmp    %esi,%edx
f01067fa:	72 06                	jb     f0106802 <__udivdi3+0x62>
f01067fc:	31 c0                	xor    %eax,%eax
f01067fe:	39 eb                	cmp    %ebp,%ebx
f0106800:	77 de                	ja     f01067e0 <__udivdi3+0x40>
f0106802:	b8 01 00 00 00       	mov    $0x1,%eax
f0106807:	eb d7                	jmp    f01067e0 <__udivdi3+0x40>
f0106809:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106810:	89 d9                	mov    %ebx,%ecx
f0106812:	85 db                	test   %ebx,%ebx
f0106814:	75 0b                	jne    f0106821 <__udivdi3+0x81>
f0106816:	b8 01 00 00 00       	mov    $0x1,%eax
f010681b:	31 d2                	xor    %edx,%edx
f010681d:	f7 f3                	div    %ebx
f010681f:	89 c1                	mov    %eax,%ecx
f0106821:	31 d2                	xor    %edx,%edx
f0106823:	89 f0                	mov    %esi,%eax
f0106825:	f7 f1                	div    %ecx
f0106827:	89 c6                	mov    %eax,%esi
f0106829:	89 e8                	mov    %ebp,%eax
f010682b:	89 f7                	mov    %esi,%edi
f010682d:	f7 f1                	div    %ecx
f010682f:	89 fa                	mov    %edi,%edx
f0106831:	83 c4 1c             	add    $0x1c,%esp
f0106834:	5b                   	pop    %ebx
f0106835:	5e                   	pop    %esi
f0106836:	5f                   	pop    %edi
f0106837:	5d                   	pop    %ebp
f0106838:	c3                   	ret    
f0106839:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106840:	89 f9                	mov    %edi,%ecx
f0106842:	b8 20 00 00 00       	mov    $0x20,%eax
f0106847:	29 f8                	sub    %edi,%eax
f0106849:	d3 e2                	shl    %cl,%edx
f010684b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010684f:	89 c1                	mov    %eax,%ecx
f0106851:	89 da                	mov    %ebx,%edx
f0106853:	d3 ea                	shr    %cl,%edx
f0106855:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0106859:	09 d1                	or     %edx,%ecx
f010685b:	89 f2                	mov    %esi,%edx
f010685d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106861:	89 f9                	mov    %edi,%ecx
f0106863:	d3 e3                	shl    %cl,%ebx
f0106865:	89 c1                	mov    %eax,%ecx
f0106867:	d3 ea                	shr    %cl,%edx
f0106869:	89 f9                	mov    %edi,%ecx
f010686b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010686f:	89 eb                	mov    %ebp,%ebx
f0106871:	d3 e6                	shl    %cl,%esi
f0106873:	89 c1                	mov    %eax,%ecx
f0106875:	d3 eb                	shr    %cl,%ebx
f0106877:	09 de                	or     %ebx,%esi
f0106879:	89 f0                	mov    %esi,%eax
f010687b:	f7 74 24 08          	divl   0x8(%esp)
f010687f:	89 d6                	mov    %edx,%esi
f0106881:	89 c3                	mov    %eax,%ebx
f0106883:	f7 64 24 0c          	mull   0xc(%esp)
f0106887:	39 d6                	cmp    %edx,%esi
f0106889:	72 15                	jb     f01068a0 <__udivdi3+0x100>
f010688b:	89 f9                	mov    %edi,%ecx
f010688d:	d3 e5                	shl    %cl,%ebp
f010688f:	39 c5                	cmp    %eax,%ebp
f0106891:	73 04                	jae    f0106897 <__udivdi3+0xf7>
f0106893:	39 d6                	cmp    %edx,%esi
f0106895:	74 09                	je     f01068a0 <__udivdi3+0x100>
f0106897:	89 d8                	mov    %ebx,%eax
f0106899:	31 ff                	xor    %edi,%edi
f010689b:	e9 40 ff ff ff       	jmp    f01067e0 <__udivdi3+0x40>
f01068a0:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01068a3:	31 ff                	xor    %edi,%edi
f01068a5:	e9 36 ff ff ff       	jmp    f01067e0 <__udivdi3+0x40>
f01068aa:	66 90                	xchg   %ax,%ax
f01068ac:	66 90                	xchg   %ax,%ax
f01068ae:	66 90                	xchg   %ax,%ax

f01068b0 <__umoddi3>:
f01068b0:	f3 0f 1e fb          	endbr32 
f01068b4:	55                   	push   %ebp
f01068b5:	57                   	push   %edi
f01068b6:	56                   	push   %esi
f01068b7:	53                   	push   %ebx
f01068b8:	83 ec 1c             	sub    $0x1c,%esp
f01068bb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f01068bf:	8b 74 24 30          	mov    0x30(%esp),%esi
f01068c3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f01068c7:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01068cb:	85 c0                	test   %eax,%eax
f01068cd:	75 19                	jne    f01068e8 <__umoddi3+0x38>
f01068cf:	39 df                	cmp    %ebx,%edi
f01068d1:	76 5d                	jbe    f0106930 <__umoddi3+0x80>
f01068d3:	89 f0                	mov    %esi,%eax
f01068d5:	89 da                	mov    %ebx,%edx
f01068d7:	f7 f7                	div    %edi
f01068d9:	89 d0                	mov    %edx,%eax
f01068db:	31 d2                	xor    %edx,%edx
f01068dd:	83 c4 1c             	add    $0x1c,%esp
f01068e0:	5b                   	pop    %ebx
f01068e1:	5e                   	pop    %esi
f01068e2:	5f                   	pop    %edi
f01068e3:	5d                   	pop    %ebp
f01068e4:	c3                   	ret    
f01068e5:	8d 76 00             	lea    0x0(%esi),%esi
f01068e8:	89 f2                	mov    %esi,%edx
f01068ea:	39 d8                	cmp    %ebx,%eax
f01068ec:	76 12                	jbe    f0106900 <__umoddi3+0x50>
f01068ee:	89 f0                	mov    %esi,%eax
f01068f0:	89 da                	mov    %ebx,%edx
f01068f2:	83 c4 1c             	add    $0x1c,%esp
f01068f5:	5b                   	pop    %ebx
f01068f6:	5e                   	pop    %esi
f01068f7:	5f                   	pop    %edi
f01068f8:	5d                   	pop    %ebp
f01068f9:	c3                   	ret    
f01068fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106900:	0f bd e8             	bsr    %eax,%ebp
f0106903:	83 f5 1f             	xor    $0x1f,%ebp
f0106906:	75 50                	jne    f0106958 <__umoddi3+0xa8>
f0106908:	39 d8                	cmp    %ebx,%eax
f010690a:	0f 82 e0 00 00 00    	jb     f01069f0 <__umoddi3+0x140>
f0106910:	89 d9                	mov    %ebx,%ecx
f0106912:	39 f7                	cmp    %esi,%edi
f0106914:	0f 86 d6 00 00 00    	jbe    f01069f0 <__umoddi3+0x140>
f010691a:	89 d0                	mov    %edx,%eax
f010691c:	89 ca                	mov    %ecx,%edx
f010691e:	83 c4 1c             	add    $0x1c,%esp
f0106921:	5b                   	pop    %ebx
f0106922:	5e                   	pop    %esi
f0106923:	5f                   	pop    %edi
f0106924:	5d                   	pop    %ebp
f0106925:	c3                   	ret    
f0106926:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f010692d:	8d 76 00             	lea    0x0(%esi),%esi
f0106930:	89 fd                	mov    %edi,%ebp
f0106932:	85 ff                	test   %edi,%edi
f0106934:	75 0b                	jne    f0106941 <__umoddi3+0x91>
f0106936:	b8 01 00 00 00       	mov    $0x1,%eax
f010693b:	31 d2                	xor    %edx,%edx
f010693d:	f7 f7                	div    %edi
f010693f:	89 c5                	mov    %eax,%ebp
f0106941:	89 d8                	mov    %ebx,%eax
f0106943:	31 d2                	xor    %edx,%edx
f0106945:	f7 f5                	div    %ebp
f0106947:	89 f0                	mov    %esi,%eax
f0106949:	f7 f5                	div    %ebp
f010694b:	89 d0                	mov    %edx,%eax
f010694d:	31 d2                	xor    %edx,%edx
f010694f:	eb 8c                	jmp    f01068dd <__umoddi3+0x2d>
f0106951:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106958:	89 e9                	mov    %ebp,%ecx
f010695a:	ba 20 00 00 00       	mov    $0x20,%edx
f010695f:	29 ea                	sub    %ebp,%edx
f0106961:	d3 e0                	shl    %cl,%eax
f0106963:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106967:	89 d1                	mov    %edx,%ecx
f0106969:	89 f8                	mov    %edi,%eax
f010696b:	d3 e8                	shr    %cl,%eax
f010696d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0106971:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106975:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106979:	09 c1                	or     %eax,%ecx
f010697b:	89 d8                	mov    %ebx,%eax
f010697d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106981:	89 e9                	mov    %ebp,%ecx
f0106983:	d3 e7                	shl    %cl,%edi
f0106985:	89 d1                	mov    %edx,%ecx
f0106987:	d3 e8                	shr    %cl,%eax
f0106989:	89 e9                	mov    %ebp,%ecx
f010698b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010698f:	d3 e3                	shl    %cl,%ebx
f0106991:	89 c7                	mov    %eax,%edi
f0106993:	89 d1                	mov    %edx,%ecx
f0106995:	89 f0                	mov    %esi,%eax
f0106997:	d3 e8                	shr    %cl,%eax
f0106999:	89 e9                	mov    %ebp,%ecx
f010699b:	89 fa                	mov    %edi,%edx
f010699d:	d3 e6                	shl    %cl,%esi
f010699f:	09 d8                	or     %ebx,%eax
f01069a1:	f7 74 24 08          	divl   0x8(%esp)
f01069a5:	89 d1                	mov    %edx,%ecx
f01069a7:	89 f3                	mov    %esi,%ebx
f01069a9:	f7 64 24 0c          	mull   0xc(%esp)
f01069ad:	89 c6                	mov    %eax,%esi
f01069af:	89 d7                	mov    %edx,%edi
f01069b1:	39 d1                	cmp    %edx,%ecx
f01069b3:	72 06                	jb     f01069bb <__umoddi3+0x10b>
f01069b5:	75 10                	jne    f01069c7 <__umoddi3+0x117>
f01069b7:	39 c3                	cmp    %eax,%ebx
f01069b9:	73 0c                	jae    f01069c7 <__umoddi3+0x117>
f01069bb:	2b 44 24 0c          	sub    0xc(%esp),%eax
f01069bf:	1b 54 24 08          	sbb    0x8(%esp),%edx
f01069c3:	89 d7                	mov    %edx,%edi
f01069c5:	89 c6                	mov    %eax,%esi
f01069c7:	89 ca                	mov    %ecx,%edx
f01069c9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01069ce:	29 f3                	sub    %esi,%ebx
f01069d0:	19 fa                	sbb    %edi,%edx
f01069d2:	89 d0                	mov    %edx,%eax
f01069d4:	d3 e0                	shl    %cl,%eax
f01069d6:	89 e9                	mov    %ebp,%ecx
f01069d8:	d3 eb                	shr    %cl,%ebx
f01069da:	d3 ea                	shr    %cl,%edx
f01069dc:	09 d8                	or     %ebx,%eax
f01069de:	83 c4 1c             	add    $0x1c,%esp
f01069e1:	5b                   	pop    %ebx
f01069e2:	5e                   	pop    %esi
f01069e3:	5f                   	pop    %edi
f01069e4:	5d                   	pop    %ebp
f01069e5:	c3                   	ret    
f01069e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01069ed:	8d 76 00             	lea    0x0(%esi),%esi
f01069f0:	29 fe                	sub    %edi,%esi
f01069f2:	19 c3                	sbb    %eax,%ebx
f01069f4:	89 f2                	mov    %esi,%edx
f01069f6:	89 d9                	mov    %ebx,%ecx
f01069f8:	e9 1d ff ff ff       	jmp    f010691a <__umoddi3+0x6a>
