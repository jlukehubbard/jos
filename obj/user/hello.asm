
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 31 00 00 00       	call   800062 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  80003d:	68 60 10 80 00       	push   $0x801060
  800042:	e8 22 01 00 00       	call   800169 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800047:	a1 04 20 80 00       	mov    0x802004,%eax
  80004c:	8b 40 48             	mov    0x48(%eax),%eax
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	50                   	push   %eax
  800053:	68 6e 10 80 00       	push   $0x80106e
  800058:	e8 0c 01 00 00       	call   800169 <cprintf>
}
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	c9                   	leave  
  800061:	c3                   	ret    

00800062 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800062:	f3 0f 1e fb          	endbr32 
  800066:	55                   	push   %ebp
  800067:	89 e5                	mov    %esp,%ebp
  800069:	56                   	push   %esi
  80006a:	53                   	push   %ebx
  80006b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800071:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800078:	00 00 00 
    envid_t envid = sys_getenvid();
  80007b:	e8 ee 0a 00 00       	call   800b6e <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  800080:	25 ff 03 00 00       	and    $0x3ff,%eax
  800085:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800088:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008d:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800092:	85 db                	test   %ebx,%ebx
  800094:	7e 07                	jle    80009d <libmain+0x3b>
		binaryname = argv[0];
  800096:	8b 06                	mov    (%esi),%eax
  800098:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80009d:	83 ec 08             	sub    $0x8,%esp
  8000a0:	56                   	push   %esi
  8000a1:	53                   	push   %ebx
  8000a2:	e8 8c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a7:	e8 0a 00 00 00       	call   8000b6 <exit>
}
  8000ac:	83 c4 10             	add    $0x10,%esp
  8000af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000b2:	5b                   	pop    %ebx
  8000b3:	5e                   	pop    %esi
  8000b4:	5d                   	pop    %ebp
  8000b5:	c3                   	ret    

008000b6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b6:	f3 0f 1e fb          	endbr32 
  8000ba:	55                   	push   %ebp
  8000bb:	89 e5                	mov    %esp,%ebp
  8000bd:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  8000c0:	6a 00                	push   $0x0
  8000c2:	e8 62 0a 00 00       	call   800b29 <sys_env_destroy>
}
  8000c7:	83 c4 10             	add    $0x10,%esp
  8000ca:	c9                   	leave  
  8000cb:	c3                   	ret    

008000cc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000cc:	f3 0f 1e fb          	endbr32 
  8000d0:	55                   	push   %ebp
  8000d1:	89 e5                	mov    %esp,%ebp
  8000d3:	53                   	push   %ebx
  8000d4:	83 ec 04             	sub    $0x4,%esp
  8000d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000da:	8b 13                	mov    (%ebx),%edx
  8000dc:	8d 42 01             	lea    0x1(%edx),%eax
  8000df:	89 03                	mov    %eax,(%ebx)
  8000e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000e8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ed:	74 09                	je     8000f8 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000ef:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f6:	c9                   	leave  
  8000f7:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000f8:	83 ec 08             	sub    $0x8,%esp
  8000fb:	68 ff 00 00 00       	push   $0xff
  800100:	8d 43 08             	lea    0x8(%ebx),%eax
  800103:	50                   	push   %eax
  800104:	e8 db 09 00 00       	call   800ae4 <sys_cputs>
		b->idx = 0;
  800109:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb db                	jmp    8000ef <putch+0x23>

00800114 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800114:	f3 0f 1e fb          	endbr32 
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800121:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800128:	00 00 00 
	b.cnt = 0;
  80012b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800132:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800135:	ff 75 0c             	pushl  0xc(%ebp)
  800138:	ff 75 08             	pushl  0x8(%ebp)
  80013b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800141:	50                   	push   %eax
  800142:	68 cc 00 80 00       	push   $0x8000cc
  800147:	e8 20 01 00 00       	call   80026c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80014c:	83 c4 08             	add    $0x8,%esp
  80014f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800155:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80015b:	50                   	push   %eax
  80015c:	e8 83 09 00 00       	call   800ae4 <sys_cputs>

	return b.cnt;
}
  800161:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800167:	c9                   	leave  
  800168:	c3                   	ret    

00800169 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800169:	f3 0f 1e fb          	endbr32 
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800173:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800176:	50                   	push   %eax
  800177:	ff 75 08             	pushl  0x8(%ebp)
  80017a:	e8 95 ff ff ff       	call   800114 <vcprintf>
	va_end(ap);

	return cnt;
}
  80017f:	c9                   	leave  
  800180:	c3                   	ret    

00800181 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	57                   	push   %edi
  800185:	56                   	push   %esi
  800186:	53                   	push   %ebx
  800187:	83 ec 1c             	sub    $0x1c,%esp
  80018a:	89 c7                	mov    %eax,%edi
  80018c:	89 d6                	mov    %edx,%esi
  80018e:	8b 45 08             	mov    0x8(%ebp),%eax
  800191:	8b 55 0c             	mov    0xc(%ebp),%edx
  800194:	89 d1                	mov    %edx,%ecx
  800196:	89 c2                	mov    %eax,%edx
  800198:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80019b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80019e:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a1:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001a7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001ae:	39 c2                	cmp    %eax,%edx
  8001b0:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001b3:	72 3e                	jb     8001f3 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b5:	83 ec 0c             	sub    $0xc,%esp
  8001b8:	ff 75 18             	pushl  0x18(%ebp)
  8001bb:	83 eb 01             	sub    $0x1,%ebx
  8001be:	53                   	push   %ebx
  8001bf:	50                   	push   %eax
  8001c0:	83 ec 08             	sub    $0x8,%esp
  8001c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8001c9:	ff 75 dc             	pushl  -0x24(%ebp)
  8001cc:	ff 75 d8             	pushl  -0x28(%ebp)
  8001cf:	e8 1c 0c 00 00       	call   800df0 <__udivdi3>
  8001d4:	83 c4 18             	add    $0x18,%esp
  8001d7:	52                   	push   %edx
  8001d8:	50                   	push   %eax
  8001d9:	89 f2                	mov    %esi,%edx
  8001db:	89 f8                	mov    %edi,%eax
  8001dd:	e8 9f ff ff ff       	call   800181 <printnum>
  8001e2:	83 c4 20             	add    $0x20,%esp
  8001e5:	eb 13                	jmp    8001fa <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001e7:	83 ec 08             	sub    $0x8,%esp
  8001ea:	56                   	push   %esi
  8001eb:	ff 75 18             	pushl  0x18(%ebp)
  8001ee:	ff d7                	call   *%edi
  8001f0:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001f3:	83 eb 01             	sub    $0x1,%ebx
  8001f6:	85 db                	test   %ebx,%ebx
  8001f8:	7f ed                	jg     8001e7 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001fa:	83 ec 08             	sub    $0x8,%esp
  8001fd:	56                   	push   %esi
  8001fe:	83 ec 04             	sub    $0x4,%esp
  800201:	ff 75 e4             	pushl  -0x1c(%ebp)
  800204:	ff 75 e0             	pushl  -0x20(%ebp)
  800207:	ff 75 dc             	pushl  -0x24(%ebp)
  80020a:	ff 75 d8             	pushl  -0x28(%ebp)
  80020d:	e8 ee 0c 00 00       	call   800f00 <__umoddi3>
  800212:	83 c4 14             	add    $0x14,%esp
  800215:	0f be 80 8f 10 80 00 	movsbl 0x80108f(%eax),%eax
  80021c:	50                   	push   %eax
  80021d:	ff d7                	call   *%edi
}
  80021f:	83 c4 10             	add    $0x10,%esp
  800222:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800225:	5b                   	pop    %ebx
  800226:	5e                   	pop    %esi
  800227:	5f                   	pop    %edi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80022a:	f3 0f 1e fb          	endbr32 
  80022e:	55                   	push   %ebp
  80022f:	89 e5                	mov    %esp,%ebp
  800231:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800234:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800238:	8b 10                	mov    (%eax),%edx
  80023a:	3b 50 04             	cmp    0x4(%eax),%edx
  80023d:	73 0a                	jae    800249 <sprintputch+0x1f>
		*b->buf++ = ch;
  80023f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800242:	89 08                	mov    %ecx,(%eax)
  800244:	8b 45 08             	mov    0x8(%ebp),%eax
  800247:	88 02                	mov    %al,(%edx)
}
  800249:	5d                   	pop    %ebp
  80024a:	c3                   	ret    

