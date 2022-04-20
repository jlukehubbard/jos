
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
  80003d:	68 20 10 80 00       	push   $0x801020
  800042:	e8 18 01 00 00       	call   80015f <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800047:	a1 04 20 80 00       	mov    0x802004,%eax
  80004c:	8b 40 48             	mov    0x48(%eax),%eax
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	50                   	push   %eax
  800053:	68 2e 10 80 00       	push   $0x80102e
  800058:	e8 02 01 00 00       	call   80015f <cprintf>
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
    envid_t envid = sys_getenvid();
  800071:	e8 ee 0a 00 00       	call   800b64 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  800076:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800083:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800088:	85 db                	test   %ebx,%ebx
  80008a:	7e 07                	jle    800093 <libmain+0x31>
		binaryname = argv[0];
  80008c:	8b 06                	mov    (%esi),%eax
  80008e:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800093:	83 ec 08             	sub    $0x8,%esp
  800096:	56                   	push   %esi
  800097:	53                   	push   %ebx
  800098:	e8 96 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009d:	e8 0a 00 00 00       	call   8000ac <exit>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a8:	5b                   	pop    %ebx
  8000a9:	5e                   	pop    %esi
  8000aa:	5d                   	pop    %ebp
  8000ab:	c3                   	ret    

008000ac <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ac:	f3 0f 1e fb          	endbr32 
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000b6:	6a 00                	push   $0x0
  8000b8:	e8 62 0a 00 00       	call   800b1f <sys_env_destroy>
}
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	c9                   	leave  
  8000c1:	c3                   	ret    

008000c2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c2:	f3 0f 1e fb          	endbr32 
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	53                   	push   %ebx
  8000ca:	83 ec 04             	sub    $0x4,%esp
  8000cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d0:	8b 13                	mov    (%ebx),%edx
  8000d2:	8d 42 01             	lea    0x1(%edx),%eax
  8000d5:	89 03                	mov    %eax,(%ebx)
  8000d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000da:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000de:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e3:	74 09                	je     8000ee <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000e5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000ec:	c9                   	leave  
  8000ed:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000ee:	83 ec 08             	sub    $0x8,%esp
  8000f1:	68 ff 00 00 00       	push   $0xff
  8000f6:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f9:	50                   	push   %eax
  8000fa:	e8 db 09 00 00       	call   800ada <sys_cputs>
		b->idx = 0;
  8000ff:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800105:	83 c4 10             	add    $0x10,%esp
  800108:	eb db                	jmp    8000e5 <putch+0x23>

0080010a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80010a:	f3 0f 1e fb          	endbr32 
  80010e:	55                   	push   %ebp
  80010f:	89 e5                	mov    %esp,%ebp
  800111:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800117:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80011e:	00 00 00 
	b.cnt = 0;
  800121:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800128:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80012b:	ff 75 0c             	pushl  0xc(%ebp)
  80012e:	ff 75 08             	pushl  0x8(%ebp)
  800131:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800137:	50                   	push   %eax
  800138:	68 c2 00 80 00       	push   $0x8000c2
  80013d:	e8 20 01 00 00       	call   800262 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800142:	83 c4 08             	add    $0x8,%esp
  800145:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80014b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800151:	50                   	push   %eax
  800152:	e8 83 09 00 00       	call   800ada <sys_cputs>

	return b.cnt;
}
  800157:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80015d:	c9                   	leave  
  80015e:	c3                   	ret    

0080015f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80015f:	f3 0f 1e fb          	endbr32 
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800169:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80016c:	50                   	push   %eax
  80016d:	ff 75 08             	pushl  0x8(%ebp)
  800170:	e8 95 ff ff ff       	call   80010a <vcprintf>
	va_end(ap);

	return cnt;
}
  800175:	c9                   	leave  
  800176:	c3                   	ret    

00800177 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	57                   	push   %edi
  80017b:	56                   	push   %esi
  80017c:	53                   	push   %ebx
  80017d:	83 ec 1c             	sub    $0x1c,%esp
  800180:	89 c7                	mov    %eax,%edi
  800182:	89 d6                	mov    %edx,%esi
  800184:	8b 45 08             	mov    0x8(%ebp),%eax
  800187:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018a:	89 d1                	mov    %edx,%ecx
  80018c:	89 c2                	mov    %eax,%edx
  80018e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800191:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800194:	8b 45 10             	mov    0x10(%ebp),%eax
  800197:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80019a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80019d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001a4:	39 c2                	cmp    %eax,%edx
  8001a6:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001a9:	72 3e                	jb     8001e9 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ab:	83 ec 0c             	sub    $0xc,%esp
  8001ae:	ff 75 18             	pushl  0x18(%ebp)
  8001b1:	83 eb 01             	sub    $0x1,%ebx
  8001b4:	53                   	push   %ebx
  8001b5:	50                   	push   %eax
  8001b6:	83 ec 08             	sub    $0x8,%esp
  8001b9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8001bf:	ff 75 dc             	pushl  -0x24(%ebp)
  8001c2:	ff 75 d8             	pushl  -0x28(%ebp)
  8001c5:	e8 f6 0b 00 00       	call   800dc0 <__udivdi3>
  8001ca:	83 c4 18             	add    $0x18,%esp
  8001cd:	52                   	push   %edx
  8001ce:	50                   	push   %eax
  8001cf:	89 f2                	mov    %esi,%edx
  8001d1:	89 f8                	mov    %edi,%eax
  8001d3:	e8 9f ff ff ff       	call   800177 <printnum>
  8001d8:	83 c4 20             	add    $0x20,%esp
  8001db:	eb 13                	jmp    8001f0 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001dd:	83 ec 08             	sub    $0x8,%esp
  8001e0:	56                   	push   %esi
  8001e1:	ff 75 18             	pushl  0x18(%ebp)
  8001e4:	ff d7                	call   *%edi
  8001e6:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001e9:	83 eb 01             	sub    $0x1,%ebx
  8001ec:	85 db                	test   %ebx,%ebx
  8001ee:	7f ed                	jg     8001dd <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001f0:	83 ec 08             	sub    $0x8,%esp
  8001f3:	56                   	push   %esi
  8001f4:	83 ec 04             	sub    $0x4,%esp
  8001f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001fa:	ff 75 e0             	pushl  -0x20(%ebp)
  8001fd:	ff 75 dc             	pushl  -0x24(%ebp)
  800200:	ff 75 d8             	pushl  -0x28(%ebp)
  800203:	e8 c8 0c 00 00       	call   800ed0 <__umoddi3>
  800208:	83 c4 14             	add    $0x14,%esp
  80020b:	0f be 80 4f 10 80 00 	movsbl 0x80104f(%eax),%eax
  800212:	50                   	push   %eax
  800213:	ff d7                	call   *%edi
}
  800215:	83 c4 10             	add    $0x10,%esp
  800218:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021b:	5b                   	pop    %ebx
  80021c:	5e                   	pop    %esi
  80021d:	5f                   	pop    %edi
  80021e:	5d                   	pop    %ebp
  80021f:	c3                   	ret    

00800220 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800220:	f3 0f 1e fb          	endbr32 
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80022a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80022e:	8b 10                	mov    (%eax),%edx
  800230:	3b 50 04             	cmp    0x4(%eax),%edx
  800233:	73 0a                	jae    80023f <sprintputch+0x1f>
		*b->buf++ = ch;
  800235:	8d 4a 01             	lea    0x1(%edx),%ecx
  800238:	89 08                	mov    %ecx,(%eax)
  80023a:	8b 45 08             	mov    0x8(%ebp),%eax
  80023d:	88 02                	mov    %al,(%edx)
}
  80023f:	5d                   	pop    %ebp
  800240:	c3                   	ret    

00800241 <printfmt>:
{
  800241:	f3 0f 1e fb          	endbr32 
  800245:	55                   	push   %ebp
  800246:	89 e5                	mov    %esp,%ebp
  800248:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80024b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80024e:	50                   	push   %eax
  80024f:	ff 75 10             	pushl  0x10(%ebp)
  800252:	ff 75 0c             	pushl  0xc(%ebp)
  800255:	ff 75 08             	pushl  0x8(%ebp)
  800258:	e8 05 00 00 00       	call   800262 <vprintfmt>
}
  80025d:	83 c4 10             	add    $0x10,%esp
  800260:	c9                   	leave  
  800261:	c3                   	ret    

