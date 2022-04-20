
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 33 00 00 00       	call   800064 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  80003d:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800044:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800047:	b8 01 00 00 00       	mov    $0x1,%eax
  80004c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800051:	99                   	cltd   
  800052:	f7 f9                	idiv   %ecx
  800054:	50                   	push   %eax
  800055:	68 40 10 80 00       	push   $0x801040
  80005a:	e8 02 01 00 00       	call   800161 <cprintf>
}
  80005f:	83 c4 10             	add    $0x10,%esp
  800062:	c9                   	leave  
  800063:	c3                   	ret    

00800064 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800064:	f3 0f 1e fb          	endbr32 
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	56                   	push   %esi
  80006c:	53                   	push   %ebx
  80006d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800070:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    envid_t envid = sys_getenvid();
  800073:	e8 ee 0a 00 00       	call   800b66 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  800078:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800080:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800085:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008a:	85 db                	test   %ebx,%ebx
  80008c:	7e 07                	jle    800095 <libmain+0x31>
		binaryname = argv[0];
  80008e:	8b 06                	mov    (%esi),%eax
  800090:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800095:	83 ec 08             	sub    $0x8,%esp
  800098:	56                   	push   %esi
  800099:	53                   	push   %ebx
  80009a:	e8 94 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009f:	e8 0a 00 00 00       	call   8000ae <exit>
}
  8000a4:	83 c4 10             	add    $0x10,%esp
  8000a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000aa:	5b                   	pop    %ebx
  8000ab:	5e                   	pop    %esi
  8000ac:	5d                   	pop    %ebp
  8000ad:	c3                   	ret    

008000ae <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ae:	f3 0f 1e fb          	endbr32 
  8000b2:	55                   	push   %ebp
  8000b3:	89 e5                	mov    %esp,%ebp
  8000b5:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000b8:	6a 00                	push   $0x0
  8000ba:	e8 62 0a 00 00       	call   800b21 <sys_env_destroy>
}
  8000bf:	83 c4 10             	add    $0x10,%esp
  8000c2:	c9                   	leave  
  8000c3:	c3                   	ret    

008000c4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c4:	f3 0f 1e fb          	endbr32 
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	53                   	push   %ebx
  8000cc:	83 ec 04             	sub    $0x4,%esp
  8000cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d2:	8b 13                	mov    (%ebx),%edx
  8000d4:	8d 42 01             	lea    0x1(%edx),%eax
  8000d7:	89 03                	mov    %eax,(%ebx)
  8000d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000dc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000e0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e5:	74 09                	je     8000f0 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000e7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000ee:	c9                   	leave  
  8000ef:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000f0:	83 ec 08             	sub    $0x8,%esp
  8000f3:	68 ff 00 00 00       	push   $0xff
  8000f8:	8d 43 08             	lea    0x8(%ebx),%eax
  8000fb:	50                   	push   %eax
  8000fc:	e8 db 09 00 00       	call   800adc <sys_cputs>
		b->idx = 0;
  800101:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	eb db                	jmp    8000e7 <putch+0x23>

0080010c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80010c:	f3 0f 1e fb          	endbr32 
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800119:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800120:	00 00 00 
	b.cnt = 0;
  800123:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80012a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80012d:	ff 75 0c             	pushl  0xc(%ebp)
  800130:	ff 75 08             	pushl  0x8(%ebp)
  800133:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800139:	50                   	push   %eax
  80013a:	68 c4 00 80 00       	push   $0x8000c4
  80013f:	e8 20 01 00 00       	call   800264 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800144:	83 c4 08             	add    $0x8,%esp
  800147:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80014d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800153:	50                   	push   %eax
  800154:	e8 83 09 00 00       	call   800adc <sys_cputs>

	return b.cnt;
}
  800159:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80015f:	c9                   	leave  
  800160:	c3                   	ret    

00800161 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800161:	f3 0f 1e fb          	endbr32 
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80016b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80016e:	50                   	push   %eax
  80016f:	ff 75 08             	pushl  0x8(%ebp)
  800172:	e8 95 ff ff ff       	call   80010c <vcprintf>
	va_end(ap);

	return cnt;
}
  800177:	c9                   	leave  
  800178:	c3                   	ret    

00800179 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	57                   	push   %edi
  80017d:	56                   	push   %esi
  80017e:	53                   	push   %ebx
  80017f:	83 ec 1c             	sub    $0x1c,%esp
  800182:	89 c7                	mov    %eax,%edi
  800184:	89 d6                	mov    %edx,%esi
  800186:	8b 45 08             	mov    0x8(%ebp),%eax
  800189:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018c:	89 d1                	mov    %edx,%ecx
  80018e:	89 c2                	mov    %eax,%edx
  800190:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800193:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800196:	8b 45 10             	mov    0x10(%ebp),%eax
  800199:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80019c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80019f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001a6:	39 c2                	cmp    %eax,%edx
  8001a8:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001ab:	72 3e                	jb     8001eb <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ad:	83 ec 0c             	sub    $0xc,%esp
  8001b0:	ff 75 18             	pushl  0x18(%ebp)
  8001b3:	83 eb 01             	sub    $0x1,%ebx
  8001b6:	53                   	push   %ebx
  8001b7:	50                   	push   %eax
  8001b8:	83 ec 08             	sub    $0x8,%esp
  8001bb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001be:	ff 75 e0             	pushl  -0x20(%ebp)
  8001c1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001c4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001c7:	e8 04 0c 00 00       	call   800dd0 <__udivdi3>
  8001cc:	83 c4 18             	add    $0x18,%esp
  8001cf:	52                   	push   %edx
  8001d0:	50                   	push   %eax
  8001d1:	89 f2                	mov    %esi,%edx
  8001d3:	89 f8                	mov    %edi,%eax
  8001d5:	e8 9f ff ff ff       	call   800179 <printnum>
  8001da:	83 c4 20             	add    $0x20,%esp
  8001dd:	eb 13                	jmp    8001f2 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001df:	83 ec 08             	sub    $0x8,%esp
  8001e2:	56                   	push   %esi
  8001e3:	ff 75 18             	pushl  0x18(%ebp)
  8001e6:	ff d7                	call   *%edi
  8001e8:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001eb:	83 eb 01             	sub    $0x1,%ebx
  8001ee:	85 db                	test   %ebx,%ebx
  8001f0:	7f ed                	jg     8001df <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001f2:	83 ec 08             	sub    $0x8,%esp
  8001f5:	56                   	push   %esi
  8001f6:	83 ec 04             	sub    $0x4,%esp
  8001f9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001fc:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ff:	ff 75 dc             	pushl  -0x24(%ebp)
  800202:	ff 75 d8             	pushl  -0x28(%ebp)
  800205:	e8 d6 0c 00 00       	call   800ee0 <__umoddi3>
  80020a:	83 c4 14             	add    $0x14,%esp
  80020d:	0f be 80 58 10 80 00 	movsbl 0x801058(%eax),%eax
  800214:	50                   	push   %eax
  800215:	ff d7                	call   *%edi
}
  800217:	83 c4 10             	add    $0x10,%esp
  80021a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021d:	5b                   	pop    %ebx
  80021e:	5e                   	pop    %esi
  80021f:	5f                   	pop    %edi
  800220:	5d                   	pop    %ebp
  800221:	c3                   	ret    

00800222 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800222:	f3 0f 1e fb          	endbr32 
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80022c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800230:	8b 10                	mov    (%eax),%edx
  800232:	3b 50 04             	cmp    0x4(%eax),%edx
  800235:	73 0a                	jae    800241 <sprintputch+0x1f>
		*b->buf++ = ch;
  800237:	8d 4a 01             	lea    0x1(%edx),%ecx
  80023a:	89 08                	mov    %ecx,(%eax)
  80023c:	8b 45 08             	mov    0x8(%ebp),%eax
  80023f:	88 02                	mov    %al,(%edx)
}
  800241:	5d                   	pop    %ebp
  800242:	c3                   	ret    

00800243 <printfmt>:
{
  800243:	f3 0f 1e fb          	endbr32 
  800247:	55                   	push   %ebp
  800248:	89 e5                	mov    %esp,%ebp
  80024a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80024d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800250:	50                   	push   %eax
  800251:	ff 75 10             	pushl  0x10(%ebp)
  800254:	ff 75 0c             	pushl  0xc(%ebp)
  800257:	ff 75 08             	pushl  0x8(%ebp)
  80025a:	e8 05 00 00 00       	call   800264 <vprintfmt>
}
  80025f:	83 c4 10             	add    $0x10,%esp
  800262:	c9                   	leave  
  800263:	c3                   	ret    

