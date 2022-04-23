
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
  800055:	68 60 10 80 00       	push   $0x801060
  80005a:	e8 0c 01 00 00       	call   80016b <cprintf>
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
  800073:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  80007a:	00 00 00 
    envid_t envid = sys_getenvid();
  80007d:	e8 ee 0a 00 00       	call   800b70 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  800082:	25 ff 03 00 00       	and    $0x3ff,%eax
  800087:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80008a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008f:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800094:	85 db                	test   %ebx,%ebx
  800096:	7e 07                	jle    80009f <libmain+0x3b>
		binaryname = argv[0];
  800098:	8b 06                	mov    (%esi),%eax
  80009a:	a3 00 20 80 00       	mov    %eax,0x802000

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
  8000bf:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  8000c2:	6a 00                	push   $0x0
  8000c4:	e8 62 0a 00 00       	call   800b2b <sys_env_destroy>
}
  8000c9:	83 c4 10             	add    $0x10,%esp
  8000cc:	c9                   	leave  
  8000cd:	c3                   	ret    

008000ce <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ce:	f3 0f 1e fb          	endbr32 
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	53                   	push   %ebx
  8000d6:	83 ec 04             	sub    $0x4,%esp
  8000d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000dc:	8b 13                	mov    (%ebx),%edx
  8000de:	8d 42 01             	lea    0x1(%edx),%eax
  8000e1:	89 03                	mov    %eax,(%ebx)
  8000e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000ea:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ef:	74 09                	je     8000fa <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000f1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f8:	c9                   	leave  
  8000f9:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000fa:	83 ec 08             	sub    $0x8,%esp
  8000fd:	68 ff 00 00 00       	push   $0xff
  800102:	8d 43 08             	lea    0x8(%ebx),%eax
  800105:	50                   	push   %eax
  800106:	e8 db 09 00 00       	call   800ae6 <sys_cputs>
		b->idx = 0;
  80010b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800111:	83 c4 10             	add    $0x10,%esp
  800114:	eb db                	jmp    8000f1 <putch+0x23>

00800116 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800116:	f3 0f 1e fb          	endbr32 
  80011a:	55                   	push   %ebp
  80011b:	89 e5                	mov    %esp,%ebp
  80011d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800123:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80012a:	00 00 00 
	b.cnt = 0;
  80012d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800134:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800137:	ff 75 0c             	pushl  0xc(%ebp)
  80013a:	ff 75 08             	pushl  0x8(%ebp)
  80013d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	68 ce 00 80 00       	push   $0x8000ce
  800149:	e8 20 01 00 00       	call   80026e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80014e:	83 c4 08             	add    $0x8,%esp
  800151:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800157:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80015d:	50                   	push   %eax
  80015e:	e8 83 09 00 00       	call   800ae6 <sys_cputs>

	return b.cnt;
}
  800163:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800169:	c9                   	leave  
  80016a:	c3                   	ret    

0080016b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80016b:	f3 0f 1e fb          	endbr32 
  80016f:	55                   	push   %ebp
  800170:	89 e5                	mov    %esp,%ebp
  800172:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800175:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800178:	50                   	push   %eax
  800179:	ff 75 08             	pushl  0x8(%ebp)
  80017c:	e8 95 ff ff ff       	call   800116 <vcprintf>
	va_end(ap);

	return cnt;
}
  800181:	c9                   	leave  
  800182:	c3                   	ret    

00800183 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	57                   	push   %edi
  800187:	56                   	push   %esi
  800188:	53                   	push   %ebx
  800189:	83 ec 1c             	sub    $0x1c,%esp
  80018c:	89 c7                	mov    %eax,%edi
  80018e:	89 d6                	mov    %edx,%esi
  800190:	8b 45 08             	mov    0x8(%ebp),%eax
  800193:	8b 55 0c             	mov    0xc(%ebp),%edx
  800196:	89 d1                	mov    %edx,%ecx
  800198:	89 c2                	mov    %eax,%edx
  80019a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80019d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001a9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001b0:	39 c2                	cmp    %eax,%edx
  8001b2:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001b5:	72 3e                	jb     8001f5 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b7:	83 ec 0c             	sub    $0xc,%esp
  8001ba:	ff 75 18             	pushl  0x18(%ebp)
  8001bd:	83 eb 01             	sub    $0x1,%ebx
  8001c0:	53                   	push   %ebx
  8001c1:	50                   	push   %eax
  8001c2:	83 ec 08             	sub    $0x8,%esp
  8001c5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8001cb:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ce:	ff 75 d8             	pushl  -0x28(%ebp)
  8001d1:	e8 1a 0c 00 00       	call   800df0 <__udivdi3>
  8001d6:	83 c4 18             	add    $0x18,%esp
  8001d9:	52                   	push   %edx
  8001da:	50                   	push   %eax
  8001db:	89 f2                	mov    %esi,%edx
  8001dd:	89 f8                	mov    %edi,%eax
  8001df:	e8 9f ff ff ff       	call   800183 <printnum>
  8001e4:	83 c4 20             	add    $0x20,%esp
  8001e7:	eb 13                	jmp    8001fc <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001e9:	83 ec 08             	sub    $0x8,%esp
  8001ec:	56                   	push   %esi
  8001ed:	ff 75 18             	pushl  0x18(%ebp)
  8001f0:	ff d7                	call   *%edi
  8001f2:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001f5:	83 eb 01             	sub    $0x1,%ebx
  8001f8:	85 db                	test   %ebx,%ebx
  8001fa:	7f ed                	jg     8001e9 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001fc:	83 ec 08             	sub    $0x8,%esp
  8001ff:	56                   	push   %esi
  800200:	83 ec 04             	sub    $0x4,%esp
  800203:	ff 75 e4             	pushl  -0x1c(%ebp)
  800206:	ff 75 e0             	pushl  -0x20(%ebp)
  800209:	ff 75 dc             	pushl  -0x24(%ebp)
  80020c:	ff 75 d8             	pushl  -0x28(%ebp)
  80020f:	e8 ec 0c 00 00       	call   800f00 <__umoddi3>
  800214:	83 c4 14             	add    $0x14,%esp
  800217:	0f be 80 78 10 80 00 	movsbl 0x801078(%eax),%eax
  80021e:	50                   	push   %eax
  80021f:	ff d7                	call   *%edi
}
  800221:	83 c4 10             	add    $0x10,%esp
  800224:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800227:	5b                   	pop    %ebx
  800228:	5e                   	pop    %esi
  800229:	5f                   	pop    %edi
  80022a:	5d                   	pop    %ebp
  80022b:	c3                   	ret    

0080022c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80022c:	f3 0f 1e fb          	endbr32 
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800236:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80023a:	8b 10                	mov    (%eax),%edx
  80023c:	3b 50 04             	cmp    0x4(%eax),%edx
  80023f:	73 0a                	jae    80024b <sprintputch+0x1f>
		*b->buf++ = ch;
  800241:	8d 4a 01             	lea    0x1(%edx),%ecx
  800244:	89 08                	mov    %ecx,(%eax)
  800246:	8b 45 08             	mov    0x8(%ebp),%eax
  800249:	88 02                	mov    %al,(%edx)
}
  80024b:	5d                   	pop    %ebp
  80024c:	c3                   	ret    

0080024d <printfmt>:
{
  80024d:	f3 0f 1e fb          	endbr32 
  800251:	55                   	push   %ebp
  800252:	89 e5                	mov    %esp,%ebp
  800254:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800257:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80025a:	50                   	push   %eax
  80025b:	ff 75 10             	pushl  0x10(%ebp)
  80025e:	ff 75 0c             	pushl  0xc(%ebp)
  800261:	ff 75 08             	pushl  0x8(%ebp)
  800264:	e8 05 00 00 00       	call   80026e <vprintfmt>
}
  800269:	83 c4 10             	add    $0x10,%esp
  80026c:	c9                   	leave  
  80026d:	c3                   	ret    

