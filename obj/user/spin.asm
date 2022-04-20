
obj/user/spin:     file format elf32-i386


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
  80002c:	e8 88 00 00 00       	call   8000b9 <libmain>
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
  80003a:	53                   	push   %ebx
  80003b:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003e:	68 60 13 80 00       	push   $0x801360
  800043:	e8 6e 01 00 00       	call   8001b6 <cprintf>
	if ((env = fork()) == 0) {
  800048:	e8 54 0e 00 00       	call   800ea1 <fork>
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	85 c0                	test   %eax,%eax
  800052:	75 12                	jne    800066 <umain+0x33>
		cprintf("I am the child.  Spinning...\n");
  800054:	83 ec 0c             	sub    $0xc,%esp
  800057:	68 d8 13 80 00       	push   $0x8013d8
  80005c:	e8 55 01 00 00       	call   8001b6 <cprintf>
  800061:	83 c4 10             	add    $0x10,%esp
  800064:	eb fe                	jmp    800064 <umain+0x31>
  800066:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800068:	83 ec 0c             	sub    $0xc,%esp
  80006b:	68 88 13 80 00       	push   $0x801388
  800070:	e8 41 01 00 00       	call   8001b6 <cprintf>
	sys_yield();
  800075:	e8 64 0b 00 00       	call   800bde <sys_yield>
	sys_yield();
  80007a:	e8 5f 0b 00 00       	call   800bde <sys_yield>
	sys_yield();
  80007f:	e8 5a 0b 00 00       	call   800bde <sys_yield>
	sys_yield();
  800084:	e8 55 0b 00 00       	call   800bde <sys_yield>
	sys_yield();
  800089:	e8 50 0b 00 00       	call   800bde <sys_yield>
	sys_yield();
  80008e:	e8 4b 0b 00 00       	call   800bde <sys_yield>
	sys_yield();
  800093:	e8 46 0b 00 00       	call   800bde <sys_yield>
	sys_yield();
  800098:	e8 41 0b 00 00       	call   800bde <sys_yield>

    cprintf("I am the parent.  Killing the child...\n");
  80009d:	c7 04 24 b0 13 80 00 	movl   $0x8013b0,(%esp)
  8000a4:	e8 0d 01 00 00       	call   8001b6 <cprintf>
	sys_env_destroy(env);
  8000a9:	89 1c 24             	mov    %ebx,(%esp)
  8000ac:	e8 c5 0a 00 00       	call   800b76 <sys_env_destroy>
}
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b7:	c9                   	leave  
  8000b8:	c3                   	ret    

008000b9 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b9:	f3 0f 1e fb          	endbr32 
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
  8000c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    envid_t envid = sys_getenvid();
  8000c8:	e8 ee 0a 00 00       	call   800bbb <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  8000cd:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000da:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000df:	85 db                	test   %ebx,%ebx
  8000e1:	7e 07                	jle    8000ea <libmain+0x31>
		binaryname = argv[0];
  8000e3:	8b 06                	mov    (%esi),%eax
  8000e5:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ea:	83 ec 08             	sub    $0x8,%esp
  8000ed:	56                   	push   %esi
  8000ee:	53                   	push   %ebx
  8000ef:	e8 3f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f4:	e8 0a 00 00 00       	call   800103 <exit>
}
  8000f9:	83 c4 10             	add    $0x10,%esp
  8000fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ff:	5b                   	pop    %ebx
  800100:	5e                   	pop    %esi
  800101:	5d                   	pop    %ebp
  800102:	c3                   	ret    

00800103 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800103:	f3 0f 1e fb          	endbr32 
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80010d:	6a 00                	push   $0x0
  80010f:	e8 62 0a 00 00       	call   800b76 <sys_env_destroy>
}
  800114:	83 c4 10             	add    $0x10,%esp
  800117:	c9                   	leave  
  800118:	c3                   	ret    

00800119 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800119:	f3 0f 1e fb          	endbr32 
  80011d:	55                   	push   %ebp
  80011e:	89 e5                	mov    %esp,%ebp
  800120:	53                   	push   %ebx
  800121:	83 ec 04             	sub    $0x4,%esp
  800124:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800127:	8b 13                	mov    (%ebx),%edx
  800129:	8d 42 01             	lea    0x1(%edx),%eax
  80012c:	89 03                	mov    %eax,(%ebx)
  80012e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800131:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800135:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013a:	74 09                	je     800145 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80013c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800140:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800143:	c9                   	leave  
  800144:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800145:	83 ec 08             	sub    $0x8,%esp
  800148:	68 ff 00 00 00       	push   $0xff
  80014d:	8d 43 08             	lea    0x8(%ebx),%eax
  800150:	50                   	push   %eax
  800151:	e8 db 09 00 00       	call   800b31 <sys_cputs>
		b->idx = 0;
  800156:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80015c:	83 c4 10             	add    $0x10,%esp
  80015f:	eb db                	jmp    80013c <putch+0x23>

00800161 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800161:	f3 0f 1e fb          	endbr32 
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80016e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800175:	00 00 00 
	b.cnt = 0;
  800178:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800182:	ff 75 0c             	pushl  0xc(%ebp)
  800185:	ff 75 08             	pushl  0x8(%ebp)
  800188:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018e:	50                   	push   %eax
  80018f:	68 19 01 80 00       	push   $0x800119
  800194:	e8 20 01 00 00       	call   8002b9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800199:	83 c4 08             	add    $0x8,%esp
  80019c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a8:	50                   	push   %eax
  8001a9:	e8 83 09 00 00       	call   800b31 <sys_cputs>

	return b.cnt;
}
  8001ae:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b4:	c9                   	leave  
  8001b5:	c3                   	ret    

008001b6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b6:	f3 0f 1e fb          	endbr32 
  8001ba:	55                   	push   %ebp
  8001bb:	89 e5                	mov    %esp,%ebp
  8001bd:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001c0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001c3:	50                   	push   %eax
  8001c4:	ff 75 08             	pushl  0x8(%ebp)
  8001c7:	e8 95 ff ff ff       	call   800161 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001cc:	c9                   	leave  
  8001cd:	c3                   	ret    

008001ce <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ce:	55                   	push   %ebp
  8001cf:	89 e5                	mov    %esp,%ebp
  8001d1:	57                   	push   %edi
  8001d2:	56                   	push   %esi
  8001d3:	53                   	push   %ebx
  8001d4:	83 ec 1c             	sub    $0x1c,%esp
  8001d7:	89 c7                	mov    %eax,%edi
  8001d9:	89 d6                	mov    %edx,%esi
  8001db:	8b 45 08             	mov    0x8(%ebp),%eax
  8001de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e1:	89 d1                	mov    %edx,%ecx
  8001e3:	89 c2                	mov    %eax,%edx
  8001e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001e8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001eb:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ee:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001f4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001fb:	39 c2                	cmp    %eax,%edx
  8001fd:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800200:	72 3e                	jb     800240 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	ff 75 18             	pushl  0x18(%ebp)
  800208:	83 eb 01             	sub    $0x1,%ebx
  80020b:	53                   	push   %ebx
  80020c:	50                   	push   %eax
  80020d:	83 ec 08             	sub    $0x8,%esp
  800210:	ff 75 e4             	pushl  -0x1c(%ebp)
  800213:	ff 75 e0             	pushl  -0x20(%ebp)
  800216:	ff 75 dc             	pushl  -0x24(%ebp)
  800219:	ff 75 d8             	pushl  -0x28(%ebp)
  80021c:	e8 df 0e 00 00       	call   801100 <__udivdi3>
  800221:	83 c4 18             	add    $0x18,%esp
  800224:	52                   	push   %edx
  800225:	50                   	push   %eax
  800226:	89 f2                	mov    %esi,%edx
  800228:	89 f8                	mov    %edi,%eax
  80022a:	e8 9f ff ff ff       	call   8001ce <printnum>
  80022f:	83 c4 20             	add    $0x20,%esp
  800232:	eb 13                	jmp    800247 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800234:	83 ec 08             	sub    $0x8,%esp
  800237:	56                   	push   %esi
  800238:	ff 75 18             	pushl  0x18(%ebp)
  80023b:	ff d7                	call   *%edi
  80023d:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800240:	83 eb 01             	sub    $0x1,%ebx
  800243:	85 db                	test   %ebx,%ebx
  800245:	7f ed                	jg     800234 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800247:	83 ec 08             	sub    $0x8,%esp
  80024a:	56                   	push   %esi
  80024b:	83 ec 04             	sub    $0x4,%esp
  80024e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800251:	ff 75 e0             	pushl  -0x20(%ebp)
  800254:	ff 75 dc             	pushl  -0x24(%ebp)
  800257:	ff 75 d8             	pushl  -0x28(%ebp)
  80025a:	e8 b1 0f 00 00       	call   801210 <__umoddi3>
  80025f:	83 c4 14             	add    $0x14,%esp
  800262:	0f be 80 00 14 80 00 	movsbl 0x801400(%eax),%eax
  800269:	50                   	push   %eax
  80026a:	ff d7                	call   *%edi
}
  80026c:	83 c4 10             	add    $0x10,%esp
  80026f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800272:	5b                   	pop    %ebx
  800273:	5e                   	pop    %esi
  800274:	5f                   	pop    %edi
  800275:	5d                   	pop    %ebp
  800276:	c3                   	ret    

00800277 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800277:	f3 0f 1e fb          	endbr32 
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800281:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800285:	8b 10                	mov    (%eax),%edx
  800287:	3b 50 04             	cmp    0x4(%eax),%edx
  80028a:	73 0a                	jae    800296 <sprintputch+0x1f>
		*b->buf++ = ch;
  80028c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80028f:	89 08                	mov    %ecx,(%eax)
  800291:	8b 45 08             	mov    0x8(%ebp),%eax
  800294:	88 02                	mov    %al,(%edx)
}
  800296:	5d                   	pop    %ebp
  800297:	c3                   	ret    

00800298 <printfmt>:
{
  800298:	f3 0f 1e fb          	endbr32 
  80029c:	55                   	push   %ebp
  80029d:	89 e5                	mov    %esp,%ebp
  80029f:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002a2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002a5:	50                   	push   %eax
  8002a6:	ff 75 10             	pushl  0x10(%ebp)
  8002a9:	ff 75 0c             	pushl  0xc(%ebp)
  8002ac:	ff 75 08             	pushl  0x8(%ebp)
  8002af:	e8 05 00 00 00       	call   8002b9 <vprintfmt>
}
  8002b4:	83 c4 10             	add    $0x10,%esp
  8002b7:	c9                   	leave  
  8002b8:	c3                   	ret    

