
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
  80003d:	68 00 1f 80 00       	push   $0x801f00
  800042:	e8 2a 01 00 00       	call   800171 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800047:	a1 04 40 80 00       	mov    0x804004,%eax
  80004c:	8b 40 48             	mov    0x48(%eax),%eax
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	50                   	push   %eax
  800053:	68 0e 1f 80 00       	push   $0x801f0e
  800058:	e8 14 01 00 00       	call   800171 <cprintf>
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
  800071:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800078:	00 00 00 
    envid_t envid = sys_getenvid();
  80007b:	e8 f6 0a 00 00       	call   800b76 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  800080:	25 ff 03 00 00       	and    $0x3ff,%eax
  800085:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800088:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800092:	85 db                	test   %ebx,%ebx
  800094:	7e 07                	jle    80009d <libmain+0x3b>
		binaryname = argv[0];
  800096:	8b 06                	mov    (%esi),%eax
  800098:	a3 00 30 80 00       	mov    %eax,0x803000

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
  8000bd:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000c0:	e8 f7 0e 00 00       	call   800fbc <close_all>
	sys_env_destroy(0);
  8000c5:	83 ec 0c             	sub    $0xc,%esp
  8000c8:	6a 00                	push   $0x0
  8000ca:	e8 62 0a 00 00       	call   800b31 <sys_env_destroy>
}
  8000cf:	83 c4 10             	add    $0x10,%esp
  8000d2:	c9                   	leave  
  8000d3:	c3                   	ret    

008000d4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d4:	f3 0f 1e fb          	endbr32 
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 04             	sub    $0x4,%esp
  8000df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000e2:	8b 13                	mov    (%ebx),%edx
  8000e4:	8d 42 01             	lea    0x1(%edx),%eax
  8000e7:	89 03                	mov    %eax,(%ebx)
  8000e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ec:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000f0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000f5:	74 09                	je     800100 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000f7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000fe:	c9                   	leave  
  8000ff:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800100:	83 ec 08             	sub    $0x8,%esp
  800103:	68 ff 00 00 00       	push   $0xff
  800108:	8d 43 08             	lea    0x8(%ebx),%eax
  80010b:	50                   	push   %eax
  80010c:	e8 db 09 00 00       	call   800aec <sys_cputs>
		b->idx = 0;
  800111:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800117:	83 c4 10             	add    $0x10,%esp
  80011a:	eb db                	jmp    8000f7 <putch+0x23>

0080011c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80011c:	f3 0f 1e fb          	endbr32 
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800129:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800130:	00 00 00 
	b.cnt = 0;
  800133:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80013a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80013d:	ff 75 0c             	pushl  0xc(%ebp)
  800140:	ff 75 08             	pushl  0x8(%ebp)
  800143:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800149:	50                   	push   %eax
  80014a:	68 d4 00 80 00       	push   $0x8000d4
  80014f:	e8 20 01 00 00       	call   800274 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800154:	83 c4 08             	add    $0x8,%esp
  800157:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80015d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800163:	50                   	push   %eax
  800164:	e8 83 09 00 00       	call   800aec <sys_cputs>

	return b.cnt;
}
  800169:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80016f:	c9                   	leave  
  800170:	c3                   	ret    

00800171 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800171:	f3 0f 1e fb          	endbr32 
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80017b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80017e:	50                   	push   %eax
  80017f:	ff 75 08             	pushl  0x8(%ebp)
  800182:	e8 95 ff ff ff       	call   80011c <vcprintf>
	va_end(ap);

	return cnt;
}
  800187:	c9                   	leave  
  800188:	c3                   	ret    

00800189 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800189:	55                   	push   %ebp
  80018a:	89 e5                	mov    %esp,%ebp
  80018c:	57                   	push   %edi
  80018d:	56                   	push   %esi
  80018e:	53                   	push   %ebx
  80018f:	83 ec 1c             	sub    $0x1c,%esp
  800192:	89 c7                	mov    %eax,%edi
  800194:	89 d6                	mov    %edx,%esi
  800196:	8b 45 08             	mov    0x8(%ebp),%eax
  800199:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019c:	89 d1                	mov    %edx,%ecx
  80019e:	89 c2                	mov    %eax,%edx
  8001a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001a3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001af:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001b6:	39 c2                	cmp    %eax,%edx
  8001b8:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001bb:	72 3e                	jb     8001fb <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001bd:	83 ec 0c             	sub    $0xc,%esp
  8001c0:	ff 75 18             	pushl  0x18(%ebp)
  8001c3:	83 eb 01             	sub    $0x1,%ebx
  8001c6:	53                   	push   %ebx
  8001c7:	50                   	push   %eax
  8001c8:	83 ec 08             	sub    $0x8,%esp
  8001cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ce:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001d7:	e8 c4 1a 00 00       	call   801ca0 <__udivdi3>
  8001dc:	83 c4 18             	add    $0x18,%esp
  8001df:	52                   	push   %edx
  8001e0:	50                   	push   %eax
  8001e1:	89 f2                	mov    %esi,%edx
  8001e3:	89 f8                	mov    %edi,%eax
  8001e5:	e8 9f ff ff ff       	call   800189 <printnum>
  8001ea:	83 c4 20             	add    $0x20,%esp
  8001ed:	eb 13                	jmp    800202 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ef:	83 ec 08             	sub    $0x8,%esp
  8001f2:	56                   	push   %esi
  8001f3:	ff 75 18             	pushl  0x18(%ebp)
  8001f6:	ff d7                	call   *%edi
  8001f8:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001fb:	83 eb 01             	sub    $0x1,%ebx
  8001fe:	85 db                	test   %ebx,%ebx
  800200:	7f ed                	jg     8001ef <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800202:	83 ec 08             	sub    $0x8,%esp
  800205:	56                   	push   %esi
  800206:	83 ec 04             	sub    $0x4,%esp
  800209:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020c:	ff 75 e0             	pushl  -0x20(%ebp)
  80020f:	ff 75 dc             	pushl  -0x24(%ebp)
  800212:	ff 75 d8             	pushl  -0x28(%ebp)
  800215:	e8 96 1b 00 00       	call   801db0 <__umoddi3>
  80021a:	83 c4 14             	add    $0x14,%esp
  80021d:	0f be 80 2f 1f 80 00 	movsbl 0x801f2f(%eax),%eax
  800224:	50                   	push   %eax
  800225:	ff d7                	call   *%edi
}
  800227:	83 c4 10             	add    $0x10,%esp
  80022a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022d:	5b                   	pop    %ebx
  80022e:	5e                   	pop    %esi
  80022f:	5f                   	pop    %edi
  800230:	5d                   	pop    %ebp
  800231:	c3                   	ret    

00800232 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800232:	f3 0f 1e fb          	endbr32 
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80023c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800240:	8b 10                	mov    (%eax),%edx
  800242:	3b 50 04             	cmp    0x4(%eax),%edx
  800245:	73 0a                	jae    800251 <sprintputch+0x1f>
		*b->buf++ = ch;
  800247:	8d 4a 01             	lea    0x1(%edx),%ecx
  80024a:	89 08                	mov    %ecx,(%eax)
  80024c:	8b 45 08             	mov    0x8(%ebp),%eax
  80024f:	88 02                	mov    %al,(%edx)
}
  800251:	5d                   	pop    %ebp
  800252:	c3                   	ret    

00800253 <printfmt>:
{
  800253:	f3 0f 1e fb          	endbr32 
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80025d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800260:	50                   	push   %eax
  800261:	ff 75 10             	pushl  0x10(%ebp)
  800264:	ff 75 0c             	pushl  0xc(%ebp)
  800267:	ff 75 08             	pushl  0x8(%ebp)
  80026a:	e8 05 00 00 00       	call   800274 <vprintfmt>
}
  80026f:	83 c4 10             	add    $0x10,%esp
  800272:	c9                   	leave  
  800273:	c3                   	ret    

