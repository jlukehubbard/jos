
obj/user/faultreadkernel:     file format elf32-i386


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
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  80003d:	ff 35 00 00 10 f0    	pushl  0xf0100000
  800043:	68 60 10 80 00       	push   $0x801060
  800048:	e8 0c 01 00 00       	call   800159 <cprintf>
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
  800061:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800068:	00 00 00 
    envid_t envid = sys_getenvid();
  80006b:	e8 ee 0a 00 00       	call   800b5e <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 db                	test   %ebx,%ebx
  800084:	7e 07                	jle    80008d <libmain+0x3b>
		binaryname = argv[0];
  800086:	8b 06                	mov    (%esi),%eax
  800088:	a3 00 20 80 00       	mov    %eax,0x802000

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
  8000ad:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  8000b0:	6a 00                	push   $0x0
  8000b2:	e8 62 0a 00 00       	call   800b19 <sys_env_destroy>
}
  8000b7:	83 c4 10             	add    $0x10,%esp
  8000ba:	c9                   	leave  
  8000bb:	c3                   	ret    

008000bc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000bc:	f3 0f 1e fb          	endbr32 
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	53                   	push   %ebx
  8000c4:	83 ec 04             	sub    $0x4,%esp
  8000c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ca:	8b 13                	mov    (%ebx),%edx
  8000cc:	8d 42 01             	lea    0x1(%edx),%eax
  8000cf:	89 03                	mov    %eax,(%ebx)
  8000d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000dd:	74 09                	je     8000e8 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000df:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e6:	c9                   	leave  
  8000e7:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000e8:	83 ec 08             	sub    $0x8,%esp
  8000eb:	68 ff 00 00 00       	push   $0xff
  8000f0:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f3:	50                   	push   %eax
  8000f4:	e8 db 09 00 00       	call   800ad4 <sys_cputs>
		b->idx = 0;
  8000f9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000ff:	83 c4 10             	add    $0x10,%esp
  800102:	eb db                	jmp    8000df <putch+0x23>

00800104 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800104:	f3 0f 1e fb          	endbr32 
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800111:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800118:	00 00 00 
	b.cnt = 0;
  80011b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800122:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800125:	ff 75 0c             	pushl  0xc(%ebp)
  800128:	ff 75 08             	pushl  0x8(%ebp)
  80012b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800131:	50                   	push   %eax
  800132:	68 bc 00 80 00       	push   $0x8000bc
  800137:	e8 20 01 00 00       	call   80025c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80013c:	83 c4 08             	add    $0x8,%esp
  80013f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800145:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80014b:	50                   	push   %eax
  80014c:	e8 83 09 00 00       	call   800ad4 <sys_cputs>

	return b.cnt;
}
  800151:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800157:	c9                   	leave  
  800158:	c3                   	ret    

00800159 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800159:	f3 0f 1e fb          	endbr32 
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800163:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800166:	50                   	push   %eax
  800167:	ff 75 08             	pushl  0x8(%ebp)
  80016a:	e8 95 ff ff ff       	call   800104 <vcprintf>
	va_end(ap);

	return cnt;
}
  80016f:	c9                   	leave  
  800170:	c3                   	ret    

00800171 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800171:	55                   	push   %ebp
  800172:	89 e5                	mov    %esp,%ebp
  800174:	57                   	push   %edi
  800175:	56                   	push   %esi
  800176:	53                   	push   %ebx
  800177:	83 ec 1c             	sub    $0x1c,%esp
  80017a:	89 c7                	mov    %eax,%edi
  80017c:	89 d6                	mov    %edx,%esi
  80017e:	8b 45 08             	mov    0x8(%ebp),%eax
  800181:	8b 55 0c             	mov    0xc(%ebp),%edx
  800184:	89 d1                	mov    %edx,%ecx
  800186:	89 c2                	mov    %eax,%edx
  800188:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80018b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80018e:	8b 45 10             	mov    0x10(%ebp),%eax
  800191:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800194:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800197:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80019e:	39 c2                	cmp    %eax,%edx
  8001a0:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001a3:	72 3e                	jb     8001e3 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001a5:	83 ec 0c             	sub    $0xc,%esp
  8001a8:	ff 75 18             	pushl  0x18(%ebp)
  8001ab:	83 eb 01             	sub    $0x1,%ebx
  8001ae:	53                   	push   %ebx
  8001af:	50                   	push   %eax
  8001b0:	83 ec 08             	sub    $0x8,%esp
  8001b3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001b6:	ff 75 e0             	pushl  -0x20(%ebp)
  8001b9:	ff 75 dc             	pushl  -0x24(%ebp)
  8001bc:	ff 75 d8             	pushl  -0x28(%ebp)
  8001bf:	e8 3c 0c 00 00       	call   800e00 <__udivdi3>
  8001c4:	83 c4 18             	add    $0x18,%esp
  8001c7:	52                   	push   %edx
  8001c8:	50                   	push   %eax
  8001c9:	89 f2                	mov    %esi,%edx
  8001cb:	89 f8                	mov    %edi,%eax
  8001cd:	e8 9f ff ff ff       	call   800171 <printnum>
  8001d2:	83 c4 20             	add    $0x20,%esp
  8001d5:	eb 13                	jmp    8001ea <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001d7:	83 ec 08             	sub    $0x8,%esp
  8001da:	56                   	push   %esi
  8001db:	ff 75 18             	pushl  0x18(%ebp)
  8001de:	ff d7                	call   *%edi
  8001e0:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001e3:	83 eb 01             	sub    $0x1,%ebx
  8001e6:	85 db                	test   %ebx,%ebx
  8001e8:	7f ed                	jg     8001d7 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001ea:	83 ec 08             	sub    $0x8,%esp
  8001ed:	56                   	push   %esi
  8001ee:	83 ec 04             	sub    $0x4,%esp
  8001f1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f4:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f7:	ff 75 dc             	pushl  -0x24(%ebp)
  8001fa:	ff 75 d8             	pushl  -0x28(%ebp)
  8001fd:	e8 0e 0d 00 00       	call   800f10 <__umoddi3>
  800202:	83 c4 14             	add    $0x14,%esp
  800205:	0f be 80 91 10 80 00 	movsbl 0x801091(%eax),%eax
  80020c:	50                   	push   %eax
  80020d:	ff d7                	call   *%edi
}
  80020f:	83 c4 10             	add    $0x10,%esp
  800212:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800215:	5b                   	pop    %ebx
  800216:	5e                   	pop    %esi
  800217:	5f                   	pop    %edi
  800218:	5d                   	pop    %ebp
  800219:	c3                   	ret    

0080021a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80021a:	f3 0f 1e fb          	endbr32 
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800224:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800228:	8b 10                	mov    (%eax),%edx
  80022a:	3b 50 04             	cmp    0x4(%eax),%edx
  80022d:	73 0a                	jae    800239 <sprintputch+0x1f>
		*b->buf++ = ch;
  80022f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800232:	89 08                	mov    %ecx,(%eax)
  800234:	8b 45 08             	mov    0x8(%ebp),%eax
  800237:	88 02                	mov    %al,(%edx)
}
  800239:	5d                   	pop    %ebp
  80023a:	c3                   	ret    

0080023b <printfmt>:
{
  80023b:	f3 0f 1e fb          	endbr32 
  80023f:	55                   	push   %ebp
  800240:	89 e5                	mov    %esp,%ebp
  800242:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800245:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800248:	50                   	push   %eax
  800249:	ff 75 10             	pushl  0x10(%ebp)
  80024c:	ff 75 0c             	pushl  0xc(%ebp)
  80024f:	ff 75 08             	pushl  0x8(%ebp)
  800252:	e8 05 00 00 00       	call   80025c <vprintfmt>
}
  800257:	83 c4 10             	add    $0x10,%esp
  80025a:	c9                   	leave  
  80025b:	c3                   	ret    