00800264 <vprintfmt>:
{
  800264:	f3 0f 1e fb          	endbr32 
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	57                   	push   %edi
  80026c:	56                   	push   %esi
  80026d:	53                   	push   %ebx
  80026e:	83 ec 3c             	sub    $0x3c,%esp
  800271:	8b 75 08             	mov    0x8(%ebp),%esi
  800274:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800277:	8b 7d 10             	mov    0x10(%ebp),%edi
  80027a:	e9 4a 03 00 00       	jmp    8005c9 <vprintfmt+0x365>
		padc = ' ';
  80027f:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800283:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80028a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800291:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800298:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80029d:	8d 47 01             	lea    0x1(%edi),%eax
  8002a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002a3:	0f b6 17             	movzbl (%edi),%edx
  8002a6:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002a9:	3c 55                	cmp    $0x55,%al
  8002ab:	0f 87 de 03 00 00    	ja     80068f <vprintfmt+0x42b>
  8002b1:	0f b6 c0             	movzbl %al,%eax
  8002b4:	3e ff 24 85 20 11 80 	notrack jmp *0x801120(,%eax,4)
  8002bb:	00 
  8002bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002bf:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002c3:	eb d8                	jmp    80029d <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8002c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002c8:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002cc:	eb cf                	jmp    80029d <vprintfmt+0x39>
  8002ce:	0f b6 d2             	movzbl %dl,%edx
  8002d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8002d9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002dc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002df:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002e3:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002e6:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002e9:	83 f9 09             	cmp    $0x9,%ecx
  8002ec:	77 55                	ja     800343 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8002ee:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002f1:	eb e9                	jmp    8002dc <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8002f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f6:	8b 00                	mov    (%eax),%eax
  8002f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8002fe:	8d 40 04             	lea    0x4(%eax),%eax
  800301:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800304:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800307:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80030b:	79 90                	jns    80029d <vprintfmt+0x39>
				width = precision, precision = -1;
  80030d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800310:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800313:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80031a:	eb 81                	jmp    80029d <vprintfmt+0x39>
  80031c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80031f:	85 c0                	test   %eax,%eax
  800321:	ba 00 00 00 00       	mov    $0x0,%edx
  800326:	0f 49 d0             	cmovns %eax,%edx
  800329:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80032c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80032f:	e9 69 ff ff ff       	jmp    80029d <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800334:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800337:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80033e:	e9 5a ff ff ff       	jmp    80029d <vprintfmt+0x39>
  800343:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800346:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800349:	eb bc                	jmp    800307 <vprintfmt+0xa3>
			lflag++;
  80034b:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80034e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800351:	e9 47 ff ff ff       	jmp    80029d <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800356:	8b 45 14             	mov    0x14(%ebp),%eax
  800359:	8d 78 04             	lea    0x4(%eax),%edi
  80035c:	83 ec 08             	sub    $0x8,%esp
  80035f:	53                   	push   %ebx
  800360:	ff 30                	pushl  (%eax)
  800362:	ff d6                	call   *%esi
			break;
  800364:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800367:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80036a:	e9 57 02 00 00       	jmp    8005c6 <vprintfmt+0x362>
			err = va_arg(ap, int);
  80036f:	8b 45 14             	mov    0x14(%ebp),%eax
  800372:	8d 78 04             	lea    0x4(%eax),%edi
  800375:	8b 00                	mov    (%eax),%eax
  800377:	99                   	cltd   
  800378:	31 d0                	xor    %edx,%eax
  80037a:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80037c:	83 f8 08             	cmp    $0x8,%eax
  80037f:	7f 23                	jg     8003a4 <vprintfmt+0x140>
  800381:	8b 14 85 80 12 80 00 	mov    0x801280(,%eax,4),%edx
  800388:	85 d2                	test   %edx,%edx
  80038a:	74 18                	je     8003a4 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80038c:	52                   	push   %edx
  80038d:	68 79 10 80 00       	push   $0x801079
  800392:	53                   	push   %ebx
  800393:	56                   	push   %esi
  800394:	e8 aa fe ff ff       	call   800243 <printfmt>
  800399:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80039c:	89 7d 14             	mov    %edi,0x14(%ebp)
  80039f:	e9 22 02 00 00       	jmp    8005c6 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8003a4:	50                   	push   %eax
  8003a5:	68 70 10 80 00       	push   $0x801070
  8003aa:	53                   	push   %ebx
  8003ab:	56                   	push   %esi
  8003ac:	e8 92 fe ff ff       	call   800243 <printfmt>
  8003b1:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003b4:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003b7:	e9 0a 02 00 00       	jmp    8005c6 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8003bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bf:	83 c0 04             	add    $0x4,%eax
  8003c2:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c8:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003ca:	85 d2                	test   %edx,%edx
  8003cc:	b8 69 10 80 00       	mov    $0x801069,%eax
  8003d1:	0f 45 c2             	cmovne %edx,%eax
  8003d4:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003d7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003db:	7e 06                	jle    8003e3 <vprintfmt+0x17f>
  8003dd:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8003e1:	75 0d                	jne    8003f0 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003e3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003e6:	89 c7                	mov    %eax,%edi
  8003e8:	03 45 e0             	add    -0x20(%ebp),%eax
  8003eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ee:	eb 55                	jmp    800445 <vprintfmt+0x1e1>
  8003f0:	83 ec 08             	sub    $0x8,%esp
  8003f3:	ff 75 d8             	pushl  -0x28(%ebp)
  8003f6:	ff 75 cc             	pushl  -0x34(%ebp)
  8003f9:	e8 45 03 00 00       	call   800743 <strnlen>
  8003fe:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800401:	29 c2                	sub    %eax,%edx
  800403:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800406:	83 c4 10             	add    $0x10,%esp
  800409:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80040b:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80040f:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800412:	85 ff                	test   %edi,%edi
  800414:	7e 11                	jle    800427 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800416:	83 ec 08             	sub    $0x8,%esp
  800419:	53                   	push   %ebx
  80041a:	ff 75 e0             	pushl  -0x20(%ebp)
  80041d:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80041f:	83 ef 01             	sub    $0x1,%edi
  800422:	83 c4 10             	add    $0x10,%esp
  800425:	eb eb                	jmp    800412 <vprintfmt+0x1ae>
  800427:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80042a:	85 d2                	test   %edx,%edx
  80042c:	b8 00 00 00 00       	mov    $0x0,%eax
  800431:	0f 49 c2             	cmovns %edx,%eax
  800434:	29 c2                	sub    %eax,%edx
  800436:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800439:	eb a8                	jmp    8003e3 <vprintfmt+0x17f>
					putch(ch, putdat);
  80043b:	83 ec 08             	sub    $0x8,%esp
  80043e:	53                   	push   %ebx
  80043f:	52                   	push   %edx
  800440:	ff d6                	call   *%esi
  800442:	83 c4 10             	add    $0x10,%esp
  800445:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800448:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80044a:	83 c7 01             	add    $0x1,%edi
  80044d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800451:	0f be d0             	movsbl %al,%edx
  800454:	85 d2                	test   %edx,%edx
  800456:	74 4b                	je     8004a3 <vprintfmt+0x23f>
  800458:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80045c:	78 06                	js     800464 <vprintfmt+0x200>
  80045e:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800462:	78 1e                	js     800482 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800464:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800468:	74 d1                	je     80043b <vprintfmt+0x1d7>
  80046a:	0f be c0             	movsbl %al,%eax
  80046d:	83 e8 20             	sub    $0x20,%eax
  800470:	83 f8 5e             	cmp    $0x5e,%eax
  800473:	76 c6                	jbe    80043b <vprintfmt+0x1d7>
					putch('?', putdat);
  800475:	83 ec 08             	sub    $0x8,%esp
  800478:	53                   	push   %ebx
  800479:	6a 3f                	push   $0x3f
  80047b:	ff d6                	call   *%esi
  80047d:	83 c4 10             	add    $0x10,%esp
  800480:	eb c3                	jmp    800445 <vprintfmt+0x1e1>
  800482:	89 cf                	mov    %ecx,%edi
  800484:	eb 0e                	jmp    800494 <vprintfmt+0x230>
				putch(' ', putdat);
  800486:	83 ec 08             	sub    $0x8,%esp
  800489:	53                   	push   %ebx
  80048a:	6a 20                	push   $0x20
  80048c:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80048e:	83 ef 01             	sub    $0x1,%edi
  800491:	83 c4 10             	add    $0x10,%esp
  800494:	85 ff                	test   %edi,%edi
  800496:	7f ee                	jg     800486 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800498:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80049b:	89 45 14             	mov    %eax,0x14(%ebp)
  80049e:	e9 23 01 00 00       	jmp    8005c6 <vprintfmt+0x362>
  8004a3:	89 cf                	mov    %ecx,%edi
  8004a5:	eb ed                	jmp    800494 <vprintfmt+0x230>
	if (lflag >= 2)
  8004a7:	83 f9 01             	cmp    $0x1,%ecx
  8004aa:	7f 1b                	jg     8004c7 <vprintfmt+0x263>
	else if (lflag)
  8004ac:	85 c9                	test   %ecx,%ecx
  8004ae:	74 63                	je     800513 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8004b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b3:	8b 00                	mov    (%eax),%eax
  8004b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004b8:	99                   	cltd   
  8004b9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bf:	8d 40 04             	lea    0x4(%eax),%eax
  8004c2:	89 45 14             	mov    %eax,0x14(%ebp)
  8004c5:	eb 17                	jmp    8004de <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8004c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ca:	8b 50 04             	mov    0x4(%eax),%edx
  8004cd:	8b 00                	mov    (%eax),%eax
  8004cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004d2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d8:	8d 40 08             	lea    0x8(%eax),%eax
  8004db:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004de:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004e1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8004e4:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8004e9:	85 c9                	test   %ecx,%ecx
  8004eb:	0f 89 bb 00 00 00    	jns    8005ac <vprintfmt+0x348>
				putch('-', putdat);
  8004f1:	83 ec 08             	sub    $0x8,%esp
  8004f4:	53                   	push   %ebx
  8004f5:	6a 2d                	push   $0x2d
  8004f7:	ff d6                	call   *%esi
				num = -(long long) num;
  8004f9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004fc:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004ff:	f7 da                	neg    %edx
  800501:	83 d1 00             	adc    $0x0,%ecx
  800504:	f7 d9                	neg    %ecx
  800506:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800509:	b8 0a 00 00 00       	mov    $0xa,%eax
  80050e:	e9 99 00 00 00       	jmp    8005ac <vprintfmt+0x348>
		return va_arg(*ap, int);
  800513:	8b 45 14             	mov    0x14(%ebp),%eax
  800516:	8b 00                	mov    (%eax),%eax
  800518:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051b:	99                   	cltd   
  80051c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80051f:	8b 45 14             	mov    0x14(%ebp),%eax
  800522:	8d 40 04             	lea    0x4(%eax),%eax
  800525:	89 45 14             	mov    %eax,0x14(%ebp)
  800528:	eb b4                	jmp    8004de <vprintfmt+0x27a>
	if (lflag >= 2)
  80052a:	83 f9 01             	cmp    $0x1,%ecx
  80052d:	7f 1b                	jg     80054a <vprintfmt+0x2e6>
	else if (lflag)
  80052f:	85 c9                	test   %ecx,%ecx
  800531:	74 2c                	je     80055f <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8b 10                	mov    (%eax),%edx
  800538:	b9 00 00 00 00       	mov    $0x0,%ecx
  80053d:	8d 40 04             	lea    0x4(%eax),%eax
  800540:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800543:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800548:	eb 62                	jmp    8005ac <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80054a:	8b 45 14             	mov    0x14(%ebp),%eax
  80054d:	8b 10                	mov    (%eax),%edx
  80054f:	8b 48 04             	mov    0x4(%eax),%ecx
  800552:	8d 40 08             	lea    0x8(%eax),%eax
  800555:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800558:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80055d:	eb 4d                	jmp    8005ac <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80055f:	8b 45 14             	mov    0x14(%ebp),%eax
  800562:	8b 10                	mov    (%eax),%edx
  800564:	b9 00 00 00 00       	mov    $0x0,%ecx
  800569:	8d 40 04             	lea    0x4(%eax),%eax
  80056c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80056f:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800574:	eb 36                	jmp    8005ac <vprintfmt+0x348>
	if (lflag >= 2)
  800576:	83 f9 01             	cmp    $0x1,%ecx
  800579:	7f 17                	jg     800592 <vprintfmt+0x32e>
	else if (lflag)
  80057b:	85 c9                	test   %ecx,%ecx
  80057d:	74 6e                	je     8005ed <vprintfmt+0x389>
		return va_arg(*ap, long);
  80057f:	8b 45 14             	mov    0x14(%ebp),%eax
  800582:	8b 10                	mov    (%eax),%edx
  800584:	89 d0                	mov    %edx,%eax
  800586:	99                   	cltd   
  800587:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80058a:	8d 49 04             	lea    0x4(%ecx),%ecx
  80058d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800590:	eb 11                	jmp    8005a3 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8b 50 04             	mov    0x4(%eax),%edx
  800598:	8b 00                	mov    (%eax),%eax
  80059a:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80059d:	8d 49 08             	lea    0x8(%ecx),%ecx
  8005a0:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8005a3:	89 d1                	mov    %edx,%ecx
  8005a5:	89 c2                	mov    %eax,%edx
            base = 8;
  8005a7:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005ac:	83 ec 0c             	sub    $0xc,%esp
  8005af:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005b3:	57                   	push   %edi
  8005b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8005b7:	50                   	push   %eax
  8005b8:	51                   	push   %ecx
  8005b9:	52                   	push   %edx
  8005ba:	89 da                	mov    %ebx,%edx
  8005bc:	89 f0                	mov    %esi,%eax
  8005be:	e8 b6 fb ff ff       	call   800179 <printnum>
			break;
  8005c3:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8005c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005c9:	83 c7 01             	add    $0x1,%edi
  8005cc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005d0:	83 f8 25             	cmp    $0x25,%eax
  8005d3:	0f 84 a6 fc ff ff    	je     80027f <vprintfmt+0x1b>
			if (ch == '\0')
  8005d9:	85 c0                	test   %eax,%eax
  8005db:	0f 84 ce 00 00 00    	je     8006af <vprintfmt+0x44b>
			putch(ch, putdat);
  8005e1:	83 ec 08             	sub    $0x8,%esp
  8005e4:	53                   	push   %ebx
  8005e5:	50                   	push   %eax
  8005e6:	ff d6                	call   *%esi
  8005e8:	83 c4 10             	add    $0x10,%esp
  8005eb:	eb dc                	jmp    8005c9 <vprintfmt+0x365>
		return va_arg(*ap, int);
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8b 10                	mov    (%eax),%edx
  8005f2:	89 d0                	mov    %edx,%eax
  8005f4:	99                   	cltd   
  8005f5:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005f8:	8d 49 04             	lea    0x4(%ecx),%ecx
  8005fb:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005fe:	eb a3                	jmp    8005a3 <vprintfmt+0x33f>
			putch('0', putdat);
  800600:	83 ec 08             	sub    $0x8,%esp
  800603:	53                   	push   %ebx
  800604:	6a 30                	push   $0x30
  800606:	ff d6                	call   *%esi
			putch('x', putdat);
  800608:	83 c4 08             	add    $0x8,%esp
  80060b:	53                   	push   %ebx
  80060c:	6a 78                	push   $0x78
  80060e:	ff d6                	call   *%esi
			num = (unsigned long long)
  800610:	8b 45 14             	mov    0x14(%ebp),%eax
  800613:	8b 10                	mov    (%eax),%edx
  800615:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80061a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80061d:	8d 40 04             	lea    0x4(%eax),%eax
  800620:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800623:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800628:	eb 82                	jmp    8005ac <vprintfmt+0x348>
	if (lflag >= 2)
  80062a:	83 f9 01             	cmp    $0x1,%ecx
  80062d:	7f 1e                	jg     80064d <vprintfmt+0x3e9>
	else if (lflag)
  80062f:	85 c9                	test   %ecx,%ecx
  800631:	74 32                	je     800665 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800633:	8b 45 14             	mov    0x14(%ebp),%eax
  800636:	8b 10                	mov    (%eax),%edx
  800638:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063d:	8d 40 04             	lea    0x4(%eax),%eax
  800640:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800643:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800648:	e9 5f ff ff ff       	jmp    8005ac <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80064d:	8b 45 14             	mov    0x14(%ebp),%eax
  800650:	8b 10                	mov    (%eax),%edx
  800652:	8b 48 04             	mov    0x4(%eax),%ecx
  800655:	8d 40 08             	lea    0x8(%eax),%eax
  800658:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80065b:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800660:	e9 47 ff ff ff       	jmp    8005ac <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800665:	8b 45 14             	mov    0x14(%ebp),%eax
  800668:	8b 10                	mov    (%eax),%edx
  80066a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80066f:	8d 40 04             	lea    0x4(%eax),%eax
  800672:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800675:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80067a:	e9 2d ff ff ff       	jmp    8005ac <vprintfmt+0x348>
			putch(ch, putdat);
  80067f:	83 ec 08             	sub    $0x8,%esp
  800682:	53                   	push   %ebx
  800683:	6a 25                	push   $0x25
  800685:	ff d6                	call   *%esi
			break;
  800687:	83 c4 10             	add    $0x10,%esp
  80068a:	e9 37 ff ff ff       	jmp    8005c6 <vprintfmt+0x362>
			putch('%', putdat);
  80068f:	83 ec 08             	sub    $0x8,%esp
  800692:	53                   	push   %ebx
  800693:	6a 25                	push   $0x25
  800695:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800697:	83 c4 10             	add    $0x10,%esp
  80069a:	89 f8                	mov    %edi,%eax
  80069c:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006a0:	74 05                	je     8006a7 <vprintfmt+0x443>
  8006a2:	83 e8 01             	sub    $0x1,%eax
  8006a5:	eb f5                	jmp    80069c <vprintfmt+0x438>
  8006a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006aa:	e9 17 ff ff ff       	jmp    8005c6 <vprintfmt+0x362>
}
  8006af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006b2:	5b                   	pop    %ebx
  8006b3:	5e                   	pop    %esi
  8006b4:	5f                   	pop    %edi
  8006b5:	5d                   	pop    %ebp
  8006b6:	c3                   	ret    

