
obj/user/faultalloc:     file format elf32-i386


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
  80002c:	e8 a1 00 00 00       	call   8000d2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	53                   	push   %ebx
  80003b:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003e:	8b 45 08             	mov    0x8(%ebp),%eax
  800041:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  800043:	53                   	push   %ebx
  800044:	68 e0 1f 80 00       	push   $0x801fe0
  800049:	e8 dd 01 00 00       	call   80022b <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004e:	83 c4 0c             	add    $0xc,%esp
  800051:	6a 07                	push   $0x7
  800053:	89 d8                	mov    %ebx,%eax
  800055:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005a:	50                   	push   %eax
  80005b:	6a 00                	push   $0x0
  80005d:	e8 14 0c 00 00       	call   800c76 <sys_page_alloc>
  800062:	83 c4 10             	add    $0x10,%esp
  800065:	85 c0                	test   %eax,%eax
  800067:	78 16                	js     80007f <handler+0x4c>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800069:	53                   	push   %ebx
  80006a:	68 2c 20 80 00       	push   $0x80202c
  80006f:	6a 64                	push   $0x64
  800071:	53                   	push   %ebx
  800072:	e8 5c 07 00 00       	call   8007d3 <snprintf>
}
  800077:	83 c4 10             	add    $0x10,%esp
  80007a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007d:	c9                   	leave  
  80007e:	c3                   	ret    
		panic("allocating at %x in page fault handler: %e", addr, r);
  80007f:	83 ec 0c             	sub    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	53                   	push   %ebx
  800084:	68 00 20 80 00       	push   $0x802000
  800089:	6a 0e                	push   $0xe
  80008b:	68 ea 1f 80 00       	push   $0x801fea
  800090:	e8 af 00 00 00       	call   800144 <_panic>

00800095 <umain>:

void
umain(int argc, char **argv)
{
  800095:	f3 0f 1e fb          	endbr32 
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  80009f:	68 33 00 80 00       	push   $0x800033
  8000a4:	e8 de 0d 00 00       	call   800e87 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a9:	83 c4 08             	add    $0x8,%esp
  8000ac:	68 ef be ad de       	push   $0xdeadbeef
  8000b1:	68 fc 1f 80 00       	push   $0x801ffc
  8000b6:	e8 70 01 00 00       	call   80022b <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000bb:	83 c4 08             	add    $0x8,%esp
  8000be:	68 fe bf fe ca       	push   $0xcafebffe
  8000c3:	68 fc 1f 80 00       	push   $0x801ffc
  8000c8:	e8 5e 01 00 00       	call   80022b <cprintf>
}
  8000cd:	83 c4 10             	add    $0x10,%esp
  8000d0:	c9                   	leave  
  8000d1:	c3                   	ret    

008000d2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000d2:	f3 0f 1e fb          	endbr32 
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	56                   	push   %esi
  8000da:	53                   	push   %ebx
  8000db:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000de:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000e1:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  8000e8:	00 00 00 
    envid_t envid = sys_getenvid();
  8000eb:	e8 40 0b 00 00       	call   800c30 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  8000f0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fd:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800102:	85 db                	test   %ebx,%ebx
  800104:	7e 07                	jle    80010d <libmain+0x3b>
		binaryname = argv[0];
  800106:	8b 06                	mov    (%esi),%eax
  800108:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80010d:	83 ec 08             	sub    $0x8,%esp
  800110:	56                   	push   %esi
  800111:	53                   	push   %ebx
  800112:	e8 7e ff ff ff       	call   800095 <umain>

	// exit gracefully
	exit();
  800117:	e8 0a 00 00 00       	call   800126 <exit>
}
  80011c:	83 c4 10             	add    $0x10,%esp
  80011f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800122:	5b                   	pop    %ebx
  800123:	5e                   	pop    %esi
  800124:	5d                   	pop    %ebp
  800125:	c3                   	ret    

00800126 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800126:	f3 0f 1e fb          	endbr32 
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800130:	e8 e7 0f 00 00       	call   80111c <close_all>
	sys_env_destroy(0);
  800135:	83 ec 0c             	sub    $0xc,%esp
  800138:	6a 00                	push   $0x0
  80013a:	e8 ac 0a 00 00       	call   800beb <sys_env_destroy>
}
  80013f:	83 c4 10             	add    $0x10,%esp
  800142:	c9                   	leave  
  800143:	c3                   	ret    

00800144 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800144:	f3 0f 1e fb          	endbr32 
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80014d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800150:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800156:	e8 d5 0a 00 00       	call   800c30 <sys_getenvid>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	ff 75 0c             	pushl  0xc(%ebp)
  800161:	ff 75 08             	pushl  0x8(%ebp)
  800164:	56                   	push   %esi
  800165:	50                   	push   %eax
  800166:	68 58 20 80 00       	push   $0x802058
  80016b:	e8 bb 00 00 00       	call   80022b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800170:	83 c4 18             	add    $0x18,%esp
  800173:	53                   	push   %ebx
  800174:	ff 75 10             	pushl  0x10(%ebp)
  800177:	e8 5a 00 00 00       	call   8001d6 <vcprintf>
	cprintf("\n");
  80017c:	c7 04 24 b7 23 80 00 	movl   $0x8023b7,(%esp)
  800183:	e8 a3 00 00 00       	call   80022b <cprintf>
  800188:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80018b:	cc                   	int3   
  80018c:	eb fd                	jmp    80018b <_panic+0x47>

0080018e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80018e:	f3 0f 1e fb          	endbr32 
  800192:	55                   	push   %ebp
  800193:	89 e5                	mov    %esp,%ebp
  800195:	53                   	push   %ebx
  800196:	83 ec 04             	sub    $0x4,%esp
  800199:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019c:	8b 13                	mov    (%ebx),%edx
  80019e:	8d 42 01             	lea    0x1(%edx),%eax
  8001a1:	89 03                	mov    %eax,(%ebx)
  8001a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001aa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001af:	74 09                	je     8001ba <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001b1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b8:	c9                   	leave  
  8001b9:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001ba:	83 ec 08             	sub    $0x8,%esp
  8001bd:	68 ff 00 00 00       	push   $0xff
  8001c2:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c5:	50                   	push   %eax
  8001c6:	e8 db 09 00 00       	call   800ba6 <sys_cputs>
		b->idx = 0;
  8001cb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d1:	83 c4 10             	add    $0x10,%esp
  8001d4:	eb db                	jmp    8001b1 <putch+0x23>

008001d6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d6:	f3 0f 1e fb          	endbr32 
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ea:	00 00 00 
	b.cnt = 0;
  8001ed:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f7:	ff 75 0c             	pushl  0xc(%ebp)
  8001fa:	ff 75 08             	pushl  0x8(%ebp)
  8001fd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800203:	50                   	push   %eax
  800204:	68 8e 01 80 00       	push   $0x80018e
  800209:	e8 20 01 00 00       	call   80032e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80020e:	83 c4 08             	add    $0x8,%esp
  800211:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800217:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80021d:	50                   	push   %eax
  80021e:	e8 83 09 00 00       	call   800ba6 <sys_cputs>

	return b.cnt;
}
  800223:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800229:	c9                   	leave  
  80022a:	c3                   	ret    

0080022b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80022b:	f3 0f 1e fb          	endbr32 
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800235:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800238:	50                   	push   %eax
  800239:	ff 75 08             	pushl  0x8(%ebp)
  80023c:	e8 95 ff ff ff       	call   8001d6 <vcprintf>
	va_end(ap);

	return cnt;
}
  800241:	c9                   	leave  
  800242:	c3                   	ret    

00800243 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800243:	55                   	push   %ebp
  800244:	89 e5                	mov    %esp,%ebp
  800246:	57                   	push   %edi
  800247:	56                   	push   %esi
  800248:	53                   	push   %ebx
  800249:	83 ec 1c             	sub    $0x1c,%esp
  80024c:	89 c7                	mov    %eax,%edi
  80024e:	89 d6                	mov    %edx,%esi
  800250:	8b 45 08             	mov    0x8(%ebp),%eax
  800253:	8b 55 0c             	mov    0xc(%ebp),%edx
  800256:	89 d1                	mov    %edx,%ecx
  800258:	89 c2                	mov    %eax,%edx
  80025a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800260:	8b 45 10             	mov    0x10(%ebp),%eax
  800263:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800266:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800269:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800270:	39 c2                	cmp    %eax,%edx
  800272:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800275:	72 3e                	jb     8002b5 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	ff 75 18             	pushl  0x18(%ebp)
  80027d:	83 eb 01             	sub    $0x1,%ebx
  800280:	53                   	push   %ebx
  800281:	50                   	push   %eax
  800282:	83 ec 08             	sub    $0x8,%esp
  800285:	ff 75 e4             	pushl  -0x1c(%ebp)
  800288:	ff 75 e0             	pushl  -0x20(%ebp)
  80028b:	ff 75 dc             	pushl  -0x24(%ebp)
  80028e:	ff 75 d8             	pushl  -0x28(%ebp)
  800291:	e8 ea 1a 00 00       	call   801d80 <__udivdi3>
  800296:	83 c4 18             	add    $0x18,%esp
  800299:	52                   	push   %edx
  80029a:	50                   	push   %eax
  80029b:	89 f2                	mov    %esi,%edx
  80029d:	89 f8                	mov    %edi,%eax
  80029f:	e8 9f ff ff ff       	call   800243 <printnum>
  8002a4:	83 c4 20             	add    $0x20,%esp
  8002a7:	eb 13                	jmp    8002bc <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a9:	83 ec 08             	sub    $0x8,%esp
  8002ac:	56                   	push   %esi
  8002ad:	ff 75 18             	pushl  0x18(%ebp)
  8002b0:	ff d7                	call   *%edi
  8002b2:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002b5:	83 eb 01             	sub    $0x1,%ebx
  8002b8:	85 db                	test   %ebx,%ebx
  8002ba:	7f ed                	jg     8002a9 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002bc:	83 ec 08             	sub    $0x8,%esp
  8002bf:	56                   	push   %esi
  8002c0:	83 ec 04             	sub    $0x4,%esp
  8002c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cc:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cf:	e8 bc 1b 00 00       	call   801e90 <__umoddi3>
  8002d4:	83 c4 14             	add    $0x14,%esp
  8002d7:	0f be 80 7b 20 80 00 	movsbl 0x80207b(%eax),%eax
  8002de:	50                   	push   %eax
  8002df:	ff d7                	call   *%edi
}
  8002e1:	83 c4 10             	add    $0x10,%esp
  8002e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e7:	5b                   	pop    %ebx
  8002e8:	5e                   	pop    %esi
  8002e9:	5f                   	pop    %edi
  8002ea:	5d                   	pop    %ebp
  8002eb:	c3                   	ret    

008002ec <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ec:	f3 0f 1e fb          	endbr32 
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002fa:	8b 10                	mov    (%eax),%edx
  8002fc:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ff:	73 0a                	jae    80030b <sprintputch+0x1f>
		*b->buf++ = ch;
  800301:	8d 4a 01             	lea    0x1(%edx),%ecx
  800304:	89 08                	mov    %ecx,(%eax)
  800306:	8b 45 08             	mov    0x8(%ebp),%eax
  800309:	88 02                	mov    %al,(%edx)
}
  80030b:	5d                   	pop    %ebp
  80030c:	c3                   	ret    

0080030d <printfmt>:
{
  80030d:	f3 0f 1e fb          	endbr32 
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800317:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031a:	50                   	push   %eax
  80031b:	ff 75 10             	pushl  0x10(%ebp)
  80031e:	ff 75 0c             	pushl  0xc(%ebp)
  800321:	ff 75 08             	pushl  0x8(%ebp)
  800324:	e8 05 00 00 00       	call   80032e <vprintfmt>
}
  800329:	83 c4 10             	add    $0x10,%esp
  80032c:	c9                   	leave  
  80032d:	c3                   	ret    

