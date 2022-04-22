
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
  800049:	68 e0 1f 80 00       	push   $0x801fe0
  80004e:	e8 44 01 00 00       	call   800197 <cprintf>
	sys_env_destroy(sys_getenvid());
  800053:	e8 44 0b 00 00       	call   800b9c <sys_getenvid>
  800058:	89 04 24             	mov    %eax,(%esp)
  80005b:	e8 f7 0a 00 00       	call   800b57 <sys_env_destroy>
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
  800074:	e8 7a 0d 00 00       	call   800df3 <set_pgfault_handler>
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
	thisenv = 0;
  800097:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  80009e:	00 00 00 
    envid_t envid = sys_getenvid();
  8000a1:	e8 f6 0a 00 00       	call   800b9c <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  8000a6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ab:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000ae:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b3:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b8:	85 db                	test   %ebx,%ebx
  8000ba:	7e 07                	jle    8000c3 <libmain+0x3b>
		binaryname = argv[0];
  8000bc:	8b 06                	mov    (%esi),%eax
  8000be:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000c3:	83 ec 08             	sub    $0x8,%esp
  8000c6:	56                   	push   %esi
  8000c7:	53                   	push   %ebx
  8000c8:	e8 98 ff ff ff       	call   800065 <umain>

	// exit gracefully
	exit();
  8000cd:	e8 0a 00 00 00       	call   8000dc <exit>
}
  8000d2:	83 c4 10             	add    $0x10,%esp
  8000d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000d8:	5b                   	pop    %ebx
  8000d9:	5e                   	pop    %esi
  8000da:	5d                   	pop    %ebp
  8000db:	c3                   	ret    

008000dc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000dc:	f3 0f 1e fb          	endbr32 
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000e6:	e8 9d 0f 00 00       	call   801088 <close_all>
	sys_env_destroy(0);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	6a 00                	push   $0x0
  8000f0:	e8 62 0a 00 00       	call   800b57 <sys_env_destroy>
}
  8000f5:	83 c4 10             	add    $0x10,%esp
  8000f8:	c9                   	leave  
  8000f9:	c3                   	ret    

008000fa <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000fa:	f3 0f 1e fb          	endbr32 
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	53                   	push   %ebx
  800102:	83 ec 04             	sub    $0x4,%esp
  800105:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800108:	8b 13                	mov    (%ebx),%edx
  80010a:	8d 42 01             	lea    0x1(%edx),%eax
  80010d:	89 03                	mov    %eax,(%ebx)
  80010f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800112:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800116:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011b:	74 09                	je     800126 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80011d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800121:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800124:	c9                   	leave  
  800125:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800126:	83 ec 08             	sub    $0x8,%esp
  800129:	68 ff 00 00 00       	push   $0xff
  80012e:	8d 43 08             	lea    0x8(%ebx),%eax
  800131:	50                   	push   %eax
  800132:	e8 db 09 00 00       	call   800b12 <sys_cputs>
		b->idx = 0;
  800137:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80013d:	83 c4 10             	add    $0x10,%esp
  800140:	eb db                	jmp    80011d <putch+0x23>

00800142 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800142:	f3 0f 1e fb          	endbr32 
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80014f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800156:	00 00 00 
	b.cnt = 0;
  800159:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800160:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800163:	ff 75 0c             	pushl  0xc(%ebp)
  800166:	ff 75 08             	pushl  0x8(%ebp)
  800169:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016f:	50                   	push   %eax
  800170:	68 fa 00 80 00       	push   $0x8000fa
  800175:	e8 20 01 00 00       	call   80029a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80017a:	83 c4 08             	add    $0x8,%esp
  80017d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800183:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800189:	50                   	push   %eax
  80018a:	e8 83 09 00 00       	call   800b12 <sys_cputs>

	return b.cnt;
}
  80018f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800195:	c9                   	leave  
  800196:	c3                   	ret    

00800197 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800197:	f3 0f 1e fb          	endbr32 
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a4:	50                   	push   %eax
  8001a5:	ff 75 08             	pushl  0x8(%ebp)
  8001a8:	e8 95 ff ff ff       	call   800142 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ad:	c9                   	leave  
  8001ae:	c3                   	ret    

008001af <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001af:	55                   	push   %ebp
  8001b0:	89 e5                	mov    %esp,%ebp
  8001b2:	57                   	push   %edi
  8001b3:	56                   	push   %esi
  8001b4:	53                   	push   %ebx
  8001b5:	83 ec 1c             	sub    $0x1c,%esp
  8001b8:	89 c7                	mov    %eax,%edi
  8001ba:	89 d6                	mov    %edx,%esi
  8001bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8001bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c2:	89 d1                	mov    %edx,%ecx
  8001c4:	89 c2                	mov    %eax,%edx
  8001c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001c9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8001cf:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001d5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001dc:	39 c2                	cmp    %eax,%edx
  8001de:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001e1:	72 3e                	jb     800221 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e3:	83 ec 0c             	sub    $0xc,%esp
  8001e6:	ff 75 18             	pushl  0x18(%ebp)
  8001e9:	83 eb 01             	sub    $0x1,%ebx
  8001ec:	53                   	push   %ebx
  8001ed:	50                   	push   %eax
  8001ee:	83 ec 08             	sub    $0x8,%esp
  8001f1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f4:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f7:	ff 75 dc             	pushl  -0x24(%ebp)
  8001fa:	ff 75 d8             	pushl  -0x28(%ebp)
  8001fd:	e8 6e 1b 00 00       	call   801d70 <__udivdi3>
  800202:	83 c4 18             	add    $0x18,%esp
  800205:	52                   	push   %edx
  800206:	50                   	push   %eax
  800207:	89 f2                	mov    %esi,%edx
  800209:	89 f8                	mov    %edi,%eax
  80020b:	e8 9f ff ff ff       	call   8001af <printnum>
  800210:	83 c4 20             	add    $0x20,%esp
  800213:	eb 13                	jmp    800228 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800215:	83 ec 08             	sub    $0x8,%esp
  800218:	56                   	push   %esi
  800219:	ff 75 18             	pushl  0x18(%ebp)
  80021c:	ff d7                	call   *%edi
  80021e:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800221:	83 eb 01             	sub    $0x1,%ebx
  800224:	85 db                	test   %ebx,%ebx
  800226:	7f ed                	jg     800215 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800228:	83 ec 08             	sub    $0x8,%esp
  80022b:	56                   	push   %esi
  80022c:	83 ec 04             	sub    $0x4,%esp
  80022f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800232:	ff 75 e0             	pushl  -0x20(%ebp)
  800235:	ff 75 dc             	pushl  -0x24(%ebp)
  800238:	ff 75 d8             	pushl  -0x28(%ebp)
  80023b:	e8 40 1c 00 00       	call   801e80 <__umoddi3>
  800240:	83 c4 14             	add    $0x14,%esp
  800243:	0f be 80 06 20 80 00 	movsbl 0x802006(%eax),%eax
  80024a:	50                   	push   %eax
  80024b:	ff d7                	call   *%edi
}
  80024d:	83 c4 10             	add    $0x10,%esp
  800250:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800253:	5b                   	pop    %ebx
  800254:	5e                   	pop    %esi
  800255:	5f                   	pop    %edi
  800256:	5d                   	pop    %ebp
  800257:	c3                   	ret    

00800258 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800258:	f3 0f 1e fb          	endbr32 
  80025c:	55                   	push   %ebp
  80025d:	89 e5                	mov    %esp,%ebp
  80025f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800262:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800266:	8b 10                	mov    (%eax),%edx
  800268:	3b 50 04             	cmp    0x4(%eax),%edx
  80026b:	73 0a                	jae    800277 <sprintputch+0x1f>
		*b->buf++ = ch;
  80026d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800270:	89 08                	mov    %ecx,(%eax)
  800272:	8b 45 08             	mov    0x8(%ebp),%eax
  800275:	88 02                	mov    %al,(%edx)
}
  800277:	5d                   	pop    %ebp
  800278:	c3                   	ret    

00800279 <printfmt>:
{
  800279:	f3 0f 1e fb          	endbr32 
  80027d:	55                   	push   %ebp
  80027e:	89 e5                	mov    %esp,%ebp
  800280:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800283:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800286:	50                   	push   %eax
  800287:	ff 75 10             	pushl  0x10(%ebp)
  80028a:	ff 75 0c             	pushl  0xc(%ebp)
  80028d:	ff 75 08             	pushl  0x8(%ebp)
  800290:	e8 05 00 00 00       	call   80029a <vprintfmt>
}
  800295:	83 c4 10             	add    $0x10,%esp
  800298:	c9                   	leave  
  800299:	c3                   	ret    