0080025c <vprintfmt>:
{
  80025c:	f3 0f 1e fb          	endbr32 
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	57                   	push   %edi
  800264:	56                   	push   %esi
  800265:	53                   	push   %ebx
  800266:	83 ec 3c             	sub    $0x3c,%esp
  800269:	8b 75 08             	mov    0x8(%ebp),%esi
  80026c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80026f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800272:	e9 4a 03 00 00       	jmp    8005c1 <vprintfmt+0x365>
		padc = ' ';
  800277:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80027b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800282:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800289:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800290:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800295:	8d 47 01             	lea    0x1(%edi),%eax
  800298:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80029b:	0f b6 17             	movzbl (%edi),%edx
  80029e:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002a1:	3c 55                	cmp    $0x55,%al
  8002a3:	0f 87 de 03 00 00    	ja     800687 <vprintfmt+0x42b>
  8002a9:	0f b6 c0             	movzbl %al,%eax
  8002ac:	3e ff 24 85 e0 11 80 	notrack jmp *0x8011e0(,%eax,4)
  8002b3:	00 
  8002b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002b7:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002bb:	eb d8                	jmp    800295 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8002bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002c0:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002c4:	eb cf                	jmp    800295 <vprintfmt+0x39>
  8002c6:	0f b6 d2             	movzbl %dl,%edx
  8002c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8002d1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002d4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002d7:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002db:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002de:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002e1:	83 f9 09             	cmp    $0x9,%ecx
  8002e4:	77 55                	ja     80033b <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8002e6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002e9:	eb e9                	jmp    8002d4 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8002eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ee:	8b 00                	mov    (%eax),%eax
  8002f0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f6:	8d 40 04             	lea    0x4(%eax),%eax
  8002f9:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8002ff:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800303:	79 90                	jns    800295 <vprintfmt+0x39>
				width = precision, precision = -1;
  800305:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800308:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80030b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800312:	eb 81                	jmp    800295 <vprintfmt+0x39>
  800314:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800317:	85 c0                	test   %eax,%eax
  800319:	ba 00 00 00 00       	mov    $0x0,%edx
  80031e:	0f 49 d0             	cmovns %eax,%edx
  800321:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800324:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800327:	e9 69 ff ff ff       	jmp    800295 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80032c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80032f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800336:	e9 5a ff ff ff       	jmp    800295 <vprintfmt+0x39>
  80033b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80033e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800341:	eb bc                	jmp    8002ff <vprintfmt+0xa3>
			lflag++;
  800343:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800346:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800349:	e9 47 ff ff ff       	jmp    800295 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80034e:	8b 45 14             	mov    0x14(%ebp),%eax
  800351:	8d 78 04             	lea    0x4(%eax),%edi
  800354:	83 ec 08             	sub    $0x8,%esp
  800357:	53                   	push   %ebx
  800358:	ff 30                	pushl  (%eax)
  80035a:	ff d6                	call   *%esi
			break;
  80035c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80035f:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800362:	e9 57 02 00 00       	jmp    8005be <vprintfmt+0x362>
			err = va_arg(ap, int);
  800367:	8b 45 14             	mov    0x14(%ebp),%eax
  80036a:	8d 78 04             	lea    0x4(%eax),%edi
  80036d:	8b 00                	mov    (%eax),%eax
  80036f:	99                   	cltd   
  800370:	31 d0                	xor    %edx,%eax
  800372:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800374:	83 f8 0f             	cmp    $0xf,%eax
  800377:	7f 23                	jg     80039c <vprintfmt+0x140>
  800379:	8b 14 85 40 13 80 00 	mov    0x801340(,%eax,4),%edx
  800380:	85 d2                	test   %edx,%edx
  800382:	74 18                	je     80039c <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800384:	52                   	push   %edx
  800385:	68 b2 10 80 00       	push   $0x8010b2
  80038a:	53                   	push   %ebx
  80038b:	56                   	push   %esi
  80038c:	e8 aa fe ff ff       	call   80023b <printfmt>
  800391:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800394:	89 7d 14             	mov    %edi,0x14(%ebp)
  800397:	e9 22 02 00 00       	jmp    8005be <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  80039c:	50                   	push   %eax
  80039d:	68 a9 10 80 00       	push   $0x8010a9
  8003a2:	53                   	push   %ebx
  8003a3:	56                   	push   %esi
  8003a4:	e8 92 fe ff ff       	call   80023b <printfmt>
  8003a9:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003ac:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003af:	e9 0a 02 00 00       	jmp    8005be <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8003b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b7:	83 c0 04             	add    $0x4,%eax
  8003ba:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c0:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003c2:	85 d2                	test   %edx,%edx
  8003c4:	b8 a2 10 80 00       	mov    $0x8010a2,%eax
  8003c9:	0f 45 c2             	cmovne %edx,%eax
  8003cc:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003cf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d3:	7e 06                	jle    8003db <vprintfmt+0x17f>
  8003d5:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8003d9:	75 0d                	jne    8003e8 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003db:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003de:	89 c7                	mov    %eax,%edi
  8003e0:	03 45 e0             	add    -0x20(%ebp),%eax
  8003e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e6:	eb 55                	jmp    80043d <vprintfmt+0x1e1>
  8003e8:	83 ec 08             	sub    $0x8,%esp
  8003eb:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ee:	ff 75 cc             	pushl  -0x34(%ebp)
  8003f1:	e8 45 03 00 00       	call   80073b <strnlen>
  8003f6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003f9:	29 c2                	sub    %eax,%edx
  8003fb:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8003fe:	83 c4 10             	add    $0x10,%esp
  800401:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800403:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800407:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80040a:	85 ff                	test   %edi,%edi
  80040c:	7e 11                	jle    80041f <vprintfmt+0x1c3>
					putch(padc, putdat);
  80040e:	83 ec 08             	sub    $0x8,%esp
  800411:	53                   	push   %ebx
  800412:	ff 75 e0             	pushl  -0x20(%ebp)
  800415:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800417:	83 ef 01             	sub    $0x1,%edi
  80041a:	83 c4 10             	add    $0x10,%esp
  80041d:	eb eb                	jmp    80040a <vprintfmt+0x1ae>
  80041f:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800422:	85 d2                	test   %edx,%edx
  800424:	b8 00 00 00 00       	mov    $0x0,%eax
  800429:	0f 49 c2             	cmovns %edx,%eax
  80042c:	29 c2                	sub    %eax,%edx
  80042e:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800431:	eb a8                	jmp    8003db <vprintfmt+0x17f>
					putch(ch, putdat);
  800433:	83 ec 08             	sub    $0x8,%esp
  800436:	53                   	push   %ebx
  800437:	52                   	push   %edx
  800438:	ff d6                	call   *%esi
  80043a:	83 c4 10             	add    $0x10,%esp
  80043d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800440:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800442:	83 c7 01             	add    $0x1,%edi
  800445:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800449:	0f be d0             	movsbl %al,%edx
  80044c:	85 d2                	test   %edx,%edx
  80044e:	74 4b                	je     80049b <vprintfmt+0x23f>
  800450:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800454:	78 06                	js     80045c <vprintfmt+0x200>
  800456:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80045a:	78 1e                	js     80047a <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80045c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800460:	74 d1                	je     800433 <vprintfmt+0x1d7>
  800462:	0f be c0             	movsbl %al,%eax
  800465:	83 e8 20             	sub    $0x20,%eax
  800468:	83 f8 5e             	cmp    $0x5e,%eax
  80046b:	76 c6                	jbe    800433 <vprintfmt+0x1d7>
					putch('?', putdat);
  80046d:	83 ec 08             	sub    $0x8,%esp
  800470:	53                   	push   %ebx
  800471:	6a 3f                	push   $0x3f
  800473:	ff d6                	call   *%esi
  800475:	83 c4 10             	add    $0x10,%esp
  800478:	eb c3                	jmp    80043d <vprintfmt+0x1e1>
  80047a:	89 cf                	mov    %ecx,%edi
  80047c:	eb 0e                	jmp    80048c <vprintfmt+0x230>
				putch(' ', putdat);
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	53                   	push   %ebx
  800482:	6a 20                	push   $0x20
  800484:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800486:	83 ef 01             	sub    $0x1,%edi
  800489:	83 c4 10             	add    $0x10,%esp
  80048c:	85 ff                	test   %edi,%edi
  80048e:	7f ee                	jg     80047e <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800490:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800493:	89 45 14             	mov    %eax,0x14(%ebp)
  800496:	e9 23 01 00 00       	jmp    8005be <vprintfmt+0x362>
  80049b:	89 cf                	mov    %ecx,%edi
  80049d:	eb ed                	jmp    80048c <vprintfmt+0x230>
	if (lflag >= 2)
  80049f:	83 f9 01             	cmp    $0x1,%ecx
  8004a2:	7f 1b                	jg     8004bf <vprintfmt+0x263>
	else if (lflag)
  8004a4:	85 c9                	test   %ecx,%ecx
  8004a6:	74 63                	je     80050b <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8004a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ab:	8b 00                	mov    (%eax),%eax
  8004ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004b0:	99                   	cltd   
  8004b1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b7:	8d 40 04             	lea    0x4(%eax),%eax
  8004ba:	89 45 14             	mov    %eax,0x14(%ebp)
  8004bd:	eb 17                	jmp    8004d6 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8004bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c2:	8b 50 04             	mov    0x4(%eax),%edx
  8004c5:	8b 00                	mov    (%eax),%eax
  8004c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004ca:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d0:	8d 40 08             	lea    0x8(%eax),%eax
  8004d3:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004d6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004d9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8004dc:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8004e1:	85 c9                	test   %ecx,%ecx
  8004e3:	0f 89 bb 00 00 00    	jns    8005a4 <vprintfmt+0x348>
				putch('-', putdat);
  8004e9:	83 ec 08             	sub    $0x8,%esp
  8004ec:	53                   	push   %ebx
  8004ed:	6a 2d                	push   $0x2d
  8004ef:	ff d6                	call   *%esi
				num = -(long long) num;
  8004f1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004f4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004f7:	f7 da                	neg    %edx
  8004f9:	83 d1 00             	adc    $0x0,%ecx
  8004fc:	f7 d9                	neg    %ecx
  8004fe:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800501:	b8 0a 00 00 00       	mov    $0xa,%eax
  800506:	e9 99 00 00 00       	jmp    8005a4 <vprintfmt+0x348>
		return va_arg(*ap, int);
  80050b:	8b 45 14             	mov    0x14(%ebp),%eax
  80050e:	8b 00                	mov    (%eax),%eax
  800510:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800513:	99                   	cltd   
  800514:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800517:	8b 45 14             	mov    0x14(%ebp),%eax
  80051a:	8d 40 04             	lea    0x4(%eax),%eax
  80051d:	89 45 14             	mov    %eax,0x14(%ebp)
  800520:	eb b4                	jmp    8004d6 <vprintfmt+0x27a>
	if (lflag >= 2)
  800522:	83 f9 01             	cmp    $0x1,%ecx
  800525:	7f 1b                	jg     800542 <vprintfmt+0x2e6>
	else if (lflag)
  800527:	85 c9                	test   %ecx,%ecx
  800529:	74 2c                	je     800557 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  80052b:	8b 45 14             	mov    0x14(%ebp),%eax
  80052e:	8b 10                	mov    (%eax),%edx
  800530:	b9 00 00 00 00       	mov    $0x0,%ecx
  800535:	8d 40 04             	lea    0x4(%eax),%eax
  800538:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80053b:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800540:	eb 62                	jmp    8005a4 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800542:	8b 45 14             	mov    0x14(%ebp),%eax
  800545:	8b 10                	mov    (%eax),%edx
  800547:	8b 48 04             	mov    0x4(%eax),%ecx
  80054a:	8d 40 08             	lea    0x8(%eax),%eax
  80054d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800550:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800555:	eb 4d                	jmp    8005a4 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800557:	8b 45 14             	mov    0x14(%ebp),%eax
  80055a:	8b 10                	mov    (%eax),%edx
  80055c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800561:	8d 40 04             	lea    0x4(%eax),%eax
  800564:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800567:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80056c:	eb 36                	jmp    8005a4 <vprintfmt+0x348>
	if (lflag >= 2)
  80056e:	83 f9 01             	cmp    $0x1,%ecx
  800571:	7f 17                	jg     80058a <vprintfmt+0x32e>
	else if (lflag)
  800573:	85 c9                	test   %ecx,%ecx
  800575:	74 6e                	je     8005e5 <vprintfmt+0x389>
		return va_arg(*ap, long);
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8b 10                	mov    (%eax),%edx
  80057c:	89 d0                	mov    %edx,%eax
  80057e:	99                   	cltd   
  80057f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800582:	8d 49 04             	lea    0x4(%ecx),%ecx
  800585:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800588:	eb 11                	jmp    80059b <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  80058a:	8b 45 14             	mov    0x14(%ebp),%eax
  80058d:	8b 50 04             	mov    0x4(%eax),%edx
  800590:	8b 00                	mov    (%eax),%eax
  800592:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800595:	8d 49 08             	lea    0x8(%ecx),%ecx
  800598:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  80059b:	89 d1                	mov    %edx,%ecx
  80059d:	89 c2                	mov    %eax,%edx
            base = 8;
  80059f:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005a4:	83 ec 0c             	sub    $0xc,%esp
  8005a7:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005ab:	57                   	push   %edi
  8005ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8005af:	50                   	push   %eax
  8005b0:	51                   	push   %ecx
  8005b1:	52                   	push   %edx
  8005b2:	89 da                	mov    %ebx,%edx
  8005b4:	89 f0                	mov    %esi,%eax
  8005b6:	e8 b6 fb ff ff       	call   800171 <printnum>
			break;
  8005bb:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8005be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005c1:	83 c7 01             	add    $0x1,%edi
  8005c4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005c8:	83 f8 25             	cmp    $0x25,%eax
  8005cb:	0f 84 a6 fc ff ff    	je     800277 <vprintfmt+0x1b>
			if (ch == '\0')
  8005d1:	85 c0                	test   %eax,%eax
  8005d3:	0f 84 ce 00 00 00    	je     8006a7 <vprintfmt+0x44b>
			putch(ch, putdat);
  8005d9:	83 ec 08             	sub    $0x8,%esp
  8005dc:	53                   	push   %ebx
  8005dd:	50                   	push   %eax
  8005de:	ff d6                	call   *%esi
  8005e0:	83 c4 10             	add    $0x10,%esp
  8005e3:	eb dc                	jmp    8005c1 <vprintfmt+0x365>
		return va_arg(*ap, int);
  8005e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e8:	8b 10                	mov    (%eax),%edx
  8005ea:	89 d0                	mov    %edx,%eax
  8005ec:	99                   	cltd   
  8005ed:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005f0:	8d 49 04             	lea    0x4(%ecx),%ecx
  8005f3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005f6:	eb a3                	jmp    80059b <vprintfmt+0x33f>
			putch('0', putdat);
  8005f8:	83 ec 08             	sub    $0x8,%esp
  8005fb:	53                   	push   %ebx
  8005fc:	6a 30                	push   $0x30
  8005fe:	ff d6                	call   *%esi
			putch('x', putdat);
  800600:	83 c4 08             	add    $0x8,%esp
  800603:	53                   	push   %ebx
  800604:	6a 78                	push   $0x78
  800606:	ff d6                	call   *%esi
			num = (unsigned long long)
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8b 10                	mov    (%eax),%edx
  80060d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800612:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800615:	8d 40 04             	lea    0x4(%eax),%eax
  800618:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80061b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800620:	eb 82                	jmp    8005a4 <vprintfmt+0x348>
	if (lflag >= 2)
  800622:	83 f9 01             	cmp    $0x1,%ecx
  800625:	7f 1e                	jg     800645 <vprintfmt+0x3e9>
	else if (lflag)
  800627:	85 c9                	test   %ecx,%ecx
  800629:	74 32                	je     80065d <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  80062b:	8b 45 14             	mov    0x14(%ebp),%eax
  80062e:	8b 10                	mov    (%eax),%edx
  800630:	b9 00 00 00 00       	mov    $0x0,%ecx
  800635:	8d 40 04             	lea    0x4(%eax),%eax
  800638:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80063b:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800640:	e9 5f ff ff ff       	jmp    8005a4 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800645:	8b 45 14             	mov    0x14(%ebp),%eax
  800648:	8b 10                	mov    (%eax),%edx
  80064a:	8b 48 04             	mov    0x4(%eax),%ecx
  80064d:	8d 40 08             	lea    0x8(%eax),%eax
  800650:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800653:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800658:	e9 47 ff ff ff       	jmp    8005a4 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80065d:	8b 45 14             	mov    0x14(%ebp),%eax
  800660:	8b 10                	mov    (%eax),%edx
  800662:	b9 00 00 00 00       	mov    $0x0,%ecx
  800667:	8d 40 04             	lea    0x4(%eax),%eax
  80066a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80066d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800672:	e9 2d ff ff ff       	jmp    8005a4 <vprintfmt+0x348>
			putch(ch, putdat);
  800677:	83 ec 08             	sub    $0x8,%esp
  80067a:	53                   	push   %ebx
  80067b:	6a 25                	push   $0x25
  80067d:	ff d6                	call   *%esi
			break;
  80067f:	83 c4 10             	add    $0x10,%esp
  800682:	e9 37 ff ff ff       	jmp    8005be <vprintfmt+0x362>
			putch('%', putdat);
  800687:	83 ec 08             	sub    $0x8,%esp
  80068a:	53                   	push   %ebx
  80068b:	6a 25                	push   $0x25
  80068d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80068f:	83 c4 10             	add    $0x10,%esp
  800692:	89 f8                	mov    %edi,%eax
  800694:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800698:	74 05                	je     80069f <vprintfmt+0x443>
  80069a:	83 e8 01             	sub    $0x1,%eax
  80069d:	eb f5                	jmp    800694 <vprintfmt+0x438>
  80069f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006a2:	e9 17 ff ff ff       	jmp    8005be <vprintfmt+0x362>
}
  8006a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006aa:	5b                   	pop    %ebx
  8006ab:	5e                   	pop    %esi
  8006ac:	5f                   	pop    %edi
  8006ad:	5d                   	pop    %ebp
  8006ae:	c3                   	ret    

