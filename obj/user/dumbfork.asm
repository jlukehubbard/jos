
obj/user/dumbfork:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 ad 01 00 00       	call   8001de <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	56                   	push   %esi
  80003b:	53                   	push   %ebx
  80003c:	8b 75 08             	mov    0x8(%ebp),%esi
  80003f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	6a 07                	push   $0x7
  800047:	53                   	push   %ebx
  800048:	56                   	push   %esi
  800049:	e8 34 0d 00 00       	call   800d82 <sys_page_alloc>
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	85 c0                	test   %eax,%eax
  800053:	78 4a                	js     80009f <duppage+0x6c>
		panic("sys_page_alloc: %e", r);
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800055:	83 ec 0c             	sub    $0xc,%esp
  800058:	6a 07                	push   $0x7
  80005a:	68 00 00 40 00       	push   $0x400000
  80005f:	6a 00                	push   $0x0
  800061:	53                   	push   %ebx
  800062:	56                   	push   %esi
  800063:	e8 61 0d 00 00       	call   800dc9 <sys_page_map>
  800068:	83 c4 20             	add    $0x20,%esp
  80006b:	85 c0                	test   %eax,%eax
  80006d:	78 42                	js     8000b1 <duppage+0x7e>
		panic("sys_page_map: %e", r);
	memmove(UTEMP, addr, PGSIZE);
  80006f:	83 ec 04             	sub    $0x4,%esp
  800072:	68 00 10 00 00       	push   $0x1000
  800077:	53                   	push   %ebx
  800078:	68 00 00 40 00       	push   $0x400000
  80007d:	e8 74 0a 00 00       	call   800af6 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800082:	83 c4 08             	add    $0x8,%esp
  800085:	68 00 00 40 00       	push   $0x400000
  80008a:	6a 00                	push   $0x0
  80008c:	e8 7e 0d 00 00       	call   800e0f <sys_page_unmap>
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	85 c0                	test   %eax,%eax
  800096:	78 2b                	js     8000c3 <duppage+0x90>
		panic("sys_page_unmap: %e", r);
}
  800098:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80009b:	5b                   	pop    %ebx
  80009c:	5e                   	pop    %esi
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  80009f:	50                   	push   %eax
  8000a0:	68 80 20 80 00       	push   $0x802080
  8000a5:	6a 20                	push   $0x20
  8000a7:	68 93 20 80 00       	push   $0x802093
  8000ac:	e8 9f 01 00 00       	call   800250 <_panic>
		panic("sys_page_map: %e", r);
  8000b1:	50                   	push   %eax
  8000b2:	68 a3 20 80 00       	push   $0x8020a3
  8000b7:	6a 22                	push   $0x22
  8000b9:	68 93 20 80 00       	push   $0x802093
  8000be:	e8 8d 01 00 00       	call   800250 <_panic>
		panic("sys_page_unmap: %e", r);
  8000c3:	50                   	push   %eax
  8000c4:	68 b4 20 80 00       	push   $0x8020b4
  8000c9:	6a 25                	push   $0x25
  8000cb:	68 93 20 80 00       	push   $0x802093
  8000d0:	e8 7b 01 00 00       	call   800250 <_panic>

008000d5 <dumbfork>:

envid_t
dumbfork(void)
{
  8000d5:	f3 0f 1e fb          	endbr32 
  8000d9:	55                   	push   %ebp
  8000da:	89 e5                	mov    %esp,%ebp
  8000dc:	56                   	push   %esi
  8000dd:	53                   	push   %ebx
  8000de:	83 ec 10             	sub    $0x10,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8000e1:	b8 07 00 00 00       	mov    $0x7,%eax
  8000e6:	cd 30                	int    $0x30
  8000e8:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  8000ea:	85 c0                	test   %eax,%eax
  8000ec:	78 0d                	js     8000fb <dumbfork+0x26>
  8000ee:	89 c6                	mov    %eax,%esi
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  8000f0:	74 1b                	je     80010d <dumbfork+0x38>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  8000f2:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  8000f9:	eb 3f                	jmp    80013a <dumbfork+0x65>
		panic("sys_exofork: %e", envid);
  8000fb:	50                   	push   %eax
  8000fc:	68 c7 20 80 00       	push   $0x8020c7
  800101:	6a 37                	push   $0x37
  800103:	68 93 20 80 00       	push   $0x802093
  800108:	e8 43 01 00 00       	call   800250 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
  80010d:	e8 2a 0c 00 00       	call   800d3c <sys_getenvid>
  800112:	25 ff 03 00 00       	and    $0x3ff,%eax
  800117:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80011a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011f:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800124:	eb 43                	jmp    800169 <dumbfork+0x94>
		duppage(envid, addr);
  800126:	83 ec 08             	sub    $0x8,%esp
  800129:	52                   	push   %edx
  80012a:	56                   	push   %esi
  80012b:	e8 03 ff ff ff       	call   800033 <duppage>
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800130:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800137:	83 c4 10             	add    $0x10,%esp
  80013a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80013d:	81 fa 00 60 80 00    	cmp    $0x806000,%edx
  800143:	72 e1                	jb     800126 <dumbfork+0x51>

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800145:	83 ec 08             	sub    $0x8,%esp
  800148:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80014b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800150:	50                   	push   %eax
  800151:	53                   	push   %ebx
  800152:	e8 dc fe ff ff       	call   800033 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800157:	83 c4 08             	add    $0x8,%esp
  80015a:	6a 02                	push   $0x2
  80015c:	53                   	push   %ebx
  80015d:	e8 f3 0c 00 00       	call   800e55 <sys_env_set_status>
  800162:	83 c4 10             	add    $0x10,%esp
  800165:	85 c0                	test   %eax,%eax
  800167:	78 09                	js     800172 <dumbfork+0x9d>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  800169:	89 d8                	mov    %ebx,%eax
  80016b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80016e:	5b                   	pop    %ebx
  80016f:	5e                   	pop    %esi
  800170:	5d                   	pop    %ebp
  800171:	c3                   	ret    
		panic("sys_env_set_status: %e", r);
  800172:	50                   	push   %eax
  800173:	68 d7 20 80 00       	push   $0x8020d7
  800178:	6a 4c                	push   $0x4c
  80017a:	68 93 20 80 00       	push   $0x802093
  80017f:	e8 cc 00 00 00       	call   800250 <_panic>

00800184 <umain>:
{
  800184:	f3 0f 1e fb          	endbr32 
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	57                   	push   %edi
  80018c:	56                   	push   %esi
  80018d:	53                   	push   %ebx
  80018e:	83 ec 0c             	sub    $0xc,%esp
	who = dumbfork();
  800191:	e8 3f ff ff ff       	call   8000d5 <dumbfork>
  800196:	89 c6                	mov    %eax,%esi
  800198:	85 c0                	test   %eax,%eax
  80019a:	bf ee 20 80 00       	mov    $0x8020ee,%edi
  80019f:	b8 f5 20 80 00       	mov    $0x8020f5,%eax
  8001a4:	0f 44 f8             	cmove  %eax,%edi
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001a7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ac:	eb 1f                	jmp    8001cd <umain+0x49>
  8001ae:	83 fb 13             	cmp    $0x13,%ebx
  8001b1:	7f 23                	jg     8001d6 <umain+0x52>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001b3:	83 ec 04             	sub    $0x4,%esp
  8001b6:	57                   	push   %edi
  8001b7:	53                   	push   %ebx
  8001b8:	68 fb 20 80 00       	push   $0x8020fb
  8001bd:	e8 75 01 00 00       	call   800337 <cprintf>
		sys_yield();
  8001c2:	e8 98 0b 00 00       	call   800d5f <sys_yield>
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001c7:	83 c3 01             	add    $0x1,%ebx
  8001ca:	83 c4 10             	add    $0x10,%esp
  8001cd:	85 f6                	test   %esi,%esi
  8001cf:	74 dd                	je     8001ae <umain+0x2a>
  8001d1:	83 fb 09             	cmp    $0x9,%ebx
  8001d4:	7e dd                	jle    8001b3 <umain+0x2f>
}
  8001d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d9:	5b                   	pop    %ebx
  8001da:	5e                   	pop    %esi
  8001db:	5f                   	pop    %edi
  8001dc:	5d                   	pop    %ebp
  8001dd:	c3                   	ret    

008001de <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001de:	f3 0f 1e fb          	endbr32 
  8001e2:	55                   	push   %ebp
  8001e3:	89 e5                	mov    %esp,%ebp
  8001e5:	56                   	push   %esi
  8001e6:	53                   	push   %ebx
  8001e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001ea:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8001ed:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  8001f4:	00 00 00 
    envid_t envid = sys_getenvid();
  8001f7:	e8 40 0b 00 00       	call   800d3c <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  8001fc:	25 ff 03 00 00       	and    $0x3ff,%eax
  800201:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800204:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800209:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80020e:	85 db                	test   %ebx,%ebx
  800210:	7e 07                	jle    800219 <libmain+0x3b>
		binaryname = argv[0];
  800212:	8b 06                	mov    (%esi),%eax
  800214:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800219:	83 ec 08             	sub    $0x8,%esp
  80021c:	56                   	push   %esi
  80021d:	53                   	push   %ebx
  80021e:	e8 61 ff ff ff       	call   800184 <umain>

	// exit gracefully
	exit();
  800223:	e8 0a 00 00 00       	call   800232 <exit>
}
  800228:	83 c4 10             	add    $0x10,%esp
  80022b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80022e:	5b                   	pop    %ebx
  80022f:	5e                   	pop    %esi
  800230:	5d                   	pop    %ebp
  800231:	c3                   	ret    

00800232 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800232:	f3 0f 1e fb          	endbr32 
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80023c:	e8 41 0f 00 00       	call   801182 <close_all>
	sys_env_destroy(0);
  800241:	83 ec 0c             	sub    $0xc,%esp
  800244:	6a 00                	push   $0x0
  800246:	e8 ac 0a 00 00       	call   800cf7 <sys_env_destroy>
}
  80024b:	83 c4 10             	add    $0x10,%esp
  80024e:	c9                   	leave  
  80024f:	c3                   	ret    

00800250 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800250:	f3 0f 1e fb          	endbr32 
  800254:	55                   	push   %ebp
  800255:	89 e5                	mov    %esp,%ebp
  800257:	56                   	push   %esi
  800258:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800259:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80025c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800262:	e8 d5 0a 00 00       	call   800d3c <sys_getenvid>
  800267:	83 ec 0c             	sub    $0xc,%esp
  80026a:	ff 75 0c             	pushl  0xc(%ebp)
  80026d:	ff 75 08             	pushl  0x8(%ebp)
  800270:	56                   	push   %esi
  800271:	50                   	push   %eax
  800272:	68 18 21 80 00       	push   $0x802118
  800277:	e8 bb 00 00 00       	call   800337 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80027c:	83 c4 18             	add    $0x18,%esp
  80027f:	53                   	push   %ebx
  800280:	ff 75 10             	pushl  0x10(%ebp)
  800283:	e8 5a 00 00 00       	call   8002e2 <vcprintf>
	cprintf("\n");
  800288:	c7 04 24 0b 21 80 00 	movl   $0x80210b,(%esp)
  80028f:	e8 a3 00 00 00       	call   800337 <cprintf>
  800294:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800297:	cc                   	int3   
  800298:	eb fd                	jmp    800297 <_panic+0x47>

0080029a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80029a:	f3 0f 1e fb          	endbr32 
  80029e:	55                   	push   %ebp
  80029f:	89 e5                	mov    %esp,%ebp
  8002a1:	53                   	push   %ebx
  8002a2:	83 ec 04             	sub    $0x4,%esp
  8002a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002a8:	8b 13                	mov    (%ebx),%edx
  8002aa:	8d 42 01             	lea    0x1(%edx),%eax
  8002ad:	89 03                	mov    %eax,(%ebx)
  8002af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002b2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002b6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002bb:	74 09                	je     8002c6 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8002bd:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002c4:	c9                   	leave  
  8002c5:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8002c6:	83 ec 08             	sub    $0x8,%esp
  8002c9:	68 ff 00 00 00       	push   $0xff
  8002ce:	8d 43 08             	lea    0x8(%ebx),%eax
  8002d1:	50                   	push   %eax
  8002d2:	e8 db 09 00 00       	call   800cb2 <sys_cputs>
		b->idx = 0;
  8002d7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002dd:	83 c4 10             	add    $0x10,%esp
  8002e0:	eb db                	jmp    8002bd <putch+0x23>

008002e2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002e2:	f3 0f 1e fb          	endbr32 
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002ef:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002f6:	00 00 00 
	b.cnt = 0;
  8002f9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800300:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800303:	ff 75 0c             	pushl  0xc(%ebp)
  800306:	ff 75 08             	pushl  0x8(%ebp)
  800309:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80030f:	50                   	push   %eax
  800310:	68 9a 02 80 00       	push   $0x80029a
  800315:	e8 20 01 00 00       	call   80043a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80031a:	83 c4 08             	add    $0x8,%esp
  80031d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800323:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800329:	50                   	push   %eax
  80032a:	e8 83 09 00 00       	call   800cb2 <sys_cputs>

	return b.cnt;
}
  80032f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800335:	c9                   	leave  
  800336:	c3                   	ret    

00800337 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800337:	f3 0f 1e fb          	endbr32 
  80033b:	55                   	push   %ebp
  80033c:	89 e5                	mov    %esp,%ebp
  80033e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800341:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800344:	50                   	push   %eax
  800345:	ff 75 08             	pushl  0x8(%ebp)
  800348:	e8 95 ff ff ff       	call   8002e2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80034d:	c9                   	leave  
  80034e:	c3                   	ret    

0080034f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
  800352:	57                   	push   %edi
  800353:	56                   	push   %esi
  800354:	53                   	push   %ebx
  800355:	83 ec 1c             	sub    $0x1c,%esp
  800358:	89 c7                	mov    %eax,%edi
  80035a:	89 d6                	mov    %edx,%esi
  80035c:	8b 45 08             	mov    0x8(%ebp),%eax
  80035f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800362:	89 d1                	mov    %edx,%ecx
  800364:	89 c2                	mov    %eax,%edx
  800366:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800369:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80036c:	8b 45 10             	mov    0x10(%ebp),%eax
  80036f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800372:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800375:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80037c:	39 c2                	cmp    %eax,%edx
  80037e:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800381:	72 3e                	jb     8003c1 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800383:	83 ec 0c             	sub    $0xc,%esp
  800386:	ff 75 18             	pushl  0x18(%ebp)
  800389:	83 eb 01             	sub    $0x1,%ebx
  80038c:	53                   	push   %ebx
  80038d:	50                   	push   %eax
  80038e:	83 ec 08             	sub    $0x8,%esp
  800391:	ff 75 e4             	pushl  -0x1c(%ebp)
  800394:	ff 75 e0             	pushl  -0x20(%ebp)
  800397:	ff 75 dc             	pushl  -0x24(%ebp)
  80039a:	ff 75 d8             	pushl  -0x28(%ebp)
  80039d:	e8 7e 1a 00 00       	call   801e20 <__udivdi3>
  8003a2:	83 c4 18             	add    $0x18,%esp
  8003a5:	52                   	push   %edx
  8003a6:	50                   	push   %eax
  8003a7:	89 f2                	mov    %esi,%edx
  8003a9:	89 f8                	mov    %edi,%eax
  8003ab:	e8 9f ff ff ff       	call   80034f <printnum>
  8003b0:	83 c4 20             	add    $0x20,%esp
  8003b3:	eb 13                	jmp    8003c8 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003b5:	83 ec 08             	sub    $0x8,%esp
  8003b8:	56                   	push   %esi
  8003b9:	ff 75 18             	pushl  0x18(%ebp)
  8003bc:	ff d7                	call   *%edi
  8003be:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8003c1:	83 eb 01             	sub    $0x1,%ebx
  8003c4:	85 db                	test   %ebx,%ebx
  8003c6:	7f ed                	jg     8003b5 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003c8:	83 ec 08             	sub    $0x8,%esp
  8003cb:	56                   	push   %esi
  8003cc:	83 ec 04             	sub    $0x4,%esp
  8003cf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003d2:	ff 75 e0             	pushl  -0x20(%ebp)
  8003d5:	ff 75 dc             	pushl  -0x24(%ebp)
  8003d8:	ff 75 d8             	pushl  -0x28(%ebp)
  8003db:	e8 50 1b 00 00       	call   801f30 <__umoddi3>
  8003e0:	83 c4 14             	add    $0x14,%esp
  8003e3:	0f be 80 3b 21 80 00 	movsbl 0x80213b(%eax),%eax
  8003ea:	50                   	push   %eax
  8003eb:	ff d7                	call   *%edi
}
  8003ed:	83 c4 10             	add    $0x10,%esp
  8003f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003f3:	5b                   	pop    %ebx
  8003f4:	5e                   	pop    %esi
  8003f5:	5f                   	pop    %edi
  8003f6:	5d                   	pop    %ebp
  8003f7:	c3                   	ret    

008003f8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003f8:	f3 0f 1e fb          	endbr32 
  8003fc:	55                   	push   %ebp
  8003fd:	89 e5                	mov    %esp,%ebp
  8003ff:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800402:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800406:	8b 10                	mov    (%eax),%edx
  800408:	3b 50 04             	cmp    0x4(%eax),%edx
  80040b:	73 0a                	jae    800417 <sprintputch+0x1f>
		*b->buf++ = ch;
  80040d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800410:	89 08                	mov    %ecx,(%eax)
  800412:	8b 45 08             	mov    0x8(%ebp),%eax
  800415:	88 02                	mov    %al,(%edx)
}
  800417:	5d                   	pop    %ebp
  800418:	c3                   	ret    

00800419 <printfmt>:
{
  800419:	f3 0f 1e fb          	endbr32 
  80041d:	55                   	push   %ebp
  80041e:	89 e5                	mov    %esp,%ebp
  800420:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800423:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800426:	50                   	push   %eax
  800427:	ff 75 10             	pushl  0x10(%ebp)
  80042a:	ff 75 0c             	pushl  0xc(%ebp)
  80042d:	ff 75 08             	pushl  0x8(%ebp)
  800430:	e8 05 00 00 00       	call   80043a <vprintfmt>
}
  800435:	83 c4 10             	add    $0x10,%esp
  800438:	c9                   	leave  
  800439:	c3                   	ret    