0080029a <vprintfmt>:
{
  80029a:	f3 0f 1e fb          	endbr32 
  80029e:	55                   	push   %ebp
  80029f:	89 e5                	mov    %esp,%ebp
  8002a1:	57                   	push   %edi
  8002a2:	56                   	push   %esi
  8002a3:	53                   	push   %ebx
  8002a4:	83 ec 3c             	sub    $0x3c,%esp
  8002a7:	8b 75 08             	mov    0x8(%ebp),%esi
  8002aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ad:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002b0:	e9 4a 03 00 00       	jmp    8005ff <vprintfmt+0x365>
		padc = ' ';
  8002b5:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002b9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002c0:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002c7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002ce:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002d3:	8d 47 01             	lea    0x1(%edi),%eax
  8002d6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002d9:	0f b6 17             	movzbl (%edi),%edx
  8002dc:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002df:	3c 55                	cmp    $0x55,%al
  8002e1:	0f 87 de 03 00 00    	ja     8006c5 <vprintfmt+0x42b>
  8002e7:	0f b6 c0             	movzbl %al,%eax
  8002ea:	3e ff 24 85 40 21 80 	notrack jmp *0x802140(,%eax,4)
  8002f1:	00 
  8002f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002f5:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002f9:	eb d8                	jmp    8002d3 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8002fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002fe:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800302:	eb cf                	jmp    8002d3 <vprintfmt+0x39>
  800304:	0f b6 d2             	movzbl %dl,%edx
  800307:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80030a:	b8 00 00 00 00       	mov    $0x0,%eax
  80030f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800312:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800315:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800319:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80031c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80031f:	83 f9 09             	cmp    $0x9,%ecx
  800322:	77 55                	ja     800379 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800324:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800327:	eb e9                	jmp    800312 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800329:	8b 45 14             	mov    0x14(%ebp),%eax
  80032c:	8b 00                	mov    (%eax),%eax
  80032e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800331:	8b 45 14             	mov    0x14(%ebp),%eax
  800334:	8d 40 04             	lea    0x4(%eax),%eax
  800337:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80033d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800341:	79 90                	jns    8002d3 <vprintfmt+0x39>
				width = precision, precision = -1;
  800343:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800346:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800349:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800350:	eb 81                	jmp    8002d3 <vprintfmt+0x39>
  800352:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800355:	85 c0                	test   %eax,%eax
  800357:	ba 00 00 00 00       	mov    $0x0,%edx
  80035c:	0f 49 d0             	cmovns %eax,%edx
  80035f:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800362:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800365:	e9 69 ff ff ff       	jmp    8002d3 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80036a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80036d:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800374:	e9 5a ff ff ff       	jmp    8002d3 <vprintfmt+0x39>
  800379:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80037c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80037f:	eb bc                	jmp    80033d <vprintfmt+0xa3>
			lflag++;
  800381:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800384:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800387:	e9 47 ff ff ff       	jmp    8002d3 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80038c:	8b 45 14             	mov    0x14(%ebp),%eax
  80038f:	8d 78 04             	lea    0x4(%eax),%edi
  800392:	83 ec 08             	sub    $0x8,%esp
  800395:	53                   	push   %ebx
  800396:	ff 30                	pushl  (%eax)
  800398:	ff d6                	call   *%esi
			break;
  80039a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80039d:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003a0:	e9 57 02 00 00       	jmp    8005fc <vprintfmt+0x362>
			err = va_arg(ap, int);
  8003a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a8:	8d 78 04             	lea    0x4(%eax),%edi
  8003ab:	8b 00                	mov    (%eax),%eax
  8003ad:	99                   	cltd   
  8003ae:	31 d0                	xor    %edx,%eax
  8003b0:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003b2:	83 f8 0f             	cmp    $0xf,%eax
  8003b5:	7f 23                	jg     8003da <vprintfmt+0x140>
  8003b7:	8b 14 85 a0 22 80 00 	mov    0x8022a0(,%eax,4),%edx
  8003be:	85 d2                	test   %edx,%edx
  8003c0:	74 18                	je     8003da <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8003c2:	52                   	push   %edx
  8003c3:	68 31 24 80 00       	push   $0x802431
  8003c8:	53                   	push   %ebx
  8003c9:	56                   	push   %esi
  8003ca:	e8 aa fe ff ff       	call   800279 <printfmt>
  8003cf:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003d2:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003d5:	e9 22 02 00 00       	jmp    8005fc <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8003da:	50                   	push   %eax
  8003db:	68 1e 20 80 00       	push   $0x80201e
  8003e0:	53                   	push   %ebx
  8003e1:	56                   	push   %esi
  8003e2:	e8 92 fe ff ff       	call   800279 <printfmt>
  8003e7:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003ea:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003ed:	e9 0a 02 00 00       	jmp    8005fc <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8003f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f5:	83 c0 04             	add    $0x4,%eax
  8003f8:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fe:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800400:	85 d2                	test   %edx,%edx
  800402:	b8 17 20 80 00       	mov    $0x802017,%eax
  800407:	0f 45 c2             	cmovne %edx,%eax
  80040a:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80040d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800411:	7e 06                	jle    800419 <vprintfmt+0x17f>
  800413:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800417:	75 0d                	jne    800426 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800419:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80041c:	89 c7                	mov    %eax,%edi
  80041e:	03 45 e0             	add    -0x20(%ebp),%eax
  800421:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800424:	eb 55                	jmp    80047b <vprintfmt+0x1e1>
  800426:	83 ec 08             	sub    $0x8,%esp
  800429:	ff 75 d8             	pushl  -0x28(%ebp)
  80042c:	ff 75 cc             	pushl  -0x34(%ebp)
  80042f:	e8 45 03 00 00       	call   800779 <strnlen>
  800434:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800437:	29 c2                	sub    %eax,%edx
  800439:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80043c:	83 c4 10             	add    $0x10,%esp
  80043f:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800441:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800445:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800448:	85 ff                	test   %edi,%edi
  80044a:	7e 11                	jle    80045d <vprintfmt+0x1c3>
					putch(padc, putdat);
  80044c:	83 ec 08             	sub    $0x8,%esp
  80044f:	53                   	push   %ebx
  800450:	ff 75 e0             	pushl  -0x20(%ebp)
  800453:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800455:	83 ef 01             	sub    $0x1,%edi
  800458:	83 c4 10             	add    $0x10,%esp
  80045b:	eb eb                	jmp    800448 <vprintfmt+0x1ae>
  80045d:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800460:	85 d2                	test   %edx,%edx
  800462:	b8 00 00 00 00       	mov    $0x0,%eax
  800467:	0f 49 c2             	cmovns %edx,%eax
  80046a:	29 c2                	sub    %eax,%edx
  80046c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80046f:	eb a8                	jmp    800419 <vprintfmt+0x17f>
					putch(ch, putdat);
  800471:	83 ec 08             	sub    $0x8,%esp
  800474:	53                   	push   %ebx
  800475:	52                   	push   %edx
  800476:	ff d6                	call   *%esi
  800478:	83 c4 10             	add    $0x10,%esp
  80047b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80047e:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800480:	83 c7 01             	add    $0x1,%edi
  800483:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800487:	0f be d0             	movsbl %al,%edx
  80048a:	85 d2                	test   %edx,%edx
  80048c:	74 4b                	je     8004d9 <vprintfmt+0x23f>
  80048e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800492:	78 06                	js     80049a <vprintfmt+0x200>
  800494:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800498:	78 1e                	js     8004b8 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80049a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80049e:	74 d1                	je     800471 <vprintfmt+0x1d7>
  8004a0:	0f be c0             	movsbl %al,%eax
  8004a3:	83 e8 20             	sub    $0x20,%eax
  8004a6:	83 f8 5e             	cmp    $0x5e,%eax
  8004a9:	76 c6                	jbe    800471 <vprintfmt+0x1d7>
					putch('?', putdat);
  8004ab:	83 ec 08             	sub    $0x8,%esp
  8004ae:	53                   	push   %ebx
  8004af:	6a 3f                	push   $0x3f
  8004b1:	ff d6                	call   *%esi
  8004b3:	83 c4 10             	add    $0x10,%esp
  8004b6:	eb c3                	jmp    80047b <vprintfmt+0x1e1>
  8004b8:	89 cf                	mov    %ecx,%edi
  8004ba:	eb 0e                	jmp    8004ca <vprintfmt+0x230>
				putch(' ', putdat);
  8004bc:	83 ec 08             	sub    $0x8,%esp
  8004bf:	53                   	push   %ebx
  8004c0:	6a 20                	push   $0x20
  8004c2:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004c4:	83 ef 01             	sub    $0x1,%edi
  8004c7:	83 c4 10             	add    $0x10,%esp
  8004ca:	85 ff                	test   %edi,%edi
  8004cc:	7f ee                	jg     8004bc <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8004ce:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004d1:	89 45 14             	mov    %eax,0x14(%ebp)
  8004d4:	e9 23 01 00 00       	jmp    8005fc <vprintfmt+0x362>
  8004d9:	89 cf                	mov    %ecx,%edi
  8004db:	eb ed                	jmp    8004ca <vprintfmt+0x230>
	if (lflag >= 2)
  8004dd:	83 f9 01             	cmp    $0x1,%ecx
  8004e0:	7f 1b                	jg     8004fd <vprintfmt+0x263>
	else if (lflag)
  8004e2:	85 c9                	test   %ecx,%ecx
  8004e4:	74 63                	je     800549 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8004e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e9:	8b 00                	mov    (%eax),%eax
  8004eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004ee:	99                   	cltd   
  8004ef:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f5:	8d 40 04             	lea    0x4(%eax),%eax
  8004f8:	89 45 14             	mov    %eax,0x14(%ebp)
  8004fb:	eb 17                	jmp    800514 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8004fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800500:	8b 50 04             	mov    0x4(%eax),%edx
  800503:	8b 00                	mov    (%eax),%eax
  800505:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800508:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80050b:	8b 45 14             	mov    0x14(%ebp),%eax
  80050e:	8d 40 08             	lea    0x8(%eax),%eax
  800511:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800514:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800517:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80051a:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80051f:	85 c9                	test   %ecx,%ecx
  800521:	0f 89 bb 00 00 00    	jns    8005e2 <vprintfmt+0x348>
				putch('-', putdat);
  800527:	83 ec 08             	sub    $0x8,%esp
  80052a:	53                   	push   %ebx
  80052b:	6a 2d                	push   $0x2d
  80052d:	ff d6                	call   *%esi
				num = -(long long) num;
  80052f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800532:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800535:	f7 da                	neg    %edx
  800537:	83 d1 00             	adc    $0x0,%ecx
  80053a:	f7 d9                	neg    %ecx
  80053c:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80053f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800544:	e9 99 00 00 00       	jmp    8005e2 <vprintfmt+0x348>
		return va_arg(*ap, int);
  800549:	8b 45 14             	mov    0x14(%ebp),%eax
  80054c:	8b 00                	mov    (%eax),%eax
  80054e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800551:	99                   	cltd   
  800552:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800555:	8b 45 14             	mov    0x14(%ebp),%eax
  800558:	8d 40 04             	lea    0x4(%eax),%eax
  80055b:	89 45 14             	mov    %eax,0x14(%ebp)
  80055e:	eb b4                	jmp    800514 <vprintfmt+0x27a>
	if (lflag >= 2)
  800560:	83 f9 01             	cmp    $0x1,%ecx
  800563:	7f 1b                	jg     800580 <vprintfmt+0x2e6>
	else if (lflag)
  800565:	85 c9                	test   %ecx,%ecx
  800567:	74 2c                	je     800595 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8b 10                	mov    (%eax),%edx
  80056e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800573:	8d 40 04             	lea    0x4(%eax),%eax
  800576:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800579:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80057e:	eb 62                	jmp    8005e2 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800580:	8b 45 14             	mov    0x14(%ebp),%eax
  800583:	8b 10                	mov    (%eax),%edx
  800585:	8b 48 04             	mov    0x4(%eax),%ecx
  800588:	8d 40 08             	lea    0x8(%eax),%eax
  80058b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80058e:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800593:	eb 4d                	jmp    8005e2 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	8b 10                	mov    (%eax),%edx
  80059a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80059f:	8d 40 04             	lea    0x4(%eax),%eax
  8005a2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005a5:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8005aa:	eb 36                	jmp    8005e2 <vprintfmt+0x348>
	if (lflag >= 2)
  8005ac:	83 f9 01             	cmp    $0x1,%ecx
  8005af:	7f 17                	jg     8005c8 <vprintfmt+0x32e>
	else if (lflag)
  8005b1:	85 c9                	test   %ecx,%ecx
  8005b3:	74 6e                	je     800623 <vprintfmt+0x389>
		return va_arg(*ap, long);
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8b 10                	mov    (%eax),%edx
  8005ba:	89 d0                	mov    %edx,%eax
  8005bc:	99                   	cltd   
  8005bd:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005c0:	8d 49 04             	lea    0x4(%ecx),%ecx
  8005c3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005c6:	eb 11                	jmp    8005d9 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8b 50 04             	mov    0x4(%eax),%edx
  8005ce:	8b 00                	mov    (%eax),%eax
  8005d0:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005d3:	8d 49 08             	lea    0x8(%ecx),%ecx
  8005d6:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8005d9:	89 d1                	mov    %edx,%ecx
  8005db:	89 c2                	mov    %eax,%edx
            base = 8;
  8005dd:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005e2:	83 ec 0c             	sub    $0xc,%esp
  8005e5:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005e9:	57                   	push   %edi
  8005ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8005ed:	50                   	push   %eax
  8005ee:	51                   	push   %ecx
  8005ef:	52                   	push   %edx
  8005f0:	89 da                	mov    %ebx,%edx
  8005f2:	89 f0                	mov    %esi,%eax
  8005f4:	e8 b6 fb ff ff       	call   8001af <printnum>
			break;
  8005f9:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8005fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005ff:	83 c7 01             	add    $0x1,%edi
  800602:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800606:	83 f8 25             	cmp    $0x25,%eax
  800609:	0f 84 a6 fc ff ff    	je     8002b5 <vprintfmt+0x1b>
			if (ch == '\0')
  80060f:	85 c0                	test   %eax,%eax
  800611:	0f 84 ce 00 00 00    	je     8006e5 <vprintfmt+0x44b>
			putch(ch, putdat);
  800617:	83 ec 08             	sub    $0x8,%esp
  80061a:	53                   	push   %ebx
  80061b:	50                   	push   %eax
  80061c:	ff d6                	call   *%esi
  80061e:	83 c4 10             	add    $0x10,%esp
  800621:	eb dc                	jmp    8005ff <vprintfmt+0x365>
		return va_arg(*ap, int);
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8b 10                	mov    (%eax),%edx
  800628:	89 d0                	mov    %edx,%eax
  80062a:	99                   	cltd   
  80062b:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80062e:	8d 49 04             	lea    0x4(%ecx),%ecx
  800631:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800634:	eb a3                	jmp    8005d9 <vprintfmt+0x33f>
			putch('0', putdat);
  800636:	83 ec 08             	sub    $0x8,%esp
  800639:	53                   	push   %ebx
  80063a:	6a 30                	push   $0x30
  80063c:	ff d6                	call   *%esi
			putch('x', putdat);
  80063e:	83 c4 08             	add    $0x8,%esp
  800641:	53                   	push   %ebx
  800642:	6a 78                	push   $0x78
  800644:	ff d6                	call   *%esi
			num = (unsigned long long)
  800646:	8b 45 14             	mov    0x14(%ebp),%eax
  800649:	8b 10                	mov    (%eax),%edx
  80064b:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800650:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800653:	8d 40 04             	lea    0x4(%eax),%eax
  800656:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800659:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80065e:	eb 82                	jmp    8005e2 <vprintfmt+0x348>
	if (lflag >= 2)
  800660:	83 f9 01             	cmp    $0x1,%ecx
  800663:	7f 1e                	jg     800683 <vprintfmt+0x3e9>
	else if (lflag)
  800665:	85 c9                	test   %ecx,%ecx
  800667:	74 32                	je     80069b <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800669:	8b 45 14             	mov    0x14(%ebp),%eax
  80066c:	8b 10                	mov    (%eax),%edx
  80066e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800673:	8d 40 04             	lea    0x4(%eax),%eax
  800676:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800679:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80067e:	e9 5f ff ff ff       	jmp    8005e2 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8b 10                	mov    (%eax),%edx
  800688:	8b 48 04             	mov    0x4(%eax),%ecx
  80068b:	8d 40 08             	lea    0x8(%eax),%eax
  80068e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800691:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800696:	e9 47 ff ff ff       	jmp    8005e2 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80069b:	8b 45 14             	mov    0x14(%ebp),%eax
  80069e:	8b 10                	mov    (%eax),%edx
  8006a0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a5:	8d 40 04             	lea    0x4(%eax),%eax
  8006a8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ab:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006b0:	e9 2d ff ff ff       	jmp    8005e2 <vprintfmt+0x348>
			putch(ch, putdat);
  8006b5:	83 ec 08             	sub    $0x8,%esp
  8006b8:	53                   	push   %ebx
  8006b9:	6a 25                	push   $0x25
  8006bb:	ff d6                	call   *%esi
			break;
  8006bd:	83 c4 10             	add    $0x10,%esp
  8006c0:	e9 37 ff ff ff       	jmp    8005fc <vprintfmt+0x362>
			putch('%', putdat);
  8006c5:	83 ec 08             	sub    $0x8,%esp
  8006c8:	53                   	push   %ebx
  8006c9:	6a 25                	push   $0x25
  8006cb:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006cd:	83 c4 10             	add    $0x10,%esp
  8006d0:	89 f8                	mov    %edi,%eax
  8006d2:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006d6:	74 05                	je     8006dd <vprintfmt+0x443>
  8006d8:	83 e8 01             	sub    $0x1,%eax
  8006db:	eb f5                	jmp    8006d2 <vprintfmt+0x438>
  8006dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006e0:	e9 17 ff ff ff       	jmp    8005fc <vprintfmt+0x362>
}
  8006e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006e8:	5b                   	pop    %ebx
  8006e9:	5e                   	pop    %esi
  8006ea:	5f                   	pop    %edi
  8006eb:	5d                   	pop    %ebp
  8006ec:	c3                   	ret    

008006ed <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ed:	f3 0f 1e fb          	endbr32 
  8006f1:	55                   	push   %ebp
  8006f2:	89 e5                	mov    %esp,%ebp
  8006f4:	83 ec 18             	sub    $0x18,%esp
  8006f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fa:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800700:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800704:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800707:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80070e:	85 c0                	test   %eax,%eax
  800710:	74 26                	je     800738 <vsnprintf+0x4b>
  800712:	85 d2                	test   %edx,%edx
  800714:	7e 22                	jle    800738 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800716:	ff 75 14             	pushl  0x14(%ebp)
  800719:	ff 75 10             	pushl  0x10(%ebp)
  80071c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80071f:	50                   	push   %eax
  800720:	68 58 02 80 00       	push   $0x800258
  800725:	e8 70 fb ff ff       	call   80029a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80072a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80072d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800730:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800733:	83 c4 10             	add    $0x10,%esp
}
  800736:	c9                   	leave  
  800737:	c3                   	ret    
		return -E_INVAL;
  800738:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80073d:	eb f7                	jmp    800736 <vsnprintf+0x49>

0080073f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80073f:	f3 0f 1e fb          	endbr32 
  800743:	55                   	push   %ebp
  800744:	89 e5                	mov    %esp,%ebp
  800746:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800749:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80074c:	50                   	push   %eax
  80074d:	ff 75 10             	pushl  0x10(%ebp)
  800750:	ff 75 0c             	pushl  0xc(%ebp)
  800753:	ff 75 08             	pushl  0x8(%ebp)
  800756:	e8 92 ff ff ff       	call   8006ed <vsnprintf>
	va_end(ap);

	return rc;
}
  80075b:	c9                   	leave  
  80075c:	c3                   	ret    

0080075d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80075d:	f3 0f 1e fb          	endbr32 
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800767:	b8 00 00 00 00       	mov    $0x0,%eax
  80076c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800770:	74 05                	je     800777 <strlen+0x1a>
		n++;
  800772:	83 c0 01             	add    $0x1,%eax
  800775:	eb f5                	jmp    80076c <strlen+0xf>
	return n;
}
  800777:	5d                   	pop    %ebp
  800778:	c3                   	ret    

00800779 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800779:	f3 0f 1e fb          	endbr32 
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800783:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800786:	b8 00 00 00 00       	mov    $0x0,%eax
  80078b:	39 d0                	cmp    %edx,%eax
  80078d:	74 0d                	je     80079c <strnlen+0x23>
  80078f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800793:	74 05                	je     80079a <strnlen+0x21>
		n++;
  800795:	83 c0 01             	add    $0x1,%eax
  800798:	eb f1                	jmp    80078b <strnlen+0x12>
  80079a:	89 c2                	mov    %eax,%edx
	return n;
}
  80079c:	89 d0                	mov    %edx,%eax
  80079e:	5d                   	pop    %ebp
  80079f:	c3                   	ret    

008007a0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007a0:	f3 0f 1e fb          	endbr32 
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
  8007a7:	53                   	push   %ebx
  8007a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b3:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007b7:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007ba:	83 c0 01             	add    $0x1,%eax
  8007bd:	84 d2                	test   %dl,%dl
  8007bf:	75 f2                	jne    8007b3 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8007c1:	89 c8                	mov    %ecx,%eax
  8007c3:	5b                   	pop    %ebx
  8007c4:	5d                   	pop    %ebp
  8007c5:	c3                   	ret    

008007c6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007c6:	f3 0f 1e fb          	endbr32 
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	53                   	push   %ebx
  8007ce:	83 ec 10             	sub    $0x10,%esp
  8007d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d4:	53                   	push   %ebx
  8007d5:	e8 83 ff ff ff       	call   80075d <strlen>
  8007da:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007dd:	ff 75 0c             	pushl  0xc(%ebp)
  8007e0:	01 d8                	add    %ebx,%eax
  8007e2:	50                   	push   %eax
  8007e3:	e8 b8 ff ff ff       	call   8007a0 <strcpy>
	return dst;
}
  8007e8:	89 d8                	mov    %ebx,%eax
  8007ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ed:	c9                   	leave  
  8007ee:	c3                   	ret    

008007ef <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ef:	f3 0f 1e fb          	endbr32 
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	56                   	push   %esi
  8007f7:	53                   	push   %ebx
  8007f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fe:	89 f3                	mov    %esi,%ebx
  800800:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800803:	89 f0                	mov    %esi,%eax
  800805:	39 d8                	cmp    %ebx,%eax
  800807:	74 11                	je     80081a <strncpy+0x2b>
		*dst++ = *src;
  800809:	83 c0 01             	add    $0x1,%eax
  80080c:	0f b6 0a             	movzbl (%edx),%ecx
  80080f:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800812:	80 f9 01             	cmp    $0x1,%cl
  800815:	83 da ff             	sbb    $0xffffffff,%edx
  800818:	eb eb                	jmp    800805 <strncpy+0x16>
	}
	return ret;
}
  80081a:	89 f0                	mov    %esi,%eax
  80081c:	5b                   	pop    %ebx
  80081d:	5e                   	pop    %esi
  80081e:	5d                   	pop    %ebp
  80081f:	c3                   	ret    

00800820 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800820:	f3 0f 1e fb          	endbr32 
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	56                   	push   %esi
  800828:	53                   	push   %ebx
  800829:	8b 75 08             	mov    0x8(%ebp),%esi
  80082c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80082f:	8b 55 10             	mov    0x10(%ebp),%edx
  800832:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800834:	85 d2                	test   %edx,%edx
  800836:	74 21                	je     800859 <strlcpy+0x39>
  800838:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80083c:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80083e:	39 c2                	cmp    %eax,%edx
  800840:	74 14                	je     800856 <strlcpy+0x36>
  800842:	0f b6 19             	movzbl (%ecx),%ebx
  800845:	84 db                	test   %bl,%bl
  800847:	74 0b                	je     800854 <strlcpy+0x34>
			*dst++ = *src++;
  800849:	83 c1 01             	add    $0x1,%ecx
  80084c:	83 c2 01             	add    $0x1,%edx
  80084f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800852:	eb ea                	jmp    80083e <strlcpy+0x1e>
  800854:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800856:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800859:	29 f0                	sub    %esi,%eax
}
  80085b:	5b                   	pop    %ebx
  80085c:	5e                   	pop    %esi
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80085f:	f3 0f 1e fb          	endbr32 
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800869:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80086c:	0f b6 01             	movzbl (%ecx),%eax
  80086f:	84 c0                	test   %al,%al
  800871:	74 0c                	je     80087f <strcmp+0x20>
  800873:	3a 02                	cmp    (%edx),%al
  800875:	75 08                	jne    80087f <strcmp+0x20>
		p++, q++;
  800877:	83 c1 01             	add    $0x1,%ecx
  80087a:	83 c2 01             	add    $0x1,%edx
  80087d:	eb ed                	jmp    80086c <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80087f:	0f b6 c0             	movzbl %al,%eax
  800882:	0f b6 12             	movzbl (%edx),%edx
  800885:	29 d0                	sub    %edx,%eax
}
  800887:	5d                   	pop    %ebp
  800888:	c3                   	ret    

00800889 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800889:	f3 0f 1e fb          	endbr32 
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	53                   	push   %ebx
  800891:	8b 45 08             	mov    0x8(%ebp),%eax
  800894:	8b 55 0c             	mov    0xc(%ebp),%edx
  800897:	89 c3                	mov    %eax,%ebx
  800899:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80089c:	eb 06                	jmp    8008a4 <strncmp+0x1b>
		n--, p++, q++;
  80089e:	83 c0 01             	add    $0x1,%eax
  8008a1:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008a4:	39 d8                	cmp    %ebx,%eax
  8008a6:	74 16                	je     8008be <strncmp+0x35>
  8008a8:	0f b6 08             	movzbl (%eax),%ecx
  8008ab:	84 c9                	test   %cl,%cl
  8008ad:	74 04                	je     8008b3 <strncmp+0x2a>
  8008af:	3a 0a                	cmp    (%edx),%cl
  8008b1:	74 eb                	je     80089e <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b3:	0f b6 00             	movzbl (%eax),%eax
  8008b6:	0f b6 12             	movzbl (%edx),%edx
  8008b9:	29 d0                	sub    %edx,%eax
}
  8008bb:	5b                   	pop    %ebx
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    
		return 0;
  8008be:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c3:	eb f6                	jmp    8008bb <strncmp+0x32>

