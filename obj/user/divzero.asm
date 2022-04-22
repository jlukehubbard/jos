
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
  800055:	68 00 1f 80 00       	push   $0x801f00
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
  8001d9:	e8 c2 1a 00 00       	call   801ca0 <__udivdi3>
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
  800217:	e8 94 1b 00 00       	call   801db0 <__umoddi3>
  80021c:	83 c4 14             	add    $0x14,%esp
  80021f:	0f be 80 18 1f 80 00 	movsbl 0x801f18(%eax),%eax
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
  8002c6:	3e ff 24 85 60 20 80 	notrack jmp *0x802060(,%eax,4)
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
  800393:	8b 14 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%edx
  80039a:	85 d2                	test   %edx,%edx
  80039c:	74 18                	je     8003b6 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80039e:	52                   	push   %edx
  80039f:	68 f1 22 80 00       	push   $0x8022f1
  8003a4:	53                   	push   %ebx
  8003a5:	56                   	push   %esi
  8003a6:	e8 aa fe ff ff       	call   800255 <printfmt>
  8003ab:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003ae:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003b1:	e9 22 02 00 00       	jmp    8005d8 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8003b6:	50                   	push   %eax
  8003b7:	68 30 1f 80 00       	push   $0x801f30
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
  8003de:	b8 29 1f 80 00       	mov    $0x801f29,%eax
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
  800b67:	68 1f 22 80 00       	push   $0x80221f
  800b6c:	6a 23                	push   $0x23
  800b6e:	68 3c 22 80 00       	push   $0x80223c
  800b73:	e8 9c 0f 00 00       	call   801b14 <_panic>

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
  800bf4:	68 1f 22 80 00       	push   $0x80221f
  800bf9:	6a 23                	push   $0x23
  800bfb:	68 3c 22 80 00       	push   $0x80223c
  800c00:	e8 0f 0f 00 00       	call   801b14 <_panic>

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
  800c3a:	68 1f 22 80 00       	push   $0x80221f
  800c3f:	6a 23                	push   $0x23
  800c41:	68 3c 22 80 00       	push   $0x80223c
  800c46:	e8 c9 0e 00 00       	call   801b14 <_panic>

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
  800c80:	68 1f 22 80 00       	push   $0x80221f
  800c85:	6a 23                	push   $0x23
  800c87:	68 3c 22 80 00       	push   $0x80223c
  800c8c:	e8 83 0e 00 00       	call   801b14 <_panic>

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
  800cc6:	68 1f 22 80 00       	push   $0x80221f
  800ccb:	6a 23                	push   $0x23
  800ccd:	68 3c 22 80 00       	push   $0x80223c
  800cd2:	e8 3d 0e 00 00       	call   801b14 <_panic>

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
  800d0c:	68 1f 22 80 00       	push   $0x80221f
  800d11:	6a 23                	push   $0x23
  800d13:	68 3c 22 80 00       	push   $0x80223c
  800d18:	e8 f7 0d 00 00       	call   801b14 <_panic>

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
  800d52:	68 1f 22 80 00       	push   $0x80221f
  800d57:	6a 23                	push   $0x23
  800d59:	68 3c 22 80 00       	push   $0x80223c
  800d5e:	e8 b1 0d 00 00       	call   801b14 <_panic>

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
  800dbe:	68 1f 22 80 00       	push   $0x80221f
  800dc3:	6a 23                	push   $0x23
  800dc5:	68 3c 22 80 00       	push   $0x80223c
  800dca:	e8 45 0d 00 00       	call   801b14 <_panic>

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
  800eb5:	ba c8 22 80 00       	mov    $0x8022c8,%edx
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
  800ed9:	68 4c 22 80 00       	push   $0x80224c
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
  801147:	68 8d 22 80 00       	push   $0x80228d
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
  801218:	68 a9 22 80 00       	push   $0x8022a9
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
  8012c8:	68 6c 22 80 00       	push   $0x80226c
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
  80136c:	e8 fb 01 00 00       	call   80156c <open>
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
  8013be:	e8 f2 07 00 00       	call   801bb5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013c3:	83 c4 0c             	add    $0xc,%esp
  8013c6:	6a 00                	push   $0x0
  8013c8:	53                   	push   %ebx
  8013c9:	6a 00                	push   $0x0
  8013cb:	e8 8e 07 00 00       	call   801b5e <ipc_recv>
}
  8013d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013d3:	5b                   	pop    %ebx
  8013d4:	5e                   	pop    %esi
  8013d5:	5d                   	pop    %ebp
  8013d6:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013d7:	83 ec 0c             	sub    $0xc,%esp
  8013da:	6a 01                	push   $0x1
  8013dc:	e8 3a 08 00 00       	call   801c1b <ipc_find_env>
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
  8014a6:	8b 45 10             	mov    0x10(%ebp),%eax
	n = n > size_max ? size_max : n;
  8014a9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014ae:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8014b3:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8014b9:	8b 52 0c             	mov    0xc(%edx),%edx
  8014bc:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014c2:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014c7:	50                   	push   %eax
  8014c8:	ff 75 0c             	pushl  0xc(%ebp)
  8014cb:	68 08 50 80 00       	push   $0x805008
  8014d0:	e8 5d f4 ff ff       	call   800932 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8014d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014da:	b8 04 00 00 00       	mov    $0x4,%eax
  8014df:	e8 ba fe ff ff       	call   80139e <fsipc>
}
  8014e4:	c9                   	leave  
  8014e5:	c3                   	ret    

008014e6 <devfile_read>:
{
  8014e6:	f3 0f 1e fb          	endbr32 
  8014ea:	55                   	push   %ebp
  8014eb:	89 e5                	mov    %esp,%ebp
  8014ed:	56                   	push   %esi
  8014ee:	53                   	push   %ebx
  8014ef:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8014f8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014fd:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801503:	ba 00 00 00 00       	mov    $0x0,%edx
  801508:	b8 03 00 00 00       	mov    $0x3,%eax
  80150d:	e8 8c fe ff ff       	call   80139e <fsipc>
  801512:	89 c3                	mov    %eax,%ebx
  801514:	85 c0                	test   %eax,%eax
  801516:	78 1f                	js     801537 <devfile_read+0x51>
	assert(r <= n);
  801518:	39 f0                	cmp    %esi,%eax
  80151a:	77 24                	ja     801540 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  80151c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801521:	7f 33                	jg     801556 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801523:	83 ec 04             	sub    $0x4,%esp
  801526:	50                   	push   %eax
  801527:	68 00 50 80 00       	push   $0x805000
  80152c:	ff 75 0c             	pushl  0xc(%ebp)
  80152f:	e8 fe f3 ff ff       	call   800932 <memmove>
	return r;
  801534:	83 c4 10             	add    $0x10,%esp
}
  801537:	89 d8                	mov    %ebx,%eax
  801539:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80153c:	5b                   	pop    %ebx
  80153d:	5e                   	pop    %esi
  80153e:	5d                   	pop    %ebp
  80153f:	c3                   	ret    
	assert(r <= n);
  801540:	68 d8 22 80 00       	push   $0x8022d8
  801545:	68 df 22 80 00       	push   $0x8022df
  80154a:	6a 7c                	push   $0x7c
  80154c:	68 f4 22 80 00       	push   $0x8022f4
  801551:	e8 be 05 00 00       	call   801b14 <_panic>
	assert(r <= PGSIZE);
  801556:	68 ff 22 80 00       	push   $0x8022ff
  80155b:	68 df 22 80 00       	push   $0x8022df
  801560:	6a 7d                	push   $0x7d
  801562:	68 f4 22 80 00       	push   $0x8022f4
  801567:	e8 a8 05 00 00       	call   801b14 <_panic>