0080043a <vprintfmt>:
{
  80043a:	f3 0f 1e fb          	endbr32 
  80043e:	55                   	push   %ebp
  80043f:	89 e5                	mov    %esp,%ebp
  800441:	57                   	push   %edi
  800442:	56                   	push   %esi
  800443:	53                   	push   %ebx
  800444:	83 ec 3c             	sub    $0x3c,%esp
  800447:	8b 75 08             	mov    0x8(%ebp),%esi
  80044a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80044d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800450:	e9 4a 03 00 00       	jmp    80079f <vprintfmt+0x365>
		padc = ' ';
  800455:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800459:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800460:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800467:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80046e:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800473:	8d 47 01             	lea    0x1(%edi),%eax
  800476:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800479:	0f b6 17             	movzbl (%edi),%edx
  80047c:	8d 42 dd             	lea    -0x23(%edx),%eax
  80047f:	3c 55                	cmp    $0x55,%al
  800481:	0f 87 de 03 00 00    	ja     800865 <vprintfmt+0x42b>
  800487:	0f b6 c0             	movzbl %al,%eax
  80048a:	3e ff 24 85 80 22 80 	notrack jmp *0x802280(,%eax,4)
  800491:	00 
  800492:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800495:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800499:	eb d8                	jmp    800473 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80049b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80049e:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8004a2:	eb cf                	jmp    800473 <vprintfmt+0x39>
  8004a4:	0f b6 d2             	movzbl %dl,%edx
  8004a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8004aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8004af:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8004b2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004b5:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8004b9:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004bc:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004bf:	83 f9 09             	cmp    $0x9,%ecx
  8004c2:	77 55                	ja     800519 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8004c4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004c7:	eb e9                	jmp    8004b2 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8004c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cc:	8b 00                	mov    (%eax),%eax
  8004ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d4:	8d 40 04             	lea    0x4(%eax),%eax
  8004d7:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8004dd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e1:	79 90                	jns    800473 <vprintfmt+0x39>
				width = precision, precision = -1;
  8004e3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e9:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8004f0:	eb 81                	jmp    800473 <vprintfmt+0x39>
  8004f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f5:	85 c0                	test   %eax,%eax
  8004f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8004fc:	0f 49 d0             	cmovns %eax,%edx
  8004ff:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800502:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800505:	e9 69 ff ff ff       	jmp    800473 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80050a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80050d:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800514:	e9 5a ff ff ff       	jmp    800473 <vprintfmt+0x39>
  800519:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80051c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051f:	eb bc                	jmp    8004dd <vprintfmt+0xa3>
			lflag++;
  800521:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800524:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800527:	e9 47 ff ff ff       	jmp    800473 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80052c:	8b 45 14             	mov    0x14(%ebp),%eax
  80052f:	8d 78 04             	lea    0x4(%eax),%edi
  800532:	83 ec 08             	sub    $0x8,%esp
  800535:	53                   	push   %ebx
  800536:	ff 30                	pushl  (%eax)
  800538:	ff d6                	call   *%esi
			break;
  80053a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80053d:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800540:	e9 57 02 00 00       	jmp    80079c <vprintfmt+0x362>
			err = va_arg(ap, int);
  800545:	8b 45 14             	mov    0x14(%ebp),%eax
  800548:	8d 78 04             	lea    0x4(%eax),%edi
  80054b:	8b 00                	mov    (%eax),%eax
  80054d:	99                   	cltd   
  80054e:	31 d0                	xor    %edx,%eax
  800550:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800552:	83 f8 0f             	cmp    $0xf,%eax
  800555:	7f 23                	jg     80057a <vprintfmt+0x140>
  800557:	8b 14 85 e0 23 80 00 	mov    0x8023e0(,%eax,4),%edx
  80055e:	85 d2                	test   %edx,%edx
  800560:	74 18                	je     80057a <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800562:	52                   	push   %edx
  800563:	68 11 25 80 00       	push   $0x802511
  800568:	53                   	push   %ebx
  800569:	56                   	push   %esi
  80056a:	e8 aa fe ff ff       	call   800419 <printfmt>
  80056f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800572:	89 7d 14             	mov    %edi,0x14(%ebp)
  800575:	e9 22 02 00 00       	jmp    80079c <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  80057a:	50                   	push   %eax
  80057b:	68 53 21 80 00       	push   $0x802153
  800580:	53                   	push   %ebx
  800581:	56                   	push   %esi
  800582:	e8 92 fe ff ff       	call   800419 <printfmt>
  800587:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80058a:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80058d:	e9 0a 02 00 00       	jmp    80079c <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	83 c0 04             	add    $0x4,%eax
  800598:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80059b:	8b 45 14             	mov    0x14(%ebp),%eax
  80059e:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8005a0:	85 d2                	test   %edx,%edx
  8005a2:	b8 4c 21 80 00       	mov    $0x80214c,%eax
  8005a7:	0f 45 c2             	cmovne %edx,%eax
  8005aa:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8005ad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005b1:	7e 06                	jle    8005b9 <vprintfmt+0x17f>
  8005b3:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8005b7:	75 0d                	jne    8005c6 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b9:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005bc:	89 c7                	mov    %eax,%edi
  8005be:	03 45 e0             	add    -0x20(%ebp),%eax
  8005c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005c4:	eb 55                	jmp    80061b <vprintfmt+0x1e1>
  8005c6:	83 ec 08             	sub    $0x8,%esp
  8005c9:	ff 75 d8             	pushl  -0x28(%ebp)
  8005cc:	ff 75 cc             	pushl  -0x34(%ebp)
  8005cf:	e8 45 03 00 00       	call   800919 <strnlen>
  8005d4:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005d7:	29 c2                	sub    %eax,%edx
  8005d9:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8005dc:	83 c4 10             	add    $0x10,%esp
  8005df:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8005e1:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8005e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e8:	85 ff                	test   %edi,%edi
  8005ea:	7e 11                	jle    8005fd <vprintfmt+0x1c3>
					putch(padc, putdat);
  8005ec:	83 ec 08             	sub    $0x8,%esp
  8005ef:	53                   	push   %ebx
  8005f0:	ff 75 e0             	pushl  -0x20(%ebp)
  8005f3:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f5:	83 ef 01             	sub    $0x1,%edi
  8005f8:	83 c4 10             	add    $0x10,%esp
  8005fb:	eb eb                	jmp    8005e8 <vprintfmt+0x1ae>
  8005fd:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800600:	85 d2                	test   %edx,%edx
  800602:	b8 00 00 00 00       	mov    $0x0,%eax
  800607:	0f 49 c2             	cmovns %edx,%eax
  80060a:	29 c2                	sub    %eax,%edx
  80060c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80060f:	eb a8                	jmp    8005b9 <vprintfmt+0x17f>
					putch(ch, putdat);
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	53                   	push   %ebx
  800615:	52                   	push   %edx
  800616:	ff d6                	call   *%esi
  800618:	83 c4 10             	add    $0x10,%esp
  80061b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80061e:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800620:	83 c7 01             	add    $0x1,%edi
  800623:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800627:	0f be d0             	movsbl %al,%edx
  80062a:	85 d2                	test   %edx,%edx
  80062c:	74 4b                	je     800679 <vprintfmt+0x23f>
  80062e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800632:	78 06                	js     80063a <vprintfmt+0x200>
  800634:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800638:	78 1e                	js     800658 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80063a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80063e:	74 d1                	je     800611 <vprintfmt+0x1d7>
  800640:	0f be c0             	movsbl %al,%eax
  800643:	83 e8 20             	sub    $0x20,%eax
  800646:	83 f8 5e             	cmp    $0x5e,%eax
  800649:	76 c6                	jbe    800611 <vprintfmt+0x1d7>
					putch('?', putdat);
  80064b:	83 ec 08             	sub    $0x8,%esp
  80064e:	53                   	push   %ebx
  80064f:	6a 3f                	push   $0x3f
  800651:	ff d6                	call   *%esi
  800653:	83 c4 10             	add    $0x10,%esp
  800656:	eb c3                	jmp    80061b <vprintfmt+0x1e1>
  800658:	89 cf                	mov    %ecx,%edi
  80065a:	eb 0e                	jmp    80066a <vprintfmt+0x230>
				putch(' ', putdat);
  80065c:	83 ec 08             	sub    $0x8,%esp
  80065f:	53                   	push   %ebx
  800660:	6a 20                	push   $0x20
  800662:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800664:	83 ef 01             	sub    $0x1,%edi
  800667:	83 c4 10             	add    $0x10,%esp
  80066a:	85 ff                	test   %edi,%edi
  80066c:	7f ee                	jg     80065c <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80066e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800671:	89 45 14             	mov    %eax,0x14(%ebp)
  800674:	e9 23 01 00 00       	jmp    80079c <vprintfmt+0x362>
  800679:	89 cf                	mov    %ecx,%edi
  80067b:	eb ed                	jmp    80066a <vprintfmt+0x230>
	if (lflag >= 2)
  80067d:	83 f9 01             	cmp    $0x1,%ecx
  800680:	7f 1b                	jg     80069d <vprintfmt+0x263>
	else if (lflag)
  800682:	85 c9                	test   %ecx,%ecx
  800684:	74 63                	je     8006e9 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800686:	8b 45 14             	mov    0x14(%ebp),%eax
  800689:	8b 00                	mov    (%eax),%eax
  80068b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068e:	99                   	cltd   
  80068f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800692:	8b 45 14             	mov    0x14(%ebp),%eax
  800695:	8d 40 04             	lea    0x4(%eax),%eax
  800698:	89 45 14             	mov    %eax,0x14(%ebp)
  80069b:	eb 17                	jmp    8006b4 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80069d:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a0:	8b 50 04             	mov    0x4(%eax),%edx
  8006a3:	8b 00                	mov    (%eax),%eax
  8006a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ae:	8d 40 08             	lea    0x8(%eax),%eax
  8006b1:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8006b4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006b7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8006ba:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8006bf:	85 c9                	test   %ecx,%ecx
  8006c1:	0f 89 bb 00 00 00    	jns    800782 <vprintfmt+0x348>
				putch('-', putdat);
  8006c7:	83 ec 08             	sub    $0x8,%esp
  8006ca:	53                   	push   %ebx
  8006cb:	6a 2d                	push   $0x2d
  8006cd:	ff d6                	call   *%esi
				num = -(long long) num;
  8006cf:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006d2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006d5:	f7 da                	neg    %edx
  8006d7:	83 d1 00             	adc    $0x0,%ecx
  8006da:	f7 d9                	neg    %ecx
  8006dc:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006df:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006e4:	e9 99 00 00 00       	jmp    800782 <vprintfmt+0x348>
		return va_arg(*ap, int);
  8006e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ec:	8b 00                	mov    (%eax),%eax
  8006ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f1:	99                   	cltd   
  8006f2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f8:	8d 40 04             	lea    0x4(%eax),%eax
  8006fb:	89 45 14             	mov    %eax,0x14(%ebp)
  8006fe:	eb b4                	jmp    8006b4 <vprintfmt+0x27a>
	if (lflag >= 2)
  800700:	83 f9 01             	cmp    $0x1,%ecx
  800703:	7f 1b                	jg     800720 <vprintfmt+0x2e6>
	else if (lflag)
  800705:	85 c9                	test   %ecx,%ecx
  800707:	74 2c                	je     800735 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800709:	8b 45 14             	mov    0x14(%ebp),%eax
  80070c:	8b 10                	mov    (%eax),%edx
  80070e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800713:	8d 40 04             	lea    0x4(%eax),%eax
  800716:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800719:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80071e:	eb 62                	jmp    800782 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800720:	8b 45 14             	mov    0x14(%ebp),%eax
  800723:	8b 10                	mov    (%eax),%edx
  800725:	8b 48 04             	mov    0x4(%eax),%ecx
  800728:	8d 40 08             	lea    0x8(%eax),%eax
  80072b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80072e:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800733:	eb 4d                	jmp    800782 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800735:	8b 45 14             	mov    0x14(%ebp),%eax
  800738:	8b 10                	mov    (%eax),%edx
  80073a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073f:	8d 40 04             	lea    0x4(%eax),%eax
  800742:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800745:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80074a:	eb 36                	jmp    800782 <vprintfmt+0x348>
	if (lflag >= 2)
  80074c:	83 f9 01             	cmp    $0x1,%ecx
  80074f:	7f 17                	jg     800768 <vprintfmt+0x32e>
	else if (lflag)
  800751:	85 c9                	test   %ecx,%ecx
  800753:	74 6e                	je     8007c3 <vprintfmt+0x389>
		return va_arg(*ap, long);
  800755:	8b 45 14             	mov    0x14(%ebp),%eax
  800758:	8b 10                	mov    (%eax),%edx
  80075a:	89 d0                	mov    %edx,%eax
  80075c:	99                   	cltd   
  80075d:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800760:	8d 49 04             	lea    0x4(%ecx),%ecx
  800763:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800766:	eb 11                	jmp    800779 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  800768:	8b 45 14             	mov    0x14(%ebp),%eax
  80076b:	8b 50 04             	mov    0x4(%eax),%edx
  80076e:	8b 00                	mov    (%eax),%eax
  800770:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800773:	8d 49 08             	lea    0x8(%ecx),%ecx
  800776:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800779:	89 d1                	mov    %edx,%ecx
  80077b:	89 c2                	mov    %eax,%edx
            base = 8;
  80077d:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800782:	83 ec 0c             	sub    $0xc,%esp
  800785:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800789:	57                   	push   %edi
  80078a:	ff 75 e0             	pushl  -0x20(%ebp)
  80078d:	50                   	push   %eax
  80078e:	51                   	push   %ecx
  80078f:	52                   	push   %edx
  800790:	89 da                	mov    %ebx,%edx
  800792:	89 f0                	mov    %esi,%eax
  800794:	e8 b6 fb ff ff       	call   80034f <printnum>
			break;
  800799:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80079c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80079f:	83 c7 01             	add    $0x1,%edi
  8007a2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007a6:	83 f8 25             	cmp    $0x25,%eax
  8007a9:	0f 84 a6 fc ff ff    	je     800455 <vprintfmt+0x1b>
			if (ch == '\0')
  8007af:	85 c0                	test   %eax,%eax
  8007b1:	0f 84 ce 00 00 00    	je     800885 <vprintfmt+0x44b>
			putch(ch, putdat);
  8007b7:	83 ec 08             	sub    $0x8,%esp
  8007ba:	53                   	push   %ebx
  8007bb:	50                   	push   %eax
  8007bc:	ff d6                	call   *%esi
  8007be:	83 c4 10             	add    $0x10,%esp
  8007c1:	eb dc                	jmp    80079f <vprintfmt+0x365>
		return va_arg(*ap, int);
  8007c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c6:	8b 10                	mov    (%eax),%edx
  8007c8:	89 d0                	mov    %edx,%eax
  8007ca:	99                   	cltd   
  8007cb:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007ce:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007d1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007d4:	eb a3                	jmp    800779 <vprintfmt+0x33f>
			putch('0', putdat);
  8007d6:	83 ec 08             	sub    $0x8,%esp
  8007d9:	53                   	push   %ebx
  8007da:	6a 30                	push   $0x30
  8007dc:	ff d6                	call   *%esi
			putch('x', putdat);
  8007de:	83 c4 08             	add    $0x8,%esp
  8007e1:	53                   	push   %ebx
  8007e2:	6a 78                	push   $0x78
  8007e4:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e9:	8b 10                	mov    (%eax),%edx
  8007eb:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007f0:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8007f3:	8d 40 04             	lea    0x4(%eax),%eax
  8007f6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007f9:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007fe:	eb 82                	jmp    800782 <vprintfmt+0x348>
	if (lflag >= 2)
  800800:	83 f9 01             	cmp    $0x1,%ecx
  800803:	7f 1e                	jg     800823 <vprintfmt+0x3e9>
	else if (lflag)
  800805:	85 c9                	test   %ecx,%ecx
  800807:	74 32                	je     80083b <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800809:	8b 45 14             	mov    0x14(%ebp),%eax
  80080c:	8b 10                	mov    (%eax),%edx
  80080e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800813:	8d 40 04             	lea    0x4(%eax),%eax
  800816:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800819:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80081e:	e9 5f ff ff ff       	jmp    800782 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800823:	8b 45 14             	mov    0x14(%ebp),%eax
  800826:	8b 10                	mov    (%eax),%edx
  800828:	8b 48 04             	mov    0x4(%eax),%ecx
  80082b:	8d 40 08             	lea    0x8(%eax),%eax
  80082e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800831:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800836:	e9 47 ff ff ff       	jmp    800782 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80083b:	8b 45 14             	mov    0x14(%ebp),%eax
  80083e:	8b 10                	mov    (%eax),%edx
  800840:	b9 00 00 00 00       	mov    $0x0,%ecx
  800845:	8d 40 04             	lea    0x4(%eax),%eax
  800848:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80084b:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800850:	e9 2d ff ff ff       	jmp    800782 <vprintfmt+0x348>
			putch(ch, putdat);
  800855:	83 ec 08             	sub    $0x8,%esp
  800858:	53                   	push   %ebx
  800859:	6a 25                	push   $0x25
  80085b:	ff d6                	call   *%esi
			break;
  80085d:	83 c4 10             	add    $0x10,%esp
  800860:	e9 37 ff ff ff       	jmp    80079c <vprintfmt+0x362>
			putch('%', putdat);
  800865:	83 ec 08             	sub    $0x8,%esp
  800868:	53                   	push   %ebx
  800869:	6a 25                	push   $0x25
  80086b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80086d:	83 c4 10             	add    $0x10,%esp
  800870:	89 f8                	mov    %edi,%eax
  800872:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800876:	74 05                	je     80087d <vprintfmt+0x443>
  800878:	83 e8 01             	sub    $0x1,%eax
  80087b:	eb f5                	jmp    800872 <vprintfmt+0x438>
  80087d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800880:	e9 17 ff ff ff       	jmp    80079c <vprintfmt+0x362>
}
  800885:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800888:	5b                   	pop    %ebx
  800889:	5e                   	pop    %esi
  80088a:	5f                   	pop    %edi
  80088b:	5d                   	pop    %ebp
  80088c:	c3                   	ret    