008008c5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c5:	f3 0f 1e fb          	endbr32 
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d3:	0f b6 10             	movzbl (%eax),%edx
  8008d6:	84 d2                	test   %dl,%dl
  8008d8:	74 09                	je     8008e3 <strchr+0x1e>
		if (*s == c)
  8008da:	38 ca                	cmp    %cl,%dl
  8008dc:	74 0a                	je     8008e8 <strchr+0x23>
	for (; *s; s++)
  8008de:	83 c0 01             	add    $0x1,%eax
  8008e1:	eb f0                	jmp    8008d3 <strchr+0xe>
			return (char *) s;
	return 0;
  8008e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e8:	5d                   	pop    %ebp
  8008e9:	c3                   	ret    

008008ea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ea:	f3 0f 1e fb          	endbr32 
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008fb:	38 ca                	cmp    %cl,%dl
  8008fd:	74 09                	je     800908 <strfind+0x1e>
  8008ff:	84 d2                	test   %dl,%dl
  800901:	74 05                	je     800908 <strfind+0x1e>
	for (; *s; s++)
  800903:	83 c0 01             	add    $0x1,%eax
  800906:	eb f0                	jmp    8008f8 <strfind+0xe>
			break;
	return (char *) s;
}
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80090a:	f3 0f 1e fb          	endbr32 
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	57                   	push   %edi
  800912:	56                   	push   %esi
  800913:	53                   	push   %ebx
  800914:	8b 7d 08             	mov    0x8(%ebp),%edi
  800917:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80091a:	85 c9                	test   %ecx,%ecx
  80091c:	74 31                	je     80094f <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80091e:	89 f8                	mov    %edi,%eax
  800920:	09 c8                	or     %ecx,%eax
  800922:	a8 03                	test   $0x3,%al
  800924:	75 23                	jne    800949 <memset+0x3f>
		c &= 0xFF;
  800926:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80092a:	89 d3                	mov    %edx,%ebx
  80092c:	c1 e3 08             	shl    $0x8,%ebx
  80092f:	89 d0                	mov    %edx,%eax
  800931:	c1 e0 18             	shl    $0x18,%eax
  800934:	89 d6                	mov    %edx,%esi
  800936:	c1 e6 10             	shl    $0x10,%esi
  800939:	09 f0                	or     %esi,%eax
  80093b:	09 c2                	or     %eax,%edx
  80093d:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80093f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800942:	89 d0                	mov    %edx,%eax
  800944:	fc                   	cld    
  800945:	f3 ab                	rep stos %eax,%es:(%edi)
  800947:	eb 06                	jmp    80094f <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800949:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094c:	fc                   	cld    
  80094d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80094f:	89 f8                	mov    %edi,%eax
  800951:	5b                   	pop    %ebx
  800952:	5e                   	pop    %esi
  800953:	5f                   	pop    %edi
  800954:	5d                   	pop    %ebp
  800955:	c3                   	ret    

00800956 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800956:	f3 0f 1e fb          	endbr32 
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	57                   	push   %edi
  80095e:	56                   	push   %esi
  80095f:	8b 45 08             	mov    0x8(%ebp),%eax
  800962:	8b 75 0c             	mov    0xc(%ebp),%esi
  800965:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800968:	39 c6                	cmp    %eax,%esi
  80096a:	73 32                	jae    80099e <memmove+0x48>
  80096c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80096f:	39 c2                	cmp    %eax,%edx
  800971:	76 2b                	jbe    80099e <memmove+0x48>
		s += n;
		d += n;
  800973:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800976:	89 fe                	mov    %edi,%esi
  800978:	09 ce                	or     %ecx,%esi
  80097a:	09 d6                	or     %edx,%esi
  80097c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800982:	75 0e                	jne    800992 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800984:	83 ef 04             	sub    $0x4,%edi
  800987:	8d 72 fc             	lea    -0x4(%edx),%esi
  80098a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80098d:	fd                   	std    
  80098e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800990:	eb 09                	jmp    80099b <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800992:	83 ef 01             	sub    $0x1,%edi
  800995:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800998:	fd                   	std    
  800999:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80099b:	fc                   	cld    
  80099c:	eb 1a                	jmp    8009b8 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099e:	89 c2                	mov    %eax,%edx
  8009a0:	09 ca                	or     %ecx,%edx
  8009a2:	09 f2                	or     %esi,%edx
  8009a4:	f6 c2 03             	test   $0x3,%dl
  8009a7:	75 0a                	jne    8009b3 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009a9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009ac:	89 c7                	mov    %eax,%edi
  8009ae:	fc                   	cld    
  8009af:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b1:	eb 05                	jmp    8009b8 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8009b3:	89 c7                	mov    %eax,%edi
  8009b5:	fc                   	cld    
  8009b6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b8:	5e                   	pop    %esi
  8009b9:	5f                   	pop    %edi
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009bc:	f3 0f 1e fb          	endbr32 
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009c6:	ff 75 10             	pushl  0x10(%ebp)
  8009c9:	ff 75 0c             	pushl  0xc(%ebp)
  8009cc:	ff 75 08             	pushl  0x8(%ebp)
  8009cf:	e8 82 ff ff ff       	call   800956 <memmove>
}
  8009d4:	c9                   	leave  
  8009d5:	c3                   	ret    

008009d6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009d6:	f3 0f 1e fb          	endbr32 
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	56                   	push   %esi
  8009de:	53                   	push   %ebx
  8009df:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e5:	89 c6                	mov    %eax,%esi
  8009e7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ea:	39 f0                	cmp    %esi,%eax
  8009ec:	74 1c                	je     800a0a <memcmp+0x34>
		if (*s1 != *s2)
  8009ee:	0f b6 08             	movzbl (%eax),%ecx
  8009f1:	0f b6 1a             	movzbl (%edx),%ebx
  8009f4:	38 d9                	cmp    %bl,%cl
  8009f6:	75 08                	jne    800a00 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009f8:	83 c0 01             	add    $0x1,%eax
  8009fb:	83 c2 01             	add    $0x1,%edx
  8009fe:	eb ea                	jmp    8009ea <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a00:	0f b6 c1             	movzbl %cl,%eax
  800a03:	0f b6 db             	movzbl %bl,%ebx
  800a06:	29 d8                	sub    %ebx,%eax
  800a08:	eb 05                	jmp    800a0f <memcmp+0x39>
	}

	return 0;
  800a0a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0f:	5b                   	pop    %ebx
  800a10:	5e                   	pop    %esi
  800a11:	5d                   	pop    %ebp
  800a12:	c3                   	ret    

00800a13 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a13:	f3 0f 1e fb          	endbr32 
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a20:	89 c2                	mov    %eax,%edx
  800a22:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a25:	39 d0                	cmp    %edx,%eax
  800a27:	73 09                	jae    800a32 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a29:	38 08                	cmp    %cl,(%eax)
  800a2b:	74 05                	je     800a32 <memfind+0x1f>
	for (; s < ends; s++)
  800a2d:	83 c0 01             	add    $0x1,%eax
  800a30:	eb f3                	jmp    800a25 <memfind+0x12>
			break;
	return (void *) s;
}
  800a32:	5d                   	pop    %ebp
  800a33:	c3                   	ret    

00800a34 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a34:	f3 0f 1e fb          	endbr32 
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	57                   	push   %edi
  800a3c:	56                   	push   %esi
  800a3d:	53                   	push   %ebx
  800a3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a41:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a44:	eb 03                	jmp    800a49 <strtol+0x15>
		s++;
  800a46:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a49:	0f b6 01             	movzbl (%ecx),%eax
  800a4c:	3c 20                	cmp    $0x20,%al
  800a4e:	74 f6                	je     800a46 <strtol+0x12>
  800a50:	3c 09                	cmp    $0x9,%al
  800a52:	74 f2                	je     800a46 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a54:	3c 2b                	cmp    $0x2b,%al
  800a56:	74 2a                	je     800a82 <strtol+0x4e>
	int neg = 0;
  800a58:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a5d:	3c 2d                	cmp    $0x2d,%al
  800a5f:	74 2b                	je     800a8c <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a61:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a67:	75 0f                	jne    800a78 <strtol+0x44>
  800a69:	80 39 30             	cmpb   $0x30,(%ecx)
  800a6c:	74 28                	je     800a96 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a6e:	85 db                	test   %ebx,%ebx
  800a70:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a75:	0f 44 d8             	cmove  %eax,%ebx
  800a78:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a80:	eb 46                	jmp    800ac8 <strtol+0x94>
		s++;
  800a82:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a85:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8a:	eb d5                	jmp    800a61 <strtol+0x2d>
		s++, neg = 1;
  800a8c:	83 c1 01             	add    $0x1,%ecx
  800a8f:	bf 01 00 00 00       	mov    $0x1,%edi
  800a94:	eb cb                	jmp    800a61 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a96:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a9a:	74 0e                	je     800aaa <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a9c:	85 db                	test   %ebx,%ebx
  800a9e:	75 d8                	jne    800a78 <strtol+0x44>
		s++, base = 8;
  800aa0:	83 c1 01             	add    $0x1,%ecx
  800aa3:	bb 08 00 00 00       	mov    $0x8,%ebx
  800aa8:	eb ce                	jmp    800a78 <strtol+0x44>
		s += 2, base = 16;
  800aaa:	83 c1 02             	add    $0x2,%ecx
  800aad:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab2:	eb c4                	jmp    800a78 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ab4:	0f be d2             	movsbl %dl,%edx
  800ab7:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aba:	3b 55 10             	cmp    0x10(%ebp),%edx
  800abd:	7d 3a                	jge    800af9 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800abf:	83 c1 01             	add    $0x1,%ecx
  800ac2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ac6:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ac8:	0f b6 11             	movzbl (%ecx),%edx
  800acb:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ace:	89 f3                	mov    %esi,%ebx
  800ad0:	80 fb 09             	cmp    $0x9,%bl
  800ad3:	76 df                	jbe    800ab4 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800ad5:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ad8:	89 f3                	mov    %esi,%ebx
  800ada:	80 fb 19             	cmp    $0x19,%bl
  800add:	77 08                	ja     800ae7 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800adf:	0f be d2             	movsbl %dl,%edx
  800ae2:	83 ea 57             	sub    $0x57,%edx
  800ae5:	eb d3                	jmp    800aba <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800ae7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aea:	89 f3                	mov    %esi,%ebx
  800aec:	80 fb 19             	cmp    $0x19,%bl
  800aef:	77 08                	ja     800af9 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800af1:	0f be d2             	movsbl %dl,%edx
  800af4:	83 ea 37             	sub    $0x37,%edx
  800af7:	eb c1                	jmp    800aba <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800af9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800afd:	74 05                	je     800b04 <strtol+0xd0>
		*endptr = (char *) s;
  800aff:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b02:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b04:	89 c2                	mov    %eax,%edx
  800b06:	f7 da                	neg    %edx
  800b08:	85 ff                	test   %edi,%edi
  800b0a:	0f 45 c2             	cmovne %edx,%eax
}
  800b0d:	5b                   	pop    %ebx
  800b0e:	5e                   	pop    %esi
  800b0f:	5f                   	pop    %edi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b12:	f3 0f 1e fb          	endbr32 
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	57                   	push   %edi
  800b1a:	56                   	push   %esi
  800b1b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b21:	8b 55 08             	mov    0x8(%ebp),%edx
  800b24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b27:	89 c3                	mov    %eax,%ebx
  800b29:	89 c7                	mov    %eax,%edi
  800b2b:	89 c6                	mov    %eax,%esi
  800b2d:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b2f:	5b                   	pop    %ebx
  800b30:	5e                   	pop    %esi
  800b31:	5f                   	pop    %edi
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b34:	f3 0f 1e fb          	endbr32 
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	57                   	push   %edi
  800b3c:	56                   	push   %esi
  800b3d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b43:	b8 01 00 00 00       	mov    $0x1,%eax
  800b48:	89 d1                	mov    %edx,%ecx
  800b4a:	89 d3                	mov    %edx,%ebx
  800b4c:	89 d7                	mov    %edx,%edi
  800b4e:	89 d6                	mov    %edx,%esi
  800b50:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5f                   	pop    %edi
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b57:	f3 0f 1e fb          	endbr32 
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	57                   	push   %edi
  800b5f:	56                   	push   %esi
  800b60:	53                   	push   %ebx
  800b61:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b64:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b69:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6c:	b8 03 00 00 00       	mov    $0x3,%eax
  800b71:	89 cb                	mov    %ecx,%ebx
  800b73:	89 cf                	mov    %ecx,%edi
  800b75:	89 ce                	mov    %ecx,%esi
  800b77:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b79:	85 c0                	test   %eax,%eax
  800b7b:	7f 08                	jg     800b85 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5f                   	pop    %edi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b85:	83 ec 0c             	sub    $0xc,%esp
  800b88:	50                   	push   %eax
  800b89:	6a 03                	push   $0x3
  800b8b:	68 ff 22 80 00       	push   $0x8022ff
  800b90:	6a 23                	push   $0x23
  800b92:	68 1c 23 80 00       	push   $0x80231c
  800b97:	e8 42 10 00 00       	call   801bde <_panic>

00800b9c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b9c:	f3 0f 1e fb          	endbr32 
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	57                   	push   %edi
  800ba4:	56                   	push   %esi
  800ba5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ba6:	ba 00 00 00 00       	mov    $0x0,%edx
  800bab:	b8 02 00 00 00       	mov    $0x2,%eax
  800bb0:	89 d1                	mov    %edx,%ecx
  800bb2:	89 d3                	mov    %edx,%ebx
  800bb4:	89 d7                	mov    %edx,%edi
  800bb6:	89 d6                	mov    %edx,%esi
  800bb8:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bba:	5b                   	pop    %ebx
  800bbb:	5e                   	pop    %esi
  800bbc:	5f                   	pop    %edi
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    

00800bbf <sys_yield>:

void
sys_yield(void)
{
  800bbf:	f3 0f 1e fb          	endbr32 
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	57                   	push   %edi
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bc9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bce:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bd3:	89 d1                	mov    %edx,%ecx
  800bd5:	89 d3                	mov    %edx,%ebx
  800bd7:	89 d7                	mov    %edx,%edi
  800bd9:	89 d6                	mov    %edx,%esi
  800bdb:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800be2:	f3 0f 1e fb          	endbr32 
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	57                   	push   %edi
  800bea:	56                   	push   %esi
  800beb:	53                   	push   %ebx
  800bec:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bef:	be 00 00 00 00       	mov    $0x0,%esi
  800bf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfa:	b8 04 00 00 00       	mov    $0x4,%eax
  800bff:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c02:	89 f7                	mov    %esi,%edi
  800c04:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c06:	85 c0                	test   %eax,%eax
  800c08:	7f 08                	jg     800c12 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0d:	5b                   	pop    %ebx
  800c0e:	5e                   	pop    %esi
  800c0f:	5f                   	pop    %edi
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c12:	83 ec 0c             	sub    $0xc,%esp
  800c15:	50                   	push   %eax
  800c16:	6a 04                	push   $0x4
  800c18:	68 ff 22 80 00       	push   $0x8022ff
  800c1d:	6a 23                	push   $0x23
  800c1f:	68 1c 23 80 00       	push   $0x80231c
  800c24:	e8 b5 0f 00 00       	call   801bde <_panic>

00800c29 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c29:	f3 0f 1e fb          	endbr32 
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	57                   	push   %edi
  800c31:	56                   	push   %esi
  800c32:	53                   	push   %ebx
  800c33:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c36:	8b 55 08             	mov    0x8(%ebp),%edx
  800c39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3c:	b8 05 00 00 00       	mov    $0x5,%eax
  800c41:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c44:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c47:	8b 75 18             	mov    0x18(%ebp),%esi
  800c4a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c4c:	85 c0                	test   %eax,%eax
  800c4e:	7f 08                	jg     800c58 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c53:	5b                   	pop    %ebx
  800c54:	5e                   	pop    %esi
  800c55:	5f                   	pop    %edi
  800c56:	5d                   	pop    %ebp
  800c57:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c58:	83 ec 0c             	sub    $0xc,%esp
  800c5b:	50                   	push   %eax
  800c5c:	6a 05                	push   $0x5
  800c5e:	68 ff 22 80 00       	push   $0x8022ff
  800c63:	6a 23                	push   $0x23
  800c65:	68 1c 23 80 00       	push   $0x80231c
  800c6a:	e8 6f 0f 00 00       	call   801bde <_panic>

00800c6f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c6f:	f3 0f 1e fb          	endbr32 
  800c73:	55                   	push   %ebp
  800c74:	89 e5                	mov    %esp,%ebp
  800c76:	57                   	push   %edi
  800c77:	56                   	push   %esi
  800c78:	53                   	push   %ebx
  800c79:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c7c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c81:	8b 55 08             	mov    0x8(%ebp),%edx
  800c84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c87:	b8 06 00 00 00       	mov    $0x6,%eax
  800c8c:	89 df                	mov    %ebx,%edi
  800c8e:	89 de                	mov    %ebx,%esi
  800c90:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c92:	85 c0                	test   %eax,%eax
  800c94:	7f 08                	jg     800c9e <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c99:	5b                   	pop    %ebx
  800c9a:	5e                   	pop    %esi
  800c9b:	5f                   	pop    %edi
  800c9c:	5d                   	pop    %ebp
  800c9d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9e:	83 ec 0c             	sub    $0xc,%esp
  800ca1:	50                   	push   %eax
  800ca2:	6a 06                	push   $0x6
  800ca4:	68 ff 22 80 00       	push   $0x8022ff
  800ca9:	6a 23                	push   $0x23
  800cab:	68 1c 23 80 00       	push   $0x80231c
  800cb0:	e8 29 0f 00 00       	call   801bde <_panic>

00800cb5 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cb5:	f3 0f 1e fb          	endbr32 
  800cb9:	55                   	push   %ebp
  800cba:	89 e5                	mov    %esp,%ebp
  800cbc:	57                   	push   %edi
  800cbd:	56                   	push   %esi
  800cbe:	53                   	push   %ebx
  800cbf:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cc2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccd:	b8 08 00 00 00       	mov    $0x8,%eax
  800cd2:	89 df                	mov    %ebx,%edi
  800cd4:	89 de                	mov    %ebx,%esi
  800cd6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd8:	85 c0                	test   %eax,%eax
  800cda:	7f 08                	jg     800ce4 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce4:	83 ec 0c             	sub    $0xc,%esp
  800ce7:	50                   	push   %eax
  800ce8:	6a 08                	push   $0x8
  800cea:	68 ff 22 80 00       	push   $0x8022ff
  800cef:	6a 23                	push   $0x23
  800cf1:	68 1c 23 80 00       	push   $0x80231c
  800cf6:	e8 e3 0e 00 00       	call   801bde <_panic>

00800cfb <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cfb:	f3 0f 1e fb          	endbr32 
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	57                   	push   %edi
  800d03:	56                   	push   %esi
  800d04:	53                   	push   %ebx
  800d05:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d08:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d13:	b8 09 00 00 00       	mov    $0x9,%eax
  800d18:	89 df                	mov    %ebx,%edi
  800d1a:	89 de                	mov    %ebx,%esi
  800d1c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d1e:	85 c0                	test   %eax,%eax
  800d20:	7f 08                	jg     800d2a <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2a:	83 ec 0c             	sub    $0xc,%esp
  800d2d:	50                   	push   %eax
  800d2e:	6a 09                	push   $0x9
  800d30:	68 ff 22 80 00       	push   $0x8022ff
  800d35:	6a 23                	push   $0x23
  800d37:	68 1c 23 80 00       	push   $0x80231c
  800d3c:	e8 9d 0e 00 00       	call   801bde <_panic>

00800d41 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d41:	f3 0f 1e fb          	endbr32 
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	57                   	push   %edi
  800d49:	56                   	push   %esi
  800d4a:	53                   	push   %ebx
  800d4b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d53:	8b 55 08             	mov    0x8(%ebp),%edx
  800d56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d59:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d5e:	89 df                	mov    %ebx,%edi
  800d60:	89 de                	mov    %ebx,%esi
  800d62:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d64:	85 c0                	test   %eax,%eax
  800d66:	7f 08                	jg     800d70 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6b:	5b                   	pop    %ebx
  800d6c:	5e                   	pop    %esi
  800d6d:	5f                   	pop    %edi
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d70:	83 ec 0c             	sub    $0xc,%esp
  800d73:	50                   	push   %eax
  800d74:	6a 0a                	push   $0xa
  800d76:	68 ff 22 80 00       	push   $0x8022ff
  800d7b:	6a 23                	push   $0x23
  800d7d:	68 1c 23 80 00       	push   $0x80231c
  800d82:	e8 57 0e 00 00       	call   801bde <_panic>

00800d87 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d87:	f3 0f 1e fb          	endbr32 
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	57                   	push   %edi
  800d8f:	56                   	push   %esi
  800d90:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d91:	8b 55 08             	mov    0x8(%ebp),%edx
  800d94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d97:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d9c:	be 00 00 00 00       	mov    $0x0,%esi
  800da1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da7:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800da9:	5b                   	pop    %ebx
  800daa:	5e                   	pop    %esi
  800dab:	5f                   	pop    %edi
  800dac:	5d                   	pop    %ebp
  800dad:	c3                   	ret    

00800dae <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dae:	f3 0f 1e fb          	endbr32 
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	57                   	push   %edi
  800db6:	56                   	push   %esi
  800db7:	53                   	push   %ebx
  800db8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dbb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc3:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dc8:	89 cb                	mov    %ecx,%ebx
  800dca:	89 cf                	mov    %ecx,%edi
  800dcc:	89 ce                	mov    %ecx,%esi
  800dce:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dd0:	85 c0                	test   %eax,%eax
  800dd2:	7f 08                	jg     800ddc <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd7:	5b                   	pop    %ebx
  800dd8:	5e                   	pop    %esi
  800dd9:	5f                   	pop    %edi
  800dda:	5d                   	pop    %ebp
  800ddb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ddc:	83 ec 0c             	sub    $0xc,%esp
  800ddf:	50                   	push   %eax
  800de0:	6a 0d                	push   $0xd
  800de2:	68 ff 22 80 00       	push   $0x8022ff
  800de7:	6a 23                	push   $0x23
  800de9:	68 1c 23 80 00       	push   $0x80231c
  800dee:	e8 eb 0d 00 00       	call   801bde <_panic>

00800df3 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800df3:	f3 0f 1e fb          	endbr32 
  800df7:	55                   	push   %ebp
  800df8:	89 e5                	mov    %esp,%ebp
  800dfa:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800dfd:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800e04:	74 0a                	je     800e10 <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e06:	8b 45 08             	mov    0x8(%ebp),%eax
  800e09:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800e0e:	c9                   	leave  
  800e0f:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  800e10:	83 ec 0c             	sub    $0xc,%esp
  800e13:	68 2a 23 80 00       	push   $0x80232a
  800e18:	e8 7a f3 ff ff       	call   800197 <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  800e1d:	83 c4 0c             	add    $0xc,%esp
  800e20:	6a 07                	push   $0x7
  800e22:	68 00 f0 bf ee       	push   $0xeebff000
  800e27:	6a 00                	push   $0x0
  800e29:	e8 b4 fd ff ff       	call   800be2 <sys_page_alloc>
  800e2e:	83 c4 10             	add    $0x10,%esp
  800e31:	85 c0                	test   %eax,%eax
  800e33:	78 2a                	js     800e5f <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  800e35:	83 ec 08             	sub    $0x8,%esp
  800e38:	68 73 0e 80 00       	push   $0x800e73
  800e3d:	6a 00                	push   $0x0
  800e3f:	e8 fd fe ff ff       	call   800d41 <sys_env_set_pgfault_upcall>
  800e44:	83 c4 10             	add    $0x10,%esp
  800e47:	85 c0                	test   %eax,%eax
  800e49:	79 bb                	jns    800e06 <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  800e4b:	83 ec 04             	sub    $0x4,%esp
  800e4e:	68 68 23 80 00       	push   $0x802368
  800e53:	6a 25                	push   $0x25
  800e55:	68 57 23 80 00       	push   $0x802357
  800e5a:	e8 7f 0d 00 00       	call   801bde <_panic>
            panic("Allocation of UXSTACK failed!");
  800e5f:	83 ec 04             	sub    $0x4,%esp
  800e62:	68 39 23 80 00       	push   $0x802339
  800e67:	6a 22                	push   $0x22
  800e69:	68 57 23 80 00       	push   $0x802357
  800e6e:	e8 6b 0d 00 00       	call   801bde <_panic>

00800e73 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e73:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e74:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800e79:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e7b:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  800e7e:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  800e82:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  800e86:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  800e89:	83 c4 08             	add    $0x8,%esp
    popa
  800e8c:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

    add $0x4, %esp
  800e8d:	83 c4 04             	add    $0x4,%esp
    popf
  800e90:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  800e91:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  800e94:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  800e98:	c3                   	ret    

00800e99 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e99:	f3 0f 1e fb          	endbr32 
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ea0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea3:	05 00 00 00 30       	add    $0x30000000,%eax
  800ea8:	c1 e8 0c             	shr    $0xc,%eax
}
  800eab:	5d                   	pop    %ebp
  800eac:	c3                   	ret    

00800ead <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ead:	f3 0f 1e fb          	endbr32 
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb7:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800ebc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ec1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ec6:	5d                   	pop    %ebp
  800ec7:	c3                   	ret    

00800ec8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ec8:	f3 0f 1e fb          	endbr32 
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ed4:	89 c2                	mov    %eax,%edx
  800ed6:	c1 ea 16             	shr    $0x16,%edx
  800ed9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ee0:	f6 c2 01             	test   $0x1,%dl
  800ee3:	74 2d                	je     800f12 <fd_alloc+0x4a>
  800ee5:	89 c2                	mov    %eax,%edx
  800ee7:	c1 ea 0c             	shr    $0xc,%edx
  800eea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ef1:	f6 c2 01             	test   $0x1,%dl
  800ef4:	74 1c                	je     800f12 <fd_alloc+0x4a>
  800ef6:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800efb:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f00:	75 d2                	jne    800ed4 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f02:	8b 45 08             	mov    0x8(%ebp),%eax
  800f05:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800f0b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800f10:	eb 0a                	jmp    800f1c <fd_alloc+0x54>
			*fd_store = fd;
  800f12:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f15:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f17:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f1c:	5d                   	pop    %ebp
  800f1d:	c3                   	ret    

00800f1e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f1e:	f3 0f 1e fb          	endbr32 
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f28:	83 f8 1f             	cmp    $0x1f,%eax
  800f2b:	77 30                	ja     800f5d <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f2d:	c1 e0 0c             	shl    $0xc,%eax
  800f30:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f35:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800f3b:	f6 c2 01             	test   $0x1,%dl
  800f3e:	74 24                	je     800f64 <fd_lookup+0x46>
  800f40:	89 c2                	mov    %eax,%edx
  800f42:	c1 ea 0c             	shr    $0xc,%edx
  800f45:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f4c:	f6 c2 01             	test   $0x1,%dl
  800f4f:	74 1a                	je     800f6b <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f51:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f54:	89 02                	mov    %eax,(%edx)
	return 0;
  800f56:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f5b:	5d                   	pop    %ebp
  800f5c:	c3                   	ret    
		return -E_INVAL;
  800f5d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f62:	eb f7                	jmp    800f5b <fd_lookup+0x3d>
		return -E_INVAL;
  800f64:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f69:	eb f0                	jmp    800f5b <fd_lookup+0x3d>
  800f6b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f70:	eb e9                	jmp    800f5b <fd_lookup+0x3d>

00800f72 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f72:	f3 0f 1e fb          	endbr32 
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
  800f79:	83 ec 08             	sub    $0x8,%esp
  800f7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f7f:	ba 08 24 80 00       	mov    $0x802408,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f84:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800f89:	39 08                	cmp    %ecx,(%eax)
  800f8b:	74 33                	je     800fc0 <dev_lookup+0x4e>
  800f8d:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800f90:	8b 02                	mov    (%edx),%eax
  800f92:	85 c0                	test   %eax,%eax
  800f94:	75 f3                	jne    800f89 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f96:	a1 04 40 80 00       	mov    0x804004,%eax
  800f9b:	8b 40 48             	mov    0x48(%eax),%eax
  800f9e:	83 ec 04             	sub    $0x4,%esp
  800fa1:	51                   	push   %ecx
  800fa2:	50                   	push   %eax
  800fa3:	68 8c 23 80 00       	push   $0x80238c
  800fa8:	e8 ea f1 ff ff       	call   800197 <cprintf>
	*dev = 0;
  800fad:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fb0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fb6:	83 c4 10             	add    $0x10,%esp
  800fb9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fbe:	c9                   	leave  
  800fbf:	c3                   	ret    
			*dev = devtab[i];
  800fc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc3:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fc5:	b8 00 00 00 00       	mov    $0x0,%eax
  800fca:	eb f2                	jmp    800fbe <dev_lookup+0x4c>

00800fcc <fd_close>:
{
  800fcc:	f3 0f 1e fb          	endbr32 
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  800fd3:	57                   	push   %edi
  800fd4:	56                   	push   %esi
  800fd5:	53                   	push   %ebx
  800fd6:	83 ec 24             	sub    $0x24,%esp
  800fd9:	8b 75 08             	mov    0x8(%ebp),%esi
  800fdc:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fdf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fe2:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fe3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fe9:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fec:	50                   	push   %eax
  800fed:	e8 2c ff ff ff       	call   800f1e <fd_lookup>
  800ff2:	89 c3                	mov    %eax,%ebx
  800ff4:	83 c4 10             	add    $0x10,%esp
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	78 05                	js     801000 <fd_close+0x34>
	    || fd != fd2)
  800ffb:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800ffe:	74 16                	je     801016 <fd_close+0x4a>
		return (must_exist ? r : 0);
  801000:	89 f8                	mov    %edi,%eax
  801002:	84 c0                	test   %al,%al
  801004:	b8 00 00 00 00       	mov    $0x0,%eax
  801009:	0f 44 d8             	cmove  %eax,%ebx
}
  80100c:	89 d8                	mov    %ebx,%eax
  80100e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801011:	5b                   	pop    %ebx
  801012:	5e                   	pop    %esi
  801013:	5f                   	pop    %edi
  801014:	5d                   	pop    %ebp
  801015:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801016:	83 ec 08             	sub    $0x8,%esp
  801019:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80101c:	50                   	push   %eax
  80101d:	ff 36                	pushl  (%esi)
  80101f:	e8 4e ff ff ff       	call   800f72 <dev_lookup>
  801024:	89 c3                	mov    %eax,%ebx
  801026:	83 c4 10             	add    $0x10,%esp
  801029:	85 c0                	test   %eax,%eax
  80102b:	78 1a                	js     801047 <fd_close+0x7b>
		if (dev->dev_close)
  80102d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801030:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801033:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801038:	85 c0                	test   %eax,%eax
  80103a:	74 0b                	je     801047 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  80103c:	83 ec 0c             	sub    $0xc,%esp
  80103f:	56                   	push   %esi
  801040:	ff d0                	call   *%eax
  801042:	89 c3                	mov    %eax,%ebx
  801044:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801047:	83 ec 08             	sub    $0x8,%esp
  80104a:	56                   	push   %esi
  80104b:	6a 00                	push   $0x0
  80104d:	e8 1d fc ff ff       	call   800c6f <sys_page_unmap>
	return r;
  801052:	83 c4 10             	add    $0x10,%esp
  801055:	eb b5                	jmp    80100c <fd_close+0x40>

00801057 <close>:

int
close(int fdnum)
{
  801057:	f3 0f 1e fb          	endbr32 
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801061:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801064:	50                   	push   %eax
  801065:	ff 75 08             	pushl  0x8(%ebp)
  801068:	e8 b1 fe ff ff       	call   800f1e <fd_lookup>
  80106d:	83 c4 10             	add    $0x10,%esp
  801070:	85 c0                	test   %eax,%eax
  801072:	79 02                	jns    801076 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801074:	c9                   	leave  
  801075:	c3                   	ret    
		return fd_close(fd, 1);
  801076:	83 ec 08             	sub    $0x8,%esp
  801079:	6a 01                	push   $0x1
  80107b:	ff 75 f4             	pushl  -0xc(%ebp)
  80107e:	e8 49 ff ff ff       	call   800fcc <fd_close>
  801083:	83 c4 10             	add    $0x10,%esp
  801086:	eb ec                	jmp    801074 <close+0x1d>

00801088 <close_all>:

void
close_all(void)
{
  801088:	f3 0f 1e fb          	endbr32 
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	53                   	push   %ebx
  801090:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801093:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801098:	83 ec 0c             	sub    $0xc,%esp
  80109b:	53                   	push   %ebx
  80109c:	e8 b6 ff ff ff       	call   801057 <close>
	for (i = 0; i < MAXFD; i++)
  8010a1:	83 c3 01             	add    $0x1,%ebx
  8010a4:	83 c4 10             	add    $0x10,%esp
  8010a7:	83 fb 20             	cmp    $0x20,%ebx
  8010aa:	75 ec                	jne    801098 <close_all+0x10>
}
  8010ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010af:	c9                   	leave  
  8010b0:	c3                   	ret    

008010b1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010b1:	f3 0f 1e fb          	endbr32 
  8010b5:	55                   	push   %ebp
  8010b6:	89 e5                	mov    %esp,%ebp
  8010b8:	57                   	push   %edi
  8010b9:	56                   	push   %esi
  8010ba:	53                   	push   %ebx
  8010bb:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010be:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010c1:	50                   	push   %eax
  8010c2:	ff 75 08             	pushl  0x8(%ebp)
  8010c5:	e8 54 fe ff ff       	call   800f1e <fd_lookup>
  8010ca:	89 c3                	mov    %eax,%ebx
  8010cc:	83 c4 10             	add    $0x10,%esp
  8010cf:	85 c0                	test   %eax,%eax
  8010d1:	0f 88 81 00 00 00    	js     801158 <dup+0xa7>
		return r;
	close(newfdnum);
  8010d7:	83 ec 0c             	sub    $0xc,%esp
  8010da:	ff 75 0c             	pushl  0xc(%ebp)
  8010dd:	e8 75 ff ff ff       	call   801057 <close>

	newfd = INDEX2FD(newfdnum);
  8010e2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010e5:	c1 e6 0c             	shl    $0xc,%esi
  8010e8:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8010ee:	83 c4 04             	add    $0x4,%esp
  8010f1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010f4:	e8 b4 fd ff ff       	call   800ead <fd2data>
  8010f9:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010fb:	89 34 24             	mov    %esi,(%esp)
  8010fe:	e8 aa fd ff ff       	call   800ead <fd2data>
  801103:	83 c4 10             	add    $0x10,%esp
  801106:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801108:	89 d8                	mov    %ebx,%eax
  80110a:	c1 e8 16             	shr    $0x16,%eax
  80110d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801114:	a8 01                	test   $0x1,%al
  801116:	74 11                	je     801129 <dup+0x78>
  801118:	89 d8                	mov    %ebx,%eax
  80111a:	c1 e8 0c             	shr    $0xc,%eax
  80111d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801124:	f6 c2 01             	test   $0x1,%dl
  801127:	75 39                	jne    801162 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801129:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80112c:	89 d0                	mov    %edx,%eax
  80112e:	c1 e8 0c             	shr    $0xc,%eax
  801131:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801138:	83 ec 0c             	sub    $0xc,%esp
  80113b:	25 07 0e 00 00       	and    $0xe07,%eax
  801140:	50                   	push   %eax
  801141:	56                   	push   %esi
  801142:	6a 00                	push   $0x0
  801144:	52                   	push   %edx
  801145:	6a 00                	push   $0x0
  801147:	e8 dd fa ff ff       	call   800c29 <sys_page_map>
  80114c:	89 c3                	mov    %eax,%ebx
  80114e:	83 c4 20             	add    $0x20,%esp
  801151:	85 c0                	test   %eax,%eax
  801153:	78 31                	js     801186 <dup+0xd5>
		goto err;

	return newfdnum;
  801155:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801158:	89 d8                	mov    %ebx,%eax
  80115a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115d:	5b                   	pop    %ebx
  80115e:	5e                   	pop    %esi
  80115f:	5f                   	pop    %edi
  801160:	5d                   	pop    %ebp
  801161:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801162:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801169:	83 ec 0c             	sub    $0xc,%esp
  80116c:	25 07 0e 00 00       	and    $0xe07,%eax
  801171:	50                   	push   %eax
  801172:	57                   	push   %edi
  801173:	6a 00                	push   $0x0
  801175:	53                   	push   %ebx
  801176:	6a 00                	push   $0x0
  801178:	e8 ac fa ff ff       	call   800c29 <sys_page_map>
  80117d:	89 c3                	mov    %eax,%ebx
  80117f:	83 c4 20             	add    $0x20,%esp
  801182:	85 c0                	test   %eax,%eax
  801184:	79 a3                	jns    801129 <dup+0x78>
	sys_page_unmap(0, newfd);
  801186:	83 ec 08             	sub    $0x8,%esp
  801189:	56                   	push   %esi
  80118a:	6a 00                	push   $0x0
  80118c:	e8 de fa ff ff       	call   800c6f <sys_page_unmap>
	sys_page_unmap(0, nva);
  801191:	83 c4 08             	add    $0x8,%esp
  801194:	57                   	push   %edi
  801195:	6a 00                	push   $0x0
  801197:	e8 d3 fa ff ff       	call   800c6f <sys_page_unmap>
	return r;
  80119c:	83 c4 10             	add    $0x10,%esp
  80119f:	eb b7                	jmp    801158 <dup+0xa7>

008011a1 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011a1:	f3 0f 1e fb          	endbr32 
  8011a5:	55                   	push   %ebp
  8011a6:	89 e5                	mov    %esp,%ebp
  8011a8:	53                   	push   %ebx
  8011a9:	83 ec 1c             	sub    $0x1c,%esp
  8011ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b2:	50                   	push   %eax
  8011b3:	53                   	push   %ebx
  8011b4:	e8 65 fd ff ff       	call   800f1e <fd_lookup>
  8011b9:	83 c4 10             	add    $0x10,%esp
  8011bc:	85 c0                	test   %eax,%eax
  8011be:	78 3f                	js     8011ff <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c0:	83 ec 08             	sub    $0x8,%esp
  8011c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c6:	50                   	push   %eax
  8011c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ca:	ff 30                	pushl  (%eax)
  8011cc:	e8 a1 fd ff ff       	call   800f72 <dev_lookup>
  8011d1:	83 c4 10             	add    $0x10,%esp
  8011d4:	85 c0                	test   %eax,%eax
  8011d6:	78 27                	js     8011ff <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011db:	8b 42 08             	mov    0x8(%edx),%eax
  8011de:	83 e0 03             	and    $0x3,%eax
  8011e1:	83 f8 01             	cmp    $0x1,%eax
  8011e4:	74 1e                	je     801204 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8011e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011e9:	8b 40 08             	mov    0x8(%eax),%eax
  8011ec:	85 c0                	test   %eax,%eax
  8011ee:	74 35                	je     801225 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011f0:	83 ec 04             	sub    $0x4,%esp
  8011f3:	ff 75 10             	pushl  0x10(%ebp)
  8011f6:	ff 75 0c             	pushl  0xc(%ebp)
  8011f9:	52                   	push   %edx
  8011fa:	ff d0                	call   *%eax
  8011fc:	83 c4 10             	add    $0x10,%esp
}
  8011ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801202:	c9                   	leave  
  801203:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801204:	a1 04 40 80 00       	mov    0x804004,%eax
  801209:	8b 40 48             	mov    0x48(%eax),%eax
  80120c:	83 ec 04             	sub    $0x4,%esp
  80120f:	53                   	push   %ebx
  801210:	50                   	push   %eax
  801211:	68 cd 23 80 00       	push   $0x8023cd
  801216:	e8 7c ef ff ff       	call   800197 <cprintf>
		return -E_INVAL;
  80121b:	83 c4 10             	add    $0x10,%esp
  80121e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801223:	eb da                	jmp    8011ff <read+0x5e>
		return -E_NOT_SUPP;
  801225:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80122a:	eb d3                	jmp    8011ff <read+0x5e>

0080122c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80122c:	f3 0f 1e fb          	endbr32 
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	57                   	push   %edi
  801234:	56                   	push   %esi
  801235:	53                   	push   %ebx
  801236:	83 ec 0c             	sub    $0xc,%esp
  801239:	8b 7d 08             	mov    0x8(%ebp),%edi
  80123c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80123f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801244:	eb 02                	jmp    801248 <readn+0x1c>
  801246:	01 c3                	add    %eax,%ebx
  801248:	39 f3                	cmp    %esi,%ebx
  80124a:	73 21                	jae    80126d <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80124c:	83 ec 04             	sub    $0x4,%esp
  80124f:	89 f0                	mov    %esi,%eax
  801251:	29 d8                	sub    %ebx,%eax
  801253:	50                   	push   %eax
  801254:	89 d8                	mov    %ebx,%eax
  801256:	03 45 0c             	add    0xc(%ebp),%eax
  801259:	50                   	push   %eax
  80125a:	57                   	push   %edi
  80125b:	e8 41 ff ff ff       	call   8011a1 <read>
		if (m < 0)
  801260:	83 c4 10             	add    $0x10,%esp
  801263:	85 c0                	test   %eax,%eax
  801265:	78 04                	js     80126b <readn+0x3f>
			return m;
		if (m == 0)
  801267:	75 dd                	jne    801246 <readn+0x1a>
  801269:	eb 02                	jmp    80126d <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80126b:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80126d:	89 d8                	mov    %ebx,%eax
  80126f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801272:	5b                   	pop    %ebx
  801273:	5e                   	pop    %esi
  801274:	5f                   	pop    %edi
  801275:	5d                   	pop    %ebp
  801276:	c3                   	ret    

00801277 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801277:	f3 0f 1e fb          	endbr32 
  80127b:	55                   	push   %ebp
  80127c:	89 e5                	mov    %esp,%ebp
  80127e:	53                   	push   %ebx
  80127f:	83 ec 1c             	sub    $0x1c,%esp
  801282:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801285:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801288:	50                   	push   %eax
  801289:	53                   	push   %ebx
  80128a:	e8 8f fc ff ff       	call   800f1e <fd_lookup>
  80128f:	83 c4 10             	add    $0x10,%esp
  801292:	85 c0                	test   %eax,%eax
  801294:	78 3a                	js     8012d0 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801296:	83 ec 08             	sub    $0x8,%esp
  801299:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129c:	50                   	push   %eax
  80129d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a0:	ff 30                	pushl  (%eax)
  8012a2:	e8 cb fc ff ff       	call   800f72 <dev_lookup>
  8012a7:	83 c4 10             	add    $0x10,%esp
  8012aa:	85 c0                	test   %eax,%eax
  8012ac:	78 22                	js     8012d0 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012b5:	74 1e                	je     8012d5 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012ba:	8b 52 0c             	mov    0xc(%edx),%edx
  8012bd:	85 d2                	test   %edx,%edx
  8012bf:	74 35                	je     8012f6 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012c1:	83 ec 04             	sub    $0x4,%esp
  8012c4:	ff 75 10             	pushl  0x10(%ebp)
  8012c7:	ff 75 0c             	pushl  0xc(%ebp)
  8012ca:	50                   	push   %eax
  8012cb:	ff d2                	call   *%edx
  8012cd:	83 c4 10             	add    $0x10,%esp
}
  8012d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d3:	c9                   	leave  
  8012d4:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012d5:	a1 04 40 80 00       	mov    0x804004,%eax
  8012da:	8b 40 48             	mov    0x48(%eax),%eax
  8012dd:	83 ec 04             	sub    $0x4,%esp
  8012e0:	53                   	push   %ebx
  8012e1:	50                   	push   %eax
  8012e2:	68 e9 23 80 00       	push   $0x8023e9
  8012e7:	e8 ab ee ff ff       	call   800197 <cprintf>
		return -E_INVAL;
  8012ec:	83 c4 10             	add    $0x10,%esp
  8012ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012f4:	eb da                	jmp    8012d0 <write+0x59>
		return -E_NOT_SUPP;
  8012f6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012fb:	eb d3                	jmp    8012d0 <write+0x59>

008012fd <seek>:

int
seek(int fdnum, off_t offset)
{
  8012fd:	f3 0f 1e fb          	endbr32 
  801301:	55                   	push   %ebp
  801302:	89 e5                	mov    %esp,%ebp
  801304:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801307:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130a:	50                   	push   %eax
  80130b:	ff 75 08             	pushl  0x8(%ebp)
  80130e:	e8 0b fc ff ff       	call   800f1e <fd_lookup>
  801313:	83 c4 10             	add    $0x10,%esp
  801316:	85 c0                	test   %eax,%eax
  801318:	78 0e                	js     801328 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80131a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80131d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801320:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801323:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801328:	c9                   	leave  
  801329:	c3                   	ret    

0080132a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80132a:	f3 0f 1e fb          	endbr32 
  80132e:	55                   	push   %ebp
  80132f:	89 e5                	mov    %esp,%ebp
  801331:	53                   	push   %ebx
  801332:	83 ec 1c             	sub    $0x1c,%esp
  801335:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801338:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80133b:	50                   	push   %eax
  80133c:	53                   	push   %ebx
  80133d:	e8 dc fb ff ff       	call   800f1e <fd_lookup>
  801342:	83 c4 10             	add    $0x10,%esp
  801345:	85 c0                	test   %eax,%eax
  801347:	78 37                	js     801380 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801349:	83 ec 08             	sub    $0x8,%esp
  80134c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134f:	50                   	push   %eax
  801350:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801353:	ff 30                	pushl  (%eax)
  801355:	e8 18 fc ff ff       	call   800f72 <dev_lookup>
  80135a:	83 c4 10             	add    $0x10,%esp
  80135d:	85 c0                	test   %eax,%eax
  80135f:	78 1f                	js     801380 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801361:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801364:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801368:	74 1b                	je     801385 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80136a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80136d:	8b 52 18             	mov    0x18(%edx),%edx
  801370:	85 d2                	test   %edx,%edx
  801372:	74 32                	je     8013a6 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801374:	83 ec 08             	sub    $0x8,%esp
  801377:	ff 75 0c             	pushl  0xc(%ebp)
  80137a:	50                   	push   %eax
  80137b:	ff d2                	call   *%edx
  80137d:	83 c4 10             	add    $0x10,%esp
}
  801380:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801383:	c9                   	leave  
  801384:	c3                   	ret    
			thisenv->env_id, fdnum);
  801385:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80138a:	8b 40 48             	mov    0x48(%eax),%eax
  80138d:	83 ec 04             	sub    $0x4,%esp
  801390:	53                   	push   %ebx
  801391:	50                   	push   %eax
  801392:	68 ac 23 80 00       	push   $0x8023ac
  801397:	e8 fb ed ff ff       	call   800197 <cprintf>
		return -E_INVAL;
  80139c:	83 c4 10             	add    $0x10,%esp
  80139f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013a4:	eb da                	jmp    801380 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8013a6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013ab:	eb d3                	jmp    801380 <ftruncate+0x56>

008013ad <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013ad:	f3 0f 1e fb          	endbr32 
  8013b1:	55                   	push   %ebp
  8013b2:	89 e5                	mov    %esp,%ebp
  8013b4:	53                   	push   %ebx
  8013b5:	83 ec 1c             	sub    $0x1c,%esp
  8013b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013be:	50                   	push   %eax
  8013bf:	ff 75 08             	pushl  0x8(%ebp)
  8013c2:	e8 57 fb ff ff       	call   800f1e <fd_lookup>
  8013c7:	83 c4 10             	add    $0x10,%esp
  8013ca:	85 c0                	test   %eax,%eax
  8013cc:	78 4b                	js     801419 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ce:	83 ec 08             	sub    $0x8,%esp
  8013d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d4:	50                   	push   %eax
  8013d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d8:	ff 30                	pushl  (%eax)
  8013da:	e8 93 fb ff ff       	call   800f72 <dev_lookup>
  8013df:	83 c4 10             	add    $0x10,%esp
  8013e2:	85 c0                	test   %eax,%eax
  8013e4:	78 33                	js     801419 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8013e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013e9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013ed:	74 2f                	je     80141e <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013ef:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013f2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013f9:	00 00 00 
	stat->st_isdir = 0;
  8013fc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801403:	00 00 00 
	stat->st_dev = dev;
  801406:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80140c:	83 ec 08             	sub    $0x8,%esp
  80140f:	53                   	push   %ebx
  801410:	ff 75 f0             	pushl  -0x10(%ebp)
  801413:	ff 50 14             	call   *0x14(%eax)
  801416:	83 c4 10             	add    $0x10,%esp
}
  801419:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80141c:	c9                   	leave  
  80141d:	c3                   	ret    
		return -E_NOT_SUPP;
  80141e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801423:	eb f4                	jmp    801419 <fstat+0x6c>

00801425 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801425:	f3 0f 1e fb          	endbr32 
  801429:	55                   	push   %ebp
  80142a:	89 e5                	mov    %esp,%ebp
  80142c:	56                   	push   %esi
  80142d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80142e:	83 ec 08             	sub    $0x8,%esp
  801431:	6a 00                	push   $0x0
  801433:	ff 75 08             	pushl  0x8(%ebp)
  801436:	e8 fb 01 00 00       	call   801636 <open>
  80143b:	89 c3                	mov    %eax,%ebx
  80143d:	83 c4 10             	add    $0x10,%esp
  801440:	85 c0                	test   %eax,%eax
  801442:	78 1b                	js     80145f <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801444:	83 ec 08             	sub    $0x8,%esp
  801447:	ff 75 0c             	pushl  0xc(%ebp)
  80144a:	50                   	push   %eax
  80144b:	e8 5d ff ff ff       	call   8013ad <fstat>
  801450:	89 c6                	mov    %eax,%esi
	close(fd);
  801452:	89 1c 24             	mov    %ebx,(%esp)
  801455:	e8 fd fb ff ff       	call   801057 <close>
	return r;
  80145a:	83 c4 10             	add    $0x10,%esp
  80145d:	89 f3                	mov    %esi,%ebx
}
  80145f:	89 d8                	mov    %ebx,%eax
  801461:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801464:	5b                   	pop    %ebx
  801465:	5e                   	pop    %esi
  801466:	5d                   	pop    %ebp
  801467:	c3                   	ret    

00801468 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801468:	55                   	push   %ebp
  801469:	89 e5                	mov    %esp,%ebp
  80146b:	56                   	push   %esi
  80146c:	53                   	push   %ebx
  80146d:	89 c6                	mov    %eax,%esi
  80146f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801471:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801478:	74 27                	je     8014a1 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80147a:	6a 07                	push   $0x7
  80147c:	68 00 50 80 00       	push   $0x805000
  801481:	56                   	push   %esi
  801482:	ff 35 00 40 80 00    	pushl  0x804000
  801488:	e8 f2 07 00 00       	call   801c7f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80148d:	83 c4 0c             	add    $0xc,%esp
  801490:	6a 00                	push   $0x0
  801492:	53                   	push   %ebx
  801493:	6a 00                	push   $0x0
  801495:	e8 8e 07 00 00       	call   801c28 <ipc_recv>
}
  80149a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80149d:	5b                   	pop    %ebx
  80149e:	5e                   	pop    %esi
  80149f:	5d                   	pop    %ebp
  8014a0:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014a1:	83 ec 0c             	sub    $0xc,%esp
  8014a4:	6a 01                	push   $0x1
  8014a6:	e8 3a 08 00 00       	call   801ce5 <ipc_find_env>
  8014ab:	a3 00 40 80 00       	mov    %eax,0x804000
  8014b0:	83 c4 10             	add    $0x10,%esp
  8014b3:	eb c5                	jmp    80147a <fsipc+0x12>

008014b5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014b5:	f3 0f 1e fb          	endbr32 
  8014b9:	55                   	push   %ebp
  8014ba:	89 e5                	mov    %esp,%ebp
  8014bc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c2:	8b 40 0c             	mov    0xc(%eax),%eax
  8014c5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014cd:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d7:	b8 02 00 00 00       	mov    $0x2,%eax
  8014dc:	e8 87 ff ff ff       	call   801468 <fsipc>
}
  8014e1:	c9                   	leave  
  8014e2:	c3                   	ret    