0080026e <vprintfmt>:
{
  80026e:	f3 0f 1e fb          	endbr32 
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
  800275:	57                   	push   %edi
  800276:	56                   	push   %esi
  800277:	53                   	push   %ebx
  800278:	83 ec 3c             	sub    $0x3c,%esp
  80027b:	8b 75 08             	mov    0x8(%ebp),%esi
  80027e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800281:	8b 7d 10             	mov    0x10(%ebp),%edi
  800284:	e9 4a 03 00 00       	jmp    8005d3 <vprintfmt+0x365>
		padc = ' ';
  800289:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80028d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800294:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80029b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002a2:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002a7:	8d 47 01             	lea    0x1(%edi),%eax
  8002aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ad:	0f b6 17             	movzbl (%edi),%edx
  8002b0:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002b3:	3c 55                	cmp    $0x55,%al
  8002b5:	0f 87 de 03 00 00    	ja     800699 <vprintfmt+0x42b>
  8002bb:	0f b6 c0             	movzbl %al,%eax
  8002be:	3e ff 24 85 c0 11 80 	notrack jmp *0x8011c0(,%eax,4)
  8002c5:	00 
  8002c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002c9:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002cd:	eb d8                	jmp    8002a7 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8002cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002d2:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002d6:	eb cf                	jmp    8002a7 <vprintfmt+0x39>
  8002d8:	0f b6 d2             	movzbl %dl,%edx
  8002db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002de:	b8 00 00 00 00       	mov    $0x0,%eax
  8002e3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002e6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002e9:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002ed:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002f0:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002f3:	83 f9 09             	cmp    $0x9,%ecx
  8002f6:	77 55                	ja     80034d <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8002f8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002fb:	eb e9                	jmp    8002e6 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8002fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800300:	8b 00                	mov    (%eax),%eax
  800302:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800305:	8b 45 14             	mov    0x14(%ebp),%eax
  800308:	8d 40 04             	lea    0x4(%eax),%eax
  80030b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80030e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800311:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800315:	79 90                	jns    8002a7 <vprintfmt+0x39>
				width = precision, precision = -1;
  800317:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80031a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80031d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800324:	eb 81                	jmp    8002a7 <vprintfmt+0x39>
  800326:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800329:	85 c0                	test   %eax,%eax
  80032b:	ba 00 00 00 00       	mov    $0x0,%edx
  800330:	0f 49 d0             	cmovns %eax,%edx
  800333:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800336:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800339:	e9 69 ff ff ff       	jmp    8002a7 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80033e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800341:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800348:	e9 5a ff ff ff       	jmp    8002a7 <vprintfmt+0x39>
  80034d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800350:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800353:	eb bc                	jmp    800311 <vprintfmt+0xa3>
			lflag++;
  800355:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800358:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80035b:	e9 47 ff ff ff       	jmp    8002a7 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800360:	8b 45 14             	mov    0x14(%ebp),%eax
  800363:	8d 78 04             	lea    0x4(%eax),%edi
  800366:	83 ec 08             	sub    $0x8,%esp
  800369:	53                   	push   %ebx
  80036a:	ff 30                	pushl  (%eax)
  80036c:	ff d6                	call   *%esi
			break;
  80036e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800371:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800374:	e9 57 02 00 00       	jmp    8005d0 <vprintfmt+0x362>
			err = va_arg(ap, int);
  800379:	8b 45 14             	mov    0x14(%ebp),%eax
  80037c:	8d 78 04             	lea    0x4(%eax),%edi
  80037f:	8b 00                	mov    (%eax),%eax
  800381:	99                   	cltd   
  800382:	31 d0                	xor    %edx,%eax
  800384:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800386:	83 f8 0f             	cmp    $0xf,%eax
  800389:	7f 23                	jg     8003ae <vprintfmt+0x140>
  80038b:	8b 14 85 20 13 80 00 	mov    0x801320(,%eax,4),%edx
  800392:	85 d2                	test   %edx,%edx
  800394:	74 18                	je     8003ae <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800396:	52                   	push   %edx
  800397:	68 99 10 80 00       	push   $0x801099
  80039c:	53                   	push   %ebx
  80039d:	56                   	push   %esi
  80039e:	e8 aa fe ff ff       	call   80024d <printfmt>
  8003a3:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003a6:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003a9:	e9 22 02 00 00       	jmp    8005d0 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8003ae:	50                   	push   %eax
  8003af:	68 90 10 80 00       	push   $0x801090
  8003b4:	53                   	push   %ebx
  8003b5:	56                   	push   %esi
  8003b6:	e8 92 fe ff ff       	call   80024d <printfmt>
  8003bb:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003be:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003c1:	e9 0a 02 00 00       	jmp    8005d0 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8003c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c9:	83 c0 04             	add    $0x4,%eax
  8003cc:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d2:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003d4:	85 d2                	test   %edx,%edx
  8003d6:	b8 89 10 80 00       	mov    $0x801089,%eax
  8003db:	0f 45 c2             	cmovne %edx,%eax
  8003de:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003e1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e5:	7e 06                	jle    8003ed <vprintfmt+0x17f>
  8003e7:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8003eb:	75 0d                	jne    8003fa <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003ed:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003f0:	89 c7                	mov    %eax,%edi
  8003f2:	03 45 e0             	add    -0x20(%ebp),%eax
  8003f5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f8:	eb 55                	jmp    80044f <vprintfmt+0x1e1>
  8003fa:	83 ec 08             	sub    $0x8,%esp
  8003fd:	ff 75 d8             	pushl  -0x28(%ebp)
  800400:	ff 75 cc             	pushl  -0x34(%ebp)
  800403:	e8 45 03 00 00       	call   80074d <strnlen>
  800408:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80040b:	29 c2                	sub    %eax,%edx
  80040d:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800410:	83 c4 10             	add    $0x10,%esp
  800413:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800415:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800419:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80041c:	85 ff                	test   %edi,%edi
  80041e:	7e 11                	jle    800431 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800420:	83 ec 08             	sub    $0x8,%esp
  800423:	53                   	push   %ebx
  800424:	ff 75 e0             	pushl  -0x20(%ebp)
  800427:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800429:	83 ef 01             	sub    $0x1,%edi
  80042c:	83 c4 10             	add    $0x10,%esp
  80042f:	eb eb                	jmp    80041c <vprintfmt+0x1ae>
  800431:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800434:	85 d2                	test   %edx,%edx
  800436:	b8 00 00 00 00       	mov    $0x0,%eax
  80043b:	0f 49 c2             	cmovns %edx,%eax
  80043e:	29 c2                	sub    %eax,%edx
  800440:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800443:	eb a8                	jmp    8003ed <vprintfmt+0x17f>
					putch(ch, putdat);
  800445:	83 ec 08             	sub    $0x8,%esp
  800448:	53                   	push   %ebx
  800449:	52                   	push   %edx
  80044a:	ff d6                	call   *%esi
  80044c:	83 c4 10             	add    $0x10,%esp
  80044f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800452:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800454:	83 c7 01             	add    $0x1,%edi
  800457:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80045b:	0f be d0             	movsbl %al,%edx
  80045e:	85 d2                	test   %edx,%edx
  800460:	74 4b                	je     8004ad <vprintfmt+0x23f>
  800462:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800466:	78 06                	js     80046e <vprintfmt+0x200>
  800468:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80046c:	78 1e                	js     80048c <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80046e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800472:	74 d1                	je     800445 <vprintfmt+0x1d7>
  800474:	0f be c0             	movsbl %al,%eax
  800477:	83 e8 20             	sub    $0x20,%eax
  80047a:	83 f8 5e             	cmp    $0x5e,%eax
  80047d:	76 c6                	jbe    800445 <vprintfmt+0x1d7>
					putch('?', putdat);
  80047f:	83 ec 08             	sub    $0x8,%esp
  800482:	53                   	push   %ebx
  800483:	6a 3f                	push   $0x3f
  800485:	ff d6                	call   *%esi
  800487:	83 c4 10             	add    $0x10,%esp
  80048a:	eb c3                	jmp    80044f <vprintfmt+0x1e1>
  80048c:	89 cf                	mov    %ecx,%edi
  80048e:	eb 0e                	jmp    80049e <vprintfmt+0x230>
				putch(' ', putdat);
  800490:	83 ec 08             	sub    $0x8,%esp
  800493:	53                   	push   %ebx
  800494:	6a 20                	push   $0x20
  800496:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800498:	83 ef 01             	sub    $0x1,%edi
  80049b:	83 c4 10             	add    $0x10,%esp
  80049e:	85 ff                	test   %edi,%edi
  8004a0:	7f ee                	jg     800490 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8004a2:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004a5:	89 45 14             	mov    %eax,0x14(%ebp)
  8004a8:	e9 23 01 00 00       	jmp    8005d0 <vprintfmt+0x362>
  8004ad:	89 cf                	mov    %ecx,%edi
  8004af:	eb ed                	jmp    80049e <vprintfmt+0x230>
	if (lflag >= 2)
  8004b1:	83 f9 01             	cmp    $0x1,%ecx
  8004b4:	7f 1b                	jg     8004d1 <vprintfmt+0x263>
	else if (lflag)
  8004b6:	85 c9                	test   %ecx,%ecx
  8004b8:	74 63                	je     80051d <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8004ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bd:	8b 00                	mov    (%eax),%eax
  8004bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004c2:	99                   	cltd   
  8004c3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c9:	8d 40 04             	lea    0x4(%eax),%eax
  8004cc:	89 45 14             	mov    %eax,0x14(%ebp)
  8004cf:	eb 17                	jmp    8004e8 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8004d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d4:	8b 50 04             	mov    0x4(%eax),%edx
  8004d7:	8b 00                	mov    (%eax),%eax
  8004d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004dc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004df:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e2:	8d 40 08             	lea    0x8(%eax),%eax
  8004e5:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004e8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004eb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8004ee:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8004f3:	85 c9                	test   %ecx,%ecx
  8004f5:	0f 89 bb 00 00 00    	jns    8005b6 <vprintfmt+0x348>
				putch('-', putdat);
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	53                   	push   %ebx
  8004ff:	6a 2d                	push   $0x2d
  800501:	ff d6                	call   *%esi
				num = -(long long) num;
  800503:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800506:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800509:	f7 da                	neg    %edx
  80050b:	83 d1 00             	adc    $0x0,%ecx
  80050e:	f7 d9                	neg    %ecx
  800510:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800513:	b8 0a 00 00 00       	mov    $0xa,%eax
  800518:	e9 99 00 00 00       	jmp    8005b6 <vprintfmt+0x348>
		return va_arg(*ap, int);
  80051d:	8b 45 14             	mov    0x14(%ebp),%eax
  800520:	8b 00                	mov    (%eax),%eax
  800522:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800525:	99                   	cltd   
  800526:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800529:	8b 45 14             	mov    0x14(%ebp),%eax
  80052c:	8d 40 04             	lea    0x4(%eax),%eax
  80052f:	89 45 14             	mov    %eax,0x14(%ebp)
  800532:	eb b4                	jmp    8004e8 <vprintfmt+0x27a>
	if (lflag >= 2)
  800534:	83 f9 01             	cmp    $0x1,%ecx
  800537:	7f 1b                	jg     800554 <vprintfmt+0x2e6>
	else if (lflag)
  800539:	85 c9                	test   %ecx,%ecx
  80053b:	74 2c                	je     800569 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  80053d:	8b 45 14             	mov    0x14(%ebp),%eax
  800540:	8b 10                	mov    (%eax),%edx
  800542:	b9 00 00 00 00       	mov    $0x0,%ecx
  800547:	8d 40 04             	lea    0x4(%eax),%eax
  80054a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80054d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800552:	eb 62                	jmp    8005b6 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800554:	8b 45 14             	mov    0x14(%ebp),%eax
  800557:	8b 10                	mov    (%eax),%edx
  800559:	8b 48 04             	mov    0x4(%eax),%ecx
  80055c:	8d 40 08             	lea    0x8(%eax),%eax
  80055f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800562:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800567:	eb 4d                	jmp    8005b6 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8b 10                	mov    (%eax),%edx
  80056e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800573:	8d 40 04             	lea    0x4(%eax),%eax
  800576:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800579:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80057e:	eb 36                	jmp    8005b6 <vprintfmt+0x348>
	if (lflag >= 2)
  800580:	83 f9 01             	cmp    $0x1,%ecx
  800583:	7f 17                	jg     80059c <vprintfmt+0x32e>
	else if (lflag)
  800585:	85 c9                	test   %ecx,%ecx
  800587:	74 6e                	je     8005f7 <vprintfmt+0x389>
		return va_arg(*ap, long);
  800589:	8b 45 14             	mov    0x14(%ebp),%eax
  80058c:	8b 10                	mov    (%eax),%edx
  80058e:	89 d0                	mov    %edx,%eax
  800590:	99                   	cltd   
  800591:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800594:	8d 49 04             	lea    0x4(%ecx),%ecx
  800597:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80059a:	eb 11                	jmp    8005ad <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	8b 50 04             	mov    0x4(%eax),%edx
  8005a2:	8b 00                	mov    (%eax),%eax
  8005a4:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005a7:	8d 49 08             	lea    0x8(%ecx),%ecx
  8005aa:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8005ad:	89 d1                	mov    %edx,%ecx
  8005af:	89 c2                	mov    %eax,%edx
            base = 8;
  8005b1:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005b6:	83 ec 0c             	sub    $0xc,%esp
  8005b9:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005bd:	57                   	push   %edi
  8005be:	ff 75 e0             	pushl  -0x20(%ebp)
  8005c1:	50                   	push   %eax
  8005c2:	51                   	push   %ecx
  8005c3:	52                   	push   %edx
  8005c4:	89 da                	mov    %ebx,%edx
  8005c6:	89 f0                	mov    %esi,%eax
  8005c8:	e8 b6 fb ff ff       	call   800183 <printnum>
			break;
  8005cd:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8005d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005d3:	83 c7 01             	add    $0x1,%edi
  8005d6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005da:	83 f8 25             	cmp    $0x25,%eax
  8005dd:	0f 84 a6 fc ff ff    	je     800289 <vprintfmt+0x1b>
			if (ch == '\0')
  8005e3:	85 c0                	test   %eax,%eax
  8005e5:	0f 84 ce 00 00 00    	je     8006b9 <vprintfmt+0x44b>
			putch(ch, putdat);
  8005eb:	83 ec 08             	sub    $0x8,%esp
  8005ee:	53                   	push   %ebx
  8005ef:	50                   	push   %eax
  8005f0:	ff d6                	call   *%esi
  8005f2:	83 c4 10             	add    $0x10,%esp
  8005f5:	eb dc                	jmp    8005d3 <vprintfmt+0x365>
		return va_arg(*ap, int);
  8005f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fa:	8b 10                	mov    (%eax),%edx
  8005fc:	89 d0                	mov    %edx,%eax
  8005fe:	99                   	cltd   
  8005ff:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800602:	8d 49 04             	lea    0x4(%ecx),%ecx
  800605:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800608:	eb a3                	jmp    8005ad <vprintfmt+0x33f>
			putch('0', putdat);
  80060a:	83 ec 08             	sub    $0x8,%esp
  80060d:	53                   	push   %ebx
  80060e:	6a 30                	push   $0x30
  800610:	ff d6                	call   *%esi
			putch('x', putdat);
  800612:	83 c4 08             	add    $0x8,%esp
  800615:	53                   	push   %ebx
  800616:	6a 78                	push   $0x78
  800618:	ff d6                	call   *%esi
			num = (unsigned long long)
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8b 10                	mov    (%eax),%edx
  80061f:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800624:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800627:	8d 40 04             	lea    0x4(%eax),%eax
  80062a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80062d:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800632:	eb 82                	jmp    8005b6 <vprintfmt+0x348>
	if (lflag >= 2)
  800634:	83 f9 01             	cmp    $0x1,%ecx
  800637:	7f 1e                	jg     800657 <vprintfmt+0x3e9>
	else if (lflag)
  800639:	85 c9                	test   %ecx,%ecx
  80063b:	74 32                	je     80066f <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  80063d:	8b 45 14             	mov    0x14(%ebp),%eax
  800640:	8b 10                	mov    (%eax),%edx
  800642:	b9 00 00 00 00       	mov    $0x0,%ecx
  800647:	8d 40 04             	lea    0x4(%eax),%eax
  80064a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80064d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800652:	e9 5f ff ff ff       	jmp    8005b6 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8b 10                	mov    (%eax),%edx
  80065c:	8b 48 04             	mov    0x4(%eax),%ecx
  80065f:	8d 40 08             	lea    0x8(%eax),%eax
  800662:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800665:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80066a:	e9 47 ff ff ff       	jmp    8005b6 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80066f:	8b 45 14             	mov    0x14(%ebp),%eax
  800672:	8b 10                	mov    (%eax),%edx
  800674:	b9 00 00 00 00       	mov    $0x0,%ecx
  800679:	8d 40 04             	lea    0x4(%eax),%eax
  80067c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80067f:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800684:	e9 2d ff ff ff       	jmp    8005b6 <vprintfmt+0x348>
			putch(ch, putdat);
  800689:	83 ec 08             	sub    $0x8,%esp
  80068c:	53                   	push   %ebx
  80068d:	6a 25                	push   $0x25
  80068f:	ff d6                	call   *%esi
			break;
  800691:	83 c4 10             	add    $0x10,%esp
  800694:	e9 37 ff ff ff       	jmp    8005d0 <vprintfmt+0x362>
			putch('%', putdat);
  800699:	83 ec 08             	sub    $0x8,%esp
  80069c:	53                   	push   %ebx
  80069d:	6a 25                	push   $0x25
  80069f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006a1:	83 c4 10             	add    $0x10,%esp
  8006a4:	89 f8                	mov    %edi,%eax
  8006a6:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006aa:	74 05                	je     8006b1 <vprintfmt+0x443>
  8006ac:	83 e8 01             	sub    $0x1,%eax
  8006af:	eb f5                	jmp    8006a6 <vprintfmt+0x438>
  8006b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006b4:	e9 17 ff ff ff       	jmp    8005d0 <vprintfmt+0x362>
}
  8006b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006bc:	5b                   	pop    %ebx
  8006bd:	5e                   	pop    %esi
  8006be:	5f                   	pop    %edi
  8006bf:	5d                   	pop    %ebp
  8006c0:	c3                   	ret    