008006af <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006af:	f3 0f 1e fb          	endbr32 
  8006b3:	55                   	push   %ebp
  8006b4:	89 e5                	mov    %esp,%ebp
  8006b6:	83 ec 18             	sub    $0x18,%esp
  8006b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d0:	85 c0                	test   %eax,%eax
  8006d2:	74 26                	je     8006fa <vsnprintf+0x4b>
  8006d4:	85 d2                	test   %edx,%edx
  8006d6:	7e 22                	jle    8006fa <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006d8:	ff 75 14             	pushl  0x14(%ebp)
  8006db:	ff 75 10             	pushl  0x10(%ebp)
  8006de:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e1:	50                   	push   %eax
  8006e2:	68 1a 02 80 00       	push   $0x80021a
  8006e7:	e8 70 fb ff ff       	call   80025c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ef:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f5:	83 c4 10             	add    $0x10,%esp
}
  8006f8:	c9                   	leave  
  8006f9:	c3                   	ret    
		return -E_INVAL;
  8006fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006ff:	eb f7                	jmp    8006f8 <vsnprintf+0x49>

00800701 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800701:	f3 0f 1e fb          	endbr32 
  800705:	55                   	push   %ebp
  800706:	89 e5                	mov    %esp,%ebp
  800708:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80070b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80070e:	50                   	push   %eax
  80070f:	ff 75 10             	pushl  0x10(%ebp)
  800712:	ff 75 0c             	pushl  0xc(%ebp)
  800715:	ff 75 08             	pushl  0x8(%ebp)
  800718:	e8 92 ff ff ff       	call   8006af <vsnprintf>
	va_end(ap);

	return rc;
}
  80071d:	c9                   	leave  
  80071e:	c3                   	ret    