0080088d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80088d:	f3 0f 1e fb          	endbr32 
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	83 ec 18             	sub    $0x18,%esp
  800897:	8b 45 08             	mov    0x8(%ebp),%eax
  80089a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80089d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008a0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008a4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008ae:	85 c0                	test   %eax,%eax
  8008b0:	74 26                	je     8008d8 <vsnprintf+0x4b>
  8008b2:	85 d2                	test   %edx,%edx
  8008b4:	7e 22                	jle    8008d8 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008b6:	ff 75 14             	pushl  0x14(%ebp)
  8008b9:	ff 75 10             	pushl  0x10(%ebp)
  8008bc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008bf:	50                   	push   %eax
  8008c0:	68 f8 03 80 00       	push   $0x8003f8
  8008c5:	e8 70 fb ff ff       	call   80043a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008cd:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008d3:	83 c4 10             	add    $0x10,%esp
}
  8008d6:	c9                   	leave  
  8008d7:	c3                   	ret    
		return -E_INVAL;
  8008d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008dd:	eb f7                	jmp    8008d6 <vsnprintf+0x49>

008008df <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008df:	f3 0f 1e fb          	endbr32 
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008e9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008ec:	50                   	push   %eax
  8008ed:	ff 75 10             	pushl  0x10(%ebp)
  8008f0:	ff 75 0c             	pushl  0xc(%ebp)
  8008f3:	ff 75 08             	pushl  0x8(%ebp)
  8008f6:	e8 92 ff ff ff       	call   80088d <vsnprintf>
	va_end(ap);

	return rc;
}
  8008fb:	c9                   	leave  
  8008fc:	c3                   	ret    

008008fd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008fd:	f3 0f 1e fb          	endbr32 
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800907:	b8 00 00 00 00       	mov    $0x0,%eax
  80090c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800910:	74 05                	je     800917 <strlen+0x1a>
		n++;
  800912:	83 c0 01             	add    $0x1,%eax
  800915:	eb f5                	jmp    80090c <strlen+0xf>
	return n;
}
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800919:	f3 0f 1e fb          	endbr32 
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800923:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800926:	b8 00 00 00 00       	mov    $0x0,%eax
  80092b:	39 d0                	cmp    %edx,%eax
  80092d:	74 0d                	je     80093c <strnlen+0x23>
  80092f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800933:	74 05                	je     80093a <strnlen+0x21>
		n++;
  800935:	83 c0 01             	add    $0x1,%eax
  800938:	eb f1                	jmp    80092b <strnlen+0x12>
  80093a:	89 c2                	mov    %eax,%edx
	return n;
}
  80093c:	89 d0                	mov    %edx,%eax
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800940:	f3 0f 1e fb          	endbr32 
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	53                   	push   %ebx
  800948:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80094b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80094e:	b8 00 00 00 00       	mov    $0x0,%eax
  800953:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800957:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80095a:	83 c0 01             	add    $0x1,%eax
  80095d:	84 d2                	test   %dl,%dl
  80095f:	75 f2                	jne    800953 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800961:	89 c8                	mov    %ecx,%eax
  800963:	5b                   	pop    %ebx
  800964:	5d                   	pop    %ebp
  800965:	c3                   	ret    

00800966 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800966:	f3 0f 1e fb          	endbr32 
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	53                   	push   %ebx
  80096e:	83 ec 10             	sub    $0x10,%esp
  800971:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800974:	53                   	push   %ebx
  800975:	e8 83 ff ff ff       	call   8008fd <strlen>
  80097a:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80097d:	ff 75 0c             	pushl  0xc(%ebp)
  800980:	01 d8                	add    %ebx,%eax
  800982:	50                   	push   %eax
  800983:	e8 b8 ff ff ff       	call   800940 <strcpy>
	return dst;
}
  800988:	89 d8                	mov    %ebx,%eax
  80098a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80098d:	c9                   	leave  
  80098e:	c3                   	ret    

0080098f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80098f:	f3 0f 1e fb          	endbr32 
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	56                   	push   %esi
  800997:	53                   	push   %ebx
  800998:	8b 75 08             	mov    0x8(%ebp),%esi
  80099b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099e:	89 f3                	mov    %esi,%ebx
  8009a0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a3:	89 f0                	mov    %esi,%eax
  8009a5:	39 d8                	cmp    %ebx,%eax
  8009a7:	74 11                	je     8009ba <strncpy+0x2b>
		*dst++ = *src;
  8009a9:	83 c0 01             	add    $0x1,%eax
  8009ac:	0f b6 0a             	movzbl (%edx),%ecx
  8009af:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009b2:	80 f9 01             	cmp    $0x1,%cl
  8009b5:	83 da ff             	sbb    $0xffffffff,%edx
  8009b8:	eb eb                	jmp    8009a5 <strncpy+0x16>
	}
	return ret;
}
  8009ba:	89 f0                	mov    %esi,%eax
  8009bc:	5b                   	pop    %ebx
  8009bd:	5e                   	pop    %esi
  8009be:	5d                   	pop    %ebp
  8009bf:	c3                   	ret    

008009c0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009c0:	f3 0f 1e fb          	endbr32 
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	56                   	push   %esi
  8009c8:	53                   	push   %ebx
  8009c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8009cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009cf:	8b 55 10             	mov    0x10(%ebp),%edx
  8009d2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009d4:	85 d2                	test   %edx,%edx
  8009d6:	74 21                	je     8009f9 <strlcpy+0x39>
  8009d8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009dc:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8009de:	39 c2                	cmp    %eax,%edx
  8009e0:	74 14                	je     8009f6 <strlcpy+0x36>
  8009e2:	0f b6 19             	movzbl (%ecx),%ebx
  8009e5:	84 db                	test   %bl,%bl
  8009e7:	74 0b                	je     8009f4 <strlcpy+0x34>
			*dst++ = *src++;
  8009e9:	83 c1 01             	add    $0x1,%ecx
  8009ec:	83 c2 01             	add    $0x1,%edx
  8009ef:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009f2:	eb ea                	jmp    8009de <strlcpy+0x1e>
  8009f4:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8009f6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009f9:	29 f0                	sub    %esi,%eax
}
  8009fb:	5b                   	pop    %ebx
  8009fc:	5e                   	pop    %esi
  8009fd:	5d                   	pop    %ebp
  8009fe:	c3                   	ret    

008009ff <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009ff:	f3 0f 1e fb          	endbr32 
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a09:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a0c:	0f b6 01             	movzbl (%ecx),%eax
  800a0f:	84 c0                	test   %al,%al
  800a11:	74 0c                	je     800a1f <strcmp+0x20>
  800a13:	3a 02                	cmp    (%edx),%al
  800a15:	75 08                	jne    800a1f <strcmp+0x20>
		p++, q++;
  800a17:	83 c1 01             	add    $0x1,%ecx
  800a1a:	83 c2 01             	add    $0x1,%edx
  800a1d:	eb ed                	jmp    800a0c <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a1f:	0f b6 c0             	movzbl %al,%eax
  800a22:	0f b6 12             	movzbl (%edx),%edx
  800a25:	29 d0                	sub    %edx,%eax
}
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a29:	f3 0f 1e fb          	endbr32 
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	53                   	push   %ebx
  800a31:	8b 45 08             	mov    0x8(%ebp),%eax
  800a34:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a37:	89 c3                	mov    %eax,%ebx
  800a39:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a3c:	eb 06                	jmp    800a44 <strncmp+0x1b>
		n--, p++, q++;
  800a3e:	83 c0 01             	add    $0x1,%eax
  800a41:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a44:	39 d8                	cmp    %ebx,%eax
  800a46:	74 16                	je     800a5e <strncmp+0x35>
  800a48:	0f b6 08             	movzbl (%eax),%ecx
  800a4b:	84 c9                	test   %cl,%cl
  800a4d:	74 04                	je     800a53 <strncmp+0x2a>
  800a4f:	3a 0a                	cmp    (%edx),%cl
  800a51:	74 eb                	je     800a3e <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a53:	0f b6 00             	movzbl (%eax),%eax
  800a56:	0f b6 12             	movzbl (%edx),%edx
  800a59:	29 d0                	sub    %edx,%eax
}
  800a5b:	5b                   	pop    %ebx
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    
		return 0;
  800a5e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a63:	eb f6                	jmp    800a5b <strncmp+0x32>

00800a65 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a65:	f3 0f 1e fb          	endbr32 
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
  800a6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a73:	0f b6 10             	movzbl (%eax),%edx
  800a76:	84 d2                	test   %dl,%dl
  800a78:	74 09                	je     800a83 <strchr+0x1e>
		if (*s == c)
  800a7a:	38 ca                	cmp    %cl,%dl
  800a7c:	74 0a                	je     800a88 <strchr+0x23>
	for (; *s; s++)
  800a7e:	83 c0 01             	add    $0x1,%eax
  800a81:	eb f0                	jmp    800a73 <strchr+0xe>
			return (char *) s;
	return 0;
  800a83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a88:	5d                   	pop    %ebp
  800a89:	c3                   	ret    

00800a8a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a8a:	f3 0f 1e fb          	endbr32 
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
  800a91:	8b 45 08             	mov    0x8(%ebp),%eax
  800a94:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a98:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a9b:	38 ca                	cmp    %cl,%dl
  800a9d:	74 09                	je     800aa8 <strfind+0x1e>
  800a9f:	84 d2                	test   %dl,%dl
  800aa1:	74 05                	je     800aa8 <strfind+0x1e>
	for (; *s; s++)
  800aa3:	83 c0 01             	add    $0x1,%eax
  800aa6:	eb f0                	jmp    800a98 <strfind+0xe>
			break;
	return (char *) s;
}
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aaa:	f3 0f 1e fb          	endbr32 
  800aae:	55                   	push   %ebp
  800aaf:	89 e5                	mov    %esp,%ebp
  800ab1:	57                   	push   %edi
  800ab2:	56                   	push   %esi
  800ab3:	53                   	push   %ebx
  800ab4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ab7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aba:	85 c9                	test   %ecx,%ecx
  800abc:	74 31                	je     800aef <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800abe:	89 f8                	mov    %edi,%eax
  800ac0:	09 c8                	or     %ecx,%eax
  800ac2:	a8 03                	test   $0x3,%al
  800ac4:	75 23                	jne    800ae9 <memset+0x3f>
		c &= 0xFF;
  800ac6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aca:	89 d3                	mov    %edx,%ebx
  800acc:	c1 e3 08             	shl    $0x8,%ebx
  800acf:	89 d0                	mov    %edx,%eax
  800ad1:	c1 e0 18             	shl    $0x18,%eax
  800ad4:	89 d6                	mov    %edx,%esi
  800ad6:	c1 e6 10             	shl    $0x10,%esi
  800ad9:	09 f0                	or     %esi,%eax
  800adb:	09 c2                	or     %eax,%edx
  800add:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800adf:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ae2:	89 d0                	mov    %edx,%eax
  800ae4:	fc                   	cld    
  800ae5:	f3 ab                	rep stos %eax,%es:(%edi)
  800ae7:	eb 06                	jmp    800aef <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ae9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aec:	fc                   	cld    
  800aed:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aef:	89 f8                	mov    %edi,%eax
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5f                   	pop    %edi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800af6:	f3 0f 1e fb          	endbr32 
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	57                   	push   %edi
  800afe:	56                   	push   %esi
  800aff:	8b 45 08             	mov    0x8(%ebp),%eax
  800b02:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b05:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b08:	39 c6                	cmp    %eax,%esi
  800b0a:	73 32                	jae    800b3e <memmove+0x48>
  800b0c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b0f:	39 c2                	cmp    %eax,%edx
  800b11:	76 2b                	jbe    800b3e <memmove+0x48>
		s += n;
		d += n;
  800b13:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b16:	89 fe                	mov    %edi,%esi
  800b18:	09 ce                	or     %ecx,%esi
  800b1a:	09 d6                	or     %edx,%esi
  800b1c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b22:	75 0e                	jne    800b32 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b24:	83 ef 04             	sub    $0x4,%edi
  800b27:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b2a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b2d:	fd                   	std    
  800b2e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b30:	eb 09                	jmp    800b3b <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b32:	83 ef 01             	sub    $0x1,%edi
  800b35:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b38:	fd                   	std    
  800b39:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b3b:	fc                   	cld    
  800b3c:	eb 1a                	jmp    800b58 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b3e:	89 c2                	mov    %eax,%edx
  800b40:	09 ca                	or     %ecx,%edx
  800b42:	09 f2                	or     %esi,%edx
  800b44:	f6 c2 03             	test   $0x3,%dl
  800b47:	75 0a                	jne    800b53 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b49:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b4c:	89 c7                	mov    %eax,%edi
  800b4e:	fc                   	cld    
  800b4f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b51:	eb 05                	jmp    800b58 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800b53:	89 c7                	mov    %eax,%edi
  800b55:	fc                   	cld    
  800b56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b58:	5e                   	pop    %esi
  800b59:	5f                   	pop    %edi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b5c:	f3 0f 1e fb          	endbr32 
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b66:	ff 75 10             	pushl  0x10(%ebp)
  800b69:	ff 75 0c             	pushl  0xc(%ebp)
  800b6c:	ff 75 08             	pushl  0x8(%ebp)
  800b6f:	e8 82 ff ff ff       	call   800af6 <memmove>
}
  800b74:	c9                   	leave  
  800b75:	c3                   	ret    

00800b76 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b76:	f3 0f 1e fb          	endbr32 
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	56                   	push   %esi
  800b7e:	53                   	push   %ebx
  800b7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b82:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b85:	89 c6                	mov    %eax,%esi
  800b87:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b8a:	39 f0                	cmp    %esi,%eax
  800b8c:	74 1c                	je     800baa <memcmp+0x34>
		if (*s1 != *s2)
  800b8e:	0f b6 08             	movzbl (%eax),%ecx
  800b91:	0f b6 1a             	movzbl (%edx),%ebx
  800b94:	38 d9                	cmp    %bl,%cl
  800b96:	75 08                	jne    800ba0 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b98:	83 c0 01             	add    $0x1,%eax
  800b9b:	83 c2 01             	add    $0x1,%edx
  800b9e:	eb ea                	jmp    800b8a <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800ba0:	0f b6 c1             	movzbl %cl,%eax
  800ba3:	0f b6 db             	movzbl %bl,%ebx
  800ba6:	29 d8                	sub    %ebx,%eax
  800ba8:	eb 05                	jmp    800baf <memcmp+0x39>
	}

	return 0;
  800baa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bb3:	f3 0f 1e fb          	endbr32 
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bc0:	89 c2                	mov    %eax,%edx
  800bc2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bc5:	39 d0                	cmp    %edx,%eax
  800bc7:	73 09                	jae    800bd2 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc9:	38 08                	cmp    %cl,(%eax)
  800bcb:	74 05                	je     800bd2 <memfind+0x1f>
	for (; s < ends; s++)
  800bcd:	83 c0 01             	add    $0x1,%eax
  800bd0:	eb f3                	jmp    800bc5 <memfind+0x12>
			break;
	return (void *) s;
}
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bd4:	f3 0f 1e fb          	endbr32 
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	57                   	push   %edi
  800bdc:	56                   	push   %esi
  800bdd:	53                   	push   %ebx
  800bde:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800be4:	eb 03                	jmp    800be9 <strtol+0x15>
		s++;
  800be6:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800be9:	0f b6 01             	movzbl (%ecx),%eax
  800bec:	3c 20                	cmp    $0x20,%al
  800bee:	74 f6                	je     800be6 <strtol+0x12>
  800bf0:	3c 09                	cmp    $0x9,%al
  800bf2:	74 f2                	je     800be6 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800bf4:	3c 2b                	cmp    $0x2b,%al
  800bf6:	74 2a                	je     800c22 <strtol+0x4e>
	int neg = 0;
  800bf8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800bfd:	3c 2d                	cmp    $0x2d,%al
  800bff:	74 2b                	je     800c2c <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c01:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c07:	75 0f                	jne    800c18 <strtol+0x44>
  800c09:	80 39 30             	cmpb   $0x30,(%ecx)
  800c0c:	74 28                	je     800c36 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c0e:	85 db                	test   %ebx,%ebx
  800c10:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c15:	0f 44 d8             	cmove  %eax,%ebx
  800c18:	b8 00 00 00 00       	mov    $0x0,%eax
  800c1d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c20:	eb 46                	jmp    800c68 <strtol+0x94>
		s++;
  800c22:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800c25:	bf 00 00 00 00       	mov    $0x0,%edi
  800c2a:	eb d5                	jmp    800c01 <strtol+0x2d>
		s++, neg = 1;
  800c2c:	83 c1 01             	add    $0x1,%ecx
  800c2f:	bf 01 00 00 00       	mov    $0x1,%edi
  800c34:	eb cb                	jmp    800c01 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c36:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c3a:	74 0e                	je     800c4a <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c3c:	85 db                	test   %ebx,%ebx
  800c3e:	75 d8                	jne    800c18 <strtol+0x44>
		s++, base = 8;
  800c40:	83 c1 01             	add    $0x1,%ecx
  800c43:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c48:	eb ce                	jmp    800c18 <strtol+0x44>
		s += 2, base = 16;
  800c4a:	83 c1 02             	add    $0x2,%ecx
  800c4d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c52:	eb c4                	jmp    800c18 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800c54:	0f be d2             	movsbl %dl,%edx
  800c57:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c5a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c5d:	7d 3a                	jge    800c99 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c5f:	83 c1 01             	add    $0x1,%ecx
  800c62:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c66:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c68:	0f b6 11             	movzbl (%ecx),%edx
  800c6b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c6e:	89 f3                	mov    %esi,%ebx
  800c70:	80 fb 09             	cmp    $0x9,%bl
  800c73:	76 df                	jbe    800c54 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800c75:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c78:	89 f3                	mov    %esi,%ebx
  800c7a:	80 fb 19             	cmp    $0x19,%bl
  800c7d:	77 08                	ja     800c87 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c7f:	0f be d2             	movsbl %dl,%edx
  800c82:	83 ea 57             	sub    $0x57,%edx
  800c85:	eb d3                	jmp    800c5a <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800c87:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c8a:	89 f3                	mov    %esi,%ebx
  800c8c:	80 fb 19             	cmp    $0x19,%bl
  800c8f:	77 08                	ja     800c99 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c91:	0f be d2             	movsbl %dl,%edx
  800c94:	83 ea 37             	sub    $0x37,%edx
  800c97:	eb c1                	jmp    800c5a <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c99:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c9d:	74 05                	je     800ca4 <strtol+0xd0>
		*endptr = (char *) s;
  800c9f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ca2:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ca4:	89 c2                	mov    %eax,%edx
  800ca6:	f7 da                	neg    %edx
  800ca8:	85 ff                	test   %edi,%edi
  800caa:	0f 45 c2             	cmovne %edx,%eax
}
  800cad:	5b                   	pop    %ebx
  800cae:	5e                   	pop    %esi
  800caf:	5f                   	pop    %edi
  800cb0:	5d                   	pop    %ebp
  800cb1:	c3                   	ret    

