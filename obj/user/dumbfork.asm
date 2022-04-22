
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
  800049:	e8 2c 0d 00 00       	call   800d7a <sys_page_alloc>
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
  800063:	e8 59 0d 00 00       	call   800dc1 <sys_page_map>
  800068:	83 c4 20             	add    $0x20,%esp
  80006b:	85 c0                	test   %eax,%eax
  80006d:	78 42                	js     8000b1 <duppage+0x7e>
		panic("sys_page_map: %e", r);
	memmove(UTEMP, addr, PGSIZE);
  80006f:	83 ec 04             	sub    $0x4,%esp
  800072:	68 00 10 00 00       	push   $0x1000
  800077:	53                   	push   %ebx
  800078:	68 00 00 40 00       	push   $0x400000
  80007d:	e8 6c 0a 00 00       	call   800aee <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800082:	83 c4 08             	add    $0x8,%esp
  800085:	68 00 00 40 00       	push   $0x400000
  80008a:	6a 00                	push   $0x0
  80008c:	e8 76 0d 00 00       	call   800e07 <sys_page_unmap>
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
  8000a0:	68 00 12 80 00       	push   $0x801200
  8000a5:	6a 20                	push   $0x20
  8000a7:	68 13 12 80 00       	push   $0x801213
  8000ac:	e8 97 01 00 00       	call   800248 <_panic>
		panic("sys_page_map: %e", r);
  8000b1:	50                   	push   %eax
  8000b2:	68 23 12 80 00       	push   $0x801223
  8000b7:	6a 22                	push   $0x22
  8000b9:	68 13 12 80 00       	push   $0x801213
  8000be:	e8 85 01 00 00       	call   800248 <_panic>
		panic("sys_page_unmap: %e", r);
  8000c3:	50                   	push   %eax
  8000c4:	68 34 12 80 00       	push   $0x801234
  8000c9:	6a 25                	push   $0x25
  8000cb:	68 13 12 80 00       	push   $0x801213
  8000d0:	e8 73 01 00 00       	call   800248 <_panic>

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
  8000fc:	68 47 12 80 00       	push   $0x801247
  800101:	6a 37                	push   $0x37
  800103:	68 13 12 80 00       	push   $0x801213
  800108:	e8 3b 01 00 00       	call   800248 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
  80010d:	e8 22 0c 00 00       	call   800d34 <sys_getenvid>
  800112:	25 ff 03 00 00       	and    $0x3ff,%eax
  800117:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80011a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011f:	a3 04 20 80 00       	mov    %eax,0x802004
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
  80013d:	81 fa 08 20 80 00    	cmp    $0x802008,%edx
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
  80015d:	e8 eb 0c 00 00       	call   800e4d <sys_env_set_status>
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
  800173:	68 57 12 80 00       	push   $0x801257
  800178:	6a 4c                	push   $0x4c
  80017a:	68 13 12 80 00       	push   $0x801213
  80017f:	e8 c4 00 00 00       	call   800248 <_panic>

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
  80019a:	bf 6e 12 80 00       	mov    $0x80126e,%edi
  80019f:	b8 75 12 80 00       	mov    $0x801275,%eax
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
  8001b8:	68 7b 12 80 00       	push   $0x80127b
  8001bd:	e8 6d 01 00 00       	call   80032f <cprintf>
		sys_yield();
  8001c2:	e8 90 0b 00 00       	call   800d57 <sys_yield>
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
  8001ed:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8001f4:	00 00 00 
    envid_t envid = sys_getenvid();
  8001f7:	e8 38 0b 00 00       	call   800d34 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  8001fc:	25 ff 03 00 00       	and    $0x3ff,%eax
  800201:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800204:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800209:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80020e:	85 db                	test   %ebx,%ebx
  800210:	7e 07                	jle    800219 <libmain+0x3b>
		binaryname = argv[0];
  800212:	8b 06                	mov    (%esi),%eax
  800214:	a3 00 20 80 00       	mov    %eax,0x802000

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
  800239:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  80023c:	6a 00                	push   $0x0
  80023e:	e8 ac 0a 00 00       	call   800cef <sys_env_destroy>
}
  800243:	83 c4 10             	add    $0x10,%esp
  800246:	c9                   	leave  
  800247:	c3                   	ret    

00800248 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800248:	f3 0f 1e fb          	endbr32 
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	56                   	push   %esi
  800250:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800251:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800254:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80025a:	e8 d5 0a 00 00       	call   800d34 <sys_getenvid>
  80025f:	83 ec 0c             	sub    $0xc,%esp
  800262:	ff 75 0c             	pushl  0xc(%ebp)
  800265:	ff 75 08             	pushl  0x8(%ebp)
  800268:	56                   	push   %esi
  800269:	50                   	push   %eax
  80026a:	68 98 12 80 00       	push   $0x801298
  80026f:	e8 bb 00 00 00       	call   80032f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800274:	83 c4 18             	add    $0x18,%esp
  800277:	53                   	push   %ebx
  800278:	ff 75 10             	pushl  0x10(%ebp)
  80027b:	e8 5a 00 00 00       	call   8002da <vcprintf>
	cprintf("\n");
  800280:	c7 04 24 8b 12 80 00 	movl   $0x80128b,(%esp)
  800287:	e8 a3 00 00 00       	call   80032f <cprintf>
  80028c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80028f:	cc                   	int3   
  800290:	eb fd                	jmp    80028f <_panic+0x47>

00800292 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800292:	f3 0f 1e fb          	endbr32 
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
  800299:	53                   	push   %ebx
  80029a:	83 ec 04             	sub    $0x4,%esp
  80029d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002a0:	8b 13                	mov    (%ebx),%edx
  8002a2:	8d 42 01             	lea    0x1(%edx),%eax
  8002a5:	89 03                	mov    %eax,(%ebx)
  8002a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002aa:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002ae:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002b3:	74 09                	je     8002be <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8002b5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8002be:	83 ec 08             	sub    $0x8,%esp
  8002c1:	68 ff 00 00 00       	push   $0xff
  8002c6:	8d 43 08             	lea    0x8(%ebx),%eax
  8002c9:	50                   	push   %eax
  8002ca:	e8 db 09 00 00       	call   800caa <sys_cputs>
		b->idx = 0;
  8002cf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002d5:	83 c4 10             	add    $0x10,%esp
  8002d8:	eb db                	jmp    8002b5 <putch+0x23>

008002da <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002da:	f3 0f 1e fb          	endbr32 
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002e7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002ee:	00 00 00 
	b.cnt = 0;
  8002f1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002f8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002fb:	ff 75 0c             	pushl  0xc(%ebp)
  8002fe:	ff 75 08             	pushl  0x8(%ebp)
  800301:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800307:	50                   	push   %eax
  800308:	68 92 02 80 00       	push   $0x800292
  80030d:	e8 20 01 00 00       	call   800432 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800312:	83 c4 08             	add    $0x8,%esp
  800315:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80031b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800321:	50                   	push   %eax
  800322:	e8 83 09 00 00       	call   800caa <sys_cputs>

	return b.cnt;
}
  800327:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80032d:	c9                   	leave  
  80032e:	c3                   	ret    

0080032f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80032f:	f3 0f 1e fb          	endbr32 
  800333:	55                   	push   %ebp
  800334:	89 e5                	mov    %esp,%ebp
  800336:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800339:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80033c:	50                   	push   %eax
  80033d:	ff 75 08             	pushl  0x8(%ebp)
  800340:	e8 95 ff ff ff       	call   8002da <vcprintf>
	va_end(ap);

	return cnt;
}
  800345:	c9                   	leave  
  800346:	c3                   	ret    

00800347 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
  80034a:	57                   	push   %edi
  80034b:	56                   	push   %esi
  80034c:	53                   	push   %ebx
  80034d:	83 ec 1c             	sub    $0x1c,%esp
  800350:	89 c7                	mov    %eax,%edi
  800352:	89 d6                	mov    %edx,%esi
  800354:	8b 45 08             	mov    0x8(%ebp),%eax
  800357:	8b 55 0c             	mov    0xc(%ebp),%edx
  80035a:	89 d1                	mov    %edx,%ecx
  80035c:	89 c2                	mov    %eax,%edx
  80035e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800361:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800364:	8b 45 10             	mov    0x10(%ebp),%eax
  800367:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80036a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80036d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800374:	39 c2                	cmp    %eax,%edx
  800376:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800379:	72 3e                	jb     8003b9 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80037b:	83 ec 0c             	sub    $0xc,%esp
  80037e:	ff 75 18             	pushl  0x18(%ebp)
  800381:	83 eb 01             	sub    $0x1,%ebx
  800384:	53                   	push   %ebx
  800385:	50                   	push   %eax
  800386:	83 ec 08             	sub    $0x8,%esp
  800389:	ff 75 e4             	pushl  -0x1c(%ebp)
  80038c:	ff 75 e0             	pushl  -0x20(%ebp)
  80038f:	ff 75 dc             	pushl  -0x24(%ebp)
  800392:	ff 75 d8             	pushl  -0x28(%ebp)
  800395:	e8 f6 0b 00 00       	call   800f90 <__udivdi3>
  80039a:	83 c4 18             	add    $0x18,%esp
  80039d:	52                   	push   %edx
  80039e:	50                   	push   %eax
  80039f:	89 f2                	mov    %esi,%edx
  8003a1:	89 f8                	mov    %edi,%eax
  8003a3:	e8 9f ff ff ff       	call   800347 <printnum>
  8003a8:	83 c4 20             	add    $0x20,%esp
  8003ab:	eb 13                	jmp    8003c0 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003ad:	83 ec 08             	sub    $0x8,%esp
  8003b0:	56                   	push   %esi
  8003b1:	ff 75 18             	pushl  0x18(%ebp)
  8003b4:	ff d7                	call   *%edi
  8003b6:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8003b9:	83 eb 01             	sub    $0x1,%ebx
  8003bc:	85 db                	test   %ebx,%ebx
  8003be:	7f ed                	jg     8003ad <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003c0:	83 ec 08             	sub    $0x8,%esp
  8003c3:	56                   	push   %esi
  8003c4:	83 ec 04             	sub    $0x4,%esp
  8003c7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ca:	ff 75 e0             	pushl  -0x20(%ebp)
  8003cd:	ff 75 dc             	pushl  -0x24(%ebp)
  8003d0:	ff 75 d8             	pushl  -0x28(%ebp)
  8003d3:	e8 c8 0c 00 00       	call   8010a0 <__umoddi3>
  8003d8:	83 c4 14             	add    $0x14,%esp
  8003db:	0f be 80 bb 12 80 00 	movsbl 0x8012bb(%eax),%eax
  8003e2:	50                   	push   %eax
  8003e3:	ff d7                	call   *%edi
}
  8003e5:	83 c4 10             	add    $0x10,%esp
  8003e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003eb:	5b                   	pop    %ebx
  8003ec:	5e                   	pop    %esi
  8003ed:	5f                   	pop    %edi
  8003ee:	5d                   	pop    %ebp
  8003ef:	c3                   	ret    

