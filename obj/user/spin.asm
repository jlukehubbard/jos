
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
  80003e:	68 40 22 80 00       	push   $0x802240
  800043:	e8 80 01 00 00       	call   8001c8 <cprintf>
	if ((env = fork()) == 0) {
  800048:	e8 ac 0e 00 00       	call   800ef9 <fork>
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	85 c0                	test   %eax,%eax
  800052:	75 12                	jne    800066 <umain+0x33>
		cprintf("I am the child.  Spinning...\n");
  800054:	83 ec 0c             	sub    $0xc,%esp
  800057:	68 b8 22 80 00       	push   $0x8022b8
  80005c:	e8 67 01 00 00       	call   8001c8 <cprintf>
  800061:	83 c4 10             	add    $0x10,%esp
  800064:	eb fe                	jmp    800064 <umain+0x31>
  800066:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800068:	83 ec 0c             	sub    $0xc,%esp
  80006b:	68 68 22 80 00       	push   $0x802268
  800070:	e8 53 01 00 00       	call   8001c8 <cprintf>
	sys_yield();
  800075:	e8 76 0b 00 00       	call   800bf0 <sys_yield>
	sys_yield();
  80007a:	e8 71 0b 00 00       	call   800bf0 <sys_yield>
	sys_yield();
  80007f:	e8 6c 0b 00 00       	call   800bf0 <sys_yield>
	sys_yield();
  800084:	e8 67 0b 00 00       	call   800bf0 <sys_yield>
	sys_yield();
  800089:	e8 62 0b 00 00       	call   800bf0 <sys_yield>
	sys_yield();
  80008e:	e8 5d 0b 00 00       	call   800bf0 <sys_yield>
	sys_yield();
  800093:	e8 58 0b 00 00       	call   800bf0 <sys_yield>
	sys_yield();
  800098:	e8 53 0b 00 00       	call   800bf0 <sys_yield>

    cprintf("I am the parent.  Killing the child...\n");
  80009d:	c7 04 24 90 22 80 00 	movl   $0x802290,(%esp)
  8000a4:	e8 1f 01 00 00       	call   8001c8 <cprintf>
	sys_env_destroy(env);
  8000a9:	89 1c 24             	mov    %ebx,(%esp)
  8000ac:	e8 d7 0a 00 00       	call   800b88 <sys_env_destroy>
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
	thisenv = 0;
  8000c8:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  8000cf:	00 00 00 
    envid_t envid = sys_getenvid();
  8000d2:	e8 f6 0a 00 00       	call   800bcd <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  8000d7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000dc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000df:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e4:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e9:	85 db                	test   %ebx,%ebx
  8000eb:	7e 07                	jle    8000f4 <libmain+0x3b>
		binaryname = argv[0];
  8000ed:	8b 06                	mov    (%esi),%eax
  8000ef:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000f4:	83 ec 08             	sub    $0x8,%esp
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	e8 35 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000fe:	e8 0a 00 00 00       	call   80010d <exit>
}
  800103:	83 c4 10             	add    $0x10,%esp
  800106:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800109:	5b                   	pop    %ebx
  80010a:	5e                   	pop    %esi
  80010b:	5d                   	pop    %ebp
  80010c:	c3                   	ret    

0080010d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80010d:	f3 0f 1e fb          	endbr32 
  800111:	55                   	push   %ebp
  800112:	89 e5                	mov    %esp,%ebp
  800114:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800117:	e8 43 11 00 00       	call   80125f <close_all>
	sys_env_destroy(0);
  80011c:	83 ec 0c             	sub    $0xc,%esp
  80011f:	6a 00                	push   $0x0
  800121:	e8 62 0a 00 00       	call   800b88 <sys_env_destroy>
}
  800126:	83 c4 10             	add    $0x10,%esp
  800129:	c9                   	leave  
  80012a:	c3                   	ret    

0080012b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80012b:	f3 0f 1e fb          	endbr32 
  80012f:	55                   	push   %ebp
  800130:	89 e5                	mov    %esp,%ebp
  800132:	53                   	push   %ebx
  800133:	83 ec 04             	sub    $0x4,%esp
  800136:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800139:	8b 13                	mov    (%ebx),%edx
  80013b:	8d 42 01             	lea    0x1(%edx),%eax
  80013e:	89 03                	mov    %eax,(%ebx)
  800140:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800143:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800147:	3d ff 00 00 00       	cmp    $0xff,%eax
  80014c:	74 09                	je     800157 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80014e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800152:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800155:	c9                   	leave  
  800156:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800157:	83 ec 08             	sub    $0x8,%esp
  80015a:	68 ff 00 00 00       	push   $0xff
  80015f:	8d 43 08             	lea    0x8(%ebx),%eax
  800162:	50                   	push   %eax
  800163:	e8 db 09 00 00       	call   800b43 <sys_cputs>
		b->idx = 0;
  800168:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80016e:	83 c4 10             	add    $0x10,%esp
  800171:	eb db                	jmp    80014e <putch+0x23>

00800173 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800173:	f3 0f 1e fb          	endbr32 
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800180:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800187:	00 00 00 
	b.cnt = 0;
  80018a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800191:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800194:	ff 75 0c             	pushl  0xc(%ebp)
  800197:	ff 75 08             	pushl  0x8(%ebp)
  80019a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a0:	50                   	push   %eax
  8001a1:	68 2b 01 80 00       	push   $0x80012b
  8001a6:	e8 20 01 00 00       	call   8002cb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ab:	83 c4 08             	add    $0x8,%esp
  8001ae:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001b4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ba:	50                   	push   %eax
  8001bb:	e8 83 09 00 00       	call   800b43 <sys_cputs>

	return b.cnt;
}
  8001c0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001c6:	c9                   	leave  
  8001c7:	c3                   	ret    

008001c8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c8:	f3 0f 1e fb          	endbr32 
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001d5:	50                   	push   %eax
  8001d6:	ff 75 08             	pushl  0x8(%ebp)
  8001d9:	e8 95 ff ff ff       	call   800173 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

008001e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	57                   	push   %edi
  8001e4:	56                   	push   %esi
  8001e5:	53                   	push   %ebx
  8001e6:	83 ec 1c             	sub    $0x1c,%esp
  8001e9:	89 c7                	mov    %eax,%edi
  8001eb:	89 d6                	mov    %edx,%esi
  8001ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f3:	89 d1                	mov    %edx,%ecx
  8001f5:	89 c2                	mov    %eax,%edx
  8001f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001fa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001fd:	8b 45 10             	mov    0x10(%ebp),%eax
  800200:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800203:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800206:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80020d:	39 c2                	cmp    %eax,%edx
  80020f:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800212:	72 3e                	jb     800252 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800214:	83 ec 0c             	sub    $0xc,%esp
  800217:	ff 75 18             	pushl  0x18(%ebp)
  80021a:	83 eb 01             	sub    $0x1,%ebx
  80021d:	53                   	push   %ebx
  80021e:	50                   	push   %eax
  80021f:	83 ec 08             	sub    $0x8,%esp
  800222:	ff 75 e4             	pushl  -0x1c(%ebp)
  800225:	ff 75 e0             	pushl  -0x20(%ebp)
  800228:	ff 75 dc             	pushl  -0x24(%ebp)
  80022b:	ff 75 d8             	pushl  -0x28(%ebp)
  80022e:	e8 ad 1d 00 00       	call   801fe0 <__udivdi3>
  800233:	83 c4 18             	add    $0x18,%esp
  800236:	52                   	push   %edx
  800237:	50                   	push   %eax
  800238:	89 f2                	mov    %esi,%edx
  80023a:	89 f8                	mov    %edi,%eax
  80023c:	e8 9f ff ff ff       	call   8001e0 <printnum>
  800241:	83 c4 20             	add    $0x20,%esp
  800244:	eb 13                	jmp    800259 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800246:	83 ec 08             	sub    $0x8,%esp
  800249:	56                   	push   %esi
  80024a:	ff 75 18             	pushl  0x18(%ebp)
  80024d:	ff d7                	call   *%edi
  80024f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800252:	83 eb 01             	sub    $0x1,%ebx
  800255:	85 db                	test   %ebx,%ebx
  800257:	7f ed                	jg     800246 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800259:	83 ec 08             	sub    $0x8,%esp
  80025c:	56                   	push   %esi
  80025d:	83 ec 04             	sub    $0x4,%esp
  800260:	ff 75 e4             	pushl  -0x1c(%ebp)
  800263:	ff 75 e0             	pushl  -0x20(%ebp)
  800266:	ff 75 dc             	pushl  -0x24(%ebp)
  800269:	ff 75 d8             	pushl  -0x28(%ebp)
  80026c:	e8 7f 1e 00 00       	call   8020f0 <__umoddi3>
  800271:	83 c4 14             	add    $0x14,%esp
  800274:	0f be 80 e0 22 80 00 	movsbl 0x8022e0(%eax),%eax
  80027b:	50                   	push   %eax
  80027c:	ff d7                	call   *%edi
}
  80027e:	83 c4 10             	add    $0x10,%esp
  800281:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800284:	5b                   	pop    %ebx
  800285:	5e                   	pop    %esi
  800286:	5f                   	pop    %edi
  800287:	5d                   	pop    %ebp
  800288:	c3                   	ret    

00800289 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800289:	f3 0f 1e fb          	endbr32 
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800293:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800297:	8b 10                	mov    (%eax),%edx
  800299:	3b 50 04             	cmp    0x4(%eax),%edx
  80029c:	73 0a                	jae    8002a8 <sprintputch+0x1f>
		*b->buf++ = ch;
  80029e:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002a1:	89 08                	mov    %ecx,(%eax)
  8002a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a6:	88 02                	mov    %al,(%edx)
}
  8002a8:	5d                   	pop    %ebp
  8002a9:	c3                   	ret    

008002aa <printfmt>:
{
  8002aa:	f3 0f 1e fb          	endbr32 
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002b4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b7:	50                   	push   %eax
  8002b8:	ff 75 10             	pushl  0x10(%ebp)
  8002bb:	ff 75 0c             	pushl  0xc(%ebp)
  8002be:	ff 75 08             	pushl  0x8(%ebp)
  8002c1:	e8 05 00 00 00       	call   8002cb <vprintfmt>
}
  8002c6:	83 c4 10             	add    $0x10,%esp
  8002c9:	c9                   	leave  
  8002ca:	c3                   	ret    