00800cb2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cb2:	f3 0f 1e fb          	endbr32 
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	57                   	push   %edi
  800cba:	56                   	push   %esi
  800cbb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cbc:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc7:	89 c3                	mov    %eax,%ebx
  800cc9:	89 c7                	mov    %eax,%edi
  800ccb:	89 c6                	mov    %eax,%esi
  800ccd:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800cd4:	f3 0f 1e fb          	endbr32 
  800cd8:	55                   	push   %ebp
  800cd9:	89 e5                	mov    %esp,%ebp
  800cdb:	57                   	push   %edi
  800cdc:	56                   	push   %esi
  800cdd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cde:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce3:	b8 01 00 00 00       	mov    $0x1,%eax
  800ce8:	89 d1                	mov    %edx,%ecx
  800cea:	89 d3                	mov    %edx,%ebx
  800cec:	89 d7                	mov    %edx,%edi
  800cee:	89 d6                	mov    %edx,%esi
  800cf0:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cf2:	5b                   	pop    %ebx
  800cf3:	5e                   	pop    %esi
  800cf4:	5f                   	pop    %edi
  800cf5:	5d                   	pop    %ebp
  800cf6:	c3                   	ret    

00800cf7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cf7:	f3 0f 1e fb          	endbr32 
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	57                   	push   %edi
  800cff:	56                   	push   %esi
  800d00:	53                   	push   %ebx
  800d01:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d04:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d09:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0c:	b8 03 00 00 00       	mov    $0x3,%eax
  800d11:	89 cb                	mov    %ecx,%ebx
  800d13:	89 cf                	mov    %ecx,%edi
  800d15:	89 ce                	mov    %ecx,%esi
  800d17:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d19:	85 c0                	test   %eax,%eax
  800d1b:	7f 08                	jg     800d25 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5f                   	pop    %edi
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d25:	83 ec 0c             	sub    $0xc,%esp
  800d28:	50                   	push   %eax
  800d29:	6a 03                	push   $0x3
  800d2b:	68 3f 24 80 00       	push   $0x80243f
  800d30:	6a 23                	push   $0x23
  800d32:	68 5c 24 80 00       	push   $0x80245c
  800d37:	e8 14 f5 ff ff       	call   800250 <_panic>

00800d3c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d3c:	f3 0f 1e fb          	endbr32 
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	57                   	push   %edi
  800d44:	56                   	push   %esi
  800d45:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d46:	ba 00 00 00 00       	mov    $0x0,%edx
  800d4b:	b8 02 00 00 00       	mov    $0x2,%eax
  800d50:	89 d1                	mov    %edx,%ecx
  800d52:	89 d3                	mov    %edx,%ebx
  800d54:	89 d7                	mov    %edx,%edi
  800d56:	89 d6                	mov    %edx,%esi
  800d58:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d5a:	5b                   	pop    %ebx
  800d5b:	5e                   	pop    %esi
  800d5c:	5f                   	pop    %edi
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <sys_yield>:

void
sys_yield(void)
{
  800d5f:	f3 0f 1e fb          	endbr32 
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	57                   	push   %edi
  800d67:	56                   	push   %esi
  800d68:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d69:	ba 00 00 00 00       	mov    $0x0,%edx
  800d6e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d73:	89 d1                	mov    %edx,%ecx
  800d75:	89 d3                	mov    %edx,%ebx
  800d77:	89 d7                	mov    %edx,%edi
  800d79:	89 d6                	mov    %edx,%esi
  800d7b:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d7d:	5b                   	pop    %ebx
  800d7e:	5e                   	pop    %esi
  800d7f:	5f                   	pop    %edi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    

00800d82 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d82:	f3 0f 1e fb          	endbr32 
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	57                   	push   %edi
  800d8a:	56                   	push   %esi
  800d8b:	53                   	push   %ebx
  800d8c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d8f:	be 00 00 00 00       	mov    $0x0,%esi
  800d94:	8b 55 08             	mov    0x8(%ebp),%edx
  800d97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9a:	b8 04 00 00 00       	mov    $0x4,%eax
  800d9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da2:	89 f7                	mov    %esi,%edi
  800da4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800da6:	85 c0                	test   %eax,%eax
  800da8:	7f 08                	jg     800db2 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800daa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dad:	5b                   	pop    %ebx
  800dae:	5e                   	pop    %esi
  800daf:	5f                   	pop    %edi
  800db0:	5d                   	pop    %ebp
  800db1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800db2:	83 ec 0c             	sub    $0xc,%esp
  800db5:	50                   	push   %eax
  800db6:	6a 04                	push   $0x4
  800db8:	68 3f 24 80 00       	push   $0x80243f
  800dbd:	6a 23                	push   $0x23
  800dbf:	68 5c 24 80 00       	push   $0x80245c
  800dc4:	e8 87 f4 ff ff       	call   800250 <_panic>

00800dc9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dc9:	f3 0f 1e fb          	endbr32 
  800dcd:	55                   	push   %ebp
  800dce:	89 e5                	mov    %esp,%ebp
  800dd0:	57                   	push   %edi
  800dd1:	56                   	push   %esi
  800dd2:	53                   	push   %ebx
  800dd3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ddc:	b8 05 00 00 00       	mov    $0x5,%eax
  800de1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de7:	8b 75 18             	mov    0x18(%ebp),%esi
  800dea:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dec:	85 c0                	test   %eax,%eax
  800dee:	7f 08                	jg     800df8 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800df0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df3:	5b                   	pop    %ebx
  800df4:	5e                   	pop    %esi
  800df5:	5f                   	pop    %edi
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800df8:	83 ec 0c             	sub    $0xc,%esp
  800dfb:	50                   	push   %eax
  800dfc:	6a 05                	push   $0x5
  800dfe:	68 3f 24 80 00       	push   $0x80243f
  800e03:	6a 23                	push   $0x23
  800e05:	68 5c 24 80 00       	push   $0x80245c
  800e0a:	e8 41 f4 ff ff       	call   800250 <_panic>

00800e0f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e0f:	f3 0f 1e fb          	endbr32 
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	57                   	push   %edi
  800e17:	56                   	push   %esi
  800e18:	53                   	push   %ebx
  800e19:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e1c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e21:	8b 55 08             	mov    0x8(%ebp),%edx
  800e24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e27:	b8 06 00 00 00       	mov    $0x6,%eax
  800e2c:	89 df                	mov    %ebx,%edi
  800e2e:	89 de                	mov    %ebx,%esi
  800e30:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e32:	85 c0                	test   %eax,%eax
  800e34:	7f 08                	jg     800e3e <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e39:	5b                   	pop    %ebx
  800e3a:	5e                   	pop    %esi
  800e3b:	5f                   	pop    %edi
  800e3c:	5d                   	pop    %ebp
  800e3d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3e:	83 ec 0c             	sub    $0xc,%esp
  800e41:	50                   	push   %eax
  800e42:	6a 06                	push   $0x6
  800e44:	68 3f 24 80 00       	push   $0x80243f
  800e49:	6a 23                	push   $0x23
  800e4b:	68 5c 24 80 00       	push   $0x80245c
  800e50:	e8 fb f3 ff ff       	call   800250 <_panic>

00800e55 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e55:	f3 0f 1e fb          	endbr32 
  800e59:	55                   	push   %ebp
  800e5a:	89 e5                	mov    %esp,%ebp
  800e5c:	57                   	push   %edi
  800e5d:	56                   	push   %esi
  800e5e:	53                   	push   %ebx
  800e5f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e62:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e67:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6d:	b8 08 00 00 00       	mov    $0x8,%eax
  800e72:	89 df                	mov    %ebx,%edi
  800e74:	89 de                	mov    %ebx,%esi
  800e76:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e78:	85 c0                	test   %eax,%eax
  800e7a:	7f 08                	jg     800e84 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e7f:	5b                   	pop    %ebx
  800e80:	5e                   	pop    %esi
  800e81:	5f                   	pop    %edi
  800e82:	5d                   	pop    %ebp
  800e83:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e84:	83 ec 0c             	sub    $0xc,%esp
  800e87:	50                   	push   %eax
  800e88:	6a 08                	push   $0x8
  800e8a:	68 3f 24 80 00       	push   $0x80243f
  800e8f:	6a 23                	push   $0x23
  800e91:	68 5c 24 80 00       	push   $0x80245c
  800e96:	e8 b5 f3 ff ff       	call   800250 <_panic>

00800e9b <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e9b:	f3 0f 1e fb          	endbr32 
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	57                   	push   %edi
  800ea3:	56                   	push   %esi
  800ea4:	53                   	push   %ebx
  800ea5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ea8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ead:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb3:	b8 09 00 00 00       	mov    $0x9,%eax
  800eb8:	89 df                	mov    %ebx,%edi
  800eba:	89 de                	mov    %ebx,%esi
  800ebc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ebe:	85 c0                	test   %eax,%eax
  800ec0:	7f 08                	jg     800eca <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ec2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec5:	5b                   	pop    %ebx
  800ec6:	5e                   	pop    %esi
  800ec7:	5f                   	pop    %edi
  800ec8:	5d                   	pop    %ebp
  800ec9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800eca:	83 ec 0c             	sub    $0xc,%esp
  800ecd:	50                   	push   %eax
  800ece:	6a 09                	push   $0x9
  800ed0:	68 3f 24 80 00       	push   $0x80243f
  800ed5:	6a 23                	push   $0x23
  800ed7:	68 5c 24 80 00       	push   $0x80245c
  800edc:	e8 6f f3 ff ff       	call   800250 <_panic>

00800ee1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ee1:	f3 0f 1e fb          	endbr32 
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
  800ee8:	57                   	push   %edi
  800ee9:	56                   	push   %esi
  800eea:	53                   	push   %ebx
  800eeb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800eee:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800efe:	89 df                	mov    %ebx,%edi
  800f00:	89 de                	mov    %ebx,%esi
  800f02:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f04:	85 c0                	test   %eax,%eax
  800f06:	7f 08                	jg     800f10 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f0b:	5b                   	pop    %ebx
  800f0c:	5e                   	pop    %esi
  800f0d:	5f                   	pop    %edi
  800f0e:	5d                   	pop    %ebp
  800f0f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f10:	83 ec 0c             	sub    $0xc,%esp
  800f13:	50                   	push   %eax
  800f14:	6a 0a                	push   $0xa
  800f16:	68 3f 24 80 00       	push   $0x80243f
  800f1b:	6a 23                	push   $0x23
  800f1d:	68 5c 24 80 00       	push   $0x80245c
  800f22:	e8 29 f3 ff ff       	call   800250 <_panic>

00800f27 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f27:	f3 0f 1e fb          	endbr32 
  800f2b:	55                   	push   %ebp
  800f2c:	89 e5                	mov    %esp,%ebp
  800f2e:	57                   	push   %edi
  800f2f:	56                   	push   %esi
  800f30:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f31:	8b 55 08             	mov    0x8(%ebp),%edx
  800f34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f37:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f3c:	be 00 00 00 00       	mov    $0x0,%esi
  800f41:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f44:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f47:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f49:	5b                   	pop    %ebx
  800f4a:	5e                   	pop    %esi
  800f4b:	5f                   	pop    %edi
  800f4c:	5d                   	pop    %ebp
  800f4d:	c3                   	ret    

00800f4e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f4e:	f3 0f 1e fb          	endbr32 
  800f52:	55                   	push   %ebp
  800f53:	89 e5                	mov    %esp,%ebp
  800f55:	57                   	push   %edi
  800f56:	56                   	push   %esi
  800f57:	53                   	push   %ebx
  800f58:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f5b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f60:	8b 55 08             	mov    0x8(%ebp),%edx
  800f63:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f68:	89 cb                	mov    %ecx,%ebx
  800f6a:	89 cf                	mov    %ecx,%edi
  800f6c:	89 ce                	mov    %ecx,%esi
  800f6e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f70:	85 c0                	test   %eax,%eax
  800f72:	7f 08                	jg     800f7c <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f77:	5b                   	pop    %ebx
  800f78:	5e                   	pop    %esi
  800f79:	5f                   	pop    %edi
  800f7a:	5d                   	pop    %ebp
  800f7b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f7c:	83 ec 0c             	sub    $0xc,%esp
  800f7f:	50                   	push   %eax
  800f80:	6a 0d                	push   $0xd
  800f82:	68 3f 24 80 00       	push   $0x80243f
  800f87:	6a 23                	push   $0x23
  800f89:	68 5c 24 80 00       	push   $0x80245c
  800f8e:	e8 bd f2 ff ff       	call   800250 <_panic>

00800f93 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f93:	f3 0f 1e fb          	endbr32 
  800f97:	55                   	push   %ebp
  800f98:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9d:	05 00 00 00 30       	add    $0x30000000,%eax
  800fa2:	c1 e8 0c             	shr    $0xc,%eax
}
  800fa5:	5d                   	pop    %ebp
  800fa6:	c3                   	ret    

00800fa7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800fa7:	f3 0f 1e fb          	endbr32 
  800fab:	55                   	push   %ebp
  800fac:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fae:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb1:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800fb6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800fbb:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800fc0:	5d                   	pop    %ebp
  800fc1:	c3                   	ret    

00800fc2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800fc2:	f3 0f 1e fb          	endbr32 
  800fc6:	55                   	push   %ebp
  800fc7:	89 e5                	mov    %esp,%ebp
  800fc9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800fce:	89 c2                	mov    %eax,%edx
  800fd0:	c1 ea 16             	shr    $0x16,%edx
  800fd3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fda:	f6 c2 01             	test   $0x1,%dl
  800fdd:	74 2d                	je     80100c <fd_alloc+0x4a>
  800fdf:	89 c2                	mov    %eax,%edx
  800fe1:	c1 ea 0c             	shr    $0xc,%edx
  800fe4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800feb:	f6 c2 01             	test   $0x1,%dl
  800fee:	74 1c                	je     80100c <fd_alloc+0x4a>
  800ff0:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800ff5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ffa:	75 d2                	jne    800fce <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ffc:	8b 45 08             	mov    0x8(%ebp),%eax
  800fff:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801005:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80100a:	eb 0a                	jmp    801016 <fd_alloc+0x54>
			*fd_store = fd;
  80100c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80100f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801011:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801016:	5d                   	pop    %ebp
  801017:	c3                   	ret    

00801018 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801018:	f3 0f 1e fb          	endbr32 
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801022:	83 f8 1f             	cmp    $0x1f,%eax
  801025:	77 30                	ja     801057 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801027:	c1 e0 0c             	shl    $0xc,%eax
  80102a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80102f:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801035:	f6 c2 01             	test   $0x1,%dl
  801038:	74 24                	je     80105e <fd_lookup+0x46>
  80103a:	89 c2                	mov    %eax,%edx
  80103c:	c1 ea 0c             	shr    $0xc,%edx
  80103f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801046:	f6 c2 01             	test   $0x1,%dl
  801049:	74 1a                	je     801065 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80104b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80104e:	89 02                	mov    %eax,(%edx)
	return 0;
  801050:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801055:	5d                   	pop    %ebp
  801056:	c3                   	ret    
		return -E_INVAL;
  801057:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80105c:	eb f7                	jmp    801055 <fd_lookup+0x3d>
		return -E_INVAL;
  80105e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801063:	eb f0                	jmp    801055 <fd_lookup+0x3d>
  801065:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80106a:	eb e9                	jmp    801055 <fd_lookup+0x3d>

0080106c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80106c:	f3 0f 1e fb          	endbr32 
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	83 ec 08             	sub    $0x8,%esp
  801076:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801079:	ba e8 24 80 00       	mov    $0x8024e8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80107e:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  801083:	39 08                	cmp    %ecx,(%eax)
  801085:	74 33                	je     8010ba <dev_lookup+0x4e>
  801087:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80108a:	8b 02                	mov    (%edx),%eax
  80108c:	85 c0                	test   %eax,%eax
  80108e:	75 f3                	jne    801083 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801090:	a1 04 40 80 00       	mov    0x804004,%eax
  801095:	8b 40 48             	mov    0x48(%eax),%eax
  801098:	83 ec 04             	sub    $0x4,%esp
  80109b:	51                   	push   %ecx
  80109c:	50                   	push   %eax
  80109d:	68 6c 24 80 00       	push   $0x80246c
  8010a2:	e8 90 f2 ff ff       	call   800337 <cprintf>
	*dev = 0;
  8010a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010aa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8010b0:	83 c4 10             	add    $0x10,%esp
  8010b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8010b8:	c9                   	leave  
  8010b9:	c3                   	ret    
			*dev = devtab[i];
  8010ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010bd:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c4:	eb f2                	jmp    8010b8 <dev_lookup+0x4c>

008010c6 <fd_close>:
{
  8010c6:	f3 0f 1e fb          	endbr32 
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	57                   	push   %edi
  8010ce:	56                   	push   %esi
  8010cf:	53                   	push   %ebx
  8010d0:	83 ec 24             	sub    $0x24,%esp
  8010d3:	8b 75 08             	mov    0x8(%ebp),%esi
  8010d6:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010d9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010dc:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010dd:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8010e3:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010e6:	50                   	push   %eax
  8010e7:	e8 2c ff ff ff       	call   801018 <fd_lookup>
  8010ec:	89 c3                	mov    %eax,%ebx
  8010ee:	83 c4 10             	add    $0x10,%esp
  8010f1:	85 c0                	test   %eax,%eax
  8010f3:	78 05                	js     8010fa <fd_close+0x34>
	    || fd != fd2)
  8010f5:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8010f8:	74 16                	je     801110 <fd_close+0x4a>
		return (must_exist ? r : 0);
  8010fa:	89 f8                	mov    %edi,%eax
  8010fc:	84 c0                	test   %al,%al
  8010fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801103:	0f 44 d8             	cmove  %eax,%ebx
}
  801106:	89 d8                	mov    %ebx,%eax
  801108:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80110b:	5b                   	pop    %ebx
  80110c:	5e                   	pop    %esi
  80110d:	5f                   	pop    %edi
  80110e:	5d                   	pop    %ebp
  80110f:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801110:	83 ec 08             	sub    $0x8,%esp
  801113:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801116:	50                   	push   %eax
  801117:	ff 36                	pushl  (%esi)
  801119:	e8 4e ff ff ff       	call   80106c <dev_lookup>
  80111e:	89 c3                	mov    %eax,%ebx
  801120:	83 c4 10             	add    $0x10,%esp
  801123:	85 c0                	test   %eax,%eax
  801125:	78 1a                	js     801141 <fd_close+0x7b>
		if (dev->dev_close)
  801127:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80112a:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80112d:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801132:	85 c0                	test   %eax,%eax
  801134:	74 0b                	je     801141 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  801136:	83 ec 0c             	sub    $0xc,%esp
  801139:	56                   	push   %esi
  80113a:	ff d0                	call   *%eax
  80113c:	89 c3                	mov    %eax,%ebx
  80113e:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801141:	83 ec 08             	sub    $0x8,%esp
  801144:	56                   	push   %esi
  801145:	6a 00                	push   $0x0
  801147:	e8 c3 fc ff ff       	call   800e0f <sys_page_unmap>
	return r;
  80114c:	83 c4 10             	add    $0x10,%esp
  80114f:	eb b5                	jmp    801106 <fd_close+0x40>

