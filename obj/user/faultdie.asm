
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
  800049:	68 00 11 80 00       	push   $0x801100
  80004e:	e8 32 01 00 00       	call   800185 <cprintf>
	sys_env_destroy(sys_getenvid());
  800053:	e8 32 0b 00 00       	call   800b8a <sys_getenvid>
  800058:	89 04 24             	mov    %eax,(%esp)
  80005b:	e8 e5 0a 00 00       	call   800b45 <sys_env_destroy>
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
  800074:	e8 22 0d 00 00       	call   800d9b <set_pgfault_handler>
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
    envid_t envid = sys_getenvid();
  800097:	e8 ee 0a 00 00       	call   800b8a <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  80009c:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000a1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000a4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000a9:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ae:	85 db                	test   %ebx,%ebx
  8000b0:	7e 07                	jle    8000b9 <libmain+0x31>
		binaryname = argv[0];
  8000b2:	8b 06                	mov    (%esi),%eax
  8000b4:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000b9:	83 ec 08             	sub    $0x8,%esp
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
  8000be:	e8 a2 ff ff ff       	call   800065 <umain>

	// exit gracefully
	exit();
  8000c3:	e8 0a 00 00 00       	call   8000d2 <exit>
}
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ce:	5b                   	pop    %ebx
  8000cf:	5e                   	pop    %esi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d2:	f3 0f 1e fb          	endbr32 
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000dc:	6a 00                	push   $0x0
  8000de:	e8 62 0a 00 00       	call   800b45 <sys_env_destroy>
}
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	c9                   	leave  
  8000e7:	c3                   	ret    

008000e8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e8:	f3 0f 1e fb          	endbr32 
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	53                   	push   %ebx
  8000f0:	83 ec 04             	sub    $0x4,%esp
  8000f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000f6:	8b 13                	mov    (%ebx),%edx
  8000f8:	8d 42 01             	lea    0x1(%edx),%eax
  8000fb:	89 03                	mov    %eax,(%ebx)
  8000fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800100:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800104:	3d ff 00 00 00       	cmp    $0xff,%eax
  800109:	74 09                	je     800114 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80010b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80010f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800112:	c9                   	leave  
  800113:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800114:	83 ec 08             	sub    $0x8,%esp
  800117:	68 ff 00 00 00       	push   $0xff
  80011c:	8d 43 08             	lea    0x8(%ebx),%eax
  80011f:	50                   	push   %eax
  800120:	e8 db 09 00 00       	call   800b00 <sys_cputs>
		b->idx = 0;
  800125:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80012b:	83 c4 10             	add    $0x10,%esp
  80012e:	eb db                	jmp    80010b <putch+0x23>

00800130 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800130:	f3 0f 1e fb          	endbr32 
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80013d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800144:	00 00 00 
	b.cnt = 0;
  800147:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80014e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800151:	ff 75 0c             	pushl  0xc(%ebp)
  800154:	ff 75 08             	pushl  0x8(%ebp)
  800157:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80015d:	50                   	push   %eax
  80015e:	68 e8 00 80 00       	push   $0x8000e8
  800163:	e8 20 01 00 00       	call   800288 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800168:	83 c4 08             	add    $0x8,%esp
  80016b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800171:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800177:	50                   	push   %eax
  800178:	e8 83 09 00 00       	call   800b00 <sys_cputs>

	return b.cnt;
}
  80017d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800183:	c9                   	leave  
  800184:	c3                   	ret    

00800185 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800185:	f3 0f 1e fb          	endbr32 
  800189:	55                   	push   %ebp
  80018a:	89 e5                	mov    %esp,%ebp
  80018c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80018f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800192:	50                   	push   %eax
  800193:	ff 75 08             	pushl  0x8(%ebp)
  800196:	e8 95 ff ff ff       	call   800130 <vcprintf>
	va_end(ap);

	return cnt;
}
  80019b:	c9                   	leave  
  80019c:	c3                   	ret    

0080019d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	57                   	push   %edi
  8001a1:	56                   	push   %esi
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 1c             	sub    $0x1c,%esp
  8001a6:	89 c7                	mov    %eax,%edi
  8001a8:	89 d6                	mov    %edx,%esi
  8001aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b0:	89 d1                	mov    %edx,%ecx
  8001b2:	89 c2                	mov    %eax,%edx
  8001b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001b7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8001bd:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001c3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001ca:	39 c2                	cmp    %eax,%edx
  8001cc:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001cf:	72 3e                	jb     80020f <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d1:	83 ec 0c             	sub    $0xc,%esp
  8001d4:	ff 75 18             	pushl  0x18(%ebp)
  8001d7:	83 eb 01             	sub    $0x1,%ebx
  8001da:	53                   	push   %ebx
  8001db:	50                   	push   %eax
  8001dc:	83 ec 08             	sub    $0x8,%esp
  8001df:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e2:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e5:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e8:	ff 75 d8             	pushl  -0x28(%ebp)
  8001eb:	e8 a0 0c 00 00       	call   800e90 <__udivdi3>
  8001f0:	83 c4 18             	add    $0x18,%esp
  8001f3:	52                   	push   %edx
  8001f4:	50                   	push   %eax
  8001f5:	89 f2                	mov    %esi,%edx
  8001f7:	89 f8                	mov    %edi,%eax
  8001f9:	e8 9f ff ff ff       	call   80019d <printnum>
  8001fe:	83 c4 20             	add    $0x20,%esp
  800201:	eb 13                	jmp    800216 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800203:	83 ec 08             	sub    $0x8,%esp
  800206:	56                   	push   %esi
  800207:	ff 75 18             	pushl  0x18(%ebp)
  80020a:	ff d7                	call   *%edi
  80020c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80020f:	83 eb 01             	sub    $0x1,%ebx
  800212:	85 db                	test   %ebx,%ebx
  800214:	7f ed                	jg     800203 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800216:	83 ec 08             	sub    $0x8,%esp
  800219:	56                   	push   %esi
  80021a:	83 ec 04             	sub    $0x4,%esp
  80021d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800220:	ff 75 e0             	pushl  -0x20(%ebp)
  800223:	ff 75 dc             	pushl  -0x24(%ebp)
  800226:	ff 75 d8             	pushl  -0x28(%ebp)
  800229:	e8 72 0d 00 00       	call   800fa0 <__umoddi3>
  80022e:	83 c4 14             	add    $0x14,%esp
  800231:	0f be 80 26 11 80 00 	movsbl 0x801126(%eax),%eax
  800238:	50                   	push   %eax
  800239:	ff d7                	call   *%edi
}
  80023b:	83 c4 10             	add    $0x10,%esp
  80023e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800241:	5b                   	pop    %ebx
  800242:	5e                   	pop    %esi
  800243:	5f                   	pop    %edi
  800244:	5d                   	pop    %ebp
  800245:	c3                   	ret    

00800246 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800246:	f3 0f 1e fb          	endbr32 
  80024a:	55                   	push   %ebp
  80024b:	89 e5                	mov    %esp,%ebp
  80024d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800250:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800254:	8b 10                	mov    (%eax),%edx
  800256:	3b 50 04             	cmp    0x4(%eax),%edx
  800259:	73 0a                	jae    800265 <sprintputch+0x1f>
		*b->buf++ = ch;
  80025b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80025e:	89 08                	mov    %ecx,(%eax)
  800260:	8b 45 08             	mov    0x8(%ebp),%eax
  800263:	88 02                	mov    %al,(%edx)
}
  800265:	5d                   	pop    %ebp
  800266:	c3                   	ret    

00800267 <printfmt>:
{
  800267:	f3 0f 1e fb          	endbr32 
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800271:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800274:	50                   	push   %eax
  800275:	ff 75 10             	pushl  0x10(%ebp)
  800278:	ff 75 0c             	pushl  0xc(%ebp)
  80027b:	ff 75 08             	pushl  0x8(%ebp)
  80027e:	e8 05 00 00 00       	call   800288 <vprintfmt>
}
  800283:	83 c4 10             	add    $0x10,%esp
  800286:	c9                   	leave  
  800287:	c3                   	ret    