008002b9 <vprintfmt>:
{
  8002b9:	f3 0f 1e fb          	endbr32 
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	57                   	push   %edi
  8002c1:	56                   	push   %esi
  8002c2:	53                   	push   %ebx
  8002c3:	83 ec 3c             	sub    $0x3c,%esp
  8002c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8002c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002cc:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002cf:	e9 4a 03 00 00       	jmp    80061e <vprintfmt+0x365>
		padc = ' ';
  8002d4:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002d8:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002df:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002e6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002ed:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002f2:	8d 47 01             	lea    0x1(%edi),%eax
  8002f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002f8:	0f b6 17             	movzbl (%edi),%edx
  8002fb:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002fe:	3c 55                	cmp    $0x55,%al
  800300:	0f 87 de 03 00 00    	ja     8006e4 <vprintfmt+0x42b>
  800306:	0f b6 c0             	movzbl %al,%eax
  800309:	3e ff 24 85 c0 14 80 	notrack jmp *0x8014c0(,%eax,4)
  800310:	00 
  800311:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800314:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800318:	eb d8                	jmp    8002f2 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80031a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80031d:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800321:	eb cf                	jmp    8002f2 <vprintfmt+0x39>
  800323:	0f b6 d2             	movzbl %dl,%edx
  800326:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800329:	b8 00 00 00 00       	mov    $0x0,%eax
  80032e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800331:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800334:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800338:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80033b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80033e:	83 f9 09             	cmp    $0x9,%ecx
  800341:	77 55                	ja     800398 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800343:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800346:	eb e9                	jmp    800331 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800348:	8b 45 14             	mov    0x14(%ebp),%eax
  80034b:	8b 00                	mov    (%eax),%eax
  80034d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800350:	8b 45 14             	mov    0x14(%ebp),%eax
  800353:	8d 40 04             	lea    0x4(%eax),%eax
  800356:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800359:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80035c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800360:	79 90                	jns    8002f2 <vprintfmt+0x39>
				width = precision, precision = -1;
  800362:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800365:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800368:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80036f:	eb 81                	jmp    8002f2 <vprintfmt+0x39>
  800371:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800374:	85 c0                	test   %eax,%eax
  800376:	ba 00 00 00 00       	mov    $0x0,%edx
  80037b:	0f 49 d0             	cmovns %eax,%edx
  80037e:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800381:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800384:	e9 69 ff ff ff       	jmp    8002f2 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800389:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80038c:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800393:	e9 5a ff ff ff       	jmp    8002f2 <vprintfmt+0x39>
  800398:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80039b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80039e:	eb bc                	jmp    80035c <vprintfmt+0xa3>
			lflag++;
  8003a0:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003a6:	e9 47 ff ff ff       	jmp    8002f2 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ae:	8d 78 04             	lea    0x4(%eax),%edi
  8003b1:	83 ec 08             	sub    $0x8,%esp
  8003b4:	53                   	push   %ebx
  8003b5:	ff 30                	pushl  (%eax)
  8003b7:	ff d6                	call   *%esi
			break;
  8003b9:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003bc:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003bf:	e9 57 02 00 00       	jmp    80061b <vprintfmt+0x362>
			err = va_arg(ap, int);
  8003c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c7:	8d 78 04             	lea    0x4(%eax),%edi
  8003ca:	8b 00                	mov    (%eax),%eax
  8003cc:	99                   	cltd   
  8003cd:	31 d0                	xor    %edx,%eax
  8003cf:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003d1:	83 f8 08             	cmp    $0x8,%eax
  8003d4:	7f 23                	jg     8003f9 <vprintfmt+0x140>
  8003d6:	8b 14 85 20 16 80 00 	mov    0x801620(,%eax,4),%edx
  8003dd:	85 d2                	test   %edx,%edx
  8003df:	74 18                	je     8003f9 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8003e1:	52                   	push   %edx
  8003e2:	68 21 14 80 00       	push   $0x801421
  8003e7:	53                   	push   %ebx
  8003e8:	56                   	push   %esi
  8003e9:	e8 aa fe ff ff       	call   800298 <printfmt>
  8003ee:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003f1:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003f4:	e9 22 02 00 00       	jmp    80061b <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8003f9:	50                   	push   %eax
  8003fa:	68 18 14 80 00       	push   $0x801418
  8003ff:	53                   	push   %ebx
  800400:	56                   	push   %esi
  800401:	e8 92 fe ff ff       	call   800298 <printfmt>
  800406:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800409:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80040c:	e9 0a 02 00 00       	jmp    80061b <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  800411:	8b 45 14             	mov    0x14(%ebp),%eax
  800414:	83 c0 04             	add    $0x4,%eax
  800417:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80041a:	8b 45 14             	mov    0x14(%ebp),%eax
  80041d:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80041f:	85 d2                	test   %edx,%edx
  800421:	b8 11 14 80 00       	mov    $0x801411,%eax
  800426:	0f 45 c2             	cmovne %edx,%eax
  800429:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80042c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800430:	7e 06                	jle    800438 <vprintfmt+0x17f>
  800432:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800436:	75 0d                	jne    800445 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800438:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80043b:	89 c7                	mov    %eax,%edi
  80043d:	03 45 e0             	add    -0x20(%ebp),%eax
  800440:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800443:	eb 55                	jmp    80049a <vprintfmt+0x1e1>
  800445:	83 ec 08             	sub    $0x8,%esp
  800448:	ff 75 d8             	pushl  -0x28(%ebp)
  80044b:	ff 75 cc             	pushl  -0x34(%ebp)
  80044e:	e8 45 03 00 00       	call   800798 <strnlen>
  800453:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800456:	29 c2                	sub    %eax,%edx
  800458:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80045b:	83 c4 10             	add    $0x10,%esp
  80045e:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800460:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800464:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800467:	85 ff                	test   %edi,%edi
  800469:	7e 11                	jle    80047c <vprintfmt+0x1c3>
					putch(padc, putdat);
  80046b:	83 ec 08             	sub    $0x8,%esp
  80046e:	53                   	push   %ebx
  80046f:	ff 75 e0             	pushl  -0x20(%ebp)
  800472:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800474:	83 ef 01             	sub    $0x1,%edi
  800477:	83 c4 10             	add    $0x10,%esp
  80047a:	eb eb                	jmp    800467 <vprintfmt+0x1ae>
  80047c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80047f:	85 d2                	test   %edx,%edx
  800481:	b8 00 00 00 00       	mov    $0x0,%eax
  800486:	0f 49 c2             	cmovns %edx,%eax
  800489:	29 c2                	sub    %eax,%edx
  80048b:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80048e:	eb a8                	jmp    800438 <vprintfmt+0x17f>
					putch(ch, putdat);
  800490:	83 ec 08             	sub    $0x8,%esp
  800493:	53                   	push   %ebx
  800494:	52                   	push   %edx
  800495:	ff d6                	call   *%esi
  800497:	83 c4 10             	add    $0x10,%esp
  80049a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80049d:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049f:	83 c7 01             	add    $0x1,%edi
  8004a2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004a6:	0f be d0             	movsbl %al,%edx
  8004a9:	85 d2                	test   %edx,%edx
  8004ab:	74 4b                	je     8004f8 <vprintfmt+0x23f>
  8004ad:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b1:	78 06                	js     8004b9 <vprintfmt+0x200>
  8004b3:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004b7:	78 1e                	js     8004d7 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004b9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004bd:	74 d1                	je     800490 <vprintfmt+0x1d7>
  8004bf:	0f be c0             	movsbl %al,%eax
  8004c2:	83 e8 20             	sub    $0x20,%eax
  8004c5:	83 f8 5e             	cmp    $0x5e,%eax
  8004c8:	76 c6                	jbe    800490 <vprintfmt+0x1d7>
					putch('?', putdat);
  8004ca:	83 ec 08             	sub    $0x8,%esp
  8004cd:	53                   	push   %ebx
  8004ce:	6a 3f                	push   $0x3f
  8004d0:	ff d6                	call   *%esi
  8004d2:	83 c4 10             	add    $0x10,%esp
  8004d5:	eb c3                	jmp    80049a <vprintfmt+0x1e1>
  8004d7:	89 cf                	mov    %ecx,%edi
  8004d9:	eb 0e                	jmp    8004e9 <vprintfmt+0x230>
				putch(' ', putdat);
  8004db:	83 ec 08             	sub    $0x8,%esp
  8004de:	53                   	push   %ebx
  8004df:	6a 20                	push   $0x20
  8004e1:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004e3:	83 ef 01             	sub    $0x1,%edi
  8004e6:	83 c4 10             	add    $0x10,%esp
  8004e9:	85 ff                	test   %edi,%edi
  8004eb:	7f ee                	jg     8004db <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8004ed:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004f0:	89 45 14             	mov    %eax,0x14(%ebp)
  8004f3:	e9 23 01 00 00       	jmp    80061b <vprintfmt+0x362>
  8004f8:	89 cf                	mov    %ecx,%edi
  8004fa:	eb ed                	jmp    8004e9 <vprintfmt+0x230>
	if (lflag >= 2)
  8004fc:	83 f9 01             	cmp    $0x1,%ecx
  8004ff:	7f 1b                	jg     80051c <vprintfmt+0x263>
	else if (lflag)
  800501:	85 c9                	test   %ecx,%ecx
  800503:	74 63                	je     800568 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800505:	8b 45 14             	mov    0x14(%ebp),%eax
  800508:	8b 00                	mov    (%eax),%eax
  80050a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80050d:	99                   	cltd   
  80050e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800511:	8b 45 14             	mov    0x14(%ebp),%eax
  800514:	8d 40 04             	lea    0x4(%eax),%eax
  800517:	89 45 14             	mov    %eax,0x14(%ebp)
  80051a:	eb 17                	jmp    800533 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80051c:	8b 45 14             	mov    0x14(%ebp),%eax
  80051f:	8b 50 04             	mov    0x4(%eax),%edx
  800522:	8b 00                	mov    (%eax),%eax
  800524:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800527:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80052a:	8b 45 14             	mov    0x14(%ebp),%eax
  80052d:	8d 40 08             	lea    0x8(%eax),%eax
  800530:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800533:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800536:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800539:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80053e:	85 c9                	test   %ecx,%ecx
  800540:	0f 89 bb 00 00 00    	jns    800601 <vprintfmt+0x348>
				putch('-', putdat);
  800546:	83 ec 08             	sub    $0x8,%esp
  800549:	53                   	push   %ebx
  80054a:	6a 2d                	push   $0x2d
  80054c:	ff d6                	call   *%esi
				num = -(long long) num;
  80054e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800551:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800554:	f7 da                	neg    %edx
  800556:	83 d1 00             	adc    $0x0,%ecx
  800559:	f7 d9                	neg    %ecx
  80055b:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80055e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800563:	e9 99 00 00 00       	jmp    800601 <vprintfmt+0x348>
		return va_arg(*ap, int);
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8b 00                	mov    (%eax),%eax
  80056d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800570:	99                   	cltd   
  800571:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8d 40 04             	lea    0x4(%eax),%eax
  80057a:	89 45 14             	mov    %eax,0x14(%ebp)
  80057d:	eb b4                	jmp    800533 <vprintfmt+0x27a>
	if (lflag >= 2)
  80057f:	83 f9 01             	cmp    $0x1,%ecx
  800582:	7f 1b                	jg     80059f <vprintfmt+0x2e6>
	else if (lflag)
  800584:	85 c9                	test   %ecx,%ecx
  800586:	74 2c                	je     8005b4 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800588:	8b 45 14             	mov    0x14(%ebp),%eax
  80058b:	8b 10                	mov    (%eax),%edx
  80058d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800592:	8d 40 04             	lea    0x4(%eax),%eax
  800595:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800598:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80059d:	eb 62                	jmp    800601 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80059f:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a2:	8b 10                	mov    (%eax),%edx
  8005a4:	8b 48 04             	mov    0x4(%eax),%ecx
  8005a7:	8d 40 08             	lea    0x8(%eax),%eax
  8005aa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ad:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005b2:	eb 4d                	jmp    800601 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8b 10                	mov    (%eax),%edx
  8005b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005be:	8d 40 04             	lea    0x4(%eax),%eax
  8005c1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005c4:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8005c9:	eb 36                	jmp    800601 <vprintfmt+0x348>
	if (lflag >= 2)
  8005cb:	83 f9 01             	cmp    $0x1,%ecx
  8005ce:	7f 17                	jg     8005e7 <vprintfmt+0x32e>
	else if (lflag)
  8005d0:	85 c9                	test   %ecx,%ecx
  8005d2:	74 6e                	je     800642 <vprintfmt+0x389>
		return va_arg(*ap, long);
  8005d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d7:	8b 10                	mov    (%eax),%edx
  8005d9:	89 d0                	mov    %edx,%eax
  8005db:	99                   	cltd   
  8005dc:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005df:	8d 49 04             	lea    0x4(%ecx),%ecx
  8005e2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005e5:	eb 11                	jmp    8005f8 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8005e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ea:	8b 50 04             	mov    0x4(%eax),%edx
  8005ed:	8b 00                	mov    (%eax),%eax
  8005ef:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005f2:	8d 49 08             	lea    0x8(%ecx),%ecx
  8005f5:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8005f8:	89 d1                	mov    %edx,%ecx
  8005fa:	89 c2                	mov    %eax,%edx
            base = 8;
  8005fc:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800601:	83 ec 0c             	sub    $0xc,%esp
  800604:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800608:	57                   	push   %edi
  800609:	ff 75 e0             	pushl  -0x20(%ebp)
  80060c:	50                   	push   %eax
  80060d:	51                   	push   %ecx
  80060e:	52                   	push   %edx
  80060f:	89 da                	mov    %ebx,%edx
  800611:	89 f0                	mov    %esi,%eax
  800613:	e8 b6 fb ff ff       	call   8001ce <printnum>
			break;
  800618:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80061b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80061e:	83 c7 01             	add    $0x1,%edi
  800621:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800625:	83 f8 25             	cmp    $0x25,%eax
  800628:	0f 84 a6 fc ff ff    	je     8002d4 <vprintfmt+0x1b>
			if (ch == '\0')
  80062e:	85 c0                	test   %eax,%eax
  800630:	0f 84 ce 00 00 00    	je     800704 <vprintfmt+0x44b>
			putch(ch, putdat);
  800636:	83 ec 08             	sub    $0x8,%esp
  800639:	53                   	push   %ebx
  80063a:	50                   	push   %eax
  80063b:	ff d6                	call   *%esi
  80063d:	83 c4 10             	add    $0x10,%esp
  800640:	eb dc                	jmp    80061e <vprintfmt+0x365>
		return va_arg(*ap, int);
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8b 10                	mov    (%eax),%edx
  800647:	89 d0                	mov    %edx,%eax
  800649:	99                   	cltd   
  80064a:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80064d:	8d 49 04             	lea    0x4(%ecx),%ecx
  800650:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800653:	eb a3                	jmp    8005f8 <vprintfmt+0x33f>
			putch('0', putdat);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	53                   	push   %ebx
  800659:	6a 30                	push   $0x30
  80065b:	ff d6                	call   *%esi
			putch('x', putdat);
  80065d:	83 c4 08             	add    $0x8,%esp
  800660:	53                   	push   %ebx
  800661:	6a 78                	push   $0x78
  800663:	ff d6                	call   *%esi
			num = (unsigned long long)
  800665:	8b 45 14             	mov    0x14(%ebp),%eax
  800668:	8b 10                	mov    (%eax),%edx
  80066a:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80066f:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800672:	8d 40 04             	lea    0x4(%eax),%eax
  800675:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800678:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80067d:	eb 82                	jmp    800601 <vprintfmt+0x348>
	if (lflag >= 2)
  80067f:	83 f9 01             	cmp    $0x1,%ecx
  800682:	7f 1e                	jg     8006a2 <vprintfmt+0x3e9>
	else if (lflag)
  800684:	85 c9                	test   %ecx,%ecx
  800686:	74 32                	je     8006ba <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8b 10                	mov    (%eax),%edx
  80068d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800692:	8d 40 04             	lea    0x4(%eax),%eax
  800695:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800698:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80069d:	e9 5f ff ff ff       	jmp    800601 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8006a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a5:	8b 10                	mov    (%eax),%edx
  8006a7:	8b 48 04             	mov    0x4(%eax),%ecx
  8006aa:	8d 40 08             	lea    0x8(%eax),%eax
  8006ad:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b0:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006b5:	e9 47 ff ff ff       	jmp    800601 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8006ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bd:	8b 10                	mov    (%eax),%edx
  8006bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c4:	8d 40 04             	lea    0x4(%eax),%eax
  8006c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ca:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006cf:	e9 2d ff ff ff       	jmp    800601 <vprintfmt+0x348>
			putch(ch, putdat);
  8006d4:	83 ec 08             	sub    $0x8,%esp
  8006d7:	53                   	push   %ebx
  8006d8:	6a 25                	push   $0x25
  8006da:	ff d6                	call   *%esi
			break;
  8006dc:	83 c4 10             	add    $0x10,%esp
  8006df:	e9 37 ff ff ff       	jmp    80061b <vprintfmt+0x362>
			putch('%', putdat);
  8006e4:	83 ec 08             	sub    $0x8,%esp
  8006e7:	53                   	push   %ebx
  8006e8:	6a 25                	push   $0x25
  8006ea:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ec:	83 c4 10             	add    $0x10,%esp
  8006ef:	89 f8                	mov    %edi,%eax
  8006f1:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006f5:	74 05                	je     8006fc <vprintfmt+0x443>
  8006f7:	83 e8 01             	sub    $0x1,%eax
  8006fa:	eb f5                	jmp    8006f1 <vprintfmt+0x438>
  8006fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006ff:	e9 17 ff ff ff       	jmp    80061b <vprintfmt+0x362>
}
  800704:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800707:	5b                   	pop    %ebx
  800708:	5e                   	pop    %esi
  800709:	5f                   	pop    %edi
  80070a:	5d                   	pop    %ebp
  80070b:	c3                   	ret    