00800274 <vprintfmt>:
{
  800274:	f3 0f 1e fb          	endbr32 
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	57                   	push   %edi
  80027c:	56                   	push   %esi
  80027d:	53                   	push   %ebx
  80027e:	83 ec 3c             	sub    $0x3c,%esp
  800281:	8b 75 08             	mov    0x8(%ebp),%esi
  800284:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800287:	8b 7d 10             	mov    0x10(%ebp),%edi
  80028a:	e9 4a 03 00 00       	jmp    8005d9 <vprintfmt+0x365>
		padc = ' ';
  80028f:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800293:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80029a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002a1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002a8:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002ad:	8d 47 01             	lea    0x1(%edi),%eax
  8002b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002b3:	0f b6 17             	movzbl (%edi),%edx
  8002b6:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002b9:	3c 55                	cmp    $0x55,%al
  8002bb:	0f 87 de 03 00 00    	ja     80069f <vprintfmt+0x42b>
  8002c1:	0f b6 c0             	movzbl %al,%eax
  8002c4:	3e ff 24 85 80 20 80 	notrack jmp *0x802080(,%eax,4)
  8002cb:	00 
  8002cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002cf:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002d3:	eb d8                	jmp    8002ad <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8002d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002d8:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002dc:	eb cf                	jmp    8002ad <vprintfmt+0x39>
  8002de:	0f b6 d2             	movzbl %dl,%edx
  8002e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8002e9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002ec:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002ef:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002f3:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002f6:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002f9:	83 f9 09             	cmp    $0x9,%ecx
  8002fc:	77 55                	ja     800353 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8002fe:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800301:	eb e9                	jmp    8002ec <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800303:	8b 45 14             	mov    0x14(%ebp),%eax
  800306:	8b 00                	mov    (%eax),%eax
  800308:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80030b:	8b 45 14             	mov    0x14(%ebp),%eax
  80030e:	8d 40 04             	lea    0x4(%eax),%eax
  800311:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800314:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800317:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80031b:	79 90                	jns    8002ad <vprintfmt+0x39>
				width = precision, precision = -1;
  80031d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800320:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800323:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80032a:	eb 81                	jmp    8002ad <vprintfmt+0x39>
  80032c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80032f:	85 c0                	test   %eax,%eax
  800331:	ba 00 00 00 00       	mov    $0x0,%edx
  800336:	0f 49 d0             	cmovns %eax,%edx
  800339:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80033c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80033f:	e9 69 ff ff ff       	jmp    8002ad <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800344:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800347:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80034e:	e9 5a ff ff ff       	jmp    8002ad <vprintfmt+0x39>
  800353:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800356:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800359:	eb bc                	jmp    800317 <vprintfmt+0xa3>
			lflag++;
  80035b:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80035e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800361:	e9 47 ff ff ff       	jmp    8002ad <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800366:	8b 45 14             	mov    0x14(%ebp),%eax
  800369:	8d 78 04             	lea    0x4(%eax),%edi
  80036c:	83 ec 08             	sub    $0x8,%esp
  80036f:	53                   	push   %ebx
  800370:	ff 30                	pushl  (%eax)
  800372:	ff d6                	call   *%esi
			break;
  800374:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800377:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80037a:	e9 57 02 00 00       	jmp    8005d6 <vprintfmt+0x362>
			err = va_arg(ap, int);
  80037f:	8b 45 14             	mov    0x14(%ebp),%eax
  800382:	8d 78 04             	lea    0x4(%eax),%edi
  800385:	8b 00                	mov    (%eax),%eax
  800387:	99                   	cltd   
  800388:	31 d0                	xor    %edx,%eax
  80038a:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80038c:	83 f8 0f             	cmp    $0xf,%eax
  80038f:	7f 23                	jg     8003b4 <vprintfmt+0x140>
  800391:	8b 14 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%edx
  800398:	85 d2                	test   %edx,%edx
  80039a:	74 18                	je     8003b4 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80039c:	52                   	push   %edx
  80039d:	68 11 23 80 00       	push   $0x802311
  8003a2:	53                   	push   %ebx
  8003a3:	56                   	push   %esi
  8003a4:	e8 aa fe ff ff       	call   800253 <printfmt>
  8003a9:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003ac:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003af:	e9 22 02 00 00       	jmp    8005d6 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8003b4:	50                   	push   %eax
  8003b5:	68 47 1f 80 00       	push   $0x801f47
  8003ba:	53                   	push   %ebx
  8003bb:	56                   	push   %esi
  8003bc:	e8 92 fe ff ff       	call   800253 <printfmt>
  8003c1:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003c4:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003c7:	e9 0a 02 00 00       	jmp    8005d6 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8003cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cf:	83 c0 04             	add    $0x4,%eax
  8003d2:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d8:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003da:	85 d2                	test   %edx,%edx
  8003dc:	b8 40 1f 80 00       	mov    $0x801f40,%eax
  8003e1:	0f 45 c2             	cmovne %edx,%eax
  8003e4:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003e7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003eb:	7e 06                	jle    8003f3 <vprintfmt+0x17f>
  8003ed:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8003f1:	75 0d                	jne    800400 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003f3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003f6:	89 c7                	mov    %eax,%edi
  8003f8:	03 45 e0             	add    -0x20(%ebp),%eax
  8003fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003fe:	eb 55                	jmp    800455 <vprintfmt+0x1e1>
  800400:	83 ec 08             	sub    $0x8,%esp
  800403:	ff 75 d8             	pushl  -0x28(%ebp)
  800406:	ff 75 cc             	pushl  -0x34(%ebp)
  800409:	e8 45 03 00 00       	call   800753 <strnlen>
  80040e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800411:	29 c2                	sub    %eax,%edx
  800413:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800416:	83 c4 10             	add    $0x10,%esp
  800419:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80041b:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80041f:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800422:	85 ff                	test   %edi,%edi
  800424:	7e 11                	jle    800437 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800426:	83 ec 08             	sub    $0x8,%esp
  800429:	53                   	push   %ebx
  80042a:	ff 75 e0             	pushl  -0x20(%ebp)
  80042d:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80042f:	83 ef 01             	sub    $0x1,%edi
  800432:	83 c4 10             	add    $0x10,%esp
  800435:	eb eb                	jmp    800422 <vprintfmt+0x1ae>
  800437:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80043a:	85 d2                	test   %edx,%edx
  80043c:	b8 00 00 00 00       	mov    $0x0,%eax
  800441:	0f 49 c2             	cmovns %edx,%eax
  800444:	29 c2                	sub    %eax,%edx
  800446:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800449:	eb a8                	jmp    8003f3 <vprintfmt+0x17f>
					putch(ch, putdat);
  80044b:	83 ec 08             	sub    $0x8,%esp
  80044e:	53                   	push   %ebx
  80044f:	52                   	push   %edx
  800450:	ff d6                	call   *%esi
  800452:	83 c4 10             	add    $0x10,%esp
  800455:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800458:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80045a:	83 c7 01             	add    $0x1,%edi
  80045d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800461:	0f be d0             	movsbl %al,%edx
  800464:	85 d2                	test   %edx,%edx
  800466:	74 4b                	je     8004b3 <vprintfmt+0x23f>
  800468:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80046c:	78 06                	js     800474 <vprintfmt+0x200>
  80046e:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800472:	78 1e                	js     800492 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800474:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800478:	74 d1                	je     80044b <vprintfmt+0x1d7>
  80047a:	0f be c0             	movsbl %al,%eax
  80047d:	83 e8 20             	sub    $0x20,%eax
  800480:	83 f8 5e             	cmp    $0x5e,%eax
  800483:	76 c6                	jbe    80044b <vprintfmt+0x1d7>
					putch('?', putdat);
  800485:	83 ec 08             	sub    $0x8,%esp
  800488:	53                   	push   %ebx
  800489:	6a 3f                	push   $0x3f
  80048b:	ff d6                	call   *%esi
  80048d:	83 c4 10             	add    $0x10,%esp
  800490:	eb c3                	jmp    800455 <vprintfmt+0x1e1>
  800492:	89 cf                	mov    %ecx,%edi
  800494:	eb 0e                	jmp    8004a4 <vprintfmt+0x230>
				putch(' ', putdat);
  800496:	83 ec 08             	sub    $0x8,%esp
  800499:	53                   	push   %ebx
  80049a:	6a 20                	push   $0x20
  80049c:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80049e:	83 ef 01             	sub    $0x1,%edi
  8004a1:	83 c4 10             	add    $0x10,%esp
  8004a4:	85 ff                	test   %edi,%edi
  8004a6:	7f ee                	jg     800496 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8004a8:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004ab:	89 45 14             	mov    %eax,0x14(%ebp)
  8004ae:	e9 23 01 00 00       	jmp    8005d6 <vprintfmt+0x362>
  8004b3:	89 cf                	mov    %ecx,%edi
  8004b5:	eb ed                	jmp    8004a4 <vprintfmt+0x230>
	if (lflag >= 2)
  8004b7:	83 f9 01             	cmp    $0x1,%ecx
  8004ba:	7f 1b                	jg     8004d7 <vprintfmt+0x263>
	else if (lflag)
  8004bc:	85 c9                	test   %ecx,%ecx
  8004be:	74 63                	je     800523 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8004c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c3:	8b 00                	mov    (%eax),%eax
  8004c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004c8:	99                   	cltd   
  8004c9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cf:	8d 40 04             	lea    0x4(%eax),%eax
  8004d2:	89 45 14             	mov    %eax,0x14(%ebp)
  8004d5:	eb 17                	jmp    8004ee <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8004d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004da:	8b 50 04             	mov    0x4(%eax),%edx
  8004dd:	8b 00                	mov    (%eax),%eax
  8004df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004e2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e8:	8d 40 08             	lea    0x8(%eax),%eax
  8004eb:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004ee:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004f1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8004f4:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8004f9:	85 c9                	test   %ecx,%ecx
  8004fb:	0f 89 bb 00 00 00    	jns    8005bc <vprintfmt+0x348>
				putch('-', putdat);
  800501:	83 ec 08             	sub    $0x8,%esp
  800504:	53                   	push   %ebx
  800505:	6a 2d                	push   $0x2d
  800507:	ff d6                	call   *%esi
				num = -(long long) num;
  800509:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80050c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80050f:	f7 da                	neg    %edx
  800511:	83 d1 00             	adc    $0x0,%ecx
  800514:	f7 d9                	neg    %ecx
  800516:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800519:	b8 0a 00 00 00       	mov    $0xa,%eax
  80051e:	e9 99 00 00 00       	jmp    8005bc <vprintfmt+0x348>
		return va_arg(*ap, int);
  800523:	8b 45 14             	mov    0x14(%ebp),%eax
  800526:	8b 00                	mov    (%eax),%eax
  800528:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80052b:	99                   	cltd   
  80052c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80052f:	8b 45 14             	mov    0x14(%ebp),%eax
  800532:	8d 40 04             	lea    0x4(%eax),%eax
  800535:	89 45 14             	mov    %eax,0x14(%ebp)
  800538:	eb b4                	jmp    8004ee <vprintfmt+0x27a>
	if (lflag >= 2)
  80053a:	83 f9 01             	cmp    $0x1,%ecx
  80053d:	7f 1b                	jg     80055a <vprintfmt+0x2e6>
	else if (lflag)
  80053f:	85 c9                	test   %ecx,%ecx
  800541:	74 2c                	je     80056f <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800543:	8b 45 14             	mov    0x14(%ebp),%eax
  800546:	8b 10                	mov    (%eax),%edx
  800548:	b9 00 00 00 00       	mov    $0x0,%ecx
  80054d:	8d 40 04             	lea    0x4(%eax),%eax
  800550:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800553:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800558:	eb 62                	jmp    8005bc <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80055a:	8b 45 14             	mov    0x14(%ebp),%eax
  80055d:	8b 10                	mov    (%eax),%edx
  80055f:	8b 48 04             	mov    0x4(%eax),%ecx
  800562:	8d 40 08             	lea    0x8(%eax),%eax
  800565:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800568:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80056d:	eb 4d                	jmp    8005bc <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80056f:	8b 45 14             	mov    0x14(%ebp),%eax
  800572:	8b 10                	mov    (%eax),%edx
  800574:	b9 00 00 00 00       	mov    $0x0,%ecx
  800579:	8d 40 04             	lea    0x4(%eax),%eax
  80057c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80057f:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800584:	eb 36                	jmp    8005bc <vprintfmt+0x348>
	if (lflag >= 2)
  800586:	83 f9 01             	cmp    $0x1,%ecx
  800589:	7f 17                	jg     8005a2 <vprintfmt+0x32e>
	else if (lflag)
  80058b:	85 c9                	test   %ecx,%ecx
  80058d:	74 6e                	je     8005fd <vprintfmt+0x389>
		return va_arg(*ap, long);
  80058f:	8b 45 14             	mov    0x14(%ebp),%eax
  800592:	8b 10                	mov    (%eax),%edx
  800594:	89 d0                	mov    %edx,%eax
  800596:	99                   	cltd   
  800597:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80059a:	8d 49 04             	lea    0x4(%ecx),%ecx
  80059d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005a0:	eb 11                	jmp    8005b3 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8b 50 04             	mov    0x4(%eax),%edx
  8005a8:	8b 00                	mov    (%eax),%eax
  8005aa:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005ad:	8d 49 08             	lea    0x8(%ecx),%ecx
  8005b0:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8005b3:	89 d1                	mov    %edx,%ecx
  8005b5:	89 c2                	mov    %eax,%edx
            base = 8;
  8005b7:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005bc:	83 ec 0c             	sub    $0xc,%esp
  8005bf:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005c3:	57                   	push   %edi
  8005c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8005c7:	50                   	push   %eax
  8005c8:	51                   	push   %ecx
  8005c9:	52                   	push   %edx
  8005ca:	89 da                	mov    %ebx,%edx
  8005cc:	89 f0                	mov    %esi,%eax
  8005ce:	e8 b6 fb ff ff       	call   800189 <printnum>
			break;
  8005d3:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8005d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005d9:	83 c7 01             	add    $0x1,%edi
  8005dc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005e0:	83 f8 25             	cmp    $0x25,%eax
  8005e3:	0f 84 a6 fc ff ff    	je     80028f <vprintfmt+0x1b>
			if (ch == '\0')
  8005e9:	85 c0                	test   %eax,%eax
  8005eb:	0f 84 ce 00 00 00    	je     8006bf <vprintfmt+0x44b>
			putch(ch, putdat);
  8005f1:	83 ec 08             	sub    $0x8,%esp
  8005f4:	53                   	push   %ebx
  8005f5:	50                   	push   %eax
  8005f6:	ff d6                	call   *%esi
  8005f8:	83 c4 10             	add    $0x10,%esp
  8005fb:	eb dc                	jmp    8005d9 <vprintfmt+0x365>
		return va_arg(*ap, int);
  8005fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800600:	8b 10                	mov    (%eax),%edx
  800602:	89 d0                	mov    %edx,%eax
  800604:	99                   	cltd   
  800605:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800608:	8d 49 04             	lea    0x4(%ecx),%ecx
  80060b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80060e:	eb a3                	jmp    8005b3 <vprintfmt+0x33f>
			putch('0', putdat);
  800610:	83 ec 08             	sub    $0x8,%esp
  800613:	53                   	push   %ebx
  800614:	6a 30                	push   $0x30
  800616:	ff d6                	call   *%esi
			putch('x', putdat);
  800618:	83 c4 08             	add    $0x8,%esp
  80061b:	53                   	push   %ebx
  80061c:	6a 78                	push   $0x78
  80061e:	ff d6                	call   *%esi
			num = (unsigned long long)
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8b 10                	mov    (%eax),%edx
  800625:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80062a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80062d:	8d 40 04             	lea    0x4(%eax),%eax
  800630:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800633:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800638:	eb 82                	jmp    8005bc <vprintfmt+0x348>
	if (lflag >= 2)
  80063a:	83 f9 01             	cmp    $0x1,%ecx
  80063d:	7f 1e                	jg     80065d <vprintfmt+0x3e9>
	else if (lflag)
  80063f:	85 c9                	test   %ecx,%ecx
  800641:	74 32                	je     800675 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800643:	8b 45 14             	mov    0x14(%ebp),%eax
  800646:	8b 10                	mov    (%eax),%edx
  800648:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064d:	8d 40 04             	lea    0x4(%eax),%eax
  800650:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800653:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800658:	e9 5f ff ff ff       	jmp    8005bc <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80065d:	8b 45 14             	mov    0x14(%ebp),%eax
  800660:	8b 10                	mov    (%eax),%edx
  800662:	8b 48 04             	mov    0x4(%eax),%ecx
  800665:	8d 40 08             	lea    0x8(%eax),%eax
  800668:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80066b:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800670:	e9 47 ff ff ff       	jmp    8005bc <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800675:	8b 45 14             	mov    0x14(%ebp),%eax
  800678:	8b 10                	mov    (%eax),%edx
  80067a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067f:	8d 40 04             	lea    0x4(%eax),%eax
  800682:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800685:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80068a:	e9 2d ff ff ff       	jmp    8005bc <vprintfmt+0x348>
			putch(ch, putdat);
  80068f:	83 ec 08             	sub    $0x8,%esp
  800692:	53                   	push   %ebx
  800693:	6a 25                	push   $0x25
  800695:	ff d6                	call   *%esi
			break;
  800697:	83 c4 10             	add    $0x10,%esp
  80069a:	e9 37 ff ff ff       	jmp    8005d6 <vprintfmt+0x362>
			putch('%', putdat);
  80069f:	83 ec 08             	sub    $0x8,%esp
  8006a2:	53                   	push   %ebx
  8006a3:	6a 25                	push   $0x25
  8006a5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006a7:	83 c4 10             	add    $0x10,%esp
  8006aa:	89 f8                	mov    %edi,%eax
  8006ac:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006b0:	74 05                	je     8006b7 <vprintfmt+0x443>
  8006b2:	83 e8 01             	sub    $0x1,%eax
  8006b5:	eb f5                	jmp    8006ac <vprintfmt+0x438>
  8006b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006ba:	e9 17 ff ff ff       	jmp    8005d6 <vprintfmt+0x362>
}
  8006bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c2:	5b                   	pop    %ebx
  8006c3:	5e                   	pop    %esi
  8006c4:	5f                   	pop    %edi
  8006c5:	5d                   	pop    %ebp
  8006c6:	c3                   	ret    

008006c7 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006c7:	f3 0f 1e fb          	endbr32 
  8006cb:	55                   	push   %ebp
  8006cc:	89 e5                	mov    %esp,%ebp
  8006ce:	83 ec 18             	sub    $0x18,%esp
  8006d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006da:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006de:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006e8:	85 c0                	test   %eax,%eax
  8006ea:	74 26                	je     800712 <vsnprintf+0x4b>
  8006ec:	85 d2                	test   %edx,%edx
  8006ee:	7e 22                	jle    800712 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f0:	ff 75 14             	pushl  0x14(%ebp)
  8006f3:	ff 75 10             	pushl  0x10(%ebp)
  8006f6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f9:	50                   	push   %eax
  8006fa:	68 32 02 80 00       	push   $0x800232
  8006ff:	e8 70 fb ff ff       	call   800274 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800704:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800707:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80070a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80070d:	83 c4 10             	add    $0x10,%esp
}
  800710:	c9                   	leave  
  800711:	c3                   	ret    
		return -E_INVAL;
  800712:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800717:	eb f7                	jmp    800710 <vsnprintf+0x49>

00800719 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800719:	f3 0f 1e fb          	endbr32 
  80071d:	55                   	push   %ebp
  80071e:	89 e5                	mov    %esp,%ebp
  800720:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800723:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800726:	50                   	push   %eax
  800727:	ff 75 10             	pushl  0x10(%ebp)
  80072a:	ff 75 0c             	pushl  0xc(%ebp)
  80072d:	ff 75 08             	pushl  0x8(%ebp)
  800730:	e8 92 ff ff ff       	call   8006c7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800735:	c9                   	leave  
  800736:	c3                   	ret    

00800737 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800737:	f3 0f 1e fb          	endbr32 
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800741:	b8 00 00 00 00       	mov    $0x0,%eax
  800746:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80074a:	74 05                	je     800751 <strlen+0x1a>
		n++;
  80074c:	83 c0 01             	add    $0x1,%eax
  80074f:	eb f5                	jmp    800746 <strlen+0xf>
	return n;
}
  800751:	5d                   	pop    %ebp
  800752:	c3                   	ret    

00800753 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800753:	f3 0f 1e fb          	endbr32 
  800757:	55                   	push   %ebp
  800758:	89 e5                	mov    %esp,%ebp
  80075a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075d:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800760:	b8 00 00 00 00       	mov    $0x0,%eax
  800765:	39 d0                	cmp    %edx,%eax
  800767:	74 0d                	je     800776 <strnlen+0x23>
  800769:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80076d:	74 05                	je     800774 <strnlen+0x21>
		n++;
  80076f:	83 c0 01             	add    $0x1,%eax
  800772:	eb f1                	jmp    800765 <strnlen+0x12>
  800774:	89 c2                	mov    %eax,%edx
	return n;
}
  800776:	89 d0                	mov    %edx,%eax
  800778:	5d                   	pop    %ebp
  800779:	c3                   	ret    

0080077a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80077a:	f3 0f 1e fb          	endbr32 
  80077e:	55                   	push   %ebp
  80077f:	89 e5                	mov    %esp,%ebp
  800781:	53                   	push   %ebx
  800782:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800785:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800788:	b8 00 00 00 00       	mov    $0x0,%eax
  80078d:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800791:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800794:	83 c0 01             	add    $0x1,%eax
  800797:	84 d2                	test   %dl,%dl
  800799:	75 f2                	jne    80078d <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80079b:	89 c8                	mov    %ecx,%eax
  80079d:	5b                   	pop    %ebx
  80079e:	5d                   	pop    %ebp
  80079f:	c3                   	ret    

008007a0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a0:	f3 0f 1e fb          	endbr32 
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
  8007a7:	53                   	push   %ebx
  8007a8:	83 ec 10             	sub    $0x10,%esp
  8007ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ae:	53                   	push   %ebx
  8007af:	e8 83 ff ff ff       	call   800737 <strlen>
  8007b4:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007b7:	ff 75 0c             	pushl  0xc(%ebp)
  8007ba:	01 d8                	add    %ebx,%eax
  8007bc:	50                   	push   %eax
  8007bd:	e8 b8 ff ff ff       	call   80077a <strcpy>
	return dst;
}
  8007c2:	89 d8                	mov    %ebx,%eax
  8007c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c7:	c9                   	leave  
  8007c8:	c3                   	ret    