0080071f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80071f:	f3 0f 1e fb          	endbr32 
  800723:	55                   	push   %ebp
  800724:	89 e5                	mov    %esp,%ebp
  800726:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800729:	b8 00 00 00 00       	mov    $0x0,%eax
  80072e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800732:	74 05                	je     800739 <strlen+0x1a>
		n++;
  800734:	83 c0 01             	add    $0x1,%eax
  800737:	eb f5                	jmp    80072e <strlen+0xf>
	return n;
}
  800739:	5d                   	pop    %ebp
  80073a:	c3                   	ret    

0080073b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80073b:	f3 0f 1e fb          	endbr32 
  80073f:	55                   	push   %ebp
  800740:	89 e5                	mov    %esp,%ebp
  800742:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800745:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800748:	b8 00 00 00 00       	mov    $0x0,%eax
  80074d:	39 d0                	cmp    %edx,%eax
  80074f:	74 0d                	je     80075e <strnlen+0x23>
  800751:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800755:	74 05                	je     80075c <strnlen+0x21>
		n++;
  800757:	83 c0 01             	add    $0x1,%eax
  80075a:	eb f1                	jmp    80074d <strnlen+0x12>
  80075c:	89 c2                	mov    %eax,%edx
	return n;
}
  80075e:	89 d0                	mov    %edx,%eax
  800760:	5d                   	pop    %ebp
  800761:	c3                   	ret    

00800762 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800762:	f3 0f 1e fb          	endbr32 
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	53                   	push   %ebx
  80076a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80076d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800770:	b8 00 00 00 00       	mov    $0x0,%eax
  800775:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800779:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80077c:	83 c0 01             	add    $0x1,%eax
  80077f:	84 d2                	test   %dl,%dl
  800781:	75 f2                	jne    800775 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800783:	89 c8                	mov    %ecx,%eax
  800785:	5b                   	pop    %ebx
  800786:	5d                   	pop    %ebp
  800787:	c3                   	ret    

00800788 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800788:	f3 0f 1e fb          	endbr32 
  80078c:	55                   	push   %ebp
  80078d:	89 e5                	mov    %esp,%ebp
  80078f:	53                   	push   %ebx
  800790:	83 ec 10             	sub    $0x10,%esp
  800793:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800796:	53                   	push   %ebx
  800797:	e8 83 ff ff ff       	call   80071f <strlen>
  80079c:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80079f:	ff 75 0c             	pushl  0xc(%ebp)
  8007a2:	01 d8                	add    %ebx,%eax
  8007a4:	50                   	push   %eax
  8007a5:	e8 b8 ff ff ff       	call   800762 <strcpy>
	return dst;
}
  8007aa:	89 d8                	mov    %ebx,%eax
  8007ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007af:	c9                   	leave  
  8007b0:	c3                   	ret    

008007b1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b1:	f3 0f 1e fb          	endbr32 
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	56                   	push   %esi
  8007b9:	53                   	push   %ebx
  8007ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c0:	89 f3                	mov    %esi,%ebx
  8007c2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c5:	89 f0                	mov    %esi,%eax
  8007c7:	39 d8                	cmp    %ebx,%eax
  8007c9:	74 11                	je     8007dc <strncpy+0x2b>
		*dst++ = *src;
  8007cb:	83 c0 01             	add    $0x1,%eax
  8007ce:	0f b6 0a             	movzbl (%edx),%ecx
  8007d1:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d4:	80 f9 01             	cmp    $0x1,%cl
  8007d7:	83 da ff             	sbb    $0xffffffff,%edx
  8007da:	eb eb                	jmp    8007c7 <strncpy+0x16>
	}
	return ret;
}
  8007dc:	89 f0                	mov    %esi,%eax
  8007de:	5b                   	pop    %ebx
  8007df:	5e                   	pop    %esi
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e2:	f3 0f 1e fb          	endbr32 
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	56                   	push   %esi
  8007ea:	53                   	push   %ebx
  8007eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f1:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f6:	85 d2                	test   %edx,%edx
  8007f8:	74 21                	je     80081b <strlcpy+0x39>
  8007fa:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007fe:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800800:	39 c2                	cmp    %eax,%edx
  800802:	74 14                	je     800818 <strlcpy+0x36>
  800804:	0f b6 19             	movzbl (%ecx),%ebx
  800807:	84 db                	test   %bl,%bl
  800809:	74 0b                	je     800816 <strlcpy+0x34>
			*dst++ = *src++;
  80080b:	83 c1 01             	add    $0x1,%ecx
  80080e:	83 c2 01             	add    $0x1,%edx
  800811:	88 5a ff             	mov    %bl,-0x1(%edx)
  800814:	eb ea                	jmp    800800 <strlcpy+0x1e>
  800816:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800818:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80081b:	29 f0                	sub    %esi,%eax
}
  80081d:	5b                   	pop    %ebx
  80081e:	5e                   	pop    %esi
  80081f:	5d                   	pop    %ebp
  800820:	c3                   	ret    

00800821 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800821:	f3 0f 1e fb          	endbr32 
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80082e:	0f b6 01             	movzbl (%ecx),%eax
  800831:	84 c0                	test   %al,%al
  800833:	74 0c                	je     800841 <strcmp+0x20>
  800835:	3a 02                	cmp    (%edx),%al
  800837:	75 08                	jne    800841 <strcmp+0x20>
		p++, q++;
  800839:	83 c1 01             	add    $0x1,%ecx
  80083c:	83 c2 01             	add    $0x1,%edx
  80083f:	eb ed                	jmp    80082e <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800841:	0f b6 c0             	movzbl %al,%eax
  800844:	0f b6 12             	movzbl (%edx),%edx
  800847:	29 d0                	sub    %edx,%eax
}
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80084b:	f3 0f 1e fb          	endbr32 
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	53                   	push   %ebx
  800853:	8b 45 08             	mov    0x8(%ebp),%eax
  800856:	8b 55 0c             	mov    0xc(%ebp),%edx
  800859:	89 c3                	mov    %eax,%ebx
  80085b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80085e:	eb 06                	jmp    800866 <strncmp+0x1b>
		n--, p++, q++;
  800860:	83 c0 01             	add    $0x1,%eax
  800863:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800866:	39 d8                	cmp    %ebx,%eax
  800868:	74 16                	je     800880 <strncmp+0x35>
  80086a:	0f b6 08             	movzbl (%eax),%ecx
  80086d:	84 c9                	test   %cl,%cl
  80086f:	74 04                	je     800875 <strncmp+0x2a>
  800871:	3a 0a                	cmp    (%edx),%cl
  800873:	74 eb                	je     800860 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800875:	0f b6 00             	movzbl (%eax),%eax
  800878:	0f b6 12             	movzbl (%edx),%edx
  80087b:	29 d0                	sub    %edx,%eax
}
  80087d:	5b                   	pop    %ebx
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    
		return 0;
  800880:	b8 00 00 00 00       	mov    $0x0,%eax
  800885:	eb f6                	jmp    80087d <strncmp+0x32>

00800887 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800887:	f3 0f 1e fb          	endbr32 
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	8b 45 08             	mov    0x8(%ebp),%eax
  800891:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800895:	0f b6 10             	movzbl (%eax),%edx
  800898:	84 d2                	test   %dl,%dl
  80089a:	74 09                	je     8008a5 <strchr+0x1e>
		if (*s == c)
  80089c:	38 ca                	cmp    %cl,%dl
  80089e:	74 0a                	je     8008aa <strchr+0x23>
	for (; *s; s++)
  8008a0:	83 c0 01             	add    $0x1,%eax
  8008a3:	eb f0                	jmp    800895 <strchr+0xe>
			return (char *) s;
	return 0;
  8008a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    