0080156c <open>:
{
  80156c:	f3 0f 1e fb          	endbr32 
  801570:	55                   	push   %ebp
  801571:	89 e5                	mov    %esp,%ebp
  801573:	56                   	push   %esi
  801574:	53                   	push   %ebx
  801575:	83 ec 1c             	sub    $0x1c,%esp
  801578:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80157b:	56                   	push   %esi
  80157c:	e8 b8 f1 ff ff       	call   800739 <strlen>
  801581:	83 c4 10             	add    $0x10,%esp
  801584:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801589:	7f 6c                	jg     8015f7 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  80158b:	83 ec 0c             	sub    $0xc,%esp
  80158e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801591:	50                   	push   %eax
  801592:	e8 67 f8 ff ff       	call   800dfe <fd_alloc>
  801597:	89 c3                	mov    %eax,%ebx
  801599:	83 c4 10             	add    $0x10,%esp
  80159c:	85 c0                	test   %eax,%eax
  80159e:	78 3c                	js     8015dc <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  8015a0:	83 ec 08             	sub    $0x8,%esp
  8015a3:	56                   	push   %esi
  8015a4:	68 00 50 80 00       	push   $0x805000
  8015a9:	e8 ce f1 ff ff       	call   80077c <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015b1:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015b9:	b8 01 00 00 00       	mov    $0x1,%eax
  8015be:	e8 db fd ff ff       	call   80139e <fsipc>
  8015c3:	89 c3                	mov    %eax,%ebx
  8015c5:	83 c4 10             	add    $0x10,%esp
  8015c8:	85 c0                	test   %eax,%eax
  8015ca:	78 19                	js     8015e5 <open+0x79>
	return fd2num(fd);
  8015cc:	83 ec 0c             	sub    $0xc,%esp
  8015cf:	ff 75 f4             	pushl  -0xc(%ebp)
  8015d2:	e8 f8 f7 ff ff       	call   800dcf <fd2num>
  8015d7:	89 c3                	mov    %eax,%ebx
  8015d9:	83 c4 10             	add    $0x10,%esp
}
  8015dc:	89 d8                	mov    %ebx,%eax
  8015de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015e1:	5b                   	pop    %ebx
  8015e2:	5e                   	pop    %esi
  8015e3:	5d                   	pop    %ebp
  8015e4:	c3                   	ret    
		fd_close(fd, 0);
  8015e5:	83 ec 08             	sub    $0x8,%esp
  8015e8:	6a 00                	push   $0x0
  8015ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8015ed:	e8 10 f9 ff ff       	call   800f02 <fd_close>
		return r;
  8015f2:	83 c4 10             	add    $0x10,%esp
  8015f5:	eb e5                	jmp    8015dc <open+0x70>
		return -E_BAD_PATH;
  8015f7:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8015fc:	eb de                	jmp    8015dc <open+0x70>

008015fe <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015fe:	f3 0f 1e fb          	endbr32 
  801602:	55                   	push   %ebp
  801603:	89 e5                	mov    %esp,%ebp
  801605:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801608:	ba 00 00 00 00       	mov    $0x0,%edx
  80160d:	b8 08 00 00 00       	mov    $0x8,%eax
  801612:	e8 87 fd ff ff       	call   80139e <fsipc>
}
  801617:	c9                   	leave  
  801618:	c3                   	ret    

00801619 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801619:	f3 0f 1e fb          	endbr32 
  80161d:	55                   	push   %ebp
  80161e:	89 e5                	mov    %esp,%ebp
  801620:	56                   	push   %esi
  801621:	53                   	push   %ebx
  801622:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801625:	83 ec 0c             	sub    $0xc,%esp
  801628:	ff 75 08             	pushl  0x8(%ebp)
  80162b:	e8 b3 f7 ff ff       	call   800de3 <fd2data>
  801630:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801632:	83 c4 08             	add    $0x8,%esp
  801635:	68 0b 23 80 00       	push   $0x80230b
  80163a:	53                   	push   %ebx
  80163b:	e8 3c f1 ff ff       	call   80077c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801640:	8b 46 04             	mov    0x4(%esi),%eax
  801643:	2b 06                	sub    (%esi),%eax
  801645:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80164b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801652:	00 00 00 
	stat->st_dev = &devpipe;
  801655:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80165c:	30 80 00 
	return 0;
}
  80165f:	b8 00 00 00 00       	mov    $0x0,%eax
  801664:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801667:	5b                   	pop    %ebx
  801668:	5e                   	pop    %esi
  801669:	5d                   	pop    %ebp
  80166a:	c3                   	ret    

0080166b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80166b:	f3 0f 1e fb          	endbr32 
  80166f:	55                   	push   %ebp
  801670:	89 e5                	mov    %esp,%ebp
  801672:	53                   	push   %ebx
  801673:	83 ec 0c             	sub    $0xc,%esp
  801676:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801679:	53                   	push   %ebx
  80167a:	6a 00                	push   $0x0
  80167c:	e8 ca f5 ff ff       	call   800c4b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801681:	89 1c 24             	mov    %ebx,(%esp)
  801684:	e8 5a f7 ff ff       	call   800de3 <fd2data>
  801689:	83 c4 08             	add    $0x8,%esp
  80168c:	50                   	push   %eax
  80168d:	6a 00                	push   $0x0
  80168f:	e8 b7 f5 ff ff       	call   800c4b <sys_page_unmap>
}
  801694:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801697:	c9                   	leave  
  801698:	c3                   	ret    

