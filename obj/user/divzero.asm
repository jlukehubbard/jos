
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
  80003d:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800044:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800047:	b8 01 00 00 00       	mov    $0x1,%eax
  80004c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800051:	99                   	cltd   
  800052:	f7 f9                	idiv   %ecx
  800054:	50                   	push   %eax
  800055:	68 e0 1e 80 00       	push   $0x801ee0
  80005a:	e8 14 01 00 00       	call   800173 <cprintf>
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
	thisenv = 0;
  800073:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  80007a:	00 00 00 
    envid_t envid = sys_getenvid();
  80007d:	e8 f6 0a 00 00       	call   800b78 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  800082:	25 ff 03 00 00       	and    $0x3ff,%eax
  800087:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80008a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008f:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800094:	85 db                	test   %ebx,%ebx
  800096:	7e 07                	jle    80009f <libmain+0x3b>
		binaryname = argv[0];
  800098:	8b 06                	mov    (%esi),%eax
  80009a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80009f:	83 ec 08             	sub    $0x8,%esp
  8000a2:	56                   	push   %esi
  8000a3:	53                   	push   %ebx
  8000a4:	e8 8a ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a9:	e8 0a 00 00 00       	call   8000b8 <exit>
}
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000b4:	5b                   	pop    %ebx
  8000b5:	5e                   	pop    %esi
  8000b6:	5d                   	pop    %ebp
  8000b7:	c3                   	ret    

008000b8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b8:	f3 0f 1e fb          	endbr32 
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000c2:	e8 f7 0e 00 00       	call   800fbe <close_all>
	sys_env_destroy(0);
  8000c7:	83 ec 0c             	sub    $0xc,%esp
  8000ca:	6a 00                	push   $0x0
  8000cc:	e8 62 0a 00 00       	call   800b33 <sys_env_destroy>
}
  8000d1:	83 c4 10             	add    $0x10,%esp
  8000d4:	c9                   	leave  
  8000d5:	c3                   	ret    

008000d6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d6:	f3 0f 1e fb          	endbr32 
  8000da:	55                   	push   %ebp
  8000db:	89 e5                	mov    %esp,%ebp
  8000dd:	53                   	push   %ebx
  8000de:	83 ec 04             	sub    $0x4,%esp
  8000e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000e4:	8b 13                	mov    (%ebx),%edx
  8000e6:	8d 42 01             	lea    0x1(%edx),%eax
  8000e9:	89 03                	mov    %eax,(%ebx)
  8000eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ee:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000f2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000f7:	74 09                	je     800102 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000f9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800100:	c9                   	leave  
  800101:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800102:	83 ec 08             	sub    $0x8,%esp
  800105:	68 ff 00 00 00       	push   $0xff
  80010a:	8d 43 08             	lea    0x8(%ebx),%eax
  80010d:	50                   	push   %eax
  80010e:	e8 db 09 00 00       	call   800aee <sys_cputs>
		b->idx = 0;
  800113:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800119:	83 c4 10             	add    $0x10,%esp
  80011c:	eb db                	jmp    8000f9 <putch+0x23>

0080011e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80011e:	f3 0f 1e fb          	endbr32 
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80012b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800132:	00 00 00 
	b.cnt = 0;
  800135:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80013c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80013f:	ff 75 0c             	pushl  0xc(%ebp)
  800142:	ff 75 08             	pushl  0x8(%ebp)
  800145:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014b:	50                   	push   %eax
  80014c:	68 d6 00 80 00       	push   $0x8000d6
  800151:	e8 20 01 00 00       	call   800276 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800156:	83 c4 08             	add    $0x8,%esp
  800159:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80015f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800165:	50                   	push   %eax
  800166:	e8 83 09 00 00       	call   800aee <sys_cputs>

	return b.cnt;
}
  80016b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800171:	c9                   	leave  
  800172:	c3                   	ret    

00800173 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800173:	f3 0f 1e fb          	endbr32 
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80017d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800180:	50                   	push   %eax
  800181:	ff 75 08             	pushl  0x8(%ebp)
  800184:	e8 95 ff ff ff       	call   80011e <vcprintf>
	va_end(ap);

	return cnt;
}
  800189:	c9                   	leave  
  80018a:	c3                   	ret    

0080018b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80018b:	55                   	push   %ebp
  80018c:	89 e5                	mov    %esp,%ebp
  80018e:	57                   	push   %edi
  80018f:	56                   	push   %esi
  800190:	53                   	push   %ebx
  800191:	83 ec 1c             	sub    $0x1c,%esp
  800194:	89 c7                	mov    %eax,%edi
  800196:	89 d6                	mov    %edx,%esi
  800198:	8b 45 08             	mov    0x8(%ebp),%eax
  80019b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019e:	89 d1                	mov    %edx,%ecx
  8001a0:	89 c2                	mov    %eax,%edx
  8001a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001a5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ab:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001b1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001b8:	39 c2                	cmp    %eax,%edx
  8001ba:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001bd:	72 3e                	jb     8001fd <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001bf:	83 ec 0c             	sub    $0xc,%esp
  8001c2:	ff 75 18             	pushl  0x18(%ebp)
  8001c5:	83 eb 01             	sub    $0x1,%ebx
  8001c8:	53                   	push   %ebx
  8001c9:	50                   	push   %eax
  8001ca:	83 ec 08             	sub    $0x8,%esp
  8001cd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d3:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d6:	ff 75 d8             	pushl  -0x28(%ebp)
  8001d9:	e8 92 1a 00 00       	call   801c70 <__udivdi3>
  8001de:	83 c4 18             	add    $0x18,%esp
  8001e1:	52                   	push   %edx
  8001e2:	50                   	push   %eax
  8001e3:	89 f2                	mov    %esi,%edx
  8001e5:	89 f8                	mov    %edi,%eax
  8001e7:	e8 9f ff ff ff       	call   80018b <printnum>
  8001ec:	83 c4 20             	add    $0x20,%esp
  8001ef:	eb 13                	jmp    800204 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001f1:	83 ec 08             	sub    $0x8,%esp
  8001f4:	56                   	push   %esi
  8001f5:	ff 75 18             	pushl  0x18(%ebp)
  8001f8:	ff d7                	call   *%edi
  8001fa:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001fd:	83 eb 01             	sub    $0x1,%ebx
  800200:	85 db                	test   %ebx,%ebx
  800202:	7f ed                	jg     8001f1 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800204:	83 ec 08             	sub    $0x8,%esp
  800207:	56                   	push   %esi
  800208:	83 ec 04             	sub    $0x4,%esp
  80020b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020e:	ff 75 e0             	pushl  -0x20(%ebp)
  800211:	ff 75 dc             	pushl  -0x24(%ebp)
  800214:	ff 75 d8             	pushl  -0x28(%ebp)
  800217:	e8 64 1b 00 00       	call   801d80 <__umoddi3>
  80021c:	83 c4 14             	add    $0x14,%esp
  80021f:	0f be 80 f8 1e 80 00 	movsbl 0x801ef8(%eax),%eax
  800226:	50                   	push   %eax
  800227:	ff d7                	call   *%edi
}
  800229:	83 c4 10             	add    $0x10,%esp
  80022c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022f:	5b                   	pop    %ebx
  800230:	5e                   	pop    %esi
  800231:	5f                   	pop    %edi
  800232:	5d                   	pop    %ebp
  800233:	c3                   	ret    

00800234 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800234:	f3 0f 1e fb          	endbr32 
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80023e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800242:	8b 10                	mov    (%eax),%edx
  800244:	3b 50 04             	cmp    0x4(%eax),%edx
  800247:	73 0a                	jae    800253 <sprintputch+0x1f>
		*b->buf++ = ch;
  800249:	8d 4a 01             	lea    0x1(%edx),%ecx
  80024c:	89 08                	mov    %ecx,(%eax)
  80024e:	8b 45 08             	mov    0x8(%ebp),%eax
  800251:	88 02                	mov    %al,(%edx)
}
  800253:	5d                   	pop    %ebp
  800254:	c3                   	ret    

00800255 <printfmt>:
{
  800255:	f3 0f 1e fb          	endbr32 
  800259:	55                   	push   %ebp
  80025a:	89 e5                	mov    %esp,%ebp
  80025c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80025f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800262:	50                   	push   %eax
  800263:	ff 75 10             	pushl  0x10(%ebp)
  800266:	ff 75 0c             	pushl  0xc(%ebp)
  800269:	ff 75 08             	pushl  0x8(%ebp)
  80026c:	e8 05 00 00 00       	call   800276 <vprintfmt>
}
  800271:	83 c4 10             	add    $0x10,%esp
  800274:	c9                   	leave  
  800275:	c3                   	ret    