0080024b <printfmt>:
{
  80024b:	f3 0f 1e fb          	endbr32 
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
  800252:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800255:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800258:	50                   	push   %eax
  800259:	ff 75 10             	pushl  0x10(%ebp)
  80025c:	ff 75 0c             	pushl  0xc(%ebp)
  80025f:	ff 75 08             	pushl  0x8(%ebp)
  800262:	e8 05 00 00 00       	call   80026c <vprintfmt>
}
  800267:	83 c4 10             	add    $0x10,%esp
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <vprintfmt>:
{
  80026c:	f3 0f 1e fb          	endbr32 
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	57                   	push   %edi
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	83 ec 3c             	sub    $0x3c,%esp
  800279:	8b 75 08             	mov    0x8(%ebp),%esi
  80027c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80027f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800282:	e9 4a 03 00 00       	jmp    8005d1 <vprintfmt+0x365>
		padc = ' ';
  800287:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80028b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800292:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800299:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002a0:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002a5:	8d 47 01             	lea    0x1(%edi),%eax
  8002a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ab:	0f b6 17             	movzbl (%edi),%edx
  8002ae:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002b1:	3c 55                	cmp    $0x55,%al
  8002b3:	0f 87 de 03 00 00    	ja     800697 <vprintfmt+0x42b>
  8002b9:	0f b6 c0             	movzbl %al,%eax
  8002bc:	3e ff 24 85 e0 11 80 	notrack jmp *0x8011e0(,%eax,4)
  8002c3:	00 
  8002c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002c7:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002cb:	eb d8                	jmp    8002a5 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8002cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002d0:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002d4:	eb cf                	jmp    8002a5 <vprintfmt+0x39>
  8002d6:	0f b6 d2             	movzbl %dl,%edx
  8002d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8002e1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002e4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002e7:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002eb:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002ee:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002f1:	83 f9 09             	cmp    $0x9,%ecx
  8002f4:	77 55                	ja     80034b <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8002f6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002f9:	eb e9                	jmp    8002e4 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8002fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8002fe:	8b 00                	mov    (%eax),%eax
  800300:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800303:	8b 45 14             	mov    0x14(%ebp),%eax
  800306:	8d 40 04             	lea    0x4(%eax),%eax
  800309:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80030c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80030f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800313:	79 90                	jns    8002a5 <vprintfmt+0x39>
				width = precision, precision = -1;
  800315:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800318:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80031b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800322:	eb 81                	jmp    8002a5 <vprintfmt+0x39>
  800324:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800327:	85 c0                	test   %eax,%eax
  800329:	ba 00 00 00 00       	mov    $0x0,%edx
  80032e:	0f 49 d0             	cmovns %eax,%edx
  800331:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800334:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800337:	e9 69 ff ff ff       	jmp    8002a5 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80033c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80033f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800346:	e9 5a ff ff ff       	jmp    8002a5 <vprintfmt+0x39>
  80034b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80034e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800351:	eb bc                	jmp    80030f <vprintfmt+0xa3>
			lflag++;
  800353:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800356:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800359:	e9 47 ff ff ff       	jmp    8002a5 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80035e:	8b 45 14             	mov    0x14(%ebp),%eax
  800361:	8d 78 04             	lea    0x4(%eax),%edi
  800364:	83 ec 08             	sub    $0x8,%esp
  800367:	53                   	push   %ebx
  800368:	ff 30                	pushl  (%eax)
  80036a:	ff d6                	call   *%esi
			break;
  80036c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80036f:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800372:	e9 57 02 00 00       	jmp    8005ce <vprintfmt+0x362>
			err = va_arg(ap, int);
  800377:	8b 45 14             	mov    0x14(%ebp),%eax
  80037a:	8d 78 04             	lea    0x4(%eax),%edi
  80037d:	8b 00                	mov    (%eax),%eax
  80037f:	99                   	cltd   
  800380:	31 d0                	xor    %edx,%eax
  800382:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800384:	83 f8 0f             	cmp    $0xf,%eax
  800387:	7f 23                	jg     8003ac <vprintfmt+0x140>
  800389:	8b 14 85 40 13 80 00 	mov    0x801340(,%eax,4),%edx
  800390:	85 d2                	test   %edx,%edx
  800392:	74 18                	je     8003ac <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800394:	52                   	push   %edx
  800395:	68 b0 10 80 00       	push   $0x8010b0
  80039a:	53                   	push   %ebx
  80039b:	56                   	push   %esi
  80039c:	e8 aa fe ff ff       	call   80024b <printfmt>
  8003a1:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003a4:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003a7:	e9 22 02 00 00       	jmp    8005ce <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8003ac:	50                   	push   %eax
  8003ad:	68 a7 10 80 00       	push   $0x8010a7
  8003b2:	53                   	push   %ebx
  8003b3:	56                   	push   %esi
  8003b4:	e8 92 fe ff ff       	call   80024b <printfmt>
  8003b9:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003bc:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003bf:	e9 0a 02 00 00       	jmp    8005ce <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8003c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c7:	83 c0 04             	add    $0x4,%eax
  8003ca:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d0:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003d2:	85 d2                	test   %edx,%edx
  8003d4:	b8 a0 10 80 00       	mov    $0x8010a0,%eax
  8003d9:	0f 45 c2             	cmovne %edx,%eax
  8003dc:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003df:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e3:	7e 06                	jle    8003eb <vprintfmt+0x17f>
  8003e5:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8003e9:	75 0d                	jne    8003f8 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003eb:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003ee:	89 c7                	mov    %eax,%edi
  8003f0:	03 45 e0             	add    -0x20(%ebp),%eax
  8003f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f6:	eb 55                	jmp    80044d <vprintfmt+0x1e1>
  8003f8:	83 ec 08             	sub    $0x8,%esp
  8003fb:	ff 75 d8             	pushl  -0x28(%ebp)
  8003fe:	ff 75 cc             	pushl  -0x34(%ebp)
  800401:	e8 45 03 00 00       	call   80074b <strnlen>
  800406:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800409:	29 c2                	sub    %eax,%edx
  80040b:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80040e:	83 c4 10             	add    $0x10,%esp
  800411:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800413:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800417:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80041a:	85 ff                	test   %edi,%edi
  80041c:	7e 11                	jle    80042f <vprintfmt+0x1c3>
					putch(padc, putdat);
  80041e:	83 ec 08             	sub    $0x8,%esp
  800421:	53                   	push   %ebx
  800422:	ff 75 e0             	pushl  -0x20(%ebp)
  800425:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800427:	83 ef 01             	sub    $0x1,%edi
  80042a:	83 c4 10             	add    $0x10,%esp
  80042d:	eb eb                	jmp    80041a <vprintfmt+0x1ae>
  80042f:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800432:	85 d2                	test   %edx,%edx
  800434:	b8 00 00 00 00       	mov    $0x0,%eax
  800439:	0f 49 c2             	cmovns %edx,%eax
  80043c:	29 c2                	sub    %eax,%edx
  80043e:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800441:	eb a8                	jmp    8003eb <vprintfmt+0x17f>
					putch(ch, putdat);
  800443:	83 ec 08             	sub    $0x8,%esp
  800446:	53                   	push   %ebx
  800447:	52                   	push   %edx
  800448:	ff d6                	call   *%esi
  80044a:	83 c4 10             	add    $0x10,%esp
  80044d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800450:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800452:	83 c7 01             	add    $0x1,%edi
  800455:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800459:	0f be d0             	movsbl %al,%edx
  80045c:	85 d2                	test   %edx,%edx
  80045e:	74 4b                	je     8004ab <vprintfmt+0x23f>
  800460:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800464:	78 06                	js     80046c <vprintfmt+0x200>
  800466:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80046a:	78 1e                	js     80048a <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80046c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800470:	74 d1                	je     800443 <vprintfmt+0x1d7>
  800472:	0f be c0             	movsbl %al,%eax
  800475:	83 e8 20             	sub    $0x20,%eax
  800478:	83 f8 5e             	cmp    $0x5e,%eax
  80047b:	76 c6                	jbe    800443 <vprintfmt+0x1d7>
					putch('?', putdat);
  80047d:	83 ec 08             	sub    $0x8,%esp
  800480:	53                   	push   %ebx
  800481:	6a 3f                	push   $0x3f
  800483:	ff d6                	call   *%esi
  800485:	83 c4 10             	add    $0x10,%esp
  800488:	eb c3                	jmp    80044d <vprintfmt+0x1e1>
  80048a:	89 cf                	mov    %ecx,%edi
  80048c:	eb 0e                	jmp    80049c <vprintfmt+0x230>
				putch(' ', putdat);
  80048e:	83 ec 08             	sub    $0x8,%esp
  800491:	53                   	push   %ebx
  800492:	6a 20                	push   $0x20
  800494:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800496:	83 ef 01             	sub    $0x1,%edi
  800499:	83 c4 10             	add    $0x10,%esp
  80049c:	85 ff                	test   %edi,%edi
  80049e:	7f ee                	jg     80048e <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8004a0:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004a3:	89 45 14             	mov    %eax,0x14(%ebp)
  8004a6:	e9 23 01 00 00       	jmp    8005ce <vprintfmt+0x362>
  8004ab:	89 cf                	mov    %ecx,%edi
  8004ad:	eb ed                	jmp    80049c <vprintfmt+0x230>
	if (lflag >= 2)
  8004af:	83 f9 01             	cmp    $0x1,%ecx
  8004b2:	7f 1b                	jg     8004cf <vprintfmt+0x263>
	else if (lflag)
  8004b4:	85 c9                	test   %ecx,%ecx
  8004b6:	74 63                	je     80051b <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8004b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bb:	8b 00                	mov    (%eax),%eax
  8004bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004c0:	99                   	cltd   
  8004c1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c7:	8d 40 04             	lea    0x4(%eax),%eax
  8004ca:	89 45 14             	mov    %eax,0x14(%ebp)
  8004cd:	eb 17                	jmp    8004e6 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8004cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d2:	8b 50 04             	mov    0x4(%eax),%edx
  8004d5:	8b 00                	mov    (%eax),%eax
  8004d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004da:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e0:	8d 40 08             	lea    0x8(%eax),%eax
  8004e3:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004e6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004e9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8004ec:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8004f1:	85 c9                	test   %ecx,%ecx
  8004f3:	0f 89 bb 00 00 00    	jns    8005b4 <vprintfmt+0x348>
				putch('-', putdat);
  8004f9:	83 ec 08             	sub    $0x8,%esp
  8004fc:	53                   	push   %ebx
  8004fd:	6a 2d                	push   $0x2d
  8004ff:	ff d6                	call   *%esi
				num = -(long long) num;
  800501:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800504:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800507:	f7 da                	neg    %edx
  800509:	83 d1 00             	adc    $0x0,%ecx
  80050c:	f7 d9                	neg    %ecx
  80050e:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800511:	b8 0a 00 00 00       	mov    $0xa,%eax
  800516:	e9 99 00 00 00       	jmp    8005b4 <vprintfmt+0x348>
		return va_arg(*ap, int);
  80051b:	8b 45 14             	mov    0x14(%ebp),%eax
  80051e:	8b 00                	mov    (%eax),%eax
  800520:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800523:	99                   	cltd   
  800524:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800527:	8b 45 14             	mov    0x14(%ebp),%eax
  80052a:	8d 40 04             	lea    0x4(%eax),%eax
  80052d:	89 45 14             	mov    %eax,0x14(%ebp)
  800530:	eb b4                	jmp    8004e6 <vprintfmt+0x27a>
	if (lflag >= 2)
  800532:	83 f9 01             	cmp    $0x1,%ecx
  800535:	7f 1b                	jg     800552 <vprintfmt+0x2e6>
	else if (lflag)
  800537:	85 c9                	test   %ecx,%ecx
  800539:	74 2c                	je     800567 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  80053b:	8b 45 14             	mov    0x14(%ebp),%eax
  80053e:	8b 10                	mov    (%eax),%edx
  800540:	b9 00 00 00 00       	mov    $0x0,%ecx
  800545:	8d 40 04             	lea    0x4(%eax),%eax
  800548:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80054b:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800550:	eb 62                	jmp    8005b4 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800552:	8b 45 14             	mov    0x14(%ebp),%eax
  800555:	8b 10                	mov    (%eax),%edx
  800557:	8b 48 04             	mov    0x4(%eax),%ecx
  80055a:	8d 40 08             	lea    0x8(%eax),%eax
  80055d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800560:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800565:	eb 4d                	jmp    8005b4 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8b 10                	mov    (%eax),%edx
  80056c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800571:	8d 40 04             	lea    0x4(%eax),%eax
  800574:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800577:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80057c:	eb 36                	jmp    8005b4 <vprintfmt+0x348>
	if (lflag >= 2)
  80057e:	83 f9 01             	cmp    $0x1,%ecx
  800581:	7f 17                	jg     80059a <vprintfmt+0x32e>
	else if (lflag)
  800583:	85 c9                	test   %ecx,%ecx
  800585:	74 6e                	je     8005f5 <vprintfmt+0x389>
		return va_arg(*ap, long);
  800587:	8b 45 14             	mov    0x14(%ebp),%eax
  80058a:	8b 10                	mov    (%eax),%edx
  80058c:	89 d0                	mov    %edx,%eax
  80058e:	99                   	cltd   
  80058f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800592:	8d 49 04             	lea    0x4(%ecx),%ecx
  800595:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800598:	eb 11                	jmp    8005ab <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8b 50 04             	mov    0x4(%eax),%edx
  8005a0:	8b 00                	mov    (%eax),%eax
  8005a2:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005a5:	8d 49 08             	lea    0x8(%ecx),%ecx
  8005a8:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8005ab:	89 d1                	mov    %edx,%ecx
  8005ad:	89 c2                	mov    %eax,%edx
            base = 8;
  8005af:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005b4:	83 ec 0c             	sub    $0xc,%esp
  8005b7:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005bb:	57                   	push   %edi
  8005bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8005bf:	50                   	push   %eax
  8005c0:	51                   	push   %ecx
  8005c1:	52                   	push   %edx
  8005c2:	89 da                	mov    %ebx,%edx
  8005c4:	89 f0                	mov    %esi,%eax
  8005c6:	e8 b6 fb ff ff       	call   800181 <printnum>
			break;
  8005cb:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8005ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005d1:	83 c7 01             	add    $0x1,%edi
  8005d4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005d8:	83 f8 25             	cmp    $0x25,%eax
  8005db:	0f 84 a6 fc ff ff    	je     800287 <vprintfmt+0x1b>
			if (ch == '\0')
  8005e1:	85 c0                	test   %eax,%eax
  8005e3:	0f 84 ce 00 00 00    	je     8006b7 <vprintfmt+0x44b>
			putch(ch, putdat);
  8005e9:	83 ec 08             	sub    $0x8,%esp
  8005ec:	53                   	push   %ebx
  8005ed:	50                   	push   %eax
  8005ee:	ff d6                	call   *%esi
  8005f0:	83 c4 10             	add    $0x10,%esp
  8005f3:	eb dc                	jmp    8005d1 <vprintfmt+0x365>
		return va_arg(*ap, int);
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8b 10                	mov    (%eax),%edx
  8005fa:	89 d0                	mov    %edx,%eax
  8005fc:	99                   	cltd   
  8005fd:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800600:	8d 49 04             	lea    0x4(%ecx),%ecx
  800603:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800606:	eb a3                	jmp    8005ab <vprintfmt+0x33f>
			putch('0', putdat);
  800608:	83 ec 08             	sub    $0x8,%esp
  80060b:	53                   	push   %ebx
  80060c:	6a 30                	push   $0x30
  80060e:	ff d6                	call   *%esi
			putch('x', putdat);
  800610:	83 c4 08             	add    $0x8,%esp
  800613:	53                   	push   %ebx
  800614:	6a 78                	push   $0x78
  800616:	ff d6                	call   *%esi
			num = (unsigned long long)
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8b 10                	mov    (%eax),%edx
  80061d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800622:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800625:	8d 40 04             	lea    0x4(%eax),%eax
  800628:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80062b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800630:	eb 82                	jmp    8005b4 <vprintfmt+0x348>
	if (lflag >= 2)
  800632:	83 f9 01             	cmp    $0x1,%ecx
  800635:	7f 1e                	jg     800655 <vprintfmt+0x3e9>
	else if (lflag)
  800637:	85 c9                	test   %ecx,%ecx
  800639:	74 32                	je     80066d <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  80063b:	8b 45 14             	mov    0x14(%ebp),%eax
  80063e:	8b 10                	mov    (%eax),%edx
  800640:	b9 00 00 00 00       	mov    $0x0,%ecx
  800645:	8d 40 04             	lea    0x4(%eax),%eax
  800648:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80064b:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800650:	e9 5f ff ff ff       	jmp    8005b4 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800655:	8b 45 14             	mov    0x14(%ebp),%eax
  800658:	8b 10                	mov    (%eax),%edx
  80065a:	8b 48 04             	mov    0x4(%eax),%ecx
  80065d:	8d 40 08             	lea    0x8(%eax),%eax
  800660:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800663:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800668:	e9 47 ff ff ff       	jmp    8005b4 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80066d:	8b 45 14             	mov    0x14(%ebp),%eax
  800670:	8b 10                	mov    (%eax),%edx
  800672:	b9 00 00 00 00       	mov    $0x0,%ecx
  800677:	8d 40 04             	lea    0x4(%eax),%eax
  80067a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80067d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800682:	e9 2d ff ff ff       	jmp    8005b4 <vprintfmt+0x348>
			putch(ch, putdat);
  800687:	83 ec 08             	sub    $0x8,%esp
  80068a:	53                   	push   %ebx
  80068b:	6a 25                	push   $0x25
  80068d:	ff d6                	call   *%esi
			break;
  80068f:	83 c4 10             	add    $0x10,%esp
  800692:	e9 37 ff ff ff       	jmp    8005ce <vprintfmt+0x362>
			putch('%', putdat);
  800697:	83 ec 08             	sub    $0x8,%esp
  80069a:	53                   	push   %ebx
  80069b:	6a 25                	push   $0x25
  80069d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80069f:	83 c4 10             	add    $0x10,%esp
  8006a2:	89 f8                	mov    %edi,%eax
  8006a4:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006a8:	74 05                	je     8006af <vprintfmt+0x443>
  8006aa:	83 e8 01             	sub    $0x1,%eax
  8006ad:	eb f5                	jmp    8006a4 <vprintfmt+0x438>
  8006af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006b2:	e9 17 ff ff ff       	jmp    8005ce <vprintfmt+0x362>
}
  8006b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ba:	5b                   	pop    %ebx
  8006bb:	5e                   	pop    %esi
  8006bc:	5f                   	pop    %edi
  8006bd:	5d                   	pop    %ebp
  8006be:	c3                   	ret    