008002cb <vprintfmt>:
{
  8002cb:	f3 0f 1e fb          	endbr32 
  8002cf:	55                   	push   %ebp
  8002d0:	89 e5                	mov    %esp,%ebp
  8002d2:	57                   	push   %edi
  8002d3:	56                   	push   %esi
  8002d4:	53                   	push   %ebx
  8002d5:	83 ec 3c             	sub    $0x3c,%esp
  8002d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8002db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002de:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002e1:	e9 4a 03 00 00       	jmp    800630 <vprintfmt+0x365>
		padc = ' ';
  8002e6:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002ea:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002f1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002f8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002ff:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800304:	8d 47 01             	lea    0x1(%edi),%eax
  800307:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80030a:	0f b6 17             	movzbl (%edi),%edx
  80030d:	8d 42 dd             	lea    -0x23(%edx),%eax
  800310:	3c 55                	cmp    $0x55,%al
  800312:	0f 87 de 03 00 00    	ja     8006f6 <vprintfmt+0x42b>
  800318:	0f b6 c0             	movzbl %al,%eax
  80031b:	3e ff 24 85 20 24 80 	notrack jmp *0x802420(,%eax,4)
  800322:	00 
  800323:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800326:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80032a:	eb d8                	jmp    800304 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80032c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80032f:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800333:	eb cf                	jmp    800304 <vprintfmt+0x39>
  800335:	0f b6 d2             	movzbl %dl,%edx
  800338:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80033b:	b8 00 00 00 00       	mov    $0x0,%eax
  800340:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800343:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800346:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80034a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80034d:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800350:	83 f9 09             	cmp    $0x9,%ecx
  800353:	77 55                	ja     8003aa <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800355:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800358:	eb e9                	jmp    800343 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80035a:	8b 45 14             	mov    0x14(%ebp),%eax
  80035d:	8b 00                	mov    (%eax),%eax
  80035f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800362:	8b 45 14             	mov    0x14(%ebp),%eax
  800365:	8d 40 04             	lea    0x4(%eax),%eax
  800368:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80036b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80036e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800372:	79 90                	jns    800304 <vprintfmt+0x39>
				width = precision, precision = -1;
  800374:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800377:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80037a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800381:	eb 81                	jmp    800304 <vprintfmt+0x39>
  800383:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800386:	85 c0                	test   %eax,%eax
  800388:	ba 00 00 00 00       	mov    $0x0,%edx
  80038d:	0f 49 d0             	cmovns %eax,%edx
  800390:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800393:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800396:	e9 69 ff ff ff       	jmp    800304 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80039b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80039e:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003a5:	e9 5a ff ff ff       	jmp    800304 <vprintfmt+0x39>
  8003aa:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003b0:	eb bc                	jmp    80036e <vprintfmt+0xa3>
			lflag++;
  8003b2:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003b8:	e9 47 ff ff ff       	jmp    800304 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c0:	8d 78 04             	lea    0x4(%eax),%edi
  8003c3:	83 ec 08             	sub    $0x8,%esp
  8003c6:	53                   	push   %ebx
  8003c7:	ff 30                	pushl  (%eax)
  8003c9:	ff d6                	call   *%esi
			break;
  8003cb:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003ce:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003d1:	e9 57 02 00 00       	jmp    80062d <vprintfmt+0x362>
			err = va_arg(ap, int);
  8003d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d9:	8d 78 04             	lea    0x4(%eax),%edi
  8003dc:	8b 00                	mov    (%eax),%eax
  8003de:	99                   	cltd   
  8003df:	31 d0                	xor    %edx,%eax
  8003e1:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e3:	83 f8 0f             	cmp    $0xf,%eax
  8003e6:	7f 23                	jg     80040b <vprintfmt+0x140>
  8003e8:	8b 14 85 80 25 80 00 	mov    0x802580(,%eax,4),%edx
  8003ef:	85 d2                	test   %edx,%edx
  8003f1:	74 18                	je     80040b <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8003f3:	52                   	push   %edx
  8003f4:	68 89 27 80 00       	push   $0x802789
  8003f9:	53                   	push   %ebx
  8003fa:	56                   	push   %esi
  8003fb:	e8 aa fe ff ff       	call   8002aa <printfmt>
  800400:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800403:	89 7d 14             	mov    %edi,0x14(%ebp)
  800406:	e9 22 02 00 00       	jmp    80062d <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  80040b:	50                   	push   %eax
  80040c:	68 f8 22 80 00       	push   $0x8022f8
  800411:	53                   	push   %ebx
  800412:	56                   	push   %esi
  800413:	e8 92 fe ff ff       	call   8002aa <printfmt>
  800418:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80041b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80041e:	e9 0a 02 00 00       	jmp    80062d <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  800423:	8b 45 14             	mov    0x14(%ebp),%eax
  800426:	83 c0 04             	add    $0x4,%eax
  800429:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80042c:	8b 45 14             	mov    0x14(%ebp),%eax
  80042f:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800431:	85 d2                	test   %edx,%edx
  800433:	b8 f1 22 80 00       	mov    $0x8022f1,%eax
  800438:	0f 45 c2             	cmovne %edx,%eax
  80043b:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80043e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800442:	7e 06                	jle    80044a <vprintfmt+0x17f>
  800444:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800448:	75 0d                	jne    800457 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80044a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80044d:	89 c7                	mov    %eax,%edi
  80044f:	03 45 e0             	add    -0x20(%ebp),%eax
  800452:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800455:	eb 55                	jmp    8004ac <vprintfmt+0x1e1>
  800457:	83 ec 08             	sub    $0x8,%esp
  80045a:	ff 75 d8             	pushl  -0x28(%ebp)
  80045d:	ff 75 cc             	pushl  -0x34(%ebp)
  800460:	e8 45 03 00 00       	call   8007aa <strnlen>
  800465:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800468:	29 c2                	sub    %eax,%edx
  80046a:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80046d:	83 c4 10             	add    $0x10,%esp
  800470:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800472:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800476:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800479:	85 ff                	test   %edi,%edi
  80047b:	7e 11                	jle    80048e <vprintfmt+0x1c3>
					putch(padc, putdat);
  80047d:	83 ec 08             	sub    $0x8,%esp
  800480:	53                   	push   %ebx
  800481:	ff 75 e0             	pushl  -0x20(%ebp)
  800484:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800486:	83 ef 01             	sub    $0x1,%edi
  800489:	83 c4 10             	add    $0x10,%esp
  80048c:	eb eb                	jmp    800479 <vprintfmt+0x1ae>
  80048e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800491:	85 d2                	test   %edx,%edx
  800493:	b8 00 00 00 00       	mov    $0x0,%eax
  800498:	0f 49 c2             	cmovns %edx,%eax
  80049b:	29 c2                	sub    %eax,%edx
  80049d:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004a0:	eb a8                	jmp    80044a <vprintfmt+0x17f>
					putch(ch, putdat);
  8004a2:	83 ec 08             	sub    $0x8,%esp
  8004a5:	53                   	push   %ebx
  8004a6:	52                   	push   %edx
  8004a7:	ff d6                	call   *%esi
  8004a9:	83 c4 10             	add    $0x10,%esp
  8004ac:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004af:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004b1:	83 c7 01             	add    $0x1,%edi
  8004b4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004b8:	0f be d0             	movsbl %al,%edx
  8004bb:	85 d2                	test   %edx,%edx
  8004bd:	74 4b                	je     80050a <vprintfmt+0x23f>
  8004bf:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004c3:	78 06                	js     8004cb <vprintfmt+0x200>
  8004c5:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004c9:	78 1e                	js     8004e9 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004cb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004cf:	74 d1                	je     8004a2 <vprintfmt+0x1d7>
  8004d1:	0f be c0             	movsbl %al,%eax
  8004d4:	83 e8 20             	sub    $0x20,%eax
  8004d7:	83 f8 5e             	cmp    $0x5e,%eax
  8004da:	76 c6                	jbe    8004a2 <vprintfmt+0x1d7>
					putch('?', putdat);
  8004dc:	83 ec 08             	sub    $0x8,%esp
  8004df:	53                   	push   %ebx
  8004e0:	6a 3f                	push   $0x3f
  8004e2:	ff d6                	call   *%esi
  8004e4:	83 c4 10             	add    $0x10,%esp
  8004e7:	eb c3                	jmp    8004ac <vprintfmt+0x1e1>
  8004e9:	89 cf                	mov    %ecx,%edi
  8004eb:	eb 0e                	jmp    8004fb <vprintfmt+0x230>
				putch(' ', putdat);
  8004ed:	83 ec 08             	sub    $0x8,%esp
  8004f0:	53                   	push   %ebx
  8004f1:	6a 20                	push   $0x20
  8004f3:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004f5:	83 ef 01             	sub    $0x1,%edi
  8004f8:	83 c4 10             	add    $0x10,%esp
  8004fb:	85 ff                	test   %edi,%edi
  8004fd:	7f ee                	jg     8004ed <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8004ff:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800502:	89 45 14             	mov    %eax,0x14(%ebp)
  800505:	e9 23 01 00 00       	jmp    80062d <vprintfmt+0x362>
  80050a:	89 cf                	mov    %ecx,%edi
  80050c:	eb ed                	jmp    8004fb <vprintfmt+0x230>
	if (lflag >= 2)
  80050e:	83 f9 01             	cmp    $0x1,%ecx
  800511:	7f 1b                	jg     80052e <vprintfmt+0x263>
	else if (lflag)
  800513:	85 c9                	test   %ecx,%ecx
  800515:	74 63                	je     80057a <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800517:	8b 45 14             	mov    0x14(%ebp),%eax
  80051a:	8b 00                	mov    (%eax),%eax
  80051c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051f:	99                   	cltd   
  800520:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800523:	8b 45 14             	mov    0x14(%ebp),%eax
  800526:	8d 40 04             	lea    0x4(%eax),%eax
  800529:	89 45 14             	mov    %eax,0x14(%ebp)
  80052c:	eb 17                	jmp    800545 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80052e:	8b 45 14             	mov    0x14(%ebp),%eax
  800531:	8b 50 04             	mov    0x4(%eax),%edx
  800534:	8b 00                	mov    (%eax),%eax
  800536:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800539:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80053c:	8b 45 14             	mov    0x14(%ebp),%eax
  80053f:	8d 40 08             	lea    0x8(%eax),%eax
  800542:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800545:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800548:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80054b:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800550:	85 c9                	test   %ecx,%ecx
  800552:	0f 89 bb 00 00 00    	jns    800613 <vprintfmt+0x348>
				putch('-', putdat);
  800558:	83 ec 08             	sub    $0x8,%esp
  80055b:	53                   	push   %ebx
  80055c:	6a 2d                	push   $0x2d
  80055e:	ff d6                	call   *%esi
				num = -(long long) num;
  800560:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800563:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800566:	f7 da                	neg    %edx
  800568:	83 d1 00             	adc    $0x0,%ecx
  80056b:	f7 d9                	neg    %ecx
  80056d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800570:	b8 0a 00 00 00       	mov    $0xa,%eax
  800575:	e9 99 00 00 00       	jmp    800613 <vprintfmt+0x348>
		return va_arg(*ap, int);
  80057a:	8b 45 14             	mov    0x14(%ebp),%eax
  80057d:	8b 00                	mov    (%eax),%eax
  80057f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800582:	99                   	cltd   
  800583:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8d 40 04             	lea    0x4(%eax),%eax
  80058c:	89 45 14             	mov    %eax,0x14(%ebp)
  80058f:	eb b4                	jmp    800545 <vprintfmt+0x27a>
	if (lflag >= 2)
  800591:	83 f9 01             	cmp    $0x1,%ecx
  800594:	7f 1b                	jg     8005b1 <vprintfmt+0x2e6>
	else if (lflag)
  800596:	85 c9                	test   %ecx,%ecx
  800598:	74 2c                	je     8005c6 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8b 10                	mov    (%eax),%edx
  80059f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a4:	8d 40 04             	lea    0x4(%eax),%eax
  8005a7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005aa:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005af:	eb 62                	jmp    800613 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	8b 10                	mov    (%eax),%edx
  8005b6:	8b 48 04             	mov    0x4(%eax),%ecx
  8005b9:	8d 40 08             	lea    0x8(%eax),%eax
  8005bc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005bf:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005c4:	eb 4d                	jmp    800613 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8b 10                	mov    (%eax),%edx
  8005cb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d0:	8d 40 04             	lea    0x4(%eax),%eax
  8005d3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005d6:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8005db:	eb 36                	jmp    800613 <vprintfmt+0x348>
	if (lflag >= 2)
  8005dd:	83 f9 01             	cmp    $0x1,%ecx
  8005e0:	7f 17                	jg     8005f9 <vprintfmt+0x32e>
	else if (lflag)
  8005e2:	85 c9                	test   %ecx,%ecx
  8005e4:	74 6e                	je     800654 <vprintfmt+0x389>
		return va_arg(*ap, long);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8b 10                	mov    (%eax),%edx
  8005eb:	89 d0                	mov    %edx,%eax
  8005ed:	99                   	cltd   
  8005ee:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005f1:	8d 49 04             	lea    0x4(%ecx),%ecx
  8005f4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005f7:	eb 11                	jmp    80060a <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8005f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fc:	8b 50 04             	mov    0x4(%eax),%edx
  8005ff:	8b 00                	mov    (%eax),%eax
  800601:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800604:	8d 49 08             	lea    0x8(%ecx),%ecx
  800607:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  80060a:	89 d1                	mov    %edx,%ecx
  80060c:	89 c2                	mov    %eax,%edx
            base = 8;
  80060e:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800613:	83 ec 0c             	sub    $0xc,%esp
  800616:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80061a:	57                   	push   %edi
  80061b:	ff 75 e0             	pushl  -0x20(%ebp)
  80061e:	50                   	push   %eax
  80061f:	51                   	push   %ecx
  800620:	52                   	push   %edx
  800621:	89 da                	mov    %ebx,%edx
  800623:	89 f0                	mov    %esi,%eax
  800625:	e8 b6 fb ff ff       	call   8001e0 <printnum>
			break;
  80062a:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80062d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800630:	83 c7 01             	add    $0x1,%edi
  800633:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800637:	83 f8 25             	cmp    $0x25,%eax
  80063a:	0f 84 a6 fc ff ff    	je     8002e6 <vprintfmt+0x1b>
			if (ch == '\0')
  800640:	85 c0                	test   %eax,%eax
  800642:	0f 84 ce 00 00 00    	je     800716 <vprintfmt+0x44b>
			putch(ch, putdat);
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	53                   	push   %ebx
  80064c:	50                   	push   %eax
  80064d:	ff d6                	call   *%esi
  80064f:	83 c4 10             	add    $0x10,%esp
  800652:	eb dc                	jmp    800630 <vprintfmt+0x365>
		return va_arg(*ap, int);
  800654:	8b 45 14             	mov    0x14(%ebp),%eax
  800657:	8b 10                	mov    (%eax),%edx
  800659:	89 d0                	mov    %edx,%eax
  80065b:	99                   	cltd   
  80065c:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80065f:	8d 49 04             	lea    0x4(%ecx),%ecx
  800662:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800665:	eb a3                	jmp    80060a <vprintfmt+0x33f>
			putch('0', putdat);
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	53                   	push   %ebx
  80066b:	6a 30                	push   $0x30
  80066d:	ff d6                	call   *%esi
			putch('x', putdat);
  80066f:	83 c4 08             	add    $0x8,%esp
  800672:	53                   	push   %ebx
  800673:	6a 78                	push   $0x78
  800675:	ff d6                	call   *%esi
			num = (unsigned long long)
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	8b 10                	mov    (%eax),%edx
  80067c:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800681:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800684:	8d 40 04             	lea    0x4(%eax),%eax
  800687:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80068a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80068f:	eb 82                	jmp    800613 <vprintfmt+0x348>
	if (lflag >= 2)
  800691:	83 f9 01             	cmp    $0x1,%ecx
  800694:	7f 1e                	jg     8006b4 <vprintfmt+0x3e9>
	else if (lflag)
  800696:	85 c9                	test   %ecx,%ecx
  800698:	74 32                	je     8006cc <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  80069a:	8b 45 14             	mov    0x14(%ebp),%eax
  80069d:	8b 10                	mov    (%eax),%edx
  80069f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a4:	8d 40 04             	lea    0x4(%eax),%eax
  8006a7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006aa:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006af:	e9 5f ff ff ff       	jmp    800613 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8006b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b7:	8b 10                	mov    (%eax),%edx
  8006b9:	8b 48 04             	mov    0x4(%eax),%ecx
  8006bc:	8d 40 08             	lea    0x8(%eax),%eax
  8006bf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c2:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006c7:	e9 47 ff ff ff       	jmp    800613 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8006cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cf:	8b 10                	mov    (%eax),%edx
  8006d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d6:	8d 40 04             	lea    0x4(%eax),%eax
  8006d9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006dc:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006e1:	e9 2d ff ff ff       	jmp    800613 <vprintfmt+0x348>
			putch(ch, putdat);
  8006e6:	83 ec 08             	sub    $0x8,%esp
  8006e9:	53                   	push   %ebx
  8006ea:	6a 25                	push   $0x25
  8006ec:	ff d6                	call   *%esi
			break;
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	e9 37 ff ff ff       	jmp    80062d <vprintfmt+0x362>
			putch('%', putdat);
  8006f6:	83 ec 08             	sub    $0x8,%esp
  8006f9:	53                   	push   %ebx
  8006fa:	6a 25                	push   $0x25
  8006fc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fe:	83 c4 10             	add    $0x10,%esp
  800701:	89 f8                	mov    %edi,%eax
  800703:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800707:	74 05                	je     80070e <vprintfmt+0x443>
  800709:	83 e8 01             	sub    $0x1,%eax
  80070c:	eb f5                	jmp    800703 <vprintfmt+0x438>
  80070e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800711:	e9 17 ff ff ff       	jmp    80062d <vprintfmt+0x362>
}
  800716:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800719:	5b                   	pop    %ebx
  80071a:	5e                   	pop    %esi
  80071b:	5f                   	pop    %edi
  80071c:	5d                   	pop    %ebp
  80071d:	c3                   	ret    

0080071e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80071e:	f3 0f 1e fb          	endbr32 
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
  800725:	83 ec 18             	sub    $0x18,%esp
  800728:	8b 45 08             	mov    0x8(%ebp),%eax
  80072b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80072e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800731:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800735:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800738:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80073f:	85 c0                	test   %eax,%eax
  800741:	74 26                	je     800769 <vsnprintf+0x4b>
  800743:	85 d2                	test   %edx,%edx
  800745:	7e 22                	jle    800769 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800747:	ff 75 14             	pushl  0x14(%ebp)
  80074a:	ff 75 10             	pushl  0x10(%ebp)
  80074d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800750:	50                   	push   %eax
  800751:	68 89 02 80 00       	push   $0x800289
  800756:	e8 70 fb ff ff       	call   8002cb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80075b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80075e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800761:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800764:	83 c4 10             	add    $0x10,%esp
}
  800767:	c9                   	leave  
  800768:	c3                   	ret    
		return -E_INVAL;
  800769:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80076e:	eb f7                	jmp    800767 <vsnprintf+0x49>

00800770 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800770:	f3 0f 1e fb          	endbr32 
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80077a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80077d:	50                   	push   %eax
  80077e:	ff 75 10             	pushl  0x10(%ebp)
  800781:	ff 75 0c             	pushl  0xc(%ebp)
  800784:	ff 75 08             	pushl  0x8(%ebp)
  800787:	e8 92 ff ff ff       	call   80071e <vsnprintf>
	va_end(ap);

	return rc;
}
  80078c:	c9                   	leave  
  80078d:	c3                   	ret    

0080078e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80078e:	f3 0f 1e fb          	endbr32 
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800798:	b8 00 00 00 00       	mov    $0x0,%eax
  80079d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a1:	74 05                	je     8007a8 <strlen+0x1a>
		n++;
  8007a3:	83 c0 01             	add    $0x1,%eax
  8007a6:	eb f5                	jmp    80079d <strlen+0xf>
	return n;
}
  8007a8:	5d                   	pop    %ebp
  8007a9:	c3                   	ret    

008007aa <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007aa:	f3 0f 1e fb          	endbr32 
  8007ae:	55                   	push   %ebp
  8007af:	89 e5                	mov    %esp,%ebp
  8007b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b4:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bc:	39 d0                	cmp    %edx,%eax
  8007be:	74 0d                	je     8007cd <strnlen+0x23>
  8007c0:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007c4:	74 05                	je     8007cb <strnlen+0x21>
		n++;
  8007c6:	83 c0 01             	add    $0x1,%eax
  8007c9:	eb f1                	jmp    8007bc <strnlen+0x12>
  8007cb:	89 c2                	mov    %eax,%edx
	return n;
}
  8007cd:	89 d0                	mov    %edx,%eax
  8007cf:	5d                   	pop    %ebp
  8007d0:	c3                   	ret    

008007d1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d1:	f3 0f 1e fb          	endbr32 
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	53                   	push   %ebx
  8007d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007df:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e4:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007e8:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007eb:	83 c0 01             	add    $0x1,%eax
  8007ee:	84 d2                	test   %dl,%dl
  8007f0:	75 f2                	jne    8007e4 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8007f2:	89 c8                	mov    %ecx,%eax
  8007f4:	5b                   	pop    %ebx
  8007f5:	5d                   	pop    %ebp
  8007f6:	c3                   	ret    

008007f7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f7:	f3 0f 1e fb          	endbr32 
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	53                   	push   %ebx
  8007ff:	83 ec 10             	sub    $0x10,%esp
  800802:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800805:	53                   	push   %ebx
  800806:	e8 83 ff ff ff       	call   80078e <strlen>
  80080b:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80080e:	ff 75 0c             	pushl  0xc(%ebp)
  800811:	01 d8                	add    %ebx,%eax
  800813:	50                   	push   %eax
  800814:	e8 b8 ff ff ff       	call   8007d1 <strcpy>
	return dst;
}
  800819:	89 d8                	mov    %ebx,%eax
  80081b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80081e:	c9                   	leave  
  80081f:	c3                   	ret    

00800820 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800820:	f3 0f 1e fb          	endbr32 
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	56                   	push   %esi
  800828:	53                   	push   %ebx
  800829:	8b 75 08             	mov    0x8(%ebp),%esi
  80082c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082f:	89 f3                	mov    %esi,%ebx
  800831:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800834:	89 f0                	mov    %esi,%eax
  800836:	39 d8                	cmp    %ebx,%eax
  800838:	74 11                	je     80084b <strncpy+0x2b>
		*dst++ = *src;
  80083a:	83 c0 01             	add    $0x1,%eax
  80083d:	0f b6 0a             	movzbl (%edx),%ecx
  800840:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800843:	80 f9 01             	cmp    $0x1,%cl
  800846:	83 da ff             	sbb    $0xffffffff,%edx
  800849:	eb eb                	jmp    800836 <strncpy+0x16>
	}
	return ret;
}
  80084b:	89 f0                	mov    %esi,%eax
  80084d:	5b                   	pop    %ebx
  80084e:	5e                   	pop    %esi
  80084f:	5d                   	pop    %ebp
  800850:	c3                   	ret    

00800851 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800851:	f3 0f 1e fb          	endbr32 
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	56                   	push   %esi
  800859:	53                   	push   %ebx
  80085a:	8b 75 08             	mov    0x8(%ebp),%esi
  80085d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800860:	8b 55 10             	mov    0x10(%ebp),%edx
  800863:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800865:	85 d2                	test   %edx,%edx
  800867:	74 21                	je     80088a <strlcpy+0x39>
  800869:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80086d:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80086f:	39 c2                	cmp    %eax,%edx
  800871:	74 14                	je     800887 <strlcpy+0x36>
  800873:	0f b6 19             	movzbl (%ecx),%ebx
  800876:	84 db                	test   %bl,%bl
  800878:	74 0b                	je     800885 <strlcpy+0x34>
			*dst++ = *src++;
  80087a:	83 c1 01             	add    $0x1,%ecx
  80087d:	83 c2 01             	add    $0x1,%edx
  800880:	88 5a ff             	mov    %bl,-0x1(%edx)
  800883:	eb ea                	jmp    80086f <strlcpy+0x1e>
  800885:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800887:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80088a:	29 f0                	sub    %esi,%eax
}
  80088c:	5b                   	pop    %ebx
  80088d:	5e                   	pop    %esi
  80088e:	5d                   	pop    %ebp
  80088f:	c3                   	ret    

00800890 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800890:	f3 0f 1e fb          	endbr32 
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80089d:	0f b6 01             	movzbl (%ecx),%eax
  8008a0:	84 c0                	test   %al,%al
  8008a2:	74 0c                	je     8008b0 <strcmp+0x20>
  8008a4:	3a 02                	cmp    (%edx),%al
  8008a6:	75 08                	jne    8008b0 <strcmp+0x20>
		p++, q++;
  8008a8:	83 c1 01             	add    $0x1,%ecx
  8008ab:	83 c2 01             	add    $0x1,%edx
  8008ae:	eb ed                	jmp    80089d <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b0:	0f b6 c0             	movzbl %al,%eax
  8008b3:	0f b6 12             	movzbl (%edx),%edx
  8008b6:	29 d0                	sub    %edx,%eax
}
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ba:	f3 0f 1e fb          	endbr32 
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	53                   	push   %ebx
  8008c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c8:	89 c3                	mov    %eax,%ebx
  8008ca:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008cd:	eb 06                	jmp    8008d5 <strncmp+0x1b>
		n--, p++, q++;
  8008cf:	83 c0 01             	add    $0x1,%eax
  8008d2:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008d5:	39 d8                	cmp    %ebx,%eax
  8008d7:	74 16                	je     8008ef <strncmp+0x35>
  8008d9:	0f b6 08             	movzbl (%eax),%ecx
  8008dc:	84 c9                	test   %cl,%cl
  8008de:	74 04                	je     8008e4 <strncmp+0x2a>
  8008e0:	3a 0a                	cmp    (%edx),%cl
  8008e2:	74 eb                	je     8008cf <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e4:	0f b6 00             	movzbl (%eax),%eax
  8008e7:	0f b6 12             	movzbl (%edx),%edx
  8008ea:	29 d0                	sub    %edx,%eax
}
  8008ec:	5b                   	pop    %ebx
  8008ed:	5d                   	pop    %ebp
  8008ee:	c3                   	ret    
		return 0;
  8008ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f4:	eb f6                	jmp    8008ec <strncmp+0x32>

008008f6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f6:	f3 0f 1e fb          	endbr32 
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800900:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800904:	0f b6 10             	movzbl (%eax),%edx
  800907:	84 d2                	test   %dl,%dl
  800909:	74 09                	je     800914 <strchr+0x1e>
		if (*s == c)
  80090b:	38 ca                	cmp    %cl,%dl
  80090d:	74 0a                	je     800919 <strchr+0x23>
	for (; *s; s++)
  80090f:	83 c0 01             	add    $0x1,%eax
  800912:	eb f0                	jmp    800904 <strchr+0xe>
			return (char *) s;
	return 0;
  800914:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091b:	f3 0f 1e fb          	endbr32 
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	8b 45 08             	mov    0x8(%ebp),%eax
  800925:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800929:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80092c:	38 ca                	cmp    %cl,%dl
  80092e:	74 09                	je     800939 <strfind+0x1e>
  800930:	84 d2                	test   %dl,%dl
  800932:	74 05                	je     800939 <strfind+0x1e>
	for (; *s; s++)
  800934:	83 c0 01             	add    $0x1,%eax
  800937:	eb f0                	jmp    800929 <strfind+0xe>
			break;
	return (char *) s;
}
  800939:	5d                   	pop    %ebp
  80093a:	c3                   	ret    