008006c1 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006c1:	f3 0f 1e fb          	endbr32 
  8006c5:	55                   	push   %ebp
  8006c6:	89 e5                	mov    %esp,%ebp
  8006c8:	83 ec 18             	sub    $0x18,%esp
  8006cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ce:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006d4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006d8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006e2:	85 c0                	test   %eax,%eax
  8006e4:	74 26                	je     80070c <vsnprintf+0x4b>
  8006e6:	85 d2                	test   %edx,%edx
  8006e8:	7e 22                	jle    80070c <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006ea:	ff 75 14             	pushl  0x14(%ebp)
  8006ed:	ff 75 10             	pushl  0x10(%ebp)
  8006f0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f3:	50                   	push   %eax
  8006f4:	68 2c 02 80 00       	push   $0x80022c
  8006f9:	e8 70 fb ff ff       	call   80026e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800701:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800704:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800707:	83 c4 10             	add    $0x10,%esp
}
  80070a:	c9                   	leave  
  80070b:	c3                   	ret    
		return -E_INVAL;
  80070c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800711:	eb f7                	jmp    80070a <vsnprintf+0x49>

00800713 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800713:	f3 0f 1e fb          	endbr32 
  800717:	55                   	push   %ebp
  800718:	89 e5                	mov    %esp,%ebp
  80071a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80071d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800720:	50                   	push   %eax
  800721:	ff 75 10             	pushl  0x10(%ebp)
  800724:	ff 75 0c             	pushl  0xc(%ebp)
  800727:	ff 75 08             	pushl  0x8(%ebp)
  80072a:	e8 92 ff ff ff       	call   8006c1 <vsnprintf>
	va_end(ap);

	return rc;
}
  80072f:	c9                   	leave  
  800730:	c3                   	ret    