008008ac <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ac:	f3 0f 1e fb          	endbr32 
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ba:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008bd:	38 ca                	cmp    %cl,%dl
  8008bf:	74 09                	je     8008ca <strfind+0x1e>
  8008c1:	84 d2                	test   %dl,%dl
  8008c3:	74 05                	je     8008ca <strfind+0x1e>
	for (; *s; s++)
  8008c5:	83 c0 01             	add    $0x1,%eax
  8008c8:	eb f0                	jmp    8008ba <strfind+0xe>
			break;
	return (char *) s;
}
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008cc:	f3 0f 1e fb          	endbr32 
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	57                   	push   %edi
  8008d4:	56                   	push   %esi
  8008d5:	53                   	push   %ebx
  8008d6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008dc:	85 c9                	test   %ecx,%ecx
  8008de:	74 31                	je     800911 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e0:	89 f8                	mov    %edi,%eax
  8008e2:	09 c8                	or     %ecx,%eax
  8008e4:	a8 03                	test   $0x3,%al
  8008e6:	75 23                	jne    80090b <memset+0x3f>
		c &= 0xFF;
  8008e8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ec:	89 d3                	mov    %edx,%ebx
  8008ee:	c1 e3 08             	shl    $0x8,%ebx
  8008f1:	89 d0                	mov    %edx,%eax
  8008f3:	c1 e0 18             	shl    $0x18,%eax
  8008f6:	89 d6                	mov    %edx,%esi
  8008f8:	c1 e6 10             	shl    $0x10,%esi
  8008fb:	09 f0                	or     %esi,%eax
  8008fd:	09 c2                	or     %eax,%edx
  8008ff:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800901:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800904:	89 d0                	mov    %edx,%eax
  800906:	fc                   	cld    
  800907:	f3 ab                	rep stos %eax,%es:(%edi)
  800909:	eb 06                	jmp    800911 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80090b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090e:	fc                   	cld    
  80090f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800911:	89 f8                	mov    %edi,%eax
  800913:	5b                   	pop    %ebx
  800914:	5e                   	pop    %esi
  800915:	5f                   	pop    %edi
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    

00800918 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800918:	f3 0f 1e fb          	endbr32 
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	57                   	push   %edi
  800920:	56                   	push   %esi
  800921:	8b 45 08             	mov    0x8(%ebp),%eax
  800924:	8b 75 0c             	mov    0xc(%ebp),%esi
  800927:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80092a:	39 c6                	cmp    %eax,%esi
  80092c:	73 32                	jae    800960 <memmove+0x48>
  80092e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800931:	39 c2                	cmp    %eax,%edx
  800933:	76 2b                	jbe    800960 <memmove+0x48>
		s += n;
		d += n;
  800935:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800938:	89 fe                	mov    %edi,%esi
  80093a:	09 ce                	or     %ecx,%esi
  80093c:	09 d6                	or     %edx,%esi
  80093e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800944:	75 0e                	jne    800954 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800946:	83 ef 04             	sub    $0x4,%edi
  800949:	8d 72 fc             	lea    -0x4(%edx),%esi
  80094c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80094f:	fd                   	std    
  800950:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800952:	eb 09                	jmp    80095d <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800954:	83 ef 01             	sub    $0x1,%edi
  800957:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80095a:	fd                   	std    
  80095b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80095d:	fc                   	cld    
  80095e:	eb 1a                	jmp    80097a <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800960:	89 c2                	mov    %eax,%edx
  800962:	09 ca                	or     %ecx,%edx
  800964:	09 f2                	or     %esi,%edx
  800966:	f6 c2 03             	test   $0x3,%dl
  800969:	75 0a                	jne    800975 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80096b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80096e:	89 c7                	mov    %eax,%edi
  800970:	fc                   	cld    
  800971:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800973:	eb 05                	jmp    80097a <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800975:	89 c7                	mov    %eax,%edi
  800977:	fc                   	cld    
  800978:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80097a:	5e                   	pop    %esi
  80097b:	5f                   	pop    %edi
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80097e:	f3 0f 1e fb          	endbr32 
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800988:	ff 75 10             	pushl  0x10(%ebp)
  80098b:	ff 75 0c             	pushl  0xc(%ebp)
  80098e:	ff 75 08             	pushl  0x8(%ebp)
  800991:	e8 82 ff ff ff       	call   800918 <memmove>
}
  800996:	c9                   	leave  
  800997:	c3                   	ret    

00800998 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800998:	f3 0f 1e fb          	endbr32 
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	56                   	push   %esi
  8009a0:	53                   	push   %ebx
  8009a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a7:	89 c6                	mov    %eax,%esi
  8009a9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ac:	39 f0                	cmp    %esi,%eax
  8009ae:	74 1c                	je     8009cc <memcmp+0x34>
		if (*s1 != *s2)
  8009b0:	0f b6 08             	movzbl (%eax),%ecx
  8009b3:	0f b6 1a             	movzbl (%edx),%ebx
  8009b6:	38 d9                	cmp    %bl,%cl
  8009b8:	75 08                	jne    8009c2 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009ba:	83 c0 01             	add    $0x1,%eax
  8009bd:	83 c2 01             	add    $0x1,%edx
  8009c0:	eb ea                	jmp    8009ac <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  8009c2:	0f b6 c1             	movzbl %cl,%eax
  8009c5:	0f b6 db             	movzbl %bl,%ebx
  8009c8:	29 d8                	sub    %ebx,%eax
  8009ca:	eb 05                	jmp    8009d1 <memcmp+0x39>
	}

	return 0;
  8009cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d1:	5b                   	pop    %ebx
  8009d2:	5e                   	pop    %esi
  8009d3:	5d                   	pop    %ebp
  8009d4:	c3                   	ret    

008009d5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d5:	f3 0f 1e fb          	endbr32 
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009e2:	89 c2                	mov    %eax,%edx
  8009e4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009e7:	39 d0                	cmp    %edx,%eax
  8009e9:	73 09                	jae    8009f4 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009eb:	38 08                	cmp    %cl,(%eax)
  8009ed:	74 05                	je     8009f4 <memfind+0x1f>
	for (; s < ends; s++)
  8009ef:	83 c0 01             	add    $0x1,%eax
  8009f2:	eb f3                	jmp    8009e7 <memfind+0x12>
			break;
	return (void *) s;
}
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009f6:	f3 0f 1e fb          	endbr32 
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	57                   	push   %edi
  8009fe:	56                   	push   %esi
  8009ff:	53                   	push   %ebx
  800a00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a03:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a06:	eb 03                	jmp    800a0b <strtol+0x15>
		s++;
  800a08:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a0b:	0f b6 01             	movzbl (%ecx),%eax
  800a0e:	3c 20                	cmp    $0x20,%al
  800a10:	74 f6                	je     800a08 <strtol+0x12>
  800a12:	3c 09                	cmp    $0x9,%al
  800a14:	74 f2                	je     800a08 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a16:	3c 2b                	cmp    $0x2b,%al
  800a18:	74 2a                	je     800a44 <strtol+0x4e>
	int neg = 0;
  800a1a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a1f:	3c 2d                	cmp    $0x2d,%al
  800a21:	74 2b                	je     800a4e <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a23:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a29:	75 0f                	jne    800a3a <strtol+0x44>
  800a2b:	80 39 30             	cmpb   $0x30,(%ecx)
  800a2e:	74 28                	je     800a58 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a30:	85 db                	test   %ebx,%ebx
  800a32:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a37:	0f 44 d8             	cmove  %eax,%ebx
  800a3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a42:	eb 46                	jmp    800a8a <strtol+0x94>
		s++;
  800a44:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a47:	bf 00 00 00 00       	mov    $0x0,%edi
  800a4c:	eb d5                	jmp    800a23 <strtol+0x2d>
		s++, neg = 1;
  800a4e:	83 c1 01             	add    $0x1,%ecx
  800a51:	bf 01 00 00 00       	mov    $0x1,%edi
  800a56:	eb cb                	jmp    800a23 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a58:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a5c:	74 0e                	je     800a6c <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a5e:	85 db                	test   %ebx,%ebx
  800a60:	75 d8                	jne    800a3a <strtol+0x44>
		s++, base = 8;
  800a62:	83 c1 01             	add    $0x1,%ecx
  800a65:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a6a:	eb ce                	jmp    800a3a <strtol+0x44>
		s += 2, base = 16;
  800a6c:	83 c1 02             	add    $0x2,%ecx
  800a6f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a74:	eb c4                	jmp    800a3a <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a76:	0f be d2             	movsbl %dl,%edx
  800a79:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a7c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a7f:	7d 3a                	jge    800abb <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a81:	83 c1 01             	add    $0x1,%ecx
  800a84:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a88:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a8a:	0f b6 11             	movzbl (%ecx),%edx
  800a8d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a90:	89 f3                	mov    %esi,%ebx
  800a92:	80 fb 09             	cmp    $0x9,%bl
  800a95:	76 df                	jbe    800a76 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800a97:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a9a:	89 f3                	mov    %esi,%ebx
  800a9c:	80 fb 19             	cmp    $0x19,%bl
  800a9f:	77 08                	ja     800aa9 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800aa1:	0f be d2             	movsbl %dl,%edx
  800aa4:	83 ea 57             	sub    $0x57,%edx
  800aa7:	eb d3                	jmp    800a7c <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800aa9:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aac:	89 f3                	mov    %esi,%ebx
  800aae:	80 fb 19             	cmp    $0x19,%bl
  800ab1:	77 08                	ja     800abb <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ab3:	0f be d2             	movsbl %dl,%edx
  800ab6:	83 ea 37             	sub    $0x37,%edx
  800ab9:	eb c1                	jmp    800a7c <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800abb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800abf:	74 05                	je     800ac6 <strtol+0xd0>
		*endptr = (char *) s;
  800ac1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac4:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ac6:	89 c2                	mov    %eax,%edx
  800ac8:	f7 da                	neg    %edx
  800aca:	85 ff                	test   %edi,%edi
  800acc:	0f 45 c2             	cmovne %edx,%eax
}
  800acf:	5b                   	pop    %ebx
  800ad0:	5e                   	pop    %esi
  800ad1:	5f                   	pop    %edi
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ad4:	f3 0f 1e fb          	endbr32 
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	57                   	push   %edi
  800adc:	56                   	push   %esi
  800add:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ade:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae9:	89 c3                	mov    %eax,%ebx
  800aeb:	89 c7                	mov    %eax,%edi
  800aed:	89 c6                	mov    %eax,%esi
  800aef:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5f                   	pop    %edi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800af6:	f3 0f 1e fb          	endbr32 
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	57                   	push   %edi
  800afe:	56                   	push   %esi
  800aff:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b00:	ba 00 00 00 00       	mov    $0x0,%edx
  800b05:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0a:	89 d1                	mov    %edx,%ecx
  800b0c:	89 d3                	mov    %edx,%ebx
  800b0e:	89 d7                	mov    %edx,%edi
  800b10:	89 d6                	mov    %edx,%esi
  800b12:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b14:	5b                   	pop    %ebx
  800b15:	5e                   	pop    %esi
  800b16:	5f                   	pop    %edi
  800b17:	5d                   	pop    %ebp
  800b18:	c3                   	ret    