00801699 <_pipeisclosed>:
{
  801699:	55                   	push   %ebp
  80169a:	89 e5                	mov    %esp,%ebp
  80169c:	57                   	push   %edi
  80169d:	56                   	push   %esi
  80169e:	53                   	push   %ebx
  80169f:	83 ec 1c             	sub    $0x1c,%esp
  8016a2:	89 c7                	mov    %eax,%edi
  8016a4:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8016a6:	a1 08 40 80 00       	mov    0x804008,%eax
  8016ab:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8016ae:	83 ec 0c             	sub    $0xc,%esp
  8016b1:	57                   	push   %edi
  8016b2:	e8 a1 05 00 00       	call   801c58 <pageref>
  8016b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016ba:	89 34 24             	mov    %esi,(%esp)
  8016bd:	e8 96 05 00 00       	call   801c58 <pageref>
		nn = thisenv->env_runs;
  8016c2:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8016c8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016cb:	83 c4 10             	add    $0x10,%esp
  8016ce:	39 cb                	cmp    %ecx,%ebx
  8016d0:	74 1b                	je     8016ed <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8016d2:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8016d5:	75 cf                	jne    8016a6 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016d7:	8b 42 58             	mov    0x58(%edx),%eax
  8016da:	6a 01                	push   $0x1
  8016dc:	50                   	push   %eax
  8016dd:	53                   	push   %ebx
  8016de:	68 12 23 80 00       	push   $0x802312
  8016e3:	e8 8b ea ff ff       	call   800173 <cprintf>
  8016e8:	83 c4 10             	add    $0x10,%esp
  8016eb:	eb b9                	jmp    8016a6 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8016ed:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8016f0:	0f 94 c0             	sete   %al
  8016f3:	0f b6 c0             	movzbl %al,%eax
}
  8016f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f9:	5b                   	pop    %ebx
  8016fa:	5e                   	pop    %esi
  8016fb:	5f                   	pop    %edi
  8016fc:	5d                   	pop    %ebp
  8016fd:	c3                   	ret    