00800262 <vprintfmt>:
{
  800262:	f3 0f 1e fb          	endbr32 
  800266:	55                   	push   %ebp
  800267:	89 e5                	mov    %esp,%ebp
  800269:	57                   	push   %edi
  80026a:	56                   	push   %esi
  80026b:	53                   	push   %ebx
  80026c:	83 ec 3c             	sub    $0x3c,%esp
  80026f:	8b 75 08             	mov    0x8(%ebp),%esi
  800272:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800275:	8b 7d 10             	mov    0x10(%ebp),%edi
  800278:	e9 4a 03 00 00       	jmp    8005c7 <vprintfmt+0x365>
		padc = ' ';
  80027d:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800281:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800288:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80028f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800296:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80029b:	8d 47 01             	lea    0x1(%edi),%eax
  80029e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002a1:	0f b6 17             	movzbl (%edi),%edx
  8002a4:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002a7:	3c 55                	cmp    $0x55,%al
  8002a9:	0f 87 de 03 00 00    	ja     80068d <vprintfmt+0x42b>
  8002af:	0f b6 c0             	movzbl %al,%eax
  8002b2:	3e ff 24 85 20 11 80 	notrack jmp *0x801120(,%eax,4)
  8002b9:	00 
  8002ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002bd:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002c1:	eb d8                	jmp    80029b <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8002c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002c6:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002ca:	eb cf                	jmp    80029b <vprintfmt+0x39>
  8002cc:	0f b6 d2             	movzbl %dl,%edx
  8002cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8002d7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002da:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002dd:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002e1:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002e4:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002e7:	83 f9 09             	cmp    $0x9,%ecx
  8002ea:	77 55                	ja     800341 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8002ec:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002ef:	eb e9                	jmp    8002da <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8002f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f4:	8b 00                	mov    (%eax),%eax
  8002f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8002fc:	8d 40 04             	lea    0x4(%eax),%eax
  8002ff:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800302:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800305:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800309:	79 90                	jns    80029b <vprintfmt+0x39>
				width = precision, precision = -1;
  80030b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80030e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800311:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800318:	eb 81                	jmp    80029b <vprintfmt+0x39>
  80031a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80031d:	85 c0                	test   %eax,%eax
  80031f:	ba 00 00 00 00       	mov    $0x0,%edx
  800324:	0f 49 d0             	cmovns %eax,%edx
  800327:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80032a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80032d:	e9 69 ff ff ff       	jmp    80029b <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800332:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800335:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80033c:	e9 5a ff ff ff       	jmp    80029b <vprintfmt+0x39>
  800341:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800344:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800347:	eb bc                	jmp    800305 <vprintfmt+0xa3>
			lflag++;
  800349:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80034c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80034f:	e9 47 ff ff ff       	jmp    80029b <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800354:	8b 45 14             	mov    0x14(%ebp),%eax
  800357:	8d 78 04             	lea    0x4(%eax),%edi
  80035a:	83 ec 08             	sub    $0x8,%esp
  80035d:	53                   	push   %ebx
  80035e:	ff 30                	pushl  (%eax)
  800360:	ff d6                	call   *%esi
			break;
  800362:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800365:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800368:	e9 57 02 00 00       	jmp    8005c4 <vprintfmt+0x362>
			err = va_arg(ap, int);
  80036d:	8b 45 14             	mov    0x14(%ebp),%eax
  800370:	8d 78 04             	lea    0x4(%eax),%edi
  800373:	8b 00                	mov    (%eax),%eax
  800375:	99                   	cltd   
  800376:	31 d0                	xor    %edx,%eax
  800378:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80037a:	83 f8 08             	cmp    $0x8,%eax
  80037d:	7f 23                	jg     8003a2 <vprintfmt+0x140>
  80037f:	8b 14 85 80 12 80 00 	mov    0x801280(,%eax,4),%edx
  800386:	85 d2                	test   %edx,%edx
  800388:	74 18                	je     8003a2 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80038a:	52                   	push   %edx
  80038b:	68 70 10 80 00       	push   $0x801070
  800390:	53                   	push   %ebx
  800391:	56                   	push   %esi
  800392:	e8 aa fe ff ff       	call   800241 <printfmt>
  800397:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80039a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80039d:	e9 22 02 00 00       	jmp    8005c4 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8003a2:	50                   	push   %eax
  8003a3:	68 67 10 80 00       	push   $0x801067
  8003a8:	53                   	push   %ebx
  8003a9:	56                   	push   %esi
  8003aa:	e8 92 fe ff ff       	call   800241 <printfmt>
  8003af:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003b2:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003b5:	e9 0a 02 00 00       	jmp    8005c4 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8003ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bd:	83 c0 04             	add    $0x4,%eax
  8003c0:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c6:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003c8:	85 d2                	test   %edx,%edx
  8003ca:	b8 60 10 80 00       	mov    $0x801060,%eax
  8003cf:	0f 45 c2             	cmovne %edx,%eax
  8003d2:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d9:	7e 06                	jle    8003e1 <vprintfmt+0x17f>
  8003db:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8003df:	75 0d                	jne    8003ee <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003e1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003e4:	89 c7                	mov    %eax,%edi
  8003e6:	03 45 e0             	add    -0x20(%ebp),%eax
  8003e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ec:	eb 55                	jmp    800443 <vprintfmt+0x1e1>
  8003ee:	83 ec 08             	sub    $0x8,%esp
  8003f1:	ff 75 d8             	pushl  -0x28(%ebp)
  8003f4:	ff 75 cc             	pushl  -0x34(%ebp)
  8003f7:	e8 45 03 00 00       	call   800741 <strnlen>
  8003fc:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003ff:	29 c2                	sub    %eax,%edx
  800401:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800404:	83 c4 10             	add    $0x10,%esp
  800407:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800409:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80040d:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800410:	85 ff                	test   %edi,%edi
  800412:	7e 11                	jle    800425 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800414:	83 ec 08             	sub    $0x8,%esp
  800417:	53                   	push   %ebx
  800418:	ff 75 e0             	pushl  -0x20(%ebp)
  80041b:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80041d:	83 ef 01             	sub    $0x1,%edi
  800420:	83 c4 10             	add    $0x10,%esp
  800423:	eb eb                	jmp    800410 <vprintfmt+0x1ae>
  800425:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800428:	85 d2                	test   %edx,%edx
  80042a:	b8 00 00 00 00       	mov    $0x0,%eax
  80042f:	0f 49 c2             	cmovns %edx,%eax
  800432:	29 c2                	sub    %eax,%edx
  800434:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800437:	eb a8                	jmp    8003e1 <vprintfmt+0x17f>
					putch(ch, putdat);
  800439:	83 ec 08             	sub    $0x8,%esp
  80043c:	53                   	push   %ebx
  80043d:	52                   	push   %edx
  80043e:	ff d6                	call   *%esi
  800440:	83 c4 10             	add    $0x10,%esp
  800443:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800446:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800448:	83 c7 01             	add    $0x1,%edi
  80044b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80044f:	0f be d0             	movsbl %al,%edx
  800452:	85 d2                	test   %edx,%edx
  800454:	74 4b                	je     8004a1 <vprintfmt+0x23f>
  800456:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80045a:	78 06                	js     800462 <vprintfmt+0x200>
  80045c:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800460:	78 1e                	js     800480 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800462:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800466:	74 d1                	je     800439 <vprintfmt+0x1d7>
  800468:	0f be c0             	movsbl %al,%eax
  80046b:	83 e8 20             	sub    $0x20,%eax
  80046e:	83 f8 5e             	cmp    $0x5e,%eax
  800471:	76 c6                	jbe    800439 <vprintfmt+0x1d7>
					putch('?', putdat);
  800473:	83 ec 08             	sub    $0x8,%esp
  800476:	53                   	push   %ebx
  800477:	6a 3f                	push   $0x3f
  800479:	ff d6                	call   *%esi
  80047b:	83 c4 10             	add    $0x10,%esp
  80047e:	eb c3                	jmp    800443 <vprintfmt+0x1e1>
  800480:	89 cf                	mov    %ecx,%edi
  800482:	eb 0e                	jmp    800492 <vprintfmt+0x230>
				putch(' ', putdat);
  800484:	83 ec 08             	sub    $0x8,%esp
  800487:	53                   	push   %ebx
  800488:	6a 20                	push   $0x20
  80048a:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80048c:	83 ef 01             	sub    $0x1,%edi
  80048f:	83 c4 10             	add    $0x10,%esp
  800492:	85 ff                	test   %edi,%edi
  800494:	7f ee                	jg     800484 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800496:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800499:	89 45 14             	mov    %eax,0x14(%ebp)
  80049c:	e9 23 01 00 00       	jmp    8005c4 <vprintfmt+0x362>
  8004a1:	89 cf                	mov    %ecx,%edi
  8004a3:	eb ed                	jmp    800492 <vprintfmt+0x230>
	if (lflag >= 2)
  8004a5:	83 f9 01             	cmp    $0x1,%ecx
  8004a8:	7f 1b                	jg     8004c5 <vprintfmt+0x263>
	else if (lflag)
  8004aa:	85 c9                	test   %ecx,%ecx
  8004ac:	74 63                	je     800511 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8004ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b1:	8b 00                	mov    (%eax),%eax
  8004b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004b6:	99                   	cltd   
  8004b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bd:	8d 40 04             	lea    0x4(%eax),%eax
  8004c0:	89 45 14             	mov    %eax,0x14(%ebp)
  8004c3:	eb 17                	jmp    8004dc <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8004c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c8:	8b 50 04             	mov    0x4(%eax),%edx
  8004cb:	8b 00                	mov    (%eax),%eax
  8004cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004d0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d6:	8d 40 08             	lea    0x8(%eax),%eax
  8004d9:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004dc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004df:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8004e2:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8004e7:	85 c9                	test   %ecx,%ecx
  8004e9:	0f 89 bb 00 00 00    	jns    8005aa <vprintfmt+0x348>
				putch('-', putdat);
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	53                   	push   %ebx
  8004f3:	6a 2d                	push   $0x2d
  8004f5:	ff d6                	call   *%esi
				num = -(long long) num;
  8004f7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004fa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004fd:	f7 da                	neg    %edx
  8004ff:	83 d1 00             	adc    $0x0,%ecx
  800502:	f7 d9                	neg    %ecx
  800504:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800507:	b8 0a 00 00 00       	mov    $0xa,%eax
  80050c:	e9 99 00 00 00       	jmp    8005aa <vprintfmt+0x348>
		return va_arg(*ap, int);
  800511:	8b 45 14             	mov    0x14(%ebp),%eax
  800514:	8b 00                	mov    (%eax),%eax
  800516:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800519:	99                   	cltd   
  80051a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80051d:	8b 45 14             	mov    0x14(%ebp),%eax
  800520:	8d 40 04             	lea    0x4(%eax),%eax
  800523:	89 45 14             	mov    %eax,0x14(%ebp)
  800526:	eb b4                	jmp    8004dc <vprintfmt+0x27a>
	if (lflag >= 2)
  800528:	83 f9 01             	cmp    $0x1,%ecx
  80052b:	7f 1b                	jg     800548 <vprintfmt+0x2e6>
	else if (lflag)
  80052d:	85 c9                	test   %ecx,%ecx
  80052f:	74 2c                	je     80055d <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800531:	8b 45 14             	mov    0x14(%ebp),%eax
  800534:	8b 10                	mov    (%eax),%edx
  800536:	b9 00 00 00 00       	mov    $0x0,%ecx
  80053b:	8d 40 04             	lea    0x4(%eax),%eax
  80053e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800541:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800546:	eb 62                	jmp    8005aa <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800548:	8b 45 14             	mov    0x14(%ebp),%eax
  80054b:	8b 10                	mov    (%eax),%edx
  80054d:	8b 48 04             	mov    0x4(%eax),%ecx
  800550:	8d 40 08             	lea    0x8(%eax),%eax
  800553:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800556:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80055b:	eb 4d                	jmp    8005aa <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80055d:	8b 45 14             	mov    0x14(%ebp),%eax
  800560:	8b 10                	mov    (%eax),%edx
  800562:	b9 00 00 00 00       	mov    $0x0,%ecx
  800567:	8d 40 04             	lea    0x4(%eax),%eax
  80056a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80056d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800572:	eb 36                	jmp    8005aa <vprintfmt+0x348>
	if (lflag >= 2)
  800574:	83 f9 01             	cmp    $0x1,%ecx
  800577:	7f 17                	jg     800590 <vprintfmt+0x32e>
	else if (lflag)
  800579:	85 c9                	test   %ecx,%ecx
  80057b:	74 6e                	je     8005eb <vprintfmt+0x389>
		return va_arg(*ap, long);
  80057d:	8b 45 14             	mov    0x14(%ebp),%eax
  800580:	8b 10                	mov    (%eax),%edx
  800582:	89 d0                	mov    %edx,%eax
  800584:	99                   	cltd   
  800585:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800588:	8d 49 04             	lea    0x4(%ecx),%ecx
  80058b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80058e:	eb 11                	jmp    8005a1 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  800590:	8b 45 14             	mov    0x14(%ebp),%eax
  800593:	8b 50 04             	mov    0x4(%eax),%edx
  800596:	8b 00                	mov    (%eax),%eax
  800598:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80059b:	8d 49 08             	lea    0x8(%ecx),%ecx
  80059e:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8005a1:	89 d1                	mov    %edx,%ecx
  8005a3:	89 c2                	mov    %eax,%edx
            base = 8;
  8005a5:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005aa:	83 ec 0c             	sub    $0xc,%esp
  8005ad:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005b1:	57                   	push   %edi
  8005b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8005b5:	50                   	push   %eax
  8005b6:	51                   	push   %ecx
  8005b7:	52                   	push   %edx
  8005b8:	89 da                	mov    %ebx,%edx
  8005ba:	89 f0                	mov    %esi,%eax
  8005bc:	e8 b6 fb ff ff       	call   800177 <printnum>
			break;
  8005c1:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8005c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005c7:	83 c7 01             	add    $0x1,%edi
  8005ca:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005ce:	83 f8 25             	cmp    $0x25,%eax
  8005d1:	0f 84 a6 fc ff ff    	je     80027d <vprintfmt+0x1b>
			if (ch == '\0')
  8005d7:	85 c0                	test   %eax,%eax
  8005d9:	0f 84 ce 00 00 00    	je     8006ad <vprintfmt+0x44b>
			putch(ch, putdat);
  8005df:	83 ec 08             	sub    $0x8,%esp
  8005e2:	53                   	push   %ebx
  8005e3:	50                   	push   %eax
  8005e4:	ff d6                	call   *%esi
  8005e6:	83 c4 10             	add    $0x10,%esp
  8005e9:	eb dc                	jmp    8005c7 <vprintfmt+0x365>
		return va_arg(*ap, int);
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8b 10                	mov    (%eax),%edx
  8005f0:	89 d0                	mov    %edx,%eax
  8005f2:	99                   	cltd   
  8005f3:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005f6:	8d 49 04             	lea    0x4(%ecx),%ecx
  8005f9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005fc:	eb a3                	jmp    8005a1 <vprintfmt+0x33f>
			putch('0', putdat);
  8005fe:	83 ec 08             	sub    $0x8,%esp
  800601:	53                   	push   %ebx
  800602:	6a 30                	push   $0x30
  800604:	ff d6                	call   *%esi
			putch('x', putdat);
  800606:	83 c4 08             	add    $0x8,%esp
  800609:	53                   	push   %ebx
  80060a:	6a 78                	push   $0x78
  80060c:	ff d6                	call   *%esi
			num = (unsigned long long)
  80060e:	8b 45 14             	mov    0x14(%ebp),%eax
  800611:	8b 10                	mov    (%eax),%edx
  800613:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800618:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80061b:	8d 40 04             	lea    0x4(%eax),%eax
  80061e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800621:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800626:	eb 82                	jmp    8005aa <vprintfmt+0x348>
	if (lflag >= 2)
  800628:	83 f9 01             	cmp    $0x1,%ecx
  80062b:	7f 1e                	jg     80064b <vprintfmt+0x3e9>
	else if (lflag)
  80062d:	85 c9                	test   %ecx,%ecx
  80062f:	74 32                	je     800663 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8b 10                	mov    (%eax),%edx
  800636:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063b:	8d 40 04             	lea    0x4(%eax),%eax
  80063e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800641:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800646:	e9 5f ff ff ff       	jmp    8005aa <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80064b:	8b 45 14             	mov    0x14(%ebp),%eax
  80064e:	8b 10                	mov    (%eax),%edx
  800650:	8b 48 04             	mov    0x4(%eax),%ecx
  800653:	8d 40 08             	lea    0x8(%eax),%eax
  800656:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800659:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80065e:	e9 47 ff ff ff       	jmp    8005aa <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800663:	8b 45 14             	mov    0x14(%ebp),%eax
  800666:	8b 10                	mov    (%eax),%edx
  800668:	b9 00 00 00 00       	mov    $0x0,%ecx
  80066d:	8d 40 04             	lea    0x4(%eax),%eax
  800670:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800673:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800678:	e9 2d ff ff ff       	jmp    8005aa <vprintfmt+0x348>
			putch(ch, putdat);
  80067d:	83 ec 08             	sub    $0x8,%esp
  800680:	53                   	push   %ebx
  800681:	6a 25                	push   $0x25
  800683:	ff d6                	call   *%esi
			break;
  800685:	83 c4 10             	add    $0x10,%esp
  800688:	e9 37 ff ff ff       	jmp    8005c4 <vprintfmt+0x362>
			putch('%', putdat);
  80068d:	83 ec 08             	sub    $0x8,%esp
  800690:	53                   	push   %ebx
  800691:	6a 25                	push   $0x25
  800693:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800695:	83 c4 10             	add    $0x10,%esp
  800698:	89 f8                	mov    %edi,%eax
  80069a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80069e:	74 05                	je     8006a5 <vprintfmt+0x443>
  8006a0:	83 e8 01             	sub    $0x1,%eax
  8006a3:	eb f5                	jmp    80069a <vprintfmt+0x438>
  8006a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006a8:	e9 17 ff ff ff       	jmp    8005c4 <vprintfmt+0x362>
}
  8006ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006b0:	5b                   	pop    %ebx
  8006b1:	5e                   	pop    %esi
  8006b2:	5f                   	pop    %edi
  8006b3:	5d                   	pop    %ebp
  8006b4:	c3                   	ret    