008007c9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c9:	f3 0f 1e fb          	endbr32 
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	56                   	push   %esi
  8007d1:	53                   	push   %ebx
  8007d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d8:	89 f3                	mov    %esi,%ebx
  8007da:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007dd:	89 f0                	mov    %esi,%eax
  8007df:	39 d8                	cmp    %ebx,%eax
  8007e1:	74 11                	je     8007f4 <strncpy+0x2b>
		*dst++ = *src;
  8007e3:	83 c0 01             	add    $0x1,%eax
  8007e6:	0f b6 0a             	movzbl (%edx),%ecx
  8007e9:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ec:	80 f9 01             	cmp    $0x1,%cl
  8007ef:	83 da ff             	sbb    $0xffffffff,%edx
  8007f2:	eb eb                	jmp    8007df <strncpy+0x16>
	}
	return ret;
}
  8007f4:	89 f0                	mov    %esi,%eax
  8007f6:	5b                   	pop    %ebx
  8007f7:	5e                   	pop    %esi
  8007f8:	5d                   	pop    %ebp
  8007f9:	c3                   	ret    

008007fa <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007fa:	f3 0f 1e fb          	endbr32 
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	56                   	push   %esi
  800802:	53                   	push   %ebx
  800803:	8b 75 08             	mov    0x8(%ebp),%esi
  800806:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800809:	8b 55 10             	mov    0x10(%ebp),%edx
  80080c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80080e:	85 d2                	test   %edx,%edx
  800810:	74 21                	je     800833 <strlcpy+0x39>
  800812:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800816:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800818:	39 c2                	cmp    %eax,%edx
  80081a:	74 14                	je     800830 <strlcpy+0x36>
  80081c:	0f b6 19             	movzbl (%ecx),%ebx
  80081f:	84 db                	test   %bl,%bl
  800821:	74 0b                	je     80082e <strlcpy+0x34>
			*dst++ = *src++;
  800823:	83 c1 01             	add    $0x1,%ecx
  800826:	83 c2 01             	add    $0x1,%edx
  800829:	88 5a ff             	mov    %bl,-0x1(%edx)
  80082c:	eb ea                	jmp    800818 <strlcpy+0x1e>
  80082e:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800830:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800833:	29 f0                	sub    %esi,%eax
}
  800835:	5b                   	pop    %ebx
  800836:	5e                   	pop    %esi
  800837:	5d                   	pop    %ebp
  800838:	c3                   	ret    

00800839 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800839:	f3 0f 1e fb          	endbr32 
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800843:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800846:	0f b6 01             	movzbl (%ecx),%eax
  800849:	84 c0                	test   %al,%al
  80084b:	74 0c                	je     800859 <strcmp+0x20>
  80084d:	3a 02                	cmp    (%edx),%al
  80084f:	75 08                	jne    800859 <strcmp+0x20>
		p++, q++;
  800851:	83 c1 01             	add    $0x1,%ecx
  800854:	83 c2 01             	add    $0x1,%edx
  800857:	eb ed                	jmp    800846 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800859:	0f b6 c0             	movzbl %al,%eax
  80085c:	0f b6 12             	movzbl (%edx),%edx
  80085f:	29 d0                	sub    %edx,%eax
}
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800863:	f3 0f 1e fb          	endbr32 
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	53                   	push   %ebx
  80086b:	8b 45 08             	mov    0x8(%ebp),%eax
  80086e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800871:	89 c3                	mov    %eax,%ebx
  800873:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800876:	eb 06                	jmp    80087e <strncmp+0x1b>
		n--, p++, q++;
  800878:	83 c0 01             	add    $0x1,%eax
  80087b:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80087e:	39 d8                	cmp    %ebx,%eax
  800880:	74 16                	je     800898 <strncmp+0x35>
  800882:	0f b6 08             	movzbl (%eax),%ecx
  800885:	84 c9                	test   %cl,%cl
  800887:	74 04                	je     80088d <strncmp+0x2a>
  800889:	3a 0a                	cmp    (%edx),%cl
  80088b:	74 eb                	je     800878 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088d:	0f b6 00             	movzbl (%eax),%eax
  800890:	0f b6 12             	movzbl (%edx),%edx
  800893:	29 d0                	sub    %edx,%eax
}
  800895:	5b                   	pop    %ebx
  800896:	5d                   	pop    %ebp
  800897:	c3                   	ret    
		return 0;
  800898:	b8 00 00 00 00       	mov    $0x0,%eax
  80089d:	eb f6                	jmp    800895 <strncmp+0x32>

0080089f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80089f:	f3 0f 1e fb          	endbr32 
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ad:	0f b6 10             	movzbl (%eax),%edx
  8008b0:	84 d2                	test   %dl,%dl
  8008b2:	74 09                	je     8008bd <strchr+0x1e>
		if (*s == c)
  8008b4:	38 ca                	cmp    %cl,%dl
  8008b6:	74 0a                	je     8008c2 <strchr+0x23>
	for (; *s; s++)
  8008b8:	83 c0 01             	add    $0x1,%eax
  8008bb:	eb f0                	jmp    8008ad <strchr+0xe>
			return (char *) s;
	return 0;
  8008bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    

008008c4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c4:	f3 0f 1e fb          	endbr32 
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ce:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d5:	38 ca                	cmp    %cl,%dl
  8008d7:	74 09                	je     8008e2 <strfind+0x1e>
  8008d9:	84 d2                	test   %dl,%dl
  8008db:	74 05                	je     8008e2 <strfind+0x1e>
	for (; *s; s++)
  8008dd:	83 c0 01             	add    $0x1,%eax
  8008e0:	eb f0                	jmp    8008d2 <strfind+0xe>
			break;
	return (char *) s;
}
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e4:	f3 0f 1e fb          	endbr32 
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	57                   	push   %edi
  8008ec:	56                   	push   %esi
  8008ed:	53                   	push   %ebx
  8008ee:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008f4:	85 c9                	test   %ecx,%ecx
  8008f6:	74 31                	je     800929 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f8:	89 f8                	mov    %edi,%eax
  8008fa:	09 c8                	or     %ecx,%eax
  8008fc:	a8 03                	test   $0x3,%al
  8008fe:	75 23                	jne    800923 <memset+0x3f>
		c &= 0xFF;
  800900:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800904:	89 d3                	mov    %edx,%ebx
  800906:	c1 e3 08             	shl    $0x8,%ebx
  800909:	89 d0                	mov    %edx,%eax
  80090b:	c1 e0 18             	shl    $0x18,%eax
  80090e:	89 d6                	mov    %edx,%esi
  800910:	c1 e6 10             	shl    $0x10,%esi
  800913:	09 f0                	or     %esi,%eax
  800915:	09 c2                	or     %eax,%edx
  800917:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800919:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80091c:	89 d0                	mov    %edx,%eax
  80091e:	fc                   	cld    
  80091f:	f3 ab                	rep stos %eax,%es:(%edi)
  800921:	eb 06                	jmp    800929 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800923:	8b 45 0c             	mov    0xc(%ebp),%eax
  800926:	fc                   	cld    
  800927:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800929:	89 f8                	mov    %edi,%eax
  80092b:	5b                   	pop    %ebx
  80092c:	5e                   	pop    %esi
  80092d:	5f                   	pop    %edi
  80092e:	5d                   	pop    %ebp
  80092f:	c3                   	ret    

00800930 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800930:	f3 0f 1e fb          	endbr32 
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	57                   	push   %edi
  800938:	56                   	push   %esi
  800939:	8b 45 08             	mov    0x8(%ebp),%eax
  80093c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80093f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800942:	39 c6                	cmp    %eax,%esi
  800944:	73 32                	jae    800978 <memmove+0x48>
  800946:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800949:	39 c2                	cmp    %eax,%edx
  80094b:	76 2b                	jbe    800978 <memmove+0x48>
		s += n;
		d += n;
  80094d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800950:	89 fe                	mov    %edi,%esi
  800952:	09 ce                	or     %ecx,%esi
  800954:	09 d6                	or     %edx,%esi
  800956:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80095c:	75 0e                	jne    80096c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80095e:	83 ef 04             	sub    $0x4,%edi
  800961:	8d 72 fc             	lea    -0x4(%edx),%esi
  800964:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800967:	fd                   	std    
  800968:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096a:	eb 09                	jmp    800975 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80096c:	83 ef 01             	sub    $0x1,%edi
  80096f:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800972:	fd                   	std    
  800973:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800975:	fc                   	cld    
  800976:	eb 1a                	jmp    800992 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800978:	89 c2                	mov    %eax,%edx
  80097a:	09 ca                	or     %ecx,%edx
  80097c:	09 f2                	or     %esi,%edx
  80097e:	f6 c2 03             	test   $0x3,%dl
  800981:	75 0a                	jne    80098d <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800983:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800986:	89 c7                	mov    %eax,%edi
  800988:	fc                   	cld    
  800989:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098b:	eb 05                	jmp    800992 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  80098d:	89 c7                	mov    %eax,%edi
  80098f:	fc                   	cld    
  800990:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800992:	5e                   	pop    %esi
  800993:	5f                   	pop    %edi
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800996:	f3 0f 1e fb          	endbr32 
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009a0:	ff 75 10             	pushl  0x10(%ebp)
  8009a3:	ff 75 0c             	pushl  0xc(%ebp)
  8009a6:	ff 75 08             	pushl  0x8(%ebp)
  8009a9:	e8 82 ff ff ff       	call   800930 <memmove>
}
  8009ae:	c9                   	leave  
  8009af:	c3                   	ret    

008009b0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b0:	f3 0f 1e fb          	endbr32 
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	56                   	push   %esi
  8009b8:	53                   	push   %ebx
  8009b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009bf:	89 c6                	mov    %eax,%esi
  8009c1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c4:	39 f0                	cmp    %esi,%eax
  8009c6:	74 1c                	je     8009e4 <memcmp+0x34>
		if (*s1 != *s2)
  8009c8:	0f b6 08             	movzbl (%eax),%ecx
  8009cb:	0f b6 1a             	movzbl (%edx),%ebx
  8009ce:	38 d9                	cmp    %bl,%cl
  8009d0:	75 08                	jne    8009da <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009d2:	83 c0 01             	add    $0x1,%eax
  8009d5:	83 c2 01             	add    $0x1,%edx
  8009d8:	eb ea                	jmp    8009c4 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  8009da:	0f b6 c1             	movzbl %cl,%eax
  8009dd:	0f b6 db             	movzbl %bl,%ebx
  8009e0:	29 d8                	sub    %ebx,%eax
  8009e2:	eb 05                	jmp    8009e9 <memcmp+0x39>
	}

	return 0;
  8009e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e9:	5b                   	pop    %ebx
  8009ea:	5e                   	pop    %esi
  8009eb:	5d                   	pop    %ebp
  8009ec:	c3                   	ret    

008009ed <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ed:	f3 0f 1e fb          	endbr32 
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009fa:	89 c2                	mov    %eax,%edx
  8009fc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009ff:	39 d0                	cmp    %edx,%eax
  800a01:	73 09                	jae    800a0c <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a03:	38 08                	cmp    %cl,(%eax)
  800a05:	74 05                	je     800a0c <memfind+0x1f>
	for (; s < ends; s++)
  800a07:	83 c0 01             	add    $0x1,%eax
  800a0a:	eb f3                	jmp    8009ff <memfind+0x12>
			break;
	return (void *) s;
}
  800a0c:	5d                   	pop    %ebp
  800a0d:	c3                   	ret    

00800a0e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a0e:	f3 0f 1e fb          	endbr32 
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	57                   	push   %edi
  800a16:	56                   	push   %esi
  800a17:	53                   	push   %ebx
  800a18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1e:	eb 03                	jmp    800a23 <strtol+0x15>
		s++;
  800a20:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a23:	0f b6 01             	movzbl (%ecx),%eax
  800a26:	3c 20                	cmp    $0x20,%al
  800a28:	74 f6                	je     800a20 <strtol+0x12>
  800a2a:	3c 09                	cmp    $0x9,%al
  800a2c:	74 f2                	je     800a20 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a2e:	3c 2b                	cmp    $0x2b,%al
  800a30:	74 2a                	je     800a5c <strtol+0x4e>
	int neg = 0;
  800a32:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a37:	3c 2d                	cmp    $0x2d,%al
  800a39:	74 2b                	je     800a66 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a41:	75 0f                	jne    800a52 <strtol+0x44>
  800a43:	80 39 30             	cmpb   $0x30,(%ecx)
  800a46:	74 28                	je     800a70 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a48:	85 db                	test   %ebx,%ebx
  800a4a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a4f:	0f 44 d8             	cmove  %eax,%ebx
  800a52:	b8 00 00 00 00       	mov    $0x0,%eax
  800a57:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a5a:	eb 46                	jmp    800aa2 <strtol+0x94>
		s++;
  800a5c:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a5f:	bf 00 00 00 00       	mov    $0x0,%edi
  800a64:	eb d5                	jmp    800a3b <strtol+0x2d>
		s++, neg = 1;
  800a66:	83 c1 01             	add    $0x1,%ecx
  800a69:	bf 01 00 00 00       	mov    $0x1,%edi
  800a6e:	eb cb                	jmp    800a3b <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a70:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a74:	74 0e                	je     800a84 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a76:	85 db                	test   %ebx,%ebx
  800a78:	75 d8                	jne    800a52 <strtol+0x44>
		s++, base = 8;
  800a7a:	83 c1 01             	add    $0x1,%ecx
  800a7d:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a82:	eb ce                	jmp    800a52 <strtol+0x44>
		s += 2, base = 16;
  800a84:	83 c1 02             	add    $0x2,%ecx
  800a87:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a8c:	eb c4                	jmp    800a52 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a8e:	0f be d2             	movsbl %dl,%edx
  800a91:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a94:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a97:	7d 3a                	jge    800ad3 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a99:	83 c1 01             	add    $0x1,%ecx
  800a9c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aa0:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800aa2:	0f b6 11             	movzbl (%ecx),%edx
  800aa5:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aa8:	89 f3                	mov    %esi,%ebx
  800aaa:	80 fb 09             	cmp    $0x9,%bl
  800aad:	76 df                	jbe    800a8e <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800aaf:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab2:	89 f3                	mov    %esi,%ebx
  800ab4:	80 fb 19             	cmp    $0x19,%bl
  800ab7:	77 08                	ja     800ac1 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ab9:	0f be d2             	movsbl %dl,%edx
  800abc:	83 ea 57             	sub    $0x57,%edx
  800abf:	eb d3                	jmp    800a94 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800ac1:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac4:	89 f3                	mov    %esi,%ebx
  800ac6:	80 fb 19             	cmp    $0x19,%bl
  800ac9:	77 08                	ja     800ad3 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800acb:	0f be d2             	movsbl %dl,%edx
  800ace:	83 ea 37             	sub    $0x37,%edx
  800ad1:	eb c1                	jmp    800a94 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ad3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad7:	74 05                	je     800ade <strtol+0xd0>
		*endptr = (char *) s;
  800ad9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800adc:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ade:	89 c2                	mov    %eax,%edx
  800ae0:	f7 da                	neg    %edx
  800ae2:	85 ff                	test   %edi,%edi
  800ae4:	0f 45 c2             	cmovne %edx,%eax
}
  800ae7:	5b                   	pop    %ebx
  800ae8:	5e                   	pop    %esi
  800ae9:	5f                   	pop    %edi
  800aea:	5d                   	pop    %ebp
  800aeb:	c3                   	ret    

