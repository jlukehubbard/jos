
obj/user/faultdie:     file format elf32-i386


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
  80002c:	e8 57 00 00 00       	call   800088 <libmain>
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
  80003a:	83 ec 0c             	sub    $0xc,%esp
  80003d:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  800040:	8b 42 04             	mov    0x4(%edx),%eax
  800043:	83 e0 07             	and    $0x7,%eax
  800046:	50                   	push   %eax
  800047:	ff 32                	pushl  (%edx)
  800049:	68 40 11 80 00       	push   $0x801140
  80004e:	e8 3c 01 00 00       	call   80018f <cprintf>
	sys_env_destroy(sys_getenvid());
  800053:	e8 3c 0b 00 00       	call   800b94 <sys_getenvid>
  800058:	89 04 24             	mov    %eax,(%esp)
  80005b:	e8 ef 0a 00 00       	call   800b4f <sys_env_destroy>
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <umain>:

void
umain(int argc, char **argv)
{
  800065:	f3 0f 1e fb          	endbr32 
  800069:	55                   	push   %ebp
  80006a:	89 e5                	mov    %esp,%ebp
  80006c:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  80006f:	68 33 00 80 00       	push   $0x800033
  800074:	e8 72 0d 00 00       	call   800deb <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800079:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800080:	00 00 00 
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	c9                   	leave  
  800087:	c3                   	ret    

00800088 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800088:	f3 0f 1e fb          	endbr32 
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	56                   	push   %esi
  800090:	53                   	push   %ebx
  800091:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800094:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800097:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80009e:	00 00 00 
    envid_t envid = sys_getenvid();
  8000a1:	e8 ee 0a 00 00       	call   800b94 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  8000a6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ab:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000ae:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b3:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b8:	85 db                	test   %ebx,%ebx
  8000ba:	7e 07                	jle    8000c3 <libmain+0x3b>
		binaryname = argv[0];
  8000bc:	8b 06                	mov    (%esi),%eax
  8000be:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000c3:	83 ec 08             	sub    $0x8,%esp
  8000c6:	56                   	push   %esi
  8000c7:	53                   	push   %ebx
  8000c8:	e8 98 ff ff ff       	call   800065 <umain>

	// exit gracefully
	exit();
  8000cd:	e8 0a 00 00 00       	call   8000dc <exit>
}
  8000d2:	83 c4 10             	add    $0x10,%esp
  8000d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000d8:	5b                   	pop    %ebx
  8000d9:	5e                   	pop    %esi
  8000da:	5d                   	pop    %ebp
  8000db:	c3                   	ret    

008000dc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000dc:	f3 0f 1e fb          	endbr32 
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  8000e6:	6a 00                	push   $0x0
  8000e8:	e8 62 0a 00 00       	call   800b4f <sys_env_destroy>
}
  8000ed:	83 c4 10             	add    $0x10,%esp
  8000f0:	c9                   	leave  
  8000f1:	c3                   	ret    

008000f2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f2:	f3 0f 1e fb          	endbr32 
  8000f6:	55                   	push   %ebp
  8000f7:	89 e5                	mov    %esp,%ebp
  8000f9:	53                   	push   %ebx
  8000fa:	83 ec 04             	sub    $0x4,%esp
  8000fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800100:	8b 13                	mov    (%ebx),%edx
  800102:	8d 42 01             	lea    0x1(%edx),%eax
  800105:	89 03                	mov    %eax,(%ebx)
  800107:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80010e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800113:	74 09                	je     80011e <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800115:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800119:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80011c:	c9                   	leave  
  80011d:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80011e:	83 ec 08             	sub    $0x8,%esp
  800121:	68 ff 00 00 00       	push   $0xff
  800126:	8d 43 08             	lea    0x8(%ebx),%eax
  800129:	50                   	push   %eax
  80012a:	e8 db 09 00 00       	call   800b0a <sys_cputs>
		b->idx = 0;
  80012f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800135:	83 c4 10             	add    $0x10,%esp
  800138:	eb db                	jmp    800115 <putch+0x23>

0080013a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013a:	f3 0f 1e fb          	endbr32 
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800147:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014e:	00 00 00 
	b.cnt = 0;
  800151:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800158:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80015b:	ff 75 0c             	pushl  0xc(%ebp)
  80015e:	ff 75 08             	pushl  0x8(%ebp)
  800161:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800167:	50                   	push   %eax
  800168:	68 f2 00 80 00       	push   $0x8000f2
  80016d:	e8 20 01 00 00       	call   800292 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800172:	83 c4 08             	add    $0x8,%esp
  800175:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80017b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800181:	50                   	push   %eax
  800182:	e8 83 09 00 00       	call   800b0a <sys_cputs>

	return b.cnt;
}
  800187:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018d:	c9                   	leave  
  80018e:	c3                   	ret    

0080018f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018f:	f3 0f 1e fb          	endbr32 
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800199:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019c:	50                   	push   %eax
  80019d:	ff 75 08             	pushl  0x8(%ebp)
  8001a0:	e8 95 ff ff ff       	call   80013a <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    

008001a7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	57                   	push   %edi
  8001ab:	56                   	push   %esi
  8001ac:	53                   	push   %ebx
  8001ad:	83 ec 1c             	sub    $0x1c,%esp
  8001b0:	89 c7                	mov    %eax,%edi
  8001b2:	89 d6                	mov    %edx,%esi
  8001b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ba:	89 d1                	mov    %edx,%ecx
  8001bc:	89 c2                	mov    %eax,%edx
  8001be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001c1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001cd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001d4:	39 c2                	cmp    %eax,%edx
  8001d6:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001d9:	72 3e                	jb     800219 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001db:	83 ec 0c             	sub    $0xc,%esp
  8001de:	ff 75 18             	pushl  0x18(%ebp)
  8001e1:	83 eb 01             	sub    $0x1,%ebx
  8001e4:	53                   	push   %ebx
  8001e5:	50                   	push   %eax
  8001e6:	83 ec 08             	sub    $0x8,%esp
  8001e9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ef:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f2:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f5:	e8 e6 0c 00 00       	call   800ee0 <__udivdi3>
  8001fa:	83 c4 18             	add    $0x18,%esp
  8001fd:	52                   	push   %edx
  8001fe:	50                   	push   %eax
  8001ff:	89 f2                	mov    %esi,%edx
  800201:	89 f8                	mov    %edi,%eax
  800203:	e8 9f ff ff ff       	call   8001a7 <printnum>
  800208:	83 c4 20             	add    $0x20,%esp
  80020b:	eb 13                	jmp    800220 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020d:	83 ec 08             	sub    $0x8,%esp
  800210:	56                   	push   %esi
  800211:	ff 75 18             	pushl  0x18(%ebp)
  800214:	ff d7                	call   *%edi
  800216:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800219:	83 eb 01             	sub    $0x1,%ebx
  80021c:	85 db                	test   %ebx,%ebx
  80021e:	7f ed                	jg     80020d <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800220:	83 ec 08             	sub    $0x8,%esp
  800223:	56                   	push   %esi
  800224:	83 ec 04             	sub    $0x4,%esp
  800227:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022a:	ff 75 e0             	pushl  -0x20(%ebp)
  80022d:	ff 75 dc             	pushl  -0x24(%ebp)
  800230:	ff 75 d8             	pushl  -0x28(%ebp)
  800233:	e8 b8 0d 00 00       	call   800ff0 <__umoddi3>
  800238:	83 c4 14             	add    $0x14,%esp
  80023b:	0f be 80 66 11 80 00 	movsbl 0x801166(%eax),%eax
  800242:	50                   	push   %eax
  800243:	ff d7                	call   *%edi
}
  800245:	83 c4 10             	add    $0x10,%esp
  800248:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024b:	5b                   	pop    %ebx
  80024c:	5e                   	pop    %esi
  80024d:	5f                   	pop    %edi
  80024e:	5d                   	pop    %ebp
  80024f:	c3                   	ret    

00800250 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800250:	f3 0f 1e fb          	endbr32 
  800254:	55                   	push   %ebp
  800255:	89 e5                	mov    %esp,%ebp
  800257:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80025a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80025e:	8b 10                	mov    (%eax),%edx
  800260:	3b 50 04             	cmp    0x4(%eax),%edx
  800263:	73 0a                	jae    80026f <sprintputch+0x1f>
		*b->buf++ = ch;
  800265:	8d 4a 01             	lea    0x1(%edx),%ecx
  800268:	89 08                	mov    %ecx,(%eax)
  80026a:	8b 45 08             	mov    0x8(%ebp),%eax
  80026d:	88 02                	mov    %al,(%edx)
}
  80026f:	5d                   	pop    %ebp
  800270:	c3                   	ret    

00800271 <printfmt>:
{
  800271:	f3 0f 1e fb          	endbr32 
  800275:	55                   	push   %ebp
  800276:	89 e5                	mov    %esp,%ebp
  800278:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80027b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80027e:	50                   	push   %eax
  80027f:	ff 75 10             	pushl  0x10(%ebp)
  800282:	ff 75 0c             	pushl  0xc(%ebp)
  800285:	ff 75 08             	pushl  0x8(%ebp)
  800288:	e8 05 00 00 00       	call   800292 <vprintfmt>
}
  80028d:	83 c4 10             	add    $0x10,%esp
  800290:	c9                   	leave  
  800291:	c3                   	ret    