008006b7 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b7:	f3 0f 1e fb          	endbr32 
  8006bb:	55                   	push   %ebp
  8006bc:	89 e5                	mov    %esp,%ebp
  8006be:	83 ec 18             	sub    $0x18,%esp
  8006c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ca:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ce:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d8:	85 c0                	test   %eax,%eax
  8006da:	74 26                	je     800702 <vsnprintf+0x4b>
  8006dc:	85 d2                	test   %edx,%edx
  8006de:	7e 22                	jle    800702 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e0:	ff 75 14             	pushl  0x14(%ebp)
  8006e3:	ff 75 10             	pushl  0x10(%ebp)
  8006e6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e9:	50                   	push   %eax
  8006ea:	68 22 02 80 00       	push   $0x800222
  8006ef:	e8 70 fb ff ff       	call   800264 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006fd:	83 c4 10             	add    $0x10,%esp
}
  800700:	c9                   	leave  
  800701:	c3                   	ret    
		return -E_INVAL;
  800702:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800707:	eb f7                	jmp    800700 <vsnprintf+0x49>

00800709 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800709:	f3 0f 1e fb          	endbr32 
  80070d:	55                   	push   %ebp
  80070e:	89 e5                	mov    %esp,%ebp
  800710:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800713:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800716:	50                   	push   %eax
  800717:	ff 75 10             	pushl  0x10(%ebp)
  80071a:	ff 75 0c             	pushl  0xc(%ebp)
  80071d:	ff 75 08             	pushl  0x8(%ebp)
  800720:	e8 92 ff ff ff       	call   8006b7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800725:	c9                   	leave  
  800726:	c3                   	ret    

