
obj/user/faultread:     file format elf32-i386


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
  80002c:	e8 21 00 00 00       	call   800052 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 10             	sub    $0x10,%esp
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  80003d:	ff 35 00 00 00 00    	pushl  0x0
  800043:	68 c0 1e 80 00       	push   $0x801ec0
  800048:	e8 14 01 00 00       	call   800161 <cprintf>
}
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	c9                   	leave  
  800051:	c3                   	ret    

00800052 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800052:	f3 0f 1e fb          	endbr32 
  800056:	55                   	push   %ebp
  800057:	89 e5                	mov    %esp,%ebp
  800059:	56                   	push   %esi
  80005a:	53                   	push   %ebx
  80005b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800061:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800068:	00 00 00 
    envid_t envid = sys_getenvid();
  80006b:	e8 f6 0a 00 00       	call   800b66 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 db                	test   %ebx,%ebx
  800084:	7e 07                	jle    80008d <libmain+0x3b>
		binaryname = argv[0];
  800086:	8b 06                	mov    (%esi),%eax
  800088:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80008d:	83 ec 08             	sub    $0x8,%esp
  800090:	56                   	push   %esi
  800091:	53                   	push   %ebx
  800092:	e8 9c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800097:	e8 0a 00 00 00       	call   8000a6 <exit>
}
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a2:	5b                   	pop    %ebx
  8000a3:	5e                   	pop    %esi
  8000a4:	5d                   	pop    %ebp
  8000a5:	c3                   	ret    

008000a6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a6:	f3 0f 1e fb          	endbr32 
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b0:	e8 f7 0e 00 00       	call   800fac <close_all>
	sys_env_destroy(0);
  8000b5:	83 ec 0c             	sub    $0xc,%esp
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
  8001c7:	e8 94 1a 00 00       	call   801c60 <__udivdi3>
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
  800205:	e8 66 1b 00 00       	call   801d70 <__umoddi3>
  80020a:	83 c4 14             	add    $0x14,%esp
  80020d:	0f be 80 e8 1e 80 00 	movsbl 0x801ee8(%eax),%eax
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
  8002b4:	3e ff 24 85 20 20 80 	notrack jmp *0x802020(,%eax,4)
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
  80037c:	83 f8 0f             	cmp    $0xf,%eax
  80037f:	7f 23                	jg     8003a4 <vprintfmt+0x140>
  800381:	8b 14 85 80 21 80 00 	mov    0x802180(,%eax,4),%edx
  800388:	85 d2                	test   %edx,%edx
  80038a:	74 18                	je     8003a4 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80038c:	52                   	push   %edx
  80038d:	68 da 22 80 00       	push   $0x8022da
  800392:	53                   	push   %ebx
  800393:	56                   	push   %esi
  800394:	e8 aa fe ff ff       	call   800243 <printfmt>
  800399:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80039c:	89 7d 14             	mov    %edi,0x14(%ebp)
  80039f:	e9 22 02 00 00       	jmp    8005c6 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8003a4:	50                   	push   %eax
  8003a5:	68 00 1f 80 00       	push   $0x801f00
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
  8003cc:	b8 f9 1e 80 00       	mov    $0x801ef9,%eax
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
  800b55:	68 df 21 80 00       	push   $0x8021df
  800b5a:	6a 23                	push   $0x23
  800b5c:	68 fc 21 80 00       	push   $0x8021fc
  800b61:	e8 70 0f 00 00       	call   801ad6 <_panic>

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
  800b98:	b8 0b 00 00 00       	mov    $0xb,%eax
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
  800be2:	68 df 21 80 00       	push   $0x8021df
  800be7:	6a 23                	push   $0x23
  800be9:	68 fc 21 80 00       	push   $0x8021fc
  800bee:	e8 e3 0e 00 00       	call   801ad6 <_panic>

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
  800c28:	68 df 21 80 00       	push   $0x8021df
  800c2d:	6a 23                	push   $0x23
  800c2f:	68 fc 21 80 00       	push   $0x8021fc
  800c34:	e8 9d 0e 00 00       	call   801ad6 <_panic>

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
  800c6e:	68 df 21 80 00       	push   $0x8021df
  800c73:	6a 23                	push   $0x23
  800c75:	68 fc 21 80 00       	push   $0x8021fc
  800c7a:	e8 57 0e 00 00       	call   801ad6 <_panic>

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
  800cb4:	68 df 21 80 00       	push   $0x8021df
  800cb9:	6a 23                	push   $0x23
  800cbb:	68 fc 21 80 00       	push   $0x8021fc
  800cc0:	e8 11 0e 00 00       	call   801ad6 <_panic>

00800cc5 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800cea:	7f 08                	jg     800cf4 <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
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
  800cfa:	68 df 21 80 00       	push   $0x8021df
  800cff:	6a 23                	push   $0x23
  800d01:	68 fc 21 80 00       	push   $0x8021fc
  800d06:	e8 cb 0d 00 00       	call   801ad6 <_panic>

00800d0b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d0b:	f3 0f 1e fb          	endbr32 
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	57                   	push   %edi
  800d13:	56                   	push   %esi
  800d14:	53                   	push   %ebx
  800d15:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d18:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d23:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d28:	89 df                	mov    %ebx,%edi
  800d2a:	89 de                	mov    %ebx,%esi
  800d2c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d2e:	85 c0                	test   %eax,%eax
  800d30:	7f 08                	jg     800d3a <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3a:	83 ec 0c             	sub    $0xc,%esp
  800d3d:	50                   	push   %eax
  800d3e:	6a 0a                	push   $0xa
  800d40:	68 df 21 80 00       	push   $0x8021df
  800d45:	6a 23                	push   $0x23
  800d47:	68 fc 21 80 00       	push   $0x8021fc
  800d4c:	e8 85 0d 00 00       	call   801ad6 <_panic>

00800d51 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d51:	f3 0f 1e fb          	endbr32 
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	57                   	push   %edi
  800d59:	56                   	push   %esi
  800d5a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d61:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d66:	be 00 00 00 00       	mov    $0x0,%esi
  800d6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d6e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d71:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5f                   	pop    %edi
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    

00800d78 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d78:	f3 0f 1e fb          	endbr32 
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	57                   	push   %edi
  800d80:	56                   	push   %esi
  800d81:	53                   	push   %ebx
  800d82:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d85:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d92:	89 cb                	mov    %ecx,%ebx
  800d94:	89 cf                	mov    %ecx,%edi
  800d96:	89 ce                	mov    %ecx,%esi
  800d98:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d9a:	85 c0                	test   %eax,%eax
  800d9c:	7f 08                	jg     800da6 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da1:	5b                   	pop    %ebx
  800da2:	5e                   	pop    %esi
  800da3:	5f                   	pop    %edi
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800da6:	83 ec 0c             	sub    $0xc,%esp
  800da9:	50                   	push   %eax
  800daa:	6a 0d                	push   $0xd
  800dac:	68 df 21 80 00       	push   $0x8021df
  800db1:	6a 23                	push   $0x23
  800db3:	68 fc 21 80 00       	push   $0x8021fc
  800db8:	e8 19 0d 00 00       	call   801ad6 <_panic>

00800dbd <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dbd:	f3 0f 1e fb          	endbr32 
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc7:	05 00 00 00 30       	add    $0x30000000,%eax
  800dcc:	c1 e8 0c             	shr    $0xc,%eax
}
  800dcf:	5d                   	pop    %ebp
  800dd0:	c3                   	ret    

00800dd1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dd1:	f3 0f 1e fb          	endbr32 
  800dd5:	55                   	push   %ebp
  800dd6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddb:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800de0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800de5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800dea:	5d                   	pop    %ebp
  800deb:	c3                   	ret    

00800dec <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dec:	f3 0f 1e fb          	endbr32 
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800df8:	89 c2                	mov    %eax,%edx
  800dfa:	c1 ea 16             	shr    $0x16,%edx
  800dfd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e04:	f6 c2 01             	test   $0x1,%dl
  800e07:	74 2d                	je     800e36 <fd_alloc+0x4a>
  800e09:	89 c2                	mov    %eax,%edx
  800e0b:	c1 ea 0c             	shr    $0xc,%edx
  800e0e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e15:	f6 c2 01             	test   $0x1,%dl
  800e18:	74 1c                	je     800e36 <fd_alloc+0x4a>
  800e1a:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800e1f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e24:	75 d2                	jne    800df8 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e26:	8b 45 08             	mov    0x8(%ebp),%eax
  800e29:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800e2f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800e34:	eb 0a                	jmp    800e40 <fd_alloc+0x54>
			*fd_store = fd;
  800e36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e39:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e40:	5d                   	pop    %ebp
  800e41:	c3                   	ret    

00800e42 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e42:	f3 0f 1e fb          	endbr32 
  800e46:	55                   	push   %ebp
  800e47:	89 e5                	mov    %esp,%ebp
  800e49:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e4c:	83 f8 1f             	cmp    $0x1f,%eax
  800e4f:	77 30                	ja     800e81 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e51:	c1 e0 0c             	shl    $0xc,%eax
  800e54:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e59:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800e5f:	f6 c2 01             	test   $0x1,%dl
  800e62:	74 24                	je     800e88 <fd_lookup+0x46>
  800e64:	89 c2                	mov    %eax,%edx
  800e66:	c1 ea 0c             	shr    $0xc,%edx
  800e69:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e70:	f6 c2 01             	test   $0x1,%dl
  800e73:	74 1a                	je     800e8f <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e75:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e78:	89 02                	mov    %eax,(%edx)
	return 0;
  800e7a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    
		return -E_INVAL;
  800e81:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e86:	eb f7                	jmp    800e7f <fd_lookup+0x3d>
		return -E_INVAL;
  800e88:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e8d:	eb f0                	jmp    800e7f <fd_lookup+0x3d>
  800e8f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e94:	eb e9                	jmp    800e7f <fd_lookup+0x3d>

00800e96 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e96:	f3 0f 1e fb          	endbr32 
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	83 ec 08             	sub    $0x8,%esp
  800ea0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ea3:	ba 88 22 80 00       	mov    $0x802288,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ea8:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800ead:	39 08                	cmp    %ecx,(%eax)
  800eaf:	74 33                	je     800ee4 <dev_lookup+0x4e>
  800eb1:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800eb4:	8b 02                	mov    (%edx),%eax
  800eb6:	85 c0                	test   %eax,%eax
  800eb8:	75 f3                	jne    800ead <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800eba:	a1 04 40 80 00       	mov    0x804004,%eax
  800ebf:	8b 40 48             	mov    0x48(%eax),%eax
  800ec2:	83 ec 04             	sub    $0x4,%esp
  800ec5:	51                   	push   %ecx
  800ec6:	50                   	push   %eax
  800ec7:	68 0c 22 80 00       	push   $0x80220c
  800ecc:	e8 90 f2 ff ff       	call   800161 <cprintf>
	*dev = 0;
  800ed1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ed4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800eda:	83 c4 10             	add    $0x10,%esp
  800edd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ee2:	c9                   	leave  
  800ee3:	c3                   	ret    
			*dev = devtab[i];
  800ee4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee7:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ee9:	b8 00 00 00 00       	mov    $0x0,%eax
  800eee:	eb f2                	jmp    800ee2 <dev_lookup+0x4c>