00801151 <close>:

int
close(int fdnum)
{
  801151:	f3 0f 1e fb          	endbr32 
  801155:	55                   	push   %ebp
  801156:	89 e5                	mov    %esp,%ebp
  801158:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80115b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80115e:	50                   	push   %eax
  80115f:	ff 75 08             	pushl  0x8(%ebp)
  801162:	e8 b1 fe ff ff       	call   801018 <fd_lookup>
  801167:	83 c4 10             	add    $0x10,%esp
  80116a:	85 c0                	test   %eax,%eax
  80116c:	79 02                	jns    801170 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  80116e:	c9                   	leave  
  80116f:	c3                   	ret    
		return fd_close(fd, 1);
  801170:	83 ec 08             	sub    $0x8,%esp
  801173:	6a 01                	push   $0x1
  801175:	ff 75 f4             	pushl  -0xc(%ebp)
  801178:	e8 49 ff ff ff       	call   8010c6 <fd_close>
  80117d:	83 c4 10             	add    $0x10,%esp
  801180:	eb ec                	jmp    80116e <close+0x1d>

00801182 <close_all>:

void
close_all(void)
{
  801182:	f3 0f 1e fb          	endbr32 
  801186:	55                   	push   %ebp
  801187:	89 e5                	mov    %esp,%ebp
  801189:	53                   	push   %ebx
  80118a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80118d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801192:	83 ec 0c             	sub    $0xc,%esp
  801195:	53                   	push   %ebx
  801196:	e8 b6 ff ff ff       	call   801151 <close>
	for (i = 0; i < MAXFD; i++)
  80119b:	83 c3 01             	add    $0x1,%ebx
  80119e:	83 c4 10             	add    $0x10,%esp
  8011a1:	83 fb 20             	cmp    $0x20,%ebx
  8011a4:	75 ec                	jne    801192 <close_all+0x10>
}
  8011a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011a9:	c9                   	leave  
  8011aa:	c3                   	ret    

008011ab <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8011ab:	f3 0f 1e fb          	endbr32 
  8011af:	55                   	push   %ebp
  8011b0:	89 e5                	mov    %esp,%ebp
  8011b2:	57                   	push   %edi
  8011b3:	56                   	push   %esi
  8011b4:	53                   	push   %ebx
  8011b5:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8011b8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011bb:	50                   	push   %eax
  8011bc:	ff 75 08             	pushl  0x8(%ebp)
  8011bf:	e8 54 fe ff ff       	call   801018 <fd_lookup>
  8011c4:	89 c3                	mov    %eax,%ebx
  8011c6:	83 c4 10             	add    $0x10,%esp
  8011c9:	85 c0                	test   %eax,%eax
  8011cb:	0f 88 81 00 00 00    	js     801252 <dup+0xa7>
		return r;
	close(newfdnum);
  8011d1:	83 ec 0c             	sub    $0xc,%esp
  8011d4:	ff 75 0c             	pushl  0xc(%ebp)
  8011d7:	e8 75 ff ff ff       	call   801151 <close>

	newfd = INDEX2FD(newfdnum);
  8011dc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011df:	c1 e6 0c             	shl    $0xc,%esi
  8011e2:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8011e8:	83 c4 04             	add    $0x4,%esp
  8011eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ee:	e8 b4 fd ff ff       	call   800fa7 <fd2data>
  8011f3:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8011f5:	89 34 24             	mov    %esi,(%esp)
  8011f8:	e8 aa fd ff ff       	call   800fa7 <fd2data>
  8011fd:	83 c4 10             	add    $0x10,%esp
  801200:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801202:	89 d8                	mov    %ebx,%eax
  801204:	c1 e8 16             	shr    $0x16,%eax
  801207:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80120e:	a8 01                	test   $0x1,%al
  801210:	74 11                	je     801223 <dup+0x78>
  801212:	89 d8                	mov    %ebx,%eax
  801214:	c1 e8 0c             	shr    $0xc,%eax
  801217:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80121e:	f6 c2 01             	test   $0x1,%dl
  801221:	75 39                	jne    80125c <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801223:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801226:	89 d0                	mov    %edx,%eax
  801228:	c1 e8 0c             	shr    $0xc,%eax
  80122b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801232:	83 ec 0c             	sub    $0xc,%esp
  801235:	25 07 0e 00 00       	and    $0xe07,%eax
  80123a:	50                   	push   %eax
  80123b:	56                   	push   %esi
  80123c:	6a 00                	push   $0x0
  80123e:	52                   	push   %edx
  80123f:	6a 00                	push   $0x0
  801241:	e8 83 fb ff ff       	call   800dc9 <sys_page_map>
  801246:	89 c3                	mov    %eax,%ebx
  801248:	83 c4 20             	add    $0x20,%esp
  80124b:	85 c0                	test   %eax,%eax
  80124d:	78 31                	js     801280 <dup+0xd5>
		goto err;

	return newfdnum;
  80124f:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801252:	89 d8                	mov    %ebx,%eax
  801254:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801257:	5b                   	pop    %ebx
  801258:	5e                   	pop    %esi
  801259:	5f                   	pop    %edi
  80125a:	5d                   	pop    %ebp
  80125b:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80125c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801263:	83 ec 0c             	sub    $0xc,%esp
  801266:	25 07 0e 00 00       	and    $0xe07,%eax
  80126b:	50                   	push   %eax
  80126c:	57                   	push   %edi
  80126d:	6a 00                	push   $0x0
  80126f:	53                   	push   %ebx
  801270:	6a 00                	push   $0x0
  801272:	e8 52 fb ff ff       	call   800dc9 <sys_page_map>
  801277:	89 c3                	mov    %eax,%ebx
  801279:	83 c4 20             	add    $0x20,%esp
  80127c:	85 c0                	test   %eax,%eax
  80127e:	79 a3                	jns    801223 <dup+0x78>
	sys_page_unmap(0, newfd);
  801280:	83 ec 08             	sub    $0x8,%esp
  801283:	56                   	push   %esi
  801284:	6a 00                	push   $0x0
  801286:	e8 84 fb ff ff       	call   800e0f <sys_page_unmap>
	sys_page_unmap(0, nva);
  80128b:	83 c4 08             	add    $0x8,%esp
  80128e:	57                   	push   %edi
  80128f:	6a 00                	push   $0x0
  801291:	e8 79 fb ff ff       	call   800e0f <sys_page_unmap>
	return r;
  801296:	83 c4 10             	add    $0x10,%esp
  801299:	eb b7                	jmp    801252 <dup+0xa7>

0080129b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80129b:	f3 0f 1e fb          	endbr32 
  80129f:	55                   	push   %ebp
  8012a0:	89 e5                	mov    %esp,%ebp
  8012a2:	53                   	push   %ebx
  8012a3:	83 ec 1c             	sub    $0x1c,%esp
  8012a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ac:	50                   	push   %eax
  8012ad:	53                   	push   %ebx
  8012ae:	e8 65 fd ff ff       	call   801018 <fd_lookup>
  8012b3:	83 c4 10             	add    $0x10,%esp
  8012b6:	85 c0                	test   %eax,%eax
  8012b8:	78 3f                	js     8012f9 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ba:	83 ec 08             	sub    $0x8,%esp
  8012bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c0:	50                   	push   %eax
  8012c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c4:	ff 30                	pushl  (%eax)
  8012c6:	e8 a1 fd ff ff       	call   80106c <dev_lookup>
  8012cb:	83 c4 10             	add    $0x10,%esp
  8012ce:	85 c0                	test   %eax,%eax
  8012d0:	78 27                	js     8012f9 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8012d2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012d5:	8b 42 08             	mov    0x8(%edx),%eax
  8012d8:	83 e0 03             	and    $0x3,%eax
  8012db:	83 f8 01             	cmp    $0x1,%eax
  8012de:	74 1e                	je     8012fe <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8012e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e3:	8b 40 08             	mov    0x8(%eax),%eax
  8012e6:	85 c0                	test   %eax,%eax
  8012e8:	74 35                	je     80131f <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8012ea:	83 ec 04             	sub    $0x4,%esp
  8012ed:	ff 75 10             	pushl  0x10(%ebp)
  8012f0:	ff 75 0c             	pushl  0xc(%ebp)
  8012f3:	52                   	push   %edx
  8012f4:	ff d0                	call   *%eax
  8012f6:	83 c4 10             	add    $0x10,%esp
}
  8012f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012fc:	c9                   	leave  
  8012fd:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8012fe:	a1 04 40 80 00       	mov    0x804004,%eax
  801303:	8b 40 48             	mov    0x48(%eax),%eax
  801306:	83 ec 04             	sub    $0x4,%esp
  801309:	53                   	push   %ebx
  80130a:	50                   	push   %eax
  80130b:	68 ad 24 80 00       	push   $0x8024ad
  801310:	e8 22 f0 ff ff       	call   800337 <cprintf>
		return -E_INVAL;
  801315:	83 c4 10             	add    $0x10,%esp
  801318:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80131d:	eb da                	jmp    8012f9 <read+0x5e>
		return -E_NOT_SUPP;
  80131f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801324:	eb d3                	jmp    8012f9 <read+0x5e>

00801326 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801326:	f3 0f 1e fb          	endbr32 
  80132a:	55                   	push   %ebp
  80132b:	89 e5                	mov    %esp,%ebp
  80132d:	57                   	push   %edi
  80132e:	56                   	push   %esi
  80132f:	53                   	push   %ebx
  801330:	83 ec 0c             	sub    $0xc,%esp
  801333:	8b 7d 08             	mov    0x8(%ebp),%edi
  801336:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801339:	bb 00 00 00 00       	mov    $0x0,%ebx
  80133e:	eb 02                	jmp    801342 <readn+0x1c>
  801340:	01 c3                	add    %eax,%ebx
  801342:	39 f3                	cmp    %esi,%ebx
  801344:	73 21                	jae    801367 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801346:	83 ec 04             	sub    $0x4,%esp
  801349:	89 f0                	mov    %esi,%eax
  80134b:	29 d8                	sub    %ebx,%eax
  80134d:	50                   	push   %eax
  80134e:	89 d8                	mov    %ebx,%eax
  801350:	03 45 0c             	add    0xc(%ebp),%eax
  801353:	50                   	push   %eax
  801354:	57                   	push   %edi
  801355:	e8 41 ff ff ff       	call   80129b <read>
		if (m < 0)
  80135a:	83 c4 10             	add    $0x10,%esp
  80135d:	85 c0                	test   %eax,%eax
  80135f:	78 04                	js     801365 <readn+0x3f>
			return m;
		if (m == 0)
  801361:	75 dd                	jne    801340 <readn+0x1a>
  801363:	eb 02                	jmp    801367 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801365:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801367:	89 d8                	mov    %ebx,%eax
  801369:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80136c:	5b                   	pop    %ebx
  80136d:	5e                   	pop    %esi
  80136e:	5f                   	pop    %edi
  80136f:	5d                   	pop    %ebp
  801370:	c3                   	ret    

00801371 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801371:	f3 0f 1e fb          	endbr32 
  801375:	55                   	push   %ebp
  801376:	89 e5                	mov    %esp,%ebp
  801378:	53                   	push   %ebx
  801379:	83 ec 1c             	sub    $0x1c,%esp
  80137c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80137f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801382:	50                   	push   %eax
  801383:	53                   	push   %ebx
  801384:	e8 8f fc ff ff       	call   801018 <fd_lookup>
  801389:	83 c4 10             	add    $0x10,%esp
  80138c:	85 c0                	test   %eax,%eax
  80138e:	78 3a                	js     8013ca <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801390:	83 ec 08             	sub    $0x8,%esp
  801393:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801396:	50                   	push   %eax
  801397:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80139a:	ff 30                	pushl  (%eax)
  80139c:	e8 cb fc ff ff       	call   80106c <dev_lookup>
  8013a1:	83 c4 10             	add    $0x10,%esp
  8013a4:	85 c0                	test   %eax,%eax
  8013a6:	78 22                	js     8013ca <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ab:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013af:	74 1e                	je     8013cf <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8013b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013b4:	8b 52 0c             	mov    0xc(%edx),%edx
  8013b7:	85 d2                	test   %edx,%edx
  8013b9:	74 35                	je     8013f0 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8013bb:	83 ec 04             	sub    $0x4,%esp
  8013be:	ff 75 10             	pushl  0x10(%ebp)
  8013c1:	ff 75 0c             	pushl  0xc(%ebp)
  8013c4:	50                   	push   %eax
  8013c5:	ff d2                	call   *%edx
  8013c7:	83 c4 10             	add    $0x10,%esp
}
  8013ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013cd:	c9                   	leave  
  8013ce:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013cf:	a1 04 40 80 00       	mov    0x804004,%eax
  8013d4:	8b 40 48             	mov    0x48(%eax),%eax
  8013d7:	83 ec 04             	sub    $0x4,%esp
  8013da:	53                   	push   %ebx
  8013db:	50                   	push   %eax
  8013dc:	68 c9 24 80 00       	push   $0x8024c9
  8013e1:	e8 51 ef ff ff       	call   800337 <cprintf>
		return -E_INVAL;
  8013e6:	83 c4 10             	add    $0x10,%esp
  8013e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013ee:	eb da                	jmp    8013ca <write+0x59>
		return -E_NOT_SUPP;
  8013f0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013f5:	eb d3                	jmp    8013ca <write+0x59>

008013f7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8013f7:	f3 0f 1e fb          	endbr32 
  8013fb:	55                   	push   %ebp
  8013fc:	89 e5                	mov    %esp,%ebp
  8013fe:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801401:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801404:	50                   	push   %eax
  801405:	ff 75 08             	pushl  0x8(%ebp)
  801408:	e8 0b fc ff ff       	call   801018 <fd_lookup>
  80140d:	83 c4 10             	add    $0x10,%esp
  801410:	85 c0                	test   %eax,%eax
  801412:	78 0e                	js     801422 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801414:	8b 55 0c             	mov    0xc(%ebp),%edx
  801417:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80141a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80141d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801422:	c9                   	leave  
  801423:	c3                   	ret    

00801424 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801424:	f3 0f 1e fb          	endbr32 
  801428:	55                   	push   %ebp
  801429:	89 e5                	mov    %esp,%ebp
  80142b:	53                   	push   %ebx
  80142c:	83 ec 1c             	sub    $0x1c,%esp
  80142f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801432:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801435:	50                   	push   %eax
  801436:	53                   	push   %ebx
  801437:	e8 dc fb ff ff       	call   801018 <fd_lookup>
  80143c:	83 c4 10             	add    $0x10,%esp
  80143f:	85 c0                	test   %eax,%eax
  801441:	78 37                	js     80147a <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801443:	83 ec 08             	sub    $0x8,%esp
  801446:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801449:	50                   	push   %eax
  80144a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144d:	ff 30                	pushl  (%eax)
  80144f:	e8 18 fc ff ff       	call   80106c <dev_lookup>
  801454:	83 c4 10             	add    $0x10,%esp
  801457:	85 c0                	test   %eax,%eax
  801459:	78 1f                	js     80147a <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80145b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80145e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801462:	74 1b                	je     80147f <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801464:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801467:	8b 52 18             	mov    0x18(%edx),%edx
  80146a:	85 d2                	test   %edx,%edx
  80146c:	74 32                	je     8014a0 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80146e:	83 ec 08             	sub    $0x8,%esp
  801471:	ff 75 0c             	pushl  0xc(%ebp)
  801474:	50                   	push   %eax
  801475:	ff d2                	call   *%edx
  801477:	83 c4 10             	add    $0x10,%esp
}
  80147a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80147d:	c9                   	leave  
  80147e:	c3                   	ret    
			thisenv->env_id, fdnum);
  80147f:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801484:	8b 40 48             	mov    0x48(%eax),%eax
  801487:	83 ec 04             	sub    $0x4,%esp
  80148a:	53                   	push   %ebx
  80148b:	50                   	push   %eax
  80148c:	68 8c 24 80 00       	push   $0x80248c
  801491:	e8 a1 ee ff ff       	call   800337 <cprintf>
		return -E_INVAL;
  801496:	83 c4 10             	add    $0x10,%esp
  801499:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80149e:	eb da                	jmp    80147a <ftruncate+0x56>
		return -E_NOT_SUPP;
  8014a0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014a5:	eb d3                	jmp    80147a <ftruncate+0x56>

008014a7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8014a7:	f3 0f 1e fb          	endbr32 
  8014ab:	55                   	push   %ebp
  8014ac:	89 e5                	mov    %esp,%ebp
  8014ae:	53                   	push   %ebx
  8014af:	83 ec 1c             	sub    $0x1c,%esp
  8014b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014b8:	50                   	push   %eax
  8014b9:	ff 75 08             	pushl  0x8(%ebp)
  8014bc:	e8 57 fb ff ff       	call   801018 <fd_lookup>
  8014c1:	83 c4 10             	add    $0x10,%esp
  8014c4:	85 c0                	test   %eax,%eax
  8014c6:	78 4b                	js     801513 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014c8:	83 ec 08             	sub    $0x8,%esp
  8014cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ce:	50                   	push   %eax
  8014cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d2:	ff 30                	pushl  (%eax)
  8014d4:	e8 93 fb ff ff       	call   80106c <dev_lookup>
  8014d9:	83 c4 10             	add    $0x10,%esp
  8014dc:	85 c0                	test   %eax,%eax
  8014de:	78 33                	js     801513 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8014e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014e3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8014e7:	74 2f                	je     801518 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8014e9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8014ec:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8014f3:	00 00 00 
	stat->st_isdir = 0;
  8014f6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014fd:	00 00 00 
	stat->st_dev = dev;
  801500:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801506:	83 ec 08             	sub    $0x8,%esp
  801509:	53                   	push   %ebx
  80150a:	ff 75 f0             	pushl  -0x10(%ebp)
  80150d:	ff 50 14             	call   *0x14(%eax)
  801510:	83 c4 10             	add    $0x10,%esp
}
  801513:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801516:	c9                   	leave  
  801517:	c3                   	ret    
		return -E_NOT_SUPP;
  801518:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80151d:	eb f4                	jmp    801513 <fstat+0x6c>