008006bf <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006bf:	f3 0f 1e fb          	endbr32 
  8006c3:	55                   	push   %ebp
  8006c4:	89 e5                	mov    %esp,%ebp
  8006c6:	83 ec 18             	sub    $0x18,%esp
  8006c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006d2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006d6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006e0:	85 c0                	test   %eax,%eax
  8006e2:	74 26                	je     80070a <vsnprintf+0x4b>
  8006e4:	85 d2                	test   %edx,%edx
  8006e6:	7e 22                	jle    80070a <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e8:	ff 75 14             	pushl  0x14(%ebp)
  8006eb:	ff 75 10             	pushl  0x10(%ebp)
  8006ee:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f1:	50                   	push   %eax
  8006f2:	68 2a 02 80 00       	push   $0x80022a
  8006f7:	e8 70 fb ff ff       	call   80026c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ff:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800702:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800705:	83 c4 10             	add    $0x10,%esp
}
  800708:	c9                   	leave  
  800709:	c3                   	ret    
		return -E_INVAL;
  80070a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80070f:	eb f7                	jmp    800708 <vsnprintf+0x49>

00800711 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800711:	f3 0f 1e fb          	endbr32 
  800715:	55                   	push   %ebp
  800716:	89 e5                	mov    %esp,%ebp
  800718:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80071b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80071e:	50                   	push   %eax
  80071f:	ff 75 10             	pushl  0x10(%ebp)
  800722:	ff 75 0c             	pushl  0xc(%ebp)
  800725:	ff 75 08             	pushl  0x8(%ebp)
  800728:	e8 92 ff ff ff       	call   8006bf <vsnprintf>
	va_end(ap);

	return rc;
}
  80072d:	c9                   	leave  
  80072e:	c3                   	ret    