0080032e <vprintfmt>:
{
  80032e:	f3 0f 1e fb          	endbr32 
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
  800335:	57                   	push   %edi
  800336:	56                   	push   %esi
  800337:	53                   	push   %ebx
  800338:	83 ec 3c             	sub    $0x3c,%esp
  80033b:	8b 75 08             	mov    0x8(%ebp),%esi
  80033e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800341:	8b 7d 10             	mov    0x10(%ebp),%edi
  800344:	e9 4a 03 00 00       	jmp    800693 <vprintfmt+0x365>
		padc = ' ';
  800349:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80034d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800354:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80035b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800362:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800367:	8d 47 01             	lea    0x1(%edi),%eax
  80036a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036d:	0f b6 17             	movzbl (%edi),%edx
  800370:	8d 42 dd             	lea    -0x23(%edx),%eax
  800373:	3c 55                	cmp    $0x55,%al
  800375:	0f 87 de 03 00 00    	ja     800759 <vprintfmt+0x42b>
  80037b:	0f b6 c0             	movzbl %al,%eax
  80037e:	3e ff 24 85 c0 21 80 	notrack jmp *0x8021c0(,%eax,4)
  800385:	00 
  800386:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800389:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80038d:	eb d8                	jmp    800367 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80038f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800392:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800396:	eb cf                	jmp    800367 <vprintfmt+0x39>
  800398:	0f b6 d2             	movzbl %dl,%edx
  80039b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80039e:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003a6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003a9:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003ad:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003b0:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003b3:	83 f9 09             	cmp    $0x9,%ecx
  8003b6:	77 55                	ja     80040d <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8003b8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003bb:	eb e9                	jmp    8003a6 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c0:	8b 00                	mov    (%eax),%eax
  8003c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c8:	8d 40 04             	lea    0x4(%eax),%eax
  8003cb:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003d1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d5:	79 90                	jns    800367 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003d7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003da:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003dd:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003e4:	eb 81                	jmp    800367 <vprintfmt+0x39>
  8003e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e9:	85 c0                	test   %eax,%eax
  8003eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f0:	0f 49 d0             	cmovns %eax,%edx
  8003f3:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003f9:	e9 69 ff ff ff       	jmp    800367 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800401:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800408:	e9 5a ff ff ff       	jmp    800367 <vprintfmt+0x39>
  80040d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800410:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800413:	eb bc                	jmp    8003d1 <vprintfmt+0xa3>
			lflag++;
  800415:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800418:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80041b:	e9 47 ff ff ff       	jmp    800367 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800420:	8b 45 14             	mov    0x14(%ebp),%eax
  800423:	8d 78 04             	lea    0x4(%eax),%edi
  800426:	83 ec 08             	sub    $0x8,%esp
  800429:	53                   	push   %ebx
  80042a:	ff 30                	pushl  (%eax)
  80042c:	ff d6                	call   *%esi
			break;
  80042e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800431:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800434:	e9 57 02 00 00       	jmp    800690 <vprintfmt+0x362>
			err = va_arg(ap, int);
  800439:	8b 45 14             	mov    0x14(%ebp),%eax
  80043c:	8d 78 04             	lea    0x4(%eax),%edi
  80043f:	8b 00                	mov    (%eax),%eax
  800441:	99                   	cltd   
  800442:	31 d0                	xor    %edx,%eax
  800444:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800446:	83 f8 0f             	cmp    $0xf,%eax
  800449:	7f 23                	jg     80046e <vprintfmt+0x140>
  80044b:	8b 14 85 20 23 80 00 	mov    0x802320(,%eax,4),%edx
  800452:	85 d2                	test   %edx,%edx
  800454:	74 18                	je     80046e <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800456:	52                   	push   %edx
  800457:	68 da 24 80 00       	push   $0x8024da
  80045c:	53                   	push   %ebx
  80045d:	56                   	push   %esi
  80045e:	e8 aa fe ff ff       	call   80030d <printfmt>
  800463:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800466:	89 7d 14             	mov    %edi,0x14(%ebp)
  800469:	e9 22 02 00 00       	jmp    800690 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  80046e:	50                   	push   %eax
  80046f:	68 93 20 80 00       	push   $0x802093
  800474:	53                   	push   %ebx
  800475:	56                   	push   %esi
  800476:	e8 92 fe ff ff       	call   80030d <printfmt>
  80047b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80047e:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800481:	e9 0a 02 00 00       	jmp    800690 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  800486:	8b 45 14             	mov    0x14(%ebp),%eax
  800489:	83 c0 04             	add    $0x4,%eax
  80048c:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80048f:	8b 45 14             	mov    0x14(%ebp),%eax
  800492:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800494:	85 d2                	test   %edx,%edx
  800496:	b8 8c 20 80 00       	mov    $0x80208c,%eax
  80049b:	0f 45 c2             	cmovne %edx,%eax
  80049e:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004a1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a5:	7e 06                	jle    8004ad <vprintfmt+0x17f>
  8004a7:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004ab:	75 0d                	jne    8004ba <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ad:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004b0:	89 c7                	mov    %eax,%edi
  8004b2:	03 45 e0             	add    -0x20(%ebp),%eax
  8004b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b8:	eb 55                	jmp    80050f <vprintfmt+0x1e1>
  8004ba:	83 ec 08             	sub    $0x8,%esp
  8004bd:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c0:	ff 75 cc             	pushl  -0x34(%ebp)
  8004c3:	e8 45 03 00 00       	call   80080d <strnlen>
  8004c8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004cb:	29 c2                	sub    %eax,%edx
  8004cd:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004d0:	83 c4 10             	add    $0x10,%esp
  8004d3:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004d5:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004dc:	85 ff                	test   %edi,%edi
  8004de:	7e 11                	jle    8004f1 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004e0:	83 ec 08             	sub    $0x8,%esp
  8004e3:	53                   	push   %ebx
  8004e4:	ff 75 e0             	pushl  -0x20(%ebp)
  8004e7:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e9:	83 ef 01             	sub    $0x1,%edi
  8004ec:	83 c4 10             	add    $0x10,%esp
  8004ef:	eb eb                	jmp    8004dc <vprintfmt+0x1ae>
  8004f1:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004f4:	85 d2                	test   %edx,%edx
  8004f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fb:	0f 49 c2             	cmovns %edx,%eax
  8004fe:	29 c2                	sub    %eax,%edx
  800500:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800503:	eb a8                	jmp    8004ad <vprintfmt+0x17f>
					putch(ch, putdat);
  800505:	83 ec 08             	sub    $0x8,%esp
  800508:	53                   	push   %ebx
  800509:	52                   	push   %edx
  80050a:	ff d6                	call   *%esi
  80050c:	83 c4 10             	add    $0x10,%esp
  80050f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800512:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800514:	83 c7 01             	add    $0x1,%edi
  800517:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80051b:	0f be d0             	movsbl %al,%edx
  80051e:	85 d2                	test   %edx,%edx
  800520:	74 4b                	je     80056d <vprintfmt+0x23f>
  800522:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800526:	78 06                	js     80052e <vprintfmt+0x200>
  800528:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80052c:	78 1e                	js     80054c <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80052e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800532:	74 d1                	je     800505 <vprintfmt+0x1d7>
  800534:	0f be c0             	movsbl %al,%eax
  800537:	83 e8 20             	sub    $0x20,%eax
  80053a:	83 f8 5e             	cmp    $0x5e,%eax
  80053d:	76 c6                	jbe    800505 <vprintfmt+0x1d7>
					putch('?', putdat);
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	53                   	push   %ebx
  800543:	6a 3f                	push   $0x3f
  800545:	ff d6                	call   *%esi
  800547:	83 c4 10             	add    $0x10,%esp
  80054a:	eb c3                	jmp    80050f <vprintfmt+0x1e1>
  80054c:	89 cf                	mov    %ecx,%edi
  80054e:	eb 0e                	jmp    80055e <vprintfmt+0x230>
				putch(' ', putdat);
  800550:	83 ec 08             	sub    $0x8,%esp
  800553:	53                   	push   %ebx
  800554:	6a 20                	push   $0x20
  800556:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800558:	83 ef 01             	sub    $0x1,%edi
  80055b:	83 c4 10             	add    $0x10,%esp
  80055e:	85 ff                	test   %edi,%edi
  800560:	7f ee                	jg     800550 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800562:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800565:	89 45 14             	mov    %eax,0x14(%ebp)
  800568:	e9 23 01 00 00       	jmp    800690 <vprintfmt+0x362>
  80056d:	89 cf                	mov    %ecx,%edi
  80056f:	eb ed                	jmp    80055e <vprintfmt+0x230>
	if (lflag >= 2)
  800571:	83 f9 01             	cmp    $0x1,%ecx
  800574:	7f 1b                	jg     800591 <vprintfmt+0x263>
	else if (lflag)
  800576:	85 c9                	test   %ecx,%ecx
  800578:	74 63                	je     8005dd <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80057a:	8b 45 14             	mov    0x14(%ebp),%eax
  80057d:	8b 00                	mov    (%eax),%eax
  80057f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800582:	99                   	cltd   
  800583:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8d 40 04             	lea    0x4(%eax),%eax
  80058c:	89 45 14             	mov    %eax,0x14(%ebp)
  80058f:	eb 17                	jmp    8005a8 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800591:	8b 45 14             	mov    0x14(%ebp),%eax
  800594:	8b 50 04             	mov    0x4(%eax),%edx
  800597:	8b 00                	mov    (%eax),%eax
  800599:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80059f:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a2:	8d 40 08             	lea    0x8(%eax),%eax
  8005a5:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005a8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ab:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005ae:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005b3:	85 c9                	test   %ecx,%ecx
  8005b5:	0f 89 bb 00 00 00    	jns    800676 <vprintfmt+0x348>
				putch('-', putdat);
  8005bb:	83 ec 08             	sub    $0x8,%esp
  8005be:	53                   	push   %ebx
  8005bf:	6a 2d                	push   $0x2d
  8005c1:	ff d6                	call   *%esi
				num = -(long long) num;
  8005c3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005c9:	f7 da                	neg    %edx
  8005cb:	83 d1 00             	adc    $0x0,%ecx
  8005ce:	f7 d9                	neg    %ecx
  8005d0:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005d3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d8:	e9 99 00 00 00       	jmp    800676 <vprintfmt+0x348>
		return va_arg(*ap, int);
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8b 00                	mov    (%eax),%eax
  8005e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e5:	99                   	cltd   
  8005e6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	8d 40 04             	lea    0x4(%eax),%eax
  8005ef:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f2:	eb b4                	jmp    8005a8 <vprintfmt+0x27a>
	if (lflag >= 2)
  8005f4:	83 f9 01             	cmp    $0x1,%ecx
  8005f7:	7f 1b                	jg     800614 <vprintfmt+0x2e6>
	else if (lflag)
  8005f9:	85 c9                	test   %ecx,%ecx
  8005fb:	74 2c                	je     800629 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  8005fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800600:	8b 10                	mov    (%eax),%edx
  800602:	b9 00 00 00 00       	mov    $0x0,%ecx
  800607:	8d 40 04             	lea    0x4(%eax),%eax
  80060a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80060d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800612:	eb 62                	jmp    800676 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8b 10                	mov    (%eax),%edx
  800619:	8b 48 04             	mov    0x4(%eax),%ecx
  80061c:	8d 40 08             	lea    0x8(%eax),%eax
  80061f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800622:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800627:	eb 4d                	jmp    800676 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800629:	8b 45 14             	mov    0x14(%ebp),%eax
  80062c:	8b 10                	mov    (%eax),%edx
  80062e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800633:	8d 40 04             	lea    0x4(%eax),%eax
  800636:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800639:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80063e:	eb 36                	jmp    800676 <vprintfmt+0x348>
	if (lflag >= 2)
  800640:	83 f9 01             	cmp    $0x1,%ecx
  800643:	7f 17                	jg     80065c <vprintfmt+0x32e>
	else if (lflag)
  800645:	85 c9                	test   %ecx,%ecx
  800647:	74 6e                	je     8006b7 <vprintfmt+0x389>
		return va_arg(*ap, long);
  800649:	8b 45 14             	mov    0x14(%ebp),%eax
  80064c:	8b 10                	mov    (%eax),%edx
  80064e:	89 d0                	mov    %edx,%eax
  800650:	99                   	cltd   
  800651:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800654:	8d 49 04             	lea    0x4(%ecx),%ecx
  800657:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80065a:	eb 11                	jmp    80066d <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  80065c:	8b 45 14             	mov    0x14(%ebp),%eax
  80065f:	8b 50 04             	mov    0x4(%eax),%edx
  800662:	8b 00                	mov    (%eax),%eax
  800664:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800667:	8d 49 08             	lea    0x8(%ecx),%ecx
  80066a:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  80066d:	89 d1                	mov    %edx,%ecx
  80066f:	89 c2                	mov    %eax,%edx
            base = 8;
  800671:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800676:	83 ec 0c             	sub    $0xc,%esp
  800679:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80067d:	57                   	push   %edi
  80067e:	ff 75 e0             	pushl  -0x20(%ebp)
  800681:	50                   	push   %eax
  800682:	51                   	push   %ecx
  800683:	52                   	push   %edx
  800684:	89 da                	mov    %ebx,%edx
  800686:	89 f0                	mov    %esi,%eax
  800688:	e8 b6 fb ff ff       	call   800243 <printnum>
			break;
  80068d:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800690:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800693:	83 c7 01             	add    $0x1,%edi
  800696:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80069a:	83 f8 25             	cmp    $0x25,%eax
  80069d:	0f 84 a6 fc ff ff    	je     800349 <vprintfmt+0x1b>
			if (ch == '\0')
  8006a3:	85 c0                	test   %eax,%eax
  8006a5:	0f 84 ce 00 00 00    	je     800779 <vprintfmt+0x44b>
			putch(ch, putdat);
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	53                   	push   %ebx
  8006af:	50                   	push   %eax
  8006b0:	ff d6                	call   *%esi
  8006b2:	83 c4 10             	add    $0x10,%esp
  8006b5:	eb dc                	jmp    800693 <vprintfmt+0x365>
		return va_arg(*ap, int);
  8006b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ba:	8b 10                	mov    (%eax),%edx
  8006bc:	89 d0                	mov    %edx,%eax
  8006be:	99                   	cltd   
  8006bf:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006c2:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006c5:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006c8:	eb a3                	jmp    80066d <vprintfmt+0x33f>
			putch('0', putdat);
  8006ca:	83 ec 08             	sub    $0x8,%esp
  8006cd:	53                   	push   %ebx
  8006ce:	6a 30                	push   $0x30
  8006d0:	ff d6                	call   *%esi
			putch('x', putdat);
  8006d2:	83 c4 08             	add    $0x8,%esp
  8006d5:	53                   	push   %ebx
  8006d6:	6a 78                	push   $0x78
  8006d8:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006da:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dd:	8b 10                	mov    (%eax),%edx
  8006df:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006e4:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006e7:	8d 40 04             	lea    0x4(%eax),%eax
  8006ea:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ed:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006f2:	eb 82                	jmp    800676 <vprintfmt+0x348>
	if (lflag >= 2)
  8006f4:	83 f9 01             	cmp    $0x1,%ecx
  8006f7:	7f 1e                	jg     800717 <vprintfmt+0x3e9>
	else if (lflag)
  8006f9:	85 c9                	test   %ecx,%ecx
  8006fb:	74 32                	je     80072f <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  8006fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800700:	8b 10                	mov    (%eax),%edx
  800702:	b9 00 00 00 00       	mov    $0x0,%ecx
  800707:	8d 40 04             	lea    0x4(%eax),%eax
  80070a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80070d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800712:	e9 5f ff ff ff       	jmp    800676 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800717:	8b 45 14             	mov    0x14(%ebp),%eax
  80071a:	8b 10                	mov    (%eax),%edx
  80071c:	8b 48 04             	mov    0x4(%eax),%ecx
  80071f:	8d 40 08             	lea    0x8(%eax),%eax
  800722:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800725:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80072a:	e9 47 ff ff ff       	jmp    800676 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80072f:	8b 45 14             	mov    0x14(%ebp),%eax
  800732:	8b 10                	mov    (%eax),%edx
  800734:	b9 00 00 00 00       	mov    $0x0,%ecx
  800739:	8d 40 04             	lea    0x4(%eax),%eax
  80073c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80073f:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800744:	e9 2d ff ff ff       	jmp    800676 <vprintfmt+0x348>
			putch(ch, putdat);
  800749:	83 ec 08             	sub    $0x8,%esp
  80074c:	53                   	push   %ebx
  80074d:	6a 25                	push   $0x25
  80074f:	ff d6                	call   *%esi
			break;
  800751:	83 c4 10             	add    $0x10,%esp
  800754:	e9 37 ff ff ff       	jmp    800690 <vprintfmt+0x362>
			putch('%', putdat);
  800759:	83 ec 08             	sub    $0x8,%esp
  80075c:	53                   	push   %ebx
  80075d:	6a 25                	push   $0x25
  80075f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800761:	83 c4 10             	add    $0x10,%esp
  800764:	89 f8                	mov    %edi,%eax
  800766:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80076a:	74 05                	je     800771 <vprintfmt+0x443>
  80076c:	83 e8 01             	sub    $0x1,%eax
  80076f:	eb f5                	jmp    800766 <vprintfmt+0x438>
  800771:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800774:	e9 17 ff ff ff       	jmp    800690 <vprintfmt+0x362>
}
  800779:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80077c:	5b                   	pop    %ebx
  80077d:	5e                   	pop    %esi
  80077e:	5f                   	pop    %edi
  80077f:	5d                   	pop    %ebp
  800780:	c3                   	ret    

00800781 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800781:	f3 0f 1e fb          	endbr32 
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	83 ec 18             	sub    $0x18,%esp
  80078b:	8b 45 08             	mov    0x8(%ebp),%eax
  80078e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800791:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800794:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800798:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80079b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007a2:	85 c0                	test   %eax,%eax
  8007a4:	74 26                	je     8007cc <vsnprintf+0x4b>
  8007a6:	85 d2                	test   %edx,%edx
  8007a8:	7e 22                	jle    8007cc <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007aa:	ff 75 14             	pushl  0x14(%ebp)
  8007ad:	ff 75 10             	pushl  0x10(%ebp)
  8007b0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007b3:	50                   	push   %eax
  8007b4:	68 ec 02 80 00       	push   $0x8002ec
  8007b9:	e8 70 fb ff ff       	call   80032e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007be:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007c1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007c7:	83 c4 10             	add    $0x10,%esp
}
  8007ca:	c9                   	leave  
  8007cb:	c3                   	ret    
		return -E_INVAL;
  8007cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007d1:	eb f7                	jmp    8007ca <vsnprintf+0x49>

008007d3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007d3:	f3 0f 1e fb          	endbr32 
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007dd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007e0:	50                   	push   %eax
  8007e1:	ff 75 10             	pushl  0x10(%ebp)
  8007e4:	ff 75 0c             	pushl  0xc(%ebp)
  8007e7:	ff 75 08             	pushl  0x8(%ebp)
  8007ea:	e8 92 ff ff ff       	call   800781 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ef:	c9                   	leave  
  8007f0:	c3                   	ret    

008007f1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f1:	f3 0f 1e fb          	endbr32 
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800800:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800804:	74 05                	je     80080b <strlen+0x1a>
		n++;
  800806:	83 c0 01             	add    $0x1,%eax
  800809:	eb f5                	jmp    800800 <strlen+0xf>
	return n;
}
  80080b:	5d                   	pop    %ebp
  80080c:	c3                   	ret    

0080080d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80080d:	f3 0f 1e fb          	endbr32 
  800811:	55                   	push   %ebp
  800812:	89 e5                	mov    %esp,%ebp
  800814:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800817:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081a:	b8 00 00 00 00       	mov    $0x0,%eax
  80081f:	39 d0                	cmp    %edx,%eax
  800821:	74 0d                	je     800830 <strnlen+0x23>
  800823:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800827:	74 05                	je     80082e <strnlen+0x21>
		n++;
  800829:	83 c0 01             	add    $0x1,%eax
  80082c:	eb f1                	jmp    80081f <strnlen+0x12>
  80082e:	89 c2                	mov    %eax,%edx
	return n;
}
  800830:	89 d0                	mov    %edx,%eax
  800832:	5d                   	pop    %ebp
  800833:	c3                   	ret    

00800834 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800834:	f3 0f 1e fb          	endbr32 
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	53                   	push   %ebx
  80083c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800842:	b8 00 00 00 00       	mov    $0x0,%eax
  800847:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80084b:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80084e:	83 c0 01             	add    $0x1,%eax
  800851:	84 d2                	test   %dl,%dl
  800853:	75 f2                	jne    800847 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800855:	89 c8                	mov    %ecx,%eax
  800857:	5b                   	pop    %ebx
  800858:	5d                   	pop    %ebp
  800859:	c3                   	ret    

0080085a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80085a:	f3 0f 1e fb          	endbr32 
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	53                   	push   %ebx
  800862:	83 ec 10             	sub    $0x10,%esp
  800865:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800868:	53                   	push   %ebx
  800869:	e8 83 ff ff ff       	call   8007f1 <strlen>
  80086e:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800871:	ff 75 0c             	pushl  0xc(%ebp)
  800874:	01 d8                	add    %ebx,%eax
  800876:	50                   	push   %eax
  800877:	e8 b8 ff ff ff       	call   800834 <strcpy>
	return dst;
}
  80087c:	89 d8                	mov    %ebx,%eax
  80087e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800881:	c9                   	leave  
  800882:	c3                   	ret    

00800883 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800883:	f3 0f 1e fb          	endbr32 
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	56                   	push   %esi
  80088b:	53                   	push   %ebx
  80088c:	8b 75 08             	mov    0x8(%ebp),%esi
  80088f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800892:	89 f3                	mov    %esi,%ebx
  800894:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800897:	89 f0                	mov    %esi,%eax
  800899:	39 d8                	cmp    %ebx,%eax
  80089b:	74 11                	je     8008ae <strncpy+0x2b>
		*dst++ = *src;
  80089d:	83 c0 01             	add    $0x1,%eax
  8008a0:	0f b6 0a             	movzbl (%edx),%ecx
  8008a3:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008a6:	80 f9 01             	cmp    $0x1,%cl
  8008a9:	83 da ff             	sbb    $0xffffffff,%edx
  8008ac:	eb eb                	jmp    800899 <strncpy+0x16>
	}
	return ret;
}
  8008ae:	89 f0                	mov    %esi,%eax
  8008b0:	5b                   	pop    %ebx
  8008b1:	5e                   	pop    %esi
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008b4:	f3 0f 1e fb          	endbr32 
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	56                   	push   %esi
  8008bc:	53                   	push   %ebx
  8008bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c3:	8b 55 10             	mov    0x10(%ebp),%edx
  8008c6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008c8:	85 d2                	test   %edx,%edx
  8008ca:	74 21                	je     8008ed <strlcpy+0x39>
  8008cc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008d0:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008d2:	39 c2                	cmp    %eax,%edx
  8008d4:	74 14                	je     8008ea <strlcpy+0x36>
  8008d6:	0f b6 19             	movzbl (%ecx),%ebx
  8008d9:	84 db                	test   %bl,%bl
  8008db:	74 0b                	je     8008e8 <strlcpy+0x34>
			*dst++ = *src++;
  8008dd:	83 c1 01             	add    $0x1,%ecx
  8008e0:	83 c2 01             	add    $0x1,%edx
  8008e3:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008e6:	eb ea                	jmp    8008d2 <strlcpy+0x1e>
  8008e8:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008ea:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008ed:	29 f0                	sub    %esi,%eax
}
  8008ef:	5b                   	pop    %ebx
  8008f0:	5e                   	pop    %esi
  8008f1:	5d                   	pop    %ebp
  8008f2:	c3                   	ret    