00800292 <vprintfmt>:
{
  800292:	f3 0f 1e fb          	endbr32 
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
  800299:	57                   	push   %edi
  80029a:	56                   	push   %esi
  80029b:	53                   	push   %ebx
  80029c:	83 ec 3c             	sub    $0x3c,%esp
  80029f:	8b 75 08             	mov    0x8(%ebp),%esi
  8002a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002a5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002a8:	e9 4a 03 00 00       	jmp    8005f7 <vprintfmt+0x365>
		padc = ' ';
  8002ad:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002b1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002b8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002bf:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002c6:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002cb:	8d 47 01             	lea    0x1(%edi),%eax
  8002ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002d1:	0f b6 17             	movzbl (%edi),%edx
  8002d4:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002d7:	3c 55                	cmp    $0x55,%al
  8002d9:	0f 87 de 03 00 00    	ja     8006bd <vprintfmt+0x42b>
  8002df:	0f b6 c0             	movzbl %al,%eax
  8002e2:	3e ff 24 85 a0 12 80 	notrack jmp *0x8012a0(,%eax,4)
  8002e9:	00 
  8002ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002ed:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002f1:	eb d8                	jmp    8002cb <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8002f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002f6:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002fa:	eb cf                	jmp    8002cb <vprintfmt+0x39>
  8002fc:	0f b6 d2             	movzbl %dl,%edx
  8002ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800302:	b8 00 00 00 00       	mov    $0x0,%eax
  800307:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80030a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80030d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800311:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800314:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800317:	83 f9 09             	cmp    $0x9,%ecx
  80031a:	77 55                	ja     800371 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80031c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80031f:	eb e9                	jmp    80030a <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800321:	8b 45 14             	mov    0x14(%ebp),%eax
  800324:	8b 00                	mov    (%eax),%eax
  800326:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800329:	8b 45 14             	mov    0x14(%ebp),%eax
  80032c:	8d 40 04             	lea    0x4(%eax),%eax
  80032f:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800332:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800335:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800339:	79 90                	jns    8002cb <vprintfmt+0x39>
				width = precision, precision = -1;
  80033b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80033e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800341:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800348:	eb 81                	jmp    8002cb <vprintfmt+0x39>
  80034a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80034d:	85 c0                	test   %eax,%eax
  80034f:	ba 00 00 00 00       	mov    $0x0,%edx
  800354:	0f 49 d0             	cmovns %eax,%edx
  800357:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80035a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80035d:	e9 69 ff ff ff       	jmp    8002cb <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800362:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800365:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80036c:	e9 5a ff ff ff       	jmp    8002cb <vprintfmt+0x39>
  800371:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800374:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800377:	eb bc                	jmp    800335 <vprintfmt+0xa3>
			lflag++;
  800379:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80037c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80037f:	e9 47 ff ff ff       	jmp    8002cb <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800384:	8b 45 14             	mov    0x14(%ebp),%eax
  800387:	8d 78 04             	lea    0x4(%eax),%edi
  80038a:	83 ec 08             	sub    $0x8,%esp
  80038d:	53                   	push   %ebx
  80038e:	ff 30                	pushl  (%eax)
  800390:	ff d6                	call   *%esi
			break;
  800392:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800395:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800398:	e9 57 02 00 00       	jmp    8005f4 <vprintfmt+0x362>
			err = va_arg(ap, int);
  80039d:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a0:	8d 78 04             	lea    0x4(%eax),%edi
  8003a3:	8b 00                	mov    (%eax),%eax
  8003a5:	99                   	cltd   
  8003a6:	31 d0                	xor    %edx,%eax
  8003a8:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003aa:	83 f8 0f             	cmp    $0xf,%eax
  8003ad:	7f 23                	jg     8003d2 <vprintfmt+0x140>
  8003af:	8b 14 85 00 14 80 00 	mov    0x801400(,%eax,4),%edx
  8003b6:	85 d2                	test   %edx,%edx
  8003b8:	74 18                	je     8003d2 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8003ba:	52                   	push   %edx
  8003bb:	68 87 11 80 00       	push   $0x801187
  8003c0:	53                   	push   %ebx
  8003c1:	56                   	push   %esi
  8003c2:	e8 aa fe ff ff       	call   800271 <printfmt>
  8003c7:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003ca:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003cd:	e9 22 02 00 00       	jmp    8005f4 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8003d2:	50                   	push   %eax
  8003d3:	68 7e 11 80 00       	push   $0x80117e
  8003d8:	53                   	push   %ebx
  8003d9:	56                   	push   %esi
  8003da:	e8 92 fe ff ff       	call   800271 <printfmt>
  8003df:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003e2:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003e5:	e9 0a 02 00 00       	jmp    8005f4 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8003ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ed:	83 c0 04             	add    $0x4,%eax
  8003f0:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f6:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003f8:	85 d2                	test   %edx,%edx
  8003fa:	b8 77 11 80 00       	mov    $0x801177,%eax
  8003ff:	0f 45 c2             	cmovne %edx,%eax
  800402:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800405:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800409:	7e 06                	jle    800411 <vprintfmt+0x17f>
  80040b:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80040f:	75 0d                	jne    80041e <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800411:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800414:	89 c7                	mov    %eax,%edi
  800416:	03 45 e0             	add    -0x20(%ebp),%eax
  800419:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80041c:	eb 55                	jmp    800473 <vprintfmt+0x1e1>
  80041e:	83 ec 08             	sub    $0x8,%esp
  800421:	ff 75 d8             	pushl  -0x28(%ebp)
  800424:	ff 75 cc             	pushl  -0x34(%ebp)
  800427:	e8 45 03 00 00       	call   800771 <strnlen>
  80042c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80042f:	29 c2                	sub    %eax,%edx
  800431:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800434:	83 c4 10             	add    $0x10,%esp
  800437:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800439:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80043d:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800440:	85 ff                	test   %edi,%edi
  800442:	7e 11                	jle    800455 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800444:	83 ec 08             	sub    $0x8,%esp
  800447:	53                   	push   %ebx
  800448:	ff 75 e0             	pushl  -0x20(%ebp)
  80044b:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80044d:	83 ef 01             	sub    $0x1,%edi
  800450:	83 c4 10             	add    $0x10,%esp
  800453:	eb eb                	jmp    800440 <vprintfmt+0x1ae>
  800455:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800458:	85 d2                	test   %edx,%edx
  80045a:	b8 00 00 00 00       	mov    $0x0,%eax
  80045f:	0f 49 c2             	cmovns %edx,%eax
  800462:	29 c2                	sub    %eax,%edx
  800464:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800467:	eb a8                	jmp    800411 <vprintfmt+0x17f>
					putch(ch, putdat);
  800469:	83 ec 08             	sub    $0x8,%esp
  80046c:	53                   	push   %ebx
  80046d:	52                   	push   %edx
  80046e:	ff d6                	call   *%esi
  800470:	83 c4 10             	add    $0x10,%esp
  800473:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800476:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800478:	83 c7 01             	add    $0x1,%edi
  80047b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80047f:	0f be d0             	movsbl %al,%edx
  800482:	85 d2                	test   %edx,%edx
  800484:	74 4b                	je     8004d1 <vprintfmt+0x23f>
  800486:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80048a:	78 06                	js     800492 <vprintfmt+0x200>
  80048c:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800490:	78 1e                	js     8004b0 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800492:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800496:	74 d1                	je     800469 <vprintfmt+0x1d7>
  800498:	0f be c0             	movsbl %al,%eax
  80049b:	83 e8 20             	sub    $0x20,%eax
  80049e:	83 f8 5e             	cmp    $0x5e,%eax
  8004a1:	76 c6                	jbe    800469 <vprintfmt+0x1d7>
					putch('?', putdat);
  8004a3:	83 ec 08             	sub    $0x8,%esp
  8004a6:	53                   	push   %ebx
  8004a7:	6a 3f                	push   $0x3f
  8004a9:	ff d6                	call   *%esi
  8004ab:	83 c4 10             	add    $0x10,%esp
  8004ae:	eb c3                	jmp    800473 <vprintfmt+0x1e1>
  8004b0:	89 cf                	mov    %ecx,%edi
  8004b2:	eb 0e                	jmp    8004c2 <vprintfmt+0x230>
				putch(' ', putdat);
  8004b4:	83 ec 08             	sub    $0x8,%esp
  8004b7:	53                   	push   %ebx
  8004b8:	6a 20                	push   $0x20
  8004ba:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004bc:	83 ef 01             	sub    $0x1,%edi
  8004bf:	83 c4 10             	add    $0x10,%esp
  8004c2:	85 ff                	test   %edi,%edi
  8004c4:	7f ee                	jg     8004b4 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8004c6:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004c9:	89 45 14             	mov    %eax,0x14(%ebp)
  8004cc:	e9 23 01 00 00       	jmp    8005f4 <vprintfmt+0x362>
  8004d1:	89 cf                	mov    %ecx,%edi
  8004d3:	eb ed                	jmp    8004c2 <vprintfmt+0x230>
	if (lflag >= 2)
  8004d5:	83 f9 01             	cmp    $0x1,%ecx
  8004d8:	7f 1b                	jg     8004f5 <vprintfmt+0x263>
	else if (lflag)
  8004da:	85 c9                	test   %ecx,%ecx
  8004dc:	74 63                	je     800541 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8004de:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e1:	8b 00                	mov    (%eax),%eax
  8004e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004e6:	99                   	cltd   
  8004e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ed:	8d 40 04             	lea    0x4(%eax),%eax
  8004f0:	89 45 14             	mov    %eax,0x14(%ebp)
  8004f3:	eb 17                	jmp    80050c <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8004f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f8:	8b 50 04             	mov    0x4(%eax),%edx
  8004fb:	8b 00                	mov    (%eax),%eax
  8004fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800500:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800503:	8b 45 14             	mov    0x14(%ebp),%eax
  800506:	8d 40 08             	lea    0x8(%eax),%eax
  800509:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80050c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80050f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800512:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800517:	85 c9                	test   %ecx,%ecx
  800519:	0f 89 bb 00 00 00    	jns    8005da <vprintfmt+0x348>
				putch('-', putdat);
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	53                   	push   %ebx
  800523:	6a 2d                	push   $0x2d
  800525:	ff d6                	call   *%esi
				num = -(long long) num;
  800527:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80052a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80052d:	f7 da                	neg    %edx
  80052f:	83 d1 00             	adc    $0x0,%ecx
  800532:	f7 d9                	neg    %ecx
  800534:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800537:	b8 0a 00 00 00       	mov    $0xa,%eax
  80053c:	e9 99 00 00 00       	jmp    8005da <vprintfmt+0x348>
		return va_arg(*ap, int);
  800541:	8b 45 14             	mov    0x14(%ebp),%eax
  800544:	8b 00                	mov    (%eax),%eax
  800546:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800549:	99                   	cltd   
  80054a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80054d:	8b 45 14             	mov    0x14(%ebp),%eax
  800550:	8d 40 04             	lea    0x4(%eax),%eax
  800553:	89 45 14             	mov    %eax,0x14(%ebp)
  800556:	eb b4                	jmp    80050c <vprintfmt+0x27a>
	if (lflag >= 2)
  800558:	83 f9 01             	cmp    $0x1,%ecx
  80055b:	7f 1b                	jg     800578 <vprintfmt+0x2e6>
	else if (lflag)
  80055d:	85 c9                	test   %ecx,%ecx
  80055f:	74 2c                	je     80058d <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800561:	8b 45 14             	mov    0x14(%ebp),%eax
  800564:	8b 10                	mov    (%eax),%edx
  800566:	b9 00 00 00 00       	mov    $0x0,%ecx
  80056b:	8d 40 04             	lea    0x4(%eax),%eax
  80056e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800571:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800576:	eb 62                	jmp    8005da <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	8b 10                	mov    (%eax),%edx
  80057d:	8b 48 04             	mov    0x4(%eax),%ecx
  800580:	8d 40 08             	lea    0x8(%eax),%eax
  800583:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800586:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80058b:	eb 4d                	jmp    8005da <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	8b 10                	mov    (%eax),%edx
  800592:	b9 00 00 00 00       	mov    $0x0,%ecx
  800597:	8d 40 04             	lea    0x4(%eax),%eax
  80059a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80059d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8005a2:	eb 36                	jmp    8005da <vprintfmt+0x348>
	if (lflag >= 2)
  8005a4:	83 f9 01             	cmp    $0x1,%ecx
  8005a7:	7f 17                	jg     8005c0 <vprintfmt+0x32e>
	else if (lflag)
  8005a9:	85 c9                	test   %ecx,%ecx
  8005ab:	74 6e                	je     80061b <vprintfmt+0x389>
		return va_arg(*ap, long);
  8005ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b0:	8b 10                	mov    (%eax),%edx
  8005b2:	89 d0                	mov    %edx,%eax
  8005b4:	99                   	cltd   
  8005b5:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005b8:	8d 49 04             	lea    0x4(%ecx),%ecx
  8005bb:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005be:	eb 11                	jmp    8005d1 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8b 50 04             	mov    0x4(%eax),%edx
  8005c6:	8b 00                	mov    (%eax),%eax
  8005c8:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005cb:	8d 49 08             	lea    0x8(%ecx),%ecx
  8005ce:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8005d1:	89 d1                	mov    %edx,%ecx
  8005d3:	89 c2                	mov    %eax,%edx
            base = 8;
  8005d5:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005da:	83 ec 0c             	sub    $0xc,%esp
  8005dd:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005e1:	57                   	push   %edi
  8005e2:	ff 75 e0             	pushl  -0x20(%ebp)
  8005e5:	50                   	push   %eax
  8005e6:	51                   	push   %ecx
  8005e7:	52                   	push   %edx
  8005e8:	89 da                	mov    %ebx,%edx
  8005ea:	89 f0                	mov    %esi,%eax
  8005ec:	e8 b6 fb ff ff       	call   8001a7 <printnum>
			break;
  8005f1:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8005f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005f7:	83 c7 01             	add    $0x1,%edi
  8005fa:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005fe:	83 f8 25             	cmp    $0x25,%eax
  800601:	0f 84 a6 fc ff ff    	je     8002ad <vprintfmt+0x1b>
			if (ch == '\0')
  800607:	85 c0                	test   %eax,%eax
  800609:	0f 84 ce 00 00 00    	je     8006dd <vprintfmt+0x44b>
			putch(ch, putdat);
  80060f:	83 ec 08             	sub    $0x8,%esp
  800612:	53                   	push   %ebx
  800613:	50                   	push   %eax
  800614:	ff d6                	call   *%esi
  800616:	83 c4 10             	add    $0x10,%esp
  800619:	eb dc                	jmp    8005f7 <vprintfmt+0x365>
		return va_arg(*ap, int);
  80061b:	8b 45 14             	mov    0x14(%ebp),%eax
  80061e:	8b 10                	mov    (%eax),%edx
  800620:	89 d0                	mov    %edx,%eax
  800622:	99                   	cltd   
  800623:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800626:	8d 49 04             	lea    0x4(%ecx),%ecx
  800629:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80062c:	eb a3                	jmp    8005d1 <vprintfmt+0x33f>
			putch('0', putdat);
  80062e:	83 ec 08             	sub    $0x8,%esp
  800631:	53                   	push   %ebx
  800632:	6a 30                	push   $0x30
  800634:	ff d6                	call   *%esi
			putch('x', putdat);
  800636:	83 c4 08             	add    $0x8,%esp
  800639:	53                   	push   %ebx
  80063a:	6a 78                	push   $0x78
  80063c:	ff d6                	call   *%esi
			num = (unsigned long long)
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	8b 10                	mov    (%eax),%edx
  800643:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800648:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80064b:	8d 40 04             	lea    0x4(%eax),%eax
  80064e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800651:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800656:	eb 82                	jmp    8005da <vprintfmt+0x348>
	if (lflag >= 2)
  800658:	83 f9 01             	cmp    $0x1,%ecx
  80065b:	7f 1e                	jg     80067b <vprintfmt+0x3e9>
	else if (lflag)
  80065d:	85 c9                	test   %ecx,%ecx
  80065f:	74 32                	je     800693 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800661:	8b 45 14             	mov    0x14(%ebp),%eax
  800664:	8b 10                	mov    (%eax),%edx
  800666:	b9 00 00 00 00       	mov    $0x0,%ecx
  80066b:	8d 40 04             	lea    0x4(%eax),%eax
  80066e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800671:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800676:	e9 5f ff ff ff       	jmp    8005da <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80067b:	8b 45 14             	mov    0x14(%ebp),%eax
  80067e:	8b 10                	mov    (%eax),%edx
  800680:	8b 48 04             	mov    0x4(%eax),%ecx
  800683:	8d 40 08             	lea    0x8(%eax),%eax
  800686:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800689:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80068e:	e9 47 ff ff ff       	jmp    8005da <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800693:	8b 45 14             	mov    0x14(%ebp),%eax
  800696:	8b 10                	mov    (%eax),%edx
  800698:	b9 00 00 00 00       	mov    $0x0,%ecx
  80069d:	8d 40 04             	lea    0x4(%eax),%eax
  8006a0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a3:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006a8:	e9 2d ff ff ff       	jmp    8005da <vprintfmt+0x348>
			putch(ch, putdat);
  8006ad:	83 ec 08             	sub    $0x8,%esp
  8006b0:	53                   	push   %ebx
  8006b1:	6a 25                	push   $0x25
  8006b3:	ff d6                	call   *%esi
			break;
  8006b5:	83 c4 10             	add    $0x10,%esp
  8006b8:	e9 37 ff ff ff       	jmp    8005f4 <vprintfmt+0x362>
			putch('%', putdat);
  8006bd:	83 ec 08             	sub    $0x8,%esp
  8006c0:	53                   	push   %ebx
  8006c1:	6a 25                	push   $0x25
  8006c3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c5:	83 c4 10             	add    $0x10,%esp
  8006c8:	89 f8                	mov    %edi,%eax
  8006ca:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006ce:	74 05                	je     8006d5 <vprintfmt+0x443>
  8006d0:	83 e8 01             	sub    $0x1,%eax
  8006d3:	eb f5                	jmp    8006ca <vprintfmt+0x438>
  8006d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006d8:	e9 17 ff ff ff       	jmp    8005f4 <vprintfmt+0x362>
}
  8006dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006e0:	5b                   	pop    %ebx
  8006e1:	5e                   	pop    %esi
  8006e2:	5f                   	pop    %edi
  8006e3:	5d                   	pop    %ebp
  8006e4:	c3                   	ret    