008006b5 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b5:	f3 0f 1e fb          	endbr32 
  8006b9:	55                   	push   %ebp
  8006ba:	89 e5                	mov    %esp,%ebp
  8006bc:	83 ec 18             	sub    $0x18,%esp
  8006bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006cc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d6:	85 c0                	test   %eax,%eax
  8006d8:	74 26                	je     800700 <vsnprintf+0x4b>
  8006da:	85 d2                	test   %edx,%edx
  8006dc:	7e 22                	jle    800700 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006de:	ff 75 14             	pushl  0x14(%ebp)
  8006e1:	ff 75 10             	pushl  0x10(%ebp)
  8006e4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e7:	50                   	push   %eax
  8006e8:	68 20 02 80 00       	push   $0x800220
  8006ed:	e8 70 fb ff ff       	call   800262 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006fb:	83 c4 10             	add    $0x10,%esp
}
  8006fe:	c9                   	leave  
  8006ff:	c3                   	ret    
		return -E_INVAL;
  800700:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800705:	eb f7                	jmp    8006fe <vsnprintf+0x49>

00800707 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800707:	f3 0f 1e fb          	endbr32 
  80070b:	55                   	push   %ebp
  80070c:	89 e5                	mov    %esp,%ebp
  80070e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800711:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800714:	50                   	push   %eax
  800715:	ff 75 10             	pushl  0x10(%ebp)
  800718:	ff 75 0c             	pushl  0xc(%ebp)
  80071b:	ff 75 08             	pushl  0x8(%ebp)
  80071e:	e8 92 ff ff ff       	call   8006b5 <vsnprintf>
	va_end(ap);

	return rc;
}
  800723:	c9                   	leave  
  800724:	c3                   	ret    