00800276 <vprintfmt>:
{
  800276:	f3 0f 1e fb          	endbr32 
  80027a:	55                   	push   %ebp
  80027b:	89 e5                	mov    %esp,%ebp
  80027d:	57                   	push   %edi
  80027e:	56                   	push   %esi
  80027f:	53                   	push   %ebx
  800280:	83 ec 3c             	sub    $0x3c,%esp
  800283:	8b 75 08             	mov    0x8(%ebp),%esi
  800286:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800289:	8b 7d 10             	mov    0x10(%ebp),%edi
  80028c:	e9 4a 03 00 00       	jmp    8005db <vprintfmt+0x365>
		padc = ' ';
  800291:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800295:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80029c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002a3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002aa:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002af:	8d 47 01             	lea    0x1(%edi),%eax
  8002b2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002b5:	0f b6 17             	movzbl (%edi),%edx
  8002b8:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002bb:	3c 55                	cmp    $0x55,%al
  8002bd:	0f 87 de 03 00 00    	ja     8006a1 <vprintfmt+0x42b>
  8002c3:	0f b6 c0             	movzbl %al,%eax
  8002c6:	3e ff 24 85 40 20 80 	notrack jmp *0x802040(,%eax,4)
  8002cd:	00 
  8002ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002d1:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002d5:	eb d8                	jmp    8002af <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8002d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002da:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002de:	eb cf                	jmp    8002af <vprintfmt+0x39>
  8002e0:	0f b6 d2             	movzbl %dl,%edx
  8002e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8002eb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002ee:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002f1:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002f5:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002f8:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002fb:	83 f9 09             	cmp    $0x9,%ecx
  8002fe:	77 55                	ja     800355 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800300:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800303:	eb e9                	jmp    8002ee <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800305:	8b 45 14             	mov    0x14(%ebp),%eax
  800308:	8b 00                	mov    (%eax),%eax
  80030a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80030d:	8b 45 14             	mov    0x14(%ebp),%eax
  800310:	8d 40 04             	lea    0x4(%eax),%eax
  800313:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800316:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800319:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80031d:	79 90                	jns    8002af <vprintfmt+0x39>
				width = precision, precision = -1;
  80031f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800322:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800325:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80032c:	eb 81                	jmp    8002af <vprintfmt+0x39>
  80032e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800331:	85 c0                	test   %eax,%eax
  800333:	ba 00 00 00 00       	mov    $0x0,%edx
  800338:	0f 49 d0             	cmovns %eax,%edx
  80033b:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80033e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800341:	e9 69 ff ff ff       	jmp    8002af <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800346:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800349:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800350:	e9 5a ff ff ff       	jmp    8002af <vprintfmt+0x39>
  800355:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800358:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80035b:	eb bc                	jmp    800319 <vprintfmt+0xa3>
			lflag++;
  80035d:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800360:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800363:	e9 47 ff ff ff       	jmp    8002af <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800368:	8b 45 14             	mov    0x14(%ebp),%eax
  80036b:	8d 78 04             	lea    0x4(%eax),%edi
  80036e:	83 ec 08             	sub    $0x8,%esp
  800371:	53                   	push   %ebx
  800372:	ff 30                	pushl  (%eax)
  800374:	ff d6                	call   *%esi
			break;
  800376:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800379:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80037c:	e9 57 02 00 00       	jmp    8005d8 <vprintfmt+0x362>
			err = va_arg(ap, int);
  800381:	8b 45 14             	mov    0x14(%ebp),%eax
  800384:	8d 78 04             	lea    0x4(%eax),%edi
  800387:	8b 00                	mov    (%eax),%eax
  800389:	99                   	cltd   
  80038a:	31 d0                	xor    %edx,%eax
  80038c:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80038e:	83 f8 0f             	cmp    $0xf,%eax
  800391:	7f 23                	jg     8003b6 <vprintfmt+0x140>
  800393:	8b 14 85 a0 21 80 00 	mov    0x8021a0(,%eax,4),%edx
  80039a:	85 d2                	test   %edx,%edx
  80039c:	74 18                	je     8003b6 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80039e:	52                   	push   %edx
  80039f:	68 fa 22 80 00       	push   $0x8022fa
  8003a4:	53                   	push   %ebx
  8003a5:	56                   	push   %esi
  8003a6:	e8 aa fe ff ff       	call   800255 <printfmt>
  8003ab:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003ae:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003b1:	e9 22 02 00 00       	jmp    8005d8 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8003b6:	50                   	push   %eax
  8003b7:	68 10 1f 80 00       	push   $0x801f10
  8003bc:	53                   	push   %ebx
  8003bd:	56                   	push   %esi
  8003be:	e8 92 fe ff ff       	call   800255 <printfmt>
  8003c3:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003c6:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003c9:	e9 0a 02 00 00       	jmp    8005d8 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8003ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d1:	83 c0 04             	add    $0x4,%eax
  8003d4:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003da:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003dc:	85 d2                	test   %edx,%edx
  8003de:	b8 09 1f 80 00       	mov    $0x801f09,%eax
  8003e3:	0f 45 c2             	cmovne %edx,%eax
  8003e6:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003e9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ed:	7e 06                	jle    8003f5 <vprintfmt+0x17f>
  8003ef:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8003f3:	75 0d                	jne    800402 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003f5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003f8:	89 c7                	mov    %eax,%edi
  8003fa:	03 45 e0             	add    -0x20(%ebp),%eax
  8003fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800400:	eb 55                	jmp    800457 <vprintfmt+0x1e1>
  800402:	83 ec 08             	sub    $0x8,%esp
  800405:	ff 75 d8             	pushl  -0x28(%ebp)
  800408:	ff 75 cc             	pushl  -0x34(%ebp)
  80040b:	e8 45 03 00 00       	call   800755 <strnlen>
  800410:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800413:	29 c2                	sub    %eax,%edx
  800415:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800418:	83 c4 10             	add    $0x10,%esp
  80041b:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80041d:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800421:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800424:	85 ff                	test   %edi,%edi
  800426:	7e 11                	jle    800439 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800428:	83 ec 08             	sub    $0x8,%esp
  80042b:	53                   	push   %ebx
  80042c:	ff 75 e0             	pushl  -0x20(%ebp)
  80042f:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800431:	83 ef 01             	sub    $0x1,%edi
  800434:	83 c4 10             	add    $0x10,%esp
  800437:	eb eb                	jmp    800424 <vprintfmt+0x1ae>
  800439:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80043c:	85 d2                	test   %edx,%edx
  80043e:	b8 00 00 00 00       	mov    $0x0,%eax
  800443:	0f 49 c2             	cmovns %edx,%eax
  800446:	29 c2                	sub    %eax,%edx
  800448:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80044b:	eb a8                	jmp    8003f5 <vprintfmt+0x17f>
					putch(ch, putdat);
  80044d:	83 ec 08             	sub    $0x8,%esp
  800450:	53                   	push   %ebx
  800451:	52                   	push   %edx
  800452:	ff d6                	call   *%esi
  800454:	83 c4 10             	add    $0x10,%esp
  800457:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80045a:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80045c:	83 c7 01             	add    $0x1,%edi
  80045f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800463:	0f be d0             	movsbl %al,%edx
  800466:	85 d2                	test   %edx,%edx
  800468:	74 4b                	je     8004b5 <vprintfmt+0x23f>
  80046a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80046e:	78 06                	js     800476 <vprintfmt+0x200>
  800470:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800474:	78 1e                	js     800494 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800476:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80047a:	74 d1                	je     80044d <vprintfmt+0x1d7>
  80047c:	0f be c0             	movsbl %al,%eax
  80047f:	83 e8 20             	sub    $0x20,%eax
  800482:	83 f8 5e             	cmp    $0x5e,%eax
  800485:	76 c6                	jbe    80044d <vprintfmt+0x1d7>
					putch('?', putdat);
  800487:	83 ec 08             	sub    $0x8,%esp
  80048a:	53                   	push   %ebx
  80048b:	6a 3f                	push   $0x3f
  80048d:	ff d6                	call   *%esi
  80048f:	83 c4 10             	add    $0x10,%esp
  800492:	eb c3                	jmp    800457 <vprintfmt+0x1e1>
  800494:	89 cf                	mov    %ecx,%edi
  800496:	eb 0e                	jmp    8004a6 <vprintfmt+0x230>
				putch(' ', putdat);
  800498:	83 ec 08             	sub    $0x8,%esp
  80049b:	53                   	push   %ebx
  80049c:	6a 20                	push   $0x20
  80049e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004a0:	83 ef 01             	sub    $0x1,%edi
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	85 ff                	test   %edi,%edi
  8004a8:	7f ee                	jg     800498 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8004aa:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004ad:	89 45 14             	mov    %eax,0x14(%ebp)
  8004b0:	e9 23 01 00 00       	jmp    8005d8 <vprintfmt+0x362>
  8004b5:	89 cf                	mov    %ecx,%edi
  8004b7:	eb ed                	jmp    8004a6 <vprintfmt+0x230>
	if (lflag >= 2)
  8004b9:	83 f9 01             	cmp    $0x1,%ecx
  8004bc:	7f 1b                	jg     8004d9 <vprintfmt+0x263>
	else if (lflag)
  8004be:	85 c9                	test   %ecx,%ecx
  8004c0:	74 63                	je     800525 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8004c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c5:	8b 00                	mov    (%eax),%eax
  8004c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004ca:	99                   	cltd   
  8004cb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d1:	8d 40 04             	lea    0x4(%eax),%eax
  8004d4:	89 45 14             	mov    %eax,0x14(%ebp)
  8004d7:	eb 17                	jmp    8004f0 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8004d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dc:	8b 50 04             	mov    0x4(%eax),%edx
  8004df:	8b 00                	mov    (%eax),%eax
  8004e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004e4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ea:	8d 40 08             	lea    0x8(%eax),%eax
  8004ed:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004f0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004f3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8004f6:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8004fb:	85 c9                	test   %ecx,%ecx
  8004fd:	0f 89 bb 00 00 00    	jns    8005be <vprintfmt+0x348>
				putch('-', putdat);
  800503:	83 ec 08             	sub    $0x8,%esp
  800506:	53                   	push   %ebx
  800507:	6a 2d                	push   $0x2d
  800509:	ff d6                	call   *%esi
				num = -(long long) num;
  80050b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80050e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800511:	f7 da                	neg    %edx
  800513:	83 d1 00             	adc    $0x0,%ecx
  800516:	f7 d9                	neg    %ecx
  800518:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80051b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800520:	e9 99 00 00 00       	jmp    8005be <vprintfmt+0x348>
		return va_arg(*ap, int);
  800525:	8b 45 14             	mov    0x14(%ebp),%eax
  800528:	8b 00                	mov    (%eax),%eax
  80052a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80052d:	99                   	cltd   
  80052e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800531:	8b 45 14             	mov    0x14(%ebp),%eax
  800534:	8d 40 04             	lea    0x4(%eax),%eax
  800537:	89 45 14             	mov    %eax,0x14(%ebp)
  80053a:	eb b4                	jmp    8004f0 <vprintfmt+0x27a>
	if (lflag >= 2)
  80053c:	83 f9 01             	cmp    $0x1,%ecx
  80053f:	7f 1b                	jg     80055c <vprintfmt+0x2e6>
	else if (lflag)
  800541:	85 c9                	test   %ecx,%ecx
  800543:	74 2c                	je     800571 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800545:	8b 45 14             	mov    0x14(%ebp),%eax
  800548:	8b 10                	mov    (%eax),%edx
  80054a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80054f:	8d 40 04             	lea    0x4(%eax),%eax
  800552:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800555:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80055a:	eb 62                	jmp    8005be <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80055c:	8b 45 14             	mov    0x14(%ebp),%eax
  80055f:	8b 10                	mov    (%eax),%edx
  800561:	8b 48 04             	mov    0x4(%eax),%ecx
  800564:	8d 40 08             	lea    0x8(%eax),%eax
  800567:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80056a:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80056f:	eb 4d                	jmp    8005be <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8b 10                	mov    (%eax),%edx
  800576:	b9 00 00 00 00       	mov    $0x0,%ecx
  80057b:	8d 40 04             	lea    0x4(%eax),%eax
  80057e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800581:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800586:	eb 36                	jmp    8005be <vprintfmt+0x348>
	if (lflag >= 2)
  800588:	83 f9 01             	cmp    $0x1,%ecx
  80058b:	7f 17                	jg     8005a4 <vprintfmt+0x32e>
	else if (lflag)
  80058d:	85 c9                	test   %ecx,%ecx
  80058f:	74 6e                	je     8005ff <vprintfmt+0x389>
		return va_arg(*ap, long);
  800591:	8b 45 14             	mov    0x14(%ebp),%eax
  800594:	8b 10                	mov    (%eax),%edx
  800596:	89 d0                	mov    %edx,%eax
  800598:	99                   	cltd   
  800599:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80059c:	8d 49 04             	lea    0x4(%ecx),%ecx
  80059f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005a2:	eb 11                	jmp    8005b5 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8005a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a7:	8b 50 04             	mov    0x4(%eax),%edx
  8005aa:	8b 00                	mov    (%eax),%eax
  8005ac:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005af:	8d 49 08             	lea    0x8(%ecx),%ecx
  8005b2:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8005b5:	89 d1                	mov    %edx,%ecx
  8005b7:	89 c2                	mov    %eax,%edx
            base = 8;
  8005b9:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005be:	83 ec 0c             	sub    $0xc,%esp
  8005c1:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005c5:	57                   	push   %edi
  8005c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8005c9:	50                   	push   %eax
  8005ca:	51                   	push   %ecx
  8005cb:	52                   	push   %edx
  8005cc:	89 da                	mov    %ebx,%edx
  8005ce:	89 f0                	mov    %esi,%eax
  8005d0:	e8 b6 fb ff ff       	call   80018b <printnum>
			break;
  8005d5:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8005d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005db:	83 c7 01             	add    $0x1,%edi
  8005de:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005e2:	83 f8 25             	cmp    $0x25,%eax
  8005e5:	0f 84 a6 fc ff ff    	je     800291 <vprintfmt+0x1b>
			if (ch == '\0')
  8005eb:	85 c0                	test   %eax,%eax
  8005ed:	0f 84 ce 00 00 00    	je     8006c1 <vprintfmt+0x44b>
			putch(ch, putdat);
  8005f3:	83 ec 08             	sub    $0x8,%esp
  8005f6:	53                   	push   %ebx
  8005f7:	50                   	push   %eax
  8005f8:	ff d6                	call   *%esi
  8005fa:	83 c4 10             	add    $0x10,%esp
  8005fd:	eb dc                	jmp    8005db <vprintfmt+0x365>
		return va_arg(*ap, int);
  8005ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800602:	8b 10                	mov    (%eax),%edx
  800604:	89 d0                	mov    %edx,%eax
  800606:	99                   	cltd   
  800607:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80060a:	8d 49 04             	lea    0x4(%ecx),%ecx
  80060d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800610:	eb a3                	jmp    8005b5 <vprintfmt+0x33f>
			putch('0', putdat);
  800612:	83 ec 08             	sub    $0x8,%esp
  800615:	53                   	push   %ebx
  800616:	6a 30                	push   $0x30
  800618:	ff d6                	call   *%esi
			putch('x', putdat);
  80061a:	83 c4 08             	add    $0x8,%esp
  80061d:	53                   	push   %ebx
  80061e:	6a 78                	push   $0x78
  800620:	ff d6                	call   *%esi
			num = (unsigned long long)
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8b 10                	mov    (%eax),%edx
  800627:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80062c:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80062f:	8d 40 04             	lea    0x4(%eax),%eax
  800632:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800635:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80063a:	eb 82                	jmp    8005be <vprintfmt+0x348>
	if (lflag >= 2)
  80063c:	83 f9 01             	cmp    $0x1,%ecx
  80063f:	7f 1e                	jg     80065f <vprintfmt+0x3e9>
	else if (lflag)
  800641:	85 c9                	test   %ecx,%ecx
  800643:	74 32                	je     800677 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800645:	8b 45 14             	mov    0x14(%ebp),%eax
  800648:	8b 10                	mov    (%eax),%edx
  80064a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064f:	8d 40 04             	lea    0x4(%eax),%eax
  800652:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800655:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80065a:	e9 5f ff ff ff       	jmp    8005be <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80065f:	8b 45 14             	mov    0x14(%ebp),%eax
  800662:	8b 10                	mov    (%eax),%edx
  800664:	8b 48 04             	mov    0x4(%eax),%ecx
  800667:	8d 40 08             	lea    0x8(%eax),%eax
  80066a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80066d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800672:	e9 47 ff ff ff       	jmp    8005be <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	8b 10                	mov    (%eax),%edx
  80067c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800681:	8d 40 04             	lea    0x4(%eax),%eax
  800684:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800687:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80068c:	e9 2d ff ff ff       	jmp    8005be <vprintfmt+0x348>
			putch(ch, putdat);
  800691:	83 ec 08             	sub    $0x8,%esp
  800694:	53                   	push   %ebx
  800695:	6a 25                	push   $0x25
  800697:	ff d6                	call   *%esi
			break;
  800699:	83 c4 10             	add    $0x10,%esp
  80069c:	e9 37 ff ff ff       	jmp    8005d8 <vprintfmt+0x362>
			putch('%', putdat);
  8006a1:	83 ec 08             	sub    $0x8,%esp
  8006a4:	53                   	push   %ebx
  8006a5:	6a 25                	push   $0x25
  8006a7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006a9:	83 c4 10             	add    $0x10,%esp
  8006ac:	89 f8                	mov    %edi,%eax
  8006ae:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006b2:	74 05                	je     8006b9 <vprintfmt+0x443>
  8006b4:	83 e8 01             	sub    $0x1,%eax
  8006b7:	eb f5                	jmp    8006ae <vprintfmt+0x438>
  8006b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006bc:	e9 17 ff ff ff       	jmp    8005d8 <vprintfmt+0x362>
}
  8006c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c4:	5b                   	pop    %ebx
  8006c5:	5e                   	pop    %esi
  8006c6:	5f                   	pop    %edi
  8006c7:	5d                   	pop    %ebp
  8006c8:	c3                   	ret    

008006c9 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006c9:	f3 0f 1e fb          	endbr32 
  8006cd:	55                   	push   %ebp
  8006ce:	89 e5                	mov    %esp,%ebp
  8006d0:	83 ec 18             	sub    $0x18,%esp
  8006d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006dc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ea:	85 c0                	test   %eax,%eax
  8006ec:	74 26                	je     800714 <vsnprintf+0x4b>
  8006ee:	85 d2                	test   %edx,%edx
  8006f0:	7e 22                	jle    800714 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f2:	ff 75 14             	pushl  0x14(%ebp)
  8006f5:	ff 75 10             	pushl  0x10(%ebp)
  8006f8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006fb:	50                   	push   %eax
  8006fc:	68 34 02 80 00       	push   $0x800234
  800701:	e8 70 fb ff ff       	call   800276 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800706:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800709:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80070c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80070f:	83 c4 10             	add    $0x10,%esp
}
  800712:	c9                   	leave  
  800713:	c3                   	ret    
		return -E_INVAL;
  800714:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800719:	eb f7                	jmp    800712 <vsnprintf+0x49>

0080071b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80071b:	f3 0f 1e fb          	endbr32 
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
  800722:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800725:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800728:	50                   	push   %eax
  800729:	ff 75 10             	pushl  0x10(%ebp)
  80072c:	ff 75 0c             	pushl  0xc(%ebp)
  80072f:	ff 75 08             	pushl  0x8(%ebp)
  800732:	e8 92 ff ff ff       	call   8006c9 <vsnprintf>
	va_end(ap);

	return rc;
}
  800737:	c9                   	leave  
  800738:	c3                   	ret    

00800739 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800739:	f3 0f 1e fb          	endbr32 
  80073d:	55                   	push   %ebp
  80073e:	89 e5                	mov    %esp,%ebp
  800740:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800743:	b8 00 00 00 00       	mov    $0x0,%eax
  800748:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80074c:	74 05                	je     800753 <strlen+0x1a>
		n++;
  80074e:	83 c0 01             	add    $0x1,%eax
  800751:	eb f5                	jmp    800748 <strlen+0xf>
	return n;
}
  800753:	5d                   	pop    %ebp
  800754:	c3                   	ret    

00800755 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800755:	f3 0f 1e fb          	endbr32 
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800762:	b8 00 00 00 00       	mov    $0x0,%eax
  800767:	39 d0                	cmp    %edx,%eax
  800769:	74 0d                	je     800778 <strnlen+0x23>
  80076b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80076f:	74 05                	je     800776 <strnlen+0x21>
		n++;
  800771:	83 c0 01             	add    $0x1,%eax
  800774:	eb f1                	jmp    800767 <strnlen+0x12>
  800776:	89 c2                	mov    %eax,%edx
	return n;
}
  800778:	89 d0                	mov    %edx,%eax
  80077a:	5d                   	pop    %ebp
  80077b:	c3                   	ret    

0080077c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80077c:	f3 0f 1e fb          	endbr32 
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	53                   	push   %ebx
  800784:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800787:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80078a:	b8 00 00 00 00       	mov    $0x0,%eax
  80078f:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800793:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800796:	83 c0 01             	add    $0x1,%eax
  800799:	84 d2                	test   %dl,%dl
  80079b:	75 f2                	jne    80078f <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80079d:	89 c8                	mov    %ecx,%eax
  80079f:	5b                   	pop    %ebx
  8007a0:	5d                   	pop    %ebp
  8007a1:	c3                   	ret    

008007a2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a2:	f3 0f 1e fb          	endbr32 
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	53                   	push   %ebx
  8007aa:	83 ec 10             	sub    $0x10,%esp
  8007ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007b0:	53                   	push   %ebx
  8007b1:	e8 83 ff ff ff       	call   800739 <strlen>
  8007b6:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007b9:	ff 75 0c             	pushl  0xc(%ebp)
  8007bc:	01 d8                	add    %ebx,%eax
  8007be:	50                   	push   %eax
  8007bf:	e8 b8 ff ff ff       	call   80077c <strcpy>
	return dst;
}
  8007c4:	89 d8                	mov    %ebx,%eax
  8007c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c9:	c9                   	leave  
  8007ca:	c3                   	ret    

008007cb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007cb:	f3 0f 1e fb          	endbr32 
  8007cf:	55                   	push   %ebp
  8007d0:	89 e5                	mov    %esp,%ebp
  8007d2:	56                   	push   %esi
  8007d3:	53                   	push   %ebx
  8007d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007da:	89 f3                	mov    %esi,%ebx
  8007dc:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007df:	89 f0                	mov    %esi,%eax
  8007e1:	39 d8                	cmp    %ebx,%eax
  8007e3:	74 11                	je     8007f6 <strncpy+0x2b>
		*dst++ = *src;
  8007e5:	83 c0 01             	add    $0x1,%eax
  8007e8:	0f b6 0a             	movzbl (%edx),%ecx
  8007eb:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ee:	80 f9 01             	cmp    $0x1,%cl
  8007f1:	83 da ff             	sbb    $0xffffffff,%edx
  8007f4:	eb eb                	jmp    8007e1 <strncpy+0x16>
	}
	return ret;
}
  8007f6:	89 f0                	mov    %esi,%eax
  8007f8:	5b                   	pop    %ebx
  8007f9:	5e                   	pop    %esi
  8007fa:	5d                   	pop    %ebp
  8007fb:	c3                   	ret    

008007fc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007fc:	f3 0f 1e fb          	endbr32 
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	56                   	push   %esi
  800804:	53                   	push   %ebx
  800805:	8b 75 08             	mov    0x8(%ebp),%esi
  800808:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080b:	8b 55 10             	mov    0x10(%ebp),%edx
  80080e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800810:	85 d2                	test   %edx,%edx
  800812:	74 21                	je     800835 <strlcpy+0x39>
  800814:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800818:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80081a:	39 c2                	cmp    %eax,%edx
  80081c:	74 14                	je     800832 <strlcpy+0x36>
  80081e:	0f b6 19             	movzbl (%ecx),%ebx
  800821:	84 db                	test   %bl,%bl
  800823:	74 0b                	je     800830 <strlcpy+0x34>
			*dst++ = *src++;
  800825:	83 c1 01             	add    $0x1,%ecx
  800828:	83 c2 01             	add    $0x1,%edx
  80082b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80082e:	eb ea                	jmp    80081a <strlcpy+0x1e>
  800830:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800832:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800835:	29 f0                	sub    %esi,%eax
}
  800837:	5b                   	pop    %ebx
  800838:	5e                   	pop    %esi
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80083b:	f3 0f 1e fb          	endbr32 
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800845:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800848:	0f b6 01             	movzbl (%ecx),%eax
  80084b:	84 c0                	test   %al,%al
  80084d:	74 0c                	je     80085b <strcmp+0x20>
  80084f:	3a 02                	cmp    (%edx),%al
  800851:	75 08                	jne    80085b <strcmp+0x20>
		p++, q++;
  800853:	83 c1 01             	add    $0x1,%ecx
  800856:	83 c2 01             	add    $0x1,%edx
  800859:	eb ed                	jmp    800848 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80085b:	0f b6 c0             	movzbl %al,%eax
  80085e:	0f b6 12             	movzbl (%edx),%edx
  800861:	29 d0                	sub    %edx,%eax
}
  800863:	5d                   	pop    %ebp
  800864:	c3                   	ret    