00800288 <vprintfmt>:
{
  800288:	f3 0f 1e fb          	endbr32 
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	57                   	push   %edi
  800290:	56                   	push   %esi
  800291:	53                   	push   %ebx
  800292:	83 ec 3c             	sub    $0x3c,%esp
  800295:	8b 75 08             	mov    0x8(%ebp),%esi
  800298:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80029b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80029e:	e9 4a 03 00 00       	jmp    8005ed <vprintfmt+0x365>
		padc = ' ';
  8002a3:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002a7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002ae:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002b5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002bc:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002c1:	8d 47 01             	lea    0x1(%edi),%eax
  8002c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002c7:	0f b6 17             	movzbl (%edi),%edx
  8002ca:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002cd:	3c 55                	cmp    $0x55,%al
  8002cf:	0f 87 de 03 00 00    	ja     8006b3 <vprintfmt+0x42b>
  8002d5:	0f b6 c0             	movzbl %al,%eax
  8002d8:	3e ff 24 85 e0 11 80 	notrack jmp *0x8011e0(,%eax,4)
  8002df:	00 
  8002e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002e3:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002e7:	eb d8                	jmp    8002c1 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8002e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002ec:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002f0:	eb cf                	jmp    8002c1 <vprintfmt+0x39>
  8002f2:	0f b6 d2             	movzbl %dl,%edx
  8002f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8002fd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800300:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800303:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800307:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80030a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80030d:	83 f9 09             	cmp    $0x9,%ecx
  800310:	77 55                	ja     800367 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800312:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800315:	eb e9                	jmp    800300 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800317:	8b 45 14             	mov    0x14(%ebp),%eax
  80031a:	8b 00                	mov    (%eax),%eax
  80031c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80031f:	8b 45 14             	mov    0x14(%ebp),%eax
  800322:	8d 40 04             	lea    0x4(%eax),%eax
  800325:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80032b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80032f:	79 90                	jns    8002c1 <vprintfmt+0x39>
				width = precision, precision = -1;
  800331:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800334:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800337:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80033e:	eb 81                	jmp    8002c1 <vprintfmt+0x39>
  800340:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800343:	85 c0                	test   %eax,%eax
  800345:	ba 00 00 00 00       	mov    $0x0,%edx
  80034a:	0f 49 d0             	cmovns %eax,%edx
  80034d:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800350:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800353:	e9 69 ff ff ff       	jmp    8002c1 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800358:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80035b:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800362:	e9 5a ff ff ff       	jmp    8002c1 <vprintfmt+0x39>
  800367:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80036a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80036d:	eb bc                	jmp    80032b <vprintfmt+0xa3>
			lflag++;
  80036f:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800372:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800375:	e9 47 ff ff ff       	jmp    8002c1 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80037a:	8b 45 14             	mov    0x14(%ebp),%eax
  80037d:	8d 78 04             	lea    0x4(%eax),%edi
  800380:	83 ec 08             	sub    $0x8,%esp
  800383:	53                   	push   %ebx
  800384:	ff 30                	pushl  (%eax)
  800386:	ff d6                	call   *%esi
			break;
  800388:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80038b:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80038e:	e9 57 02 00 00       	jmp    8005ea <vprintfmt+0x362>
			err = va_arg(ap, int);
  800393:	8b 45 14             	mov    0x14(%ebp),%eax
  800396:	8d 78 04             	lea    0x4(%eax),%edi
  800399:	8b 00                	mov    (%eax),%eax
  80039b:	99                   	cltd   
  80039c:	31 d0                	xor    %edx,%eax
  80039e:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003a0:	83 f8 08             	cmp    $0x8,%eax
  8003a3:	7f 23                	jg     8003c8 <vprintfmt+0x140>
  8003a5:	8b 14 85 40 13 80 00 	mov    0x801340(,%eax,4),%edx
  8003ac:	85 d2                	test   %edx,%edx
  8003ae:	74 18                	je     8003c8 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8003b0:	52                   	push   %edx
  8003b1:	68 47 11 80 00       	push   $0x801147
  8003b6:	53                   	push   %ebx
  8003b7:	56                   	push   %esi
  8003b8:	e8 aa fe ff ff       	call   800267 <printfmt>
  8003bd:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003c0:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003c3:	e9 22 02 00 00       	jmp    8005ea <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8003c8:	50                   	push   %eax
  8003c9:	68 3e 11 80 00       	push   $0x80113e
  8003ce:	53                   	push   %ebx
  8003cf:	56                   	push   %esi
  8003d0:	e8 92 fe ff ff       	call   800267 <printfmt>
  8003d5:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003d8:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003db:	e9 0a 02 00 00       	jmp    8005ea <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8003e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e3:	83 c0 04             	add    $0x4,%eax
  8003e6:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ec:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003ee:	85 d2                	test   %edx,%edx
  8003f0:	b8 37 11 80 00       	mov    $0x801137,%eax
  8003f5:	0f 45 c2             	cmovne %edx,%eax
  8003f8:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003fb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ff:	7e 06                	jle    800407 <vprintfmt+0x17f>
  800401:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800405:	75 0d                	jne    800414 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800407:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80040a:	89 c7                	mov    %eax,%edi
  80040c:	03 45 e0             	add    -0x20(%ebp),%eax
  80040f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800412:	eb 55                	jmp    800469 <vprintfmt+0x1e1>
  800414:	83 ec 08             	sub    $0x8,%esp
  800417:	ff 75 d8             	pushl  -0x28(%ebp)
  80041a:	ff 75 cc             	pushl  -0x34(%ebp)
  80041d:	e8 45 03 00 00       	call   800767 <strnlen>
  800422:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800425:	29 c2                	sub    %eax,%edx
  800427:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80042a:	83 c4 10             	add    $0x10,%esp
  80042d:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80042f:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800433:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800436:	85 ff                	test   %edi,%edi
  800438:	7e 11                	jle    80044b <vprintfmt+0x1c3>
					putch(padc, putdat);
  80043a:	83 ec 08             	sub    $0x8,%esp
  80043d:	53                   	push   %ebx
  80043e:	ff 75 e0             	pushl  -0x20(%ebp)
  800441:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800443:	83 ef 01             	sub    $0x1,%edi
  800446:	83 c4 10             	add    $0x10,%esp
  800449:	eb eb                	jmp    800436 <vprintfmt+0x1ae>
  80044b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80044e:	85 d2                	test   %edx,%edx
  800450:	b8 00 00 00 00       	mov    $0x0,%eax
  800455:	0f 49 c2             	cmovns %edx,%eax
  800458:	29 c2                	sub    %eax,%edx
  80045a:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80045d:	eb a8                	jmp    800407 <vprintfmt+0x17f>
					putch(ch, putdat);
  80045f:	83 ec 08             	sub    $0x8,%esp
  800462:	53                   	push   %ebx
  800463:	52                   	push   %edx
  800464:	ff d6                	call   *%esi
  800466:	83 c4 10             	add    $0x10,%esp
  800469:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80046c:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80046e:	83 c7 01             	add    $0x1,%edi
  800471:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800475:	0f be d0             	movsbl %al,%edx
  800478:	85 d2                	test   %edx,%edx
  80047a:	74 4b                	je     8004c7 <vprintfmt+0x23f>
  80047c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800480:	78 06                	js     800488 <vprintfmt+0x200>
  800482:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800486:	78 1e                	js     8004a6 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800488:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80048c:	74 d1                	je     80045f <vprintfmt+0x1d7>
  80048e:	0f be c0             	movsbl %al,%eax
  800491:	83 e8 20             	sub    $0x20,%eax
  800494:	83 f8 5e             	cmp    $0x5e,%eax
  800497:	76 c6                	jbe    80045f <vprintfmt+0x1d7>
					putch('?', putdat);
  800499:	83 ec 08             	sub    $0x8,%esp
  80049c:	53                   	push   %ebx
  80049d:	6a 3f                	push   $0x3f
  80049f:	ff d6                	call   *%esi
  8004a1:	83 c4 10             	add    $0x10,%esp
  8004a4:	eb c3                	jmp    800469 <vprintfmt+0x1e1>
  8004a6:	89 cf                	mov    %ecx,%edi
  8004a8:	eb 0e                	jmp    8004b8 <vprintfmt+0x230>
				putch(' ', putdat);
  8004aa:	83 ec 08             	sub    $0x8,%esp
  8004ad:	53                   	push   %ebx
  8004ae:	6a 20                	push   $0x20
  8004b0:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004b2:	83 ef 01             	sub    $0x1,%edi
  8004b5:	83 c4 10             	add    $0x10,%esp
  8004b8:	85 ff                	test   %edi,%edi
  8004ba:	7f ee                	jg     8004aa <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8004bc:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004bf:	89 45 14             	mov    %eax,0x14(%ebp)
  8004c2:	e9 23 01 00 00       	jmp    8005ea <vprintfmt+0x362>
  8004c7:	89 cf                	mov    %ecx,%edi
  8004c9:	eb ed                	jmp    8004b8 <vprintfmt+0x230>
	if (lflag >= 2)
  8004cb:	83 f9 01             	cmp    $0x1,%ecx
  8004ce:	7f 1b                	jg     8004eb <vprintfmt+0x263>
	else if (lflag)
  8004d0:	85 c9                	test   %ecx,%ecx
  8004d2:	74 63                	je     800537 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8004d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d7:	8b 00                	mov    (%eax),%eax
  8004d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004dc:	99                   	cltd   
  8004dd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e3:	8d 40 04             	lea    0x4(%eax),%eax
  8004e6:	89 45 14             	mov    %eax,0x14(%ebp)
  8004e9:	eb 17                	jmp    800502 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8004eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ee:	8b 50 04             	mov    0x4(%eax),%edx
  8004f1:	8b 00                	mov    (%eax),%eax
  8004f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004f6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fc:	8d 40 08             	lea    0x8(%eax),%eax
  8004ff:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800502:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800505:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800508:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80050d:	85 c9                	test   %ecx,%ecx
  80050f:	0f 89 bb 00 00 00    	jns    8005d0 <vprintfmt+0x348>
				putch('-', putdat);
  800515:	83 ec 08             	sub    $0x8,%esp
  800518:	53                   	push   %ebx
  800519:	6a 2d                	push   $0x2d
  80051b:	ff d6                	call   *%esi
				num = -(long long) num;
  80051d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800520:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800523:	f7 da                	neg    %edx
  800525:	83 d1 00             	adc    $0x0,%ecx
  800528:	f7 d9                	neg    %ecx
  80052a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80052d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800532:	e9 99 00 00 00       	jmp    8005d0 <vprintfmt+0x348>
		return va_arg(*ap, int);
  800537:	8b 45 14             	mov    0x14(%ebp),%eax
  80053a:	8b 00                	mov    (%eax),%eax
  80053c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053f:	99                   	cltd   
  800540:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800543:	8b 45 14             	mov    0x14(%ebp),%eax
  800546:	8d 40 04             	lea    0x4(%eax),%eax
  800549:	89 45 14             	mov    %eax,0x14(%ebp)
  80054c:	eb b4                	jmp    800502 <vprintfmt+0x27a>
	if (lflag >= 2)
  80054e:	83 f9 01             	cmp    $0x1,%ecx
  800551:	7f 1b                	jg     80056e <vprintfmt+0x2e6>
	else if (lflag)
  800553:	85 c9                	test   %ecx,%ecx
  800555:	74 2c                	je     800583 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800557:	8b 45 14             	mov    0x14(%ebp),%eax
  80055a:	8b 10                	mov    (%eax),%edx
  80055c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800561:	8d 40 04             	lea    0x4(%eax),%eax
  800564:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800567:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80056c:	eb 62                	jmp    8005d0 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80056e:	8b 45 14             	mov    0x14(%ebp),%eax
  800571:	8b 10                	mov    (%eax),%edx
  800573:	8b 48 04             	mov    0x4(%eax),%ecx
  800576:	8d 40 08             	lea    0x8(%eax),%eax
  800579:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80057c:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800581:	eb 4d                	jmp    8005d0 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800583:	8b 45 14             	mov    0x14(%ebp),%eax
  800586:	8b 10                	mov    (%eax),%edx
  800588:	b9 00 00 00 00       	mov    $0x0,%ecx
  80058d:	8d 40 04             	lea    0x4(%eax),%eax
  800590:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800593:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800598:	eb 36                	jmp    8005d0 <vprintfmt+0x348>
	if (lflag >= 2)
  80059a:	83 f9 01             	cmp    $0x1,%ecx
  80059d:	7f 17                	jg     8005b6 <vprintfmt+0x32e>
	else if (lflag)
  80059f:	85 c9                	test   %ecx,%ecx
  8005a1:	74 6e                	je     800611 <vprintfmt+0x389>
		return va_arg(*ap, long);
  8005a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a6:	8b 10                	mov    (%eax),%edx
  8005a8:	89 d0                	mov    %edx,%eax
  8005aa:	99                   	cltd   
  8005ab:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005ae:	8d 49 04             	lea    0x4(%ecx),%ecx
  8005b1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005b4:	eb 11                	jmp    8005c7 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8b 50 04             	mov    0x4(%eax),%edx
  8005bc:	8b 00                	mov    (%eax),%eax
  8005be:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005c1:	8d 49 08             	lea    0x8(%ecx),%ecx
  8005c4:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8005c7:	89 d1                	mov    %edx,%ecx
  8005c9:	89 c2                	mov    %eax,%edx
            base = 8;
  8005cb:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005d0:	83 ec 0c             	sub    $0xc,%esp
  8005d3:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005d7:	57                   	push   %edi
  8005d8:	ff 75 e0             	pushl  -0x20(%ebp)
  8005db:	50                   	push   %eax
  8005dc:	51                   	push   %ecx
  8005dd:	52                   	push   %edx
  8005de:	89 da                	mov    %ebx,%edx
  8005e0:	89 f0                	mov    %esi,%eax
  8005e2:	e8 b6 fb ff ff       	call   80019d <printnum>
			break;
  8005e7:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8005ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005ed:	83 c7 01             	add    $0x1,%edi
  8005f0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005f4:	83 f8 25             	cmp    $0x25,%eax
  8005f7:	0f 84 a6 fc ff ff    	je     8002a3 <vprintfmt+0x1b>
			if (ch == '\0')
  8005fd:	85 c0                	test   %eax,%eax
  8005ff:	0f 84 ce 00 00 00    	je     8006d3 <vprintfmt+0x44b>
			putch(ch, putdat);
  800605:	83 ec 08             	sub    $0x8,%esp
  800608:	53                   	push   %ebx
  800609:	50                   	push   %eax
  80060a:	ff d6                	call   *%esi
  80060c:	83 c4 10             	add    $0x10,%esp
  80060f:	eb dc                	jmp    8005ed <vprintfmt+0x365>
		return va_arg(*ap, int);
  800611:	8b 45 14             	mov    0x14(%ebp),%eax
  800614:	8b 10                	mov    (%eax),%edx
  800616:	89 d0                	mov    %edx,%eax
  800618:	99                   	cltd   
  800619:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80061c:	8d 49 04             	lea    0x4(%ecx),%ecx
  80061f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800622:	eb a3                	jmp    8005c7 <vprintfmt+0x33f>
			putch('0', putdat);
  800624:	83 ec 08             	sub    $0x8,%esp
  800627:	53                   	push   %ebx
  800628:	6a 30                	push   $0x30
  80062a:	ff d6                	call   *%esi
			putch('x', putdat);
  80062c:	83 c4 08             	add    $0x8,%esp
  80062f:	53                   	push   %ebx
  800630:	6a 78                	push   $0x78
  800632:	ff d6                	call   *%esi
			num = (unsigned long long)
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8b 10                	mov    (%eax),%edx
  800639:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80063e:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800641:	8d 40 04             	lea    0x4(%eax),%eax
  800644:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800647:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80064c:	eb 82                	jmp    8005d0 <vprintfmt+0x348>
	if (lflag >= 2)
  80064e:	83 f9 01             	cmp    $0x1,%ecx
  800651:	7f 1e                	jg     800671 <vprintfmt+0x3e9>
	else if (lflag)
  800653:	85 c9                	test   %ecx,%ecx
  800655:	74 32                	je     800689 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8b 10                	mov    (%eax),%edx
  80065c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800661:	8d 40 04             	lea    0x4(%eax),%eax
  800664:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800667:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80066c:	e9 5f ff ff ff       	jmp    8005d0 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800671:	8b 45 14             	mov    0x14(%ebp),%eax
  800674:	8b 10                	mov    (%eax),%edx
  800676:	8b 48 04             	mov    0x4(%eax),%ecx
  800679:	8d 40 08             	lea    0x8(%eax),%eax
  80067c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80067f:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800684:	e9 47 ff ff ff       	jmp    8005d0 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800689:	8b 45 14             	mov    0x14(%ebp),%eax
  80068c:	8b 10                	mov    (%eax),%edx
  80068e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800693:	8d 40 04             	lea    0x4(%eax),%eax
  800696:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800699:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80069e:	e9 2d ff ff ff       	jmp    8005d0 <vprintfmt+0x348>
			putch(ch, putdat);
  8006a3:	83 ec 08             	sub    $0x8,%esp
  8006a6:	53                   	push   %ebx
  8006a7:	6a 25                	push   $0x25
  8006a9:	ff d6                	call   *%esi
			break;
  8006ab:	83 c4 10             	add    $0x10,%esp
  8006ae:	e9 37 ff ff ff       	jmp    8005ea <vprintfmt+0x362>
			putch('%', putdat);
  8006b3:	83 ec 08             	sub    $0x8,%esp
  8006b6:	53                   	push   %ebx
  8006b7:	6a 25                	push   $0x25
  8006b9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006bb:	83 c4 10             	add    $0x10,%esp
  8006be:	89 f8                	mov    %edi,%eax
  8006c0:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006c4:	74 05                	je     8006cb <vprintfmt+0x443>
  8006c6:	83 e8 01             	sub    $0x1,%eax
  8006c9:	eb f5                	jmp    8006c0 <vprintfmt+0x438>
  8006cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006ce:	e9 17 ff ff ff       	jmp    8005ea <vprintfmt+0x362>
}
  8006d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d6:	5b                   	pop    %ebx
  8006d7:	5e                   	pop    %esi
  8006d8:	5f                   	pop    %edi
  8006d9:	5d                   	pop    %ebp
  8006da:	c3                   	ret    