008016fe <devpipe_write>:
{
  8016fe:	f3 0f 1e fb          	endbr32 
  801702:	55                   	push   %ebp
  801703:	89 e5                	mov    %esp,%ebp
  801705:	57                   	push   %edi
  801706:	56                   	push   %esi
  801707:	53                   	push   %ebx
  801708:	83 ec 28             	sub    $0x28,%esp
  80170b:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  80170e:	56                   	push   %esi
  80170f:	e8 cf f6 ff ff       	call   800de3 <fd2data>
  801714:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801716:	83 c4 10             	add    $0x10,%esp
  801719:	bf 00 00 00 00       	mov    $0x0,%edi
  80171e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801721:	74 4f                	je     801772 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801723:	8b 43 04             	mov    0x4(%ebx),%eax
  801726:	8b 0b                	mov    (%ebx),%ecx
  801728:	8d 51 20             	lea    0x20(%ecx),%edx
  80172b:	39 d0                	cmp    %edx,%eax
  80172d:	72 14                	jb     801743 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  80172f:	89 da                	mov    %ebx,%edx
  801731:	89 f0                	mov    %esi,%eax
  801733:	e8 61 ff ff ff       	call   801699 <_pipeisclosed>
  801738:	85 c0                	test   %eax,%eax
  80173a:	75 3b                	jne    801777 <devpipe_write+0x79>
			sys_yield();
  80173c:	e8 5a f4 ff ff       	call   800b9b <sys_yield>
  801741:	eb e0                	jmp    801723 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801743:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801746:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80174a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80174d:	89 c2                	mov    %eax,%edx
  80174f:	c1 fa 1f             	sar    $0x1f,%edx
  801752:	89 d1                	mov    %edx,%ecx
  801754:	c1 e9 1b             	shr    $0x1b,%ecx
  801757:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80175a:	83 e2 1f             	and    $0x1f,%edx
  80175d:	29 ca                	sub    %ecx,%edx
  80175f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801763:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801767:	83 c0 01             	add    $0x1,%eax
  80176a:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80176d:	83 c7 01             	add    $0x1,%edi
  801770:	eb ac                	jmp    80171e <devpipe_write+0x20>
	return i;
  801772:	8b 45 10             	mov    0x10(%ebp),%eax
  801775:	eb 05                	jmp    80177c <devpipe_write+0x7e>
				return 0;
  801777:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80177c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80177f:	5b                   	pop    %ebx
  801780:	5e                   	pop    %esi
  801781:	5f                   	pop    %edi
  801782:	5d                   	pop    %ebp
  801783:	c3                   	ret    

00801784 <devpipe_read>:
{
  801784:	f3 0f 1e fb          	endbr32 
  801788:	55                   	push   %ebp
  801789:	89 e5                	mov    %esp,%ebp
  80178b:	57                   	push   %edi
  80178c:	56                   	push   %esi
  80178d:	53                   	push   %ebx
  80178e:	83 ec 18             	sub    $0x18,%esp
  801791:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801794:	57                   	push   %edi
  801795:	e8 49 f6 ff ff       	call   800de3 <fd2data>
  80179a:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80179c:	83 c4 10             	add    $0x10,%esp
  80179f:	be 00 00 00 00       	mov    $0x0,%esi
  8017a4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8017a7:	75 14                	jne    8017bd <devpipe_read+0x39>
	return i;
  8017a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8017ac:	eb 02                	jmp    8017b0 <devpipe_read+0x2c>
				return i;
  8017ae:	89 f0                	mov    %esi,%eax
}
  8017b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017b3:	5b                   	pop    %ebx
  8017b4:	5e                   	pop    %esi
  8017b5:	5f                   	pop    %edi
  8017b6:	5d                   	pop    %ebp
  8017b7:	c3                   	ret    
			sys_yield();
  8017b8:	e8 de f3 ff ff       	call   800b9b <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8017bd:	8b 03                	mov    (%ebx),%eax
  8017bf:	3b 43 04             	cmp    0x4(%ebx),%eax
  8017c2:	75 18                	jne    8017dc <devpipe_read+0x58>
			if (i > 0)
  8017c4:	85 f6                	test   %esi,%esi
  8017c6:	75 e6                	jne    8017ae <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  8017c8:	89 da                	mov    %ebx,%edx
  8017ca:	89 f8                	mov    %edi,%eax
  8017cc:	e8 c8 fe ff ff       	call   801699 <_pipeisclosed>
  8017d1:	85 c0                	test   %eax,%eax
  8017d3:	74 e3                	je     8017b8 <devpipe_read+0x34>
				return 0;
  8017d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8017da:	eb d4                	jmp    8017b0 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017dc:	99                   	cltd   
  8017dd:	c1 ea 1b             	shr    $0x1b,%edx
  8017e0:	01 d0                	add    %edx,%eax
  8017e2:	83 e0 1f             	and    $0x1f,%eax
  8017e5:	29 d0                	sub    %edx,%eax
  8017e7:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8017ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017ef:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8017f2:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8017f5:	83 c6 01             	add    $0x1,%esi
  8017f8:	eb aa                	jmp    8017a4 <devpipe_read+0x20>

008017fa <pipe>:
{
  8017fa:	f3 0f 1e fb          	endbr32 
  8017fe:	55                   	push   %ebp
  8017ff:	89 e5                	mov    %esp,%ebp
  801801:	56                   	push   %esi
  801802:	53                   	push   %ebx
  801803:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801806:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801809:	50                   	push   %eax
  80180a:	e8 ef f5 ff ff       	call   800dfe <fd_alloc>
  80180f:	89 c3                	mov    %eax,%ebx
  801811:	83 c4 10             	add    $0x10,%esp
  801814:	85 c0                	test   %eax,%eax
  801816:	0f 88 23 01 00 00    	js     80193f <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80181c:	83 ec 04             	sub    $0x4,%esp
  80181f:	68 07 04 00 00       	push   $0x407
  801824:	ff 75 f4             	pushl  -0xc(%ebp)
  801827:	6a 00                	push   $0x0
  801829:	e8 90 f3 ff ff       	call   800bbe <sys_page_alloc>
  80182e:	89 c3                	mov    %eax,%ebx
  801830:	83 c4 10             	add    $0x10,%esp
  801833:	85 c0                	test   %eax,%eax
  801835:	0f 88 04 01 00 00    	js     80193f <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  80183b:	83 ec 0c             	sub    $0xc,%esp
  80183e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801841:	50                   	push   %eax
  801842:	e8 b7 f5 ff ff       	call   800dfe <fd_alloc>
  801847:	89 c3                	mov    %eax,%ebx
  801849:	83 c4 10             	add    $0x10,%esp
  80184c:	85 c0                	test   %eax,%eax
  80184e:	0f 88 db 00 00 00    	js     80192f <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801854:	83 ec 04             	sub    $0x4,%esp
  801857:	68 07 04 00 00       	push   $0x407
  80185c:	ff 75 f0             	pushl  -0x10(%ebp)
  80185f:	6a 00                	push   $0x0
  801861:	e8 58 f3 ff ff       	call   800bbe <sys_page_alloc>
  801866:	89 c3                	mov    %eax,%ebx
  801868:	83 c4 10             	add    $0x10,%esp
  80186b:	85 c0                	test   %eax,%eax
  80186d:	0f 88 bc 00 00 00    	js     80192f <pipe+0x135>
	va = fd2data(fd0);
  801873:	83 ec 0c             	sub    $0xc,%esp
  801876:	ff 75 f4             	pushl  -0xc(%ebp)
  801879:	e8 65 f5 ff ff       	call   800de3 <fd2data>
  80187e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801880:	83 c4 0c             	add    $0xc,%esp
  801883:	68 07 04 00 00       	push   $0x407
  801888:	50                   	push   %eax
  801889:	6a 00                	push   $0x0
  80188b:	e8 2e f3 ff ff       	call   800bbe <sys_page_alloc>
  801890:	89 c3                	mov    %eax,%ebx
  801892:	83 c4 10             	add    $0x10,%esp
  801895:	85 c0                	test   %eax,%eax
  801897:	0f 88 82 00 00 00    	js     80191f <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80189d:	83 ec 0c             	sub    $0xc,%esp
  8018a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8018a3:	e8 3b f5 ff ff       	call   800de3 <fd2data>
  8018a8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018af:	50                   	push   %eax
  8018b0:	6a 00                	push   $0x0
  8018b2:	56                   	push   %esi
  8018b3:	6a 00                	push   $0x0
  8018b5:	e8 4b f3 ff ff       	call   800c05 <sys_page_map>
  8018ba:	89 c3                	mov    %eax,%ebx
  8018bc:	83 c4 20             	add    $0x20,%esp
  8018bf:	85 c0                	test   %eax,%eax
  8018c1:	78 4e                	js     801911 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  8018c3:	a1 20 30 80 00       	mov    0x803020,%eax
  8018c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018cb:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8018cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018d0:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8018d7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018da:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8018dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018df:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8018e6:	83 ec 0c             	sub    $0xc,%esp
  8018e9:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ec:	e8 de f4 ff ff       	call   800dcf <fd2num>
  8018f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018f4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018f6:	83 c4 04             	add    $0x4,%esp
  8018f9:	ff 75 f0             	pushl  -0x10(%ebp)
  8018fc:	e8 ce f4 ff ff       	call   800dcf <fd2num>
  801901:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801904:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801907:	83 c4 10             	add    $0x10,%esp
  80190a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80190f:	eb 2e                	jmp    80193f <pipe+0x145>
	sys_page_unmap(0, va);
  801911:	83 ec 08             	sub    $0x8,%esp
  801914:	56                   	push   %esi
  801915:	6a 00                	push   $0x0
  801917:	e8 2f f3 ff ff       	call   800c4b <sys_page_unmap>
  80191c:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80191f:	83 ec 08             	sub    $0x8,%esp
  801922:	ff 75 f0             	pushl  -0x10(%ebp)
  801925:	6a 00                	push   $0x0
  801927:	e8 1f f3 ff ff       	call   800c4b <sys_page_unmap>
  80192c:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80192f:	83 ec 08             	sub    $0x8,%esp
  801932:	ff 75 f4             	pushl  -0xc(%ebp)
  801935:	6a 00                	push   $0x0
  801937:	e8 0f f3 ff ff       	call   800c4b <sys_page_unmap>
  80193c:	83 c4 10             	add    $0x10,%esp
}
  80193f:	89 d8                	mov    %ebx,%eax
  801941:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801944:	5b                   	pop    %ebx
  801945:	5e                   	pop    %esi
  801946:	5d                   	pop    %ebp
  801947:	c3                   	ret    

00801948 <pipeisclosed>:
{
  801948:	f3 0f 1e fb          	endbr32 
  80194c:	55                   	push   %ebp
  80194d:	89 e5                	mov    %esp,%ebp
  80194f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801952:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801955:	50                   	push   %eax
  801956:	ff 75 08             	pushl  0x8(%ebp)
  801959:	e8 f6 f4 ff ff       	call   800e54 <fd_lookup>
  80195e:	83 c4 10             	add    $0x10,%esp
  801961:	85 c0                	test   %eax,%eax
  801963:	78 18                	js     80197d <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801965:	83 ec 0c             	sub    $0xc,%esp
  801968:	ff 75 f4             	pushl  -0xc(%ebp)
  80196b:	e8 73 f4 ff ff       	call   800de3 <fd2data>
  801970:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801972:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801975:	e8 1f fd ff ff       	call   801699 <_pipeisclosed>
  80197a:	83 c4 10             	add    $0x10,%esp
}
  80197d:	c9                   	leave  
  80197e:	c3                   	ret    

0080197f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80197f:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801983:	b8 00 00 00 00       	mov    $0x0,%eax
  801988:	c3                   	ret    

00801989 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801989:	f3 0f 1e fb          	endbr32 
  80198d:	55                   	push   %ebp
  80198e:	89 e5                	mov    %esp,%ebp
  801990:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801993:	68 2a 23 80 00       	push   $0x80232a
  801998:	ff 75 0c             	pushl  0xc(%ebp)
  80199b:	e8 dc ed ff ff       	call   80077c <strcpy>
	return 0;
}
  8019a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a5:	c9                   	leave  
  8019a6:	c3                   	ret    