0080093b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80093b:	f3 0f 1e fb          	endbr32 
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	57                   	push   %edi
  800943:	56                   	push   %esi
  800944:	53                   	push   %ebx
  800945:	8b 7d 08             	mov    0x8(%ebp),%edi
  800948:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80094b:	85 c9                	test   %ecx,%ecx
  80094d:	74 31                	je     800980 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80094f:	89 f8                	mov    %edi,%eax
  800951:	09 c8                	or     %ecx,%eax
  800953:	a8 03                	test   $0x3,%al
  800955:	75 23                	jne    80097a <memset+0x3f>
		c &= 0xFF;
  800957:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80095b:	89 d3                	mov    %edx,%ebx
  80095d:	c1 e3 08             	shl    $0x8,%ebx
  800960:	89 d0                	mov    %edx,%eax
  800962:	c1 e0 18             	shl    $0x18,%eax
  800965:	89 d6                	mov    %edx,%esi
  800967:	c1 e6 10             	shl    $0x10,%esi
  80096a:	09 f0                	or     %esi,%eax
  80096c:	09 c2                	or     %eax,%edx
  80096e:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800970:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800973:	89 d0                	mov    %edx,%eax
  800975:	fc                   	cld    
  800976:	f3 ab                	rep stos %eax,%es:(%edi)
  800978:	eb 06                	jmp    800980 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80097a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097d:	fc                   	cld    
  80097e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800980:	89 f8                	mov    %edi,%eax
  800982:	5b                   	pop    %ebx
  800983:	5e                   	pop    %esi
  800984:	5f                   	pop    %edi
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800987:	f3 0f 1e fb          	endbr32 
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	57                   	push   %edi
  80098f:	56                   	push   %esi
  800990:	8b 45 08             	mov    0x8(%ebp),%eax
  800993:	8b 75 0c             	mov    0xc(%ebp),%esi
  800996:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800999:	39 c6                	cmp    %eax,%esi
  80099b:	73 32                	jae    8009cf <memmove+0x48>
  80099d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a0:	39 c2                	cmp    %eax,%edx
  8009a2:	76 2b                	jbe    8009cf <memmove+0x48>
		s += n;
		d += n;
  8009a4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a7:	89 fe                	mov    %edi,%esi
  8009a9:	09 ce                	or     %ecx,%esi
  8009ab:	09 d6                	or     %edx,%esi
  8009ad:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b3:	75 0e                	jne    8009c3 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b5:	83 ef 04             	sub    $0x4,%edi
  8009b8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009bb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009be:	fd                   	std    
  8009bf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c1:	eb 09                	jmp    8009cc <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c3:	83 ef 01             	sub    $0x1,%edi
  8009c6:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009c9:	fd                   	std    
  8009ca:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009cc:	fc                   	cld    
  8009cd:	eb 1a                	jmp    8009e9 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cf:	89 c2                	mov    %eax,%edx
  8009d1:	09 ca                	or     %ecx,%edx
  8009d3:	09 f2                	or     %esi,%edx
  8009d5:	f6 c2 03             	test   $0x3,%dl
  8009d8:	75 0a                	jne    8009e4 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009da:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009dd:	89 c7                	mov    %eax,%edi
  8009df:	fc                   	cld    
  8009e0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e2:	eb 05                	jmp    8009e9 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8009e4:	89 c7                	mov    %eax,%edi
  8009e6:	fc                   	cld    
  8009e7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e9:	5e                   	pop    %esi
  8009ea:	5f                   	pop    %edi
  8009eb:	5d                   	pop    %ebp
  8009ec:	c3                   	ret    

008009ed <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ed:	f3 0f 1e fb          	endbr32 
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009f7:	ff 75 10             	pushl  0x10(%ebp)
  8009fa:	ff 75 0c             	pushl  0xc(%ebp)
  8009fd:	ff 75 08             	pushl  0x8(%ebp)
  800a00:	e8 82 ff ff ff       	call   800987 <memmove>
}
  800a05:	c9                   	leave  
  800a06:	c3                   	ret    

00800a07 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a07:	f3 0f 1e fb          	endbr32 
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	56                   	push   %esi
  800a0f:	53                   	push   %ebx
  800a10:	8b 45 08             	mov    0x8(%ebp),%eax
  800a13:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a16:	89 c6                	mov    %eax,%esi
  800a18:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1b:	39 f0                	cmp    %esi,%eax
  800a1d:	74 1c                	je     800a3b <memcmp+0x34>
		if (*s1 != *s2)
  800a1f:	0f b6 08             	movzbl (%eax),%ecx
  800a22:	0f b6 1a             	movzbl (%edx),%ebx
  800a25:	38 d9                	cmp    %bl,%cl
  800a27:	75 08                	jne    800a31 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a29:	83 c0 01             	add    $0x1,%eax
  800a2c:	83 c2 01             	add    $0x1,%edx
  800a2f:	eb ea                	jmp    800a1b <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a31:	0f b6 c1             	movzbl %cl,%eax
  800a34:	0f b6 db             	movzbl %bl,%ebx
  800a37:	29 d8                	sub    %ebx,%eax
  800a39:	eb 05                	jmp    800a40 <memcmp+0x39>
	}

	return 0;
  800a3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a40:	5b                   	pop    %ebx
  800a41:	5e                   	pop    %esi
  800a42:	5d                   	pop    %ebp
  800a43:	c3                   	ret    

00800a44 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a44:	f3 0f 1e fb          	endbr32 
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a51:	89 c2                	mov    %eax,%edx
  800a53:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a56:	39 d0                	cmp    %edx,%eax
  800a58:	73 09                	jae    800a63 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a5a:	38 08                	cmp    %cl,(%eax)
  800a5c:	74 05                	je     800a63 <memfind+0x1f>
	for (; s < ends; s++)
  800a5e:	83 c0 01             	add    $0x1,%eax
  800a61:	eb f3                	jmp    800a56 <memfind+0x12>
			break;
	return (void *) s;
}
  800a63:	5d                   	pop    %ebp
  800a64:	c3                   	ret    

00800a65 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a65:	f3 0f 1e fb          	endbr32 
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
  800a6c:	57                   	push   %edi
  800a6d:	56                   	push   %esi
  800a6e:	53                   	push   %ebx
  800a6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a72:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a75:	eb 03                	jmp    800a7a <strtol+0x15>
		s++;
  800a77:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a7a:	0f b6 01             	movzbl (%ecx),%eax
  800a7d:	3c 20                	cmp    $0x20,%al
  800a7f:	74 f6                	je     800a77 <strtol+0x12>
  800a81:	3c 09                	cmp    $0x9,%al
  800a83:	74 f2                	je     800a77 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a85:	3c 2b                	cmp    $0x2b,%al
  800a87:	74 2a                	je     800ab3 <strtol+0x4e>
	int neg = 0;
  800a89:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a8e:	3c 2d                	cmp    $0x2d,%al
  800a90:	74 2b                	je     800abd <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a92:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a98:	75 0f                	jne    800aa9 <strtol+0x44>
  800a9a:	80 39 30             	cmpb   $0x30,(%ecx)
  800a9d:	74 28                	je     800ac7 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a9f:	85 db                	test   %ebx,%ebx
  800aa1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aa6:	0f 44 d8             	cmove  %eax,%ebx
  800aa9:	b8 00 00 00 00       	mov    $0x0,%eax
  800aae:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ab1:	eb 46                	jmp    800af9 <strtol+0x94>
		s++;
  800ab3:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ab6:	bf 00 00 00 00       	mov    $0x0,%edi
  800abb:	eb d5                	jmp    800a92 <strtol+0x2d>
		s++, neg = 1;
  800abd:	83 c1 01             	add    $0x1,%ecx
  800ac0:	bf 01 00 00 00       	mov    $0x1,%edi
  800ac5:	eb cb                	jmp    800a92 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800acb:	74 0e                	je     800adb <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800acd:	85 db                	test   %ebx,%ebx
  800acf:	75 d8                	jne    800aa9 <strtol+0x44>
		s++, base = 8;
  800ad1:	83 c1 01             	add    $0x1,%ecx
  800ad4:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ad9:	eb ce                	jmp    800aa9 <strtol+0x44>
		s += 2, base = 16;
  800adb:	83 c1 02             	add    $0x2,%ecx
  800ade:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ae3:	eb c4                	jmp    800aa9 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ae5:	0f be d2             	movsbl %dl,%edx
  800ae8:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aeb:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aee:	7d 3a                	jge    800b2a <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800af0:	83 c1 01             	add    $0x1,%ecx
  800af3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800af7:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800af9:	0f b6 11             	movzbl (%ecx),%edx
  800afc:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aff:	89 f3                	mov    %esi,%ebx
  800b01:	80 fb 09             	cmp    $0x9,%bl
  800b04:	76 df                	jbe    800ae5 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b06:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b09:	89 f3                	mov    %esi,%ebx
  800b0b:	80 fb 19             	cmp    $0x19,%bl
  800b0e:	77 08                	ja     800b18 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b10:	0f be d2             	movsbl %dl,%edx
  800b13:	83 ea 57             	sub    $0x57,%edx
  800b16:	eb d3                	jmp    800aeb <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b18:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b1b:	89 f3                	mov    %esi,%ebx
  800b1d:	80 fb 19             	cmp    $0x19,%bl
  800b20:	77 08                	ja     800b2a <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b22:	0f be d2             	movsbl %dl,%edx
  800b25:	83 ea 37             	sub    $0x37,%edx
  800b28:	eb c1                	jmp    800aeb <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b2a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b2e:	74 05                	je     800b35 <strtol+0xd0>
		*endptr = (char *) s;
  800b30:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b33:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b35:	89 c2                	mov    %eax,%edx
  800b37:	f7 da                	neg    %edx
  800b39:	85 ff                	test   %edi,%edi
  800b3b:	0f 45 c2             	cmovne %edx,%eax
}
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5f                   	pop    %edi
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b43:	f3 0f 1e fb          	endbr32 
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	57                   	push   %edi
  800b4b:	56                   	push   %esi
  800b4c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b52:	8b 55 08             	mov    0x8(%ebp),%edx
  800b55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b58:	89 c3                	mov    %eax,%ebx
  800b5a:	89 c7                	mov    %eax,%edi
  800b5c:	89 c6                	mov    %eax,%esi
  800b5e:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b60:	5b                   	pop    %ebx
  800b61:	5e                   	pop    %esi
  800b62:	5f                   	pop    %edi
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b65:	f3 0f 1e fb          	endbr32 
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	57                   	push   %edi
  800b6d:	56                   	push   %esi
  800b6e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b74:	b8 01 00 00 00       	mov    $0x1,%eax
  800b79:	89 d1                	mov    %edx,%ecx
  800b7b:	89 d3                	mov    %edx,%ebx
  800b7d:	89 d7                	mov    %edx,%edi
  800b7f:	89 d6                	mov    %edx,%esi
  800b81:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b83:	5b                   	pop    %ebx
  800b84:	5e                   	pop    %esi
  800b85:	5f                   	pop    %edi
  800b86:	5d                   	pop    %ebp
  800b87:	c3                   	ret    

00800b88 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b88:	f3 0f 1e fb          	endbr32 
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	57                   	push   %edi
  800b90:	56                   	push   %esi
  800b91:	53                   	push   %ebx
  800b92:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b95:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9d:	b8 03 00 00 00       	mov    $0x3,%eax
  800ba2:	89 cb                	mov    %ecx,%ebx
  800ba4:	89 cf                	mov    %ecx,%edi
  800ba6:	89 ce                	mov    %ecx,%esi
  800ba8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800baa:	85 c0                	test   %eax,%eax
  800bac:	7f 08                	jg     800bb6 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5f                   	pop    %edi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb6:	83 ec 0c             	sub    $0xc,%esp
  800bb9:	50                   	push   %eax
  800bba:	6a 03                	push   $0x3
  800bbc:	68 df 25 80 00       	push   $0x8025df
  800bc1:	6a 23                	push   $0x23
  800bc3:	68 fc 25 80 00       	push   $0x8025fc
  800bc8:	e8 e8 11 00 00       	call   801db5 <_panic>

00800bcd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bcd:	f3 0f 1e fb          	endbr32 
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	57                   	push   %edi
  800bd5:	56                   	push   %esi
  800bd6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdc:	b8 02 00 00 00       	mov    $0x2,%eax
  800be1:	89 d1                	mov    %edx,%ecx
  800be3:	89 d3                	mov    %edx,%ebx
  800be5:	89 d7                	mov    %edx,%edi
  800be7:	89 d6                	mov    %edx,%esi
  800be9:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800beb:	5b                   	pop    %ebx
  800bec:	5e                   	pop    %esi
  800bed:	5f                   	pop    %edi
  800bee:	5d                   	pop    %ebp
  800bef:	c3                   	ret    

00800bf0 <sys_yield>:

void
sys_yield(void)
{
  800bf0:	f3 0f 1e fb          	endbr32 
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	57                   	push   %edi
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bfa:	ba 00 00 00 00       	mov    $0x0,%edx
  800bff:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c04:	89 d1                	mov    %edx,%ecx
  800c06:	89 d3                	mov    %edx,%ebx
  800c08:	89 d7                	mov    %edx,%edi
  800c0a:	89 d6                	mov    %edx,%esi
  800c0c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c0e:	5b                   	pop    %ebx
  800c0f:	5e                   	pop    %esi
  800c10:	5f                   	pop    %edi
  800c11:	5d                   	pop    %ebp
  800c12:	c3                   	ret    

00800c13 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c13:	f3 0f 1e fb          	endbr32 
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	57                   	push   %edi
  800c1b:	56                   	push   %esi
  800c1c:	53                   	push   %ebx
  800c1d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c20:	be 00 00 00 00       	mov    $0x0,%esi
  800c25:	8b 55 08             	mov    0x8(%ebp),%edx
  800c28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2b:	b8 04 00 00 00       	mov    $0x4,%eax
  800c30:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c33:	89 f7                	mov    %esi,%edi
  800c35:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c37:	85 c0                	test   %eax,%eax
  800c39:	7f 08                	jg     800c43 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c43:	83 ec 0c             	sub    $0xc,%esp
  800c46:	50                   	push   %eax
  800c47:	6a 04                	push   $0x4
  800c49:	68 df 25 80 00       	push   $0x8025df
  800c4e:	6a 23                	push   $0x23
  800c50:	68 fc 25 80 00       	push   $0x8025fc
  800c55:	e8 5b 11 00 00       	call   801db5 <_panic>

00800c5a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c5a:	f3 0f 1e fb          	endbr32 
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	57                   	push   %edi
  800c62:	56                   	push   %esi
  800c63:	53                   	push   %ebx
  800c64:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c67:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6d:	b8 05 00 00 00       	mov    $0x5,%eax
  800c72:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c75:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c78:	8b 75 18             	mov    0x18(%ebp),%esi
  800c7b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c7d:	85 c0                	test   %eax,%eax
  800c7f:	7f 08                	jg     800c89 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c89:	83 ec 0c             	sub    $0xc,%esp
  800c8c:	50                   	push   %eax
  800c8d:	6a 05                	push   $0x5
  800c8f:	68 df 25 80 00       	push   $0x8025df
  800c94:	6a 23                	push   $0x23
  800c96:	68 fc 25 80 00       	push   $0x8025fc
  800c9b:	e8 15 11 00 00       	call   801db5 <_panic>

00800ca0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ca0:	f3 0f 1e fb          	endbr32 
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	57                   	push   %edi
  800ca8:	56                   	push   %esi
  800ca9:	53                   	push   %ebx
  800caa:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cad:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb8:	b8 06 00 00 00       	mov    $0x6,%eax
  800cbd:	89 df                	mov    %ebx,%edi
  800cbf:	89 de                	mov    %ebx,%esi
  800cc1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cc3:	85 c0                	test   %eax,%eax
  800cc5:	7f 08                	jg     800ccf <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cca:	5b                   	pop    %ebx
  800ccb:	5e                   	pop    %esi
  800ccc:	5f                   	pop    %edi
  800ccd:	5d                   	pop    %ebp
  800cce:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccf:	83 ec 0c             	sub    $0xc,%esp
  800cd2:	50                   	push   %eax
  800cd3:	6a 06                	push   $0x6
  800cd5:	68 df 25 80 00       	push   $0x8025df
  800cda:	6a 23                	push   $0x23
  800cdc:	68 fc 25 80 00       	push   $0x8025fc
  800ce1:	e8 cf 10 00 00       	call   801db5 <_panic>

00800ce6 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ce6:	f3 0f 1e fb          	endbr32 
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	57                   	push   %edi
  800cee:	56                   	push   %esi
  800cef:	53                   	push   %ebx
  800cf0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cf3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfe:	b8 08 00 00 00       	mov    $0x8,%eax
  800d03:	89 df                	mov    %ebx,%edi
  800d05:	89 de                	mov    %ebx,%esi
  800d07:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d09:	85 c0                	test   %eax,%eax
  800d0b:	7f 08                	jg     800d15 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d10:	5b                   	pop    %ebx
  800d11:	5e                   	pop    %esi
  800d12:	5f                   	pop    %edi
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d15:	83 ec 0c             	sub    $0xc,%esp
  800d18:	50                   	push   %eax
  800d19:	6a 08                	push   $0x8
  800d1b:	68 df 25 80 00       	push   $0x8025df
  800d20:	6a 23                	push   $0x23
  800d22:	68 fc 25 80 00       	push   $0x8025fc
  800d27:	e8 89 10 00 00       	call   801db5 <_panic>

00800d2c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d2c:	f3 0f 1e fb          	endbr32 
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	57                   	push   %edi
  800d34:	56                   	push   %esi
  800d35:	53                   	push   %ebx
  800d36:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d39:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d44:	b8 09 00 00 00       	mov    $0x9,%eax
  800d49:	89 df                	mov    %ebx,%edi
  800d4b:	89 de                	mov    %ebx,%esi
  800d4d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d4f:	85 c0                	test   %eax,%eax
  800d51:	7f 08                	jg     800d5b <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d56:	5b                   	pop    %ebx
  800d57:	5e                   	pop    %esi
  800d58:	5f                   	pop    %edi
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5b:	83 ec 0c             	sub    $0xc,%esp
  800d5e:	50                   	push   %eax
  800d5f:	6a 09                	push   $0x9
  800d61:	68 df 25 80 00       	push   $0x8025df
  800d66:	6a 23                	push   $0x23
  800d68:	68 fc 25 80 00       	push   $0x8025fc
  800d6d:	e8 43 10 00 00       	call   801db5 <_panic>

00800d72 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d72:	f3 0f 1e fb          	endbr32 
  800d76:	55                   	push   %ebp
  800d77:	89 e5                	mov    %esp,%ebp
  800d79:	57                   	push   %edi
  800d7a:	56                   	push   %esi
  800d7b:	53                   	push   %ebx
  800d7c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d7f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d84:	8b 55 08             	mov    0x8(%ebp),%edx
  800d87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d8f:	89 df                	mov    %ebx,%edi
  800d91:	89 de                	mov    %ebx,%esi
  800d93:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d95:	85 c0                	test   %eax,%eax
  800d97:	7f 08                	jg     800da1 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9c:	5b                   	pop    %ebx
  800d9d:	5e                   	pop    %esi
  800d9e:	5f                   	pop    %edi
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800da1:	83 ec 0c             	sub    $0xc,%esp
  800da4:	50                   	push   %eax
  800da5:	6a 0a                	push   $0xa
  800da7:	68 df 25 80 00       	push   $0x8025df
  800dac:	6a 23                	push   $0x23
  800dae:	68 fc 25 80 00       	push   $0x8025fc
  800db3:	e8 fd 0f 00 00       	call   801db5 <_panic>

00800db8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800db8:	f3 0f 1e fb          	endbr32 
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	57                   	push   %edi
  800dc0:	56                   	push   %esi
  800dc1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc8:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dcd:	be 00 00 00 00       	mov    $0x0,%esi
  800dd2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dd8:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dda:	5b                   	pop    %ebx
  800ddb:	5e                   	pop    %esi
  800ddc:	5f                   	pop    %edi
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    

00800ddf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ddf:	f3 0f 1e fb          	endbr32 
  800de3:	55                   	push   %ebp
  800de4:	89 e5                	mov    %esp,%ebp
  800de6:	57                   	push   %edi
  800de7:	56                   	push   %esi
  800de8:	53                   	push   %ebx
  800de9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dec:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df1:	8b 55 08             	mov    0x8(%ebp),%edx
  800df4:	b8 0d 00 00 00       	mov    $0xd,%eax
  800df9:	89 cb                	mov    %ecx,%ebx
  800dfb:	89 cf                	mov    %ecx,%edi
  800dfd:	89 ce                	mov    %ecx,%esi
  800dff:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e01:	85 c0                	test   %eax,%eax
  800e03:	7f 08                	jg     800e0d <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e08:	5b                   	pop    %ebx
  800e09:	5e                   	pop    %esi
  800e0a:	5f                   	pop    %edi
  800e0b:	5d                   	pop    %ebp
  800e0c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0d:	83 ec 0c             	sub    $0xc,%esp
  800e10:	50                   	push   %eax
  800e11:	6a 0d                	push   $0xd
  800e13:	68 df 25 80 00       	push   $0x8025df
  800e18:	6a 23                	push   $0x23
  800e1a:	68 fc 25 80 00       	push   $0x8025fc
  800e1f:	e8 91 0f 00 00       	call   801db5 <_panic>

00800e24 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e24:	f3 0f 1e fb          	endbr32 
  800e28:	55                   	push   %ebp
  800e29:	89 e5                	mov    %esp,%ebp
  800e2b:	53                   	push   %ebx
  800e2c:	83 ec 04             	sub    $0x4,%esp
  800e2f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e32:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if ( !(err & FEC_WR) ||
  800e34:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e38:	74 75                	je     800eaf <pgfault+0x8b>
            !(uvpt[PGNUM(addr)] | PTE_COW) ) {
  800e3a:	89 d8                	mov    %ebx,%eax
  800e3c:	c1 e8 0c             	shr    $0xc,%eax
  800e3f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, (void *)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0) {
  800e46:	83 ec 04             	sub    $0x4,%esp
  800e49:	6a 07                	push   $0x7
  800e4b:	68 00 f0 7f 00       	push   $0x7ff000
  800e50:	6a 00                	push   $0x0
  800e52:	e8 bc fd ff ff       	call   800c13 <sys_page_alloc>
  800e57:	83 c4 10             	add    $0x10,%esp
  800e5a:	85 c0                	test   %eax,%eax
  800e5c:	78 65                	js     800ec3 <pgfault+0x9f>
        panic("sys_page_alloc failed %e\n", r);
    }
    memmove((void *)PFTEMP, (void *)PTE_ADDR(addr), PGSIZE);
  800e5e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800e64:	83 ec 04             	sub    $0x4,%esp
  800e67:	68 00 10 00 00       	push   $0x1000
  800e6c:	53                   	push   %ebx
  800e6d:	68 00 f0 7f 00       	push   $0x7ff000
  800e72:	e8 10 fb ff ff       	call   800987 <memmove>
    if ((r = sys_page_map(0, (void *)PFTEMP,
  800e77:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e7e:	53                   	push   %ebx
  800e7f:	6a 00                	push   $0x0
  800e81:	68 00 f0 7f 00       	push   $0x7ff000
  800e86:	6a 00                	push   $0x0
  800e88:	e8 cd fd ff ff       	call   800c5a <sys_page_map>
  800e8d:	83 c4 20             	add    $0x20,%esp
  800e90:	85 c0                	test   %eax,%eax
  800e92:	78 41                	js     800ed5 <pgfault+0xb1>
                0, (void *)PTE_ADDR(addr), PTE_P | PTE_U | PTE_W)) < 0) {
        panic("sys_page_map failed %e\n", r);
    }
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0) {
  800e94:	83 ec 08             	sub    $0x8,%esp
  800e97:	68 00 f0 7f 00       	push   $0x7ff000
  800e9c:	6a 00                	push   $0x0
  800e9e:	e8 fd fd ff ff       	call   800ca0 <sys_page_unmap>
  800ea3:	83 c4 10             	add    $0x10,%esp
  800ea6:	85 c0                	test   %eax,%eax
  800ea8:	78 3d                	js     800ee7 <pgfault+0xc3>
        panic("sys_page_unmap failed %e\n", r);
    }

}
  800eaa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ead:	c9                   	leave  
  800eae:	c3                   	ret    
        panic("Not a copy-on-write page");
  800eaf:	83 ec 04             	sub    $0x4,%esp
  800eb2:	68 0a 26 80 00       	push   $0x80260a
  800eb7:	6a 1e                	push   $0x1e
  800eb9:	68 23 26 80 00       	push   $0x802623
  800ebe:	e8 f2 0e 00 00       	call   801db5 <_panic>
        panic("sys_page_alloc failed %e\n", r);
  800ec3:	50                   	push   %eax
  800ec4:	68 2e 26 80 00       	push   $0x80262e
  800ec9:	6a 2a                	push   $0x2a
  800ecb:	68 23 26 80 00       	push   $0x802623
  800ed0:	e8 e0 0e 00 00       	call   801db5 <_panic>
        panic("sys_page_map failed %e\n", r);
  800ed5:	50                   	push   %eax
  800ed6:	68 48 26 80 00       	push   $0x802648
  800edb:	6a 2f                	push   $0x2f
  800edd:	68 23 26 80 00       	push   $0x802623
  800ee2:	e8 ce 0e 00 00       	call   801db5 <_panic>
        panic("sys_page_unmap failed %e\n", r);
  800ee7:	50                   	push   %eax
  800ee8:	68 60 26 80 00       	push   $0x802660
  800eed:	6a 32                	push   $0x32
  800eef:	68 23 26 80 00       	push   $0x802623
  800ef4:	e8 bc 0e 00 00       	call   801db5 <_panic>