008008f3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008f3:	f3 0f 1e fb          	endbr32 
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008fd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800900:	0f b6 01             	movzbl (%ecx),%eax
  800903:	84 c0                	test   %al,%al
  800905:	74 0c                	je     800913 <strcmp+0x20>
  800907:	3a 02                	cmp    (%edx),%al
  800909:	75 08                	jne    800913 <strcmp+0x20>
		p++, q++;
  80090b:	83 c1 01             	add    $0x1,%ecx
  80090e:	83 c2 01             	add    $0x1,%edx
  800911:	eb ed                	jmp    800900 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800913:	0f b6 c0             	movzbl %al,%eax
  800916:	0f b6 12             	movzbl (%edx),%edx
  800919:	29 d0                	sub    %edx,%eax
}
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80091d:	f3 0f 1e fb          	endbr32 
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	53                   	push   %ebx
  800925:	8b 45 08             	mov    0x8(%ebp),%eax
  800928:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092b:	89 c3                	mov    %eax,%ebx
  80092d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800930:	eb 06                	jmp    800938 <strncmp+0x1b>
		n--, p++, q++;
  800932:	83 c0 01             	add    $0x1,%eax
  800935:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800938:	39 d8                	cmp    %ebx,%eax
  80093a:	74 16                	je     800952 <strncmp+0x35>
  80093c:	0f b6 08             	movzbl (%eax),%ecx
  80093f:	84 c9                	test   %cl,%cl
  800941:	74 04                	je     800947 <strncmp+0x2a>
  800943:	3a 0a                	cmp    (%edx),%cl
  800945:	74 eb                	je     800932 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800947:	0f b6 00             	movzbl (%eax),%eax
  80094a:	0f b6 12             	movzbl (%edx),%edx
  80094d:	29 d0                	sub    %edx,%eax
}
  80094f:	5b                   	pop    %ebx
  800950:	5d                   	pop    %ebp
  800951:	c3                   	ret    
		return 0;
  800952:	b8 00 00 00 00       	mov    $0x0,%eax
  800957:	eb f6                	jmp    80094f <strncmp+0x32>

00800959 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800959:	f3 0f 1e fb          	endbr32 
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
  800963:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800967:	0f b6 10             	movzbl (%eax),%edx
  80096a:	84 d2                	test   %dl,%dl
  80096c:	74 09                	je     800977 <strchr+0x1e>
		if (*s == c)
  80096e:	38 ca                	cmp    %cl,%dl
  800970:	74 0a                	je     80097c <strchr+0x23>
	for (; *s; s++)
  800972:	83 c0 01             	add    $0x1,%eax
  800975:	eb f0                	jmp    800967 <strchr+0xe>
			return (char *) s;
	return 0;
  800977:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80097e:	f3 0f 1e fb          	endbr32 
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80098c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80098f:	38 ca                	cmp    %cl,%dl
  800991:	74 09                	je     80099c <strfind+0x1e>
  800993:	84 d2                	test   %dl,%dl
  800995:	74 05                	je     80099c <strfind+0x1e>
	for (; *s; s++)
  800997:	83 c0 01             	add    $0x1,%eax
  80099a:	eb f0                	jmp    80098c <strfind+0xe>
			break;
	return (char *) s;
}
  80099c:	5d                   	pop    %ebp
  80099d:	c3                   	ret    

0080099e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80099e:	f3 0f 1e fb          	endbr32 
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	57                   	push   %edi
  8009a6:	56                   	push   %esi
  8009a7:	53                   	push   %ebx
  8009a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ab:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009ae:	85 c9                	test   %ecx,%ecx
  8009b0:	74 31                	je     8009e3 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009b2:	89 f8                	mov    %edi,%eax
  8009b4:	09 c8                	or     %ecx,%eax
  8009b6:	a8 03                	test   $0x3,%al
  8009b8:	75 23                	jne    8009dd <memset+0x3f>
		c &= 0xFF;
  8009ba:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009be:	89 d3                	mov    %edx,%ebx
  8009c0:	c1 e3 08             	shl    $0x8,%ebx
  8009c3:	89 d0                	mov    %edx,%eax
  8009c5:	c1 e0 18             	shl    $0x18,%eax
  8009c8:	89 d6                	mov    %edx,%esi
  8009ca:	c1 e6 10             	shl    $0x10,%esi
  8009cd:	09 f0                	or     %esi,%eax
  8009cf:	09 c2                	or     %eax,%edx
  8009d1:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009d3:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009d6:	89 d0                	mov    %edx,%eax
  8009d8:	fc                   	cld    
  8009d9:	f3 ab                	rep stos %eax,%es:(%edi)
  8009db:	eb 06                	jmp    8009e3 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e0:	fc                   	cld    
  8009e1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009e3:	89 f8                	mov    %edi,%eax
  8009e5:	5b                   	pop    %ebx
  8009e6:	5e                   	pop    %esi
  8009e7:	5f                   	pop    %edi
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009ea:	f3 0f 1e fb          	endbr32 
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	57                   	push   %edi
  8009f2:	56                   	push   %esi
  8009f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009fc:	39 c6                	cmp    %eax,%esi
  8009fe:	73 32                	jae    800a32 <memmove+0x48>
  800a00:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a03:	39 c2                	cmp    %eax,%edx
  800a05:	76 2b                	jbe    800a32 <memmove+0x48>
		s += n;
		d += n;
  800a07:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0a:	89 fe                	mov    %edi,%esi
  800a0c:	09 ce                	or     %ecx,%esi
  800a0e:	09 d6                	or     %edx,%esi
  800a10:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a16:	75 0e                	jne    800a26 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a18:	83 ef 04             	sub    $0x4,%edi
  800a1b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a1e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a21:	fd                   	std    
  800a22:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a24:	eb 09                	jmp    800a2f <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a26:	83 ef 01             	sub    $0x1,%edi
  800a29:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a2c:	fd                   	std    
  800a2d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a2f:	fc                   	cld    
  800a30:	eb 1a                	jmp    800a4c <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a32:	89 c2                	mov    %eax,%edx
  800a34:	09 ca                	or     %ecx,%edx
  800a36:	09 f2                	or     %esi,%edx
  800a38:	f6 c2 03             	test   $0x3,%dl
  800a3b:	75 0a                	jne    800a47 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a3d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a40:	89 c7                	mov    %eax,%edi
  800a42:	fc                   	cld    
  800a43:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a45:	eb 05                	jmp    800a4c <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a47:	89 c7                	mov    %eax,%edi
  800a49:	fc                   	cld    
  800a4a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a4c:	5e                   	pop    %esi
  800a4d:	5f                   	pop    %edi
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    

00800a50 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a50:	f3 0f 1e fb          	endbr32 
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a5a:	ff 75 10             	pushl  0x10(%ebp)
  800a5d:	ff 75 0c             	pushl  0xc(%ebp)
  800a60:	ff 75 08             	pushl  0x8(%ebp)
  800a63:	e8 82 ff ff ff       	call   8009ea <memmove>
}
  800a68:	c9                   	leave  
  800a69:	c3                   	ret    

00800a6a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a6a:	f3 0f 1e fb          	endbr32 
  800a6e:	55                   	push   %ebp
  800a6f:	89 e5                	mov    %esp,%ebp
  800a71:	56                   	push   %esi
  800a72:	53                   	push   %ebx
  800a73:	8b 45 08             	mov    0x8(%ebp),%eax
  800a76:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a79:	89 c6                	mov    %eax,%esi
  800a7b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a7e:	39 f0                	cmp    %esi,%eax
  800a80:	74 1c                	je     800a9e <memcmp+0x34>
		if (*s1 != *s2)
  800a82:	0f b6 08             	movzbl (%eax),%ecx
  800a85:	0f b6 1a             	movzbl (%edx),%ebx
  800a88:	38 d9                	cmp    %bl,%cl
  800a8a:	75 08                	jne    800a94 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a8c:	83 c0 01             	add    $0x1,%eax
  800a8f:	83 c2 01             	add    $0x1,%edx
  800a92:	eb ea                	jmp    800a7e <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a94:	0f b6 c1             	movzbl %cl,%eax
  800a97:	0f b6 db             	movzbl %bl,%ebx
  800a9a:	29 d8                	sub    %ebx,%eax
  800a9c:	eb 05                	jmp    800aa3 <memcmp+0x39>
	}

	return 0;
  800a9e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa3:	5b                   	pop    %ebx
  800aa4:	5e                   	pop    %esi
  800aa5:	5d                   	pop    %ebp
  800aa6:	c3                   	ret    

00800aa7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aa7:	f3 0f 1e fb          	endbr32 
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ab4:	89 c2                	mov    %eax,%edx
  800ab6:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ab9:	39 d0                	cmp    %edx,%eax
  800abb:	73 09                	jae    800ac6 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800abd:	38 08                	cmp    %cl,(%eax)
  800abf:	74 05                	je     800ac6 <memfind+0x1f>
	for (; s < ends; s++)
  800ac1:	83 c0 01             	add    $0x1,%eax
  800ac4:	eb f3                	jmp    800ab9 <memfind+0x12>
			break;
	return (void *) s;
}
  800ac6:	5d                   	pop    %ebp
  800ac7:	c3                   	ret    

00800ac8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ac8:	f3 0f 1e fb          	endbr32 
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	57                   	push   %edi
  800ad0:	56                   	push   %esi
  800ad1:	53                   	push   %ebx
  800ad2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad8:	eb 03                	jmp    800add <strtol+0x15>
		s++;
  800ada:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800add:	0f b6 01             	movzbl (%ecx),%eax
  800ae0:	3c 20                	cmp    $0x20,%al
  800ae2:	74 f6                	je     800ada <strtol+0x12>
  800ae4:	3c 09                	cmp    $0x9,%al
  800ae6:	74 f2                	je     800ada <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800ae8:	3c 2b                	cmp    $0x2b,%al
  800aea:	74 2a                	je     800b16 <strtol+0x4e>
	int neg = 0;
  800aec:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800af1:	3c 2d                	cmp    $0x2d,%al
  800af3:	74 2b                	je     800b20 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800af5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800afb:	75 0f                	jne    800b0c <strtol+0x44>
  800afd:	80 39 30             	cmpb   $0x30,(%ecx)
  800b00:	74 28                	je     800b2a <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b02:	85 db                	test   %ebx,%ebx
  800b04:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b09:	0f 44 d8             	cmove  %eax,%ebx
  800b0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b11:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b14:	eb 46                	jmp    800b5c <strtol+0x94>
		s++;
  800b16:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b19:	bf 00 00 00 00       	mov    $0x0,%edi
  800b1e:	eb d5                	jmp    800af5 <strtol+0x2d>
		s++, neg = 1;
  800b20:	83 c1 01             	add    $0x1,%ecx
  800b23:	bf 01 00 00 00       	mov    $0x1,%edi
  800b28:	eb cb                	jmp    800af5 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b2a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b2e:	74 0e                	je     800b3e <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b30:	85 db                	test   %ebx,%ebx
  800b32:	75 d8                	jne    800b0c <strtol+0x44>
		s++, base = 8;
  800b34:	83 c1 01             	add    $0x1,%ecx
  800b37:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b3c:	eb ce                	jmp    800b0c <strtol+0x44>
		s += 2, base = 16;
  800b3e:	83 c1 02             	add    $0x2,%ecx
  800b41:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b46:	eb c4                	jmp    800b0c <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b48:	0f be d2             	movsbl %dl,%edx
  800b4b:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b4e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b51:	7d 3a                	jge    800b8d <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b53:	83 c1 01             	add    $0x1,%ecx
  800b56:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b5a:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b5c:	0f b6 11             	movzbl (%ecx),%edx
  800b5f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b62:	89 f3                	mov    %esi,%ebx
  800b64:	80 fb 09             	cmp    $0x9,%bl
  800b67:	76 df                	jbe    800b48 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b69:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b6c:	89 f3                	mov    %esi,%ebx
  800b6e:	80 fb 19             	cmp    $0x19,%bl
  800b71:	77 08                	ja     800b7b <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b73:	0f be d2             	movsbl %dl,%edx
  800b76:	83 ea 57             	sub    $0x57,%edx
  800b79:	eb d3                	jmp    800b4e <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b7b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b7e:	89 f3                	mov    %esi,%ebx
  800b80:	80 fb 19             	cmp    $0x19,%bl
  800b83:	77 08                	ja     800b8d <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b85:	0f be d2             	movsbl %dl,%edx
  800b88:	83 ea 37             	sub    $0x37,%edx
  800b8b:	eb c1                	jmp    800b4e <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b8d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b91:	74 05                	je     800b98 <strtol+0xd0>
		*endptr = (char *) s;
  800b93:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b96:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b98:	89 c2                	mov    %eax,%edx
  800b9a:	f7 da                	neg    %edx
  800b9c:	85 ff                	test   %edi,%edi
  800b9e:	0f 45 c2             	cmovne %edx,%eax
}
  800ba1:	5b                   	pop    %ebx
  800ba2:	5e                   	pop    %esi
  800ba3:	5f                   	pop    %edi
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ba6:	f3 0f 1e fb          	endbr32 
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	57                   	push   %edi
  800bae:	56                   	push   %esi
  800baf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb0:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbb:	89 c3                	mov    %eax,%ebx
  800bbd:	89 c7                	mov    %eax,%edi
  800bbf:	89 c6                	mov    %eax,%esi
  800bc1:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bc3:	5b                   	pop    %ebx
  800bc4:	5e                   	pop    %esi
  800bc5:	5f                   	pop    %edi
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    

00800bc8 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bc8:	f3 0f 1e fb          	endbr32 
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	57                   	push   %edi
  800bd0:	56                   	push   %esi
  800bd1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd7:	b8 01 00 00 00       	mov    $0x1,%eax
  800bdc:	89 d1                	mov    %edx,%ecx
  800bde:	89 d3                	mov    %edx,%ebx
  800be0:	89 d7                	mov    %edx,%edi
  800be2:	89 d6                	mov    %edx,%esi
  800be4:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800be6:	5b                   	pop    %ebx
  800be7:	5e                   	pop    %esi
  800be8:	5f                   	pop    %edi
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800beb:	f3 0f 1e fb          	endbr32 
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	57                   	push   %edi
  800bf3:	56                   	push   %esi
  800bf4:	53                   	push   %ebx
  800bf5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bf8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800c00:	b8 03 00 00 00       	mov    $0x3,%eax
  800c05:	89 cb                	mov    %ecx,%ebx
  800c07:	89 cf                	mov    %ecx,%edi
  800c09:	89 ce                	mov    %ecx,%esi
  800c0b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c0d:	85 c0                	test   %eax,%eax
  800c0f:	7f 08                	jg     800c19 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c14:	5b                   	pop    %ebx
  800c15:	5e                   	pop    %esi
  800c16:	5f                   	pop    %edi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c19:	83 ec 0c             	sub    $0xc,%esp
  800c1c:	50                   	push   %eax
  800c1d:	6a 03                	push   $0x3
  800c1f:	68 7f 23 80 00       	push   $0x80237f
  800c24:	6a 23                	push   $0x23
  800c26:	68 9c 23 80 00       	push   $0x80239c
  800c2b:	e8 14 f5 ff ff       	call   800144 <_panic>

00800c30 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c30:	f3 0f 1e fb          	endbr32 
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	57                   	push   %edi
  800c38:	56                   	push   %esi
  800c39:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3f:	b8 02 00 00 00       	mov    $0x2,%eax
  800c44:	89 d1                	mov    %edx,%ecx
  800c46:	89 d3                	mov    %edx,%ebx
  800c48:	89 d7                	mov    %edx,%edi
  800c4a:	89 d6                	mov    %edx,%esi
  800c4c:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c4e:	5b                   	pop    %ebx
  800c4f:	5e                   	pop    %esi
  800c50:	5f                   	pop    %edi
  800c51:	5d                   	pop    %ebp
  800c52:	c3                   	ret    

00800c53 <sys_yield>:

void
sys_yield(void)
{
  800c53:	f3 0f 1e fb          	endbr32 
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c62:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c67:	89 d1                	mov    %edx,%ecx
  800c69:	89 d3                	mov    %edx,%ebx
  800c6b:	89 d7                	mov    %edx,%edi
  800c6d:	89 d6                	mov    %edx,%esi
  800c6f:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c71:	5b                   	pop    %ebx
  800c72:	5e                   	pop    %esi
  800c73:	5f                   	pop    %edi
  800c74:	5d                   	pop    %ebp
  800c75:	c3                   	ret    

00800c76 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c76:	f3 0f 1e fb          	endbr32 
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	57                   	push   %edi
  800c7e:	56                   	push   %esi
  800c7f:	53                   	push   %ebx
  800c80:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c83:	be 00 00 00 00       	mov    $0x0,%esi
  800c88:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8e:	b8 04 00 00 00       	mov    $0x4,%eax
  800c93:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c96:	89 f7                	mov    %esi,%edi
  800c98:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c9a:	85 c0                	test   %eax,%eax
  800c9c:	7f 08                	jg     800ca6 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5f                   	pop    %edi
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca6:	83 ec 0c             	sub    $0xc,%esp
  800ca9:	50                   	push   %eax
  800caa:	6a 04                	push   $0x4
  800cac:	68 7f 23 80 00       	push   $0x80237f
  800cb1:	6a 23                	push   $0x23
  800cb3:	68 9c 23 80 00       	push   $0x80239c
  800cb8:	e8 87 f4 ff ff       	call   800144 <_panic>

00800cbd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cbd:	f3 0f 1e fb          	endbr32 
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cca:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd0:	b8 05 00 00 00       	mov    $0x5,%eax
  800cd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cdb:	8b 75 18             	mov    0x18(%ebp),%esi
  800cde:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	7f 08                	jg     800cec <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ce4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cec:	83 ec 0c             	sub    $0xc,%esp
  800cef:	50                   	push   %eax
  800cf0:	6a 05                	push   $0x5
  800cf2:	68 7f 23 80 00       	push   $0x80237f
  800cf7:	6a 23                	push   $0x23
  800cf9:	68 9c 23 80 00       	push   $0x80239c
  800cfe:	e8 41 f4 ff ff       	call   800144 <_panic>

00800d03 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d03:	f3 0f 1e fb          	endbr32 
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
  800d0d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d15:	8b 55 08             	mov    0x8(%ebp),%edx
  800d18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1b:	b8 06 00 00 00       	mov    $0x6,%eax
  800d20:	89 df                	mov    %ebx,%edi
  800d22:	89 de                	mov    %ebx,%esi
  800d24:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d26:	85 c0                	test   %eax,%eax
  800d28:	7f 08                	jg     800d32 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2d:	5b                   	pop    %ebx
  800d2e:	5e                   	pop    %esi
  800d2f:	5f                   	pop    %edi
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d32:	83 ec 0c             	sub    $0xc,%esp
  800d35:	50                   	push   %eax
  800d36:	6a 06                	push   $0x6
  800d38:	68 7f 23 80 00       	push   $0x80237f
  800d3d:	6a 23                	push   $0x23
  800d3f:	68 9c 23 80 00       	push   $0x80239c
  800d44:	e8 fb f3 ff ff       	call   800144 <_panic>

00800d49 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d49:	f3 0f 1e fb          	endbr32 
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	57                   	push   %edi
  800d51:	56                   	push   %esi
  800d52:	53                   	push   %ebx
  800d53:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d56:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d61:	b8 08 00 00 00       	mov    $0x8,%eax
  800d66:	89 df                	mov    %ebx,%edi
  800d68:	89 de                	mov    %ebx,%esi
  800d6a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d6c:	85 c0                	test   %eax,%eax
  800d6e:	7f 08                	jg     800d78 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5f                   	pop    %edi
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d78:	83 ec 0c             	sub    $0xc,%esp
  800d7b:	50                   	push   %eax
  800d7c:	6a 08                	push   $0x8
  800d7e:	68 7f 23 80 00       	push   $0x80237f
  800d83:	6a 23                	push   $0x23
  800d85:	68 9c 23 80 00       	push   $0x80239c
  800d8a:	e8 b5 f3 ff ff       	call   800144 <_panic>

00800d8f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d8f:	f3 0f 1e fb          	endbr32 
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	57                   	push   %edi
  800d97:	56                   	push   %esi
  800d98:	53                   	push   %ebx
  800d99:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da1:	8b 55 08             	mov    0x8(%ebp),%edx
  800da4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da7:	b8 09 00 00 00       	mov    $0x9,%eax
  800dac:	89 df                	mov    %ebx,%edi
  800dae:	89 de                	mov    %ebx,%esi
  800db0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800db2:	85 c0                	test   %eax,%eax
  800db4:	7f 08                	jg     800dbe <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800db6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db9:	5b                   	pop    %ebx
  800dba:	5e                   	pop    %esi
  800dbb:	5f                   	pop    %edi
  800dbc:	5d                   	pop    %ebp
  800dbd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbe:	83 ec 0c             	sub    $0xc,%esp
  800dc1:	50                   	push   %eax
  800dc2:	6a 09                	push   $0x9
  800dc4:	68 7f 23 80 00       	push   $0x80237f
  800dc9:	6a 23                	push   $0x23
  800dcb:	68 9c 23 80 00       	push   $0x80239c
  800dd0:	e8 6f f3 ff ff       	call   800144 <_panic>

00800dd5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dd5:	f3 0f 1e fb          	endbr32 
  800dd9:	55                   	push   %ebp
  800dda:	89 e5                	mov    %esp,%ebp
  800ddc:	57                   	push   %edi
  800ddd:	56                   	push   %esi
  800dde:	53                   	push   %ebx
  800ddf:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800de2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ded:	b8 0a 00 00 00       	mov    $0xa,%eax
  800df2:	89 df                	mov    %ebx,%edi
  800df4:	89 de                	mov    %ebx,%esi
  800df6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800df8:	85 c0                	test   %eax,%eax
  800dfa:	7f 08                	jg     800e04 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dff:	5b                   	pop    %ebx
  800e00:	5e                   	pop    %esi
  800e01:	5f                   	pop    %edi
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e04:	83 ec 0c             	sub    $0xc,%esp
  800e07:	50                   	push   %eax
  800e08:	6a 0a                	push   $0xa
  800e0a:	68 7f 23 80 00       	push   $0x80237f
  800e0f:	6a 23                	push   $0x23
  800e11:	68 9c 23 80 00       	push   $0x80239c
  800e16:	e8 29 f3 ff ff       	call   800144 <_panic>

00800e1b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e1b:	f3 0f 1e fb          	endbr32 
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	57                   	push   %edi
  800e23:	56                   	push   %esi
  800e24:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e25:	8b 55 08             	mov    0x8(%ebp),%edx
  800e28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e30:	be 00 00 00 00       	mov    $0x0,%esi
  800e35:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e38:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e3b:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e3d:	5b                   	pop    %ebx
  800e3e:	5e                   	pop    %esi
  800e3f:	5f                   	pop    %edi
  800e40:	5d                   	pop    %ebp
  800e41:	c3                   	ret    

00800e42 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e42:	f3 0f 1e fb          	endbr32 
  800e46:	55                   	push   %ebp
  800e47:	89 e5                	mov    %esp,%ebp
  800e49:	57                   	push   %edi
  800e4a:	56                   	push   %esi
  800e4b:	53                   	push   %ebx
  800e4c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e4f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e54:	8b 55 08             	mov    0x8(%ebp),%edx
  800e57:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e5c:	89 cb                	mov    %ecx,%ebx
  800e5e:	89 cf                	mov    %ecx,%edi
  800e60:	89 ce                	mov    %ecx,%esi
  800e62:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e64:	85 c0                	test   %eax,%eax
  800e66:	7f 08                	jg     800e70 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e6b:	5b                   	pop    %ebx
  800e6c:	5e                   	pop    %esi
  800e6d:	5f                   	pop    %edi
  800e6e:	5d                   	pop    %ebp
  800e6f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e70:	83 ec 0c             	sub    $0xc,%esp
  800e73:	50                   	push   %eax
  800e74:	6a 0d                	push   $0xd
  800e76:	68 7f 23 80 00       	push   $0x80237f
  800e7b:	6a 23                	push   $0x23
  800e7d:	68 9c 23 80 00       	push   $0x80239c
  800e82:	e8 bd f2 ff ff       	call   800144 <_panic>

00800e87 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e87:	f3 0f 1e fb          	endbr32 
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e91:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800e98:	74 0a                	je     800ea4 <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9d:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800ea2:	c9                   	leave  
  800ea3:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  800ea4:	83 ec 0c             	sub    $0xc,%esp
  800ea7:	68 aa 23 80 00       	push   $0x8023aa
  800eac:	e8 7a f3 ff ff       	call   80022b <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  800eb1:	83 c4 0c             	add    $0xc,%esp
  800eb4:	6a 07                	push   $0x7
  800eb6:	68 00 f0 bf ee       	push   $0xeebff000
  800ebb:	6a 00                	push   $0x0
  800ebd:	e8 b4 fd ff ff       	call   800c76 <sys_page_alloc>
  800ec2:	83 c4 10             	add    $0x10,%esp
  800ec5:	85 c0                	test   %eax,%eax
  800ec7:	78 2a                	js     800ef3 <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  800ec9:	83 ec 08             	sub    $0x8,%esp
  800ecc:	68 07 0f 80 00       	push   $0x800f07
  800ed1:	6a 00                	push   $0x0
  800ed3:	e8 fd fe ff ff       	call   800dd5 <sys_env_set_pgfault_upcall>
  800ed8:	83 c4 10             	add    $0x10,%esp
  800edb:	85 c0                	test   %eax,%eax
  800edd:	79 bb                	jns    800e9a <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  800edf:	83 ec 04             	sub    $0x4,%esp
  800ee2:	68 e8 23 80 00       	push   $0x8023e8
  800ee7:	6a 25                	push   $0x25
  800ee9:	68 d7 23 80 00       	push   $0x8023d7
  800eee:	e8 51 f2 ff ff       	call   800144 <_panic>
            panic("Allocation of UXSTACK failed!");
  800ef3:	83 ec 04             	sub    $0x4,%esp
  800ef6:	68 b9 23 80 00       	push   $0x8023b9
  800efb:	6a 22                	push   $0x22
  800efd:	68 d7 23 80 00       	push   $0x8023d7
  800f02:	e8 3d f2 ff ff       	call   800144 <_panic>

00800f07 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800f07:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800f08:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800f0d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800f0f:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  800f12:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  800f16:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  800f1a:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  800f1d:	83 c4 08             	add    $0x8,%esp
    popa
  800f20:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

    add $0x4, %esp
  800f21:	83 c4 04             	add    $0x4,%esp
    popf
  800f24:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  800f25:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  800f28:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  800f2c:	c3                   	ret    

00800f2d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f2d:	f3 0f 1e fb          	endbr32 
  800f31:	55                   	push   %ebp
  800f32:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f34:	8b 45 08             	mov    0x8(%ebp),%eax
  800f37:	05 00 00 00 30       	add    $0x30000000,%eax
  800f3c:	c1 e8 0c             	shr    $0xc,%eax
}
  800f3f:	5d                   	pop    %ebp
  800f40:	c3                   	ret    

00800f41 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f41:	f3 0f 1e fb          	endbr32 
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f48:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4b:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800f50:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f55:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f5a:	5d                   	pop    %ebp
  800f5b:	c3                   	ret    

00800f5c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f5c:	f3 0f 1e fb          	endbr32 
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
  800f63:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f68:	89 c2                	mov    %eax,%edx
  800f6a:	c1 ea 16             	shr    $0x16,%edx
  800f6d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f74:	f6 c2 01             	test   $0x1,%dl
  800f77:	74 2d                	je     800fa6 <fd_alloc+0x4a>
  800f79:	89 c2                	mov    %eax,%edx
  800f7b:	c1 ea 0c             	shr    $0xc,%edx
  800f7e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f85:	f6 c2 01             	test   $0x1,%dl
  800f88:	74 1c                	je     800fa6 <fd_alloc+0x4a>
  800f8a:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800f8f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f94:	75 d2                	jne    800f68 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f96:	8b 45 08             	mov    0x8(%ebp),%eax
  800f99:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800f9f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800fa4:	eb 0a                	jmp    800fb0 <fd_alloc+0x54>
			*fd_store = fd;
  800fa6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fa9:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fb0:	5d                   	pop    %ebp
  800fb1:	c3                   	ret    

00800fb2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fb2:	f3 0f 1e fb          	endbr32 
  800fb6:	55                   	push   %ebp
  800fb7:	89 e5                	mov    %esp,%ebp
  800fb9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800fbc:	83 f8 1f             	cmp    $0x1f,%eax
  800fbf:	77 30                	ja     800ff1 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800fc1:	c1 e0 0c             	shl    $0xc,%eax
  800fc4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fc9:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800fcf:	f6 c2 01             	test   $0x1,%dl
  800fd2:	74 24                	je     800ff8 <fd_lookup+0x46>
  800fd4:	89 c2                	mov    %eax,%edx
  800fd6:	c1 ea 0c             	shr    $0xc,%edx
  800fd9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fe0:	f6 c2 01             	test   $0x1,%dl
  800fe3:	74 1a                	je     800fff <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fe5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fe8:	89 02                	mov    %eax,(%edx)
	return 0;
  800fea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fef:	5d                   	pop    %ebp
  800ff0:	c3                   	ret    
		return -E_INVAL;
  800ff1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ff6:	eb f7                	jmp    800fef <fd_lookup+0x3d>
		return -E_INVAL;
  800ff8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ffd:	eb f0                	jmp    800fef <fd_lookup+0x3d>
  800fff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801004:	eb e9                	jmp    800fef <fd_lookup+0x3d>

00801006 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801006:	f3 0f 1e fb          	endbr32 
  80100a:	55                   	push   %ebp
  80100b:	89 e5                	mov    %esp,%ebp
  80100d:	83 ec 08             	sub    $0x8,%esp
  801010:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801013:	ba 88 24 80 00       	mov    $0x802488,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801018:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  80101d:	39 08                	cmp    %ecx,(%eax)
  80101f:	74 33                	je     801054 <dev_lookup+0x4e>
  801021:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801024:	8b 02                	mov    (%edx),%eax
  801026:	85 c0                	test   %eax,%eax
  801028:	75 f3                	jne    80101d <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80102a:	a1 04 40 80 00       	mov    0x804004,%eax
  80102f:	8b 40 48             	mov    0x48(%eax),%eax
  801032:	83 ec 04             	sub    $0x4,%esp
  801035:	51                   	push   %ecx
  801036:	50                   	push   %eax
  801037:	68 0c 24 80 00       	push   $0x80240c
  80103c:	e8 ea f1 ff ff       	call   80022b <cprintf>
	*dev = 0;
  801041:	8b 45 0c             	mov    0xc(%ebp),%eax
  801044:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80104a:	83 c4 10             	add    $0x10,%esp
  80104d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801052:	c9                   	leave  
  801053:	c3                   	ret    
			*dev = devtab[i];
  801054:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801057:	89 01                	mov    %eax,(%ecx)
			return 0;
  801059:	b8 00 00 00 00       	mov    $0x0,%eax
  80105e:	eb f2                	jmp    801052 <dev_lookup+0x4c>

00801060 <fd_close>:
{
  801060:	f3 0f 1e fb          	endbr32 
  801064:	55                   	push   %ebp
  801065:	89 e5                	mov    %esp,%ebp
  801067:	57                   	push   %edi
  801068:	56                   	push   %esi
  801069:	53                   	push   %ebx
  80106a:	83 ec 24             	sub    $0x24,%esp
  80106d:	8b 75 08             	mov    0x8(%ebp),%esi
  801070:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801073:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801076:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801077:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80107d:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801080:	50                   	push   %eax
  801081:	e8 2c ff ff ff       	call   800fb2 <fd_lookup>
  801086:	89 c3                	mov    %eax,%ebx
  801088:	83 c4 10             	add    $0x10,%esp
  80108b:	85 c0                	test   %eax,%eax
  80108d:	78 05                	js     801094 <fd_close+0x34>
	    || fd != fd2)
  80108f:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801092:	74 16                	je     8010aa <fd_close+0x4a>
		return (must_exist ? r : 0);
  801094:	89 f8                	mov    %edi,%eax
  801096:	84 c0                	test   %al,%al
  801098:	b8 00 00 00 00       	mov    $0x0,%eax
  80109d:	0f 44 d8             	cmove  %eax,%ebx
}
  8010a0:	89 d8                	mov    %ebx,%eax
  8010a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a5:	5b                   	pop    %ebx
  8010a6:	5e                   	pop    %esi
  8010a7:	5f                   	pop    %edi
  8010a8:	5d                   	pop    %ebp
  8010a9:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8010aa:	83 ec 08             	sub    $0x8,%esp
  8010ad:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8010b0:	50                   	push   %eax
  8010b1:	ff 36                	pushl  (%esi)
  8010b3:	e8 4e ff ff ff       	call   801006 <dev_lookup>
  8010b8:	89 c3                	mov    %eax,%ebx
  8010ba:	83 c4 10             	add    $0x10,%esp
  8010bd:	85 c0                	test   %eax,%eax
  8010bf:	78 1a                	js     8010db <fd_close+0x7b>
		if (dev->dev_close)
  8010c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010c4:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8010c7:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8010cc:	85 c0                	test   %eax,%eax
  8010ce:	74 0b                	je     8010db <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8010d0:	83 ec 0c             	sub    $0xc,%esp
  8010d3:	56                   	push   %esi
  8010d4:	ff d0                	call   *%eax
  8010d6:	89 c3                	mov    %eax,%ebx
  8010d8:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8010db:	83 ec 08             	sub    $0x8,%esp
  8010de:	56                   	push   %esi
  8010df:	6a 00                	push   $0x0
  8010e1:	e8 1d fc ff ff       	call   800d03 <sys_page_unmap>
	return r;
  8010e6:	83 c4 10             	add    $0x10,%esp
  8010e9:	eb b5                	jmp    8010a0 <fd_close+0x40>

008010eb <close>:

int
close(int fdnum)
{
  8010eb:	f3 0f 1e fb          	endbr32 
  8010ef:	55                   	push   %ebp
  8010f0:	89 e5                	mov    %esp,%ebp
  8010f2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010f8:	50                   	push   %eax
  8010f9:	ff 75 08             	pushl  0x8(%ebp)
  8010fc:	e8 b1 fe ff ff       	call   800fb2 <fd_lookup>
  801101:	83 c4 10             	add    $0x10,%esp
  801104:	85 c0                	test   %eax,%eax
  801106:	79 02                	jns    80110a <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801108:	c9                   	leave  
  801109:	c3                   	ret    
		return fd_close(fd, 1);
  80110a:	83 ec 08             	sub    $0x8,%esp
  80110d:	6a 01                	push   $0x1
  80110f:	ff 75 f4             	pushl  -0xc(%ebp)
  801112:	e8 49 ff ff ff       	call   801060 <fd_close>
  801117:	83 c4 10             	add    $0x10,%esp
  80111a:	eb ec                	jmp    801108 <close+0x1d>

0080111c <close_all>:

void
close_all(void)
{
  80111c:	f3 0f 1e fb          	endbr32 
  801120:	55                   	push   %ebp
  801121:	89 e5                	mov    %esp,%ebp
  801123:	53                   	push   %ebx
  801124:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801127:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80112c:	83 ec 0c             	sub    $0xc,%esp
  80112f:	53                   	push   %ebx
  801130:	e8 b6 ff ff ff       	call   8010eb <close>
	for (i = 0; i < MAXFD; i++)
  801135:	83 c3 01             	add    $0x1,%ebx
  801138:	83 c4 10             	add    $0x10,%esp
  80113b:	83 fb 20             	cmp    $0x20,%ebx
  80113e:	75 ec                	jne    80112c <close_all+0x10>
}
  801140:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801143:	c9                   	leave  
  801144:	c3                   	ret    

00801145 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801145:	f3 0f 1e fb          	endbr32 
  801149:	55                   	push   %ebp
  80114a:	89 e5                	mov    %esp,%ebp
  80114c:	57                   	push   %edi
  80114d:	56                   	push   %esi
  80114e:	53                   	push   %ebx
  80114f:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801152:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801155:	50                   	push   %eax
  801156:	ff 75 08             	pushl  0x8(%ebp)
  801159:	e8 54 fe ff ff       	call   800fb2 <fd_lookup>
  80115e:	89 c3                	mov    %eax,%ebx
  801160:	83 c4 10             	add    $0x10,%esp
  801163:	85 c0                	test   %eax,%eax
  801165:	0f 88 81 00 00 00    	js     8011ec <dup+0xa7>
		return r;
	close(newfdnum);
  80116b:	83 ec 0c             	sub    $0xc,%esp
  80116e:	ff 75 0c             	pushl  0xc(%ebp)
  801171:	e8 75 ff ff ff       	call   8010eb <close>

	newfd = INDEX2FD(newfdnum);
  801176:	8b 75 0c             	mov    0xc(%ebp),%esi
  801179:	c1 e6 0c             	shl    $0xc,%esi
  80117c:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801182:	83 c4 04             	add    $0x4,%esp
  801185:	ff 75 e4             	pushl  -0x1c(%ebp)
  801188:	e8 b4 fd ff ff       	call   800f41 <fd2data>
  80118d:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80118f:	89 34 24             	mov    %esi,(%esp)
  801192:	e8 aa fd ff ff       	call   800f41 <fd2data>
  801197:	83 c4 10             	add    $0x10,%esp
  80119a:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80119c:	89 d8                	mov    %ebx,%eax
  80119e:	c1 e8 16             	shr    $0x16,%eax
  8011a1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011a8:	a8 01                	test   $0x1,%al
  8011aa:	74 11                	je     8011bd <dup+0x78>
  8011ac:	89 d8                	mov    %ebx,%eax
  8011ae:	c1 e8 0c             	shr    $0xc,%eax
  8011b1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011b8:	f6 c2 01             	test   $0x1,%dl
  8011bb:	75 39                	jne    8011f6 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011bd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8011c0:	89 d0                	mov    %edx,%eax
  8011c2:	c1 e8 0c             	shr    $0xc,%eax
  8011c5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011cc:	83 ec 0c             	sub    $0xc,%esp
  8011cf:	25 07 0e 00 00       	and    $0xe07,%eax
  8011d4:	50                   	push   %eax
  8011d5:	56                   	push   %esi
  8011d6:	6a 00                	push   $0x0
  8011d8:	52                   	push   %edx
  8011d9:	6a 00                	push   $0x0
  8011db:	e8 dd fa ff ff       	call   800cbd <sys_page_map>
  8011e0:	89 c3                	mov    %eax,%ebx
  8011e2:	83 c4 20             	add    $0x20,%esp
  8011e5:	85 c0                	test   %eax,%eax
  8011e7:	78 31                	js     80121a <dup+0xd5>
		goto err;

	return newfdnum;
  8011e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8011ec:	89 d8                	mov    %ebx,%eax
  8011ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f1:	5b                   	pop    %ebx
  8011f2:	5e                   	pop    %esi
  8011f3:	5f                   	pop    %edi
  8011f4:	5d                   	pop    %ebp
  8011f5:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011f6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011fd:	83 ec 0c             	sub    $0xc,%esp
  801200:	25 07 0e 00 00       	and    $0xe07,%eax
  801205:	50                   	push   %eax
  801206:	57                   	push   %edi
  801207:	6a 00                	push   $0x0
  801209:	53                   	push   %ebx
  80120a:	6a 00                	push   $0x0
  80120c:	e8 ac fa ff ff       	call   800cbd <sys_page_map>
  801211:	89 c3                	mov    %eax,%ebx
  801213:	83 c4 20             	add    $0x20,%esp
  801216:	85 c0                	test   %eax,%eax
  801218:	79 a3                	jns    8011bd <dup+0x78>
	sys_page_unmap(0, newfd);
  80121a:	83 ec 08             	sub    $0x8,%esp
  80121d:	56                   	push   %esi
  80121e:	6a 00                	push   $0x0
  801220:	e8 de fa ff ff       	call   800d03 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801225:	83 c4 08             	add    $0x8,%esp
  801228:	57                   	push   %edi
  801229:	6a 00                	push   $0x0
  80122b:	e8 d3 fa ff ff       	call   800d03 <sys_page_unmap>
	return r;
  801230:	83 c4 10             	add    $0x10,%esp
  801233:	eb b7                	jmp    8011ec <dup+0xa7>

00801235 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801235:	f3 0f 1e fb          	endbr32 
  801239:	55                   	push   %ebp
  80123a:	89 e5                	mov    %esp,%ebp
  80123c:	53                   	push   %ebx
  80123d:	83 ec 1c             	sub    $0x1c,%esp
  801240:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801243:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801246:	50                   	push   %eax
  801247:	53                   	push   %ebx
  801248:	e8 65 fd ff ff       	call   800fb2 <fd_lookup>
  80124d:	83 c4 10             	add    $0x10,%esp
  801250:	85 c0                	test   %eax,%eax
  801252:	78 3f                	js     801293 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801254:	83 ec 08             	sub    $0x8,%esp
  801257:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80125a:	50                   	push   %eax
  80125b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80125e:	ff 30                	pushl  (%eax)
  801260:	e8 a1 fd ff ff       	call   801006 <dev_lookup>
  801265:	83 c4 10             	add    $0x10,%esp
  801268:	85 c0                	test   %eax,%eax
  80126a:	78 27                	js     801293 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80126c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80126f:	8b 42 08             	mov    0x8(%edx),%eax
  801272:	83 e0 03             	and    $0x3,%eax
  801275:	83 f8 01             	cmp    $0x1,%eax
  801278:	74 1e                	je     801298 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80127a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80127d:	8b 40 08             	mov    0x8(%eax),%eax
  801280:	85 c0                	test   %eax,%eax
  801282:	74 35                	je     8012b9 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801284:	83 ec 04             	sub    $0x4,%esp
  801287:	ff 75 10             	pushl  0x10(%ebp)
  80128a:	ff 75 0c             	pushl  0xc(%ebp)
  80128d:	52                   	push   %edx
  80128e:	ff d0                	call   *%eax
  801290:	83 c4 10             	add    $0x10,%esp
}
  801293:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801296:	c9                   	leave  
  801297:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801298:	a1 04 40 80 00       	mov    0x804004,%eax
  80129d:	8b 40 48             	mov    0x48(%eax),%eax
  8012a0:	83 ec 04             	sub    $0x4,%esp
  8012a3:	53                   	push   %ebx
  8012a4:	50                   	push   %eax
  8012a5:	68 4d 24 80 00       	push   $0x80244d
  8012aa:	e8 7c ef ff ff       	call   80022b <cprintf>
		return -E_INVAL;
  8012af:	83 c4 10             	add    $0x10,%esp
  8012b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b7:	eb da                	jmp    801293 <read+0x5e>
		return -E_NOT_SUPP;
  8012b9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012be:	eb d3                	jmp    801293 <read+0x5e>

008012c0 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012c0:	f3 0f 1e fb          	endbr32 
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
  8012c7:	57                   	push   %edi
  8012c8:	56                   	push   %esi
  8012c9:	53                   	push   %ebx
  8012ca:	83 ec 0c             	sub    $0xc,%esp
  8012cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012d0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012d8:	eb 02                	jmp    8012dc <readn+0x1c>
  8012da:	01 c3                	add    %eax,%ebx
  8012dc:	39 f3                	cmp    %esi,%ebx
  8012de:	73 21                	jae    801301 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012e0:	83 ec 04             	sub    $0x4,%esp
  8012e3:	89 f0                	mov    %esi,%eax
  8012e5:	29 d8                	sub    %ebx,%eax
  8012e7:	50                   	push   %eax
  8012e8:	89 d8                	mov    %ebx,%eax
  8012ea:	03 45 0c             	add    0xc(%ebp),%eax
  8012ed:	50                   	push   %eax
  8012ee:	57                   	push   %edi
  8012ef:	e8 41 ff ff ff       	call   801235 <read>
		if (m < 0)
  8012f4:	83 c4 10             	add    $0x10,%esp
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	78 04                	js     8012ff <readn+0x3f>
			return m;
		if (m == 0)
  8012fb:	75 dd                	jne    8012da <readn+0x1a>
  8012fd:	eb 02                	jmp    801301 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012ff:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801301:	89 d8                	mov    %ebx,%eax
  801303:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801306:	5b                   	pop    %ebx
  801307:	5e                   	pop    %esi
  801308:	5f                   	pop    %edi
  801309:	5d                   	pop    %ebp
  80130a:	c3                   	ret    

0080130b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80130b:	f3 0f 1e fb          	endbr32 
  80130f:	55                   	push   %ebp
  801310:	89 e5                	mov    %esp,%ebp
  801312:	53                   	push   %ebx
  801313:	83 ec 1c             	sub    $0x1c,%esp
  801316:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801319:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80131c:	50                   	push   %eax
  80131d:	53                   	push   %ebx
  80131e:	e8 8f fc ff ff       	call   800fb2 <fd_lookup>
  801323:	83 c4 10             	add    $0x10,%esp
  801326:	85 c0                	test   %eax,%eax
  801328:	78 3a                	js     801364 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80132a:	83 ec 08             	sub    $0x8,%esp
  80132d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801330:	50                   	push   %eax
  801331:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801334:	ff 30                	pushl  (%eax)
  801336:	e8 cb fc ff ff       	call   801006 <dev_lookup>
  80133b:	83 c4 10             	add    $0x10,%esp
  80133e:	85 c0                	test   %eax,%eax
  801340:	78 22                	js     801364 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801342:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801345:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801349:	74 1e                	je     801369 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80134b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80134e:	8b 52 0c             	mov    0xc(%edx),%edx
  801351:	85 d2                	test   %edx,%edx
  801353:	74 35                	je     80138a <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801355:	83 ec 04             	sub    $0x4,%esp
  801358:	ff 75 10             	pushl  0x10(%ebp)
  80135b:	ff 75 0c             	pushl  0xc(%ebp)
  80135e:	50                   	push   %eax
  80135f:	ff d2                	call   *%edx
  801361:	83 c4 10             	add    $0x10,%esp
}
  801364:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801367:	c9                   	leave  
  801368:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801369:	a1 04 40 80 00       	mov    0x804004,%eax
  80136e:	8b 40 48             	mov    0x48(%eax),%eax
  801371:	83 ec 04             	sub    $0x4,%esp
  801374:	53                   	push   %ebx
  801375:	50                   	push   %eax
  801376:	68 69 24 80 00       	push   $0x802469
  80137b:	e8 ab ee ff ff       	call   80022b <cprintf>
		return -E_INVAL;
  801380:	83 c4 10             	add    $0x10,%esp
  801383:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801388:	eb da                	jmp    801364 <write+0x59>
		return -E_NOT_SUPP;
  80138a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80138f:	eb d3                	jmp    801364 <write+0x59>

00801391 <seek>:

int
seek(int fdnum, off_t offset)
{
  801391:	f3 0f 1e fb          	endbr32 
  801395:	55                   	push   %ebp
  801396:	89 e5                	mov    %esp,%ebp
  801398:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80139b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80139e:	50                   	push   %eax
  80139f:	ff 75 08             	pushl  0x8(%ebp)
  8013a2:	e8 0b fc ff ff       	call   800fb2 <fd_lookup>
  8013a7:	83 c4 10             	add    $0x10,%esp
  8013aa:	85 c0                	test   %eax,%eax
  8013ac:	78 0e                	js     8013bc <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8013ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013bc:	c9                   	leave  
  8013bd:	c3                   	ret    

008013be <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013be:	f3 0f 1e fb          	endbr32 
  8013c2:	55                   	push   %ebp
  8013c3:	89 e5                	mov    %esp,%ebp
  8013c5:	53                   	push   %ebx
  8013c6:	83 ec 1c             	sub    $0x1c,%esp
  8013c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013cf:	50                   	push   %eax
  8013d0:	53                   	push   %ebx
  8013d1:	e8 dc fb ff ff       	call   800fb2 <fd_lookup>
  8013d6:	83 c4 10             	add    $0x10,%esp
  8013d9:	85 c0                	test   %eax,%eax
  8013db:	78 37                	js     801414 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013dd:	83 ec 08             	sub    $0x8,%esp
  8013e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e3:	50                   	push   %eax
  8013e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e7:	ff 30                	pushl  (%eax)
  8013e9:	e8 18 fc ff ff       	call   801006 <dev_lookup>
  8013ee:	83 c4 10             	add    $0x10,%esp
  8013f1:	85 c0                	test   %eax,%eax
  8013f3:	78 1f                	js     801414 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013fc:	74 1b                	je     801419 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8013fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801401:	8b 52 18             	mov    0x18(%edx),%edx
  801404:	85 d2                	test   %edx,%edx
  801406:	74 32                	je     80143a <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801408:	83 ec 08             	sub    $0x8,%esp
  80140b:	ff 75 0c             	pushl  0xc(%ebp)
  80140e:	50                   	push   %eax
  80140f:	ff d2                	call   *%edx
  801411:	83 c4 10             	add    $0x10,%esp
}
  801414:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801417:	c9                   	leave  
  801418:	c3                   	ret    
			thisenv->env_id, fdnum);
  801419:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80141e:	8b 40 48             	mov    0x48(%eax),%eax
  801421:	83 ec 04             	sub    $0x4,%esp
  801424:	53                   	push   %ebx
  801425:	50                   	push   %eax
  801426:	68 2c 24 80 00       	push   $0x80242c
  80142b:	e8 fb ed ff ff       	call   80022b <cprintf>
		return -E_INVAL;
  801430:	83 c4 10             	add    $0x10,%esp
  801433:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801438:	eb da                	jmp    801414 <ftruncate+0x56>
		return -E_NOT_SUPP;
  80143a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80143f:	eb d3                	jmp    801414 <ftruncate+0x56>

00801441 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801441:	f3 0f 1e fb          	endbr32 
  801445:	55                   	push   %ebp
  801446:	89 e5                	mov    %esp,%ebp
  801448:	53                   	push   %ebx
  801449:	83 ec 1c             	sub    $0x1c,%esp
  80144c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80144f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801452:	50                   	push   %eax
  801453:	ff 75 08             	pushl  0x8(%ebp)
  801456:	e8 57 fb ff ff       	call   800fb2 <fd_lookup>
  80145b:	83 c4 10             	add    $0x10,%esp
  80145e:	85 c0                	test   %eax,%eax
  801460:	78 4b                	js     8014ad <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801462:	83 ec 08             	sub    $0x8,%esp
  801465:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801468:	50                   	push   %eax
  801469:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80146c:	ff 30                	pushl  (%eax)
  80146e:	e8 93 fb ff ff       	call   801006 <dev_lookup>
  801473:	83 c4 10             	add    $0x10,%esp
  801476:	85 c0                	test   %eax,%eax
  801478:	78 33                	js     8014ad <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80147a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80147d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801481:	74 2f                	je     8014b2 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801483:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801486:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80148d:	00 00 00 
	stat->st_isdir = 0;
  801490:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801497:	00 00 00 
	stat->st_dev = dev;
  80149a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8014a0:	83 ec 08             	sub    $0x8,%esp
  8014a3:	53                   	push   %ebx
  8014a4:	ff 75 f0             	pushl  -0x10(%ebp)
  8014a7:	ff 50 14             	call   *0x14(%eax)
  8014aa:	83 c4 10             	add    $0x10,%esp
}
  8014ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014b0:	c9                   	leave  
  8014b1:	c3                   	ret    
		return -E_NOT_SUPP;
  8014b2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014b7:	eb f4                	jmp    8014ad <fstat+0x6c>

008014b9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014b9:	f3 0f 1e fb          	endbr32 
  8014bd:	55                   	push   %ebp
  8014be:	89 e5                	mov    %esp,%ebp
  8014c0:	56                   	push   %esi
  8014c1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014c2:	83 ec 08             	sub    $0x8,%esp
  8014c5:	6a 00                	push   $0x0
  8014c7:	ff 75 08             	pushl  0x8(%ebp)
  8014ca:	e8 cf 01 00 00       	call   80169e <open>
  8014cf:	89 c3                	mov    %eax,%ebx
  8014d1:	83 c4 10             	add    $0x10,%esp
  8014d4:	85 c0                	test   %eax,%eax
  8014d6:	78 1b                	js     8014f3 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8014d8:	83 ec 08             	sub    $0x8,%esp
  8014db:	ff 75 0c             	pushl  0xc(%ebp)
  8014de:	50                   	push   %eax
  8014df:	e8 5d ff ff ff       	call   801441 <fstat>
  8014e4:	89 c6                	mov    %eax,%esi
	close(fd);
  8014e6:	89 1c 24             	mov    %ebx,(%esp)
  8014e9:	e8 fd fb ff ff       	call   8010eb <close>
	return r;
  8014ee:	83 c4 10             	add    $0x10,%esp
  8014f1:	89 f3                	mov    %esi,%ebx
}
  8014f3:	89 d8                	mov    %ebx,%eax
  8014f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014f8:	5b                   	pop    %ebx
  8014f9:	5e                   	pop    %esi
  8014fa:	5d                   	pop    %ebp
  8014fb:	c3                   	ret    

