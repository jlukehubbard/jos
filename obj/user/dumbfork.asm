
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
  800049:	e8 22 0d 00 00       	call   800d70 <sys_page_alloc>
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
  800063:	e8 4f 0d 00 00       	call   800db7 <sys_page_map>
  800068:	83 c4 20             	add    $0x20,%esp
  80006b:	85 c0                	test   %eax,%eax
  80006d:	78 42                	js     8000b1 <duppage+0x7e>
		panic("sys_page_map: %e", r);
	memmove(UTEMP, addr, PGSIZE);
  80006f:	83 ec 04             	sub    $0x4,%esp
  800072:	68 00 10 00 00       	push   $0x1000
  800077:	53                   	push   %ebx
  800078:	68 00 00 40 00       	push   $0x400000
  80007d:	e8 62 0a 00 00       	call   800ae4 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800082:	83 c4 08             	add    $0x8,%esp
  800085:	68 00 00 40 00       	push   $0x400000
  80008a:	6a 00                	push   $0x0
  80008c:	e8 6c 0d 00 00       	call   800dfd <sys_page_unmap>
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
  8000a0:	68 a0 11 80 00       	push   $0x8011a0
  8000a5:	6a 20                	push   $0x20
  8000a7:	68 b3 11 80 00       	push   $0x8011b3
  8000ac:	e8 8d 01 00 00       	call   80023e <_panic>
		panic("sys_page_map: %e", r);
  8000b1:	50                   	push   %eax
  8000b2:	68 c3 11 80 00       	push   $0x8011c3
  8000b7:	6a 22                	push   $0x22
  8000b9:	68 b3 11 80 00       	push   $0x8011b3
  8000be:	e8 7b 01 00 00       	call   80023e <_panic>
		panic("sys_page_unmap: %e", r);
  8000c3:	50                   	push   %eax
  8000c4:	68 d4 11 80 00       	push   $0x8011d4
  8000c9:	6a 25                	push   $0x25
  8000cb:	68 b3 11 80 00       	push   $0x8011b3
  8000d0:	e8 69 01 00 00       	call   80023e <_panic>

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
  8000fc:	68 e7 11 80 00       	push   $0x8011e7
  800101:	6a 37                	push   $0x37
  800103:	68 b3 11 80 00       	push   $0x8011b3
  800108:	e8 31 01 00 00       	call   80023e <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
  80010d:	e8 18 0c 00 00       	call   800d2a <sys_getenvid>
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
  80015d:	e8 e1 0c 00 00       	call   800e43 <sys_env_set_status>
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
  800173:	68 f7 11 80 00       	push   $0x8011f7
  800178:	6a 4c                	push   $0x4c
  80017a:	68 b3 11 80 00       	push   $0x8011b3
  80017f:	e8 ba 00 00 00       	call   80023e <_panic>

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
  80019a:	bf 0e 12 80 00       	mov    $0x80120e,%edi
  80019f:	b8 15 12 80 00       	mov    $0x801215,%eax
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
  8001b8:	68 1b 12 80 00       	push   $0x80121b
  8001bd:	e8 63 01 00 00       	call   800325 <cprintf>
		sys_yield();
  8001c2:	e8 86 0b 00 00       	call   800d4d <sys_yield>
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
    envid_t envid = sys_getenvid();
  8001ed:	e8 38 0b 00 00       	call   800d2a <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  8001f2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001fa:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001ff:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800204:	85 db                	test   %ebx,%ebx
  800206:	7e 07                	jle    80020f <libmain+0x31>
		binaryname = argv[0];
  800208:	8b 06                	mov    (%esi),%eax
  80020a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80020f:	83 ec 08             	sub    $0x8,%esp
  800212:	56                   	push   %esi
  800213:	53                   	push   %ebx
  800214:	e8 6b ff ff ff       	call   800184 <umain>

	// exit gracefully
	exit();
  800219:	e8 0a 00 00 00       	call   800228 <exit>
}
  80021e:	83 c4 10             	add    $0x10,%esp
  800221:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800224:	5b                   	pop    %ebx
  800225:	5e                   	pop    %esi
  800226:	5d                   	pop    %ebp
  800227:	c3                   	ret    

00800228 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800228:	f3 0f 1e fb          	endbr32 
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800232:	6a 00                	push   $0x0
  800234:	e8 ac 0a 00 00       	call   800ce5 <sys_env_destroy>
}
  800239:	83 c4 10             	add    $0x10,%esp
  80023c:	c9                   	leave  
  80023d:	c3                   	ret    

0080023e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80023e:	f3 0f 1e fb          	endbr32 
  800242:	55                   	push   %ebp
  800243:	89 e5                	mov    %esp,%ebp
  800245:	56                   	push   %esi
  800246:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800247:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80024a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800250:	e8 d5 0a 00 00       	call   800d2a <sys_getenvid>
  800255:	83 ec 0c             	sub    $0xc,%esp
  800258:	ff 75 0c             	pushl  0xc(%ebp)
  80025b:	ff 75 08             	pushl  0x8(%ebp)
  80025e:	56                   	push   %esi
  80025f:	50                   	push   %eax
  800260:	68 38 12 80 00       	push   $0x801238
  800265:	e8 bb 00 00 00       	call   800325 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80026a:	83 c4 18             	add    $0x18,%esp
  80026d:	53                   	push   %ebx
  80026e:	ff 75 10             	pushl  0x10(%ebp)
  800271:	e8 5a 00 00 00       	call   8002d0 <vcprintf>
	cprintf("\n");
  800276:	c7 04 24 2b 12 80 00 	movl   $0x80122b,(%esp)
  80027d:	e8 a3 00 00 00       	call   800325 <cprintf>
  800282:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800285:	cc                   	int3   
  800286:	eb fd                	jmp    800285 <_panic+0x47>

00800288 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800288:	f3 0f 1e fb          	endbr32 
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	53                   	push   %ebx
  800290:	83 ec 04             	sub    $0x4,%esp
  800293:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800296:	8b 13                	mov    (%ebx),%edx
  800298:	8d 42 01             	lea    0x1(%edx),%eax
  80029b:	89 03                	mov    %eax,(%ebx)
  80029d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002a4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a9:	74 09                	je     8002b4 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8002ab:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002b2:	c9                   	leave  
  8002b3:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8002b4:	83 ec 08             	sub    $0x8,%esp
  8002b7:	68 ff 00 00 00       	push   $0xff
  8002bc:	8d 43 08             	lea    0x8(%ebx),%eax
  8002bf:	50                   	push   %eax
  8002c0:	e8 db 09 00 00       	call   800ca0 <sys_cputs>
		b->idx = 0;
  8002c5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002cb:	83 c4 10             	add    $0x10,%esp
  8002ce:	eb db                	jmp    8002ab <putch+0x23>

008002d0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002d0:	f3 0f 1e fb          	endbr32 
  8002d4:	55                   	push   %ebp
  8002d5:	89 e5                	mov    %esp,%ebp
  8002d7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002dd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002e4:	00 00 00 
	b.cnt = 0;
  8002e7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002ee:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002f1:	ff 75 0c             	pushl  0xc(%ebp)
  8002f4:	ff 75 08             	pushl  0x8(%ebp)
  8002f7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002fd:	50                   	push   %eax
  8002fe:	68 88 02 80 00       	push   $0x800288
  800303:	e8 20 01 00 00       	call   800428 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800308:	83 c4 08             	add    $0x8,%esp
  80030b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800311:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800317:	50                   	push   %eax
  800318:	e8 83 09 00 00       	call   800ca0 <sys_cputs>

	return b.cnt;
}
  80031d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800325:	f3 0f 1e fb          	endbr32 
  800329:	55                   	push   %ebp
  80032a:	89 e5                	mov    %esp,%ebp
  80032c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80032f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800332:	50                   	push   %eax
  800333:	ff 75 08             	pushl  0x8(%ebp)
  800336:	e8 95 ff ff ff       	call   8002d0 <vcprintf>
	va_end(ap);

	return cnt;
}
  80033b:	c9                   	leave  
  80033c:	c3                   	ret    