00800727 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800727:	f3 0f 1e fb          	endbr32 
  80072b:	55                   	push   %ebp
  80072c:	89 e5                	mov    %esp,%ebp
  80072e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800731:	b8 00 00 00 00       	mov    $0x0,%eax
  800736:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80073a:	74 05                	je     800741 <strlen+0x1a>
		n++;
  80073c:	83 c0 01             	add    $0x1,%eax
  80073f:	eb f5                	jmp    800736 <strlen+0xf>
	return n;
}
  800741:	5d                   	pop    %ebp
  800742:	c3                   	ret    

00800743 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800743:	f3 0f 1e fb          	endbr32 
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80074d:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800750:	b8 00 00 00 00       	mov    $0x0,%eax
  800755:	39 d0                	cmp    %edx,%eax
  800757:	74 0d                	je     800766 <strnlen+0x23>
  800759:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80075d:	74 05                	je     800764 <strnlen+0x21>
		n++;
  80075f:	83 c0 01             	add    $0x1,%eax
  800762:	eb f1                	jmp    800755 <strnlen+0x12>
  800764:	89 c2                	mov    %eax,%edx
	return n;
}
  800766:	89 d0                	mov    %edx,%eax
  800768:	5d                   	pop    %ebp
  800769:	c3                   	ret    

0080076a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80076a:	f3 0f 1e fb          	endbr32 
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	53                   	push   %ebx
  800772:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800775:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800778:	b8 00 00 00 00       	mov    $0x0,%eax
  80077d:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800781:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800784:	83 c0 01             	add    $0x1,%eax
  800787:	84 d2                	test   %dl,%dl
  800789:	75 f2                	jne    80077d <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80078b:	89 c8                	mov    %ecx,%eax
  80078d:	5b                   	pop    %ebx
  80078e:	5d                   	pop    %ebp
  80078f:	c3                   	ret    

00800790 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800790:	f3 0f 1e fb          	endbr32 
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	53                   	push   %ebx
  800798:	83 ec 10             	sub    $0x10,%esp
  80079b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079e:	53                   	push   %ebx
  80079f:	e8 83 ff ff ff       	call   800727 <strlen>
  8007a4:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007a7:	ff 75 0c             	pushl  0xc(%ebp)
  8007aa:	01 d8                	add    %ebx,%eax
  8007ac:	50                   	push   %eax
  8007ad:	e8 b8 ff ff ff       	call   80076a <strcpy>
	return dst;
}
  8007b2:	89 d8                	mov    %ebx,%eax
  8007b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b7:	c9                   	leave  
  8007b8:	c3                   	ret    

008007b9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b9:	f3 0f 1e fb          	endbr32 
  8007bd:	55                   	push   %ebp
  8007be:	89 e5                	mov    %esp,%ebp
  8007c0:	56                   	push   %esi
  8007c1:	53                   	push   %ebx
  8007c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c8:	89 f3                	mov    %esi,%ebx
  8007ca:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007cd:	89 f0                	mov    %esi,%eax
  8007cf:	39 d8                	cmp    %ebx,%eax
  8007d1:	74 11                	je     8007e4 <strncpy+0x2b>
		*dst++ = *src;
  8007d3:	83 c0 01             	add    $0x1,%eax
  8007d6:	0f b6 0a             	movzbl (%edx),%ecx
  8007d9:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007dc:	80 f9 01             	cmp    $0x1,%cl
  8007df:	83 da ff             	sbb    $0xffffffff,%edx
  8007e2:	eb eb                	jmp    8007cf <strncpy+0x16>
	}
	return ret;
}
  8007e4:	89 f0                	mov    %esi,%eax
  8007e6:	5b                   	pop    %ebx
  8007e7:	5e                   	pop    %esi
  8007e8:	5d                   	pop    %ebp
  8007e9:	c3                   	ret    

008007ea <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ea:	f3 0f 1e fb          	endbr32 
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	56                   	push   %esi
  8007f2:	53                   	push   %ebx
  8007f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f9:	8b 55 10             	mov    0x10(%ebp),%edx
  8007fc:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007fe:	85 d2                	test   %edx,%edx
  800800:	74 21                	je     800823 <strlcpy+0x39>
  800802:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800806:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800808:	39 c2                	cmp    %eax,%edx
  80080a:	74 14                	je     800820 <strlcpy+0x36>
  80080c:	0f b6 19             	movzbl (%ecx),%ebx
  80080f:	84 db                	test   %bl,%bl
  800811:	74 0b                	je     80081e <strlcpy+0x34>
			*dst++ = *src++;
  800813:	83 c1 01             	add    $0x1,%ecx
  800816:	83 c2 01             	add    $0x1,%edx
  800819:	88 5a ff             	mov    %bl,-0x1(%edx)
  80081c:	eb ea                	jmp    800808 <strlcpy+0x1e>
  80081e:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800820:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800823:	29 f0                	sub    %esi,%eax
}
  800825:	5b                   	pop    %ebx
  800826:	5e                   	pop    %esi
  800827:	5d                   	pop    %ebp
  800828:	c3                   	ret    

00800829 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800829:	f3 0f 1e fb          	endbr32 
  80082d:	55                   	push   %ebp
  80082e:	89 e5                	mov    %esp,%ebp
  800830:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800833:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800836:	0f b6 01             	movzbl (%ecx),%eax
  800839:	84 c0                	test   %al,%al
  80083b:	74 0c                	je     800849 <strcmp+0x20>
  80083d:	3a 02                	cmp    (%edx),%al
  80083f:	75 08                	jne    800849 <strcmp+0x20>
		p++, q++;
  800841:	83 c1 01             	add    $0x1,%ecx
  800844:	83 c2 01             	add    $0x1,%edx
  800847:	eb ed                	jmp    800836 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800849:	0f b6 c0             	movzbl %al,%eax
  80084c:	0f b6 12             	movzbl (%edx),%edx
  80084f:	29 d0                	sub    %edx,%eax
}
  800851:	5d                   	pop    %ebp
  800852:	c3                   	ret    

00800853 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800853:	f3 0f 1e fb          	endbr32 
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	53                   	push   %ebx
  80085b:	8b 45 08             	mov    0x8(%ebp),%eax
  80085e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800861:	89 c3                	mov    %eax,%ebx
  800863:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800866:	eb 06                	jmp    80086e <strncmp+0x1b>
		n--, p++, q++;
  800868:	83 c0 01             	add    $0x1,%eax
  80086b:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80086e:	39 d8                	cmp    %ebx,%eax
  800870:	74 16                	je     800888 <strncmp+0x35>
  800872:	0f b6 08             	movzbl (%eax),%ecx
  800875:	84 c9                	test   %cl,%cl
  800877:	74 04                	je     80087d <strncmp+0x2a>
  800879:	3a 0a                	cmp    (%edx),%cl
  80087b:	74 eb                	je     800868 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80087d:	0f b6 00             	movzbl (%eax),%eax
  800880:	0f b6 12             	movzbl (%edx),%edx
  800883:	29 d0                	sub    %edx,%eax
}
  800885:	5b                   	pop    %ebx
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    
		return 0;
  800888:	b8 00 00 00 00       	mov    $0x0,%eax
  80088d:	eb f6                	jmp    800885 <strncmp+0x32>