00800731 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800731:	f3 0f 1e fb          	endbr32 
  800735:	55                   	push   %ebp
  800736:	89 e5                	mov    %esp,%ebp
  800738:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80073b:	b8 00 00 00 00       	mov    $0x0,%eax
  800740:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800744:	74 05                	je     80074b <strlen+0x1a>
		n++;
  800746:	83 c0 01             	add    $0x1,%eax
  800749:	eb f5                	jmp    800740 <strlen+0xf>
	return n;
}
  80074b:	5d                   	pop    %ebp
  80074c:	c3                   	ret    

0080074d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80074d:	f3 0f 1e fb          	endbr32 
  800751:	55                   	push   %ebp
  800752:	89 e5                	mov    %esp,%ebp
  800754:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800757:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075a:	b8 00 00 00 00       	mov    $0x0,%eax
  80075f:	39 d0                	cmp    %edx,%eax
  800761:	74 0d                	je     800770 <strnlen+0x23>
  800763:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800767:	74 05                	je     80076e <strnlen+0x21>
		n++;
  800769:	83 c0 01             	add    $0x1,%eax
  80076c:	eb f1                	jmp    80075f <strnlen+0x12>
  80076e:	89 c2                	mov    %eax,%edx
	return n;
}
  800770:	89 d0                	mov    %edx,%eax
  800772:	5d                   	pop    %ebp
  800773:	c3                   	ret    

00800774 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800774:	f3 0f 1e fb          	endbr32 
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	53                   	push   %ebx
  80077c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800782:	b8 00 00 00 00       	mov    $0x0,%eax
  800787:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80078b:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80078e:	83 c0 01             	add    $0x1,%eax
  800791:	84 d2                	test   %dl,%dl
  800793:	75 f2                	jne    800787 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800795:	89 c8                	mov    %ecx,%eax
  800797:	5b                   	pop    %ebx
  800798:	5d                   	pop    %ebp
  800799:	c3                   	ret    

0080079a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80079a:	f3 0f 1e fb          	endbr32 
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	53                   	push   %ebx
  8007a2:	83 ec 10             	sub    $0x10,%esp
  8007a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a8:	53                   	push   %ebx
  8007a9:	e8 83 ff ff ff       	call   800731 <strlen>
  8007ae:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007b1:	ff 75 0c             	pushl  0xc(%ebp)
  8007b4:	01 d8                	add    %ebx,%eax
  8007b6:	50                   	push   %eax
  8007b7:	e8 b8 ff ff ff       	call   800774 <strcpy>
	return dst;
}
  8007bc:	89 d8                	mov    %ebx,%eax
  8007be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c1:	c9                   	leave  
  8007c2:	c3                   	ret    

008007c3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c3:	f3 0f 1e fb          	endbr32 
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	56                   	push   %esi
  8007cb:	53                   	push   %ebx
  8007cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d2:	89 f3                	mov    %esi,%ebx
  8007d4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d7:	89 f0                	mov    %esi,%eax
  8007d9:	39 d8                	cmp    %ebx,%eax
  8007db:	74 11                	je     8007ee <strncpy+0x2b>
		*dst++ = *src;
  8007dd:	83 c0 01             	add    $0x1,%eax
  8007e0:	0f b6 0a             	movzbl (%edx),%ecx
  8007e3:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e6:	80 f9 01             	cmp    $0x1,%cl
  8007e9:	83 da ff             	sbb    $0xffffffff,%edx
  8007ec:	eb eb                	jmp    8007d9 <strncpy+0x16>
	}
	return ret;
}
  8007ee:	89 f0                	mov    %esi,%eax
  8007f0:	5b                   	pop    %ebx
  8007f1:	5e                   	pop    %esi
  8007f2:	5d                   	pop    %ebp
  8007f3:	c3                   	ret    

008007f4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f4:	f3 0f 1e fb          	endbr32 
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	56                   	push   %esi
  8007fc:	53                   	push   %ebx
  8007fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800800:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800803:	8b 55 10             	mov    0x10(%ebp),%edx
  800806:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800808:	85 d2                	test   %edx,%edx
  80080a:	74 21                	je     80082d <strlcpy+0x39>
  80080c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800810:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800812:	39 c2                	cmp    %eax,%edx
  800814:	74 14                	je     80082a <strlcpy+0x36>
  800816:	0f b6 19             	movzbl (%ecx),%ebx
  800819:	84 db                	test   %bl,%bl
  80081b:	74 0b                	je     800828 <strlcpy+0x34>
			*dst++ = *src++;
  80081d:	83 c1 01             	add    $0x1,%ecx
  800820:	83 c2 01             	add    $0x1,%edx
  800823:	88 5a ff             	mov    %bl,-0x1(%edx)
  800826:	eb ea                	jmp    800812 <strlcpy+0x1e>
  800828:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80082a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80082d:	29 f0                	sub    %esi,%eax
}
  80082f:	5b                   	pop    %ebx
  800830:	5e                   	pop    %esi
  800831:	5d                   	pop    %ebp
  800832:	c3                   	ret    

00800833 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800833:	f3 0f 1e fb          	endbr32 
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800840:	0f b6 01             	movzbl (%ecx),%eax
  800843:	84 c0                	test   %al,%al
  800845:	74 0c                	je     800853 <strcmp+0x20>
  800847:	3a 02                	cmp    (%edx),%al
  800849:	75 08                	jne    800853 <strcmp+0x20>
		p++, q++;
  80084b:	83 c1 01             	add    $0x1,%ecx
  80084e:	83 c2 01             	add    $0x1,%edx
  800851:	eb ed                	jmp    800840 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800853:	0f b6 c0             	movzbl %al,%eax
  800856:	0f b6 12             	movzbl (%edx),%edx
  800859:	29 d0                	sub    %edx,%eax
}
  80085b:	5d                   	pop    %ebp
  80085c:	c3                   	ret    

0080085d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80085d:	f3 0f 1e fb          	endbr32 
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	53                   	push   %ebx
  800865:	8b 45 08             	mov    0x8(%ebp),%eax
  800868:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086b:	89 c3                	mov    %eax,%ebx
  80086d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800870:	eb 06                	jmp    800878 <strncmp+0x1b>
		n--, p++, q++;
  800872:	83 c0 01             	add    $0x1,%eax
  800875:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800878:	39 d8                	cmp    %ebx,%eax
  80087a:	74 16                	je     800892 <strncmp+0x35>
  80087c:	0f b6 08             	movzbl (%eax),%ecx
  80087f:	84 c9                	test   %cl,%cl
  800881:	74 04                	je     800887 <strncmp+0x2a>
  800883:	3a 0a                	cmp    (%edx),%cl
  800885:	74 eb                	je     800872 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800887:	0f b6 00             	movzbl (%eax),%eax
  80088a:	0f b6 12             	movzbl (%edx),%edx
  80088d:	29 d0                	sub    %edx,%eax
}
  80088f:	5b                   	pop    %ebx
  800890:	5d                   	pop    %ebp
  800891:	c3                   	ret    
		return 0;
  800892:	b8 00 00 00 00       	mov    $0x0,%eax
  800897:	eb f6                	jmp    80088f <strncmp+0x32>