0080033d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80033d:	55                   	push   %ebp
  80033e:	89 e5                	mov    %esp,%ebp
  800340:	57                   	push   %edi
  800341:	56                   	push   %esi
  800342:	53                   	push   %ebx
  800343:	83 ec 1c             	sub    $0x1c,%esp
  800346:	89 c7                	mov    %eax,%edi
  800348:	89 d6                	mov    %edx,%esi
  80034a:	8b 45 08             	mov    0x8(%ebp),%eax
  80034d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800350:	89 d1                	mov    %edx,%ecx
  800352:	89 c2                	mov    %eax,%edx
  800354:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800357:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80035a:	8b 45 10             	mov    0x10(%ebp),%eax
  80035d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800360:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800363:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80036a:	39 c2                	cmp    %eax,%edx
  80036c:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80036f:	72 3e                	jb     8003af <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800371:	83 ec 0c             	sub    $0xc,%esp
  800374:	ff 75 18             	pushl  0x18(%ebp)
  800377:	83 eb 01             	sub    $0x1,%ebx
  80037a:	53                   	push   %ebx
  80037b:	50                   	push   %eax
  80037c:	83 ec 08             	sub    $0x8,%esp
  80037f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800382:	ff 75 e0             	pushl  -0x20(%ebp)
  800385:	ff 75 dc             	pushl  -0x24(%ebp)
  800388:	ff 75 d8             	pushl  -0x28(%ebp)
  80038b:	e8 b0 0b 00 00       	call   800f40 <__udivdi3>
  800390:	83 c4 18             	add    $0x18,%esp
  800393:	52                   	push   %edx
  800394:	50                   	push   %eax
  800395:	89 f2                	mov    %esi,%edx
  800397:	89 f8                	mov    %edi,%eax
  800399:	e8 9f ff ff ff       	call   80033d <printnum>
  80039e:	83 c4 20             	add    $0x20,%esp
  8003a1:	eb 13                	jmp    8003b6 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	56                   	push   %esi
  8003a7:	ff 75 18             	pushl  0x18(%ebp)
  8003aa:	ff d7                	call   *%edi
  8003ac:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8003af:	83 eb 01             	sub    $0x1,%ebx
  8003b2:	85 db                	test   %ebx,%ebx
  8003b4:	7f ed                	jg     8003a3 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003b6:	83 ec 08             	sub    $0x8,%esp
  8003b9:	56                   	push   %esi
  8003ba:	83 ec 04             	sub    $0x4,%esp
  8003bd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8003c3:	ff 75 dc             	pushl  -0x24(%ebp)
  8003c6:	ff 75 d8             	pushl  -0x28(%ebp)
  8003c9:	e8 82 0c 00 00       	call   801050 <__umoddi3>
  8003ce:	83 c4 14             	add    $0x14,%esp
  8003d1:	0f be 80 5b 12 80 00 	movsbl 0x80125b(%eax),%eax
  8003d8:	50                   	push   %eax
  8003d9:	ff d7                	call   *%edi
}
  8003db:	83 c4 10             	add    $0x10,%esp
  8003de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003e1:	5b                   	pop    %ebx
  8003e2:	5e                   	pop    %esi
  8003e3:	5f                   	pop    %edi
  8003e4:	5d                   	pop    %ebp
  8003e5:	c3                   	ret    

008003e6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003e6:	f3 0f 1e fb          	endbr32 
  8003ea:	55                   	push   %ebp
  8003eb:	89 e5                	mov    %esp,%ebp
  8003ed:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003f0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003f4:	8b 10                	mov    (%eax),%edx
  8003f6:	3b 50 04             	cmp    0x4(%eax),%edx
  8003f9:	73 0a                	jae    800405 <sprintputch+0x1f>
		*b->buf++ = ch;
  8003fb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003fe:	89 08                	mov    %ecx,(%eax)
  800400:	8b 45 08             	mov    0x8(%ebp),%eax
  800403:	88 02                	mov    %al,(%edx)
}
  800405:	5d                   	pop    %ebp
  800406:	c3                   	ret    

00800407 <printfmt>:
{
  800407:	f3 0f 1e fb          	endbr32 
  80040b:	55                   	push   %ebp
  80040c:	89 e5                	mov    %esp,%ebp
  80040e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800411:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800414:	50                   	push   %eax
  800415:	ff 75 10             	pushl  0x10(%ebp)
  800418:	ff 75 0c             	pushl  0xc(%ebp)
  80041b:	ff 75 08             	pushl  0x8(%ebp)
  80041e:	e8 05 00 00 00       	call   800428 <vprintfmt>
}
  800423:	83 c4 10             	add    $0x10,%esp
  800426:	c9                   	leave  
  800427:	c3                   	ret    