00800aec <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aec:	f3 0f 1e fb          	endbr32 
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	57                   	push   %edi
  800af4:	56                   	push   %esi
  800af5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800af6:	b8 00 00 00 00       	mov    $0x0,%eax
  800afb:	8b 55 08             	mov    0x8(%ebp),%edx
  800afe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b01:	89 c3                	mov    %eax,%ebx
  800b03:	89 c7                	mov    %eax,%edi
  800b05:	89 c6                	mov    %eax,%esi
  800b07:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b09:	5b                   	pop    %ebx
  800b0a:	5e                   	pop    %esi
  800b0b:	5f                   	pop    %edi
  800b0c:	5d                   	pop    %ebp
  800b0d:	c3                   	ret    

00800b0e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b0e:	f3 0f 1e fb          	endbr32 
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	57                   	push   %edi
  800b16:	56                   	push   %esi
  800b17:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b18:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b22:	89 d1                	mov    %edx,%ecx
  800b24:	89 d3                	mov    %edx,%ebx
  800b26:	89 d7                	mov    %edx,%edi
  800b28:	89 d6                	mov    %edx,%esi
  800b2a:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b2c:	5b                   	pop    %ebx
  800b2d:	5e                   	pop    %esi
  800b2e:	5f                   	pop    %edi
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    

00800b31 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b31:	f3 0f 1e fb          	endbr32 
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	57                   	push   %edi
  800b39:	56                   	push   %esi
  800b3a:	53                   	push   %ebx
  800b3b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b3e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b43:	8b 55 08             	mov    0x8(%ebp),%edx
  800b46:	b8 03 00 00 00       	mov    $0x3,%eax
  800b4b:	89 cb                	mov    %ecx,%ebx
  800b4d:	89 cf                	mov    %ecx,%edi
  800b4f:	89 ce                	mov    %ecx,%esi
  800b51:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b53:	85 c0                	test   %eax,%eax
  800b55:	7f 08                	jg     800b5f <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5a:	5b                   	pop    %ebx
  800b5b:	5e                   	pop    %esi
  800b5c:	5f                   	pop    %edi
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5f:	83 ec 0c             	sub    $0xc,%esp
  800b62:	50                   	push   %eax
  800b63:	6a 03                	push   $0x3
  800b65:	68 3f 22 80 00       	push   $0x80223f
  800b6a:	6a 23                	push   $0x23
  800b6c:	68 5c 22 80 00       	push   $0x80225c
  800b71:	e8 9c 0f 00 00       	call   801b12 <_panic>

00800b76 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b76:	f3 0f 1e fb          	endbr32 
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	57                   	push   %edi
  800b7e:	56                   	push   %esi
  800b7f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b80:	ba 00 00 00 00       	mov    $0x0,%edx
  800b85:	b8 02 00 00 00       	mov    $0x2,%eax
  800b8a:	89 d1                	mov    %edx,%ecx
  800b8c:	89 d3                	mov    %edx,%ebx
  800b8e:	89 d7                	mov    %edx,%edi
  800b90:	89 d6                	mov    %edx,%esi
  800b92:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b94:	5b                   	pop    %ebx
  800b95:	5e                   	pop    %esi
  800b96:	5f                   	pop    %edi
  800b97:	5d                   	pop    %ebp
  800b98:	c3                   	ret    

00800b99 <sys_yield>:

void
sys_yield(void)
{
  800b99:	f3 0f 1e fb          	endbr32 
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ba3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba8:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bad:	89 d1                	mov    %edx,%ecx
  800baf:	89 d3                	mov    %edx,%ebx
  800bb1:	89 d7                	mov    %edx,%edi
  800bb3:	89 d6                	mov    %edx,%esi
  800bb5:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb7:	5b                   	pop    %ebx
  800bb8:	5e                   	pop    %esi
  800bb9:	5f                   	pop    %edi
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    

00800bbc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bbc:	f3 0f 1e fb          	endbr32 
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	57                   	push   %edi
  800bc4:	56                   	push   %esi
  800bc5:	53                   	push   %ebx
  800bc6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bc9:	be 00 00 00 00       	mov    $0x0,%esi
  800bce:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd4:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bdc:	89 f7                	mov    %esi,%edi
  800bde:	cd 30                	int    $0x30
	if(check && ret > 0)
  800be0:	85 c0                	test   %eax,%eax
  800be2:	7f 08                	jg     800bec <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800be4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be7:	5b                   	pop    %ebx
  800be8:	5e                   	pop    %esi
  800be9:	5f                   	pop    %edi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bec:	83 ec 0c             	sub    $0xc,%esp
  800bef:	50                   	push   %eax
  800bf0:	6a 04                	push   $0x4
  800bf2:	68 3f 22 80 00       	push   $0x80223f
  800bf7:	6a 23                	push   $0x23
  800bf9:	68 5c 22 80 00       	push   $0x80225c
  800bfe:	e8 0f 0f 00 00       	call   801b12 <_panic>

00800c03 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c03:	f3 0f 1e fb          	endbr32 
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
  800c0d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c10:	8b 55 08             	mov    0x8(%ebp),%edx
  800c13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c16:	b8 05 00 00 00       	mov    $0x5,%eax
  800c1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c21:	8b 75 18             	mov    0x18(%ebp),%esi
  800c24:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c26:	85 c0                	test   %eax,%eax
  800c28:	7f 08                	jg     800c32 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2d:	5b                   	pop    %ebx
  800c2e:	5e                   	pop    %esi
  800c2f:	5f                   	pop    %edi
  800c30:	5d                   	pop    %ebp
  800c31:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c32:	83 ec 0c             	sub    $0xc,%esp
  800c35:	50                   	push   %eax
  800c36:	6a 05                	push   $0x5
  800c38:	68 3f 22 80 00       	push   $0x80223f
  800c3d:	6a 23                	push   $0x23
  800c3f:	68 5c 22 80 00       	push   $0x80225c
  800c44:	e8 c9 0e 00 00       	call   801b12 <_panic>

00800c49 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c49:	f3 0f 1e fb          	endbr32 
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	57                   	push   %edi
  800c51:	56                   	push   %esi
  800c52:	53                   	push   %ebx
  800c53:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c56:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c61:	b8 06 00 00 00       	mov    $0x6,%eax
  800c66:	89 df                	mov    %ebx,%edi
  800c68:	89 de                	mov    %ebx,%esi
  800c6a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c6c:	85 c0                	test   %eax,%eax
  800c6e:	7f 08                	jg     800c78 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c73:	5b                   	pop    %ebx
  800c74:	5e                   	pop    %esi
  800c75:	5f                   	pop    %edi
  800c76:	5d                   	pop    %ebp
  800c77:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c78:	83 ec 0c             	sub    $0xc,%esp
  800c7b:	50                   	push   %eax
  800c7c:	6a 06                	push   $0x6
  800c7e:	68 3f 22 80 00       	push   $0x80223f
  800c83:	6a 23                	push   $0x23
  800c85:	68 5c 22 80 00       	push   $0x80225c
  800c8a:	e8 83 0e 00 00       	call   801b12 <_panic>

00800c8f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c8f:	f3 0f 1e fb          	endbr32 
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca7:	b8 08 00 00 00       	mov    $0x8,%eax
  800cac:	89 df                	mov    %ebx,%edi
  800cae:	89 de                	mov    %ebx,%esi
  800cb0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb2:	85 c0                	test   %eax,%eax
  800cb4:	7f 08                	jg     800cbe <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb9:	5b                   	pop    %ebx
  800cba:	5e                   	pop    %esi
  800cbb:	5f                   	pop    %edi
  800cbc:	5d                   	pop    %ebp
  800cbd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbe:	83 ec 0c             	sub    $0xc,%esp
  800cc1:	50                   	push   %eax
  800cc2:	6a 08                	push   $0x8
  800cc4:	68 3f 22 80 00       	push   $0x80223f
  800cc9:	6a 23                	push   $0x23
  800ccb:	68 5c 22 80 00       	push   $0x80225c
  800cd0:	e8 3d 0e 00 00       	call   801b12 <_panic>

00800cd5 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cd5:	f3 0f 1e fb          	endbr32 
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	57                   	push   %edi
  800cdd:	56                   	push   %esi
  800cde:	53                   	push   %ebx
  800cdf:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ce2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ced:	b8 09 00 00 00       	mov    $0x9,%eax
  800cf2:	89 df                	mov    %ebx,%edi
  800cf4:	89 de                	mov    %ebx,%esi
  800cf6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf8:	85 c0                	test   %eax,%eax
  800cfa:	7f 08                	jg     800d04 <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d04:	83 ec 0c             	sub    $0xc,%esp
  800d07:	50                   	push   %eax
  800d08:	6a 09                	push   $0x9
  800d0a:	68 3f 22 80 00       	push   $0x80223f
  800d0f:	6a 23                	push   $0x23
  800d11:	68 5c 22 80 00       	push   $0x80225c
  800d16:	e8 f7 0d 00 00       	call   801b12 <_panic>

00800d1b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d1b:	f3 0f 1e fb          	endbr32 
  800d1f:	55                   	push   %ebp
  800d20:	89 e5                	mov    %esp,%ebp
  800d22:	57                   	push   %edi
  800d23:	56                   	push   %esi
  800d24:	53                   	push   %ebx
  800d25:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d28:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d38:	89 df                	mov    %ebx,%edi
  800d3a:	89 de                	mov    %ebx,%esi
  800d3c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d3e:	85 c0                	test   %eax,%eax
  800d40:	7f 08                	jg     800d4a <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4a:	83 ec 0c             	sub    $0xc,%esp
  800d4d:	50                   	push   %eax
  800d4e:	6a 0a                	push   $0xa
  800d50:	68 3f 22 80 00       	push   $0x80223f
  800d55:	6a 23                	push   $0x23
  800d57:	68 5c 22 80 00       	push   $0x80225c
  800d5c:	e8 b1 0d 00 00       	call   801b12 <_panic>

00800d61 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d61:	f3 0f 1e fb          	endbr32 
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	57                   	push   %edi
  800d69:	56                   	push   %esi
  800d6a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d71:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d76:	be 00 00 00 00       	mov    $0x0,%esi
  800d7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d7e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d81:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5f                   	pop    %edi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d88:	f3 0f 1e fb          	endbr32 
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	57                   	push   %edi
  800d90:	56                   	push   %esi
  800d91:	53                   	push   %ebx
  800d92:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d95:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800da2:	89 cb                	mov    %ecx,%ebx
  800da4:	89 cf                	mov    %ecx,%edi
  800da6:	89 ce                	mov    %ecx,%esi
  800da8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800daa:	85 c0                	test   %eax,%eax
  800dac:	7f 08                	jg     800db6 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db1:	5b                   	pop    %ebx
  800db2:	5e                   	pop    %esi
  800db3:	5f                   	pop    %edi
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800db6:	83 ec 0c             	sub    $0xc,%esp
  800db9:	50                   	push   %eax
  800dba:	6a 0d                	push   $0xd
  800dbc:	68 3f 22 80 00       	push   $0x80223f
  800dc1:	6a 23                	push   $0x23
  800dc3:	68 5c 22 80 00       	push   $0x80225c
  800dc8:	e8 45 0d 00 00       	call   801b12 <_panic>

00800dcd <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dcd:	f3 0f 1e fb          	endbr32 
  800dd1:	55                   	push   %ebp
  800dd2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dd4:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd7:	05 00 00 00 30       	add    $0x30000000,%eax
  800ddc:	c1 e8 0c             	shr    $0xc,%eax
}
  800ddf:	5d                   	pop    %ebp
  800de0:	c3                   	ret    

00800de1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800de1:	f3 0f 1e fb          	endbr32 
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800de8:	8b 45 08             	mov    0x8(%ebp),%eax
  800deb:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800df0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800df5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800dfa:	5d                   	pop    %ebp
  800dfb:	c3                   	ret    

00800dfc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dfc:	f3 0f 1e fb          	endbr32 
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e08:	89 c2                	mov    %eax,%edx
  800e0a:	c1 ea 16             	shr    $0x16,%edx
  800e0d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e14:	f6 c2 01             	test   $0x1,%dl
  800e17:	74 2d                	je     800e46 <fd_alloc+0x4a>
  800e19:	89 c2                	mov    %eax,%edx
  800e1b:	c1 ea 0c             	shr    $0xc,%edx
  800e1e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e25:	f6 c2 01             	test   $0x1,%dl
  800e28:	74 1c                	je     800e46 <fd_alloc+0x4a>
  800e2a:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800e2f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e34:	75 d2                	jne    800e08 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e36:	8b 45 08             	mov    0x8(%ebp),%eax
  800e39:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800e3f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800e44:	eb 0a                	jmp    800e50 <fd_alloc+0x54>
			*fd_store = fd;
  800e46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e49:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e50:	5d                   	pop    %ebp
  800e51:	c3                   	ret    

00800e52 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e52:	f3 0f 1e fb          	endbr32 
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e5c:	83 f8 1f             	cmp    $0x1f,%eax
  800e5f:	77 30                	ja     800e91 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e61:	c1 e0 0c             	shl    $0xc,%eax
  800e64:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e69:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800e6f:	f6 c2 01             	test   $0x1,%dl
  800e72:	74 24                	je     800e98 <fd_lookup+0x46>
  800e74:	89 c2                	mov    %eax,%edx
  800e76:	c1 ea 0c             	shr    $0xc,%edx
  800e79:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e80:	f6 c2 01             	test   $0x1,%dl
  800e83:	74 1a                	je     800e9f <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e85:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e88:	89 02                	mov    %eax,(%edx)
	return 0;
  800e8a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e8f:	5d                   	pop    %ebp
  800e90:	c3                   	ret    
		return -E_INVAL;
  800e91:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e96:	eb f7                	jmp    800e8f <fd_lookup+0x3d>
		return -E_INVAL;
  800e98:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e9d:	eb f0                	jmp    800e8f <fd_lookup+0x3d>
  800e9f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ea4:	eb e9                	jmp    800e8f <fd_lookup+0x3d>

00800ea6 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ea6:	f3 0f 1e fb          	endbr32 
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	83 ec 08             	sub    $0x8,%esp
  800eb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eb3:	ba e8 22 80 00       	mov    $0x8022e8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800eb8:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800ebd:	39 08                	cmp    %ecx,(%eax)
  800ebf:	74 33                	je     800ef4 <dev_lookup+0x4e>
  800ec1:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800ec4:	8b 02                	mov    (%edx),%eax
  800ec6:	85 c0                	test   %eax,%eax
  800ec8:	75 f3                	jne    800ebd <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800eca:	a1 04 40 80 00       	mov    0x804004,%eax
  800ecf:	8b 40 48             	mov    0x48(%eax),%eax
  800ed2:	83 ec 04             	sub    $0x4,%esp
  800ed5:	51                   	push   %ecx
  800ed6:	50                   	push   %eax
  800ed7:	68 6c 22 80 00       	push   $0x80226c
  800edc:	e8 90 f2 ff ff       	call   800171 <cprintf>
	*dev = 0;
  800ee1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800eea:	83 c4 10             	add    $0x10,%esp
  800eed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ef2:	c9                   	leave  
  800ef3:	c3                   	ret    
			*dev = devtab[i];
  800ef4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef7:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ef9:	b8 00 00 00 00       	mov    $0x0,%eax
  800efe:	eb f2                	jmp    800ef2 <dev_lookup+0x4c>