00800ef0 <fd_close>:
{
  800ef0:	f3 0f 1e fb          	endbr32 
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	57                   	push   %edi
  800ef8:	56                   	push   %esi
  800ef9:	53                   	push   %ebx
  800efa:	83 ec 24             	sub    $0x24,%esp
  800efd:	8b 75 08             	mov    0x8(%ebp),%esi
  800f00:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f03:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f06:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f07:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f0d:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f10:	50                   	push   %eax
  800f11:	e8 2c ff ff ff       	call   800e42 <fd_lookup>
  800f16:	89 c3                	mov    %eax,%ebx
  800f18:	83 c4 10             	add    $0x10,%esp
  800f1b:	85 c0                	test   %eax,%eax
  800f1d:	78 05                	js     800f24 <fd_close+0x34>
	    || fd != fd2)
  800f1f:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800f22:	74 16                	je     800f3a <fd_close+0x4a>
		return (must_exist ? r : 0);
  800f24:	89 f8                	mov    %edi,%eax
  800f26:	84 c0                	test   %al,%al
  800f28:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2d:	0f 44 d8             	cmove  %eax,%ebx
}
  800f30:	89 d8                	mov    %ebx,%eax
  800f32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f35:	5b                   	pop    %ebx
  800f36:	5e                   	pop    %esi
  800f37:	5f                   	pop    %edi
  800f38:	5d                   	pop    %ebp
  800f39:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f3a:	83 ec 08             	sub    $0x8,%esp
  800f3d:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f40:	50                   	push   %eax
  800f41:	ff 36                	pushl  (%esi)
  800f43:	e8 4e ff ff ff       	call   800e96 <dev_lookup>
  800f48:	89 c3                	mov    %eax,%ebx
  800f4a:	83 c4 10             	add    $0x10,%esp
  800f4d:	85 c0                	test   %eax,%eax
  800f4f:	78 1a                	js     800f6b <fd_close+0x7b>
		if (dev->dev_close)
  800f51:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f54:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800f57:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800f5c:	85 c0                	test   %eax,%eax
  800f5e:	74 0b                	je     800f6b <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800f60:	83 ec 0c             	sub    $0xc,%esp
  800f63:	56                   	push   %esi
  800f64:	ff d0                	call   *%eax
  800f66:	89 c3                	mov    %eax,%ebx
  800f68:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f6b:	83 ec 08             	sub    $0x8,%esp
  800f6e:	56                   	push   %esi
  800f6f:	6a 00                	push   $0x0
  800f71:	e8 c3 fc ff ff       	call   800c39 <sys_page_unmap>
	return r;
  800f76:	83 c4 10             	add    $0x10,%esp
  800f79:	eb b5                	jmp    800f30 <fd_close+0x40>

00800f7b <close>:

int
close(int fdnum)
{
  800f7b:	f3 0f 1e fb          	endbr32 
  800f7f:	55                   	push   %ebp
  800f80:	89 e5                	mov    %esp,%ebp
  800f82:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f85:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f88:	50                   	push   %eax
  800f89:	ff 75 08             	pushl  0x8(%ebp)
  800f8c:	e8 b1 fe ff ff       	call   800e42 <fd_lookup>
  800f91:	83 c4 10             	add    $0x10,%esp
  800f94:	85 c0                	test   %eax,%eax
  800f96:	79 02                	jns    800f9a <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  800f98:	c9                   	leave  
  800f99:	c3                   	ret    
		return fd_close(fd, 1);
  800f9a:	83 ec 08             	sub    $0x8,%esp
  800f9d:	6a 01                	push   $0x1
  800f9f:	ff 75 f4             	pushl  -0xc(%ebp)
  800fa2:	e8 49 ff ff ff       	call   800ef0 <fd_close>
  800fa7:	83 c4 10             	add    $0x10,%esp
  800faa:	eb ec                	jmp    800f98 <close+0x1d>

00800fac <close_all>:

void
close_all(void)
{
  800fac:	f3 0f 1e fb          	endbr32 
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	53                   	push   %ebx
  800fb4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fb7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fbc:	83 ec 0c             	sub    $0xc,%esp
  800fbf:	53                   	push   %ebx
  800fc0:	e8 b6 ff ff ff       	call   800f7b <close>
	for (i = 0; i < MAXFD; i++)
  800fc5:	83 c3 01             	add    $0x1,%ebx
  800fc8:	83 c4 10             	add    $0x10,%esp
  800fcb:	83 fb 20             	cmp    $0x20,%ebx
  800fce:	75 ec                	jne    800fbc <close_all+0x10>
}
  800fd0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fd3:	c9                   	leave  
  800fd4:	c3                   	ret    

00800fd5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fd5:	f3 0f 1e fb          	endbr32 
  800fd9:	55                   	push   %ebp
  800fda:	89 e5                	mov    %esp,%ebp
  800fdc:	57                   	push   %edi
  800fdd:	56                   	push   %esi
  800fde:	53                   	push   %ebx
  800fdf:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fe2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fe5:	50                   	push   %eax
  800fe6:	ff 75 08             	pushl  0x8(%ebp)
  800fe9:	e8 54 fe ff ff       	call   800e42 <fd_lookup>
  800fee:	89 c3                	mov    %eax,%ebx
  800ff0:	83 c4 10             	add    $0x10,%esp
  800ff3:	85 c0                	test   %eax,%eax
  800ff5:	0f 88 81 00 00 00    	js     80107c <dup+0xa7>
		return r;
	close(newfdnum);
  800ffb:	83 ec 0c             	sub    $0xc,%esp
  800ffe:	ff 75 0c             	pushl  0xc(%ebp)
  801001:	e8 75 ff ff ff       	call   800f7b <close>

	newfd = INDEX2FD(newfdnum);
  801006:	8b 75 0c             	mov    0xc(%ebp),%esi
  801009:	c1 e6 0c             	shl    $0xc,%esi
  80100c:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801012:	83 c4 04             	add    $0x4,%esp
  801015:	ff 75 e4             	pushl  -0x1c(%ebp)
  801018:	e8 b4 fd ff ff       	call   800dd1 <fd2data>
  80101d:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80101f:	89 34 24             	mov    %esi,(%esp)
  801022:	e8 aa fd ff ff       	call   800dd1 <fd2data>
  801027:	83 c4 10             	add    $0x10,%esp
  80102a:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80102c:	89 d8                	mov    %ebx,%eax
  80102e:	c1 e8 16             	shr    $0x16,%eax
  801031:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801038:	a8 01                	test   $0x1,%al
  80103a:	74 11                	je     80104d <dup+0x78>
  80103c:	89 d8                	mov    %ebx,%eax
  80103e:	c1 e8 0c             	shr    $0xc,%eax
  801041:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801048:	f6 c2 01             	test   $0x1,%dl
  80104b:	75 39                	jne    801086 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80104d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801050:	89 d0                	mov    %edx,%eax
  801052:	c1 e8 0c             	shr    $0xc,%eax
  801055:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80105c:	83 ec 0c             	sub    $0xc,%esp
  80105f:	25 07 0e 00 00       	and    $0xe07,%eax
  801064:	50                   	push   %eax
  801065:	56                   	push   %esi
  801066:	6a 00                	push   $0x0
  801068:	52                   	push   %edx
  801069:	6a 00                	push   $0x0
  80106b:	e8 83 fb ff ff       	call   800bf3 <sys_page_map>
  801070:	89 c3                	mov    %eax,%ebx
  801072:	83 c4 20             	add    $0x20,%esp
  801075:	85 c0                	test   %eax,%eax
  801077:	78 31                	js     8010aa <dup+0xd5>
		goto err;

	return newfdnum;
  801079:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80107c:	89 d8                	mov    %ebx,%eax
  80107e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801081:	5b                   	pop    %ebx
  801082:	5e                   	pop    %esi
  801083:	5f                   	pop    %edi
  801084:	5d                   	pop    %ebp
  801085:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801086:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80108d:	83 ec 0c             	sub    $0xc,%esp
  801090:	25 07 0e 00 00       	and    $0xe07,%eax
  801095:	50                   	push   %eax
  801096:	57                   	push   %edi
  801097:	6a 00                	push   $0x0
  801099:	53                   	push   %ebx
  80109a:	6a 00                	push   $0x0
  80109c:	e8 52 fb ff ff       	call   800bf3 <sys_page_map>
  8010a1:	89 c3                	mov    %eax,%ebx
  8010a3:	83 c4 20             	add    $0x20,%esp
  8010a6:	85 c0                	test   %eax,%eax
  8010a8:	79 a3                	jns    80104d <dup+0x78>
	sys_page_unmap(0, newfd);
  8010aa:	83 ec 08             	sub    $0x8,%esp
  8010ad:	56                   	push   %esi
  8010ae:	6a 00                	push   $0x0
  8010b0:	e8 84 fb ff ff       	call   800c39 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010b5:	83 c4 08             	add    $0x8,%esp
  8010b8:	57                   	push   %edi
  8010b9:	6a 00                	push   $0x0
  8010bb:	e8 79 fb ff ff       	call   800c39 <sys_page_unmap>
	return r;
  8010c0:	83 c4 10             	add    $0x10,%esp
  8010c3:	eb b7                	jmp    80107c <dup+0xa7>

008010c5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010c5:	f3 0f 1e fb          	endbr32 
  8010c9:	55                   	push   %ebp
  8010ca:	89 e5                	mov    %esp,%ebp
  8010cc:	53                   	push   %ebx
  8010cd:	83 ec 1c             	sub    $0x1c,%esp
  8010d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010d6:	50                   	push   %eax
  8010d7:	53                   	push   %ebx
  8010d8:	e8 65 fd ff ff       	call   800e42 <fd_lookup>
  8010dd:	83 c4 10             	add    $0x10,%esp
  8010e0:	85 c0                	test   %eax,%eax
  8010e2:	78 3f                	js     801123 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010e4:	83 ec 08             	sub    $0x8,%esp
  8010e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ea:	50                   	push   %eax
  8010eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010ee:	ff 30                	pushl  (%eax)
  8010f0:	e8 a1 fd ff ff       	call   800e96 <dev_lookup>
  8010f5:	83 c4 10             	add    $0x10,%esp
  8010f8:	85 c0                	test   %eax,%eax
  8010fa:	78 27                	js     801123 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010fc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010ff:	8b 42 08             	mov    0x8(%edx),%eax
  801102:	83 e0 03             	and    $0x3,%eax
  801105:	83 f8 01             	cmp    $0x1,%eax
  801108:	74 1e                	je     801128 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80110a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80110d:	8b 40 08             	mov    0x8(%eax),%eax
  801110:	85 c0                	test   %eax,%eax
  801112:	74 35                	je     801149 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801114:	83 ec 04             	sub    $0x4,%esp
  801117:	ff 75 10             	pushl  0x10(%ebp)
  80111a:	ff 75 0c             	pushl  0xc(%ebp)
  80111d:	52                   	push   %edx
  80111e:	ff d0                	call   *%eax
  801120:	83 c4 10             	add    $0x10,%esp
}
  801123:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801126:	c9                   	leave  
  801127:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801128:	a1 04 40 80 00       	mov    0x804004,%eax
  80112d:	8b 40 48             	mov    0x48(%eax),%eax
  801130:	83 ec 04             	sub    $0x4,%esp
  801133:	53                   	push   %ebx
  801134:	50                   	push   %eax
  801135:	68 4d 22 80 00       	push   $0x80224d
  80113a:	e8 22 f0 ff ff       	call   800161 <cprintf>
		return -E_INVAL;
  80113f:	83 c4 10             	add    $0x10,%esp
  801142:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801147:	eb da                	jmp    801123 <read+0x5e>
		return -E_NOT_SUPP;
  801149:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80114e:	eb d3                	jmp    801123 <read+0x5e>