008019a7 <devcons_write>:
{
  8019a7:	f3 0f 1e fb          	endbr32 
  8019ab:	55                   	push   %ebp
  8019ac:	89 e5                	mov    %esp,%ebp
  8019ae:	57                   	push   %edi
  8019af:	56                   	push   %esi
  8019b0:	53                   	push   %ebx
  8019b1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8019b7:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8019bc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8019c2:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019c5:	73 31                	jae    8019f8 <devcons_write+0x51>
		m = n - tot;
  8019c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019ca:	29 f3                	sub    %esi,%ebx
  8019cc:	83 fb 7f             	cmp    $0x7f,%ebx
  8019cf:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8019d4:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8019d7:	83 ec 04             	sub    $0x4,%esp
  8019da:	53                   	push   %ebx
  8019db:	89 f0                	mov    %esi,%eax
  8019dd:	03 45 0c             	add    0xc(%ebp),%eax
  8019e0:	50                   	push   %eax
  8019e1:	57                   	push   %edi
  8019e2:	e8 4b ef ff ff       	call   800932 <memmove>
		sys_cputs(buf, m);
  8019e7:	83 c4 08             	add    $0x8,%esp
  8019ea:	53                   	push   %ebx
  8019eb:	57                   	push   %edi
  8019ec:	e8 fd f0 ff ff       	call   800aee <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8019f1:	01 de                	add    %ebx,%esi
  8019f3:	83 c4 10             	add    $0x10,%esp
  8019f6:	eb ca                	jmp    8019c2 <devcons_write+0x1b>
}
  8019f8:	89 f0                	mov    %esi,%eax
  8019fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019fd:	5b                   	pop    %ebx
  8019fe:	5e                   	pop    %esi
  8019ff:	5f                   	pop    %edi
  801a00:	5d                   	pop    %ebp
  801a01:	c3                   	ret    

00801a02 <devcons_read>:
{
  801a02:	f3 0f 1e fb          	endbr32 
  801a06:	55                   	push   %ebp
  801a07:	89 e5                	mov    %esp,%ebp
  801a09:	83 ec 08             	sub    $0x8,%esp
  801a0c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801a11:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a15:	74 21                	je     801a38 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801a17:	e8 f4 f0 ff ff       	call   800b10 <sys_cgetc>
  801a1c:	85 c0                	test   %eax,%eax
  801a1e:	75 07                	jne    801a27 <devcons_read+0x25>
		sys_yield();
  801a20:	e8 76 f1 ff ff       	call   800b9b <sys_yield>
  801a25:	eb f0                	jmp    801a17 <devcons_read+0x15>
	if (c < 0)
  801a27:	78 0f                	js     801a38 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801a29:	83 f8 04             	cmp    $0x4,%eax
  801a2c:	74 0c                	je     801a3a <devcons_read+0x38>
	*(char*)vbuf = c;
  801a2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a31:	88 02                	mov    %al,(%edx)
	return 1;
  801a33:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801a38:	c9                   	leave  
  801a39:	c3                   	ret    
		return 0;
  801a3a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a3f:	eb f7                	jmp    801a38 <devcons_read+0x36>

00801a41 <cputchar>:
{
  801a41:	f3 0f 1e fb          	endbr32 
  801a45:	55                   	push   %ebp
  801a46:	89 e5                	mov    %esp,%ebp
  801a48:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801a51:	6a 01                	push   $0x1
  801a53:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a56:	50                   	push   %eax
  801a57:	e8 92 f0 ff ff       	call   800aee <sys_cputs>
}
  801a5c:	83 c4 10             	add    $0x10,%esp
  801a5f:	c9                   	leave  
  801a60:	c3                   	ret    

00801a61 <getchar>:
{
  801a61:	f3 0f 1e fb          	endbr32 
  801a65:	55                   	push   %ebp
  801a66:	89 e5                	mov    %esp,%ebp
  801a68:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801a6b:	6a 01                	push   $0x1
  801a6d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a70:	50                   	push   %eax
  801a71:	6a 00                	push   $0x0
  801a73:	e8 5f f6 ff ff       	call   8010d7 <read>
	if (r < 0)
  801a78:	83 c4 10             	add    $0x10,%esp
  801a7b:	85 c0                	test   %eax,%eax
  801a7d:	78 06                	js     801a85 <getchar+0x24>
	if (r < 1)
  801a7f:	74 06                	je     801a87 <getchar+0x26>
	return c;
  801a81:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801a85:	c9                   	leave  
  801a86:	c3                   	ret    
		return -E_EOF;
  801a87:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801a8c:	eb f7                	jmp    801a85 <getchar+0x24>

00801a8e <iscons>:
{
  801a8e:	f3 0f 1e fb          	endbr32 
  801a92:	55                   	push   %ebp
  801a93:	89 e5                	mov    %esp,%ebp
  801a95:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a98:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a9b:	50                   	push   %eax
  801a9c:	ff 75 08             	pushl  0x8(%ebp)
  801a9f:	e8 b0 f3 ff ff       	call   800e54 <fd_lookup>
  801aa4:	83 c4 10             	add    $0x10,%esp
  801aa7:	85 c0                	test   %eax,%eax
  801aa9:	78 11                	js     801abc <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aae:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ab4:	39 10                	cmp    %edx,(%eax)
  801ab6:	0f 94 c0             	sete   %al
  801ab9:	0f b6 c0             	movzbl %al,%eax
}
  801abc:	c9                   	leave  
  801abd:	c3                   	ret    

00801abe <opencons>:
{
  801abe:	f3 0f 1e fb          	endbr32 
  801ac2:	55                   	push   %ebp
  801ac3:	89 e5                	mov    %esp,%ebp
  801ac5:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801ac8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801acb:	50                   	push   %eax
  801acc:	e8 2d f3 ff ff       	call   800dfe <fd_alloc>
  801ad1:	83 c4 10             	add    $0x10,%esp
  801ad4:	85 c0                	test   %eax,%eax
  801ad6:	78 3a                	js     801b12 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ad8:	83 ec 04             	sub    $0x4,%esp
  801adb:	68 07 04 00 00       	push   $0x407
  801ae0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae3:	6a 00                	push   $0x0
  801ae5:	e8 d4 f0 ff ff       	call   800bbe <sys_page_alloc>
  801aea:	83 c4 10             	add    $0x10,%esp
  801aed:	85 c0                	test   %eax,%eax
  801aef:	78 21                	js     801b12 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801af1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801afa:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801afc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aff:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b06:	83 ec 0c             	sub    $0xc,%esp
  801b09:	50                   	push   %eax
  801b0a:	e8 c0 f2 ff ff       	call   800dcf <fd2num>
  801b0f:	83 c4 10             	add    $0x10,%esp
}
  801b12:	c9                   	leave  
  801b13:	c3                   	ret    

00801b14 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b14:	f3 0f 1e fb          	endbr32 
  801b18:	55                   	push   %ebp
  801b19:	89 e5                	mov    %esp,%ebp
  801b1b:	56                   	push   %esi
  801b1c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801b1d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b20:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801b26:	e8 4d f0 ff ff       	call   800b78 <sys_getenvid>
  801b2b:	83 ec 0c             	sub    $0xc,%esp
  801b2e:	ff 75 0c             	pushl  0xc(%ebp)
  801b31:	ff 75 08             	pushl  0x8(%ebp)
  801b34:	56                   	push   %esi
  801b35:	50                   	push   %eax
  801b36:	68 38 23 80 00       	push   $0x802338
  801b3b:	e8 33 e6 ff ff       	call   800173 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b40:	83 c4 18             	add    $0x18,%esp
  801b43:	53                   	push   %ebx
  801b44:	ff 75 10             	pushl  0x10(%ebp)
  801b47:	e8 d2 e5 ff ff       	call   80011e <vcprintf>
	cprintf("\n");
  801b4c:	c7 04 24 0c 1f 80 00 	movl   $0x801f0c,(%esp)
  801b53:	e8 1b e6 ff ff       	call   800173 <cprintf>
  801b58:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b5b:	cc                   	int3   
  801b5c:	eb fd                	jmp    801b5b <_panic+0x47>

00801b5e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b5e:	f3 0f 1e fb          	endbr32 
  801b62:	55                   	push   %ebp
  801b63:	89 e5                	mov    %esp,%ebp
  801b65:	56                   	push   %esi
  801b66:	53                   	push   %ebx
  801b67:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b6d:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801b70:	85 c0                	test   %eax,%eax
  801b72:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b77:	0f 44 c2             	cmove  %edx,%eax
  801b7a:	83 ec 0c             	sub    $0xc,%esp
  801b7d:	50                   	push   %eax
  801b7e:	e8 07 f2 ff ff       	call   800d8a <sys_ipc_recv>
  801b83:	83 c4 10             	add    $0x10,%esp
  801b86:	85 c0                	test   %eax,%eax
  801b88:	78 24                	js     801bae <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801b8a:	85 f6                	test   %esi,%esi
  801b8c:	74 0a                	je     801b98 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801b8e:	a1 08 40 80 00       	mov    0x804008,%eax
  801b93:	8b 40 78             	mov    0x78(%eax),%eax
  801b96:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801b98:	85 db                	test   %ebx,%ebx
  801b9a:	74 0a                	je     801ba6 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801b9c:	a1 08 40 80 00       	mov    0x804008,%eax
  801ba1:	8b 40 74             	mov    0x74(%eax),%eax
  801ba4:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801ba6:	a1 08 40 80 00       	mov    0x804008,%eax
  801bab:	8b 40 70             	mov    0x70(%eax),%eax
}
  801bae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bb1:	5b                   	pop    %ebx
  801bb2:	5e                   	pop    %esi
  801bb3:	5d                   	pop    %ebp
  801bb4:	c3                   	ret    

00801bb5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bb5:	f3 0f 1e fb          	endbr32 
  801bb9:	55                   	push   %ebp
  801bba:	89 e5                	mov    %esp,%ebp
  801bbc:	57                   	push   %edi
  801bbd:	56                   	push   %esi
  801bbe:	53                   	push   %ebx
  801bbf:	83 ec 1c             	sub    $0x1c,%esp
  801bc2:	8b 45 10             	mov    0x10(%ebp),%eax
  801bc5:	85 c0                	test   %eax,%eax
  801bc7:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801bcc:	0f 45 d0             	cmovne %eax,%edx
  801bcf:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801bd1:	be 01 00 00 00       	mov    $0x1,%esi
  801bd6:	eb 1f                	jmp    801bf7 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801bd8:	e8 be ef ff ff       	call   800b9b <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801bdd:	83 c3 01             	add    $0x1,%ebx
  801be0:	39 de                	cmp    %ebx,%esi
  801be2:	7f f4                	jg     801bd8 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801be4:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801be6:	83 fe 11             	cmp    $0x11,%esi
  801be9:	b8 01 00 00 00       	mov    $0x1,%eax
  801bee:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801bf1:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801bf5:	75 1c                	jne    801c13 <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801bf7:	ff 75 14             	pushl  0x14(%ebp)
  801bfa:	57                   	push   %edi
  801bfb:	ff 75 0c             	pushl  0xc(%ebp)
  801bfe:	ff 75 08             	pushl  0x8(%ebp)
  801c01:	e8 5d f1 ff ff       	call   800d63 <sys_ipc_try_send>
  801c06:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801c09:	83 c4 10             	add    $0x10,%esp
  801c0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c11:	eb cd                	jmp    801be0 <ipc_send+0x2b>
}
  801c13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c16:	5b                   	pop    %ebx
  801c17:	5e                   	pop    %esi
  801c18:	5f                   	pop    %edi
  801c19:	5d                   	pop    %ebp
  801c1a:	c3                   	ret    