008006db <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006db:	f3 0f 1e fb          	endbr32 
  8006df:	55                   	push   %ebp
  8006e0:	89 e5                	mov    %esp,%ebp
  8006e2:	83 ec 18             	sub    $0x18,%esp
  8006e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ee:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006fc:	85 c0                	test   %eax,%eax
  8006fe:	74 26                	je     800726 <vsnprintf+0x4b>
  800700:	85 d2                	test   %edx,%edx
  800702:	7e 22                	jle    800726 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800704:	ff 75 14             	pushl  0x14(%ebp)
  800707:	ff 75 10             	pushl  0x10(%ebp)
  80070a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80070d:	50                   	push   %eax
  80070e:	68 46 02 80 00       	push   $0x800246
  800713:	e8 70 fb ff ff       	call   800288 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800718:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80071b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80071e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800721:	83 c4 10             	add    $0x10,%esp
}
  800724:	c9                   	leave  
  800725:	c3                   	ret    
		return -E_INVAL;
  800726:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80072b:	eb f7                	jmp    800724 <vsnprintf+0x49>

0080072d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80072d:	f3 0f 1e fb          	endbr32 
  800731:	55                   	push   %ebp
  800732:	89 e5                	mov    %esp,%ebp
  800734:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800737:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80073a:	50                   	push   %eax
  80073b:	ff 75 10             	pushl  0x10(%ebp)
  80073e:	ff 75 0c             	pushl  0xc(%ebp)
  800741:	ff 75 08             	pushl  0x8(%ebp)
  800744:	e8 92 ff ff ff       	call   8006db <vsnprintf>
	va_end(ap);

	return rc;
}
  800749:	c9                   	leave  
  80074a:	c3                   	ret    