008006e5 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006e5:	f3 0f 1e fb          	endbr32 
  8006e9:	55                   	push   %ebp
  8006ea:	89 e5                	mov    %esp,%ebp
  8006ec:	83 ec 18             	sub    $0x18,%esp
  8006ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006fc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800706:	85 c0                	test   %eax,%eax
  800708:	74 26                	je     800730 <vsnprintf+0x4b>
  80070a:	85 d2                	test   %edx,%edx
  80070c:	7e 22                	jle    800730 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80070e:	ff 75 14             	pushl  0x14(%ebp)
  800711:	ff 75 10             	pushl  0x10(%ebp)
  800714:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800717:	50                   	push   %eax
  800718:	68 50 02 80 00       	push   $0x800250
  80071d:	e8 70 fb ff ff       	call   800292 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800722:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800725:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800728:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80072b:	83 c4 10             	add    $0x10,%esp
}
  80072e:	c9                   	leave  
  80072f:	c3                   	ret    
		return -E_INVAL;
  800730:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800735:	eb f7                	jmp    80072e <vsnprintf+0x49>

00800737 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800737:	f3 0f 1e fb          	endbr32 
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800741:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800744:	50                   	push   %eax
  800745:	ff 75 10             	pushl  0x10(%ebp)
  800748:	ff 75 0c             	pushl  0xc(%ebp)
  80074b:	ff 75 08             	pushl  0x8(%ebp)
  80074e:	e8 92 ff ff ff       	call   8006e5 <vsnprintf>
	va_end(ap);

	return rc;
}
  800753:	c9                   	leave  
  800754:	c3                   	ret    