0080072f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80072f:	f3 0f 1e fb          	endbr32 
  800733:	55                   	push   %ebp
  800734:	89 e5                	mov    %esp,%ebp
  800736:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800739:	b8 00 00 00 00       	mov    $0x0,%eax
  80073e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800742:	74 05                	je     800749 <strlen+0x1a>
		n++;
  800744:	83 c0 01             	add    $0x1,%eax
  800747:	eb f5                	jmp    80073e <strlen+0xf>
	return n;
}
  800749:	5d                   	pop    %ebp
  80074a:	c3                   	ret    

0080074b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80074b:	f3 0f 1e fb          	endbr32 
  80074f:	55                   	push   %ebp
  800750:	89 e5                	mov    %esp,%ebp
  800752:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800755:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800758:	b8 00 00 00 00       	mov    $0x0,%eax
  80075d:	39 d0                	cmp    %edx,%eax
  80075f:	74 0d                	je     80076e <strnlen+0x23>
  800761:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800765:	74 05                	je     80076c <strnlen+0x21>
		n++;
  800767:	83 c0 01             	add    $0x1,%eax
  80076a:	eb f1                	jmp    80075d <strnlen+0x12>
  80076c:	89 c2                	mov    %eax,%edx
	return n;
}
  80076e:	89 d0                	mov    %edx,%eax
  800770:	5d                   	pop    %ebp
  800771:	c3                   	ret    