0080074b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80074b:	f3 0f 1e fb          	endbr32 
  80074f:	55                   	push   %ebp
  800750:	89 e5                	mov    %esp,%ebp
  800752:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800755:	b8 00 00 00 00       	mov    $0x0,%eax
  80075a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80075e:	74 05                	je     800765 <strlen+0x1a>
		n++;
  800760:	83 c0 01             	add    $0x1,%eax
  800763:	eb f5                	jmp    80075a <strlen+0xf>
	return n;
}
  800765:	5d                   	pop    %ebp
  800766:	c3                   	ret    

00800767 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800767:	f3 0f 1e fb          	endbr32 
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800771:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800774:	b8 00 00 00 00       	mov    $0x0,%eax
  800779:	39 d0                	cmp    %edx,%eax
  80077b:	74 0d                	je     80078a <strnlen+0x23>
  80077d:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800781:	74 05                	je     800788 <strnlen+0x21>
		n++;
  800783:	83 c0 01             	add    $0x1,%eax
  800786:	eb f1                	jmp    800779 <strnlen+0x12>
  800788:	89 c2                	mov    %eax,%edx
	return n;
}
  80078a:	89 d0                	mov    %edx,%eax
  80078c:	5d                   	pop    %ebp
  80078d:	c3                   	ret    

0080078e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80078e:	f3 0f 1e fb          	endbr32 
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	53                   	push   %ebx
  800796:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800799:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80079c:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a1:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007a5:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007a8:	83 c0 01             	add    $0x1,%eax
  8007ab:	84 d2                	test   %dl,%dl
  8007ad:	75 f2                	jne    8007a1 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8007af:	89 c8                	mov    %ecx,%eax
  8007b1:	5b                   	pop    %ebx
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    

008007b4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b4:	f3 0f 1e fb          	endbr32 
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	53                   	push   %ebx
  8007bc:	83 ec 10             	sub    $0x10,%esp
  8007bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c2:	53                   	push   %ebx
  8007c3:	e8 83 ff ff ff       	call   80074b <strlen>
  8007c8:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007cb:	ff 75 0c             	pushl  0xc(%ebp)
  8007ce:	01 d8                	add    %ebx,%eax
  8007d0:	50                   	push   %eax
  8007d1:	e8 b8 ff ff ff       	call   80078e <strcpy>
	return dst;
}
  8007d6:	89 d8                	mov    %ebx,%eax
  8007d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007db:	c9                   	leave  
  8007dc:	c3                   	ret    

008007dd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007dd:	f3 0f 1e fb          	endbr32 
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	56                   	push   %esi
  8007e5:	53                   	push   %ebx
  8007e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ec:	89 f3                	mov    %esi,%ebx
  8007ee:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f1:	89 f0                	mov    %esi,%eax
  8007f3:	39 d8                	cmp    %ebx,%eax
  8007f5:	74 11                	je     800808 <strncpy+0x2b>
		*dst++ = *src;
  8007f7:	83 c0 01             	add    $0x1,%eax
  8007fa:	0f b6 0a             	movzbl (%edx),%ecx
  8007fd:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800800:	80 f9 01             	cmp    $0x1,%cl
  800803:	83 da ff             	sbb    $0xffffffff,%edx
  800806:	eb eb                	jmp    8007f3 <strncpy+0x16>
	}
	return ret;
}
  800808:	89 f0                	mov    %esi,%eax
  80080a:	5b                   	pop    %ebx
  80080b:	5e                   	pop    %esi
  80080c:	5d                   	pop    %ebp
  80080d:	c3                   	ret    

0080080e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80080e:	f3 0f 1e fb          	endbr32 
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	56                   	push   %esi
  800816:	53                   	push   %ebx
  800817:	8b 75 08             	mov    0x8(%ebp),%esi
  80081a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80081d:	8b 55 10             	mov    0x10(%ebp),%edx
  800820:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800822:	85 d2                	test   %edx,%edx
  800824:	74 21                	je     800847 <strlcpy+0x39>
  800826:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80082a:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80082c:	39 c2                	cmp    %eax,%edx
  80082e:	74 14                	je     800844 <strlcpy+0x36>
  800830:	0f b6 19             	movzbl (%ecx),%ebx
  800833:	84 db                	test   %bl,%bl
  800835:	74 0b                	je     800842 <strlcpy+0x34>
			*dst++ = *src++;
  800837:	83 c1 01             	add    $0x1,%ecx
  80083a:	83 c2 01             	add    $0x1,%edx
  80083d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800840:	eb ea                	jmp    80082c <strlcpy+0x1e>
  800842:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800844:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800847:	29 f0                	sub    %esi,%eax
}
  800849:	5b                   	pop    %ebx
  80084a:	5e                   	pop    %esi
  80084b:	5d                   	pop    %ebp
  80084c:	c3                   	ret    

0080084d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80084d:	f3 0f 1e fb          	endbr32 
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800857:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80085a:	0f b6 01             	movzbl (%ecx),%eax
  80085d:	84 c0                	test   %al,%al
  80085f:	74 0c                	je     80086d <strcmp+0x20>
  800861:	3a 02                	cmp    (%edx),%al
  800863:	75 08                	jne    80086d <strcmp+0x20>
		p++, q++;
  800865:	83 c1 01             	add    $0x1,%ecx
  800868:	83 c2 01             	add    $0x1,%edx
  80086b:	eb ed                	jmp    80085a <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80086d:	0f b6 c0             	movzbl %al,%eax
  800870:	0f b6 12             	movzbl (%edx),%edx
  800873:	29 d0                	sub    %edx,%eax
}
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800877:	f3 0f 1e fb          	endbr32 
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	53                   	push   %ebx
  80087f:	8b 45 08             	mov    0x8(%ebp),%eax
  800882:	8b 55 0c             	mov    0xc(%ebp),%edx
  800885:	89 c3                	mov    %eax,%ebx
  800887:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80088a:	eb 06                	jmp    800892 <strncmp+0x1b>
		n--, p++, q++;
  80088c:	83 c0 01             	add    $0x1,%eax
  80088f:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800892:	39 d8                	cmp    %ebx,%eax
  800894:	74 16                	je     8008ac <strncmp+0x35>
  800896:	0f b6 08             	movzbl (%eax),%ecx
  800899:	84 c9                	test   %cl,%cl
  80089b:	74 04                	je     8008a1 <strncmp+0x2a>
  80089d:	3a 0a                	cmp    (%edx),%cl
  80089f:	74 eb                	je     80088c <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a1:	0f b6 00             	movzbl (%eax),%eax
  8008a4:	0f b6 12             	movzbl (%edx),%edx
  8008a7:	29 d0                	sub    %edx,%eax
}
  8008a9:	5b                   	pop    %ebx
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    
		return 0;
  8008ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b1:	eb f6                	jmp    8008a9 <strncmp+0x32>

008008b3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b3:	f3 0f 1e fb          	endbr32 
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c1:	0f b6 10             	movzbl (%eax),%edx
  8008c4:	84 d2                	test   %dl,%dl
  8008c6:	74 09                	je     8008d1 <strchr+0x1e>
		if (*s == c)
  8008c8:	38 ca                	cmp    %cl,%dl
  8008ca:	74 0a                	je     8008d6 <strchr+0x23>
	for (; *s; s++)
  8008cc:	83 c0 01             	add    $0x1,%eax
  8008cf:	eb f0                	jmp    8008c1 <strchr+0xe>
			return (char *) s;
	return 0;
  8008d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d6:	5d                   	pop    %ebp
  8008d7:	c3                   	ret    

008008d8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008d8:	f3 0f 1e fb          	endbr32 
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008e9:	38 ca                	cmp    %cl,%dl
  8008eb:	74 09                	je     8008f6 <strfind+0x1e>
  8008ed:	84 d2                	test   %dl,%dl
  8008ef:	74 05                	je     8008f6 <strfind+0x1e>
	for (; *s; s++)
  8008f1:	83 c0 01             	add    $0x1,%eax
  8008f4:	eb f0                	jmp    8008e6 <strfind+0xe>
			break;
	return (char *) s;
}
  8008f6:	5d                   	pop    %ebp
  8008f7:	c3                   	ret    

008008f8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f8:	f3 0f 1e fb          	endbr32 
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	57                   	push   %edi
  800900:	56                   	push   %esi
  800901:	53                   	push   %ebx
  800902:	8b 7d 08             	mov    0x8(%ebp),%edi
  800905:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800908:	85 c9                	test   %ecx,%ecx
  80090a:	74 31                	je     80093d <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090c:	89 f8                	mov    %edi,%eax
  80090e:	09 c8                	or     %ecx,%eax
  800910:	a8 03                	test   $0x3,%al
  800912:	75 23                	jne    800937 <memset+0x3f>
		c &= 0xFF;
  800914:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800918:	89 d3                	mov    %edx,%ebx
  80091a:	c1 e3 08             	shl    $0x8,%ebx
  80091d:	89 d0                	mov    %edx,%eax
  80091f:	c1 e0 18             	shl    $0x18,%eax
  800922:	89 d6                	mov    %edx,%esi
  800924:	c1 e6 10             	shl    $0x10,%esi
  800927:	09 f0                	or     %esi,%eax
  800929:	09 c2                	or     %eax,%edx
  80092b:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80092d:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800930:	89 d0                	mov    %edx,%eax
  800932:	fc                   	cld    
  800933:	f3 ab                	rep stos %eax,%es:(%edi)
  800935:	eb 06                	jmp    80093d <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800937:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093a:	fc                   	cld    
  80093b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80093d:	89 f8                	mov    %edi,%eax
  80093f:	5b                   	pop    %ebx
  800940:	5e                   	pop    %esi
  800941:	5f                   	pop    %edi
  800942:	5d                   	pop    %ebp
  800943:	c3                   	ret    