008014fc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014fc:	55                   	push   %ebp
  8014fd:	89 e5                	mov    %esp,%ebp
  8014ff:	56                   	push   %esi
  801500:	53                   	push   %ebx
  801501:	89 c6                	mov    %eax,%esi
  801503:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801505:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80150c:	74 27                	je     801535 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80150e:	6a 07                	push   $0x7
  801510:	68 00 50 80 00       	push   $0x805000
  801515:	56                   	push   %esi
  801516:	ff 35 00 40 80 00    	pushl  0x804000
  80151c:	e8 7c 07 00 00       	call   801c9d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801521:	83 c4 0c             	add    $0xc,%esp
  801524:	6a 00                	push   $0x0
  801526:	53                   	push   %ebx
  801527:	6a 00                	push   $0x0
  801529:	e8 18 07 00 00       	call   801c46 <ipc_recv>
}
  80152e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801531:	5b                   	pop    %ebx
  801532:	5e                   	pop    %esi
  801533:	5d                   	pop    %ebp
  801534:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801535:	83 ec 0c             	sub    $0xc,%esp
  801538:	6a 01                	push   $0x1
  80153a:	e8 c4 07 00 00       	call   801d03 <ipc_find_env>
  80153f:	a3 00 40 80 00       	mov    %eax,0x804000
  801544:	83 c4 10             	add    $0x10,%esp
  801547:	eb c5                	jmp    80150e <fsipc+0x12>

00801549 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801549:	f3 0f 1e fb          	endbr32 
  80154d:	55                   	push   %ebp
  80154e:	89 e5                	mov    %esp,%ebp
  801550:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801553:	8b 45 08             	mov    0x8(%ebp),%eax
  801556:	8b 40 0c             	mov    0xc(%eax),%eax
  801559:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80155e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801561:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801566:	ba 00 00 00 00       	mov    $0x0,%edx
  80156b:	b8 02 00 00 00       	mov    $0x2,%eax
  801570:	e8 87 ff ff ff       	call   8014fc <fsipc>
}
  801575:	c9                   	leave  
  801576:	c3                   	ret    

00801577 <devfile_flush>:
{
  801577:	f3 0f 1e fb          	endbr32 
  80157b:	55                   	push   %ebp
  80157c:	89 e5                	mov    %esp,%ebp
  80157e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801581:	8b 45 08             	mov    0x8(%ebp),%eax
  801584:	8b 40 0c             	mov    0xc(%eax),%eax
  801587:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80158c:	ba 00 00 00 00       	mov    $0x0,%edx
  801591:	b8 06 00 00 00       	mov    $0x6,%eax
  801596:	e8 61 ff ff ff       	call   8014fc <fsipc>
}
  80159b:	c9                   	leave  
  80159c:	c3                   	ret    

0080159d <devfile_stat>:
{
  80159d:	f3 0f 1e fb          	endbr32 
  8015a1:	55                   	push   %ebp
  8015a2:	89 e5                	mov    %esp,%ebp
  8015a4:	53                   	push   %ebx
  8015a5:	83 ec 04             	sub    $0x4,%esp
  8015a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8015ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8015b1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8015bb:	b8 05 00 00 00       	mov    $0x5,%eax
  8015c0:	e8 37 ff ff ff       	call   8014fc <fsipc>
  8015c5:	85 c0                	test   %eax,%eax
  8015c7:	78 2c                	js     8015f5 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015c9:	83 ec 08             	sub    $0x8,%esp
  8015cc:	68 00 50 80 00       	push   $0x805000
  8015d1:	53                   	push   %ebx
  8015d2:	e8 5d f2 ff ff       	call   800834 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015d7:	a1 80 50 80 00       	mov    0x805080,%eax
  8015dc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015e2:	a1 84 50 80 00       	mov    0x805084,%eax
  8015e7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015ed:	83 c4 10             	add    $0x10,%esp
  8015f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f8:	c9                   	leave  
  8015f9:	c3                   	ret    

008015fa <devfile_write>:
{
  8015fa:	f3 0f 1e fb          	endbr32 
  8015fe:	55                   	push   %ebp
  8015ff:	89 e5                	mov    %esp,%ebp
  801601:	83 ec 0c             	sub    $0xc,%esp
	panic("devfile_write not implemented");
  801604:	68 98 24 80 00       	push   $0x802498
  801609:	68 90 00 00 00       	push   $0x90
  80160e:	68 b6 24 80 00       	push   $0x8024b6
  801613:	e8 2c eb ff ff       	call   800144 <_panic>

00801618 <devfile_read>:
{
  801618:	f3 0f 1e fb          	endbr32 
  80161c:	55                   	push   %ebp
  80161d:	89 e5                	mov    %esp,%ebp
  80161f:	56                   	push   %esi
  801620:	53                   	push   %ebx
  801621:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801624:	8b 45 08             	mov    0x8(%ebp),%eax
  801627:	8b 40 0c             	mov    0xc(%eax),%eax
  80162a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80162f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801635:	ba 00 00 00 00       	mov    $0x0,%edx
  80163a:	b8 03 00 00 00       	mov    $0x3,%eax
  80163f:	e8 b8 fe ff ff       	call   8014fc <fsipc>
  801644:	89 c3                	mov    %eax,%ebx
  801646:	85 c0                	test   %eax,%eax
  801648:	78 1f                	js     801669 <devfile_read+0x51>
	assert(r <= n);
  80164a:	39 f0                	cmp    %esi,%eax
  80164c:	77 24                	ja     801672 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  80164e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801653:	7f 33                	jg     801688 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801655:	83 ec 04             	sub    $0x4,%esp
  801658:	50                   	push   %eax
  801659:	68 00 50 80 00       	push   $0x805000
  80165e:	ff 75 0c             	pushl  0xc(%ebp)
  801661:	e8 84 f3 ff ff       	call   8009ea <memmove>
	return r;
  801666:	83 c4 10             	add    $0x10,%esp
}
  801669:	89 d8                	mov    %ebx,%eax
  80166b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80166e:	5b                   	pop    %ebx
  80166f:	5e                   	pop    %esi
  801670:	5d                   	pop    %ebp
  801671:	c3                   	ret    
	assert(r <= n);
  801672:	68 c1 24 80 00       	push   $0x8024c1
  801677:	68 c8 24 80 00       	push   $0x8024c8
  80167c:	6a 7c                	push   $0x7c
  80167e:	68 b6 24 80 00       	push   $0x8024b6
  801683:	e8 bc ea ff ff       	call   800144 <_panic>
	assert(r <= PGSIZE);
  801688:	68 dd 24 80 00       	push   $0x8024dd
  80168d:	68 c8 24 80 00       	push   $0x8024c8
  801692:	6a 7d                	push   $0x7d
  801694:	68 b6 24 80 00       	push   $0x8024b6
  801699:	e8 a6 ea ff ff       	call   800144 <_panic>

0080169e <open>:
{
  80169e:	f3 0f 1e fb          	endbr32 
  8016a2:	55                   	push   %ebp
  8016a3:	89 e5                	mov    %esp,%ebp
  8016a5:	56                   	push   %esi
  8016a6:	53                   	push   %ebx
  8016a7:	83 ec 1c             	sub    $0x1c,%esp
  8016aa:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8016ad:	56                   	push   %esi
  8016ae:	e8 3e f1 ff ff       	call   8007f1 <strlen>
  8016b3:	83 c4 10             	add    $0x10,%esp
  8016b6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016bb:	7f 6c                	jg     801729 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  8016bd:	83 ec 0c             	sub    $0xc,%esp
  8016c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c3:	50                   	push   %eax
  8016c4:	e8 93 f8 ff ff       	call   800f5c <fd_alloc>
  8016c9:	89 c3                	mov    %eax,%ebx
  8016cb:	83 c4 10             	add    $0x10,%esp
  8016ce:	85 c0                	test   %eax,%eax
  8016d0:	78 3c                	js     80170e <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  8016d2:	83 ec 08             	sub    $0x8,%esp
  8016d5:	56                   	push   %esi
  8016d6:	68 00 50 80 00       	push   $0x805000
  8016db:	e8 54 f1 ff ff       	call   800834 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016e3:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016eb:	b8 01 00 00 00       	mov    $0x1,%eax
  8016f0:	e8 07 fe ff ff       	call   8014fc <fsipc>
  8016f5:	89 c3                	mov    %eax,%ebx
  8016f7:	83 c4 10             	add    $0x10,%esp
  8016fa:	85 c0                	test   %eax,%eax
  8016fc:	78 19                	js     801717 <open+0x79>
	return fd2num(fd);
  8016fe:	83 ec 0c             	sub    $0xc,%esp
  801701:	ff 75 f4             	pushl  -0xc(%ebp)
  801704:	e8 24 f8 ff ff       	call   800f2d <fd2num>
  801709:	89 c3                	mov    %eax,%ebx
  80170b:	83 c4 10             	add    $0x10,%esp
}
  80170e:	89 d8                	mov    %ebx,%eax
  801710:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801713:	5b                   	pop    %ebx
  801714:	5e                   	pop    %esi
  801715:	5d                   	pop    %ebp
  801716:	c3                   	ret    
		fd_close(fd, 0);
  801717:	83 ec 08             	sub    $0x8,%esp
  80171a:	6a 00                	push   $0x0
  80171c:	ff 75 f4             	pushl  -0xc(%ebp)
  80171f:	e8 3c f9 ff ff       	call   801060 <fd_close>
		return r;
  801724:	83 c4 10             	add    $0x10,%esp
  801727:	eb e5                	jmp    80170e <open+0x70>
		return -E_BAD_PATH;
  801729:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80172e:	eb de                	jmp    80170e <open+0x70>

00801730 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801730:	f3 0f 1e fb          	endbr32 
  801734:	55                   	push   %ebp
  801735:	89 e5                	mov    %esp,%ebp
  801737:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80173a:	ba 00 00 00 00       	mov    $0x0,%edx
  80173f:	b8 08 00 00 00       	mov    $0x8,%eax
  801744:	e8 b3 fd ff ff       	call   8014fc <fsipc>
}
  801749:	c9                   	leave  
  80174a:	c3                   	ret    

0080174b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80174b:	f3 0f 1e fb          	endbr32 
  80174f:	55                   	push   %ebp
  801750:	89 e5                	mov    %esp,%ebp
  801752:	56                   	push   %esi
  801753:	53                   	push   %ebx
  801754:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801757:	83 ec 0c             	sub    $0xc,%esp
  80175a:	ff 75 08             	pushl  0x8(%ebp)
  80175d:	e8 df f7 ff ff       	call   800f41 <fd2data>
  801762:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801764:	83 c4 08             	add    $0x8,%esp
  801767:	68 e9 24 80 00       	push   $0x8024e9
  80176c:	53                   	push   %ebx
  80176d:	e8 c2 f0 ff ff       	call   800834 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801772:	8b 46 04             	mov    0x4(%esi),%eax
  801775:	2b 06                	sub    (%esi),%eax
  801777:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80177d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801784:	00 00 00 
	stat->st_dev = &devpipe;
  801787:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80178e:	30 80 00 
	return 0;
}
  801791:	b8 00 00 00 00       	mov    $0x0,%eax
  801796:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801799:	5b                   	pop    %ebx
  80179a:	5e                   	pop    %esi
  80179b:	5d                   	pop    %ebp
  80179c:	c3                   	ret    

0080179d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80179d:	f3 0f 1e fb          	endbr32 
  8017a1:	55                   	push   %ebp
  8017a2:	89 e5                	mov    %esp,%ebp
  8017a4:	53                   	push   %ebx
  8017a5:	83 ec 0c             	sub    $0xc,%esp
  8017a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8017ab:	53                   	push   %ebx
  8017ac:	6a 00                	push   $0x0
  8017ae:	e8 50 f5 ff ff       	call   800d03 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8017b3:	89 1c 24             	mov    %ebx,(%esp)
  8017b6:	e8 86 f7 ff ff       	call   800f41 <fd2data>
  8017bb:	83 c4 08             	add    $0x8,%esp
  8017be:	50                   	push   %eax
  8017bf:	6a 00                	push   $0x0
  8017c1:	e8 3d f5 ff ff       	call   800d03 <sys_page_unmap>
}
  8017c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c9:	c9                   	leave  
  8017ca:	c3                   	ret    

008017cb <_pipeisclosed>:
{
  8017cb:	55                   	push   %ebp
  8017cc:	89 e5                	mov    %esp,%ebp
  8017ce:	57                   	push   %edi
  8017cf:	56                   	push   %esi
  8017d0:	53                   	push   %ebx
  8017d1:	83 ec 1c             	sub    $0x1c,%esp
  8017d4:	89 c7                	mov    %eax,%edi
  8017d6:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8017d8:	a1 04 40 80 00       	mov    0x804004,%eax
  8017dd:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8017e0:	83 ec 0c             	sub    $0xc,%esp
  8017e3:	57                   	push   %edi
  8017e4:	e8 57 05 00 00       	call   801d40 <pageref>
  8017e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8017ec:	89 34 24             	mov    %esi,(%esp)
  8017ef:	e8 4c 05 00 00       	call   801d40 <pageref>
		nn = thisenv->env_runs;
  8017f4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8017fa:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8017fd:	83 c4 10             	add    $0x10,%esp
  801800:	39 cb                	cmp    %ecx,%ebx
  801802:	74 1b                	je     80181f <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801804:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801807:	75 cf                	jne    8017d8 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801809:	8b 42 58             	mov    0x58(%edx),%eax
  80180c:	6a 01                	push   $0x1
  80180e:	50                   	push   %eax
  80180f:	53                   	push   %ebx
  801810:	68 f0 24 80 00       	push   $0x8024f0
  801815:	e8 11 ea ff ff       	call   80022b <cprintf>
  80181a:	83 c4 10             	add    $0x10,%esp
  80181d:	eb b9                	jmp    8017d8 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  80181f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801822:	0f 94 c0             	sete   %al
  801825:	0f b6 c0             	movzbl %al,%eax
}
  801828:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80182b:	5b                   	pop    %ebx
  80182c:	5e                   	pop    %esi
  80182d:	5f                   	pop    %edi
  80182e:	5d                   	pop    %ebp
  80182f:	c3                   	ret    