00800865 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800865:	f3 0f 1e fb          	endbr32 
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	53                   	push   %ebx
  80086d:	8b 45 08             	mov    0x8(%ebp),%eax
  800870:	8b 55 0c             	mov    0xc(%ebp),%edx
  800873:	89 c3                	mov    %eax,%ebx
  800875:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800878:	eb 06                	jmp    800880 <strncmp+0x1b>
		n--, p++, q++;
  80087a:	83 c0 01             	add    $0x1,%eax
  80087d:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800880:	39 d8                	cmp    %ebx,%eax
  800882:	74 16                	je     80089a <strncmp+0x35>
  800884:	0f b6 08             	movzbl (%eax),%ecx
  800887:	84 c9                	test   %cl,%cl
  800889:	74 04                	je     80088f <strncmp+0x2a>
  80088b:	3a 0a                	cmp    (%edx),%cl
  80088d:	74 eb                	je     80087a <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088f:	0f b6 00             	movzbl (%eax),%eax
  800892:	0f b6 12             	movzbl (%edx),%edx
  800895:	29 d0                	sub    %edx,%eax
}
  800897:	5b                   	pop    %ebx
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    
		return 0;
  80089a:	b8 00 00 00 00       	mov    $0x0,%eax
  80089f:	eb f6                	jmp    800897 <strncmp+0x32>

008008a1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a1:	f3 0f 1e fb          	endbr32 
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ab:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008af:	0f b6 10             	movzbl (%eax),%edx
  8008b2:	84 d2                	test   %dl,%dl
  8008b4:	74 09                	je     8008bf <strchr+0x1e>
		if (*s == c)
  8008b6:	38 ca                	cmp    %cl,%dl
  8008b8:	74 0a                	je     8008c4 <strchr+0x23>
	for (; *s; s++)
  8008ba:	83 c0 01             	add    $0x1,%eax
  8008bd:	eb f0                	jmp    8008af <strchr+0xe>
			return (char *) s;
	return 0;
  8008bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    

008008c6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c6:	f3 0f 1e fb          	endbr32 
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d7:	38 ca                	cmp    %cl,%dl
  8008d9:	74 09                	je     8008e4 <strfind+0x1e>
  8008db:	84 d2                	test   %dl,%dl
  8008dd:	74 05                	je     8008e4 <strfind+0x1e>
	for (; *s; s++)
  8008df:	83 c0 01             	add    $0x1,%eax
  8008e2:	eb f0                	jmp    8008d4 <strfind+0xe>
			break;
	return (char *) s;
}
  8008e4:	5d                   	pop    %ebp
  8008e5:	c3                   	ret    

008008e6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e6:	f3 0f 1e fb          	endbr32 
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	57                   	push   %edi
  8008ee:	56                   	push   %esi
  8008ef:	53                   	push   %ebx
  8008f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008f6:	85 c9                	test   %ecx,%ecx
  8008f8:	74 31                	je     80092b <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008fa:	89 f8                	mov    %edi,%eax
  8008fc:	09 c8                	or     %ecx,%eax
  8008fe:	a8 03                	test   $0x3,%al
  800900:	75 23                	jne    800925 <memset+0x3f>
		c &= 0xFF;
  800902:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800906:	89 d3                	mov    %edx,%ebx
  800908:	c1 e3 08             	shl    $0x8,%ebx
  80090b:	89 d0                	mov    %edx,%eax
  80090d:	c1 e0 18             	shl    $0x18,%eax
  800910:	89 d6                	mov    %edx,%esi
  800912:	c1 e6 10             	shl    $0x10,%esi
  800915:	09 f0                	or     %esi,%eax
  800917:	09 c2                	or     %eax,%edx
  800919:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80091b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80091e:	89 d0                	mov    %edx,%eax
  800920:	fc                   	cld    
  800921:	f3 ab                	rep stos %eax,%es:(%edi)
  800923:	eb 06                	jmp    80092b <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800925:	8b 45 0c             	mov    0xc(%ebp),%eax
  800928:	fc                   	cld    
  800929:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80092b:	89 f8                	mov    %edi,%eax
  80092d:	5b                   	pop    %ebx
  80092e:	5e                   	pop    %esi
  80092f:	5f                   	pop    %edi
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800932:	f3 0f 1e fb          	endbr32 
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	57                   	push   %edi
  80093a:	56                   	push   %esi
  80093b:	8b 45 08             	mov    0x8(%ebp),%eax
  80093e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800941:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800944:	39 c6                	cmp    %eax,%esi
  800946:	73 32                	jae    80097a <memmove+0x48>
  800948:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80094b:	39 c2                	cmp    %eax,%edx
  80094d:	76 2b                	jbe    80097a <memmove+0x48>
		s += n;
		d += n;
  80094f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800952:	89 fe                	mov    %edi,%esi
  800954:	09 ce                	or     %ecx,%esi
  800956:	09 d6                	or     %edx,%esi
  800958:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80095e:	75 0e                	jne    80096e <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800960:	83 ef 04             	sub    $0x4,%edi
  800963:	8d 72 fc             	lea    -0x4(%edx),%esi
  800966:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800969:	fd                   	std    
  80096a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096c:	eb 09                	jmp    800977 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80096e:	83 ef 01             	sub    $0x1,%edi
  800971:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800974:	fd                   	std    
  800975:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800977:	fc                   	cld    
  800978:	eb 1a                	jmp    800994 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097a:	89 c2                	mov    %eax,%edx
  80097c:	09 ca                	or     %ecx,%edx
  80097e:	09 f2                	or     %esi,%edx
  800980:	f6 c2 03             	test   $0x3,%dl
  800983:	75 0a                	jne    80098f <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800985:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800988:	89 c7                	mov    %eax,%edi
  80098a:	fc                   	cld    
  80098b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098d:	eb 05                	jmp    800994 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  80098f:	89 c7                	mov    %eax,%edi
  800991:	fc                   	cld    
  800992:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800994:	5e                   	pop    %esi
  800995:	5f                   	pop    %edi
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    

00800998 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800998:	f3 0f 1e fb          	endbr32 
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009a2:	ff 75 10             	pushl  0x10(%ebp)
  8009a5:	ff 75 0c             	pushl  0xc(%ebp)
  8009a8:	ff 75 08             	pushl  0x8(%ebp)
  8009ab:	e8 82 ff ff ff       	call   800932 <memmove>
}
  8009b0:	c9                   	leave  
  8009b1:	c3                   	ret    

008009b2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b2:	f3 0f 1e fb          	endbr32 
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	56                   	push   %esi
  8009ba:	53                   	push   %ebx
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c1:	89 c6                	mov    %eax,%esi
  8009c3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c6:	39 f0                	cmp    %esi,%eax
  8009c8:	74 1c                	je     8009e6 <memcmp+0x34>
		if (*s1 != *s2)
  8009ca:	0f b6 08             	movzbl (%eax),%ecx
  8009cd:	0f b6 1a             	movzbl (%edx),%ebx
  8009d0:	38 d9                	cmp    %bl,%cl
  8009d2:	75 08                	jne    8009dc <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009d4:	83 c0 01             	add    $0x1,%eax
  8009d7:	83 c2 01             	add    $0x1,%edx
  8009da:	eb ea                	jmp    8009c6 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  8009dc:	0f b6 c1             	movzbl %cl,%eax
  8009df:	0f b6 db             	movzbl %bl,%ebx
  8009e2:	29 d8                	sub    %ebx,%eax
  8009e4:	eb 05                	jmp    8009eb <memcmp+0x39>
	}

	return 0;
  8009e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009eb:	5b                   	pop    %ebx
  8009ec:	5e                   	pop    %esi
  8009ed:	5d                   	pop    %ebp
  8009ee:	c3                   	ret    

008009ef <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ef:	f3 0f 1e fb          	endbr32 
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009fc:	89 c2                	mov    %eax,%edx
  8009fe:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a01:	39 d0                	cmp    %edx,%eax
  800a03:	73 09                	jae    800a0e <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a05:	38 08                	cmp    %cl,(%eax)
  800a07:	74 05                	je     800a0e <memfind+0x1f>
	for (; s < ends; s++)
  800a09:	83 c0 01             	add    $0x1,%eax
  800a0c:	eb f3                	jmp    800a01 <memfind+0x12>
			break;
	return (void *) s;
}
  800a0e:	5d                   	pop    %ebp
  800a0f:	c3                   	ret    

00800a10 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a10:	f3 0f 1e fb          	endbr32 
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	57                   	push   %edi
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
  800a1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a20:	eb 03                	jmp    800a25 <strtol+0x15>
		s++;
  800a22:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a25:	0f b6 01             	movzbl (%ecx),%eax
  800a28:	3c 20                	cmp    $0x20,%al
  800a2a:	74 f6                	je     800a22 <strtol+0x12>
  800a2c:	3c 09                	cmp    $0x9,%al
  800a2e:	74 f2                	je     800a22 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a30:	3c 2b                	cmp    $0x2b,%al
  800a32:	74 2a                	je     800a5e <strtol+0x4e>
	int neg = 0;
  800a34:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a39:	3c 2d                	cmp    $0x2d,%al
  800a3b:	74 2b                	je     800a68 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a43:	75 0f                	jne    800a54 <strtol+0x44>
  800a45:	80 39 30             	cmpb   $0x30,(%ecx)
  800a48:	74 28                	je     800a72 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a4a:	85 db                	test   %ebx,%ebx
  800a4c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a51:	0f 44 d8             	cmove  %eax,%ebx
  800a54:	b8 00 00 00 00       	mov    $0x0,%eax
  800a59:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a5c:	eb 46                	jmp    800aa4 <strtol+0x94>
		s++;
  800a5e:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a61:	bf 00 00 00 00       	mov    $0x0,%edi
  800a66:	eb d5                	jmp    800a3d <strtol+0x2d>
		s++, neg = 1;
  800a68:	83 c1 01             	add    $0x1,%ecx
  800a6b:	bf 01 00 00 00       	mov    $0x1,%edi
  800a70:	eb cb                	jmp    800a3d <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a72:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a76:	74 0e                	je     800a86 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a78:	85 db                	test   %ebx,%ebx
  800a7a:	75 d8                	jne    800a54 <strtol+0x44>
		s++, base = 8;
  800a7c:	83 c1 01             	add    $0x1,%ecx
  800a7f:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a84:	eb ce                	jmp    800a54 <strtol+0x44>
		s += 2, base = 16;
  800a86:	83 c1 02             	add    $0x2,%ecx
  800a89:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a8e:	eb c4                	jmp    800a54 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a90:	0f be d2             	movsbl %dl,%edx
  800a93:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a96:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a99:	7d 3a                	jge    800ad5 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a9b:	83 c1 01             	add    $0x1,%ecx
  800a9e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aa2:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800aa4:	0f b6 11             	movzbl (%ecx),%edx
  800aa7:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aaa:	89 f3                	mov    %esi,%ebx
  800aac:	80 fb 09             	cmp    $0x9,%bl
  800aaf:	76 df                	jbe    800a90 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800ab1:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab4:	89 f3                	mov    %esi,%ebx
  800ab6:	80 fb 19             	cmp    $0x19,%bl
  800ab9:	77 08                	ja     800ac3 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800abb:	0f be d2             	movsbl %dl,%edx
  800abe:	83 ea 57             	sub    $0x57,%edx
  800ac1:	eb d3                	jmp    800a96 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800ac3:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac6:	89 f3                	mov    %esi,%ebx
  800ac8:	80 fb 19             	cmp    $0x19,%bl
  800acb:	77 08                	ja     800ad5 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800acd:	0f be d2             	movsbl %dl,%edx
  800ad0:	83 ea 37             	sub    $0x37,%edx
  800ad3:	eb c1                	jmp    800a96 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ad5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad9:	74 05                	je     800ae0 <strtol+0xd0>
		*endptr = (char *) s;
  800adb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ade:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ae0:	89 c2                	mov    %eax,%edx
  800ae2:	f7 da                	neg    %edx
  800ae4:	85 ff                	test   %edi,%edi
  800ae6:	0f 45 c2             	cmovne %edx,%eax
}
  800ae9:	5b                   	pop    %ebx
  800aea:	5e                   	pop    %esi
  800aeb:	5f                   	pop    %edi
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aee:	f3 0f 1e fb          	endbr32 
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	57                   	push   %edi
  800af6:	56                   	push   %esi
  800af7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800af8:	b8 00 00 00 00       	mov    $0x0,%eax
  800afd:	8b 55 08             	mov    0x8(%ebp),%edx
  800b00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b03:	89 c3                	mov    %eax,%ebx
  800b05:	89 c7                	mov    %eax,%edi
  800b07:	89 c6                	mov    %eax,%esi
  800b09:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b0b:	5b                   	pop    %ebx
  800b0c:	5e                   	pop    %esi
  800b0d:	5f                   	pop    %edi
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    

00800b10 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b10:	f3 0f 1e fb          	endbr32 
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	57                   	push   %edi
  800b18:	56                   	push   %esi
  800b19:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b24:	89 d1                	mov    %edx,%ecx
  800b26:	89 d3                	mov    %edx,%ebx
  800b28:	89 d7                	mov    %edx,%edi
  800b2a:	89 d6                	mov    %edx,%esi
  800b2c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b2e:	5b                   	pop    %ebx
  800b2f:	5e                   	pop    %esi
  800b30:	5f                   	pop    %edi
  800b31:	5d                   	pop    %ebp
  800b32:	c3                   	ret    

00800b33 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b33:	f3 0f 1e fb          	endbr32 
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	57                   	push   %edi
  800b3b:	56                   	push   %esi
  800b3c:	53                   	push   %ebx
  800b3d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b40:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b45:	8b 55 08             	mov    0x8(%ebp),%edx
  800b48:	b8 03 00 00 00       	mov    $0x3,%eax
  800b4d:	89 cb                	mov    %ecx,%ebx
  800b4f:	89 cf                	mov    %ecx,%edi
  800b51:	89 ce                	mov    %ecx,%esi
  800b53:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b55:	85 c0                	test   %eax,%eax
  800b57:	7f 08                	jg     800b61 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5c:	5b                   	pop    %ebx
  800b5d:	5e                   	pop    %esi
  800b5e:	5f                   	pop    %edi
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b61:	83 ec 0c             	sub    $0xc,%esp
  800b64:	50                   	push   %eax
  800b65:	6a 03                	push   $0x3
  800b67:	68 ff 21 80 00       	push   $0x8021ff
  800b6c:	6a 23                	push   $0x23
  800b6e:	68 1c 22 80 00       	push   $0x80221c
  800b73:	e8 70 0f 00 00       	call   801ae8 <_panic>

00800b78 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b78:	f3 0f 1e fb          	endbr32 
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	57                   	push   %edi
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b82:	ba 00 00 00 00       	mov    $0x0,%edx
  800b87:	b8 02 00 00 00       	mov    $0x2,%eax
  800b8c:	89 d1                	mov    %edx,%ecx
  800b8e:	89 d3                	mov    %edx,%ebx
  800b90:	89 d7                	mov    %edx,%edi
  800b92:	89 d6                	mov    %edx,%esi
  800b94:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <sys_yield>:

void
sys_yield(void)
{
  800b9b:	f3 0f 1e fb          	endbr32 
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	57                   	push   %edi
  800ba3:	56                   	push   %esi
  800ba4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ba5:	ba 00 00 00 00       	mov    $0x0,%edx
  800baa:	b8 0b 00 00 00       	mov    $0xb,%eax
  800baf:	89 d1                	mov    %edx,%ecx
  800bb1:	89 d3                	mov    %edx,%ebx
  800bb3:	89 d7                	mov    %edx,%edi
  800bb5:	89 d6                	mov    %edx,%esi
  800bb7:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bbe:	f3 0f 1e fb          	endbr32 
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
  800bc8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bcb:	be 00 00 00 00       	mov    $0x0,%esi
  800bd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd6:	b8 04 00 00 00       	mov    $0x4,%eax
  800bdb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bde:	89 f7                	mov    %esi,%edi
  800be0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800be2:	85 c0                	test   %eax,%eax
  800be4:	7f 08                	jg     800bee <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800be6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be9:	5b                   	pop    %ebx
  800bea:	5e                   	pop    %esi
  800beb:	5f                   	pop    %edi
  800bec:	5d                   	pop    %ebp
  800bed:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bee:	83 ec 0c             	sub    $0xc,%esp
  800bf1:	50                   	push   %eax
  800bf2:	6a 04                	push   $0x4
  800bf4:	68 ff 21 80 00       	push   $0x8021ff
  800bf9:	6a 23                	push   $0x23
  800bfb:	68 1c 22 80 00       	push   $0x80221c
  800c00:	e8 e3 0e 00 00       	call   801ae8 <_panic>

00800c05 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c05:	f3 0f 1e fb          	endbr32 
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	57                   	push   %edi
  800c0d:	56                   	push   %esi
  800c0e:	53                   	push   %ebx
  800c0f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c12:	8b 55 08             	mov    0x8(%ebp),%edx
  800c15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c18:	b8 05 00 00 00       	mov    $0x5,%eax
  800c1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c20:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c23:	8b 75 18             	mov    0x18(%ebp),%esi
  800c26:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c28:	85 c0                	test   %eax,%eax
  800c2a:	7f 08                	jg     800c34 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2f:	5b                   	pop    %ebx
  800c30:	5e                   	pop    %esi
  800c31:	5f                   	pop    %edi
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c34:	83 ec 0c             	sub    $0xc,%esp
  800c37:	50                   	push   %eax
  800c38:	6a 05                	push   $0x5
  800c3a:	68 ff 21 80 00       	push   $0x8021ff
  800c3f:	6a 23                	push   $0x23
  800c41:	68 1c 22 80 00       	push   $0x80221c
  800c46:	e8 9d 0e 00 00       	call   801ae8 <_panic>

00800c4b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c4b:	f3 0f 1e fb          	endbr32 
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	57                   	push   %edi
  800c53:	56                   	push   %esi
  800c54:	53                   	push   %ebx
  800c55:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c58:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c63:	b8 06 00 00 00       	mov    $0x6,%eax
  800c68:	89 df                	mov    %ebx,%edi
  800c6a:	89 de                	mov    %ebx,%esi
  800c6c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c6e:	85 c0                	test   %eax,%eax
  800c70:	7f 08                	jg     800c7a <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7a:	83 ec 0c             	sub    $0xc,%esp
  800c7d:	50                   	push   %eax
  800c7e:	6a 06                	push   $0x6
  800c80:	68 ff 21 80 00       	push   $0x8021ff
  800c85:	6a 23                	push   $0x23
  800c87:	68 1c 22 80 00       	push   $0x80221c
  800c8c:	e8 57 0e 00 00       	call   801ae8 <_panic>

00800c91 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c91:	f3 0f 1e fb          	endbr32 
  800c95:	55                   	push   %ebp
  800c96:	89 e5                	mov    %esp,%ebp
  800c98:	57                   	push   %edi
  800c99:	56                   	push   %esi
  800c9a:	53                   	push   %ebx
  800c9b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c9e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca9:	b8 08 00 00 00       	mov    $0x8,%eax
  800cae:	89 df                	mov    %ebx,%edi
  800cb0:	89 de                	mov    %ebx,%esi
  800cb2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb4:	85 c0                	test   %eax,%eax
  800cb6:	7f 08                	jg     800cc0 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbb:	5b                   	pop    %ebx
  800cbc:	5e                   	pop    %esi
  800cbd:	5f                   	pop    %edi
  800cbe:	5d                   	pop    %ebp
  800cbf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc0:	83 ec 0c             	sub    $0xc,%esp
  800cc3:	50                   	push   %eax
  800cc4:	6a 08                	push   $0x8
  800cc6:	68 ff 21 80 00       	push   $0x8021ff
  800ccb:	6a 23                	push   $0x23
  800ccd:	68 1c 22 80 00       	push   $0x80221c
  800cd2:	e8 11 0e 00 00       	call   801ae8 <_panic>

00800cd7 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cd7:	f3 0f 1e fb          	endbr32 
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	57                   	push   %edi
  800cdf:	56                   	push   %esi
  800ce0:	53                   	push   %ebx
  800ce1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ce4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cef:	b8 09 00 00 00       	mov    $0x9,%eax
  800cf4:	89 df                	mov    %ebx,%edi
  800cf6:	89 de                	mov    %ebx,%esi
  800cf8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cfa:	85 c0                	test   %eax,%eax
  800cfc:	7f 08                	jg     800d06 <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d06:	83 ec 0c             	sub    $0xc,%esp
  800d09:	50                   	push   %eax
  800d0a:	6a 09                	push   $0x9
  800d0c:	68 ff 21 80 00       	push   $0x8021ff
  800d11:	6a 23                	push   $0x23
  800d13:	68 1c 22 80 00       	push   $0x80221c
  800d18:	e8 cb 0d 00 00       	call   801ae8 <_panic>

00800d1d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d1d:	f3 0f 1e fb          	endbr32 
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	57                   	push   %edi
  800d25:	56                   	push   %esi
  800d26:	53                   	push   %ebx
  800d27:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d2a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d35:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d3a:	89 df                	mov    %ebx,%edi
  800d3c:	89 de                	mov    %ebx,%esi
  800d3e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d40:	85 c0                	test   %eax,%eax
  800d42:	7f 08                	jg     800d4c <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4c:	83 ec 0c             	sub    $0xc,%esp
  800d4f:	50                   	push   %eax
  800d50:	6a 0a                	push   $0xa
  800d52:	68 ff 21 80 00       	push   $0x8021ff
  800d57:	6a 23                	push   $0x23
  800d59:	68 1c 22 80 00       	push   $0x80221c
  800d5e:	e8 85 0d 00 00       	call   801ae8 <_panic>

00800d63 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d63:	f3 0f 1e fb          	endbr32 
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	57                   	push   %edi
  800d6b:	56                   	push   %esi
  800d6c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d73:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d78:	be 00 00 00 00       	mov    $0x0,%esi
  800d7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d80:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d83:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d85:	5b                   	pop    %ebx
  800d86:	5e                   	pop    %esi
  800d87:	5f                   	pop    %edi
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d8a:	f3 0f 1e fb          	endbr32 
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	57                   	push   %edi
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
  800d94:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d97:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800da4:	89 cb                	mov    %ecx,%ebx
  800da6:	89 cf                	mov    %ecx,%edi
  800da8:	89 ce                	mov    %ecx,%esi
  800daa:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dac:	85 c0                	test   %eax,%eax
  800dae:	7f 08                	jg     800db8 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800db0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db3:	5b                   	pop    %ebx
  800db4:	5e                   	pop    %esi
  800db5:	5f                   	pop    %edi
  800db6:	5d                   	pop    %ebp
  800db7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800db8:	83 ec 0c             	sub    $0xc,%esp
  800dbb:	50                   	push   %eax
  800dbc:	6a 0d                	push   $0xd
  800dbe:	68 ff 21 80 00       	push   $0x8021ff
  800dc3:	6a 23                	push   $0x23
  800dc5:	68 1c 22 80 00       	push   $0x80221c
  800dca:	e8 19 0d 00 00       	call   801ae8 <_panic>

00800dcf <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dcf:	f3 0f 1e fb          	endbr32 
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dd6:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd9:	05 00 00 00 30       	add    $0x30000000,%eax
  800dde:	c1 e8 0c             	shr    $0xc,%eax
}
  800de1:	5d                   	pop    %ebp
  800de2:	c3                   	ret    

00800de3 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800de3:	f3 0f 1e fb          	endbr32 
  800de7:	55                   	push   %ebp
  800de8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dea:	8b 45 08             	mov    0x8(%ebp),%eax
  800ded:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800df2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800df7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800dfc:	5d                   	pop    %ebp
  800dfd:	c3                   	ret    

00800dfe <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dfe:	f3 0f 1e fb          	endbr32 
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e0a:	89 c2                	mov    %eax,%edx
  800e0c:	c1 ea 16             	shr    $0x16,%edx
  800e0f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e16:	f6 c2 01             	test   $0x1,%dl
  800e19:	74 2d                	je     800e48 <fd_alloc+0x4a>
  800e1b:	89 c2                	mov    %eax,%edx
  800e1d:	c1 ea 0c             	shr    $0xc,%edx
  800e20:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e27:	f6 c2 01             	test   $0x1,%dl
  800e2a:	74 1c                	je     800e48 <fd_alloc+0x4a>
  800e2c:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800e31:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e36:	75 d2                	jne    800e0a <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e38:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800e41:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800e46:	eb 0a                	jmp    800e52 <fd_alloc+0x54>
			*fd_store = fd;
  800e48:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4b:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e52:	5d                   	pop    %ebp
  800e53:	c3                   	ret    

00800e54 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e54:	f3 0f 1e fb          	endbr32 
  800e58:	55                   	push   %ebp
  800e59:	89 e5                	mov    %esp,%ebp
  800e5b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e5e:	83 f8 1f             	cmp    $0x1f,%eax
  800e61:	77 30                	ja     800e93 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e63:	c1 e0 0c             	shl    $0xc,%eax
  800e66:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e6b:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800e71:	f6 c2 01             	test   $0x1,%dl
  800e74:	74 24                	je     800e9a <fd_lookup+0x46>
  800e76:	89 c2                	mov    %eax,%edx
  800e78:	c1 ea 0c             	shr    $0xc,%edx
  800e7b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e82:	f6 c2 01             	test   $0x1,%dl
  800e85:	74 1a                	je     800ea1 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e87:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e8a:	89 02                	mov    %eax,(%edx)
	return 0;
  800e8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e91:	5d                   	pop    %ebp
  800e92:	c3                   	ret    
		return -E_INVAL;
  800e93:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e98:	eb f7                	jmp    800e91 <fd_lookup+0x3d>
		return -E_INVAL;
  800e9a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e9f:	eb f0                	jmp    800e91 <fd_lookup+0x3d>
  800ea1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ea6:	eb e9                	jmp    800e91 <fd_lookup+0x3d>

00800ea8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ea8:	f3 0f 1e fb          	endbr32 
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	83 ec 08             	sub    $0x8,%esp
  800eb2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eb5:	ba a8 22 80 00       	mov    $0x8022a8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800eba:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800ebf:	39 08                	cmp    %ecx,(%eax)
  800ec1:	74 33                	je     800ef6 <dev_lookup+0x4e>
  800ec3:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800ec6:	8b 02                	mov    (%edx),%eax
  800ec8:	85 c0                	test   %eax,%eax
  800eca:	75 f3                	jne    800ebf <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ecc:	a1 08 40 80 00       	mov    0x804008,%eax
  800ed1:	8b 40 48             	mov    0x48(%eax),%eax
  800ed4:	83 ec 04             	sub    $0x4,%esp
  800ed7:	51                   	push   %ecx
  800ed8:	50                   	push   %eax
  800ed9:	68 2c 22 80 00       	push   $0x80222c
  800ede:	e8 90 f2 ff ff       	call   800173 <cprintf>
	*dev = 0;
  800ee3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800eec:	83 c4 10             	add    $0x10,%esp
  800eef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ef4:	c9                   	leave  
  800ef5:	c3                   	ret    
			*dev = devtab[i];
  800ef6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef9:	89 01                	mov    %eax,(%ecx)
			return 0;
  800efb:	b8 00 00 00 00       	mov    $0x0,%eax
  800f00:	eb f2                	jmp    800ef4 <dev_lookup+0x4c>

00800f02 <fd_close>:
{
  800f02:	f3 0f 1e fb          	endbr32 
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	57                   	push   %edi
  800f0a:	56                   	push   %esi
  800f0b:	53                   	push   %ebx
  800f0c:	83 ec 24             	sub    $0x24,%esp
  800f0f:	8b 75 08             	mov    0x8(%ebp),%esi
  800f12:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f15:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f18:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f19:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f1f:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f22:	50                   	push   %eax
  800f23:	e8 2c ff ff ff       	call   800e54 <fd_lookup>
  800f28:	89 c3                	mov    %eax,%ebx
  800f2a:	83 c4 10             	add    $0x10,%esp
  800f2d:	85 c0                	test   %eax,%eax
  800f2f:	78 05                	js     800f36 <fd_close+0x34>
	    || fd != fd2)
  800f31:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800f34:	74 16                	je     800f4c <fd_close+0x4a>
		return (must_exist ? r : 0);
  800f36:	89 f8                	mov    %edi,%eax
  800f38:	84 c0                	test   %al,%al
  800f3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3f:	0f 44 d8             	cmove  %eax,%ebx
}
  800f42:	89 d8                	mov    %ebx,%eax
  800f44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f47:	5b                   	pop    %ebx
  800f48:	5e                   	pop    %esi
  800f49:	5f                   	pop    %edi
  800f4a:	5d                   	pop    %ebp
  800f4b:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f4c:	83 ec 08             	sub    $0x8,%esp
  800f4f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f52:	50                   	push   %eax
  800f53:	ff 36                	pushl  (%esi)
  800f55:	e8 4e ff ff ff       	call   800ea8 <dev_lookup>
  800f5a:	89 c3                	mov    %eax,%ebx
  800f5c:	83 c4 10             	add    $0x10,%esp
  800f5f:	85 c0                	test   %eax,%eax
  800f61:	78 1a                	js     800f7d <fd_close+0x7b>
		if (dev->dev_close)
  800f63:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f66:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800f69:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	74 0b                	je     800f7d <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800f72:	83 ec 0c             	sub    $0xc,%esp
  800f75:	56                   	push   %esi
  800f76:	ff d0                	call   *%eax
  800f78:	89 c3                	mov    %eax,%ebx
  800f7a:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f7d:	83 ec 08             	sub    $0x8,%esp
  800f80:	56                   	push   %esi
  800f81:	6a 00                	push   $0x0
  800f83:	e8 c3 fc ff ff       	call   800c4b <sys_page_unmap>
	return r;
  800f88:	83 c4 10             	add    $0x10,%esp
  800f8b:	eb b5                	jmp    800f42 <fd_close+0x40>

00800f8d <close>:

int
close(int fdnum)
{
  800f8d:	f3 0f 1e fb          	endbr32 
  800f91:	55                   	push   %ebp
  800f92:	89 e5                	mov    %esp,%ebp
  800f94:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f97:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f9a:	50                   	push   %eax
  800f9b:	ff 75 08             	pushl  0x8(%ebp)
  800f9e:	e8 b1 fe ff ff       	call   800e54 <fd_lookup>
  800fa3:	83 c4 10             	add    $0x10,%esp
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	79 02                	jns    800fac <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  800faa:	c9                   	leave  
  800fab:	c3                   	ret    
		return fd_close(fd, 1);
  800fac:	83 ec 08             	sub    $0x8,%esp
  800faf:	6a 01                	push   $0x1
  800fb1:	ff 75 f4             	pushl  -0xc(%ebp)
  800fb4:	e8 49 ff ff ff       	call   800f02 <fd_close>
  800fb9:	83 c4 10             	add    $0x10,%esp
  800fbc:	eb ec                	jmp    800faa <close+0x1d>

00800fbe <close_all>:

void
close_all(void)
{
  800fbe:	f3 0f 1e fb          	endbr32 
  800fc2:	55                   	push   %ebp
  800fc3:	89 e5                	mov    %esp,%ebp
  800fc5:	53                   	push   %ebx
  800fc6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fc9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fce:	83 ec 0c             	sub    $0xc,%esp
  800fd1:	53                   	push   %ebx
  800fd2:	e8 b6 ff ff ff       	call   800f8d <close>
	for (i = 0; i < MAXFD; i++)
  800fd7:	83 c3 01             	add    $0x1,%ebx
  800fda:	83 c4 10             	add    $0x10,%esp
  800fdd:	83 fb 20             	cmp    $0x20,%ebx
  800fe0:	75 ec                	jne    800fce <close_all+0x10>
}
  800fe2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fe5:	c9                   	leave  
  800fe6:	c3                   	ret    

00800fe7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fe7:	f3 0f 1e fb          	endbr32 
  800feb:	55                   	push   %ebp
  800fec:	89 e5                	mov    %esp,%ebp
  800fee:	57                   	push   %edi
  800fef:	56                   	push   %esi
  800ff0:	53                   	push   %ebx
  800ff1:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ff4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ff7:	50                   	push   %eax
  800ff8:	ff 75 08             	pushl  0x8(%ebp)
  800ffb:	e8 54 fe ff ff       	call   800e54 <fd_lookup>
  801000:	89 c3                	mov    %eax,%ebx
  801002:	83 c4 10             	add    $0x10,%esp
  801005:	85 c0                	test   %eax,%eax
  801007:	0f 88 81 00 00 00    	js     80108e <dup+0xa7>
		return r;
	close(newfdnum);
  80100d:	83 ec 0c             	sub    $0xc,%esp
  801010:	ff 75 0c             	pushl  0xc(%ebp)
  801013:	e8 75 ff ff ff       	call   800f8d <close>

	newfd = INDEX2FD(newfdnum);
  801018:	8b 75 0c             	mov    0xc(%ebp),%esi
  80101b:	c1 e6 0c             	shl    $0xc,%esi
  80101e:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801024:	83 c4 04             	add    $0x4,%esp
  801027:	ff 75 e4             	pushl  -0x1c(%ebp)
  80102a:	e8 b4 fd ff ff       	call   800de3 <fd2data>
  80102f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801031:	89 34 24             	mov    %esi,(%esp)
  801034:	e8 aa fd ff ff       	call   800de3 <fd2data>
  801039:	83 c4 10             	add    $0x10,%esp
  80103c:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80103e:	89 d8                	mov    %ebx,%eax
  801040:	c1 e8 16             	shr    $0x16,%eax
  801043:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80104a:	a8 01                	test   $0x1,%al
  80104c:	74 11                	je     80105f <dup+0x78>
  80104e:	89 d8                	mov    %ebx,%eax
  801050:	c1 e8 0c             	shr    $0xc,%eax
  801053:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80105a:	f6 c2 01             	test   $0x1,%dl
  80105d:	75 39                	jne    801098 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80105f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801062:	89 d0                	mov    %edx,%eax
  801064:	c1 e8 0c             	shr    $0xc,%eax
  801067:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80106e:	83 ec 0c             	sub    $0xc,%esp
  801071:	25 07 0e 00 00       	and    $0xe07,%eax
  801076:	50                   	push   %eax
  801077:	56                   	push   %esi
  801078:	6a 00                	push   $0x0
  80107a:	52                   	push   %edx
  80107b:	6a 00                	push   $0x0
  80107d:	e8 83 fb ff ff       	call   800c05 <sys_page_map>
  801082:	89 c3                	mov    %eax,%ebx
  801084:	83 c4 20             	add    $0x20,%esp
  801087:	85 c0                	test   %eax,%eax
  801089:	78 31                	js     8010bc <dup+0xd5>
		goto err;

	return newfdnum;
  80108b:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80108e:	89 d8                	mov    %ebx,%eax
  801090:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801093:	5b                   	pop    %ebx
  801094:	5e                   	pop    %esi
  801095:	5f                   	pop    %edi
  801096:	5d                   	pop    %ebp
  801097:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801098:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80109f:	83 ec 0c             	sub    $0xc,%esp
  8010a2:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a7:	50                   	push   %eax
  8010a8:	57                   	push   %edi
  8010a9:	6a 00                	push   $0x0
  8010ab:	53                   	push   %ebx
  8010ac:	6a 00                	push   $0x0
  8010ae:	e8 52 fb ff ff       	call   800c05 <sys_page_map>
  8010b3:	89 c3                	mov    %eax,%ebx
  8010b5:	83 c4 20             	add    $0x20,%esp
  8010b8:	85 c0                	test   %eax,%eax
  8010ba:	79 a3                	jns    80105f <dup+0x78>
	sys_page_unmap(0, newfd);
  8010bc:	83 ec 08             	sub    $0x8,%esp
  8010bf:	56                   	push   %esi
  8010c0:	6a 00                	push   $0x0
  8010c2:	e8 84 fb ff ff       	call   800c4b <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010c7:	83 c4 08             	add    $0x8,%esp
  8010ca:	57                   	push   %edi
  8010cb:	6a 00                	push   $0x0
  8010cd:	e8 79 fb ff ff       	call   800c4b <sys_page_unmap>
	return r;
  8010d2:	83 c4 10             	add    $0x10,%esp
  8010d5:	eb b7                	jmp    80108e <dup+0xa7>

008010d7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010d7:	f3 0f 1e fb          	endbr32 
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	53                   	push   %ebx
  8010df:	83 ec 1c             	sub    $0x1c,%esp
  8010e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010e8:	50                   	push   %eax
  8010e9:	53                   	push   %ebx
  8010ea:	e8 65 fd ff ff       	call   800e54 <fd_lookup>
  8010ef:	83 c4 10             	add    $0x10,%esp
  8010f2:	85 c0                	test   %eax,%eax
  8010f4:	78 3f                	js     801135 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010f6:	83 ec 08             	sub    $0x8,%esp
  8010f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010fc:	50                   	push   %eax
  8010fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801100:	ff 30                	pushl  (%eax)
  801102:	e8 a1 fd ff ff       	call   800ea8 <dev_lookup>
  801107:	83 c4 10             	add    $0x10,%esp
  80110a:	85 c0                	test   %eax,%eax
  80110c:	78 27                	js     801135 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80110e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801111:	8b 42 08             	mov    0x8(%edx),%eax
  801114:	83 e0 03             	and    $0x3,%eax
  801117:	83 f8 01             	cmp    $0x1,%eax
  80111a:	74 1e                	je     80113a <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80111c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80111f:	8b 40 08             	mov    0x8(%eax),%eax
  801122:	85 c0                	test   %eax,%eax
  801124:	74 35                	je     80115b <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801126:	83 ec 04             	sub    $0x4,%esp
  801129:	ff 75 10             	pushl  0x10(%ebp)
  80112c:	ff 75 0c             	pushl  0xc(%ebp)
  80112f:	52                   	push   %edx
  801130:	ff d0                	call   *%eax
  801132:	83 c4 10             	add    $0x10,%esp
}
  801135:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801138:	c9                   	leave  
  801139:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80113a:	a1 08 40 80 00       	mov    0x804008,%eax
  80113f:	8b 40 48             	mov    0x48(%eax),%eax
  801142:	83 ec 04             	sub    $0x4,%esp
  801145:	53                   	push   %ebx
  801146:	50                   	push   %eax
  801147:	68 6d 22 80 00       	push   $0x80226d
  80114c:	e8 22 f0 ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  801151:	83 c4 10             	add    $0x10,%esp
  801154:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801159:	eb da                	jmp    801135 <read+0x5e>
		return -E_NOT_SUPP;
  80115b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801160:	eb d3                	jmp    801135 <read+0x5e>