0080070c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80070c:	f3 0f 1e fb          	endbr32 
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	83 ec 18             	sub    $0x18,%esp
  800716:	8b 45 08             	mov    0x8(%ebp),%eax
  800719:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80071c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80071f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800723:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800726:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80072d:	85 c0                	test   %eax,%eax
  80072f:	74 26                	je     800757 <vsnprintf+0x4b>
  800731:	85 d2                	test   %edx,%edx
  800733:	7e 22                	jle    800757 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800735:	ff 75 14             	pushl  0x14(%ebp)
  800738:	ff 75 10             	pushl  0x10(%ebp)
  80073b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80073e:	50                   	push   %eax
  80073f:	68 77 02 80 00       	push   $0x800277
  800744:	e8 70 fb ff ff       	call   8002b9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800749:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80074c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80074f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800752:	83 c4 10             	add    $0x10,%esp
}
  800755:	c9                   	leave  
  800756:	c3                   	ret    
		return -E_INVAL;
  800757:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80075c:	eb f7                	jmp    800755 <vsnprintf+0x49>

0080075e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80075e:	f3 0f 1e fb          	endbr32 
  800762:	55                   	push   %ebp
  800763:	89 e5                	mov    %esp,%ebp
  800765:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800768:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076b:	50                   	push   %eax
  80076c:	ff 75 10             	pushl  0x10(%ebp)
  80076f:	ff 75 0c             	pushl  0xc(%ebp)
  800772:	ff 75 08             	pushl  0x8(%ebp)
  800775:	e8 92 ff ff ff       	call   80070c <vsnprintf>
	va_end(ap);

	return rc;
}
  80077a:	c9                   	leave  
  80077b:	c3                   	ret    

0080077c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80077c:	f3 0f 1e fb          	endbr32 
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800786:	b8 00 00 00 00       	mov    $0x0,%eax
  80078b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80078f:	74 05                	je     800796 <strlen+0x1a>
		n++;
  800791:	83 c0 01             	add    $0x1,%eax
  800794:	eb f5                	jmp    80078b <strlen+0xf>
	return n;
}
  800796:	5d                   	pop    %ebp
  800797:	c3                   	ret    

00800798 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800798:	f3 0f 1e fb          	endbr32 
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8007aa:	39 d0                	cmp    %edx,%eax
  8007ac:	74 0d                	je     8007bb <strnlen+0x23>
  8007ae:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007b2:	74 05                	je     8007b9 <strnlen+0x21>
		n++;
  8007b4:	83 c0 01             	add    $0x1,%eax
  8007b7:	eb f1                	jmp    8007aa <strnlen+0x12>
  8007b9:	89 c2                	mov    %eax,%edx
	return n;
}
  8007bb:	89 d0                	mov    %edx,%eax
  8007bd:	5d                   	pop    %ebp
  8007be:	c3                   	ret    

008007bf <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007bf:	f3 0f 1e fb          	endbr32 
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
  8007c6:	53                   	push   %ebx
  8007c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d2:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007d6:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007d9:	83 c0 01             	add    $0x1,%eax
  8007dc:	84 d2                	test   %dl,%dl
  8007de:	75 f2                	jne    8007d2 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8007e0:	89 c8                	mov    %ecx,%eax
  8007e2:	5b                   	pop    %ebx
  8007e3:	5d                   	pop    %ebp
  8007e4:	c3                   	ret    

008007e5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e5:	f3 0f 1e fb          	endbr32 
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	53                   	push   %ebx
  8007ed:	83 ec 10             	sub    $0x10,%esp
  8007f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f3:	53                   	push   %ebx
  8007f4:	e8 83 ff ff ff       	call   80077c <strlen>
  8007f9:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007fc:	ff 75 0c             	pushl  0xc(%ebp)
  8007ff:	01 d8                	add    %ebx,%eax
  800801:	50                   	push   %eax
  800802:	e8 b8 ff ff ff       	call   8007bf <strcpy>
	return dst;
}
  800807:	89 d8                	mov    %ebx,%eax
  800809:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80080c:	c9                   	leave  
  80080d:	c3                   	ret    