00801c1b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c1b:	f3 0f 1e fb          	endbr32 
  801c1f:	55                   	push   %ebp
  801c20:	89 e5                	mov    %esp,%ebp
  801c22:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c25:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c2a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c2d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c33:	8b 52 50             	mov    0x50(%edx),%edx
  801c36:	39 ca                	cmp    %ecx,%edx
  801c38:	74 11                	je     801c4b <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801c3a:	83 c0 01             	add    $0x1,%eax
  801c3d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c42:	75 e6                	jne    801c2a <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801c44:	b8 00 00 00 00       	mov    $0x0,%eax
  801c49:	eb 0b                	jmp    801c56 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801c4b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c4e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c53:	8b 40 48             	mov    0x48(%eax),%eax
}
  801c56:	5d                   	pop    %ebp
  801c57:	c3                   	ret    

00801c58 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c58:	f3 0f 1e fb          	endbr32 
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c62:	89 c2                	mov    %eax,%edx
  801c64:	c1 ea 16             	shr    $0x16,%edx
  801c67:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801c6e:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801c73:	f6 c1 01             	test   $0x1,%cl
  801c76:	74 1c                	je     801c94 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801c78:	c1 e8 0c             	shr    $0xc,%eax
  801c7b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c82:	a8 01                	test   $0x1,%al
  801c84:	74 0e                	je     801c94 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c86:	c1 e8 0c             	shr    $0xc,%eax
  801c89:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801c90:	ef 
  801c91:	0f b7 d2             	movzwl %dx,%edx
}
  801c94:	89 d0                	mov    %edx,%eax
  801c96:	5d                   	pop    %ebp
  801c97:	c3                   	ret    
  801c98:	66 90                	xchg   %ax,%ax
  801c9a:	66 90                	xchg   %ax,%ax
  801c9c:	66 90                	xchg   %ax,%ax
  801c9e:	66 90                	xchg   %ax,%ax