00801162 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801162:	f3 0f 1e fb          	endbr32 
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	57                   	push   %edi
  80116a:	56                   	push   %esi
  80116b:	53                   	push   %ebx
  80116c:	83 ec 0c             	sub    $0xc,%esp
  80116f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801172:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801175:	bb 00 00 00 00       	mov    $0x0,%ebx
  80117a:	eb 02                	jmp    80117e <readn+0x1c>
  80117c:	01 c3                	add    %eax,%ebx
  80117e:	39 f3                	cmp    %esi,%ebx
  801180:	73 21                	jae    8011a3 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801182:	83 ec 04             	sub    $0x4,%esp
  801185:	89 f0                	mov    %esi,%eax
  801187:	29 d8                	sub    %ebx,%eax
  801189:	50                   	push   %eax
  80118a:	89 d8                	mov    %ebx,%eax
  80118c:	03 45 0c             	add    0xc(%ebp),%eax
  80118f:	50                   	push   %eax
  801190:	57                   	push   %edi
  801191:	e8 41 ff ff ff       	call   8010d7 <read>
		if (m < 0)
  801196:	83 c4 10             	add    $0x10,%esp
  801199:	85 c0                	test   %eax,%eax
  80119b:	78 04                	js     8011a1 <readn+0x3f>
			return m;
		if (m == 0)
  80119d:	75 dd                	jne    80117c <readn+0x1a>
  80119f:	eb 02                	jmp    8011a3 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011a1:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8011a3:	89 d8                	mov    %ebx,%eax
  8011a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a8:	5b                   	pop    %ebx
  8011a9:	5e                   	pop    %esi
  8011aa:	5f                   	pop    %edi
  8011ab:	5d                   	pop    %ebp
  8011ac:	c3                   	ret    

008011ad <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011ad:	f3 0f 1e fb          	endbr32 
  8011b1:	55                   	push   %ebp
  8011b2:	89 e5                	mov    %esp,%ebp
  8011b4:	53                   	push   %ebx
  8011b5:	83 ec 1c             	sub    $0x1c,%esp
  8011b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011be:	50                   	push   %eax
  8011bf:	53                   	push   %ebx
  8011c0:	e8 8f fc ff ff       	call   800e54 <fd_lookup>
  8011c5:	83 c4 10             	add    $0x10,%esp
  8011c8:	85 c0                	test   %eax,%eax
  8011ca:	78 3a                	js     801206 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011cc:	83 ec 08             	sub    $0x8,%esp
  8011cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d2:	50                   	push   %eax
  8011d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d6:	ff 30                	pushl  (%eax)
  8011d8:	e8 cb fc ff ff       	call   800ea8 <dev_lookup>
  8011dd:	83 c4 10             	add    $0x10,%esp
  8011e0:	85 c0                	test   %eax,%eax
  8011e2:	78 22                	js     801206 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011eb:	74 1e                	je     80120b <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011f0:	8b 52 0c             	mov    0xc(%edx),%edx
  8011f3:	85 d2                	test   %edx,%edx
  8011f5:	74 35                	je     80122c <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011f7:	83 ec 04             	sub    $0x4,%esp
  8011fa:	ff 75 10             	pushl  0x10(%ebp)
  8011fd:	ff 75 0c             	pushl  0xc(%ebp)
  801200:	50                   	push   %eax
  801201:	ff d2                	call   *%edx
  801203:	83 c4 10             	add    $0x10,%esp
}
  801206:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801209:	c9                   	leave  
  80120a:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80120b:	a1 08 40 80 00       	mov    0x804008,%eax
  801210:	8b 40 48             	mov    0x48(%eax),%eax
  801213:	83 ec 04             	sub    $0x4,%esp
  801216:	53                   	push   %ebx
  801217:	50                   	push   %eax
  801218:	68 89 22 80 00       	push   $0x802289
  80121d:	e8 51 ef ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  801222:	83 c4 10             	add    $0x10,%esp
  801225:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80122a:	eb da                	jmp    801206 <write+0x59>
		return -E_NOT_SUPP;
  80122c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801231:	eb d3                	jmp    801206 <write+0x59>

00801233 <seek>:

int
seek(int fdnum, off_t offset)
{
  801233:	f3 0f 1e fb          	endbr32 
  801237:	55                   	push   %ebp
  801238:	89 e5                	mov    %esp,%ebp
  80123a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80123d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801240:	50                   	push   %eax
  801241:	ff 75 08             	pushl  0x8(%ebp)
  801244:	e8 0b fc ff ff       	call   800e54 <fd_lookup>
  801249:	83 c4 10             	add    $0x10,%esp
  80124c:	85 c0                	test   %eax,%eax
  80124e:	78 0e                	js     80125e <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801250:	8b 55 0c             	mov    0xc(%ebp),%edx
  801253:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801256:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801259:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80125e:	c9                   	leave  
  80125f:	c3                   	ret    

00801260 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801260:	f3 0f 1e fb          	endbr32 
  801264:	55                   	push   %ebp
  801265:	89 e5                	mov    %esp,%ebp
  801267:	53                   	push   %ebx
  801268:	83 ec 1c             	sub    $0x1c,%esp
  80126b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80126e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801271:	50                   	push   %eax
  801272:	53                   	push   %ebx
  801273:	e8 dc fb ff ff       	call   800e54 <fd_lookup>
  801278:	83 c4 10             	add    $0x10,%esp
  80127b:	85 c0                	test   %eax,%eax
  80127d:	78 37                	js     8012b6 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80127f:	83 ec 08             	sub    $0x8,%esp
  801282:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801285:	50                   	push   %eax
  801286:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801289:	ff 30                	pushl  (%eax)
  80128b:	e8 18 fc ff ff       	call   800ea8 <dev_lookup>
  801290:	83 c4 10             	add    $0x10,%esp
  801293:	85 c0                	test   %eax,%eax
  801295:	78 1f                	js     8012b6 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801297:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80129e:	74 1b                	je     8012bb <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8012a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012a3:	8b 52 18             	mov    0x18(%edx),%edx
  8012a6:	85 d2                	test   %edx,%edx
  8012a8:	74 32                	je     8012dc <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012aa:	83 ec 08             	sub    $0x8,%esp
  8012ad:	ff 75 0c             	pushl  0xc(%ebp)
  8012b0:	50                   	push   %eax
  8012b1:	ff d2                	call   *%edx
  8012b3:	83 c4 10             	add    $0x10,%esp
}
  8012b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b9:	c9                   	leave  
  8012ba:	c3                   	ret    
			thisenv->env_id, fdnum);
  8012bb:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012c0:	8b 40 48             	mov    0x48(%eax),%eax
  8012c3:	83 ec 04             	sub    $0x4,%esp
  8012c6:	53                   	push   %ebx
  8012c7:	50                   	push   %eax
  8012c8:	68 4c 22 80 00       	push   $0x80224c
  8012cd:	e8 a1 ee ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  8012d2:	83 c4 10             	add    $0x10,%esp
  8012d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012da:	eb da                	jmp    8012b6 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8012dc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012e1:	eb d3                	jmp    8012b6 <ftruncate+0x56>

008012e3 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012e3:	f3 0f 1e fb          	endbr32 
  8012e7:	55                   	push   %ebp
  8012e8:	89 e5                	mov    %esp,%ebp
  8012ea:	53                   	push   %ebx
  8012eb:	83 ec 1c             	sub    $0x1c,%esp
  8012ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f4:	50                   	push   %eax
  8012f5:	ff 75 08             	pushl  0x8(%ebp)
  8012f8:	e8 57 fb ff ff       	call   800e54 <fd_lookup>
  8012fd:	83 c4 10             	add    $0x10,%esp
  801300:	85 c0                	test   %eax,%eax
  801302:	78 4b                	js     80134f <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801304:	83 ec 08             	sub    $0x8,%esp
  801307:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130a:	50                   	push   %eax
  80130b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130e:	ff 30                	pushl  (%eax)
  801310:	e8 93 fb ff ff       	call   800ea8 <dev_lookup>
  801315:	83 c4 10             	add    $0x10,%esp
  801318:	85 c0                	test   %eax,%eax
  80131a:	78 33                	js     80134f <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80131c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80131f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801323:	74 2f                	je     801354 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801325:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801328:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80132f:	00 00 00 
	stat->st_isdir = 0;
  801332:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801339:	00 00 00 
	stat->st_dev = dev;
  80133c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801342:	83 ec 08             	sub    $0x8,%esp
  801345:	53                   	push   %ebx
  801346:	ff 75 f0             	pushl  -0x10(%ebp)
  801349:	ff 50 14             	call   *0x14(%eax)
  80134c:	83 c4 10             	add    $0x10,%esp
}
  80134f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801352:	c9                   	leave  
  801353:	c3                   	ret    
		return -E_NOT_SUPP;
  801354:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801359:	eb f4                	jmp    80134f <fstat+0x6c>

0080135b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80135b:	f3 0f 1e fb          	endbr32 
  80135f:	55                   	push   %ebp
  801360:	89 e5                	mov    %esp,%ebp
  801362:	56                   	push   %esi
  801363:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801364:	83 ec 08             	sub    $0x8,%esp
  801367:	6a 00                	push   $0x0
  801369:	ff 75 08             	pushl  0x8(%ebp)
  80136c:	e8 cf 01 00 00       	call   801540 <open>
  801371:	89 c3                	mov    %eax,%ebx
  801373:	83 c4 10             	add    $0x10,%esp
  801376:	85 c0                	test   %eax,%eax
  801378:	78 1b                	js     801395 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  80137a:	83 ec 08             	sub    $0x8,%esp
  80137d:	ff 75 0c             	pushl  0xc(%ebp)
  801380:	50                   	push   %eax
  801381:	e8 5d ff ff ff       	call   8012e3 <fstat>
  801386:	89 c6                	mov    %eax,%esi
	close(fd);
  801388:	89 1c 24             	mov    %ebx,(%esp)
  80138b:	e8 fd fb ff ff       	call   800f8d <close>
	return r;
  801390:	83 c4 10             	add    $0x10,%esp
  801393:	89 f3                	mov    %esi,%ebx
}
  801395:	89 d8                	mov    %ebx,%eax
  801397:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80139a:	5b                   	pop    %ebx
  80139b:	5e                   	pop    %esi
  80139c:	5d                   	pop    %ebp
  80139d:	c3                   	ret    

0080139e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
  8013a1:	56                   	push   %esi
  8013a2:	53                   	push   %ebx
  8013a3:	89 c6                	mov    %eax,%esi
  8013a5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013a7:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013ae:	74 27                	je     8013d7 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013b0:	6a 07                	push   $0x7
  8013b2:	68 00 50 80 00       	push   $0x805000
  8013b7:	56                   	push   %esi
  8013b8:	ff 35 00 40 80 00    	pushl  0x804000
  8013be:	e8 c6 07 00 00       	call   801b89 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013c3:	83 c4 0c             	add    $0xc,%esp
  8013c6:	6a 00                	push   $0x0
  8013c8:	53                   	push   %ebx
  8013c9:	6a 00                	push   $0x0
  8013cb:	e8 62 07 00 00       	call   801b32 <ipc_recv>
}
  8013d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013d3:	5b                   	pop    %ebx
  8013d4:	5e                   	pop    %esi
  8013d5:	5d                   	pop    %ebp
  8013d6:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013d7:	83 ec 0c             	sub    $0xc,%esp
  8013da:	6a 01                	push   $0x1
  8013dc:	e8 0e 08 00 00       	call   801bef <ipc_find_env>
  8013e1:	a3 00 40 80 00       	mov    %eax,0x804000
  8013e6:	83 c4 10             	add    $0x10,%esp
  8013e9:	eb c5                	jmp    8013b0 <fsipc+0x12>

008013eb <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013eb:	f3 0f 1e fb          	endbr32 
  8013ef:	55                   	push   %ebp
  8013f0:	89 e5                	mov    %esp,%ebp
  8013f2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f8:	8b 40 0c             	mov    0xc(%eax),%eax
  8013fb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801400:	8b 45 0c             	mov    0xc(%ebp),%eax
  801403:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801408:	ba 00 00 00 00       	mov    $0x0,%edx
  80140d:	b8 02 00 00 00       	mov    $0x2,%eax
  801412:	e8 87 ff ff ff       	call   80139e <fsipc>
}
  801417:	c9                   	leave  
  801418:	c3                   	ret    

00801419 <devfile_flush>:
{
  801419:	f3 0f 1e fb          	endbr32 
  80141d:	55                   	push   %ebp
  80141e:	89 e5                	mov    %esp,%ebp
  801420:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801423:	8b 45 08             	mov    0x8(%ebp),%eax
  801426:	8b 40 0c             	mov    0xc(%eax),%eax
  801429:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80142e:	ba 00 00 00 00       	mov    $0x0,%edx
  801433:	b8 06 00 00 00       	mov    $0x6,%eax
  801438:	e8 61 ff ff ff       	call   80139e <fsipc>
}
  80143d:	c9                   	leave  
  80143e:	c3                   	ret    