00801150 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801150:	f3 0f 1e fb          	endbr32 
  801154:	55                   	push   %ebp
  801155:	89 e5                	mov    %esp,%ebp
  801157:	57                   	push   %edi
  801158:	56                   	push   %esi
  801159:	53                   	push   %ebx
  80115a:	83 ec 0c             	sub    $0xc,%esp
  80115d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801160:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801163:	bb 00 00 00 00       	mov    $0x0,%ebx
  801168:	eb 02                	jmp    80116c <readn+0x1c>
  80116a:	01 c3                	add    %eax,%ebx
  80116c:	39 f3                	cmp    %esi,%ebx
  80116e:	73 21                	jae    801191 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801170:	83 ec 04             	sub    $0x4,%esp
  801173:	89 f0                	mov    %esi,%eax
  801175:	29 d8                	sub    %ebx,%eax
  801177:	50                   	push   %eax
  801178:	89 d8                	mov    %ebx,%eax
  80117a:	03 45 0c             	add    0xc(%ebp),%eax
  80117d:	50                   	push   %eax
  80117e:	57                   	push   %edi
  80117f:	e8 41 ff ff ff       	call   8010c5 <read>
		if (m < 0)
  801184:	83 c4 10             	add    $0x10,%esp
  801187:	85 c0                	test   %eax,%eax
  801189:	78 04                	js     80118f <readn+0x3f>
			return m;
		if (m == 0)
  80118b:	75 dd                	jne    80116a <readn+0x1a>
  80118d:	eb 02                	jmp    801191 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80118f:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801191:	89 d8                	mov    %ebx,%eax
  801193:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801196:	5b                   	pop    %ebx
  801197:	5e                   	pop    %esi
  801198:	5f                   	pop    %edi
  801199:	5d                   	pop    %ebp
  80119a:	c3                   	ret    

0080119b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80119b:	f3 0f 1e fb          	endbr32 
  80119f:	55                   	push   %ebp
  8011a0:	89 e5                	mov    %esp,%ebp
  8011a2:	53                   	push   %ebx
  8011a3:	83 ec 1c             	sub    $0x1c,%esp
  8011a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ac:	50                   	push   %eax
  8011ad:	53                   	push   %ebx
  8011ae:	e8 8f fc ff ff       	call   800e42 <fd_lookup>
  8011b3:	83 c4 10             	add    $0x10,%esp
  8011b6:	85 c0                	test   %eax,%eax
  8011b8:	78 3a                	js     8011f4 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ba:	83 ec 08             	sub    $0x8,%esp
  8011bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c0:	50                   	push   %eax
  8011c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c4:	ff 30                	pushl  (%eax)
  8011c6:	e8 cb fc ff ff       	call   800e96 <dev_lookup>
  8011cb:	83 c4 10             	add    $0x10,%esp
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	78 22                	js     8011f4 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011d9:	74 1e                	je     8011f9 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011db:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011de:	8b 52 0c             	mov    0xc(%edx),%edx
  8011e1:	85 d2                	test   %edx,%edx
  8011e3:	74 35                	je     80121a <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011e5:	83 ec 04             	sub    $0x4,%esp
  8011e8:	ff 75 10             	pushl  0x10(%ebp)
  8011eb:	ff 75 0c             	pushl  0xc(%ebp)
  8011ee:	50                   	push   %eax
  8011ef:	ff d2                	call   *%edx
  8011f1:	83 c4 10             	add    $0x10,%esp
}
  8011f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f7:	c9                   	leave  
  8011f8:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011f9:	a1 04 40 80 00       	mov    0x804004,%eax
  8011fe:	8b 40 48             	mov    0x48(%eax),%eax
  801201:	83 ec 04             	sub    $0x4,%esp
  801204:	53                   	push   %ebx
  801205:	50                   	push   %eax
  801206:	68 69 22 80 00       	push   $0x802269
  80120b:	e8 51 ef ff ff       	call   800161 <cprintf>
		return -E_INVAL;
  801210:	83 c4 10             	add    $0x10,%esp
  801213:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801218:	eb da                	jmp    8011f4 <write+0x59>
		return -E_NOT_SUPP;
  80121a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80121f:	eb d3                	jmp    8011f4 <write+0x59>

00801221 <seek>:

int
seek(int fdnum, off_t offset)
{
  801221:	f3 0f 1e fb          	endbr32 
  801225:	55                   	push   %ebp
  801226:	89 e5                	mov    %esp,%ebp
  801228:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80122b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122e:	50                   	push   %eax
  80122f:	ff 75 08             	pushl  0x8(%ebp)
  801232:	e8 0b fc ff ff       	call   800e42 <fd_lookup>
  801237:	83 c4 10             	add    $0x10,%esp
  80123a:	85 c0                	test   %eax,%eax
  80123c:	78 0e                	js     80124c <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80123e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801241:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801244:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801247:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80124c:	c9                   	leave  
  80124d:	c3                   	ret    

0080124e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80124e:	f3 0f 1e fb          	endbr32 
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	53                   	push   %ebx
  801256:	83 ec 1c             	sub    $0x1c,%esp
  801259:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80125c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80125f:	50                   	push   %eax
  801260:	53                   	push   %ebx
  801261:	e8 dc fb ff ff       	call   800e42 <fd_lookup>
  801266:	83 c4 10             	add    $0x10,%esp
  801269:	85 c0                	test   %eax,%eax
  80126b:	78 37                	js     8012a4 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80126d:	83 ec 08             	sub    $0x8,%esp
  801270:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801273:	50                   	push   %eax
  801274:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801277:	ff 30                	pushl  (%eax)
  801279:	e8 18 fc ff ff       	call   800e96 <dev_lookup>
  80127e:	83 c4 10             	add    $0x10,%esp
  801281:	85 c0                	test   %eax,%eax
  801283:	78 1f                	js     8012a4 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801285:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801288:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80128c:	74 1b                	je     8012a9 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80128e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801291:	8b 52 18             	mov    0x18(%edx),%edx
  801294:	85 d2                	test   %edx,%edx
  801296:	74 32                	je     8012ca <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801298:	83 ec 08             	sub    $0x8,%esp
  80129b:	ff 75 0c             	pushl  0xc(%ebp)
  80129e:	50                   	push   %eax
  80129f:	ff d2                	call   *%edx
  8012a1:	83 c4 10             	add    $0x10,%esp
}
  8012a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a7:	c9                   	leave  
  8012a8:	c3                   	ret    
			thisenv->env_id, fdnum);
  8012a9:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012ae:	8b 40 48             	mov    0x48(%eax),%eax
  8012b1:	83 ec 04             	sub    $0x4,%esp
  8012b4:	53                   	push   %ebx
  8012b5:	50                   	push   %eax
  8012b6:	68 2c 22 80 00       	push   $0x80222c
  8012bb:	e8 a1 ee ff ff       	call   800161 <cprintf>
		return -E_INVAL;
  8012c0:	83 c4 10             	add    $0x10,%esp
  8012c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c8:	eb da                	jmp    8012a4 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8012ca:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012cf:	eb d3                	jmp    8012a4 <ftruncate+0x56>

008012d1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012d1:	f3 0f 1e fb          	endbr32 
  8012d5:	55                   	push   %ebp
  8012d6:	89 e5                	mov    %esp,%ebp
  8012d8:	53                   	push   %ebx
  8012d9:	83 ec 1c             	sub    $0x1c,%esp
  8012dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e2:	50                   	push   %eax
  8012e3:	ff 75 08             	pushl  0x8(%ebp)
  8012e6:	e8 57 fb ff ff       	call   800e42 <fd_lookup>
  8012eb:	83 c4 10             	add    $0x10,%esp
  8012ee:	85 c0                	test   %eax,%eax
  8012f0:	78 4b                	js     80133d <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f2:	83 ec 08             	sub    $0x8,%esp
  8012f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f8:	50                   	push   %eax
  8012f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012fc:	ff 30                	pushl  (%eax)
  8012fe:	e8 93 fb ff ff       	call   800e96 <dev_lookup>
  801303:	83 c4 10             	add    $0x10,%esp
  801306:	85 c0                	test   %eax,%eax
  801308:	78 33                	js     80133d <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80130a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80130d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801311:	74 2f                	je     801342 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801313:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801316:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80131d:	00 00 00 
	stat->st_isdir = 0;
  801320:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801327:	00 00 00 
	stat->st_dev = dev;
  80132a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801330:	83 ec 08             	sub    $0x8,%esp
  801333:	53                   	push   %ebx
  801334:	ff 75 f0             	pushl  -0x10(%ebp)
  801337:	ff 50 14             	call   *0x14(%eax)
  80133a:	83 c4 10             	add    $0x10,%esp
}
  80133d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801340:	c9                   	leave  
  801341:	c3                   	ret    
		return -E_NOT_SUPP;
  801342:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801347:	eb f4                	jmp    80133d <fstat+0x6c>

00801349 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801349:	f3 0f 1e fb          	endbr32 
  80134d:	55                   	push   %ebp
  80134e:	89 e5                	mov    %esp,%ebp
  801350:	56                   	push   %esi
  801351:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801352:	83 ec 08             	sub    $0x8,%esp
  801355:	6a 00                	push   $0x0
  801357:	ff 75 08             	pushl  0x8(%ebp)
  80135a:	e8 cf 01 00 00       	call   80152e <open>
  80135f:	89 c3                	mov    %eax,%ebx
  801361:	83 c4 10             	add    $0x10,%esp
  801364:	85 c0                	test   %eax,%eax
  801366:	78 1b                	js     801383 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801368:	83 ec 08             	sub    $0x8,%esp
  80136b:	ff 75 0c             	pushl  0xc(%ebp)
  80136e:	50                   	push   %eax
  80136f:	e8 5d ff ff ff       	call   8012d1 <fstat>
  801374:	89 c6                	mov    %eax,%esi
	close(fd);
  801376:	89 1c 24             	mov    %ebx,(%esp)
  801379:	e8 fd fb ff ff       	call   800f7b <close>
	return r;
  80137e:	83 c4 10             	add    $0x10,%esp
  801381:	89 f3                	mov    %esi,%ebx
}
  801383:	89 d8                	mov    %ebx,%eax
  801385:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801388:	5b                   	pop    %ebx
  801389:	5e                   	pop    %esi
  80138a:	5d                   	pop    %ebp
  80138b:	c3                   	ret    