00800755 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800755:	f3 0f 1e fb          	endbr32 
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80075f:	b8 00 00 00 00       	mov    $0x0,%eax
  800764:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800768:	74 05                	je     80076f <strlen+0x1a>
		n++;
  80076a:	83 c0 01             	add    $0x1,%eax
  80076d:	eb f5                	jmp    800764 <strlen+0xf>
	return n;
}
  80076f:	5d                   	pop    %ebp
  800770:	c3                   	ret    

00800771 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800771:	f3 0f 1e fb          	endbr32 
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077e:	b8 00 00 00 00       	mov    $0x0,%eax
  800783:	39 d0                	cmp    %edx,%eax
  800785:	74 0d                	je     800794 <strnlen+0x23>
  800787:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80078b:	74 05                	je     800792 <strnlen+0x21>
		n++;
  80078d:	83 c0 01             	add    $0x1,%eax
  800790:	eb f1                	jmp    800783 <strnlen+0x12>
  800792:	89 c2                	mov    %eax,%edx
	return n;
}
  800794:	89 d0                	mov    %edx,%eax
  800796:	5d                   	pop    %ebp
  800797:	c3                   	ret    

00800798 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800798:	f3 0f 1e fb          	endbr32 
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	53                   	push   %ebx
  8007a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ab:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007af:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007b2:	83 c0 01             	add    $0x1,%eax
  8007b5:	84 d2                	test   %dl,%dl
  8007b7:	75 f2                	jne    8007ab <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8007b9:	89 c8                	mov    %ecx,%eax
  8007bb:	5b                   	pop    %ebx
  8007bc:	5d                   	pop    %ebp
  8007bd:	c3                   	ret    

008007be <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007be:	f3 0f 1e fb          	endbr32 
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	53                   	push   %ebx
  8007c6:	83 ec 10             	sub    $0x10,%esp
  8007c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007cc:	53                   	push   %ebx
  8007cd:	e8 83 ff ff ff       	call   800755 <strlen>
  8007d2:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007d5:	ff 75 0c             	pushl  0xc(%ebp)
  8007d8:	01 d8                	add    %ebx,%eax
  8007da:	50                   	push   %eax
  8007db:	e8 b8 ff ff ff       	call   800798 <strcpy>
	return dst;
}
  8007e0:	89 d8                	mov    %ebx,%eax
  8007e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e5:	c9                   	leave  
  8007e6:	c3                   	ret    

008007e7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007e7:	f3 0f 1e fb          	endbr32 
  8007eb:	55                   	push   %ebp
  8007ec:	89 e5                	mov    %esp,%ebp
  8007ee:	56                   	push   %esi
  8007ef:	53                   	push   %ebx
  8007f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f6:	89 f3                	mov    %esi,%ebx
  8007f8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fb:	89 f0                	mov    %esi,%eax
  8007fd:	39 d8                	cmp    %ebx,%eax
  8007ff:	74 11                	je     800812 <strncpy+0x2b>
		*dst++ = *src;
  800801:	83 c0 01             	add    $0x1,%eax
  800804:	0f b6 0a             	movzbl (%edx),%ecx
  800807:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80080a:	80 f9 01             	cmp    $0x1,%cl
  80080d:	83 da ff             	sbb    $0xffffffff,%edx
  800810:	eb eb                	jmp    8007fd <strncpy+0x16>
	}
	return ret;
}
  800812:	89 f0                	mov    %esi,%eax
  800814:	5b                   	pop    %ebx
  800815:	5e                   	pop    %esi
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800818:	f3 0f 1e fb          	endbr32 
  80081c:	55                   	push   %ebp
  80081d:	89 e5                	mov    %esp,%ebp
  80081f:	56                   	push   %esi
  800820:	53                   	push   %ebx
  800821:	8b 75 08             	mov    0x8(%ebp),%esi
  800824:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800827:	8b 55 10             	mov    0x10(%ebp),%edx
  80082a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80082c:	85 d2                	test   %edx,%edx
  80082e:	74 21                	je     800851 <strlcpy+0x39>
  800830:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800834:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800836:	39 c2                	cmp    %eax,%edx
  800838:	74 14                	je     80084e <strlcpy+0x36>
  80083a:	0f b6 19             	movzbl (%ecx),%ebx
  80083d:	84 db                	test   %bl,%bl
  80083f:	74 0b                	je     80084c <strlcpy+0x34>
			*dst++ = *src++;
  800841:	83 c1 01             	add    $0x1,%ecx
  800844:	83 c2 01             	add    $0x1,%edx
  800847:	88 5a ff             	mov    %bl,-0x1(%edx)
  80084a:	eb ea                	jmp    800836 <strlcpy+0x1e>
  80084c:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80084e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800851:	29 f0                	sub    %esi,%eax
}
  800853:	5b                   	pop    %ebx
  800854:	5e                   	pop    %esi
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800857:	f3 0f 1e fb          	endbr32 
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800861:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800864:	0f b6 01             	movzbl (%ecx),%eax
  800867:	84 c0                	test   %al,%al
  800869:	74 0c                	je     800877 <strcmp+0x20>
  80086b:	3a 02                	cmp    (%edx),%al
  80086d:	75 08                	jne    800877 <strcmp+0x20>
		p++, q++;
  80086f:	83 c1 01             	add    $0x1,%ecx
  800872:	83 c2 01             	add    $0x1,%edx
  800875:	eb ed                	jmp    800864 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800877:	0f b6 c0             	movzbl %al,%eax
  80087a:	0f b6 12             	movzbl (%edx),%edx
  80087d:	29 d0                	sub    %edx,%eax
}
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800881:	f3 0f 1e fb          	endbr32 
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	53                   	push   %ebx
  800889:	8b 45 08             	mov    0x8(%ebp),%eax
  80088c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088f:	89 c3                	mov    %eax,%ebx
  800891:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800894:	eb 06                	jmp    80089c <strncmp+0x1b>
		n--, p++, q++;
  800896:	83 c0 01             	add    $0x1,%eax
  800899:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80089c:	39 d8                	cmp    %ebx,%eax
  80089e:	74 16                	je     8008b6 <strncmp+0x35>
  8008a0:	0f b6 08             	movzbl (%eax),%ecx
  8008a3:	84 c9                	test   %cl,%cl
  8008a5:	74 04                	je     8008ab <strncmp+0x2a>
  8008a7:	3a 0a                	cmp    (%edx),%cl
  8008a9:	74 eb                	je     800896 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ab:	0f b6 00             	movzbl (%eax),%eax
  8008ae:	0f b6 12             	movzbl (%edx),%edx
  8008b1:	29 d0                	sub    %edx,%eax
}
  8008b3:	5b                   	pop    %ebx
  8008b4:	5d                   	pop    %ebp
  8008b5:	c3                   	ret    
		return 0;
  8008b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008bb:	eb f6                	jmp    8008b3 <strncmp+0x32>