00801830 <devpipe_write>:
{
  801830:	f3 0f 1e fb          	endbr32 
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
  801837:	57                   	push   %edi
  801838:	56                   	push   %esi
  801839:	53                   	push   %ebx
  80183a:	83 ec 28             	sub    $0x28,%esp
  80183d:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801840:	56                   	push   %esi
  801841:	e8 fb f6 ff ff       	call   800f41 <fd2data>
  801846:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801848:	83 c4 10             	add    $0x10,%esp
  80184b:	bf 00 00 00 00       	mov    $0x0,%edi
  801850:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801853:	74 4f                	je     8018a4 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801855:	8b 43 04             	mov    0x4(%ebx),%eax
  801858:	8b 0b                	mov    (%ebx),%ecx
  80185a:	8d 51 20             	lea    0x20(%ecx),%edx
  80185d:	39 d0                	cmp    %edx,%eax
  80185f:	72 14                	jb     801875 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801861:	89 da                	mov    %ebx,%edx
  801863:	89 f0                	mov    %esi,%eax
  801865:	e8 61 ff ff ff       	call   8017cb <_pipeisclosed>
  80186a:	85 c0                	test   %eax,%eax
  80186c:	75 3b                	jne    8018a9 <devpipe_write+0x79>
			sys_yield();
  80186e:	e8 e0 f3 ff ff       	call   800c53 <sys_yield>
  801873:	eb e0                	jmp    801855 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801875:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801878:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80187c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80187f:	89 c2                	mov    %eax,%edx
  801881:	c1 fa 1f             	sar    $0x1f,%edx
  801884:	89 d1                	mov    %edx,%ecx
  801886:	c1 e9 1b             	shr    $0x1b,%ecx
  801889:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80188c:	83 e2 1f             	and    $0x1f,%edx
  80188f:	29 ca                	sub    %ecx,%edx
  801891:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801895:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801899:	83 c0 01             	add    $0x1,%eax
  80189c:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80189f:	83 c7 01             	add    $0x1,%edi
  8018a2:	eb ac                	jmp    801850 <devpipe_write+0x20>
	return i;
  8018a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8018a7:	eb 05                	jmp    8018ae <devpipe_write+0x7e>
				return 0;
  8018a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018b1:	5b                   	pop    %ebx
  8018b2:	5e                   	pop    %esi
  8018b3:	5f                   	pop    %edi
  8018b4:	5d                   	pop    %ebp
  8018b5:	c3                   	ret    

008018b6 <devpipe_read>:
{
  8018b6:	f3 0f 1e fb          	endbr32 
  8018ba:	55                   	push   %ebp
  8018bb:	89 e5                	mov    %esp,%ebp
  8018bd:	57                   	push   %edi
  8018be:	56                   	push   %esi
  8018bf:	53                   	push   %ebx
  8018c0:	83 ec 18             	sub    $0x18,%esp
  8018c3:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8018c6:	57                   	push   %edi
  8018c7:	e8 75 f6 ff ff       	call   800f41 <fd2data>
  8018cc:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8018ce:	83 c4 10             	add    $0x10,%esp
  8018d1:	be 00 00 00 00       	mov    $0x0,%esi
  8018d6:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018d9:	75 14                	jne    8018ef <devpipe_read+0x39>
	return i;
  8018db:	8b 45 10             	mov    0x10(%ebp),%eax
  8018de:	eb 02                	jmp    8018e2 <devpipe_read+0x2c>
				return i;
  8018e0:	89 f0                	mov    %esi,%eax
}
  8018e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018e5:	5b                   	pop    %ebx
  8018e6:	5e                   	pop    %esi
  8018e7:	5f                   	pop    %edi
  8018e8:	5d                   	pop    %ebp
  8018e9:	c3                   	ret    
			sys_yield();
  8018ea:	e8 64 f3 ff ff       	call   800c53 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8018ef:	8b 03                	mov    (%ebx),%eax
  8018f1:	3b 43 04             	cmp    0x4(%ebx),%eax
  8018f4:	75 18                	jne    80190e <devpipe_read+0x58>
			if (i > 0)
  8018f6:	85 f6                	test   %esi,%esi
  8018f8:	75 e6                	jne    8018e0 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  8018fa:	89 da                	mov    %ebx,%edx
  8018fc:	89 f8                	mov    %edi,%eax
  8018fe:	e8 c8 fe ff ff       	call   8017cb <_pipeisclosed>
  801903:	85 c0                	test   %eax,%eax
  801905:	74 e3                	je     8018ea <devpipe_read+0x34>
				return 0;
  801907:	b8 00 00 00 00       	mov    $0x0,%eax
  80190c:	eb d4                	jmp    8018e2 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80190e:	99                   	cltd   
  80190f:	c1 ea 1b             	shr    $0x1b,%edx
  801912:	01 d0                	add    %edx,%eax
  801914:	83 e0 1f             	and    $0x1f,%eax
  801917:	29 d0                	sub    %edx,%eax
  801919:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  80191e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801921:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801924:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801927:	83 c6 01             	add    $0x1,%esi
  80192a:	eb aa                	jmp    8018d6 <devpipe_read+0x20>

0080192c <pipe>:
{
  80192c:	f3 0f 1e fb          	endbr32 
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	56                   	push   %esi
  801934:	53                   	push   %ebx
  801935:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801938:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80193b:	50                   	push   %eax
  80193c:	e8 1b f6 ff ff       	call   800f5c <fd_alloc>
  801941:	89 c3                	mov    %eax,%ebx
  801943:	83 c4 10             	add    $0x10,%esp
  801946:	85 c0                	test   %eax,%eax
  801948:	0f 88 23 01 00 00    	js     801a71 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80194e:	83 ec 04             	sub    $0x4,%esp
  801951:	68 07 04 00 00       	push   $0x407
  801956:	ff 75 f4             	pushl  -0xc(%ebp)
  801959:	6a 00                	push   $0x0
  80195b:	e8 16 f3 ff ff       	call   800c76 <sys_page_alloc>
  801960:	89 c3                	mov    %eax,%ebx
  801962:	83 c4 10             	add    $0x10,%esp
  801965:	85 c0                	test   %eax,%eax
  801967:	0f 88 04 01 00 00    	js     801a71 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  80196d:	83 ec 0c             	sub    $0xc,%esp
  801970:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801973:	50                   	push   %eax
  801974:	e8 e3 f5 ff ff       	call   800f5c <fd_alloc>
  801979:	89 c3                	mov    %eax,%ebx
  80197b:	83 c4 10             	add    $0x10,%esp
  80197e:	85 c0                	test   %eax,%eax
  801980:	0f 88 db 00 00 00    	js     801a61 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801986:	83 ec 04             	sub    $0x4,%esp
  801989:	68 07 04 00 00       	push   $0x407
  80198e:	ff 75 f0             	pushl  -0x10(%ebp)
  801991:	6a 00                	push   $0x0
  801993:	e8 de f2 ff ff       	call   800c76 <sys_page_alloc>
  801998:	89 c3                	mov    %eax,%ebx
  80199a:	83 c4 10             	add    $0x10,%esp
  80199d:	85 c0                	test   %eax,%eax
  80199f:	0f 88 bc 00 00 00    	js     801a61 <pipe+0x135>
	va = fd2data(fd0);
  8019a5:	83 ec 0c             	sub    $0xc,%esp
  8019a8:	ff 75 f4             	pushl  -0xc(%ebp)
  8019ab:	e8 91 f5 ff ff       	call   800f41 <fd2data>
  8019b0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019b2:	83 c4 0c             	add    $0xc,%esp
  8019b5:	68 07 04 00 00       	push   $0x407
  8019ba:	50                   	push   %eax
  8019bb:	6a 00                	push   $0x0
  8019bd:	e8 b4 f2 ff ff       	call   800c76 <sys_page_alloc>
  8019c2:	89 c3                	mov    %eax,%ebx
  8019c4:	83 c4 10             	add    $0x10,%esp
  8019c7:	85 c0                	test   %eax,%eax
  8019c9:	0f 88 82 00 00 00    	js     801a51 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019cf:	83 ec 0c             	sub    $0xc,%esp
  8019d2:	ff 75 f0             	pushl  -0x10(%ebp)
  8019d5:	e8 67 f5 ff ff       	call   800f41 <fd2data>
  8019da:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8019e1:	50                   	push   %eax
  8019e2:	6a 00                	push   $0x0
  8019e4:	56                   	push   %esi
  8019e5:	6a 00                	push   $0x0
  8019e7:	e8 d1 f2 ff ff       	call   800cbd <sys_page_map>
  8019ec:	89 c3                	mov    %eax,%ebx
  8019ee:	83 c4 20             	add    $0x20,%esp
  8019f1:	85 c0                	test   %eax,%eax
  8019f3:	78 4e                	js     801a43 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  8019f5:	a1 20 30 80 00       	mov    0x803020,%eax
  8019fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019fd:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8019ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a02:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801a09:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a0c:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801a0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a11:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801a18:	83 ec 0c             	sub    $0xc,%esp
  801a1b:	ff 75 f4             	pushl  -0xc(%ebp)
  801a1e:	e8 0a f5 ff ff       	call   800f2d <fd2num>
  801a23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a26:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801a28:	83 c4 04             	add    $0x4,%esp
  801a2b:	ff 75 f0             	pushl  -0x10(%ebp)
  801a2e:	e8 fa f4 ff ff       	call   800f2d <fd2num>
  801a33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a36:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801a39:	83 c4 10             	add    $0x10,%esp
  801a3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a41:	eb 2e                	jmp    801a71 <pipe+0x145>
	sys_page_unmap(0, va);
  801a43:	83 ec 08             	sub    $0x8,%esp
  801a46:	56                   	push   %esi
  801a47:	6a 00                	push   $0x0
  801a49:	e8 b5 f2 ff ff       	call   800d03 <sys_page_unmap>
  801a4e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801a51:	83 ec 08             	sub    $0x8,%esp
  801a54:	ff 75 f0             	pushl  -0x10(%ebp)
  801a57:	6a 00                	push   $0x0
  801a59:	e8 a5 f2 ff ff       	call   800d03 <sys_page_unmap>
  801a5e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801a61:	83 ec 08             	sub    $0x8,%esp
  801a64:	ff 75 f4             	pushl  -0xc(%ebp)
  801a67:	6a 00                	push   $0x0
  801a69:	e8 95 f2 ff ff       	call   800d03 <sys_page_unmap>
  801a6e:	83 c4 10             	add    $0x10,%esp
}
  801a71:	89 d8                	mov    %ebx,%eax
  801a73:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a76:	5b                   	pop    %ebx
  801a77:	5e                   	pop    %esi
  801a78:	5d                   	pop    %ebp
  801a79:	c3                   	ret    

00801a7a <pipeisclosed>:
{
  801a7a:	f3 0f 1e fb          	endbr32 
  801a7e:	55                   	push   %ebp
  801a7f:	89 e5                	mov    %esp,%ebp
  801a81:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a84:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a87:	50                   	push   %eax
  801a88:	ff 75 08             	pushl  0x8(%ebp)
  801a8b:	e8 22 f5 ff ff       	call   800fb2 <fd_lookup>
  801a90:	83 c4 10             	add    $0x10,%esp
  801a93:	85 c0                	test   %eax,%eax
  801a95:	78 18                	js     801aaf <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801a97:	83 ec 0c             	sub    $0xc,%esp
  801a9a:	ff 75 f4             	pushl  -0xc(%ebp)
  801a9d:	e8 9f f4 ff ff       	call   800f41 <fd2data>
  801aa2:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa7:	e8 1f fd ff ff       	call   8017cb <_pipeisclosed>
  801aac:	83 c4 10             	add    $0x10,%esp
}
  801aaf:	c9                   	leave  
  801ab0:	c3                   	ret    

00801ab1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ab1:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801ab5:	b8 00 00 00 00       	mov    $0x0,%eax
  801aba:	c3                   	ret    

00801abb <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801abb:	f3 0f 1e fb          	endbr32 
  801abf:	55                   	push   %ebp
  801ac0:	89 e5                	mov    %esp,%ebp
  801ac2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ac5:	68 08 25 80 00       	push   $0x802508
  801aca:	ff 75 0c             	pushl  0xc(%ebp)
  801acd:	e8 62 ed ff ff       	call   800834 <strcpy>
	return 0;
}
  801ad2:	b8 00 00 00 00       	mov    $0x0,%eax
  801ad7:	c9                   	leave  
  801ad8:	c3                   	ret    

00801ad9 <devcons_write>:
{
  801ad9:	f3 0f 1e fb          	endbr32 
  801add:	55                   	push   %ebp
  801ade:	89 e5                	mov    %esp,%ebp
  801ae0:	57                   	push   %edi
  801ae1:	56                   	push   %esi
  801ae2:	53                   	push   %ebx
  801ae3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801ae9:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801aee:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801af4:	3b 75 10             	cmp    0x10(%ebp),%esi
  801af7:	73 31                	jae    801b2a <devcons_write+0x51>
		m = n - tot;
  801af9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801afc:	29 f3                	sub    %esi,%ebx
  801afe:	83 fb 7f             	cmp    $0x7f,%ebx
  801b01:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801b06:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801b09:	83 ec 04             	sub    $0x4,%esp
  801b0c:	53                   	push   %ebx
  801b0d:	89 f0                	mov    %esi,%eax
  801b0f:	03 45 0c             	add    0xc(%ebp),%eax
  801b12:	50                   	push   %eax
  801b13:	57                   	push   %edi
  801b14:	e8 d1 ee ff ff       	call   8009ea <memmove>
		sys_cputs(buf, m);
  801b19:	83 c4 08             	add    $0x8,%esp
  801b1c:	53                   	push   %ebx
  801b1d:	57                   	push   %edi
  801b1e:	e8 83 f0 ff ff       	call   800ba6 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801b23:	01 de                	add    %ebx,%esi
  801b25:	83 c4 10             	add    $0x10,%esp
  801b28:	eb ca                	jmp    801af4 <devcons_write+0x1b>
}
  801b2a:	89 f0                	mov    %esi,%eax
  801b2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b2f:	5b                   	pop    %ebx
  801b30:	5e                   	pop    %esi
  801b31:	5f                   	pop    %edi
  801b32:	5d                   	pop    %ebp
  801b33:	c3                   	ret    

00801b34 <devcons_read>:
{
  801b34:	f3 0f 1e fb          	endbr32 
  801b38:	55                   	push   %ebp
  801b39:	89 e5                	mov    %esp,%ebp
  801b3b:	83 ec 08             	sub    $0x8,%esp
  801b3e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801b43:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b47:	74 21                	je     801b6a <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801b49:	e8 7a f0 ff ff       	call   800bc8 <sys_cgetc>
  801b4e:	85 c0                	test   %eax,%eax
  801b50:	75 07                	jne    801b59 <devcons_read+0x25>
		sys_yield();
  801b52:	e8 fc f0 ff ff       	call   800c53 <sys_yield>
  801b57:	eb f0                	jmp    801b49 <devcons_read+0x15>
	if (c < 0)
  801b59:	78 0f                	js     801b6a <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801b5b:	83 f8 04             	cmp    $0x4,%eax
  801b5e:	74 0c                	je     801b6c <devcons_read+0x38>
	*(char*)vbuf = c;
  801b60:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b63:	88 02                	mov    %al,(%edx)
	return 1;
  801b65:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801b6a:	c9                   	leave  
  801b6b:	c3                   	ret    
		return 0;
  801b6c:	b8 00 00 00 00       	mov    $0x0,%eax
  801b71:	eb f7                	jmp    801b6a <devcons_read+0x36>

00801b73 <cputchar>:
{
  801b73:	f3 0f 1e fb          	endbr32 
  801b77:	55                   	push   %ebp
  801b78:	89 e5                	mov    %esp,%ebp
  801b7a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b80:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801b83:	6a 01                	push   $0x1
  801b85:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b88:	50                   	push   %eax
  801b89:	e8 18 f0 ff ff       	call   800ba6 <sys_cputs>
}
  801b8e:	83 c4 10             	add    $0x10,%esp
  801b91:	c9                   	leave  
  801b92:	c3                   	ret    

00801b93 <getchar>:
{
  801b93:	f3 0f 1e fb          	endbr32 
  801b97:	55                   	push   %ebp
  801b98:	89 e5                	mov    %esp,%ebp
  801b9a:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801b9d:	6a 01                	push   $0x1
  801b9f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ba2:	50                   	push   %eax
  801ba3:	6a 00                	push   $0x0
  801ba5:	e8 8b f6 ff ff       	call   801235 <read>
	if (r < 0)
  801baa:	83 c4 10             	add    $0x10,%esp
  801bad:	85 c0                	test   %eax,%eax
  801baf:	78 06                	js     801bb7 <getchar+0x24>
	if (r < 1)
  801bb1:	74 06                	je     801bb9 <getchar+0x26>
	return c;
  801bb3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801bb7:	c9                   	leave  
  801bb8:	c3                   	ret    
		return -E_EOF;
  801bb9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801bbe:	eb f7                	jmp    801bb7 <getchar+0x24>

00801bc0 <iscons>:
{
  801bc0:	f3 0f 1e fb          	endbr32 
  801bc4:	55                   	push   %ebp
  801bc5:	89 e5                	mov    %esp,%ebp
  801bc7:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bcd:	50                   	push   %eax
  801bce:	ff 75 08             	pushl  0x8(%ebp)
  801bd1:	e8 dc f3 ff ff       	call   800fb2 <fd_lookup>
  801bd6:	83 c4 10             	add    $0x10,%esp
  801bd9:	85 c0                	test   %eax,%eax
  801bdb:	78 11                	js     801bee <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801be6:	39 10                	cmp    %edx,(%eax)
  801be8:	0f 94 c0             	sete   %al
  801beb:	0f b6 c0             	movzbl %al,%eax
}
  801bee:	c9                   	leave  
  801bef:	c3                   	ret    

00801bf0 <opencons>:
{
  801bf0:	f3 0f 1e fb          	endbr32 
  801bf4:	55                   	push   %ebp
  801bf5:	89 e5                	mov    %esp,%ebp
  801bf7:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801bfa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bfd:	50                   	push   %eax
  801bfe:	e8 59 f3 ff ff       	call   800f5c <fd_alloc>
  801c03:	83 c4 10             	add    $0x10,%esp
  801c06:	85 c0                	test   %eax,%eax
  801c08:	78 3a                	js     801c44 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c0a:	83 ec 04             	sub    $0x4,%esp
  801c0d:	68 07 04 00 00       	push   $0x407
  801c12:	ff 75 f4             	pushl  -0xc(%ebp)
  801c15:	6a 00                	push   $0x0
  801c17:	e8 5a f0 ff ff       	call   800c76 <sys_page_alloc>
  801c1c:	83 c4 10             	add    $0x10,%esp
  801c1f:	85 c0                	test   %eax,%eax
  801c21:	78 21                	js     801c44 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801c23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c26:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c2c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c31:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c38:	83 ec 0c             	sub    $0xc,%esp
  801c3b:	50                   	push   %eax
  801c3c:	e8 ec f2 ff ff       	call   800f2d <fd2num>
  801c41:	83 c4 10             	add    $0x10,%esp
}
  801c44:	c9                   	leave  
  801c45:	c3                   	ret    

00801c46 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c46:	f3 0f 1e fb          	endbr32 
  801c4a:	55                   	push   %ebp
  801c4b:	89 e5                	mov    %esp,%ebp
  801c4d:	56                   	push   %esi
  801c4e:	53                   	push   %ebx
  801c4f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801c52:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c55:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801c58:	85 c0                	test   %eax,%eax
  801c5a:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801c5f:	0f 44 c2             	cmove  %edx,%eax
  801c62:	83 ec 0c             	sub    $0xc,%esp
  801c65:	50                   	push   %eax
  801c66:	e8 d7 f1 ff ff       	call   800e42 <sys_ipc_recv>
  801c6b:	83 c4 10             	add    $0x10,%esp
  801c6e:	85 c0                	test   %eax,%eax
  801c70:	78 24                	js     801c96 <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801c72:	85 f6                	test   %esi,%esi
  801c74:	74 0a                	je     801c80 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801c76:	a1 04 40 80 00       	mov    0x804004,%eax
  801c7b:	8b 40 78             	mov    0x78(%eax),%eax
  801c7e:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801c80:	85 db                	test   %ebx,%ebx
  801c82:	74 0a                	je     801c8e <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801c84:	a1 04 40 80 00       	mov    0x804004,%eax
  801c89:	8b 40 74             	mov    0x74(%eax),%eax
  801c8c:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801c8e:	a1 04 40 80 00       	mov    0x804004,%eax
  801c93:	8b 40 70             	mov    0x70(%eax),%eax
}
  801c96:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c99:	5b                   	pop    %ebx
  801c9a:	5e                   	pop    %esi
  801c9b:	5d                   	pop    %ebp
  801c9c:	c3                   	ret    

00801c9d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c9d:	f3 0f 1e fb          	endbr32 
  801ca1:	55                   	push   %ebp
  801ca2:	89 e5                	mov    %esp,%ebp
  801ca4:	57                   	push   %edi
  801ca5:	56                   	push   %esi
  801ca6:	53                   	push   %ebx
  801ca7:	83 ec 1c             	sub    $0x1c,%esp
  801caa:	8b 45 10             	mov    0x10(%ebp),%eax
  801cad:	85 c0                	test   %eax,%eax
  801caf:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801cb4:	0f 45 d0             	cmovne %eax,%edx
  801cb7:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801cb9:	be 01 00 00 00       	mov    $0x1,%esi
  801cbe:	eb 1f                	jmp    801cdf <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801cc0:	e8 8e ef ff ff       	call   800c53 <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801cc5:	83 c3 01             	add    $0x1,%ebx
  801cc8:	39 de                	cmp    %ebx,%esi
  801cca:	7f f4                	jg     801cc0 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801ccc:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801cce:	83 fe 11             	cmp    $0x11,%esi
  801cd1:	b8 01 00 00 00       	mov    $0x1,%eax
  801cd6:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801cd9:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801cdd:	75 1c                	jne    801cfb <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801cdf:	ff 75 14             	pushl  0x14(%ebp)
  801ce2:	57                   	push   %edi
  801ce3:	ff 75 0c             	pushl  0xc(%ebp)
  801ce6:	ff 75 08             	pushl  0x8(%ebp)
  801ce9:	e8 2d f1 ff ff       	call   800e1b <sys_ipc_try_send>
  801cee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801cf1:	83 c4 10             	add    $0x10,%esp
  801cf4:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cf9:	eb cd                	jmp    801cc8 <ipc_send+0x2b>
}
  801cfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cfe:	5b                   	pop    %ebx
  801cff:	5e                   	pop    %esi
  801d00:	5f                   	pop    %edi
  801d01:	5d                   	pop    %ebp
  801d02:	c3                   	ret    