0080143f <devfile_stat>:
{
  80143f:	f3 0f 1e fb          	endbr32 
  801443:	55                   	push   %ebp
  801444:	89 e5                	mov    %esp,%ebp
  801446:	53                   	push   %ebx
  801447:	83 ec 04             	sub    $0x4,%esp
  80144a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80144d:	8b 45 08             	mov    0x8(%ebp),%eax
  801450:	8b 40 0c             	mov    0xc(%eax),%eax
  801453:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801458:	ba 00 00 00 00       	mov    $0x0,%edx
  80145d:	b8 05 00 00 00       	mov    $0x5,%eax
  801462:	e8 37 ff ff ff       	call   80139e <fsipc>
  801467:	85 c0                	test   %eax,%eax
  801469:	78 2c                	js     801497 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80146b:	83 ec 08             	sub    $0x8,%esp
  80146e:	68 00 50 80 00       	push   $0x805000
  801473:	53                   	push   %ebx
  801474:	e8 03 f3 ff ff       	call   80077c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801479:	a1 80 50 80 00       	mov    0x805080,%eax
  80147e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801484:	a1 84 50 80 00       	mov    0x805084,%eax
  801489:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80148f:	83 c4 10             	add    $0x10,%esp
  801492:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801497:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80149a:	c9                   	leave  
  80149b:	c3                   	ret    

0080149c <devfile_write>:
{
  80149c:	f3 0f 1e fb          	endbr32 
  8014a0:	55                   	push   %ebp
  8014a1:	89 e5                	mov    %esp,%ebp
  8014a3:	83 ec 0c             	sub    $0xc,%esp
	panic("devfile_write not implemented");
  8014a6:	68 b8 22 80 00       	push   $0x8022b8
  8014ab:	68 90 00 00 00       	push   $0x90
  8014b0:	68 d6 22 80 00       	push   $0x8022d6
  8014b5:	e8 2e 06 00 00       	call   801ae8 <_panic>

008014ba <devfile_read>:
{
  8014ba:	f3 0f 1e fb          	endbr32 
  8014be:	55                   	push   %ebp
  8014bf:	89 e5                	mov    %esp,%ebp
  8014c1:	56                   	push   %esi
  8014c2:	53                   	push   %ebx
  8014c3:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8014cc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014d1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8014dc:	b8 03 00 00 00       	mov    $0x3,%eax
  8014e1:	e8 b8 fe ff ff       	call   80139e <fsipc>
  8014e6:	89 c3                	mov    %eax,%ebx
  8014e8:	85 c0                	test   %eax,%eax
  8014ea:	78 1f                	js     80150b <devfile_read+0x51>
	assert(r <= n);
  8014ec:	39 f0                	cmp    %esi,%eax
  8014ee:	77 24                	ja     801514 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8014f0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014f5:	7f 33                	jg     80152a <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014f7:	83 ec 04             	sub    $0x4,%esp
  8014fa:	50                   	push   %eax
  8014fb:	68 00 50 80 00       	push   $0x805000
  801500:	ff 75 0c             	pushl  0xc(%ebp)
  801503:	e8 2a f4 ff ff       	call   800932 <memmove>
	return r;
  801508:	83 c4 10             	add    $0x10,%esp
}
  80150b:	89 d8                	mov    %ebx,%eax
  80150d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801510:	5b                   	pop    %ebx
  801511:	5e                   	pop    %esi
  801512:	5d                   	pop    %ebp
  801513:	c3                   	ret    
	assert(r <= n);
  801514:	68 e1 22 80 00       	push   $0x8022e1
  801519:	68 e8 22 80 00       	push   $0x8022e8
  80151e:	6a 7c                	push   $0x7c
  801520:	68 d6 22 80 00       	push   $0x8022d6
  801525:	e8 be 05 00 00       	call   801ae8 <_panic>
	assert(r <= PGSIZE);
  80152a:	68 fd 22 80 00       	push   $0x8022fd
  80152f:	68 e8 22 80 00       	push   $0x8022e8
  801534:	6a 7d                	push   $0x7d
  801536:	68 d6 22 80 00       	push   $0x8022d6
  80153b:	e8 a8 05 00 00       	call   801ae8 <_panic>

00801540 <open>:
{
  801540:	f3 0f 1e fb          	endbr32 
  801544:	55                   	push   %ebp
  801545:	89 e5                	mov    %esp,%ebp
  801547:	56                   	push   %esi
  801548:	53                   	push   %ebx
  801549:	83 ec 1c             	sub    $0x1c,%esp
  80154c:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80154f:	56                   	push   %esi
  801550:	e8 e4 f1 ff ff       	call   800739 <strlen>
  801555:	83 c4 10             	add    $0x10,%esp
  801558:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80155d:	7f 6c                	jg     8015cb <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  80155f:	83 ec 0c             	sub    $0xc,%esp
  801562:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801565:	50                   	push   %eax
  801566:	e8 93 f8 ff ff       	call   800dfe <fd_alloc>
  80156b:	89 c3                	mov    %eax,%ebx
  80156d:	83 c4 10             	add    $0x10,%esp
  801570:	85 c0                	test   %eax,%eax
  801572:	78 3c                	js     8015b0 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801574:	83 ec 08             	sub    $0x8,%esp
  801577:	56                   	push   %esi
  801578:	68 00 50 80 00       	push   $0x805000
  80157d:	e8 fa f1 ff ff       	call   80077c <strcpy>
	fsipcbuf.open.req_omode = mode;
  801582:	8b 45 0c             	mov    0xc(%ebp),%eax
  801585:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80158a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80158d:	b8 01 00 00 00       	mov    $0x1,%eax
  801592:	e8 07 fe ff ff       	call   80139e <fsipc>
  801597:	89 c3                	mov    %eax,%ebx
  801599:	83 c4 10             	add    $0x10,%esp
  80159c:	85 c0                	test   %eax,%eax
  80159e:	78 19                	js     8015b9 <open+0x79>
	return fd2num(fd);
  8015a0:	83 ec 0c             	sub    $0xc,%esp
  8015a3:	ff 75 f4             	pushl  -0xc(%ebp)
  8015a6:	e8 24 f8 ff ff       	call   800dcf <fd2num>
  8015ab:	89 c3                	mov    %eax,%ebx
  8015ad:	83 c4 10             	add    $0x10,%esp
}
  8015b0:	89 d8                	mov    %ebx,%eax
  8015b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015b5:	5b                   	pop    %ebx
  8015b6:	5e                   	pop    %esi
  8015b7:	5d                   	pop    %ebp
  8015b8:	c3                   	ret    
		fd_close(fd, 0);
  8015b9:	83 ec 08             	sub    $0x8,%esp
  8015bc:	6a 00                	push   $0x0
  8015be:	ff 75 f4             	pushl  -0xc(%ebp)
  8015c1:	e8 3c f9 ff ff       	call   800f02 <fd_close>
		return r;
  8015c6:	83 c4 10             	add    $0x10,%esp
  8015c9:	eb e5                	jmp    8015b0 <open+0x70>
		return -E_BAD_PATH;
  8015cb:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8015d0:	eb de                	jmp    8015b0 <open+0x70>

008015d2 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015d2:	f3 0f 1e fb          	endbr32 
  8015d6:	55                   	push   %ebp
  8015d7:	89 e5                	mov    %esp,%ebp
  8015d9:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e1:	b8 08 00 00 00       	mov    $0x8,%eax
  8015e6:	e8 b3 fd ff ff       	call   80139e <fsipc>
}
  8015eb:	c9                   	leave  
  8015ec:	c3                   	ret    

008015ed <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015ed:	f3 0f 1e fb          	endbr32 
  8015f1:	55                   	push   %ebp
  8015f2:	89 e5                	mov    %esp,%ebp
  8015f4:	56                   	push   %esi
  8015f5:	53                   	push   %ebx
  8015f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015f9:	83 ec 0c             	sub    $0xc,%esp
  8015fc:	ff 75 08             	pushl  0x8(%ebp)
  8015ff:	e8 df f7 ff ff       	call   800de3 <fd2data>
  801604:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801606:	83 c4 08             	add    $0x8,%esp
  801609:	68 09 23 80 00       	push   $0x802309
  80160e:	53                   	push   %ebx
  80160f:	e8 68 f1 ff ff       	call   80077c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801614:	8b 46 04             	mov    0x4(%esi),%eax
  801617:	2b 06                	sub    (%esi),%eax
  801619:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80161f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801626:	00 00 00 
	stat->st_dev = &devpipe;
  801629:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801630:	30 80 00 
	return 0;
}
  801633:	b8 00 00 00 00       	mov    $0x0,%eax
  801638:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80163b:	5b                   	pop    %ebx
  80163c:	5e                   	pop    %esi
  80163d:	5d                   	pop    %ebp
  80163e:	c3                   	ret    

0080163f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80163f:	f3 0f 1e fb          	endbr32 
  801643:	55                   	push   %ebp
  801644:	89 e5                	mov    %esp,%ebp
  801646:	53                   	push   %ebx
  801647:	83 ec 0c             	sub    $0xc,%esp
  80164a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80164d:	53                   	push   %ebx
  80164e:	6a 00                	push   $0x0
  801650:	e8 f6 f5 ff ff       	call   800c4b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801655:	89 1c 24             	mov    %ebx,(%esp)
  801658:	e8 86 f7 ff ff       	call   800de3 <fd2data>
  80165d:	83 c4 08             	add    $0x8,%esp
  801660:	50                   	push   %eax
  801661:	6a 00                	push   $0x0
  801663:	e8 e3 f5 ff ff       	call   800c4b <sys_page_unmap>
}
  801668:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166b:	c9                   	leave  
  80166c:	c3                   	ret    

0080166d <_pipeisclosed>:
{
  80166d:	55                   	push   %ebp
  80166e:	89 e5                	mov    %esp,%ebp
  801670:	57                   	push   %edi
  801671:	56                   	push   %esi
  801672:	53                   	push   %ebx
  801673:	83 ec 1c             	sub    $0x1c,%esp
  801676:	89 c7                	mov    %eax,%edi
  801678:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80167a:	a1 08 40 80 00       	mov    0x804008,%eax
  80167f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801682:	83 ec 0c             	sub    $0xc,%esp
  801685:	57                   	push   %edi
  801686:	e8 a1 05 00 00       	call   801c2c <pageref>
  80168b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80168e:	89 34 24             	mov    %esi,(%esp)
  801691:	e8 96 05 00 00       	call   801c2c <pageref>
		nn = thisenv->env_runs;
  801696:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80169c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80169f:	83 c4 10             	add    $0x10,%esp
  8016a2:	39 cb                	cmp    %ecx,%ebx
  8016a4:	74 1b                	je     8016c1 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8016a6:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8016a9:	75 cf                	jne    80167a <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016ab:	8b 42 58             	mov    0x58(%edx),%eax
  8016ae:	6a 01                	push   $0x1
  8016b0:	50                   	push   %eax
  8016b1:	53                   	push   %ebx
  8016b2:	68 10 23 80 00       	push   $0x802310
  8016b7:	e8 b7 ea ff ff       	call   800173 <cprintf>
  8016bc:	83 c4 10             	add    $0x10,%esp
  8016bf:	eb b9                	jmp    80167a <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8016c1:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8016c4:	0f 94 c0             	sete   %al
  8016c7:	0f b6 c0             	movzbl %al,%eax
}
  8016ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016cd:	5b                   	pop    %ebx
  8016ce:	5e                   	pop    %esi
  8016cf:	5f                   	pop    %edi
  8016d0:	5d                   	pop    %ebp
  8016d1:	c3                   	ret    