008003f0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003f0:	f3 0f 1e fb          	endbr32 
  8003f4:	55                   	push   %ebp
  8003f5:	89 e5                	mov    %esp,%ebp
  8003f7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003fa:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003fe:	8b 10                	mov    (%eax),%edx
  800400:	3b 50 04             	cmp    0x4(%eax),%edx
  800403:	73 0a                	jae    80040f <sprintputch+0x1f>
		*b->buf++ = ch;
  800405:	8d 4a 01             	lea    0x1(%edx),%ecx
  800408:	89 08                	mov    %ecx,(%eax)
  80040a:	8b 45 08             	mov    0x8(%ebp),%eax
  80040d:	88 02                	mov    %al,(%edx)
}
  80040f:	5d                   	pop    %ebp
  800410:	c3                   	ret    

00800411 <printfmt>:
{
  800411:	f3 0f 1e fb          	endbr32 
  800415:	55                   	push   %ebp
  800416:	89 e5                	mov    %esp,%ebp
  800418:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80041b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80041e:	50                   	push   %eax
  80041f:	ff 75 10             	pushl  0x10(%ebp)
  800422:	ff 75 0c             	pushl  0xc(%ebp)
  800425:	ff 75 08             	pushl  0x8(%ebp)
  800428:	e8 05 00 00 00       	call   800432 <vprintfmt>
}
  80042d:	83 c4 10             	add    $0x10,%esp
  800430:	c9                   	leave  
  800431:	c3                   	ret    