00800428 <vprintfmt>:
{
  800428:	f3 0f 1e fb          	endbr32 
  80042c:	55                   	push   %ebp
  80042d:	89 e5                	mov    %esp,%ebp
  80042f:	57                   	push   %edi
  800430:	56                   	push   %esi
  800431:	53                   	push   %ebx
  800432:	83 ec 3c             	sub    $0x3c,%esp
  800435:	8b 75 08             	mov    0x8(%ebp),%esi
  800438:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80043b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80043e:	e9 4a 03 00 00       	jmp    80078d <vprintfmt+0x365>
		padc = ' ';
  800443:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800447:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80044e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800455:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80045c:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800461:	8d 47 01             	lea    0x1(%edi),%eax
  800464:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800467:	0f b6 17             	movzbl (%edi),%edx
  80046a:	8d 42 dd             	lea    -0x23(%edx),%eax
  80046d:	3c 55                	cmp    $0x55,%al
  80046f:	0f 87 de 03 00 00    	ja     800853 <vprintfmt+0x42b>
  800475:	0f b6 c0             	movzbl %al,%eax
  800478:	3e ff 24 85 20 13 80 	notrack jmp *0x801320(,%eax,4)
  80047f:	00 
  800480:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800483:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800487:	eb d8                	jmp    800461 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800489:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80048c:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800490:	eb cf                	jmp    800461 <vprintfmt+0x39>
  800492:	0f b6 d2             	movzbl %dl,%edx
  800495:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800498:	b8 00 00 00 00       	mov    $0x0,%eax
  80049d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8004a0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004a3:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8004a7:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004aa:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004ad:	83 f9 09             	cmp    $0x9,%ecx
  8004b0:	77 55                	ja     800507 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8004b2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004b5:	eb e9                	jmp    8004a0 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8004b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ba:	8b 00                	mov    (%eax),%eax
  8004bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c2:	8d 40 04             	lea    0x4(%eax),%eax
  8004c5:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8004cb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004cf:	79 90                	jns    800461 <vprintfmt+0x39>
				width = precision, precision = -1;
  8004d1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d7:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8004de:	eb 81                	jmp    800461 <vprintfmt+0x39>
  8004e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004e3:	85 c0                	test   %eax,%eax
  8004e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ea:	0f 49 d0             	cmovns %eax,%edx
  8004ed:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004f3:	e9 69 ff ff ff       	jmp    800461 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8004f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8004fb:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800502:	e9 5a ff ff ff       	jmp    800461 <vprintfmt+0x39>
  800507:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80050a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80050d:	eb bc                	jmp    8004cb <vprintfmt+0xa3>
			lflag++;
  80050f:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800512:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800515:	e9 47 ff ff ff       	jmp    800461 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80051a:	8b 45 14             	mov    0x14(%ebp),%eax
  80051d:	8d 78 04             	lea    0x4(%eax),%edi
  800520:	83 ec 08             	sub    $0x8,%esp
  800523:	53                   	push   %ebx
  800524:	ff 30                	pushl  (%eax)
  800526:	ff d6                	call   *%esi
			break;
  800528:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80052b:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80052e:	e9 57 02 00 00       	jmp    80078a <vprintfmt+0x362>
			err = va_arg(ap, int);
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8d 78 04             	lea    0x4(%eax),%edi
  800539:	8b 00                	mov    (%eax),%eax
  80053b:	99                   	cltd   
  80053c:	31 d0                	xor    %edx,%eax
  80053e:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800540:	83 f8 08             	cmp    $0x8,%eax
  800543:	7f 23                	jg     800568 <vprintfmt+0x140>
  800545:	8b 14 85 80 14 80 00 	mov    0x801480(,%eax,4),%edx
  80054c:	85 d2                	test   %edx,%edx
  80054e:	74 18                	je     800568 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800550:	52                   	push   %edx
  800551:	68 7c 12 80 00       	push   $0x80127c
  800556:	53                   	push   %ebx
  800557:	56                   	push   %esi
  800558:	e8 aa fe ff ff       	call   800407 <printfmt>
  80055d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800560:	89 7d 14             	mov    %edi,0x14(%ebp)
  800563:	e9 22 02 00 00       	jmp    80078a <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  800568:	50                   	push   %eax
  800569:	68 73 12 80 00       	push   $0x801273
  80056e:	53                   	push   %ebx
  80056f:	56                   	push   %esi
  800570:	e8 92 fe ff ff       	call   800407 <printfmt>
  800575:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800578:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80057b:	e9 0a 02 00 00       	jmp    80078a <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  800580:	8b 45 14             	mov    0x14(%ebp),%eax
  800583:	83 c0 04             	add    $0x4,%eax
  800586:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800589:	8b 45 14             	mov    0x14(%ebp),%eax
  80058c:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80058e:	85 d2                	test   %edx,%edx
  800590:	b8 6c 12 80 00       	mov    $0x80126c,%eax
  800595:	0f 45 c2             	cmovne %edx,%eax
  800598:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80059b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80059f:	7e 06                	jle    8005a7 <vprintfmt+0x17f>
  8005a1:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8005a5:	75 0d                	jne    8005b4 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a7:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005aa:	89 c7                	mov    %eax,%edi
  8005ac:	03 45 e0             	add    -0x20(%ebp),%eax
  8005af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005b2:	eb 55                	jmp    800609 <vprintfmt+0x1e1>
  8005b4:	83 ec 08             	sub    $0x8,%esp
  8005b7:	ff 75 d8             	pushl  -0x28(%ebp)
  8005ba:	ff 75 cc             	pushl  -0x34(%ebp)
  8005bd:	e8 45 03 00 00       	call   800907 <strnlen>
  8005c2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005c5:	29 c2                	sub    %eax,%edx
  8005c7:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8005ca:	83 c4 10             	add    $0x10,%esp
  8005cd:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8005cf:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8005d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d6:	85 ff                	test   %edi,%edi
  8005d8:	7e 11                	jle    8005eb <vprintfmt+0x1c3>
					putch(padc, putdat);
  8005da:	83 ec 08             	sub    $0x8,%esp
  8005dd:	53                   	push   %ebx
  8005de:	ff 75 e0             	pushl  -0x20(%ebp)
  8005e1:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e3:	83 ef 01             	sub    $0x1,%edi
  8005e6:	83 c4 10             	add    $0x10,%esp
  8005e9:	eb eb                	jmp    8005d6 <vprintfmt+0x1ae>
  8005eb:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005ee:	85 d2                	test   %edx,%edx
  8005f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f5:	0f 49 c2             	cmovns %edx,%eax
  8005f8:	29 c2                	sub    %eax,%edx
  8005fa:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005fd:	eb a8                	jmp    8005a7 <vprintfmt+0x17f>
					putch(ch, putdat);
  8005ff:	83 ec 08             	sub    $0x8,%esp
  800602:	53                   	push   %ebx
  800603:	52                   	push   %edx
  800604:	ff d6                	call   *%esi
  800606:	83 c4 10             	add    $0x10,%esp
  800609:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80060c:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80060e:	83 c7 01             	add    $0x1,%edi
  800611:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800615:	0f be d0             	movsbl %al,%edx
  800618:	85 d2                	test   %edx,%edx
  80061a:	74 4b                	je     800667 <vprintfmt+0x23f>
  80061c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800620:	78 06                	js     800628 <vprintfmt+0x200>
  800622:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800626:	78 1e                	js     800646 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800628:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80062c:	74 d1                	je     8005ff <vprintfmt+0x1d7>
  80062e:	0f be c0             	movsbl %al,%eax
  800631:	83 e8 20             	sub    $0x20,%eax
  800634:	83 f8 5e             	cmp    $0x5e,%eax
  800637:	76 c6                	jbe    8005ff <vprintfmt+0x1d7>
					putch('?', putdat);
  800639:	83 ec 08             	sub    $0x8,%esp
  80063c:	53                   	push   %ebx
  80063d:	6a 3f                	push   $0x3f
  80063f:	ff d6                	call   *%esi
  800641:	83 c4 10             	add    $0x10,%esp
  800644:	eb c3                	jmp    800609 <vprintfmt+0x1e1>
  800646:	89 cf                	mov    %ecx,%edi
  800648:	eb 0e                	jmp    800658 <vprintfmt+0x230>
				putch(' ', putdat);
  80064a:	83 ec 08             	sub    $0x8,%esp
  80064d:	53                   	push   %ebx
  80064e:	6a 20                	push   $0x20
  800650:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800652:	83 ef 01             	sub    $0x1,%edi
  800655:	83 c4 10             	add    $0x10,%esp
  800658:	85 ff                	test   %edi,%edi
  80065a:	7f ee                	jg     80064a <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80065c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80065f:	89 45 14             	mov    %eax,0x14(%ebp)
  800662:	e9 23 01 00 00       	jmp    80078a <vprintfmt+0x362>
  800667:	89 cf                	mov    %ecx,%edi
  800669:	eb ed                	jmp    800658 <vprintfmt+0x230>
	if (lflag >= 2)
  80066b:	83 f9 01             	cmp    $0x1,%ecx
  80066e:	7f 1b                	jg     80068b <vprintfmt+0x263>
	else if (lflag)
  800670:	85 c9                	test   %ecx,%ecx
  800672:	74 63                	je     8006d7 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800674:	8b 45 14             	mov    0x14(%ebp),%eax
  800677:	8b 00                	mov    (%eax),%eax
  800679:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067c:	99                   	cltd   
  80067d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8d 40 04             	lea    0x4(%eax),%eax
  800686:	89 45 14             	mov    %eax,0x14(%ebp)
  800689:	eb 17                	jmp    8006a2 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80068b:	8b 45 14             	mov    0x14(%ebp),%eax
  80068e:	8b 50 04             	mov    0x4(%eax),%edx
  800691:	8b 00                	mov    (%eax),%eax
  800693:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800696:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800699:	8b 45 14             	mov    0x14(%ebp),%eax
  80069c:	8d 40 08             	lea    0x8(%eax),%eax
  80069f:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8006a2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006a5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8006a8:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8006ad:	85 c9                	test   %ecx,%ecx
  8006af:	0f 89 bb 00 00 00    	jns    800770 <vprintfmt+0x348>
				putch('-', putdat);
  8006b5:	83 ec 08             	sub    $0x8,%esp
  8006b8:	53                   	push   %ebx
  8006b9:	6a 2d                	push   $0x2d
  8006bb:	ff d6                	call   *%esi
				num = -(long long) num;
  8006bd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006c0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006c3:	f7 da                	neg    %edx
  8006c5:	83 d1 00             	adc    $0x0,%ecx
  8006c8:	f7 d9                	neg    %ecx
  8006ca:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006cd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d2:	e9 99 00 00 00       	jmp    800770 <vprintfmt+0x348>
		return va_arg(*ap, int);
  8006d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006da:	8b 00                	mov    (%eax),%eax
  8006dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006df:	99                   	cltd   
  8006e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e6:	8d 40 04             	lea    0x4(%eax),%eax
  8006e9:	89 45 14             	mov    %eax,0x14(%ebp)
  8006ec:	eb b4                	jmp    8006a2 <vprintfmt+0x27a>
	if (lflag >= 2)
  8006ee:	83 f9 01             	cmp    $0x1,%ecx
  8006f1:	7f 1b                	jg     80070e <vprintfmt+0x2e6>
	else if (lflag)
  8006f3:	85 c9                	test   %ecx,%ecx
  8006f5:	74 2c                	je     800723 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  8006f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fa:	8b 10                	mov    (%eax),%edx
  8006fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800701:	8d 40 04             	lea    0x4(%eax),%eax
  800704:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800707:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80070c:	eb 62                	jmp    800770 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80070e:	8b 45 14             	mov    0x14(%ebp),%eax
  800711:	8b 10                	mov    (%eax),%edx
  800713:	8b 48 04             	mov    0x4(%eax),%ecx
  800716:	8d 40 08             	lea    0x8(%eax),%eax
  800719:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80071c:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800721:	eb 4d                	jmp    800770 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800723:	8b 45 14             	mov    0x14(%ebp),%eax
  800726:	8b 10                	mov    (%eax),%edx
  800728:	b9 00 00 00 00       	mov    $0x0,%ecx
  80072d:	8d 40 04             	lea    0x4(%eax),%eax
  800730:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800733:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800738:	eb 36                	jmp    800770 <vprintfmt+0x348>
	if (lflag >= 2)
  80073a:	83 f9 01             	cmp    $0x1,%ecx
  80073d:	7f 17                	jg     800756 <vprintfmt+0x32e>
	else if (lflag)
  80073f:	85 c9                	test   %ecx,%ecx
  800741:	74 6e                	je     8007b1 <vprintfmt+0x389>
		return va_arg(*ap, long);
  800743:	8b 45 14             	mov    0x14(%ebp),%eax
  800746:	8b 10                	mov    (%eax),%edx
  800748:	89 d0                	mov    %edx,%eax
  80074a:	99                   	cltd   
  80074b:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80074e:	8d 49 04             	lea    0x4(%ecx),%ecx
  800751:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800754:	eb 11                	jmp    800767 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  800756:	8b 45 14             	mov    0x14(%ebp),%eax
  800759:	8b 50 04             	mov    0x4(%eax),%edx
  80075c:	8b 00                	mov    (%eax),%eax
  80075e:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800761:	8d 49 08             	lea    0x8(%ecx),%ecx
  800764:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800767:	89 d1                	mov    %edx,%ecx
  800769:	89 c2                	mov    %eax,%edx
            base = 8;
  80076b:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800770:	83 ec 0c             	sub    $0xc,%esp
  800773:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800777:	57                   	push   %edi
  800778:	ff 75 e0             	pushl  -0x20(%ebp)
  80077b:	50                   	push   %eax
  80077c:	51                   	push   %ecx
  80077d:	52                   	push   %edx
  80077e:	89 da                	mov    %ebx,%edx
  800780:	89 f0                	mov    %esi,%eax
  800782:	e8 b6 fb ff ff       	call   80033d <printnum>
			break;
  800787:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80078a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80078d:	83 c7 01             	add    $0x1,%edi
  800790:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800794:	83 f8 25             	cmp    $0x25,%eax
  800797:	0f 84 a6 fc ff ff    	je     800443 <vprintfmt+0x1b>
			if (ch == '\0')
  80079d:	85 c0                	test   %eax,%eax
  80079f:	0f 84 ce 00 00 00    	je     800873 <vprintfmt+0x44b>
			putch(ch, putdat);
  8007a5:	83 ec 08             	sub    $0x8,%esp
  8007a8:	53                   	push   %ebx
  8007a9:	50                   	push   %eax
  8007aa:	ff d6                	call   *%esi
  8007ac:	83 c4 10             	add    $0x10,%esp
  8007af:	eb dc                	jmp    80078d <vprintfmt+0x365>
		return va_arg(*ap, int);
  8007b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b4:	8b 10                	mov    (%eax),%edx
  8007b6:	89 d0                	mov    %edx,%eax
  8007b8:	99                   	cltd   
  8007b9:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007bc:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007bf:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007c2:	eb a3                	jmp    800767 <vprintfmt+0x33f>
			putch('0', putdat);
  8007c4:	83 ec 08             	sub    $0x8,%esp
  8007c7:	53                   	push   %ebx
  8007c8:	6a 30                	push   $0x30
  8007ca:	ff d6                	call   *%esi
			putch('x', putdat);
  8007cc:	83 c4 08             	add    $0x8,%esp
  8007cf:	53                   	push   %ebx
  8007d0:	6a 78                	push   $0x78
  8007d2:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d7:	8b 10                	mov    (%eax),%edx
  8007d9:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007de:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8007e1:	8d 40 04             	lea    0x4(%eax),%eax
  8007e4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007e7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007ec:	eb 82                	jmp    800770 <vprintfmt+0x348>
	if (lflag >= 2)
  8007ee:	83 f9 01             	cmp    $0x1,%ecx
  8007f1:	7f 1e                	jg     800811 <vprintfmt+0x3e9>
	else if (lflag)
  8007f3:	85 c9                	test   %ecx,%ecx
  8007f5:	74 32                	je     800829 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  8007f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fa:	8b 10                	mov    (%eax),%edx
  8007fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800801:	8d 40 04             	lea    0x4(%eax),%eax
  800804:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800807:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80080c:	e9 5f ff ff ff       	jmp    800770 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800811:	8b 45 14             	mov    0x14(%ebp),%eax
  800814:	8b 10                	mov    (%eax),%edx
  800816:	8b 48 04             	mov    0x4(%eax),%ecx
  800819:	8d 40 08             	lea    0x8(%eax),%eax
  80081c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80081f:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800824:	e9 47 ff ff ff       	jmp    800770 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800829:	8b 45 14             	mov    0x14(%ebp),%eax
  80082c:	8b 10                	mov    (%eax),%edx
  80082e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800833:	8d 40 04             	lea    0x4(%eax),%eax
  800836:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800839:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80083e:	e9 2d ff ff ff       	jmp    800770 <vprintfmt+0x348>
			putch(ch, putdat);
  800843:	83 ec 08             	sub    $0x8,%esp
  800846:	53                   	push   %ebx
  800847:	6a 25                	push   $0x25
  800849:	ff d6                	call   *%esi
			break;
  80084b:	83 c4 10             	add    $0x10,%esp
  80084e:	e9 37 ff ff ff       	jmp    80078a <vprintfmt+0x362>
			putch('%', putdat);
  800853:	83 ec 08             	sub    $0x8,%esp
  800856:	53                   	push   %ebx
  800857:	6a 25                	push   $0x25
  800859:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80085b:	83 c4 10             	add    $0x10,%esp
  80085e:	89 f8                	mov    %edi,%eax
  800860:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800864:	74 05                	je     80086b <vprintfmt+0x443>
  800866:	83 e8 01             	sub    $0x1,%eax
  800869:	eb f5                	jmp    800860 <vprintfmt+0x438>
  80086b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80086e:	e9 17 ff ff ff       	jmp    80078a <vprintfmt+0x362>
}
  800873:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800876:	5b                   	pop    %ebx
  800877:	5e                   	pop    %esi
  800878:	5f                   	pop    %edi
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80087b:	f3 0f 1e fb          	endbr32 
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	83 ec 18             	sub    $0x18,%esp
  800885:	8b 45 08             	mov    0x8(%ebp),%eax
  800888:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80088b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80088e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800892:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800895:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80089c:	85 c0                	test   %eax,%eax
  80089e:	74 26                	je     8008c6 <vsnprintf+0x4b>
  8008a0:	85 d2                	test   %edx,%edx
  8008a2:	7e 22                	jle    8008c6 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008a4:	ff 75 14             	pushl  0x14(%ebp)
  8008a7:	ff 75 10             	pushl  0x10(%ebp)
  8008aa:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008ad:	50                   	push   %eax
  8008ae:	68 e6 03 80 00       	push   $0x8003e6
  8008b3:	e8 70 fb ff ff       	call   800428 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008bb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c1:	83 c4 10             	add    $0x10,%esp
}
  8008c4:	c9                   	leave  
  8008c5:	c3                   	ret    
		return -E_INVAL;
  8008c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008cb:	eb f7                	jmp    8008c4 <vsnprintf+0x49>