00800772 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800772:	f3 0f 1e fb          	endbr32 
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	53                   	push   %ebx
  80077a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800780:	b8 00 00 00 00       	mov    $0x0,%eax
  800785:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800789:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80078c:	83 c0 01             	add    $0x1,%eax
  80078f:	84 d2                	test   %dl,%dl
  800791:	75 f2                	jne    800785 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800793:	89 c8                	mov    %ecx,%eax
  800795:	5b                   	pop    %ebx
  800796:	5d                   	pop    %ebp
  800797:	c3                   	ret    

00800798 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800798:	f3 0f 1e fb          	endbr32 
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	53                   	push   %ebx
  8007a0:	83 ec 10             	sub    $0x10,%esp
  8007a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a6:	53                   	push   %ebx
  8007a7:	e8 83 ff ff ff       	call   80072f <strlen>
  8007ac:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007af:	ff 75 0c             	pushl  0xc(%ebp)
  8007b2:	01 d8                	add    %ebx,%eax
  8007b4:	50                   	push   %eax
  8007b5:	e8 b8 ff ff ff       	call   800772 <strcpy>
	return dst;
}
  8007ba:	89 d8                	mov    %ebx,%eax
  8007bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007bf:	c9                   	leave  
  8007c0:	c3                   	ret    

008007c1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c1:	f3 0f 1e fb          	endbr32 
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
  8007c8:	56                   	push   %esi
  8007c9:	53                   	push   %ebx
  8007ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d0:	89 f3                	mov    %esi,%ebx
  8007d2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d5:	89 f0                	mov    %esi,%eax
  8007d7:	39 d8                	cmp    %ebx,%eax
  8007d9:	74 11                	je     8007ec <strncpy+0x2b>
		*dst++ = *src;
  8007db:	83 c0 01             	add    $0x1,%eax
  8007de:	0f b6 0a             	movzbl (%edx),%ecx
  8007e1:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e4:	80 f9 01             	cmp    $0x1,%cl
  8007e7:	83 da ff             	sbb    $0xffffffff,%edx
  8007ea:	eb eb                	jmp    8007d7 <strncpy+0x16>
	}
	return ret;
}
  8007ec:	89 f0                	mov    %esi,%eax
  8007ee:	5b                   	pop    %ebx
  8007ef:	5e                   	pop    %esi
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f2:	f3 0f 1e fb          	endbr32 
  8007f6:	55                   	push   %ebp
  8007f7:	89 e5                	mov    %esp,%ebp
  8007f9:	56                   	push   %esi
  8007fa:	53                   	push   %ebx
  8007fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800801:	8b 55 10             	mov    0x10(%ebp),%edx
  800804:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800806:	85 d2                	test   %edx,%edx
  800808:	74 21                	je     80082b <strlcpy+0x39>
  80080a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80080e:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800810:	39 c2                	cmp    %eax,%edx
  800812:	74 14                	je     800828 <strlcpy+0x36>
  800814:	0f b6 19             	movzbl (%ecx),%ebx
  800817:	84 db                	test   %bl,%bl
  800819:	74 0b                	je     800826 <strlcpy+0x34>
			*dst++ = *src++;
  80081b:	83 c1 01             	add    $0x1,%ecx
  80081e:	83 c2 01             	add    $0x1,%edx
  800821:	88 5a ff             	mov    %bl,-0x1(%edx)
  800824:	eb ea                	jmp    800810 <strlcpy+0x1e>
  800826:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800828:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80082b:	29 f0                	sub    %esi,%eax
}
  80082d:	5b                   	pop    %ebx
  80082e:	5e                   	pop    %esi
  80082f:	5d                   	pop    %ebp
  800830:	c3                   	ret    

00800831 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800831:	f3 0f 1e fb          	endbr32 
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80083e:	0f b6 01             	movzbl (%ecx),%eax
  800841:	84 c0                	test   %al,%al
  800843:	74 0c                	je     800851 <strcmp+0x20>
  800845:	3a 02                	cmp    (%edx),%al
  800847:	75 08                	jne    800851 <strcmp+0x20>
		p++, q++;
  800849:	83 c1 01             	add    $0x1,%ecx
  80084c:	83 c2 01             	add    $0x1,%edx
  80084f:	eb ed                	jmp    80083e <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800851:	0f b6 c0             	movzbl %al,%eax
  800854:	0f b6 12             	movzbl (%edx),%edx
  800857:	29 d0                	sub    %edx,%eax
}
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80085b:	f3 0f 1e fb          	endbr32 
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	53                   	push   %ebx
  800863:	8b 45 08             	mov    0x8(%ebp),%eax
  800866:	8b 55 0c             	mov    0xc(%ebp),%edx
  800869:	89 c3                	mov    %eax,%ebx
  80086b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80086e:	eb 06                	jmp    800876 <strncmp+0x1b>
		n--, p++, q++;
  800870:	83 c0 01             	add    $0x1,%eax
  800873:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800876:	39 d8                	cmp    %ebx,%eax
  800878:	74 16                	je     800890 <strncmp+0x35>
  80087a:	0f b6 08             	movzbl (%eax),%ecx
  80087d:	84 c9                	test   %cl,%cl
  80087f:	74 04                	je     800885 <strncmp+0x2a>
  800881:	3a 0a                	cmp    (%edx),%cl
  800883:	74 eb                	je     800870 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800885:	0f b6 00             	movzbl (%eax),%eax
  800888:	0f b6 12             	movzbl (%edx),%edx
  80088b:	29 d0                	sub    %edx,%eax
}
  80088d:	5b                   	pop    %ebx
  80088e:	5d                   	pop    %ebp
  80088f:	c3                   	ret    
		return 0;
  800890:	b8 00 00 00 00       	mov    $0x0,%eax
  800895:	eb f6                	jmp    80088d <strncmp+0x32>

00800897 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800897:	f3 0f 1e fb          	endbr32 
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a5:	0f b6 10             	movzbl (%eax),%edx
  8008a8:	84 d2                	test   %dl,%dl
  8008aa:	74 09                	je     8008b5 <strchr+0x1e>
		if (*s == c)
  8008ac:	38 ca                	cmp    %cl,%dl
  8008ae:	74 0a                	je     8008ba <strchr+0x23>
	for (; *s; s++)
  8008b0:	83 c0 01             	add    $0x1,%eax
  8008b3:	eb f0                	jmp    8008a5 <strchr+0xe>
			return (char *) s;
	return 0;
  8008b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ba:	5d                   	pop    %ebp
  8008bb:	c3                   	ret    

008008bc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008bc:	f3 0f 1e fb          	endbr32 
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ca:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008cd:	38 ca                	cmp    %cl,%dl
  8008cf:	74 09                	je     8008da <strfind+0x1e>
  8008d1:	84 d2                	test   %dl,%dl
  8008d3:	74 05                	je     8008da <strfind+0x1e>
	for (; *s; s++)
  8008d5:	83 c0 01             	add    $0x1,%eax
  8008d8:	eb f0                	jmp    8008ca <strfind+0xe>
			break;
	return (char *) s;
}
  8008da:	5d                   	pop    %ebp
  8008db:	c3                   	ret    