0080080e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80080e:	f3 0f 1e fb          	endbr32 
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	56                   	push   %esi
  800816:	53                   	push   %ebx
  800817:	8b 75 08             	mov    0x8(%ebp),%esi
  80081a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081d:	89 f3                	mov    %esi,%ebx
  80081f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800822:	89 f0                	mov    %esi,%eax
  800824:	39 d8                	cmp    %ebx,%eax
  800826:	74 11                	je     800839 <strncpy+0x2b>
		*dst++ = *src;
  800828:	83 c0 01             	add    $0x1,%eax
  80082b:	0f b6 0a             	movzbl (%edx),%ecx
  80082e:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800831:	80 f9 01             	cmp    $0x1,%cl
  800834:	83 da ff             	sbb    $0xffffffff,%edx
  800837:	eb eb                	jmp    800824 <strncpy+0x16>
	}
	return ret;
}
  800839:	89 f0                	mov    %esi,%eax
  80083b:	5b                   	pop    %ebx
  80083c:	5e                   	pop    %esi
  80083d:	5d                   	pop    %ebp
  80083e:	c3                   	ret    

0080083f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80083f:	f3 0f 1e fb          	endbr32 
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	56                   	push   %esi
  800847:	53                   	push   %ebx
  800848:	8b 75 08             	mov    0x8(%ebp),%esi
  80084b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80084e:	8b 55 10             	mov    0x10(%ebp),%edx
  800851:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800853:	85 d2                	test   %edx,%edx
  800855:	74 21                	je     800878 <strlcpy+0x39>
  800857:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80085b:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80085d:	39 c2                	cmp    %eax,%edx
  80085f:	74 14                	je     800875 <strlcpy+0x36>
  800861:	0f b6 19             	movzbl (%ecx),%ebx
  800864:	84 db                	test   %bl,%bl
  800866:	74 0b                	je     800873 <strlcpy+0x34>
			*dst++ = *src++;
  800868:	83 c1 01             	add    $0x1,%ecx
  80086b:	83 c2 01             	add    $0x1,%edx
  80086e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800871:	eb ea                	jmp    80085d <strlcpy+0x1e>
  800873:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800875:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800878:	29 f0                	sub    %esi,%eax
}
  80087a:	5b                   	pop    %ebx
  80087b:	5e                   	pop    %esi
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80087e:	f3 0f 1e fb          	endbr32 
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800888:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80088b:	0f b6 01             	movzbl (%ecx),%eax
  80088e:	84 c0                	test   %al,%al
  800890:	74 0c                	je     80089e <strcmp+0x20>
  800892:	3a 02                	cmp    (%edx),%al
  800894:	75 08                	jne    80089e <strcmp+0x20>
		p++, q++;
  800896:	83 c1 01             	add    $0x1,%ecx
  800899:	83 c2 01             	add    $0x1,%edx
  80089c:	eb ed                	jmp    80088b <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80089e:	0f b6 c0             	movzbl %al,%eax
  8008a1:	0f b6 12             	movzbl (%edx),%edx
  8008a4:	29 d0                	sub    %edx,%eax
}
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    

008008a8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a8:	f3 0f 1e fb          	endbr32 
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	53                   	push   %ebx
  8008b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b6:	89 c3                	mov    %eax,%ebx
  8008b8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008bb:	eb 06                	jmp    8008c3 <strncmp+0x1b>
		n--, p++, q++;
  8008bd:	83 c0 01             	add    $0x1,%eax
  8008c0:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008c3:	39 d8                	cmp    %ebx,%eax
  8008c5:	74 16                	je     8008dd <strncmp+0x35>
  8008c7:	0f b6 08             	movzbl (%eax),%ecx
  8008ca:	84 c9                	test   %cl,%cl
  8008cc:	74 04                	je     8008d2 <strncmp+0x2a>
  8008ce:	3a 0a                	cmp    (%edx),%cl
  8008d0:	74 eb                	je     8008bd <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d2:	0f b6 00             	movzbl (%eax),%eax
  8008d5:	0f b6 12             	movzbl (%edx),%edx
  8008d8:	29 d0                	sub    %edx,%eax
}
  8008da:	5b                   	pop    %ebx
  8008db:	5d                   	pop    %ebp
  8008dc:	c3                   	ret    
		return 0;
  8008dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e2:	eb f6                	jmp    8008da <strncmp+0x32>

008008e4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e4:	f3 0f 1e fb          	endbr32 
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ee:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f2:	0f b6 10             	movzbl (%eax),%edx
  8008f5:	84 d2                	test   %dl,%dl
  8008f7:	74 09                	je     800902 <strchr+0x1e>
		if (*s == c)
  8008f9:	38 ca                	cmp    %cl,%dl
  8008fb:	74 0a                	je     800907 <strchr+0x23>
	for (; *s; s++)
  8008fd:	83 c0 01             	add    $0x1,%eax
  800900:	eb f0                	jmp    8008f2 <strchr+0xe>
			return (char *) s;
	return 0;
  800902:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800907:	5d                   	pop    %ebp
  800908:	c3                   	ret    

00800909 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800909:	f3 0f 1e fb          	endbr32 
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
  800910:	8b 45 08             	mov    0x8(%ebp),%eax
  800913:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800917:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80091a:	38 ca                	cmp    %cl,%dl
  80091c:	74 09                	je     800927 <strfind+0x1e>
  80091e:	84 d2                	test   %dl,%dl
  800920:	74 05                	je     800927 <strfind+0x1e>
	for (; *s; s++)
  800922:	83 c0 01             	add    $0x1,%eax
  800925:	eb f0                	jmp    800917 <strfind+0xe>
			break;
	return (char *) s;
}
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800929:	f3 0f 1e fb          	endbr32 
  80092d:	55                   	push   %ebp
  80092e:	89 e5                	mov    %esp,%ebp
  800930:	57                   	push   %edi
  800931:	56                   	push   %esi
  800932:	53                   	push   %ebx
  800933:	8b 7d 08             	mov    0x8(%ebp),%edi
  800936:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800939:	85 c9                	test   %ecx,%ecx
  80093b:	74 31                	je     80096e <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80093d:	89 f8                	mov    %edi,%eax
  80093f:	09 c8                	or     %ecx,%eax
  800941:	a8 03                	test   $0x3,%al
  800943:	75 23                	jne    800968 <memset+0x3f>
		c &= 0xFF;
  800945:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800949:	89 d3                	mov    %edx,%ebx
  80094b:	c1 e3 08             	shl    $0x8,%ebx
  80094e:	89 d0                	mov    %edx,%eax
  800950:	c1 e0 18             	shl    $0x18,%eax
  800953:	89 d6                	mov    %edx,%esi
  800955:	c1 e6 10             	shl    $0x10,%esi
  800958:	09 f0                	or     %esi,%eax
  80095a:	09 c2                	or     %eax,%edx
  80095c:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80095e:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800961:	89 d0                	mov    %edx,%eax
  800963:	fc                   	cld    
  800964:	f3 ab                	rep stos %eax,%es:(%edi)
  800966:	eb 06                	jmp    80096e <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800968:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096b:	fc                   	cld    
  80096c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80096e:	89 f8                	mov    %edi,%eax
  800970:	5b                   	pop    %ebx
  800971:	5e                   	pop    %esi
  800972:	5f                   	pop    %edi
  800973:	5d                   	pop    %ebp
  800974:	c3                   	ret    

00800975 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800975:	f3 0f 1e fb          	endbr32 
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
  80097c:	57                   	push   %edi
  80097d:	56                   	push   %esi
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	8b 75 0c             	mov    0xc(%ebp),%esi
  800984:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800987:	39 c6                	cmp    %eax,%esi
  800989:	73 32                	jae    8009bd <memmove+0x48>
  80098b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80098e:	39 c2                	cmp    %eax,%edx
  800990:	76 2b                	jbe    8009bd <memmove+0x48>
		s += n;
		d += n;
  800992:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800995:	89 fe                	mov    %edi,%esi
  800997:	09 ce                	or     %ecx,%esi
  800999:	09 d6                	or     %edx,%esi
  80099b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a1:	75 0e                	jne    8009b1 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009a3:	83 ef 04             	sub    $0x4,%edi
  8009a6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009ac:	fd                   	std    
  8009ad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009af:	eb 09                	jmp    8009ba <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009b1:	83 ef 01             	sub    $0x1,%edi
  8009b4:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009b7:	fd                   	std    
  8009b8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ba:	fc                   	cld    
  8009bb:	eb 1a                	jmp    8009d7 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009bd:	89 c2                	mov    %eax,%edx
  8009bf:	09 ca                	or     %ecx,%edx
  8009c1:	09 f2                	or     %esi,%edx
  8009c3:	f6 c2 03             	test   $0x3,%dl
  8009c6:	75 0a                	jne    8009d2 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009c8:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009cb:	89 c7                	mov    %eax,%edi
  8009cd:	fc                   	cld    
  8009ce:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d0:	eb 05                	jmp    8009d7 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8009d2:	89 c7                	mov    %eax,%edi
  8009d4:	fc                   	cld    
  8009d5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d7:	5e                   	pop    %esi
  8009d8:	5f                   	pop    %edi
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009db:	f3 0f 1e fb          	endbr32 
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009e5:	ff 75 10             	pushl  0x10(%ebp)
  8009e8:	ff 75 0c             	pushl  0xc(%ebp)
  8009eb:	ff 75 08             	pushl  0x8(%ebp)
  8009ee:	e8 82 ff ff ff       	call   800975 <memmove>
}
  8009f3:	c9                   	leave  
  8009f4:	c3                   	ret    

008009f5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f5:	f3 0f 1e fb          	endbr32 
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
  8009fc:	56                   	push   %esi
  8009fd:	53                   	push   %ebx
  8009fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800a01:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a04:	89 c6                	mov    %eax,%esi
  800a06:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a09:	39 f0                	cmp    %esi,%eax
  800a0b:	74 1c                	je     800a29 <memcmp+0x34>
		if (*s1 != *s2)
  800a0d:	0f b6 08             	movzbl (%eax),%ecx
  800a10:	0f b6 1a             	movzbl (%edx),%ebx
  800a13:	38 d9                	cmp    %bl,%cl
  800a15:	75 08                	jne    800a1f <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a17:	83 c0 01             	add    $0x1,%eax
  800a1a:	83 c2 01             	add    $0x1,%edx
  800a1d:	eb ea                	jmp    800a09 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a1f:	0f b6 c1             	movzbl %cl,%eax
  800a22:	0f b6 db             	movzbl %bl,%ebx
  800a25:	29 d8                	sub    %ebx,%eax
  800a27:	eb 05                	jmp    800a2e <memcmp+0x39>
	}

	return 0;
  800a29:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2e:	5b                   	pop    %ebx
  800a2f:	5e                   	pop    %esi
  800a30:	5d                   	pop    %ebp
  800a31:	c3                   	ret    