008014e3 <devfile_flush>:
{
  8014e3:	f3 0f 1e fb          	endbr32 
  8014e7:	55                   	push   %ebp
  8014e8:	89 e5                	mov    %esp,%ebp
  8014ea:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f0:	8b 40 0c             	mov    0xc(%eax),%eax
  8014f3:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fd:	b8 06 00 00 00       	mov    $0x6,%eax
  801502:	e8 61 ff ff ff       	call   801468 <fsipc>
}
  801507:	c9                   	leave  
  801508:	c3                   	ret    

00801509 <devfile_stat>:
{
  801509:	f3 0f 1e fb          	endbr32 
  80150d:	55                   	push   %ebp
  80150e:	89 e5                	mov    %esp,%ebp
  801510:	53                   	push   %ebx
  801511:	83 ec 04             	sub    $0x4,%esp
  801514:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801517:	8b 45 08             	mov    0x8(%ebp),%eax
  80151a:	8b 40 0c             	mov    0xc(%eax),%eax
  80151d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801522:	ba 00 00 00 00       	mov    $0x0,%edx
  801527:	b8 05 00 00 00       	mov    $0x5,%eax
  80152c:	e8 37 ff ff ff       	call   801468 <fsipc>
  801531:	85 c0                	test   %eax,%eax
  801533:	78 2c                	js     801561 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801535:	83 ec 08             	sub    $0x8,%esp
  801538:	68 00 50 80 00       	push   $0x805000
  80153d:	53                   	push   %ebx
  80153e:	e8 5d f2 ff ff       	call   8007a0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801543:	a1 80 50 80 00       	mov    0x805080,%eax
  801548:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80154e:	a1 84 50 80 00       	mov    0x805084,%eax
  801553:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801559:	83 c4 10             	add    $0x10,%esp
  80155c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801561:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801564:	c9                   	leave  
  801565:	c3                   	ret    

00801566 <devfile_write>:
{
  801566:	f3 0f 1e fb          	endbr32 
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	83 ec 0c             	sub    $0xc,%esp
  801570:	8b 45 10             	mov    0x10(%ebp),%eax
	n = n > size_max ? size_max : n;
  801573:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801578:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80157d:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801580:	8b 55 08             	mov    0x8(%ebp),%edx
  801583:	8b 52 0c             	mov    0xc(%edx),%edx
  801586:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80158c:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801591:	50                   	push   %eax
  801592:	ff 75 0c             	pushl  0xc(%ebp)
  801595:	68 08 50 80 00       	push   $0x805008
  80159a:	e8 b7 f3 ff ff       	call   800956 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80159f:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a4:	b8 04 00 00 00       	mov    $0x4,%eax
  8015a9:	e8 ba fe ff ff       	call   801468 <fsipc>
}
  8015ae:	c9                   	leave  
  8015af:	c3                   	ret    

008015b0 <devfile_read>:
{
  8015b0:	f3 0f 1e fb          	endbr32 
  8015b4:	55                   	push   %ebp
  8015b5:	89 e5                	mov    %esp,%ebp
  8015b7:	56                   	push   %esi
  8015b8:	53                   	push   %ebx
  8015b9:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8015bf:	8b 40 0c             	mov    0xc(%eax),%eax
  8015c2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015c7:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d2:	b8 03 00 00 00       	mov    $0x3,%eax
  8015d7:	e8 8c fe ff ff       	call   801468 <fsipc>
  8015dc:	89 c3                	mov    %eax,%ebx
  8015de:	85 c0                	test   %eax,%eax
  8015e0:	78 1f                	js     801601 <devfile_read+0x51>
	assert(r <= n);
  8015e2:	39 f0                	cmp    %esi,%eax
  8015e4:	77 24                	ja     80160a <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8015e6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015eb:	7f 33                	jg     801620 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015ed:	83 ec 04             	sub    $0x4,%esp
  8015f0:	50                   	push   %eax
  8015f1:	68 00 50 80 00       	push   $0x805000
  8015f6:	ff 75 0c             	pushl  0xc(%ebp)
  8015f9:	e8 58 f3 ff ff       	call   800956 <memmove>
	return r;
  8015fe:	83 c4 10             	add    $0x10,%esp
}
  801601:	89 d8                	mov    %ebx,%eax
  801603:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801606:	5b                   	pop    %ebx
  801607:	5e                   	pop    %esi
  801608:	5d                   	pop    %ebp
  801609:	c3                   	ret    
	assert(r <= n);
  80160a:	68 18 24 80 00       	push   $0x802418
  80160f:	68 1f 24 80 00       	push   $0x80241f
  801614:	6a 7c                	push   $0x7c
  801616:	68 34 24 80 00       	push   $0x802434
  80161b:	e8 be 05 00 00       	call   801bde <_panic>
	assert(r <= PGSIZE);
  801620:	68 3f 24 80 00       	push   $0x80243f
  801625:	68 1f 24 80 00       	push   $0x80241f
  80162a:	6a 7d                	push   $0x7d
  80162c:	68 34 24 80 00       	push   $0x802434
  801631:	e8 a8 05 00 00       	call   801bde <_panic>

00801636 <open>:
{
  801636:	f3 0f 1e fb          	endbr32 
  80163a:	55                   	push   %ebp
  80163b:	89 e5                	mov    %esp,%ebp
  80163d:	56                   	push   %esi
  80163e:	53                   	push   %ebx
  80163f:	83 ec 1c             	sub    $0x1c,%esp
  801642:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801645:	56                   	push   %esi
  801646:	e8 12 f1 ff ff       	call   80075d <strlen>
  80164b:	83 c4 10             	add    $0x10,%esp
  80164e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801653:	7f 6c                	jg     8016c1 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801655:	83 ec 0c             	sub    $0xc,%esp
  801658:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80165b:	50                   	push   %eax
  80165c:	e8 67 f8 ff ff       	call   800ec8 <fd_alloc>
  801661:	89 c3                	mov    %eax,%ebx
  801663:	83 c4 10             	add    $0x10,%esp
  801666:	85 c0                	test   %eax,%eax
  801668:	78 3c                	js     8016a6 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  80166a:	83 ec 08             	sub    $0x8,%esp
  80166d:	56                   	push   %esi
  80166e:	68 00 50 80 00       	push   $0x805000
  801673:	e8 28 f1 ff ff       	call   8007a0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801678:	8b 45 0c             	mov    0xc(%ebp),%eax
  80167b:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801680:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801683:	b8 01 00 00 00       	mov    $0x1,%eax
  801688:	e8 db fd ff ff       	call   801468 <fsipc>
  80168d:	89 c3                	mov    %eax,%ebx
  80168f:	83 c4 10             	add    $0x10,%esp
  801692:	85 c0                	test   %eax,%eax
  801694:	78 19                	js     8016af <open+0x79>
	return fd2num(fd);
  801696:	83 ec 0c             	sub    $0xc,%esp
  801699:	ff 75 f4             	pushl  -0xc(%ebp)
  80169c:	e8 f8 f7 ff ff       	call   800e99 <fd2num>
  8016a1:	89 c3                	mov    %eax,%ebx
  8016a3:	83 c4 10             	add    $0x10,%esp
}
  8016a6:	89 d8                	mov    %ebx,%eax
  8016a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ab:	5b                   	pop    %ebx
  8016ac:	5e                   	pop    %esi
  8016ad:	5d                   	pop    %ebp
  8016ae:	c3                   	ret    
		fd_close(fd, 0);
  8016af:	83 ec 08             	sub    $0x8,%esp
  8016b2:	6a 00                	push   $0x0
  8016b4:	ff 75 f4             	pushl  -0xc(%ebp)
  8016b7:	e8 10 f9 ff ff       	call   800fcc <fd_close>
		return r;
  8016bc:	83 c4 10             	add    $0x10,%esp
  8016bf:	eb e5                	jmp    8016a6 <open+0x70>
		return -E_BAD_PATH;
  8016c1:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8016c6:	eb de                	jmp    8016a6 <open+0x70>

008016c8 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016c8:	f3 0f 1e fb          	endbr32 
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
  8016cf:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d7:	b8 08 00 00 00       	mov    $0x8,%eax
  8016dc:	e8 87 fd ff ff       	call   801468 <fsipc>
}
  8016e1:	c9                   	leave  
  8016e2:	c3                   	ret    

008016e3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8016e3:	f3 0f 1e fb          	endbr32 
  8016e7:	55                   	push   %ebp
  8016e8:	89 e5                	mov    %esp,%ebp
  8016ea:	56                   	push   %esi
  8016eb:	53                   	push   %ebx
  8016ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8016ef:	83 ec 0c             	sub    $0xc,%esp
  8016f2:	ff 75 08             	pushl  0x8(%ebp)
  8016f5:	e8 b3 f7 ff ff       	call   800ead <fd2data>
  8016fa:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8016fc:	83 c4 08             	add    $0x8,%esp
  8016ff:	68 4b 24 80 00       	push   $0x80244b
  801704:	53                   	push   %ebx
  801705:	e8 96 f0 ff ff       	call   8007a0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80170a:	8b 46 04             	mov    0x4(%esi),%eax
  80170d:	2b 06                	sub    (%esi),%eax
  80170f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801715:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80171c:	00 00 00 
	stat->st_dev = &devpipe;
  80171f:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801726:	30 80 00 
	return 0;
}
  801729:	b8 00 00 00 00       	mov    $0x0,%eax
  80172e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801731:	5b                   	pop    %ebx
  801732:	5e                   	pop    %esi
  801733:	5d                   	pop    %ebp
  801734:	c3                   	ret    

00801735 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801735:	f3 0f 1e fb          	endbr32 
  801739:	55                   	push   %ebp
  80173a:	89 e5                	mov    %esp,%ebp
  80173c:	53                   	push   %ebx
  80173d:	83 ec 0c             	sub    $0xc,%esp
  801740:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801743:	53                   	push   %ebx
  801744:	6a 00                	push   $0x0
  801746:	e8 24 f5 ff ff       	call   800c6f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80174b:	89 1c 24             	mov    %ebx,(%esp)
  80174e:	e8 5a f7 ff ff       	call   800ead <fd2data>
  801753:	83 c4 08             	add    $0x8,%esp
  801756:	50                   	push   %eax
  801757:	6a 00                	push   $0x0
  801759:	e8 11 f5 ff ff       	call   800c6f <sys_page_unmap>
}
  80175e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801761:	c9                   	leave  
  801762:	c3                   	ret    

00801763 <_pipeisclosed>:
{
  801763:	55                   	push   %ebp
  801764:	89 e5                	mov    %esp,%ebp
  801766:	57                   	push   %edi
  801767:	56                   	push   %esi
  801768:	53                   	push   %ebx
  801769:	83 ec 1c             	sub    $0x1c,%esp
  80176c:	89 c7                	mov    %eax,%edi
  80176e:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801770:	a1 04 40 80 00       	mov    0x804004,%eax
  801775:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801778:	83 ec 0c             	sub    $0xc,%esp
  80177b:	57                   	push   %edi
  80177c:	e8 a1 05 00 00       	call   801d22 <pageref>
  801781:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801784:	89 34 24             	mov    %esi,(%esp)
  801787:	e8 96 05 00 00       	call   801d22 <pageref>
		nn = thisenv->env_runs;
  80178c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801792:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801795:	83 c4 10             	add    $0x10,%esp
  801798:	39 cb                	cmp    %ecx,%ebx
  80179a:	74 1b                	je     8017b7 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  80179c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80179f:	75 cf                	jne    801770 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8017a1:	8b 42 58             	mov    0x58(%edx),%eax
  8017a4:	6a 01                	push   $0x1
  8017a6:	50                   	push   %eax
  8017a7:	53                   	push   %ebx
  8017a8:	68 52 24 80 00       	push   $0x802452
  8017ad:	e8 e5 e9 ff ff       	call   800197 <cprintf>
  8017b2:	83 c4 10             	add    $0x10,%esp
  8017b5:	eb b9                	jmp    801770 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8017b7:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8017ba:	0f 94 c0             	sete   %al
  8017bd:	0f b6 c0             	movzbl %al,%eax
}
  8017c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017c3:	5b                   	pop    %ebx
  8017c4:	5e                   	pop    %esi
  8017c5:	5f                   	pop    %edi
  8017c6:	5d                   	pop    %ebp
  8017c7:	c3                   	ret    