0080151f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80151f:	f3 0f 1e fb          	endbr32 
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
  801526:	56                   	push   %esi
  801527:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801528:	83 ec 08             	sub    $0x8,%esp
  80152b:	6a 00                	push   $0x0
  80152d:	ff 75 08             	pushl  0x8(%ebp)
  801530:	e8 fb 01 00 00       	call   801730 <open>
  801535:	89 c3                	mov    %eax,%ebx
  801537:	83 c4 10             	add    $0x10,%esp
  80153a:	85 c0                	test   %eax,%eax
  80153c:	78 1b                	js     801559 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  80153e:	83 ec 08             	sub    $0x8,%esp
  801541:	ff 75 0c             	pushl  0xc(%ebp)
  801544:	50                   	push   %eax
  801545:	e8 5d ff ff ff       	call   8014a7 <fstat>
  80154a:	89 c6                	mov    %eax,%esi
	close(fd);
  80154c:	89 1c 24             	mov    %ebx,(%esp)
  80154f:	e8 fd fb ff ff       	call   801151 <close>
	return r;
  801554:	83 c4 10             	add    $0x10,%esp
  801557:	89 f3                	mov    %esi,%ebx
}
  801559:	89 d8                	mov    %ebx,%eax
  80155b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80155e:	5b                   	pop    %ebx
  80155f:	5e                   	pop    %esi
  801560:	5d                   	pop    %ebp
  801561:	c3                   	ret    

00801562 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801562:	55                   	push   %ebp
  801563:	89 e5                	mov    %esp,%ebp
  801565:	56                   	push   %esi
  801566:	53                   	push   %ebx
  801567:	89 c6                	mov    %eax,%esi
  801569:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80156b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801572:	74 27                	je     80159b <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801574:	6a 07                	push   $0x7
  801576:	68 00 50 80 00       	push   $0x805000
  80157b:	56                   	push   %esi
  80157c:	ff 35 00 40 80 00    	pushl  0x804000
  801582:	e8 a8 07 00 00       	call   801d2f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801587:	83 c4 0c             	add    $0xc,%esp
  80158a:	6a 00                	push   $0x0
  80158c:	53                   	push   %ebx
  80158d:	6a 00                	push   $0x0
  80158f:	e8 44 07 00 00       	call   801cd8 <ipc_recv>
}
  801594:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801597:	5b                   	pop    %ebx
  801598:	5e                   	pop    %esi
  801599:	5d                   	pop    %ebp
  80159a:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80159b:	83 ec 0c             	sub    $0xc,%esp
  80159e:	6a 01                	push   $0x1
  8015a0:	e8 f0 07 00 00       	call   801d95 <ipc_find_env>
  8015a5:	a3 00 40 80 00       	mov    %eax,0x804000
  8015aa:	83 c4 10             	add    $0x10,%esp
  8015ad:	eb c5                	jmp    801574 <fsipc+0x12>

008015af <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8015af:	f3 0f 1e fb          	endbr32 
  8015b3:	55                   	push   %ebp
  8015b4:	89 e5                	mov    %esp,%ebp
  8015b6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8015b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015bc:	8b 40 0c             	mov    0xc(%eax),%eax
  8015bf:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8015c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015c7:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8015cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d1:	b8 02 00 00 00       	mov    $0x2,%eax
  8015d6:	e8 87 ff ff ff       	call   801562 <fsipc>
}
  8015db:	c9                   	leave  
  8015dc:	c3                   	ret    

008015dd <devfile_flush>:
{
  8015dd:	f3 0f 1e fb          	endbr32 
  8015e1:	55                   	push   %ebp
  8015e2:	89 e5                	mov    %esp,%ebp
  8015e4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8015e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8015ed:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8015f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f7:	b8 06 00 00 00       	mov    $0x6,%eax
  8015fc:	e8 61 ff ff ff       	call   801562 <fsipc>
}
  801601:	c9                   	leave  
  801602:	c3                   	ret    

00801603 <devfile_stat>:
{
  801603:	f3 0f 1e fb          	endbr32 
  801607:	55                   	push   %ebp
  801608:	89 e5                	mov    %esp,%ebp
  80160a:	53                   	push   %ebx
  80160b:	83 ec 04             	sub    $0x4,%esp
  80160e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801611:	8b 45 08             	mov    0x8(%ebp),%eax
  801614:	8b 40 0c             	mov    0xc(%eax),%eax
  801617:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80161c:	ba 00 00 00 00       	mov    $0x0,%edx
  801621:	b8 05 00 00 00       	mov    $0x5,%eax
  801626:	e8 37 ff ff ff       	call   801562 <fsipc>
  80162b:	85 c0                	test   %eax,%eax
  80162d:	78 2c                	js     80165b <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80162f:	83 ec 08             	sub    $0x8,%esp
  801632:	68 00 50 80 00       	push   $0x805000
  801637:	53                   	push   %ebx
  801638:	e8 03 f3 ff ff       	call   800940 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80163d:	a1 80 50 80 00       	mov    0x805080,%eax
  801642:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801648:	a1 84 50 80 00       	mov    0x805084,%eax
  80164d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801653:	83 c4 10             	add    $0x10,%esp
  801656:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80165b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165e:	c9                   	leave  
  80165f:	c3                   	ret    

00801660 <devfile_write>:
{
  801660:	f3 0f 1e fb          	endbr32 
  801664:	55                   	push   %ebp
  801665:	89 e5                	mov    %esp,%ebp
  801667:	83 ec 0c             	sub    $0xc,%esp
  80166a:	8b 45 10             	mov    0x10(%ebp),%eax
	n = n > size_max ? size_max : n;
  80166d:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801672:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801677:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80167a:	8b 55 08             	mov    0x8(%ebp),%edx
  80167d:	8b 52 0c             	mov    0xc(%edx),%edx
  801680:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801686:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80168b:	50                   	push   %eax
  80168c:	ff 75 0c             	pushl  0xc(%ebp)
  80168f:	68 08 50 80 00       	push   $0x805008
  801694:	e8 5d f4 ff ff       	call   800af6 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801699:	ba 00 00 00 00       	mov    $0x0,%edx
  80169e:	b8 04 00 00 00       	mov    $0x4,%eax
  8016a3:	e8 ba fe ff ff       	call   801562 <fsipc>
}
  8016a8:	c9                   	leave  
  8016a9:	c3                   	ret    

008016aa <devfile_read>:
{
  8016aa:	f3 0f 1e fb          	endbr32 
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	56                   	push   %esi
  8016b2:	53                   	push   %ebx
  8016b3:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b9:	8b 40 0c             	mov    0xc(%eax),%eax
  8016bc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8016c1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016cc:	b8 03 00 00 00       	mov    $0x3,%eax
  8016d1:	e8 8c fe ff ff       	call   801562 <fsipc>
  8016d6:	89 c3                	mov    %eax,%ebx
  8016d8:	85 c0                	test   %eax,%eax
  8016da:	78 1f                	js     8016fb <devfile_read+0x51>
	assert(r <= n);
  8016dc:	39 f0                	cmp    %esi,%eax
  8016de:	77 24                	ja     801704 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8016e0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8016e5:	7f 33                	jg     80171a <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8016e7:	83 ec 04             	sub    $0x4,%esp
  8016ea:	50                   	push   %eax
  8016eb:	68 00 50 80 00       	push   $0x805000
  8016f0:	ff 75 0c             	pushl  0xc(%ebp)
  8016f3:	e8 fe f3 ff ff       	call   800af6 <memmove>
	return r;
  8016f8:	83 c4 10             	add    $0x10,%esp
}
  8016fb:	89 d8                	mov    %ebx,%eax
  8016fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801700:	5b                   	pop    %ebx
  801701:	5e                   	pop    %esi
  801702:	5d                   	pop    %ebp
  801703:	c3                   	ret    
	assert(r <= n);
  801704:	68 f8 24 80 00       	push   $0x8024f8
  801709:	68 ff 24 80 00       	push   $0x8024ff
  80170e:	6a 7c                	push   $0x7c
  801710:	68 14 25 80 00       	push   $0x802514
  801715:	e8 36 eb ff ff       	call   800250 <_panic>
	assert(r <= PGSIZE);
  80171a:	68 1f 25 80 00       	push   $0x80251f
  80171f:	68 ff 24 80 00       	push   $0x8024ff
  801724:	6a 7d                	push   $0x7d
  801726:	68 14 25 80 00       	push   $0x802514
  80172b:	e8 20 eb ff ff       	call   800250 <_panic>

00801730 <open>:
{
  801730:	f3 0f 1e fb          	endbr32 
  801734:	55                   	push   %ebp
  801735:	89 e5                	mov    %esp,%ebp
  801737:	56                   	push   %esi
  801738:	53                   	push   %ebx
  801739:	83 ec 1c             	sub    $0x1c,%esp
  80173c:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80173f:	56                   	push   %esi
  801740:	e8 b8 f1 ff ff       	call   8008fd <strlen>
  801745:	83 c4 10             	add    $0x10,%esp
  801748:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80174d:	7f 6c                	jg     8017bb <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  80174f:	83 ec 0c             	sub    $0xc,%esp
  801752:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801755:	50                   	push   %eax
  801756:	e8 67 f8 ff ff       	call   800fc2 <fd_alloc>
  80175b:	89 c3                	mov    %eax,%ebx
  80175d:	83 c4 10             	add    $0x10,%esp
  801760:	85 c0                	test   %eax,%eax
  801762:	78 3c                	js     8017a0 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801764:	83 ec 08             	sub    $0x8,%esp
  801767:	56                   	push   %esi
  801768:	68 00 50 80 00       	push   $0x805000
  80176d:	e8 ce f1 ff ff       	call   800940 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801772:	8b 45 0c             	mov    0xc(%ebp),%eax
  801775:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80177a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80177d:	b8 01 00 00 00       	mov    $0x1,%eax
  801782:	e8 db fd ff ff       	call   801562 <fsipc>
  801787:	89 c3                	mov    %eax,%ebx
  801789:	83 c4 10             	add    $0x10,%esp
  80178c:	85 c0                	test   %eax,%eax
  80178e:	78 19                	js     8017a9 <open+0x79>
	return fd2num(fd);
  801790:	83 ec 0c             	sub    $0xc,%esp
  801793:	ff 75 f4             	pushl  -0xc(%ebp)
  801796:	e8 f8 f7 ff ff       	call   800f93 <fd2num>
  80179b:	89 c3                	mov    %eax,%ebx
  80179d:	83 c4 10             	add    $0x10,%esp
}
  8017a0:	89 d8                	mov    %ebx,%eax
  8017a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017a5:	5b                   	pop    %ebx
  8017a6:	5e                   	pop    %esi
  8017a7:	5d                   	pop    %ebp
  8017a8:	c3                   	ret    
		fd_close(fd, 0);
  8017a9:	83 ec 08             	sub    $0x8,%esp
  8017ac:	6a 00                	push   $0x0
  8017ae:	ff 75 f4             	pushl  -0xc(%ebp)
  8017b1:	e8 10 f9 ff ff       	call   8010c6 <fd_close>
		return r;
  8017b6:	83 c4 10             	add    $0x10,%esp
  8017b9:	eb e5                	jmp    8017a0 <open+0x70>
		return -E_BAD_PATH;
  8017bb:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8017c0:	eb de                	jmp    8017a0 <open+0x70>

008017c2 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8017c2:	f3 0f 1e fb          	endbr32 
  8017c6:	55                   	push   %ebp
  8017c7:	89 e5                	mov    %esp,%ebp
  8017c9:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d1:	b8 08 00 00 00       	mov    $0x8,%eax
  8017d6:	e8 87 fd ff ff       	call   801562 <fsipc>
}
  8017db:	c9                   	leave  
  8017dc:	c3                   	ret    

008017dd <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8017dd:	f3 0f 1e fb          	endbr32 
  8017e1:	55                   	push   %ebp
  8017e2:	89 e5                	mov    %esp,%ebp
  8017e4:	56                   	push   %esi
  8017e5:	53                   	push   %ebx
  8017e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8017e9:	83 ec 0c             	sub    $0xc,%esp
  8017ec:	ff 75 08             	pushl  0x8(%ebp)
  8017ef:	e8 b3 f7 ff ff       	call   800fa7 <fd2data>
  8017f4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8017f6:	83 c4 08             	add    $0x8,%esp
  8017f9:	68 2b 25 80 00       	push   $0x80252b
  8017fe:	53                   	push   %ebx
  8017ff:	e8 3c f1 ff ff       	call   800940 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801804:	8b 46 04             	mov    0x4(%esi),%eax
  801807:	2b 06                	sub    (%esi),%eax
  801809:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80180f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801816:	00 00 00 
	stat->st_dev = &devpipe;
  801819:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801820:	30 80 00 
	return 0;
}
  801823:	b8 00 00 00 00       	mov    $0x0,%eax
  801828:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80182b:	5b                   	pop    %ebx
  80182c:	5e                   	pop    %esi
  80182d:	5d                   	pop    %ebp
  80182e:	c3                   	ret    

0080182f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80182f:	f3 0f 1e fb          	endbr32 
  801833:	55                   	push   %ebp
  801834:	89 e5                	mov    %esp,%ebp
  801836:	53                   	push   %ebx
  801837:	83 ec 0c             	sub    $0xc,%esp
  80183a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80183d:	53                   	push   %ebx
  80183e:	6a 00                	push   $0x0
  801840:	e8 ca f5 ff ff       	call   800e0f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801845:	89 1c 24             	mov    %ebx,(%esp)
  801848:	e8 5a f7 ff ff       	call   800fa7 <fd2data>
  80184d:	83 c4 08             	add    $0x8,%esp
  801850:	50                   	push   %eax
  801851:	6a 00                	push   $0x0
  801853:	e8 b7 f5 ff ff       	call   800e0f <sys_page_unmap>
}
  801858:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80185b:	c9                   	leave  
  80185c:	c3                   	ret    

0080185d <_pipeisclosed>:
{
  80185d:	55                   	push   %ebp
  80185e:	89 e5                	mov    %esp,%ebp
  801860:	57                   	push   %edi
  801861:	56                   	push   %esi
  801862:	53                   	push   %ebx
  801863:	83 ec 1c             	sub    $0x1c,%esp
  801866:	89 c7                	mov    %eax,%edi
  801868:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80186a:	a1 04 40 80 00       	mov    0x804004,%eax
  80186f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801872:	83 ec 0c             	sub    $0xc,%esp
  801875:	57                   	push   %edi
  801876:	e8 57 05 00 00       	call   801dd2 <pageref>
  80187b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80187e:	89 34 24             	mov    %esi,(%esp)
  801881:	e8 4c 05 00 00       	call   801dd2 <pageref>
		nn = thisenv->env_runs;
  801886:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80188c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80188f:	83 c4 10             	add    $0x10,%esp
  801892:	39 cb                	cmp    %ecx,%ebx
  801894:	74 1b                	je     8018b1 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801896:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801899:	75 cf                	jne    80186a <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80189b:	8b 42 58             	mov    0x58(%edx),%eax
  80189e:	6a 01                	push   $0x1
  8018a0:	50                   	push   %eax
  8018a1:	53                   	push   %ebx
  8018a2:	68 32 25 80 00       	push   $0x802532
  8018a7:	e8 8b ea ff ff       	call   800337 <cprintf>
  8018ac:	83 c4 10             	add    $0x10,%esp
  8018af:	eb b9                	jmp    80186a <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8018b1:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8018b4:	0f 94 c0             	sete   %al
  8018b7:	0f b6 c0             	movzbl %al,%eax
}
  8018ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018bd:	5b                   	pop    %ebx
  8018be:	5e                   	pop    %esi
  8018bf:	5f                   	pop    %edi
  8018c0:	5d                   	pop    %ebp
  8018c1:	c3                   	ret    