00800ef9 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ef9:	f3 0f 1e fb          	endbr32 
  800efd:	55                   	push   %ebp
  800efe:	89 e5                	mov    %esp,%ebp
  800f00:	57                   	push   %edi
  800f01:	56                   	push   %esi
  800f02:	53                   	push   %ebx
  800f03:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");

    // 1. set pgfault handler.
    set_pgfault_handler(pgfault);
  800f06:	68 24 0e 80 00       	push   $0x800e24
  800f0b:	e8 ef 0e 00 00       	call   801dff <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f10:	b8 07 00 00 00       	mov    $0x7,%eax
  800f15:	cd 30                	int    $0x30
  800f17:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f1a:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    // 2. exofork.
    envid_t envid = sys_exofork();

    if (envid < 0)
  800f1d:	83 c4 10             	add    $0x10,%esp
  800f20:	85 c0                	test   %eax,%eax
  800f22:	78 2a                	js     800f4e <fork+0x55>
        thisenv = &envs[ENVX(my_envid)];
        return 0;
    }
    else {
        // parent
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800f24:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (envid == 0) {
  800f29:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800f2d:	75 69                	jne    800f98 <fork+0x9f>
        envid_t my_envid = sys_getenvid();
  800f2f:	e8 99 fc ff ff       	call   800bcd <sys_getenvid>
        thisenv = &envs[ENVX(my_envid)];
  800f34:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f39:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f3c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f41:	a3 04 40 80 00       	mov    %eax,0x804004
        return 0;
  800f46:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f49:	e9 fc 00 00 00       	jmp    80104a <fork+0x151>
        panic("fork, sys_exofork %e", envid);
  800f4e:	50                   	push   %eax
  800f4f:	68 7a 26 80 00       	push   $0x80267a
  800f54:	6a 7b                	push   $0x7b
  800f56:	68 23 26 80 00       	push   $0x802623
  800f5b:	e8 55 0e 00 00       	call   801db5 <_panic>
    if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0) {
  800f60:	83 ec 0c             	sub    $0xc,%esp
  800f63:	57                   	push   %edi
  800f64:	56                   	push   %esi
  800f65:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f68:	56                   	push   %esi
  800f69:	6a 00                	push   $0x0
  800f6b:	e8 ea fc ff ff       	call   800c5a <sys_page_map>
  800f70:	83 c4 20             	add    $0x20,%esp
  800f73:	85 c0                	test   %eax,%eax
  800f75:	78 69                	js     800fe0 <fork+0xe7>
        if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0) {
  800f77:	83 ec 0c             	sub    $0xc,%esp
  800f7a:	57                   	push   %edi
  800f7b:	56                   	push   %esi
  800f7c:	6a 00                	push   $0x0
  800f7e:	56                   	push   %esi
  800f7f:	6a 00                	push   $0x0
  800f81:	e8 d4 fc ff ff       	call   800c5a <sys_page_map>
  800f86:	83 c4 20             	add    $0x20,%esp
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	78 65                	js     800ff2 <fork+0xf9>
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800f8d:	83 c3 01             	add    $0x1,%ebx
  800f90:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  800f96:	74 6c                	je     801004 <fork+0x10b>
  800f98:	89 de                	mov    %ebx,%esi
  800f9a:	c1 e6 0c             	shl    $0xc,%esi
            uintptr_t pgaddr = pn << PGSHIFT;
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800f9d:	89 f0                	mov    %esi,%eax
  800f9f:	c1 e8 16             	shr    $0x16,%eax
  800fa2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fa9:	a8 01                	test   $0x1,%al
  800fab:	74 e0                	je     800f8d <fork+0x94>
                    (uvpt[pn] & PTE_P) ) {
  800fad:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800fb4:	a8 01                	test   $0x1,%al
  800fb6:	74 d5                	je     800f8d <fork+0x94>
    pte_t pte = uvpt[pn];
  800fb8:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
    int perm = PTE_U | PTE_P;
  800fbf:	bf 05 00 00 00       	mov    $0x5,%edi
    if ( ((pte & PTE_W) || (pte & PTE_COW)) && !(pte & PTE_SHARE)) {
  800fc4:	a9 02 08 00 00       	test   $0x802,%eax
  800fc9:	74 95                	je     800f60 <fork+0x67>
  800fcb:	25 00 04 00 00       	and    $0x400,%eax
        perm |= PTE_COW;
  800fd0:	83 f8 01             	cmp    $0x1,%eax
  800fd3:	19 ff                	sbb    %edi,%edi
  800fd5:	81 e7 00 08 00 00    	and    $0x800,%edi
  800fdb:	83 c7 05             	add    $0x5,%edi
  800fde:	eb 80                	jmp    800f60 <fork+0x67>
        panic("sys_page_map others failed %e\n", r);
  800fe0:	50                   	push   %eax
  800fe1:	68 c4 26 80 00       	push   $0x8026c4
  800fe6:	6a 51                	push   $0x51
  800fe8:	68 23 26 80 00       	push   $0x802623
  800fed:	e8 c3 0d 00 00       	call   801db5 <_panic>
            panic("sys_page_map mine failed %e\n", r);
  800ff2:	50                   	push   %eax
  800ff3:	68 8f 26 80 00       	push   $0x80268f
  800ff8:	6a 56                	push   $0x56
  800ffa:	68 23 26 80 00       	push   $0x802623
  800fff:	e8 b1 0d 00 00       	call   801db5 <_panic>
            }
        }

        int r;

        if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE),
  801004:	83 ec 04             	sub    $0x4,%esp
  801007:	6a 07                	push   $0x7
  801009:	68 00 f0 bf ee       	push   $0xeebff000
  80100e:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801011:	57                   	push   %edi
  801012:	e8 fc fb ff ff       	call   800c13 <sys_page_alloc>
  801017:	83 c4 10             	add    $0x10,%esp
  80101a:	85 c0                	test   %eax,%eax
  80101c:	78 2c                	js     80104a <fork+0x151>
                    PTE_U | PTE_W | PTE_P)) < 0) {
            return r;
        }

        if ((r = sys_env_set_pgfault_upcall(envid,
                        thisenv->env_pgfault_upcall)) < 0) {
  80101e:	a1 04 40 80 00       	mov    0x804004,%eax
        if ((r = sys_env_set_pgfault_upcall(envid,
  801023:	8b 40 64             	mov    0x64(%eax),%eax
  801026:	83 ec 08             	sub    $0x8,%esp
  801029:	50                   	push   %eax
  80102a:	57                   	push   %edi
  80102b:	e8 42 fd ff ff       	call   800d72 <sys_env_set_pgfault_upcall>
  801030:	83 c4 10             	add    $0x10,%esp
  801033:	85 c0                	test   %eax,%eax
  801035:	78 13                	js     80104a <fork+0x151>
            return r;
        }

        if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  801037:	83 ec 08             	sub    $0x8,%esp
  80103a:	6a 02                	push   $0x2
  80103c:	57                   	push   %edi
  80103d:	e8 a4 fc ff ff       	call   800ce6 <sys_env_set_status>
  801042:	83 c4 10             	add    $0x10,%esp
            return r;
        }
        return envid;
  801045:	85 c0                	test   %eax,%eax
  801047:	0f 49 c7             	cmovns %edi,%eax
    }

}
  80104a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104d:	5b                   	pop    %ebx
  80104e:	5e                   	pop    %esi
  80104f:	5f                   	pop    %edi
  801050:	5d                   	pop    %ebp
  801051:	c3                   	ret    

00801052 <sfork>:

// Challenge!
int
sfork(void)
{
  801052:	f3 0f 1e fb          	endbr32 
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80105c:	68 ac 26 80 00       	push   $0x8026ac
  801061:	68 a5 00 00 00       	push   $0xa5
  801066:	68 23 26 80 00       	push   $0x802623
  80106b:	e8 45 0d 00 00       	call   801db5 <_panic>

00801070 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801070:	f3 0f 1e fb          	endbr32 
  801074:	55                   	push   %ebp
  801075:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801077:	8b 45 08             	mov    0x8(%ebp),%eax
  80107a:	05 00 00 00 30       	add    $0x30000000,%eax
  80107f:	c1 e8 0c             	shr    $0xc,%eax
}
  801082:	5d                   	pop    %ebp
  801083:	c3                   	ret    

00801084 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801084:	f3 0f 1e fb          	endbr32 
  801088:	55                   	push   %ebp
  801089:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80108b:	8b 45 08             	mov    0x8(%ebp),%eax
  80108e:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801093:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801098:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80109d:	5d                   	pop    %ebp
  80109e:	c3                   	ret    

0080109f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80109f:	f3 0f 1e fb          	endbr32 
  8010a3:	55                   	push   %ebp
  8010a4:	89 e5                	mov    %esp,%ebp
  8010a6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010ab:	89 c2                	mov    %eax,%edx
  8010ad:	c1 ea 16             	shr    $0x16,%edx
  8010b0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010b7:	f6 c2 01             	test   $0x1,%dl
  8010ba:	74 2d                	je     8010e9 <fd_alloc+0x4a>
  8010bc:	89 c2                	mov    %eax,%edx
  8010be:	c1 ea 0c             	shr    $0xc,%edx
  8010c1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010c8:	f6 c2 01             	test   $0x1,%dl
  8010cb:	74 1c                	je     8010e9 <fd_alloc+0x4a>
  8010cd:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8010d2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010d7:	75 d2                	jne    8010ab <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010dc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8010e2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8010e7:	eb 0a                	jmp    8010f3 <fd_alloc+0x54>
			*fd_store = fd;
  8010e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ec:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010f3:	5d                   	pop    %ebp
  8010f4:	c3                   	ret    

008010f5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010f5:	f3 0f 1e fb          	endbr32 
  8010f9:	55                   	push   %ebp
  8010fa:	89 e5                	mov    %esp,%ebp
  8010fc:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010ff:	83 f8 1f             	cmp    $0x1f,%eax
  801102:	77 30                	ja     801134 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801104:	c1 e0 0c             	shl    $0xc,%eax
  801107:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80110c:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801112:	f6 c2 01             	test   $0x1,%dl
  801115:	74 24                	je     80113b <fd_lookup+0x46>
  801117:	89 c2                	mov    %eax,%edx
  801119:	c1 ea 0c             	shr    $0xc,%edx
  80111c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801123:	f6 c2 01             	test   $0x1,%dl
  801126:	74 1a                	je     801142 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801128:	8b 55 0c             	mov    0xc(%ebp),%edx
  80112b:	89 02                	mov    %eax,(%edx)
	return 0;
  80112d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801132:	5d                   	pop    %ebp
  801133:	c3                   	ret    
		return -E_INVAL;
  801134:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801139:	eb f7                	jmp    801132 <fd_lookup+0x3d>
		return -E_INVAL;
  80113b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801140:	eb f0                	jmp    801132 <fd_lookup+0x3d>
  801142:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801147:	eb e9                	jmp    801132 <fd_lookup+0x3d>

00801149 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801149:	f3 0f 1e fb          	endbr32 
  80114d:	55                   	push   %ebp
  80114e:	89 e5                	mov    %esp,%ebp
  801150:	83 ec 08             	sub    $0x8,%esp
  801153:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801156:	ba 60 27 80 00       	mov    $0x802760,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80115b:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  801160:	39 08                	cmp    %ecx,(%eax)
  801162:	74 33                	je     801197 <dev_lookup+0x4e>
  801164:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801167:	8b 02                	mov    (%edx),%eax
  801169:	85 c0                	test   %eax,%eax
  80116b:	75 f3                	jne    801160 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80116d:	a1 04 40 80 00       	mov    0x804004,%eax
  801172:	8b 40 48             	mov    0x48(%eax),%eax
  801175:	83 ec 04             	sub    $0x4,%esp
  801178:	51                   	push   %ecx
  801179:	50                   	push   %eax
  80117a:	68 e4 26 80 00       	push   $0x8026e4
  80117f:	e8 44 f0 ff ff       	call   8001c8 <cprintf>
	*dev = 0;
  801184:	8b 45 0c             	mov    0xc(%ebp),%eax
  801187:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80118d:	83 c4 10             	add    $0x10,%esp
  801190:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801195:	c9                   	leave  
  801196:	c3                   	ret    
			*dev = devtab[i];
  801197:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80119a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80119c:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a1:	eb f2                	jmp    801195 <dev_lookup+0x4c>