00801ca0 <__udivdi3>:
  801ca0:	f3 0f 1e fb          	endbr32 
  801ca4:	55                   	push   %ebp
  801ca5:	57                   	push   %edi
  801ca6:	56                   	push   %esi
  801ca7:	53                   	push   %ebx
  801ca8:	83 ec 1c             	sub    $0x1c,%esp
  801cab:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801caf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801cb3:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cb7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801cbb:	85 d2                	test   %edx,%edx
  801cbd:	75 19                	jne    801cd8 <__udivdi3+0x38>
  801cbf:	39 f3                	cmp    %esi,%ebx
  801cc1:	76 4d                	jbe    801d10 <__udivdi3+0x70>
  801cc3:	31 ff                	xor    %edi,%edi
  801cc5:	89 e8                	mov    %ebp,%eax
  801cc7:	89 f2                	mov    %esi,%edx
  801cc9:	f7 f3                	div    %ebx
  801ccb:	89 fa                	mov    %edi,%edx
  801ccd:	83 c4 1c             	add    $0x1c,%esp
  801cd0:	5b                   	pop    %ebx
  801cd1:	5e                   	pop    %esi
  801cd2:	5f                   	pop    %edi
  801cd3:	5d                   	pop    %ebp
  801cd4:	c3                   	ret    
  801cd5:	8d 76 00             	lea    0x0(%esi),%esi
  801cd8:	39 f2                	cmp    %esi,%edx
  801cda:	76 14                	jbe    801cf0 <__udivdi3+0x50>
  801cdc:	31 ff                	xor    %edi,%edi
  801cde:	31 c0                	xor    %eax,%eax
  801ce0:	89 fa                	mov    %edi,%edx
  801ce2:	83 c4 1c             	add    $0x1c,%esp
  801ce5:	5b                   	pop    %ebx
  801ce6:	5e                   	pop    %esi
  801ce7:	5f                   	pop    %edi
  801ce8:	5d                   	pop    %ebp
  801ce9:	c3                   	ret    
  801cea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cf0:	0f bd fa             	bsr    %edx,%edi
  801cf3:	83 f7 1f             	xor    $0x1f,%edi
  801cf6:	75 48                	jne    801d40 <__udivdi3+0xa0>
  801cf8:	39 f2                	cmp    %esi,%edx
  801cfa:	72 06                	jb     801d02 <__udivdi3+0x62>
  801cfc:	31 c0                	xor    %eax,%eax
  801cfe:	39 eb                	cmp    %ebp,%ebx
  801d00:	77 de                	ja     801ce0 <__udivdi3+0x40>
  801d02:	b8 01 00 00 00       	mov    $0x1,%eax
  801d07:	eb d7                	jmp    801ce0 <__udivdi3+0x40>
  801d09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d10:	89 d9                	mov    %ebx,%ecx
  801d12:	85 db                	test   %ebx,%ebx
  801d14:	75 0b                	jne    801d21 <__udivdi3+0x81>
  801d16:	b8 01 00 00 00       	mov    $0x1,%eax
  801d1b:	31 d2                	xor    %edx,%edx
  801d1d:	f7 f3                	div    %ebx
  801d1f:	89 c1                	mov    %eax,%ecx
  801d21:	31 d2                	xor    %edx,%edx
  801d23:	89 f0                	mov    %esi,%eax
  801d25:	f7 f1                	div    %ecx
  801d27:	89 c6                	mov    %eax,%esi
  801d29:	89 e8                	mov    %ebp,%eax
  801d2b:	89 f7                	mov    %esi,%edi
  801d2d:	f7 f1                	div    %ecx
  801d2f:	89 fa                	mov    %edi,%edx
  801d31:	83 c4 1c             	add    $0x1c,%esp
  801d34:	5b                   	pop    %ebx
  801d35:	5e                   	pop    %esi
  801d36:	5f                   	pop    %edi
  801d37:	5d                   	pop    %ebp
  801d38:	c3                   	ret    
  801d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d40:	89 f9                	mov    %edi,%ecx
  801d42:	b8 20 00 00 00       	mov    $0x20,%eax
  801d47:	29 f8                	sub    %edi,%eax
  801d49:	d3 e2                	shl    %cl,%edx
  801d4b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d4f:	89 c1                	mov    %eax,%ecx
  801d51:	89 da                	mov    %ebx,%edx
  801d53:	d3 ea                	shr    %cl,%edx
  801d55:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801d59:	09 d1                	or     %edx,%ecx
  801d5b:	89 f2                	mov    %esi,%edx
  801d5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d61:	89 f9                	mov    %edi,%ecx
  801d63:	d3 e3                	shl    %cl,%ebx
  801d65:	89 c1                	mov    %eax,%ecx
  801d67:	d3 ea                	shr    %cl,%edx
  801d69:	89 f9                	mov    %edi,%ecx
  801d6b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801d6f:	89 eb                	mov    %ebp,%ebx
  801d71:	d3 e6                	shl    %cl,%esi
  801d73:	89 c1                	mov    %eax,%ecx
  801d75:	d3 eb                	shr    %cl,%ebx
  801d77:	09 de                	or     %ebx,%esi
  801d79:	89 f0                	mov    %esi,%eax
  801d7b:	f7 74 24 08          	divl   0x8(%esp)
  801d7f:	89 d6                	mov    %edx,%esi
  801d81:	89 c3                	mov    %eax,%ebx
  801d83:	f7 64 24 0c          	mull   0xc(%esp)
  801d87:	39 d6                	cmp    %edx,%esi
  801d89:	72 15                	jb     801da0 <__udivdi3+0x100>
  801d8b:	89 f9                	mov    %edi,%ecx
  801d8d:	d3 e5                	shl    %cl,%ebp
  801d8f:	39 c5                	cmp    %eax,%ebp
  801d91:	73 04                	jae    801d97 <__udivdi3+0xf7>
  801d93:	39 d6                	cmp    %edx,%esi
  801d95:	74 09                	je     801da0 <__udivdi3+0x100>
  801d97:	89 d8                	mov    %ebx,%eax
  801d99:	31 ff                	xor    %edi,%edi
  801d9b:	e9 40 ff ff ff       	jmp    801ce0 <__udivdi3+0x40>
  801da0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801da3:	31 ff                	xor    %edi,%edi
  801da5:	e9 36 ff ff ff       	jmp    801ce0 <__udivdi3+0x40>
  801daa:	66 90                	xchg   %ax,%ax
  801dac:	66 90                	xchg   %ax,%ax
  801dae:	66 90                	xchg   %ax,%ax