00800f00 <fd_close>:
{
  800f00:	f3 0f 1e fb          	endbr32 
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	57                   	push   %edi
  800f08:	56                   	push   %esi
  800f09:	53                   	push   %ebx
  800f0a:	83 ec 24             	sub    $0x24,%esp
  800f0d:	8b 75 08             	mov    0x8(%ebp),%esi
  800f10:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f13:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f16:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f17:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f1d:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f20:	50                   	push   %eax
  800f21:	e8 2c ff ff ff       	call   800e52 <fd_lookup>
  800f26:	89 c3                	mov    %eax,%ebx
  800f28:	83 c4 10             	add    $0x10,%esp
  800f2b:	85 c0                	test   %eax,%eax
  800f2d:	78 05                	js     800f34 <fd_close+0x34>
	    || fd != fd2)
  800f2f:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800f32:	74 16                	je     800f4a <fd_close+0x4a>
		return (must_exist ? r : 0);
  800f34:	89 f8                	mov    %edi,%eax
  800f36:	84 c0                	test   %al,%al
  800f38:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3d:	0f 44 d8             	cmove  %eax,%ebx
}
  800f40:	89 d8                	mov    %ebx,%eax
  800f42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f45:	5b                   	pop    %ebx
  800f46:	5e                   	pop    %esi
  800f47:	5f                   	pop    %edi
  800f48:	5d                   	pop    %ebp
  800f49:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f4a:	83 ec 08             	sub    $0x8,%esp
  800f4d:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f50:	50                   	push   %eax
  800f51:	ff 36                	pushl  (%esi)
  800f53:	e8 4e ff ff ff       	call   800ea6 <dev_lookup>
  800f58:	89 c3                	mov    %eax,%ebx
  800f5a:	83 c4 10             	add    $0x10,%esp
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	78 1a                	js     800f7b <fd_close+0x7b>
		if (dev->dev_close)
  800f61:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f64:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800f67:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800f6c:	85 c0                	test   %eax,%eax
  800f6e:	74 0b                	je     800f7b <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800f70:	83 ec 0c             	sub    $0xc,%esp
  800f73:	56                   	push   %esi
  800f74:	ff d0                	call   *%eax
  800f76:	89 c3                	mov    %eax,%ebx
  800f78:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f7b:	83 ec 08             	sub    $0x8,%esp
  800f7e:	56                   	push   %esi
  800f7f:	6a 00                	push   $0x0
  800f81:	e8 c3 fc ff ff       	call   800c49 <sys_page_unmap>
	return r;
  800f86:	83 c4 10             	add    $0x10,%esp
  800f89:	eb b5                	jmp    800f40 <fd_close+0x40>

00800f8b <close>:

int
close(int fdnum)
{
  800f8b:	f3 0f 1e fb          	endbr32 
  800f8f:	55                   	push   %ebp
  800f90:	89 e5                	mov    %esp,%ebp
  800f92:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f95:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f98:	50                   	push   %eax
  800f99:	ff 75 08             	pushl  0x8(%ebp)
  800f9c:	e8 b1 fe ff ff       	call   800e52 <fd_lookup>
  800fa1:	83 c4 10             	add    $0x10,%esp
  800fa4:	85 c0                	test   %eax,%eax
  800fa6:	79 02                	jns    800faa <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  800fa8:	c9                   	leave  
  800fa9:	c3                   	ret    
		return fd_close(fd, 1);
  800faa:	83 ec 08             	sub    $0x8,%esp
  800fad:	6a 01                	push   $0x1
  800faf:	ff 75 f4             	pushl  -0xc(%ebp)
  800fb2:	e8 49 ff ff ff       	call   800f00 <fd_close>
  800fb7:	83 c4 10             	add    $0x10,%esp
  800fba:	eb ec                	jmp    800fa8 <close+0x1d>

00800fbc <close_all>:

void
close_all(void)
{
  800fbc:	f3 0f 1e fb          	endbr32 
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	53                   	push   %ebx
  800fc4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fc7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fcc:	83 ec 0c             	sub    $0xc,%esp
  800fcf:	53                   	push   %ebx
  800fd0:	e8 b6 ff ff ff       	call   800f8b <close>
	for (i = 0; i < MAXFD; i++)
  800fd5:	83 c3 01             	add    $0x1,%ebx
  800fd8:	83 c4 10             	add    $0x10,%esp
  800fdb:	83 fb 20             	cmp    $0x20,%ebx
  800fde:	75 ec                	jne    800fcc <close_all+0x10>
}
  800fe0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fe3:	c9                   	leave  
  800fe4:	c3                   	ret    

00800fe5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fe5:	f3 0f 1e fb          	endbr32 
  800fe9:	55                   	push   %ebp
  800fea:	89 e5                	mov    %esp,%ebp
  800fec:	57                   	push   %edi
  800fed:	56                   	push   %esi
  800fee:	53                   	push   %ebx
  800fef:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ff2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ff5:	50                   	push   %eax
  800ff6:	ff 75 08             	pushl  0x8(%ebp)
  800ff9:	e8 54 fe ff ff       	call   800e52 <fd_lookup>
  800ffe:	89 c3                	mov    %eax,%ebx
  801000:	83 c4 10             	add    $0x10,%esp
  801003:	85 c0                	test   %eax,%eax
  801005:	0f 88 81 00 00 00    	js     80108c <dup+0xa7>
		return r;
	close(newfdnum);
  80100b:	83 ec 0c             	sub    $0xc,%esp
  80100e:	ff 75 0c             	pushl  0xc(%ebp)
  801011:	e8 75 ff ff ff       	call   800f8b <close>

	newfd = INDEX2FD(newfdnum);
  801016:	8b 75 0c             	mov    0xc(%ebp),%esi
  801019:	c1 e6 0c             	shl    $0xc,%esi
  80101c:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801022:	83 c4 04             	add    $0x4,%esp
  801025:	ff 75 e4             	pushl  -0x1c(%ebp)
  801028:	e8 b4 fd ff ff       	call   800de1 <fd2data>
  80102d:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80102f:	89 34 24             	mov    %esi,(%esp)
  801032:	e8 aa fd ff ff       	call   800de1 <fd2data>
  801037:	83 c4 10             	add    $0x10,%esp
  80103a:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80103c:	89 d8                	mov    %ebx,%eax
  80103e:	c1 e8 16             	shr    $0x16,%eax
  801041:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801048:	a8 01                	test   $0x1,%al
  80104a:	74 11                	je     80105d <dup+0x78>
  80104c:	89 d8                	mov    %ebx,%eax
  80104e:	c1 e8 0c             	shr    $0xc,%eax
  801051:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801058:	f6 c2 01             	test   $0x1,%dl
  80105b:	75 39                	jne    801096 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80105d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801060:	89 d0                	mov    %edx,%eax
  801062:	c1 e8 0c             	shr    $0xc,%eax
  801065:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80106c:	83 ec 0c             	sub    $0xc,%esp
  80106f:	25 07 0e 00 00       	and    $0xe07,%eax
  801074:	50                   	push   %eax
  801075:	56                   	push   %esi
  801076:	6a 00                	push   $0x0
  801078:	52                   	push   %edx
  801079:	6a 00                	push   $0x0
  80107b:	e8 83 fb ff ff       	call   800c03 <sys_page_map>
  801080:	89 c3                	mov    %eax,%ebx
  801082:	83 c4 20             	add    $0x20,%esp
  801085:	85 c0                	test   %eax,%eax
  801087:	78 31                	js     8010ba <dup+0xd5>
		goto err;

	return newfdnum;
  801089:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80108c:	89 d8                	mov    %ebx,%eax
  80108e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801091:	5b                   	pop    %ebx
  801092:	5e                   	pop    %esi
  801093:	5f                   	pop    %edi
  801094:	5d                   	pop    %ebp
  801095:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801096:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80109d:	83 ec 0c             	sub    $0xc,%esp
  8010a0:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a5:	50                   	push   %eax
  8010a6:	57                   	push   %edi
  8010a7:	6a 00                	push   $0x0
  8010a9:	53                   	push   %ebx
  8010aa:	6a 00                	push   $0x0
  8010ac:	e8 52 fb ff ff       	call   800c03 <sys_page_map>
  8010b1:	89 c3                	mov    %eax,%ebx
  8010b3:	83 c4 20             	add    $0x20,%esp
  8010b6:	85 c0                	test   %eax,%eax
  8010b8:	79 a3                	jns    80105d <dup+0x78>
	sys_page_unmap(0, newfd);
  8010ba:	83 ec 08             	sub    $0x8,%esp
  8010bd:	56                   	push   %esi
  8010be:	6a 00                	push   $0x0
  8010c0:	e8 84 fb ff ff       	call   800c49 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010c5:	83 c4 08             	add    $0x8,%esp
  8010c8:	57                   	push   %edi
  8010c9:	6a 00                	push   $0x0
  8010cb:	e8 79 fb ff ff       	call   800c49 <sys_page_unmap>
	return r;
  8010d0:	83 c4 10             	add    $0x10,%esp
  8010d3:	eb b7                	jmp    80108c <dup+0xa7>

008010d5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010d5:	f3 0f 1e fb          	endbr32 
  8010d9:	55                   	push   %ebp
  8010da:	89 e5                	mov    %esp,%ebp
  8010dc:	53                   	push   %ebx
  8010dd:	83 ec 1c             	sub    $0x1c,%esp
  8010e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010e6:	50                   	push   %eax
  8010e7:	53                   	push   %ebx
  8010e8:	e8 65 fd ff ff       	call   800e52 <fd_lookup>
  8010ed:	83 c4 10             	add    $0x10,%esp
  8010f0:	85 c0                	test   %eax,%eax
  8010f2:	78 3f                	js     801133 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010f4:	83 ec 08             	sub    $0x8,%esp
  8010f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010fa:	50                   	push   %eax
  8010fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010fe:	ff 30                	pushl  (%eax)
  801100:	e8 a1 fd ff ff       	call   800ea6 <dev_lookup>
  801105:	83 c4 10             	add    $0x10,%esp
  801108:	85 c0                	test   %eax,%eax
  80110a:	78 27                	js     801133 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80110c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80110f:	8b 42 08             	mov    0x8(%edx),%eax
  801112:	83 e0 03             	and    $0x3,%eax
  801115:	83 f8 01             	cmp    $0x1,%eax
  801118:	74 1e                	je     801138 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80111a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80111d:	8b 40 08             	mov    0x8(%eax),%eax
  801120:	85 c0                	test   %eax,%eax
  801122:	74 35                	je     801159 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801124:	83 ec 04             	sub    $0x4,%esp
  801127:	ff 75 10             	pushl  0x10(%ebp)
  80112a:	ff 75 0c             	pushl  0xc(%ebp)
  80112d:	52                   	push   %edx
  80112e:	ff d0                	call   *%eax
  801130:	83 c4 10             	add    $0x10,%esp
}
  801133:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801136:	c9                   	leave  
  801137:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801138:	a1 04 40 80 00       	mov    0x804004,%eax
  80113d:	8b 40 48             	mov    0x48(%eax),%eax
  801140:	83 ec 04             	sub    $0x4,%esp
  801143:	53                   	push   %ebx
  801144:	50                   	push   %eax
  801145:	68 ad 22 80 00       	push   $0x8022ad
  80114a:	e8 22 f0 ff ff       	call   800171 <cprintf>
		return -E_INVAL;
  80114f:	83 c4 10             	add    $0x10,%esp
  801152:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801157:	eb da                	jmp    801133 <read+0x5e>
		return -E_NOT_SUPP;
  801159:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80115e:	eb d3                	jmp    801133 <read+0x5e>

00801160 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801160:	f3 0f 1e fb          	endbr32 
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	57                   	push   %edi
  801168:	56                   	push   %esi
  801169:	53                   	push   %ebx
  80116a:	83 ec 0c             	sub    $0xc,%esp
  80116d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801170:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801173:	bb 00 00 00 00       	mov    $0x0,%ebx
  801178:	eb 02                	jmp    80117c <readn+0x1c>
  80117a:	01 c3                	add    %eax,%ebx
  80117c:	39 f3                	cmp    %esi,%ebx
  80117e:	73 21                	jae    8011a1 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801180:	83 ec 04             	sub    $0x4,%esp
  801183:	89 f0                	mov    %esi,%eax
  801185:	29 d8                	sub    %ebx,%eax
  801187:	50                   	push   %eax
  801188:	89 d8                	mov    %ebx,%eax
  80118a:	03 45 0c             	add    0xc(%ebp),%eax
  80118d:	50                   	push   %eax
  80118e:	57                   	push   %edi
  80118f:	e8 41 ff ff ff       	call   8010d5 <read>
		if (m < 0)
  801194:	83 c4 10             	add    $0x10,%esp
  801197:	85 c0                	test   %eax,%eax
  801199:	78 04                	js     80119f <readn+0x3f>
			return m;
		if (m == 0)
  80119b:	75 dd                	jne    80117a <readn+0x1a>
  80119d:	eb 02                	jmp    8011a1 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80119f:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8011a1:	89 d8                	mov    %ebx,%eax
  8011a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a6:	5b                   	pop    %ebx
  8011a7:	5e                   	pop    %esi
  8011a8:	5f                   	pop    %edi
  8011a9:	5d                   	pop    %ebp
  8011aa:	c3                   	ret    

008011ab <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011ab:	f3 0f 1e fb          	endbr32 
  8011af:	55                   	push   %ebp
  8011b0:	89 e5                	mov    %esp,%ebp
  8011b2:	53                   	push   %ebx
  8011b3:	83 ec 1c             	sub    $0x1c,%esp
  8011b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011bc:	50                   	push   %eax
  8011bd:	53                   	push   %ebx
  8011be:	e8 8f fc ff ff       	call   800e52 <fd_lookup>
  8011c3:	83 c4 10             	add    $0x10,%esp
  8011c6:	85 c0                	test   %eax,%eax
  8011c8:	78 3a                	js     801204 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ca:	83 ec 08             	sub    $0x8,%esp
  8011cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d0:	50                   	push   %eax
  8011d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d4:	ff 30                	pushl  (%eax)
  8011d6:	e8 cb fc ff ff       	call   800ea6 <dev_lookup>
  8011db:	83 c4 10             	add    $0x10,%esp
  8011de:	85 c0                	test   %eax,%eax
  8011e0:	78 22                	js     801204 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011e9:	74 1e                	je     801209 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011ee:	8b 52 0c             	mov    0xc(%edx),%edx
  8011f1:	85 d2                	test   %edx,%edx
  8011f3:	74 35                	je     80122a <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011f5:	83 ec 04             	sub    $0x4,%esp
  8011f8:	ff 75 10             	pushl  0x10(%ebp)
  8011fb:	ff 75 0c             	pushl  0xc(%ebp)
  8011fe:	50                   	push   %eax
  8011ff:	ff d2                	call   *%edx
  801201:	83 c4 10             	add    $0x10,%esp
}
  801204:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801207:	c9                   	leave  
  801208:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801209:	a1 04 40 80 00       	mov    0x804004,%eax
  80120e:	8b 40 48             	mov    0x48(%eax),%eax
  801211:	83 ec 04             	sub    $0x4,%esp
  801214:	53                   	push   %ebx
  801215:	50                   	push   %eax
  801216:	68 c9 22 80 00       	push   $0x8022c9
  80121b:	e8 51 ef ff ff       	call   800171 <cprintf>
		return -E_INVAL;
  801220:	83 c4 10             	add    $0x10,%esp
  801223:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801228:	eb da                	jmp    801204 <write+0x59>
		return -E_NOT_SUPP;
  80122a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80122f:	eb d3                	jmp    801204 <write+0x59>

00801231 <seek>:

int
seek(int fdnum, off_t offset)
{
  801231:	f3 0f 1e fb          	endbr32 
  801235:	55                   	push   %ebp
  801236:	89 e5                	mov    %esp,%ebp
  801238:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80123b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80123e:	50                   	push   %eax
  80123f:	ff 75 08             	pushl  0x8(%ebp)
  801242:	e8 0b fc ff ff       	call   800e52 <fd_lookup>
  801247:	83 c4 10             	add    $0x10,%esp
  80124a:	85 c0                	test   %eax,%eax
  80124c:	78 0e                	js     80125c <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80124e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801251:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801254:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801257:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80125c:	c9                   	leave  
  80125d:	c3                   	ret    

0080125e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80125e:	f3 0f 1e fb          	endbr32 
  801262:	55                   	push   %ebp
  801263:	89 e5                	mov    %esp,%ebp
  801265:	53                   	push   %ebx
  801266:	83 ec 1c             	sub    $0x1c,%esp
  801269:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80126c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80126f:	50                   	push   %eax
  801270:	53                   	push   %ebx
  801271:	e8 dc fb ff ff       	call   800e52 <fd_lookup>
  801276:	83 c4 10             	add    $0x10,%esp
  801279:	85 c0                	test   %eax,%eax
  80127b:	78 37                	js     8012b4 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80127d:	83 ec 08             	sub    $0x8,%esp
  801280:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801283:	50                   	push   %eax
  801284:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801287:	ff 30                	pushl  (%eax)
  801289:	e8 18 fc ff ff       	call   800ea6 <dev_lookup>
  80128e:	83 c4 10             	add    $0x10,%esp
  801291:	85 c0                	test   %eax,%eax
  801293:	78 1f                	js     8012b4 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801295:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801298:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80129c:	74 1b                	je     8012b9 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80129e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012a1:	8b 52 18             	mov    0x18(%edx),%edx
  8012a4:	85 d2                	test   %edx,%edx
  8012a6:	74 32                	je     8012da <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012a8:	83 ec 08             	sub    $0x8,%esp
  8012ab:	ff 75 0c             	pushl  0xc(%ebp)
  8012ae:	50                   	push   %eax
  8012af:	ff d2                	call   *%edx
  8012b1:	83 c4 10             	add    $0x10,%esp
}
  8012b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b7:	c9                   	leave  
  8012b8:	c3                   	ret    
			thisenv->env_id, fdnum);
  8012b9:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012be:	8b 40 48             	mov    0x48(%eax),%eax
  8012c1:	83 ec 04             	sub    $0x4,%esp
  8012c4:	53                   	push   %ebx
  8012c5:	50                   	push   %eax
  8012c6:	68 8c 22 80 00       	push   $0x80228c
  8012cb:	e8 a1 ee ff ff       	call   800171 <cprintf>
		return -E_INVAL;
  8012d0:	83 c4 10             	add    $0x10,%esp
  8012d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d8:	eb da                	jmp    8012b4 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8012da:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012df:	eb d3                	jmp    8012b4 <ftruncate+0x56>

008012e1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012e1:	f3 0f 1e fb          	endbr32 
  8012e5:	55                   	push   %ebp
  8012e6:	89 e5                	mov    %esp,%ebp
  8012e8:	53                   	push   %ebx
  8012e9:	83 ec 1c             	sub    $0x1c,%esp
  8012ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f2:	50                   	push   %eax
  8012f3:	ff 75 08             	pushl  0x8(%ebp)
  8012f6:	e8 57 fb ff ff       	call   800e52 <fd_lookup>
  8012fb:	83 c4 10             	add    $0x10,%esp
  8012fe:	85 c0                	test   %eax,%eax
  801300:	78 4b                	js     80134d <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801302:	83 ec 08             	sub    $0x8,%esp
  801305:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801308:	50                   	push   %eax
  801309:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130c:	ff 30                	pushl  (%eax)
  80130e:	e8 93 fb ff ff       	call   800ea6 <dev_lookup>
  801313:	83 c4 10             	add    $0x10,%esp
  801316:	85 c0                	test   %eax,%eax
  801318:	78 33                	js     80134d <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80131a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80131d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801321:	74 2f                	je     801352 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801323:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801326:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80132d:	00 00 00 
	stat->st_isdir = 0;
  801330:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801337:	00 00 00 
	stat->st_dev = dev;
  80133a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801340:	83 ec 08             	sub    $0x8,%esp
  801343:	53                   	push   %ebx
  801344:	ff 75 f0             	pushl  -0x10(%ebp)
  801347:	ff 50 14             	call   *0x14(%eax)
  80134a:	83 c4 10             	add    $0x10,%esp
}
  80134d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801350:	c9                   	leave  
  801351:	c3                   	ret    
		return -E_NOT_SUPP;
  801352:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801357:	eb f4                	jmp    80134d <fstat+0x6c>

00801359 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801359:	f3 0f 1e fb          	endbr32 
  80135d:	55                   	push   %ebp
  80135e:	89 e5                	mov    %esp,%ebp
  801360:	56                   	push   %esi
  801361:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801362:	83 ec 08             	sub    $0x8,%esp
  801365:	6a 00                	push   $0x0
  801367:	ff 75 08             	pushl  0x8(%ebp)
  80136a:	e8 fb 01 00 00       	call   80156a <open>
  80136f:	89 c3                	mov    %eax,%ebx
  801371:	83 c4 10             	add    $0x10,%esp
  801374:	85 c0                	test   %eax,%eax
  801376:	78 1b                	js     801393 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801378:	83 ec 08             	sub    $0x8,%esp
  80137b:	ff 75 0c             	pushl  0xc(%ebp)
  80137e:	50                   	push   %eax
  80137f:	e8 5d ff ff ff       	call   8012e1 <fstat>
  801384:	89 c6                	mov    %eax,%esi
	close(fd);
  801386:	89 1c 24             	mov    %ebx,(%esp)
  801389:	e8 fd fb ff ff       	call   800f8b <close>
	return r;
  80138e:	83 c4 10             	add    $0x10,%esp
  801391:	89 f3                	mov    %esi,%ebx
}
  801393:	89 d8                	mov    %ebx,%eax
  801395:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801398:	5b                   	pop    %ebx
  801399:	5e                   	pop    %esi
  80139a:	5d                   	pop    %ebp
  80139b:	c3                   	ret    

0080139c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80139c:	55                   	push   %ebp
  80139d:	89 e5                	mov    %esp,%ebp
  80139f:	56                   	push   %esi
  8013a0:	53                   	push   %ebx
  8013a1:	89 c6                	mov    %eax,%esi
  8013a3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013a5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013ac:	74 27                	je     8013d5 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013ae:	6a 07                	push   $0x7
  8013b0:	68 00 50 80 00       	push   $0x805000
  8013b5:	56                   	push   %esi
  8013b6:	ff 35 00 40 80 00    	pushl  0x804000
  8013bc:	e8 f2 07 00 00       	call   801bb3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013c1:	83 c4 0c             	add    $0xc,%esp
  8013c4:	6a 00                	push   $0x0
  8013c6:	53                   	push   %ebx
  8013c7:	6a 00                	push   $0x0
  8013c9:	e8 8e 07 00 00       	call   801b5c <ipc_recv>
}
  8013ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013d1:	5b                   	pop    %ebx
  8013d2:	5e                   	pop    %esi
  8013d3:	5d                   	pop    %ebp
  8013d4:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013d5:	83 ec 0c             	sub    $0xc,%esp
  8013d8:	6a 01                	push   $0x1
  8013da:	e8 3a 08 00 00       	call   801c19 <ipc_find_env>
  8013df:	a3 00 40 80 00       	mov    %eax,0x804000
  8013e4:	83 c4 10             	add    $0x10,%esp
  8013e7:	eb c5                	jmp    8013ae <fsipc+0x12>

008013e9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013e9:	f3 0f 1e fb          	endbr32 
  8013ed:	55                   	push   %ebp
  8013ee:	89 e5                	mov    %esp,%ebp
  8013f0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f6:	8b 40 0c             	mov    0xc(%eax),%eax
  8013f9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801401:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801406:	ba 00 00 00 00       	mov    $0x0,%edx
  80140b:	b8 02 00 00 00       	mov    $0x2,%eax
  801410:	e8 87 ff ff ff       	call   80139c <fsipc>
}
  801415:	c9                   	leave  
  801416:	c3                   	ret    

00801417 <devfile_flush>:
{
  801417:	f3 0f 1e fb          	endbr32 
  80141b:	55                   	push   %ebp
  80141c:	89 e5                	mov    %esp,%ebp
  80141e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801421:	8b 45 08             	mov    0x8(%ebp),%eax
  801424:	8b 40 0c             	mov    0xc(%eax),%eax
  801427:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80142c:	ba 00 00 00 00       	mov    $0x0,%edx
  801431:	b8 06 00 00 00       	mov    $0x6,%eax
  801436:	e8 61 ff ff ff       	call   80139c <fsipc>
}
  80143b:	c9                   	leave  
  80143c:	c3                   	ret    

0080143d <devfile_stat>:
{
  80143d:	f3 0f 1e fb          	endbr32 
  801441:	55                   	push   %ebp
  801442:	89 e5                	mov    %esp,%ebp
  801444:	53                   	push   %ebx
  801445:	83 ec 04             	sub    $0x4,%esp
  801448:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80144b:	8b 45 08             	mov    0x8(%ebp),%eax
  80144e:	8b 40 0c             	mov    0xc(%eax),%eax
  801451:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801456:	ba 00 00 00 00       	mov    $0x0,%edx
  80145b:	b8 05 00 00 00       	mov    $0x5,%eax
  801460:	e8 37 ff ff ff       	call   80139c <fsipc>
  801465:	85 c0                	test   %eax,%eax
  801467:	78 2c                	js     801495 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801469:	83 ec 08             	sub    $0x8,%esp
  80146c:	68 00 50 80 00       	push   $0x805000
  801471:	53                   	push   %ebx
  801472:	e8 03 f3 ff ff       	call   80077a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801477:	a1 80 50 80 00       	mov    0x805080,%eax
  80147c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801482:	a1 84 50 80 00       	mov    0x805084,%eax
  801487:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80148d:	83 c4 10             	add    $0x10,%esp
  801490:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801495:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801498:	c9                   	leave  
  801499:	c3                   	ret    

0080149a <devfile_write>:
{
  80149a:	f3 0f 1e fb          	endbr32 
  80149e:	55                   	push   %ebp
  80149f:	89 e5                	mov    %esp,%ebp
  8014a1:	83 ec 0c             	sub    $0xc,%esp
  8014a4:	8b 45 10             	mov    0x10(%ebp),%eax
	n = n > size_max ? size_max : n;
  8014a7:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014ac:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8014b1:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8014b7:	8b 52 0c             	mov    0xc(%edx),%edx
  8014ba:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014c0:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014c5:	50                   	push   %eax
  8014c6:	ff 75 0c             	pushl  0xc(%ebp)
  8014c9:	68 08 50 80 00       	push   $0x805008
  8014ce:	e8 5d f4 ff ff       	call   800930 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8014d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d8:	b8 04 00 00 00       	mov    $0x4,%eax
  8014dd:	e8 ba fe ff ff       	call   80139c <fsipc>
}
  8014e2:	c9                   	leave  
  8014e3:	c3                   	ret    

008014e4 <devfile_read>:
{
  8014e4:	f3 0f 1e fb          	endbr32 
  8014e8:	55                   	push   %ebp
  8014e9:	89 e5                	mov    %esp,%ebp
  8014eb:	56                   	push   %esi
  8014ec:	53                   	push   %ebx
  8014ed:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f3:	8b 40 0c             	mov    0xc(%eax),%eax
  8014f6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014fb:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801501:	ba 00 00 00 00       	mov    $0x0,%edx
  801506:	b8 03 00 00 00       	mov    $0x3,%eax
  80150b:	e8 8c fe ff ff       	call   80139c <fsipc>
  801510:	89 c3                	mov    %eax,%ebx
  801512:	85 c0                	test   %eax,%eax
  801514:	78 1f                	js     801535 <devfile_read+0x51>
	assert(r <= n);
  801516:	39 f0                	cmp    %esi,%eax
  801518:	77 24                	ja     80153e <devfile_read+0x5a>
	assert(r <= PGSIZE);
  80151a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80151f:	7f 33                	jg     801554 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801521:	83 ec 04             	sub    $0x4,%esp
  801524:	50                   	push   %eax
  801525:	68 00 50 80 00       	push   $0x805000
  80152a:	ff 75 0c             	pushl  0xc(%ebp)
  80152d:	e8 fe f3 ff ff       	call   800930 <memmove>
	return r;
  801532:	83 c4 10             	add    $0x10,%esp
}
  801535:	89 d8                	mov    %ebx,%eax
  801537:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80153a:	5b                   	pop    %ebx
  80153b:	5e                   	pop    %esi
  80153c:	5d                   	pop    %ebp
  80153d:	c3                   	ret    
	assert(r <= n);
  80153e:	68 f8 22 80 00       	push   $0x8022f8
  801543:	68 ff 22 80 00       	push   $0x8022ff
  801548:	6a 7c                	push   $0x7c
  80154a:	68 14 23 80 00       	push   $0x802314
  80154f:	e8 be 05 00 00       	call   801b12 <_panic>
	assert(r <= PGSIZE);
  801554:	68 1f 23 80 00       	push   $0x80231f
  801559:	68 ff 22 80 00       	push   $0x8022ff
  80155e:	6a 7d                	push   $0x7d
  801560:	68 14 23 80 00       	push   $0x802314
  801565:	e8 a8 05 00 00       	call   801b12 <_panic>

0080156a <open>:
{
  80156a:	f3 0f 1e fb          	endbr32 
  80156e:	55                   	push   %ebp
  80156f:	89 e5                	mov    %esp,%ebp
  801571:	56                   	push   %esi
  801572:	53                   	push   %ebx
  801573:	83 ec 1c             	sub    $0x1c,%esp
  801576:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801579:	56                   	push   %esi
  80157a:	e8 b8 f1 ff ff       	call   800737 <strlen>
  80157f:	83 c4 10             	add    $0x10,%esp
  801582:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801587:	7f 6c                	jg     8015f5 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801589:	83 ec 0c             	sub    $0xc,%esp
  80158c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158f:	50                   	push   %eax
  801590:	e8 67 f8 ff ff       	call   800dfc <fd_alloc>
  801595:	89 c3                	mov    %eax,%ebx
  801597:	83 c4 10             	add    $0x10,%esp
  80159a:	85 c0                	test   %eax,%eax
  80159c:	78 3c                	js     8015da <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  80159e:	83 ec 08             	sub    $0x8,%esp
  8015a1:	56                   	push   %esi
  8015a2:	68 00 50 80 00       	push   $0x805000
  8015a7:	e8 ce f1 ff ff       	call   80077a <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015af:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015b7:	b8 01 00 00 00       	mov    $0x1,%eax
  8015bc:	e8 db fd ff ff       	call   80139c <fsipc>
  8015c1:	89 c3                	mov    %eax,%ebx
  8015c3:	83 c4 10             	add    $0x10,%esp
  8015c6:	85 c0                	test   %eax,%eax
  8015c8:	78 19                	js     8015e3 <open+0x79>
	return fd2num(fd);
  8015ca:	83 ec 0c             	sub    $0xc,%esp
  8015cd:	ff 75 f4             	pushl  -0xc(%ebp)
  8015d0:	e8 f8 f7 ff ff       	call   800dcd <fd2num>
  8015d5:	89 c3                	mov    %eax,%ebx
  8015d7:	83 c4 10             	add    $0x10,%esp
}
  8015da:	89 d8                	mov    %ebx,%eax
  8015dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015df:	5b                   	pop    %ebx
  8015e0:	5e                   	pop    %esi
  8015e1:	5d                   	pop    %ebp
  8015e2:	c3                   	ret    
		fd_close(fd, 0);
  8015e3:	83 ec 08             	sub    $0x8,%esp
  8015e6:	6a 00                	push   $0x0
  8015e8:	ff 75 f4             	pushl  -0xc(%ebp)
  8015eb:	e8 10 f9 ff ff       	call   800f00 <fd_close>
		return r;
  8015f0:	83 c4 10             	add    $0x10,%esp
  8015f3:	eb e5                	jmp    8015da <open+0x70>
		return -E_BAD_PATH;
  8015f5:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8015fa:	eb de                	jmp    8015da <open+0x70>

008015fc <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015fc:	f3 0f 1e fb          	endbr32 
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
  801603:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801606:	ba 00 00 00 00       	mov    $0x0,%edx
  80160b:	b8 08 00 00 00       	mov    $0x8,%eax
  801610:	e8 87 fd ff ff       	call   80139c <fsipc>
}
  801615:	c9                   	leave  
  801616:	c3                   	ret    