008011a3 <fd_close>:
{
  8011a3:	f3 0f 1e fb          	endbr32 
  8011a7:	55                   	push   %ebp
  8011a8:	89 e5                	mov    %esp,%ebp
  8011aa:	57                   	push   %edi
  8011ab:	56                   	push   %esi
  8011ac:	53                   	push   %ebx
  8011ad:	83 ec 24             	sub    $0x24,%esp
  8011b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8011b3:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011b6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011b9:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011ba:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011c0:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011c3:	50                   	push   %eax
  8011c4:	e8 2c ff ff ff       	call   8010f5 <fd_lookup>
  8011c9:	89 c3                	mov    %eax,%ebx
  8011cb:	83 c4 10             	add    $0x10,%esp
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	78 05                	js     8011d7 <fd_close+0x34>
	    || fd != fd2)
  8011d2:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8011d5:	74 16                	je     8011ed <fd_close+0x4a>
		return (must_exist ? r : 0);
  8011d7:	89 f8                	mov    %edi,%eax
  8011d9:	84 c0                	test   %al,%al
  8011db:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e0:	0f 44 d8             	cmove  %eax,%ebx
}
  8011e3:	89 d8                	mov    %ebx,%eax
  8011e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e8:	5b                   	pop    %ebx
  8011e9:	5e                   	pop    %esi
  8011ea:	5f                   	pop    %edi
  8011eb:	5d                   	pop    %ebp
  8011ec:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011ed:	83 ec 08             	sub    $0x8,%esp
  8011f0:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8011f3:	50                   	push   %eax
  8011f4:	ff 36                	pushl  (%esi)
  8011f6:	e8 4e ff ff ff       	call   801149 <dev_lookup>
  8011fb:	89 c3                	mov    %eax,%ebx
  8011fd:	83 c4 10             	add    $0x10,%esp
  801200:	85 c0                	test   %eax,%eax
  801202:	78 1a                	js     80121e <fd_close+0x7b>
		if (dev->dev_close)
  801204:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801207:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80120a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80120f:	85 c0                	test   %eax,%eax
  801211:	74 0b                	je     80121e <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  801213:	83 ec 0c             	sub    $0xc,%esp
  801216:	56                   	push   %esi
  801217:	ff d0                	call   *%eax
  801219:	89 c3                	mov    %eax,%ebx
  80121b:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80121e:	83 ec 08             	sub    $0x8,%esp
  801221:	56                   	push   %esi
  801222:	6a 00                	push   $0x0
  801224:	e8 77 fa ff ff       	call   800ca0 <sys_page_unmap>
	return r;
  801229:	83 c4 10             	add    $0x10,%esp
  80122c:	eb b5                	jmp    8011e3 <fd_close+0x40>

0080122e <close>:

int
close(int fdnum)
{
  80122e:	f3 0f 1e fb          	endbr32 
  801232:	55                   	push   %ebp
  801233:	89 e5                	mov    %esp,%ebp
  801235:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801238:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80123b:	50                   	push   %eax
  80123c:	ff 75 08             	pushl  0x8(%ebp)
  80123f:	e8 b1 fe ff ff       	call   8010f5 <fd_lookup>
  801244:	83 c4 10             	add    $0x10,%esp
  801247:	85 c0                	test   %eax,%eax
  801249:	79 02                	jns    80124d <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  80124b:	c9                   	leave  
  80124c:	c3                   	ret    
		return fd_close(fd, 1);
  80124d:	83 ec 08             	sub    $0x8,%esp
  801250:	6a 01                	push   $0x1
  801252:	ff 75 f4             	pushl  -0xc(%ebp)
  801255:	e8 49 ff ff ff       	call   8011a3 <fd_close>
  80125a:	83 c4 10             	add    $0x10,%esp
  80125d:	eb ec                	jmp    80124b <close+0x1d>

0080125f <close_all>:

void
close_all(void)
{
  80125f:	f3 0f 1e fb          	endbr32 
  801263:	55                   	push   %ebp
  801264:	89 e5                	mov    %esp,%ebp
  801266:	53                   	push   %ebx
  801267:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80126a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80126f:	83 ec 0c             	sub    $0xc,%esp
  801272:	53                   	push   %ebx
  801273:	e8 b6 ff ff ff       	call   80122e <close>
	for (i = 0; i < MAXFD; i++)
  801278:	83 c3 01             	add    $0x1,%ebx
  80127b:	83 c4 10             	add    $0x10,%esp
  80127e:	83 fb 20             	cmp    $0x20,%ebx
  801281:	75 ec                	jne    80126f <close_all+0x10>
}
  801283:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801286:	c9                   	leave  
  801287:	c3                   	ret    

00801288 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801288:	f3 0f 1e fb          	endbr32 
  80128c:	55                   	push   %ebp
  80128d:	89 e5                	mov    %esp,%ebp
  80128f:	57                   	push   %edi
  801290:	56                   	push   %esi
  801291:	53                   	push   %ebx
  801292:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801295:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801298:	50                   	push   %eax
  801299:	ff 75 08             	pushl  0x8(%ebp)
  80129c:	e8 54 fe ff ff       	call   8010f5 <fd_lookup>
  8012a1:	89 c3                	mov    %eax,%ebx
  8012a3:	83 c4 10             	add    $0x10,%esp
  8012a6:	85 c0                	test   %eax,%eax
  8012a8:	0f 88 81 00 00 00    	js     80132f <dup+0xa7>
		return r;
	close(newfdnum);
  8012ae:	83 ec 0c             	sub    $0xc,%esp
  8012b1:	ff 75 0c             	pushl  0xc(%ebp)
  8012b4:	e8 75 ff ff ff       	call   80122e <close>

	newfd = INDEX2FD(newfdnum);
  8012b9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012bc:	c1 e6 0c             	shl    $0xc,%esi
  8012bf:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8012c5:	83 c4 04             	add    $0x4,%esp
  8012c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012cb:	e8 b4 fd ff ff       	call   801084 <fd2data>
  8012d0:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8012d2:	89 34 24             	mov    %esi,(%esp)
  8012d5:	e8 aa fd ff ff       	call   801084 <fd2data>
  8012da:	83 c4 10             	add    $0x10,%esp
  8012dd:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012df:	89 d8                	mov    %ebx,%eax
  8012e1:	c1 e8 16             	shr    $0x16,%eax
  8012e4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012eb:	a8 01                	test   $0x1,%al
  8012ed:	74 11                	je     801300 <dup+0x78>
  8012ef:	89 d8                	mov    %ebx,%eax
  8012f1:	c1 e8 0c             	shr    $0xc,%eax
  8012f4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012fb:	f6 c2 01             	test   $0x1,%dl
  8012fe:	75 39                	jne    801339 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801300:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801303:	89 d0                	mov    %edx,%eax
  801305:	c1 e8 0c             	shr    $0xc,%eax
  801308:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80130f:	83 ec 0c             	sub    $0xc,%esp
  801312:	25 07 0e 00 00       	and    $0xe07,%eax
  801317:	50                   	push   %eax
  801318:	56                   	push   %esi
  801319:	6a 00                	push   $0x0
  80131b:	52                   	push   %edx
  80131c:	6a 00                	push   $0x0
  80131e:	e8 37 f9 ff ff       	call   800c5a <sys_page_map>
  801323:	89 c3                	mov    %eax,%ebx
  801325:	83 c4 20             	add    $0x20,%esp
  801328:	85 c0                	test   %eax,%eax
  80132a:	78 31                	js     80135d <dup+0xd5>
		goto err;

	return newfdnum;
  80132c:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80132f:	89 d8                	mov    %ebx,%eax
  801331:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801334:	5b                   	pop    %ebx
  801335:	5e                   	pop    %esi
  801336:	5f                   	pop    %edi
  801337:	5d                   	pop    %ebp
  801338:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801339:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801340:	83 ec 0c             	sub    $0xc,%esp
  801343:	25 07 0e 00 00       	and    $0xe07,%eax
  801348:	50                   	push   %eax
  801349:	57                   	push   %edi
  80134a:	6a 00                	push   $0x0
  80134c:	53                   	push   %ebx
  80134d:	6a 00                	push   $0x0
  80134f:	e8 06 f9 ff ff       	call   800c5a <sys_page_map>
  801354:	89 c3                	mov    %eax,%ebx
  801356:	83 c4 20             	add    $0x20,%esp
  801359:	85 c0                	test   %eax,%eax
  80135b:	79 a3                	jns    801300 <dup+0x78>
	sys_page_unmap(0, newfd);
  80135d:	83 ec 08             	sub    $0x8,%esp
  801360:	56                   	push   %esi
  801361:	6a 00                	push   $0x0
  801363:	e8 38 f9 ff ff       	call   800ca0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801368:	83 c4 08             	add    $0x8,%esp
  80136b:	57                   	push   %edi
  80136c:	6a 00                	push   $0x0
  80136e:	e8 2d f9 ff ff       	call   800ca0 <sys_page_unmap>
	return r;
  801373:	83 c4 10             	add    $0x10,%esp
  801376:	eb b7                	jmp    80132f <dup+0xa7>

00801378 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801378:	f3 0f 1e fb          	endbr32 
  80137c:	55                   	push   %ebp
  80137d:	89 e5                	mov    %esp,%ebp
  80137f:	53                   	push   %ebx
  801380:	83 ec 1c             	sub    $0x1c,%esp
  801383:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801386:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801389:	50                   	push   %eax
  80138a:	53                   	push   %ebx
  80138b:	e8 65 fd ff ff       	call   8010f5 <fd_lookup>
  801390:	83 c4 10             	add    $0x10,%esp
  801393:	85 c0                	test   %eax,%eax
  801395:	78 3f                	js     8013d6 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801397:	83 ec 08             	sub    $0x8,%esp
  80139a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80139d:	50                   	push   %eax
  80139e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a1:	ff 30                	pushl  (%eax)
  8013a3:	e8 a1 fd ff ff       	call   801149 <dev_lookup>
  8013a8:	83 c4 10             	add    $0x10,%esp
  8013ab:	85 c0                	test   %eax,%eax
  8013ad:	78 27                	js     8013d6 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013af:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013b2:	8b 42 08             	mov    0x8(%edx),%eax
  8013b5:	83 e0 03             	and    $0x3,%eax
  8013b8:	83 f8 01             	cmp    $0x1,%eax
  8013bb:	74 1e                	je     8013db <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8013bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c0:	8b 40 08             	mov    0x8(%eax),%eax
  8013c3:	85 c0                	test   %eax,%eax
  8013c5:	74 35                	je     8013fc <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013c7:	83 ec 04             	sub    $0x4,%esp
  8013ca:	ff 75 10             	pushl  0x10(%ebp)
  8013cd:	ff 75 0c             	pushl  0xc(%ebp)
  8013d0:	52                   	push   %edx
  8013d1:	ff d0                	call   *%eax
  8013d3:	83 c4 10             	add    $0x10,%esp
}
  8013d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d9:	c9                   	leave  
  8013da:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013db:	a1 04 40 80 00       	mov    0x804004,%eax
  8013e0:	8b 40 48             	mov    0x48(%eax),%eax
  8013e3:	83 ec 04             	sub    $0x4,%esp
  8013e6:	53                   	push   %ebx
  8013e7:	50                   	push   %eax
  8013e8:	68 25 27 80 00       	push   $0x802725
  8013ed:	e8 d6 ed ff ff       	call   8001c8 <cprintf>
		return -E_INVAL;
  8013f2:	83 c4 10             	add    $0x10,%esp
  8013f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013fa:	eb da                	jmp    8013d6 <read+0x5e>
		return -E_NOT_SUPP;
  8013fc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801401:	eb d3                	jmp    8013d6 <read+0x5e>

00801403 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801403:	f3 0f 1e fb          	endbr32 
  801407:	55                   	push   %ebp
  801408:	89 e5                	mov    %esp,%ebp
  80140a:	57                   	push   %edi
  80140b:	56                   	push   %esi
  80140c:	53                   	push   %ebx
  80140d:	83 ec 0c             	sub    $0xc,%esp
  801410:	8b 7d 08             	mov    0x8(%ebp),%edi
  801413:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801416:	bb 00 00 00 00       	mov    $0x0,%ebx
  80141b:	eb 02                	jmp    80141f <readn+0x1c>
  80141d:	01 c3                	add    %eax,%ebx
  80141f:	39 f3                	cmp    %esi,%ebx
  801421:	73 21                	jae    801444 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801423:	83 ec 04             	sub    $0x4,%esp
  801426:	89 f0                	mov    %esi,%eax
  801428:	29 d8                	sub    %ebx,%eax
  80142a:	50                   	push   %eax
  80142b:	89 d8                	mov    %ebx,%eax
  80142d:	03 45 0c             	add    0xc(%ebp),%eax
  801430:	50                   	push   %eax
  801431:	57                   	push   %edi
  801432:	e8 41 ff ff ff       	call   801378 <read>
		if (m < 0)
  801437:	83 c4 10             	add    $0x10,%esp
  80143a:	85 c0                	test   %eax,%eax
  80143c:	78 04                	js     801442 <readn+0x3f>
			return m;
		if (m == 0)
  80143e:	75 dd                	jne    80141d <readn+0x1a>
  801440:	eb 02                	jmp    801444 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801442:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801444:	89 d8                	mov    %ebx,%eax
  801446:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801449:	5b                   	pop    %ebx
  80144a:	5e                   	pop    %esi
  80144b:	5f                   	pop    %edi
  80144c:	5d                   	pop    %ebp
  80144d:	c3                   	ret    

0080144e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80144e:	f3 0f 1e fb          	endbr32 
  801452:	55                   	push   %ebp
  801453:	89 e5                	mov    %esp,%ebp
  801455:	53                   	push   %ebx
  801456:	83 ec 1c             	sub    $0x1c,%esp
  801459:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80145c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80145f:	50                   	push   %eax
  801460:	53                   	push   %ebx
  801461:	e8 8f fc ff ff       	call   8010f5 <fd_lookup>
  801466:	83 c4 10             	add    $0x10,%esp
  801469:	85 c0                	test   %eax,%eax
  80146b:	78 3a                	js     8014a7 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80146d:	83 ec 08             	sub    $0x8,%esp
  801470:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801473:	50                   	push   %eax
  801474:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801477:	ff 30                	pushl  (%eax)
  801479:	e8 cb fc ff ff       	call   801149 <dev_lookup>
  80147e:	83 c4 10             	add    $0x10,%esp
  801481:	85 c0                	test   %eax,%eax
  801483:	78 22                	js     8014a7 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801485:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801488:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80148c:	74 1e                	je     8014ac <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80148e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801491:	8b 52 0c             	mov    0xc(%edx),%edx
  801494:	85 d2                	test   %edx,%edx
  801496:	74 35                	je     8014cd <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801498:	83 ec 04             	sub    $0x4,%esp
  80149b:	ff 75 10             	pushl  0x10(%ebp)
  80149e:	ff 75 0c             	pushl  0xc(%ebp)
  8014a1:	50                   	push   %eax
  8014a2:	ff d2                	call   *%edx
  8014a4:	83 c4 10             	add    $0x10,%esp
}
  8014a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014aa:	c9                   	leave  
  8014ab:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014ac:	a1 04 40 80 00       	mov    0x804004,%eax
  8014b1:	8b 40 48             	mov    0x48(%eax),%eax
  8014b4:	83 ec 04             	sub    $0x4,%esp
  8014b7:	53                   	push   %ebx
  8014b8:	50                   	push   %eax
  8014b9:	68 41 27 80 00       	push   $0x802741
  8014be:	e8 05 ed ff ff       	call   8001c8 <cprintf>
		return -E_INVAL;
  8014c3:	83 c4 10             	add    $0x10,%esp
  8014c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014cb:	eb da                	jmp    8014a7 <write+0x59>
		return -E_NOT_SUPP;
  8014cd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014d2:	eb d3                	jmp    8014a7 <write+0x59>

008014d4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014d4:	f3 0f 1e fb          	endbr32 
  8014d8:	55                   	push   %ebp
  8014d9:	89 e5                	mov    %esp,%ebp
  8014db:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e1:	50                   	push   %eax
  8014e2:	ff 75 08             	pushl  0x8(%ebp)
  8014e5:	e8 0b fc ff ff       	call   8010f5 <fd_lookup>
  8014ea:	83 c4 10             	add    $0x10,%esp
  8014ed:	85 c0                	test   %eax,%eax
  8014ef:	78 0e                	js     8014ff <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8014f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014f7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014ff:	c9                   	leave  
  801500:	c3                   	ret    

00801501 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801501:	f3 0f 1e fb          	endbr32 
  801505:	55                   	push   %ebp
  801506:	89 e5                	mov    %esp,%ebp
  801508:	53                   	push   %ebx
  801509:	83 ec 1c             	sub    $0x1c,%esp
  80150c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80150f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801512:	50                   	push   %eax
  801513:	53                   	push   %ebx
  801514:	e8 dc fb ff ff       	call   8010f5 <fd_lookup>
  801519:	83 c4 10             	add    $0x10,%esp
  80151c:	85 c0                	test   %eax,%eax
  80151e:	78 37                	js     801557 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801520:	83 ec 08             	sub    $0x8,%esp
  801523:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801526:	50                   	push   %eax
  801527:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152a:	ff 30                	pushl  (%eax)
  80152c:	e8 18 fc ff ff       	call   801149 <dev_lookup>
  801531:	83 c4 10             	add    $0x10,%esp
  801534:	85 c0                	test   %eax,%eax
  801536:	78 1f                	js     801557 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801538:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80153f:	74 1b                	je     80155c <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801541:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801544:	8b 52 18             	mov    0x18(%edx),%edx
  801547:	85 d2                	test   %edx,%edx
  801549:	74 32                	je     80157d <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80154b:	83 ec 08             	sub    $0x8,%esp
  80154e:	ff 75 0c             	pushl  0xc(%ebp)
  801551:	50                   	push   %eax
  801552:	ff d2                	call   *%edx
  801554:	83 c4 10             	add    $0x10,%esp
}
  801557:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80155a:	c9                   	leave  
  80155b:	c3                   	ret    
			thisenv->env_id, fdnum);
  80155c:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801561:	8b 40 48             	mov    0x48(%eax),%eax
  801564:	83 ec 04             	sub    $0x4,%esp
  801567:	53                   	push   %ebx
  801568:	50                   	push   %eax
  801569:	68 04 27 80 00       	push   $0x802704
  80156e:	e8 55 ec ff ff       	call   8001c8 <cprintf>
		return -E_INVAL;
  801573:	83 c4 10             	add    $0x10,%esp
  801576:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80157b:	eb da                	jmp    801557 <ftruncate+0x56>
		return -E_NOT_SUPP;
  80157d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801582:	eb d3                	jmp    801557 <ftruncate+0x56>

00801584 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801584:	f3 0f 1e fb          	endbr32 
  801588:	55                   	push   %ebp
  801589:	89 e5                	mov    %esp,%ebp
  80158b:	53                   	push   %ebx
  80158c:	83 ec 1c             	sub    $0x1c,%esp
  80158f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801592:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801595:	50                   	push   %eax
  801596:	ff 75 08             	pushl  0x8(%ebp)
  801599:	e8 57 fb ff ff       	call   8010f5 <fd_lookup>
  80159e:	83 c4 10             	add    $0x10,%esp
  8015a1:	85 c0                	test   %eax,%eax
  8015a3:	78 4b                	js     8015f0 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a5:	83 ec 08             	sub    $0x8,%esp
  8015a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ab:	50                   	push   %eax
  8015ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015af:	ff 30                	pushl  (%eax)
  8015b1:	e8 93 fb ff ff       	call   801149 <dev_lookup>
  8015b6:	83 c4 10             	add    $0x10,%esp
  8015b9:	85 c0                	test   %eax,%eax
  8015bb:	78 33                	js     8015f0 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8015bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015c0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015c4:	74 2f                	je     8015f5 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015c6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015c9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015d0:	00 00 00 
	stat->st_isdir = 0;
  8015d3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015da:	00 00 00 
	stat->st_dev = dev;
  8015dd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015e3:	83 ec 08             	sub    $0x8,%esp
  8015e6:	53                   	push   %ebx
  8015e7:	ff 75 f0             	pushl  -0x10(%ebp)
  8015ea:	ff 50 14             	call   *0x14(%eax)
  8015ed:	83 c4 10             	add    $0x10,%esp
}
  8015f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f3:	c9                   	leave  
  8015f4:	c3                   	ret    
		return -E_NOT_SUPP;
  8015f5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015fa:	eb f4                	jmp    8015f0 <fstat+0x6c>