00800a32 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a32:	f3 0f 1e fb          	endbr32 
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a3f:	89 c2                	mov    %eax,%edx
  800a41:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a44:	39 d0                	cmp    %edx,%eax
  800a46:	73 09                	jae    800a51 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a48:	38 08                	cmp    %cl,(%eax)
  800a4a:	74 05                	je     800a51 <memfind+0x1f>
	for (; s < ends; s++)
  800a4c:	83 c0 01             	add    $0x1,%eax
  800a4f:	eb f3                	jmp    800a44 <memfind+0x12>
			break;
	return (void *) s;
}
  800a51:	5d                   	pop    %ebp
  800a52:	c3                   	ret    

00800a53 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a53:	f3 0f 1e fb          	endbr32 
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	57                   	push   %edi
  800a5b:	56                   	push   %esi
  800a5c:	53                   	push   %ebx
  800a5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a60:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a63:	eb 03                	jmp    800a68 <strtol+0x15>
		s++;
  800a65:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a68:	0f b6 01             	movzbl (%ecx),%eax
  800a6b:	3c 20                	cmp    $0x20,%al
  800a6d:	74 f6                	je     800a65 <strtol+0x12>
  800a6f:	3c 09                	cmp    $0x9,%al
  800a71:	74 f2                	je     800a65 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a73:	3c 2b                	cmp    $0x2b,%al
  800a75:	74 2a                	je     800aa1 <strtol+0x4e>
	int neg = 0;
  800a77:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a7c:	3c 2d                	cmp    $0x2d,%al
  800a7e:	74 2b                	je     800aab <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a80:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a86:	75 0f                	jne    800a97 <strtol+0x44>
  800a88:	80 39 30             	cmpb   $0x30,(%ecx)
  800a8b:	74 28                	je     800ab5 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a8d:	85 db                	test   %ebx,%ebx
  800a8f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a94:	0f 44 d8             	cmove  %eax,%ebx
  800a97:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a9f:	eb 46                	jmp    800ae7 <strtol+0x94>
		s++;
  800aa1:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800aa4:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa9:	eb d5                	jmp    800a80 <strtol+0x2d>
		s++, neg = 1;
  800aab:	83 c1 01             	add    $0x1,%ecx
  800aae:	bf 01 00 00 00       	mov    $0x1,%edi
  800ab3:	eb cb                	jmp    800a80 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ab9:	74 0e                	je     800ac9 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800abb:	85 db                	test   %ebx,%ebx
  800abd:	75 d8                	jne    800a97 <strtol+0x44>
		s++, base = 8;
  800abf:	83 c1 01             	add    $0x1,%ecx
  800ac2:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ac7:	eb ce                	jmp    800a97 <strtol+0x44>
		s += 2, base = 16;
  800ac9:	83 c1 02             	add    $0x2,%ecx
  800acc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad1:	eb c4                	jmp    800a97 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ad3:	0f be d2             	movsbl %dl,%edx
  800ad6:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ad9:	3b 55 10             	cmp    0x10(%ebp),%edx
  800adc:	7d 3a                	jge    800b18 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ade:	83 c1 01             	add    $0x1,%ecx
  800ae1:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ae5:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ae7:	0f b6 11             	movzbl (%ecx),%edx
  800aea:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aed:	89 f3                	mov    %esi,%ebx
  800aef:	80 fb 09             	cmp    $0x9,%bl
  800af2:	76 df                	jbe    800ad3 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800af4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800af7:	89 f3                	mov    %esi,%ebx
  800af9:	80 fb 19             	cmp    $0x19,%bl
  800afc:	77 08                	ja     800b06 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800afe:	0f be d2             	movsbl %dl,%edx
  800b01:	83 ea 57             	sub    $0x57,%edx
  800b04:	eb d3                	jmp    800ad9 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b06:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b09:	89 f3                	mov    %esi,%ebx
  800b0b:	80 fb 19             	cmp    $0x19,%bl
  800b0e:	77 08                	ja     800b18 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b10:	0f be d2             	movsbl %dl,%edx
  800b13:	83 ea 37             	sub    $0x37,%edx
  800b16:	eb c1                	jmp    800ad9 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b18:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1c:	74 05                	je     800b23 <strtol+0xd0>
		*endptr = (char *) s;
  800b1e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b21:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b23:	89 c2                	mov    %eax,%edx
  800b25:	f7 da                	neg    %edx
  800b27:	85 ff                	test   %edi,%edi
  800b29:	0f 45 c2             	cmovne %edx,%eax
}
  800b2c:	5b                   	pop    %ebx
  800b2d:	5e                   	pop    %esi
  800b2e:	5f                   	pop    %edi
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    

00800b31 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b31:	f3 0f 1e fb          	endbr32 
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	57                   	push   %edi
  800b39:	56                   	push   %esi
  800b3a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b3b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b40:	8b 55 08             	mov    0x8(%ebp),%edx
  800b43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b46:	89 c3                	mov    %eax,%ebx
  800b48:	89 c7                	mov    %eax,%edi
  800b4a:	89 c6                	mov    %eax,%esi
  800b4c:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b4e:	5b                   	pop    %ebx
  800b4f:	5e                   	pop    %esi
  800b50:	5f                   	pop    %edi
  800b51:	5d                   	pop    %ebp
  800b52:	c3                   	ret    

00800b53 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b53:	f3 0f 1e fb          	endbr32 
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	57                   	push   %edi
  800b5b:	56                   	push   %esi
  800b5c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b62:	b8 01 00 00 00       	mov    $0x1,%eax
  800b67:	89 d1                	mov    %edx,%ecx
  800b69:	89 d3                	mov    %edx,%ebx
  800b6b:	89 d7                	mov    %edx,%edi
  800b6d:	89 d6                	mov    %edx,%esi
  800b6f:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b76:	f3 0f 1e fb          	endbr32 
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	57                   	push   %edi
  800b7e:	56                   	push   %esi
  800b7f:	53                   	push   %ebx
  800b80:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b83:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b88:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b90:	89 cb                	mov    %ecx,%ebx
  800b92:	89 cf                	mov    %ecx,%edi
  800b94:	89 ce                	mov    %ecx,%esi
  800b96:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b98:	85 c0                	test   %eax,%eax
  800b9a:	7f 08                	jg     800ba4 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5f                   	pop    %edi
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba4:	83 ec 0c             	sub    $0xc,%esp
  800ba7:	50                   	push   %eax
  800ba8:	6a 03                	push   $0x3
  800baa:	68 44 16 80 00       	push   $0x801644
  800baf:	6a 23                	push   $0x23
  800bb1:	68 61 16 80 00       	push   $0x801661
  800bb6:	e8 52 04 00 00       	call   80100d <_panic>

00800bbb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bbb:	f3 0f 1e fb          	endbr32 
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	57                   	push   %edi
  800bc3:	56                   	push   %esi
  800bc4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bc5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bca:	b8 02 00 00 00       	mov    $0x2,%eax
  800bcf:	89 d1                	mov    %edx,%ecx
  800bd1:	89 d3                	mov    %edx,%ebx
  800bd3:	89 d7                	mov    %edx,%edi
  800bd5:	89 d6                	mov    %edx,%esi
  800bd7:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd9:	5b                   	pop    %ebx
  800bda:	5e                   	pop    %esi
  800bdb:	5f                   	pop    %edi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <sys_yield>:

void
sys_yield(void)
{
  800bde:	f3 0f 1e fb          	endbr32 
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800be8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bed:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bf2:	89 d1                	mov    %edx,%ecx
  800bf4:	89 d3                	mov    %edx,%ebx
  800bf6:	89 d7                	mov    %edx,%edi
  800bf8:	89 d6                	mov    %edx,%esi
  800bfa:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bfc:	5b                   	pop    %ebx
  800bfd:	5e                   	pop    %esi
  800bfe:	5f                   	pop    %edi
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c01:	f3 0f 1e fb          	endbr32 
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	57                   	push   %edi
  800c09:	56                   	push   %esi
  800c0a:	53                   	push   %ebx
  800c0b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c0e:	be 00 00 00 00       	mov    $0x0,%esi
  800c13:	8b 55 08             	mov    0x8(%ebp),%edx
  800c16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c19:	b8 04 00 00 00       	mov    $0x4,%eax
  800c1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c21:	89 f7                	mov    %esi,%edi
  800c23:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c25:	85 c0                	test   %eax,%eax
  800c27:	7f 08                	jg     800c31 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2c:	5b                   	pop    %ebx
  800c2d:	5e                   	pop    %esi
  800c2e:	5f                   	pop    %edi
  800c2f:	5d                   	pop    %ebp
  800c30:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c31:	83 ec 0c             	sub    $0xc,%esp
  800c34:	50                   	push   %eax
  800c35:	6a 04                	push   $0x4
  800c37:	68 44 16 80 00       	push   $0x801644
  800c3c:	6a 23                	push   $0x23
  800c3e:	68 61 16 80 00       	push   $0x801661
  800c43:	e8 c5 03 00 00       	call   80100d <_panic>

00800c48 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c48:	f3 0f 1e fb          	endbr32 
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	57                   	push   %edi
  800c50:	56                   	push   %esi
  800c51:	53                   	push   %ebx
  800c52:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c55:	8b 55 08             	mov    0x8(%ebp),%edx
  800c58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5b:	b8 05 00 00 00       	mov    $0x5,%eax
  800c60:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c63:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c66:	8b 75 18             	mov    0x18(%ebp),%esi
  800c69:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c6b:	85 c0                	test   %eax,%eax
  800c6d:	7f 08                	jg     800c77 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c72:	5b                   	pop    %ebx
  800c73:	5e                   	pop    %esi
  800c74:	5f                   	pop    %edi
  800c75:	5d                   	pop    %ebp
  800c76:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c77:	83 ec 0c             	sub    $0xc,%esp
  800c7a:	50                   	push   %eax
  800c7b:	6a 05                	push   $0x5
  800c7d:	68 44 16 80 00       	push   $0x801644
  800c82:	6a 23                	push   $0x23
  800c84:	68 61 16 80 00       	push   $0x801661
  800c89:	e8 7f 03 00 00       	call   80100d <_panic>

00800c8e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c8e:	f3 0f 1e fb          	endbr32 
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	57                   	push   %edi
  800c96:	56                   	push   %esi
  800c97:	53                   	push   %ebx
  800c98:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c9b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca6:	b8 06 00 00 00       	mov    $0x6,%eax
  800cab:	89 df                	mov    %ebx,%edi
  800cad:	89 de                	mov    %ebx,%esi
  800caf:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb1:	85 c0                	test   %eax,%eax
  800cb3:	7f 08                	jg     800cbd <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb8:	5b                   	pop    %ebx
  800cb9:	5e                   	pop    %esi
  800cba:	5f                   	pop    %edi
  800cbb:	5d                   	pop    %ebp
  800cbc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbd:	83 ec 0c             	sub    $0xc,%esp
  800cc0:	50                   	push   %eax
  800cc1:	6a 06                	push   $0x6
  800cc3:	68 44 16 80 00       	push   $0x801644
  800cc8:	6a 23                	push   $0x23
  800cca:	68 61 16 80 00       	push   $0x801661
  800ccf:	e8 39 03 00 00       	call   80100d <_panic>

00800cd4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cd4:	f3 0f 1e fb          	endbr32 
  800cd8:	55                   	push   %ebp
  800cd9:	89 e5                	mov    %esp,%ebp
  800cdb:	57                   	push   %edi
  800cdc:	56                   	push   %esi
  800cdd:	53                   	push   %ebx
  800cde:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ce1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cec:	b8 08 00 00 00       	mov    $0x8,%eax
  800cf1:	89 df                	mov    %ebx,%edi
  800cf3:	89 de                	mov    %ebx,%esi
  800cf5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf7:	85 c0                	test   %eax,%eax
  800cf9:	7f 08                	jg     800d03 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d03:	83 ec 0c             	sub    $0xc,%esp
  800d06:	50                   	push   %eax
  800d07:	6a 08                	push   $0x8
  800d09:	68 44 16 80 00       	push   $0x801644
  800d0e:	6a 23                	push   $0x23
  800d10:	68 61 16 80 00       	push   $0x801661
  800d15:	e8 f3 02 00 00       	call   80100d <_panic>

00800d1a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d1a:	f3 0f 1e fb          	endbr32 
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	57                   	push   %edi
  800d22:	56                   	push   %esi
  800d23:	53                   	push   %ebx
  800d24:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d27:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d32:	b8 09 00 00 00       	mov    $0x9,%eax
  800d37:	89 df                	mov    %ebx,%edi
  800d39:	89 de                	mov    %ebx,%esi
  800d3b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d3d:	85 c0                	test   %eax,%eax
  800d3f:	7f 08                	jg     800d49 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d44:	5b                   	pop    %ebx
  800d45:	5e                   	pop    %esi
  800d46:	5f                   	pop    %edi
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d49:	83 ec 0c             	sub    $0xc,%esp
  800d4c:	50                   	push   %eax
  800d4d:	6a 09                	push   $0x9
  800d4f:	68 44 16 80 00       	push   $0x801644
  800d54:	6a 23                	push   $0x23
  800d56:	68 61 16 80 00       	push   $0x801661
  800d5b:	e8 ad 02 00 00       	call   80100d <_panic>

00800d60 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d60:	f3 0f 1e fb          	endbr32 
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	57                   	push   %edi
  800d68:	56                   	push   %esi
  800d69:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d70:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d75:	be 00 00 00 00       	mov    $0x0,%esi
  800d7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d7d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d80:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d82:	5b                   	pop    %ebx
  800d83:	5e                   	pop    %esi
  800d84:	5f                   	pop    %edi
  800d85:	5d                   	pop    %ebp
  800d86:	c3                   	ret    

00800d87 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d87:	f3 0f 1e fb          	endbr32 
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	57                   	push   %edi
  800d8f:	56                   	push   %esi
  800d90:	53                   	push   %ebx
  800d91:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d94:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d99:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da1:	89 cb                	mov    %ecx,%ebx
  800da3:	89 cf                	mov    %ecx,%edi
  800da5:	89 ce                	mov    %ecx,%esi
  800da7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800da9:	85 c0                	test   %eax,%eax
  800dab:	7f 08                	jg     800db5 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db0:	5b                   	pop    %ebx
  800db1:	5e                   	pop    %esi
  800db2:	5f                   	pop    %edi
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800db5:	83 ec 0c             	sub    $0xc,%esp
  800db8:	50                   	push   %eax
  800db9:	6a 0c                	push   $0xc
  800dbb:	68 44 16 80 00       	push   $0x801644
  800dc0:	6a 23                	push   $0x23
  800dc2:	68 61 16 80 00       	push   $0x801661
  800dc7:	e8 41 02 00 00       	call   80100d <_panic>

00800dcc <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dcc:	f3 0f 1e fb          	endbr32 
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	53                   	push   %ebx
  800dd4:	83 ec 04             	sub    $0x4,%esp
  800dd7:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dda:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if ( !(err & FEC_WR) ||
  800ddc:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800de0:	74 75                	je     800e57 <pgfault+0x8b>
            !(uvpt[PGNUM(addr)] | PTE_COW) ) {
  800de2:	89 d8                	mov    %ebx,%eax
  800de4:	c1 e8 0c             	shr    $0xc,%eax
  800de7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, (void *)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0) {
  800dee:	83 ec 04             	sub    $0x4,%esp
  800df1:	6a 07                	push   $0x7
  800df3:	68 00 f0 7f 00       	push   $0x7ff000
  800df8:	6a 00                	push   $0x0
  800dfa:	e8 02 fe ff ff       	call   800c01 <sys_page_alloc>
  800dff:	83 c4 10             	add    $0x10,%esp
  800e02:	85 c0                	test   %eax,%eax
  800e04:	78 65                	js     800e6b <pgfault+0x9f>
        panic("sys_page_alloc failed %e\n", r);
    }
    memmove((void *)PFTEMP, (void *)PTE_ADDR(addr), PGSIZE);
  800e06:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800e0c:	83 ec 04             	sub    $0x4,%esp
  800e0f:	68 00 10 00 00       	push   $0x1000
  800e14:	53                   	push   %ebx
  800e15:	68 00 f0 7f 00       	push   $0x7ff000
  800e1a:	e8 56 fb ff ff       	call   800975 <memmove>
    if ((r = sys_page_map(0, (void *)PFTEMP,
  800e1f:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e26:	53                   	push   %ebx
  800e27:	6a 00                	push   $0x0
  800e29:	68 00 f0 7f 00       	push   $0x7ff000
  800e2e:	6a 00                	push   $0x0
  800e30:	e8 13 fe ff ff       	call   800c48 <sys_page_map>
  800e35:	83 c4 20             	add    $0x20,%esp
  800e38:	85 c0                	test   %eax,%eax
  800e3a:	78 41                	js     800e7d <pgfault+0xb1>
                0, (void *)PTE_ADDR(addr), PTE_P | PTE_U | PTE_W)) < 0) {
        panic("sys_page_map failed %e\n", r);
    }
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0) {
  800e3c:	83 ec 08             	sub    $0x8,%esp
  800e3f:	68 00 f0 7f 00       	push   $0x7ff000
  800e44:	6a 00                	push   $0x0
  800e46:	e8 43 fe ff ff       	call   800c8e <sys_page_unmap>
  800e4b:	83 c4 10             	add    $0x10,%esp
  800e4e:	85 c0                	test   %eax,%eax
  800e50:	78 3d                	js     800e8f <pgfault+0xc3>
        panic("sys_page_unmap failed %e\n", r);
    }

}
  800e52:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e55:	c9                   	leave  
  800e56:	c3                   	ret    
        panic("Not a copy-on-write page");
  800e57:	83 ec 04             	sub    $0x4,%esp
  800e5a:	68 6f 16 80 00       	push   $0x80166f
  800e5f:	6a 1e                	push   $0x1e
  800e61:	68 88 16 80 00       	push   $0x801688
  800e66:	e8 a2 01 00 00       	call   80100d <_panic>
        panic("sys_page_alloc failed %e\n", r);
  800e6b:	50                   	push   %eax
  800e6c:	68 93 16 80 00       	push   $0x801693
  800e71:	6a 2a                	push   $0x2a
  800e73:	68 88 16 80 00       	push   $0x801688
  800e78:	e8 90 01 00 00       	call   80100d <_panic>
        panic("sys_page_map failed %e\n", r);
  800e7d:	50                   	push   %eax
  800e7e:	68 ad 16 80 00       	push   $0x8016ad
  800e83:	6a 2f                	push   $0x2f
  800e85:	68 88 16 80 00       	push   $0x801688
  800e8a:	e8 7e 01 00 00       	call   80100d <_panic>
        panic("sys_page_unmap failed %e\n", r);
  800e8f:	50                   	push   %eax
  800e90:	68 c5 16 80 00       	push   $0x8016c5
  800e95:	6a 32                	push   $0x32
  800e97:	68 88 16 80 00       	push   $0x801688
  800e9c:	e8 6c 01 00 00       	call   80100d <_panic>