00801617 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801617:	f3 0f 1e fb          	endbr32 
  80161b:	55                   	push   %ebp
  80161c:	89 e5                	mov    %esp,%ebp
  80161e:	56                   	push   %esi
  80161f:	53                   	push   %ebx
  801620:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801623:	83 ec 0c             	sub    $0xc,%esp
  801626:	ff 75 08             	pushl  0x8(%ebp)
  801629:	e8 b3 f7 ff ff       	call   800de1 <fd2data>
  80162e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801630:	83 c4 08             	add    $0x8,%esp
  801633:	68 2b 23 80 00       	push   $0x80232b
  801638:	53                   	push   %ebx
  801639:	e8 3c f1 ff ff       	call   80077a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80163e:	8b 46 04             	mov    0x4(%esi),%eax
  801641:	2b 06                	sub    (%esi),%eax
  801643:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801649:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801650:	00 00 00 
	stat->st_dev = &devpipe;
  801653:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80165a:	30 80 00 
	return 0;
}
  80165d:	b8 00 00 00 00       	mov    $0x0,%eax
  801662:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801665:	5b                   	pop    %ebx
  801666:	5e                   	pop    %esi
  801667:	5d                   	pop    %ebp
  801668:	c3                   	ret    

00801669 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801669:	f3 0f 1e fb          	endbr32 
  80166d:	55                   	push   %ebp
  80166e:	89 e5                	mov    %esp,%ebp
  801670:	53                   	push   %ebx
  801671:	83 ec 0c             	sub    $0xc,%esp
  801674:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801677:	53                   	push   %ebx
  801678:	6a 00                	push   $0x0
  80167a:	e8 ca f5 ff ff       	call   800c49 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80167f:	89 1c 24             	mov    %ebx,(%esp)
  801682:	e8 5a f7 ff ff       	call   800de1 <fd2data>
  801687:	83 c4 08             	add    $0x8,%esp
  80168a:	50                   	push   %eax
  80168b:	6a 00                	push   $0x0
  80168d:	e8 b7 f5 ff ff       	call   800c49 <sys_page_unmap>
}
  801692:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801695:	c9                   	leave  
  801696:	c3                   	ret    

00801697 <_pipeisclosed>:
{
  801697:	55                   	push   %ebp
  801698:	89 e5                	mov    %esp,%ebp
  80169a:	57                   	push   %edi
  80169b:	56                   	push   %esi
  80169c:	53                   	push   %ebx
  80169d:	83 ec 1c             	sub    $0x1c,%esp
  8016a0:	89 c7                	mov    %eax,%edi
  8016a2:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8016a4:	a1 04 40 80 00       	mov    0x804004,%eax
  8016a9:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8016ac:	83 ec 0c             	sub    $0xc,%esp
  8016af:	57                   	push   %edi
  8016b0:	e8 a1 05 00 00       	call   801c56 <pageref>
  8016b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016b8:	89 34 24             	mov    %esi,(%esp)
  8016bb:	e8 96 05 00 00       	call   801c56 <pageref>
		nn = thisenv->env_runs;
  8016c0:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8016c6:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016c9:	83 c4 10             	add    $0x10,%esp
  8016cc:	39 cb                	cmp    %ecx,%ebx
  8016ce:	74 1b                	je     8016eb <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8016d0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8016d3:	75 cf                	jne    8016a4 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016d5:	8b 42 58             	mov    0x58(%edx),%eax
  8016d8:	6a 01                	push   $0x1
  8016da:	50                   	push   %eax
  8016db:	53                   	push   %ebx
  8016dc:	68 32 23 80 00       	push   $0x802332
  8016e1:	e8 8b ea ff ff       	call   800171 <cprintf>
  8016e6:	83 c4 10             	add    $0x10,%esp
  8016e9:	eb b9                	jmp    8016a4 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8016eb:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8016ee:	0f 94 c0             	sete   %al
  8016f1:	0f b6 c0             	movzbl %al,%eax
}
  8016f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f7:	5b                   	pop    %ebx
  8016f8:	5e                   	pop    %esi
  8016f9:	5f                   	pop    %edi
  8016fa:	5d                   	pop    %ebp
  8016fb:	c3                   	ret    

008016fc <devpipe_write>:
{
  8016fc:	f3 0f 1e fb          	endbr32 
  801700:	55                   	push   %ebp
  801701:	89 e5                	mov    %esp,%ebp
  801703:	57                   	push   %edi
  801704:	56                   	push   %esi
  801705:	53                   	push   %ebx
  801706:	83 ec 28             	sub    $0x28,%esp
  801709:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  80170c:	56                   	push   %esi
  80170d:	e8 cf f6 ff ff       	call   800de1 <fd2data>
  801712:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801714:	83 c4 10             	add    $0x10,%esp
  801717:	bf 00 00 00 00       	mov    $0x0,%edi
  80171c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80171f:	74 4f                	je     801770 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801721:	8b 43 04             	mov    0x4(%ebx),%eax
  801724:	8b 0b                	mov    (%ebx),%ecx
  801726:	8d 51 20             	lea    0x20(%ecx),%edx
  801729:	39 d0                	cmp    %edx,%eax
  80172b:	72 14                	jb     801741 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  80172d:	89 da                	mov    %ebx,%edx
  80172f:	89 f0                	mov    %esi,%eax
  801731:	e8 61 ff ff ff       	call   801697 <_pipeisclosed>
  801736:	85 c0                	test   %eax,%eax
  801738:	75 3b                	jne    801775 <devpipe_write+0x79>
			sys_yield();
  80173a:	e8 5a f4 ff ff       	call   800b99 <sys_yield>
  80173f:	eb e0                	jmp    801721 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801741:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801744:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801748:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80174b:	89 c2                	mov    %eax,%edx
  80174d:	c1 fa 1f             	sar    $0x1f,%edx
  801750:	89 d1                	mov    %edx,%ecx
  801752:	c1 e9 1b             	shr    $0x1b,%ecx
  801755:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801758:	83 e2 1f             	and    $0x1f,%edx
  80175b:	29 ca                	sub    %ecx,%edx
  80175d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801761:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801765:	83 c0 01             	add    $0x1,%eax
  801768:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80176b:	83 c7 01             	add    $0x1,%edi
  80176e:	eb ac                	jmp    80171c <devpipe_write+0x20>
	return i;
  801770:	8b 45 10             	mov    0x10(%ebp),%eax
  801773:	eb 05                	jmp    80177a <devpipe_write+0x7e>
				return 0;
  801775:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80177a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80177d:	5b                   	pop    %ebx
  80177e:	5e                   	pop    %esi
  80177f:	5f                   	pop    %edi
  801780:	5d                   	pop    %ebp
  801781:	c3                   	ret    

00801782 <devpipe_read>:
{
  801782:	f3 0f 1e fb          	endbr32 
  801786:	55                   	push   %ebp
  801787:	89 e5                	mov    %esp,%ebp
  801789:	57                   	push   %edi
  80178a:	56                   	push   %esi
  80178b:	53                   	push   %ebx
  80178c:	83 ec 18             	sub    $0x18,%esp
  80178f:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801792:	57                   	push   %edi
  801793:	e8 49 f6 ff ff       	call   800de1 <fd2data>
  801798:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80179a:	83 c4 10             	add    $0x10,%esp
  80179d:	be 00 00 00 00       	mov    $0x0,%esi
  8017a2:	3b 75 10             	cmp    0x10(%ebp),%esi
  8017a5:	75 14                	jne    8017bb <devpipe_read+0x39>
	return i;
  8017a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8017aa:	eb 02                	jmp    8017ae <devpipe_read+0x2c>
				return i;
  8017ac:	89 f0                	mov    %esi,%eax
}
  8017ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017b1:	5b                   	pop    %ebx
  8017b2:	5e                   	pop    %esi
  8017b3:	5f                   	pop    %edi
  8017b4:	5d                   	pop    %ebp
  8017b5:	c3                   	ret    
			sys_yield();
  8017b6:	e8 de f3 ff ff       	call   800b99 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8017bb:	8b 03                	mov    (%ebx),%eax
  8017bd:	3b 43 04             	cmp    0x4(%ebx),%eax
  8017c0:	75 18                	jne    8017da <devpipe_read+0x58>
			if (i > 0)
  8017c2:	85 f6                	test   %esi,%esi
  8017c4:	75 e6                	jne    8017ac <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  8017c6:	89 da                	mov    %ebx,%edx
  8017c8:	89 f8                	mov    %edi,%eax
  8017ca:	e8 c8 fe ff ff       	call   801697 <_pipeisclosed>
  8017cf:	85 c0                	test   %eax,%eax
  8017d1:	74 e3                	je     8017b6 <devpipe_read+0x34>
				return 0;
  8017d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8017d8:	eb d4                	jmp    8017ae <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017da:	99                   	cltd   
  8017db:	c1 ea 1b             	shr    $0x1b,%edx
  8017de:	01 d0                	add    %edx,%eax
  8017e0:	83 e0 1f             	and    $0x1f,%eax
  8017e3:	29 d0                	sub    %edx,%eax
  8017e5:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8017ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017ed:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8017f0:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8017f3:	83 c6 01             	add    $0x1,%esi
  8017f6:	eb aa                	jmp    8017a2 <devpipe_read+0x20>

008017f8 <pipe>:
{
  8017f8:	f3 0f 1e fb          	endbr32 
  8017fc:	55                   	push   %ebp
  8017fd:	89 e5                	mov    %esp,%ebp
  8017ff:	56                   	push   %esi
  801800:	53                   	push   %ebx
  801801:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801804:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801807:	50                   	push   %eax
  801808:	e8 ef f5 ff ff       	call   800dfc <fd_alloc>
  80180d:	89 c3                	mov    %eax,%ebx
  80180f:	83 c4 10             	add    $0x10,%esp
  801812:	85 c0                	test   %eax,%eax
  801814:	0f 88 23 01 00 00    	js     80193d <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80181a:	83 ec 04             	sub    $0x4,%esp
  80181d:	68 07 04 00 00       	push   $0x407
  801822:	ff 75 f4             	pushl  -0xc(%ebp)
  801825:	6a 00                	push   $0x0
  801827:	e8 90 f3 ff ff       	call   800bbc <sys_page_alloc>
  80182c:	89 c3                	mov    %eax,%ebx
  80182e:	83 c4 10             	add    $0x10,%esp
  801831:	85 c0                	test   %eax,%eax
  801833:	0f 88 04 01 00 00    	js     80193d <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801839:	83 ec 0c             	sub    $0xc,%esp
  80183c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80183f:	50                   	push   %eax
  801840:	e8 b7 f5 ff ff       	call   800dfc <fd_alloc>
  801845:	89 c3                	mov    %eax,%ebx
  801847:	83 c4 10             	add    $0x10,%esp
  80184a:	85 c0                	test   %eax,%eax
  80184c:	0f 88 db 00 00 00    	js     80192d <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801852:	83 ec 04             	sub    $0x4,%esp
  801855:	68 07 04 00 00       	push   $0x407
  80185a:	ff 75 f0             	pushl  -0x10(%ebp)
  80185d:	6a 00                	push   $0x0
  80185f:	e8 58 f3 ff ff       	call   800bbc <sys_page_alloc>
  801864:	89 c3                	mov    %eax,%ebx
  801866:	83 c4 10             	add    $0x10,%esp
  801869:	85 c0                	test   %eax,%eax
  80186b:	0f 88 bc 00 00 00    	js     80192d <pipe+0x135>
	va = fd2data(fd0);
  801871:	83 ec 0c             	sub    $0xc,%esp
  801874:	ff 75 f4             	pushl  -0xc(%ebp)
  801877:	e8 65 f5 ff ff       	call   800de1 <fd2data>
  80187c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80187e:	83 c4 0c             	add    $0xc,%esp
  801881:	68 07 04 00 00       	push   $0x407
  801886:	50                   	push   %eax
  801887:	6a 00                	push   $0x0
  801889:	e8 2e f3 ff ff       	call   800bbc <sys_page_alloc>
  80188e:	89 c3                	mov    %eax,%ebx
  801890:	83 c4 10             	add    $0x10,%esp
  801893:	85 c0                	test   %eax,%eax
  801895:	0f 88 82 00 00 00    	js     80191d <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80189b:	83 ec 0c             	sub    $0xc,%esp
  80189e:	ff 75 f0             	pushl  -0x10(%ebp)
  8018a1:	e8 3b f5 ff ff       	call   800de1 <fd2data>
  8018a6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018ad:	50                   	push   %eax
  8018ae:	6a 00                	push   $0x0
  8018b0:	56                   	push   %esi
  8018b1:	6a 00                	push   $0x0
  8018b3:	e8 4b f3 ff ff       	call   800c03 <sys_page_map>
  8018b8:	89 c3                	mov    %eax,%ebx
  8018ba:	83 c4 20             	add    $0x20,%esp
  8018bd:	85 c0                	test   %eax,%eax
  8018bf:	78 4e                	js     80190f <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  8018c1:	a1 20 30 80 00       	mov    0x803020,%eax
  8018c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018c9:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8018cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ce:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8018d5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018d8:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8018da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018dd:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8018e4:	83 ec 0c             	sub    $0xc,%esp
  8018e7:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ea:	e8 de f4 ff ff       	call   800dcd <fd2num>
  8018ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018f2:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018f4:	83 c4 04             	add    $0x4,%esp
  8018f7:	ff 75 f0             	pushl  -0x10(%ebp)
  8018fa:	e8 ce f4 ff ff       	call   800dcd <fd2num>
  8018ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801902:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801905:	83 c4 10             	add    $0x10,%esp
  801908:	bb 00 00 00 00       	mov    $0x0,%ebx
  80190d:	eb 2e                	jmp    80193d <pipe+0x145>
	sys_page_unmap(0, va);
  80190f:	83 ec 08             	sub    $0x8,%esp
  801912:	56                   	push   %esi
  801913:	6a 00                	push   $0x0
  801915:	e8 2f f3 ff ff       	call   800c49 <sys_page_unmap>
  80191a:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80191d:	83 ec 08             	sub    $0x8,%esp
  801920:	ff 75 f0             	pushl  -0x10(%ebp)
  801923:	6a 00                	push   $0x0
  801925:	e8 1f f3 ff ff       	call   800c49 <sys_page_unmap>
  80192a:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80192d:	83 ec 08             	sub    $0x8,%esp
  801930:	ff 75 f4             	pushl  -0xc(%ebp)
  801933:	6a 00                	push   $0x0
  801935:	e8 0f f3 ff ff       	call   800c49 <sys_page_unmap>
  80193a:	83 c4 10             	add    $0x10,%esp
}
  80193d:	89 d8                	mov    %ebx,%eax
  80193f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801942:	5b                   	pop    %ebx
  801943:	5e                   	pop    %esi
  801944:	5d                   	pop    %ebp
  801945:	c3                   	ret    

00801946 <pipeisclosed>:
{
  801946:	f3 0f 1e fb          	endbr32 
  80194a:	55                   	push   %ebp
  80194b:	89 e5                	mov    %esp,%ebp
  80194d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801950:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801953:	50                   	push   %eax
  801954:	ff 75 08             	pushl  0x8(%ebp)
  801957:	e8 f6 f4 ff ff       	call   800e52 <fd_lookup>
  80195c:	83 c4 10             	add    $0x10,%esp
  80195f:	85 c0                	test   %eax,%eax
  801961:	78 18                	js     80197b <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801963:	83 ec 0c             	sub    $0xc,%esp
  801966:	ff 75 f4             	pushl  -0xc(%ebp)
  801969:	e8 73 f4 ff ff       	call   800de1 <fd2data>
  80196e:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801970:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801973:	e8 1f fd ff ff       	call   801697 <_pipeisclosed>
  801978:	83 c4 10             	add    $0x10,%esp
}
  80197b:	c9                   	leave  
  80197c:	c3                   	ret    

0080197d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80197d:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801981:	b8 00 00 00 00       	mov    $0x0,%eax
  801986:	c3                   	ret    

00801987 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801987:	f3 0f 1e fb          	endbr32 
  80198b:	55                   	push   %ebp
  80198c:	89 e5                	mov    %esp,%ebp
  80198e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801991:	68 4a 23 80 00       	push   $0x80234a
  801996:	ff 75 0c             	pushl  0xc(%ebp)
  801999:	e8 dc ed ff ff       	call   80077a <strcpy>
	return 0;
}
  80199e:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a3:	c9                   	leave  
  8019a4:	c3                   	ret    