008008cd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008cd:	f3 0f 1e fb          	endbr32 
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008d7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008da:	50                   	push   %eax
  8008db:	ff 75 10             	pushl  0x10(%ebp)
  8008de:	ff 75 0c             	pushl  0xc(%ebp)
  8008e1:	ff 75 08             	pushl  0x8(%ebp)
  8008e4:	e8 92 ff ff ff       	call   80087b <vsnprintf>
	va_end(ap);

	return rc;
}
  8008e9:	c9                   	leave  
  8008ea:	c3                   	ret    

008008eb <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008eb:	f3 0f 1e fb          	endbr32 
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fa:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008fe:	74 05                	je     800905 <strlen+0x1a>
		n++;
  800900:	83 c0 01             	add    $0x1,%eax
  800903:	eb f5                	jmp    8008fa <strlen+0xf>
	return n;
}
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800907:	f3 0f 1e fb          	endbr32 
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800911:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800914:	b8 00 00 00 00       	mov    $0x0,%eax
  800919:	39 d0                	cmp    %edx,%eax
  80091b:	74 0d                	je     80092a <strnlen+0x23>
  80091d:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800921:	74 05                	je     800928 <strnlen+0x21>
		n++;
  800923:	83 c0 01             	add    $0x1,%eax
  800926:	eb f1                	jmp    800919 <strnlen+0x12>
  800928:	89 c2                	mov    %eax,%edx
	return n;
}
  80092a:	89 d0                	mov    %edx,%eax
  80092c:	5d                   	pop    %ebp
  80092d:	c3                   	ret    

0080092e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80092e:	f3 0f 1e fb          	endbr32 
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	53                   	push   %ebx
  800936:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800939:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80093c:	b8 00 00 00 00       	mov    $0x0,%eax
  800941:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800945:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800948:	83 c0 01             	add    $0x1,%eax
  80094b:	84 d2                	test   %dl,%dl
  80094d:	75 f2                	jne    800941 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80094f:	89 c8                	mov    %ecx,%eax
  800951:	5b                   	pop    %ebx
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800954:	f3 0f 1e fb          	endbr32 
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	53                   	push   %ebx
  80095c:	83 ec 10             	sub    $0x10,%esp
  80095f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800962:	53                   	push   %ebx
  800963:	e8 83 ff ff ff       	call   8008eb <strlen>
  800968:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80096b:	ff 75 0c             	pushl  0xc(%ebp)
  80096e:	01 d8                	add    %ebx,%eax
  800970:	50                   	push   %eax
  800971:	e8 b8 ff ff ff       	call   80092e <strcpy>
	return dst;
}
  800976:	89 d8                	mov    %ebx,%eax
  800978:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80097b:	c9                   	leave  
  80097c:	c3                   	ret    

0080097d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80097d:	f3 0f 1e fb          	endbr32 
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	56                   	push   %esi
  800985:	53                   	push   %ebx
  800986:	8b 75 08             	mov    0x8(%ebp),%esi
  800989:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098c:	89 f3                	mov    %esi,%ebx
  80098e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800991:	89 f0                	mov    %esi,%eax
  800993:	39 d8                	cmp    %ebx,%eax
  800995:	74 11                	je     8009a8 <strncpy+0x2b>
		*dst++ = *src;
  800997:	83 c0 01             	add    $0x1,%eax
  80099a:	0f b6 0a             	movzbl (%edx),%ecx
  80099d:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009a0:	80 f9 01             	cmp    $0x1,%cl
  8009a3:	83 da ff             	sbb    $0xffffffff,%edx
  8009a6:	eb eb                	jmp    800993 <strncpy+0x16>
	}
	return ret;
}
  8009a8:	89 f0                	mov    %esi,%eax
  8009aa:	5b                   	pop    %ebx
  8009ab:	5e                   	pop    %esi
  8009ac:	5d                   	pop    %ebp
  8009ad:	c3                   	ret    

008009ae <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009ae:	f3 0f 1e fb          	endbr32 
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	56                   	push   %esi
  8009b6:	53                   	push   %ebx
  8009b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009bd:	8b 55 10             	mov    0x10(%ebp),%edx
  8009c0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009c2:	85 d2                	test   %edx,%edx
  8009c4:	74 21                	je     8009e7 <strlcpy+0x39>
  8009c6:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009ca:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8009cc:	39 c2                	cmp    %eax,%edx
  8009ce:	74 14                	je     8009e4 <strlcpy+0x36>
  8009d0:	0f b6 19             	movzbl (%ecx),%ebx
  8009d3:	84 db                	test   %bl,%bl
  8009d5:	74 0b                	je     8009e2 <strlcpy+0x34>
			*dst++ = *src++;
  8009d7:	83 c1 01             	add    $0x1,%ecx
  8009da:	83 c2 01             	add    $0x1,%edx
  8009dd:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009e0:	eb ea                	jmp    8009cc <strlcpy+0x1e>
  8009e2:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8009e4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009e7:	29 f0                	sub    %esi,%eax
}
  8009e9:	5b                   	pop    %ebx
  8009ea:	5e                   	pop    %esi
  8009eb:	5d                   	pop    %ebp
  8009ec:	c3                   	ret    