00801db0 <__umoddi3>:
  801db0:	f3 0f 1e fb          	endbr32 
  801db4:	55                   	push   %ebp
  801db5:	57                   	push   %edi
  801db6:	56                   	push   %esi
  801db7:	53                   	push   %ebx
  801db8:	83 ec 1c             	sub    $0x1c,%esp
  801dbb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801dbf:	8b 74 24 30          	mov    0x30(%esp),%esi
  801dc3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801dc7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801dcb:	85 c0                	test   %eax,%eax
  801dcd:	75 19                	jne    801de8 <__umoddi3+0x38>
  801dcf:	39 df                	cmp    %ebx,%edi
  801dd1:	76 5d                	jbe    801e30 <__umoddi3+0x80>
  801dd3:	89 f0                	mov    %esi,%eax
  801dd5:	89 da                	mov    %ebx,%edx
  801dd7:	f7 f7                	div    %edi
  801dd9:	89 d0                	mov    %edx,%eax
  801ddb:	31 d2                	xor    %edx,%edx
  801ddd:	83 c4 1c             	add    $0x1c,%esp
  801de0:	5b                   	pop    %ebx
  801de1:	5e                   	pop    %esi
  801de2:	5f                   	pop    %edi
  801de3:	5d                   	pop    %ebp
  801de4:	c3                   	ret    
  801de5:	8d 76 00             	lea    0x0(%esi),%esi
  801de8:	89 f2                	mov    %esi,%edx
  801dea:	39 d8                	cmp    %ebx,%eax
  801dec:	76 12                	jbe    801e00 <__umoddi3+0x50>
  801dee:	89 f0                	mov    %esi,%eax
  801df0:	89 da                	mov    %ebx,%edx
  801df2:	83 c4 1c             	add    $0x1c,%esp
  801df5:	5b                   	pop    %ebx
  801df6:	5e                   	pop    %esi
  801df7:	5f                   	pop    %edi
  801df8:	5d                   	pop    %ebp
  801df9:	c3                   	ret    
  801dfa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e00:	0f bd e8             	bsr    %eax,%ebp
  801e03:	83 f5 1f             	xor    $0x1f,%ebp
  801e06:	75 50                	jne    801e58 <__umoddi3+0xa8>
  801e08:	39 d8                	cmp    %ebx,%eax
  801e0a:	0f 82 e0 00 00 00    	jb     801ef0 <__umoddi3+0x140>
  801e10:	89 d9                	mov    %ebx,%ecx
  801e12:	39 f7                	cmp    %esi,%edi
  801e14:	0f 86 d6 00 00 00    	jbe    801ef0 <__umoddi3+0x140>
  801e1a:	89 d0                	mov    %edx,%eax
  801e1c:	89 ca                	mov    %ecx,%edx
  801e1e:	83 c4 1c             	add    $0x1c,%esp
  801e21:	5b                   	pop    %ebx
  801e22:	5e                   	pop    %esi
  801e23:	5f                   	pop    %edi
  801e24:	5d                   	pop    %ebp
  801e25:	c3                   	ret    
  801e26:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e2d:	8d 76 00             	lea    0x0(%esi),%esi
  801e30:	89 fd                	mov    %edi,%ebp
  801e32:	85 ff                	test   %edi,%edi
  801e34:	75 0b                	jne    801e41 <__umoddi3+0x91>
  801e36:	b8 01 00 00 00       	mov    $0x1,%eax
  801e3b:	31 d2                	xor    %edx,%edx
  801e3d:	f7 f7                	div    %edi
  801e3f:	89 c5                	mov    %eax,%ebp
  801e41:	89 d8                	mov    %ebx,%eax
  801e43:	31 d2                	xor    %edx,%edx
  801e45:	f7 f5                	div    %ebp
  801e47:	89 f0                	mov    %esi,%eax
  801e49:	f7 f5                	div    %ebp
  801e4b:	89 d0                	mov    %edx,%eax
  801e4d:	31 d2                	xor    %edx,%edx
  801e4f:	eb 8c                	jmp    801ddd <__umoddi3+0x2d>
  801e51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e58:	89 e9                	mov    %ebp,%ecx
  801e5a:	ba 20 00 00 00       	mov    $0x20,%edx
  801e5f:	29 ea                	sub    %ebp,%edx
  801e61:	d3 e0                	shl    %cl,%eax
  801e63:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e67:	89 d1                	mov    %edx,%ecx
  801e69:	89 f8                	mov    %edi,%eax
  801e6b:	d3 e8                	shr    %cl,%eax
  801e6d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801e71:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e75:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e79:	09 c1                	or     %eax,%ecx
  801e7b:	89 d8                	mov    %ebx,%eax
  801e7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e81:	89 e9                	mov    %ebp,%ecx
  801e83:	d3 e7                	shl    %cl,%edi
  801e85:	89 d1                	mov    %edx,%ecx
  801e87:	d3 e8                	shr    %cl,%eax
  801e89:	89 e9                	mov    %ebp,%ecx
  801e8b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e8f:	d3 e3                	shl    %cl,%ebx
  801e91:	89 c7                	mov    %eax,%edi
  801e93:	89 d1                	mov    %edx,%ecx
  801e95:	89 f0                	mov    %esi,%eax
  801e97:	d3 e8                	shr    %cl,%eax
  801e99:	89 e9                	mov    %ebp,%ecx
  801e9b:	89 fa                	mov    %edi,%edx
  801e9d:	d3 e6                	shl    %cl,%esi
  801e9f:	09 d8                	or     %ebx,%eax
  801ea1:	f7 74 24 08          	divl   0x8(%esp)
  801ea5:	89 d1                	mov    %edx,%ecx
  801ea7:	89 f3                	mov    %esi,%ebx
  801ea9:	f7 64 24 0c          	mull   0xc(%esp)
  801ead:	89 c6                	mov    %eax,%esi
  801eaf:	89 d7                	mov    %edx,%edi
  801eb1:	39 d1                	cmp    %edx,%ecx
  801eb3:	72 06                	jb     801ebb <__umoddi3+0x10b>
  801eb5:	75 10                	jne    801ec7 <__umoddi3+0x117>
  801eb7:	39 c3                	cmp    %eax,%ebx
  801eb9:	73 0c                	jae    801ec7 <__umoddi3+0x117>
  801ebb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801ebf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801ec3:	89 d7                	mov    %edx,%edi
  801ec5:	89 c6                	mov    %eax,%esi
  801ec7:	89 ca                	mov    %ecx,%edx
  801ec9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801ece:	29 f3                	sub    %esi,%ebx
  801ed0:	19 fa                	sbb    %edi,%edx
  801ed2:	89 d0                	mov    %edx,%eax
  801ed4:	d3 e0                	shl    %cl,%eax
  801ed6:	89 e9                	mov    %ebp,%ecx
  801ed8:	d3 eb                	shr    %cl,%ebx
  801eda:	d3 ea                	shr    %cl,%edx
  801edc:	09 d8                	or     %ebx,%eax
  801ede:	83 c4 1c             	add    $0x1c,%esp
  801ee1:	5b                   	pop    %ebx
  801ee2:	5e                   	pop    %esi
  801ee3:	5f                   	pop    %edi
  801ee4:	5d                   	pop    %ebp
  801ee5:	c3                   	ret    
  801ee6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801eed:	8d 76 00             	lea    0x0(%esi),%esi
  801ef0:	29 fe                	sub    %edi,%esi
  801ef2:	19 c3                	sbb    %eax,%ebx
  801ef4:	89 f2                	mov    %esi,%edx
  801ef6:	89 d9                	mov    %ebx,%ecx
  801ef8:	e9 1d ff ff ff       	jmp    801e1a <__umoddi3+0x6a>
