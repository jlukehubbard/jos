
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
f0100015:	b8 00 20 12 00       	mov    $0x122000,%eax
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
f0100034:	bc 00 20 12 f0       	mov    $0xf0122000,%esp

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
f010004c:	83 3d 80 0e 33 f0 00 	cmpl   $0x0,0xf0330e80
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
f0100064:	89 35 80 0e 33 f0    	mov    %esi,0xf0330e80
	asm volatile("cli; cld");
f010006a:	fa                   	cli    
f010006b:	fc                   	cld    
	va_start(ap, fmt);
f010006c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010006f:	e8 b6 63 00 00       	call   f010642a <cpunum>
f0100074:	ff 75 0c             	pushl  0xc(%ebp)
f0100077:	ff 75 08             	pushl  0x8(%ebp)
f010007a:	50                   	push   %eax
f010007b:	68 a0 6a 10 f0       	push   $0xf0106aa0
f0100080:	e8 b9 3a 00 00       	call   f0103b3e <cprintf>
	vcprintf(fmt, ap);
f0100085:	83 c4 08             	add    $0x8,%esp
f0100088:	53                   	push   %ebx
f0100089:	56                   	push   %esi
f010008a:	e8 85 3a 00 00       	call   f0103b14 <vcprintf>
	cprintf("\n");
f010008f:	c7 04 24 80 7c 10 f0 	movl   $0xf0107c80,(%esp)
f0100096:	e8 a3 3a 00 00       	call   f0103b3e <cprintf>
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
f01000b8:	68 0c 6b 10 f0       	push   $0xf0106b0c
f01000bd:	e8 7c 3a 00 00       	call   f0103b3e <cprintf>
	mem_init();
f01000c2:	e8 da 12 00 00       	call   f01013a1 <mem_init>
	env_init();
f01000c7:	e8 fa 31 00 00       	call   f01032c6 <env_init>
	trap_init();
f01000cc:	e8 67 3b 00 00       	call   f0103c38 <trap_init>
	mp_init();
f01000d1:	e8 55 60 00 00       	call   f010612b <mp_init>
	lapic_init();
f01000d6:	e8 69 63 00 00       	call   f0106444 <lapic_init>
	pic_init();
f01000db:	e8 73 39 00 00       	call   f0103a53 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000e0:	c7 04 24 c0 43 12 f0 	movl   $0xf01243c0,(%esp)
f01000e7:	e8 c6 65 00 00       	call   f01066b2 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000ec:	83 c4 10             	add    $0x10,%esp
f01000ef:	83 3d 88 0e 33 f0 07 	cmpl   $0x7,0xf0330e88
f01000f6:	76 27                	jbe    f010011f <i386_init+0x7f>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01000f8:	83 ec 04             	sub    $0x4,%esp
f01000fb:	b8 8e 60 10 f0       	mov    $0xf010608e,%eax
f0100100:	2d 14 60 10 f0       	sub    $0xf0106014,%eax
f0100105:	50                   	push   %eax
f0100106:	68 14 60 10 f0       	push   $0xf0106014
f010010b:	68 00 70 00 f0       	push   $0xf0007000
f0100110:	e8 43 5d 00 00       	call   f0105e58 <memmove>
	for (c = cpus; c < cpus + ncpu; c++) {
f0100115:	83 c4 10             	add    $0x10,%esp
f0100118:	bb 20 10 33 f0       	mov    $0xf0331020,%ebx
f010011d:	eb 53                	jmp    f0100172 <i386_init+0xd2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010011f:	68 00 70 00 00       	push   $0x7000
f0100124:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0100129:	6a 53                	push   $0x53
f010012b:	68 29 6b 10 f0       	push   $0xf0106b29
f0100130:	e8 0b ff ff ff       	call   f0100040 <_panic>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100135:	89 d8                	mov    %ebx,%eax
f0100137:	2d 20 10 33 f0       	sub    $0xf0331020,%eax
f010013c:	c1 f8 02             	sar    $0x2,%eax
f010013f:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100145:	c1 e0 0f             	shl    $0xf,%eax
f0100148:	8d 80 00 a0 33 f0    	lea    -0xfcc6000(%eax),%eax
f010014e:	a3 84 0e 33 f0       	mov    %eax,0xf0330e84
		lapic_startap(c->cpu_id, PADDR(code));
f0100153:	83 ec 08             	sub    $0x8,%esp
f0100156:	68 00 70 00 00       	push   $0x7000
f010015b:	0f b6 03             	movzbl (%ebx),%eax
f010015e:	50                   	push   %eax
f010015f:	e8 3a 64 00 00       	call   f010659e <lapic_startap>
		while(c->cpu_status != CPU_STARTED)
f0100164:	83 c4 10             	add    $0x10,%esp
f0100167:	8b 43 04             	mov    0x4(%ebx),%eax
f010016a:	83 f8 01             	cmp    $0x1,%eax
f010016d:	75 f8                	jne    f0100167 <i386_init+0xc7>
	for (c = cpus; c < cpus + ncpu; c++) {
f010016f:	83 c3 74             	add    $0x74,%ebx
f0100172:	6b 05 c4 13 33 f0 74 	imul   $0x74,0xf03313c4,%eax
f0100179:	05 20 10 33 f0       	add    $0xf0331020,%eax
f010017e:	39 c3                	cmp    %eax,%ebx
f0100180:	73 13                	jae    f0100195 <i386_init+0xf5>
		if (c == cpus + cpunum())  // We've started already.
f0100182:	e8 a3 62 00 00       	call   f010642a <cpunum>
f0100187:	6b c0 74             	imul   $0x74,%eax,%eax
f010018a:	05 20 10 33 f0       	add    $0xf0331020,%eax
f010018f:	39 c3                	cmp    %eax,%ebx
f0100191:	74 dc                	je     f010016f <i386_init+0xcf>
f0100193:	eb a0                	jmp    f0100135 <i386_init+0x95>
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f0100195:	83 ec 08             	sub    $0x8,%esp
f0100198:	6a 01                	push   $0x1
f010019a:	68 cc 9f 29 f0       	push   $0xf0299fcc
f010019f:	e8 1b 33 00 00       	call   f01034bf <env_create>
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001a4:	83 c4 08             	add    $0x8,%esp
f01001a7:	6a 00                	push   $0x0
f01001a9:	68 a8 02 30 f0       	push   $0xf03002a8
f01001ae:	e8 0c 33 00 00       	call   f01034bf <env_create>
	kbd_intr();
f01001b3:	e8 45 04 00 00       	call   f01005fd <kbd_intr>
	sched_yield();
f01001b8:	e8 5f 48 00 00       	call   f0104a1c <sched_yield>

f01001bd <mp_main>:
{
f01001bd:	f3 0f 1e fb          	endbr32 
f01001c1:	55                   	push   %ebp
f01001c2:	89 e5                	mov    %esp,%ebp
f01001c4:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f01001c7:	a1 8c 0e 33 f0       	mov    0xf0330e8c,%eax
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
f01001db:	e8 4a 62 00 00       	call   f010642a <cpunum>
f01001e0:	83 ec 08             	sub    $0x8,%esp
f01001e3:	50                   	push   %eax
f01001e4:	68 35 6b 10 f0       	push   $0xf0106b35
f01001e9:	e8 50 39 00 00       	call   f0103b3e <cprintf>
	lapic_init();
f01001ee:	e8 51 62 00 00       	call   f0106444 <lapic_init>
	env_init_percpu();
f01001f3:	e8 9e 30 00 00       	call   f0103296 <env_init_percpu>
	trap_init_percpu();
f01001f8:	e8 59 39 00 00       	call   f0103b56 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01001fd:	e8 28 62 00 00       	call   f010642a <cpunum>
f0100202:	6b d0 74             	imul   $0x74,%eax,%edx
f0100205:	83 c2 04             	add    $0x4,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100208:	b8 01 00 00 00       	mov    $0x1,%eax
f010020d:	f0 87 82 20 10 33 f0 	lock xchg %eax,-0xfccefe0(%edx)
f0100214:	c7 04 24 c0 43 12 f0 	movl   $0xf01243c0,(%esp)
f010021b:	e8 92 64 00 00       	call   f01066b2 <spin_lock>
    sched_yield();
f0100220:	e8 f7 47 00 00       	call   f0104a1c <sched_yield>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100225:	50                   	push   %eax
f0100226:	68 e8 6a 10 f0       	push   $0xf0106ae8
f010022b:	6a 6a                	push   $0x6a
f010022d:	68 29 6b 10 f0       	push   $0xf0106b29
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
f010024b:	68 4b 6b 10 f0       	push   $0xf0106b4b
f0100250:	e8 e9 38 00 00       	call   f0103b3e <cprintf>
	vcprintf(fmt, ap);
f0100255:	83 c4 08             	add    $0x8,%esp
f0100258:	53                   	push   %ebx
f0100259:	ff 75 10             	pushl  0x10(%ebp)
f010025c:	e8 b3 38 00 00       	call   f0103b14 <vcprintf>
	cprintf("\n");
f0100261:	c7 04 24 80 7c 10 f0 	movl   $0xf0107c80,(%esp)
f0100268:	e8 d1 38 00 00       	call   f0103b3e <cprintf>
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
f01002a7:	8b 0d 24 02 33 f0    	mov    0xf0330224,%ecx
f01002ad:	8d 51 01             	lea    0x1(%ecx),%edx
f01002b0:	88 81 20 00 33 f0    	mov    %al,-0xfccffe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002b6:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f01002bc:	b8 00 00 00 00       	mov    $0x0,%eax
f01002c1:	0f 44 d0             	cmove  %eax,%edx
f01002c4:	89 15 24 02 33 f0    	mov    %edx,0xf0330224
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
f0100303:	8b 0d 00 00 33 f0    	mov    0xf0330000,%ecx
f0100309:	f6 c1 40             	test   $0x40,%cl
f010030c:	74 0e                	je     f010031c <kbd_proc_data+0x4a>
		data |= 0x80;
f010030e:	83 c8 80             	or     $0xffffff80,%eax
f0100311:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100313:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100316:	89 0d 00 00 33 f0    	mov    %ecx,0xf0330000
	shift |= shiftcode[data];
f010031c:	0f b6 d2             	movzbl %dl,%edx
f010031f:	0f b6 82 c0 6c 10 f0 	movzbl -0xfef9340(%edx),%eax
f0100326:	0b 05 00 00 33 f0    	or     0xf0330000,%eax
	shift ^= togglecode[data];
f010032c:	0f b6 8a c0 6b 10 f0 	movzbl -0xfef9440(%edx),%ecx
f0100333:	31 c8                	xor    %ecx,%eax
f0100335:	a3 00 00 33 f0       	mov    %eax,0xf0330000
	c = charcode[shift & (CTL | SHIFT)][data];
f010033a:	89 c1                	mov    %eax,%ecx
f010033c:	83 e1 03             	and    $0x3,%ecx
f010033f:	8b 0c 8d a0 6b 10 f0 	mov    -0xfef9460(,%ecx,4),%ecx
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
f0100360:	83 0d 00 00 33 f0 40 	orl    $0x40,0xf0330000
		return 0;
f0100367:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f010036c:	89 d8                	mov    %ebx,%eax
f010036e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100371:	c9                   	leave  
f0100372:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100373:	8b 0d 00 00 33 f0    	mov    0xf0330000,%ecx
f0100379:	89 cb                	mov    %ecx,%ebx
f010037b:	83 e3 40             	and    $0x40,%ebx
f010037e:	83 e0 7f             	and    $0x7f,%eax
f0100381:	85 db                	test   %ebx,%ebx
f0100383:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100386:	0f b6 d2             	movzbl %dl,%edx
f0100389:	0f b6 82 c0 6c 10 f0 	movzbl -0xfef9340(%edx),%eax
f0100390:	83 c8 40             	or     $0x40,%eax
f0100393:	0f b6 c0             	movzbl %al,%eax
f0100396:	f7 d0                	not    %eax
f0100398:	21 c8                	and    %ecx,%eax
f010039a:	a3 00 00 33 f0       	mov    %eax,0xf0330000
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
f01003c3:	68 65 6b 10 f0       	push   $0xf0106b65
f01003c8:	e8 71 37 00 00       	call   f0103b3e <cprintf>
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
f01004dc:	0f b7 05 28 02 33 f0 	movzwl 0xf0330228,%eax
f01004e3:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004e9:	c1 e8 16             	shr    $0x16,%eax
f01004ec:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004ef:	c1 e0 04             	shl    $0x4,%eax
f01004f2:	66 a3 28 02 33 f0    	mov    %ax,0xf0330228
	if (crt_pos >= CRT_SIZE) {
f01004f8:	66 81 3d 28 02 33 f0 	cmpw   $0x7cf,0xf0330228
f01004ff:	cf 07 
f0100501:	0f 87 8e 00 00 00    	ja     f0100595 <cons_putc+0x1aa>
	outb(addr_6845, 14);
f0100507:	8b 0d 30 02 33 f0    	mov    0xf0330230,%ecx
f010050d:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100512:	89 ca                	mov    %ecx,%edx
f0100514:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100515:	0f b7 1d 28 02 33 f0 	movzwl 0xf0330228,%ebx
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
f010053d:	0f b7 05 28 02 33 f0 	movzwl 0xf0330228,%eax
f0100544:	66 85 c0             	test   %ax,%ax
f0100547:	74 be                	je     f0100507 <cons_putc+0x11c>
			crt_pos--;
f0100549:	83 e8 01             	sub    $0x1,%eax
f010054c:	66 a3 28 02 33 f0    	mov    %ax,0xf0330228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100552:	0f b7 d0             	movzwl %ax,%edx
f0100555:	b1 00                	mov    $0x0,%cl
f0100557:	83 c9 20             	or     $0x20,%ecx
f010055a:	a1 2c 02 33 f0       	mov    0xf033022c,%eax
f010055f:	66 89 0c 50          	mov    %cx,(%eax,%edx,2)
f0100563:	eb 93                	jmp    f01004f8 <cons_putc+0x10d>
		crt_pos += CRT_COLS;
f0100565:	66 83 05 28 02 33 f0 	addw   $0x50,0xf0330228
f010056c:	50 
f010056d:	e9 6a ff ff ff       	jmp    f01004dc <cons_putc+0xf1>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100572:	0f b7 05 28 02 33 f0 	movzwl 0xf0330228,%eax
f0100579:	8d 50 01             	lea    0x1(%eax),%edx
f010057c:	66 89 15 28 02 33 f0 	mov    %dx,0xf0330228
f0100583:	0f b7 c0             	movzwl %ax,%eax
f0100586:	8b 15 2c 02 33 f0    	mov    0xf033022c,%edx
f010058c:	66 89 0c 42          	mov    %cx,(%edx,%eax,2)
		break;
f0100590:	e9 63 ff ff ff       	jmp    f01004f8 <cons_putc+0x10d>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100595:	a1 2c 02 33 f0       	mov    0xf033022c,%eax
f010059a:	83 ec 04             	sub    $0x4,%esp
f010059d:	68 00 0f 00 00       	push   $0xf00
f01005a2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005a8:	52                   	push   %edx
f01005a9:	50                   	push   %eax
f01005aa:	e8 a9 58 00 00       	call   f0105e58 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01005af:	8b 15 2c 02 33 f0    	mov    0xf033022c,%edx
f01005b5:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01005bb:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01005c1:	83 c4 10             	add    $0x10,%esp
f01005c4:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01005c9:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005cc:	39 d0                	cmp    %edx,%eax
f01005ce:	75 f4                	jne    f01005c4 <cons_putc+0x1d9>
		crt_pos -= CRT_COLS;
f01005d0:	66 83 2d 28 02 33 f0 	subw   $0x50,0xf0330228
f01005d7:	50 
f01005d8:	e9 2a ff ff ff       	jmp    f0100507 <cons_putc+0x11c>

f01005dd <serial_intr>:
{
f01005dd:	f3 0f 1e fb          	endbr32 
	if (serial_exists)
f01005e1:	80 3d 34 02 33 f0 00 	cmpb   $0x0,0xf0330234
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
f0100627:	a1 20 02 33 f0       	mov    0xf0330220,%eax
	return 0;
f010062c:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f0100631:	3b 05 24 02 33 f0    	cmp    0xf0330224,%eax
f0100637:	74 1c                	je     f0100655 <cons_getc+0x42>
		c = cons.buf[cons.rpos++];
f0100639:	8d 48 01             	lea    0x1(%eax),%ecx
f010063c:	0f b6 90 20 00 33 f0 	movzbl -0xfccffe0(%eax),%edx
			cons.rpos = 0;
f0100643:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f0100648:	b8 00 00 00 00       	mov    $0x0,%eax
f010064d:	0f 45 c1             	cmovne %ecx,%eax
f0100650:	a3 20 02 33 f0       	mov    %eax,0xf0330220
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
f0100687:	c7 05 30 02 33 f0 b4 	movl   $0x3b4,0xf0330230
f010068e:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100691:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f0100696:	8b 3d 30 02 33 f0    	mov    0xf0330230,%edi
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
f01006bd:	89 35 2c 02 33 f0    	mov    %esi,0xf033022c
	pos |= inb(addr_6845 + 1);
f01006c3:	0f b6 c0             	movzbl %al,%eax
f01006c6:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f01006c8:	66 a3 28 02 33 f0    	mov    %ax,0xf0330228
	kbd_intr();
f01006ce:	e8 2a ff ff ff       	call   f01005fd <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006d3:	83 ec 0c             	sub    $0xc,%esp
f01006d6:	0f b7 05 a8 43 12 f0 	movzwl 0xf01243a8,%eax
f01006dd:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006e2:	50                   	push   %eax
f01006e3:	e8 e9 32 00 00       	call   f01039d1 <irq_setmask_8259A>
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
f010073e:	0f 95 05 34 02 33 f0 	setne  0xf0330234
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
f0100756:	68 71 6b 10 f0       	push   $0xf0106b71
f010075b:	e8 de 33 00 00       	call   f0103b3e <cprintf>
f0100760:	83 c4 10             	add    $0x10,%esp
}
f0100763:	eb 3c                	jmp    f01007a1 <cons_init+0x148>
		*cp = was;
f0100765:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010076c:	c7 05 30 02 33 f0 d4 	movl   $0x3d4,0xf0330230
f0100773:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100776:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f010077b:	e9 16 ff ff ff       	jmp    f0100696 <cons_init+0x3d>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_SERIAL));
f0100780:	83 ec 0c             	sub    $0xc,%esp
f0100783:	0f b7 05 a8 43 12 f0 	movzwl 0xf01243a8,%eax
f010078a:	25 ef ff 00 00       	and    $0xffef,%eax
f010078f:	50                   	push   %eax
f0100790:	e8 3c 32 00 00       	call   f01039d1 <irq_setmask_8259A>
	if (!serial_exists)
f0100795:	83 c4 10             	add    $0x10,%esp
f0100798:	80 3d 34 02 33 f0 00 	cmpb   $0x0,0xf0330234
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
f01007e6:	68 c0 6d 10 f0       	push   $0xf0106dc0
f01007eb:	68 de 6d 10 f0       	push   $0xf0106dde
f01007f0:	68 e3 6d 10 f0       	push   $0xf0106de3
f01007f5:	e8 44 33 00 00       	call   f0103b3e <cprintf>
f01007fa:	83 c4 0c             	add    $0xc,%esp
f01007fd:	68 9c 6e 10 f0       	push   $0xf0106e9c
f0100802:	68 ec 6d 10 f0       	push   $0xf0106dec
f0100807:	68 e3 6d 10 f0       	push   $0xf0106de3
f010080c:	e8 2d 33 00 00       	call   f0103b3e <cprintf>
f0100811:	83 c4 0c             	add    $0xc,%esp
f0100814:	68 c4 6e 10 f0       	push   $0xf0106ec4
f0100819:	68 f5 6d 10 f0       	push   $0xf0106df5
f010081e:	68 e3 6d 10 f0       	push   $0xf0106de3
f0100823:	e8 16 33 00 00       	call   f0103b3e <cprintf>
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
f0100839:	68 ff 6d 10 f0       	push   $0xf0106dff
f010083e:	e8 fb 32 00 00       	call   f0103b3e <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100843:	83 c4 08             	add    $0x8,%esp
f0100846:	68 0c 00 10 00       	push   $0x10000c
f010084b:	68 f4 6e 10 f0       	push   $0xf0106ef4
f0100850:	e8 e9 32 00 00       	call   f0103b3e <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100855:	83 c4 0c             	add    $0xc,%esp
f0100858:	68 0c 00 10 00       	push   $0x10000c
f010085d:	68 0c 00 10 f0       	push   $0xf010000c
f0100862:	68 1c 6f 10 f0       	push   $0xf0106f1c
f0100867:	e8 d2 32 00 00       	call   f0103b3e <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010086c:	83 c4 0c             	add    $0xc,%esp
f010086f:	68 9d 6a 10 00       	push   $0x106a9d
f0100874:	68 9d 6a 10 f0       	push   $0xf0106a9d
f0100879:	68 40 6f 10 f0       	push   $0xf0106f40
f010087e:	e8 bb 32 00 00       	call   f0103b3e <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100883:	83 c4 0c             	add    $0xc,%esp
f0100886:	68 00 00 33 00       	push   $0x330000
f010088b:	68 00 00 33 f0       	push   $0xf0330000
f0100890:	68 64 6f 10 f0       	push   $0xf0106f64
f0100895:	e8 a4 32 00 00       	call   f0103b3e <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010089a:	83 c4 0c             	add    $0xc,%esp
f010089d:	68 08 20 37 00       	push   $0x372008
f01008a2:	68 08 20 37 f0       	push   $0xf0372008
f01008a7:	68 88 6f 10 f0       	push   $0xf0106f88
f01008ac:	e8 8d 32 00 00       	call   f0103b3e <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008b1:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01008b4:	b8 08 20 37 f0       	mov    $0xf0372008,%eax
f01008b9:	2d 0d fc 0f f0       	sub    $0xf00ffc0d,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008be:	c1 f8 0a             	sar    $0xa,%eax
f01008c1:	50                   	push   %eax
f01008c2:	68 ac 6f 10 f0       	push   $0xf0106fac
f01008c7:	e8 72 32 00 00       	call   f0103b3e <cprintf>
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
f01008e0:	68 18 6e 10 f0       	push   $0xf0106e18
f01008e5:	e8 54 32 00 00       	call   f0103b3e <cprintf>
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
f01008f7:	68 80 7c 10 f0       	push   $0xf0107c80
f01008fc:	e8 3d 32 00 00       	call   f0103b3e <cprintf>

        struct Eipdebuginfo info;
        memset(&info, 0, sizeof(struct Eipdebuginfo));
f0100901:	83 c4 0c             	add    $0xc,%esp
f0100904:	6a 18                	push   $0x18
f0100906:	6a 00                	push   $0x0
f0100908:	8d 45 d0             	lea    -0x30(%ebp),%eax
f010090b:	50                   	push   %eax
f010090c:	e8 fb 54 00 00       	call   f0105e0c <memset>

        int ret = debuginfo_eip((uintptr_t)ebp[1], &info);
f0100911:	83 c4 08             	add    $0x8,%esp
f0100914:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100917:	50                   	push   %eax
f0100918:	ff 77 04             	pushl  0x4(%edi)
f010091b:	e8 ae 49 00 00       	call   f01052ce <debuginfo_eip>
        cprintf("         ");
f0100920:	c7 04 24 47 6e 10 f0 	movl   $0xf0106e47,(%esp)
f0100927:	e8 12 32 00 00       	call   f0103b3e <cprintf>
        cprintf("%s:", info.eip_file);
f010092c:	83 c4 08             	add    $0x8,%esp
f010092f:	ff 75 d0             	pushl  -0x30(%ebp)
f0100932:	68 51 6e 10 f0       	push   $0xf0106e51
f0100937:	e8 02 32 00 00       	call   f0103b3e <cprintf>
        cprintf("%d: ", info.eip_line);
f010093c:	83 c4 08             	add    $0x8,%esp
f010093f:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100942:	68 60 6b 10 f0       	push   $0xf0106b60
f0100947:	e8 f2 31 00 00       	call   f0103b3e <cprintf>
        cprintf("%.*s", info.eip_fn_namelen, info.eip_fn_name);
f010094c:	83 c4 0c             	add    $0xc,%esp
f010094f:	ff 75 d8             	pushl  -0x28(%ebp)
f0100952:	ff 75 dc             	pushl  -0x24(%ebp)
f0100955:	68 55 6e 10 f0       	push   $0xf0106e55
f010095a:	e8 df 31 00 00       	call   f0103b3e <cprintf>

        uintptr_t addr = ebp[1] - info.eip_fn_addr;

        cprintf("+%d\n", addr);
f010095f:	83 c4 08             	add    $0x8,%esp
        uintptr_t addr = ebp[1] - info.eip_fn_addr;
f0100962:	8b 47 04             	mov    0x4(%edi),%eax
f0100965:	2b 45 e0             	sub    -0x20(%ebp),%eax
        cprintf("+%d\n", addr);
f0100968:	50                   	push   %eax
f0100969:	68 5a 6e 10 f0       	push   $0xf0106e5a
f010096e:	e8 cb 31 00 00       	call   f0103b3e <cprintf>

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
f0100982:	68 2a 6e 10 f0       	push   $0xf0106e2a
f0100987:	e8 b2 31 00 00       	call   f0103b3e <cprintf>
        cprintf("  eip %08x", ebp[1]);
f010098c:	83 c4 08             	add    $0x8,%esp
f010098f:	ff 76 04             	pushl  0x4(%esi)
f0100992:	68 35 6e 10 f0       	push   $0xf0106e35
f0100997:	e8 a2 31 00 00       	call   f0103b3e <cprintf>
        cprintf("  args");
f010099c:	c7 04 24 40 6e 10 f0 	movl   $0xf0106e40,(%esp)
f01009a3:	e8 96 31 00 00       	call   f0103b3e <cprintf>
f01009a8:	8d 5e 08             	lea    0x8(%esi),%ebx
f01009ab:	83 c6 1c             	add    $0x1c,%esi
f01009ae:	83 c4 10             	add    $0x10,%esp
            cprintf(" %08x", ebp[2+i]);
f01009b1:	83 ec 08             	sub    $0x8,%esp
f01009b4:	ff 33                	pushl  (%ebx)
f01009b6:	68 2f 6e 10 f0       	push   $0xf0106e2f
f01009bb:	e8 7e 31 00 00       	call   f0103b3e <cprintf>
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
f01009e9:	68 d8 6f 10 f0       	push   $0xf0106fd8
f01009ee:	e8 4b 31 00 00       	call   f0103b3e <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009f3:	c7 04 24 fc 6f 10 f0 	movl   $0xf0106ffc,(%esp)
f01009fa:	e8 3f 31 00 00       	call   f0103b3e <cprintf>

	if (tf != NULL)
f01009ff:	83 c4 10             	add    $0x10,%esp
f0100a02:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100a06:	0f 84 d9 00 00 00    	je     f0100ae5 <monitor+0x109>
		print_trapframe(tf);
f0100a0c:	83 ec 0c             	sub    $0xc,%esp
f0100a0f:	ff 75 08             	pushl  0x8(%ebp)
f0100a12:	e8 a5 38 00 00       	call   f01042bc <print_trapframe>
f0100a17:	83 c4 10             	add    $0x10,%esp
f0100a1a:	e9 c6 00 00 00       	jmp    f0100ae5 <monitor+0x109>
		while (*buf && strchr(WHITESPACE, *buf))
f0100a1f:	83 ec 08             	sub    $0x8,%esp
f0100a22:	0f be c0             	movsbl %al,%eax
f0100a25:	50                   	push   %eax
f0100a26:	68 63 6e 10 f0       	push   $0xf0106e63
f0100a2b:	e8 97 53 00 00       	call   f0105dc7 <strchr>
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
f0100a63:	ff 34 85 40 70 10 f0 	pushl  -0xfef8fc0(,%eax,4)
f0100a6a:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a6d:	e8 ef 52 00 00       	call   f0105d61 <strcmp>
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
f0100a8b:	68 85 6e 10 f0       	push   $0xf0106e85
f0100a90:	e8 a9 30 00 00       	call   f0103b3e <cprintf>
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
f0100ab9:	68 63 6e 10 f0       	push   $0xf0106e63
f0100abe:	e8 04 53 00 00       	call   f0105dc7 <strchr>
f0100ac3:	83 c4 10             	add    $0x10,%esp
f0100ac6:	85 c0                	test   %eax,%eax
f0100ac8:	0f 85 71 ff ff ff    	jne    f0100a3f <monitor+0x63>
			buf++;
f0100ace:	83 c3 01             	add    $0x1,%ebx
f0100ad1:	eb d8                	jmp    f0100aab <monitor+0xcf>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100ad3:	83 ec 08             	sub    $0x8,%esp
f0100ad6:	6a 10                	push   $0x10
f0100ad8:	68 68 6e 10 f0       	push   $0xf0106e68
f0100add:	e8 5c 30 00 00       	call   f0103b3e <cprintf>
			return 0;
f0100ae2:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100ae5:	83 ec 0c             	sub    $0xc,%esp
f0100ae8:	68 5f 6e 10 f0       	push   $0xf0106e5f
f0100aed:	e8 7b 50 00 00       	call   f0105b6d <readline>
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
f0100b1a:	ff 14 85 48 70 10 f0 	call   *-0xfef8fb8(,%eax,4)
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
f0100b3b:	e8 5b 2e 00 00       	call   f010399b <mc146818_read>
f0100b40:	89 c6                	mov    %eax,%esi
f0100b42:	83 c3 01             	add    $0x1,%ebx
f0100b45:	89 1c 24             	mov    %ebx,(%esp)
f0100b48:	e8 4e 2e 00 00       	call   f010399b <mc146818_read>
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
f0100b70:	3b 05 88 0e 33 f0    	cmp    0xf0330e88,%eax
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
f0100ba2:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0100ba7:	68 d6 03 00 00       	push   $0x3d6
f0100bac:	68 85 79 10 f0       	push   $0xf0107985
f0100bb1:	e8 8a f4 ff ff       	call   f0100040 <_panic>
		return ~0;
f0100bb6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100bbb:	c3                   	ret    

f0100bbc <boot_alloc>:
	if (!nextfree) {
f0100bbc:	83 3d 38 02 33 f0 00 	cmpl   $0x0,0xf0330238
f0100bc3:	74 3d                	je     f0100c02 <boot_alloc+0x46>
    if (n == 0) {
f0100bc5:	85 c0                	test   %eax,%eax
f0100bc7:	74 4c                	je     f0100c15 <boot_alloc+0x59>
{
f0100bc9:	55                   	push   %ebp
f0100bca:	89 e5                	mov    %esp,%ebp
f0100bcc:	83 ec 08             	sub    $0x8,%esp
            (uintptr_t) ROUNDUP((char *)nextfree + n, PGSIZE);
f0100bcf:	8b 15 38 02 33 f0    	mov    0xf0330238,%edx
f0100bd5:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100bdc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if ((uint32_t)kva < KERNBASE)
f0100be1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100be6:	76 36                	jbe    f0100c1e <boot_alloc+0x62>
	return (physaddr_t)kva - KERNBASE;
f0100be8:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
    if ( PADDR((void *)next_nextfree)/PGSIZE < npages ) {
f0100bee:	c1 e9 0c             	shr    $0xc,%ecx
f0100bf1:	3b 0d 88 0e 33 f0    	cmp    0xf0330e88,%ecx
f0100bf7:	73 37                	jae    f0100c30 <boot_alloc+0x74>
        nextfree = (char *)next_nextfree;
f0100bf9:	a3 38 02 33 f0       	mov    %eax,0xf0330238
}
f0100bfe:	89 d0                	mov    %edx,%eax
f0100c00:	c9                   	leave  
f0100c01:	c3                   	ret    
		nextfree = ROUNDUP((char *) end + 1, PGSIZE);
f0100c02:	ba 08 30 37 f0       	mov    $0xf0373008,%edx
f0100c07:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100c0d:	89 15 38 02 33 f0    	mov    %edx,0xf0330238
f0100c13:	eb b0                	jmp    f0100bc5 <boot_alloc+0x9>
        return nextfree;
f0100c15:	8b 15 38 02 33 f0    	mov    0xf0330238,%edx
}
f0100c1b:	89 d0                	mov    %edx,%eax
f0100c1d:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100c1e:	50                   	push   %eax
f0100c1f:	68 e8 6a 10 f0       	push   $0xf0106ae8
f0100c24:	6a 76                	push   $0x76
f0100c26:	68 85 79 10 f0       	push   $0xf0107985
f0100c2b:	e8 10 f4 ff ff       	call   f0100040 <_panic>
        panic("Out of memory");
f0100c30:	83 ec 04             	sub    $0x4,%esp
f0100c33:	68 91 79 10 f0       	push   $0xf0107991
f0100c38:	6a 7c                	push   $0x7c
f0100c3a:	68 85 79 10 f0       	push   $0xf0107985
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
f0100c55:	83 3d 40 02 33 f0 00 	cmpl   $0x0,0xf0330240
f0100c5c:	74 0a                	je     f0100c68 <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c5e:	be 00 04 00 00       	mov    $0x400,%esi
f0100c63:	e9 bf 02 00 00       	jmp    f0100f27 <check_page_free_list+0x2e3>
		panic("'page_free_list' is a null pointer!");
f0100c68:	83 ec 04             	sub    $0x4,%esp
f0100c6b:	68 64 70 10 f0       	push   $0xf0107064
f0100c70:	68 08 03 00 00       	push   $0x308
f0100c75:	68 85 79 10 f0       	push   $0xf0107985
f0100c7a:	e8 c1 f3 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c7f:	50                   	push   %eax
f0100c80:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0100c85:	6a 58                	push   $0x58
f0100c87:	68 9f 79 10 f0       	push   $0xf010799f
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
f0100c99:	2b 05 90 0e 33 f0    	sub    0xf0330e90,%eax
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
f0100cb3:	3b 15 88 0e 33 f0    	cmp    0xf0330e88,%edx
f0100cb9:	73 c4                	jae    f0100c7f <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100cbb:	83 ec 04             	sub    $0x4,%esp
f0100cbe:	68 80 00 00 00       	push   $0x80
f0100cc3:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100cc8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ccd:	50                   	push   %eax
f0100cce:	e8 39 51 00 00       	call   f0105e0c <memset>
f0100cd3:	83 c4 10             	add    $0x10,%esp
f0100cd6:	eb b9                	jmp    f0100c91 <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f0100cd8:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cdd:	e8 da fe ff ff       	call   f0100bbc <boot_alloc>
f0100ce2:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ce5:	8b 15 40 02 33 f0    	mov    0xf0330240,%edx
		assert(pp >= pages);
f0100ceb:	8b 0d 90 0e 33 f0    	mov    0xf0330e90,%ecx
		assert(pp < pages + npages);
f0100cf1:	a1 88 0e 33 f0       	mov    0xf0330e88,%eax
f0100cf6:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100cf9:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100cfc:	bf 00 00 00 00       	mov    $0x0,%edi
f0100d01:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d04:	e9 f9 00 00 00       	jmp    f0100e02 <check_page_free_list+0x1be>
		assert(pp >= pages);
f0100d09:	68 ad 79 10 f0       	push   $0xf01079ad
f0100d0e:	68 b9 79 10 f0       	push   $0xf01079b9
f0100d13:	68 22 03 00 00       	push   $0x322
f0100d18:	68 85 79 10 f0       	push   $0xf0107985
f0100d1d:	e8 1e f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100d22:	68 ce 79 10 f0       	push   $0xf01079ce
f0100d27:	68 b9 79 10 f0       	push   $0xf01079b9
f0100d2c:	68 23 03 00 00       	push   $0x323
f0100d31:	68 85 79 10 f0       	push   $0xf0107985
f0100d36:	e8 05 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d3b:	68 88 70 10 f0       	push   $0xf0107088
f0100d40:	68 b9 79 10 f0       	push   $0xf01079b9
f0100d45:	68 24 03 00 00       	push   $0x324
f0100d4a:	68 85 79 10 f0       	push   $0xf0107985
f0100d4f:	e8 ec f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != 0);
f0100d54:	68 e2 79 10 f0       	push   $0xf01079e2
f0100d59:	68 b9 79 10 f0       	push   $0xf01079b9
f0100d5e:	68 27 03 00 00       	push   $0x327
f0100d63:	68 85 79 10 f0       	push   $0xf0107985
f0100d68:	e8 d3 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d6d:	68 f3 79 10 f0       	push   $0xf01079f3
f0100d72:	68 b9 79 10 f0       	push   $0xf01079b9
f0100d77:	68 28 03 00 00       	push   $0x328
f0100d7c:	68 85 79 10 f0       	push   $0xf0107985
f0100d81:	e8 ba f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d86:	68 bc 70 10 f0       	push   $0xf01070bc
f0100d8b:	68 b9 79 10 f0       	push   $0xf01079b9
f0100d90:	68 29 03 00 00       	push   $0x329
f0100d95:	68 85 79 10 f0       	push   $0xf0107985
f0100d9a:	e8 a1 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d9f:	68 0c 7a 10 f0       	push   $0xf0107a0c
f0100da4:	68 b9 79 10 f0       	push   $0xf01079b9
f0100da9:	68 2a 03 00 00       	push   $0x32a
f0100dae:	68 85 79 10 f0       	push   $0xf0107985
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
f0100dd2:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0100dd7:	6a 58                	push   $0x58
f0100dd9:	68 9f 79 10 f0       	push   $0xf010799f
f0100dde:	e8 5d f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100de3:	68 e0 70 10 f0       	push   $0xf01070e0
f0100de8:	68 b9 79 10 f0       	push   $0xf01079b9
f0100ded:	68 2b 03 00 00       	push   $0x32b
f0100df2:	68 85 79 10 f0       	push   $0xf0107985
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
f0100e61:	68 26 7a 10 f0       	push   $0xf0107a26
f0100e66:	68 b9 79 10 f0       	push   $0xf01079b9
f0100e6b:	68 2d 03 00 00       	push   $0x32d
f0100e70:	68 85 79 10 f0       	push   $0xf0107985
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
f0100e88:	68 28 71 10 f0       	push   $0xf0107128
f0100e8d:	e8 ac 2c 00 00       	call   f0103b3e <cprintf>
}
f0100e92:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e95:	5b                   	pop    %ebx
f0100e96:	5e                   	pop    %esi
f0100e97:	5f                   	pop    %edi
f0100e98:	5d                   	pop    %ebp
f0100e99:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100e9a:	68 43 7a 10 f0       	push   $0xf0107a43
f0100e9f:	68 b9 79 10 f0       	push   $0xf01079b9
f0100ea4:	68 35 03 00 00       	push   $0x335
f0100ea9:	68 85 79 10 f0       	push   $0xf0107985
f0100eae:	e8 8d f1 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100eb3:	68 55 7a 10 f0       	push   $0xf0107a55
f0100eb8:	68 b9 79 10 f0       	push   $0xf01079b9
f0100ebd:	68 36 03 00 00       	push   $0x336
f0100ec2:	68 85 79 10 f0       	push   $0xf0107985
f0100ec7:	e8 74 f1 ff ff       	call   f0100040 <_panic>
	if (!page_free_list)
f0100ecc:	a1 40 02 33 f0       	mov    0xf0330240,%eax
f0100ed1:	85 c0                	test   %eax,%eax
f0100ed3:	0f 84 8f fd ff ff    	je     f0100c68 <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100ed9:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100edc:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100edf:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100ee2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100ee5:	89 c2                	mov    %eax,%edx
f0100ee7:	2b 15 90 0e 33 f0    	sub    0xf0330e90,%edx
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
f0100f1d:	a3 40 02 33 f0       	mov    %eax,0xf0330240
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100f22:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100f27:	8b 1d 40 02 33 f0    	mov    0xf0330240,%ebx
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
f0100f59:	8b 3d 40 02 33 f0    	mov    0xf0330240,%edi
    for (int i=0; i<npages; ++i) {
f0100f5f:	c6 45 e3 00          	movb   $0x0,-0x1d(%ebp)
f0100f63:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f68:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100f6b:	eb 32                	jmp    f0100f9f <page_init+0x6d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f6d:	50                   	push   %eax
f0100f6e:	68 e8 6a 10 f0       	push   $0xf0106ae8
f0100f73:	68 5f 01 00 00       	push   $0x15f
f0100f78:	68 85 79 10 f0       	push   $0xf0107985
f0100f7d:	e8 be f0 ff ff       	call   f0100040 <_panic>
            pages[i].pp_link = NULL;
f0100f82:	8b 1d 90 0e 33 f0    	mov    0xf0330e90,%ebx
f0100f88:	c7 04 d3 00 00 00 00 	movl   $0x0,(%ebx,%edx,8)
            pages[i].pp_ref = 1;
f0100f8f:	8b 1d 90 0e 33 f0    	mov    0xf0330e90,%ebx
f0100f95:	66 c7 44 d3 04 01 00 	movw   $0x1,0x4(%ebx,%edx,8)
    for (int i=0; i<npages; ++i) {
f0100f9c:	83 c0 01             	add    $0x1,%eax
f0100f9f:	89 c2                	mov    %eax,%edx
f0100fa1:	39 05 88 0e 33 f0    	cmp    %eax,0xf0330e88
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
f0100fce:	03 1d 90 0e 33 f0    	add    0xf0330e90,%ebx
f0100fd4:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
            pages[i].pp_link = page_free_list;
f0100fda:	89 3b                	mov    %edi,(%ebx)
            page_free_list = &pages[i];
f0100fdc:	89 d7                	mov    %edx,%edi
f0100fde:	03 3d 90 0e 33 f0    	add    0xf0330e90,%edi
f0100fe4:	c6 45 e3 01          	movb   $0x1,-0x1d(%ebp)
f0100fe8:	eb b2                	jmp    f0100f9c <page_init+0x6a>
f0100fea:	80 7d e3 00          	cmpb   $0x0,-0x1d(%ebp)
f0100fee:	74 06                	je     f0100ff6 <page_init+0xc4>
f0100ff0:	89 3d 40 02 33 f0    	mov    %edi,0xf0330240
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
f0101009:	8b 1d 40 02 33 f0    	mov    0xf0330240,%ebx
f010100f:	85 db                	test   %ebx,%ebx
f0101011:	74 13                	je     f0101026 <page_alloc+0x28>
    page_free_list = ret->pp_link;
f0101013:	8b 03                	mov    (%ebx),%eax
f0101015:	a3 40 02 33 f0       	mov    %eax,0xf0330240
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
f010102f:	2b 05 90 0e 33 f0    	sub    0xf0330e90,%eax
f0101035:	c1 f8 03             	sar    $0x3,%eax
f0101038:	89 c2                	mov    %eax,%edx
f010103a:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010103d:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101042:	3b 05 88 0e 33 f0    	cmp    0xf0330e88,%eax
f0101048:	73 1b                	jae    f0101065 <page_alloc+0x67>
        memset(p, 0, PGSIZE);
f010104a:	83 ec 04             	sub    $0x4,%esp
f010104d:	68 00 10 00 00       	push   $0x1000
f0101052:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0101054:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010105a:	52                   	push   %edx
f010105b:	e8 ac 4d 00 00       	call   f0105e0c <memset>
f0101060:	83 c4 10             	add    $0x10,%esp
f0101063:	eb c1                	jmp    f0101026 <page_alloc+0x28>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101065:	52                   	push   %edx
f0101066:	68 c4 6a 10 f0       	push   $0xf0106ac4
f010106b:	6a 58                	push   $0x58
f010106d:	68 9f 79 10 f0       	push   $0xf010799f
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
f0101090:	8b 15 40 02 33 f0    	mov    0xf0330240,%edx
f0101096:	89 10                	mov    %edx,(%eax)
    page_free_list = pp;
f0101098:	a3 40 02 33 f0       	mov    %eax,0xf0330240
}
f010109d:	c9                   	leave  
f010109e:	c3                   	ret    
        panic("Double free!");
f010109f:	83 ec 04             	sub    $0x4,%esp
f01010a2:	68 66 7a 10 f0       	push   $0xf0107a66
f01010a7:	68 9f 01 00 00       	push   $0x19f
f01010ac:	68 85 79 10 f0       	push   $0xf0107985
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
f010111b:	2b 05 90 0e 33 f0    	sub    0xf0330e90,%eax
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
f0101143:	3b 15 88 0e 33 f0    	cmp    0xf0330e88,%edx
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
f0101158:	68 c4 6a 10 f0       	push   $0xf0106ac4
f010115d:	68 df 01 00 00       	push   $0x1df
f0101162:	68 85 79 10 f0       	push   $0xf0107985
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
f0101214:	39 05 88 0e 33 f0    	cmp    %eax,0xf0330e88
f010121a:	76 0e                	jbe    f010122a <page_lookup+0x47>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f010121c:	8b 15 90 0e 33 f0    	mov    0xf0330e90,%edx
f0101222:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f0101225:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101228:	c9                   	leave  
f0101229:	c3                   	ret    
		panic("pa2page called with invalid pa");
f010122a:	83 ec 04             	sub    $0x4,%esp
f010122d:	68 4c 71 10 f0       	push   $0xf010714c
f0101232:	6a 51                	push   $0x51
f0101234:	68 9f 79 10 f0       	push   $0xf010799f
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
f010124f:	e8 d6 51 00 00       	call   f010642a <cpunum>
f0101254:	6b c0 74             	imul   $0x74,%eax,%eax
f0101257:	83 b8 28 10 33 f0 00 	cmpl   $0x0,-0xfccefd8(%eax)
f010125e:	74 16                	je     f0101276 <tlb_invalidate+0x31>
f0101260:	e8 c5 51 00 00       	call   f010642a <cpunum>
f0101265:	6b c0 74             	imul   $0x74,%eax,%eax
f0101268:	8b 80 28 10 33 f0    	mov    -0xfccefd8(%eax),%eax
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
f01012fe:	2b 1d 90 0e 33 f0    	sub    0xf0330e90,%ebx
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
f0101373:	8b 15 00 43 12 f0    	mov    0xf0124300,%edx
f0101379:	a1 8c 0e 33 f0       	mov    0xf0330e8c,%eax
f010137e:	e8 f0 fd ff ff       	call   f0101173 <boot_map_region>
    uintptr_t ret = base + pa_offset;
f0101383:	8b 15 00 43 12 f0    	mov    0xf0124300,%edx
    base = base + alloc_size;
f0101389:	01 d3                	add    %edx,%ebx
f010138b:	89 1d 00 43 12 f0    	mov    %ebx,0xf0124300
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
f01013e3:	89 15 88 0e 33 f0    	mov    %edx,0xf0330e88
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013e9:	89 c2                	mov    %eax,%edx
f01013eb:	29 da                	sub    %ebx,%edx
f01013ed:	52                   	push   %edx
f01013ee:	53                   	push   %ebx
f01013ef:	50                   	push   %eax
f01013f0:	68 6c 71 10 f0       	push   $0xf010716c
f01013f5:	e8 44 27 00 00       	call   f0103b3e <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01013fa:	b8 00 10 00 00       	mov    $0x1000,%eax
f01013ff:	e8 b8 f7 ff ff       	call   f0100bbc <boot_alloc>
f0101404:	a3 8c 0e 33 f0       	mov    %eax,0xf0330e8c
	memset(kern_pgdir, 0, PGSIZE);
f0101409:	83 c4 0c             	add    $0xc,%esp
f010140c:	68 00 10 00 00       	push   $0x1000
f0101411:	6a 00                	push   $0x0
f0101413:	50                   	push   %eax
f0101414:	e8 f3 49 00 00       	call   f0105e0c <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101419:	a1 8c 0e 33 f0       	mov    0xf0330e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f010141e:	83 c4 10             	add    $0x10,%esp
f0101421:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101426:	0f 86 9b 00 00 00    	jbe    f01014c7 <mem_init+0x126>
	return (physaddr_t)kva - KERNBASE;
f010142c:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101432:	83 ca 05             	or     $0x5,%edx
f0101435:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
    size_t alloc_size = ROUNDUP(sizeof(struct PageInfo) * npages, PGSIZE);
f010143b:	a1 88 0e 33 f0       	mov    0xf0330e88,%eax
f0101440:	8d 1c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ebx
f0101447:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    pages = (struct PageInfo *) boot_alloc(alloc_size);
f010144d:	89 d8                	mov    %ebx,%eax
f010144f:	e8 68 f7 ff ff       	call   f0100bbc <boot_alloc>
f0101454:	a3 90 0e 33 f0       	mov    %eax,0xf0330e90
    memset(pages, 0, alloc_size);
f0101459:	83 ec 04             	sub    $0x4,%esp
f010145c:	53                   	push   %ebx
f010145d:	6a 00                	push   $0x0
f010145f:	50                   	push   %eax
f0101460:	e8 a7 49 00 00       	call   f0105e0c <memset>
    envs = (struct Env *) boot_alloc(alloc_size);
f0101465:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f010146a:	e8 4d f7 ff ff       	call   f0100bbc <boot_alloc>
f010146f:	a3 44 02 33 f0       	mov    %eax,0xf0330244
    memset(envs, 0, alloc_size);
f0101474:	83 c4 0c             	add    $0xc,%esp
f0101477:	68 00 f0 01 00       	push   $0x1f000
f010147c:	6a 00                	push   $0x0
f010147e:	50                   	push   %eax
f010147f:	e8 88 49 00 00       	call   f0105e0c <memset>
	page_init();
f0101484:	e8 a9 fa ff ff       	call   f0100f32 <page_init>
	check_page_free_list(1);
f0101489:	b8 01 00 00 00       	mov    $0x1,%eax
f010148e:	e8 b1 f7 ff ff       	call   f0100c44 <check_page_free_list>
	if (!pages)
f0101493:	83 c4 10             	add    $0x10,%esp
f0101496:	83 3d 90 0e 33 f0 00 	cmpl   $0x0,0xf0330e90
f010149d:	74 3d                	je     f01014dc <mem_init+0x13b>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010149f:	a1 40 02 33 f0       	mov    0xf0330240,%eax
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
f01014c8:	68 e8 6a 10 f0       	push   $0xf0106ae8
f01014cd:	68 a5 00 00 00       	push   $0xa5
f01014d2:	68 85 79 10 f0       	push   $0xf0107985
f01014d7:	e8 64 eb ff ff       	call   f0100040 <_panic>
		panic("'pages' is a null pointer!");
f01014dc:	83 ec 04             	sub    $0x4,%esp
f01014df:	68 73 7a 10 f0       	push   $0xf0107a73
f01014e4:	68 49 03 00 00       	push   $0x349
f01014e9:	68 85 79 10 f0       	push   $0xf0107985
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
f0101550:	8b 0d 90 0e 33 f0    	mov    0xf0330e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101556:	8b 15 88 0e 33 f0    	mov    0xf0330e88,%edx
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
f0101595:	a1 40 02 33 f0       	mov    0xf0330240,%eax
f010159a:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010159d:	c7 05 40 02 33 f0 00 	movl   $0x0,0xf0330240
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
f010164b:	2b 05 90 0e 33 f0    	sub    0xf0330e90,%eax
f0101651:	c1 f8 03             	sar    $0x3,%eax
f0101654:	89 c2                	mov    %eax,%edx
f0101656:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101659:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010165e:	3b 05 88 0e 33 f0    	cmp    0xf0330e88,%eax
f0101664:	0f 83 28 02 00 00    	jae    f0101892 <mem_init+0x4f1>
	memset(page2kva(pp0), 1, PGSIZE);
f010166a:	83 ec 04             	sub    $0x4,%esp
f010166d:	68 00 10 00 00       	push   $0x1000
f0101672:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101674:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010167a:	52                   	push   %edx
f010167b:	e8 8c 47 00 00       	call   f0105e0c <memset>
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
f01016a7:	2b 05 90 0e 33 f0    	sub    0xf0330e90,%eax
f01016ad:	c1 f8 03             	sar    $0x3,%eax
f01016b0:	89 c2                	mov    %eax,%edx
f01016b2:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01016b5:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01016ba:	3b 05 88 0e 33 f0    	cmp    0xf0330e88,%eax
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
f01016e5:	a3 40 02 33 f0       	mov    %eax,0xf0330240
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
f0101703:	a1 40 02 33 f0       	mov    0xf0330240,%eax
f0101708:	83 c4 10             	add    $0x10,%esp
f010170b:	85 c0                	test   %eax,%eax
f010170d:	0f 84 ee 01 00 00    	je     f0101901 <mem_init+0x560>
		--nfree;
f0101713:	83 6d d4 01          	subl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101717:	8b 00                	mov    (%eax),%eax
f0101719:	eb f0                	jmp    f010170b <mem_init+0x36a>
	assert((pp0 = page_alloc(0)));
f010171b:	68 8e 7a 10 f0       	push   $0xf0107a8e
f0101720:	68 b9 79 10 f0       	push   $0xf01079b9
f0101725:	68 51 03 00 00       	push   $0x351
f010172a:	68 85 79 10 f0       	push   $0xf0107985
f010172f:	e8 0c e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101734:	68 a4 7a 10 f0       	push   $0xf0107aa4
f0101739:	68 b9 79 10 f0       	push   $0xf01079b9
f010173e:	68 52 03 00 00       	push   $0x352
f0101743:	68 85 79 10 f0       	push   $0xf0107985
f0101748:	e8 f3 e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010174d:	68 ba 7a 10 f0       	push   $0xf0107aba
f0101752:	68 b9 79 10 f0       	push   $0xf01079b9
f0101757:	68 53 03 00 00       	push   $0x353
f010175c:	68 85 79 10 f0       	push   $0xf0107985
f0101761:	e8 da e8 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101766:	68 d0 7a 10 f0       	push   $0xf0107ad0
f010176b:	68 b9 79 10 f0       	push   $0xf01079b9
f0101770:	68 56 03 00 00       	push   $0x356
f0101775:	68 85 79 10 f0       	push   $0xf0107985
f010177a:	e8 c1 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010177f:	68 a8 71 10 f0       	push   $0xf01071a8
f0101784:	68 b9 79 10 f0       	push   $0xf01079b9
f0101789:	68 57 03 00 00       	push   $0x357
f010178e:	68 85 79 10 f0       	push   $0xf0107985
f0101793:	e8 a8 e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101798:	68 e2 7a 10 f0       	push   $0xf0107ae2
f010179d:	68 b9 79 10 f0       	push   $0xf01079b9
f01017a2:	68 58 03 00 00       	push   $0x358
f01017a7:	68 85 79 10 f0       	push   $0xf0107985
f01017ac:	e8 8f e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01017b1:	68 ff 7a 10 f0       	push   $0xf0107aff
f01017b6:	68 b9 79 10 f0       	push   $0xf01079b9
f01017bb:	68 59 03 00 00       	push   $0x359
f01017c0:	68 85 79 10 f0       	push   $0xf0107985
f01017c5:	e8 76 e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01017ca:	68 1c 7b 10 f0       	push   $0xf0107b1c
f01017cf:	68 b9 79 10 f0       	push   $0xf01079b9
f01017d4:	68 5a 03 00 00       	push   $0x35a
f01017d9:	68 85 79 10 f0       	push   $0xf0107985
f01017de:	e8 5d e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01017e3:	68 39 7b 10 f0       	push   $0xf0107b39
f01017e8:	68 b9 79 10 f0       	push   $0xf01079b9
f01017ed:	68 61 03 00 00       	push   $0x361
f01017f2:	68 85 79 10 f0       	push   $0xf0107985
f01017f7:	e8 44 e8 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f01017fc:	68 8e 7a 10 f0       	push   $0xf0107a8e
f0101801:	68 b9 79 10 f0       	push   $0xf01079b9
f0101806:	68 68 03 00 00       	push   $0x368
f010180b:	68 85 79 10 f0       	push   $0xf0107985
f0101810:	e8 2b e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101815:	68 a4 7a 10 f0       	push   $0xf0107aa4
f010181a:	68 b9 79 10 f0       	push   $0xf01079b9
f010181f:	68 69 03 00 00       	push   $0x369
f0101824:	68 85 79 10 f0       	push   $0xf0107985
f0101829:	e8 12 e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010182e:	68 ba 7a 10 f0       	push   $0xf0107aba
f0101833:	68 b9 79 10 f0       	push   $0xf01079b9
f0101838:	68 6a 03 00 00       	push   $0x36a
f010183d:	68 85 79 10 f0       	push   $0xf0107985
f0101842:	e8 f9 e7 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101847:	68 d0 7a 10 f0       	push   $0xf0107ad0
f010184c:	68 b9 79 10 f0       	push   $0xf01079b9
f0101851:	68 6c 03 00 00       	push   $0x36c
f0101856:	68 85 79 10 f0       	push   $0xf0107985
f010185b:	e8 e0 e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101860:	68 a8 71 10 f0       	push   $0xf01071a8
f0101865:	68 b9 79 10 f0       	push   $0xf01079b9
f010186a:	68 6d 03 00 00       	push   $0x36d
f010186f:	68 85 79 10 f0       	push   $0xf0107985
f0101874:	e8 c7 e7 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101879:	68 39 7b 10 f0       	push   $0xf0107b39
f010187e:	68 b9 79 10 f0       	push   $0xf01079b9
f0101883:	68 6e 03 00 00       	push   $0x36e
f0101888:	68 85 79 10 f0       	push   $0xf0107985
f010188d:	e8 ae e7 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101892:	52                   	push   %edx
f0101893:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101898:	6a 58                	push   $0x58
f010189a:	68 9f 79 10 f0       	push   $0xf010799f
f010189f:	e8 9c e7 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01018a4:	68 48 7b 10 f0       	push   $0xf0107b48
f01018a9:	68 b9 79 10 f0       	push   $0xf01079b9
f01018ae:	68 73 03 00 00       	push   $0x373
f01018b3:	68 85 79 10 f0       	push   $0xf0107985
f01018b8:	e8 83 e7 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01018bd:	68 66 7b 10 f0       	push   $0xf0107b66
f01018c2:	68 b9 79 10 f0       	push   $0xf01079b9
f01018c7:	68 74 03 00 00       	push   $0x374
f01018cc:	68 85 79 10 f0       	push   $0xf0107985
f01018d1:	e8 6a e7 ff ff       	call   f0100040 <_panic>
f01018d6:	52                   	push   %edx
f01018d7:	68 c4 6a 10 f0       	push   $0xf0106ac4
f01018dc:	6a 58                	push   $0x58
f01018de:	68 9f 79 10 f0       	push   $0xf010799f
f01018e3:	e8 58 e7 ff ff       	call   f0100040 <_panic>
		assert(c[i] == 0);
f01018e8:	68 76 7b 10 f0       	push   $0xf0107b76
f01018ed:	68 b9 79 10 f0       	push   $0xf01079b9
f01018f2:	68 77 03 00 00       	push   $0x377
f01018f7:	68 85 79 10 f0       	push   $0xf0107985
f01018fc:	e8 3f e7 ff ff       	call   f0100040 <_panic>
	assert(nfree == 0);
f0101901:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0101905:	0f 85 e4 09 00 00    	jne    f01022ef <mem_init+0xf4e>
	cprintf("check_page_alloc() succeeded!\n");
f010190b:	83 ec 0c             	sub    $0xc,%esp
f010190e:	68 c8 71 10 f0       	push   $0xf01071c8
f0101913:	e8 26 22 00 00       	call   f0103b3e <cprintf>
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
f010197a:	a1 40 02 33 f0       	mov    0xf0330240,%eax
f010197f:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f0101982:	c7 05 40 02 33 f0 00 	movl   $0x0,0xf0330240
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
f01019aa:	ff 35 8c 0e 33 f0    	pushl  0xf0330e8c
f01019b0:	e8 2e f8 ff ff       	call   f01011e3 <page_lookup>
f01019b5:	83 c4 10             	add    $0x10,%esp
f01019b8:	85 c0                	test   %eax,%eax
f01019ba:	0f 85 de 09 00 00    	jne    f010239e <mem_init+0xffd>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01019c0:	6a 02                	push   $0x2
f01019c2:	6a 00                	push   $0x0
f01019c4:	57                   	push   %edi
f01019c5:	ff 35 8c 0e 33 f0    	pushl  0xf0330e8c
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
f01019eb:	ff 35 8c 0e 33 f0    	pushl  0xf0330e8c
f01019f1:	e8 d6 f8 ff ff       	call   f01012cc <page_insert>
f01019f6:	83 c4 20             	add    $0x20,%esp
f01019f9:	85 c0                	test   %eax,%eax
f01019fb:	0f 85 cf 09 00 00    	jne    f01023d0 <mem_init+0x102f>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101a01:	8b 35 8c 0e 33 f0    	mov    0xf0330e8c,%esi
	return (pp - pages) << PGSHIFT;
f0101a07:	8b 0d 90 0e 33 f0    	mov    0xf0330e90,%ecx
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
f0101a83:	a1 8c 0e 33 f0       	mov    0xf0330e8c,%eax
f0101a88:	e8 cc f0 ff ff       	call   f0100b59 <check_va2pa>
f0101a8d:	89 c2                	mov    %eax,%edx
f0101a8f:	89 d8                	mov    %ebx,%eax
f0101a91:	2b 05 90 0e 33 f0    	sub    0xf0330e90,%eax
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
f0101acd:	ff 35 8c 0e 33 f0    	pushl  0xf0330e8c
f0101ad3:	e8 f4 f7 ff ff       	call   f01012cc <page_insert>
f0101ad8:	83 c4 10             	add    $0x10,%esp
f0101adb:	85 c0                	test   %eax,%eax
f0101add:	0f 85 ce 09 00 00    	jne    f01024b1 <mem_init+0x1110>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ae3:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ae8:	a1 8c 0e 33 f0       	mov    0xf0330e8c,%eax
f0101aed:	e8 67 f0 ff ff       	call   f0100b59 <check_va2pa>
f0101af2:	89 c2                	mov    %eax,%edx
f0101af4:	89 d8                	mov    %ebx,%eax
f0101af6:	2b 05 90 0e 33 f0    	sub    0xf0330e90,%eax
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
f0101b2a:	8b 0d 8c 0e 33 f0    	mov    0xf0330e8c,%ecx
f0101b30:	8b 01                	mov    (%ecx),%eax
f0101b32:	89 c2                	mov    %eax,%edx
f0101b34:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101b3a:	c1 e8 0c             	shr    $0xc,%eax
f0101b3d:	3b 05 88 0e 33 f0    	cmp    0xf0330e88,%eax
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
f0101b7d:	ff 35 8c 0e 33 f0    	pushl  0xf0330e8c
f0101b83:	e8 44 f7 ff ff       	call   f01012cc <page_insert>
f0101b88:	83 c4 10             	add    $0x10,%esp
f0101b8b:	85 c0                	test   %eax,%eax
f0101b8d:	0f 85 b0 09 00 00    	jne    f0102543 <mem_init+0x11a2>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b93:	8b 35 8c 0e 33 f0    	mov    0xf0330e8c,%esi
f0101b99:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b9e:	89 f0                	mov    %esi,%eax
f0101ba0:	e8 b4 ef ff ff       	call   f0100b59 <check_va2pa>
f0101ba5:	89 c2                	mov    %eax,%edx
	return (pp - pages) << PGSHIFT;
f0101ba7:	89 d8                	mov    %ebx,%eax
f0101ba9:	2b 05 90 0e 33 f0    	sub    0xf0330e90,%eax
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
f0101be4:	a1 8c 0e 33 f0       	mov    0xf0330e8c,%eax
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
f0101c15:	ff 35 8c 0e 33 f0    	pushl  0xf0330e8c
f0101c1b:	e8 c3 f4 ff ff       	call   f01010e3 <pgdir_walk>
f0101c20:	83 c4 10             	add    $0x10,%esp
f0101c23:	f6 00 02             	testb  $0x2,(%eax)
f0101c26:	0f 84 ad 09 00 00    	je     f01025d9 <mem_init+0x1238>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c2c:	83 ec 04             	sub    $0x4,%esp
f0101c2f:	6a 00                	push   $0x0
f0101c31:	68 00 10 00 00       	push   $0x1000
f0101c36:	ff 35 8c 0e 33 f0    	pushl  0xf0330e8c
f0101c3c:	e8 a2 f4 ff ff       	call   f01010e3 <pgdir_walk>
f0101c41:	83 c4 10             	add    $0x10,%esp
f0101c44:	f6 00 04             	testb  $0x4,(%eax)
f0101c47:	0f 85 a5 09 00 00    	jne    f01025f2 <mem_init+0x1251>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101c4d:	6a 02                	push   $0x2
f0101c4f:	68 00 00 40 00       	push   $0x400000
f0101c54:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101c57:	ff 35 8c 0e 33 f0    	pushl  0xf0330e8c
f0101c5d:	e8 6a f6 ff ff       	call   f01012cc <page_insert>
f0101c62:	83 c4 10             	add    $0x10,%esp
f0101c65:	85 c0                	test   %eax,%eax
f0101c67:	0f 89 9e 09 00 00    	jns    f010260b <mem_init+0x126a>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101c6d:	6a 02                	push   $0x2
f0101c6f:	68 00 10 00 00       	push   $0x1000
f0101c74:	57                   	push   %edi
f0101c75:	ff 35 8c 0e 33 f0    	pushl  0xf0330e8c
f0101c7b:	e8 4c f6 ff ff       	call   f01012cc <page_insert>
f0101c80:	83 c4 10             	add    $0x10,%esp
f0101c83:	85 c0                	test   %eax,%eax
f0101c85:	0f 85 99 09 00 00    	jne    f0102624 <mem_init+0x1283>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c8b:	83 ec 04             	sub    $0x4,%esp
f0101c8e:	6a 00                	push   $0x0
f0101c90:	68 00 10 00 00       	push   $0x1000
f0101c95:	ff 35 8c 0e 33 f0    	pushl  0xf0330e8c
f0101c9b:	e8 43 f4 ff ff       	call   f01010e3 <pgdir_walk>
f0101ca0:	83 c4 10             	add    $0x10,%esp
f0101ca3:	f6 00 04             	testb  $0x4,(%eax)
f0101ca6:	0f 85 91 09 00 00    	jne    f010263d <mem_init+0x129c>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101cac:	a1 8c 0e 33 f0       	mov    0xf0330e8c,%eax
f0101cb1:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101cb4:	ba 00 00 00 00       	mov    $0x0,%edx
f0101cb9:	e8 9b ee ff ff       	call   f0100b59 <check_va2pa>
f0101cbe:	89 fe                	mov    %edi,%esi
f0101cc0:	2b 35 90 0e 33 f0    	sub    0xf0330e90,%esi
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
f0101d21:	ff 35 8c 0e 33 f0    	pushl  0xf0330e8c
f0101d27:	e8 52 f5 ff ff       	call   f010127e <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d2c:	8b 35 8c 0e 33 f0    	mov    0xf0330e8c,%esi
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
f0101d5a:	2b 05 90 0e 33 f0    	sub    0xf0330e90,%eax
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
f0101db9:	ff 35 8c 0e 33 f0    	pushl  0xf0330e8c
f0101dbf:	e8 ba f4 ff ff       	call   f010127e <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101dc4:	8b 35 8c 0e 33 f0    	mov    0xf0330e8c,%esi
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
f0101e3f:	8b 0d 8c 0e 33 f0    	mov    0xf0330e8c,%ecx
f0101e45:	8b 11                	mov    (%ecx),%edx
f0101e47:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101e4d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e50:	2b 05 90 0e 33 f0    	sub    0xf0330e90,%eax
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
f0101e94:	ff 35 8c 0e 33 f0    	pushl  0xf0330e8c
f0101e9a:	e8 44 f2 ff ff       	call   f01010e3 <pgdir_walk>
f0101e9f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101ea2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101ea5:	8b 0d 8c 0e 33 f0    	mov    0xf0330e8c,%ecx
f0101eab:	8b 41 04             	mov    0x4(%ecx),%eax
f0101eae:	89 c6                	mov    %eax,%esi
f0101eb0:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f0101eb6:	8b 15 88 0e 33 f0    	mov    0xf0330e88,%edx
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
f0101ee9:	2b 05 90 0e 33 f0    	sub    0xf0330e90,%eax
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
f0101f18:	e8 ef 3e 00 00       	call   f0105e0c <memset>
	page_free(pp0);
f0101f1d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101f20:	89 34 24             	mov    %esi,(%esp)
f0101f23:	e8 4f f1 ff ff       	call   f0101077 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101f28:	83 c4 0c             	add    $0xc,%esp
f0101f2b:	6a 01                	push   $0x1
f0101f2d:	6a 00                	push   $0x0
f0101f2f:	ff 35 8c 0e 33 f0    	pushl  0xf0330e8c
f0101f35:	e8 a9 f1 ff ff       	call   f01010e3 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101f3a:	89 f0                	mov    %esi,%eax
f0101f3c:	2b 05 90 0e 33 f0    	sub    0xf0330e90,%eax
f0101f42:	c1 f8 03             	sar    $0x3,%eax
f0101f45:	89 c2                	mov    %eax,%edx
f0101f47:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101f4a:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101f4f:	83 c4 10             	add    $0x10,%esp
f0101f52:	3b 05 88 0e 33 f0    	cmp    0xf0330e88,%eax
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
f0101f7d:	a1 8c 0e 33 f0       	mov    0xf0330e8c,%eax
f0101f82:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101f88:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f8b:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101f91:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101f94:	89 0d 40 02 33 f0    	mov    %ecx,0xf0330240

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
f010202b:	8b 3d 8c 0e 33 f0    	mov    0xf0330e8c,%edi
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
f01020a4:	ff 35 8c 0e 33 f0    	pushl  0xf0330e8c
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
f01020c5:	ff 35 8c 0e 33 f0    	pushl  0xf0330e8c
f01020cb:	e8 13 f0 ff ff       	call   f01010e3 <pgdir_walk>
f01020d0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f01020d6:	83 c4 0c             	add    $0xc,%esp
f01020d9:	6a 00                	push   $0x0
f01020db:	ff 75 d4             	pushl  -0x2c(%ebp)
f01020de:	ff 35 8c 0e 33 f0    	pushl  0xf0330e8c
f01020e4:	e8 fa ef ff ff       	call   f01010e3 <pgdir_walk>
f01020e9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f01020ef:	83 c4 0c             	add    $0xc,%esp
f01020f2:	6a 00                	push   $0x0
f01020f4:	56                   	push   %esi
f01020f5:	ff 35 8c 0e 33 f0    	pushl  0xf0330e8c
f01020fb:	e8 e3 ef ff ff       	call   f01010e3 <pgdir_walk>
f0102100:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102106:	c7 04 24 69 7c 10 f0 	movl   $0xf0107c69,(%esp)
f010210d:	e8 2c 1a 00 00       	call   f0103b3e <cprintf>
    size_t pages_size = ROUNDUP(sizeof(struct PageInfo) * npages, PGSIZE);
f0102112:	a1 88 0e 33 f0       	mov    0xf0330e88,%eax
f0102117:	8d 1c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ebx
f010211e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    boot_map_region(kern_pgdir, UPAGES, pages_size,
f0102124:	a1 90 0e 33 f0       	mov    0xf0330e90,%eax
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
f0102149:	a1 8c 0e 33 f0       	mov    0xf0330e8c,%eax
f010214e:	e8 20 f0 ff ff       	call   f0101173 <boot_map_region>
    boot_map_region(kern_pgdir, (uintptr_t)pages, pages_size,
f0102153:	8b 15 90 0e 33 f0    	mov    0xf0330e90,%edx
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
f0102176:	a1 8c 0e 33 f0       	mov    0xf0330e8c,%eax
f010217b:	e8 f3 ef ff ff       	call   f0101173 <boot_map_region>
    boot_map_region(kern_pgdir, UENVS, alloc_size,
f0102180:	a1 44 02 33 f0       	mov    0xf0330244,%eax
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
f01021a8:	a1 8c 0e 33 f0       	mov    0xf0330e8c,%eax
f01021ad:	e8 c1 ef ff ff       	call   f0101173 <boot_map_region>
    boot_map_region(kern_pgdir, (uintptr_t)envs, alloc_size,
f01021b2:	8b 15 44 02 33 f0    	mov    0xf0330244,%edx
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
f01021d8:	a1 8c 0e 33 f0       	mov    0xf0330e8c,%eax
f01021dd:	e8 91 ef ff ff       	call   f0101173 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f01021e2:	83 c4 10             	add    $0x10,%esp
f01021e5:	b8 00 a0 11 f0       	mov    $0xf011a000,%eax
f01021ea:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01021ef:	0f 86 0e 08 00 00    	jbe    f0102a03 <mem_init+0x1662>
    boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE,
f01021f5:	83 ec 08             	sub    $0x8,%esp
f01021f8:	6a 03                	push   $0x3
f01021fa:	68 00 a0 11 00       	push   $0x11a000
f01021ff:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102204:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102209:	a1 8c 0e 33 f0       	mov    0xf0330e8c,%eax
f010220e:	e8 60 ef ff ff       	call   f0101173 <boot_map_region>
    boot_map_region(kern_pgdir, KERNBASE, -KERNBASE,
f0102213:	83 c4 08             	add    $0x8,%esp
f0102216:	6a 03                	push   $0x3
f0102218:	6a 00                	push   $0x0
f010221a:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f010221f:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102224:	a1 8c 0e 33 f0       	mov    0xf0330e8c,%eax
f0102229:	e8 45 ef ff ff       	call   f0101173 <boot_map_region>
f010222e:	c7 45 d0 00 20 33 f0 	movl   $0xf0332000,-0x30(%ebp)
f0102235:	83 c4 10             	add    $0x10,%esp
f0102238:	bb 00 20 33 f0       	mov    $0xf0332000,%ebx
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
f0102261:	a1 8c 0e 33 f0       	mov    0xf0330e8c,%eax
f0102266:	e8 08 ef ff ff       	call   f0101173 <boot_map_region>
f010226b:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102271:	81 ee 00 00 01 00    	sub    $0x10000,%esi
    for (int i = 0; i < NCPU; ++i) {
f0102277:	83 c4 10             	add    $0x10,%esp
f010227a:	81 fb 00 20 37 f0    	cmp    $0xf0372000,%ebx
f0102280:	75 c0                	jne    f0102242 <mem_init+0xea1>
	pgdir = kern_pgdir;
f0102282:	a1 8c 0e 33 f0       	mov    0xf0330e8c,%eax
f0102287:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010228a:	a1 88 0e 33 f0       	mov    0xf0330e88,%eax
f010228f:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0102292:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102299:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010229e:	89 45 cc             	mov    %eax,-0x34(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01022a1:	8b 35 90 0e 33 f0    	mov    0xf0330e90,%esi
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
f01022ef:	68 80 7b 10 f0       	push   $0xf0107b80
f01022f4:	68 b9 79 10 f0       	push   $0xf01079b9
f01022f9:	68 84 03 00 00       	push   $0x384
f01022fe:	68 85 79 10 f0       	push   $0xf0107985
f0102303:	e8 38 dd ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0102308:	68 8e 7a 10 f0       	push   $0xf0107a8e
f010230d:	68 b9 79 10 f0       	push   $0xf01079b9
f0102312:	68 eb 03 00 00       	push   $0x3eb
f0102317:	68 85 79 10 f0       	push   $0xf0107985
f010231c:	e8 1f dd ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102321:	68 a4 7a 10 f0       	push   $0xf0107aa4
f0102326:	68 b9 79 10 f0       	push   $0xf01079b9
f010232b:	68 ec 03 00 00       	push   $0x3ec
f0102330:	68 85 79 10 f0       	push   $0xf0107985
f0102335:	e8 06 dd ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010233a:	68 ba 7a 10 f0       	push   $0xf0107aba
f010233f:	68 b9 79 10 f0       	push   $0xf01079b9
f0102344:	68 ed 03 00 00       	push   $0x3ed
f0102349:	68 85 79 10 f0       	push   $0xf0107985
f010234e:	e8 ed dc ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0102353:	68 d0 7a 10 f0       	push   $0xf0107ad0
f0102358:	68 b9 79 10 f0       	push   $0xf01079b9
f010235d:	68 f0 03 00 00       	push   $0x3f0
f0102362:	68 85 79 10 f0       	push   $0xf0107985
f0102367:	e8 d4 dc ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010236c:	68 a8 71 10 f0       	push   $0xf01071a8
f0102371:	68 b9 79 10 f0       	push   $0xf01079b9
f0102376:	68 f1 03 00 00       	push   $0x3f1
f010237b:	68 85 79 10 f0       	push   $0xf0107985
f0102380:	e8 bb dc ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102385:	68 39 7b 10 f0       	push   $0xf0107b39
f010238a:	68 b9 79 10 f0       	push   $0xf01079b9
f010238f:	68 f8 03 00 00       	push   $0x3f8
f0102394:	68 85 79 10 f0       	push   $0xf0107985
f0102399:	e8 a2 dc ff ff       	call   f0100040 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010239e:	68 e8 71 10 f0       	push   $0xf01071e8
f01023a3:	68 b9 79 10 f0       	push   $0xf01079b9
f01023a8:	68 fb 03 00 00       	push   $0x3fb
f01023ad:	68 85 79 10 f0       	push   $0xf0107985
f01023b2:	e8 89 dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01023b7:	68 20 72 10 f0       	push   $0xf0107220
f01023bc:	68 b9 79 10 f0       	push   $0xf01079b9
f01023c1:	68 fe 03 00 00       	push   $0x3fe
f01023c6:	68 85 79 10 f0       	push   $0xf0107985
f01023cb:	e8 70 dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01023d0:	68 50 72 10 f0       	push   $0xf0107250
f01023d5:	68 b9 79 10 f0       	push   $0xf01079b9
f01023da:	68 02 04 00 00       	push   $0x402
f01023df:	68 85 79 10 f0       	push   $0xf0107985
f01023e4:	e8 57 dc ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01023e9:	68 80 72 10 f0       	push   $0xf0107280
f01023ee:	68 b9 79 10 f0       	push   $0xf01079b9
f01023f3:	68 03 04 00 00       	push   $0x403
f01023f8:	68 85 79 10 f0       	push   $0xf0107985
f01023fd:	e8 3e dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102402:	68 a8 72 10 f0       	push   $0xf01072a8
f0102407:	68 b9 79 10 f0       	push   $0xf01079b9
f010240c:	68 04 04 00 00       	push   $0x404
f0102411:	68 85 79 10 f0       	push   $0xf0107985
f0102416:	e8 25 dc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010241b:	68 8b 7b 10 f0       	push   $0xf0107b8b
f0102420:	68 b9 79 10 f0       	push   $0xf01079b9
f0102425:	68 05 04 00 00       	push   $0x405
f010242a:	68 85 79 10 f0       	push   $0xf0107985
f010242f:	e8 0c dc ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102434:	68 9c 7b 10 f0       	push   $0xf0107b9c
f0102439:	68 b9 79 10 f0       	push   $0xf01079b9
f010243e:	68 06 04 00 00       	push   $0x406
f0102443:	68 85 79 10 f0       	push   $0xf0107985
f0102448:	e8 f3 db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010244d:	68 d8 72 10 f0       	push   $0xf01072d8
f0102452:	68 b9 79 10 f0       	push   $0xf01079b9
f0102457:	68 09 04 00 00       	push   $0x409
f010245c:	68 85 79 10 f0       	push   $0xf0107985
f0102461:	e8 da db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102466:	68 14 73 10 f0       	push   $0xf0107314
f010246b:	68 b9 79 10 f0       	push   $0xf01079b9
f0102470:	68 0a 04 00 00       	push   $0x40a
f0102475:	68 85 79 10 f0       	push   $0xf0107985
f010247a:	e8 c1 db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010247f:	68 ad 7b 10 f0       	push   $0xf0107bad
f0102484:	68 b9 79 10 f0       	push   $0xf01079b9
f0102489:	68 0b 04 00 00       	push   $0x40b
f010248e:	68 85 79 10 f0       	push   $0xf0107985
f0102493:	e8 a8 db ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102498:	68 39 7b 10 f0       	push   $0xf0107b39
f010249d:	68 b9 79 10 f0       	push   $0xf01079b9
f01024a2:	68 0e 04 00 00       	push   $0x40e
f01024a7:	68 85 79 10 f0       	push   $0xf0107985
f01024ac:	e8 8f db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01024b1:	68 d8 72 10 f0       	push   $0xf01072d8
f01024b6:	68 b9 79 10 f0       	push   $0xf01079b9
f01024bb:	68 11 04 00 00       	push   $0x411
f01024c0:	68 85 79 10 f0       	push   $0xf0107985
f01024c5:	e8 76 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01024ca:	68 14 73 10 f0       	push   $0xf0107314
f01024cf:	68 b9 79 10 f0       	push   $0xf01079b9
f01024d4:	68 12 04 00 00       	push   $0x412
f01024d9:	68 85 79 10 f0       	push   $0xf0107985
f01024de:	e8 5d db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01024e3:	68 ad 7b 10 f0       	push   $0xf0107bad
f01024e8:	68 b9 79 10 f0       	push   $0xf01079b9
f01024ed:	68 13 04 00 00       	push   $0x413
f01024f2:	68 85 79 10 f0       	push   $0xf0107985
f01024f7:	e8 44 db ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01024fc:	68 39 7b 10 f0       	push   $0xf0107b39
f0102501:	68 b9 79 10 f0       	push   $0xf01079b9
f0102506:	68 17 04 00 00       	push   $0x417
f010250b:	68 85 79 10 f0       	push   $0xf0107985
f0102510:	e8 2b db ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102515:	52                   	push   %edx
f0102516:	68 c4 6a 10 f0       	push   $0xf0106ac4
f010251b:	68 1a 04 00 00       	push   $0x41a
f0102520:	68 85 79 10 f0       	push   $0xf0107985
f0102525:	e8 16 db ff ff       	call   f0100040 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010252a:	68 44 73 10 f0       	push   $0xf0107344
f010252f:	68 b9 79 10 f0       	push   $0xf01079b9
f0102534:	68 1b 04 00 00       	push   $0x41b
f0102539:	68 85 79 10 f0       	push   $0xf0107985
f010253e:	e8 fd da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102543:	68 84 73 10 f0       	push   $0xf0107384
f0102548:	68 b9 79 10 f0       	push   $0xf01079b9
f010254d:	68 1e 04 00 00       	push   $0x41e
f0102552:	68 85 79 10 f0       	push   $0xf0107985
f0102557:	e8 e4 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010255c:	68 14 73 10 f0       	push   $0xf0107314
f0102561:	68 b9 79 10 f0       	push   $0xf01079b9
f0102566:	68 1f 04 00 00       	push   $0x41f
f010256b:	68 85 79 10 f0       	push   $0xf0107985
f0102570:	e8 cb da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102575:	68 ad 7b 10 f0       	push   $0xf0107bad
f010257a:	68 b9 79 10 f0       	push   $0xf01079b9
f010257f:	68 20 04 00 00       	push   $0x420
f0102584:	68 85 79 10 f0       	push   $0xf0107985
f0102589:	e8 b2 da ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010258e:	68 c4 73 10 f0       	push   $0xf01073c4
f0102593:	68 b9 79 10 f0       	push   $0xf01079b9
f0102598:	68 21 04 00 00       	push   $0x421
f010259d:	68 85 79 10 f0       	push   $0xf0107985
f01025a2:	e8 99 da ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01025a7:	68 be 7b 10 f0       	push   $0xf0107bbe
f01025ac:	68 b9 79 10 f0       	push   $0xf01079b9
f01025b1:	68 22 04 00 00       	push   $0x422
f01025b6:	68 85 79 10 f0       	push   $0xf0107985
f01025bb:	e8 80 da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01025c0:	68 d8 72 10 f0       	push   $0xf01072d8
f01025c5:	68 b9 79 10 f0       	push   $0xf01079b9
f01025ca:	68 25 04 00 00       	push   $0x425
f01025cf:	68 85 79 10 f0       	push   $0xf0107985
f01025d4:	e8 67 da ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01025d9:	68 f8 73 10 f0       	push   $0xf01073f8
f01025de:	68 b9 79 10 f0       	push   $0xf01079b9
f01025e3:	68 26 04 00 00       	push   $0x426
f01025e8:	68 85 79 10 f0       	push   $0xf0107985
f01025ed:	e8 4e da ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01025f2:	68 2c 74 10 f0       	push   $0xf010742c
f01025f7:	68 b9 79 10 f0       	push   $0xf01079b9
f01025fc:	68 27 04 00 00       	push   $0x427
f0102601:	68 85 79 10 f0       	push   $0xf0107985
f0102606:	e8 35 da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010260b:	68 64 74 10 f0       	push   $0xf0107464
f0102610:	68 b9 79 10 f0       	push   $0xf01079b9
f0102615:	68 2a 04 00 00       	push   $0x42a
f010261a:	68 85 79 10 f0       	push   $0xf0107985
f010261f:	e8 1c da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102624:	68 9c 74 10 f0       	push   $0xf010749c
f0102629:	68 b9 79 10 f0       	push   $0xf01079b9
f010262e:	68 2d 04 00 00       	push   $0x42d
f0102633:	68 85 79 10 f0       	push   $0xf0107985
f0102638:	e8 03 da ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010263d:	68 2c 74 10 f0       	push   $0xf010742c
f0102642:	68 b9 79 10 f0       	push   $0xf01079b9
f0102647:	68 2e 04 00 00       	push   $0x42e
f010264c:	68 85 79 10 f0       	push   $0xf0107985
f0102651:	e8 ea d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102656:	68 d8 74 10 f0       	push   $0xf01074d8
f010265b:	68 b9 79 10 f0       	push   $0xf01079b9
f0102660:	68 31 04 00 00       	push   $0x431
f0102665:	68 85 79 10 f0       	push   $0xf0107985
f010266a:	e8 d1 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010266f:	68 04 75 10 f0       	push   $0xf0107504
f0102674:	68 b9 79 10 f0       	push   $0xf01079b9
f0102679:	68 32 04 00 00       	push   $0x432
f010267e:	68 85 79 10 f0       	push   $0xf0107985
f0102683:	e8 b8 d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 2);
f0102688:	68 d4 7b 10 f0       	push   $0xf0107bd4
f010268d:	68 b9 79 10 f0       	push   $0xf01079b9
f0102692:	68 34 04 00 00       	push   $0x434
f0102697:	68 85 79 10 f0       	push   $0xf0107985
f010269c:	e8 9f d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01026a1:	68 e5 7b 10 f0       	push   $0xf0107be5
f01026a6:	68 b9 79 10 f0       	push   $0xf01079b9
f01026ab:	68 35 04 00 00       	push   $0x435
f01026b0:	68 85 79 10 f0       	push   $0xf0107985
f01026b5:	e8 86 d9 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f01026ba:	68 34 75 10 f0       	push   $0xf0107534
f01026bf:	68 b9 79 10 f0       	push   $0xf01079b9
f01026c4:	68 38 04 00 00       	push   $0x438
f01026c9:	68 85 79 10 f0       	push   $0xf0107985
f01026ce:	e8 6d d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01026d3:	68 58 75 10 f0       	push   $0xf0107558
f01026d8:	68 b9 79 10 f0       	push   $0xf01079b9
f01026dd:	68 3c 04 00 00       	push   $0x43c
f01026e2:	68 85 79 10 f0       	push   $0xf0107985
f01026e7:	e8 54 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01026ec:	68 04 75 10 f0       	push   $0xf0107504
f01026f1:	68 b9 79 10 f0       	push   $0xf01079b9
f01026f6:	68 3d 04 00 00       	push   $0x43d
f01026fb:	68 85 79 10 f0       	push   $0xf0107985
f0102700:	e8 3b d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102705:	68 8b 7b 10 f0       	push   $0xf0107b8b
f010270a:	68 b9 79 10 f0       	push   $0xf01079b9
f010270f:	68 3e 04 00 00       	push   $0x43e
f0102714:	68 85 79 10 f0       	push   $0xf0107985
f0102719:	e8 22 d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010271e:	68 e5 7b 10 f0       	push   $0xf0107be5
f0102723:	68 b9 79 10 f0       	push   $0xf01079b9
f0102728:	68 3f 04 00 00       	push   $0x43f
f010272d:	68 85 79 10 f0       	push   $0xf0107985
f0102732:	e8 09 d9 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102737:	68 7c 75 10 f0       	push   $0xf010757c
f010273c:	68 b9 79 10 f0       	push   $0xf01079b9
f0102741:	68 42 04 00 00       	push   $0x442
f0102746:	68 85 79 10 f0       	push   $0xf0107985
f010274b:	e8 f0 d8 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0102750:	68 f6 7b 10 f0       	push   $0xf0107bf6
f0102755:	68 b9 79 10 f0       	push   $0xf01079b9
f010275a:	68 43 04 00 00       	push   $0x443
f010275f:	68 85 79 10 f0       	push   $0xf0107985
f0102764:	e8 d7 d8 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102769:	68 02 7c 10 f0       	push   $0xf0107c02
f010276e:	68 b9 79 10 f0       	push   $0xf01079b9
f0102773:	68 44 04 00 00       	push   $0x444
f0102778:	68 85 79 10 f0       	push   $0xf0107985
f010277d:	e8 be d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102782:	68 58 75 10 f0       	push   $0xf0107558
f0102787:	68 b9 79 10 f0       	push   $0xf01079b9
f010278c:	68 48 04 00 00       	push   $0x448
f0102791:	68 85 79 10 f0       	push   $0xf0107985
f0102796:	e8 a5 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010279b:	68 b4 75 10 f0       	push   $0xf01075b4
f01027a0:	68 b9 79 10 f0       	push   $0xf01079b9
f01027a5:	68 49 04 00 00       	push   $0x449
f01027aa:	68 85 79 10 f0       	push   $0xf0107985
f01027af:	e8 8c d8 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01027b4:	68 17 7c 10 f0       	push   $0xf0107c17
f01027b9:	68 b9 79 10 f0       	push   $0xf01079b9
f01027be:	68 4a 04 00 00       	push   $0x44a
f01027c3:	68 85 79 10 f0       	push   $0xf0107985
f01027c8:	e8 73 d8 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01027cd:	68 e5 7b 10 f0       	push   $0xf0107be5
f01027d2:	68 b9 79 10 f0       	push   $0xf01079b9
f01027d7:	68 4b 04 00 00       	push   $0x44b
f01027dc:	68 85 79 10 f0       	push   $0xf0107985
f01027e1:	e8 5a d8 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f01027e6:	68 dc 75 10 f0       	push   $0xf01075dc
f01027eb:	68 b9 79 10 f0       	push   $0xf01079b9
f01027f0:	68 4e 04 00 00       	push   $0x44e
f01027f5:	68 85 79 10 f0       	push   $0xf0107985
f01027fa:	e8 41 d8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01027ff:	68 39 7b 10 f0       	push   $0xf0107b39
f0102804:	68 b9 79 10 f0       	push   $0xf01079b9
f0102809:	68 51 04 00 00       	push   $0x451
f010280e:	68 85 79 10 f0       	push   $0xf0107985
f0102813:	e8 28 d8 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102818:	68 80 72 10 f0       	push   $0xf0107280
f010281d:	68 b9 79 10 f0       	push   $0xf01079b9
f0102822:	68 54 04 00 00       	push   $0x454
f0102827:	68 85 79 10 f0       	push   $0xf0107985
f010282c:	e8 0f d8 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102831:	68 9c 7b 10 f0       	push   $0xf0107b9c
f0102836:	68 b9 79 10 f0       	push   $0xf01079b9
f010283b:	68 56 04 00 00       	push   $0x456
f0102840:	68 85 79 10 f0       	push   $0xf0107985
f0102845:	e8 f6 d7 ff ff       	call   f0100040 <_panic>
f010284a:	56                   	push   %esi
f010284b:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0102850:	68 5d 04 00 00       	push   $0x45d
f0102855:	68 85 79 10 f0       	push   $0xf0107985
f010285a:	e8 e1 d7 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010285f:	68 28 7c 10 f0       	push   $0xf0107c28
f0102864:	68 b9 79 10 f0       	push   $0xf01079b9
f0102869:	68 5e 04 00 00       	push   $0x45e
f010286e:	68 85 79 10 f0       	push   $0xf0107985
f0102873:	e8 c8 d7 ff ff       	call   f0100040 <_panic>
f0102878:	51                   	push   %ecx
f0102879:	68 c4 6a 10 f0       	push   $0xf0106ac4
f010287e:	6a 58                	push   $0x58
f0102880:	68 9f 79 10 f0       	push   $0xf010799f
f0102885:	e8 b6 d7 ff ff       	call   f0100040 <_panic>
f010288a:	52                   	push   %edx
f010288b:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0102890:	6a 58                	push   $0x58
f0102892:	68 9f 79 10 f0       	push   $0xf010799f
f0102897:	e8 a4 d7 ff ff       	call   f0100040 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f010289c:	68 40 7c 10 f0       	push   $0xf0107c40
f01028a1:	68 b9 79 10 f0       	push   $0xf01079b9
f01028a6:	68 68 04 00 00       	push   $0x468
f01028ab:	68 85 79 10 f0       	push   $0xf0107985
f01028b0:	e8 8b d7 ff ff       	call   f0100040 <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f01028b5:	68 00 76 10 f0       	push   $0xf0107600
f01028ba:	68 b9 79 10 f0       	push   $0xf01079b9
f01028bf:	68 78 04 00 00       	push   $0x478
f01028c4:	68 85 79 10 f0       	push   $0xf0107985
f01028c9:	e8 72 d7 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f01028ce:	68 28 76 10 f0       	push   $0xf0107628
f01028d3:	68 b9 79 10 f0       	push   $0xf01079b9
f01028d8:	68 79 04 00 00       	push   $0x479
f01028dd:	68 85 79 10 f0       	push   $0xf0107985
f01028e2:	e8 59 d7 ff ff       	call   f0100040 <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01028e7:	68 50 76 10 f0       	push   $0xf0107650
f01028ec:	68 b9 79 10 f0       	push   $0xf01079b9
f01028f1:	68 7b 04 00 00       	push   $0x47b
f01028f6:	68 85 79 10 f0       	push   $0xf0107985
f01028fb:	e8 40 d7 ff ff       	call   f0100040 <_panic>
	assert(mm1 + 8192 <= mm2);
f0102900:	68 57 7c 10 f0       	push   $0xf0107c57
f0102905:	68 b9 79 10 f0       	push   $0xf01079b9
f010290a:	68 7d 04 00 00       	push   $0x47d
f010290f:	68 85 79 10 f0       	push   $0xf0107985
f0102914:	e8 27 d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102919:	68 78 76 10 f0       	push   $0xf0107678
f010291e:	68 b9 79 10 f0       	push   $0xf01079b9
f0102923:	68 7f 04 00 00       	push   $0x47f
f0102928:	68 85 79 10 f0       	push   $0xf0107985
f010292d:	e8 0e d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102932:	68 9c 76 10 f0       	push   $0xf010769c
f0102937:	68 b9 79 10 f0       	push   $0xf01079b9
f010293c:	68 80 04 00 00       	push   $0x480
f0102941:	68 85 79 10 f0       	push   $0xf0107985
f0102946:	e8 f5 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f010294b:	68 cc 76 10 f0       	push   $0xf01076cc
f0102950:	68 b9 79 10 f0       	push   $0xf01079b9
f0102955:	68 81 04 00 00       	push   $0x481
f010295a:	68 85 79 10 f0       	push   $0xf0107985
f010295f:	e8 dc d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102964:	68 f0 76 10 f0       	push   $0xf01076f0
f0102969:	68 b9 79 10 f0       	push   $0xf01079b9
f010296e:	68 82 04 00 00       	push   $0x482
f0102973:	68 85 79 10 f0       	push   $0xf0107985
f0102978:	e8 c3 d6 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f010297d:	68 1c 77 10 f0       	push   $0xf010771c
f0102982:	68 b9 79 10 f0       	push   $0xf01079b9
f0102987:	68 84 04 00 00       	push   $0x484
f010298c:	68 85 79 10 f0       	push   $0xf0107985
f0102991:	e8 aa d6 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102996:	68 60 77 10 f0       	push   $0xf0107760
f010299b:	68 b9 79 10 f0       	push   $0xf01079b9
f01029a0:	68 85 04 00 00       	push   $0x485
f01029a5:	68 85 79 10 f0       	push   $0xf0107985
f01029aa:	e8 91 d6 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029af:	50                   	push   %eax
f01029b0:	68 e8 6a 10 f0       	push   $0xf0106ae8
f01029b5:	68 d1 00 00 00       	push   $0xd1
f01029ba:	68 85 79 10 f0       	push   $0xf0107985
f01029bf:	e8 7c d6 ff ff       	call   f0100040 <_panic>
f01029c4:	52                   	push   %edx
f01029c5:	68 e8 6a 10 f0       	push   $0xf0106ae8
f01029ca:	68 d4 00 00 00       	push   $0xd4
f01029cf:	68 85 79 10 f0       	push   $0xf0107985
f01029d4:	e8 67 d6 ff ff       	call   f0100040 <_panic>
f01029d9:	50                   	push   %eax
f01029da:	68 e8 6a 10 f0       	push   $0xf0106ae8
f01029df:	68 e0 00 00 00       	push   $0xe0
f01029e4:	68 85 79 10 f0       	push   $0xf0107985
f01029e9:	e8 52 d6 ff ff       	call   f0100040 <_panic>
f01029ee:	52                   	push   %edx
f01029ef:	68 e8 6a 10 f0       	push   $0xf0106ae8
f01029f4:	68 e2 00 00 00       	push   $0xe2
f01029f9:	68 85 79 10 f0       	push   $0xf0107985
f01029fe:	e8 3d d6 ff ff       	call   f0100040 <_panic>
f0102a03:	50                   	push   %eax
f0102a04:	68 e8 6a 10 f0       	push   $0xf0106ae8
f0102a09:	68 f0 00 00 00       	push   $0xf0
f0102a0e:	68 85 79 10 f0       	push   $0xf0107985
f0102a13:	e8 28 d6 ff ff       	call   f0100040 <_panic>
f0102a18:	53                   	push   %ebx
f0102a19:	68 e8 6a 10 f0       	push   $0xf0106ae8
f0102a1e:	68 34 01 00 00       	push   $0x134
f0102a23:	68 85 79 10 f0       	push   $0xf0107985
f0102a28:	e8 13 d6 ff ff       	call   f0100040 <_panic>
f0102a2d:	56                   	push   %esi
f0102a2e:	68 e8 6a 10 f0       	push   $0xf0106ae8
f0102a33:	68 9c 03 00 00       	push   $0x39c
f0102a38:	68 85 79 10 f0       	push   $0xf0107985
f0102a3d:	e8 fe d5 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102a42:	68 94 77 10 f0       	push   $0xf0107794
f0102a47:	68 b9 79 10 f0       	push   $0xf01079b9
f0102a4c:	68 9c 03 00 00       	push   $0x39c
f0102a51:	68 85 79 10 f0       	push   $0xf0107985
f0102a56:	e8 e5 d5 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102a5b:	a1 44 02 33 f0       	mov    0xf0330244,%eax
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
f0102ac2:	68 e8 6a 10 f0       	push   $0xf0106ae8
f0102ac7:	68 a1 03 00 00       	push   $0x3a1
f0102acc:	68 85 79 10 f0       	push   $0xf0107985
f0102ad1:	e8 6a d5 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102ad6:	68 c8 77 10 f0       	push   $0xf01077c8
f0102adb:	68 b9 79 10 f0       	push   $0xf01079b9
f0102ae0:	68 a1 03 00 00       	push   $0x3a1
f0102ae5:	68 85 79 10 f0       	push   $0xf0107985
f0102aea:	e8 51 d5 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102aef:	68 fc 77 10 f0       	push   $0xf01077fc
f0102af4:	68 b9 79 10 f0       	push   $0xf01079b9
f0102af9:	68 a5 03 00 00       	push   $0x3a5
f0102afe:	68 85 79 10 f0       	push   $0xf0107985
f0102b03:	e8 38 d5 ff ff       	call   f0100040 <_panic>
f0102b08:	c7 45 cc 00 20 34 00 	movl   $0x342000,-0x34(%ebp)
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
f0102b91:	3d 00 20 37 f0       	cmp    $0xf0372000,%eax
f0102b96:	0f 85 7b ff ff ff    	jne    f0102b17 <mem_init+0x1776>
f0102b9c:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0102b9f:	e9 84 00 00 00       	jmp    f0102c28 <mem_init+0x1887>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ba4:	ff 75 bc             	pushl  -0x44(%ebp)
f0102ba7:	68 e8 6a 10 f0       	push   $0xf0106ae8
f0102bac:	68 ae 03 00 00       	push   $0x3ae
f0102bb1:	68 85 79 10 f0       	push   $0xf0107985
f0102bb6:	e8 85 d4 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102bbb:	68 24 78 10 f0       	push   $0xf0107824
f0102bc0:	68 b9 79 10 f0       	push   $0xf01079b9
f0102bc5:	68 ad 03 00 00       	push   $0x3ad
f0102bca:	68 85 79 10 f0       	push   $0xf0107985
f0102bcf:	e8 6c d4 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102bd4:	68 6c 78 10 f0       	push   $0xf010786c
f0102bd9:	68 b9 79 10 f0       	push   $0xf01079b9
f0102bde:	68 b0 03 00 00       	push   $0x3b0
f0102be3:	68 85 79 10 f0       	push   $0xf0107985
f0102be8:	e8 53 d4 ff ff       	call   f0100040 <_panic>
			assert(pgdir[i] & PTE_P);
f0102bed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102bf0:	f6 04 b8 01          	testb  $0x1,(%eax,%edi,4)
f0102bf4:	75 4e                	jne    f0102c44 <mem_init+0x18a3>
f0102bf6:	68 82 7c 10 f0       	push   $0xf0107c82
f0102bfb:	68 b9 79 10 f0       	push   $0xf01079b9
f0102c00:	68 bb 03 00 00       	push   $0x3bb
f0102c05:	68 85 79 10 f0       	push   $0xf0107985
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
f0102c49:	68 82 7c 10 f0       	push   $0xf0107c82
f0102c4e:	68 b9 79 10 f0       	push   $0xf01079b9
f0102c53:	68 bf 03 00 00       	push   $0x3bf
f0102c58:	68 85 79 10 f0       	push   $0xf0107985
f0102c5d:	e8 de d3 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102c62:	68 93 7c 10 f0       	push   $0xf0107c93
f0102c67:	68 b9 79 10 f0       	push   $0xf01079b9
f0102c6c:	68 c0 03 00 00       	push   $0x3c0
f0102c71:	68 85 79 10 f0       	push   $0xf0107985
f0102c76:	e8 c5 d3 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] == 0);
f0102c7b:	68 a4 7c 10 f0       	push   $0xf0107ca4
f0102c80:	68 b9 79 10 f0       	push   $0xf01079b9
f0102c85:	68 c2 03 00 00       	push   $0x3c2
f0102c8a:	68 85 79 10 f0       	push   $0xf0107985
f0102c8f:	e8 ac d3 ff ff       	call   f0100040 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102c94:	83 ec 0c             	sub    $0xc,%esp
f0102c97:	68 90 78 10 f0       	push   $0xf0107890
f0102c9c:	e8 9d 0e 00 00       	call   f0103b3e <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102ca1:	a1 8c 0e 33 f0       	mov    0xf0330e8c,%eax
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
f0102d24:	2b 05 90 0e 33 f0    	sub    0xf0330e90,%eax
f0102d2a:	c1 f8 03             	sar    $0x3,%eax
f0102d2d:	89 c2                	mov    %eax,%edx
f0102d2f:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102d32:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102d37:	83 c4 10             	add    $0x10,%esp
f0102d3a:	3b 05 88 0e 33 f0    	cmp    0xf0330e88,%eax
f0102d40:	0f 83 d1 01 00 00    	jae    f0102f17 <mem_init+0x1b76>
	memset(page2kva(pp1), 1, PGSIZE);
f0102d46:	83 ec 04             	sub    $0x4,%esp
f0102d49:	68 00 10 00 00       	push   $0x1000
f0102d4e:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102d50:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102d56:	52                   	push   %edx
f0102d57:	e8 b0 30 00 00       	call   f0105e0c <memset>
	return (pp - pages) << PGSHIFT;
f0102d5c:	89 d8                	mov    %ebx,%eax
f0102d5e:	2b 05 90 0e 33 f0    	sub    0xf0330e90,%eax
f0102d64:	c1 f8 03             	sar    $0x3,%eax
f0102d67:	89 c2                	mov    %eax,%edx
f0102d69:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102d6c:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102d71:	83 c4 10             	add    $0x10,%esp
f0102d74:	3b 05 88 0e 33 f0    	cmp    0xf0330e88,%eax
f0102d7a:	0f 83 a9 01 00 00    	jae    f0102f29 <mem_init+0x1b88>
	memset(page2kva(pp2), 2, PGSIZE);
f0102d80:	83 ec 04             	sub    $0x4,%esp
f0102d83:	68 00 10 00 00       	push   $0x1000
f0102d88:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102d8a:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102d90:	52                   	push   %edx
f0102d91:	e8 76 30 00 00       	call   f0105e0c <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102d96:	6a 02                	push   $0x2
f0102d98:	68 00 10 00 00       	push   $0x1000
f0102d9d:	57                   	push   %edi
f0102d9e:	ff 35 8c 0e 33 f0    	pushl  0xf0330e8c
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
f0102dcf:	ff 35 8c 0e 33 f0    	pushl  0xf0330e8c
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
f0102e0f:	2b 05 90 0e 33 f0    	sub    0xf0330e90,%eax
f0102e15:	c1 f8 03             	sar    $0x3,%eax
f0102e18:	89 c2                	mov    %eax,%edx
f0102e1a:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102e1d:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102e22:	3b 05 88 0e 33 f0    	cmp    0xf0330e88,%eax
f0102e28:	0f 83 8a 01 00 00    	jae    f0102fb8 <mem_init+0x1c17>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102e2e:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f0102e35:	03 03 03 
f0102e38:	0f 85 8c 01 00 00    	jne    f0102fca <mem_init+0x1c29>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102e3e:	83 ec 08             	sub    $0x8,%esp
f0102e41:	68 00 10 00 00       	push   $0x1000
f0102e46:	ff 35 8c 0e 33 f0    	pushl  0xf0330e8c
f0102e4c:	e8 2d e4 ff ff       	call   f010127e <page_remove>
	assert(pp2->pp_ref == 0);
f0102e51:	83 c4 10             	add    $0x10,%esp
f0102e54:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102e59:	0f 85 84 01 00 00    	jne    f0102fe3 <mem_init+0x1c42>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102e5f:	8b 0d 8c 0e 33 f0    	mov    0xf0330e8c,%ecx
f0102e65:	8b 11                	mov    (%ecx),%edx
f0102e67:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102e6d:	89 f0                	mov    %esi,%eax
f0102e6f:	2b 05 90 0e 33 f0    	sub    0xf0330e90,%eax
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
f0102ea3:	c7 04 24 24 79 10 f0 	movl   $0xf0107924,(%esp)
f0102eaa:	e8 8f 0c 00 00       	call   f0103b3e <cprintf>
}
f0102eaf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102eb2:	5b                   	pop    %ebx
f0102eb3:	5e                   	pop    %esi
f0102eb4:	5f                   	pop    %edi
f0102eb5:	5d                   	pop    %ebp
f0102eb6:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102eb7:	50                   	push   %eax
f0102eb8:	68 e8 6a 10 f0       	push   $0xf0106ae8
f0102ebd:	68 0a 01 00 00       	push   $0x10a
f0102ec2:	68 85 79 10 f0       	push   $0xf0107985
f0102ec7:	e8 74 d1 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0102ecc:	68 8e 7a 10 f0       	push   $0xf0107a8e
f0102ed1:	68 b9 79 10 f0       	push   $0xf01079b9
f0102ed6:	68 9a 04 00 00       	push   $0x49a
f0102edb:	68 85 79 10 f0       	push   $0xf0107985
f0102ee0:	e8 5b d1 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102ee5:	68 a4 7a 10 f0       	push   $0xf0107aa4
f0102eea:	68 b9 79 10 f0       	push   $0xf01079b9
f0102eef:	68 9b 04 00 00       	push   $0x49b
f0102ef4:	68 85 79 10 f0       	push   $0xf0107985
f0102ef9:	e8 42 d1 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102efe:	68 ba 7a 10 f0       	push   $0xf0107aba
f0102f03:	68 b9 79 10 f0       	push   $0xf01079b9
f0102f08:	68 9c 04 00 00       	push   $0x49c
f0102f0d:	68 85 79 10 f0       	push   $0xf0107985
f0102f12:	e8 29 d1 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f17:	52                   	push   %edx
f0102f18:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0102f1d:	6a 58                	push   $0x58
f0102f1f:	68 9f 79 10 f0       	push   $0xf010799f
f0102f24:	e8 17 d1 ff ff       	call   f0100040 <_panic>
f0102f29:	52                   	push   %edx
f0102f2a:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0102f2f:	6a 58                	push   $0x58
f0102f31:	68 9f 79 10 f0       	push   $0xf010799f
f0102f36:	e8 05 d1 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102f3b:	68 8b 7b 10 f0       	push   $0xf0107b8b
f0102f40:	68 b9 79 10 f0       	push   $0xf01079b9
f0102f45:	68 a1 04 00 00       	push   $0x4a1
f0102f4a:	68 85 79 10 f0       	push   $0xf0107985
f0102f4f:	e8 ec d0 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102f54:	68 b0 78 10 f0       	push   $0xf01078b0
f0102f59:	68 b9 79 10 f0       	push   $0xf01079b9
f0102f5e:	68 a2 04 00 00       	push   $0x4a2
f0102f63:	68 85 79 10 f0       	push   $0xf0107985
f0102f68:	e8 d3 d0 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102f6d:	68 d4 78 10 f0       	push   $0xf01078d4
f0102f72:	68 b9 79 10 f0       	push   $0xf01079b9
f0102f77:	68 a4 04 00 00       	push   $0x4a4
f0102f7c:	68 85 79 10 f0       	push   $0xf0107985
f0102f81:	e8 ba d0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102f86:	68 ad 7b 10 f0       	push   $0xf0107bad
f0102f8b:	68 b9 79 10 f0       	push   $0xf01079b9
f0102f90:	68 a5 04 00 00       	push   $0x4a5
f0102f95:	68 85 79 10 f0       	push   $0xf0107985
f0102f9a:	e8 a1 d0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102f9f:	68 17 7c 10 f0       	push   $0xf0107c17
f0102fa4:	68 b9 79 10 f0       	push   $0xf01079b9
f0102fa9:	68 a6 04 00 00       	push   $0x4a6
f0102fae:	68 85 79 10 f0       	push   $0xf0107985
f0102fb3:	e8 88 d0 ff ff       	call   f0100040 <_panic>
f0102fb8:	52                   	push   %edx
f0102fb9:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0102fbe:	6a 58                	push   $0x58
f0102fc0:	68 9f 79 10 f0       	push   $0xf010799f
f0102fc5:	e8 76 d0 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102fca:	68 f8 78 10 f0       	push   $0xf01078f8
f0102fcf:	68 b9 79 10 f0       	push   $0xf01079b9
f0102fd4:	68 a8 04 00 00       	push   $0x4a8
f0102fd9:	68 85 79 10 f0       	push   $0xf0107985
f0102fde:	e8 5d d0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102fe3:	68 e5 7b 10 f0       	push   $0xf0107be5
f0102fe8:	68 b9 79 10 f0       	push   $0xf01079b9
f0102fed:	68 aa 04 00 00       	push   $0x4aa
f0102ff2:	68 85 79 10 f0       	push   $0xf0107985
f0102ff7:	e8 44 d0 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102ffc:	68 80 72 10 f0       	push   $0xf0107280
f0103001:	68 b9 79 10 f0       	push   $0xf01079b9
f0103006:	68 ad 04 00 00       	push   $0x4ad
f010300b:	68 85 79 10 f0       	push   $0xf0107985
f0103010:	e8 2b d0 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0103015:	68 9c 7b 10 f0       	push   $0xf0107b9c
f010301a:	68 b9 79 10 f0       	push   $0xf01079b9
f010301f:	68 af 04 00 00       	push   $0x4af
f0103024:	68 85 79 10 f0       	push   $0xf0107985
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
f0103098:	89 1d 3c 02 33 f0    	mov    %ebx,0xf033023c
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
f01030d1:	89 1d 3c 02 33 f0    	mov    %ebx,0xf033023c
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
f010311b:	ff 35 3c 02 33 f0    	pushl  0xf033023c
f0103121:	ff 73 48             	pushl  0x48(%ebx)
f0103124:	68 50 79 10 f0       	push   $0xf0107950
f0103129:	e8 10 0a 00 00       	call   f0103b3e <cprintf>
		env_destroy(env);	// may not return
f010312e:	89 1c 24             	mov    %ebx,(%esp)
f0103131:	e8 d1 06 00 00       	call   f0103807 <env_destroy>
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
f0103166:	68 b4 7c 10 f0       	push   $0xf0107cb4
f010316b:	68 2c 01 00 00       	push   $0x12c
f0103170:	68 60 7d 10 f0       	push   $0xf0107d60
f0103175:	e8 c6 ce ff ff       	call   f0100040 <_panic>
        }

        pp = page_alloc(0);

        if (pp == NULL) {
            panic("region_alloc: out-of-memory!\n");
f010317a:	83 ec 04             	sub    $0x4,%esp
f010317d:	68 6b 7d 10 f0       	push   $0xf0107d6b
f0103182:	68 3a 01 00 00       	push   $0x13a
f0103187:	68 60 7d 10 f0       	push   $0xf0107d60
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
f01031dc:	68 e8 7c 10 f0       	push   $0xf0107ce8
f01031e1:	68 3e 01 00 00       	push   $0x13e
f01031e6:	68 60 7d 10 f0       	push   $0xf0107d60
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
f0103216:	03 1d 44 02 33 f0    	add    0xf0330244,%ebx
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
f0103239:	e8 ec 31 00 00       	call   f010642a <cpunum>
f010323e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103241:	8b 80 28 10 33 f0    	mov    -0xfccefd8(%eax),%eax
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
f0103260:	e8 c5 31 00 00       	call   f010642a <cpunum>
f0103265:	6b c0 74             	imul   $0x74,%eax,%eax
f0103268:	39 98 28 10 33 f0    	cmp    %ebx,-0xfccefd8(%eax)
f010326e:	74 bb                	je     f010322b <envid2env+0x33>
f0103270:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103273:	e8 b2 31 00 00       	call   f010642a <cpunum>
f0103278:	6b c0 74             	imul   $0x74,%eax,%eax
f010327b:	8b 80 28 10 33 f0    	mov    -0xfccefd8(%eax),%eax
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
f010329a:	b8 20 43 12 f0       	mov    $0xf0124320,%eax
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
f01032d9:	ff 35 44 02 33 f0    	pushl  0xf0330244
f01032df:	e8 28 2b 00 00       	call   f0105e0c <memset>
        envs[i].env_link = env_free_list;
f01032e4:	8b 35 44 02 33 f0    	mov    0xf0330244,%esi
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
f0103308:	89 35 48 02 33 f0    	mov    %esi,0xf0330248
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
f0103325:	8b 1d 48 02 33 f0    	mov    0xf0330248,%ebx
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
f010334d:	2b 05 90 0e 33 f0    	sub    0xf0330e90,%eax
f0103353:	c1 f8 03             	sar    $0x3,%eax
f0103356:	89 c2                	mov    %eax,%edx
f0103358:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010335b:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0103360:	3b 05 88 0e 33 f0    	cmp    0xf0330e88,%eax
f0103366:	0f 83 1e 01 00 00    	jae    f010348a <env_alloc+0x170>
	return (void *)(pa + KERNBASE);
f010336c:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103372:	89 53 60             	mov    %edx,0x60(%ebx)
    e->env_pgdir = page2kva(p);
f0103375:	b8 ec 0e 00 00       	mov    $0xeec,%eax
        e->env_pgdir[i] = kern_pgdir[i];
f010337a:	8b 15 8c 0e 33 f0    	mov    0xf0330e8c,%edx
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
f01033c7:	2b 15 44 02 33 f0    	sub    0xf0330244,%edx
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
f01033fe:	e8 09 2a 00 00       	call   f0105e0c <memset>
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
f0103437:	a3 48 02 33 f0       	mov    %eax,0xf0330248
	*newenv_store = e;
f010343c:	8b 45 08             	mov    0x8(%ebp),%eax
f010343f:	89 18                	mov    %ebx,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103441:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103444:	e8 e1 2f 00 00       	call   f010642a <cpunum>
f0103449:	6b c0 74             	imul   $0x74,%eax,%eax
f010344c:	83 c4 10             	add    $0x10,%esp
f010344f:	ba 00 00 00 00       	mov    $0x0,%edx
f0103454:	83 b8 28 10 33 f0 00 	cmpl   $0x0,-0xfccefd8(%eax)
f010345b:	74 11                	je     f010346e <env_alloc+0x154>
f010345d:	e8 c8 2f 00 00       	call   f010642a <cpunum>
f0103462:	6b c0 74             	imul   $0x74,%eax,%eax
f0103465:	8b 80 28 10 33 f0    	mov    -0xfccefd8(%eax),%eax
f010346b:	8b 50 48             	mov    0x48(%eax),%edx
f010346e:	83 ec 04             	sub    $0x4,%esp
f0103471:	53                   	push   %ebx
f0103472:	52                   	push   %edx
f0103473:	68 89 7d 10 f0       	push   $0xf0107d89
f0103478:	e8 c1 06 00 00       	call   f0103b3e <cprintf>
	return 0;
f010347d:	83 c4 10             	add    $0x10,%esp
f0103480:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103485:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103488:	c9                   	leave  
f0103489:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010348a:	52                   	push   %edx
f010348b:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0103490:	6a 58                	push   $0x58
f0103492:	68 9f 79 10 f0       	push   $0xf010799f
f0103497:	e8 a4 cb ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010349c:	50                   	push   %eax
f010349d:	68 e8 6a 10 f0       	push   $0xf0106ae8
f01034a2:	68 c8 00 00 00       	push   $0xc8
f01034a7:	68 60 7d 10 f0       	push   $0xf0107d60
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
f01034cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// LAB 3: Your code here.

	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.
    struct Env *new_env = NULL;
f01034d2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    int ret = env_alloc(&new_env, 0);
f01034d9:	6a 00                	push   $0x0
f01034db:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01034de:	50                   	push   %eax
f01034df:	e8 36 fe ff ff       	call   f010331a <env_alloc>
    if (ret == -E_NO_FREE_ENV) {
f01034e4:	83 c4 10             	add    $0x10,%esp
f01034e7:	83 f8 fb             	cmp    $0xfffffffb,%eax
f01034ea:	74 4d                	je     f0103539 <env_create+0x7a>
        panic("all NENV environments are allocated!\n");
    }
    else if (ret == -E_NO_MEM) {
f01034ec:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01034ef:	74 5f                	je     f0103550 <env_create+0x91>
        panic("not enouth memory!\n");
    }
    else if (new_env == NULL) {
f01034f1:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01034f4:	85 f6                	test   %esi,%esi
f01034f6:	74 6f                	je     f0103567 <env_create+0xa8>
        panic("new env is not allocated!\n");
    }

    new_env->env_type = type;
f01034f8:	89 5e 50             	mov    %ebx,0x50(%esi)
    if (type == ENV_TYPE_FS) new_env->env_tf.tf_eflags |= FL_IOPL_3;
f01034fb:	83 fb 01             	cmp    $0x1,%ebx
f01034fe:	74 7e                	je     f010357e <env_create+0xbf>
	asm volatile("movl %%cr3,%0" : "=r" (val));
f0103500:	0f 20 d8             	mov    %cr3,%eax
f0103503:	89 45 cc             	mov    %eax,-0x34(%ebp)
    lcr3(PADDR(e->env_pgdir));
f0103506:	8b 46 60             	mov    0x60(%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f0103509:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010350e:	76 7a                	jbe    f010358a <env_create+0xcb>
	return (physaddr_t)kva - KERNBASE;
f0103510:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103515:	0f 22 d8             	mov    %eax,%cr3
    if (elf->e_magic != ELF_MAGIC) {
f0103518:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f010351e:	75 7f                	jne    f010359f <env_create+0xe0>
    uintptr_t elf_base = (uintptr_t) elf;
f0103520:	89 7d d4             	mov    %edi,-0x2c(%ebp)
    ph = (struct Proghdr *) (elf_base + elf->e_phoff);
f0103523:	89 fb                	mov    %edi,%ebx
f0103525:	03 5f 1c             	add    0x1c(%edi),%ebx
    eph = ph + elf->e_phnum;
f0103528:	0f b7 47 2c          	movzwl 0x2c(%edi),%eax
f010352c:	c1 e0 05             	shl    $0x5,%eax
f010352f:	01 d8                	add    %ebx,%eax
f0103531:	89 45 d0             	mov    %eax,-0x30(%ebp)
    for (; ph < eph; ++ph) {
f0103534:	e9 b5 00 00 00       	jmp    f01035ee <env_create+0x12f>
        panic("all NENV environments are allocated!\n");
f0103539:	83 ec 04             	sub    $0x4,%esp
f010353c:	68 18 7d 10 f0       	push   $0xf0107d18
f0103541:	68 b1 01 00 00       	push   $0x1b1
f0103546:	68 60 7d 10 f0       	push   $0xf0107d60
f010354b:	e8 f0 ca ff ff       	call   f0100040 <_panic>
        panic("not enouth memory!\n");
f0103550:	83 ec 04             	sub    $0x4,%esp
f0103553:	68 9e 7d 10 f0       	push   $0xf0107d9e
f0103558:	68 b4 01 00 00       	push   $0x1b4
f010355d:	68 60 7d 10 f0       	push   $0xf0107d60
f0103562:	e8 d9 ca ff ff       	call   f0100040 <_panic>
        panic("new env is not allocated!\n");
f0103567:	83 ec 04             	sub    $0x4,%esp
f010356a:	68 b2 7d 10 f0       	push   $0xf0107db2
f010356f:	68 b7 01 00 00       	push   $0x1b7
f0103574:	68 60 7d 10 f0       	push   $0xf0107d60
f0103579:	e8 c2 ca ff ff       	call   f0100040 <_panic>
    if (type == ENV_TYPE_FS) new_env->env_tf.tf_eflags |= FL_IOPL_3;
f010357e:	81 4e 38 00 30 00 00 	orl    $0x3000,0x38(%esi)
f0103585:	e9 76 ff ff ff       	jmp    f0103500 <env_create+0x41>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010358a:	50                   	push   %eax
f010358b:	68 e8 6a 10 f0       	push   $0xf0106ae8
f0103590:	68 7b 01 00 00       	push   $0x17b
f0103595:	68 60 7d 10 f0       	push   $0xf0107d60
f010359a:	e8 a1 ca ff ff       	call   f0100040 <_panic>
        panic("load_icode: not an ELF binary!\n");
f010359f:	83 ec 04             	sub    $0x4,%esp
f01035a2:	68 40 7d 10 f0       	push   $0xf0107d40
f01035a7:	68 81 01 00 00       	push   $0x181
f01035ac:	68 60 7d 10 f0       	push   $0xf0107d60
f01035b1:	e8 8a ca ff ff       	call   f0100040 <_panic>
            region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f01035b6:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01035b9:	8b 53 08             	mov    0x8(%ebx),%edx
f01035bc:	89 f0                	mov    %esi,%eax
f01035be:	e8 78 fb ff ff       	call   f010313b <region_alloc>
            memset((void *)ph->p_va, 0, ph->p_memsz);
f01035c3:	83 ec 04             	sub    $0x4,%esp
f01035c6:	ff 73 14             	pushl  0x14(%ebx)
f01035c9:	6a 00                	push   $0x0
f01035cb:	ff 73 08             	pushl  0x8(%ebx)
f01035ce:	e8 39 28 00 00       	call   f0105e0c <memset>
            memcpy((void *)ph->p_va, (void *)(elf_base + ph->p_offset), ph->p_filesz);
f01035d3:	83 c4 0c             	add    $0xc,%esp
f01035d6:	ff 73 10             	pushl  0x10(%ebx)
f01035d9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01035dc:	03 43 04             	add    0x4(%ebx),%eax
f01035df:	50                   	push   %eax
f01035e0:	ff 73 08             	pushl  0x8(%ebx)
f01035e3:	e8 d6 28 00 00       	call   f0105ebe <memcpy>
f01035e8:	83 c4 10             	add    $0x10,%esp
    for (; ph < eph; ++ph) {
f01035eb:	83 c3 20             	add    $0x20,%ebx
f01035ee:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f01035f1:	76 07                	jbe    f01035fa <env_create+0x13b>
        if (ph->p_type == ELF_PROG_LOAD) {
f01035f3:	83 3b 01             	cmpl   $0x1,(%ebx)
f01035f6:	75 f3                	jne    f01035eb <env_create+0x12c>
f01035f8:	eb bc                	jmp    f01035b6 <env_create+0xf7>
    e->env_tf.tf_eip = elf->e_entry;
f01035fa:	8b 47 18             	mov    0x18(%edi),%eax
f01035fd:	89 46 30             	mov    %eax,0x30(%esi)
    region_alloc(e, (void *)(USTACKTOP-PGSIZE), PGSIZE);
f0103600:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103605:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010360a:	89 f0                	mov    %esi,%eax
f010360c:	e8 2a fb ff ff       	call   f010313b <region_alloc>
    e->env_tf.tf_esp = USTACKTOP;
f0103611:	c7 46 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%esi)
f0103618:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010361b:	0f 22 d8             	mov    %eax,%cr3
    load_icode(new_env, binary);

}
f010361e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103621:	5b                   	pop    %ebx
f0103622:	5e                   	pop    %esi
f0103623:	5f                   	pop    %edi
f0103624:	5d                   	pop    %ebp
f0103625:	c3                   	ret    

f0103626 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103626:	f3 0f 1e fb          	endbr32 
f010362a:	55                   	push   %ebp
f010362b:	89 e5                	mov    %esp,%ebp
f010362d:	57                   	push   %edi
f010362e:	56                   	push   %esi
f010362f:	53                   	push   %ebx
f0103630:	83 ec 1c             	sub    $0x1c,%esp
f0103633:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103636:	e8 ef 2d 00 00       	call   f010642a <cpunum>
f010363b:	6b c0 74             	imul   $0x74,%eax,%eax
f010363e:	39 b8 28 10 33 f0    	cmp    %edi,-0xfccefd8(%eax)
f0103644:	74 48                	je     f010368e <env_free+0x68>
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103646:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103649:	e8 dc 2d 00 00       	call   f010642a <cpunum>
f010364e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103651:	ba 00 00 00 00       	mov    $0x0,%edx
f0103656:	83 b8 28 10 33 f0 00 	cmpl   $0x0,-0xfccefd8(%eax)
f010365d:	74 11                	je     f0103670 <env_free+0x4a>
f010365f:	e8 c6 2d 00 00       	call   f010642a <cpunum>
f0103664:	6b c0 74             	imul   $0x74,%eax,%eax
f0103667:	8b 80 28 10 33 f0    	mov    -0xfccefd8(%eax),%eax
f010366d:	8b 50 48             	mov    0x48(%eax),%edx
f0103670:	83 ec 04             	sub    $0x4,%esp
f0103673:	53                   	push   %ebx
f0103674:	52                   	push   %edx
f0103675:	68 cd 7d 10 f0       	push   $0xf0107dcd
f010367a:	e8 bf 04 00 00       	call   f0103b3e <cprintf>
f010367f:	83 c4 10             	add    $0x10,%esp
f0103682:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103689:	e9 a9 00 00 00       	jmp    f0103737 <env_free+0x111>
		lcr3(PADDR(kern_pgdir));
f010368e:	a1 8c 0e 33 f0       	mov    0xf0330e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0103693:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103698:	76 0a                	jbe    f01036a4 <env_free+0x7e>
	return (physaddr_t)kva - KERNBASE;
f010369a:	05 00 00 00 10       	add    $0x10000000,%eax
f010369f:	0f 22 d8             	mov    %eax,%cr3
}
f01036a2:	eb a2                	jmp    f0103646 <env_free+0x20>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036a4:	50                   	push   %eax
f01036a5:	68 e8 6a 10 f0       	push   $0xf0106ae8
f01036aa:	68 ce 01 00 00       	push   $0x1ce
f01036af:	68 60 7d 10 f0       	push   $0xf0107d60
f01036b4:	e8 87 c9 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01036b9:	56                   	push   %esi
f01036ba:	68 c4 6a 10 f0       	push   $0xf0106ac4
f01036bf:	68 dd 01 00 00       	push   $0x1dd
f01036c4:	68 60 7d 10 f0       	push   $0xf0107d60
f01036c9:	e8 72 c9 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01036ce:	83 ec 08             	sub    $0x8,%esp
f01036d1:	89 d8                	mov    %ebx,%eax
f01036d3:	c1 e0 0c             	shl    $0xc,%eax
f01036d6:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01036d9:	50                   	push   %eax
f01036da:	ff 77 60             	pushl  0x60(%edi)
f01036dd:	e8 9c db ff ff       	call   f010127e <page_remove>
f01036e2:	83 c4 10             	add    $0x10,%esp
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01036e5:	83 c3 01             	add    $0x1,%ebx
f01036e8:	83 c6 04             	add    $0x4,%esi
f01036eb:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01036f1:	74 07                	je     f01036fa <env_free+0xd4>
			if (pt[pteno] & PTE_P)
f01036f3:	f6 06 01             	testb  $0x1,(%esi)
f01036f6:	74 ed                	je     f01036e5 <env_free+0xbf>
f01036f8:	eb d4                	jmp    f01036ce <env_free+0xa8>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01036fa:	8b 47 60             	mov    0x60(%edi),%eax
f01036fd:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103700:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103707:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010370a:	3b 05 88 0e 33 f0    	cmp    0xf0330e88,%eax
f0103710:	73 65                	jae    f0103777 <env_free+0x151>
		page_decref(pa2page(pa));
f0103712:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103715:	a1 90 0e 33 f0       	mov    0xf0330e90,%eax
f010371a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010371d:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103720:	50                   	push   %eax
f0103721:	e8 90 d9 ff ff       	call   f01010b6 <page_decref>
f0103726:	83 c4 10             	add    $0x10,%esp
f0103729:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f010372d:	8b 45 e0             	mov    -0x20(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103730:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0103735:	74 54                	je     f010378b <env_free+0x165>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103737:	8b 47 60             	mov    0x60(%edi),%eax
f010373a:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010373d:	8b 04 10             	mov    (%eax,%edx,1),%eax
f0103740:	a8 01                	test   $0x1,%al
f0103742:	74 e5                	je     f0103729 <env_free+0x103>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103744:	89 c6                	mov    %eax,%esi
f0103746:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f010374c:	c1 e8 0c             	shr    $0xc,%eax
f010374f:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103752:	39 05 88 0e 33 f0    	cmp    %eax,0xf0330e88
f0103758:	0f 86 5b ff ff ff    	jbe    f01036b9 <env_free+0x93>
	return (void *)(pa + KERNBASE);
f010375e:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f0103764:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103767:	c1 e0 14             	shl    $0x14,%eax
f010376a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010376d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103772:	e9 7c ff ff ff       	jmp    f01036f3 <env_free+0xcd>
		panic("pa2page called with invalid pa");
f0103777:	83 ec 04             	sub    $0x4,%esp
f010377a:	68 4c 71 10 f0       	push   $0xf010714c
f010377f:	6a 51                	push   $0x51
f0103781:	68 9f 79 10 f0       	push   $0xf010799f
f0103786:	e8 b5 c8 ff ff       	call   f0100040 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010378b:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f010378e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103793:	76 49                	jbe    f01037de <env_free+0x1b8>
	e->env_pgdir = 0;
f0103795:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f010379c:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f01037a1:	c1 e8 0c             	shr    $0xc,%eax
f01037a4:	3b 05 88 0e 33 f0    	cmp    0xf0330e88,%eax
f01037aa:	73 47                	jae    f01037f3 <env_free+0x1cd>
	page_decref(pa2page(pa));
f01037ac:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01037af:	8b 15 90 0e 33 f0    	mov    0xf0330e90,%edx
f01037b5:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01037b8:	50                   	push   %eax
f01037b9:	e8 f8 d8 ff ff       	call   f01010b6 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01037be:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01037c5:	a1 48 02 33 f0       	mov    0xf0330248,%eax
f01037ca:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01037cd:	89 3d 48 02 33 f0    	mov    %edi,0xf0330248
}
f01037d3:	83 c4 10             	add    $0x10,%esp
f01037d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01037d9:	5b                   	pop    %ebx
f01037da:	5e                   	pop    %esi
f01037db:	5f                   	pop    %edi
f01037dc:	5d                   	pop    %ebp
f01037dd:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037de:	50                   	push   %eax
f01037df:	68 e8 6a 10 f0       	push   $0xf0106ae8
f01037e4:	68 eb 01 00 00       	push   $0x1eb
f01037e9:	68 60 7d 10 f0       	push   $0xf0107d60
f01037ee:	e8 4d c8 ff ff       	call   f0100040 <_panic>
		panic("pa2page called with invalid pa");
f01037f3:	83 ec 04             	sub    $0x4,%esp
f01037f6:	68 4c 71 10 f0       	push   $0xf010714c
f01037fb:	6a 51                	push   $0x51
f01037fd:	68 9f 79 10 f0       	push   $0xf010799f
f0103802:	e8 39 c8 ff ff       	call   f0100040 <_panic>

f0103807 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103807:	f3 0f 1e fb          	endbr32 
f010380b:	55                   	push   %ebp
f010380c:	89 e5                	mov    %esp,%ebp
f010380e:	53                   	push   %ebx
f010380f:	83 ec 04             	sub    $0x4,%esp
f0103812:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103815:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103819:	74 21                	je     f010383c <env_destroy+0x35>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f010381b:	83 ec 0c             	sub    $0xc,%esp
f010381e:	53                   	push   %ebx
f010381f:	e8 02 fe ff ff       	call   f0103626 <env_free>

	if (curenv == e) {
f0103824:	e8 01 2c 00 00       	call   f010642a <cpunum>
f0103829:	6b c0 74             	imul   $0x74,%eax,%eax
f010382c:	83 c4 10             	add    $0x10,%esp
f010382f:	39 98 28 10 33 f0    	cmp    %ebx,-0xfccefd8(%eax)
f0103835:	74 1e                	je     f0103855 <env_destroy+0x4e>
		curenv = NULL;
		sched_yield();
	}
}
f0103837:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010383a:	c9                   	leave  
f010383b:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f010383c:	e8 e9 2b 00 00       	call   f010642a <cpunum>
f0103841:	6b c0 74             	imul   $0x74,%eax,%eax
f0103844:	39 98 28 10 33 f0    	cmp    %ebx,-0xfccefd8(%eax)
f010384a:	74 cf                	je     f010381b <env_destroy+0x14>
		e->env_status = ENV_DYING;
f010384c:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103853:	eb e2                	jmp    f0103837 <env_destroy+0x30>
		curenv = NULL;
f0103855:	e8 d0 2b 00 00       	call   f010642a <cpunum>
f010385a:	6b c0 74             	imul   $0x74,%eax,%eax
f010385d:	c7 80 28 10 33 f0 00 	movl   $0x0,-0xfccefd8(%eax)
f0103864:	00 00 00 
		sched_yield();
f0103867:	e8 b0 11 00 00       	call   f0104a1c <sched_yield>

f010386c <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f010386c:	f3 0f 1e fb          	endbr32 
f0103870:	55                   	push   %ebp
f0103871:	89 e5                	mov    %esp,%ebp
f0103873:	56                   	push   %esi
f0103874:	53                   	push   %ebx
f0103875:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103878:	e8 ad 2b 00 00       	call   f010642a <cpunum>
f010387d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103880:	8b b0 28 10 33 f0    	mov    -0xfccefd8(%eax),%esi
f0103886:	e8 9f 2b 00 00       	call   f010642a <cpunum>
f010388b:	89 46 5c             	mov    %eax,0x5c(%esi)
    assert(tf->tf_eflags & FL_IF);
f010388e:	f6 43 39 02          	testb  $0x2,0x39(%ebx)
f0103892:	75 19                	jne    f01038ad <env_pop_tf+0x41>
f0103894:	68 e3 7d 10 f0       	push   $0xf0107de3
f0103899:	68 b9 79 10 f0       	push   $0xf01079b9
f010389e:	68 19 02 00 00       	push   $0x219
f01038a3:	68 60 7d 10 f0       	push   $0xf0107d60
f01038a8:	e8 93 c7 ff ff       	call   f0100040 <_panic>

	asm volatile(
f01038ad:	89 dc                	mov    %ebx,%esp
f01038af:	61                   	popa   
f01038b0:	07                   	pop    %es
f01038b1:	1f                   	pop    %ds
f01038b2:	83 c4 08             	add    $0x8,%esp
f01038b5:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01038b6:	83 ec 04             	sub    $0x4,%esp
f01038b9:	68 f9 7d 10 f0       	push   $0xf0107df9
f01038be:	68 23 02 00 00       	push   $0x223
f01038c3:	68 60 7d 10 f0       	push   $0xf0107d60
f01038c8:	e8 73 c7 ff ff       	call   f0100040 <_panic>

f01038cd <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01038cd:	f3 0f 1e fb          	endbr32 
f01038d1:	55                   	push   %ebp
f01038d2:	89 e5                	mov    %esp,%ebp
f01038d4:	53                   	push   %ebx
f01038d5:	83 ec 04             	sub    $0x4,%esp
f01038d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

    // 1.
    if (curenv != NULL && curenv->env_status == ENV_RUNNING) {
f01038db:	e8 4a 2b 00 00       	call   f010642a <cpunum>
f01038e0:	6b c0 74             	imul   $0x74,%eax,%eax
f01038e3:	83 b8 28 10 33 f0 00 	cmpl   $0x0,-0xfccefd8(%eax)
f01038ea:	74 14                	je     f0103900 <env_run+0x33>
f01038ec:	e8 39 2b 00 00       	call   f010642a <cpunum>
f01038f1:	6b c0 74             	imul   $0x74,%eax,%eax
f01038f4:	8b 80 28 10 33 f0    	mov    -0xfccefd8(%eax),%eax
f01038fa:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01038fe:	74 6c                	je     f010396c <env_run+0x9f>
        curenv->env_status = ENV_RUNNABLE;
    }
    // 2.
    curenv = e;
f0103900:	e8 25 2b 00 00       	call   f010642a <cpunum>
f0103905:	6b c0 74             	imul   $0x74,%eax,%eax
f0103908:	89 98 28 10 33 f0    	mov    %ebx,-0xfccefd8(%eax)
    // 3.
    curenv->env_status = ENV_RUNNING;
f010390e:	e8 17 2b 00 00       	call   f010642a <cpunum>
f0103913:	6b c0 74             	imul   $0x74,%eax,%eax
f0103916:	8b 80 28 10 33 f0    	mov    -0xfccefd8(%eax),%eax
f010391c:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
    // 4.
    curenv->env_runs += 1;
f0103923:	e8 02 2b 00 00       	call   f010642a <cpunum>
f0103928:	6b c0 74             	imul   $0x74,%eax,%eax
f010392b:	8b 80 28 10 33 f0    	mov    -0xfccefd8(%eax),%eax
f0103931:	83 40 58 01          	addl   $0x1,0x58(%eax)
    // 5.
    lcr3(PADDR(e->env_pgdir));
f0103935:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0103938:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010393d:	76 47                	jbe    f0103986 <env_run+0xb9>
	return (physaddr_t)kva - KERNBASE;
f010393f:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103944:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103947:	83 ec 0c             	sub    $0xc,%esp
f010394a:	68 c0 43 12 f0       	push   $0xf01243c0
f010394f:	e8 fc 2d 00 00       	call   f0106750 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103954:	f3 90                	pause  

    unlock_kernel();

    env_pop_tf(&curenv->env_tf);
f0103956:	e8 cf 2a 00 00       	call   f010642a <cpunum>
f010395b:	83 c4 04             	add    $0x4,%esp
f010395e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103961:	ff b0 28 10 33 f0    	pushl  -0xfccefd8(%eax)
f0103967:	e8 00 ff ff ff       	call   f010386c <env_pop_tf>
        curenv->env_status = ENV_RUNNABLE;
f010396c:	e8 b9 2a 00 00       	call   f010642a <cpunum>
f0103971:	6b c0 74             	imul   $0x74,%eax,%eax
f0103974:	8b 80 28 10 33 f0    	mov    -0xfccefd8(%eax),%eax
f010397a:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f0103981:	e9 7a ff ff ff       	jmp    f0103900 <env_run+0x33>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103986:	50                   	push   %eax
f0103987:	68 e8 6a 10 f0       	push   $0xf0106ae8
f010398c:	68 4d 02 00 00       	push   $0x24d
f0103991:	68 60 7d 10 f0       	push   $0xf0107d60
f0103996:	e8 a5 c6 ff ff       	call   f0100040 <_panic>

f010399b <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f010399b:	f3 0f 1e fb          	endbr32 
f010399f:	55                   	push   %ebp
f01039a0:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01039a2:	8b 45 08             	mov    0x8(%ebp),%eax
f01039a5:	ba 70 00 00 00       	mov    $0x70,%edx
f01039aa:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01039ab:	ba 71 00 00 00       	mov    $0x71,%edx
f01039b0:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01039b1:	0f b6 c0             	movzbl %al,%eax
}
f01039b4:	5d                   	pop    %ebp
f01039b5:	c3                   	ret    

f01039b6 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01039b6:	f3 0f 1e fb          	endbr32 
f01039ba:	55                   	push   %ebp
f01039bb:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01039bd:	8b 45 08             	mov    0x8(%ebp),%eax
f01039c0:	ba 70 00 00 00       	mov    $0x70,%edx
f01039c5:	ee                   	out    %al,(%dx)
f01039c6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01039c9:	ba 71 00 00 00       	mov    $0x71,%edx
f01039ce:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01039cf:	5d                   	pop    %ebp
f01039d0:	c3                   	ret    

f01039d1 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01039d1:	f3 0f 1e fb          	endbr32 
f01039d5:	55                   	push   %ebp
f01039d6:	89 e5                	mov    %esp,%ebp
f01039d8:	56                   	push   %esi
f01039d9:	53                   	push   %ebx
f01039da:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f01039dd:	66 a3 a8 43 12 f0    	mov    %ax,0xf01243a8
	if (!didinit)
f01039e3:	80 3d 4c 02 33 f0 00 	cmpb   $0x0,0xf033024c
f01039ea:	75 07                	jne    f01039f3 <irq_setmask_8259A+0x22>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f01039ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01039ef:	5b                   	pop    %ebx
f01039f0:	5e                   	pop    %esi
f01039f1:	5d                   	pop    %ebp
f01039f2:	c3                   	ret    
f01039f3:	89 c6                	mov    %eax,%esi
f01039f5:	ba 21 00 00 00       	mov    $0x21,%edx
f01039fa:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f01039fb:	66 c1 e8 08          	shr    $0x8,%ax
f01039ff:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103a04:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103a05:	83 ec 0c             	sub    $0xc,%esp
f0103a08:	68 05 7e 10 f0       	push   $0xf0107e05
f0103a0d:	e8 2c 01 00 00       	call   f0103b3e <cprintf>
f0103a12:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103a15:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103a1a:	0f b7 f6             	movzwl %si,%esi
f0103a1d:	f7 d6                	not    %esi
f0103a1f:	eb 19                	jmp    f0103a3a <irq_setmask_8259A+0x69>
			cprintf(" %d", i);
f0103a21:	83 ec 08             	sub    $0x8,%esp
f0103a24:	53                   	push   %ebx
f0103a25:	68 13 83 10 f0       	push   $0xf0108313
f0103a2a:	e8 0f 01 00 00       	call   f0103b3e <cprintf>
f0103a2f:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103a32:	83 c3 01             	add    $0x1,%ebx
f0103a35:	83 fb 10             	cmp    $0x10,%ebx
f0103a38:	74 07                	je     f0103a41 <irq_setmask_8259A+0x70>
		if (~mask & (1<<i))
f0103a3a:	0f a3 de             	bt     %ebx,%esi
f0103a3d:	73 f3                	jae    f0103a32 <irq_setmask_8259A+0x61>
f0103a3f:	eb e0                	jmp    f0103a21 <irq_setmask_8259A+0x50>
	cprintf("\n");
f0103a41:	83 ec 0c             	sub    $0xc,%esp
f0103a44:	68 80 7c 10 f0       	push   $0xf0107c80
f0103a49:	e8 f0 00 00 00       	call   f0103b3e <cprintf>
f0103a4e:	83 c4 10             	add    $0x10,%esp
f0103a51:	eb 99                	jmp    f01039ec <irq_setmask_8259A+0x1b>

f0103a53 <pic_init>:
{
f0103a53:	f3 0f 1e fb          	endbr32 
f0103a57:	55                   	push   %ebp
f0103a58:	89 e5                	mov    %esp,%ebp
f0103a5a:	57                   	push   %edi
f0103a5b:	56                   	push   %esi
f0103a5c:	53                   	push   %ebx
f0103a5d:	83 ec 0c             	sub    $0xc,%esp
	didinit = 1;
f0103a60:	c6 05 4c 02 33 f0 01 	movb   $0x1,0xf033024c
f0103a67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103a6c:	bb 21 00 00 00       	mov    $0x21,%ebx
f0103a71:	89 da                	mov    %ebx,%edx
f0103a73:	ee                   	out    %al,(%dx)
f0103a74:	b9 a1 00 00 00       	mov    $0xa1,%ecx
f0103a79:	89 ca                	mov    %ecx,%edx
f0103a7b:	ee                   	out    %al,(%dx)
f0103a7c:	bf 11 00 00 00       	mov    $0x11,%edi
f0103a81:	be 20 00 00 00       	mov    $0x20,%esi
f0103a86:	89 f8                	mov    %edi,%eax
f0103a88:	89 f2                	mov    %esi,%edx
f0103a8a:	ee                   	out    %al,(%dx)
f0103a8b:	b8 20 00 00 00       	mov    $0x20,%eax
f0103a90:	89 da                	mov    %ebx,%edx
f0103a92:	ee                   	out    %al,(%dx)
f0103a93:	b8 04 00 00 00       	mov    $0x4,%eax
f0103a98:	ee                   	out    %al,(%dx)
f0103a99:	b8 03 00 00 00       	mov    $0x3,%eax
f0103a9e:	ee                   	out    %al,(%dx)
f0103a9f:	bb a0 00 00 00       	mov    $0xa0,%ebx
f0103aa4:	89 f8                	mov    %edi,%eax
f0103aa6:	89 da                	mov    %ebx,%edx
f0103aa8:	ee                   	out    %al,(%dx)
f0103aa9:	b8 28 00 00 00       	mov    $0x28,%eax
f0103aae:	89 ca                	mov    %ecx,%edx
f0103ab0:	ee                   	out    %al,(%dx)
f0103ab1:	b8 02 00 00 00       	mov    $0x2,%eax
f0103ab6:	ee                   	out    %al,(%dx)
f0103ab7:	b8 01 00 00 00       	mov    $0x1,%eax
f0103abc:	ee                   	out    %al,(%dx)
f0103abd:	bf 68 00 00 00       	mov    $0x68,%edi
f0103ac2:	89 f8                	mov    %edi,%eax
f0103ac4:	89 f2                	mov    %esi,%edx
f0103ac6:	ee                   	out    %al,(%dx)
f0103ac7:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0103acc:	89 c8                	mov    %ecx,%eax
f0103ace:	ee                   	out    %al,(%dx)
f0103acf:	89 f8                	mov    %edi,%eax
f0103ad1:	89 da                	mov    %ebx,%edx
f0103ad3:	ee                   	out    %al,(%dx)
f0103ad4:	89 c8                	mov    %ecx,%eax
f0103ad6:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f0103ad7:	0f b7 05 a8 43 12 f0 	movzwl 0xf01243a8,%eax
f0103ade:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103ae2:	75 08                	jne    f0103aec <pic_init+0x99>
}
f0103ae4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103ae7:	5b                   	pop    %ebx
f0103ae8:	5e                   	pop    %esi
f0103ae9:	5f                   	pop    %edi
f0103aea:	5d                   	pop    %ebp
f0103aeb:	c3                   	ret    
		irq_setmask_8259A(irq_mask_8259A);
f0103aec:	83 ec 0c             	sub    $0xc,%esp
f0103aef:	0f b7 c0             	movzwl %ax,%eax
f0103af2:	50                   	push   %eax
f0103af3:	e8 d9 fe ff ff       	call   f01039d1 <irq_setmask_8259A>
f0103af8:	83 c4 10             	add    $0x10,%esp
}
f0103afb:	eb e7                	jmp    f0103ae4 <pic_init+0x91>

f0103afd <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103afd:	f3 0f 1e fb          	endbr32 
f0103b01:	55                   	push   %ebp
f0103b02:	89 e5                	mov    %esp,%ebp
f0103b04:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103b07:	ff 75 08             	pushl  0x8(%ebp)
f0103b0a:	e8 9a cc ff ff       	call   f01007a9 <cputchar>
	*cnt++;
}
f0103b0f:	83 c4 10             	add    $0x10,%esp
f0103b12:	c9                   	leave  
f0103b13:	c3                   	ret    

f0103b14 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103b14:	f3 0f 1e fb          	endbr32 
f0103b18:	55                   	push   %ebp
f0103b19:	89 e5                	mov    %esp,%ebp
f0103b1b:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103b1e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103b25:	ff 75 0c             	pushl  0xc(%ebp)
f0103b28:	ff 75 08             	pushl  0x8(%ebp)
f0103b2b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103b2e:	50                   	push   %eax
f0103b2f:	68 fd 3a 10 f0       	push   $0xf0103afd
f0103b34:	e8 71 1b 00 00       	call   f01056aa <vprintfmt>
	return cnt;
}
f0103b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103b3c:	c9                   	leave  
f0103b3d:	c3                   	ret    

f0103b3e <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103b3e:	f3 0f 1e fb          	endbr32 
f0103b42:	55                   	push   %ebp
f0103b43:	89 e5                	mov    %esp,%ebp
f0103b45:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103b48:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103b4b:	50                   	push   %eax
f0103b4c:	ff 75 08             	pushl  0x8(%ebp)
f0103b4f:	e8 c0 ff ff ff       	call   f0103b14 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103b54:	c9                   	leave  
f0103b55:	c3                   	ret    

f0103b56 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103b56:	f3 0f 1e fb          	endbr32 
f0103b5a:	55                   	push   %ebp
f0103b5b:	89 e5                	mov    %esp,%ebp
f0103b5d:	57                   	push   %edi
f0103b5e:	56                   	push   %esi
f0103b5f:	53                   	push   %ebx
f0103b60:	83 ec 1c             	sub    $0x1c,%esp
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
    uint32_t cpu_id = thiscpu->cpu_id;
f0103b63:	e8 c2 28 00 00       	call   f010642a <cpunum>
f0103b68:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b6b:	0f b6 b8 20 10 33 f0 	movzbl -0xfccefe0(%eax),%edi
f0103b72:	89 f8                	mov    %edi,%eax
f0103b74:	0f b6 d8             	movzbl %al,%ebx
    thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - (KSTKSIZE + KSTKGAP) * cpu_id;
f0103b77:	e8 ae 28 00 00       	call   f010642a <cpunum>
f0103b7c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b7f:	ba 00 f0 00 00       	mov    $0xf000,%edx
f0103b84:	29 da                	sub    %ebx,%edx
f0103b86:	c1 e2 10             	shl    $0x10,%edx
f0103b89:	89 90 30 10 33 f0    	mov    %edx,-0xfccefd0(%eax)
    thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103b8f:	e8 96 28 00 00       	call   f010642a <cpunum>
f0103b94:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b97:	66 c7 80 34 10 33 f0 	movw   $0x10,-0xfccefcc(%eax)
f0103b9e:	10 00 
    thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f0103ba0:	e8 85 28 00 00       	call   f010642a <cpunum>
f0103ba5:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ba8:	66 c7 80 92 10 33 f0 	movw   $0x68,-0xfccef6e(%eax)
f0103baf:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cpu_id] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f0103bb1:	83 c3 05             	add    $0x5,%ebx
f0103bb4:	e8 71 28 00 00       	call   f010642a <cpunum>
f0103bb9:	89 c6                	mov    %eax,%esi
f0103bbb:	e8 6a 28 00 00       	call   f010642a <cpunum>
f0103bc0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103bc3:	e8 62 28 00 00       	call   f010642a <cpunum>
f0103bc8:	66 c7 04 dd 40 43 12 	movw   $0x67,-0xfedbcc0(,%ebx,8)
f0103bcf:	f0 67 00 
f0103bd2:	6b f6 74             	imul   $0x74,%esi,%esi
f0103bd5:	81 c6 2c 10 33 f0    	add    $0xf033102c,%esi
f0103bdb:	66 89 34 dd 42 43 12 	mov    %si,-0xfedbcbe(,%ebx,8)
f0103be2:	f0 
f0103be3:	6b 55 e4 74          	imul   $0x74,-0x1c(%ebp),%edx
f0103be7:	81 c2 2c 10 33 f0    	add    $0xf033102c,%edx
f0103bed:	c1 ea 10             	shr    $0x10,%edx
f0103bf0:	88 14 dd 44 43 12 f0 	mov    %dl,-0xfedbcbc(,%ebx,8)
f0103bf7:	c6 04 dd 46 43 12 f0 	movb   $0x40,-0xfedbcba(,%ebx,8)
f0103bfe:	40 
f0103bff:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c02:	05 2c 10 33 f0       	add    $0xf033102c,%eax
f0103c07:	c1 e8 18             	shr    $0x18,%eax
f0103c0a:	88 04 dd 47 43 12 f0 	mov    %al,-0xfedbcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpu_id].sd_s = 0;
f0103c11:	c6 04 dd 45 43 12 f0 	movb   $0x89,-0xfedbcbb(,%ebx,8)
f0103c18:	89 

    ltr(GD_TSS0 + (cpu_id << 3));
f0103c19:	89 f8                	mov    %edi,%eax
f0103c1b:	0f b6 f8             	movzbl %al,%edi
f0103c1e:	8d 3c fd 28 00 00 00 	lea    0x28(,%edi,8),%edi
	asm volatile("ltr %0" : : "r" (sel));
f0103c25:	0f 00 df             	ltr    %di
	asm volatile("lidt (%0)" : : "r" (p));
f0103c28:	b8 ac 43 12 f0       	mov    $0xf01243ac,%eax
f0103c2d:	0f 01 18             	lidtl  (%eax)
    lidt(&idt_pd);


}
f0103c30:	83 c4 1c             	add    $0x1c,%esp
f0103c33:	5b                   	pop    %ebx
f0103c34:	5e                   	pop    %esi
f0103c35:	5f                   	pop    %edi
f0103c36:	5d                   	pop    %ebp
f0103c37:	c3                   	ret    

f0103c38 <trap_init>:
{
f0103c38:	f3 0f 1e fb          	endbr32 
f0103c3c:	55                   	push   %ebp
f0103c3d:	89 e5                	mov    %esp,%ebp
f0103c3f:	83 ec 08             	sub    $0x8,%esp
    SETGATE(idt[T_DIVIDE], 0, GD_KT, t_divide, 0);
f0103c42:	b8 44 48 10 f0       	mov    $0xf0104844,%eax
f0103c47:	66 a3 60 02 33 f0    	mov    %ax,0xf0330260
f0103c4d:	66 c7 05 62 02 33 f0 	movw   $0x8,0xf0330262
f0103c54:	08 00 
f0103c56:	c6 05 64 02 33 f0 00 	movb   $0x0,0xf0330264
f0103c5d:	c6 05 65 02 33 f0 8e 	movb   $0x8e,0xf0330265
f0103c64:	c1 e8 10             	shr    $0x10,%eax
f0103c67:	66 a3 66 02 33 f0    	mov    %ax,0xf0330266
    SETGATE(idt[T_DEBUG], 0, GD_KT, t_debug, 0);
f0103c6d:	b8 4e 48 10 f0       	mov    $0xf010484e,%eax
f0103c72:	66 a3 68 02 33 f0    	mov    %ax,0xf0330268
f0103c78:	66 c7 05 6a 02 33 f0 	movw   $0x8,0xf033026a
f0103c7f:	08 00 
f0103c81:	c6 05 6c 02 33 f0 00 	movb   $0x0,0xf033026c
f0103c88:	c6 05 6d 02 33 f0 8e 	movb   $0x8e,0xf033026d
f0103c8f:	c1 e8 10             	shr    $0x10,%eax
f0103c92:	66 a3 6e 02 33 f0    	mov    %ax,0xf033026e
    SETGATE(idt[T_NMI], 0, GD_KT, t_nmi, 0);
f0103c98:	b8 58 48 10 f0       	mov    $0xf0104858,%eax
f0103c9d:	66 a3 70 02 33 f0    	mov    %ax,0xf0330270
f0103ca3:	66 c7 05 72 02 33 f0 	movw   $0x8,0xf0330272
f0103caa:	08 00 
f0103cac:	c6 05 74 02 33 f0 00 	movb   $0x0,0xf0330274
f0103cb3:	c6 05 75 02 33 f0 8e 	movb   $0x8e,0xf0330275
f0103cba:	c1 e8 10             	shr    $0x10,%eax
f0103cbd:	66 a3 76 02 33 f0    	mov    %ax,0xf0330276
    SETGATE(idt[T_BRKPT], 0, GD_KT, t_brkpt, 3);
f0103cc3:	b8 62 48 10 f0       	mov    $0xf0104862,%eax
f0103cc8:	66 a3 78 02 33 f0    	mov    %ax,0xf0330278
f0103cce:	66 c7 05 7a 02 33 f0 	movw   $0x8,0xf033027a
f0103cd5:	08 00 
f0103cd7:	c6 05 7c 02 33 f0 00 	movb   $0x0,0xf033027c
f0103cde:	c6 05 7d 02 33 f0 ee 	movb   $0xee,0xf033027d
f0103ce5:	c1 e8 10             	shr    $0x10,%eax
f0103ce8:	66 a3 7e 02 33 f0    	mov    %ax,0xf033027e
    SETGATE(idt[T_OFLOW], 0, GD_KT, t_oflow, 0);
f0103cee:	b8 6c 48 10 f0       	mov    $0xf010486c,%eax
f0103cf3:	66 a3 80 02 33 f0    	mov    %ax,0xf0330280
f0103cf9:	66 c7 05 82 02 33 f0 	movw   $0x8,0xf0330282
f0103d00:	08 00 
f0103d02:	c6 05 84 02 33 f0 00 	movb   $0x0,0xf0330284
f0103d09:	c6 05 85 02 33 f0 8e 	movb   $0x8e,0xf0330285
f0103d10:	c1 e8 10             	shr    $0x10,%eax
f0103d13:	66 a3 86 02 33 f0    	mov    %ax,0xf0330286
    SETGATE(idt[T_BOUND], 0, GD_KT, t_bound, 0);
f0103d19:	b8 76 48 10 f0       	mov    $0xf0104876,%eax
f0103d1e:	66 a3 88 02 33 f0    	mov    %ax,0xf0330288
f0103d24:	66 c7 05 8a 02 33 f0 	movw   $0x8,0xf033028a
f0103d2b:	08 00 
f0103d2d:	c6 05 8c 02 33 f0 00 	movb   $0x0,0xf033028c
f0103d34:	c6 05 8d 02 33 f0 8e 	movb   $0x8e,0xf033028d
f0103d3b:	c1 e8 10             	shr    $0x10,%eax
f0103d3e:	66 a3 8e 02 33 f0    	mov    %ax,0xf033028e
    SETGATE(idt[T_ILLOP], 0, GD_KT, t_illop, 0);
f0103d44:	b8 80 48 10 f0       	mov    $0xf0104880,%eax
f0103d49:	66 a3 90 02 33 f0    	mov    %ax,0xf0330290
f0103d4f:	66 c7 05 92 02 33 f0 	movw   $0x8,0xf0330292
f0103d56:	08 00 
f0103d58:	c6 05 94 02 33 f0 00 	movb   $0x0,0xf0330294
f0103d5f:	c6 05 95 02 33 f0 8e 	movb   $0x8e,0xf0330295
f0103d66:	c1 e8 10             	shr    $0x10,%eax
f0103d69:	66 a3 96 02 33 f0    	mov    %ax,0xf0330296
    SETGATE(idt[T_DEVICE], 0, GD_KT, t_device, 0);
f0103d6f:	b8 8a 48 10 f0       	mov    $0xf010488a,%eax
f0103d74:	66 a3 98 02 33 f0    	mov    %ax,0xf0330298
f0103d7a:	66 c7 05 9a 02 33 f0 	movw   $0x8,0xf033029a
f0103d81:	08 00 
f0103d83:	c6 05 9c 02 33 f0 00 	movb   $0x0,0xf033029c
f0103d8a:	c6 05 9d 02 33 f0 8e 	movb   $0x8e,0xf033029d
f0103d91:	c1 e8 10             	shr    $0x10,%eax
f0103d94:	66 a3 9e 02 33 f0    	mov    %ax,0xf033029e
    SETGATE(idt[T_DBLFLT], 0, GD_KT, t_dblflt, 0);
f0103d9a:	b8 94 48 10 f0       	mov    $0xf0104894,%eax
f0103d9f:	66 a3 a0 02 33 f0    	mov    %ax,0xf03302a0
f0103da5:	66 c7 05 a2 02 33 f0 	movw   $0x8,0xf03302a2
f0103dac:	08 00 
f0103dae:	c6 05 a4 02 33 f0 00 	movb   $0x0,0xf03302a4
f0103db5:	c6 05 a5 02 33 f0 8e 	movb   $0x8e,0xf03302a5
f0103dbc:	c1 e8 10             	shr    $0x10,%eax
f0103dbf:	66 a3 a6 02 33 f0    	mov    %ax,0xf03302a6
    SETGATE(idt[T_TSS], 0, GD_KT, t_tss, 0);
f0103dc5:	b8 9c 48 10 f0       	mov    $0xf010489c,%eax
f0103dca:	66 a3 b0 02 33 f0    	mov    %ax,0xf03302b0
f0103dd0:	66 c7 05 b2 02 33 f0 	movw   $0x8,0xf03302b2
f0103dd7:	08 00 
f0103dd9:	c6 05 b4 02 33 f0 00 	movb   $0x0,0xf03302b4
f0103de0:	c6 05 b5 02 33 f0 8e 	movb   $0x8e,0xf03302b5
f0103de7:	c1 e8 10             	shr    $0x10,%eax
f0103dea:	66 a3 b6 02 33 f0    	mov    %ax,0xf03302b6
    SETGATE(idt[T_SEGNP], 0, GD_KT, t_segnp, 0);
f0103df0:	b8 a4 48 10 f0       	mov    $0xf01048a4,%eax
f0103df5:	66 a3 b8 02 33 f0    	mov    %ax,0xf03302b8
f0103dfb:	66 c7 05 ba 02 33 f0 	movw   $0x8,0xf03302ba
f0103e02:	08 00 
f0103e04:	c6 05 bc 02 33 f0 00 	movb   $0x0,0xf03302bc
f0103e0b:	c6 05 bd 02 33 f0 8e 	movb   $0x8e,0xf03302bd
f0103e12:	c1 e8 10             	shr    $0x10,%eax
f0103e15:	66 a3 be 02 33 f0    	mov    %ax,0xf03302be
    SETGATE(idt[T_STACK], 0, GD_KT, t_stack, 0);
f0103e1b:	b8 ac 48 10 f0       	mov    $0xf01048ac,%eax
f0103e20:	66 a3 c0 02 33 f0    	mov    %ax,0xf03302c0
f0103e26:	66 c7 05 c2 02 33 f0 	movw   $0x8,0xf03302c2
f0103e2d:	08 00 
f0103e2f:	c6 05 c4 02 33 f0 00 	movb   $0x0,0xf03302c4
f0103e36:	c6 05 c5 02 33 f0 8e 	movb   $0x8e,0xf03302c5
f0103e3d:	c1 e8 10             	shr    $0x10,%eax
f0103e40:	66 a3 c6 02 33 f0    	mov    %ax,0xf03302c6
    SETGATE(idt[T_GPFLT], 0, GD_KT, t_gpflt, 0);
f0103e46:	b8 b4 48 10 f0       	mov    $0xf01048b4,%eax
f0103e4b:	66 a3 c8 02 33 f0    	mov    %ax,0xf03302c8
f0103e51:	66 c7 05 ca 02 33 f0 	movw   $0x8,0xf03302ca
f0103e58:	08 00 
f0103e5a:	c6 05 cc 02 33 f0 00 	movb   $0x0,0xf03302cc
f0103e61:	c6 05 cd 02 33 f0 8e 	movb   $0x8e,0xf03302cd
f0103e68:	c1 e8 10             	shr    $0x10,%eax
f0103e6b:	66 a3 ce 02 33 f0    	mov    %ax,0xf03302ce
    SETGATE(idt[T_PGFLT], 0, GD_KT, t_pgflt, 0);
f0103e71:	b8 bc 48 10 f0       	mov    $0xf01048bc,%eax
f0103e76:	66 a3 d0 02 33 f0    	mov    %ax,0xf03302d0
f0103e7c:	66 c7 05 d2 02 33 f0 	movw   $0x8,0xf03302d2
f0103e83:	08 00 
f0103e85:	c6 05 d4 02 33 f0 00 	movb   $0x0,0xf03302d4
f0103e8c:	c6 05 d5 02 33 f0 8e 	movb   $0x8e,0xf03302d5
f0103e93:	c1 e8 10             	shr    $0x10,%eax
f0103e96:	66 a3 d6 02 33 f0    	mov    %ax,0xf03302d6
    SETGATE(idt[T_FPERR], 0, GD_KT, t_fperr, 0);
f0103e9c:	b8 c0 48 10 f0       	mov    $0xf01048c0,%eax
f0103ea1:	66 a3 e0 02 33 f0    	mov    %ax,0xf03302e0
f0103ea7:	66 c7 05 e2 02 33 f0 	movw   $0x8,0xf03302e2
f0103eae:	08 00 
f0103eb0:	c6 05 e4 02 33 f0 00 	movb   $0x0,0xf03302e4
f0103eb7:	c6 05 e5 02 33 f0 8e 	movb   $0x8e,0xf03302e5
f0103ebe:	c1 e8 10             	shr    $0x10,%eax
f0103ec1:	66 a3 e6 02 33 f0    	mov    %ax,0xf03302e6
    SETGATE(idt[T_ALIGN], 0, GD_KT, t_align, 0);
f0103ec7:	b8 c6 48 10 f0       	mov    $0xf01048c6,%eax
f0103ecc:	66 a3 e8 02 33 f0    	mov    %ax,0xf03302e8
f0103ed2:	66 c7 05 ea 02 33 f0 	movw   $0x8,0xf03302ea
f0103ed9:	08 00 
f0103edb:	c6 05 ec 02 33 f0 00 	movb   $0x0,0xf03302ec
f0103ee2:	c6 05 ed 02 33 f0 8e 	movb   $0x8e,0xf03302ed
f0103ee9:	c1 e8 10             	shr    $0x10,%eax
f0103eec:	66 a3 ee 02 33 f0    	mov    %ax,0xf03302ee
    SETGATE(idt[T_MCHK], 0, GD_KT, t_mchk, 0);
f0103ef2:	b8 ca 48 10 f0       	mov    $0xf01048ca,%eax
f0103ef7:	66 a3 f0 02 33 f0    	mov    %ax,0xf03302f0
f0103efd:	66 c7 05 f2 02 33 f0 	movw   $0x8,0xf03302f2
f0103f04:	08 00 
f0103f06:	c6 05 f4 02 33 f0 00 	movb   $0x0,0xf03302f4
f0103f0d:	c6 05 f5 02 33 f0 8e 	movb   $0x8e,0xf03302f5
f0103f14:	c1 e8 10             	shr    $0x10,%eax
f0103f17:	66 a3 f6 02 33 f0    	mov    %ax,0xf03302f6
    SETGATE(idt[T_SIMDERR], 0, GD_KT, t_simderr, 0);
f0103f1d:	b8 d0 48 10 f0       	mov    $0xf01048d0,%eax
f0103f22:	66 a3 f8 02 33 f0    	mov    %ax,0xf03302f8
f0103f28:	66 c7 05 fa 02 33 f0 	movw   $0x8,0xf03302fa
f0103f2f:	08 00 
f0103f31:	c6 05 fc 02 33 f0 00 	movb   $0x0,0xf03302fc
f0103f38:	c6 05 fd 02 33 f0 8e 	movb   $0x8e,0xf03302fd
f0103f3f:	c1 e8 10             	shr    $0x10,%eax
f0103f42:	66 a3 fe 02 33 f0    	mov    %ax,0xf03302fe
    SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, t_irq_timer, 0);
f0103f48:	b8 d6 48 10 f0       	mov    $0xf01048d6,%eax
f0103f4d:	66 a3 60 03 33 f0    	mov    %ax,0xf0330360
f0103f53:	66 c7 05 62 03 33 f0 	movw   $0x8,0xf0330362
f0103f5a:	08 00 
f0103f5c:	c6 05 64 03 33 f0 00 	movb   $0x0,0xf0330364
f0103f63:	c6 05 65 03 33 f0 8e 	movb   $0x8e,0xf0330365
f0103f6a:	c1 e8 10             	shr    $0x10,%eax
f0103f6d:	66 a3 66 03 33 f0    	mov    %ax,0xf0330366
    SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0, GD_KT, t_irq_kbd, 0);
f0103f73:	b8 dc 48 10 f0       	mov    $0xf01048dc,%eax
f0103f78:	66 a3 68 03 33 f0    	mov    %ax,0xf0330368
f0103f7e:	66 c7 05 6a 03 33 f0 	movw   $0x8,0xf033036a
f0103f85:	08 00 
f0103f87:	c6 05 6c 03 33 f0 00 	movb   $0x0,0xf033036c
f0103f8e:	c6 05 6d 03 33 f0 8e 	movb   $0x8e,0xf033036d
f0103f95:	c1 e8 10             	shr    $0x10,%eax
f0103f98:	66 a3 6e 03 33 f0    	mov    %ax,0xf033036e
    SETGATE(idt[IRQ_OFFSET + 2], 0, GD_KT, t_irq_2, 0);
f0103f9e:	b8 e2 48 10 f0       	mov    $0xf01048e2,%eax
f0103fa3:	66 a3 70 03 33 f0    	mov    %ax,0xf0330370
f0103fa9:	66 c7 05 72 03 33 f0 	movw   $0x8,0xf0330372
f0103fb0:	08 00 
f0103fb2:	c6 05 74 03 33 f0 00 	movb   $0x0,0xf0330374
f0103fb9:	c6 05 75 03 33 f0 8e 	movb   $0x8e,0xf0330375
f0103fc0:	c1 e8 10             	shr    $0x10,%eax
f0103fc3:	66 a3 76 03 33 f0    	mov    %ax,0xf0330376
    SETGATE(idt[IRQ_OFFSET + 3], 0, GD_KT, t_irq_3, 0);
f0103fc9:	b8 e8 48 10 f0       	mov    $0xf01048e8,%eax
f0103fce:	66 a3 78 03 33 f0    	mov    %ax,0xf0330378
f0103fd4:	66 c7 05 7a 03 33 f0 	movw   $0x8,0xf033037a
f0103fdb:	08 00 
f0103fdd:	c6 05 7c 03 33 f0 00 	movb   $0x0,0xf033037c
f0103fe4:	c6 05 7d 03 33 f0 8e 	movb   $0x8e,0xf033037d
f0103feb:	c1 e8 10             	shr    $0x10,%eax
f0103fee:	66 a3 7e 03 33 f0    	mov    %ax,0xf033037e
    SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0, GD_KT, t_irq_serial, 0);
f0103ff4:	b8 ee 48 10 f0       	mov    $0xf01048ee,%eax
f0103ff9:	66 a3 80 03 33 f0    	mov    %ax,0xf0330380
f0103fff:	66 c7 05 82 03 33 f0 	movw   $0x8,0xf0330382
f0104006:	08 00 
f0104008:	c6 05 84 03 33 f0 00 	movb   $0x0,0xf0330384
f010400f:	c6 05 85 03 33 f0 8e 	movb   $0x8e,0xf0330385
f0104016:	c1 e8 10             	shr    $0x10,%eax
f0104019:	66 a3 86 03 33 f0    	mov    %ax,0xf0330386
    SETGATE(idt[IRQ_OFFSET + 5], 0, GD_KT, t_irq_5, 0);
f010401f:	b8 f4 48 10 f0       	mov    $0xf01048f4,%eax
f0104024:	66 a3 88 03 33 f0    	mov    %ax,0xf0330388
f010402a:	66 c7 05 8a 03 33 f0 	movw   $0x8,0xf033038a
f0104031:	08 00 
f0104033:	c6 05 8c 03 33 f0 00 	movb   $0x0,0xf033038c
f010403a:	c6 05 8d 03 33 f0 8e 	movb   $0x8e,0xf033038d
f0104041:	c1 e8 10             	shr    $0x10,%eax
f0104044:	66 a3 8e 03 33 f0    	mov    %ax,0xf033038e
    SETGATE(idt[IRQ_OFFSET + 6], 0, GD_KT, t_irq_6, 0);
f010404a:	b8 fa 48 10 f0       	mov    $0xf01048fa,%eax
f010404f:	66 a3 90 03 33 f0    	mov    %ax,0xf0330390
f0104055:	66 c7 05 92 03 33 f0 	movw   $0x8,0xf0330392
f010405c:	08 00 
f010405e:	c6 05 94 03 33 f0 00 	movb   $0x0,0xf0330394
f0104065:	c6 05 95 03 33 f0 8e 	movb   $0x8e,0xf0330395
f010406c:	c1 e8 10             	shr    $0x10,%eax
f010406f:	66 a3 96 03 33 f0    	mov    %ax,0xf0330396
    SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, t_irq_spurious, 0);
f0104075:	b8 00 49 10 f0       	mov    $0xf0104900,%eax
f010407a:	66 a3 98 03 33 f0    	mov    %ax,0xf0330398
f0104080:	66 c7 05 9a 03 33 f0 	movw   $0x8,0xf033039a
f0104087:	08 00 
f0104089:	c6 05 9c 03 33 f0 00 	movb   $0x0,0xf033039c
f0104090:	c6 05 9d 03 33 f0 8e 	movb   $0x8e,0xf033039d
f0104097:	c1 e8 10             	shr    $0x10,%eax
f010409a:	66 a3 9e 03 33 f0    	mov    %ax,0xf033039e
    SETGATE(idt[IRQ_OFFSET + 8], 0, GD_KT, t_irq_8, 0);
f01040a0:	b8 06 49 10 f0       	mov    $0xf0104906,%eax
f01040a5:	66 a3 a0 03 33 f0    	mov    %ax,0xf03303a0
f01040ab:	66 c7 05 a2 03 33 f0 	movw   $0x8,0xf03303a2
f01040b2:	08 00 
f01040b4:	c6 05 a4 03 33 f0 00 	movb   $0x0,0xf03303a4
f01040bb:	c6 05 a5 03 33 f0 8e 	movb   $0x8e,0xf03303a5
f01040c2:	c1 e8 10             	shr    $0x10,%eax
f01040c5:	66 a3 a6 03 33 f0    	mov    %ax,0xf03303a6
    SETGATE(idt[IRQ_OFFSET + 9], 0, GD_KT, t_irq_9, 0);
f01040cb:	b8 0c 49 10 f0       	mov    $0xf010490c,%eax
f01040d0:	66 a3 a8 03 33 f0    	mov    %ax,0xf03303a8
f01040d6:	66 c7 05 aa 03 33 f0 	movw   $0x8,0xf03303aa
f01040dd:	08 00 
f01040df:	c6 05 ac 03 33 f0 00 	movb   $0x0,0xf03303ac
f01040e6:	c6 05 ad 03 33 f0 8e 	movb   $0x8e,0xf03303ad
f01040ed:	c1 e8 10             	shr    $0x10,%eax
f01040f0:	66 a3 ae 03 33 f0    	mov    %ax,0xf03303ae
    SETGATE(idt[IRQ_OFFSET + 10], 0, GD_KT, t_irq_10, 0);
f01040f6:	b8 12 49 10 f0       	mov    $0xf0104912,%eax
f01040fb:	66 a3 b0 03 33 f0    	mov    %ax,0xf03303b0
f0104101:	66 c7 05 b2 03 33 f0 	movw   $0x8,0xf03303b2
f0104108:	08 00 
f010410a:	c6 05 b4 03 33 f0 00 	movb   $0x0,0xf03303b4
f0104111:	c6 05 b5 03 33 f0 8e 	movb   $0x8e,0xf03303b5
f0104118:	c1 e8 10             	shr    $0x10,%eax
f010411b:	66 a3 b6 03 33 f0    	mov    %ax,0xf03303b6
    SETGATE(idt[IRQ_OFFSET + 11], 0, GD_KT, t_irq_11, 0);
f0104121:	b8 18 49 10 f0       	mov    $0xf0104918,%eax
f0104126:	66 a3 b8 03 33 f0    	mov    %ax,0xf03303b8
f010412c:	66 c7 05 ba 03 33 f0 	movw   $0x8,0xf03303ba
f0104133:	08 00 
f0104135:	c6 05 bc 03 33 f0 00 	movb   $0x0,0xf03303bc
f010413c:	c6 05 bd 03 33 f0 8e 	movb   $0x8e,0xf03303bd
f0104143:	c1 e8 10             	shr    $0x10,%eax
f0104146:	66 a3 be 03 33 f0    	mov    %ax,0xf03303be
    SETGATE(idt[IRQ_OFFSET + 12], 0, GD_KT, t_irq_12, 0);
f010414c:	b8 1e 49 10 f0       	mov    $0xf010491e,%eax
f0104151:	66 a3 c0 03 33 f0    	mov    %ax,0xf03303c0
f0104157:	66 c7 05 c2 03 33 f0 	movw   $0x8,0xf03303c2
f010415e:	08 00 
f0104160:	c6 05 c4 03 33 f0 00 	movb   $0x0,0xf03303c4
f0104167:	c6 05 c5 03 33 f0 8e 	movb   $0x8e,0xf03303c5
f010416e:	c1 e8 10             	shr    $0x10,%eax
f0104171:	66 a3 c6 03 33 f0    	mov    %ax,0xf03303c6
    SETGATE(idt[IRQ_OFFSET + 13], 0, GD_KT, t_irq_13, 0);
f0104177:	b8 24 49 10 f0       	mov    $0xf0104924,%eax
f010417c:	66 a3 c8 03 33 f0    	mov    %ax,0xf03303c8
f0104182:	66 c7 05 ca 03 33 f0 	movw   $0x8,0xf03303ca
f0104189:	08 00 
f010418b:	c6 05 cc 03 33 f0 00 	movb   $0x0,0xf03303cc
f0104192:	c6 05 cd 03 33 f0 8e 	movb   $0x8e,0xf03303cd
f0104199:	c1 e8 10             	shr    $0x10,%eax
f010419c:	66 a3 ce 03 33 f0    	mov    %ax,0xf03303ce
    SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 0, GD_KT, t_irq_ide, 0);
f01041a2:	b8 2a 49 10 f0       	mov    $0xf010492a,%eax
f01041a7:	66 a3 d0 03 33 f0    	mov    %ax,0xf03303d0
f01041ad:	66 c7 05 d2 03 33 f0 	movw   $0x8,0xf03303d2
f01041b4:	08 00 
f01041b6:	c6 05 d4 03 33 f0 00 	movb   $0x0,0xf03303d4
f01041bd:	c6 05 d5 03 33 f0 8e 	movb   $0x8e,0xf03303d5
f01041c4:	c1 e8 10             	shr    $0x10,%eax
f01041c7:	66 a3 d6 03 33 f0    	mov    %ax,0xf03303d6
    SETGATE(idt[IRQ_OFFSET + 15], 0, GD_KT, t_irq_15, 0);
f01041cd:	b8 30 49 10 f0       	mov    $0xf0104930,%eax
f01041d2:	66 a3 d8 03 33 f0    	mov    %ax,0xf03303d8
f01041d8:	66 c7 05 da 03 33 f0 	movw   $0x8,0xf03303da
f01041df:	08 00 
f01041e1:	c6 05 dc 03 33 f0 00 	movb   $0x0,0xf03303dc
f01041e8:	c6 05 dd 03 33 f0 8e 	movb   $0x8e,0xf03303dd
f01041ef:	c1 e8 10             	shr    $0x10,%eax
f01041f2:	66 a3 de 03 33 f0    	mov    %ax,0xf03303de
    SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall, 3);
f01041f8:	b8 36 49 10 f0       	mov    $0xf0104936,%eax
f01041fd:	66 a3 e0 03 33 f0    	mov    %ax,0xf03303e0
f0104203:	66 c7 05 e2 03 33 f0 	movw   $0x8,0xf03303e2
f010420a:	08 00 
f010420c:	c6 05 e4 03 33 f0 00 	movb   $0x0,0xf03303e4
f0104213:	c6 05 e5 03 33 f0 ee 	movb   $0xee,0xf03303e5
f010421a:	c1 e8 10             	shr    $0x10,%eax
f010421d:	66 a3 e6 03 33 f0    	mov    %ax,0xf03303e6
	trap_init_percpu();
f0104223:	e8 2e f9 ff ff       	call   f0103b56 <trap_init_percpu>
}
f0104228:	c9                   	leave  
f0104229:	c3                   	ret    

f010422a <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f010422a:	f3 0f 1e fb          	endbr32 
f010422e:	55                   	push   %ebp
f010422f:	89 e5                	mov    %esp,%ebp
f0104231:	53                   	push   %ebx
f0104232:	83 ec 0c             	sub    $0xc,%esp
f0104235:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0104238:	ff 33                	pushl  (%ebx)
f010423a:	68 19 7e 10 f0       	push   $0xf0107e19
f010423f:	e8 fa f8 ff ff       	call   f0103b3e <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0104244:	83 c4 08             	add    $0x8,%esp
f0104247:	ff 73 04             	pushl  0x4(%ebx)
f010424a:	68 28 7e 10 f0       	push   $0xf0107e28
f010424f:	e8 ea f8 ff ff       	call   f0103b3e <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0104254:	83 c4 08             	add    $0x8,%esp
f0104257:	ff 73 08             	pushl  0x8(%ebx)
f010425a:	68 37 7e 10 f0       	push   $0xf0107e37
f010425f:	e8 da f8 ff ff       	call   f0103b3e <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104264:	83 c4 08             	add    $0x8,%esp
f0104267:	ff 73 0c             	pushl  0xc(%ebx)
f010426a:	68 46 7e 10 f0       	push   $0xf0107e46
f010426f:	e8 ca f8 ff ff       	call   f0103b3e <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104274:	83 c4 08             	add    $0x8,%esp
f0104277:	ff 73 10             	pushl  0x10(%ebx)
f010427a:	68 55 7e 10 f0       	push   $0xf0107e55
f010427f:	e8 ba f8 ff ff       	call   f0103b3e <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104284:	83 c4 08             	add    $0x8,%esp
f0104287:	ff 73 14             	pushl  0x14(%ebx)
f010428a:	68 64 7e 10 f0       	push   $0xf0107e64
f010428f:	e8 aa f8 ff ff       	call   f0103b3e <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0104294:	83 c4 08             	add    $0x8,%esp
f0104297:	ff 73 18             	pushl  0x18(%ebx)
f010429a:	68 73 7e 10 f0       	push   $0xf0107e73
f010429f:	e8 9a f8 ff ff       	call   f0103b3e <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01042a4:	83 c4 08             	add    $0x8,%esp
f01042a7:	ff 73 1c             	pushl  0x1c(%ebx)
f01042aa:	68 82 7e 10 f0       	push   $0xf0107e82
f01042af:	e8 8a f8 ff ff       	call   f0103b3e <cprintf>
}
f01042b4:	83 c4 10             	add    $0x10,%esp
f01042b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01042ba:	c9                   	leave  
f01042bb:	c3                   	ret    

f01042bc <print_trapframe>:
{
f01042bc:	f3 0f 1e fb          	endbr32 
f01042c0:	55                   	push   %ebp
f01042c1:	89 e5                	mov    %esp,%ebp
f01042c3:	56                   	push   %esi
f01042c4:	53                   	push   %ebx
f01042c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01042c8:	e8 5d 21 00 00       	call   f010642a <cpunum>
f01042cd:	83 ec 04             	sub    $0x4,%esp
f01042d0:	50                   	push   %eax
f01042d1:	53                   	push   %ebx
f01042d2:	68 e6 7e 10 f0       	push   $0xf0107ee6
f01042d7:	e8 62 f8 ff ff       	call   f0103b3e <cprintf>
	print_regs(&tf->tf_regs);
f01042dc:	89 1c 24             	mov    %ebx,(%esp)
f01042df:	e8 46 ff ff ff       	call   f010422a <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01042e4:	83 c4 08             	add    $0x8,%esp
f01042e7:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01042eb:	50                   	push   %eax
f01042ec:	68 04 7f 10 f0       	push   $0xf0107f04
f01042f1:	e8 48 f8 ff ff       	call   f0103b3e <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01042f6:	83 c4 08             	add    $0x8,%esp
f01042f9:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01042fd:	50                   	push   %eax
f01042fe:	68 17 7f 10 f0       	push   $0xf0107f17
f0104303:	e8 36 f8 ff ff       	call   f0103b3e <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104308:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f010430b:	83 c4 10             	add    $0x10,%esp
f010430e:	83 f8 13             	cmp    $0x13,%eax
f0104311:	0f 86 da 00 00 00    	jbe    f01043f1 <print_trapframe+0x135>
		return "System call";
f0104317:	ba 91 7e 10 f0       	mov    $0xf0107e91,%edx
	if (trapno == T_SYSCALL)
f010431c:	83 f8 30             	cmp    $0x30,%eax
f010431f:	74 13                	je     f0104334 <print_trapframe+0x78>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104321:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f0104324:	83 fa 0f             	cmp    $0xf,%edx
f0104327:	ba 9d 7e 10 f0       	mov    $0xf0107e9d,%edx
f010432c:	b9 ac 7e 10 f0       	mov    $0xf0107eac,%ecx
f0104331:	0f 46 d1             	cmovbe %ecx,%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104334:	83 ec 04             	sub    $0x4,%esp
f0104337:	52                   	push   %edx
f0104338:	50                   	push   %eax
f0104339:	68 2a 7f 10 f0       	push   $0xf0107f2a
f010433e:	e8 fb f7 ff ff       	call   f0103b3e <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104343:	83 c4 10             	add    $0x10,%esp
f0104346:	39 1d 60 0a 33 f0    	cmp    %ebx,0xf0330a60
f010434c:	0f 84 ab 00 00 00    	je     f01043fd <print_trapframe+0x141>
	cprintf("  err  0x%08x", tf->tf_err);
f0104352:	83 ec 08             	sub    $0x8,%esp
f0104355:	ff 73 2c             	pushl  0x2c(%ebx)
f0104358:	68 4b 7f 10 f0       	push   $0xf0107f4b
f010435d:	e8 dc f7 ff ff       	call   f0103b3e <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0104362:	83 c4 10             	add    $0x10,%esp
f0104365:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104369:	0f 85 b1 00 00 00    	jne    f0104420 <print_trapframe+0x164>
			tf->tf_err & 1 ? "protection" : "not-present");
f010436f:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f0104372:	a8 01                	test   $0x1,%al
f0104374:	b9 bf 7e 10 f0       	mov    $0xf0107ebf,%ecx
f0104379:	ba ca 7e 10 f0       	mov    $0xf0107eca,%edx
f010437e:	0f 44 ca             	cmove  %edx,%ecx
f0104381:	a8 02                	test   $0x2,%al
f0104383:	be d6 7e 10 f0       	mov    $0xf0107ed6,%esi
f0104388:	ba dc 7e 10 f0       	mov    $0xf0107edc,%edx
f010438d:	0f 45 d6             	cmovne %esi,%edx
f0104390:	a8 04                	test   $0x4,%al
f0104392:	b8 e1 7e 10 f0       	mov    $0xf0107ee1,%eax
f0104397:	be 16 80 10 f0       	mov    $0xf0108016,%esi
f010439c:	0f 44 c6             	cmove  %esi,%eax
f010439f:	51                   	push   %ecx
f01043a0:	52                   	push   %edx
f01043a1:	50                   	push   %eax
f01043a2:	68 59 7f 10 f0       	push   $0xf0107f59
f01043a7:	e8 92 f7 ff ff       	call   f0103b3e <cprintf>
f01043ac:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01043af:	83 ec 08             	sub    $0x8,%esp
f01043b2:	ff 73 30             	pushl  0x30(%ebx)
f01043b5:	68 68 7f 10 f0       	push   $0xf0107f68
f01043ba:	e8 7f f7 ff ff       	call   f0103b3e <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01043bf:	83 c4 08             	add    $0x8,%esp
f01043c2:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01043c6:	50                   	push   %eax
f01043c7:	68 77 7f 10 f0       	push   $0xf0107f77
f01043cc:	e8 6d f7 ff ff       	call   f0103b3e <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01043d1:	83 c4 08             	add    $0x8,%esp
f01043d4:	ff 73 38             	pushl  0x38(%ebx)
f01043d7:	68 8a 7f 10 f0       	push   $0xf0107f8a
f01043dc:	e8 5d f7 ff ff       	call   f0103b3e <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01043e1:	83 c4 10             	add    $0x10,%esp
f01043e4:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01043e8:	75 4b                	jne    f0104435 <print_trapframe+0x179>
}
f01043ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01043ed:	5b                   	pop    %ebx
f01043ee:	5e                   	pop    %esi
f01043ef:	5d                   	pop    %ebp
f01043f0:	c3                   	ret    
		return excnames[trapno];
f01043f1:	8b 14 85 c0 81 10 f0 	mov    -0xfef7e40(,%eax,4),%edx
f01043f8:	e9 37 ff ff ff       	jmp    f0104334 <print_trapframe+0x78>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01043fd:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104401:	0f 85 4b ff ff ff    	jne    f0104352 <print_trapframe+0x96>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0104407:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010440a:	83 ec 08             	sub    $0x8,%esp
f010440d:	50                   	push   %eax
f010440e:	68 3c 7f 10 f0       	push   $0xf0107f3c
f0104413:	e8 26 f7 ff ff       	call   f0103b3e <cprintf>
f0104418:	83 c4 10             	add    $0x10,%esp
f010441b:	e9 32 ff ff ff       	jmp    f0104352 <print_trapframe+0x96>
		cprintf("\n");
f0104420:	83 ec 0c             	sub    $0xc,%esp
f0104423:	68 80 7c 10 f0       	push   $0xf0107c80
f0104428:	e8 11 f7 ff ff       	call   f0103b3e <cprintf>
f010442d:	83 c4 10             	add    $0x10,%esp
f0104430:	e9 7a ff ff ff       	jmp    f01043af <print_trapframe+0xf3>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104435:	83 ec 08             	sub    $0x8,%esp
f0104438:	ff 73 3c             	pushl  0x3c(%ebx)
f010443b:	68 99 7f 10 f0       	push   $0xf0107f99
f0104440:	e8 f9 f6 ff ff       	call   f0103b3e <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104445:	83 c4 08             	add    $0x8,%esp
f0104448:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010444c:	50                   	push   %eax
f010444d:	68 a8 7f 10 f0       	push   $0xf0107fa8
f0104452:	e8 e7 f6 ff ff       	call   f0103b3e <cprintf>
f0104457:	83 c4 10             	add    $0x10,%esp
}
f010445a:	eb 8e                	jmp    f01043ea <print_trapframe+0x12e>

f010445c <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010445c:	f3 0f 1e fb          	endbr32 
f0104460:	55                   	push   %ebp
f0104461:	89 e5                	mov    %esp,%ebp
f0104463:	57                   	push   %edi
f0104464:	56                   	push   %esi
f0104465:	53                   	push   %ebx
f0104466:	83 ec 3c             	sub    $0x3c,%esp
f0104469:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010446c:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
    if ((tf->tf_cs&0x3) == 0) {
f010446f:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104473:	74 5a                	je     f01044cf <page_fault_handler+0x73>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
    if (curenv->env_pgfault_upcall == NULL) {
f0104475:	e8 b0 1f 00 00       	call   f010642a <cpunum>
f010447a:	6b c0 74             	imul   $0x74,%eax,%eax
f010447d:	8b 80 28 10 33 f0    	mov    -0xfccefd8(%eax),%eax
f0104483:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104487:	75 64                	jne    f01044ed <page_fault_handler+0x91>
        // no pgfault handler!
        // Destroy the environment that caused the fault.
        cprintf("[%08x] user fault va %08x ip %08x\n",
f0104489:	8b 7b 30             	mov    0x30(%ebx),%edi
                curenv->env_id, fault_va, tf->tf_eip);
f010448c:	e8 99 1f 00 00       	call   f010642a <cpunum>
        cprintf("[%08x] user fault va %08x ip %08x\n",
f0104491:	57                   	push   %edi
f0104492:	56                   	push   %esi
                curenv->env_id, fault_va, tf->tf_eip);
f0104493:	6b c0 74             	imul   $0x74,%eax,%eax
        cprintf("[%08x] user fault va %08x ip %08x\n",
f0104496:	8b 80 28 10 33 f0    	mov    -0xfccefd8(%eax),%eax
f010449c:	ff 70 48             	pushl  0x48(%eax)
f010449f:	68 90 81 10 f0       	push   $0xf0108190
f01044a4:	e8 95 f6 ff ff       	call   f0103b3e <cprintf>
        print_trapframe(tf);
f01044a9:	89 1c 24             	mov    %ebx,(%esp)
f01044ac:	e8 0b fe ff ff       	call   f01042bc <print_trapframe>
        env_destroy(curenv);
f01044b1:	e8 74 1f 00 00       	call   f010642a <cpunum>
f01044b6:	83 c4 04             	add    $0x4,%esp
f01044b9:	6b c0 74             	imul   $0x74,%eax,%eax
f01044bc:	ff b0 28 10 33 f0    	pushl  -0xfccefd8(%eax)
f01044c2:	e8 40 f3 ff ff       	call   f0103807 <env_destroy>

    tf->tf_eip = (uintptr_t) curenv->env_pgfault_upcall;

    env_run(curenv);

}
f01044c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01044ca:	5b                   	pop    %ebx
f01044cb:	5e                   	pop    %esi
f01044cc:	5f                   	pop    %edi
f01044cd:	5d                   	pop    %ebp
f01044ce:	c3                   	ret    
        print_trapframe(tf);
f01044cf:	83 ec 0c             	sub    $0xc,%esp
f01044d2:	53                   	push   %ebx
f01044d3:	e8 e4 fd ff ff       	call   f01042bc <print_trapframe>
        panic("page_fault_handler: kernel page fault at %p\n", fault_va);
f01044d8:	56                   	push   %esi
f01044d9:	68 60 81 10 f0       	push   $0xf0108160
f01044de:	68 9a 01 00 00       	push   $0x19a
f01044e3:	68 bb 7f 10 f0       	push   $0xf0107fbb
f01044e8:	e8 53 bb ff ff       	call   f0100040 <_panic>
    utf.utf_err = tf->tf_err;
f01044ed:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01044f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
    utf.utf_regs = tf->tf_regs;
f01044f3:	8b 03                	mov    (%ebx),%eax
f01044f5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01044f8:	8b 43 04             	mov    0x4(%ebx),%eax
f01044fb:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01044fe:	8b 43 08             	mov    0x8(%ebx),%eax
f0104501:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0104504:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104507:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010450a:	8b 43 10             	mov    0x10(%ebx),%eax
f010450d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0104510:	8b 43 14             	mov    0x14(%ebx),%eax
f0104513:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0104516:	8b 43 18             	mov    0x18(%ebx),%eax
f0104519:	89 45 bc             	mov    %eax,-0x44(%ebp)
f010451c:	8b 43 1c             	mov    0x1c(%ebx),%eax
f010451f:	89 45 b8             	mov    %eax,-0x48(%ebp)
    utf.utf_eip = tf->tf_eip;
f0104522:	8b 43 30             	mov    0x30(%ebx),%eax
f0104525:	89 45 dc             	mov    %eax,-0x24(%ebp)
    utf.utf_eflags = tf->tf_eflags;
f0104528:	8b 43 38             	mov    0x38(%ebx),%eax
f010452b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    utf.utf_esp = tf->tf_esp;
f010452e:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104531:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (ROUNDUP(utf.utf_esp, PGSIZE) == UXSTACKTOP) {
f0104534:	05 ff 0f 00 00       	add    $0xfff,%eax
f0104539:	25 00 f0 ff ff       	and    $0xfffff000,%eax
        tf->tf_esp = UXSTACKTOP;
f010453e:	bf 00 00 c0 ee       	mov    $0xeec00000,%edi
    if (ROUNDUP(utf.utf_esp, PGSIZE) == UXSTACKTOP) {
f0104543:	3d 00 00 c0 ee       	cmp    $0xeec00000,%eax
f0104548:	0f 84 95 00 00 00    	je     f01045e3 <page_fault_handler+0x187>
    tf->tf_esp -= sizeof(struct UTrapframe);
f010454e:	83 ef 34             	sub    $0x34,%edi
f0104551:	89 7b 3c             	mov    %edi,0x3c(%ebx)
    user_mem_assert(curenv, (void *) tf->tf_esp, sizeof(struct UTrapframe),
f0104554:	e8 d1 1e 00 00       	call   f010642a <cpunum>
f0104559:	6a 07                	push   $0x7
f010455b:	6a 34                	push   $0x34
f010455d:	57                   	push   %edi
f010455e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104561:	ff b0 28 10 33 f0    	pushl  -0xfccefd8(%eax)
f0104567:	e8 7f eb ff ff       	call   f01030eb <user_mem_assert>
    *((struct UTrapframe *) tf->tf_esp) = utf;
f010456c:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010456f:	89 30                	mov    %esi,(%eax)
f0104571:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104574:	89 50 04             	mov    %edx,0x4(%eax)
f0104577:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010457a:	89 48 08             	mov    %ecx,0x8(%eax)
f010457d:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0104580:	89 50 0c             	mov    %edx,0xc(%eax)
f0104583:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0104586:	89 48 10             	mov    %ecx,0x10(%eax)
f0104589:	8b 55 c8             	mov    -0x38(%ebp),%edx
f010458c:	89 50 14             	mov    %edx,0x14(%eax)
f010458f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0104592:	89 48 18             	mov    %ecx,0x18(%eax)
f0104595:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0104598:	89 50 1c             	mov    %edx,0x1c(%eax)
f010459b:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f010459e:	89 48 20             	mov    %ecx,0x20(%eax)
f01045a1:	8b 55 b8             	mov    -0x48(%ebp),%edx
f01045a4:	89 50 24             	mov    %edx,0x24(%eax)
f01045a7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01045aa:	89 48 28             	mov    %ecx,0x28(%eax)
f01045ad:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01045b0:	89 50 2c             	mov    %edx,0x2c(%eax)
f01045b3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01045b6:	89 48 30             	mov    %ecx,0x30(%eax)
    tf->tf_eip = (uintptr_t) curenv->env_pgfault_upcall;
f01045b9:	e8 6c 1e 00 00       	call   f010642a <cpunum>
f01045be:	6b c0 74             	imul   $0x74,%eax,%eax
f01045c1:	8b 80 28 10 33 f0    	mov    -0xfccefd8(%eax),%eax
f01045c7:	8b 40 64             	mov    0x64(%eax),%eax
f01045ca:	89 43 30             	mov    %eax,0x30(%ebx)
    env_run(curenv);
f01045cd:	e8 58 1e 00 00       	call   f010642a <cpunum>
f01045d2:	83 c4 04             	add    $0x4,%esp
f01045d5:	6b c0 74             	imul   $0x74,%eax,%eax
f01045d8:	ff b0 28 10 33 f0    	pushl  -0xfccefd8(%eax)
f01045de:	e8 ea f2 ff ff       	call   f01038cd <env_run>
        tf->tf_esp -= 4;
f01045e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01045e6:	8d 78 fc             	lea    -0x4(%eax),%edi
f01045e9:	e9 60 ff ff ff       	jmp    f010454e <page_fault_handler+0xf2>

f01045ee <trap>:
{
f01045ee:	f3 0f 1e fb          	endbr32 
f01045f2:	55                   	push   %ebp
f01045f3:	89 e5                	mov    %esp,%ebp
f01045f5:	57                   	push   %edi
f01045f6:	56                   	push   %esi
f01045f7:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f01045fa:	fc                   	cld    
	if (panicstr)
f01045fb:	83 3d 80 0e 33 f0 00 	cmpl   $0x0,0xf0330e80
f0104602:	74 01                	je     f0104605 <trap+0x17>
		asm volatile("hlt");
f0104604:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104605:	e8 20 1e 00 00       	call   f010642a <cpunum>
f010460a:	6b d0 74             	imul   $0x74,%eax,%edx
f010460d:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f0104610:	b8 01 00 00 00       	mov    $0x1,%eax
f0104615:	f0 87 82 20 10 33 f0 	lock xchg %eax,-0xfccefe0(%edx)
f010461c:	83 f8 02             	cmp    $0x2,%eax
f010461f:	74 62                	je     f0104683 <trap+0x95>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104621:	9c                   	pushf  
f0104622:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f0104623:	f6 c4 02             	test   $0x2,%ah
f0104626:	75 6d                	jne    f0104695 <trap+0xa7>
	if ((tf->tf_cs & 3) == 3) {
f0104628:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010462c:	83 e0 03             	and    $0x3,%eax
f010462f:	66 83 f8 03          	cmp    $0x3,%ax
f0104633:	74 79                	je     f01046ae <trap+0xc0>
	last_tf = tf;
f0104635:	89 35 60 0a 33 f0    	mov    %esi,0xf0330a60
    switch (tf->tf_trapno) {
f010463b:	8b 46 28             	mov    0x28(%esi),%eax
f010463e:	83 f8 0e             	cmp    $0xe,%eax
f0104641:	0f 84 23 01 00 00    	je     f010476a <trap+0x17c>
f0104647:	0f 86 06 01 00 00    	jbe    f0104753 <trap+0x165>
f010464d:	83 f8 20             	cmp    $0x20,%eax
f0104650:	0f 84 4e 01 00 00    	je     f01047a4 <trap+0x1b6>
f0104656:	83 f8 30             	cmp    $0x30,%eax
f0104659:	0f 85 4f 01 00 00    	jne    f01047ae <trap+0x1c0>
            int32_t ret = syscall(tf->tf_regs.reg_eax,
f010465f:	83 ec 08             	sub    $0x8,%esp
f0104662:	ff 76 04             	pushl  0x4(%esi)
f0104665:	ff 36                	pushl  (%esi)
f0104667:	ff 76 10             	pushl  0x10(%esi)
f010466a:	ff 76 18             	pushl  0x18(%esi)
f010466d:	ff 76 14             	pushl  0x14(%esi)
f0104670:	ff 76 1c             	pushl  0x1c(%esi)
f0104673:	e8 3a 04 00 00       	call   f0104ab2 <syscall>
            tf->tf_regs.reg_eax = ret;
f0104678:	89 46 1c             	mov    %eax,0x1c(%esi)
            return;
f010467b:	83 c4 20             	add    $0x20,%esp
f010467e:	e9 f3 00 00 00       	jmp    f0104776 <trap+0x188>
	spin_lock(&kernel_lock);
f0104683:	83 ec 0c             	sub    $0xc,%esp
f0104686:	68 c0 43 12 f0       	push   $0xf01243c0
f010468b:	e8 22 20 00 00       	call   f01066b2 <spin_lock>
}
f0104690:	83 c4 10             	add    $0x10,%esp
f0104693:	eb 8c                	jmp    f0104621 <trap+0x33>
	assert(!(read_eflags() & FL_IF));
f0104695:	68 c7 7f 10 f0       	push   $0xf0107fc7
f010469a:	68 b9 79 10 f0       	push   $0xf01079b9
f010469f:	68 62 01 00 00       	push   $0x162
f01046a4:	68 bb 7f 10 f0       	push   $0xf0107fbb
f01046a9:	e8 92 b9 ff ff       	call   f0100040 <_panic>
	spin_lock(&kernel_lock);
f01046ae:	83 ec 0c             	sub    $0xc,%esp
f01046b1:	68 c0 43 12 f0       	push   $0xf01243c0
f01046b6:	e8 f7 1f 00 00       	call   f01066b2 <spin_lock>
		assert(curenv);
f01046bb:	e8 6a 1d 00 00       	call   f010642a <cpunum>
f01046c0:	6b c0 74             	imul   $0x74,%eax,%eax
f01046c3:	83 c4 10             	add    $0x10,%esp
f01046c6:	83 b8 28 10 33 f0 00 	cmpl   $0x0,-0xfccefd8(%eax)
f01046cd:	74 3e                	je     f010470d <trap+0x11f>
		if (curenv->env_status == ENV_DYING) {
f01046cf:	e8 56 1d 00 00       	call   f010642a <cpunum>
f01046d4:	6b c0 74             	imul   $0x74,%eax,%eax
f01046d7:	8b 80 28 10 33 f0    	mov    -0xfccefd8(%eax),%eax
f01046dd:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01046e1:	74 43                	je     f0104726 <trap+0x138>
		curenv->env_tf = *tf;
f01046e3:	e8 42 1d 00 00       	call   f010642a <cpunum>
f01046e8:	6b c0 74             	imul   $0x74,%eax,%eax
f01046eb:	8b 80 28 10 33 f0    	mov    -0xfccefd8(%eax),%eax
f01046f1:	b9 11 00 00 00       	mov    $0x11,%ecx
f01046f6:	89 c7                	mov    %eax,%edi
f01046f8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f01046fa:	e8 2b 1d 00 00       	call   f010642a <cpunum>
f01046ff:	6b c0 74             	imul   $0x74,%eax,%eax
f0104702:	8b b0 28 10 33 f0    	mov    -0xfccefd8(%eax),%esi
f0104708:	e9 28 ff ff ff       	jmp    f0104635 <trap+0x47>
		assert(curenv);
f010470d:	68 e0 7f 10 f0       	push   $0xf0107fe0
f0104712:	68 b9 79 10 f0       	push   $0xf01079b9
f0104717:	68 6a 01 00 00       	push   $0x16a
f010471c:	68 bb 7f 10 f0       	push   $0xf0107fbb
f0104721:	e8 1a b9 ff ff       	call   f0100040 <_panic>
			env_free(curenv);
f0104726:	e8 ff 1c 00 00       	call   f010642a <cpunum>
f010472b:	83 ec 0c             	sub    $0xc,%esp
f010472e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104731:	ff b0 28 10 33 f0    	pushl  -0xfccefd8(%eax)
f0104737:	e8 ea ee ff ff       	call   f0103626 <env_free>
			curenv = NULL;
f010473c:	e8 e9 1c 00 00       	call   f010642a <cpunum>
f0104741:	6b c0 74             	imul   $0x74,%eax,%eax
f0104744:	c7 80 28 10 33 f0 00 	movl   $0x0,-0xfccefd8(%eax)
f010474b:	00 00 00 
			sched_yield();
f010474e:	e8 c9 02 00 00       	call   f0104a1c <sched_yield>
    switch (tf->tf_trapno) {
f0104753:	83 f8 03             	cmp    $0x3,%eax
f0104756:	0f 85 89 00 00 00    	jne    f01047e5 <trap+0x1f7>
            return monitor(tf);
f010475c:	83 ec 0c             	sub    $0xc,%esp
f010475f:	56                   	push   %esi
f0104760:	e8 77 c2 ff ff       	call   f01009dc <monitor>
f0104765:	83 c4 10             	add    $0x10,%esp
f0104768:	eb 0c                	jmp    f0104776 <trap+0x188>
            return page_fault_handler(tf);
f010476a:	83 ec 0c             	sub    $0xc,%esp
f010476d:	56                   	push   %esi
f010476e:	e8 e9 fc ff ff       	call   f010445c <page_fault_handler>
f0104773:	83 c4 10             	add    $0x10,%esp
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104776:	e8 af 1c 00 00       	call   f010642a <cpunum>
f010477b:	6b c0 74             	imul   $0x74,%eax,%eax
f010477e:	83 b8 28 10 33 f0 00 	cmpl   $0x0,-0xfccefd8(%eax)
f0104785:	74 18                	je     f010479f <trap+0x1b1>
f0104787:	e8 9e 1c 00 00       	call   f010642a <cpunum>
f010478c:	6b c0 74             	imul   $0x74,%eax,%eax
f010478f:	8b 80 28 10 33 f0    	mov    -0xfccefd8(%eax),%eax
f0104795:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104799:	0f 84 8e 00 00 00    	je     f010482d <trap+0x23f>
		sched_yield();
f010479f:	e8 78 02 00 00       	call   f0104a1c <sched_yield>
            lapic_eoi();
f01047a4:	e8 d0 1d 00 00       	call   f0106579 <lapic_eoi>
            sched_yield();
f01047a9:	e8 6e 02 00 00       	call   f0104a1c <sched_yield>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01047ae:	83 f8 27             	cmp    $0x27,%eax
f01047b1:	74 11                	je     f01047c4 <trap+0x1d6>
	if(tf->tf_trapno == IRQ_OFFSET + IRQ_KBD)
f01047b3:	83 f8 21             	cmp    $0x21,%eax
f01047b6:	74 26                	je     f01047de <trap+0x1f0>
	if(tf->tf_trapno == IRQ_OFFSET + IRQ_SERIAL)
f01047b8:	83 f8 24             	cmp    $0x24,%eax
f01047bb:	75 28                	jne    f01047e5 <trap+0x1f7>
		serial_intr();
f01047bd:	e8 1b be ff ff       	call   f01005dd <serial_intr>
		return;
f01047c2:	eb b2                	jmp    f0104776 <trap+0x188>
		cprintf("Spurious interrupt on irq 7\n");
f01047c4:	83 ec 0c             	sub    $0xc,%esp
f01047c7:	68 e7 7f 10 f0       	push   $0xf0107fe7
f01047cc:	e8 6d f3 ff ff       	call   f0103b3e <cprintf>
		print_trapframe(tf);
f01047d1:	89 34 24             	mov    %esi,(%esp)
f01047d4:	e8 e3 fa ff ff       	call   f01042bc <print_trapframe>
		return;
f01047d9:	83 c4 10             	add    $0x10,%esp
f01047dc:	eb 98                	jmp    f0104776 <trap+0x188>
		kbd_intr();
f01047de:	e8 1a be ff ff       	call   f01005fd <kbd_intr>
		return;
f01047e3:	eb 91                	jmp    f0104776 <trap+0x188>
	print_trapframe(tf);
f01047e5:	83 ec 0c             	sub    $0xc,%esp
f01047e8:	56                   	push   %esi
f01047e9:	e8 ce fa ff ff       	call   f01042bc <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01047ee:	83 c4 10             	add    $0x10,%esp
f01047f1:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01047f6:	74 1e                	je     f0104816 <trap+0x228>
		env_destroy(curenv);
f01047f8:	e8 2d 1c 00 00       	call   f010642a <cpunum>
f01047fd:	83 ec 0c             	sub    $0xc,%esp
f0104800:	6b c0 74             	imul   $0x74,%eax,%eax
f0104803:	ff b0 28 10 33 f0    	pushl  -0xfccefd8(%eax)
f0104809:	e8 f9 ef ff ff       	call   f0103807 <env_destroy>
		return;
f010480e:	83 c4 10             	add    $0x10,%esp
f0104811:	e9 60 ff ff ff       	jmp    f0104776 <trap+0x188>
		panic("unhandled trap in kernel");
f0104816:	83 ec 04             	sub    $0x4,%esp
f0104819:	68 04 80 10 f0       	push   $0xf0108004
f010481e:	68 48 01 00 00       	push   $0x148
f0104823:	68 bb 7f 10 f0       	push   $0xf0107fbb
f0104828:	e8 13 b8 ff ff       	call   f0100040 <_panic>
		env_run(curenv);
f010482d:	e8 f8 1b 00 00       	call   f010642a <cpunum>
f0104832:	83 ec 0c             	sub    $0xc,%esp
f0104835:	6b c0 74             	imul   $0x74,%eax,%eax
f0104838:	ff b0 28 10 33 f0    	pushl  -0xfccefd8(%eax)
f010483e:	e8 8a f0 ff ff       	call   f01038cd <env_run>
f0104843:	90                   	nop

f0104844 <t_divide>:
// HINT 2 : TRAPHANDLER(t_dblflt, T_DBLFLT);
//          Do something like this if the trap includes an error code..
// HINT 3 : READ Intel's manual to check if the trap includes an error code
//          or not...

TRAPHANDLER_NOEC(t_divide, T_DIVIDE);    // 0
f0104844:	6a 00                	push   $0x0
f0104846:	6a 00                	push   $0x0
f0104848:	e9 ef 00 00 00       	jmp    f010493c <_alltraps>
f010484d:	90                   	nop

f010484e <t_debug>:
TRAPHANDLER_NOEC(t_debug, T_DEBUG);      // 1
f010484e:	6a 00                	push   $0x0
f0104850:	6a 01                	push   $0x1
f0104852:	e9 e5 00 00 00       	jmp    f010493c <_alltraps>
f0104857:	90                   	nop

f0104858 <t_nmi>:
TRAPHANDLER_NOEC(t_nmi, T_NMI);          // 2
f0104858:	6a 00                	push   $0x0
f010485a:	6a 02                	push   $0x2
f010485c:	e9 db 00 00 00       	jmp    f010493c <_alltraps>
f0104861:	90                   	nop

f0104862 <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT);      // 3
f0104862:	6a 00                	push   $0x0
f0104864:	6a 03                	push   $0x3
f0104866:	e9 d1 00 00 00       	jmp    f010493c <_alltraps>
f010486b:	90                   	nop

f010486c <t_oflow>:
TRAPHANDLER_NOEC(t_oflow, T_OFLOW);      // 4
f010486c:	6a 00                	push   $0x0
f010486e:	6a 04                	push   $0x4
f0104870:	e9 c7 00 00 00       	jmp    f010493c <_alltraps>
f0104875:	90                   	nop

f0104876 <t_bound>:
TRAPHANDLER_NOEC(t_bound, T_BOUND);      // 5
f0104876:	6a 00                	push   $0x0
f0104878:	6a 05                	push   $0x5
f010487a:	e9 bd 00 00 00       	jmp    f010493c <_alltraps>
f010487f:	90                   	nop

f0104880 <t_illop>:
TRAPHANDLER_NOEC(t_illop, T_ILLOP);      // 6
f0104880:	6a 00                	push   $0x0
f0104882:	6a 06                	push   $0x6
f0104884:	e9 b3 00 00 00       	jmp    f010493c <_alltraps>
f0104889:	90                   	nop

f010488a <t_device>:
TRAPHANDLER_NOEC(t_device, T_DEVICE);    // 7
f010488a:	6a 00                	push   $0x0
f010488c:	6a 07                	push   $0x7
f010488e:	e9 a9 00 00 00       	jmp    f010493c <_alltraps>
f0104893:	90                   	nop

f0104894 <t_dblflt>:

TRAPHANDLER(t_dblflt, T_DBLFLT);    // 8
f0104894:	6a 08                	push   $0x8
f0104896:	e9 a1 00 00 00       	jmp    f010493c <_alltraps>
f010489b:	90                   	nop

f010489c <t_tss>:

TRAPHANDLER(t_tss, T_TSS);          // 10
f010489c:	6a 0a                	push   $0xa
f010489e:	e9 99 00 00 00       	jmp    f010493c <_alltraps>
f01048a3:	90                   	nop

f01048a4 <t_segnp>:
TRAPHANDLER(t_segnp, T_SEGNP);      // 11
f01048a4:	6a 0b                	push   $0xb
f01048a6:	e9 91 00 00 00       	jmp    f010493c <_alltraps>
f01048ab:	90                   	nop

f01048ac <t_stack>:
TRAPHANDLER(t_stack, T_STACK);      // 12
f01048ac:	6a 0c                	push   $0xc
f01048ae:	e9 89 00 00 00       	jmp    f010493c <_alltraps>
f01048b3:	90                   	nop

f01048b4 <t_gpflt>:
TRAPHANDLER(t_gpflt, T_GPFLT);      // 13
f01048b4:	6a 0d                	push   $0xd
f01048b6:	e9 81 00 00 00       	jmp    f010493c <_alltraps>
f01048bb:	90                   	nop

f01048bc <t_pgflt>:
TRAPHANDLER(t_pgflt, T_PGFLT);      // 14
f01048bc:	6a 0e                	push   $0xe
f01048be:	eb 7c                	jmp    f010493c <_alltraps>

f01048c0 <t_fperr>:

TRAPHANDLER_NOEC(t_fperr, T_FPERR);      // 16
f01048c0:	6a 00                	push   $0x0
f01048c2:	6a 10                	push   $0x10
f01048c4:	eb 76                	jmp    f010493c <_alltraps>

f01048c6 <t_align>:

TRAPHANDLER(t_align, T_ALIGN);      // 17
f01048c6:	6a 11                	push   $0x11
f01048c8:	eb 72                	jmp    f010493c <_alltraps>

f01048ca <t_mchk>:

TRAPHANDLER_NOEC(t_mchk, T_MCHK);        // 18
f01048ca:	6a 00                	push   $0x0
f01048cc:	6a 12                	push   $0x12
f01048ce:	eb 6c                	jmp    f010493c <_alltraps>

f01048d0 <t_simderr>:
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR);  // 19
f01048d0:	6a 00                	push   $0x0
f01048d2:	6a 13                	push   $0x13
f01048d4:	eb 66                	jmp    f010493c <_alltraps>

f01048d6 <t_irq_timer>:


TRAPHANDLER_NOEC(t_irq_timer, IRQ_OFFSET + IRQ_TIMER); // 32 + 0
f01048d6:	6a 00                	push   $0x0
f01048d8:	6a 20                	push   $0x20
f01048da:	eb 60                	jmp    f010493c <_alltraps>

f01048dc <t_irq_kbd>:
TRAPHANDLER_NOEC(t_irq_kbd, IRQ_OFFSET + IRQ_KBD); // 32 + 1
f01048dc:	6a 00                	push   $0x0
f01048de:	6a 21                	push   $0x21
f01048e0:	eb 5a                	jmp    f010493c <_alltraps>

f01048e2 <t_irq_2>:
TRAPHANDLER_NOEC(t_irq_2, IRQ_OFFSET + 2); // 32 + 2
f01048e2:	6a 00                	push   $0x0
f01048e4:	6a 22                	push   $0x22
f01048e6:	eb 54                	jmp    f010493c <_alltraps>

f01048e8 <t_irq_3>:
TRAPHANDLER_NOEC(t_irq_3, IRQ_OFFSET + 3); // 32 + 3
f01048e8:	6a 00                	push   $0x0
f01048ea:	6a 23                	push   $0x23
f01048ec:	eb 4e                	jmp    f010493c <_alltraps>

f01048ee <t_irq_serial>:
TRAPHANDLER_NOEC(t_irq_serial, IRQ_OFFSET + IRQ_SERIAL); // 32 + 4
f01048ee:	6a 00                	push   $0x0
f01048f0:	6a 24                	push   $0x24
f01048f2:	eb 48                	jmp    f010493c <_alltraps>

f01048f4 <t_irq_5>:
TRAPHANDLER_NOEC(t_irq_5, IRQ_OFFSET + 5); // 32 + 5
f01048f4:	6a 00                	push   $0x0
f01048f6:	6a 25                	push   $0x25
f01048f8:	eb 42                	jmp    f010493c <_alltraps>

f01048fa <t_irq_6>:
TRAPHANDLER_NOEC(t_irq_6, IRQ_OFFSET + 6); // 32 + 6
f01048fa:	6a 00                	push   $0x0
f01048fc:	6a 26                	push   $0x26
f01048fe:	eb 3c                	jmp    f010493c <_alltraps>

f0104900 <t_irq_spurious>:
TRAPHANDLER_NOEC(t_irq_spurious, IRQ_OFFSET + IRQ_SPURIOUS); // 32 + 7
f0104900:	6a 00                	push   $0x0
f0104902:	6a 27                	push   $0x27
f0104904:	eb 36                	jmp    f010493c <_alltraps>

f0104906 <t_irq_8>:
TRAPHANDLER_NOEC(t_irq_8, IRQ_OFFSET + 8); // 32 + 8
f0104906:	6a 00                	push   $0x0
f0104908:	6a 28                	push   $0x28
f010490a:	eb 30                	jmp    f010493c <_alltraps>

f010490c <t_irq_9>:
TRAPHANDLER_NOEC(t_irq_9, IRQ_OFFSET + 9); // 32 + 9
f010490c:	6a 00                	push   $0x0
f010490e:	6a 29                	push   $0x29
f0104910:	eb 2a                	jmp    f010493c <_alltraps>

f0104912 <t_irq_10>:
TRAPHANDLER_NOEC(t_irq_10, IRQ_OFFSET + 10); // 32 + 10
f0104912:	6a 00                	push   $0x0
f0104914:	6a 2a                	push   $0x2a
f0104916:	eb 24                	jmp    f010493c <_alltraps>

f0104918 <t_irq_11>:
TRAPHANDLER_NOEC(t_irq_11, IRQ_OFFSET + 11); // 32 + 11
f0104918:	6a 00                	push   $0x0
f010491a:	6a 2b                	push   $0x2b
f010491c:	eb 1e                	jmp    f010493c <_alltraps>

f010491e <t_irq_12>:
TRAPHANDLER_NOEC(t_irq_12, IRQ_OFFSET + 12); // 32 + 12
f010491e:	6a 00                	push   $0x0
f0104920:	6a 2c                	push   $0x2c
f0104922:	eb 18                	jmp    f010493c <_alltraps>

f0104924 <t_irq_13>:
TRAPHANDLER_NOEC(t_irq_13, IRQ_OFFSET + 13); // 32 + 13
f0104924:	6a 00                	push   $0x0
f0104926:	6a 2d                	push   $0x2d
f0104928:	eb 12                	jmp    f010493c <_alltraps>

f010492a <t_irq_ide>:
TRAPHANDLER_NOEC(t_irq_ide, IRQ_OFFSET + IRQ_IDE); // 32 + 14
f010492a:	6a 00                	push   $0x0
f010492c:	6a 2e                	push   $0x2e
f010492e:	eb 0c                	jmp    f010493c <_alltraps>

f0104930 <t_irq_15>:
TRAPHANDLER_NOEC(t_irq_15, IRQ_OFFSET + 15); // 32 + 15
f0104930:	6a 00                	push   $0x0
f0104932:	6a 2f                	push   $0x2f
f0104934:	eb 06                	jmp    f010493c <_alltraps>

f0104936 <t_syscall>:

TRAPHANDLER_NOEC(t_syscall, T_SYSCALL);  // 48, 0x30
f0104936:	6a 00                	push   $0x0
f0104938:	6a 30                	push   $0x30
f010493a:	eb 00                	jmp    f010493c <_alltraps>

f010493c <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */

_alltraps:
    pushl %ds
f010493c:	1e                   	push   %ds
    pushl %es
f010493d:	06                   	push   %es
    pushal
f010493e:	60                   	pusha  

    movl $GD_KD, %eax
f010493f:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
f0104944:	8e d8                	mov    %eax,%ds
    movw %ax, %es
f0104946:	8e c0                	mov    %eax,%es

    pushl %esp
f0104948:	54                   	push   %esp

    call trap
f0104949:	e8 a0 fc ff ff       	call   f01045ee <trap>

f010494e <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f010494e:	f3 0f 1e fb          	endbr32 
f0104952:	55                   	push   %ebp
f0104953:	89 e5                	mov    %esp,%ebp
f0104955:	83 ec 08             	sub    $0x8,%esp
f0104958:	a1 44 02 33 f0       	mov    0xf0330244,%eax
f010495d:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104960:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104965:	8b 02                	mov    (%edx),%eax
f0104967:	83 e8 01             	sub    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f010496a:	83 f8 02             	cmp    $0x2,%eax
f010496d:	76 2d                	jbe    f010499c <sched_halt+0x4e>
	for (i = 0; i < NENV; i++) {
f010496f:	83 c1 01             	add    $0x1,%ecx
f0104972:	83 c2 7c             	add    $0x7c,%edx
f0104975:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f010497b:	75 e8                	jne    f0104965 <sched_halt+0x17>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f010497d:	83 ec 0c             	sub    $0xc,%esp
f0104980:	68 10 82 10 f0       	push   $0xf0108210
f0104985:	e8 b4 f1 ff ff       	call   f0103b3e <cprintf>
f010498a:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f010498d:	83 ec 0c             	sub    $0xc,%esp
f0104990:	6a 00                	push   $0x0
f0104992:	e8 45 c0 ff ff       	call   f01009dc <monitor>
f0104997:	83 c4 10             	add    $0x10,%esp
f010499a:	eb f1                	jmp    f010498d <sched_halt+0x3f>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f010499c:	e8 89 1a 00 00       	call   f010642a <cpunum>
f01049a1:	6b c0 74             	imul   $0x74,%eax,%eax
f01049a4:	c7 80 28 10 33 f0 00 	movl   $0x0,-0xfccefd8(%eax)
f01049ab:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f01049ae:	a1 8c 0e 33 f0       	mov    0xf0330e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01049b3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01049b8:	76 50                	jbe    f0104a0a <sched_halt+0xbc>
	return (physaddr_t)kva - KERNBASE;
f01049ba:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01049bf:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f01049c2:	e8 63 1a 00 00       	call   f010642a <cpunum>
f01049c7:	6b d0 74             	imul   $0x74,%eax,%edx
f01049ca:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f01049cd:	b8 02 00 00 00       	mov    $0x2,%eax
f01049d2:	f0 87 82 20 10 33 f0 	lock xchg %eax,-0xfccefe0(%edx)
	spin_unlock(&kernel_lock);
f01049d9:	83 ec 0c             	sub    $0xc,%esp
f01049dc:	68 c0 43 12 f0       	push   $0xf01243c0
f01049e1:	e8 6a 1d 00 00       	call   f0106750 <spin_unlock>
	asm volatile("pause");
f01049e6:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f01049e8:	e8 3d 1a 00 00       	call   f010642a <cpunum>
f01049ed:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile (
f01049f0:	8b 80 30 10 33 f0    	mov    -0xfccefd0(%eax),%eax
f01049f6:	bd 00 00 00 00       	mov    $0x0,%ebp
f01049fb:	89 c4                	mov    %eax,%esp
f01049fd:	6a 00                	push   $0x0
f01049ff:	6a 00                	push   $0x0
f0104a01:	fb                   	sti    
f0104a02:	f4                   	hlt    
f0104a03:	eb fd                	jmp    f0104a02 <sched_halt+0xb4>
}
f0104a05:	83 c4 10             	add    $0x10,%esp
f0104a08:	c9                   	leave  
f0104a09:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104a0a:	50                   	push   %eax
f0104a0b:	68 e8 6a 10 f0       	push   $0xf0106ae8
f0104a10:	6a 50                	push   $0x50
f0104a12:	68 39 82 10 f0       	push   $0xf0108239
f0104a17:	e8 24 b6 ff ff       	call   f0100040 <_panic>

f0104a1c <sched_yield>:
{
f0104a1c:	f3 0f 1e fb          	endbr32 
f0104a20:	55                   	push   %ebp
f0104a21:	89 e5                	mov    %esp,%ebp
f0104a23:	56                   	push   %esi
f0104a24:	53                   	push   %ebx
    for (uint32_t i = probing_env_idx; i < (probing_env_idx + NENV); ++i) {
f0104a25:	8b 1d 64 0a 33 f0    	mov    0xf0330a64,%ebx
        if (envs[env_idx].env_status == ENV_RUNNABLE) {
f0104a2b:	8b 35 44 02 33 f0    	mov    0xf0330244,%esi
    for (uint32_t i = probing_env_idx; i < (probing_env_idx + NENV); ++i) {
f0104a31:	89 d8                	mov    %ebx,%eax
f0104a33:	81 c3 00 04 00 00    	add    $0x400,%ebx
f0104a39:	39 c3                	cmp    %eax,%ebx
f0104a3b:	76 2e                	jbe    f0104a6b <sched_yield+0x4f>
        uint32_t env_idx = i % NENV;
f0104a3d:	89 c1                	mov    %eax,%ecx
f0104a3f:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
        if (envs[env_idx].env_status == ENV_RUNNABLE) {
f0104a45:	6b d1 7c             	imul   $0x7c,%ecx,%edx
f0104a48:	01 f2                	add    %esi,%edx
f0104a4a:	83 7a 54 02          	cmpl   $0x2,0x54(%edx)
f0104a4e:	74 05                	je     f0104a55 <sched_yield+0x39>
    for (uint32_t i = probing_env_idx; i < (probing_env_idx + NENV); ++i) {
f0104a50:	83 c0 01             	add    $0x1,%eax
f0104a53:	eb e4                	jmp    f0104a39 <sched_yield+0x1d>
            probing_env_idx = (env_idx + 1) % NENV;
f0104a55:	8d 41 01             	lea    0x1(%ecx),%eax
f0104a58:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104a5d:	a3 64 0a 33 f0       	mov    %eax,0xf0330a64
            env_run(target_env);
f0104a62:	83 ec 0c             	sub    $0xc,%esp
f0104a65:	52                   	push   %edx
f0104a66:	e8 62 ee ff ff       	call   f01038cd <env_run>
    if (curenv && curenv->env_status == ENV_RUNNING) {
f0104a6b:	e8 ba 19 00 00       	call   f010642a <cpunum>
f0104a70:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a73:	83 b8 28 10 33 f0 00 	cmpl   $0x0,-0xfccefd8(%eax)
f0104a7a:	74 14                	je     f0104a90 <sched_yield+0x74>
f0104a7c:	e8 a9 19 00 00       	call   f010642a <cpunum>
f0104a81:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a84:	8b 80 28 10 33 f0    	mov    -0xfccefd8(%eax),%eax
f0104a8a:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104a8e:	74 0c                	je     f0104a9c <sched_yield+0x80>
	sched_halt();
f0104a90:	e8 b9 fe ff ff       	call   f010494e <sched_halt>
}
f0104a95:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104a98:	5b                   	pop    %ebx
f0104a99:	5e                   	pop    %esi
f0104a9a:	5d                   	pop    %ebp
f0104a9b:	c3                   	ret    
        env_run(curenv);
f0104a9c:	e8 89 19 00 00       	call   f010642a <cpunum>
f0104aa1:	83 ec 0c             	sub    $0xc,%esp
f0104aa4:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aa7:	ff b0 28 10 33 f0    	pushl  -0xfccefd8(%eax)
f0104aad:	e8 1b ee ff ff       	call   f01038cd <env_run>

f0104ab2 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104ab2:	f3 0f 1e fb          	endbr32 
f0104ab6:	55                   	push   %ebp
f0104ab7:	89 e5                	mov    %esp,%ebp
f0104ab9:	57                   	push   %edi
f0104aba:	56                   	push   %esi
f0104abb:	83 ec 10             	sub    $0x10,%esp
f0104abe:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ac1:	83 f8 0d             	cmp    $0xd,%eax
f0104ac4:	0f 87 fa 06 00 00    	ja     f01051c4 <syscall+0x712>
f0104aca:	3e ff 24 85 b4 82 10 	notrack jmp *-0xfef7d4c(,%eax,4)
f0104ad1:	f0 
    user_mem_assert(curenv, s, len, PTE_U|PTE_P);
f0104ad2:	e8 53 19 00 00       	call   f010642a <cpunum>
f0104ad7:	6a 05                	push   $0x5
f0104ad9:	ff 75 10             	pushl  0x10(%ebp)
f0104adc:	ff 75 0c             	pushl  0xc(%ebp)
f0104adf:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ae2:	ff b0 28 10 33 f0    	pushl  -0xfccefd8(%eax)
f0104ae8:	e8 fe e5 ff ff       	call   f01030eb <user_mem_assert>
	cprintf("%.*s", len, s);
f0104aed:	83 c4 0c             	add    $0xc,%esp
f0104af0:	ff 75 0c             	pushl  0xc(%ebp)
f0104af3:	ff 75 10             	pushl  0x10(%ebp)
f0104af6:	68 55 6e 10 f0       	push   $0xf0106e55
f0104afb:	e8 3e f0 ff ff       	call   f0103b3e <cprintf>
}
f0104b00:	83 c4 10             	add    $0x10,%esp

	switch (syscallno) {
    case SYS_cputs:
    {
        sys_cputs((const char *)a1, (size_t) a2);
        return 0;
f0104b03:	b8 00 00 00 00       	mov    $0x0,%eax
	default:
	    panic("syscall %d not implemented", syscallno);
		return -E_INVAL;
	}

}
f0104b08:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104b0b:	5e                   	pop    %esi
f0104b0c:	5f                   	pop    %edi
f0104b0d:	5d                   	pop    %ebp
f0104b0e:	c3                   	ret    
	return cons_getc();
f0104b0f:	e8 ff ba ff ff       	call   f0100613 <cons_getc>
        return sys_cgetc();
f0104b14:	eb f2                	jmp    f0104b08 <syscall+0x56>
	return curenv->env_id;
f0104b16:	e8 0f 19 00 00       	call   f010642a <cpunum>
f0104b1b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b1e:	8b 80 28 10 33 f0    	mov    -0xfccefd8(%eax),%eax
f0104b24:	8b 40 48             	mov    0x48(%eax),%eax
        return (int32_t) sys_getenvid();
f0104b27:	eb df                	jmp    f0104b08 <syscall+0x56>
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104b29:	83 ec 04             	sub    $0x4,%esp
f0104b2c:	6a 01                	push   $0x1
f0104b2e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104b31:	50                   	push   %eax
f0104b32:	ff 75 0c             	pushl  0xc(%ebp)
f0104b35:	e8 be e6 ff ff       	call   f01031f8 <envid2env>
f0104b3a:	83 c4 10             	add    $0x10,%esp
f0104b3d:	85 c0                	test   %eax,%eax
f0104b3f:	78 c7                	js     f0104b08 <syscall+0x56>
	if (e == curenv)
f0104b41:	e8 e4 18 00 00       	call   f010642a <cpunum>
f0104b46:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104b49:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b4c:	39 90 28 10 33 f0    	cmp    %edx,-0xfccefd8(%eax)
f0104b52:	74 3d                	je     f0104b91 <syscall+0xdf>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104b54:	8b 72 48             	mov    0x48(%edx),%esi
f0104b57:	e8 ce 18 00 00       	call   f010642a <cpunum>
f0104b5c:	83 ec 04             	sub    $0x4,%esp
f0104b5f:	56                   	push   %esi
f0104b60:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b63:	8b 80 28 10 33 f0    	mov    -0xfccefd8(%eax),%eax
f0104b69:	ff 70 48             	pushl  0x48(%eax)
f0104b6c:	68 61 82 10 f0       	push   $0xf0108261
f0104b71:	e8 c8 ef ff ff       	call   f0103b3e <cprintf>
f0104b76:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104b79:	83 ec 0c             	sub    $0xc,%esp
f0104b7c:	ff 75 f4             	pushl  -0xc(%ebp)
f0104b7f:	e8 83 ec ff ff       	call   f0103807 <env_destroy>
	return 0;
f0104b84:	83 c4 10             	add    $0x10,%esp
f0104b87:	b8 00 00 00 00       	mov    $0x0,%eax
        return sys_env_destroy((envid_t) a1);
f0104b8c:	e9 77 ff ff ff       	jmp    f0104b08 <syscall+0x56>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104b91:	e8 94 18 00 00       	call   f010642a <cpunum>
f0104b96:	83 ec 08             	sub    $0x8,%esp
f0104b99:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b9c:	8b 80 28 10 33 f0    	mov    -0xfccefd8(%eax),%eax
f0104ba2:	ff 70 48             	pushl  0x48(%eax)
f0104ba5:	68 46 82 10 f0       	push   $0xf0108246
f0104baa:	e8 8f ef ff ff       	call   f0103b3e <cprintf>
f0104baf:	83 c4 10             	add    $0x10,%esp
f0104bb2:	eb c5                	jmp    f0104b79 <syscall+0xc7>
	sched_yield();
f0104bb4:	e8 63 fe ff ff       	call   f0104a1c <sched_yield>
    struct Env *e = NULL;
f0104bb9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (envid2env(envid, &e, 1) < 0) {
f0104bc0:	83 ec 04             	sub    $0x4,%esp
f0104bc3:	6a 01                	push   $0x1
f0104bc5:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104bc8:	50                   	push   %eax
f0104bc9:	ff 75 0c             	pushl  0xc(%ebp)
f0104bcc:	e8 27 e6 ff ff       	call   f01031f8 <envid2env>
f0104bd1:	83 c4 10             	add    $0x10,%esp
f0104bd4:	85 c0                	test   %eax,%eax
f0104bd6:	0f 88 9b 00 00 00    	js     f0104c77 <syscall+0x1c5>
    if (e == NULL) {
f0104bdc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0104be0:	0f 84 9b 00 00 00    	je     f0104c81 <syscall+0x1cf>
    if (((uintptr_t)va) >= UTOP) {
f0104be6:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104bed:	0f 87 98 00 00 00    	ja     f0104c8b <syscall+0x1d9>
    if (PGOFF(va)) return -E_INVAL;
f0104bf3:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104bfa:	0f 85 95 00 00 00    	jne    f0104c95 <syscall+0x1e3>
    if (!(perm & PTE_SYSCALL)) return -E_INVAL;
f0104c00:	f7 45 14 07 0e 00 00 	testl  $0xe07,0x14(%ebp)
f0104c07:	0f 84 92 00 00 00    	je     f0104c9f <syscall+0x1ed>
    struct PageInfo *pp = page_alloc(ALLOC_ZERO);
f0104c0d:	83 ec 0c             	sub    $0xc,%esp
f0104c10:	6a 01                	push   $0x1
f0104c12:	e8 e7 c3 ff ff       	call   f0100ffe <page_alloc>
f0104c17:	89 c6                	mov    %eax,%esi
    if (pp == NULL) {
f0104c19:	83 c4 10             	add    $0x10,%esp
f0104c1c:	85 c0                	test   %eax,%eax
f0104c1e:	0f 84 85 00 00 00    	je     f0104ca9 <syscall+0x1f7>
    if (page_insert(e->env_pgdir, pp, va, perm) != 0) {
f0104c24:	ff 75 14             	pushl  0x14(%ebp)
f0104c27:	ff 75 10             	pushl  0x10(%ebp)
f0104c2a:	50                   	push   %eax
f0104c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104c2e:	ff 70 60             	pushl  0x60(%eax)
f0104c31:	e8 96 c6 ff ff       	call   f01012cc <page_insert>
f0104c36:	83 c4 10             	add    $0x10,%esp
f0104c39:	85 c0                	test   %eax,%eax
f0104c3b:	0f 84 c7 fe ff ff    	je     f0104b08 <syscall+0x56>
        assert(pp->pp_ref == 0);
f0104c41:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0104c46:	75 16                	jne    f0104c5e <syscall+0x1ac>
        page_free(pp);
f0104c48:	83 ec 0c             	sub    $0xc,%esp
f0104c4b:	56                   	push   %esi
f0104c4c:	e8 26 c4 ff ff       	call   f0101077 <page_free>
        return -E_NO_MEM;
f0104c51:	83 c4 10             	add    $0x10,%esp
f0104c54:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104c59:	e9 aa fe ff ff       	jmp    f0104b08 <syscall+0x56>
        assert(pp->pp_ref == 0);
f0104c5e:	68 79 82 10 f0       	push   $0xf0108279
f0104c63:	68 b9 79 10 f0       	push   $0xf01079b9
f0104c68:	68 0b 01 00 00       	push   $0x10b
f0104c6d:	68 89 82 10 f0       	push   $0xf0108289
f0104c72:	e8 c9 b3 ff ff       	call   f0100040 <_panic>
        return -E_BAD_ENV;
f0104c77:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104c7c:	e9 87 fe ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_BAD_ENV;
f0104c81:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104c86:	e9 7d fe ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_INVAL;
f0104c8b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104c90:	e9 73 fe ff ff       	jmp    f0104b08 <syscall+0x56>
    if (PGOFF(va)) return -E_INVAL;
f0104c95:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104c9a:	e9 69 fe ff ff       	jmp    f0104b08 <syscall+0x56>
    if (!(perm & PTE_SYSCALL)) return -E_INVAL;
f0104c9f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104ca4:	e9 5f fe ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_NO_MEM;
f0104ca9:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
        return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
f0104cae:	e9 55 fe ff ff       	jmp    f0104b08 <syscall+0x56>
    struct Env *srcenv = NULL;
f0104cb3:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    if (envid2env(srcenvid, &srcenv, 1) < 0)
f0104cba:	83 ec 04             	sub    $0x4,%esp
f0104cbd:	6a 01                	push   $0x1
f0104cbf:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0104cc2:	50                   	push   %eax
f0104cc3:	ff 75 0c             	pushl  0xc(%ebp)
f0104cc6:	e8 2d e5 ff ff       	call   f01031f8 <envid2env>
f0104ccb:	83 c4 10             	add    $0x10,%esp
f0104cce:	85 c0                	test   %eax,%eax
f0104cd0:	0f 88 09 01 00 00    	js     f0104ddf <syscall+0x32d>
    if (srcenv == NULL)
f0104cd6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104cda:	0f 84 09 01 00 00    	je     f0104de9 <syscall+0x337>
    struct Env *dstenv = NULL;
f0104ce0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    if (envid2env(dstenvid, &dstenv, 1) < 0)
f0104ce7:	83 ec 04             	sub    $0x4,%esp
f0104cea:	6a 01                	push   $0x1
f0104cec:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104cef:	50                   	push   %eax
f0104cf0:	ff 75 14             	pushl  0x14(%ebp)
f0104cf3:	e8 00 e5 ff ff       	call   f01031f8 <envid2env>
f0104cf8:	83 c4 10             	add    $0x10,%esp
f0104cfb:	85 c0                	test   %eax,%eax
f0104cfd:	0f 88 f0 00 00 00    	js     f0104df3 <syscall+0x341>
    if (dstenv == NULL)
f0104d03:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0104d07:	0f 84 f0 00 00 00    	je     f0104dfd <syscall+0x34b>
    if ( ((uintptr_t)dstva) >= UTOP )
f0104d0d:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104d14:	0f 87 ed 00 00 00    	ja     f0104e07 <syscall+0x355>
f0104d1a:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104d21:	0f 87 e0 00 00 00    	ja     f0104e07 <syscall+0x355>
    if (!(PTE_P & perm)) {
f0104d27:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0104d2a:	83 e0 05             	and    $0x5,%eax
f0104d2d:	83 f8 05             	cmp    $0x5,%eax
f0104d30:	0f 85 db 00 00 00    	jne    f0104e11 <syscall+0x35f>
    pte_t *src_pte = NULL, *dst_pte = NULL;
f0104d36:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0104d3d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    struct PageInfo *src_pp = page_lookup(srcenv->env_pgdir, srcva, &src_pte);
f0104d44:	83 ec 04             	sub    $0x4,%esp
f0104d47:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0104d4a:	50                   	push   %eax
f0104d4b:	ff 75 10             	pushl  0x10(%ebp)
f0104d4e:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104d51:	ff 70 60             	pushl  0x60(%eax)
f0104d54:	e8 8a c4 ff ff       	call   f01011e3 <page_lookup>
f0104d59:	89 c6                	mov    %eax,%esi
    if (src_pte == NULL)
f0104d5b:	83 c4 10             	add    $0x10,%esp
f0104d5e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0104d62:	0f 84 b3 00 00 00    	je     f0104e1b <syscall+0x369>
    struct PageInfo *dst_pp = page_lookup(dstenv->env_pgdir, dstva, &dst_pte);
f0104d68:	83 ec 04             	sub    $0x4,%esp
f0104d6b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104d6e:	50                   	push   %eax
f0104d6f:	ff 75 18             	pushl  0x18(%ebp)
f0104d72:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104d75:	ff 70 60             	pushl  0x60(%eax)
f0104d78:	e8 66 c4 ff ff       	call   f01011e3 <page_lookup>
    if (dst_pte == NULL) {
f0104d7d:	83 c4 10             	add    $0x10,%esp
f0104d80:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0104d84:	74 32                	je     f0104db8 <syscall+0x306>
    if ( (perm&PTE_W) && ((*src_pte & PTE_W) == 0) ) {
f0104d86:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104d8a:	74 0c                	je     f0104d98 <syscall+0x2e6>
f0104d8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104d8f:	f6 00 02             	testb  $0x2,(%eax)
f0104d92:	0f 84 8d 00 00 00    	je     f0104e25 <syscall+0x373>
    if (page_insert(dstenv->env_pgdir, src_pp, dstva, perm) < 0)
f0104d98:	ff 75 1c             	pushl  0x1c(%ebp)
f0104d9b:	ff 75 18             	pushl  0x18(%ebp)
f0104d9e:	56                   	push   %esi
f0104d9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104da2:	ff 70 60             	pushl  0x60(%eax)
f0104da5:	e8 22 c5 ff ff       	call   f01012cc <page_insert>
f0104daa:	83 c4 10             	add    $0x10,%esp
        return -E_NO_MEM;
f0104dad:	c1 f8 1f             	sar    $0x1f,%eax
f0104db0:	83 e0 fc             	and    $0xfffffffc,%eax
f0104db3:	e9 50 fd ff ff       	jmp    f0104b08 <syscall+0x56>
        dst_pte = pgdir_walk(dstenv->env_pgdir, dstva, 1);
f0104db8:	83 ec 04             	sub    $0x4,%esp
f0104dbb:	6a 01                	push   $0x1
f0104dbd:	ff 75 18             	pushl  0x18(%ebp)
f0104dc0:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104dc3:	ff 70 60             	pushl  0x60(%eax)
f0104dc6:	e8 18 c3 ff ff       	call   f01010e3 <pgdir_walk>
f0104dcb:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (dst_pte == NULL) {
f0104dce:	83 c4 10             	add    $0x10,%esp
f0104dd1:	85 c0                	test   %eax,%eax
f0104dd3:	75 b1                	jne    f0104d86 <syscall+0x2d4>
            return -E_NO_MEM;
f0104dd5:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104dda:	e9 29 fd ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_BAD_ENV;
f0104ddf:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104de4:	e9 1f fd ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_BAD_ENV;
f0104de9:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104dee:	e9 15 fd ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_BAD_ENV;
f0104df3:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104df8:	e9 0b fd ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_BAD_ENV;
f0104dfd:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104e02:	e9 01 fd ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_INVAL;
f0104e07:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104e0c:	e9 f7 fc ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_INVAL;
f0104e11:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104e16:	e9 ed fc ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_NO_MEM;
f0104e1b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104e20:	e9 e3 fc ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_INVAL;
f0104e25:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104e2a:	e9 d9 fc ff ff       	jmp    f0104b08 <syscall+0x56>
    struct Env *e = NULL;
f0104e2f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (envid2env(envid, &e, 1) < 0)
f0104e36:	83 ec 04             	sub    $0x4,%esp
f0104e39:	6a 01                	push   $0x1
f0104e3b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104e3e:	50                   	push   %eax
f0104e3f:	ff 75 0c             	pushl  0xc(%ebp)
f0104e42:	e8 b1 e3 ff ff       	call   f01031f8 <envid2env>
f0104e47:	83 c4 10             	add    $0x10,%esp
f0104e4a:	85 c0                	test   %eax,%eax
f0104e4c:	78 2b                	js     f0104e79 <syscall+0x3c7>
    if (e == NULL)
f0104e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104e51:	85 c0                	test   %eax,%eax
f0104e53:	74 2e                	je     f0104e83 <syscall+0x3d1>
    if (((uintptr_t)va) >= UTOP) {
f0104e55:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104e5c:	77 2f                	ja     f0104e8d <syscall+0x3db>
    page_remove(e->env_pgdir, va);
f0104e5e:	83 ec 08             	sub    $0x8,%esp
f0104e61:	ff 75 10             	pushl  0x10(%ebp)
f0104e64:	ff 70 60             	pushl  0x60(%eax)
f0104e67:	e8 12 c4 ff ff       	call   f010127e <page_remove>
    return 0;
f0104e6c:	83 c4 10             	add    $0x10,%esp
f0104e6f:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e74:	e9 8f fc ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_BAD_ENV;
f0104e79:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104e7e:	e9 85 fc ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_BAD_ENV;
f0104e83:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104e88:	e9 7b fc ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_INVAL;
f0104e8d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
        return sys_page_unmap((envid_t)a1, (void *)a2);
f0104e92:	e9 71 fc ff ff       	jmp    f0104b08 <syscall+0x56>
    if (env_alloc(&newenv, curenv->env_id) < 0) {
f0104e97:	e8 8e 15 00 00       	call   f010642a <cpunum>
f0104e9c:	83 ec 08             	sub    $0x8,%esp
f0104e9f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ea2:	8b 80 28 10 33 f0    	mov    -0xfccefd8(%eax),%eax
f0104ea8:	ff 70 48             	pushl  0x48(%eax)
f0104eab:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104eae:	50                   	push   %eax
f0104eaf:	e8 66 e4 ff ff       	call   f010331a <env_alloc>
f0104eb4:	83 c4 10             	add    $0x10,%esp
f0104eb7:	85 c0                	test   %eax,%eax
f0104eb9:	78 31                	js     f0104eec <syscall+0x43a>
    newenv->env_tf = curenv->env_tf;
f0104ebb:	e8 6a 15 00 00       	call   f010642a <cpunum>
f0104ec0:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ec3:	8b b0 28 10 33 f0    	mov    -0xfccefd8(%eax),%esi
f0104ec9:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104ece:	8b 7d f4             	mov    -0xc(%ebp),%edi
f0104ed1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
    newenv->env_tf.tf_regs.reg_eax = 0;
f0104ed3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104ed6:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    newenv->env_status = ENV_NOT_RUNNABLE;
f0104edd:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
    return newenv->env_id;
f0104ee4:	8b 40 48             	mov    0x48(%eax),%eax
f0104ee7:	e9 1c fc ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_NO_FREE_ENV;
f0104eec:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
        return sys_exofork();
f0104ef1:	e9 12 fc ff ff       	jmp    f0104b08 <syscall+0x56>
    struct Env *e = NULL;
f0104ef6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (envid2env(envid, &e, 1) < 0) {
f0104efd:	83 ec 04             	sub    $0x4,%esp
f0104f00:	6a 01                	push   $0x1
f0104f02:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104f05:	50                   	push   %eax
f0104f06:	ff 75 0c             	pushl  0xc(%ebp)
f0104f09:	e8 ea e2 ff ff       	call   f01031f8 <envid2env>
f0104f0e:	83 c4 10             	add    $0x10,%esp
f0104f11:	85 c0                	test   %eax,%eax
f0104f13:	78 1d                	js     f0104f32 <syscall+0x480>
    if (e == NULL) {
f0104f15:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104f18:	85 c0                	test   %eax,%eax
f0104f1a:	74 20                	je     f0104f3c <syscall+0x48a>
    if (status > ENV_NOT_RUNNABLE || status < ENV_FREE) {
f0104f1c:	83 7d 10 04          	cmpl   $0x4,0x10(%ebp)
f0104f20:	77 24                	ja     f0104f46 <syscall+0x494>
    e->env_status = status;
f0104f22:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104f25:	89 78 54             	mov    %edi,0x54(%eax)
    return 0;
f0104f28:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f2d:	e9 d6 fb ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_BAD_ENV;
f0104f32:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104f37:	e9 cc fb ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_BAD_ENV;
f0104f3c:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104f41:	e9 c2 fb ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_INVAL;
f0104f46:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
        return sys_env_set_status((envid_t)a1, (int)a2);
f0104f4b:	e9 b8 fb ff ff       	jmp    f0104b08 <syscall+0x56>
    struct Env *e = NULL;
f0104f50:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (envid2env(envid, &e, 1) < 0) {
f0104f57:	83 ec 04             	sub    $0x4,%esp
f0104f5a:	6a 01                	push   $0x1
f0104f5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104f5f:	50                   	push   %eax
f0104f60:	ff 75 0c             	pushl  0xc(%ebp)
f0104f63:	e8 90 e2 ff ff       	call   f01031f8 <envid2env>
f0104f68:	83 c4 10             	add    $0x10,%esp
f0104f6b:	85 c0                	test   %eax,%eax
f0104f6d:	78 55                	js     f0104fc4 <syscall+0x512>
    if (e == NULL) {
f0104f6f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0104f73:	74 59                	je     f0104fce <syscall+0x51c>
    if (curenv->env_id != e->env_id &&
f0104f75:	e8 b0 14 00 00       	call   f010642a <cpunum>
f0104f7a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f7d:	8b 90 28 10 33 f0    	mov    -0xfccefd8(%eax),%edx
f0104f83:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104f86:	8b 40 48             	mov    0x48(%eax),%eax
f0104f89:	39 42 48             	cmp    %eax,0x48(%edx)
f0104f8c:	75 13                	jne    f0104fa1 <syscall+0x4ef>
    e->env_pgfault_upcall = func;
f0104f8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104f91:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104f94:	89 78 64             	mov    %edi,0x64(%eax)
    return 0;
f0104f97:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f9c:	e9 67 fb ff ff       	jmp    f0104b08 <syscall+0x56>
            curenv->env_id != e->env_parent_id) {
f0104fa1:	e8 84 14 00 00       	call   f010642a <cpunum>
f0104fa6:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fa9:	8b 90 28 10 33 f0    	mov    -0xfccefd8(%eax),%edx
    if (curenv->env_id != e->env_id &&
f0104faf:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104fb2:	8b 40 4c             	mov    0x4c(%eax),%eax
f0104fb5:	39 42 48             	cmp    %eax,0x48(%edx)
f0104fb8:	74 d4                	je     f0104f8e <syscall+0x4dc>
        return -E_BAD_ENV;
f0104fba:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
        return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
f0104fbf:	e9 44 fb ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_BAD_ENV;
f0104fc4:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104fc9:	e9 3a fb ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_BAD_ENV;
f0104fce:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104fd3:	e9 30 fb ff ff       	jmp    f0104b08 <syscall+0x56>
    struct Env *dstenv = NULL;
f0104fd8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    envid2env(envid, &dstenv, 0);
f0104fdf:	83 ec 04             	sub    $0x4,%esp
f0104fe2:	6a 00                	push   $0x0
f0104fe4:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0104fe7:	50                   	push   %eax
f0104fe8:	ff 75 0c             	pushl  0xc(%ebp)
f0104feb:	e8 08 e2 ff ff       	call   f01031f8 <envid2env>
    if (dstenv == NULL) {
f0104ff0:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104ff3:	83 c4 10             	add    $0x10,%esp
f0104ff6:	85 c0                	test   %eax,%eax
f0104ff8:	0f 84 c2 00 00 00    	je     f01050c0 <syscall+0x60e>
    if (!dstenv->env_ipc_recving) {
f0104ffe:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0105002:	0f 84 c2 00 00 00    	je     f01050ca <syscall+0x618>
    pte_t *pte = NULL;
f0105008:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (va < UTOP) {
f010500f:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0105016:	77 73                	ja     f010508b <syscall+0x5d9>
        if (va & 0xfff) {
f0105018:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f010501f:	0f 85 af 00 00 00    	jne    f01050d4 <syscall+0x622>
        pp = page_lookup(curenv->env_pgdir, srcva, &pte);
f0105025:	e8 00 14 00 00       	call   f010642a <cpunum>
f010502a:	83 ec 04             	sub    $0x4,%esp
f010502d:	8d 55 f4             	lea    -0xc(%ebp),%edx
f0105030:	52                   	push   %edx
f0105031:	ff 75 14             	pushl  0x14(%ebp)
f0105034:	6b c0 74             	imul   $0x74,%eax,%eax
f0105037:	8b 80 28 10 33 f0    	mov    -0xfccefd8(%eax),%eax
f010503d:	ff 70 60             	pushl  0x60(%eax)
f0105040:	e8 9e c1 ff ff       	call   f01011e3 <page_lookup>
        if (!(*pte & PTE_P)) {
f0105045:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0105048:	8b 12                	mov    (%edx),%edx
f010504a:	83 c4 10             	add    $0x10,%esp
f010504d:	f6 c2 01             	test   $0x1,%dl
f0105050:	0f 84 88 00 00 00    	je     f01050de <syscall+0x62c>
        if (perm & PTE_W) {
f0105056:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f010505a:	74 09                	je     f0105065 <syscall+0x5b3>
            if ((*pte & PTE_W) == 0) {
f010505c:	f6 c2 02             	test   $0x2,%dl
f010505f:	0f 84 83 00 00 00    	je     f01050e8 <syscall+0x636>
    if (pp != NULL) {
f0105065:	85 c0                	test   %eax,%eax
f0105067:	74 22                	je     f010508b <syscall+0x5d9>
                    dstenv->env_ipc_dstva, perm) < 0) {
f0105069:	8b 55 f0             	mov    -0x10(%ebp),%edx
        if (page_insert(dstenv->env_pgdir, pp,
f010506c:	ff 75 18             	pushl  0x18(%ebp)
f010506f:	ff 72 6c             	pushl  0x6c(%edx)
f0105072:	50                   	push   %eax
f0105073:	ff 72 60             	pushl  0x60(%edx)
f0105076:	e8 51 c2 ff ff       	call   f01012cc <page_insert>
f010507b:	83 c4 10             	add    $0x10,%esp
f010507e:	85 c0                	test   %eax,%eax
f0105080:	78 70                	js     f01050f2 <syscall+0x640>
	dstenv->env_ipc_perm = perm;
f0105082:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105085:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0105088:	89 48 78             	mov    %ecx,0x78(%eax)
    dstenv->env_ipc_value = value;
f010508b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010508e:	8b 7d 10             	mov    0x10(%ebp),%edi
f0105091:	89 78 70             	mov    %edi,0x70(%eax)
    dstenv->env_ipc_from = curenv->env_id;
f0105094:	e8 91 13 00 00       	call   f010642a <cpunum>
f0105099:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010509c:	6b c0 74             	imul   $0x74,%eax,%eax
f010509f:	8b 80 28 10 33 f0    	mov    -0xfccefd8(%eax),%eax
f01050a5:	8b 40 48             	mov    0x48(%eax),%eax
f01050a8:	89 42 74             	mov    %eax,0x74(%edx)
    dstenv->env_ipc_recving = false;
f01050ab:	c6 42 68 00          	movb   $0x0,0x68(%edx)
    dstenv->env_status = ENV_RUNNABLE;
f01050af:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
    return 0;
f01050b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01050bb:	e9 48 fa ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_BAD_ENV;
f01050c0:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01050c5:	e9 3e fa ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_IPC_NOT_RECV;
f01050ca:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
f01050cf:	e9 34 fa ff ff       	jmp    f0104b08 <syscall+0x56>
            return -E_INVAL;
f01050d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01050d9:	e9 2a fa ff ff       	jmp    f0104b08 <syscall+0x56>
            return -E_INVAL;
f01050de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01050e3:	e9 20 fa ff ff       	jmp    f0104b08 <syscall+0x56>
                return -E_INVAL;
f01050e8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01050ed:	e9 16 fa ff ff       	jmp    f0104b08 <syscall+0x56>
            return -E_NO_MEM;
f01050f2:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
        return sys_ipc_try_send((envid_t) a1, (uint32_t) a2,
f01050f7:	e9 0c fa ff ff       	jmp    f0104b08 <syscall+0x56>
    if (va < UTOP) {
f01050fc:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0105103:	77 29                	ja     f010512e <syscall+0x67c>
        if (va & 0xfff) {
f0105105:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f010510c:	74 0a                	je     f0105118 <syscall+0x666>
        return sys_ipc_recv((void*)a1);
f010510e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105113:	e9 f0 f9 ff ff       	jmp    f0104b08 <syscall+0x56>
        curenv->env_ipc_dstva = dstva;
f0105118:	e8 0d 13 00 00       	call   f010642a <cpunum>
f010511d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105120:	8b 80 28 10 33 f0    	mov    -0xfccefd8(%eax),%eax
f0105126:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105129:	89 48 6c             	mov    %ecx,0x6c(%eax)
f010512c:	eb 15                	jmp    f0105143 <syscall+0x691>
        curenv->env_ipc_dstva = NULL;
f010512e:	e8 f7 12 00 00       	call   f010642a <cpunum>
f0105133:	6b c0 74             	imul   $0x74,%eax,%eax
f0105136:	8b 80 28 10 33 f0    	mov    -0xfccefd8(%eax),%eax
f010513c:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)
    curenv->env_ipc_recving = true;
f0105143:	e8 e2 12 00 00       	call   f010642a <cpunum>
f0105148:	6b c0 74             	imul   $0x74,%eax,%eax
f010514b:	8b 80 28 10 33 f0    	mov    -0xfccefd8(%eax),%eax
f0105151:	c6 40 68 01          	movb   $0x1,0x68(%eax)
    curenv->env_status = ENV_NOT_RUNNABLE;
f0105155:	e8 d0 12 00 00       	call   f010642a <cpunum>
f010515a:	6b c0 74             	imul   $0x74,%eax,%eax
f010515d:	8b 80 28 10 33 f0    	mov    -0xfccefd8(%eax),%eax
f0105163:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
    sched_yield();
f010516a:	e8 ad f8 ff ff       	call   f0104a1c <sched_yield>
	if((x = envid2env(envid, &e, 1)) != 0)
f010516f:	83 ec 04             	sub    $0x4,%esp
f0105172:	6a 01                	push   $0x1
f0105174:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0105177:	50                   	push   %eax
f0105178:	ff 75 0c             	pushl  0xc(%ebp)
f010517b:	e8 78 e0 ff ff       	call   f01031f8 <envid2env>
f0105180:	83 c4 10             	add    $0x10,%esp
f0105183:	85 c0                	test   %eax,%eax
f0105185:	0f 85 7d f9 ff ff    	jne    f0104b08 <syscall+0x56>
	e->env_tf = *tf;
f010518b:	b9 11 00 00 00       	mov    $0x11,%ecx
f0105190:	8b 7d f4             	mov    -0xc(%ebp),%edi
f0105193:	8b 75 10             	mov    0x10(%ebp),%esi
f0105196:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_tf.tf_eflags &= ~FL_IOPL_MASK;
f0105198:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010519b:	8b 4a 38             	mov    0x38(%edx),%ecx
f010519e:	80 e5 cf             	and    $0xcf,%ch
	e->env_tf.tf_eflags |= FL_IF;
f01051a1:	80 cd 02             	or     $0x2,%ch
f01051a4:	89 4a 38             	mov    %ecx,0x38(%edx)
	e->env_tf.tf_ds = GD_UD | 3;
f01051a7:	66 c7 42 24 23 00    	movw   $0x23,0x24(%edx)
	e->env_tf.tf_es = GD_UD | 3;
f01051ad:	66 c7 42 20 23 00    	movw   $0x23,0x20(%edx)
	e->env_tf.tf_ss = GD_UD | 3;
f01051b3:	66 c7 42 40 23 00    	movw   $0x23,0x40(%edx)
	e->env_tf.tf_cs = GD_UT | 3;
f01051b9:	66 c7 42 34 1b 00    	movw   $0x1b,0x34(%edx)
	return (int32_t)sys_env_set_trapframe((envid_t) a1, (struct Trapframe *) a2);
f01051bf:	e9 44 f9 ff ff       	jmp    f0104b08 <syscall+0x56>
	    panic("syscall %d not implemented", syscallno);
f01051c4:	50                   	push   %eax
f01051c5:	68 98 82 10 f0       	push   $0xf0108298
f01051ca:	68 5a 02 00 00       	push   $0x25a
f01051cf:	68 89 82 10 f0       	push   $0xf0108289
f01051d4:	e8 67 ae ff ff       	call   f0100040 <_panic>

f01051d9 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01051d9:	55                   	push   %ebp
f01051da:	89 e5                	mov    %esp,%ebp
f01051dc:	57                   	push   %edi
f01051dd:	56                   	push   %esi
f01051de:	53                   	push   %ebx
f01051df:	83 ec 14             	sub    $0x14,%esp
f01051e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01051e5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01051e8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01051eb:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01051ee:	8b 1a                	mov    (%edx),%ebx
f01051f0:	8b 01                	mov    (%ecx),%eax
f01051f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01051f5:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01051fc:	eb 23                	jmp    f0105221 <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01051fe:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0105201:	eb 1e                	jmp    f0105221 <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0105203:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105206:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105209:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010520d:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0105210:	73 46                	jae    f0105258 <stab_binsearch+0x7f>
			*region_left = m;
f0105212:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105215:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0105217:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f010521a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0105221:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0105224:	7f 5f                	jg     f0105285 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0105226:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105229:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f010522c:	89 d0                	mov    %edx,%eax
f010522e:	c1 e8 1f             	shr    $0x1f,%eax
f0105231:	01 d0                	add    %edx,%eax
f0105233:	89 c7                	mov    %eax,%edi
f0105235:	d1 ff                	sar    %edi
f0105237:	83 e0 fe             	and    $0xfffffffe,%eax
f010523a:	01 f8                	add    %edi,%eax
f010523c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010523f:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0105243:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0105245:	39 c3                	cmp    %eax,%ebx
f0105247:	7f b5                	jg     f01051fe <stab_binsearch+0x25>
f0105249:	0f b6 0a             	movzbl (%edx),%ecx
f010524c:	83 ea 0c             	sub    $0xc,%edx
f010524f:	39 f1                	cmp    %esi,%ecx
f0105251:	74 b0                	je     f0105203 <stab_binsearch+0x2a>
			m--;
f0105253:	83 e8 01             	sub    $0x1,%eax
f0105256:	eb ed                	jmp    f0105245 <stab_binsearch+0x6c>
		} else if (stabs[m].n_value > addr) {
f0105258:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010525b:	76 14                	jbe    f0105271 <stab_binsearch+0x98>
			*region_right = m - 1;
f010525d:	83 e8 01             	sub    $0x1,%eax
f0105260:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105263:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105266:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0105268:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010526f:	eb b0                	jmp    f0105221 <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0105271:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105274:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0105276:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010527a:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f010527c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105283:	eb 9c                	jmp    f0105221 <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f0105285:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0105289:	75 15                	jne    f01052a0 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f010528b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010528e:	8b 00                	mov    (%eax),%eax
f0105290:	83 e8 01             	sub    $0x1,%eax
f0105293:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105296:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0105298:	83 c4 14             	add    $0x14,%esp
f010529b:	5b                   	pop    %ebx
f010529c:	5e                   	pop    %esi
f010529d:	5f                   	pop    %edi
f010529e:	5d                   	pop    %ebp
f010529f:	c3                   	ret    
		for (l = *region_right;
f01052a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01052a3:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01052a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01052a8:	8b 0f                	mov    (%edi),%ecx
f01052aa:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01052ad:	8b 7d ec             	mov    -0x14(%ebp),%edi
f01052b0:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f01052b4:	eb 03                	jmp    f01052b9 <stab_binsearch+0xe0>
		     l--)
f01052b6:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f01052b9:	39 c1                	cmp    %eax,%ecx
f01052bb:	7d 0a                	jge    f01052c7 <stab_binsearch+0xee>
		     l > *region_left && stabs[l].n_type != type;
f01052bd:	0f b6 1a             	movzbl (%edx),%ebx
f01052c0:	83 ea 0c             	sub    $0xc,%edx
f01052c3:	39 f3                	cmp    %esi,%ebx
f01052c5:	75 ef                	jne    f01052b6 <stab_binsearch+0xdd>
		*region_left = l;
f01052c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01052ca:	89 07                	mov    %eax,(%edi)
}
f01052cc:	eb ca                	jmp    f0105298 <stab_binsearch+0xbf>

f01052ce <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01052ce:	f3 0f 1e fb          	endbr32 
f01052d2:	55                   	push   %ebp
f01052d3:	89 e5                	mov    %esp,%ebp
f01052d5:	57                   	push   %edi
f01052d6:	56                   	push   %esi
f01052d7:	53                   	push   %ebx
f01052d8:	83 ec 4c             	sub    $0x4c,%esp
f01052db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01052de:	c7 03 ec 82 10 f0    	movl   $0xf01082ec,(%ebx)
	info->eip_line = 0;
f01052e4:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01052eb:	c7 43 08 ec 82 10 f0 	movl   $0xf01082ec,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01052f2:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01052f9:	8b 45 08             	mov    0x8(%ebp),%eax
f01052fc:	89 43 10             	mov    %eax,0x10(%ebx)
	info->eip_fn_narg = 0;
f01052ff:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0105306:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f010530b:	0f 86 1b 01 00 00    	jbe    f010542c <debuginfo_eip+0x15e>
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0105311:	c7 45 bc e9 90 11 f0 	movl   $0xf01190e9,-0x44(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0105318:	c7 45 b4 75 58 11 f0 	movl   $0xf0115875,-0x4c(%ebp)
		stab_end = __STAB_END__;
f010531f:	bf 74 58 11 f0       	mov    $0xf0115874,%edi
		stabs = __STAB_BEGIN__;
f0105324:	c7 45 b8 90 88 10 f0 	movl   $0xf0108890,-0x48(%ebp)
            return -1;
        }
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010532b:	8b 75 bc             	mov    -0x44(%ebp),%esi
f010532e:	39 75 b4             	cmp    %esi,-0x4c(%ebp)
f0105331:	0f 83 5d 02 00 00    	jae    f0105594 <debuginfo_eip+0x2c6>
f0105337:	80 7e ff 00          	cmpb   $0x0,-0x1(%esi)
f010533b:	0f 85 5a 02 00 00    	jne    f010559b <debuginfo_eip+0x2cd>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105341:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0105348:	8b 75 b8             	mov    -0x48(%ebp),%esi
f010534b:	29 f7                	sub    %esi,%edi
f010534d:	c1 ff 02             	sar    $0x2,%edi
f0105350:	69 c7 ab aa aa aa    	imul   $0xaaaaaaab,%edi,%eax
f0105356:	83 e8 01             	sub    $0x1,%eax
f0105359:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010535c:	83 ec 08             	sub    $0x8,%esp
f010535f:	ff 75 08             	pushl  0x8(%ebp)
f0105362:	6a 64                	push   $0x64
f0105364:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0105367:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010536a:	89 f0                	mov    %esi,%eax
f010536c:	e8 68 fe ff ff       	call   f01051d9 <stab_binsearch>
	if (lfile == 0)
f0105371:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105374:	83 c4 10             	add    $0x10,%esp
f0105377:	85 c0                	test   %eax,%eax
f0105379:	0f 84 23 02 00 00    	je     f01055a2 <debuginfo_eip+0x2d4>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010537f:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0105382:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105385:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105388:	83 ec 08             	sub    $0x8,%esp
f010538b:	ff 75 08             	pushl  0x8(%ebp)
f010538e:	6a 24                	push   $0x24
f0105390:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0105393:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105396:	89 f0                	mov    %esi,%eax
f0105398:	e8 3c fe ff ff       	call   f01051d9 <stab_binsearch>

	if (lfun <= rfun) {
f010539d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01053a0:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01053a3:	83 c4 10             	add    $0x10,%esp
f01053a6:	39 d0                	cmp    %edx,%eax
f01053a8:	0f 8f 2b 01 00 00    	jg     f01054d9 <debuginfo_eip+0x20b>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01053ae:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01053b1:	8d 3c 8e             	lea    (%esi,%ecx,4),%edi
f01053b4:	8b 0f                	mov    (%edi),%ecx
f01053b6:	8b 75 bc             	mov    -0x44(%ebp),%esi
f01053b9:	2b 75 b4             	sub    -0x4c(%ebp),%esi
f01053bc:	39 f1                	cmp    %esi,%ecx
f01053be:	73 06                	jae    f01053c6 <debuginfo_eip+0xf8>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01053c0:	03 4d b4             	add    -0x4c(%ebp),%ecx
f01053c3:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01053c6:	8b 4f 08             	mov    0x8(%edi),%ecx
f01053c9:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01053cc:	29 4d 08             	sub    %ecx,0x8(%ebp)
		// Search within the function definition for the line number.
		lline = lfun;
f01053cf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01053d2:	89 55 d0             	mov    %edx,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01053d5:	83 ec 08             	sub    $0x8,%esp
f01053d8:	6a 3a                	push   $0x3a
f01053da:	ff 73 08             	pushl  0x8(%ebx)
f01053dd:	e8 0a 0a 00 00       	call   f0105dec <strfind>
f01053e2:	2b 43 08             	sub    0x8(%ebx),%eax
f01053e5:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01053e8:	83 c4 08             	add    $0x8,%esp
f01053eb:	ff 75 08             	pushl  0x8(%ebp)
f01053ee:	6a 44                	push   $0x44
f01053f0:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01053f3:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01053f6:	8b 75 b8             	mov    -0x48(%ebp),%esi
f01053f9:	89 f0                	mov    %esi,%eax
f01053fb:	e8 d9 fd ff ff       	call   f01051d9 <stab_binsearch>

    if (lline <= rline) {
f0105400:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0105403:	83 c4 10             	add    $0x10,%esp
f0105406:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0105409:	0f 8f 9a 01 00 00    	jg     f01055a9 <debuginfo_eip+0x2db>
        info->eip_line = stabs[lline].n_desc;
f010540f:	89 d0                	mov    %edx,%eax
f0105411:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0105414:	0f b7 4c 96 06       	movzwl 0x6(%esi,%edx,4),%ecx
f0105419:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010541c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010541f:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
f0105423:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0105427:	e9 ce 00 00 00       	jmp    f01054fa <debuginfo_eip+0x22c>
        if (user_mem_check(curenv, usd, sizeof(const struct UserStabData),
f010542c:	e8 f9 0f 00 00       	call   f010642a <cpunum>
f0105431:	6a 05                	push   $0x5
f0105433:	6a 10                	push   $0x10
f0105435:	68 00 00 20 00       	push   $0x200000
f010543a:	6b c0 74             	imul   $0x74,%eax,%eax
f010543d:	ff b0 28 10 33 f0    	pushl  -0xfccefd8(%eax)
f0105443:	e8 29 dc ff ff       	call   f0103071 <user_mem_check>
f0105448:	83 c4 10             	add    $0x10,%esp
f010544b:	85 c0                	test   %eax,%eax
f010544d:	0f 88 33 01 00 00    	js     f0105586 <debuginfo_eip+0x2b8>
		stabs = usd->stabs;
f0105453:	a1 00 00 20 00       	mov    0x200000,%eax
f0105458:	89 45 b8             	mov    %eax,-0x48(%ebp)
		stab_end = usd->stab_end;
f010545b:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f0105461:	8b 35 08 00 20 00    	mov    0x200008,%esi
f0105467:	89 75 b4             	mov    %esi,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f010546a:	8b 0d 0c 00 20 00    	mov    0x20000c,%ecx
f0105470:	89 4d bc             	mov    %ecx,-0x44(%ebp)
        size_t stabs_size = ((uintptr_t)stab_end) - ((uintptr_t) stabs);
f0105473:	89 fa                	mov    %edi,%edx
f0105475:	89 c6                	mov    %eax,%esi
f0105477:	29 c2                	sub    %eax,%edx
f0105479:	89 55 c4             	mov    %edx,-0x3c(%ebp)
        if (user_mem_check(curenv, stabs, stabs_size,
f010547c:	e8 a9 0f 00 00       	call   f010642a <cpunum>
f0105481:	6a 05                	push   $0x5
f0105483:	ff 75 c4             	pushl  -0x3c(%ebp)
f0105486:	56                   	push   %esi
f0105487:	6b c0 74             	imul   $0x74,%eax,%eax
f010548a:	ff b0 28 10 33 f0    	pushl  -0xfccefd8(%eax)
f0105490:	e8 dc db ff ff       	call   f0103071 <user_mem_check>
f0105495:	83 c4 10             	add    $0x10,%esp
f0105498:	85 c0                	test   %eax,%eax
f010549a:	0f 88 ed 00 00 00    	js     f010558d <debuginfo_eip+0x2bf>
        size_t stabstr_size = ((uintptr_t)stabstr_end) - ((uintptr_t) stabstr);
f01054a0:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01054a3:	8b 75 b4             	mov    -0x4c(%ebp),%esi
f01054a6:	29 f0                	sub    %esi,%eax
f01054a8:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        if (user_mem_check(curenv, stabstr, stabstr_size,
f01054ab:	e8 7a 0f 00 00       	call   f010642a <cpunum>
f01054b0:	6a 05                	push   $0x5
f01054b2:	ff 75 c4             	pushl  -0x3c(%ebp)
f01054b5:	56                   	push   %esi
f01054b6:	6b c0 74             	imul   $0x74,%eax,%eax
f01054b9:	ff b0 28 10 33 f0    	pushl  -0xfccefd8(%eax)
f01054bf:	e8 ad db ff ff       	call   f0103071 <user_mem_check>
f01054c4:	83 c4 10             	add    $0x10,%esp
f01054c7:	85 c0                	test   %eax,%eax
f01054c9:	0f 89 5c fe ff ff    	jns    f010532b <debuginfo_eip+0x5d>
            return -1;
f01054cf:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01054d4:	e9 dc 00 00 00       	jmp    f01055b5 <debuginfo_eip+0x2e7>
		info->eip_fn_addr = addr;
f01054d9:	8b 45 08             	mov    0x8(%ebp),%eax
f01054dc:	89 43 10             	mov    %eax,0x10(%ebx)
		lline = lfile;
f01054df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01054e2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01054e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01054e8:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01054eb:	e9 e5 fe ff ff       	jmp    f01053d5 <debuginfo_eip+0x107>
f01054f0:	83 e8 01             	sub    $0x1,%eax
f01054f3:	83 ea 0c             	sub    $0xc,%edx
	while (lline >= lfile
f01054f6:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f01054fa:	89 45 c0             	mov    %eax,-0x40(%ebp)
f01054fd:	39 c7                	cmp    %eax,%edi
f01054ff:	7f 45                	jg     f0105546 <debuginfo_eip+0x278>
	       && stabs[lline].n_type != N_SOL
f0105501:	0f b6 0a             	movzbl (%edx),%ecx
f0105504:	80 f9 84             	cmp    $0x84,%cl
f0105507:	74 19                	je     f0105522 <debuginfo_eip+0x254>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105509:	80 f9 64             	cmp    $0x64,%cl
f010550c:	75 e2                	jne    f01054f0 <debuginfo_eip+0x222>
f010550e:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f0105512:	74 dc                	je     f01054f0 <debuginfo_eip+0x222>
f0105514:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0105518:	74 11                	je     f010552b <debuginfo_eip+0x25d>
f010551a:	8b 7d c0             	mov    -0x40(%ebp),%edi
f010551d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105520:	eb 09                	jmp    f010552b <debuginfo_eip+0x25d>
f0105522:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0105526:	74 03                	je     f010552b <debuginfo_eip+0x25d>
f0105528:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010552b:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010552e:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0105531:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0105534:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0105537:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f010553a:	29 f8                	sub    %edi,%eax
f010553c:	39 c2                	cmp    %eax,%edx
f010553e:	73 06                	jae    f0105546 <debuginfo_eip+0x278>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105540:	89 f8                	mov    %edi,%eax
f0105542:	01 d0                	add    %edx,%eax
f0105544:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105546:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105549:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010554c:	ba 00 00 00 00       	mov    $0x0,%edx
	if (lfun < rfun)
f0105551:	39 f0                	cmp    %esi,%eax
f0105553:	7d 60                	jge    f01055b5 <debuginfo_eip+0x2e7>
		for (lline = lfun + 1;
f0105555:	8d 50 01             	lea    0x1(%eax),%edx
f0105558:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010555b:	89 d0                	mov    %edx,%eax
f010555d:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0105560:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0105563:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0105567:	eb 04                	jmp    f010556d <debuginfo_eip+0x29f>
			info->eip_fn_narg++;
f0105569:	83 43 14 01          	addl   $0x1,0x14(%ebx)
		for (lline = lfun + 1;
f010556d:	39 c6                	cmp    %eax,%esi
f010556f:	7e 3f                	jle    f01055b0 <debuginfo_eip+0x2e2>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105571:	0f b6 0a             	movzbl (%edx),%ecx
f0105574:	83 c0 01             	add    $0x1,%eax
f0105577:	83 c2 0c             	add    $0xc,%edx
f010557a:	80 f9 a0             	cmp    $0xa0,%cl
f010557d:	74 ea                	je     f0105569 <debuginfo_eip+0x29b>
	return 0;
f010557f:	ba 00 00 00 00       	mov    $0x0,%edx
f0105584:	eb 2f                	jmp    f01055b5 <debuginfo_eip+0x2e7>
            return -1;
f0105586:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f010558b:	eb 28                	jmp    f01055b5 <debuginfo_eip+0x2e7>
            return -1;
f010558d:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0105592:	eb 21                	jmp    f01055b5 <debuginfo_eip+0x2e7>
		return -1;
f0105594:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0105599:	eb 1a                	jmp    f01055b5 <debuginfo_eip+0x2e7>
f010559b:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01055a0:	eb 13                	jmp    f01055b5 <debuginfo_eip+0x2e7>
		return -1;
f01055a2:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01055a7:	eb 0c                	jmp    f01055b5 <debuginfo_eip+0x2e7>
        return -1;
f01055a9:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01055ae:	eb 05                	jmp    f01055b5 <debuginfo_eip+0x2e7>
	return 0;
f01055b0:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01055b5:	89 d0                	mov    %edx,%eax
f01055b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01055ba:	5b                   	pop    %ebx
f01055bb:	5e                   	pop    %esi
f01055bc:	5f                   	pop    %edi
f01055bd:	5d                   	pop    %ebp
f01055be:	c3                   	ret    

f01055bf <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01055bf:	55                   	push   %ebp
f01055c0:	89 e5                	mov    %esp,%ebp
f01055c2:	57                   	push   %edi
f01055c3:	56                   	push   %esi
f01055c4:	53                   	push   %ebx
f01055c5:	83 ec 1c             	sub    $0x1c,%esp
f01055c8:	89 c7                	mov    %eax,%edi
f01055ca:	89 d6                	mov    %edx,%esi
f01055cc:	8b 45 08             	mov    0x8(%ebp),%eax
f01055cf:	8b 55 0c             	mov    0xc(%ebp),%edx
f01055d2:	89 d1                	mov    %edx,%ecx
f01055d4:	89 c2                	mov    %eax,%edx
f01055d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01055d9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01055dc:	8b 45 10             	mov    0x10(%ebp),%eax
f01055df:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01055e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01055e5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01055ec:	39 c2                	cmp    %eax,%edx
f01055ee:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f01055f1:	72 3e                	jb     f0105631 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01055f3:	83 ec 0c             	sub    $0xc,%esp
f01055f6:	ff 75 18             	pushl  0x18(%ebp)
f01055f9:	83 eb 01             	sub    $0x1,%ebx
f01055fc:	53                   	push   %ebx
f01055fd:	50                   	push   %eax
f01055fe:	83 ec 08             	sub    $0x8,%esp
f0105601:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105604:	ff 75 e0             	pushl  -0x20(%ebp)
f0105607:	ff 75 dc             	pushl  -0x24(%ebp)
f010560a:	ff 75 d8             	pushl  -0x28(%ebp)
f010560d:	e8 2e 12 00 00       	call   f0106840 <__udivdi3>
f0105612:	83 c4 18             	add    $0x18,%esp
f0105615:	52                   	push   %edx
f0105616:	50                   	push   %eax
f0105617:	89 f2                	mov    %esi,%edx
f0105619:	89 f8                	mov    %edi,%eax
f010561b:	e8 9f ff ff ff       	call   f01055bf <printnum>
f0105620:	83 c4 20             	add    $0x20,%esp
f0105623:	eb 13                	jmp    f0105638 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105625:	83 ec 08             	sub    $0x8,%esp
f0105628:	56                   	push   %esi
f0105629:	ff 75 18             	pushl  0x18(%ebp)
f010562c:	ff d7                	call   *%edi
f010562e:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0105631:	83 eb 01             	sub    $0x1,%ebx
f0105634:	85 db                	test   %ebx,%ebx
f0105636:	7f ed                	jg     f0105625 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105638:	83 ec 08             	sub    $0x8,%esp
f010563b:	56                   	push   %esi
f010563c:	83 ec 04             	sub    $0x4,%esp
f010563f:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105642:	ff 75 e0             	pushl  -0x20(%ebp)
f0105645:	ff 75 dc             	pushl  -0x24(%ebp)
f0105648:	ff 75 d8             	pushl  -0x28(%ebp)
f010564b:	e8 00 13 00 00       	call   f0106950 <__umoddi3>
f0105650:	83 c4 14             	add    $0x14,%esp
f0105653:	0f be 80 f6 82 10 f0 	movsbl -0xfef7d0a(%eax),%eax
f010565a:	50                   	push   %eax
f010565b:	ff d7                	call   *%edi
}
f010565d:	83 c4 10             	add    $0x10,%esp
f0105660:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105663:	5b                   	pop    %ebx
f0105664:	5e                   	pop    %esi
f0105665:	5f                   	pop    %edi
f0105666:	5d                   	pop    %ebp
f0105667:	c3                   	ret    

f0105668 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105668:	f3 0f 1e fb          	endbr32 
f010566c:	55                   	push   %ebp
f010566d:	89 e5                	mov    %esp,%ebp
f010566f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105672:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0105676:	8b 10                	mov    (%eax),%edx
f0105678:	3b 50 04             	cmp    0x4(%eax),%edx
f010567b:	73 0a                	jae    f0105687 <sprintputch+0x1f>
		*b->buf++ = ch;
f010567d:	8d 4a 01             	lea    0x1(%edx),%ecx
f0105680:	89 08                	mov    %ecx,(%eax)
f0105682:	8b 45 08             	mov    0x8(%ebp),%eax
f0105685:	88 02                	mov    %al,(%edx)
}
f0105687:	5d                   	pop    %ebp
f0105688:	c3                   	ret    

f0105689 <printfmt>:
{
f0105689:	f3 0f 1e fb          	endbr32 
f010568d:	55                   	push   %ebp
f010568e:	89 e5                	mov    %esp,%ebp
f0105690:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0105693:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105696:	50                   	push   %eax
f0105697:	ff 75 10             	pushl  0x10(%ebp)
f010569a:	ff 75 0c             	pushl  0xc(%ebp)
f010569d:	ff 75 08             	pushl  0x8(%ebp)
f01056a0:	e8 05 00 00 00       	call   f01056aa <vprintfmt>
}
f01056a5:	83 c4 10             	add    $0x10,%esp
f01056a8:	c9                   	leave  
f01056a9:	c3                   	ret    

f01056aa <vprintfmt>:
{
f01056aa:	f3 0f 1e fb          	endbr32 
f01056ae:	55                   	push   %ebp
f01056af:	89 e5                	mov    %esp,%ebp
f01056b1:	57                   	push   %edi
f01056b2:	56                   	push   %esi
f01056b3:	53                   	push   %ebx
f01056b4:	83 ec 3c             	sub    $0x3c,%esp
f01056b7:	8b 75 08             	mov    0x8(%ebp),%esi
f01056ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01056bd:	8b 7d 10             	mov    0x10(%ebp),%edi
f01056c0:	e9 4a 03 00 00       	jmp    f0105a0f <vprintfmt+0x365>
		padc = ' ';
f01056c5:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
f01056c9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f01056d0:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f01056d7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f01056de:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f01056e3:	8d 47 01             	lea    0x1(%edi),%eax
f01056e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01056e9:	0f b6 17             	movzbl (%edi),%edx
f01056ec:	8d 42 dd             	lea    -0x23(%edx),%eax
f01056ef:	3c 55                	cmp    $0x55,%al
f01056f1:	0f 87 de 03 00 00    	ja     f0105ad5 <vprintfmt+0x42b>
f01056f7:	0f b6 c0             	movzbl %al,%eax
f01056fa:	3e ff 24 85 40 84 10 	notrack jmp *-0xfef7bc0(,%eax,4)
f0105701:	f0 
f0105702:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0105705:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
f0105709:	eb d8                	jmp    f01056e3 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
f010570b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010570e:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
f0105712:	eb cf                	jmp    f01056e3 <vprintfmt+0x39>
f0105714:	0f b6 d2             	movzbl %dl,%edx
f0105717:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f010571a:	b8 00 00 00 00       	mov    $0x0,%eax
f010571f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0105722:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0105725:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0105729:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f010572c:	8d 4a d0             	lea    -0x30(%edx),%ecx
f010572f:	83 f9 09             	cmp    $0x9,%ecx
f0105732:	77 55                	ja     f0105789 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
f0105734:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0105737:	eb e9                	jmp    f0105722 <vprintfmt+0x78>
			precision = va_arg(ap, int);
f0105739:	8b 45 14             	mov    0x14(%ebp),%eax
f010573c:	8b 00                	mov    (%eax),%eax
f010573e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105741:	8b 45 14             	mov    0x14(%ebp),%eax
f0105744:	8d 40 04             	lea    0x4(%eax),%eax
f0105747:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010574a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f010574d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105751:	79 90                	jns    f01056e3 <vprintfmt+0x39>
				width = precision, precision = -1;
f0105753:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105756:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105759:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0105760:	eb 81                	jmp    f01056e3 <vprintfmt+0x39>
f0105762:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105765:	85 c0                	test   %eax,%eax
f0105767:	ba 00 00 00 00       	mov    $0x0,%edx
f010576c:	0f 49 d0             	cmovns %eax,%edx
f010576f:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0105772:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0105775:	e9 69 ff ff ff       	jmp    f01056e3 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
f010577a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f010577d:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f0105784:	e9 5a ff ff ff       	jmp    f01056e3 <vprintfmt+0x39>
f0105789:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010578c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010578f:	eb bc                	jmp    f010574d <vprintfmt+0xa3>
			lflag++;
f0105791:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0105794:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0105797:	e9 47 ff ff ff       	jmp    f01056e3 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
f010579c:	8b 45 14             	mov    0x14(%ebp),%eax
f010579f:	8d 78 04             	lea    0x4(%eax),%edi
f01057a2:	83 ec 08             	sub    $0x8,%esp
f01057a5:	53                   	push   %ebx
f01057a6:	ff 30                	pushl  (%eax)
f01057a8:	ff d6                	call   *%esi
			break;
f01057aa:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01057ad:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f01057b0:	e9 57 02 00 00       	jmp    f0105a0c <vprintfmt+0x362>
			err = va_arg(ap, int);
f01057b5:	8b 45 14             	mov    0x14(%ebp),%eax
f01057b8:	8d 78 04             	lea    0x4(%eax),%edi
f01057bb:	8b 00                	mov    (%eax),%eax
f01057bd:	99                   	cltd   
f01057be:	31 d0                	xor    %edx,%eax
f01057c0:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01057c2:	83 f8 0f             	cmp    $0xf,%eax
f01057c5:	7f 23                	jg     f01057ea <vprintfmt+0x140>
f01057c7:	8b 14 85 a0 85 10 f0 	mov    -0xfef7a60(,%eax,4),%edx
f01057ce:	85 d2                	test   %edx,%edx
f01057d0:	74 18                	je     f01057ea <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
f01057d2:	52                   	push   %edx
f01057d3:	68 cb 79 10 f0       	push   $0xf01079cb
f01057d8:	53                   	push   %ebx
f01057d9:	56                   	push   %esi
f01057da:	e8 aa fe ff ff       	call   f0105689 <printfmt>
f01057df:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01057e2:	89 7d 14             	mov    %edi,0x14(%ebp)
f01057e5:	e9 22 02 00 00       	jmp    f0105a0c <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
f01057ea:	50                   	push   %eax
f01057eb:	68 0e 83 10 f0       	push   $0xf010830e
f01057f0:	53                   	push   %ebx
f01057f1:	56                   	push   %esi
f01057f2:	e8 92 fe ff ff       	call   f0105689 <printfmt>
f01057f7:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01057fa:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f01057fd:	e9 0a 02 00 00       	jmp    f0105a0c <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
f0105802:	8b 45 14             	mov    0x14(%ebp),%eax
f0105805:	83 c0 04             	add    $0x4,%eax
f0105808:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010580b:	8b 45 14             	mov    0x14(%ebp),%eax
f010580e:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f0105810:	85 d2                	test   %edx,%edx
f0105812:	b8 07 83 10 f0       	mov    $0xf0108307,%eax
f0105817:	0f 45 c2             	cmovne %edx,%eax
f010581a:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
f010581d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105821:	7e 06                	jle    f0105829 <vprintfmt+0x17f>
f0105823:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
f0105827:	75 0d                	jne    f0105836 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105829:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010582c:	89 c7                	mov    %eax,%edi
f010582e:	03 45 e0             	add    -0x20(%ebp),%eax
f0105831:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105834:	eb 55                	jmp    f010588b <vprintfmt+0x1e1>
f0105836:	83 ec 08             	sub    $0x8,%esp
f0105839:	ff 75 d8             	pushl  -0x28(%ebp)
f010583c:	ff 75 cc             	pushl  -0x34(%ebp)
f010583f:	e8 37 04 00 00       	call   f0105c7b <strnlen>
f0105844:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105847:	29 c2                	sub    %eax,%edx
f0105849:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f010584c:	83 c4 10             	add    $0x10,%esp
f010584f:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
f0105851:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f0105855:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0105858:	85 ff                	test   %edi,%edi
f010585a:	7e 11                	jle    f010586d <vprintfmt+0x1c3>
					putch(padc, putdat);
f010585c:	83 ec 08             	sub    $0x8,%esp
f010585f:	53                   	push   %ebx
f0105860:	ff 75 e0             	pushl  -0x20(%ebp)
f0105863:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0105865:	83 ef 01             	sub    $0x1,%edi
f0105868:	83 c4 10             	add    $0x10,%esp
f010586b:	eb eb                	jmp    f0105858 <vprintfmt+0x1ae>
f010586d:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0105870:	85 d2                	test   %edx,%edx
f0105872:	b8 00 00 00 00       	mov    $0x0,%eax
f0105877:	0f 49 c2             	cmovns %edx,%eax
f010587a:	29 c2                	sub    %eax,%edx
f010587c:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010587f:	eb a8                	jmp    f0105829 <vprintfmt+0x17f>
					putch(ch, putdat);
f0105881:	83 ec 08             	sub    $0x8,%esp
f0105884:	53                   	push   %ebx
f0105885:	52                   	push   %edx
f0105886:	ff d6                	call   *%esi
f0105888:	83 c4 10             	add    $0x10,%esp
f010588b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010588e:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105890:	83 c7 01             	add    $0x1,%edi
f0105893:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105897:	0f be d0             	movsbl %al,%edx
f010589a:	85 d2                	test   %edx,%edx
f010589c:	74 4b                	je     f01058e9 <vprintfmt+0x23f>
f010589e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01058a2:	78 06                	js     f01058aa <vprintfmt+0x200>
f01058a4:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f01058a8:	78 1e                	js     f01058c8 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
f01058aa:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01058ae:	74 d1                	je     f0105881 <vprintfmt+0x1d7>
f01058b0:	0f be c0             	movsbl %al,%eax
f01058b3:	83 e8 20             	sub    $0x20,%eax
f01058b6:	83 f8 5e             	cmp    $0x5e,%eax
f01058b9:	76 c6                	jbe    f0105881 <vprintfmt+0x1d7>
					putch('?', putdat);
f01058bb:	83 ec 08             	sub    $0x8,%esp
f01058be:	53                   	push   %ebx
f01058bf:	6a 3f                	push   $0x3f
f01058c1:	ff d6                	call   *%esi
f01058c3:	83 c4 10             	add    $0x10,%esp
f01058c6:	eb c3                	jmp    f010588b <vprintfmt+0x1e1>
f01058c8:	89 cf                	mov    %ecx,%edi
f01058ca:	eb 0e                	jmp    f01058da <vprintfmt+0x230>
				putch(' ', putdat);
f01058cc:	83 ec 08             	sub    $0x8,%esp
f01058cf:	53                   	push   %ebx
f01058d0:	6a 20                	push   $0x20
f01058d2:	ff d6                	call   *%esi
			for (; width > 0; width--)
f01058d4:	83 ef 01             	sub    $0x1,%edi
f01058d7:	83 c4 10             	add    $0x10,%esp
f01058da:	85 ff                	test   %edi,%edi
f01058dc:	7f ee                	jg     f01058cc <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
f01058de:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01058e1:	89 45 14             	mov    %eax,0x14(%ebp)
f01058e4:	e9 23 01 00 00       	jmp    f0105a0c <vprintfmt+0x362>
f01058e9:	89 cf                	mov    %ecx,%edi
f01058eb:	eb ed                	jmp    f01058da <vprintfmt+0x230>
	if (lflag >= 2)
f01058ed:	83 f9 01             	cmp    $0x1,%ecx
f01058f0:	7f 1b                	jg     f010590d <vprintfmt+0x263>
	else if (lflag)
f01058f2:	85 c9                	test   %ecx,%ecx
f01058f4:	74 63                	je     f0105959 <vprintfmt+0x2af>
		return va_arg(*ap, long);
f01058f6:	8b 45 14             	mov    0x14(%ebp),%eax
f01058f9:	8b 00                	mov    (%eax),%eax
f01058fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01058fe:	99                   	cltd   
f01058ff:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105902:	8b 45 14             	mov    0x14(%ebp),%eax
f0105905:	8d 40 04             	lea    0x4(%eax),%eax
f0105908:	89 45 14             	mov    %eax,0x14(%ebp)
f010590b:	eb 17                	jmp    f0105924 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
f010590d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105910:	8b 50 04             	mov    0x4(%eax),%edx
f0105913:	8b 00                	mov    (%eax),%eax
f0105915:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105918:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010591b:	8b 45 14             	mov    0x14(%ebp),%eax
f010591e:	8d 40 08             	lea    0x8(%eax),%eax
f0105921:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0105924:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105927:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f010592a:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f010592f:	85 c9                	test   %ecx,%ecx
f0105931:	0f 89 bb 00 00 00    	jns    f01059f2 <vprintfmt+0x348>
				putch('-', putdat);
f0105937:	83 ec 08             	sub    $0x8,%esp
f010593a:	53                   	push   %ebx
f010593b:	6a 2d                	push   $0x2d
f010593d:	ff d6                	call   *%esi
				num = -(long long) num;
f010593f:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105942:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105945:	f7 da                	neg    %edx
f0105947:	83 d1 00             	adc    $0x0,%ecx
f010594a:	f7 d9                	neg    %ecx
f010594c:	83 c4 10             	add    $0x10,%esp
			base = 10;
f010594f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105954:	e9 99 00 00 00       	jmp    f01059f2 <vprintfmt+0x348>
		return va_arg(*ap, int);
f0105959:	8b 45 14             	mov    0x14(%ebp),%eax
f010595c:	8b 00                	mov    (%eax),%eax
f010595e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105961:	99                   	cltd   
f0105962:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105965:	8b 45 14             	mov    0x14(%ebp),%eax
f0105968:	8d 40 04             	lea    0x4(%eax),%eax
f010596b:	89 45 14             	mov    %eax,0x14(%ebp)
f010596e:	eb b4                	jmp    f0105924 <vprintfmt+0x27a>
	if (lflag >= 2)
f0105970:	83 f9 01             	cmp    $0x1,%ecx
f0105973:	7f 1b                	jg     f0105990 <vprintfmt+0x2e6>
	else if (lflag)
f0105975:	85 c9                	test   %ecx,%ecx
f0105977:	74 2c                	je     f01059a5 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
f0105979:	8b 45 14             	mov    0x14(%ebp),%eax
f010597c:	8b 10                	mov    (%eax),%edx
f010597e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105983:	8d 40 04             	lea    0x4(%eax),%eax
f0105986:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105989:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
f010598e:	eb 62                	jmp    f01059f2 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
f0105990:	8b 45 14             	mov    0x14(%ebp),%eax
f0105993:	8b 10                	mov    (%eax),%edx
f0105995:	8b 48 04             	mov    0x4(%eax),%ecx
f0105998:	8d 40 08             	lea    0x8(%eax),%eax
f010599b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010599e:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
f01059a3:	eb 4d                	jmp    f01059f2 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
f01059a5:	8b 45 14             	mov    0x14(%ebp),%eax
f01059a8:	8b 10                	mov    (%eax),%edx
f01059aa:	b9 00 00 00 00       	mov    $0x0,%ecx
f01059af:	8d 40 04             	lea    0x4(%eax),%eax
f01059b2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01059b5:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
f01059ba:	eb 36                	jmp    f01059f2 <vprintfmt+0x348>
	if (lflag >= 2)
f01059bc:	83 f9 01             	cmp    $0x1,%ecx
f01059bf:	7f 17                	jg     f01059d8 <vprintfmt+0x32e>
	else if (lflag)
f01059c1:	85 c9                	test   %ecx,%ecx
f01059c3:	74 6e                	je     f0105a33 <vprintfmt+0x389>
		return va_arg(*ap, long);
f01059c5:	8b 45 14             	mov    0x14(%ebp),%eax
f01059c8:	8b 10                	mov    (%eax),%edx
f01059ca:	89 d0                	mov    %edx,%eax
f01059cc:	99                   	cltd   
f01059cd:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01059d0:	8d 49 04             	lea    0x4(%ecx),%ecx
f01059d3:	89 4d 14             	mov    %ecx,0x14(%ebp)
f01059d6:	eb 11                	jmp    f01059e9 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
f01059d8:	8b 45 14             	mov    0x14(%ebp),%eax
f01059db:	8b 50 04             	mov    0x4(%eax),%edx
f01059de:	8b 00                	mov    (%eax),%eax
f01059e0:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01059e3:	8d 49 08             	lea    0x8(%ecx),%ecx
f01059e6:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
f01059e9:	89 d1                	mov    %edx,%ecx
f01059eb:	89 c2                	mov    %eax,%edx
            base = 8;
f01059ed:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
f01059f2:	83 ec 0c             	sub    $0xc,%esp
f01059f5:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
f01059f9:	57                   	push   %edi
f01059fa:	ff 75 e0             	pushl  -0x20(%ebp)
f01059fd:	50                   	push   %eax
f01059fe:	51                   	push   %ecx
f01059ff:	52                   	push   %edx
f0105a00:	89 da                	mov    %ebx,%edx
f0105a02:	89 f0                	mov    %esi,%eax
f0105a04:	e8 b6 fb ff ff       	call   f01055bf <printnum>
			break;
f0105a09:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f0105a0c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105a0f:	83 c7 01             	add    $0x1,%edi
f0105a12:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105a16:	83 f8 25             	cmp    $0x25,%eax
f0105a19:	0f 84 a6 fc ff ff    	je     f01056c5 <vprintfmt+0x1b>
			if (ch == '\0')
f0105a1f:	85 c0                	test   %eax,%eax
f0105a21:	0f 84 ce 00 00 00    	je     f0105af5 <vprintfmt+0x44b>
			putch(ch, putdat);
f0105a27:	83 ec 08             	sub    $0x8,%esp
f0105a2a:	53                   	push   %ebx
f0105a2b:	50                   	push   %eax
f0105a2c:	ff d6                	call   *%esi
f0105a2e:	83 c4 10             	add    $0x10,%esp
f0105a31:	eb dc                	jmp    f0105a0f <vprintfmt+0x365>
		return va_arg(*ap, int);
f0105a33:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a36:	8b 10                	mov    (%eax),%edx
f0105a38:	89 d0                	mov    %edx,%eax
f0105a3a:	99                   	cltd   
f0105a3b:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0105a3e:	8d 49 04             	lea    0x4(%ecx),%ecx
f0105a41:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105a44:	eb a3                	jmp    f01059e9 <vprintfmt+0x33f>
			putch('0', putdat);
f0105a46:	83 ec 08             	sub    $0x8,%esp
f0105a49:	53                   	push   %ebx
f0105a4a:	6a 30                	push   $0x30
f0105a4c:	ff d6                	call   *%esi
			putch('x', putdat);
f0105a4e:	83 c4 08             	add    $0x8,%esp
f0105a51:	53                   	push   %ebx
f0105a52:	6a 78                	push   $0x78
f0105a54:	ff d6                	call   *%esi
			num = (unsigned long long)
f0105a56:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a59:	8b 10                	mov    (%eax),%edx
f0105a5b:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0105a60:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0105a63:	8d 40 04             	lea    0x4(%eax),%eax
f0105a66:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105a69:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0105a6e:	eb 82                	jmp    f01059f2 <vprintfmt+0x348>
	if (lflag >= 2)
f0105a70:	83 f9 01             	cmp    $0x1,%ecx
f0105a73:	7f 1e                	jg     f0105a93 <vprintfmt+0x3e9>
	else if (lflag)
f0105a75:	85 c9                	test   %ecx,%ecx
f0105a77:	74 32                	je     f0105aab <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
f0105a79:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a7c:	8b 10                	mov    (%eax),%edx
f0105a7e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105a83:	8d 40 04             	lea    0x4(%eax),%eax
f0105a86:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105a89:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
f0105a8e:	e9 5f ff ff ff       	jmp    f01059f2 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
f0105a93:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a96:	8b 10                	mov    (%eax),%edx
f0105a98:	8b 48 04             	mov    0x4(%eax),%ecx
f0105a9b:	8d 40 08             	lea    0x8(%eax),%eax
f0105a9e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105aa1:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
f0105aa6:	e9 47 ff ff ff       	jmp    f01059f2 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
f0105aab:	8b 45 14             	mov    0x14(%ebp),%eax
f0105aae:	8b 10                	mov    (%eax),%edx
f0105ab0:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105ab5:	8d 40 04             	lea    0x4(%eax),%eax
f0105ab8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105abb:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
f0105ac0:	e9 2d ff ff ff       	jmp    f01059f2 <vprintfmt+0x348>
			putch(ch, putdat);
f0105ac5:	83 ec 08             	sub    $0x8,%esp
f0105ac8:	53                   	push   %ebx
f0105ac9:	6a 25                	push   $0x25
f0105acb:	ff d6                	call   *%esi
			break;
f0105acd:	83 c4 10             	add    $0x10,%esp
f0105ad0:	e9 37 ff ff ff       	jmp    f0105a0c <vprintfmt+0x362>
			putch('%', putdat);
f0105ad5:	83 ec 08             	sub    $0x8,%esp
f0105ad8:	53                   	push   %ebx
f0105ad9:	6a 25                	push   $0x25
f0105adb:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105add:	83 c4 10             	add    $0x10,%esp
f0105ae0:	89 f8                	mov    %edi,%eax
f0105ae2:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0105ae6:	74 05                	je     f0105aed <vprintfmt+0x443>
f0105ae8:	83 e8 01             	sub    $0x1,%eax
f0105aeb:	eb f5                	jmp    f0105ae2 <vprintfmt+0x438>
f0105aed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105af0:	e9 17 ff ff ff       	jmp    f0105a0c <vprintfmt+0x362>
}
f0105af5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105af8:	5b                   	pop    %ebx
f0105af9:	5e                   	pop    %esi
f0105afa:	5f                   	pop    %edi
f0105afb:	5d                   	pop    %ebp
f0105afc:	c3                   	ret    

f0105afd <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105afd:	f3 0f 1e fb          	endbr32 
f0105b01:	55                   	push   %ebp
f0105b02:	89 e5                	mov    %esp,%ebp
f0105b04:	83 ec 18             	sub    $0x18,%esp
f0105b07:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b0a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105b0d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105b10:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105b14:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105b17:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105b1e:	85 c0                	test   %eax,%eax
f0105b20:	74 26                	je     f0105b48 <vsnprintf+0x4b>
f0105b22:	85 d2                	test   %edx,%edx
f0105b24:	7e 22                	jle    f0105b48 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105b26:	ff 75 14             	pushl  0x14(%ebp)
f0105b29:	ff 75 10             	pushl  0x10(%ebp)
f0105b2c:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105b2f:	50                   	push   %eax
f0105b30:	68 68 56 10 f0       	push   $0xf0105668
f0105b35:	e8 70 fb ff ff       	call   f01056aa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105b3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105b3d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105b43:	83 c4 10             	add    $0x10,%esp
}
f0105b46:	c9                   	leave  
f0105b47:	c3                   	ret    
		return -E_INVAL;
f0105b48:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105b4d:	eb f7                	jmp    f0105b46 <vsnprintf+0x49>

f0105b4f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105b4f:	f3 0f 1e fb          	endbr32 
f0105b53:	55                   	push   %ebp
f0105b54:	89 e5                	mov    %esp,%ebp
f0105b56:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105b59:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105b5c:	50                   	push   %eax
f0105b5d:	ff 75 10             	pushl  0x10(%ebp)
f0105b60:	ff 75 0c             	pushl  0xc(%ebp)
f0105b63:	ff 75 08             	pushl  0x8(%ebp)
f0105b66:	e8 92 ff ff ff       	call   f0105afd <vsnprintf>
	va_end(ap);

	return rc;
}
f0105b6b:	c9                   	leave  
f0105b6c:	c3                   	ret    

f0105b6d <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105b6d:	f3 0f 1e fb          	endbr32 
f0105b71:	55                   	push   %ebp
f0105b72:	89 e5                	mov    %esp,%ebp
f0105b74:	57                   	push   %edi
f0105b75:	56                   	push   %esi
f0105b76:	53                   	push   %ebx
f0105b77:	83 ec 0c             	sub    $0xc,%esp
f0105b7a:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105b7d:	85 c0                	test   %eax,%eax
f0105b7f:	74 11                	je     f0105b92 <readline+0x25>
		cprintf("%s", prompt);
f0105b81:	83 ec 08             	sub    $0x8,%esp
f0105b84:	50                   	push   %eax
f0105b85:	68 cb 79 10 f0       	push   $0xf01079cb
f0105b8a:	e8 af df ff ff       	call   f0103b3e <cprintf>
f0105b8f:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105b92:	83 ec 0c             	sub    $0xc,%esp
f0105b95:	6a 00                	push   $0x0
f0105b97:	e8 36 ac ff ff       	call   f01007d2 <iscons>
f0105b9c:	89 c7                	mov    %eax,%edi
f0105b9e:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0105ba1:	be 00 00 00 00       	mov    $0x0,%esi
f0105ba6:	eb 57                	jmp    f0105bff <readline+0x92>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f0105ba8:	b8 00 00 00 00       	mov    $0x0,%eax
			if (c != -E_EOF)
f0105bad:	83 fb f8             	cmp    $0xfffffff8,%ebx
f0105bb0:	75 08                	jne    f0105bba <readline+0x4d>
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0105bb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105bb5:	5b                   	pop    %ebx
f0105bb6:	5e                   	pop    %esi
f0105bb7:	5f                   	pop    %edi
f0105bb8:	5d                   	pop    %ebp
f0105bb9:	c3                   	ret    
				cprintf("read error: %e\n", c);
f0105bba:	83 ec 08             	sub    $0x8,%esp
f0105bbd:	53                   	push   %ebx
f0105bbe:	68 ff 85 10 f0       	push   $0xf01085ff
f0105bc3:	e8 76 df ff ff       	call   f0103b3e <cprintf>
f0105bc8:	83 c4 10             	add    $0x10,%esp
			return NULL;
f0105bcb:	b8 00 00 00 00       	mov    $0x0,%eax
f0105bd0:	eb e0                	jmp    f0105bb2 <readline+0x45>
			if (echoing)
f0105bd2:	85 ff                	test   %edi,%edi
f0105bd4:	75 05                	jne    f0105bdb <readline+0x6e>
			i--;
f0105bd6:	83 ee 01             	sub    $0x1,%esi
f0105bd9:	eb 24                	jmp    f0105bff <readline+0x92>
				cputchar('\b');
f0105bdb:	83 ec 0c             	sub    $0xc,%esp
f0105bde:	6a 08                	push   $0x8
f0105be0:	e8 c4 ab ff ff       	call   f01007a9 <cputchar>
f0105be5:	83 c4 10             	add    $0x10,%esp
f0105be8:	eb ec                	jmp    f0105bd6 <readline+0x69>
				cputchar(c);
f0105bea:	83 ec 0c             	sub    $0xc,%esp
f0105bed:	53                   	push   %ebx
f0105bee:	e8 b6 ab ff ff       	call   f01007a9 <cputchar>
f0105bf3:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105bf6:	88 9e 80 0a 33 f0    	mov    %bl,-0xfccf580(%esi)
f0105bfc:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f0105bff:	e8 b9 ab ff ff       	call   f01007bd <getchar>
f0105c04:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105c06:	85 c0                	test   %eax,%eax
f0105c08:	78 9e                	js     f0105ba8 <readline+0x3b>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105c0a:	83 f8 08             	cmp    $0x8,%eax
f0105c0d:	0f 94 c2             	sete   %dl
f0105c10:	83 f8 7f             	cmp    $0x7f,%eax
f0105c13:	0f 94 c0             	sete   %al
f0105c16:	08 c2                	or     %al,%dl
f0105c18:	74 04                	je     f0105c1e <readline+0xb1>
f0105c1a:	85 f6                	test   %esi,%esi
f0105c1c:	7f b4                	jg     f0105bd2 <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105c1e:	83 fb 1f             	cmp    $0x1f,%ebx
f0105c21:	7e 0e                	jle    f0105c31 <readline+0xc4>
f0105c23:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105c29:	7f 06                	jg     f0105c31 <readline+0xc4>
			if (echoing)
f0105c2b:	85 ff                	test   %edi,%edi
f0105c2d:	74 c7                	je     f0105bf6 <readline+0x89>
f0105c2f:	eb b9                	jmp    f0105bea <readline+0x7d>
		} else if (c == '\n' || c == '\r') {
f0105c31:	83 fb 0a             	cmp    $0xa,%ebx
f0105c34:	74 05                	je     f0105c3b <readline+0xce>
f0105c36:	83 fb 0d             	cmp    $0xd,%ebx
f0105c39:	75 c4                	jne    f0105bff <readline+0x92>
			if (echoing)
f0105c3b:	85 ff                	test   %edi,%edi
f0105c3d:	75 11                	jne    f0105c50 <readline+0xe3>
			buf[i] = 0;
f0105c3f:	c6 86 80 0a 33 f0 00 	movb   $0x0,-0xfccf580(%esi)
			return buf;
f0105c46:	b8 80 0a 33 f0       	mov    $0xf0330a80,%eax
f0105c4b:	e9 62 ff ff ff       	jmp    f0105bb2 <readline+0x45>
				cputchar('\n');
f0105c50:	83 ec 0c             	sub    $0xc,%esp
f0105c53:	6a 0a                	push   $0xa
f0105c55:	e8 4f ab ff ff       	call   f01007a9 <cputchar>
f0105c5a:	83 c4 10             	add    $0x10,%esp
f0105c5d:	eb e0                	jmp    f0105c3f <readline+0xd2>

f0105c5f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105c5f:	f3 0f 1e fb          	endbr32 
f0105c63:	55                   	push   %ebp
f0105c64:	89 e5                	mov    %esp,%ebp
f0105c66:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105c69:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c6e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105c72:	74 05                	je     f0105c79 <strlen+0x1a>
		n++;
f0105c74:	83 c0 01             	add    $0x1,%eax
f0105c77:	eb f5                	jmp    f0105c6e <strlen+0xf>
	return n;
}
f0105c79:	5d                   	pop    %ebp
f0105c7a:	c3                   	ret    

f0105c7b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105c7b:	f3 0f 1e fb          	endbr32 
f0105c7f:	55                   	push   %ebp
f0105c80:	89 e5                	mov    %esp,%ebp
f0105c82:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105c85:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105c88:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c8d:	39 d0                	cmp    %edx,%eax
f0105c8f:	74 0d                	je     f0105c9e <strnlen+0x23>
f0105c91:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0105c95:	74 05                	je     f0105c9c <strnlen+0x21>
		n++;
f0105c97:	83 c0 01             	add    $0x1,%eax
f0105c9a:	eb f1                	jmp    f0105c8d <strnlen+0x12>
f0105c9c:	89 c2                	mov    %eax,%edx
	return n;
}
f0105c9e:	89 d0                	mov    %edx,%eax
f0105ca0:	5d                   	pop    %ebp
f0105ca1:	c3                   	ret    

f0105ca2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105ca2:	f3 0f 1e fb          	endbr32 
f0105ca6:	55                   	push   %ebp
f0105ca7:	89 e5                	mov    %esp,%ebp
f0105ca9:	53                   	push   %ebx
f0105caa:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105cad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105cb0:	b8 00 00 00 00       	mov    $0x0,%eax
f0105cb5:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f0105cb9:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f0105cbc:	83 c0 01             	add    $0x1,%eax
f0105cbf:	84 d2                	test   %dl,%dl
f0105cc1:	75 f2                	jne    f0105cb5 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
f0105cc3:	89 c8                	mov    %ecx,%eax
f0105cc5:	5b                   	pop    %ebx
f0105cc6:	5d                   	pop    %ebp
f0105cc7:	c3                   	ret    

f0105cc8 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105cc8:	f3 0f 1e fb          	endbr32 
f0105ccc:	55                   	push   %ebp
f0105ccd:	89 e5                	mov    %esp,%ebp
f0105ccf:	53                   	push   %ebx
f0105cd0:	83 ec 10             	sub    $0x10,%esp
f0105cd3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105cd6:	53                   	push   %ebx
f0105cd7:	e8 83 ff ff ff       	call   f0105c5f <strlen>
f0105cdc:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0105cdf:	ff 75 0c             	pushl  0xc(%ebp)
f0105ce2:	01 d8                	add    %ebx,%eax
f0105ce4:	50                   	push   %eax
f0105ce5:	e8 b8 ff ff ff       	call   f0105ca2 <strcpy>
	return dst;
}
f0105cea:	89 d8                	mov    %ebx,%eax
f0105cec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105cef:	c9                   	leave  
f0105cf0:	c3                   	ret    

f0105cf1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105cf1:	f3 0f 1e fb          	endbr32 
f0105cf5:	55                   	push   %ebp
f0105cf6:	89 e5                	mov    %esp,%ebp
f0105cf8:	56                   	push   %esi
f0105cf9:	53                   	push   %ebx
f0105cfa:	8b 75 08             	mov    0x8(%ebp),%esi
f0105cfd:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105d00:	89 f3                	mov    %esi,%ebx
f0105d02:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105d05:	89 f0                	mov    %esi,%eax
f0105d07:	39 d8                	cmp    %ebx,%eax
f0105d09:	74 11                	je     f0105d1c <strncpy+0x2b>
		*dst++ = *src;
f0105d0b:	83 c0 01             	add    $0x1,%eax
f0105d0e:	0f b6 0a             	movzbl (%edx),%ecx
f0105d11:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105d14:	80 f9 01             	cmp    $0x1,%cl
f0105d17:	83 da ff             	sbb    $0xffffffff,%edx
f0105d1a:	eb eb                	jmp    f0105d07 <strncpy+0x16>
	}
	return ret;
}
f0105d1c:	89 f0                	mov    %esi,%eax
f0105d1e:	5b                   	pop    %ebx
f0105d1f:	5e                   	pop    %esi
f0105d20:	5d                   	pop    %ebp
f0105d21:	c3                   	ret    

f0105d22 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105d22:	f3 0f 1e fb          	endbr32 
f0105d26:	55                   	push   %ebp
f0105d27:	89 e5                	mov    %esp,%ebp
f0105d29:	56                   	push   %esi
f0105d2a:	53                   	push   %ebx
f0105d2b:	8b 75 08             	mov    0x8(%ebp),%esi
f0105d2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105d31:	8b 55 10             	mov    0x10(%ebp),%edx
f0105d34:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105d36:	85 d2                	test   %edx,%edx
f0105d38:	74 21                	je     f0105d5b <strlcpy+0x39>
f0105d3a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105d3e:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f0105d40:	39 c2                	cmp    %eax,%edx
f0105d42:	74 14                	je     f0105d58 <strlcpy+0x36>
f0105d44:	0f b6 19             	movzbl (%ecx),%ebx
f0105d47:	84 db                	test   %bl,%bl
f0105d49:	74 0b                	je     f0105d56 <strlcpy+0x34>
			*dst++ = *src++;
f0105d4b:	83 c1 01             	add    $0x1,%ecx
f0105d4e:	83 c2 01             	add    $0x1,%edx
f0105d51:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105d54:	eb ea                	jmp    f0105d40 <strlcpy+0x1e>
f0105d56:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0105d58:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105d5b:	29 f0                	sub    %esi,%eax
}
f0105d5d:	5b                   	pop    %ebx
f0105d5e:	5e                   	pop    %esi
f0105d5f:	5d                   	pop    %ebp
f0105d60:	c3                   	ret    

f0105d61 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105d61:	f3 0f 1e fb          	endbr32 
f0105d65:	55                   	push   %ebp
f0105d66:	89 e5                	mov    %esp,%ebp
f0105d68:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105d6b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105d6e:	0f b6 01             	movzbl (%ecx),%eax
f0105d71:	84 c0                	test   %al,%al
f0105d73:	74 0c                	je     f0105d81 <strcmp+0x20>
f0105d75:	3a 02                	cmp    (%edx),%al
f0105d77:	75 08                	jne    f0105d81 <strcmp+0x20>
		p++, q++;
f0105d79:	83 c1 01             	add    $0x1,%ecx
f0105d7c:	83 c2 01             	add    $0x1,%edx
f0105d7f:	eb ed                	jmp    f0105d6e <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105d81:	0f b6 c0             	movzbl %al,%eax
f0105d84:	0f b6 12             	movzbl (%edx),%edx
f0105d87:	29 d0                	sub    %edx,%eax
}
f0105d89:	5d                   	pop    %ebp
f0105d8a:	c3                   	ret    

f0105d8b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105d8b:	f3 0f 1e fb          	endbr32 
f0105d8f:	55                   	push   %ebp
f0105d90:	89 e5                	mov    %esp,%ebp
f0105d92:	53                   	push   %ebx
f0105d93:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d96:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105d99:	89 c3                	mov    %eax,%ebx
f0105d9b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105d9e:	eb 06                	jmp    f0105da6 <strncmp+0x1b>
		n--, p++, q++;
f0105da0:	83 c0 01             	add    $0x1,%eax
f0105da3:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0105da6:	39 d8                	cmp    %ebx,%eax
f0105da8:	74 16                	je     f0105dc0 <strncmp+0x35>
f0105daa:	0f b6 08             	movzbl (%eax),%ecx
f0105dad:	84 c9                	test   %cl,%cl
f0105daf:	74 04                	je     f0105db5 <strncmp+0x2a>
f0105db1:	3a 0a                	cmp    (%edx),%cl
f0105db3:	74 eb                	je     f0105da0 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105db5:	0f b6 00             	movzbl (%eax),%eax
f0105db8:	0f b6 12             	movzbl (%edx),%edx
f0105dbb:	29 d0                	sub    %edx,%eax
}
f0105dbd:	5b                   	pop    %ebx
f0105dbe:	5d                   	pop    %ebp
f0105dbf:	c3                   	ret    
		return 0;
f0105dc0:	b8 00 00 00 00       	mov    $0x0,%eax
f0105dc5:	eb f6                	jmp    f0105dbd <strncmp+0x32>

f0105dc7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105dc7:	f3 0f 1e fb          	endbr32 
f0105dcb:	55                   	push   %ebp
f0105dcc:	89 e5                	mov    %esp,%ebp
f0105dce:	8b 45 08             	mov    0x8(%ebp),%eax
f0105dd1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105dd5:	0f b6 10             	movzbl (%eax),%edx
f0105dd8:	84 d2                	test   %dl,%dl
f0105dda:	74 09                	je     f0105de5 <strchr+0x1e>
		if (*s == c)
f0105ddc:	38 ca                	cmp    %cl,%dl
f0105dde:	74 0a                	je     f0105dea <strchr+0x23>
	for (; *s; s++)
f0105de0:	83 c0 01             	add    $0x1,%eax
f0105de3:	eb f0                	jmp    f0105dd5 <strchr+0xe>
			return (char *) s;
	return 0;
f0105de5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105dea:	5d                   	pop    %ebp
f0105deb:	c3                   	ret    

f0105dec <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105dec:	f3 0f 1e fb          	endbr32 
f0105df0:	55                   	push   %ebp
f0105df1:	89 e5                	mov    %esp,%ebp
f0105df3:	8b 45 08             	mov    0x8(%ebp),%eax
f0105df6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105dfa:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105dfd:	38 ca                	cmp    %cl,%dl
f0105dff:	74 09                	je     f0105e0a <strfind+0x1e>
f0105e01:	84 d2                	test   %dl,%dl
f0105e03:	74 05                	je     f0105e0a <strfind+0x1e>
	for (; *s; s++)
f0105e05:	83 c0 01             	add    $0x1,%eax
f0105e08:	eb f0                	jmp    f0105dfa <strfind+0xe>
			break;
	return (char *) s;
}
f0105e0a:	5d                   	pop    %ebp
f0105e0b:	c3                   	ret    

f0105e0c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105e0c:	f3 0f 1e fb          	endbr32 
f0105e10:	55                   	push   %ebp
f0105e11:	89 e5                	mov    %esp,%ebp
f0105e13:	57                   	push   %edi
f0105e14:	56                   	push   %esi
f0105e15:	53                   	push   %ebx
f0105e16:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105e19:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105e1c:	85 c9                	test   %ecx,%ecx
f0105e1e:	74 31                	je     f0105e51 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105e20:	89 f8                	mov    %edi,%eax
f0105e22:	09 c8                	or     %ecx,%eax
f0105e24:	a8 03                	test   $0x3,%al
f0105e26:	75 23                	jne    f0105e4b <memset+0x3f>
		c &= 0xFF;
f0105e28:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105e2c:	89 d3                	mov    %edx,%ebx
f0105e2e:	c1 e3 08             	shl    $0x8,%ebx
f0105e31:	89 d0                	mov    %edx,%eax
f0105e33:	c1 e0 18             	shl    $0x18,%eax
f0105e36:	89 d6                	mov    %edx,%esi
f0105e38:	c1 e6 10             	shl    $0x10,%esi
f0105e3b:	09 f0                	or     %esi,%eax
f0105e3d:	09 c2                	or     %eax,%edx
f0105e3f:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105e41:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0105e44:	89 d0                	mov    %edx,%eax
f0105e46:	fc                   	cld    
f0105e47:	f3 ab                	rep stos %eax,%es:(%edi)
f0105e49:	eb 06                	jmp    f0105e51 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105e4b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105e4e:	fc                   	cld    
f0105e4f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105e51:	89 f8                	mov    %edi,%eax
f0105e53:	5b                   	pop    %ebx
f0105e54:	5e                   	pop    %esi
f0105e55:	5f                   	pop    %edi
f0105e56:	5d                   	pop    %ebp
f0105e57:	c3                   	ret    

f0105e58 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105e58:	f3 0f 1e fb          	endbr32 
f0105e5c:	55                   	push   %ebp
f0105e5d:	89 e5                	mov    %esp,%ebp
f0105e5f:	57                   	push   %edi
f0105e60:	56                   	push   %esi
f0105e61:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e64:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105e67:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105e6a:	39 c6                	cmp    %eax,%esi
f0105e6c:	73 32                	jae    f0105ea0 <memmove+0x48>
f0105e6e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105e71:	39 c2                	cmp    %eax,%edx
f0105e73:	76 2b                	jbe    f0105ea0 <memmove+0x48>
		s += n;
		d += n;
f0105e75:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105e78:	89 fe                	mov    %edi,%esi
f0105e7a:	09 ce                	or     %ecx,%esi
f0105e7c:	09 d6                	or     %edx,%esi
f0105e7e:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105e84:	75 0e                	jne    f0105e94 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105e86:	83 ef 04             	sub    $0x4,%edi
f0105e89:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105e8c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0105e8f:	fd                   	std    
f0105e90:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105e92:	eb 09                	jmp    f0105e9d <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105e94:	83 ef 01             	sub    $0x1,%edi
f0105e97:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0105e9a:	fd                   	std    
f0105e9b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105e9d:	fc                   	cld    
f0105e9e:	eb 1a                	jmp    f0105eba <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105ea0:	89 c2                	mov    %eax,%edx
f0105ea2:	09 ca                	or     %ecx,%edx
f0105ea4:	09 f2                	or     %esi,%edx
f0105ea6:	f6 c2 03             	test   $0x3,%dl
f0105ea9:	75 0a                	jne    f0105eb5 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105eab:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0105eae:	89 c7                	mov    %eax,%edi
f0105eb0:	fc                   	cld    
f0105eb1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105eb3:	eb 05                	jmp    f0105eba <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
f0105eb5:	89 c7                	mov    %eax,%edi
f0105eb7:	fc                   	cld    
f0105eb8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105eba:	5e                   	pop    %esi
f0105ebb:	5f                   	pop    %edi
f0105ebc:	5d                   	pop    %ebp
f0105ebd:	c3                   	ret    

f0105ebe <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105ebe:	f3 0f 1e fb          	endbr32 
f0105ec2:	55                   	push   %ebp
f0105ec3:	89 e5                	mov    %esp,%ebp
f0105ec5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105ec8:	ff 75 10             	pushl  0x10(%ebp)
f0105ecb:	ff 75 0c             	pushl  0xc(%ebp)
f0105ece:	ff 75 08             	pushl  0x8(%ebp)
f0105ed1:	e8 82 ff ff ff       	call   f0105e58 <memmove>
}
f0105ed6:	c9                   	leave  
f0105ed7:	c3                   	ret    

f0105ed8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105ed8:	f3 0f 1e fb          	endbr32 
f0105edc:	55                   	push   %ebp
f0105edd:	89 e5                	mov    %esp,%ebp
f0105edf:	56                   	push   %esi
f0105ee0:	53                   	push   %ebx
f0105ee1:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ee4:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105ee7:	89 c6                	mov    %eax,%esi
f0105ee9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105eec:	39 f0                	cmp    %esi,%eax
f0105eee:	74 1c                	je     f0105f0c <memcmp+0x34>
		if (*s1 != *s2)
f0105ef0:	0f b6 08             	movzbl (%eax),%ecx
f0105ef3:	0f b6 1a             	movzbl (%edx),%ebx
f0105ef6:	38 d9                	cmp    %bl,%cl
f0105ef8:	75 08                	jne    f0105f02 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0105efa:	83 c0 01             	add    $0x1,%eax
f0105efd:	83 c2 01             	add    $0x1,%edx
f0105f00:	eb ea                	jmp    f0105eec <memcmp+0x14>
			return (int) *s1 - (int) *s2;
f0105f02:	0f b6 c1             	movzbl %cl,%eax
f0105f05:	0f b6 db             	movzbl %bl,%ebx
f0105f08:	29 d8                	sub    %ebx,%eax
f0105f0a:	eb 05                	jmp    f0105f11 <memcmp+0x39>
	}

	return 0;
f0105f0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105f11:	5b                   	pop    %ebx
f0105f12:	5e                   	pop    %esi
f0105f13:	5d                   	pop    %ebp
f0105f14:	c3                   	ret    

f0105f15 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105f15:	f3 0f 1e fb          	endbr32 
f0105f19:	55                   	push   %ebp
f0105f1a:	89 e5                	mov    %esp,%ebp
f0105f1c:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105f22:	89 c2                	mov    %eax,%edx
f0105f24:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105f27:	39 d0                	cmp    %edx,%eax
f0105f29:	73 09                	jae    f0105f34 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105f2b:	38 08                	cmp    %cl,(%eax)
f0105f2d:	74 05                	je     f0105f34 <memfind+0x1f>
	for (; s < ends; s++)
f0105f2f:	83 c0 01             	add    $0x1,%eax
f0105f32:	eb f3                	jmp    f0105f27 <memfind+0x12>
			break;
	return (void *) s;
}
f0105f34:	5d                   	pop    %ebp
f0105f35:	c3                   	ret    

f0105f36 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105f36:	f3 0f 1e fb          	endbr32 
f0105f3a:	55                   	push   %ebp
f0105f3b:	89 e5                	mov    %esp,%ebp
f0105f3d:	57                   	push   %edi
f0105f3e:	56                   	push   %esi
f0105f3f:	53                   	push   %ebx
f0105f40:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105f43:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105f46:	eb 03                	jmp    f0105f4b <strtol+0x15>
		s++;
f0105f48:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0105f4b:	0f b6 01             	movzbl (%ecx),%eax
f0105f4e:	3c 20                	cmp    $0x20,%al
f0105f50:	74 f6                	je     f0105f48 <strtol+0x12>
f0105f52:	3c 09                	cmp    $0x9,%al
f0105f54:	74 f2                	je     f0105f48 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
f0105f56:	3c 2b                	cmp    $0x2b,%al
f0105f58:	74 2a                	je     f0105f84 <strtol+0x4e>
	int neg = 0;
f0105f5a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0105f5f:	3c 2d                	cmp    $0x2d,%al
f0105f61:	74 2b                	je     f0105f8e <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105f63:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105f69:	75 0f                	jne    f0105f7a <strtol+0x44>
f0105f6b:	80 39 30             	cmpb   $0x30,(%ecx)
f0105f6e:	74 28                	je     f0105f98 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105f70:	85 db                	test   %ebx,%ebx
f0105f72:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105f77:	0f 44 d8             	cmove  %eax,%ebx
f0105f7a:	b8 00 00 00 00       	mov    $0x0,%eax
f0105f7f:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105f82:	eb 46                	jmp    f0105fca <strtol+0x94>
		s++;
f0105f84:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0105f87:	bf 00 00 00 00       	mov    $0x0,%edi
f0105f8c:	eb d5                	jmp    f0105f63 <strtol+0x2d>
		s++, neg = 1;
f0105f8e:	83 c1 01             	add    $0x1,%ecx
f0105f91:	bf 01 00 00 00       	mov    $0x1,%edi
f0105f96:	eb cb                	jmp    f0105f63 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105f98:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105f9c:	74 0e                	je     f0105fac <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0105f9e:	85 db                	test   %ebx,%ebx
f0105fa0:	75 d8                	jne    f0105f7a <strtol+0x44>
		s++, base = 8;
f0105fa2:	83 c1 01             	add    $0x1,%ecx
f0105fa5:	bb 08 00 00 00       	mov    $0x8,%ebx
f0105faa:	eb ce                	jmp    f0105f7a <strtol+0x44>
		s += 2, base = 16;
f0105fac:	83 c1 02             	add    $0x2,%ecx
f0105faf:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105fb4:	eb c4                	jmp    f0105f7a <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f0105fb6:	0f be d2             	movsbl %dl,%edx
f0105fb9:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105fbc:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105fbf:	7d 3a                	jge    f0105ffb <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f0105fc1:	83 c1 01             	add    $0x1,%ecx
f0105fc4:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105fc8:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0105fca:	0f b6 11             	movzbl (%ecx),%edx
f0105fcd:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105fd0:	89 f3                	mov    %esi,%ebx
f0105fd2:	80 fb 09             	cmp    $0x9,%bl
f0105fd5:	76 df                	jbe    f0105fb6 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
f0105fd7:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105fda:	89 f3                	mov    %esi,%ebx
f0105fdc:	80 fb 19             	cmp    $0x19,%bl
f0105fdf:	77 08                	ja     f0105fe9 <strtol+0xb3>
			dig = *s - 'a' + 10;
f0105fe1:	0f be d2             	movsbl %dl,%edx
f0105fe4:	83 ea 57             	sub    $0x57,%edx
f0105fe7:	eb d3                	jmp    f0105fbc <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
f0105fe9:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105fec:	89 f3                	mov    %esi,%ebx
f0105fee:	80 fb 19             	cmp    $0x19,%bl
f0105ff1:	77 08                	ja     f0105ffb <strtol+0xc5>
			dig = *s - 'A' + 10;
f0105ff3:	0f be d2             	movsbl %dl,%edx
f0105ff6:	83 ea 37             	sub    $0x37,%edx
f0105ff9:	eb c1                	jmp    f0105fbc <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
f0105ffb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105fff:	74 05                	je     f0106006 <strtol+0xd0>
		*endptr = (char *) s;
f0106001:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106004:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0106006:	89 c2                	mov    %eax,%edx
f0106008:	f7 da                	neg    %edx
f010600a:	85 ff                	test   %edi,%edi
f010600c:	0f 45 c2             	cmovne %edx,%eax
}
f010600f:	5b                   	pop    %ebx
f0106010:	5e                   	pop    %esi
f0106011:	5f                   	pop    %edi
f0106012:	5d                   	pop    %ebp
f0106013:	c3                   	ret    

f0106014 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0106014:	fa                   	cli    

	xorw    %ax, %ax
f0106015:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0106017:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106019:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010601b:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f010601d:	0f 01 16             	lgdtl  (%esi)
f0106020:	74 70                	je     f0106092 <mpsearch1+0x3>
	movl    %cr0, %eax
f0106022:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0106025:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0106029:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f010602c:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0106032:	08 00                	or     %al,(%eax)

f0106034 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0106034:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0106038:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010603a:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010603c:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f010603e:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0106042:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0106044:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0106046:	b8 00 20 12 00       	mov    $0x122000,%eax
	movl    %eax, %cr3
f010604b:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f010604e:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0106051:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0106056:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0106059:	8b 25 84 0e 33 f0    	mov    0xf0330e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f010605f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0106064:	b8 bd 01 10 f0       	mov    $0xf01001bd,%eax
	call    *%eax
f0106069:	ff d0                	call   *%eax

f010606b <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f010606b:	eb fe                	jmp    f010606b <spin>
f010606d:	8d 76 00             	lea    0x0(%esi),%esi

f0106070 <gdt>:
	...
f0106078:	ff                   	(bad)  
f0106079:	ff 00                	incl   (%eax)
f010607b:	00 00                	add    %al,(%eax)
f010607d:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0106084:	00                   	.byte 0x0
f0106085:	92                   	xchg   %eax,%edx
f0106086:	cf                   	iret   
	...

f0106088 <gdtdesc>:
f0106088:	17                   	pop    %ss
f0106089:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f010608e <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f010608e:	90                   	nop

f010608f <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f010608f:	55                   	push   %ebp
f0106090:	89 e5                	mov    %esp,%ebp
f0106092:	57                   	push   %edi
f0106093:	56                   	push   %esi
f0106094:	53                   	push   %ebx
f0106095:	83 ec 0c             	sub    $0xc,%esp
f0106098:	89 c7                	mov    %eax,%edi
	if (PGNUM(pa) >= npages)
f010609a:	a1 88 0e 33 f0       	mov    0xf0330e88,%eax
f010609f:	89 f9                	mov    %edi,%ecx
f01060a1:	c1 e9 0c             	shr    $0xc,%ecx
f01060a4:	39 c1                	cmp    %eax,%ecx
f01060a6:	73 19                	jae    f01060c1 <mpsearch1+0x32>
	return (void *)(pa + KERNBASE);
f01060a8:	8d 9f 00 00 00 f0    	lea    -0x10000000(%edi),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01060ae:	01 d7                	add    %edx,%edi
	if (PGNUM(pa) >= npages)
f01060b0:	89 fa                	mov    %edi,%edx
f01060b2:	c1 ea 0c             	shr    $0xc,%edx
f01060b5:	39 c2                	cmp    %eax,%edx
f01060b7:	73 1a                	jae    f01060d3 <mpsearch1+0x44>
	return (void *)(pa + KERNBASE);
f01060b9:	81 ef 00 00 00 10    	sub    $0x10000000,%edi

	for (; mp < end; mp++)
f01060bf:	eb 27                	jmp    f01060e8 <mpsearch1+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01060c1:	57                   	push   %edi
f01060c2:	68 c4 6a 10 f0       	push   $0xf0106ac4
f01060c7:	6a 57                	push   $0x57
f01060c9:	68 9d 87 10 f0       	push   $0xf010879d
f01060ce:	e8 6d 9f ff ff       	call   f0100040 <_panic>
f01060d3:	57                   	push   %edi
f01060d4:	68 c4 6a 10 f0       	push   $0xf0106ac4
f01060d9:	6a 57                	push   $0x57
f01060db:	68 9d 87 10 f0       	push   $0xf010879d
f01060e0:	e8 5b 9f ff ff       	call   f0100040 <_panic>
f01060e5:	83 c3 10             	add    $0x10,%ebx
f01060e8:	39 fb                	cmp    %edi,%ebx
f01060ea:	73 30                	jae    f010611c <mpsearch1+0x8d>
f01060ec:	89 de                	mov    %ebx,%esi
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01060ee:	83 ec 04             	sub    $0x4,%esp
f01060f1:	6a 04                	push   $0x4
f01060f3:	68 ad 87 10 f0       	push   $0xf01087ad
f01060f8:	53                   	push   %ebx
f01060f9:	e8 da fd ff ff       	call   f0105ed8 <memcmp>
f01060fe:	83 c4 10             	add    $0x10,%esp
f0106101:	85 c0                	test   %eax,%eax
f0106103:	75 e0                	jne    f01060e5 <mpsearch1+0x56>
f0106105:	89 da                	mov    %ebx,%edx
	for (i = 0; i < len; i++)
f0106107:	83 c6 10             	add    $0x10,%esi
		sum += ((uint8_t *)addr)[i];
f010610a:	0f b6 0a             	movzbl (%edx),%ecx
f010610d:	01 c8                	add    %ecx,%eax
f010610f:	83 c2 01             	add    $0x1,%edx
	for (i = 0; i < len; i++)
f0106112:	39 f2                	cmp    %esi,%edx
f0106114:	75 f4                	jne    f010610a <mpsearch1+0x7b>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106116:	84 c0                	test   %al,%al
f0106118:	75 cb                	jne    f01060e5 <mpsearch1+0x56>
f010611a:	eb 05                	jmp    f0106121 <mpsearch1+0x92>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f010611c:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0106121:	89 d8                	mov    %ebx,%eax
f0106123:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106126:	5b                   	pop    %ebx
f0106127:	5e                   	pop    %esi
f0106128:	5f                   	pop    %edi
f0106129:	5d                   	pop    %ebp
f010612a:	c3                   	ret    

f010612b <mp_init>:
	return conf;
}

void
mp_init(void)
{
f010612b:	f3 0f 1e fb          	endbr32 
f010612f:	55                   	push   %ebp
f0106130:	89 e5                	mov    %esp,%ebp
f0106132:	57                   	push   %edi
f0106133:	56                   	push   %esi
f0106134:	53                   	push   %ebx
f0106135:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0106138:	c7 05 c0 13 33 f0 20 	movl   $0xf0331020,0xf03313c0
f010613f:	10 33 f0 
	if (PGNUM(pa) >= npages)
f0106142:	83 3d 88 0e 33 f0 00 	cmpl   $0x0,0xf0330e88
f0106149:	0f 84 a3 00 00 00    	je     f01061f2 <mp_init+0xc7>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f010614f:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0106156:	85 c0                	test   %eax,%eax
f0106158:	0f 84 aa 00 00 00    	je     f0106208 <mp_init+0xdd>
		p <<= 4;	// Translate from segment to PA
f010615e:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0106161:	ba 00 04 00 00       	mov    $0x400,%edx
f0106166:	e8 24 ff ff ff       	call   f010608f <mpsearch1>
f010616b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010616e:	85 c0                	test   %eax,%eax
f0106170:	75 1a                	jne    f010618c <mp_init+0x61>
	return mpsearch1(0xF0000, 0x10000);
f0106172:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106177:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f010617c:	e8 0e ff ff ff       	call   f010608f <mpsearch1>
f0106181:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((mp = mpsearch()) == 0)
f0106184:	85 c0                	test   %eax,%eax
f0106186:	0f 84 35 02 00 00    	je     f01063c1 <mp_init+0x296>
	if (mp->physaddr == 0 || mp->type != 0) {
f010618c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010618f:	8b 58 04             	mov    0x4(%eax),%ebx
f0106192:	85 db                	test   %ebx,%ebx
f0106194:	0f 84 97 00 00 00    	je     f0106231 <mp_init+0x106>
f010619a:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f010619e:	0f 85 8d 00 00 00    	jne    f0106231 <mp_init+0x106>
f01061a4:	89 d8                	mov    %ebx,%eax
f01061a6:	c1 e8 0c             	shr    $0xc,%eax
f01061a9:	3b 05 88 0e 33 f0    	cmp    0xf0330e88,%eax
f01061af:	0f 83 91 00 00 00    	jae    f0106246 <mp_init+0x11b>
	return (void *)(pa + KERNBASE);
f01061b5:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
f01061bb:	89 de                	mov    %ebx,%esi
	if (memcmp(conf, "PCMP", 4) != 0) {
f01061bd:	83 ec 04             	sub    $0x4,%esp
f01061c0:	6a 04                	push   $0x4
f01061c2:	68 b2 87 10 f0       	push   $0xf01087b2
f01061c7:	53                   	push   %ebx
f01061c8:	e8 0b fd ff ff       	call   f0105ed8 <memcmp>
f01061cd:	83 c4 10             	add    $0x10,%esp
f01061d0:	85 c0                	test   %eax,%eax
f01061d2:	0f 85 83 00 00 00    	jne    f010625b <mp_init+0x130>
f01061d8:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
f01061dc:	01 df                	add    %ebx,%edi
	sum = 0;
f01061de:	89 c2                	mov    %eax,%edx
	for (i = 0; i < len; i++)
f01061e0:	39 fb                	cmp    %edi,%ebx
f01061e2:	0f 84 88 00 00 00    	je     f0106270 <mp_init+0x145>
		sum += ((uint8_t *)addr)[i];
f01061e8:	0f b6 0b             	movzbl (%ebx),%ecx
f01061eb:	01 ca                	add    %ecx,%edx
f01061ed:	83 c3 01             	add    $0x1,%ebx
f01061f0:	eb ee                	jmp    f01061e0 <mp_init+0xb5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01061f2:	68 00 04 00 00       	push   $0x400
f01061f7:	68 c4 6a 10 f0       	push   $0xf0106ac4
f01061fc:	6a 6f                	push   $0x6f
f01061fe:	68 9d 87 10 f0       	push   $0xf010879d
f0106203:	e8 38 9e ff ff       	call   f0100040 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0106208:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f010620f:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0106212:	2d 00 04 00 00       	sub    $0x400,%eax
f0106217:	ba 00 04 00 00       	mov    $0x400,%edx
f010621c:	e8 6e fe ff ff       	call   f010608f <mpsearch1>
f0106221:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106224:	85 c0                	test   %eax,%eax
f0106226:	0f 85 60 ff ff ff    	jne    f010618c <mp_init+0x61>
f010622c:	e9 41 ff ff ff       	jmp    f0106172 <mp_init+0x47>
		cprintf("SMP: Default configurations not implemented\n");
f0106231:	83 ec 0c             	sub    $0xc,%esp
f0106234:	68 10 86 10 f0       	push   $0xf0108610
f0106239:	e8 00 d9 ff ff       	call   f0103b3e <cprintf>
		return NULL;
f010623e:	83 c4 10             	add    $0x10,%esp
f0106241:	e9 7b 01 00 00       	jmp    f01063c1 <mp_init+0x296>
f0106246:	53                   	push   %ebx
f0106247:	68 c4 6a 10 f0       	push   $0xf0106ac4
f010624c:	68 90 00 00 00       	push   $0x90
f0106251:	68 9d 87 10 f0       	push   $0xf010879d
f0106256:	e8 e5 9d ff ff       	call   f0100040 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f010625b:	83 ec 0c             	sub    $0xc,%esp
f010625e:	68 40 86 10 f0       	push   $0xf0108640
f0106263:	e8 d6 d8 ff ff       	call   f0103b3e <cprintf>
		return NULL;
f0106268:	83 c4 10             	add    $0x10,%esp
f010626b:	e9 51 01 00 00       	jmp    f01063c1 <mp_init+0x296>
	if (sum(conf, conf->length) != 0) {
f0106270:	84 d2                	test   %dl,%dl
f0106272:	75 22                	jne    f0106296 <mp_init+0x16b>
	if (conf->version != 1 && conf->version != 4) {
f0106274:	0f b6 56 06          	movzbl 0x6(%esi),%edx
f0106278:	80 fa 01             	cmp    $0x1,%dl
f010627b:	74 05                	je     f0106282 <mp_init+0x157>
f010627d:	80 fa 04             	cmp    $0x4,%dl
f0106280:	75 29                	jne    f01062ab <mp_init+0x180>
f0106282:	0f b7 4e 28          	movzwl 0x28(%esi),%ecx
f0106286:	01 d9                	add    %ebx,%ecx
	for (i = 0; i < len; i++)
f0106288:	39 d9                	cmp    %ebx,%ecx
f010628a:	74 38                	je     f01062c4 <mp_init+0x199>
		sum += ((uint8_t *)addr)[i];
f010628c:	0f b6 13             	movzbl (%ebx),%edx
f010628f:	01 d0                	add    %edx,%eax
f0106291:	83 c3 01             	add    $0x1,%ebx
f0106294:	eb f2                	jmp    f0106288 <mp_init+0x15d>
		cprintf("SMP: Bad MP configuration checksum\n");
f0106296:	83 ec 0c             	sub    $0xc,%esp
f0106299:	68 74 86 10 f0       	push   $0xf0108674
f010629e:	e8 9b d8 ff ff       	call   f0103b3e <cprintf>
		return NULL;
f01062a3:	83 c4 10             	add    $0x10,%esp
f01062a6:	e9 16 01 00 00       	jmp    f01063c1 <mp_init+0x296>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01062ab:	83 ec 08             	sub    $0x8,%esp
f01062ae:	0f b6 d2             	movzbl %dl,%edx
f01062b1:	52                   	push   %edx
f01062b2:	68 98 86 10 f0       	push   $0xf0108698
f01062b7:	e8 82 d8 ff ff       	call   f0103b3e <cprintf>
		return NULL;
f01062bc:	83 c4 10             	add    $0x10,%esp
f01062bf:	e9 fd 00 00 00       	jmp    f01063c1 <mp_init+0x296>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01062c4:	02 46 2a             	add    0x2a(%esi),%al
f01062c7:	75 1c                	jne    f01062e5 <mp_init+0x1ba>
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
f01062c9:	c7 05 00 10 33 f0 01 	movl   $0x1,0xf0331000
f01062d0:	00 00 00 
	lapicaddr = conf->lapicaddr;
f01062d3:	8b 46 24             	mov    0x24(%esi),%eax
f01062d6:	a3 00 20 37 f0       	mov    %eax,0xf0372000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01062db:	8d 7e 2c             	lea    0x2c(%esi),%edi
f01062de:	bb 00 00 00 00       	mov    $0x0,%ebx
f01062e3:	eb 4d                	jmp    f0106332 <mp_init+0x207>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f01062e5:	83 ec 0c             	sub    $0xc,%esp
f01062e8:	68 b8 86 10 f0       	push   $0xf01086b8
f01062ed:	e8 4c d8 ff ff       	call   f0103b3e <cprintf>
		return NULL;
f01062f2:	83 c4 10             	add    $0x10,%esp
f01062f5:	e9 c7 00 00 00       	jmp    f01063c1 <mp_init+0x296>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f01062fa:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f01062fe:	74 11                	je     f0106311 <mp_init+0x1e6>
				bootcpu = &cpus[ncpu];
f0106300:	6b 05 c4 13 33 f0 74 	imul   $0x74,0xf03313c4,%eax
f0106307:	05 20 10 33 f0       	add    $0xf0331020,%eax
f010630c:	a3 c0 13 33 f0       	mov    %eax,0xf03313c0
			if (ncpu < NCPU) {
f0106311:	a1 c4 13 33 f0       	mov    0xf03313c4,%eax
f0106316:	83 f8 07             	cmp    $0x7,%eax
f0106319:	7f 33                	jg     f010634e <mp_init+0x223>
				cpus[ncpu].cpu_id = ncpu;
f010631b:	6b d0 74             	imul   $0x74,%eax,%edx
f010631e:	88 82 20 10 33 f0    	mov    %al,-0xfccefe0(%edx)
				ncpu++;
f0106324:	83 c0 01             	add    $0x1,%eax
f0106327:	a3 c4 13 33 f0       	mov    %eax,0xf03313c4
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f010632c:	83 c7 14             	add    $0x14,%edi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010632f:	83 c3 01             	add    $0x1,%ebx
f0106332:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f0106336:	39 d8                	cmp    %ebx,%eax
f0106338:	76 4f                	jbe    f0106389 <mp_init+0x25e>
		switch (*p) {
f010633a:	0f b6 07             	movzbl (%edi),%eax
f010633d:	84 c0                	test   %al,%al
f010633f:	74 b9                	je     f01062fa <mp_init+0x1cf>
f0106341:	8d 50 ff             	lea    -0x1(%eax),%edx
f0106344:	80 fa 03             	cmp    $0x3,%dl
f0106347:	77 1c                	ja     f0106365 <mp_init+0x23a>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106349:	83 c7 08             	add    $0x8,%edi
			continue;
f010634c:	eb e1                	jmp    f010632f <mp_init+0x204>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f010634e:	83 ec 08             	sub    $0x8,%esp
f0106351:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0106355:	50                   	push   %eax
f0106356:	68 e8 86 10 f0       	push   $0xf01086e8
f010635b:	e8 de d7 ff ff       	call   f0103b3e <cprintf>
f0106360:	83 c4 10             	add    $0x10,%esp
f0106363:	eb c7                	jmp    f010632c <mp_init+0x201>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0106365:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f0106368:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f010636b:	50                   	push   %eax
f010636c:	68 10 87 10 f0       	push   $0xf0108710
f0106371:	e8 c8 d7 ff ff       	call   f0103b3e <cprintf>
			ismp = 0;
f0106376:	c7 05 00 10 33 f0 00 	movl   $0x0,0xf0331000
f010637d:	00 00 00 
			i = conf->entry;
f0106380:	0f b7 5e 22          	movzwl 0x22(%esi),%ebx
f0106384:	83 c4 10             	add    $0x10,%esp
f0106387:	eb a6                	jmp    f010632f <mp_init+0x204>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0106389:	a1 c0 13 33 f0       	mov    0xf03313c0,%eax
f010638e:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0106395:	83 3d 00 10 33 f0 00 	cmpl   $0x0,0xf0331000
f010639c:	74 2b                	je     f01063c9 <mp_init+0x29e>
		ncpu = 1;
		lapicaddr = 0;
		cprintf("SMP: configuration not found, SMP disabled\n");
		return;
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f010639e:	83 ec 04             	sub    $0x4,%esp
f01063a1:	ff 35 c4 13 33 f0    	pushl  0xf03313c4
f01063a7:	0f b6 00             	movzbl (%eax),%eax
f01063aa:	50                   	push   %eax
f01063ab:	68 b7 87 10 f0       	push   $0xf01087b7
f01063b0:	e8 89 d7 ff ff       	call   f0103b3e <cprintf>

	if (mp->imcrp) {
f01063b5:	83 c4 10             	add    $0x10,%esp
f01063b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01063bb:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01063bf:	75 2e                	jne    f01063ef <mp_init+0x2c4>
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f01063c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01063c4:	5b                   	pop    %ebx
f01063c5:	5e                   	pop    %esi
f01063c6:	5f                   	pop    %edi
f01063c7:	5d                   	pop    %ebp
f01063c8:	c3                   	ret    
		ncpu = 1;
f01063c9:	c7 05 c4 13 33 f0 01 	movl   $0x1,0xf03313c4
f01063d0:	00 00 00 
		lapicaddr = 0;
f01063d3:	c7 05 00 20 37 f0 00 	movl   $0x0,0xf0372000
f01063da:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f01063dd:	83 ec 0c             	sub    $0xc,%esp
f01063e0:	68 30 87 10 f0       	push   $0xf0108730
f01063e5:	e8 54 d7 ff ff       	call   f0103b3e <cprintf>
		return;
f01063ea:	83 c4 10             	add    $0x10,%esp
f01063ed:	eb d2                	jmp    f01063c1 <mp_init+0x296>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01063ef:	83 ec 0c             	sub    $0xc,%esp
f01063f2:	68 5c 87 10 f0       	push   $0xf010875c
f01063f7:	e8 42 d7 ff ff       	call   f0103b3e <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01063fc:	b8 70 00 00 00       	mov    $0x70,%eax
f0106401:	ba 22 00 00 00       	mov    $0x22,%edx
f0106406:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0106407:	ba 23 00 00 00       	mov    $0x23,%edx
f010640c:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f010640d:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106410:	ee                   	out    %al,(%dx)
}
f0106411:	83 c4 10             	add    $0x10,%esp
f0106414:	eb ab                	jmp    f01063c1 <mp_init+0x296>

f0106416 <lapicw>:
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
	lapic[index] = value;
f0106416:	8b 0d 04 20 37 f0    	mov    0xf0372004,%ecx
f010641c:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f010641f:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106421:	a1 04 20 37 f0       	mov    0xf0372004,%eax
f0106426:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106429:	c3                   	ret    

f010642a <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f010642a:	f3 0f 1e fb          	endbr32 
	if (lapic)
f010642e:	8b 15 04 20 37 f0    	mov    0xf0372004,%edx
		return lapic[ID] >> 24;
	return 0;
f0106434:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lapic)
f0106439:	85 d2                	test   %edx,%edx
f010643b:	74 06                	je     f0106443 <cpunum+0x19>
		return lapic[ID] >> 24;
f010643d:	8b 42 20             	mov    0x20(%edx),%eax
f0106440:	c1 e8 18             	shr    $0x18,%eax
}
f0106443:	c3                   	ret    

f0106444 <lapic_init>:
{
f0106444:	f3 0f 1e fb          	endbr32 
	if (!lapicaddr)
f0106448:	a1 00 20 37 f0       	mov    0xf0372000,%eax
f010644d:	85 c0                	test   %eax,%eax
f010644f:	75 01                	jne    f0106452 <lapic_init+0xe>
f0106451:	c3                   	ret    
{
f0106452:	55                   	push   %ebp
f0106453:	89 e5                	mov    %esp,%ebp
f0106455:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f0106458:	68 00 10 00 00       	push   $0x1000
f010645d:	50                   	push   %eax
f010645e:	e8 e3 ae ff ff       	call   f0101346 <mmio_map_region>
f0106463:	a3 04 20 37 f0       	mov    %eax,0xf0372004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0106468:	ba 27 01 00 00       	mov    $0x127,%edx
f010646d:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106472:	e8 9f ff ff ff       	call   f0106416 <lapicw>
	lapicw(TDCR, X1);
f0106477:	ba 0b 00 00 00       	mov    $0xb,%edx
f010647c:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0106481:	e8 90 ff ff ff       	call   f0106416 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0106486:	ba 20 00 02 00       	mov    $0x20020,%edx
f010648b:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0106490:	e8 81 ff ff ff       	call   f0106416 <lapicw>
	lapicw(TICR, 10000000); 
f0106495:	ba 80 96 98 00       	mov    $0x989680,%edx
f010649a:	b8 e0 00 00 00       	mov    $0xe0,%eax
f010649f:	e8 72 ff ff ff       	call   f0106416 <lapicw>
	if (thiscpu != bootcpu)
f01064a4:	e8 81 ff ff ff       	call   f010642a <cpunum>
f01064a9:	6b c0 74             	imul   $0x74,%eax,%eax
f01064ac:	05 20 10 33 f0       	add    $0xf0331020,%eax
f01064b1:	83 c4 10             	add    $0x10,%esp
f01064b4:	39 05 c0 13 33 f0    	cmp    %eax,0xf03313c0
f01064ba:	74 0f                	je     f01064cb <lapic_init+0x87>
		lapicw(LINT0, MASKED);
f01064bc:	ba 00 00 01 00       	mov    $0x10000,%edx
f01064c1:	b8 d4 00 00 00       	mov    $0xd4,%eax
f01064c6:	e8 4b ff ff ff       	call   f0106416 <lapicw>
	lapicw(LINT1, MASKED);
f01064cb:	ba 00 00 01 00       	mov    $0x10000,%edx
f01064d0:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01064d5:	e8 3c ff ff ff       	call   f0106416 <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01064da:	a1 04 20 37 f0       	mov    0xf0372004,%eax
f01064df:	8b 40 30             	mov    0x30(%eax),%eax
f01064e2:	c1 e8 10             	shr    $0x10,%eax
f01064e5:	a8 fc                	test   $0xfc,%al
f01064e7:	75 7c                	jne    f0106565 <lapic_init+0x121>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01064e9:	ba 33 00 00 00       	mov    $0x33,%edx
f01064ee:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01064f3:	e8 1e ff ff ff       	call   f0106416 <lapicw>
	lapicw(ESR, 0);
f01064f8:	ba 00 00 00 00       	mov    $0x0,%edx
f01064fd:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106502:	e8 0f ff ff ff       	call   f0106416 <lapicw>
	lapicw(ESR, 0);
f0106507:	ba 00 00 00 00       	mov    $0x0,%edx
f010650c:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106511:	e8 00 ff ff ff       	call   f0106416 <lapicw>
	lapicw(EOI, 0);
f0106516:	ba 00 00 00 00       	mov    $0x0,%edx
f010651b:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106520:	e8 f1 fe ff ff       	call   f0106416 <lapicw>
	lapicw(ICRHI, 0);
f0106525:	ba 00 00 00 00       	mov    $0x0,%edx
f010652a:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010652f:	e8 e2 fe ff ff       	call   f0106416 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0106534:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106539:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010653e:	e8 d3 fe ff ff       	call   f0106416 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0106543:	8b 15 04 20 37 f0    	mov    0xf0372004,%edx
f0106549:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010654f:	f6 c4 10             	test   $0x10,%ah
f0106552:	75 f5                	jne    f0106549 <lapic_init+0x105>
	lapicw(TPR, 0);
f0106554:	ba 00 00 00 00       	mov    $0x0,%edx
f0106559:	b8 20 00 00 00       	mov    $0x20,%eax
f010655e:	e8 b3 fe ff ff       	call   f0106416 <lapicw>
}
f0106563:	c9                   	leave  
f0106564:	c3                   	ret    
		lapicw(PCINT, MASKED);
f0106565:	ba 00 00 01 00       	mov    $0x10000,%edx
f010656a:	b8 d0 00 00 00       	mov    $0xd0,%eax
f010656f:	e8 a2 fe ff ff       	call   f0106416 <lapicw>
f0106574:	e9 70 ff ff ff       	jmp    f01064e9 <lapic_init+0xa5>

f0106579 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0106579:	f3 0f 1e fb          	endbr32 
	if (lapic)
f010657d:	83 3d 04 20 37 f0 00 	cmpl   $0x0,0xf0372004
f0106584:	74 17                	je     f010659d <lapic_eoi+0x24>
{
f0106586:	55                   	push   %ebp
f0106587:	89 e5                	mov    %esp,%ebp
f0106589:	83 ec 08             	sub    $0x8,%esp
		lapicw(EOI, 0);
f010658c:	ba 00 00 00 00       	mov    $0x0,%edx
f0106591:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106596:	e8 7b fe ff ff       	call   f0106416 <lapicw>
}
f010659b:	c9                   	leave  
f010659c:	c3                   	ret    
f010659d:	c3                   	ret    

f010659e <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f010659e:	f3 0f 1e fb          	endbr32 
f01065a2:	55                   	push   %ebp
f01065a3:	89 e5                	mov    %esp,%ebp
f01065a5:	56                   	push   %esi
f01065a6:	53                   	push   %ebx
f01065a7:	8b 75 08             	mov    0x8(%ebp),%esi
f01065aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01065ad:	b8 0f 00 00 00       	mov    $0xf,%eax
f01065b2:	ba 70 00 00 00       	mov    $0x70,%edx
f01065b7:	ee                   	out    %al,(%dx)
f01065b8:	b8 0a 00 00 00       	mov    $0xa,%eax
f01065bd:	ba 71 00 00 00       	mov    $0x71,%edx
f01065c2:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f01065c3:	83 3d 88 0e 33 f0 00 	cmpl   $0x0,0xf0330e88
f01065ca:	74 7e                	je     f010664a <lapic_startap+0xac>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01065cc:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01065d3:	00 00 
	wrv[1] = addr >> 4;
f01065d5:	89 d8                	mov    %ebx,%eax
f01065d7:	c1 e8 04             	shr    $0x4,%eax
f01065da:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01065e0:	c1 e6 18             	shl    $0x18,%esi
f01065e3:	89 f2                	mov    %esi,%edx
f01065e5:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01065ea:	e8 27 fe ff ff       	call   f0106416 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01065ef:	ba 00 c5 00 00       	mov    $0xc500,%edx
f01065f4:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01065f9:	e8 18 fe ff ff       	call   f0106416 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01065fe:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106603:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106608:	e8 09 fe ff ff       	call   f0106416 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010660d:	c1 eb 0c             	shr    $0xc,%ebx
f0106610:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f0106613:	89 f2                	mov    %esi,%edx
f0106615:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010661a:	e8 f7 fd ff ff       	call   f0106416 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010661f:	89 da                	mov    %ebx,%edx
f0106621:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106626:	e8 eb fd ff ff       	call   f0106416 <lapicw>
		lapicw(ICRHI, apicid << 24);
f010662b:	89 f2                	mov    %esi,%edx
f010662d:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106632:	e8 df fd ff ff       	call   f0106416 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106637:	89 da                	mov    %ebx,%edx
f0106639:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010663e:	e8 d3 fd ff ff       	call   f0106416 <lapicw>
		microdelay(200);
	}
}
f0106643:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106646:	5b                   	pop    %ebx
f0106647:	5e                   	pop    %esi
f0106648:	5d                   	pop    %ebp
f0106649:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010664a:	68 67 04 00 00       	push   $0x467
f010664f:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0106654:	68 98 00 00 00       	push   $0x98
f0106659:	68 d4 87 10 f0       	push   $0xf01087d4
f010665e:	e8 dd 99 ff ff       	call   f0100040 <_panic>

f0106663 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106663:	f3 0f 1e fb          	endbr32 
f0106667:	55                   	push   %ebp
f0106668:	89 e5                	mov    %esp,%ebp
f010666a:	83 ec 08             	sub    $0x8,%esp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f010666d:	8b 55 08             	mov    0x8(%ebp),%edx
f0106670:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106676:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010667b:	e8 96 fd ff ff       	call   f0106416 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106680:	8b 15 04 20 37 f0    	mov    0xf0372004,%edx
f0106686:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010668c:	f6 c4 10             	test   $0x10,%ah
f010668f:	75 f5                	jne    f0106686 <lapic_ipi+0x23>
		;
}
f0106691:	c9                   	leave  
f0106692:	c3                   	ret    

f0106693 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106693:	f3 0f 1e fb          	endbr32 
f0106697:	55                   	push   %ebp
f0106698:	89 e5                	mov    %esp,%ebp
f010669a:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f010669d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01066a3:	8b 55 0c             	mov    0xc(%ebp),%edx
f01066a6:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01066a9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01066b0:	5d                   	pop    %ebp
f01066b1:	c3                   	ret    

f01066b2 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01066b2:	f3 0f 1e fb          	endbr32 
f01066b6:	55                   	push   %ebp
f01066b7:	89 e5                	mov    %esp,%ebp
f01066b9:	56                   	push   %esi
f01066ba:	53                   	push   %ebx
f01066bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f01066be:	83 3b 00             	cmpl   $0x0,(%ebx)
f01066c1:	75 07                	jne    f01066ca <spin_lock+0x18>
	asm volatile("lock; xchgl %0, %1"
f01066c3:	ba 01 00 00 00       	mov    $0x1,%edx
f01066c8:	eb 34                	jmp    f01066fe <spin_lock+0x4c>
f01066ca:	8b 73 08             	mov    0x8(%ebx),%esi
f01066cd:	e8 58 fd ff ff       	call   f010642a <cpunum>
f01066d2:	6b c0 74             	imul   $0x74,%eax,%eax
f01066d5:	05 20 10 33 f0       	add    $0xf0331020,%eax
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01066da:	39 c6                	cmp    %eax,%esi
f01066dc:	75 e5                	jne    f01066c3 <spin_lock+0x11>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01066de:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01066e1:	e8 44 fd ff ff       	call   f010642a <cpunum>
f01066e6:	83 ec 0c             	sub    $0xc,%esp
f01066e9:	53                   	push   %ebx
f01066ea:	50                   	push   %eax
f01066eb:	68 e4 87 10 f0       	push   $0xf01087e4
f01066f0:	6a 41                	push   $0x41
f01066f2:	68 46 88 10 f0       	push   $0xf0108846
f01066f7:	e8 44 99 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f01066fc:	f3 90                	pause  
f01066fe:	89 d0                	mov    %edx,%eax
f0106700:	f0 87 03             	lock xchg %eax,(%ebx)
	while (xchg(&lk->locked, 1) != 0)
f0106703:	85 c0                	test   %eax,%eax
f0106705:	75 f5                	jne    f01066fc <spin_lock+0x4a>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106707:	e8 1e fd ff ff       	call   f010642a <cpunum>
f010670c:	6b c0 74             	imul   $0x74,%eax,%eax
f010670f:	05 20 10 33 f0       	add    $0xf0331020,%eax
f0106714:	89 43 08             	mov    %eax,0x8(%ebx)
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0106717:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f0106719:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f010671e:	83 f8 09             	cmp    $0x9,%eax
f0106721:	7f 21                	jg     f0106744 <spin_lock+0x92>
f0106723:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106729:	76 19                	jbe    f0106744 <spin_lock+0x92>
		pcs[i] = ebp[1];          // saved %eip
f010672b:	8b 4a 04             	mov    0x4(%edx),%ecx
f010672e:	89 4c 83 0c          	mov    %ecx,0xc(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106732:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f0106734:	83 c0 01             	add    $0x1,%eax
f0106737:	eb e5                	jmp    f010671e <spin_lock+0x6c>
		pcs[i] = 0;
f0106739:	c7 44 83 0c 00 00 00 	movl   $0x0,0xc(%ebx,%eax,4)
f0106740:	00 
	for (; i < 10; i++)
f0106741:	83 c0 01             	add    $0x1,%eax
f0106744:	83 f8 09             	cmp    $0x9,%eax
f0106747:	7e f0                	jle    f0106739 <spin_lock+0x87>
	get_caller_pcs(lk->pcs);
#endif
}
f0106749:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010674c:	5b                   	pop    %ebx
f010674d:	5e                   	pop    %esi
f010674e:	5d                   	pop    %ebp
f010674f:	c3                   	ret    

f0106750 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106750:	f3 0f 1e fb          	endbr32 
f0106754:	55                   	push   %ebp
f0106755:	89 e5                	mov    %esp,%ebp
f0106757:	57                   	push   %edi
f0106758:	56                   	push   %esi
f0106759:	53                   	push   %ebx
f010675a:	83 ec 4c             	sub    $0x4c,%esp
f010675d:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f0106760:	83 3e 00             	cmpl   $0x0,(%esi)
f0106763:	75 35                	jne    f010679a <spin_unlock+0x4a>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106765:	83 ec 04             	sub    $0x4,%esp
f0106768:	6a 28                	push   $0x28
f010676a:	8d 46 0c             	lea    0xc(%esi),%eax
f010676d:	50                   	push   %eax
f010676e:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106771:	53                   	push   %ebx
f0106772:	e8 e1 f6 ff ff       	call   f0105e58 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106777:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f010677a:	0f b6 38             	movzbl (%eax),%edi
f010677d:	8b 76 04             	mov    0x4(%esi),%esi
f0106780:	e8 a5 fc ff ff       	call   f010642a <cpunum>
f0106785:	57                   	push   %edi
f0106786:	56                   	push   %esi
f0106787:	50                   	push   %eax
f0106788:	68 10 88 10 f0       	push   $0xf0108810
f010678d:	e8 ac d3 ff ff       	call   f0103b3e <cprintf>
f0106792:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106795:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0106798:	eb 4e                	jmp    f01067e8 <spin_unlock+0x98>
	return lock->locked && lock->cpu == thiscpu;
f010679a:	8b 5e 08             	mov    0x8(%esi),%ebx
f010679d:	e8 88 fc ff ff       	call   f010642a <cpunum>
f01067a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01067a5:	05 20 10 33 f0       	add    $0xf0331020,%eax
	if (!holding(lk)) {
f01067aa:	39 c3                	cmp    %eax,%ebx
f01067ac:	75 b7                	jne    f0106765 <spin_unlock+0x15>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f01067ae:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f01067b5:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f01067bc:	b8 00 00 00 00       	mov    $0x0,%eax
f01067c1:	f0 87 06             	lock xchg %eax,(%esi)
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
    //lk->locked = 0;
}
f01067c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01067c7:	5b                   	pop    %ebx
f01067c8:	5e                   	pop    %esi
f01067c9:	5f                   	pop    %edi
f01067ca:	5d                   	pop    %ebp
f01067cb:	c3                   	ret    
				cprintf("  %08x\n", pcs[i]);
f01067cc:	83 ec 08             	sub    $0x8,%esp
f01067cf:	ff 36                	pushl  (%esi)
f01067d1:	68 6d 88 10 f0       	push   $0xf010886d
f01067d6:	e8 63 d3 ff ff       	call   f0103b3e <cprintf>
f01067db:	83 c4 10             	add    $0x10,%esp
f01067de:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f01067e1:	8d 45 e8             	lea    -0x18(%ebp),%eax
f01067e4:	39 c3                	cmp    %eax,%ebx
f01067e6:	74 40                	je     f0106828 <spin_unlock+0xd8>
f01067e8:	89 de                	mov    %ebx,%esi
f01067ea:	8b 03                	mov    (%ebx),%eax
f01067ec:	85 c0                	test   %eax,%eax
f01067ee:	74 38                	je     f0106828 <spin_unlock+0xd8>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01067f0:	83 ec 08             	sub    $0x8,%esp
f01067f3:	57                   	push   %edi
f01067f4:	50                   	push   %eax
f01067f5:	e8 d4 ea ff ff       	call   f01052ce <debuginfo_eip>
f01067fa:	83 c4 10             	add    $0x10,%esp
f01067fd:	85 c0                	test   %eax,%eax
f01067ff:	78 cb                	js     f01067cc <spin_unlock+0x7c>
					pcs[i] - info.eip_fn_addr);
f0106801:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106803:	83 ec 04             	sub    $0x4,%esp
f0106806:	89 c2                	mov    %eax,%edx
f0106808:	2b 55 b8             	sub    -0x48(%ebp),%edx
f010680b:	52                   	push   %edx
f010680c:	ff 75 b0             	pushl  -0x50(%ebp)
f010680f:	ff 75 b4             	pushl  -0x4c(%ebp)
f0106812:	ff 75 ac             	pushl  -0x54(%ebp)
f0106815:	ff 75 a8             	pushl  -0x58(%ebp)
f0106818:	50                   	push   %eax
f0106819:	68 56 88 10 f0       	push   $0xf0108856
f010681e:	e8 1b d3 ff ff       	call   f0103b3e <cprintf>
f0106823:	83 c4 20             	add    $0x20,%esp
f0106826:	eb b6                	jmp    f01067de <spin_unlock+0x8e>
		panic("spin_unlock");
f0106828:	83 ec 04             	sub    $0x4,%esp
f010682b:	68 75 88 10 f0       	push   $0xf0108875
f0106830:	6a 67                	push   $0x67
f0106832:	68 46 88 10 f0       	push   $0xf0108846
f0106837:	e8 04 98 ff ff       	call   f0100040 <_panic>
f010683c:	66 90                	xchg   %ax,%ax
f010683e:	66 90                	xchg   %ax,%ax

f0106840 <__udivdi3>:
f0106840:	f3 0f 1e fb          	endbr32 
f0106844:	55                   	push   %ebp
f0106845:	57                   	push   %edi
f0106846:	56                   	push   %esi
f0106847:	53                   	push   %ebx
f0106848:	83 ec 1c             	sub    $0x1c,%esp
f010684b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010684f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0106853:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106857:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f010685b:	85 d2                	test   %edx,%edx
f010685d:	75 19                	jne    f0106878 <__udivdi3+0x38>
f010685f:	39 f3                	cmp    %esi,%ebx
f0106861:	76 4d                	jbe    f01068b0 <__udivdi3+0x70>
f0106863:	31 ff                	xor    %edi,%edi
f0106865:	89 e8                	mov    %ebp,%eax
f0106867:	89 f2                	mov    %esi,%edx
f0106869:	f7 f3                	div    %ebx
f010686b:	89 fa                	mov    %edi,%edx
f010686d:	83 c4 1c             	add    $0x1c,%esp
f0106870:	5b                   	pop    %ebx
f0106871:	5e                   	pop    %esi
f0106872:	5f                   	pop    %edi
f0106873:	5d                   	pop    %ebp
f0106874:	c3                   	ret    
f0106875:	8d 76 00             	lea    0x0(%esi),%esi
f0106878:	39 f2                	cmp    %esi,%edx
f010687a:	76 14                	jbe    f0106890 <__udivdi3+0x50>
f010687c:	31 ff                	xor    %edi,%edi
f010687e:	31 c0                	xor    %eax,%eax
f0106880:	89 fa                	mov    %edi,%edx
f0106882:	83 c4 1c             	add    $0x1c,%esp
f0106885:	5b                   	pop    %ebx
f0106886:	5e                   	pop    %esi
f0106887:	5f                   	pop    %edi
f0106888:	5d                   	pop    %ebp
f0106889:	c3                   	ret    
f010688a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106890:	0f bd fa             	bsr    %edx,%edi
f0106893:	83 f7 1f             	xor    $0x1f,%edi
f0106896:	75 48                	jne    f01068e0 <__udivdi3+0xa0>
f0106898:	39 f2                	cmp    %esi,%edx
f010689a:	72 06                	jb     f01068a2 <__udivdi3+0x62>
f010689c:	31 c0                	xor    %eax,%eax
f010689e:	39 eb                	cmp    %ebp,%ebx
f01068a0:	77 de                	ja     f0106880 <__udivdi3+0x40>
f01068a2:	b8 01 00 00 00       	mov    $0x1,%eax
f01068a7:	eb d7                	jmp    f0106880 <__udivdi3+0x40>
f01068a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01068b0:	89 d9                	mov    %ebx,%ecx
f01068b2:	85 db                	test   %ebx,%ebx
f01068b4:	75 0b                	jne    f01068c1 <__udivdi3+0x81>
f01068b6:	b8 01 00 00 00       	mov    $0x1,%eax
f01068bb:	31 d2                	xor    %edx,%edx
f01068bd:	f7 f3                	div    %ebx
f01068bf:	89 c1                	mov    %eax,%ecx
f01068c1:	31 d2                	xor    %edx,%edx
f01068c3:	89 f0                	mov    %esi,%eax
f01068c5:	f7 f1                	div    %ecx
f01068c7:	89 c6                	mov    %eax,%esi
f01068c9:	89 e8                	mov    %ebp,%eax
f01068cb:	89 f7                	mov    %esi,%edi
f01068cd:	f7 f1                	div    %ecx
f01068cf:	89 fa                	mov    %edi,%edx
f01068d1:	83 c4 1c             	add    $0x1c,%esp
f01068d4:	5b                   	pop    %ebx
f01068d5:	5e                   	pop    %esi
f01068d6:	5f                   	pop    %edi
f01068d7:	5d                   	pop    %ebp
f01068d8:	c3                   	ret    
f01068d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01068e0:	89 f9                	mov    %edi,%ecx
f01068e2:	b8 20 00 00 00       	mov    $0x20,%eax
f01068e7:	29 f8                	sub    %edi,%eax
f01068e9:	d3 e2                	shl    %cl,%edx
f01068eb:	89 54 24 08          	mov    %edx,0x8(%esp)
f01068ef:	89 c1                	mov    %eax,%ecx
f01068f1:	89 da                	mov    %ebx,%edx
f01068f3:	d3 ea                	shr    %cl,%edx
f01068f5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01068f9:	09 d1                	or     %edx,%ecx
f01068fb:	89 f2                	mov    %esi,%edx
f01068fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106901:	89 f9                	mov    %edi,%ecx
f0106903:	d3 e3                	shl    %cl,%ebx
f0106905:	89 c1                	mov    %eax,%ecx
f0106907:	d3 ea                	shr    %cl,%edx
f0106909:	89 f9                	mov    %edi,%ecx
f010690b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010690f:	89 eb                	mov    %ebp,%ebx
f0106911:	d3 e6                	shl    %cl,%esi
f0106913:	89 c1                	mov    %eax,%ecx
f0106915:	d3 eb                	shr    %cl,%ebx
f0106917:	09 de                	or     %ebx,%esi
f0106919:	89 f0                	mov    %esi,%eax
f010691b:	f7 74 24 08          	divl   0x8(%esp)
f010691f:	89 d6                	mov    %edx,%esi
f0106921:	89 c3                	mov    %eax,%ebx
f0106923:	f7 64 24 0c          	mull   0xc(%esp)
f0106927:	39 d6                	cmp    %edx,%esi
f0106929:	72 15                	jb     f0106940 <__udivdi3+0x100>
f010692b:	89 f9                	mov    %edi,%ecx
f010692d:	d3 e5                	shl    %cl,%ebp
f010692f:	39 c5                	cmp    %eax,%ebp
f0106931:	73 04                	jae    f0106937 <__udivdi3+0xf7>
f0106933:	39 d6                	cmp    %edx,%esi
f0106935:	74 09                	je     f0106940 <__udivdi3+0x100>
f0106937:	89 d8                	mov    %ebx,%eax
f0106939:	31 ff                	xor    %edi,%edi
f010693b:	e9 40 ff ff ff       	jmp    f0106880 <__udivdi3+0x40>
f0106940:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0106943:	31 ff                	xor    %edi,%edi
f0106945:	e9 36 ff ff ff       	jmp    f0106880 <__udivdi3+0x40>
f010694a:	66 90                	xchg   %ax,%ax
f010694c:	66 90                	xchg   %ax,%ax
f010694e:	66 90                	xchg   %ax,%ax

f0106950 <__umoddi3>:
f0106950:	f3 0f 1e fb          	endbr32 
f0106954:	55                   	push   %ebp
f0106955:	57                   	push   %edi
f0106956:	56                   	push   %esi
f0106957:	53                   	push   %ebx
f0106958:	83 ec 1c             	sub    $0x1c,%esp
f010695b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010695f:	8b 74 24 30          	mov    0x30(%esp),%esi
f0106963:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0106967:	8b 7c 24 38          	mov    0x38(%esp),%edi
f010696b:	85 c0                	test   %eax,%eax
f010696d:	75 19                	jne    f0106988 <__umoddi3+0x38>
f010696f:	39 df                	cmp    %ebx,%edi
f0106971:	76 5d                	jbe    f01069d0 <__umoddi3+0x80>
f0106973:	89 f0                	mov    %esi,%eax
f0106975:	89 da                	mov    %ebx,%edx
f0106977:	f7 f7                	div    %edi
f0106979:	89 d0                	mov    %edx,%eax
f010697b:	31 d2                	xor    %edx,%edx
f010697d:	83 c4 1c             	add    $0x1c,%esp
f0106980:	5b                   	pop    %ebx
f0106981:	5e                   	pop    %esi
f0106982:	5f                   	pop    %edi
f0106983:	5d                   	pop    %ebp
f0106984:	c3                   	ret    
f0106985:	8d 76 00             	lea    0x0(%esi),%esi
f0106988:	89 f2                	mov    %esi,%edx
f010698a:	39 d8                	cmp    %ebx,%eax
f010698c:	76 12                	jbe    f01069a0 <__umoddi3+0x50>
f010698e:	89 f0                	mov    %esi,%eax
f0106990:	89 da                	mov    %ebx,%edx
f0106992:	83 c4 1c             	add    $0x1c,%esp
f0106995:	5b                   	pop    %ebx
f0106996:	5e                   	pop    %esi
f0106997:	5f                   	pop    %edi
f0106998:	5d                   	pop    %ebp
f0106999:	c3                   	ret    
f010699a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01069a0:	0f bd e8             	bsr    %eax,%ebp
f01069a3:	83 f5 1f             	xor    $0x1f,%ebp
f01069a6:	75 50                	jne    f01069f8 <__umoddi3+0xa8>
f01069a8:	39 d8                	cmp    %ebx,%eax
f01069aa:	0f 82 e0 00 00 00    	jb     f0106a90 <__umoddi3+0x140>
f01069b0:	89 d9                	mov    %ebx,%ecx
f01069b2:	39 f7                	cmp    %esi,%edi
f01069b4:	0f 86 d6 00 00 00    	jbe    f0106a90 <__umoddi3+0x140>
f01069ba:	89 d0                	mov    %edx,%eax
f01069bc:	89 ca                	mov    %ecx,%edx
f01069be:	83 c4 1c             	add    $0x1c,%esp
f01069c1:	5b                   	pop    %ebx
f01069c2:	5e                   	pop    %esi
f01069c3:	5f                   	pop    %edi
f01069c4:	5d                   	pop    %ebp
f01069c5:	c3                   	ret    
f01069c6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01069cd:	8d 76 00             	lea    0x0(%esi),%esi
f01069d0:	89 fd                	mov    %edi,%ebp
f01069d2:	85 ff                	test   %edi,%edi
f01069d4:	75 0b                	jne    f01069e1 <__umoddi3+0x91>
f01069d6:	b8 01 00 00 00       	mov    $0x1,%eax
f01069db:	31 d2                	xor    %edx,%edx
f01069dd:	f7 f7                	div    %edi
f01069df:	89 c5                	mov    %eax,%ebp
f01069e1:	89 d8                	mov    %ebx,%eax
f01069e3:	31 d2                	xor    %edx,%edx
f01069e5:	f7 f5                	div    %ebp
f01069e7:	89 f0                	mov    %esi,%eax
f01069e9:	f7 f5                	div    %ebp
f01069eb:	89 d0                	mov    %edx,%eax
f01069ed:	31 d2                	xor    %edx,%edx
f01069ef:	eb 8c                	jmp    f010697d <__umoddi3+0x2d>
f01069f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01069f8:	89 e9                	mov    %ebp,%ecx
f01069fa:	ba 20 00 00 00       	mov    $0x20,%edx
f01069ff:	29 ea                	sub    %ebp,%edx
f0106a01:	d3 e0                	shl    %cl,%eax
f0106a03:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106a07:	89 d1                	mov    %edx,%ecx
f0106a09:	89 f8                	mov    %edi,%eax
f0106a0b:	d3 e8                	shr    %cl,%eax
f0106a0d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0106a11:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106a15:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106a19:	09 c1                	or     %eax,%ecx
f0106a1b:	89 d8                	mov    %ebx,%eax
f0106a1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106a21:	89 e9                	mov    %ebp,%ecx
f0106a23:	d3 e7                	shl    %cl,%edi
f0106a25:	89 d1                	mov    %edx,%ecx
f0106a27:	d3 e8                	shr    %cl,%eax
f0106a29:	89 e9                	mov    %ebp,%ecx
f0106a2b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106a2f:	d3 e3                	shl    %cl,%ebx
f0106a31:	89 c7                	mov    %eax,%edi
f0106a33:	89 d1                	mov    %edx,%ecx
f0106a35:	89 f0                	mov    %esi,%eax
f0106a37:	d3 e8                	shr    %cl,%eax
f0106a39:	89 e9                	mov    %ebp,%ecx
f0106a3b:	89 fa                	mov    %edi,%edx
f0106a3d:	d3 e6                	shl    %cl,%esi
f0106a3f:	09 d8                	or     %ebx,%eax
f0106a41:	f7 74 24 08          	divl   0x8(%esp)
f0106a45:	89 d1                	mov    %edx,%ecx
f0106a47:	89 f3                	mov    %esi,%ebx
f0106a49:	f7 64 24 0c          	mull   0xc(%esp)
f0106a4d:	89 c6                	mov    %eax,%esi
f0106a4f:	89 d7                	mov    %edx,%edi
f0106a51:	39 d1                	cmp    %edx,%ecx
f0106a53:	72 06                	jb     f0106a5b <__umoddi3+0x10b>
f0106a55:	75 10                	jne    f0106a67 <__umoddi3+0x117>
f0106a57:	39 c3                	cmp    %eax,%ebx
f0106a59:	73 0c                	jae    f0106a67 <__umoddi3+0x117>
f0106a5b:	2b 44 24 0c          	sub    0xc(%esp),%eax
f0106a5f:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0106a63:	89 d7                	mov    %edx,%edi
f0106a65:	89 c6                	mov    %eax,%esi
f0106a67:	89 ca                	mov    %ecx,%edx
f0106a69:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106a6e:	29 f3                	sub    %esi,%ebx
f0106a70:	19 fa                	sbb    %edi,%edx
f0106a72:	89 d0                	mov    %edx,%eax
f0106a74:	d3 e0                	shl    %cl,%eax
f0106a76:	89 e9                	mov    %ebp,%ecx
f0106a78:	d3 eb                	shr    %cl,%ebx
f0106a7a:	d3 ea                	shr    %cl,%edx
f0106a7c:	09 d8                	or     %ebx,%eax
f0106a7e:	83 c4 1c             	add    $0x1c,%esp
f0106a81:	5b                   	pop    %ebx
f0106a82:	5e                   	pop    %esi
f0106a83:	5f                   	pop    %edi
f0106a84:	5d                   	pop    %ebp
f0106a85:	c3                   	ret    
f0106a86:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106a8d:	8d 76 00             	lea    0x0(%esi),%esi
f0106a90:	29 fe                	sub    %edi,%esi
f0106a92:	19 c3                	sbb    %eax,%ebx
f0106a94:	89 f2                	mov    %esi,%edx
f0106a96:	89 d9                	mov    %ebx,%ecx
f0106a98:	e9 1d ff ff ff       	jmp    f01069ba <__umoddi3+0x6a>