008016d2 <devpipe_write>:
{
  8016d2:	f3 0f 1e fb          	endbr32 
  8016d6:	55                   	push   %ebp
  8016d7:	89 e5                	mov    %esp,%ebp
  8016d9:	57                   	push   %edi
  8016da:	56                   	push   %esi
  8016db:	53                   	push   %ebx
  8016dc:	83 ec 28             	sub    $0x28,%esp
  8016df:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8016e2:	56                   	push   %esi
  8016e3:	e8 fb f6 ff ff       	call   800de3 <fd2data>
  8016e8:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8016ea:	83 c4 10             	add    $0x10,%esp
  8016ed:	bf 00 00 00 00       	mov    $0x0,%edi
  8016f2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8016f5:	74 4f                	je     801746 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016f7:	8b 43 04             	mov    0x4(%ebx),%eax
  8016fa:	8b 0b                	mov    (%ebx),%ecx
  8016fc:	8d 51 20             	lea    0x20(%ecx),%edx
  8016ff:	39 d0                	cmp    %edx,%eax
  801701:	72 14                	jb     801717 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801703:	89 da                	mov    %ebx,%edx
  801705:	89 f0                	mov    %esi,%eax
  801707:	e8 61 ff ff ff       	call   80166d <_pipeisclosed>
  80170c:	85 c0                	test   %eax,%eax
  80170e:	75 3b                	jne    80174b <devpipe_write+0x79>
			sys_yield();
  801710:	e8 86 f4 ff ff       	call   800b9b <sys_yield>
  801715:	eb e0                	jmp    8016f7 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801717:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80171a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80171e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801721:	89 c2                	mov    %eax,%edx
  801723:	c1 fa 1f             	sar    $0x1f,%edx
  801726:	89 d1                	mov    %edx,%ecx
  801728:	c1 e9 1b             	shr    $0x1b,%ecx
  80172b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80172e:	83 e2 1f             	and    $0x1f,%edx
  801731:	29 ca                	sub    %ecx,%edx
  801733:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801737:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80173b:	83 c0 01             	add    $0x1,%eax
  80173e:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801741:	83 c7 01             	add    $0x1,%edi
  801744:	eb ac                	jmp    8016f2 <devpipe_write+0x20>
	return i;
  801746:	8b 45 10             	mov    0x10(%ebp),%eax
  801749:	eb 05                	jmp    801750 <devpipe_write+0x7e>
				return 0;
  80174b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801750:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801753:	5b                   	pop    %ebx
  801754:	5e                   	pop    %esi
  801755:	5f                   	pop    %edi
  801756:	5d                   	pop    %ebp
  801757:	c3                   	ret    

00801758 <devpipe_read>:
{
  801758:	f3 0f 1e fb          	endbr32 
  80175c:	55                   	push   %ebp
  80175d:	89 e5                	mov    %esp,%ebp
  80175f:	57                   	push   %edi
  801760:	56                   	push   %esi
  801761:	53                   	push   %ebx
  801762:	83 ec 18             	sub    $0x18,%esp
  801765:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801768:	57                   	push   %edi
  801769:	e8 75 f6 ff ff       	call   800de3 <fd2data>
  80176e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801770:	83 c4 10             	add    $0x10,%esp
  801773:	be 00 00 00 00       	mov    $0x0,%esi
  801778:	3b 75 10             	cmp    0x10(%ebp),%esi
  80177b:	75 14                	jne    801791 <devpipe_read+0x39>
	return i;
  80177d:	8b 45 10             	mov    0x10(%ebp),%eax
  801780:	eb 02                	jmp    801784 <devpipe_read+0x2c>
				return i;
  801782:	89 f0                	mov    %esi,%eax
}
  801784:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801787:	5b                   	pop    %ebx
  801788:	5e                   	pop    %esi
  801789:	5f                   	pop    %edi
  80178a:	5d                   	pop    %ebp
  80178b:	c3                   	ret    
			sys_yield();
  80178c:	e8 0a f4 ff ff       	call   800b9b <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801791:	8b 03                	mov    (%ebx),%eax
  801793:	3b 43 04             	cmp    0x4(%ebx),%eax
  801796:	75 18                	jne    8017b0 <devpipe_read+0x58>
			if (i > 0)
  801798:	85 f6                	test   %esi,%esi
  80179a:	75 e6                	jne    801782 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  80179c:	89 da                	mov    %ebx,%edx
  80179e:	89 f8                	mov    %edi,%eax
  8017a0:	e8 c8 fe ff ff       	call   80166d <_pipeisclosed>
  8017a5:	85 c0                	test   %eax,%eax
  8017a7:	74 e3                	je     80178c <devpipe_read+0x34>
				return 0;
  8017a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8017ae:	eb d4                	jmp    801784 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017b0:	99                   	cltd   
  8017b1:	c1 ea 1b             	shr    $0x1b,%edx
  8017b4:	01 d0                	add    %edx,%eax
  8017b6:	83 e0 1f             	and    $0x1f,%eax
  8017b9:	29 d0                	sub    %edx,%eax
  8017bb:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8017c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017c3:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8017c6:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8017c9:	83 c6 01             	add    $0x1,%esi
  8017cc:	eb aa                	jmp    801778 <devpipe_read+0x20>

008017ce <pipe>:
{
  8017ce:	f3 0f 1e fb          	endbr32 
  8017d2:	55                   	push   %ebp
  8017d3:	89 e5                	mov    %esp,%ebp
  8017d5:	56                   	push   %esi
  8017d6:	53                   	push   %ebx
  8017d7:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8017da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017dd:	50                   	push   %eax
  8017de:	e8 1b f6 ff ff       	call   800dfe <fd_alloc>
  8017e3:	89 c3                	mov    %eax,%ebx
  8017e5:	83 c4 10             	add    $0x10,%esp
  8017e8:	85 c0                	test   %eax,%eax
  8017ea:	0f 88 23 01 00 00    	js     801913 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017f0:	83 ec 04             	sub    $0x4,%esp
  8017f3:	68 07 04 00 00       	push   $0x407
  8017f8:	ff 75 f4             	pushl  -0xc(%ebp)
  8017fb:	6a 00                	push   $0x0
  8017fd:	e8 bc f3 ff ff       	call   800bbe <sys_page_alloc>
  801802:	89 c3                	mov    %eax,%ebx
  801804:	83 c4 10             	add    $0x10,%esp
  801807:	85 c0                	test   %eax,%eax
  801809:	0f 88 04 01 00 00    	js     801913 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  80180f:	83 ec 0c             	sub    $0xc,%esp
  801812:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801815:	50                   	push   %eax
  801816:	e8 e3 f5 ff ff       	call   800dfe <fd_alloc>
  80181b:	89 c3                	mov    %eax,%ebx
  80181d:	83 c4 10             	add    $0x10,%esp
  801820:	85 c0                	test   %eax,%eax
  801822:	0f 88 db 00 00 00    	js     801903 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801828:	83 ec 04             	sub    $0x4,%esp
  80182b:	68 07 04 00 00       	push   $0x407
  801830:	ff 75 f0             	pushl  -0x10(%ebp)
  801833:	6a 00                	push   $0x0
  801835:	e8 84 f3 ff ff       	call   800bbe <sys_page_alloc>
  80183a:	89 c3                	mov    %eax,%ebx
  80183c:	83 c4 10             	add    $0x10,%esp
  80183f:	85 c0                	test   %eax,%eax
  801841:	0f 88 bc 00 00 00    	js     801903 <pipe+0x135>
	va = fd2data(fd0);
  801847:	83 ec 0c             	sub    $0xc,%esp
  80184a:	ff 75 f4             	pushl  -0xc(%ebp)
  80184d:	e8 91 f5 ff ff       	call   800de3 <fd2data>
  801852:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801854:	83 c4 0c             	add    $0xc,%esp
  801857:	68 07 04 00 00       	push   $0x407
  80185c:	50                   	push   %eax
  80185d:	6a 00                	push   $0x0
  80185f:	e8 5a f3 ff ff       	call   800bbe <sys_page_alloc>
  801864:	89 c3                	mov    %eax,%ebx
  801866:	83 c4 10             	add    $0x10,%esp
  801869:	85 c0                	test   %eax,%eax
  80186b:	0f 88 82 00 00 00    	js     8018f3 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801871:	83 ec 0c             	sub    $0xc,%esp
  801874:	ff 75 f0             	pushl  -0x10(%ebp)
  801877:	e8 67 f5 ff ff       	call   800de3 <fd2data>
  80187c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801883:	50                   	push   %eax
  801884:	6a 00                	push   $0x0
  801886:	56                   	push   %esi
  801887:	6a 00                	push   $0x0
  801889:	e8 77 f3 ff ff       	call   800c05 <sys_page_map>
  80188e:	89 c3                	mov    %eax,%ebx
  801890:	83 c4 20             	add    $0x20,%esp
  801893:	85 c0                	test   %eax,%eax
  801895:	78 4e                	js     8018e5 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801897:	a1 20 30 80 00       	mov    0x803020,%eax
  80189c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80189f:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8018a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018a4:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8018ab:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018ae:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8018b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8018ba:	83 ec 0c             	sub    $0xc,%esp
  8018bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8018c0:	e8 0a f5 ff ff       	call   800dcf <fd2num>
  8018c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018c8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018ca:	83 c4 04             	add    $0x4,%esp
  8018cd:	ff 75 f0             	pushl  -0x10(%ebp)
  8018d0:	e8 fa f4 ff ff       	call   800dcf <fd2num>
  8018d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018d8:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8018db:	83 c4 10             	add    $0x10,%esp
  8018de:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018e3:	eb 2e                	jmp    801913 <pipe+0x145>
	sys_page_unmap(0, va);
  8018e5:	83 ec 08             	sub    $0x8,%esp
  8018e8:	56                   	push   %esi
  8018e9:	6a 00                	push   $0x0
  8018eb:	e8 5b f3 ff ff       	call   800c4b <sys_page_unmap>
  8018f0:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8018f3:	83 ec 08             	sub    $0x8,%esp
  8018f6:	ff 75 f0             	pushl  -0x10(%ebp)
  8018f9:	6a 00                	push   $0x0
  8018fb:	e8 4b f3 ff ff       	call   800c4b <sys_page_unmap>
  801900:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801903:	83 ec 08             	sub    $0x8,%esp
  801906:	ff 75 f4             	pushl  -0xc(%ebp)
  801909:	6a 00                	push   $0x0
  80190b:	e8 3b f3 ff ff       	call   800c4b <sys_page_unmap>
  801910:	83 c4 10             	add    $0x10,%esp
}
  801913:	89 d8                	mov    %ebx,%eax
  801915:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801918:	5b                   	pop    %ebx
  801919:	5e                   	pop    %esi
  80191a:	5d                   	pop    %ebp
  80191b:	c3                   	ret    

0080191c <pipeisclosed>:
{
  80191c:	f3 0f 1e fb          	endbr32 
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
  801923:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801926:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801929:	50                   	push   %eax
  80192a:	ff 75 08             	pushl  0x8(%ebp)
  80192d:	e8 22 f5 ff ff       	call   800e54 <fd_lookup>
  801932:	83 c4 10             	add    $0x10,%esp
  801935:	85 c0                	test   %eax,%eax
  801937:	78 18                	js     801951 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801939:	83 ec 0c             	sub    $0xc,%esp
  80193c:	ff 75 f4             	pushl  -0xc(%ebp)
  80193f:	e8 9f f4 ff ff       	call   800de3 <fd2data>
  801944:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801946:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801949:	e8 1f fd ff ff       	call   80166d <_pipeisclosed>
  80194e:	83 c4 10             	add    $0x10,%esp
}
  801951:	c9                   	leave  
  801952:	c3                   	ret    

00801953 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801953:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801957:	b8 00 00 00 00       	mov    $0x0,%eax
  80195c:	c3                   	ret    

0080195d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80195d:	f3 0f 1e fb          	endbr32 
  801961:	55                   	push   %ebp
  801962:	89 e5                	mov    %esp,%ebp
  801964:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801967:	68 28 23 80 00       	push   $0x802328
  80196c:	ff 75 0c             	pushl  0xc(%ebp)
  80196f:	e8 08 ee ff ff       	call   80077c <strcpy>
	return 0;
}
  801974:	b8 00 00 00 00       	mov    $0x0,%eax
  801979:	c9                   	leave  
  80197a:	c3                   	ret    

0080197b <devcons_write>:
{
  80197b:	f3 0f 1e fb          	endbr32 
  80197f:	55                   	push   %ebp
  801980:	89 e5                	mov    %esp,%ebp
  801982:	57                   	push   %edi
  801983:	56                   	push   %esi
  801984:	53                   	push   %ebx
  801985:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80198b:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801990:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801996:	3b 75 10             	cmp    0x10(%ebp),%esi
  801999:	73 31                	jae    8019cc <devcons_write+0x51>
		m = n - tot;
  80199b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80199e:	29 f3                	sub    %esi,%ebx
  8019a0:	83 fb 7f             	cmp    $0x7f,%ebx
  8019a3:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8019a8:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8019ab:	83 ec 04             	sub    $0x4,%esp
  8019ae:	53                   	push   %ebx
  8019af:	89 f0                	mov    %esi,%eax
  8019b1:	03 45 0c             	add    0xc(%ebp),%eax
  8019b4:	50                   	push   %eax
  8019b5:	57                   	push   %edi
  8019b6:	e8 77 ef ff ff       	call   800932 <memmove>
		sys_cputs(buf, m);
  8019bb:	83 c4 08             	add    $0x8,%esp
  8019be:	53                   	push   %ebx
  8019bf:	57                   	push   %edi
  8019c0:	e8 29 f1 ff ff       	call   800aee <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8019c5:	01 de                	add    %ebx,%esi
  8019c7:	83 c4 10             	add    $0x10,%esp
  8019ca:	eb ca                	jmp    801996 <devcons_write+0x1b>
}
  8019cc:	89 f0                	mov    %esi,%eax
  8019ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019d1:	5b                   	pop    %ebx
  8019d2:	5e                   	pop    %esi
  8019d3:	5f                   	pop    %edi
  8019d4:	5d                   	pop    %ebp
  8019d5:	c3                   	ret    

008019d6 <devcons_read>:
{
  8019d6:	f3 0f 1e fb          	endbr32 
  8019da:	55                   	push   %ebp
  8019db:	89 e5                	mov    %esp,%ebp
  8019dd:	83 ec 08             	sub    $0x8,%esp
  8019e0:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8019e5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019e9:	74 21                	je     801a0c <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  8019eb:	e8 20 f1 ff ff       	call   800b10 <sys_cgetc>
  8019f0:	85 c0                	test   %eax,%eax
  8019f2:	75 07                	jne    8019fb <devcons_read+0x25>
		sys_yield();
  8019f4:	e8 a2 f1 ff ff       	call   800b9b <sys_yield>
  8019f9:	eb f0                	jmp    8019eb <devcons_read+0x15>
	if (c < 0)
  8019fb:	78 0f                	js     801a0c <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  8019fd:	83 f8 04             	cmp    $0x4,%eax
  801a00:	74 0c                	je     801a0e <devcons_read+0x38>
	*(char*)vbuf = c;
  801a02:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a05:	88 02                	mov    %al,(%edx)
	return 1;
  801a07:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801a0c:	c9                   	leave  
  801a0d:	c3                   	ret    
		return 0;
  801a0e:	b8 00 00 00 00       	mov    $0x0,%eax
  801a13:	eb f7                	jmp    801a0c <devcons_read+0x36>

00801a15 <cputchar>:
{
  801a15:	f3 0f 1e fb          	endbr32 
  801a19:	55                   	push   %ebp
  801a1a:	89 e5                	mov    %esp,%ebp
  801a1c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a22:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801a25:	6a 01                	push   $0x1
  801a27:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a2a:	50                   	push   %eax
  801a2b:	e8 be f0 ff ff       	call   800aee <sys_cputs>
}
  801a30:	83 c4 10             	add    $0x10,%esp
  801a33:	c9                   	leave  
  801a34:	c3                   	ret    

00801a35 <getchar>:
{
  801a35:	f3 0f 1e fb          	endbr32 
  801a39:	55                   	push   %ebp
  801a3a:	89 e5                	mov    %esp,%ebp
  801a3c:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801a3f:	6a 01                	push   $0x1
  801a41:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a44:	50                   	push   %eax
  801a45:	6a 00                	push   $0x0
  801a47:	e8 8b f6 ff ff       	call   8010d7 <read>
	if (r < 0)
  801a4c:	83 c4 10             	add    $0x10,%esp
  801a4f:	85 c0                	test   %eax,%eax
  801a51:	78 06                	js     801a59 <getchar+0x24>
	if (r < 1)
  801a53:	74 06                	je     801a5b <getchar+0x26>
	return c;
  801a55:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801a59:	c9                   	leave  
  801a5a:	c3                   	ret    
		return -E_EOF;
  801a5b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801a60:	eb f7                	jmp    801a59 <getchar+0x24>

00801a62 <iscons>:
{
  801a62:	f3 0f 1e fb          	endbr32 
  801a66:	55                   	push   %ebp
  801a67:	89 e5                	mov    %esp,%ebp
  801a69:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a6c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a6f:	50                   	push   %eax
  801a70:	ff 75 08             	pushl  0x8(%ebp)
  801a73:	e8 dc f3 ff ff       	call   800e54 <fd_lookup>
  801a78:	83 c4 10             	add    $0x10,%esp
  801a7b:	85 c0                	test   %eax,%eax
  801a7d:	78 11                	js     801a90 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a82:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a88:	39 10                	cmp    %edx,(%eax)
  801a8a:	0f 94 c0             	sete   %al
  801a8d:	0f b6 c0             	movzbl %al,%eax
}
  801a90:	c9                   	leave  
  801a91:	c3                   	ret    

00801a92 <opencons>:
{
  801a92:	f3 0f 1e fb          	endbr32 
  801a96:	55                   	push   %ebp
  801a97:	89 e5                	mov    %esp,%ebp
  801a99:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801a9c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a9f:	50                   	push   %eax
  801aa0:	e8 59 f3 ff ff       	call   800dfe <fd_alloc>
  801aa5:	83 c4 10             	add    $0x10,%esp
  801aa8:	85 c0                	test   %eax,%eax
  801aaa:	78 3a                	js     801ae6 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801aac:	83 ec 04             	sub    $0x4,%esp
  801aaf:	68 07 04 00 00       	push   $0x407
  801ab4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ab7:	6a 00                	push   $0x0
  801ab9:	e8 00 f1 ff ff       	call   800bbe <sys_page_alloc>
  801abe:	83 c4 10             	add    $0x10,%esp
  801ac1:	85 c0                	test   %eax,%eax
  801ac3:	78 21                	js     801ae6 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ace:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ada:	83 ec 0c             	sub    $0xc,%esp
  801add:	50                   	push   %eax
  801ade:	e8 ec f2 ff ff       	call   800dcf <fd2num>
  801ae3:	83 c4 10             	add    $0x10,%esp
}
  801ae6:	c9                   	leave  
  801ae7:	c3                   	ret    

00801ae8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ae8:	f3 0f 1e fb          	endbr32 
  801aec:	55                   	push   %ebp
  801aed:	89 e5                	mov    %esp,%ebp
  801aef:	56                   	push   %esi
  801af0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801af1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801af4:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801afa:	e8 79 f0 ff ff       	call   800b78 <sys_getenvid>
  801aff:	83 ec 0c             	sub    $0xc,%esp
  801b02:	ff 75 0c             	pushl  0xc(%ebp)
  801b05:	ff 75 08             	pushl  0x8(%ebp)
  801b08:	56                   	push   %esi
  801b09:	50                   	push   %eax
  801b0a:	68 34 23 80 00       	push   $0x802334
  801b0f:	e8 5f e6 ff ff       	call   800173 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b14:	83 c4 18             	add    $0x18,%esp
  801b17:	53                   	push   %ebx
  801b18:	ff 75 10             	pushl  0x10(%ebp)
  801b1b:	e8 fe e5 ff ff       	call   80011e <vcprintf>
	cprintf("\n");
  801b20:	c7 04 24 ec 1e 80 00 	movl   $0x801eec,(%esp)
  801b27:	e8 47 e6 ff ff       	call   800173 <cprintf>
  801b2c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b2f:	cc                   	int3   
  801b30:	eb fd                	jmp    801b2f <_panic+0x47>

00801b32 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b32:	f3 0f 1e fb          	endbr32 
  801b36:	55                   	push   %ebp
  801b37:	89 e5                	mov    %esp,%ebp
  801b39:	56                   	push   %esi
  801b3a:	53                   	push   %ebx
  801b3b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b41:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801b44:	85 c0                	test   %eax,%eax
  801b46:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b4b:	0f 44 c2             	cmove  %edx,%eax
  801b4e:	83 ec 0c             	sub    $0xc,%esp
  801b51:	50                   	push   %eax
  801b52:	e8 33 f2 ff ff       	call   800d8a <sys_ipc_recv>
  801b57:	83 c4 10             	add    $0x10,%esp
  801b5a:	85 c0                	test   %eax,%eax
  801b5c:	78 24                	js     801b82 <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801b5e:	85 f6                	test   %esi,%esi
  801b60:	74 0a                	je     801b6c <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801b62:	a1 08 40 80 00       	mov    0x804008,%eax
  801b67:	8b 40 78             	mov    0x78(%eax),%eax
  801b6a:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801b6c:	85 db                	test   %ebx,%ebx
  801b6e:	74 0a                	je     801b7a <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801b70:	a1 08 40 80 00       	mov    0x804008,%eax
  801b75:	8b 40 74             	mov    0x74(%eax),%eax
  801b78:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801b7a:	a1 08 40 80 00       	mov    0x804008,%eax
  801b7f:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b82:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b85:	5b                   	pop    %ebx
  801b86:	5e                   	pop    %esi
  801b87:	5d                   	pop    %ebp
  801b88:	c3                   	ret    

00801b89 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b89:	f3 0f 1e fb          	endbr32 
  801b8d:	55                   	push   %ebp
  801b8e:	89 e5                	mov    %esp,%ebp
  801b90:	57                   	push   %edi
  801b91:	56                   	push   %esi
  801b92:	53                   	push   %ebx
  801b93:	83 ec 1c             	sub    $0x1c,%esp
  801b96:	8b 45 10             	mov    0x10(%ebp),%eax
  801b99:	85 c0                	test   %eax,%eax
  801b9b:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801ba0:	0f 45 d0             	cmovne %eax,%edx
  801ba3:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801ba5:	be 01 00 00 00       	mov    $0x1,%esi
  801baa:	eb 1f                	jmp    801bcb <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801bac:	e8 ea ef ff ff       	call   800b9b <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801bb1:	83 c3 01             	add    $0x1,%ebx
  801bb4:	39 de                	cmp    %ebx,%esi
  801bb6:	7f f4                	jg     801bac <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801bb8:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801bba:	83 fe 11             	cmp    $0x11,%esi
  801bbd:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc2:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801bc5:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801bc9:	75 1c                	jne    801be7 <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801bcb:	ff 75 14             	pushl  0x14(%ebp)
  801bce:	57                   	push   %edi
  801bcf:	ff 75 0c             	pushl  0xc(%ebp)
  801bd2:	ff 75 08             	pushl  0x8(%ebp)
  801bd5:	e8 89 f1 ff ff       	call   800d63 <sys_ipc_try_send>
  801bda:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801bdd:	83 c4 10             	add    $0x10,%esp
  801be0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801be5:	eb cd                	jmp    801bb4 <ipc_send+0x2b>
}
  801be7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bea:	5b                   	pop    %ebx
  801beb:	5e                   	pop    %esi
  801bec:	5f                   	pop    %edi
  801bed:	5d                   	pop    %ebp
  801bee:	c3                   	ret    

00801bef <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bef:	f3 0f 1e fb          	endbr32 
  801bf3:	55                   	push   %ebp
  801bf4:	89 e5                	mov    %esp,%ebp
  801bf6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801bf9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801bfe:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c01:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c07:	8b 52 50             	mov    0x50(%edx),%edx
  801c0a:	39 ca                	cmp    %ecx,%edx
  801c0c:	74 11                	je     801c1f <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801c0e:	83 c0 01             	add    $0x1,%eax
  801c11:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c16:	75 e6                	jne    801bfe <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801c18:	b8 00 00 00 00       	mov    $0x0,%eax
  801c1d:	eb 0b                	jmp    801c2a <ipc_find_env+0x3b>
			return envs[i].env_id;
  801c1f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c22:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c27:	8b 40 48             	mov    0x48(%eax),%eax
}
  801c2a:	5d                   	pop    %ebp
  801c2b:	c3                   	ret    