00800899 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800899:	f3 0f 1e fb          	endbr32 
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a7:	0f b6 10             	movzbl (%eax),%edx
  8008aa:	84 d2                	test   %dl,%dl
  8008ac:	74 09                	je     8008b7 <strchr+0x1e>
		if (*s == c)
  8008ae:	38 ca                	cmp    %cl,%dl
  8008b0:	74 0a                	je     8008bc <strchr+0x23>
	for (; *s; s++)
  8008b2:	83 c0 01             	add    $0x1,%eax
  8008b5:	eb f0                	jmp    8008a7 <strchr+0xe>
			return (char *) s;
	return 0;
  8008b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008be:	f3 0f 1e fb          	endbr32 
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008cc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008cf:	38 ca                	cmp    %cl,%dl
  8008d1:	74 09                	je     8008dc <strfind+0x1e>
  8008d3:	84 d2                	test   %dl,%dl
  8008d5:	74 05                	je     8008dc <strfind+0x1e>
	for (; *s; s++)
  8008d7:	83 c0 01             	add    $0x1,%eax
  8008da:	eb f0                	jmp    8008cc <strfind+0xe>
			break;
	return (char *) s;
}
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008de:	f3 0f 1e fb          	endbr32 
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	57                   	push   %edi
  8008e6:	56                   	push   %esi
  8008e7:	53                   	push   %ebx
  8008e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ee:	85 c9                	test   %ecx,%ecx
  8008f0:	74 31                	je     800923 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f2:	89 f8                	mov    %edi,%eax
  8008f4:	09 c8                	or     %ecx,%eax
  8008f6:	a8 03                	test   $0x3,%al
  8008f8:	75 23                	jne    80091d <memset+0x3f>
		c &= 0xFF;
  8008fa:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008fe:	89 d3                	mov    %edx,%ebx
  800900:	c1 e3 08             	shl    $0x8,%ebx
  800903:	89 d0                	mov    %edx,%eax
  800905:	c1 e0 18             	shl    $0x18,%eax
  800908:	89 d6                	mov    %edx,%esi
  80090a:	c1 e6 10             	shl    $0x10,%esi
  80090d:	09 f0                	or     %esi,%eax
  80090f:	09 c2                	or     %eax,%edx
  800911:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800913:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800916:	89 d0                	mov    %edx,%eax
  800918:	fc                   	cld    
  800919:	f3 ab                	rep stos %eax,%es:(%edi)
  80091b:	eb 06                	jmp    800923 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800920:	fc                   	cld    
  800921:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800923:	89 f8                	mov    %edi,%eax
  800925:	5b                   	pop    %ebx
  800926:	5e                   	pop    %esi
  800927:	5f                   	pop    %edi
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80092a:	f3 0f 1e fb          	endbr32 
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	57                   	push   %edi
  800932:	56                   	push   %esi
  800933:	8b 45 08             	mov    0x8(%ebp),%eax
  800936:	8b 75 0c             	mov    0xc(%ebp),%esi
  800939:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80093c:	39 c6                	cmp    %eax,%esi
  80093e:	73 32                	jae    800972 <memmove+0x48>
  800940:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800943:	39 c2                	cmp    %eax,%edx
  800945:	76 2b                	jbe    800972 <memmove+0x48>
		s += n;
		d += n;
  800947:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094a:	89 fe                	mov    %edi,%esi
  80094c:	09 ce                	or     %ecx,%esi
  80094e:	09 d6                	or     %edx,%esi
  800950:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800956:	75 0e                	jne    800966 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800958:	83 ef 04             	sub    $0x4,%edi
  80095b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80095e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800961:	fd                   	std    
  800962:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800964:	eb 09                	jmp    80096f <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800966:	83 ef 01             	sub    $0x1,%edi
  800969:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80096c:	fd                   	std    
  80096d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096f:	fc                   	cld    
  800970:	eb 1a                	jmp    80098c <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800972:	89 c2                	mov    %eax,%edx
  800974:	09 ca                	or     %ecx,%edx
  800976:	09 f2                	or     %esi,%edx
  800978:	f6 c2 03             	test   $0x3,%dl
  80097b:	75 0a                	jne    800987 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80097d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800980:	89 c7                	mov    %eax,%edi
  800982:	fc                   	cld    
  800983:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800985:	eb 05                	jmp    80098c <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800987:	89 c7                	mov    %eax,%edi
  800989:	fc                   	cld    
  80098a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098c:	5e                   	pop    %esi
  80098d:	5f                   	pop    %edi
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800990:	f3 0f 1e fb          	endbr32 
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80099a:	ff 75 10             	pushl  0x10(%ebp)
  80099d:	ff 75 0c             	pushl  0xc(%ebp)
  8009a0:	ff 75 08             	pushl  0x8(%ebp)
  8009a3:	e8 82 ff ff ff       	call   80092a <memmove>
}
  8009a8:	c9                   	leave  
  8009a9:	c3                   	ret    

008009aa <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009aa:	f3 0f 1e fb          	endbr32 
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	56                   	push   %esi
  8009b2:	53                   	push   %ebx
  8009b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b9:	89 c6                	mov    %eax,%esi
  8009bb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009be:	39 f0                	cmp    %esi,%eax
  8009c0:	74 1c                	je     8009de <memcmp+0x34>
		if (*s1 != *s2)
  8009c2:	0f b6 08             	movzbl (%eax),%ecx
  8009c5:	0f b6 1a             	movzbl (%edx),%ebx
  8009c8:	38 d9                	cmp    %bl,%cl
  8009ca:	75 08                	jne    8009d4 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009cc:	83 c0 01             	add    $0x1,%eax
  8009cf:	83 c2 01             	add    $0x1,%edx
  8009d2:	eb ea                	jmp    8009be <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  8009d4:	0f b6 c1             	movzbl %cl,%eax
  8009d7:	0f b6 db             	movzbl %bl,%ebx
  8009da:	29 d8                	sub    %ebx,%eax
  8009dc:	eb 05                	jmp    8009e3 <memcmp+0x39>
	}

	return 0;
  8009de:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e3:	5b                   	pop    %ebx
  8009e4:	5e                   	pop    %esi
  8009e5:	5d                   	pop    %ebp
  8009e6:	c3                   	ret    

008009e7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009e7:	f3 0f 1e fb          	endbr32 
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009f4:	89 c2                	mov    %eax,%edx
  8009f6:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009f9:	39 d0                	cmp    %edx,%eax
  8009fb:	73 09                	jae    800a06 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009fd:	38 08                	cmp    %cl,(%eax)
  8009ff:	74 05                	je     800a06 <memfind+0x1f>
	for (; s < ends; s++)
  800a01:	83 c0 01             	add    $0x1,%eax
  800a04:	eb f3                	jmp    8009f9 <memfind+0x12>
			break;
	return (void *) s;
}
  800a06:	5d                   	pop    %ebp
  800a07:	c3                   	ret    