008009ed <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009ed:	f3 0f 1e fb          	endbr32 
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009fa:	0f b6 01             	movzbl (%ecx),%eax
  8009fd:	84 c0                	test   %al,%al
  8009ff:	74 0c                	je     800a0d <strcmp+0x20>
  800a01:	3a 02                	cmp    (%edx),%al
  800a03:	75 08                	jne    800a0d <strcmp+0x20>
		p++, q++;
  800a05:	83 c1 01             	add    $0x1,%ecx
  800a08:	83 c2 01             	add    $0x1,%edx
  800a0b:	eb ed                	jmp    8009fa <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a0d:	0f b6 c0             	movzbl %al,%eax
  800a10:	0f b6 12             	movzbl (%edx),%edx
  800a13:	29 d0                	sub    %edx,%eax
}
  800a15:	5d                   	pop    %ebp
  800a16:	c3                   	ret    

00800a17 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a17:	f3 0f 1e fb          	endbr32 
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	53                   	push   %ebx
  800a1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a22:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a25:	89 c3                	mov    %eax,%ebx
  800a27:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a2a:	eb 06                	jmp    800a32 <strncmp+0x1b>
		n--, p++, q++;
  800a2c:	83 c0 01             	add    $0x1,%eax
  800a2f:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a32:	39 d8                	cmp    %ebx,%eax
  800a34:	74 16                	je     800a4c <strncmp+0x35>
  800a36:	0f b6 08             	movzbl (%eax),%ecx
  800a39:	84 c9                	test   %cl,%cl
  800a3b:	74 04                	je     800a41 <strncmp+0x2a>
  800a3d:	3a 0a                	cmp    (%edx),%cl
  800a3f:	74 eb                	je     800a2c <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a41:	0f b6 00             	movzbl (%eax),%eax
  800a44:	0f b6 12             	movzbl (%edx),%edx
  800a47:	29 d0                	sub    %edx,%eax
}
  800a49:	5b                   	pop    %ebx
  800a4a:	5d                   	pop    %ebp
  800a4b:	c3                   	ret    
		return 0;
  800a4c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a51:	eb f6                	jmp    800a49 <strncmp+0x32>

00800a53 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a53:	f3 0f 1e fb          	endbr32 
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a61:	0f b6 10             	movzbl (%eax),%edx
  800a64:	84 d2                	test   %dl,%dl
  800a66:	74 09                	je     800a71 <strchr+0x1e>
		if (*s == c)
  800a68:	38 ca                	cmp    %cl,%dl
  800a6a:	74 0a                	je     800a76 <strchr+0x23>
	for (; *s; s++)
  800a6c:	83 c0 01             	add    $0x1,%eax
  800a6f:	eb f0                	jmp    800a61 <strchr+0xe>
			return (char *) s;
	return 0;
  800a71:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a76:	5d                   	pop    %ebp
  800a77:	c3                   	ret    

00800a78 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a78:	f3 0f 1e fb          	endbr32 
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a82:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a86:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a89:	38 ca                	cmp    %cl,%dl
  800a8b:	74 09                	je     800a96 <strfind+0x1e>
  800a8d:	84 d2                	test   %dl,%dl
  800a8f:	74 05                	je     800a96 <strfind+0x1e>
	for (; *s; s++)
  800a91:	83 c0 01             	add    $0x1,%eax
  800a94:	eb f0                	jmp    800a86 <strfind+0xe>
			break;
	return (char *) s;
}
  800a96:	5d                   	pop    %ebp
  800a97:	c3                   	ret    

00800a98 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a98:	f3 0f 1e fb          	endbr32 
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	57                   	push   %edi
  800aa0:	56                   	push   %esi
  800aa1:	53                   	push   %ebx
  800aa2:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aa5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aa8:	85 c9                	test   %ecx,%ecx
  800aaa:	74 31                	je     800add <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aac:	89 f8                	mov    %edi,%eax
  800aae:	09 c8                	or     %ecx,%eax
  800ab0:	a8 03                	test   $0x3,%al
  800ab2:	75 23                	jne    800ad7 <memset+0x3f>
		c &= 0xFF;
  800ab4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ab8:	89 d3                	mov    %edx,%ebx
  800aba:	c1 e3 08             	shl    $0x8,%ebx
  800abd:	89 d0                	mov    %edx,%eax
  800abf:	c1 e0 18             	shl    $0x18,%eax
  800ac2:	89 d6                	mov    %edx,%esi
  800ac4:	c1 e6 10             	shl    $0x10,%esi
  800ac7:	09 f0                	or     %esi,%eax
  800ac9:	09 c2                	or     %eax,%edx
  800acb:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800acd:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ad0:	89 d0                	mov    %edx,%eax
  800ad2:	fc                   	cld    
  800ad3:	f3 ab                	rep stos %eax,%es:(%edi)
  800ad5:	eb 06                	jmp    800add <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ad7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ada:	fc                   	cld    
  800adb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800add:	89 f8                	mov    %edi,%eax
  800adf:	5b                   	pop    %ebx
  800ae0:	5e                   	pop    %esi
  800ae1:	5f                   	pop    %edi
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ae4:	f3 0f 1e fb          	endbr32 
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	57                   	push   %edi
  800aec:	56                   	push   %esi
  800aed:	8b 45 08             	mov    0x8(%ebp),%eax
  800af0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800af6:	39 c6                	cmp    %eax,%esi
  800af8:	73 32                	jae    800b2c <memmove+0x48>
  800afa:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800afd:	39 c2                	cmp    %eax,%edx
  800aff:	76 2b                	jbe    800b2c <memmove+0x48>
		s += n;
		d += n;
  800b01:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b04:	89 fe                	mov    %edi,%esi
  800b06:	09 ce                	or     %ecx,%esi
  800b08:	09 d6                	or     %edx,%esi
  800b0a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b10:	75 0e                	jne    800b20 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b12:	83 ef 04             	sub    $0x4,%edi
  800b15:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b18:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b1b:	fd                   	std    
  800b1c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b1e:	eb 09                	jmp    800b29 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b20:	83 ef 01             	sub    $0x1,%edi
  800b23:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b26:	fd                   	std    
  800b27:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b29:	fc                   	cld    
  800b2a:	eb 1a                	jmp    800b46 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b2c:	89 c2                	mov    %eax,%edx
  800b2e:	09 ca                	or     %ecx,%edx
  800b30:	09 f2                	or     %esi,%edx
  800b32:	f6 c2 03             	test   $0x3,%dl
  800b35:	75 0a                	jne    800b41 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b37:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b3a:	89 c7                	mov    %eax,%edi
  800b3c:	fc                   	cld    
  800b3d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b3f:	eb 05                	jmp    800b46 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800b41:	89 c7                	mov    %eax,%edi
  800b43:	fc                   	cld    
  800b44:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b46:	5e                   	pop    %esi
  800b47:	5f                   	pop    %edi
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    

00800b4a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b4a:	f3 0f 1e fb          	endbr32 
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b54:	ff 75 10             	pushl  0x10(%ebp)
  800b57:	ff 75 0c             	pushl  0xc(%ebp)
  800b5a:	ff 75 08             	pushl  0x8(%ebp)
  800b5d:	e8 82 ff ff ff       	call   800ae4 <memmove>
}
  800b62:	c9                   	leave  
  800b63:	c3                   	ret    