00801c2c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c2c:	f3 0f 1e fb          	endbr32 
  801c30:	55                   	push   %ebp
  801c31:	89 e5                	mov    %esp,%ebp
  801c33:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c36:	89 c2                	mov    %eax,%edx
  801c38:	c1 ea 16             	shr    $0x16,%edx
  801c3b:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801c42:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801c47:	f6 c1 01             	test   $0x1,%cl
  801c4a:	74 1c                	je     801c68 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801c4c:	c1 e8 0c             	shr    $0xc,%eax
  801c4f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c56:	a8 01                	test   $0x1,%al
  801c58:	74 0e                	je     801c68 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c5a:	c1 e8 0c             	shr    $0xc,%eax
  801c5d:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801c64:	ef 
  801c65:	0f b7 d2             	movzwl %dx,%edx
}
  801c68:	89 d0                	mov    %edx,%eax
  801c6a:	5d                   	pop    %ebp
  801c6b:	c3                   	ret    
  801c6c:	66 90                	xchg   %ax,%ax
  801c6e:	66 90                	xchg   %ax,%ax

00801c70 <__udivdi3>:
  801c70:	f3 0f 1e fb          	endbr32 
  801c74:	55                   	push   %ebp
  801c75:	57                   	push   %edi
  801c76:	56                   	push   %esi
  801c77:	53                   	push   %ebx
  801c78:	83 ec 1c             	sub    $0x1c,%esp
  801c7b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c7f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801c83:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c87:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801c8b:	85 d2                	test   %edx,%edx
  801c8d:	75 19                	jne    801ca8 <__udivdi3+0x38>
  801c8f:	39 f3                	cmp    %esi,%ebx
  801c91:	76 4d                	jbe    801ce0 <__udivdi3+0x70>
  801c93:	31 ff                	xor    %edi,%edi
  801c95:	89 e8                	mov    %ebp,%eax
  801c97:	89 f2                	mov    %esi,%edx
  801c99:	f7 f3                	div    %ebx
  801c9b:	89 fa                	mov    %edi,%edx
  801c9d:	83 c4 1c             	add    $0x1c,%esp
  801ca0:	5b                   	pop    %ebx
  801ca1:	5e                   	pop    %esi
  801ca2:	5f                   	pop    %edi
  801ca3:	5d                   	pop    %ebp
  801ca4:	c3                   	ret    
  801ca5:	8d 76 00             	lea    0x0(%esi),%esi
  801ca8:	39 f2                	cmp    %esi,%edx
  801caa:	76 14                	jbe    801cc0 <__udivdi3+0x50>
  801cac:	31 ff                	xor    %edi,%edi
  801cae:	31 c0                	xor    %eax,%eax
  801cb0:	89 fa                	mov    %edi,%edx
  801cb2:	83 c4 1c             	add    $0x1c,%esp
  801cb5:	5b                   	pop    %ebx
  801cb6:	5e                   	pop    %esi
  801cb7:	5f                   	pop    %edi
  801cb8:	5d                   	pop    %ebp
  801cb9:	c3                   	ret    
  801cba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cc0:	0f bd fa             	bsr    %edx,%edi
  801cc3:	83 f7 1f             	xor    $0x1f,%edi
  801cc6:	75 48                	jne    801d10 <__udivdi3+0xa0>
  801cc8:	39 f2                	cmp    %esi,%edx
  801cca:	72 06                	jb     801cd2 <__udivdi3+0x62>
  801ccc:	31 c0                	xor    %eax,%eax
  801cce:	39 eb                	cmp    %ebp,%ebx
  801cd0:	77 de                	ja     801cb0 <__udivdi3+0x40>
  801cd2:	b8 01 00 00 00       	mov    $0x1,%eax
  801cd7:	eb d7                	jmp    801cb0 <__udivdi3+0x40>
  801cd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ce0:	89 d9                	mov    %ebx,%ecx
  801ce2:	85 db                	test   %ebx,%ebx
  801ce4:	75 0b                	jne    801cf1 <__udivdi3+0x81>
  801ce6:	b8 01 00 00 00       	mov    $0x1,%eax
  801ceb:	31 d2                	xor    %edx,%edx
  801ced:	f7 f3                	div    %ebx
  801cef:	89 c1                	mov    %eax,%ecx
  801cf1:	31 d2                	xor    %edx,%edx
  801cf3:	89 f0                	mov    %esi,%eax
  801cf5:	f7 f1                	div    %ecx
  801cf7:	89 c6                	mov    %eax,%esi
  801cf9:	89 e8                	mov    %ebp,%eax
  801cfb:	89 f7                	mov    %esi,%edi
  801cfd:	f7 f1                	div    %ecx
  801cff:	89 fa                	mov    %edi,%edx
  801d01:	83 c4 1c             	add    $0x1c,%esp
  801d04:	5b                   	pop    %ebx
  801d05:	5e                   	pop    %esi
  801d06:	5f                   	pop    %edi
  801d07:	5d                   	pop    %ebp
  801d08:	c3                   	ret    
  801d09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d10:	89 f9                	mov    %edi,%ecx
  801d12:	b8 20 00 00 00       	mov    $0x20,%eax
  801d17:	29 f8                	sub    %edi,%eax
  801d19:	d3 e2                	shl    %cl,%edx
  801d1b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d1f:	89 c1                	mov    %eax,%ecx
  801d21:	89 da                	mov    %ebx,%edx
  801d23:	d3 ea                	shr    %cl,%edx
  801d25:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801d29:	09 d1                	or     %edx,%ecx
  801d2b:	89 f2                	mov    %esi,%edx
  801d2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d31:	89 f9                	mov    %edi,%ecx
  801d33:	d3 e3                	shl    %cl,%ebx
  801d35:	89 c1                	mov    %eax,%ecx
  801d37:	d3 ea                	shr    %cl,%edx
  801d39:	89 f9                	mov    %edi,%ecx
  801d3b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801d3f:	89 eb                	mov    %ebp,%ebx
  801d41:	d3 e6                	shl    %cl,%esi
  801d43:	89 c1                	mov    %eax,%ecx
  801d45:	d3 eb                	shr    %cl,%ebx
  801d47:	09 de                	or     %ebx,%esi
  801d49:	89 f0                	mov    %esi,%eax
  801d4b:	f7 74 24 08          	divl   0x8(%esp)
  801d4f:	89 d6                	mov    %edx,%esi
  801d51:	89 c3                	mov    %eax,%ebx
  801d53:	f7 64 24 0c          	mull   0xc(%esp)
  801d57:	39 d6                	cmp    %edx,%esi
  801d59:	72 15                	jb     801d70 <__udivdi3+0x100>
  801d5b:	89 f9                	mov    %edi,%ecx
  801d5d:	d3 e5                	shl    %cl,%ebp
  801d5f:	39 c5                	cmp    %eax,%ebp
  801d61:	73 04                	jae    801d67 <__udivdi3+0xf7>
  801d63:	39 d6                	cmp    %edx,%esi
  801d65:	74 09                	je     801d70 <__udivdi3+0x100>
  801d67:	89 d8                	mov    %ebx,%eax
  801d69:	31 ff                	xor    %edi,%edi
  801d6b:	e9 40 ff ff ff       	jmp    801cb0 <__udivdi3+0x40>
  801d70:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801d73:	31 ff                	xor    %edi,%edi
  801d75:	e9 36 ff ff ff       	jmp    801cb0 <__udivdi3+0x40>
  801d7a:	66 90                	xchg   %ax,%ax
  801d7c:	66 90                	xchg   %ax,%ax
  801d7e:	66 90                	xchg   %ax,%ax

00801d80 <__umoddi3>:
  801d80:	f3 0f 1e fb          	endbr32 
  801d84:	55                   	push   %ebp
  801d85:	57                   	push   %edi
  801d86:	56                   	push   %esi
  801d87:	53                   	push   %ebx
  801d88:	83 ec 1c             	sub    $0x1c,%esp
  801d8b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d8f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801d93:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801d97:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d9b:	85 c0                	test   %eax,%eax
  801d9d:	75 19                	jne    801db8 <__umoddi3+0x38>
  801d9f:	39 df                	cmp    %ebx,%edi
  801da1:	76 5d                	jbe    801e00 <__umoddi3+0x80>
  801da3:	89 f0                	mov    %esi,%eax
  801da5:	89 da                	mov    %ebx,%edx
  801da7:	f7 f7                	div    %edi
  801da9:	89 d0                	mov    %edx,%eax
  801dab:	31 d2                	xor    %edx,%edx
  801dad:	83 c4 1c             	add    $0x1c,%esp
  801db0:	5b                   	pop    %ebx
  801db1:	5e                   	pop    %esi
  801db2:	5f                   	pop    %edi
  801db3:	5d                   	pop    %ebp
  801db4:	c3                   	ret    
  801db5:	8d 76 00             	lea    0x0(%esi),%esi
  801db8:	89 f2                	mov    %esi,%edx
  801dba:	39 d8                	cmp    %ebx,%eax
  801dbc:	76 12                	jbe    801dd0 <__umoddi3+0x50>
  801dbe:	89 f0                	mov    %esi,%eax
  801dc0:	89 da                	mov    %ebx,%edx
  801dc2:	83 c4 1c             	add    $0x1c,%esp
  801dc5:	5b                   	pop    %ebx
  801dc6:	5e                   	pop    %esi
  801dc7:	5f                   	pop    %edi
  801dc8:	5d                   	pop    %ebp
  801dc9:	c3                   	ret    
  801dca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801dd0:	0f bd e8             	bsr    %eax,%ebp
  801dd3:	83 f5 1f             	xor    $0x1f,%ebp
  801dd6:	75 50                	jne    801e28 <__umoddi3+0xa8>
  801dd8:	39 d8                	cmp    %ebx,%eax
  801dda:	0f 82 e0 00 00 00    	jb     801ec0 <__umoddi3+0x140>
  801de0:	89 d9                	mov    %ebx,%ecx
  801de2:	39 f7                	cmp    %esi,%edi
  801de4:	0f 86 d6 00 00 00    	jbe    801ec0 <__umoddi3+0x140>
  801dea:	89 d0                	mov    %edx,%eax
  801dec:	89 ca                	mov    %ecx,%edx
  801dee:	83 c4 1c             	add    $0x1c,%esp
  801df1:	5b                   	pop    %ebx
  801df2:	5e                   	pop    %esi
  801df3:	5f                   	pop    %edi
  801df4:	5d                   	pop    %ebp
  801df5:	c3                   	ret    
  801df6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dfd:	8d 76 00             	lea    0x0(%esi),%esi
  801e00:	89 fd                	mov    %edi,%ebp
  801e02:	85 ff                	test   %edi,%edi
  801e04:	75 0b                	jne    801e11 <__umoddi3+0x91>
  801e06:	b8 01 00 00 00       	mov    $0x1,%eax
  801e0b:	31 d2                	xor    %edx,%edx
  801e0d:	f7 f7                	div    %edi
  801e0f:	89 c5                	mov    %eax,%ebp
  801e11:	89 d8                	mov    %ebx,%eax
  801e13:	31 d2                	xor    %edx,%edx
  801e15:	f7 f5                	div    %ebp
  801e17:	89 f0                	mov    %esi,%eax
  801e19:	f7 f5                	div    %ebp
  801e1b:	89 d0                	mov    %edx,%eax
  801e1d:	31 d2                	xor    %edx,%edx
  801e1f:	eb 8c                	jmp    801dad <__umoddi3+0x2d>
  801e21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e28:	89 e9                	mov    %ebp,%ecx
  801e2a:	ba 20 00 00 00       	mov    $0x20,%edx
  801e2f:	29 ea                	sub    %ebp,%edx
  801e31:	d3 e0                	shl    %cl,%eax
  801e33:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e37:	89 d1                	mov    %edx,%ecx
  801e39:	89 f8                	mov    %edi,%eax
  801e3b:	d3 e8                	shr    %cl,%eax
  801e3d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801e41:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e45:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e49:	09 c1                	or     %eax,%ecx
  801e4b:	89 d8                	mov    %ebx,%eax
  801e4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e51:	89 e9                	mov    %ebp,%ecx
  801e53:	d3 e7                	shl    %cl,%edi
  801e55:	89 d1                	mov    %edx,%ecx
  801e57:	d3 e8                	shr    %cl,%eax
  801e59:	89 e9                	mov    %ebp,%ecx
  801e5b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e5f:	d3 e3                	shl    %cl,%ebx
  801e61:	89 c7                	mov    %eax,%edi
  801e63:	89 d1                	mov    %edx,%ecx
  801e65:	89 f0                	mov    %esi,%eax
  801e67:	d3 e8                	shr    %cl,%eax
  801e69:	89 e9                	mov    %ebp,%ecx
  801e6b:	89 fa                	mov    %edi,%edx
  801e6d:	d3 e6                	shl    %cl,%esi
  801e6f:	09 d8                	or     %ebx,%eax
  801e71:	f7 74 24 08          	divl   0x8(%esp)
  801e75:	89 d1                	mov    %edx,%ecx
  801e77:	89 f3                	mov    %esi,%ebx
  801e79:	f7 64 24 0c          	mull   0xc(%esp)
  801e7d:	89 c6                	mov    %eax,%esi
  801e7f:	89 d7                	mov    %edx,%edi
  801e81:	39 d1                	cmp    %edx,%ecx
  801e83:	72 06                	jb     801e8b <__umoddi3+0x10b>
  801e85:	75 10                	jne    801e97 <__umoddi3+0x117>
  801e87:	39 c3                	cmp    %eax,%ebx
  801e89:	73 0c                	jae    801e97 <__umoddi3+0x117>
  801e8b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801e8f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801e93:	89 d7                	mov    %edx,%edi
  801e95:	89 c6                	mov    %eax,%esi
  801e97:	89 ca                	mov    %ecx,%edx
  801e99:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801e9e:	29 f3                	sub    %esi,%ebx
  801ea0:	19 fa                	sbb    %edi,%edx
  801ea2:	89 d0                	mov    %edx,%eax
  801ea4:	d3 e0                	shl    %cl,%eax
  801ea6:	89 e9                	mov    %ebp,%ecx
  801ea8:	d3 eb                	shr    %cl,%ebx
  801eaa:	d3 ea                	shr    %cl,%edx
  801eac:	09 d8                	or     %ebx,%eax
  801eae:	83 c4 1c             	add    $0x1c,%esp
  801eb1:	5b                   	pop    %ebx
  801eb2:	5e                   	pop    %esi
  801eb3:	5f                   	pop    %edi
  801eb4:	5d                   	pop    %ebp
  801eb5:	c3                   	ret    
  801eb6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ebd:	8d 76 00             	lea    0x0(%esi),%esi
  801ec0:	29 fe                	sub    %edi,%esi
  801ec2:	19 c3                	sbb    %eax,%ebx
  801ec4:	89 f2                	mov    %esi,%edx
  801ec6:	89 d9                	mov    %ebx,%ecx
  801ec8:	e9 1d ff ff ff       	jmp    801dea <__umoddi3+0x6a>