0080138c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80138c:	55                   	push   %ebp
  80138d:	89 e5                	mov    %esp,%ebp
  80138f:	56                   	push   %esi
  801390:	53                   	push   %ebx
  801391:	89 c6                	mov    %eax,%esi
  801393:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801395:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80139c:	74 27                	je     8013c5 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80139e:	6a 07                	push   $0x7
  8013a0:	68 00 50 80 00       	push   $0x805000
  8013a5:	56                   	push   %esi
  8013a6:	ff 35 00 40 80 00    	pushl  0x804000
  8013ac:	e8 c6 07 00 00       	call   801b77 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013b1:	83 c4 0c             	add    $0xc,%esp
  8013b4:	6a 00                	push   $0x0
  8013b6:	53                   	push   %ebx
  8013b7:	6a 00                	push   $0x0
  8013b9:	e8 62 07 00 00       	call   801b20 <ipc_recv>
}
  8013be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013c1:	5b                   	pop    %ebx
  8013c2:	5e                   	pop    %esi
  8013c3:	5d                   	pop    %ebp
  8013c4:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013c5:	83 ec 0c             	sub    $0xc,%esp
  8013c8:	6a 01                	push   $0x1
  8013ca:	e8 0e 08 00 00       	call   801bdd <ipc_find_env>
  8013cf:	a3 00 40 80 00       	mov    %eax,0x804000
  8013d4:	83 c4 10             	add    $0x10,%esp
  8013d7:	eb c5                	jmp    80139e <fsipc+0x12>

008013d9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013d9:	f3 0f 1e fb          	endbr32 
  8013dd:	55                   	push   %ebp
  8013de:	89 e5                	mov    %esp,%ebp
  8013e0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e6:	8b 40 0c             	mov    0xc(%eax),%eax
  8013e9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013f1:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8013fb:	b8 02 00 00 00       	mov    $0x2,%eax
  801400:	e8 87 ff ff ff       	call   80138c <fsipc>
}
  801405:	c9                   	leave  
  801406:	c3                   	ret    

00801407 <devfile_flush>:
{
  801407:	f3 0f 1e fb          	endbr32 
  80140b:	55                   	push   %ebp
  80140c:	89 e5                	mov    %esp,%ebp
  80140e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801411:	8b 45 08             	mov    0x8(%ebp),%eax
  801414:	8b 40 0c             	mov    0xc(%eax),%eax
  801417:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80141c:	ba 00 00 00 00       	mov    $0x0,%edx
  801421:	b8 06 00 00 00       	mov    $0x6,%eax
  801426:	e8 61 ff ff ff       	call   80138c <fsipc>
}
  80142b:	c9                   	leave  
  80142c:	c3                   	ret    

0080142d <devfile_stat>:
{
  80142d:	f3 0f 1e fb          	endbr32 
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
  801434:	53                   	push   %ebx
  801435:	83 ec 04             	sub    $0x4,%esp
  801438:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80143b:	8b 45 08             	mov    0x8(%ebp),%eax
  80143e:	8b 40 0c             	mov    0xc(%eax),%eax
  801441:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801446:	ba 00 00 00 00       	mov    $0x0,%edx
  80144b:	b8 05 00 00 00       	mov    $0x5,%eax
  801450:	e8 37 ff ff ff       	call   80138c <fsipc>
  801455:	85 c0                	test   %eax,%eax
  801457:	78 2c                	js     801485 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801459:	83 ec 08             	sub    $0x8,%esp
  80145c:	68 00 50 80 00       	push   $0x805000
  801461:	53                   	push   %ebx
  801462:	e8 03 f3 ff ff       	call   80076a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801467:	a1 80 50 80 00       	mov    0x805080,%eax
  80146c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801472:	a1 84 50 80 00       	mov    0x805084,%eax
  801477:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80147d:	83 c4 10             	add    $0x10,%esp
  801480:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801485:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801488:	c9                   	leave  
  801489:	c3                   	ret    

0080148a <devfile_write>:
{
  80148a:	f3 0f 1e fb          	endbr32 
  80148e:	55                   	push   %ebp
  80148f:	89 e5                	mov    %esp,%ebp
  801491:	83 ec 0c             	sub    $0xc,%esp
	panic("devfile_write not implemented");
  801494:	68 98 22 80 00       	push   $0x802298
  801499:	68 90 00 00 00       	push   $0x90
  80149e:	68 b6 22 80 00       	push   $0x8022b6
  8014a3:	e8 2e 06 00 00       	call   801ad6 <_panic>

008014a8 <devfile_read>:
{
  8014a8:	f3 0f 1e fb          	endbr32 
  8014ac:	55                   	push   %ebp
  8014ad:	89 e5                	mov    %esp,%ebp
  8014af:	56                   	push   %esi
  8014b0:	53                   	push   %ebx
  8014b1:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b7:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ba:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014bf:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ca:	b8 03 00 00 00       	mov    $0x3,%eax
  8014cf:	e8 b8 fe ff ff       	call   80138c <fsipc>
  8014d4:	89 c3                	mov    %eax,%ebx
  8014d6:	85 c0                	test   %eax,%eax
  8014d8:	78 1f                	js     8014f9 <devfile_read+0x51>
	assert(r <= n);
  8014da:	39 f0                	cmp    %esi,%eax
  8014dc:	77 24                	ja     801502 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8014de:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014e3:	7f 33                	jg     801518 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014e5:	83 ec 04             	sub    $0x4,%esp
  8014e8:	50                   	push   %eax
  8014e9:	68 00 50 80 00       	push   $0x805000
  8014ee:	ff 75 0c             	pushl  0xc(%ebp)
  8014f1:	e8 2a f4 ff ff       	call   800920 <memmove>
	return r;
  8014f6:	83 c4 10             	add    $0x10,%esp
}
  8014f9:	89 d8                	mov    %ebx,%eax
  8014fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014fe:	5b                   	pop    %ebx
  8014ff:	5e                   	pop    %esi
  801500:	5d                   	pop    %ebp
  801501:	c3                   	ret    
	assert(r <= n);
  801502:	68 c1 22 80 00       	push   $0x8022c1
  801507:	68 c8 22 80 00       	push   $0x8022c8
  80150c:	6a 7c                	push   $0x7c
  80150e:	68 b6 22 80 00       	push   $0x8022b6
  801513:	e8 be 05 00 00       	call   801ad6 <_panic>
	assert(r <= PGSIZE);
  801518:	68 dd 22 80 00       	push   $0x8022dd
  80151d:	68 c8 22 80 00       	push   $0x8022c8
  801522:	6a 7d                	push   $0x7d
  801524:	68 b6 22 80 00       	push   $0x8022b6
  801529:	e8 a8 05 00 00       	call   801ad6 <_panic>

0080152e <open>:
{
  80152e:	f3 0f 1e fb          	endbr32 
  801532:	55                   	push   %ebp
  801533:	89 e5                	mov    %esp,%ebp
  801535:	56                   	push   %esi
  801536:	53                   	push   %ebx
  801537:	83 ec 1c             	sub    $0x1c,%esp
  80153a:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80153d:	56                   	push   %esi
  80153e:	e8 e4 f1 ff ff       	call   800727 <strlen>
  801543:	83 c4 10             	add    $0x10,%esp
  801546:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80154b:	7f 6c                	jg     8015b9 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  80154d:	83 ec 0c             	sub    $0xc,%esp
  801550:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801553:	50                   	push   %eax
  801554:	e8 93 f8 ff ff       	call   800dec <fd_alloc>
  801559:	89 c3                	mov    %eax,%ebx
  80155b:	83 c4 10             	add    $0x10,%esp
  80155e:	85 c0                	test   %eax,%eax
  801560:	78 3c                	js     80159e <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801562:	83 ec 08             	sub    $0x8,%esp
  801565:	56                   	push   %esi
  801566:	68 00 50 80 00       	push   $0x805000
  80156b:	e8 fa f1 ff ff       	call   80076a <strcpy>
	fsipcbuf.open.req_omode = mode;
  801570:	8b 45 0c             	mov    0xc(%ebp),%eax
  801573:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801578:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80157b:	b8 01 00 00 00       	mov    $0x1,%eax
  801580:	e8 07 fe ff ff       	call   80138c <fsipc>
  801585:	89 c3                	mov    %eax,%ebx
  801587:	83 c4 10             	add    $0x10,%esp
  80158a:	85 c0                	test   %eax,%eax
  80158c:	78 19                	js     8015a7 <open+0x79>
	return fd2num(fd);
  80158e:	83 ec 0c             	sub    $0xc,%esp
  801591:	ff 75 f4             	pushl  -0xc(%ebp)
  801594:	e8 24 f8 ff ff       	call   800dbd <fd2num>
  801599:	89 c3                	mov    %eax,%ebx
  80159b:	83 c4 10             	add    $0x10,%esp
}
  80159e:	89 d8                	mov    %ebx,%eax
  8015a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015a3:	5b                   	pop    %ebx
  8015a4:	5e                   	pop    %esi
  8015a5:	5d                   	pop    %ebp
  8015a6:	c3                   	ret    
		fd_close(fd, 0);
  8015a7:	83 ec 08             	sub    $0x8,%esp
  8015aa:	6a 00                	push   $0x0
  8015ac:	ff 75 f4             	pushl  -0xc(%ebp)
  8015af:	e8 3c f9 ff ff       	call   800ef0 <fd_close>
		return r;
  8015b4:	83 c4 10             	add    $0x10,%esp
  8015b7:	eb e5                	jmp    80159e <open+0x70>
		return -E_BAD_PATH;
  8015b9:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8015be:	eb de                	jmp    80159e <open+0x70>

008015c0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015c0:	f3 0f 1e fb          	endbr32 
  8015c4:	55                   	push   %ebp
  8015c5:	89 e5                	mov    %esp,%ebp
  8015c7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8015cf:	b8 08 00 00 00       	mov    $0x8,%eax
  8015d4:	e8 b3 fd ff ff       	call   80138c <fsipc>
}
  8015d9:	c9                   	leave  
  8015da:	c3                   	ret    

008015db <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015db:	f3 0f 1e fb          	endbr32 
  8015df:	55                   	push   %ebp
  8015e0:	89 e5                	mov    %esp,%ebp
  8015e2:	56                   	push   %esi
  8015e3:	53                   	push   %ebx
  8015e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015e7:	83 ec 0c             	sub    $0xc,%esp
  8015ea:	ff 75 08             	pushl  0x8(%ebp)
  8015ed:	e8 df f7 ff ff       	call   800dd1 <fd2data>
  8015f2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8015f4:	83 c4 08             	add    $0x8,%esp
  8015f7:	68 e9 22 80 00       	push   $0x8022e9
  8015fc:	53                   	push   %ebx
  8015fd:	e8 68 f1 ff ff       	call   80076a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801602:	8b 46 04             	mov    0x4(%esi),%eax
  801605:	2b 06                	sub    (%esi),%eax
  801607:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80160d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801614:	00 00 00 
	stat->st_dev = &devpipe;
  801617:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80161e:	30 80 00 
	return 0;
}
  801621:	b8 00 00 00 00       	mov    $0x0,%eax
  801626:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801629:	5b                   	pop    %ebx
  80162a:	5e                   	pop    %esi
  80162b:	5d                   	pop    %ebp
  80162c:	c3                   	ret    