00800a08 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a08:	f3 0f 1e fb          	endbr32 
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	57                   	push   %edi
  800a10:	56                   	push   %esi
  800a11:	53                   	push   %ebx
  800a12:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a15:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a18:	eb 03                	jmp    800a1d <strtol+0x15>
		s++;
  800a1a:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a1d:	0f b6 01             	movzbl (%ecx),%eax
  800a20:	3c 20                	cmp    $0x20,%al
  800a22:	74 f6                	je     800a1a <strtol+0x12>
  800a24:	3c 09                	cmp    $0x9,%al
  800a26:	74 f2                	je     800a1a <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a28:	3c 2b                	cmp    $0x2b,%al
  800a2a:	74 2a                	je     800a56 <strtol+0x4e>
	int neg = 0;
  800a2c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a31:	3c 2d                	cmp    $0x2d,%al
  800a33:	74 2b                	je     800a60 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a35:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a3b:	75 0f                	jne    800a4c <strtol+0x44>
  800a3d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a40:	74 28                	je     800a6a <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a42:	85 db                	test   %ebx,%ebx
  800a44:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a49:	0f 44 d8             	cmove  %eax,%ebx
  800a4c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a51:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a54:	eb 46                	jmp    800a9c <strtol+0x94>
		s++;
  800a56:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a59:	bf 00 00 00 00       	mov    $0x0,%edi
  800a5e:	eb d5                	jmp    800a35 <strtol+0x2d>
		s++, neg = 1;
  800a60:	83 c1 01             	add    $0x1,%ecx
  800a63:	bf 01 00 00 00       	mov    $0x1,%edi
  800a68:	eb cb                	jmp    800a35 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a6a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a6e:	74 0e                	je     800a7e <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a70:	85 db                	test   %ebx,%ebx
  800a72:	75 d8                	jne    800a4c <strtol+0x44>
		s++, base = 8;
  800a74:	83 c1 01             	add    $0x1,%ecx
  800a77:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a7c:	eb ce                	jmp    800a4c <strtol+0x44>
		s += 2, base = 16;
  800a7e:	83 c1 02             	add    $0x2,%ecx
  800a81:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a86:	eb c4                	jmp    800a4c <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a88:	0f be d2             	movsbl %dl,%edx
  800a8b:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a8e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a91:	7d 3a                	jge    800acd <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a93:	83 c1 01             	add    $0x1,%ecx
  800a96:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a9a:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a9c:	0f b6 11             	movzbl (%ecx),%edx
  800a9f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aa2:	89 f3                	mov    %esi,%ebx
  800aa4:	80 fb 09             	cmp    $0x9,%bl
  800aa7:	76 df                	jbe    800a88 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800aa9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aac:	89 f3                	mov    %esi,%ebx
  800aae:	80 fb 19             	cmp    $0x19,%bl
  800ab1:	77 08                	ja     800abb <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ab3:	0f be d2             	movsbl %dl,%edx
  800ab6:	83 ea 57             	sub    $0x57,%edx
  800ab9:	eb d3                	jmp    800a8e <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800abb:	8d 72 bf             	lea    -0x41(%edx),%esi
  800abe:	89 f3                	mov    %esi,%ebx
  800ac0:	80 fb 19             	cmp    $0x19,%bl
  800ac3:	77 08                	ja     800acd <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ac5:	0f be d2             	movsbl %dl,%edx
  800ac8:	83 ea 37             	sub    $0x37,%edx
  800acb:	eb c1                	jmp    800a8e <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800acd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad1:	74 05                	je     800ad8 <strtol+0xd0>
		*endptr = (char *) s;
  800ad3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad6:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ad8:	89 c2                	mov    %eax,%edx
  800ada:	f7 da                	neg    %edx
  800adc:	85 ff                	test   %edi,%edi
  800ade:	0f 45 c2             	cmovne %edx,%eax
}
  800ae1:	5b                   	pop    %ebx
  800ae2:	5e                   	pop    %esi
  800ae3:	5f                   	pop    %edi
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ae6:	f3 0f 1e fb          	endbr32 
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	57                   	push   %edi
  800aee:	56                   	push   %esi
  800aef:	53                   	push   %ebx
	asm volatile("int %1\n"
  800af0:	b8 00 00 00 00       	mov    $0x0,%eax
  800af5:	8b 55 08             	mov    0x8(%ebp),%edx
  800af8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800afb:	89 c3                	mov    %eax,%ebx
  800afd:	89 c7                	mov    %eax,%edi
  800aff:	89 c6                	mov    %eax,%esi
  800b01:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b03:	5b                   	pop    %ebx
  800b04:	5e                   	pop    %esi
  800b05:	5f                   	pop    %edi
  800b06:	5d                   	pop    %ebp
  800b07:	c3                   	ret    

00800b08 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b08:	f3 0f 1e fb          	endbr32 
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	57                   	push   %edi
  800b10:	56                   	push   %esi
  800b11:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b12:	ba 00 00 00 00       	mov    $0x0,%edx
  800b17:	b8 01 00 00 00       	mov    $0x1,%eax
  800b1c:	89 d1                	mov    %edx,%ecx
  800b1e:	89 d3                	mov    %edx,%ebx
  800b20:	89 d7                	mov    %edx,%edi
  800b22:	89 d6                	mov    %edx,%esi
  800b24:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b26:	5b                   	pop    %ebx
  800b27:	5e                   	pop    %esi
  800b28:	5f                   	pop    %edi
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b2b:	f3 0f 1e fb          	endbr32 
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
  800b35:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b38:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b40:	b8 03 00 00 00       	mov    $0x3,%eax
  800b45:	89 cb                	mov    %ecx,%ebx
  800b47:	89 cf                	mov    %ecx,%edi
  800b49:	89 ce                	mov    %ecx,%esi
  800b4b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b4d:	85 c0                	test   %eax,%eax
  800b4f:	7f 08                	jg     800b59 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b54:	5b                   	pop    %ebx
  800b55:	5e                   	pop    %esi
  800b56:	5f                   	pop    %edi
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b59:	83 ec 0c             	sub    $0xc,%esp
  800b5c:	50                   	push   %eax
  800b5d:	6a 03                	push   $0x3
  800b5f:	68 7f 13 80 00       	push   $0x80137f
  800b64:	6a 23                	push   $0x23
  800b66:	68 9c 13 80 00       	push   $0x80139c
  800b6b:	e8 36 02 00 00       	call   800da6 <_panic>

00800b70 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b70:	f3 0f 1e fb          	endbr32 
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	57                   	push   %edi
  800b78:	56                   	push   %esi
  800b79:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7f:	b8 02 00 00 00       	mov    $0x2,%eax
  800b84:	89 d1                	mov    %edx,%ecx
  800b86:	89 d3                	mov    %edx,%ebx
  800b88:	89 d7                	mov    %edx,%edi
  800b8a:	89 d6                	mov    %edx,%esi
  800b8c:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b8e:	5b                   	pop    %ebx
  800b8f:	5e                   	pop    %esi
  800b90:	5f                   	pop    %edi
  800b91:	5d                   	pop    %ebp
  800b92:	c3                   	ret    

00800b93 <sys_yield>:

void
sys_yield(void)
{
  800b93:	f3 0f 1e fb          	endbr32 
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	57                   	push   %edi
  800b9b:	56                   	push   %esi
  800b9c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba2:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ba7:	89 d1                	mov    %edx,%ecx
  800ba9:	89 d3                	mov    %edx,%ebx
  800bab:	89 d7                	mov    %edx,%edi
  800bad:	89 d6                	mov    %edx,%esi
  800baf:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5f                   	pop    %edi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bb6:	f3 0f 1e fb          	endbr32 
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	57                   	push   %edi
  800bbe:	56                   	push   %esi
  800bbf:	53                   	push   %ebx
  800bc0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bc3:	be 00 00 00 00       	mov    $0x0,%esi
  800bc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bce:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd6:	89 f7                	mov    %esi,%edi
  800bd8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bda:	85 c0                	test   %eax,%eax
  800bdc:	7f 08                	jg     800be6 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be1:	5b                   	pop    %ebx
  800be2:	5e                   	pop    %esi
  800be3:	5f                   	pop    %edi
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800be6:	83 ec 0c             	sub    $0xc,%esp
  800be9:	50                   	push   %eax
  800bea:	6a 04                	push   $0x4
  800bec:	68 7f 13 80 00       	push   $0x80137f
  800bf1:	6a 23                	push   $0x23
  800bf3:	68 9c 13 80 00       	push   $0x80139c
  800bf8:	e8 a9 01 00 00       	call   800da6 <_panic>

00800bfd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bfd:	f3 0f 1e fb          	endbr32 
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	57                   	push   %edi
  800c05:	56                   	push   %esi
  800c06:	53                   	push   %ebx
  800c07:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c10:	b8 05 00 00 00       	mov    $0x5,%eax
  800c15:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c18:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c1b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c1e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c20:	85 c0                	test   %eax,%eax
  800c22:	7f 08                	jg     800c2c <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c27:	5b                   	pop    %ebx
  800c28:	5e                   	pop    %esi
  800c29:	5f                   	pop    %edi
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2c:	83 ec 0c             	sub    $0xc,%esp
  800c2f:	50                   	push   %eax
  800c30:	6a 05                	push   $0x5
  800c32:	68 7f 13 80 00       	push   $0x80137f
  800c37:	6a 23                	push   $0x23
  800c39:	68 9c 13 80 00       	push   $0x80139c
  800c3e:	e8 63 01 00 00       	call   800da6 <_panic>

00800c43 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c43:	f3 0f 1e fb          	endbr32 
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
  800c4d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c55:	8b 55 08             	mov    0x8(%ebp),%edx
  800c58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5b:	b8 06 00 00 00       	mov    $0x6,%eax
  800c60:	89 df                	mov    %ebx,%edi
  800c62:	89 de                	mov    %ebx,%esi
  800c64:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c66:	85 c0                	test   %eax,%eax
  800c68:	7f 08                	jg     800c72 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6d:	5b                   	pop    %ebx
  800c6e:	5e                   	pop    %esi
  800c6f:	5f                   	pop    %edi
  800c70:	5d                   	pop    %ebp
  800c71:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c72:	83 ec 0c             	sub    $0xc,%esp
  800c75:	50                   	push   %eax
  800c76:	6a 06                	push   $0x6
  800c78:	68 7f 13 80 00       	push   $0x80137f
  800c7d:	6a 23                	push   $0x23
  800c7f:	68 9c 13 80 00       	push   $0x80139c
  800c84:	e8 1d 01 00 00       	call   800da6 <_panic>

00800c89 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c89:	f3 0f 1e fb          	endbr32 
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	57                   	push   %edi
  800c91:	56                   	push   %esi
  800c92:	53                   	push   %ebx
  800c93:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c96:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca1:	b8 08 00 00 00       	mov    $0x8,%eax
  800ca6:	89 df                	mov    %ebx,%edi
  800ca8:	89 de                	mov    %ebx,%esi
  800caa:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cac:	85 c0                	test   %eax,%eax
  800cae:	7f 08                	jg     800cb8 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb3:	5b                   	pop    %ebx
  800cb4:	5e                   	pop    %esi
  800cb5:	5f                   	pop    %edi
  800cb6:	5d                   	pop    %ebp
  800cb7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb8:	83 ec 0c             	sub    $0xc,%esp
  800cbb:	50                   	push   %eax
  800cbc:	6a 08                	push   $0x8
  800cbe:	68 7f 13 80 00       	push   $0x80137f
  800cc3:	6a 23                	push   $0x23
  800cc5:	68 9c 13 80 00       	push   $0x80139c
  800cca:	e8 d7 00 00 00       	call   800da6 <_panic>

00800ccf <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ccf:	f3 0f 1e fb          	endbr32 
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	57                   	push   %edi
  800cd7:	56                   	push   %esi
  800cd8:	53                   	push   %ebx
  800cd9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cdc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce7:	b8 09 00 00 00       	mov    $0x9,%eax
  800cec:	89 df                	mov    %ebx,%edi
  800cee:	89 de                	mov    %ebx,%esi
  800cf0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf2:	85 c0                	test   %eax,%eax
  800cf4:	7f 08                	jg     800cfe <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfe:	83 ec 0c             	sub    $0xc,%esp
  800d01:	50                   	push   %eax
  800d02:	6a 09                	push   $0x9
  800d04:	68 7f 13 80 00       	push   $0x80137f
  800d09:	6a 23                	push   $0x23
  800d0b:	68 9c 13 80 00       	push   $0x80139c
  800d10:	e8 91 00 00 00       	call   800da6 <_panic>

00800d15 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d15:	f3 0f 1e fb          	endbr32 
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	57                   	push   %edi
  800d1d:	56                   	push   %esi
  800d1e:	53                   	push   %ebx
  800d1f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d22:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d27:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d32:	89 df                	mov    %ebx,%edi
  800d34:	89 de                	mov    %ebx,%esi
  800d36:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d38:	85 c0                	test   %eax,%eax
  800d3a:	7f 08                	jg     800d44 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3f:	5b                   	pop    %ebx
  800d40:	5e                   	pop    %esi
  800d41:	5f                   	pop    %edi
  800d42:	5d                   	pop    %ebp
  800d43:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d44:	83 ec 0c             	sub    $0xc,%esp
  800d47:	50                   	push   %eax
  800d48:	6a 0a                	push   $0xa
  800d4a:	68 7f 13 80 00       	push   $0x80137f
  800d4f:	6a 23                	push   $0x23
  800d51:	68 9c 13 80 00       	push   $0x80139c
  800d56:	e8 4b 00 00 00       	call   800da6 <_panic>

00800d5b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d5b:	f3 0f 1e fb          	endbr32 
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	57                   	push   %edi
  800d63:	56                   	push   %esi
  800d64:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d65:	8b 55 08             	mov    0x8(%ebp),%edx
  800d68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d70:	be 00 00 00 00       	mov    $0x0,%esi
  800d75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d78:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d7b:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d7d:	5b                   	pop    %ebx
  800d7e:	5e                   	pop    %esi
  800d7f:	5f                   	pop    %edi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    

00800d82 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d82:	f3 0f 1e fb          	endbr32 
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	57                   	push   %edi
  800d8a:	56                   	push   %esi
  800d8b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d8c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d91:	8b 55 08             	mov    0x8(%ebp),%edx
  800d94:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d99:	89 cb                	mov    %ecx,%ebx
  800d9b:	89 cf                	mov    %ecx,%edi
  800d9d:	89 ce                	mov    %ecx,%esi
  800d9f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 0, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da1:	5b                   	pop    %ebx
  800da2:	5e                   	pop    %esi
  800da3:	5f                   	pop    %edi
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    

00800da6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800da6:	f3 0f 1e fb          	endbr32 
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	56                   	push   %esi
  800dae:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800daf:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800db2:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800db8:	e8 b3 fd ff ff       	call   800b70 <sys_getenvid>
  800dbd:	83 ec 0c             	sub    $0xc,%esp
  800dc0:	ff 75 0c             	pushl  0xc(%ebp)
  800dc3:	ff 75 08             	pushl  0x8(%ebp)
  800dc6:	56                   	push   %esi
  800dc7:	50                   	push   %eax
  800dc8:	68 ac 13 80 00       	push   $0x8013ac
  800dcd:	e8 99 f3 ff ff       	call   80016b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800dd2:	83 c4 18             	add    $0x18,%esp
  800dd5:	53                   	push   %ebx
  800dd6:	ff 75 10             	pushl  0x10(%ebp)
  800dd9:	e8 38 f3 ff ff       	call   800116 <vcprintf>
	cprintf("\n");
  800dde:	c7 04 24 6c 10 80 00 	movl   $0x80106c,(%esp)
  800de5:	e8 81 f3 ff ff       	call   80016b <cprintf>
  800dea:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800ded:	cc                   	int3   
  800dee:	eb fd                	jmp    800ded <_panic+0x47>

00800df0 <__udivdi3>:
  800df0:	f3 0f 1e fb          	endbr32 
  800df4:	55                   	push   %ebp
  800df5:	57                   	push   %edi
  800df6:	56                   	push   %esi
  800df7:	53                   	push   %ebx
  800df8:	83 ec 1c             	sub    $0x1c,%esp
  800dfb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800dff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e03:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e07:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e0b:	85 d2                	test   %edx,%edx
  800e0d:	75 19                	jne    800e28 <__udivdi3+0x38>
  800e0f:	39 f3                	cmp    %esi,%ebx
  800e11:	76 4d                	jbe    800e60 <__udivdi3+0x70>
  800e13:	31 ff                	xor    %edi,%edi
  800e15:	89 e8                	mov    %ebp,%eax
  800e17:	89 f2                	mov    %esi,%edx
  800e19:	f7 f3                	div    %ebx
  800e1b:	89 fa                	mov    %edi,%edx
  800e1d:	83 c4 1c             	add    $0x1c,%esp
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    
  800e25:	8d 76 00             	lea    0x0(%esi),%esi
  800e28:	39 f2                	cmp    %esi,%edx
  800e2a:	76 14                	jbe    800e40 <__udivdi3+0x50>
  800e2c:	31 ff                	xor    %edi,%edi
  800e2e:	31 c0                	xor    %eax,%eax
  800e30:	89 fa                	mov    %edi,%edx
  800e32:	83 c4 1c             	add    $0x1c,%esp
  800e35:	5b                   	pop    %ebx
  800e36:	5e                   	pop    %esi
  800e37:	5f                   	pop    %edi
  800e38:	5d                   	pop    %ebp
  800e39:	c3                   	ret    
  800e3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e40:	0f bd fa             	bsr    %edx,%edi
  800e43:	83 f7 1f             	xor    $0x1f,%edi
  800e46:	75 48                	jne    800e90 <__udivdi3+0xa0>
  800e48:	39 f2                	cmp    %esi,%edx
  800e4a:	72 06                	jb     800e52 <__udivdi3+0x62>
  800e4c:	31 c0                	xor    %eax,%eax
  800e4e:	39 eb                	cmp    %ebp,%ebx
  800e50:	77 de                	ja     800e30 <__udivdi3+0x40>
  800e52:	b8 01 00 00 00       	mov    $0x1,%eax
  800e57:	eb d7                	jmp    800e30 <__udivdi3+0x40>
  800e59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e60:	89 d9                	mov    %ebx,%ecx
  800e62:	85 db                	test   %ebx,%ebx
  800e64:	75 0b                	jne    800e71 <__udivdi3+0x81>
  800e66:	b8 01 00 00 00       	mov    $0x1,%eax
  800e6b:	31 d2                	xor    %edx,%edx
  800e6d:	f7 f3                	div    %ebx
  800e6f:	89 c1                	mov    %eax,%ecx
  800e71:	31 d2                	xor    %edx,%edx
  800e73:	89 f0                	mov    %esi,%eax
  800e75:	f7 f1                	div    %ecx
  800e77:	89 c6                	mov    %eax,%esi
  800e79:	89 e8                	mov    %ebp,%eax
  800e7b:	89 f7                	mov    %esi,%edi
  800e7d:	f7 f1                	div    %ecx
  800e7f:	89 fa                	mov    %edi,%edx
  800e81:	83 c4 1c             	add    $0x1c,%esp
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    
  800e89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e90:	89 f9                	mov    %edi,%ecx
  800e92:	b8 20 00 00 00       	mov    $0x20,%eax
  800e97:	29 f8                	sub    %edi,%eax
  800e99:	d3 e2                	shl    %cl,%edx
  800e9b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e9f:	89 c1                	mov    %eax,%ecx
  800ea1:	89 da                	mov    %ebx,%edx
  800ea3:	d3 ea                	shr    %cl,%edx
  800ea5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ea9:	09 d1                	or     %edx,%ecx
  800eab:	89 f2                	mov    %esi,%edx
  800ead:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800eb1:	89 f9                	mov    %edi,%ecx
  800eb3:	d3 e3                	shl    %cl,%ebx
  800eb5:	89 c1                	mov    %eax,%ecx
  800eb7:	d3 ea                	shr    %cl,%edx
  800eb9:	89 f9                	mov    %edi,%ecx
  800ebb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ebf:	89 eb                	mov    %ebp,%ebx
  800ec1:	d3 e6                	shl    %cl,%esi
  800ec3:	89 c1                	mov    %eax,%ecx
  800ec5:	d3 eb                	shr    %cl,%ebx
  800ec7:	09 de                	or     %ebx,%esi
  800ec9:	89 f0                	mov    %esi,%eax
  800ecb:	f7 74 24 08          	divl   0x8(%esp)
  800ecf:	89 d6                	mov    %edx,%esi
  800ed1:	89 c3                	mov    %eax,%ebx
  800ed3:	f7 64 24 0c          	mull   0xc(%esp)
  800ed7:	39 d6                	cmp    %edx,%esi
  800ed9:	72 15                	jb     800ef0 <__udivdi3+0x100>
  800edb:	89 f9                	mov    %edi,%ecx
  800edd:	d3 e5                	shl    %cl,%ebp
  800edf:	39 c5                	cmp    %eax,%ebp
  800ee1:	73 04                	jae    800ee7 <__udivdi3+0xf7>
  800ee3:	39 d6                	cmp    %edx,%esi
  800ee5:	74 09                	je     800ef0 <__udivdi3+0x100>
  800ee7:	89 d8                	mov    %ebx,%eax
  800ee9:	31 ff                	xor    %edi,%edi
  800eeb:	e9 40 ff ff ff       	jmp    800e30 <__udivdi3+0x40>
  800ef0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800ef3:	31 ff                	xor    %edi,%edi
  800ef5:	e9 36 ff ff ff       	jmp    800e30 <__udivdi3+0x40>
  800efa:	66 90                	xchg   %ax,%ax
  800efc:	66 90                	xchg   %ax,%ax
  800efe:	66 90                	xchg   %ax,%ax

00800f00 <__umoddi3>:
  800f00:	f3 0f 1e fb          	endbr32 
  800f04:	55                   	push   %ebp
  800f05:	57                   	push   %edi
  800f06:	56                   	push   %esi
  800f07:	53                   	push   %ebx
  800f08:	83 ec 1c             	sub    $0x1c,%esp
  800f0b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800f0f:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f13:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f17:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f1b:	85 c0                	test   %eax,%eax
  800f1d:	75 19                	jne    800f38 <__umoddi3+0x38>
  800f1f:	39 df                	cmp    %ebx,%edi
  800f21:	76 5d                	jbe    800f80 <__umoddi3+0x80>
  800f23:	89 f0                	mov    %esi,%eax
  800f25:	89 da                	mov    %ebx,%edx
  800f27:	f7 f7                	div    %edi
  800f29:	89 d0                	mov    %edx,%eax
  800f2b:	31 d2                	xor    %edx,%edx
  800f2d:	83 c4 1c             	add    $0x1c,%esp
  800f30:	5b                   	pop    %ebx
  800f31:	5e                   	pop    %esi
  800f32:	5f                   	pop    %edi
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    
  800f35:	8d 76 00             	lea    0x0(%esi),%esi
  800f38:	89 f2                	mov    %esi,%edx
  800f3a:	39 d8                	cmp    %ebx,%eax
  800f3c:	76 12                	jbe    800f50 <__umoddi3+0x50>
  800f3e:	89 f0                	mov    %esi,%eax
  800f40:	89 da                	mov    %ebx,%edx
  800f42:	83 c4 1c             	add    $0x1c,%esp
  800f45:	5b                   	pop    %ebx
  800f46:	5e                   	pop    %esi
  800f47:	5f                   	pop    %edi
  800f48:	5d                   	pop    %ebp
  800f49:	c3                   	ret    
  800f4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f50:	0f bd e8             	bsr    %eax,%ebp
  800f53:	83 f5 1f             	xor    $0x1f,%ebp
  800f56:	75 50                	jne    800fa8 <__umoddi3+0xa8>
  800f58:	39 d8                	cmp    %ebx,%eax
  800f5a:	0f 82 e0 00 00 00    	jb     801040 <__umoddi3+0x140>
  800f60:	89 d9                	mov    %ebx,%ecx
  800f62:	39 f7                	cmp    %esi,%edi
  800f64:	0f 86 d6 00 00 00    	jbe    801040 <__umoddi3+0x140>
  800f6a:	89 d0                	mov    %edx,%eax
  800f6c:	89 ca                	mov    %ecx,%edx
  800f6e:	83 c4 1c             	add    $0x1c,%esp
  800f71:	5b                   	pop    %ebx
  800f72:	5e                   	pop    %esi
  800f73:	5f                   	pop    %edi
  800f74:	5d                   	pop    %ebp
  800f75:	c3                   	ret    
  800f76:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f7d:	8d 76 00             	lea    0x0(%esi),%esi
  800f80:	89 fd                	mov    %edi,%ebp
  800f82:	85 ff                	test   %edi,%edi
  800f84:	75 0b                	jne    800f91 <__umoddi3+0x91>
  800f86:	b8 01 00 00 00       	mov    $0x1,%eax
  800f8b:	31 d2                	xor    %edx,%edx
  800f8d:	f7 f7                	div    %edi
  800f8f:	89 c5                	mov    %eax,%ebp
  800f91:	89 d8                	mov    %ebx,%eax
  800f93:	31 d2                	xor    %edx,%edx
  800f95:	f7 f5                	div    %ebp
  800f97:	89 f0                	mov    %esi,%eax
  800f99:	f7 f5                	div    %ebp
  800f9b:	89 d0                	mov    %edx,%eax
  800f9d:	31 d2                	xor    %edx,%edx
  800f9f:	eb 8c                	jmp    800f2d <__umoddi3+0x2d>
  800fa1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fa8:	89 e9                	mov    %ebp,%ecx
  800faa:	ba 20 00 00 00       	mov    $0x20,%edx
  800faf:	29 ea                	sub    %ebp,%edx
  800fb1:	d3 e0                	shl    %cl,%eax
  800fb3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fb7:	89 d1                	mov    %edx,%ecx
  800fb9:	89 f8                	mov    %edi,%eax
  800fbb:	d3 e8                	shr    %cl,%eax
  800fbd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800fc1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fc5:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fc9:	09 c1                	or     %eax,%ecx
  800fcb:	89 d8                	mov    %ebx,%eax
  800fcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fd1:	89 e9                	mov    %ebp,%ecx
  800fd3:	d3 e7                	shl    %cl,%edi
  800fd5:	89 d1                	mov    %edx,%ecx
  800fd7:	d3 e8                	shr    %cl,%eax
  800fd9:	89 e9                	mov    %ebp,%ecx
  800fdb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fdf:	d3 e3                	shl    %cl,%ebx
  800fe1:	89 c7                	mov    %eax,%edi
  800fe3:	89 d1                	mov    %edx,%ecx
  800fe5:	89 f0                	mov    %esi,%eax
  800fe7:	d3 e8                	shr    %cl,%eax
  800fe9:	89 e9                	mov    %ebp,%ecx
  800feb:	89 fa                	mov    %edi,%edx
  800fed:	d3 e6                	shl    %cl,%esi
  800fef:	09 d8                	or     %ebx,%eax
  800ff1:	f7 74 24 08          	divl   0x8(%esp)
  800ff5:	89 d1                	mov    %edx,%ecx
  800ff7:	89 f3                	mov    %esi,%ebx
  800ff9:	f7 64 24 0c          	mull   0xc(%esp)
  800ffd:	89 c6                	mov    %eax,%esi
  800fff:	89 d7                	mov    %edx,%edi
  801001:	39 d1                	cmp    %edx,%ecx
  801003:	72 06                	jb     80100b <__umoddi3+0x10b>
  801005:	75 10                	jne    801017 <__umoddi3+0x117>
  801007:	39 c3                	cmp    %eax,%ebx
  801009:	73 0c                	jae    801017 <__umoddi3+0x117>
  80100b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80100f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801013:	89 d7                	mov    %edx,%edi
  801015:	89 c6                	mov    %eax,%esi
  801017:	89 ca                	mov    %ecx,%edx
  801019:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80101e:	29 f3                	sub    %esi,%ebx
  801020:	19 fa                	sbb    %edi,%edx
  801022:	89 d0                	mov    %edx,%eax
  801024:	d3 e0                	shl    %cl,%eax
  801026:	89 e9                	mov    %ebp,%ecx
  801028:	d3 eb                	shr    %cl,%ebx
  80102a:	d3 ea                	shr    %cl,%edx
  80102c:	09 d8                	or     %ebx,%eax
  80102e:	83 c4 1c             	add    $0x1c,%esp
  801031:	5b                   	pop    %ebx
  801032:	5e                   	pop    %esi
  801033:	5f                   	pop    %edi
  801034:	5d                   	pop    %ebp
  801035:	c3                   	ret    
  801036:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80103d:	8d 76 00             	lea    0x0(%esi),%esi
  801040:	29 fe                	sub    %edi,%esi
  801042:	19 c3                	sbb    %eax,%ebx
  801044:	89 f2                	mov    %esi,%edx
  801046:	89 d9                	mov    %ebx,%ecx
  801048:	e9 1d ff ff ff       	jmp    800f6a <__umoddi3+0x6a>