008008dc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008dc:	f3 0f 1e fb          	endbr32 
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	57                   	push   %edi
  8008e4:	56                   	push   %esi
  8008e5:	53                   	push   %ebx
  8008e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ec:	85 c9                	test   %ecx,%ecx
  8008ee:	74 31                	je     800921 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f0:	89 f8                	mov    %edi,%eax
  8008f2:	09 c8                	or     %ecx,%eax
  8008f4:	a8 03                	test   $0x3,%al
  8008f6:	75 23                	jne    80091b <memset+0x3f>
		c &= 0xFF;
  8008f8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008fc:	89 d3                	mov    %edx,%ebx
  8008fe:	c1 e3 08             	shl    $0x8,%ebx
  800901:	89 d0                	mov    %edx,%eax
  800903:	c1 e0 18             	shl    $0x18,%eax
  800906:	89 d6                	mov    %edx,%esi
  800908:	c1 e6 10             	shl    $0x10,%esi
  80090b:	09 f0                	or     %esi,%eax
  80090d:	09 c2                	or     %eax,%edx
  80090f:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800911:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800914:	89 d0                	mov    %edx,%eax
  800916:	fc                   	cld    
  800917:	f3 ab                	rep stos %eax,%es:(%edi)
  800919:	eb 06                	jmp    800921 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091e:	fc                   	cld    
  80091f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800921:	89 f8                	mov    %edi,%eax
  800923:	5b                   	pop    %ebx
  800924:	5e                   	pop    %esi
  800925:	5f                   	pop    %edi
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    

00800928 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800928:	f3 0f 1e fb          	endbr32 
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	57                   	push   %edi
  800930:	56                   	push   %esi
  800931:	8b 45 08             	mov    0x8(%ebp),%eax
  800934:	8b 75 0c             	mov    0xc(%ebp),%esi
  800937:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80093a:	39 c6                	cmp    %eax,%esi
  80093c:	73 32                	jae    800970 <memmove+0x48>
  80093e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800941:	39 c2                	cmp    %eax,%edx
  800943:	76 2b                	jbe    800970 <memmove+0x48>
		s += n;
		d += n;
  800945:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800948:	89 fe                	mov    %edi,%esi
  80094a:	09 ce                	or     %ecx,%esi
  80094c:	09 d6                	or     %edx,%esi
  80094e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800954:	75 0e                	jne    800964 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800956:	83 ef 04             	sub    $0x4,%edi
  800959:	8d 72 fc             	lea    -0x4(%edx),%esi
  80095c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80095f:	fd                   	std    
  800960:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800962:	eb 09                	jmp    80096d <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800964:	83 ef 01             	sub    $0x1,%edi
  800967:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80096a:	fd                   	std    
  80096b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096d:	fc                   	cld    
  80096e:	eb 1a                	jmp    80098a <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800970:	89 c2                	mov    %eax,%edx
  800972:	09 ca                	or     %ecx,%edx
  800974:	09 f2                	or     %esi,%edx
  800976:	f6 c2 03             	test   $0x3,%dl
  800979:	75 0a                	jne    800985 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80097b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80097e:	89 c7                	mov    %eax,%edi
  800980:	fc                   	cld    
  800981:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800983:	eb 05                	jmp    80098a <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800985:	89 c7                	mov    %eax,%edi
  800987:	fc                   	cld    
  800988:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098a:	5e                   	pop    %esi
  80098b:	5f                   	pop    %edi
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80098e:	f3 0f 1e fb          	endbr32 
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800998:	ff 75 10             	pushl  0x10(%ebp)
  80099b:	ff 75 0c             	pushl  0xc(%ebp)
  80099e:	ff 75 08             	pushl  0x8(%ebp)
  8009a1:	e8 82 ff ff ff       	call   800928 <memmove>
}
  8009a6:	c9                   	leave  
  8009a7:	c3                   	ret    

008009a8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a8:	f3 0f 1e fb          	endbr32 
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	56                   	push   %esi
  8009b0:	53                   	push   %ebx
  8009b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b7:	89 c6                	mov    %eax,%esi
  8009b9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009bc:	39 f0                	cmp    %esi,%eax
  8009be:	74 1c                	je     8009dc <memcmp+0x34>
		if (*s1 != *s2)
  8009c0:	0f b6 08             	movzbl (%eax),%ecx
  8009c3:	0f b6 1a             	movzbl (%edx),%ebx
  8009c6:	38 d9                	cmp    %bl,%cl
  8009c8:	75 08                	jne    8009d2 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009ca:	83 c0 01             	add    $0x1,%eax
  8009cd:	83 c2 01             	add    $0x1,%edx
  8009d0:	eb ea                	jmp    8009bc <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  8009d2:	0f b6 c1             	movzbl %cl,%eax
  8009d5:	0f b6 db             	movzbl %bl,%ebx
  8009d8:	29 d8                	sub    %ebx,%eax
  8009da:	eb 05                	jmp    8009e1 <memcmp+0x39>
	}

	return 0;
  8009dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e1:	5b                   	pop    %ebx
  8009e2:	5e                   	pop    %esi
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    