0080162d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80162d:	f3 0f 1e fb          	endbr32 
  801631:	55                   	push   %ebp
  801632:	89 e5                	mov    %esp,%ebp
  801634:	53                   	push   %ebx
  801635:	83 ec 0c             	sub    $0xc,%esp
  801638:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80163b:	53                   	push   %ebx
  80163c:	6a 00                	push   $0x0
  80163e:	e8 f6 f5 ff ff       	call   800c39 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801643:	89 1c 24             	mov    %ebx,(%esp)
  801646:	e8 86 f7 ff ff       	call   800dd1 <fd2data>
  80164b:	83 c4 08             	add    $0x8,%esp
  80164e:	50                   	push   %eax
  80164f:	6a 00                	push   $0x0
  801651:	e8 e3 f5 ff ff       	call   800c39 <sys_page_unmap>
}
  801656:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801659:	c9                   	leave  
  80165a:	c3                   	ret    

0080165b <_pipeisclosed>:
{
  80165b:	55                   	push   %ebp
  80165c:	89 e5                	mov    %esp,%ebp
  80165e:	57                   	push   %edi
  80165f:	56                   	push   %esi
  801660:	53                   	push   %ebx
  801661:	83 ec 1c             	sub    $0x1c,%esp
  801664:	89 c7                	mov    %eax,%edi
  801666:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801668:	a1 04 40 80 00       	mov    0x804004,%eax
  80166d:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801670:	83 ec 0c             	sub    $0xc,%esp
  801673:	57                   	push   %edi
  801674:	e8 a1 05 00 00       	call   801c1a <pageref>
  801679:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80167c:	89 34 24             	mov    %esi,(%esp)
  80167f:	e8 96 05 00 00       	call   801c1a <pageref>
		nn = thisenv->env_runs;
  801684:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80168a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80168d:	83 c4 10             	add    $0x10,%esp
  801690:	39 cb                	cmp    %ecx,%ebx
  801692:	74 1b                	je     8016af <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801694:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801697:	75 cf                	jne    801668 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801699:	8b 42 58             	mov    0x58(%edx),%eax
  80169c:	6a 01                	push   $0x1
  80169e:	50                   	push   %eax
  80169f:	53                   	push   %ebx
  8016a0:	68 f0 22 80 00       	push   $0x8022f0
  8016a5:	e8 b7 ea ff ff       	call   800161 <cprintf>
  8016aa:	83 c4 10             	add    $0x10,%esp
  8016ad:	eb b9                	jmp    801668 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8016af:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8016b2:	0f 94 c0             	sete   %al
  8016b5:	0f b6 c0             	movzbl %al,%eax
}
  8016b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016bb:	5b                   	pop    %ebx
  8016bc:	5e                   	pop    %esi
  8016bd:	5f                   	pop    %edi
  8016be:	5d                   	pop    %ebp
  8016bf:	c3                   	ret    

008016c0 <devpipe_write>:
{
  8016c0:	f3 0f 1e fb          	endbr32 
  8016c4:	55                   	push   %ebp
  8016c5:	89 e5                	mov    %esp,%ebp
  8016c7:	57                   	push   %edi
  8016c8:	56                   	push   %esi
  8016c9:	53                   	push   %ebx
  8016ca:	83 ec 28             	sub    $0x28,%esp
  8016cd:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8016d0:	56                   	push   %esi
  8016d1:	e8 fb f6 ff ff       	call   800dd1 <fd2data>
  8016d6:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8016d8:	83 c4 10             	add    $0x10,%esp
  8016db:	bf 00 00 00 00       	mov    $0x0,%edi
  8016e0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8016e3:	74 4f                	je     801734 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016e5:	8b 43 04             	mov    0x4(%ebx),%eax
  8016e8:	8b 0b                	mov    (%ebx),%ecx
  8016ea:	8d 51 20             	lea    0x20(%ecx),%edx
  8016ed:	39 d0                	cmp    %edx,%eax
  8016ef:	72 14                	jb     801705 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  8016f1:	89 da                	mov    %ebx,%edx
  8016f3:	89 f0                	mov    %esi,%eax
  8016f5:	e8 61 ff ff ff       	call   80165b <_pipeisclosed>
  8016fa:	85 c0                	test   %eax,%eax
  8016fc:	75 3b                	jne    801739 <devpipe_write+0x79>
			sys_yield();
  8016fe:	e8 86 f4 ff ff       	call   800b89 <sys_yield>
  801703:	eb e0                	jmp    8016e5 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801705:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801708:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80170c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80170f:	89 c2                	mov    %eax,%edx
  801711:	c1 fa 1f             	sar    $0x1f,%edx
  801714:	89 d1                	mov    %edx,%ecx
  801716:	c1 e9 1b             	shr    $0x1b,%ecx
  801719:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80171c:	83 e2 1f             	and    $0x1f,%edx
  80171f:	29 ca                	sub    %ecx,%edx
  801721:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801725:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801729:	83 c0 01             	add    $0x1,%eax
  80172c:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80172f:	83 c7 01             	add    $0x1,%edi
  801732:	eb ac                	jmp    8016e0 <devpipe_write+0x20>
	return i;
  801734:	8b 45 10             	mov    0x10(%ebp),%eax
  801737:	eb 05                	jmp    80173e <devpipe_write+0x7e>
				return 0;
  801739:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80173e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801741:	5b                   	pop    %ebx
  801742:	5e                   	pop    %esi
  801743:	5f                   	pop    %edi
  801744:	5d                   	pop    %ebp
  801745:	c3                   	ret    

00801746 <devpipe_read>:
{
  801746:	f3 0f 1e fb          	endbr32 
  80174a:	55                   	push   %ebp
  80174b:	89 e5                	mov    %esp,%ebp
  80174d:	57                   	push   %edi
  80174e:	56                   	push   %esi
  80174f:	53                   	push   %ebx
  801750:	83 ec 18             	sub    $0x18,%esp
  801753:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801756:	57                   	push   %edi
  801757:	e8 75 f6 ff ff       	call   800dd1 <fd2data>
  80175c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80175e:	83 c4 10             	add    $0x10,%esp
  801761:	be 00 00 00 00       	mov    $0x0,%esi
  801766:	3b 75 10             	cmp    0x10(%ebp),%esi
  801769:	75 14                	jne    80177f <devpipe_read+0x39>
	return i;
  80176b:	8b 45 10             	mov    0x10(%ebp),%eax
  80176e:	eb 02                	jmp    801772 <devpipe_read+0x2c>
				return i;
  801770:	89 f0                	mov    %esi,%eax
}
  801772:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801775:	5b                   	pop    %ebx
  801776:	5e                   	pop    %esi
  801777:	5f                   	pop    %edi
  801778:	5d                   	pop    %ebp
  801779:	c3                   	ret    
			sys_yield();
  80177a:	e8 0a f4 ff ff       	call   800b89 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80177f:	8b 03                	mov    (%ebx),%eax
  801781:	3b 43 04             	cmp    0x4(%ebx),%eax
  801784:	75 18                	jne    80179e <devpipe_read+0x58>
			if (i > 0)
  801786:	85 f6                	test   %esi,%esi
  801788:	75 e6                	jne    801770 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  80178a:	89 da                	mov    %ebx,%edx
  80178c:	89 f8                	mov    %edi,%eax
  80178e:	e8 c8 fe ff ff       	call   80165b <_pipeisclosed>
  801793:	85 c0                	test   %eax,%eax
  801795:	74 e3                	je     80177a <devpipe_read+0x34>
				return 0;
  801797:	b8 00 00 00 00       	mov    $0x0,%eax
  80179c:	eb d4                	jmp    801772 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80179e:	99                   	cltd   
  80179f:	c1 ea 1b             	shr    $0x1b,%edx
  8017a2:	01 d0                	add    %edx,%eax
  8017a4:	83 e0 1f             	and    $0x1f,%eax
  8017a7:	29 d0                	sub    %edx,%eax
  8017a9:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8017ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017b1:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8017b4:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8017b7:	83 c6 01             	add    $0x1,%esi
  8017ba:	eb aa                	jmp    801766 <devpipe_read+0x20>

008017bc <pipe>:
{
  8017bc:	f3 0f 1e fb          	endbr32 
  8017c0:	55                   	push   %ebp
  8017c1:	89 e5                	mov    %esp,%ebp
  8017c3:	56                   	push   %esi
  8017c4:	53                   	push   %ebx
  8017c5:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8017c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017cb:	50                   	push   %eax
  8017cc:	e8 1b f6 ff ff       	call   800dec <fd_alloc>
  8017d1:	89 c3                	mov    %eax,%ebx
  8017d3:	83 c4 10             	add    $0x10,%esp
  8017d6:	85 c0                	test   %eax,%eax
  8017d8:	0f 88 23 01 00 00    	js     801901 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017de:	83 ec 04             	sub    $0x4,%esp
  8017e1:	68 07 04 00 00       	push   $0x407
  8017e6:	ff 75 f4             	pushl  -0xc(%ebp)
  8017e9:	6a 00                	push   $0x0
  8017eb:	e8 bc f3 ff ff       	call   800bac <sys_page_alloc>
  8017f0:	89 c3                	mov    %eax,%ebx
  8017f2:	83 c4 10             	add    $0x10,%esp
  8017f5:	85 c0                	test   %eax,%eax
  8017f7:	0f 88 04 01 00 00    	js     801901 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  8017fd:	83 ec 0c             	sub    $0xc,%esp
  801800:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801803:	50                   	push   %eax
  801804:	e8 e3 f5 ff ff       	call   800dec <fd_alloc>
  801809:	89 c3                	mov    %eax,%ebx
  80180b:	83 c4 10             	add    $0x10,%esp
  80180e:	85 c0                	test   %eax,%eax
  801810:	0f 88 db 00 00 00    	js     8018f1 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801816:	83 ec 04             	sub    $0x4,%esp
  801819:	68 07 04 00 00       	push   $0x407
  80181e:	ff 75 f0             	pushl  -0x10(%ebp)
  801821:	6a 00                	push   $0x0
  801823:	e8 84 f3 ff ff       	call   800bac <sys_page_alloc>
  801828:	89 c3                	mov    %eax,%ebx
  80182a:	83 c4 10             	add    $0x10,%esp
  80182d:	85 c0                	test   %eax,%eax
  80182f:	0f 88 bc 00 00 00    	js     8018f1 <pipe+0x135>
	va = fd2data(fd0);
  801835:	83 ec 0c             	sub    $0xc,%esp
  801838:	ff 75 f4             	pushl  -0xc(%ebp)
  80183b:	e8 91 f5 ff ff       	call   800dd1 <fd2data>
  801840:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801842:	83 c4 0c             	add    $0xc,%esp
  801845:	68 07 04 00 00       	push   $0x407
  80184a:	50                   	push   %eax
  80184b:	6a 00                	push   $0x0
  80184d:	e8 5a f3 ff ff       	call   800bac <sys_page_alloc>
  801852:	89 c3                	mov    %eax,%ebx
  801854:	83 c4 10             	add    $0x10,%esp
  801857:	85 c0                	test   %eax,%eax
  801859:	0f 88 82 00 00 00    	js     8018e1 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80185f:	83 ec 0c             	sub    $0xc,%esp
  801862:	ff 75 f0             	pushl  -0x10(%ebp)
  801865:	e8 67 f5 ff ff       	call   800dd1 <fd2data>
  80186a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801871:	50                   	push   %eax
  801872:	6a 00                	push   $0x0
  801874:	56                   	push   %esi
  801875:	6a 00                	push   $0x0
  801877:	e8 77 f3 ff ff       	call   800bf3 <sys_page_map>
  80187c:	89 c3                	mov    %eax,%ebx
  80187e:	83 c4 20             	add    $0x20,%esp
  801881:	85 c0                	test   %eax,%eax
  801883:	78 4e                	js     8018d3 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801885:	a1 20 30 80 00       	mov    0x803020,%eax
  80188a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80188d:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  80188f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801892:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801899:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80189c:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  80189e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8018a8:	83 ec 0c             	sub    $0xc,%esp
  8018ab:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ae:	e8 0a f5 ff ff       	call   800dbd <fd2num>
  8018b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018b6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018b8:	83 c4 04             	add    $0x4,%esp
  8018bb:	ff 75 f0             	pushl  -0x10(%ebp)
  8018be:	e8 fa f4 ff ff       	call   800dbd <fd2num>
  8018c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018c6:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8018c9:	83 c4 10             	add    $0x10,%esp
  8018cc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018d1:	eb 2e                	jmp    801901 <pipe+0x145>
	sys_page_unmap(0, va);
  8018d3:	83 ec 08             	sub    $0x8,%esp
  8018d6:	56                   	push   %esi
  8018d7:	6a 00                	push   $0x0
  8018d9:	e8 5b f3 ff ff       	call   800c39 <sys_page_unmap>
  8018de:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8018e1:	83 ec 08             	sub    $0x8,%esp
  8018e4:	ff 75 f0             	pushl  -0x10(%ebp)
  8018e7:	6a 00                	push   $0x0
  8018e9:	e8 4b f3 ff ff       	call   800c39 <sys_page_unmap>
  8018ee:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8018f1:	83 ec 08             	sub    $0x8,%esp
  8018f4:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f7:	6a 00                	push   $0x0
  8018f9:	e8 3b f3 ff ff       	call   800c39 <sys_page_unmap>
  8018fe:	83 c4 10             	add    $0x10,%esp
}
  801901:	89 d8                	mov    %ebx,%eax
  801903:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801906:	5b                   	pop    %ebx
  801907:	5e                   	pop    %esi
  801908:	5d                   	pop    %ebp
  801909:	c3                   	ret    

0080190a <pipeisclosed>:
{
  80190a:	f3 0f 1e fb          	endbr32 
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801914:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801917:	50                   	push   %eax
  801918:	ff 75 08             	pushl  0x8(%ebp)
  80191b:	e8 22 f5 ff ff       	call   800e42 <fd_lookup>
  801920:	83 c4 10             	add    $0x10,%esp
  801923:	85 c0                	test   %eax,%eax
  801925:	78 18                	js     80193f <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801927:	83 ec 0c             	sub    $0xc,%esp
  80192a:	ff 75 f4             	pushl  -0xc(%ebp)
  80192d:	e8 9f f4 ff ff       	call   800dd1 <fd2data>
  801932:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801934:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801937:	e8 1f fd ff ff       	call   80165b <_pipeisclosed>
  80193c:	83 c4 10             	add    $0x10,%esp
}
  80193f:	c9                   	leave  
  801940:	c3                   	ret    

00801941 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801941:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801945:	b8 00 00 00 00       	mov    $0x0,%eax
  80194a:	c3                   	ret    

0080194b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80194b:	f3 0f 1e fb          	endbr32 
  80194f:	55                   	push   %ebp
  801950:	89 e5                	mov    %esp,%ebp
  801952:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801955:	68 08 23 80 00       	push   $0x802308
  80195a:	ff 75 0c             	pushl  0xc(%ebp)
  80195d:	e8 08 ee ff ff       	call   80076a <strcpy>
	return 0;
}
  801962:	b8 00 00 00 00       	mov    $0x0,%eax
  801967:	c9                   	leave  
  801968:	c3                   	ret    