008018c2 <devpipe_write>:
{
  8018c2:	f3 0f 1e fb          	endbr32 
  8018c6:	55                   	push   %ebp
  8018c7:	89 e5                	mov    %esp,%ebp
  8018c9:	57                   	push   %edi
  8018ca:	56                   	push   %esi
  8018cb:	53                   	push   %ebx
  8018cc:	83 ec 28             	sub    $0x28,%esp
  8018cf:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8018d2:	56                   	push   %esi
  8018d3:	e8 cf f6 ff ff       	call   800fa7 <fd2data>
  8018d8:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8018da:	83 c4 10             	add    $0x10,%esp
  8018dd:	bf 00 00 00 00       	mov    $0x0,%edi
  8018e2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8018e5:	74 4f                	je     801936 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8018e7:	8b 43 04             	mov    0x4(%ebx),%eax
  8018ea:	8b 0b                	mov    (%ebx),%ecx
  8018ec:	8d 51 20             	lea    0x20(%ecx),%edx
  8018ef:	39 d0                	cmp    %edx,%eax
  8018f1:	72 14                	jb     801907 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  8018f3:	89 da                	mov    %ebx,%edx
  8018f5:	89 f0                	mov    %esi,%eax
  8018f7:	e8 61 ff ff ff       	call   80185d <_pipeisclosed>
  8018fc:	85 c0                	test   %eax,%eax
  8018fe:	75 3b                	jne    80193b <devpipe_write+0x79>
			sys_yield();
  801900:	e8 5a f4 ff ff       	call   800d5f <sys_yield>
  801905:	eb e0                	jmp    8018e7 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801907:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80190a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80190e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801911:	89 c2                	mov    %eax,%edx
  801913:	c1 fa 1f             	sar    $0x1f,%edx
  801916:	89 d1                	mov    %edx,%ecx
  801918:	c1 e9 1b             	shr    $0x1b,%ecx
  80191b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80191e:	83 e2 1f             	and    $0x1f,%edx
  801921:	29 ca                	sub    %ecx,%edx
  801923:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801927:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80192b:	83 c0 01             	add    $0x1,%eax
  80192e:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801931:	83 c7 01             	add    $0x1,%edi
  801934:	eb ac                	jmp    8018e2 <devpipe_write+0x20>
	return i;
  801936:	8b 45 10             	mov    0x10(%ebp),%eax
  801939:	eb 05                	jmp    801940 <devpipe_write+0x7e>
				return 0;
  80193b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801940:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801943:	5b                   	pop    %ebx
  801944:	5e                   	pop    %esi
  801945:	5f                   	pop    %edi
  801946:	5d                   	pop    %ebp
  801947:	c3                   	ret    

00801948 <devpipe_read>:
{
  801948:	f3 0f 1e fb          	endbr32 
  80194c:	55                   	push   %ebp
  80194d:	89 e5                	mov    %esp,%ebp
  80194f:	57                   	push   %edi
  801950:	56                   	push   %esi
  801951:	53                   	push   %ebx
  801952:	83 ec 18             	sub    $0x18,%esp
  801955:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801958:	57                   	push   %edi
  801959:	e8 49 f6 ff ff       	call   800fa7 <fd2data>
  80195e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801960:	83 c4 10             	add    $0x10,%esp
  801963:	be 00 00 00 00       	mov    $0x0,%esi
  801968:	3b 75 10             	cmp    0x10(%ebp),%esi
  80196b:	75 14                	jne    801981 <devpipe_read+0x39>
	return i;
  80196d:	8b 45 10             	mov    0x10(%ebp),%eax
  801970:	eb 02                	jmp    801974 <devpipe_read+0x2c>
				return i;
  801972:	89 f0                	mov    %esi,%eax
}
  801974:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801977:	5b                   	pop    %ebx
  801978:	5e                   	pop    %esi
  801979:	5f                   	pop    %edi
  80197a:	5d                   	pop    %ebp
  80197b:	c3                   	ret    
			sys_yield();
  80197c:	e8 de f3 ff ff       	call   800d5f <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801981:	8b 03                	mov    (%ebx),%eax
  801983:	3b 43 04             	cmp    0x4(%ebx),%eax
  801986:	75 18                	jne    8019a0 <devpipe_read+0x58>
			if (i > 0)
  801988:	85 f6                	test   %esi,%esi
  80198a:	75 e6                	jne    801972 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  80198c:	89 da                	mov    %ebx,%edx
  80198e:	89 f8                	mov    %edi,%eax
  801990:	e8 c8 fe ff ff       	call   80185d <_pipeisclosed>
  801995:	85 c0                	test   %eax,%eax
  801997:	74 e3                	je     80197c <devpipe_read+0x34>
				return 0;
  801999:	b8 00 00 00 00       	mov    $0x0,%eax
  80199e:	eb d4                	jmp    801974 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019a0:	99                   	cltd   
  8019a1:	c1 ea 1b             	shr    $0x1b,%edx
  8019a4:	01 d0                	add    %edx,%eax
  8019a6:	83 e0 1f             	and    $0x1f,%eax
  8019a9:	29 d0                	sub    %edx,%eax
  8019ab:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8019b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019b3:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8019b6:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8019b9:	83 c6 01             	add    $0x1,%esi
  8019bc:	eb aa                	jmp    801968 <devpipe_read+0x20>

008019be <pipe>:
{
  8019be:	f3 0f 1e fb          	endbr32 
  8019c2:	55                   	push   %ebp
  8019c3:	89 e5                	mov    %esp,%ebp
  8019c5:	56                   	push   %esi
  8019c6:	53                   	push   %ebx
  8019c7:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8019ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019cd:	50                   	push   %eax
  8019ce:	e8 ef f5 ff ff       	call   800fc2 <fd_alloc>
  8019d3:	89 c3                	mov    %eax,%ebx
  8019d5:	83 c4 10             	add    $0x10,%esp
  8019d8:	85 c0                	test   %eax,%eax
  8019da:	0f 88 23 01 00 00    	js     801b03 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019e0:	83 ec 04             	sub    $0x4,%esp
  8019e3:	68 07 04 00 00       	push   $0x407
  8019e8:	ff 75 f4             	pushl  -0xc(%ebp)
  8019eb:	6a 00                	push   $0x0
  8019ed:	e8 90 f3 ff ff       	call   800d82 <sys_page_alloc>
  8019f2:	89 c3                	mov    %eax,%ebx
  8019f4:	83 c4 10             	add    $0x10,%esp
  8019f7:	85 c0                	test   %eax,%eax
  8019f9:	0f 88 04 01 00 00    	js     801b03 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  8019ff:	83 ec 0c             	sub    $0xc,%esp
  801a02:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a05:	50                   	push   %eax
  801a06:	e8 b7 f5 ff ff       	call   800fc2 <fd_alloc>
  801a0b:	89 c3                	mov    %eax,%ebx
  801a0d:	83 c4 10             	add    $0x10,%esp
  801a10:	85 c0                	test   %eax,%eax
  801a12:	0f 88 db 00 00 00    	js     801af3 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a18:	83 ec 04             	sub    $0x4,%esp
  801a1b:	68 07 04 00 00       	push   $0x407
  801a20:	ff 75 f0             	pushl  -0x10(%ebp)
  801a23:	6a 00                	push   $0x0
  801a25:	e8 58 f3 ff ff       	call   800d82 <sys_page_alloc>
  801a2a:	89 c3                	mov    %eax,%ebx
  801a2c:	83 c4 10             	add    $0x10,%esp
  801a2f:	85 c0                	test   %eax,%eax
  801a31:	0f 88 bc 00 00 00    	js     801af3 <pipe+0x135>
	va = fd2data(fd0);
  801a37:	83 ec 0c             	sub    $0xc,%esp
  801a3a:	ff 75 f4             	pushl  -0xc(%ebp)
  801a3d:	e8 65 f5 ff ff       	call   800fa7 <fd2data>
  801a42:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a44:	83 c4 0c             	add    $0xc,%esp
  801a47:	68 07 04 00 00       	push   $0x407
  801a4c:	50                   	push   %eax
  801a4d:	6a 00                	push   $0x0
  801a4f:	e8 2e f3 ff ff       	call   800d82 <sys_page_alloc>
  801a54:	89 c3                	mov    %eax,%ebx
  801a56:	83 c4 10             	add    $0x10,%esp
  801a59:	85 c0                	test   %eax,%eax
  801a5b:	0f 88 82 00 00 00    	js     801ae3 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a61:	83 ec 0c             	sub    $0xc,%esp
  801a64:	ff 75 f0             	pushl  -0x10(%ebp)
  801a67:	e8 3b f5 ff ff       	call   800fa7 <fd2data>
  801a6c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a73:	50                   	push   %eax
  801a74:	6a 00                	push   $0x0
  801a76:	56                   	push   %esi
  801a77:	6a 00                	push   $0x0
  801a79:	e8 4b f3 ff ff       	call   800dc9 <sys_page_map>
  801a7e:	89 c3                	mov    %eax,%ebx
  801a80:	83 c4 20             	add    $0x20,%esp
  801a83:	85 c0                	test   %eax,%eax
  801a85:	78 4e                	js     801ad5 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801a87:	a1 20 30 80 00       	mov    0x803020,%eax
  801a8c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a8f:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801a91:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a94:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801a9b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a9e:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801aa0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aa3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801aaa:	83 ec 0c             	sub    $0xc,%esp
  801aad:	ff 75 f4             	pushl  -0xc(%ebp)
  801ab0:	e8 de f4 ff ff       	call   800f93 <fd2num>
  801ab5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ab8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801aba:	83 c4 04             	add    $0x4,%esp
  801abd:	ff 75 f0             	pushl  -0x10(%ebp)
  801ac0:	e8 ce f4 ff ff       	call   800f93 <fd2num>
  801ac5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ac8:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801acb:	83 c4 10             	add    $0x10,%esp
  801ace:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ad3:	eb 2e                	jmp    801b03 <pipe+0x145>
	sys_page_unmap(0, va);
  801ad5:	83 ec 08             	sub    $0x8,%esp
  801ad8:	56                   	push   %esi
  801ad9:	6a 00                	push   $0x0
  801adb:	e8 2f f3 ff ff       	call   800e0f <sys_page_unmap>
  801ae0:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801ae3:	83 ec 08             	sub    $0x8,%esp
  801ae6:	ff 75 f0             	pushl  -0x10(%ebp)
  801ae9:	6a 00                	push   $0x0
  801aeb:	e8 1f f3 ff ff       	call   800e0f <sys_page_unmap>
  801af0:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801af3:	83 ec 08             	sub    $0x8,%esp
  801af6:	ff 75 f4             	pushl  -0xc(%ebp)
  801af9:	6a 00                	push   $0x0
  801afb:	e8 0f f3 ff ff       	call   800e0f <sys_page_unmap>
  801b00:	83 c4 10             	add    $0x10,%esp
}
  801b03:	89 d8                	mov    %ebx,%eax
  801b05:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b08:	5b                   	pop    %ebx
  801b09:	5e                   	pop    %esi
  801b0a:	5d                   	pop    %ebp
  801b0b:	c3                   	ret    

00801b0c <pipeisclosed>:
{
  801b0c:	f3 0f 1e fb          	endbr32 
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b16:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b19:	50                   	push   %eax
  801b1a:	ff 75 08             	pushl  0x8(%ebp)
  801b1d:	e8 f6 f4 ff ff       	call   801018 <fd_lookup>
  801b22:	83 c4 10             	add    $0x10,%esp
  801b25:	85 c0                	test   %eax,%eax
  801b27:	78 18                	js     801b41 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801b29:	83 ec 0c             	sub    $0xc,%esp
  801b2c:	ff 75 f4             	pushl  -0xc(%ebp)
  801b2f:	e8 73 f4 ff ff       	call   800fa7 <fd2data>
  801b34:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b39:	e8 1f fd ff ff       	call   80185d <_pipeisclosed>
  801b3e:	83 c4 10             	add    $0x10,%esp
}
  801b41:	c9                   	leave  
  801b42:	c3                   	ret    

00801b43 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b43:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801b47:	b8 00 00 00 00       	mov    $0x0,%eax
  801b4c:	c3                   	ret    

00801b4d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b4d:	f3 0f 1e fb          	endbr32 
  801b51:	55                   	push   %ebp
  801b52:	89 e5                	mov    %esp,%ebp
  801b54:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b57:	68 4a 25 80 00       	push   $0x80254a
  801b5c:	ff 75 0c             	pushl  0xc(%ebp)
  801b5f:	e8 dc ed ff ff       	call   800940 <strcpy>
	return 0;
}
  801b64:	b8 00 00 00 00       	mov    $0x0,%eax
  801b69:	c9                   	leave  
  801b6a:	c3                   	ret    

00801b6b <devcons_write>:
{
  801b6b:	f3 0f 1e fb          	endbr32 
  801b6f:	55                   	push   %ebp
  801b70:	89 e5                	mov    %esp,%ebp
  801b72:	57                   	push   %edi
  801b73:	56                   	push   %esi
  801b74:	53                   	push   %ebx
  801b75:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801b7b:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801b80:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801b86:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b89:	73 31                	jae    801bbc <devcons_write+0x51>
		m = n - tot;
  801b8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b8e:	29 f3                	sub    %esi,%ebx
  801b90:	83 fb 7f             	cmp    $0x7f,%ebx
  801b93:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801b98:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801b9b:	83 ec 04             	sub    $0x4,%esp
  801b9e:	53                   	push   %ebx
  801b9f:	89 f0                	mov    %esi,%eax
  801ba1:	03 45 0c             	add    0xc(%ebp),%eax
  801ba4:	50                   	push   %eax
  801ba5:	57                   	push   %edi
  801ba6:	e8 4b ef ff ff       	call   800af6 <memmove>
		sys_cputs(buf, m);
  801bab:	83 c4 08             	add    $0x8,%esp
  801bae:	53                   	push   %ebx
  801baf:	57                   	push   %edi
  801bb0:	e8 fd f0 ff ff       	call   800cb2 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801bb5:	01 de                	add    %ebx,%esi
  801bb7:	83 c4 10             	add    $0x10,%esp
  801bba:	eb ca                	jmp    801b86 <devcons_write+0x1b>
}
  801bbc:	89 f0                	mov    %esi,%eax
  801bbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bc1:	5b                   	pop    %ebx
  801bc2:	5e                   	pop    %esi
  801bc3:	5f                   	pop    %edi
  801bc4:	5d                   	pop    %ebp
  801bc5:	c3                   	ret    

00801bc6 <devcons_read>:
{
  801bc6:	f3 0f 1e fb          	endbr32 
  801bca:	55                   	push   %ebp
  801bcb:	89 e5                	mov    %esp,%ebp
  801bcd:	83 ec 08             	sub    $0x8,%esp
  801bd0:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801bd5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bd9:	74 21                	je     801bfc <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801bdb:	e8 f4 f0 ff ff       	call   800cd4 <sys_cgetc>
  801be0:	85 c0                	test   %eax,%eax
  801be2:	75 07                	jne    801beb <devcons_read+0x25>
		sys_yield();
  801be4:	e8 76 f1 ff ff       	call   800d5f <sys_yield>
  801be9:	eb f0                	jmp    801bdb <devcons_read+0x15>
	if (c < 0)
  801beb:	78 0f                	js     801bfc <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801bed:	83 f8 04             	cmp    $0x4,%eax
  801bf0:	74 0c                	je     801bfe <devcons_read+0x38>
	*(char*)vbuf = c;
  801bf2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bf5:	88 02                	mov    %al,(%edx)
	return 1;
  801bf7:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801bfc:	c9                   	leave  
  801bfd:	c3                   	ret    
		return 0;
  801bfe:	b8 00 00 00 00       	mov    $0x0,%eax
  801c03:	eb f7                	jmp    801bfc <devcons_read+0x36>

00801c05 <cputchar>:
{
  801c05:	f3 0f 1e fb          	endbr32 
  801c09:	55                   	push   %ebp
  801c0a:	89 e5                	mov    %esp,%ebp
  801c0c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c12:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801c15:	6a 01                	push   $0x1
  801c17:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c1a:	50                   	push   %eax
  801c1b:	e8 92 f0 ff ff       	call   800cb2 <sys_cputs>
}
  801c20:	83 c4 10             	add    $0x10,%esp
  801c23:	c9                   	leave  
  801c24:	c3                   	ret    

00801c25 <getchar>:
{
  801c25:	f3 0f 1e fb          	endbr32 
  801c29:	55                   	push   %ebp
  801c2a:	89 e5                	mov    %esp,%ebp
  801c2c:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801c2f:	6a 01                	push   $0x1
  801c31:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c34:	50                   	push   %eax
  801c35:	6a 00                	push   $0x0
  801c37:	e8 5f f6 ff ff       	call   80129b <read>
	if (r < 0)
  801c3c:	83 c4 10             	add    $0x10,%esp
  801c3f:	85 c0                	test   %eax,%eax
  801c41:	78 06                	js     801c49 <getchar+0x24>
	if (r < 1)
  801c43:	74 06                	je     801c4b <getchar+0x26>
	return c;
  801c45:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801c49:	c9                   	leave  
  801c4a:	c3                   	ret    
		return -E_EOF;
  801c4b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801c50:	eb f7                	jmp    801c49 <getchar+0x24>

00801c52 <iscons>:
{
  801c52:	f3 0f 1e fb          	endbr32 
  801c56:	55                   	push   %ebp
  801c57:	89 e5                	mov    %esp,%ebp
  801c59:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c5f:	50                   	push   %eax
  801c60:	ff 75 08             	pushl  0x8(%ebp)
  801c63:	e8 b0 f3 ff ff       	call   801018 <fd_lookup>
  801c68:	83 c4 10             	add    $0x10,%esp
  801c6b:	85 c0                	test   %eax,%eax
  801c6d:	78 11                	js     801c80 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801c6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c72:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c78:	39 10                	cmp    %edx,(%eax)
  801c7a:	0f 94 c0             	sete   %al
  801c7d:	0f b6 c0             	movzbl %al,%eax
}
  801c80:	c9                   	leave  
  801c81:	c3                   	ret    

00801c82 <opencons>:
{
  801c82:	f3 0f 1e fb          	endbr32 
  801c86:	55                   	push   %ebp
  801c87:	89 e5                	mov    %esp,%ebp
  801c89:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801c8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c8f:	50                   	push   %eax
  801c90:	e8 2d f3 ff ff       	call   800fc2 <fd_alloc>
  801c95:	83 c4 10             	add    $0x10,%esp
  801c98:	85 c0                	test   %eax,%eax
  801c9a:	78 3a                	js     801cd6 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c9c:	83 ec 04             	sub    $0x4,%esp
  801c9f:	68 07 04 00 00       	push   $0x407
  801ca4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca7:	6a 00                	push   $0x0
  801ca9:	e8 d4 f0 ff ff       	call   800d82 <sys_page_alloc>
  801cae:	83 c4 10             	add    $0x10,%esp
  801cb1:	85 c0                	test   %eax,%eax
  801cb3:	78 21                	js     801cd6 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801cb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cbe:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801cc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801cca:	83 ec 0c             	sub    $0xc,%esp
  801ccd:	50                   	push   %eax
  801cce:	e8 c0 f2 ff ff       	call   800f93 <fd2num>
  801cd3:	83 c4 10             	add    $0x10,%esp
}
  801cd6:	c9                   	leave  
  801cd7:	c3                   	ret    

00801cd8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801cd8:	f3 0f 1e fb          	endbr32 
  801cdc:	55                   	push   %ebp
  801cdd:	89 e5                	mov    %esp,%ebp
  801cdf:	56                   	push   %esi
  801ce0:	53                   	push   %ebx
  801ce1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801ce4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ce7:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801cea:	85 c0                	test   %eax,%eax
  801cec:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801cf1:	0f 44 c2             	cmove  %edx,%eax
  801cf4:	83 ec 0c             	sub    $0xc,%esp
  801cf7:	50                   	push   %eax
  801cf8:	e8 51 f2 ff ff       	call   800f4e <sys_ipc_recv>
  801cfd:	83 c4 10             	add    $0x10,%esp
  801d00:	85 c0                	test   %eax,%eax
  801d02:	78 24                	js     801d28 <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801d04:	85 f6                	test   %esi,%esi
  801d06:	74 0a                	je     801d12 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801d08:	a1 04 40 80 00       	mov    0x804004,%eax
  801d0d:	8b 40 78             	mov    0x78(%eax),%eax
  801d10:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801d12:	85 db                	test   %ebx,%ebx
  801d14:	74 0a                	je     801d20 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801d16:	a1 04 40 80 00       	mov    0x804004,%eax
  801d1b:	8b 40 74             	mov    0x74(%eax),%eax
  801d1e:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801d20:	a1 04 40 80 00       	mov    0x804004,%eax
  801d25:	8b 40 70             	mov    0x70(%eax),%eax
}
  801d28:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d2b:	5b                   	pop    %ebx
  801d2c:	5e                   	pop    %esi
  801d2d:	5d                   	pop    %ebp
  801d2e:	c3                   	ret    

00801d2f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d2f:	f3 0f 1e fb          	endbr32 
  801d33:	55                   	push   %ebp
  801d34:	89 e5                	mov    %esp,%ebp
  801d36:	57                   	push   %edi
  801d37:	56                   	push   %esi
  801d38:	53                   	push   %ebx
  801d39:	83 ec 1c             	sub    $0x1c,%esp
  801d3c:	8b 45 10             	mov    0x10(%ebp),%eax
  801d3f:	85 c0                	test   %eax,%eax
  801d41:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801d46:	0f 45 d0             	cmovne %eax,%edx
  801d49:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801d4b:	be 01 00 00 00       	mov    $0x1,%esi
  801d50:	eb 1f                	jmp    801d71 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801d52:	e8 08 f0 ff ff       	call   800d5f <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801d57:	83 c3 01             	add    $0x1,%ebx
  801d5a:	39 de                	cmp    %ebx,%esi
  801d5c:	7f f4                	jg     801d52 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801d5e:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801d60:	83 fe 11             	cmp    $0x11,%esi
  801d63:	b8 01 00 00 00       	mov    $0x1,%eax
  801d68:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801d6b:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801d6f:	75 1c                	jne    801d8d <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801d71:	ff 75 14             	pushl  0x14(%ebp)
  801d74:	57                   	push   %edi
  801d75:	ff 75 0c             	pushl  0xc(%ebp)
  801d78:	ff 75 08             	pushl  0x8(%ebp)
  801d7b:	e8 a7 f1 ff ff       	call   800f27 <sys_ipc_try_send>
  801d80:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801d83:	83 c4 10             	add    $0x10,%esp
  801d86:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d8b:	eb cd                	jmp    801d5a <ipc_send+0x2b>
}
  801d8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d90:	5b                   	pop    %ebx
  801d91:	5e                   	pop    %esi
  801d92:	5f                   	pop    %edi
  801d93:	5d                   	pop    %ebp
  801d94:	c3                   	ret    