00800432 <vprintfmt>:
{
  800432:	f3 0f 1e fb          	endbr32 
  800436:	55                   	push   %ebp
  800437:	89 e5                	mov    %esp,%ebp
  800439:	57                   	push   %edi
  80043a:	56                   	push   %esi
  80043b:	53                   	push   %ebx
  80043c:	83 ec 3c             	sub    $0x3c,%esp
  80043f:	8b 75 08             	mov    0x8(%ebp),%esi
  800442:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800445:	8b 7d 10             	mov    0x10(%ebp),%edi
  800448:	e9 4a 03 00 00       	jmp    800797 <vprintfmt+0x365>
		padc = ' ';
  80044d:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800451:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800458:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80045f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800466:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	8d 47 01             	lea    0x1(%edi),%eax
  80046e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800471:	0f b6 17             	movzbl (%edi),%edx
  800474:	8d 42 dd             	lea    -0x23(%edx),%eax
  800477:	3c 55                	cmp    $0x55,%al
  800479:	0f 87 de 03 00 00    	ja     80085d <vprintfmt+0x42b>
  80047f:	0f b6 c0             	movzbl %al,%eax
  800482:	3e ff 24 85 00 14 80 	notrack jmp *0x801400(,%eax,4)
  800489:	00 
  80048a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80048d:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800491:	eb d8                	jmp    80046b <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800493:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800496:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80049a:	eb cf                	jmp    80046b <vprintfmt+0x39>
  80049c:	0f b6 d2             	movzbl %dl,%edx
  80049f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8004a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8004aa:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004ad:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8004b1:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004b4:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004b7:	83 f9 09             	cmp    $0x9,%ecx
  8004ba:	77 55                	ja     800511 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8004bc:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004bf:	eb e9                	jmp    8004aa <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8004c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c4:	8b 00                	mov    (%eax),%eax
  8004c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cc:	8d 40 04             	lea    0x4(%eax),%eax
  8004cf:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8004d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d9:	79 90                	jns    80046b <vprintfmt+0x39>
				width = precision, precision = -1;
  8004db:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8004e8:	eb 81                	jmp    80046b <vprintfmt+0x39>
  8004ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ed:	85 c0                	test   %eax,%eax
  8004ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f4:	0f 49 d0             	cmovns %eax,%edx
  8004f7:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004fd:	e9 69 ff ff ff       	jmp    80046b <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800502:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800505:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80050c:	e9 5a ff ff ff       	jmp    80046b <vprintfmt+0x39>
  800511:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800514:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800517:	eb bc                	jmp    8004d5 <vprintfmt+0xa3>
			lflag++;
  800519:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80051c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80051f:	e9 47 ff ff ff       	jmp    80046b <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800524:	8b 45 14             	mov    0x14(%ebp),%eax
  800527:	8d 78 04             	lea    0x4(%eax),%edi
  80052a:	83 ec 08             	sub    $0x8,%esp
  80052d:	53                   	push   %ebx
  80052e:	ff 30                	pushl  (%eax)
  800530:	ff d6                	call   *%esi
			break;
  800532:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800535:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800538:	e9 57 02 00 00       	jmp    800794 <vprintfmt+0x362>
			err = va_arg(ap, int);
  80053d:	8b 45 14             	mov    0x14(%ebp),%eax
  800540:	8d 78 04             	lea    0x4(%eax),%edi
  800543:	8b 00                	mov    (%eax),%eax
  800545:	99                   	cltd   
  800546:	31 d0                	xor    %edx,%eax
  800548:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80054a:	83 f8 0f             	cmp    $0xf,%eax
  80054d:	7f 23                	jg     800572 <vprintfmt+0x140>
  80054f:	8b 14 85 60 15 80 00 	mov    0x801560(,%eax,4),%edx
  800556:	85 d2                	test   %edx,%edx
  800558:	74 18                	je     800572 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80055a:	52                   	push   %edx
  80055b:	68 dc 12 80 00       	push   $0x8012dc
  800560:	53                   	push   %ebx
  800561:	56                   	push   %esi
  800562:	e8 aa fe ff ff       	call   800411 <printfmt>
  800567:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80056a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80056d:	e9 22 02 00 00       	jmp    800794 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  800572:	50                   	push   %eax
  800573:	68 d3 12 80 00       	push   $0x8012d3
  800578:	53                   	push   %ebx
  800579:	56                   	push   %esi
  80057a:	e8 92 fe ff ff       	call   800411 <printfmt>
  80057f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800582:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800585:	e9 0a 02 00 00       	jmp    800794 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  80058a:	8b 45 14             	mov    0x14(%ebp),%eax
  80058d:	83 c0 04             	add    $0x4,%eax
  800590:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800593:	8b 45 14             	mov    0x14(%ebp),%eax
  800596:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800598:	85 d2                	test   %edx,%edx
  80059a:	b8 cc 12 80 00       	mov    $0x8012cc,%eax
  80059f:	0f 45 c2             	cmovne %edx,%eax
  8005a2:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8005a5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005a9:	7e 06                	jle    8005b1 <vprintfmt+0x17f>
  8005ab:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8005af:	75 0d                	jne    8005be <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005b4:	89 c7                	mov    %eax,%edi
  8005b6:	03 45 e0             	add    -0x20(%ebp),%eax
  8005b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005bc:	eb 55                	jmp    800613 <vprintfmt+0x1e1>
  8005be:	83 ec 08             	sub    $0x8,%esp
  8005c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8005c4:	ff 75 cc             	pushl  -0x34(%ebp)
  8005c7:	e8 45 03 00 00       	call   800911 <strnlen>
  8005cc:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005cf:	29 c2                	sub    %eax,%edx
  8005d1:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8005d4:	83 c4 10             	add    $0x10,%esp
  8005d7:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8005d9:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8005dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e0:	85 ff                	test   %edi,%edi
  8005e2:	7e 11                	jle    8005f5 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8005e4:	83 ec 08             	sub    $0x8,%esp
  8005e7:	53                   	push   %ebx
  8005e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8005eb:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ed:	83 ef 01             	sub    $0x1,%edi
  8005f0:	83 c4 10             	add    $0x10,%esp
  8005f3:	eb eb                	jmp    8005e0 <vprintfmt+0x1ae>
  8005f5:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005f8:	85 d2                	test   %edx,%edx
  8005fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ff:	0f 49 c2             	cmovns %edx,%eax
  800602:	29 c2                	sub    %eax,%edx
  800604:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800607:	eb a8                	jmp    8005b1 <vprintfmt+0x17f>
					putch(ch, putdat);
  800609:	83 ec 08             	sub    $0x8,%esp
  80060c:	53                   	push   %ebx
  80060d:	52                   	push   %edx
  80060e:	ff d6                	call   *%esi
  800610:	83 c4 10             	add    $0x10,%esp
  800613:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800616:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800618:	83 c7 01             	add    $0x1,%edi
  80061b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80061f:	0f be d0             	movsbl %al,%edx
  800622:	85 d2                	test   %edx,%edx
  800624:	74 4b                	je     800671 <vprintfmt+0x23f>
  800626:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80062a:	78 06                	js     800632 <vprintfmt+0x200>
  80062c:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800630:	78 1e                	js     800650 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800632:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800636:	74 d1                	je     800609 <vprintfmt+0x1d7>
  800638:	0f be c0             	movsbl %al,%eax
  80063b:	83 e8 20             	sub    $0x20,%eax
  80063e:	83 f8 5e             	cmp    $0x5e,%eax
  800641:	76 c6                	jbe    800609 <vprintfmt+0x1d7>
					putch('?', putdat);
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	53                   	push   %ebx
  800647:	6a 3f                	push   $0x3f
  800649:	ff d6                	call   *%esi
  80064b:	83 c4 10             	add    $0x10,%esp
  80064e:	eb c3                	jmp    800613 <vprintfmt+0x1e1>
  800650:	89 cf                	mov    %ecx,%edi
  800652:	eb 0e                	jmp    800662 <vprintfmt+0x230>
				putch(' ', putdat);
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	53                   	push   %ebx
  800658:	6a 20                	push   $0x20
  80065a:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80065c:	83 ef 01             	sub    $0x1,%edi
  80065f:	83 c4 10             	add    $0x10,%esp
  800662:	85 ff                	test   %edi,%edi
  800664:	7f ee                	jg     800654 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800666:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800669:	89 45 14             	mov    %eax,0x14(%ebp)
  80066c:	e9 23 01 00 00       	jmp    800794 <vprintfmt+0x362>
  800671:	89 cf                	mov    %ecx,%edi
  800673:	eb ed                	jmp    800662 <vprintfmt+0x230>
	if (lflag >= 2)
  800675:	83 f9 01             	cmp    $0x1,%ecx
  800678:	7f 1b                	jg     800695 <vprintfmt+0x263>
	else if (lflag)
  80067a:	85 c9                	test   %ecx,%ecx
  80067c:	74 63                	je     8006e1 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8b 00                	mov    (%eax),%eax
  800683:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800686:	99                   	cltd   
  800687:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80068a:	8b 45 14             	mov    0x14(%ebp),%eax
  80068d:	8d 40 04             	lea    0x4(%eax),%eax
  800690:	89 45 14             	mov    %eax,0x14(%ebp)
  800693:	eb 17                	jmp    8006ac <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800695:	8b 45 14             	mov    0x14(%ebp),%eax
  800698:	8b 50 04             	mov    0x4(%eax),%edx
  80069b:	8b 00                	mov    (%eax),%eax
  80069d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a6:	8d 40 08             	lea    0x8(%eax),%eax
  8006a9:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8006ac:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006af:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8006b2:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8006b7:	85 c9                	test   %ecx,%ecx
  8006b9:	0f 89 bb 00 00 00    	jns    80077a <vprintfmt+0x348>
				putch('-', putdat);
  8006bf:	83 ec 08             	sub    $0x8,%esp
  8006c2:	53                   	push   %ebx
  8006c3:	6a 2d                	push   $0x2d
  8006c5:	ff d6                	call   *%esi
				num = -(long long) num;
  8006c7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006ca:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006cd:	f7 da                	neg    %edx
  8006cf:	83 d1 00             	adc    $0x0,%ecx
  8006d2:	f7 d9                	neg    %ecx
  8006d4:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006d7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006dc:	e9 99 00 00 00       	jmp    80077a <vprintfmt+0x348>
		return va_arg(*ap, int);
  8006e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e4:	8b 00                	mov    (%eax),%eax
  8006e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e9:	99                   	cltd   
  8006ea:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f0:	8d 40 04             	lea    0x4(%eax),%eax
  8006f3:	89 45 14             	mov    %eax,0x14(%ebp)
  8006f6:	eb b4                	jmp    8006ac <vprintfmt+0x27a>
	if (lflag >= 2)
  8006f8:	83 f9 01             	cmp    $0x1,%ecx
  8006fb:	7f 1b                	jg     800718 <vprintfmt+0x2e6>
	else if (lflag)
  8006fd:	85 c9                	test   %ecx,%ecx
  8006ff:	74 2c                	je     80072d <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800701:	8b 45 14             	mov    0x14(%ebp),%eax
  800704:	8b 10                	mov    (%eax),%edx
  800706:	b9 00 00 00 00       	mov    $0x0,%ecx
  80070b:	8d 40 04             	lea    0x4(%eax),%eax
  80070e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800711:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800716:	eb 62                	jmp    80077a <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800718:	8b 45 14             	mov    0x14(%ebp),%eax
  80071b:	8b 10                	mov    (%eax),%edx
  80071d:	8b 48 04             	mov    0x4(%eax),%ecx
  800720:	8d 40 08             	lea    0x8(%eax),%eax
  800723:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800726:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80072b:	eb 4d                	jmp    80077a <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80072d:	8b 45 14             	mov    0x14(%ebp),%eax
  800730:	8b 10                	mov    (%eax),%edx
  800732:	b9 00 00 00 00       	mov    $0x0,%ecx
  800737:	8d 40 04             	lea    0x4(%eax),%eax
  80073a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80073d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800742:	eb 36                	jmp    80077a <vprintfmt+0x348>
	if (lflag >= 2)
  800744:	83 f9 01             	cmp    $0x1,%ecx
  800747:	7f 17                	jg     800760 <vprintfmt+0x32e>
	else if (lflag)
  800749:	85 c9                	test   %ecx,%ecx
  80074b:	74 6e                	je     8007bb <vprintfmt+0x389>
		return va_arg(*ap, long);
  80074d:	8b 45 14             	mov    0x14(%ebp),%eax
  800750:	8b 10                	mov    (%eax),%edx
  800752:	89 d0                	mov    %edx,%eax
  800754:	99                   	cltd   
  800755:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800758:	8d 49 04             	lea    0x4(%ecx),%ecx
  80075b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80075e:	eb 11                	jmp    800771 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  800760:	8b 45 14             	mov    0x14(%ebp),%eax
  800763:	8b 50 04             	mov    0x4(%eax),%edx
  800766:	8b 00                	mov    (%eax),%eax
  800768:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80076b:	8d 49 08             	lea    0x8(%ecx),%ecx
  80076e:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800771:	89 d1                	mov    %edx,%ecx
  800773:	89 c2                	mov    %eax,%edx
            base = 8;
  800775:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  80077a:	83 ec 0c             	sub    $0xc,%esp
  80077d:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800781:	57                   	push   %edi
  800782:	ff 75 e0             	pushl  -0x20(%ebp)
  800785:	50                   	push   %eax
  800786:	51                   	push   %ecx
  800787:	52                   	push   %edx
  800788:	89 da                	mov    %ebx,%edx
  80078a:	89 f0                	mov    %esi,%eax
  80078c:	e8 b6 fb ff ff       	call   800347 <printnum>
			break;
  800791:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800794:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800797:	83 c7 01             	add    $0x1,%edi
  80079a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80079e:	83 f8 25             	cmp    $0x25,%eax
  8007a1:	0f 84 a6 fc ff ff    	je     80044d <vprintfmt+0x1b>
			if (ch == '\0')
  8007a7:	85 c0                	test   %eax,%eax
  8007a9:	0f 84 ce 00 00 00    	je     80087d <vprintfmt+0x44b>
			putch(ch, putdat);
  8007af:	83 ec 08             	sub    $0x8,%esp
  8007b2:	53                   	push   %ebx
  8007b3:	50                   	push   %eax
  8007b4:	ff d6                	call   *%esi
  8007b6:	83 c4 10             	add    $0x10,%esp
  8007b9:	eb dc                	jmp    800797 <vprintfmt+0x365>
		return va_arg(*ap, int);
  8007bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007be:	8b 10                	mov    (%eax),%edx
  8007c0:	89 d0                	mov    %edx,%eax
  8007c2:	99                   	cltd   
  8007c3:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007c6:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007c9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007cc:	eb a3                	jmp    800771 <vprintfmt+0x33f>
			putch('0', putdat);
  8007ce:	83 ec 08             	sub    $0x8,%esp
  8007d1:	53                   	push   %ebx
  8007d2:	6a 30                	push   $0x30
  8007d4:	ff d6                	call   *%esi
			putch('x', putdat);
  8007d6:	83 c4 08             	add    $0x8,%esp
  8007d9:	53                   	push   %ebx
  8007da:	6a 78                	push   $0x78
  8007dc:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007de:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e1:	8b 10                	mov    (%eax),%edx
  8007e3:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007e8:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8007eb:	8d 40 04             	lea    0x4(%eax),%eax
  8007ee:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007f1:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007f6:	eb 82                	jmp    80077a <vprintfmt+0x348>
	if (lflag >= 2)
  8007f8:	83 f9 01             	cmp    $0x1,%ecx
  8007fb:	7f 1e                	jg     80081b <vprintfmt+0x3e9>
	else if (lflag)
  8007fd:	85 c9                	test   %ecx,%ecx
  8007ff:	74 32                	je     800833 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800801:	8b 45 14             	mov    0x14(%ebp),%eax
  800804:	8b 10                	mov    (%eax),%edx
  800806:	b9 00 00 00 00       	mov    $0x0,%ecx
  80080b:	8d 40 04             	lea    0x4(%eax),%eax
  80080e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800811:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800816:	e9 5f ff ff ff       	jmp    80077a <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80081b:	8b 45 14             	mov    0x14(%ebp),%eax
  80081e:	8b 10                	mov    (%eax),%edx
  800820:	8b 48 04             	mov    0x4(%eax),%ecx
  800823:	8d 40 08             	lea    0x8(%eax),%eax
  800826:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800829:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80082e:	e9 47 ff ff ff       	jmp    80077a <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800833:	8b 45 14             	mov    0x14(%ebp),%eax
  800836:	8b 10                	mov    (%eax),%edx
  800838:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083d:	8d 40 04             	lea    0x4(%eax),%eax
  800840:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800843:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800848:	e9 2d ff ff ff       	jmp    80077a <vprintfmt+0x348>
			putch(ch, putdat);
  80084d:	83 ec 08             	sub    $0x8,%esp
  800850:	53                   	push   %ebx
  800851:	6a 25                	push   $0x25
  800853:	ff d6                	call   *%esi
			break;
  800855:	83 c4 10             	add    $0x10,%esp
  800858:	e9 37 ff ff ff       	jmp    800794 <vprintfmt+0x362>
			putch('%', putdat);
  80085d:	83 ec 08             	sub    $0x8,%esp
  800860:	53                   	push   %ebx
  800861:	6a 25                	push   $0x25
  800863:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800865:	83 c4 10             	add    $0x10,%esp
  800868:	89 f8                	mov    %edi,%eax
  80086a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80086e:	74 05                	je     800875 <vprintfmt+0x443>
  800870:	83 e8 01             	sub    $0x1,%eax
  800873:	eb f5                	jmp    80086a <vprintfmt+0x438>
  800875:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800878:	e9 17 ff ff ff       	jmp    800794 <vprintfmt+0x362>
}
  80087d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800880:	5b                   	pop    %ebx
  800881:	5e                   	pop    %esi
  800882:	5f                   	pop    %edi
  800883:	5d                   	pop    %ebp
  800884:	c3                   	ret    