00801969 <devcons_write>:
{
  801969:	f3 0f 1e fb          	endbr32 
  80196d:	55                   	push   %ebp
  80196e:	89 e5                	mov    %esp,%ebp
  801970:	57                   	push   %edi
  801971:	56                   	push   %esi
  801972:	53                   	push   %ebx
  801973:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801979:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80197e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801984:	3b 75 10             	cmp    0x10(%ebp),%esi
  801987:	73 31                	jae    8019ba <devcons_write+0x51>
		m = n - tot;
  801989:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80198c:	29 f3                	sub    %esi,%ebx
  80198e:	83 fb 7f             	cmp    $0x7f,%ebx
  801991:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801996:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801999:	83 ec 04             	sub    $0x4,%esp
  80199c:	53                   	push   %ebx
  80199d:	89 f0                	mov    %esi,%eax
  80199f:	03 45 0c             	add    0xc(%ebp),%eax
  8019a2:	50                   	push   %eax
  8019a3:	57                   	push   %edi
  8019a4:	e8 77 ef ff ff       	call   800920 <memmove>
		sys_cputs(buf, m);
  8019a9:	83 c4 08             	add    $0x8,%esp
  8019ac:	53                   	push   %ebx
  8019ad:	57                   	push   %edi
  8019ae:	e8 29 f1 ff ff       	call   800adc <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8019b3:	01 de                	add    %ebx,%esi
  8019b5:	83 c4 10             	add    $0x10,%esp
  8019b8:	eb ca                	jmp    801984 <devcons_write+0x1b>
}
  8019ba:	89 f0                	mov    %esi,%eax
  8019bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019bf:	5b                   	pop    %ebx
  8019c0:	5e                   	pop    %esi
  8019c1:	5f                   	pop    %edi
  8019c2:	5d                   	pop    %ebp
  8019c3:	c3                   	ret    