008015fc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015fc:	f3 0f 1e fb          	endbr32 
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
  801603:	56                   	push   %esi
  801604:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801605:	83 ec 08             	sub    $0x8,%esp
  801608:	6a 00                	push   $0x0
  80160a:	ff 75 08             	pushl  0x8(%ebp)
  80160d:	e8 fb 01 00 00       	call   80180d <open>
  801612:	89 c3                	mov    %eax,%ebx
  801614:	83 c4 10             	add    $0x10,%esp
  801617:	85 c0                	test   %eax,%eax
  801619:	78 1b                	js     801636 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  80161b:	83 ec 08             	sub    $0x8,%esp
  80161e:	ff 75 0c             	pushl  0xc(%ebp)
  801621:	50                   	push   %eax
  801622:	e8 5d ff ff ff       	call   801584 <fstat>
  801627:	89 c6                	mov    %eax,%esi
	close(fd);
  801629:	89 1c 24             	mov    %ebx,(%esp)
  80162c:	e8 fd fb ff ff       	call   80122e <close>
	return r;
  801631:	83 c4 10             	add    $0x10,%esp
  801634:	89 f3                	mov    %esi,%ebx
}
  801636:	89 d8                	mov    %ebx,%eax
  801638:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80163b:	5b                   	pop    %ebx
  80163c:	5e                   	pop    %esi
  80163d:	5d                   	pop    %ebp
  80163e:	c3                   	ret    

0080163f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	56                   	push   %esi
  801643:	53                   	push   %ebx
  801644:	89 c6                	mov    %eax,%esi
  801646:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801648:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80164f:	74 27                	je     801678 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801651:	6a 07                	push   $0x7
  801653:	68 00 50 80 00       	push   $0x805000
  801658:	56                   	push   %esi
  801659:	ff 35 00 40 80 00    	pushl  0x804000
  80165f:	e8 98 08 00 00       	call   801efc <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801664:	83 c4 0c             	add    $0xc,%esp
  801667:	6a 00                	push   $0x0
  801669:	53                   	push   %ebx
  80166a:	6a 00                	push   $0x0
  80166c:	e8 34 08 00 00       	call   801ea5 <ipc_recv>
}
  801671:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801674:	5b                   	pop    %ebx
  801675:	5e                   	pop    %esi
  801676:	5d                   	pop    %ebp
  801677:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801678:	83 ec 0c             	sub    $0xc,%esp
  80167b:	6a 01                	push   $0x1
  80167d:	e8 e0 08 00 00       	call   801f62 <ipc_find_env>
  801682:	a3 00 40 80 00       	mov    %eax,0x804000
  801687:	83 c4 10             	add    $0x10,%esp
  80168a:	eb c5                	jmp    801651 <fsipc+0x12>

0080168c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80168c:	f3 0f 1e fb          	endbr32 
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801696:	8b 45 08             	mov    0x8(%ebp),%eax
  801699:	8b 40 0c             	mov    0xc(%eax),%eax
  80169c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016a4:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ae:	b8 02 00 00 00       	mov    $0x2,%eax
  8016b3:	e8 87 ff ff ff       	call   80163f <fsipc>
}
  8016b8:	c9                   	leave  
  8016b9:	c3                   	ret    

008016ba <devfile_flush>:
{
  8016ba:	f3 0f 1e fb          	endbr32 
  8016be:	55                   	push   %ebp
  8016bf:	89 e5                	mov    %esp,%ebp
  8016c1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c7:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ca:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d4:	b8 06 00 00 00       	mov    $0x6,%eax
  8016d9:	e8 61 ff ff ff       	call   80163f <fsipc>
}
  8016de:	c9                   	leave  
  8016df:	c3                   	ret    

008016e0 <devfile_stat>:
{
  8016e0:	f3 0f 1e fb          	endbr32 
  8016e4:	55                   	push   %ebp
  8016e5:	89 e5                	mov    %esp,%ebp
  8016e7:	53                   	push   %ebx
  8016e8:	83 ec 04             	sub    $0x4,%esp
  8016eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f1:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f4:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016fe:	b8 05 00 00 00       	mov    $0x5,%eax
  801703:	e8 37 ff ff ff       	call   80163f <fsipc>
  801708:	85 c0                	test   %eax,%eax
  80170a:	78 2c                	js     801738 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80170c:	83 ec 08             	sub    $0x8,%esp
  80170f:	68 00 50 80 00       	push   $0x805000
  801714:	53                   	push   %ebx
  801715:	e8 b7 f0 ff ff       	call   8007d1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80171a:	a1 80 50 80 00       	mov    0x805080,%eax
  80171f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801725:	a1 84 50 80 00       	mov    0x805084,%eax
  80172a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801730:	83 c4 10             	add    $0x10,%esp
  801733:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801738:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80173b:	c9                   	leave  
  80173c:	c3                   	ret    

0080173d <devfile_write>:
{
  80173d:	f3 0f 1e fb          	endbr32 
  801741:	55                   	push   %ebp
  801742:	89 e5                	mov    %esp,%ebp
  801744:	83 ec 0c             	sub    $0xc,%esp
  801747:	8b 45 10             	mov    0x10(%ebp),%eax
	n = n > size_max ? size_max : n;
  80174a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80174f:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801754:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801757:	8b 55 08             	mov    0x8(%ebp),%edx
  80175a:	8b 52 0c             	mov    0xc(%edx),%edx
  80175d:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801763:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801768:	50                   	push   %eax
  801769:	ff 75 0c             	pushl  0xc(%ebp)
  80176c:	68 08 50 80 00       	push   $0x805008
  801771:	e8 11 f2 ff ff       	call   800987 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801776:	ba 00 00 00 00       	mov    $0x0,%edx
  80177b:	b8 04 00 00 00       	mov    $0x4,%eax
  801780:	e8 ba fe ff ff       	call   80163f <fsipc>
}
  801785:	c9                   	leave  
  801786:	c3                   	ret    

00801787 <devfile_read>:
{
  801787:	f3 0f 1e fb          	endbr32 
  80178b:	55                   	push   %ebp
  80178c:	89 e5                	mov    %esp,%ebp
  80178e:	56                   	push   %esi
  80178f:	53                   	push   %ebx
  801790:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801793:	8b 45 08             	mov    0x8(%ebp),%eax
  801796:	8b 40 0c             	mov    0xc(%eax),%eax
  801799:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80179e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a9:	b8 03 00 00 00       	mov    $0x3,%eax
  8017ae:	e8 8c fe ff ff       	call   80163f <fsipc>
  8017b3:	89 c3                	mov    %eax,%ebx
  8017b5:	85 c0                	test   %eax,%eax
  8017b7:	78 1f                	js     8017d8 <devfile_read+0x51>
	assert(r <= n);
  8017b9:	39 f0                	cmp    %esi,%eax
  8017bb:	77 24                	ja     8017e1 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8017bd:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017c2:	7f 33                	jg     8017f7 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017c4:	83 ec 04             	sub    $0x4,%esp
  8017c7:	50                   	push   %eax
  8017c8:	68 00 50 80 00       	push   $0x805000
  8017cd:	ff 75 0c             	pushl  0xc(%ebp)
  8017d0:	e8 b2 f1 ff ff       	call   800987 <memmove>
	return r;
  8017d5:	83 c4 10             	add    $0x10,%esp
}
  8017d8:	89 d8                	mov    %ebx,%eax
  8017da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017dd:	5b                   	pop    %ebx
  8017de:	5e                   	pop    %esi
  8017df:	5d                   	pop    %ebp
  8017e0:	c3                   	ret    
	assert(r <= n);
  8017e1:	68 70 27 80 00       	push   $0x802770
  8017e6:	68 77 27 80 00       	push   $0x802777
  8017eb:	6a 7c                	push   $0x7c
  8017ed:	68 8c 27 80 00       	push   $0x80278c
  8017f2:	e8 be 05 00 00       	call   801db5 <_panic>
	assert(r <= PGSIZE);
  8017f7:	68 97 27 80 00       	push   $0x802797
  8017fc:	68 77 27 80 00       	push   $0x802777
  801801:	6a 7d                	push   $0x7d
  801803:	68 8c 27 80 00       	push   $0x80278c
  801808:	e8 a8 05 00 00       	call   801db5 <_panic>

0080180d <open>:
{
  80180d:	f3 0f 1e fb          	endbr32 
  801811:	55                   	push   %ebp
  801812:	89 e5                	mov    %esp,%ebp
  801814:	56                   	push   %esi
  801815:	53                   	push   %ebx
  801816:	83 ec 1c             	sub    $0x1c,%esp
  801819:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80181c:	56                   	push   %esi
  80181d:	e8 6c ef ff ff       	call   80078e <strlen>
  801822:	83 c4 10             	add    $0x10,%esp
  801825:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80182a:	7f 6c                	jg     801898 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  80182c:	83 ec 0c             	sub    $0xc,%esp
  80182f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801832:	50                   	push   %eax
  801833:	e8 67 f8 ff ff       	call   80109f <fd_alloc>
  801838:	89 c3                	mov    %eax,%ebx
  80183a:	83 c4 10             	add    $0x10,%esp
  80183d:	85 c0                	test   %eax,%eax
  80183f:	78 3c                	js     80187d <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801841:	83 ec 08             	sub    $0x8,%esp
  801844:	56                   	push   %esi
  801845:	68 00 50 80 00       	push   $0x805000
  80184a:	e8 82 ef ff ff       	call   8007d1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80184f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801852:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801857:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80185a:	b8 01 00 00 00       	mov    $0x1,%eax
  80185f:	e8 db fd ff ff       	call   80163f <fsipc>
  801864:	89 c3                	mov    %eax,%ebx
  801866:	83 c4 10             	add    $0x10,%esp
  801869:	85 c0                	test   %eax,%eax
  80186b:	78 19                	js     801886 <open+0x79>
	return fd2num(fd);
  80186d:	83 ec 0c             	sub    $0xc,%esp
  801870:	ff 75 f4             	pushl  -0xc(%ebp)
  801873:	e8 f8 f7 ff ff       	call   801070 <fd2num>
  801878:	89 c3                	mov    %eax,%ebx
  80187a:	83 c4 10             	add    $0x10,%esp
}
  80187d:	89 d8                	mov    %ebx,%eax
  80187f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801882:	5b                   	pop    %ebx
  801883:	5e                   	pop    %esi
  801884:	5d                   	pop    %ebp
  801885:	c3                   	ret    
		fd_close(fd, 0);
  801886:	83 ec 08             	sub    $0x8,%esp
  801889:	6a 00                	push   $0x0
  80188b:	ff 75 f4             	pushl  -0xc(%ebp)
  80188e:	e8 10 f9 ff ff       	call   8011a3 <fd_close>
		return r;
  801893:	83 c4 10             	add    $0x10,%esp
  801896:	eb e5                	jmp    80187d <open+0x70>
		return -E_BAD_PATH;
  801898:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80189d:	eb de                	jmp    80187d <open+0x70>

0080189f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80189f:	f3 0f 1e fb          	endbr32 
  8018a3:	55                   	push   %ebp
  8018a4:	89 e5                	mov    %esp,%ebp
  8018a6:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ae:	b8 08 00 00 00       	mov    $0x8,%eax
  8018b3:	e8 87 fd ff ff       	call   80163f <fsipc>
}
  8018b8:	c9                   	leave  
  8018b9:	c3                   	ret    

008018ba <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018ba:	f3 0f 1e fb          	endbr32 
  8018be:	55                   	push   %ebp
  8018bf:	89 e5                	mov    %esp,%ebp
  8018c1:	56                   	push   %esi
  8018c2:	53                   	push   %ebx
  8018c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018c6:	83 ec 0c             	sub    $0xc,%esp
  8018c9:	ff 75 08             	pushl  0x8(%ebp)
  8018cc:	e8 b3 f7 ff ff       	call   801084 <fd2data>
  8018d1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018d3:	83 c4 08             	add    $0x8,%esp
  8018d6:	68 a3 27 80 00       	push   $0x8027a3
  8018db:	53                   	push   %ebx
  8018dc:	e8 f0 ee ff ff       	call   8007d1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018e1:	8b 46 04             	mov    0x4(%esi),%eax
  8018e4:	2b 06                	sub    (%esi),%eax
  8018e6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018ec:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018f3:	00 00 00 
	stat->st_dev = &devpipe;
  8018f6:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018fd:	30 80 00 
	return 0;
}
  801900:	b8 00 00 00 00       	mov    $0x0,%eax
  801905:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801908:	5b                   	pop    %ebx
  801909:	5e                   	pop    %esi
  80190a:	5d                   	pop    %ebp
  80190b:	c3                   	ret    

0080190c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80190c:	f3 0f 1e fb          	endbr32 
  801910:	55                   	push   %ebp
  801911:	89 e5                	mov    %esp,%ebp
  801913:	53                   	push   %ebx
  801914:	83 ec 0c             	sub    $0xc,%esp
  801917:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80191a:	53                   	push   %ebx
  80191b:	6a 00                	push   $0x0
  80191d:	e8 7e f3 ff ff       	call   800ca0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801922:	89 1c 24             	mov    %ebx,(%esp)
  801925:	e8 5a f7 ff ff       	call   801084 <fd2data>
  80192a:	83 c4 08             	add    $0x8,%esp
  80192d:	50                   	push   %eax
  80192e:	6a 00                	push   $0x0
  801930:	e8 6b f3 ff ff       	call   800ca0 <sys_page_unmap>
}
  801935:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801938:	c9                   	leave  
  801939:	c3                   	ret    

0080193a <_pipeisclosed>:
{
  80193a:	55                   	push   %ebp
  80193b:	89 e5                	mov    %esp,%ebp
  80193d:	57                   	push   %edi
  80193e:	56                   	push   %esi
  80193f:	53                   	push   %ebx
  801940:	83 ec 1c             	sub    $0x1c,%esp
  801943:	89 c7                	mov    %eax,%edi
  801945:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801947:	a1 04 40 80 00       	mov    0x804004,%eax
  80194c:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80194f:	83 ec 0c             	sub    $0xc,%esp
  801952:	57                   	push   %edi
  801953:	e8 47 06 00 00       	call   801f9f <pageref>
  801958:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80195b:	89 34 24             	mov    %esi,(%esp)
  80195e:	e8 3c 06 00 00       	call   801f9f <pageref>
		nn = thisenv->env_runs;
  801963:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801969:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80196c:	83 c4 10             	add    $0x10,%esp
  80196f:	39 cb                	cmp    %ecx,%ebx
  801971:	74 1b                	je     80198e <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801973:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801976:	75 cf                	jne    801947 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801978:	8b 42 58             	mov    0x58(%edx),%eax
  80197b:	6a 01                	push   $0x1
  80197d:	50                   	push   %eax
  80197e:	53                   	push   %ebx
  80197f:	68 aa 27 80 00       	push   $0x8027aa
  801984:	e8 3f e8 ff ff       	call   8001c8 <cprintf>
  801989:	83 c4 10             	add    $0x10,%esp
  80198c:	eb b9                	jmp    801947 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  80198e:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801991:	0f 94 c0             	sete   %al
  801994:	0f b6 c0             	movzbl %al,%eax
}
  801997:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80199a:	5b                   	pop    %ebx
  80199b:	5e                   	pop    %esi
  80199c:	5f                   	pop    %edi
  80199d:	5d                   	pop    %ebp
  80199e:	c3                   	ret    