00801d95 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d95:	f3 0f 1e fb          	endbr32 
  801d99:	55                   	push   %ebp
  801d9a:	89 e5                	mov    %esp,%ebp
  801d9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801d9f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801da4:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801da7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801dad:	8b 52 50             	mov    0x50(%edx),%edx
  801db0:	39 ca                	cmp    %ecx,%edx
  801db2:	74 11                	je     801dc5 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801db4:	83 c0 01             	add    $0x1,%eax
  801db7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801dbc:	75 e6                	jne    801da4 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801dbe:	b8 00 00 00 00       	mov    $0x0,%eax
  801dc3:	eb 0b                	jmp    801dd0 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801dc5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801dc8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801dcd:	8b 40 48             	mov    0x48(%eax),%eax
}
  801dd0:	5d                   	pop    %ebp
  801dd1:	c3                   	ret    

00801dd2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801dd2:	f3 0f 1e fb          	endbr32 
  801dd6:	55                   	push   %ebp
  801dd7:	89 e5                	mov    %esp,%ebp
  801dd9:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ddc:	89 c2                	mov    %eax,%edx
  801dde:	c1 ea 16             	shr    $0x16,%edx
  801de1:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801de8:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801ded:	f6 c1 01             	test   $0x1,%cl
  801df0:	74 1c                	je     801e0e <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801df2:	c1 e8 0c             	shr    $0xc,%eax
  801df5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801dfc:	a8 01                	test   $0x1,%al
  801dfe:	74 0e                	je     801e0e <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e00:	c1 e8 0c             	shr    $0xc,%eax
  801e03:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801e0a:	ef 
  801e0b:	0f b7 d2             	movzwl %dx,%edx
}
  801e0e:	89 d0                	mov    %edx,%eax
  801e10:	5d                   	pop    %ebp
  801e11:	c3                   	ret    
  801e12:	66 90                	xchg   %ax,%ax
  801e14:	66 90                	xchg   %ax,%ax
  801e16:	66 90                	xchg   %ax,%ax
  801e18:	66 90                	xchg   %ax,%ax
  801e1a:	66 90                	xchg   %ax,%ax
  801e1c:	66 90                	xchg   %ax,%ax
  801e1e:	66 90                	xchg   %ax,%ax

00801e20 <__udivdi3>:
  801e20:	f3 0f 1e fb          	endbr32 
  801e24:	55                   	push   %ebp
  801e25:	57                   	push   %edi
  801e26:	56                   	push   %esi
  801e27:	53                   	push   %ebx
  801e28:	83 ec 1c             	sub    $0x1c,%esp
  801e2b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801e2f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801e33:	8b 74 24 34          	mov    0x34(%esp),%esi
  801e37:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801e3b:	85 d2                	test   %edx,%edx
  801e3d:	75 19                	jne    801e58 <__udivdi3+0x38>
  801e3f:	39 f3                	cmp    %esi,%ebx
  801e41:	76 4d                	jbe    801e90 <__udivdi3+0x70>
  801e43:	31 ff                	xor    %edi,%edi
  801e45:	89 e8                	mov    %ebp,%eax
  801e47:	89 f2                	mov    %esi,%edx
  801e49:	f7 f3                	div    %ebx
  801e4b:	89 fa                	mov    %edi,%edx
  801e4d:	83 c4 1c             	add    $0x1c,%esp
  801e50:	5b                   	pop    %ebx
  801e51:	5e                   	pop    %esi
  801e52:	5f                   	pop    %edi
  801e53:	5d                   	pop    %ebp
  801e54:	c3                   	ret    
  801e55:	8d 76 00             	lea    0x0(%esi),%esi
  801e58:	39 f2                	cmp    %esi,%edx
  801e5a:	76 14                	jbe    801e70 <__udivdi3+0x50>
  801e5c:	31 ff                	xor    %edi,%edi
  801e5e:	31 c0                	xor    %eax,%eax
  801e60:	89 fa                	mov    %edi,%edx
  801e62:	83 c4 1c             	add    $0x1c,%esp
  801e65:	5b                   	pop    %ebx
  801e66:	5e                   	pop    %esi
  801e67:	5f                   	pop    %edi
  801e68:	5d                   	pop    %ebp
  801e69:	c3                   	ret    
  801e6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e70:	0f bd fa             	bsr    %edx,%edi
  801e73:	83 f7 1f             	xor    $0x1f,%edi
  801e76:	75 48                	jne    801ec0 <__udivdi3+0xa0>
  801e78:	39 f2                	cmp    %esi,%edx
  801e7a:	72 06                	jb     801e82 <__udivdi3+0x62>
  801e7c:	31 c0                	xor    %eax,%eax
  801e7e:	39 eb                	cmp    %ebp,%ebx
  801e80:	77 de                	ja     801e60 <__udivdi3+0x40>
  801e82:	b8 01 00 00 00       	mov    $0x1,%eax
  801e87:	eb d7                	jmp    801e60 <__udivdi3+0x40>
  801e89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e90:	89 d9                	mov    %ebx,%ecx
  801e92:	85 db                	test   %ebx,%ebx
  801e94:	75 0b                	jne    801ea1 <__udivdi3+0x81>
  801e96:	b8 01 00 00 00       	mov    $0x1,%eax
  801e9b:	31 d2                	xor    %edx,%edx
  801e9d:	f7 f3                	div    %ebx
  801e9f:	89 c1                	mov    %eax,%ecx
  801ea1:	31 d2                	xor    %edx,%edx
  801ea3:	89 f0                	mov    %esi,%eax
  801ea5:	f7 f1                	div    %ecx
  801ea7:	89 c6                	mov    %eax,%esi
  801ea9:	89 e8                	mov    %ebp,%eax
  801eab:	89 f7                	mov    %esi,%edi
  801ead:	f7 f1                	div    %ecx
  801eaf:	89 fa                	mov    %edi,%edx
  801eb1:	83 c4 1c             	add    $0x1c,%esp
  801eb4:	5b                   	pop    %ebx
  801eb5:	5e                   	pop    %esi
  801eb6:	5f                   	pop    %edi
  801eb7:	5d                   	pop    %ebp
  801eb8:	c3                   	ret    
  801eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ec0:	89 f9                	mov    %edi,%ecx
  801ec2:	b8 20 00 00 00       	mov    $0x20,%eax
  801ec7:	29 f8                	sub    %edi,%eax
  801ec9:	d3 e2                	shl    %cl,%edx
  801ecb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ecf:	89 c1                	mov    %eax,%ecx
  801ed1:	89 da                	mov    %ebx,%edx
  801ed3:	d3 ea                	shr    %cl,%edx
  801ed5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801ed9:	09 d1                	or     %edx,%ecx
  801edb:	89 f2                	mov    %esi,%edx
  801edd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ee1:	89 f9                	mov    %edi,%ecx
  801ee3:	d3 e3                	shl    %cl,%ebx
  801ee5:	89 c1                	mov    %eax,%ecx
  801ee7:	d3 ea                	shr    %cl,%edx
  801ee9:	89 f9                	mov    %edi,%ecx
  801eeb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801eef:	89 eb                	mov    %ebp,%ebx
  801ef1:	d3 e6                	shl    %cl,%esi
  801ef3:	89 c1                	mov    %eax,%ecx
  801ef5:	d3 eb                	shr    %cl,%ebx
  801ef7:	09 de                	or     %ebx,%esi
  801ef9:	89 f0                	mov    %esi,%eax
  801efb:	f7 74 24 08          	divl   0x8(%esp)
  801eff:	89 d6                	mov    %edx,%esi
  801f01:	89 c3                	mov    %eax,%ebx
  801f03:	f7 64 24 0c          	mull   0xc(%esp)
  801f07:	39 d6                	cmp    %edx,%esi
  801f09:	72 15                	jb     801f20 <__udivdi3+0x100>
  801f0b:	89 f9                	mov    %edi,%ecx
  801f0d:	d3 e5                	shl    %cl,%ebp
  801f0f:	39 c5                	cmp    %eax,%ebp
  801f11:	73 04                	jae    801f17 <__udivdi3+0xf7>
  801f13:	39 d6                	cmp    %edx,%esi
  801f15:	74 09                	je     801f20 <__udivdi3+0x100>
  801f17:	89 d8                	mov    %ebx,%eax
  801f19:	31 ff                	xor    %edi,%edi
  801f1b:	e9 40 ff ff ff       	jmp    801e60 <__udivdi3+0x40>
  801f20:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801f23:	31 ff                	xor    %edi,%edi
  801f25:	e9 36 ff ff ff       	jmp    801e60 <__udivdi3+0x40>
  801f2a:	66 90                	xchg   %ax,%ax
  801f2c:	66 90                	xchg   %ax,%ax
  801f2e:	66 90                	xchg   %ax,%ax

00801f30 <__umoddi3>:
  801f30:	f3 0f 1e fb          	endbr32 
  801f34:	55                   	push   %ebp
  801f35:	57                   	push   %edi
  801f36:	56                   	push   %esi
  801f37:	53                   	push   %ebx
  801f38:	83 ec 1c             	sub    $0x1c,%esp
  801f3b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801f3f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801f43:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801f47:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f4b:	85 c0                	test   %eax,%eax
  801f4d:	75 19                	jne    801f68 <__umoddi3+0x38>
  801f4f:	39 df                	cmp    %ebx,%edi
  801f51:	76 5d                	jbe    801fb0 <__umoddi3+0x80>
  801f53:	89 f0                	mov    %esi,%eax
  801f55:	89 da                	mov    %ebx,%edx
  801f57:	f7 f7                	div    %edi
  801f59:	89 d0                	mov    %edx,%eax
  801f5b:	31 d2                	xor    %edx,%edx
  801f5d:	83 c4 1c             	add    $0x1c,%esp
  801f60:	5b                   	pop    %ebx
  801f61:	5e                   	pop    %esi
  801f62:	5f                   	pop    %edi
  801f63:	5d                   	pop    %ebp
  801f64:	c3                   	ret    
  801f65:	8d 76 00             	lea    0x0(%esi),%esi
  801f68:	89 f2                	mov    %esi,%edx
  801f6a:	39 d8                	cmp    %ebx,%eax
  801f6c:	76 12                	jbe    801f80 <__umoddi3+0x50>
  801f6e:	89 f0                	mov    %esi,%eax
  801f70:	89 da                	mov    %ebx,%edx
  801f72:	83 c4 1c             	add    $0x1c,%esp
  801f75:	5b                   	pop    %ebx
  801f76:	5e                   	pop    %esi
  801f77:	5f                   	pop    %edi
  801f78:	5d                   	pop    %ebp
  801f79:	c3                   	ret    
  801f7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f80:	0f bd e8             	bsr    %eax,%ebp
  801f83:	83 f5 1f             	xor    $0x1f,%ebp
  801f86:	75 50                	jne    801fd8 <__umoddi3+0xa8>
  801f88:	39 d8                	cmp    %ebx,%eax
  801f8a:	0f 82 e0 00 00 00    	jb     802070 <__umoddi3+0x140>
  801f90:	89 d9                	mov    %ebx,%ecx
  801f92:	39 f7                	cmp    %esi,%edi
  801f94:	0f 86 d6 00 00 00    	jbe    802070 <__umoddi3+0x140>
  801f9a:	89 d0                	mov    %edx,%eax
  801f9c:	89 ca                	mov    %ecx,%edx
  801f9e:	83 c4 1c             	add    $0x1c,%esp
  801fa1:	5b                   	pop    %ebx
  801fa2:	5e                   	pop    %esi
  801fa3:	5f                   	pop    %edi
  801fa4:	5d                   	pop    %ebp
  801fa5:	c3                   	ret    
  801fa6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fad:	8d 76 00             	lea    0x0(%esi),%esi
  801fb0:	89 fd                	mov    %edi,%ebp
  801fb2:	85 ff                	test   %edi,%edi
  801fb4:	75 0b                	jne    801fc1 <__umoddi3+0x91>
  801fb6:	b8 01 00 00 00       	mov    $0x1,%eax
  801fbb:	31 d2                	xor    %edx,%edx
  801fbd:	f7 f7                	div    %edi
  801fbf:	89 c5                	mov    %eax,%ebp
  801fc1:	89 d8                	mov    %ebx,%eax
  801fc3:	31 d2                	xor    %edx,%edx
  801fc5:	f7 f5                	div    %ebp
  801fc7:	89 f0                	mov    %esi,%eax
  801fc9:	f7 f5                	div    %ebp
  801fcb:	89 d0                	mov    %edx,%eax
  801fcd:	31 d2                	xor    %edx,%edx
  801fcf:	eb 8c                	jmp    801f5d <__umoddi3+0x2d>
  801fd1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fd8:	89 e9                	mov    %ebp,%ecx
  801fda:	ba 20 00 00 00       	mov    $0x20,%edx
  801fdf:	29 ea                	sub    %ebp,%edx
  801fe1:	d3 e0                	shl    %cl,%eax
  801fe3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fe7:	89 d1                	mov    %edx,%ecx
  801fe9:	89 f8                	mov    %edi,%eax
  801feb:	d3 e8                	shr    %cl,%eax
  801fed:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801ff1:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ff5:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ff9:	09 c1                	or     %eax,%ecx
  801ffb:	89 d8                	mov    %ebx,%eax
  801ffd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802001:	89 e9                	mov    %ebp,%ecx
  802003:	d3 e7                	shl    %cl,%edi
  802005:	89 d1                	mov    %edx,%ecx
  802007:	d3 e8                	shr    %cl,%eax
  802009:	89 e9                	mov    %ebp,%ecx
  80200b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80200f:	d3 e3                	shl    %cl,%ebx
  802011:	89 c7                	mov    %eax,%edi
  802013:	89 d1                	mov    %edx,%ecx
  802015:	89 f0                	mov    %esi,%eax
  802017:	d3 e8                	shr    %cl,%eax
  802019:	89 e9                	mov    %ebp,%ecx
  80201b:	89 fa                	mov    %edi,%edx
  80201d:	d3 e6                	shl    %cl,%esi
  80201f:	09 d8                	or     %ebx,%eax
  802021:	f7 74 24 08          	divl   0x8(%esp)
  802025:	89 d1                	mov    %edx,%ecx
  802027:	89 f3                	mov    %esi,%ebx
  802029:	f7 64 24 0c          	mull   0xc(%esp)
  80202d:	89 c6                	mov    %eax,%esi
  80202f:	89 d7                	mov    %edx,%edi
  802031:	39 d1                	cmp    %edx,%ecx
  802033:	72 06                	jb     80203b <__umoddi3+0x10b>
  802035:	75 10                	jne    802047 <__umoddi3+0x117>
  802037:	39 c3                	cmp    %eax,%ebx
  802039:	73 0c                	jae    802047 <__umoddi3+0x117>
  80203b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80203f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802043:	89 d7                	mov    %edx,%edi
  802045:	89 c6                	mov    %eax,%esi
  802047:	89 ca                	mov    %ecx,%edx
  802049:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80204e:	29 f3                	sub    %esi,%ebx
  802050:	19 fa                	sbb    %edi,%edx
  802052:	89 d0                	mov    %edx,%eax
  802054:	d3 e0                	shl    %cl,%eax
  802056:	89 e9                	mov    %ebp,%ecx
  802058:	d3 eb                	shr    %cl,%ebx
  80205a:	d3 ea                	shr    %cl,%edx
  80205c:	09 d8                	or     %ebx,%eax
  80205e:	83 c4 1c             	add    $0x1c,%esp
  802061:	5b                   	pop    %ebx
  802062:	5e                   	pop    %esi
  802063:	5f                   	pop    %edi
  802064:	5d                   	pop    %ebp
  802065:	c3                   	ret    
  802066:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80206d:	8d 76 00             	lea    0x0(%esi),%esi
  802070:	29 fe                	sub    %edi,%esi
  802072:	19 c3                	sbb    %eax,%ebx
  802074:	89 f2                	mov    %esi,%edx
  802076:	89 d9                	mov    %ebx,%ecx
  802078:	e9 1d ff ff ff       	jmp    801f9a <__umoddi3+0x6a>