008008bd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008bd:	f3 0f 1e fb          	endbr32 
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008cb:	0f b6 10             	movzbl (%eax),%edx
  8008ce:	84 d2                	test   %dl,%dl
  8008d0:	74 09                	je     8008db <strchr+0x1e>
		if (*s == c)
  8008d2:	38 ca                	cmp    %cl,%dl
  8008d4:	74 0a                	je     8008e0 <strchr+0x23>
	for (; *s; s++)
  8008d6:	83 c0 01             	add    $0x1,%eax
  8008d9:	eb f0                	jmp    8008cb <strchr+0xe>
			return (char *) s;
	return 0;
  8008db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e2:	f3 0f 1e fb          	endbr32 
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ec:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f3:	38 ca                	cmp    %cl,%dl
  8008f5:	74 09                	je     800900 <strfind+0x1e>
  8008f7:	84 d2                	test   %dl,%dl
  8008f9:	74 05                	je     800900 <strfind+0x1e>
	for (; *s; s++)
  8008fb:	83 c0 01             	add    $0x1,%eax
  8008fe:	eb f0                	jmp    8008f0 <strfind+0xe>
			break;
	return (char *) s;
}
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800902:	f3 0f 1e fb          	endbr32 
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	57                   	push   %edi
  80090a:	56                   	push   %esi
  80090b:	53                   	push   %ebx
  80090c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80090f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800912:	85 c9                	test   %ecx,%ecx
  800914:	74 31                	je     800947 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800916:	89 f8                	mov    %edi,%eax
  800918:	09 c8                	or     %ecx,%eax
  80091a:	a8 03                	test   $0x3,%al
  80091c:	75 23                	jne    800941 <memset+0x3f>
		c &= 0xFF;
  80091e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800922:	89 d3                	mov    %edx,%ebx
  800924:	c1 e3 08             	shl    $0x8,%ebx
  800927:	89 d0                	mov    %edx,%eax
  800929:	c1 e0 18             	shl    $0x18,%eax
  80092c:	89 d6                	mov    %edx,%esi
  80092e:	c1 e6 10             	shl    $0x10,%esi
  800931:	09 f0                	or     %esi,%eax
  800933:	09 c2                	or     %eax,%edx
  800935:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800937:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80093a:	89 d0                	mov    %edx,%eax
  80093c:	fc                   	cld    
  80093d:	f3 ab                	rep stos %eax,%es:(%edi)
  80093f:	eb 06                	jmp    800947 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800941:	8b 45 0c             	mov    0xc(%ebp),%eax
  800944:	fc                   	cld    
  800945:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800947:	89 f8                	mov    %edi,%eax
  800949:	5b                   	pop    %ebx
  80094a:	5e                   	pop    %esi
  80094b:	5f                   	pop    %edi
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80094e:	f3 0f 1e fb          	endbr32 
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	57                   	push   %edi
  800956:	56                   	push   %esi
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80095d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800960:	39 c6                	cmp    %eax,%esi
  800962:	73 32                	jae    800996 <memmove+0x48>
  800964:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800967:	39 c2                	cmp    %eax,%edx
  800969:	76 2b                	jbe    800996 <memmove+0x48>
		s += n;
		d += n;
  80096b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096e:	89 fe                	mov    %edi,%esi
  800970:	09 ce                	or     %ecx,%esi
  800972:	09 d6                	or     %edx,%esi
  800974:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80097a:	75 0e                	jne    80098a <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80097c:	83 ef 04             	sub    $0x4,%edi
  80097f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800982:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800985:	fd                   	std    
  800986:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800988:	eb 09                	jmp    800993 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80098a:	83 ef 01             	sub    $0x1,%edi
  80098d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800990:	fd                   	std    
  800991:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800993:	fc                   	cld    
  800994:	eb 1a                	jmp    8009b0 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800996:	89 c2                	mov    %eax,%edx
  800998:	09 ca                	or     %ecx,%edx
  80099a:	09 f2                	or     %esi,%edx
  80099c:	f6 c2 03             	test   $0x3,%dl
  80099f:	75 0a                	jne    8009ab <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009a1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009a4:	89 c7                	mov    %eax,%edi
  8009a6:	fc                   	cld    
  8009a7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a9:	eb 05                	jmp    8009b0 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8009ab:	89 c7                	mov    %eax,%edi
  8009ad:	fc                   	cld    
  8009ae:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b0:	5e                   	pop    %esi
  8009b1:	5f                   	pop    %edi
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b4:	f3 0f 1e fb          	endbr32 
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009be:	ff 75 10             	pushl  0x10(%ebp)
  8009c1:	ff 75 0c             	pushl  0xc(%ebp)
  8009c4:	ff 75 08             	pushl  0x8(%ebp)
  8009c7:	e8 82 ff ff ff       	call   80094e <memmove>
}
  8009cc:	c9                   	leave  
  8009cd:	c3                   	ret    

008009ce <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ce:	f3 0f 1e fb          	endbr32 
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	56                   	push   %esi
  8009d6:	53                   	push   %ebx
  8009d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009dd:	89 c6                	mov    %eax,%esi
  8009df:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e2:	39 f0                	cmp    %esi,%eax
  8009e4:	74 1c                	je     800a02 <memcmp+0x34>
		if (*s1 != *s2)
  8009e6:	0f b6 08             	movzbl (%eax),%ecx
  8009e9:	0f b6 1a             	movzbl (%edx),%ebx
  8009ec:	38 d9                	cmp    %bl,%cl
  8009ee:	75 08                	jne    8009f8 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009f0:	83 c0 01             	add    $0x1,%eax
  8009f3:	83 c2 01             	add    $0x1,%edx
  8009f6:	eb ea                	jmp    8009e2 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  8009f8:	0f b6 c1             	movzbl %cl,%eax
  8009fb:	0f b6 db             	movzbl %bl,%ebx
  8009fe:	29 d8                	sub    %ebx,%eax
  800a00:	eb 05                	jmp    800a07 <memcmp+0x39>
	}

	return 0;
  800a02:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a07:	5b                   	pop    %ebx
  800a08:	5e                   	pop    %esi
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a0b:	f3 0f 1e fb          	endbr32 
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	8b 45 08             	mov    0x8(%ebp),%eax
  800a15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a18:	89 c2                	mov    %eax,%edx
  800a1a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a1d:	39 d0                	cmp    %edx,%eax
  800a1f:	73 09                	jae    800a2a <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a21:	38 08                	cmp    %cl,(%eax)
  800a23:	74 05                	je     800a2a <memfind+0x1f>
	for (; s < ends; s++)
  800a25:	83 c0 01             	add    $0x1,%eax
  800a28:	eb f3                	jmp    800a1d <memfind+0x12>
			break;
	return (void *) s;
}
  800a2a:	5d                   	pop    %ebp
  800a2b:	c3                   	ret    

00800a2c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a2c:	f3 0f 1e fb          	endbr32 
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	57                   	push   %edi
  800a34:	56                   	push   %esi
  800a35:	53                   	push   %ebx
  800a36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a39:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a3c:	eb 03                	jmp    800a41 <strtol+0x15>
		s++;
  800a3e:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a41:	0f b6 01             	movzbl (%ecx),%eax
  800a44:	3c 20                	cmp    $0x20,%al
  800a46:	74 f6                	je     800a3e <strtol+0x12>
  800a48:	3c 09                	cmp    $0x9,%al
  800a4a:	74 f2                	je     800a3e <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a4c:	3c 2b                	cmp    $0x2b,%al
  800a4e:	74 2a                	je     800a7a <strtol+0x4e>
	int neg = 0;
  800a50:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a55:	3c 2d                	cmp    $0x2d,%al
  800a57:	74 2b                	je     800a84 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a59:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a5f:	75 0f                	jne    800a70 <strtol+0x44>
  800a61:	80 39 30             	cmpb   $0x30,(%ecx)
  800a64:	74 28                	je     800a8e <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a66:	85 db                	test   %ebx,%ebx
  800a68:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a6d:	0f 44 d8             	cmove  %eax,%ebx
  800a70:	b8 00 00 00 00       	mov    $0x0,%eax
  800a75:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a78:	eb 46                	jmp    800ac0 <strtol+0x94>
		s++;
  800a7a:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a7d:	bf 00 00 00 00       	mov    $0x0,%edi
  800a82:	eb d5                	jmp    800a59 <strtol+0x2d>
		s++, neg = 1;
  800a84:	83 c1 01             	add    $0x1,%ecx
  800a87:	bf 01 00 00 00       	mov    $0x1,%edi
  800a8c:	eb cb                	jmp    800a59 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a92:	74 0e                	je     800aa2 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a94:	85 db                	test   %ebx,%ebx
  800a96:	75 d8                	jne    800a70 <strtol+0x44>
		s++, base = 8;
  800a98:	83 c1 01             	add    $0x1,%ecx
  800a9b:	bb 08 00 00 00       	mov    $0x8,%ebx
  800aa0:	eb ce                	jmp    800a70 <strtol+0x44>
		s += 2, base = 16;
  800aa2:	83 c1 02             	add    $0x2,%ecx
  800aa5:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aaa:	eb c4                	jmp    800a70 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800aac:	0f be d2             	movsbl %dl,%edx
  800aaf:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ab2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ab5:	7d 3a                	jge    800af1 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ab7:	83 c1 01             	add    $0x1,%ecx
  800aba:	0f af 45 10          	imul   0x10(%ebp),%eax
  800abe:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ac0:	0f b6 11             	movzbl (%ecx),%edx
  800ac3:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ac6:	89 f3                	mov    %esi,%ebx
  800ac8:	80 fb 09             	cmp    $0x9,%bl
  800acb:	76 df                	jbe    800aac <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800acd:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ad0:	89 f3                	mov    %esi,%ebx
  800ad2:	80 fb 19             	cmp    $0x19,%bl
  800ad5:	77 08                	ja     800adf <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ad7:	0f be d2             	movsbl %dl,%edx
  800ada:	83 ea 57             	sub    $0x57,%edx
  800add:	eb d3                	jmp    800ab2 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800adf:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ae2:	89 f3                	mov    %esi,%ebx
  800ae4:	80 fb 19             	cmp    $0x19,%bl
  800ae7:	77 08                	ja     800af1 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ae9:	0f be d2             	movsbl %dl,%edx
  800aec:	83 ea 37             	sub    $0x37,%edx
  800aef:	eb c1                	jmp    800ab2 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800af1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800af5:	74 05                	je     800afc <strtol+0xd0>
		*endptr = (char *) s;
  800af7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800afa:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800afc:	89 c2                	mov    %eax,%edx
  800afe:	f7 da                	neg    %edx
  800b00:	85 ff                	test   %edi,%edi
  800b02:	0f 45 c2             	cmovne %edx,%eax
}
  800b05:	5b                   	pop    %ebx
  800b06:	5e                   	pop    %esi
  800b07:	5f                   	pop    %edi
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b0a:	f3 0f 1e fb          	endbr32 
  800b0e:	55                   	push   %ebp
  800b0f:	89 e5                	mov    %esp,%ebp
  800b11:	57                   	push   %edi
  800b12:	56                   	push   %esi
  800b13:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b14:	b8 00 00 00 00       	mov    $0x0,%eax
  800b19:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b1f:	89 c3                	mov    %eax,%ebx
  800b21:	89 c7                	mov    %eax,%edi
  800b23:	89 c6                	mov    %eax,%esi
  800b25:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b27:	5b                   	pop    %ebx
  800b28:	5e                   	pop    %esi
  800b29:	5f                   	pop    %edi
  800b2a:	5d                   	pop    %ebp
  800b2b:	c3                   	ret    