008019c4 <devcons_read>:
{
  8019c4:	f3 0f 1e fb          	endbr32 
  8019c8:	55                   	push   %ebp
  8019c9:	89 e5                	mov    %esp,%ebp
  8019cb:	83 ec 08             	sub    $0x8,%esp
  8019ce:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8019d3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019d7:	74 21                	je     8019fa <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  8019d9:	e8 20 f1 ff ff       	call   800afe <sys_cgetc>
  8019de:	85 c0                	test   %eax,%eax
  8019e0:	75 07                	jne    8019e9 <devcons_read+0x25>
		sys_yield();
  8019e2:	e8 a2 f1 ff ff       	call   800b89 <sys_yield>
  8019e7:	eb f0                	jmp    8019d9 <devcons_read+0x15>
	if (c < 0)
  8019e9:	78 0f                	js     8019fa <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  8019eb:	83 f8 04             	cmp    $0x4,%eax
  8019ee:	74 0c                	je     8019fc <devcons_read+0x38>
	*(char*)vbuf = c;
  8019f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019f3:	88 02                	mov    %al,(%edx)
	return 1;
  8019f5:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8019fa:	c9                   	leave  
  8019fb:	c3                   	ret    
		return 0;
  8019fc:	b8 00 00 00 00       	mov    $0x0,%eax
  801a01:	eb f7                	jmp    8019fa <devcons_read+0x36>

00801a03 <cputchar>:
{
  801a03:	f3 0f 1e fb          	endbr32 
  801a07:	55                   	push   %ebp
  801a08:	89 e5                	mov    %esp,%ebp
  801a0a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a10:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801a13:	6a 01                	push   $0x1
  801a15:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a18:	50                   	push   %eax
  801a19:	e8 be f0 ff ff       	call   800adc <sys_cputs>
}
  801a1e:	83 c4 10             	add    $0x10,%esp
  801a21:	c9                   	leave  
  801a22:	c3                   	ret    

00801a23 <getchar>:
{
  801a23:	f3 0f 1e fb          	endbr32 
  801a27:	55                   	push   %ebp
  801a28:	89 e5                	mov    %esp,%ebp
  801a2a:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801a2d:	6a 01                	push   $0x1
  801a2f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a32:	50                   	push   %eax
  801a33:	6a 00                	push   $0x0
  801a35:	e8 8b f6 ff ff       	call   8010c5 <read>
	if (r < 0)
  801a3a:	83 c4 10             	add    $0x10,%esp
  801a3d:	85 c0                	test   %eax,%eax
  801a3f:	78 06                	js     801a47 <getchar+0x24>
	if (r < 1)
  801a41:	74 06                	je     801a49 <getchar+0x26>
	return c;
  801a43:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801a47:	c9                   	leave  
  801a48:	c3                   	ret    
		return -E_EOF;
  801a49:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801a4e:	eb f7                	jmp    801a47 <getchar+0x24>

00801a50 <iscons>:
{
  801a50:	f3 0f 1e fb          	endbr32 
  801a54:	55                   	push   %ebp
  801a55:	89 e5                	mov    %esp,%ebp
  801a57:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a5d:	50                   	push   %eax
  801a5e:	ff 75 08             	pushl  0x8(%ebp)
  801a61:	e8 dc f3 ff ff       	call   800e42 <fd_lookup>
  801a66:	83 c4 10             	add    $0x10,%esp
  801a69:	85 c0                	test   %eax,%eax
  801a6b:	78 11                	js     801a7e <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801a6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a70:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a76:	39 10                	cmp    %edx,(%eax)
  801a78:	0f 94 c0             	sete   %al
  801a7b:	0f b6 c0             	movzbl %al,%eax
}
  801a7e:	c9                   	leave  
  801a7f:	c3                   	ret    

00801a80 <opencons>:
{
  801a80:	f3 0f 1e fb          	endbr32 
  801a84:	55                   	push   %ebp
  801a85:	89 e5                	mov    %esp,%ebp
  801a87:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801a8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a8d:	50                   	push   %eax
  801a8e:	e8 59 f3 ff ff       	call   800dec <fd_alloc>
  801a93:	83 c4 10             	add    $0x10,%esp
  801a96:	85 c0                	test   %eax,%eax
  801a98:	78 3a                	js     801ad4 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a9a:	83 ec 04             	sub    $0x4,%esp
  801a9d:	68 07 04 00 00       	push   $0x407
  801aa2:	ff 75 f4             	pushl  -0xc(%ebp)
  801aa5:	6a 00                	push   $0x0
  801aa7:	e8 00 f1 ff ff       	call   800bac <sys_page_alloc>
  801aac:	83 c4 10             	add    $0x10,%esp
  801aaf:	85 c0                	test   %eax,%eax
  801ab1:	78 21                	js     801ad4 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801abc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ac8:	83 ec 0c             	sub    $0xc,%esp
  801acb:	50                   	push   %eax
  801acc:	e8 ec f2 ff ff       	call   800dbd <fd2num>
  801ad1:	83 c4 10             	add    $0x10,%esp
}
  801ad4:	c9                   	leave  
  801ad5:	c3                   	ret    

00801ad6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ad6:	f3 0f 1e fb          	endbr32 
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	56                   	push   %esi
  801ade:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801adf:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ae2:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ae8:	e8 79 f0 ff ff       	call   800b66 <sys_getenvid>
  801aed:	83 ec 0c             	sub    $0xc,%esp
  801af0:	ff 75 0c             	pushl  0xc(%ebp)
  801af3:	ff 75 08             	pushl  0x8(%ebp)
  801af6:	56                   	push   %esi
  801af7:	50                   	push   %eax
  801af8:	68 14 23 80 00       	push   $0x802314
  801afd:	e8 5f e6 ff ff       	call   800161 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b02:	83 c4 18             	add    $0x18,%esp
  801b05:	53                   	push   %ebx
  801b06:	ff 75 10             	pushl  0x10(%ebp)
  801b09:	e8 fe e5 ff ff       	call   80010c <vcprintf>
	cprintf("\n");
  801b0e:	c7 04 24 dc 1e 80 00 	movl   $0x801edc,(%esp)
  801b15:	e8 47 e6 ff ff       	call   800161 <cprintf>
  801b1a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b1d:	cc                   	int3   
  801b1e:	eb fd                	jmp    801b1d <_panic+0x47>

00801b20 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b20:	f3 0f 1e fb          	endbr32 
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	56                   	push   %esi
  801b28:	53                   	push   %ebx
  801b29:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b2f:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801b32:	85 c0                	test   %eax,%eax
  801b34:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b39:	0f 44 c2             	cmove  %edx,%eax
  801b3c:	83 ec 0c             	sub    $0xc,%esp
  801b3f:	50                   	push   %eax
  801b40:	e8 33 f2 ff ff       	call   800d78 <sys_ipc_recv>
  801b45:	83 c4 10             	add    $0x10,%esp
  801b48:	85 c0                	test   %eax,%eax
  801b4a:	78 24                	js     801b70 <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801b4c:	85 f6                	test   %esi,%esi
  801b4e:	74 0a                	je     801b5a <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801b50:	a1 04 40 80 00       	mov    0x804004,%eax
  801b55:	8b 40 78             	mov    0x78(%eax),%eax
  801b58:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801b5a:	85 db                	test   %ebx,%ebx
  801b5c:	74 0a                	je     801b68 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801b5e:	a1 04 40 80 00       	mov    0x804004,%eax
  801b63:	8b 40 74             	mov    0x74(%eax),%eax
  801b66:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801b68:	a1 04 40 80 00       	mov    0x804004,%eax
  801b6d:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b70:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b73:	5b                   	pop    %ebx
  801b74:	5e                   	pop    %esi
  801b75:	5d                   	pop    %ebp
  801b76:	c3                   	ret    

00801b77 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b77:	f3 0f 1e fb          	endbr32 
  801b7b:	55                   	push   %ebp
  801b7c:	89 e5                	mov    %esp,%ebp
  801b7e:	57                   	push   %edi
  801b7f:	56                   	push   %esi
  801b80:	53                   	push   %ebx
  801b81:	83 ec 1c             	sub    $0x1c,%esp
  801b84:	8b 45 10             	mov    0x10(%ebp),%eax
  801b87:	85 c0                	test   %eax,%eax
  801b89:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b8e:	0f 45 d0             	cmovne %eax,%edx
  801b91:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801b93:	be 01 00 00 00       	mov    $0x1,%esi
  801b98:	eb 1f                	jmp    801bb9 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801b9a:	e8 ea ef ff ff       	call   800b89 <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801b9f:	83 c3 01             	add    $0x1,%ebx
  801ba2:	39 de                	cmp    %ebx,%esi
  801ba4:	7f f4                	jg     801b9a <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801ba6:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801ba8:	83 fe 11             	cmp    $0x11,%esi
  801bab:	b8 01 00 00 00       	mov    $0x1,%eax
  801bb0:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801bb3:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801bb7:	75 1c                	jne    801bd5 <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801bb9:	ff 75 14             	pushl  0x14(%ebp)
  801bbc:	57                   	push   %edi
  801bbd:	ff 75 0c             	pushl  0xc(%ebp)
  801bc0:	ff 75 08             	pushl  0x8(%ebp)
  801bc3:	e8 89 f1 ff ff       	call   800d51 <sys_ipc_try_send>
  801bc8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801bcb:	83 c4 10             	add    $0x10,%esp
  801bce:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bd3:	eb cd                	jmp    801ba2 <ipc_send+0x2b>
}
  801bd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bd8:	5b                   	pop    %ebx
  801bd9:	5e                   	pop    %esi
  801bda:	5f                   	pop    %edi
  801bdb:	5d                   	pop    %ebp
  801bdc:	c3                   	ret    

00801bdd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bdd:	f3 0f 1e fb          	endbr32 
  801be1:	55                   	push   %ebp
  801be2:	89 e5                	mov    %esp,%ebp
  801be4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801be7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801bec:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801bef:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801bf5:	8b 52 50             	mov    0x50(%edx),%edx
  801bf8:	39 ca                	cmp    %ecx,%edx
  801bfa:	74 11                	je     801c0d <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801bfc:	83 c0 01             	add    $0x1,%eax
  801bff:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c04:	75 e6                	jne    801bec <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801c06:	b8 00 00 00 00       	mov    $0x0,%eax
  801c0b:	eb 0b                	jmp    801c18 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801c0d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c10:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c15:	8b 40 48             	mov    0x48(%eax),%eax
}
  801c18:	5d                   	pop    %ebp
  801c19:	c3                   	ret    

00801c1a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c1a:	f3 0f 1e fb          	endbr32 
  801c1e:	55                   	push   %ebp
  801c1f:	89 e5                	mov    %esp,%ebp
  801c21:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c24:	89 c2                	mov    %eax,%edx
  801c26:	c1 ea 16             	shr    $0x16,%edx
  801c29:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801c30:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801c35:	f6 c1 01             	test   $0x1,%cl
  801c38:	74 1c                	je     801c56 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801c3a:	c1 e8 0c             	shr    $0xc,%eax
  801c3d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c44:	a8 01                	test   $0x1,%al
  801c46:	74 0e                	je     801c56 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c48:	c1 e8 0c             	shr    $0xc,%eax
  801c4b:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801c52:	ef 
  801c53:	0f b7 d2             	movzwl %dx,%edx
}
  801c56:	89 d0                	mov    %edx,%eax
  801c58:	5d                   	pop    %ebp
  801c59:	c3                   	ret    
  801c5a:	66 90                	xchg   %ax,%ax
  801c5c:	66 90                	xchg   %ax,%ax
  801c5e:	66 90                	xchg   %ax,%ax