0080199f <devpipe_write>:
{
  80199f:	f3 0f 1e fb          	endbr32 
  8019a3:	55                   	push   %ebp
  8019a4:	89 e5                	mov    %esp,%ebp
  8019a6:	57                   	push   %edi
  8019a7:	56                   	push   %esi
  8019a8:	53                   	push   %ebx
  8019a9:	83 ec 28             	sub    $0x28,%esp
  8019ac:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8019af:	56                   	push   %esi
  8019b0:	e8 cf f6 ff ff       	call   801084 <fd2data>
  8019b5:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8019b7:	83 c4 10             	add    $0x10,%esp
  8019ba:	bf 00 00 00 00       	mov    $0x0,%edi
  8019bf:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019c2:	74 4f                	je     801a13 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019c4:	8b 43 04             	mov    0x4(%ebx),%eax
  8019c7:	8b 0b                	mov    (%ebx),%ecx
  8019c9:	8d 51 20             	lea    0x20(%ecx),%edx
  8019cc:	39 d0                	cmp    %edx,%eax
  8019ce:	72 14                	jb     8019e4 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  8019d0:	89 da                	mov    %ebx,%edx
  8019d2:	89 f0                	mov    %esi,%eax
  8019d4:	e8 61 ff ff ff       	call   80193a <_pipeisclosed>
  8019d9:	85 c0                	test   %eax,%eax
  8019db:	75 3b                	jne    801a18 <devpipe_write+0x79>
			sys_yield();
  8019dd:	e8 0e f2 ff ff       	call   800bf0 <sys_yield>
  8019e2:	eb e0                	jmp    8019c4 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019e7:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019eb:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019ee:	89 c2                	mov    %eax,%edx
  8019f0:	c1 fa 1f             	sar    $0x1f,%edx
  8019f3:	89 d1                	mov    %edx,%ecx
  8019f5:	c1 e9 1b             	shr    $0x1b,%ecx
  8019f8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019fb:	83 e2 1f             	and    $0x1f,%edx
  8019fe:	29 ca                	sub    %ecx,%edx
  801a00:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a04:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a08:	83 c0 01             	add    $0x1,%eax
  801a0b:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801a0e:	83 c7 01             	add    $0x1,%edi
  801a11:	eb ac                	jmp    8019bf <devpipe_write+0x20>
	return i;
  801a13:	8b 45 10             	mov    0x10(%ebp),%eax
  801a16:	eb 05                	jmp    801a1d <devpipe_write+0x7e>
				return 0;
  801a18:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a20:	5b                   	pop    %ebx
  801a21:	5e                   	pop    %esi
  801a22:	5f                   	pop    %edi
  801a23:	5d                   	pop    %ebp
  801a24:	c3                   	ret    

00801a25 <devpipe_read>:
{
  801a25:	f3 0f 1e fb          	endbr32 
  801a29:	55                   	push   %ebp
  801a2a:	89 e5                	mov    %esp,%ebp
  801a2c:	57                   	push   %edi
  801a2d:	56                   	push   %esi
  801a2e:	53                   	push   %ebx
  801a2f:	83 ec 18             	sub    $0x18,%esp
  801a32:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801a35:	57                   	push   %edi
  801a36:	e8 49 f6 ff ff       	call   801084 <fd2data>
  801a3b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801a3d:	83 c4 10             	add    $0x10,%esp
  801a40:	be 00 00 00 00       	mov    $0x0,%esi
  801a45:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a48:	75 14                	jne    801a5e <devpipe_read+0x39>
	return i;
  801a4a:	8b 45 10             	mov    0x10(%ebp),%eax
  801a4d:	eb 02                	jmp    801a51 <devpipe_read+0x2c>
				return i;
  801a4f:	89 f0                	mov    %esi,%eax
}
  801a51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a54:	5b                   	pop    %ebx
  801a55:	5e                   	pop    %esi
  801a56:	5f                   	pop    %edi
  801a57:	5d                   	pop    %ebp
  801a58:	c3                   	ret    
			sys_yield();
  801a59:	e8 92 f1 ff ff       	call   800bf0 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801a5e:	8b 03                	mov    (%ebx),%eax
  801a60:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a63:	75 18                	jne    801a7d <devpipe_read+0x58>
			if (i > 0)
  801a65:	85 f6                	test   %esi,%esi
  801a67:	75 e6                	jne    801a4f <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801a69:	89 da                	mov    %ebx,%edx
  801a6b:	89 f8                	mov    %edi,%eax
  801a6d:	e8 c8 fe ff ff       	call   80193a <_pipeisclosed>
  801a72:	85 c0                	test   %eax,%eax
  801a74:	74 e3                	je     801a59 <devpipe_read+0x34>
				return 0;
  801a76:	b8 00 00 00 00       	mov    $0x0,%eax
  801a7b:	eb d4                	jmp    801a51 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a7d:	99                   	cltd   
  801a7e:	c1 ea 1b             	shr    $0x1b,%edx
  801a81:	01 d0                	add    %edx,%eax
  801a83:	83 e0 1f             	and    $0x1f,%eax
  801a86:	29 d0                	sub    %edx,%eax
  801a88:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801a8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a90:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801a93:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801a96:	83 c6 01             	add    $0x1,%esi
  801a99:	eb aa                	jmp    801a45 <devpipe_read+0x20>

00801a9b <pipe>:
{
  801a9b:	f3 0f 1e fb          	endbr32 
  801a9f:	55                   	push   %ebp
  801aa0:	89 e5                	mov    %esp,%ebp
  801aa2:	56                   	push   %esi
  801aa3:	53                   	push   %ebx
  801aa4:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801aa7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aaa:	50                   	push   %eax
  801aab:	e8 ef f5 ff ff       	call   80109f <fd_alloc>
  801ab0:	89 c3                	mov    %eax,%ebx
  801ab2:	83 c4 10             	add    $0x10,%esp
  801ab5:	85 c0                	test   %eax,%eax
  801ab7:	0f 88 23 01 00 00    	js     801be0 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801abd:	83 ec 04             	sub    $0x4,%esp
  801ac0:	68 07 04 00 00       	push   $0x407
  801ac5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ac8:	6a 00                	push   $0x0
  801aca:	e8 44 f1 ff ff       	call   800c13 <sys_page_alloc>
  801acf:	89 c3                	mov    %eax,%ebx
  801ad1:	83 c4 10             	add    $0x10,%esp
  801ad4:	85 c0                	test   %eax,%eax
  801ad6:	0f 88 04 01 00 00    	js     801be0 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801adc:	83 ec 0c             	sub    $0xc,%esp
  801adf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ae2:	50                   	push   %eax
  801ae3:	e8 b7 f5 ff ff       	call   80109f <fd_alloc>
  801ae8:	89 c3                	mov    %eax,%ebx
  801aea:	83 c4 10             	add    $0x10,%esp
  801aed:	85 c0                	test   %eax,%eax
  801aef:	0f 88 db 00 00 00    	js     801bd0 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801af5:	83 ec 04             	sub    $0x4,%esp
  801af8:	68 07 04 00 00       	push   $0x407
  801afd:	ff 75 f0             	pushl  -0x10(%ebp)
  801b00:	6a 00                	push   $0x0
  801b02:	e8 0c f1 ff ff       	call   800c13 <sys_page_alloc>
  801b07:	89 c3                	mov    %eax,%ebx
  801b09:	83 c4 10             	add    $0x10,%esp
  801b0c:	85 c0                	test   %eax,%eax
  801b0e:	0f 88 bc 00 00 00    	js     801bd0 <pipe+0x135>
	va = fd2data(fd0);
  801b14:	83 ec 0c             	sub    $0xc,%esp
  801b17:	ff 75 f4             	pushl  -0xc(%ebp)
  801b1a:	e8 65 f5 ff ff       	call   801084 <fd2data>
  801b1f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b21:	83 c4 0c             	add    $0xc,%esp
  801b24:	68 07 04 00 00       	push   $0x407
  801b29:	50                   	push   %eax
  801b2a:	6a 00                	push   $0x0
  801b2c:	e8 e2 f0 ff ff       	call   800c13 <sys_page_alloc>
  801b31:	89 c3                	mov    %eax,%ebx
  801b33:	83 c4 10             	add    $0x10,%esp
  801b36:	85 c0                	test   %eax,%eax
  801b38:	0f 88 82 00 00 00    	js     801bc0 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b3e:	83 ec 0c             	sub    $0xc,%esp
  801b41:	ff 75 f0             	pushl  -0x10(%ebp)
  801b44:	e8 3b f5 ff ff       	call   801084 <fd2data>
  801b49:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b50:	50                   	push   %eax
  801b51:	6a 00                	push   $0x0
  801b53:	56                   	push   %esi
  801b54:	6a 00                	push   $0x0
  801b56:	e8 ff f0 ff ff       	call   800c5a <sys_page_map>
  801b5b:	89 c3                	mov    %eax,%ebx
  801b5d:	83 c4 20             	add    $0x20,%esp
  801b60:	85 c0                	test   %eax,%eax
  801b62:	78 4e                	js     801bb2 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801b64:	a1 20 30 80 00       	mov    0x803020,%eax
  801b69:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b6c:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801b6e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b71:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801b78:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b7b:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801b7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b80:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801b87:	83 ec 0c             	sub    $0xc,%esp
  801b8a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b8d:	e8 de f4 ff ff       	call   801070 <fd2num>
  801b92:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b95:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b97:	83 c4 04             	add    $0x4,%esp
  801b9a:	ff 75 f0             	pushl  -0x10(%ebp)
  801b9d:	e8 ce f4 ff ff       	call   801070 <fd2num>
  801ba2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ba5:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ba8:	83 c4 10             	add    $0x10,%esp
  801bab:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bb0:	eb 2e                	jmp    801be0 <pipe+0x145>
	sys_page_unmap(0, va);
  801bb2:	83 ec 08             	sub    $0x8,%esp
  801bb5:	56                   	push   %esi
  801bb6:	6a 00                	push   $0x0
  801bb8:	e8 e3 f0 ff ff       	call   800ca0 <sys_page_unmap>
  801bbd:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801bc0:	83 ec 08             	sub    $0x8,%esp
  801bc3:	ff 75 f0             	pushl  -0x10(%ebp)
  801bc6:	6a 00                	push   $0x0
  801bc8:	e8 d3 f0 ff ff       	call   800ca0 <sys_page_unmap>
  801bcd:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801bd0:	83 ec 08             	sub    $0x8,%esp
  801bd3:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd6:	6a 00                	push   $0x0
  801bd8:	e8 c3 f0 ff ff       	call   800ca0 <sys_page_unmap>
  801bdd:	83 c4 10             	add    $0x10,%esp
}
  801be0:	89 d8                	mov    %ebx,%eax
  801be2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801be5:	5b                   	pop    %ebx
  801be6:	5e                   	pop    %esi
  801be7:	5d                   	pop    %ebp
  801be8:	c3                   	ret    

00801be9 <pipeisclosed>:
{
  801be9:	f3 0f 1e fb          	endbr32 
  801bed:	55                   	push   %ebp
  801bee:	89 e5                	mov    %esp,%ebp
  801bf0:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bf3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf6:	50                   	push   %eax
  801bf7:	ff 75 08             	pushl  0x8(%ebp)
  801bfa:	e8 f6 f4 ff ff       	call   8010f5 <fd_lookup>
  801bff:	83 c4 10             	add    $0x10,%esp
  801c02:	85 c0                	test   %eax,%eax
  801c04:	78 18                	js     801c1e <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801c06:	83 ec 0c             	sub    $0xc,%esp
  801c09:	ff 75 f4             	pushl  -0xc(%ebp)
  801c0c:	e8 73 f4 ff ff       	call   801084 <fd2data>
  801c11:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801c13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c16:	e8 1f fd ff ff       	call   80193a <_pipeisclosed>
  801c1b:	83 c4 10             	add    $0x10,%esp
}
  801c1e:	c9                   	leave  
  801c1f:	c3                   	ret    

00801c20 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c20:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801c24:	b8 00 00 00 00       	mov    $0x0,%eax
  801c29:	c3                   	ret    

00801c2a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c2a:	f3 0f 1e fb          	endbr32 
  801c2e:	55                   	push   %ebp
  801c2f:	89 e5                	mov    %esp,%ebp
  801c31:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c34:	68 c2 27 80 00       	push   $0x8027c2
  801c39:	ff 75 0c             	pushl  0xc(%ebp)
  801c3c:	e8 90 eb ff ff       	call   8007d1 <strcpy>
	return 0;
}
  801c41:	b8 00 00 00 00       	mov    $0x0,%eax
  801c46:	c9                   	leave  
  801c47:	c3                   	ret    

00801c48 <devcons_write>:
{
  801c48:	f3 0f 1e fb          	endbr32 
  801c4c:	55                   	push   %ebp
  801c4d:	89 e5                	mov    %esp,%ebp
  801c4f:	57                   	push   %edi
  801c50:	56                   	push   %esi
  801c51:	53                   	push   %ebx
  801c52:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801c58:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801c5d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801c63:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c66:	73 31                	jae    801c99 <devcons_write+0x51>
		m = n - tot;
  801c68:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c6b:	29 f3                	sub    %esi,%ebx
  801c6d:	83 fb 7f             	cmp    $0x7f,%ebx
  801c70:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801c75:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801c78:	83 ec 04             	sub    $0x4,%esp
  801c7b:	53                   	push   %ebx
  801c7c:	89 f0                	mov    %esi,%eax
  801c7e:	03 45 0c             	add    0xc(%ebp),%eax
  801c81:	50                   	push   %eax
  801c82:	57                   	push   %edi
  801c83:	e8 ff ec ff ff       	call   800987 <memmove>
		sys_cputs(buf, m);
  801c88:	83 c4 08             	add    $0x8,%esp
  801c8b:	53                   	push   %ebx
  801c8c:	57                   	push   %edi
  801c8d:	e8 b1 ee ff ff       	call   800b43 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801c92:	01 de                	add    %ebx,%esi
  801c94:	83 c4 10             	add    $0x10,%esp
  801c97:	eb ca                	jmp    801c63 <devcons_write+0x1b>
}
  801c99:	89 f0                	mov    %esi,%eax
  801c9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c9e:	5b                   	pop    %ebx
  801c9f:	5e                   	pop    %esi
  801ca0:	5f                   	pop    %edi
  801ca1:	5d                   	pop    %ebp
  801ca2:	c3                   	ret    

00801ca3 <devcons_read>:
{
  801ca3:	f3 0f 1e fb          	endbr32 
  801ca7:	55                   	push   %ebp
  801ca8:	89 e5                	mov    %esp,%ebp
  801caa:	83 ec 08             	sub    $0x8,%esp
  801cad:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801cb2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cb6:	74 21                	je     801cd9 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801cb8:	e8 a8 ee ff ff       	call   800b65 <sys_cgetc>
  801cbd:	85 c0                	test   %eax,%eax
  801cbf:	75 07                	jne    801cc8 <devcons_read+0x25>
		sys_yield();
  801cc1:	e8 2a ef ff ff       	call   800bf0 <sys_yield>
  801cc6:	eb f0                	jmp    801cb8 <devcons_read+0x15>
	if (c < 0)
  801cc8:	78 0f                	js     801cd9 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801cca:	83 f8 04             	cmp    $0x4,%eax
  801ccd:	74 0c                	je     801cdb <devcons_read+0x38>
	*(char*)vbuf = c;
  801ccf:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cd2:	88 02                	mov    %al,(%edx)
	return 1;
  801cd4:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801cd9:	c9                   	leave  
  801cda:	c3                   	ret    
		return 0;
  801cdb:	b8 00 00 00 00       	mov    $0x0,%eax
  801ce0:	eb f7                	jmp    801cd9 <devcons_read+0x36>

00801ce2 <cputchar>:
{
  801ce2:	f3 0f 1e fb          	endbr32 
  801ce6:	55                   	push   %ebp
  801ce7:	89 e5                	mov    %esp,%ebp
  801ce9:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801cec:	8b 45 08             	mov    0x8(%ebp),%eax
  801cef:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801cf2:	6a 01                	push   $0x1
  801cf4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cf7:	50                   	push   %eax
  801cf8:	e8 46 ee ff ff       	call   800b43 <sys_cputs>
}
  801cfd:	83 c4 10             	add    $0x10,%esp
  801d00:	c9                   	leave  
  801d01:	c3                   	ret    

00801d02 <getchar>:
{
  801d02:	f3 0f 1e fb          	endbr32 
  801d06:	55                   	push   %ebp
  801d07:	89 e5                	mov    %esp,%ebp
  801d09:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801d0c:	6a 01                	push   $0x1
  801d0e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d11:	50                   	push   %eax
  801d12:	6a 00                	push   $0x0
  801d14:	e8 5f f6 ff ff       	call   801378 <read>
	if (r < 0)
  801d19:	83 c4 10             	add    $0x10,%esp
  801d1c:	85 c0                	test   %eax,%eax
  801d1e:	78 06                	js     801d26 <getchar+0x24>
	if (r < 1)
  801d20:	74 06                	je     801d28 <getchar+0x26>
	return c;
  801d22:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801d26:	c9                   	leave  
  801d27:	c3                   	ret    
		return -E_EOF;
  801d28:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801d2d:	eb f7                	jmp    801d26 <getchar+0x24>

00801d2f <iscons>:
{
  801d2f:	f3 0f 1e fb          	endbr32 
  801d33:	55                   	push   %ebp
  801d34:	89 e5                	mov    %esp,%ebp
  801d36:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d39:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d3c:	50                   	push   %eax
  801d3d:	ff 75 08             	pushl  0x8(%ebp)
  801d40:	e8 b0 f3 ff ff       	call   8010f5 <fd_lookup>
  801d45:	83 c4 10             	add    $0x10,%esp
  801d48:	85 c0                	test   %eax,%eax
  801d4a:	78 11                	js     801d5d <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d55:	39 10                	cmp    %edx,(%eax)
  801d57:	0f 94 c0             	sete   %al
  801d5a:	0f b6 c0             	movzbl %al,%eax
}
  801d5d:	c9                   	leave  
  801d5e:	c3                   	ret    

00801d5f <opencons>:
{
  801d5f:	f3 0f 1e fb          	endbr32 
  801d63:	55                   	push   %ebp
  801d64:	89 e5                	mov    %esp,%ebp
  801d66:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801d69:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d6c:	50                   	push   %eax
  801d6d:	e8 2d f3 ff ff       	call   80109f <fd_alloc>
  801d72:	83 c4 10             	add    $0x10,%esp
  801d75:	85 c0                	test   %eax,%eax
  801d77:	78 3a                	js     801db3 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d79:	83 ec 04             	sub    $0x4,%esp
  801d7c:	68 07 04 00 00       	push   $0x407
  801d81:	ff 75 f4             	pushl  -0xc(%ebp)
  801d84:	6a 00                	push   $0x0
  801d86:	e8 88 ee ff ff       	call   800c13 <sys_page_alloc>
  801d8b:	83 c4 10             	add    $0x10,%esp
  801d8e:	85 c0                	test   %eax,%eax
  801d90:	78 21                	js     801db3 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801d92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d95:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d9b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801da7:	83 ec 0c             	sub    $0xc,%esp
  801daa:	50                   	push   %eax
  801dab:	e8 c0 f2 ff ff       	call   801070 <fd2num>
  801db0:	83 c4 10             	add    $0x10,%esp
}
  801db3:	c9                   	leave  
  801db4:	c3                   	ret    

00801db5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801db5:	f3 0f 1e fb          	endbr32 
  801db9:	55                   	push   %ebp
  801dba:	89 e5                	mov    %esp,%ebp
  801dbc:	56                   	push   %esi
  801dbd:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801dbe:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801dc1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801dc7:	e8 01 ee ff ff       	call   800bcd <sys_getenvid>
  801dcc:	83 ec 0c             	sub    $0xc,%esp
  801dcf:	ff 75 0c             	pushl  0xc(%ebp)
  801dd2:	ff 75 08             	pushl  0x8(%ebp)
  801dd5:	56                   	push   %esi
  801dd6:	50                   	push   %eax
  801dd7:	68 d0 27 80 00       	push   $0x8027d0
  801ddc:	e8 e7 e3 ff ff       	call   8001c8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801de1:	83 c4 18             	add    $0x18,%esp
  801de4:	53                   	push   %ebx
  801de5:	ff 75 10             	pushl  0x10(%ebp)
  801de8:	e8 86 e3 ff ff       	call   800173 <vcprintf>
	cprintf("\n");
  801ded:	c7 04 24 d4 22 80 00 	movl   $0x8022d4,(%esp)
  801df4:	e8 cf e3 ff ff       	call   8001c8 <cprintf>
  801df9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801dfc:	cc                   	int3   
  801dfd:	eb fd                	jmp    801dfc <_panic+0x47>

00801dff <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801dff:	f3 0f 1e fb          	endbr32 
  801e03:	55                   	push   %ebp
  801e04:	89 e5                	mov    %esp,%ebp
  801e06:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e09:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e10:	74 0a                	je     801e1c <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e12:	8b 45 08             	mov    0x8(%ebp),%eax
  801e15:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e1a:	c9                   	leave  
  801e1b:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  801e1c:	83 ec 0c             	sub    $0xc,%esp
  801e1f:	68 f3 27 80 00       	push   $0x8027f3
  801e24:	e8 9f e3 ff ff       	call   8001c8 <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  801e29:	83 c4 0c             	add    $0xc,%esp
  801e2c:	6a 07                	push   $0x7
  801e2e:	68 00 f0 bf ee       	push   $0xeebff000
  801e33:	6a 00                	push   $0x0
  801e35:	e8 d9 ed ff ff       	call   800c13 <sys_page_alloc>
  801e3a:	83 c4 10             	add    $0x10,%esp
  801e3d:	85 c0                	test   %eax,%eax
  801e3f:	78 2a                	js     801e6b <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  801e41:	83 ec 08             	sub    $0x8,%esp
  801e44:	68 7f 1e 80 00       	push   $0x801e7f
  801e49:	6a 00                	push   $0x0
  801e4b:	e8 22 ef ff ff       	call   800d72 <sys_env_set_pgfault_upcall>
  801e50:	83 c4 10             	add    $0x10,%esp
  801e53:	85 c0                	test   %eax,%eax
  801e55:	79 bb                	jns    801e12 <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  801e57:	83 ec 04             	sub    $0x4,%esp
  801e5a:	68 30 28 80 00       	push   $0x802830
  801e5f:	6a 25                	push   $0x25
  801e61:	68 20 28 80 00       	push   $0x802820
  801e66:	e8 4a ff ff ff       	call   801db5 <_panic>
            panic("Allocation of UXSTACK failed!");
  801e6b:	83 ec 04             	sub    $0x4,%esp
  801e6e:	68 02 28 80 00       	push   $0x802802
  801e73:	6a 22                	push   $0x22
  801e75:	68 20 28 80 00       	push   $0x802820
  801e7a:	e8 36 ff ff ff       	call   801db5 <_panic>

00801e7f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e7f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e80:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e85:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e87:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  801e8a:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  801e8e:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  801e92:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  801e95:	83 c4 08             	add    $0x8,%esp
    popa
  801e98:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

    add $0x4, %esp
  801e99:	83 c4 04             	add    $0x4,%esp
    popf
  801e9c:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  801e9d:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  801ea0:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  801ea4:	c3                   	ret    

00801ea5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ea5:	f3 0f 1e fb          	endbr32 
  801ea9:	55                   	push   %ebp
  801eaa:	89 e5                	mov    %esp,%ebp
  801eac:	56                   	push   %esi
  801ead:	53                   	push   %ebx
  801eae:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801eb1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eb4:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801eb7:	85 c0                	test   %eax,%eax
  801eb9:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801ebe:	0f 44 c2             	cmove  %edx,%eax
  801ec1:	83 ec 0c             	sub    $0xc,%esp
  801ec4:	50                   	push   %eax
  801ec5:	e8 15 ef ff ff       	call   800ddf <sys_ipc_recv>
  801eca:	83 c4 10             	add    $0x10,%esp
  801ecd:	85 c0                	test   %eax,%eax
  801ecf:	78 24                	js     801ef5 <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801ed1:	85 f6                	test   %esi,%esi
  801ed3:	74 0a                	je     801edf <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801ed5:	a1 04 40 80 00       	mov    0x804004,%eax
  801eda:	8b 40 78             	mov    0x78(%eax),%eax
  801edd:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801edf:	85 db                	test   %ebx,%ebx
  801ee1:	74 0a                	je     801eed <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801ee3:	a1 04 40 80 00       	mov    0x804004,%eax
  801ee8:	8b 40 74             	mov    0x74(%eax),%eax
  801eeb:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801eed:	a1 04 40 80 00       	mov    0x804004,%eax
  801ef2:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ef5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ef8:	5b                   	pop    %ebx
  801ef9:	5e                   	pop    %esi
  801efa:	5d                   	pop    %ebp
  801efb:	c3                   	ret    

00801efc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801efc:	f3 0f 1e fb          	endbr32 
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
  801f03:	57                   	push   %edi
  801f04:	56                   	push   %esi
  801f05:	53                   	push   %ebx
  801f06:	83 ec 1c             	sub    $0x1c,%esp
  801f09:	8b 45 10             	mov    0x10(%ebp),%eax
  801f0c:	85 c0                	test   %eax,%eax
  801f0e:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801f13:	0f 45 d0             	cmovne %eax,%edx
  801f16:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801f18:	be 01 00 00 00       	mov    $0x1,%esi
  801f1d:	eb 1f                	jmp    801f3e <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801f1f:	e8 cc ec ff ff       	call   800bf0 <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801f24:	83 c3 01             	add    $0x1,%ebx
  801f27:	39 de                	cmp    %ebx,%esi
  801f29:	7f f4                	jg     801f1f <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801f2b:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801f2d:	83 fe 11             	cmp    $0x11,%esi
  801f30:	b8 01 00 00 00       	mov    $0x1,%eax
  801f35:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801f38:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801f3c:	75 1c                	jne    801f5a <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801f3e:	ff 75 14             	pushl  0x14(%ebp)
  801f41:	57                   	push   %edi
  801f42:	ff 75 0c             	pushl  0xc(%ebp)
  801f45:	ff 75 08             	pushl  0x8(%ebp)
  801f48:	e8 6b ee ff ff       	call   800db8 <sys_ipc_try_send>
  801f4d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801f50:	83 c4 10             	add    $0x10,%esp
  801f53:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f58:	eb cd                	jmp    801f27 <ipc_send+0x2b>
}
  801f5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f5d:	5b                   	pop    %ebx
  801f5e:	5e                   	pop    %esi
  801f5f:	5f                   	pop    %edi
  801f60:	5d                   	pop    %ebp
  801f61:	c3                   	ret    

00801f62 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f62:	f3 0f 1e fb          	endbr32 
  801f66:	55                   	push   %ebp
  801f67:	89 e5                	mov    %esp,%ebp
  801f69:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f6c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f71:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f74:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f7a:	8b 52 50             	mov    0x50(%edx),%edx
  801f7d:	39 ca                	cmp    %ecx,%edx
  801f7f:	74 11                	je     801f92 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801f81:	83 c0 01             	add    $0x1,%eax
  801f84:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f89:	75 e6                	jne    801f71 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801f8b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f90:	eb 0b                	jmp    801f9d <ipc_find_env+0x3b>
			return envs[i].env_id;
  801f92:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f95:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f9a:	8b 40 48             	mov    0x48(%eax),%eax
}
  801f9d:	5d                   	pop    %ebp
  801f9e:	c3                   	ret    

