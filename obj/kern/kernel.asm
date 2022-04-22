
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
f010004c:	83 3d 80 fe 32 f0 00 	cmpl   $0x0,0xf032fe80
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
f0100064:	89 35 80 fe 32 f0    	mov    %esi,0xf032fe80
	asm volatile("cli; cld");
f010006a:	fa                   	cli    
f010006b:	fc                   	cld    
	va_start(ap, fmt);
f010006c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010006f:	e8 6e 63 00 00       	call   f01063e2 <cpunum>
f0100074:	ff 75 0c             	pushl  0xc(%ebp)
f0100077:	ff 75 08             	pushl  0x8(%ebp)
f010007a:	50                   	push   %eax
f010007b:	68 60 6a 10 f0       	push   $0xf0106a60
f0100080:	e8 b9 3a 00 00       	call   f0103b3e <cprintf>
	vcprintf(fmt, ap);
f0100085:	83 c4 08             	add    $0x8,%esp
f0100088:	53                   	push   %ebx
f0100089:	56                   	push   %esi
f010008a:	e8 85 3a 00 00       	call   f0103b14 <vcprintf>
	cprintf("\n");
f010008f:	c7 04 24 40 7c 10 f0 	movl   $0xf0107c40,(%esp)
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
f01000b8:	68 cc 6a 10 f0       	push   $0xf0106acc
f01000bd:	e8 7c 3a 00 00       	call   f0103b3e <cprintf>
	mem_init();
f01000c2:	e8 da 12 00 00       	call   f01013a1 <mem_init>
	env_init();
f01000c7:	e8 fa 31 00 00       	call   f01032c6 <env_init>
	trap_init();
f01000cc:	e8 67 3b 00 00       	call   f0103c38 <trap_init>
	mp_init();
f01000d1:	e8 0d 60 00 00       	call   f01060e3 <mp_init>
	lapic_init();
f01000d6:	e8 21 63 00 00       	call   f01063fc <lapic_init>
	pic_init();
f01000db:	e8 73 39 00 00       	call   f0103a53 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000e0:	c7 04 24 c0 43 12 f0 	movl   $0xf01243c0,(%esp)
f01000e7:	e8 7e 65 00 00       	call   f010666a <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000ec:	83 c4 10             	add    $0x10,%esp
f01000ef:	83 3d 88 fe 32 f0 07 	cmpl   $0x7,0xf032fe88
f01000f6:	76 27                	jbe    f010011f <i386_init+0x7f>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01000f8:	83 ec 04             	sub    $0x4,%esp
f01000fb:	b8 46 60 10 f0       	mov    $0xf0106046,%eax
f0100100:	2d cc 5f 10 f0       	sub    $0xf0105fcc,%eax
f0100105:	50                   	push   %eax
f0100106:	68 cc 5f 10 f0       	push   $0xf0105fcc
f010010b:	68 00 70 00 f0       	push   $0xf0007000
f0100110:	e8 fb 5c 00 00       	call   f0105e10 <memmove>
	for (c = cpus; c < cpus + ncpu; c++) {
f0100115:	83 c4 10             	add    $0x10,%esp
f0100118:	bb 20 00 33 f0       	mov    $0xf0330020,%ebx
f010011d:	eb 53                	jmp    f0100172 <i386_init+0xd2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010011f:	68 00 70 00 00       	push   $0x7000
f0100124:	68 84 6a 10 f0       	push   $0xf0106a84
f0100129:	6a 53                	push   $0x53
f010012b:	68 e9 6a 10 f0       	push   $0xf0106ae9
f0100130:	e8 0b ff ff ff       	call   f0100040 <_panic>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100135:	89 d8                	mov    %ebx,%eax
f0100137:	2d 20 00 33 f0       	sub    $0xf0330020,%eax
f010013c:	c1 f8 02             	sar    $0x2,%eax
f010013f:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100145:	c1 e0 0f             	shl    $0xf,%eax
f0100148:	8d 80 00 90 33 f0    	lea    -0xfcc7000(%eax),%eax
f010014e:	a3 84 fe 32 f0       	mov    %eax,0xf032fe84
		lapic_startap(c->cpu_id, PADDR(code));
f0100153:	83 ec 08             	sub    $0x8,%esp
f0100156:	68 00 70 00 00       	push   $0x7000
f010015b:	0f b6 03             	movzbl (%ebx),%eax
f010015e:	50                   	push   %eax
f010015f:	e8 f2 63 00 00       	call   f0106556 <lapic_startap>
		while(c->cpu_status != CPU_STARTED)
f0100164:	83 c4 10             	add    $0x10,%esp
f0100167:	8b 43 04             	mov    0x4(%ebx),%eax
f010016a:	83 f8 01             	cmp    $0x1,%eax
f010016d:	75 f8                	jne    f0100167 <i386_init+0xc7>
	for (c = cpus; c < cpus + ncpu; c++) {
f010016f:	83 c3 74             	add    $0x74,%ebx
f0100172:	6b 05 c4 03 33 f0 74 	imul   $0x74,0xf03303c4,%eax
f0100179:	05 20 00 33 f0       	add    $0xf0330020,%eax
f010017e:	39 c3                	cmp    %eax,%ebx
f0100180:	73 13                	jae    f0100195 <i386_init+0xf5>
		if (c == cpus + cpunum())  // We've started already.
f0100182:	e8 5b 62 00 00       	call   f01063e2 <cpunum>
f0100187:	6b c0 74             	imul   $0x74,%eax,%eax
f010018a:	05 20 00 33 f0       	add    $0xf0330020,%eax
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
f01001a9:	68 ec e3 25 f0       	push   $0xf025e3ec
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
f01001c7:	a1 8c fe 32 f0       	mov    0xf032fe8c,%eax
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
f01001db:	e8 02 62 00 00       	call   f01063e2 <cpunum>
f01001e0:	83 ec 08             	sub    $0x8,%esp
f01001e3:	50                   	push   %eax
f01001e4:	68 f5 6a 10 f0       	push   $0xf0106af5
f01001e9:	e8 50 39 00 00       	call   f0103b3e <cprintf>
	lapic_init();
f01001ee:	e8 09 62 00 00       	call   f01063fc <lapic_init>
	env_init_percpu();
f01001f3:	e8 9e 30 00 00       	call   f0103296 <env_init_percpu>
	trap_init_percpu();
f01001f8:	e8 59 39 00 00       	call   f0103b56 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01001fd:	e8 e0 61 00 00       	call   f01063e2 <cpunum>
f0100202:	6b d0 74             	imul   $0x74,%eax,%edx
f0100205:	83 c2 04             	add    $0x4,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100208:	b8 01 00 00 00       	mov    $0x1,%eax
f010020d:	f0 87 82 20 00 33 f0 	lock xchg %eax,-0xfccffe0(%edx)
f0100214:	c7 04 24 c0 43 12 f0 	movl   $0xf01243c0,(%esp)
f010021b:	e8 4a 64 00 00       	call   f010666a <spin_lock>
    sched_yield();
f0100220:	e8 f7 47 00 00       	call   f0104a1c <sched_yield>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100225:	50                   	push   %eax
f0100226:	68 a8 6a 10 f0       	push   $0xf0106aa8
f010022b:	6a 6a                	push   $0x6a
f010022d:	68 e9 6a 10 f0       	push   $0xf0106ae9
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
f010024b:	68 0b 6b 10 f0       	push   $0xf0106b0b
f0100250:	e8 e9 38 00 00       	call   f0103b3e <cprintf>
	vcprintf(fmt, ap);
f0100255:	83 c4 08             	add    $0x8,%esp
f0100258:	53                   	push   %ebx
f0100259:	ff 75 10             	pushl  0x10(%ebp)
f010025c:	e8 b3 38 00 00       	call   f0103b14 <vcprintf>
	cprintf("\n");
f0100261:	c7 04 24 40 7c 10 f0 	movl   $0xf0107c40,(%esp)
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
f01002a7:	8b 0d 24 f2 32 f0    	mov    0xf032f224,%ecx
f01002ad:	8d 51 01             	lea    0x1(%ecx),%edx
f01002b0:	88 81 20 f0 32 f0    	mov    %al,-0xfcd0fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002b6:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f01002bc:	b8 00 00 00 00       	mov    $0x0,%eax
f01002c1:	0f 44 d0             	cmove  %eax,%edx
f01002c4:	89 15 24 f2 32 f0    	mov    %edx,0xf032f224
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
f0100303:	8b 0d 00 f0 32 f0    	mov    0xf032f000,%ecx
f0100309:	f6 c1 40             	test   $0x40,%cl
f010030c:	74 0e                	je     f010031c <kbd_proc_data+0x4a>
		data |= 0x80;
f010030e:	83 c8 80             	or     $0xffffff80,%eax
f0100311:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100313:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100316:	89 0d 00 f0 32 f0    	mov    %ecx,0xf032f000
	shift |= shiftcode[data];
f010031c:	0f b6 d2             	movzbl %dl,%edx
f010031f:	0f b6 82 80 6c 10 f0 	movzbl -0xfef9380(%edx),%eax
f0100326:	0b 05 00 f0 32 f0    	or     0xf032f000,%eax
	shift ^= togglecode[data];
f010032c:	0f b6 8a 80 6b 10 f0 	movzbl -0xfef9480(%edx),%ecx
f0100333:	31 c8                	xor    %ecx,%eax
f0100335:	a3 00 f0 32 f0       	mov    %eax,0xf032f000
	c = charcode[shift & (CTL | SHIFT)][data];
f010033a:	89 c1                	mov    %eax,%ecx
f010033c:	83 e1 03             	and    $0x3,%ecx
f010033f:	8b 0c 8d 60 6b 10 f0 	mov    -0xfef94a0(,%ecx,4),%ecx
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
f0100360:	83 0d 00 f0 32 f0 40 	orl    $0x40,0xf032f000
		return 0;
f0100367:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f010036c:	89 d8                	mov    %ebx,%eax
f010036e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100371:	c9                   	leave  
f0100372:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100373:	8b 0d 00 f0 32 f0    	mov    0xf032f000,%ecx
f0100379:	89 cb                	mov    %ecx,%ebx
f010037b:	83 e3 40             	and    $0x40,%ebx
f010037e:	83 e0 7f             	and    $0x7f,%eax
f0100381:	85 db                	test   %ebx,%ebx
f0100383:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100386:	0f b6 d2             	movzbl %dl,%edx
f0100389:	0f b6 82 80 6c 10 f0 	movzbl -0xfef9380(%edx),%eax
f0100390:	83 c8 40             	or     $0x40,%eax
f0100393:	0f b6 c0             	movzbl %al,%eax
f0100396:	f7 d0                	not    %eax
f0100398:	21 c8                	and    %ecx,%eax
f010039a:	a3 00 f0 32 f0       	mov    %eax,0xf032f000
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
f01003c3:	68 25 6b 10 f0       	push   $0xf0106b25
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
f01004dc:	0f b7 05 28 f2 32 f0 	movzwl 0xf032f228,%eax
f01004e3:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004e9:	c1 e8 16             	shr    $0x16,%eax
f01004ec:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004ef:	c1 e0 04             	shl    $0x4,%eax
f01004f2:	66 a3 28 f2 32 f0    	mov    %ax,0xf032f228
	if (crt_pos >= CRT_SIZE) {
f01004f8:	66 81 3d 28 f2 32 f0 	cmpw   $0x7cf,0xf032f228
f01004ff:	cf 07 
f0100501:	0f 87 8e 00 00 00    	ja     f0100595 <cons_putc+0x1aa>
	outb(addr_6845, 14);
f0100507:	8b 0d 30 f2 32 f0    	mov    0xf032f230,%ecx
f010050d:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100512:	89 ca                	mov    %ecx,%edx
f0100514:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100515:	0f b7 1d 28 f2 32 f0 	movzwl 0xf032f228,%ebx
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
f010053d:	0f b7 05 28 f2 32 f0 	movzwl 0xf032f228,%eax
f0100544:	66 85 c0             	test   %ax,%ax
f0100547:	74 be                	je     f0100507 <cons_putc+0x11c>
			crt_pos--;
f0100549:	83 e8 01             	sub    $0x1,%eax
f010054c:	66 a3 28 f2 32 f0    	mov    %ax,0xf032f228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100552:	0f b7 d0             	movzwl %ax,%edx
f0100555:	b1 00                	mov    $0x0,%cl
f0100557:	83 c9 20             	or     $0x20,%ecx
f010055a:	a1 2c f2 32 f0       	mov    0xf032f22c,%eax
f010055f:	66 89 0c 50          	mov    %cx,(%eax,%edx,2)
f0100563:	eb 93                	jmp    f01004f8 <cons_putc+0x10d>
		crt_pos += CRT_COLS;
f0100565:	66 83 05 28 f2 32 f0 	addw   $0x50,0xf032f228
f010056c:	50 
f010056d:	e9 6a ff ff ff       	jmp    f01004dc <cons_putc+0xf1>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100572:	0f b7 05 28 f2 32 f0 	movzwl 0xf032f228,%eax
f0100579:	8d 50 01             	lea    0x1(%eax),%edx
f010057c:	66 89 15 28 f2 32 f0 	mov    %dx,0xf032f228
f0100583:	0f b7 c0             	movzwl %ax,%eax
f0100586:	8b 15 2c f2 32 f0    	mov    0xf032f22c,%edx
f010058c:	66 89 0c 42          	mov    %cx,(%edx,%eax,2)
		break;
f0100590:	e9 63 ff ff ff       	jmp    f01004f8 <cons_putc+0x10d>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100595:	a1 2c f2 32 f0       	mov    0xf032f22c,%eax
f010059a:	83 ec 04             	sub    $0x4,%esp
f010059d:	68 00 0f 00 00       	push   $0xf00
f01005a2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005a8:	52                   	push   %edx
f01005a9:	50                   	push   %eax
f01005aa:	e8 61 58 00 00       	call   f0105e10 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01005af:	8b 15 2c f2 32 f0    	mov    0xf032f22c,%edx
f01005b5:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01005bb:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01005c1:	83 c4 10             	add    $0x10,%esp
f01005c4:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01005c9:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005cc:	39 d0                	cmp    %edx,%eax
f01005ce:	75 f4                	jne    f01005c4 <cons_putc+0x1d9>
		crt_pos -= CRT_COLS;
f01005d0:	66 83 2d 28 f2 32 f0 	subw   $0x50,0xf032f228
f01005d7:	50 
f01005d8:	e9 2a ff ff ff       	jmp    f0100507 <cons_putc+0x11c>

f01005dd <serial_intr>:
{
f01005dd:	f3 0f 1e fb          	endbr32 
	if (serial_exists)
f01005e1:	80 3d 34 f2 32 f0 00 	cmpb   $0x0,0xf032f234
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
f0100627:	a1 20 f2 32 f0       	mov    0xf032f220,%eax
	return 0;
f010062c:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f0100631:	3b 05 24 f2 32 f0    	cmp    0xf032f224,%eax
f0100637:	74 1c                	je     f0100655 <cons_getc+0x42>
		c = cons.buf[cons.rpos++];
f0100639:	8d 48 01             	lea    0x1(%eax),%ecx
f010063c:	0f b6 90 20 f0 32 f0 	movzbl -0xfcd0fe0(%eax),%edx
			cons.rpos = 0;
f0100643:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f0100648:	b8 00 00 00 00       	mov    $0x0,%eax
f010064d:	0f 45 c1             	cmovne %ecx,%eax
f0100650:	a3 20 f2 32 f0       	mov    %eax,0xf032f220
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
f0100687:	c7 05 30 f2 32 f0 b4 	movl   $0x3b4,0xf032f230
f010068e:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100691:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f0100696:	8b 3d 30 f2 32 f0    	mov    0xf032f230,%edi
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
f01006bd:	89 35 2c f2 32 f0    	mov    %esi,0xf032f22c
	pos |= inb(addr_6845 + 1);
f01006c3:	0f b6 c0             	movzbl %al,%eax
f01006c6:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f01006c8:	66 a3 28 f2 32 f0    	mov    %ax,0xf032f228
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
f010073e:	0f 95 05 34 f2 32 f0 	setne  0xf032f234
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
f0100756:	68 31 6b 10 f0       	push   $0xf0106b31
f010075b:	e8 de 33 00 00       	call   f0103b3e <cprintf>
f0100760:	83 c4 10             	add    $0x10,%esp
}
f0100763:	eb 3c                	jmp    f01007a1 <cons_init+0x148>
		*cp = was;
f0100765:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010076c:	c7 05 30 f2 32 f0 d4 	movl   $0x3d4,0xf032f230
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
f0100798:	80 3d 34 f2 32 f0 00 	cmpb   $0x0,0xf032f234
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
f01007e6:	68 80 6d 10 f0       	push   $0xf0106d80
f01007eb:	68 9e 6d 10 f0       	push   $0xf0106d9e
f01007f0:	68 a3 6d 10 f0       	push   $0xf0106da3
f01007f5:	e8 44 33 00 00       	call   f0103b3e <cprintf>
f01007fa:	83 c4 0c             	add    $0xc,%esp
f01007fd:	68 5c 6e 10 f0       	push   $0xf0106e5c
f0100802:	68 ac 6d 10 f0       	push   $0xf0106dac
f0100807:	68 a3 6d 10 f0       	push   $0xf0106da3
f010080c:	e8 2d 33 00 00       	call   f0103b3e <cprintf>
f0100811:	83 c4 0c             	add    $0xc,%esp
f0100814:	68 84 6e 10 f0       	push   $0xf0106e84
f0100819:	68 b5 6d 10 f0       	push   $0xf0106db5
f010081e:	68 a3 6d 10 f0       	push   $0xf0106da3
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
f0100839:	68 bf 6d 10 f0       	push   $0xf0106dbf
f010083e:	e8 fb 32 00 00       	call   f0103b3e <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100843:	83 c4 08             	add    $0x8,%esp
f0100846:	68 0c 00 10 00       	push   $0x10000c
f010084b:	68 b4 6e 10 f0       	push   $0xf0106eb4
f0100850:	e8 e9 32 00 00       	call   f0103b3e <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100855:	83 c4 0c             	add    $0xc,%esp
f0100858:	68 0c 00 10 00       	push   $0x10000c
f010085d:	68 0c 00 10 f0       	push   $0xf010000c
f0100862:	68 dc 6e 10 f0       	push   $0xf0106edc
f0100867:	e8 d2 32 00 00       	call   f0103b3e <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010086c:	83 c4 0c             	add    $0xc,%esp
f010086f:	68 5d 6a 10 00       	push   $0x106a5d
f0100874:	68 5d 6a 10 f0       	push   $0xf0106a5d
f0100879:	68 00 6f 10 f0       	push   $0xf0106f00
f010087e:	e8 bb 32 00 00       	call   f0103b3e <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100883:	83 c4 0c             	add    $0xc,%esp
f0100886:	68 00 f0 32 00       	push   $0x32f000
f010088b:	68 00 f0 32 f0       	push   $0xf032f000
f0100890:	68 24 6f 10 f0       	push   $0xf0106f24
f0100895:	e8 a4 32 00 00       	call   f0103b3e <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010089a:	83 c4 0c             	add    $0xc,%esp
f010089d:	68 08 10 37 00       	push   $0x371008
f01008a2:	68 08 10 37 f0       	push   $0xf0371008
f01008a7:	68 48 6f 10 f0       	push   $0xf0106f48
f01008ac:	e8 8d 32 00 00       	call   f0103b3e <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008b1:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01008b4:	b8 08 10 37 f0       	mov    $0xf0371008,%eax
f01008b9:	2d 0d fc 0f f0       	sub    $0xf00ffc0d,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008be:	c1 f8 0a             	sar    $0xa,%eax
f01008c1:	50                   	push   %eax
f01008c2:	68 6c 6f 10 f0       	push   $0xf0106f6c
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
f01008e0:	68 d8 6d 10 f0       	push   $0xf0106dd8
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
f01008f7:	68 40 7c 10 f0       	push   $0xf0107c40
f01008fc:	e8 3d 32 00 00       	call   f0103b3e <cprintf>

        struct Eipdebuginfo info;
        memset(&info, 0, sizeof(struct Eipdebuginfo));
f0100901:	83 c4 0c             	add    $0xc,%esp
f0100904:	6a 18                	push   $0x18
f0100906:	6a 00                	push   $0x0
f0100908:	8d 45 d0             	lea    -0x30(%ebp),%eax
f010090b:	50                   	push   %eax
f010090c:	e8 b3 54 00 00       	call   f0105dc4 <memset>

        int ret = debuginfo_eip((uintptr_t)ebp[1], &info);
f0100911:	83 c4 08             	add    $0x8,%esp
f0100914:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100917:	50                   	push   %eax
f0100918:	ff 77 04             	pushl  0x4(%edi)
f010091b:	e8 66 49 00 00       	call   f0105286 <debuginfo_eip>
        cprintf("         ");
f0100920:	c7 04 24 07 6e 10 f0 	movl   $0xf0106e07,(%esp)
f0100927:	e8 12 32 00 00       	call   f0103b3e <cprintf>
        cprintf("%s:", info.eip_file);
f010092c:	83 c4 08             	add    $0x8,%esp
f010092f:	ff 75 d0             	pushl  -0x30(%ebp)
f0100932:	68 11 6e 10 f0       	push   $0xf0106e11
f0100937:	e8 02 32 00 00       	call   f0103b3e <cprintf>
        cprintf("%d: ", info.eip_line);
f010093c:	83 c4 08             	add    $0x8,%esp
f010093f:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100942:	68 20 6b 10 f0       	push   $0xf0106b20
f0100947:	e8 f2 31 00 00       	call   f0103b3e <cprintf>
        cprintf("%.*s", info.eip_fn_namelen, info.eip_fn_name);
f010094c:	83 c4 0c             	add    $0xc,%esp
f010094f:	ff 75 d8             	pushl  -0x28(%ebp)
f0100952:	ff 75 dc             	pushl  -0x24(%ebp)
f0100955:	68 15 6e 10 f0       	push   $0xf0106e15
f010095a:	e8 df 31 00 00       	call   f0103b3e <cprintf>

        uintptr_t addr = ebp[1] - info.eip_fn_addr;

        cprintf("+%d\n", addr);
f010095f:	83 c4 08             	add    $0x8,%esp
        uintptr_t addr = ebp[1] - info.eip_fn_addr;
f0100962:	8b 47 04             	mov    0x4(%edi),%eax
f0100965:	2b 45 e0             	sub    -0x20(%ebp),%eax
        cprintf("+%d\n", addr);
f0100968:	50                   	push   %eax
f0100969:	68 1a 6e 10 f0       	push   $0xf0106e1a
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
f0100982:	68 ea 6d 10 f0       	push   $0xf0106dea
f0100987:	e8 b2 31 00 00       	call   f0103b3e <cprintf>
        cprintf("  eip %08x", ebp[1]);
f010098c:	83 c4 08             	add    $0x8,%esp
f010098f:	ff 76 04             	pushl  0x4(%esi)
f0100992:	68 f5 6d 10 f0       	push   $0xf0106df5
f0100997:	e8 a2 31 00 00       	call   f0103b3e <cprintf>
        cprintf("  args");
f010099c:	c7 04 24 00 6e 10 f0 	movl   $0xf0106e00,(%esp)
f01009a3:	e8 96 31 00 00       	call   f0103b3e <cprintf>
f01009a8:	8d 5e 08             	lea    0x8(%esi),%ebx
f01009ab:	83 c6 1c             	add    $0x1c,%esi
f01009ae:	83 c4 10             	add    $0x10,%esp
            cprintf(" %08x", ebp[2+i]);
f01009b1:	83 ec 08             	sub    $0x8,%esp
f01009b4:	ff 33                	pushl  (%ebx)
f01009b6:	68 ef 6d 10 f0       	push   $0xf0106def
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
f01009e9:	68 98 6f 10 f0       	push   $0xf0106f98
f01009ee:	e8 4b 31 00 00       	call   f0103b3e <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009f3:	c7 04 24 bc 6f 10 f0 	movl   $0xf0106fbc,(%esp)
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
f0100a26:	68 23 6e 10 f0       	push   $0xf0106e23
f0100a2b:	e8 4f 53 00 00       	call   f0105d7f <strchr>
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
f0100a63:	ff 34 85 00 70 10 f0 	pushl  -0xfef9000(,%eax,4)
f0100a6a:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a6d:	e8 a7 52 00 00       	call   f0105d19 <strcmp>
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
f0100a8b:	68 45 6e 10 f0       	push   $0xf0106e45
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
f0100ab9:	68 23 6e 10 f0       	push   $0xf0106e23
f0100abe:	e8 bc 52 00 00       	call   f0105d7f <strchr>
f0100ac3:	83 c4 10             	add    $0x10,%esp
f0100ac6:	85 c0                	test   %eax,%eax
f0100ac8:	0f 85 71 ff ff ff    	jne    f0100a3f <monitor+0x63>
			buf++;
f0100ace:	83 c3 01             	add    $0x1,%ebx
f0100ad1:	eb d8                	jmp    f0100aab <monitor+0xcf>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100ad3:	83 ec 08             	sub    $0x8,%esp
f0100ad6:	6a 10                	push   $0x10
f0100ad8:	68 28 6e 10 f0       	push   $0xf0106e28
f0100add:	e8 5c 30 00 00       	call   f0103b3e <cprintf>
			return 0;
f0100ae2:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100ae5:	83 ec 0c             	sub    $0xc,%esp
f0100ae8:	68 1f 6e 10 f0       	push   $0xf0106e1f
f0100aed:	e8 33 50 00 00       	call   f0105b25 <readline>
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
f0100b1a:	ff 14 85 08 70 10 f0 	call   *-0xfef8ff8(,%eax,4)
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
f0100b70:	3b 05 88 fe 32 f0    	cmp    0xf032fe88,%eax
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
f0100ba2:	68 84 6a 10 f0       	push   $0xf0106a84
f0100ba7:	68 d6 03 00 00       	push   $0x3d6
f0100bac:	68 45 79 10 f0       	push   $0xf0107945
f0100bb1:	e8 8a f4 ff ff       	call   f0100040 <_panic>
		return ~0;
f0100bb6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100bbb:	c3                   	ret    

f0100bbc <boot_alloc>:
	if (!nextfree) {
f0100bbc:	83 3d 38 f2 32 f0 00 	cmpl   $0x0,0xf032f238
f0100bc3:	74 3d                	je     f0100c02 <boot_alloc+0x46>
    if (n == 0) {
f0100bc5:	85 c0                	test   %eax,%eax
f0100bc7:	74 4c                	je     f0100c15 <boot_alloc+0x59>
{
f0100bc9:	55                   	push   %ebp
f0100bca:	89 e5                	mov    %esp,%ebp
f0100bcc:	83 ec 08             	sub    $0x8,%esp
            (uintptr_t) ROUNDUP((char *)nextfree + n, PGSIZE);
f0100bcf:	8b 15 38 f2 32 f0    	mov    0xf032f238,%edx
f0100bd5:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100bdc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if ((uint32_t)kva < KERNBASE)
f0100be1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100be6:	76 36                	jbe    f0100c1e <boot_alloc+0x62>
	return (physaddr_t)kva - KERNBASE;
f0100be8:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
    if ( PADDR((void *)next_nextfree)/PGSIZE < npages ) {
f0100bee:	c1 e9 0c             	shr    $0xc,%ecx
f0100bf1:	3b 0d 88 fe 32 f0    	cmp    0xf032fe88,%ecx
f0100bf7:	73 37                	jae    f0100c30 <boot_alloc+0x74>
        nextfree = (char *)next_nextfree;
f0100bf9:	a3 38 f2 32 f0       	mov    %eax,0xf032f238
}
f0100bfe:	89 d0                	mov    %edx,%eax
f0100c00:	c9                   	leave  
f0100c01:	c3                   	ret    
		nextfree = ROUNDUP((char *) end + 1, PGSIZE);
f0100c02:	ba 08 20 37 f0       	mov    $0xf0372008,%edx
f0100c07:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100c0d:	89 15 38 f2 32 f0    	mov    %edx,0xf032f238
f0100c13:	eb b0                	jmp    f0100bc5 <boot_alloc+0x9>
        return nextfree;
f0100c15:	8b 15 38 f2 32 f0    	mov    0xf032f238,%edx
}
f0100c1b:	89 d0                	mov    %edx,%eax
f0100c1d:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100c1e:	50                   	push   %eax
f0100c1f:	68 a8 6a 10 f0       	push   $0xf0106aa8
f0100c24:	6a 76                	push   $0x76
f0100c26:	68 45 79 10 f0       	push   $0xf0107945
f0100c2b:	e8 10 f4 ff ff       	call   f0100040 <_panic>
        panic("Out of memory");
f0100c30:	83 ec 04             	sub    $0x4,%esp
f0100c33:	68 51 79 10 f0       	push   $0xf0107951
f0100c38:	6a 7c                	push   $0x7c
f0100c3a:	68 45 79 10 f0       	push   $0xf0107945
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
f0100c55:	83 3d 40 f2 32 f0 00 	cmpl   $0x0,0xf032f240
f0100c5c:	74 0a                	je     f0100c68 <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c5e:	be 00 04 00 00       	mov    $0x400,%esi
f0100c63:	e9 bf 02 00 00       	jmp    f0100f27 <check_page_free_list+0x2e3>
		panic("'page_free_list' is a null pointer!");
f0100c68:	83 ec 04             	sub    $0x4,%esp
f0100c6b:	68 24 70 10 f0       	push   $0xf0107024
f0100c70:	68 08 03 00 00       	push   $0x308
f0100c75:	68 45 79 10 f0       	push   $0xf0107945
f0100c7a:	e8 c1 f3 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c7f:	50                   	push   %eax
f0100c80:	68 84 6a 10 f0       	push   $0xf0106a84
f0100c85:	6a 58                	push   $0x58
f0100c87:	68 5f 79 10 f0       	push   $0xf010795f
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
f0100c99:	2b 05 90 fe 32 f0    	sub    0xf032fe90,%eax
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
f0100cb3:	3b 15 88 fe 32 f0    	cmp    0xf032fe88,%edx
f0100cb9:	73 c4                	jae    f0100c7f <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100cbb:	83 ec 04             	sub    $0x4,%esp
f0100cbe:	68 80 00 00 00       	push   $0x80
f0100cc3:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100cc8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ccd:	50                   	push   %eax
f0100cce:	e8 f1 50 00 00       	call   f0105dc4 <memset>
f0100cd3:	83 c4 10             	add    $0x10,%esp
f0100cd6:	eb b9                	jmp    f0100c91 <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f0100cd8:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cdd:	e8 da fe ff ff       	call   f0100bbc <boot_alloc>
f0100ce2:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ce5:	8b 15 40 f2 32 f0    	mov    0xf032f240,%edx
		assert(pp >= pages);
f0100ceb:	8b 0d 90 fe 32 f0    	mov    0xf032fe90,%ecx
		assert(pp < pages + npages);
f0100cf1:	a1 88 fe 32 f0       	mov    0xf032fe88,%eax
f0100cf6:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100cf9:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100cfc:	bf 00 00 00 00       	mov    $0x0,%edi
f0100d01:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d04:	e9 f9 00 00 00       	jmp    f0100e02 <check_page_free_list+0x1be>
		assert(pp >= pages);
f0100d09:	68 6d 79 10 f0       	push   $0xf010796d
f0100d0e:	68 79 79 10 f0       	push   $0xf0107979
f0100d13:	68 22 03 00 00       	push   $0x322
f0100d18:	68 45 79 10 f0       	push   $0xf0107945
f0100d1d:	e8 1e f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100d22:	68 8e 79 10 f0       	push   $0xf010798e
f0100d27:	68 79 79 10 f0       	push   $0xf0107979
f0100d2c:	68 23 03 00 00       	push   $0x323
f0100d31:	68 45 79 10 f0       	push   $0xf0107945
f0100d36:	e8 05 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d3b:	68 48 70 10 f0       	push   $0xf0107048
f0100d40:	68 79 79 10 f0       	push   $0xf0107979
f0100d45:	68 24 03 00 00       	push   $0x324
f0100d4a:	68 45 79 10 f0       	push   $0xf0107945
f0100d4f:	e8 ec f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != 0);
f0100d54:	68 a2 79 10 f0       	push   $0xf01079a2
f0100d59:	68 79 79 10 f0       	push   $0xf0107979
f0100d5e:	68 27 03 00 00       	push   $0x327
f0100d63:	68 45 79 10 f0       	push   $0xf0107945
f0100d68:	e8 d3 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d6d:	68 b3 79 10 f0       	push   $0xf01079b3
f0100d72:	68 79 79 10 f0       	push   $0xf0107979
f0100d77:	68 28 03 00 00       	push   $0x328
f0100d7c:	68 45 79 10 f0       	push   $0xf0107945
f0100d81:	e8 ba f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d86:	68 7c 70 10 f0       	push   $0xf010707c
f0100d8b:	68 79 79 10 f0       	push   $0xf0107979
f0100d90:	68 29 03 00 00       	push   $0x329
f0100d95:	68 45 79 10 f0       	push   $0xf0107945
f0100d9a:	e8 a1 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d9f:	68 cc 79 10 f0       	push   $0xf01079cc
f0100da4:	68 79 79 10 f0       	push   $0xf0107979
f0100da9:	68 2a 03 00 00       	push   $0x32a
f0100dae:	68 45 79 10 f0       	push   $0xf0107945
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
f0100dd2:	68 84 6a 10 f0       	push   $0xf0106a84
f0100dd7:	6a 58                	push   $0x58
f0100dd9:	68 5f 79 10 f0       	push   $0xf010795f
f0100dde:	e8 5d f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100de3:	68 a0 70 10 f0       	push   $0xf01070a0
f0100de8:	68 79 79 10 f0       	push   $0xf0107979
f0100ded:	68 2b 03 00 00       	push   $0x32b
f0100df2:	68 45 79 10 f0       	push   $0xf0107945
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
f0100e61:	68 e6 79 10 f0       	push   $0xf01079e6
f0100e66:	68 79 79 10 f0       	push   $0xf0107979
f0100e6b:	68 2d 03 00 00       	push   $0x32d
f0100e70:	68 45 79 10 f0       	push   $0xf0107945
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
f0100e88:	68 e8 70 10 f0       	push   $0xf01070e8
f0100e8d:	e8 ac 2c 00 00       	call   f0103b3e <cprintf>
}
f0100e92:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e95:	5b                   	pop    %ebx
f0100e96:	5e                   	pop    %esi
f0100e97:	5f                   	pop    %edi
f0100e98:	5d                   	pop    %ebp
f0100e99:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100e9a:	68 03 7a 10 f0       	push   $0xf0107a03
f0100e9f:	68 79 79 10 f0       	push   $0xf0107979
f0100ea4:	68 35 03 00 00       	push   $0x335
f0100ea9:	68 45 79 10 f0       	push   $0xf0107945
f0100eae:	e8 8d f1 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100eb3:	68 15 7a 10 f0       	push   $0xf0107a15
f0100eb8:	68 79 79 10 f0       	push   $0xf0107979
f0100ebd:	68 36 03 00 00       	push   $0x336
f0100ec2:	68 45 79 10 f0       	push   $0xf0107945
f0100ec7:	e8 74 f1 ff ff       	call   f0100040 <_panic>
	if (!page_free_list)
f0100ecc:	a1 40 f2 32 f0       	mov    0xf032f240,%eax
f0100ed1:	85 c0                	test   %eax,%eax
f0100ed3:	0f 84 8f fd ff ff    	je     f0100c68 <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100ed9:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100edc:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100edf:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100ee2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100ee5:	89 c2                	mov    %eax,%edx
f0100ee7:	2b 15 90 fe 32 f0    	sub    0xf032fe90,%edx
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
f0100f1d:	a3 40 f2 32 f0       	mov    %eax,0xf032f240
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100f22:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100f27:	8b 1d 40 f2 32 f0    	mov    0xf032f240,%ebx
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
f0100f59:	8b 3d 40 f2 32 f0    	mov    0xf032f240,%edi
    for (int i=0; i<npages; ++i) {
f0100f5f:	c6 45 e3 00          	movb   $0x0,-0x1d(%ebp)
f0100f63:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f68:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100f6b:	eb 32                	jmp    f0100f9f <page_init+0x6d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f6d:	50                   	push   %eax
f0100f6e:	68 a8 6a 10 f0       	push   $0xf0106aa8
f0100f73:	68 5f 01 00 00       	push   $0x15f
f0100f78:	68 45 79 10 f0       	push   $0xf0107945
f0100f7d:	e8 be f0 ff ff       	call   f0100040 <_panic>
            pages[i].pp_link = NULL;
f0100f82:	8b 1d 90 fe 32 f0    	mov    0xf032fe90,%ebx
f0100f88:	c7 04 d3 00 00 00 00 	movl   $0x0,(%ebx,%edx,8)
            pages[i].pp_ref = 1;
f0100f8f:	8b 1d 90 fe 32 f0    	mov    0xf032fe90,%ebx
f0100f95:	66 c7 44 d3 04 01 00 	movw   $0x1,0x4(%ebx,%edx,8)
    for (int i=0; i<npages; ++i) {
f0100f9c:	83 c0 01             	add    $0x1,%eax
f0100f9f:	89 c2                	mov    %eax,%edx
f0100fa1:	39 05 88 fe 32 f0    	cmp    %eax,0xf032fe88
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
f0100fce:	03 1d 90 fe 32 f0    	add    0xf032fe90,%ebx
f0100fd4:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
            pages[i].pp_link = page_free_list;
f0100fda:	89 3b                	mov    %edi,(%ebx)
            page_free_list = &pages[i];
f0100fdc:	89 d7                	mov    %edx,%edi
f0100fde:	03 3d 90 fe 32 f0    	add    0xf032fe90,%edi
f0100fe4:	c6 45 e3 01          	movb   $0x1,-0x1d(%ebp)
f0100fe8:	eb b2                	jmp    f0100f9c <page_init+0x6a>
f0100fea:	80 7d e3 00          	cmpb   $0x0,-0x1d(%ebp)
f0100fee:	74 06                	je     f0100ff6 <page_init+0xc4>
f0100ff0:	89 3d 40 f2 32 f0    	mov    %edi,0xf032f240
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
f0101009:	8b 1d 40 f2 32 f0    	mov    0xf032f240,%ebx
f010100f:	85 db                	test   %ebx,%ebx
f0101011:	74 13                	je     f0101026 <page_alloc+0x28>
    page_free_list = ret->pp_link;
f0101013:	8b 03                	mov    (%ebx),%eax
f0101015:	a3 40 f2 32 f0       	mov    %eax,0xf032f240
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
f010102f:	2b 05 90 fe 32 f0    	sub    0xf032fe90,%eax
f0101035:	c1 f8 03             	sar    $0x3,%eax
f0101038:	89 c2                	mov    %eax,%edx
f010103a:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010103d:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101042:	3b 05 88 fe 32 f0    	cmp    0xf032fe88,%eax
f0101048:	73 1b                	jae    f0101065 <page_alloc+0x67>
        memset(p, 0, PGSIZE);
f010104a:	83 ec 04             	sub    $0x4,%esp
f010104d:	68 00 10 00 00       	push   $0x1000
f0101052:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0101054:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010105a:	52                   	push   %edx
f010105b:	e8 64 4d 00 00       	call   f0105dc4 <memset>
f0101060:	83 c4 10             	add    $0x10,%esp
f0101063:	eb c1                	jmp    f0101026 <page_alloc+0x28>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101065:	52                   	push   %edx
f0101066:	68 84 6a 10 f0       	push   $0xf0106a84
f010106b:	6a 58                	push   $0x58
f010106d:	68 5f 79 10 f0       	push   $0xf010795f
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
f0101090:	8b 15 40 f2 32 f0    	mov    0xf032f240,%edx
f0101096:	89 10                	mov    %edx,(%eax)
    page_free_list = pp;
f0101098:	a3 40 f2 32 f0       	mov    %eax,0xf032f240
}
f010109d:	c9                   	leave  
f010109e:	c3                   	ret    
        panic("Double free!");
f010109f:	83 ec 04             	sub    $0x4,%esp
f01010a2:	68 26 7a 10 f0       	push   $0xf0107a26
f01010a7:	68 9f 01 00 00       	push   $0x19f
f01010ac:	68 45 79 10 f0       	push   $0xf0107945
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
f010111b:	2b 05 90 fe 32 f0    	sub    0xf032fe90,%eax
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
f0101143:	3b 15 88 fe 32 f0    	cmp    0xf032fe88,%edx
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
f0101158:	68 84 6a 10 f0       	push   $0xf0106a84
f010115d:	68 df 01 00 00       	push   $0x1df
f0101162:	68 45 79 10 f0       	push   $0xf0107945
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
f0101214:	39 05 88 fe 32 f0    	cmp    %eax,0xf032fe88
f010121a:	76 0e                	jbe    f010122a <page_lookup+0x47>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f010121c:	8b 15 90 fe 32 f0    	mov    0xf032fe90,%edx
f0101222:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f0101225:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101228:	c9                   	leave  
f0101229:	c3                   	ret    
		panic("pa2page called with invalid pa");
f010122a:	83 ec 04             	sub    $0x4,%esp
f010122d:	68 0c 71 10 f0       	push   $0xf010710c
f0101232:	6a 51                	push   $0x51
f0101234:	68 5f 79 10 f0       	push   $0xf010795f
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
f010124f:	e8 8e 51 00 00       	call   f01063e2 <cpunum>
f0101254:	6b c0 74             	imul   $0x74,%eax,%eax
f0101257:	83 b8 28 00 33 f0 00 	cmpl   $0x0,-0xfccffd8(%eax)
f010125e:	74 16                	je     f0101276 <tlb_invalidate+0x31>
f0101260:	e8 7d 51 00 00       	call   f01063e2 <cpunum>
f0101265:	6b c0 74             	imul   $0x74,%eax,%eax
f0101268:	8b 80 28 00 33 f0    	mov    -0xfccffd8(%eax),%eax
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
f01012fe:	2b 1d 90 fe 32 f0    	sub    0xf032fe90,%ebx
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
f0101379:	a1 8c fe 32 f0       	mov    0xf032fe8c,%eax
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
f01013e3:	89 15 88 fe 32 f0    	mov    %edx,0xf032fe88
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013e9:	89 c2                	mov    %eax,%edx
f01013eb:	29 da                	sub    %ebx,%edx
f01013ed:	52                   	push   %edx
f01013ee:	53                   	push   %ebx
f01013ef:	50                   	push   %eax
f01013f0:	68 2c 71 10 f0       	push   $0xf010712c
f01013f5:	e8 44 27 00 00       	call   f0103b3e <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01013fa:	b8 00 10 00 00       	mov    $0x1000,%eax
f01013ff:	e8 b8 f7 ff ff       	call   f0100bbc <boot_alloc>
f0101404:	a3 8c fe 32 f0       	mov    %eax,0xf032fe8c
	memset(kern_pgdir, 0, PGSIZE);
f0101409:	83 c4 0c             	add    $0xc,%esp
f010140c:	68 00 10 00 00       	push   $0x1000
f0101411:	6a 00                	push   $0x0
f0101413:	50                   	push   %eax
f0101414:	e8 ab 49 00 00       	call   f0105dc4 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101419:	a1 8c fe 32 f0       	mov    0xf032fe8c,%eax
	if ((uint32_t)kva < KERNBASE)
f010141e:	83 c4 10             	add    $0x10,%esp
f0101421:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101426:	0f 86 9b 00 00 00    	jbe    f01014c7 <mem_init+0x126>
	return (physaddr_t)kva - KERNBASE;
f010142c:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101432:	83 ca 05             	or     $0x5,%edx
f0101435:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
    size_t alloc_size = ROUNDUP(sizeof(struct PageInfo) * npages, PGSIZE);
f010143b:	a1 88 fe 32 f0       	mov    0xf032fe88,%eax
f0101440:	8d 1c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ebx
f0101447:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    pages = (struct PageInfo *) boot_alloc(alloc_size);
f010144d:	89 d8                	mov    %ebx,%eax
f010144f:	e8 68 f7 ff ff       	call   f0100bbc <boot_alloc>
f0101454:	a3 90 fe 32 f0       	mov    %eax,0xf032fe90
    memset(pages, 0, alloc_size);
f0101459:	83 ec 04             	sub    $0x4,%esp
f010145c:	53                   	push   %ebx
f010145d:	6a 00                	push   $0x0
f010145f:	50                   	push   %eax
f0101460:	e8 5f 49 00 00       	call   f0105dc4 <memset>
    envs = (struct Env *) boot_alloc(alloc_size);
f0101465:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f010146a:	e8 4d f7 ff ff       	call   f0100bbc <boot_alloc>
f010146f:	a3 44 f2 32 f0       	mov    %eax,0xf032f244
    memset(envs, 0, alloc_size);
f0101474:	83 c4 0c             	add    $0xc,%esp
f0101477:	68 00 f0 01 00       	push   $0x1f000
f010147c:	6a 00                	push   $0x0
f010147e:	50                   	push   %eax
f010147f:	e8 40 49 00 00       	call   f0105dc4 <memset>
	page_init();
f0101484:	e8 a9 fa ff ff       	call   f0100f32 <page_init>
	check_page_free_list(1);
f0101489:	b8 01 00 00 00       	mov    $0x1,%eax
f010148e:	e8 b1 f7 ff ff       	call   f0100c44 <check_page_free_list>
	if (!pages)
f0101493:	83 c4 10             	add    $0x10,%esp
f0101496:	83 3d 90 fe 32 f0 00 	cmpl   $0x0,0xf032fe90
f010149d:	74 3d                	je     f01014dc <mem_init+0x13b>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010149f:	a1 40 f2 32 f0       	mov    0xf032f240,%eax
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
f01014c8:	68 a8 6a 10 f0       	push   $0xf0106aa8
f01014cd:	68 a5 00 00 00       	push   $0xa5
f01014d2:	68 45 79 10 f0       	push   $0xf0107945
f01014d7:	e8 64 eb ff ff       	call   f0100040 <_panic>
		panic("'pages' is a null pointer!");
f01014dc:	83 ec 04             	sub    $0x4,%esp
f01014df:	68 33 7a 10 f0       	push   $0xf0107a33
f01014e4:	68 49 03 00 00       	push   $0x349
f01014e9:	68 45 79 10 f0       	push   $0xf0107945
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
f0101550:	8b 0d 90 fe 32 f0    	mov    0xf032fe90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101556:	8b 15 88 fe 32 f0    	mov    0xf032fe88,%edx
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
f0101595:	a1 40 f2 32 f0       	mov    0xf032f240,%eax
f010159a:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010159d:	c7 05 40 f2 32 f0 00 	movl   $0x0,0xf032f240
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
f010164b:	2b 05 90 fe 32 f0    	sub    0xf032fe90,%eax
f0101651:	c1 f8 03             	sar    $0x3,%eax
f0101654:	89 c2                	mov    %eax,%edx
f0101656:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101659:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010165e:	3b 05 88 fe 32 f0    	cmp    0xf032fe88,%eax
f0101664:	0f 83 28 02 00 00    	jae    f0101892 <mem_init+0x4f1>
	memset(page2kva(pp0), 1, PGSIZE);
f010166a:	83 ec 04             	sub    $0x4,%esp
f010166d:	68 00 10 00 00       	push   $0x1000
f0101672:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101674:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010167a:	52                   	push   %edx
f010167b:	e8 44 47 00 00       	call   f0105dc4 <memset>
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
f01016a7:	2b 05 90 fe 32 f0    	sub    0xf032fe90,%eax
f01016ad:	c1 f8 03             	sar    $0x3,%eax
f01016b0:	89 c2                	mov    %eax,%edx
f01016b2:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01016b5:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01016ba:	3b 05 88 fe 32 f0    	cmp    0xf032fe88,%eax
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
f01016e5:	a3 40 f2 32 f0       	mov    %eax,0xf032f240
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
f0101703:	a1 40 f2 32 f0       	mov    0xf032f240,%eax
f0101708:	83 c4 10             	add    $0x10,%esp
f010170b:	85 c0                	test   %eax,%eax
f010170d:	0f 84 ee 01 00 00    	je     f0101901 <mem_init+0x560>
		--nfree;
f0101713:	83 6d d4 01          	subl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101717:	8b 00                	mov    (%eax),%eax
f0101719:	eb f0                	jmp    f010170b <mem_init+0x36a>
	assert((pp0 = page_alloc(0)));
f010171b:	68 4e 7a 10 f0       	push   $0xf0107a4e
f0101720:	68 79 79 10 f0       	push   $0xf0107979
f0101725:	68 51 03 00 00       	push   $0x351
f010172a:	68 45 79 10 f0       	push   $0xf0107945
f010172f:	e8 0c e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101734:	68 64 7a 10 f0       	push   $0xf0107a64
f0101739:	68 79 79 10 f0       	push   $0xf0107979
f010173e:	68 52 03 00 00       	push   $0x352
f0101743:	68 45 79 10 f0       	push   $0xf0107945
f0101748:	e8 f3 e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010174d:	68 7a 7a 10 f0       	push   $0xf0107a7a
f0101752:	68 79 79 10 f0       	push   $0xf0107979
f0101757:	68 53 03 00 00       	push   $0x353
f010175c:	68 45 79 10 f0       	push   $0xf0107945
f0101761:	e8 da e8 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101766:	68 90 7a 10 f0       	push   $0xf0107a90
f010176b:	68 79 79 10 f0       	push   $0xf0107979
f0101770:	68 56 03 00 00       	push   $0x356
f0101775:	68 45 79 10 f0       	push   $0xf0107945
f010177a:	e8 c1 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010177f:	68 68 71 10 f0       	push   $0xf0107168
f0101784:	68 79 79 10 f0       	push   $0xf0107979
f0101789:	68 57 03 00 00       	push   $0x357
f010178e:	68 45 79 10 f0       	push   $0xf0107945
f0101793:	e8 a8 e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101798:	68 a2 7a 10 f0       	push   $0xf0107aa2
f010179d:	68 79 79 10 f0       	push   $0xf0107979
f01017a2:	68 58 03 00 00       	push   $0x358
f01017a7:	68 45 79 10 f0       	push   $0xf0107945
f01017ac:	e8 8f e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01017b1:	68 bf 7a 10 f0       	push   $0xf0107abf
f01017b6:	68 79 79 10 f0       	push   $0xf0107979
f01017bb:	68 59 03 00 00       	push   $0x359
f01017c0:	68 45 79 10 f0       	push   $0xf0107945
f01017c5:	e8 76 e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01017ca:	68 dc 7a 10 f0       	push   $0xf0107adc
f01017cf:	68 79 79 10 f0       	push   $0xf0107979
f01017d4:	68 5a 03 00 00       	push   $0x35a
f01017d9:	68 45 79 10 f0       	push   $0xf0107945
f01017de:	e8 5d e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01017e3:	68 f9 7a 10 f0       	push   $0xf0107af9
f01017e8:	68 79 79 10 f0       	push   $0xf0107979
f01017ed:	68 61 03 00 00       	push   $0x361
f01017f2:	68 45 79 10 f0       	push   $0xf0107945
f01017f7:	e8 44 e8 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f01017fc:	68 4e 7a 10 f0       	push   $0xf0107a4e
f0101801:	68 79 79 10 f0       	push   $0xf0107979
f0101806:	68 68 03 00 00       	push   $0x368
f010180b:	68 45 79 10 f0       	push   $0xf0107945
f0101810:	e8 2b e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101815:	68 64 7a 10 f0       	push   $0xf0107a64
f010181a:	68 79 79 10 f0       	push   $0xf0107979
f010181f:	68 69 03 00 00       	push   $0x369
f0101824:	68 45 79 10 f0       	push   $0xf0107945
f0101829:	e8 12 e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010182e:	68 7a 7a 10 f0       	push   $0xf0107a7a
f0101833:	68 79 79 10 f0       	push   $0xf0107979
f0101838:	68 6a 03 00 00       	push   $0x36a
f010183d:	68 45 79 10 f0       	push   $0xf0107945
f0101842:	e8 f9 e7 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101847:	68 90 7a 10 f0       	push   $0xf0107a90
f010184c:	68 79 79 10 f0       	push   $0xf0107979
f0101851:	68 6c 03 00 00       	push   $0x36c
f0101856:	68 45 79 10 f0       	push   $0xf0107945
f010185b:	e8 e0 e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101860:	68 68 71 10 f0       	push   $0xf0107168
f0101865:	68 79 79 10 f0       	push   $0xf0107979
f010186a:	68 6d 03 00 00       	push   $0x36d
f010186f:	68 45 79 10 f0       	push   $0xf0107945
f0101874:	e8 c7 e7 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101879:	68 f9 7a 10 f0       	push   $0xf0107af9
f010187e:	68 79 79 10 f0       	push   $0xf0107979
f0101883:	68 6e 03 00 00       	push   $0x36e
f0101888:	68 45 79 10 f0       	push   $0xf0107945
f010188d:	e8 ae e7 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101892:	52                   	push   %edx
f0101893:	68 84 6a 10 f0       	push   $0xf0106a84
f0101898:	6a 58                	push   $0x58
f010189a:	68 5f 79 10 f0       	push   $0xf010795f
f010189f:	e8 9c e7 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01018a4:	68 08 7b 10 f0       	push   $0xf0107b08
f01018a9:	68 79 79 10 f0       	push   $0xf0107979
f01018ae:	68 73 03 00 00       	push   $0x373
f01018b3:	68 45 79 10 f0       	push   $0xf0107945
f01018b8:	e8 83 e7 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01018bd:	68 26 7b 10 f0       	push   $0xf0107b26
f01018c2:	68 79 79 10 f0       	push   $0xf0107979
f01018c7:	68 74 03 00 00       	push   $0x374
f01018cc:	68 45 79 10 f0       	push   $0xf0107945
f01018d1:	e8 6a e7 ff ff       	call   f0100040 <_panic>
f01018d6:	52                   	push   %edx
f01018d7:	68 84 6a 10 f0       	push   $0xf0106a84
f01018dc:	6a 58                	push   $0x58
f01018de:	68 5f 79 10 f0       	push   $0xf010795f
f01018e3:	e8 58 e7 ff ff       	call   f0100040 <_panic>
		assert(c[i] == 0);
f01018e8:	68 36 7b 10 f0       	push   $0xf0107b36
f01018ed:	68 79 79 10 f0       	push   $0xf0107979
f01018f2:	68 77 03 00 00       	push   $0x377
f01018f7:	68 45 79 10 f0       	push   $0xf0107945
f01018fc:	e8 3f e7 ff ff       	call   f0100040 <_panic>
	assert(nfree == 0);
f0101901:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0101905:	0f 85 e4 09 00 00    	jne    f01022ef <mem_init+0xf4e>
	cprintf("check_page_alloc() succeeded!\n");
f010190b:	83 ec 0c             	sub    $0xc,%esp
f010190e:	68 88 71 10 f0       	push   $0xf0107188
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
f010197a:	a1 40 f2 32 f0       	mov    0xf032f240,%eax
f010197f:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f0101982:	c7 05 40 f2 32 f0 00 	movl   $0x0,0xf032f240
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
f01019aa:	ff 35 8c fe 32 f0    	pushl  0xf032fe8c
f01019b0:	e8 2e f8 ff ff       	call   f01011e3 <page_lookup>
f01019b5:	83 c4 10             	add    $0x10,%esp
f01019b8:	85 c0                	test   %eax,%eax
f01019ba:	0f 85 de 09 00 00    	jne    f010239e <mem_init+0xffd>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01019c0:	6a 02                	push   $0x2
f01019c2:	6a 00                	push   $0x0
f01019c4:	57                   	push   %edi
f01019c5:	ff 35 8c fe 32 f0    	pushl  0xf032fe8c
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
f01019eb:	ff 35 8c fe 32 f0    	pushl  0xf032fe8c
f01019f1:	e8 d6 f8 ff ff       	call   f01012cc <page_insert>
f01019f6:	83 c4 20             	add    $0x20,%esp
f01019f9:	85 c0                	test   %eax,%eax
f01019fb:	0f 85 cf 09 00 00    	jne    f01023d0 <mem_init+0x102f>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101a01:	8b 35 8c fe 32 f0    	mov    0xf032fe8c,%esi
	return (pp - pages) << PGSHIFT;
f0101a07:	8b 0d 90 fe 32 f0    	mov    0xf032fe90,%ecx
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
f0101a83:	a1 8c fe 32 f0       	mov    0xf032fe8c,%eax
f0101a88:	e8 cc f0 ff ff       	call   f0100b59 <check_va2pa>
f0101a8d:	89 c2                	mov    %eax,%edx
f0101a8f:	89 d8                	mov    %ebx,%eax
f0101a91:	2b 05 90 fe 32 f0    	sub    0xf032fe90,%eax
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
f0101acd:	ff 35 8c fe 32 f0    	pushl  0xf032fe8c
f0101ad3:	e8 f4 f7 ff ff       	call   f01012cc <page_insert>
f0101ad8:	83 c4 10             	add    $0x10,%esp
f0101adb:	85 c0                	test   %eax,%eax
f0101add:	0f 85 ce 09 00 00    	jne    f01024b1 <mem_init+0x1110>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ae3:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ae8:	a1 8c fe 32 f0       	mov    0xf032fe8c,%eax
f0101aed:	e8 67 f0 ff ff       	call   f0100b59 <check_va2pa>
f0101af2:	89 c2                	mov    %eax,%edx
f0101af4:	89 d8                	mov    %ebx,%eax
f0101af6:	2b 05 90 fe 32 f0    	sub    0xf032fe90,%eax
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
f0101b2a:	8b 0d 8c fe 32 f0    	mov    0xf032fe8c,%ecx
f0101b30:	8b 01                	mov    (%ecx),%eax
f0101b32:	89 c2                	mov    %eax,%edx
f0101b34:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101b3a:	c1 e8 0c             	shr    $0xc,%eax
f0101b3d:	3b 05 88 fe 32 f0    	cmp    0xf032fe88,%eax
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
f0101b7d:	ff 35 8c fe 32 f0    	pushl  0xf032fe8c
f0101b83:	e8 44 f7 ff ff       	call   f01012cc <page_insert>
f0101b88:	83 c4 10             	add    $0x10,%esp
f0101b8b:	85 c0                	test   %eax,%eax
f0101b8d:	0f 85 b0 09 00 00    	jne    f0102543 <mem_init+0x11a2>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b93:	8b 35 8c fe 32 f0    	mov    0xf032fe8c,%esi
f0101b99:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b9e:	89 f0                	mov    %esi,%eax
f0101ba0:	e8 b4 ef ff ff       	call   f0100b59 <check_va2pa>
f0101ba5:	89 c2                	mov    %eax,%edx
	return (pp - pages) << PGSHIFT;
f0101ba7:	89 d8                	mov    %ebx,%eax
f0101ba9:	2b 05 90 fe 32 f0    	sub    0xf032fe90,%eax
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
f0101be4:	a1 8c fe 32 f0       	mov    0xf032fe8c,%eax
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
f0101c15:	ff 35 8c fe 32 f0    	pushl  0xf032fe8c
f0101c1b:	e8 c3 f4 ff ff       	call   f01010e3 <pgdir_walk>
f0101c20:	83 c4 10             	add    $0x10,%esp
f0101c23:	f6 00 02             	testb  $0x2,(%eax)
f0101c26:	0f 84 ad 09 00 00    	je     f01025d9 <mem_init+0x1238>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c2c:	83 ec 04             	sub    $0x4,%esp
f0101c2f:	6a 00                	push   $0x0
f0101c31:	68 00 10 00 00       	push   $0x1000
f0101c36:	ff 35 8c fe 32 f0    	pushl  0xf032fe8c
f0101c3c:	e8 a2 f4 ff ff       	call   f01010e3 <pgdir_walk>
f0101c41:	83 c4 10             	add    $0x10,%esp
f0101c44:	f6 00 04             	testb  $0x4,(%eax)
f0101c47:	0f 85 a5 09 00 00    	jne    f01025f2 <mem_init+0x1251>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101c4d:	6a 02                	push   $0x2
f0101c4f:	68 00 00 40 00       	push   $0x400000
f0101c54:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101c57:	ff 35 8c fe 32 f0    	pushl  0xf032fe8c
f0101c5d:	e8 6a f6 ff ff       	call   f01012cc <page_insert>
f0101c62:	83 c4 10             	add    $0x10,%esp
f0101c65:	85 c0                	test   %eax,%eax
f0101c67:	0f 89 9e 09 00 00    	jns    f010260b <mem_init+0x126a>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101c6d:	6a 02                	push   $0x2
f0101c6f:	68 00 10 00 00       	push   $0x1000
f0101c74:	57                   	push   %edi
f0101c75:	ff 35 8c fe 32 f0    	pushl  0xf032fe8c
f0101c7b:	e8 4c f6 ff ff       	call   f01012cc <page_insert>
f0101c80:	83 c4 10             	add    $0x10,%esp
f0101c83:	85 c0                	test   %eax,%eax
f0101c85:	0f 85 99 09 00 00    	jne    f0102624 <mem_init+0x1283>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c8b:	83 ec 04             	sub    $0x4,%esp
f0101c8e:	6a 00                	push   $0x0
f0101c90:	68 00 10 00 00       	push   $0x1000
f0101c95:	ff 35 8c fe 32 f0    	pushl  0xf032fe8c
f0101c9b:	e8 43 f4 ff ff       	call   f01010e3 <pgdir_walk>
f0101ca0:	83 c4 10             	add    $0x10,%esp
f0101ca3:	f6 00 04             	testb  $0x4,(%eax)
f0101ca6:	0f 85 91 09 00 00    	jne    f010263d <mem_init+0x129c>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101cac:	a1 8c fe 32 f0       	mov    0xf032fe8c,%eax
f0101cb1:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101cb4:	ba 00 00 00 00       	mov    $0x0,%edx
f0101cb9:	e8 9b ee ff ff       	call   f0100b59 <check_va2pa>
f0101cbe:	89 fe                	mov    %edi,%esi
f0101cc0:	2b 35 90 fe 32 f0    	sub    0xf032fe90,%esi
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
f0101d21:	ff 35 8c fe 32 f0    	pushl  0xf032fe8c
f0101d27:	e8 52 f5 ff ff       	call   f010127e <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d2c:	8b 35 8c fe 32 f0    	mov    0xf032fe8c,%esi
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
f0101d5a:	2b 05 90 fe 32 f0    	sub    0xf032fe90,%eax
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
f0101db9:	ff 35 8c fe 32 f0    	pushl  0xf032fe8c
f0101dbf:	e8 ba f4 ff ff       	call   f010127e <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101dc4:	8b 35 8c fe 32 f0    	mov    0xf032fe8c,%esi
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
f0101e3f:	8b 0d 8c fe 32 f0    	mov    0xf032fe8c,%ecx
f0101e45:	8b 11                	mov    (%ecx),%edx
f0101e47:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101e4d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e50:	2b 05 90 fe 32 f0    	sub    0xf032fe90,%eax
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
f0101e94:	ff 35 8c fe 32 f0    	pushl  0xf032fe8c
f0101e9a:	e8 44 f2 ff ff       	call   f01010e3 <pgdir_walk>
f0101e9f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101ea2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101ea5:	8b 0d 8c fe 32 f0    	mov    0xf032fe8c,%ecx
f0101eab:	8b 41 04             	mov    0x4(%ecx),%eax
f0101eae:	89 c6                	mov    %eax,%esi
f0101eb0:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f0101eb6:	8b 15 88 fe 32 f0    	mov    0xf032fe88,%edx
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
f0101ee9:	2b 05 90 fe 32 f0    	sub    0xf032fe90,%eax
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
f0101f18:	e8 a7 3e 00 00       	call   f0105dc4 <memset>
	page_free(pp0);
f0101f1d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101f20:	89 34 24             	mov    %esi,(%esp)
f0101f23:	e8 4f f1 ff ff       	call   f0101077 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101f28:	83 c4 0c             	add    $0xc,%esp
f0101f2b:	6a 01                	push   $0x1
f0101f2d:	6a 00                	push   $0x0
f0101f2f:	ff 35 8c fe 32 f0    	pushl  0xf032fe8c
f0101f35:	e8 a9 f1 ff ff       	call   f01010e3 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101f3a:	89 f0                	mov    %esi,%eax
f0101f3c:	2b 05 90 fe 32 f0    	sub    0xf032fe90,%eax
f0101f42:	c1 f8 03             	sar    $0x3,%eax
f0101f45:	89 c2                	mov    %eax,%edx
f0101f47:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101f4a:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101f4f:	83 c4 10             	add    $0x10,%esp
f0101f52:	3b 05 88 fe 32 f0    	cmp    0xf032fe88,%eax
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
f0101f7d:	a1 8c fe 32 f0       	mov    0xf032fe8c,%eax
f0101f82:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101f88:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f8b:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101f91:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101f94:	89 0d 40 f2 32 f0    	mov    %ecx,0xf032f240

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
f010202b:	8b 3d 8c fe 32 f0    	mov    0xf032fe8c,%edi
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
f01020a4:	ff 35 8c fe 32 f0    	pushl  0xf032fe8c
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
f01020c5:	ff 35 8c fe 32 f0    	pushl  0xf032fe8c
f01020cb:	e8 13 f0 ff ff       	call   f01010e3 <pgdir_walk>
f01020d0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f01020d6:	83 c4 0c             	add    $0xc,%esp
f01020d9:	6a 00                	push   $0x0
f01020db:	ff 75 d4             	pushl  -0x2c(%ebp)
f01020de:	ff 35 8c fe 32 f0    	pushl  0xf032fe8c
f01020e4:	e8 fa ef ff ff       	call   f01010e3 <pgdir_walk>
f01020e9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f01020ef:	83 c4 0c             	add    $0xc,%esp
f01020f2:	6a 00                	push   $0x0
f01020f4:	56                   	push   %esi
f01020f5:	ff 35 8c fe 32 f0    	pushl  0xf032fe8c
f01020fb:	e8 e3 ef ff ff       	call   f01010e3 <pgdir_walk>
f0102100:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102106:	c7 04 24 29 7c 10 f0 	movl   $0xf0107c29,(%esp)
f010210d:	e8 2c 1a 00 00       	call   f0103b3e <cprintf>
    size_t pages_size = ROUNDUP(sizeof(struct PageInfo) * npages, PGSIZE);
f0102112:	a1 88 fe 32 f0       	mov    0xf032fe88,%eax
f0102117:	8d 1c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ebx
f010211e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    boot_map_region(kern_pgdir, UPAGES, pages_size,
f0102124:	a1 90 fe 32 f0       	mov    0xf032fe90,%eax
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
f0102149:	a1 8c fe 32 f0       	mov    0xf032fe8c,%eax
f010214e:	e8 20 f0 ff ff       	call   f0101173 <boot_map_region>
    boot_map_region(kern_pgdir, (uintptr_t)pages, pages_size,
f0102153:	8b 15 90 fe 32 f0    	mov    0xf032fe90,%edx
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
f0102176:	a1 8c fe 32 f0       	mov    0xf032fe8c,%eax
f010217b:	e8 f3 ef ff ff       	call   f0101173 <boot_map_region>
    boot_map_region(kern_pgdir, UENVS, alloc_size,
f0102180:	a1 44 f2 32 f0       	mov    0xf032f244,%eax
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
f01021a8:	a1 8c fe 32 f0       	mov    0xf032fe8c,%eax
f01021ad:	e8 c1 ef ff ff       	call   f0101173 <boot_map_region>
    boot_map_region(kern_pgdir, (uintptr_t)envs, alloc_size,
f01021b2:	8b 15 44 f2 32 f0    	mov    0xf032f244,%edx
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
f01021d8:	a1 8c fe 32 f0       	mov    0xf032fe8c,%eax
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
f0102209:	a1 8c fe 32 f0       	mov    0xf032fe8c,%eax
f010220e:	e8 60 ef ff ff       	call   f0101173 <boot_map_region>
    boot_map_region(kern_pgdir, KERNBASE, -KERNBASE,
f0102213:	83 c4 08             	add    $0x8,%esp
f0102216:	6a 03                	push   $0x3
f0102218:	6a 00                	push   $0x0
f010221a:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f010221f:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102224:	a1 8c fe 32 f0       	mov    0xf032fe8c,%eax
f0102229:	e8 45 ef ff ff       	call   f0101173 <boot_map_region>
f010222e:	c7 45 d0 00 10 33 f0 	movl   $0xf0331000,-0x30(%ebp)
f0102235:	83 c4 10             	add    $0x10,%esp
f0102238:	bb 00 10 33 f0       	mov    $0xf0331000,%ebx
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
f0102261:	a1 8c fe 32 f0       	mov    0xf032fe8c,%eax
f0102266:	e8 08 ef ff ff       	call   f0101173 <boot_map_region>
f010226b:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102271:	81 ee 00 00 01 00    	sub    $0x10000,%esi
    for (int i = 0; i < NCPU; ++i) {
f0102277:	83 c4 10             	add    $0x10,%esp
f010227a:	81 fb 00 10 37 f0    	cmp    $0xf0371000,%ebx
f0102280:	75 c0                	jne    f0102242 <mem_init+0xea1>
	pgdir = kern_pgdir;
f0102282:	a1 8c fe 32 f0       	mov    0xf032fe8c,%eax
f0102287:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010228a:	a1 88 fe 32 f0       	mov    0xf032fe88,%eax
f010228f:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0102292:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102299:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010229e:	89 45 cc             	mov    %eax,-0x34(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01022a1:	8b 35 90 fe 32 f0    	mov    0xf032fe90,%esi
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
f01022ef:	68 40 7b 10 f0       	push   $0xf0107b40
f01022f4:	68 79 79 10 f0       	push   $0xf0107979
f01022f9:	68 84 03 00 00       	push   $0x384
f01022fe:	68 45 79 10 f0       	push   $0xf0107945
f0102303:	e8 38 dd ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0102308:	68 4e 7a 10 f0       	push   $0xf0107a4e
f010230d:	68 79 79 10 f0       	push   $0xf0107979
f0102312:	68 eb 03 00 00       	push   $0x3eb
f0102317:	68 45 79 10 f0       	push   $0xf0107945
f010231c:	e8 1f dd ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102321:	68 64 7a 10 f0       	push   $0xf0107a64
f0102326:	68 79 79 10 f0       	push   $0xf0107979
f010232b:	68 ec 03 00 00       	push   $0x3ec
f0102330:	68 45 79 10 f0       	push   $0xf0107945
f0102335:	e8 06 dd ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010233a:	68 7a 7a 10 f0       	push   $0xf0107a7a
f010233f:	68 79 79 10 f0       	push   $0xf0107979
f0102344:	68 ed 03 00 00       	push   $0x3ed
f0102349:	68 45 79 10 f0       	push   $0xf0107945
f010234e:	e8 ed dc ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0102353:	68 90 7a 10 f0       	push   $0xf0107a90
f0102358:	68 79 79 10 f0       	push   $0xf0107979
f010235d:	68 f0 03 00 00       	push   $0x3f0
f0102362:	68 45 79 10 f0       	push   $0xf0107945
f0102367:	e8 d4 dc ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010236c:	68 68 71 10 f0       	push   $0xf0107168
f0102371:	68 79 79 10 f0       	push   $0xf0107979
f0102376:	68 f1 03 00 00       	push   $0x3f1
f010237b:	68 45 79 10 f0       	push   $0xf0107945
f0102380:	e8 bb dc ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102385:	68 f9 7a 10 f0       	push   $0xf0107af9
f010238a:	68 79 79 10 f0       	push   $0xf0107979
f010238f:	68 f8 03 00 00       	push   $0x3f8
f0102394:	68 45 79 10 f0       	push   $0xf0107945
f0102399:	e8 a2 dc ff ff       	call   f0100040 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010239e:	68 a8 71 10 f0       	push   $0xf01071a8
f01023a3:	68 79 79 10 f0       	push   $0xf0107979
f01023a8:	68 fb 03 00 00       	push   $0x3fb
f01023ad:	68 45 79 10 f0       	push   $0xf0107945
f01023b2:	e8 89 dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01023b7:	68 e0 71 10 f0       	push   $0xf01071e0
f01023bc:	68 79 79 10 f0       	push   $0xf0107979
f01023c1:	68 fe 03 00 00       	push   $0x3fe
f01023c6:	68 45 79 10 f0       	push   $0xf0107945
f01023cb:	e8 70 dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01023d0:	68 10 72 10 f0       	push   $0xf0107210
f01023d5:	68 79 79 10 f0       	push   $0xf0107979
f01023da:	68 02 04 00 00       	push   $0x402
f01023df:	68 45 79 10 f0       	push   $0xf0107945
f01023e4:	e8 57 dc ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01023e9:	68 40 72 10 f0       	push   $0xf0107240
f01023ee:	68 79 79 10 f0       	push   $0xf0107979
f01023f3:	68 03 04 00 00       	push   $0x403
f01023f8:	68 45 79 10 f0       	push   $0xf0107945
f01023fd:	e8 3e dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102402:	68 68 72 10 f0       	push   $0xf0107268
f0102407:	68 79 79 10 f0       	push   $0xf0107979
f010240c:	68 04 04 00 00       	push   $0x404
f0102411:	68 45 79 10 f0       	push   $0xf0107945
f0102416:	e8 25 dc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010241b:	68 4b 7b 10 f0       	push   $0xf0107b4b
f0102420:	68 79 79 10 f0       	push   $0xf0107979
f0102425:	68 05 04 00 00       	push   $0x405
f010242a:	68 45 79 10 f0       	push   $0xf0107945
f010242f:	e8 0c dc ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102434:	68 5c 7b 10 f0       	push   $0xf0107b5c
f0102439:	68 79 79 10 f0       	push   $0xf0107979
f010243e:	68 06 04 00 00       	push   $0x406
f0102443:	68 45 79 10 f0       	push   $0xf0107945
f0102448:	e8 f3 db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010244d:	68 98 72 10 f0       	push   $0xf0107298
f0102452:	68 79 79 10 f0       	push   $0xf0107979
f0102457:	68 09 04 00 00       	push   $0x409
f010245c:	68 45 79 10 f0       	push   $0xf0107945
f0102461:	e8 da db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102466:	68 d4 72 10 f0       	push   $0xf01072d4
f010246b:	68 79 79 10 f0       	push   $0xf0107979
f0102470:	68 0a 04 00 00       	push   $0x40a
f0102475:	68 45 79 10 f0       	push   $0xf0107945
f010247a:	e8 c1 db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010247f:	68 6d 7b 10 f0       	push   $0xf0107b6d
f0102484:	68 79 79 10 f0       	push   $0xf0107979
f0102489:	68 0b 04 00 00       	push   $0x40b
f010248e:	68 45 79 10 f0       	push   $0xf0107945
f0102493:	e8 a8 db ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102498:	68 f9 7a 10 f0       	push   $0xf0107af9
f010249d:	68 79 79 10 f0       	push   $0xf0107979
f01024a2:	68 0e 04 00 00       	push   $0x40e
f01024a7:	68 45 79 10 f0       	push   $0xf0107945
f01024ac:	e8 8f db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01024b1:	68 98 72 10 f0       	push   $0xf0107298
f01024b6:	68 79 79 10 f0       	push   $0xf0107979
f01024bb:	68 11 04 00 00       	push   $0x411
f01024c0:	68 45 79 10 f0       	push   $0xf0107945
f01024c5:	e8 76 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01024ca:	68 d4 72 10 f0       	push   $0xf01072d4
f01024cf:	68 79 79 10 f0       	push   $0xf0107979
f01024d4:	68 12 04 00 00       	push   $0x412
f01024d9:	68 45 79 10 f0       	push   $0xf0107945
f01024de:	e8 5d db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01024e3:	68 6d 7b 10 f0       	push   $0xf0107b6d
f01024e8:	68 79 79 10 f0       	push   $0xf0107979
f01024ed:	68 13 04 00 00       	push   $0x413
f01024f2:	68 45 79 10 f0       	push   $0xf0107945
f01024f7:	e8 44 db ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01024fc:	68 f9 7a 10 f0       	push   $0xf0107af9
f0102501:	68 79 79 10 f0       	push   $0xf0107979
f0102506:	68 17 04 00 00       	push   $0x417
f010250b:	68 45 79 10 f0       	push   $0xf0107945
f0102510:	e8 2b db ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102515:	52                   	push   %edx
f0102516:	68 84 6a 10 f0       	push   $0xf0106a84
f010251b:	68 1a 04 00 00       	push   $0x41a
f0102520:	68 45 79 10 f0       	push   $0xf0107945
f0102525:	e8 16 db ff ff       	call   f0100040 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010252a:	68 04 73 10 f0       	push   $0xf0107304
f010252f:	68 79 79 10 f0       	push   $0xf0107979
f0102534:	68 1b 04 00 00       	push   $0x41b
f0102539:	68 45 79 10 f0       	push   $0xf0107945
f010253e:	e8 fd da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102543:	68 44 73 10 f0       	push   $0xf0107344
f0102548:	68 79 79 10 f0       	push   $0xf0107979
f010254d:	68 1e 04 00 00       	push   $0x41e
f0102552:	68 45 79 10 f0       	push   $0xf0107945
f0102557:	e8 e4 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010255c:	68 d4 72 10 f0       	push   $0xf01072d4
f0102561:	68 79 79 10 f0       	push   $0xf0107979
f0102566:	68 1f 04 00 00       	push   $0x41f
f010256b:	68 45 79 10 f0       	push   $0xf0107945
f0102570:	e8 cb da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102575:	68 6d 7b 10 f0       	push   $0xf0107b6d
f010257a:	68 79 79 10 f0       	push   $0xf0107979
f010257f:	68 20 04 00 00       	push   $0x420
f0102584:	68 45 79 10 f0       	push   $0xf0107945
f0102589:	e8 b2 da ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010258e:	68 84 73 10 f0       	push   $0xf0107384
f0102593:	68 79 79 10 f0       	push   $0xf0107979
f0102598:	68 21 04 00 00       	push   $0x421
f010259d:	68 45 79 10 f0       	push   $0xf0107945
f01025a2:	e8 99 da ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01025a7:	68 7e 7b 10 f0       	push   $0xf0107b7e
f01025ac:	68 79 79 10 f0       	push   $0xf0107979
f01025b1:	68 22 04 00 00       	push   $0x422
f01025b6:	68 45 79 10 f0       	push   $0xf0107945
f01025bb:	e8 80 da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01025c0:	68 98 72 10 f0       	push   $0xf0107298
f01025c5:	68 79 79 10 f0       	push   $0xf0107979
f01025ca:	68 25 04 00 00       	push   $0x425
f01025cf:	68 45 79 10 f0       	push   $0xf0107945
f01025d4:	e8 67 da ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01025d9:	68 b8 73 10 f0       	push   $0xf01073b8
f01025de:	68 79 79 10 f0       	push   $0xf0107979
f01025e3:	68 26 04 00 00       	push   $0x426
f01025e8:	68 45 79 10 f0       	push   $0xf0107945
f01025ed:	e8 4e da ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01025f2:	68 ec 73 10 f0       	push   $0xf01073ec
f01025f7:	68 79 79 10 f0       	push   $0xf0107979
f01025fc:	68 27 04 00 00       	push   $0x427
f0102601:	68 45 79 10 f0       	push   $0xf0107945
f0102606:	e8 35 da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010260b:	68 24 74 10 f0       	push   $0xf0107424
f0102610:	68 79 79 10 f0       	push   $0xf0107979
f0102615:	68 2a 04 00 00       	push   $0x42a
f010261a:	68 45 79 10 f0       	push   $0xf0107945
f010261f:	e8 1c da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102624:	68 5c 74 10 f0       	push   $0xf010745c
f0102629:	68 79 79 10 f0       	push   $0xf0107979
f010262e:	68 2d 04 00 00       	push   $0x42d
f0102633:	68 45 79 10 f0       	push   $0xf0107945
f0102638:	e8 03 da ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010263d:	68 ec 73 10 f0       	push   $0xf01073ec
f0102642:	68 79 79 10 f0       	push   $0xf0107979
f0102647:	68 2e 04 00 00       	push   $0x42e
f010264c:	68 45 79 10 f0       	push   $0xf0107945
f0102651:	e8 ea d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102656:	68 98 74 10 f0       	push   $0xf0107498
f010265b:	68 79 79 10 f0       	push   $0xf0107979
f0102660:	68 31 04 00 00       	push   $0x431
f0102665:	68 45 79 10 f0       	push   $0xf0107945
f010266a:	e8 d1 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010266f:	68 c4 74 10 f0       	push   $0xf01074c4
f0102674:	68 79 79 10 f0       	push   $0xf0107979
f0102679:	68 32 04 00 00       	push   $0x432
f010267e:	68 45 79 10 f0       	push   $0xf0107945
f0102683:	e8 b8 d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 2);
f0102688:	68 94 7b 10 f0       	push   $0xf0107b94
f010268d:	68 79 79 10 f0       	push   $0xf0107979
f0102692:	68 34 04 00 00       	push   $0x434
f0102697:	68 45 79 10 f0       	push   $0xf0107945
f010269c:	e8 9f d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01026a1:	68 a5 7b 10 f0       	push   $0xf0107ba5
f01026a6:	68 79 79 10 f0       	push   $0xf0107979
f01026ab:	68 35 04 00 00       	push   $0x435
f01026b0:	68 45 79 10 f0       	push   $0xf0107945
f01026b5:	e8 86 d9 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f01026ba:	68 f4 74 10 f0       	push   $0xf01074f4
f01026bf:	68 79 79 10 f0       	push   $0xf0107979
f01026c4:	68 38 04 00 00       	push   $0x438
f01026c9:	68 45 79 10 f0       	push   $0xf0107945
f01026ce:	e8 6d d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01026d3:	68 18 75 10 f0       	push   $0xf0107518
f01026d8:	68 79 79 10 f0       	push   $0xf0107979
f01026dd:	68 3c 04 00 00       	push   $0x43c
f01026e2:	68 45 79 10 f0       	push   $0xf0107945
f01026e7:	e8 54 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01026ec:	68 c4 74 10 f0       	push   $0xf01074c4
f01026f1:	68 79 79 10 f0       	push   $0xf0107979
f01026f6:	68 3d 04 00 00       	push   $0x43d
f01026fb:	68 45 79 10 f0       	push   $0xf0107945
f0102700:	e8 3b d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102705:	68 4b 7b 10 f0       	push   $0xf0107b4b
f010270a:	68 79 79 10 f0       	push   $0xf0107979
f010270f:	68 3e 04 00 00       	push   $0x43e
f0102714:	68 45 79 10 f0       	push   $0xf0107945
f0102719:	e8 22 d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010271e:	68 a5 7b 10 f0       	push   $0xf0107ba5
f0102723:	68 79 79 10 f0       	push   $0xf0107979
f0102728:	68 3f 04 00 00       	push   $0x43f
f010272d:	68 45 79 10 f0       	push   $0xf0107945
f0102732:	e8 09 d9 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102737:	68 3c 75 10 f0       	push   $0xf010753c
f010273c:	68 79 79 10 f0       	push   $0xf0107979
f0102741:	68 42 04 00 00       	push   $0x442
f0102746:	68 45 79 10 f0       	push   $0xf0107945
f010274b:	e8 f0 d8 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0102750:	68 b6 7b 10 f0       	push   $0xf0107bb6
f0102755:	68 79 79 10 f0       	push   $0xf0107979
f010275a:	68 43 04 00 00       	push   $0x443
f010275f:	68 45 79 10 f0       	push   $0xf0107945
f0102764:	e8 d7 d8 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102769:	68 c2 7b 10 f0       	push   $0xf0107bc2
f010276e:	68 79 79 10 f0       	push   $0xf0107979
f0102773:	68 44 04 00 00       	push   $0x444
f0102778:	68 45 79 10 f0       	push   $0xf0107945
f010277d:	e8 be d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102782:	68 18 75 10 f0       	push   $0xf0107518
f0102787:	68 79 79 10 f0       	push   $0xf0107979
f010278c:	68 48 04 00 00       	push   $0x448
f0102791:	68 45 79 10 f0       	push   $0xf0107945
f0102796:	e8 a5 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010279b:	68 74 75 10 f0       	push   $0xf0107574
f01027a0:	68 79 79 10 f0       	push   $0xf0107979
f01027a5:	68 49 04 00 00       	push   $0x449
f01027aa:	68 45 79 10 f0       	push   $0xf0107945
f01027af:	e8 8c d8 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01027b4:	68 d7 7b 10 f0       	push   $0xf0107bd7
f01027b9:	68 79 79 10 f0       	push   $0xf0107979
f01027be:	68 4a 04 00 00       	push   $0x44a
f01027c3:	68 45 79 10 f0       	push   $0xf0107945
f01027c8:	e8 73 d8 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01027cd:	68 a5 7b 10 f0       	push   $0xf0107ba5
f01027d2:	68 79 79 10 f0       	push   $0xf0107979
f01027d7:	68 4b 04 00 00       	push   $0x44b
f01027dc:	68 45 79 10 f0       	push   $0xf0107945
f01027e1:	e8 5a d8 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f01027e6:	68 9c 75 10 f0       	push   $0xf010759c
f01027eb:	68 79 79 10 f0       	push   $0xf0107979
f01027f0:	68 4e 04 00 00       	push   $0x44e
f01027f5:	68 45 79 10 f0       	push   $0xf0107945
f01027fa:	e8 41 d8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01027ff:	68 f9 7a 10 f0       	push   $0xf0107af9
f0102804:	68 79 79 10 f0       	push   $0xf0107979
f0102809:	68 51 04 00 00       	push   $0x451
f010280e:	68 45 79 10 f0       	push   $0xf0107945
f0102813:	e8 28 d8 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102818:	68 40 72 10 f0       	push   $0xf0107240
f010281d:	68 79 79 10 f0       	push   $0xf0107979
f0102822:	68 54 04 00 00       	push   $0x454
f0102827:	68 45 79 10 f0       	push   $0xf0107945
f010282c:	e8 0f d8 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102831:	68 5c 7b 10 f0       	push   $0xf0107b5c
f0102836:	68 79 79 10 f0       	push   $0xf0107979
f010283b:	68 56 04 00 00       	push   $0x456
f0102840:	68 45 79 10 f0       	push   $0xf0107945
f0102845:	e8 f6 d7 ff ff       	call   f0100040 <_panic>
f010284a:	56                   	push   %esi
f010284b:	68 84 6a 10 f0       	push   $0xf0106a84
f0102850:	68 5d 04 00 00       	push   $0x45d
f0102855:	68 45 79 10 f0       	push   $0xf0107945
f010285a:	e8 e1 d7 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010285f:	68 e8 7b 10 f0       	push   $0xf0107be8
f0102864:	68 79 79 10 f0       	push   $0xf0107979
f0102869:	68 5e 04 00 00       	push   $0x45e
f010286e:	68 45 79 10 f0       	push   $0xf0107945
f0102873:	e8 c8 d7 ff ff       	call   f0100040 <_panic>
f0102878:	51                   	push   %ecx
f0102879:	68 84 6a 10 f0       	push   $0xf0106a84
f010287e:	6a 58                	push   $0x58
f0102880:	68 5f 79 10 f0       	push   $0xf010795f
f0102885:	e8 b6 d7 ff ff       	call   f0100040 <_panic>
f010288a:	52                   	push   %edx
f010288b:	68 84 6a 10 f0       	push   $0xf0106a84
f0102890:	6a 58                	push   $0x58
f0102892:	68 5f 79 10 f0       	push   $0xf010795f
f0102897:	e8 a4 d7 ff ff       	call   f0100040 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f010289c:	68 00 7c 10 f0       	push   $0xf0107c00
f01028a1:	68 79 79 10 f0       	push   $0xf0107979
f01028a6:	68 68 04 00 00       	push   $0x468
f01028ab:	68 45 79 10 f0       	push   $0xf0107945
f01028b0:	e8 8b d7 ff ff       	call   f0100040 <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f01028b5:	68 c0 75 10 f0       	push   $0xf01075c0
f01028ba:	68 79 79 10 f0       	push   $0xf0107979
f01028bf:	68 78 04 00 00       	push   $0x478
f01028c4:	68 45 79 10 f0       	push   $0xf0107945
f01028c9:	e8 72 d7 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f01028ce:	68 e8 75 10 f0       	push   $0xf01075e8
f01028d3:	68 79 79 10 f0       	push   $0xf0107979
f01028d8:	68 79 04 00 00       	push   $0x479
f01028dd:	68 45 79 10 f0       	push   $0xf0107945
f01028e2:	e8 59 d7 ff ff       	call   f0100040 <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01028e7:	68 10 76 10 f0       	push   $0xf0107610
f01028ec:	68 79 79 10 f0       	push   $0xf0107979
f01028f1:	68 7b 04 00 00       	push   $0x47b
f01028f6:	68 45 79 10 f0       	push   $0xf0107945
f01028fb:	e8 40 d7 ff ff       	call   f0100040 <_panic>
	assert(mm1 + 8192 <= mm2);
f0102900:	68 17 7c 10 f0       	push   $0xf0107c17
f0102905:	68 79 79 10 f0       	push   $0xf0107979
f010290a:	68 7d 04 00 00       	push   $0x47d
f010290f:	68 45 79 10 f0       	push   $0xf0107945
f0102914:	e8 27 d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102919:	68 38 76 10 f0       	push   $0xf0107638
f010291e:	68 79 79 10 f0       	push   $0xf0107979
f0102923:	68 7f 04 00 00       	push   $0x47f
f0102928:	68 45 79 10 f0       	push   $0xf0107945
f010292d:	e8 0e d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102932:	68 5c 76 10 f0       	push   $0xf010765c
f0102937:	68 79 79 10 f0       	push   $0xf0107979
f010293c:	68 80 04 00 00       	push   $0x480
f0102941:	68 45 79 10 f0       	push   $0xf0107945
f0102946:	e8 f5 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f010294b:	68 8c 76 10 f0       	push   $0xf010768c
f0102950:	68 79 79 10 f0       	push   $0xf0107979
f0102955:	68 81 04 00 00       	push   $0x481
f010295a:	68 45 79 10 f0       	push   $0xf0107945
f010295f:	e8 dc d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102964:	68 b0 76 10 f0       	push   $0xf01076b0
f0102969:	68 79 79 10 f0       	push   $0xf0107979
f010296e:	68 82 04 00 00       	push   $0x482
f0102973:	68 45 79 10 f0       	push   $0xf0107945
f0102978:	e8 c3 d6 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f010297d:	68 dc 76 10 f0       	push   $0xf01076dc
f0102982:	68 79 79 10 f0       	push   $0xf0107979
f0102987:	68 84 04 00 00       	push   $0x484
f010298c:	68 45 79 10 f0       	push   $0xf0107945
f0102991:	e8 aa d6 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102996:	68 20 77 10 f0       	push   $0xf0107720
f010299b:	68 79 79 10 f0       	push   $0xf0107979
f01029a0:	68 85 04 00 00       	push   $0x485
f01029a5:	68 45 79 10 f0       	push   $0xf0107945
f01029aa:	e8 91 d6 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029af:	50                   	push   %eax
f01029b0:	68 a8 6a 10 f0       	push   $0xf0106aa8
f01029b5:	68 d1 00 00 00       	push   $0xd1
f01029ba:	68 45 79 10 f0       	push   $0xf0107945
f01029bf:	e8 7c d6 ff ff       	call   f0100040 <_panic>
f01029c4:	52                   	push   %edx
f01029c5:	68 a8 6a 10 f0       	push   $0xf0106aa8
f01029ca:	68 d4 00 00 00       	push   $0xd4
f01029cf:	68 45 79 10 f0       	push   $0xf0107945
f01029d4:	e8 67 d6 ff ff       	call   f0100040 <_panic>
f01029d9:	50                   	push   %eax
f01029da:	68 a8 6a 10 f0       	push   $0xf0106aa8
f01029df:	68 e0 00 00 00       	push   $0xe0
f01029e4:	68 45 79 10 f0       	push   $0xf0107945
f01029e9:	e8 52 d6 ff ff       	call   f0100040 <_panic>
f01029ee:	52                   	push   %edx
f01029ef:	68 a8 6a 10 f0       	push   $0xf0106aa8
f01029f4:	68 e2 00 00 00       	push   $0xe2
f01029f9:	68 45 79 10 f0       	push   $0xf0107945
f01029fe:	e8 3d d6 ff ff       	call   f0100040 <_panic>
f0102a03:	50                   	push   %eax
f0102a04:	68 a8 6a 10 f0       	push   $0xf0106aa8
f0102a09:	68 f0 00 00 00       	push   $0xf0
f0102a0e:	68 45 79 10 f0       	push   $0xf0107945
f0102a13:	e8 28 d6 ff ff       	call   f0100040 <_panic>
f0102a18:	53                   	push   %ebx
f0102a19:	68 a8 6a 10 f0       	push   $0xf0106aa8
f0102a1e:	68 34 01 00 00       	push   $0x134
f0102a23:	68 45 79 10 f0       	push   $0xf0107945
f0102a28:	e8 13 d6 ff ff       	call   f0100040 <_panic>
f0102a2d:	56                   	push   %esi
f0102a2e:	68 a8 6a 10 f0       	push   $0xf0106aa8
f0102a33:	68 9c 03 00 00       	push   $0x39c
f0102a38:	68 45 79 10 f0       	push   $0xf0107945
f0102a3d:	e8 fe d5 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102a42:	68 54 77 10 f0       	push   $0xf0107754
f0102a47:	68 79 79 10 f0       	push   $0xf0107979
f0102a4c:	68 9c 03 00 00       	push   $0x39c
f0102a51:	68 45 79 10 f0       	push   $0xf0107945
f0102a56:	e8 e5 d5 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102a5b:	a1 44 f2 32 f0       	mov    0xf032f244,%eax
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
f0102ac2:	68 a8 6a 10 f0       	push   $0xf0106aa8
f0102ac7:	68 a1 03 00 00       	push   $0x3a1
f0102acc:	68 45 79 10 f0       	push   $0xf0107945
f0102ad1:	e8 6a d5 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102ad6:	68 88 77 10 f0       	push   $0xf0107788
f0102adb:	68 79 79 10 f0       	push   $0xf0107979
f0102ae0:	68 a1 03 00 00       	push   $0x3a1
f0102ae5:	68 45 79 10 f0       	push   $0xf0107945
f0102aea:	e8 51 d5 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102aef:	68 bc 77 10 f0       	push   $0xf01077bc
f0102af4:	68 79 79 10 f0       	push   $0xf0107979
f0102af9:	68 a5 03 00 00       	push   $0x3a5
f0102afe:	68 45 79 10 f0       	push   $0xf0107945
f0102b03:	e8 38 d5 ff ff       	call   f0100040 <_panic>
f0102b08:	c7 45 cc 00 10 34 00 	movl   $0x341000,-0x34(%ebp)
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
f0102b91:	3d 00 10 37 f0       	cmp    $0xf0371000,%eax
f0102b96:	0f 85 7b ff ff ff    	jne    f0102b17 <mem_init+0x1776>
f0102b9c:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0102b9f:	e9 84 00 00 00       	jmp    f0102c28 <mem_init+0x1887>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ba4:	ff 75 bc             	pushl  -0x44(%ebp)
f0102ba7:	68 a8 6a 10 f0       	push   $0xf0106aa8
f0102bac:	68 ae 03 00 00       	push   $0x3ae
f0102bb1:	68 45 79 10 f0       	push   $0xf0107945
f0102bb6:	e8 85 d4 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102bbb:	68 e4 77 10 f0       	push   $0xf01077e4
f0102bc0:	68 79 79 10 f0       	push   $0xf0107979
f0102bc5:	68 ad 03 00 00       	push   $0x3ad
f0102bca:	68 45 79 10 f0       	push   $0xf0107945
f0102bcf:	e8 6c d4 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102bd4:	68 2c 78 10 f0       	push   $0xf010782c
f0102bd9:	68 79 79 10 f0       	push   $0xf0107979
f0102bde:	68 b0 03 00 00       	push   $0x3b0
f0102be3:	68 45 79 10 f0       	push   $0xf0107945
f0102be8:	e8 53 d4 ff ff       	call   f0100040 <_panic>
			assert(pgdir[i] & PTE_P);
f0102bed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102bf0:	f6 04 b8 01          	testb  $0x1,(%eax,%edi,4)
f0102bf4:	75 4e                	jne    f0102c44 <mem_init+0x18a3>
f0102bf6:	68 42 7c 10 f0       	push   $0xf0107c42
f0102bfb:	68 79 79 10 f0       	push   $0xf0107979
f0102c00:	68 bb 03 00 00       	push   $0x3bb
f0102c05:	68 45 79 10 f0       	push   $0xf0107945
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
f0102c49:	68 42 7c 10 f0       	push   $0xf0107c42
f0102c4e:	68 79 79 10 f0       	push   $0xf0107979
f0102c53:	68 bf 03 00 00       	push   $0x3bf
f0102c58:	68 45 79 10 f0       	push   $0xf0107945
f0102c5d:	e8 de d3 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102c62:	68 53 7c 10 f0       	push   $0xf0107c53
f0102c67:	68 79 79 10 f0       	push   $0xf0107979
f0102c6c:	68 c0 03 00 00       	push   $0x3c0
f0102c71:	68 45 79 10 f0       	push   $0xf0107945
f0102c76:	e8 c5 d3 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] == 0);
f0102c7b:	68 64 7c 10 f0       	push   $0xf0107c64
f0102c80:	68 79 79 10 f0       	push   $0xf0107979
f0102c85:	68 c2 03 00 00       	push   $0x3c2
f0102c8a:	68 45 79 10 f0       	push   $0xf0107945
f0102c8f:	e8 ac d3 ff ff       	call   f0100040 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102c94:	83 ec 0c             	sub    $0xc,%esp
f0102c97:	68 50 78 10 f0       	push   $0xf0107850
f0102c9c:	e8 9d 0e 00 00       	call   f0103b3e <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102ca1:	a1 8c fe 32 f0       	mov    0xf032fe8c,%eax
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
f0102d24:	2b 05 90 fe 32 f0    	sub    0xf032fe90,%eax
f0102d2a:	c1 f8 03             	sar    $0x3,%eax
f0102d2d:	89 c2                	mov    %eax,%edx
f0102d2f:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102d32:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102d37:	83 c4 10             	add    $0x10,%esp
f0102d3a:	3b 05 88 fe 32 f0    	cmp    0xf032fe88,%eax
f0102d40:	0f 83 d1 01 00 00    	jae    f0102f17 <mem_init+0x1b76>
	memset(page2kva(pp1), 1, PGSIZE);
f0102d46:	83 ec 04             	sub    $0x4,%esp
f0102d49:	68 00 10 00 00       	push   $0x1000
f0102d4e:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102d50:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102d56:	52                   	push   %edx
f0102d57:	e8 68 30 00 00       	call   f0105dc4 <memset>
	return (pp - pages) << PGSHIFT;
f0102d5c:	89 d8                	mov    %ebx,%eax
f0102d5e:	2b 05 90 fe 32 f0    	sub    0xf032fe90,%eax
f0102d64:	c1 f8 03             	sar    $0x3,%eax
f0102d67:	89 c2                	mov    %eax,%edx
f0102d69:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102d6c:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102d71:	83 c4 10             	add    $0x10,%esp
f0102d74:	3b 05 88 fe 32 f0    	cmp    0xf032fe88,%eax
f0102d7a:	0f 83 a9 01 00 00    	jae    f0102f29 <mem_init+0x1b88>
	memset(page2kva(pp2), 2, PGSIZE);
f0102d80:	83 ec 04             	sub    $0x4,%esp
f0102d83:	68 00 10 00 00       	push   $0x1000
f0102d88:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102d8a:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102d90:	52                   	push   %edx
f0102d91:	e8 2e 30 00 00       	call   f0105dc4 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102d96:	6a 02                	push   $0x2
f0102d98:	68 00 10 00 00       	push   $0x1000
f0102d9d:	57                   	push   %edi
f0102d9e:	ff 35 8c fe 32 f0    	pushl  0xf032fe8c
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
f0102dcf:	ff 35 8c fe 32 f0    	pushl  0xf032fe8c
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
f0102e0f:	2b 05 90 fe 32 f0    	sub    0xf032fe90,%eax
f0102e15:	c1 f8 03             	sar    $0x3,%eax
f0102e18:	89 c2                	mov    %eax,%edx
f0102e1a:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102e1d:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102e22:	3b 05 88 fe 32 f0    	cmp    0xf032fe88,%eax
f0102e28:	0f 83 8a 01 00 00    	jae    f0102fb8 <mem_init+0x1c17>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102e2e:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f0102e35:	03 03 03 
f0102e38:	0f 85 8c 01 00 00    	jne    f0102fca <mem_init+0x1c29>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102e3e:	83 ec 08             	sub    $0x8,%esp
f0102e41:	68 00 10 00 00       	push   $0x1000
f0102e46:	ff 35 8c fe 32 f0    	pushl  0xf032fe8c
f0102e4c:	e8 2d e4 ff ff       	call   f010127e <page_remove>
	assert(pp2->pp_ref == 0);
f0102e51:	83 c4 10             	add    $0x10,%esp
f0102e54:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102e59:	0f 85 84 01 00 00    	jne    f0102fe3 <mem_init+0x1c42>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102e5f:	8b 0d 8c fe 32 f0    	mov    0xf032fe8c,%ecx
f0102e65:	8b 11                	mov    (%ecx),%edx
f0102e67:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102e6d:	89 f0                	mov    %esi,%eax
f0102e6f:	2b 05 90 fe 32 f0    	sub    0xf032fe90,%eax
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
f0102ea3:	c7 04 24 e4 78 10 f0 	movl   $0xf01078e4,(%esp)
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
f0102eb8:	68 a8 6a 10 f0       	push   $0xf0106aa8
f0102ebd:	68 0a 01 00 00       	push   $0x10a
f0102ec2:	68 45 79 10 f0       	push   $0xf0107945
f0102ec7:	e8 74 d1 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0102ecc:	68 4e 7a 10 f0       	push   $0xf0107a4e
f0102ed1:	68 79 79 10 f0       	push   $0xf0107979
f0102ed6:	68 9a 04 00 00       	push   $0x49a
f0102edb:	68 45 79 10 f0       	push   $0xf0107945
f0102ee0:	e8 5b d1 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102ee5:	68 64 7a 10 f0       	push   $0xf0107a64
f0102eea:	68 79 79 10 f0       	push   $0xf0107979
f0102eef:	68 9b 04 00 00       	push   $0x49b
f0102ef4:	68 45 79 10 f0       	push   $0xf0107945
f0102ef9:	e8 42 d1 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102efe:	68 7a 7a 10 f0       	push   $0xf0107a7a
f0102f03:	68 79 79 10 f0       	push   $0xf0107979
f0102f08:	68 9c 04 00 00       	push   $0x49c
f0102f0d:	68 45 79 10 f0       	push   $0xf0107945
f0102f12:	e8 29 d1 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f17:	52                   	push   %edx
f0102f18:	68 84 6a 10 f0       	push   $0xf0106a84
f0102f1d:	6a 58                	push   $0x58
f0102f1f:	68 5f 79 10 f0       	push   $0xf010795f
f0102f24:	e8 17 d1 ff ff       	call   f0100040 <_panic>
f0102f29:	52                   	push   %edx
f0102f2a:	68 84 6a 10 f0       	push   $0xf0106a84
f0102f2f:	6a 58                	push   $0x58
f0102f31:	68 5f 79 10 f0       	push   $0xf010795f
f0102f36:	e8 05 d1 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102f3b:	68 4b 7b 10 f0       	push   $0xf0107b4b
f0102f40:	68 79 79 10 f0       	push   $0xf0107979
f0102f45:	68 a1 04 00 00       	push   $0x4a1
f0102f4a:	68 45 79 10 f0       	push   $0xf0107945
f0102f4f:	e8 ec d0 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102f54:	68 70 78 10 f0       	push   $0xf0107870
f0102f59:	68 79 79 10 f0       	push   $0xf0107979
f0102f5e:	68 a2 04 00 00       	push   $0x4a2
f0102f63:	68 45 79 10 f0       	push   $0xf0107945
f0102f68:	e8 d3 d0 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102f6d:	68 94 78 10 f0       	push   $0xf0107894
f0102f72:	68 79 79 10 f0       	push   $0xf0107979
f0102f77:	68 a4 04 00 00       	push   $0x4a4
f0102f7c:	68 45 79 10 f0       	push   $0xf0107945
f0102f81:	e8 ba d0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102f86:	68 6d 7b 10 f0       	push   $0xf0107b6d
f0102f8b:	68 79 79 10 f0       	push   $0xf0107979
f0102f90:	68 a5 04 00 00       	push   $0x4a5
f0102f95:	68 45 79 10 f0       	push   $0xf0107945
f0102f9a:	e8 a1 d0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102f9f:	68 d7 7b 10 f0       	push   $0xf0107bd7
f0102fa4:	68 79 79 10 f0       	push   $0xf0107979
f0102fa9:	68 a6 04 00 00       	push   $0x4a6
f0102fae:	68 45 79 10 f0       	push   $0xf0107945
f0102fb3:	e8 88 d0 ff ff       	call   f0100040 <_panic>
f0102fb8:	52                   	push   %edx
f0102fb9:	68 84 6a 10 f0       	push   $0xf0106a84
f0102fbe:	6a 58                	push   $0x58
f0102fc0:	68 5f 79 10 f0       	push   $0xf010795f
f0102fc5:	e8 76 d0 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102fca:	68 b8 78 10 f0       	push   $0xf01078b8
f0102fcf:	68 79 79 10 f0       	push   $0xf0107979
f0102fd4:	68 a8 04 00 00       	push   $0x4a8
f0102fd9:	68 45 79 10 f0       	push   $0xf0107945
f0102fde:	e8 5d d0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102fe3:	68 a5 7b 10 f0       	push   $0xf0107ba5
f0102fe8:	68 79 79 10 f0       	push   $0xf0107979
f0102fed:	68 aa 04 00 00       	push   $0x4aa
f0102ff2:	68 45 79 10 f0       	push   $0xf0107945
f0102ff7:	e8 44 d0 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102ffc:	68 40 72 10 f0       	push   $0xf0107240
f0103001:	68 79 79 10 f0       	push   $0xf0107979
f0103006:	68 ad 04 00 00       	push   $0x4ad
f010300b:	68 45 79 10 f0       	push   $0xf0107945
f0103010:	e8 2b d0 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0103015:	68 5c 7b 10 f0       	push   $0xf0107b5c
f010301a:	68 79 79 10 f0       	push   $0xf0107979
f010301f:	68 af 04 00 00       	push   $0x4af
f0103024:	68 45 79 10 f0       	push   $0xf0107945
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
f0103098:	89 1d 3c f2 32 f0    	mov    %ebx,0xf032f23c
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
f01030d1:	89 1d 3c f2 32 f0    	mov    %ebx,0xf032f23c
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
f010311b:	ff 35 3c f2 32 f0    	pushl  0xf032f23c
f0103121:	ff 73 48             	pushl  0x48(%ebx)
f0103124:	68 10 79 10 f0       	push   $0xf0107910
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
f0103166:	68 74 7c 10 f0       	push   $0xf0107c74
f010316b:	68 2c 01 00 00       	push   $0x12c
f0103170:	68 20 7d 10 f0       	push   $0xf0107d20
f0103175:	e8 c6 ce ff ff       	call   f0100040 <_panic>
        }

        pp = page_alloc(0);

        if (pp == NULL) {
            panic("region_alloc: out-of-memory!\n");
f010317a:	83 ec 04             	sub    $0x4,%esp
f010317d:	68 2b 7d 10 f0       	push   $0xf0107d2b
f0103182:	68 3a 01 00 00       	push   $0x13a
f0103187:	68 20 7d 10 f0       	push   $0xf0107d20
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
f01031dc:	68 a8 7c 10 f0       	push   $0xf0107ca8
f01031e1:	68 3e 01 00 00       	push   $0x13e
f01031e6:	68 20 7d 10 f0       	push   $0xf0107d20
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
f0103216:	03 1d 44 f2 32 f0    	add    0xf032f244,%ebx
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
f0103239:	e8 a4 31 00 00       	call   f01063e2 <cpunum>
f010323e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103241:	8b 80 28 00 33 f0    	mov    -0xfccffd8(%eax),%eax
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
f0103260:	e8 7d 31 00 00       	call   f01063e2 <cpunum>
f0103265:	6b c0 74             	imul   $0x74,%eax,%eax
f0103268:	39 98 28 00 33 f0    	cmp    %ebx,-0xfccffd8(%eax)
f010326e:	74 bb                	je     f010322b <envid2env+0x33>
f0103270:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103273:	e8 6a 31 00 00       	call   f01063e2 <cpunum>
f0103278:	6b c0 74             	imul   $0x74,%eax,%eax
f010327b:	8b 80 28 00 33 f0    	mov    -0xfccffd8(%eax),%eax
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
f01032d9:	ff 35 44 f2 32 f0    	pushl  0xf032f244
f01032df:	e8 e0 2a 00 00       	call   f0105dc4 <memset>
        envs[i].env_link = env_free_list;
f01032e4:	8b 35 44 f2 32 f0    	mov    0xf032f244,%esi
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
f0103308:	89 35 48 f2 32 f0    	mov    %esi,0xf032f248
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
f0103325:	8b 1d 48 f2 32 f0    	mov    0xf032f248,%ebx
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
f010334d:	2b 05 90 fe 32 f0    	sub    0xf032fe90,%eax
f0103353:	c1 f8 03             	sar    $0x3,%eax
f0103356:	89 c2                	mov    %eax,%edx
f0103358:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010335b:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0103360:	3b 05 88 fe 32 f0    	cmp    0xf032fe88,%eax
f0103366:	0f 83 1e 01 00 00    	jae    f010348a <env_alloc+0x170>
	return (void *)(pa + KERNBASE);
f010336c:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103372:	89 53 60             	mov    %edx,0x60(%ebx)
    e->env_pgdir = page2kva(p);
f0103375:	b8 ec 0e 00 00       	mov    $0xeec,%eax
        e->env_pgdir[i] = kern_pgdir[i];
f010337a:	8b 15 8c fe 32 f0    	mov    0xf032fe8c,%edx
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
f01033c7:	2b 15 44 f2 32 f0    	sub    0xf032f244,%edx
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
f01033fe:	e8 c1 29 00 00       	call   f0105dc4 <memset>
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
f0103437:	a3 48 f2 32 f0       	mov    %eax,0xf032f248
	*newenv_store = e;
f010343c:	8b 45 08             	mov    0x8(%ebp),%eax
f010343f:	89 18                	mov    %ebx,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103441:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103444:	e8 99 2f 00 00       	call   f01063e2 <cpunum>
f0103449:	6b c0 74             	imul   $0x74,%eax,%eax
f010344c:	83 c4 10             	add    $0x10,%esp
f010344f:	ba 00 00 00 00       	mov    $0x0,%edx
f0103454:	83 b8 28 00 33 f0 00 	cmpl   $0x0,-0xfccffd8(%eax)
f010345b:	74 11                	je     f010346e <env_alloc+0x154>
f010345d:	e8 80 2f 00 00       	call   f01063e2 <cpunum>
f0103462:	6b c0 74             	imul   $0x74,%eax,%eax
f0103465:	8b 80 28 00 33 f0    	mov    -0xfccffd8(%eax),%eax
f010346b:	8b 50 48             	mov    0x48(%eax),%edx
f010346e:	83 ec 04             	sub    $0x4,%esp
f0103471:	53                   	push   %ebx
f0103472:	52                   	push   %edx
f0103473:	68 49 7d 10 f0       	push   $0xf0107d49
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
f010348b:	68 84 6a 10 f0       	push   $0xf0106a84
f0103490:	6a 58                	push   $0x58
f0103492:	68 5f 79 10 f0       	push   $0xf010795f
f0103497:	e8 a4 cb ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010349c:	50                   	push   %eax
f010349d:	68 a8 6a 10 f0       	push   $0xf0106aa8
f01034a2:	68 c8 00 00 00       	push   $0xc8
f01034a7:	68 20 7d 10 f0       	push   $0xf0107d20
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
f010353c:	68 d8 7c 10 f0       	push   $0xf0107cd8
f0103541:	68 b1 01 00 00       	push   $0x1b1
f0103546:	68 20 7d 10 f0       	push   $0xf0107d20
f010354b:	e8 f0 ca ff ff       	call   f0100040 <_panic>
        panic("not enouth memory!\n");
f0103550:	83 ec 04             	sub    $0x4,%esp
f0103553:	68 5e 7d 10 f0       	push   $0xf0107d5e
f0103558:	68 b4 01 00 00       	push   $0x1b4
f010355d:	68 20 7d 10 f0       	push   $0xf0107d20
f0103562:	e8 d9 ca ff ff       	call   f0100040 <_panic>
        panic("new env is not allocated!\n");
f0103567:	83 ec 04             	sub    $0x4,%esp
f010356a:	68 72 7d 10 f0       	push   $0xf0107d72
f010356f:	68 b7 01 00 00       	push   $0x1b7
f0103574:	68 20 7d 10 f0       	push   $0xf0107d20
f0103579:	e8 c2 ca ff ff       	call   f0100040 <_panic>
    if (type == ENV_TYPE_FS) new_env->env_tf.tf_eflags |= FL_IOPL_3;
f010357e:	81 4e 38 00 30 00 00 	orl    $0x3000,0x38(%esi)
f0103585:	e9 76 ff ff ff       	jmp    f0103500 <env_create+0x41>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010358a:	50                   	push   %eax
f010358b:	68 a8 6a 10 f0       	push   $0xf0106aa8
f0103590:	68 7b 01 00 00       	push   $0x17b
f0103595:	68 20 7d 10 f0       	push   $0xf0107d20
f010359a:	e8 a1 ca ff ff       	call   f0100040 <_panic>
        panic("load_icode: not an ELF binary!\n");
f010359f:	83 ec 04             	sub    $0x4,%esp
f01035a2:	68 00 7d 10 f0       	push   $0xf0107d00
f01035a7:	68 81 01 00 00       	push   $0x181
f01035ac:	68 20 7d 10 f0       	push   $0xf0107d20
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
f01035ce:	e8 f1 27 00 00       	call   f0105dc4 <memset>
            memcpy((void *)ph->p_va, (void *)(elf_base + ph->p_offset), ph->p_filesz);
f01035d3:	83 c4 0c             	add    $0xc,%esp
f01035d6:	ff 73 10             	pushl  0x10(%ebx)
f01035d9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01035dc:	03 43 04             	add    0x4(%ebx),%eax
f01035df:	50                   	push   %eax
f01035e0:	ff 73 08             	pushl  0x8(%ebx)
f01035e3:	e8 8e 28 00 00       	call   f0105e76 <memcpy>
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
f0103636:	e8 a7 2d 00 00       	call   f01063e2 <cpunum>
f010363b:	6b c0 74             	imul   $0x74,%eax,%eax
f010363e:	39 b8 28 00 33 f0    	cmp    %edi,-0xfccffd8(%eax)
f0103644:	74 48                	je     f010368e <env_free+0x68>
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103646:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103649:	e8 94 2d 00 00       	call   f01063e2 <cpunum>
f010364e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103651:	ba 00 00 00 00       	mov    $0x0,%edx
f0103656:	83 b8 28 00 33 f0 00 	cmpl   $0x0,-0xfccffd8(%eax)
f010365d:	74 11                	je     f0103670 <env_free+0x4a>
f010365f:	e8 7e 2d 00 00       	call   f01063e2 <cpunum>
f0103664:	6b c0 74             	imul   $0x74,%eax,%eax
f0103667:	8b 80 28 00 33 f0    	mov    -0xfccffd8(%eax),%eax
f010366d:	8b 50 48             	mov    0x48(%eax),%edx
f0103670:	83 ec 04             	sub    $0x4,%esp
f0103673:	53                   	push   %ebx
f0103674:	52                   	push   %edx
f0103675:	68 8d 7d 10 f0       	push   $0xf0107d8d
f010367a:	e8 bf 04 00 00       	call   f0103b3e <cprintf>
f010367f:	83 c4 10             	add    $0x10,%esp
f0103682:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103689:	e9 a9 00 00 00       	jmp    f0103737 <env_free+0x111>
		lcr3(PADDR(kern_pgdir));
f010368e:	a1 8c fe 32 f0       	mov    0xf032fe8c,%eax
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
f01036a5:	68 a8 6a 10 f0       	push   $0xf0106aa8
f01036aa:	68 ce 01 00 00       	push   $0x1ce
f01036af:	68 20 7d 10 f0       	push   $0xf0107d20
f01036b4:	e8 87 c9 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01036b9:	56                   	push   %esi
f01036ba:	68 84 6a 10 f0       	push   $0xf0106a84
f01036bf:	68 dd 01 00 00       	push   $0x1dd
f01036c4:	68 20 7d 10 f0       	push   $0xf0107d20
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
f010370a:	3b 05 88 fe 32 f0    	cmp    0xf032fe88,%eax
f0103710:	73 65                	jae    f0103777 <env_free+0x151>
		page_decref(pa2page(pa));
f0103712:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103715:	a1 90 fe 32 f0       	mov    0xf032fe90,%eax
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
f0103752:	39 05 88 fe 32 f0    	cmp    %eax,0xf032fe88
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
f010377a:	68 0c 71 10 f0       	push   $0xf010710c
f010377f:	6a 51                	push   $0x51
f0103781:	68 5f 79 10 f0       	push   $0xf010795f
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
f01037a4:	3b 05 88 fe 32 f0    	cmp    0xf032fe88,%eax
f01037aa:	73 47                	jae    f01037f3 <env_free+0x1cd>
	page_decref(pa2page(pa));
f01037ac:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01037af:	8b 15 90 fe 32 f0    	mov    0xf032fe90,%edx
f01037b5:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01037b8:	50                   	push   %eax
f01037b9:	e8 f8 d8 ff ff       	call   f01010b6 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01037be:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01037c5:	a1 48 f2 32 f0       	mov    0xf032f248,%eax
f01037ca:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01037cd:	89 3d 48 f2 32 f0    	mov    %edi,0xf032f248
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
f01037df:	68 a8 6a 10 f0       	push   $0xf0106aa8
f01037e4:	68 eb 01 00 00       	push   $0x1eb
f01037e9:	68 20 7d 10 f0       	push   $0xf0107d20
f01037ee:	e8 4d c8 ff ff       	call   f0100040 <_panic>
		panic("pa2page called with invalid pa");
f01037f3:	83 ec 04             	sub    $0x4,%esp
f01037f6:	68 0c 71 10 f0       	push   $0xf010710c
f01037fb:	6a 51                	push   $0x51
f01037fd:	68 5f 79 10 f0       	push   $0xf010795f
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
f0103824:	e8 b9 2b 00 00       	call   f01063e2 <cpunum>
f0103829:	6b c0 74             	imul   $0x74,%eax,%eax
f010382c:	83 c4 10             	add    $0x10,%esp
f010382f:	39 98 28 00 33 f0    	cmp    %ebx,-0xfccffd8(%eax)
f0103835:	74 1e                	je     f0103855 <env_destroy+0x4e>
		curenv = NULL;
		sched_yield();
	}
}
f0103837:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010383a:	c9                   	leave  
f010383b:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f010383c:	e8 a1 2b 00 00       	call   f01063e2 <cpunum>
f0103841:	6b c0 74             	imul   $0x74,%eax,%eax
f0103844:	39 98 28 00 33 f0    	cmp    %ebx,-0xfccffd8(%eax)
f010384a:	74 cf                	je     f010381b <env_destroy+0x14>
		e->env_status = ENV_DYING;
f010384c:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103853:	eb e2                	jmp    f0103837 <env_destroy+0x30>
		curenv = NULL;
f0103855:	e8 88 2b 00 00       	call   f01063e2 <cpunum>
f010385a:	6b c0 74             	imul   $0x74,%eax,%eax
f010385d:	c7 80 28 00 33 f0 00 	movl   $0x0,-0xfccffd8(%eax)
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
f0103878:	e8 65 2b 00 00       	call   f01063e2 <cpunum>
f010387d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103880:	8b b0 28 00 33 f0    	mov    -0xfccffd8(%eax),%esi
f0103886:	e8 57 2b 00 00       	call   f01063e2 <cpunum>
f010388b:	89 46 5c             	mov    %eax,0x5c(%esi)
    assert(tf->tf_eflags & FL_IF);
f010388e:	f6 43 39 02          	testb  $0x2,0x39(%ebx)
f0103892:	75 19                	jne    f01038ad <env_pop_tf+0x41>
f0103894:	68 a3 7d 10 f0       	push   $0xf0107da3
f0103899:	68 79 79 10 f0       	push   $0xf0107979
f010389e:	68 19 02 00 00       	push   $0x219
f01038a3:	68 20 7d 10 f0       	push   $0xf0107d20
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
f01038b9:	68 b9 7d 10 f0       	push   $0xf0107db9
f01038be:	68 23 02 00 00       	push   $0x223
f01038c3:	68 20 7d 10 f0       	push   $0xf0107d20
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
f01038db:	e8 02 2b 00 00       	call   f01063e2 <cpunum>
f01038e0:	6b c0 74             	imul   $0x74,%eax,%eax
f01038e3:	83 b8 28 00 33 f0 00 	cmpl   $0x0,-0xfccffd8(%eax)
f01038ea:	74 14                	je     f0103900 <env_run+0x33>
f01038ec:	e8 f1 2a 00 00       	call   f01063e2 <cpunum>
f01038f1:	6b c0 74             	imul   $0x74,%eax,%eax
f01038f4:	8b 80 28 00 33 f0    	mov    -0xfccffd8(%eax),%eax
f01038fa:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01038fe:	74 6c                	je     f010396c <env_run+0x9f>
        curenv->env_status = ENV_RUNNABLE;
    }
    // 2.
    curenv = e;
f0103900:	e8 dd 2a 00 00       	call   f01063e2 <cpunum>
f0103905:	6b c0 74             	imul   $0x74,%eax,%eax
f0103908:	89 98 28 00 33 f0    	mov    %ebx,-0xfccffd8(%eax)
    // 3.
    curenv->env_status = ENV_RUNNING;
f010390e:	e8 cf 2a 00 00       	call   f01063e2 <cpunum>
f0103913:	6b c0 74             	imul   $0x74,%eax,%eax
f0103916:	8b 80 28 00 33 f0    	mov    -0xfccffd8(%eax),%eax
f010391c:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
    // 4.
    curenv->env_runs += 1;
f0103923:	e8 ba 2a 00 00       	call   f01063e2 <cpunum>
f0103928:	6b c0 74             	imul   $0x74,%eax,%eax
f010392b:	8b 80 28 00 33 f0    	mov    -0xfccffd8(%eax),%eax
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
f010394f:	e8 b4 2d 00 00       	call   f0106708 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103954:	f3 90                	pause  

    unlock_kernel();

    env_pop_tf(&curenv->env_tf);
f0103956:	e8 87 2a 00 00       	call   f01063e2 <cpunum>
f010395b:	83 c4 04             	add    $0x4,%esp
f010395e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103961:	ff b0 28 00 33 f0    	pushl  -0xfccffd8(%eax)
f0103967:	e8 00 ff ff ff       	call   f010386c <env_pop_tf>
        curenv->env_status = ENV_RUNNABLE;
f010396c:	e8 71 2a 00 00       	call   f01063e2 <cpunum>
f0103971:	6b c0 74             	imul   $0x74,%eax,%eax
f0103974:	8b 80 28 00 33 f0    	mov    -0xfccffd8(%eax),%eax
f010397a:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f0103981:	e9 7a ff ff ff       	jmp    f0103900 <env_run+0x33>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103986:	50                   	push   %eax
f0103987:	68 a8 6a 10 f0       	push   $0xf0106aa8
f010398c:	68 4d 02 00 00       	push   $0x24d
f0103991:	68 20 7d 10 f0       	push   $0xf0107d20
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
f01039e3:	80 3d 4c f2 32 f0 00 	cmpb   $0x0,0xf032f24c
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
f0103a08:	68 c5 7d 10 f0       	push   $0xf0107dc5
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
f0103a25:	68 d3 82 10 f0       	push   $0xf01082d3
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
f0103a44:	68 40 7c 10 f0       	push   $0xf0107c40
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
f0103a60:	c6 05 4c f2 32 f0 01 	movb   $0x1,0xf032f24c
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
f0103b34:	e8 29 1b 00 00       	call   f0105662 <vprintfmt>
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
f0103b63:	e8 7a 28 00 00       	call   f01063e2 <cpunum>
f0103b68:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b6b:	0f b6 b8 20 00 33 f0 	movzbl -0xfccffe0(%eax),%edi
f0103b72:	89 f8                	mov    %edi,%eax
f0103b74:	0f b6 d8             	movzbl %al,%ebx
    thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - (KSTKSIZE + KSTKGAP) * cpu_id;
f0103b77:	e8 66 28 00 00       	call   f01063e2 <cpunum>
f0103b7c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b7f:	ba 00 f0 00 00       	mov    $0xf000,%edx
f0103b84:	29 da                	sub    %ebx,%edx
f0103b86:	c1 e2 10             	shl    $0x10,%edx
f0103b89:	89 90 30 00 33 f0    	mov    %edx,-0xfccffd0(%eax)
    thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103b8f:	e8 4e 28 00 00       	call   f01063e2 <cpunum>
f0103b94:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b97:	66 c7 80 34 00 33 f0 	movw   $0x10,-0xfccffcc(%eax)
f0103b9e:	10 00 
    thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f0103ba0:	e8 3d 28 00 00       	call   f01063e2 <cpunum>
f0103ba5:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ba8:	66 c7 80 92 00 33 f0 	movw   $0x68,-0xfccff6e(%eax)
f0103baf:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cpu_id] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f0103bb1:	83 c3 05             	add    $0x5,%ebx
f0103bb4:	e8 29 28 00 00       	call   f01063e2 <cpunum>
f0103bb9:	89 c6                	mov    %eax,%esi
f0103bbb:	e8 22 28 00 00       	call   f01063e2 <cpunum>
f0103bc0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103bc3:	e8 1a 28 00 00       	call   f01063e2 <cpunum>
f0103bc8:	66 c7 04 dd 40 43 12 	movw   $0x67,-0xfedbcc0(,%ebx,8)
f0103bcf:	f0 67 00 
f0103bd2:	6b f6 74             	imul   $0x74,%esi,%esi
f0103bd5:	81 c6 2c 00 33 f0    	add    $0xf033002c,%esi
f0103bdb:	66 89 34 dd 42 43 12 	mov    %si,-0xfedbcbe(,%ebx,8)
f0103be2:	f0 
f0103be3:	6b 55 e4 74          	imul   $0x74,-0x1c(%ebp),%edx
f0103be7:	81 c2 2c 00 33 f0    	add    $0xf033002c,%edx
f0103bed:	c1 ea 10             	shr    $0x10,%edx
f0103bf0:	88 14 dd 44 43 12 f0 	mov    %dl,-0xfedbcbc(,%ebx,8)
f0103bf7:	c6 04 dd 46 43 12 f0 	movb   $0x40,-0xfedbcba(,%ebx,8)
f0103bfe:	40 
f0103bff:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c02:	05 2c 00 33 f0       	add    $0xf033002c,%eax
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
f0103c47:	66 a3 60 f2 32 f0    	mov    %ax,0xf032f260
f0103c4d:	66 c7 05 62 f2 32 f0 	movw   $0x8,0xf032f262
f0103c54:	08 00 
f0103c56:	c6 05 64 f2 32 f0 00 	movb   $0x0,0xf032f264
f0103c5d:	c6 05 65 f2 32 f0 8e 	movb   $0x8e,0xf032f265
f0103c64:	c1 e8 10             	shr    $0x10,%eax
f0103c67:	66 a3 66 f2 32 f0    	mov    %ax,0xf032f266
    SETGATE(idt[T_DEBUG], 0, GD_KT, t_debug, 0);
f0103c6d:	b8 4e 48 10 f0       	mov    $0xf010484e,%eax
f0103c72:	66 a3 68 f2 32 f0    	mov    %ax,0xf032f268
f0103c78:	66 c7 05 6a f2 32 f0 	movw   $0x8,0xf032f26a
f0103c7f:	08 00 
f0103c81:	c6 05 6c f2 32 f0 00 	movb   $0x0,0xf032f26c
f0103c88:	c6 05 6d f2 32 f0 8e 	movb   $0x8e,0xf032f26d
f0103c8f:	c1 e8 10             	shr    $0x10,%eax
f0103c92:	66 a3 6e f2 32 f0    	mov    %ax,0xf032f26e
    SETGATE(idt[T_NMI], 0, GD_KT, t_nmi, 0);
f0103c98:	b8 58 48 10 f0       	mov    $0xf0104858,%eax
f0103c9d:	66 a3 70 f2 32 f0    	mov    %ax,0xf032f270
f0103ca3:	66 c7 05 72 f2 32 f0 	movw   $0x8,0xf032f272
f0103caa:	08 00 
f0103cac:	c6 05 74 f2 32 f0 00 	movb   $0x0,0xf032f274
f0103cb3:	c6 05 75 f2 32 f0 8e 	movb   $0x8e,0xf032f275
f0103cba:	c1 e8 10             	shr    $0x10,%eax
f0103cbd:	66 a3 76 f2 32 f0    	mov    %ax,0xf032f276
    SETGATE(idt[T_BRKPT], 0, GD_KT, t_brkpt, 3);
f0103cc3:	b8 62 48 10 f0       	mov    $0xf0104862,%eax
f0103cc8:	66 a3 78 f2 32 f0    	mov    %ax,0xf032f278
f0103cce:	66 c7 05 7a f2 32 f0 	movw   $0x8,0xf032f27a
f0103cd5:	08 00 
f0103cd7:	c6 05 7c f2 32 f0 00 	movb   $0x0,0xf032f27c
f0103cde:	c6 05 7d f2 32 f0 ee 	movb   $0xee,0xf032f27d
f0103ce5:	c1 e8 10             	shr    $0x10,%eax
f0103ce8:	66 a3 7e f2 32 f0    	mov    %ax,0xf032f27e
    SETGATE(idt[T_OFLOW], 0, GD_KT, t_oflow, 0);
f0103cee:	b8 6c 48 10 f0       	mov    $0xf010486c,%eax
f0103cf3:	66 a3 80 f2 32 f0    	mov    %ax,0xf032f280
f0103cf9:	66 c7 05 82 f2 32 f0 	movw   $0x8,0xf032f282
f0103d00:	08 00 
f0103d02:	c6 05 84 f2 32 f0 00 	movb   $0x0,0xf032f284
f0103d09:	c6 05 85 f2 32 f0 8e 	movb   $0x8e,0xf032f285
f0103d10:	c1 e8 10             	shr    $0x10,%eax
f0103d13:	66 a3 86 f2 32 f0    	mov    %ax,0xf032f286
    SETGATE(idt[T_BOUND], 0, GD_KT, t_bound, 0);
f0103d19:	b8 76 48 10 f0       	mov    $0xf0104876,%eax
f0103d1e:	66 a3 88 f2 32 f0    	mov    %ax,0xf032f288
f0103d24:	66 c7 05 8a f2 32 f0 	movw   $0x8,0xf032f28a
f0103d2b:	08 00 
f0103d2d:	c6 05 8c f2 32 f0 00 	movb   $0x0,0xf032f28c
f0103d34:	c6 05 8d f2 32 f0 8e 	movb   $0x8e,0xf032f28d
f0103d3b:	c1 e8 10             	shr    $0x10,%eax
f0103d3e:	66 a3 8e f2 32 f0    	mov    %ax,0xf032f28e
    SETGATE(idt[T_ILLOP], 0, GD_KT, t_illop, 0);
f0103d44:	b8 80 48 10 f0       	mov    $0xf0104880,%eax
f0103d49:	66 a3 90 f2 32 f0    	mov    %ax,0xf032f290
f0103d4f:	66 c7 05 92 f2 32 f0 	movw   $0x8,0xf032f292
f0103d56:	08 00 
f0103d58:	c6 05 94 f2 32 f0 00 	movb   $0x0,0xf032f294
f0103d5f:	c6 05 95 f2 32 f0 8e 	movb   $0x8e,0xf032f295
f0103d66:	c1 e8 10             	shr    $0x10,%eax
f0103d69:	66 a3 96 f2 32 f0    	mov    %ax,0xf032f296
    SETGATE(idt[T_DEVICE], 0, GD_KT, t_device, 0);
f0103d6f:	b8 8a 48 10 f0       	mov    $0xf010488a,%eax
f0103d74:	66 a3 98 f2 32 f0    	mov    %ax,0xf032f298
f0103d7a:	66 c7 05 9a f2 32 f0 	movw   $0x8,0xf032f29a
f0103d81:	08 00 
f0103d83:	c6 05 9c f2 32 f0 00 	movb   $0x0,0xf032f29c
f0103d8a:	c6 05 9d f2 32 f0 8e 	movb   $0x8e,0xf032f29d
f0103d91:	c1 e8 10             	shr    $0x10,%eax
f0103d94:	66 a3 9e f2 32 f0    	mov    %ax,0xf032f29e
    SETGATE(idt[T_DBLFLT], 0, GD_KT, t_dblflt, 0);
f0103d9a:	b8 94 48 10 f0       	mov    $0xf0104894,%eax
f0103d9f:	66 a3 a0 f2 32 f0    	mov    %ax,0xf032f2a0
f0103da5:	66 c7 05 a2 f2 32 f0 	movw   $0x8,0xf032f2a2
f0103dac:	08 00 
f0103dae:	c6 05 a4 f2 32 f0 00 	movb   $0x0,0xf032f2a4
f0103db5:	c6 05 a5 f2 32 f0 8e 	movb   $0x8e,0xf032f2a5
f0103dbc:	c1 e8 10             	shr    $0x10,%eax
f0103dbf:	66 a3 a6 f2 32 f0    	mov    %ax,0xf032f2a6
    SETGATE(idt[T_TSS], 0, GD_KT, t_tss, 0);
f0103dc5:	b8 9c 48 10 f0       	mov    $0xf010489c,%eax
f0103dca:	66 a3 b0 f2 32 f0    	mov    %ax,0xf032f2b0
f0103dd0:	66 c7 05 b2 f2 32 f0 	movw   $0x8,0xf032f2b2
f0103dd7:	08 00 
f0103dd9:	c6 05 b4 f2 32 f0 00 	movb   $0x0,0xf032f2b4
f0103de0:	c6 05 b5 f2 32 f0 8e 	movb   $0x8e,0xf032f2b5
f0103de7:	c1 e8 10             	shr    $0x10,%eax
f0103dea:	66 a3 b6 f2 32 f0    	mov    %ax,0xf032f2b6
    SETGATE(idt[T_SEGNP], 0, GD_KT, t_segnp, 0);
f0103df0:	b8 a4 48 10 f0       	mov    $0xf01048a4,%eax
f0103df5:	66 a3 b8 f2 32 f0    	mov    %ax,0xf032f2b8
f0103dfb:	66 c7 05 ba f2 32 f0 	movw   $0x8,0xf032f2ba
f0103e02:	08 00 
f0103e04:	c6 05 bc f2 32 f0 00 	movb   $0x0,0xf032f2bc
f0103e0b:	c6 05 bd f2 32 f0 8e 	movb   $0x8e,0xf032f2bd
f0103e12:	c1 e8 10             	shr    $0x10,%eax
f0103e15:	66 a3 be f2 32 f0    	mov    %ax,0xf032f2be
    SETGATE(idt[T_STACK], 0, GD_KT, t_stack, 0);
f0103e1b:	b8 ac 48 10 f0       	mov    $0xf01048ac,%eax
f0103e20:	66 a3 c0 f2 32 f0    	mov    %ax,0xf032f2c0
f0103e26:	66 c7 05 c2 f2 32 f0 	movw   $0x8,0xf032f2c2
f0103e2d:	08 00 
f0103e2f:	c6 05 c4 f2 32 f0 00 	movb   $0x0,0xf032f2c4
f0103e36:	c6 05 c5 f2 32 f0 8e 	movb   $0x8e,0xf032f2c5
f0103e3d:	c1 e8 10             	shr    $0x10,%eax
f0103e40:	66 a3 c6 f2 32 f0    	mov    %ax,0xf032f2c6
    SETGATE(idt[T_GPFLT], 0, GD_KT, t_gpflt, 0);
f0103e46:	b8 b4 48 10 f0       	mov    $0xf01048b4,%eax
f0103e4b:	66 a3 c8 f2 32 f0    	mov    %ax,0xf032f2c8
f0103e51:	66 c7 05 ca f2 32 f0 	movw   $0x8,0xf032f2ca
f0103e58:	08 00 
f0103e5a:	c6 05 cc f2 32 f0 00 	movb   $0x0,0xf032f2cc
f0103e61:	c6 05 cd f2 32 f0 8e 	movb   $0x8e,0xf032f2cd
f0103e68:	c1 e8 10             	shr    $0x10,%eax
f0103e6b:	66 a3 ce f2 32 f0    	mov    %ax,0xf032f2ce
    SETGATE(idt[T_PGFLT], 0, GD_KT, t_pgflt, 0);
f0103e71:	b8 bc 48 10 f0       	mov    $0xf01048bc,%eax
f0103e76:	66 a3 d0 f2 32 f0    	mov    %ax,0xf032f2d0
f0103e7c:	66 c7 05 d2 f2 32 f0 	movw   $0x8,0xf032f2d2
f0103e83:	08 00 
f0103e85:	c6 05 d4 f2 32 f0 00 	movb   $0x0,0xf032f2d4
f0103e8c:	c6 05 d5 f2 32 f0 8e 	movb   $0x8e,0xf032f2d5
f0103e93:	c1 e8 10             	shr    $0x10,%eax
f0103e96:	66 a3 d6 f2 32 f0    	mov    %ax,0xf032f2d6
    SETGATE(idt[T_FPERR], 0, GD_KT, t_fperr, 0);
f0103e9c:	b8 c0 48 10 f0       	mov    $0xf01048c0,%eax
f0103ea1:	66 a3 e0 f2 32 f0    	mov    %ax,0xf032f2e0
f0103ea7:	66 c7 05 e2 f2 32 f0 	movw   $0x8,0xf032f2e2
f0103eae:	08 00 
f0103eb0:	c6 05 e4 f2 32 f0 00 	movb   $0x0,0xf032f2e4
f0103eb7:	c6 05 e5 f2 32 f0 8e 	movb   $0x8e,0xf032f2e5
f0103ebe:	c1 e8 10             	shr    $0x10,%eax
f0103ec1:	66 a3 e6 f2 32 f0    	mov    %ax,0xf032f2e6
    SETGATE(idt[T_ALIGN], 0, GD_KT, t_align, 0);
f0103ec7:	b8 c6 48 10 f0       	mov    $0xf01048c6,%eax
f0103ecc:	66 a3 e8 f2 32 f0    	mov    %ax,0xf032f2e8
f0103ed2:	66 c7 05 ea f2 32 f0 	movw   $0x8,0xf032f2ea
f0103ed9:	08 00 
f0103edb:	c6 05 ec f2 32 f0 00 	movb   $0x0,0xf032f2ec
f0103ee2:	c6 05 ed f2 32 f0 8e 	movb   $0x8e,0xf032f2ed
f0103ee9:	c1 e8 10             	shr    $0x10,%eax
f0103eec:	66 a3 ee f2 32 f0    	mov    %ax,0xf032f2ee
    SETGATE(idt[T_MCHK], 0, GD_KT, t_mchk, 0);
f0103ef2:	b8 ca 48 10 f0       	mov    $0xf01048ca,%eax
f0103ef7:	66 a3 f0 f2 32 f0    	mov    %ax,0xf032f2f0
f0103efd:	66 c7 05 f2 f2 32 f0 	movw   $0x8,0xf032f2f2
f0103f04:	08 00 
f0103f06:	c6 05 f4 f2 32 f0 00 	movb   $0x0,0xf032f2f4
f0103f0d:	c6 05 f5 f2 32 f0 8e 	movb   $0x8e,0xf032f2f5
f0103f14:	c1 e8 10             	shr    $0x10,%eax
f0103f17:	66 a3 f6 f2 32 f0    	mov    %ax,0xf032f2f6
    SETGATE(idt[T_SIMDERR], 0, GD_KT, t_simderr, 0);
f0103f1d:	b8 d0 48 10 f0       	mov    $0xf01048d0,%eax
f0103f22:	66 a3 f8 f2 32 f0    	mov    %ax,0xf032f2f8
f0103f28:	66 c7 05 fa f2 32 f0 	movw   $0x8,0xf032f2fa
f0103f2f:	08 00 
f0103f31:	c6 05 fc f2 32 f0 00 	movb   $0x0,0xf032f2fc
f0103f38:	c6 05 fd f2 32 f0 8e 	movb   $0x8e,0xf032f2fd
f0103f3f:	c1 e8 10             	shr    $0x10,%eax
f0103f42:	66 a3 fe f2 32 f0    	mov    %ax,0xf032f2fe
    SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, t_irq_timer, 0);
f0103f48:	b8 d6 48 10 f0       	mov    $0xf01048d6,%eax
f0103f4d:	66 a3 60 f3 32 f0    	mov    %ax,0xf032f360
f0103f53:	66 c7 05 62 f3 32 f0 	movw   $0x8,0xf032f362
f0103f5a:	08 00 
f0103f5c:	c6 05 64 f3 32 f0 00 	movb   $0x0,0xf032f364
f0103f63:	c6 05 65 f3 32 f0 8e 	movb   $0x8e,0xf032f365
f0103f6a:	c1 e8 10             	shr    $0x10,%eax
f0103f6d:	66 a3 66 f3 32 f0    	mov    %ax,0xf032f366
    SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0, GD_KT, t_irq_kbd, 0);
f0103f73:	b8 dc 48 10 f0       	mov    $0xf01048dc,%eax
f0103f78:	66 a3 68 f3 32 f0    	mov    %ax,0xf032f368
f0103f7e:	66 c7 05 6a f3 32 f0 	movw   $0x8,0xf032f36a
f0103f85:	08 00 
f0103f87:	c6 05 6c f3 32 f0 00 	movb   $0x0,0xf032f36c
f0103f8e:	c6 05 6d f3 32 f0 8e 	movb   $0x8e,0xf032f36d
f0103f95:	c1 e8 10             	shr    $0x10,%eax
f0103f98:	66 a3 6e f3 32 f0    	mov    %ax,0xf032f36e
    SETGATE(idt[IRQ_OFFSET + 2], 0, GD_KT, t_irq_2, 0);
f0103f9e:	b8 e2 48 10 f0       	mov    $0xf01048e2,%eax
f0103fa3:	66 a3 70 f3 32 f0    	mov    %ax,0xf032f370
f0103fa9:	66 c7 05 72 f3 32 f0 	movw   $0x8,0xf032f372
f0103fb0:	08 00 
f0103fb2:	c6 05 74 f3 32 f0 00 	movb   $0x0,0xf032f374
f0103fb9:	c6 05 75 f3 32 f0 8e 	movb   $0x8e,0xf032f375
f0103fc0:	c1 e8 10             	shr    $0x10,%eax
f0103fc3:	66 a3 76 f3 32 f0    	mov    %ax,0xf032f376
    SETGATE(idt[IRQ_OFFSET + 3], 0, GD_KT, t_irq_3, 0);
f0103fc9:	b8 e8 48 10 f0       	mov    $0xf01048e8,%eax
f0103fce:	66 a3 78 f3 32 f0    	mov    %ax,0xf032f378
f0103fd4:	66 c7 05 7a f3 32 f0 	movw   $0x8,0xf032f37a
f0103fdb:	08 00 
f0103fdd:	c6 05 7c f3 32 f0 00 	movb   $0x0,0xf032f37c
f0103fe4:	c6 05 7d f3 32 f0 8e 	movb   $0x8e,0xf032f37d
f0103feb:	c1 e8 10             	shr    $0x10,%eax
f0103fee:	66 a3 7e f3 32 f0    	mov    %ax,0xf032f37e
    SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0, GD_KT, t_irq_serial, 0);
f0103ff4:	b8 ee 48 10 f0       	mov    $0xf01048ee,%eax
f0103ff9:	66 a3 80 f3 32 f0    	mov    %ax,0xf032f380
f0103fff:	66 c7 05 82 f3 32 f0 	movw   $0x8,0xf032f382
f0104006:	08 00 
f0104008:	c6 05 84 f3 32 f0 00 	movb   $0x0,0xf032f384
f010400f:	c6 05 85 f3 32 f0 8e 	movb   $0x8e,0xf032f385
f0104016:	c1 e8 10             	shr    $0x10,%eax
f0104019:	66 a3 86 f3 32 f0    	mov    %ax,0xf032f386
    SETGATE(idt[IRQ_OFFSET + 5], 0, GD_KT, t_irq_5, 0);
f010401f:	b8 f4 48 10 f0       	mov    $0xf01048f4,%eax
f0104024:	66 a3 88 f3 32 f0    	mov    %ax,0xf032f388
f010402a:	66 c7 05 8a f3 32 f0 	movw   $0x8,0xf032f38a
f0104031:	08 00 
f0104033:	c6 05 8c f3 32 f0 00 	movb   $0x0,0xf032f38c
f010403a:	c6 05 8d f3 32 f0 8e 	movb   $0x8e,0xf032f38d
f0104041:	c1 e8 10             	shr    $0x10,%eax
f0104044:	66 a3 8e f3 32 f0    	mov    %ax,0xf032f38e
    SETGATE(idt[IRQ_OFFSET + 6], 0, GD_KT, t_irq_6, 0);
f010404a:	b8 fa 48 10 f0       	mov    $0xf01048fa,%eax
f010404f:	66 a3 90 f3 32 f0    	mov    %ax,0xf032f390
f0104055:	66 c7 05 92 f3 32 f0 	movw   $0x8,0xf032f392
f010405c:	08 00 
f010405e:	c6 05 94 f3 32 f0 00 	movb   $0x0,0xf032f394
f0104065:	c6 05 95 f3 32 f0 8e 	movb   $0x8e,0xf032f395
f010406c:	c1 e8 10             	shr    $0x10,%eax
f010406f:	66 a3 96 f3 32 f0    	mov    %ax,0xf032f396
    SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, t_irq_spurious, 0);
f0104075:	b8 00 49 10 f0       	mov    $0xf0104900,%eax
f010407a:	66 a3 98 f3 32 f0    	mov    %ax,0xf032f398
f0104080:	66 c7 05 9a f3 32 f0 	movw   $0x8,0xf032f39a
f0104087:	08 00 
f0104089:	c6 05 9c f3 32 f0 00 	movb   $0x0,0xf032f39c
f0104090:	c6 05 9d f3 32 f0 8e 	movb   $0x8e,0xf032f39d
f0104097:	c1 e8 10             	shr    $0x10,%eax
f010409a:	66 a3 9e f3 32 f0    	mov    %ax,0xf032f39e
    SETGATE(idt[IRQ_OFFSET + 8], 0, GD_KT, t_irq_8, 0);
f01040a0:	b8 06 49 10 f0       	mov    $0xf0104906,%eax
f01040a5:	66 a3 a0 f3 32 f0    	mov    %ax,0xf032f3a0
f01040ab:	66 c7 05 a2 f3 32 f0 	movw   $0x8,0xf032f3a2
f01040b2:	08 00 
f01040b4:	c6 05 a4 f3 32 f0 00 	movb   $0x0,0xf032f3a4
f01040bb:	c6 05 a5 f3 32 f0 8e 	movb   $0x8e,0xf032f3a5
f01040c2:	c1 e8 10             	shr    $0x10,%eax
f01040c5:	66 a3 a6 f3 32 f0    	mov    %ax,0xf032f3a6
    SETGATE(idt[IRQ_OFFSET + 9], 0, GD_KT, t_irq_9, 0);
f01040cb:	b8 0c 49 10 f0       	mov    $0xf010490c,%eax
f01040d0:	66 a3 a8 f3 32 f0    	mov    %ax,0xf032f3a8
f01040d6:	66 c7 05 aa f3 32 f0 	movw   $0x8,0xf032f3aa
f01040dd:	08 00 
f01040df:	c6 05 ac f3 32 f0 00 	movb   $0x0,0xf032f3ac
f01040e6:	c6 05 ad f3 32 f0 8e 	movb   $0x8e,0xf032f3ad
f01040ed:	c1 e8 10             	shr    $0x10,%eax
f01040f0:	66 a3 ae f3 32 f0    	mov    %ax,0xf032f3ae
    SETGATE(idt[IRQ_OFFSET + 10], 0, GD_KT, t_irq_10, 0);
f01040f6:	b8 12 49 10 f0       	mov    $0xf0104912,%eax
f01040fb:	66 a3 b0 f3 32 f0    	mov    %ax,0xf032f3b0
f0104101:	66 c7 05 b2 f3 32 f0 	movw   $0x8,0xf032f3b2
f0104108:	08 00 
f010410a:	c6 05 b4 f3 32 f0 00 	movb   $0x0,0xf032f3b4
f0104111:	c6 05 b5 f3 32 f0 8e 	movb   $0x8e,0xf032f3b5
f0104118:	c1 e8 10             	shr    $0x10,%eax
f010411b:	66 a3 b6 f3 32 f0    	mov    %ax,0xf032f3b6
    SETGATE(idt[IRQ_OFFSET + 11], 0, GD_KT, t_irq_11, 0);
f0104121:	b8 18 49 10 f0       	mov    $0xf0104918,%eax
f0104126:	66 a3 b8 f3 32 f0    	mov    %ax,0xf032f3b8
f010412c:	66 c7 05 ba f3 32 f0 	movw   $0x8,0xf032f3ba
f0104133:	08 00 
f0104135:	c6 05 bc f3 32 f0 00 	movb   $0x0,0xf032f3bc
f010413c:	c6 05 bd f3 32 f0 8e 	movb   $0x8e,0xf032f3bd
f0104143:	c1 e8 10             	shr    $0x10,%eax
f0104146:	66 a3 be f3 32 f0    	mov    %ax,0xf032f3be
    SETGATE(idt[IRQ_OFFSET + 12], 0, GD_KT, t_irq_12, 0);
f010414c:	b8 1e 49 10 f0       	mov    $0xf010491e,%eax
f0104151:	66 a3 c0 f3 32 f0    	mov    %ax,0xf032f3c0
f0104157:	66 c7 05 c2 f3 32 f0 	movw   $0x8,0xf032f3c2
f010415e:	08 00 
f0104160:	c6 05 c4 f3 32 f0 00 	movb   $0x0,0xf032f3c4
f0104167:	c6 05 c5 f3 32 f0 8e 	movb   $0x8e,0xf032f3c5
f010416e:	c1 e8 10             	shr    $0x10,%eax
f0104171:	66 a3 c6 f3 32 f0    	mov    %ax,0xf032f3c6
    SETGATE(idt[IRQ_OFFSET + 13], 0, GD_KT, t_irq_13, 0);
f0104177:	b8 24 49 10 f0       	mov    $0xf0104924,%eax
f010417c:	66 a3 c8 f3 32 f0    	mov    %ax,0xf032f3c8
f0104182:	66 c7 05 ca f3 32 f0 	movw   $0x8,0xf032f3ca
f0104189:	08 00 
f010418b:	c6 05 cc f3 32 f0 00 	movb   $0x0,0xf032f3cc
f0104192:	c6 05 cd f3 32 f0 8e 	movb   $0x8e,0xf032f3cd
f0104199:	c1 e8 10             	shr    $0x10,%eax
f010419c:	66 a3 ce f3 32 f0    	mov    %ax,0xf032f3ce
    SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 0, GD_KT, t_irq_ide, 0);
f01041a2:	b8 2a 49 10 f0       	mov    $0xf010492a,%eax
f01041a7:	66 a3 d0 f3 32 f0    	mov    %ax,0xf032f3d0
f01041ad:	66 c7 05 d2 f3 32 f0 	movw   $0x8,0xf032f3d2
f01041b4:	08 00 
f01041b6:	c6 05 d4 f3 32 f0 00 	movb   $0x0,0xf032f3d4
f01041bd:	c6 05 d5 f3 32 f0 8e 	movb   $0x8e,0xf032f3d5
f01041c4:	c1 e8 10             	shr    $0x10,%eax
f01041c7:	66 a3 d6 f3 32 f0    	mov    %ax,0xf032f3d6
    SETGATE(idt[IRQ_OFFSET + 15], 0, GD_KT, t_irq_15, 0);
f01041cd:	b8 30 49 10 f0       	mov    $0xf0104930,%eax
f01041d2:	66 a3 d8 f3 32 f0    	mov    %ax,0xf032f3d8
f01041d8:	66 c7 05 da f3 32 f0 	movw   $0x8,0xf032f3da
f01041df:	08 00 
f01041e1:	c6 05 dc f3 32 f0 00 	movb   $0x0,0xf032f3dc
f01041e8:	c6 05 dd f3 32 f0 8e 	movb   $0x8e,0xf032f3dd
f01041ef:	c1 e8 10             	shr    $0x10,%eax
f01041f2:	66 a3 de f3 32 f0    	mov    %ax,0xf032f3de
    SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall, 3);
f01041f8:	b8 36 49 10 f0       	mov    $0xf0104936,%eax
f01041fd:	66 a3 e0 f3 32 f0    	mov    %ax,0xf032f3e0
f0104203:	66 c7 05 e2 f3 32 f0 	movw   $0x8,0xf032f3e2
f010420a:	08 00 
f010420c:	c6 05 e4 f3 32 f0 00 	movb   $0x0,0xf032f3e4
f0104213:	c6 05 e5 f3 32 f0 ee 	movb   $0xee,0xf032f3e5
f010421a:	c1 e8 10             	shr    $0x10,%eax
f010421d:	66 a3 e6 f3 32 f0    	mov    %ax,0xf032f3e6
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
f010423a:	68 d9 7d 10 f0       	push   $0xf0107dd9
f010423f:	e8 fa f8 ff ff       	call   f0103b3e <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0104244:	83 c4 08             	add    $0x8,%esp
f0104247:	ff 73 04             	pushl  0x4(%ebx)
f010424a:	68 e8 7d 10 f0       	push   $0xf0107de8
f010424f:	e8 ea f8 ff ff       	call   f0103b3e <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0104254:	83 c4 08             	add    $0x8,%esp
f0104257:	ff 73 08             	pushl  0x8(%ebx)
f010425a:	68 f7 7d 10 f0       	push   $0xf0107df7
f010425f:	e8 da f8 ff ff       	call   f0103b3e <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104264:	83 c4 08             	add    $0x8,%esp
f0104267:	ff 73 0c             	pushl  0xc(%ebx)
f010426a:	68 06 7e 10 f0       	push   $0xf0107e06
f010426f:	e8 ca f8 ff ff       	call   f0103b3e <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104274:	83 c4 08             	add    $0x8,%esp
f0104277:	ff 73 10             	pushl  0x10(%ebx)
f010427a:	68 15 7e 10 f0       	push   $0xf0107e15
f010427f:	e8 ba f8 ff ff       	call   f0103b3e <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104284:	83 c4 08             	add    $0x8,%esp
f0104287:	ff 73 14             	pushl  0x14(%ebx)
f010428a:	68 24 7e 10 f0       	push   $0xf0107e24
f010428f:	e8 aa f8 ff ff       	call   f0103b3e <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0104294:	83 c4 08             	add    $0x8,%esp
f0104297:	ff 73 18             	pushl  0x18(%ebx)
f010429a:	68 33 7e 10 f0       	push   $0xf0107e33
f010429f:	e8 9a f8 ff ff       	call   f0103b3e <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01042a4:	83 c4 08             	add    $0x8,%esp
f01042a7:	ff 73 1c             	pushl  0x1c(%ebx)
f01042aa:	68 42 7e 10 f0       	push   $0xf0107e42
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
f01042c8:	e8 15 21 00 00       	call   f01063e2 <cpunum>
f01042cd:	83 ec 04             	sub    $0x4,%esp
f01042d0:	50                   	push   %eax
f01042d1:	53                   	push   %ebx
f01042d2:	68 a6 7e 10 f0       	push   $0xf0107ea6
f01042d7:	e8 62 f8 ff ff       	call   f0103b3e <cprintf>
	print_regs(&tf->tf_regs);
f01042dc:	89 1c 24             	mov    %ebx,(%esp)
f01042df:	e8 46 ff ff ff       	call   f010422a <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01042e4:	83 c4 08             	add    $0x8,%esp
f01042e7:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01042eb:	50                   	push   %eax
f01042ec:	68 c4 7e 10 f0       	push   $0xf0107ec4
f01042f1:	e8 48 f8 ff ff       	call   f0103b3e <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01042f6:	83 c4 08             	add    $0x8,%esp
f01042f9:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01042fd:	50                   	push   %eax
f01042fe:	68 d7 7e 10 f0       	push   $0xf0107ed7
f0104303:	e8 36 f8 ff ff       	call   f0103b3e <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104308:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f010430b:	83 c4 10             	add    $0x10,%esp
f010430e:	83 f8 13             	cmp    $0x13,%eax
f0104311:	0f 86 da 00 00 00    	jbe    f01043f1 <print_trapframe+0x135>
		return "System call";
f0104317:	ba 51 7e 10 f0       	mov    $0xf0107e51,%edx
	if (trapno == T_SYSCALL)
f010431c:	83 f8 30             	cmp    $0x30,%eax
f010431f:	74 13                	je     f0104334 <print_trapframe+0x78>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104321:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f0104324:	83 fa 0f             	cmp    $0xf,%edx
f0104327:	ba 5d 7e 10 f0       	mov    $0xf0107e5d,%edx
f010432c:	b9 6c 7e 10 f0       	mov    $0xf0107e6c,%ecx
f0104331:	0f 46 d1             	cmovbe %ecx,%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104334:	83 ec 04             	sub    $0x4,%esp
f0104337:	52                   	push   %edx
f0104338:	50                   	push   %eax
f0104339:	68 ea 7e 10 f0       	push   $0xf0107eea
f010433e:	e8 fb f7 ff ff       	call   f0103b3e <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104343:	83 c4 10             	add    $0x10,%esp
f0104346:	39 1d 60 fa 32 f0    	cmp    %ebx,0xf032fa60
f010434c:	0f 84 ab 00 00 00    	je     f01043fd <print_trapframe+0x141>
	cprintf("  err  0x%08x", tf->tf_err);
f0104352:	83 ec 08             	sub    $0x8,%esp
f0104355:	ff 73 2c             	pushl  0x2c(%ebx)
f0104358:	68 0b 7f 10 f0       	push   $0xf0107f0b
f010435d:	e8 dc f7 ff ff       	call   f0103b3e <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0104362:	83 c4 10             	add    $0x10,%esp
f0104365:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104369:	0f 85 b1 00 00 00    	jne    f0104420 <print_trapframe+0x164>
			tf->tf_err & 1 ? "protection" : "not-present");
f010436f:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f0104372:	a8 01                	test   $0x1,%al
f0104374:	b9 7f 7e 10 f0       	mov    $0xf0107e7f,%ecx
f0104379:	ba 8a 7e 10 f0       	mov    $0xf0107e8a,%edx
f010437e:	0f 44 ca             	cmove  %edx,%ecx
f0104381:	a8 02                	test   $0x2,%al
f0104383:	be 96 7e 10 f0       	mov    $0xf0107e96,%esi
f0104388:	ba 9c 7e 10 f0       	mov    $0xf0107e9c,%edx
f010438d:	0f 45 d6             	cmovne %esi,%edx
f0104390:	a8 04                	test   $0x4,%al
f0104392:	b8 a1 7e 10 f0       	mov    $0xf0107ea1,%eax
f0104397:	be d6 7f 10 f0       	mov    $0xf0107fd6,%esi
f010439c:	0f 44 c6             	cmove  %esi,%eax
f010439f:	51                   	push   %ecx
f01043a0:	52                   	push   %edx
f01043a1:	50                   	push   %eax
f01043a2:	68 19 7f 10 f0       	push   $0xf0107f19
f01043a7:	e8 92 f7 ff ff       	call   f0103b3e <cprintf>
f01043ac:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01043af:	83 ec 08             	sub    $0x8,%esp
f01043b2:	ff 73 30             	pushl  0x30(%ebx)
f01043b5:	68 28 7f 10 f0       	push   $0xf0107f28
f01043ba:	e8 7f f7 ff ff       	call   f0103b3e <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01043bf:	83 c4 08             	add    $0x8,%esp
f01043c2:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01043c6:	50                   	push   %eax
f01043c7:	68 37 7f 10 f0       	push   $0xf0107f37
f01043cc:	e8 6d f7 ff ff       	call   f0103b3e <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01043d1:	83 c4 08             	add    $0x8,%esp
f01043d4:	ff 73 38             	pushl  0x38(%ebx)
f01043d7:	68 4a 7f 10 f0       	push   $0xf0107f4a
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
f01043f1:	8b 14 85 80 81 10 f0 	mov    -0xfef7e80(,%eax,4),%edx
f01043f8:	e9 37 ff ff ff       	jmp    f0104334 <print_trapframe+0x78>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01043fd:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104401:	0f 85 4b ff ff ff    	jne    f0104352 <print_trapframe+0x96>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0104407:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010440a:	83 ec 08             	sub    $0x8,%esp
f010440d:	50                   	push   %eax
f010440e:	68 fc 7e 10 f0       	push   $0xf0107efc
f0104413:	e8 26 f7 ff ff       	call   f0103b3e <cprintf>
f0104418:	83 c4 10             	add    $0x10,%esp
f010441b:	e9 32 ff ff ff       	jmp    f0104352 <print_trapframe+0x96>
		cprintf("\n");
f0104420:	83 ec 0c             	sub    $0xc,%esp
f0104423:	68 40 7c 10 f0       	push   $0xf0107c40
f0104428:	e8 11 f7 ff ff       	call   f0103b3e <cprintf>
f010442d:	83 c4 10             	add    $0x10,%esp
f0104430:	e9 7a ff ff ff       	jmp    f01043af <print_trapframe+0xf3>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104435:	83 ec 08             	sub    $0x8,%esp
f0104438:	ff 73 3c             	pushl  0x3c(%ebx)
f010443b:	68 59 7f 10 f0       	push   $0xf0107f59
f0104440:	e8 f9 f6 ff ff       	call   f0103b3e <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104445:	83 c4 08             	add    $0x8,%esp
f0104448:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010444c:	50                   	push   %eax
f010444d:	68 68 7f 10 f0       	push   $0xf0107f68
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
f0104475:	e8 68 1f 00 00       	call   f01063e2 <cpunum>
f010447a:	6b c0 74             	imul   $0x74,%eax,%eax
f010447d:	8b 80 28 00 33 f0    	mov    -0xfccffd8(%eax),%eax
f0104483:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104487:	75 64                	jne    f01044ed <page_fault_handler+0x91>
        // no pgfault handler!
        // Destroy the environment that caused the fault.
        cprintf("[%08x] user fault va %08x ip %08x\n",
f0104489:	8b 7b 30             	mov    0x30(%ebx),%edi
                curenv->env_id, fault_va, tf->tf_eip);
f010448c:	e8 51 1f 00 00       	call   f01063e2 <cpunum>
        cprintf("[%08x] user fault va %08x ip %08x\n",
f0104491:	57                   	push   %edi
f0104492:	56                   	push   %esi
                curenv->env_id, fault_va, tf->tf_eip);
f0104493:	6b c0 74             	imul   $0x74,%eax,%eax
        cprintf("[%08x] user fault va %08x ip %08x\n",
f0104496:	8b 80 28 00 33 f0    	mov    -0xfccffd8(%eax),%eax
f010449c:	ff 70 48             	pushl  0x48(%eax)
f010449f:	68 50 81 10 f0       	push   $0xf0108150
f01044a4:	e8 95 f6 ff ff       	call   f0103b3e <cprintf>
        print_trapframe(tf);
f01044a9:	89 1c 24             	mov    %ebx,(%esp)
f01044ac:	e8 0b fe ff ff       	call   f01042bc <print_trapframe>
        env_destroy(curenv);
f01044b1:	e8 2c 1f 00 00       	call   f01063e2 <cpunum>
f01044b6:	83 c4 04             	add    $0x4,%esp
f01044b9:	6b c0 74             	imul   $0x74,%eax,%eax
f01044bc:	ff b0 28 00 33 f0    	pushl  -0xfccffd8(%eax)
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
f01044d9:	68 20 81 10 f0       	push   $0xf0108120
f01044de:	68 9a 01 00 00       	push   $0x19a
f01044e3:	68 7b 7f 10 f0       	push   $0xf0107f7b
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
f0104554:	e8 89 1e 00 00       	call   f01063e2 <cpunum>
f0104559:	6a 07                	push   $0x7
f010455b:	6a 34                	push   $0x34
f010455d:	57                   	push   %edi
f010455e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104561:	ff b0 28 00 33 f0    	pushl  -0xfccffd8(%eax)
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
f01045b9:	e8 24 1e 00 00       	call   f01063e2 <cpunum>
f01045be:	6b c0 74             	imul   $0x74,%eax,%eax
f01045c1:	8b 80 28 00 33 f0    	mov    -0xfccffd8(%eax),%eax
f01045c7:	8b 40 64             	mov    0x64(%eax),%eax
f01045ca:	89 43 30             	mov    %eax,0x30(%ebx)
    env_run(curenv);
f01045cd:	e8 10 1e 00 00       	call   f01063e2 <cpunum>
f01045d2:	83 c4 04             	add    $0x4,%esp
f01045d5:	6b c0 74             	imul   $0x74,%eax,%eax
f01045d8:	ff b0 28 00 33 f0    	pushl  -0xfccffd8(%eax)
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
f01045fb:	83 3d 80 fe 32 f0 00 	cmpl   $0x0,0xf032fe80
f0104602:	74 01                	je     f0104605 <trap+0x17>
		asm volatile("hlt");
f0104604:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104605:	e8 d8 1d 00 00       	call   f01063e2 <cpunum>
f010460a:	6b d0 74             	imul   $0x74,%eax,%edx
f010460d:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f0104610:	b8 01 00 00 00       	mov    $0x1,%eax
f0104615:	f0 87 82 20 00 33 f0 	lock xchg %eax,-0xfccffe0(%edx)
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
f0104635:	89 35 60 fa 32 f0    	mov    %esi,0xf032fa60
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
f010468b:	e8 da 1f 00 00       	call   f010666a <spin_lock>
}
f0104690:	83 c4 10             	add    $0x10,%esp
f0104693:	eb 8c                	jmp    f0104621 <trap+0x33>
	assert(!(read_eflags() & FL_IF));
f0104695:	68 87 7f 10 f0       	push   $0xf0107f87
f010469a:	68 79 79 10 f0       	push   $0xf0107979
f010469f:	68 62 01 00 00       	push   $0x162
f01046a4:	68 7b 7f 10 f0       	push   $0xf0107f7b
f01046a9:	e8 92 b9 ff ff       	call   f0100040 <_panic>
	spin_lock(&kernel_lock);
f01046ae:	83 ec 0c             	sub    $0xc,%esp
f01046b1:	68 c0 43 12 f0       	push   $0xf01243c0
f01046b6:	e8 af 1f 00 00       	call   f010666a <spin_lock>
		assert(curenv);
f01046bb:	e8 22 1d 00 00       	call   f01063e2 <cpunum>
f01046c0:	6b c0 74             	imul   $0x74,%eax,%eax
f01046c3:	83 c4 10             	add    $0x10,%esp
f01046c6:	83 b8 28 00 33 f0 00 	cmpl   $0x0,-0xfccffd8(%eax)
f01046cd:	74 3e                	je     f010470d <trap+0x11f>
		if (curenv->env_status == ENV_DYING) {
f01046cf:	e8 0e 1d 00 00       	call   f01063e2 <cpunum>
f01046d4:	6b c0 74             	imul   $0x74,%eax,%eax
f01046d7:	8b 80 28 00 33 f0    	mov    -0xfccffd8(%eax),%eax
f01046dd:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01046e1:	74 43                	je     f0104726 <trap+0x138>
		curenv->env_tf = *tf;
f01046e3:	e8 fa 1c 00 00       	call   f01063e2 <cpunum>
f01046e8:	6b c0 74             	imul   $0x74,%eax,%eax
f01046eb:	8b 80 28 00 33 f0    	mov    -0xfccffd8(%eax),%eax
f01046f1:	b9 11 00 00 00       	mov    $0x11,%ecx
f01046f6:	89 c7                	mov    %eax,%edi
f01046f8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f01046fa:	e8 e3 1c 00 00       	call   f01063e2 <cpunum>
f01046ff:	6b c0 74             	imul   $0x74,%eax,%eax
f0104702:	8b b0 28 00 33 f0    	mov    -0xfccffd8(%eax),%esi
f0104708:	e9 28 ff ff ff       	jmp    f0104635 <trap+0x47>
		assert(curenv);
f010470d:	68 a0 7f 10 f0       	push   $0xf0107fa0
f0104712:	68 79 79 10 f0       	push   $0xf0107979
f0104717:	68 6a 01 00 00       	push   $0x16a
f010471c:	68 7b 7f 10 f0       	push   $0xf0107f7b
f0104721:	e8 1a b9 ff ff       	call   f0100040 <_panic>
			env_free(curenv);
f0104726:	e8 b7 1c 00 00       	call   f01063e2 <cpunum>
f010472b:	83 ec 0c             	sub    $0xc,%esp
f010472e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104731:	ff b0 28 00 33 f0    	pushl  -0xfccffd8(%eax)
f0104737:	e8 ea ee ff ff       	call   f0103626 <env_free>
			curenv = NULL;
f010473c:	e8 a1 1c 00 00       	call   f01063e2 <cpunum>
f0104741:	6b c0 74             	imul   $0x74,%eax,%eax
f0104744:	c7 80 28 00 33 f0 00 	movl   $0x0,-0xfccffd8(%eax)
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
f0104776:	e8 67 1c 00 00       	call   f01063e2 <cpunum>
f010477b:	6b c0 74             	imul   $0x74,%eax,%eax
f010477e:	83 b8 28 00 33 f0 00 	cmpl   $0x0,-0xfccffd8(%eax)
f0104785:	74 18                	je     f010479f <trap+0x1b1>
f0104787:	e8 56 1c 00 00       	call   f01063e2 <cpunum>
f010478c:	6b c0 74             	imul   $0x74,%eax,%eax
f010478f:	8b 80 28 00 33 f0    	mov    -0xfccffd8(%eax),%eax
f0104795:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104799:	0f 84 8e 00 00 00    	je     f010482d <trap+0x23f>
		sched_yield();
f010479f:	e8 78 02 00 00       	call   f0104a1c <sched_yield>
            lapic_eoi();
f01047a4:	e8 88 1d 00 00       	call   f0106531 <lapic_eoi>
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
f01047c7:	68 a7 7f 10 f0       	push   $0xf0107fa7
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
f01047f8:	e8 e5 1b 00 00       	call   f01063e2 <cpunum>
f01047fd:	83 ec 0c             	sub    $0xc,%esp
f0104800:	6b c0 74             	imul   $0x74,%eax,%eax
f0104803:	ff b0 28 00 33 f0    	pushl  -0xfccffd8(%eax)
f0104809:	e8 f9 ef ff ff       	call   f0103807 <env_destroy>
		return;
f010480e:	83 c4 10             	add    $0x10,%esp
f0104811:	e9 60 ff ff ff       	jmp    f0104776 <trap+0x188>
		panic("unhandled trap in kernel");
f0104816:	83 ec 04             	sub    $0x4,%esp
f0104819:	68 c4 7f 10 f0       	push   $0xf0107fc4
f010481e:	68 48 01 00 00       	push   $0x148
f0104823:	68 7b 7f 10 f0       	push   $0xf0107f7b
f0104828:	e8 13 b8 ff ff       	call   f0100040 <_panic>
		env_run(curenv);
f010482d:	e8 b0 1b 00 00       	call   f01063e2 <cpunum>
f0104832:	83 ec 0c             	sub    $0xc,%esp
f0104835:	6b c0 74             	imul   $0x74,%eax,%eax
f0104838:	ff b0 28 00 33 f0    	pushl  -0xfccffd8(%eax)
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
f0104958:	a1 44 f2 32 f0       	mov    0xf032f244,%eax
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
f0104980:	68 d0 81 10 f0       	push   $0xf01081d0
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
f010499c:	e8 41 1a 00 00       	call   f01063e2 <cpunum>
f01049a1:	6b c0 74             	imul   $0x74,%eax,%eax
f01049a4:	c7 80 28 00 33 f0 00 	movl   $0x0,-0xfccffd8(%eax)
f01049ab:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f01049ae:	a1 8c fe 32 f0       	mov    0xf032fe8c,%eax
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
f01049c2:	e8 1b 1a 00 00       	call   f01063e2 <cpunum>
f01049c7:	6b d0 74             	imul   $0x74,%eax,%edx
f01049ca:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f01049cd:	b8 02 00 00 00       	mov    $0x2,%eax
f01049d2:	f0 87 82 20 00 33 f0 	lock xchg %eax,-0xfccffe0(%edx)
	spin_unlock(&kernel_lock);
f01049d9:	83 ec 0c             	sub    $0xc,%esp
f01049dc:	68 c0 43 12 f0       	push   $0xf01243c0
f01049e1:	e8 22 1d 00 00       	call   f0106708 <spin_unlock>
	asm volatile("pause");
f01049e6:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f01049e8:	e8 f5 19 00 00       	call   f01063e2 <cpunum>
f01049ed:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile (
f01049f0:	8b 80 30 00 33 f0    	mov    -0xfccffd0(%eax),%eax
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
f0104a0b:	68 a8 6a 10 f0       	push   $0xf0106aa8
f0104a10:	6a 50                	push   $0x50
f0104a12:	68 f9 81 10 f0       	push   $0xf01081f9
f0104a17:	e8 24 b6 ff ff       	call   f0100040 <_panic>

f0104a1c <sched_yield>:
{
f0104a1c:	f3 0f 1e fb          	endbr32 
f0104a20:	55                   	push   %ebp
f0104a21:	89 e5                	mov    %esp,%ebp
f0104a23:	56                   	push   %esi
f0104a24:	53                   	push   %ebx
    for (uint32_t i = probing_env_idx; i < (probing_env_idx + NENV); ++i) {
f0104a25:	8b 1d 64 fa 32 f0    	mov    0xf032fa64,%ebx
        if (envs[env_idx].env_status == ENV_RUNNABLE) {
f0104a2b:	8b 35 44 f2 32 f0    	mov    0xf032f244,%esi
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
f0104a5d:	a3 64 fa 32 f0       	mov    %eax,0xf032fa64
            env_run(target_env);
f0104a62:	83 ec 0c             	sub    $0xc,%esp
f0104a65:	52                   	push   %edx
f0104a66:	e8 62 ee ff ff       	call   f01038cd <env_run>
    if (curenv && curenv->env_status == ENV_RUNNING) {
f0104a6b:	e8 72 19 00 00       	call   f01063e2 <cpunum>
f0104a70:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a73:	83 b8 28 00 33 f0 00 	cmpl   $0x0,-0xfccffd8(%eax)
f0104a7a:	74 14                	je     f0104a90 <sched_yield+0x74>
f0104a7c:	e8 61 19 00 00       	call   f01063e2 <cpunum>
f0104a81:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a84:	8b 80 28 00 33 f0    	mov    -0xfccffd8(%eax),%eax
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
f0104a9c:	e8 41 19 00 00       	call   f01063e2 <cpunum>
f0104aa1:	83 ec 0c             	sub    $0xc,%esp
f0104aa4:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aa7:	ff b0 28 00 33 f0    	pushl  -0xfccffd8(%eax)
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
f0104abb:	53                   	push   %ebx
f0104abc:	83 ec 1c             	sub    $0x1c,%esp
f0104abf:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ac2:	8b 75 10             	mov    0x10(%ebp),%esi
f0104ac5:	83 f8 0d             	cmp    $0xd,%eax
f0104ac8:	0f 87 a4 06 00 00    	ja     f0105172 <syscall+0x6c0>
f0104ace:	3e ff 24 85 74 82 10 	notrack jmp *-0xfef7d8c(,%eax,4)
f0104ad5:	f0 
    user_mem_assert(curenv, s, len, PTE_U|PTE_P);
f0104ad6:	e8 07 19 00 00       	call   f01063e2 <cpunum>
f0104adb:	6a 05                	push   $0x5
f0104add:	56                   	push   %esi
f0104ade:	ff 75 0c             	pushl  0xc(%ebp)
f0104ae1:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ae4:	ff b0 28 00 33 f0    	pushl  -0xfccffd8(%eax)
f0104aea:	e8 fc e5 ff ff       	call   f01030eb <user_mem_assert>
	cprintf("%.*s", len, s);
f0104aef:	83 c4 0c             	add    $0xc,%esp
f0104af2:	ff 75 0c             	pushl  0xc(%ebp)
f0104af5:	56                   	push   %esi
f0104af6:	68 15 6e 10 f0       	push   $0xf0106e15
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
f0104b08:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104b0b:	5b                   	pop    %ebx
f0104b0c:	5e                   	pop    %esi
f0104b0d:	5f                   	pop    %edi
f0104b0e:	5d                   	pop    %ebp
f0104b0f:	c3                   	ret    
	return cons_getc();
f0104b10:	e8 fe ba ff ff       	call   f0100613 <cons_getc>
        return sys_cgetc();
f0104b15:	eb f1                	jmp    f0104b08 <syscall+0x56>
	return curenv->env_id;
f0104b17:	e8 c6 18 00 00       	call   f01063e2 <cpunum>
f0104b1c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b1f:	8b 80 28 00 33 f0    	mov    -0xfccffd8(%eax),%eax
f0104b25:	8b 40 48             	mov    0x48(%eax),%eax
        return (int32_t) sys_getenvid();
f0104b28:	eb de                	jmp    f0104b08 <syscall+0x56>
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104b2a:	83 ec 04             	sub    $0x4,%esp
f0104b2d:	6a 01                	push   $0x1
f0104b2f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104b32:	50                   	push   %eax
f0104b33:	ff 75 0c             	pushl  0xc(%ebp)
f0104b36:	e8 bd e6 ff ff       	call   f01031f8 <envid2env>
f0104b3b:	83 c4 10             	add    $0x10,%esp
f0104b3e:	85 c0                	test   %eax,%eax
f0104b40:	78 c6                	js     f0104b08 <syscall+0x56>
	if (e == curenv)
f0104b42:	e8 9b 18 00 00       	call   f01063e2 <cpunum>
f0104b47:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104b4a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b4d:	39 90 28 00 33 f0    	cmp    %edx,-0xfccffd8(%eax)
f0104b53:	74 3d                	je     f0104b92 <syscall+0xe0>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104b55:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104b58:	e8 85 18 00 00       	call   f01063e2 <cpunum>
f0104b5d:	83 ec 04             	sub    $0x4,%esp
f0104b60:	53                   	push   %ebx
f0104b61:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b64:	8b 80 28 00 33 f0    	mov    -0xfccffd8(%eax),%eax
f0104b6a:	ff 70 48             	pushl  0x48(%eax)
f0104b6d:	68 21 82 10 f0       	push   $0xf0108221
f0104b72:	e8 c7 ef ff ff       	call   f0103b3e <cprintf>
f0104b77:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104b7a:	83 ec 0c             	sub    $0xc,%esp
f0104b7d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104b80:	e8 82 ec ff ff       	call   f0103807 <env_destroy>
	return 0;
f0104b85:	83 c4 10             	add    $0x10,%esp
f0104b88:	b8 00 00 00 00       	mov    $0x0,%eax
        return sys_env_destroy((envid_t) a1);
f0104b8d:	e9 76 ff ff ff       	jmp    f0104b08 <syscall+0x56>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104b92:	e8 4b 18 00 00       	call   f01063e2 <cpunum>
f0104b97:	83 ec 08             	sub    $0x8,%esp
f0104b9a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b9d:	8b 80 28 00 33 f0    	mov    -0xfccffd8(%eax),%eax
f0104ba3:	ff 70 48             	pushl  0x48(%eax)
f0104ba6:	68 06 82 10 f0       	push   $0xf0108206
f0104bab:	e8 8e ef ff ff       	call   f0103b3e <cprintf>
f0104bb0:	83 c4 10             	add    $0x10,%esp
f0104bb3:	eb c5                	jmp    f0104b7a <syscall+0xc8>
	sched_yield();
f0104bb5:	e8 62 fe ff ff       	call   f0104a1c <sched_yield>
    struct Env *e = NULL;
f0104bba:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    if (envid2env(envid, &e, 1) < 0) {
f0104bc1:	83 ec 04             	sub    $0x4,%esp
f0104bc4:	6a 01                	push   $0x1
f0104bc6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104bc9:	50                   	push   %eax
f0104bca:	ff 75 0c             	pushl  0xc(%ebp)
f0104bcd:	e8 26 e6 ff ff       	call   f01031f8 <envid2env>
f0104bd2:	83 c4 10             	add    $0x10,%esp
f0104bd5:	85 c0                	test   %eax,%eax
f0104bd7:	0f 88 89 00 00 00    	js     f0104c66 <syscall+0x1b4>
    if (e == NULL) {
f0104bdd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104be1:	0f 84 89 00 00 00    	je     f0104c70 <syscall+0x1be>
    if (((uintptr_t)va) >= UTOP) {
f0104be7:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104bed:	0f 87 87 00 00 00    	ja     f0104c7a <syscall+0x1c8>
    if (!(PTE_P & perm)) {
f0104bf3:	8b 45 14             	mov    0x14(%ebp),%eax
f0104bf6:	83 e0 05             	and    $0x5,%eax
f0104bf9:	83 f8 05             	cmp    $0x5,%eax
f0104bfc:	0f 85 82 00 00 00    	jne    f0104c84 <syscall+0x1d2>
    struct PageInfo *pp = page_alloc(ALLOC_ZERO);
f0104c02:	83 ec 0c             	sub    $0xc,%esp
f0104c05:	6a 01                	push   $0x1
f0104c07:	e8 f2 c3 ff ff       	call   f0100ffe <page_alloc>
f0104c0c:	89 c3                	mov    %eax,%ebx
    if (pp == NULL) {
f0104c0e:	83 c4 10             	add    $0x10,%esp
f0104c11:	85 c0                	test   %eax,%eax
f0104c13:	74 79                	je     f0104c8e <syscall+0x1dc>
    if (page_insert(e->env_pgdir, pp, va, perm) != 0) {
f0104c15:	ff 75 14             	pushl  0x14(%ebp)
f0104c18:	56                   	push   %esi
f0104c19:	50                   	push   %eax
f0104c1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c1d:	ff 70 60             	pushl  0x60(%eax)
f0104c20:	e8 a7 c6 ff ff       	call   f01012cc <page_insert>
f0104c25:	83 c4 10             	add    $0x10,%esp
f0104c28:	85 c0                	test   %eax,%eax
f0104c2a:	0f 84 d8 fe ff ff    	je     f0104b08 <syscall+0x56>
        assert(pp->pp_ref == 0);
f0104c30:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0104c35:	75 16                	jne    f0104c4d <syscall+0x19b>
        page_free(pp);
f0104c37:	83 ec 0c             	sub    $0xc,%esp
f0104c3a:	53                   	push   %ebx
f0104c3b:	e8 37 c4 ff ff       	call   f0101077 <page_free>
        return -E_NO_MEM;
f0104c40:	83 c4 10             	add    $0x10,%esp
f0104c43:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104c48:	e9 bb fe ff ff       	jmp    f0104b08 <syscall+0x56>
        assert(pp->pp_ref == 0);
f0104c4d:	68 39 82 10 f0       	push   $0xf0108239
f0104c52:	68 79 79 10 f0       	push   $0xf0107979
f0104c57:	68 fb 00 00 00       	push   $0xfb
f0104c5c:	68 49 82 10 f0       	push   $0xf0108249
f0104c61:	e8 da b3 ff ff       	call   f0100040 <_panic>
        return -E_BAD_ENV;
f0104c66:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104c6b:	e9 98 fe ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_BAD_ENV;
f0104c70:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104c75:	e9 8e fe ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_INVAL;
f0104c7a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104c7f:	e9 84 fe ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_INVAL;
f0104c84:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104c89:	e9 7a fe ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_NO_MEM;
f0104c8e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
        return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
f0104c93:	e9 70 fe ff ff       	jmp    f0104b08 <syscall+0x56>
    struct Env *srcenv = NULL;
f0104c98:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
    if (envid2env(srcenvid, &srcenv, 1) < 0)
f0104c9f:	83 ec 04             	sub    $0x4,%esp
f0104ca2:	6a 01                	push   $0x1
f0104ca4:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0104ca7:	50                   	push   %eax
f0104ca8:	ff 75 0c             	pushl  0xc(%ebp)
f0104cab:	e8 48 e5 ff ff       	call   f01031f8 <envid2env>
f0104cb0:	83 c4 10             	add    $0x10,%esp
f0104cb3:	85 c0                	test   %eax,%eax
f0104cb5:	0f 88 06 01 00 00    	js     f0104dc1 <syscall+0x30f>
    if (srcenv == NULL)
f0104cbb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104cbf:	0f 84 06 01 00 00    	je     f0104dcb <syscall+0x319>
    struct Env *dstenv = NULL;
f0104cc5:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    if (envid2env(dstenvid, &dstenv, 1) < 0)
f0104ccc:	83 ec 04             	sub    $0x4,%esp
f0104ccf:	6a 01                	push   $0x1
f0104cd1:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104cd4:	50                   	push   %eax
f0104cd5:	ff 75 14             	pushl  0x14(%ebp)
f0104cd8:	e8 1b e5 ff ff       	call   f01031f8 <envid2env>
f0104cdd:	83 c4 10             	add    $0x10,%esp
f0104ce0:	85 c0                	test   %eax,%eax
f0104ce2:	0f 88 ed 00 00 00    	js     f0104dd5 <syscall+0x323>
    if (dstenv == NULL)
f0104ce8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0104cec:	0f 84 ed 00 00 00    	je     f0104ddf <syscall+0x32d>
    if ( ((uintptr_t)dstva) >= UTOP )
f0104cf2:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104cf8:	0f 87 eb 00 00 00    	ja     f0104de9 <syscall+0x337>
f0104cfe:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104d05:	0f 87 de 00 00 00    	ja     f0104de9 <syscall+0x337>
    if (!(PTE_P & perm)) {
f0104d0b:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0104d0e:	83 e0 05             	and    $0x5,%eax
f0104d11:	83 f8 05             	cmp    $0x5,%eax
f0104d14:	0f 85 d9 00 00 00    	jne    f0104df3 <syscall+0x341>
    pte_t *src_pte = NULL, *dst_pte = NULL;
f0104d1a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0104d21:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    struct PageInfo *src_pp = page_lookup(srcenv->env_pgdir, srcva, &src_pte);
f0104d28:	83 ec 04             	sub    $0x4,%esp
f0104d2b:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104d2e:	50                   	push   %eax
f0104d2f:	56                   	push   %esi
f0104d30:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104d33:	ff 70 60             	pushl  0x60(%eax)
f0104d36:	e8 a8 c4 ff ff       	call   f01011e3 <page_lookup>
f0104d3b:	89 c3                	mov    %eax,%ebx
    if (src_pte == NULL)
f0104d3d:	83 c4 10             	add    $0x10,%esp
f0104d40:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104d44:	0f 84 b3 00 00 00    	je     f0104dfd <syscall+0x34b>
    struct PageInfo *dst_pp = page_lookup(dstenv->env_pgdir, dstva, &dst_pte);
f0104d4a:	83 ec 04             	sub    $0x4,%esp
f0104d4d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104d50:	50                   	push   %eax
f0104d51:	ff 75 18             	pushl  0x18(%ebp)
f0104d54:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104d57:	ff 70 60             	pushl  0x60(%eax)
f0104d5a:	e8 84 c4 ff ff       	call   f01011e3 <page_lookup>
    if (dst_pte == NULL) {
f0104d5f:	83 c4 10             	add    $0x10,%esp
f0104d62:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104d66:	74 32                	je     f0104d9a <syscall+0x2e8>
    if ( (perm&PTE_W) && ((*src_pte & PTE_W) == 0) ) {
f0104d68:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104d6c:	74 0c                	je     f0104d7a <syscall+0x2c8>
f0104d6e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d71:	f6 00 02             	testb  $0x2,(%eax)
f0104d74:	0f 84 8d 00 00 00    	je     f0104e07 <syscall+0x355>
    if (page_insert(dstenv->env_pgdir, src_pp, dstva, perm) < 0)
f0104d7a:	ff 75 1c             	pushl  0x1c(%ebp)
f0104d7d:	ff 75 18             	pushl  0x18(%ebp)
f0104d80:	53                   	push   %ebx
f0104d81:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104d84:	ff 70 60             	pushl  0x60(%eax)
f0104d87:	e8 40 c5 ff ff       	call   f01012cc <page_insert>
f0104d8c:	83 c4 10             	add    $0x10,%esp
        return -E_NO_MEM;
f0104d8f:	c1 f8 1f             	sar    $0x1f,%eax
f0104d92:	83 e0 fc             	and    $0xfffffffc,%eax
f0104d95:	e9 6e fd ff ff       	jmp    f0104b08 <syscall+0x56>
        dst_pte = pgdir_walk(dstenv->env_pgdir, dstva, 1);
f0104d9a:	83 ec 04             	sub    $0x4,%esp
f0104d9d:	6a 01                	push   $0x1
f0104d9f:	ff 75 18             	pushl  0x18(%ebp)
f0104da2:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104da5:	ff 70 60             	pushl  0x60(%eax)
f0104da8:	e8 36 c3 ff ff       	call   f01010e3 <pgdir_walk>
f0104dad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if (dst_pte == NULL) {
f0104db0:	83 c4 10             	add    $0x10,%esp
f0104db3:	85 c0                	test   %eax,%eax
f0104db5:	75 b1                	jne    f0104d68 <syscall+0x2b6>
            return -E_NO_MEM;
f0104db7:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104dbc:	e9 47 fd ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_BAD_ENV;
f0104dc1:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104dc6:	e9 3d fd ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_BAD_ENV;
f0104dcb:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104dd0:	e9 33 fd ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_BAD_ENV;
f0104dd5:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104dda:	e9 29 fd ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_BAD_ENV;
f0104ddf:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104de4:	e9 1f fd ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_INVAL;
f0104de9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104dee:	e9 15 fd ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_INVAL;
f0104df3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104df8:	e9 0b fd ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_NO_MEM;
f0104dfd:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104e02:	e9 01 fd ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_INVAL;
f0104e07:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104e0c:	e9 f7 fc ff ff       	jmp    f0104b08 <syscall+0x56>
    struct Env *e = NULL;
f0104e11:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    if (envid2env(envid, &e, 1) < 0)
f0104e18:	83 ec 04             	sub    $0x4,%esp
f0104e1b:	6a 01                	push   $0x1
f0104e1d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104e20:	50                   	push   %eax
f0104e21:	ff 75 0c             	pushl  0xc(%ebp)
f0104e24:	e8 cf e3 ff ff       	call   f01031f8 <envid2env>
f0104e29:	83 c4 10             	add    $0x10,%esp
f0104e2c:	85 c0                	test   %eax,%eax
f0104e2e:	78 28                	js     f0104e58 <syscall+0x3a6>
    if (e == NULL)
f0104e30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e33:	85 c0                	test   %eax,%eax
f0104e35:	74 2b                	je     f0104e62 <syscall+0x3b0>
    if (((uintptr_t)va) >= UTOP) {
f0104e37:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104e3d:	77 2d                	ja     f0104e6c <syscall+0x3ba>
    page_remove(e->env_pgdir, va);
f0104e3f:	83 ec 08             	sub    $0x8,%esp
f0104e42:	56                   	push   %esi
f0104e43:	ff 70 60             	pushl  0x60(%eax)
f0104e46:	e8 33 c4 ff ff       	call   f010127e <page_remove>
    return 0;
f0104e4b:	83 c4 10             	add    $0x10,%esp
f0104e4e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e53:	e9 b0 fc ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_BAD_ENV;
f0104e58:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104e5d:	e9 a6 fc ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_BAD_ENV;
f0104e62:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104e67:	e9 9c fc ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_INVAL;
f0104e6c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
        return sys_page_unmap((envid_t)a1, (void *)a2);
f0104e71:	e9 92 fc ff ff       	jmp    f0104b08 <syscall+0x56>
    if (env_alloc(&newenv, curenv->env_id) < 0) {
f0104e76:	e8 67 15 00 00       	call   f01063e2 <cpunum>
f0104e7b:	83 ec 08             	sub    $0x8,%esp
f0104e7e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e81:	8b 80 28 00 33 f0    	mov    -0xfccffd8(%eax),%eax
f0104e87:	ff 70 48             	pushl  0x48(%eax)
f0104e8a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104e8d:	50                   	push   %eax
f0104e8e:	e8 87 e4 ff ff       	call   f010331a <env_alloc>
f0104e93:	83 c4 10             	add    $0x10,%esp
f0104e96:	85 c0                	test   %eax,%eax
f0104e98:	78 31                	js     f0104ecb <syscall+0x419>
    newenv->env_tf = curenv->env_tf;
f0104e9a:	e8 43 15 00 00       	call   f01063e2 <cpunum>
f0104e9f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ea2:	8b b0 28 00 33 f0    	mov    -0xfccffd8(%eax),%esi
f0104ea8:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104ead:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104eb0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
    newenv->env_tf.tf_regs.reg_eax = 0;
f0104eb2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104eb5:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    newenv->env_status = ENV_NOT_RUNNABLE;
f0104ebc:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
    return newenv->env_id;
f0104ec3:	8b 40 48             	mov    0x48(%eax),%eax
f0104ec6:	e9 3d fc ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_NO_FREE_ENV;
f0104ecb:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
        return sys_exofork();
f0104ed0:	e9 33 fc ff ff       	jmp    f0104b08 <syscall+0x56>
    struct Env *e = NULL;
f0104ed5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    if (envid2env(envid, &e, 1) < 0) {
f0104edc:	83 ec 04             	sub    $0x4,%esp
f0104edf:	6a 01                	push   $0x1
f0104ee1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104ee4:	50                   	push   %eax
f0104ee5:	ff 75 0c             	pushl  0xc(%ebp)
f0104ee8:	e8 0b e3 ff ff       	call   f01031f8 <envid2env>
f0104eed:	83 c4 10             	add    $0x10,%esp
f0104ef0:	85 c0                	test   %eax,%eax
f0104ef2:	78 19                	js     f0104f0d <syscall+0x45b>
    if (e == NULL) {
f0104ef4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104ef7:	85 c0                	test   %eax,%eax
f0104ef9:	74 1c                	je     f0104f17 <syscall+0x465>
    if (status > ENV_NOT_RUNNABLE || status < ENV_FREE) {
f0104efb:	83 fe 04             	cmp    $0x4,%esi
f0104efe:	77 21                	ja     f0104f21 <syscall+0x46f>
    e->env_status = status;
f0104f00:	89 70 54             	mov    %esi,0x54(%eax)
    return 0;
f0104f03:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f08:	e9 fb fb ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_BAD_ENV;
f0104f0d:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104f12:	e9 f1 fb ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_BAD_ENV;
f0104f17:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104f1c:	e9 e7 fb ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_INVAL;
f0104f21:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
        return sys_env_set_status((envid_t)a1, (int)a2);
f0104f26:	e9 dd fb ff ff       	jmp    f0104b08 <syscall+0x56>
    struct Env *e = NULL;
f0104f2b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    if (envid2env(envid, &e, 1) < 0) {
f0104f32:	83 ec 04             	sub    $0x4,%esp
f0104f35:	6a 01                	push   $0x1
f0104f37:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104f3a:	50                   	push   %eax
f0104f3b:	ff 75 0c             	pushl  0xc(%ebp)
f0104f3e:	e8 b5 e2 ff ff       	call   f01031f8 <envid2env>
f0104f43:	83 c4 10             	add    $0x10,%esp
f0104f46:	85 c0                	test   %eax,%eax
f0104f48:	78 52                	js     f0104f9c <syscall+0x4ea>
    if (e == NULL) {
f0104f4a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104f4e:	74 56                	je     f0104fa6 <syscall+0x4f4>
    if (curenv->env_id != e->env_id &&
f0104f50:	e8 8d 14 00 00       	call   f01063e2 <cpunum>
f0104f55:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f58:	8b 90 28 00 33 f0    	mov    -0xfccffd8(%eax),%edx
f0104f5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f61:	8b 40 48             	mov    0x48(%eax),%eax
f0104f64:	39 42 48             	cmp    %eax,0x48(%edx)
f0104f67:	75 10                	jne    f0104f79 <syscall+0x4c7>
    e->env_pgfault_upcall = func;
f0104f69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f6c:	89 70 64             	mov    %esi,0x64(%eax)
    return 0;
f0104f6f:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f74:	e9 8f fb ff ff       	jmp    f0104b08 <syscall+0x56>
            curenv->env_id != e->env_parent_id) {
f0104f79:	e8 64 14 00 00       	call   f01063e2 <cpunum>
f0104f7e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f81:	8b 90 28 00 33 f0    	mov    -0xfccffd8(%eax),%edx
    if (curenv->env_id != e->env_id &&
f0104f87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f8a:	8b 40 4c             	mov    0x4c(%eax),%eax
f0104f8d:	39 42 48             	cmp    %eax,0x48(%edx)
f0104f90:	74 d7                	je     f0104f69 <syscall+0x4b7>
        return -E_BAD_ENV;
f0104f92:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
        return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
f0104f97:	e9 6c fb ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_BAD_ENV;
f0104f9c:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104fa1:	e9 62 fb ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_BAD_ENV;
f0104fa6:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104fab:	e9 58 fb ff ff       	jmp    f0104b08 <syscall+0x56>
    struct Env *dstenv = NULL;
f0104fb0:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
    envid2env(envid, &dstenv, 0);
f0104fb7:	83 ec 04             	sub    $0x4,%esp
f0104fba:	6a 00                	push   $0x0
f0104fbc:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104fbf:	50                   	push   %eax
f0104fc0:	ff 75 0c             	pushl  0xc(%ebp)
f0104fc3:	e8 30 e2 ff ff       	call   f01031f8 <envid2env>
    if (dstenv == NULL) {
f0104fc8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104fcb:	83 c4 10             	add    $0x10,%esp
f0104fce:	85 c0                	test   %eax,%eax
f0104fd0:	0f 84 b8 00 00 00    	je     f010508e <syscall+0x5dc>
    if (!dstenv->env_ipc_recving) {
f0104fd6:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104fda:	0f 84 b8 00 00 00    	je     f0105098 <syscall+0x5e6>
    pte_t *pte = NULL;
f0104fe0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    if (va < UTOP) {
f0104fe7:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104fee:	77 6c                	ja     f010505c <syscall+0x5aa>
        if (va & 0xfff) {
f0104ff0:	8b 55 14             	mov    0x14(%ebp),%edx
f0104ff3:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
        if (perm & perm_check) {
f0104ff9:	8b 45 18             	mov    0x18(%ebp),%eax
f0104ffc:	83 e0 f8             	and    $0xfffffff8,%eax
f0104fff:	09 c2                	or     %eax,%edx
f0105001:	0f 85 9b 00 00 00    	jne    f01050a2 <syscall+0x5f0>
        pp = page_lookup(curenv->env_pgdir, srcva, &pte);
f0105007:	e8 d6 13 00 00       	call   f01063e2 <cpunum>
f010500c:	83 ec 04             	sub    $0x4,%esp
f010500f:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105012:	52                   	push   %edx
f0105013:	ff 75 14             	pushl  0x14(%ebp)
f0105016:	6b c0 74             	imul   $0x74,%eax,%eax
f0105019:	8b 80 28 00 33 f0    	mov    -0xfccffd8(%eax),%eax
f010501f:	ff 70 60             	pushl  0x60(%eax)
f0105022:	e8 bc c1 ff ff       	call   f01011e3 <page_lookup>
        if (!(*pte & PTE_P)) {
f0105027:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010502a:	8b 12                	mov    (%edx),%edx
f010502c:	83 c4 10             	add    $0x10,%esp
f010502f:	f6 c2 01             	test   $0x1,%dl
f0105032:	74 78                	je     f01050ac <syscall+0x5fa>
        if (perm & PTE_W) {
f0105034:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0105038:	74 05                	je     f010503f <syscall+0x58d>
            if ((*pte & PTE_W) == 0) {
f010503a:	f6 c2 02             	test   $0x2,%dl
f010503d:	74 77                	je     f01050b6 <syscall+0x604>
    if (pp != NULL) {
f010503f:	85 c0                	test   %eax,%eax
f0105041:	74 19                	je     f010505c <syscall+0x5aa>
                    dstenv->env_ipc_dstva, perm) < 0) {
f0105043:	8b 55 e0             	mov    -0x20(%ebp),%edx
        if (page_insert(dstenv->env_pgdir, pp,
f0105046:	ff 75 18             	pushl  0x18(%ebp)
f0105049:	ff 72 6c             	pushl  0x6c(%edx)
f010504c:	50                   	push   %eax
f010504d:	ff 72 60             	pushl  0x60(%edx)
f0105050:	e8 77 c2 ff ff       	call   f01012cc <page_insert>
f0105055:	83 c4 10             	add    $0x10,%esp
f0105058:	85 c0                	test   %eax,%eax
f010505a:	78 64                	js     f01050c0 <syscall+0x60e>
    dstenv->env_ipc_value = value;
f010505c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010505f:	89 70 70             	mov    %esi,0x70(%eax)
    dstenv->env_ipc_from = curenv->env_id;
f0105062:	e8 7b 13 00 00       	call   f01063e2 <cpunum>
f0105067:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010506a:	6b c0 74             	imul   $0x74,%eax,%eax
f010506d:	8b 80 28 00 33 f0    	mov    -0xfccffd8(%eax),%eax
f0105073:	8b 40 48             	mov    0x48(%eax),%eax
f0105076:	89 42 74             	mov    %eax,0x74(%edx)
    dstenv->env_ipc_recving = false;
f0105079:	c6 42 68 00          	movb   $0x0,0x68(%edx)
    dstenv->env_status = ENV_RUNNABLE;
f010507d:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
    return 0;
f0105084:	b8 00 00 00 00       	mov    $0x0,%eax
f0105089:	e9 7a fa ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_BAD_ENV;
f010508e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0105093:	e9 70 fa ff ff       	jmp    f0104b08 <syscall+0x56>
        return -E_IPC_NOT_RECV;
f0105098:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
f010509d:	e9 66 fa ff ff       	jmp    f0104b08 <syscall+0x56>
            return -E_INVAL;
f01050a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01050a7:	e9 5c fa ff ff       	jmp    f0104b08 <syscall+0x56>
            return -E_INVAL;
f01050ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01050b1:	e9 52 fa ff ff       	jmp    f0104b08 <syscall+0x56>
                return -E_INVAL;
f01050b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01050bb:	e9 48 fa ff ff       	jmp    f0104b08 <syscall+0x56>
            return -E_NO_MEM;
f01050c0:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
        return sys_ipc_try_send((envid_t) a1, (uint32_t) a2,
f01050c5:	e9 3e fa ff ff       	jmp    f0104b08 <syscall+0x56>
    if (va < UTOP) {
f01050ca:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f01050d1:	77 52                	ja     f0105125 <syscall+0x673>
        if (va & 0xfff) {
f01050d3:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f01050da:	0f 85 a7 00 00 00    	jne    f0105187 <syscall+0x6d5>
        curenv->env_ipc_dstva = dstva;
f01050e0:	e8 fd 12 00 00       	call   f01063e2 <cpunum>
f01050e5:	6b c0 74             	imul   $0x74,%eax,%eax
f01050e8:	8b 80 28 00 33 f0    	mov    -0xfccffd8(%eax),%eax
f01050ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01050f1:	89 48 6c             	mov    %ecx,0x6c(%eax)
    curenv->env_ipc_recving = true;
f01050f4:	e8 e9 12 00 00       	call   f01063e2 <cpunum>
f01050f9:	6b c0 74             	imul   $0x74,%eax,%eax
f01050fc:	8b 80 28 00 33 f0    	mov    -0xfccffd8(%eax),%eax
f0105102:	c6 40 68 01          	movb   $0x1,0x68(%eax)
    curenv->env_status = ENV_NOT_RUNNABLE;
f0105106:	e8 d7 12 00 00       	call   f01063e2 <cpunum>
f010510b:	6b c0 74             	imul   $0x74,%eax,%eax
f010510e:	8b 80 28 00 33 f0    	mov    -0xfccffd8(%eax),%eax
f0105114:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	return 0;
f010511b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105120:	e9 e3 f9 ff ff       	jmp    f0104b08 <syscall+0x56>
        curenv->env_ipc_dstva = NULL;
f0105125:	e8 b8 12 00 00       	call   f01063e2 <cpunum>
f010512a:	6b c0 74             	imul   $0x74,%eax,%eax
f010512d:	8b 80 28 00 33 f0    	mov    -0xfccffd8(%eax),%eax
f0105133:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)
f010513a:	eb b8                	jmp    f01050f4 <syscall+0x642>
	if(x = envid2env(envid, &e, 1))
f010513c:	83 ec 04             	sub    $0x4,%esp
f010513f:	6a 01                	push   $0x1
f0105141:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105144:	50                   	push   %eax
f0105145:	ff 75 0c             	pushl  0xc(%ebp)
f0105148:	e8 ab e0 ff ff       	call   f01031f8 <envid2env>
f010514d:	83 c4 10             	add    $0x10,%esp
f0105150:	85 c0                	test   %eax,%eax
f0105152:	0f 85 b0 f9 ff ff    	jne    f0104b08 <syscall+0x56>
	tf->tf_eip |= 0x3;
f0105158:	83 4e 30 03          	orl    $0x3,0x30(%esi)
	tf->tf_eflags |= FL_IF;
f010515c:	81 4e 38 00 02 00 00 	orl    $0x200,0x38(%esi)
	e->env_tf = *tf;
f0105163:	b9 11 00 00 00       	mov    $0x11,%ecx
f0105168:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010516b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return (int32_t)sys_env_set_trapframe((envid_t) a1, (struct Trapframe *) a2);
f010516d:	e9 96 f9 ff ff       	jmp    f0104b08 <syscall+0x56>
	    panic("syscall %d not implemented", syscallno);
f0105172:	50                   	push   %eax
f0105173:	68 58 82 10 f0       	push   $0xf0108258
f0105178:	68 47 02 00 00       	push   $0x247
f010517d:	68 49 82 10 f0       	push   $0xf0108249
f0105182:	e8 b9 ae ff ff       	call   f0100040 <_panic>
            return -E_INVAL;
f0105187:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010518c:	e9 77 f9 ff ff       	jmp    f0104b08 <syscall+0x56>

f0105191 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0105191:	55                   	push   %ebp
f0105192:	89 e5                	mov    %esp,%ebp
f0105194:	57                   	push   %edi
f0105195:	56                   	push   %esi
f0105196:	53                   	push   %ebx
f0105197:	83 ec 14             	sub    $0x14,%esp
f010519a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010519d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01051a0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01051a3:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01051a6:	8b 1a                	mov    (%edx),%ebx
f01051a8:	8b 01                	mov    (%ecx),%eax
f01051aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01051ad:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01051b4:	eb 23                	jmp    f01051d9 <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01051b6:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f01051b9:	eb 1e                	jmp    f01051d9 <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01051bb:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01051be:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01051c1:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01051c5:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01051c8:	73 46                	jae    f0105210 <stab_binsearch+0x7f>
			*region_left = m;
f01051ca:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01051cd:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01051cf:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f01051d2:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f01051d9:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01051dc:	7f 5f                	jg     f010523d <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f01051de:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01051e1:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f01051e4:	89 d0                	mov    %edx,%eax
f01051e6:	c1 e8 1f             	shr    $0x1f,%eax
f01051e9:	01 d0                	add    %edx,%eax
f01051eb:	89 c7                	mov    %eax,%edi
f01051ed:	d1 ff                	sar    %edi
f01051ef:	83 e0 fe             	and    $0xfffffffe,%eax
f01051f2:	01 f8                	add    %edi,%eax
f01051f4:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01051f7:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f01051fb:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f01051fd:	39 c3                	cmp    %eax,%ebx
f01051ff:	7f b5                	jg     f01051b6 <stab_binsearch+0x25>
f0105201:	0f b6 0a             	movzbl (%edx),%ecx
f0105204:	83 ea 0c             	sub    $0xc,%edx
f0105207:	39 f1                	cmp    %esi,%ecx
f0105209:	74 b0                	je     f01051bb <stab_binsearch+0x2a>
			m--;
f010520b:	83 e8 01             	sub    $0x1,%eax
f010520e:	eb ed                	jmp    f01051fd <stab_binsearch+0x6c>
		} else if (stabs[m].n_value > addr) {
f0105210:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0105213:	76 14                	jbe    f0105229 <stab_binsearch+0x98>
			*region_right = m - 1;
f0105215:	83 e8 01             	sub    $0x1,%eax
f0105218:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010521b:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010521e:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0105220:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105227:	eb b0                	jmp    f01051d9 <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0105229:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010522c:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f010522e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0105232:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0105234:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010523b:	eb 9c                	jmp    f01051d9 <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f010523d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0105241:	75 15                	jne    f0105258 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0105243:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105246:	8b 00                	mov    (%eax),%eax
f0105248:	83 e8 01             	sub    $0x1,%eax
f010524b:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010524e:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0105250:	83 c4 14             	add    $0x14,%esp
f0105253:	5b                   	pop    %ebx
f0105254:	5e                   	pop    %esi
f0105255:	5f                   	pop    %edi
f0105256:	5d                   	pop    %ebp
f0105257:	c3                   	ret    
		for (l = *region_right;
f0105258:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010525b:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f010525d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105260:	8b 0f                	mov    (%edi),%ecx
f0105262:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105265:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0105268:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f010526c:	eb 03                	jmp    f0105271 <stab_binsearch+0xe0>
		     l--)
f010526e:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0105271:	39 c1                	cmp    %eax,%ecx
f0105273:	7d 0a                	jge    f010527f <stab_binsearch+0xee>
		     l > *region_left && stabs[l].n_type != type;
f0105275:	0f b6 1a             	movzbl (%edx),%ebx
f0105278:	83 ea 0c             	sub    $0xc,%edx
f010527b:	39 f3                	cmp    %esi,%ebx
f010527d:	75 ef                	jne    f010526e <stab_binsearch+0xdd>
		*region_left = l;
f010527f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105282:	89 07                	mov    %eax,(%edi)
}
f0105284:	eb ca                	jmp    f0105250 <stab_binsearch+0xbf>

f0105286 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0105286:	f3 0f 1e fb          	endbr32 
f010528a:	55                   	push   %ebp
f010528b:	89 e5                	mov    %esp,%ebp
f010528d:	57                   	push   %edi
f010528e:	56                   	push   %esi
f010528f:	53                   	push   %ebx
f0105290:	83 ec 4c             	sub    $0x4c,%esp
f0105293:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0105296:	c7 03 ac 82 10 f0    	movl   $0xf01082ac,(%ebx)
	info->eip_line = 0;
f010529c:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01052a3:	c7 43 08 ac 82 10 f0 	movl   $0xf01082ac,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01052aa:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01052b1:	8b 45 08             	mov    0x8(%ebp),%eax
f01052b4:	89 43 10             	mov    %eax,0x10(%ebx)
	info->eip_fn_narg = 0;
f01052b7:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01052be:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f01052c3:	0f 86 1b 01 00 00    	jbe    f01053e4 <debuginfo_eip+0x15e>
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01052c9:	c7 45 bc 83 90 11 f0 	movl   $0xf0119083,-0x44(%ebp)
		stabstr = __STABSTR_BEGIN__;
f01052d0:	c7 45 b4 05 58 11 f0 	movl   $0xf0115805,-0x4c(%ebp)
		stab_end = __STAB_END__;
f01052d7:	bf 04 58 11 f0       	mov    $0xf0115804,%edi
		stabs = __STAB_BEGIN__;
f01052dc:	c7 45 b8 50 88 10 f0 	movl   $0xf0108850,-0x48(%ebp)
            return -1;
        }
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01052e3:	8b 75 bc             	mov    -0x44(%ebp),%esi
f01052e6:	39 75 b4             	cmp    %esi,-0x4c(%ebp)
f01052e9:	0f 83 5d 02 00 00    	jae    f010554c <debuginfo_eip+0x2c6>
f01052ef:	80 7e ff 00          	cmpb   $0x0,-0x1(%esi)
f01052f3:	0f 85 5a 02 00 00    	jne    f0105553 <debuginfo_eip+0x2cd>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01052f9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0105300:	8b 75 b8             	mov    -0x48(%ebp),%esi
f0105303:	29 f7                	sub    %esi,%edi
f0105305:	c1 ff 02             	sar    $0x2,%edi
f0105308:	69 c7 ab aa aa aa    	imul   $0xaaaaaaab,%edi,%eax
f010530e:	83 e8 01             	sub    $0x1,%eax
f0105311:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105314:	83 ec 08             	sub    $0x8,%esp
f0105317:	ff 75 08             	pushl  0x8(%ebp)
f010531a:	6a 64                	push   $0x64
f010531c:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010531f:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105322:	89 f0                	mov    %esi,%eax
f0105324:	e8 68 fe ff ff       	call   f0105191 <stab_binsearch>
	if (lfile == 0)
f0105329:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010532c:	83 c4 10             	add    $0x10,%esp
f010532f:	85 c0                	test   %eax,%eax
f0105331:	0f 84 23 02 00 00    	je     f010555a <debuginfo_eip+0x2d4>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105337:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010533a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010533d:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105340:	83 ec 08             	sub    $0x8,%esp
f0105343:	ff 75 08             	pushl  0x8(%ebp)
f0105346:	6a 24                	push   $0x24
f0105348:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010534b:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010534e:	89 f0                	mov    %esi,%eax
f0105350:	e8 3c fe ff ff       	call   f0105191 <stab_binsearch>

	if (lfun <= rfun) {
f0105355:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105358:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010535b:	83 c4 10             	add    $0x10,%esp
f010535e:	39 d0                	cmp    %edx,%eax
f0105360:	0f 8f 2b 01 00 00    	jg     f0105491 <debuginfo_eip+0x20b>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105366:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0105369:	8d 3c 8e             	lea    (%esi,%ecx,4),%edi
f010536c:	8b 0f                	mov    (%edi),%ecx
f010536e:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0105371:	2b 75 b4             	sub    -0x4c(%ebp),%esi
f0105374:	39 f1                	cmp    %esi,%ecx
f0105376:	73 06                	jae    f010537e <debuginfo_eip+0xf8>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105378:	03 4d b4             	add    -0x4c(%ebp),%ecx
f010537b:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010537e:	8b 4f 08             	mov    0x8(%edi),%ecx
f0105381:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0105384:	29 4d 08             	sub    %ecx,0x8(%ebp)
		// Search within the function definition for the line number.
		lline = lfun;
f0105387:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f010538a:	89 55 d0             	mov    %edx,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010538d:	83 ec 08             	sub    $0x8,%esp
f0105390:	6a 3a                	push   $0x3a
f0105392:	ff 73 08             	pushl  0x8(%ebx)
f0105395:	e8 0a 0a 00 00       	call   f0105da4 <strfind>
f010539a:	2b 43 08             	sub    0x8(%ebx),%eax
f010539d:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01053a0:	83 c4 08             	add    $0x8,%esp
f01053a3:	ff 75 08             	pushl  0x8(%ebp)
f01053a6:	6a 44                	push   $0x44
f01053a8:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01053ab:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01053ae:	8b 75 b8             	mov    -0x48(%ebp),%esi
f01053b1:	89 f0                	mov    %esi,%eax
f01053b3:	e8 d9 fd ff ff       	call   f0105191 <stab_binsearch>

    if (lline <= rline) {
f01053b8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01053bb:	83 c4 10             	add    $0x10,%esp
f01053be:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f01053c1:	0f 8f 9a 01 00 00    	jg     f0105561 <debuginfo_eip+0x2db>
        info->eip_line = stabs[lline].n_desc;
f01053c7:	89 d0                	mov    %edx,%eax
f01053c9:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01053cc:	0f b7 4c 96 06       	movzwl 0x6(%esi,%edx,4),%ecx
f01053d1:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01053d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01053d7:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
f01053db:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f01053df:	e9 ce 00 00 00       	jmp    f01054b2 <debuginfo_eip+0x22c>
        if (user_mem_check(curenv, usd, sizeof(const struct UserStabData),
f01053e4:	e8 f9 0f 00 00       	call   f01063e2 <cpunum>
f01053e9:	6a 05                	push   $0x5
f01053eb:	6a 10                	push   $0x10
f01053ed:	68 00 00 20 00       	push   $0x200000
f01053f2:	6b c0 74             	imul   $0x74,%eax,%eax
f01053f5:	ff b0 28 00 33 f0    	pushl  -0xfccffd8(%eax)
f01053fb:	e8 71 dc ff ff       	call   f0103071 <user_mem_check>
f0105400:	83 c4 10             	add    $0x10,%esp
f0105403:	85 c0                	test   %eax,%eax
f0105405:	0f 88 33 01 00 00    	js     f010553e <debuginfo_eip+0x2b8>
		stabs = usd->stabs;
f010540b:	a1 00 00 20 00       	mov    0x200000,%eax
f0105410:	89 45 b8             	mov    %eax,-0x48(%ebp)
		stab_end = usd->stab_end;
f0105413:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f0105419:	8b 35 08 00 20 00    	mov    0x200008,%esi
f010541f:	89 75 b4             	mov    %esi,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f0105422:	8b 0d 0c 00 20 00    	mov    0x20000c,%ecx
f0105428:	89 4d bc             	mov    %ecx,-0x44(%ebp)
        size_t stabs_size = ((uintptr_t)stab_end) - ((uintptr_t) stabs);
f010542b:	89 fa                	mov    %edi,%edx
f010542d:	89 c6                	mov    %eax,%esi
f010542f:	29 c2                	sub    %eax,%edx
f0105431:	89 55 c4             	mov    %edx,-0x3c(%ebp)
        if (user_mem_check(curenv, stabs, stabs_size,
f0105434:	e8 a9 0f 00 00       	call   f01063e2 <cpunum>
f0105439:	6a 05                	push   $0x5
f010543b:	ff 75 c4             	pushl  -0x3c(%ebp)
f010543e:	56                   	push   %esi
f010543f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105442:	ff b0 28 00 33 f0    	pushl  -0xfccffd8(%eax)
f0105448:	e8 24 dc ff ff       	call   f0103071 <user_mem_check>
f010544d:	83 c4 10             	add    $0x10,%esp
f0105450:	85 c0                	test   %eax,%eax
f0105452:	0f 88 ed 00 00 00    	js     f0105545 <debuginfo_eip+0x2bf>
        size_t stabstr_size = ((uintptr_t)stabstr_end) - ((uintptr_t) stabstr);
f0105458:	8b 45 bc             	mov    -0x44(%ebp),%eax
f010545b:	8b 75 b4             	mov    -0x4c(%ebp),%esi
f010545e:	29 f0                	sub    %esi,%eax
f0105460:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        if (user_mem_check(curenv, stabstr, stabstr_size,
f0105463:	e8 7a 0f 00 00       	call   f01063e2 <cpunum>
f0105468:	6a 05                	push   $0x5
f010546a:	ff 75 c4             	pushl  -0x3c(%ebp)
f010546d:	56                   	push   %esi
f010546e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105471:	ff b0 28 00 33 f0    	pushl  -0xfccffd8(%eax)
f0105477:	e8 f5 db ff ff       	call   f0103071 <user_mem_check>
f010547c:	83 c4 10             	add    $0x10,%esp
f010547f:	85 c0                	test   %eax,%eax
f0105481:	0f 89 5c fe ff ff    	jns    f01052e3 <debuginfo_eip+0x5d>
            return -1;
f0105487:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f010548c:	e9 dc 00 00 00       	jmp    f010556d <debuginfo_eip+0x2e7>
		info->eip_fn_addr = addr;
f0105491:	8b 45 08             	mov    0x8(%ebp),%eax
f0105494:	89 43 10             	mov    %eax,0x10(%ebx)
		lline = lfile;
f0105497:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010549a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f010549d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01054a0:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01054a3:	e9 e5 fe ff ff       	jmp    f010538d <debuginfo_eip+0x107>
f01054a8:	83 e8 01             	sub    $0x1,%eax
f01054ab:	83 ea 0c             	sub    $0xc,%edx
	while (lline >= lfile
f01054ae:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f01054b2:	89 45 c0             	mov    %eax,-0x40(%ebp)
f01054b5:	39 c7                	cmp    %eax,%edi
f01054b7:	7f 45                	jg     f01054fe <debuginfo_eip+0x278>
	       && stabs[lline].n_type != N_SOL
f01054b9:	0f b6 0a             	movzbl (%edx),%ecx
f01054bc:	80 f9 84             	cmp    $0x84,%cl
f01054bf:	74 19                	je     f01054da <debuginfo_eip+0x254>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01054c1:	80 f9 64             	cmp    $0x64,%cl
f01054c4:	75 e2                	jne    f01054a8 <debuginfo_eip+0x222>
f01054c6:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f01054ca:	74 dc                	je     f01054a8 <debuginfo_eip+0x222>
f01054cc:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f01054d0:	74 11                	je     f01054e3 <debuginfo_eip+0x25d>
f01054d2:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01054d5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01054d8:	eb 09                	jmp    f01054e3 <debuginfo_eip+0x25d>
f01054da:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f01054de:	74 03                	je     f01054e3 <debuginfo_eip+0x25d>
f01054e0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01054e3:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01054e6:	8b 7d b8             	mov    -0x48(%ebp),%edi
f01054e9:	8b 14 87             	mov    (%edi,%eax,4),%edx
f01054ec:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01054ef:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f01054f2:	29 f8                	sub    %edi,%eax
f01054f4:	39 c2                	cmp    %eax,%edx
f01054f6:	73 06                	jae    f01054fe <debuginfo_eip+0x278>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01054f8:	89 f8                	mov    %edi,%eax
f01054fa:	01 d0                	add    %edx,%eax
f01054fc:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01054fe:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105501:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105504:	ba 00 00 00 00       	mov    $0x0,%edx
	if (lfun < rfun)
f0105509:	39 f0                	cmp    %esi,%eax
f010550b:	7d 60                	jge    f010556d <debuginfo_eip+0x2e7>
		for (lline = lfun + 1;
f010550d:	8d 50 01             	lea    0x1(%eax),%edx
f0105510:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105513:	89 d0                	mov    %edx,%eax
f0105515:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0105518:	8b 7d b8             	mov    -0x48(%ebp),%edi
f010551b:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f010551f:	eb 04                	jmp    f0105525 <debuginfo_eip+0x29f>
			info->eip_fn_narg++;
f0105521:	83 43 14 01          	addl   $0x1,0x14(%ebx)
		for (lline = lfun + 1;
f0105525:	39 c6                	cmp    %eax,%esi
f0105527:	7e 3f                	jle    f0105568 <debuginfo_eip+0x2e2>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105529:	0f b6 0a             	movzbl (%edx),%ecx
f010552c:	83 c0 01             	add    $0x1,%eax
f010552f:	83 c2 0c             	add    $0xc,%edx
f0105532:	80 f9 a0             	cmp    $0xa0,%cl
f0105535:	74 ea                	je     f0105521 <debuginfo_eip+0x29b>
	return 0;
f0105537:	ba 00 00 00 00       	mov    $0x0,%edx
f010553c:	eb 2f                	jmp    f010556d <debuginfo_eip+0x2e7>
            return -1;
f010553e:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0105543:	eb 28                	jmp    f010556d <debuginfo_eip+0x2e7>
            return -1;
f0105545:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f010554a:	eb 21                	jmp    f010556d <debuginfo_eip+0x2e7>
		return -1;
f010554c:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0105551:	eb 1a                	jmp    f010556d <debuginfo_eip+0x2e7>
f0105553:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0105558:	eb 13                	jmp    f010556d <debuginfo_eip+0x2e7>
		return -1;
f010555a:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f010555f:	eb 0c                	jmp    f010556d <debuginfo_eip+0x2e7>
        return -1;
f0105561:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0105566:	eb 05                	jmp    f010556d <debuginfo_eip+0x2e7>
	return 0;
f0105568:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010556d:	89 d0                	mov    %edx,%eax
f010556f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105572:	5b                   	pop    %ebx
f0105573:	5e                   	pop    %esi
f0105574:	5f                   	pop    %edi
f0105575:	5d                   	pop    %ebp
f0105576:	c3                   	ret    

f0105577 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105577:	55                   	push   %ebp
f0105578:	89 e5                	mov    %esp,%ebp
f010557a:	57                   	push   %edi
f010557b:	56                   	push   %esi
f010557c:	53                   	push   %ebx
f010557d:	83 ec 1c             	sub    $0x1c,%esp
f0105580:	89 c7                	mov    %eax,%edi
f0105582:	89 d6                	mov    %edx,%esi
f0105584:	8b 45 08             	mov    0x8(%ebp),%eax
f0105587:	8b 55 0c             	mov    0xc(%ebp),%edx
f010558a:	89 d1                	mov    %edx,%ecx
f010558c:	89 c2                	mov    %eax,%edx
f010558e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105591:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105594:	8b 45 10             	mov    0x10(%ebp),%eax
f0105597:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010559a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010559d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01055a4:	39 c2                	cmp    %eax,%edx
f01055a6:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f01055a9:	72 3e                	jb     f01055e9 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01055ab:	83 ec 0c             	sub    $0xc,%esp
f01055ae:	ff 75 18             	pushl  0x18(%ebp)
f01055b1:	83 eb 01             	sub    $0x1,%ebx
f01055b4:	53                   	push   %ebx
f01055b5:	50                   	push   %eax
f01055b6:	83 ec 08             	sub    $0x8,%esp
f01055b9:	ff 75 e4             	pushl  -0x1c(%ebp)
f01055bc:	ff 75 e0             	pushl  -0x20(%ebp)
f01055bf:	ff 75 dc             	pushl  -0x24(%ebp)
f01055c2:	ff 75 d8             	pushl  -0x28(%ebp)
f01055c5:	e8 36 12 00 00       	call   f0106800 <__udivdi3>
f01055ca:	83 c4 18             	add    $0x18,%esp
f01055cd:	52                   	push   %edx
f01055ce:	50                   	push   %eax
f01055cf:	89 f2                	mov    %esi,%edx
f01055d1:	89 f8                	mov    %edi,%eax
f01055d3:	e8 9f ff ff ff       	call   f0105577 <printnum>
f01055d8:	83 c4 20             	add    $0x20,%esp
f01055db:	eb 13                	jmp    f01055f0 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01055dd:	83 ec 08             	sub    $0x8,%esp
f01055e0:	56                   	push   %esi
f01055e1:	ff 75 18             	pushl  0x18(%ebp)
f01055e4:	ff d7                	call   *%edi
f01055e6:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f01055e9:	83 eb 01             	sub    $0x1,%ebx
f01055ec:	85 db                	test   %ebx,%ebx
f01055ee:	7f ed                	jg     f01055dd <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01055f0:	83 ec 08             	sub    $0x8,%esp
f01055f3:	56                   	push   %esi
f01055f4:	83 ec 04             	sub    $0x4,%esp
f01055f7:	ff 75 e4             	pushl  -0x1c(%ebp)
f01055fa:	ff 75 e0             	pushl  -0x20(%ebp)
f01055fd:	ff 75 dc             	pushl  -0x24(%ebp)
f0105600:	ff 75 d8             	pushl  -0x28(%ebp)
f0105603:	e8 08 13 00 00       	call   f0106910 <__umoddi3>
f0105608:	83 c4 14             	add    $0x14,%esp
f010560b:	0f be 80 b6 82 10 f0 	movsbl -0xfef7d4a(%eax),%eax
f0105612:	50                   	push   %eax
f0105613:	ff d7                	call   *%edi
}
f0105615:	83 c4 10             	add    $0x10,%esp
f0105618:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010561b:	5b                   	pop    %ebx
f010561c:	5e                   	pop    %esi
f010561d:	5f                   	pop    %edi
f010561e:	5d                   	pop    %ebp
f010561f:	c3                   	ret    

f0105620 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105620:	f3 0f 1e fb          	endbr32 
f0105624:	55                   	push   %ebp
f0105625:	89 e5                	mov    %esp,%ebp
f0105627:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010562a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010562e:	8b 10                	mov    (%eax),%edx
f0105630:	3b 50 04             	cmp    0x4(%eax),%edx
f0105633:	73 0a                	jae    f010563f <sprintputch+0x1f>
		*b->buf++ = ch;
f0105635:	8d 4a 01             	lea    0x1(%edx),%ecx
f0105638:	89 08                	mov    %ecx,(%eax)
f010563a:	8b 45 08             	mov    0x8(%ebp),%eax
f010563d:	88 02                	mov    %al,(%edx)
}
f010563f:	5d                   	pop    %ebp
f0105640:	c3                   	ret    

f0105641 <printfmt>:
{
f0105641:	f3 0f 1e fb          	endbr32 
f0105645:	55                   	push   %ebp
f0105646:	89 e5                	mov    %esp,%ebp
f0105648:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f010564b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010564e:	50                   	push   %eax
f010564f:	ff 75 10             	pushl  0x10(%ebp)
f0105652:	ff 75 0c             	pushl  0xc(%ebp)
f0105655:	ff 75 08             	pushl  0x8(%ebp)
f0105658:	e8 05 00 00 00       	call   f0105662 <vprintfmt>
}
f010565d:	83 c4 10             	add    $0x10,%esp
f0105660:	c9                   	leave  
f0105661:	c3                   	ret    

f0105662 <vprintfmt>:
{
f0105662:	f3 0f 1e fb          	endbr32 
f0105666:	55                   	push   %ebp
f0105667:	89 e5                	mov    %esp,%ebp
f0105669:	57                   	push   %edi
f010566a:	56                   	push   %esi
f010566b:	53                   	push   %ebx
f010566c:	83 ec 3c             	sub    $0x3c,%esp
f010566f:	8b 75 08             	mov    0x8(%ebp),%esi
f0105672:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105675:	8b 7d 10             	mov    0x10(%ebp),%edi
f0105678:	e9 4a 03 00 00       	jmp    f01059c7 <vprintfmt+0x365>
		padc = ' ';
f010567d:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
f0105681:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f0105688:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f010568f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0105696:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f010569b:	8d 47 01             	lea    0x1(%edi),%eax
f010569e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01056a1:	0f b6 17             	movzbl (%edi),%edx
f01056a4:	8d 42 dd             	lea    -0x23(%edx),%eax
f01056a7:	3c 55                	cmp    $0x55,%al
f01056a9:	0f 87 de 03 00 00    	ja     f0105a8d <vprintfmt+0x42b>
f01056af:	0f b6 c0             	movzbl %al,%eax
f01056b2:	3e ff 24 85 00 84 10 	notrack jmp *-0xfef7c00(,%eax,4)
f01056b9:	f0 
f01056ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f01056bd:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
f01056c1:	eb d8                	jmp    f010569b <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
f01056c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01056c6:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
f01056ca:	eb cf                	jmp    f010569b <vprintfmt+0x39>
f01056cc:	0f b6 d2             	movzbl %dl,%edx
f01056cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f01056d2:	b8 00 00 00 00       	mov    $0x0,%eax
f01056d7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f01056da:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01056dd:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f01056e1:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f01056e4:	8d 4a d0             	lea    -0x30(%edx),%ecx
f01056e7:	83 f9 09             	cmp    $0x9,%ecx
f01056ea:	77 55                	ja     f0105741 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
f01056ec:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f01056ef:	eb e9                	jmp    f01056da <vprintfmt+0x78>
			precision = va_arg(ap, int);
f01056f1:	8b 45 14             	mov    0x14(%ebp),%eax
f01056f4:	8b 00                	mov    (%eax),%eax
f01056f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01056f9:	8b 45 14             	mov    0x14(%ebp),%eax
f01056fc:	8d 40 04             	lea    0x4(%eax),%eax
f01056ff:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0105702:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0105705:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105709:	79 90                	jns    f010569b <vprintfmt+0x39>
				width = precision, precision = -1;
f010570b:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010570e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105711:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0105718:	eb 81                	jmp    f010569b <vprintfmt+0x39>
f010571a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010571d:	85 c0                	test   %eax,%eax
f010571f:	ba 00 00 00 00       	mov    $0x0,%edx
f0105724:	0f 49 d0             	cmovns %eax,%edx
f0105727:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010572a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f010572d:	e9 69 ff ff ff       	jmp    f010569b <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
f0105732:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0105735:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f010573c:	e9 5a ff ff ff       	jmp    f010569b <vprintfmt+0x39>
f0105741:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105744:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105747:	eb bc                	jmp    f0105705 <vprintfmt+0xa3>
			lflag++;
f0105749:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f010574c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f010574f:	e9 47 ff ff ff       	jmp    f010569b <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
f0105754:	8b 45 14             	mov    0x14(%ebp),%eax
f0105757:	8d 78 04             	lea    0x4(%eax),%edi
f010575a:	83 ec 08             	sub    $0x8,%esp
f010575d:	53                   	push   %ebx
f010575e:	ff 30                	pushl  (%eax)
f0105760:	ff d6                	call   *%esi
			break;
f0105762:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0105765:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0105768:	e9 57 02 00 00       	jmp    f01059c4 <vprintfmt+0x362>
			err = va_arg(ap, int);
f010576d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105770:	8d 78 04             	lea    0x4(%eax),%edi
f0105773:	8b 00                	mov    (%eax),%eax
f0105775:	99                   	cltd   
f0105776:	31 d0                	xor    %edx,%eax
f0105778:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010577a:	83 f8 0f             	cmp    $0xf,%eax
f010577d:	7f 23                	jg     f01057a2 <vprintfmt+0x140>
f010577f:	8b 14 85 60 85 10 f0 	mov    -0xfef7aa0(,%eax,4),%edx
f0105786:	85 d2                	test   %edx,%edx
f0105788:	74 18                	je     f01057a2 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
f010578a:	52                   	push   %edx
f010578b:	68 8b 79 10 f0       	push   $0xf010798b
f0105790:	53                   	push   %ebx
f0105791:	56                   	push   %esi
f0105792:	e8 aa fe ff ff       	call   f0105641 <printfmt>
f0105797:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010579a:	89 7d 14             	mov    %edi,0x14(%ebp)
f010579d:	e9 22 02 00 00       	jmp    f01059c4 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
f01057a2:	50                   	push   %eax
f01057a3:	68 ce 82 10 f0       	push   $0xf01082ce
f01057a8:	53                   	push   %ebx
f01057a9:	56                   	push   %esi
f01057aa:	e8 92 fe ff ff       	call   f0105641 <printfmt>
f01057af:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01057b2:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f01057b5:	e9 0a 02 00 00       	jmp    f01059c4 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
f01057ba:	8b 45 14             	mov    0x14(%ebp),%eax
f01057bd:	83 c0 04             	add    $0x4,%eax
f01057c0:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01057c3:	8b 45 14             	mov    0x14(%ebp),%eax
f01057c6:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f01057c8:	85 d2                	test   %edx,%edx
f01057ca:	b8 c7 82 10 f0       	mov    $0xf01082c7,%eax
f01057cf:	0f 45 c2             	cmovne %edx,%eax
f01057d2:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
f01057d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01057d9:	7e 06                	jle    f01057e1 <vprintfmt+0x17f>
f01057db:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
f01057df:	75 0d                	jne    f01057ee <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
f01057e1:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01057e4:	89 c7                	mov    %eax,%edi
f01057e6:	03 45 e0             	add    -0x20(%ebp),%eax
f01057e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01057ec:	eb 55                	jmp    f0105843 <vprintfmt+0x1e1>
f01057ee:	83 ec 08             	sub    $0x8,%esp
f01057f1:	ff 75 d8             	pushl  -0x28(%ebp)
f01057f4:	ff 75 cc             	pushl  -0x34(%ebp)
f01057f7:	e8 37 04 00 00       	call   f0105c33 <strnlen>
f01057fc:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01057ff:	29 c2                	sub    %eax,%edx
f0105801:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0105804:	83 c4 10             	add    $0x10,%esp
f0105807:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
f0105809:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f010580d:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0105810:	85 ff                	test   %edi,%edi
f0105812:	7e 11                	jle    f0105825 <vprintfmt+0x1c3>
					putch(padc, putdat);
f0105814:	83 ec 08             	sub    $0x8,%esp
f0105817:	53                   	push   %ebx
f0105818:	ff 75 e0             	pushl  -0x20(%ebp)
f010581b:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f010581d:	83 ef 01             	sub    $0x1,%edi
f0105820:	83 c4 10             	add    $0x10,%esp
f0105823:	eb eb                	jmp    f0105810 <vprintfmt+0x1ae>
f0105825:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0105828:	85 d2                	test   %edx,%edx
f010582a:	b8 00 00 00 00       	mov    $0x0,%eax
f010582f:	0f 49 c2             	cmovns %edx,%eax
f0105832:	29 c2                	sub    %eax,%edx
f0105834:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0105837:	eb a8                	jmp    f01057e1 <vprintfmt+0x17f>
					putch(ch, putdat);
f0105839:	83 ec 08             	sub    $0x8,%esp
f010583c:	53                   	push   %ebx
f010583d:	52                   	push   %edx
f010583e:	ff d6                	call   *%esi
f0105840:	83 c4 10             	add    $0x10,%esp
f0105843:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105846:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105848:	83 c7 01             	add    $0x1,%edi
f010584b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010584f:	0f be d0             	movsbl %al,%edx
f0105852:	85 d2                	test   %edx,%edx
f0105854:	74 4b                	je     f01058a1 <vprintfmt+0x23f>
f0105856:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010585a:	78 06                	js     f0105862 <vprintfmt+0x200>
f010585c:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0105860:	78 1e                	js     f0105880 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
f0105862:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0105866:	74 d1                	je     f0105839 <vprintfmt+0x1d7>
f0105868:	0f be c0             	movsbl %al,%eax
f010586b:	83 e8 20             	sub    $0x20,%eax
f010586e:	83 f8 5e             	cmp    $0x5e,%eax
f0105871:	76 c6                	jbe    f0105839 <vprintfmt+0x1d7>
					putch('?', putdat);
f0105873:	83 ec 08             	sub    $0x8,%esp
f0105876:	53                   	push   %ebx
f0105877:	6a 3f                	push   $0x3f
f0105879:	ff d6                	call   *%esi
f010587b:	83 c4 10             	add    $0x10,%esp
f010587e:	eb c3                	jmp    f0105843 <vprintfmt+0x1e1>
f0105880:	89 cf                	mov    %ecx,%edi
f0105882:	eb 0e                	jmp    f0105892 <vprintfmt+0x230>
				putch(' ', putdat);
f0105884:	83 ec 08             	sub    $0x8,%esp
f0105887:	53                   	push   %ebx
f0105888:	6a 20                	push   $0x20
f010588a:	ff d6                	call   *%esi
			for (; width > 0; width--)
f010588c:	83 ef 01             	sub    $0x1,%edi
f010588f:	83 c4 10             	add    $0x10,%esp
f0105892:	85 ff                	test   %edi,%edi
f0105894:	7f ee                	jg     f0105884 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
f0105896:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0105899:	89 45 14             	mov    %eax,0x14(%ebp)
f010589c:	e9 23 01 00 00       	jmp    f01059c4 <vprintfmt+0x362>
f01058a1:	89 cf                	mov    %ecx,%edi
f01058a3:	eb ed                	jmp    f0105892 <vprintfmt+0x230>
	if (lflag >= 2)
f01058a5:	83 f9 01             	cmp    $0x1,%ecx
f01058a8:	7f 1b                	jg     f01058c5 <vprintfmt+0x263>
	else if (lflag)
f01058aa:	85 c9                	test   %ecx,%ecx
f01058ac:	74 63                	je     f0105911 <vprintfmt+0x2af>
		return va_arg(*ap, long);
f01058ae:	8b 45 14             	mov    0x14(%ebp),%eax
f01058b1:	8b 00                	mov    (%eax),%eax
f01058b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01058b6:	99                   	cltd   
f01058b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01058ba:	8b 45 14             	mov    0x14(%ebp),%eax
f01058bd:	8d 40 04             	lea    0x4(%eax),%eax
f01058c0:	89 45 14             	mov    %eax,0x14(%ebp)
f01058c3:	eb 17                	jmp    f01058dc <vprintfmt+0x27a>
		return va_arg(*ap, long long);
f01058c5:	8b 45 14             	mov    0x14(%ebp),%eax
f01058c8:	8b 50 04             	mov    0x4(%eax),%edx
f01058cb:	8b 00                	mov    (%eax),%eax
f01058cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01058d0:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01058d3:	8b 45 14             	mov    0x14(%ebp),%eax
f01058d6:	8d 40 08             	lea    0x8(%eax),%eax
f01058d9:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f01058dc:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01058df:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f01058e2:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f01058e7:	85 c9                	test   %ecx,%ecx
f01058e9:	0f 89 bb 00 00 00    	jns    f01059aa <vprintfmt+0x348>
				putch('-', putdat);
f01058ef:	83 ec 08             	sub    $0x8,%esp
f01058f2:	53                   	push   %ebx
f01058f3:	6a 2d                	push   $0x2d
f01058f5:	ff d6                	call   *%esi
				num = -(long long) num;
f01058f7:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01058fa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01058fd:	f7 da                	neg    %edx
f01058ff:	83 d1 00             	adc    $0x0,%ecx
f0105902:	f7 d9                	neg    %ecx
f0105904:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0105907:	b8 0a 00 00 00       	mov    $0xa,%eax
f010590c:	e9 99 00 00 00       	jmp    f01059aa <vprintfmt+0x348>
		return va_arg(*ap, int);
f0105911:	8b 45 14             	mov    0x14(%ebp),%eax
f0105914:	8b 00                	mov    (%eax),%eax
f0105916:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105919:	99                   	cltd   
f010591a:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010591d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105920:	8d 40 04             	lea    0x4(%eax),%eax
f0105923:	89 45 14             	mov    %eax,0x14(%ebp)
f0105926:	eb b4                	jmp    f01058dc <vprintfmt+0x27a>
	if (lflag >= 2)
f0105928:	83 f9 01             	cmp    $0x1,%ecx
f010592b:	7f 1b                	jg     f0105948 <vprintfmt+0x2e6>
	else if (lflag)
f010592d:	85 c9                	test   %ecx,%ecx
f010592f:	74 2c                	je     f010595d <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
f0105931:	8b 45 14             	mov    0x14(%ebp),%eax
f0105934:	8b 10                	mov    (%eax),%edx
f0105936:	b9 00 00 00 00       	mov    $0x0,%ecx
f010593b:	8d 40 04             	lea    0x4(%eax),%eax
f010593e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105941:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
f0105946:	eb 62                	jmp    f01059aa <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
f0105948:	8b 45 14             	mov    0x14(%ebp),%eax
f010594b:	8b 10                	mov    (%eax),%edx
f010594d:	8b 48 04             	mov    0x4(%eax),%ecx
f0105950:	8d 40 08             	lea    0x8(%eax),%eax
f0105953:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105956:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
f010595b:	eb 4d                	jmp    f01059aa <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
f010595d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105960:	8b 10                	mov    (%eax),%edx
f0105962:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105967:	8d 40 04             	lea    0x4(%eax),%eax
f010596a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010596d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
f0105972:	eb 36                	jmp    f01059aa <vprintfmt+0x348>
	if (lflag >= 2)
f0105974:	83 f9 01             	cmp    $0x1,%ecx
f0105977:	7f 17                	jg     f0105990 <vprintfmt+0x32e>
	else if (lflag)
f0105979:	85 c9                	test   %ecx,%ecx
f010597b:	74 6e                	je     f01059eb <vprintfmt+0x389>
		return va_arg(*ap, long);
f010597d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105980:	8b 10                	mov    (%eax),%edx
f0105982:	89 d0                	mov    %edx,%eax
f0105984:	99                   	cltd   
f0105985:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0105988:	8d 49 04             	lea    0x4(%ecx),%ecx
f010598b:	89 4d 14             	mov    %ecx,0x14(%ebp)
f010598e:	eb 11                	jmp    f01059a1 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
f0105990:	8b 45 14             	mov    0x14(%ebp),%eax
f0105993:	8b 50 04             	mov    0x4(%eax),%edx
f0105996:	8b 00                	mov    (%eax),%eax
f0105998:	8b 4d 14             	mov    0x14(%ebp),%ecx
f010599b:	8d 49 08             	lea    0x8(%ecx),%ecx
f010599e:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
f01059a1:	89 d1                	mov    %edx,%ecx
f01059a3:	89 c2                	mov    %eax,%edx
            base = 8;
f01059a5:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
f01059aa:	83 ec 0c             	sub    $0xc,%esp
f01059ad:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
f01059b1:	57                   	push   %edi
f01059b2:	ff 75 e0             	pushl  -0x20(%ebp)
f01059b5:	50                   	push   %eax
f01059b6:	51                   	push   %ecx
f01059b7:	52                   	push   %edx
f01059b8:	89 da                	mov    %ebx,%edx
f01059ba:	89 f0                	mov    %esi,%eax
f01059bc:	e8 b6 fb ff ff       	call   f0105577 <printnum>
			break;
f01059c1:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f01059c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01059c7:	83 c7 01             	add    $0x1,%edi
f01059ca:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01059ce:	83 f8 25             	cmp    $0x25,%eax
f01059d1:	0f 84 a6 fc ff ff    	je     f010567d <vprintfmt+0x1b>
			if (ch == '\0')
f01059d7:	85 c0                	test   %eax,%eax
f01059d9:	0f 84 ce 00 00 00    	je     f0105aad <vprintfmt+0x44b>
			putch(ch, putdat);
f01059df:	83 ec 08             	sub    $0x8,%esp
f01059e2:	53                   	push   %ebx
f01059e3:	50                   	push   %eax
f01059e4:	ff d6                	call   *%esi
f01059e6:	83 c4 10             	add    $0x10,%esp
f01059e9:	eb dc                	jmp    f01059c7 <vprintfmt+0x365>
		return va_arg(*ap, int);
f01059eb:	8b 45 14             	mov    0x14(%ebp),%eax
f01059ee:	8b 10                	mov    (%eax),%edx
f01059f0:	89 d0                	mov    %edx,%eax
f01059f2:	99                   	cltd   
f01059f3:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01059f6:	8d 49 04             	lea    0x4(%ecx),%ecx
f01059f9:	89 4d 14             	mov    %ecx,0x14(%ebp)
f01059fc:	eb a3                	jmp    f01059a1 <vprintfmt+0x33f>
			putch('0', putdat);
f01059fe:	83 ec 08             	sub    $0x8,%esp
f0105a01:	53                   	push   %ebx
f0105a02:	6a 30                	push   $0x30
f0105a04:	ff d6                	call   *%esi
			putch('x', putdat);
f0105a06:	83 c4 08             	add    $0x8,%esp
f0105a09:	53                   	push   %ebx
f0105a0a:	6a 78                	push   $0x78
f0105a0c:	ff d6                	call   *%esi
			num = (unsigned long long)
f0105a0e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a11:	8b 10                	mov    (%eax),%edx
f0105a13:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0105a18:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0105a1b:	8d 40 04             	lea    0x4(%eax),%eax
f0105a1e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105a21:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0105a26:	eb 82                	jmp    f01059aa <vprintfmt+0x348>
	if (lflag >= 2)
f0105a28:	83 f9 01             	cmp    $0x1,%ecx
f0105a2b:	7f 1e                	jg     f0105a4b <vprintfmt+0x3e9>
	else if (lflag)
f0105a2d:	85 c9                	test   %ecx,%ecx
f0105a2f:	74 32                	je     f0105a63 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
f0105a31:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a34:	8b 10                	mov    (%eax),%edx
f0105a36:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105a3b:	8d 40 04             	lea    0x4(%eax),%eax
f0105a3e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105a41:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
f0105a46:	e9 5f ff ff ff       	jmp    f01059aa <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
f0105a4b:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a4e:	8b 10                	mov    (%eax),%edx
f0105a50:	8b 48 04             	mov    0x4(%eax),%ecx
f0105a53:	8d 40 08             	lea    0x8(%eax),%eax
f0105a56:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105a59:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
f0105a5e:	e9 47 ff ff ff       	jmp    f01059aa <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
f0105a63:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a66:	8b 10                	mov    (%eax),%edx
f0105a68:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105a6d:	8d 40 04             	lea    0x4(%eax),%eax
f0105a70:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105a73:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
f0105a78:	e9 2d ff ff ff       	jmp    f01059aa <vprintfmt+0x348>
			putch(ch, putdat);
f0105a7d:	83 ec 08             	sub    $0x8,%esp
f0105a80:	53                   	push   %ebx
f0105a81:	6a 25                	push   $0x25
f0105a83:	ff d6                	call   *%esi
			break;
f0105a85:	83 c4 10             	add    $0x10,%esp
f0105a88:	e9 37 ff ff ff       	jmp    f01059c4 <vprintfmt+0x362>
			putch('%', putdat);
f0105a8d:	83 ec 08             	sub    $0x8,%esp
f0105a90:	53                   	push   %ebx
f0105a91:	6a 25                	push   $0x25
f0105a93:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105a95:	83 c4 10             	add    $0x10,%esp
f0105a98:	89 f8                	mov    %edi,%eax
f0105a9a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0105a9e:	74 05                	je     f0105aa5 <vprintfmt+0x443>
f0105aa0:	83 e8 01             	sub    $0x1,%eax
f0105aa3:	eb f5                	jmp    f0105a9a <vprintfmt+0x438>
f0105aa5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105aa8:	e9 17 ff ff ff       	jmp    f01059c4 <vprintfmt+0x362>
}
f0105aad:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105ab0:	5b                   	pop    %ebx
f0105ab1:	5e                   	pop    %esi
f0105ab2:	5f                   	pop    %edi
f0105ab3:	5d                   	pop    %ebp
f0105ab4:	c3                   	ret    

f0105ab5 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105ab5:	f3 0f 1e fb          	endbr32 
f0105ab9:	55                   	push   %ebp
f0105aba:	89 e5                	mov    %esp,%ebp
f0105abc:	83 ec 18             	sub    $0x18,%esp
f0105abf:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ac2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105ac5:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105ac8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105acc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105acf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105ad6:	85 c0                	test   %eax,%eax
f0105ad8:	74 26                	je     f0105b00 <vsnprintf+0x4b>
f0105ada:	85 d2                	test   %edx,%edx
f0105adc:	7e 22                	jle    f0105b00 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105ade:	ff 75 14             	pushl  0x14(%ebp)
f0105ae1:	ff 75 10             	pushl  0x10(%ebp)
f0105ae4:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105ae7:	50                   	push   %eax
f0105ae8:	68 20 56 10 f0       	push   $0xf0105620
f0105aed:	e8 70 fb ff ff       	call   f0105662 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105af2:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105af5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105afb:	83 c4 10             	add    $0x10,%esp
}
f0105afe:	c9                   	leave  
f0105aff:	c3                   	ret    
		return -E_INVAL;
f0105b00:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105b05:	eb f7                	jmp    f0105afe <vsnprintf+0x49>

f0105b07 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105b07:	f3 0f 1e fb          	endbr32 
f0105b0b:	55                   	push   %ebp
f0105b0c:	89 e5                	mov    %esp,%ebp
f0105b0e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105b11:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105b14:	50                   	push   %eax
f0105b15:	ff 75 10             	pushl  0x10(%ebp)
f0105b18:	ff 75 0c             	pushl  0xc(%ebp)
f0105b1b:	ff 75 08             	pushl  0x8(%ebp)
f0105b1e:	e8 92 ff ff ff       	call   f0105ab5 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105b23:	c9                   	leave  
f0105b24:	c3                   	ret    

f0105b25 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105b25:	f3 0f 1e fb          	endbr32 
f0105b29:	55                   	push   %ebp
f0105b2a:	89 e5                	mov    %esp,%ebp
f0105b2c:	57                   	push   %edi
f0105b2d:	56                   	push   %esi
f0105b2e:	53                   	push   %ebx
f0105b2f:	83 ec 0c             	sub    $0xc,%esp
f0105b32:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105b35:	85 c0                	test   %eax,%eax
f0105b37:	74 11                	je     f0105b4a <readline+0x25>
		cprintf("%s", prompt);
f0105b39:	83 ec 08             	sub    $0x8,%esp
f0105b3c:	50                   	push   %eax
f0105b3d:	68 8b 79 10 f0       	push   $0xf010798b
f0105b42:	e8 f7 df ff ff       	call   f0103b3e <cprintf>
f0105b47:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105b4a:	83 ec 0c             	sub    $0xc,%esp
f0105b4d:	6a 00                	push   $0x0
f0105b4f:	e8 7e ac ff ff       	call   f01007d2 <iscons>
f0105b54:	89 c7                	mov    %eax,%edi
f0105b56:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0105b59:	be 00 00 00 00       	mov    $0x0,%esi
f0105b5e:	eb 57                	jmp    f0105bb7 <readline+0x92>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f0105b60:	b8 00 00 00 00       	mov    $0x0,%eax
			if (c != -E_EOF)
f0105b65:	83 fb f8             	cmp    $0xfffffff8,%ebx
f0105b68:	75 08                	jne    f0105b72 <readline+0x4d>
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0105b6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105b6d:	5b                   	pop    %ebx
f0105b6e:	5e                   	pop    %esi
f0105b6f:	5f                   	pop    %edi
f0105b70:	5d                   	pop    %ebp
f0105b71:	c3                   	ret    
				cprintf("read error: %e\n", c);
f0105b72:	83 ec 08             	sub    $0x8,%esp
f0105b75:	53                   	push   %ebx
f0105b76:	68 bf 85 10 f0       	push   $0xf01085bf
f0105b7b:	e8 be df ff ff       	call   f0103b3e <cprintf>
f0105b80:	83 c4 10             	add    $0x10,%esp
			return NULL;
f0105b83:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b88:	eb e0                	jmp    f0105b6a <readline+0x45>
			if (echoing)
f0105b8a:	85 ff                	test   %edi,%edi
f0105b8c:	75 05                	jne    f0105b93 <readline+0x6e>
			i--;
f0105b8e:	83 ee 01             	sub    $0x1,%esi
f0105b91:	eb 24                	jmp    f0105bb7 <readline+0x92>
				cputchar('\b');
f0105b93:	83 ec 0c             	sub    $0xc,%esp
f0105b96:	6a 08                	push   $0x8
f0105b98:	e8 0c ac ff ff       	call   f01007a9 <cputchar>
f0105b9d:	83 c4 10             	add    $0x10,%esp
f0105ba0:	eb ec                	jmp    f0105b8e <readline+0x69>
				cputchar(c);
f0105ba2:	83 ec 0c             	sub    $0xc,%esp
f0105ba5:	53                   	push   %ebx
f0105ba6:	e8 fe ab ff ff       	call   f01007a9 <cputchar>
f0105bab:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105bae:	88 9e 80 fa 32 f0    	mov    %bl,-0xfcd0580(%esi)
f0105bb4:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f0105bb7:	e8 01 ac ff ff       	call   f01007bd <getchar>
f0105bbc:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105bbe:	85 c0                	test   %eax,%eax
f0105bc0:	78 9e                	js     f0105b60 <readline+0x3b>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105bc2:	83 f8 08             	cmp    $0x8,%eax
f0105bc5:	0f 94 c2             	sete   %dl
f0105bc8:	83 f8 7f             	cmp    $0x7f,%eax
f0105bcb:	0f 94 c0             	sete   %al
f0105bce:	08 c2                	or     %al,%dl
f0105bd0:	74 04                	je     f0105bd6 <readline+0xb1>
f0105bd2:	85 f6                	test   %esi,%esi
f0105bd4:	7f b4                	jg     f0105b8a <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105bd6:	83 fb 1f             	cmp    $0x1f,%ebx
f0105bd9:	7e 0e                	jle    f0105be9 <readline+0xc4>
f0105bdb:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105be1:	7f 06                	jg     f0105be9 <readline+0xc4>
			if (echoing)
f0105be3:	85 ff                	test   %edi,%edi
f0105be5:	74 c7                	je     f0105bae <readline+0x89>
f0105be7:	eb b9                	jmp    f0105ba2 <readline+0x7d>
		} else if (c == '\n' || c == '\r') {
f0105be9:	83 fb 0a             	cmp    $0xa,%ebx
f0105bec:	74 05                	je     f0105bf3 <readline+0xce>
f0105bee:	83 fb 0d             	cmp    $0xd,%ebx
f0105bf1:	75 c4                	jne    f0105bb7 <readline+0x92>
			if (echoing)
f0105bf3:	85 ff                	test   %edi,%edi
f0105bf5:	75 11                	jne    f0105c08 <readline+0xe3>
			buf[i] = 0;
f0105bf7:	c6 86 80 fa 32 f0 00 	movb   $0x0,-0xfcd0580(%esi)
			return buf;
f0105bfe:	b8 80 fa 32 f0       	mov    $0xf032fa80,%eax
f0105c03:	e9 62 ff ff ff       	jmp    f0105b6a <readline+0x45>
				cputchar('\n');
f0105c08:	83 ec 0c             	sub    $0xc,%esp
f0105c0b:	6a 0a                	push   $0xa
f0105c0d:	e8 97 ab ff ff       	call   f01007a9 <cputchar>
f0105c12:	83 c4 10             	add    $0x10,%esp
f0105c15:	eb e0                	jmp    f0105bf7 <readline+0xd2>

f0105c17 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105c17:	f3 0f 1e fb          	endbr32 
f0105c1b:	55                   	push   %ebp
f0105c1c:	89 e5                	mov    %esp,%ebp
f0105c1e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105c21:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c26:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105c2a:	74 05                	je     f0105c31 <strlen+0x1a>
		n++;
f0105c2c:	83 c0 01             	add    $0x1,%eax
f0105c2f:	eb f5                	jmp    f0105c26 <strlen+0xf>
	return n;
}
f0105c31:	5d                   	pop    %ebp
f0105c32:	c3                   	ret    

f0105c33 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105c33:	f3 0f 1e fb          	endbr32 
f0105c37:	55                   	push   %ebp
f0105c38:	89 e5                	mov    %esp,%ebp
f0105c3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105c3d:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105c40:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c45:	39 d0                	cmp    %edx,%eax
f0105c47:	74 0d                	je     f0105c56 <strnlen+0x23>
f0105c49:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0105c4d:	74 05                	je     f0105c54 <strnlen+0x21>
		n++;
f0105c4f:	83 c0 01             	add    $0x1,%eax
f0105c52:	eb f1                	jmp    f0105c45 <strnlen+0x12>
f0105c54:	89 c2                	mov    %eax,%edx
	return n;
}
f0105c56:	89 d0                	mov    %edx,%eax
f0105c58:	5d                   	pop    %ebp
f0105c59:	c3                   	ret    

f0105c5a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105c5a:	f3 0f 1e fb          	endbr32 
f0105c5e:	55                   	push   %ebp
f0105c5f:	89 e5                	mov    %esp,%ebp
f0105c61:	53                   	push   %ebx
f0105c62:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105c65:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105c68:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c6d:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f0105c71:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f0105c74:	83 c0 01             	add    $0x1,%eax
f0105c77:	84 d2                	test   %dl,%dl
f0105c79:	75 f2                	jne    f0105c6d <strcpy+0x13>
		/* do nothing */;
	return ret;
}
f0105c7b:	89 c8                	mov    %ecx,%eax
f0105c7d:	5b                   	pop    %ebx
f0105c7e:	5d                   	pop    %ebp
f0105c7f:	c3                   	ret    

f0105c80 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105c80:	f3 0f 1e fb          	endbr32 
f0105c84:	55                   	push   %ebp
f0105c85:	89 e5                	mov    %esp,%ebp
f0105c87:	53                   	push   %ebx
f0105c88:	83 ec 10             	sub    $0x10,%esp
f0105c8b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105c8e:	53                   	push   %ebx
f0105c8f:	e8 83 ff ff ff       	call   f0105c17 <strlen>
f0105c94:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0105c97:	ff 75 0c             	pushl  0xc(%ebp)
f0105c9a:	01 d8                	add    %ebx,%eax
f0105c9c:	50                   	push   %eax
f0105c9d:	e8 b8 ff ff ff       	call   f0105c5a <strcpy>
	return dst;
}
f0105ca2:	89 d8                	mov    %ebx,%eax
f0105ca4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105ca7:	c9                   	leave  
f0105ca8:	c3                   	ret    

f0105ca9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105ca9:	f3 0f 1e fb          	endbr32 
f0105cad:	55                   	push   %ebp
f0105cae:	89 e5                	mov    %esp,%ebp
f0105cb0:	56                   	push   %esi
f0105cb1:	53                   	push   %ebx
f0105cb2:	8b 75 08             	mov    0x8(%ebp),%esi
f0105cb5:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105cb8:	89 f3                	mov    %esi,%ebx
f0105cba:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105cbd:	89 f0                	mov    %esi,%eax
f0105cbf:	39 d8                	cmp    %ebx,%eax
f0105cc1:	74 11                	je     f0105cd4 <strncpy+0x2b>
		*dst++ = *src;
f0105cc3:	83 c0 01             	add    $0x1,%eax
f0105cc6:	0f b6 0a             	movzbl (%edx),%ecx
f0105cc9:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105ccc:	80 f9 01             	cmp    $0x1,%cl
f0105ccf:	83 da ff             	sbb    $0xffffffff,%edx
f0105cd2:	eb eb                	jmp    f0105cbf <strncpy+0x16>
	}
	return ret;
}
f0105cd4:	89 f0                	mov    %esi,%eax
f0105cd6:	5b                   	pop    %ebx
f0105cd7:	5e                   	pop    %esi
f0105cd8:	5d                   	pop    %ebp
f0105cd9:	c3                   	ret    

f0105cda <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105cda:	f3 0f 1e fb          	endbr32 
f0105cde:	55                   	push   %ebp
f0105cdf:	89 e5                	mov    %esp,%ebp
f0105ce1:	56                   	push   %esi
f0105ce2:	53                   	push   %ebx
f0105ce3:	8b 75 08             	mov    0x8(%ebp),%esi
f0105ce6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105ce9:	8b 55 10             	mov    0x10(%ebp),%edx
f0105cec:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105cee:	85 d2                	test   %edx,%edx
f0105cf0:	74 21                	je     f0105d13 <strlcpy+0x39>
f0105cf2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105cf6:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f0105cf8:	39 c2                	cmp    %eax,%edx
f0105cfa:	74 14                	je     f0105d10 <strlcpy+0x36>
f0105cfc:	0f b6 19             	movzbl (%ecx),%ebx
f0105cff:	84 db                	test   %bl,%bl
f0105d01:	74 0b                	je     f0105d0e <strlcpy+0x34>
			*dst++ = *src++;
f0105d03:	83 c1 01             	add    $0x1,%ecx
f0105d06:	83 c2 01             	add    $0x1,%edx
f0105d09:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105d0c:	eb ea                	jmp    f0105cf8 <strlcpy+0x1e>
f0105d0e:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0105d10:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105d13:	29 f0                	sub    %esi,%eax
}
f0105d15:	5b                   	pop    %ebx
f0105d16:	5e                   	pop    %esi
f0105d17:	5d                   	pop    %ebp
f0105d18:	c3                   	ret    

f0105d19 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105d19:	f3 0f 1e fb          	endbr32 
f0105d1d:	55                   	push   %ebp
f0105d1e:	89 e5                	mov    %esp,%ebp
f0105d20:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105d23:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105d26:	0f b6 01             	movzbl (%ecx),%eax
f0105d29:	84 c0                	test   %al,%al
f0105d2b:	74 0c                	je     f0105d39 <strcmp+0x20>
f0105d2d:	3a 02                	cmp    (%edx),%al
f0105d2f:	75 08                	jne    f0105d39 <strcmp+0x20>
		p++, q++;
f0105d31:	83 c1 01             	add    $0x1,%ecx
f0105d34:	83 c2 01             	add    $0x1,%edx
f0105d37:	eb ed                	jmp    f0105d26 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105d39:	0f b6 c0             	movzbl %al,%eax
f0105d3c:	0f b6 12             	movzbl (%edx),%edx
f0105d3f:	29 d0                	sub    %edx,%eax
}
f0105d41:	5d                   	pop    %ebp
f0105d42:	c3                   	ret    

f0105d43 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105d43:	f3 0f 1e fb          	endbr32 
f0105d47:	55                   	push   %ebp
f0105d48:	89 e5                	mov    %esp,%ebp
f0105d4a:	53                   	push   %ebx
f0105d4b:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d4e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105d51:	89 c3                	mov    %eax,%ebx
f0105d53:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105d56:	eb 06                	jmp    f0105d5e <strncmp+0x1b>
		n--, p++, q++;
f0105d58:	83 c0 01             	add    $0x1,%eax
f0105d5b:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0105d5e:	39 d8                	cmp    %ebx,%eax
f0105d60:	74 16                	je     f0105d78 <strncmp+0x35>
f0105d62:	0f b6 08             	movzbl (%eax),%ecx
f0105d65:	84 c9                	test   %cl,%cl
f0105d67:	74 04                	je     f0105d6d <strncmp+0x2a>
f0105d69:	3a 0a                	cmp    (%edx),%cl
f0105d6b:	74 eb                	je     f0105d58 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105d6d:	0f b6 00             	movzbl (%eax),%eax
f0105d70:	0f b6 12             	movzbl (%edx),%edx
f0105d73:	29 d0                	sub    %edx,%eax
}
f0105d75:	5b                   	pop    %ebx
f0105d76:	5d                   	pop    %ebp
f0105d77:	c3                   	ret    
		return 0;
f0105d78:	b8 00 00 00 00       	mov    $0x0,%eax
f0105d7d:	eb f6                	jmp    f0105d75 <strncmp+0x32>

f0105d7f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105d7f:	f3 0f 1e fb          	endbr32 
f0105d83:	55                   	push   %ebp
f0105d84:	89 e5                	mov    %esp,%ebp
f0105d86:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d89:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105d8d:	0f b6 10             	movzbl (%eax),%edx
f0105d90:	84 d2                	test   %dl,%dl
f0105d92:	74 09                	je     f0105d9d <strchr+0x1e>
		if (*s == c)
f0105d94:	38 ca                	cmp    %cl,%dl
f0105d96:	74 0a                	je     f0105da2 <strchr+0x23>
	for (; *s; s++)
f0105d98:	83 c0 01             	add    $0x1,%eax
f0105d9b:	eb f0                	jmp    f0105d8d <strchr+0xe>
			return (char *) s;
	return 0;
f0105d9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105da2:	5d                   	pop    %ebp
f0105da3:	c3                   	ret    

f0105da4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105da4:	f3 0f 1e fb          	endbr32 
f0105da8:	55                   	push   %ebp
f0105da9:	89 e5                	mov    %esp,%ebp
f0105dab:	8b 45 08             	mov    0x8(%ebp),%eax
f0105dae:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105db2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105db5:	38 ca                	cmp    %cl,%dl
f0105db7:	74 09                	je     f0105dc2 <strfind+0x1e>
f0105db9:	84 d2                	test   %dl,%dl
f0105dbb:	74 05                	je     f0105dc2 <strfind+0x1e>
	for (; *s; s++)
f0105dbd:	83 c0 01             	add    $0x1,%eax
f0105dc0:	eb f0                	jmp    f0105db2 <strfind+0xe>
			break;
	return (char *) s;
}
f0105dc2:	5d                   	pop    %ebp
f0105dc3:	c3                   	ret    

f0105dc4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105dc4:	f3 0f 1e fb          	endbr32 
f0105dc8:	55                   	push   %ebp
f0105dc9:	89 e5                	mov    %esp,%ebp
f0105dcb:	57                   	push   %edi
f0105dcc:	56                   	push   %esi
f0105dcd:	53                   	push   %ebx
f0105dce:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105dd1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105dd4:	85 c9                	test   %ecx,%ecx
f0105dd6:	74 31                	je     f0105e09 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105dd8:	89 f8                	mov    %edi,%eax
f0105dda:	09 c8                	or     %ecx,%eax
f0105ddc:	a8 03                	test   $0x3,%al
f0105dde:	75 23                	jne    f0105e03 <memset+0x3f>
		c &= 0xFF;
f0105de0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105de4:	89 d3                	mov    %edx,%ebx
f0105de6:	c1 e3 08             	shl    $0x8,%ebx
f0105de9:	89 d0                	mov    %edx,%eax
f0105deb:	c1 e0 18             	shl    $0x18,%eax
f0105dee:	89 d6                	mov    %edx,%esi
f0105df0:	c1 e6 10             	shl    $0x10,%esi
f0105df3:	09 f0                	or     %esi,%eax
f0105df5:	09 c2                	or     %eax,%edx
f0105df7:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105df9:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0105dfc:	89 d0                	mov    %edx,%eax
f0105dfe:	fc                   	cld    
f0105dff:	f3 ab                	rep stos %eax,%es:(%edi)
f0105e01:	eb 06                	jmp    f0105e09 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105e03:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105e06:	fc                   	cld    
f0105e07:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105e09:	89 f8                	mov    %edi,%eax
f0105e0b:	5b                   	pop    %ebx
f0105e0c:	5e                   	pop    %esi
f0105e0d:	5f                   	pop    %edi
f0105e0e:	5d                   	pop    %ebp
f0105e0f:	c3                   	ret    

f0105e10 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105e10:	f3 0f 1e fb          	endbr32 
f0105e14:	55                   	push   %ebp
f0105e15:	89 e5                	mov    %esp,%ebp
f0105e17:	57                   	push   %edi
f0105e18:	56                   	push   %esi
f0105e19:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e1c:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105e1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105e22:	39 c6                	cmp    %eax,%esi
f0105e24:	73 32                	jae    f0105e58 <memmove+0x48>
f0105e26:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105e29:	39 c2                	cmp    %eax,%edx
f0105e2b:	76 2b                	jbe    f0105e58 <memmove+0x48>
		s += n;
		d += n;
f0105e2d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105e30:	89 fe                	mov    %edi,%esi
f0105e32:	09 ce                	or     %ecx,%esi
f0105e34:	09 d6                	or     %edx,%esi
f0105e36:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105e3c:	75 0e                	jne    f0105e4c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105e3e:	83 ef 04             	sub    $0x4,%edi
f0105e41:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105e44:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0105e47:	fd                   	std    
f0105e48:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105e4a:	eb 09                	jmp    f0105e55 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105e4c:	83 ef 01             	sub    $0x1,%edi
f0105e4f:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0105e52:	fd                   	std    
f0105e53:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105e55:	fc                   	cld    
f0105e56:	eb 1a                	jmp    f0105e72 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105e58:	89 c2                	mov    %eax,%edx
f0105e5a:	09 ca                	or     %ecx,%edx
f0105e5c:	09 f2                	or     %esi,%edx
f0105e5e:	f6 c2 03             	test   $0x3,%dl
f0105e61:	75 0a                	jne    f0105e6d <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105e63:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0105e66:	89 c7                	mov    %eax,%edi
f0105e68:	fc                   	cld    
f0105e69:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105e6b:	eb 05                	jmp    f0105e72 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
f0105e6d:	89 c7                	mov    %eax,%edi
f0105e6f:	fc                   	cld    
f0105e70:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105e72:	5e                   	pop    %esi
f0105e73:	5f                   	pop    %edi
f0105e74:	5d                   	pop    %ebp
f0105e75:	c3                   	ret    

f0105e76 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105e76:	f3 0f 1e fb          	endbr32 
f0105e7a:	55                   	push   %ebp
f0105e7b:	89 e5                	mov    %esp,%ebp
f0105e7d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105e80:	ff 75 10             	pushl  0x10(%ebp)
f0105e83:	ff 75 0c             	pushl  0xc(%ebp)
f0105e86:	ff 75 08             	pushl  0x8(%ebp)
f0105e89:	e8 82 ff ff ff       	call   f0105e10 <memmove>
}
f0105e8e:	c9                   	leave  
f0105e8f:	c3                   	ret    

f0105e90 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105e90:	f3 0f 1e fb          	endbr32 
f0105e94:	55                   	push   %ebp
f0105e95:	89 e5                	mov    %esp,%ebp
f0105e97:	56                   	push   %esi
f0105e98:	53                   	push   %ebx
f0105e99:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e9c:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105e9f:	89 c6                	mov    %eax,%esi
f0105ea1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105ea4:	39 f0                	cmp    %esi,%eax
f0105ea6:	74 1c                	je     f0105ec4 <memcmp+0x34>
		if (*s1 != *s2)
f0105ea8:	0f b6 08             	movzbl (%eax),%ecx
f0105eab:	0f b6 1a             	movzbl (%edx),%ebx
f0105eae:	38 d9                	cmp    %bl,%cl
f0105eb0:	75 08                	jne    f0105eba <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0105eb2:	83 c0 01             	add    $0x1,%eax
f0105eb5:	83 c2 01             	add    $0x1,%edx
f0105eb8:	eb ea                	jmp    f0105ea4 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
f0105eba:	0f b6 c1             	movzbl %cl,%eax
f0105ebd:	0f b6 db             	movzbl %bl,%ebx
f0105ec0:	29 d8                	sub    %ebx,%eax
f0105ec2:	eb 05                	jmp    f0105ec9 <memcmp+0x39>
	}

	return 0;
f0105ec4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105ec9:	5b                   	pop    %ebx
f0105eca:	5e                   	pop    %esi
f0105ecb:	5d                   	pop    %ebp
f0105ecc:	c3                   	ret    

f0105ecd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105ecd:	f3 0f 1e fb          	endbr32 
f0105ed1:	55                   	push   %ebp
f0105ed2:	89 e5                	mov    %esp,%ebp
f0105ed4:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ed7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105eda:	89 c2                	mov    %eax,%edx
f0105edc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105edf:	39 d0                	cmp    %edx,%eax
f0105ee1:	73 09                	jae    f0105eec <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105ee3:	38 08                	cmp    %cl,(%eax)
f0105ee5:	74 05                	je     f0105eec <memfind+0x1f>
	for (; s < ends; s++)
f0105ee7:	83 c0 01             	add    $0x1,%eax
f0105eea:	eb f3                	jmp    f0105edf <memfind+0x12>
			break;
	return (void *) s;
}
f0105eec:	5d                   	pop    %ebp
f0105eed:	c3                   	ret    

f0105eee <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105eee:	f3 0f 1e fb          	endbr32 
f0105ef2:	55                   	push   %ebp
f0105ef3:	89 e5                	mov    %esp,%ebp
f0105ef5:	57                   	push   %edi
f0105ef6:	56                   	push   %esi
f0105ef7:	53                   	push   %ebx
f0105ef8:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105efb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105efe:	eb 03                	jmp    f0105f03 <strtol+0x15>
		s++;
f0105f00:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0105f03:	0f b6 01             	movzbl (%ecx),%eax
f0105f06:	3c 20                	cmp    $0x20,%al
f0105f08:	74 f6                	je     f0105f00 <strtol+0x12>
f0105f0a:	3c 09                	cmp    $0x9,%al
f0105f0c:	74 f2                	je     f0105f00 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
f0105f0e:	3c 2b                	cmp    $0x2b,%al
f0105f10:	74 2a                	je     f0105f3c <strtol+0x4e>
	int neg = 0;
f0105f12:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0105f17:	3c 2d                	cmp    $0x2d,%al
f0105f19:	74 2b                	je     f0105f46 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105f1b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105f21:	75 0f                	jne    f0105f32 <strtol+0x44>
f0105f23:	80 39 30             	cmpb   $0x30,(%ecx)
f0105f26:	74 28                	je     f0105f50 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105f28:	85 db                	test   %ebx,%ebx
f0105f2a:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105f2f:	0f 44 d8             	cmove  %eax,%ebx
f0105f32:	b8 00 00 00 00       	mov    $0x0,%eax
f0105f37:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105f3a:	eb 46                	jmp    f0105f82 <strtol+0x94>
		s++;
f0105f3c:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0105f3f:	bf 00 00 00 00       	mov    $0x0,%edi
f0105f44:	eb d5                	jmp    f0105f1b <strtol+0x2d>
		s++, neg = 1;
f0105f46:	83 c1 01             	add    $0x1,%ecx
f0105f49:	bf 01 00 00 00       	mov    $0x1,%edi
f0105f4e:	eb cb                	jmp    f0105f1b <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105f50:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105f54:	74 0e                	je     f0105f64 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0105f56:	85 db                	test   %ebx,%ebx
f0105f58:	75 d8                	jne    f0105f32 <strtol+0x44>
		s++, base = 8;
f0105f5a:	83 c1 01             	add    $0x1,%ecx
f0105f5d:	bb 08 00 00 00       	mov    $0x8,%ebx
f0105f62:	eb ce                	jmp    f0105f32 <strtol+0x44>
		s += 2, base = 16;
f0105f64:	83 c1 02             	add    $0x2,%ecx
f0105f67:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105f6c:	eb c4                	jmp    f0105f32 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f0105f6e:	0f be d2             	movsbl %dl,%edx
f0105f71:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105f74:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105f77:	7d 3a                	jge    f0105fb3 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f0105f79:	83 c1 01             	add    $0x1,%ecx
f0105f7c:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105f80:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0105f82:	0f b6 11             	movzbl (%ecx),%edx
f0105f85:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105f88:	89 f3                	mov    %esi,%ebx
f0105f8a:	80 fb 09             	cmp    $0x9,%bl
f0105f8d:	76 df                	jbe    f0105f6e <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
f0105f8f:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105f92:	89 f3                	mov    %esi,%ebx
f0105f94:	80 fb 19             	cmp    $0x19,%bl
f0105f97:	77 08                	ja     f0105fa1 <strtol+0xb3>
			dig = *s - 'a' + 10;
f0105f99:	0f be d2             	movsbl %dl,%edx
f0105f9c:	83 ea 57             	sub    $0x57,%edx
f0105f9f:	eb d3                	jmp    f0105f74 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
f0105fa1:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105fa4:	89 f3                	mov    %esi,%ebx
f0105fa6:	80 fb 19             	cmp    $0x19,%bl
f0105fa9:	77 08                	ja     f0105fb3 <strtol+0xc5>
			dig = *s - 'A' + 10;
f0105fab:	0f be d2             	movsbl %dl,%edx
f0105fae:	83 ea 37             	sub    $0x37,%edx
f0105fb1:	eb c1                	jmp    f0105f74 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
f0105fb3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105fb7:	74 05                	je     f0105fbe <strtol+0xd0>
		*endptr = (char *) s;
f0105fb9:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105fbc:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0105fbe:	89 c2                	mov    %eax,%edx
f0105fc0:	f7 da                	neg    %edx
f0105fc2:	85 ff                	test   %edi,%edi
f0105fc4:	0f 45 c2             	cmovne %edx,%eax
}
f0105fc7:	5b                   	pop    %ebx
f0105fc8:	5e                   	pop    %esi
f0105fc9:	5f                   	pop    %edi
f0105fca:	5d                   	pop    %ebp
f0105fcb:	c3                   	ret    

f0105fcc <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105fcc:	fa                   	cli    

	xorw    %ax, %ax
f0105fcd:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105fcf:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105fd1:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105fd3:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105fd5:	0f 01 16             	lgdtl  (%esi)
f0105fd8:	74 70                	je     f010604a <mpsearch1+0x3>
	movl    %cr0, %eax
f0105fda:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105fdd:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105fe1:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105fe4:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105fea:	08 00                	or     %al,(%eax)

f0105fec <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105fec:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105ff0:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105ff2:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105ff4:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105ff6:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105ffa:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105ffc:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105ffe:	b8 00 20 12 00       	mov    $0x122000,%eax
	movl    %eax, %cr3
f0106003:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0106006:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0106009:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010600e:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0106011:	8b 25 84 fe 32 f0    	mov    0xf032fe84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0106017:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f010601c:	b8 bd 01 10 f0       	mov    $0xf01001bd,%eax
	call    *%eax
f0106021:	ff d0                	call   *%eax

f0106023 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0106023:	eb fe                	jmp    f0106023 <spin>
f0106025:	8d 76 00             	lea    0x0(%esi),%esi

f0106028 <gdt>:
	...
f0106030:	ff                   	(bad)  
f0106031:	ff 00                	incl   (%eax)
f0106033:	00 00                	add    %al,(%eax)
f0106035:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f010603c:	00                   	.byte 0x0
f010603d:	92                   	xchg   %eax,%edx
f010603e:	cf                   	iret   
	...

f0106040 <gdtdesc>:
f0106040:	17                   	pop    %ss
f0106041:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0106046 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0106046:	90                   	nop

f0106047 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0106047:	55                   	push   %ebp
f0106048:	89 e5                	mov    %esp,%ebp
f010604a:	57                   	push   %edi
f010604b:	56                   	push   %esi
f010604c:	53                   	push   %ebx
f010604d:	83 ec 0c             	sub    $0xc,%esp
f0106050:	89 c7                	mov    %eax,%edi
	if (PGNUM(pa) >= npages)
f0106052:	a1 88 fe 32 f0       	mov    0xf032fe88,%eax
f0106057:	89 f9                	mov    %edi,%ecx
f0106059:	c1 e9 0c             	shr    $0xc,%ecx
f010605c:	39 c1                	cmp    %eax,%ecx
f010605e:	73 19                	jae    f0106079 <mpsearch1+0x32>
	return (void *)(pa + KERNBASE);
f0106060:	8d 9f 00 00 00 f0    	lea    -0x10000000(%edi),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0106066:	01 d7                	add    %edx,%edi
	if (PGNUM(pa) >= npages)
f0106068:	89 fa                	mov    %edi,%edx
f010606a:	c1 ea 0c             	shr    $0xc,%edx
f010606d:	39 c2                	cmp    %eax,%edx
f010606f:	73 1a                	jae    f010608b <mpsearch1+0x44>
	return (void *)(pa + KERNBASE);
f0106071:	81 ef 00 00 00 10    	sub    $0x10000000,%edi

	for (; mp < end; mp++)
f0106077:	eb 27                	jmp    f01060a0 <mpsearch1+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106079:	57                   	push   %edi
f010607a:	68 84 6a 10 f0       	push   $0xf0106a84
f010607f:	6a 57                	push   $0x57
f0106081:	68 5d 87 10 f0       	push   $0xf010875d
f0106086:	e8 b5 9f ff ff       	call   f0100040 <_panic>
f010608b:	57                   	push   %edi
f010608c:	68 84 6a 10 f0       	push   $0xf0106a84
f0106091:	6a 57                	push   $0x57
f0106093:	68 5d 87 10 f0       	push   $0xf010875d
f0106098:	e8 a3 9f ff ff       	call   f0100040 <_panic>
f010609d:	83 c3 10             	add    $0x10,%ebx
f01060a0:	39 fb                	cmp    %edi,%ebx
f01060a2:	73 30                	jae    f01060d4 <mpsearch1+0x8d>
f01060a4:	89 de                	mov    %ebx,%esi
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01060a6:	83 ec 04             	sub    $0x4,%esp
f01060a9:	6a 04                	push   $0x4
f01060ab:	68 6d 87 10 f0       	push   $0xf010876d
f01060b0:	53                   	push   %ebx
f01060b1:	e8 da fd ff ff       	call   f0105e90 <memcmp>
f01060b6:	83 c4 10             	add    $0x10,%esp
f01060b9:	85 c0                	test   %eax,%eax
f01060bb:	75 e0                	jne    f010609d <mpsearch1+0x56>
f01060bd:	89 da                	mov    %ebx,%edx
	for (i = 0; i < len; i++)
f01060bf:	83 c6 10             	add    $0x10,%esi
		sum += ((uint8_t *)addr)[i];
f01060c2:	0f b6 0a             	movzbl (%edx),%ecx
f01060c5:	01 c8                	add    %ecx,%eax
f01060c7:	83 c2 01             	add    $0x1,%edx
	for (i = 0; i < len; i++)
f01060ca:	39 f2                	cmp    %esi,%edx
f01060cc:	75 f4                	jne    f01060c2 <mpsearch1+0x7b>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01060ce:	84 c0                	test   %al,%al
f01060d0:	75 cb                	jne    f010609d <mpsearch1+0x56>
f01060d2:	eb 05                	jmp    f01060d9 <mpsearch1+0x92>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01060d4:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f01060d9:	89 d8                	mov    %ebx,%eax
f01060db:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01060de:	5b                   	pop    %ebx
f01060df:	5e                   	pop    %esi
f01060e0:	5f                   	pop    %edi
f01060e1:	5d                   	pop    %ebp
f01060e2:	c3                   	ret    

f01060e3 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01060e3:	f3 0f 1e fb          	endbr32 
f01060e7:	55                   	push   %ebp
f01060e8:	89 e5                	mov    %esp,%ebp
f01060ea:	57                   	push   %edi
f01060eb:	56                   	push   %esi
f01060ec:	53                   	push   %ebx
f01060ed:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01060f0:	c7 05 c0 03 33 f0 20 	movl   $0xf0330020,0xf03303c0
f01060f7:	00 33 f0 
	if (PGNUM(pa) >= npages)
f01060fa:	83 3d 88 fe 32 f0 00 	cmpl   $0x0,0xf032fe88
f0106101:	0f 84 a3 00 00 00    	je     f01061aa <mp_init+0xc7>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0106107:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f010610e:	85 c0                	test   %eax,%eax
f0106110:	0f 84 aa 00 00 00    	je     f01061c0 <mp_init+0xdd>
		p <<= 4;	// Translate from segment to PA
f0106116:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0106119:	ba 00 04 00 00       	mov    $0x400,%edx
f010611e:	e8 24 ff ff ff       	call   f0106047 <mpsearch1>
f0106123:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106126:	85 c0                	test   %eax,%eax
f0106128:	75 1a                	jne    f0106144 <mp_init+0x61>
	return mpsearch1(0xF0000, 0x10000);
f010612a:	ba 00 00 01 00       	mov    $0x10000,%edx
f010612f:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0106134:	e8 0e ff ff ff       	call   f0106047 <mpsearch1>
f0106139:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((mp = mpsearch()) == 0)
f010613c:	85 c0                	test   %eax,%eax
f010613e:	0f 84 35 02 00 00    	je     f0106379 <mp_init+0x296>
	if (mp->physaddr == 0 || mp->type != 0) {
f0106144:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106147:	8b 58 04             	mov    0x4(%eax),%ebx
f010614a:	85 db                	test   %ebx,%ebx
f010614c:	0f 84 97 00 00 00    	je     f01061e9 <mp_init+0x106>
f0106152:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0106156:	0f 85 8d 00 00 00    	jne    f01061e9 <mp_init+0x106>
f010615c:	89 d8                	mov    %ebx,%eax
f010615e:	c1 e8 0c             	shr    $0xc,%eax
f0106161:	3b 05 88 fe 32 f0    	cmp    0xf032fe88,%eax
f0106167:	0f 83 91 00 00 00    	jae    f01061fe <mp_init+0x11b>
	return (void *)(pa + KERNBASE);
f010616d:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
f0106173:	89 de                	mov    %ebx,%esi
	if (memcmp(conf, "PCMP", 4) != 0) {
f0106175:	83 ec 04             	sub    $0x4,%esp
f0106178:	6a 04                	push   $0x4
f010617a:	68 72 87 10 f0       	push   $0xf0108772
f010617f:	53                   	push   %ebx
f0106180:	e8 0b fd ff ff       	call   f0105e90 <memcmp>
f0106185:	83 c4 10             	add    $0x10,%esp
f0106188:	85 c0                	test   %eax,%eax
f010618a:	0f 85 83 00 00 00    	jne    f0106213 <mp_init+0x130>
f0106190:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
f0106194:	01 df                	add    %ebx,%edi
	sum = 0;
f0106196:	89 c2                	mov    %eax,%edx
	for (i = 0; i < len; i++)
f0106198:	39 fb                	cmp    %edi,%ebx
f010619a:	0f 84 88 00 00 00    	je     f0106228 <mp_init+0x145>
		sum += ((uint8_t *)addr)[i];
f01061a0:	0f b6 0b             	movzbl (%ebx),%ecx
f01061a3:	01 ca                	add    %ecx,%edx
f01061a5:	83 c3 01             	add    $0x1,%ebx
f01061a8:	eb ee                	jmp    f0106198 <mp_init+0xb5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01061aa:	68 00 04 00 00       	push   $0x400
f01061af:	68 84 6a 10 f0       	push   $0xf0106a84
f01061b4:	6a 6f                	push   $0x6f
f01061b6:	68 5d 87 10 f0       	push   $0xf010875d
f01061bb:	e8 80 9e ff ff       	call   f0100040 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f01061c0:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01061c7:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f01061ca:	2d 00 04 00 00       	sub    $0x400,%eax
f01061cf:	ba 00 04 00 00       	mov    $0x400,%edx
f01061d4:	e8 6e fe ff ff       	call   f0106047 <mpsearch1>
f01061d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01061dc:	85 c0                	test   %eax,%eax
f01061de:	0f 85 60 ff ff ff    	jne    f0106144 <mp_init+0x61>
f01061e4:	e9 41 ff ff ff       	jmp    f010612a <mp_init+0x47>
		cprintf("SMP: Default configurations not implemented\n");
f01061e9:	83 ec 0c             	sub    $0xc,%esp
f01061ec:	68 d0 85 10 f0       	push   $0xf01085d0
f01061f1:	e8 48 d9 ff ff       	call   f0103b3e <cprintf>
		return NULL;
f01061f6:	83 c4 10             	add    $0x10,%esp
f01061f9:	e9 7b 01 00 00       	jmp    f0106379 <mp_init+0x296>
f01061fe:	53                   	push   %ebx
f01061ff:	68 84 6a 10 f0       	push   $0xf0106a84
f0106204:	68 90 00 00 00       	push   $0x90
f0106209:	68 5d 87 10 f0       	push   $0xf010875d
f010620e:	e8 2d 9e ff ff       	call   f0100040 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0106213:	83 ec 0c             	sub    $0xc,%esp
f0106216:	68 00 86 10 f0       	push   $0xf0108600
f010621b:	e8 1e d9 ff ff       	call   f0103b3e <cprintf>
		return NULL;
f0106220:	83 c4 10             	add    $0x10,%esp
f0106223:	e9 51 01 00 00       	jmp    f0106379 <mp_init+0x296>
	if (sum(conf, conf->length) != 0) {
f0106228:	84 d2                	test   %dl,%dl
f010622a:	75 22                	jne    f010624e <mp_init+0x16b>
	if (conf->version != 1 && conf->version != 4) {
f010622c:	0f b6 56 06          	movzbl 0x6(%esi),%edx
f0106230:	80 fa 01             	cmp    $0x1,%dl
f0106233:	74 05                	je     f010623a <mp_init+0x157>
f0106235:	80 fa 04             	cmp    $0x4,%dl
f0106238:	75 29                	jne    f0106263 <mp_init+0x180>
f010623a:	0f b7 4e 28          	movzwl 0x28(%esi),%ecx
f010623e:	01 d9                	add    %ebx,%ecx
	for (i = 0; i < len; i++)
f0106240:	39 d9                	cmp    %ebx,%ecx
f0106242:	74 38                	je     f010627c <mp_init+0x199>
		sum += ((uint8_t *)addr)[i];
f0106244:	0f b6 13             	movzbl (%ebx),%edx
f0106247:	01 d0                	add    %edx,%eax
f0106249:	83 c3 01             	add    $0x1,%ebx
f010624c:	eb f2                	jmp    f0106240 <mp_init+0x15d>
		cprintf("SMP: Bad MP configuration checksum\n");
f010624e:	83 ec 0c             	sub    $0xc,%esp
f0106251:	68 34 86 10 f0       	push   $0xf0108634
f0106256:	e8 e3 d8 ff ff       	call   f0103b3e <cprintf>
		return NULL;
f010625b:	83 c4 10             	add    $0x10,%esp
f010625e:	e9 16 01 00 00       	jmp    f0106379 <mp_init+0x296>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0106263:	83 ec 08             	sub    $0x8,%esp
f0106266:	0f b6 d2             	movzbl %dl,%edx
f0106269:	52                   	push   %edx
f010626a:	68 58 86 10 f0       	push   $0xf0108658
f010626f:	e8 ca d8 ff ff       	call   f0103b3e <cprintf>
		return NULL;
f0106274:	83 c4 10             	add    $0x10,%esp
f0106277:	e9 fd 00 00 00       	jmp    f0106379 <mp_init+0x296>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010627c:	02 46 2a             	add    0x2a(%esi),%al
f010627f:	75 1c                	jne    f010629d <mp_init+0x1ba>
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
f0106281:	c7 05 00 00 33 f0 01 	movl   $0x1,0xf0330000
f0106288:	00 00 00 
	lapicaddr = conf->lapicaddr;
f010628b:	8b 46 24             	mov    0x24(%esi),%eax
f010628e:	a3 00 10 37 f0       	mov    %eax,0xf0371000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106293:	8d 7e 2c             	lea    0x2c(%esi),%edi
f0106296:	bb 00 00 00 00       	mov    $0x0,%ebx
f010629b:	eb 4d                	jmp    f01062ea <mp_init+0x207>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f010629d:	83 ec 0c             	sub    $0xc,%esp
f01062a0:	68 78 86 10 f0       	push   $0xf0108678
f01062a5:	e8 94 d8 ff ff       	call   f0103b3e <cprintf>
		return NULL;
f01062aa:	83 c4 10             	add    $0x10,%esp
f01062ad:	e9 c7 00 00 00       	jmp    f0106379 <mp_init+0x296>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f01062b2:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f01062b6:	74 11                	je     f01062c9 <mp_init+0x1e6>
				bootcpu = &cpus[ncpu];
f01062b8:	6b 05 c4 03 33 f0 74 	imul   $0x74,0xf03303c4,%eax
f01062bf:	05 20 00 33 f0       	add    $0xf0330020,%eax
f01062c4:	a3 c0 03 33 f0       	mov    %eax,0xf03303c0
			if (ncpu < NCPU) {
f01062c9:	a1 c4 03 33 f0       	mov    0xf03303c4,%eax
f01062ce:	83 f8 07             	cmp    $0x7,%eax
f01062d1:	7f 33                	jg     f0106306 <mp_init+0x223>
				cpus[ncpu].cpu_id = ncpu;
f01062d3:	6b d0 74             	imul   $0x74,%eax,%edx
f01062d6:	88 82 20 00 33 f0    	mov    %al,-0xfccffe0(%edx)
				ncpu++;
f01062dc:	83 c0 01             	add    $0x1,%eax
f01062df:	a3 c4 03 33 f0       	mov    %eax,0xf03303c4
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f01062e4:	83 c7 14             	add    $0x14,%edi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01062e7:	83 c3 01             	add    $0x1,%ebx
f01062ea:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f01062ee:	39 d8                	cmp    %ebx,%eax
f01062f0:	76 4f                	jbe    f0106341 <mp_init+0x25e>
		switch (*p) {
f01062f2:	0f b6 07             	movzbl (%edi),%eax
f01062f5:	84 c0                	test   %al,%al
f01062f7:	74 b9                	je     f01062b2 <mp_init+0x1cf>
f01062f9:	8d 50 ff             	lea    -0x1(%eax),%edx
f01062fc:	80 fa 03             	cmp    $0x3,%dl
f01062ff:	77 1c                	ja     f010631d <mp_init+0x23a>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106301:	83 c7 08             	add    $0x8,%edi
			continue;
f0106304:	eb e1                	jmp    f01062e7 <mp_init+0x204>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106306:	83 ec 08             	sub    $0x8,%esp
f0106309:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f010630d:	50                   	push   %eax
f010630e:	68 a8 86 10 f0       	push   $0xf01086a8
f0106313:	e8 26 d8 ff ff       	call   f0103b3e <cprintf>
f0106318:	83 c4 10             	add    $0x10,%esp
f010631b:	eb c7                	jmp    f01062e4 <mp_init+0x201>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f010631d:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f0106320:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f0106323:	50                   	push   %eax
f0106324:	68 d0 86 10 f0       	push   $0xf01086d0
f0106329:	e8 10 d8 ff ff       	call   f0103b3e <cprintf>
			ismp = 0;
f010632e:	c7 05 00 00 33 f0 00 	movl   $0x0,0xf0330000
f0106335:	00 00 00 
			i = conf->entry;
f0106338:	0f b7 5e 22          	movzwl 0x22(%esi),%ebx
f010633c:	83 c4 10             	add    $0x10,%esp
f010633f:	eb a6                	jmp    f01062e7 <mp_init+0x204>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0106341:	a1 c0 03 33 f0       	mov    0xf03303c0,%eax
f0106346:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f010634d:	83 3d 00 00 33 f0 00 	cmpl   $0x0,0xf0330000
f0106354:	74 2b                	je     f0106381 <mp_init+0x29e>
		ncpu = 1;
		lapicaddr = 0;
		cprintf("SMP: configuration not found, SMP disabled\n");
		return;
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0106356:	83 ec 04             	sub    $0x4,%esp
f0106359:	ff 35 c4 03 33 f0    	pushl  0xf03303c4
f010635f:	0f b6 00             	movzbl (%eax),%eax
f0106362:	50                   	push   %eax
f0106363:	68 77 87 10 f0       	push   $0xf0108777
f0106368:	e8 d1 d7 ff ff       	call   f0103b3e <cprintf>

	if (mp->imcrp) {
f010636d:	83 c4 10             	add    $0x10,%esp
f0106370:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106373:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106377:	75 2e                	jne    f01063a7 <mp_init+0x2c4>
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0106379:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010637c:	5b                   	pop    %ebx
f010637d:	5e                   	pop    %esi
f010637e:	5f                   	pop    %edi
f010637f:	5d                   	pop    %ebp
f0106380:	c3                   	ret    
		ncpu = 1;
f0106381:	c7 05 c4 03 33 f0 01 	movl   $0x1,0xf03303c4
f0106388:	00 00 00 
		lapicaddr = 0;
f010638b:	c7 05 00 10 37 f0 00 	movl   $0x0,0xf0371000
f0106392:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106395:	83 ec 0c             	sub    $0xc,%esp
f0106398:	68 f0 86 10 f0       	push   $0xf01086f0
f010639d:	e8 9c d7 ff ff       	call   f0103b3e <cprintf>
		return;
f01063a2:	83 c4 10             	add    $0x10,%esp
f01063a5:	eb d2                	jmp    f0106379 <mp_init+0x296>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01063a7:	83 ec 0c             	sub    $0xc,%esp
f01063aa:	68 1c 87 10 f0       	push   $0xf010871c
f01063af:	e8 8a d7 ff ff       	call   f0103b3e <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01063b4:	b8 70 00 00 00       	mov    $0x70,%eax
f01063b9:	ba 22 00 00 00       	mov    $0x22,%edx
f01063be:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01063bf:	ba 23 00 00 00       	mov    $0x23,%edx
f01063c4:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f01063c5:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01063c8:	ee                   	out    %al,(%dx)
}
f01063c9:	83 c4 10             	add    $0x10,%esp
f01063cc:	eb ab                	jmp    f0106379 <mp_init+0x296>

f01063ce <lapicw>:
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
	lapic[index] = value;
f01063ce:	8b 0d 04 10 37 f0    	mov    0xf0371004,%ecx
f01063d4:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f01063d7:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f01063d9:	a1 04 10 37 f0       	mov    0xf0371004,%eax
f01063de:	8b 40 20             	mov    0x20(%eax),%eax
}
f01063e1:	c3                   	ret    

f01063e2 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f01063e2:	f3 0f 1e fb          	endbr32 
	if (lapic)
f01063e6:	8b 15 04 10 37 f0    	mov    0xf0371004,%edx
		return lapic[ID] >> 24;
	return 0;
f01063ec:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lapic)
f01063f1:	85 d2                	test   %edx,%edx
f01063f3:	74 06                	je     f01063fb <cpunum+0x19>
		return lapic[ID] >> 24;
f01063f5:	8b 42 20             	mov    0x20(%edx),%eax
f01063f8:	c1 e8 18             	shr    $0x18,%eax
}
f01063fb:	c3                   	ret    

f01063fc <lapic_init>:
{
f01063fc:	f3 0f 1e fb          	endbr32 
	if (!lapicaddr)
f0106400:	a1 00 10 37 f0       	mov    0xf0371000,%eax
f0106405:	85 c0                	test   %eax,%eax
f0106407:	75 01                	jne    f010640a <lapic_init+0xe>
f0106409:	c3                   	ret    
{
f010640a:	55                   	push   %ebp
f010640b:	89 e5                	mov    %esp,%ebp
f010640d:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f0106410:	68 00 10 00 00       	push   $0x1000
f0106415:	50                   	push   %eax
f0106416:	e8 2b af ff ff       	call   f0101346 <mmio_map_region>
f010641b:	a3 04 10 37 f0       	mov    %eax,0xf0371004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0106420:	ba 27 01 00 00       	mov    $0x127,%edx
f0106425:	b8 3c 00 00 00       	mov    $0x3c,%eax
f010642a:	e8 9f ff ff ff       	call   f01063ce <lapicw>
	lapicw(TDCR, X1);
f010642f:	ba 0b 00 00 00       	mov    $0xb,%edx
f0106434:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0106439:	e8 90 ff ff ff       	call   f01063ce <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f010643e:	ba 20 00 02 00       	mov    $0x20020,%edx
f0106443:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0106448:	e8 81 ff ff ff       	call   f01063ce <lapicw>
	lapicw(TICR, 10000000); 
f010644d:	ba 80 96 98 00       	mov    $0x989680,%edx
f0106452:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106457:	e8 72 ff ff ff       	call   f01063ce <lapicw>
	if (thiscpu != bootcpu)
f010645c:	e8 81 ff ff ff       	call   f01063e2 <cpunum>
f0106461:	6b c0 74             	imul   $0x74,%eax,%eax
f0106464:	05 20 00 33 f0       	add    $0xf0330020,%eax
f0106469:	83 c4 10             	add    $0x10,%esp
f010646c:	39 05 c0 03 33 f0    	cmp    %eax,0xf03303c0
f0106472:	74 0f                	je     f0106483 <lapic_init+0x87>
		lapicw(LINT0, MASKED);
f0106474:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106479:	b8 d4 00 00 00       	mov    $0xd4,%eax
f010647e:	e8 4b ff ff ff       	call   f01063ce <lapicw>
	lapicw(LINT1, MASKED);
f0106483:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106488:	b8 d8 00 00 00       	mov    $0xd8,%eax
f010648d:	e8 3c ff ff ff       	call   f01063ce <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0106492:	a1 04 10 37 f0       	mov    0xf0371004,%eax
f0106497:	8b 40 30             	mov    0x30(%eax),%eax
f010649a:	c1 e8 10             	shr    $0x10,%eax
f010649d:	a8 fc                	test   $0xfc,%al
f010649f:	75 7c                	jne    f010651d <lapic_init+0x121>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01064a1:	ba 33 00 00 00       	mov    $0x33,%edx
f01064a6:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01064ab:	e8 1e ff ff ff       	call   f01063ce <lapicw>
	lapicw(ESR, 0);
f01064b0:	ba 00 00 00 00       	mov    $0x0,%edx
f01064b5:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01064ba:	e8 0f ff ff ff       	call   f01063ce <lapicw>
	lapicw(ESR, 0);
f01064bf:	ba 00 00 00 00       	mov    $0x0,%edx
f01064c4:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01064c9:	e8 00 ff ff ff       	call   f01063ce <lapicw>
	lapicw(EOI, 0);
f01064ce:	ba 00 00 00 00       	mov    $0x0,%edx
f01064d3:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01064d8:	e8 f1 fe ff ff       	call   f01063ce <lapicw>
	lapicw(ICRHI, 0);
f01064dd:	ba 00 00 00 00       	mov    $0x0,%edx
f01064e2:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01064e7:	e8 e2 fe ff ff       	call   f01063ce <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01064ec:	ba 00 85 08 00       	mov    $0x88500,%edx
f01064f1:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01064f6:	e8 d3 fe ff ff       	call   f01063ce <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01064fb:	8b 15 04 10 37 f0    	mov    0xf0371004,%edx
f0106501:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106507:	f6 c4 10             	test   $0x10,%ah
f010650a:	75 f5                	jne    f0106501 <lapic_init+0x105>
	lapicw(TPR, 0);
f010650c:	ba 00 00 00 00       	mov    $0x0,%edx
f0106511:	b8 20 00 00 00       	mov    $0x20,%eax
f0106516:	e8 b3 fe ff ff       	call   f01063ce <lapicw>
}
f010651b:	c9                   	leave  
f010651c:	c3                   	ret    
		lapicw(PCINT, MASKED);
f010651d:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106522:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0106527:	e8 a2 fe ff ff       	call   f01063ce <lapicw>
f010652c:	e9 70 ff ff ff       	jmp    f01064a1 <lapic_init+0xa5>

f0106531 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0106531:	f3 0f 1e fb          	endbr32 
	if (lapic)
f0106535:	83 3d 04 10 37 f0 00 	cmpl   $0x0,0xf0371004
f010653c:	74 17                	je     f0106555 <lapic_eoi+0x24>
{
f010653e:	55                   	push   %ebp
f010653f:	89 e5                	mov    %esp,%ebp
f0106541:	83 ec 08             	sub    $0x8,%esp
		lapicw(EOI, 0);
f0106544:	ba 00 00 00 00       	mov    $0x0,%edx
f0106549:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010654e:	e8 7b fe ff ff       	call   f01063ce <lapicw>
}
f0106553:	c9                   	leave  
f0106554:	c3                   	ret    
f0106555:	c3                   	ret    

f0106556 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106556:	f3 0f 1e fb          	endbr32 
f010655a:	55                   	push   %ebp
f010655b:	89 e5                	mov    %esp,%ebp
f010655d:	56                   	push   %esi
f010655e:	53                   	push   %ebx
f010655f:	8b 75 08             	mov    0x8(%ebp),%esi
f0106562:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106565:	b8 0f 00 00 00       	mov    $0xf,%eax
f010656a:	ba 70 00 00 00       	mov    $0x70,%edx
f010656f:	ee                   	out    %al,(%dx)
f0106570:	b8 0a 00 00 00       	mov    $0xa,%eax
f0106575:	ba 71 00 00 00       	mov    $0x71,%edx
f010657a:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f010657b:	83 3d 88 fe 32 f0 00 	cmpl   $0x0,0xf032fe88
f0106582:	74 7e                	je     f0106602 <lapic_startap+0xac>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106584:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f010658b:	00 00 
	wrv[1] = addr >> 4;
f010658d:	89 d8                	mov    %ebx,%eax
f010658f:	c1 e8 04             	shr    $0x4,%eax
f0106592:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106598:	c1 e6 18             	shl    $0x18,%esi
f010659b:	89 f2                	mov    %esi,%edx
f010659d:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01065a2:	e8 27 fe ff ff       	call   f01063ce <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01065a7:	ba 00 c5 00 00       	mov    $0xc500,%edx
f01065ac:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01065b1:	e8 18 fe ff ff       	call   f01063ce <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01065b6:	ba 00 85 00 00       	mov    $0x8500,%edx
f01065bb:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01065c0:	e8 09 fe ff ff       	call   f01063ce <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01065c5:	c1 eb 0c             	shr    $0xc,%ebx
f01065c8:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f01065cb:	89 f2                	mov    %esi,%edx
f01065cd:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01065d2:	e8 f7 fd ff ff       	call   f01063ce <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01065d7:	89 da                	mov    %ebx,%edx
f01065d9:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01065de:	e8 eb fd ff ff       	call   f01063ce <lapicw>
		lapicw(ICRHI, apicid << 24);
f01065e3:	89 f2                	mov    %esi,%edx
f01065e5:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01065ea:	e8 df fd ff ff       	call   f01063ce <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01065ef:	89 da                	mov    %ebx,%edx
f01065f1:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01065f6:	e8 d3 fd ff ff       	call   f01063ce <lapicw>
		microdelay(200);
	}
}
f01065fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01065fe:	5b                   	pop    %ebx
f01065ff:	5e                   	pop    %esi
f0106600:	5d                   	pop    %ebp
f0106601:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106602:	68 67 04 00 00       	push   $0x467
f0106607:	68 84 6a 10 f0       	push   $0xf0106a84
f010660c:	68 98 00 00 00       	push   $0x98
f0106611:	68 94 87 10 f0       	push   $0xf0108794
f0106616:	e8 25 9a ff ff       	call   f0100040 <_panic>

f010661b <lapic_ipi>:

void
lapic_ipi(int vector)
{
f010661b:	f3 0f 1e fb          	endbr32 
f010661f:	55                   	push   %ebp
f0106620:	89 e5                	mov    %esp,%ebp
f0106622:	83 ec 08             	sub    $0x8,%esp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106625:	8b 55 08             	mov    0x8(%ebp),%edx
f0106628:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f010662e:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106633:	e8 96 fd ff ff       	call   f01063ce <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106638:	8b 15 04 10 37 f0    	mov    0xf0371004,%edx
f010663e:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106644:	f6 c4 10             	test   $0x10,%ah
f0106647:	75 f5                	jne    f010663e <lapic_ipi+0x23>
		;
}
f0106649:	c9                   	leave  
f010664a:	c3                   	ret    

f010664b <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f010664b:	f3 0f 1e fb          	endbr32 
f010664f:	55                   	push   %ebp
f0106650:	89 e5                	mov    %esp,%ebp
f0106652:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106655:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f010665b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010665e:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106661:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106668:	5d                   	pop    %ebp
f0106669:	c3                   	ret    

f010666a <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f010666a:	f3 0f 1e fb          	endbr32 
f010666e:	55                   	push   %ebp
f010666f:	89 e5                	mov    %esp,%ebp
f0106671:	56                   	push   %esi
f0106672:	53                   	push   %ebx
f0106673:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f0106676:	83 3b 00             	cmpl   $0x0,(%ebx)
f0106679:	75 07                	jne    f0106682 <spin_lock+0x18>
	asm volatile("lock; xchgl %0, %1"
f010667b:	ba 01 00 00 00       	mov    $0x1,%edx
f0106680:	eb 34                	jmp    f01066b6 <spin_lock+0x4c>
f0106682:	8b 73 08             	mov    0x8(%ebx),%esi
f0106685:	e8 58 fd ff ff       	call   f01063e2 <cpunum>
f010668a:	6b c0 74             	imul   $0x74,%eax,%eax
f010668d:	05 20 00 33 f0       	add    $0xf0330020,%eax
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106692:	39 c6                	cmp    %eax,%esi
f0106694:	75 e5                	jne    f010667b <spin_lock+0x11>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106696:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106699:	e8 44 fd ff ff       	call   f01063e2 <cpunum>
f010669e:	83 ec 0c             	sub    $0xc,%esp
f01066a1:	53                   	push   %ebx
f01066a2:	50                   	push   %eax
f01066a3:	68 a4 87 10 f0       	push   $0xf01087a4
f01066a8:	6a 41                	push   $0x41
f01066aa:	68 06 88 10 f0       	push   $0xf0108806
f01066af:	e8 8c 99 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f01066b4:	f3 90                	pause  
f01066b6:	89 d0                	mov    %edx,%eax
f01066b8:	f0 87 03             	lock xchg %eax,(%ebx)
	while (xchg(&lk->locked, 1) != 0)
f01066bb:	85 c0                	test   %eax,%eax
f01066bd:	75 f5                	jne    f01066b4 <spin_lock+0x4a>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f01066bf:	e8 1e fd ff ff       	call   f01063e2 <cpunum>
f01066c4:	6b c0 74             	imul   $0x74,%eax,%eax
f01066c7:	05 20 00 33 f0       	add    $0xf0330020,%eax
f01066cc:	89 43 08             	mov    %eax,0x8(%ebx)
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01066cf:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f01066d1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f01066d6:	83 f8 09             	cmp    $0x9,%eax
f01066d9:	7f 21                	jg     f01066fc <spin_lock+0x92>
f01066db:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01066e1:	76 19                	jbe    f01066fc <spin_lock+0x92>
		pcs[i] = ebp[1];          // saved %eip
f01066e3:	8b 4a 04             	mov    0x4(%edx),%ecx
f01066e6:	89 4c 83 0c          	mov    %ecx,0xc(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01066ea:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f01066ec:	83 c0 01             	add    $0x1,%eax
f01066ef:	eb e5                	jmp    f01066d6 <spin_lock+0x6c>
		pcs[i] = 0;
f01066f1:	c7 44 83 0c 00 00 00 	movl   $0x0,0xc(%ebx,%eax,4)
f01066f8:	00 
	for (; i < 10; i++)
f01066f9:	83 c0 01             	add    $0x1,%eax
f01066fc:	83 f8 09             	cmp    $0x9,%eax
f01066ff:	7e f0                	jle    f01066f1 <spin_lock+0x87>
	get_caller_pcs(lk->pcs);
#endif
}
f0106701:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106704:	5b                   	pop    %ebx
f0106705:	5e                   	pop    %esi
f0106706:	5d                   	pop    %ebp
f0106707:	c3                   	ret    

f0106708 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106708:	f3 0f 1e fb          	endbr32 
f010670c:	55                   	push   %ebp
f010670d:	89 e5                	mov    %esp,%ebp
f010670f:	57                   	push   %edi
f0106710:	56                   	push   %esi
f0106711:	53                   	push   %ebx
f0106712:	83 ec 4c             	sub    $0x4c,%esp
f0106715:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f0106718:	83 3e 00             	cmpl   $0x0,(%esi)
f010671b:	75 35                	jne    f0106752 <spin_unlock+0x4a>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f010671d:	83 ec 04             	sub    $0x4,%esp
f0106720:	6a 28                	push   $0x28
f0106722:	8d 46 0c             	lea    0xc(%esi),%eax
f0106725:	50                   	push   %eax
f0106726:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106729:	53                   	push   %ebx
f010672a:	e8 e1 f6 ff ff       	call   f0105e10 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f010672f:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106732:	0f b6 38             	movzbl (%eax),%edi
f0106735:	8b 76 04             	mov    0x4(%esi),%esi
f0106738:	e8 a5 fc ff ff       	call   f01063e2 <cpunum>
f010673d:	57                   	push   %edi
f010673e:	56                   	push   %esi
f010673f:	50                   	push   %eax
f0106740:	68 d0 87 10 f0       	push   $0xf01087d0
f0106745:	e8 f4 d3 ff ff       	call   f0103b3e <cprintf>
f010674a:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010674d:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0106750:	eb 4e                	jmp    f01067a0 <spin_unlock+0x98>
	return lock->locked && lock->cpu == thiscpu;
f0106752:	8b 5e 08             	mov    0x8(%esi),%ebx
f0106755:	e8 88 fc ff ff       	call   f01063e2 <cpunum>
f010675a:	6b c0 74             	imul   $0x74,%eax,%eax
f010675d:	05 20 00 33 f0       	add    $0xf0330020,%eax
	if (!holding(lk)) {
f0106762:	39 c3                	cmp    %eax,%ebx
f0106764:	75 b7                	jne    f010671d <spin_unlock+0x15>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f0106766:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f010676d:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f0106774:	b8 00 00 00 00       	mov    $0x0,%eax
f0106779:	f0 87 06             	lock xchg %eax,(%esi)
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
    //lk->locked = 0;
}
f010677c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010677f:	5b                   	pop    %ebx
f0106780:	5e                   	pop    %esi
f0106781:	5f                   	pop    %edi
f0106782:	5d                   	pop    %ebp
f0106783:	c3                   	ret    
				cprintf("  %08x\n", pcs[i]);
f0106784:	83 ec 08             	sub    $0x8,%esp
f0106787:	ff 36                	pushl  (%esi)
f0106789:	68 2d 88 10 f0       	push   $0xf010882d
f010678e:	e8 ab d3 ff ff       	call   f0103b3e <cprintf>
f0106793:	83 c4 10             	add    $0x10,%esp
f0106796:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106799:	8d 45 e8             	lea    -0x18(%ebp),%eax
f010679c:	39 c3                	cmp    %eax,%ebx
f010679e:	74 40                	je     f01067e0 <spin_unlock+0xd8>
f01067a0:	89 de                	mov    %ebx,%esi
f01067a2:	8b 03                	mov    (%ebx),%eax
f01067a4:	85 c0                	test   %eax,%eax
f01067a6:	74 38                	je     f01067e0 <spin_unlock+0xd8>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01067a8:	83 ec 08             	sub    $0x8,%esp
f01067ab:	57                   	push   %edi
f01067ac:	50                   	push   %eax
f01067ad:	e8 d4 ea ff ff       	call   f0105286 <debuginfo_eip>
f01067b2:	83 c4 10             	add    $0x10,%esp
f01067b5:	85 c0                	test   %eax,%eax
f01067b7:	78 cb                	js     f0106784 <spin_unlock+0x7c>
					pcs[i] - info.eip_fn_addr);
f01067b9:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01067bb:	83 ec 04             	sub    $0x4,%esp
f01067be:	89 c2                	mov    %eax,%edx
f01067c0:	2b 55 b8             	sub    -0x48(%ebp),%edx
f01067c3:	52                   	push   %edx
f01067c4:	ff 75 b0             	pushl  -0x50(%ebp)
f01067c7:	ff 75 b4             	pushl  -0x4c(%ebp)
f01067ca:	ff 75 ac             	pushl  -0x54(%ebp)
f01067cd:	ff 75 a8             	pushl  -0x58(%ebp)
f01067d0:	50                   	push   %eax
f01067d1:	68 16 88 10 f0       	push   $0xf0108816
f01067d6:	e8 63 d3 ff ff       	call   f0103b3e <cprintf>
f01067db:	83 c4 20             	add    $0x20,%esp
f01067de:	eb b6                	jmp    f0106796 <spin_unlock+0x8e>
		panic("spin_unlock");
f01067e0:	83 ec 04             	sub    $0x4,%esp
f01067e3:	68 35 88 10 f0       	push   $0xf0108835
f01067e8:	6a 67                	push   $0x67
f01067ea:	68 06 88 10 f0       	push   $0xf0108806
f01067ef:	e8 4c 98 ff ff       	call   f0100040 <_panic>
f01067f4:	66 90                	xchg   %ax,%ax
f01067f6:	66 90                	xchg   %ax,%ax
f01067f8:	66 90                	xchg   %ax,%ax
f01067fa:	66 90                	xchg   %ax,%ax
f01067fc:	66 90                	xchg   %ax,%ax
f01067fe:	66 90                	xchg   %ax,%ax

f0106800 <__udivdi3>:
f0106800:	f3 0f 1e fb          	endbr32 
f0106804:	55                   	push   %ebp
f0106805:	57                   	push   %edi
f0106806:	56                   	push   %esi
f0106807:	53                   	push   %ebx
f0106808:	83 ec 1c             	sub    $0x1c,%esp
f010680b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010680f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0106813:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106817:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f010681b:	85 d2                	test   %edx,%edx
f010681d:	75 19                	jne    f0106838 <__udivdi3+0x38>
f010681f:	39 f3                	cmp    %esi,%ebx
f0106821:	76 4d                	jbe    f0106870 <__udivdi3+0x70>
f0106823:	31 ff                	xor    %edi,%edi
f0106825:	89 e8                	mov    %ebp,%eax
f0106827:	89 f2                	mov    %esi,%edx
f0106829:	f7 f3                	div    %ebx
f010682b:	89 fa                	mov    %edi,%edx
f010682d:	83 c4 1c             	add    $0x1c,%esp
f0106830:	5b                   	pop    %ebx
f0106831:	5e                   	pop    %esi
f0106832:	5f                   	pop    %edi
f0106833:	5d                   	pop    %ebp
f0106834:	c3                   	ret    
f0106835:	8d 76 00             	lea    0x0(%esi),%esi
f0106838:	39 f2                	cmp    %esi,%edx
f010683a:	76 14                	jbe    f0106850 <__udivdi3+0x50>
f010683c:	31 ff                	xor    %edi,%edi
f010683e:	31 c0                	xor    %eax,%eax
f0106840:	89 fa                	mov    %edi,%edx
f0106842:	83 c4 1c             	add    $0x1c,%esp
f0106845:	5b                   	pop    %ebx
f0106846:	5e                   	pop    %esi
f0106847:	5f                   	pop    %edi
f0106848:	5d                   	pop    %ebp
f0106849:	c3                   	ret    
f010684a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106850:	0f bd fa             	bsr    %edx,%edi
f0106853:	83 f7 1f             	xor    $0x1f,%edi
f0106856:	75 48                	jne    f01068a0 <__udivdi3+0xa0>
f0106858:	39 f2                	cmp    %esi,%edx
f010685a:	72 06                	jb     f0106862 <__udivdi3+0x62>
f010685c:	31 c0                	xor    %eax,%eax
f010685e:	39 eb                	cmp    %ebp,%ebx
f0106860:	77 de                	ja     f0106840 <__udivdi3+0x40>
f0106862:	b8 01 00 00 00       	mov    $0x1,%eax
f0106867:	eb d7                	jmp    f0106840 <__udivdi3+0x40>
f0106869:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106870:	89 d9                	mov    %ebx,%ecx
f0106872:	85 db                	test   %ebx,%ebx
f0106874:	75 0b                	jne    f0106881 <__udivdi3+0x81>
f0106876:	b8 01 00 00 00       	mov    $0x1,%eax
f010687b:	31 d2                	xor    %edx,%edx
f010687d:	f7 f3                	div    %ebx
f010687f:	89 c1                	mov    %eax,%ecx
f0106881:	31 d2                	xor    %edx,%edx
f0106883:	89 f0                	mov    %esi,%eax
f0106885:	f7 f1                	div    %ecx
f0106887:	89 c6                	mov    %eax,%esi
f0106889:	89 e8                	mov    %ebp,%eax
f010688b:	89 f7                	mov    %esi,%edi
f010688d:	f7 f1                	div    %ecx
f010688f:	89 fa                	mov    %edi,%edx
f0106891:	83 c4 1c             	add    $0x1c,%esp
f0106894:	5b                   	pop    %ebx
f0106895:	5e                   	pop    %esi
f0106896:	5f                   	pop    %edi
f0106897:	5d                   	pop    %ebp
f0106898:	c3                   	ret    
f0106899:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01068a0:	89 f9                	mov    %edi,%ecx
f01068a2:	b8 20 00 00 00       	mov    $0x20,%eax
f01068a7:	29 f8                	sub    %edi,%eax
f01068a9:	d3 e2                	shl    %cl,%edx
f01068ab:	89 54 24 08          	mov    %edx,0x8(%esp)
f01068af:	89 c1                	mov    %eax,%ecx
f01068b1:	89 da                	mov    %ebx,%edx
f01068b3:	d3 ea                	shr    %cl,%edx
f01068b5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01068b9:	09 d1                	or     %edx,%ecx
f01068bb:	89 f2                	mov    %esi,%edx
f01068bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01068c1:	89 f9                	mov    %edi,%ecx
f01068c3:	d3 e3                	shl    %cl,%ebx
f01068c5:	89 c1                	mov    %eax,%ecx
f01068c7:	d3 ea                	shr    %cl,%edx
f01068c9:	89 f9                	mov    %edi,%ecx
f01068cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01068cf:	89 eb                	mov    %ebp,%ebx
f01068d1:	d3 e6                	shl    %cl,%esi
f01068d3:	89 c1                	mov    %eax,%ecx
f01068d5:	d3 eb                	shr    %cl,%ebx
f01068d7:	09 de                	or     %ebx,%esi
f01068d9:	89 f0                	mov    %esi,%eax
f01068db:	f7 74 24 08          	divl   0x8(%esp)
f01068df:	89 d6                	mov    %edx,%esi
f01068e1:	89 c3                	mov    %eax,%ebx
f01068e3:	f7 64 24 0c          	mull   0xc(%esp)
f01068e7:	39 d6                	cmp    %edx,%esi
f01068e9:	72 15                	jb     f0106900 <__udivdi3+0x100>
f01068eb:	89 f9                	mov    %edi,%ecx
f01068ed:	d3 e5                	shl    %cl,%ebp
f01068ef:	39 c5                	cmp    %eax,%ebp
f01068f1:	73 04                	jae    f01068f7 <__udivdi3+0xf7>
f01068f3:	39 d6                	cmp    %edx,%esi
f01068f5:	74 09                	je     f0106900 <__udivdi3+0x100>
f01068f7:	89 d8                	mov    %ebx,%eax
f01068f9:	31 ff                	xor    %edi,%edi
f01068fb:	e9 40 ff ff ff       	jmp    f0106840 <__udivdi3+0x40>
f0106900:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0106903:	31 ff                	xor    %edi,%edi
f0106905:	e9 36 ff ff ff       	jmp    f0106840 <__udivdi3+0x40>
f010690a:	66 90                	xchg   %ax,%ax
f010690c:	66 90                	xchg   %ax,%ax
f010690e:	66 90                	xchg   %ax,%ax

f0106910 <__umoddi3>:
f0106910:	f3 0f 1e fb          	endbr32 
f0106914:	55                   	push   %ebp
f0106915:	57                   	push   %edi
f0106916:	56                   	push   %esi
f0106917:	53                   	push   %ebx
f0106918:	83 ec 1c             	sub    $0x1c,%esp
f010691b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010691f:	8b 74 24 30          	mov    0x30(%esp),%esi
f0106923:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0106927:	8b 7c 24 38          	mov    0x38(%esp),%edi
f010692b:	85 c0                	test   %eax,%eax
f010692d:	75 19                	jne    f0106948 <__umoddi3+0x38>
f010692f:	39 df                	cmp    %ebx,%edi
f0106931:	76 5d                	jbe    f0106990 <__umoddi3+0x80>
f0106933:	89 f0                	mov    %esi,%eax
f0106935:	89 da                	mov    %ebx,%edx
f0106937:	f7 f7                	div    %edi
f0106939:	89 d0                	mov    %edx,%eax
f010693b:	31 d2                	xor    %edx,%edx
f010693d:	83 c4 1c             	add    $0x1c,%esp
f0106940:	5b                   	pop    %ebx
f0106941:	5e                   	pop    %esi
f0106942:	5f                   	pop    %edi
f0106943:	5d                   	pop    %ebp
f0106944:	c3                   	ret    
f0106945:	8d 76 00             	lea    0x0(%esi),%esi
f0106948:	89 f2                	mov    %esi,%edx
f010694a:	39 d8                	cmp    %ebx,%eax
f010694c:	76 12                	jbe    f0106960 <__umoddi3+0x50>
f010694e:	89 f0                	mov    %esi,%eax
f0106950:	89 da                	mov    %ebx,%edx
f0106952:	83 c4 1c             	add    $0x1c,%esp
f0106955:	5b                   	pop    %ebx
f0106956:	5e                   	pop    %esi
f0106957:	5f                   	pop    %edi
f0106958:	5d                   	pop    %ebp
f0106959:	c3                   	ret    
f010695a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106960:	0f bd e8             	bsr    %eax,%ebp
f0106963:	83 f5 1f             	xor    $0x1f,%ebp
f0106966:	75 50                	jne    f01069b8 <__umoddi3+0xa8>
f0106968:	39 d8                	cmp    %ebx,%eax
f010696a:	0f 82 e0 00 00 00    	jb     f0106a50 <__umoddi3+0x140>
f0106970:	89 d9                	mov    %ebx,%ecx
f0106972:	39 f7                	cmp    %esi,%edi
f0106974:	0f 86 d6 00 00 00    	jbe    f0106a50 <__umoddi3+0x140>
f010697a:	89 d0                	mov    %edx,%eax
f010697c:	89 ca                	mov    %ecx,%edx
f010697e:	83 c4 1c             	add    $0x1c,%esp
f0106981:	5b                   	pop    %ebx
f0106982:	5e                   	pop    %esi
f0106983:	5f                   	pop    %edi
f0106984:	5d                   	pop    %ebp
f0106985:	c3                   	ret    
f0106986:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f010698d:	8d 76 00             	lea    0x0(%esi),%esi
f0106990:	89 fd                	mov    %edi,%ebp
f0106992:	85 ff                	test   %edi,%edi
f0106994:	75 0b                	jne    f01069a1 <__umoddi3+0x91>
f0106996:	b8 01 00 00 00       	mov    $0x1,%eax
f010699b:	31 d2                	xor    %edx,%edx
f010699d:	f7 f7                	div    %edi
f010699f:	89 c5                	mov    %eax,%ebp
f01069a1:	89 d8                	mov    %ebx,%eax
f01069a3:	31 d2                	xor    %edx,%edx
f01069a5:	f7 f5                	div    %ebp
f01069a7:	89 f0                	mov    %esi,%eax
f01069a9:	f7 f5                	div    %ebp
f01069ab:	89 d0                	mov    %edx,%eax
f01069ad:	31 d2                	xor    %edx,%edx
f01069af:	eb 8c                	jmp    f010693d <__umoddi3+0x2d>
f01069b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01069b8:	89 e9                	mov    %ebp,%ecx
f01069ba:	ba 20 00 00 00       	mov    $0x20,%edx
f01069bf:	29 ea                	sub    %ebp,%edx
f01069c1:	d3 e0                	shl    %cl,%eax
f01069c3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01069c7:	89 d1                	mov    %edx,%ecx
f01069c9:	89 f8                	mov    %edi,%eax
f01069cb:	d3 e8                	shr    %cl,%eax
f01069cd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01069d1:	89 54 24 04          	mov    %edx,0x4(%esp)
f01069d5:	8b 54 24 04          	mov    0x4(%esp),%edx
f01069d9:	09 c1                	or     %eax,%ecx
f01069db:	89 d8                	mov    %ebx,%eax
f01069dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01069e1:	89 e9                	mov    %ebp,%ecx
f01069e3:	d3 e7                	shl    %cl,%edi
f01069e5:	89 d1                	mov    %edx,%ecx
f01069e7:	d3 e8                	shr    %cl,%eax
f01069e9:	89 e9                	mov    %ebp,%ecx
f01069eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01069ef:	d3 e3                	shl    %cl,%ebx
f01069f1:	89 c7                	mov    %eax,%edi
f01069f3:	89 d1                	mov    %edx,%ecx
f01069f5:	89 f0                	mov    %esi,%eax
f01069f7:	d3 e8                	shr    %cl,%eax
f01069f9:	89 e9                	mov    %ebp,%ecx
f01069fb:	89 fa                	mov    %edi,%edx
f01069fd:	d3 e6                	shl    %cl,%esi
f01069ff:	09 d8                	or     %ebx,%eax
f0106a01:	f7 74 24 08          	divl   0x8(%esp)
f0106a05:	89 d1                	mov    %edx,%ecx
f0106a07:	89 f3                	mov    %esi,%ebx
f0106a09:	f7 64 24 0c          	mull   0xc(%esp)
f0106a0d:	89 c6                	mov    %eax,%esi
f0106a0f:	89 d7                	mov    %edx,%edi
f0106a11:	39 d1                	cmp    %edx,%ecx
f0106a13:	72 06                	jb     f0106a1b <__umoddi3+0x10b>
f0106a15:	75 10                	jne    f0106a27 <__umoddi3+0x117>
f0106a17:	39 c3                	cmp    %eax,%ebx
f0106a19:	73 0c                	jae    f0106a27 <__umoddi3+0x117>
f0106a1b:	2b 44 24 0c          	sub    0xc(%esp),%eax
f0106a1f:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0106a23:	89 d7                	mov    %edx,%edi
f0106a25:	89 c6                	mov    %eax,%esi
f0106a27:	89 ca                	mov    %ecx,%edx
f0106a29:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106a2e:	29 f3                	sub    %esi,%ebx
f0106a30:	19 fa                	sbb    %edi,%edx
f0106a32:	89 d0                	mov    %edx,%eax
f0106a34:	d3 e0                	shl    %cl,%eax
f0106a36:	89 e9                	mov    %ebp,%ecx
f0106a38:	d3 eb                	shr    %cl,%ebx
f0106a3a:	d3 ea                	shr    %cl,%edx
f0106a3c:	09 d8                	or     %ebx,%eax
f0106a3e:	83 c4 1c             	add    $0x1c,%esp
f0106a41:	5b                   	pop    %ebx
f0106a42:	5e                   	pop    %esi
f0106a43:	5f                   	pop    %edi
f0106a44:	5d                   	pop    %ebp
f0106a45:	c3                   	ret    
f0106a46:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106a4d:	8d 76 00             	lea    0x0(%esi),%esi
f0106a50:	29 fe                	sub    %edi,%esi
f0106a52:	19 c3                	sbb    %eax,%ebx
f0106a54:	89 f2                	mov    %esi,%edx
f0106a56:	89 d9                	mov    %ebx,%ecx
f0106a58:	e9 1d ff ff ff       	jmp    f010697a <__umoddi3+0x6a>