00801d03 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d03:	f3 0f 1e fb          	endbr32 
  801d07:	55                   	push   %ebp
  801d08:	89 e5                	mov    %esp,%ebp
  801d0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801d0d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801d12:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801d15:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d1b:	8b 52 50             	mov    0x50(%edx),%edx
  801d1e:	39 ca                	cmp    %ecx,%edx
  801d20:	74 11                	je     801d33 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801d22:	83 c0 01             	add    $0x1,%eax
  801d25:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d2a:	75 e6                	jne    801d12 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801d2c:	b8 00 00 00 00       	mov    $0x0,%eax
  801d31:	eb 0b                	jmp    801d3e <ipc_find_env+0x3b>
			return envs[i].env_id;
  801d33:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801d36:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801d3b:	8b 40 48             	mov    0x48(%eax),%eax
}
  801d3e:	5d                   	pop    %ebp
  801d3f:	c3                   	ret    

00801d40 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d40:	f3 0f 1e fb          	endbr32 
  801d44:	55                   	push   %ebp
  801d45:	89 e5                	mov    %esp,%ebp
  801d47:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d4a:	89 c2                	mov    %eax,%edx
  801d4c:	c1 ea 16             	shr    $0x16,%edx
  801d4f:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801d56:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801d5b:	f6 c1 01             	test   $0x1,%cl
  801d5e:	74 1c                	je     801d7c <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801d60:	c1 e8 0c             	shr    $0xc,%eax
  801d63:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d6a:	a8 01                	test   $0x1,%al
  801d6c:	74 0e                	je     801d7c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d6e:	c1 e8 0c             	shr    $0xc,%eax
  801d71:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801d78:	ef 
  801d79:	0f b7 d2             	movzwl %dx,%edx
}
  801d7c:	89 d0                	mov    %edx,%eax
  801d7e:	5d                   	pop    %ebp
  801d7f:	c3                   	ret    

00801d80 <__udivdi3>:
  801d80:	f3 0f 1e fb          	endbr32 
  801d84:	55                   	push   %ebp
  801d85:	57                   	push   %edi
  801d86:	56                   	push   %esi
  801d87:	53                   	push   %ebx
  801d88:	83 ec 1c             	sub    $0x1c,%esp
  801d8b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d8f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801d93:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d97:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801d9b:	85 d2                	test   %edx,%edx
  801d9d:	75 19                	jne    801db8 <__udivdi3+0x38>
  801d9f:	39 f3                	cmp    %esi,%ebx
  801da1:	76 4d                	jbe    801df0 <__udivdi3+0x70>
  801da3:	31 ff                	xor    %edi,%edi
  801da5:	89 e8                	mov    %ebp,%eax
  801da7:	89 f2                	mov    %esi,%edx
  801da9:	f7 f3                	div    %ebx
  801dab:	89 fa                	mov    %edi,%edx
  801dad:	83 c4 1c             	add    $0x1c,%esp
  801db0:	5b                   	pop    %ebx
  801db1:	5e                   	pop    %esi
  801db2:	5f                   	pop    %edi
  801db3:	5d                   	pop    %ebp
  801db4:	c3                   	ret    
  801db5:	8d 76 00             	lea    0x0(%esi),%esi
  801db8:	39 f2                	cmp    %esi,%edx
  801dba:	76 14                	jbe    801dd0 <__udivdi3+0x50>
  801dbc:	31 ff                	xor    %edi,%edi
  801dbe:	31 c0                	xor    %eax,%eax
  801dc0:	89 fa                	mov    %edi,%edx
  801dc2:	83 c4 1c             	add    $0x1c,%esp
  801dc5:	5b                   	pop    %ebx
  801dc6:	5e                   	pop    %esi
  801dc7:	5f                   	pop    %edi
  801dc8:	5d                   	pop    %ebp
  801dc9:	c3                   	ret    
  801dca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801dd0:	0f bd fa             	bsr    %edx,%edi
  801dd3:	83 f7 1f             	xor    $0x1f,%edi
  801dd6:	75 48                	jne    801e20 <__udivdi3+0xa0>
  801dd8:	39 f2                	cmp    %esi,%edx
  801dda:	72 06                	jb     801de2 <__udivdi3+0x62>
  801ddc:	31 c0                	xor    %eax,%eax
  801dde:	39 eb                	cmp    %ebp,%ebx
  801de0:	77 de                	ja     801dc0 <__udivdi3+0x40>
  801de2:	b8 01 00 00 00       	mov    $0x1,%eax
  801de7:	eb d7                	jmp    801dc0 <__udivdi3+0x40>
  801de9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801df0:	89 d9                	mov    %ebx,%ecx
  801df2:	85 db                	test   %ebx,%ebx
  801df4:	75 0b                	jne    801e01 <__udivdi3+0x81>
  801df6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dfb:	31 d2                	xor    %edx,%edx
  801dfd:	f7 f3                	div    %ebx
  801dff:	89 c1                	mov    %eax,%ecx
  801e01:	31 d2                	xor    %edx,%edx
  801e03:	89 f0                	mov    %esi,%eax
  801e05:	f7 f1                	div    %ecx
  801e07:	89 c6                	mov    %eax,%esi
  801e09:	89 e8                	mov    %ebp,%eax
  801e0b:	89 f7                	mov    %esi,%edi
  801e0d:	f7 f1                	div    %ecx
  801e0f:	89 fa                	mov    %edi,%edx
  801e11:	83 c4 1c             	add    $0x1c,%esp
  801e14:	5b                   	pop    %ebx
  801e15:	5e                   	pop    %esi
  801e16:	5f                   	pop    %edi
  801e17:	5d                   	pop    %ebp
  801e18:	c3                   	ret    
  801e19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e20:	89 f9                	mov    %edi,%ecx
  801e22:	b8 20 00 00 00       	mov    $0x20,%eax
  801e27:	29 f8                	sub    %edi,%eax
  801e29:	d3 e2                	shl    %cl,%edx
  801e2b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e2f:	89 c1                	mov    %eax,%ecx
  801e31:	89 da                	mov    %ebx,%edx
  801e33:	d3 ea                	shr    %cl,%edx
  801e35:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801e39:	09 d1                	or     %edx,%ecx
  801e3b:	89 f2                	mov    %esi,%edx
  801e3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e41:	89 f9                	mov    %edi,%ecx
  801e43:	d3 e3                	shl    %cl,%ebx
  801e45:	89 c1                	mov    %eax,%ecx
  801e47:	d3 ea                	shr    %cl,%edx
  801e49:	89 f9                	mov    %edi,%ecx
  801e4b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801e4f:	89 eb                	mov    %ebp,%ebx
  801e51:	d3 e6                	shl    %cl,%esi
  801e53:	89 c1                	mov    %eax,%ecx
  801e55:	d3 eb                	shr    %cl,%ebx
  801e57:	09 de                	or     %ebx,%esi
  801e59:	89 f0                	mov    %esi,%eax
  801e5b:	f7 74 24 08          	divl   0x8(%esp)
  801e5f:	89 d6                	mov    %edx,%esi
  801e61:	89 c3                	mov    %eax,%ebx
  801e63:	f7 64 24 0c          	mull   0xc(%esp)
  801e67:	39 d6                	cmp    %edx,%esi
  801e69:	72 15                	jb     801e80 <__udivdi3+0x100>
  801e6b:	89 f9                	mov    %edi,%ecx
  801e6d:	d3 e5                	shl    %cl,%ebp
  801e6f:	39 c5                	cmp    %eax,%ebp
  801e71:	73 04                	jae    801e77 <__udivdi3+0xf7>
  801e73:	39 d6                	cmp    %edx,%esi
  801e75:	74 09                	je     801e80 <__udivdi3+0x100>
  801e77:	89 d8                	mov    %ebx,%eax
  801e79:	31 ff                	xor    %edi,%edi
  801e7b:	e9 40 ff ff ff       	jmp    801dc0 <__udivdi3+0x40>
  801e80:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801e83:	31 ff                	xor    %edi,%edi
  801e85:	e9 36 ff ff ff       	jmp    801dc0 <__udivdi3+0x40>
  801e8a:	66 90                	xchg   %ax,%ax
  801e8c:	66 90                	xchg   %ax,%ax
  801e8e:	66 90                	xchg   %ax,%ax

00801e90 <__umoddi3>:
  801e90:	f3 0f 1e fb          	endbr32 
  801e94:	55                   	push   %ebp
  801e95:	57                   	push   %edi
  801e96:	56                   	push   %esi
  801e97:	53                   	push   %ebx
  801e98:	83 ec 1c             	sub    $0x1c,%esp
  801e9b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801e9f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801ea3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801ea7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801eab:	85 c0                	test   %eax,%eax
  801ead:	75 19                	jne    801ec8 <__umoddi3+0x38>
  801eaf:	39 df                	cmp    %ebx,%edi
  801eb1:	76 5d                	jbe    801f10 <__umoddi3+0x80>
  801eb3:	89 f0                	mov    %esi,%eax
  801eb5:	89 da                	mov    %ebx,%edx
  801eb7:	f7 f7                	div    %edi
  801eb9:	89 d0                	mov    %edx,%eax
  801ebb:	31 d2                	xor    %edx,%edx
  801ebd:	83 c4 1c             	add    $0x1c,%esp
  801ec0:	5b                   	pop    %ebx
  801ec1:	5e                   	pop    %esi
  801ec2:	5f                   	pop    %edi
  801ec3:	5d                   	pop    %ebp
  801ec4:	c3                   	ret    
  801ec5:	8d 76 00             	lea    0x0(%esi),%esi
  801ec8:	89 f2                	mov    %esi,%edx
  801eca:	39 d8                	cmp    %ebx,%eax
  801ecc:	76 12                	jbe    801ee0 <__umoddi3+0x50>
  801ece:	89 f0                	mov    %esi,%eax
  801ed0:	89 da                	mov    %ebx,%edx
  801ed2:	83 c4 1c             	add    $0x1c,%esp
  801ed5:	5b                   	pop    %ebx
  801ed6:	5e                   	pop    %esi
  801ed7:	5f                   	pop    %edi
  801ed8:	5d                   	pop    %ebp
  801ed9:	c3                   	ret    
  801eda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ee0:	0f bd e8             	bsr    %eax,%ebp
  801ee3:	83 f5 1f             	xor    $0x1f,%ebp
  801ee6:	75 50                	jne    801f38 <__umoddi3+0xa8>
  801ee8:	39 d8                	cmp    %ebx,%eax
  801eea:	0f 82 e0 00 00 00    	jb     801fd0 <__umoddi3+0x140>
  801ef0:	89 d9                	mov    %ebx,%ecx
  801ef2:	39 f7                	cmp    %esi,%edi
  801ef4:	0f 86 d6 00 00 00    	jbe    801fd0 <__umoddi3+0x140>
  801efa:	89 d0                	mov    %edx,%eax
  801efc:	89 ca                	mov    %ecx,%edx
  801efe:	83 c4 1c             	add    $0x1c,%esp
  801f01:	5b                   	pop    %ebx
  801f02:	5e                   	pop    %esi
  801f03:	5f                   	pop    %edi
  801f04:	5d                   	pop    %ebp
  801f05:	c3                   	ret    
  801f06:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f0d:	8d 76 00             	lea    0x0(%esi),%esi
  801f10:	89 fd                	mov    %edi,%ebp
  801f12:	85 ff                	test   %edi,%edi
  801f14:	75 0b                	jne    801f21 <__umoddi3+0x91>
  801f16:	b8 01 00 00 00       	mov    $0x1,%eax
  801f1b:	31 d2                	xor    %edx,%edx
  801f1d:	f7 f7                	div    %edi
  801f1f:	89 c5                	mov    %eax,%ebp
  801f21:	89 d8                	mov    %ebx,%eax
  801f23:	31 d2                	xor    %edx,%edx
  801f25:	f7 f5                	div    %ebp
  801f27:	89 f0                	mov    %esi,%eax
  801f29:	f7 f5                	div    %ebp
  801f2b:	89 d0                	mov    %edx,%eax
  801f2d:	31 d2                	xor    %edx,%edx
  801f2f:	eb 8c                	jmp    801ebd <__umoddi3+0x2d>
  801f31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f38:	89 e9                	mov    %ebp,%ecx
  801f3a:	ba 20 00 00 00       	mov    $0x20,%edx
  801f3f:	29 ea                	sub    %ebp,%edx
  801f41:	d3 e0                	shl    %cl,%eax
  801f43:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f47:	89 d1                	mov    %edx,%ecx
  801f49:	89 f8                	mov    %edi,%eax
  801f4b:	d3 e8                	shr    %cl,%eax
  801f4d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801f51:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f55:	8b 54 24 04          	mov    0x4(%esp),%edx
  801f59:	09 c1                	or     %eax,%ecx
  801f5b:	89 d8                	mov    %ebx,%eax
  801f5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f61:	89 e9                	mov    %ebp,%ecx
  801f63:	d3 e7                	shl    %cl,%edi
  801f65:	89 d1                	mov    %edx,%ecx
  801f67:	d3 e8                	shr    %cl,%eax
  801f69:	89 e9                	mov    %ebp,%ecx
  801f6b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f6f:	d3 e3                	shl    %cl,%ebx
  801f71:	89 c7                	mov    %eax,%edi
  801f73:	89 d1                	mov    %edx,%ecx
  801f75:	89 f0                	mov    %esi,%eax
  801f77:	d3 e8                	shr    %cl,%eax
  801f79:	89 e9                	mov    %ebp,%ecx
  801f7b:	89 fa                	mov    %edi,%edx
  801f7d:	d3 e6                	shl    %cl,%esi
  801f7f:	09 d8                	or     %ebx,%eax
  801f81:	f7 74 24 08          	divl   0x8(%esp)
  801f85:	89 d1                	mov    %edx,%ecx
  801f87:	89 f3                	mov    %esi,%ebx
  801f89:	f7 64 24 0c          	mull   0xc(%esp)
  801f8d:	89 c6                	mov    %eax,%esi
  801f8f:	89 d7                	mov    %edx,%edi
  801f91:	39 d1                	cmp    %edx,%ecx
  801f93:	72 06                	jb     801f9b <__umoddi3+0x10b>
  801f95:	75 10                	jne    801fa7 <__umoddi3+0x117>
  801f97:	39 c3                	cmp    %eax,%ebx
  801f99:	73 0c                	jae    801fa7 <__umoddi3+0x117>
  801f9b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801f9f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801fa3:	89 d7                	mov    %edx,%edi
  801fa5:	89 c6                	mov    %eax,%esi
  801fa7:	89 ca                	mov    %ecx,%edx
  801fa9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801fae:	29 f3                	sub    %esi,%ebx
  801fb0:	19 fa                	sbb    %edi,%edx
  801fb2:	89 d0                	mov    %edx,%eax
  801fb4:	d3 e0                	shl    %cl,%eax
  801fb6:	89 e9                	mov    %ebp,%ecx
  801fb8:	d3 eb                	shr    %cl,%ebx
  801fba:	d3 ea                	shr    %cl,%edx
  801fbc:	09 d8                	or     %ebx,%eax
  801fbe:	83 c4 1c             	add    $0x1c,%esp
  801fc1:	5b                   	pop    %ebx
  801fc2:	5e                   	pop    %esi
  801fc3:	5f                   	pop    %edi
  801fc4:	5d                   	pop    %ebp
  801fc5:	c3                   	ret    
  801fc6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fcd:	8d 76 00             	lea    0x0(%esi),%esi
  801fd0:	29 fe                	sub    %edi,%esi
  801fd2:	19 c3                	sbb    %eax,%ebx
  801fd4:	89 f2                	mov    %esi,%edx
  801fd6:	89 d9                	mov    %ebx,%ecx
  801fd8:	e9 1d ff ff ff       	jmp    801efa <__umoddi3+0x6a>