0080088f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80088f:	f3 0f 1e fb          	endbr32 
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	8b 45 08             	mov    0x8(%ebp),%eax
  800899:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80089d:	0f b6 10             	movzbl (%eax),%edx
  8008a0:	84 d2                	test   %dl,%dl
  8008a2:	74 09                	je     8008ad <strchr+0x1e>
		if (*s == c)
  8008a4:	38 ca                	cmp    %cl,%dl
  8008a6:	74 0a                	je     8008b2 <strchr+0x23>
	for (; *s; s++)
  8008a8:	83 c0 01             	add    $0x1,%eax
  8008ab:	eb f0                	jmp    80089d <strchr+0xe>
			return (char *) s;
	return 0;
  8008ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008b4:	f3 0f 1e fb          	endbr32 
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008be:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008c5:	38 ca                	cmp    %cl,%dl
  8008c7:	74 09                	je     8008d2 <strfind+0x1e>
  8008c9:	84 d2                	test   %dl,%dl
  8008cb:	74 05                	je     8008d2 <strfind+0x1e>
	for (; *s; s++)
  8008cd:	83 c0 01             	add    $0x1,%eax
  8008d0:	eb f0                	jmp    8008c2 <strfind+0xe>
			break;
	return (char *) s;
}
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d4:	f3 0f 1e fb          	endbr32 
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	57                   	push   %edi
  8008dc:	56                   	push   %esi
  8008dd:	53                   	push   %ebx
  8008de:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e4:	85 c9                	test   %ecx,%ecx
  8008e6:	74 31                	je     800919 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e8:	89 f8                	mov    %edi,%eax
  8008ea:	09 c8                	or     %ecx,%eax
  8008ec:	a8 03                	test   $0x3,%al
  8008ee:	75 23                	jne    800913 <memset+0x3f>
		c &= 0xFF;
  8008f0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f4:	89 d3                	mov    %edx,%ebx
  8008f6:	c1 e3 08             	shl    $0x8,%ebx
  8008f9:	89 d0                	mov    %edx,%eax
  8008fb:	c1 e0 18             	shl    $0x18,%eax
  8008fe:	89 d6                	mov    %edx,%esi
  800900:	c1 e6 10             	shl    $0x10,%esi
  800903:	09 f0                	or     %esi,%eax
  800905:	09 c2                	or     %eax,%edx
  800907:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800909:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80090c:	89 d0                	mov    %edx,%eax
  80090e:	fc                   	cld    
  80090f:	f3 ab                	rep stos %eax,%es:(%edi)
  800911:	eb 06                	jmp    800919 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800913:	8b 45 0c             	mov    0xc(%ebp),%eax
  800916:	fc                   	cld    
  800917:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800919:	89 f8                	mov    %edi,%eax
  80091b:	5b                   	pop    %ebx
  80091c:	5e                   	pop    %esi
  80091d:	5f                   	pop    %edi
  80091e:	5d                   	pop    %ebp
  80091f:	c3                   	ret    

00800920 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800920:	f3 0f 1e fb          	endbr32 
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	57                   	push   %edi
  800928:	56                   	push   %esi
  800929:	8b 45 08             	mov    0x8(%ebp),%eax
  80092c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80092f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800932:	39 c6                	cmp    %eax,%esi
  800934:	73 32                	jae    800968 <memmove+0x48>
  800936:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800939:	39 c2                	cmp    %eax,%edx
  80093b:	76 2b                	jbe    800968 <memmove+0x48>
		s += n;
		d += n;
  80093d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800940:	89 fe                	mov    %edi,%esi
  800942:	09 ce                	or     %ecx,%esi
  800944:	09 d6                	or     %edx,%esi
  800946:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80094c:	75 0e                	jne    80095c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80094e:	83 ef 04             	sub    $0x4,%edi
  800951:	8d 72 fc             	lea    -0x4(%edx),%esi
  800954:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800957:	fd                   	std    
  800958:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095a:	eb 09                	jmp    800965 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80095c:	83 ef 01             	sub    $0x1,%edi
  80095f:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800962:	fd                   	std    
  800963:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800965:	fc                   	cld    
  800966:	eb 1a                	jmp    800982 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800968:	89 c2                	mov    %eax,%edx
  80096a:	09 ca                	or     %ecx,%edx
  80096c:	09 f2                	or     %esi,%edx
  80096e:	f6 c2 03             	test   $0x3,%dl
  800971:	75 0a                	jne    80097d <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800973:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800976:	89 c7                	mov    %eax,%edi
  800978:	fc                   	cld    
  800979:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80097b:	eb 05                	jmp    800982 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  80097d:	89 c7                	mov    %eax,%edi
  80097f:	fc                   	cld    
  800980:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800982:	5e                   	pop    %esi
  800983:	5f                   	pop    %edi
  800984:	5d                   	pop    %ebp
  800985:	c3                   	ret    

00800986 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800986:	f3 0f 1e fb          	endbr32 
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800990:	ff 75 10             	pushl  0x10(%ebp)
  800993:	ff 75 0c             	pushl  0xc(%ebp)
  800996:	ff 75 08             	pushl  0x8(%ebp)
  800999:	e8 82 ff ff ff       	call   800920 <memmove>
}
  80099e:	c9                   	leave  
  80099f:	c3                   	ret    

008009a0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a0:	f3 0f 1e fb          	endbr32 
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	56                   	push   %esi
  8009a8:	53                   	push   %ebx
  8009a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009af:	89 c6                	mov    %eax,%esi
  8009b1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b4:	39 f0                	cmp    %esi,%eax
  8009b6:	74 1c                	je     8009d4 <memcmp+0x34>
		if (*s1 != *s2)
  8009b8:	0f b6 08             	movzbl (%eax),%ecx
  8009bb:	0f b6 1a             	movzbl (%edx),%ebx
  8009be:	38 d9                	cmp    %bl,%cl
  8009c0:	75 08                	jne    8009ca <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009c2:	83 c0 01             	add    $0x1,%eax
  8009c5:	83 c2 01             	add    $0x1,%edx
  8009c8:	eb ea                	jmp    8009b4 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  8009ca:	0f b6 c1             	movzbl %cl,%eax
  8009cd:	0f b6 db             	movzbl %bl,%ebx
  8009d0:	29 d8                	sub    %ebx,%eax
  8009d2:	eb 05                	jmp    8009d9 <memcmp+0x39>
	}

	return 0;
  8009d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d9:	5b                   	pop    %ebx
  8009da:	5e                   	pop    %esi
  8009db:	5d                   	pop    %ebp
  8009dc:	c3                   	ret    

008009dd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009dd:	f3 0f 1e fb          	endbr32 
  8009e1:	55                   	push   %ebp
  8009e2:	89 e5                	mov    %esp,%ebp
  8009e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009ea:	89 c2                	mov    %eax,%edx
  8009ec:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009ef:	39 d0                	cmp    %edx,%eax
  8009f1:	73 09                	jae    8009fc <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f3:	38 08                	cmp    %cl,(%eax)
  8009f5:	74 05                	je     8009fc <memfind+0x1f>
	for (; s < ends; s++)
  8009f7:	83 c0 01             	add    $0x1,%eax
  8009fa:	eb f3                	jmp    8009ef <memfind+0x12>
			break;
	return (void *) s;
}
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009fe:	f3 0f 1e fb          	endbr32 
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	57                   	push   %edi
  800a06:	56                   	push   %esi
  800a07:	53                   	push   %ebx
  800a08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0e:	eb 03                	jmp    800a13 <strtol+0x15>
		s++;
  800a10:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a13:	0f b6 01             	movzbl (%ecx),%eax
  800a16:	3c 20                	cmp    $0x20,%al
  800a18:	74 f6                	je     800a10 <strtol+0x12>
  800a1a:	3c 09                	cmp    $0x9,%al
  800a1c:	74 f2                	je     800a10 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a1e:	3c 2b                	cmp    $0x2b,%al
  800a20:	74 2a                	je     800a4c <strtol+0x4e>
	int neg = 0;
  800a22:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a27:	3c 2d                	cmp    $0x2d,%al
  800a29:	74 2b                	je     800a56 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a2b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a31:	75 0f                	jne    800a42 <strtol+0x44>
  800a33:	80 39 30             	cmpb   $0x30,(%ecx)
  800a36:	74 28                	je     800a60 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a38:	85 db                	test   %ebx,%ebx
  800a3a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a3f:	0f 44 d8             	cmove  %eax,%ebx
  800a42:	b8 00 00 00 00       	mov    $0x0,%eax
  800a47:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a4a:	eb 46                	jmp    800a92 <strtol+0x94>
		s++;
  800a4c:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a4f:	bf 00 00 00 00       	mov    $0x0,%edi
  800a54:	eb d5                	jmp    800a2b <strtol+0x2d>
		s++, neg = 1;
  800a56:	83 c1 01             	add    $0x1,%ecx
  800a59:	bf 01 00 00 00       	mov    $0x1,%edi
  800a5e:	eb cb                	jmp    800a2b <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a60:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a64:	74 0e                	je     800a74 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a66:	85 db                	test   %ebx,%ebx
  800a68:	75 d8                	jne    800a42 <strtol+0x44>
		s++, base = 8;
  800a6a:	83 c1 01             	add    $0x1,%ecx
  800a6d:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a72:	eb ce                	jmp    800a42 <strtol+0x44>
		s += 2, base = 16;
  800a74:	83 c1 02             	add    $0x2,%ecx
  800a77:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a7c:	eb c4                	jmp    800a42 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a7e:	0f be d2             	movsbl %dl,%edx
  800a81:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a84:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a87:	7d 3a                	jge    800ac3 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a89:	83 c1 01             	add    $0x1,%ecx
  800a8c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a90:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a92:	0f b6 11             	movzbl (%ecx),%edx
  800a95:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a98:	89 f3                	mov    %esi,%ebx
  800a9a:	80 fb 09             	cmp    $0x9,%bl
  800a9d:	76 df                	jbe    800a7e <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800a9f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aa2:	89 f3                	mov    %esi,%ebx
  800aa4:	80 fb 19             	cmp    $0x19,%bl
  800aa7:	77 08                	ja     800ab1 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800aa9:	0f be d2             	movsbl %dl,%edx
  800aac:	83 ea 57             	sub    $0x57,%edx
  800aaf:	eb d3                	jmp    800a84 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800ab1:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ab4:	89 f3                	mov    %esi,%ebx
  800ab6:	80 fb 19             	cmp    $0x19,%bl
  800ab9:	77 08                	ja     800ac3 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800abb:	0f be d2             	movsbl %dl,%edx
  800abe:	83 ea 37             	sub    $0x37,%edx
  800ac1:	eb c1                	jmp    800a84 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ac3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac7:	74 05                	je     800ace <strtol+0xd0>
		*endptr = (char *) s;
  800ac9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800acc:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ace:	89 c2                	mov    %eax,%edx
  800ad0:	f7 da                	neg    %edx
  800ad2:	85 ff                	test   %edi,%edi
  800ad4:	0f 45 c2             	cmovne %edx,%eax
}
  800ad7:	5b                   	pop    %ebx
  800ad8:	5e                   	pop    %esi
  800ad9:	5f                   	pop    %edi
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    