00800b2c <sys_cgetc>:

int
sys_cgetc(void)
{
  800b2c:	f3 0f 1e fb          	endbr32 
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	57                   	push   %edi
  800b34:	56                   	push   %esi
  800b35:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b36:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b40:	89 d1                	mov    %edx,%ecx
  800b42:	89 d3                	mov    %edx,%ebx
  800b44:	89 d7                	mov    %edx,%edi
  800b46:	89 d6                	mov    %edx,%esi
  800b48:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b4a:	5b                   	pop    %ebx
  800b4b:	5e                   	pop    %esi
  800b4c:	5f                   	pop    %edi
  800b4d:	5d                   	pop    %ebp
  800b4e:	c3                   	ret    

00800b4f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b4f:	f3 0f 1e fb          	endbr32 
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	57                   	push   %edi
  800b57:	56                   	push   %esi
  800b58:	53                   	push   %ebx
  800b59:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b5c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b61:	8b 55 08             	mov    0x8(%ebp),%edx
  800b64:	b8 03 00 00 00       	mov    $0x3,%eax
  800b69:	89 cb                	mov    %ecx,%ebx
  800b6b:	89 cf                	mov    %ecx,%edi
  800b6d:	89 ce                	mov    %ecx,%esi
  800b6f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b71:	85 c0                	test   %eax,%eax
  800b73:	7f 08                	jg     800b7d <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5f                   	pop    %edi
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7d:	83 ec 0c             	sub    $0xc,%esp
  800b80:	50                   	push   %eax
  800b81:	6a 03                	push   $0x3
  800b83:	68 5f 14 80 00       	push   $0x80145f
  800b88:	6a 23                	push   $0x23
  800b8a:	68 7c 14 80 00       	push   $0x80147c
  800b8f:	e8 fd 02 00 00       	call   800e91 <_panic>

00800b94 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b94:	f3 0f 1e fb          	endbr32 
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	57                   	push   %edi
  800b9c:	56                   	push   %esi
  800b9d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b9e:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba3:	b8 02 00 00 00       	mov    $0x2,%eax
  800ba8:	89 d1                	mov    %edx,%ecx
  800baa:	89 d3                	mov    %edx,%ebx
  800bac:	89 d7                	mov    %edx,%edi
  800bae:	89 d6                	mov    %edx,%esi
  800bb0:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bb2:	5b                   	pop    %ebx
  800bb3:	5e                   	pop    %esi
  800bb4:	5f                   	pop    %edi
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    

00800bb7 <sys_yield>:

void
sys_yield(void)
{
  800bb7:	f3 0f 1e fb          	endbr32 
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	57                   	push   %edi
  800bbf:	56                   	push   %esi
  800bc0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bc1:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bcb:	89 d1                	mov    %edx,%ecx
  800bcd:	89 d3                	mov    %edx,%ebx
  800bcf:	89 d7                	mov    %edx,%edi
  800bd1:	89 d6                	mov    %edx,%esi
  800bd3:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bd5:	5b                   	pop    %ebx
  800bd6:	5e                   	pop    %esi
  800bd7:	5f                   	pop    %edi
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    

00800bda <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bda:	f3 0f 1e fb          	endbr32 
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
  800be4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800be7:	be 00 00 00 00       	mov    $0x0,%esi
  800bec:	8b 55 08             	mov    0x8(%ebp),%edx
  800bef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf2:	b8 04 00 00 00       	mov    $0x4,%eax
  800bf7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bfa:	89 f7                	mov    %esi,%edi
  800bfc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bfe:	85 c0                	test   %eax,%eax
  800c00:	7f 08                	jg     800c0a <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c05:	5b                   	pop    %ebx
  800c06:	5e                   	pop    %esi
  800c07:	5f                   	pop    %edi
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0a:	83 ec 0c             	sub    $0xc,%esp
  800c0d:	50                   	push   %eax
  800c0e:	6a 04                	push   $0x4
  800c10:	68 5f 14 80 00       	push   $0x80145f
  800c15:	6a 23                	push   $0x23
  800c17:	68 7c 14 80 00       	push   $0x80147c
  800c1c:	e8 70 02 00 00       	call   800e91 <_panic>

00800c21 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c21:	f3 0f 1e fb          	endbr32 
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
  800c2b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c34:	b8 05 00 00 00       	mov    $0x5,%eax
  800c39:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c3c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c3f:	8b 75 18             	mov    0x18(%ebp),%esi
  800c42:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c44:	85 c0                	test   %eax,%eax
  800c46:	7f 08                	jg     800c50 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4b:	5b                   	pop    %ebx
  800c4c:	5e                   	pop    %esi
  800c4d:	5f                   	pop    %edi
  800c4e:	5d                   	pop    %ebp
  800c4f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c50:	83 ec 0c             	sub    $0xc,%esp
  800c53:	50                   	push   %eax
  800c54:	6a 05                	push   $0x5
  800c56:	68 5f 14 80 00       	push   $0x80145f
  800c5b:	6a 23                	push   $0x23
  800c5d:	68 7c 14 80 00       	push   $0x80147c
  800c62:	e8 2a 02 00 00       	call   800e91 <_panic>

00800c67 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c67:	f3 0f 1e fb          	endbr32 
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	57                   	push   %edi
  800c6f:	56                   	push   %esi
  800c70:	53                   	push   %ebx
  800c71:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c74:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c79:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7f:	b8 06 00 00 00       	mov    $0x6,%eax
  800c84:	89 df                	mov    %ebx,%edi
  800c86:	89 de                	mov    %ebx,%esi
  800c88:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c8a:	85 c0                	test   %eax,%eax
  800c8c:	7f 08                	jg     800c96 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c91:	5b                   	pop    %ebx
  800c92:	5e                   	pop    %esi
  800c93:	5f                   	pop    %edi
  800c94:	5d                   	pop    %ebp
  800c95:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c96:	83 ec 0c             	sub    $0xc,%esp
  800c99:	50                   	push   %eax
  800c9a:	6a 06                	push   $0x6
  800c9c:	68 5f 14 80 00       	push   $0x80145f
  800ca1:	6a 23                	push   $0x23
  800ca3:	68 7c 14 80 00       	push   $0x80147c
  800ca8:	e8 e4 01 00 00       	call   800e91 <_panic>

00800cad <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cad:	f3 0f 1e fb          	endbr32 
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	57                   	push   %edi
  800cb5:	56                   	push   %esi
  800cb6:	53                   	push   %ebx
  800cb7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cba:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc5:	b8 08 00 00 00       	mov    $0x8,%eax
  800cca:	89 df                	mov    %ebx,%edi
  800ccc:	89 de                	mov    %ebx,%esi
  800cce:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd0:	85 c0                	test   %eax,%eax
  800cd2:	7f 08                	jg     800cdc <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd7:	5b                   	pop    %ebx
  800cd8:	5e                   	pop    %esi
  800cd9:	5f                   	pop    %edi
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdc:	83 ec 0c             	sub    $0xc,%esp
  800cdf:	50                   	push   %eax
  800ce0:	6a 08                	push   $0x8
  800ce2:	68 5f 14 80 00       	push   $0x80145f
  800ce7:	6a 23                	push   $0x23
  800ce9:	68 7c 14 80 00       	push   $0x80147c
  800cee:	e8 9e 01 00 00       	call   800e91 <_panic>

00800cf3 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cf3:	f3 0f 1e fb          	endbr32 
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	57                   	push   %edi
  800cfb:	56                   	push   %esi
  800cfc:	53                   	push   %ebx
  800cfd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d00:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d05:	8b 55 08             	mov    0x8(%ebp),%edx
  800d08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0b:	b8 09 00 00 00       	mov    $0x9,%eax
  800d10:	89 df                	mov    %ebx,%edi
  800d12:	89 de                	mov    %ebx,%esi
  800d14:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d16:	85 c0                	test   %eax,%eax
  800d18:	7f 08                	jg     800d22 <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1d:	5b                   	pop    %ebx
  800d1e:	5e                   	pop    %esi
  800d1f:	5f                   	pop    %edi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d22:	83 ec 0c             	sub    $0xc,%esp
  800d25:	50                   	push   %eax
  800d26:	6a 09                	push   $0x9
  800d28:	68 5f 14 80 00       	push   $0x80145f
  800d2d:	6a 23                	push   $0x23
  800d2f:	68 7c 14 80 00       	push   $0x80147c
  800d34:	e8 58 01 00 00       	call   800e91 <_panic>

00800d39 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d39:	f3 0f 1e fb          	endbr32 
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	57                   	push   %edi
  800d41:	56                   	push   %esi
  800d42:	53                   	push   %ebx
  800d43:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d46:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d51:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d56:	89 df                	mov    %ebx,%edi
  800d58:	89 de                	mov    %ebx,%esi
  800d5a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d5c:	85 c0                	test   %eax,%eax
  800d5e:	7f 08                	jg     800d68 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d63:	5b                   	pop    %ebx
  800d64:	5e                   	pop    %esi
  800d65:	5f                   	pop    %edi
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d68:	83 ec 0c             	sub    $0xc,%esp
  800d6b:	50                   	push   %eax
  800d6c:	6a 0a                	push   $0xa
  800d6e:	68 5f 14 80 00       	push   $0x80145f
  800d73:	6a 23                	push   $0x23
  800d75:	68 7c 14 80 00       	push   $0x80147c
  800d7a:	e8 12 01 00 00       	call   800e91 <_panic>

00800d7f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d7f:	f3 0f 1e fb          	endbr32 
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
  800d86:	57                   	push   %edi
  800d87:	56                   	push   %esi
  800d88:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d89:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d94:	be 00 00 00 00       	mov    $0x0,%esi
  800d99:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d9f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800da1:	5b                   	pop    %ebx
  800da2:	5e                   	pop    %esi
  800da3:	5f                   	pop    %edi
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    

00800da6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800da6:	f3 0f 1e fb          	endbr32 
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	57                   	push   %edi
  800dae:	56                   	push   %esi
  800daf:	53                   	push   %ebx
  800db0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800db3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbb:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dc0:	89 cb                	mov    %ecx,%ebx
  800dc2:	89 cf                	mov    %ecx,%edi
  800dc4:	89 ce                	mov    %ecx,%esi
  800dc6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dc8:	85 c0                	test   %eax,%eax
  800dca:	7f 08                	jg     800dd4 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dcf:	5b                   	pop    %ebx
  800dd0:	5e                   	pop    %esi
  800dd1:	5f                   	pop    %edi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd4:	83 ec 0c             	sub    $0xc,%esp
  800dd7:	50                   	push   %eax
  800dd8:	6a 0d                	push   $0xd
  800dda:	68 5f 14 80 00       	push   $0x80145f
  800ddf:	6a 23                	push   $0x23
  800de1:	68 7c 14 80 00       	push   $0x80147c
  800de6:	e8 a6 00 00 00       	call   800e91 <_panic>

00800deb <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800deb:	f3 0f 1e fb          	endbr32 
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
  800df2:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800df5:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800dfc:	74 0a                	je     800e08 <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800dfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800e01:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800e06:	c9                   	leave  
  800e07:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  800e08:	83 ec 0c             	sub    $0xc,%esp
  800e0b:	68 8a 14 80 00       	push   $0x80148a
  800e10:	e8 7a f3 ff ff       	call   80018f <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  800e15:	83 c4 0c             	add    $0xc,%esp
  800e18:	6a 07                	push   $0x7
  800e1a:	68 00 f0 bf ee       	push   $0xeebff000
  800e1f:	6a 00                	push   $0x0
  800e21:	e8 b4 fd ff ff       	call   800bda <sys_page_alloc>
  800e26:	83 c4 10             	add    $0x10,%esp
  800e29:	85 c0                	test   %eax,%eax
  800e2b:	78 2a                	js     800e57 <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  800e2d:	83 ec 08             	sub    $0x8,%esp
  800e30:	68 6b 0e 80 00       	push   $0x800e6b
  800e35:	6a 00                	push   $0x0
  800e37:	e8 fd fe ff ff       	call   800d39 <sys_env_set_pgfault_upcall>
  800e3c:	83 c4 10             	add    $0x10,%esp
  800e3f:	85 c0                	test   %eax,%eax
  800e41:	79 bb                	jns    800dfe <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  800e43:	83 ec 04             	sub    $0x4,%esp
  800e46:	68 c8 14 80 00       	push   $0x8014c8
  800e4b:	6a 25                	push   $0x25
  800e4d:	68 b7 14 80 00       	push   $0x8014b7
  800e52:	e8 3a 00 00 00       	call   800e91 <_panic>
            panic("Allocation of UXSTACK failed!");
  800e57:	83 ec 04             	sub    $0x4,%esp
  800e5a:	68 99 14 80 00       	push   $0x801499
  800e5f:	6a 22                	push   $0x22
  800e61:	68 b7 14 80 00       	push   $0x8014b7
  800e66:	e8 26 00 00 00       	call   800e91 <_panic>

00800e6b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e6b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e6c:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800e71:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e73:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  800e76:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  800e7a:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  800e7e:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  800e81:	83 c4 08             	add    $0x8,%esp
    popa
  800e84:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

    add $0x4, %esp
  800e85:	83 c4 04             	add    $0x4,%esp
    popf
  800e88:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  800e89:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  800e8c:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  800e90:	c3                   	ret    

00800e91 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800e91:	f3 0f 1e fb          	endbr32 
  800e95:	55                   	push   %ebp
  800e96:	89 e5                	mov    %esp,%ebp
  800e98:	56                   	push   %esi
  800e99:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800e9a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800e9d:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800ea3:	e8 ec fc ff ff       	call   800b94 <sys_getenvid>
  800ea8:	83 ec 0c             	sub    $0xc,%esp
  800eab:	ff 75 0c             	pushl  0xc(%ebp)
  800eae:	ff 75 08             	pushl  0x8(%ebp)
  800eb1:	56                   	push   %esi
  800eb2:	50                   	push   %eax
  800eb3:	68 ec 14 80 00       	push   $0x8014ec
  800eb8:	e8 d2 f2 ff ff       	call   80018f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ebd:	83 c4 18             	add    $0x18,%esp
  800ec0:	53                   	push   %ebx
  800ec1:	ff 75 10             	pushl  0x10(%ebp)
  800ec4:	e8 71 f2 ff ff       	call   80013a <vcprintf>
	cprintf("\n");
  800ec9:	c7 04 24 97 14 80 00 	movl   $0x801497,(%esp)
  800ed0:	e8 ba f2 ff ff       	call   80018f <cprintf>
  800ed5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800ed8:	cc                   	int3   
  800ed9:	eb fd                	jmp    800ed8 <_panic+0x47>
  800edb:	66 90                	xchg   %ax,%ax
  800edd:	66 90                	xchg   %ax,%ax
  800edf:	90                   	nop

00800ee0 <__udivdi3>:
  800ee0:	f3 0f 1e fb          	endbr32 
  800ee4:	55                   	push   %ebp
  800ee5:	57                   	push   %edi
  800ee6:	56                   	push   %esi
  800ee7:	53                   	push   %ebx
  800ee8:	83 ec 1c             	sub    $0x1c,%esp
  800eeb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800eef:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800ef3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ef7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800efb:	85 d2                	test   %edx,%edx
  800efd:	75 19                	jne    800f18 <__udivdi3+0x38>
  800eff:	39 f3                	cmp    %esi,%ebx
  800f01:	76 4d                	jbe    800f50 <__udivdi3+0x70>
  800f03:	31 ff                	xor    %edi,%edi
  800f05:	89 e8                	mov    %ebp,%eax
  800f07:	89 f2                	mov    %esi,%edx
  800f09:	f7 f3                	div    %ebx
  800f0b:	89 fa                	mov    %edi,%edx
  800f0d:	83 c4 1c             	add    $0x1c,%esp
  800f10:	5b                   	pop    %ebx
  800f11:	5e                   	pop    %esi
  800f12:	5f                   	pop    %edi
  800f13:	5d                   	pop    %ebp
  800f14:	c3                   	ret    
  800f15:	8d 76 00             	lea    0x0(%esi),%esi
  800f18:	39 f2                	cmp    %esi,%edx
  800f1a:	76 14                	jbe    800f30 <__udivdi3+0x50>
  800f1c:	31 ff                	xor    %edi,%edi
  800f1e:	31 c0                	xor    %eax,%eax
  800f20:	89 fa                	mov    %edi,%edx
  800f22:	83 c4 1c             	add    $0x1c,%esp
  800f25:	5b                   	pop    %ebx
  800f26:	5e                   	pop    %esi
  800f27:	5f                   	pop    %edi
  800f28:	5d                   	pop    %ebp
  800f29:	c3                   	ret    
  800f2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f30:	0f bd fa             	bsr    %edx,%edi
  800f33:	83 f7 1f             	xor    $0x1f,%edi
  800f36:	75 48                	jne    800f80 <__udivdi3+0xa0>
  800f38:	39 f2                	cmp    %esi,%edx
  800f3a:	72 06                	jb     800f42 <__udivdi3+0x62>
  800f3c:	31 c0                	xor    %eax,%eax
  800f3e:	39 eb                	cmp    %ebp,%ebx
  800f40:	77 de                	ja     800f20 <__udivdi3+0x40>
  800f42:	b8 01 00 00 00       	mov    $0x1,%eax
  800f47:	eb d7                	jmp    800f20 <__udivdi3+0x40>
  800f49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f50:	89 d9                	mov    %ebx,%ecx
  800f52:	85 db                	test   %ebx,%ebx
  800f54:	75 0b                	jne    800f61 <__udivdi3+0x81>
  800f56:	b8 01 00 00 00       	mov    $0x1,%eax
  800f5b:	31 d2                	xor    %edx,%edx
  800f5d:	f7 f3                	div    %ebx
  800f5f:	89 c1                	mov    %eax,%ecx
  800f61:	31 d2                	xor    %edx,%edx
  800f63:	89 f0                	mov    %esi,%eax
  800f65:	f7 f1                	div    %ecx
  800f67:	89 c6                	mov    %eax,%esi
  800f69:	89 e8                	mov    %ebp,%eax
  800f6b:	89 f7                	mov    %esi,%edi
  800f6d:	f7 f1                	div    %ecx
  800f6f:	89 fa                	mov    %edi,%edx
  800f71:	83 c4 1c             	add    $0x1c,%esp
  800f74:	5b                   	pop    %ebx
  800f75:	5e                   	pop    %esi
  800f76:	5f                   	pop    %edi
  800f77:	5d                   	pop    %ebp
  800f78:	c3                   	ret    
  800f79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f80:	89 f9                	mov    %edi,%ecx
  800f82:	b8 20 00 00 00       	mov    $0x20,%eax
  800f87:	29 f8                	sub    %edi,%eax
  800f89:	d3 e2                	shl    %cl,%edx
  800f8b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f8f:	89 c1                	mov    %eax,%ecx
  800f91:	89 da                	mov    %ebx,%edx
  800f93:	d3 ea                	shr    %cl,%edx
  800f95:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800f99:	09 d1                	or     %edx,%ecx
  800f9b:	89 f2                	mov    %esi,%edx
  800f9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fa1:	89 f9                	mov    %edi,%ecx
  800fa3:	d3 e3                	shl    %cl,%ebx
  800fa5:	89 c1                	mov    %eax,%ecx
  800fa7:	d3 ea                	shr    %cl,%edx
  800fa9:	89 f9                	mov    %edi,%ecx
  800fab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800faf:	89 eb                	mov    %ebp,%ebx
  800fb1:	d3 e6                	shl    %cl,%esi
  800fb3:	89 c1                	mov    %eax,%ecx
  800fb5:	d3 eb                	shr    %cl,%ebx
  800fb7:	09 de                	or     %ebx,%esi
  800fb9:	89 f0                	mov    %esi,%eax
  800fbb:	f7 74 24 08          	divl   0x8(%esp)
  800fbf:	89 d6                	mov    %edx,%esi
  800fc1:	89 c3                	mov    %eax,%ebx
  800fc3:	f7 64 24 0c          	mull   0xc(%esp)
  800fc7:	39 d6                	cmp    %edx,%esi
  800fc9:	72 15                	jb     800fe0 <__udivdi3+0x100>
  800fcb:	89 f9                	mov    %edi,%ecx
  800fcd:	d3 e5                	shl    %cl,%ebp
  800fcf:	39 c5                	cmp    %eax,%ebp
  800fd1:	73 04                	jae    800fd7 <__udivdi3+0xf7>
  800fd3:	39 d6                	cmp    %edx,%esi
  800fd5:	74 09                	je     800fe0 <__udivdi3+0x100>
  800fd7:	89 d8                	mov    %ebx,%eax
  800fd9:	31 ff                	xor    %edi,%edi
  800fdb:	e9 40 ff ff ff       	jmp    800f20 <__udivdi3+0x40>
  800fe0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800fe3:	31 ff                	xor    %edi,%edi
  800fe5:	e9 36 ff ff ff       	jmp    800f20 <__udivdi3+0x40>
  800fea:	66 90                	xchg   %ax,%ax
  800fec:	66 90                	xchg   %ax,%ax
  800fee:	66 90                	xchg   %ax,%ax

00800ff0 <__umoddi3>:
  800ff0:	f3 0f 1e fb          	endbr32 
  800ff4:	55                   	push   %ebp
  800ff5:	57                   	push   %edi
  800ff6:	56                   	push   %esi
  800ff7:	53                   	push   %ebx
  800ff8:	83 ec 1c             	sub    $0x1c,%esp
  800ffb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800fff:	8b 74 24 30          	mov    0x30(%esp),%esi
  801003:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801007:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80100b:	85 c0                	test   %eax,%eax
  80100d:	75 19                	jne    801028 <__umoddi3+0x38>
  80100f:	39 df                	cmp    %ebx,%edi
  801011:	76 5d                	jbe    801070 <__umoddi3+0x80>
  801013:	89 f0                	mov    %esi,%eax
  801015:	89 da                	mov    %ebx,%edx
  801017:	f7 f7                	div    %edi
  801019:	89 d0                	mov    %edx,%eax
  80101b:	31 d2                	xor    %edx,%edx
  80101d:	83 c4 1c             	add    $0x1c,%esp
  801020:	5b                   	pop    %ebx
  801021:	5e                   	pop    %esi
  801022:	5f                   	pop    %edi
  801023:	5d                   	pop    %ebp
  801024:	c3                   	ret    
  801025:	8d 76 00             	lea    0x0(%esi),%esi
  801028:	89 f2                	mov    %esi,%edx
  80102a:	39 d8                	cmp    %ebx,%eax
  80102c:	76 12                	jbe    801040 <__umoddi3+0x50>
  80102e:	89 f0                	mov    %esi,%eax
  801030:	89 da                	mov    %ebx,%edx
  801032:	83 c4 1c             	add    $0x1c,%esp
  801035:	5b                   	pop    %ebx
  801036:	5e                   	pop    %esi
  801037:	5f                   	pop    %edi
  801038:	5d                   	pop    %ebp
  801039:	c3                   	ret    
  80103a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801040:	0f bd e8             	bsr    %eax,%ebp
  801043:	83 f5 1f             	xor    $0x1f,%ebp
  801046:	75 50                	jne    801098 <__umoddi3+0xa8>
  801048:	39 d8                	cmp    %ebx,%eax
  80104a:	0f 82 e0 00 00 00    	jb     801130 <__umoddi3+0x140>
  801050:	89 d9                	mov    %ebx,%ecx
  801052:	39 f7                	cmp    %esi,%edi
  801054:	0f 86 d6 00 00 00    	jbe    801130 <__umoddi3+0x140>
  80105a:	89 d0                	mov    %edx,%eax
  80105c:	89 ca                	mov    %ecx,%edx
  80105e:	83 c4 1c             	add    $0x1c,%esp
  801061:	5b                   	pop    %ebx
  801062:	5e                   	pop    %esi
  801063:	5f                   	pop    %edi
  801064:	5d                   	pop    %ebp
  801065:	c3                   	ret    
  801066:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80106d:	8d 76 00             	lea    0x0(%esi),%esi
  801070:	89 fd                	mov    %edi,%ebp
  801072:	85 ff                	test   %edi,%edi
  801074:	75 0b                	jne    801081 <__umoddi3+0x91>
  801076:	b8 01 00 00 00       	mov    $0x1,%eax
  80107b:	31 d2                	xor    %edx,%edx
  80107d:	f7 f7                	div    %edi
  80107f:	89 c5                	mov    %eax,%ebp
  801081:	89 d8                	mov    %ebx,%eax
  801083:	31 d2                	xor    %edx,%edx
  801085:	f7 f5                	div    %ebp
  801087:	89 f0                	mov    %esi,%eax
  801089:	f7 f5                	div    %ebp
  80108b:	89 d0                	mov    %edx,%eax
  80108d:	31 d2                	xor    %edx,%edx
  80108f:	eb 8c                	jmp    80101d <__umoddi3+0x2d>
  801091:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801098:	89 e9                	mov    %ebp,%ecx
  80109a:	ba 20 00 00 00       	mov    $0x20,%edx
  80109f:	29 ea                	sub    %ebp,%edx
  8010a1:	d3 e0                	shl    %cl,%eax
  8010a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010a7:	89 d1                	mov    %edx,%ecx
  8010a9:	89 f8                	mov    %edi,%eax
  8010ab:	d3 e8                	shr    %cl,%eax
  8010ad:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8010b1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010b5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8010b9:	09 c1                	or     %eax,%ecx
  8010bb:	89 d8                	mov    %ebx,%eax
  8010bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010c1:	89 e9                	mov    %ebp,%ecx
  8010c3:	d3 e7                	shl    %cl,%edi
  8010c5:	89 d1                	mov    %edx,%ecx
  8010c7:	d3 e8                	shr    %cl,%eax
  8010c9:	89 e9                	mov    %ebp,%ecx
  8010cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010cf:	d3 e3                	shl    %cl,%ebx
  8010d1:	89 c7                	mov    %eax,%edi
  8010d3:	89 d1                	mov    %edx,%ecx
  8010d5:	89 f0                	mov    %esi,%eax
  8010d7:	d3 e8                	shr    %cl,%eax
  8010d9:	89 e9                	mov    %ebp,%ecx
  8010db:	89 fa                	mov    %edi,%edx
  8010dd:	d3 e6                	shl    %cl,%esi
  8010df:	09 d8                	or     %ebx,%eax
  8010e1:	f7 74 24 08          	divl   0x8(%esp)
  8010e5:	89 d1                	mov    %edx,%ecx
  8010e7:	89 f3                	mov    %esi,%ebx
  8010e9:	f7 64 24 0c          	mull   0xc(%esp)
  8010ed:	89 c6                	mov    %eax,%esi
  8010ef:	89 d7                	mov    %edx,%edi
  8010f1:	39 d1                	cmp    %edx,%ecx
  8010f3:	72 06                	jb     8010fb <__umoddi3+0x10b>
  8010f5:	75 10                	jne    801107 <__umoddi3+0x117>
  8010f7:	39 c3                	cmp    %eax,%ebx
  8010f9:	73 0c                	jae    801107 <__umoddi3+0x117>
  8010fb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8010ff:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801103:	89 d7                	mov    %edx,%edi
  801105:	89 c6                	mov    %eax,%esi
  801107:	89 ca                	mov    %ecx,%edx
  801109:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80110e:	29 f3                	sub    %esi,%ebx
  801110:	19 fa                	sbb    %edi,%edx
  801112:	89 d0                	mov    %edx,%eax
  801114:	d3 e0                	shl    %cl,%eax
  801116:	89 e9                	mov    %ebp,%ecx
  801118:	d3 eb                	shr    %cl,%ebx
  80111a:	d3 ea                	shr    %cl,%edx
  80111c:	09 d8                	or     %ebx,%eax
  80111e:	83 c4 1c             	add    $0x1c,%esp
  801121:	5b                   	pop    %ebx
  801122:	5e                   	pop    %esi
  801123:	5f                   	pop    %edi
  801124:	5d                   	pop    %ebp
  801125:	c3                   	ret    
  801126:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80112d:	8d 76 00             	lea    0x0(%esi),%esi
  801130:	29 fe                	sub    %edi,%esi
  801132:	19 c3                	sbb    %eax,%ebx
  801134:	89 f2                	mov    %esi,%edx
  801136:	89 d9                	mov    %ebx,%ecx
  801138:	e9 1d ff ff ff       	jmp    80105a <__umoddi3+0x6a>