00801c60 <__udivdi3>:
  801c60:	f3 0f 1e fb          	endbr32 
  801c64:	55                   	push   %ebp
  801c65:	57                   	push   %edi
  801c66:	56                   	push   %esi
  801c67:	53                   	push   %ebx
  801c68:	83 ec 1c             	sub    $0x1c,%esp
  801c6b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c6f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801c73:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c77:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801c7b:	85 d2                	test   %edx,%edx
  801c7d:	75 19                	jne    801c98 <__udivdi3+0x38>
  801c7f:	39 f3                	cmp    %esi,%ebx
  801c81:	76 4d                	jbe    801cd0 <__udivdi3+0x70>
  801c83:	31 ff                	xor    %edi,%edi
  801c85:	89 e8                	mov    %ebp,%eax
  801c87:	89 f2                	mov    %esi,%edx
  801c89:	f7 f3                	div    %ebx
  801c8b:	89 fa                	mov    %edi,%edx
  801c8d:	83 c4 1c             	add    $0x1c,%esp
  801c90:	5b                   	pop    %ebx
  801c91:	5e                   	pop    %esi
  801c92:	5f                   	pop    %edi
  801c93:	5d                   	pop    %ebp
  801c94:	c3                   	ret    
  801c95:	8d 76 00             	lea    0x0(%esi),%esi
  801c98:	39 f2                	cmp    %esi,%edx
  801c9a:	76 14                	jbe    801cb0 <__udivdi3+0x50>
  801c9c:	31 ff                	xor    %edi,%edi
  801c9e:	31 c0                	xor    %eax,%eax
  801ca0:	89 fa                	mov    %edi,%edx
  801ca2:	83 c4 1c             	add    $0x1c,%esp
  801ca5:	5b                   	pop    %ebx
  801ca6:	5e                   	pop    %esi
  801ca7:	5f                   	pop    %edi
  801ca8:	5d                   	pop    %ebp
  801ca9:	c3                   	ret    
  801caa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cb0:	0f bd fa             	bsr    %edx,%edi
  801cb3:	83 f7 1f             	xor    $0x1f,%edi
  801cb6:	75 48                	jne    801d00 <__udivdi3+0xa0>
  801cb8:	39 f2                	cmp    %esi,%edx
  801cba:	72 06                	jb     801cc2 <__udivdi3+0x62>
  801cbc:	31 c0                	xor    %eax,%eax
  801cbe:	39 eb                	cmp    %ebp,%ebx
  801cc0:	77 de                	ja     801ca0 <__udivdi3+0x40>
  801cc2:	b8 01 00 00 00       	mov    $0x1,%eax
  801cc7:	eb d7                	jmp    801ca0 <__udivdi3+0x40>
  801cc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cd0:	89 d9                	mov    %ebx,%ecx
  801cd2:	85 db                	test   %ebx,%ebx
  801cd4:	75 0b                	jne    801ce1 <__udivdi3+0x81>
  801cd6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cdb:	31 d2                	xor    %edx,%edx
  801cdd:	f7 f3                	div    %ebx
  801cdf:	89 c1                	mov    %eax,%ecx
  801ce1:	31 d2                	xor    %edx,%edx
  801ce3:	89 f0                	mov    %esi,%eax
  801ce5:	f7 f1                	div    %ecx
  801ce7:	89 c6                	mov    %eax,%esi
  801ce9:	89 e8                	mov    %ebp,%eax
  801ceb:	89 f7                	mov    %esi,%edi
  801ced:	f7 f1                	div    %ecx
  801cef:	89 fa                	mov    %edi,%edx
  801cf1:	83 c4 1c             	add    $0x1c,%esp
  801cf4:	5b                   	pop    %ebx
  801cf5:	5e                   	pop    %esi
  801cf6:	5f                   	pop    %edi
  801cf7:	5d                   	pop    %ebp
  801cf8:	c3                   	ret    
  801cf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d00:	89 f9                	mov    %edi,%ecx
  801d02:	b8 20 00 00 00       	mov    $0x20,%eax
  801d07:	29 f8                	sub    %edi,%eax
  801d09:	d3 e2                	shl    %cl,%edx
  801d0b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d0f:	89 c1                	mov    %eax,%ecx
  801d11:	89 da                	mov    %ebx,%edx
  801d13:	d3 ea                	shr    %cl,%edx
  801d15:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801d19:	09 d1                	or     %edx,%ecx
  801d1b:	89 f2                	mov    %esi,%edx
  801d1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d21:	89 f9                	mov    %edi,%ecx
  801d23:	d3 e3                	shl    %cl,%ebx
  801d25:	89 c1                	mov    %eax,%ecx
  801d27:	d3 ea                	shr    %cl,%edx
  801d29:	89 f9                	mov    %edi,%ecx
  801d2b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801d2f:	89 eb                	mov    %ebp,%ebx
  801d31:	d3 e6                	shl    %cl,%esi
  801d33:	89 c1                	mov    %eax,%ecx
  801d35:	d3 eb                	shr    %cl,%ebx
  801d37:	09 de                	or     %ebx,%esi
  801d39:	89 f0                	mov    %esi,%eax
  801d3b:	f7 74 24 08          	divl   0x8(%esp)
  801d3f:	89 d6                	mov    %edx,%esi
  801d41:	89 c3                	mov    %eax,%ebx
  801d43:	f7 64 24 0c          	mull   0xc(%esp)
  801d47:	39 d6                	cmp    %edx,%esi
  801d49:	72 15                	jb     801d60 <__udivdi3+0x100>
  801d4b:	89 f9                	mov    %edi,%ecx
  801d4d:	d3 e5                	shl    %cl,%ebp
  801d4f:	39 c5                	cmp    %eax,%ebp
  801d51:	73 04                	jae    801d57 <__udivdi3+0xf7>
  801d53:	39 d6                	cmp    %edx,%esi
  801d55:	74 09                	je     801d60 <__udivdi3+0x100>
  801d57:	89 d8                	mov    %ebx,%eax
  801d59:	31 ff                	xor    %edi,%edi
  801d5b:	e9 40 ff ff ff       	jmp    801ca0 <__udivdi3+0x40>
  801d60:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801d63:	31 ff                	xor    %edi,%edi
  801d65:	e9 36 ff ff ff       	jmp    801ca0 <__udivdi3+0x40>
  801d6a:	66 90                	xchg   %ax,%ax
  801d6c:	66 90                	xchg   %ax,%ax
  801d6e:	66 90                	xchg   %ax,%ax

00801d70 <__umoddi3>:
  801d70:	f3 0f 1e fb          	endbr32 
  801d74:	55                   	push   %ebp
  801d75:	57                   	push   %edi
  801d76:	56                   	push   %esi
  801d77:	53                   	push   %ebx
  801d78:	83 ec 1c             	sub    $0x1c,%esp
  801d7b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d7f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801d83:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801d87:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d8b:	85 c0                	test   %eax,%eax
  801d8d:	75 19                	jne    801da8 <__umoddi3+0x38>
  801d8f:	39 df                	cmp    %ebx,%edi
  801d91:	76 5d                	jbe    801df0 <__umoddi3+0x80>
  801d93:	89 f0                	mov    %esi,%eax
  801d95:	89 da                	mov    %ebx,%edx
  801d97:	f7 f7                	div    %edi
  801d99:	89 d0                	mov    %edx,%eax
  801d9b:	31 d2                	xor    %edx,%edx
  801d9d:	83 c4 1c             	add    $0x1c,%esp
  801da0:	5b                   	pop    %ebx
  801da1:	5e                   	pop    %esi
  801da2:	5f                   	pop    %edi
  801da3:	5d                   	pop    %ebp
  801da4:	c3                   	ret    
  801da5:	8d 76 00             	lea    0x0(%esi),%esi
  801da8:	89 f2                	mov    %esi,%edx
  801daa:	39 d8                	cmp    %ebx,%eax
  801dac:	76 12                	jbe    801dc0 <__umoddi3+0x50>
  801dae:	89 f0                	mov    %esi,%eax
  801db0:	89 da                	mov    %ebx,%edx
  801db2:	83 c4 1c             	add    $0x1c,%esp
  801db5:	5b                   	pop    %ebx
  801db6:	5e                   	pop    %esi
  801db7:	5f                   	pop    %edi
  801db8:	5d                   	pop    %ebp
  801db9:	c3                   	ret    
  801dba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801dc0:	0f bd e8             	bsr    %eax,%ebp
  801dc3:	83 f5 1f             	xor    $0x1f,%ebp
  801dc6:	75 50                	jne    801e18 <__umoddi3+0xa8>
  801dc8:	39 d8                	cmp    %ebx,%eax
  801dca:	0f 82 e0 00 00 00    	jb     801eb0 <__umoddi3+0x140>
  801dd0:	89 d9                	mov    %ebx,%ecx
  801dd2:	39 f7                	cmp    %esi,%edi
  801dd4:	0f 86 d6 00 00 00    	jbe    801eb0 <__umoddi3+0x140>
  801dda:	89 d0                	mov    %edx,%eax
  801ddc:	89 ca                	mov    %ecx,%edx
  801dde:	83 c4 1c             	add    $0x1c,%esp
  801de1:	5b                   	pop    %ebx
  801de2:	5e                   	pop    %esi
  801de3:	5f                   	pop    %edi
  801de4:	5d                   	pop    %ebp
  801de5:	c3                   	ret    
  801de6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ded:	8d 76 00             	lea    0x0(%esi),%esi
  801df0:	89 fd                	mov    %edi,%ebp
  801df2:	85 ff                	test   %edi,%edi
  801df4:	75 0b                	jne    801e01 <__umoddi3+0x91>
  801df6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dfb:	31 d2                	xor    %edx,%edx
  801dfd:	f7 f7                	div    %edi
  801dff:	89 c5                	mov    %eax,%ebp
  801e01:	89 d8                	mov    %ebx,%eax
  801e03:	31 d2                	xor    %edx,%edx
  801e05:	f7 f5                	div    %ebp
  801e07:	89 f0                	mov    %esi,%eax
  801e09:	f7 f5                	div    %ebp
  801e0b:	89 d0                	mov    %edx,%eax
  801e0d:	31 d2                	xor    %edx,%edx
  801e0f:	eb 8c                	jmp    801d9d <__umoddi3+0x2d>
  801e11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e18:	89 e9                	mov    %ebp,%ecx
  801e1a:	ba 20 00 00 00       	mov    $0x20,%edx
  801e1f:	29 ea                	sub    %ebp,%edx
  801e21:	d3 e0                	shl    %cl,%eax
  801e23:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e27:	89 d1                	mov    %edx,%ecx
  801e29:	89 f8                	mov    %edi,%eax
  801e2b:	d3 e8                	shr    %cl,%eax
  801e2d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801e31:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e35:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e39:	09 c1                	or     %eax,%ecx
  801e3b:	89 d8                	mov    %ebx,%eax
  801e3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e41:	89 e9                	mov    %ebp,%ecx
  801e43:	d3 e7                	shl    %cl,%edi
  801e45:	89 d1                	mov    %edx,%ecx
  801e47:	d3 e8                	shr    %cl,%eax
  801e49:	89 e9                	mov    %ebp,%ecx
  801e4b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e4f:	d3 e3                	shl    %cl,%ebx
  801e51:	89 c7                	mov    %eax,%edi
  801e53:	89 d1                	mov    %edx,%ecx
  801e55:	89 f0                	mov    %esi,%eax
  801e57:	d3 e8                	shr    %cl,%eax
  801e59:	89 e9                	mov    %ebp,%ecx
  801e5b:	89 fa                	mov    %edi,%edx
  801e5d:	d3 e6                	shl    %cl,%esi
  801e5f:	09 d8                	or     %ebx,%eax
  801e61:	f7 74 24 08          	divl   0x8(%esp)
  801e65:	89 d1                	mov    %edx,%ecx
  801e67:	89 f3                	mov    %esi,%ebx
  801e69:	f7 64 24 0c          	mull   0xc(%esp)
  801e6d:	89 c6                	mov    %eax,%esi
  801e6f:	89 d7                	mov    %edx,%edi
  801e71:	39 d1                	cmp    %edx,%ecx
  801e73:	72 06                	jb     801e7b <__umoddi3+0x10b>
  801e75:	75 10                	jne    801e87 <__umoddi3+0x117>
  801e77:	39 c3                	cmp    %eax,%ebx
  801e79:	73 0c                	jae    801e87 <__umoddi3+0x117>
  801e7b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801e7f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801e83:	89 d7                	mov    %edx,%edi
  801e85:	89 c6                	mov    %eax,%esi
  801e87:	89 ca                	mov    %ecx,%edx
  801e89:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801e8e:	29 f3                	sub    %esi,%ebx
  801e90:	19 fa                	sbb    %edi,%edx
  801e92:	89 d0                	mov    %edx,%eax
  801e94:	d3 e0                	shl    %cl,%eax
  801e96:	89 e9                	mov    %ebp,%ecx
  801e98:	d3 eb                	shr    %cl,%ebx
  801e9a:	d3 ea                	shr    %cl,%edx
  801e9c:	09 d8                	or     %ebx,%eax
  801e9e:	83 c4 1c             	add    $0x1c,%esp
  801ea1:	5b                   	pop    %ebx
  801ea2:	5e                   	pop    %esi
  801ea3:	5f                   	pop    %edi
  801ea4:	5d                   	pop    %ebp
  801ea5:	c3                   	ret    
  801ea6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ead:	8d 76 00             	lea    0x0(%esi),%esi
  801eb0:	29 fe                	sub    %edi,%esi
  801eb2:	19 c3                	sbb    %eax,%ebx
  801eb4:	89 f2                	mov    %esi,%edx
  801eb6:	89 d9                	mov    %ebx,%ecx
  801eb8:	e9 1d ff ff ff       	jmp    801dda <__umoddi3+0x6a>