00800885 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800885:	f3 0f 1e fb          	endbr32 
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	83 ec 18             	sub    $0x18,%esp
  80088f:	8b 45 08             	mov    0x8(%ebp),%eax
  800892:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800895:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800898:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80089c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80089f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008a6:	85 c0                	test   %eax,%eax
  8008a8:	74 26                	je     8008d0 <vsnprintf+0x4b>
  8008aa:	85 d2                	test   %edx,%edx
  8008ac:	7e 22                	jle    8008d0 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008ae:	ff 75 14             	pushl  0x14(%ebp)
  8008b1:	ff 75 10             	pushl  0x10(%ebp)
  8008b4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008b7:	50                   	push   %eax
  8008b8:	68 f0 03 80 00       	push   $0x8003f0
  8008bd:	e8 70 fb ff ff       	call   800432 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008c5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008cb:	83 c4 10             	add    $0x10,%esp
}
  8008ce:	c9                   	leave  
  8008cf:	c3                   	ret    
		return -E_INVAL;
  8008d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008d5:	eb f7                	jmp    8008ce <vsnprintf+0x49>

008008d7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008d7:	f3 0f 1e fb          	endbr32 
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008e1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008e4:	50                   	push   %eax
  8008e5:	ff 75 10             	pushl  0x10(%ebp)
  8008e8:	ff 75 0c             	pushl  0xc(%ebp)
  8008eb:	ff 75 08             	pushl  0x8(%ebp)
  8008ee:	e8 92 ff ff ff       	call   800885 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008f3:	c9                   	leave  
  8008f4:	c3                   	ret    

008008f5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008f5:	f3 0f 1e fb          	endbr32 
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800904:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800908:	74 05                	je     80090f <strlen+0x1a>
		n++;
  80090a:	83 c0 01             	add    $0x1,%eax
  80090d:	eb f5                	jmp    800904 <strlen+0xf>
	return n;
}
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    

00800911 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800911:	f3 0f 1e fb          	endbr32 
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80091b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80091e:	b8 00 00 00 00       	mov    $0x0,%eax
  800923:	39 d0                	cmp    %edx,%eax
  800925:	74 0d                	je     800934 <strnlen+0x23>
  800927:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80092b:	74 05                	je     800932 <strnlen+0x21>
		n++;
  80092d:	83 c0 01             	add    $0x1,%eax
  800930:	eb f1                	jmp    800923 <strnlen+0x12>
  800932:	89 c2                	mov    %eax,%edx
	return n;
}
  800934:	89 d0                	mov    %edx,%eax
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800938:	f3 0f 1e fb          	endbr32 
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	53                   	push   %ebx
  800940:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800943:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800946:	b8 00 00 00 00       	mov    $0x0,%eax
  80094b:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80094f:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800952:	83 c0 01             	add    $0x1,%eax
  800955:	84 d2                	test   %dl,%dl
  800957:	75 f2                	jne    80094b <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800959:	89 c8                	mov    %ecx,%eax
  80095b:	5b                   	pop    %ebx
  80095c:	5d                   	pop    %ebp
  80095d:	c3                   	ret    

0080095e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80095e:	f3 0f 1e fb          	endbr32 
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	53                   	push   %ebx
  800966:	83 ec 10             	sub    $0x10,%esp
  800969:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80096c:	53                   	push   %ebx
  80096d:	e8 83 ff ff ff       	call   8008f5 <strlen>
  800972:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800975:	ff 75 0c             	pushl  0xc(%ebp)
  800978:	01 d8                	add    %ebx,%eax
  80097a:	50                   	push   %eax
  80097b:	e8 b8 ff ff ff       	call   800938 <strcpy>
	return dst;
}
  800980:	89 d8                	mov    %ebx,%eax
  800982:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800985:	c9                   	leave  
  800986:	c3                   	ret    

00800987 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800987:	f3 0f 1e fb          	endbr32 
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	56                   	push   %esi
  80098f:	53                   	push   %ebx
  800990:	8b 75 08             	mov    0x8(%ebp),%esi
  800993:	8b 55 0c             	mov    0xc(%ebp),%edx
  800996:	89 f3                	mov    %esi,%ebx
  800998:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80099b:	89 f0                	mov    %esi,%eax
  80099d:	39 d8                	cmp    %ebx,%eax
  80099f:	74 11                	je     8009b2 <strncpy+0x2b>
		*dst++ = *src;
  8009a1:	83 c0 01             	add    $0x1,%eax
  8009a4:	0f b6 0a             	movzbl (%edx),%ecx
  8009a7:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009aa:	80 f9 01             	cmp    $0x1,%cl
  8009ad:	83 da ff             	sbb    $0xffffffff,%edx
  8009b0:	eb eb                	jmp    80099d <strncpy+0x16>
	}
	return ret;
}
  8009b2:	89 f0                	mov    %esi,%eax
  8009b4:	5b                   	pop    %ebx
  8009b5:	5e                   	pop    %esi
  8009b6:	5d                   	pop    %ebp
  8009b7:	c3                   	ret    

008009b8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009b8:	f3 0f 1e fb          	endbr32 
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	56                   	push   %esi
  8009c0:	53                   	push   %ebx
  8009c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8009c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009c7:	8b 55 10             	mov    0x10(%ebp),%edx
  8009ca:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009cc:	85 d2                	test   %edx,%edx
  8009ce:	74 21                	je     8009f1 <strlcpy+0x39>
  8009d0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009d4:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8009d6:	39 c2                	cmp    %eax,%edx
  8009d8:	74 14                	je     8009ee <strlcpy+0x36>
  8009da:	0f b6 19             	movzbl (%ecx),%ebx
  8009dd:	84 db                	test   %bl,%bl
  8009df:	74 0b                	je     8009ec <strlcpy+0x34>
			*dst++ = *src++;
  8009e1:	83 c1 01             	add    $0x1,%ecx
  8009e4:	83 c2 01             	add    $0x1,%edx
  8009e7:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009ea:	eb ea                	jmp    8009d6 <strlcpy+0x1e>
  8009ec:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8009ee:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009f1:	29 f0                	sub    %esi,%eax
}
  8009f3:	5b                   	pop    %ebx
  8009f4:	5e                   	pop    %esi
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009f7:	f3 0f 1e fb          	endbr32 
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a01:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a04:	0f b6 01             	movzbl (%ecx),%eax
  800a07:	84 c0                	test   %al,%al
  800a09:	74 0c                	je     800a17 <strcmp+0x20>
  800a0b:	3a 02                	cmp    (%edx),%al
  800a0d:	75 08                	jne    800a17 <strcmp+0x20>
		p++, q++;
  800a0f:	83 c1 01             	add    $0x1,%ecx
  800a12:	83 c2 01             	add    $0x1,%edx
  800a15:	eb ed                	jmp    800a04 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a17:	0f b6 c0             	movzbl %al,%eax
  800a1a:	0f b6 12             	movzbl (%edx),%edx
  800a1d:	29 d0                	sub    %edx,%eax
}
  800a1f:	5d                   	pop    %ebp
  800a20:	c3                   	ret    

00800a21 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a21:	f3 0f 1e fb          	endbr32 
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	53                   	push   %ebx
  800a29:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2f:	89 c3                	mov    %eax,%ebx
  800a31:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a34:	eb 06                	jmp    800a3c <strncmp+0x1b>
		n--, p++, q++;
  800a36:	83 c0 01             	add    $0x1,%eax
  800a39:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a3c:	39 d8                	cmp    %ebx,%eax
  800a3e:	74 16                	je     800a56 <strncmp+0x35>
  800a40:	0f b6 08             	movzbl (%eax),%ecx
  800a43:	84 c9                	test   %cl,%cl
  800a45:	74 04                	je     800a4b <strncmp+0x2a>
  800a47:	3a 0a                	cmp    (%edx),%cl
  800a49:	74 eb                	je     800a36 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a4b:	0f b6 00             	movzbl (%eax),%eax
  800a4e:	0f b6 12             	movzbl (%edx),%edx
  800a51:	29 d0                	sub    %edx,%eax
}
  800a53:	5b                   	pop    %ebx
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    
		return 0;
  800a56:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5b:	eb f6                	jmp    800a53 <strncmp+0x32>