00800725 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800725:	f3 0f 1e fb          	endbr32 
  800729:	55                   	push   %ebp
  80072a:	89 e5                	mov    %esp,%ebp
  80072c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80072f:	b8 00 00 00 00       	mov    $0x0,%eax
  800734:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800738:	74 05                	je     80073f <strlen+0x1a>
		n++;
  80073a:	83 c0 01             	add    $0x1,%eax
  80073d:	eb f5                	jmp    800734 <strlen+0xf>
	return n;
}
  80073f:	5d                   	pop    %ebp
  800740:	c3                   	ret    

00800741 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800741:	f3 0f 1e fb          	endbr32 
  800745:	55                   	push   %ebp
  800746:	89 e5                	mov    %esp,%ebp
  800748:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80074b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074e:	b8 00 00 00 00       	mov    $0x0,%eax
  800753:	39 d0                	cmp    %edx,%eax
  800755:	74 0d                	je     800764 <strnlen+0x23>
  800757:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80075b:	74 05                	je     800762 <strnlen+0x21>
		n++;
  80075d:	83 c0 01             	add    $0x1,%eax
  800760:	eb f1                	jmp    800753 <strnlen+0x12>
  800762:	89 c2                	mov    %eax,%edx
	return n;
}
  800764:	89 d0                	mov    %edx,%eax
  800766:	5d                   	pop    %ebp
  800767:	c3                   	ret    

00800768 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800768:	f3 0f 1e fb          	endbr32 
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	53                   	push   %ebx
  800770:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800773:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800776:	b8 00 00 00 00       	mov    $0x0,%eax
  80077b:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80077f:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800782:	83 c0 01             	add    $0x1,%eax
  800785:	84 d2                	test   %dl,%dl
  800787:	75 f2                	jne    80077b <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800789:	89 c8                	mov    %ecx,%eax
  80078b:	5b                   	pop    %ebx
  80078c:	5d                   	pop    %ebp
  80078d:	c3                   	ret    

0080078e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80078e:	f3 0f 1e fb          	endbr32 
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	53                   	push   %ebx
  800796:	83 ec 10             	sub    $0x10,%esp
  800799:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079c:	53                   	push   %ebx
  80079d:	e8 83 ff ff ff       	call   800725 <strlen>
  8007a2:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007a5:	ff 75 0c             	pushl  0xc(%ebp)
  8007a8:	01 d8                	add    %ebx,%eax
  8007aa:	50                   	push   %eax
  8007ab:	e8 b8 ff ff ff       	call   800768 <strcpy>
	return dst;
}
  8007b0:	89 d8                	mov    %ebx,%eax
  8007b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b5:	c9                   	leave  
  8007b6:	c3                   	ret    

008007b7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b7:	f3 0f 1e fb          	endbr32 
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	56                   	push   %esi
  8007bf:	53                   	push   %ebx
  8007c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c6:	89 f3                	mov    %esi,%ebx
  8007c8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007cb:	89 f0                	mov    %esi,%eax
  8007cd:	39 d8                	cmp    %ebx,%eax
  8007cf:	74 11                	je     8007e2 <strncpy+0x2b>
		*dst++ = *src;
  8007d1:	83 c0 01             	add    $0x1,%eax
  8007d4:	0f b6 0a             	movzbl (%edx),%ecx
  8007d7:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007da:	80 f9 01             	cmp    $0x1,%cl
  8007dd:	83 da ff             	sbb    $0xffffffff,%edx
  8007e0:	eb eb                	jmp    8007cd <strncpy+0x16>
	}
	return ret;
}
  8007e2:	89 f0                	mov    %esi,%eax
  8007e4:	5b                   	pop    %ebx
  8007e5:	5e                   	pop    %esi
  8007e6:	5d                   	pop    %ebp
  8007e7:	c3                   	ret    

008007e8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e8:	f3 0f 1e fb          	endbr32 
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	56                   	push   %esi
  8007f0:	53                   	push   %ebx
  8007f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f7:	8b 55 10             	mov    0x10(%ebp),%edx
  8007fa:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007fc:	85 d2                	test   %edx,%edx
  8007fe:	74 21                	je     800821 <strlcpy+0x39>
  800800:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800804:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800806:	39 c2                	cmp    %eax,%edx
  800808:	74 14                	je     80081e <strlcpy+0x36>
  80080a:	0f b6 19             	movzbl (%ecx),%ebx
  80080d:	84 db                	test   %bl,%bl
  80080f:	74 0b                	je     80081c <strlcpy+0x34>
			*dst++ = *src++;
  800811:	83 c1 01             	add    $0x1,%ecx
  800814:	83 c2 01             	add    $0x1,%edx
  800817:	88 5a ff             	mov    %bl,-0x1(%edx)
  80081a:	eb ea                	jmp    800806 <strlcpy+0x1e>
  80081c:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80081e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800821:	29 f0                	sub    %esi,%eax
}
  800823:	5b                   	pop    %ebx
  800824:	5e                   	pop    %esi
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800827:	f3 0f 1e fb          	endbr32 
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800831:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800834:	0f b6 01             	movzbl (%ecx),%eax
  800837:	84 c0                	test   %al,%al
  800839:	74 0c                	je     800847 <strcmp+0x20>
  80083b:	3a 02                	cmp    (%edx),%al
  80083d:	75 08                	jne    800847 <strcmp+0x20>
		p++, q++;
  80083f:	83 c1 01             	add    $0x1,%ecx
  800842:	83 c2 01             	add    $0x1,%edx
  800845:	eb ed                	jmp    800834 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800847:	0f b6 c0             	movzbl %al,%eax
  80084a:	0f b6 12             	movzbl (%edx),%edx
  80084d:	29 d0                	sub    %edx,%eax
}
  80084f:	5d                   	pop    %ebp
  800850:	c3                   	ret    

00800851 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800851:	f3 0f 1e fb          	endbr32 
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	53                   	push   %ebx
  800859:	8b 45 08             	mov    0x8(%ebp),%eax
  80085c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085f:	89 c3                	mov    %eax,%ebx
  800861:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800864:	eb 06                	jmp    80086c <strncmp+0x1b>
		n--, p++, q++;
  800866:	83 c0 01             	add    $0x1,%eax
  800869:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80086c:	39 d8                	cmp    %ebx,%eax
  80086e:	74 16                	je     800886 <strncmp+0x35>
  800870:	0f b6 08             	movzbl (%eax),%ecx
  800873:	84 c9                	test   %cl,%cl
  800875:	74 04                	je     80087b <strncmp+0x2a>
  800877:	3a 0a                	cmp    (%edx),%cl
  800879:	74 eb                	je     800866 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80087b:	0f b6 00             	movzbl (%eax),%eax
  80087e:	0f b6 12             	movzbl (%edx),%edx
  800881:	29 d0                	sub    %edx,%eax
}
  800883:	5b                   	pop    %ebx
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    
		return 0;
  800886:	b8 00 00 00 00       	mov    $0x0,%eax
  80088b:	eb f6                	jmp    800883 <strncmp+0x32>