008017c8 <devpipe_write>:
{
  8017c8:	f3 0f 1e fb          	endbr32 
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	57                   	push   %edi
  8017d0:	56                   	push   %esi
  8017d1:	53                   	push   %ebx
  8017d2:	83 ec 28             	sub    $0x28,%esp
  8017d5:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8017d8:	56                   	push   %esi
  8017d9:	e8 cf f6 ff ff       	call   800ead <fd2data>
  8017de:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8017e0:	83 c4 10             	add    $0x10,%esp
  8017e3:	bf 00 00 00 00       	mov    $0x0,%edi
  8017e8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017eb:	74 4f                	je     80183c <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8017ed:	8b 43 04             	mov    0x4(%ebx),%eax
  8017f0:	8b 0b                	mov    (%ebx),%ecx
  8017f2:	8d 51 20             	lea    0x20(%ecx),%edx
  8017f5:	39 d0                	cmp    %edx,%eax
  8017f7:	72 14                	jb     80180d <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  8017f9:	89 da                	mov    %ebx,%edx
  8017fb:	89 f0                	mov    %esi,%eax
  8017fd:	e8 61 ff ff ff       	call   801763 <_pipeisclosed>
  801802:	85 c0                	test   %eax,%eax
  801804:	75 3b                	jne    801841 <devpipe_write+0x79>
			sys_yield();
  801806:	e8 b4 f3 ff ff       	call   800bbf <sys_yield>
  80180b:	eb e0                	jmp    8017ed <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80180d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801810:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801814:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801817:	89 c2                	mov    %eax,%edx
  801819:	c1 fa 1f             	sar    $0x1f,%edx
  80181c:	89 d1                	mov    %edx,%ecx
  80181e:	c1 e9 1b             	shr    $0x1b,%ecx
  801821:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801824:	83 e2 1f             	and    $0x1f,%edx
  801827:	29 ca                	sub    %ecx,%edx
  801829:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80182d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801831:	83 c0 01             	add    $0x1,%eax
  801834:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801837:	83 c7 01             	add    $0x1,%edi
  80183a:	eb ac                	jmp    8017e8 <devpipe_write+0x20>
	return i;
  80183c:	8b 45 10             	mov    0x10(%ebp),%eax
  80183f:	eb 05                	jmp    801846 <devpipe_write+0x7e>
				return 0;
  801841:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801846:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801849:	5b                   	pop    %ebx
  80184a:	5e                   	pop    %esi
  80184b:	5f                   	pop    %edi
  80184c:	5d                   	pop    %ebp
  80184d:	c3                   	ret    

0080184e <devpipe_read>:
{
  80184e:	f3 0f 1e fb          	endbr32 
  801852:	55                   	push   %ebp
  801853:	89 e5                	mov    %esp,%ebp
  801855:	57                   	push   %edi
  801856:	56                   	push   %esi
  801857:	53                   	push   %ebx
  801858:	83 ec 18             	sub    $0x18,%esp
  80185b:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80185e:	57                   	push   %edi
  80185f:	e8 49 f6 ff ff       	call   800ead <fd2data>
  801864:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801866:	83 c4 10             	add    $0x10,%esp
  801869:	be 00 00 00 00       	mov    $0x0,%esi
  80186e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801871:	75 14                	jne    801887 <devpipe_read+0x39>
	return i;
  801873:	8b 45 10             	mov    0x10(%ebp),%eax
  801876:	eb 02                	jmp    80187a <devpipe_read+0x2c>
				return i;
  801878:	89 f0                	mov    %esi,%eax
}
  80187a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80187d:	5b                   	pop    %ebx
  80187e:	5e                   	pop    %esi
  80187f:	5f                   	pop    %edi
  801880:	5d                   	pop    %ebp
  801881:	c3                   	ret    
			sys_yield();
  801882:	e8 38 f3 ff ff       	call   800bbf <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801887:	8b 03                	mov    (%ebx),%eax
  801889:	3b 43 04             	cmp    0x4(%ebx),%eax
  80188c:	75 18                	jne    8018a6 <devpipe_read+0x58>
			if (i > 0)
  80188e:	85 f6                	test   %esi,%esi
  801890:	75 e6                	jne    801878 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801892:	89 da                	mov    %ebx,%edx
  801894:	89 f8                	mov    %edi,%eax
  801896:	e8 c8 fe ff ff       	call   801763 <_pipeisclosed>
  80189b:	85 c0                	test   %eax,%eax
  80189d:	74 e3                	je     801882 <devpipe_read+0x34>
				return 0;
  80189f:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a4:	eb d4                	jmp    80187a <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8018a6:	99                   	cltd   
  8018a7:	c1 ea 1b             	shr    $0x1b,%edx
  8018aa:	01 d0                	add    %edx,%eax
  8018ac:	83 e0 1f             	and    $0x1f,%eax
  8018af:	29 d0                	sub    %edx,%eax
  8018b1:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8018b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018b9:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8018bc:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8018bf:	83 c6 01             	add    $0x1,%esi
  8018c2:	eb aa                	jmp    80186e <devpipe_read+0x20>

008018c4 <pipe>:
{
  8018c4:	f3 0f 1e fb          	endbr32 
  8018c8:	55                   	push   %ebp
  8018c9:	89 e5                	mov    %esp,%ebp
  8018cb:	56                   	push   %esi
  8018cc:	53                   	push   %ebx
  8018cd:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8018d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d3:	50                   	push   %eax
  8018d4:	e8 ef f5 ff ff       	call   800ec8 <fd_alloc>
  8018d9:	89 c3                	mov    %eax,%ebx
  8018db:	83 c4 10             	add    $0x10,%esp
  8018de:	85 c0                	test   %eax,%eax
  8018e0:	0f 88 23 01 00 00    	js     801a09 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018e6:	83 ec 04             	sub    $0x4,%esp
  8018e9:	68 07 04 00 00       	push   $0x407
  8018ee:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f1:	6a 00                	push   $0x0
  8018f3:	e8 ea f2 ff ff       	call   800be2 <sys_page_alloc>
  8018f8:	89 c3                	mov    %eax,%ebx
  8018fa:	83 c4 10             	add    $0x10,%esp
  8018fd:	85 c0                	test   %eax,%eax
  8018ff:	0f 88 04 01 00 00    	js     801a09 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801905:	83 ec 0c             	sub    $0xc,%esp
  801908:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80190b:	50                   	push   %eax
  80190c:	e8 b7 f5 ff ff       	call   800ec8 <fd_alloc>
  801911:	89 c3                	mov    %eax,%ebx
  801913:	83 c4 10             	add    $0x10,%esp
  801916:	85 c0                	test   %eax,%eax
  801918:	0f 88 db 00 00 00    	js     8019f9 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80191e:	83 ec 04             	sub    $0x4,%esp
  801921:	68 07 04 00 00       	push   $0x407
  801926:	ff 75 f0             	pushl  -0x10(%ebp)
  801929:	6a 00                	push   $0x0
  80192b:	e8 b2 f2 ff ff       	call   800be2 <sys_page_alloc>
  801930:	89 c3                	mov    %eax,%ebx
  801932:	83 c4 10             	add    $0x10,%esp
  801935:	85 c0                	test   %eax,%eax
  801937:	0f 88 bc 00 00 00    	js     8019f9 <pipe+0x135>
	va = fd2data(fd0);
  80193d:	83 ec 0c             	sub    $0xc,%esp
  801940:	ff 75 f4             	pushl  -0xc(%ebp)
  801943:	e8 65 f5 ff ff       	call   800ead <fd2data>
  801948:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80194a:	83 c4 0c             	add    $0xc,%esp
  80194d:	68 07 04 00 00       	push   $0x407
  801952:	50                   	push   %eax
  801953:	6a 00                	push   $0x0
  801955:	e8 88 f2 ff ff       	call   800be2 <sys_page_alloc>
  80195a:	89 c3                	mov    %eax,%ebx
  80195c:	83 c4 10             	add    $0x10,%esp
  80195f:	85 c0                	test   %eax,%eax
  801961:	0f 88 82 00 00 00    	js     8019e9 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801967:	83 ec 0c             	sub    $0xc,%esp
  80196a:	ff 75 f0             	pushl  -0x10(%ebp)
  80196d:	e8 3b f5 ff ff       	call   800ead <fd2data>
  801972:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801979:	50                   	push   %eax
  80197a:	6a 00                	push   $0x0
  80197c:	56                   	push   %esi
  80197d:	6a 00                	push   $0x0
  80197f:	e8 a5 f2 ff ff       	call   800c29 <sys_page_map>
  801984:	89 c3                	mov    %eax,%ebx
  801986:	83 c4 20             	add    $0x20,%esp
  801989:	85 c0                	test   %eax,%eax
  80198b:	78 4e                	js     8019db <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  80198d:	a1 20 30 80 00       	mov    0x803020,%eax
  801992:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801995:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801997:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80199a:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8019a1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8019a4:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8019a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019a9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8019b0:	83 ec 0c             	sub    $0xc,%esp
  8019b3:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b6:	e8 de f4 ff ff       	call   800e99 <fd2num>
  8019bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019be:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8019c0:	83 c4 04             	add    $0x4,%esp
  8019c3:	ff 75 f0             	pushl  -0x10(%ebp)
  8019c6:	e8 ce f4 ff ff       	call   800e99 <fd2num>
  8019cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019ce:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8019d1:	83 c4 10             	add    $0x10,%esp
  8019d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019d9:	eb 2e                	jmp    801a09 <pipe+0x145>
	sys_page_unmap(0, va);
  8019db:	83 ec 08             	sub    $0x8,%esp
  8019de:	56                   	push   %esi
  8019df:	6a 00                	push   $0x0
  8019e1:	e8 89 f2 ff ff       	call   800c6f <sys_page_unmap>
  8019e6:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8019e9:	83 ec 08             	sub    $0x8,%esp
  8019ec:	ff 75 f0             	pushl  -0x10(%ebp)
  8019ef:	6a 00                	push   $0x0
  8019f1:	e8 79 f2 ff ff       	call   800c6f <sys_page_unmap>
  8019f6:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8019f9:	83 ec 08             	sub    $0x8,%esp
  8019fc:	ff 75 f4             	pushl  -0xc(%ebp)
  8019ff:	6a 00                	push   $0x0
  801a01:	e8 69 f2 ff ff       	call   800c6f <sys_page_unmap>
  801a06:	83 c4 10             	add    $0x10,%esp
}
  801a09:	89 d8                	mov    %ebx,%eax
  801a0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a0e:	5b                   	pop    %ebx
  801a0f:	5e                   	pop    %esi
  801a10:	5d                   	pop    %ebp
  801a11:	c3                   	ret    

00801a12 <pipeisclosed>:
{
  801a12:	f3 0f 1e fb          	endbr32 
  801a16:	55                   	push   %ebp
  801a17:	89 e5                	mov    %esp,%ebp
  801a19:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a1f:	50                   	push   %eax
  801a20:	ff 75 08             	pushl  0x8(%ebp)
  801a23:	e8 f6 f4 ff ff       	call   800f1e <fd_lookup>
  801a28:	83 c4 10             	add    $0x10,%esp
  801a2b:	85 c0                	test   %eax,%eax
  801a2d:	78 18                	js     801a47 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801a2f:	83 ec 0c             	sub    $0xc,%esp
  801a32:	ff 75 f4             	pushl  -0xc(%ebp)
  801a35:	e8 73 f4 ff ff       	call   800ead <fd2data>
  801a3a:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801a3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a3f:	e8 1f fd ff ff       	call   801763 <_pipeisclosed>
  801a44:	83 c4 10             	add    $0x10,%esp
}
  801a47:	c9                   	leave  
  801a48:	c3                   	ret    

00801a49 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a49:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801a4d:	b8 00 00 00 00       	mov    $0x0,%eax
  801a52:	c3                   	ret    

00801a53 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a53:	f3 0f 1e fb          	endbr32 
  801a57:	55                   	push   %ebp
  801a58:	89 e5                	mov    %esp,%ebp
  801a5a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a5d:	68 6a 24 80 00       	push   $0x80246a
  801a62:	ff 75 0c             	pushl  0xc(%ebp)
  801a65:	e8 36 ed ff ff       	call   8007a0 <strcpy>
	return 0;
}
  801a6a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a6f:	c9                   	leave  
  801a70:	c3                   	ret    

00801a71 <devcons_write>:
{
  801a71:	f3 0f 1e fb          	endbr32 
  801a75:	55                   	push   %ebp
  801a76:	89 e5                	mov    %esp,%ebp
  801a78:	57                   	push   %edi
  801a79:	56                   	push   %esi
  801a7a:	53                   	push   %ebx
  801a7b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801a81:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801a86:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801a8c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a8f:	73 31                	jae    801ac2 <devcons_write+0x51>
		m = n - tot;
  801a91:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a94:	29 f3                	sub    %esi,%ebx
  801a96:	83 fb 7f             	cmp    $0x7f,%ebx
  801a99:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801a9e:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801aa1:	83 ec 04             	sub    $0x4,%esp
  801aa4:	53                   	push   %ebx
  801aa5:	89 f0                	mov    %esi,%eax
  801aa7:	03 45 0c             	add    0xc(%ebp),%eax
  801aaa:	50                   	push   %eax
  801aab:	57                   	push   %edi
  801aac:	e8 a5 ee ff ff       	call   800956 <memmove>
		sys_cputs(buf, m);
  801ab1:	83 c4 08             	add    $0x8,%esp
  801ab4:	53                   	push   %ebx
  801ab5:	57                   	push   %edi
  801ab6:	e8 57 f0 ff ff       	call   800b12 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801abb:	01 de                	add    %ebx,%esi
  801abd:	83 c4 10             	add    $0x10,%esp
  801ac0:	eb ca                	jmp    801a8c <devcons_write+0x1b>
}
  801ac2:	89 f0                	mov    %esi,%eax
  801ac4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac7:	5b                   	pop    %ebx
  801ac8:	5e                   	pop    %esi
  801ac9:	5f                   	pop    %edi
  801aca:	5d                   	pop    %ebp
  801acb:	c3                   	ret    

00801acc <devcons_read>:
{
  801acc:	f3 0f 1e fb          	endbr32 
  801ad0:	55                   	push   %ebp
  801ad1:	89 e5                	mov    %esp,%ebp
  801ad3:	83 ec 08             	sub    $0x8,%esp
  801ad6:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801adb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801adf:	74 21                	je     801b02 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801ae1:	e8 4e f0 ff ff       	call   800b34 <sys_cgetc>
  801ae6:	85 c0                	test   %eax,%eax
  801ae8:	75 07                	jne    801af1 <devcons_read+0x25>
		sys_yield();
  801aea:	e8 d0 f0 ff ff       	call   800bbf <sys_yield>
  801aef:	eb f0                	jmp    801ae1 <devcons_read+0x15>
	if (c < 0)
  801af1:	78 0f                	js     801b02 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801af3:	83 f8 04             	cmp    $0x4,%eax
  801af6:	74 0c                	je     801b04 <devcons_read+0x38>
	*(char*)vbuf = c;
  801af8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801afb:	88 02                	mov    %al,(%edx)
	return 1;
  801afd:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801b02:	c9                   	leave  
  801b03:	c3                   	ret    
		return 0;
  801b04:	b8 00 00 00 00       	mov    $0x0,%eax
  801b09:	eb f7                	jmp    801b02 <devcons_read+0x36>

00801b0b <cputchar>:
{
  801b0b:	f3 0f 1e fb          	endbr32 
  801b0f:	55                   	push   %ebp
  801b10:	89 e5                	mov    %esp,%ebp
  801b12:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b15:	8b 45 08             	mov    0x8(%ebp),%eax
  801b18:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801b1b:	6a 01                	push   $0x1
  801b1d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b20:	50                   	push   %eax
  801b21:	e8 ec ef ff ff       	call   800b12 <sys_cputs>
}
  801b26:	83 c4 10             	add    $0x10,%esp
  801b29:	c9                   	leave  
  801b2a:	c3                   	ret    

00801b2b <getchar>:
{
  801b2b:	f3 0f 1e fb          	endbr32 
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801b35:	6a 01                	push   $0x1
  801b37:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b3a:	50                   	push   %eax
  801b3b:	6a 00                	push   $0x0
  801b3d:	e8 5f f6 ff ff       	call   8011a1 <read>
	if (r < 0)
  801b42:	83 c4 10             	add    $0x10,%esp
  801b45:	85 c0                	test   %eax,%eax
  801b47:	78 06                	js     801b4f <getchar+0x24>
	if (r < 1)
  801b49:	74 06                	je     801b51 <getchar+0x26>
	return c;
  801b4b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801b4f:	c9                   	leave  
  801b50:	c3                   	ret    
		return -E_EOF;
  801b51:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801b56:	eb f7                	jmp    801b4f <getchar+0x24>

00801b58 <iscons>:
{
  801b58:	f3 0f 1e fb          	endbr32 
  801b5c:	55                   	push   %ebp
  801b5d:	89 e5                	mov    %esp,%ebp
  801b5f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b62:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b65:	50                   	push   %eax
  801b66:	ff 75 08             	pushl  0x8(%ebp)
  801b69:	e8 b0 f3 ff ff       	call   800f1e <fd_lookup>
  801b6e:	83 c4 10             	add    $0x10,%esp
  801b71:	85 c0                	test   %eax,%eax
  801b73:	78 11                	js     801b86 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801b75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b78:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b7e:	39 10                	cmp    %edx,(%eax)
  801b80:	0f 94 c0             	sete   %al
  801b83:	0f b6 c0             	movzbl %al,%eax
}
  801b86:	c9                   	leave  
  801b87:	c3                   	ret    

00801b88 <opencons>:
{
  801b88:	f3 0f 1e fb          	endbr32 
  801b8c:	55                   	push   %ebp
  801b8d:	89 e5                	mov    %esp,%ebp
  801b8f:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801b92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b95:	50                   	push   %eax
  801b96:	e8 2d f3 ff ff       	call   800ec8 <fd_alloc>
  801b9b:	83 c4 10             	add    $0x10,%esp
  801b9e:	85 c0                	test   %eax,%eax
  801ba0:	78 3a                	js     801bdc <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ba2:	83 ec 04             	sub    $0x4,%esp
  801ba5:	68 07 04 00 00       	push   $0x407
  801baa:	ff 75 f4             	pushl  -0xc(%ebp)
  801bad:	6a 00                	push   $0x0
  801baf:	e8 2e f0 ff ff       	call   800be2 <sys_page_alloc>
  801bb4:	83 c4 10             	add    $0x10,%esp
  801bb7:	85 c0                	test   %eax,%eax
  801bb9:	78 21                	js     801bdc <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801bbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bbe:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bc4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801bc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801bd0:	83 ec 0c             	sub    $0xc,%esp
  801bd3:	50                   	push   %eax
  801bd4:	e8 c0 f2 ff ff       	call   800e99 <fd2num>
  801bd9:	83 c4 10             	add    $0x10,%esp
}
  801bdc:	c9                   	leave  
  801bdd:	c3                   	ret    

00801bde <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801bde:	f3 0f 1e fb          	endbr32 
  801be2:	55                   	push   %ebp
  801be3:	89 e5                	mov    %esp,%ebp
  801be5:	56                   	push   %esi
  801be6:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801be7:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801bea:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801bf0:	e8 a7 ef ff ff       	call   800b9c <sys_getenvid>
  801bf5:	83 ec 0c             	sub    $0xc,%esp
  801bf8:	ff 75 0c             	pushl  0xc(%ebp)
  801bfb:	ff 75 08             	pushl  0x8(%ebp)
  801bfe:	56                   	push   %esi
  801bff:	50                   	push   %eax
  801c00:	68 78 24 80 00       	push   $0x802478
  801c05:	e8 8d e5 ff ff       	call   800197 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801c0a:	83 c4 18             	add    $0x18,%esp
  801c0d:	53                   	push   %ebx
  801c0e:	ff 75 10             	pushl  0x10(%ebp)
  801c11:	e8 2c e5 ff ff       	call   800142 <vcprintf>
	cprintf("\n");
  801c16:	c7 04 24 37 23 80 00 	movl   $0x802337,(%esp)
  801c1d:	e8 75 e5 ff ff       	call   800197 <cprintf>
  801c22:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801c25:	cc                   	int3   
  801c26:	eb fd                	jmp    801c25 <_panic+0x47>

00801c28 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c28:	f3 0f 1e fb          	endbr32 
  801c2c:	55                   	push   %ebp
  801c2d:	89 e5                	mov    %esp,%ebp
  801c2f:	56                   	push   %esi
  801c30:	53                   	push   %ebx
  801c31:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801c34:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c37:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801c3a:	85 c0                	test   %eax,%eax
  801c3c:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801c41:	0f 44 c2             	cmove  %edx,%eax
  801c44:	83 ec 0c             	sub    $0xc,%esp
  801c47:	50                   	push   %eax
  801c48:	e8 61 f1 ff ff       	call   800dae <sys_ipc_recv>
  801c4d:	83 c4 10             	add    $0x10,%esp
  801c50:	85 c0                	test   %eax,%eax
  801c52:	78 24                	js     801c78 <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801c54:	85 f6                	test   %esi,%esi
  801c56:	74 0a                	je     801c62 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801c58:	a1 04 40 80 00       	mov    0x804004,%eax
  801c5d:	8b 40 78             	mov    0x78(%eax),%eax
  801c60:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801c62:	85 db                	test   %ebx,%ebx
  801c64:	74 0a                	je     801c70 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801c66:	a1 04 40 80 00       	mov    0x804004,%eax
  801c6b:	8b 40 74             	mov    0x74(%eax),%eax
  801c6e:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801c70:	a1 04 40 80 00       	mov    0x804004,%eax
  801c75:	8b 40 70             	mov    0x70(%eax),%eax
}
  801c78:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c7b:	5b                   	pop    %ebx
  801c7c:	5e                   	pop    %esi
  801c7d:	5d                   	pop    %ebp
  801c7e:	c3                   	ret    

00801c7f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c7f:	f3 0f 1e fb          	endbr32 
  801c83:	55                   	push   %ebp
  801c84:	89 e5                	mov    %esp,%ebp
  801c86:	57                   	push   %edi
  801c87:	56                   	push   %esi
  801c88:	53                   	push   %ebx
  801c89:	83 ec 1c             	sub    $0x1c,%esp
  801c8c:	8b 45 10             	mov    0x10(%ebp),%eax
  801c8f:	85 c0                	test   %eax,%eax
  801c91:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801c96:	0f 45 d0             	cmovne %eax,%edx
  801c99:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801c9b:	be 01 00 00 00       	mov    $0x1,%esi
  801ca0:	eb 1f                	jmp    801cc1 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801ca2:	e8 18 ef ff ff       	call   800bbf <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801ca7:	83 c3 01             	add    $0x1,%ebx
  801caa:	39 de                	cmp    %ebx,%esi
  801cac:	7f f4                	jg     801ca2 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801cae:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801cb0:	83 fe 11             	cmp    $0x11,%esi
  801cb3:	b8 01 00 00 00       	mov    $0x1,%eax
  801cb8:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801cbb:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801cbf:	75 1c                	jne    801cdd <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801cc1:	ff 75 14             	pushl  0x14(%ebp)
  801cc4:	57                   	push   %edi
  801cc5:	ff 75 0c             	pushl  0xc(%ebp)
  801cc8:	ff 75 08             	pushl  0x8(%ebp)
  801ccb:	e8 b7 f0 ff ff       	call   800d87 <sys_ipc_try_send>
  801cd0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801cd3:	83 c4 10             	add    $0x10,%esp
  801cd6:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cdb:	eb cd                	jmp    801caa <ipc_send+0x2b>
}
  801cdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ce0:	5b                   	pop    %ebx
  801ce1:	5e                   	pop    %esi
  801ce2:	5f                   	pop    %edi
  801ce3:	5d                   	pop    %ebp
  801ce4:	c3                   	ret    