00800944 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800944:	f3 0f 1e fb          	endbr32 
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	57                   	push   %edi
  80094c:	56                   	push   %esi
  80094d:	8b 45 08             	mov    0x8(%ebp),%eax
  800950:	8b 75 0c             	mov    0xc(%ebp),%esi
  800953:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800956:	39 c6                	cmp    %eax,%esi
  800958:	73 32                	jae    80098c <memmove+0x48>
  80095a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80095d:	39 c2                	cmp    %eax,%edx
  80095f:	76 2b                	jbe    80098c <memmove+0x48>
		s += n;
		d += n;
  800961:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800964:	89 fe                	mov    %edi,%esi
  800966:	09 ce                	or     %ecx,%esi
  800968:	09 d6                	or     %edx,%esi
  80096a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800970:	75 0e                	jne    800980 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800972:	83 ef 04             	sub    $0x4,%edi
  800975:	8d 72 fc             	lea    -0x4(%edx),%esi
  800978:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80097b:	fd                   	std    
  80097c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80097e:	eb 09                	jmp    800989 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800980:	83 ef 01             	sub    $0x1,%edi
  800983:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800986:	fd                   	std    
  800987:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800989:	fc                   	cld    
  80098a:	eb 1a                	jmp    8009a6 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098c:	89 c2                	mov    %eax,%edx
  80098e:	09 ca                	or     %ecx,%edx
  800990:	09 f2                	or     %esi,%edx
  800992:	f6 c2 03             	test   $0x3,%dl
  800995:	75 0a                	jne    8009a1 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800997:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80099a:	89 c7                	mov    %eax,%edi
  80099c:	fc                   	cld    
  80099d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099f:	eb 05                	jmp    8009a6 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8009a1:	89 c7                	mov    %eax,%edi
  8009a3:	fc                   	cld    
  8009a4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a6:	5e                   	pop    %esi
  8009a7:	5f                   	pop    %edi
  8009a8:	5d                   	pop    %ebp
  8009a9:	c3                   	ret    

008009aa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009aa:	f3 0f 1e fb          	endbr32 
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009b4:	ff 75 10             	pushl  0x10(%ebp)
  8009b7:	ff 75 0c             	pushl  0xc(%ebp)
  8009ba:	ff 75 08             	pushl  0x8(%ebp)
  8009bd:	e8 82 ff ff ff       	call   800944 <memmove>
}
  8009c2:	c9                   	leave  
  8009c3:	c3                   	ret    

008009c4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c4:	f3 0f 1e fb          	endbr32 
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	56                   	push   %esi
  8009cc:	53                   	push   %ebx
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d3:	89 c6                	mov    %eax,%esi
  8009d5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d8:	39 f0                	cmp    %esi,%eax
  8009da:	74 1c                	je     8009f8 <memcmp+0x34>
		if (*s1 != *s2)
  8009dc:	0f b6 08             	movzbl (%eax),%ecx
  8009df:	0f b6 1a             	movzbl (%edx),%ebx
  8009e2:	38 d9                	cmp    %bl,%cl
  8009e4:	75 08                	jne    8009ee <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009e6:	83 c0 01             	add    $0x1,%eax
  8009e9:	83 c2 01             	add    $0x1,%edx
  8009ec:	eb ea                	jmp    8009d8 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  8009ee:	0f b6 c1             	movzbl %cl,%eax
  8009f1:	0f b6 db             	movzbl %bl,%ebx
  8009f4:	29 d8                	sub    %ebx,%eax
  8009f6:	eb 05                	jmp    8009fd <memcmp+0x39>
	}

	return 0;
  8009f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009fd:	5b                   	pop    %ebx
  8009fe:	5e                   	pop    %esi
  8009ff:	5d                   	pop    %ebp
  800a00:	c3                   	ret    

00800a01 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a01:	f3 0f 1e fb          	endbr32 
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a0e:	89 c2                	mov    %eax,%edx
  800a10:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a13:	39 d0                	cmp    %edx,%eax
  800a15:	73 09                	jae    800a20 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a17:	38 08                	cmp    %cl,(%eax)
  800a19:	74 05                	je     800a20 <memfind+0x1f>
	for (; s < ends; s++)
  800a1b:	83 c0 01             	add    $0x1,%eax
  800a1e:	eb f3                	jmp    800a13 <memfind+0x12>
			break;
	return (void *) s;
}
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a22:	f3 0f 1e fb          	endbr32 
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	57                   	push   %edi
  800a2a:	56                   	push   %esi
  800a2b:	53                   	push   %ebx
  800a2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a32:	eb 03                	jmp    800a37 <strtol+0x15>
		s++;
  800a34:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a37:	0f b6 01             	movzbl (%ecx),%eax
  800a3a:	3c 20                	cmp    $0x20,%al
  800a3c:	74 f6                	je     800a34 <strtol+0x12>
  800a3e:	3c 09                	cmp    $0x9,%al
  800a40:	74 f2                	je     800a34 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a42:	3c 2b                	cmp    $0x2b,%al
  800a44:	74 2a                	je     800a70 <strtol+0x4e>
	int neg = 0;
  800a46:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a4b:	3c 2d                	cmp    $0x2d,%al
  800a4d:	74 2b                	je     800a7a <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a4f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a55:	75 0f                	jne    800a66 <strtol+0x44>
  800a57:	80 39 30             	cmpb   $0x30,(%ecx)
  800a5a:	74 28                	je     800a84 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a5c:	85 db                	test   %ebx,%ebx
  800a5e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a63:	0f 44 d8             	cmove  %eax,%ebx
  800a66:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a6e:	eb 46                	jmp    800ab6 <strtol+0x94>
		s++;
  800a70:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a73:	bf 00 00 00 00       	mov    $0x0,%edi
  800a78:	eb d5                	jmp    800a4f <strtol+0x2d>
		s++, neg = 1;
  800a7a:	83 c1 01             	add    $0x1,%ecx
  800a7d:	bf 01 00 00 00       	mov    $0x1,%edi
  800a82:	eb cb                	jmp    800a4f <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a84:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a88:	74 0e                	je     800a98 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a8a:	85 db                	test   %ebx,%ebx
  800a8c:	75 d8                	jne    800a66 <strtol+0x44>
		s++, base = 8;
  800a8e:	83 c1 01             	add    $0x1,%ecx
  800a91:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a96:	eb ce                	jmp    800a66 <strtol+0x44>
		s += 2, base = 16;
  800a98:	83 c1 02             	add    $0x2,%ecx
  800a9b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa0:	eb c4                	jmp    800a66 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800aa2:	0f be d2             	movsbl %dl,%edx
  800aa5:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aa8:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aab:	7d 3a                	jge    800ae7 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800aad:	83 c1 01             	add    $0x1,%ecx
  800ab0:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ab4:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ab6:	0f b6 11             	movzbl (%ecx),%edx
  800ab9:	8d 72 d0             	lea    -0x30(%edx),%esi
  800abc:	89 f3                	mov    %esi,%ebx
  800abe:	80 fb 09             	cmp    $0x9,%bl
  800ac1:	76 df                	jbe    800aa2 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800ac3:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ac6:	89 f3                	mov    %esi,%ebx
  800ac8:	80 fb 19             	cmp    $0x19,%bl
  800acb:	77 08                	ja     800ad5 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800acd:	0f be d2             	movsbl %dl,%edx
  800ad0:	83 ea 57             	sub    $0x57,%edx
  800ad3:	eb d3                	jmp    800aa8 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800ad5:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ad8:	89 f3                	mov    %esi,%ebx
  800ada:	80 fb 19             	cmp    $0x19,%bl
  800add:	77 08                	ja     800ae7 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800adf:	0f be d2             	movsbl %dl,%edx
  800ae2:	83 ea 37             	sub    $0x37,%edx
  800ae5:	eb c1                	jmp    800aa8 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ae7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aeb:	74 05                	je     800af2 <strtol+0xd0>
		*endptr = (char *) s;
  800aed:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af0:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800af2:	89 c2                	mov    %eax,%edx
  800af4:	f7 da                	neg    %edx
  800af6:	85 ff                	test   %edi,%edi
  800af8:	0f 45 c2             	cmovne %edx,%eax
}
  800afb:	5b                   	pop    %ebx
  800afc:	5e                   	pop    %esi
  800afd:	5f                   	pop    %edi
  800afe:	5d                   	pop    %ebp
  800aff:	c3                   	ret    

00800b00 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b00:	f3 0f 1e fb          	endbr32 
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	57                   	push   %edi
  800b08:	56                   	push   %esi
  800b09:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b0a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b15:	89 c3                	mov    %eax,%ebx
  800b17:	89 c7                	mov    %eax,%edi
  800b19:	89 c6                	mov    %eax,%esi
  800b1b:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b1d:	5b                   	pop    %ebx
  800b1e:	5e                   	pop    %esi
  800b1f:	5f                   	pop    %edi
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    