00800adc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800adc:	f3 0f 1e fb          	endbr32 
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	57                   	push   %edi
  800ae4:	56                   	push   %esi
  800ae5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ae6:	b8 00 00 00 00       	mov    $0x0,%eax
  800aeb:	8b 55 08             	mov    0x8(%ebp),%edx
  800aee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af1:	89 c3                	mov    %eax,%ebx
  800af3:	89 c7                	mov    %eax,%edi
  800af5:	89 c6                	mov    %eax,%esi
  800af7:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5f                   	pop    %edi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <sys_cgetc>:

int
sys_cgetc(void)
{
  800afe:	f3 0f 1e fb          	endbr32 
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b08:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b12:	89 d1                	mov    %edx,%ecx
  800b14:	89 d3                	mov    %edx,%ebx
  800b16:	89 d7                	mov    %edx,%edi
  800b18:	89 d6                	mov    %edx,%esi
  800b1a:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b1c:	5b                   	pop    %ebx
  800b1d:	5e                   	pop    %esi
  800b1e:	5f                   	pop    %edi
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b21:	f3 0f 1e fb          	endbr32 
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	57                   	push   %edi
  800b29:	56                   	push   %esi
  800b2a:	53                   	push   %ebx
  800b2b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b2e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b33:	8b 55 08             	mov    0x8(%ebp),%edx
  800b36:	b8 03 00 00 00       	mov    $0x3,%eax
  800b3b:	89 cb                	mov    %ecx,%ebx
  800b3d:	89 cf                	mov    %ecx,%edi
  800b3f:	89 ce                	mov    %ecx,%esi
  800b41:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b43:	85 c0                	test   %eax,%eax
  800b45:	7f 08                	jg     800b4f <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b4a:	5b                   	pop    %ebx
  800b4b:	5e                   	pop    %esi
  800b4c:	5f                   	pop    %edi
  800b4d:	5d                   	pop    %ebp
  800b4e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b4f:	83 ec 0c             	sub    $0xc,%esp
  800b52:	50                   	push   %eax
  800b53:	6a 03                	push   $0x3
  800b55:	68 a4 12 80 00       	push   $0x8012a4
  800b5a:	6a 23                	push   $0x23
  800b5c:	68 c1 12 80 00       	push   $0x8012c1
  800b61:	e8 11 02 00 00       	call   800d77 <_panic>

00800b66 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b66:	f3 0f 1e fb          	endbr32 
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	57                   	push   %edi
  800b6e:	56                   	push   %esi
  800b6f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b70:	ba 00 00 00 00       	mov    $0x0,%edx
  800b75:	b8 02 00 00 00       	mov    $0x2,%eax
  800b7a:	89 d1                	mov    %edx,%ecx
  800b7c:	89 d3                	mov    %edx,%ebx
  800b7e:	89 d7                	mov    %edx,%edi
  800b80:	89 d6                	mov    %edx,%esi
  800b82:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5f                   	pop    %edi
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    

00800b89 <sys_yield>:

void
sys_yield(void)
{
  800b89:	f3 0f 1e fb          	endbr32 
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	57                   	push   %edi
  800b91:	56                   	push   %esi
  800b92:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b93:	ba 00 00 00 00       	mov    $0x0,%edx
  800b98:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b9d:	89 d1                	mov    %edx,%ecx
  800b9f:	89 d3                	mov    %edx,%ebx
  800ba1:	89 d7                	mov    %edx,%edi
  800ba3:	89 d6                	mov    %edx,%esi
  800ba5:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ba7:	5b                   	pop    %ebx
  800ba8:	5e                   	pop    %esi
  800ba9:	5f                   	pop    %edi
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bac:	f3 0f 1e fb          	endbr32 
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	57                   	push   %edi
  800bb4:	56                   	push   %esi
  800bb5:	53                   	push   %ebx
  800bb6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bb9:	be 00 00 00 00       	mov    $0x0,%esi
  800bbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc4:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bcc:	89 f7                	mov    %esi,%edi
  800bce:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bd0:	85 c0                	test   %eax,%eax
  800bd2:	7f 08                	jg     800bdc <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd7:	5b                   	pop    %ebx
  800bd8:	5e                   	pop    %esi
  800bd9:	5f                   	pop    %edi
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdc:	83 ec 0c             	sub    $0xc,%esp
  800bdf:	50                   	push   %eax
  800be0:	6a 04                	push   $0x4
  800be2:	68 a4 12 80 00       	push   $0x8012a4
  800be7:	6a 23                	push   $0x23
  800be9:	68 c1 12 80 00       	push   $0x8012c1
  800bee:	e8 84 01 00 00       	call   800d77 <_panic>

00800bf3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf3:	f3 0f 1e fb          	endbr32 
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	57                   	push   %edi
  800bfb:	56                   	push   %esi
  800bfc:	53                   	push   %ebx
  800bfd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c00:	8b 55 08             	mov    0x8(%ebp),%edx
  800c03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c06:	b8 05 00 00 00       	mov    $0x5,%eax
  800c0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c0e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c11:	8b 75 18             	mov    0x18(%ebp),%esi
  800c14:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c16:	85 c0                	test   %eax,%eax
  800c18:	7f 08                	jg     800c22 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1d:	5b                   	pop    %ebx
  800c1e:	5e                   	pop    %esi
  800c1f:	5f                   	pop    %edi
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c22:	83 ec 0c             	sub    $0xc,%esp
  800c25:	50                   	push   %eax
  800c26:	6a 05                	push   $0x5
  800c28:	68 a4 12 80 00       	push   $0x8012a4
  800c2d:	6a 23                	push   $0x23
  800c2f:	68 c1 12 80 00       	push   $0x8012c1
  800c34:	e8 3e 01 00 00       	call   800d77 <_panic>

00800c39 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c39:	f3 0f 1e fb          	endbr32 
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
  800c43:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c46:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c51:	b8 06 00 00 00       	mov    $0x6,%eax
  800c56:	89 df                	mov    %ebx,%edi
  800c58:	89 de                	mov    %ebx,%esi
  800c5a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c5c:	85 c0                	test   %eax,%eax
  800c5e:	7f 08                	jg     800c68 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c63:	5b                   	pop    %ebx
  800c64:	5e                   	pop    %esi
  800c65:	5f                   	pop    %edi
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c68:	83 ec 0c             	sub    $0xc,%esp
  800c6b:	50                   	push   %eax
  800c6c:	6a 06                	push   $0x6
  800c6e:	68 a4 12 80 00       	push   $0x8012a4
  800c73:	6a 23                	push   $0x23
  800c75:	68 c1 12 80 00       	push   $0x8012c1
  800c7a:	e8 f8 00 00 00       	call   800d77 <_panic>

00800c7f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c7f:	f3 0f 1e fb          	endbr32 
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	57                   	push   %edi
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
  800c89:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c8c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c91:	8b 55 08             	mov    0x8(%ebp),%edx
  800c94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c97:	b8 08 00 00 00       	mov    $0x8,%eax
  800c9c:	89 df                	mov    %ebx,%edi
  800c9e:	89 de                	mov    %ebx,%esi
  800ca0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca2:	85 c0                	test   %eax,%eax
  800ca4:	7f 08                	jg     800cae <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ca6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca9:	5b                   	pop    %ebx
  800caa:	5e                   	pop    %esi
  800cab:	5f                   	pop    %edi
  800cac:	5d                   	pop    %ebp
  800cad:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cae:	83 ec 0c             	sub    $0xc,%esp
  800cb1:	50                   	push   %eax
  800cb2:	6a 08                	push   $0x8
  800cb4:	68 a4 12 80 00       	push   $0x8012a4
  800cb9:	6a 23                	push   $0x23
  800cbb:	68 c1 12 80 00       	push   $0x8012c1
  800cc0:	e8 b2 00 00 00       	call   800d77 <_panic>

00800cc5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc5:	f3 0f 1e fb          	endbr32 
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	57                   	push   %edi
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
  800ccf:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdd:	b8 09 00 00 00       	mov    $0x9,%eax
  800ce2:	89 df                	mov    %ebx,%edi
  800ce4:	89 de                	mov    %ebx,%esi
  800ce6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce8:	85 c0                	test   %eax,%eax
  800cea:	7f 08                	jg     800cf4 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf4:	83 ec 0c             	sub    $0xc,%esp
  800cf7:	50                   	push   %eax
  800cf8:	6a 09                	push   $0x9
  800cfa:	68 a4 12 80 00       	push   $0x8012a4
  800cff:	6a 23                	push   $0x23
  800d01:	68 c1 12 80 00       	push   $0x8012c1
  800d06:	e8 6c 00 00 00       	call   800d77 <_panic>

00800d0b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d0b:	f3 0f 1e fb          	endbr32 
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	57                   	push   %edi
  800d13:	56                   	push   %esi
  800d14:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d15:	8b 55 08             	mov    0x8(%ebp),%edx
  800d18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d20:	be 00 00 00 00       	mov    $0x0,%esi
  800d25:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d28:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d2b:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d2d:	5b                   	pop    %ebx
  800d2e:	5e                   	pop    %esi
  800d2f:	5f                   	pop    %edi
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    

00800d32 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d32:	f3 0f 1e fb          	endbr32 
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	57                   	push   %edi
  800d3a:	56                   	push   %esi
  800d3b:	53                   	push   %ebx
  800d3c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d3f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d44:	8b 55 08             	mov    0x8(%ebp),%edx
  800d47:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d4c:	89 cb                	mov    %ecx,%ebx
  800d4e:	89 cf                	mov    %ecx,%edi
  800d50:	89 ce                	mov    %ecx,%esi
  800d52:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d54:	85 c0                	test   %eax,%eax
  800d56:	7f 08                	jg     800d60 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5b:	5b                   	pop    %ebx
  800d5c:	5e                   	pop    %esi
  800d5d:	5f                   	pop    %edi
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d60:	83 ec 0c             	sub    $0xc,%esp
  800d63:	50                   	push   %eax
  800d64:	6a 0c                	push   $0xc
  800d66:	68 a4 12 80 00       	push   $0x8012a4
  800d6b:	6a 23                	push   $0x23
  800d6d:	68 c1 12 80 00       	push   $0x8012c1
  800d72:	e8 00 00 00 00       	call   800d77 <_panic>

00800d77 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d77:	f3 0f 1e fb          	endbr32 
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	56                   	push   %esi
  800d7f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d80:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d83:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d89:	e8 d8 fd ff ff       	call   800b66 <sys_getenvid>
  800d8e:	83 ec 0c             	sub    $0xc,%esp
  800d91:	ff 75 0c             	pushl  0xc(%ebp)
  800d94:	ff 75 08             	pushl  0x8(%ebp)
  800d97:	56                   	push   %esi
  800d98:	50                   	push   %eax
  800d99:	68 d0 12 80 00       	push   $0x8012d0
  800d9e:	e8 be f3 ff ff       	call   800161 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800da3:	83 c4 18             	add    $0x18,%esp
  800da6:	53                   	push   %ebx
  800da7:	ff 75 10             	pushl  0x10(%ebp)
  800daa:	e8 5d f3 ff ff       	call   80010c <vcprintf>
	cprintf("\n");
  800daf:	c7 04 24 4c 10 80 00 	movl   $0x80104c,(%esp)
  800db6:	e8 a6 f3 ff ff       	call   800161 <cprintf>
  800dbb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800dbe:	cc                   	int3   
  800dbf:	eb fd                	jmp    800dbe <_panic+0x47>
  800dc1:	66 90                	xchg   %ax,%ax
  800dc3:	66 90                	xchg   %ax,%ax
  800dc5:	66 90                	xchg   %ax,%ax
  800dc7:	66 90                	xchg   %ax,%ax
  800dc9:	66 90                	xchg   %ax,%ax
  800dcb:	66 90                	xchg   %ax,%ax
  800dcd:	66 90                	xchg   %ax,%ax
  800dcf:	90                   	nop

00800dd0 <__udivdi3>:
  800dd0:	f3 0f 1e fb          	endbr32 
  800dd4:	55                   	push   %ebp
  800dd5:	57                   	push   %edi
  800dd6:	56                   	push   %esi
  800dd7:	53                   	push   %ebx
  800dd8:	83 ec 1c             	sub    $0x1c,%esp
  800ddb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800ddf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800de3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800de7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800deb:	85 d2                	test   %edx,%edx
  800ded:	75 19                	jne    800e08 <__udivdi3+0x38>
  800def:	39 f3                	cmp    %esi,%ebx
  800df1:	76 4d                	jbe    800e40 <__udivdi3+0x70>
  800df3:	31 ff                	xor    %edi,%edi
  800df5:	89 e8                	mov    %ebp,%eax
  800df7:	89 f2                	mov    %esi,%edx
  800df9:	f7 f3                	div    %ebx
  800dfb:	89 fa                	mov    %edi,%edx
  800dfd:	83 c4 1c             	add    $0x1c,%esp
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    
  800e05:	8d 76 00             	lea    0x0(%esi),%esi
  800e08:	39 f2                	cmp    %esi,%edx
  800e0a:	76 14                	jbe    800e20 <__udivdi3+0x50>
  800e0c:	31 ff                	xor    %edi,%edi
  800e0e:	31 c0                	xor    %eax,%eax
  800e10:	89 fa                	mov    %edi,%edx
  800e12:	83 c4 1c             	add    $0x1c,%esp
  800e15:	5b                   	pop    %ebx
  800e16:	5e                   	pop    %esi
  800e17:	5f                   	pop    %edi
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    
  800e1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e20:	0f bd fa             	bsr    %edx,%edi
  800e23:	83 f7 1f             	xor    $0x1f,%edi
  800e26:	75 48                	jne    800e70 <__udivdi3+0xa0>
  800e28:	39 f2                	cmp    %esi,%edx
  800e2a:	72 06                	jb     800e32 <__udivdi3+0x62>
  800e2c:	31 c0                	xor    %eax,%eax
  800e2e:	39 eb                	cmp    %ebp,%ebx
  800e30:	77 de                	ja     800e10 <__udivdi3+0x40>
  800e32:	b8 01 00 00 00       	mov    $0x1,%eax
  800e37:	eb d7                	jmp    800e10 <__udivdi3+0x40>
  800e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e40:	89 d9                	mov    %ebx,%ecx
  800e42:	85 db                	test   %ebx,%ebx
  800e44:	75 0b                	jne    800e51 <__udivdi3+0x81>
  800e46:	b8 01 00 00 00       	mov    $0x1,%eax
  800e4b:	31 d2                	xor    %edx,%edx
  800e4d:	f7 f3                	div    %ebx
  800e4f:	89 c1                	mov    %eax,%ecx
  800e51:	31 d2                	xor    %edx,%edx
  800e53:	89 f0                	mov    %esi,%eax
  800e55:	f7 f1                	div    %ecx
  800e57:	89 c6                	mov    %eax,%esi
  800e59:	89 e8                	mov    %ebp,%eax
  800e5b:	89 f7                	mov    %esi,%edi
  800e5d:	f7 f1                	div    %ecx
  800e5f:	89 fa                	mov    %edi,%edx
  800e61:	83 c4 1c             	add    $0x1c,%esp
  800e64:	5b                   	pop    %ebx
  800e65:	5e                   	pop    %esi
  800e66:	5f                   	pop    %edi
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    
  800e69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e70:	89 f9                	mov    %edi,%ecx
  800e72:	b8 20 00 00 00       	mov    $0x20,%eax
  800e77:	29 f8                	sub    %edi,%eax
  800e79:	d3 e2                	shl    %cl,%edx
  800e7b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e7f:	89 c1                	mov    %eax,%ecx
  800e81:	89 da                	mov    %ebx,%edx
  800e83:	d3 ea                	shr    %cl,%edx
  800e85:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e89:	09 d1                	or     %edx,%ecx
  800e8b:	89 f2                	mov    %esi,%edx
  800e8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e91:	89 f9                	mov    %edi,%ecx
  800e93:	d3 e3                	shl    %cl,%ebx
  800e95:	89 c1                	mov    %eax,%ecx
  800e97:	d3 ea                	shr    %cl,%edx
  800e99:	89 f9                	mov    %edi,%ecx
  800e9b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e9f:	89 eb                	mov    %ebp,%ebx
  800ea1:	d3 e6                	shl    %cl,%esi
  800ea3:	89 c1                	mov    %eax,%ecx
  800ea5:	d3 eb                	shr    %cl,%ebx
  800ea7:	09 de                	or     %ebx,%esi
  800ea9:	89 f0                	mov    %esi,%eax
  800eab:	f7 74 24 08          	divl   0x8(%esp)
  800eaf:	89 d6                	mov    %edx,%esi
  800eb1:	89 c3                	mov    %eax,%ebx
  800eb3:	f7 64 24 0c          	mull   0xc(%esp)
  800eb7:	39 d6                	cmp    %edx,%esi
  800eb9:	72 15                	jb     800ed0 <__udivdi3+0x100>
  800ebb:	89 f9                	mov    %edi,%ecx
  800ebd:	d3 e5                	shl    %cl,%ebp
  800ebf:	39 c5                	cmp    %eax,%ebp
  800ec1:	73 04                	jae    800ec7 <__udivdi3+0xf7>
  800ec3:	39 d6                	cmp    %edx,%esi
  800ec5:	74 09                	je     800ed0 <__udivdi3+0x100>
  800ec7:	89 d8                	mov    %ebx,%eax
  800ec9:	31 ff                	xor    %edi,%edi
  800ecb:	e9 40 ff ff ff       	jmp    800e10 <__udivdi3+0x40>
  800ed0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800ed3:	31 ff                	xor    %edi,%edi
  800ed5:	e9 36 ff ff ff       	jmp    800e10 <__udivdi3+0x40>
  800eda:	66 90                	xchg   %ax,%ax
  800edc:	66 90                	xchg   %ax,%ax
  800ede:	66 90                	xchg   %ax,%ax

00800ee0 <__umoddi3>:
  800ee0:	f3 0f 1e fb          	endbr32 
  800ee4:	55                   	push   %ebp
  800ee5:	57                   	push   %edi
  800ee6:	56                   	push   %esi
  800ee7:	53                   	push   %ebx
  800ee8:	83 ec 1c             	sub    $0x1c,%esp
  800eeb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800eef:	8b 74 24 30          	mov    0x30(%esp),%esi
  800ef3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800ef7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800efb:	85 c0                	test   %eax,%eax
  800efd:	75 19                	jne    800f18 <__umoddi3+0x38>
  800eff:	39 df                	cmp    %ebx,%edi
  800f01:	76 5d                	jbe    800f60 <__umoddi3+0x80>
  800f03:	89 f0                	mov    %esi,%eax
  800f05:	89 da                	mov    %ebx,%edx
  800f07:	f7 f7                	div    %edi
  800f09:	89 d0                	mov    %edx,%eax
  800f0b:	31 d2                	xor    %edx,%edx
  800f0d:	83 c4 1c             	add    $0x1c,%esp
  800f10:	5b                   	pop    %ebx
  800f11:	5e                   	pop    %esi
  800f12:	5f                   	pop    %edi
  800f13:	5d                   	pop    %ebp
  800f14:	c3                   	ret    
  800f15:	8d 76 00             	lea    0x0(%esi),%esi
  800f18:	89 f2                	mov    %esi,%edx
  800f1a:	39 d8                	cmp    %ebx,%eax
  800f1c:	76 12                	jbe    800f30 <__umoddi3+0x50>
  800f1e:	89 f0                	mov    %esi,%eax
  800f20:	89 da                	mov    %ebx,%edx
  800f22:	83 c4 1c             	add    $0x1c,%esp
  800f25:	5b                   	pop    %ebx
  800f26:	5e                   	pop    %esi
  800f27:	5f                   	pop    %edi
  800f28:	5d                   	pop    %ebp
  800f29:	c3                   	ret    
  800f2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f30:	0f bd e8             	bsr    %eax,%ebp
  800f33:	83 f5 1f             	xor    $0x1f,%ebp
  800f36:	75 50                	jne    800f88 <__umoddi3+0xa8>
  800f38:	39 d8                	cmp    %ebx,%eax
  800f3a:	0f 82 e0 00 00 00    	jb     801020 <__umoddi3+0x140>
  800f40:	89 d9                	mov    %ebx,%ecx
  800f42:	39 f7                	cmp    %esi,%edi
  800f44:	0f 86 d6 00 00 00    	jbe    801020 <__umoddi3+0x140>
  800f4a:	89 d0                	mov    %edx,%eax
  800f4c:	89 ca                	mov    %ecx,%edx
  800f4e:	83 c4 1c             	add    $0x1c,%esp
  800f51:	5b                   	pop    %ebx
  800f52:	5e                   	pop    %esi
  800f53:	5f                   	pop    %edi
  800f54:	5d                   	pop    %ebp
  800f55:	c3                   	ret    
  800f56:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f5d:	8d 76 00             	lea    0x0(%esi),%esi
  800f60:	89 fd                	mov    %edi,%ebp
  800f62:	85 ff                	test   %edi,%edi
  800f64:	75 0b                	jne    800f71 <__umoddi3+0x91>
  800f66:	b8 01 00 00 00       	mov    $0x1,%eax
  800f6b:	31 d2                	xor    %edx,%edx
  800f6d:	f7 f7                	div    %edi
  800f6f:	89 c5                	mov    %eax,%ebp
  800f71:	89 d8                	mov    %ebx,%eax
  800f73:	31 d2                	xor    %edx,%edx
  800f75:	f7 f5                	div    %ebp
  800f77:	89 f0                	mov    %esi,%eax
  800f79:	f7 f5                	div    %ebp
  800f7b:	89 d0                	mov    %edx,%eax
  800f7d:	31 d2                	xor    %edx,%edx
  800f7f:	eb 8c                	jmp    800f0d <__umoddi3+0x2d>
  800f81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f88:	89 e9                	mov    %ebp,%ecx
  800f8a:	ba 20 00 00 00       	mov    $0x20,%edx
  800f8f:	29 ea                	sub    %ebp,%edx
  800f91:	d3 e0                	shl    %cl,%eax
  800f93:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f97:	89 d1                	mov    %edx,%ecx
  800f99:	89 f8                	mov    %edi,%eax
  800f9b:	d3 e8                	shr    %cl,%eax
  800f9d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800fa1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fa5:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fa9:	09 c1                	or     %eax,%ecx
  800fab:	89 d8                	mov    %ebx,%eax
  800fad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fb1:	89 e9                	mov    %ebp,%ecx
  800fb3:	d3 e7                	shl    %cl,%edi
  800fb5:	89 d1                	mov    %edx,%ecx
  800fb7:	d3 e8                	shr    %cl,%eax
  800fb9:	89 e9                	mov    %ebp,%ecx
  800fbb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fbf:	d3 e3                	shl    %cl,%ebx
  800fc1:	89 c7                	mov    %eax,%edi
  800fc3:	89 d1                	mov    %edx,%ecx
  800fc5:	89 f0                	mov    %esi,%eax
  800fc7:	d3 e8                	shr    %cl,%eax
  800fc9:	89 e9                	mov    %ebp,%ecx
  800fcb:	89 fa                	mov    %edi,%edx
  800fcd:	d3 e6                	shl    %cl,%esi
  800fcf:	09 d8                	or     %ebx,%eax
  800fd1:	f7 74 24 08          	divl   0x8(%esp)
  800fd5:	89 d1                	mov    %edx,%ecx
  800fd7:	89 f3                	mov    %esi,%ebx
  800fd9:	f7 64 24 0c          	mull   0xc(%esp)
  800fdd:	89 c6                	mov    %eax,%esi
  800fdf:	89 d7                	mov    %edx,%edi
  800fe1:	39 d1                	cmp    %edx,%ecx
  800fe3:	72 06                	jb     800feb <__umoddi3+0x10b>
  800fe5:	75 10                	jne    800ff7 <__umoddi3+0x117>
  800fe7:	39 c3                	cmp    %eax,%ebx
  800fe9:	73 0c                	jae    800ff7 <__umoddi3+0x117>
  800feb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800fef:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800ff3:	89 d7                	mov    %edx,%edi
  800ff5:	89 c6                	mov    %eax,%esi
  800ff7:	89 ca                	mov    %ecx,%edx
  800ff9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ffe:	29 f3                	sub    %esi,%ebx
  801000:	19 fa                	sbb    %edi,%edx
  801002:	89 d0                	mov    %edx,%eax
  801004:	d3 e0                	shl    %cl,%eax
  801006:	89 e9                	mov    %ebp,%ecx
  801008:	d3 eb                	shr    %cl,%ebx
  80100a:	d3 ea                	shr    %cl,%edx
  80100c:	09 d8                	or     %ebx,%eax
  80100e:	83 c4 1c             	add    $0x1c,%esp
  801011:	5b                   	pop    %ebx
  801012:	5e                   	pop    %esi
  801013:	5f                   	pop    %edi
  801014:	5d                   	pop    %ebp
  801015:	c3                   	ret    
  801016:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80101d:	8d 76 00             	lea    0x0(%esi),%esi
  801020:	29 fe                	sub    %edi,%esi
  801022:	19 c3                	sbb    %eax,%ebx
  801024:	89 f2                	mov    %esi,%edx
  801026:	89 d9                	mov    %ebx,%ecx
  801028:	e9 1d ff ff ff       	jmp    800f4a <__umoddi3+0x6a>
