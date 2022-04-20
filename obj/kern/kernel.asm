
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
f010004c:	83 3d 80 7e 23 f0 00 	cmpl   $0x0,0xf0237e80
f0100053:	74 0f                	je     f0100064 <_panic+0x24>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100055:	83 ec 0c             	sub    $0xc,%esp
f0100058:	6a 00                	push   $0x0
f010005a:	e8 48 09 00 00       	call   f01009a7 <monitor>
f010005f:	83 c4 10             	add    $0x10,%esp
f0100062:	eb f1                	jmp    f0100055 <_panic+0x15>
	panicstr = fmt;
f0100064:	89 35 80 7e 23 f0    	mov    %esi,0xf0237e80
	asm volatile("cli; cld");
f010006a:	fa                   	cli    
f010006b:	fc                   	cld    
	va_start(ap, fmt);
f010006c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010006f:	e8 d6 62 00 00       	call   f010634a <cpunum>
f0100074:	ff 75 0c             	pushl  0xc(%ebp)
f0100077:	ff 75 08             	pushl  0x8(%ebp)
f010007a:	50                   	push   %eax
f010007b:	68 c0 69 10 f0       	push   $0xf01069c0
f0100080:	e8 73 3a 00 00       	call   f0103af8 <cprintf>
	vcprintf(fmt, ap);
f0100085:	83 c4 08             	add    $0x8,%esp
f0100088:	53                   	push   %ebx
f0100089:	56                   	push   %esi
f010008a:	e8 3f 3a 00 00       	call   f0103ace <vcprintf>
	cprintf("\n");
f010008f:	c7 04 24 a0 7b 10 f0 	movl   $0xf0107ba0,(%esp)
f0100096:	e8 5d 3a 00 00       	call   f0103af8 <cprintf>
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
f01000ab:	e8 95 05 00 00       	call   f0100645 <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b0:	83 ec 08             	sub    $0x8,%esp
f01000b3:	68 ac 1a 00 00       	push   $0x1aac
f01000b8:	68 2c 6a 10 f0       	push   $0xf0106a2c
f01000bd:	e8 36 3a 00 00       	call   f0103af8 <cprintf>
	mem_init();
f01000c2:	e8 a5 12 00 00       	call   f010136c <mem_init>
	env_init();
f01000c7:	e8 c5 31 00 00       	call   f0103291 <env_init>
	trap_init();
f01000cc:	e8 21 3b 00 00       	call   f0103bf2 <trap_init>
	mp_init();
f01000d1:	e8 75 5f 00 00       	call   f010604b <mp_init>
	lapic_init();
f01000d6:	e8 89 62 00 00       	call   f0106364 <lapic_init>
	pic_init();
f01000db:	e8 2d 39 00 00       	call   f0103a0d <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000e0:	c7 04 24 c0 33 12 f0 	movl   $0xf01233c0,(%esp)
f01000e7:	e8 e6 64 00 00       	call   f01065d2 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000ec:	83 c4 10             	add    $0x10,%esp
f01000ef:	83 3d 88 7e 23 f0 07 	cmpl   $0x7,0xf0237e88
f01000f6:	76 27                	jbe    f010011f <i386_init+0x7f>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01000f8:	83 ec 04             	sub    $0x4,%esp
f01000fb:	b8 ae 5f 10 f0       	mov    $0xf0105fae,%eax
f0100100:	2d 34 5f 10 f0       	sub    $0xf0105f34,%eax
f0100105:	50                   	push   %eax
f0100106:	68 34 5f 10 f0       	push   $0xf0105f34
f010010b:	68 00 70 00 f0       	push   $0xf0007000
f0100110:	e8 63 5c 00 00       	call   f0105d78 <memmove>
	for (c = cpus; c < cpus + ncpu; c++) {
f0100115:	83 c4 10             	add    $0x10,%esp
f0100118:	bb 20 80 23 f0       	mov    $0xf0238020,%ebx
f010011d:	eb 53                	jmp    f0100172 <i386_init+0xd2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010011f:	68 00 70 00 00       	push   $0x7000
f0100124:	68 e4 69 10 f0       	push   $0xf01069e4
f0100129:	6a 4d                	push   $0x4d
f010012b:	68 47 6a 10 f0       	push   $0xf0106a47
f0100130:	e8 0b ff ff ff       	call   f0100040 <_panic>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100135:	89 d8                	mov    %ebx,%eax
f0100137:	2d 20 80 23 f0       	sub    $0xf0238020,%eax
f010013c:	c1 f8 02             	sar    $0x2,%eax
f010013f:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100145:	c1 e0 0f             	shl    $0xf,%eax
f0100148:	8d 80 00 10 24 f0    	lea    -0xfdbf000(%eax),%eax
f010014e:	a3 84 7e 23 f0       	mov    %eax,0xf0237e84
		lapic_startap(c->cpu_id, PADDR(code));
f0100153:	83 ec 08             	sub    $0x8,%esp
f0100156:	68 00 70 00 00       	push   $0x7000
f010015b:	0f b6 03             	movzbl (%ebx),%eax
f010015e:	50                   	push   %eax
f010015f:	e8 5a 63 00 00       	call   f01064be <lapic_startap>
		while(c->cpu_status != CPU_STARTED)
f0100164:	83 c4 10             	add    $0x10,%esp
f0100167:	8b 43 04             	mov    0x4(%ebx),%eax
f010016a:	83 f8 01             	cmp    $0x1,%eax
f010016d:	75 f8                	jne    f0100167 <i386_init+0xc7>
	for (c = cpus; c < cpus + ncpu; c++) {
f010016f:	83 c3 74             	add    $0x74,%ebx
f0100172:	6b 05 c4 83 23 f0 74 	imul   $0x74,0xf02383c4,%eax
f0100179:	05 20 80 23 f0       	add    $0xf0238020,%eax
f010017e:	39 c3                	cmp    %eax,%ebx
f0100180:	73 13                	jae    f0100195 <i386_init+0xf5>
		if (c == cpus + cpunum())  // We've started already.
f0100182:	e8 c3 61 00 00       	call   f010634a <cpunum>
f0100187:	6b c0 74             	imul   $0x74,%eax,%eax
f010018a:	05 20 80 23 f0       	add    $0xf0238020,%eax
f010018f:	39 c3                	cmp    %eax,%ebx
f0100191:	74 dc                	je     f010016f <i386_init+0xcf>
f0100193:	eb a0                	jmp    f0100135 <i386_init+0x95>
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100195:	83 ec 08             	sub    $0x8,%esp
f0100198:	6a 00                	push   $0x0
f010019a:	68 fc cb 22 f0       	push   $0xf022cbfc
f010019f:	e8 e6 32 00 00       	call   f010348a <env_create>
	sched_yield();
f01001a4:	e8 0d 48 00 00       	call   f01049b6 <sched_yield>

f01001a9 <mp_main>:
{
f01001a9:	f3 0f 1e fb          	endbr32 
f01001ad:	55                   	push   %ebp
f01001ae:	89 e5                	mov    %esp,%ebp
f01001b0:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f01001b3:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01001b8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001bd:	76 52                	jbe    f0100211 <mp_main+0x68>
	return (physaddr_t)kva - KERNBASE;
f01001bf:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001c4:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001c7:	e8 7e 61 00 00       	call   f010634a <cpunum>
f01001cc:	83 ec 08             	sub    $0x8,%esp
f01001cf:	50                   	push   %eax
f01001d0:	68 53 6a 10 f0       	push   $0xf0106a53
f01001d5:	e8 1e 39 00 00       	call   f0103af8 <cprintf>
	lapic_init();
f01001da:	e8 85 61 00 00       	call   f0106364 <lapic_init>
	env_init_percpu();
f01001df:	e8 7d 30 00 00       	call   f0103261 <env_init_percpu>
	trap_init_percpu();
f01001e4:	e8 27 39 00 00       	call   f0103b10 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01001e9:	e8 5c 61 00 00       	call   f010634a <cpunum>
f01001ee:	6b d0 74             	imul   $0x74,%eax,%edx
f01001f1:	83 c2 04             	add    $0x4,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01001f4:	b8 01 00 00 00       	mov    $0x1,%eax
f01001f9:	f0 87 82 20 80 23 f0 	lock xchg %eax,-0xfdc7fe0(%edx)
f0100200:	c7 04 24 c0 33 12 f0 	movl   $0xf01233c0,(%esp)
f0100207:	e8 c6 63 00 00       	call   f01065d2 <spin_lock>
    sched_yield();
f010020c:	e8 a5 47 00 00       	call   f01049b6 <sched_yield>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100211:	50                   	push   %eax
f0100212:	68 08 6a 10 f0       	push   $0xf0106a08
f0100217:	6a 64                	push   $0x64
f0100219:	68 47 6a 10 f0       	push   $0xf0106a47
f010021e:	e8 1d fe ff ff       	call   f0100040 <_panic>

f0100223 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100223:	f3 0f 1e fb          	endbr32 
f0100227:	55                   	push   %ebp
f0100228:	89 e5                	mov    %esp,%ebp
f010022a:	53                   	push   %ebx
f010022b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010022e:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100231:	ff 75 0c             	pushl  0xc(%ebp)
f0100234:	ff 75 08             	pushl  0x8(%ebp)
f0100237:	68 69 6a 10 f0       	push   $0xf0106a69
f010023c:	e8 b7 38 00 00       	call   f0103af8 <cprintf>
	vcprintf(fmt, ap);
f0100241:	83 c4 08             	add    $0x8,%esp
f0100244:	53                   	push   %ebx
f0100245:	ff 75 10             	pushl  0x10(%ebp)
f0100248:	e8 81 38 00 00       	call   f0103ace <vcprintf>
	cprintf("\n");
f010024d:	c7 04 24 a0 7b 10 f0 	movl   $0xf0107ba0,(%esp)
f0100254:	e8 9f 38 00 00       	call   f0103af8 <cprintf>
	va_end(ap);
}
f0100259:	83 c4 10             	add    $0x10,%esp
f010025c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010025f:	c9                   	leave  
f0100260:	c3                   	ret    

f0100261 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100261:	f3 0f 1e fb          	endbr32 
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100265:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010026a:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010026b:	a8 01                	test   $0x1,%al
f010026d:	74 0a                	je     f0100279 <serial_proc_data+0x18>
f010026f:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100274:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100275:	0f b6 c0             	movzbl %al,%eax
f0100278:	c3                   	ret    
		return -1;
f0100279:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f010027e:	c3                   	ret    

f010027f <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010027f:	55                   	push   %ebp
f0100280:	89 e5                	mov    %esp,%ebp
f0100282:	53                   	push   %ebx
f0100283:	83 ec 04             	sub    $0x4,%esp
f0100286:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100288:	ff d3                	call   *%ebx
f010028a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010028d:	74 29                	je     f01002b8 <cons_intr+0x39>
		if (c == 0)
f010028f:	85 c0                	test   %eax,%eax
f0100291:	74 f5                	je     f0100288 <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f0100293:	8b 0d 24 72 23 f0    	mov    0xf0237224,%ecx
f0100299:	8d 51 01             	lea    0x1(%ecx),%edx
f010029c:	88 81 20 70 23 f0    	mov    %al,-0xfdc8fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002a2:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f01002a8:	b8 00 00 00 00       	mov    $0x0,%eax
f01002ad:	0f 44 d0             	cmove  %eax,%edx
f01002b0:	89 15 24 72 23 f0    	mov    %edx,0xf0237224
f01002b6:	eb d0                	jmp    f0100288 <cons_intr+0x9>
	}
}
f01002b8:	83 c4 04             	add    $0x4,%esp
f01002bb:	5b                   	pop    %ebx
f01002bc:	5d                   	pop    %ebp
f01002bd:	c3                   	ret    

f01002be <kbd_proc_data>:
{
f01002be:	f3 0f 1e fb          	endbr32 
f01002c2:	55                   	push   %ebp
f01002c3:	89 e5                	mov    %esp,%ebp
f01002c5:	53                   	push   %ebx
f01002c6:	83 ec 04             	sub    $0x4,%esp
f01002c9:	ba 64 00 00 00       	mov    $0x64,%edx
f01002ce:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01002cf:	a8 01                	test   $0x1,%al
f01002d1:	0f 84 f2 00 00 00    	je     f01003c9 <kbd_proc_data+0x10b>
	if (stat & KBS_TERR)
f01002d7:	a8 20                	test   $0x20,%al
f01002d9:	0f 85 f1 00 00 00    	jne    f01003d0 <kbd_proc_data+0x112>
f01002df:	ba 60 00 00 00       	mov    $0x60,%edx
f01002e4:	ec                   	in     (%dx),%al
f01002e5:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f01002e7:	3c e0                	cmp    $0xe0,%al
f01002e9:	74 61                	je     f010034c <kbd_proc_data+0x8e>
	} else if (data & 0x80) {
f01002eb:	84 c0                	test   %al,%al
f01002ed:	78 70                	js     f010035f <kbd_proc_data+0xa1>
	} else if (shift & E0ESC) {
f01002ef:	8b 0d 00 70 23 f0    	mov    0xf0237000,%ecx
f01002f5:	f6 c1 40             	test   $0x40,%cl
f01002f8:	74 0e                	je     f0100308 <kbd_proc_data+0x4a>
		data |= 0x80;
f01002fa:	83 c8 80             	or     $0xffffff80,%eax
f01002fd:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01002ff:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100302:	89 0d 00 70 23 f0    	mov    %ecx,0xf0237000
	shift |= shiftcode[data];
f0100308:	0f b6 d2             	movzbl %dl,%edx
f010030b:	0f b6 82 e0 6b 10 f0 	movzbl -0xfef9420(%edx),%eax
f0100312:	0b 05 00 70 23 f0    	or     0xf0237000,%eax
	shift ^= togglecode[data];
f0100318:	0f b6 8a e0 6a 10 f0 	movzbl -0xfef9520(%edx),%ecx
f010031f:	31 c8                	xor    %ecx,%eax
f0100321:	a3 00 70 23 f0       	mov    %eax,0xf0237000
	c = charcode[shift & (CTL | SHIFT)][data];
f0100326:	89 c1                	mov    %eax,%ecx
f0100328:	83 e1 03             	and    $0x3,%ecx
f010032b:	8b 0c 8d c0 6a 10 f0 	mov    -0xfef9540(,%ecx,4),%ecx
f0100332:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100336:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100339:	a8 08                	test   $0x8,%al
f010033b:	74 61                	je     f010039e <kbd_proc_data+0xe0>
		if ('a' <= c && c <= 'z')
f010033d:	89 da                	mov    %ebx,%edx
f010033f:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100342:	83 f9 19             	cmp    $0x19,%ecx
f0100345:	77 4b                	ja     f0100392 <kbd_proc_data+0xd4>
			c += 'A' - 'a';
f0100347:	83 eb 20             	sub    $0x20,%ebx
f010034a:	eb 0c                	jmp    f0100358 <kbd_proc_data+0x9a>
		shift |= E0ESC;
f010034c:	83 0d 00 70 23 f0 40 	orl    $0x40,0xf0237000
		return 0;
f0100353:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0100358:	89 d8                	mov    %ebx,%eax
f010035a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010035d:	c9                   	leave  
f010035e:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f010035f:	8b 0d 00 70 23 f0    	mov    0xf0237000,%ecx
f0100365:	89 cb                	mov    %ecx,%ebx
f0100367:	83 e3 40             	and    $0x40,%ebx
f010036a:	83 e0 7f             	and    $0x7f,%eax
f010036d:	85 db                	test   %ebx,%ebx
f010036f:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100372:	0f b6 d2             	movzbl %dl,%edx
f0100375:	0f b6 82 e0 6b 10 f0 	movzbl -0xfef9420(%edx),%eax
f010037c:	83 c8 40             	or     $0x40,%eax
f010037f:	0f b6 c0             	movzbl %al,%eax
f0100382:	f7 d0                	not    %eax
f0100384:	21 c8                	and    %ecx,%eax
f0100386:	a3 00 70 23 f0       	mov    %eax,0xf0237000
		return 0;
f010038b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100390:	eb c6                	jmp    f0100358 <kbd_proc_data+0x9a>
		else if ('A' <= c && c <= 'Z')
f0100392:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100395:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100398:	83 fa 1a             	cmp    $0x1a,%edx
f010039b:	0f 42 d9             	cmovb  %ecx,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010039e:	f7 d0                	not    %eax
f01003a0:	a8 06                	test   $0x6,%al
f01003a2:	75 b4                	jne    f0100358 <kbd_proc_data+0x9a>
f01003a4:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003aa:	75 ac                	jne    f0100358 <kbd_proc_data+0x9a>
		cprintf("Rebooting!\n");
f01003ac:	83 ec 0c             	sub    $0xc,%esp
f01003af:	68 83 6a 10 f0       	push   $0xf0106a83
f01003b4:	e8 3f 37 00 00       	call   f0103af8 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003b9:	b8 03 00 00 00       	mov    $0x3,%eax
f01003be:	ba 92 00 00 00       	mov    $0x92,%edx
f01003c3:	ee                   	out    %al,(%dx)
}
f01003c4:	83 c4 10             	add    $0x10,%esp
f01003c7:	eb 8f                	jmp    f0100358 <kbd_proc_data+0x9a>
		return -1;
f01003c9:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003ce:	eb 88                	jmp    f0100358 <kbd_proc_data+0x9a>
		return -1;
f01003d0:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003d5:	eb 81                	jmp    f0100358 <kbd_proc_data+0x9a>

f01003d7 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003d7:	55                   	push   %ebp
f01003d8:	89 e5                	mov    %esp,%ebp
f01003da:	57                   	push   %edi
f01003db:	56                   	push   %esi
f01003dc:	53                   	push   %ebx
f01003dd:	83 ec 1c             	sub    $0x1c,%esp
f01003e0:	89 c1                	mov    %eax,%ecx
	for (i = 0;
f01003e2:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003e7:	bf fd 03 00 00       	mov    $0x3fd,%edi
f01003ec:	bb 84 00 00 00       	mov    $0x84,%ebx
f01003f1:	89 fa                	mov    %edi,%edx
f01003f3:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003f4:	a8 20                	test   $0x20,%al
f01003f6:	75 13                	jne    f010040b <cons_putc+0x34>
f01003f8:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003fe:	7f 0b                	jg     f010040b <cons_putc+0x34>
f0100400:	89 da                	mov    %ebx,%edx
f0100402:	ec                   	in     (%dx),%al
f0100403:	ec                   	in     (%dx),%al
f0100404:	ec                   	in     (%dx),%al
f0100405:	ec                   	in     (%dx),%al
	     i++)
f0100406:	83 c6 01             	add    $0x1,%esi
f0100409:	eb e6                	jmp    f01003f1 <cons_putc+0x1a>
	outb(COM1 + COM_TX, c);
f010040b:	88 4d e7             	mov    %cl,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010040e:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100413:	89 c8                	mov    %ecx,%eax
f0100415:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100416:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010041b:	bf 79 03 00 00       	mov    $0x379,%edi
f0100420:	bb 84 00 00 00       	mov    $0x84,%ebx
f0100425:	89 fa                	mov    %edi,%edx
f0100427:	ec                   	in     (%dx),%al
f0100428:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010042e:	7f 0f                	jg     f010043f <cons_putc+0x68>
f0100430:	84 c0                	test   %al,%al
f0100432:	78 0b                	js     f010043f <cons_putc+0x68>
f0100434:	89 da                	mov    %ebx,%edx
f0100436:	ec                   	in     (%dx),%al
f0100437:	ec                   	in     (%dx),%al
f0100438:	ec                   	in     (%dx),%al
f0100439:	ec                   	in     (%dx),%al
f010043a:	83 c6 01             	add    $0x1,%esi
f010043d:	eb e6                	jmp    f0100425 <cons_putc+0x4e>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010043f:	ba 78 03 00 00       	mov    $0x378,%edx
f0100444:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100448:	ee                   	out    %al,(%dx)
f0100449:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010044e:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100453:	ee                   	out    %al,(%dx)
f0100454:	b8 08 00 00 00       	mov    $0x8,%eax
f0100459:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f010045a:	89 c8                	mov    %ecx,%eax
f010045c:	80 cc 07             	or     $0x7,%ah
f010045f:	f7 c1 00 ff ff ff    	test   $0xffffff00,%ecx
f0100465:	0f 44 c8             	cmove  %eax,%ecx
	switch (c & 0xff) {
f0100468:	0f b6 c1             	movzbl %cl,%eax
f010046b:	80 f9 0a             	cmp    $0xa,%cl
f010046e:	0f 84 dd 00 00 00    	je     f0100551 <cons_putc+0x17a>
f0100474:	83 f8 0a             	cmp    $0xa,%eax
f0100477:	7f 46                	jg     f01004bf <cons_putc+0xe8>
f0100479:	83 f8 08             	cmp    $0x8,%eax
f010047c:	0f 84 a7 00 00 00    	je     f0100529 <cons_putc+0x152>
f0100482:	83 f8 09             	cmp    $0x9,%eax
f0100485:	0f 85 d3 00 00 00    	jne    f010055e <cons_putc+0x187>
		cons_putc(' ');
f010048b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100490:	e8 42 ff ff ff       	call   f01003d7 <cons_putc>
		cons_putc(' ');
f0100495:	b8 20 00 00 00       	mov    $0x20,%eax
f010049a:	e8 38 ff ff ff       	call   f01003d7 <cons_putc>
		cons_putc(' ');
f010049f:	b8 20 00 00 00       	mov    $0x20,%eax
f01004a4:	e8 2e ff ff ff       	call   f01003d7 <cons_putc>
		cons_putc(' ');
f01004a9:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ae:	e8 24 ff ff ff       	call   f01003d7 <cons_putc>
		cons_putc(' ');
f01004b3:	b8 20 00 00 00       	mov    $0x20,%eax
f01004b8:	e8 1a ff ff ff       	call   f01003d7 <cons_putc>
		break;
f01004bd:	eb 25                	jmp    f01004e4 <cons_putc+0x10d>
	switch (c & 0xff) {
f01004bf:	83 f8 0d             	cmp    $0xd,%eax
f01004c2:	0f 85 96 00 00 00    	jne    f010055e <cons_putc+0x187>
		crt_pos -= (crt_pos % CRT_COLS);
f01004c8:	0f b7 05 28 72 23 f0 	movzwl 0xf0237228,%eax
f01004cf:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004d5:	c1 e8 16             	shr    $0x16,%eax
f01004d8:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004db:	c1 e0 04             	shl    $0x4,%eax
f01004de:	66 a3 28 72 23 f0    	mov    %ax,0xf0237228
	if (crt_pos >= CRT_SIZE) {
f01004e4:	66 81 3d 28 72 23 f0 	cmpw   $0x7cf,0xf0237228
f01004eb:	cf 07 
f01004ed:	0f 87 8e 00 00 00    	ja     f0100581 <cons_putc+0x1aa>
	outb(addr_6845, 14);
f01004f3:	8b 0d 30 72 23 f0    	mov    0xf0237230,%ecx
f01004f9:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004fe:	89 ca                	mov    %ecx,%edx
f0100500:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100501:	0f b7 1d 28 72 23 f0 	movzwl 0xf0237228,%ebx
f0100508:	8d 71 01             	lea    0x1(%ecx),%esi
f010050b:	89 d8                	mov    %ebx,%eax
f010050d:	66 c1 e8 08          	shr    $0x8,%ax
f0100511:	89 f2                	mov    %esi,%edx
f0100513:	ee                   	out    %al,(%dx)
f0100514:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100519:	89 ca                	mov    %ecx,%edx
f010051b:	ee                   	out    %al,(%dx)
f010051c:	89 d8                	mov    %ebx,%eax
f010051e:	89 f2                	mov    %esi,%edx
f0100520:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100521:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100524:	5b                   	pop    %ebx
f0100525:	5e                   	pop    %esi
f0100526:	5f                   	pop    %edi
f0100527:	5d                   	pop    %ebp
f0100528:	c3                   	ret    
		if (crt_pos > 0) {
f0100529:	0f b7 05 28 72 23 f0 	movzwl 0xf0237228,%eax
f0100530:	66 85 c0             	test   %ax,%ax
f0100533:	74 be                	je     f01004f3 <cons_putc+0x11c>
			crt_pos--;
f0100535:	83 e8 01             	sub    $0x1,%eax
f0100538:	66 a3 28 72 23 f0    	mov    %ax,0xf0237228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010053e:	0f b7 d0             	movzwl %ax,%edx
f0100541:	b1 00                	mov    $0x0,%cl
f0100543:	83 c9 20             	or     $0x20,%ecx
f0100546:	a1 2c 72 23 f0       	mov    0xf023722c,%eax
f010054b:	66 89 0c 50          	mov    %cx,(%eax,%edx,2)
f010054f:	eb 93                	jmp    f01004e4 <cons_putc+0x10d>
		crt_pos += CRT_COLS;
f0100551:	66 83 05 28 72 23 f0 	addw   $0x50,0xf0237228
f0100558:	50 
f0100559:	e9 6a ff ff ff       	jmp    f01004c8 <cons_putc+0xf1>
		crt_buf[crt_pos++] = c;		/* write the character */
f010055e:	0f b7 05 28 72 23 f0 	movzwl 0xf0237228,%eax
f0100565:	8d 50 01             	lea    0x1(%eax),%edx
f0100568:	66 89 15 28 72 23 f0 	mov    %dx,0xf0237228
f010056f:	0f b7 c0             	movzwl %ax,%eax
f0100572:	8b 15 2c 72 23 f0    	mov    0xf023722c,%edx
f0100578:	66 89 0c 42          	mov    %cx,(%edx,%eax,2)
		break;
f010057c:	e9 63 ff ff ff       	jmp    f01004e4 <cons_putc+0x10d>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100581:	a1 2c 72 23 f0       	mov    0xf023722c,%eax
f0100586:	83 ec 04             	sub    $0x4,%esp
f0100589:	68 00 0f 00 00       	push   $0xf00
f010058e:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100594:	52                   	push   %edx
f0100595:	50                   	push   %eax
f0100596:	e8 dd 57 00 00       	call   f0105d78 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f010059b:	8b 15 2c 72 23 f0    	mov    0xf023722c,%edx
f01005a1:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01005a7:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01005ad:	83 c4 10             	add    $0x10,%esp
f01005b0:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01005b5:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005b8:	39 d0                	cmp    %edx,%eax
f01005ba:	75 f4                	jne    f01005b0 <cons_putc+0x1d9>
		crt_pos -= CRT_COLS;
f01005bc:	66 83 2d 28 72 23 f0 	subw   $0x50,0xf0237228
f01005c3:	50 
f01005c4:	e9 2a ff ff ff       	jmp    f01004f3 <cons_putc+0x11c>

f01005c9 <serial_intr>:
{
f01005c9:	f3 0f 1e fb          	endbr32 
	if (serial_exists)
f01005cd:	80 3d 34 72 23 f0 00 	cmpb   $0x0,0xf0237234
f01005d4:	75 01                	jne    f01005d7 <serial_intr+0xe>
f01005d6:	c3                   	ret    
{
f01005d7:	55                   	push   %ebp
f01005d8:	89 e5                	mov    %esp,%ebp
f01005da:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01005dd:	b8 61 02 10 f0       	mov    $0xf0100261,%eax
f01005e2:	e8 98 fc ff ff       	call   f010027f <cons_intr>
}
f01005e7:	c9                   	leave  
f01005e8:	c3                   	ret    

f01005e9 <kbd_intr>:
{
f01005e9:	f3 0f 1e fb          	endbr32 
f01005ed:	55                   	push   %ebp
f01005ee:	89 e5                	mov    %esp,%ebp
f01005f0:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005f3:	b8 be 02 10 f0       	mov    $0xf01002be,%eax
f01005f8:	e8 82 fc ff ff       	call   f010027f <cons_intr>
}
f01005fd:	c9                   	leave  
f01005fe:	c3                   	ret    

f01005ff <cons_getc>:
{
f01005ff:	f3 0f 1e fb          	endbr32 
f0100603:	55                   	push   %ebp
f0100604:	89 e5                	mov    %esp,%ebp
f0100606:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f0100609:	e8 bb ff ff ff       	call   f01005c9 <serial_intr>
	kbd_intr();
f010060e:	e8 d6 ff ff ff       	call   f01005e9 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100613:	a1 20 72 23 f0       	mov    0xf0237220,%eax
	return 0;
f0100618:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f010061d:	3b 05 24 72 23 f0    	cmp    0xf0237224,%eax
f0100623:	74 1c                	je     f0100641 <cons_getc+0x42>
		c = cons.buf[cons.rpos++];
f0100625:	8d 48 01             	lea    0x1(%eax),%ecx
f0100628:	0f b6 90 20 70 23 f0 	movzbl -0xfdc8fe0(%eax),%edx
			cons.rpos = 0;
f010062f:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f0100634:	b8 00 00 00 00       	mov    $0x0,%eax
f0100639:	0f 45 c1             	cmovne %ecx,%eax
f010063c:	a3 20 72 23 f0       	mov    %eax,0xf0237220
}
f0100641:	89 d0                	mov    %edx,%eax
f0100643:	c9                   	leave  
f0100644:	c3                   	ret    

f0100645 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100645:	f3 0f 1e fb          	endbr32 
f0100649:	55                   	push   %ebp
f010064a:	89 e5                	mov    %esp,%ebp
f010064c:	57                   	push   %edi
f010064d:	56                   	push   %esi
f010064e:	53                   	push   %ebx
f010064f:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f0100652:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100659:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100660:	5a a5 
	if (*cp != 0xA55A) {
f0100662:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100669:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010066d:	0f 84 d4 00 00 00    	je     f0100747 <cons_init+0x102>
		addr_6845 = MONO_BASE;
f0100673:	c7 05 30 72 23 f0 b4 	movl   $0x3b4,0xf0237230
f010067a:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010067d:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f0100682:	8b 3d 30 72 23 f0    	mov    0xf0237230,%edi
f0100688:	b8 0e 00 00 00       	mov    $0xe,%eax
f010068d:	89 fa                	mov    %edi,%edx
f010068f:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100690:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100693:	89 ca                	mov    %ecx,%edx
f0100695:	ec                   	in     (%dx),%al
f0100696:	0f b6 c0             	movzbl %al,%eax
f0100699:	c1 e0 08             	shl    $0x8,%eax
f010069c:	89 c3                	mov    %eax,%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010069e:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006a3:	89 fa                	mov    %edi,%edx
f01006a5:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006a6:	89 ca                	mov    %ecx,%edx
f01006a8:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f01006a9:	89 35 2c 72 23 f0    	mov    %esi,0xf023722c
	pos |= inb(addr_6845 + 1);
f01006af:	0f b6 c0             	movzbl %al,%eax
f01006b2:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f01006b4:	66 a3 28 72 23 f0    	mov    %ax,0xf0237228
	kbd_intr();
f01006ba:	e8 2a ff ff ff       	call   f01005e9 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006bf:	83 ec 0c             	sub    $0xc,%esp
f01006c2:	0f b7 05 a8 33 12 f0 	movzwl 0xf01233a8,%eax
f01006c9:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006ce:	50                   	push   %eax
f01006cf:	e8 b7 32 00 00       	call   f010398b <irq_setmask_8259A>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006d4:	bb 00 00 00 00       	mov    $0x0,%ebx
f01006d9:	b9 fa 03 00 00       	mov    $0x3fa,%ecx
f01006de:	89 d8                	mov    %ebx,%eax
f01006e0:	89 ca                	mov    %ecx,%edx
f01006e2:	ee                   	out    %al,(%dx)
f01006e3:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006e8:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006ed:	89 fa                	mov    %edi,%edx
f01006ef:	ee                   	out    %al,(%dx)
f01006f0:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006f5:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006fa:	ee                   	out    %al,(%dx)
f01006fb:	be f9 03 00 00       	mov    $0x3f9,%esi
f0100700:	89 d8                	mov    %ebx,%eax
f0100702:	89 f2                	mov    %esi,%edx
f0100704:	ee                   	out    %al,(%dx)
f0100705:	b8 03 00 00 00       	mov    $0x3,%eax
f010070a:	89 fa                	mov    %edi,%edx
f010070c:	ee                   	out    %al,(%dx)
f010070d:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100712:	89 d8                	mov    %ebx,%eax
f0100714:	ee                   	out    %al,(%dx)
f0100715:	b8 01 00 00 00       	mov    $0x1,%eax
f010071a:	89 f2                	mov    %esi,%edx
f010071c:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010071d:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100722:	ec                   	in     (%dx),%al
f0100723:	89 c3                	mov    %eax,%ebx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100725:	83 c4 10             	add    $0x10,%esp
f0100728:	3c ff                	cmp    $0xff,%al
f010072a:	0f 95 05 34 72 23 f0 	setne  0xf0237234
f0100731:	89 ca                	mov    %ecx,%edx
f0100733:	ec                   	in     (%dx),%al
f0100734:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100739:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010073a:	80 fb ff             	cmp    $0xff,%bl
f010073d:	74 23                	je     f0100762 <cons_init+0x11d>
		cprintf("Serial port does not exist!\n");
}
f010073f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100742:	5b                   	pop    %ebx
f0100743:	5e                   	pop    %esi
f0100744:	5f                   	pop    %edi
f0100745:	5d                   	pop    %ebp
f0100746:	c3                   	ret    
		*cp = was;
f0100747:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010074e:	c7 05 30 72 23 f0 d4 	movl   $0x3d4,0xf0237230
f0100755:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100758:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f010075d:	e9 20 ff ff ff       	jmp    f0100682 <cons_init+0x3d>
		cprintf("Serial port does not exist!\n");
f0100762:	83 ec 0c             	sub    $0xc,%esp
f0100765:	68 8f 6a 10 f0       	push   $0xf0106a8f
f010076a:	e8 89 33 00 00       	call   f0103af8 <cprintf>
f010076f:	83 c4 10             	add    $0x10,%esp
}
f0100772:	eb cb                	jmp    f010073f <cons_init+0xfa>

f0100774 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100774:	f3 0f 1e fb          	endbr32 
f0100778:	55                   	push   %ebp
f0100779:	89 e5                	mov    %esp,%ebp
f010077b:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010077e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100781:	e8 51 fc ff ff       	call   f01003d7 <cons_putc>
}
f0100786:	c9                   	leave  
f0100787:	c3                   	ret    

f0100788 <getchar>:

int
getchar(void)
{
f0100788:	f3 0f 1e fb          	endbr32 
f010078c:	55                   	push   %ebp
f010078d:	89 e5                	mov    %esp,%ebp
f010078f:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100792:	e8 68 fe ff ff       	call   f01005ff <cons_getc>
f0100797:	85 c0                	test   %eax,%eax
f0100799:	74 f7                	je     f0100792 <getchar+0xa>
		/* do nothing */;
	return c;
}
f010079b:	c9                   	leave  
f010079c:	c3                   	ret    

f010079d <iscons>:

int
iscons(int fdnum)
{
f010079d:	f3 0f 1e fb          	endbr32 
	// used by readline
	return 1;
}
f01007a1:	b8 01 00 00 00       	mov    $0x1,%eax
f01007a6:	c3                   	ret    

f01007a7 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007a7:	f3 0f 1e fb          	endbr32 
f01007ab:	55                   	push   %ebp
f01007ac:	89 e5                	mov    %esp,%ebp
f01007ae:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007b1:	68 e0 6c 10 f0       	push   $0xf0106ce0
f01007b6:	68 fe 6c 10 f0       	push   $0xf0106cfe
f01007bb:	68 03 6d 10 f0       	push   $0xf0106d03
f01007c0:	e8 33 33 00 00       	call   f0103af8 <cprintf>
f01007c5:	83 c4 0c             	add    $0xc,%esp
f01007c8:	68 bc 6d 10 f0       	push   $0xf0106dbc
f01007cd:	68 0c 6d 10 f0       	push   $0xf0106d0c
f01007d2:	68 03 6d 10 f0       	push   $0xf0106d03
f01007d7:	e8 1c 33 00 00       	call   f0103af8 <cprintf>
f01007dc:	83 c4 0c             	add    $0xc,%esp
f01007df:	68 e4 6d 10 f0       	push   $0xf0106de4
f01007e4:	68 15 6d 10 f0       	push   $0xf0106d15
f01007e9:	68 03 6d 10 f0       	push   $0xf0106d03
f01007ee:	e8 05 33 00 00       	call   f0103af8 <cprintf>
	return 0;
}
f01007f3:	b8 00 00 00 00       	mov    $0x0,%eax
f01007f8:	c9                   	leave  
f01007f9:	c3                   	ret    

f01007fa <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007fa:	f3 0f 1e fb          	endbr32 
f01007fe:	55                   	push   %ebp
f01007ff:	89 e5                	mov    %esp,%ebp
f0100801:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100804:	68 1f 6d 10 f0       	push   $0xf0106d1f
f0100809:	e8 ea 32 00 00       	call   f0103af8 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010080e:	83 c4 08             	add    $0x8,%esp
f0100811:	68 0c 00 10 00       	push   $0x10000c
f0100816:	68 14 6e 10 f0       	push   $0xf0106e14
f010081b:	e8 d8 32 00 00       	call   f0103af8 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100820:	83 c4 0c             	add    $0xc,%esp
f0100823:	68 0c 00 10 00       	push   $0x10000c
f0100828:	68 0c 00 10 f0       	push   $0xf010000c
f010082d:	68 3c 6e 10 f0       	push   $0xf0106e3c
f0100832:	e8 c1 32 00 00       	call   f0103af8 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100837:	83 c4 0c             	add    $0xc,%esp
f010083a:	68 bd 69 10 00       	push   $0x1069bd
f010083f:	68 bd 69 10 f0       	push   $0xf01069bd
f0100844:	68 60 6e 10 f0       	push   $0xf0106e60
f0100849:	e8 aa 32 00 00       	call   f0103af8 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010084e:	83 c4 0c             	add    $0xc,%esp
f0100851:	68 00 70 23 00       	push   $0x237000
f0100856:	68 00 70 23 f0       	push   $0xf0237000
f010085b:	68 84 6e 10 f0       	push   $0xf0106e84
f0100860:	e8 93 32 00 00       	call   f0103af8 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100865:	83 c4 0c             	add    $0xc,%esp
f0100868:	68 08 90 27 00       	push   $0x279008
f010086d:	68 08 90 27 f0       	push   $0xf0279008
f0100872:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0100877:	e8 7c 32 00 00       	call   f0103af8 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010087c:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010087f:	b8 08 90 27 f0       	mov    $0xf0279008,%eax
f0100884:	2d 0d fc 0f f0       	sub    $0xf00ffc0d,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100889:	c1 f8 0a             	sar    $0xa,%eax
f010088c:	50                   	push   %eax
f010088d:	68 cc 6e 10 f0       	push   $0xf0106ecc
f0100892:	e8 61 32 00 00       	call   f0103af8 <cprintf>
	return 0;
}
f0100897:	b8 00 00 00 00       	mov    $0x0,%eax
f010089c:	c9                   	leave  
f010089d:	c3                   	ret    

f010089e <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010089e:	f3 0f 1e fb          	endbr32 
f01008a2:	55                   	push   %ebp
f01008a3:	89 e5                	mov    %esp,%ebp
f01008a5:	57                   	push   %edi
f01008a6:	56                   	push   %esi
f01008a7:	53                   	push   %ebx
f01008a8:	83 ec 38             	sub    $0x38,%esp
	// Your code here.

    cprintf("Stack backtrace:\n");
f01008ab:	68 38 6d 10 f0       	push   $0xf0106d38
f01008b0:	e8 43 32 00 00       	call   f0103af8 <cprintf>
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008b5:	89 ee                	mov    %ebp,%esi

    uint32_t c_ebp = read_ebp();

    while (c_ebp != 0) {
f01008b7:	83 c4 10             	add    $0x10,%esp
f01008ba:	e9 84 00 00 00       	jmp    f0100943 <mon_backtrace+0xa5>
        cprintf("  eip %08x", ebp[1]);
        cprintf("  args");
        for(int i = 0; i < 5; ++i) {
            cprintf(" %08x", ebp[2+i]);
        }
        cprintf("\n");
f01008bf:	83 ec 0c             	sub    $0xc,%esp
f01008c2:	68 a0 7b 10 f0       	push   $0xf0107ba0
f01008c7:	e8 2c 32 00 00       	call   f0103af8 <cprintf>

        struct Eipdebuginfo info;
        memset(&info, 0, sizeof(struct Eipdebuginfo));
f01008cc:	83 c4 0c             	add    $0xc,%esp
f01008cf:	6a 18                	push   $0x18
f01008d1:	6a 00                	push   $0x0
f01008d3:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008d6:	50                   	push   %eax
f01008d7:	e8 50 54 00 00       	call   f0105d2c <memset>

        int ret = debuginfo_eip((uintptr_t)ebp[1], &info);
f01008dc:	83 c4 08             	add    $0x8,%esp
f01008df:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008e2:	50                   	push   %eax
f01008e3:	ff 77 04             	pushl  0x4(%edi)
f01008e6:	e8 0f 49 00 00       	call   f01051fa <debuginfo_eip>
        cprintf("         ");
f01008eb:	c7 04 24 67 6d 10 f0 	movl   $0xf0106d67,(%esp)
f01008f2:	e8 01 32 00 00       	call   f0103af8 <cprintf>
        cprintf("%s:", info.eip_file);
f01008f7:	83 c4 08             	add    $0x8,%esp
f01008fa:	ff 75 d0             	pushl  -0x30(%ebp)
f01008fd:	68 71 6d 10 f0       	push   $0xf0106d71
f0100902:	e8 f1 31 00 00       	call   f0103af8 <cprintf>
        cprintf("%d: ", info.eip_line);
f0100907:	83 c4 08             	add    $0x8,%esp
f010090a:	ff 75 d4             	pushl  -0x2c(%ebp)
f010090d:	68 7e 6a 10 f0       	push   $0xf0106a7e
f0100912:	e8 e1 31 00 00       	call   f0103af8 <cprintf>
        cprintf("%.*s", info.eip_fn_namelen, info.eip_fn_name);
f0100917:	83 c4 0c             	add    $0xc,%esp
f010091a:	ff 75 d8             	pushl  -0x28(%ebp)
f010091d:	ff 75 dc             	pushl  -0x24(%ebp)
f0100920:	68 75 6d 10 f0       	push   $0xf0106d75
f0100925:	e8 ce 31 00 00       	call   f0103af8 <cprintf>

        uintptr_t addr = ebp[1] - info.eip_fn_addr;

        cprintf("+%d\n", addr);
f010092a:	83 c4 08             	add    $0x8,%esp
        uintptr_t addr = ebp[1] - info.eip_fn_addr;
f010092d:	8b 47 04             	mov    0x4(%edi),%eax
f0100930:	2b 45 e0             	sub    -0x20(%ebp),%eax
        cprintf("+%d\n", addr);
f0100933:	50                   	push   %eax
f0100934:	68 7a 6d 10 f0       	push   $0xf0106d7a
f0100939:	e8 ba 31 00 00       	call   f0103af8 <cprintf>

        c_ebp = ebp[0];
f010093e:	8b 37                	mov    (%edi),%esi
f0100940:	83 c4 10             	add    $0x10,%esp
    while (c_ebp != 0) {
f0100943:	85 f6                	test   %esi,%esi
f0100945:	74 53                	je     f010099a <mon_backtrace+0xfc>
        uint32_t *ebp = (uint32_t *)c_ebp;
f0100947:	89 f7                	mov    %esi,%edi
        cprintf("  ebp %08x", c_ebp);
f0100949:	83 ec 08             	sub    $0x8,%esp
f010094c:	56                   	push   %esi
f010094d:	68 4a 6d 10 f0       	push   $0xf0106d4a
f0100952:	e8 a1 31 00 00       	call   f0103af8 <cprintf>
        cprintf("  eip %08x", ebp[1]);
f0100957:	83 c4 08             	add    $0x8,%esp
f010095a:	ff 76 04             	pushl  0x4(%esi)
f010095d:	68 55 6d 10 f0       	push   $0xf0106d55
f0100962:	e8 91 31 00 00       	call   f0103af8 <cprintf>
        cprintf("  args");
f0100967:	c7 04 24 60 6d 10 f0 	movl   $0xf0106d60,(%esp)
f010096e:	e8 85 31 00 00       	call   f0103af8 <cprintf>
f0100973:	8d 5e 08             	lea    0x8(%esi),%ebx
f0100976:	83 c6 1c             	add    $0x1c,%esi
f0100979:	83 c4 10             	add    $0x10,%esp
            cprintf(" %08x", ebp[2+i]);
f010097c:	83 ec 08             	sub    $0x8,%esp
f010097f:	ff 33                	pushl  (%ebx)
f0100981:	68 4f 6d 10 f0       	push   $0xf0106d4f
f0100986:	e8 6d 31 00 00       	call   f0103af8 <cprintf>
f010098b:	83 c3 04             	add    $0x4,%ebx
        for(int i = 0; i < 5; ++i) {
f010098e:	83 c4 10             	add    $0x10,%esp
f0100991:	39 f3                	cmp    %esi,%ebx
f0100993:	75 e7                	jne    f010097c <mon_backtrace+0xde>
f0100995:	e9 25 ff ff ff       	jmp    f01008bf <mon_backtrace+0x21>
    }
	return 0;
}
f010099a:	b8 00 00 00 00       	mov    $0x0,%eax
f010099f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009a2:	5b                   	pop    %ebx
f01009a3:	5e                   	pop    %esi
f01009a4:	5f                   	pop    %edi
f01009a5:	5d                   	pop    %ebp
f01009a6:	c3                   	ret    

f01009a7 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01009a7:	f3 0f 1e fb          	endbr32 
f01009ab:	55                   	push   %ebp
f01009ac:	89 e5                	mov    %esp,%ebp
f01009ae:	57                   	push   %edi
f01009af:	56                   	push   %esi
f01009b0:	53                   	push   %ebx
f01009b1:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01009b4:	68 f8 6e 10 f0       	push   $0xf0106ef8
f01009b9:	e8 3a 31 00 00       	call   f0103af8 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009be:	c7 04 24 1c 6f 10 f0 	movl   $0xf0106f1c,(%esp)
f01009c5:	e8 2e 31 00 00       	call   f0103af8 <cprintf>

	if (tf != NULL)
f01009ca:	83 c4 10             	add    $0x10,%esp
f01009cd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01009d1:	0f 84 d9 00 00 00    	je     f0100ab0 <monitor+0x109>
		print_trapframe(tf);
f01009d7:	83 ec 0c             	sub    $0xc,%esp
f01009da:	ff 75 08             	pushl  0x8(%ebp)
f01009dd:	e8 94 38 00 00       	call   f0104276 <print_trapframe>
f01009e2:	83 c4 10             	add    $0x10,%esp
f01009e5:	e9 c6 00 00 00       	jmp    f0100ab0 <monitor+0x109>
		while (*buf && strchr(WHITESPACE, *buf))
f01009ea:	83 ec 08             	sub    $0x8,%esp
f01009ed:	0f be c0             	movsbl %al,%eax
f01009f0:	50                   	push   %eax
f01009f1:	68 83 6d 10 f0       	push   $0xf0106d83
f01009f6:	e8 ec 52 00 00       	call   f0105ce7 <strchr>
f01009fb:	83 c4 10             	add    $0x10,%esp
f01009fe:	85 c0                	test   %eax,%eax
f0100a00:	74 63                	je     f0100a65 <monitor+0xbe>
			*buf++ = 0;
f0100a02:	c6 03 00             	movb   $0x0,(%ebx)
f0100a05:	89 f7                	mov    %esi,%edi
f0100a07:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100a0a:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100a0c:	0f b6 03             	movzbl (%ebx),%eax
f0100a0f:	84 c0                	test   %al,%al
f0100a11:	75 d7                	jne    f01009ea <monitor+0x43>
	argv[argc] = 0;
f0100a13:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a1a:	00 
	if (argc == 0)
f0100a1b:	85 f6                	test   %esi,%esi
f0100a1d:	0f 84 8d 00 00 00    	je     f0100ab0 <monitor+0x109>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a23:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a28:	83 ec 08             	sub    $0x8,%esp
f0100a2b:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a2e:	ff 34 85 60 6f 10 f0 	pushl  -0xfef90a0(,%eax,4)
f0100a35:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a38:	e8 44 52 00 00       	call   f0105c81 <strcmp>
f0100a3d:	83 c4 10             	add    $0x10,%esp
f0100a40:	85 c0                	test   %eax,%eax
f0100a42:	0f 84 8f 00 00 00    	je     f0100ad7 <monitor+0x130>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a48:	83 c3 01             	add    $0x1,%ebx
f0100a4b:	83 fb 03             	cmp    $0x3,%ebx
f0100a4e:	75 d8                	jne    f0100a28 <monitor+0x81>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a50:	83 ec 08             	sub    $0x8,%esp
f0100a53:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a56:	68 a5 6d 10 f0       	push   $0xf0106da5
f0100a5b:	e8 98 30 00 00       	call   f0103af8 <cprintf>
	return 0;
f0100a60:	83 c4 10             	add    $0x10,%esp
f0100a63:	eb 4b                	jmp    f0100ab0 <monitor+0x109>
		if (*buf == 0)
f0100a65:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100a68:	74 a9                	je     f0100a13 <monitor+0x6c>
		if (argc == MAXARGS-1) {
f0100a6a:	83 fe 0f             	cmp    $0xf,%esi
f0100a6d:	74 2f                	je     f0100a9e <monitor+0xf7>
		argv[argc++] = buf;
f0100a6f:	8d 7e 01             	lea    0x1(%esi),%edi
f0100a72:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a76:	0f b6 03             	movzbl (%ebx),%eax
f0100a79:	84 c0                	test   %al,%al
f0100a7b:	74 8d                	je     f0100a0a <monitor+0x63>
f0100a7d:	83 ec 08             	sub    $0x8,%esp
f0100a80:	0f be c0             	movsbl %al,%eax
f0100a83:	50                   	push   %eax
f0100a84:	68 83 6d 10 f0       	push   $0xf0106d83
f0100a89:	e8 59 52 00 00       	call   f0105ce7 <strchr>
f0100a8e:	83 c4 10             	add    $0x10,%esp
f0100a91:	85 c0                	test   %eax,%eax
f0100a93:	0f 85 71 ff ff ff    	jne    f0100a0a <monitor+0x63>
			buf++;
f0100a99:	83 c3 01             	add    $0x1,%ebx
f0100a9c:	eb d8                	jmp    f0100a76 <monitor+0xcf>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a9e:	83 ec 08             	sub    $0x8,%esp
f0100aa1:	6a 10                	push   $0x10
f0100aa3:	68 88 6d 10 f0       	push   $0xf0106d88
f0100aa8:	e8 4b 30 00 00       	call   f0103af8 <cprintf>
			return 0;
f0100aad:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100ab0:	83 ec 0c             	sub    $0xc,%esp
f0100ab3:	68 7f 6d 10 f0       	push   $0xf0106d7f
f0100ab8:	e8 dc 4f 00 00       	call   f0105a99 <readline>
f0100abd:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100abf:	83 c4 10             	add    $0x10,%esp
f0100ac2:	85 c0                	test   %eax,%eax
f0100ac4:	74 ea                	je     f0100ab0 <monitor+0x109>
	argv[argc] = 0;
f0100ac6:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100acd:	be 00 00 00 00       	mov    $0x0,%esi
f0100ad2:	e9 35 ff ff ff       	jmp    f0100a0c <monitor+0x65>
			return commands[i].func(argc, argv, tf);
f0100ad7:	83 ec 04             	sub    $0x4,%esp
f0100ada:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100add:	ff 75 08             	pushl  0x8(%ebp)
f0100ae0:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100ae3:	52                   	push   %edx
f0100ae4:	56                   	push   %esi
f0100ae5:	ff 14 85 68 6f 10 f0 	call   *-0xfef9098(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100aec:	83 c4 10             	add    $0x10,%esp
f0100aef:	85 c0                	test   %eax,%eax
f0100af1:	79 bd                	jns    f0100ab0 <monitor+0x109>
				break;
	}
}
f0100af3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100af6:	5b                   	pop    %ebx
f0100af7:	5e                   	pop    %esi
f0100af8:	5f                   	pop    %edi
f0100af9:	5d                   	pop    %ebp
f0100afa:	c3                   	ret    

f0100afb <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100afb:	55                   	push   %ebp
f0100afc:	89 e5                	mov    %esp,%ebp
f0100afe:	56                   	push   %esi
f0100aff:	53                   	push   %ebx
f0100b00:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100b02:	83 ec 0c             	sub    $0xc,%esp
f0100b05:	50                   	push   %eax
f0100b06:	e8 4a 2e 00 00       	call   f0103955 <mc146818_read>
f0100b0b:	89 c6                	mov    %eax,%esi
f0100b0d:	83 c3 01             	add    $0x1,%ebx
f0100b10:	89 1c 24             	mov    %ebx,(%esp)
f0100b13:	e8 3d 2e 00 00       	call   f0103955 <mc146818_read>
f0100b18:	c1 e0 08             	shl    $0x8,%eax
f0100b1b:	09 f0                	or     %esi,%eax
}
f0100b1d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100b20:	5b                   	pop    %ebx
f0100b21:	5e                   	pop    %esi
f0100b22:	5d                   	pop    %ebp
f0100b23:	c3                   	ret    

f0100b24 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100b24:	89 d1                	mov    %edx,%ecx
f0100b26:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100b29:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b2c:	a8 01                	test   $0x1,%al
f0100b2e:	74 51                	je     f0100b81 <check_va2pa+0x5d>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b30:	89 c1                	mov    %eax,%ecx
f0100b32:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	if (PGNUM(pa) >= npages)
f0100b38:	c1 e8 0c             	shr    $0xc,%eax
f0100b3b:	3b 05 88 7e 23 f0    	cmp    0xf0237e88,%eax
f0100b41:	73 23                	jae    f0100b66 <check_va2pa+0x42>
	if (!(p[PTX(va)] & PTE_P))
f0100b43:	c1 ea 0c             	shr    $0xc,%edx
f0100b46:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b4c:	8b 94 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b53:	89 d0                	mov    %edx,%eax
f0100b55:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b5a:	f6 c2 01             	test   $0x1,%dl
f0100b5d:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b62:	0f 44 c2             	cmove  %edx,%eax
f0100b65:	c3                   	ret    
{
f0100b66:	55                   	push   %ebp
f0100b67:	89 e5                	mov    %esp,%ebp
f0100b69:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b6c:	51                   	push   %ecx
f0100b6d:	68 e4 69 10 f0       	push   $0xf01069e4
f0100b72:	68 dc 03 00 00       	push   $0x3dc
f0100b77:	68 a5 78 10 f0       	push   $0xf01078a5
f0100b7c:	e8 bf f4 ff ff       	call   f0100040 <_panic>
		return ~0;
f0100b81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100b86:	c3                   	ret    

f0100b87 <boot_alloc>:
	if (!nextfree) {
f0100b87:	83 3d 38 72 23 f0 00 	cmpl   $0x0,0xf0237238
f0100b8e:	74 3d                	je     f0100bcd <boot_alloc+0x46>
    if (n == 0) {
f0100b90:	85 c0                	test   %eax,%eax
f0100b92:	74 4c                	je     f0100be0 <boot_alloc+0x59>
{
f0100b94:	55                   	push   %ebp
f0100b95:	89 e5                	mov    %esp,%ebp
f0100b97:	83 ec 08             	sub    $0x8,%esp
            (uintptr_t) ROUNDUP((char *)nextfree + n, PGSIZE);
f0100b9a:	8b 15 38 72 23 f0    	mov    0xf0237238,%edx
f0100ba0:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100ba7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if ((uint32_t)kva < KERNBASE)
f0100bac:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100bb1:	76 36                	jbe    f0100be9 <boot_alloc+0x62>
	return (physaddr_t)kva - KERNBASE;
f0100bb3:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
    if ( PADDR((void *)next_nextfree)/PGSIZE < npages ) {
f0100bb9:	c1 e9 0c             	shr    $0xc,%ecx
f0100bbc:	3b 0d 88 7e 23 f0    	cmp    0xf0237e88,%ecx
f0100bc2:	73 37                	jae    f0100bfb <boot_alloc+0x74>
        nextfree = (char *)next_nextfree;
f0100bc4:	a3 38 72 23 f0       	mov    %eax,0xf0237238
}
f0100bc9:	89 d0                	mov    %edx,%eax
f0100bcb:	c9                   	leave  
f0100bcc:	c3                   	ret    
		nextfree = ROUNDUP((char *) end + 1, PGSIZE);
f0100bcd:	ba 08 a0 27 f0       	mov    $0xf027a008,%edx
f0100bd2:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100bd8:	89 15 38 72 23 f0    	mov    %edx,0xf0237238
f0100bde:	eb b0                	jmp    f0100b90 <boot_alloc+0x9>
        return nextfree;
f0100be0:	8b 15 38 72 23 f0    	mov    0xf0237238,%edx
}
f0100be6:	89 d0                	mov    %edx,%eax
f0100be8:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100be9:	50                   	push   %eax
f0100bea:	68 08 6a 10 f0       	push   $0xf0106a08
f0100bef:	6a 74                	push   $0x74
f0100bf1:	68 a5 78 10 f0       	push   $0xf01078a5
f0100bf6:	e8 45 f4 ff ff       	call   f0100040 <_panic>
        panic("Out of memory");
f0100bfb:	83 ec 04             	sub    $0x4,%esp
f0100bfe:	68 b1 78 10 f0       	push   $0xf01078b1
f0100c03:	6a 7a                	push   $0x7a
f0100c05:	68 a5 78 10 f0       	push   $0xf01078a5
f0100c0a:	e8 31 f4 ff ff       	call   f0100040 <_panic>

f0100c0f <check_page_free_list>:
{
f0100c0f:	55                   	push   %ebp
f0100c10:	89 e5                	mov    %esp,%ebp
f0100c12:	57                   	push   %edi
f0100c13:	56                   	push   %esi
f0100c14:	53                   	push   %ebx
f0100c15:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c18:	84 c0                	test   %al,%al
f0100c1a:	0f 85 77 02 00 00    	jne    f0100e97 <check_page_free_list+0x288>
	if (!page_free_list)
f0100c20:	83 3d 40 72 23 f0 00 	cmpl   $0x0,0xf0237240
f0100c27:	74 0a                	je     f0100c33 <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c29:	be 00 04 00 00       	mov    $0x400,%esi
f0100c2e:	e9 bf 02 00 00       	jmp    f0100ef2 <check_page_free_list+0x2e3>
		panic("'page_free_list' is a null pointer!");
f0100c33:	83 ec 04             	sub    $0x4,%esp
f0100c36:	68 84 6f 10 f0       	push   $0xf0106f84
f0100c3b:	68 0e 03 00 00       	push   $0x30e
f0100c40:	68 a5 78 10 f0       	push   $0xf01078a5
f0100c45:	e8 f6 f3 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c4a:	50                   	push   %eax
f0100c4b:	68 e4 69 10 f0       	push   $0xf01069e4
f0100c50:	6a 58                	push   $0x58
f0100c52:	68 bf 78 10 f0       	push   $0xf01078bf
f0100c57:	e8 e4 f3 ff ff       	call   f0100040 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c5c:	8b 1b                	mov    (%ebx),%ebx
f0100c5e:	85 db                	test   %ebx,%ebx
f0100c60:	74 41                	je     f0100ca3 <check_page_free_list+0x94>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c62:	89 d8                	mov    %ebx,%eax
f0100c64:	2b 05 90 7e 23 f0    	sub    0xf0237e90,%eax
f0100c6a:	c1 f8 03             	sar    $0x3,%eax
f0100c6d:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c70:	89 c2                	mov    %eax,%edx
f0100c72:	c1 ea 16             	shr    $0x16,%edx
f0100c75:	39 f2                	cmp    %esi,%edx
f0100c77:	73 e3                	jae    f0100c5c <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f0100c79:	89 c2                	mov    %eax,%edx
f0100c7b:	c1 ea 0c             	shr    $0xc,%edx
f0100c7e:	3b 15 88 7e 23 f0    	cmp    0xf0237e88,%edx
f0100c84:	73 c4                	jae    f0100c4a <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100c86:	83 ec 04             	sub    $0x4,%esp
f0100c89:	68 80 00 00 00       	push   $0x80
f0100c8e:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100c93:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c98:	50                   	push   %eax
f0100c99:	e8 8e 50 00 00       	call   f0105d2c <memset>
f0100c9e:	83 c4 10             	add    $0x10,%esp
f0100ca1:	eb b9                	jmp    f0100c5c <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f0100ca3:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ca8:	e8 da fe ff ff       	call   f0100b87 <boot_alloc>
f0100cad:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cb0:	8b 15 40 72 23 f0    	mov    0xf0237240,%edx
		assert(pp >= pages);
f0100cb6:	8b 0d 90 7e 23 f0    	mov    0xf0237e90,%ecx
		assert(pp < pages + npages);
f0100cbc:	a1 88 7e 23 f0       	mov    0xf0237e88,%eax
f0100cc1:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100cc4:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100cc7:	bf 00 00 00 00       	mov    $0x0,%edi
f0100ccc:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ccf:	e9 f9 00 00 00       	jmp    f0100dcd <check_page_free_list+0x1be>
		assert(pp >= pages);
f0100cd4:	68 cd 78 10 f0       	push   $0xf01078cd
f0100cd9:	68 d9 78 10 f0       	push   $0xf01078d9
f0100cde:	68 28 03 00 00       	push   $0x328
f0100ce3:	68 a5 78 10 f0       	push   $0xf01078a5
f0100ce8:	e8 53 f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100ced:	68 ee 78 10 f0       	push   $0xf01078ee
f0100cf2:	68 d9 78 10 f0       	push   $0xf01078d9
f0100cf7:	68 29 03 00 00       	push   $0x329
f0100cfc:	68 a5 78 10 f0       	push   $0xf01078a5
f0100d01:	e8 3a f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d06:	68 a8 6f 10 f0       	push   $0xf0106fa8
f0100d0b:	68 d9 78 10 f0       	push   $0xf01078d9
f0100d10:	68 2a 03 00 00       	push   $0x32a
f0100d15:	68 a5 78 10 f0       	push   $0xf01078a5
f0100d1a:	e8 21 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != 0);
f0100d1f:	68 02 79 10 f0       	push   $0xf0107902
f0100d24:	68 d9 78 10 f0       	push   $0xf01078d9
f0100d29:	68 2d 03 00 00       	push   $0x32d
f0100d2e:	68 a5 78 10 f0       	push   $0xf01078a5
f0100d33:	e8 08 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d38:	68 13 79 10 f0       	push   $0xf0107913
f0100d3d:	68 d9 78 10 f0       	push   $0xf01078d9
f0100d42:	68 2e 03 00 00       	push   $0x32e
f0100d47:	68 a5 78 10 f0       	push   $0xf01078a5
f0100d4c:	e8 ef f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d51:	68 dc 6f 10 f0       	push   $0xf0106fdc
f0100d56:	68 d9 78 10 f0       	push   $0xf01078d9
f0100d5b:	68 2f 03 00 00       	push   $0x32f
f0100d60:	68 a5 78 10 f0       	push   $0xf01078a5
f0100d65:	e8 d6 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d6a:	68 2c 79 10 f0       	push   $0xf010792c
f0100d6f:	68 d9 78 10 f0       	push   $0xf01078d9
f0100d74:	68 30 03 00 00       	push   $0x330
f0100d79:	68 a5 78 10 f0       	push   $0xf01078a5
f0100d7e:	e8 bd f2 ff ff       	call   f0100040 <_panic>
	if (PGNUM(pa) >= npages)
f0100d83:	89 c3                	mov    %eax,%ebx
f0100d85:	c1 eb 0c             	shr    $0xc,%ebx
f0100d88:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0100d8b:	76 0f                	jbe    f0100d9c <check_page_free_list+0x18d>
	return (void *)(pa + KERNBASE);
f0100d8d:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d92:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100d95:	77 17                	ja     f0100dae <check_page_free_list+0x19f>
			++nfree_extmem;
f0100d97:	83 c7 01             	add    $0x1,%edi
f0100d9a:	eb 2f                	jmp    f0100dcb <check_page_free_list+0x1bc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d9c:	50                   	push   %eax
f0100d9d:	68 e4 69 10 f0       	push   $0xf01069e4
f0100da2:	6a 58                	push   $0x58
f0100da4:	68 bf 78 10 f0       	push   $0xf01078bf
f0100da9:	e8 92 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100dae:	68 00 70 10 f0       	push   $0xf0107000
f0100db3:	68 d9 78 10 f0       	push   $0xf01078d9
f0100db8:	68 31 03 00 00       	push   $0x331
f0100dbd:	68 a5 78 10 f0       	push   $0xf01078a5
f0100dc2:	e8 79 f2 ff ff       	call   f0100040 <_panic>
			++nfree_basemem;
f0100dc7:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100dcb:	8b 12                	mov    (%edx),%edx
f0100dcd:	85 d2                	test   %edx,%edx
f0100dcf:	74 74                	je     f0100e45 <check_page_free_list+0x236>
		assert(pp >= pages);
f0100dd1:	39 d1                	cmp    %edx,%ecx
f0100dd3:	0f 87 fb fe ff ff    	ja     f0100cd4 <check_page_free_list+0xc5>
		assert(pp < pages + npages);
f0100dd9:	39 d6                	cmp    %edx,%esi
f0100ddb:	0f 86 0c ff ff ff    	jbe    f0100ced <check_page_free_list+0xde>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100de1:	89 d0                	mov    %edx,%eax
f0100de3:	29 c8                	sub    %ecx,%eax
f0100de5:	a8 07                	test   $0x7,%al
f0100de7:	0f 85 19 ff ff ff    	jne    f0100d06 <check_page_free_list+0xf7>
	return (pp - pages) << PGSHIFT;
f0100ded:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100df0:	c1 e0 0c             	shl    $0xc,%eax
f0100df3:	0f 84 26 ff ff ff    	je     f0100d1f <check_page_free_list+0x110>
		assert(page2pa(pp) != IOPHYSMEM);
f0100df9:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100dfe:	0f 84 34 ff ff ff    	je     f0100d38 <check_page_free_list+0x129>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100e04:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100e09:	0f 84 42 ff ff ff    	je     f0100d51 <check_page_free_list+0x142>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100e0f:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100e14:	0f 84 50 ff ff ff    	je     f0100d6a <check_page_free_list+0x15b>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e1a:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100e1f:	0f 87 5e ff ff ff    	ja     f0100d83 <check_page_free_list+0x174>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e25:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e2a:	75 9b                	jne    f0100dc7 <check_page_free_list+0x1b8>
f0100e2c:	68 46 79 10 f0       	push   $0xf0107946
f0100e31:	68 d9 78 10 f0       	push   $0xf01078d9
f0100e36:	68 33 03 00 00       	push   $0x333
f0100e3b:	68 a5 78 10 f0       	push   $0xf01078a5
f0100e40:	e8 fb f1 ff ff       	call   f0100040 <_panic>
f0100e45:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
	assert(nfree_basemem > 0);
f0100e48:	85 db                	test   %ebx,%ebx
f0100e4a:	7e 19                	jle    f0100e65 <check_page_free_list+0x256>
	assert(nfree_extmem > 0);
f0100e4c:	85 ff                	test   %edi,%edi
f0100e4e:	7e 2e                	jle    f0100e7e <check_page_free_list+0x26f>
	cprintf("check_page_free_list() succeeded!\n");
f0100e50:	83 ec 0c             	sub    $0xc,%esp
f0100e53:	68 48 70 10 f0       	push   $0xf0107048
f0100e58:	e8 9b 2c 00 00       	call   f0103af8 <cprintf>
}
f0100e5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e60:	5b                   	pop    %ebx
f0100e61:	5e                   	pop    %esi
f0100e62:	5f                   	pop    %edi
f0100e63:	5d                   	pop    %ebp
f0100e64:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100e65:	68 63 79 10 f0       	push   $0xf0107963
f0100e6a:	68 d9 78 10 f0       	push   $0xf01078d9
f0100e6f:	68 3b 03 00 00       	push   $0x33b
f0100e74:	68 a5 78 10 f0       	push   $0xf01078a5
f0100e79:	e8 c2 f1 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e7e:	68 75 79 10 f0       	push   $0xf0107975
f0100e83:	68 d9 78 10 f0       	push   $0xf01078d9
f0100e88:	68 3c 03 00 00       	push   $0x33c
f0100e8d:	68 a5 78 10 f0       	push   $0xf01078a5
f0100e92:	e8 a9 f1 ff ff       	call   f0100040 <_panic>
	if (!page_free_list)
f0100e97:	a1 40 72 23 f0       	mov    0xf0237240,%eax
f0100e9c:	85 c0                	test   %eax,%eax
f0100e9e:	0f 84 8f fd ff ff    	je     f0100c33 <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100ea4:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100ea7:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100eaa:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100ead:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100eb0:	89 c2                	mov    %eax,%edx
f0100eb2:	2b 15 90 7e 23 f0    	sub    0xf0237e90,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100eb8:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100ebe:	0f 95 c2             	setne  %dl
f0100ec1:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100ec4:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100ec8:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100eca:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ece:	8b 00                	mov    (%eax),%eax
f0100ed0:	85 c0                	test   %eax,%eax
f0100ed2:	75 dc                	jne    f0100eb0 <check_page_free_list+0x2a1>
		*tp[1] = 0;
f0100ed4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ed7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100edd:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100ee0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ee3:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100ee5:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100ee8:	a3 40 72 23 f0       	mov    %eax,0xf0237240
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100eed:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ef2:	8b 1d 40 72 23 f0    	mov    0xf0237240,%ebx
f0100ef8:	e9 61 fd ff ff       	jmp    f0100c5e <check_page_free_list+0x4f>

f0100efd <page_init>:
{
f0100efd:	f3 0f 1e fb          	endbr32 
f0100f01:	55                   	push   %ebp
f0100f02:	89 e5                	mov    %esp,%ebp
f0100f04:	57                   	push   %edi
f0100f05:	56                   	push   %esi
f0100f06:	53                   	push   %ebx
f0100f07:	83 ec 1c             	sub    $0x1c,%esp
    physaddr_t free_phy = PADDR((void *)boot_alloc(0));
f0100f0a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f0f:	e8 73 fc ff ff       	call   f0100b87 <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0100f14:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100f19:	76 1d                	jbe    f0100f38 <page_init+0x3b>
	return (physaddr_t)kva - KERNBASE;
f0100f1b:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
    size_t free_phy_pgnum = PGNUM(free_phy);
f0100f21:	c1 e9 0c             	shr    $0xc,%ecx
f0100f24:	8b 3d 40 72 23 f0    	mov    0xf0237240,%edi
    for (int i=0; i<npages; ++i) {
f0100f2a:	c6 45 e3 00          	movb   $0x0,-0x1d(%ebp)
f0100f2e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f33:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100f36:	eb 32                	jmp    f0100f6a <page_init+0x6d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f38:	50                   	push   %eax
f0100f39:	68 08 6a 10 f0       	push   $0xf0106a08
f0100f3e:	68 65 01 00 00       	push   $0x165
f0100f43:	68 a5 78 10 f0       	push   $0xf01078a5
f0100f48:	e8 f3 f0 ff ff       	call   f0100040 <_panic>
            pages[i].pp_link = NULL;
f0100f4d:	8b 1d 90 7e 23 f0    	mov    0xf0237e90,%ebx
f0100f53:	c7 04 d3 00 00 00 00 	movl   $0x0,(%ebx,%edx,8)
            pages[i].pp_ref = 1;
f0100f5a:	8b 1d 90 7e 23 f0    	mov    0xf0237e90,%ebx
f0100f60:	66 c7 44 d3 04 01 00 	movw   $0x1,0x4(%ebx,%edx,8)
    for (int i=0; i<npages; ++i) {
f0100f67:	83 c0 01             	add    $0x1,%eax
f0100f6a:	89 c2                	mov    %eax,%edx
f0100f6c:	39 05 88 7e 23 f0    	cmp    %eax,0xf0237e88
f0100f72:	76 41                	jbe    f0100fb5 <page_init+0xb8>
        if (i == 0 || ( i >= PGNUM(IOPHYSMEM) && i < free_phy_pgnum ) ||
f0100f74:	85 c0                	test   %eax,%eax
f0100f76:	74 d5                	je     f0100f4d <page_init+0x50>
f0100f78:	81 fa 9f 00 00 00    	cmp    $0x9f,%edx
f0100f7e:	0f 97 c3             	seta   %bl
f0100f81:	89 de                	mov    %ebx,%esi
f0100f83:	39 55 e4             	cmp    %edx,-0x1c(%ebp)
f0100f86:	0f 97 c3             	seta   %bl
f0100f89:	89 f1                	mov    %esi,%ecx
f0100f8b:	84 d9                	test   %bl,%cl
f0100f8d:	75 be                	jne    f0100f4d <page_init+0x50>
f0100f8f:	83 f8 07             	cmp    $0x7,%eax
f0100f92:	74 b9                	je     f0100f4d <page_init+0x50>
f0100f94:	c1 e2 03             	shl    $0x3,%edx
            pages[i].pp_ref = 0;
f0100f97:	89 d3                	mov    %edx,%ebx
f0100f99:	03 1d 90 7e 23 f0    	add    0xf0237e90,%ebx
f0100f9f:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
            pages[i].pp_link = page_free_list;
f0100fa5:	89 3b                	mov    %edi,(%ebx)
            page_free_list = &pages[i];
f0100fa7:	89 d7                	mov    %edx,%edi
f0100fa9:	03 3d 90 7e 23 f0    	add    0xf0237e90,%edi
f0100faf:	c6 45 e3 01          	movb   $0x1,-0x1d(%ebp)
f0100fb3:	eb b2                	jmp    f0100f67 <page_init+0x6a>
f0100fb5:	80 7d e3 00          	cmpb   $0x0,-0x1d(%ebp)
f0100fb9:	74 06                	je     f0100fc1 <page_init+0xc4>
f0100fbb:	89 3d 40 72 23 f0    	mov    %edi,0xf0237240
}
f0100fc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100fc4:	5b                   	pop    %ebx
f0100fc5:	5e                   	pop    %esi
f0100fc6:	5f                   	pop    %edi
f0100fc7:	5d                   	pop    %ebp
f0100fc8:	c3                   	ret    

f0100fc9 <page_alloc>:
{
f0100fc9:	f3 0f 1e fb          	endbr32 
f0100fcd:	55                   	push   %ebp
f0100fce:	89 e5                	mov    %esp,%ebp
f0100fd0:	53                   	push   %ebx
f0100fd1:	83 ec 04             	sub    $0x4,%esp
    if (page_free_list == NULL) {
f0100fd4:	8b 1d 40 72 23 f0    	mov    0xf0237240,%ebx
f0100fda:	85 db                	test   %ebx,%ebx
f0100fdc:	74 13                	je     f0100ff1 <page_alloc+0x28>
    page_free_list = ret->pp_link;
f0100fde:	8b 03                	mov    (%ebx),%eax
f0100fe0:	a3 40 72 23 f0       	mov    %eax,0xf0237240
    ret->pp_link = NULL;
f0100fe5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (alloc_flags & ALLOC_ZERO) {
f0100feb:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100fef:	75 07                	jne    f0100ff8 <page_alloc+0x2f>
}
f0100ff1:	89 d8                	mov    %ebx,%eax
f0100ff3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100ff6:	c9                   	leave  
f0100ff7:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f0100ff8:	89 d8                	mov    %ebx,%eax
f0100ffa:	2b 05 90 7e 23 f0    	sub    0xf0237e90,%eax
f0101000:	c1 f8 03             	sar    $0x3,%eax
f0101003:	89 c2                	mov    %eax,%edx
f0101005:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101008:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010100d:	3b 05 88 7e 23 f0    	cmp    0xf0237e88,%eax
f0101013:	73 1b                	jae    f0101030 <page_alloc+0x67>
        memset(p, 0, PGSIZE);
f0101015:	83 ec 04             	sub    $0x4,%esp
f0101018:	68 00 10 00 00       	push   $0x1000
f010101d:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f010101f:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101025:	52                   	push   %edx
f0101026:	e8 01 4d 00 00       	call   f0105d2c <memset>
f010102b:	83 c4 10             	add    $0x10,%esp
f010102e:	eb c1                	jmp    f0100ff1 <page_alloc+0x28>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101030:	52                   	push   %edx
f0101031:	68 e4 69 10 f0       	push   $0xf01069e4
f0101036:	6a 58                	push   $0x58
f0101038:	68 bf 78 10 f0       	push   $0xf01078bf
f010103d:	e8 fe ef ff ff       	call   f0100040 <_panic>

f0101042 <page_free>:
{
f0101042:	f3 0f 1e fb          	endbr32 
f0101046:	55                   	push   %ebp
f0101047:	89 e5                	mov    %esp,%ebp
f0101049:	83 ec 08             	sub    $0x8,%esp
f010104c:	8b 45 08             	mov    0x8(%ebp),%eax
    if (pp->pp_ref != 0 || pp->pp_link != NULL) {
f010104f:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101054:	75 14                	jne    f010106a <page_free+0x28>
f0101056:	83 38 00             	cmpl   $0x0,(%eax)
f0101059:	75 0f                	jne    f010106a <page_free+0x28>
    pp->pp_link = page_free_list;
f010105b:	8b 15 40 72 23 f0    	mov    0xf0237240,%edx
f0101061:	89 10                	mov    %edx,(%eax)
    page_free_list = pp;
f0101063:	a3 40 72 23 f0       	mov    %eax,0xf0237240
}
f0101068:	c9                   	leave  
f0101069:	c3                   	ret    
        panic("Double free!");
f010106a:	83 ec 04             	sub    $0x4,%esp
f010106d:	68 86 79 10 f0       	push   $0xf0107986
f0101072:	68 a5 01 00 00       	push   $0x1a5
f0101077:	68 a5 78 10 f0       	push   $0xf01078a5
f010107c:	e8 bf ef ff ff       	call   f0100040 <_panic>

f0101081 <page_decref>:
{
f0101081:	f3 0f 1e fb          	endbr32 
f0101085:	55                   	push   %ebp
f0101086:	89 e5                	mov    %esp,%ebp
f0101088:	83 ec 08             	sub    $0x8,%esp
f010108b:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f010108e:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101092:	83 e8 01             	sub    $0x1,%eax
f0101095:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101099:	66 85 c0             	test   %ax,%ax
f010109c:	74 02                	je     f01010a0 <page_decref+0x1f>
}
f010109e:	c9                   	leave  
f010109f:	c3                   	ret    
		page_free(pp);
f01010a0:	83 ec 0c             	sub    $0xc,%esp
f01010a3:	52                   	push   %edx
f01010a4:	e8 99 ff ff ff       	call   f0101042 <page_free>
f01010a9:	83 c4 10             	add    $0x10,%esp
}
f01010ac:	eb f0                	jmp    f010109e <page_decref+0x1d>

f01010ae <pgdir_walk>:
{
f01010ae:	f3 0f 1e fb          	endbr32 
f01010b2:	55                   	push   %ebp
f01010b3:	89 e5                	mov    %esp,%ebp
f01010b5:	56                   	push   %esi
f01010b6:	53                   	push   %ebx
f01010b7:	8b 75 0c             	mov    0xc(%ebp),%esi
    pde_t pde = pgdir[PDX(va)];
f01010ba:	89 f3                	mov    %esi,%ebx
f01010bc:	c1 eb 16             	shr    $0x16,%ebx
f01010bf:	c1 e3 02             	shl    $0x2,%ebx
f01010c2:	03 5d 08             	add    0x8(%ebp),%ebx
    if (!(pde & PTE_P)) {
f01010c5:	f6 03 01             	testb  $0x1,(%ebx)
f01010c8:	75 2d                	jne    f01010f7 <pgdir_walk+0x49>
        if (create) {
f01010ca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01010ce:	74 67                	je     f0101137 <pgdir_walk+0x89>
            struct PageInfo *pp = page_alloc(ALLOC_ZERO);
f01010d0:	83 ec 0c             	sub    $0xc,%esp
f01010d3:	6a 01                	push   $0x1
f01010d5:	e8 ef fe ff ff       	call   f0100fc9 <page_alloc>
            if (pp == NULL) {
f01010da:	83 c4 10             	add    $0x10,%esp
f01010dd:	85 c0                	test   %eax,%eax
f01010df:	74 3a                	je     f010111b <pgdir_walk+0x6d>
            pp->pp_ref += 1;
f01010e1:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f01010e6:	2b 05 90 7e 23 f0    	sub    0xf0237e90,%eax
f01010ec:	c1 f8 03             	sar    $0x3,%eax
f01010ef:	c1 e0 0c             	shl    $0xc,%eax
            pgdir[PDX(va)] = pa_pt | PTE_W | PTE_U | PTE_P;
f01010f2:	83 c8 07             	or     $0x7,%eax
f01010f5:	89 03                	mov    %eax,(%ebx)
    pte_t *pt = (pte_t *) PTE_ADDR(pgdir[PDX(va)]);
f01010f7:	8b 13                	mov    (%ebx),%edx
f01010f9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
    return KADDR((physaddr_t)(pt + PTX(va)));
f01010ff:	c1 ee 0a             	shr    $0xa,%esi
f0101102:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0101108:	8d 04 32             	lea    (%edx,%esi,1),%eax
	if (PGNUM(pa) >= npages)
f010110b:	c1 ea 0c             	shr    $0xc,%edx
f010110e:	3b 15 88 7e 23 f0    	cmp    0xf0237e88,%edx
f0101114:	73 0c                	jae    f0101122 <pgdir_walk+0x74>
	return (void *)(pa + KERNBASE);
f0101116:	2d 00 00 00 10       	sub    $0x10000000,%eax
}
f010111b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010111e:	5b                   	pop    %ebx
f010111f:	5e                   	pop    %esi
f0101120:	5d                   	pop    %ebp
f0101121:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101122:	50                   	push   %eax
f0101123:	68 e4 69 10 f0       	push   $0xf01069e4
f0101128:	68 e5 01 00 00       	push   $0x1e5
f010112d:	68 a5 78 10 f0       	push   $0xf01078a5
f0101132:	e8 09 ef ff ff       	call   f0100040 <_panic>
            return NULL;
f0101137:	b8 00 00 00 00       	mov    $0x0,%eax
f010113c:	eb dd                	jmp    f010111b <pgdir_walk+0x6d>

f010113e <boot_map_region>:
{
f010113e:	55                   	push   %ebp
f010113f:	89 e5                	mov    %esp,%ebp
f0101141:	57                   	push   %edi
f0101142:	56                   	push   %esi
f0101143:	53                   	push   %ebx
f0101144:	83 ec 1c             	sub    $0x1c,%esp
f0101147:	89 45 dc             	mov    %eax,-0x24(%ebp)
f010114a:	8b 5d 08             	mov    0x8(%ebp),%ebx
    uint64_t e_va = (uint64_t)va + (uint64_t)size;
f010114d:	89 d6                	mov    %edx,%esi
f010114f:	bf 00 00 00 00       	mov    $0x0,%edi
f0101154:	89 c8                	mov    %ecx,%eax
f0101156:	ba 00 00 00 00       	mov    $0x0,%edx
f010115b:	01 f0                	add    %esi,%eax
f010115d:	11 fa                	adc    %edi,%edx
f010115f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101162:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    while (c_va < e_va) {
f0101165:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101168:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010116b:	39 c6                	cmp    %eax,%esi
f010116d:	89 f9                	mov    %edi,%ecx
f010116f:	19 d1                	sbb    %edx,%ecx
f0101171:	73 33                	jae    f01011a6 <boot_map_region+0x68>
        pte_t *p_pte = pgdir_walk(pgdir, (void *)((uintptr_t)c_va), 1);
f0101173:	83 ec 04             	sub    $0x4,%esp
f0101176:	6a 01                	push   $0x1
f0101178:	56                   	push   %esi
f0101179:	ff 75 dc             	pushl  -0x24(%ebp)
f010117c:	e8 2d ff ff ff       	call   f01010ae <pgdir_walk>
f0101181:	89 c2                	mov    %eax,%edx
        *p_pte = PTE_ADDR(c_pa) | perm | PTE_P;
f0101183:	89 d8                	mov    %ebx,%eax
f0101185:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010118a:	0b 45 0c             	or     0xc(%ebp),%eax
f010118d:	83 c8 01             	or     $0x1,%eax
f0101190:	89 02                	mov    %eax,(%edx)
        c_va += PGSIZE;
f0101192:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0101198:	83 d7 00             	adc    $0x0,%edi
        c_pa += PGSIZE;
f010119b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01011a1:	83 c4 10             	add    $0x10,%esp
f01011a4:	eb bf                	jmp    f0101165 <boot_map_region+0x27>
}
f01011a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011a9:	5b                   	pop    %ebx
f01011aa:	5e                   	pop    %esi
f01011ab:	5f                   	pop    %edi
f01011ac:	5d                   	pop    %ebp
f01011ad:	c3                   	ret    

f01011ae <page_lookup>:
{
f01011ae:	f3 0f 1e fb          	endbr32 
f01011b2:	55                   	push   %ebp
f01011b3:	89 e5                	mov    %esp,%ebp
f01011b5:	53                   	push   %ebx
f01011b6:	83 ec 08             	sub    $0x8,%esp
f01011b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
    pte_t *p_pte = pgdir_walk(pgdir, va, 0);
f01011bc:	6a 00                	push   $0x0
f01011be:	ff 75 0c             	pushl  0xc(%ebp)
f01011c1:	ff 75 08             	pushl  0x8(%ebp)
f01011c4:	e8 e5 fe ff ff       	call   f01010ae <pgdir_walk>
    if (pte_store != NULL) {
f01011c9:	83 c4 10             	add    $0x10,%esp
f01011cc:	85 db                	test   %ebx,%ebx
f01011ce:	74 02                	je     f01011d2 <page_lookup+0x24>
        *pte_store = p_pte;
f01011d0:	89 03                	mov    %eax,(%ebx)
    if (p_pte == NULL) {
f01011d2:	85 c0                	test   %eax,%eax
f01011d4:	74 1a                	je     f01011f0 <page_lookup+0x42>
    if (!(*p_pte & PTE_P)) {
f01011d6:	8b 00                	mov    (%eax),%eax
f01011d8:	a8 01                	test   $0x1,%al
f01011da:	74 2d                	je     f0101209 <page_lookup+0x5b>
f01011dc:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011df:	39 05 88 7e 23 f0    	cmp    %eax,0xf0237e88
f01011e5:	76 0e                	jbe    f01011f5 <page_lookup+0x47>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f01011e7:	8b 15 90 7e 23 f0    	mov    0xf0237e90,%edx
f01011ed:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f01011f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01011f3:	c9                   	leave  
f01011f4:	c3                   	ret    
		panic("pa2page called with invalid pa");
f01011f5:	83 ec 04             	sub    $0x4,%esp
f01011f8:	68 6c 70 10 f0       	push   $0xf010706c
f01011fd:	6a 51                	push   $0x51
f01011ff:	68 bf 78 10 f0       	push   $0xf01078bf
f0101204:	e8 37 ee ff ff       	call   f0100040 <_panic>
        return NULL;
f0101209:	b8 00 00 00 00       	mov    $0x0,%eax
f010120e:	eb e0                	jmp    f01011f0 <page_lookup+0x42>

f0101210 <tlb_invalidate>:
{
f0101210:	f3 0f 1e fb          	endbr32 
f0101214:	55                   	push   %ebp
f0101215:	89 e5                	mov    %esp,%ebp
f0101217:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f010121a:	e8 2b 51 00 00       	call   f010634a <cpunum>
f010121f:	6b c0 74             	imul   $0x74,%eax,%eax
f0101222:	83 b8 28 80 23 f0 00 	cmpl   $0x0,-0xfdc7fd8(%eax)
f0101229:	74 16                	je     f0101241 <tlb_invalidate+0x31>
f010122b:	e8 1a 51 00 00       	call   f010634a <cpunum>
f0101230:	6b c0 74             	imul   $0x74,%eax,%eax
f0101233:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f0101239:	8b 55 08             	mov    0x8(%ebp),%edx
f010123c:	39 50 60             	cmp    %edx,0x60(%eax)
f010123f:	75 06                	jne    f0101247 <tlb_invalidate+0x37>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101241:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101244:	0f 01 38             	invlpg (%eax)
}
f0101247:	c9                   	leave  
f0101248:	c3                   	ret    

f0101249 <page_remove>:
{
f0101249:	f3 0f 1e fb          	endbr32 
f010124d:	55                   	push   %ebp
f010124e:	89 e5                	mov    %esp,%ebp
f0101250:	56                   	push   %esi
f0101251:	53                   	push   %ebx
f0101252:	83 ec 14             	sub    $0x14,%esp
f0101255:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101258:	8b 75 0c             	mov    0xc(%ebp),%esi
    struct PageInfo *pp = page_lookup(pgdir, va, &p_pte);
f010125b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010125e:	50                   	push   %eax
f010125f:	56                   	push   %esi
f0101260:	53                   	push   %ebx
f0101261:	e8 48 ff ff ff       	call   f01011ae <page_lookup>
    if ( pp == NULL ) {
f0101266:	83 c4 10             	add    $0x10,%esp
f0101269:	85 c0                	test   %eax,%eax
f010126b:	74 23                	je     f0101290 <page_remove+0x47>
    if (p_pte != NULL) {
f010126d:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101270:	85 d2                	test   %edx,%edx
f0101272:	74 06                	je     f010127a <page_remove+0x31>
        *p_pte = 0;
f0101274:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
    page_decref(pp);
f010127a:	83 ec 0c             	sub    $0xc,%esp
f010127d:	50                   	push   %eax
f010127e:	e8 fe fd ff ff       	call   f0101081 <page_decref>
    tlb_invalidate(pgdir, va);
f0101283:	83 c4 08             	add    $0x8,%esp
f0101286:	56                   	push   %esi
f0101287:	53                   	push   %ebx
f0101288:	e8 83 ff ff ff       	call   f0101210 <tlb_invalidate>
f010128d:	83 c4 10             	add    $0x10,%esp
}
f0101290:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101293:	5b                   	pop    %ebx
f0101294:	5e                   	pop    %esi
f0101295:	5d                   	pop    %ebp
f0101296:	c3                   	ret    

f0101297 <page_insert>:
{
f0101297:	f3 0f 1e fb          	endbr32 
f010129b:	55                   	push   %ebp
f010129c:	89 e5                	mov    %esp,%ebp
f010129e:	57                   	push   %edi
f010129f:	56                   	push   %esi
f01012a0:	53                   	push   %ebx
f01012a1:	83 ec 10             	sub    $0x10,%esp
f01012a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01012a7:	8b 7d 10             	mov    0x10(%ebp),%edi
    pte_t *p_pte = pgdir_walk(pgdir, va, 1);
f01012aa:	6a 01                	push   $0x1
f01012ac:	57                   	push   %edi
f01012ad:	ff 75 08             	pushl  0x8(%ebp)
f01012b0:	e8 f9 fd ff ff       	call   f01010ae <pgdir_walk>
    if (p_pte == NULL) {
f01012b5:	83 c4 10             	add    $0x10,%esp
f01012b8:	85 c0                	test   %eax,%eax
f01012ba:	74 4e                	je     f010130a <page_insert+0x73>
f01012bc:	89 c6                	mov    %eax,%esi
    pte_t pte = *p_pte;
f01012be:	8b 00                	mov    (%eax),%eax
    pp->pp_ref += 1;
f01012c0:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
    if (pte & PTE_P) {
f01012c5:	a8 01                	test   $0x1,%al
f01012c7:	75 30                	jne    f01012f9 <page_insert+0x62>
	return (pp - pages) << PGSHIFT;
f01012c9:	2b 1d 90 7e 23 f0    	sub    0xf0237e90,%ebx
f01012cf:	c1 fb 03             	sar    $0x3,%ebx
f01012d2:	c1 e3 0c             	shl    $0xc,%ebx
    *p_pte = (page2pa(pp) | perm | PTE_P);
f01012d5:	0b 5d 14             	or     0x14(%ebp),%ebx
f01012d8:	83 cb 01             	or     $0x1,%ebx
f01012db:	89 1e                	mov    %ebx,(%esi)
    tlb_invalidate(pgdir, va);
f01012dd:	83 ec 08             	sub    $0x8,%esp
f01012e0:	57                   	push   %edi
f01012e1:	ff 75 08             	pushl  0x8(%ebp)
f01012e4:	e8 27 ff ff ff       	call   f0101210 <tlb_invalidate>
	return 0;
f01012e9:	83 c4 10             	add    $0x10,%esp
f01012ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01012f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012f4:	5b                   	pop    %ebx
f01012f5:	5e                   	pop    %esi
f01012f6:	5f                   	pop    %edi
f01012f7:	5d                   	pop    %ebp
f01012f8:	c3                   	ret    
        page_remove(pgdir, va);
f01012f9:	83 ec 08             	sub    $0x8,%esp
f01012fc:	57                   	push   %edi
f01012fd:	ff 75 08             	pushl  0x8(%ebp)
f0101300:	e8 44 ff ff ff       	call   f0101249 <page_remove>
f0101305:	83 c4 10             	add    $0x10,%esp
f0101308:	eb bf                	jmp    f01012c9 <page_insert+0x32>
        return -E_NO_MEM;
f010130a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010130f:	eb e0                	jmp    f01012f1 <page_insert+0x5a>

f0101311 <mmio_map_region>:
{
f0101311:	f3 0f 1e fb          	endbr32 
f0101315:	55                   	push   %ebp
f0101316:	89 e5                	mov    %esp,%ebp
f0101318:	56                   	push   %esi
f0101319:	53                   	push   %ebx
f010131a:	8b 75 08             	mov    0x8(%ebp),%esi
    physaddr_t start_pa = ROUNDDOWN(pa, PGSIZE);
f010131d:	89 f0                	mov    %esi,%eax
f010131f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    physaddr_t end_pa = ROUNDUP(pa + size, PGSIZE);
f0101324:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101327:	8d 9c 16 ff 0f 00 00 	lea    0xfff(%esi,%edx,1),%ebx
    size_t alloc_size = end_pa - start_pa;
f010132e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0101334:	29 c3                	sub    %eax,%ebx
    boot_map_region(kern_pgdir, base, alloc_size, start_pa,
f0101336:	83 ec 08             	sub    $0x8,%esp
f0101339:	6a 1b                	push   $0x1b
f010133b:	50                   	push   %eax
f010133c:	89 d9                	mov    %ebx,%ecx
f010133e:	8b 15 00 33 12 f0    	mov    0xf0123300,%edx
f0101344:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
f0101349:	e8 f0 fd ff ff       	call   f010113e <boot_map_region>
    uintptr_t ret = base + pa_offset;
f010134e:	8b 15 00 33 12 f0    	mov    0xf0123300,%edx
    base = base + alloc_size;
f0101354:	01 d3                	add    %edx,%ebx
f0101356:	89 1d 00 33 12 f0    	mov    %ebx,0xf0123300
    physaddr_t pa_offset = pa & 0xfff;
f010135c:	89 f0                	mov    %esi,%eax
f010135e:	25 ff 0f 00 00       	and    $0xfff,%eax
    uintptr_t ret = base + pa_offset;
f0101363:	01 d0                	add    %edx,%eax
}
f0101365:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101368:	5b                   	pop    %ebx
f0101369:	5e                   	pop    %esi
f010136a:	5d                   	pop    %ebp
f010136b:	c3                   	ret    

f010136c <mem_init>:
{
f010136c:	f3 0f 1e fb          	endbr32 
f0101370:	55                   	push   %ebp
f0101371:	89 e5                	mov    %esp,%ebp
f0101373:	57                   	push   %edi
f0101374:	56                   	push   %esi
f0101375:	53                   	push   %ebx
f0101376:	83 ec 3c             	sub    $0x3c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f0101379:	b8 15 00 00 00       	mov    $0x15,%eax
f010137e:	e8 78 f7 ff ff       	call   f0100afb <nvram_read>
f0101383:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101385:	b8 17 00 00 00       	mov    $0x17,%eax
f010138a:	e8 6c f7 ff ff       	call   f0100afb <nvram_read>
f010138f:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101391:	b8 34 00 00 00       	mov    $0x34,%eax
f0101396:	e8 60 f7 ff ff       	call   f0100afb <nvram_read>
	if (ext16mem)
f010139b:	c1 e0 06             	shl    $0x6,%eax
f010139e:	0f 84 de 00 00 00    	je     f0101482 <mem_init+0x116>
		totalmem = 16 * 1024 + ext16mem;
f01013a4:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f01013a9:	89 c2                	mov    %eax,%edx
f01013ab:	c1 ea 02             	shr    $0x2,%edx
f01013ae:	89 15 88 7e 23 f0    	mov    %edx,0xf0237e88
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013b4:	89 c2                	mov    %eax,%edx
f01013b6:	29 da                	sub    %ebx,%edx
f01013b8:	52                   	push   %edx
f01013b9:	53                   	push   %ebx
f01013ba:	50                   	push   %eax
f01013bb:	68 8c 70 10 f0       	push   $0xf010708c
f01013c0:	e8 33 27 00 00       	call   f0103af8 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01013c5:	b8 00 10 00 00       	mov    $0x1000,%eax
f01013ca:	e8 b8 f7 ff ff       	call   f0100b87 <boot_alloc>
f01013cf:	a3 8c 7e 23 f0       	mov    %eax,0xf0237e8c
	memset(kern_pgdir, 0, PGSIZE);
f01013d4:	83 c4 0c             	add    $0xc,%esp
f01013d7:	68 00 10 00 00       	push   $0x1000
f01013dc:	6a 00                	push   $0x0
f01013de:	50                   	push   %eax
f01013df:	e8 48 49 00 00       	call   f0105d2c <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01013e4:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01013e9:	83 c4 10             	add    $0x10,%esp
f01013ec:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01013f1:	0f 86 9b 00 00 00    	jbe    f0101492 <mem_init+0x126>
	return (physaddr_t)kva - KERNBASE;
f01013f7:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01013fd:	83 ca 05             	or     $0x5,%edx
f0101400:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
    size_t alloc_size = ROUNDUP(sizeof(struct PageInfo) * npages, PGSIZE);
f0101406:	a1 88 7e 23 f0       	mov    0xf0237e88,%eax
f010140b:	8d 1c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ebx
f0101412:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    pages = (struct PageInfo *) boot_alloc(alloc_size);
f0101418:	89 d8                	mov    %ebx,%eax
f010141a:	e8 68 f7 ff ff       	call   f0100b87 <boot_alloc>
f010141f:	a3 90 7e 23 f0       	mov    %eax,0xf0237e90
    memset(pages, 0, alloc_size);
f0101424:	83 ec 04             	sub    $0x4,%esp
f0101427:	53                   	push   %ebx
f0101428:	6a 00                	push   $0x0
f010142a:	50                   	push   %eax
f010142b:	e8 fc 48 00 00       	call   f0105d2c <memset>
    envs = (struct Env *) boot_alloc(alloc_size);
f0101430:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101435:	e8 4d f7 ff ff       	call   f0100b87 <boot_alloc>
f010143a:	a3 44 72 23 f0       	mov    %eax,0xf0237244
    memset(envs, 0, alloc_size);
f010143f:	83 c4 0c             	add    $0xc,%esp
f0101442:	68 00 f0 01 00       	push   $0x1f000
f0101447:	6a 00                	push   $0x0
f0101449:	50                   	push   %eax
f010144a:	e8 dd 48 00 00       	call   f0105d2c <memset>
	page_init();
f010144f:	e8 a9 fa ff ff       	call   f0100efd <page_init>
	check_page_free_list(1);
f0101454:	b8 01 00 00 00       	mov    $0x1,%eax
f0101459:	e8 b1 f7 ff ff       	call   f0100c0f <check_page_free_list>
	if (!pages)
f010145e:	83 c4 10             	add    $0x10,%esp
f0101461:	83 3d 90 7e 23 f0 00 	cmpl   $0x0,0xf0237e90
f0101468:	74 3d                	je     f01014a7 <mem_init+0x13b>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010146a:	a1 40 72 23 f0       	mov    0xf0237240,%eax
f010146f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0101476:	85 c0                	test   %eax,%eax
f0101478:	74 44                	je     f01014be <mem_init+0x152>
		++nfree;
f010147a:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010147e:	8b 00                	mov    (%eax),%eax
f0101480:	eb f4                	jmp    f0101476 <mem_init+0x10a>
		totalmem = 1 * 1024 + extmem;
f0101482:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101488:	85 f6                	test   %esi,%esi
f010148a:	0f 44 c3             	cmove  %ebx,%eax
f010148d:	e9 17 ff ff ff       	jmp    f01013a9 <mem_init+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101492:	50                   	push   %eax
f0101493:	68 08 6a 10 f0       	push   $0xf0106a08
f0101498:	68 a3 00 00 00       	push   $0xa3
f010149d:	68 a5 78 10 f0       	push   $0xf01078a5
f01014a2:	e8 99 eb ff ff       	call   f0100040 <_panic>
		panic("'pages' is a null pointer!");
f01014a7:	83 ec 04             	sub    $0x4,%esp
f01014aa:	68 93 79 10 f0       	push   $0xf0107993
f01014af:	68 4f 03 00 00       	push   $0x34f
f01014b4:	68 a5 78 10 f0       	push   $0xf01078a5
f01014b9:	e8 82 eb ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f01014be:	83 ec 0c             	sub    $0xc,%esp
f01014c1:	6a 00                	push   $0x0
f01014c3:	e8 01 fb ff ff       	call   f0100fc9 <page_alloc>
f01014c8:	89 c3                	mov    %eax,%ebx
f01014ca:	83 c4 10             	add    $0x10,%esp
f01014cd:	85 c0                	test   %eax,%eax
f01014cf:	0f 84 11 02 00 00    	je     f01016e6 <mem_init+0x37a>
	assert((pp1 = page_alloc(0)));
f01014d5:	83 ec 0c             	sub    $0xc,%esp
f01014d8:	6a 00                	push   $0x0
f01014da:	e8 ea fa ff ff       	call   f0100fc9 <page_alloc>
f01014df:	89 c6                	mov    %eax,%esi
f01014e1:	83 c4 10             	add    $0x10,%esp
f01014e4:	85 c0                	test   %eax,%eax
f01014e6:	0f 84 13 02 00 00    	je     f01016ff <mem_init+0x393>
	assert((pp2 = page_alloc(0)));
f01014ec:	83 ec 0c             	sub    $0xc,%esp
f01014ef:	6a 00                	push   $0x0
f01014f1:	e8 d3 fa ff ff       	call   f0100fc9 <page_alloc>
f01014f6:	89 c7                	mov    %eax,%edi
f01014f8:	83 c4 10             	add    $0x10,%esp
f01014fb:	85 c0                	test   %eax,%eax
f01014fd:	0f 84 15 02 00 00    	je     f0101718 <mem_init+0x3ac>
	assert(pp1 && pp1 != pp0);
f0101503:	39 f3                	cmp    %esi,%ebx
f0101505:	0f 84 26 02 00 00    	je     f0101731 <mem_init+0x3c5>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010150b:	39 c3                	cmp    %eax,%ebx
f010150d:	0f 84 37 02 00 00    	je     f010174a <mem_init+0x3de>
f0101513:	39 c6                	cmp    %eax,%esi
f0101515:	0f 84 2f 02 00 00    	je     f010174a <mem_init+0x3de>
	return (pp - pages) << PGSHIFT;
f010151b:	8b 0d 90 7e 23 f0    	mov    0xf0237e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101521:	8b 15 88 7e 23 f0    	mov    0xf0237e88,%edx
f0101527:	c1 e2 0c             	shl    $0xc,%edx
f010152a:	89 d8                	mov    %ebx,%eax
f010152c:	29 c8                	sub    %ecx,%eax
f010152e:	c1 f8 03             	sar    $0x3,%eax
f0101531:	c1 e0 0c             	shl    $0xc,%eax
f0101534:	39 d0                	cmp    %edx,%eax
f0101536:	0f 83 27 02 00 00    	jae    f0101763 <mem_init+0x3f7>
f010153c:	89 f0                	mov    %esi,%eax
f010153e:	29 c8                	sub    %ecx,%eax
f0101540:	c1 f8 03             	sar    $0x3,%eax
f0101543:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101546:	39 c2                	cmp    %eax,%edx
f0101548:	0f 86 2e 02 00 00    	jbe    f010177c <mem_init+0x410>
f010154e:	89 f8                	mov    %edi,%eax
f0101550:	29 c8                	sub    %ecx,%eax
f0101552:	c1 f8 03             	sar    $0x3,%eax
f0101555:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101558:	39 c2                	cmp    %eax,%edx
f010155a:	0f 86 35 02 00 00    	jbe    f0101795 <mem_init+0x429>
	fl = page_free_list;
f0101560:	a1 40 72 23 f0       	mov    0xf0237240,%eax
f0101565:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101568:	c7 05 40 72 23 f0 00 	movl   $0x0,0xf0237240
f010156f:	00 00 00 
	assert(!page_alloc(0));
f0101572:	83 ec 0c             	sub    $0xc,%esp
f0101575:	6a 00                	push   $0x0
f0101577:	e8 4d fa ff ff       	call   f0100fc9 <page_alloc>
f010157c:	83 c4 10             	add    $0x10,%esp
f010157f:	85 c0                	test   %eax,%eax
f0101581:	0f 85 27 02 00 00    	jne    f01017ae <mem_init+0x442>
	page_free(pp0);
f0101587:	83 ec 0c             	sub    $0xc,%esp
f010158a:	53                   	push   %ebx
f010158b:	e8 b2 fa ff ff       	call   f0101042 <page_free>
	page_free(pp1);
f0101590:	89 34 24             	mov    %esi,(%esp)
f0101593:	e8 aa fa ff ff       	call   f0101042 <page_free>
	page_free(pp2);
f0101598:	89 3c 24             	mov    %edi,(%esp)
f010159b:	e8 a2 fa ff ff       	call   f0101042 <page_free>
	assert((pp0 = page_alloc(0)));
f01015a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015a7:	e8 1d fa ff ff       	call   f0100fc9 <page_alloc>
f01015ac:	89 c3                	mov    %eax,%ebx
f01015ae:	83 c4 10             	add    $0x10,%esp
f01015b1:	85 c0                	test   %eax,%eax
f01015b3:	0f 84 0e 02 00 00    	je     f01017c7 <mem_init+0x45b>
	assert((pp1 = page_alloc(0)));
f01015b9:	83 ec 0c             	sub    $0xc,%esp
f01015bc:	6a 00                	push   $0x0
f01015be:	e8 06 fa ff ff       	call   f0100fc9 <page_alloc>
f01015c3:	89 c6                	mov    %eax,%esi
f01015c5:	83 c4 10             	add    $0x10,%esp
f01015c8:	85 c0                	test   %eax,%eax
f01015ca:	0f 84 10 02 00 00    	je     f01017e0 <mem_init+0x474>
	assert((pp2 = page_alloc(0)));
f01015d0:	83 ec 0c             	sub    $0xc,%esp
f01015d3:	6a 00                	push   $0x0
f01015d5:	e8 ef f9 ff ff       	call   f0100fc9 <page_alloc>
f01015da:	89 c7                	mov    %eax,%edi
f01015dc:	83 c4 10             	add    $0x10,%esp
f01015df:	85 c0                	test   %eax,%eax
f01015e1:	0f 84 12 02 00 00    	je     f01017f9 <mem_init+0x48d>
	assert(pp1 && pp1 != pp0);
f01015e7:	39 f3                	cmp    %esi,%ebx
f01015e9:	0f 84 23 02 00 00    	je     f0101812 <mem_init+0x4a6>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015ef:	39 c6                	cmp    %eax,%esi
f01015f1:	0f 84 34 02 00 00    	je     f010182b <mem_init+0x4bf>
f01015f7:	39 c3                	cmp    %eax,%ebx
f01015f9:	0f 84 2c 02 00 00    	je     f010182b <mem_init+0x4bf>
	assert(!page_alloc(0));
f01015ff:	83 ec 0c             	sub    $0xc,%esp
f0101602:	6a 00                	push   $0x0
f0101604:	e8 c0 f9 ff ff       	call   f0100fc9 <page_alloc>
f0101609:	83 c4 10             	add    $0x10,%esp
f010160c:	85 c0                	test   %eax,%eax
f010160e:	0f 85 30 02 00 00    	jne    f0101844 <mem_init+0x4d8>
f0101614:	89 d8                	mov    %ebx,%eax
f0101616:	2b 05 90 7e 23 f0    	sub    0xf0237e90,%eax
f010161c:	c1 f8 03             	sar    $0x3,%eax
f010161f:	89 c2                	mov    %eax,%edx
f0101621:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101624:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101629:	3b 05 88 7e 23 f0    	cmp    0xf0237e88,%eax
f010162f:	0f 83 28 02 00 00    	jae    f010185d <mem_init+0x4f1>
	memset(page2kva(pp0), 1, PGSIZE);
f0101635:	83 ec 04             	sub    $0x4,%esp
f0101638:	68 00 10 00 00       	push   $0x1000
f010163d:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f010163f:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101645:	52                   	push   %edx
f0101646:	e8 e1 46 00 00       	call   f0105d2c <memset>
	page_free(pp0);
f010164b:	89 1c 24             	mov    %ebx,(%esp)
f010164e:	e8 ef f9 ff ff       	call   f0101042 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101653:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010165a:	e8 6a f9 ff ff       	call   f0100fc9 <page_alloc>
f010165f:	83 c4 10             	add    $0x10,%esp
f0101662:	85 c0                	test   %eax,%eax
f0101664:	0f 84 05 02 00 00    	je     f010186f <mem_init+0x503>
	assert(pp && pp0 == pp);
f010166a:	39 c3                	cmp    %eax,%ebx
f010166c:	0f 85 16 02 00 00    	jne    f0101888 <mem_init+0x51c>
	return (pp - pages) << PGSHIFT;
f0101672:	2b 05 90 7e 23 f0    	sub    0xf0237e90,%eax
f0101678:	c1 f8 03             	sar    $0x3,%eax
f010167b:	89 c2                	mov    %eax,%edx
f010167d:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101680:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101685:	3b 05 88 7e 23 f0    	cmp    0xf0237e88,%eax
f010168b:	0f 83 10 02 00 00    	jae    f01018a1 <mem_init+0x535>
	return (void *)(pa + KERNBASE);
f0101691:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101697:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f010169d:	80 38 00             	cmpb   $0x0,(%eax)
f01016a0:	0f 85 0d 02 00 00    	jne    f01018b3 <mem_init+0x547>
f01016a6:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f01016a9:	39 d0                	cmp    %edx,%eax
f01016ab:	75 f0                	jne    f010169d <mem_init+0x331>
	page_free_list = fl;
f01016ad:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01016b0:	a3 40 72 23 f0       	mov    %eax,0xf0237240
	page_free(pp0);
f01016b5:	83 ec 0c             	sub    $0xc,%esp
f01016b8:	53                   	push   %ebx
f01016b9:	e8 84 f9 ff ff       	call   f0101042 <page_free>
	page_free(pp1);
f01016be:	89 34 24             	mov    %esi,(%esp)
f01016c1:	e8 7c f9 ff ff       	call   f0101042 <page_free>
	page_free(pp2);
f01016c6:	89 3c 24             	mov    %edi,(%esp)
f01016c9:	e8 74 f9 ff ff       	call   f0101042 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01016ce:	a1 40 72 23 f0       	mov    0xf0237240,%eax
f01016d3:	83 c4 10             	add    $0x10,%esp
f01016d6:	85 c0                	test   %eax,%eax
f01016d8:	0f 84 ee 01 00 00    	je     f01018cc <mem_init+0x560>
		--nfree;
f01016de:	83 6d d4 01          	subl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01016e2:	8b 00                	mov    (%eax),%eax
f01016e4:	eb f0                	jmp    f01016d6 <mem_init+0x36a>
	assert((pp0 = page_alloc(0)));
f01016e6:	68 ae 79 10 f0       	push   $0xf01079ae
f01016eb:	68 d9 78 10 f0       	push   $0xf01078d9
f01016f0:	68 57 03 00 00       	push   $0x357
f01016f5:	68 a5 78 10 f0       	push   $0xf01078a5
f01016fa:	e8 41 e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01016ff:	68 c4 79 10 f0       	push   $0xf01079c4
f0101704:	68 d9 78 10 f0       	push   $0xf01078d9
f0101709:	68 58 03 00 00       	push   $0x358
f010170e:	68 a5 78 10 f0       	push   $0xf01078a5
f0101713:	e8 28 e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101718:	68 da 79 10 f0       	push   $0xf01079da
f010171d:	68 d9 78 10 f0       	push   $0xf01078d9
f0101722:	68 59 03 00 00       	push   $0x359
f0101727:	68 a5 78 10 f0       	push   $0xf01078a5
f010172c:	e8 0f e9 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101731:	68 f0 79 10 f0       	push   $0xf01079f0
f0101736:	68 d9 78 10 f0       	push   $0xf01078d9
f010173b:	68 5c 03 00 00       	push   $0x35c
f0101740:	68 a5 78 10 f0       	push   $0xf01078a5
f0101745:	e8 f6 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010174a:	68 c8 70 10 f0       	push   $0xf01070c8
f010174f:	68 d9 78 10 f0       	push   $0xf01078d9
f0101754:	68 5d 03 00 00       	push   $0x35d
f0101759:	68 a5 78 10 f0       	push   $0xf01078a5
f010175e:	e8 dd e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101763:	68 02 7a 10 f0       	push   $0xf0107a02
f0101768:	68 d9 78 10 f0       	push   $0xf01078d9
f010176d:	68 5e 03 00 00       	push   $0x35e
f0101772:	68 a5 78 10 f0       	push   $0xf01078a5
f0101777:	e8 c4 e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f010177c:	68 1f 7a 10 f0       	push   $0xf0107a1f
f0101781:	68 d9 78 10 f0       	push   $0xf01078d9
f0101786:	68 5f 03 00 00       	push   $0x35f
f010178b:	68 a5 78 10 f0       	push   $0xf01078a5
f0101790:	e8 ab e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101795:	68 3c 7a 10 f0       	push   $0xf0107a3c
f010179a:	68 d9 78 10 f0       	push   $0xf01078d9
f010179f:	68 60 03 00 00       	push   $0x360
f01017a4:	68 a5 78 10 f0       	push   $0xf01078a5
f01017a9:	e8 92 e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01017ae:	68 59 7a 10 f0       	push   $0xf0107a59
f01017b3:	68 d9 78 10 f0       	push   $0xf01078d9
f01017b8:	68 67 03 00 00       	push   $0x367
f01017bd:	68 a5 78 10 f0       	push   $0xf01078a5
f01017c2:	e8 79 e8 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f01017c7:	68 ae 79 10 f0       	push   $0xf01079ae
f01017cc:	68 d9 78 10 f0       	push   $0xf01078d9
f01017d1:	68 6e 03 00 00       	push   $0x36e
f01017d6:	68 a5 78 10 f0       	push   $0xf01078a5
f01017db:	e8 60 e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01017e0:	68 c4 79 10 f0       	push   $0xf01079c4
f01017e5:	68 d9 78 10 f0       	push   $0xf01078d9
f01017ea:	68 6f 03 00 00       	push   $0x36f
f01017ef:	68 a5 78 10 f0       	push   $0xf01078a5
f01017f4:	e8 47 e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01017f9:	68 da 79 10 f0       	push   $0xf01079da
f01017fe:	68 d9 78 10 f0       	push   $0xf01078d9
f0101803:	68 70 03 00 00       	push   $0x370
f0101808:	68 a5 78 10 f0       	push   $0xf01078a5
f010180d:	e8 2e e8 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101812:	68 f0 79 10 f0       	push   $0xf01079f0
f0101817:	68 d9 78 10 f0       	push   $0xf01078d9
f010181c:	68 72 03 00 00       	push   $0x372
f0101821:	68 a5 78 10 f0       	push   $0xf01078a5
f0101826:	e8 15 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010182b:	68 c8 70 10 f0       	push   $0xf01070c8
f0101830:	68 d9 78 10 f0       	push   $0xf01078d9
f0101835:	68 73 03 00 00       	push   $0x373
f010183a:	68 a5 78 10 f0       	push   $0xf01078a5
f010183f:	e8 fc e7 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101844:	68 59 7a 10 f0       	push   $0xf0107a59
f0101849:	68 d9 78 10 f0       	push   $0xf01078d9
f010184e:	68 74 03 00 00       	push   $0x374
f0101853:	68 a5 78 10 f0       	push   $0xf01078a5
f0101858:	e8 e3 e7 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010185d:	52                   	push   %edx
f010185e:	68 e4 69 10 f0       	push   $0xf01069e4
f0101863:	6a 58                	push   $0x58
f0101865:	68 bf 78 10 f0       	push   $0xf01078bf
f010186a:	e8 d1 e7 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010186f:	68 68 7a 10 f0       	push   $0xf0107a68
f0101874:	68 d9 78 10 f0       	push   $0xf01078d9
f0101879:	68 79 03 00 00       	push   $0x379
f010187e:	68 a5 78 10 f0       	push   $0xf01078a5
f0101883:	e8 b8 e7 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101888:	68 86 7a 10 f0       	push   $0xf0107a86
f010188d:	68 d9 78 10 f0       	push   $0xf01078d9
f0101892:	68 7a 03 00 00       	push   $0x37a
f0101897:	68 a5 78 10 f0       	push   $0xf01078a5
f010189c:	e8 9f e7 ff ff       	call   f0100040 <_panic>
f01018a1:	52                   	push   %edx
f01018a2:	68 e4 69 10 f0       	push   $0xf01069e4
f01018a7:	6a 58                	push   $0x58
f01018a9:	68 bf 78 10 f0       	push   $0xf01078bf
f01018ae:	e8 8d e7 ff ff       	call   f0100040 <_panic>
		assert(c[i] == 0);
f01018b3:	68 96 7a 10 f0       	push   $0xf0107a96
f01018b8:	68 d9 78 10 f0       	push   $0xf01078d9
f01018bd:	68 7d 03 00 00       	push   $0x37d
f01018c2:	68 a5 78 10 f0       	push   $0xf01078a5
f01018c7:	e8 74 e7 ff ff       	call   f0100040 <_panic>
	assert(nfree == 0);
f01018cc:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01018d0:	0f 85 e4 09 00 00    	jne    f01022ba <mem_init+0xf4e>
	cprintf("check_page_alloc() succeeded!\n");
f01018d6:	83 ec 0c             	sub    $0xc,%esp
f01018d9:	68 e8 70 10 f0       	push   $0xf01070e8
f01018de:	e8 15 22 00 00       	call   f0103af8 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01018e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018ea:	e8 da f6 ff ff       	call   f0100fc9 <page_alloc>
f01018ef:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01018f2:	83 c4 10             	add    $0x10,%esp
f01018f5:	85 c0                	test   %eax,%eax
f01018f7:	0f 84 d6 09 00 00    	je     f01022d3 <mem_init+0xf67>
	assert((pp1 = page_alloc(0)));
f01018fd:	83 ec 0c             	sub    $0xc,%esp
f0101900:	6a 00                	push   $0x0
f0101902:	e8 c2 f6 ff ff       	call   f0100fc9 <page_alloc>
f0101907:	89 c7                	mov    %eax,%edi
f0101909:	83 c4 10             	add    $0x10,%esp
f010190c:	85 c0                	test   %eax,%eax
f010190e:	0f 84 d8 09 00 00    	je     f01022ec <mem_init+0xf80>
	assert((pp2 = page_alloc(0)));
f0101914:	83 ec 0c             	sub    $0xc,%esp
f0101917:	6a 00                	push   $0x0
f0101919:	e8 ab f6 ff ff       	call   f0100fc9 <page_alloc>
f010191e:	89 c3                	mov    %eax,%ebx
f0101920:	83 c4 10             	add    $0x10,%esp
f0101923:	85 c0                	test   %eax,%eax
f0101925:	0f 84 da 09 00 00    	je     f0102305 <mem_init+0xf99>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010192b:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f010192e:	0f 84 ea 09 00 00    	je     f010231e <mem_init+0xfb2>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101934:	39 c7                	cmp    %eax,%edi
f0101936:	0f 84 fb 09 00 00    	je     f0102337 <mem_init+0xfcb>
f010193c:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010193f:	0f 84 f2 09 00 00    	je     f0102337 <mem_init+0xfcb>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101945:	a1 40 72 23 f0       	mov    0xf0237240,%eax
f010194a:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f010194d:	c7 05 40 72 23 f0 00 	movl   $0x0,0xf0237240
f0101954:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101957:	83 ec 0c             	sub    $0xc,%esp
f010195a:	6a 00                	push   $0x0
f010195c:	e8 68 f6 ff ff       	call   f0100fc9 <page_alloc>
f0101961:	83 c4 10             	add    $0x10,%esp
f0101964:	85 c0                	test   %eax,%eax
f0101966:	0f 85 e4 09 00 00    	jne    f0102350 <mem_init+0xfe4>

    // there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010196c:	83 ec 04             	sub    $0x4,%esp
f010196f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101972:	50                   	push   %eax
f0101973:	6a 00                	push   $0x0
f0101975:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f010197b:	e8 2e f8 ff ff       	call   f01011ae <page_lookup>
f0101980:	83 c4 10             	add    $0x10,%esp
f0101983:	85 c0                	test   %eax,%eax
f0101985:	0f 85 de 09 00 00    	jne    f0102369 <mem_init+0xffd>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010198b:	6a 02                	push   $0x2
f010198d:	6a 00                	push   $0x0
f010198f:	57                   	push   %edi
f0101990:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f0101996:	e8 fc f8 ff ff       	call   f0101297 <page_insert>
f010199b:	83 c4 10             	add    $0x10,%esp
f010199e:	85 c0                	test   %eax,%eax
f01019a0:	0f 89 dc 09 00 00    	jns    f0102382 <mem_init+0x1016>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01019a6:	83 ec 0c             	sub    $0xc,%esp
f01019a9:	ff 75 d4             	pushl  -0x2c(%ebp)
f01019ac:	e8 91 f6 ff ff       	call   f0101042 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01019b1:	6a 02                	push   $0x2
f01019b3:	6a 00                	push   $0x0
f01019b5:	57                   	push   %edi
f01019b6:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f01019bc:	e8 d6 f8 ff ff       	call   f0101297 <page_insert>
f01019c1:	83 c4 20             	add    $0x20,%esp
f01019c4:	85 c0                	test   %eax,%eax
f01019c6:	0f 85 cf 09 00 00    	jne    f010239b <mem_init+0x102f>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01019cc:	8b 35 8c 7e 23 f0    	mov    0xf0237e8c,%esi
	return (pp - pages) << PGSHIFT;
f01019d2:	8b 0d 90 7e 23 f0    	mov    0xf0237e90,%ecx
f01019d8:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01019db:	8b 16                	mov    (%esi),%edx
f01019dd:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01019e3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019e6:	29 c8                	sub    %ecx,%eax
f01019e8:	c1 f8 03             	sar    $0x3,%eax
f01019eb:	c1 e0 0c             	shl    $0xc,%eax
f01019ee:	39 c2                	cmp    %eax,%edx
f01019f0:	0f 85 be 09 00 00    	jne    f01023b4 <mem_init+0x1048>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01019f6:	ba 00 00 00 00       	mov    $0x0,%edx
f01019fb:	89 f0                	mov    %esi,%eax
f01019fd:	e8 22 f1 ff ff       	call   f0100b24 <check_va2pa>
f0101a02:	89 c2                	mov    %eax,%edx
f0101a04:	89 f8                	mov    %edi,%eax
f0101a06:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101a09:	c1 f8 03             	sar    $0x3,%eax
f0101a0c:	c1 e0 0c             	shl    $0xc,%eax
f0101a0f:	39 c2                	cmp    %eax,%edx
f0101a11:	0f 85 b6 09 00 00    	jne    f01023cd <mem_init+0x1061>
	assert(pp1->pp_ref == 1);
f0101a17:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101a1c:	0f 85 c4 09 00 00    	jne    f01023e6 <mem_init+0x107a>
	assert(pp0->pp_ref == 1);
f0101a22:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a25:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101a2a:	0f 85 cf 09 00 00    	jne    f01023ff <mem_init+0x1093>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a30:	6a 02                	push   $0x2
f0101a32:	68 00 10 00 00       	push   $0x1000
f0101a37:	53                   	push   %ebx
f0101a38:	56                   	push   %esi
f0101a39:	e8 59 f8 ff ff       	call   f0101297 <page_insert>
f0101a3e:	83 c4 10             	add    $0x10,%esp
f0101a41:	85 c0                	test   %eax,%eax
f0101a43:	0f 85 cf 09 00 00    	jne    f0102418 <mem_init+0x10ac>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a49:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a4e:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
f0101a53:	e8 cc f0 ff ff       	call   f0100b24 <check_va2pa>
f0101a58:	89 c2                	mov    %eax,%edx
f0101a5a:	89 d8                	mov    %ebx,%eax
f0101a5c:	2b 05 90 7e 23 f0    	sub    0xf0237e90,%eax
f0101a62:	c1 f8 03             	sar    $0x3,%eax
f0101a65:	c1 e0 0c             	shl    $0xc,%eax
f0101a68:	39 c2                	cmp    %eax,%edx
f0101a6a:	0f 85 c1 09 00 00    	jne    f0102431 <mem_init+0x10c5>
	assert(pp2->pp_ref == 1);
f0101a70:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a75:	0f 85 cf 09 00 00    	jne    f010244a <mem_init+0x10de>

	// should be no free memory
	assert(!page_alloc(0));
f0101a7b:	83 ec 0c             	sub    $0xc,%esp
f0101a7e:	6a 00                	push   $0x0
f0101a80:	e8 44 f5 ff ff       	call   f0100fc9 <page_alloc>
f0101a85:	83 c4 10             	add    $0x10,%esp
f0101a88:	85 c0                	test   %eax,%eax
f0101a8a:	0f 85 d3 09 00 00    	jne    f0102463 <mem_init+0x10f7>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a90:	6a 02                	push   $0x2
f0101a92:	68 00 10 00 00       	push   $0x1000
f0101a97:	53                   	push   %ebx
f0101a98:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f0101a9e:	e8 f4 f7 ff ff       	call   f0101297 <page_insert>
f0101aa3:	83 c4 10             	add    $0x10,%esp
f0101aa6:	85 c0                	test   %eax,%eax
f0101aa8:	0f 85 ce 09 00 00    	jne    f010247c <mem_init+0x1110>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101aae:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ab3:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
f0101ab8:	e8 67 f0 ff ff       	call   f0100b24 <check_va2pa>
f0101abd:	89 c2                	mov    %eax,%edx
f0101abf:	89 d8                	mov    %ebx,%eax
f0101ac1:	2b 05 90 7e 23 f0    	sub    0xf0237e90,%eax
f0101ac7:	c1 f8 03             	sar    $0x3,%eax
f0101aca:	c1 e0 0c             	shl    $0xc,%eax
f0101acd:	39 c2                	cmp    %eax,%edx
f0101acf:	0f 85 c0 09 00 00    	jne    f0102495 <mem_init+0x1129>
	assert(pp2->pp_ref == 1);
f0101ad5:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ada:	0f 85 ce 09 00 00    	jne    f01024ae <mem_init+0x1142>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101ae0:	83 ec 0c             	sub    $0xc,%esp
f0101ae3:	6a 00                	push   $0x0
f0101ae5:	e8 df f4 ff ff       	call   f0100fc9 <page_alloc>
f0101aea:	83 c4 10             	add    $0x10,%esp
f0101aed:	85 c0                	test   %eax,%eax
f0101aef:	0f 85 d2 09 00 00    	jne    f01024c7 <mem_init+0x115b>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101af5:	8b 0d 8c 7e 23 f0    	mov    0xf0237e8c,%ecx
f0101afb:	8b 01                	mov    (%ecx),%eax
f0101afd:	89 c2                	mov    %eax,%edx
f0101aff:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101b05:	c1 e8 0c             	shr    $0xc,%eax
f0101b08:	3b 05 88 7e 23 f0    	cmp    0xf0237e88,%eax
f0101b0e:	0f 83 cc 09 00 00    	jae    f01024e0 <mem_init+0x1174>
	return (void *)(pa + KERNBASE);
f0101b14:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101b1a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101b1d:	83 ec 04             	sub    $0x4,%esp
f0101b20:	6a 00                	push   $0x0
f0101b22:	68 00 10 00 00       	push   $0x1000
f0101b27:	51                   	push   %ecx
f0101b28:	e8 81 f5 ff ff       	call   f01010ae <pgdir_walk>
f0101b2d:	89 c2                	mov    %eax,%edx
f0101b2f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101b32:	83 c0 04             	add    $0x4,%eax
f0101b35:	83 c4 10             	add    $0x10,%esp
f0101b38:	39 d0                	cmp    %edx,%eax
f0101b3a:	0f 85 b5 09 00 00    	jne    f01024f5 <mem_init+0x1189>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101b40:	6a 06                	push   $0x6
f0101b42:	68 00 10 00 00       	push   $0x1000
f0101b47:	53                   	push   %ebx
f0101b48:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f0101b4e:	e8 44 f7 ff ff       	call   f0101297 <page_insert>
f0101b53:	83 c4 10             	add    $0x10,%esp
f0101b56:	85 c0                	test   %eax,%eax
f0101b58:	0f 85 b0 09 00 00    	jne    f010250e <mem_init+0x11a2>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b5e:	8b 35 8c 7e 23 f0    	mov    0xf0237e8c,%esi
f0101b64:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b69:	89 f0                	mov    %esi,%eax
f0101b6b:	e8 b4 ef ff ff       	call   f0100b24 <check_va2pa>
f0101b70:	89 c2                	mov    %eax,%edx
	return (pp - pages) << PGSHIFT;
f0101b72:	89 d8                	mov    %ebx,%eax
f0101b74:	2b 05 90 7e 23 f0    	sub    0xf0237e90,%eax
f0101b7a:	c1 f8 03             	sar    $0x3,%eax
f0101b7d:	c1 e0 0c             	shl    $0xc,%eax
f0101b80:	39 c2                	cmp    %eax,%edx
f0101b82:	0f 85 9f 09 00 00    	jne    f0102527 <mem_init+0x11bb>
	assert(pp2->pp_ref == 1);
f0101b88:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101b8d:	0f 85 ad 09 00 00    	jne    f0102540 <mem_init+0x11d4>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101b93:	83 ec 04             	sub    $0x4,%esp
f0101b96:	6a 00                	push   $0x0
f0101b98:	68 00 10 00 00       	push   $0x1000
f0101b9d:	56                   	push   %esi
f0101b9e:	e8 0b f5 ff ff       	call   f01010ae <pgdir_walk>
f0101ba3:	83 c4 10             	add    $0x10,%esp
f0101ba6:	f6 00 04             	testb  $0x4,(%eax)
f0101ba9:	0f 84 aa 09 00 00    	je     f0102559 <mem_init+0x11ed>
	assert(kern_pgdir[0] & PTE_U);
f0101baf:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
f0101bb4:	f6 00 04             	testb  $0x4,(%eax)
f0101bb7:	0f 84 b5 09 00 00    	je     f0102572 <mem_init+0x1206>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101bbd:	6a 02                	push   $0x2
f0101bbf:	68 00 10 00 00       	push   $0x1000
f0101bc4:	53                   	push   %ebx
f0101bc5:	50                   	push   %eax
f0101bc6:	e8 cc f6 ff ff       	call   f0101297 <page_insert>
f0101bcb:	83 c4 10             	add    $0x10,%esp
f0101bce:	85 c0                	test   %eax,%eax
f0101bd0:	0f 85 b5 09 00 00    	jne    f010258b <mem_init+0x121f>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101bd6:	83 ec 04             	sub    $0x4,%esp
f0101bd9:	6a 00                	push   $0x0
f0101bdb:	68 00 10 00 00       	push   $0x1000
f0101be0:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f0101be6:	e8 c3 f4 ff ff       	call   f01010ae <pgdir_walk>
f0101beb:	83 c4 10             	add    $0x10,%esp
f0101bee:	f6 00 02             	testb  $0x2,(%eax)
f0101bf1:	0f 84 ad 09 00 00    	je     f01025a4 <mem_init+0x1238>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101bf7:	83 ec 04             	sub    $0x4,%esp
f0101bfa:	6a 00                	push   $0x0
f0101bfc:	68 00 10 00 00       	push   $0x1000
f0101c01:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f0101c07:	e8 a2 f4 ff ff       	call   f01010ae <pgdir_walk>
f0101c0c:	83 c4 10             	add    $0x10,%esp
f0101c0f:	f6 00 04             	testb  $0x4,(%eax)
f0101c12:	0f 85 a5 09 00 00    	jne    f01025bd <mem_init+0x1251>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101c18:	6a 02                	push   $0x2
f0101c1a:	68 00 00 40 00       	push   $0x400000
f0101c1f:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101c22:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f0101c28:	e8 6a f6 ff ff       	call   f0101297 <page_insert>
f0101c2d:	83 c4 10             	add    $0x10,%esp
f0101c30:	85 c0                	test   %eax,%eax
f0101c32:	0f 89 9e 09 00 00    	jns    f01025d6 <mem_init+0x126a>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101c38:	6a 02                	push   $0x2
f0101c3a:	68 00 10 00 00       	push   $0x1000
f0101c3f:	57                   	push   %edi
f0101c40:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f0101c46:	e8 4c f6 ff ff       	call   f0101297 <page_insert>
f0101c4b:	83 c4 10             	add    $0x10,%esp
f0101c4e:	85 c0                	test   %eax,%eax
f0101c50:	0f 85 99 09 00 00    	jne    f01025ef <mem_init+0x1283>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c56:	83 ec 04             	sub    $0x4,%esp
f0101c59:	6a 00                	push   $0x0
f0101c5b:	68 00 10 00 00       	push   $0x1000
f0101c60:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f0101c66:	e8 43 f4 ff ff       	call   f01010ae <pgdir_walk>
f0101c6b:	83 c4 10             	add    $0x10,%esp
f0101c6e:	f6 00 04             	testb  $0x4,(%eax)
f0101c71:	0f 85 91 09 00 00    	jne    f0102608 <mem_init+0x129c>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101c77:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
f0101c7c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101c7f:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c84:	e8 9b ee ff ff       	call   f0100b24 <check_va2pa>
f0101c89:	89 fe                	mov    %edi,%esi
f0101c8b:	2b 35 90 7e 23 f0    	sub    0xf0237e90,%esi
f0101c91:	c1 fe 03             	sar    $0x3,%esi
f0101c94:	c1 e6 0c             	shl    $0xc,%esi
f0101c97:	39 f0                	cmp    %esi,%eax
f0101c99:	0f 85 82 09 00 00    	jne    f0102621 <mem_init+0x12b5>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c9f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ca4:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101ca7:	e8 78 ee ff ff       	call   f0100b24 <check_va2pa>
f0101cac:	39 c6                	cmp    %eax,%esi
f0101cae:	0f 85 86 09 00 00    	jne    f010263a <mem_init+0x12ce>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101cb4:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0101cb9:	0f 85 94 09 00 00    	jne    f0102653 <mem_init+0x12e7>
	assert(pp2->pp_ref == 0);
f0101cbf:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101cc4:	0f 85 a2 09 00 00    	jne    f010266c <mem_init+0x1300>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101cca:	83 ec 0c             	sub    $0xc,%esp
f0101ccd:	6a 00                	push   $0x0
f0101ccf:	e8 f5 f2 ff ff       	call   f0100fc9 <page_alloc>
f0101cd4:	83 c4 10             	add    $0x10,%esp
f0101cd7:	39 c3                	cmp    %eax,%ebx
f0101cd9:	0f 85 a6 09 00 00    	jne    f0102685 <mem_init+0x1319>
f0101cdf:	85 c0                	test   %eax,%eax
f0101ce1:	0f 84 9e 09 00 00    	je     f0102685 <mem_init+0x1319>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101ce7:	83 ec 08             	sub    $0x8,%esp
f0101cea:	6a 00                	push   $0x0
f0101cec:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f0101cf2:	e8 52 f5 ff ff       	call   f0101249 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101cf7:	8b 35 8c 7e 23 f0    	mov    0xf0237e8c,%esi
f0101cfd:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d02:	89 f0                	mov    %esi,%eax
f0101d04:	e8 1b ee ff ff       	call   f0100b24 <check_va2pa>
f0101d09:	83 c4 10             	add    $0x10,%esp
f0101d0c:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d0f:	0f 85 89 09 00 00    	jne    f010269e <mem_init+0x1332>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101d15:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d1a:	89 f0                	mov    %esi,%eax
f0101d1c:	e8 03 ee ff ff       	call   f0100b24 <check_va2pa>
f0101d21:	89 c2                	mov    %eax,%edx
f0101d23:	89 f8                	mov    %edi,%eax
f0101d25:	2b 05 90 7e 23 f0    	sub    0xf0237e90,%eax
f0101d2b:	c1 f8 03             	sar    $0x3,%eax
f0101d2e:	c1 e0 0c             	shl    $0xc,%eax
f0101d31:	39 c2                	cmp    %eax,%edx
f0101d33:	0f 85 7e 09 00 00    	jne    f01026b7 <mem_init+0x134b>
	assert(pp1->pp_ref == 1);
f0101d39:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101d3e:	0f 85 8c 09 00 00    	jne    f01026d0 <mem_init+0x1364>
	assert(pp2->pp_ref == 0);
f0101d44:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d49:	0f 85 9a 09 00 00    	jne    f01026e9 <mem_init+0x137d>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101d4f:	6a 00                	push   $0x0
f0101d51:	68 00 10 00 00       	push   $0x1000
f0101d56:	57                   	push   %edi
f0101d57:	56                   	push   %esi
f0101d58:	e8 3a f5 ff ff       	call   f0101297 <page_insert>
f0101d5d:	83 c4 10             	add    $0x10,%esp
f0101d60:	85 c0                	test   %eax,%eax
f0101d62:	0f 85 9a 09 00 00    	jne    f0102702 <mem_init+0x1396>
	assert(pp1->pp_ref);
f0101d68:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101d6d:	0f 84 a8 09 00 00    	je     f010271b <mem_init+0x13af>
	assert(pp1->pp_link == NULL);
f0101d73:	83 3f 00             	cmpl   $0x0,(%edi)
f0101d76:	0f 85 b8 09 00 00    	jne    f0102734 <mem_init+0x13c8>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101d7c:	83 ec 08             	sub    $0x8,%esp
f0101d7f:	68 00 10 00 00       	push   $0x1000
f0101d84:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f0101d8a:	e8 ba f4 ff ff       	call   f0101249 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d8f:	8b 35 8c 7e 23 f0    	mov    0xf0237e8c,%esi
f0101d95:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d9a:	89 f0                	mov    %esi,%eax
f0101d9c:	e8 83 ed ff ff       	call   f0100b24 <check_va2pa>
f0101da1:	83 c4 10             	add    $0x10,%esp
f0101da4:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101da7:	0f 85 a0 09 00 00    	jne    f010274d <mem_init+0x13e1>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101dad:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101db2:	89 f0                	mov    %esi,%eax
f0101db4:	e8 6b ed ff ff       	call   f0100b24 <check_va2pa>
f0101db9:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101dbc:	0f 85 a4 09 00 00    	jne    f0102766 <mem_init+0x13fa>
	assert(pp1->pp_ref == 0);
f0101dc2:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101dc7:	0f 85 b2 09 00 00    	jne    f010277f <mem_init+0x1413>
	assert(pp2->pp_ref == 0);
f0101dcd:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101dd2:	0f 85 c0 09 00 00    	jne    f0102798 <mem_init+0x142c>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101dd8:	83 ec 0c             	sub    $0xc,%esp
f0101ddb:	6a 00                	push   $0x0
f0101ddd:	e8 e7 f1 ff ff       	call   f0100fc9 <page_alloc>
f0101de2:	83 c4 10             	add    $0x10,%esp
f0101de5:	85 c0                	test   %eax,%eax
f0101de7:	0f 84 c4 09 00 00    	je     f01027b1 <mem_init+0x1445>
f0101ded:	39 c7                	cmp    %eax,%edi
f0101def:	0f 85 bc 09 00 00    	jne    f01027b1 <mem_init+0x1445>

	// should be no free memory
	assert(!page_alloc(0));
f0101df5:	83 ec 0c             	sub    $0xc,%esp
f0101df8:	6a 00                	push   $0x0
f0101dfa:	e8 ca f1 ff ff       	call   f0100fc9 <page_alloc>
f0101dff:	83 c4 10             	add    $0x10,%esp
f0101e02:	85 c0                	test   %eax,%eax
f0101e04:	0f 85 c0 09 00 00    	jne    f01027ca <mem_init+0x145e>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101e0a:	8b 0d 8c 7e 23 f0    	mov    0xf0237e8c,%ecx
f0101e10:	8b 11                	mov    (%ecx),%edx
f0101e12:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101e18:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e1b:	2b 05 90 7e 23 f0    	sub    0xf0237e90,%eax
f0101e21:	c1 f8 03             	sar    $0x3,%eax
f0101e24:	c1 e0 0c             	shl    $0xc,%eax
f0101e27:	39 c2                	cmp    %eax,%edx
f0101e29:	0f 85 b4 09 00 00    	jne    f01027e3 <mem_init+0x1477>
	kern_pgdir[0] = 0;
f0101e2f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101e35:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e38:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101e3d:	0f 85 b9 09 00 00    	jne    f01027fc <mem_init+0x1490>
	pp0->pp_ref = 0;
f0101e43:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e46:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101e4c:	83 ec 0c             	sub    $0xc,%esp
f0101e4f:	50                   	push   %eax
f0101e50:	e8 ed f1 ff ff       	call   f0101042 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101e55:	83 c4 0c             	add    $0xc,%esp
f0101e58:	6a 01                	push   $0x1
f0101e5a:	68 00 10 40 00       	push   $0x401000
f0101e5f:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f0101e65:	e8 44 f2 ff ff       	call   f01010ae <pgdir_walk>
f0101e6a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101e6d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101e70:	8b 0d 8c 7e 23 f0    	mov    0xf0237e8c,%ecx
f0101e76:	8b 41 04             	mov    0x4(%ecx),%eax
f0101e79:	89 c6                	mov    %eax,%esi
f0101e7b:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f0101e81:	8b 15 88 7e 23 f0    	mov    0xf0237e88,%edx
f0101e87:	c1 e8 0c             	shr    $0xc,%eax
f0101e8a:	83 c4 10             	add    $0x10,%esp
f0101e8d:	39 d0                	cmp    %edx,%eax
f0101e8f:	0f 83 80 09 00 00    	jae    f0102815 <mem_init+0x14a9>
	assert(ptep == ptep1 + PTX(va));
f0101e95:	81 ee fc ff ff 0f    	sub    $0xffffffc,%esi
f0101e9b:	39 75 d0             	cmp    %esi,-0x30(%ebp)
f0101e9e:	0f 85 86 09 00 00    	jne    f010282a <mem_init+0x14be>
	kern_pgdir[PDX(va)] = 0;
f0101ea4:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0101eab:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101eae:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101eb4:	2b 05 90 7e 23 f0    	sub    0xf0237e90,%eax
f0101eba:	c1 f8 03             	sar    $0x3,%eax
f0101ebd:	89 c1                	mov    %eax,%ecx
f0101ebf:	c1 e1 0c             	shl    $0xc,%ecx
	if (PGNUM(pa) >= npages)
f0101ec2:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101ec7:	39 c2                	cmp    %eax,%edx
f0101ec9:	0f 86 74 09 00 00    	jbe    f0102843 <mem_init+0x14d7>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101ecf:	83 ec 04             	sub    $0x4,%esp
f0101ed2:	68 00 10 00 00       	push   $0x1000
f0101ed7:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101edc:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0101ee2:	51                   	push   %ecx
f0101ee3:	e8 44 3e 00 00       	call   f0105d2c <memset>
	page_free(pp0);
f0101ee8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101eeb:	89 34 24             	mov    %esi,(%esp)
f0101eee:	e8 4f f1 ff ff       	call   f0101042 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101ef3:	83 c4 0c             	add    $0xc,%esp
f0101ef6:	6a 01                	push   $0x1
f0101ef8:	6a 00                	push   $0x0
f0101efa:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f0101f00:	e8 a9 f1 ff ff       	call   f01010ae <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101f05:	89 f0                	mov    %esi,%eax
f0101f07:	2b 05 90 7e 23 f0    	sub    0xf0237e90,%eax
f0101f0d:	c1 f8 03             	sar    $0x3,%eax
f0101f10:	89 c2                	mov    %eax,%edx
f0101f12:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101f15:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101f1a:	83 c4 10             	add    $0x10,%esp
f0101f1d:	3b 05 88 7e 23 f0    	cmp    0xf0237e88,%eax
f0101f23:	0f 83 2c 09 00 00    	jae    f0102855 <mem_init+0x14e9>
	return (void *)(pa + KERNBASE);
f0101f29:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0101f2f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101f32:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101f38:	f6 00 01             	testb  $0x1,(%eax)
f0101f3b:	0f 85 26 09 00 00    	jne    f0102867 <mem_init+0x14fb>
f0101f41:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0101f44:	39 d0                	cmp    %edx,%eax
f0101f46:	75 f0                	jne    f0101f38 <mem_init+0xbcc>
	kern_pgdir[0] = 0;
f0101f48:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
f0101f4d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101f53:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f56:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101f5c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101f5f:	89 0d 40 72 23 f0    	mov    %ecx,0xf0237240

	// free the pages we took
	page_free(pp0);
f0101f65:	83 ec 0c             	sub    $0xc,%esp
f0101f68:	50                   	push   %eax
f0101f69:	e8 d4 f0 ff ff       	call   f0101042 <page_free>
	page_free(pp1);
f0101f6e:	89 3c 24             	mov    %edi,(%esp)
f0101f71:	e8 cc f0 ff ff       	call   f0101042 <page_free>
	page_free(pp2);
f0101f76:	89 1c 24             	mov    %ebx,(%esp)
f0101f79:	e8 c4 f0 ff ff       	call   f0101042 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0101f7e:	83 c4 08             	add    $0x8,%esp
f0101f81:	68 01 10 00 00       	push   $0x1001
f0101f86:	6a 00                	push   $0x0
f0101f88:	e8 84 f3 ff ff       	call   f0101311 <mmio_map_region>
f0101f8d:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0101f8f:	83 c4 08             	add    $0x8,%esp
f0101f92:	68 00 10 00 00       	push   $0x1000
f0101f97:	6a 00                	push   $0x0
f0101f99:	e8 73 f3 ff ff       	call   f0101311 <mmio_map_region>
f0101f9e:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0101fa0:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f0101fa6:	83 c4 10             	add    $0x10,%esp
f0101fa9:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0101faf:	0f 86 cb 08 00 00    	jbe    f0102880 <mem_init+0x1514>
f0101fb5:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101fba:	0f 87 c0 08 00 00    	ja     f0102880 <mem_init+0x1514>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0101fc0:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f0101fc6:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0101fcc:	0f 87 c7 08 00 00    	ja     f0102899 <mem_init+0x152d>
f0101fd2:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0101fd8:	0f 86 bb 08 00 00    	jbe    f0102899 <mem_init+0x152d>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0101fde:	89 da                	mov    %ebx,%edx
f0101fe0:	09 f2                	or     %esi,%edx
f0101fe2:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0101fe8:	0f 85 c4 08 00 00    	jne    f01028b2 <mem_init+0x1546>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f0101fee:	39 c6                	cmp    %eax,%esi
f0101ff0:	0f 82 d5 08 00 00    	jb     f01028cb <mem_init+0x155f>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0101ff6:	8b 3d 8c 7e 23 f0    	mov    0xf0237e8c,%edi
f0101ffc:	89 da                	mov    %ebx,%edx
f0101ffe:	89 f8                	mov    %edi,%eax
f0102000:	e8 1f eb ff ff       	call   f0100b24 <check_va2pa>
f0102005:	85 c0                	test   %eax,%eax
f0102007:	0f 85 d7 08 00 00    	jne    f01028e4 <mem_init+0x1578>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f010200d:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102013:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102016:	89 c2                	mov    %eax,%edx
f0102018:	89 f8                	mov    %edi,%eax
f010201a:	e8 05 eb ff ff       	call   f0100b24 <check_va2pa>
f010201f:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102024:	0f 85 d3 08 00 00    	jne    f01028fd <mem_init+0x1591>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f010202a:	89 f2                	mov    %esi,%edx
f010202c:	89 f8                	mov    %edi,%eax
f010202e:	e8 f1 ea ff ff       	call   f0100b24 <check_va2pa>
f0102033:	85 c0                	test   %eax,%eax
f0102035:	0f 85 db 08 00 00    	jne    f0102916 <mem_init+0x15aa>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f010203b:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102041:	89 f8                	mov    %edi,%eax
f0102043:	e8 dc ea ff ff       	call   f0100b24 <check_va2pa>
f0102048:	83 f8 ff             	cmp    $0xffffffff,%eax
f010204b:	0f 85 de 08 00 00    	jne    f010292f <mem_init+0x15c3>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102051:	83 ec 04             	sub    $0x4,%esp
f0102054:	6a 00                	push   $0x0
f0102056:	53                   	push   %ebx
f0102057:	57                   	push   %edi
f0102058:	e8 51 f0 ff ff       	call   f01010ae <pgdir_walk>
f010205d:	83 c4 10             	add    $0x10,%esp
f0102060:	f6 00 1a             	testb  $0x1a,(%eax)
f0102063:	0f 84 df 08 00 00    	je     f0102948 <mem_init+0x15dc>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102069:	83 ec 04             	sub    $0x4,%esp
f010206c:	6a 00                	push   $0x0
f010206e:	53                   	push   %ebx
f010206f:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f0102075:	e8 34 f0 ff ff       	call   f01010ae <pgdir_walk>
f010207a:	8b 00                	mov    (%eax),%eax
f010207c:	83 c4 10             	add    $0x10,%esp
f010207f:	83 e0 04             	and    $0x4,%eax
f0102082:	89 c7                	mov    %eax,%edi
f0102084:	0f 85 d7 08 00 00    	jne    f0102961 <mem_init+0x15f5>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f010208a:	83 ec 04             	sub    $0x4,%esp
f010208d:	6a 00                	push   $0x0
f010208f:	53                   	push   %ebx
f0102090:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f0102096:	e8 13 f0 ff ff       	call   f01010ae <pgdir_walk>
f010209b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f01020a1:	83 c4 0c             	add    $0xc,%esp
f01020a4:	6a 00                	push   $0x0
f01020a6:	ff 75 d4             	pushl  -0x2c(%ebp)
f01020a9:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f01020af:	e8 fa ef ff ff       	call   f01010ae <pgdir_walk>
f01020b4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f01020ba:	83 c4 0c             	add    $0xc,%esp
f01020bd:	6a 00                	push   $0x0
f01020bf:	56                   	push   %esi
f01020c0:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f01020c6:	e8 e3 ef ff ff       	call   f01010ae <pgdir_walk>
f01020cb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f01020d1:	c7 04 24 89 7b 10 f0 	movl   $0xf0107b89,(%esp)
f01020d8:	e8 1b 1a 00 00       	call   f0103af8 <cprintf>
    size_t pages_size = ROUNDUP(sizeof(struct PageInfo) * npages, PGSIZE);
f01020dd:	a1 88 7e 23 f0       	mov    0xf0237e88,%eax
f01020e2:	8d 1c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ebx
f01020e9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    boot_map_region(kern_pgdir, UPAGES, pages_size,
f01020ef:	a1 90 7e 23 f0       	mov    0xf0237e90,%eax
	if ((uint32_t)kva < KERNBASE)
f01020f4:	83 c4 10             	add    $0x10,%esp
f01020f7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020fc:	0f 86 78 08 00 00    	jbe    f010297a <mem_init+0x160e>
f0102102:	83 ec 08             	sub    $0x8,%esp
f0102105:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0102107:	05 00 00 00 10       	add    $0x10000000,%eax
f010210c:	50                   	push   %eax
f010210d:	89 d9                	mov    %ebx,%ecx
f010210f:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102114:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
f0102119:	e8 20 f0 ff ff       	call   f010113e <boot_map_region>
    boot_map_region(kern_pgdir, (uintptr_t)pages, pages_size,
f010211e:	8b 15 90 7e 23 f0    	mov    0xf0237e90,%edx
	if ((uint32_t)kva < KERNBASE)
f0102124:	83 c4 10             	add    $0x10,%esp
f0102127:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010212d:	0f 86 5c 08 00 00    	jbe    f010298f <mem_init+0x1623>
f0102133:	83 ec 08             	sub    $0x8,%esp
f0102136:	6a 03                	push   $0x3
	return (physaddr_t)kva - KERNBASE;
f0102138:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
f010213e:	50                   	push   %eax
f010213f:	89 d9                	mov    %ebx,%ecx
f0102141:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
f0102146:	e8 f3 ef ff ff       	call   f010113e <boot_map_region>
    boot_map_region(kern_pgdir, UENVS, alloc_size,
f010214b:	a1 44 72 23 f0       	mov    0xf0237244,%eax
	if ((uint32_t)kva < KERNBASE)
f0102150:	83 c4 10             	add    $0x10,%esp
f0102153:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102158:	0f 86 46 08 00 00    	jbe    f01029a4 <mem_init+0x1638>
f010215e:	83 ec 08             	sub    $0x8,%esp
f0102161:	6a 07                	push   $0x7
	return (physaddr_t)kva - KERNBASE;
f0102163:	05 00 00 00 10       	add    $0x10000000,%eax
f0102168:	50                   	push   %eax
f0102169:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f010216e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102173:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
f0102178:	e8 c1 ef ff ff       	call   f010113e <boot_map_region>
    boot_map_region(kern_pgdir, (uintptr_t)envs, alloc_size,
f010217d:	8b 15 44 72 23 f0    	mov    0xf0237244,%edx
	if ((uint32_t)kva < KERNBASE)
f0102183:	83 c4 10             	add    $0x10,%esp
f0102186:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010218c:	0f 86 27 08 00 00    	jbe    f01029b9 <mem_init+0x164d>
f0102192:	83 ec 08             	sub    $0x8,%esp
f0102195:	6a 03                	push   $0x3
	return (physaddr_t)kva - KERNBASE;
f0102197:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
f010219d:	50                   	push   %eax
f010219e:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f01021a3:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
f01021a8:	e8 91 ef ff ff       	call   f010113e <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f01021ad:	83 c4 10             	add    $0x10,%esp
f01021b0:	b8 00 90 11 f0       	mov    $0xf0119000,%eax
f01021b5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01021ba:	0f 86 0e 08 00 00    	jbe    f01029ce <mem_init+0x1662>
    boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE,
f01021c0:	83 ec 08             	sub    $0x8,%esp
f01021c3:	6a 03                	push   $0x3
f01021c5:	68 00 90 11 00       	push   $0x119000
f01021ca:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01021cf:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01021d4:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
f01021d9:	e8 60 ef ff ff       	call   f010113e <boot_map_region>
    boot_map_region(kern_pgdir, KERNBASE, -KERNBASE,
f01021de:	83 c4 08             	add    $0x8,%esp
f01021e1:	6a 03                	push   $0x3
f01021e3:	6a 00                	push   $0x0
f01021e5:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01021ea:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01021ef:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
f01021f4:	e8 45 ef ff ff       	call   f010113e <boot_map_region>
f01021f9:	c7 45 d0 00 90 23 f0 	movl   $0xf0239000,-0x30(%ebp)
f0102200:	83 c4 10             	add    $0x10,%esp
f0102203:	bb 00 90 23 f0       	mov    $0xf0239000,%ebx
f0102208:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f010220d:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102213:	0f 86 ca 07 00 00    	jbe    f01029e3 <mem_init+0x1677>
        boot_map_region(kern_pgdir, ith_top - KSTKSIZE, KSTKSIZE,
f0102219:	83 ec 08             	sub    $0x8,%esp
f010221c:	6a 03                	push   $0x3
f010221e:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102224:	50                   	push   %eax
f0102225:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010222a:	89 f2                	mov    %esi,%edx
f010222c:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
f0102231:	e8 08 ef ff ff       	call   f010113e <boot_map_region>
f0102236:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f010223c:	81 ee 00 00 01 00    	sub    $0x10000,%esi
    for (int i = 0; i < NCPU; ++i) {
f0102242:	83 c4 10             	add    $0x10,%esp
f0102245:	81 fb 00 90 27 f0    	cmp    $0xf0279000,%ebx
f010224b:	75 c0                	jne    f010220d <mem_init+0xea1>
	pgdir = kern_pgdir;
f010224d:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
f0102252:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102255:	a1 88 7e 23 f0       	mov    0xf0237e88,%eax
f010225a:	89 45 c0             	mov    %eax,-0x40(%ebp)
f010225d:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102264:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102269:	89 45 cc             	mov    %eax,-0x34(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010226c:	8b 35 90 7e 23 f0    	mov    0xf0237e90,%esi
f0102272:	89 75 c8             	mov    %esi,-0x38(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0102275:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f010227b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f010227e:	89 fb                	mov    %edi,%ebx
f0102280:	39 5d cc             	cmp    %ebx,-0x34(%ebp)
f0102283:	0f 86 9d 07 00 00    	jbe    f0102a26 <mem_init+0x16ba>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102289:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f010228f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102292:	e8 8d e8 ff ff       	call   f0100b24 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102297:	81 7d c8 ff ff ff ef 	cmpl   $0xefffffff,-0x38(%ebp)
f010229e:	0f 86 54 07 00 00    	jbe    f01029f8 <mem_init+0x168c>
f01022a4:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01022a7:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f01022aa:	39 d0                	cmp    %edx,%eax
f01022ac:	0f 85 5b 07 00 00    	jne    f0102a0d <mem_init+0x16a1>
	for (i = 0; i < n; i += PGSIZE)
f01022b2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01022b8:	eb c6                	jmp    f0102280 <mem_init+0xf14>
	assert(nfree == 0);
f01022ba:	68 a0 7a 10 f0       	push   $0xf0107aa0
f01022bf:	68 d9 78 10 f0       	push   $0xf01078d9
f01022c4:	68 8a 03 00 00       	push   $0x38a
f01022c9:	68 a5 78 10 f0       	push   $0xf01078a5
f01022ce:	e8 6d dd ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f01022d3:	68 ae 79 10 f0       	push   $0xf01079ae
f01022d8:	68 d9 78 10 f0       	push   $0xf01078d9
f01022dd:	68 f1 03 00 00       	push   $0x3f1
f01022e2:	68 a5 78 10 f0       	push   $0xf01078a5
f01022e7:	e8 54 dd ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01022ec:	68 c4 79 10 f0       	push   $0xf01079c4
f01022f1:	68 d9 78 10 f0       	push   $0xf01078d9
f01022f6:	68 f2 03 00 00       	push   $0x3f2
f01022fb:	68 a5 78 10 f0       	push   $0xf01078a5
f0102300:	e8 3b dd ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102305:	68 da 79 10 f0       	push   $0xf01079da
f010230a:	68 d9 78 10 f0       	push   $0xf01078d9
f010230f:	68 f3 03 00 00       	push   $0x3f3
f0102314:	68 a5 78 10 f0       	push   $0xf01078a5
f0102319:	e8 22 dd ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f010231e:	68 f0 79 10 f0       	push   $0xf01079f0
f0102323:	68 d9 78 10 f0       	push   $0xf01078d9
f0102328:	68 f6 03 00 00       	push   $0x3f6
f010232d:	68 a5 78 10 f0       	push   $0xf01078a5
f0102332:	e8 09 dd ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102337:	68 c8 70 10 f0       	push   $0xf01070c8
f010233c:	68 d9 78 10 f0       	push   $0xf01078d9
f0102341:	68 f7 03 00 00       	push   $0x3f7
f0102346:	68 a5 78 10 f0       	push   $0xf01078a5
f010234b:	e8 f0 dc ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102350:	68 59 7a 10 f0       	push   $0xf0107a59
f0102355:	68 d9 78 10 f0       	push   $0xf01078d9
f010235a:	68 fe 03 00 00       	push   $0x3fe
f010235f:	68 a5 78 10 f0       	push   $0xf01078a5
f0102364:	e8 d7 dc ff ff       	call   f0100040 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102369:	68 08 71 10 f0       	push   $0xf0107108
f010236e:	68 d9 78 10 f0       	push   $0xf01078d9
f0102373:	68 01 04 00 00       	push   $0x401
f0102378:	68 a5 78 10 f0       	push   $0xf01078a5
f010237d:	e8 be dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102382:	68 40 71 10 f0       	push   $0xf0107140
f0102387:	68 d9 78 10 f0       	push   $0xf01078d9
f010238c:	68 04 04 00 00       	push   $0x404
f0102391:	68 a5 78 10 f0       	push   $0xf01078a5
f0102396:	e8 a5 dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010239b:	68 70 71 10 f0       	push   $0xf0107170
f01023a0:	68 d9 78 10 f0       	push   $0xf01078d9
f01023a5:	68 08 04 00 00       	push   $0x408
f01023aa:	68 a5 78 10 f0       	push   $0xf01078a5
f01023af:	e8 8c dc ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01023b4:	68 a0 71 10 f0       	push   $0xf01071a0
f01023b9:	68 d9 78 10 f0       	push   $0xf01078d9
f01023be:	68 09 04 00 00       	push   $0x409
f01023c3:	68 a5 78 10 f0       	push   $0xf01078a5
f01023c8:	e8 73 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01023cd:	68 c8 71 10 f0       	push   $0xf01071c8
f01023d2:	68 d9 78 10 f0       	push   $0xf01078d9
f01023d7:	68 0a 04 00 00       	push   $0x40a
f01023dc:	68 a5 78 10 f0       	push   $0xf01078a5
f01023e1:	e8 5a dc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01023e6:	68 ab 7a 10 f0       	push   $0xf0107aab
f01023eb:	68 d9 78 10 f0       	push   $0xf01078d9
f01023f0:	68 0b 04 00 00       	push   $0x40b
f01023f5:	68 a5 78 10 f0       	push   $0xf01078a5
f01023fa:	e8 41 dc ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f01023ff:	68 bc 7a 10 f0       	push   $0xf0107abc
f0102404:	68 d9 78 10 f0       	push   $0xf01078d9
f0102409:	68 0c 04 00 00       	push   $0x40c
f010240e:	68 a5 78 10 f0       	push   $0xf01078a5
f0102413:	e8 28 dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102418:	68 f8 71 10 f0       	push   $0xf01071f8
f010241d:	68 d9 78 10 f0       	push   $0xf01078d9
f0102422:	68 0f 04 00 00       	push   $0x40f
f0102427:	68 a5 78 10 f0       	push   $0xf01078a5
f010242c:	e8 0f dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102431:	68 34 72 10 f0       	push   $0xf0107234
f0102436:	68 d9 78 10 f0       	push   $0xf01078d9
f010243b:	68 10 04 00 00       	push   $0x410
f0102440:	68 a5 78 10 f0       	push   $0xf01078a5
f0102445:	e8 f6 db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010244a:	68 cd 7a 10 f0       	push   $0xf0107acd
f010244f:	68 d9 78 10 f0       	push   $0xf01078d9
f0102454:	68 11 04 00 00       	push   $0x411
f0102459:	68 a5 78 10 f0       	push   $0xf01078a5
f010245e:	e8 dd db ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102463:	68 59 7a 10 f0       	push   $0xf0107a59
f0102468:	68 d9 78 10 f0       	push   $0xf01078d9
f010246d:	68 14 04 00 00       	push   $0x414
f0102472:	68 a5 78 10 f0       	push   $0xf01078a5
f0102477:	e8 c4 db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010247c:	68 f8 71 10 f0       	push   $0xf01071f8
f0102481:	68 d9 78 10 f0       	push   $0xf01078d9
f0102486:	68 17 04 00 00       	push   $0x417
f010248b:	68 a5 78 10 f0       	push   $0xf01078a5
f0102490:	e8 ab db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102495:	68 34 72 10 f0       	push   $0xf0107234
f010249a:	68 d9 78 10 f0       	push   $0xf01078d9
f010249f:	68 18 04 00 00       	push   $0x418
f01024a4:	68 a5 78 10 f0       	push   $0xf01078a5
f01024a9:	e8 92 db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01024ae:	68 cd 7a 10 f0       	push   $0xf0107acd
f01024b3:	68 d9 78 10 f0       	push   $0xf01078d9
f01024b8:	68 19 04 00 00       	push   $0x419
f01024bd:	68 a5 78 10 f0       	push   $0xf01078a5
f01024c2:	e8 79 db ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01024c7:	68 59 7a 10 f0       	push   $0xf0107a59
f01024cc:	68 d9 78 10 f0       	push   $0xf01078d9
f01024d1:	68 1d 04 00 00       	push   $0x41d
f01024d6:	68 a5 78 10 f0       	push   $0xf01078a5
f01024db:	e8 60 db ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024e0:	52                   	push   %edx
f01024e1:	68 e4 69 10 f0       	push   $0xf01069e4
f01024e6:	68 20 04 00 00       	push   $0x420
f01024eb:	68 a5 78 10 f0       	push   $0xf01078a5
f01024f0:	e8 4b db ff ff       	call   f0100040 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01024f5:	68 64 72 10 f0       	push   $0xf0107264
f01024fa:	68 d9 78 10 f0       	push   $0xf01078d9
f01024ff:	68 21 04 00 00       	push   $0x421
f0102504:	68 a5 78 10 f0       	push   $0xf01078a5
f0102509:	e8 32 db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010250e:	68 a4 72 10 f0       	push   $0xf01072a4
f0102513:	68 d9 78 10 f0       	push   $0xf01078d9
f0102518:	68 24 04 00 00       	push   $0x424
f010251d:	68 a5 78 10 f0       	push   $0xf01078a5
f0102522:	e8 19 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102527:	68 34 72 10 f0       	push   $0xf0107234
f010252c:	68 d9 78 10 f0       	push   $0xf01078d9
f0102531:	68 25 04 00 00       	push   $0x425
f0102536:	68 a5 78 10 f0       	push   $0xf01078a5
f010253b:	e8 00 db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102540:	68 cd 7a 10 f0       	push   $0xf0107acd
f0102545:	68 d9 78 10 f0       	push   $0xf01078d9
f010254a:	68 26 04 00 00       	push   $0x426
f010254f:	68 a5 78 10 f0       	push   $0xf01078a5
f0102554:	e8 e7 da ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102559:	68 e4 72 10 f0       	push   $0xf01072e4
f010255e:	68 d9 78 10 f0       	push   $0xf01078d9
f0102563:	68 27 04 00 00       	push   $0x427
f0102568:	68 a5 78 10 f0       	push   $0xf01078a5
f010256d:	e8 ce da ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102572:	68 de 7a 10 f0       	push   $0xf0107ade
f0102577:	68 d9 78 10 f0       	push   $0xf01078d9
f010257c:	68 28 04 00 00       	push   $0x428
f0102581:	68 a5 78 10 f0       	push   $0xf01078a5
f0102586:	e8 b5 da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010258b:	68 f8 71 10 f0       	push   $0xf01071f8
f0102590:	68 d9 78 10 f0       	push   $0xf01078d9
f0102595:	68 2b 04 00 00       	push   $0x42b
f010259a:	68 a5 78 10 f0       	push   $0xf01078a5
f010259f:	e8 9c da ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01025a4:	68 18 73 10 f0       	push   $0xf0107318
f01025a9:	68 d9 78 10 f0       	push   $0xf01078d9
f01025ae:	68 2c 04 00 00       	push   $0x42c
f01025b3:	68 a5 78 10 f0       	push   $0xf01078a5
f01025b8:	e8 83 da ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01025bd:	68 4c 73 10 f0       	push   $0xf010734c
f01025c2:	68 d9 78 10 f0       	push   $0xf01078d9
f01025c7:	68 2d 04 00 00       	push   $0x42d
f01025cc:	68 a5 78 10 f0       	push   $0xf01078a5
f01025d1:	e8 6a da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01025d6:	68 84 73 10 f0       	push   $0xf0107384
f01025db:	68 d9 78 10 f0       	push   $0xf01078d9
f01025e0:	68 30 04 00 00       	push   $0x430
f01025e5:	68 a5 78 10 f0       	push   $0xf01078a5
f01025ea:	e8 51 da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01025ef:	68 bc 73 10 f0       	push   $0xf01073bc
f01025f4:	68 d9 78 10 f0       	push   $0xf01078d9
f01025f9:	68 33 04 00 00       	push   $0x433
f01025fe:	68 a5 78 10 f0       	push   $0xf01078a5
f0102603:	e8 38 da ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102608:	68 4c 73 10 f0       	push   $0xf010734c
f010260d:	68 d9 78 10 f0       	push   $0xf01078d9
f0102612:	68 34 04 00 00       	push   $0x434
f0102617:	68 a5 78 10 f0       	push   $0xf01078a5
f010261c:	e8 1f da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102621:	68 f8 73 10 f0       	push   $0xf01073f8
f0102626:	68 d9 78 10 f0       	push   $0xf01078d9
f010262b:	68 37 04 00 00       	push   $0x437
f0102630:	68 a5 78 10 f0       	push   $0xf01078a5
f0102635:	e8 06 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010263a:	68 24 74 10 f0       	push   $0xf0107424
f010263f:	68 d9 78 10 f0       	push   $0xf01078d9
f0102644:	68 38 04 00 00       	push   $0x438
f0102649:	68 a5 78 10 f0       	push   $0xf01078a5
f010264e:	e8 ed d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 2);
f0102653:	68 f4 7a 10 f0       	push   $0xf0107af4
f0102658:	68 d9 78 10 f0       	push   $0xf01078d9
f010265d:	68 3a 04 00 00       	push   $0x43a
f0102662:	68 a5 78 10 f0       	push   $0xf01078a5
f0102667:	e8 d4 d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010266c:	68 05 7b 10 f0       	push   $0xf0107b05
f0102671:	68 d9 78 10 f0       	push   $0xf01078d9
f0102676:	68 3b 04 00 00       	push   $0x43b
f010267b:	68 a5 78 10 f0       	push   $0xf01078a5
f0102680:	e8 bb d9 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102685:	68 54 74 10 f0       	push   $0xf0107454
f010268a:	68 d9 78 10 f0       	push   $0xf01078d9
f010268f:	68 3e 04 00 00       	push   $0x43e
f0102694:	68 a5 78 10 f0       	push   $0xf01078a5
f0102699:	e8 a2 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010269e:	68 78 74 10 f0       	push   $0xf0107478
f01026a3:	68 d9 78 10 f0       	push   $0xf01078d9
f01026a8:	68 42 04 00 00       	push   $0x442
f01026ad:	68 a5 78 10 f0       	push   $0xf01078a5
f01026b2:	e8 89 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01026b7:	68 24 74 10 f0       	push   $0xf0107424
f01026bc:	68 d9 78 10 f0       	push   $0xf01078d9
f01026c1:	68 43 04 00 00       	push   $0x443
f01026c6:	68 a5 78 10 f0       	push   $0xf01078a5
f01026cb:	e8 70 d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01026d0:	68 ab 7a 10 f0       	push   $0xf0107aab
f01026d5:	68 d9 78 10 f0       	push   $0xf01078d9
f01026da:	68 44 04 00 00       	push   $0x444
f01026df:	68 a5 78 10 f0       	push   $0xf01078a5
f01026e4:	e8 57 d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01026e9:	68 05 7b 10 f0       	push   $0xf0107b05
f01026ee:	68 d9 78 10 f0       	push   $0xf01078d9
f01026f3:	68 45 04 00 00       	push   $0x445
f01026f8:	68 a5 78 10 f0       	push   $0xf01078a5
f01026fd:	e8 3e d9 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102702:	68 9c 74 10 f0       	push   $0xf010749c
f0102707:	68 d9 78 10 f0       	push   $0xf01078d9
f010270c:	68 48 04 00 00       	push   $0x448
f0102711:	68 a5 78 10 f0       	push   $0xf01078a5
f0102716:	e8 25 d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f010271b:	68 16 7b 10 f0       	push   $0xf0107b16
f0102720:	68 d9 78 10 f0       	push   $0xf01078d9
f0102725:	68 49 04 00 00       	push   $0x449
f010272a:	68 a5 78 10 f0       	push   $0xf01078a5
f010272f:	e8 0c d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102734:	68 22 7b 10 f0       	push   $0xf0107b22
f0102739:	68 d9 78 10 f0       	push   $0xf01078d9
f010273e:	68 4a 04 00 00       	push   $0x44a
f0102743:	68 a5 78 10 f0       	push   $0xf01078a5
f0102748:	e8 f3 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010274d:	68 78 74 10 f0       	push   $0xf0107478
f0102752:	68 d9 78 10 f0       	push   $0xf01078d9
f0102757:	68 4e 04 00 00       	push   $0x44e
f010275c:	68 a5 78 10 f0       	push   $0xf01078a5
f0102761:	e8 da d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102766:	68 d4 74 10 f0       	push   $0xf01074d4
f010276b:	68 d9 78 10 f0       	push   $0xf01078d9
f0102770:	68 4f 04 00 00       	push   $0x44f
f0102775:	68 a5 78 10 f0       	push   $0xf01078a5
f010277a:	e8 c1 d8 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010277f:	68 37 7b 10 f0       	push   $0xf0107b37
f0102784:	68 d9 78 10 f0       	push   $0xf01078d9
f0102789:	68 50 04 00 00       	push   $0x450
f010278e:	68 a5 78 10 f0       	push   $0xf01078a5
f0102793:	e8 a8 d8 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102798:	68 05 7b 10 f0       	push   $0xf0107b05
f010279d:	68 d9 78 10 f0       	push   $0xf01078d9
f01027a2:	68 51 04 00 00       	push   $0x451
f01027a7:	68 a5 78 10 f0       	push   $0xf01078a5
f01027ac:	e8 8f d8 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f01027b1:	68 fc 74 10 f0       	push   $0xf01074fc
f01027b6:	68 d9 78 10 f0       	push   $0xf01078d9
f01027bb:	68 54 04 00 00       	push   $0x454
f01027c0:	68 a5 78 10 f0       	push   $0xf01078a5
f01027c5:	e8 76 d8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01027ca:	68 59 7a 10 f0       	push   $0xf0107a59
f01027cf:	68 d9 78 10 f0       	push   $0xf01078d9
f01027d4:	68 57 04 00 00       	push   $0x457
f01027d9:	68 a5 78 10 f0       	push   $0xf01078a5
f01027de:	e8 5d d8 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01027e3:	68 a0 71 10 f0       	push   $0xf01071a0
f01027e8:	68 d9 78 10 f0       	push   $0xf01078d9
f01027ed:	68 5a 04 00 00       	push   $0x45a
f01027f2:	68 a5 78 10 f0       	push   $0xf01078a5
f01027f7:	e8 44 d8 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f01027fc:	68 bc 7a 10 f0       	push   $0xf0107abc
f0102801:	68 d9 78 10 f0       	push   $0xf01078d9
f0102806:	68 5c 04 00 00       	push   $0x45c
f010280b:	68 a5 78 10 f0       	push   $0xf01078a5
f0102810:	e8 2b d8 ff ff       	call   f0100040 <_panic>
f0102815:	56                   	push   %esi
f0102816:	68 e4 69 10 f0       	push   $0xf01069e4
f010281b:	68 63 04 00 00       	push   $0x463
f0102820:	68 a5 78 10 f0       	push   $0xf01078a5
f0102825:	e8 16 d8 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010282a:	68 48 7b 10 f0       	push   $0xf0107b48
f010282f:	68 d9 78 10 f0       	push   $0xf01078d9
f0102834:	68 64 04 00 00       	push   $0x464
f0102839:	68 a5 78 10 f0       	push   $0xf01078a5
f010283e:	e8 fd d7 ff ff       	call   f0100040 <_panic>
f0102843:	51                   	push   %ecx
f0102844:	68 e4 69 10 f0       	push   $0xf01069e4
f0102849:	6a 58                	push   $0x58
f010284b:	68 bf 78 10 f0       	push   $0xf01078bf
f0102850:	e8 eb d7 ff ff       	call   f0100040 <_panic>
f0102855:	52                   	push   %edx
f0102856:	68 e4 69 10 f0       	push   $0xf01069e4
f010285b:	6a 58                	push   $0x58
f010285d:	68 bf 78 10 f0       	push   $0xf01078bf
f0102862:	e8 d9 d7 ff ff       	call   f0100040 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102867:	68 60 7b 10 f0       	push   $0xf0107b60
f010286c:	68 d9 78 10 f0       	push   $0xf01078d9
f0102871:	68 6e 04 00 00       	push   $0x46e
f0102876:	68 a5 78 10 f0       	push   $0xf01078a5
f010287b:	e8 c0 d7 ff ff       	call   f0100040 <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0102880:	68 20 75 10 f0       	push   $0xf0107520
f0102885:	68 d9 78 10 f0       	push   $0xf01078d9
f010288a:	68 7e 04 00 00       	push   $0x47e
f010288f:	68 a5 78 10 f0       	push   $0xf01078a5
f0102894:	e8 a7 d7 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0102899:	68 48 75 10 f0       	push   $0xf0107548
f010289e:	68 d9 78 10 f0       	push   $0xf01078d9
f01028a3:	68 7f 04 00 00       	push   $0x47f
f01028a8:	68 a5 78 10 f0       	push   $0xf01078a5
f01028ad:	e8 8e d7 ff ff       	call   f0100040 <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01028b2:	68 70 75 10 f0       	push   $0xf0107570
f01028b7:	68 d9 78 10 f0       	push   $0xf01078d9
f01028bc:	68 81 04 00 00       	push   $0x481
f01028c1:	68 a5 78 10 f0       	push   $0xf01078a5
f01028c6:	e8 75 d7 ff ff       	call   f0100040 <_panic>
	assert(mm1 + 8192 <= mm2);
f01028cb:	68 77 7b 10 f0       	push   $0xf0107b77
f01028d0:	68 d9 78 10 f0       	push   $0xf01078d9
f01028d5:	68 83 04 00 00       	push   $0x483
f01028da:	68 a5 78 10 f0       	push   $0xf01078a5
f01028df:	e8 5c d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01028e4:	68 98 75 10 f0       	push   $0xf0107598
f01028e9:	68 d9 78 10 f0       	push   $0xf01078d9
f01028ee:	68 85 04 00 00       	push   $0x485
f01028f3:	68 a5 78 10 f0       	push   $0xf01078a5
f01028f8:	e8 43 d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01028fd:	68 bc 75 10 f0       	push   $0xf01075bc
f0102902:	68 d9 78 10 f0       	push   $0xf01078d9
f0102907:	68 86 04 00 00       	push   $0x486
f010290c:	68 a5 78 10 f0       	push   $0xf01078a5
f0102911:	e8 2a d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102916:	68 ec 75 10 f0       	push   $0xf01075ec
f010291b:	68 d9 78 10 f0       	push   $0xf01078d9
f0102920:	68 87 04 00 00       	push   $0x487
f0102925:	68 a5 78 10 f0       	push   $0xf01078a5
f010292a:	e8 11 d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f010292f:	68 10 76 10 f0       	push   $0xf0107610
f0102934:	68 d9 78 10 f0       	push   $0xf01078d9
f0102939:	68 88 04 00 00       	push   $0x488
f010293e:	68 a5 78 10 f0       	push   $0xf01078a5
f0102943:	e8 f8 d6 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102948:	68 3c 76 10 f0       	push   $0xf010763c
f010294d:	68 d9 78 10 f0       	push   $0xf01078d9
f0102952:	68 8a 04 00 00       	push   $0x48a
f0102957:	68 a5 78 10 f0       	push   $0xf01078a5
f010295c:	e8 df d6 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102961:	68 80 76 10 f0       	push   $0xf0107680
f0102966:	68 d9 78 10 f0       	push   $0xf01078d9
f010296b:	68 8b 04 00 00       	push   $0x48b
f0102970:	68 a5 78 10 f0       	push   $0xf01078a5
f0102975:	e8 c6 d6 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010297a:	50                   	push   %eax
f010297b:	68 08 6a 10 f0       	push   $0xf0106a08
f0102980:	68 cf 00 00 00       	push   $0xcf
f0102985:	68 a5 78 10 f0       	push   $0xf01078a5
f010298a:	e8 b1 d6 ff ff       	call   f0100040 <_panic>
f010298f:	52                   	push   %edx
f0102990:	68 08 6a 10 f0       	push   $0xf0106a08
f0102995:	68 d2 00 00 00       	push   $0xd2
f010299a:	68 a5 78 10 f0       	push   $0xf01078a5
f010299f:	e8 9c d6 ff ff       	call   f0100040 <_panic>
f01029a4:	50                   	push   %eax
f01029a5:	68 08 6a 10 f0       	push   $0xf0106a08
f01029aa:	68 de 00 00 00       	push   $0xde
f01029af:	68 a5 78 10 f0       	push   $0xf01078a5
f01029b4:	e8 87 d6 ff ff       	call   f0100040 <_panic>
f01029b9:	52                   	push   %edx
f01029ba:	68 08 6a 10 f0       	push   $0xf0106a08
f01029bf:	68 e0 00 00 00       	push   $0xe0
f01029c4:	68 a5 78 10 f0       	push   $0xf01078a5
f01029c9:	e8 72 d6 ff ff       	call   f0100040 <_panic>
f01029ce:	50                   	push   %eax
f01029cf:	68 08 6a 10 f0       	push   $0xf0106a08
f01029d4:	68 ee 00 00 00       	push   $0xee
f01029d9:	68 a5 78 10 f0       	push   $0xf01078a5
f01029de:	e8 5d d6 ff ff       	call   f0100040 <_panic>
f01029e3:	53                   	push   %ebx
f01029e4:	68 08 6a 10 f0       	push   $0xf0106a08
f01029e9:	68 32 01 00 00       	push   $0x132
f01029ee:	68 a5 78 10 f0       	push   $0xf01078a5
f01029f3:	e8 48 d6 ff ff       	call   f0100040 <_panic>
f01029f8:	56                   	push   %esi
f01029f9:	68 08 6a 10 f0       	push   $0xf0106a08
f01029fe:	68 a2 03 00 00       	push   $0x3a2
f0102a03:	68 a5 78 10 f0       	push   $0xf01078a5
f0102a08:	e8 33 d6 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102a0d:	68 b4 76 10 f0       	push   $0xf01076b4
f0102a12:	68 d9 78 10 f0       	push   $0xf01078d9
f0102a17:	68 a2 03 00 00       	push   $0x3a2
f0102a1c:	68 a5 78 10 f0       	push   $0xf01078a5
f0102a21:	e8 1a d6 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102a26:	a1 44 72 23 f0       	mov    0xf0237244,%eax
f0102a2b:	89 45 c8             	mov    %eax,-0x38(%ebp)
	if ((uint32_t)kva < KERNBASE)
f0102a2e:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102a31:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102a36:	8d b0 00 00 40 21    	lea    0x21400000(%eax),%esi
f0102a3c:	89 da                	mov    %ebx,%edx
f0102a3e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a41:	e8 de e0 ff ff       	call   f0100b24 <check_va2pa>
f0102a46:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102a4d:	76 3b                	jbe    f0102a8a <mem_init+0x171e>
f0102a4f:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102a52:	39 d0                	cmp    %edx,%eax
f0102a54:	75 4b                	jne    f0102aa1 <mem_init+0x1735>
f0102a56:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
f0102a5c:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102a62:	75 d8                	jne    f0102a3c <mem_init+0x16d0>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE) {
f0102a64:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0102a67:	c1 e6 0c             	shl    $0xc,%esi
f0102a6a:	89 fb                	mov    %edi,%ebx
f0102a6c:	39 f3                	cmp    %esi,%ebx
f0102a6e:	73 63                	jae    f0102ad3 <mem_init+0x1767>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102a70:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102a76:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a79:	e8 a6 e0 ff ff       	call   f0100b24 <check_va2pa>
f0102a7e:	39 c3                	cmp    %eax,%ebx
f0102a80:	75 38                	jne    f0102aba <mem_init+0x174e>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE) {
f0102a82:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102a88:	eb e2                	jmp    f0102a6c <mem_init+0x1700>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a8a:	ff 75 c8             	pushl  -0x38(%ebp)
f0102a8d:	68 08 6a 10 f0       	push   $0xf0106a08
f0102a92:	68 a7 03 00 00       	push   $0x3a7
f0102a97:	68 a5 78 10 f0       	push   $0xf01078a5
f0102a9c:	e8 9f d5 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102aa1:	68 e8 76 10 f0       	push   $0xf01076e8
f0102aa6:	68 d9 78 10 f0       	push   $0xf01078d9
f0102aab:	68 a7 03 00 00       	push   $0x3a7
f0102ab0:	68 a5 78 10 f0       	push   $0xf01078a5
f0102ab5:	e8 86 d5 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102aba:	68 1c 77 10 f0       	push   $0xf010771c
f0102abf:	68 d9 78 10 f0       	push   $0xf01078d9
f0102ac4:	68 ab 03 00 00       	push   $0x3ab
f0102ac9:	68 a5 78 10 f0       	push   $0xf01078a5
f0102ace:	e8 6d d5 ff ff       	call   f0100040 <_panic>
f0102ad3:	c7 45 cc 00 90 24 00 	movl   $0x249000,-0x34(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE) {
f0102ada:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
f0102adf:	89 7d c0             	mov    %edi,-0x40(%ebp)
f0102ae2:	8d bb 00 80 ff ff    	lea    -0x8000(%ebx),%edi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102ae8:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102aeb:	89 45 bc             	mov    %eax,-0x44(%ebp)
f0102aee:	89 de                	mov    %ebx,%esi
f0102af0:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102af3:	05 00 80 ff 0f       	add    $0xfff8000,%eax
f0102af8:	89 45 c8             	mov    %eax,-0x38(%ebp)
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102afb:	8d 83 00 80 00 00    	lea    0x8000(%ebx),%eax
f0102b01:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102b04:	89 f2                	mov    %esi,%edx
f0102b06:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b09:	e8 16 e0 ff ff       	call   f0100b24 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102b0e:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102b15:	76 58                	jbe    f0102b6f <mem_init+0x1803>
f0102b17:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102b1a:	8d 14 31             	lea    (%ecx,%esi,1),%edx
f0102b1d:	39 d0                	cmp    %edx,%eax
f0102b1f:	75 65                	jne    f0102b86 <mem_init+0x181a>
f0102b21:	81 c6 00 10 00 00    	add    $0x1000,%esi
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102b27:	3b 75 c4             	cmp    -0x3c(%ebp),%esi
f0102b2a:	75 d8                	jne    f0102b04 <mem_init+0x1798>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102b2c:	89 fa                	mov    %edi,%edx
f0102b2e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b31:	e8 ee df ff ff       	call   f0100b24 <check_va2pa>
f0102b36:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102b39:	75 64                	jne    f0102b9f <mem_init+0x1833>
f0102b3b:	81 c7 00 10 00 00    	add    $0x1000,%edi
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102b41:	39 df                	cmp    %ebx,%edi
f0102b43:	75 e7                	jne    f0102b2c <mem_init+0x17c0>
f0102b45:	81 eb 00 00 01 00    	sub    $0x10000,%ebx
f0102b4b:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
f0102b52:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102b55:	81 45 cc 00 80 01 00 	addl   $0x18000,-0x34(%ebp)
	for (n = 0; n < NCPU; n++) {
f0102b5c:	3d 00 90 27 f0       	cmp    $0xf0279000,%eax
f0102b61:	0f 85 7b ff ff ff    	jne    f0102ae2 <mem_init+0x1776>
f0102b67:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0102b6a:	e9 84 00 00 00       	jmp    f0102bf3 <mem_init+0x1887>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b6f:	ff 75 bc             	pushl  -0x44(%ebp)
f0102b72:	68 08 6a 10 f0       	push   $0xf0106a08
f0102b77:	68 b4 03 00 00       	push   $0x3b4
f0102b7c:	68 a5 78 10 f0       	push   $0xf01078a5
f0102b81:	e8 ba d4 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102b86:	68 44 77 10 f0       	push   $0xf0107744
f0102b8b:	68 d9 78 10 f0       	push   $0xf01078d9
f0102b90:	68 b3 03 00 00       	push   $0x3b3
f0102b95:	68 a5 78 10 f0       	push   $0xf01078a5
f0102b9a:	e8 a1 d4 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102b9f:	68 8c 77 10 f0       	push   $0xf010778c
f0102ba4:	68 d9 78 10 f0       	push   $0xf01078d9
f0102ba9:	68 b6 03 00 00       	push   $0x3b6
f0102bae:	68 a5 78 10 f0       	push   $0xf01078a5
f0102bb3:	e8 88 d4 ff ff       	call   f0100040 <_panic>
			assert(pgdir[i] & PTE_P);
f0102bb8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102bbb:	f6 04 b8 01          	testb  $0x1,(%eax,%edi,4)
f0102bbf:	75 4e                	jne    f0102c0f <mem_init+0x18a3>
f0102bc1:	68 a2 7b 10 f0       	push   $0xf0107ba2
f0102bc6:	68 d9 78 10 f0       	push   $0xf01078d9
f0102bcb:	68 c1 03 00 00       	push   $0x3c1
f0102bd0:	68 a5 78 10 f0       	push   $0xf01078a5
f0102bd5:	e8 66 d4 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_P);
f0102bda:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102bdd:	8b 04 b8             	mov    (%eax,%edi,4),%eax
f0102be0:	a8 01                	test   $0x1,%al
f0102be2:	74 30                	je     f0102c14 <mem_init+0x18a8>
				assert(pgdir[i] & PTE_W);
f0102be4:	a8 02                	test   $0x2,%al
f0102be6:	74 45                	je     f0102c2d <mem_init+0x18c1>
	for (i = 0; i < NPDENTRIES; i++) {
f0102be8:	83 c7 01             	add    $0x1,%edi
f0102beb:	81 ff 00 04 00 00    	cmp    $0x400,%edi
f0102bf1:	74 6c                	je     f0102c5f <mem_init+0x18f3>
		switch (i) {
f0102bf3:	8d 87 45 fc ff ff    	lea    -0x3bb(%edi),%eax
f0102bf9:	83 f8 04             	cmp    $0x4,%eax
f0102bfc:	76 ba                	jbe    f0102bb8 <mem_init+0x184c>
			if (i >= PDX(KERNBASE)) {
f0102bfe:	81 ff bf 03 00 00    	cmp    $0x3bf,%edi
f0102c04:	77 d4                	ja     f0102bda <mem_init+0x186e>
				assert(pgdir[i] == 0);
f0102c06:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c09:	83 3c b8 00          	cmpl   $0x0,(%eax,%edi,4)
f0102c0d:	75 37                	jne    f0102c46 <mem_init+0x18da>
	for (i = 0; i < NPDENTRIES; i++) {
f0102c0f:	83 c7 01             	add    $0x1,%edi
f0102c12:	eb df                	jmp    f0102bf3 <mem_init+0x1887>
				assert(pgdir[i] & PTE_P);
f0102c14:	68 a2 7b 10 f0       	push   $0xf0107ba2
f0102c19:	68 d9 78 10 f0       	push   $0xf01078d9
f0102c1e:	68 c5 03 00 00       	push   $0x3c5
f0102c23:	68 a5 78 10 f0       	push   $0xf01078a5
f0102c28:	e8 13 d4 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102c2d:	68 b3 7b 10 f0       	push   $0xf0107bb3
f0102c32:	68 d9 78 10 f0       	push   $0xf01078d9
f0102c37:	68 c6 03 00 00       	push   $0x3c6
f0102c3c:	68 a5 78 10 f0       	push   $0xf01078a5
f0102c41:	e8 fa d3 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] == 0);
f0102c46:	68 c4 7b 10 f0       	push   $0xf0107bc4
f0102c4b:	68 d9 78 10 f0       	push   $0xf01078d9
f0102c50:	68 c8 03 00 00       	push   $0x3c8
f0102c55:	68 a5 78 10 f0       	push   $0xf01078a5
f0102c5a:	e8 e1 d3 ff ff       	call   f0100040 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102c5f:	83 ec 0c             	sub    $0xc,%esp
f0102c62:	68 b0 77 10 f0       	push   $0xf01077b0
f0102c67:	e8 8c 0e 00 00       	call   f0103af8 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102c6c:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0102c71:	83 c4 10             	add    $0x10,%esp
f0102c74:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c79:	0f 86 03 02 00 00    	jbe    f0102e82 <mem_init+0x1b16>
	return (physaddr_t)kva - KERNBASE;
f0102c7f:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102c84:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102c87:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c8c:	e8 7e df ff ff       	call   f0100c0f <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102c91:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102c94:	83 e0 f3             	and    $0xfffffff3,%eax
f0102c97:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102c9c:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102c9f:	83 ec 0c             	sub    $0xc,%esp
f0102ca2:	6a 00                	push   $0x0
f0102ca4:	e8 20 e3 ff ff       	call   f0100fc9 <page_alloc>
f0102ca9:	89 c6                	mov    %eax,%esi
f0102cab:	83 c4 10             	add    $0x10,%esp
f0102cae:	85 c0                	test   %eax,%eax
f0102cb0:	0f 84 e1 01 00 00    	je     f0102e97 <mem_init+0x1b2b>
	assert((pp1 = page_alloc(0)));
f0102cb6:	83 ec 0c             	sub    $0xc,%esp
f0102cb9:	6a 00                	push   $0x0
f0102cbb:	e8 09 e3 ff ff       	call   f0100fc9 <page_alloc>
f0102cc0:	89 c7                	mov    %eax,%edi
f0102cc2:	83 c4 10             	add    $0x10,%esp
f0102cc5:	85 c0                	test   %eax,%eax
f0102cc7:	0f 84 e3 01 00 00    	je     f0102eb0 <mem_init+0x1b44>
	assert((pp2 = page_alloc(0)));
f0102ccd:	83 ec 0c             	sub    $0xc,%esp
f0102cd0:	6a 00                	push   $0x0
f0102cd2:	e8 f2 e2 ff ff       	call   f0100fc9 <page_alloc>
f0102cd7:	89 c3                	mov    %eax,%ebx
f0102cd9:	83 c4 10             	add    $0x10,%esp
f0102cdc:	85 c0                	test   %eax,%eax
f0102cde:	0f 84 e5 01 00 00    	je     f0102ec9 <mem_init+0x1b5d>
	page_free(pp0);
f0102ce4:	83 ec 0c             	sub    $0xc,%esp
f0102ce7:	56                   	push   %esi
f0102ce8:	e8 55 e3 ff ff       	call   f0101042 <page_free>
	return (pp - pages) << PGSHIFT;
f0102ced:	89 f8                	mov    %edi,%eax
f0102cef:	2b 05 90 7e 23 f0    	sub    0xf0237e90,%eax
f0102cf5:	c1 f8 03             	sar    $0x3,%eax
f0102cf8:	89 c2                	mov    %eax,%edx
f0102cfa:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102cfd:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102d02:	83 c4 10             	add    $0x10,%esp
f0102d05:	3b 05 88 7e 23 f0    	cmp    0xf0237e88,%eax
f0102d0b:	0f 83 d1 01 00 00    	jae    f0102ee2 <mem_init+0x1b76>
	memset(page2kva(pp1), 1, PGSIZE);
f0102d11:	83 ec 04             	sub    $0x4,%esp
f0102d14:	68 00 10 00 00       	push   $0x1000
f0102d19:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102d1b:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102d21:	52                   	push   %edx
f0102d22:	e8 05 30 00 00       	call   f0105d2c <memset>
	return (pp - pages) << PGSHIFT;
f0102d27:	89 d8                	mov    %ebx,%eax
f0102d29:	2b 05 90 7e 23 f0    	sub    0xf0237e90,%eax
f0102d2f:	c1 f8 03             	sar    $0x3,%eax
f0102d32:	89 c2                	mov    %eax,%edx
f0102d34:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102d37:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102d3c:	83 c4 10             	add    $0x10,%esp
f0102d3f:	3b 05 88 7e 23 f0    	cmp    0xf0237e88,%eax
f0102d45:	0f 83 a9 01 00 00    	jae    f0102ef4 <mem_init+0x1b88>
	memset(page2kva(pp2), 2, PGSIZE);
f0102d4b:	83 ec 04             	sub    $0x4,%esp
f0102d4e:	68 00 10 00 00       	push   $0x1000
f0102d53:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102d55:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102d5b:	52                   	push   %edx
f0102d5c:	e8 cb 2f 00 00       	call   f0105d2c <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102d61:	6a 02                	push   $0x2
f0102d63:	68 00 10 00 00       	push   $0x1000
f0102d68:	57                   	push   %edi
f0102d69:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f0102d6f:	e8 23 e5 ff ff       	call   f0101297 <page_insert>
	assert(pp1->pp_ref == 1);
f0102d74:	83 c4 20             	add    $0x20,%esp
f0102d77:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102d7c:	0f 85 84 01 00 00    	jne    f0102f06 <mem_init+0x1b9a>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102d82:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102d89:	01 01 01 
f0102d8c:	0f 85 8d 01 00 00    	jne    f0102f1f <mem_init+0x1bb3>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102d92:	6a 02                	push   $0x2
f0102d94:	68 00 10 00 00       	push   $0x1000
f0102d99:	53                   	push   %ebx
f0102d9a:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f0102da0:	e8 f2 e4 ff ff       	call   f0101297 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102da5:	83 c4 10             	add    $0x10,%esp
f0102da8:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102daf:	02 02 02 
f0102db2:	0f 85 80 01 00 00    	jne    f0102f38 <mem_init+0x1bcc>
	assert(pp2->pp_ref == 1);
f0102db8:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102dbd:	0f 85 8e 01 00 00    	jne    f0102f51 <mem_init+0x1be5>
	assert(pp1->pp_ref == 0);
f0102dc3:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102dc8:	0f 85 9c 01 00 00    	jne    f0102f6a <mem_init+0x1bfe>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102dce:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102dd5:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102dd8:	89 d8                	mov    %ebx,%eax
f0102dda:	2b 05 90 7e 23 f0    	sub    0xf0237e90,%eax
f0102de0:	c1 f8 03             	sar    $0x3,%eax
f0102de3:	89 c2                	mov    %eax,%edx
f0102de5:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102de8:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102ded:	3b 05 88 7e 23 f0    	cmp    0xf0237e88,%eax
f0102df3:	0f 83 8a 01 00 00    	jae    f0102f83 <mem_init+0x1c17>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102df9:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f0102e00:	03 03 03 
f0102e03:	0f 85 8c 01 00 00    	jne    f0102f95 <mem_init+0x1c29>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102e09:	83 ec 08             	sub    $0x8,%esp
f0102e0c:	68 00 10 00 00       	push   $0x1000
f0102e11:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f0102e17:	e8 2d e4 ff ff       	call   f0101249 <page_remove>
	assert(pp2->pp_ref == 0);
f0102e1c:	83 c4 10             	add    $0x10,%esp
f0102e1f:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102e24:	0f 85 84 01 00 00    	jne    f0102fae <mem_init+0x1c42>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102e2a:	8b 0d 8c 7e 23 f0    	mov    0xf0237e8c,%ecx
f0102e30:	8b 11                	mov    (%ecx),%edx
f0102e32:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102e38:	89 f0                	mov    %esi,%eax
f0102e3a:	2b 05 90 7e 23 f0    	sub    0xf0237e90,%eax
f0102e40:	c1 f8 03             	sar    $0x3,%eax
f0102e43:	c1 e0 0c             	shl    $0xc,%eax
f0102e46:	39 c2                	cmp    %eax,%edx
f0102e48:	0f 85 79 01 00 00    	jne    f0102fc7 <mem_init+0x1c5b>
	kern_pgdir[0] = 0;
f0102e4e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102e54:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102e59:	0f 85 81 01 00 00    	jne    f0102fe0 <mem_init+0x1c74>
	pp0->pp_ref = 0;
f0102e5f:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102e65:	83 ec 0c             	sub    $0xc,%esp
f0102e68:	56                   	push   %esi
f0102e69:	e8 d4 e1 ff ff       	call   f0101042 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102e6e:	c7 04 24 44 78 10 f0 	movl   $0xf0107844,(%esp)
f0102e75:	e8 7e 0c 00 00       	call   f0103af8 <cprintf>
}
f0102e7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e7d:	5b                   	pop    %ebx
f0102e7e:	5e                   	pop    %esi
f0102e7f:	5f                   	pop    %edi
f0102e80:	5d                   	pop    %ebp
f0102e81:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e82:	50                   	push   %eax
f0102e83:	68 08 6a 10 f0       	push   $0xf0106a08
f0102e88:	68 08 01 00 00       	push   $0x108
f0102e8d:	68 a5 78 10 f0       	push   $0xf01078a5
f0102e92:	e8 a9 d1 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0102e97:	68 ae 79 10 f0       	push   $0xf01079ae
f0102e9c:	68 d9 78 10 f0       	push   $0xf01078d9
f0102ea1:	68 a0 04 00 00       	push   $0x4a0
f0102ea6:	68 a5 78 10 f0       	push   $0xf01078a5
f0102eab:	e8 90 d1 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102eb0:	68 c4 79 10 f0       	push   $0xf01079c4
f0102eb5:	68 d9 78 10 f0       	push   $0xf01078d9
f0102eba:	68 a1 04 00 00       	push   $0x4a1
f0102ebf:	68 a5 78 10 f0       	push   $0xf01078a5
f0102ec4:	e8 77 d1 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102ec9:	68 da 79 10 f0       	push   $0xf01079da
f0102ece:	68 d9 78 10 f0       	push   $0xf01078d9
f0102ed3:	68 a2 04 00 00       	push   $0x4a2
f0102ed8:	68 a5 78 10 f0       	push   $0xf01078a5
f0102edd:	e8 5e d1 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ee2:	52                   	push   %edx
f0102ee3:	68 e4 69 10 f0       	push   $0xf01069e4
f0102ee8:	6a 58                	push   $0x58
f0102eea:	68 bf 78 10 f0       	push   $0xf01078bf
f0102eef:	e8 4c d1 ff ff       	call   f0100040 <_panic>
f0102ef4:	52                   	push   %edx
f0102ef5:	68 e4 69 10 f0       	push   $0xf01069e4
f0102efa:	6a 58                	push   $0x58
f0102efc:	68 bf 78 10 f0       	push   $0xf01078bf
f0102f01:	e8 3a d1 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102f06:	68 ab 7a 10 f0       	push   $0xf0107aab
f0102f0b:	68 d9 78 10 f0       	push   $0xf01078d9
f0102f10:	68 a7 04 00 00       	push   $0x4a7
f0102f15:	68 a5 78 10 f0       	push   $0xf01078a5
f0102f1a:	e8 21 d1 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102f1f:	68 d0 77 10 f0       	push   $0xf01077d0
f0102f24:	68 d9 78 10 f0       	push   $0xf01078d9
f0102f29:	68 a8 04 00 00       	push   $0x4a8
f0102f2e:	68 a5 78 10 f0       	push   $0xf01078a5
f0102f33:	e8 08 d1 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102f38:	68 f4 77 10 f0       	push   $0xf01077f4
f0102f3d:	68 d9 78 10 f0       	push   $0xf01078d9
f0102f42:	68 aa 04 00 00       	push   $0x4aa
f0102f47:	68 a5 78 10 f0       	push   $0xf01078a5
f0102f4c:	e8 ef d0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102f51:	68 cd 7a 10 f0       	push   $0xf0107acd
f0102f56:	68 d9 78 10 f0       	push   $0xf01078d9
f0102f5b:	68 ab 04 00 00       	push   $0x4ab
f0102f60:	68 a5 78 10 f0       	push   $0xf01078a5
f0102f65:	e8 d6 d0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102f6a:	68 37 7b 10 f0       	push   $0xf0107b37
f0102f6f:	68 d9 78 10 f0       	push   $0xf01078d9
f0102f74:	68 ac 04 00 00       	push   $0x4ac
f0102f79:	68 a5 78 10 f0       	push   $0xf01078a5
f0102f7e:	e8 bd d0 ff ff       	call   f0100040 <_panic>
f0102f83:	52                   	push   %edx
f0102f84:	68 e4 69 10 f0       	push   $0xf01069e4
f0102f89:	6a 58                	push   $0x58
f0102f8b:	68 bf 78 10 f0       	push   $0xf01078bf
f0102f90:	e8 ab d0 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102f95:	68 18 78 10 f0       	push   $0xf0107818
f0102f9a:	68 d9 78 10 f0       	push   $0xf01078d9
f0102f9f:	68 ae 04 00 00       	push   $0x4ae
f0102fa4:	68 a5 78 10 f0       	push   $0xf01078a5
f0102fa9:	e8 92 d0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102fae:	68 05 7b 10 f0       	push   $0xf0107b05
f0102fb3:	68 d9 78 10 f0       	push   $0xf01078d9
f0102fb8:	68 b0 04 00 00       	push   $0x4b0
f0102fbd:	68 a5 78 10 f0       	push   $0xf01078a5
f0102fc2:	e8 79 d0 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102fc7:	68 a0 71 10 f0       	push   $0xf01071a0
f0102fcc:	68 d9 78 10 f0       	push   $0xf01078d9
f0102fd1:	68 b3 04 00 00       	push   $0x4b3
f0102fd6:	68 a5 78 10 f0       	push   $0xf01078a5
f0102fdb:	e8 60 d0 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102fe0:	68 bc 7a 10 f0       	push   $0xf0107abc
f0102fe5:	68 d9 78 10 f0       	push   $0xf01078d9
f0102fea:	68 b5 04 00 00       	push   $0x4b5
f0102fef:	68 a5 78 10 f0       	push   $0xf01078a5
f0102ff4:	e8 47 d0 ff ff       	call   f0100040 <_panic>

f0102ff9 <do_user_mem_check>:
do_user_mem_check(struct Env *env, uintptr_t va, int perm) {
f0102ff9:	f3 0f 1e fb          	endbr32 
f0102ffd:	55                   	push   %ebp
f0102ffe:	89 e5                	mov    %esp,%ebp
f0103000:	83 ec 0c             	sub    $0xc,%esp
    pte_t *p_pte = pgdir_walk(env->env_pgdir, (void *)va, 0);
f0103003:	6a 00                	push   $0x0
f0103005:	ff 75 0c             	pushl  0xc(%ebp)
f0103008:	8b 45 08             	mov    0x8(%ebp),%eax
f010300b:	ff 70 60             	pushl  0x60(%eax)
f010300e:	e8 9b e0 ff ff       	call   f01010ae <pgdir_walk>
    if ( p_pte == NULL || (*p_pte & (perm|PTE_P)) != (perm|PTE_P)) {
f0103013:	83 c4 10             	add    $0x10,%esp
f0103016:	85 c0                	test   %eax,%eax
f0103018:	74 1b                	je     f0103035 <do_user_mem_check+0x3c>
f010301a:	8b 55 10             	mov    0x10(%ebp),%edx
f010301d:	83 ca 01             	or     $0x1,%edx
f0103020:	89 d1                	mov    %edx,%ecx
f0103022:	23 08                	and    (%eax),%ecx
        return -E_FAULT;
f0103024:	39 ca                	cmp    %ecx,%edx
f0103026:	b8 00 00 00 00       	mov    $0x0,%eax
f010302b:	ba fa ff ff ff       	mov    $0xfffffffa,%edx
f0103030:	0f 45 c2             	cmovne %edx,%eax
}
f0103033:	c9                   	leave  
f0103034:	c3                   	ret    
        return -E_FAULT;
f0103035:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010303a:	eb f7                	jmp    f0103033 <do_user_mem_check+0x3a>

f010303c <user_mem_check>:
{
f010303c:	f3 0f 1e fb          	endbr32 
f0103040:	55                   	push   %ebp
f0103041:	89 e5                	mov    %esp,%ebp
f0103043:	57                   	push   %edi
f0103044:	56                   	push   %esi
f0103045:	53                   	push   %ebx
f0103046:	83 ec 0c             	sub    $0xc,%esp
f0103049:	8b 7d 08             	mov    0x8(%ebp),%edi
f010304c:	8b 45 0c             	mov    0xc(%ebp),%eax
    uintptr_t low_addr = (uintptr_t)va;
f010304f:	89 c3                	mov    %eax,%ebx
    uintptr_t end_addr = ROUNDUP(((uintptr_t)va) + len, PGSIZE);
f0103051:	8b 55 10             	mov    0x10(%ebp),%edx
f0103054:	8d b4 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%esi
f010305b:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    while (low_addr < end_addr) {
f0103061:	eb 19                	jmp    f010307c <user_mem_check+0x40>
            user_mem_check_addr = low_addr;
f0103063:	89 1d 3c 72 23 f0    	mov    %ebx,0xf023723c
            return -E_FAULT;
f0103069:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010306e:	eb 3e                	jmp    f01030ae <user_mem_check+0x72>
        low_addr += PGSIZE;
f0103070:	81 c3 00 10 00 00    	add    $0x1000,%ebx
        low_addr &= 0xfffff000;
f0103076:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    while (low_addr < end_addr) {
f010307c:	39 f3                	cmp    %esi,%ebx
f010307e:	73 29                	jae    f01030a9 <user_mem_check+0x6d>
        if (low_addr >= ULIM) {
f0103080:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0103086:	77 db                	ja     f0103063 <user_mem_check+0x27>
        if (do_user_mem_check(env, low_addr, perm) < 0) {
f0103088:	83 ec 04             	sub    $0x4,%esp
f010308b:	ff 75 14             	pushl  0x14(%ebp)
f010308e:	53                   	push   %ebx
f010308f:	57                   	push   %edi
f0103090:	e8 64 ff ff ff       	call   f0102ff9 <do_user_mem_check>
f0103095:	83 c4 10             	add    $0x10,%esp
f0103098:	85 c0                	test   %eax,%eax
f010309a:	79 d4                	jns    f0103070 <user_mem_check+0x34>
            user_mem_check_addr = low_addr;
f010309c:	89 1d 3c 72 23 f0    	mov    %ebx,0xf023723c
            return -E_FAULT;
f01030a2:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01030a7:	eb 05                	jmp    f01030ae <user_mem_check+0x72>
	return 0;
f01030a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01030ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01030b1:	5b                   	pop    %ebx
f01030b2:	5e                   	pop    %esi
f01030b3:	5f                   	pop    %edi
f01030b4:	5d                   	pop    %ebp
f01030b5:	c3                   	ret    

f01030b6 <user_mem_assert>:
{
f01030b6:	f3 0f 1e fb          	endbr32 
f01030ba:	55                   	push   %ebp
f01030bb:	89 e5                	mov    %esp,%ebp
f01030bd:	53                   	push   %ebx
f01030be:	83 ec 04             	sub    $0x4,%esp
f01030c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01030c4:	8b 45 14             	mov    0x14(%ebp),%eax
f01030c7:	83 c8 04             	or     $0x4,%eax
f01030ca:	50                   	push   %eax
f01030cb:	ff 75 10             	pushl  0x10(%ebp)
f01030ce:	ff 75 0c             	pushl  0xc(%ebp)
f01030d1:	53                   	push   %ebx
f01030d2:	e8 65 ff ff ff       	call   f010303c <user_mem_check>
f01030d7:	83 c4 10             	add    $0x10,%esp
f01030da:	85 c0                	test   %eax,%eax
f01030dc:	78 05                	js     f01030e3 <user_mem_assert+0x2d>
}
f01030de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01030e1:	c9                   	leave  
f01030e2:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f01030e3:	83 ec 04             	sub    $0x4,%esp
f01030e6:	ff 35 3c 72 23 f0    	pushl  0xf023723c
f01030ec:	ff 73 48             	pushl  0x48(%ebx)
f01030ef:	68 70 78 10 f0       	push   $0xf0107870
f01030f4:	e8 ff 09 00 00       	call   f0103af8 <cprintf>
		env_destroy(env);	// may not return
f01030f9:	89 1c 24             	mov    %ebx,(%esp)
f01030fc:	e8 c0 06 00 00       	call   f01037c1 <env_destroy>
f0103101:	83 c4 10             	add    $0x10,%esp
}
f0103104:	eb d8                	jmp    f01030de <user_mem_assert+0x28>

f0103106 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103106:	55                   	push   %ebp
f0103107:	89 e5                	mov    %esp,%ebp
f0103109:	57                   	push   %edi
f010310a:	56                   	push   %esi
f010310b:	53                   	push   %ebx
f010310c:	83 ec 1c             	sub    $0x1c,%esp
f010310f:	89 c6                	mov    %eax,%esi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)

    char *start_addr    = (char *) ROUNDDOWN(va, PGSIZE);
f0103111:	89 d3                	mov    %edx,%ebx
f0103113:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    char *end_addr      = (char *) ROUNDUP((char *)va + len, PGSIZE);
f0103119:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f0103120:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103125:	89 c7                	mov    %eax,%edi

    if ((uintptr_t)end_addr > UTOP) {
f0103127:	3d 00 00 c0 ee       	cmp    $0xeec00000,%eax
f010312c:	76 34                	jbe    f0103162 <region_alloc+0x5c>
        panic("region_alloc: allocating above UTOP is not allowed\n");
f010312e:	83 ec 04             	sub    $0x4,%esp
f0103131:	68 d4 7b 10 f0       	push   $0xf0107bd4
f0103136:	68 2c 01 00 00       	push   $0x12c
f010313b:	68 80 7c 10 f0       	push   $0xf0107c80
f0103140:	e8 fb ce ff ff       	call   f0100040 <_panic>
        }

        pp = page_alloc(0);

        if (pp == NULL) {
            panic("region_alloc: out-of-memory!\n");
f0103145:	83 ec 04             	sub    $0x4,%esp
f0103148:	68 8b 7c 10 f0       	push   $0xf0107c8b
f010314d:	68 3a 01 00 00       	push   $0x13a
f0103152:	68 80 7c 10 f0       	push   $0xf0107c80
f0103157:	e8 e4 ce ff ff       	call   f0100040 <_panic>
f010315c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103162:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
    while (start_addr < end_addr) {
f0103165:	39 fb                	cmp    %edi,%ebx
f0103167:	73 52                	jae    f01031bb <region_alloc+0xb5>
        struct PageInfo *pp = page_lookup(e->env_pgdir, start_addr, NULL);
f0103169:	83 ec 04             	sub    $0x4,%esp
f010316c:	6a 00                	push   $0x0
f010316e:	53                   	push   %ebx
f010316f:	ff 76 60             	pushl  0x60(%esi)
f0103172:	e8 37 e0 ff ff       	call   f01011ae <page_lookup>
        if (pp != NULL) {
f0103177:	83 c4 10             	add    $0x10,%esp
f010317a:	85 c0                	test   %eax,%eax
f010317c:	75 de                	jne    f010315c <region_alloc+0x56>
        pp = page_alloc(0);
f010317e:	83 ec 0c             	sub    $0xc,%esp
f0103181:	6a 00                	push   $0x0
f0103183:	e8 41 de ff ff       	call   f0100fc9 <page_alloc>
        if (pp == NULL) {
f0103188:	83 c4 10             	add    $0x10,%esp
f010318b:	85 c0                	test   %eax,%eax
f010318d:	74 b6                	je     f0103145 <region_alloc+0x3f>
        }

        if (page_insert(e->env_pgdir, pp, start_addr, PTE_W | PTE_U | PTE_P) < 0) {
f010318f:	6a 07                	push   $0x7
f0103191:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103194:	50                   	push   %eax
f0103195:	ff 76 60             	pushl  0x60(%esi)
f0103198:	e8 fa e0 ff ff       	call   f0101297 <page_insert>
f010319d:	83 c4 10             	add    $0x10,%esp
f01031a0:	85 c0                	test   %eax,%eax
f01031a2:	79 b8                	jns    f010315c <region_alloc+0x56>
            panic("region_alloc: page table allocation failed!\n");
f01031a4:	83 ec 04             	sub    $0x4,%esp
f01031a7:	68 08 7c 10 f0       	push   $0xf0107c08
f01031ac:	68 3e 01 00 00       	push   $0x13e
f01031b1:	68 80 7c 10 f0       	push   $0xf0107c80
f01031b6:	e8 85 ce ff ff       	call   f0100040 <_panic>
        }
        start_addr += PGSIZE;
    }
}
f01031bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01031be:	5b                   	pop    %ebx
f01031bf:	5e                   	pop    %esi
f01031c0:	5f                   	pop    %edi
f01031c1:	5d                   	pop    %ebp
f01031c2:	c3                   	ret    

f01031c3 <envid2env>:
{
f01031c3:	f3 0f 1e fb          	endbr32 
f01031c7:	55                   	push   %ebp
f01031c8:	89 e5                	mov    %esp,%ebp
f01031ca:	56                   	push   %esi
f01031cb:	53                   	push   %ebx
f01031cc:	8b 75 08             	mov    0x8(%ebp),%esi
f01031cf:	8b 45 10             	mov    0x10(%ebp),%eax
	if (envid == 0) {
f01031d2:	85 f6                	test   %esi,%esi
f01031d4:	74 2e                	je     f0103204 <envid2env+0x41>
	e = &envs[ENVX(envid)];
f01031d6:	89 f3                	mov    %esi,%ebx
f01031d8:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f01031de:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f01031e1:	03 1d 44 72 23 f0    	add    0xf0237244,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01031e7:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f01031eb:	74 2e                	je     f010321b <envid2env+0x58>
f01031ed:	39 73 48             	cmp    %esi,0x48(%ebx)
f01031f0:	75 29                	jne    f010321b <envid2env+0x58>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01031f2:	84 c0                	test   %al,%al
f01031f4:	75 35                	jne    f010322b <envid2env+0x68>
	*env_store = e;
f01031f6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031f9:	89 18                	mov    %ebx,(%eax)
	return 0;
f01031fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103200:	5b                   	pop    %ebx
f0103201:	5e                   	pop    %esi
f0103202:	5d                   	pop    %ebp
f0103203:	c3                   	ret    
		*env_store = curenv;
f0103204:	e8 41 31 00 00       	call   f010634a <cpunum>
f0103209:	6b c0 74             	imul   $0x74,%eax,%eax
f010320c:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f0103212:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103215:	89 02                	mov    %eax,(%edx)
		return 0;
f0103217:	89 f0                	mov    %esi,%eax
f0103219:	eb e5                	jmp    f0103200 <envid2env+0x3d>
		*env_store = 0;
f010321b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010321e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103224:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103229:	eb d5                	jmp    f0103200 <envid2env+0x3d>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010322b:	e8 1a 31 00 00       	call   f010634a <cpunum>
f0103230:	6b c0 74             	imul   $0x74,%eax,%eax
f0103233:	39 98 28 80 23 f0    	cmp    %ebx,-0xfdc7fd8(%eax)
f0103239:	74 bb                	je     f01031f6 <envid2env+0x33>
f010323b:	8b 73 4c             	mov    0x4c(%ebx),%esi
f010323e:	e8 07 31 00 00       	call   f010634a <cpunum>
f0103243:	6b c0 74             	imul   $0x74,%eax,%eax
f0103246:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f010324c:	3b 70 48             	cmp    0x48(%eax),%esi
f010324f:	74 a5                	je     f01031f6 <envid2env+0x33>
		*env_store = 0;
f0103251:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103254:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010325a:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010325f:	eb 9f                	jmp    f0103200 <envid2env+0x3d>

f0103261 <env_init_percpu>:
{
f0103261:	f3 0f 1e fb          	endbr32 
	asm volatile("lgdt (%0)" : : "r" (p));
f0103265:	b8 20 33 12 f0       	mov    $0xf0123320,%eax
f010326a:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f010326d:	b8 23 00 00 00       	mov    $0x23,%eax
f0103272:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103274:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0103276:	b8 10 00 00 00       	mov    $0x10,%eax
f010327b:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f010327d:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f010327f:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103281:	ea 88 32 10 f0 08 00 	ljmp   $0x8,$0xf0103288
	asm volatile("lldt %0" : : "r" (sel));
f0103288:	b8 00 00 00 00       	mov    $0x0,%eax
f010328d:	0f 00 d0             	lldt   %ax
}
f0103290:	c3                   	ret    

f0103291 <env_init>:
{
f0103291:	f3 0f 1e fb          	endbr32 
f0103295:	55                   	push   %ebp
f0103296:	89 e5                	mov    %esp,%ebp
f0103298:	56                   	push   %esi
f0103299:	53                   	push   %ebx
    memset(envs, 0, sizeof(struct Env) * NENV);
f010329a:	83 ec 04             	sub    $0x4,%esp
f010329d:	68 00 f0 01 00       	push   $0x1f000
f01032a2:	6a 00                	push   $0x0
f01032a4:	ff 35 44 72 23 f0    	pushl  0xf0237244
f01032aa:	e8 7d 2a 00 00       	call   f0105d2c <memset>
        envs[i].env_link = env_free_list;
f01032af:	8b 35 44 72 23 f0    	mov    0xf0237244,%esi
f01032b5:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f01032bb:	89 f3                	mov    %esi,%ebx
f01032bd:	83 c4 10             	add    $0x10,%esp
f01032c0:	ba 00 00 00 00       	mov    $0x0,%edx
f01032c5:	89 d1                	mov    %edx,%ecx
f01032c7:	89 c2                	mov    %eax,%edx
f01032c9:	89 48 44             	mov    %ecx,0x44(%eax)
f01032cc:	83 e8 7c             	sub    $0x7c,%eax
    for (int i=NENV-1; i>=0; --i) {
f01032cf:	39 da                	cmp    %ebx,%edx
f01032d1:	75 f2                	jne    f01032c5 <env_init+0x34>
f01032d3:	89 35 48 72 23 f0    	mov    %esi,0xf0237248
	env_init_percpu();
f01032d9:	e8 83 ff ff ff       	call   f0103261 <env_init_percpu>
}
f01032de:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01032e1:	5b                   	pop    %ebx
f01032e2:	5e                   	pop    %esi
f01032e3:	5d                   	pop    %ebp
f01032e4:	c3                   	ret    

f01032e5 <env_alloc>:
{
f01032e5:	f3 0f 1e fb          	endbr32 
f01032e9:	55                   	push   %ebp
f01032ea:	89 e5                	mov    %esp,%ebp
f01032ec:	53                   	push   %ebx
f01032ed:	83 ec 04             	sub    $0x4,%esp
	if (!(e = env_free_list))
f01032f0:	8b 1d 48 72 23 f0    	mov    0xf0237248,%ebx
f01032f6:	85 db                	test   %ebx,%ebx
f01032f8:	0f 84 7e 01 00 00    	je     f010347c <env_alloc+0x197>
	if (!(p = page_alloc(ALLOC_ZERO)))
f01032fe:	83 ec 0c             	sub    $0xc,%esp
f0103301:	6a 01                	push   $0x1
f0103303:	e8 c1 dc ff ff       	call   f0100fc9 <page_alloc>
f0103308:	83 c4 10             	add    $0x10,%esp
f010330b:	85 c0                	test   %eax,%eax
f010330d:	0f 84 70 01 00 00    	je     f0103483 <env_alloc+0x19e>
    p->pp_ref += 1;
f0103313:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0103318:	2b 05 90 7e 23 f0    	sub    0xf0237e90,%eax
f010331e:	c1 f8 03             	sar    $0x3,%eax
f0103321:	89 c2                	mov    %eax,%edx
f0103323:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0103326:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010332b:	3b 05 88 7e 23 f0    	cmp    0xf0237e88,%eax
f0103331:	0f 83 1e 01 00 00    	jae    f0103455 <env_alloc+0x170>
	return (void *)(pa + KERNBASE);
f0103337:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010333d:	89 53 60             	mov    %edx,0x60(%ebx)
    e->env_pgdir = page2kva(p);
f0103340:	b8 ec 0e 00 00       	mov    $0xeec,%eax
        e->env_pgdir[i] = kern_pgdir[i];
f0103345:	8b 15 8c 7e 23 f0    	mov    0xf0237e8c,%edx
f010334b:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f010334e:	8b 53 60             	mov    0x60(%ebx),%edx
f0103351:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0103354:	83 c0 04             	add    $0x4,%eax
    for(int i=PDX(UTOP); i<NPDENTRIES; ++i) {
f0103357:	3d 00 10 00 00       	cmp    $0x1000,%eax
f010335c:	75 e7                	jne    f0103345 <env_alloc+0x60>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010335e:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0103361:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103366:	0f 86 fb 00 00 00    	jbe    f0103467 <env_alloc+0x182>
	return (physaddr_t)kva - KERNBASE;
f010336c:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103372:	83 ca 05             	or     $0x5,%edx
f0103375:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010337b:	8b 43 48             	mov    0x48(%ebx),%eax
f010337e:	05 00 10 00 00       	add    $0x1000,%eax
		generation = 1 << ENVGENSHIFT;
f0103383:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0103388:	ba 00 10 00 00       	mov    $0x1000,%edx
f010338d:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103390:	89 da                	mov    %ebx,%edx
f0103392:	2b 15 44 72 23 f0    	sub    0xf0237244,%edx
f0103398:	c1 fa 02             	sar    $0x2,%edx
f010339b:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f01033a1:	09 d0                	or     %edx,%eax
f01033a3:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f01033a6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01033a9:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01033ac:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01033b3:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01033ba:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01033c1:	83 ec 04             	sub    $0x4,%esp
f01033c4:	6a 44                	push   $0x44
f01033c6:	6a 00                	push   $0x0
f01033c8:	53                   	push   %ebx
f01033c9:	e8 5e 29 00 00       	call   f0105d2c <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f01033ce:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01033d4:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01033da:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01033e0:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01033e7:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
    e->env_tf.tf_eflags = FL_IF;
f01033ed:	c7 43 38 00 02 00 00 	movl   $0x200,0x38(%ebx)
	e->env_pgfault_upcall = 0;
f01033f4:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_ipc_recving = 0;
f01033fb:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_free_list = e->env_link;
f01033ff:	8b 43 44             	mov    0x44(%ebx),%eax
f0103402:	a3 48 72 23 f0       	mov    %eax,0xf0237248
	*newenv_store = e;
f0103407:	8b 45 08             	mov    0x8(%ebp),%eax
f010340a:	89 18                	mov    %ebx,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010340c:	8b 5b 48             	mov    0x48(%ebx),%ebx
f010340f:	e8 36 2f 00 00       	call   f010634a <cpunum>
f0103414:	6b c0 74             	imul   $0x74,%eax,%eax
f0103417:	83 c4 10             	add    $0x10,%esp
f010341a:	ba 00 00 00 00       	mov    $0x0,%edx
f010341f:	83 b8 28 80 23 f0 00 	cmpl   $0x0,-0xfdc7fd8(%eax)
f0103426:	74 11                	je     f0103439 <env_alloc+0x154>
f0103428:	e8 1d 2f 00 00       	call   f010634a <cpunum>
f010342d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103430:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f0103436:	8b 50 48             	mov    0x48(%eax),%edx
f0103439:	83 ec 04             	sub    $0x4,%esp
f010343c:	53                   	push   %ebx
f010343d:	52                   	push   %edx
f010343e:	68 a9 7c 10 f0       	push   $0xf0107ca9
f0103443:	e8 b0 06 00 00       	call   f0103af8 <cprintf>
	return 0;
f0103448:	83 c4 10             	add    $0x10,%esp
f010344b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103450:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103453:	c9                   	leave  
f0103454:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103455:	52                   	push   %edx
f0103456:	68 e4 69 10 f0       	push   $0xf01069e4
f010345b:	6a 58                	push   $0x58
f010345d:	68 bf 78 10 f0       	push   $0xf01078bf
f0103462:	e8 d9 cb ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103467:	50                   	push   %eax
f0103468:	68 08 6a 10 f0       	push   $0xf0106a08
f010346d:	68 c8 00 00 00       	push   $0xc8
f0103472:	68 80 7c 10 f0       	push   $0xf0107c80
f0103477:	e8 c4 cb ff ff       	call   f0100040 <_panic>
		return -E_NO_FREE_ENV;
f010347c:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103481:	eb cd                	jmp    f0103450 <env_alloc+0x16b>
		return -E_NO_MEM;
f0103483:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103488:	eb c6                	jmp    f0103450 <env_alloc+0x16b>

f010348a <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f010348a:	f3 0f 1e fb          	endbr32 
f010348e:	55                   	push   %ebp
f010348f:	89 e5                	mov    %esp,%ebp
f0103491:	57                   	push   %edi
f0103492:	56                   	push   %esi
f0103493:	53                   	push   %ebx
f0103494:	83 ec 34             	sub    $0x34,%esp
f0103497:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
    struct Env *new_env = NULL;
f010349a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    int ret = env_alloc(&new_env, 0);
f01034a1:	6a 00                	push   $0x0
f01034a3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01034a6:	50                   	push   %eax
f01034a7:	e8 39 fe ff ff       	call   f01032e5 <env_alloc>
    if (ret == -E_NO_FREE_ENV) {
f01034ac:	83 c4 10             	add    $0x10,%esp
f01034af:	83 f8 fb             	cmp    $0xfffffffb,%eax
f01034b2:	74 4b                	je     f01034ff <env_create+0x75>
        panic("all NENV environments are allocated!\n");
    }
    else if (ret == -E_NO_MEM) {
f01034b4:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01034b7:	74 5d                	je     f0103516 <env_create+0x8c>
        panic("not enouth memory!\n");
    }
    else if (new_env == NULL) {
f01034b9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01034bc:	85 f6                	test   %esi,%esi
f01034be:	74 6d                	je     f010352d <env_create+0xa3>
        panic("new env is not allocated!\n");
    }

    new_env->env_type = type;
f01034c0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034c3:	89 46 50             	mov    %eax,0x50(%esi)
	asm volatile("movl %%cr3,%0" : "=r" (val));
f01034c6:	0f 20 d8             	mov    %cr3,%eax
f01034c9:	89 45 cc             	mov    %eax,-0x34(%ebp)
    lcr3(PADDR(e->env_pgdir));
f01034cc:	8b 46 60             	mov    0x60(%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f01034cf:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01034d4:	76 6e                	jbe    f0103544 <env_create+0xba>
	return (physaddr_t)kva - KERNBASE;
f01034d6:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01034db:	0f 22 d8             	mov    %eax,%cr3
    if (elf->e_magic != ELF_MAGIC) {
f01034de:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f01034e4:	75 73                	jne    f0103559 <env_create+0xcf>
    uintptr_t elf_base = (uintptr_t) elf;
f01034e6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
    ph = (struct Proghdr *) (elf_base + elf->e_phoff);
f01034e9:	89 fb                	mov    %edi,%ebx
f01034eb:	03 5f 1c             	add    0x1c(%edi),%ebx
    eph = ph + elf->e_phnum;
f01034ee:	0f b7 47 2c          	movzwl 0x2c(%edi),%eax
f01034f2:	c1 e0 05             	shl    $0x5,%eax
f01034f5:	01 d8                	add    %ebx,%eax
f01034f7:	89 45 d0             	mov    %eax,-0x30(%ebp)
    for (; ph < eph; ++ph) {
f01034fa:	e9 a9 00 00 00       	jmp    f01035a8 <env_create+0x11e>
        panic("all NENV environments are allocated!\n");
f01034ff:	83 ec 04             	sub    $0x4,%esp
f0103502:	68 38 7c 10 f0       	push   $0xf0107c38
f0103507:	68 ae 01 00 00       	push   $0x1ae
f010350c:	68 80 7c 10 f0       	push   $0xf0107c80
f0103511:	e8 2a cb ff ff       	call   f0100040 <_panic>
        panic("not enouth memory!\n");
f0103516:	83 ec 04             	sub    $0x4,%esp
f0103519:	68 be 7c 10 f0       	push   $0xf0107cbe
f010351e:	68 b1 01 00 00       	push   $0x1b1
f0103523:	68 80 7c 10 f0       	push   $0xf0107c80
f0103528:	e8 13 cb ff ff       	call   f0100040 <_panic>
        panic("new env is not allocated!\n");
f010352d:	83 ec 04             	sub    $0x4,%esp
f0103530:	68 d2 7c 10 f0       	push   $0xf0107cd2
f0103535:	68 b4 01 00 00       	push   $0x1b4
f010353a:	68 80 7c 10 f0       	push   $0xf0107c80
f010353f:	e8 fc ca ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103544:	50                   	push   %eax
f0103545:	68 08 6a 10 f0       	push   $0xf0106a08
f010354a:	68 7b 01 00 00       	push   $0x17b
f010354f:	68 80 7c 10 f0       	push   $0xf0107c80
f0103554:	e8 e7 ca ff ff       	call   f0100040 <_panic>
        panic("load_icode: not an ELF binary!\n");
f0103559:	83 ec 04             	sub    $0x4,%esp
f010355c:	68 60 7c 10 f0       	push   $0xf0107c60
f0103561:	68 81 01 00 00       	push   $0x181
f0103566:	68 80 7c 10 f0       	push   $0xf0107c80
f010356b:	e8 d0 ca ff ff       	call   f0100040 <_panic>
            region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103570:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103573:	8b 53 08             	mov    0x8(%ebx),%edx
f0103576:	89 f0                	mov    %esi,%eax
f0103578:	e8 89 fb ff ff       	call   f0103106 <region_alloc>
            memset((void *)ph->p_va, 0, ph->p_memsz);
f010357d:	83 ec 04             	sub    $0x4,%esp
f0103580:	ff 73 14             	pushl  0x14(%ebx)
f0103583:	6a 00                	push   $0x0
f0103585:	ff 73 08             	pushl  0x8(%ebx)
f0103588:	e8 9f 27 00 00       	call   f0105d2c <memset>
            memcpy((void *)ph->p_va, (void *)(elf_base + ph->p_offset), ph->p_filesz);
f010358d:	83 c4 0c             	add    $0xc,%esp
f0103590:	ff 73 10             	pushl  0x10(%ebx)
f0103593:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103596:	03 43 04             	add    0x4(%ebx),%eax
f0103599:	50                   	push   %eax
f010359a:	ff 73 08             	pushl  0x8(%ebx)
f010359d:	e8 3c 28 00 00       	call   f0105dde <memcpy>
f01035a2:	83 c4 10             	add    $0x10,%esp
    for (; ph < eph; ++ph) {
f01035a5:	83 c3 20             	add    $0x20,%ebx
f01035a8:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f01035ab:	76 07                	jbe    f01035b4 <env_create+0x12a>
        if (ph->p_type == ELF_PROG_LOAD) {
f01035ad:	83 3b 01             	cmpl   $0x1,(%ebx)
f01035b0:	75 f3                	jne    f01035a5 <env_create+0x11b>
f01035b2:	eb bc                	jmp    f0103570 <env_create+0xe6>
    e->env_tf.tf_eip = elf->e_entry;
f01035b4:	8b 47 18             	mov    0x18(%edi),%eax
f01035b7:	89 46 30             	mov    %eax,0x30(%esi)
    region_alloc(e, (void *)(USTACKTOP-PGSIZE), PGSIZE);
f01035ba:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01035bf:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01035c4:	89 f0                	mov    %esi,%eax
f01035c6:	e8 3b fb ff ff       	call   f0103106 <region_alloc>
    e->env_tf.tf_esp = USTACKTOP;
f01035cb:	c7 46 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%esi)
f01035d2:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01035d5:	0f 22 d8             	mov    %eax,%cr3
    load_icode(new_env, binary);

}
f01035d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01035db:	5b                   	pop    %ebx
f01035dc:	5e                   	pop    %esi
f01035dd:	5f                   	pop    %edi
f01035de:	5d                   	pop    %ebp
f01035df:	c3                   	ret    

f01035e0 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01035e0:	f3 0f 1e fb          	endbr32 
f01035e4:	55                   	push   %ebp
f01035e5:	89 e5                	mov    %esp,%ebp
f01035e7:	57                   	push   %edi
f01035e8:	56                   	push   %esi
f01035e9:	53                   	push   %ebx
f01035ea:	83 ec 1c             	sub    $0x1c,%esp
f01035ed:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01035f0:	e8 55 2d 00 00       	call   f010634a <cpunum>
f01035f5:	6b c0 74             	imul   $0x74,%eax,%eax
f01035f8:	39 b8 28 80 23 f0    	cmp    %edi,-0xfdc7fd8(%eax)
f01035fe:	74 48                	je     f0103648 <env_free+0x68>
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103600:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103603:	e8 42 2d 00 00       	call   f010634a <cpunum>
f0103608:	6b c0 74             	imul   $0x74,%eax,%eax
f010360b:	ba 00 00 00 00       	mov    $0x0,%edx
f0103610:	83 b8 28 80 23 f0 00 	cmpl   $0x0,-0xfdc7fd8(%eax)
f0103617:	74 11                	je     f010362a <env_free+0x4a>
f0103619:	e8 2c 2d 00 00       	call   f010634a <cpunum>
f010361e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103621:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f0103627:	8b 50 48             	mov    0x48(%eax),%edx
f010362a:	83 ec 04             	sub    $0x4,%esp
f010362d:	53                   	push   %ebx
f010362e:	52                   	push   %edx
f010362f:	68 ed 7c 10 f0       	push   $0xf0107ced
f0103634:	e8 bf 04 00 00       	call   f0103af8 <cprintf>
f0103639:	83 c4 10             	add    $0x10,%esp
f010363c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103643:	e9 a9 00 00 00       	jmp    f01036f1 <env_free+0x111>
		lcr3(PADDR(kern_pgdir));
f0103648:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f010364d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103652:	76 0a                	jbe    f010365e <env_free+0x7e>
	return (physaddr_t)kva - KERNBASE;
f0103654:	05 00 00 00 10       	add    $0x10000000,%eax
f0103659:	0f 22 d8             	mov    %eax,%cr3
}
f010365c:	eb a2                	jmp    f0103600 <env_free+0x20>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010365e:	50                   	push   %eax
f010365f:	68 08 6a 10 f0       	push   $0xf0106a08
f0103664:	68 ca 01 00 00       	push   $0x1ca
f0103669:	68 80 7c 10 f0       	push   $0xf0107c80
f010366e:	e8 cd c9 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103673:	56                   	push   %esi
f0103674:	68 e4 69 10 f0       	push   $0xf01069e4
f0103679:	68 d9 01 00 00       	push   $0x1d9
f010367e:	68 80 7c 10 f0       	push   $0xf0107c80
f0103683:	e8 b8 c9 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103688:	83 ec 08             	sub    $0x8,%esp
f010368b:	89 d8                	mov    %ebx,%eax
f010368d:	c1 e0 0c             	shl    $0xc,%eax
f0103690:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103693:	50                   	push   %eax
f0103694:	ff 77 60             	pushl  0x60(%edi)
f0103697:	e8 ad db ff ff       	call   f0101249 <page_remove>
f010369c:	83 c4 10             	add    $0x10,%esp
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010369f:	83 c3 01             	add    $0x1,%ebx
f01036a2:	83 c6 04             	add    $0x4,%esi
f01036a5:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01036ab:	74 07                	je     f01036b4 <env_free+0xd4>
			if (pt[pteno] & PTE_P)
f01036ad:	f6 06 01             	testb  $0x1,(%esi)
f01036b0:	74 ed                	je     f010369f <env_free+0xbf>
f01036b2:	eb d4                	jmp    f0103688 <env_free+0xa8>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01036b4:	8b 47 60             	mov    0x60(%edi),%eax
f01036b7:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01036ba:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f01036c1:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01036c4:	3b 05 88 7e 23 f0    	cmp    0xf0237e88,%eax
f01036ca:	73 65                	jae    f0103731 <env_free+0x151>
		page_decref(pa2page(pa));
f01036cc:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01036cf:	a1 90 7e 23 f0       	mov    0xf0237e90,%eax
f01036d4:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01036d7:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01036da:	50                   	push   %eax
f01036db:	e8 a1 d9 ff ff       	call   f0101081 <page_decref>
f01036e0:	83 c4 10             	add    $0x10,%esp
f01036e3:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f01036e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01036ea:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01036ef:	74 54                	je     f0103745 <env_free+0x165>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01036f1:	8b 47 60             	mov    0x60(%edi),%eax
f01036f4:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01036f7:	8b 04 10             	mov    (%eax,%edx,1),%eax
f01036fa:	a8 01                	test   $0x1,%al
f01036fc:	74 e5                	je     f01036e3 <env_free+0x103>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01036fe:	89 c6                	mov    %eax,%esi
f0103700:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f0103706:	c1 e8 0c             	shr    $0xc,%eax
f0103709:	89 45 dc             	mov    %eax,-0x24(%ebp)
f010370c:	39 05 88 7e 23 f0    	cmp    %eax,0xf0237e88
f0103712:	0f 86 5b ff ff ff    	jbe    f0103673 <env_free+0x93>
	return (void *)(pa + KERNBASE);
f0103718:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f010371e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103721:	c1 e0 14             	shl    $0x14,%eax
f0103724:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103727:	bb 00 00 00 00       	mov    $0x0,%ebx
f010372c:	e9 7c ff ff ff       	jmp    f01036ad <env_free+0xcd>
		panic("pa2page called with invalid pa");
f0103731:	83 ec 04             	sub    $0x4,%esp
f0103734:	68 6c 70 10 f0       	push   $0xf010706c
f0103739:	6a 51                	push   $0x51
f010373b:	68 bf 78 10 f0       	push   $0xf01078bf
f0103740:	e8 fb c8 ff ff       	call   f0100040 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103745:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f0103748:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010374d:	76 49                	jbe    f0103798 <env_free+0x1b8>
	e->env_pgdir = 0;
f010374f:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103756:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f010375b:	c1 e8 0c             	shr    $0xc,%eax
f010375e:	3b 05 88 7e 23 f0    	cmp    0xf0237e88,%eax
f0103764:	73 47                	jae    f01037ad <env_free+0x1cd>
	page_decref(pa2page(pa));
f0103766:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103769:	8b 15 90 7e 23 f0    	mov    0xf0237e90,%edx
f010376f:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103772:	50                   	push   %eax
f0103773:	e8 09 d9 ff ff       	call   f0101081 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103778:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f010377f:	a1 48 72 23 f0       	mov    0xf0237248,%eax
f0103784:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103787:	89 3d 48 72 23 f0    	mov    %edi,0xf0237248
}
f010378d:	83 c4 10             	add    $0x10,%esp
f0103790:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103793:	5b                   	pop    %ebx
f0103794:	5e                   	pop    %esi
f0103795:	5f                   	pop    %edi
f0103796:	5d                   	pop    %ebp
f0103797:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103798:	50                   	push   %eax
f0103799:	68 08 6a 10 f0       	push   $0xf0106a08
f010379e:	68 e7 01 00 00       	push   $0x1e7
f01037a3:	68 80 7c 10 f0       	push   $0xf0107c80
f01037a8:	e8 93 c8 ff ff       	call   f0100040 <_panic>
		panic("pa2page called with invalid pa");
f01037ad:	83 ec 04             	sub    $0x4,%esp
f01037b0:	68 6c 70 10 f0       	push   $0xf010706c
f01037b5:	6a 51                	push   $0x51
f01037b7:	68 bf 78 10 f0       	push   $0xf01078bf
f01037bc:	e8 7f c8 ff ff       	call   f0100040 <_panic>

f01037c1 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01037c1:	f3 0f 1e fb          	endbr32 
f01037c5:	55                   	push   %ebp
f01037c6:	89 e5                	mov    %esp,%ebp
f01037c8:	53                   	push   %ebx
f01037c9:	83 ec 04             	sub    $0x4,%esp
f01037cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01037cf:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01037d3:	74 21                	je     f01037f6 <env_destroy+0x35>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f01037d5:	83 ec 0c             	sub    $0xc,%esp
f01037d8:	53                   	push   %ebx
f01037d9:	e8 02 fe ff ff       	call   f01035e0 <env_free>

	if (curenv == e) {
f01037de:	e8 67 2b 00 00       	call   f010634a <cpunum>
f01037e3:	6b c0 74             	imul   $0x74,%eax,%eax
f01037e6:	83 c4 10             	add    $0x10,%esp
f01037e9:	39 98 28 80 23 f0    	cmp    %ebx,-0xfdc7fd8(%eax)
f01037ef:	74 1e                	je     f010380f <env_destroy+0x4e>
		curenv = NULL;
		sched_yield();
	}
}
f01037f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01037f4:	c9                   	leave  
f01037f5:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01037f6:	e8 4f 2b 00 00       	call   f010634a <cpunum>
f01037fb:	6b c0 74             	imul   $0x74,%eax,%eax
f01037fe:	39 98 28 80 23 f0    	cmp    %ebx,-0xfdc7fd8(%eax)
f0103804:	74 cf                	je     f01037d5 <env_destroy+0x14>
		e->env_status = ENV_DYING;
f0103806:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f010380d:	eb e2                	jmp    f01037f1 <env_destroy+0x30>
		curenv = NULL;
f010380f:	e8 36 2b 00 00       	call   f010634a <cpunum>
f0103814:	6b c0 74             	imul   $0x74,%eax,%eax
f0103817:	c7 80 28 80 23 f0 00 	movl   $0x0,-0xfdc7fd8(%eax)
f010381e:	00 00 00 
		sched_yield();
f0103821:	e8 90 11 00 00       	call   f01049b6 <sched_yield>

f0103826 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103826:	f3 0f 1e fb          	endbr32 
f010382a:	55                   	push   %ebp
f010382b:	89 e5                	mov    %esp,%ebp
f010382d:	56                   	push   %esi
f010382e:	53                   	push   %ebx
f010382f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103832:	e8 13 2b 00 00       	call   f010634a <cpunum>
f0103837:	6b c0 74             	imul   $0x74,%eax,%eax
f010383a:	8b b0 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%esi
f0103840:	e8 05 2b 00 00       	call   f010634a <cpunum>
f0103845:	89 46 5c             	mov    %eax,0x5c(%esi)
    assert(tf->tf_eflags & FL_IF);
f0103848:	f6 43 39 02          	testb  $0x2,0x39(%ebx)
f010384c:	75 19                	jne    f0103867 <env_pop_tf+0x41>
f010384e:	68 03 7d 10 f0       	push   $0xf0107d03
f0103853:	68 d9 78 10 f0       	push   $0xf01078d9
f0103858:	68 15 02 00 00       	push   $0x215
f010385d:	68 80 7c 10 f0       	push   $0xf0107c80
f0103862:	e8 d9 c7 ff ff       	call   f0100040 <_panic>

	asm volatile(
f0103867:	89 dc                	mov    %ebx,%esp
f0103869:	61                   	popa   
f010386a:	07                   	pop    %es
f010386b:	1f                   	pop    %ds
f010386c:	83 c4 08             	add    $0x8,%esp
f010386f:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103870:	83 ec 04             	sub    $0x4,%esp
f0103873:	68 19 7d 10 f0       	push   $0xf0107d19
f0103878:	68 1f 02 00 00       	push   $0x21f
f010387d:	68 80 7c 10 f0       	push   $0xf0107c80
f0103882:	e8 b9 c7 ff ff       	call   f0100040 <_panic>

f0103887 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103887:	f3 0f 1e fb          	endbr32 
f010388b:	55                   	push   %ebp
f010388c:	89 e5                	mov    %esp,%ebp
f010388e:	53                   	push   %ebx
f010388f:	83 ec 04             	sub    $0x4,%esp
f0103892:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

    // 1.
    if (curenv != NULL && curenv->env_status == ENV_RUNNING) {
f0103895:	e8 b0 2a 00 00       	call   f010634a <cpunum>
f010389a:	6b c0 74             	imul   $0x74,%eax,%eax
f010389d:	83 b8 28 80 23 f0 00 	cmpl   $0x0,-0xfdc7fd8(%eax)
f01038a4:	74 14                	je     f01038ba <env_run+0x33>
f01038a6:	e8 9f 2a 00 00       	call   f010634a <cpunum>
f01038ab:	6b c0 74             	imul   $0x74,%eax,%eax
f01038ae:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f01038b4:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01038b8:	74 6c                	je     f0103926 <env_run+0x9f>
        curenv->env_status = ENV_RUNNABLE;
    }
    // 2.
    curenv = e;
f01038ba:	e8 8b 2a 00 00       	call   f010634a <cpunum>
f01038bf:	6b c0 74             	imul   $0x74,%eax,%eax
f01038c2:	89 98 28 80 23 f0    	mov    %ebx,-0xfdc7fd8(%eax)
    // 3.
    curenv->env_status = ENV_RUNNING;
f01038c8:	e8 7d 2a 00 00       	call   f010634a <cpunum>
f01038cd:	6b c0 74             	imul   $0x74,%eax,%eax
f01038d0:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f01038d6:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
    // 4.
    curenv->env_runs += 1;
f01038dd:	e8 68 2a 00 00       	call   f010634a <cpunum>
f01038e2:	6b c0 74             	imul   $0x74,%eax,%eax
f01038e5:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f01038eb:	83 40 58 01          	addl   $0x1,0x58(%eax)
    // 5.
    lcr3(PADDR(e->env_pgdir));
f01038ef:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f01038f2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01038f7:	76 47                	jbe    f0103940 <env_run+0xb9>
	return (physaddr_t)kva - KERNBASE;
f01038f9:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01038fe:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103901:	83 ec 0c             	sub    $0xc,%esp
f0103904:	68 c0 33 12 f0       	push   $0xf01233c0
f0103909:	e8 62 2d 00 00       	call   f0106670 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010390e:	f3 90                	pause  

    unlock_kernel();

    env_pop_tf(&curenv->env_tf);
f0103910:	e8 35 2a 00 00       	call   f010634a <cpunum>
f0103915:	83 c4 04             	add    $0x4,%esp
f0103918:	6b c0 74             	imul   $0x74,%eax,%eax
f010391b:	ff b0 28 80 23 f0    	pushl  -0xfdc7fd8(%eax)
f0103921:	e8 00 ff ff ff       	call   f0103826 <env_pop_tf>
        curenv->env_status = ENV_RUNNABLE;
f0103926:	e8 1f 2a 00 00       	call   f010634a <cpunum>
f010392b:	6b c0 74             	imul   $0x74,%eax,%eax
f010392e:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f0103934:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f010393b:	e9 7a ff ff ff       	jmp    f01038ba <env_run+0x33>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103940:	50                   	push   %eax
f0103941:	68 08 6a 10 f0       	push   $0xf0106a08
f0103946:	68 49 02 00 00       	push   $0x249
f010394b:	68 80 7c 10 f0       	push   $0xf0107c80
f0103950:	e8 eb c6 ff ff       	call   f0100040 <_panic>

f0103955 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103955:	f3 0f 1e fb          	endbr32 
f0103959:	55                   	push   %ebp
f010395a:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010395c:	8b 45 08             	mov    0x8(%ebp),%eax
f010395f:	ba 70 00 00 00       	mov    $0x70,%edx
f0103964:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103965:	ba 71 00 00 00       	mov    $0x71,%edx
f010396a:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f010396b:	0f b6 c0             	movzbl %al,%eax
}
f010396e:	5d                   	pop    %ebp
f010396f:	c3                   	ret    

f0103970 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103970:	f3 0f 1e fb          	endbr32 
f0103974:	55                   	push   %ebp
f0103975:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103977:	8b 45 08             	mov    0x8(%ebp),%eax
f010397a:	ba 70 00 00 00       	mov    $0x70,%edx
f010397f:	ee                   	out    %al,(%dx)
f0103980:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103983:	ba 71 00 00 00       	mov    $0x71,%edx
f0103988:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103989:	5d                   	pop    %ebp
f010398a:	c3                   	ret    

f010398b <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f010398b:	f3 0f 1e fb          	endbr32 
f010398f:	55                   	push   %ebp
f0103990:	89 e5                	mov    %esp,%ebp
f0103992:	56                   	push   %esi
f0103993:	53                   	push   %ebx
f0103994:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103997:	66 a3 a8 33 12 f0    	mov    %ax,0xf01233a8
	if (!didinit)
f010399d:	80 3d 4c 72 23 f0 00 	cmpb   $0x0,0xf023724c
f01039a4:	75 07                	jne    f01039ad <irq_setmask_8259A+0x22>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f01039a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01039a9:	5b                   	pop    %ebx
f01039aa:	5e                   	pop    %esi
f01039ab:	5d                   	pop    %ebp
f01039ac:	c3                   	ret    
f01039ad:	89 c6                	mov    %eax,%esi
f01039af:	ba 21 00 00 00       	mov    $0x21,%edx
f01039b4:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f01039b5:	66 c1 e8 08          	shr    $0x8,%ax
f01039b9:	ba a1 00 00 00       	mov    $0xa1,%edx
f01039be:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f01039bf:	83 ec 0c             	sub    $0xc,%esp
f01039c2:	68 25 7d 10 f0       	push   $0xf0107d25
f01039c7:	e8 2c 01 00 00       	call   f0103af8 <cprintf>
f01039cc:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f01039cf:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f01039d4:	0f b7 f6             	movzwl %si,%esi
f01039d7:	f7 d6                	not    %esi
f01039d9:	eb 19                	jmp    f01039f4 <irq_setmask_8259A+0x69>
			cprintf(" %d", i);
f01039db:	83 ec 08             	sub    $0x8,%esp
f01039de:	53                   	push   %ebx
f01039df:	68 2f 82 10 f0       	push   $0xf010822f
f01039e4:	e8 0f 01 00 00       	call   f0103af8 <cprintf>
f01039e9:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f01039ec:	83 c3 01             	add    $0x1,%ebx
f01039ef:	83 fb 10             	cmp    $0x10,%ebx
f01039f2:	74 07                	je     f01039fb <irq_setmask_8259A+0x70>
		if (~mask & (1<<i))
f01039f4:	0f a3 de             	bt     %ebx,%esi
f01039f7:	73 f3                	jae    f01039ec <irq_setmask_8259A+0x61>
f01039f9:	eb e0                	jmp    f01039db <irq_setmask_8259A+0x50>
	cprintf("\n");
f01039fb:	83 ec 0c             	sub    $0xc,%esp
f01039fe:	68 a0 7b 10 f0       	push   $0xf0107ba0
f0103a03:	e8 f0 00 00 00       	call   f0103af8 <cprintf>
f0103a08:	83 c4 10             	add    $0x10,%esp
f0103a0b:	eb 99                	jmp    f01039a6 <irq_setmask_8259A+0x1b>

f0103a0d <pic_init>:
{
f0103a0d:	f3 0f 1e fb          	endbr32 
f0103a11:	55                   	push   %ebp
f0103a12:	89 e5                	mov    %esp,%ebp
f0103a14:	57                   	push   %edi
f0103a15:	56                   	push   %esi
f0103a16:	53                   	push   %ebx
f0103a17:	83 ec 0c             	sub    $0xc,%esp
	didinit = 1;
f0103a1a:	c6 05 4c 72 23 f0 01 	movb   $0x1,0xf023724c
f0103a21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103a26:	bb 21 00 00 00       	mov    $0x21,%ebx
f0103a2b:	89 da                	mov    %ebx,%edx
f0103a2d:	ee                   	out    %al,(%dx)
f0103a2e:	b9 a1 00 00 00       	mov    $0xa1,%ecx
f0103a33:	89 ca                	mov    %ecx,%edx
f0103a35:	ee                   	out    %al,(%dx)
f0103a36:	bf 11 00 00 00       	mov    $0x11,%edi
f0103a3b:	be 20 00 00 00       	mov    $0x20,%esi
f0103a40:	89 f8                	mov    %edi,%eax
f0103a42:	89 f2                	mov    %esi,%edx
f0103a44:	ee                   	out    %al,(%dx)
f0103a45:	b8 20 00 00 00       	mov    $0x20,%eax
f0103a4a:	89 da                	mov    %ebx,%edx
f0103a4c:	ee                   	out    %al,(%dx)
f0103a4d:	b8 04 00 00 00       	mov    $0x4,%eax
f0103a52:	ee                   	out    %al,(%dx)
f0103a53:	b8 03 00 00 00       	mov    $0x3,%eax
f0103a58:	ee                   	out    %al,(%dx)
f0103a59:	bb a0 00 00 00       	mov    $0xa0,%ebx
f0103a5e:	89 f8                	mov    %edi,%eax
f0103a60:	89 da                	mov    %ebx,%edx
f0103a62:	ee                   	out    %al,(%dx)
f0103a63:	b8 28 00 00 00       	mov    $0x28,%eax
f0103a68:	89 ca                	mov    %ecx,%edx
f0103a6a:	ee                   	out    %al,(%dx)
f0103a6b:	b8 02 00 00 00       	mov    $0x2,%eax
f0103a70:	ee                   	out    %al,(%dx)
f0103a71:	b8 01 00 00 00       	mov    $0x1,%eax
f0103a76:	ee                   	out    %al,(%dx)
f0103a77:	bf 68 00 00 00       	mov    $0x68,%edi
f0103a7c:	89 f8                	mov    %edi,%eax
f0103a7e:	89 f2                	mov    %esi,%edx
f0103a80:	ee                   	out    %al,(%dx)
f0103a81:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0103a86:	89 c8                	mov    %ecx,%eax
f0103a88:	ee                   	out    %al,(%dx)
f0103a89:	89 f8                	mov    %edi,%eax
f0103a8b:	89 da                	mov    %ebx,%edx
f0103a8d:	ee                   	out    %al,(%dx)
f0103a8e:	89 c8                	mov    %ecx,%eax
f0103a90:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f0103a91:	0f b7 05 a8 33 12 f0 	movzwl 0xf01233a8,%eax
f0103a98:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103a9c:	75 08                	jne    f0103aa6 <pic_init+0x99>
}
f0103a9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103aa1:	5b                   	pop    %ebx
f0103aa2:	5e                   	pop    %esi
f0103aa3:	5f                   	pop    %edi
f0103aa4:	5d                   	pop    %ebp
f0103aa5:	c3                   	ret    
		irq_setmask_8259A(irq_mask_8259A);
f0103aa6:	83 ec 0c             	sub    $0xc,%esp
f0103aa9:	0f b7 c0             	movzwl %ax,%eax
f0103aac:	50                   	push   %eax
f0103aad:	e8 d9 fe ff ff       	call   f010398b <irq_setmask_8259A>
f0103ab2:	83 c4 10             	add    $0x10,%esp
}
f0103ab5:	eb e7                	jmp    f0103a9e <pic_init+0x91>

f0103ab7 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103ab7:	f3 0f 1e fb          	endbr32 
f0103abb:	55                   	push   %ebp
f0103abc:	89 e5                	mov    %esp,%ebp
f0103abe:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103ac1:	ff 75 08             	pushl  0x8(%ebp)
f0103ac4:	e8 ab cc ff ff       	call   f0100774 <cputchar>
	*cnt++;
}
f0103ac9:	83 c4 10             	add    $0x10,%esp
f0103acc:	c9                   	leave  
f0103acd:	c3                   	ret    

f0103ace <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103ace:	f3 0f 1e fb          	endbr32 
f0103ad2:	55                   	push   %ebp
f0103ad3:	89 e5                	mov    %esp,%ebp
f0103ad5:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103ad8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103adf:	ff 75 0c             	pushl  0xc(%ebp)
f0103ae2:	ff 75 08             	pushl  0x8(%ebp)
f0103ae5:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103ae8:	50                   	push   %eax
f0103ae9:	68 b7 3a 10 f0       	push   $0xf0103ab7
f0103aee:	e8 e3 1a 00 00       	call   f01055d6 <vprintfmt>
	return cnt;
}
f0103af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103af6:	c9                   	leave  
f0103af7:	c3                   	ret    

f0103af8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103af8:	f3 0f 1e fb          	endbr32 
f0103afc:	55                   	push   %ebp
f0103afd:	89 e5                	mov    %esp,%ebp
f0103aff:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103b02:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103b05:	50                   	push   %eax
f0103b06:	ff 75 08             	pushl  0x8(%ebp)
f0103b09:	e8 c0 ff ff ff       	call   f0103ace <vcprintf>
	va_end(ap);

	return cnt;
}
f0103b0e:	c9                   	leave  
f0103b0f:	c3                   	ret    

f0103b10 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103b10:	f3 0f 1e fb          	endbr32 
f0103b14:	55                   	push   %ebp
f0103b15:	89 e5                	mov    %esp,%ebp
f0103b17:	57                   	push   %edi
f0103b18:	56                   	push   %esi
f0103b19:	53                   	push   %ebx
f0103b1a:	83 ec 1c             	sub    $0x1c,%esp
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
    uint32_t cpu_id = thiscpu->cpu_id;
f0103b1d:	e8 28 28 00 00       	call   f010634a <cpunum>
f0103b22:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b25:	0f b6 b8 20 80 23 f0 	movzbl -0xfdc7fe0(%eax),%edi
f0103b2c:	89 f8                	mov    %edi,%eax
f0103b2e:	0f b6 d8             	movzbl %al,%ebx
    thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - (KSTKSIZE + KSTKGAP) * cpu_id;
f0103b31:	e8 14 28 00 00       	call   f010634a <cpunum>
f0103b36:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b39:	ba 00 f0 00 00       	mov    $0xf000,%edx
f0103b3e:	29 da                	sub    %ebx,%edx
f0103b40:	c1 e2 10             	shl    $0x10,%edx
f0103b43:	89 90 30 80 23 f0    	mov    %edx,-0xfdc7fd0(%eax)
    thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103b49:	e8 fc 27 00 00       	call   f010634a <cpunum>
f0103b4e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b51:	66 c7 80 34 80 23 f0 	movw   $0x10,-0xfdc7fcc(%eax)
f0103b58:	10 00 
    thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f0103b5a:	e8 eb 27 00 00       	call   f010634a <cpunum>
f0103b5f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b62:	66 c7 80 92 80 23 f0 	movw   $0x68,-0xfdc7f6e(%eax)
f0103b69:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cpu_id] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f0103b6b:	83 c3 05             	add    $0x5,%ebx
f0103b6e:	e8 d7 27 00 00       	call   f010634a <cpunum>
f0103b73:	89 c6                	mov    %eax,%esi
f0103b75:	e8 d0 27 00 00       	call   f010634a <cpunum>
f0103b7a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103b7d:	e8 c8 27 00 00       	call   f010634a <cpunum>
f0103b82:	66 c7 04 dd 40 33 12 	movw   $0x67,-0xfedccc0(,%ebx,8)
f0103b89:	f0 67 00 
f0103b8c:	6b f6 74             	imul   $0x74,%esi,%esi
f0103b8f:	81 c6 2c 80 23 f0    	add    $0xf023802c,%esi
f0103b95:	66 89 34 dd 42 33 12 	mov    %si,-0xfedccbe(,%ebx,8)
f0103b9c:	f0 
f0103b9d:	6b 55 e4 74          	imul   $0x74,-0x1c(%ebp),%edx
f0103ba1:	81 c2 2c 80 23 f0    	add    $0xf023802c,%edx
f0103ba7:	c1 ea 10             	shr    $0x10,%edx
f0103baa:	88 14 dd 44 33 12 f0 	mov    %dl,-0xfedccbc(,%ebx,8)
f0103bb1:	c6 04 dd 46 33 12 f0 	movb   $0x40,-0xfedccba(,%ebx,8)
f0103bb8:	40 
f0103bb9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bbc:	05 2c 80 23 f0       	add    $0xf023802c,%eax
f0103bc1:	c1 e8 18             	shr    $0x18,%eax
f0103bc4:	88 04 dd 47 33 12 f0 	mov    %al,-0xfedccb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpu_id].sd_s = 0;
f0103bcb:	c6 04 dd 45 33 12 f0 	movb   $0x89,-0xfedccbb(,%ebx,8)
f0103bd2:	89 

    ltr(GD_TSS0 + (cpu_id << 3));
f0103bd3:	89 f8                	mov    %edi,%eax
f0103bd5:	0f b6 f8             	movzbl %al,%edi
f0103bd8:	8d 3c fd 28 00 00 00 	lea    0x28(,%edi,8),%edi
	asm volatile("ltr %0" : : "r" (sel));
f0103bdf:	0f 00 df             	ltr    %di
	asm volatile("lidt (%0)" : : "r" (p));
f0103be2:	b8 ac 33 12 f0       	mov    $0xf01233ac,%eax
f0103be7:	0f 01 18             	lidtl  (%eax)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
    */
}
f0103bea:	83 c4 1c             	add    $0x1c,%esp
f0103bed:	5b                   	pop    %ebx
f0103bee:	5e                   	pop    %esi
f0103bef:	5f                   	pop    %edi
f0103bf0:	5d                   	pop    %ebp
f0103bf1:	c3                   	ret    

f0103bf2 <trap_init>:
{
f0103bf2:	f3 0f 1e fb          	endbr32 
f0103bf6:	55                   	push   %ebp
f0103bf7:	89 e5                	mov    %esp,%ebp
f0103bf9:	83 ec 08             	sub    $0x8,%esp
    SETGATE(idt[T_DIVIDE], 0, GD_KT, t_divide, 0);
f0103bfc:	b8 de 47 10 f0       	mov    $0xf01047de,%eax
f0103c01:	66 a3 60 72 23 f0    	mov    %ax,0xf0237260
f0103c07:	66 c7 05 62 72 23 f0 	movw   $0x8,0xf0237262
f0103c0e:	08 00 
f0103c10:	c6 05 64 72 23 f0 00 	movb   $0x0,0xf0237264
f0103c17:	c6 05 65 72 23 f0 8e 	movb   $0x8e,0xf0237265
f0103c1e:	c1 e8 10             	shr    $0x10,%eax
f0103c21:	66 a3 66 72 23 f0    	mov    %ax,0xf0237266
    SETGATE(idt[T_DEBUG], 0, GD_KT, t_debug, 0);
f0103c27:	b8 e8 47 10 f0       	mov    $0xf01047e8,%eax
f0103c2c:	66 a3 68 72 23 f0    	mov    %ax,0xf0237268
f0103c32:	66 c7 05 6a 72 23 f0 	movw   $0x8,0xf023726a
f0103c39:	08 00 
f0103c3b:	c6 05 6c 72 23 f0 00 	movb   $0x0,0xf023726c
f0103c42:	c6 05 6d 72 23 f0 8e 	movb   $0x8e,0xf023726d
f0103c49:	c1 e8 10             	shr    $0x10,%eax
f0103c4c:	66 a3 6e 72 23 f0    	mov    %ax,0xf023726e
    SETGATE(idt[T_NMI], 0, GD_KT, t_nmi, 0);
f0103c52:	b8 f2 47 10 f0       	mov    $0xf01047f2,%eax
f0103c57:	66 a3 70 72 23 f0    	mov    %ax,0xf0237270
f0103c5d:	66 c7 05 72 72 23 f0 	movw   $0x8,0xf0237272
f0103c64:	08 00 
f0103c66:	c6 05 74 72 23 f0 00 	movb   $0x0,0xf0237274
f0103c6d:	c6 05 75 72 23 f0 8e 	movb   $0x8e,0xf0237275
f0103c74:	c1 e8 10             	shr    $0x10,%eax
f0103c77:	66 a3 76 72 23 f0    	mov    %ax,0xf0237276
    SETGATE(idt[T_BRKPT], 0, GD_KT, t_brkpt, 3);
f0103c7d:	b8 fc 47 10 f0       	mov    $0xf01047fc,%eax
f0103c82:	66 a3 78 72 23 f0    	mov    %ax,0xf0237278
f0103c88:	66 c7 05 7a 72 23 f0 	movw   $0x8,0xf023727a
f0103c8f:	08 00 
f0103c91:	c6 05 7c 72 23 f0 00 	movb   $0x0,0xf023727c
f0103c98:	c6 05 7d 72 23 f0 ee 	movb   $0xee,0xf023727d
f0103c9f:	c1 e8 10             	shr    $0x10,%eax
f0103ca2:	66 a3 7e 72 23 f0    	mov    %ax,0xf023727e
    SETGATE(idt[T_OFLOW], 0, GD_KT, t_oflow, 0);
f0103ca8:	b8 06 48 10 f0       	mov    $0xf0104806,%eax
f0103cad:	66 a3 80 72 23 f0    	mov    %ax,0xf0237280
f0103cb3:	66 c7 05 82 72 23 f0 	movw   $0x8,0xf0237282
f0103cba:	08 00 
f0103cbc:	c6 05 84 72 23 f0 00 	movb   $0x0,0xf0237284
f0103cc3:	c6 05 85 72 23 f0 8e 	movb   $0x8e,0xf0237285
f0103cca:	c1 e8 10             	shr    $0x10,%eax
f0103ccd:	66 a3 86 72 23 f0    	mov    %ax,0xf0237286
    SETGATE(idt[T_BOUND], 0, GD_KT, t_bound, 0);
f0103cd3:	b8 10 48 10 f0       	mov    $0xf0104810,%eax
f0103cd8:	66 a3 88 72 23 f0    	mov    %ax,0xf0237288
f0103cde:	66 c7 05 8a 72 23 f0 	movw   $0x8,0xf023728a
f0103ce5:	08 00 
f0103ce7:	c6 05 8c 72 23 f0 00 	movb   $0x0,0xf023728c
f0103cee:	c6 05 8d 72 23 f0 8e 	movb   $0x8e,0xf023728d
f0103cf5:	c1 e8 10             	shr    $0x10,%eax
f0103cf8:	66 a3 8e 72 23 f0    	mov    %ax,0xf023728e
    SETGATE(idt[T_ILLOP], 0, GD_KT, t_illop, 0);
f0103cfe:	b8 1a 48 10 f0       	mov    $0xf010481a,%eax
f0103d03:	66 a3 90 72 23 f0    	mov    %ax,0xf0237290
f0103d09:	66 c7 05 92 72 23 f0 	movw   $0x8,0xf0237292
f0103d10:	08 00 
f0103d12:	c6 05 94 72 23 f0 00 	movb   $0x0,0xf0237294
f0103d19:	c6 05 95 72 23 f0 8e 	movb   $0x8e,0xf0237295
f0103d20:	c1 e8 10             	shr    $0x10,%eax
f0103d23:	66 a3 96 72 23 f0    	mov    %ax,0xf0237296
    SETGATE(idt[T_DEVICE], 0, GD_KT, t_device, 0);
f0103d29:	b8 24 48 10 f0       	mov    $0xf0104824,%eax
f0103d2e:	66 a3 98 72 23 f0    	mov    %ax,0xf0237298
f0103d34:	66 c7 05 9a 72 23 f0 	movw   $0x8,0xf023729a
f0103d3b:	08 00 
f0103d3d:	c6 05 9c 72 23 f0 00 	movb   $0x0,0xf023729c
f0103d44:	c6 05 9d 72 23 f0 8e 	movb   $0x8e,0xf023729d
f0103d4b:	c1 e8 10             	shr    $0x10,%eax
f0103d4e:	66 a3 9e 72 23 f0    	mov    %ax,0xf023729e
    SETGATE(idt[T_DBLFLT], 0, GD_KT, t_dblflt, 0);
f0103d54:	b8 2e 48 10 f0       	mov    $0xf010482e,%eax
f0103d59:	66 a3 a0 72 23 f0    	mov    %ax,0xf02372a0
f0103d5f:	66 c7 05 a2 72 23 f0 	movw   $0x8,0xf02372a2
f0103d66:	08 00 
f0103d68:	c6 05 a4 72 23 f0 00 	movb   $0x0,0xf02372a4
f0103d6f:	c6 05 a5 72 23 f0 8e 	movb   $0x8e,0xf02372a5
f0103d76:	c1 e8 10             	shr    $0x10,%eax
f0103d79:	66 a3 a6 72 23 f0    	mov    %ax,0xf02372a6
    SETGATE(idt[T_TSS], 0, GD_KT, t_tss, 0);
f0103d7f:	b8 36 48 10 f0       	mov    $0xf0104836,%eax
f0103d84:	66 a3 b0 72 23 f0    	mov    %ax,0xf02372b0
f0103d8a:	66 c7 05 b2 72 23 f0 	movw   $0x8,0xf02372b2
f0103d91:	08 00 
f0103d93:	c6 05 b4 72 23 f0 00 	movb   $0x0,0xf02372b4
f0103d9a:	c6 05 b5 72 23 f0 8e 	movb   $0x8e,0xf02372b5
f0103da1:	c1 e8 10             	shr    $0x10,%eax
f0103da4:	66 a3 b6 72 23 f0    	mov    %ax,0xf02372b6
    SETGATE(idt[T_SEGNP], 0, GD_KT, t_segnp, 0);
f0103daa:	b8 3e 48 10 f0       	mov    $0xf010483e,%eax
f0103daf:	66 a3 b8 72 23 f0    	mov    %ax,0xf02372b8
f0103db5:	66 c7 05 ba 72 23 f0 	movw   $0x8,0xf02372ba
f0103dbc:	08 00 
f0103dbe:	c6 05 bc 72 23 f0 00 	movb   $0x0,0xf02372bc
f0103dc5:	c6 05 bd 72 23 f0 8e 	movb   $0x8e,0xf02372bd
f0103dcc:	c1 e8 10             	shr    $0x10,%eax
f0103dcf:	66 a3 be 72 23 f0    	mov    %ax,0xf02372be
    SETGATE(idt[T_STACK], 0, GD_KT, t_stack, 0);
f0103dd5:	b8 46 48 10 f0       	mov    $0xf0104846,%eax
f0103dda:	66 a3 c0 72 23 f0    	mov    %ax,0xf02372c0
f0103de0:	66 c7 05 c2 72 23 f0 	movw   $0x8,0xf02372c2
f0103de7:	08 00 
f0103de9:	c6 05 c4 72 23 f0 00 	movb   $0x0,0xf02372c4
f0103df0:	c6 05 c5 72 23 f0 8e 	movb   $0x8e,0xf02372c5
f0103df7:	c1 e8 10             	shr    $0x10,%eax
f0103dfa:	66 a3 c6 72 23 f0    	mov    %ax,0xf02372c6
    SETGATE(idt[T_GPFLT], 0, GD_KT, t_gpflt, 0);
f0103e00:	b8 4e 48 10 f0       	mov    $0xf010484e,%eax
f0103e05:	66 a3 c8 72 23 f0    	mov    %ax,0xf02372c8
f0103e0b:	66 c7 05 ca 72 23 f0 	movw   $0x8,0xf02372ca
f0103e12:	08 00 
f0103e14:	c6 05 cc 72 23 f0 00 	movb   $0x0,0xf02372cc
f0103e1b:	c6 05 cd 72 23 f0 8e 	movb   $0x8e,0xf02372cd
f0103e22:	c1 e8 10             	shr    $0x10,%eax
f0103e25:	66 a3 ce 72 23 f0    	mov    %ax,0xf02372ce
    SETGATE(idt[T_PGFLT], 0, GD_KT, t_pgflt, 0);
f0103e2b:	b8 56 48 10 f0       	mov    $0xf0104856,%eax
f0103e30:	66 a3 d0 72 23 f0    	mov    %ax,0xf02372d0
f0103e36:	66 c7 05 d2 72 23 f0 	movw   $0x8,0xf02372d2
f0103e3d:	08 00 
f0103e3f:	c6 05 d4 72 23 f0 00 	movb   $0x0,0xf02372d4
f0103e46:	c6 05 d5 72 23 f0 8e 	movb   $0x8e,0xf02372d5
f0103e4d:	c1 e8 10             	shr    $0x10,%eax
f0103e50:	66 a3 d6 72 23 f0    	mov    %ax,0xf02372d6
    SETGATE(idt[T_FPERR], 0, GD_KT, t_fperr, 0);
f0103e56:	b8 5a 48 10 f0       	mov    $0xf010485a,%eax
f0103e5b:	66 a3 e0 72 23 f0    	mov    %ax,0xf02372e0
f0103e61:	66 c7 05 e2 72 23 f0 	movw   $0x8,0xf02372e2
f0103e68:	08 00 
f0103e6a:	c6 05 e4 72 23 f0 00 	movb   $0x0,0xf02372e4
f0103e71:	c6 05 e5 72 23 f0 8e 	movb   $0x8e,0xf02372e5
f0103e78:	c1 e8 10             	shr    $0x10,%eax
f0103e7b:	66 a3 e6 72 23 f0    	mov    %ax,0xf02372e6
    SETGATE(idt[T_ALIGN], 0, GD_KT, t_align, 0);
f0103e81:	b8 60 48 10 f0       	mov    $0xf0104860,%eax
f0103e86:	66 a3 e8 72 23 f0    	mov    %ax,0xf02372e8
f0103e8c:	66 c7 05 ea 72 23 f0 	movw   $0x8,0xf02372ea
f0103e93:	08 00 
f0103e95:	c6 05 ec 72 23 f0 00 	movb   $0x0,0xf02372ec
f0103e9c:	c6 05 ed 72 23 f0 8e 	movb   $0x8e,0xf02372ed
f0103ea3:	c1 e8 10             	shr    $0x10,%eax
f0103ea6:	66 a3 ee 72 23 f0    	mov    %ax,0xf02372ee
    SETGATE(idt[T_MCHK], 0, GD_KT, t_mchk, 0);
f0103eac:	b8 64 48 10 f0       	mov    $0xf0104864,%eax
f0103eb1:	66 a3 f0 72 23 f0    	mov    %ax,0xf02372f0
f0103eb7:	66 c7 05 f2 72 23 f0 	movw   $0x8,0xf02372f2
f0103ebe:	08 00 
f0103ec0:	c6 05 f4 72 23 f0 00 	movb   $0x0,0xf02372f4
f0103ec7:	c6 05 f5 72 23 f0 8e 	movb   $0x8e,0xf02372f5
f0103ece:	c1 e8 10             	shr    $0x10,%eax
f0103ed1:	66 a3 f6 72 23 f0    	mov    %ax,0xf02372f6
    SETGATE(idt[T_SIMDERR], 0, GD_KT, t_simderr, 0);
f0103ed7:	b8 6a 48 10 f0       	mov    $0xf010486a,%eax
f0103edc:	66 a3 f8 72 23 f0    	mov    %ax,0xf02372f8
f0103ee2:	66 c7 05 fa 72 23 f0 	movw   $0x8,0xf02372fa
f0103ee9:	08 00 
f0103eeb:	c6 05 fc 72 23 f0 00 	movb   $0x0,0xf02372fc
f0103ef2:	c6 05 fd 72 23 f0 8e 	movb   $0x8e,0xf02372fd
f0103ef9:	c1 e8 10             	shr    $0x10,%eax
f0103efc:	66 a3 fe 72 23 f0    	mov    %ax,0xf02372fe
    SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, t_irq_timer, 0);
f0103f02:	b8 70 48 10 f0       	mov    $0xf0104870,%eax
f0103f07:	66 a3 60 73 23 f0    	mov    %ax,0xf0237360
f0103f0d:	66 c7 05 62 73 23 f0 	movw   $0x8,0xf0237362
f0103f14:	08 00 
f0103f16:	c6 05 64 73 23 f0 00 	movb   $0x0,0xf0237364
f0103f1d:	c6 05 65 73 23 f0 8e 	movb   $0x8e,0xf0237365
f0103f24:	c1 e8 10             	shr    $0x10,%eax
f0103f27:	66 a3 66 73 23 f0    	mov    %ax,0xf0237366
    SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0, GD_KT, t_irq_kbd, 0);
f0103f2d:	b8 76 48 10 f0       	mov    $0xf0104876,%eax
f0103f32:	66 a3 68 73 23 f0    	mov    %ax,0xf0237368
f0103f38:	66 c7 05 6a 73 23 f0 	movw   $0x8,0xf023736a
f0103f3f:	08 00 
f0103f41:	c6 05 6c 73 23 f0 00 	movb   $0x0,0xf023736c
f0103f48:	c6 05 6d 73 23 f0 8e 	movb   $0x8e,0xf023736d
f0103f4f:	c1 e8 10             	shr    $0x10,%eax
f0103f52:	66 a3 6e 73 23 f0    	mov    %ax,0xf023736e
    SETGATE(idt[IRQ_OFFSET + 2], 0, GD_KT, t_irq_2, 0);
f0103f58:	b8 7c 48 10 f0       	mov    $0xf010487c,%eax
f0103f5d:	66 a3 70 73 23 f0    	mov    %ax,0xf0237370
f0103f63:	66 c7 05 72 73 23 f0 	movw   $0x8,0xf0237372
f0103f6a:	08 00 
f0103f6c:	c6 05 74 73 23 f0 00 	movb   $0x0,0xf0237374
f0103f73:	c6 05 75 73 23 f0 8e 	movb   $0x8e,0xf0237375
f0103f7a:	c1 e8 10             	shr    $0x10,%eax
f0103f7d:	66 a3 76 73 23 f0    	mov    %ax,0xf0237376
    SETGATE(idt[IRQ_OFFSET + 3], 0, GD_KT, t_irq_3, 0);
f0103f83:	b8 82 48 10 f0       	mov    $0xf0104882,%eax
f0103f88:	66 a3 78 73 23 f0    	mov    %ax,0xf0237378
f0103f8e:	66 c7 05 7a 73 23 f0 	movw   $0x8,0xf023737a
f0103f95:	08 00 
f0103f97:	c6 05 7c 73 23 f0 00 	movb   $0x0,0xf023737c
f0103f9e:	c6 05 7d 73 23 f0 8e 	movb   $0x8e,0xf023737d
f0103fa5:	c1 e8 10             	shr    $0x10,%eax
f0103fa8:	66 a3 7e 73 23 f0    	mov    %ax,0xf023737e
    SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0, GD_KT, t_irq_serial, 0);
f0103fae:	b8 88 48 10 f0       	mov    $0xf0104888,%eax
f0103fb3:	66 a3 80 73 23 f0    	mov    %ax,0xf0237380
f0103fb9:	66 c7 05 82 73 23 f0 	movw   $0x8,0xf0237382
f0103fc0:	08 00 
f0103fc2:	c6 05 84 73 23 f0 00 	movb   $0x0,0xf0237384
f0103fc9:	c6 05 85 73 23 f0 8e 	movb   $0x8e,0xf0237385
f0103fd0:	c1 e8 10             	shr    $0x10,%eax
f0103fd3:	66 a3 86 73 23 f0    	mov    %ax,0xf0237386
    SETGATE(idt[IRQ_OFFSET + 5], 0, GD_KT, t_irq_5, 0);
f0103fd9:	b8 8e 48 10 f0       	mov    $0xf010488e,%eax
f0103fde:	66 a3 88 73 23 f0    	mov    %ax,0xf0237388
f0103fe4:	66 c7 05 8a 73 23 f0 	movw   $0x8,0xf023738a
f0103feb:	08 00 
f0103fed:	c6 05 8c 73 23 f0 00 	movb   $0x0,0xf023738c
f0103ff4:	c6 05 8d 73 23 f0 8e 	movb   $0x8e,0xf023738d
f0103ffb:	c1 e8 10             	shr    $0x10,%eax
f0103ffe:	66 a3 8e 73 23 f0    	mov    %ax,0xf023738e
    SETGATE(idt[IRQ_OFFSET + 6], 0, GD_KT, t_irq_6, 0);
f0104004:	b8 94 48 10 f0       	mov    $0xf0104894,%eax
f0104009:	66 a3 90 73 23 f0    	mov    %ax,0xf0237390
f010400f:	66 c7 05 92 73 23 f0 	movw   $0x8,0xf0237392
f0104016:	08 00 
f0104018:	c6 05 94 73 23 f0 00 	movb   $0x0,0xf0237394
f010401f:	c6 05 95 73 23 f0 8e 	movb   $0x8e,0xf0237395
f0104026:	c1 e8 10             	shr    $0x10,%eax
f0104029:	66 a3 96 73 23 f0    	mov    %ax,0xf0237396
    SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, t_irq_spurious, 0);
f010402f:	b8 9a 48 10 f0       	mov    $0xf010489a,%eax
f0104034:	66 a3 98 73 23 f0    	mov    %ax,0xf0237398
f010403a:	66 c7 05 9a 73 23 f0 	movw   $0x8,0xf023739a
f0104041:	08 00 
f0104043:	c6 05 9c 73 23 f0 00 	movb   $0x0,0xf023739c
f010404a:	c6 05 9d 73 23 f0 8e 	movb   $0x8e,0xf023739d
f0104051:	c1 e8 10             	shr    $0x10,%eax
f0104054:	66 a3 9e 73 23 f0    	mov    %ax,0xf023739e
    SETGATE(idt[IRQ_OFFSET + 8], 0, GD_KT, t_irq_8, 0);
f010405a:	b8 a0 48 10 f0       	mov    $0xf01048a0,%eax
f010405f:	66 a3 a0 73 23 f0    	mov    %ax,0xf02373a0
f0104065:	66 c7 05 a2 73 23 f0 	movw   $0x8,0xf02373a2
f010406c:	08 00 
f010406e:	c6 05 a4 73 23 f0 00 	movb   $0x0,0xf02373a4
f0104075:	c6 05 a5 73 23 f0 8e 	movb   $0x8e,0xf02373a5
f010407c:	c1 e8 10             	shr    $0x10,%eax
f010407f:	66 a3 a6 73 23 f0    	mov    %ax,0xf02373a6
    SETGATE(idt[IRQ_OFFSET + 9], 0, GD_KT, t_irq_9, 0);
f0104085:	b8 a6 48 10 f0       	mov    $0xf01048a6,%eax
f010408a:	66 a3 a8 73 23 f0    	mov    %ax,0xf02373a8
f0104090:	66 c7 05 aa 73 23 f0 	movw   $0x8,0xf02373aa
f0104097:	08 00 
f0104099:	c6 05 ac 73 23 f0 00 	movb   $0x0,0xf02373ac
f01040a0:	c6 05 ad 73 23 f0 8e 	movb   $0x8e,0xf02373ad
f01040a7:	c1 e8 10             	shr    $0x10,%eax
f01040aa:	66 a3 ae 73 23 f0    	mov    %ax,0xf02373ae
    SETGATE(idt[IRQ_OFFSET + 10], 0, GD_KT, t_irq_10, 0);
f01040b0:	b8 ac 48 10 f0       	mov    $0xf01048ac,%eax
f01040b5:	66 a3 b0 73 23 f0    	mov    %ax,0xf02373b0
f01040bb:	66 c7 05 b2 73 23 f0 	movw   $0x8,0xf02373b2
f01040c2:	08 00 
f01040c4:	c6 05 b4 73 23 f0 00 	movb   $0x0,0xf02373b4
f01040cb:	c6 05 b5 73 23 f0 8e 	movb   $0x8e,0xf02373b5
f01040d2:	c1 e8 10             	shr    $0x10,%eax
f01040d5:	66 a3 b6 73 23 f0    	mov    %ax,0xf02373b6
    SETGATE(idt[IRQ_OFFSET + 11], 0, GD_KT, t_irq_11, 0);
f01040db:	b8 b2 48 10 f0       	mov    $0xf01048b2,%eax
f01040e0:	66 a3 b8 73 23 f0    	mov    %ax,0xf02373b8
f01040e6:	66 c7 05 ba 73 23 f0 	movw   $0x8,0xf02373ba
f01040ed:	08 00 
f01040ef:	c6 05 bc 73 23 f0 00 	movb   $0x0,0xf02373bc
f01040f6:	c6 05 bd 73 23 f0 8e 	movb   $0x8e,0xf02373bd
f01040fd:	c1 e8 10             	shr    $0x10,%eax
f0104100:	66 a3 be 73 23 f0    	mov    %ax,0xf02373be
    SETGATE(idt[IRQ_OFFSET + 12], 0, GD_KT, t_irq_12, 0);
f0104106:	b8 b8 48 10 f0       	mov    $0xf01048b8,%eax
f010410b:	66 a3 c0 73 23 f0    	mov    %ax,0xf02373c0
f0104111:	66 c7 05 c2 73 23 f0 	movw   $0x8,0xf02373c2
f0104118:	08 00 
f010411a:	c6 05 c4 73 23 f0 00 	movb   $0x0,0xf02373c4
f0104121:	c6 05 c5 73 23 f0 8e 	movb   $0x8e,0xf02373c5
f0104128:	c1 e8 10             	shr    $0x10,%eax
f010412b:	66 a3 c6 73 23 f0    	mov    %ax,0xf02373c6
    SETGATE(idt[IRQ_OFFSET + 13], 0, GD_KT, t_irq_13, 0);
f0104131:	b8 be 48 10 f0       	mov    $0xf01048be,%eax
f0104136:	66 a3 c8 73 23 f0    	mov    %ax,0xf02373c8
f010413c:	66 c7 05 ca 73 23 f0 	movw   $0x8,0xf02373ca
f0104143:	08 00 
f0104145:	c6 05 cc 73 23 f0 00 	movb   $0x0,0xf02373cc
f010414c:	c6 05 cd 73 23 f0 8e 	movb   $0x8e,0xf02373cd
f0104153:	c1 e8 10             	shr    $0x10,%eax
f0104156:	66 a3 ce 73 23 f0    	mov    %ax,0xf02373ce
    SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 0, GD_KT, t_irq_ide, 0);
f010415c:	b8 c4 48 10 f0       	mov    $0xf01048c4,%eax
f0104161:	66 a3 d0 73 23 f0    	mov    %ax,0xf02373d0
f0104167:	66 c7 05 d2 73 23 f0 	movw   $0x8,0xf02373d2
f010416e:	08 00 
f0104170:	c6 05 d4 73 23 f0 00 	movb   $0x0,0xf02373d4
f0104177:	c6 05 d5 73 23 f0 8e 	movb   $0x8e,0xf02373d5
f010417e:	c1 e8 10             	shr    $0x10,%eax
f0104181:	66 a3 d6 73 23 f0    	mov    %ax,0xf02373d6
    SETGATE(idt[IRQ_OFFSET + 15], 0, GD_KT, t_irq_15, 0);
f0104187:	b8 ca 48 10 f0       	mov    $0xf01048ca,%eax
f010418c:	66 a3 d8 73 23 f0    	mov    %ax,0xf02373d8
f0104192:	66 c7 05 da 73 23 f0 	movw   $0x8,0xf02373da
f0104199:	08 00 
f010419b:	c6 05 dc 73 23 f0 00 	movb   $0x0,0xf02373dc
f01041a2:	c6 05 dd 73 23 f0 8e 	movb   $0x8e,0xf02373dd
f01041a9:	c1 e8 10             	shr    $0x10,%eax
f01041ac:	66 a3 de 73 23 f0    	mov    %ax,0xf02373de
    SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall, 3);
f01041b2:	b8 d0 48 10 f0       	mov    $0xf01048d0,%eax
f01041b7:	66 a3 e0 73 23 f0    	mov    %ax,0xf02373e0
f01041bd:	66 c7 05 e2 73 23 f0 	movw   $0x8,0xf02373e2
f01041c4:	08 00 
f01041c6:	c6 05 e4 73 23 f0 00 	movb   $0x0,0xf02373e4
f01041cd:	c6 05 e5 73 23 f0 ee 	movb   $0xee,0xf02373e5
f01041d4:	c1 e8 10             	shr    $0x10,%eax
f01041d7:	66 a3 e6 73 23 f0    	mov    %ax,0xf02373e6
	trap_init_percpu();
f01041dd:	e8 2e f9 ff ff       	call   f0103b10 <trap_init_percpu>
}
f01041e2:	c9                   	leave  
f01041e3:	c3                   	ret    

f01041e4 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01041e4:	f3 0f 1e fb          	endbr32 
f01041e8:	55                   	push   %ebp
f01041e9:	89 e5                	mov    %esp,%ebp
f01041eb:	53                   	push   %ebx
f01041ec:	83 ec 0c             	sub    $0xc,%esp
f01041ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01041f2:	ff 33                	pushl  (%ebx)
f01041f4:	68 39 7d 10 f0       	push   $0xf0107d39
f01041f9:	e8 fa f8 ff ff       	call   f0103af8 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01041fe:	83 c4 08             	add    $0x8,%esp
f0104201:	ff 73 04             	pushl  0x4(%ebx)
f0104204:	68 48 7d 10 f0       	push   $0xf0107d48
f0104209:	e8 ea f8 ff ff       	call   f0103af8 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010420e:	83 c4 08             	add    $0x8,%esp
f0104211:	ff 73 08             	pushl  0x8(%ebx)
f0104214:	68 57 7d 10 f0       	push   $0xf0107d57
f0104219:	e8 da f8 ff ff       	call   f0103af8 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f010421e:	83 c4 08             	add    $0x8,%esp
f0104221:	ff 73 0c             	pushl  0xc(%ebx)
f0104224:	68 66 7d 10 f0       	push   $0xf0107d66
f0104229:	e8 ca f8 ff ff       	call   f0103af8 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f010422e:	83 c4 08             	add    $0x8,%esp
f0104231:	ff 73 10             	pushl  0x10(%ebx)
f0104234:	68 75 7d 10 f0       	push   $0xf0107d75
f0104239:	e8 ba f8 ff ff       	call   f0103af8 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f010423e:	83 c4 08             	add    $0x8,%esp
f0104241:	ff 73 14             	pushl  0x14(%ebx)
f0104244:	68 84 7d 10 f0       	push   $0xf0107d84
f0104249:	e8 aa f8 ff ff       	call   f0103af8 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010424e:	83 c4 08             	add    $0x8,%esp
f0104251:	ff 73 18             	pushl  0x18(%ebx)
f0104254:	68 93 7d 10 f0       	push   $0xf0107d93
f0104259:	e8 9a f8 ff ff       	call   f0103af8 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010425e:	83 c4 08             	add    $0x8,%esp
f0104261:	ff 73 1c             	pushl  0x1c(%ebx)
f0104264:	68 a2 7d 10 f0       	push   $0xf0107da2
f0104269:	e8 8a f8 ff ff       	call   f0103af8 <cprintf>
}
f010426e:	83 c4 10             	add    $0x10,%esp
f0104271:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104274:	c9                   	leave  
f0104275:	c3                   	ret    

f0104276 <print_trapframe>:
{
f0104276:	f3 0f 1e fb          	endbr32 
f010427a:	55                   	push   %ebp
f010427b:	89 e5                	mov    %esp,%ebp
f010427d:	56                   	push   %esi
f010427e:	53                   	push   %ebx
f010427f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0104282:	e8 c3 20 00 00       	call   f010634a <cpunum>
f0104287:	83 ec 04             	sub    $0x4,%esp
f010428a:	50                   	push   %eax
f010428b:	53                   	push   %ebx
f010428c:	68 06 7e 10 f0       	push   $0xf0107e06
f0104291:	e8 62 f8 ff ff       	call   f0103af8 <cprintf>
	print_regs(&tf->tf_regs);
f0104296:	89 1c 24             	mov    %ebx,(%esp)
f0104299:	e8 46 ff ff ff       	call   f01041e4 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f010429e:	83 c4 08             	add    $0x8,%esp
f01042a1:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01042a5:	50                   	push   %eax
f01042a6:	68 24 7e 10 f0       	push   $0xf0107e24
f01042ab:	e8 48 f8 ff ff       	call   f0103af8 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01042b0:	83 c4 08             	add    $0x8,%esp
f01042b3:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01042b7:	50                   	push   %eax
f01042b8:	68 37 7e 10 f0       	push   $0xf0107e37
f01042bd:	e8 36 f8 ff ff       	call   f0103af8 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01042c2:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f01042c5:	83 c4 10             	add    $0x10,%esp
f01042c8:	83 f8 13             	cmp    $0x13,%eax
f01042cb:	0f 86 da 00 00 00    	jbe    f01043ab <print_trapframe+0x135>
		return "System call";
f01042d1:	ba b1 7d 10 f0       	mov    $0xf0107db1,%edx
	if (trapno == T_SYSCALL)
f01042d6:	83 f8 30             	cmp    $0x30,%eax
f01042d9:	74 13                	je     f01042ee <print_trapframe+0x78>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01042db:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f01042de:	83 fa 0f             	cmp    $0xf,%edx
f01042e1:	ba bd 7d 10 f0       	mov    $0xf0107dbd,%edx
f01042e6:	b9 cc 7d 10 f0       	mov    $0xf0107dcc,%ecx
f01042eb:	0f 46 d1             	cmovbe %ecx,%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01042ee:	83 ec 04             	sub    $0x4,%esp
f01042f1:	52                   	push   %edx
f01042f2:	50                   	push   %eax
f01042f3:	68 4a 7e 10 f0       	push   $0xf0107e4a
f01042f8:	e8 fb f7 ff ff       	call   f0103af8 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01042fd:	83 c4 10             	add    $0x10,%esp
f0104300:	39 1d 60 7a 23 f0    	cmp    %ebx,0xf0237a60
f0104306:	0f 84 ab 00 00 00    	je     f01043b7 <print_trapframe+0x141>
	cprintf("  err  0x%08x", tf->tf_err);
f010430c:	83 ec 08             	sub    $0x8,%esp
f010430f:	ff 73 2c             	pushl  0x2c(%ebx)
f0104312:	68 6b 7e 10 f0       	push   $0xf0107e6b
f0104317:	e8 dc f7 ff ff       	call   f0103af8 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f010431c:	83 c4 10             	add    $0x10,%esp
f010431f:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104323:	0f 85 b1 00 00 00    	jne    f01043da <print_trapframe+0x164>
			tf->tf_err & 1 ? "protection" : "not-present");
f0104329:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f010432c:	a8 01                	test   $0x1,%al
f010432e:	b9 df 7d 10 f0       	mov    $0xf0107ddf,%ecx
f0104333:	ba ea 7d 10 f0       	mov    $0xf0107dea,%edx
f0104338:	0f 44 ca             	cmove  %edx,%ecx
f010433b:	a8 02                	test   $0x2,%al
f010433d:	be f6 7d 10 f0       	mov    $0xf0107df6,%esi
f0104342:	ba fc 7d 10 f0       	mov    $0xf0107dfc,%edx
f0104347:	0f 45 d6             	cmovne %esi,%edx
f010434a:	a8 04                	test   $0x4,%al
f010434c:	b8 01 7e 10 f0       	mov    $0xf0107e01,%eax
f0104351:	be 36 7f 10 f0       	mov    $0xf0107f36,%esi
f0104356:	0f 44 c6             	cmove  %esi,%eax
f0104359:	51                   	push   %ecx
f010435a:	52                   	push   %edx
f010435b:	50                   	push   %eax
f010435c:	68 79 7e 10 f0       	push   $0xf0107e79
f0104361:	e8 92 f7 ff ff       	call   f0103af8 <cprintf>
f0104366:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104369:	83 ec 08             	sub    $0x8,%esp
f010436c:	ff 73 30             	pushl  0x30(%ebx)
f010436f:	68 88 7e 10 f0       	push   $0xf0107e88
f0104374:	e8 7f f7 ff ff       	call   f0103af8 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104379:	83 c4 08             	add    $0x8,%esp
f010437c:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104380:	50                   	push   %eax
f0104381:	68 97 7e 10 f0       	push   $0xf0107e97
f0104386:	e8 6d f7 ff ff       	call   f0103af8 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f010438b:	83 c4 08             	add    $0x8,%esp
f010438e:	ff 73 38             	pushl  0x38(%ebx)
f0104391:	68 aa 7e 10 f0       	push   $0xf0107eaa
f0104396:	e8 5d f7 ff ff       	call   f0103af8 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f010439b:	83 c4 10             	add    $0x10,%esp
f010439e:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01043a2:	75 4b                	jne    f01043ef <print_trapframe+0x179>
}
f01043a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01043a7:	5b                   	pop    %ebx
f01043a8:	5e                   	pop    %esi
f01043a9:	5d                   	pop    %ebp
f01043aa:	c3                   	ret    
		return excnames[trapno];
f01043ab:	8b 14 85 e0 80 10 f0 	mov    -0xfef7f20(,%eax,4),%edx
f01043b2:	e9 37 ff ff ff       	jmp    f01042ee <print_trapframe+0x78>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01043b7:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01043bb:	0f 85 4b ff ff ff    	jne    f010430c <print_trapframe+0x96>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f01043c1:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01043c4:	83 ec 08             	sub    $0x8,%esp
f01043c7:	50                   	push   %eax
f01043c8:	68 5c 7e 10 f0       	push   $0xf0107e5c
f01043cd:	e8 26 f7 ff ff       	call   f0103af8 <cprintf>
f01043d2:	83 c4 10             	add    $0x10,%esp
f01043d5:	e9 32 ff ff ff       	jmp    f010430c <print_trapframe+0x96>
		cprintf("\n");
f01043da:	83 ec 0c             	sub    $0xc,%esp
f01043dd:	68 a0 7b 10 f0       	push   $0xf0107ba0
f01043e2:	e8 11 f7 ff ff       	call   f0103af8 <cprintf>
f01043e7:	83 c4 10             	add    $0x10,%esp
f01043ea:	e9 7a ff ff ff       	jmp    f0104369 <print_trapframe+0xf3>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01043ef:	83 ec 08             	sub    $0x8,%esp
f01043f2:	ff 73 3c             	pushl  0x3c(%ebx)
f01043f5:	68 b9 7e 10 f0       	push   $0xf0107eb9
f01043fa:	e8 f9 f6 ff ff       	call   f0103af8 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01043ff:	83 c4 08             	add    $0x8,%esp
f0104402:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104406:	50                   	push   %eax
f0104407:	68 c8 7e 10 f0       	push   $0xf0107ec8
f010440c:	e8 e7 f6 ff ff       	call   f0103af8 <cprintf>
f0104411:	83 c4 10             	add    $0x10,%esp
}
f0104414:	eb 8e                	jmp    f01043a4 <print_trapframe+0x12e>

f0104416 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104416:	f3 0f 1e fb          	endbr32 
f010441a:	55                   	push   %ebp
f010441b:	89 e5                	mov    %esp,%ebp
f010441d:	57                   	push   %edi
f010441e:	56                   	push   %esi
f010441f:	53                   	push   %ebx
f0104420:	83 ec 3c             	sub    $0x3c,%esp
f0104423:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104426:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
    if ((tf->tf_cs&0x3) == 0) {
f0104429:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010442d:	74 5a                	je     f0104489 <page_fault_handler+0x73>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
    if (curenv->env_pgfault_upcall == NULL) {
f010442f:	e8 16 1f 00 00       	call   f010634a <cpunum>
f0104434:	6b c0 74             	imul   $0x74,%eax,%eax
f0104437:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f010443d:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104441:	75 64                	jne    f01044a7 <page_fault_handler+0x91>
        // no pgfault handler!
        // Destroy the environment that caused the fault.
        cprintf("[%08x] user fault va %08x ip %08x\n",
f0104443:	8b 7b 30             	mov    0x30(%ebx),%edi
                curenv->env_id, fault_va, tf->tf_eip);
f0104446:	e8 ff 1e 00 00       	call   f010634a <cpunum>
        cprintf("[%08x] user fault va %08x ip %08x\n",
f010444b:	57                   	push   %edi
f010444c:	56                   	push   %esi
                curenv->env_id, fault_va, tf->tf_eip);
f010444d:	6b c0 74             	imul   $0x74,%eax,%eax
        cprintf("[%08x] user fault va %08x ip %08x\n",
f0104450:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f0104456:	ff 70 48             	pushl  0x48(%eax)
f0104459:	68 b0 80 10 f0       	push   $0xf01080b0
f010445e:	e8 95 f6 ff ff       	call   f0103af8 <cprintf>
        print_trapframe(tf);
f0104463:	89 1c 24             	mov    %ebx,(%esp)
f0104466:	e8 0b fe ff ff       	call   f0104276 <print_trapframe>
        env_destroy(curenv);
f010446b:	e8 da 1e 00 00       	call   f010634a <cpunum>
f0104470:	83 c4 04             	add    $0x4,%esp
f0104473:	6b c0 74             	imul   $0x74,%eax,%eax
f0104476:	ff b0 28 80 23 f0    	pushl  -0xfdc7fd8(%eax)
f010447c:	e8 40 f3 ff ff       	call   f01037c1 <env_destroy>

    tf->tf_eip = (uintptr_t) curenv->env_pgfault_upcall;

    env_run(curenv);

}
f0104481:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104484:	5b                   	pop    %ebx
f0104485:	5e                   	pop    %esi
f0104486:	5f                   	pop    %edi
f0104487:	5d                   	pop    %ebp
f0104488:	c3                   	ret    
        print_trapframe(tf);
f0104489:	83 ec 0c             	sub    $0xc,%esp
f010448c:	53                   	push   %ebx
f010448d:	e8 e4 fd ff ff       	call   f0104276 <print_trapframe>
        panic("page_fault_handler: kernel page fault at %p\n", fault_va);
f0104492:	56                   	push   %esi
f0104493:	68 80 80 10 f0       	push   $0xf0108080
f0104498:	68 95 01 00 00       	push   $0x195
f010449d:	68 db 7e 10 f0       	push   $0xf0107edb
f01044a2:	e8 99 bb ff ff       	call   f0100040 <_panic>
    utf.utf_err = tf->tf_err;
f01044a7:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01044aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
    utf.utf_regs = tf->tf_regs;
f01044ad:	8b 03                	mov    (%ebx),%eax
f01044af:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01044b2:	8b 43 04             	mov    0x4(%ebx),%eax
f01044b5:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01044b8:	8b 43 08             	mov    0x8(%ebx),%eax
f01044bb:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01044be:	8b 43 0c             	mov    0xc(%ebx),%eax
f01044c1:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01044c4:	8b 43 10             	mov    0x10(%ebx),%eax
f01044c7:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01044ca:	8b 43 14             	mov    0x14(%ebx),%eax
f01044cd:	89 45 c0             	mov    %eax,-0x40(%ebp)
f01044d0:	8b 43 18             	mov    0x18(%ebx),%eax
f01044d3:	89 45 bc             	mov    %eax,-0x44(%ebp)
f01044d6:	8b 43 1c             	mov    0x1c(%ebx),%eax
f01044d9:	89 45 b8             	mov    %eax,-0x48(%ebp)
    utf.utf_eip = tf->tf_eip;
f01044dc:	8b 43 30             	mov    0x30(%ebx),%eax
f01044df:	89 45 dc             	mov    %eax,-0x24(%ebp)
    utf.utf_eflags = tf->tf_eflags;
f01044e2:	8b 43 38             	mov    0x38(%ebx),%eax
f01044e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
    utf.utf_esp = tf->tf_esp;
f01044e8:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01044eb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (ROUNDUP(utf.utf_esp, PGSIZE) == UXSTACKTOP) {
f01044ee:	05 ff 0f 00 00       	add    $0xfff,%eax
f01044f3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
        tf->tf_esp = UXSTACKTOP;
f01044f8:	bf 00 00 c0 ee       	mov    $0xeec00000,%edi
    if (ROUNDUP(utf.utf_esp, PGSIZE) == UXSTACKTOP) {
f01044fd:	3d 00 00 c0 ee       	cmp    $0xeec00000,%eax
f0104502:	0f 84 95 00 00 00    	je     f010459d <page_fault_handler+0x187>
    tf->tf_esp -= sizeof(struct UTrapframe);
f0104508:	83 ef 34             	sub    $0x34,%edi
f010450b:	89 7b 3c             	mov    %edi,0x3c(%ebx)
    user_mem_assert(curenv, (void *) tf->tf_esp, sizeof(struct UTrapframe),
f010450e:	e8 37 1e 00 00       	call   f010634a <cpunum>
f0104513:	6a 07                	push   $0x7
f0104515:	6a 34                	push   $0x34
f0104517:	57                   	push   %edi
f0104518:	6b c0 74             	imul   $0x74,%eax,%eax
f010451b:	ff b0 28 80 23 f0    	pushl  -0xfdc7fd8(%eax)
f0104521:	e8 90 eb ff ff       	call   f01030b6 <user_mem_assert>
    *((struct UTrapframe *) tf->tf_esp) = utf;
f0104526:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104529:	89 30                	mov    %esi,(%eax)
f010452b:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010452e:	89 50 04             	mov    %edx,0x4(%eax)
f0104531:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104534:	89 48 08             	mov    %ecx,0x8(%eax)
f0104537:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010453a:	89 50 0c             	mov    %edx,0xc(%eax)
f010453d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0104540:	89 48 10             	mov    %ecx,0x10(%eax)
f0104543:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0104546:	89 50 14             	mov    %edx,0x14(%eax)
f0104549:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f010454c:	89 48 18             	mov    %ecx,0x18(%eax)
f010454f:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0104552:	89 50 1c             	mov    %edx,0x1c(%eax)
f0104555:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104558:	89 48 20             	mov    %ecx,0x20(%eax)
f010455b:	8b 55 b8             	mov    -0x48(%ebp),%edx
f010455e:	89 50 24             	mov    %edx,0x24(%eax)
f0104561:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0104564:	89 48 28             	mov    %ecx,0x28(%eax)
f0104567:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010456a:	89 50 2c             	mov    %edx,0x2c(%eax)
f010456d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0104570:	89 48 30             	mov    %ecx,0x30(%eax)
    tf->tf_eip = (uintptr_t) curenv->env_pgfault_upcall;
f0104573:	e8 d2 1d 00 00       	call   f010634a <cpunum>
f0104578:	6b c0 74             	imul   $0x74,%eax,%eax
f010457b:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f0104581:	8b 40 64             	mov    0x64(%eax),%eax
f0104584:	89 43 30             	mov    %eax,0x30(%ebx)
    env_run(curenv);
f0104587:	e8 be 1d 00 00       	call   f010634a <cpunum>
f010458c:	83 c4 04             	add    $0x4,%esp
f010458f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104592:	ff b0 28 80 23 f0    	pushl  -0xfdc7fd8(%eax)
f0104598:	e8 ea f2 ff ff       	call   f0103887 <env_run>
        tf->tf_esp -= 4;
f010459d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01045a0:	8d 78 fc             	lea    -0x4(%eax),%edi
f01045a3:	e9 60 ff ff ff       	jmp    f0104508 <page_fault_handler+0xf2>

f01045a8 <trap>:
{
f01045a8:	f3 0f 1e fb          	endbr32 
f01045ac:	55                   	push   %ebp
f01045ad:	89 e5                	mov    %esp,%ebp
f01045af:	57                   	push   %edi
f01045b0:	56                   	push   %esi
f01045b1:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f01045b4:	fc                   	cld    
	if (panicstr)
f01045b5:	83 3d 80 7e 23 f0 00 	cmpl   $0x0,0xf0237e80
f01045bc:	74 01                	je     f01045bf <trap+0x17>
		asm volatile("hlt");
f01045be:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01045bf:	e8 86 1d 00 00       	call   f010634a <cpunum>
f01045c4:	6b d0 74             	imul   $0x74,%eax,%edx
f01045c7:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f01045ca:	b8 01 00 00 00       	mov    $0x1,%eax
f01045cf:	f0 87 82 20 80 23 f0 	lock xchg %eax,-0xfdc7fe0(%edx)
f01045d6:	83 f8 02             	cmp    $0x2,%eax
f01045d9:	74 62                	je     f010463d <trap+0x95>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f01045db:	9c                   	pushf  
f01045dc:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f01045dd:	f6 c4 02             	test   $0x2,%ah
f01045e0:	75 6d                	jne    f010464f <trap+0xa7>
	if ((tf->tf_cs & 3) == 3) {
f01045e2:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01045e6:	83 e0 03             	and    $0x3,%eax
f01045e9:	66 83 f8 03          	cmp    $0x3,%ax
f01045ed:	74 79                	je     f0104668 <trap+0xc0>
	last_tf = tf;
f01045ef:	89 35 60 7a 23 f0    	mov    %esi,0xf0237a60
    switch (tf->tf_trapno) {
f01045f5:	8b 46 28             	mov    0x28(%esi),%eax
f01045f8:	83 f8 0e             	cmp    $0xe,%eax
f01045fb:	0f 84 1f 01 00 00    	je     f0104720 <trap+0x178>
f0104601:	0f 86 06 01 00 00    	jbe    f010470d <trap+0x165>
f0104607:	83 f8 20             	cmp    $0x20,%eax
f010460a:	0f 84 46 01 00 00    	je     f0104756 <trap+0x1ae>
f0104610:	83 f8 30             	cmp    $0x30,%eax
f0104613:	0f 85 47 01 00 00    	jne    f0104760 <trap+0x1b8>
            int32_t ret = syscall(tf->tf_regs.reg_eax,
f0104619:	83 ec 08             	sub    $0x8,%esp
f010461c:	ff 76 04             	pushl  0x4(%esi)
f010461f:	ff 36                	pushl  (%esi)
f0104621:	ff 76 10             	pushl  0x10(%esi)
f0104624:	ff 76 18             	pushl  0x18(%esi)
f0104627:	ff 76 14             	pushl  0x14(%esi)
f010462a:	ff 76 1c             	pushl  0x1c(%esi)
f010462d:	e8 1a 04 00 00       	call   f0104a4c <syscall>
            tf->tf_regs.reg_eax = ret;
f0104632:	89 46 1c             	mov    %eax,0x1c(%esi)
            return;
f0104635:	83 c4 20             	add    $0x20,%esp
f0104638:	e9 ef 00 00 00       	jmp    f010472c <trap+0x184>
	spin_lock(&kernel_lock);
f010463d:	83 ec 0c             	sub    $0xc,%esp
f0104640:	68 c0 33 12 f0       	push   $0xf01233c0
f0104645:	e8 88 1f 00 00       	call   f01065d2 <spin_lock>
}
f010464a:	83 c4 10             	add    $0x10,%esp
f010464d:	eb 8c                	jmp    f01045db <trap+0x33>
	assert(!(read_eflags() & FL_IF));
f010464f:	68 e7 7e 10 f0       	push   $0xf0107ee7
f0104654:	68 d9 78 10 f0       	push   $0xf01078d9
f0104659:	68 5d 01 00 00       	push   $0x15d
f010465e:	68 db 7e 10 f0       	push   $0xf0107edb
f0104663:	e8 d8 b9 ff ff       	call   f0100040 <_panic>
	spin_lock(&kernel_lock);
f0104668:	83 ec 0c             	sub    $0xc,%esp
f010466b:	68 c0 33 12 f0       	push   $0xf01233c0
f0104670:	e8 5d 1f 00 00       	call   f01065d2 <spin_lock>
		assert(curenv);
f0104675:	e8 d0 1c 00 00       	call   f010634a <cpunum>
f010467a:	6b c0 74             	imul   $0x74,%eax,%eax
f010467d:	83 c4 10             	add    $0x10,%esp
f0104680:	83 b8 28 80 23 f0 00 	cmpl   $0x0,-0xfdc7fd8(%eax)
f0104687:	74 3e                	je     f01046c7 <trap+0x11f>
		if (curenv->env_status == ENV_DYING) {
f0104689:	e8 bc 1c 00 00       	call   f010634a <cpunum>
f010468e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104691:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f0104697:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f010469b:	74 43                	je     f01046e0 <trap+0x138>
		curenv->env_tf = *tf;
f010469d:	e8 a8 1c 00 00       	call   f010634a <cpunum>
f01046a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01046a5:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f01046ab:	b9 11 00 00 00       	mov    $0x11,%ecx
f01046b0:	89 c7                	mov    %eax,%edi
f01046b2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f01046b4:	e8 91 1c 00 00       	call   f010634a <cpunum>
f01046b9:	6b c0 74             	imul   $0x74,%eax,%eax
f01046bc:	8b b0 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%esi
f01046c2:	e9 28 ff ff ff       	jmp    f01045ef <trap+0x47>
		assert(curenv);
f01046c7:	68 00 7f 10 f0       	push   $0xf0107f00
f01046cc:	68 d9 78 10 f0       	push   $0xf01078d9
f01046d1:	68 65 01 00 00       	push   $0x165
f01046d6:	68 db 7e 10 f0       	push   $0xf0107edb
f01046db:	e8 60 b9 ff ff       	call   f0100040 <_panic>
			env_free(curenv);
f01046e0:	e8 65 1c 00 00       	call   f010634a <cpunum>
f01046e5:	83 ec 0c             	sub    $0xc,%esp
f01046e8:	6b c0 74             	imul   $0x74,%eax,%eax
f01046eb:	ff b0 28 80 23 f0    	pushl  -0xfdc7fd8(%eax)
f01046f1:	e8 ea ee ff ff       	call   f01035e0 <env_free>
			curenv = NULL;
f01046f6:	e8 4f 1c 00 00       	call   f010634a <cpunum>
f01046fb:	6b c0 74             	imul   $0x74,%eax,%eax
f01046fe:	c7 80 28 80 23 f0 00 	movl   $0x0,-0xfdc7fd8(%eax)
f0104705:	00 00 00 
			sched_yield();
f0104708:	e8 a9 02 00 00       	call   f01049b6 <sched_yield>
    switch (tf->tf_trapno) {
f010470d:	83 f8 03             	cmp    $0x3,%eax
f0104710:	75 6d                	jne    f010477f <trap+0x1d7>
            return monitor(tf);
f0104712:	83 ec 0c             	sub    $0xc,%esp
f0104715:	56                   	push   %esi
f0104716:	e8 8c c2 ff ff       	call   f01009a7 <monitor>
f010471b:	83 c4 10             	add    $0x10,%esp
f010471e:	eb 0c                	jmp    f010472c <trap+0x184>
            return page_fault_handler(tf);
f0104720:	83 ec 0c             	sub    $0xc,%esp
f0104723:	56                   	push   %esi
f0104724:	e8 ed fc ff ff       	call   f0104416 <page_fault_handler>
f0104729:	83 c4 10             	add    $0x10,%esp
	if (curenv && curenv->env_status == ENV_RUNNING)
f010472c:	e8 19 1c 00 00       	call   f010634a <cpunum>
f0104731:	6b c0 74             	imul   $0x74,%eax,%eax
f0104734:	83 b8 28 80 23 f0 00 	cmpl   $0x0,-0xfdc7fd8(%eax)
f010473b:	74 14                	je     f0104751 <trap+0x1a9>
f010473d:	e8 08 1c 00 00       	call   f010634a <cpunum>
f0104742:	6b c0 74             	imul   $0x74,%eax,%eax
f0104745:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f010474b:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010474f:	74 76                	je     f01047c7 <trap+0x21f>
		sched_yield();
f0104751:	e8 60 02 00 00       	call   f01049b6 <sched_yield>
            lapic_eoi();
f0104756:	e8 3e 1d 00 00       	call   f0106499 <lapic_eoi>
            sched_yield();
f010475b:	e8 56 02 00 00       	call   f01049b6 <sched_yield>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104760:	83 f8 27             	cmp    $0x27,%eax
f0104763:	75 1a                	jne    f010477f <trap+0x1d7>
		cprintf("Spurious interrupt on irq 7\n");
f0104765:	83 ec 0c             	sub    $0xc,%esp
f0104768:	68 07 7f 10 f0       	push   $0xf0107f07
f010476d:	e8 86 f3 ff ff       	call   f0103af8 <cprintf>
		print_trapframe(tf);
f0104772:	89 34 24             	mov    %esi,(%esp)
f0104775:	e8 fc fa ff ff       	call   f0104276 <print_trapframe>
		return;
f010477a:	83 c4 10             	add    $0x10,%esp
f010477d:	eb ad                	jmp    f010472c <trap+0x184>
	print_trapframe(tf);
f010477f:	83 ec 0c             	sub    $0xc,%esp
f0104782:	56                   	push   %esi
f0104783:	e8 ee fa ff ff       	call   f0104276 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104788:	83 c4 10             	add    $0x10,%esp
f010478b:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104790:	74 1e                	je     f01047b0 <trap+0x208>
		env_destroy(curenv);
f0104792:	e8 b3 1b 00 00       	call   f010634a <cpunum>
f0104797:	83 ec 0c             	sub    $0xc,%esp
f010479a:	6b c0 74             	imul   $0x74,%eax,%eax
f010479d:	ff b0 28 80 23 f0    	pushl  -0xfdc7fd8(%eax)
f01047a3:	e8 19 f0 ff ff       	call   f01037c1 <env_destroy>
		return;
f01047a8:	83 c4 10             	add    $0x10,%esp
f01047ab:	e9 7c ff ff ff       	jmp    f010472c <trap+0x184>
		panic("unhandled trap in kernel");
f01047b0:	83 ec 04             	sub    $0x4,%esp
f01047b3:	68 24 7f 10 f0       	push   $0xf0107f24
f01047b8:	68 43 01 00 00       	push   $0x143
f01047bd:	68 db 7e 10 f0       	push   $0xf0107edb
f01047c2:	e8 79 b8 ff ff       	call   f0100040 <_panic>
		env_run(curenv);
f01047c7:	e8 7e 1b 00 00       	call   f010634a <cpunum>
f01047cc:	83 ec 0c             	sub    $0xc,%esp
f01047cf:	6b c0 74             	imul   $0x74,%eax,%eax
f01047d2:	ff b0 28 80 23 f0    	pushl  -0xfdc7fd8(%eax)
f01047d8:	e8 aa f0 ff ff       	call   f0103887 <env_run>
f01047dd:	90                   	nop

f01047de <t_divide>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(t_divide, T_DIVIDE);    // 0
f01047de:	6a 00                	push   $0x0
f01047e0:	6a 00                	push   $0x0
f01047e2:	e9 ef 00 00 00       	jmp    f01048d6 <_alltraps>
f01047e7:	90                   	nop

f01047e8 <t_debug>:
TRAPHANDLER_NOEC(t_debug, T_DEBUG);      // 1
f01047e8:	6a 00                	push   $0x0
f01047ea:	6a 01                	push   $0x1
f01047ec:	e9 e5 00 00 00       	jmp    f01048d6 <_alltraps>
f01047f1:	90                   	nop

f01047f2 <t_nmi>:
TRAPHANDLER_NOEC(t_nmi, T_NMI);          // 2
f01047f2:	6a 00                	push   $0x0
f01047f4:	6a 02                	push   $0x2
f01047f6:	e9 db 00 00 00       	jmp    f01048d6 <_alltraps>
f01047fb:	90                   	nop

f01047fc <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT);      // 3
f01047fc:	6a 00                	push   $0x0
f01047fe:	6a 03                	push   $0x3
f0104800:	e9 d1 00 00 00       	jmp    f01048d6 <_alltraps>
f0104805:	90                   	nop

f0104806 <t_oflow>:
TRAPHANDLER_NOEC(t_oflow, T_OFLOW);      // 4
f0104806:	6a 00                	push   $0x0
f0104808:	6a 04                	push   $0x4
f010480a:	e9 c7 00 00 00       	jmp    f01048d6 <_alltraps>
f010480f:	90                   	nop

f0104810 <t_bound>:
TRAPHANDLER_NOEC(t_bound, T_BOUND);      // 5
f0104810:	6a 00                	push   $0x0
f0104812:	6a 05                	push   $0x5
f0104814:	e9 bd 00 00 00       	jmp    f01048d6 <_alltraps>
f0104819:	90                   	nop

f010481a <t_illop>:
TRAPHANDLER_NOEC(t_illop, T_ILLOP);      // 6
f010481a:	6a 00                	push   $0x0
f010481c:	6a 06                	push   $0x6
f010481e:	e9 b3 00 00 00       	jmp    f01048d6 <_alltraps>
f0104823:	90                   	nop

f0104824 <t_device>:
TRAPHANDLER_NOEC(t_device, T_DEVICE);    // 7
f0104824:	6a 00                	push   $0x0
f0104826:	6a 07                	push   $0x7
f0104828:	e9 a9 00 00 00       	jmp    f01048d6 <_alltraps>
f010482d:	90                   	nop

f010482e <t_dblflt>:

TRAPHANDLER(t_dblflt, T_DBLFLT);    // 8
f010482e:	6a 08                	push   $0x8
f0104830:	e9 a1 00 00 00       	jmp    f01048d6 <_alltraps>
f0104835:	90                   	nop

f0104836 <t_tss>:

TRAPHANDLER(t_tss, T_TSS);          // 10
f0104836:	6a 0a                	push   $0xa
f0104838:	e9 99 00 00 00       	jmp    f01048d6 <_alltraps>
f010483d:	90                   	nop

f010483e <t_segnp>:
TRAPHANDLER(t_segnp, T_SEGNP);      // 11
f010483e:	6a 0b                	push   $0xb
f0104840:	e9 91 00 00 00       	jmp    f01048d6 <_alltraps>
f0104845:	90                   	nop

f0104846 <t_stack>:
TRAPHANDLER(t_stack, T_STACK);      // 12
f0104846:	6a 0c                	push   $0xc
f0104848:	e9 89 00 00 00       	jmp    f01048d6 <_alltraps>
f010484d:	90                   	nop

f010484e <t_gpflt>:
TRAPHANDLER(t_gpflt, T_GPFLT);      // 13
f010484e:	6a 0d                	push   $0xd
f0104850:	e9 81 00 00 00       	jmp    f01048d6 <_alltraps>
f0104855:	90                   	nop

f0104856 <t_pgflt>:
TRAPHANDLER(t_pgflt, T_PGFLT);      // 14
f0104856:	6a 0e                	push   $0xe
f0104858:	eb 7c                	jmp    f01048d6 <_alltraps>

f010485a <t_fperr>:

TRAPHANDLER_NOEC(t_fperr, T_FPERR);      // 16
f010485a:	6a 00                	push   $0x0
f010485c:	6a 10                	push   $0x10
f010485e:	eb 76                	jmp    f01048d6 <_alltraps>

f0104860 <t_align>:

TRAPHANDLER(t_align, T_ALIGN);      // 17
f0104860:	6a 11                	push   $0x11
f0104862:	eb 72                	jmp    f01048d6 <_alltraps>

f0104864 <t_mchk>:

TRAPHANDLER_NOEC(t_mchk, T_MCHK);        // 18
f0104864:	6a 00                	push   $0x0
f0104866:	6a 12                	push   $0x12
f0104868:	eb 6c                	jmp    f01048d6 <_alltraps>

f010486a <t_simderr>:
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR);  // 19
f010486a:	6a 00                	push   $0x0
f010486c:	6a 13                	push   $0x13
f010486e:	eb 66                	jmp    f01048d6 <_alltraps>

f0104870 <t_irq_timer>:


TRAPHANDLER_NOEC(t_irq_timer, IRQ_OFFSET + IRQ_TIMER); // 32 + 0
f0104870:	6a 00                	push   $0x0
f0104872:	6a 20                	push   $0x20
f0104874:	eb 60                	jmp    f01048d6 <_alltraps>

f0104876 <t_irq_kbd>:
TRAPHANDLER_NOEC(t_irq_kbd, IRQ_OFFSET + IRQ_KBD); // 32 + 1
f0104876:	6a 00                	push   $0x0
f0104878:	6a 21                	push   $0x21
f010487a:	eb 5a                	jmp    f01048d6 <_alltraps>

f010487c <t_irq_2>:
TRAPHANDLER_NOEC(t_irq_2, IRQ_OFFSET + 2); // 32 + 2
f010487c:	6a 00                	push   $0x0
f010487e:	6a 22                	push   $0x22
f0104880:	eb 54                	jmp    f01048d6 <_alltraps>

f0104882 <t_irq_3>:
TRAPHANDLER_NOEC(t_irq_3, IRQ_OFFSET + 3); // 32 + 3
f0104882:	6a 00                	push   $0x0
f0104884:	6a 23                	push   $0x23
f0104886:	eb 4e                	jmp    f01048d6 <_alltraps>

f0104888 <t_irq_serial>:
TRAPHANDLER_NOEC(t_irq_serial, IRQ_OFFSET + IRQ_SERIAL); // 32 + 4
f0104888:	6a 00                	push   $0x0
f010488a:	6a 24                	push   $0x24
f010488c:	eb 48                	jmp    f01048d6 <_alltraps>

f010488e <t_irq_5>:
TRAPHANDLER_NOEC(t_irq_5, IRQ_OFFSET + 5); // 32 + 5
f010488e:	6a 00                	push   $0x0
f0104890:	6a 25                	push   $0x25
f0104892:	eb 42                	jmp    f01048d6 <_alltraps>

f0104894 <t_irq_6>:
TRAPHANDLER_NOEC(t_irq_6, IRQ_OFFSET + 6); // 32 + 6
f0104894:	6a 00                	push   $0x0
f0104896:	6a 26                	push   $0x26
f0104898:	eb 3c                	jmp    f01048d6 <_alltraps>

f010489a <t_irq_spurious>:
TRAPHANDLER_NOEC(t_irq_spurious, IRQ_OFFSET + IRQ_SPURIOUS); // 32 + 7
f010489a:	6a 00                	push   $0x0
f010489c:	6a 27                	push   $0x27
f010489e:	eb 36                	jmp    f01048d6 <_alltraps>

f01048a0 <t_irq_8>:
TRAPHANDLER_NOEC(t_irq_8, IRQ_OFFSET + 8); // 32 + 8
f01048a0:	6a 00                	push   $0x0
f01048a2:	6a 28                	push   $0x28
f01048a4:	eb 30                	jmp    f01048d6 <_alltraps>

f01048a6 <t_irq_9>:
TRAPHANDLER_NOEC(t_irq_9, IRQ_OFFSET + 9); // 32 + 9
f01048a6:	6a 00                	push   $0x0
f01048a8:	6a 29                	push   $0x29
f01048aa:	eb 2a                	jmp    f01048d6 <_alltraps>

f01048ac <t_irq_10>:
TRAPHANDLER_NOEC(t_irq_10, IRQ_OFFSET + 10); // 32 + 10
f01048ac:	6a 00                	push   $0x0
f01048ae:	6a 2a                	push   $0x2a
f01048b0:	eb 24                	jmp    f01048d6 <_alltraps>

f01048b2 <t_irq_11>:
TRAPHANDLER_NOEC(t_irq_11, IRQ_OFFSET + 11); // 32 + 11
f01048b2:	6a 00                	push   $0x0
f01048b4:	6a 2b                	push   $0x2b
f01048b6:	eb 1e                	jmp    f01048d6 <_alltraps>

f01048b8 <t_irq_12>:
TRAPHANDLER_NOEC(t_irq_12, IRQ_OFFSET + 12); // 32 + 12
f01048b8:	6a 00                	push   $0x0
f01048ba:	6a 2c                	push   $0x2c
f01048bc:	eb 18                	jmp    f01048d6 <_alltraps>

f01048be <t_irq_13>:
TRAPHANDLER_NOEC(t_irq_13, IRQ_OFFSET + 13); // 32 + 13
f01048be:	6a 00                	push   $0x0
f01048c0:	6a 2d                	push   $0x2d
f01048c2:	eb 12                	jmp    f01048d6 <_alltraps>

f01048c4 <t_irq_ide>:
TRAPHANDLER_NOEC(t_irq_ide, IRQ_OFFSET + IRQ_IDE); // 32 + 14
f01048c4:	6a 00                	push   $0x0
f01048c6:	6a 2e                	push   $0x2e
f01048c8:	eb 0c                	jmp    f01048d6 <_alltraps>

f01048ca <t_irq_15>:
TRAPHANDLER_NOEC(t_irq_15, IRQ_OFFSET + 15); // 32 + 15
f01048ca:	6a 00                	push   $0x0
f01048cc:	6a 2f                	push   $0x2f
f01048ce:	eb 06                	jmp    f01048d6 <_alltraps>

f01048d0 <t_syscall>:

TRAPHANDLER_NOEC(t_syscall, T_SYSCALL);  // 48, 0x30
f01048d0:	6a 00                	push   $0x0
f01048d2:	6a 30                	push   $0x30
f01048d4:	eb 00                	jmp    f01048d6 <_alltraps>

f01048d6 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */

_alltraps:
    pushl %ds
f01048d6:	1e                   	push   %ds
    pushl %es
f01048d7:	06                   	push   %es
    pushal
f01048d8:	60                   	pusha  

    movl $GD_KD, %eax
f01048d9:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
f01048de:	8e d8                	mov    %eax,%ds
    movw %ax, %es
f01048e0:	8e c0                	mov    %eax,%es

    pushl %esp
f01048e2:	54                   	push   %esp

    call trap
f01048e3:	e8 c0 fc ff ff       	call   f01045a8 <trap>

f01048e8 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f01048e8:	f3 0f 1e fb          	endbr32 
f01048ec:	55                   	push   %ebp
f01048ed:	89 e5                	mov    %esp,%ebp
f01048ef:	83 ec 08             	sub    $0x8,%esp
f01048f2:	a1 44 72 23 f0       	mov    0xf0237244,%eax
f01048f7:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01048fa:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f01048ff:	8b 02                	mov    (%edx),%eax
f0104901:	83 e8 01             	sub    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104904:	83 f8 02             	cmp    $0x2,%eax
f0104907:	76 2d                	jbe    f0104936 <sched_halt+0x4e>
	for (i = 0; i < NENV; i++) {
f0104909:	83 c1 01             	add    $0x1,%ecx
f010490c:	83 c2 7c             	add    $0x7c,%edx
f010490f:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104915:	75 e8                	jne    f01048ff <sched_halt+0x17>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f0104917:	83 ec 0c             	sub    $0xc,%esp
f010491a:	68 30 81 10 f0       	push   $0xf0108130
f010491f:	e8 d4 f1 ff ff       	call   f0103af8 <cprintf>
f0104924:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104927:	83 ec 0c             	sub    $0xc,%esp
f010492a:	6a 00                	push   $0x0
f010492c:	e8 76 c0 ff ff       	call   f01009a7 <monitor>
f0104931:	83 c4 10             	add    $0x10,%esp
f0104934:	eb f1                	jmp    f0104927 <sched_halt+0x3f>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104936:	e8 0f 1a 00 00       	call   f010634a <cpunum>
f010493b:	6b c0 74             	imul   $0x74,%eax,%eax
f010493e:	c7 80 28 80 23 f0 00 	movl   $0x0,-0xfdc7fd8(%eax)
f0104945:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104948:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f010494d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104952:	76 50                	jbe    f01049a4 <sched_halt+0xbc>
	return (physaddr_t)kva - KERNBASE;
f0104954:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104959:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f010495c:	e8 e9 19 00 00       	call   f010634a <cpunum>
f0104961:	6b d0 74             	imul   $0x74,%eax,%edx
f0104964:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f0104967:	b8 02 00 00 00       	mov    $0x2,%eax
f010496c:	f0 87 82 20 80 23 f0 	lock xchg %eax,-0xfdc7fe0(%edx)
	spin_unlock(&kernel_lock);
f0104973:	83 ec 0c             	sub    $0xc,%esp
f0104976:	68 c0 33 12 f0       	push   $0xf01233c0
f010497b:	e8 f0 1c 00 00       	call   f0106670 <spin_unlock>
	asm volatile("pause");
f0104980:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104982:	e8 c3 19 00 00       	call   f010634a <cpunum>
f0104987:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile (
f010498a:	8b 80 30 80 23 f0    	mov    -0xfdc7fd0(%eax),%eax
f0104990:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104995:	89 c4                	mov    %eax,%esp
f0104997:	6a 00                	push   $0x0
f0104999:	6a 00                	push   $0x0
f010499b:	fb                   	sti    
f010499c:	f4                   	hlt    
f010499d:	eb fd                	jmp    f010499c <sched_halt+0xb4>
}
f010499f:	83 c4 10             	add    $0x10,%esp
f01049a2:	c9                   	leave  
f01049a3:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01049a4:	50                   	push   %eax
f01049a5:	68 08 6a 10 f0       	push   $0xf0106a08
f01049aa:	6a 4f                	push   $0x4f
f01049ac:	68 59 81 10 f0       	push   $0xf0108159
f01049b1:	e8 8a b6 ff ff       	call   f0100040 <_panic>

f01049b6 <sched_yield>:
{
f01049b6:	f3 0f 1e fb          	endbr32 
f01049ba:	55                   	push   %ebp
f01049bb:	89 e5                	mov    %esp,%ebp
f01049bd:	56                   	push   %esi
f01049be:	53                   	push   %ebx
    for (uint32_t i = probing_env_idx; i < (probing_env_idx + NENV); ++i) {
f01049bf:	8b 1d 64 7a 23 f0    	mov    0xf0237a64,%ebx
        if (envs[env_idx].env_status == ENV_RUNNABLE) {
f01049c5:	8b 35 44 72 23 f0    	mov    0xf0237244,%esi
    for (uint32_t i = probing_env_idx; i < (probing_env_idx + NENV); ++i) {
f01049cb:	89 d8                	mov    %ebx,%eax
f01049cd:	81 c3 00 04 00 00    	add    $0x400,%ebx
f01049d3:	39 c3                	cmp    %eax,%ebx
f01049d5:	76 2e                	jbe    f0104a05 <sched_yield+0x4f>
        uint32_t env_idx = i % NENV;
f01049d7:	89 c1                	mov    %eax,%ecx
f01049d9:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
        if (envs[env_idx].env_status == ENV_RUNNABLE) {
f01049df:	6b d1 7c             	imul   $0x7c,%ecx,%edx
f01049e2:	01 f2                	add    %esi,%edx
f01049e4:	83 7a 54 02          	cmpl   $0x2,0x54(%edx)
f01049e8:	74 05                	je     f01049ef <sched_yield+0x39>
    for (uint32_t i = probing_env_idx; i < (probing_env_idx + NENV); ++i) {
f01049ea:	83 c0 01             	add    $0x1,%eax
f01049ed:	eb e4                	jmp    f01049d3 <sched_yield+0x1d>
            probing_env_idx = (env_idx + 1) % NENV;
f01049ef:	8d 41 01             	lea    0x1(%ecx),%eax
f01049f2:	25 ff 03 00 00       	and    $0x3ff,%eax
f01049f7:	a3 64 7a 23 f0       	mov    %eax,0xf0237a64
            env_run(target_env);
f01049fc:	83 ec 0c             	sub    $0xc,%esp
f01049ff:	52                   	push   %edx
f0104a00:	e8 82 ee ff ff       	call   f0103887 <env_run>
    if (curenv && curenv->env_status == ENV_RUNNING) {
f0104a05:	e8 40 19 00 00       	call   f010634a <cpunum>
f0104a0a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a0d:	83 b8 28 80 23 f0 00 	cmpl   $0x0,-0xfdc7fd8(%eax)
f0104a14:	74 14                	je     f0104a2a <sched_yield+0x74>
f0104a16:	e8 2f 19 00 00       	call   f010634a <cpunum>
f0104a1b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a1e:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f0104a24:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104a28:	74 0c                	je     f0104a36 <sched_yield+0x80>
	sched_halt();
f0104a2a:	e8 b9 fe ff ff       	call   f01048e8 <sched_halt>
}
f0104a2f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104a32:	5b                   	pop    %ebx
f0104a33:	5e                   	pop    %esi
f0104a34:	5d                   	pop    %ebp
f0104a35:	c3                   	ret    
        env_run(curenv);
f0104a36:	e8 0f 19 00 00       	call   f010634a <cpunum>
f0104a3b:	83 ec 0c             	sub    $0xc,%esp
f0104a3e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a41:	ff b0 28 80 23 f0    	pushl  -0xfdc7fd8(%eax)
f0104a47:	e8 3b ee ff ff       	call   f0103887 <env_run>

f0104a4c <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104a4c:	f3 0f 1e fb          	endbr32 
f0104a50:	55                   	push   %ebp
f0104a51:	89 e5                	mov    %esp,%ebp
f0104a53:	57                   	push   %edi
f0104a54:	56                   	push   %esi
f0104a55:	53                   	push   %ebx
f0104a56:	83 ec 1c             	sub    $0x1c,%esp
f0104a59:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a5c:	83 f8 0c             	cmp    $0xc,%eax
f0104a5f:	0f 87 81 06 00 00    	ja     f01050e6 <syscall+0x69a>
f0104a65:	3e ff 24 85 d4 81 10 	notrack jmp *-0xfef7e2c(,%eax,4)
f0104a6c:	f0 
    user_mem_assert(curenv, s, len, PTE_U|PTE_P);
f0104a6d:	e8 d8 18 00 00       	call   f010634a <cpunum>
f0104a72:	6a 05                	push   $0x5
f0104a74:	ff 75 10             	pushl  0x10(%ebp)
f0104a77:	ff 75 0c             	pushl  0xc(%ebp)
f0104a7a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a7d:	ff b0 28 80 23 f0    	pushl  -0xfdc7fd8(%eax)
f0104a83:	e8 2e e6 ff ff       	call   f01030b6 <user_mem_assert>
	cprintf("%.*s", len, s);
f0104a88:	83 c4 0c             	add    $0xc,%esp
f0104a8b:	ff 75 0c             	pushl  0xc(%ebp)
f0104a8e:	ff 75 10             	pushl  0x10(%ebp)
f0104a91:	68 75 6d 10 f0       	push   $0xf0106d75
f0104a96:	e8 5d f0 ff ff       	call   f0103af8 <cprintf>
}
f0104a9b:	83 c4 10             	add    $0x10,%esp

	switch (syscallno) {
    case SYS_cputs:
    {
        sys_cputs((const char *)a1, (size_t) a2);
        return 0;
f0104a9e:	b8 00 00 00 00       	mov    $0x0,%eax
	default:
	    panic("syscall %d not implemented", syscallno);
		return -E_INVAL;
	}

}
f0104aa3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104aa6:	5b                   	pop    %ebx
f0104aa7:	5e                   	pop    %esi
f0104aa8:	5f                   	pop    %edi
f0104aa9:	5d                   	pop    %ebp
f0104aaa:	c3                   	ret    
	return cons_getc();
f0104aab:	e8 4f bb ff ff       	call   f01005ff <cons_getc>
        return sys_cgetc();
f0104ab0:	eb f1                	jmp    f0104aa3 <syscall+0x57>
	return curenv->env_id;
f0104ab2:	e8 93 18 00 00       	call   f010634a <cpunum>
f0104ab7:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aba:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f0104ac0:	8b 40 48             	mov    0x48(%eax),%eax
        return (int32_t) sys_getenvid();
f0104ac3:	eb de                	jmp    f0104aa3 <syscall+0x57>
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104ac5:	83 ec 04             	sub    $0x4,%esp
f0104ac8:	6a 01                	push   $0x1
f0104aca:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104acd:	50                   	push   %eax
f0104ace:	ff 75 0c             	pushl  0xc(%ebp)
f0104ad1:	e8 ed e6 ff ff       	call   f01031c3 <envid2env>
f0104ad6:	83 c4 10             	add    $0x10,%esp
f0104ad9:	85 c0                	test   %eax,%eax
f0104adb:	78 c6                	js     f0104aa3 <syscall+0x57>
	if (e == curenv)
f0104add:	e8 68 18 00 00       	call   f010634a <cpunum>
f0104ae2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104ae5:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ae8:	39 90 28 80 23 f0    	cmp    %edx,-0xfdc7fd8(%eax)
f0104aee:	74 3d                	je     f0104b2d <syscall+0xe1>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104af0:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104af3:	e8 52 18 00 00       	call   f010634a <cpunum>
f0104af8:	83 ec 04             	sub    $0x4,%esp
f0104afb:	53                   	push   %ebx
f0104afc:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aff:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f0104b05:	ff 70 48             	pushl  0x48(%eax)
f0104b08:	68 81 81 10 f0       	push   $0xf0108181
f0104b0d:	e8 e6 ef ff ff       	call   f0103af8 <cprintf>
f0104b12:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104b15:	83 ec 0c             	sub    $0xc,%esp
f0104b18:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104b1b:	e8 a1 ec ff ff       	call   f01037c1 <env_destroy>
	return 0;
f0104b20:	83 c4 10             	add    $0x10,%esp
f0104b23:	b8 00 00 00 00       	mov    $0x0,%eax
        return sys_env_destroy((envid_t) a1);
f0104b28:	e9 76 ff ff ff       	jmp    f0104aa3 <syscall+0x57>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104b2d:	e8 18 18 00 00       	call   f010634a <cpunum>
f0104b32:	83 ec 08             	sub    $0x8,%esp
f0104b35:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b38:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f0104b3e:	ff 70 48             	pushl  0x48(%eax)
f0104b41:	68 66 81 10 f0       	push   $0xf0108166
f0104b46:	e8 ad ef ff ff       	call   f0103af8 <cprintf>
f0104b4b:	83 c4 10             	add    $0x10,%esp
f0104b4e:	eb c5                	jmp    f0104b15 <syscall+0xc9>
	sched_yield();
f0104b50:	e8 61 fe ff ff       	call   f01049b6 <sched_yield>
    struct Env *e = NULL;
f0104b55:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    if (envid2env(envid, &e, 1) < 0) {
f0104b5c:	83 ec 04             	sub    $0x4,%esp
f0104b5f:	6a 01                	push   $0x1
f0104b61:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104b64:	50                   	push   %eax
f0104b65:	ff 75 0c             	pushl  0xc(%ebp)
f0104b68:	e8 56 e6 ff ff       	call   f01031c3 <envid2env>
f0104b6d:	83 c4 10             	add    $0x10,%esp
f0104b70:	85 c0                	test   %eax,%eax
f0104b72:	0f 88 8c 00 00 00    	js     f0104c04 <syscall+0x1b8>
    if (e == NULL) {
f0104b78:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104b7c:	0f 84 8c 00 00 00    	je     f0104c0e <syscall+0x1c2>
    if (((uintptr_t)va) >= UTOP) {
f0104b82:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104b89:	0f 87 89 00 00 00    	ja     f0104c18 <syscall+0x1cc>
    if (!(PTE_P & perm)) {
f0104b8f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b92:	83 e0 05             	and    $0x5,%eax
f0104b95:	83 f8 05             	cmp    $0x5,%eax
f0104b98:	0f 85 84 00 00 00    	jne    f0104c22 <syscall+0x1d6>
    struct PageInfo *pp = page_alloc(ALLOC_ZERO);
f0104b9e:	83 ec 0c             	sub    $0xc,%esp
f0104ba1:	6a 01                	push   $0x1
f0104ba3:	e8 21 c4 ff ff       	call   f0100fc9 <page_alloc>
f0104ba8:	89 c3                	mov    %eax,%ebx
    if (pp == NULL) {
f0104baa:	83 c4 10             	add    $0x10,%esp
f0104bad:	85 c0                	test   %eax,%eax
f0104baf:	74 7b                	je     f0104c2c <syscall+0x1e0>
    if (page_insert(e->env_pgdir, pp, va, perm) != 0) {
f0104bb1:	ff 75 14             	pushl  0x14(%ebp)
f0104bb4:	ff 75 10             	pushl  0x10(%ebp)
f0104bb7:	50                   	push   %eax
f0104bb8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104bbb:	ff 70 60             	pushl  0x60(%eax)
f0104bbe:	e8 d4 c6 ff ff       	call   f0101297 <page_insert>
f0104bc3:	83 c4 10             	add    $0x10,%esp
f0104bc6:	85 c0                	test   %eax,%eax
f0104bc8:	0f 84 d5 fe ff ff    	je     f0104aa3 <syscall+0x57>
        assert(pp->pp_ref == 0);
f0104bce:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0104bd3:	75 16                	jne    f0104beb <syscall+0x19f>
        page_free(pp);
f0104bd5:	83 ec 0c             	sub    $0xc,%esp
f0104bd8:	53                   	push   %ebx
f0104bd9:	e8 64 c4 ff ff       	call   f0101042 <page_free>
        return -E_NO_MEM;
f0104bde:	83 c4 10             	add    $0x10,%esp
f0104be1:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104be6:	e9 b8 fe ff ff       	jmp    f0104aa3 <syscall+0x57>
        assert(pp->pp_ref == 0);
f0104beb:	68 99 81 10 f0       	push   $0xf0108199
f0104bf0:	68 d9 78 10 f0       	push   $0xf01078d9
f0104bf5:	68 e2 00 00 00       	push   $0xe2
f0104bfa:	68 a9 81 10 f0       	push   $0xf01081a9
f0104bff:	e8 3c b4 ff ff       	call   f0100040 <_panic>
        return -E_BAD_ENV;
f0104c04:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104c09:	e9 95 fe ff ff       	jmp    f0104aa3 <syscall+0x57>
        return -E_BAD_ENV;
f0104c0e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104c13:	e9 8b fe ff ff       	jmp    f0104aa3 <syscall+0x57>
        return -E_INVAL;
f0104c18:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104c1d:	e9 81 fe ff ff       	jmp    f0104aa3 <syscall+0x57>
        return -E_INVAL;
f0104c22:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104c27:	e9 77 fe ff ff       	jmp    f0104aa3 <syscall+0x57>
        return -E_NO_MEM;
f0104c2c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
        return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
f0104c31:	e9 6d fe ff ff       	jmp    f0104aa3 <syscall+0x57>
    struct Env *srcenv = NULL;
f0104c36:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
    if (envid2env(srcenvid, &srcenv, 1) < 0)
f0104c3d:	83 ec 04             	sub    $0x4,%esp
f0104c40:	6a 01                	push   $0x1
f0104c42:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0104c45:	50                   	push   %eax
f0104c46:	ff 75 0c             	pushl  0xc(%ebp)
f0104c49:	e8 75 e5 ff ff       	call   f01031c3 <envid2env>
f0104c4e:	83 c4 10             	add    $0x10,%esp
f0104c51:	85 c0                	test   %eax,%eax
f0104c53:	0f 88 09 01 00 00    	js     f0104d62 <syscall+0x316>
    if (srcenv == NULL)
f0104c59:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104c5d:	0f 84 09 01 00 00    	je     f0104d6c <syscall+0x320>
    struct Env *dstenv = NULL;
f0104c63:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    if (envid2env(dstenvid, &dstenv, 1) < 0)
f0104c6a:	83 ec 04             	sub    $0x4,%esp
f0104c6d:	6a 01                	push   $0x1
f0104c6f:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104c72:	50                   	push   %eax
f0104c73:	ff 75 14             	pushl  0x14(%ebp)
f0104c76:	e8 48 e5 ff ff       	call   f01031c3 <envid2env>
f0104c7b:	83 c4 10             	add    $0x10,%esp
f0104c7e:	85 c0                	test   %eax,%eax
f0104c80:	0f 88 f0 00 00 00    	js     f0104d76 <syscall+0x32a>
    if (dstenv == NULL)
f0104c86:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0104c8a:	0f 84 f0 00 00 00    	je     f0104d80 <syscall+0x334>
    if ( ((uintptr_t)dstva) >= UTOP )
f0104c90:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104c97:	0f 87 ed 00 00 00    	ja     f0104d8a <syscall+0x33e>
f0104c9d:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104ca4:	0f 87 e0 00 00 00    	ja     f0104d8a <syscall+0x33e>
    if (!(PTE_P & perm)) {
f0104caa:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0104cad:	83 e0 05             	and    $0x5,%eax
f0104cb0:	83 f8 05             	cmp    $0x5,%eax
f0104cb3:	0f 85 db 00 00 00    	jne    f0104d94 <syscall+0x348>
    pte_t *src_pte = NULL, *dst_pte = NULL;
f0104cb9:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0104cc0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    struct PageInfo *src_pp = page_lookup(srcenv->env_pgdir, srcva, &src_pte);
f0104cc7:	83 ec 04             	sub    $0x4,%esp
f0104cca:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104ccd:	50                   	push   %eax
f0104cce:	ff 75 10             	pushl  0x10(%ebp)
f0104cd1:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104cd4:	ff 70 60             	pushl  0x60(%eax)
f0104cd7:	e8 d2 c4 ff ff       	call   f01011ae <page_lookup>
f0104cdc:	89 c3                	mov    %eax,%ebx
    if (src_pte == NULL)
f0104cde:	83 c4 10             	add    $0x10,%esp
f0104ce1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104ce5:	0f 84 b3 00 00 00    	je     f0104d9e <syscall+0x352>
    struct PageInfo *dst_pp = page_lookup(dstenv->env_pgdir, dstva, &dst_pte);
f0104ceb:	83 ec 04             	sub    $0x4,%esp
f0104cee:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104cf1:	50                   	push   %eax
f0104cf2:	ff 75 18             	pushl  0x18(%ebp)
f0104cf5:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104cf8:	ff 70 60             	pushl  0x60(%eax)
f0104cfb:	e8 ae c4 ff ff       	call   f01011ae <page_lookup>
    if (dst_pte == NULL) {
f0104d00:	83 c4 10             	add    $0x10,%esp
f0104d03:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104d07:	74 32                	je     f0104d3b <syscall+0x2ef>
    if ( (perm&PTE_W) && ((*src_pte & PTE_W) == 0) ) {
f0104d09:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104d0d:	74 0c                	je     f0104d1b <syscall+0x2cf>
f0104d0f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d12:	f6 00 02             	testb  $0x2,(%eax)
f0104d15:	0f 84 8d 00 00 00    	je     f0104da8 <syscall+0x35c>
    if (page_insert(dstenv->env_pgdir, src_pp, dstva, perm) < 0)
f0104d1b:	ff 75 1c             	pushl  0x1c(%ebp)
f0104d1e:	ff 75 18             	pushl  0x18(%ebp)
f0104d21:	53                   	push   %ebx
f0104d22:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104d25:	ff 70 60             	pushl  0x60(%eax)
f0104d28:	e8 6a c5 ff ff       	call   f0101297 <page_insert>
f0104d2d:	83 c4 10             	add    $0x10,%esp
        return -E_NO_MEM;
f0104d30:	c1 f8 1f             	sar    $0x1f,%eax
f0104d33:	83 e0 fc             	and    $0xfffffffc,%eax
f0104d36:	e9 68 fd ff ff       	jmp    f0104aa3 <syscall+0x57>
        dst_pte = pgdir_walk(dstenv->env_pgdir, dstva, 1);
f0104d3b:	83 ec 04             	sub    $0x4,%esp
f0104d3e:	6a 01                	push   $0x1
f0104d40:	ff 75 18             	pushl  0x18(%ebp)
f0104d43:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104d46:	ff 70 60             	pushl  0x60(%eax)
f0104d49:	e8 60 c3 ff ff       	call   f01010ae <pgdir_walk>
f0104d4e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if (dst_pte == NULL) {
f0104d51:	83 c4 10             	add    $0x10,%esp
f0104d54:	85 c0                	test   %eax,%eax
f0104d56:	75 b1                	jne    f0104d09 <syscall+0x2bd>
            return -E_NO_MEM;
f0104d58:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104d5d:	e9 41 fd ff ff       	jmp    f0104aa3 <syscall+0x57>
        return -E_BAD_ENV;
f0104d62:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104d67:	e9 37 fd ff ff       	jmp    f0104aa3 <syscall+0x57>
        return -E_BAD_ENV;
f0104d6c:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104d71:	e9 2d fd ff ff       	jmp    f0104aa3 <syscall+0x57>
        return -E_BAD_ENV;
f0104d76:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104d7b:	e9 23 fd ff ff       	jmp    f0104aa3 <syscall+0x57>
        return -E_BAD_ENV;
f0104d80:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104d85:	e9 19 fd ff ff       	jmp    f0104aa3 <syscall+0x57>
        return -E_INVAL;
f0104d8a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104d8f:	e9 0f fd ff ff       	jmp    f0104aa3 <syscall+0x57>
        return -E_INVAL;
f0104d94:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104d99:	e9 05 fd ff ff       	jmp    f0104aa3 <syscall+0x57>
        return -E_NO_MEM;
f0104d9e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104da3:	e9 fb fc ff ff       	jmp    f0104aa3 <syscall+0x57>
        return -E_INVAL;
f0104da8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104dad:	e9 f1 fc ff ff       	jmp    f0104aa3 <syscall+0x57>
    struct Env *e = NULL;
f0104db2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    if (envid2env(envid, &e, 1) < 0)
f0104db9:	83 ec 04             	sub    $0x4,%esp
f0104dbc:	6a 01                	push   $0x1
f0104dbe:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104dc1:	50                   	push   %eax
f0104dc2:	ff 75 0c             	pushl  0xc(%ebp)
f0104dc5:	e8 f9 e3 ff ff       	call   f01031c3 <envid2env>
f0104dca:	83 c4 10             	add    $0x10,%esp
f0104dcd:	85 c0                	test   %eax,%eax
f0104dcf:	78 2b                	js     f0104dfc <syscall+0x3b0>
    if (e == NULL)
f0104dd1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104dd4:	85 c0                	test   %eax,%eax
f0104dd6:	74 2e                	je     f0104e06 <syscall+0x3ba>
    if (((uintptr_t)va) >= UTOP) {
f0104dd8:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104ddf:	77 2f                	ja     f0104e10 <syscall+0x3c4>
    page_remove(e->env_pgdir, va);
f0104de1:	83 ec 08             	sub    $0x8,%esp
f0104de4:	ff 75 10             	pushl  0x10(%ebp)
f0104de7:	ff 70 60             	pushl  0x60(%eax)
f0104dea:	e8 5a c4 ff ff       	call   f0101249 <page_remove>
    return 0;
f0104def:	83 c4 10             	add    $0x10,%esp
f0104df2:	b8 00 00 00 00       	mov    $0x0,%eax
f0104df7:	e9 a7 fc ff ff       	jmp    f0104aa3 <syscall+0x57>
        return -E_BAD_ENV;
f0104dfc:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104e01:	e9 9d fc ff ff       	jmp    f0104aa3 <syscall+0x57>
        return -E_BAD_ENV;
f0104e06:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104e0b:	e9 93 fc ff ff       	jmp    f0104aa3 <syscall+0x57>
        return -E_INVAL;
f0104e10:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
        return sys_page_unmap((envid_t)a1, (void *)a2);
f0104e15:	e9 89 fc ff ff       	jmp    f0104aa3 <syscall+0x57>
    if (env_alloc(&newenv, curenv->env_id) < 0) {
f0104e1a:	e8 2b 15 00 00       	call   f010634a <cpunum>
f0104e1f:	83 ec 08             	sub    $0x8,%esp
f0104e22:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e25:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f0104e2b:	ff 70 48             	pushl  0x48(%eax)
f0104e2e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104e31:	50                   	push   %eax
f0104e32:	e8 ae e4 ff ff       	call   f01032e5 <env_alloc>
f0104e37:	83 c4 10             	add    $0x10,%esp
f0104e3a:	85 c0                	test   %eax,%eax
f0104e3c:	78 31                	js     f0104e6f <syscall+0x423>
    newenv->env_tf = curenv->env_tf;
f0104e3e:	e8 07 15 00 00       	call   f010634a <cpunum>
f0104e43:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e46:	8b b0 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%esi
f0104e4c:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104e51:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104e54:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
    newenv->env_tf.tf_regs.reg_eax = 0;
f0104e56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e59:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    newenv->env_status = ENV_NOT_RUNNABLE;
f0104e60:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
    return newenv->env_id;
f0104e67:	8b 40 48             	mov    0x48(%eax),%eax
f0104e6a:	e9 34 fc ff ff       	jmp    f0104aa3 <syscall+0x57>
        return -E_NO_FREE_ENV;
f0104e6f:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
        return sys_exofork();
f0104e74:	e9 2a fc ff ff       	jmp    f0104aa3 <syscall+0x57>
    struct Env *e = NULL;
f0104e79:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    if (envid2env(envid, &e, 1) < 0) {
f0104e80:	83 ec 04             	sub    $0x4,%esp
f0104e83:	6a 01                	push   $0x1
f0104e85:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104e88:	50                   	push   %eax
f0104e89:	ff 75 0c             	pushl  0xc(%ebp)
f0104e8c:	e8 32 e3 ff ff       	call   f01031c3 <envid2env>
f0104e91:	83 c4 10             	add    $0x10,%esp
f0104e94:	85 c0                	test   %eax,%eax
f0104e96:	78 1d                	js     f0104eb5 <syscall+0x469>
    if (e == NULL) {
f0104e98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e9b:	85 c0                	test   %eax,%eax
f0104e9d:	74 20                	je     f0104ebf <syscall+0x473>
    if (status > ENV_NOT_RUNNABLE || status < ENV_FREE) {
f0104e9f:	83 7d 10 04          	cmpl   $0x4,0x10(%ebp)
f0104ea3:	77 24                	ja     f0104ec9 <syscall+0x47d>
    e->env_status = status;
f0104ea5:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104ea8:	89 48 54             	mov    %ecx,0x54(%eax)
    return 0;
f0104eab:	b8 00 00 00 00       	mov    $0x0,%eax
f0104eb0:	e9 ee fb ff ff       	jmp    f0104aa3 <syscall+0x57>
        return -E_BAD_ENV;
f0104eb5:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104eba:	e9 e4 fb ff ff       	jmp    f0104aa3 <syscall+0x57>
        return -E_BAD_ENV;
f0104ebf:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104ec4:	e9 da fb ff ff       	jmp    f0104aa3 <syscall+0x57>
        return -E_INVAL;
f0104ec9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
        return sys_env_set_status((envid_t)a1, (int)a2);
f0104ece:	e9 d0 fb ff ff       	jmp    f0104aa3 <syscall+0x57>
    struct Env *e = NULL;
f0104ed3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    if (envid2env(envid, &e, 1) < 0) {
f0104eda:	83 ec 04             	sub    $0x4,%esp
f0104edd:	6a 01                	push   $0x1
f0104edf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104ee2:	50                   	push   %eax
f0104ee3:	ff 75 0c             	pushl  0xc(%ebp)
f0104ee6:	e8 d8 e2 ff ff       	call   f01031c3 <envid2env>
f0104eeb:	83 c4 10             	add    $0x10,%esp
f0104eee:	85 c0                	test   %eax,%eax
f0104ef0:	78 55                	js     f0104f47 <syscall+0x4fb>
    if (e == NULL) {
f0104ef2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104ef6:	74 59                	je     f0104f51 <syscall+0x505>
    if (curenv->env_id != e->env_id &&
f0104ef8:	e8 4d 14 00 00       	call   f010634a <cpunum>
f0104efd:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f00:	8b 90 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%edx
f0104f06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f09:	8b 40 48             	mov    0x48(%eax),%eax
f0104f0c:	39 42 48             	cmp    %eax,0x48(%edx)
f0104f0f:	75 13                	jne    f0104f24 <syscall+0x4d8>
    e->env_pgfault_upcall = func;
f0104f11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f14:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104f17:	89 78 64             	mov    %edi,0x64(%eax)
    return 0;
f0104f1a:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f1f:	e9 7f fb ff ff       	jmp    f0104aa3 <syscall+0x57>
            curenv->env_id != e->env_parent_id) {
f0104f24:	e8 21 14 00 00       	call   f010634a <cpunum>
f0104f29:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f2c:	8b 90 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%edx
    if (curenv->env_id != e->env_id &&
f0104f32:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f35:	8b 40 4c             	mov    0x4c(%eax),%eax
f0104f38:	39 42 48             	cmp    %eax,0x48(%edx)
f0104f3b:	74 d4                	je     f0104f11 <syscall+0x4c5>
        return -E_BAD_ENV;
f0104f3d:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
        return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
f0104f42:	e9 5c fb ff ff       	jmp    f0104aa3 <syscall+0x57>
        return -E_BAD_ENV;
f0104f47:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104f4c:	e9 52 fb ff ff       	jmp    f0104aa3 <syscall+0x57>
        return -E_BAD_ENV;
f0104f51:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104f56:	e9 48 fb ff ff       	jmp    f0104aa3 <syscall+0x57>
    struct Env *dstenv = NULL;
f0104f5b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
    envid2env(envid, &dstenv, 0);
f0104f62:	83 ec 04             	sub    $0x4,%esp
f0104f65:	6a 00                	push   $0x0
f0104f67:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104f6a:	50                   	push   %eax
f0104f6b:	ff 75 0c             	pushl  0xc(%ebp)
f0104f6e:	e8 50 e2 ff ff       	call   f01031c3 <envid2env>
    if (dstenv == NULL) {
f0104f73:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104f76:	83 c4 10             	add    $0x10,%esp
f0104f79:	85 c0                	test   %eax,%eax
f0104f7b:	0f 84 bb 00 00 00    	je     f010503c <syscall+0x5f0>
    if (!dstenv->env_ipc_recving) {
f0104f81:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104f85:	0f 84 bb 00 00 00    	je     f0105046 <syscall+0x5fa>
    pte_t *pte = NULL;
f0104f8b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    if (va < UTOP) {
f0104f92:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104f99:	77 6c                	ja     f0105007 <syscall+0x5bb>
        if (va & 0xfff) {
f0104f9b:	8b 55 14             	mov    0x14(%ebp),%edx
f0104f9e:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
        if (perm & perm_check) {
f0104fa4:	8b 45 18             	mov    0x18(%ebp),%eax
f0104fa7:	83 e0 f8             	and    $0xfffffff8,%eax
f0104faa:	09 c2                	or     %eax,%edx
f0104fac:	0f 85 9e 00 00 00    	jne    f0105050 <syscall+0x604>
        pp = page_lookup(curenv->env_pgdir, srcva, &pte);
f0104fb2:	e8 93 13 00 00       	call   f010634a <cpunum>
f0104fb7:	83 ec 04             	sub    $0x4,%esp
f0104fba:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104fbd:	52                   	push   %edx
f0104fbe:	ff 75 14             	pushl  0x14(%ebp)
f0104fc1:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fc4:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f0104fca:	ff 70 60             	pushl  0x60(%eax)
f0104fcd:	e8 dc c1 ff ff       	call   f01011ae <page_lookup>
        if (!(*pte & PTE_P)) {
f0104fd2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104fd5:	8b 12                	mov    (%edx),%edx
f0104fd7:	83 c4 10             	add    $0x10,%esp
f0104fda:	f6 c2 01             	test   $0x1,%dl
f0104fdd:	74 7b                	je     f010505a <syscall+0x60e>
        if (perm & PTE_W) {
f0104fdf:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104fe3:	74 05                	je     f0104fea <syscall+0x59e>
            if ((*pte & PTE_W) == 0) {
f0104fe5:	f6 c2 02             	test   $0x2,%dl
f0104fe8:	74 7a                	je     f0105064 <syscall+0x618>
    if (pp != NULL) {
f0104fea:	85 c0                	test   %eax,%eax
f0104fec:	74 19                	je     f0105007 <syscall+0x5bb>
                    dstenv->env_ipc_dstva, perm) < 0) {
f0104fee:	8b 55 e0             	mov    -0x20(%ebp),%edx
        if (page_insert(dstenv->env_pgdir, pp,
f0104ff1:	ff 75 18             	pushl  0x18(%ebp)
f0104ff4:	ff 72 6c             	pushl  0x6c(%edx)
f0104ff7:	50                   	push   %eax
f0104ff8:	ff 72 60             	pushl  0x60(%edx)
f0104ffb:	e8 97 c2 ff ff       	call   f0101297 <page_insert>
f0105000:	83 c4 10             	add    $0x10,%esp
f0105003:	85 c0                	test   %eax,%eax
f0105005:	78 67                	js     f010506e <syscall+0x622>
    dstenv->env_ipc_value = value;
f0105007:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010500a:	8b 75 10             	mov    0x10(%ebp),%esi
f010500d:	89 70 70             	mov    %esi,0x70(%eax)
    dstenv->env_ipc_from = curenv->env_id;
f0105010:	e8 35 13 00 00       	call   f010634a <cpunum>
f0105015:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105018:	6b c0 74             	imul   $0x74,%eax,%eax
f010501b:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f0105021:	8b 40 48             	mov    0x48(%eax),%eax
f0105024:	89 42 74             	mov    %eax,0x74(%edx)
    dstenv->env_ipc_recving = false;
f0105027:	c6 42 68 00          	movb   $0x0,0x68(%edx)
    dstenv->env_status = ENV_RUNNABLE;
f010502b:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
    return 0;
f0105032:	b8 00 00 00 00       	mov    $0x0,%eax
f0105037:	e9 67 fa ff ff       	jmp    f0104aa3 <syscall+0x57>
        return -E_BAD_ENV;
f010503c:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0105041:	e9 5d fa ff ff       	jmp    f0104aa3 <syscall+0x57>
        return -E_IPC_NOT_RECV;
f0105046:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
f010504b:	e9 53 fa ff ff       	jmp    f0104aa3 <syscall+0x57>
            return -E_INVAL;
f0105050:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105055:	e9 49 fa ff ff       	jmp    f0104aa3 <syscall+0x57>
            return -E_INVAL;
f010505a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010505f:	e9 3f fa ff ff       	jmp    f0104aa3 <syscall+0x57>
                return -E_INVAL;
f0105064:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105069:	e9 35 fa ff ff       	jmp    f0104aa3 <syscall+0x57>
            return -E_NO_MEM;
f010506e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
        return sys_ipc_try_send((envid_t) a1, (uint32_t) a2,
f0105073:	e9 2b fa ff ff       	jmp    f0104aa3 <syscall+0x57>
    if (va < UTOP) {
f0105078:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f010507f:	77 4e                	ja     f01050cf <syscall+0x683>
        if (va & 0xfff) {
f0105081:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0105088:	75 71                	jne    f01050fb <syscall+0x6af>
        curenv->env_ipc_dstva = dstva;
f010508a:	e8 bb 12 00 00       	call   f010634a <cpunum>
f010508f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105092:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f0105098:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010509b:	89 48 6c             	mov    %ecx,0x6c(%eax)
    curenv->env_ipc_recving = true;
f010509e:	e8 a7 12 00 00       	call   f010634a <cpunum>
f01050a3:	6b c0 74             	imul   $0x74,%eax,%eax
f01050a6:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f01050ac:	c6 40 68 01          	movb   $0x1,0x68(%eax)
    curenv->env_status = ENV_NOT_RUNNABLE;
f01050b0:	e8 95 12 00 00       	call   f010634a <cpunum>
f01050b5:	6b c0 74             	imul   $0x74,%eax,%eax
f01050b8:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f01050be:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	return 0;
f01050c5:	b8 00 00 00 00       	mov    $0x0,%eax
f01050ca:	e9 d4 f9 ff ff       	jmp    f0104aa3 <syscall+0x57>
        curenv->env_ipc_dstva = NULL;
f01050cf:	e8 76 12 00 00       	call   f010634a <cpunum>
f01050d4:	6b c0 74             	imul   $0x74,%eax,%eax
f01050d7:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f01050dd:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)
f01050e4:	eb b8                	jmp    f010509e <syscall+0x652>
	    panic("syscall %d not implemented", syscallno);
f01050e6:	50                   	push   %eax
f01050e7:	68 b8 81 10 f0       	push   $0xf01081b8
f01050ec:	68 2b 02 00 00       	push   $0x22b
f01050f1:	68 a9 81 10 f0       	push   $0xf01081a9
f01050f6:	e8 45 af ff ff       	call   f0100040 <_panic>
            return -E_INVAL;
f01050fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105100:	e9 9e f9 ff ff       	jmp    f0104aa3 <syscall+0x57>

f0105105 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0105105:	55                   	push   %ebp
f0105106:	89 e5                	mov    %esp,%ebp
f0105108:	57                   	push   %edi
f0105109:	56                   	push   %esi
f010510a:	53                   	push   %ebx
f010510b:	83 ec 14             	sub    $0x14,%esp
f010510e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105111:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0105114:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105117:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f010511a:	8b 1a                	mov    (%edx),%ebx
f010511c:	8b 01                	mov    (%ecx),%eax
f010511e:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105121:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0105128:	eb 23                	jmp    f010514d <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010512a:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f010512d:	eb 1e                	jmp    f010514d <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010512f:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105132:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105135:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0105139:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010513c:	73 46                	jae    f0105184 <stab_binsearch+0x7f>
			*region_left = m;
f010513e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105141:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0105143:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0105146:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f010514d:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0105150:	7f 5f                	jg     f01051b1 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0105152:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105155:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0105158:	89 d0                	mov    %edx,%eax
f010515a:	c1 e8 1f             	shr    $0x1f,%eax
f010515d:	01 d0                	add    %edx,%eax
f010515f:	89 c7                	mov    %eax,%edi
f0105161:	d1 ff                	sar    %edi
f0105163:	83 e0 fe             	and    $0xfffffffe,%eax
f0105166:	01 f8                	add    %edi,%eax
f0105168:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010516b:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f010516f:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0105171:	39 c3                	cmp    %eax,%ebx
f0105173:	7f b5                	jg     f010512a <stab_binsearch+0x25>
f0105175:	0f b6 0a             	movzbl (%edx),%ecx
f0105178:	83 ea 0c             	sub    $0xc,%edx
f010517b:	39 f1                	cmp    %esi,%ecx
f010517d:	74 b0                	je     f010512f <stab_binsearch+0x2a>
			m--;
f010517f:	83 e8 01             	sub    $0x1,%eax
f0105182:	eb ed                	jmp    f0105171 <stab_binsearch+0x6c>
		} else if (stabs[m].n_value > addr) {
f0105184:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0105187:	76 14                	jbe    f010519d <stab_binsearch+0x98>
			*region_right = m - 1;
f0105189:	83 e8 01             	sub    $0x1,%eax
f010518c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010518f:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105192:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0105194:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010519b:	eb b0                	jmp    f010514d <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010519d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01051a0:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f01051a2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01051a6:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f01051a8:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01051af:	eb 9c                	jmp    f010514d <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f01051b1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01051b5:	75 15                	jne    f01051cc <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f01051b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01051ba:	8b 00                	mov    (%eax),%eax
f01051bc:	83 e8 01             	sub    $0x1,%eax
f01051bf:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01051c2:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f01051c4:	83 c4 14             	add    $0x14,%esp
f01051c7:	5b                   	pop    %ebx
f01051c8:	5e                   	pop    %esi
f01051c9:	5f                   	pop    %edi
f01051ca:	5d                   	pop    %ebp
f01051cb:	c3                   	ret    
		for (l = *region_right;
f01051cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01051cf:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01051d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01051d4:	8b 0f                	mov    (%edi),%ecx
f01051d6:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01051d9:	8b 7d ec             	mov    -0x14(%ebp),%edi
f01051dc:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f01051e0:	eb 03                	jmp    f01051e5 <stab_binsearch+0xe0>
		     l--)
f01051e2:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f01051e5:	39 c1                	cmp    %eax,%ecx
f01051e7:	7d 0a                	jge    f01051f3 <stab_binsearch+0xee>
		     l > *region_left && stabs[l].n_type != type;
f01051e9:	0f b6 1a             	movzbl (%edx),%ebx
f01051ec:	83 ea 0c             	sub    $0xc,%edx
f01051ef:	39 f3                	cmp    %esi,%ebx
f01051f1:	75 ef                	jne    f01051e2 <stab_binsearch+0xdd>
		*region_left = l;
f01051f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01051f6:	89 07                	mov    %eax,(%edi)
}
f01051f8:	eb ca                	jmp    f01051c4 <stab_binsearch+0xbf>

f01051fa <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01051fa:	f3 0f 1e fb          	endbr32 
f01051fe:	55                   	push   %ebp
f01051ff:	89 e5                	mov    %esp,%ebp
f0105201:	57                   	push   %edi
f0105202:	56                   	push   %esi
f0105203:	53                   	push   %ebx
f0105204:	83 ec 4c             	sub    $0x4c,%esp
f0105207:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010520a:	c7 03 08 82 10 f0    	movl   $0xf0108208,(%ebx)
	info->eip_line = 0;
f0105210:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0105217:	c7 43 08 08 82 10 f0 	movl   $0xf0108208,0x8(%ebx)
	info->eip_fn_namelen = 9;
f010521e:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0105225:	8b 45 08             	mov    0x8(%ebp),%eax
f0105228:	89 43 10             	mov    %eax,0x10(%ebx)
	info->eip_fn_narg = 0;
f010522b:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0105232:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0105237:	0f 86 1b 01 00 00    	jbe    f0105358 <debuginfo_eip+0x15e>
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f010523d:	c7 45 bc 5b 8d 11 f0 	movl   $0xf0118d5b,-0x44(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0105244:	c7 45 b4 7d 55 11 f0 	movl   $0xf011557d,-0x4c(%ebp)
		stab_end = __STAB_END__;
f010524b:	bf 7c 55 11 f0       	mov    $0xf011557c,%edi
		stabs = __STAB_BEGIN__;
f0105250:	c7 45 b8 f4 86 10 f0 	movl   $0xf01086f4,-0x48(%ebp)
            return -1;
        }
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0105257:	8b 75 bc             	mov    -0x44(%ebp),%esi
f010525a:	39 75 b4             	cmp    %esi,-0x4c(%ebp)
f010525d:	0f 83 5d 02 00 00    	jae    f01054c0 <debuginfo_eip+0x2c6>
f0105263:	80 7e ff 00          	cmpb   $0x0,-0x1(%esi)
f0105267:	0f 85 5a 02 00 00    	jne    f01054c7 <debuginfo_eip+0x2cd>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010526d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0105274:	8b 75 b8             	mov    -0x48(%ebp),%esi
f0105277:	29 f7                	sub    %esi,%edi
f0105279:	c1 ff 02             	sar    $0x2,%edi
f010527c:	69 c7 ab aa aa aa    	imul   $0xaaaaaaab,%edi,%eax
f0105282:	83 e8 01             	sub    $0x1,%eax
f0105285:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105288:	83 ec 08             	sub    $0x8,%esp
f010528b:	ff 75 08             	pushl  0x8(%ebp)
f010528e:	6a 64                	push   $0x64
f0105290:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0105293:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105296:	89 f0                	mov    %esi,%eax
f0105298:	e8 68 fe ff ff       	call   f0105105 <stab_binsearch>
	if (lfile == 0)
f010529d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01052a0:	83 c4 10             	add    $0x10,%esp
f01052a3:	85 c0                	test   %eax,%eax
f01052a5:	0f 84 23 02 00 00    	je     f01054ce <debuginfo_eip+0x2d4>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01052ab:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01052ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01052b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01052b4:	83 ec 08             	sub    $0x8,%esp
f01052b7:	ff 75 08             	pushl  0x8(%ebp)
f01052ba:	6a 24                	push   $0x24
f01052bc:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01052bf:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01052c2:	89 f0                	mov    %esi,%eax
f01052c4:	e8 3c fe ff ff       	call   f0105105 <stab_binsearch>

	if (lfun <= rfun) {
f01052c9:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01052cc:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01052cf:	83 c4 10             	add    $0x10,%esp
f01052d2:	39 d0                	cmp    %edx,%eax
f01052d4:	0f 8f 2b 01 00 00    	jg     f0105405 <debuginfo_eip+0x20b>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01052da:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01052dd:	8d 3c 8e             	lea    (%esi,%ecx,4),%edi
f01052e0:	8b 0f                	mov    (%edi),%ecx
f01052e2:	8b 75 bc             	mov    -0x44(%ebp),%esi
f01052e5:	2b 75 b4             	sub    -0x4c(%ebp),%esi
f01052e8:	39 f1                	cmp    %esi,%ecx
f01052ea:	73 06                	jae    f01052f2 <debuginfo_eip+0xf8>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01052ec:	03 4d b4             	add    -0x4c(%ebp),%ecx
f01052ef:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01052f2:	8b 4f 08             	mov    0x8(%edi),%ecx
f01052f5:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01052f8:	29 4d 08             	sub    %ecx,0x8(%ebp)
		// Search within the function definition for the line number.
		lline = lfun;
f01052fb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01052fe:	89 55 d0             	mov    %edx,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0105301:	83 ec 08             	sub    $0x8,%esp
f0105304:	6a 3a                	push   $0x3a
f0105306:	ff 73 08             	pushl  0x8(%ebx)
f0105309:	e8 fe 09 00 00       	call   f0105d0c <strfind>
f010530e:	2b 43 08             	sub    0x8(%ebx),%eax
f0105311:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0105314:	83 c4 08             	add    $0x8,%esp
f0105317:	ff 75 08             	pushl  0x8(%ebp)
f010531a:	6a 44                	push   $0x44
f010531c:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f010531f:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0105322:	8b 75 b8             	mov    -0x48(%ebp),%esi
f0105325:	89 f0                	mov    %esi,%eax
f0105327:	e8 d9 fd ff ff       	call   f0105105 <stab_binsearch>

    if (lline <= rline) {
f010532c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010532f:	83 c4 10             	add    $0x10,%esp
f0105332:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0105335:	0f 8f 9a 01 00 00    	jg     f01054d5 <debuginfo_eip+0x2db>
        info->eip_line = stabs[lline].n_desc;
f010533b:	89 d0                	mov    %edx,%eax
f010533d:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0105340:	0f b7 4c 96 06       	movzwl 0x6(%esi,%edx,4),%ecx
f0105345:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105348:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010534b:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
f010534f:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0105353:	e9 ce 00 00 00       	jmp    f0105426 <debuginfo_eip+0x22c>
        if (user_mem_check(curenv, usd, sizeof(const struct UserStabData),
f0105358:	e8 ed 0f 00 00       	call   f010634a <cpunum>
f010535d:	6a 05                	push   $0x5
f010535f:	6a 10                	push   $0x10
f0105361:	68 00 00 20 00       	push   $0x200000
f0105366:	6b c0 74             	imul   $0x74,%eax,%eax
f0105369:	ff b0 28 80 23 f0    	pushl  -0xfdc7fd8(%eax)
f010536f:	e8 c8 dc ff ff       	call   f010303c <user_mem_check>
f0105374:	83 c4 10             	add    $0x10,%esp
f0105377:	85 c0                	test   %eax,%eax
f0105379:	0f 88 33 01 00 00    	js     f01054b2 <debuginfo_eip+0x2b8>
		stabs = usd->stabs;
f010537f:	a1 00 00 20 00       	mov    0x200000,%eax
f0105384:	89 45 b8             	mov    %eax,-0x48(%ebp)
		stab_end = usd->stab_end;
f0105387:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f010538d:	8b 35 08 00 20 00    	mov    0x200008,%esi
f0105393:	89 75 b4             	mov    %esi,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f0105396:	8b 0d 0c 00 20 00    	mov    0x20000c,%ecx
f010539c:	89 4d bc             	mov    %ecx,-0x44(%ebp)
        size_t stabs_size = ((uintptr_t)stab_end) - ((uintptr_t) stabs);
f010539f:	89 fa                	mov    %edi,%edx
f01053a1:	89 c6                	mov    %eax,%esi
f01053a3:	29 c2                	sub    %eax,%edx
f01053a5:	89 55 c4             	mov    %edx,-0x3c(%ebp)
        if (user_mem_check(curenv, stabs, stabs_size,
f01053a8:	e8 9d 0f 00 00       	call   f010634a <cpunum>
f01053ad:	6a 05                	push   $0x5
f01053af:	ff 75 c4             	pushl  -0x3c(%ebp)
f01053b2:	56                   	push   %esi
f01053b3:	6b c0 74             	imul   $0x74,%eax,%eax
f01053b6:	ff b0 28 80 23 f0    	pushl  -0xfdc7fd8(%eax)
f01053bc:	e8 7b dc ff ff       	call   f010303c <user_mem_check>
f01053c1:	83 c4 10             	add    $0x10,%esp
f01053c4:	85 c0                	test   %eax,%eax
f01053c6:	0f 88 ed 00 00 00    	js     f01054b9 <debuginfo_eip+0x2bf>
        size_t stabstr_size = ((uintptr_t)stabstr_end) - ((uintptr_t) stabstr);
f01053cc:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01053cf:	8b 75 b4             	mov    -0x4c(%ebp),%esi
f01053d2:	29 f0                	sub    %esi,%eax
f01053d4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        if (user_mem_check(curenv, stabstr, stabstr_size,
f01053d7:	e8 6e 0f 00 00       	call   f010634a <cpunum>
f01053dc:	6a 05                	push   $0x5
f01053de:	ff 75 c4             	pushl  -0x3c(%ebp)
f01053e1:	56                   	push   %esi
f01053e2:	6b c0 74             	imul   $0x74,%eax,%eax
f01053e5:	ff b0 28 80 23 f0    	pushl  -0xfdc7fd8(%eax)
f01053eb:	e8 4c dc ff ff       	call   f010303c <user_mem_check>
f01053f0:	83 c4 10             	add    $0x10,%esp
f01053f3:	85 c0                	test   %eax,%eax
f01053f5:	0f 89 5c fe ff ff    	jns    f0105257 <debuginfo_eip+0x5d>
            return -1;
f01053fb:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0105400:	e9 dc 00 00 00       	jmp    f01054e1 <debuginfo_eip+0x2e7>
		info->eip_fn_addr = addr;
f0105405:	8b 45 08             	mov    0x8(%ebp),%eax
f0105408:	89 43 10             	mov    %eax,0x10(%ebx)
		lline = lfile;
f010540b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010540e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0105411:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105414:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105417:	e9 e5 fe ff ff       	jmp    f0105301 <debuginfo_eip+0x107>
f010541c:	83 e8 01             	sub    $0x1,%eax
f010541f:	83 ea 0c             	sub    $0xc,%edx
	while (lline >= lfile
f0105422:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0105426:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0105429:	39 c7                	cmp    %eax,%edi
f010542b:	7f 45                	jg     f0105472 <debuginfo_eip+0x278>
	       && stabs[lline].n_type != N_SOL
f010542d:	0f b6 0a             	movzbl (%edx),%ecx
f0105430:	80 f9 84             	cmp    $0x84,%cl
f0105433:	74 19                	je     f010544e <debuginfo_eip+0x254>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105435:	80 f9 64             	cmp    $0x64,%cl
f0105438:	75 e2                	jne    f010541c <debuginfo_eip+0x222>
f010543a:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f010543e:	74 dc                	je     f010541c <debuginfo_eip+0x222>
f0105440:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0105444:	74 11                	je     f0105457 <debuginfo_eip+0x25d>
f0105446:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0105449:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010544c:	eb 09                	jmp    f0105457 <debuginfo_eip+0x25d>
f010544e:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0105452:	74 03                	je     f0105457 <debuginfo_eip+0x25d>
f0105454:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105457:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010545a:	8b 7d b8             	mov    -0x48(%ebp),%edi
f010545d:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0105460:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0105463:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0105466:	29 f8                	sub    %edi,%eax
f0105468:	39 c2                	cmp    %eax,%edx
f010546a:	73 06                	jae    f0105472 <debuginfo_eip+0x278>
		info->eip_file = stabstr + stabs[lline].n_strx;
f010546c:	89 f8                	mov    %edi,%eax
f010546e:	01 d0                	add    %edx,%eax
f0105470:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105472:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105475:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105478:	ba 00 00 00 00       	mov    $0x0,%edx
	if (lfun < rfun)
f010547d:	39 f0                	cmp    %esi,%eax
f010547f:	7d 60                	jge    f01054e1 <debuginfo_eip+0x2e7>
		for (lline = lfun + 1;
f0105481:	8d 50 01             	lea    0x1(%eax),%edx
f0105484:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105487:	89 d0                	mov    %edx,%eax
f0105489:	8d 14 52             	lea    (%edx,%edx,2),%edx
f010548c:	8b 7d b8             	mov    -0x48(%ebp),%edi
f010548f:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0105493:	eb 04                	jmp    f0105499 <debuginfo_eip+0x29f>
			info->eip_fn_narg++;
f0105495:	83 43 14 01          	addl   $0x1,0x14(%ebx)
		for (lline = lfun + 1;
f0105499:	39 c6                	cmp    %eax,%esi
f010549b:	7e 3f                	jle    f01054dc <debuginfo_eip+0x2e2>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010549d:	0f b6 0a             	movzbl (%edx),%ecx
f01054a0:	83 c0 01             	add    $0x1,%eax
f01054a3:	83 c2 0c             	add    $0xc,%edx
f01054a6:	80 f9 a0             	cmp    $0xa0,%cl
f01054a9:	74 ea                	je     f0105495 <debuginfo_eip+0x29b>
	return 0;
f01054ab:	ba 00 00 00 00       	mov    $0x0,%edx
f01054b0:	eb 2f                	jmp    f01054e1 <debuginfo_eip+0x2e7>
            return -1;
f01054b2:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01054b7:	eb 28                	jmp    f01054e1 <debuginfo_eip+0x2e7>
            return -1;
f01054b9:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01054be:	eb 21                	jmp    f01054e1 <debuginfo_eip+0x2e7>
		return -1;
f01054c0:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01054c5:	eb 1a                	jmp    f01054e1 <debuginfo_eip+0x2e7>
f01054c7:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01054cc:	eb 13                	jmp    f01054e1 <debuginfo_eip+0x2e7>
		return -1;
f01054ce:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01054d3:	eb 0c                	jmp    f01054e1 <debuginfo_eip+0x2e7>
        return -1;
f01054d5:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01054da:	eb 05                	jmp    f01054e1 <debuginfo_eip+0x2e7>
	return 0;
f01054dc:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01054e1:	89 d0                	mov    %edx,%eax
f01054e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01054e6:	5b                   	pop    %ebx
f01054e7:	5e                   	pop    %esi
f01054e8:	5f                   	pop    %edi
f01054e9:	5d                   	pop    %ebp
f01054ea:	c3                   	ret    

f01054eb <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01054eb:	55                   	push   %ebp
f01054ec:	89 e5                	mov    %esp,%ebp
f01054ee:	57                   	push   %edi
f01054ef:	56                   	push   %esi
f01054f0:	53                   	push   %ebx
f01054f1:	83 ec 1c             	sub    $0x1c,%esp
f01054f4:	89 c7                	mov    %eax,%edi
f01054f6:	89 d6                	mov    %edx,%esi
f01054f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01054fb:	8b 55 0c             	mov    0xc(%ebp),%edx
f01054fe:	89 d1                	mov    %edx,%ecx
f0105500:	89 c2                	mov    %eax,%edx
f0105502:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105505:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105508:	8b 45 10             	mov    0x10(%ebp),%eax
f010550b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010550e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105511:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0105518:	39 c2                	cmp    %eax,%edx
f010551a:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f010551d:	72 3e                	jb     f010555d <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010551f:	83 ec 0c             	sub    $0xc,%esp
f0105522:	ff 75 18             	pushl  0x18(%ebp)
f0105525:	83 eb 01             	sub    $0x1,%ebx
f0105528:	53                   	push   %ebx
f0105529:	50                   	push   %eax
f010552a:	83 ec 08             	sub    $0x8,%esp
f010552d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105530:	ff 75 e0             	pushl  -0x20(%ebp)
f0105533:	ff 75 dc             	pushl  -0x24(%ebp)
f0105536:	ff 75 d8             	pushl  -0x28(%ebp)
f0105539:	e8 22 12 00 00       	call   f0106760 <__udivdi3>
f010553e:	83 c4 18             	add    $0x18,%esp
f0105541:	52                   	push   %edx
f0105542:	50                   	push   %eax
f0105543:	89 f2                	mov    %esi,%edx
f0105545:	89 f8                	mov    %edi,%eax
f0105547:	e8 9f ff ff ff       	call   f01054eb <printnum>
f010554c:	83 c4 20             	add    $0x20,%esp
f010554f:	eb 13                	jmp    f0105564 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105551:	83 ec 08             	sub    $0x8,%esp
f0105554:	56                   	push   %esi
f0105555:	ff 75 18             	pushl  0x18(%ebp)
f0105558:	ff d7                	call   *%edi
f010555a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f010555d:	83 eb 01             	sub    $0x1,%ebx
f0105560:	85 db                	test   %ebx,%ebx
f0105562:	7f ed                	jg     f0105551 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105564:	83 ec 08             	sub    $0x8,%esp
f0105567:	56                   	push   %esi
f0105568:	83 ec 04             	sub    $0x4,%esp
f010556b:	ff 75 e4             	pushl  -0x1c(%ebp)
f010556e:	ff 75 e0             	pushl  -0x20(%ebp)
f0105571:	ff 75 dc             	pushl  -0x24(%ebp)
f0105574:	ff 75 d8             	pushl  -0x28(%ebp)
f0105577:	e8 f4 12 00 00       	call   f0106870 <__umoddi3>
f010557c:	83 c4 14             	add    $0x14,%esp
f010557f:	0f be 80 12 82 10 f0 	movsbl -0xfef7dee(%eax),%eax
f0105586:	50                   	push   %eax
f0105587:	ff d7                	call   *%edi
}
f0105589:	83 c4 10             	add    $0x10,%esp
f010558c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010558f:	5b                   	pop    %ebx
f0105590:	5e                   	pop    %esi
f0105591:	5f                   	pop    %edi
f0105592:	5d                   	pop    %ebp
f0105593:	c3                   	ret    

f0105594 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105594:	f3 0f 1e fb          	endbr32 
f0105598:	55                   	push   %ebp
f0105599:	89 e5                	mov    %esp,%ebp
f010559b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010559e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01055a2:	8b 10                	mov    (%eax),%edx
f01055a4:	3b 50 04             	cmp    0x4(%eax),%edx
f01055a7:	73 0a                	jae    f01055b3 <sprintputch+0x1f>
		*b->buf++ = ch;
f01055a9:	8d 4a 01             	lea    0x1(%edx),%ecx
f01055ac:	89 08                	mov    %ecx,(%eax)
f01055ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01055b1:	88 02                	mov    %al,(%edx)
}
f01055b3:	5d                   	pop    %ebp
f01055b4:	c3                   	ret    

f01055b5 <printfmt>:
{
f01055b5:	f3 0f 1e fb          	endbr32 
f01055b9:	55                   	push   %ebp
f01055ba:	89 e5                	mov    %esp,%ebp
f01055bc:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01055bf:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01055c2:	50                   	push   %eax
f01055c3:	ff 75 10             	pushl  0x10(%ebp)
f01055c6:	ff 75 0c             	pushl  0xc(%ebp)
f01055c9:	ff 75 08             	pushl  0x8(%ebp)
f01055cc:	e8 05 00 00 00       	call   f01055d6 <vprintfmt>
}
f01055d1:	83 c4 10             	add    $0x10,%esp
f01055d4:	c9                   	leave  
f01055d5:	c3                   	ret    

f01055d6 <vprintfmt>:
{
f01055d6:	f3 0f 1e fb          	endbr32 
f01055da:	55                   	push   %ebp
f01055db:	89 e5                	mov    %esp,%ebp
f01055dd:	57                   	push   %edi
f01055de:	56                   	push   %esi
f01055df:	53                   	push   %ebx
f01055e0:	83 ec 3c             	sub    $0x3c,%esp
f01055e3:	8b 75 08             	mov    0x8(%ebp),%esi
f01055e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01055e9:	8b 7d 10             	mov    0x10(%ebp),%edi
f01055ec:	e9 4a 03 00 00       	jmp    f010593b <vprintfmt+0x365>
		padc = ' ';
f01055f1:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
f01055f5:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f01055fc:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0105603:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f010560a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f010560f:	8d 47 01             	lea    0x1(%edi),%eax
f0105612:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105615:	0f b6 17             	movzbl (%edi),%edx
f0105618:	8d 42 dd             	lea    -0x23(%edx),%eax
f010561b:	3c 55                	cmp    $0x55,%al
f010561d:	0f 87 de 03 00 00    	ja     f0105a01 <vprintfmt+0x42b>
f0105623:	0f b6 c0             	movzbl %al,%eax
f0105626:	3e ff 24 85 e0 82 10 	notrack jmp *-0xfef7d20(,%eax,4)
f010562d:	f0 
f010562e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0105631:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
f0105635:	eb d8                	jmp    f010560f <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
f0105637:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010563a:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
f010563e:	eb cf                	jmp    f010560f <vprintfmt+0x39>
f0105640:	0f b6 d2             	movzbl %dl,%edx
f0105643:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0105646:	b8 00 00 00 00       	mov    $0x0,%eax
f010564b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f010564e:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0105651:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0105655:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0105658:	8d 4a d0             	lea    -0x30(%edx),%ecx
f010565b:	83 f9 09             	cmp    $0x9,%ecx
f010565e:	77 55                	ja     f01056b5 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
f0105660:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0105663:	eb e9                	jmp    f010564e <vprintfmt+0x78>
			precision = va_arg(ap, int);
f0105665:	8b 45 14             	mov    0x14(%ebp),%eax
f0105668:	8b 00                	mov    (%eax),%eax
f010566a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010566d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105670:	8d 40 04             	lea    0x4(%eax),%eax
f0105673:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0105676:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0105679:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010567d:	79 90                	jns    f010560f <vprintfmt+0x39>
				width = precision, precision = -1;
f010567f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105682:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105685:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f010568c:	eb 81                	jmp    f010560f <vprintfmt+0x39>
f010568e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105691:	85 c0                	test   %eax,%eax
f0105693:	ba 00 00 00 00       	mov    $0x0,%edx
f0105698:	0f 49 d0             	cmovns %eax,%edx
f010569b:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010569e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01056a1:	e9 69 ff ff ff       	jmp    f010560f <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
f01056a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f01056a9:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f01056b0:	e9 5a ff ff ff       	jmp    f010560f <vprintfmt+0x39>
f01056b5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01056b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01056bb:	eb bc                	jmp    f0105679 <vprintfmt+0xa3>
			lflag++;
f01056bd:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f01056c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01056c3:	e9 47 ff ff ff       	jmp    f010560f <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
f01056c8:	8b 45 14             	mov    0x14(%ebp),%eax
f01056cb:	8d 78 04             	lea    0x4(%eax),%edi
f01056ce:	83 ec 08             	sub    $0x8,%esp
f01056d1:	53                   	push   %ebx
f01056d2:	ff 30                	pushl  (%eax)
f01056d4:	ff d6                	call   *%esi
			break;
f01056d6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01056d9:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f01056dc:	e9 57 02 00 00       	jmp    f0105938 <vprintfmt+0x362>
			err = va_arg(ap, int);
f01056e1:	8b 45 14             	mov    0x14(%ebp),%eax
f01056e4:	8d 78 04             	lea    0x4(%eax),%edi
f01056e7:	8b 00                	mov    (%eax),%eax
f01056e9:	99                   	cltd   
f01056ea:	31 d0                	xor    %edx,%eax
f01056ec:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01056ee:	83 f8 08             	cmp    $0x8,%eax
f01056f1:	7f 23                	jg     f0105716 <vprintfmt+0x140>
f01056f3:	8b 14 85 40 84 10 f0 	mov    -0xfef7bc0(,%eax,4),%edx
f01056fa:	85 d2                	test   %edx,%edx
f01056fc:	74 18                	je     f0105716 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
f01056fe:	52                   	push   %edx
f01056ff:	68 eb 78 10 f0       	push   $0xf01078eb
f0105704:	53                   	push   %ebx
f0105705:	56                   	push   %esi
f0105706:	e8 aa fe ff ff       	call   f01055b5 <printfmt>
f010570b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010570e:	89 7d 14             	mov    %edi,0x14(%ebp)
f0105711:	e9 22 02 00 00       	jmp    f0105938 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
f0105716:	50                   	push   %eax
f0105717:	68 2a 82 10 f0       	push   $0xf010822a
f010571c:	53                   	push   %ebx
f010571d:	56                   	push   %esi
f010571e:	e8 92 fe ff ff       	call   f01055b5 <printfmt>
f0105723:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0105726:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0105729:	e9 0a 02 00 00       	jmp    f0105938 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
f010572e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105731:	83 c0 04             	add    $0x4,%eax
f0105734:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0105737:	8b 45 14             	mov    0x14(%ebp),%eax
f010573a:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f010573c:	85 d2                	test   %edx,%edx
f010573e:	b8 23 82 10 f0       	mov    $0xf0108223,%eax
f0105743:	0f 45 c2             	cmovne %edx,%eax
f0105746:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
f0105749:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010574d:	7e 06                	jle    f0105755 <vprintfmt+0x17f>
f010574f:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
f0105753:	75 0d                	jne    f0105762 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105755:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105758:	89 c7                	mov    %eax,%edi
f010575a:	03 45 e0             	add    -0x20(%ebp),%eax
f010575d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105760:	eb 55                	jmp    f01057b7 <vprintfmt+0x1e1>
f0105762:	83 ec 08             	sub    $0x8,%esp
f0105765:	ff 75 d8             	pushl  -0x28(%ebp)
f0105768:	ff 75 cc             	pushl  -0x34(%ebp)
f010576b:	e8 2b 04 00 00       	call   f0105b9b <strnlen>
f0105770:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105773:	29 c2                	sub    %eax,%edx
f0105775:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0105778:	83 c4 10             	add    $0x10,%esp
f010577b:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
f010577d:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f0105781:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0105784:	85 ff                	test   %edi,%edi
f0105786:	7e 11                	jle    f0105799 <vprintfmt+0x1c3>
					putch(padc, putdat);
f0105788:	83 ec 08             	sub    $0x8,%esp
f010578b:	53                   	push   %ebx
f010578c:	ff 75 e0             	pushl  -0x20(%ebp)
f010578f:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0105791:	83 ef 01             	sub    $0x1,%edi
f0105794:	83 c4 10             	add    $0x10,%esp
f0105797:	eb eb                	jmp    f0105784 <vprintfmt+0x1ae>
f0105799:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f010579c:	85 d2                	test   %edx,%edx
f010579e:	b8 00 00 00 00       	mov    $0x0,%eax
f01057a3:	0f 49 c2             	cmovns %edx,%eax
f01057a6:	29 c2                	sub    %eax,%edx
f01057a8:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01057ab:	eb a8                	jmp    f0105755 <vprintfmt+0x17f>
					putch(ch, putdat);
f01057ad:	83 ec 08             	sub    $0x8,%esp
f01057b0:	53                   	push   %ebx
f01057b1:	52                   	push   %edx
f01057b2:	ff d6                	call   *%esi
f01057b4:	83 c4 10             	add    $0x10,%esp
f01057b7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01057ba:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01057bc:	83 c7 01             	add    $0x1,%edi
f01057bf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01057c3:	0f be d0             	movsbl %al,%edx
f01057c6:	85 d2                	test   %edx,%edx
f01057c8:	74 4b                	je     f0105815 <vprintfmt+0x23f>
f01057ca:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01057ce:	78 06                	js     f01057d6 <vprintfmt+0x200>
f01057d0:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f01057d4:	78 1e                	js     f01057f4 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
f01057d6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01057da:	74 d1                	je     f01057ad <vprintfmt+0x1d7>
f01057dc:	0f be c0             	movsbl %al,%eax
f01057df:	83 e8 20             	sub    $0x20,%eax
f01057e2:	83 f8 5e             	cmp    $0x5e,%eax
f01057e5:	76 c6                	jbe    f01057ad <vprintfmt+0x1d7>
					putch('?', putdat);
f01057e7:	83 ec 08             	sub    $0x8,%esp
f01057ea:	53                   	push   %ebx
f01057eb:	6a 3f                	push   $0x3f
f01057ed:	ff d6                	call   *%esi
f01057ef:	83 c4 10             	add    $0x10,%esp
f01057f2:	eb c3                	jmp    f01057b7 <vprintfmt+0x1e1>
f01057f4:	89 cf                	mov    %ecx,%edi
f01057f6:	eb 0e                	jmp    f0105806 <vprintfmt+0x230>
				putch(' ', putdat);
f01057f8:	83 ec 08             	sub    $0x8,%esp
f01057fb:	53                   	push   %ebx
f01057fc:	6a 20                	push   $0x20
f01057fe:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0105800:	83 ef 01             	sub    $0x1,%edi
f0105803:	83 c4 10             	add    $0x10,%esp
f0105806:	85 ff                	test   %edi,%edi
f0105808:	7f ee                	jg     f01057f8 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
f010580a:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010580d:	89 45 14             	mov    %eax,0x14(%ebp)
f0105810:	e9 23 01 00 00       	jmp    f0105938 <vprintfmt+0x362>
f0105815:	89 cf                	mov    %ecx,%edi
f0105817:	eb ed                	jmp    f0105806 <vprintfmt+0x230>
	if (lflag >= 2)
f0105819:	83 f9 01             	cmp    $0x1,%ecx
f010581c:	7f 1b                	jg     f0105839 <vprintfmt+0x263>
	else if (lflag)
f010581e:	85 c9                	test   %ecx,%ecx
f0105820:	74 63                	je     f0105885 <vprintfmt+0x2af>
		return va_arg(*ap, long);
f0105822:	8b 45 14             	mov    0x14(%ebp),%eax
f0105825:	8b 00                	mov    (%eax),%eax
f0105827:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010582a:	99                   	cltd   
f010582b:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010582e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105831:	8d 40 04             	lea    0x4(%eax),%eax
f0105834:	89 45 14             	mov    %eax,0x14(%ebp)
f0105837:	eb 17                	jmp    f0105850 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
f0105839:	8b 45 14             	mov    0x14(%ebp),%eax
f010583c:	8b 50 04             	mov    0x4(%eax),%edx
f010583f:	8b 00                	mov    (%eax),%eax
f0105841:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105844:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105847:	8b 45 14             	mov    0x14(%ebp),%eax
f010584a:	8d 40 08             	lea    0x8(%eax),%eax
f010584d:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0105850:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105853:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0105856:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f010585b:	85 c9                	test   %ecx,%ecx
f010585d:	0f 89 bb 00 00 00    	jns    f010591e <vprintfmt+0x348>
				putch('-', putdat);
f0105863:	83 ec 08             	sub    $0x8,%esp
f0105866:	53                   	push   %ebx
f0105867:	6a 2d                	push   $0x2d
f0105869:	ff d6                	call   *%esi
				num = -(long long) num;
f010586b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010586e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105871:	f7 da                	neg    %edx
f0105873:	83 d1 00             	adc    $0x0,%ecx
f0105876:	f7 d9                	neg    %ecx
f0105878:	83 c4 10             	add    $0x10,%esp
			base = 10;
f010587b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105880:	e9 99 00 00 00       	jmp    f010591e <vprintfmt+0x348>
		return va_arg(*ap, int);
f0105885:	8b 45 14             	mov    0x14(%ebp),%eax
f0105888:	8b 00                	mov    (%eax),%eax
f010588a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010588d:	99                   	cltd   
f010588e:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105891:	8b 45 14             	mov    0x14(%ebp),%eax
f0105894:	8d 40 04             	lea    0x4(%eax),%eax
f0105897:	89 45 14             	mov    %eax,0x14(%ebp)
f010589a:	eb b4                	jmp    f0105850 <vprintfmt+0x27a>
	if (lflag >= 2)
f010589c:	83 f9 01             	cmp    $0x1,%ecx
f010589f:	7f 1b                	jg     f01058bc <vprintfmt+0x2e6>
	else if (lflag)
f01058a1:	85 c9                	test   %ecx,%ecx
f01058a3:	74 2c                	je     f01058d1 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
f01058a5:	8b 45 14             	mov    0x14(%ebp),%eax
f01058a8:	8b 10                	mov    (%eax),%edx
f01058aa:	b9 00 00 00 00       	mov    $0x0,%ecx
f01058af:	8d 40 04             	lea    0x4(%eax),%eax
f01058b2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01058b5:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
f01058ba:	eb 62                	jmp    f010591e <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
f01058bc:	8b 45 14             	mov    0x14(%ebp),%eax
f01058bf:	8b 10                	mov    (%eax),%edx
f01058c1:	8b 48 04             	mov    0x4(%eax),%ecx
f01058c4:	8d 40 08             	lea    0x8(%eax),%eax
f01058c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01058ca:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
f01058cf:	eb 4d                	jmp    f010591e <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
f01058d1:	8b 45 14             	mov    0x14(%ebp),%eax
f01058d4:	8b 10                	mov    (%eax),%edx
f01058d6:	b9 00 00 00 00       	mov    $0x0,%ecx
f01058db:	8d 40 04             	lea    0x4(%eax),%eax
f01058de:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01058e1:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
f01058e6:	eb 36                	jmp    f010591e <vprintfmt+0x348>
	if (lflag >= 2)
f01058e8:	83 f9 01             	cmp    $0x1,%ecx
f01058eb:	7f 17                	jg     f0105904 <vprintfmt+0x32e>
	else if (lflag)
f01058ed:	85 c9                	test   %ecx,%ecx
f01058ef:	74 6e                	je     f010595f <vprintfmt+0x389>
		return va_arg(*ap, long);
f01058f1:	8b 45 14             	mov    0x14(%ebp),%eax
f01058f4:	8b 10                	mov    (%eax),%edx
f01058f6:	89 d0                	mov    %edx,%eax
f01058f8:	99                   	cltd   
f01058f9:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01058fc:	8d 49 04             	lea    0x4(%ecx),%ecx
f01058ff:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105902:	eb 11                	jmp    f0105915 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
f0105904:	8b 45 14             	mov    0x14(%ebp),%eax
f0105907:	8b 50 04             	mov    0x4(%eax),%edx
f010590a:	8b 00                	mov    (%eax),%eax
f010590c:	8b 4d 14             	mov    0x14(%ebp),%ecx
f010590f:	8d 49 08             	lea    0x8(%ecx),%ecx
f0105912:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
f0105915:	89 d1                	mov    %edx,%ecx
f0105917:	89 c2                	mov    %eax,%edx
            base = 8;
f0105919:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
f010591e:	83 ec 0c             	sub    $0xc,%esp
f0105921:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
f0105925:	57                   	push   %edi
f0105926:	ff 75 e0             	pushl  -0x20(%ebp)
f0105929:	50                   	push   %eax
f010592a:	51                   	push   %ecx
f010592b:	52                   	push   %edx
f010592c:	89 da                	mov    %ebx,%edx
f010592e:	89 f0                	mov    %esi,%eax
f0105930:	e8 b6 fb ff ff       	call   f01054eb <printnum>
			break;
f0105935:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f0105938:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010593b:	83 c7 01             	add    $0x1,%edi
f010593e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105942:	83 f8 25             	cmp    $0x25,%eax
f0105945:	0f 84 a6 fc ff ff    	je     f01055f1 <vprintfmt+0x1b>
			if (ch == '\0')
f010594b:	85 c0                	test   %eax,%eax
f010594d:	0f 84 ce 00 00 00    	je     f0105a21 <vprintfmt+0x44b>
			putch(ch, putdat);
f0105953:	83 ec 08             	sub    $0x8,%esp
f0105956:	53                   	push   %ebx
f0105957:	50                   	push   %eax
f0105958:	ff d6                	call   *%esi
f010595a:	83 c4 10             	add    $0x10,%esp
f010595d:	eb dc                	jmp    f010593b <vprintfmt+0x365>
		return va_arg(*ap, int);
f010595f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105962:	8b 10                	mov    (%eax),%edx
f0105964:	89 d0                	mov    %edx,%eax
f0105966:	99                   	cltd   
f0105967:	8b 4d 14             	mov    0x14(%ebp),%ecx
f010596a:	8d 49 04             	lea    0x4(%ecx),%ecx
f010596d:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105970:	eb a3                	jmp    f0105915 <vprintfmt+0x33f>
			putch('0', putdat);
f0105972:	83 ec 08             	sub    $0x8,%esp
f0105975:	53                   	push   %ebx
f0105976:	6a 30                	push   $0x30
f0105978:	ff d6                	call   *%esi
			putch('x', putdat);
f010597a:	83 c4 08             	add    $0x8,%esp
f010597d:	53                   	push   %ebx
f010597e:	6a 78                	push   $0x78
f0105980:	ff d6                	call   *%esi
			num = (unsigned long long)
f0105982:	8b 45 14             	mov    0x14(%ebp),%eax
f0105985:	8b 10                	mov    (%eax),%edx
f0105987:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f010598c:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f010598f:	8d 40 04             	lea    0x4(%eax),%eax
f0105992:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105995:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f010599a:	eb 82                	jmp    f010591e <vprintfmt+0x348>
	if (lflag >= 2)
f010599c:	83 f9 01             	cmp    $0x1,%ecx
f010599f:	7f 1e                	jg     f01059bf <vprintfmt+0x3e9>
	else if (lflag)
f01059a1:	85 c9                	test   %ecx,%ecx
f01059a3:	74 32                	je     f01059d7 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
f01059a5:	8b 45 14             	mov    0x14(%ebp),%eax
f01059a8:	8b 10                	mov    (%eax),%edx
f01059aa:	b9 00 00 00 00       	mov    $0x0,%ecx
f01059af:	8d 40 04             	lea    0x4(%eax),%eax
f01059b2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01059b5:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
f01059ba:	e9 5f ff ff ff       	jmp    f010591e <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
f01059bf:	8b 45 14             	mov    0x14(%ebp),%eax
f01059c2:	8b 10                	mov    (%eax),%edx
f01059c4:	8b 48 04             	mov    0x4(%eax),%ecx
f01059c7:	8d 40 08             	lea    0x8(%eax),%eax
f01059ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01059cd:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
f01059d2:	e9 47 ff ff ff       	jmp    f010591e <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
f01059d7:	8b 45 14             	mov    0x14(%ebp),%eax
f01059da:	8b 10                	mov    (%eax),%edx
f01059dc:	b9 00 00 00 00       	mov    $0x0,%ecx
f01059e1:	8d 40 04             	lea    0x4(%eax),%eax
f01059e4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01059e7:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
f01059ec:	e9 2d ff ff ff       	jmp    f010591e <vprintfmt+0x348>
			putch(ch, putdat);
f01059f1:	83 ec 08             	sub    $0x8,%esp
f01059f4:	53                   	push   %ebx
f01059f5:	6a 25                	push   $0x25
f01059f7:	ff d6                	call   *%esi
			break;
f01059f9:	83 c4 10             	add    $0x10,%esp
f01059fc:	e9 37 ff ff ff       	jmp    f0105938 <vprintfmt+0x362>
			putch('%', putdat);
f0105a01:	83 ec 08             	sub    $0x8,%esp
f0105a04:	53                   	push   %ebx
f0105a05:	6a 25                	push   $0x25
f0105a07:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105a09:	83 c4 10             	add    $0x10,%esp
f0105a0c:	89 f8                	mov    %edi,%eax
f0105a0e:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0105a12:	74 05                	je     f0105a19 <vprintfmt+0x443>
f0105a14:	83 e8 01             	sub    $0x1,%eax
f0105a17:	eb f5                	jmp    f0105a0e <vprintfmt+0x438>
f0105a19:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105a1c:	e9 17 ff ff ff       	jmp    f0105938 <vprintfmt+0x362>
}
f0105a21:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105a24:	5b                   	pop    %ebx
f0105a25:	5e                   	pop    %esi
f0105a26:	5f                   	pop    %edi
f0105a27:	5d                   	pop    %ebp
f0105a28:	c3                   	ret    

f0105a29 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105a29:	f3 0f 1e fb          	endbr32 
f0105a2d:	55                   	push   %ebp
f0105a2e:	89 e5                	mov    %esp,%ebp
f0105a30:	83 ec 18             	sub    $0x18,%esp
f0105a33:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a36:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105a39:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105a3c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105a40:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105a43:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105a4a:	85 c0                	test   %eax,%eax
f0105a4c:	74 26                	je     f0105a74 <vsnprintf+0x4b>
f0105a4e:	85 d2                	test   %edx,%edx
f0105a50:	7e 22                	jle    f0105a74 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105a52:	ff 75 14             	pushl  0x14(%ebp)
f0105a55:	ff 75 10             	pushl  0x10(%ebp)
f0105a58:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105a5b:	50                   	push   %eax
f0105a5c:	68 94 55 10 f0       	push   $0xf0105594
f0105a61:	e8 70 fb ff ff       	call   f01055d6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105a66:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105a69:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105a6f:	83 c4 10             	add    $0x10,%esp
}
f0105a72:	c9                   	leave  
f0105a73:	c3                   	ret    
		return -E_INVAL;
f0105a74:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105a79:	eb f7                	jmp    f0105a72 <vsnprintf+0x49>

f0105a7b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105a7b:	f3 0f 1e fb          	endbr32 
f0105a7f:	55                   	push   %ebp
f0105a80:	89 e5                	mov    %esp,%ebp
f0105a82:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105a85:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105a88:	50                   	push   %eax
f0105a89:	ff 75 10             	pushl  0x10(%ebp)
f0105a8c:	ff 75 0c             	pushl  0xc(%ebp)
f0105a8f:	ff 75 08             	pushl  0x8(%ebp)
f0105a92:	e8 92 ff ff ff       	call   f0105a29 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105a97:	c9                   	leave  
f0105a98:	c3                   	ret    

f0105a99 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105a99:	f3 0f 1e fb          	endbr32 
f0105a9d:	55                   	push   %ebp
f0105a9e:	89 e5                	mov    %esp,%ebp
f0105aa0:	57                   	push   %edi
f0105aa1:	56                   	push   %esi
f0105aa2:	53                   	push   %ebx
f0105aa3:	83 ec 0c             	sub    $0xc,%esp
f0105aa6:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105aa9:	85 c0                	test   %eax,%eax
f0105aab:	74 11                	je     f0105abe <readline+0x25>
		cprintf("%s", prompt);
f0105aad:	83 ec 08             	sub    $0x8,%esp
f0105ab0:	50                   	push   %eax
f0105ab1:	68 eb 78 10 f0       	push   $0xf01078eb
f0105ab6:	e8 3d e0 ff ff       	call   f0103af8 <cprintf>
f0105abb:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0105abe:	83 ec 0c             	sub    $0xc,%esp
f0105ac1:	6a 00                	push   $0x0
f0105ac3:	e8 d5 ac ff ff       	call   f010079d <iscons>
f0105ac8:	89 c7                	mov    %eax,%edi
f0105aca:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0105acd:	be 00 00 00 00       	mov    $0x0,%esi
f0105ad2:	eb 4b                	jmp    f0105b1f <readline+0x86>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0105ad4:	83 ec 08             	sub    $0x8,%esp
f0105ad7:	50                   	push   %eax
f0105ad8:	68 64 84 10 f0       	push   $0xf0108464
f0105add:	e8 16 e0 ff ff       	call   f0103af8 <cprintf>
			return NULL;
f0105ae2:	83 c4 10             	add    $0x10,%esp
f0105ae5:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0105aea:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105aed:	5b                   	pop    %ebx
f0105aee:	5e                   	pop    %esi
f0105aef:	5f                   	pop    %edi
f0105af0:	5d                   	pop    %ebp
f0105af1:	c3                   	ret    
			if (echoing)
f0105af2:	85 ff                	test   %edi,%edi
f0105af4:	75 05                	jne    f0105afb <readline+0x62>
			i--;
f0105af6:	83 ee 01             	sub    $0x1,%esi
f0105af9:	eb 24                	jmp    f0105b1f <readline+0x86>
				cputchar('\b');
f0105afb:	83 ec 0c             	sub    $0xc,%esp
f0105afe:	6a 08                	push   $0x8
f0105b00:	e8 6f ac ff ff       	call   f0100774 <cputchar>
f0105b05:	83 c4 10             	add    $0x10,%esp
f0105b08:	eb ec                	jmp    f0105af6 <readline+0x5d>
				cputchar(c);
f0105b0a:	83 ec 0c             	sub    $0xc,%esp
f0105b0d:	53                   	push   %ebx
f0105b0e:	e8 61 ac ff ff       	call   f0100774 <cputchar>
f0105b13:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105b16:	88 9e 80 7a 23 f0    	mov    %bl,-0xfdc8580(%esi)
f0105b1c:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f0105b1f:	e8 64 ac ff ff       	call   f0100788 <getchar>
f0105b24:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105b26:	85 c0                	test   %eax,%eax
f0105b28:	78 aa                	js     f0105ad4 <readline+0x3b>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105b2a:	83 f8 08             	cmp    $0x8,%eax
f0105b2d:	0f 94 c2             	sete   %dl
f0105b30:	83 f8 7f             	cmp    $0x7f,%eax
f0105b33:	0f 94 c0             	sete   %al
f0105b36:	08 c2                	or     %al,%dl
f0105b38:	74 04                	je     f0105b3e <readline+0xa5>
f0105b3a:	85 f6                	test   %esi,%esi
f0105b3c:	7f b4                	jg     f0105af2 <readline+0x59>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105b3e:	83 fb 1f             	cmp    $0x1f,%ebx
f0105b41:	7e 0e                	jle    f0105b51 <readline+0xb8>
f0105b43:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105b49:	7f 06                	jg     f0105b51 <readline+0xb8>
			if (echoing)
f0105b4b:	85 ff                	test   %edi,%edi
f0105b4d:	74 c7                	je     f0105b16 <readline+0x7d>
f0105b4f:	eb b9                	jmp    f0105b0a <readline+0x71>
		} else if (c == '\n' || c == '\r') {
f0105b51:	83 fb 0a             	cmp    $0xa,%ebx
f0105b54:	74 05                	je     f0105b5b <readline+0xc2>
f0105b56:	83 fb 0d             	cmp    $0xd,%ebx
f0105b59:	75 c4                	jne    f0105b1f <readline+0x86>
			if (echoing)
f0105b5b:	85 ff                	test   %edi,%edi
f0105b5d:	75 11                	jne    f0105b70 <readline+0xd7>
			buf[i] = 0;
f0105b5f:	c6 86 80 7a 23 f0 00 	movb   $0x0,-0xfdc8580(%esi)
			return buf;
f0105b66:	b8 80 7a 23 f0       	mov    $0xf0237a80,%eax
f0105b6b:	e9 7a ff ff ff       	jmp    f0105aea <readline+0x51>
				cputchar('\n');
f0105b70:	83 ec 0c             	sub    $0xc,%esp
f0105b73:	6a 0a                	push   $0xa
f0105b75:	e8 fa ab ff ff       	call   f0100774 <cputchar>
f0105b7a:	83 c4 10             	add    $0x10,%esp
f0105b7d:	eb e0                	jmp    f0105b5f <readline+0xc6>

f0105b7f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105b7f:	f3 0f 1e fb          	endbr32 
f0105b83:	55                   	push   %ebp
f0105b84:	89 e5                	mov    %esp,%ebp
f0105b86:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105b89:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b8e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105b92:	74 05                	je     f0105b99 <strlen+0x1a>
		n++;
f0105b94:	83 c0 01             	add    $0x1,%eax
f0105b97:	eb f5                	jmp    f0105b8e <strlen+0xf>
	return n;
}
f0105b99:	5d                   	pop    %ebp
f0105b9a:	c3                   	ret    

f0105b9b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105b9b:	f3 0f 1e fb          	endbr32 
f0105b9f:	55                   	push   %ebp
f0105ba0:	89 e5                	mov    %esp,%ebp
f0105ba2:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105ba5:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105ba8:	b8 00 00 00 00       	mov    $0x0,%eax
f0105bad:	39 d0                	cmp    %edx,%eax
f0105baf:	74 0d                	je     f0105bbe <strnlen+0x23>
f0105bb1:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0105bb5:	74 05                	je     f0105bbc <strnlen+0x21>
		n++;
f0105bb7:	83 c0 01             	add    $0x1,%eax
f0105bba:	eb f1                	jmp    f0105bad <strnlen+0x12>
f0105bbc:	89 c2                	mov    %eax,%edx
	return n;
}
f0105bbe:	89 d0                	mov    %edx,%eax
f0105bc0:	5d                   	pop    %ebp
f0105bc1:	c3                   	ret    

f0105bc2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105bc2:	f3 0f 1e fb          	endbr32 
f0105bc6:	55                   	push   %ebp
f0105bc7:	89 e5                	mov    %esp,%ebp
f0105bc9:	53                   	push   %ebx
f0105bca:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105bcd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105bd0:	b8 00 00 00 00       	mov    $0x0,%eax
f0105bd5:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f0105bd9:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f0105bdc:	83 c0 01             	add    $0x1,%eax
f0105bdf:	84 d2                	test   %dl,%dl
f0105be1:	75 f2                	jne    f0105bd5 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
f0105be3:	89 c8                	mov    %ecx,%eax
f0105be5:	5b                   	pop    %ebx
f0105be6:	5d                   	pop    %ebp
f0105be7:	c3                   	ret    

f0105be8 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105be8:	f3 0f 1e fb          	endbr32 
f0105bec:	55                   	push   %ebp
f0105bed:	89 e5                	mov    %esp,%ebp
f0105bef:	53                   	push   %ebx
f0105bf0:	83 ec 10             	sub    $0x10,%esp
f0105bf3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105bf6:	53                   	push   %ebx
f0105bf7:	e8 83 ff ff ff       	call   f0105b7f <strlen>
f0105bfc:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0105bff:	ff 75 0c             	pushl  0xc(%ebp)
f0105c02:	01 d8                	add    %ebx,%eax
f0105c04:	50                   	push   %eax
f0105c05:	e8 b8 ff ff ff       	call   f0105bc2 <strcpy>
	return dst;
}
f0105c0a:	89 d8                	mov    %ebx,%eax
f0105c0c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105c0f:	c9                   	leave  
f0105c10:	c3                   	ret    

f0105c11 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105c11:	f3 0f 1e fb          	endbr32 
f0105c15:	55                   	push   %ebp
f0105c16:	89 e5                	mov    %esp,%ebp
f0105c18:	56                   	push   %esi
f0105c19:	53                   	push   %ebx
f0105c1a:	8b 75 08             	mov    0x8(%ebp),%esi
f0105c1d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105c20:	89 f3                	mov    %esi,%ebx
f0105c22:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105c25:	89 f0                	mov    %esi,%eax
f0105c27:	39 d8                	cmp    %ebx,%eax
f0105c29:	74 11                	je     f0105c3c <strncpy+0x2b>
		*dst++ = *src;
f0105c2b:	83 c0 01             	add    $0x1,%eax
f0105c2e:	0f b6 0a             	movzbl (%edx),%ecx
f0105c31:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105c34:	80 f9 01             	cmp    $0x1,%cl
f0105c37:	83 da ff             	sbb    $0xffffffff,%edx
f0105c3a:	eb eb                	jmp    f0105c27 <strncpy+0x16>
	}
	return ret;
}
f0105c3c:	89 f0                	mov    %esi,%eax
f0105c3e:	5b                   	pop    %ebx
f0105c3f:	5e                   	pop    %esi
f0105c40:	5d                   	pop    %ebp
f0105c41:	c3                   	ret    

f0105c42 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105c42:	f3 0f 1e fb          	endbr32 
f0105c46:	55                   	push   %ebp
f0105c47:	89 e5                	mov    %esp,%ebp
f0105c49:	56                   	push   %esi
f0105c4a:	53                   	push   %ebx
f0105c4b:	8b 75 08             	mov    0x8(%ebp),%esi
f0105c4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105c51:	8b 55 10             	mov    0x10(%ebp),%edx
f0105c54:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105c56:	85 d2                	test   %edx,%edx
f0105c58:	74 21                	je     f0105c7b <strlcpy+0x39>
f0105c5a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105c5e:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f0105c60:	39 c2                	cmp    %eax,%edx
f0105c62:	74 14                	je     f0105c78 <strlcpy+0x36>
f0105c64:	0f b6 19             	movzbl (%ecx),%ebx
f0105c67:	84 db                	test   %bl,%bl
f0105c69:	74 0b                	je     f0105c76 <strlcpy+0x34>
			*dst++ = *src++;
f0105c6b:	83 c1 01             	add    $0x1,%ecx
f0105c6e:	83 c2 01             	add    $0x1,%edx
f0105c71:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105c74:	eb ea                	jmp    f0105c60 <strlcpy+0x1e>
f0105c76:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0105c78:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105c7b:	29 f0                	sub    %esi,%eax
}
f0105c7d:	5b                   	pop    %ebx
f0105c7e:	5e                   	pop    %esi
f0105c7f:	5d                   	pop    %ebp
f0105c80:	c3                   	ret    

f0105c81 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105c81:	f3 0f 1e fb          	endbr32 
f0105c85:	55                   	push   %ebp
f0105c86:	89 e5                	mov    %esp,%ebp
f0105c88:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105c8b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105c8e:	0f b6 01             	movzbl (%ecx),%eax
f0105c91:	84 c0                	test   %al,%al
f0105c93:	74 0c                	je     f0105ca1 <strcmp+0x20>
f0105c95:	3a 02                	cmp    (%edx),%al
f0105c97:	75 08                	jne    f0105ca1 <strcmp+0x20>
		p++, q++;
f0105c99:	83 c1 01             	add    $0x1,%ecx
f0105c9c:	83 c2 01             	add    $0x1,%edx
f0105c9f:	eb ed                	jmp    f0105c8e <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105ca1:	0f b6 c0             	movzbl %al,%eax
f0105ca4:	0f b6 12             	movzbl (%edx),%edx
f0105ca7:	29 d0                	sub    %edx,%eax
}
f0105ca9:	5d                   	pop    %ebp
f0105caa:	c3                   	ret    

f0105cab <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105cab:	f3 0f 1e fb          	endbr32 
f0105caf:	55                   	push   %ebp
f0105cb0:	89 e5                	mov    %esp,%ebp
f0105cb2:	53                   	push   %ebx
f0105cb3:	8b 45 08             	mov    0x8(%ebp),%eax
f0105cb6:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105cb9:	89 c3                	mov    %eax,%ebx
f0105cbb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105cbe:	eb 06                	jmp    f0105cc6 <strncmp+0x1b>
		n--, p++, q++;
f0105cc0:	83 c0 01             	add    $0x1,%eax
f0105cc3:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0105cc6:	39 d8                	cmp    %ebx,%eax
f0105cc8:	74 16                	je     f0105ce0 <strncmp+0x35>
f0105cca:	0f b6 08             	movzbl (%eax),%ecx
f0105ccd:	84 c9                	test   %cl,%cl
f0105ccf:	74 04                	je     f0105cd5 <strncmp+0x2a>
f0105cd1:	3a 0a                	cmp    (%edx),%cl
f0105cd3:	74 eb                	je     f0105cc0 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105cd5:	0f b6 00             	movzbl (%eax),%eax
f0105cd8:	0f b6 12             	movzbl (%edx),%edx
f0105cdb:	29 d0                	sub    %edx,%eax
}
f0105cdd:	5b                   	pop    %ebx
f0105cde:	5d                   	pop    %ebp
f0105cdf:	c3                   	ret    
		return 0;
f0105ce0:	b8 00 00 00 00       	mov    $0x0,%eax
f0105ce5:	eb f6                	jmp    f0105cdd <strncmp+0x32>

f0105ce7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105ce7:	f3 0f 1e fb          	endbr32 
f0105ceb:	55                   	push   %ebp
f0105cec:	89 e5                	mov    %esp,%ebp
f0105cee:	8b 45 08             	mov    0x8(%ebp),%eax
f0105cf1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105cf5:	0f b6 10             	movzbl (%eax),%edx
f0105cf8:	84 d2                	test   %dl,%dl
f0105cfa:	74 09                	je     f0105d05 <strchr+0x1e>
		if (*s == c)
f0105cfc:	38 ca                	cmp    %cl,%dl
f0105cfe:	74 0a                	je     f0105d0a <strchr+0x23>
	for (; *s; s++)
f0105d00:	83 c0 01             	add    $0x1,%eax
f0105d03:	eb f0                	jmp    f0105cf5 <strchr+0xe>
			return (char *) s;
	return 0;
f0105d05:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105d0a:	5d                   	pop    %ebp
f0105d0b:	c3                   	ret    

f0105d0c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105d0c:	f3 0f 1e fb          	endbr32 
f0105d10:	55                   	push   %ebp
f0105d11:	89 e5                	mov    %esp,%ebp
f0105d13:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d16:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105d1a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105d1d:	38 ca                	cmp    %cl,%dl
f0105d1f:	74 09                	je     f0105d2a <strfind+0x1e>
f0105d21:	84 d2                	test   %dl,%dl
f0105d23:	74 05                	je     f0105d2a <strfind+0x1e>
	for (; *s; s++)
f0105d25:	83 c0 01             	add    $0x1,%eax
f0105d28:	eb f0                	jmp    f0105d1a <strfind+0xe>
			break;
	return (char *) s;
}
f0105d2a:	5d                   	pop    %ebp
f0105d2b:	c3                   	ret    

f0105d2c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105d2c:	f3 0f 1e fb          	endbr32 
f0105d30:	55                   	push   %ebp
f0105d31:	89 e5                	mov    %esp,%ebp
f0105d33:	57                   	push   %edi
f0105d34:	56                   	push   %esi
f0105d35:	53                   	push   %ebx
f0105d36:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105d39:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105d3c:	85 c9                	test   %ecx,%ecx
f0105d3e:	74 31                	je     f0105d71 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105d40:	89 f8                	mov    %edi,%eax
f0105d42:	09 c8                	or     %ecx,%eax
f0105d44:	a8 03                	test   $0x3,%al
f0105d46:	75 23                	jne    f0105d6b <memset+0x3f>
		c &= 0xFF;
f0105d48:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105d4c:	89 d3                	mov    %edx,%ebx
f0105d4e:	c1 e3 08             	shl    $0x8,%ebx
f0105d51:	89 d0                	mov    %edx,%eax
f0105d53:	c1 e0 18             	shl    $0x18,%eax
f0105d56:	89 d6                	mov    %edx,%esi
f0105d58:	c1 e6 10             	shl    $0x10,%esi
f0105d5b:	09 f0                	or     %esi,%eax
f0105d5d:	09 c2                	or     %eax,%edx
f0105d5f:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105d61:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0105d64:	89 d0                	mov    %edx,%eax
f0105d66:	fc                   	cld    
f0105d67:	f3 ab                	rep stos %eax,%es:(%edi)
f0105d69:	eb 06                	jmp    f0105d71 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105d6b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105d6e:	fc                   	cld    
f0105d6f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105d71:	89 f8                	mov    %edi,%eax
f0105d73:	5b                   	pop    %ebx
f0105d74:	5e                   	pop    %esi
f0105d75:	5f                   	pop    %edi
f0105d76:	5d                   	pop    %ebp
f0105d77:	c3                   	ret    

f0105d78 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105d78:	f3 0f 1e fb          	endbr32 
f0105d7c:	55                   	push   %ebp
f0105d7d:	89 e5                	mov    %esp,%ebp
f0105d7f:	57                   	push   %edi
f0105d80:	56                   	push   %esi
f0105d81:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d84:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105d87:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105d8a:	39 c6                	cmp    %eax,%esi
f0105d8c:	73 32                	jae    f0105dc0 <memmove+0x48>
f0105d8e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105d91:	39 c2                	cmp    %eax,%edx
f0105d93:	76 2b                	jbe    f0105dc0 <memmove+0x48>
		s += n;
		d += n;
f0105d95:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105d98:	89 fe                	mov    %edi,%esi
f0105d9a:	09 ce                	or     %ecx,%esi
f0105d9c:	09 d6                	or     %edx,%esi
f0105d9e:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105da4:	75 0e                	jne    f0105db4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105da6:	83 ef 04             	sub    $0x4,%edi
f0105da9:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105dac:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0105daf:	fd                   	std    
f0105db0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105db2:	eb 09                	jmp    f0105dbd <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105db4:	83 ef 01             	sub    $0x1,%edi
f0105db7:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0105dba:	fd                   	std    
f0105dbb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105dbd:	fc                   	cld    
f0105dbe:	eb 1a                	jmp    f0105dda <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105dc0:	89 c2                	mov    %eax,%edx
f0105dc2:	09 ca                	or     %ecx,%edx
f0105dc4:	09 f2                	or     %esi,%edx
f0105dc6:	f6 c2 03             	test   $0x3,%dl
f0105dc9:	75 0a                	jne    f0105dd5 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105dcb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0105dce:	89 c7                	mov    %eax,%edi
f0105dd0:	fc                   	cld    
f0105dd1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105dd3:	eb 05                	jmp    f0105dda <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
f0105dd5:	89 c7                	mov    %eax,%edi
f0105dd7:	fc                   	cld    
f0105dd8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105dda:	5e                   	pop    %esi
f0105ddb:	5f                   	pop    %edi
f0105ddc:	5d                   	pop    %ebp
f0105ddd:	c3                   	ret    

f0105dde <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105dde:	f3 0f 1e fb          	endbr32 
f0105de2:	55                   	push   %ebp
f0105de3:	89 e5                	mov    %esp,%ebp
f0105de5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105de8:	ff 75 10             	pushl  0x10(%ebp)
f0105deb:	ff 75 0c             	pushl  0xc(%ebp)
f0105dee:	ff 75 08             	pushl  0x8(%ebp)
f0105df1:	e8 82 ff ff ff       	call   f0105d78 <memmove>
}
f0105df6:	c9                   	leave  
f0105df7:	c3                   	ret    

f0105df8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105df8:	f3 0f 1e fb          	endbr32 
f0105dfc:	55                   	push   %ebp
f0105dfd:	89 e5                	mov    %esp,%ebp
f0105dff:	56                   	push   %esi
f0105e00:	53                   	push   %ebx
f0105e01:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e04:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105e07:	89 c6                	mov    %eax,%esi
f0105e09:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105e0c:	39 f0                	cmp    %esi,%eax
f0105e0e:	74 1c                	je     f0105e2c <memcmp+0x34>
		if (*s1 != *s2)
f0105e10:	0f b6 08             	movzbl (%eax),%ecx
f0105e13:	0f b6 1a             	movzbl (%edx),%ebx
f0105e16:	38 d9                	cmp    %bl,%cl
f0105e18:	75 08                	jne    f0105e22 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0105e1a:	83 c0 01             	add    $0x1,%eax
f0105e1d:	83 c2 01             	add    $0x1,%edx
f0105e20:	eb ea                	jmp    f0105e0c <memcmp+0x14>
			return (int) *s1 - (int) *s2;
f0105e22:	0f b6 c1             	movzbl %cl,%eax
f0105e25:	0f b6 db             	movzbl %bl,%ebx
f0105e28:	29 d8                	sub    %ebx,%eax
f0105e2a:	eb 05                	jmp    f0105e31 <memcmp+0x39>
	}

	return 0;
f0105e2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105e31:	5b                   	pop    %ebx
f0105e32:	5e                   	pop    %esi
f0105e33:	5d                   	pop    %ebp
f0105e34:	c3                   	ret    

f0105e35 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105e35:	f3 0f 1e fb          	endbr32 
f0105e39:	55                   	push   %ebp
f0105e3a:	89 e5                	mov    %esp,%ebp
f0105e3c:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105e42:	89 c2                	mov    %eax,%edx
f0105e44:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105e47:	39 d0                	cmp    %edx,%eax
f0105e49:	73 09                	jae    f0105e54 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105e4b:	38 08                	cmp    %cl,(%eax)
f0105e4d:	74 05                	je     f0105e54 <memfind+0x1f>
	for (; s < ends; s++)
f0105e4f:	83 c0 01             	add    $0x1,%eax
f0105e52:	eb f3                	jmp    f0105e47 <memfind+0x12>
			break;
	return (void *) s;
}
f0105e54:	5d                   	pop    %ebp
f0105e55:	c3                   	ret    

f0105e56 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105e56:	f3 0f 1e fb          	endbr32 
f0105e5a:	55                   	push   %ebp
f0105e5b:	89 e5                	mov    %esp,%ebp
f0105e5d:	57                   	push   %edi
f0105e5e:	56                   	push   %esi
f0105e5f:	53                   	push   %ebx
f0105e60:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105e63:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105e66:	eb 03                	jmp    f0105e6b <strtol+0x15>
		s++;
f0105e68:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0105e6b:	0f b6 01             	movzbl (%ecx),%eax
f0105e6e:	3c 20                	cmp    $0x20,%al
f0105e70:	74 f6                	je     f0105e68 <strtol+0x12>
f0105e72:	3c 09                	cmp    $0x9,%al
f0105e74:	74 f2                	je     f0105e68 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
f0105e76:	3c 2b                	cmp    $0x2b,%al
f0105e78:	74 2a                	je     f0105ea4 <strtol+0x4e>
	int neg = 0;
f0105e7a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0105e7f:	3c 2d                	cmp    $0x2d,%al
f0105e81:	74 2b                	je     f0105eae <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105e83:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105e89:	75 0f                	jne    f0105e9a <strtol+0x44>
f0105e8b:	80 39 30             	cmpb   $0x30,(%ecx)
f0105e8e:	74 28                	je     f0105eb8 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105e90:	85 db                	test   %ebx,%ebx
f0105e92:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105e97:	0f 44 d8             	cmove  %eax,%ebx
f0105e9a:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e9f:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105ea2:	eb 46                	jmp    f0105eea <strtol+0x94>
		s++;
f0105ea4:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0105ea7:	bf 00 00 00 00       	mov    $0x0,%edi
f0105eac:	eb d5                	jmp    f0105e83 <strtol+0x2d>
		s++, neg = 1;
f0105eae:	83 c1 01             	add    $0x1,%ecx
f0105eb1:	bf 01 00 00 00       	mov    $0x1,%edi
f0105eb6:	eb cb                	jmp    f0105e83 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105eb8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105ebc:	74 0e                	je     f0105ecc <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0105ebe:	85 db                	test   %ebx,%ebx
f0105ec0:	75 d8                	jne    f0105e9a <strtol+0x44>
		s++, base = 8;
f0105ec2:	83 c1 01             	add    $0x1,%ecx
f0105ec5:	bb 08 00 00 00       	mov    $0x8,%ebx
f0105eca:	eb ce                	jmp    f0105e9a <strtol+0x44>
		s += 2, base = 16;
f0105ecc:	83 c1 02             	add    $0x2,%ecx
f0105ecf:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105ed4:	eb c4                	jmp    f0105e9a <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f0105ed6:	0f be d2             	movsbl %dl,%edx
f0105ed9:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105edc:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105edf:	7d 3a                	jge    f0105f1b <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f0105ee1:	83 c1 01             	add    $0x1,%ecx
f0105ee4:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105ee8:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0105eea:	0f b6 11             	movzbl (%ecx),%edx
f0105eed:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105ef0:	89 f3                	mov    %esi,%ebx
f0105ef2:	80 fb 09             	cmp    $0x9,%bl
f0105ef5:	76 df                	jbe    f0105ed6 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
f0105ef7:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105efa:	89 f3                	mov    %esi,%ebx
f0105efc:	80 fb 19             	cmp    $0x19,%bl
f0105eff:	77 08                	ja     f0105f09 <strtol+0xb3>
			dig = *s - 'a' + 10;
f0105f01:	0f be d2             	movsbl %dl,%edx
f0105f04:	83 ea 57             	sub    $0x57,%edx
f0105f07:	eb d3                	jmp    f0105edc <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
f0105f09:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105f0c:	89 f3                	mov    %esi,%ebx
f0105f0e:	80 fb 19             	cmp    $0x19,%bl
f0105f11:	77 08                	ja     f0105f1b <strtol+0xc5>
			dig = *s - 'A' + 10;
f0105f13:	0f be d2             	movsbl %dl,%edx
f0105f16:	83 ea 37             	sub    $0x37,%edx
f0105f19:	eb c1                	jmp    f0105edc <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
f0105f1b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105f1f:	74 05                	je     f0105f26 <strtol+0xd0>
		*endptr = (char *) s;
f0105f21:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105f24:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0105f26:	89 c2                	mov    %eax,%edx
f0105f28:	f7 da                	neg    %edx
f0105f2a:	85 ff                	test   %edi,%edi
f0105f2c:	0f 45 c2             	cmovne %edx,%eax
}
f0105f2f:	5b                   	pop    %ebx
f0105f30:	5e                   	pop    %esi
f0105f31:	5f                   	pop    %edi
f0105f32:	5d                   	pop    %ebp
f0105f33:	c3                   	ret    

f0105f34 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105f34:	fa                   	cli    

	xorw    %ax, %ax
f0105f35:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105f37:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105f39:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105f3b:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105f3d:	0f 01 16             	lgdtl  (%esi)
f0105f40:	74 70                	je     f0105fb2 <mpsearch1+0x3>
	movl    %cr0, %eax
f0105f42:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105f45:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105f49:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105f4c:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105f52:	08 00                	or     %al,(%eax)

f0105f54 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105f54:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105f58:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105f5a:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105f5c:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105f5e:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105f62:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105f64:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105f66:	b8 00 10 12 00       	mov    $0x121000,%eax
	movl    %eax, %cr3
f0105f6b:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105f6e:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105f71:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105f76:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105f79:	8b 25 84 7e 23 f0    	mov    0xf0237e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105f7f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105f84:	b8 a9 01 10 f0       	mov    $0xf01001a9,%eax
	call    *%eax
f0105f89:	ff d0                	call   *%eax

f0105f8b <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105f8b:	eb fe                	jmp    f0105f8b <spin>
f0105f8d:	8d 76 00             	lea    0x0(%esi),%esi

f0105f90 <gdt>:
	...
f0105f98:	ff                   	(bad)  
f0105f99:	ff 00                	incl   (%eax)
f0105f9b:	00 00                	add    %al,(%eax)
f0105f9d:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105fa4:	00                   	.byte 0x0
f0105fa5:	92                   	xchg   %eax,%edx
f0105fa6:	cf                   	iret   
	...

f0105fa8 <gdtdesc>:
f0105fa8:	17                   	pop    %ss
f0105fa9:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105fae <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105fae:	90                   	nop

f0105faf <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105faf:	55                   	push   %ebp
f0105fb0:	89 e5                	mov    %esp,%ebp
f0105fb2:	57                   	push   %edi
f0105fb3:	56                   	push   %esi
f0105fb4:	53                   	push   %ebx
f0105fb5:	83 ec 0c             	sub    $0xc,%esp
f0105fb8:	89 c7                	mov    %eax,%edi
	if (PGNUM(pa) >= npages)
f0105fba:	a1 88 7e 23 f0       	mov    0xf0237e88,%eax
f0105fbf:	89 f9                	mov    %edi,%ecx
f0105fc1:	c1 e9 0c             	shr    $0xc,%ecx
f0105fc4:	39 c1                	cmp    %eax,%ecx
f0105fc6:	73 19                	jae    f0105fe1 <mpsearch1+0x32>
	return (void *)(pa + KERNBASE);
f0105fc8:	8d 9f 00 00 00 f0    	lea    -0x10000000(%edi),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105fce:	01 d7                	add    %edx,%edi
	if (PGNUM(pa) >= npages)
f0105fd0:	89 fa                	mov    %edi,%edx
f0105fd2:	c1 ea 0c             	shr    $0xc,%edx
f0105fd5:	39 c2                	cmp    %eax,%edx
f0105fd7:	73 1a                	jae    f0105ff3 <mpsearch1+0x44>
	return (void *)(pa + KERNBASE);
f0105fd9:	81 ef 00 00 00 10    	sub    $0x10000000,%edi

	for (; mp < end; mp++)
f0105fdf:	eb 27                	jmp    f0106008 <mpsearch1+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105fe1:	57                   	push   %edi
f0105fe2:	68 e4 69 10 f0       	push   $0xf01069e4
f0105fe7:	6a 57                	push   $0x57
f0105fe9:	68 01 86 10 f0       	push   $0xf0108601
f0105fee:	e8 4d a0 ff ff       	call   f0100040 <_panic>
f0105ff3:	57                   	push   %edi
f0105ff4:	68 e4 69 10 f0       	push   $0xf01069e4
f0105ff9:	6a 57                	push   $0x57
f0105ffb:	68 01 86 10 f0       	push   $0xf0108601
f0106000:	e8 3b a0 ff ff       	call   f0100040 <_panic>
f0106005:	83 c3 10             	add    $0x10,%ebx
f0106008:	39 fb                	cmp    %edi,%ebx
f010600a:	73 30                	jae    f010603c <mpsearch1+0x8d>
f010600c:	89 de                	mov    %ebx,%esi
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010600e:	83 ec 04             	sub    $0x4,%esp
f0106011:	6a 04                	push   $0x4
f0106013:	68 11 86 10 f0       	push   $0xf0108611
f0106018:	53                   	push   %ebx
f0106019:	e8 da fd ff ff       	call   f0105df8 <memcmp>
f010601e:	83 c4 10             	add    $0x10,%esp
f0106021:	85 c0                	test   %eax,%eax
f0106023:	75 e0                	jne    f0106005 <mpsearch1+0x56>
f0106025:	89 da                	mov    %ebx,%edx
	for (i = 0; i < len; i++)
f0106027:	83 c6 10             	add    $0x10,%esi
		sum += ((uint8_t *)addr)[i];
f010602a:	0f b6 0a             	movzbl (%edx),%ecx
f010602d:	01 c8                	add    %ecx,%eax
f010602f:	83 c2 01             	add    $0x1,%edx
	for (i = 0; i < len; i++)
f0106032:	39 f2                	cmp    %esi,%edx
f0106034:	75 f4                	jne    f010602a <mpsearch1+0x7b>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106036:	84 c0                	test   %al,%al
f0106038:	75 cb                	jne    f0106005 <mpsearch1+0x56>
f010603a:	eb 05                	jmp    f0106041 <mpsearch1+0x92>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f010603c:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0106041:	89 d8                	mov    %ebx,%eax
f0106043:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106046:	5b                   	pop    %ebx
f0106047:	5e                   	pop    %esi
f0106048:	5f                   	pop    %edi
f0106049:	5d                   	pop    %ebp
f010604a:	c3                   	ret    

f010604b <mp_init>:
	return conf;
}

void
mp_init(void)
{
f010604b:	f3 0f 1e fb          	endbr32 
f010604f:	55                   	push   %ebp
f0106050:	89 e5                	mov    %esp,%ebp
f0106052:	57                   	push   %edi
f0106053:	56                   	push   %esi
f0106054:	53                   	push   %ebx
f0106055:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0106058:	c7 05 c0 83 23 f0 20 	movl   $0xf0238020,0xf02383c0
f010605f:	80 23 f0 
	if (PGNUM(pa) >= npages)
f0106062:	83 3d 88 7e 23 f0 00 	cmpl   $0x0,0xf0237e88
f0106069:	0f 84 a3 00 00 00    	je     f0106112 <mp_init+0xc7>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f010606f:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0106076:	85 c0                	test   %eax,%eax
f0106078:	0f 84 aa 00 00 00    	je     f0106128 <mp_init+0xdd>
		p <<= 4;	// Translate from segment to PA
f010607e:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0106081:	ba 00 04 00 00       	mov    $0x400,%edx
f0106086:	e8 24 ff ff ff       	call   f0105faf <mpsearch1>
f010608b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010608e:	85 c0                	test   %eax,%eax
f0106090:	75 1a                	jne    f01060ac <mp_init+0x61>
	return mpsearch1(0xF0000, 0x10000);
f0106092:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106097:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f010609c:	e8 0e ff ff ff       	call   f0105faf <mpsearch1>
f01060a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((mp = mpsearch()) == 0)
f01060a4:	85 c0                	test   %eax,%eax
f01060a6:	0f 84 35 02 00 00    	je     f01062e1 <mp_init+0x296>
	if (mp->physaddr == 0 || mp->type != 0) {
f01060ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01060af:	8b 58 04             	mov    0x4(%eax),%ebx
f01060b2:	85 db                	test   %ebx,%ebx
f01060b4:	0f 84 97 00 00 00    	je     f0106151 <mp_init+0x106>
f01060ba:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f01060be:	0f 85 8d 00 00 00    	jne    f0106151 <mp_init+0x106>
f01060c4:	89 d8                	mov    %ebx,%eax
f01060c6:	c1 e8 0c             	shr    $0xc,%eax
f01060c9:	3b 05 88 7e 23 f0    	cmp    0xf0237e88,%eax
f01060cf:	0f 83 91 00 00 00    	jae    f0106166 <mp_init+0x11b>
	return (void *)(pa + KERNBASE);
f01060d5:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
f01060db:	89 de                	mov    %ebx,%esi
	if (memcmp(conf, "PCMP", 4) != 0) {
f01060dd:	83 ec 04             	sub    $0x4,%esp
f01060e0:	6a 04                	push   $0x4
f01060e2:	68 16 86 10 f0       	push   $0xf0108616
f01060e7:	53                   	push   %ebx
f01060e8:	e8 0b fd ff ff       	call   f0105df8 <memcmp>
f01060ed:	83 c4 10             	add    $0x10,%esp
f01060f0:	85 c0                	test   %eax,%eax
f01060f2:	0f 85 83 00 00 00    	jne    f010617b <mp_init+0x130>
f01060f8:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
f01060fc:	01 df                	add    %ebx,%edi
	sum = 0;
f01060fe:	89 c2                	mov    %eax,%edx
	for (i = 0; i < len; i++)
f0106100:	39 fb                	cmp    %edi,%ebx
f0106102:	0f 84 88 00 00 00    	je     f0106190 <mp_init+0x145>
		sum += ((uint8_t *)addr)[i];
f0106108:	0f b6 0b             	movzbl (%ebx),%ecx
f010610b:	01 ca                	add    %ecx,%edx
f010610d:	83 c3 01             	add    $0x1,%ebx
f0106110:	eb ee                	jmp    f0106100 <mp_init+0xb5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106112:	68 00 04 00 00       	push   $0x400
f0106117:	68 e4 69 10 f0       	push   $0xf01069e4
f010611c:	6a 6f                	push   $0x6f
f010611e:	68 01 86 10 f0       	push   $0xf0108601
f0106123:	e8 18 9f ff ff       	call   f0100040 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0106128:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f010612f:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0106132:	2d 00 04 00 00       	sub    $0x400,%eax
f0106137:	ba 00 04 00 00       	mov    $0x400,%edx
f010613c:	e8 6e fe ff ff       	call   f0105faf <mpsearch1>
f0106141:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106144:	85 c0                	test   %eax,%eax
f0106146:	0f 85 60 ff ff ff    	jne    f01060ac <mp_init+0x61>
f010614c:	e9 41 ff ff ff       	jmp    f0106092 <mp_init+0x47>
		cprintf("SMP: Default configurations not implemented\n");
f0106151:	83 ec 0c             	sub    $0xc,%esp
f0106154:	68 74 84 10 f0       	push   $0xf0108474
f0106159:	e8 9a d9 ff ff       	call   f0103af8 <cprintf>
		return NULL;
f010615e:	83 c4 10             	add    $0x10,%esp
f0106161:	e9 7b 01 00 00       	jmp    f01062e1 <mp_init+0x296>
f0106166:	53                   	push   %ebx
f0106167:	68 e4 69 10 f0       	push   $0xf01069e4
f010616c:	68 90 00 00 00       	push   $0x90
f0106171:	68 01 86 10 f0       	push   $0xf0108601
f0106176:	e8 c5 9e ff ff       	call   f0100040 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f010617b:	83 ec 0c             	sub    $0xc,%esp
f010617e:	68 a4 84 10 f0       	push   $0xf01084a4
f0106183:	e8 70 d9 ff ff       	call   f0103af8 <cprintf>
		return NULL;
f0106188:	83 c4 10             	add    $0x10,%esp
f010618b:	e9 51 01 00 00       	jmp    f01062e1 <mp_init+0x296>
	if (sum(conf, conf->length) != 0) {
f0106190:	84 d2                	test   %dl,%dl
f0106192:	75 22                	jne    f01061b6 <mp_init+0x16b>
	if (conf->version != 1 && conf->version != 4) {
f0106194:	0f b6 56 06          	movzbl 0x6(%esi),%edx
f0106198:	80 fa 01             	cmp    $0x1,%dl
f010619b:	74 05                	je     f01061a2 <mp_init+0x157>
f010619d:	80 fa 04             	cmp    $0x4,%dl
f01061a0:	75 29                	jne    f01061cb <mp_init+0x180>
f01061a2:	0f b7 4e 28          	movzwl 0x28(%esi),%ecx
f01061a6:	01 d9                	add    %ebx,%ecx
	for (i = 0; i < len; i++)
f01061a8:	39 d9                	cmp    %ebx,%ecx
f01061aa:	74 38                	je     f01061e4 <mp_init+0x199>
		sum += ((uint8_t *)addr)[i];
f01061ac:	0f b6 13             	movzbl (%ebx),%edx
f01061af:	01 d0                	add    %edx,%eax
f01061b1:	83 c3 01             	add    $0x1,%ebx
f01061b4:	eb f2                	jmp    f01061a8 <mp_init+0x15d>
		cprintf("SMP: Bad MP configuration checksum\n");
f01061b6:	83 ec 0c             	sub    $0xc,%esp
f01061b9:	68 d8 84 10 f0       	push   $0xf01084d8
f01061be:	e8 35 d9 ff ff       	call   f0103af8 <cprintf>
		return NULL;
f01061c3:	83 c4 10             	add    $0x10,%esp
f01061c6:	e9 16 01 00 00       	jmp    f01062e1 <mp_init+0x296>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01061cb:	83 ec 08             	sub    $0x8,%esp
f01061ce:	0f b6 d2             	movzbl %dl,%edx
f01061d1:	52                   	push   %edx
f01061d2:	68 fc 84 10 f0       	push   $0xf01084fc
f01061d7:	e8 1c d9 ff ff       	call   f0103af8 <cprintf>
		return NULL;
f01061dc:	83 c4 10             	add    $0x10,%esp
f01061df:	e9 fd 00 00 00       	jmp    f01062e1 <mp_init+0x296>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01061e4:	02 46 2a             	add    0x2a(%esi),%al
f01061e7:	75 1c                	jne    f0106205 <mp_init+0x1ba>
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
f01061e9:	c7 05 00 80 23 f0 01 	movl   $0x1,0xf0238000
f01061f0:	00 00 00 
	lapicaddr = conf->lapicaddr;
f01061f3:	8b 46 24             	mov    0x24(%esi),%eax
f01061f6:	a3 00 90 27 f0       	mov    %eax,0xf0279000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01061fb:	8d 7e 2c             	lea    0x2c(%esi),%edi
f01061fe:	bb 00 00 00 00       	mov    $0x0,%ebx
f0106203:	eb 4d                	jmp    f0106252 <mp_init+0x207>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0106205:	83 ec 0c             	sub    $0xc,%esp
f0106208:	68 1c 85 10 f0       	push   $0xf010851c
f010620d:	e8 e6 d8 ff ff       	call   f0103af8 <cprintf>
		return NULL;
f0106212:	83 c4 10             	add    $0x10,%esp
f0106215:	e9 c7 00 00 00       	jmp    f01062e1 <mp_init+0x296>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f010621a:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f010621e:	74 11                	je     f0106231 <mp_init+0x1e6>
				bootcpu = &cpus[ncpu];
f0106220:	6b 05 c4 83 23 f0 74 	imul   $0x74,0xf02383c4,%eax
f0106227:	05 20 80 23 f0       	add    $0xf0238020,%eax
f010622c:	a3 c0 83 23 f0       	mov    %eax,0xf02383c0
			if (ncpu < NCPU) {
f0106231:	a1 c4 83 23 f0       	mov    0xf02383c4,%eax
f0106236:	83 f8 07             	cmp    $0x7,%eax
f0106239:	7f 33                	jg     f010626e <mp_init+0x223>
				cpus[ncpu].cpu_id = ncpu;
f010623b:	6b d0 74             	imul   $0x74,%eax,%edx
f010623e:	88 82 20 80 23 f0    	mov    %al,-0xfdc7fe0(%edx)
				ncpu++;
f0106244:	83 c0 01             	add    $0x1,%eax
f0106247:	a3 c4 83 23 f0       	mov    %eax,0xf02383c4
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f010624c:	83 c7 14             	add    $0x14,%edi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010624f:	83 c3 01             	add    $0x1,%ebx
f0106252:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f0106256:	39 d8                	cmp    %ebx,%eax
f0106258:	76 4f                	jbe    f01062a9 <mp_init+0x25e>
		switch (*p) {
f010625a:	0f b6 07             	movzbl (%edi),%eax
f010625d:	84 c0                	test   %al,%al
f010625f:	74 b9                	je     f010621a <mp_init+0x1cf>
f0106261:	8d 50 ff             	lea    -0x1(%eax),%edx
f0106264:	80 fa 03             	cmp    $0x3,%dl
f0106267:	77 1c                	ja     f0106285 <mp_init+0x23a>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106269:	83 c7 08             	add    $0x8,%edi
			continue;
f010626c:	eb e1                	jmp    f010624f <mp_init+0x204>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f010626e:	83 ec 08             	sub    $0x8,%esp
f0106271:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0106275:	50                   	push   %eax
f0106276:	68 4c 85 10 f0       	push   $0xf010854c
f010627b:	e8 78 d8 ff ff       	call   f0103af8 <cprintf>
f0106280:	83 c4 10             	add    $0x10,%esp
f0106283:	eb c7                	jmp    f010624c <mp_init+0x201>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0106285:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f0106288:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f010628b:	50                   	push   %eax
f010628c:	68 74 85 10 f0       	push   $0xf0108574
f0106291:	e8 62 d8 ff ff       	call   f0103af8 <cprintf>
			ismp = 0;
f0106296:	c7 05 00 80 23 f0 00 	movl   $0x0,0xf0238000
f010629d:	00 00 00 
			i = conf->entry;
f01062a0:	0f b7 5e 22          	movzwl 0x22(%esi),%ebx
f01062a4:	83 c4 10             	add    $0x10,%esp
f01062a7:	eb a6                	jmp    f010624f <mp_init+0x204>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f01062a9:	a1 c0 83 23 f0       	mov    0xf02383c0,%eax
f01062ae:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f01062b5:	83 3d 00 80 23 f0 00 	cmpl   $0x0,0xf0238000
f01062bc:	74 2b                	je     f01062e9 <mp_init+0x29e>
		ncpu = 1;
		lapicaddr = 0;
		cprintf("SMP: configuration not found, SMP disabled\n");
		return;
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01062be:	83 ec 04             	sub    $0x4,%esp
f01062c1:	ff 35 c4 83 23 f0    	pushl  0xf02383c4
f01062c7:	0f b6 00             	movzbl (%eax),%eax
f01062ca:	50                   	push   %eax
f01062cb:	68 1b 86 10 f0       	push   $0xf010861b
f01062d0:	e8 23 d8 ff ff       	call   f0103af8 <cprintf>

	if (mp->imcrp) {
f01062d5:	83 c4 10             	add    $0x10,%esp
f01062d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01062db:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01062df:	75 2e                	jne    f010630f <mp_init+0x2c4>
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f01062e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01062e4:	5b                   	pop    %ebx
f01062e5:	5e                   	pop    %esi
f01062e6:	5f                   	pop    %edi
f01062e7:	5d                   	pop    %ebp
f01062e8:	c3                   	ret    
		ncpu = 1;
f01062e9:	c7 05 c4 83 23 f0 01 	movl   $0x1,0xf02383c4
f01062f0:	00 00 00 
		lapicaddr = 0;
f01062f3:	c7 05 00 90 27 f0 00 	movl   $0x0,0xf0279000
f01062fa:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f01062fd:	83 ec 0c             	sub    $0xc,%esp
f0106300:	68 94 85 10 f0       	push   $0xf0108594
f0106305:	e8 ee d7 ff ff       	call   f0103af8 <cprintf>
		return;
f010630a:	83 c4 10             	add    $0x10,%esp
f010630d:	eb d2                	jmp    f01062e1 <mp_init+0x296>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f010630f:	83 ec 0c             	sub    $0xc,%esp
f0106312:	68 c0 85 10 f0       	push   $0xf01085c0
f0106317:	e8 dc d7 ff ff       	call   f0103af8 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010631c:	b8 70 00 00 00       	mov    $0x70,%eax
f0106321:	ba 22 00 00 00       	mov    $0x22,%edx
f0106326:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0106327:	ba 23 00 00 00       	mov    $0x23,%edx
f010632c:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f010632d:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106330:	ee                   	out    %al,(%dx)
}
f0106331:	83 c4 10             	add    $0x10,%esp
f0106334:	eb ab                	jmp    f01062e1 <mp_init+0x296>

f0106336 <lapicw>:
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
	lapic[index] = value;
f0106336:	8b 0d 04 90 27 f0    	mov    0xf0279004,%ecx
f010633c:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f010633f:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106341:	a1 04 90 27 f0       	mov    0xf0279004,%eax
f0106346:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106349:	c3                   	ret    

f010634a <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f010634a:	f3 0f 1e fb          	endbr32 
	if (lapic)
f010634e:	8b 15 04 90 27 f0    	mov    0xf0279004,%edx
		return lapic[ID] >> 24;
	return 0;
f0106354:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lapic)
f0106359:	85 d2                	test   %edx,%edx
f010635b:	74 06                	je     f0106363 <cpunum+0x19>
		return lapic[ID] >> 24;
f010635d:	8b 42 20             	mov    0x20(%edx),%eax
f0106360:	c1 e8 18             	shr    $0x18,%eax
}
f0106363:	c3                   	ret    

f0106364 <lapic_init>:
{
f0106364:	f3 0f 1e fb          	endbr32 
	if (!lapicaddr)
f0106368:	a1 00 90 27 f0       	mov    0xf0279000,%eax
f010636d:	85 c0                	test   %eax,%eax
f010636f:	75 01                	jne    f0106372 <lapic_init+0xe>
f0106371:	c3                   	ret    
{
f0106372:	55                   	push   %ebp
f0106373:	89 e5                	mov    %esp,%ebp
f0106375:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f0106378:	68 00 10 00 00       	push   $0x1000
f010637d:	50                   	push   %eax
f010637e:	e8 8e af ff ff       	call   f0101311 <mmio_map_region>
f0106383:	a3 04 90 27 f0       	mov    %eax,0xf0279004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0106388:	ba 27 01 00 00       	mov    $0x127,%edx
f010638d:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106392:	e8 9f ff ff ff       	call   f0106336 <lapicw>
	lapicw(TDCR, X1);
f0106397:	ba 0b 00 00 00       	mov    $0xb,%edx
f010639c:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01063a1:	e8 90 ff ff ff       	call   f0106336 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01063a6:	ba 20 00 02 00       	mov    $0x20020,%edx
f01063ab:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01063b0:	e8 81 ff ff ff       	call   f0106336 <lapicw>
	lapicw(TICR, 10000000);
f01063b5:	ba 80 96 98 00       	mov    $0x989680,%edx
f01063ba:	b8 e0 00 00 00       	mov    $0xe0,%eax
f01063bf:	e8 72 ff ff ff       	call   f0106336 <lapicw>
	if (thiscpu != bootcpu)
f01063c4:	e8 81 ff ff ff       	call   f010634a <cpunum>
f01063c9:	6b c0 74             	imul   $0x74,%eax,%eax
f01063cc:	05 20 80 23 f0       	add    $0xf0238020,%eax
f01063d1:	83 c4 10             	add    $0x10,%esp
f01063d4:	39 05 c0 83 23 f0    	cmp    %eax,0xf02383c0
f01063da:	74 0f                	je     f01063eb <lapic_init+0x87>
		lapicw(LINT0, MASKED);
f01063dc:	ba 00 00 01 00       	mov    $0x10000,%edx
f01063e1:	b8 d4 00 00 00       	mov    $0xd4,%eax
f01063e6:	e8 4b ff ff ff       	call   f0106336 <lapicw>
	lapicw(LINT1, MASKED);
f01063eb:	ba 00 00 01 00       	mov    $0x10000,%edx
f01063f0:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01063f5:	e8 3c ff ff ff       	call   f0106336 <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01063fa:	a1 04 90 27 f0       	mov    0xf0279004,%eax
f01063ff:	8b 40 30             	mov    0x30(%eax),%eax
f0106402:	c1 e8 10             	shr    $0x10,%eax
f0106405:	a8 fc                	test   $0xfc,%al
f0106407:	75 7c                	jne    f0106485 <lapic_init+0x121>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0106409:	ba 33 00 00 00       	mov    $0x33,%edx
f010640e:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106413:	e8 1e ff ff ff       	call   f0106336 <lapicw>
	lapicw(ESR, 0);
f0106418:	ba 00 00 00 00       	mov    $0x0,%edx
f010641d:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106422:	e8 0f ff ff ff       	call   f0106336 <lapicw>
	lapicw(ESR, 0);
f0106427:	ba 00 00 00 00       	mov    $0x0,%edx
f010642c:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106431:	e8 00 ff ff ff       	call   f0106336 <lapicw>
	lapicw(EOI, 0);
f0106436:	ba 00 00 00 00       	mov    $0x0,%edx
f010643b:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106440:	e8 f1 fe ff ff       	call   f0106336 <lapicw>
	lapicw(ICRHI, 0);
f0106445:	ba 00 00 00 00       	mov    $0x0,%edx
f010644a:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010644f:	e8 e2 fe ff ff       	call   f0106336 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0106454:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106459:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010645e:	e8 d3 fe ff ff       	call   f0106336 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0106463:	8b 15 04 90 27 f0    	mov    0xf0279004,%edx
f0106469:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010646f:	f6 c4 10             	test   $0x10,%ah
f0106472:	75 f5                	jne    f0106469 <lapic_init+0x105>
	lapicw(TPR, 0);
f0106474:	ba 00 00 00 00       	mov    $0x0,%edx
f0106479:	b8 20 00 00 00       	mov    $0x20,%eax
f010647e:	e8 b3 fe ff ff       	call   f0106336 <lapicw>
}
f0106483:	c9                   	leave  
f0106484:	c3                   	ret    
		lapicw(PCINT, MASKED);
f0106485:	ba 00 00 01 00       	mov    $0x10000,%edx
f010648a:	b8 d0 00 00 00       	mov    $0xd0,%eax
f010648f:	e8 a2 fe ff ff       	call   f0106336 <lapicw>
f0106494:	e9 70 ff ff ff       	jmp    f0106409 <lapic_init+0xa5>

f0106499 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0106499:	f3 0f 1e fb          	endbr32 
	if (lapic)
f010649d:	83 3d 04 90 27 f0 00 	cmpl   $0x0,0xf0279004
f01064a4:	74 17                	je     f01064bd <lapic_eoi+0x24>
{
f01064a6:	55                   	push   %ebp
f01064a7:	89 e5                	mov    %esp,%ebp
f01064a9:	83 ec 08             	sub    $0x8,%esp
		lapicw(EOI, 0);
f01064ac:	ba 00 00 00 00       	mov    $0x0,%edx
f01064b1:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01064b6:	e8 7b fe ff ff       	call   f0106336 <lapicw>
}
f01064bb:	c9                   	leave  
f01064bc:	c3                   	ret    
f01064bd:	c3                   	ret    

f01064be <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01064be:	f3 0f 1e fb          	endbr32 
f01064c2:	55                   	push   %ebp
f01064c3:	89 e5                	mov    %esp,%ebp
f01064c5:	56                   	push   %esi
f01064c6:	53                   	push   %ebx
f01064c7:	8b 75 08             	mov    0x8(%ebp),%esi
f01064ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01064cd:	b8 0f 00 00 00       	mov    $0xf,%eax
f01064d2:	ba 70 00 00 00       	mov    $0x70,%edx
f01064d7:	ee                   	out    %al,(%dx)
f01064d8:	b8 0a 00 00 00       	mov    $0xa,%eax
f01064dd:	ba 71 00 00 00       	mov    $0x71,%edx
f01064e2:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f01064e3:	83 3d 88 7e 23 f0 00 	cmpl   $0x0,0xf0237e88
f01064ea:	74 7e                	je     f010656a <lapic_startap+0xac>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01064ec:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01064f3:	00 00 
	wrv[1] = addr >> 4;
f01064f5:	89 d8                	mov    %ebx,%eax
f01064f7:	c1 e8 04             	shr    $0x4,%eax
f01064fa:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106500:	c1 e6 18             	shl    $0x18,%esi
f0106503:	89 f2                	mov    %esi,%edx
f0106505:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010650a:	e8 27 fe ff ff       	call   f0106336 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f010650f:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106514:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106519:	e8 18 fe ff ff       	call   f0106336 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f010651e:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106523:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106528:	e8 09 fe ff ff       	call   f0106336 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010652d:	c1 eb 0c             	shr    $0xc,%ebx
f0106530:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f0106533:	89 f2                	mov    %esi,%edx
f0106535:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010653a:	e8 f7 fd ff ff       	call   f0106336 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010653f:	89 da                	mov    %ebx,%edx
f0106541:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106546:	e8 eb fd ff ff       	call   f0106336 <lapicw>
		lapicw(ICRHI, apicid << 24);
f010654b:	89 f2                	mov    %esi,%edx
f010654d:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106552:	e8 df fd ff ff       	call   f0106336 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106557:	89 da                	mov    %ebx,%edx
f0106559:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010655e:	e8 d3 fd ff ff       	call   f0106336 <lapicw>
		microdelay(200);
	}
}
f0106563:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106566:	5b                   	pop    %ebx
f0106567:	5e                   	pop    %esi
f0106568:	5d                   	pop    %ebp
f0106569:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010656a:	68 67 04 00 00       	push   $0x467
f010656f:	68 e4 69 10 f0       	push   $0xf01069e4
f0106574:	68 98 00 00 00       	push   $0x98
f0106579:	68 38 86 10 f0       	push   $0xf0108638
f010657e:	e8 bd 9a ff ff       	call   f0100040 <_panic>

f0106583 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106583:	f3 0f 1e fb          	endbr32 
f0106587:	55                   	push   %ebp
f0106588:	89 e5                	mov    %esp,%ebp
f010658a:	83 ec 08             	sub    $0x8,%esp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f010658d:	8b 55 08             	mov    0x8(%ebp),%edx
f0106590:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106596:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010659b:	e8 96 fd ff ff       	call   f0106336 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01065a0:	8b 15 04 90 27 f0    	mov    0xf0279004,%edx
f01065a6:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01065ac:	f6 c4 10             	test   $0x10,%ah
f01065af:	75 f5                	jne    f01065a6 <lapic_ipi+0x23>
		;
}
f01065b1:	c9                   	leave  
f01065b2:	c3                   	ret    

f01065b3 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01065b3:	f3 0f 1e fb          	endbr32 
f01065b7:	55                   	push   %ebp
f01065b8:	89 e5                	mov    %esp,%ebp
f01065ba:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01065bd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01065c3:	8b 55 0c             	mov    0xc(%ebp),%edx
f01065c6:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01065c9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01065d0:	5d                   	pop    %ebp
f01065d1:	c3                   	ret    

f01065d2 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01065d2:	f3 0f 1e fb          	endbr32 
f01065d6:	55                   	push   %ebp
f01065d7:	89 e5                	mov    %esp,%ebp
f01065d9:	56                   	push   %esi
f01065da:	53                   	push   %ebx
f01065db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f01065de:	83 3b 00             	cmpl   $0x0,(%ebx)
f01065e1:	75 07                	jne    f01065ea <spin_lock+0x18>
	asm volatile("lock; xchgl %0, %1"
f01065e3:	ba 01 00 00 00       	mov    $0x1,%edx
f01065e8:	eb 34                	jmp    f010661e <spin_lock+0x4c>
f01065ea:	8b 73 08             	mov    0x8(%ebx),%esi
f01065ed:	e8 58 fd ff ff       	call   f010634a <cpunum>
f01065f2:	6b c0 74             	imul   $0x74,%eax,%eax
f01065f5:	05 20 80 23 f0       	add    $0xf0238020,%eax
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01065fa:	39 c6                	cmp    %eax,%esi
f01065fc:	75 e5                	jne    f01065e3 <spin_lock+0x11>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01065fe:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106601:	e8 44 fd ff ff       	call   f010634a <cpunum>
f0106606:	83 ec 0c             	sub    $0xc,%esp
f0106609:	53                   	push   %ebx
f010660a:	50                   	push   %eax
f010660b:	68 48 86 10 f0       	push   $0xf0108648
f0106610:	6a 41                	push   $0x41
f0106612:	68 aa 86 10 f0       	push   $0xf01086aa
f0106617:	e8 24 9a ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it.
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f010661c:	f3 90                	pause  
f010661e:	89 d0                	mov    %edx,%eax
f0106620:	f0 87 03             	lock xchg %eax,(%ebx)
	while (xchg(&lk->locked, 1) != 0)
f0106623:	85 c0                	test   %eax,%eax
f0106625:	75 f5                	jne    f010661c <spin_lock+0x4a>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106627:	e8 1e fd ff ff       	call   f010634a <cpunum>
f010662c:	6b c0 74             	imul   $0x74,%eax,%eax
f010662f:	05 20 80 23 f0       	add    $0xf0238020,%eax
f0106634:	89 43 08             	mov    %eax,0x8(%ebx)
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0106637:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f0106639:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f010663e:	83 f8 09             	cmp    $0x9,%eax
f0106641:	7f 21                	jg     f0106664 <spin_lock+0x92>
f0106643:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106649:	76 19                	jbe    f0106664 <spin_lock+0x92>
		pcs[i] = ebp[1];          // saved %eip
f010664b:	8b 4a 04             	mov    0x4(%edx),%ecx
f010664e:	89 4c 83 0c          	mov    %ecx,0xc(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106652:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f0106654:	83 c0 01             	add    $0x1,%eax
f0106657:	eb e5                	jmp    f010663e <spin_lock+0x6c>
		pcs[i] = 0;
f0106659:	c7 44 83 0c 00 00 00 	movl   $0x0,0xc(%ebx,%eax,4)
f0106660:	00 
	for (; i < 10; i++)
f0106661:	83 c0 01             	add    $0x1,%eax
f0106664:	83 f8 09             	cmp    $0x9,%eax
f0106667:	7e f0                	jle    f0106659 <spin_lock+0x87>
	get_caller_pcs(lk->pcs);
#endif
}
f0106669:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010666c:	5b                   	pop    %ebx
f010666d:	5e                   	pop    %esi
f010666e:	5d                   	pop    %ebp
f010666f:	c3                   	ret    

f0106670 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106670:	f3 0f 1e fb          	endbr32 
f0106674:	55                   	push   %ebp
f0106675:	89 e5                	mov    %esp,%ebp
f0106677:	57                   	push   %edi
f0106678:	56                   	push   %esi
f0106679:	53                   	push   %ebx
f010667a:	83 ec 4c             	sub    $0x4c,%esp
f010667d:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f0106680:	83 3e 00             	cmpl   $0x0,(%esi)
f0106683:	75 35                	jne    f01066ba <spin_unlock+0x4a>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106685:	83 ec 04             	sub    $0x4,%esp
f0106688:	6a 28                	push   $0x28
f010668a:	8d 46 0c             	lea    0xc(%esi),%eax
f010668d:	50                   	push   %eax
f010668e:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106691:	53                   	push   %ebx
f0106692:	e8 e1 f6 ff ff       	call   f0105d78 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:",
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106697:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:",
f010669a:	0f b6 38             	movzbl (%eax),%edi
f010669d:	8b 76 04             	mov    0x4(%esi),%esi
f01066a0:	e8 a5 fc ff ff       	call   f010634a <cpunum>
f01066a5:	57                   	push   %edi
f01066a6:	56                   	push   %esi
f01066a7:	50                   	push   %eax
f01066a8:	68 74 86 10 f0       	push   $0xf0108674
f01066ad:	e8 46 d4 ff ff       	call   f0103af8 <cprintf>
f01066b2:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01066b5:	8d 7d a8             	lea    -0x58(%ebp),%edi
f01066b8:	eb 4e                	jmp    f0106708 <spin_unlock+0x98>
	return lock->locked && lock->cpu == thiscpu;
f01066ba:	8b 5e 08             	mov    0x8(%esi),%ebx
f01066bd:	e8 88 fc ff ff       	call   f010634a <cpunum>
f01066c2:	6b c0 74             	imul   $0x74,%eax,%eax
f01066c5:	05 20 80 23 f0       	add    $0xf0238020,%eax
	if (!holding(lk)) {
f01066ca:	39 c3                	cmp    %eax,%ebx
f01066cc:	75 b7                	jne    f0106685 <spin_unlock+0x15>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f01066ce:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f01066d5:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f01066dc:	b8 00 00 00 00       	mov    $0x0,%eax
f01066e1:	f0 87 06             	lock xchg %eax,(%esi)
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
    //lk->locked = 0;
}
f01066e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01066e7:	5b                   	pop    %ebx
f01066e8:	5e                   	pop    %esi
f01066e9:	5f                   	pop    %edi
f01066ea:	5d                   	pop    %ebp
f01066eb:	c3                   	ret    
				cprintf("  %08x\n", pcs[i]);
f01066ec:	83 ec 08             	sub    $0x8,%esp
f01066ef:	ff 36                	pushl  (%esi)
f01066f1:	68 d1 86 10 f0       	push   $0xf01086d1
f01066f6:	e8 fd d3 ff ff       	call   f0103af8 <cprintf>
f01066fb:	83 c4 10             	add    $0x10,%esp
f01066fe:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106701:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106704:	39 c3                	cmp    %eax,%ebx
f0106706:	74 40                	je     f0106748 <spin_unlock+0xd8>
f0106708:	89 de                	mov    %ebx,%esi
f010670a:	8b 03                	mov    (%ebx),%eax
f010670c:	85 c0                	test   %eax,%eax
f010670e:	74 38                	je     f0106748 <spin_unlock+0xd8>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106710:	83 ec 08             	sub    $0x8,%esp
f0106713:	57                   	push   %edi
f0106714:	50                   	push   %eax
f0106715:	e8 e0 ea ff ff       	call   f01051fa <debuginfo_eip>
f010671a:	83 c4 10             	add    $0x10,%esp
f010671d:	85 c0                	test   %eax,%eax
f010671f:	78 cb                	js     f01066ec <spin_unlock+0x7c>
					pcs[i] - info.eip_fn_addr);
f0106721:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106723:	83 ec 04             	sub    $0x4,%esp
f0106726:	89 c2                	mov    %eax,%edx
f0106728:	2b 55 b8             	sub    -0x48(%ebp),%edx
f010672b:	52                   	push   %edx
f010672c:	ff 75 b0             	pushl  -0x50(%ebp)
f010672f:	ff 75 b4             	pushl  -0x4c(%ebp)
f0106732:	ff 75 ac             	pushl  -0x54(%ebp)
f0106735:	ff 75 a8             	pushl  -0x58(%ebp)
f0106738:	50                   	push   %eax
f0106739:	68 ba 86 10 f0       	push   $0xf01086ba
f010673e:	e8 b5 d3 ff ff       	call   f0103af8 <cprintf>
f0106743:	83 c4 20             	add    $0x20,%esp
f0106746:	eb b6                	jmp    f01066fe <spin_unlock+0x8e>
		panic("spin_unlock");
f0106748:	83 ec 04             	sub    $0x4,%esp
f010674b:	68 d9 86 10 f0       	push   $0xf01086d9
f0106750:	6a 67                	push   $0x67
f0106752:	68 aa 86 10 f0       	push   $0xf01086aa
f0106757:	e8 e4 98 ff ff       	call   f0100040 <_panic>
f010675c:	66 90                	xchg   %ax,%ax
f010675e:	66 90                	xchg   %ax,%ax

f0106760 <__udivdi3>:
f0106760:	f3 0f 1e fb          	endbr32 
f0106764:	55                   	push   %ebp
f0106765:	57                   	push   %edi
f0106766:	56                   	push   %esi
f0106767:	53                   	push   %ebx
f0106768:	83 ec 1c             	sub    $0x1c,%esp
f010676b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010676f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0106773:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106777:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f010677b:	85 d2                	test   %edx,%edx
f010677d:	75 19                	jne    f0106798 <__udivdi3+0x38>
f010677f:	39 f3                	cmp    %esi,%ebx
f0106781:	76 4d                	jbe    f01067d0 <__udivdi3+0x70>
f0106783:	31 ff                	xor    %edi,%edi
f0106785:	89 e8                	mov    %ebp,%eax
f0106787:	89 f2                	mov    %esi,%edx
f0106789:	f7 f3                	div    %ebx
f010678b:	89 fa                	mov    %edi,%edx
f010678d:	83 c4 1c             	add    $0x1c,%esp
f0106790:	5b                   	pop    %ebx
f0106791:	5e                   	pop    %esi
f0106792:	5f                   	pop    %edi
f0106793:	5d                   	pop    %ebp
f0106794:	c3                   	ret    
f0106795:	8d 76 00             	lea    0x0(%esi),%esi
f0106798:	39 f2                	cmp    %esi,%edx
f010679a:	76 14                	jbe    f01067b0 <__udivdi3+0x50>
f010679c:	31 ff                	xor    %edi,%edi
f010679e:	31 c0                	xor    %eax,%eax
f01067a0:	89 fa                	mov    %edi,%edx
f01067a2:	83 c4 1c             	add    $0x1c,%esp
f01067a5:	5b                   	pop    %ebx
f01067a6:	5e                   	pop    %esi
f01067a7:	5f                   	pop    %edi
f01067a8:	5d                   	pop    %ebp
f01067a9:	c3                   	ret    
f01067aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01067b0:	0f bd fa             	bsr    %edx,%edi
f01067b3:	83 f7 1f             	xor    $0x1f,%edi
f01067b6:	75 48                	jne    f0106800 <__udivdi3+0xa0>
f01067b8:	39 f2                	cmp    %esi,%edx
f01067ba:	72 06                	jb     f01067c2 <__udivdi3+0x62>
f01067bc:	31 c0                	xor    %eax,%eax
f01067be:	39 eb                	cmp    %ebp,%ebx
f01067c0:	77 de                	ja     f01067a0 <__udivdi3+0x40>
f01067c2:	b8 01 00 00 00       	mov    $0x1,%eax
f01067c7:	eb d7                	jmp    f01067a0 <__udivdi3+0x40>
f01067c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01067d0:	89 d9                	mov    %ebx,%ecx
f01067d2:	85 db                	test   %ebx,%ebx
f01067d4:	75 0b                	jne    f01067e1 <__udivdi3+0x81>
f01067d6:	b8 01 00 00 00       	mov    $0x1,%eax
f01067db:	31 d2                	xor    %edx,%edx
f01067dd:	f7 f3                	div    %ebx
f01067df:	89 c1                	mov    %eax,%ecx
f01067e1:	31 d2                	xor    %edx,%edx
f01067e3:	89 f0                	mov    %esi,%eax
f01067e5:	f7 f1                	div    %ecx
f01067e7:	89 c6                	mov    %eax,%esi
f01067e9:	89 e8                	mov    %ebp,%eax
f01067eb:	89 f7                	mov    %esi,%edi
f01067ed:	f7 f1                	div    %ecx
f01067ef:	89 fa                	mov    %edi,%edx
f01067f1:	83 c4 1c             	add    $0x1c,%esp
f01067f4:	5b                   	pop    %ebx
f01067f5:	5e                   	pop    %esi
f01067f6:	5f                   	pop    %edi
f01067f7:	5d                   	pop    %ebp
f01067f8:	c3                   	ret    
f01067f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106800:	89 f9                	mov    %edi,%ecx
f0106802:	b8 20 00 00 00       	mov    $0x20,%eax
f0106807:	29 f8                	sub    %edi,%eax
f0106809:	d3 e2                	shl    %cl,%edx
f010680b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010680f:	89 c1                	mov    %eax,%ecx
f0106811:	89 da                	mov    %ebx,%edx
f0106813:	d3 ea                	shr    %cl,%edx
f0106815:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0106819:	09 d1                	or     %edx,%ecx
f010681b:	89 f2                	mov    %esi,%edx
f010681d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106821:	89 f9                	mov    %edi,%ecx
f0106823:	d3 e3                	shl    %cl,%ebx
f0106825:	89 c1                	mov    %eax,%ecx
f0106827:	d3 ea                	shr    %cl,%edx
f0106829:	89 f9                	mov    %edi,%ecx
f010682b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010682f:	89 eb                	mov    %ebp,%ebx
f0106831:	d3 e6                	shl    %cl,%esi
f0106833:	89 c1                	mov    %eax,%ecx
f0106835:	d3 eb                	shr    %cl,%ebx
f0106837:	09 de                	or     %ebx,%esi
f0106839:	89 f0                	mov    %esi,%eax
f010683b:	f7 74 24 08          	divl   0x8(%esp)
f010683f:	89 d6                	mov    %edx,%esi
f0106841:	89 c3                	mov    %eax,%ebx
f0106843:	f7 64 24 0c          	mull   0xc(%esp)
f0106847:	39 d6                	cmp    %edx,%esi
f0106849:	72 15                	jb     f0106860 <__udivdi3+0x100>
f010684b:	89 f9                	mov    %edi,%ecx
f010684d:	d3 e5                	shl    %cl,%ebp
f010684f:	39 c5                	cmp    %eax,%ebp
f0106851:	73 04                	jae    f0106857 <__udivdi3+0xf7>
f0106853:	39 d6                	cmp    %edx,%esi
f0106855:	74 09                	je     f0106860 <__udivdi3+0x100>
f0106857:	89 d8                	mov    %ebx,%eax
f0106859:	31 ff                	xor    %edi,%edi
f010685b:	e9 40 ff ff ff       	jmp    f01067a0 <__udivdi3+0x40>
f0106860:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0106863:	31 ff                	xor    %edi,%edi
f0106865:	e9 36 ff ff ff       	jmp    f01067a0 <__udivdi3+0x40>
f010686a:	66 90                	xchg   %ax,%ax
f010686c:	66 90                	xchg   %ax,%ax
f010686e:	66 90                	xchg   %ax,%ax

f0106870 <__umoddi3>:
f0106870:	f3 0f 1e fb          	endbr32 
f0106874:	55                   	push   %ebp
f0106875:	57                   	push   %edi
f0106876:	56                   	push   %esi
f0106877:	53                   	push   %ebx
f0106878:	83 ec 1c             	sub    $0x1c,%esp
f010687b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010687f:	8b 74 24 30          	mov    0x30(%esp),%esi
f0106883:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0106887:	8b 7c 24 38          	mov    0x38(%esp),%edi
f010688b:	85 c0                	test   %eax,%eax
f010688d:	75 19                	jne    f01068a8 <__umoddi3+0x38>
f010688f:	39 df                	cmp    %ebx,%edi
f0106891:	76 5d                	jbe    f01068f0 <__umoddi3+0x80>
f0106893:	89 f0                	mov    %esi,%eax
f0106895:	89 da                	mov    %ebx,%edx
f0106897:	f7 f7                	div    %edi
f0106899:	89 d0                	mov    %edx,%eax
f010689b:	31 d2                	xor    %edx,%edx
f010689d:	83 c4 1c             	add    $0x1c,%esp
f01068a0:	5b                   	pop    %ebx
f01068a1:	5e                   	pop    %esi
f01068a2:	5f                   	pop    %edi
f01068a3:	5d                   	pop    %ebp
f01068a4:	c3                   	ret    
f01068a5:	8d 76 00             	lea    0x0(%esi),%esi
f01068a8:	89 f2                	mov    %esi,%edx
f01068aa:	39 d8                	cmp    %ebx,%eax
f01068ac:	76 12                	jbe    f01068c0 <__umoddi3+0x50>
f01068ae:	89 f0                	mov    %esi,%eax
f01068b0:	89 da                	mov    %ebx,%edx
f01068b2:	83 c4 1c             	add    $0x1c,%esp
f01068b5:	5b                   	pop    %ebx
f01068b6:	5e                   	pop    %esi
f01068b7:	5f                   	pop    %edi
f01068b8:	5d                   	pop    %ebp
f01068b9:	c3                   	ret    
f01068ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01068c0:	0f bd e8             	bsr    %eax,%ebp
f01068c3:	83 f5 1f             	xor    $0x1f,%ebp
f01068c6:	75 50                	jne    f0106918 <__umoddi3+0xa8>
f01068c8:	39 d8                	cmp    %ebx,%eax
f01068ca:	0f 82 e0 00 00 00    	jb     f01069b0 <__umoddi3+0x140>
f01068d0:	89 d9                	mov    %ebx,%ecx
f01068d2:	39 f7                	cmp    %esi,%edi
f01068d4:	0f 86 d6 00 00 00    	jbe    f01069b0 <__umoddi3+0x140>
f01068da:	89 d0                	mov    %edx,%eax
f01068dc:	89 ca                	mov    %ecx,%edx
f01068de:	83 c4 1c             	add    $0x1c,%esp
f01068e1:	5b                   	pop    %ebx
f01068e2:	5e                   	pop    %esi
f01068e3:	5f                   	pop    %edi
f01068e4:	5d                   	pop    %ebp
f01068e5:	c3                   	ret    
f01068e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01068ed:	8d 76 00             	lea    0x0(%esi),%esi
f01068f0:	89 fd                	mov    %edi,%ebp
f01068f2:	85 ff                	test   %edi,%edi
f01068f4:	75 0b                	jne    f0106901 <__umoddi3+0x91>
f01068f6:	b8 01 00 00 00       	mov    $0x1,%eax
f01068fb:	31 d2                	xor    %edx,%edx
f01068fd:	f7 f7                	div    %edi
f01068ff:	89 c5                	mov    %eax,%ebp
f0106901:	89 d8                	mov    %ebx,%eax
f0106903:	31 d2                	xor    %edx,%edx
f0106905:	f7 f5                	div    %ebp
f0106907:	89 f0                	mov    %esi,%eax
f0106909:	f7 f5                	div    %ebp
f010690b:	89 d0                	mov    %edx,%eax
f010690d:	31 d2                	xor    %edx,%edx
f010690f:	eb 8c                	jmp    f010689d <__umoddi3+0x2d>
f0106911:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106918:	89 e9                	mov    %ebp,%ecx
f010691a:	ba 20 00 00 00       	mov    $0x20,%edx
f010691f:	29 ea                	sub    %ebp,%edx
f0106921:	d3 e0                	shl    %cl,%eax
f0106923:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106927:	89 d1                	mov    %edx,%ecx
f0106929:	89 f8                	mov    %edi,%eax
f010692b:	d3 e8                	shr    %cl,%eax
f010692d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0106931:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106935:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106939:	09 c1                	or     %eax,%ecx
f010693b:	89 d8                	mov    %ebx,%eax
f010693d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106941:	89 e9                	mov    %ebp,%ecx
f0106943:	d3 e7                	shl    %cl,%edi
f0106945:	89 d1                	mov    %edx,%ecx
f0106947:	d3 e8                	shr    %cl,%eax
f0106949:	89 e9                	mov    %ebp,%ecx
f010694b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010694f:	d3 e3                	shl    %cl,%ebx
f0106951:	89 c7                	mov    %eax,%edi
f0106953:	89 d1                	mov    %edx,%ecx
f0106955:	89 f0                	mov    %esi,%eax
f0106957:	d3 e8                	shr    %cl,%eax
f0106959:	89 e9                	mov    %ebp,%ecx
f010695b:	89 fa                	mov    %edi,%edx
f010695d:	d3 e6                	shl    %cl,%esi
f010695f:	09 d8                	or     %ebx,%eax
f0106961:	f7 74 24 08          	divl   0x8(%esp)
f0106965:	89 d1                	mov    %edx,%ecx
f0106967:	89 f3                	mov    %esi,%ebx
f0106969:	f7 64 24 0c          	mull   0xc(%esp)
f010696d:	89 c6                	mov    %eax,%esi
f010696f:	89 d7                	mov    %edx,%edi
f0106971:	39 d1                	cmp    %edx,%ecx
f0106973:	72 06                	jb     f010697b <__umoddi3+0x10b>
f0106975:	75 10                	jne    f0106987 <__umoddi3+0x117>
f0106977:	39 c3                	cmp    %eax,%ebx
f0106979:	73 0c                	jae    f0106987 <__umoddi3+0x117>
f010697b:	2b 44 24 0c          	sub    0xc(%esp),%eax
f010697f:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0106983:	89 d7                	mov    %edx,%edi
f0106985:	89 c6                	mov    %eax,%esi
f0106987:	89 ca                	mov    %ecx,%edx
f0106989:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010698e:	29 f3                	sub    %esi,%ebx
f0106990:	19 fa                	sbb    %edi,%edx
f0106992:	89 d0                	mov    %edx,%eax
f0106994:	d3 e0                	shl    %cl,%eax
f0106996:	89 e9                	mov    %ebp,%ecx
f0106998:	d3 eb                	shr    %cl,%ebx
f010699a:	d3 ea                	shr    %cl,%edx
f010699c:	09 d8                	or     %ebx,%eax
f010699e:	83 c4 1c             	add    $0x1c,%esp
f01069a1:	5b                   	pop    %ebx
f01069a2:	5e                   	pop    %esi
f01069a3:	5f                   	pop    %edi
f01069a4:	5d                   	pop    %ebp
f01069a5:	c3                   	ret    
f01069a6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01069ad:	8d 76 00             	lea    0x0(%esi),%esi
f01069b0:	29 fe                	sub    %edi,%esi
f01069b2:	19 c3                	sbb    %eax,%ebx
f01069b4:	89 f2                	mov    %esi,%edx
f01069b6:	89 d9                	mov    %ebx,%ecx
f01069b8:	e9 1d ff ff ff       	jmp    f01068da <__umoddi3+0x6a>