00800a5d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a5d:	f3 0f 1e fb          	endbr32 
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	8b 45 08             	mov    0x8(%ebp),%eax
  800a67:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a6b:	0f b6 10             	movzbl (%eax),%edx
  800a6e:	84 d2                	test   %dl,%dl
  800a70:	74 09                	je     800a7b <strchr+0x1e>
		if (*s == c)
  800a72:	38 ca                	cmp    %cl,%dl
  800a74:	74 0a                	je     800a80 <strchr+0x23>
	for (; *s; s++)
  800a76:	83 c0 01             	add    $0x1,%eax
  800a79:	eb f0                	jmp    800a6b <strchr+0xe>
			return (char *) s;
	return 0;
  800a7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a80:	5d                   	pop    %ebp
  800a81:	c3                   	ret    

00800a82 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a82:	f3 0f 1e fb          	endbr32 
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a90:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a93:	38 ca                	cmp    %cl,%dl
  800a95:	74 09                	je     800aa0 <strfind+0x1e>
  800a97:	84 d2                	test   %dl,%dl
  800a99:	74 05                	je     800aa0 <strfind+0x1e>
	for (; *s; s++)
  800a9b:	83 c0 01             	add    $0x1,%eax
  800a9e:	eb f0                	jmp    800a90 <strfind+0xe>
			break;
	return (char *) s;
}
  800aa0:	5d                   	pop    %ebp
  800aa1:	c3                   	ret    

00800aa2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aa2:	f3 0f 1e fb          	endbr32 
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	57                   	push   %edi
  800aaa:	56                   	push   %esi
  800aab:	53                   	push   %ebx
  800aac:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aaf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ab2:	85 c9                	test   %ecx,%ecx
  800ab4:	74 31                	je     800ae7 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ab6:	89 f8                	mov    %edi,%eax
  800ab8:	09 c8                	or     %ecx,%eax
  800aba:	a8 03                	test   $0x3,%al
  800abc:	75 23                	jne    800ae1 <memset+0x3f>
		c &= 0xFF;
  800abe:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ac2:	89 d3                	mov    %edx,%ebx
  800ac4:	c1 e3 08             	shl    $0x8,%ebx
  800ac7:	89 d0                	mov    %edx,%eax
  800ac9:	c1 e0 18             	shl    $0x18,%eax
  800acc:	89 d6                	mov    %edx,%esi
  800ace:	c1 e6 10             	shl    $0x10,%esi
  800ad1:	09 f0                	or     %esi,%eax
  800ad3:	09 c2                	or     %eax,%edx
  800ad5:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ad7:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ada:	89 d0                	mov    %edx,%eax
  800adc:	fc                   	cld    
  800add:	f3 ab                	rep stos %eax,%es:(%edi)
  800adf:	eb 06                	jmp    800ae7 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ae1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae4:	fc                   	cld    
  800ae5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ae7:	89 f8                	mov    %edi,%eax
  800ae9:	5b                   	pop    %ebx
  800aea:	5e                   	pop    %esi
  800aeb:	5f                   	pop    %edi
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aee:	f3 0f 1e fb          	endbr32 
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	57                   	push   %edi
  800af6:	56                   	push   %esi
  800af7:	8b 45 08             	mov    0x8(%ebp),%eax
  800afa:	8b 75 0c             	mov    0xc(%ebp),%esi
  800afd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b00:	39 c6                	cmp    %eax,%esi
  800b02:	73 32                	jae    800b36 <memmove+0x48>
  800b04:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b07:	39 c2                	cmp    %eax,%edx
  800b09:	76 2b                	jbe    800b36 <memmove+0x48>
		s += n;
		d += n;
  800b0b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b0e:	89 fe                	mov    %edi,%esi
  800b10:	09 ce                	or     %ecx,%esi
  800b12:	09 d6                	or     %edx,%esi
  800b14:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b1a:	75 0e                	jne    800b2a <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b1c:	83 ef 04             	sub    $0x4,%edi
  800b1f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b22:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b25:	fd                   	std    
  800b26:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b28:	eb 09                	jmp    800b33 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b2a:	83 ef 01             	sub    $0x1,%edi
  800b2d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b30:	fd                   	std    
  800b31:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b33:	fc                   	cld    
  800b34:	eb 1a                	jmp    800b50 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b36:	89 c2                	mov    %eax,%edx
  800b38:	09 ca                	or     %ecx,%edx
  800b3a:	09 f2                	or     %esi,%edx
  800b3c:	f6 c2 03             	test   $0x3,%dl
  800b3f:	75 0a                	jne    800b4b <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b41:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b44:	89 c7                	mov    %eax,%edi
  800b46:	fc                   	cld    
  800b47:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b49:	eb 05                	jmp    800b50 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800b4b:	89 c7                	mov    %eax,%edi
  800b4d:	fc                   	cld    
  800b4e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b50:	5e                   	pop    %esi
  800b51:	5f                   	pop    %edi
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b54:	f3 0f 1e fb          	endbr32 
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b5e:	ff 75 10             	pushl  0x10(%ebp)
  800b61:	ff 75 0c             	pushl  0xc(%ebp)
  800b64:	ff 75 08             	pushl  0x8(%ebp)
  800b67:	e8 82 ff ff ff       	call   800aee <memmove>
}
  800b6c:	c9                   	leave  
  800b6d:	c3                   	ret    

00800b6e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b6e:	f3 0f 1e fb          	endbr32 
  800b72:	55                   	push   %ebp
  800b73:	89 e5                	mov    %esp,%ebp
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
  800b77:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b7d:	89 c6                	mov    %eax,%esi
  800b7f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b82:	39 f0                	cmp    %esi,%eax
  800b84:	74 1c                	je     800ba2 <memcmp+0x34>
		if (*s1 != *s2)
  800b86:	0f b6 08             	movzbl (%eax),%ecx
  800b89:	0f b6 1a             	movzbl (%edx),%ebx
  800b8c:	38 d9                	cmp    %bl,%cl
  800b8e:	75 08                	jne    800b98 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b90:	83 c0 01             	add    $0x1,%eax
  800b93:	83 c2 01             	add    $0x1,%edx
  800b96:	eb ea                	jmp    800b82 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800b98:	0f b6 c1             	movzbl %cl,%eax
  800b9b:	0f b6 db             	movzbl %bl,%ebx
  800b9e:	29 d8                	sub    %ebx,%eax
  800ba0:	eb 05                	jmp    800ba7 <memcmp+0x39>
	}

	return 0;
  800ba2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ba7:	5b                   	pop    %ebx
  800ba8:	5e                   	pop    %esi
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    

00800bab <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bab:	f3 0f 1e fb          	endbr32 
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bb8:	89 c2                	mov    %eax,%edx
  800bba:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bbd:	39 d0                	cmp    %edx,%eax
  800bbf:	73 09                	jae    800bca <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc1:	38 08                	cmp    %cl,(%eax)
  800bc3:	74 05                	je     800bca <memfind+0x1f>
	for (; s < ends; s++)
  800bc5:	83 c0 01             	add    $0x1,%eax
  800bc8:	eb f3                	jmp    800bbd <memfind+0x12>
			break;
	return (void *) s;
}
  800bca:	5d                   	pop    %ebp
  800bcb:	c3                   	ret    

00800bcc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bcc:	f3 0f 1e fb          	endbr32 
  800bd0:	55                   	push   %ebp
  800bd1:	89 e5                	mov    %esp,%ebp
  800bd3:	57                   	push   %edi
  800bd4:	56                   	push   %esi
  800bd5:	53                   	push   %ebx
  800bd6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bdc:	eb 03                	jmp    800be1 <strtol+0x15>
		s++;
  800bde:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800be1:	0f b6 01             	movzbl (%ecx),%eax
  800be4:	3c 20                	cmp    $0x20,%al
  800be6:	74 f6                	je     800bde <strtol+0x12>
  800be8:	3c 09                	cmp    $0x9,%al
  800bea:	74 f2                	je     800bde <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800bec:	3c 2b                	cmp    $0x2b,%al
  800bee:	74 2a                	je     800c1a <strtol+0x4e>
	int neg = 0;
  800bf0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800bf5:	3c 2d                	cmp    $0x2d,%al
  800bf7:	74 2b                	je     800c24 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bf9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bff:	75 0f                	jne    800c10 <strtol+0x44>
  800c01:	80 39 30             	cmpb   $0x30,(%ecx)
  800c04:	74 28                	je     800c2e <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c06:	85 db                	test   %ebx,%ebx
  800c08:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c0d:	0f 44 d8             	cmove  %eax,%ebx
  800c10:	b8 00 00 00 00       	mov    $0x0,%eax
  800c15:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c18:	eb 46                	jmp    800c60 <strtol+0x94>
		s++;
  800c1a:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800c1d:	bf 00 00 00 00       	mov    $0x0,%edi
  800c22:	eb d5                	jmp    800bf9 <strtol+0x2d>
		s++, neg = 1;
  800c24:	83 c1 01             	add    $0x1,%ecx
  800c27:	bf 01 00 00 00       	mov    $0x1,%edi
  800c2c:	eb cb                	jmp    800bf9 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c2e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c32:	74 0e                	je     800c42 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c34:	85 db                	test   %ebx,%ebx
  800c36:	75 d8                	jne    800c10 <strtol+0x44>
		s++, base = 8;
  800c38:	83 c1 01             	add    $0x1,%ecx
  800c3b:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c40:	eb ce                	jmp    800c10 <strtol+0x44>
		s += 2, base = 16;
  800c42:	83 c1 02             	add    $0x2,%ecx
  800c45:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c4a:	eb c4                	jmp    800c10 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800c4c:	0f be d2             	movsbl %dl,%edx
  800c4f:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c52:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c55:	7d 3a                	jge    800c91 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c57:	83 c1 01             	add    $0x1,%ecx
  800c5a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c5e:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c60:	0f b6 11             	movzbl (%ecx),%edx
  800c63:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c66:	89 f3                	mov    %esi,%ebx
  800c68:	80 fb 09             	cmp    $0x9,%bl
  800c6b:	76 df                	jbe    800c4c <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800c6d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c70:	89 f3                	mov    %esi,%ebx
  800c72:	80 fb 19             	cmp    $0x19,%bl
  800c75:	77 08                	ja     800c7f <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c77:	0f be d2             	movsbl %dl,%edx
  800c7a:	83 ea 57             	sub    $0x57,%edx
  800c7d:	eb d3                	jmp    800c52 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800c7f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c82:	89 f3                	mov    %esi,%ebx
  800c84:	80 fb 19             	cmp    $0x19,%bl
  800c87:	77 08                	ja     800c91 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c89:	0f be d2             	movsbl %dl,%edx
  800c8c:	83 ea 37             	sub    $0x37,%edx
  800c8f:	eb c1                	jmp    800c52 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c91:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c95:	74 05                	je     800c9c <strtol+0xd0>
		*endptr = (char *) s;
  800c97:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c9a:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c9c:	89 c2                	mov    %eax,%edx
  800c9e:	f7 da                	neg    %edx
  800ca0:	85 ff                	test   %edi,%edi
  800ca2:	0f 45 c2             	cmovne %edx,%eax
}
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    