00800b22 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b22:	f3 0f 1e fb          	endbr32 
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	57                   	push   %edi
  800b2a:	56                   	push   %esi
  800b2b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b31:	b8 01 00 00 00       	mov    $0x1,%eax
  800b36:	89 d1                	mov    %edx,%ecx
  800b38:	89 d3                	mov    %edx,%ebx
  800b3a:	89 d7                	mov    %edx,%edi
  800b3c:	89 d6                	mov    %edx,%esi
  800b3e:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b40:	5b                   	pop    %ebx
  800b41:	5e                   	pop    %esi
  800b42:	5f                   	pop    %edi
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b45:	f3 0f 1e fb          	endbr32 
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	57                   	push   %edi
  800b4d:	56                   	push   %esi
  800b4e:	53                   	push   %ebx
  800b4f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b52:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b57:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b5f:	89 cb                	mov    %ecx,%ebx
  800b61:	89 cf                	mov    %ecx,%edi
  800b63:	89 ce                	mov    %ecx,%esi
  800b65:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b67:	85 c0                	test   %eax,%eax
  800b69:	7f 08                	jg     800b73 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6e:	5b                   	pop    %ebx
  800b6f:	5e                   	pop    %esi
  800b70:	5f                   	pop    %edi
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b73:	83 ec 0c             	sub    $0xc,%esp
  800b76:	50                   	push   %eax
  800b77:	6a 03                	push   $0x3
  800b79:	68 64 13 80 00       	push   $0x801364
  800b7e:	6a 23                	push   $0x23
  800b80:	68 81 13 80 00       	push   $0x801381
  800b85:	e8 b7 02 00 00       	call   800e41 <_panic>

00800b8a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b8a:	f3 0f 1e fb          	endbr32 
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	57                   	push   %edi
  800b92:	56                   	push   %esi
  800b93:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b94:	ba 00 00 00 00       	mov    $0x0,%edx
  800b99:	b8 02 00 00 00       	mov    $0x2,%eax
  800b9e:	89 d1                	mov    %edx,%ecx
  800ba0:	89 d3                	mov    %edx,%ebx
  800ba2:	89 d7                	mov    %edx,%edi
  800ba4:	89 d6                	mov    %edx,%esi
  800ba6:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ba8:	5b                   	pop    %ebx
  800ba9:	5e                   	pop    %esi
  800baa:	5f                   	pop    %edi
  800bab:	5d                   	pop    %ebp
  800bac:	c3                   	ret    

00800bad <sys_yield>:

void
sys_yield(void)
{
  800bad:	f3 0f 1e fb          	endbr32 
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	57                   	push   %edi
  800bb5:	56                   	push   %esi
  800bb6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bc1:	89 d1                	mov    %edx,%ecx
  800bc3:	89 d3                	mov    %edx,%ebx
  800bc5:	89 d7                	mov    %edx,%edi
  800bc7:	89 d6                	mov    %edx,%esi
  800bc9:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bcb:	5b                   	pop    %ebx
  800bcc:	5e                   	pop    %esi
  800bcd:	5f                   	pop    %edi
  800bce:	5d                   	pop    %ebp
  800bcf:	c3                   	ret    

00800bd0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bd0:	f3 0f 1e fb          	endbr32 
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	57                   	push   %edi
  800bd8:	56                   	push   %esi
  800bd9:	53                   	push   %ebx
  800bda:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bdd:	be 00 00 00 00       	mov    $0x0,%esi
  800be2:	8b 55 08             	mov    0x8(%ebp),%edx
  800be5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be8:	b8 04 00 00 00       	mov    $0x4,%eax
  800bed:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf0:	89 f7                	mov    %esi,%edi
  800bf2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bf4:	85 c0                	test   %eax,%eax
  800bf6:	7f 08                	jg     800c00 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfb:	5b                   	pop    %ebx
  800bfc:	5e                   	pop    %esi
  800bfd:	5f                   	pop    %edi
  800bfe:	5d                   	pop    %ebp
  800bff:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c00:	83 ec 0c             	sub    $0xc,%esp
  800c03:	50                   	push   %eax
  800c04:	6a 04                	push   $0x4
  800c06:	68 64 13 80 00       	push   $0x801364
  800c0b:	6a 23                	push   $0x23
  800c0d:	68 81 13 80 00       	push   $0x801381
  800c12:	e8 2a 02 00 00       	call   800e41 <_panic>

00800c17 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c17:	f3 0f 1e fb          	endbr32 
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	57                   	push   %edi
  800c1f:	56                   	push   %esi
  800c20:	53                   	push   %ebx
  800c21:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c24:	8b 55 08             	mov    0x8(%ebp),%edx
  800c27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c32:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c35:	8b 75 18             	mov    0x18(%ebp),%esi
  800c38:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c3a:	85 c0                	test   %eax,%eax
  800c3c:	7f 08                	jg     800c46 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c46:	83 ec 0c             	sub    $0xc,%esp
  800c49:	50                   	push   %eax
  800c4a:	6a 05                	push   $0x5
  800c4c:	68 64 13 80 00       	push   $0x801364
  800c51:	6a 23                	push   $0x23
  800c53:	68 81 13 80 00       	push   $0x801381
  800c58:	e8 e4 01 00 00       	call   800e41 <_panic>

00800c5d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c5d:	f3 0f 1e fb          	endbr32 
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	57                   	push   %edi
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
  800c67:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c6a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c75:	b8 06 00 00 00       	mov    $0x6,%eax
  800c7a:	89 df                	mov    %ebx,%edi
  800c7c:	89 de                	mov    %ebx,%esi
  800c7e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c80:	85 c0                	test   %eax,%eax
  800c82:	7f 08                	jg     800c8c <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c87:	5b                   	pop    %ebx
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8c:	83 ec 0c             	sub    $0xc,%esp
  800c8f:	50                   	push   %eax
  800c90:	6a 06                	push   $0x6
  800c92:	68 64 13 80 00       	push   $0x801364
  800c97:	6a 23                	push   $0x23
  800c99:	68 81 13 80 00       	push   $0x801381
  800c9e:	e8 9e 01 00 00       	call   800e41 <_panic>

00800ca3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ca3:	f3 0f 1e fb          	endbr32 
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	57                   	push   %edi
  800cab:	56                   	push   %esi
  800cac:	53                   	push   %ebx
  800cad:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cb0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbb:	b8 08 00 00 00       	mov    $0x8,%eax
  800cc0:	89 df                	mov    %ebx,%edi
  800cc2:	89 de                	mov    %ebx,%esi
  800cc4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cc6:	85 c0                	test   %eax,%eax
  800cc8:	7f 08                	jg     800cd2 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccd:	5b                   	pop    %ebx
  800cce:	5e                   	pop    %esi
  800ccf:	5f                   	pop    %edi
  800cd0:	5d                   	pop    %ebp
  800cd1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd2:	83 ec 0c             	sub    $0xc,%esp
  800cd5:	50                   	push   %eax
  800cd6:	6a 08                	push   $0x8
  800cd8:	68 64 13 80 00       	push   $0x801364
  800cdd:	6a 23                	push   $0x23
  800cdf:	68 81 13 80 00       	push   $0x801381
  800ce4:	e8 58 01 00 00       	call   800e41 <_panic>

00800ce9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ce9:	f3 0f 1e fb          	endbr32 
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
  800cf0:	57                   	push   %edi
  800cf1:	56                   	push   %esi
  800cf2:	53                   	push   %ebx
  800cf3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cf6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d01:	b8 09 00 00 00       	mov    $0x9,%eax
  800d06:	89 df                	mov    %ebx,%edi
  800d08:	89 de                	mov    %ebx,%esi
  800d0a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d0c:	85 c0                	test   %eax,%eax
  800d0e:	7f 08                	jg     800d18 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d13:	5b                   	pop    %ebx
  800d14:	5e                   	pop    %esi
  800d15:	5f                   	pop    %edi
  800d16:	5d                   	pop    %ebp
  800d17:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d18:	83 ec 0c             	sub    $0xc,%esp
  800d1b:	50                   	push   %eax
  800d1c:	6a 09                	push   $0x9
  800d1e:	68 64 13 80 00       	push   $0x801364
  800d23:	6a 23                	push   $0x23
  800d25:	68 81 13 80 00       	push   $0x801381
  800d2a:	e8 12 01 00 00       	call   800e41 <_panic>

00800d2f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d2f:	f3 0f 1e fb          	endbr32 
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	57                   	push   %edi
  800d37:	56                   	push   %esi
  800d38:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d39:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d44:	be 00 00 00 00       	mov    $0x0,%esi
  800d49:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d4c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d4f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d51:	5b                   	pop    %ebx
  800d52:	5e                   	pop    %esi
  800d53:	5f                   	pop    %edi
  800d54:	5d                   	pop    %ebp
  800d55:	c3                   	ret    

00800d56 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d56:	f3 0f 1e fb          	endbr32 
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	57                   	push   %edi
  800d5e:	56                   	push   %esi
  800d5f:	53                   	push   %ebx
  800d60:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d63:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d68:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d70:	89 cb                	mov    %ecx,%ebx
  800d72:	89 cf                	mov    %ecx,%edi
  800d74:	89 ce                	mov    %ecx,%esi
  800d76:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d78:	85 c0                	test   %eax,%eax
  800d7a:	7f 08                	jg     800d84 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7f:	5b                   	pop    %ebx
  800d80:	5e                   	pop    %esi
  800d81:	5f                   	pop    %edi
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d84:	83 ec 0c             	sub    $0xc,%esp
  800d87:	50                   	push   %eax
  800d88:	6a 0c                	push   $0xc
  800d8a:	68 64 13 80 00       	push   $0x801364
  800d8f:	6a 23                	push   $0x23
  800d91:	68 81 13 80 00       	push   $0x801381
  800d96:	e8 a6 00 00 00       	call   800e41 <_panic>

00800d9b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d9b:	f3 0f 1e fb          	endbr32 
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800da5:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800dac:	74 0a                	je     800db8 <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800dae:	8b 45 08             	mov    0x8(%ebp),%eax
  800db1:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800db6:	c9                   	leave  
  800db7:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  800db8:	83 ec 0c             	sub    $0xc,%esp
  800dbb:	68 8f 13 80 00       	push   $0x80138f
  800dc0:	e8 c0 f3 ff ff       	call   800185 <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  800dc5:	83 c4 0c             	add    $0xc,%esp
  800dc8:	6a 07                	push   $0x7
  800dca:	68 00 f0 bf ee       	push   $0xeebff000
  800dcf:	6a 00                	push   $0x0
  800dd1:	e8 fa fd ff ff       	call   800bd0 <sys_page_alloc>
  800dd6:	83 c4 10             	add    $0x10,%esp
  800dd9:	85 c0                	test   %eax,%eax
  800ddb:	78 2a                	js     800e07 <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  800ddd:	83 ec 08             	sub    $0x8,%esp
  800de0:	68 1b 0e 80 00       	push   $0x800e1b
  800de5:	6a 00                	push   $0x0
  800de7:	e8 fd fe ff ff       	call   800ce9 <sys_env_set_pgfault_upcall>
  800dec:	83 c4 10             	add    $0x10,%esp
  800def:	85 c0                	test   %eax,%eax
  800df1:	79 bb                	jns    800dae <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  800df3:	83 ec 04             	sub    $0x4,%esp
  800df6:	68 cc 13 80 00       	push   $0x8013cc
  800dfb:	6a 25                	push   $0x25
  800dfd:	68 bc 13 80 00       	push   $0x8013bc
  800e02:	e8 3a 00 00 00       	call   800e41 <_panic>
            panic("Allocation of UXSTACK failed!");
  800e07:	83 ec 04             	sub    $0x4,%esp
  800e0a:	68 9e 13 80 00       	push   $0x80139e
  800e0f:	6a 22                	push   $0x22
  800e11:	68 bc 13 80 00       	push   $0x8013bc
  800e16:	e8 26 00 00 00       	call   800e41 <_panic>

00800e1b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e1b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e1c:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800e21:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e23:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  800e26:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  800e2a:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  800e2e:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  800e31:	83 c4 08             	add    $0x8,%esp
    popa
  800e34:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $0x4, %esp
  800e35:	83 c4 04             	add    $0x4,%esp
    popf
  800e38:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  800e39:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  800e3c:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  800e40:	c3                   	ret    

00800e41 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800e41:	f3 0f 1e fb          	endbr32 
  800e45:	55                   	push   %ebp
  800e46:	89 e5                	mov    %esp,%ebp
  800e48:	56                   	push   %esi
  800e49:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800e4a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800e4d:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800e53:	e8 32 fd ff ff       	call   800b8a <sys_getenvid>
  800e58:	83 ec 0c             	sub    $0xc,%esp
  800e5b:	ff 75 0c             	pushl  0xc(%ebp)
  800e5e:	ff 75 08             	pushl  0x8(%ebp)
  800e61:	56                   	push   %esi
  800e62:	50                   	push   %eax
  800e63:	68 f0 13 80 00       	push   $0x8013f0
  800e68:	e8 18 f3 ff ff       	call   800185 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e6d:	83 c4 18             	add    $0x18,%esp
  800e70:	53                   	push   %ebx
  800e71:	ff 75 10             	pushl  0x10(%ebp)
  800e74:	e8 b7 f2 ff ff       	call   800130 <vcprintf>
	cprintf("\n");
  800e79:	c7 04 24 9c 13 80 00 	movl   $0x80139c,(%esp)
  800e80:	e8 00 f3 ff ff       	call   800185 <cprintf>
  800e85:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e88:	cc                   	int3   
  800e89:	eb fd                	jmp    800e88 <_panic+0x47>
  800e8b:	66 90                	xchg   %ax,%ax
  800e8d:	66 90                	xchg   %ax,%ax
  800e8f:	90                   	nop

00800e90 <__udivdi3>:
  800e90:	f3 0f 1e fb          	endbr32 
  800e94:	55                   	push   %ebp
  800e95:	57                   	push   %edi
  800e96:	56                   	push   %esi
  800e97:	53                   	push   %ebx
  800e98:	83 ec 1c             	sub    $0x1c,%esp
  800e9b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e9f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800ea3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ea7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800eab:	85 d2                	test   %edx,%edx
  800ead:	75 19                	jne    800ec8 <__udivdi3+0x38>
  800eaf:	39 f3                	cmp    %esi,%ebx
  800eb1:	76 4d                	jbe    800f00 <__udivdi3+0x70>
  800eb3:	31 ff                	xor    %edi,%edi
  800eb5:	89 e8                	mov    %ebp,%eax
  800eb7:	89 f2                	mov    %esi,%edx
  800eb9:	f7 f3                	div    %ebx
  800ebb:	89 fa                	mov    %edi,%edx
  800ebd:	83 c4 1c             	add    $0x1c,%esp
  800ec0:	5b                   	pop    %ebx
  800ec1:	5e                   	pop    %esi
  800ec2:	5f                   	pop    %edi
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    
  800ec5:	8d 76 00             	lea    0x0(%esi),%esi
  800ec8:	39 f2                	cmp    %esi,%edx
  800eca:	76 14                	jbe    800ee0 <__udivdi3+0x50>
  800ecc:	31 ff                	xor    %edi,%edi
  800ece:	31 c0                	xor    %eax,%eax
  800ed0:	89 fa                	mov    %edi,%edx
  800ed2:	83 c4 1c             	add    $0x1c,%esp
  800ed5:	5b                   	pop    %ebx
  800ed6:	5e                   	pop    %esi
  800ed7:	5f                   	pop    %edi
  800ed8:	5d                   	pop    %ebp
  800ed9:	c3                   	ret    
  800eda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ee0:	0f bd fa             	bsr    %edx,%edi
  800ee3:	83 f7 1f             	xor    $0x1f,%edi
  800ee6:	75 48                	jne    800f30 <__udivdi3+0xa0>
  800ee8:	39 f2                	cmp    %esi,%edx
  800eea:	72 06                	jb     800ef2 <__udivdi3+0x62>
  800eec:	31 c0                	xor    %eax,%eax
  800eee:	39 eb                	cmp    %ebp,%ebx
  800ef0:	77 de                	ja     800ed0 <__udivdi3+0x40>
  800ef2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ef7:	eb d7                	jmp    800ed0 <__udivdi3+0x40>
  800ef9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f00:	89 d9                	mov    %ebx,%ecx
  800f02:	85 db                	test   %ebx,%ebx
  800f04:	75 0b                	jne    800f11 <__udivdi3+0x81>
  800f06:	b8 01 00 00 00       	mov    $0x1,%eax
  800f0b:	31 d2                	xor    %edx,%edx
  800f0d:	f7 f3                	div    %ebx
  800f0f:	89 c1                	mov    %eax,%ecx
  800f11:	31 d2                	xor    %edx,%edx
  800f13:	89 f0                	mov    %esi,%eax
  800f15:	f7 f1                	div    %ecx
  800f17:	89 c6                	mov    %eax,%esi
  800f19:	89 e8                	mov    %ebp,%eax
  800f1b:	89 f7                	mov    %esi,%edi
  800f1d:	f7 f1                	div    %ecx
  800f1f:	89 fa                	mov    %edi,%edx
  800f21:	83 c4 1c             	add    $0x1c,%esp
  800f24:	5b                   	pop    %ebx
  800f25:	5e                   	pop    %esi
  800f26:	5f                   	pop    %edi
  800f27:	5d                   	pop    %ebp
  800f28:	c3                   	ret    
  800f29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f30:	89 f9                	mov    %edi,%ecx
  800f32:	b8 20 00 00 00       	mov    $0x20,%eax
  800f37:	29 f8                	sub    %edi,%eax
  800f39:	d3 e2                	shl    %cl,%edx
  800f3b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f3f:	89 c1                	mov    %eax,%ecx
  800f41:	89 da                	mov    %ebx,%edx
  800f43:	d3 ea                	shr    %cl,%edx
  800f45:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800f49:	09 d1                	or     %edx,%ecx
  800f4b:	89 f2                	mov    %esi,%edx
  800f4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f51:	89 f9                	mov    %edi,%ecx
  800f53:	d3 e3                	shl    %cl,%ebx
  800f55:	89 c1                	mov    %eax,%ecx
  800f57:	d3 ea                	shr    %cl,%edx
  800f59:	89 f9                	mov    %edi,%ecx
  800f5b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f5f:	89 eb                	mov    %ebp,%ebx
  800f61:	d3 e6                	shl    %cl,%esi
  800f63:	89 c1                	mov    %eax,%ecx
  800f65:	d3 eb                	shr    %cl,%ebx
  800f67:	09 de                	or     %ebx,%esi
  800f69:	89 f0                	mov    %esi,%eax
  800f6b:	f7 74 24 08          	divl   0x8(%esp)
  800f6f:	89 d6                	mov    %edx,%esi
  800f71:	89 c3                	mov    %eax,%ebx
  800f73:	f7 64 24 0c          	mull   0xc(%esp)
  800f77:	39 d6                	cmp    %edx,%esi
  800f79:	72 15                	jb     800f90 <__udivdi3+0x100>
  800f7b:	89 f9                	mov    %edi,%ecx
  800f7d:	d3 e5                	shl    %cl,%ebp
  800f7f:	39 c5                	cmp    %eax,%ebp
  800f81:	73 04                	jae    800f87 <__udivdi3+0xf7>
  800f83:	39 d6                	cmp    %edx,%esi
  800f85:	74 09                	je     800f90 <__udivdi3+0x100>
  800f87:	89 d8                	mov    %ebx,%eax
  800f89:	31 ff                	xor    %edi,%edi
  800f8b:	e9 40 ff ff ff       	jmp    800ed0 <__udivdi3+0x40>
  800f90:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800f93:	31 ff                	xor    %edi,%edi
  800f95:	e9 36 ff ff ff       	jmp    800ed0 <__udivdi3+0x40>
  800f9a:	66 90                	xchg   %ax,%ax
  800f9c:	66 90                	xchg   %ax,%ax
  800f9e:	66 90                	xchg   %ax,%ax

00800fa0 <__umoddi3>:
  800fa0:	f3 0f 1e fb          	endbr32 
  800fa4:	55                   	push   %ebp
  800fa5:	57                   	push   %edi
  800fa6:	56                   	push   %esi
  800fa7:	53                   	push   %ebx
  800fa8:	83 ec 1c             	sub    $0x1c,%esp
  800fab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800faf:	8b 74 24 30          	mov    0x30(%esp),%esi
  800fb3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800fb7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800fbb:	85 c0                	test   %eax,%eax
  800fbd:	75 19                	jne    800fd8 <__umoddi3+0x38>
  800fbf:	39 df                	cmp    %ebx,%edi
  800fc1:	76 5d                	jbe    801020 <__umoddi3+0x80>
  800fc3:	89 f0                	mov    %esi,%eax
  800fc5:	89 da                	mov    %ebx,%edx
  800fc7:	f7 f7                	div    %edi
  800fc9:	89 d0                	mov    %edx,%eax
  800fcb:	31 d2                	xor    %edx,%edx
  800fcd:	83 c4 1c             	add    $0x1c,%esp
  800fd0:	5b                   	pop    %ebx
  800fd1:	5e                   	pop    %esi
  800fd2:	5f                   	pop    %edi
  800fd3:	5d                   	pop    %ebp
  800fd4:	c3                   	ret    
  800fd5:	8d 76 00             	lea    0x0(%esi),%esi
  800fd8:	89 f2                	mov    %esi,%edx
  800fda:	39 d8                	cmp    %ebx,%eax
  800fdc:	76 12                	jbe    800ff0 <__umoddi3+0x50>
  800fde:	89 f0                	mov    %esi,%eax
  800fe0:	89 da                	mov    %ebx,%edx
  800fe2:	83 c4 1c             	add    $0x1c,%esp
  800fe5:	5b                   	pop    %ebx
  800fe6:	5e                   	pop    %esi
  800fe7:	5f                   	pop    %edi
  800fe8:	5d                   	pop    %ebp
  800fe9:	c3                   	ret    
  800fea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ff0:	0f bd e8             	bsr    %eax,%ebp
  800ff3:	83 f5 1f             	xor    $0x1f,%ebp
  800ff6:	75 50                	jne    801048 <__umoddi3+0xa8>
  800ff8:	39 d8                	cmp    %ebx,%eax
  800ffa:	0f 82 e0 00 00 00    	jb     8010e0 <__umoddi3+0x140>
  801000:	89 d9                	mov    %ebx,%ecx
  801002:	39 f7                	cmp    %esi,%edi
  801004:	0f 86 d6 00 00 00    	jbe    8010e0 <__umoddi3+0x140>
  80100a:	89 d0                	mov    %edx,%eax
  80100c:	89 ca                	mov    %ecx,%edx
  80100e:	83 c4 1c             	add    $0x1c,%esp
  801011:	5b                   	pop    %ebx
  801012:	5e                   	pop    %esi
  801013:	5f                   	pop    %edi
  801014:	5d                   	pop    %ebp
  801015:	c3                   	ret    
  801016:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80101d:	8d 76 00             	lea    0x0(%esi),%esi
  801020:	89 fd                	mov    %edi,%ebp
  801022:	85 ff                	test   %edi,%edi
  801024:	75 0b                	jne    801031 <__umoddi3+0x91>
  801026:	b8 01 00 00 00       	mov    $0x1,%eax
  80102b:	31 d2                	xor    %edx,%edx
  80102d:	f7 f7                	div    %edi
  80102f:	89 c5                	mov    %eax,%ebp
  801031:	89 d8                	mov    %ebx,%eax
  801033:	31 d2                	xor    %edx,%edx
  801035:	f7 f5                	div    %ebp
  801037:	89 f0                	mov    %esi,%eax
  801039:	f7 f5                	div    %ebp
  80103b:	89 d0                	mov    %edx,%eax
  80103d:	31 d2                	xor    %edx,%edx
  80103f:	eb 8c                	jmp    800fcd <__umoddi3+0x2d>
  801041:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801048:	89 e9                	mov    %ebp,%ecx
  80104a:	ba 20 00 00 00       	mov    $0x20,%edx
  80104f:	29 ea                	sub    %ebp,%edx
  801051:	d3 e0                	shl    %cl,%eax
  801053:	89 44 24 08          	mov    %eax,0x8(%esp)
  801057:	89 d1                	mov    %edx,%ecx
  801059:	89 f8                	mov    %edi,%eax
  80105b:	d3 e8                	shr    %cl,%eax
  80105d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801061:	89 54 24 04          	mov    %edx,0x4(%esp)
  801065:	8b 54 24 04          	mov    0x4(%esp),%edx
  801069:	09 c1                	or     %eax,%ecx
  80106b:	89 d8                	mov    %ebx,%eax
  80106d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801071:	89 e9                	mov    %ebp,%ecx
  801073:	d3 e7                	shl    %cl,%edi
  801075:	89 d1                	mov    %edx,%ecx
  801077:	d3 e8                	shr    %cl,%eax
  801079:	89 e9                	mov    %ebp,%ecx
  80107b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80107f:	d3 e3                	shl    %cl,%ebx
  801081:	89 c7                	mov    %eax,%edi
  801083:	89 d1                	mov    %edx,%ecx
  801085:	89 f0                	mov    %esi,%eax
  801087:	d3 e8                	shr    %cl,%eax
  801089:	89 e9                	mov    %ebp,%ecx
  80108b:	89 fa                	mov    %edi,%edx
  80108d:	d3 e6                	shl    %cl,%esi
  80108f:	09 d8                	or     %ebx,%eax
  801091:	f7 74 24 08          	divl   0x8(%esp)
  801095:	89 d1                	mov    %edx,%ecx
  801097:	89 f3                	mov    %esi,%ebx
  801099:	f7 64 24 0c          	mull   0xc(%esp)
  80109d:	89 c6                	mov    %eax,%esi
  80109f:	89 d7                	mov    %edx,%edi
  8010a1:	39 d1                	cmp    %edx,%ecx
  8010a3:	72 06                	jb     8010ab <__umoddi3+0x10b>
  8010a5:	75 10                	jne    8010b7 <__umoddi3+0x117>
  8010a7:	39 c3                	cmp    %eax,%ebx
  8010a9:	73 0c                	jae    8010b7 <__umoddi3+0x117>
  8010ab:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8010af:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8010b3:	89 d7                	mov    %edx,%edi
  8010b5:	89 c6                	mov    %eax,%esi
  8010b7:	89 ca                	mov    %ecx,%edx
  8010b9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010be:	29 f3                	sub    %esi,%ebx
  8010c0:	19 fa                	sbb    %edi,%edx
  8010c2:	89 d0                	mov    %edx,%eax
  8010c4:	d3 e0                	shl    %cl,%eax
  8010c6:	89 e9                	mov    %ebp,%ecx
  8010c8:	d3 eb                	shr    %cl,%ebx
  8010ca:	d3 ea                	shr    %cl,%edx
  8010cc:	09 d8                	or     %ebx,%eax
  8010ce:	83 c4 1c             	add    $0x1c,%esp
  8010d1:	5b                   	pop    %ebx
  8010d2:	5e                   	pop    %esi
  8010d3:	5f                   	pop    %edi
  8010d4:	5d                   	pop    %ebp
  8010d5:	c3                   	ret    
  8010d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010dd:	8d 76 00             	lea    0x0(%esi),%esi
  8010e0:	29 fe                	sub    %edi,%esi
  8010e2:	19 c3                	sbb    %eax,%ebx
  8010e4:	89 f2                	mov    %esi,%edx
  8010e6:	89 d9                	mov    %ebx,%ecx
  8010e8:	e9 1d ff ff ff       	jmp    80100a <__umoddi3+0x6a>