00800b64 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b64:	f3 0f 1e fb          	endbr32 
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	56                   	push   %esi
  800b6c:	53                   	push   %ebx
  800b6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b70:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b73:	89 c6                	mov    %eax,%esi
  800b75:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b78:	39 f0                	cmp    %esi,%eax
  800b7a:	74 1c                	je     800b98 <memcmp+0x34>
		if (*s1 != *s2)
  800b7c:	0f b6 08             	movzbl (%eax),%ecx
  800b7f:	0f b6 1a             	movzbl (%edx),%ebx
  800b82:	38 d9                	cmp    %bl,%cl
  800b84:	75 08                	jne    800b8e <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b86:	83 c0 01             	add    $0x1,%eax
  800b89:	83 c2 01             	add    $0x1,%edx
  800b8c:	eb ea                	jmp    800b78 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800b8e:	0f b6 c1             	movzbl %cl,%eax
  800b91:	0f b6 db             	movzbl %bl,%ebx
  800b94:	29 d8                	sub    %ebx,%eax
  800b96:	eb 05                	jmp    800b9d <memcmp+0x39>
	}

	return 0;
  800b98:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b9d:	5b                   	pop    %ebx
  800b9e:	5e                   	pop    %esi
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ba1:	f3 0f 1e fb          	endbr32 
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bae:	89 c2                	mov    %eax,%edx
  800bb0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bb3:	39 d0                	cmp    %edx,%eax
  800bb5:	73 09                	jae    800bc0 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bb7:	38 08                	cmp    %cl,(%eax)
  800bb9:	74 05                	je     800bc0 <memfind+0x1f>
	for (; s < ends; s++)
  800bbb:	83 c0 01             	add    $0x1,%eax
  800bbe:	eb f3                	jmp    800bb3 <memfind+0x12>
			break;
	return (void *) s;
}
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bc2:	f3 0f 1e fb          	endbr32 
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	57                   	push   %edi
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
  800bcc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bcf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bd2:	eb 03                	jmp    800bd7 <strtol+0x15>
		s++;
  800bd4:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800bd7:	0f b6 01             	movzbl (%ecx),%eax
  800bda:	3c 20                	cmp    $0x20,%al
  800bdc:	74 f6                	je     800bd4 <strtol+0x12>
  800bde:	3c 09                	cmp    $0x9,%al
  800be0:	74 f2                	je     800bd4 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800be2:	3c 2b                	cmp    $0x2b,%al
  800be4:	74 2a                	je     800c10 <strtol+0x4e>
	int neg = 0;
  800be6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800beb:	3c 2d                	cmp    $0x2d,%al
  800bed:	74 2b                	je     800c1a <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bef:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bf5:	75 0f                	jne    800c06 <strtol+0x44>
  800bf7:	80 39 30             	cmpb   $0x30,(%ecx)
  800bfa:	74 28                	je     800c24 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bfc:	85 db                	test   %ebx,%ebx
  800bfe:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c03:	0f 44 d8             	cmove  %eax,%ebx
  800c06:	b8 00 00 00 00       	mov    $0x0,%eax
  800c0b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c0e:	eb 46                	jmp    800c56 <strtol+0x94>
		s++;
  800c10:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800c13:	bf 00 00 00 00       	mov    $0x0,%edi
  800c18:	eb d5                	jmp    800bef <strtol+0x2d>
		s++, neg = 1;
  800c1a:	83 c1 01             	add    $0x1,%ecx
  800c1d:	bf 01 00 00 00       	mov    $0x1,%edi
  800c22:	eb cb                	jmp    800bef <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c24:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c28:	74 0e                	je     800c38 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c2a:	85 db                	test   %ebx,%ebx
  800c2c:	75 d8                	jne    800c06 <strtol+0x44>
		s++, base = 8;
  800c2e:	83 c1 01             	add    $0x1,%ecx
  800c31:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c36:	eb ce                	jmp    800c06 <strtol+0x44>
		s += 2, base = 16;
  800c38:	83 c1 02             	add    $0x2,%ecx
  800c3b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c40:	eb c4                	jmp    800c06 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800c42:	0f be d2             	movsbl %dl,%edx
  800c45:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c48:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c4b:	7d 3a                	jge    800c87 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c4d:	83 c1 01             	add    $0x1,%ecx
  800c50:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c54:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c56:	0f b6 11             	movzbl (%ecx),%edx
  800c59:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c5c:	89 f3                	mov    %esi,%ebx
  800c5e:	80 fb 09             	cmp    $0x9,%bl
  800c61:	76 df                	jbe    800c42 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800c63:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c66:	89 f3                	mov    %esi,%ebx
  800c68:	80 fb 19             	cmp    $0x19,%bl
  800c6b:	77 08                	ja     800c75 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c6d:	0f be d2             	movsbl %dl,%edx
  800c70:	83 ea 57             	sub    $0x57,%edx
  800c73:	eb d3                	jmp    800c48 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800c75:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c78:	89 f3                	mov    %esi,%ebx
  800c7a:	80 fb 19             	cmp    $0x19,%bl
  800c7d:	77 08                	ja     800c87 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c7f:	0f be d2             	movsbl %dl,%edx
  800c82:	83 ea 37             	sub    $0x37,%edx
  800c85:	eb c1                	jmp    800c48 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c87:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c8b:	74 05                	je     800c92 <strtol+0xd0>
		*endptr = (char *) s;
  800c8d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c90:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c92:	89 c2                	mov    %eax,%edx
  800c94:	f7 da                	neg    %edx
  800c96:	85 ff                	test   %edi,%edi
  800c98:	0f 45 c2             	cmovne %edx,%eax
}
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5f                   	pop    %edi
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    

00800ca0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ca0:	f3 0f 1e fb          	endbr32 
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	57                   	push   %edi
  800ca8:	56                   	push   %esi
  800ca9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800caa:	b8 00 00 00 00       	mov    $0x0,%eax
  800caf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb5:	89 c3                	mov    %eax,%ebx
  800cb7:	89 c7                	mov    %eax,%edi
  800cb9:	89 c6                	mov    %eax,%esi
  800cbb:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800cc2:	f3 0f 1e fb          	endbr32 
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	57                   	push   %edi
  800cca:	56                   	push   %esi
  800ccb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ccc:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd1:	b8 01 00 00 00       	mov    $0x1,%eax
  800cd6:	89 d1                	mov    %edx,%ecx
  800cd8:	89 d3                	mov    %edx,%ebx
  800cda:	89 d7                	mov    %edx,%edi
  800cdc:	89 d6                	mov    %edx,%esi
  800cde:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ce0:	5b                   	pop    %ebx
  800ce1:	5e                   	pop    %esi
  800ce2:	5f                   	pop    %edi
  800ce3:	5d                   	pop    %ebp
  800ce4:	c3                   	ret    

00800ce5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ce5:	f3 0f 1e fb          	endbr32 
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	57                   	push   %edi
  800ced:	56                   	push   %esi
  800cee:	53                   	push   %ebx
  800cef:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cf2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfa:	b8 03 00 00 00       	mov    $0x3,%eax
  800cff:	89 cb                	mov    %ecx,%ebx
  800d01:	89 cf                	mov    %ecx,%edi
  800d03:	89 ce                	mov    %ecx,%esi
  800d05:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d07:	85 c0                	test   %eax,%eax
  800d09:	7f 08                	jg     800d13 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5f                   	pop    %edi
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d13:	83 ec 0c             	sub    $0xc,%esp
  800d16:	50                   	push   %eax
  800d17:	6a 03                	push   $0x3
  800d19:	68 a4 14 80 00       	push   $0x8014a4
  800d1e:	6a 23                	push   $0x23
  800d20:	68 c1 14 80 00       	push   $0x8014c1
  800d25:	e8 14 f5 ff ff       	call   80023e <_panic>

00800d2a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d2a:	f3 0f 1e fb          	endbr32 
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	57                   	push   %edi
  800d32:	56                   	push   %esi
  800d33:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d34:	ba 00 00 00 00       	mov    $0x0,%edx
  800d39:	b8 02 00 00 00       	mov    $0x2,%eax
  800d3e:	89 d1                	mov    %edx,%ecx
  800d40:	89 d3                	mov    %edx,%ebx
  800d42:	89 d7                	mov    %edx,%edi
  800d44:	89 d6                	mov    %edx,%esi
  800d46:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d48:	5b                   	pop    %ebx
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    

00800d4d <sys_yield>:

void
sys_yield(void)
{
  800d4d:	f3 0f 1e fb          	endbr32 
  800d51:	55                   	push   %ebp
  800d52:	89 e5                	mov    %esp,%ebp
  800d54:	57                   	push   %edi
  800d55:	56                   	push   %esi
  800d56:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d57:	ba 00 00 00 00       	mov    $0x0,%edx
  800d5c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d61:	89 d1                	mov    %edx,%ecx
  800d63:	89 d3                	mov    %edx,%ebx
  800d65:	89 d7                	mov    %edx,%edi
  800d67:	89 d6                	mov    %edx,%esi
  800d69:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d6b:	5b                   	pop    %ebx
  800d6c:	5e                   	pop    %esi
  800d6d:	5f                   	pop    %edi
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    

00800d70 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d70:	f3 0f 1e fb          	endbr32 
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	57                   	push   %edi
  800d78:	56                   	push   %esi
  800d79:	53                   	push   %ebx
  800d7a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d7d:	be 00 00 00 00       	mov    $0x0,%esi
  800d82:	8b 55 08             	mov    0x8(%ebp),%edx
  800d85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d88:	b8 04 00 00 00       	mov    $0x4,%eax
  800d8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d90:	89 f7                	mov    %esi,%edi
  800d92:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d94:	85 c0                	test   %eax,%eax
  800d96:	7f 08                	jg     800da0 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800da0:	83 ec 0c             	sub    $0xc,%esp
  800da3:	50                   	push   %eax
  800da4:	6a 04                	push   $0x4
  800da6:	68 a4 14 80 00       	push   $0x8014a4
  800dab:	6a 23                	push   $0x23
  800dad:	68 c1 14 80 00       	push   $0x8014c1
  800db2:	e8 87 f4 ff ff       	call   80023e <_panic>

00800db7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800db7:	f3 0f 1e fb          	endbr32 
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
  800dbe:	57                   	push   %edi
  800dbf:	56                   	push   %esi
  800dc0:	53                   	push   %ebx
  800dc1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dca:	b8 05 00 00 00       	mov    $0x5,%eax
  800dcf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dd5:	8b 75 18             	mov    0x18(%ebp),%esi
  800dd8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dda:	85 c0                	test   %eax,%eax
  800ddc:	7f 08                	jg     800de6 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de1:	5b                   	pop    %ebx
  800de2:	5e                   	pop    %esi
  800de3:	5f                   	pop    %edi
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800de6:	83 ec 0c             	sub    $0xc,%esp
  800de9:	50                   	push   %eax
  800dea:	6a 05                	push   $0x5
  800dec:	68 a4 14 80 00       	push   $0x8014a4
  800df1:	6a 23                	push   $0x23
  800df3:	68 c1 14 80 00       	push   $0x8014c1
  800df8:	e8 41 f4 ff ff       	call   80023e <_panic>

00800dfd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dfd:	f3 0f 1e fb          	endbr32 
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	57                   	push   %edi
  800e05:	56                   	push   %esi
  800e06:	53                   	push   %ebx
  800e07:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e0a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e15:	b8 06 00 00 00       	mov    $0x6,%eax
  800e1a:	89 df                	mov    %ebx,%edi
  800e1c:	89 de                	mov    %ebx,%esi
  800e1e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e20:	85 c0                	test   %eax,%eax
  800e22:	7f 08                	jg     800e2c <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e27:	5b                   	pop    %ebx
  800e28:	5e                   	pop    %esi
  800e29:	5f                   	pop    %edi
  800e2a:	5d                   	pop    %ebp
  800e2b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2c:	83 ec 0c             	sub    $0xc,%esp
  800e2f:	50                   	push   %eax
  800e30:	6a 06                	push   $0x6
  800e32:	68 a4 14 80 00       	push   $0x8014a4
  800e37:	6a 23                	push   $0x23
  800e39:	68 c1 14 80 00       	push   $0x8014c1
  800e3e:	e8 fb f3 ff ff       	call   80023e <_panic>

00800e43 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e43:	f3 0f 1e fb          	endbr32 
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	57                   	push   %edi
  800e4b:	56                   	push   %esi
  800e4c:	53                   	push   %ebx
  800e4d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e55:	8b 55 08             	mov    0x8(%ebp),%edx
  800e58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5b:	b8 08 00 00 00       	mov    $0x8,%eax
  800e60:	89 df                	mov    %ebx,%edi
  800e62:	89 de                	mov    %ebx,%esi
  800e64:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e66:	85 c0                	test   %eax,%eax
  800e68:	7f 08                	jg     800e72 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e6d:	5b                   	pop    %ebx
  800e6e:	5e                   	pop    %esi
  800e6f:	5f                   	pop    %edi
  800e70:	5d                   	pop    %ebp
  800e71:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e72:	83 ec 0c             	sub    $0xc,%esp
  800e75:	50                   	push   %eax
  800e76:	6a 08                	push   $0x8
  800e78:	68 a4 14 80 00       	push   $0x8014a4
  800e7d:	6a 23                	push   $0x23
  800e7f:	68 c1 14 80 00       	push   $0x8014c1
  800e84:	e8 b5 f3 ff ff       	call   80023e <_panic>

00800e89 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e89:	f3 0f 1e fb          	endbr32 
  800e8d:	55                   	push   %ebp
  800e8e:	89 e5                	mov    %esp,%ebp
  800e90:	57                   	push   %edi
  800e91:	56                   	push   %esi
  800e92:	53                   	push   %ebx
  800e93:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e96:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea1:	b8 09 00 00 00       	mov    $0x9,%eax
  800ea6:	89 df                	mov    %ebx,%edi
  800ea8:	89 de                	mov    %ebx,%esi
  800eaa:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eac:	85 c0                	test   %eax,%eax
  800eae:	7f 08                	jg     800eb8 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800eb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb3:	5b                   	pop    %ebx
  800eb4:	5e                   	pop    %esi
  800eb5:	5f                   	pop    %edi
  800eb6:	5d                   	pop    %ebp
  800eb7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb8:	83 ec 0c             	sub    $0xc,%esp
  800ebb:	50                   	push   %eax
  800ebc:	6a 09                	push   $0x9
  800ebe:	68 a4 14 80 00       	push   $0x8014a4
  800ec3:	6a 23                	push   $0x23
  800ec5:	68 c1 14 80 00       	push   $0x8014c1
  800eca:	e8 6f f3 ff ff       	call   80023e <_panic>

00800ecf <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ecf:	f3 0f 1e fb          	endbr32 
  800ed3:	55                   	push   %ebp
  800ed4:	89 e5                	mov    %esp,%ebp
  800ed6:	57                   	push   %edi
  800ed7:	56                   	push   %esi
  800ed8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ed9:	8b 55 08             	mov    0x8(%ebp),%edx
  800edc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800edf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ee4:	be 00 00 00 00       	mov    $0x0,%esi
  800ee9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eec:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eef:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ef1:	5b                   	pop    %ebx
  800ef2:	5e                   	pop    %esi
  800ef3:	5f                   	pop    %edi
  800ef4:	5d                   	pop    %ebp
  800ef5:	c3                   	ret    

00800ef6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ef6:	f3 0f 1e fb          	endbr32 
  800efa:	55                   	push   %ebp
  800efb:	89 e5                	mov    %esp,%ebp
  800efd:	57                   	push   %edi
  800efe:	56                   	push   %esi
  800eff:	53                   	push   %ebx
  800f00:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f03:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f08:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f10:	89 cb                	mov    %ecx,%ebx
  800f12:	89 cf                	mov    %ecx,%edi
  800f14:	89 ce                	mov    %ecx,%esi
  800f16:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f18:	85 c0                	test   %eax,%eax
  800f1a:	7f 08                	jg     800f24 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f1f:	5b                   	pop    %ebx
  800f20:	5e                   	pop    %esi
  800f21:	5f                   	pop    %edi
  800f22:	5d                   	pop    %ebp
  800f23:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f24:	83 ec 0c             	sub    $0xc,%esp
  800f27:	50                   	push   %eax
  800f28:	6a 0c                	push   $0xc
  800f2a:	68 a4 14 80 00       	push   $0x8014a4
  800f2f:	6a 23                	push   $0x23
  800f31:	68 c1 14 80 00       	push   $0x8014c1
  800f36:	e8 03 f3 ff ff       	call   80023e <_panic>
  800f3b:	66 90                	xchg   %ax,%ax
  800f3d:	66 90                	xchg   %ax,%ax
  800f3f:	90                   	nop

00800f40 <__udivdi3>:
  800f40:	f3 0f 1e fb          	endbr32 
  800f44:	55                   	push   %ebp
  800f45:	57                   	push   %edi
  800f46:	56                   	push   %esi
  800f47:	53                   	push   %ebx
  800f48:	83 ec 1c             	sub    $0x1c,%esp
  800f4b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f4f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800f53:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f57:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800f5b:	85 d2                	test   %edx,%edx
  800f5d:	75 19                	jne    800f78 <__udivdi3+0x38>
  800f5f:	39 f3                	cmp    %esi,%ebx
  800f61:	76 4d                	jbe    800fb0 <__udivdi3+0x70>
  800f63:	31 ff                	xor    %edi,%edi
  800f65:	89 e8                	mov    %ebp,%eax
  800f67:	89 f2                	mov    %esi,%edx
  800f69:	f7 f3                	div    %ebx
  800f6b:	89 fa                	mov    %edi,%edx
  800f6d:	83 c4 1c             	add    $0x1c,%esp
  800f70:	5b                   	pop    %ebx
  800f71:	5e                   	pop    %esi
  800f72:	5f                   	pop    %edi
  800f73:	5d                   	pop    %ebp
  800f74:	c3                   	ret    
  800f75:	8d 76 00             	lea    0x0(%esi),%esi
  800f78:	39 f2                	cmp    %esi,%edx
  800f7a:	76 14                	jbe    800f90 <__udivdi3+0x50>
  800f7c:	31 ff                	xor    %edi,%edi
  800f7e:	31 c0                	xor    %eax,%eax
  800f80:	89 fa                	mov    %edi,%edx
  800f82:	83 c4 1c             	add    $0x1c,%esp
  800f85:	5b                   	pop    %ebx
  800f86:	5e                   	pop    %esi
  800f87:	5f                   	pop    %edi
  800f88:	5d                   	pop    %ebp
  800f89:	c3                   	ret    
  800f8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f90:	0f bd fa             	bsr    %edx,%edi
  800f93:	83 f7 1f             	xor    $0x1f,%edi
  800f96:	75 48                	jne    800fe0 <__udivdi3+0xa0>
  800f98:	39 f2                	cmp    %esi,%edx
  800f9a:	72 06                	jb     800fa2 <__udivdi3+0x62>
  800f9c:	31 c0                	xor    %eax,%eax
  800f9e:	39 eb                	cmp    %ebp,%ebx
  800fa0:	77 de                	ja     800f80 <__udivdi3+0x40>
  800fa2:	b8 01 00 00 00       	mov    $0x1,%eax
  800fa7:	eb d7                	jmp    800f80 <__udivdi3+0x40>
  800fa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fb0:	89 d9                	mov    %ebx,%ecx
  800fb2:	85 db                	test   %ebx,%ebx
  800fb4:	75 0b                	jne    800fc1 <__udivdi3+0x81>
  800fb6:	b8 01 00 00 00       	mov    $0x1,%eax
  800fbb:	31 d2                	xor    %edx,%edx
  800fbd:	f7 f3                	div    %ebx
  800fbf:	89 c1                	mov    %eax,%ecx
  800fc1:	31 d2                	xor    %edx,%edx
  800fc3:	89 f0                	mov    %esi,%eax
  800fc5:	f7 f1                	div    %ecx
  800fc7:	89 c6                	mov    %eax,%esi
  800fc9:	89 e8                	mov    %ebp,%eax
  800fcb:	89 f7                	mov    %esi,%edi
  800fcd:	f7 f1                	div    %ecx
  800fcf:	89 fa                	mov    %edi,%edx
  800fd1:	83 c4 1c             	add    $0x1c,%esp
  800fd4:	5b                   	pop    %ebx
  800fd5:	5e                   	pop    %esi
  800fd6:	5f                   	pop    %edi
  800fd7:	5d                   	pop    %ebp
  800fd8:	c3                   	ret    
  800fd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fe0:	89 f9                	mov    %edi,%ecx
  800fe2:	b8 20 00 00 00       	mov    $0x20,%eax
  800fe7:	29 f8                	sub    %edi,%eax
  800fe9:	d3 e2                	shl    %cl,%edx
  800feb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800fef:	89 c1                	mov    %eax,%ecx
  800ff1:	89 da                	mov    %ebx,%edx
  800ff3:	d3 ea                	shr    %cl,%edx
  800ff5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ff9:	09 d1                	or     %edx,%ecx
  800ffb:	89 f2                	mov    %esi,%edx
  800ffd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801001:	89 f9                	mov    %edi,%ecx
  801003:	d3 e3                	shl    %cl,%ebx
  801005:	89 c1                	mov    %eax,%ecx
  801007:	d3 ea                	shr    %cl,%edx
  801009:	89 f9                	mov    %edi,%ecx
  80100b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80100f:	89 eb                	mov    %ebp,%ebx
  801011:	d3 e6                	shl    %cl,%esi
  801013:	89 c1                	mov    %eax,%ecx
  801015:	d3 eb                	shr    %cl,%ebx
  801017:	09 de                	or     %ebx,%esi
  801019:	89 f0                	mov    %esi,%eax
  80101b:	f7 74 24 08          	divl   0x8(%esp)
  80101f:	89 d6                	mov    %edx,%esi
  801021:	89 c3                	mov    %eax,%ebx
  801023:	f7 64 24 0c          	mull   0xc(%esp)
  801027:	39 d6                	cmp    %edx,%esi
  801029:	72 15                	jb     801040 <__udivdi3+0x100>
  80102b:	89 f9                	mov    %edi,%ecx
  80102d:	d3 e5                	shl    %cl,%ebp
  80102f:	39 c5                	cmp    %eax,%ebp
  801031:	73 04                	jae    801037 <__udivdi3+0xf7>
  801033:	39 d6                	cmp    %edx,%esi
  801035:	74 09                	je     801040 <__udivdi3+0x100>
  801037:	89 d8                	mov    %ebx,%eax
  801039:	31 ff                	xor    %edi,%edi
  80103b:	e9 40 ff ff ff       	jmp    800f80 <__udivdi3+0x40>
  801040:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801043:	31 ff                	xor    %edi,%edi
  801045:	e9 36 ff ff ff       	jmp    800f80 <__udivdi3+0x40>
  80104a:	66 90                	xchg   %ax,%ax
  80104c:	66 90                	xchg   %ax,%ax
  80104e:	66 90                	xchg   %ax,%ax

00801050 <__umoddi3>:
  801050:	f3 0f 1e fb          	endbr32 
  801054:	55                   	push   %ebp
  801055:	57                   	push   %edi
  801056:	56                   	push   %esi
  801057:	53                   	push   %ebx
  801058:	83 ec 1c             	sub    $0x1c,%esp
  80105b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80105f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801063:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801067:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80106b:	85 c0                	test   %eax,%eax
  80106d:	75 19                	jne    801088 <__umoddi3+0x38>
  80106f:	39 df                	cmp    %ebx,%edi
  801071:	76 5d                	jbe    8010d0 <__umoddi3+0x80>
  801073:	89 f0                	mov    %esi,%eax
  801075:	89 da                	mov    %ebx,%edx
  801077:	f7 f7                	div    %edi
  801079:	89 d0                	mov    %edx,%eax
  80107b:	31 d2                	xor    %edx,%edx
  80107d:	83 c4 1c             	add    $0x1c,%esp
  801080:	5b                   	pop    %ebx
  801081:	5e                   	pop    %esi
  801082:	5f                   	pop    %edi
  801083:	5d                   	pop    %ebp
  801084:	c3                   	ret    
  801085:	8d 76 00             	lea    0x0(%esi),%esi
  801088:	89 f2                	mov    %esi,%edx
  80108a:	39 d8                	cmp    %ebx,%eax
  80108c:	76 12                	jbe    8010a0 <__umoddi3+0x50>
  80108e:	89 f0                	mov    %esi,%eax
  801090:	89 da                	mov    %ebx,%edx
  801092:	83 c4 1c             	add    $0x1c,%esp
  801095:	5b                   	pop    %ebx
  801096:	5e                   	pop    %esi
  801097:	5f                   	pop    %edi
  801098:	5d                   	pop    %ebp
  801099:	c3                   	ret    
  80109a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010a0:	0f bd e8             	bsr    %eax,%ebp
  8010a3:	83 f5 1f             	xor    $0x1f,%ebp
  8010a6:	75 50                	jne    8010f8 <__umoddi3+0xa8>
  8010a8:	39 d8                	cmp    %ebx,%eax
  8010aa:	0f 82 e0 00 00 00    	jb     801190 <__umoddi3+0x140>
  8010b0:	89 d9                	mov    %ebx,%ecx
  8010b2:	39 f7                	cmp    %esi,%edi
  8010b4:	0f 86 d6 00 00 00    	jbe    801190 <__umoddi3+0x140>
  8010ba:	89 d0                	mov    %edx,%eax
  8010bc:	89 ca                	mov    %ecx,%edx
  8010be:	83 c4 1c             	add    $0x1c,%esp
  8010c1:	5b                   	pop    %ebx
  8010c2:	5e                   	pop    %esi
  8010c3:	5f                   	pop    %edi
  8010c4:	5d                   	pop    %ebp
  8010c5:	c3                   	ret    
  8010c6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010cd:	8d 76 00             	lea    0x0(%esi),%esi
  8010d0:	89 fd                	mov    %edi,%ebp
  8010d2:	85 ff                	test   %edi,%edi
  8010d4:	75 0b                	jne    8010e1 <__umoddi3+0x91>
  8010d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8010db:	31 d2                	xor    %edx,%edx
  8010dd:	f7 f7                	div    %edi
  8010df:	89 c5                	mov    %eax,%ebp
  8010e1:	89 d8                	mov    %ebx,%eax
  8010e3:	31 d2                	xor    %edx,%edx
  8010e5:	f7 f5                	div    %ebp
  8010e7:	89 f0                	mov    %esi,%eax
  8010e9:	f7 f5                	div    %ebp
  8010eb:	89 d0                	mov    %edx,%eax
  8010ed:	31 d2                	xor    %edx,%edx
  8010ef:	eb 8c                	jmp    80107d <__umoddi3+0x2d>
  8010f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010f8:	89 e9                	mov    %ebp,%ecx
  8010fa:	ba 20 00 00 00       	mov    $0x20,%edx
  8010ff:	29 ea                	sub    %ebp,%edx
  801101:	d3 e0                	shl    %cl,%eax
  801103:	89 44 24 08          	mov    %eax,0x8(%esp)
  801107:	89 d1                	mov    %edx,%ecx
  801109:	89 f8                	mov    %edi,%eax
  80110b:	d3 e8                	shr    %cl,%eax
  80110d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801111:	89 54 24 04          	mov    %edx,0x4(%esp)
  801115:	8b 54 24 04          	mov    0x4(%esp),%edx
  801119:	09 c1                	or     %eax,%ecx
  80111b:	89 d8                	mov    %ebx,%eax
  80111d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801121:	89 e9                	mov    %ebp,%ecx
  801123:	d3 e7                	shl    %cl,%edi
  801125:	89 d1                	mov    %edx,%ecx
  801127:	d3 e8                	shr    %cl,%eax
  801129:	89 e9                	mov    %ebp,%ecx
  80112b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80112f:	d3 e3                	shl    %cl,%ebx
  801131:	89 c7                	mov    %eax,%edi
  801133:	89 d1                	mov    %edx,%ecx
  801135:	89 f0                	mov    %esi,%eax
  801137:	d3 e8                	shr    %cl,%eax
  801139:	89 e9                	mov    %ebp,%ecx
  80113b:	89 fa                	mov    %edi,%edx
  80113d:	d3 e6                	shl    %cl,%esi
  80113f:	09 d8                	or     %ebx,%eax
  801141:	f7 74 24 08          	divl   0x8(%esp)
  801145:	89 d1                	mov    %edx,%ecx
  801147:	89 f3                	mov    %esi,%ebx
  801149:	f7 64 24 0c          	mull   0xc(%esp)
  80114d:	89 c6                	mov    %eax,%esi
  80114f:	89 d7                	mov    %edx,%edi
  801151:	39 d1                	cmp    %edx,%ecx
  801153:	72 06                	jb     80115b <__umoddi3+0x10b>
  801155:	75 10                	jne    801167 <__umoddi3+0x117>
  801157:	39 c3                	cmp    %eax,%ebx
  801159:	73 0c                	jae    801167 <__umoddi3+0x117>
  80115b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80115f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801163:	89 d7                	mov    %edx,%edi
  801165:	89 c6                	mov    %eax,%esi
  801167:	89 ca                	mov    %ecx,%edx
  801169:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80116e:	29 f3                	sub    %esi,%ebx
  801170:	19 fa                	sbb    %edi,%edx
  801172:	89 d0                	mov    %edx,%eax
  801174:	d3 e0                	shl    %cl,%eax
  801176:	89 e9                	mov    %ebp,%ecx
  801178:	d3 eb                	shr    %cl,%ebx
  80117a:	d3 ea                	shr    %cl,%edx
  80117c:	09 d8                	or     %ebx,%eax
  80117e:	83 c4 1c             	add    $0x1c,%esp
  801181:	5b                   	pop    %ebx
  801182:	5e                   	pop    %esi
  801183:	5f                   	pop    %edi
  801184:	5d                   	pop    %ebp
  801185:	c3                   	ret    
  801186:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80118d:	8d 76 00             	lea    0x0(%esi),%esi
  801190:	29 fe                	sub    %edi,%esi
  801192:	19 c3                	sbb    %eax,%ebx
  801194:	89 f2                	mov    %esi,%edx
  801196:	89 d9                	mov    %ebx,%ecx
  801198:	e9 1d ff ff ff       	jmp    8010ba <__umoddi3+0x6a>