0080088d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80088d:	f3 0f 1e fb          	endbr32 
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	8b 45 08             	mov    0x8(%ebp),%eax
  800897:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80089b:	0f b6 10             	movzbl (%eax),%edx
  80089e:	84 d2                	test   %dl,%dl
  8008a0:	74 09                	je     8008ab <strchr+0x1e>
		if (*s == c)
  8008a2:	38 ca                	cmp    %cl,%dl
  8008a4:	74 0a                	je     8008b0 <strchr+0x23>
	for (; *s; s++)
  8008a6:	83 c0 01             	add    $0x1,%eax
  8008a9:	eb f0                	jmp    80089b <strchr+0xe>
			return (char *) s;
	return 0;
  8008ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008b2:	f3 0f 1e fb          	endbr32 
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008c3:	38 ca                	cmp    %cl,%dl
  8008c5:	74 09                	je     8008d0 <strfind+0x1e>
  8008c7:	84 d2                	test   %dl,%dl
  8008c9:	74 05                	je     8008d0 <strfind+0x1e>
	for (; *s; s++)
  8008cb:	83 c0 01             	add    $0x1,%eax
  8008ce:	eb f0                	jmp    8008c0 <strfind+0xe>
			break;
	return (char *) s;
}
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d2:	f3 0f 1e fb          	endbr32 
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	57                   	push   %edi
  8008da:	56                   	push   %esi
  8008db:	53                   	push   %ebx
  8008dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008df:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e2:	85 c9                	test   %ecx,%ecx
  8008e4:	74 31                	je     800917 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e6:	89 f8                	mov    %edi,%eax
  8008e8:	09 c8                	or     %ecx,%eax
  8008ea:	a8 03                	test   $0x3,%al
  8008ec:	75 23                	jne    800911 <memset+0x3f>
		c &= 0xFF;
  8008ee:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f2:	89 d3                	mov    %edx,%ebx
  8008f4:	c1 e3 08             	shl    $0x8,%ebx
  8008f7:	89 d0                	mov    %edx,%eax
  8008f9:	c1 e0 18             	shl    $0x18,%eax
  8008fc:	89 d6                	mov    %edx,%esi
  8008fe:	c1 e6 10             	shl    $0x10,%esi
  800901:	09 f0                	or     %esi,%eax
  800903:	09 c2                	or     %eax,%edx
  800905:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800907:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80090a:	89 d0                	mov    %edx,%eax
  80090c:	fc                   	cld    
  80090d:	f3 ab                	rep stos %eax,%es:(%edi)
  80090f:	eb 06                	jmp    800917 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800911:	8b 45 0c             	mov    0xc(%ebp),%eax
  800914:	fc                   	cld    
  800915:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800917:	89 f8                	mov    %edi,%eax
  800919:	5b                   	pop    %ebx
  80091a:	5e                   	pop    %esi
  80091b:	5f                   	pop    %edi
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80091e:	f3 0f 1e fb          	endbr32 
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	57                   	push   %edi
  800926:	56                   	push   %esi
  800927:	8b 45 08             	mov    0x8(%ebp),%eax
  80092a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80092d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800930:	39 c6                	cmp    %eax,%esi
  800932:	73 32                	jae    800966 <memmove+0x48>
  800934:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800937:	39 c2                	cmp    %eax,%edx
  800939:	76 2b                	jbe    800966 <memmove+0x48>
		s += n;
		d += n;
  80093b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093e:	89 fe                	mov    %edi,%esi
  800940:	09 ce                	or     %ecx,%esi
  800942:	09 d6                	or     %edx,%esi
  800944:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80094a:	75 0e                	jne    80095a <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80094c:	83 ef 04             	sub    $0x4,%edi
  80094f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800952:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800955:	fd                   	std    
  800956:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800958:	eb 09                	jmp    800963 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80095a:	83 ef 01             	sub    $0x1,%edi
  80095d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800960:	fd                   	std    
  800961:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800963:	fc                   	cld    
  800964:	eb 1a                	jmp    800980 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800966:	89 c2                	mov    %eax,%edx
  800968:	09 ca                	or     %ecx,%edx
  80096a:	09 f2                	or     %esi,%edx
  80096c:	f6 c2 03             	test   $0x3,%dl
  80096f:	75 0a                	jne    80097b <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800971:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800974:	89 c7                	mov    %eax,%edi
  800976:	fc                   	cld    
  800977:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800979:	eb 05                	jmp    800980 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  80097b:	89 c7                	mov    %eax,%edi
  80097d:	fc                   	cld    
  80097e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800980:	5e                   	pop    %esi
  800981:	5f                   	pop    %edi
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800984:	f3 0f 1e fb          	endbr32 
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80098e:	ff 75 10             	pushl  0x10(%ebp)
  800991:	ff 75 0c             	pushl  0xc(%ebp)
  800994:	ff 75 08             	pushl  0x8(%ebp)
  800997:	e8 82 ff ff ff       	call   80091e <memmove>
}
  80099c:	c9                   	leave  
  80099d:	c3                   	ret    

0080099e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80099e:	f3 0f 1e fb          	endbr32 
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	56                   	push   %esi
  8009a6:	53                   	push   %ebx
  8009a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ad:	89 c6                	mov    %eax,%esi
  8009af:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b2:	39 f0                	cmp    %esi,%eax
  8009b4:	74 1c                	je     8009d2 <memcmp+0x34>
		if (*s1 != *s2)
  8009b6:	0f b6 08             	movzbl (%eax),%ecx
  8009b9:	0f b6 1a             	movzbl (%edx),%ebx
  8009bc:	38 d9                	cmp    %bl,%cl
  8009be:	75 08                	jne    8009c8 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009c0:	83 c0 01             	add    $0x1,%eax
  8009c3:	83 c2 01             	add    $0x1,%edx
  8009c6:	eb ea                	jmp    8009b2 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  8009c8:	0f b6 c1             	movzbl %cl,%eax
  8009cb:	0f b6 db             	movzbl %bl,%ebx
  8009ce:	29 d8                	sub    %ebx,%eax
  8009d0:	eb 05                	jmp    8009d7 <memcmp+0x39>
	}

	return 0;
  8009d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d7:	5b                   	pop    %ebx
  8009d8:	5e                   	pop    %esi
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009db:	f3 0f 1e fb          	endbr32 
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009e8:	89 c2                	mov    %eax,%edx
  8009ea:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009ed:	39 d0                	cmp    %edx,%eax
  8009ef:	73 09                	jae    8009fa <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f1:	38 08                	cmp    %cl,(%eax)
  8009f3:	74 05                	je     8009fa <memfind+0x1f>
	for (; s < ends; s++)
  8009f5:	83 c0 01             	add    $0x1,%eax
  8009f8:	eb f3                	jmp    8009ed <memfind+0x12>
			break;
	return (void *) s;
}
  8009fa:	5d                   	pop    %ebp
  8009fb:	c3                   	ret    

008009fc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009fc:	f3 0f 1e fb          	endbr32 
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	57                   	push   %edi
  800a04:	56                   	push   %esi
  800a05:	53                   	push   %ebx
  800a06:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a09:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0c:	eb 03                	jmp    800a11 <strtol+0x15>
		s++;
  800a0e:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a11:	0f b6 01             	movzbl (%ecx),%eax
  800a14:	3c 20                	cmp    $0x20,%al
  800a16:	74 f6                	je     800a0e <strtol+0x12>
  800a18:	3c 09                	cmp    $0x9,%al
  800a1a:	74 f2                	je     800a0e <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a1c:	3c 2b                	cmp    $0x2b,%al
  800a1e:	74 2a                	je     800a4a <strtol+0x4e>
	int neg = 0;
  800a20:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a25:	3c 2d                	cmp    $0x2d,%al
  800a27:	74 2b                	je     800a54 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a29:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a2f:	75 0f                	jne    800a40 <strtol+0x44>
  800a31:	80 39 30             	cmpb   $0x30,(%ecx)
  800a34:	74 28                	je     800a5e <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a36:	85 db                	test   %ebx,%ebx
  800a38:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a3d:	0f 44 d8             	cmove  %eax,%ebx
  800a40:	b8 00 00 00 00       	mov    $0x0,%eax
  800a45:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a48:	eb 46                	jmp    800a90 <strtol+0x94>
		s++;
  800a4a:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a4d:	bf 00 00 00 00       	mov    $0x0,%edi
  800a52:	eb d5                	jmp    800a29 <strtol+0x2d>
		s++, neg = 1;
  800a54:	83 c1 01             	add    $0x1,%ecx
  800a57:	bf 01 00 00 00       	mov    $0x1,%edi
  800a5c:	eb cb                	jmp    800a29 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a62:	74 0e                	je     800a72 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a64:	85 db                	test   %ebx,%ebx
  800a66:	75 d8                	jne    800a40 <strtol+0x44>
		s++, base = 8;
  800a68:	83 c1 01             	add    $0x1,%ecx
  800a6b:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a70:	eb ce                	jmp    800a40 <strtol+0x44>
		s += 2, base = 16;
  800a72:	83 c1 02             	add    $0x2,%ecx
  800a75:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a7a:	eb c4                	jmp    800a40 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a7c:	0f be d2             	movsbl %dl,%edx
  800a7f:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a82:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a85:	7d 3a                	jge    800ac1 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a87:	83 c1 01             	add    $0x1,%ecx
  800a8a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a8e:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a90:	0f b6 11             	movzbl (%ecx),%edx
  800a93:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a96:	89 f3                	mov    %esi,%ebx
  800a98:	80 fb 09             	cmp    $0x9,%bl
  800a9b:	76 df                	jbe    800a7c <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800a9d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aa0:	89 f3                	mov    %esi,%ebx
  800aa2:	80 fb 19             	cmp    $0x19,%bl
  800aa5:	77 08                	ja     800aaf <strtol+0xb3>
			dig = *s - 'a' + 10;
  800aa7:	0f be d2             	movsbl %dl,%edx
  800aaa:	83 ea 57             	sub    $0x57,%edx
  800aad:	eb d3                	jmp    800a82 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800aaf:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ab2:	89 f3                	mov    %esi,%ebx
  800ab4:	80 fb 19             	cmp    $0x19,%bl
  800ab7:	77 08                	ja     800ac1 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ab9:	0f be d2             	movsbl %dl,%edx
  800abc:	83 ea 37             	sub    $0x37,%edx
  800abf:	eb c1                	jmp    800a82 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ac1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac5:	74 05                	je     800acc <strtol+0xd0>
		*endptr = (char *) s;
  800ac7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aca:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800acc:	89 c2                	mov    %eax,%edx
  800ace:	f7 da                	neg    %edx
  800ad0:	85 ff                	test   %edi,%edi
  800ad2:	0f 45 c2             	cmovne %edx,%eax
}
  800ad5:	5b                   	pop    %ebx
  800ad6:	5e                   	pop    %esi
  800ad7:	5f                   	pop    %edi
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ada:	f3 0f 1e fb          	endbr32 
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	57                   	push   %edi
  800ae2:	56                   	push   %esi
  800ae3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ae4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae9:	8b 55 08             	mov    0x8(%ebp),%edx
  800aec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aef:	89 c3                	mov    %eax,%ebx
  800af1:	89 c7                	mov    %eax,%edi
  800af3:	89 c6                	mov    %eax,%esi
  800af5:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800af7:	5b                   	pop    %ebx
  800af8:	5e                   	pop    %esi
  800af9:	5f                   	pop    %edi
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    