00800caa <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800caa:	f3 0f 1e fb          	endbr32 
  800cae:	55                   	push   %ebp
  800caf:	89 e5                	mov    %esp,%ebp
  800cb1:	57                   	push   %edi
  800cb2:	56                   	push   %esi
  800cb3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cb4:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbf:	89 c3                	mov    %eax,%ebx
  800cc1:	89 c7                	mov    %eax,%edi
  800cc3:	89 c6                	mov    %eax,%esi
  800cc5:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <sys_cgetc>:

int
sys_cgetc(void)
{
  800ccc:	f3 0f 1e fb          	endbr32 
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	57                   	push   %edi
  800cd4:	56                   	push   %esi
  800cd5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cd6:	ba 00 00 00 00       	mov    $0x0,%edx
  800cdb:	b8 01 00 00 00       	mov    $0x1,%eax
  800ce0:	89 d1                	mov    %edx,%ecx
  800ce2:	89 d3                	mov    %edx,%ebx
  800ce4:	89 d7                	mov    %edx,%edi
  800ce6:	89 d6                	mov    %edx,%esi
  800ce8:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cea:	5b                   	pop    %ebx
  800ceb:	5e                   	pop    %esi
  800cec:	5f                   	pop    %edi
  800ced:	5d                   	pop    %ebp
  800cee:	c3                   	ret    

00800cef <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cef:	f3 0f 1e fb          	endbr32 
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	57                   	push   %edi
  800cf7:	56                   	push   %esi
  800cf8:	53                   	push   %ebx
  800cf9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cfc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d01:	8b 55 08             	mov    0x8(%ebp),%edx
  800d04:	b8 03 00 00 00       	mov    $0x3,%eax
  800d09:	89 cb                	mov    %ecx,%ebx
  800d0b:	89 cf                	mov    %ecx,%edi
  800d0d:	89 ce                	mov    %ecx,%esi
  800d0f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d11:	85 c0                	test   %eax,%eax
  800d13:	7f 08                	jg     800d1d <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d18:	5b                   	pop    %ebx
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1d:	83 ec 0c             	sub    $0xc,%esp
  800d20:	50                   	push   %eax
  800d21:	6a 03                	push   $0x3
  800d23:	68 bf 15 80 00       	push   $0x8015bf
  800d28:	6a 23                	push   $0x23
  800d2a:	68 dc 15 80 00       	push   $0x8015dc
  800d2f:	e8 14 f5 ff ff       	call   800248 <_panic>

00800d34 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d34:	f3 0f 1e fb          	endbr32 
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	57                   	push   %edi
  800d3c:	56                   	push   %esi
  800d3d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d43:	b8 02 00 00 00       	mov    $0x2,%eax
  800d48:	89 d1                	mov    %edx,%ecx
  800d4a:	89 d3                	mov    %edx,%ebx
  800d4c:	89 d7                	mov    %edx,%edi
  800d4e:	89 d6                	mov    %edx,%esi
  800d50:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d52:	5b                   	pop    %ebx
  800d53:	5e                   	pop    %esi
  800d54:	5f                   	pop    %edi
  800d55:	5d                   	pop    %ebp
  800d56:	c3                   	ret    

00800d57 <sys_yield>:

void
sys_yield(void)
{
  800d57:	f3 0f 1e fb          	endbr32 
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	57                   	push   %edi
  800d5f:	56                   	push   %esi
  800d60:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d61:	ba 00 00 00 00       	mov    $0x0,%edx
  800d66:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d6b:	89 d1                	mov    %edx,%ecx
  800d6d:	89 d3                	mov    %edx,%ebx
  800d6f:	89 d7                	mov    %edx,%edi
  800d71:	89 d6                	mov    %edx,%esi
  800d73:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d75:	5b                   	pop    %ebx
  800d76:	5e                   	pop    %esi
  800d77:	5f                   	pop    %edi
  800d78:	5d                   	pop    %ebp
  800d79:	c3                   	ret    

00800d7a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d7a:	f3 0f 1e fb          	endbr32 
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	57                   	push   %edi
  800d82:	56                   	push   %esi
  800d83:	53                   	push   %ebx
  800d84:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d87:	be 00 00 00 00       	mov    $0x0,%esi
  800d8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d92:	b8 04 00 00 00       	mov    $0x4,%eax
  800d97:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9a:	89 f7                	mov    %esi,%edi
  800d9c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d9e:	85 c0                	test   %eax,%eax
  800da0:	7f 08                	jg     800daa <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800da2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da5:	5b                   	pop    %ebx
  800da6:	5e                   	pop    %esi
  800da7:	5f                   	pop    %edi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800daa:	83 ec 0c             	sub    $0xc,%esp
  800dad:	50                   	push   %eax
  800dae:	6a 04                	push   $0x4
  800db0:	68 bf 15 80 00       	push   $0x8015bf
  800db5:	6a 23                	push   $0x23
  800db7:	68 dc 15 80 00       	push   $0x8015dc
  800dbc:	e8 87 f4 ff ff       	call   800248 <_panic>

00800dc1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dc1:	f3 0f 1e fb          	endbr32 
  800dc5:	55                   	push   %ebp
  800dc6:	89 e5                	mov    %esp,%ebp
  800dc8:	57                   	push   %edi
  800dc9:	56                   	push   %esi
  800dca:	53                   	push   %ebx
  800dcb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dce:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd4:	b8 05 00 00 00       	mov    $0x5,%eax
  800dd9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ddc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ddf:	8b 75 18             	mov    0x18(%ebp),%esi
  800de2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800de4:	85 c0                	test   %eax,%eax
  800de6:	7f 08                	jg     800df0 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800de8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800deb:	5b                   	pop    %ebx
  800dec:	5e                   	pop    %esi
  800ded:	5f                   	pop    %edi
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800df0:	83 ec 0c             	sub    $0xc,%esp
  800df3:	50                   	push   %eax
  800df4:	6a 05                	push   $0x5
  800df6:	68 bf 15 80 00       	push   $0x8015bf
  800dfb:	6a 23                	push   $0x23
  800dfd:	68 dc 15 80 00       	push   $0x8015dc
  800e02:	e8 41 f4 ff ff       	call   800248 <_panic>

00800e07 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e07:	f3 0f 1e fb          	endbr32 
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
  800e0e:	57                   	push   %edi
  800e0f:	56                   	push   %esi
  800e10:	53                   	push   %ebx
  800e11:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e14:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e19:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1f:	b8 06 00 00 00       	mov    $0x6,%eax
  800e24:	89 df                	mov    %ebx,%edi
  800e26:	89 de                	mov    %ebx,%esi
  800e28:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e2a:	85 c0                	test   %eax,%eax
  800e2c:	7f 08                	jg     800e36 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e31:	5b                   	pop    %ebx
  800e32:	5e                   	pop    %esi
  800e33:	5f                   	pop    %edi
  800e34:	5d                   	pop    %ebp
  800e35:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e36:	83 ec 0c             	sub    $0xc,%esp
  800e39:	50                   	push   %eax
  800e3a:	6a 06                	push   $0x6
  800e3c:	68 bf 15 80 00       	push   $0x8015bf
  800e41:	6a 23                	push   $0x23
  800e43:	68 dc 15 80 00       	push   $0x8015dc
  800e48:	e8 fb f3 ff ff       	call   800248 <_panic>

00800e4d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e4d:	f3 0f 1e fb          	endbr32 
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
  800e54:	57                   	push   %edi
  800e55:	56                   	push   %esi
  800e56:	53                   	push   %ebx
  800e57:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e5a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e65:	b8 08 00 00 00       	mov    $0x8,%eax
  800e6a:	89 df                	mov    %ebx,%edi
  800e6c:	89 de                	mov    %ebx,%esi
  800e6e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e70:	85 c0                	test   %eax,%eax
  800e72:	7f 08                	jg     800e7c <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e77:	5b                   	pop    %ebx
  800e78:	5e                   	pop    %esi
  800e79:	5f                   	pop    %edi
  800e7a:	5d                   	pop    %ebp
  800e7b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7c:	83 ec 0c             	sub    $0xc,%esp
  800e7f:	50                   	push   %eax
  800e80:	6a 08                	push   $0x8
  800e82:	68 bf 15 80 00       	push   $0x8015bf
  800e87:	6a 23                	push   $0x23
  800e89:	68 dc 15 80 00       	push   $0x8015dc
  800e8e:	e8 b5 f3 ff ff       	call   800248 <_panic>

00800e93 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e93:	f3 0f 1e fb          	endbr32 
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	57                   	push   %edi
  800e9b:	56                   	push   %esi
  800e9c:	53                   	push   %ebx
  800e9d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ea0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eab:	b8 09 00 00 00       	mov    $0x9,%eax
  800eb0:	89 df                	mov    %ebx,%edi
  800eb2:	89 de                	mov    %ebx,%esi
  800eb4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eb6:	85 c0                	test   %eax,%eax
  800eb8:	7f 08                	jg     800ec2 <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800eba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ebd:	5b                   	pop    %ebx
  800ebe:	5e                   	pop    %esi
  800ebf:	5f                   	pop    %edi
  800ec0:	5d                   	pop    %ebp
  800ec1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec2:	83 ec 0c             	sub    $0xc,%esp
  800ec5:	50                   	push   %eax
  800ec6:	6a 09                	push   $0x9
  800ec8:	68 bf 15 80 00       	push   $0x8015bf
  800ecd:	6a 23                	push   $0x23
  800ecf:	68 dc 15 80 00       	push   $0x8015dc
  800ed4:	e8 6f f3 ff ff       	call   800248 <_panic>

00800ed9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ed9:	f3 0f 1e fb          	endbr32 
  800edd:	55                   	push   %ebp
  800ede:	89 e5                	mov    %esp,%ebp
  800ee0:	57                   	push   %edi
  800ee1:	56                   	push   %esi
  800ee2:	53                   	push   %ebx
  800ee3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ee6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eeb:	8b 55 08             	mov    0x8(%ebp),%edx
  800eee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ef6:	89 df                	mov    %ebx,%edi
  800ef8:	89 de                	mov    %ebx,%esi
  800efa:	cd 30                	int    $0x30
	if(check && ret > 0)
  800efc:	85 c0                	test   %eax,%eax
  800efe:	7f 08                	jg     800f08 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f03:	5b                   	pop    %ebx
  800f04:	5e                   	pop    %esi
  800f05:	5f                   	pop    %edi
  800f06:	5d                   	pop    %ebp
  800f07:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f08:	83 ec 0c             	sub    $0xc,%esp
  800f0b:	50                   	push   %eax
  800f0c:	6a 0a                	push   $0xa
  800f0e:	68 bf 15 80 00       	push   $0x8015bf
  800f13:	6a 23                	push   $0x23
  800f15:	68 dc 15 80 00       	push   $0x8015dc
  800f1a:	e8 29 f3 ff ff       	call   800248 <_panic>

00800f1f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f1f:	f3 0f 1e fb          	endbr32 
  800f23:	55                   	push   %ebp
  800f24:	89 e5                	mov    %esp,%ebp
  800f26:	57                   	push   %edi
  800f27:	56                   	push   %esi
  800f28:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f29:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f2f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f34:	be 00 00 00 00       	mov    $0x0,%esi
  800f39:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f3c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f3f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f41:	5b                   	pop    %ebx
  800f42:	5e                   	pop    %esi
  800f43:	5f                   	pop    %edi
  800f44:	5d                   	pop    %ebp
  800f45:	c3                   	ret    

00800f46 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f46:	f3 0f 1e fb          	endbr32 
  800f4a:	55                   	push   %ebp
  800f4b:	89 e5                	mov    %esp,%ebp
  800f4d:	57                   	push   %edi
  800f4e:	56                   	push   %esi
  800f4f:	53                   	push   %ebx
  800f50:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f53:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f58:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f60:	89 cb                	mov    %ecx,%ebx
  800f62:	89 cf                	mov    %ecx,%edi
  800f64:	89 ce                	mov    %ecx,%esi
  800f66:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f68:	85 c0                	test   %eax,%eax
  800f6a:	7f 08                	jg     800f74 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f6f:	5b                   	pop    %ebx
  800f70:	5e                   	pop    %esi
  800f71:	5f                   	pop    %edi
  800f72:	5d                   	pop    %ebp
  800f73:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f74:	83 ec 0c             	sub    $0xc,%esp
  800f77:	50                   	push   %eax
  800f78:	6a 0d                	push   $0xd
  800f7a:	68 bf 15 80 00       	push   $0x8015bf
  800f7f:	6a 23                	push   $0x23
  800f81:	68 dc 15 80 00       	push   $0x8015dc
  800f86:	e8 bd f2 ff ff       	call   800248 <_panic>
  800f8b:	66 90                	xchg   %ax,%ax
  800f8d:	66 90                	xchg   %ax,%ax
  800f8f:	90                   	nop

00800f90 <__udivdi3>:
  800f90:	f3 0f 1e fb          	endbr32 
  800f94:	55                   	push   %ebp
  800f95:	57                   	push   %edi
  800f96:	56                   	push   %esi
  800f97:	53                   	push   %ebx
  800f98:	83 ec 1c             	sub    $0x1c,%esp
  800f9b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f9f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800fa3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800fa7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800fab:	85 d2                	test   %edx,%edx
  800fad:	75 19                	jne    800fc8 <__udivdi3+0x38>
  800faf:	39 f3                	cmp    %esi,%ebx
  800fb1:	76 4d                	jbe    801000 <__udivdi3+0x70>
  800fb3:	31 ff                	xor    %edi,%edi
  800fb5:	89 e8                	mov    %ebp,%eax
  800fb7:	89 f2                	mov    %esi,%edx
  800fb9:	f7 f3                	div    %ebx
  800fbb:	89 fa                	mov    %edi,%edx
  800fbd:	83 c4 1c             	add    $0x1c,%esp
  800fc0:	5b                   	pop    %ebx
  800fc1:	5e                   	pop    %esi
  800fc2:	5f                   	pop    %edi
  800fc3:	5d                   	pop    %ebp
  800fc4:	c3                   	ret    
  800fc5:	8d 76 00             	lea    0x0(%esi),%esi
  800fc8:	39 f2                	cmp    %esi,%edx
  800fca:	76 14                	jbe    800fe0 <__udivdi3+0x50>
  800fcc:	31 ff                	xor    %edi,%edi
  800fce:	31 c0                	xor    %eax,%eax
  800fd0:	89 fa                	mov    %edi,%edx
  800fd2:	83 c4 1c             	add    $0x1c,%esp
  800fd5:	5b                   	pop    %ebx
  800fd6:	5e                   	pop    %esi
  800fd7:	5f                   	pop    %edi
  800fd8:	5d                   	pop    %ebp
  800fd9:	c3                   	ret    
  800fda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fe0:	0f bd fa             	bsr    %edx,%edi
  800fe3:	83 f7 1f             	xor    $0x1f,%edi
  800fe6:	75 48                	jne    801030 <__udivdi3+0xa0>
  800fe8:	39 f2                	cmp    %esi,%edx
  800fea:	72 06                	jb     800ff2 <__udivdi3+0x62>
  800fec:	31 c0                	xor    %eax,%eax
  800fee:	39 eb                	cmp    %ebp,%ebx
  800ff0:	77 de                	ja     800fd0 <__udivdi3+0x40>
  800ff2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ff7:	eb d7                	jmp    800fd0 <__udivdi3+0x40>
  800ff9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801000:	89 d9                	mov    %ebx,%ecx
  801002:	85 db                	test   %ebx,%ebx
  801004:	75 0b                	jne    801011 <__udivdi3+0x81>
  801006:	b8 01 00 00 00       	mov    $0x1,%eax
  80100b:	31 d2                	xor    %edx,%edx
  80100d:	f7 f3                	div    %ebx
  80100f:	89 c1                	mov    %eax,%ecx
  801011:	31 d2                	xor    %edx,%edx
  801013:	89 f0                	mov    %esi,%eax
  801015:	f7 f1                	div    %ecx
  801017:	89 c6                	mov    %eax,%esi
  801019:	89 e8                	mov    %ebp,%eax
  80101b:	89 f7                	mov    %esi,%edi
  80101d:	f7 f1                	div    %ecx
  80101f:	89 fa                	mov    %edi,%edx
  801021:	83 c4 1c             	add    $0x1c,%esp
  801024:	5b                   	pop    %ebx
  801025:	5e                   	pop    %esi
  801026:	5f                   	pop    %edi
  801027:	5d                   	pop    %ebp
  801028:	c3                   	ret    
  801029:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801030:	89 f9                	mov    %edi,%ecx
  801032:	b8 20 00 00 00       	mov    $0x20,%eax
  801037:	29 f8                	sub    %edi,%eax
  801039:	d3 e2                	shl    %cl,%edx
  80103b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80103f:	89 c1                	mov    %eax,%ecx
  801041:	89 da                	mov    %ebx,%edx
  801043:	d3 ea                	shr    %cl,%edx
  801045:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801049:	09 d1                	or     %edx,%ecx
  80104b:	89 f2                	mov    %esi,%edx
  80104d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801051:	89 f9                	mov    %edi,%ecx
  801053:	d3 e3                	shl    %cl,%ebx
  801055:	89 c1                	mov    %eax,%ecx
  801057:	d3 ea                	shr    %cl,%edx
  801059:	89 f9                	mov    %edi,%ecx
  80105b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80105f:	89 eb                	mov    %ebp,%ebx
  801061:	d3 e6                	shl    %cl,%esi
  801063:	89 c1                	mov    %eax,%ecx
  801065:	d3 eb                	shr    %cl,%ebx
  801067:	09 de                	or     %ebx,%esi
  801069:	89 f0                	mov    %esi,%eax
  80106b:	f7 74 24 08          	divl   0x8(%esp)
  80106f:	89 d6                	mov    %edx,%esi
  801071:	89 c3                	mov    %eax,%ebx
  801073:	f7 64 24 0c          	mull   0xc(%esp)
  801077:	39 d6                	cmp    %edx,%esi
  801079:	72 15                	jb     801090 <__udivdi3+0x100>
  80107b:	89 f9                	mov    %edi,%ecx
  80107d:	d3 e5                	shl    %cl,%ebp
  80107f:	39 c5                	cmp    %eax,%ebp
  801081:	73 04                	jae    801087 <__udivdi3+0xf7>
  801083:	39 d6                	cmp    %edx,%esi
  801085:	74 09                	je     801090 <__udivdi3+0x100>
  801087:	89 d8                	mov    %ebx,%eax
  801089:	31 ff                	xor    %edi,%edi
  80108b:	e9 40 ff ff ff       	jmp    800fd0 <__udivdi3+0x40>
  801090:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801093:	31 ff                	xor    %edi,%edi
  801095:	e9 36 ff ff ff       	jmp    800fd0 <__udivdi3+0x40>
  80109a:	66 90                	xchg   %ax,%ax
  80109c:	66 90                	xchg   %ax,%ax
  80109e:	66 90                	xchg   %ax,%ax

008010a0 <__umoddi3>:
  8010a0:	f3 0f 1e fb          	endbr32 
  8010a4:	55                   	push   %ebp
  8010a5:	57                   	push   %edi
  8010a6:	56                   	push   %esi
  8010a7:	53                   	push   %ebx
  8010a8:	83 ec 1c             	sub    $0x1c,%esp
  8010ab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8010af:	8b 74 24 30          	mov    0x30(%esp),%esi
  8010b3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8010b7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8010bb:	85 c0                	test   %eax,%eax
  8010bd:	75 19                	jne    8010d8 <__umoddi3+0x38>
  8010bf:	39 df                	cmp    %ebx,%edi
  8010c1:	76 5d                	jbe    801120 <__umoddi3+0x80>
  8010c3:	89 f0                	mov    %esi,%eax
  8010c5:	89 da                	mov    %ebx,%edx
  8010c7:	f7 f7                	div    %edi
  8010c9:	89 d0                	mov    %edx,%eax
  8010cb:	31 d2                	xor    %edx,%edx
  8010cd:	83 c4 1c             	add    $0x1c,%esp
  8010d0:	5b                   	pop    %ebx
  8010d1:	5e                   	pop    %esi
  8010d2:	5f                   	pop    %edi
  8010d3:	5d                   	pop    %ebp
  8010d4:	c3                   	ret    
  8010d5:	8d 76 00             	lea    0x0(%esi),%esi
  8010d8:	89 f2                	mov    %esi,%edx
  8010da:	39 d8                	cmp    %ebx,%eax
  8010dc:	76 12                	jbe    8010f0 <__umoddi3+0x50>
  8010de:	89 f0                	mov    %esi,%eax
  8010e0:	89 da                	mov    %ebx,%edx
  8010e2:	83 c4 1c             	add    $0x1c,%esp
  8010e5:	5b                   	pop    %ebx
  8010e6:	5e                   	pop    %esi
  8010e7:	5f                   	pop    %edi
  8010e8:	5d                   	pop    %ebp
  8010e9:	c3                   	ret    
  8010ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010f0:	0f bd e8             	bsr    %eax,%ebp
  8010f3:	83 f5 1f             	xor    $0x1f,%ebp
  8010f6:	75 50                	jne    801148 <__umoddi3+0xa8>
  8010f8:	39 d8                	cmp    %ebx,%eax
  8010fa:	0f 82 e0 00 00 00    	jb     8011e0 <__umoddi3+0x140>
  801100:	89 d9                	mov    %ebx,%ecx
  801102:	39 f7                	cmp    %esi,%edi
  801104:	0f 86 d6 00 00 00    	jbe    8011e0 <__umoddi3+0x140>
  80110a:	89 d0                	mov    %edx,%eax
  80110c:	89 ca                	mov    %ecx,%edx
  80110e:	83 c4 1c             	add    $0x1c,%esp
  801111:	5b                   	pop    %ebx
  801112:	5e                   	pop    %esi
  801113:	5f                   	pop    %edi
  801114:	5d                   	pop    %ebp
  801115:	c3                   	ret    
  801116:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80111d:	8d 76 00             	lea    0x0(%esi),%esi
  801120:	89 fd                	mov    %edi,%ebp
  801122:	85 ff                	test   %edi,%edi
  801124:	75 0b                	jne    801131 <__umoddi3+0x91>
  801126:	b8 01 00 00 00       	mov    $0x1,%eax
  80112b:	31 d2                	xor    %edx,%edx
  80112d:	f7 f7                	div    %edi
  80112f:	89 c5                	mov    %eax,%ebp
  801131:	89 d8                	mov    %ebx,%eax
  801133:	31 d2                	xor    %edx,%edx
  801135:	f7 f5                	div    %ebp
  801137:	89 f0                	mov    %esi,%eax
  801139:	f7 f5                	div    %ebp
  80113b:	89 d0                	mov    %edx,%eax
  80113d:	31 d2                	xor    %edx,%edx
  80113f:	eb 8c                	jmp    8010cd <__umoddi3+0x2d>
  801141:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801148:	89 e9                	mov    %ebp,%ecx
  80114a:	ba 20 00 00 00       	mov    $0x20,%edx
  80114f:	29 ea                	sub    %ebp,%edx
  801151:	d3 e0                	shl    %cl,%eax
  801153:	89 44 24 08          	mov    %eax,0x8(%esp)
  801157:	89 d1                	mov    %edx,%ecx
  801159:	89 f8                	mov    %edi,%eax
  80115b:	d3 e8                	shr    %cl,%eax
  80115d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801161:	89 54 24 04          	mov    %edx,0x4(%esp)
  801165:	8b 54 24 04          	mov    0x4(%esp),%edx
  801169:	09 c1                	or     %eax,%ecx
  80116b:	89 d8                	mov    %ebx,%eax
  80116d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801171:	89 e9                	mov    %ebp,%ecx
  801173:	d3 e7                	shl    %cl,%edi
  801175:	89 d1                	mov    %edx,%ecx
  801177:	d3 e8                	shr    %cl,%eax
  801179:	89 e9                	mov    %ebp,%ecx
  80117b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80117f:	d3 e3                	shl    %cl,%ebx
  801181:	89 c7                	mov    %eax,%edi
  801183:	89 d1                	mov    %edx,%ecx
  801185:	89 f0                	mov    %esi,%eax
  801187:	d3 e8                	shr    %cl,%eax
  801189:	89 e9                	mov    %ebp,%ecx
  80118b:	89 fa                	mov    %edi,%edx
  80118d:	d3 e6                	shl    %cl,%esi
  80118f:	09 d8                	or     %ebx,%eax
  801191:	f7 74 24 08          	divl   0x8(%esp)
  801195:	89 d1                	mov    %edx,%ecx
  801197:	89 f3                	mov    %esi,%ebx
  801199:	f7 64 24 0c          	mull   0xc(%esp)
  80119d:	89 c6                	mov    %eax,%esi
  80119f:	89 d7                	mov    %edx,%edi
  8011a1:	39 d1                	cmp    %edx,%ecx
  8011a3:	72 06                	jb     8011ab <__umoddi3+0x10b>
  8011a5:	75 10                	jne    8011b7 <__umoddi3+0x117>
  8011a7:	39 c3                	cmp    %eax,%ebx
  8011a9:	73 0c                	jae    8011b7 <__umoddi3+0x117>
  8011ab:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8011af:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8011b3:	89 d7                	mov    %edx,%edi
  8011b5:	89 c6                	mov    %eax,%esi
  8011b7:	89 ca                	mov    %ecx,%edx
  8011b9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011be:	29 f3                	sub    %esi,%ebx
  8011c0:	19 fa                	sbb    %edi,%edx
  8011c2:	89 d0                	mov    %edx,%eax
  8011c4:	d3 e0                	shl    %cl,%eax
  8011c6:	89 e9                	mov    %ebp,%ecx
  8011c8:	d3 eb                	shr    %cl,%ebx
  8011ca:	d3 ea                	shr    %cl,%edx
  8011cc:	09 d8                	or     %ebx,%eax
  8011ce:	83 c4 1c             	add    $0x1c,%esp
  8011d1:	5b                   	pop    %ebx
  8011d2:	5e                   	pop    %esi
  8011d3:	5f                   	pop    %edi
  8011d4:	5d                   	pop    %ebp
  8011d5:	c3                   	ret    
  8011d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011dd:	8d 76 00             	lea    0x0(%esi),%esi
  8011e0:	29 fe                	sub    %edi,%esi
  8011e2:	19 c3                	sbb    %eax,%ebx
  8011e4:	89 f2                	mov    %esi,%edx
  8011e6:	89 d9                	mov    %ebx,%ecx
  8011e8:	e9 1d ff ff ff       	jmp    80110a <__umoddi3+0x6a>