00801f9f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f9f:	f3 0f 1e fb          	endbr32 
  801fa3:	55                   	push   %ebp
  801fa4:	89 e5                	mov    %esp,%ebp
  801fa6:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fa9:	89 c2                	mov    %eax,%edx
  801fab:	c1 ea 16             	shr    $0x16,%edx
  801fae:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801fb5:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801fba:	f6 c1 01             	test   $0x1,%cl
  801fbd:	74 1c                	je     801fdb <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801fbf:	c1 e8 0c             	shr    $0xc,%eax
  801fc2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801fc9:	a8 01                	test   $0x1,%al
  801fcb:	74 0e                	je     801fdb <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fcd:	c1 e8 0c             	shr    $0xc,%eax
  801fd0:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801fd7:	ef 
  801fd8:	0f b7 d2             	movzwl %dx,%edx
}
  801fdb:	89 d0                	mov    %edx,%eax
  801fdd:	5d                   	pop    %ebp
  801fde:	c3                   	ret    
  801fdf:	90                   	nop

00801fe0 <__udivdi3>:
  801fe0:	f3 0f 1e fb          	endbr32 
  801fe4:	55                   	push   %ebp
  801fe5:	57                   	push   %edi
  801fe6:	56                   	push   %esi
  801fe7:	53                   	push   %ebx
  801fe8:	83 ec 1c             	sub    $0x1c,%esp
  801feb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801fef:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801ff3:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ff7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801ffb:	85 d2                	test   %edx,%edx
  801ffd:	75 19                	jne    802018 <__udivdi3+0x38>
  801fff:	39 f3                	cmp    %esi,%ebx
  802001:	76 4d                	jbe    802050 <__udivdi3+0x70>
  802003:	31 ff                	xor    %edi,%edi
  802005:	89 e8                	mov    %ebp,%eax
  802007:	89 f2                	mov    %esi,%edx
  802009:	f7 f3                	div    %ebx
  80200b:	89 fa                	mov    %edi,%edx
  80200d:	83 c4 1c             	add    $0x1c,%esp
  802010:	5b                   	pop    %ebx
  802011:	5e                   	pop    %esi
  802012:	5f                   	pop    %edi
  802013:	5d                   	pop    %ebp
  802014:	c3                   	ret    
  802015:	8d 76 00             	lea    0x0(%esi),%esi
  802018:	39 f2                	cmp    %esi,%edx
  80201a:	76 14                	jbe    802030 <__udivdi3+0x50>
  80201c:	31 ff                	xor    %edi,%edi
  80201e:	31 c0                	xor    %eax,%eax
  802020:	89 fa                	mov    %edi,%edx
  802022:	83 c4 1c             	add    $0x1c,%esp
  802025:	5b                   	pop    %ebx
  802026:	5e                   	pop    %esi
  802027:	5f                   	pop    %edi
  802028:	5d                   	pop    %ebp
  802029:	c3                   	ret    
  80202a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802030:	0f bd fa             	bsr    %edx,%edi
  802033:	83 f7 1f             	xor    $0x1f,%edi
  802036:	75 48                	jne    802080 <__udivdi3+0xa0>
  802038:	39 f2                	cmp    %esi,%edx
  80203a:	72 06                	jb     802042 <__udivdi3+0x62>
  80203c:	31 c0                	xor    %eax,%eax
  80203e:	39 eb                	cmp    %ebp,%ebx
  802040:	77 de                	ja     802020 <__udivdi3+0x40>
  802042:	b8 01 00 00 00       	mov    $0x1,%eax
  802047:	eb d7                	jmp    802020 <__udivdi3+0x40>
  802049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802050:	89 d9                	mov    %ebx,%ecx
  802052:	85 db                	test   %ebx,%ebx
  802054:	75 0b                	jne    802061 <__udivdi3+0x81>
  802056:	b8 01 00 00 00       	mov    $0x1,%eax
  80205b:	31 d2                	xor    %edx,%edx
  80205d:	f7 f3                	div    %ebx
  80205f:	89 c1                	mov    %eax,%ecx
  802061:	31 d2                	xor    %edx,%edx
  802063:	89 f0                	mov    %esi,%eax
  802065:	f7 f1                	div    %ecx
  802067:	89 c6                	mov    %eax,%esi
  802069:	89 e8                	mov    %ebp,%eax
  80206b:	89 f7                	mov    %esi,%edi
  80206d:	f7 f1                	div    %ecx
  80206f:	89 fa                	mov    %edi,%edx
  802071:	83 c4 1c             	add    $0x1c,%esp
  802074:	5b                   	pop    %ebx
  802075:	5e                   	pop    %esi
  802076:	5f                   	pop    %edi
  802077:	5d                   	pop    %ebp
  802078:	c3                   	ret    
  802079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802080:	89 f9                	mov    %edi,%ecx
  802082:	b8 20 00 00 00       	mov    $0x20,%eax
  802087:	29 f8                	sub    %edi,%eax
  802089:	d3 e2                	shl    %cl,%edx
  80208b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80208f:	89 c1                	mov    %eax,%ecx
  802091:	89 da                	mov    %ebx,%edx
  802093:	d3 ea                	shr    %cl,%edx
  802095:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802099:	09 d1                	or     %edx,%ecx
  80209b:	89 f2                	mov    %esi,%edx
  80209d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020a1:	89 f9                	mov    %edi,%ecx
  8020a3:	d3 e3                	shl    %cl,%ebx
  8020a5:	89 c1                	mov    %eax,%ecx
  8020a7:	d3 ea                	shr    %cl,%edx
  8020a9:	89 f9                	mov    %edi,%ecx
  8020ab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8020af:	89 eb                	mov    %ebp,%ebx
  8020b1:	d3 e6                	shl    %cl,%esi
  8020b3:	89 c1                	mov    %eax,%ecx
  8020b5:	d3 eb                	shr    %cl,%ebx
  8020b7:	09 de                	or     %ebx,%esi
  8020b9:	89 f0                	mov    %esi,%eax
  8020bb:	f7 74 24 08          	divl   0x8(%esp)
  8020bf:	89 d6                	mov    %edx,%esi
  8020c1:	89 c3                	mov    %eax,%ebx
  8020c3:	f7 64 24 0c          	mull   0xc(%esp)
  8020c7:	39 d6                	cmp    %edx,%esi
  8020c9:	72 15                	jb     8020e0 <__udivdi3+0x100>
  8020cb:	89 f9                	mov    %edi,%ecx
  8020cd:	d3 e5                	shl    %cl,%ebp
  8020cf:	39 c5                	cmp    %eax,%ebp
  8020d1:	73 04                	jae    8020d7 <__udivdi3+0xf7>
  8020d3:	39 d6                	cmp    %edx,%esi
  8020d5:	74 09                	je     8020e0 <__udivdi3+0x100>
  8020d7:	89 d8                	mov    %ebx,%eax
  8020d9:	31 ff                	xor    %edi,%edi
  8020db:	e9 40 ff ff ff       	jmp    802020 <__udivdi3+0x40>
  8020e0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8020e3:	31 ff                	xor    %edi,%edi
  8020e5:	e9 36 ff ff ff       	jmp    802020 <__udivdi3+0x40>
  8020ea:	66 90                	xchg   %ax,%ax
  8020ec:	66 90                	xchg   %ax,%ax
  8020ee:	66 90                	xchg   %ax,%ax

008020f0 <__umoddi3>:
  8020f0:	f3 0f 1e fb          	endbr32 
  8020f4:	55                   	push   %ebp
  8020f5:	57                   	push   %edi
  8020f6:	56                   	push   %esi
  8020f7:	53                   	push   %ebx
  8020f8:	83 ec 1c             	sub    $0x1c,%esp
  8020fb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8020ff:	8b 74 24 30          	mov    0x30(%esp),%esi
  802103:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802107:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80210b:	85 c0                	test   %eax,%eax
  80210d:	75 19                	jne    802128 <__umoddi3+0x38>
  80210f:	39 df                	cmp    %ebx,%edi
  802111:	76 5d                	jbe    802170 <__umoddi3+0x80>
  802113:	89 f0                	mov    %esi,%eax
  802115:	89 da                	mov    %ebx,%edx
  802117:	f7 f7                	div    %edi
  802119:	89 d0                	mov    %edx,%eax
  80211b:	31 d2                	xor    %edx,%edx
  80211d:	83 c4 1c             	add    $0x1c,%esp
  802120:	5b                   	pop    %ebx
  802121:	5e                   	pop    %esi
  802122:	5f                   	pop    %edi
  802123:	5d                   	pop    %ebp
  802124:	c3                   	ret    
  802125:	8d 76 00             	lea    0x0(%esi),%esi
  802128:	89 f2                	mov    %esi,%edx
  80212a:	39 d8                	cmp    %ebx,%eax
  80212c:	76 12                	jbe    802140 <__umoddi3+0x50>
  80212e:	89 f0                	mov    %esi,%eax
  802130:	89 da                	mov    %ebx,%edx
  802132:	83 c4 1c             	add    $0x1c,%esp
  802135:	5b                   	pop    %ebx
  802136:	5e                   	pop    %esi
  802137:	5f                   	pop    %edi
  802138:	5d                   	pop    %ebp
  802139:	c3                   	ret    
  80213a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802140:	0f bd e8             	bsr    %eax,%ebp
  802143:	83 f5 1f             	xor    $0x1f,%ebp
  802146:	75 50                	jne    802198 <__umoddi3+0xa8>
  802148:	39 d8                	cmp    %ebx,%eax
  80214a:	0f 82 e0 00 00 00    	jb     802230 <__umoddi3+0x140>
  802150:	89 d9                	mov    %ebx,%ecx
  802152:	39 f7                	cmp    %esi,%edi
  802154:	0f 86 d6 00 00 00    	jbe    802230 <__umoddi3+0x140>
  80215a:	89 d0                	mov    %edx,%eax
  80215c:	89 ca                	mov    %ecx,%edx
  80215e:	83 c4 1c             	add    $0x1c,%esp
  802161:	5b                   	pop    %ebx
  802162:	5e                   	pop    %esi
  802163:	5f                   	pop    %edi
  802164:	5d                   	pop    %ebp
  802165:	c3                   	ret    
  802166:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80216d:	8d 76 00             	lea    0x0(%esi),%esi
  802170:	89 fd                	mov    %edi,%ebp
  802172:	85 ff                	test   %edi,%edi
  802174:	75 0b                	jne    802181 <__umoddi3+0x91>
  802176:	b8 01 00 00 00       	mov    $0x1,%eax
  80217b:	31 d2                	xor    %edx,%edx
  80217d:	f7 f7                	div    %edi
  80217f:	89 c5                	mov    %eax,%ebp
  802181:	89 d8                	mov    %ebx,%eax
  802183:	31 d2                	xor    %edx,%edx
  802185:	f7 f5                	div    %ebp
  802187:	89 f0                	mov    %esi,%eax
  802189:	f7 f5                	div    %ebp
  80218b:	89 d0                	mov    %edx,%eax
  80218d:	31 d2                	xor    %edx,%edx
  80218f:	eb 8c                	jmp    80211d <__umoddi3+0x2d>
  802191:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802198:	89 e9                	mov    %ebp,%ecx
  80219a:	ba 20 00 00 00       	mov    $0x20,%edx
  80219f:	29 ea                	sub    %ebp,%edx
  8021a1:	d3 e0                	shl    %cl,%eax
  8021a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021a7:	89 d1                	mov    %edx,%ecx
  8021a9:	89 f8                	mov    %edi,%eax
  8021ab:	d3 e8                	shr    %cl,%eax
  8021ad:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8021b1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021b5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021b9:	09 c1                	or     %eax,%ecx
  8021bb:	89 d8                	mov    %ebx,%eax
  8021bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021c1:	89 e9                	mov    %ebp,%ecx
  8021c3:	d3 e7                	shl    %cl,%edi
  8021c5:	89 d1                	mov    %edx,%ecx
  8021c7:	d3 e8                	shr    %cl,%eax
  8021c9:	89 e9                	mov    %ebp,%ecx
  8021cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8021cf:	d3 e3                	shl    %cl,%ebx
  8021d1:	89 c7                	mov    %eax,%edi
  8021d3:	89 d1                	mov    %edx,%ecx
  8021d5:	89 f0                	mov    %esi,%eax
  8021d7:	d3 e8                	shr    %cl,%eax
  8021d9:	89 e9                	mov    %ebp,%ecx
  8021db:	89 fa                	mov    %edi,%edx
  8021dd:	d3 e6                	shl    %cl,%esi
  8021df:	09 d8                	or     %ebx,%eax
  8021e1:	f7 74 24 08          	divl   0x8(%esp)
  8021e5:	89 d1                	mov    %edx,%ecx
  8021e7:	89 f3                	mov    %esi,%ebx
  8021e9:	f7 64 24 0c          	mull   0xc(%esp)
  8021ed:	89 c6                	mov    %eax,%esi
  8021ef:	89 d7                	mov    %edx,%edi
  8021f1:	39 d1                	cmp    %edx,%ecx
  8021f3:	72 06                	jb     8021fb <__umoddi3+0x10b>
  8021f5:	75 10                	jne    802207 <__umoddi3+0x117>
  8021f7:	39 c3                	cmp    %eax,%ebx
  8021f9:	73 0c                	jae    802207 <__umoddi3+0x117>
  8021fb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8021ff:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802203:	89 d7                	mov    %edx,%edi
  802205:	89 c6                	mov    %eax,%esi
  802207:	89 ca                	mov    %ecx,%edx
  802209:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80220e:	29 f3                	sub    %esi,%ebx
  802210:	19 fa                	sbb    %edi,%edx
  802212:	89 d0                	mov    %edx,%eax
  802214:	d3 e0                	shl    %cl,%eax
  802216:	89 e9                	mov    %ebp,%ecx
  802218:	d3 eb                	shr    %cl,%ebx
  80221a:	d3 ea                	shr    %cl,%edx
  80221c:	09 d8                	or     %ebx,%eax
  80221e:	83 c4 1c             	add    $0x1c,%esp
  802221:	5b                   	pop    %ebx
  802222:	5e                   	pop    %esi
  802223:	5f                   	pop    %edi
  802224:	5d                   	pop    %ebp
  802225:	c3                   	ret    
  802226:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80222d:	8d 76 00             	lea    0x0(%esi),%esi
  802230:	29 fe                	sub    %edi,%esi
  802232:	19 c3                	sbb    %eax,%ebx
  802234:	89 f2                	mov    %esi,%edx
  802236:	89 d9                	mov    %ebx,%ecx
  802238:	e9 1d ff ff ff       	jmp    80215a <__umoddi3+0x6a>