008009e5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009e5:	f3 0f 1e fb          	endbr32 
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009f2:	89 c2                	mov    %eax,%edx
  8009f4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009f7:	39 d0                	cmp    %edx,%eax
  8009f9:	73 09                	jae    800a04 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009fb:	38 08                	cmp    %cl,(%eax)
  8009fd:	74 05                	je     800a04 <memfind+0x1f>
	for (; s < ends; s++)
  8009ff:	83 c0 01             	add    $0x1,%eax
  800a02:	eb f3                	jmp    8009f7 <memfind+0x12>
			break;
	return (void *) s;
}
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a06:	f3 0f 1e fb          	endbr32 
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	57                   	push   %edi
  800a0e:	56                   	push   %esi
  800a0f:	53                   	push   %ebx
  800a10:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a13:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a16:	eb 03                	jmp    800a1b <strtol+0x15>
		s++;
  800a18:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a1b:	0f b6 01             	movzbl (%ecx),%eax
  800a1e:	3c 20                	cmp    $0x20,%al
  800a20:	74 f6                	je     800a18 <strtol+0x12>
  800a22:	3c 09                	cmp    $0x9,%al
  800a24:	74 f2                	je     800a18 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a26:	3c 2b                	cmp    $0x2b,%al
  800a28:	74 2a                	je     800a54 <strtol+0x4e>
	int neg = 0;
  800a2a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a2f:	3c 2d                	cmp    $0x2d,%al
  800a31:	74 2b                	je     800a5e <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a33:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a39:	75 0f                	jne    800a4a <strtol+0x44>
  800a3b:	80 39 30             	cmpb   $0x30,(%ecx)
  800a3e:	74 28                	je     800a68 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a40:	85 db                	test   %ebx,%ebx
  800a42:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a47:	0f 44 d8             	cmove  %eax,%ebx
  800a4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a52:	eb 46                	jmp    800a9a <strtol+0x94>
		s++;
  800a54:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a57:	bf 00 00 00 00       	mov    $0x0,%edi
  800a5c:	eb d5                	jmp    800a33 <strtol+0x2d>
		s++, neg = 1;
  800a5e:	83 c1 01             	add    $0x1,%ecx
  800a61:	bf 01 00 00 00       	mov    $0x1,%edi
  800a66:	eb cb                	jmp    800a33 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a68:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a6c:	74 0e                	je     800a7c <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a6e:	85 db                	test   %ebx,%ebx
  800a70:	75 d8                	jne    800a4a <strtol+0x44>
		s++, base = 8;
  800a72:	83 c1 01             	add    $0x1,%ecx
  800a75:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a7a:	eb ce                	jmp    800a4a <strtol+0x44>
		s += 2, base = 16;
  800a7c:	83 c1 02             	add    $0x2,%ecx
  800a7f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a84:	eb c4                	jmp    800a4a <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a86:	0f be d2             	movsbl %dl,%edx
  800a89:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a8c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a8f:	7d 3a                	jge    800acb <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a91:	83 c1 01             	add    $0x1,%ecx
  800a94:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a98:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a9a:	0f b6 11             	movzbl (%ecx),%edx
  800a9d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aa0:	89 f3                	mov    %esi,%ebx
  800aa2:	80 fb 09             	cmp    $0x9,%bl
  800aa5:	76 df                	jbe    800a86 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800aa7:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aaa:	89 f3                	mov    %esi,%ebx
  800aac:	80 fb 19             	cmp    $0x19,%bl
  800aaf:	77 08                	ja     800ab9 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ab1:	0f be d2             	movsbl %dl,%edx
  800ab4:	83 ea 57             	sub    $0x57,%edx
  800ab7:	eb d3                	jmp    800a8c <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800ab9:	8d 72 bf             	lea    -0x41(%edx),%esi
  800abc:	89 f3                	mov    %esi,%ebx
  800abe:	80 fb 19             	cmp    $0x19,%bl
  800ac1:	77 08                	ja     800acb <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ac3:	0f be d2             	movsbl %dl,%edx
  800ac6:	83 ea 37             	sub    $0x37,%edx
  800ac9:	eb c1                	jmp    800a8c <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800acb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800acf:	74 05                	je     800ad6 <strtol+0xd0>
		*endptr = (char *) s;
  800ad1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad4:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ad6:	89 c2                	mov    %eax,%edx
  800ad8:	f7 da                	neg    %edx
  800ada:	85 ff                	test   %edi,%edi
  800adc:	0f 45 c2             	cmovne %edx,%eax
}
  800adf:	5b                   	pop    %ebx
  800ae0:	5e                   	pop    %esi
  800ae1:	5f                   	pop    %edi
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ae4:	f3 0f 1e fb          	endbr32 
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	57                   	push   %edi
  800aec:	56                   	push   %esi
  800aed:	53                   	push   %ebx
	asm volatile("int %1\n"
  800aee:	b8 00 00 00 00       	mov    $0x0,%eax
  800af3:	8b 55 08             	mov    0x8(%ebp),%edx
  800af6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af9:	89 c3                	mov    %eax,%ebx
  800afb:	89 c7                	mov    %eax,%edi
  800afd:	89 c6                	mov    %eax,%esi
  800aff:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b01:	5b                   	pop    %ebx
  800b02:	5e                   	pop    %esi
  800b03:	5f                   	pop    %edi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b06:	f3 0f 1e fb          	endbr32 
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	57                   	push   %edi
  800b0e:	56                   	push   %esi
  800b0f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b10:	ba 00 00 00 00       	mov    $0x0,%edx
  800b15:	b8 01 00 00 00       	mov    $0x1,%eax
  800b1a:	89 d1                	mov    %edx,%ecx
  800b1c:	89 d3                	mov    %edx,%ebx
  800b1e:	89 d7                	mov    %edx,%edi
  800b20:	89 d6                	mov    %edx,%esi
  800b22:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b24:	5b                   	pop    %ebx
  800b25:	5e                   	pop    %esi
  800b26:	5f                   	pop    %edi
  800b27:	5d                   	pop    %ebp
  800b28:	c3                   	ret    

00800b29 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b29:	f3 0f 1e fb          	endbr32 
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	57                   	push   %edi
  800b31:	56                   	push   %esi
  800b32:	53                   	push   %ebx
  800b33:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b36:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3e:	b8 03 00 00 00       	mov    $0x3,%eax
  800b43:	89 cb                	mov    %ecx,%ebx
  800b45:	89 cf                	mov    %ecx,%edi
  800b47:	89 ce                	mov    %ecx,%esi
  800b49:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b4b:	85 c0                	test   %eax,%eax
  800b4d:	7f 08                	jg     800b57 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5f                   	pop    %edi
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b57:	83 ec 0c             	sub    $0xc,%esp
  800b5a:	50                   	push   %eax
  800b5b:	6a 03                	push   $0x3
  800b5d:	68 9f 13 80 00       	push   $0x80139f
  800b62:	6a 23                	push   $0x23
  800b64:	68 bc 13 80 00       	push   $0x8013bc
  800b69:	e8 36 02 00 00       	call   800da4 <_panic>

00800b6e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b6e:	f3 0f 1e fb          	endbr32 
  800b72:	55                   	push   %ebp
  800b73:	89 e5                	mov    %esp,%ebp
  800b75:	57                   	push   %edi
  800b76:	56                   	push   %esi
  800b77:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b78:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7d:	b8 02 00 00 00       	mov    $0x2,%eax
  800b82:	89 d1                	mov    %edx,%ecx
  800b84:	89 d3                	mov    %edx,%ebx
  800b86:	89 d7                	mov    %edx,%edi
  800b88:	89 d6                	mov    %edx,%esi
  800b8a:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b8c:	5b                   	pop    %ebx
  800b8d:	5e                   	pop    %esi
  800b8e:	5f                   	pop    %edi
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <sys_yield>:

void
sys_yield(void)
{
  800b91:	f3 0f 1e fb          	endbr32 
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	57                   	push   %edi
  800b99:	56                   	push   %esi
  800b9a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ba5:	89 d1                	mov    %edx,%ecx
  800ba7:	89 d3                	mov    %edx,%ebx
  800ba9:	89 d7                	mov    %edx,%edi
  800bab:	89 d6                	mov    %edx,%esi
  800bad:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5f                   	pop    %edi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bb4:	f3 0f 1e fb          	endbr32 
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	57                   	push   %edi
  800bbc:	56                   	push   %esi
  800bbd:	53                   	push   %ebx
  800bbe:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bc1:	be 00 00 00 00       	mov    $0x0,%esi
  800bc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcc:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd4:	89 f7                	mov    %esi,%edi
  800bd6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bd8:	85 c0                	test   %eax,%eax
  800bda:	7f 08                	jg     800be4 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdf:	5b                   	pop    %ebx
  800be0:	5e                   	pop    %esi
  800be1:	5f                   	pop    %edi
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800be4:	83 ec 0c             	sub    $0xc,%esp
  800be7:	50                   	push   %eax
  800be8:	6a 04                	push   $0x4
  800bea:	68 9f 13 80 00       	push   $0x80139f
  800bef:	6a 23                	push   $0x23
  800bf1:	68 bc 13 80 00       	push   $0x8013bc
  800bf6:	e8 a9 01 00 00       	call   800da4 <_panic>

00800bfb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bfb:	f3 0f 1e fb          	endbr32 
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	57                   	push   %edi
  800c03:	56                   	push   %esi
  800c04:	53                   	push   %ebx
  800c05:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c08:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0e:	b8 05 00 00 00       	mov    $0x5,%eax
  800c13:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c16:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c19:	8b 75 18             	mov    0x18(%ebp),%esi
  800c1c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c1e:	85 c0                	test   %eax,%eax
  800c20:	7f 08                	jg     800c2a <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c25:	5b                   	pop    %ebx
  800c26:	5e                   	pop    %esi
  800c27:	5f                   	pop    %edi
  800c28:	5d                   	pop    %ebp
  800c29:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2a:	83 ec 0c             	sub    $0xc,%esp
  800c2d:	50                   	push   %eax
  800c2e:	6a 05                	push   $0x5
  800c30:	68 9f 13 80 00       	push   $0x80139f
  800c35:	6a 23                	push   $0x23
  800c37:	68 bc 13 80 00       	push   $0x8013bc
  800c3c:	e8 63 01 00 00       	call   800da4 <_panic>

00800c41 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c41:	f3 0f 1e fb          	endbr32 
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	57                   	push   %edi
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
  800c4b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c53:	8b 55 08             	mov    0x8(%ebp),%edx
  800c56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c59:	b8 06 00 00 00       	mov    $0x6,%eax
  800c5e:	89 df                	mov    %ebx,%edi
  800c60:	89 de                	mov    %ebx,%esi
  800c62:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c64:	85 c0                	test   %eax,%eax
  800c66:	7f 08                	jg     800c70 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6b:	5b                   	pop    %ebx
  800c6c:	5e                   	pop    %esi
  800c6d:	5f                   	pop    %edi
  800c6e:	5d                   	pop    %ebp
  800c6f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c70:	83 ec 0c             	sub    $0xc,%esp
  800c73:	50                   	push   %eax
  800c74:	6a 06                	push   $0x6
  800c76:	68 9f 13 80 00       	push   $0x80139f
  800c7b:	6a 23                	push   $0x23
  800c7d:	68 bc 13 80 00       	push   $0x8013bc
  800c82:	e8 1d 01 00 00       	call   800da4 <_panic>

00800c87 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c87:	f3 0f 1e fb          	endbr32 
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	57                   	push   %edi
  800c8f:	56                   	push   %esi
  800c90:	53                   	push   %ebx
  800c91:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c94:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c99:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9f:	b8 08 00 00 00       	mov    $0x8,%eax
  800ca4:	89 df                	mov    %ebx,%edi
  800ca6:	89 de                	mov    %ebx,%esi
  800ca8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800caa:	85 c0                	test   %eax,%eax
  800cac:	7f 08                	jg     800cb6 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb1:	5b                   	pop    %ebx
  800cb2:	5e                   	pop    %esi
  800cb3:	5f                   	pop    %edi
  800cb4:	5d                   	pop    %ebp
  800cb5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb6:	83 ec 0c             	sub    $0xc,%esp
  800cb9:	50                   	push   %eax
  800cba:	6a 08                	push   $0x8
  800cbc:	68 9f 13 80 00       	push   $0x80139f
  800cc1:	6a 23                	push   $0x23
  800cc3:	68 bc 13 80 00       	push   $0x8013bc
  800cc8:	e8 d7 00 00 00       	call   800da4 <_panic>

00800ccd <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ccd:	f3 0f 1e fb          	endbr32 
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	57                   	push   %edi
  800cd5:	56                   	push   %esi
  800cd6:	53                   	push   %ebx
  800cd7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cda:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce5:	b8 09 00 00 00       	mov    $0x9,%eax
  800cea:	89 df                	mov    %ebx,%edi
  800cec:	89 de                	mov    %ebx,%esi
  800cee:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf0:	85 c0                	test   %eax,%eax
  800cf2:	7f 08                	jg     800cfc <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf7:	5b                   	pop    %ebx
  800cf8:	5e                   	pop    %esi
  800cf9:	5f                   	pop    %edi
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfc:	83 ec 0c             	sub    $0xc,%esp
  800cff:	50                   	push   %eax
  800d00:	6a 09                	push   $0x9
  800d02:	68 9f 13 80 00       	push   $0x80139f
  800d07:	6a 23                	push   $0x23
  800d09:	68 bc 13 80 00       	push   $0x8013bc
  800d0e:	e8 91 00 00 00       	call   800da4 <_panic>

00800d13 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d13:	f3 0f 1e fb          	endbr32 
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	57                   	push   %edi
  800d1b:	56                   	push   %esi
  800d1c:	53                   	push   %ebx
  800d1d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d20:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d25:	8b 55 08             	mov    0x8(%ebp),%edx
  800d28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d30:	89 df                	mov    %ebx,%edi
  800d32:	89 de                	mov    %ebx,%esi
  800d34:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d36:	85 c0                	test   %eax,%eax
  800d38:	7f 08                	jg     800d42 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3d:	5b                   	pop    %ebx
  800d3e:	5e                   	pop    %esi
  800d3f:	5f                   	pop    %edi
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d42:	83 ec 0c             	sub    $0xc,%esp
  800d45:	50                   	push   %eax
  800d46:	6a 0a                	push   $0xa
  800d48:	68 9f 13 80 00       	push   $0x80139f
  800d4d:	6a 23                	push   $0x23
  800d4f:	68 bc 13 80 00       	push   $0x8013bc
  800d54:	e8 4b 00 00 00       	call   800da4 <_panic>

00800d59 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d59:	f3 0f 1e fb          	endbr32 
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
  800d60:	57                   	push   %edi
  800d61:	56                   	push   %esi
  800d62:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d63:	8b 55 08             	mov    0x8(%ebp),%edx
  800d66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d69:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d6e:	be 00 00 00 00       	mov    $0x0,%esi
  800d73:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d76:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d79:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d7b:	5b                   	pop    %ebx
  800d7c:	5e                   	pop    %esi
  800d7d:	5f                   	pop    %edi
  800d7e:	5d                   	pop    %ebp
  800d7f:	c3                   	ret    

00800d80 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d80:	f3 0f 1e fb          	endbr32 
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	57                   	push   %edi
  800d88:	56                   	push   %esi
  800d89:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d8a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d92:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d97:	89 cb                	mov    %ecx,%ebx
  800d99:	89 cf                	mov    %ecx,%edi
  800d9b:	89 ce                	mov    %ecx,%esi
  800d9d:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 0, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d9f:	5b                   	pop    %ebx
  800da0:	5e                   	pop    %esi
  800da1:	5f                   	pop    %edi
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    

00800da4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800da4:	f3 0f 1e fb          	endbr32 
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	56                   	push   %esi
  800dac:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800dad:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800db0:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800db6:	e8 b3 fd ff ff       	call   800b6e <sys_getenvid>
  800dbb:	83 ec 0c             	sub    $0xc,%esp
  800dbe:	ff 75 0c             	pushl  0xc(%ebp)
  800dc1:	ff 75 08             	pushl  0x8(%ebp)
  800dc4:	56                   	push   %esi
  800dc5:	50                   	push   %eax
  800dc6:	68 cc 13 80 00       	push   $0x8013cc
  800dcb:	e8 99 f3 ff ff       	call   800169 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800dd0:	83 c4 18             	add    $0x18,%esp
  800dd3:	53                   	push   %ebx
  800dd4:	ff 75 10             	pushl  0x10(%ebp)
  800dd7:	e8 38 f3 ff ff       	call   800114 <vcprintf>
	cprintf("\n");
  800ddc:	c7 04 24 6c 10 80 00 	movl   $0x80106c,(%esp)
  800de3:	e8 81 f3 ff ff       	call   800169 <cprintf>
  800de8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800deb:	cc                   	int3   
  800dec:	eb fd                	jmp    800deb <_panic+0x47>
  800dee:	66 90                	xchg   %ax,%ax

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