00801ce5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ce5:	f3 0f 1e fb          	endbr32 
  801ce9:	55                   	push   %ebp
  801cea:	89 e5                	mov    %esp,%ebp
  801cec:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801cef:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801cf4:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801cf7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cfd:	8b 52 50             	mov    0x50(%edx),%edx
  801d00:	39 ca                	cmp    %ecx,%edx
  801d02:	74 11                	je     801d15 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801d04:	83 c0 01             	add    $0x1,%eax
  801d07:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d0c:	75 e6                	jne    801cf4 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801d0e:	b8 00 00 00 00       	mov    $0x0,%eax
  801d13:	eb 0b                	jmp    801d20 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801d15:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801d18:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801d1d:	8b 40 48             	mov    0x48(%eax),%eax
}
  801d20:	5d                   	pop    %ebp
  801d21:	c3                   	ret    

00801d22 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d22:	f3 0f 1e fb          	endbr32 
  801d26:	55                   	push   %ebp
  801d27:	89 e5                	mov    %esp,%ebp
  801d29:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d2c:	89 c2                	mov    %eax,%edx
  801d2e:	c1 ea 16             	shr    $0x16,%edx
  801d31:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801d38:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801d3d:	f6 c1 01             	test   $0x1,%cl
  801d40:	74 1c                	je     801d5e <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801d42:	c1 e8 0c             	shr    $0xc,%eax
  801d45:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d4c:	a8 01                	test   $0x1,%al
  801d4e:	74 0e                	je     801d5e <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d50:	c1 e8 0c             	shr    $0xc,%eax
  801d53:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801d5a:	ef 
  801d5b:	0f b7 d2             	movzwl %dx,%edx
}
  801d5e:	89 d0                	mov    %edx,%eax
  801d60:	5d                   	pop    %ebp
  801d61:	c3                   	ret    
  801d62:	66 90                	xchg   %ax,%ax
  801d64:	66 90                	xchg   %ax,%ax
  801d66:	66 90                	xchg   %ax,%ax
  801d68:	66 90                	xchg   %ax,%ax
  801d6a:	66 90                	xchg   %ax,%ax
  801d6c:	66 90                	xchg   %ax,%ax
  801d6e:	66 90                	xchg   %ax,%ax

00801d70 <__udivdi3>:
  801d70:	f3 0f 1e fb          	endbr32 
  801d74:	55                   	push   %ebp
  801d75:	57                   	push   %edi
  801d76:	56                   	push   %esi
  801d77:	53                   	push   %ebx
  801d78:	83 ec 1c             	sub    $0x1c,%esp
  801d7b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d7f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801d83:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d87:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801d8b:	85 d2                	test   %edx,%edx
  801d8d:	75 19                	jne    801da8 <__udivdi3+0x38>
  801d8f:	39 f3                	cmp    %esi,%ebx
  801d91:	76 4d                	jbe    801de0 <__udivdi3+0x70>
  801d93:	31 ff                	xor    %edi,%edi
  801d95:	89 e8                	mov    %ebp,%eax
  801d97:	89 f2                	mov    %esi,%edx
  801d99:	f7 f3                	div    %ebx
  801d9b:	89 fa                	mov    %edi,%edx
  801d9d:	83 c4 1c             	add    $0x1c,%esp
  801da0:	5b                   	pop    %ebx
  801da1:	5e                   	pop    %esi
  801da2:	5f                   	pop    %edi
  801da3:	5d                   	pop    %ebp
  801da4:	c3                   	ret    
  801da5:	8d 76 00             	lea    0x0(%esi),%esi
  801da8:	39 f2                	cmp    %esi,%edx
  801daa:	76 14                	jbe    801dc0 <__udivdi3+0x50>
  801dac:	31 ff                	xor    %edi,%edi
  801dae:	31 c0                	xor    %eax,%eax
  801db0:	89 fa                	mov    %edi,%edx
  801db2:	83 c4 1c             	add    $0x1c,%esp
  801db5:	5b                   	pop    %ebx
  801db6:	5e                   	pop    %esi
  801db7:	5f                   	pop    %edi
  801db8:	5d                   	pop    %ebp
  801db9:	c3                   	ret    
  801dba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801dc0:	0f bd fa             	bsr    %edx,%edi
  801dc3:	83 f7 1f             	xor    $0x1f,%edi
  801dc6:	75 48                	jne    801e10 <__udivdi3+0xa0>
  801dc8:	39 f2                	cmp    %esi,%edx
  801dca:	72 06                	jb     801dd2 <__udivdi3+0x62>
  801dcc:	31 c0                	xor    %eax,%eax
  801dce:	39 eb                	cmp    %ebp,%ebx
  801dd0:	77 de                	ja     801db0 <__udivdi3+0x40>
  801dd2:	b8 01 00 00 00       	mov    $0x1,%eax
  801dd7:	eb d7                	jmp    801db0 <__udivdi3+0x40>
  801dd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801de0:	89 d9                	mov    %ebx,%ecx
  801de2:	85 db                	test   %ebx,%ebx
  801de4:	75 0b                	jne    801df1 <__udivdi3+0x81>
  801de6:	b8 01 00 00 00       	mov    $0x1,%eax
  801deb:	31 d2                	xor    %edx,%edx
  801ded:	f7 f3                	div    %ebx
  801def:	89 c1                	mov    %eax,%ecx
  801df1:	31 d2                	xor    %edx,%edx
  801df3:	89 f0                	mov    %esi,%eax
  801df5:	f7 f1                	div    %ecx
  801df7:	89 c6                	mov    %eax,%esi
  801df9:	89 e8                	mov    %ebp,%eax
  801dfb:	89 f7                	mov    %esi,%edi
  801dfd:	f7 f1                	div    %ecx
  801dff:	89 fa                	mov    %edi,%edx
  801e01:	83 c4 1c             	add    $0x1c,%esp
  801e04:	5b                   	pop    %ebx
  801e05:	5e                   	pop    %esi
  801e06:	5f                   	pop    %edi
  801e07:	5d                   	pop    %ebp
  801e08:	c3                   	ret    
  801e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e10:	89 f9                	mov    %edi,%ecx
  801e12:	b8 20 00 00 00       	mov    $0x20,%eax
  801e17:	29 f8                	sub    %edi,%eax
  801e19:	d3 e2                	shl    %cl,%edx
  801e1b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e1f:	89 c1                	mov    %eax,%ecx
  801e21:	89 da                	mov    %ebx,%edx
  801e23:	d3 ea                	shr    %cl,%edx
  801e25:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801e29:	09 d1                	or     %edx,%ecx
  801e2b:	89 f2                	mov    %esi,%edx
  801e2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e31:	89 f9                	mov    %edi,%ecx
  801e33:	d3 e3                	shl    %cl,%ebx
  801e35:	89 c1                	mov    %eax,%ecx
  801e37:	d3 ea                	shr    %cl,%edx
  801e39:	89 f9                	mov    %edi,%ecx
  801e3b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801e3f:	89 eb                	mov    %ebp,%ebx
  801e41:	d3 e6                	shl    %cl,%esi
  801e43:	89 c1                	mov    %eax,%ecx
  801e45:	d3 eb                	shr    %cl,%ebx
  801e47:	09 de                	or     %ebx,%esi
  801e49:	89 f0                	mov    %esi,%eax
  801e4b:	f7 74 24 08          	divl   0x8(%esp)
  801e4f:	89 d6                	mov    %edx,%esi
  801e51:	89 c3                	mov    %eax,%ebx
  801e53:	f7 64 24 0c          	mull   0xc(%esp)
  801e57:	39 d6                	cmp    %edx,%esi
  801e59:	72 15                	jb     801e70 <__udivdi3+0x100>
  801e5b:	89 f9                	mov    %edi,%ecx
  801e5d:	d3 e5                	shl    %cl,%ebp
  801e5f:	39 c5                	cmp    %eax,%ebp
  801e61:	73 04                	jae    801e67 <__udivdi3+0xf7>
  801e63:	39 d6                	cmp    %edx,%esi
  801e65:	74 09                	je     801e70 <__udivdi3+0x100>
  801e67:	89 d8                	mov    %ebx,%eax
  801e69:	31 ff                	xor    %edi,%edi
  801e6b:	e9 40 ff ff ff       	jmp    801db0 <__udivdi3+0x40>
  801e70:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801e73:	31 ff                	xor    %edi,%edi
  801e75:	e9 36 ff ff ff       	jmp    801db0 <__udivdi3+0x40>
  801e7a:	66 90                	xchg   %ax,%ax
  801e7c:	66 90                	xchg   %ax,%ax
  801e7e:	66 90                	xchg   %ax,%ax

00801e80 <__umoddi3>:
  801e80:	f3 0f 1e fb          	endbr32 
  801e84:	55                   	push   %ebp
  801e85:	57                   	push   %edi
  801e86:	56                   	push   %esi
  801e87:	53                   	push   %ebx
  801e88:	83 ec 1c             	sub    $0x1c,%esp
  801e8b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801e8f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801e93:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801e97:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e9b:	85 c0                	test   %eax,%eax
  801e9d:	75 19                	jne    801eb8 <__umoddi3+0x38>
  801e9f:	39 df                	cmp    %ebx,%edi
  801ea1:	76 5d                	jbe    801f00 <__umoddi3+0x80>
  801ea3:	89 f0                	mov    %esi,%eax
  801ea5:	89 da                	mov    %ebx,%edx
  801ea7:	f7 f7                	div    %edi
  801ea9:	89 d0                	mov    %edx,%eax
  801eab:	31 d2                	xor    %edx,%edx
  801ead:	83 c4 1c             	add    $0x1c,%esp
  801eb0:	5b                   	pop    %ebx
  801eb1:	5e                   	pop    %esi
  801eb2:	5f                   	pop    %edi
  801eb3:	5d                   	pop    %ebp
  801eb4:	c3                   	ret    
  801eb5:	8d 76 00             	lea    0x0(%esi),%esi
  801eb8:	89 f2                	mov    %esi,%edx
  801eba:	39 d8                	cmp    %ebx,%eax
  801ebc:	76 12                	jbe    801ed0 <__umoddi3+0x50>
  801ebe:	89 f0                	mov    %esi,%eax
  801ec0:	89 da                	mov    %ebx,%edx
  801ec2:	83 c4 1c             	add    $0x1c,%esp
  801ec5:	5b                   	pop    %ebx
  801ec6:	5e                   	pop    %esi
  801ec7:	5f                   	pop    %edi
  801ec8:	5d                   	pop    %ebp
  801ec9:	c3                   	ret    
  801eca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ed0:	0f bd e8             	bsr    %eax,%ebp
  801ed3:	83 f5 1f             	xor    $0x1f,%ebp
  801ed6:	75 50                	jne    801f28 <__umoddi3+0xa8>
  801ed8:	39 d8                	cmp    %ebx,%eax
  801eda:	0f 82 e0 00 00 00    	jb     801fc0 <__umoddi3+0x140>
  801ee0:	89 d9                	mov    %ebx,%ecx
  801ee2:	39 f7                	cmp    %esi,%edi
  801ee4:	0f 86 d6 00 00 00    	jbe    801fc0 <__umoddi3+0x140>
  801eea:	89 d0                	mov    %edx,%eax
  801eec:	89 ca                	mov    %ecx,%edx
  801eee:	83 c4 1c             	add    $0x1c,%esp
  801ef1:	5b                   	pop    %ebx
  801ef2:	5e                   	pop    %esi
  801ef3:	5f                   	pop    %edi
  801ef4:	5d                   	pop    %ebp
  801ef5:	c3                   	ret    
  801ef6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801efd:	8d 76 00             	lea    0x0(%esi),%esi
  801f00:	89 fd                	mov    %edi,%ebp
  801f02:	85 ff                	test   %edi,%edi
  801f04:	75 0b                	jne    801f11 <__umoddi3+0x91>
  801f06:	b8 01 00 00 00       	mov    $0x1,%eax
  801f0b:	31 d2                	xor    %edx,%edx
  801f0d:	f7 f7                	div    %edi
  801f0f:	89 c5                	mov    %eax,%ebp
  801f11:	89 d8                	mov    %ebx,%eax
  801f13:	31 d2                	xor    %edx,%edx
  801f15:	f7 f5                	div    %ebp
  801f17:	89 f0                	mov    %esi,%eax
  801f19:	f7 f5                	div    %ebp
  801f1b:	89 d0                	mov    %edx,%eax
  801f1d:	31 d2                	xor    %edx,%edx
  801f1f:	eb 8c                	jmp    801ead <__umoddi3+0x2d>
  801f21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f28:	89 e9                	mov    %ebp,%ecx
  801f2a:	ba 20 00 00 00       	mov    $0x20,%edx
  801f2f:	29 ea                	sub    %ebp,%edx
  801f31:	d3 e0                	shl    %cl,%eax
  801f33:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f37:	89 d1                	mov    %edx,%ecx
  801f39:	89 f8                	mov    %edi,%eax
  801f3b:	d3 e8                	shr    %cl,%eax
  801f3d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801f41:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f45:	8b 54 24 04          	mov    0x4(%esp),%edx
  801f49:	09 c1                	or     %eax,%ecx
  801f4b:	89 d8                	mov    %ebx,%eax
  801f4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f51:	89 e9                	mov    %ebp,%ecx
  801f53:	d3 e7                	shl    %cl,%edi
  801f55:	89 d1                	mov    %edx,%ecx
  801f57:	d3 e8                	shr    %cl,%eax
  801f59:	89 e9                	mov    %ebp,%ecx
  801f5b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f5f:	d3 e3                	shl    %cl,%ebx
  801f61:	89 c7                	mov    %eax,%edi
  801f63:	89 d1                	mov    %edx,%ecx
  801f65:	89 f0                	mov    %esi,%eax
  801f67:	d3 e8                	shr    %cl,%eax
  801f69:	89 e9                	mov    %ebp,%ecx
  801f6b:	89 fa                	mov    %edi,%edx
  801f6d:	d3 e6                	shl    %cl,%esi
  801f6f:	09 d8                	or     %ebx,%eax
  801f71:	f7 74 24 08          	divl   0x8(%esp)
  801f75:	89 d1                	mov    %edx,%ecx
  801f77:	89 f3                	mov    %esi,%ebx
  801f79:	f7 64 24 0c          	mull   0xc(%esp)
  801f7d:	89 c6                	mov    %eax,%esi
  801f7f:	89 d7                	mov    %edx,%edi
  801f81:	39 d1                	cmp    %edx,%ecx
  801f83:	72 06                	jb     801f8b <__umoddi3+0x10b>
  801f85:	75 10                	jne    801f97 <__umoddi3+0x117>
  801f87:	39 c3                	cmp    %eax,%ebx
  801f89:	73 0c                	jae    801f97 <__umoddi3+0x117>
  801f8b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801f8f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801f93:	89 d7                	mov    %edx,%edi
  801f95:	89 c6                	mov    %eax,%esi
  801f97:	89 ca                	mov    %ecx,%edx
  801f99:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801f9e:	29 f3                	sub    %esi,%ebx
  801fa0:	19 fa                	sbb    %edi,%edx
  801fa2:	89 d0                	mov    %edx,%eax
  801fa4:	d3 e0                	shl    %cl,%eax
  801fa6:	89 e9                	mov    %ebp,%ecx
  801fa8:	d3 eb                	shr    %cl,%ebx
  801faa:	d3 ea                	shr    %cl,%edx
  801fac:	09 d8                	or     %ebx,%eax
  801fae:	83 c4 1c             	add    $0x1c,%esp
  801fb1:	5b                   	pop    %ebx
  801fb2:	5e                   	pop    %esi
  801fb3:	5f                   	pop    %edi
  801fb4:	5d                   	pop    %ebp
  801fb5:	c3                   	ret    
  801fb6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fbd:	8d 76 00             	lea    0x0(%esi),%esi
  801fc0:	29 fe                	sub    %edi,%esi
  801fc2:	19 c3                	sbb    %eax,%ebx
  801fc4:	89 f2                	mov    %esi,%edx
  801fc6:	89 d9                	mov    %ebx,%ecx
  801fc8:	e9 1d ff ff ff       	jmp    801eea <__umoddi3+0x6a>