008019a5 <devcons_write>:
{
  8019a5:	f3 0f 1e fb          	endbr32 
  8019a9:	55                   	push   %ebp
  8019aa:	89 e5                	mov    %esp,%ebp
  8019ac:	57                   	push   %edi
  8019ad:	56                   	push   %esi
  8019ae:	53                   	push   %ebx
  8019af:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8019b5:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8019ba:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8019c0:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019c3:	73 31                	jae    8019f6 <devcons_write+0x51>
		m = n - tot;
  8019c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019c8:	29 f3                	sub    %esi,%ebx
  8019ca:	83 fb 7f             	cmp    $0x7f,%ebx
  8019cd:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8019d2:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8019d5:	83 ec 04             	sub    $0x4,%esp
  8019d8:	53                   	push   %ebx
  8019d9:	89 f0                	mov    %esi,%eax
  8019db:	03 45 0c             	add    0xc(%ebp),%eax
  8019de:	50                   	push   %eax
  8019df:	57                   	push   %edi
  8019e0:	e8 4b ef ff ff       	call   800930 <memmove>
		sys_cputs(buf, m);
  8019e5:	83 c4 08             	add    $0x8,%esp
  8019e8:	53                   	push   %ebx
  8019e9:	57                   	push   %edi
  8019ea:	e8 fd f0 ff ff       	call   800aec <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8019ef:	01 de                	add    %ebx,%esi
  8019f1:	83 c4 10             	add    $0x10,%esp
  8019f4:	eb ca                	jmp    8019c0 <devcons_write+0x1b>
}
  8019f6:	89 f0                	mov    %esi,%eax
  8019f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019fb:	5b                   	pop    %ebx
  8019fc:	5e                   	pop    %esi
  8019fd:	5f                   	pop    %edi
  8019fe:	5d                   	pop    %ebp
  8019ff:	c3                   	ret    

00801a00 <devcons_read>:
{
  801a00:	f3 0f 1e fb          	endbr32 
  801a04:	55                   	push   %ebp
  801a05:	89 e5                	mov    %esp,%ebp
  801a07:	83 ec 08             	sub    $0x8,%esp
  801a0a:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801a0f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a13:	74 21                	je     801a36 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801a15:	e8 f4 f0 ff ff       	call   800b0e <sys_cgetc>
  801a1a:	85 c0                	test   %eax,%eax
  801a1c:	75 07                	jne    801a25 <devcons_read+0x25>
		sys_yield();
  801a1e:	e8 76 f1 ff ff       	call   800b99 <sys_yield>
  801a23:	eb f0                	jmp    801a15 <devcons_read+0x15>
	if (c < 0)
  801a25:	78 0f                	js     801a36 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801a27:	83 f8 04             	cmp    $0x4,%eax
  801a2a:	74 0c                	je     801a38 <devcons_read+0x38>
	*(char*)vbuf = c;
  801a2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a2f:	88 02                	mov    %al,(%edx)
	return 1;
  801a31:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801a36:	c9                   	leave  
  801a37:	c3                   	ret    
		return 0;
  801a38:	b8 00 00 00 00       	mov    $0x0,%eax
  801a3d:	eb f7                	jmp    801a36 <devcons_read+0x36>

00801a3f <cputchar>:
{
  801a3f:	f3 0f 1e fb          	endbr32 
  801a43:	55                   	push   %ebp
  801a44:	89 e5                	mov    %esp,%ebp
  801a46:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a49:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4c:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801a4f:	6a 01                	push   $0x1
  801a51:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a54:	50                   	push   %eax
  801a55:	e8 92 f0 ff ff       	call   800aec <sys_cputs>
}
  801a5a:	83 c4 10             	add    $0x10,%esp
  801a5d:	c9                   	leave  
  801a5e:	c3                   	ret    

00801a5f <getchar>:
{
  801a5f:	f3 0f 1e fb          	endbr32 
  801a63:	55                   	push   %ebp
  801a64:	89 e5                	mov    %esp,%ebp
  801a66:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801a69:	6a 01                	push   $0x1
  801a6b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a6e:	50                   	push   %eax
  801a6f:	6a 00                	push   $0x0
  801a71:	e8 5f f6 ff ff       	call   8010d5 <read>
	if (r < 0)
  801a76:	83 c4 10             	add    $0x10,%esp
  801a79:	85 c0                	test   %eax,%eax
  801a7b:	78 06                	js     801a83 <getchar+0x24>
	if (r < 1)
  801a7d:	74 06                	je     801a85 <getchar+0x26>
	return c;
  801a7f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801a83:	c9                   	leave  
  801a84:	c3                   	ret    
		return -E_EOF;
  801a85:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801a8a:	eb f7                	jmp    801a83 <getchar+0x24>

00801a8c <iscons>:
{
  801a8c:	f3 0f 1e fb          	endbr32 
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a96:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a99:	50                   	push   %eax
  801a9a:	ff 75 08             	pushl  0x8(%ebp)
  801a9d:	e8 b0 f3 ff ff       	call   800e52 <fd_lookup>
  801aa2:	83 c4 10             	add    $0x10,%esp
  801aa5:	85 c0                	test   %eax,%eax
  801aa7:	78 11                	js     801aba <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801aa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aac:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ab2:	39 10                	cmp    %edx,(%eax)
  801ab4:	0f 94 c0             	sete   %al
  801ab7:	0f b6 c0             	movzbl %al,%eax
}
  801aba:	c9                   	leave  
  801abb:	c3                   	ret    

00801abc <opencons>:
{
  801abc:	f3 0f 1e fb          	endbr32 
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801ac6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ac9:	50                   	push   %eax
  801aca:	e8 2d f3 ff ff       	call   800dfc <fd_alloc>
  801acf:	83 c4 10             	add    $0x10,%esp
  801ad2:	85 c0                	test   %eax,%eax
  801ad4:	78 3a                	js     801b10 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ad6:	83 ec 04             	sub    $0x4,%esp
  801ad9:	68 07 04 00 00       	push   $0x407
  801ade:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae1:	6a 00                	push   $0x0
  801ae3:	e8 d4 f0 ff ff       	call   800bbc <sys_page_alloc>
  801ae8:	83 c4 10             	add    $0x10,%esp
  801aeb:	85 c0                	test   %eax,%eax
  801aed:	78 21                	js     801b10 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801af8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801afd:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b04:	83 ec 0c             	sub    $0xc,%esp
  801b07:	50                   	push   %eax
  801b08:	e8 c0 f2 ff ff       	call   800dcd <fd2num>
  801b0d:	83 c4 10             	add    $0x10,%esp
}
  801b10:	c9                   	leave  
  801b11:	c3                   	ret    

00801b12 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b12:	f3 0f 1e fb          	endbr32 
  801b16:	55                   	push   %ebp
  801b17:	89 e5                	mov    %esp,%ebp
  801b19:	56                   	push   %esi
  801b1a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801b1b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b1e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801b24:	e8 4d f0 ff ff       	call   800b76 <sys_getenvid>
  801b29:	83 ec 0c             	sub    $0xc,%esp
  801b2c:	ff 75 0c             	pushl  0xc(%ebp)
  801b2f:	ff 75 08             	pushl  0x8(%ebp)
  801b32:	56                   	push   %esi
  801b33:	50                   	push   %eax
  801b34:	68 58 23 80 00       	push   $0x802358
  801b39:	e8 33 e6 ff ff       	call   800171 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b3e:	83 c4 18             	add    $0x18,%esp
  801b41:	53                   	push   %ebx
  801b42:	ff 75 10             	pushl  0x10(%ebp)
  801b45:	e8 d2 e5 ff ff       	call   80011c <vcprintf>
	cprintf("\n");
  801b4a:	c7 04 24 43 23 80 00 	movl   $0x802343,(%esp)
  801b51:	e8 1b e6 ff ff       	call   800171 <cprintf>
  801b56:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b59:	cc                   	int3   
  801b5a:	eb fd                	jmp    801b59 <_panic+0x47>

00801b5c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b5c:	f3 0f 1e fb          	endbr32 
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	56                   	push   %esi
  801b64:	53                   	push   %ebx
  801b65:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b68:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b6b:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801b6e:	85 c0                	test   %eax,%eax
  801b70:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b75:	0f 44 c2             	cmove  %edx,%eax
  801b78:	83 ec 0c             	sub    $0xc,%esp
  801b7b:	50                   	push   %eax
  801b7c:	e8 07 f2 ff ff       	call   800d88 <sys_ipc_recv>
  801b81:	83 c4 10             	add    $0x10,%esp
  801b84:	85 c0                	test   %eax,%eax
  801b86:	78 24                	js     801bac <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801b88:	85 f6                	test   %esi,%esi
  801b8a:	74 0a                	je     801b96 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801b8c:	a1 04 40 80 00       	mov    0x804004,%eax
  801b91:	8b 40 78             	mov    0x78(%eax),%eax
  801b94:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801b96:	85 db                	test   %ebx,%ebx
  801b98:	74 0a                	je     801ba4 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801b9a:	a1 04 40 80 00       	mov    0x804004,%eax
  801b9f:	8b 40 74             	mov    0x74(%eax),%eax
  801ba2:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801ba4:	a1 04 40 80 00       	mov    0x804004,%eax
  801ba9:	8b 40 70             	mov    0x70(%eax),%eax
}
  801bac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801baf:	5b                   	pop    %ebx
  801bb0:	5e                   	pop    %esi
  801bb1:	5d                   	pop    %ebp
  801bb2:	c3                   	ret    

00801bb3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bb3:	f3 0f 1e fb          	endbr32 
  801bb7:	55                   	push   %ebp
  801bb8:	89 e5                	mov    %esp,%ebp
  801bba:	57                   	push   %edi
  801bbb:	56                   	push   %esi
  801bbc:	53                   	push   %ebx
  801bbd:	83 ec 1c             	sub    $0x1c,%esp
  801bc0:	8b 45 10             	mov    0x10(%ebp),%eax
  801bc3:	85 c0                	test   %eax,%eax
  801bc5:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801bca:	0f 45 d0             	cmovne %eax,%edx
  801bcd:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801bcf:	be 01 00 00 00       	mov    $0x1,%esi
  801bd4:	eb 1f                	jmp    801bf5 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801bd6:	e8 be ef ff ff       	call   800b99 <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801bdb:	83 c3 01             	add    $0x1,%ebx
  801bde:	39 de                	cmp    %ebx,%esi
  801be0:	7f f4                	jg     801bd6 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801be2:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801be4:	83 fe 11             	cmp    $0x11,%esi
  801be7:	b8 01 00 00 00       	mov    $0x1,%eax
  801bec:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801bef:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801bf3:	75 1c                	jne    801c11 <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801bf5:	ff 75 14             	pushl  0x14(%ebp)
  801bf8:	57                   	push   %edi
  801bf9:	ff 75 0c             	pushl  0xc(%ebp)
  801bfc:	ff 75 08             	pushl  0x8(%ebp)
  801bff:	e8 5d f1 ff ff       	call   800d61 <sys_ipc_try_send>
  801c04:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801c07:	83 c4 10             	add    $0x10,%esp
  801c0a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c0f:	eb cd                	jmp    801bde <ipc_send+0x2b>
}
  801c11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c14:	5b                   	pop    %ebx
  801c15:	5e                   	pop    %esi
  801c16:	5f                   	pop    %edi
  801c17:	5d                   	pop    %ebp
  801c18:	c3                   	ret    

00801c19 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c19:	f3 0f 1e fb          	endbr32 
  801c1d:	55                   	push   %ebp
  801c1e:	89 e5                	mov    %esp,%ebp
  801c20:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c23:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c28:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c2b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c31:	8b 52 50             	mov    0x50(%edx),%edx
  801c34:	39 ca                	cmp    %ecx,%edx
  801c36:	74 11                	je     801c49 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801c38:	83 c0 01             	add    $0x1,%eax
  801c3b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c40:	75 e6                	jne    801c28 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801c42:	b8 00 00 00 00       	mov    $0x0,%eax
  801c47:	eb 0b                	jmp    801c54 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801c49:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c4c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c51:	8b 40 48             	mov    0x48(%eax),%eax
}
  801c54:	5d                   	pop    %ebp
  801c55:	c3                   	ret    

00801c56 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c56:	f3 0f 1e fb          	endbr32 
  801c5a:	55                   	push   %ebp
  801c5b:	89 e5                	mov    %esp,%ebp
  801c5d:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c60:	89 c2                	mov    %eax,%edx
  801c62:	c1 ea 16             	shr    $0x16,%edx
  801c65:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801c6c:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801c71:	f6 c1 01             	test   $0x1,%cl
  801c74:	74 1c                	je     801c92 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801c76:	c1 e8 0c             	shr    $0xc,%eax
  801c79:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c80:	a8 01                	test   $0x1,%al
  801c82:	74 0e                	je     801c92 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c84:	c1 e8 0c             	shr    $0xc,%eax
  801c87:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801c8e:	ef 
  801c8f:	0f b7 d2             	movzwl %dx,%edx
}
  801c92:	89 d0                	mov    %edx,%eax
  801c94:	5d                   	pop    %ebp
  801c95:	c3                   	ret    
  801c96:	66 90                	xchg   %ax,%ax
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