00800b19 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b19:	f3 0f 1e fb          	endbr32 
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	57                   	push   %edi
  800b21:	56                   	push   %esi
  800b22:	53                   	push   %ebx
  800b23:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b26:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2e:	b8 03 00 00 00       	mov    $0x3,%eax
  800b33:	89 cb                	mov    %ecx,%ebx
  800b35:	89 cf                	mov    %ecx,%edi
  800b37:	89 ce                	mov    %ecx,%esi
  800b39:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b3b:	85 c0                	test   %eax,%eax
  800b3d:	7f 08                	jg     800b47 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b42:	5b                   	pop    %ebx
  800b43:	5e                   	pop    %esi
  800b44:	5f                   	pop    %edi
  800b45:	5d                   	pop    %ebp
  800b46:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b47:	83 ec 0c             	sub    $0xc,%esp
  800b4a:	50                   	push   %eax
  800b4b:	6a 03                	push   $0x3
  800b4d:	68 9f 13 80 00       	push   $0x80139f
  800b52:	6a 23                	push   $0x23
  800b54:	68 bc 13 80 00       	push   $0x8013bc
  800b59:	e8 57 02 00 00       	call   800db5 <_panic>

00800b5e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b5e:	f3 0f 1e fb          	endbr32 
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b68:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6d:	b8 02 00 00 00       	mov    $0x2,%eax
  800b72:	89 d1                	mov    %edx,%ecx
  800b74:	89 d3                	mov    %edx,%ebx
  800b76:	89 d7                	mov    %edx,%edi
  800b78:	89 d6                	mov    %edx,%esi
  800b7a:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b7c:	5b                   	pop    %ebx
  800b7d:	5e                   	pop    %esi
  800b7e:	5f                   	pop    %edi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <sys_yield>:

void
sys_yield(void)
{
  800b81:	f3 0f 1e fb          	endbr32 
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	57                   	push   %edi
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b90:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b95:	89 d1                	mov    %edx,%ecx
  800b97:	89 d3                	mov    %edx,%ebx
  800b99:	89 d7                	mov    %edx,%edi
  800b9b:	89 d6                	mov    %edx,%esi
  800b9d:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5f                   	pop    %edi
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ba4:	f3 0f 1e fb          	endbr32 
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	57                   	push   %edi
  800bac:	56                   	push   %esi
  800bad:	53                   	push   %ebx
  800bae:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bb1:	be 00 00 00 00       	mov    $0x0,%esi
  800bb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbc:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc4:	89 f7                	mov    %esi,%edi
  800bc6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bc8:	85 c0                	test   %eax,%eax
  800bca:	7f 08                	jg     800bd4 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bcf:	5b                   	pop    %ebx
  800bd0:	5e                   	pop    %esi
  800bd1:	5f                   	pop    %edi
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd4:	83 ec 0c             	sub    $0xc,%esp
  800bd7:	50                   	push   %eax
  800bd8:	6a 04                	push   $0x4
  800bda:	68 9f 13 80 00       	push   $0x80139f
  800bdf:	6a 23                	push   $0x23
  800be1:	68 bc 13 80 00       	push   $0x8013bc
  800be6:	e8 ca 01 00 00       	call   800db5 <_panic>

00800beb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800beb:	f3 0f 1e fb          	endbr32 
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	57                   	push   %edi
  800bf3:	56                   	push   %esi
  800bf4:	53                   	push   %ebx
  800bf5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfe:	b8 05 00 00 00       	mov    $0x5,%eax
  800c03:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c06:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c09:	8b 75 18             	mov    0x18(%ebp),%esi
  800c0c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c0e:	85 c0                	test   %eax,%eax
  800c10:	7f 08                	jg     800c1a <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c15:	5b                   	pop    %ebx
  800c16:	5e                   	pop    %esi
  800c17:	5f                   	pop    %edi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1a:	83 ec 0c             	sub    $0xc,%esp
  800c1d:	50                   	push   %eax
  800c1e:	6a 05                	push   $0x5
  800c20:	68 9f 13 80 00       	push   $0x80139f
  800c25:	6a 23                	push   $0x23
  800c27:	68 bc 13 80 00       	push   $0x8013bc
  800c2c:	e8 84 01 00 00       	call   800db5 <_panic>

00800c31 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c31:	f3 0f 1e fb          	endbr32 
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	57                   	push   %edi
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
  800c3b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c3e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c43:	8b 55 08             	mov    0x8(%ebp),%edx
  800c46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c49:	b8 06 00 00 00       	mov    $0x6,%eax
  800c4e:	89 df                	mov    %ebx,%edi
  800c50:	89 de                	mov    %ebx,%esi
  800c52:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c54:	85 c0                	test   %eax,%eax
  800c56:	7f 08                	jg     800c60 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c60:	83 ec 0c             	sub    $0xc,%esp
  800c63:	50                   	push   %eax
  800c64:	6a 06                	push   $0x6
  800c66:	68 9f 13 80 00       	push   $0x80139f
  800c6b:	6a 23                	push   $0x23
  800c6d:	68 bc 13 80 00       	push   $0x8013bc
  800c72:	e8 3e 01 00 00       	call   800db5 <_panic>

00800c77 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c77:	f3 0f 1e fb          	endbr32 
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	57                   	push   %edi
  800c7f:	56                   	push   %esi
  800c80:	53                   	push   %ebx
  800c81:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c84:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c89:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8f:	b8 08 00 00 00       	mov    $0x8,%eax
  800c94:	89 df                	mov    %ebx,%edi
  800c96:	89 de                	mov    %ebx,%esi
  800c98:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c9a:	85 c0                	test   %eax,%eax
  800c9c:	7f 08                	jg     800ca6 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5f                   	pop    %edi
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca6:	83 ec 0c             	sub    $0xc,%esp
  800ca9:	50                   	push   %eax
  800caa:	6a 08                	push   $0x8
  800cac:	68 9f 13 80 00       	push   $0x80139f
  800cb1:	6a 23                	push   $0x23
  800cb3:	68 bc 13 80 00       	push   $0x8013bc
  800cb8:	e8 f8 00 00 00       	call   800db5 <_panic>

00800cbd <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cbd:	f3 0f 1e fb          	endbr32 
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cca:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd5:	b8 09 00 00 00       	mov    $0x9,%eax
  800cda:	89 df                	mov    %ebx,%edi
  800cdc:	89 de                	mov    %ebx,%esi
  800cde:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	7f 08                	jg     800cec <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ce4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cec:	83 ec 0c             	sub    $0xc,%esp
  800cef:	50                   	push   %eax
  800cf0:	6a 09                	push   $0x9
  800cf2:	68 9f 13 80 00       	push   $0x80139f
  800cf7:	6a 23                	push   $0x23
  800cf9:	68 bc 13 80 00       	push   $0x8013bc
  800cfe:	e8 b2 00 00 00       	call   800db5 <_panic>

00800d03 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d03:	f3 0f 1e fb          	endbr32 
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
  800d0d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d15:	8b 55 08             	mov    0x8(%ebp),%edx
  800d18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d20:	89 df                	mov    %ebx,%edi
  800d22:	89 de                	mov    %ebx,%esi
  800d24:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d26:	85 c0                	test   %eax,%eax
  800d28:	7f 08                	jg     800d32 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2d:	5b                   	pop    %ebx
  800d2e:	5e                   	pop    %esi
  800d2f:	5f                   	pop    %edi
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d32:	83 ec 0c             	sub    $0xc,%esp
  800d35:	50                   	push   %eax
  800d36:	6a 0a                	push   $0xa
  800d38:	68 9f 13 80 00       	push   $0x80139f
  800d3d:	6a 23                	push   $0x23
  800d3f:	68 bc 13 80 00       	push   $0x8013bc
  800d44:	e8 6c 00 00 00       	call   800db5 <_panic>

00800d49 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d49:	f3 0f 1e fb          	endbr32 
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	57                   	push   %edi
  800d51:	56                   	push   %esi
  800d52:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d53:	8b 55 08             	mov    0x8(%ebp),%edx
  800d56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d59:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d5e:	be 00 00 00 00       	mov    $0x0,%esi
  800d63:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d66:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d69:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d6b:	5b                   	pop    %ebx
  800d6c:	5e                   	pop    %esi
  800d6d:	5f                   	pop    %edi
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    

00800d70 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d70:	f3 0f 1e fb          	endbr32 
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	57                   	push   %edi
  800d78:	56                   	push   %esi
  800d79:	53                   	push   %ebx
  800d7a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d7d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d82:	8b 55 08             	mov    0x8(%ebp),%edx
  800d85:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d8a:	89 cb                	mov    %ecx,%ebx
  800d8c:	89 cf                	mov    %ecx,%edi
  800d8e:	89 ce                	mov    %ecx,%esi
  800d90:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d92:	85 c0                	test   %eax,%eax
  800d94:	7f 08                	jg     800d9e <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d99:	5b                   	pop    %ebx
  800d9a:	5e                   	pop    %esi
  800d9b:	5f                   	pop    %edi
  800d9c:	5d                   	pop    %ebp
  800d9d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9e:	83 ec 0c             	sub    $0xc,%esp
  800da1:	50                   	push   %eax
  800da2:	6a 0d                	push   $0xd
  800da4:	68 9f 13 80 00       	push   $0x80139f
  800da9:	6a 23                	push   $0x23
  800dab:	68 bc 13 80 00       	push   $0x8013bc
  800db0:	e8 00 00 00 00       	call   800db5 <_panic>

00800db5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800db5:	f3 0f 1e fb          	endbr32 
  800db9:	55                   	push   %ebp
  800dba:	89 e5                	mov    %esp,%ebp
  800dbc:	56                   	push   %esi
  800dbd:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800dbe:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800dc1:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800dc7:	e8 92 fd ff ff       	call   800b5e <sys_getenvid>
  800dcc:	83 ec 0c             	sub    $0xc,%esp
  800dcf:	ff 75 0c             	pushl  0xc(%ebp)
  800dd2:	ff 75 08             	pushl  0x8(%ebp)
  800dd5:	56                   	push   %esi
  800dd6:	50                   	push   %eax
  800dd7:	68 cc 13 80 00       	push   $0x8013cc
  800ddc:	e8 78 f3 ff ff       	call   800159 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800de1:	83 c4 18             	add    $0x18,%esp
  800de4:	53                   	push   %ebx
  800de5:	ff 75 10             	pushl  0x10(%ebp)
  800de8:	e8 17 f3 ff ff       	call   800104 <vcprintf>
	cprintf("\n");
  800ded:	c7 04 24 ef 13 80 00 	movl   $0x8013ef,(%esp)
  800df4:	e8 60 f3 ff ff       	call   800159 <cprintf>
  800df9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800dfc:	cc                   	int3   
  800dfd:	eb fd                	jmp    800dfc <_panic+0x47>
  800dff:	90                   	nop

00800e00 <__udivdi3>:
  800e00:	f3 0f 1e fb          	endbr32 
  800e04:	55                   	push   %ebp
  800e05:	57                   	push   %edi
  800e06:	56                   	push   %esi
  800e07:	53                   	push   %ebx
  800e08:	83 ec 1c             	sub    $0x1c,%esp
  800e0b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e0f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e13:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e17:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e1b:	85 d2                	test   %edx,%edx
  800e1d:	75 19                	jne    800e38 <__udivdi3+0x38>
  800e1f:	39 f3                	cmp    %esi,%ebx
  800e21:	76 4d                	jbe    800e70 <__udivdi3+0x70>
  800e23:	31 ff                	xor    %edi,%edi
  800e25:	89 e8                	mov    %ebp,%eax
  800e27:	89 f2                	mov    %esi,%edx
  800e29:	f7 f3                	div    %ebx
  800e2b:	89 fa                	mov    %edi,%edx
  800e2d:	83 c4 1c             	add    $0x1c,%esp
  800e30:	5b                   	pop    %ebx
  800e31:	5e                   	pop    %esi
  800e32:	5f                   	pop    %edi
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    
  800e35:	8d 76 00             	lea    0x0(%esi),%esi
  800e38:	39 f2                	cmp    %esi,%edx
  800e3a:	76 14                	jbe    800e50 <__udivdi3+0x50>
  800e3c:	31 ff                	xor    %edi,%edi
  800e3e:	31 c0                	xor    %eax,%eax
  800e40:	89 fa                	mov    %edi,%edx
  800e42:	83 c4 1c             	add    $0x1c,%esp
  800e45:	5b                   	pop    %ebx
  800e46:	5e                   	pop    %esi
  800e47:	5f                   	pop    %edi
  800e48:	5d                   	pop    %ebp
  800e49:	c3                   	ret    
  800e4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e50:	0f bd fa             	bsr    %edx,%edi
  800e53:	83 f7 1f             	xor    $0x1f,%edi
  800e56:	75 48                	jne    800ea0 <__udivdi3+0xa0>
  800e58:	39 f2                	cmp    %esi,%edx
  800e5a:	72 06                	jb     800e62 <__udivdi3+0x62>
  800e5c:	31 c0                	xor    %eax,%eax
  800e5e:	39 eb                	cmp    %ebp,%ebx
  800e60:	77 de                	ja     800e40 <__udivdi3+0x40>
  800e62:	b8 01 00 00 00       	mov    $0x1,%eax
  800e67:	eb d7                	jmp    800e40 <__udivdi3+0x40>
  800e69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e70:	89 d9                	mov    %ebx,%ecx
  800e72:	85 db                	test   %ebx,%ebx
  800e74:	75 0b                	jne    800e81 <__udivdi3+0x81>
  800e76:	b8 01 00 00 00       	mov    $0x1,%eax
  800e7b:	31 d2                	xor    %edx,%edx
  800e7d:	f7 f3                	div    %ebx
  800e7f:	89 c1                	mov    %eax,%ecx
  800e81:	31 d2                	xor    %edx,%edx
  800e83:	89 f0                	mov    %esi,%eax
  800e85:	f7 f1                	div    %ecx
  800e87:	89 c6                	mov    %eax,%esi
  800e89:	89 e8                	mov    %ebp,%eax
  800e8b:	89 f7                	mov    %esi,%edi
  800e8d:	f7 f1                	div    %ecx
  800e8f:	89 fa                	mov    %edi,%edx
  800e91:	83 c4 1c             	add    $0x1c,%esp
  800e94:	5b                   	pop    %ebx
  800e95:	5e                   	pop    %esi
  800e96:	5f                   	pop    %edi
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    
  800e99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ea0:	89 f9                	mov    %edi,%ecx
  800ea2:	b8 20 00 00 00       	mov    $0x20,%eax
  800ea7:	29 f8                	sub    %edi,%eax
  800ea9:	d3 e2                	shl    %cl,%edx
  800eab:	89 54 24 08          	mov    %edx,0x8(%esp)
  800eaf:	89 c1                	mov    %eax,%ecx
  800eb1:	89 da                	mov    %ebx,%edx
  800eb3:	d3 ea                	shr    %cl,%edx
  800eb5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800eb9:	09 d1                	or     %edx,%ecx
  800ebb:	89 f2                	mov    %esi,%edx
  800ebd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ec1:	89 f9                	mov    %edi,%ecx
  800ec3:	d3 e3                	shl    %cl,%ebx
  800ec5:	89 c1                	mov    %eax,%ecx
  800ec7:	d3 ea                	shr    %cl,%edx
  800ec9:	89 f9                	mov    %edi,%ecx
  800ecb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ecf:	89 eb                	mov    %ebp,%ebx
  800ed1:	d3 e6                	shl    %cl,%esi
  800ed3:	89 c1                	mov    %eax,%ecx
  800ed5:	d3 eb                	shr    %cl,%ebx
  800ed7:	09 de                	or     %ebx,%esi
  800ed9:	89 f0                	mov    %esi,%eax
  800edb:	f7 74 24 08          	divl   0x8(%esp)
  800edf:	89 d6                	mov    %edx,%esi
  800ee1:	89 c3                	mov    %eax,%ebx
  800ee3:	f7 64 24 0c          	mull   0xc(%esp)
  800ee7:	39 d6                	cmp    %edx,%esi
  800ee9:	72 15                	jb     800f00 <__udivdi3+0x100>
  800eeb:	89 f9                	mov    %edi,%ecx
  800eed:	d3 e5                	shl    %cl,%ebp
  800eef:	39 c5                	cmp    %eax,%ebp
  800ef1:	73 04                	jae    800ef7 <__udivdi3+0xf7>
  800ef3:	39 d6                	cmp    %edx,%esi
  800ef5:	74 09                	je     800f00 <__udivdi3+0x100>
  800ef7:	89 d8                	mov    %ebx,%eax
  800ef9:	31 ff                	xor    %edi,%edi
  800efb:	e9 40 ff ff ff       	jmp    800e40 <__udivdi3+0x40>
  800f00:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800f03:	31 ff                	xor    %edi,%edi
  800f05:	e9 36 ff ff ff       	jmp    800e40 <__udivdi3+0x40>
  800f0a:	66 90                	xchg   %ax,%ax
  800f0c:	66 90                	xchg   %ax,%ax
  800f0e:	66 90                	xchg   %ax,%ax

00800f10 <__umoddi3>:
  800f10:	f3 0f 1e fb          	endbr32 
  800f14:	55                   	push   %ebp
  800f15:	57                   	push   %edi
  800f16:	56                   	push   %esi
  800f17:	53                   	push   %ebx
  800f18:	83 ec 1c             	sub    $0x1c,%esp
  800f1b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800f1f:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f23:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f27:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f2b:	85 c0                	test   %eax,%eax
  800f2d:	75 19                	jne    800f48 <__umoddi3+0x38>
  800f2f:	39 df                	cmp    %ebx,%edi
  800f31:	76 5d                	jbe    800f90 <__umoddi3+0x80>
  800f33:	89 f0                	mov    %esi,%eax
  800f35:	89 da                	mov    %ebx,%edx
  800f37:	f7 f7                	div    %edi
  800f39:	89 d0                	mov    %edx,%eax
  800f3b:	31 d2                	xor    %edx,%edx
  800f3d:	83 c4 1c             	add    $0x1c,%esp
  800f40:	5b                   	pop    %ebx
  800f41:	5e                   	pop    %esi
  800f42:	5f                   	pop    %edi
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    
  800f45:	8d 76 00             	lea    0x0(%esi),%esi
  800f48:	89 f2                	mov    %esi,%edx
  800f4a:	39 d8                	cmp    %ebx,%eax
  800f4c:	76 12                	jbe    800f60 <__umoddi3+0x50>
  800f4e:	89 f0                	mov    %esi,%eax
  800f50:	89 da                	mov    %ebx,%edx
  800f52:	83 c4 1c             	add    $0x1c,%esp
  800f55:	5b                   	pop    %ebx
  800f56:	5e                   	pop    %esi
  800f57:	5f                   	pop    %edi
  800f58:	5d                   	pop    %ebp
  800f59:	c3                   	ret    
  800f5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f60:	0f bd e8             	bsr    %eax,%ebp
  800f63:	83 f5 1f             	xor    $0x1f,%ebp
  800f66:	75 50                	jne    800fb8 <__umoddi3+0xa8>
  800f68:	39 d8                	cmp    %ebx,%eax
  800f6a:	0f 82 e0 00 00 00    	jb     801050 <__umoddi3+0x140>
  800f70:	89 d9                	mov    %ebx,%ecx
  800f72:	39 f7                	cmp    %esi,%edi
  800f74:	0f 86 d6 00 00 00    	jbe    801050 <__umoddi3+0x140>
  800f7a:	89 d0                	mov    %edx,%eax
  800f7c:	89 ca                	mov    %ecx,%edx
  800f7e:	83 c4 1c             	add    $0x1c,%esp
  800f81:	5b                   	pop    %ebx
  800f82:	5e                   	pop    %esi
  800f83:	5f                   	pop    %edi
  800f84:	5d                   	pop    %ebp
  800f85:	c3                   	ret    
  800f86:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f8d:	8d 76 00             	lea    0x0(%esi),%esi
  800f90:	89 fd                	mov    %edi,%ebp
  800f92:	85 ff                	test   %edi,%edi
  800f94:	75 0b                	jne    800fa1 <__umoddi3+0x91>
  800f96:	b8 01 00 00 00       	mov    $0x1,%eax
  800f9b:	31 d2                	xor    %edx,%edx
  800f9d:	f7 f7                	div    %edi
  800f9f:	89 c5                	mov    %eax,%ebp
  800fa1:	89 d8                	mov    %ebx,%eax
  800fa3:	31 d2                	xor    %edx,%edx
  800fa5:	f7 f5                	div    %ebp
  800fa7:	89 f0                	mov    %esi,%eax
  800fa9:	f7 f5                	div    %ebp
  800fab:	89 d0                	mov    %edx,%eax
  800fad:	31 d2                	xor    %edx,%edx
  800faf:	eb 8c                	jmp    800f3d <__umoddi3+0x2d>
  800fb1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fb8:	89 e9                	mov    %ebp,%ecx
  800fba:	ba 20 00 00 00       	mov    $0x20,%edx
  800fbf:	29 ea                	sub    %ebp,%edx
  800fc1:	d3 e0                	shl    %cl,%eax
  800fc3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fc7:	89 d1                	mov    %edx,%ecx
  800fc9:	89 f8                	mov    %edi,%eax
  800fcb:	d3 e8                	shr    %cl,%eax
  800fcd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800fd1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fd5:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fd9:	09 c1                	or     %eax,%ecx
  800fdb:	89 d8                	mov    %ebx,%eax
  800fdd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fe1:	89 e9                	mov    %ebp,%ecx
  800fe3:	d3 e7                	shl    %cl,%edi
  800fe5:	89 d1                	mov    %edx,%ecx
  800fe7:	d3 e8                	shr    %cl,%eax
  800fe9:	89 e9                	mov    %ebp,%ecx
  800feb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fef:	d3 e3                	shl    %cl,%ebx
  800ff1:	89 c7                	mov    %eax,%edi
  800ff3:	89 d1                	mov    %edx,%ecx
  800ff5:	89 f0                	mov    %esi,%eax
  800ff7:	d3 e8                	shr    %cl,%eax
  800ff9:	89 e9                	mov    %ebp,%ecx
  800ffb:	89 fa                	mov    %edi,%edx
  800ffd:	d3 e6                	shl    %cl,%esi
  800fff:	09 d8                	or     %ebx,%eax
  801001:	f7 74 24 08          	divl   0x8(%esp)
  801005:	89 d1                	mov    %edx,%ecx
  801007:	89 f3                	mov    %esi,%ebx
  801009:	f7 64 24 0c          	mull   0xc(%esp)
  80100d:	89 c6                	mov    %eax,%esi
  80100f:	89 d7                	mov    %edx,%edi
  801011:	39 d1                	cmp    %edx,%ecx
  801013:	72 06                	jb     80101b <__umoddi3+0x10b>
  801015:	75 10                	jne    801027 <__umoddi3+0x117>
  801017:	39 c3                	cmp    %eax,%ebx
  801019:	73 0c                	jae    801027 <__umoddi3+0x117>
  80101b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80101f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801023:	89 d7                	mov    %edx,%edi
  801025:	89 c6                	mov    %eax,%esi
  801027:	89 ca                	mov    %ecx,%edx
  801029:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80102e:	29 f3                	sub    %esi,%ebx
  801030:	19 fa                	sbb    %edi,%edx
  801032:	89 d0                	mov    %edx,%eax
  801034:	d3 e0                	shl    %cl,%eax
  801036:	89 e9                	mov    %ebp,%ecx
  801038:	d3 eb                	shr    %cl,%ebx
  80103a:	d3 ea                	shr    %cl,%edx
  80103c:	09 d8                	or     %ebx,%eax
  80103e:	83 c4 1c             	add    $0x1c,%esp
  801041:	5b                   	pop    %ebx
  801042:	5e                   	pop    %esi
  801043:	5f                   	pop    %edi
  801044:	5d                   	pop    %ebp
  801045:	c3                   	ret    
  801046:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80104d:	8d 76 00             	lea    0x0(%esi),%esi
  801050:	29 fe                	sub    %edi,%esi
  801052:	19 c3                	sbb    %eax,%ebx
  801054:	89 f2                	mov    %esi,%edx
  801056:	89 d9                	mov    %ebx,%ecx
  801058:	e9 1d ff ff ff       	jmp    800f7a <__umoddi3+0x6a>