00800afc <sys_cgetc>:

int
sys_cgetc(void)
{
  800afc:	f3 0f 1e fb          	endbr32 
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	57                   	push   %edi
  800b04:	56                   	push   %esi
  800b05:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b06:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b10:	89 d1                	mov    %edx,%ecx
  800b12:	89 d3                	mov    %edx,%ebx
  800b14:	89 d7                	mov    %edx,%edi
  800b16:	89 d6                	mov    %edx,%esi
  800b18:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b1a:	5b                   	pop    %ebx
  800b1b:	5e                   	pop    %esi
  800b1c:	5f                   	pop    %edi
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    

00800b1f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b1f:	f3 0f 1e fb          	endbr32 
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	57                   	push   %edi
  800b27:	56                   	push   %esi
  800b28:	53                   	push   %ebx
  800b29:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b2c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b31:	8b 55 08             	mov    0x8(%ebp),%edx
  800b34:	b8 03 00 00 00       	mov    $0x3,%eax
  800b39:	89 cb                	mov    %ecx,%ebx
  800b3b:	89 cf                	mov    %ecx,%edi
  800b3d:	89 ce                	mov    %ecx,%esi
  800b3f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b41:	85 c0                	test   %eax,%eax
  800b43:	7f 08                	jg     800b4d <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5f                   	pop    %edi
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b4d:	83 ec 0c             	sub    $0xc,%esp
  800b50:	50                   	push   %eax
  800b51:	6a 03                	push   $0x3
  800b53:	68 a4 12 80 00       	push   $0x8012a4
  800b58:	6a 23                	push   $0x23
  800b5a:	68 c1 12 80 00       	push   $0x8012c1
  800b5f:	e8 11 02 00 00       	call   800d75 <_panic>

00800b64 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b64:	f3 0f 1e fb          	endbr32 
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	57                   	push   %edi
  800b6c:	56                   	push   %esi
  800b6d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b73:	b8 02 00 00 00       	mov    $0x2,%eax
  800b78:	89 d1                	mov    %edx,%ecx
  800b7a:	89 d3                	mov    %edx,%ebx
  800b7c:	89 d7                	mov    %edx,%edi
  800b7e:	89 d6                	mov    %edx,%esi
  800b80:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b82:	5b                   	pop    %ebx
  800b83:	5e                   	pop    %esi
  800b84:	5f                   	pop    %edi
  800b85:	5d                   	pop    %ebp
  800b86:	c3                   	ret    

00800b87 <sys_yield>:

void
sys_yield(void)
{
  800b87:	f3 0f 1e fb          	endbr32 
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	57                   	push   %edi
  800b8f:	56                   	push   %esi
  800b90:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b91:	ba 00 00 00 00       	mov    $0x0,%edx
  800b96:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b9b:	89 d1                	mov    %edx,%ecx
  800b9d:	89 d3                	mov    %edx,%ebx
  800b9f:	89 d7                	mov    %edx,%edi
  800ba1:	89 d6                	mov    %edx,%esi
  800ba3:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ba5:	5b                   	pop    %ebx
  800ba6:	5e                   	pop    %esi
  800ba7:	5f                   	pop    %edi
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800baa:	f3 0f 1e fb          	endbr32 
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bb7:	be 00 00 00 00       	mov    $0x0,%esi
  800bbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc2:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bca:	89 f7                	mov    %esi,%edi
  800bcc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bce:	85 c0                	test   %eax,%eax
  800bd0:	7f 08                	jg     800bda <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd5:	5b                   	pop    %ebx
  800bd6:	5e                   	pop    %esi
  800bd7:	5f                   	pop    %edi
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bda:	83 ec 0c             	sub    $0xc,%esp
  800bdd:	50                   	push   %eax
  800bde:	6a 04                	push   $0x4
  800be0:	68 a4 12 80 00       	push   $0x8012a4
  800be5:	6a 23                	push   $0x23
  800be7:	68 c1 12 80 00       	push   $0x8012c1
  800bec:	e8 84 01 00 00       	call   800d75 <_panic>

00800bf1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf1:	f3 0f 1e fb          	endbr32 
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
  800bfb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800c01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c04:	b8 05 00 00 00       	mov    $0x5,%eax
  800c09:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c0c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c0f:	8b 75 18             	mov    0x18(%ebp),%esi
  800c12:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c14:	85 c0                	test   %eax,%eax
  800c16:	7f 08                	jg     800c20 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1b:	5b                   	pop    %ebx
  800c1c:	5e                   	pop    %esi
  800c1d:	5f                   	pop    %edi
  800c1e:	5d                   	pop    %ebp
  800c1f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c20:	83 ec 0c             	sub    $0xc,%esp
  800c23:	50                   	push   %eax
  800c24:	6a 05                	push   $0x5
  800c26:	68 a4 12 80 00       	push   $0x8012a4
  800c2b:	6a 23                	push   $0x23
  800c2d:	68 c1 12 80 00       	push   $0x8012c1
  800c32:	e8 3e 01 00 00       	call   800d75 <_panic>

00800c37 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c37:	f3 0f 1e fb          	endbr32 
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
  800c41:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c44:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c49:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4f:	b8 06 00 00 00       	mov    $0x6,%eax
  800c54:	89 df                	mov    %ebx,%edi
  800c56:	89 de                	mov    %ebx,%esi
  800c58:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c5a:	85 c0                	test   %eax,%eax
  800c5c:	7f 08                	jg     800c66 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c61:	5b                   	pop    %ebx
  800c62:	5e                   	pop    %esi
  800c63:	5f                   	pop    %edi
  800c64:	5d                   	pop    %ebp
  800c65:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c66:	83 ec 0c             	sub    $0xc,%esp
  800c69:	50                   	push   %eax
  800c6a:	6a 06                	push   $0x6
  800c6c:	68 a4 12 80 00       	push   $0x8012a4
  800c71:	6a 23                	push   $0x23
  800c73:	68 c1 12 80 00       	push   $0x8012c1
  800c78:	e8 f8 00 00 00       	call   800d75 <_panic>

00800c7d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c7d:	f3 0f 1e fb          	endbr32 
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	57                   	push   %edi
  800c85:	56                   	push   %esi
  800c86:	53                   	push   %ebx
  800c87:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c95:	b8 08 00 00 00       	mov    $0x8,%eax
  800c9a:	89 df                	mov    %ebx,%edi
  800c9c:	89 de                	mov    %ebx,%esi
  800c9e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca0:	85 c0                	test   %eax,%eax
  800ca2:	7f 08                	jg     800cac <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ca4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca7:	5b                   	pop    %ebx
  800ca8:	5e                   	pop    %esi
  800ca9:	5f                   	pop    %edi
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cac:	83 ec 0c             	sub    $0xc,%esp
  800caf:	50                   	push   %eax
  800cb0:	6a 08                	push   $0x8
  800cb2:	68 a4 12 80 00       	push   $0x8012a4
  800cb7:	6a 23                	push   $0x23
  800cb9:	68 c1 12 80 00       	push   $0x8012c1
  800cbe:	e8 b2 00 00 00       	call   800d75 <_panic>

00800cc3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc3:	f3 0f 1e fb          	endbr32 
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	57                   	push   %edi
  800ccb:	56                   	push   %esi
  800ccc:	53                   	push   %ebx
  800ccd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdb:	b8 09 00 00 00       	mov    $0x9,%eax
  800ce0:	89 df                	mov    %ebx,%edi
  800ce2:	89 de                	mov    %ebx,%esi
  800ce4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce6:	85 c0                	test   %eax,%eax
  800ce8:	7f 08                	jg     800cf2 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ced:	5b                   	pop    %ebx
  800cee:	5e                   	pop    %esi
  800cef:	5f                   	pop    %edi
  800cf0:	5d                   	pop    %ebp
  800cf1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf2:	83 ec 0c             	sub    $0xc,%esp
  800cf5:	50                   	push   %eax
  800cf6:	6a 09                	push   $0x9
  800cf8:	68 a4 12 80 00       	push   $0x8012a4
  800cfd:	6a 23                	push   $0x23
  800cff:	68 c1 12 80 00       	push   $0x8012c1
  800d04:	e8 6c 00 00 00       	call   800d75 <_panic>

00800d09 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d09:	f3 0f 1e fb          	endbr32 
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d13:	8b 55 08             	mov    0x8(%ebp),%edx
  800d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d19:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d1e:	be 00 00 00 00       	mov    $0x0,%esi
  800d23:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d26:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d29:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d30:	f3 0f 1e fb          	endbr32 
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	57                   	push   %edi
  800d38:	56                   	push   %esi
  800d39:	53                   	push   %ebx
  800d3a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d3d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d42:	8b 55 08             	mov    0x8(%ebp),%edx
  800d45:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d4a:	89 cb                	mov    %ecx,%ebx
  800d4c:	89 cf                	mov    %ecx,%edi
  800d4e:	89 ce                	mov    %ecx,%esi
  800d50:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d52:	85 c0                	test   %eax,%eax
  800d54:	7f 08                	jg     800d5e <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5e:	83 ec 0c             	sub    $0xc,%esp
  800d61:	50                   	push   %eax
  800d62:	6a 0c                	push   $0xc
  800d64:	68 a4 12 80 00       	push   $0x8012a4
  800d69:	6a 23                	push   $0x23
  800d6b:	68 c1 12 80 00       	push   $0x8012c1
  800d70:	e8 00 00 00 00       	call   800d75 <_panic>

00800d75 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d75:	f3 0f 1e fb          	endbr32 
  800d79:	55                   	push   %ebp
  800d7a:	89 e5                	mov    %esp,%ebp
  800d7c:	56                   	push   %esi
  800d7d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d7e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d81:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d87:	e8 d8 fd ff ff       	call   800b64 <sys_getenvid>
  800d8c:	83 ec 0c             	sub    $0xc,%esp
  800d8f:	ff 75 0c             	pushl  0xc(%ebp)
  800d92:	ff 75 08             	pushl  0x8(%ebp)
  800d95:	56                   	push   %esi
  800d96:	50                   	push   %eax
  800d97:	68 d0 12 80 00       	push   $0x8012d0
  800d9c:	e8 be f3 ff ff       	call   80015f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800da1:	83 c4 18             	add    $0x18,%esp
  800da4:	53                   	push   %ebx
  800da5:	ff 75 10             	pushl  0x10(%ebp)
  800da8:	e8 5d f3 ff ff       	call   80010a <vcprintf>
	cprintf("\n");
  800dad:	c7 04 24 2c 10 80 00 	movl   $0x80102c,(%esp)
  800db4:	e8 a6 f3 ff ff       	call   80015f <cprintf>
  800db9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800dbc:	cc                   	int3   
  800dbd:	eb fd                	jmp    800dbc <_panic+0x47>
  800dbf:	90                   	nop

00800dc0 <__udivdi3>:
  800dc0:	f3 0f 1e fb          	endbr32 
  800dc4:	55                   	push   %ebp
  800dc5:	57                   	push   %edi
  800dc6:	56                   	push   %esi
  800dc7:	53                   	push   %ebx
  800dc8:	83 ec 1c             	sub    $0x1c,%esp
  800dcb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800dcf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800dd3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800dd7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800ddb:	85 d2                	test   %edx,%edx
  800ddd:	75 19                	jne    800df8 <__udivdi3+0x38>
  800ddf:	39 f3                	cmp    %esi,%ebx
  800de1:	76 4d                	jbe    800e30 <__udivdi3+0x70>
  800de3:	31 ff                	xor    %edi,%edi
  800de5:	89 e8                	mov    %ebp,%eax
  800de7:	89 f2                	mov    %esi,%edx
  800de9:	f7 f3                	div    %ebx
  800deb:	89 fa                	mov    %edi,%edx
  800ded:	83 c4 1c             	add    $0x1c,%esp
  800df0:	5b                   	pop    %ebx
  800df1:	5e                   	pop    %esi
  800df2:	5f                   	pop    %edi
  800df3:	5d                   	pop    %ebp
  800df4:	c3                   	ret    
  800df5:	8d 76 00             	lea    0x0(%esi),%esi
  800df8:	39 f2                	cmp    %esi,%edx
  800dfa:	76 14                	jbe    800e10 <__udivdi3+0x50>
  800dfc:	31 ff                	xor    %edi,%edi
  800dfe:	31 c0                	xor    %eax,%eax
  800e00:	89 fa                	mov    %edi,%edx
  800e02:	83 c4 1c             	add    $0x1c,%esp
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    
  800e0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e10:	0f bd fa             	bsr    %edx,%edi
  800e13:	83 f7 1f             	xor    $0x1f,%edi
  800e16:	75 48                	jne    800e60 <__udivdi3+0xa0>
  800e18:	39 f2                	cmp    %esi,%edx
  800e1a:	72 06                	jb     800e22 <__udivdi3+0x62>
  800e1c:	31 c0                	xor    %eax,%eax
  800e1e:	39 eb                	cmp    %ebp,%ebx
  800e20:	77 de                	ja     800e00 <__udivdi3+0x40>
  800e22:	b8 01 00 00 00       	mov    $0x1,%eax
  800e27:	eb d7                	jmp    800e00 <__udivdi3+0x40>
  800e29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e30:	89 d9                	mov    %ebx,%ecx
  800e32:	85 db                	test   %ebx,%ebx
  800e34:	75 0b                	jne    800e41 <__udivdi3+0x81>
  800e36:	b8 01 00 00 00       	mov    $0x1,%eax
  800e3b:	31 d2                	xor    %edx,%edx
  800e3d:	f7 f3                	div    %ebx
  800e3f:	89 c1                	mov    %eax,%ecx
  800e41:	31 d2                	xor    %edx,%edx
  800e43:	89 f0                	mov    %esi,%eax
  800e45:	f7 f1                	div    %ecx
  800e47:	89 c6                	mov    %eax,%esi
  800e49:	89 e8                	mov    %ebp,%eax
  800e4b:	89 f7                	mov    %esi,%edi
  800e4d:	f7 f1                	div    %ecx
  800e4f:	89 fa                	mov    %edi,%edx
  800e51:	83 c4 1c             	add    $0x1c,%esp
  800e54:	5b                   	pop    %ebx
  800e55:	5e                   	pop    %esi
  800e56:	5f                   	pop    %edi
  800e57:	5d                   	pop    %ebp
  800e58:	c3                   	ret    
  800e59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e60:	89 f9                	mov    %edi,%ecx
  800e62:	b8 20 00 00 00       	mov    $0x20,%eax
  800e67:	29 f8                	sub    %edi,%eax
  800e69:	d3 e2                	shl    %cl,%edx
  800e6b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e6f:	89 c1                	mov    %eax,%ecx
  800e71:	89 da                	mov    %ebx,%edx
  800e73:	d3 ea                	shr    %cl,%edx
  800e75:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e79:	09 d1                	or     %edx,%ecx
  800e7b:	89 f2                	mov    %esi,%edx
  800e7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e81:	89 f9                	mov    %edi,%ecx
  800e83:	d3 e3                	shl    %cl,%ebx
  800e85:	89 c1                	mov    %eax,%ecx
  800e87:	d3 ea                	shr    %cl,%edx
  800e89:	89 f9                	mov    %edi,%ecx
  800e8b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e8f:	89 eb                	mov    %ebp,%ebx
  800e91:	d3 e6                	shl    %cl,%esi
  800e93:	89 c1                	mov    %eax,%ecx
  800e95:	d3 eb                	shr    %cl,%ebx
  800e97:	09 de                	or     %ebx,%esi
  800e99:	89 f0                	mov    %esi,%eax
  800e9b:	f7 74 24 08          	divl   0x8(%esp)
  800e9f:	89 d6                	mov    %edx,%esi
  800ea1:	89 c3                	mov    %eax,%ebx
  800ea3:	f7 64 24 0c          	mull   0xc(%esp)
  800ea7:	39 d6                	cmp    %edx,%esi
  800ea9:	72 15                	jb     800ec0 <__udivdi3+0x100>
  800eab:	89 f9                	mov    %edi,%ecx
  800ead:	d3 e5                	shl    %cl,%ebp
  800eaf:	39 c5                	cmp    %eax,%ebp
  800eb1:	73 04                	jae    800eb7 <__udivdi3+0xf7>
  800eb3:	39 d6                	cmp    %edx,%esi
  800eb5:	74 09                	je     800ec0 <__udivdi3+0x100>
  800eb7:	89 d8                	mov    %ebx,%eax
  800eb9:	31 ff                	xor    %edi,%edi
  800ebb:	e9 40 ff ff ff       	jmp    800e00 <__udivdi3+0x40>
  800ec0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800ec3:	31 ff                	xor    %edi,%edi
  800ec5:	e9 36 ff ff ff       	jmp    800e00 <__udivdi3+0x40>
  800eca:	66 90                	xchg   %ax,%ax
  800ecc:	66 90                	xchg   %ax,%ax
  800ece:	66 90                	xchg   %ax,%ax

00800ed0 <__umoddi3>:
  800ed0:	f3 0f 1e fb          	endbr32 
  800ed4:	55                   	push   %ebp
  800ed5:	57                   	push   %edi
  800ed6:	56                   	push   %esi
  800ed7:	53                   	push   %ebx
  800ed8:	83 ec 1c             	sub    $0x1c,%esp
  800edb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800edf:	8b 74 24 30          	mov    0x30(%esp),%esi
  800ee3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800ee7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800eeb:	85 c0                	test   %eax,%eax
  800eed:	75 19                	jne    800f08 <__umoddi3+0x38>
  800eef:	39 df                	cmp    %ebx,%edi
  800ef1:	76 5d                	jbe    800f50 <__umoddi3+0x80>
  800ef3:	89 f0                	mov    %esi,%eax
  800ef5:	89 da                	mov    %ebx,%edx
  800ef7:	f7 f7                	div    %edi
  800ef9:	89 d0                	mov    %edx,%eax
  800efb:	31 d2                	xor    %edx,%edx
  800efd:	83 c4 1c             	add    $0x1c,%esp
  800f00:	5b                   	pop    %ebx
  800f01:	5e                   	pop    %esi
  800f02:	5f                   	pop    %edi
  800f03:	5d                   	pop    %ebp
  800f04:	c3                   	ret    
  800f05:	8d 76 00             	lea    0x0(%esi),%esi
  800f08:	89 f2                	mov    %esi,%edx
  800f0a:	39 d8                	cmp    %ebx,%eax
  800f0c:	76 12                	jbe    800f20 <__umoddi3+0x50>
  800f0e:	89 f0                	mov    %esi,%eax
  800f10:	89 da                	mov    %ebx,%edx
  800f12:	83 c4 1c             	add    $0x1c,%esp
  800f15:	5b                   	pop    %ebx
  800f16:	5e                   	pop    %esi
  800f17:	5f                   	pop    %edi
  800f18:	5d                   	pop    %ebp
  800f19:	c3                   	ret    
  800f1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f20:	0f bd e8             	bsr    %eax,%ebp
  800f23:	83 f5 1f             	xor    $0x1f,%ebp
  800f26:	75 50                	jne    800f78 <__umoddi3+0xa8>
  800f28:	39 d8                	cmp    %ebx,%eax
  800f2a:	0f 82 e0 00 00 00    	jb     801010 <__umoddi3+0x140>
  800f30:	89 d9                	mov    %ebx,%ecx
  800f32:	39 f7                	cmp    %esi,%edi
  800f34:	0f 86 d6 00 00 00    	jbe    801010 <__umoddi3+0x140>
  800f3a:	89 d0                	mov    %edx,%eax
  800f3c:	89 ca                	mov    %ecx,%edx
  800f3e:	83 c4 1c             	add    $0x1c,%esp
  800f41:	5b                   	pop    %ebx
  800f42:	5e                   	pop    %esi
  800f43:	5f                   	pop    %edi
  800f44:	5d                   	pop    %ebp
  800f45:	c3                   	ret    
  800f46:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f4d:	8d 76 00             	lea    0x0(%esi),%esi
  800f50:	89 fd                	mov    %edi,%ebp
  800f52:	85 ff                	test   %edi,%edi
  800f54:	75 0b                	jne    800f61 <__umoddi3+0x91>
  800f56:	b8 01 00 00 00       	mov    $0x1,%eax
  800f5b:	31 d2                	xor    %edx,%edx
  800f5d:	f7 f7                	div    %edi
  800f5f:	89 c5                	mov    %eax,%ebp
  800f61:	89 d8                	mov    %ebx,%eax
  800f63:	31 d2                	xor    %edx,%edx
  800f65:	f7 f5                	div    %ebp
  800f67:	89 f0                	mov    %esi,%eax
  800f69:	f7 f5                	div    %ebp
  800f6b:	89 d0                	mov    %edx,%eax
  800f6d:	31 d2                	xor    %edx,%edx
  800f6f:	eb 8c                	jmp    800efd <__umoddi3+0x2d>
  800f71:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f78:	89 e9                	mov    %ebp,%ecx
  800f7a:	ba 20 00 00 00       	mov    $0x20,%edx
  800f7f:	29 ea                	sub    %ebp,%edx
  800f81:	d3 e0                	shl    %cl,%eax
  800f83:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f87:	89 d1                	mov    %edx,%ecx
  800f89:	89 f8                	mov    %edi,%eax
  800f8b:	d3 e8                	shr    %cl,%eax
  800f8d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800f91:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f95:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f99:	09 c1                	or     %eax,%ecx
  800f9b:	89 d8                	mov    %ebx,%eax
  800f9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fa1:	89 e9                	mov    %ebp,%ecx
  800fa3:	d3 e7                	shl    %cl,%edi
  800fa5:	89 d1                	mov    %edx,%ecx
  800fa7:	d3 e8                	shr    %cl,%eax
  800fa9:	89 e9                	mov    %ebp,%ecx
  800fab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800faf:	d3 e3                	shl    %cl,%ebx
  800fb1:	89 c7                	mov    %eax,%edi
  800fb3:	89 d1                	mov    %edx,%ecx
  800fb5:	89 f0                	mov    %esi,%eax
  800fb7:	d3 e8                	shr    %cl,%eax
  800fb9:	89 e9                	mov    %ebp,%ecx
  800fbb:	89 fa                	mov    %edi,%edx
  800fbd:	d3 e6                	shl    %cl,%esi
  800fbf:	09 d8                	or     %ebx,%eax
  800fc1:	f7 74 24 08          	divl   0x8(%esp)
  800fc5:	89 d1                	mov    %edx,%ecx
  800fc7:	89 f3                	mov    %esi,%ebx
  800fc9:	f7 64 24 0c          	mull   0xc(%esp)
  800fcd:	89 c6                	mov    %eax,%esi
  800fcf:	89 d7                	mov    %edx,%edi
  800fd1:	39 d1                	cmp    %edx,%ecx
  800fd3:	72 06                	jb     800fdb <__umoddi3+0x10b>
  800fd5:	75 10                	jne    800fe7 <__umoddi3+0x117>
  800fd7:	39 c3                	cmp    %eax,%ebx
  800fd9:	73 0c                	jae    800fe7 <__umoddi3+0x117>
  800fdb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800fdf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800fe3:	89 d7                	mov    %edx,%edi
  800fe5:	89 c6                	mov    %eax,%esi
  800fe7:	89 ca                	mov    %ecx,%edx
  800fe9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fee:	29 f3                	sub    %esi,%ebx
  800ff0:	19 fa                	sbb    %edi,%edx
  800ff2:	89 d0                	mov    %edx,%eax
  800ff4:	d3 e0                	shl    %cl,%eax
  800ff6:	89 e9                	mov    %ebp,%ecx
  800ff8:	d3 eb                	shr    %cl,%ebx
  800ffa:	d3 ea                	shr    %cl,%edx
  800ffc:	09 d8                	or     %ebx,%eax
  800ffe:	83 c4 1c             	add    $0x1c,%esp
  801001:	5b                   	pop    %ebx
  801002:	5e                   	pop    %esi
  801003:	5f                   	pop    %edi
  801004:	5d                   	pop    %ebp
  801005:	c3                   	ret    
  801006:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80100d:	8d 76 00             	lea    0x0(%esi),%esi
  801010:	29 fe                	sub    %edi,%esi
  801012:	19 c3                	sbb    %eax,%ebx
  801014:	89 f2                	mov    %esi,%edx
  801016:	89 d9                	mov    %ebx,%ecx
  801018:	e9 1d ff ff ff       	jmp    800f3a <__umoddi3+0x6a>