00800ea1 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ea1:	f3 0f 1e fb          	endbr32 
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
  800ea8:	57                   	push   %edi
  800ea9:	56                   	push   %esi
  800eaa:	53                   	push   %ebx
  800eab:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");

    // 1. set pgfault handler.
    set_pgfault_handler(pgfault);
  800eae:	68 cc 0d 80 00       	push   $0x800dcc
  800eb3:	e8 9f 01 00 00       	call   801057 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800eb8:	b8 07 00 00 00       	mov    $0x7,%eax
  800ebd:	cd 30                	int    $0x30
  800ebf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ec2:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    // 2. exofork.
    envid_t envid = sys_exofork();

    if (envid < 0)
  800ec5:	83 c4 10             	add    $0x10,%esp
  800ec8:	85 c0                	test   %eax,%eax
  800eca:	78 2a                	js     800ef6 <fork+0x55>
        thisenv = &envs[ENVX(my_envid)];
        return 0;
    }
    else {
        // parent
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800ecc:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (envid == 0) {
  800ed1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800ed5:	75 4e                	jne    800f25 <fork+0x84>
        envid_t my_envid = sys_getenvid();
  800ed7:	e8 df fc ff ff       	call   800bbb <sys_getenvid>
        thisenv = &envs[ENVX(my_envid)];
  800edc:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ee1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ee4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ee9:	a3 04 20 80 00       	mov    %eax,0x802004
        return 0;
  800eee:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ef1:	e9 f1 00 00 00       	jmp    800fe7 <fork+0x146>
        panic("fork, sys_exofork %e", envid);
  800ef6:	50                   	push   %eax
  800ef7:	68 df 16 80 00       	push   $0x8016df
  800efc:	6a 7b                	push   $0x7b
  800efe:	68 88 16 80 00       	push   $0x801688
  800f03:	e8 05 01 00 00       	call   80100d <_panic>
        panic("sys_page_map others failed %e\n", r);
  800f08:	50                   	push   %eax
  800f09:	68 28 17 80 00       	push   $0x801728
  800f0e:	6a 51                	push   $0x51
  800f10:	68 88 16 80 00       	push   $0x801688
  800f15:	e8 f3 00 00 00       	call   80100d <_panic>
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800f1a:	83 c3 01             	add    $0x1,%ebx
  800f1d:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  800f23:	74 7c                	je     800fa1 <fork+0x100>
  800f25:	89 de                	mov    %ebx,%esi
  800f27:	c1 e6 0c             	shl    $0xc,%esi
            uintptr_t pgaddr = pn << PGSHIFT;
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800f2a:	89 f0                	mov    %esi,%eax
  800f2c:	c1 e8 16             	shr    $0x16,%eax
  800f2f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f36:	a8 01                	test   $0x1,%al
  800f38:	74 e0                	je     800f1a <fork+0x79>
                    (uvpt[pn] & PTE_P) ) {
  800f3a:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800f41:	a8 01                	test   $0x1,%al
  800f43:	74 d5                	je     800f1a <fork+0x79>
    pte_t pte = uvpt[pn];
  800f45:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
    if ( (pte & PTE_W) || (pte & PTE_COW) ) {
  800f4c:	25 02 08 00 00       	and    $0x802,%eax
        perm |= PTE_COW;
  800f51:	83 f8 01             	cmp    $0x1,%eax
  800f54:	19 ff                	sbb    %edi,%edi
  800f56:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  800f5c:	81 c7 05 08 00 00    	add    $0x805,%edi
    if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0) {
  800f62:	83 ec 0c             	sub    $0xc,%esp
  800f65:	57                   	push   %edi
  800f66:	56                   	push   %esi
  800f67:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f6a:	56                   	push   %esi
  800f6b:	6a 00                	push   $0x0
  800f6d:	e8 d6 fc ff ff       	call   800c48 <sys_page_map>
  800f72:	83 c4 20             	add    $0x20,%esp
  800f75:	85 c0                	test   %eax,%eax
  800f77:	78 8f                	js     800f08 <fork+0x67>
        if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0) {
  800f79:	83 ec 0c             	sub    $0xc,%esp
  800f7c:	57                   	push   %edi
  800f7d:	56                   	push   %esi
  800f7e:	6a 00                	push   $0x0
  800f80:	56                   	push   %esi
  800f81:	6a 00                	push   $0x0
  800f83:	e8 c0 fc ff ff       	call   800c48 <sys_page_map>
  800f88:	83 c4 20             	add    $0x20,%esp
  800f8b:	85 c0                	test   %eax,%eax
  800f8d:	79 8b                	jns    800f1a <fork+0x79>
            panic("sys_page_map mine failed %e\n", r);
  800f8f:	50                   	push   %eax
  800f90:	68 f4 16 80 00       	push   $0x8016f4
  800f95:	6a 56                	push   $0x56
  800f97:	68 88 16 80 00       	push   $0x801688
  800f9c:	e8 6c 00 00 00       	call   80100d <_panic>
            }
        }

        int r;

        if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE),
  800fa1:	83 ec 04             	sub    $0x4,%esp
  800fa4:	6a 07                	push   $0x7
  800fa6:	68 00 f0 bf ee       	push   $0xeebff000
  800fab:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800fae:	57                   	push   %edi
  800faf:	e8 4d fc ff ff       	call   800c01 <sys_page_alloc>
  800fb4:	83 c4 10             	add    $0x10,%esp
  800fb7:	85 c0                	test   %eax,%eax
  800fb9:	78 2c                	js     800fe7 <fork+0x146>
                    PTE_U | PTE_W | PTE_P)) < 0) {
            return r;
        }

        if ((r = sys_env_set_pgfault_upcall(envid,
                        thisenv->env_pgfault_upcall)) < 0) {
  800fbb:	a1 04 20 80 00       	mov    0x802004,%eax
        if ((r = sys_env_set_pgfault_upcall(envid,
  800fc0:	8b 40 64             	mov    0x64(%eax),%eax
  800fc3:	83 ec 08             	sub    $0x8,%esp
  800fc6:	50                   	push   %eax
  800fc7:	57                   	push   %edi
  800fc8:	e8 4d fd ff ff       	call   800d1a <sys_env_set_pgfault_upcall>
  800fcd:	83 c4 10             	add    $0x10,%esp
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	78 13                	js     800fe7 <fork+0x146>
            return r;
        }

        if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  800fd4:	83 ec 08             	sub    $0x8,%esp
  800fd7:	6a 02                	push   $0x2
  800fd9:	57                   	push   %edi
  800fda:	e8 f5 fc ff ff       	call   800cd4 <sys_env_set_status>
  800fdf:	83 c4 10             	add    $0x10,%esp
            return r;
        }
        return envid;
  800fe2:	85 c0                	test   %eax,%eax
  800fe4:	0f 49 c7             	cmovns %edi,%eax
    }

}
  800fe7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fea:	5b                   	pop    %ebx
  800feb:	5e                   	pop    %esi
  800fec:	5f                   	pop    %edi
  800fed:	5d                   	pop    %ebp
  800fee:	c3                   	ret    

00800fef <sfork>:

// Challenge!
int
sfork(void)
{
  800fef:	f3 0f 1e fb          	endbr32 
  800ff3:	55                   	push   %ebp
  800ff4:	89 e5                	mov    %esp,%ebp
  800ff6:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800ff9:	68 11 17 80 00       	push   $0x801711
  800ffe:	68 a5 00 00 00       	push   $0xa5
  801003:	68 88 16 80 00       	push   $0x801688
  801008:	e8 00 00 00 00       	call   80100d <_panic>

0080100d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80100d:	f3 0f 1e fb          	endbr32 
  801011:	55                   	push   %ebp
  801012:	89 e5                	mov    %esp,%ebp
  801014:	56                   	push   %esi
  801015:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801016:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801019:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80101f:	e8 97 fb ff ff       	call   800bbb <sys_getenvid>
  801024:	83 ec 0c             	sub    $0xc,%esp
  801027:	ff 75 0c             	pushl  0xc(%ebp)
  80102a:	ff 75 08             	pushl  0x8(%ebp)
  80102d:	56                   	push   %esi
  80102e:	50                   	push   %eax
  80102f:	68 48 17 80 00       	push   $0x801748
  801034:	e8 7d f1 ff ff       	call   8001b6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801039:	83 c4 18             	add    $0x18,%esp
  80103c:	53                   	push   %ebx
  80103d:	ff 75 10             	pushl  0x10(%ebp)
  801040:	e8 1c f1 ff ff       	call   800161 <vcprintf>
	cprintf("\n");
  801045:	c7 04 24 f4 13 80 00 	movl   $0x8013f4,(%esp)
  80104c:	e8 65 f1 ff ff       	call   8001b6 <cprintf>
  801051:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801054:	cc                   	int3   
  801055:	eb fd                	jmp    801054 <_panic+0x47>

00801057 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801057:	f3 0f 1e fb          	endbr32 
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801061:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801068:	74 0a                	je     801074 <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80106a:	8b 45 08             	mov    0x8(%ebp),%eax
  80106d:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801072:	c9                   	leave  
  801073:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  801074:	83 ec 0c             	sub    $0xc,%esp
  801077:	68 6b 17 80 00       	push   $0x80176b
  80107c:	e8 35 f1 ff ff       	call   8001b6 <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  801081:	83 c4 0c             	add    $0xc,%esp
  801084:	6a 07                	push   $0x7
  801086:	68 00 f0 bf ee       	push   $0xeebff000
  80108b:	6a 00                	push   $0x0
  80108d:	e8 6f fb ff ff       	call   800c01 <sys_page_alloc>
  801092:	83 c4 10             	add    $0x10,%esp
  801095:	85 c0                	test   %eax,%eax
  801097:	78 2a                	js     8010c3 <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  801099:	83 ec 08             	sub    $0x8,%esp
  80109c:	68 d7 10 80 00       	push   $0x8010d7
  8010a1:	6a 00                	push   $0x0
  8010a3:	e8 72 fc ff ff       	call   800d1a <sys_env_set_pgfault_upcall>
  8010a8:	83 c4 10             	add    $0x10,%esp
  8010ab:	85 c0                	test   %eax,%eax
  8010ad:	79 bb                	jns    80106a <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  8010af:	83 ec 04             	sub    $0x4,%esp
  8010b2:	68 a8 17 80 00       	push   $0x8017a8
  8010b7:	6a 25                	push   $0x25
  8010b9:	68 98 17 80 00       	push   $0x801798
  8010be:	e8 4a ff ff ff       	call   80100d <_panic>
            panic("Allocation of UXSTACK failed!");
  8010c3:	83 ec 04             	sub    $0x4,%esp
  8010c6:	68 7a 17 80 00       	push   $0x80177a
  8010cb:	6a 22                	push   $0x22
  8010cd:	68 98 17 80 00       	push   $0x801798
  8010d2:	e8 36 ff ff ff       	call   80100d <_panic>

008010d7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8010d7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8010d8:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8010dd:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8010df:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  8010e2:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  8010e6:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  8010ea:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  8010ed:	83 c4 08             	add    $0x8,%esp
    popa
  8010f0:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $0x4, %esp
  8010f1:	83 c4 04             	add    $0x4,%esp
    popf
  8010f4:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  8010f5:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  8010f8:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  8010fc:	c3                   	ret    
  8010fd:	66 90                	xchg   %ax,%ax
  8010ff:	90                   	nop

00801100 <__udivdi3>:
  801100:	f3 0f 1e fb          	endbr32 
  801104:	55                   	push   %ebp
  801105:	57                   	push   %edi
  801106:	56                   	push   %esi
  801107:	53                   	push   %ebx
  801108:	83 ec 1c             	sub    $0x1c,%esp
  80110b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80110f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801113:	8b 74 24 34          	mov    0x34(%esp),%esi
  801117:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80111b:	85 d2                	test   %edx,%edx
  80111d:	75 19                	jne    801138 <__udivdi3+0x38>
  80111f:	39 f3                	cmp    %esi,%ebx
  801121:	76 4d                	jbe    801170 <__udivdi3+0x70>
  801123:	31 ff                	xor    %edi,%edi
  801125:	89 e8                	mov    %ebp,%eax
  801127:	89 f2                	mov    %esi,%edx
  801129:	f7 f3                	div    %ebx
  80112b:	89 fa                	mov    %edi,%edx
  80112d:	83 c4 1c             	add    $0x1c,%esp
  801130:	5b                   	pop    %ebx
  801131:	5e                   	pop    %esi
  801132:	5f                   	pop    %edi
  801133:	5d                   	pop    %ebp
  801134:	c3                   	ret    
  801135:	8d 76 00             	lea    0x0(%esi),%esi
  801138:	39 f2                	cmp    %esi,%edx
  80113a:	76 14                	jbe    801150 <__udivdi3+0x50>
  80113c:	31 ff                	xor    %edi,%edi
  80113e:	31 c0                	xor    %eax,%eax
  801140:	89 fa                	mov    %edi,%edx
  801142:	83 c4 1c             	add    $0x1c,%esp
  801145:	5b                   	pop    %ebx
  801146:	5e                   	pop    %esi
  801147:	5f                   	pop    %edi
  801148:	5d                   	pop    %ebp
  801149:	c3                   	ret    
  80114a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801150:	0f bd fa             	bsr    %edx,%edi
  801153:	83 f7 1f             	xor    $0x1f,%edi
  801156:	75 48                	jne    8011a0 <__udivdi3+0xa0>
  801158:	39 f2                	cmp    %esi,%edx
  80115a:	72 06                	jb     801162 <__udivdi3+0x62>
  80115c:	31 c0                	xor    %eax,%eax
  80115e:	39 eb                	cmp    %ebp,%ebx
  801160:	77 de                	ja     801140 <__udivdi3+0x40>
  801162:	b8 01 00 00 00       	mov    $0x1,%eax
  801167:	eb d7                	jmp    801140 <__udivdi3+0x40>
  801169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801170:	89 d9                	mov    %ebx,%ecx
  801172:	85 db                	test   %ebx,%ebx
  801174:	75 0b                	jne    801181 <__udivdi3+0x81>
  801176:	b8 01 00 00 00       	mov    $0x1,%eax
  80117b:	31 d2                	xor    %edx,%edx
  80117d:	f7 f3                	div    %ebx
  80117f:	89 c1                	mov    %eax,%ecx
  801181:	31 d2                	xor    %edx,%edx
  801183:	89 f0                	mov    %esi,%eax
  801185:	f7 f1                	div    %ecx
  801187:	89 c6                	mov    %eax,%esi
  801189:	89 e8                	mov    %ebp,%eax
  80118b:	89 f7                	mov    %esi,%edi
  80118d:	f7 f1                	div    %ecx
  80118f:	89 fa                	mov    %edi,%edx
  801191:	83 c4 1c             	add    $0x1c,%esp
  801194:	5b                   	pop    %ebx
  801195:	5e                   	pop    %esi
  801196:	5f                   	pop    %edi
  801197:	5d                   	pop    %ebp
  801198:	c3                   	ret    
  801199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011a0:	89 f9                	mov    %edi,%ecx
  8011a2:	b8 20 00 00 00       	mov    $0x20,%eax
  8011a7:	29 f8                	sub    %edi,%eax
  8011a9:	d3 e2                	shl    %cl,%edx
  8011ab:	89 54 24 08          	mov    %edx,0x8(%esp)
  8011af:	89 c1                	mov    %eax,%ecx
  8011b1:	89 da                	mov    %ebx,%edx
  8011b3:	d3 ea                	shr    %cl,%edx
  8011b5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8011b9:	09 d1                	or     %edx,%ecx
  8011bb:	89 f2                	mov    %esi,%edx
  8011bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011c1:	89 f9                	mov    %edi,%ecx
  8011c3:	d3 e3                	shl    %cl,%ebx
  8011c5:	89 c1                	mov    %eax,%ecx
  8011c7:	d3 ea                	shr    %cl,%edx
  8011c9:	89 f9                	mov    %edi,%ecx
  8011cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8011cf:	89 eb                	mov    %ebp,%ebx
  8011d1:	d3 e6                	shl    %cl,%esi
  8011d3:	89 c1                	mov    %eax,%ecx
  8011d5:	d3 eb                	shr    %cl,%ebx
  8011d7:	09 de                	or     %ebx,%esi
  8011d9:	89 f0                	mov    %esi,%eax
  8011db:	f7 74 24 08          	divl   0x8(%esp)
  8011df:	89 d6                	mov    %edx,%esi
  8011e1:	89 c3                	mov    %eax,%ebx
  8011e3:	f7 64 24 0c          	mull   0xc(%esp)
  8011e7:	39 d6                	cmp    %edx,%esi
  8011e9:	72 15                	jb     801200 <__udivdi3+0x100>
  8011eb:	89 f9                	mov    %edi,%ecx
  8011ed:	d3 e5                	shl    %cl,%ebp
  8011ef:	39 c5                	cmp    %eax,%ebp
  8011f1:	73 04                	jae    8011f7 <__udivdi3+0xf7>
  8011f3:	39 d6                	cmp    %edx,%esi
  8011f5:	74 09                	je     801200 <__udivdi3+0x100>
  8011f7:	89 d8                	mov    %ebx,%eax
  8011f9:	31 ff                	xor    %edi,%edi
  8011fb:	e9 40 ff ff ff       	jmp    801140 <__udivdi3+0x40>
  801200:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801203:	31 ff                	xor    %edi,%edi
  801205:	e9 36 ff ff ff       	jmp    801140 <__udivdi3+0x40>
  80120a:	66 90                	xchg   %ax,%ax
  80120c:	66 90                	xchg   %ax,%ax
  80120e:	66 90                	xchg   %ax,%ax

00801210 <__umoddi3>:
  801210:	f3 0f 1e fb          	endbr32 
  801214:	55                   	push   %ebp
  801215:	57                   	push   %edi
  801216:	56                   	push   %esi
  801217:	53                   	push   %ebx
  801218:	83 ec 1c             	sub    $0x1c,%esp
  80121b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80121f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801223:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801227:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80122b:	85 c0                	test   %eax,%eax
  80122d:	75 19                	jne    801248 <__umoddi3+0x38>
  80122f:	39 df                	cmp    %ebx,%edi
  801231:	76 5d                	jbe    801290 <__umoddi3+0x80>
  801233:	89 f0                	mov    %esi,%eax
  801235:	89 da                	mov    %ebx,%edx
  801237:	f7 f7                	div    %edi
  801239:	89 d0                	mov    %edx,%eax
  80123b:	31 d2                	xor    %edx,%edx
  80123d:	83 c4 1c             	add    $0x1c,%esp
  801240:	5b                   	pop    %ebx
  801241:	5e                   	pop    %esi
  801242:	5f                   	pop    %edi
  801243:	5d                   	pop    %ebp
  801244:	c3                   	ret    
  801245:	8d 76 00             	lea    0x0(%esi),%esi
  801248:	89 f2                	mov    %esi,%edx
  80124a:	39 d8                	cmp    %ebx,%eax
  80124c:	76 12                	jbe    801260 <__umoddi3+0x50>
  80124e:	89 f0                	mov    %esi,%eax
  801250:	89 da                	mov    %ebx,%edx
  801252:	83 c4 1c             	add    $0x1c,%esp
  801255:	5b                   	pop    %ebx
  801256:	5e                   	pop    %esi
  801257:	5f                   	pop    %edi
  801258:	5d                   	pop    %ebp
  801259:	c3                   	ret    
  80125a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801260:	0f bd e8             	bsr    %eax,%ebp
  801263:	83 f5 1f             	xor    $0x1f,%ebp
  801266:	75 50                	jne    8012b8 <__umoddi3+0xa8>
  801268:	39 d8                	cmp    %ebx,%eax
  80126a:	0f 82 e0 00 00 00    	jb     801350 <__umoddi3+0x140>
  801270:	89 d9                	mov    %ebx,%ecx
  801272:	39 f7                	cmp    %esi,%edi
  801274:	0f 86 d6 00 00 00    	jbe    801350 <__umoddi3+0x140>
  80127a:	89 d0                	mov    %edx,%eax
  80127c:	89 ca                	mov    %ecx,%edx
  80127e:	83 c4 1c             	add    $0x1c,%esp
  801281:	5b                   	pop    %ebx
  801282:	5e                   	pop    %esi
  801283:	5f                   	pop    %edi
  801284:	5d                   	pop    %ebp
  801285:	c3                   	ret    
  801286:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80128d:	8d 76 00             	lea    0x0(%esi),%esi
  801290:	89 fd                	mov    %edi,%ebp
  801292:	85 ff                	test   %edi,%edi
  801294:	75 0b                	jne    8012a1 <__umoddi3+0x91>
  801296:	b8 01 00 00 00       	mov    $0x1,%eax
  80129b:	31 d2                	xor    %edx,%edx
  80129d:	f7 f7                	div    %edi
  80129f:	89 c5                	mov    %eax,%ebp
  8012a1:	89 d8                	mov    %ebx,%eax
  8012a3:	31 d2                	xor    %edx,%edx
  8012a5:	f7 f5                	div    %ebp
  8012a7:	89 f0                	mov    %esi,%eax
  8012a9:	f7 f5                	div    %ebp
  8012ab:	89 d0                	mov    %edx,%eax
  8012ad:	31 d2                	xor    %edx,%edx
  8012af:	eb 8c                	jmp    80123d <__umoddi3+0x2d>
  8012b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012b8:	89 e9                	mov    %ebp,%ecx
  8012ba:	ba 20 00 00 00       	mov    $0x20,%edx
  8012bf:	29 ea                	sub    %ebp,%edx
  8012c1:	d3 e0                	shl    %cl,%eax
  8012c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012c7:	89 d1                	mov    %edx,%ecx
  8012c9:	89 f8                	mov    %edi,%eax
  8012cb:	d3 e8                	shr    %cl,%eax
  8012cd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8012d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012d5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8012d9:	09 c1                	or     %eax,%ecx
  8012db:	89 d8                	mov    %ebx,%eax
  8012dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012e1:	89 e9                	mov    %ebp,%ecx
  8012e3:	d3 e7                	shl    %cl,%edi
  8012e5:	89 d1                	mov    %edx,%ecx
  8012e7:	d3 e8                	shr    %cl,%eax
  8012e9:	89 e9                	mov    %ebp,%ecx
  8012eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012ef:	d3 e3                	shl    %cl,%ebx
  8012f1:	89 c7                	mov    %eax,%edi
  8012f3:	89 d1                	mov    %edx,%ecx
  8012f5:	89 f0                	mov    %esi,%eax
  8012f7:	d3 e8                	shr    %cl,%eax
  8012f9:	89 e9                	mov    %ebp,%ecx
  8012fb:	89 fa                	mov    %edi,%edx
  8012fd:	d3 e6                	shl    %cl,%esi
  8012ff:	09 d8                	or     %ebx,%eax
  801301:	f7 74 24 08          	divl   0x8(%esp)
  801305:	89 d1                	mov    %edx,%ecx
  801307:	89 f3                	mov    %esi,%ebx
  801309:	f7 64 24 0c          	mull   0xc(%esp)
  80130d:	89 c6                	mov    %eax,%esi
  80130f:	89 d7                	mov    %edx,%edi
  801311:	39 d1                	cmp    %edx,%ecx
  801313:	72 06                	jb     80131b <__umoddi3+0x10b>
  801315:	75 10                	jne    801327 <__umoddi3+0x117>
  801317:	39 c3                	cmp    %eax,%ebx
  801319:	73 0c                	jae    801327 <__umoddi3+0x117>
  80131b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80131f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801323:	89 d7                	mov    %edx,%edi
  801325:	89 c6                	mov    %eax,%esi
  801327:	89 ca                	mov    %ecx,%edx
  801329:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80132e:	29 f3                	sub    %esi,%ebx
  801330:	19 fa                	sbb    %edi,%edx
  801332:	89 d0                	mov    %edx,%eax
  801334:	d3 e0                	shl    %cl,%eax
  801336:	89 e9                	mov    %ebp,%ecx
  801338:	d3 eb                	shr    %cl,%ebx
  80133a:	d3 ea                	shr    %cl,%edx
  80133c:	09 d8                	or     %ebx,%eax
  80133e:	83 c4 1c             	add    $0x1c,%esp
  801341:	5b                   	pop    %ebx
  801342:	5e                   	pop    %esi
  801343:	5f                   	pop    %edi
  801344:	5d                   	pop    %ebp
  801345:	c3                   	ret    
  801346:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80134d:	8d 76 00             	lea    0x0(%esi),%esi
  801350:	29 fe                	sub    %edi,%esi
  801352:	19 c3                	sbb    %eax,%ebx
  801354:	89 f2                	mov    %esi,%edx
  801356:	89 d9                	mov    %ebx,%ecx
  801358:	e9 1d ff ff ff       	jmp    80127a <__umoddi3+0x6a>
