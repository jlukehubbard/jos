
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
  80003e:	68 20 22 80 00       	push   $0x802220
  800043:	e8 80 01 00 00       	call   8001c8 <cprintf>
	if ((env = fork()) == 0) {
  800048:	e8 ac 0e 00 00       	call   800ef9 <fork>
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	85 c0                	test   %eax,%eax
  800052:	75 12                	jne    800066 <umain+0x33>
		cprintf("I am the child.  Spinning...\n");
  800054:	83 ec 0c             	sub    $0xc,%esp
  800057:	68 98 22 80 00       	push   $0x802298
  80005c:	e8 67 01 00 00       	call   8001c8 <cprintf>
  800061:	83 c4 10             	add    $0x10,%esp
  800064:	eb fe                	jmp    800064 <umain+0x31>
  800066:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800068:	83 ec 0c             	sub    $0xc,%esp
  80006b:	68 48 22 80 00       	push   $0x802248
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
  80009d:	c7 04 24 70 22 80 00 	movl   $0x802270,(%esp)
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
  800117:	e8 38 11 00 00       	call   801254 <close_all>
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
  80022e:	e8 7d 1d 00 00       	call   801fb0 <__udivdi3>
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
  80026c:	e8 4f 1e 00 00       	call   8020c0 <__umoddi3>
  800271:	83 c4 14             	add    $0x14,%esp
  800274:	0f be 80 c0 22 80 00 	movsbl 0x8022c0(%eax),%eax
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
  80031b:	3e ff 24 85 00 24 80 	notrack jmp *0x802400(,%eax,4)
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
  8003e8:	8b 14 85 60 25 80 00 	mov    0x802560(,%eax,4),%edx
  8003ef:	85 d2                	test   %edx,%edx
  8003f1:	74 18                	je     80040b <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8003f3:	52                   	push   %edx
  8003f4:	68 92 27 80 00       	push   $0x802792
  8003f9:	53                   	push   %ebx
  8003fa:	56                   	push   %esi
  8003fb:	e8 aa fe ff ff       	call   8002aa <printfmt>
  800400:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800403:	89 7d 14             	mov    %edi,0x14(%ebp)
  800406:	e9 22 02 00 00       	jmp    80062d <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  80040b:	50                   	push   %eax
  80040c:	68 d8 22 80 00       	push   $0x8022d8
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
  800433:	b8 d1 22 80 00       	mov    $0x8022d1,%eax
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
  800bbc:	68 bf 25 80 00       	push   $0x8025bf
  800bc1:	6a 23                	push   $0x23
  800bc3:	68 dc 25 80 00       	push   $0x8025dc
  800bc8:	e8 b1 11 00 00       	call   801d7e <_panic>

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
  800c49:	68 bf 25 80 00       	push   $0x8025bf
  800c4e:	6a 23                	push   $0x23
  800c50:	68 dc 25 80 00       	push   $0x8025dc
  800c55:	e8 24 11 00 00       	call   801d7e <_panic>

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
  800c8f:	68 bf 25 80 00       	push   $0x8025bf
  800c94:	6a 23                	push   $0x23
  800c96:	68 dc 25 80 00       	push   $0x8025dc
  800c9b:	e8 de 10 00 00       	call   801d7e <_panic>

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
  800cd5:	68 bf 25 80 00       	push   $0x8025bf
  800cda:	6a 23                	push   $0x23
  800cdc:	68 dc 25 80 00       	push   $0x8025dc
  800ce1:	e8 98 10 00 00       	call   801d7e <_panic>

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
  800d1b:	68 bf 25 80 00       	push   $0x8025bf
  800d20:	6a 23                	push   $0x23
  800d22:	68 dc 25 80 00       	push   $0x8025dc
  800d27:	e8 52 10 00 00       	call   801d7e <_panic>

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
  800d61:	68 bf 25 80 00       	push   $0x8025bf
  800d66:	6a 23                	push   $0x23
  800d68:	68 dc 25 80 00       	push   $0x8025dc
  800d6d:	e8 0c 10 00 00       	call   801d7e <_panic>

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
  800da7:	68 bf 25 80 00       	push   $0x8025bf
  800dac:	6a 23                	push   $0x23
  800dae:	68 dc 25 80 00       	push   $0x8025dc
  800db3:	e8 c6 0f 00 00       	call   801d7e <_panic>

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
  800e13:	68 bf 25 80 00       	push   $0x8025bf
  800e18:	6a 23                	push   $0x23
  800e1a:	68 dc 25 80 00       	push   $0x8025dc
  800e1f:	e8 5a 0f 00 00       	call   801d7e <_panic>

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
  800eb2:	68 ea 25 80 00       	push   $0x8025ea
  800eb7:	6a 1e                	push   $0x1e
  800eb9:	68 03 26 80 00       	push   $0x802603
  800ebe:	e8 bb 0e 00 00       	call   801d7e <_panic>
        panic("sys_page_alloc failed %e\n", r);
  800ec3:	50                   	push   %eax
  800ec4:	68 0e 26 80 00       	push   $0x80260e
  800ec9:	6a 2a                	push   $0x2a
  800ecb:	68 03 26 80 00       	push   $0x802603
  800ed0:	e8 a9 0e 00 00       	call   801d7e <_panic>
        panic("sys_page_map failed %e\n", r);
  800ed5:	50                   	push   %eax
  800ed6:	68 28 26 80 00       	push   $0x802628
  800edb:	6a 2f                	push   $0x2f
  800edd:	68 03 26 80 00       	push   $0x802603
  800ee2:	e8 97 0e 00 00       	call   801d7e <_panic>
        panic("sys_page_unmap failed %e\n", r);
  800ee7:	50                   	push   %eax
  800ee8:	68 40 26 80 00       	push   $0x802640
  800eed:	6a 32                	push   $0x32
  800eef:	68 03 26 80 00       	push   $0x802603
  800ef4:	e8 85 0e 00 00       	call   801d7e <_panic>

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
  800f0b:	e8 b8 0e 00 00       	call   801dc8 <set_pgfault_handler>
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
  800f2d:	75 4e                	jne    800f7d <fork+0x84>
        envid_t my_envid = sys_getenvid();
  800f2f:	e8 99 fc ff ff       	call   800bcd <sys_getenvid>
        thisenv = &envs[ENVX(my_envid)];
  800f34:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f39:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f3c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f41:	a3 04 40 80 00       	mov    %eax,0x804004
        return 0;
  800f46:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f49:	e9 f1 00 00 00       	jmp    80103f <fork+0x146>
        panic("fork, sys_exofork %e", envid);
  800f4e:	50                   	push   %eax
  800f4f:	68 5a 26 80 00       	push   $0x80265a
  800f54:	6a 7b                	push   $0x7b
  800f56:	68 03 26 80 00       	push   $0x802603
  800f5b:	e8 1e 0e 00 00       	call   801d7e <_panic>
        panic("sys_page_map others failed %e\n", r);
  800f60:	50                   	push   %eax
  800f61:	68 a4 26 80 00       	push   $0x8026a4
  800f66:	6a 51                	push   $0x51
  800f68:	68 03 26 80 00       	push   $0x802603
  800f6d:	e8 0c 0e 00 00       	call   801d7e <_panic>
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800f72:	83 c3 01             	add    $0x1,%ebx
  800f75:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  800f7b:	74 7c                	je     800ff9 <fork+0x100>
  800f7d:	89 de                	mov    %ebx,%esi
  800f7f:	c1 e6 0c             	shl    $0xc,%esi
            uintptr_t pgaddr = pn << PGSHIFT;
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800f82:	89 f0                	mov    %esi,%eax
  800f84:	c1 e8 16             	shr    $0x16,%eax
  800f87:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f8e:	a8 01                	test   $0x1,%al
  800f90:	74 e0                	je     800f72 <fork+0x79>
                    (uvpt[pn] & PTE_P) ) {
  800f92:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800f99:	a8 01                	test   $0x1,%al
  800f9b:	74 d5                	je     800f72 <fork+0x79>
    pte_t pte = uvpt[pn];
  800f9d:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
    if ( (pte & PTE_W) || (pte & PTE_COW) ) {
  800fa4:	25 02 08 00 00       	and    $0x802,%eax
        perm |= PTE_COW;
  800fa9:	83 f8 01             	cmp    $0x1,%eax
  800fac:	19 ff                	sbb    %edi,%edi
  800fae:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  800fb4:	81 c7 05 08 00 00    	add    $0x805,%edi
    if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0) {
  800fba:	83 ec 0c             	sub    $0xc,%esp
  800fbd:	57                   	push   %edi
  800fbe:	56                   	push   %esi
  800fbf:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fc2:	56                   	push   %esi
  800fc3:	6a 00                	push   $0x0
  800fc5:	e8 90 fc ff ff       	call   800c5a <sys_page_map>
  800fca:	83 c4 20             	add    $0x20,%esp
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	78 8f                	js     800f60 <fork+0x67>
        if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0) {
  800fd1:	83 ec 0c             	sub    $0xc,%esp
  800fd4:	57                   	push   %edi
  800fd5:	56                   	push   %esi
  800fd6:	6a 00                	push   $0x0
  800fd8:	56                   	push   %esi
  800fd9:	6a 00                	push   $0x0
  800fdb:	e8 7a fc ff ff       	call   800c5a <sys_page_map>
  800fe0:	83 c4 20             	add    $0x20,%esp
  800fe3:	85 c0                	test   %eax,%eax
  800fe5:	79 8b                	jns    800f72 <fork+0x79>
            panic("sys_page_map mine failed %e\n", r);
  800fe7:	50                   	push   %eax
  800fe8:	68 6f 26 80 00       	push   $0x80266f
  800fed:	6a 56                	push   $0x56
  800fef:	68 03 26 80 00       	push   $0x802603
  800ff4:	e8 85 0d 00 00       	call   801d7e <_panic>
            }
        }

        int r;

        if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE),
  800ff9:	83 ec 04             	sub    $0x4,%esp
  800ffc:	6a 07                	push   $0x7
  800ffe:	68 00 f0 bf ee       	push   $0xeebff000
  801003:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801006:	57                   	push   %edi
  801007:	e8 07 fc ff ff       	call   800c13 <sys_page_alloc>
  80100c:	83 c4 10             	add    $0x10,%esp
  80100f:	85 c0                	test   %eax,%eax
  801011:	78 2c                	js     80103f <fork+0x146>
                    PTE_U | PTE_W | PTE_P)) < 0) {
            return r;
        }

        if ((r = sys_env_set_pgfault_upcall(envid,
                        thisenv->env_pgfault_upcall)) < 0) {
  801013:	a1 04 40 80 00       	mov    0x804004,%eax
        if ((r = sys_env_set_pgfault_upcall(envid,
  801018:	8b 40 64             	mov    0x64(%eax),%eax
  80101b:	83 ec 08             	sub    $0x8,%esp
  80101e:	50                   	push   %eax
  80101f:	57                   	push   %edi
  801020:	e8 4d fd ff ff       	call   800d72 <sys_env_set_pgfault_upcall>
  801025:	83 c4 10             	add    $0x10,%esp
  801028:	85 c0                	test   %eax,%eax
  80102a:	78 13                	js     80103f <fork+0x146>
            return r;
        }

        if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  80102c:	83 ec 08             	sub    $0x8,%esp
  80102f:	6a 02                	push   $0x2
  801031:	57                   	push   %edi
  801032:	e8 af fc ff ff       	call   800ce6 <sys_env_set_status>
  801037:	83 c4 10             	add    $0x10,%esp
            return r;
        }
        return envid;
  80103a:	85 c0                	test   %eax,%eax
  80103c:	0f 49 c7             	cmovns %edi,%eax
    }

}
  80103f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801042:	5b                   	pop    %ebx
  801043:	5e                   	pop    %esi
  801044:	5f                   	pop    %edi
  801045:	5d                   	pop    %ebp
  801046:	c3                   	ret    

00801047 <sfork>:

// Challenge!
int
sfork(void)
{
  801047:	f3 0f 1e fb          	endbr32 
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801051:	68 8c 26 80 00       	push   $0x80268c
  801056:	68 a5 00 00 00       	push   $0xa5
  80105b:	68 03 26 80 00       	push   $0x802603
  801060:	e8 19 0d 00 00       	call   801d7e <_panic>

00801065 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801065:	f3 0f 1e fb          	endbr32 
  801069:	55                   	push   %ebp
  80106a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80106c:	8b 45 08             	mov    0x8(%ebp),%eax
  80106f:	05 00 00 00 30       	add    $0x30000000,%eax
  801074:	c1 e8 0c             	shr    $0xc,%eax
}
  801077:	5d                   	pop    %ebp
  801078:	c3                   	ret    

00801079 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801079:	f3 0f 1e fb          	endbr32 
  80107d:	55                   	push   %ebp
  80107e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801080:	8b 45 08             	mov    0x8(%ebp),%eax
  801083:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801088:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80108d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801092:	5d                   	pop    %ebp
  801093:	c3                   	ret    

00801094 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801094:	f3 0f 1e fb          	endbr32 
  801098:	55                   	push   %ebp
  801099:	89 e5                	mov    %esp,%ebp
  80109b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010a0:	89 c2                	mov    %eax,%edx
  8010a2:	c1 ea 16             	shr    $0x16,%edx
  8010a5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010ac:	f6 c2 01             	test   $0x1,%dl
  8010af:	74 2d                	je     8010de <fd_alloc+0x4a>
  8010b1:	89 c2                	mov    %eax,%edx
  8010b3:	c1 ea 0c             	shr    $0xc,%edx
  8010b6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010bd:	f6 c2 01             	test   $0x1,%dl
  8010c0:	74 1c                	je     8010de <fd_alloc+0x4a>
  8010c2:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8010c7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010cc:	75 d2                	jne    8010a0 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8010d7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8010dc:	eb 0a                	jmp    8010e8 <fd_alloc+0x54>
			*fd_store = fd;
  8010de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010e1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010e8:	5d                   	pop    %ebp
  8010e9:	c3                   	ret    

008010ea <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010ea:	f3 0f 1e fb          	endbr32 
  8010ee:	55                   	push   %ebp
  8010ef:	89 e5                	mov    %esp,%ebp
  8010f1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010f4:	83 f8 1f             	cmp    $0x1f,%eax
  8010f7:	77 30                	ja     801129 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010f9:	c1 e0 0c             	shl    $0xc,%eax
  8010fc:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801101:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801107:	f6 c2 01             	test   $0x1,%dl
  80110a:	74 24                	je     801130 <fd_lookup+0x46>
  80110c:	89 c2                	mov    %eax,%edx
  80110e:	c1 ea 0c             	shr    $0xc,%edx
  801111:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801118:	f6 c2 01             	test   $0x1,%dl
  80111b:	74 1a                	je     801137 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80111d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801120:	89 02                	mov    %eax,(%edx)
	return 0;
  801122:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801127:	5d                   	pop    %ebp
  801128:	c3                   	ret    
		return -E_INVAL;
  801129:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80112e:	eb f7                	jmp    801127 <fd_lookup+0x3d>
		return -E_INVAL;
  801130:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801135:	eb f0                	jmp    801127 <fd_lookup+0x3d>
  801137:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80113c:	eb e9                	jmp    801127 <fd_lookup+0x3d>

0080113e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80113e:	f3 0f 1e fb          	endbr32 
  801142:	55                   	push   %ebp
  801143:	89 e5                	mov    %esp,%ebp
  801145:	83 ec 08             	sub    $0x8,%esp
  801148:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80114b:	ba 40 27 80 00       	mov    $0x802740,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801150:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  801155:	39 08                	cmp    %ecx,(%eax)
  801157:	74 33                	je     80118c <dev_lookup+0x4e>
  801159:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80115c:	8b 02                	mov    (%edx),%eax
  80115e:	85 c0                	test   %eax,%eax
  801160:	75 f3                	jne    801155 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801162:	a1 04 40 80 00       	mov    0x804004,%eax
  801167:	8b 40 48             	mov    0x48(%eax),%eax
  80116a:	83 ec 04             	sub    $0x4,%esp
  80116d:	51                   	push   %ecx
  80116e:	50                   	push   %eax
  80116f:	68 c4 26 80 00       	push   $0x8026c4
  801174:	e8 4f f0 ff ff       	call   8001c8 <cprintf>
	*dev = 0;
  801179:	8b 45 0c             	mov    0xc(%ebp),%eax
  80117c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801182:	83 c4 10             	add    $0x10,%esp
  801185:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80118a:	c9                   	leave  
  80118b:	c3                   	ret    
			*dev = devtab[i];
  80118c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80118f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801191:	b8 00 00 00 00       	mov    $0x0,%eax
  801196:	eb f2                	jmp    80118a <dev_lookup+0x4c>

00801198 <fd_close>:
{
  801198:	f3 0f 1e fb          	endbr32 
  80119c:	55                   	push   %ebp
  80119d:	89 e5                	mov    %esp,%ebp
  80119f:	57                   	push   %edi
  8011a0:	56                   	push   %esi
  8011a1:	53                   	push   %ebx
  8011a2:	83 ec 24             	sub    $0x24,%esp
  8011a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8011a8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011ab:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011ae:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011af:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011b5:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011b8:	50                   	push   %eax
  8011b9:	e8 2c ff ff ff       	call   8010ea <fd_lookup>
  8011be:	89 c3                	mov    %eax,%ebx
  8011c0:	83 c4 10             	add    $0x10,%esp
  8011c3:	85 c0                	test   %eax,%eax
  8011c5:	78 05                	js     8011cc <fd_close+0x34>
	    || fd != fd2)
  8011c7:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8011ca:	74 16                	je     8011e2 <fd_close+0x4a>
		return (must_exist ? r : 0);
  8011cc:	89 f8                	mov    %edi,%eax
  8011ce:	84 c0                	test   %al,%al
  8011d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d5:	0f 44 d8             	cmove  %eax,%ebx
}
  8011d8:	89 d8                	mov    %ebx,%eax
  8011da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011dd:	5b                   	pop    %ebx
  8011de:	5e                   	pop    %esi
  8011df:	5f                   	pop    %edi
  8011e0:	5d                   	pop    %ebp
  8011e1:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011e2:	83 ec 08             	sub    $0x8,%esp
  8011e5:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8011e8:	50                   	push   %eax
  8011e9:	ff 36                	pushl  (%esi)
  8011eb:	e8 4e ff ff ff       	call   80113e <dev_lookup>
  8011f0:	89 c3                	mov    %eax,%ebx
  8011f2:	83 c4 10             	add    $0x10,%esp
  8011f5:	85 c0                	test   %eax,%eax
  8011f7:	78 1a                	js     801213 <fd_close+0x7b>
		if (dev->dev_close)
  8011f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011fc:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8011ff:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801204:	85 c0                	test   %eax,%eax
  801206:	74 0b                	je     801213 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  801208:	83 ec 0c             	sub    $0xc,%esp
  80120b:	56                   	push   %esi
  80120c:	ff d0                	call   *%eax
  80120e:	89 c3                	mov    %eax,%ebx
  801210:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801213:	83 ec 08             	sub    $0x8,%esp
  801216:	56                   	push   %esi
  801217:	6a 00                	push   $0x0
  801219:	e8 82 fa ff ff       	call   800ca0 <sys_page_unmap>
	return r;
  80121e:	83 c4 10             	add    $0x10,%esp
  801221:	eb b5                	jmp    8011d8 <fd_close+0x40>

00801223 <close>:

int
close(int fdnum)
{
  801223:	f3 0f 1e fb          	endbr32 
  801227:	55                   	push   %ebp
  801228:	89 e5                	mov    %esp,%ebp
  80122a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80122d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801230:	50                   	push   %eax
  801231:	ff 75 08             	pushl  0x8(%ebp)
  801234:	e8 b1 fe ff ff       	call   8010ea <fd_lookup>
  801239:	83 c4 10             	add    $0x10,%esp
  80123c:	85 c0                	test   %eax,%eax
  80123e:	79 02                	jns    801242 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801240:	c9                   	leave  
  801241:	c3                   	ret    
		return fd_close(fd, 1);
  801242:	83 ec 08             	sub    $0x8,%esp
  801245:	6a 01                	push   $0x1
  801247:	ff 75 f4             	pushl  -0xc(%ebp)
  80124a:	e8 49 ff ff ff       	call   801198 <fd_close>
  80124f:	83 c4 10             	add    $0x10,%esp
  801252:	eb ec                	jmp    801240 <close+0x1d>

00801254 <close_all>:

void
close_all(void)
{
  801254:	f3 0f 1e fb          	endbr32 
  801258:	55                   	push   %ebp
  801259:	89 e5                	mov    %esp,%ebp
  80125b:	53                   	push   %ebx
  80125c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80125f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801264:	83 ec 0c             	sub    $0xc,%esp
  801267:	53                   	push   %ebx
  801268:	e8 b6 ff ff ff       	call   801223 <close>
	for (i = 0; i < MAXFD; i++)
  80126d:	83 c3 01             	add    $0x1,%ebx
  801270:	83 c4 10             	add    $0x10,%esp
  801273:	83 fb 20             	cmp    $0x20,%ebx
  801276:	75 ec                	jne    801264 <close_all+0x10>
}
  801278:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80127b:	c9                   	leave  
  80127c:	c3                   	ret    

0080127d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80127d:	f3 0f 1e fb          	endbr32 
  801281:	55                   	push   %ebp
  801282:	89 e5                	mov    %esp,%ebp
  801284:	57                   	push   %edi
  801285:	56                   	push   %esi
  801286:	53                   	push   %ebx
  801287:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80128a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80128d:	50                   	push   %eax
  80128e:	ff 75 08             	pushl  0x8(%ebp)
  801291:	e8 54 fe ff ff       	call   8010ea <fd_lookup>
  801296:	89 c3                	mov    %eax,%ebx
  801298:	83 c4 10             	add    $0x10,%esp
  80129b:	85 c0                	test   %eax,%eax
  80129d:	0f 88 81 00 00 00    	js     801324 <dup+0xa7>
		return r;
	close(newfdnum);
  8012a3:	83 ec 0c             	sub    $0xc,%esp
  8012a6:	ff 75 0c             	pushl  0xc(%ebp)
  8012a9:	e8 75 ff ff ff       	call   801223 <close>

	newfd = INDEX2FD(newfdnum);
  8012ae:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012b1:	c1 e6 0c             	shl    $0xc,%esi
  8012b4:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8012ba:	83 c4 04             	add    $0x4,%esp
  8012bd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012c0:	e8 b4 fd ff ff       	call   801079 <fd2data>
  8012c5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8012c7:	89 34 24             	mov    %esi,(%esp)
  8012ca:	e8 aa fd ff ff       	call   801079 <fd2data>
  8012cf:	83 c4 10             	add    $0x10,%esp
  8012d2:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012d4:	89 d8                	mov    %ebx,%eax
  8012d6:	c1 e8 16             	shr    $0x16,%eax
  8012d9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012e0:	a8 01                	test   $0x1,%al
  8012e2:	74 11                	je     8012f5 <dup+0x78>
  8012e4:	89 d8                	mov    %ebx,%eax
  8012e6:	c1 e8 0c             	shr    $0xc,%eax
  8012e9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012f0:	f6 c2 01             	test   $0x1,%dl
  8012f3:	75 39                	jne    80132e <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012f5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012f8:	89 d0                	mov    %edx,%eax
  8012fa:	c1 e8 0c             	shr    $0xc,%eax
  8012fd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801304:	83 ec 0c             	sub    $0xc,%esp
  801307:	25 07 0e 00 00       	and    $0xe07,%eax
  80130c:	50                   	push   %eax
  80130d:	56                   	push   %esi
  80130e:	6a 00                	push   $0x0
  801310:	52                   	push   %edx
  801311:	6a 00                	push   $0x0
  801313:	e8 42 f9 ff ff       	call   800c5a <sys_page_map>
  801318:	89 c3                	mov    %eax,%ebx
  80131a:	83 c4 20             	add    $0x20,%esp
  80131d:	85 c0                	test   %eax,%eax
  80131f:	78 31                	js     801352 <dup+0xd5>
		goto err;

	return newfdnum;
  801321:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801324:	89 d8                	mov    %ebx,%eax
  801326:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801329:	5b                   	pop    %ebx
  80132a:	5e                   	pop    %esi
  80132b:	5f                   	pop    %edi
  80132c:	5d                   	pop    %ebp
  80132d:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80132e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801335:	83 ec 0c             	sub    $0xc,%esp
  801338:	25 07 0e 00 00       	and    $0xe07,%eax
  80133d:	50                   	push   %eax
  80133e:	57                   	push   %edi
  80133f:	6a 00                	push   $0x0
  801341:	53                   	push   %ebx
  801342:	6a 00                	push   $0x0
  801344:	e8 11 f9 ff ff       	call   800c5a <sys_page_map>
  801349:	89 c3                	mov    %eax,%ebx
  80134b:	83 c4 20             	add    $0x20,%esp
  80134e:	85 c0                	test   %eax,%eax
  801350:	79 a3                	jns    8012f5 <dup+0x78>
	sys_page_unmap(0, newfd);
  801352:	83 ec 08             	sub    $0x8,%esp
  801355:	56                   	push   %esi
  801356:	6a 00                	push   $0x0
  801358:	e8 43 f9 ff ff       	call   800ca0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80135d:	83 c4 08             	add    $0x8,%esp
  801360:	57                   	push   %edi
  801361:	6a 00                	push   $0x0
  801363:	e8 38 f9 ff ff       	call   800ca0 <sys_page_unmap>
	return r;
  801368:	83 c4 10             	add    $0x10,%esp
  80136b:	eb b7                	jmp    801324 <dup+0xa7>

0080136d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80136d:	f3 0f 1e fb          	endbr32 
  801371:	55                   	push   %ebp
  801372:	89 e5                	mov    %esp,%ebp
  801374:	53                   	push   %ebx
  801375:	83 ec 1c             	sub    $0x1c,%esp
  801378:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80137b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80137e:	50                   	push   %eax
  80137f:	53                   	push   %ebx
  801380:	e8 65 fd ff ff       	call   8010ea <fd_lookup>
  801385:	83 c4 10             	add    $0x10,%esp
  801388:	85 c0                	test   %eax,%eax
  80138a:	78 3f                	js     8013cb <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80138c:	83 ec 08             	sub    $0x8,%esp
  80138f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801392:	50                   	push   %eax
  801393:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801396:	ff 30                	pushl  (%eax)
  801398:	e8 a1 fd ff ff       	call   80113e <dev_lookup>
  80139d:	83 c4 10             	add    $0x10,%esp
  8013a0:	85 c0                	test   %eax,%eax
  8013a2:	78 27                	js     8013cb <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013a7:	8b 42 08             	mov    0x8(%edx),%eax
  8013aa:	83 e0 03             	and    $0x3,%eax
  8013ad:	83 f8 01             	cmp    $0x1,%eax
  8013b0:	74 1e                	je     8013d0 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8013b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b5:	8b 40 08             	mov    0x8(%eax),%eax
  8013b8:	85 c0                	test   %eax,%eax
  8013ba:	74 35                	je     8013f1 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013bc:	83 ec 04             	sub    $0x4,%esp
  8013bf:	ff 75 10             	pushl  0x10(%ebp)
  8013c2:	ff 75 0c             	pushl  0xc(%ebp)
  8013c5:	52                   	push   %edx
  8013c6:	ff d0                	call   *%eax
  8013c8:	83 c4 10             	add    $0x10,%esp
}
  8013cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ce:	c9                   	leave  
  8013cf:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013d0:	a1 04 40 80 00       	mov    0x804004,%eax
  8013d5:	8b 40 48             	mov    0x48(%eax),%eax
  8013d8:	83 ec 04             	sub    $0x4,%esp
  8013db:	53                   	push   %ebx
  8013dc:	50                   	push   %eax
  8013dd:	68 05 27 80 00       	push   $0x802705
  8013e2:	e8 e1 ed ff ff       	call   8001c8 <cprintf>
		return -E_INVAL;
  8013e7:	83 c4 10             	add    $0x10,%esp
  8013ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013ef:	eb da                	jmp    8013cb <read+0x5e>
		return -E_NOT_SUPP;
  8013f1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013f6:	eb d3                	jmp    8013cb <read+0x5e>

008013f8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013f8:	f3 0f 1e fb          	endbr32 
  8013fc:	55                   	push   %ebp
  8013fd:	89 e5                	mov    %esp,%ebp
  8013ff:	57                   	push   %edi
  801400:	56                   	push   %esi
  801401:	53                   	push   %ebx
  801402:	83 ec 0c             	sub    $0xc,%esp
  801405:	8b 7d 08             	mov    0x8(%ebp),%edi
  801408:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80140b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801410:	eb 02                	jmp    801414 <readn+0x1c>
  801412:	01 c3                	add    %eax,%ebx
  801414:	39 f3                	cmp    %esi,%ebx
  801416:	73 21                	jae    801439 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801418:	83 ec 04             	sub    $0x4,%esp
  80141b:	89 f0                	mov    %esi,%eax
  80141d:	29 d8                	sub    %ebx,%eax
  80141f:	50                   	push   %eax
  801420:	89 d8                	mov    %ebx,%eax
  801422:	03 45 0c             	add    0xc(%ebp),%eax
  801425:	50                   	push   %eax
  801426:	57                   	push   %edi
  801427:	e8 41 ff ff ff       	call   80136d <read>
		if (m < 0)
  80142c:	83 c4 10             	add    $0x10,%esp
  80142f:	85 c0                	test   %eax,%eax
  801431:	78 04                	js     801437 <readn+0x3f>
			return m;
		if (m == 0)
  801433:	75 dd                	jne    801412 <readn+0x1a>
  801435:	eb 02                	jmp    801439 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801437:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801439:	89 d8                	mov    %ebx,%eax
  80143b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80143e:	5b                   	pop    %ebx
  80143f:	5e                   	pop    %esi
  801440:	5f                   	pop    %edi
  801441:	5d                   	pop    %ebp
  801442:	c3                   	ret    

00801443 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801443:	f3 0f 1e fb          	endbr32 
  801447:	55                   	push   %ebp
  801448:	89 e5                	mov    %esp,%ebp
  80144a:	53                   	push   %ebx
  80144b:	83 ec 1c             	sub    $0x1c,%esp
  80144e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801451:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801454:	50                   	push   %eax
  801455:	53                   	push   %ebx
  801456:	e8 8f fc ff ff       	call   8010ea <fd_lookup>
  80145b:	83 c4 10             	add    $0x10,%esp
  80145e:	85 c0                	test   %eax,%eax
  801460:	78 3a                	js     80149c <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801462:	83 ec 08             	sub    $0x8,%esp
  801465:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801468:	50                   	push   %eax
  801469:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80146c:	ff 30                	pushl  (%eax)
  80146e:	e8 cb fc ff ff       	call   80113e <dev_lookup>
  801473:	83 c4 10             	add    $0x10,%esp
  801476:	85 c0                	test   %eax,%eax
  801478:	78 22                	js     80149c <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80147a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80147d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801481:	74 1e                	je     8014a1 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801483:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801486:	8b 52 0c             	mov    0xc(%edx),%edx
  801489:	85 d2                	test   %edx,%edx
  80148b:	74 35                	je     8014c2 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80148d:	83 ec 04             	sub    $0x4,%esp
  801490:	ff 75 10             	pushl  0x10(%ebp)
  801493:	ff 75 0c             	pushl  0xc(%ebp)
  801496:	50                   	push   %eax
  801497:	ff d2                	call   *%edx
  801499:	83 c4 10             	add    $0x10,%esp
}
  80149c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80149f:	c9                   	leave  
  8014a0:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014a1:	a1 04 40 80 00       	mov    0x804004,%eax
  8014a6:	8b 40 48             	mov    0x48(%eax),%eax
  8014a9:	83 ec 04             	sub    $0x4,%esp
  8014ac:	53                   	push   %ebx
  8014ad:	50                   	push   %eax
  8014ae:	68 21 27 80 00       	push   $0x802721
  8014b3:	e8 10 ed ff ff       	call   8001c8 <cprintf>
		return -E_INVAL;
  8014b8:	83 c4 10             	add    $0x10,%esp
  8014bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014c0:	eb da                	jmp    80149c <write+0x59>
		return -E_NOT_SUPP;
  8014c2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014c7:	eb d3                	jmp    80149c <write+0x59>

008014c9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014c9:	f3 0f 1e fb          	endbr32 
  8014cd:	55                   	push   %ebp
  8014ce:	89 e5                	mov    %esp,%ebp
  8014d0:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d6:	50                   	push   %eax
  8014d7:	ff 75 08             	pushl  0x8(%ebp)
  8014da:	e8 0b fc ff ff       	call   8010ea <fd_lookup>
  8014df:	83 c4 10             	add    $0x10,%esp
  8014e2:	85 c0                	test   %eax,%eax
  8014e4:	78 0e                	js     8014f4 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8014e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ec:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014f4:	c9                   	leave  
  8014f5:	c3                   	ret    

008014f6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014f6:	f3 0f 1e fb          	endbr32 
  8014fa:	55                   	push   %ebp
  8014fb:	89 e5                	mov    %esp,%ebp
  8014fd:	53                   	push   %ebx
  8014fe:	83 ec 1c             	sub    $0x1c,%esp
  801501:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801504:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801507:	50                   	push   %eax
  801508:	53                   	push   %ebx
  801509:	e8 dc fb ff ff       	call   8010ea <fd_lookup>
  80150e:	83 c4 10             	add    $0x10,%esp
  801511:	85 c0                	test   %eax,%eax
  801513:	78 37                	js     80154c <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801515:	83 ec 08             	sub    $0x8,%esp
  801518:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151b:	50                   	push   %eax
  80151c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151f:	ff 30                	pushl  (%eax)
  801521:	e8 18 fc ff ff       	call   80113e <dev_lookup>
  801526:	83 c4 10             	add    $0x10,%esp
  801529:	85 c0                	test   %eax,%eax
  80152b:	78 1f                	js     80154c <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80152d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801530:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801534:	74 1b                	je     801551 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801536:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801539:	8b 52 18             	mov    0x18(%edx),%edx
  80153c:	85 d2                	test   %edx,%edx
  80153e:	74 32                	je     801572 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801540:	83 ec 08             	sub    $0x8,%esp
  801543:	ff 75 0c             	pushl  0xc(%ebp)
  801546:	50                   	push   %eax
  801547:	ff d2                	call   *%edx
  801549:	83 c4 10             	add    $0x10,%esp
}
  80154c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80154f:	c9                   	leave  
  801550:	c3                   	ret    
			thisenv->env_id, fdnum);
  801551:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801556:	8b 40 48             	mov    0x48(%eax),%eax
  801559:	83 ec 04             	sub    $0x4,%esp
  80155c:	53                   	push   %ebx
  80155d:	50                   	push   %eax
  80155e:	68 e4 26 80 00       	push   $0x8026e4
  801563:	e8 60 ec ff ff       	call   8001c8 <cprintf>
		return -E_INVAL;
  801568:	83 c4 10             	add    $0x10,%esp
  80156b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801570:	eb da                	jmp    80154c <ftruncate+0x56>
		return -E_NOT_SUPP;
  801572:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801577:	eb d3                	jmp    80154c <ftruncate+0x56>

00801579 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801579:	f3 0f 1e fb          	endbr32 
  80157d:	55                   	push   %ebp
  80157e:	89 e5                	mov    %esp,%ebp
  801580:	53                   	push   %ebx
  801581:	83 ec 1c             	sub    $0x1c,%esp
  801584:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801587:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80158a:	50                   	push   %eax
  80158b:	ff 75 08             	pushl  0x8(%ebp)
  80158e:	e8 57 fb ff ff       	call   8010ea <fd_lookup>
  801593:	83 c4 10             	add    $0x10,%esp
  801596:	85 c0                	test   %eax,%eax
  801598:	78 4b                	js     8015e5 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80159a:	83 ec 08             	sub    $0x8,%esp
  80159d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a0:	50                   	push   %eax
  8015a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a4:	ff 30                	pushl  (%eax)
  8015a6:	e8 93 fb ff ff       	call   80113e <dev_lookup>
  8015ab:	83 c4 10             	add    $0x10,%esp
  8015ae:	85 c0                	test   %eax,%eax
  8015b0:	78 33                	js     8015e5 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8015b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015b9:	74 2f                	je     8015ea <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015bb:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015be:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015c5:	00 00 00 
	stat->st_isdir = 0;
  8015c8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015cf:	00 00 00 
	stat->st_dev = dev;
  8015d2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015d8:	83 ec 08             	sub    $0x8,%esp
  8015db:	53                   	push   %ebx
  8015dc:	ff 75 f0             	pushl  -0x10(%ebp)
  8015df:	ff 50 14             	call   *0x14(%eax)
  8015e2:	83 c4 10             	add    $0x10,%esp
}
  8015e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e8:	c9                   	leave  
  8015e9:	c3                   	ret    
		return -E_NOT_SUPP;
  8015ea:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015ef:	eb f4                	jmp    8015e5 <fstat+0x6c>

008015f1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015f1:	f3 0f 1e fb          	endbr32 
  8015f5:	55                   	push   %ebp
  8015f6:	89 e5                	mov    %esp,%ebp
  8015f8:	56                   	push   %esi
  8015f9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015fa:	83 ec 08             	sub    $0x8,%esp
  8015fd:	6a 00                	push   $0x0
  8015ff:	ff 75 08             	pushl  0x8(%ebp)
  801602:	e8 cf 01 00 00       	call   8017d6 <open>
  801607:	89 c3                	mov    %eax,%ebx
  801609:	83 c4 10             	add    $0x10,%esp
  80160c:	85 c0                	test   %eax,%eax
  80160e:	78 1b                	js     80162b <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801610:	83 ec 08             	sub    $0x8,%esp
  801613:	ff 75 0c             	pushl  0xc(%ebp)
  801616:	50                   	push   %eax
  801617:	e8 5d ff ff ff       	call   801579 <fstat>
  80161c:	89 c6                	mov    %eax,%esi
	close(fd);
  80161e:	89 1c 24             	mov    %ebx,(%esp)
  801621:	e8 fd fb ff ff       	call   801223 <close>
	return r;
  801626:	83 c4 10             	add    $0x10,%esp
  801629:	89 f3                	mov    %esi,%ebx
}
  80162b:	89 d8                	mov    %ebx,%eax
  80162d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801630:	5b                   	pop    %ebx
  801631:	5e                   	pop    %esi
  801632:	5d                   	pop    %ebp
  801633:	c3                   	ret    

00801634 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801634:	55                   	push   %ebp
  801635:	89 e5                	mov    %esp,%ebp
  801637:	56                   	push   %esi
  801638:	53                   	push   %ebx
  801639:	89 c6                	mov    %eax,%esi
  80163b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80163d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801644:	74 27                	je     80166d <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801646:	6a 07                	push   $0x7
  801648:	68 00 50 80 00       	push   $0x805000
  80164d:	56                   	push   %esi
  80164e:	ff 35 00 40 80 00    	pushl  0x804000
  801654:	e8 6c 08 00 00       	call   801ec5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801659:	83 c4 0c             	add    $0xc,%esp
  80165c:	6a 00                	push   $0x0
  80165e:	53                   	push   %ebx
  80165f:	6a 00                	push   $0x0
  801661:	e8 08 08 00 00       	call   801e6e <ipc_recv>
}
  801666:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801669:	5b                   	pop    %ebx
  80166a:	5e                   	pop    %esi
  80166b:	5d                   	pop    %ebp
  80166c:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80166d:	83 ec 0c             	sub    $0xc,%esp
  801670:	6a 01                	push   $0x1
  801672:	e8 b4 08 00 00       	call   801f2b <ipc_find_env>
  801677:	a3 00 40 80 00       	mov    %eax,0x804000
  80167c:	83 c4 10             	add    $0x10,%esp
  80167f:	eb c5                	jmp    801646 <fsipc+0x12>

00801681 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801681:	f3 0f 1e fb          	endbr32 
  801685:	55                   	push   %ebp
  801686:	89 e5                	mov    %esp,%ebp
  801688:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80168b:	8b 45 08             	mov    0x8(%ebp),%eax
  80168e:	8b 40 0c             	mov    0xc(%eax),%eax
  801691:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801696:	8b 45 0c             	mov    0xc(%ebp),%eax
  801699:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80169e:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a3:	b8 02 00 00 00       	mov    $0x2,%eax
  8016a8:	e8 87 ff ff ff       	call   801634 <fsipc>
}
  8016ad:	c9                   	leave  
  8016ae:	c3                   	ret    

008016af <devfile_flush>:
{
  8016af:	f3 0f 1e fb          	endbr32 
  8016b3:	55                   	push   %ebp
  8016b4:	89 e5                	mov    %esp,%ebp
  8016b6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bc:	8b 40 0c             	mov    0xc(%eax),%eax
  8016bf:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c9:	b8 06 00 00 00       	mov    $0x6,%eax
  8016ce:	e8 61 ff ff ff       	call   801634 <fsipc>
}
  8016d3:	c9                   	leave  
  8016d4:	c3                   	ret    

008016d5 <devfile_stat>:
{
  8016d5:	f3 0f 1e fb          	endbr32 
  8016d9:	55                   	push   %ebp
  8016da:	89 e5                	mov    %esp,%ebp
  8016dc:	53                   	push   %ebx
  8016dd:	83 ec 04             	sub    $0x4,%esp
  8016e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e6:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f3:	b8 05 00 00 00       	mov    $0x5,%eax
  8016f8:	e8 37 ff ff ff       	call   801634 <fsipc>
  8016fd:	85 c0                	test   %eax,%eax
  8016ff:	78 2c                	js     80172d <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801701:	83 ec 08             	sub    $0x8,%esp
  801704:	68 00 50 80 00       	push   $0x805000
  801709:	53                   	push   %ebx
  80170a:	e8 c2 f0 ff ff       	call   8007d1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80170f:	a1 80 50 80 00       	mov    0x805080,%eax
  801714:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80171a:	a1 84 50 80 00       	mov    0x805084,%eax
  80171f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801725:	83 c4 10             	add    $0x10,%esp
  801728:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80172d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801730:	c9                   	leave  
  801731:	c3                   	ret    

00801732 <devfile_write>:
{
  801732:	f3 0f 1e fb          	endbr32 
  801736:	55                   	push   %ebp
  801737:	89 e5                	mov    %esp,%ebp
  801739:	83 ec 0c             	sub    $0xc,%esp
	panic("devfile_write not implemented");
  80173c:	68 50 27 80 00       	push   $0x802750
  801741:	68 90 00 00 00       	push   $0x90
  801746:	68 6e 27 80 00       	push   $0x80276e
  80174b:	e8 2e 06 00 00       	call   801d7e <_panic>

00801750 <devfile_read>:
{
  801750:	f3 0f 1e fb          	endbr32 
  801754:	55                   	push   %ebp
  801755:	89 e5                	mov    %esp,%ebp
  801757:	56                   	push   %esi
  801758:	53                   	push   %ebx
  801759:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80175c:	8b 45 08             	mov    0x8(%ebp),%eax
  80175f:	8b 40 0c             	mov    0xc(%eax),%eax
  801762:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801767:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80176d:	ba 00 00 00 00       	mov    $0x0,%edx
  801772:	b8 03 00 00 00       	mov    $0x3,%eax
  801777:	e8 b8 fe ff ff       	call   801634 <fsipc>
  80177c:	89 c3                	mov    %eax,%ebx
  80177e:	85 c0                	test   %eax,%eax
  801780:	78 1f                	js     8017a1 <devfile_read+0x51>
	assert(r <= n);
  801782:	39 f0                	cmp    %esi,%eax
  801784:	77 24                	ja     8017aa <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801786:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80178b:	7f 33                	jg     8017c0 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80178d:	83 ec 04             	sub    $0x4,%esp
  801790:	50                   	push   %eax
  801791:	68 00 50 80 00       	push   $0x805000
  801796:	ff 75 0c             	pushl  0xc(%ebp)
  801799:	e8 e9 f1 ff ff       	call   800987 <memmove>
	return r;
  80179e:	83 c4 10             	add    $0x10,%esp
}
  8017a1:	89 d8                	mov    %ebx,%eax
  8017a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017a6:	5b                   	pop    %ebx
  8017a7:	5e                   	pop    %esi
  8017a8:	5d                   	pop    %ebp
  8017a9:	c3                   	ret    
	assert(r <= n);
  8017aa:	68 79 27 80 00       	push   $0x802779
  8017af:	68 80 27 80 00       	push   $0x802780
  8017b4:	6a 7c                	push   $0x7c
  8017b6:	68 6e 27 80 00       	push   $0x80276e
  8017bb:	e8 be 05 00 00       	call   801d7e <_panic>
	assert(r <= PGSIZE);
  8017c0:	68 95 27 80 00       	push   $0x802795
  8017c5:	68 80 27 80 00       	push   $0x802780
  8017ca:	6a 7d                	push   $0x7d
  8017cc:	68 6e 27 80 00       	push   $0x80276e
  8017d1:	e8 a8 05 00 00       	call   801d7e <_panic>

008017d6 <open>:
{
  8017d6:	f3 0f 1e fb          	endbr32 
  8017da:	55                   	push   %ebp
  8017db:	89 e5                	mov    %esp,%ebp
  8017dd:	56                   	push   %esi
  8017de:	53                   	push   %ebx
  8017df:	83 ec 1c             	sub    $0x1c,%esp
  8017e2:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8017e5:	56                   	push   %esi
  8017e6:	e8 a3 ef ff ff       	call   80078e <strlen>
  8017eb:	83 c4 10             	add    $0x10,%esp
  8017ee:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017f3:	7f 6c                	jg     801861 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  8017f5:	83 ec 0c             	sub    $0xc,%esp
  8017f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017fb:	50                   	push   %eax
  8017fc:	e8 93 f8 ff ff       	call   801094 <fd_alloc>
  801801:	89 c3                	mov    %eax,%ebx
  801803:	83 c4 10             	add    $0x10,%esp
  801806:	85 c0                	test   %eax,%eax
  801808:	78 3c                	js     801846 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  80180a:	83 ec 08             	sub    $0x8,%esp
  80180d:	56                   	push   %esi
  80180e:	68 00 50 80 00       	push   $0x805000
  801813:	e8 b9 ef ff ff       	call   8007d1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801818:	8b 45 0c             	mov    0xc(%ebp),%eax
  80181b:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801820:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801823:	b8 01 00 00 00       	mov    $0x1,%eax
  801828:	e8 07 fe ff ff       	call   801634 <fsipc>
  80182d:	89 c3                	mov    %eax,%ebx
  80182f:	83 c4 10             	add    $0x10,%esp
  801832:	85 c0                	test   %eax,%eax
  801834:	78 19                	js     80184f <open+0x79>
	return fd2num(fd);
  801836:	83 ec 0c             	sub    $0xc,%esp
  801839:	ff 75 f4             	pushl  -0xc(%ebp)
  80183c:	e8 24 f8 ff ff       	call   801065 <fd2num>
  801841:	89 c3                	mov    %eax,%ebx
  801843:	83 c4 10             	add    $0x10,%esp
}
  801846:	89 d8                	mov    %ebx,%eax
  801848:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80184b:	5b                   	pop    %ebx
  80184c:	5e                   	pop    %esi
  80184d:	5d                   	pop    %ebp
  80184e:	c3                   	ret    
		fd_close(fd, 0);
  80184f:	83 ec 08             	sub    $0x8,%esp
  801852:	6a 00                	push   $0x0
  801854:	ff 75 f4             	pushl  -0xc(%ebp)
  801857:	e8 3c f9 ff ff       	call   801198 <fd_close>
		return r;
  80185c:	83 c4 10             	add    $0x10,%esp
  80185f:	eb e5                	jmp    801846 <open+0x70>
		return -E_BAD_PATH;
  801861:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801866:	eb de                	jmp    801846 <open+0x70>

00801868 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801868:	f3 0f 1e fb          	endbr32 
  80186c:	55                   	push   %ebp
  80186d:	89 e5                	mov    %esp,%ebp
  80186f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801872:	ba 00 00 00 00       	mov    $0x0,%edx
  801877:	b8 08 00 00 00       	mov    $0x8,%eax
  80187c:	e8 b3 fd ff ff       	call   801634 <fsipc>
}
  801881:	c9                   	leave  
  801882:	c3                   	ret    

00801883 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801883:	f3 0f 1e fb          	endbr32 
  801887:	55                   	push   %ebp
  801888:	89 e5                	mov    %esp,%ebp
  80188a:	56                   	push   %esi
  80188b:	53                   	push   %ebx
  80188c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80188f:	83 ec 0c             	sub    $0xc,%esp
  801892:	ff 75 08             	pushl  0x8(%ebp)
  801895:	e8 df f7 ff ff       	call   801079 <fd2data>
  80189a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80189c:	83 c4 08             	add    $0x8,%esp
  80189f:	68 a1 27 80 00       	push   $0x8027a1
  8018a4:	53                   	push   %ebx
  8018a5:	e8 27 ef ff ff       	call   8007d1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018aa:	8b 46 04             	mov    0x4(%esi),%eax
  8018ad:	2b 06                	sub    (%esi),%eax
  8018af:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018b5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018bc:	00 00 00 
	stat->st_dev = &devpipe;
  8018bf:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018c6:	30 80 00 
	return 0;
}
  8018c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d1:	5b                   	pop    %ebx
  8018d2:	5e                   	pop    %esi
  8018d3:	5d                   	pop    %ebp
  8018d4:	c3                   	ret    

008018d5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018d5:	f3 0f 1e fb          	endbr32 
  8018d9:	55                   	push   %ebp
  8018da:	89 e5                	mov    %esp,%ebp
  8018dc:	53                   	push   %ebx
  8018dd:	83 ec 0c             	sub    $0xc,%esp
  8018e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018e3:	53                   	push   %ebx
  8018e4:	6a 00                	push   $0x0
  8018e6:	e8 b5 f3 ff ff       	call   800ca0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018eb:	89 1c 24             	mov    %ebx,(%esp)
  8018ee:	e8 86 f7 ff ff       	call   801079 <fd2data>
  8018f3:	83 c4 08             	add    $0x8,%esp
  8018f6:	50                   	push   %eax
  8018f7:	6a 00                	push   $0x0
  8018f9:	e8 a2 f3 ff ff       	call   800ca0 <sys_page_unmap>
}
  8018fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801901:	c9                   	leave  
  801902:	c3                   	ret    

00801903 <_pipeisclosed>:
{
  801903:	55                   	push   %ebp
  801904:	89 e5                	mov    %esp,%ebp
  801906:	57                   	push   %edi
  801907:	56                   	push   %esi
  801908:	53                   	push   %ebx
  801909:	83 ec 1c             	sub    $0x1c,%esp
  80190c:	89 c7                	mov    %eax,%edi
  80190e:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801910:	a1 04 40 80 00       	mov    0x804004,%eax
  801915:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801918:	83 ec 0c             	sub    $0xc,%esp
  80191b:	57                   	push   %edi
  80191c:	e8 47 06 00 00       	call   801f68 <pageref>
  801921:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801924:	89 34 24             	mov    %esi,(%esp)
  801927:	e8 3c 06 00 00       	call   801f68 <pageref>
		nn = thisenv->env_runs;
  80192c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801932:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801935:	83 c4 10             	add    $0x10,%esp
  801938:	39 cb                	cmp    %ecx,%ebx
  80193a:	74 1b                	je     801957 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  80193c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80193f:	75 cf                	jne    801910 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801941:	8b 42 58             	mov    0x58(%edx),%eax
  801944:	6a 01                	push   $0x1
  801946:	50                   	push   %eax
  801947:	53                   	push   %ebx
  801948:	68 a8 27 80 00       	push   $0x8027a8
  80194d:	e8 76 e8 ff ff       	call   8001c8 <cprintf>
  801952:	83 c4 10             	add    $0x10,%esp
  801955:	eb b9                	jmp    801910 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801957:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80195a:	0f 94 c0             	sete   %al
  80195d:	0f b6 c0             	movzbl %al,%eax
}
  801960:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801963:	5b                   	pop    %ebx
  801964:	5e                   	pop    %esi
  801965:	5f                   	pop    %edi
  801966:	5d                   	pop    %ebp
  801967:	c3                   	ret    

00801968 <devpipe_write>:
{
  801968:	f3 0f 1e fb          	endbr32 
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	57                   	push   %edi
  801970:	56                   	push   %esi
  801971:	53                   	push   %ebx
  801972:	83 ec 28             	sub    $0x28,%esp
  801975:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801978:	56                   	push   %esi
  801979:	e8 fb f6 ff ff       	call   801079 <fd2data>
  80197e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801980:	83 c4 10             	add    $0x10,%esp
  801983:	bf 00 00 00 00       	mov    $0x0,%edi
  801988:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80198b:	74 4f                	je     8019dc <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80198d:	8b 43 04             	mov    0x4(%ebx),%eax
  801990:	8b 0b                	mov    (%ebx),%ecx
  801992:	8d 51 20             	lea    0x20(%ecx),%edx
  801995:	39 d0                	cmp    %edx,%eax
  801997:	72 14                	jb     8019ad <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801999:	89 da                	mov    %ebx,%edx
  80199b:	89 f0                	mov    %esi,%eax
  80199d:	e8 61 ff ff ff       	call   801903 <_pipeisclosed>
  8019a2:	85 c0                	test   %eax,%eax
  8019a4:	75 3b                	jne    8019e1 <devpipe_write+0x79>
			sys_yield();
  8019a6:	e8 45 f2 ff ff       	call   800bf0 <sys_yield>
  8019ab:	eb e0                	jmp    80198d <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019b0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019b4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019b7:	89 c2                	mov    %eax,%edx
  8019b9:	c1 fa 1f             	sar    $0x1f,%edx
  8019bc:	89 d1                	mov    %edx,%ecx
  8019be:	c1 e9 1b             	shr    $0x1b,%ecx
  8019c1:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019c4:	83 e2 1f             	and    $0x1f,%edx
  8019c7:	29 ca                	sub    %ecx,%edx
  8019c9:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8019cd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019d1:	83 c0 01             	add    $0x1,%eax
  8019d4:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8019d7:	83 c7 01             	add    $0x1,%edi
  8019da:	eb ac                	jmp    801988 <devpipe_write+0x20>
	return i;
  8019dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8019df:	eb 05                	jmp    8019e6 <devpipe_write+0x7e>
				return 0;
  8019e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019e9:	5b                   	pop    %ebx
  8019ea:	5e                   	pop    %esi
  8019eb:	5f                   	pop    %edi
  8019ec:	5d                   	pop    %ebp
  8019ed:	c3                   	ret    

008019ee <devpipe_read>:
{
  8019ee:	f3 0f 1e fb          	endbr32 
  8019f2:	55                   	push   %ebp
  8019f3:	89 e5                	mov    %esp,%ebp
  8019f5:	57                   	push   %edi
  8019f6:	56                   	push   %esi
  8019f7:	53                   	push   %ebx
  8019f8:	83 ec 18             	sub    $0x18,%esp
  8019fb:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8019fe:	57                   	push   %edi
  8019ff:	e8 75 f6 ff ff       	call   801079 <fd2data>
  801a04:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801a06:	83 c4 10             	add    $0x10,%esp
  801a09:	be 00 00 00 00       	mov    $0x0,%esi
  801a0e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a11:	75 14                	jne    801a27 <devpipe_read+0x39>
	return i;
  801a13:	8b 45 10             	mov    0x10(%ebp),%eax
  801a16:	eb 02                	jmp    801a1a <devpipe_read+0x2c>
				return i;
  801a18:	89 f0                	mov    %esi,%eax
}
  801a1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a1d:	5b                   	pop    %ebx
  801a1e:	5e                   	pop    %esi
  801a1f:	5f                   	pop    %edi
  801a20:	5d                   	pop    %ebp
  801a21:	c3                   	ret    
			sys_yield();
  801a22:	e8 c9 f1 ff ff       	call   800bf0 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801a27:	8b 03                	mov    (%ebx),%eax
  801a29:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a2c:	75 18                	jne    801a46 <devpipe_read+0x58>
			if (i > 0)
  801a2e:	85 f6                	test   %esi,%esi
  801a30:	75 e6                	jne    801a18 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801a32:	89 da                	mov    %ebx,%edx
  801a34:	89 f8                	mov    %edi,%eax
  801a36:	e8 c8 fe ff ff       	call   801903 <_pipeisclosed>
  801a3b:	85 c0                	test   %eax,%eax
  801a3d:	74 e3                	je     801a22 <devpipe_read+0x34>
				return 0;
  801a3f:	b8 00 00 00 00       	mov    $0x0,%eax
  801a44:	eb d4                	jmp    801a1a <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a46:	99                   	cltd   
  801a47:	c1 ea 1b             	shr    $0x1b,%edx
  801a4a:	01 d0                	add    %edx,%eax
  801a4c:	83 e0 1f             	and    $0x1f,%eax
  801a4f:	29 d0                	sub    %edx,%eax
  801a51:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801a56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a59:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801a5c:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801a5f:	83 c6 01             	add    $0x1,%esi
  801a62:	eb aa                	jmp    801a0e <devpipe_read+0x20>

00801a64 <pipe>:
{
  801a64:	f3 0f 1e fb          	endbr32 
  801a68:	55                   	push   %ebp
  801a69:	89 e5                	mov    %esp,%ebp
  801a6b:	56                   	push   %esi
  801a6c:	53                   	push   %ebx
  801a6d:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801a70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a73:	50                   	push   %eax
  801a74:	e8 1b f6 ff ff       	call   801094 <fd_alloc>
  801a79:	89 c3                	mov    %eax,%ebx
  801a7b:	83 c4 10             	add    $0x10,%esp
  801a7e:	85 c0                	test   %eax,%eax
  801a80:	0f 88 23 01 00 00    	js     801ba9 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a86:	83 ec 04             	sub    $0x4,%esp
  801a89:	68 07 04 00 00       	push   $0x407
  801a8e:	ff 75 f4             	pushl  -0xc(%ebp)
  801a91:	6a 00                	push   $0x0
  801a93:	e8 7b f1 ff ff       	call   800c13 <sys_page_alloc>
  801a98:	89 c3                	mov    %eax,%ebx
  801a9a:	83 c4 10             	add    $0x10,%esp
  801a9d:	85 c0                	test   %eax,%eax
  801a9f:	0f 88 04 01 00 00    	js     801ba9 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801aa5:	83 ec 0c             	sub    $0xc,%esp
  801aa8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801aab:	50                   	push   %eax
  801aac:	e8 e3 f5 ff ff       	call   801094 <fd_alloc>
  801ab1:	89 c3                	mov    %eax,%ebx
  801ab3:	83 c4 10             	add    $0x10,%esp
  801ab6:	85 c0                	test   %eax,%eax
  801ab8:	0f 88 db 00 00 00    	js     801b99 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801abe:	83 ec 04             	sub    $0x4,%esp
  801ac1:	68 07 04 00 00       	push   $0x407
  801ac6:	ff 75 f0             	pushl  -0x10(%ebp)
  801ac9:	6a 00                	push   $0x0
  801acb:	e8 43 f1 ff ff       	call   800c13 <sys_page_alloc>
  801ad0:	89 c3                	mov    %eax,%ebx
  801ad2:	83 c4 10             	add    $0x10,%esp
  801ad5:	85 c0                	test   %eax,%eax
  801ad7:	0f 88 bc 00 00 00    	js     801b99 <pipe+0x135>
	va = fd2data(fd0);
  801add:	83 ec 0c             	sub    $0xc,%esp
  801ae0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae3:	e8 91 f5 ff ff       	call   801079 <fd2data>
  801ae8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aea:	83 c4 0c             	add    $0xc,%esp
  801aed:	68 07 04 00 00       	push   $0x407
  801af2:	50                   	push   %eax
  801af3:	6a 00                	push   $0x0
  801af5:	e8 19 f1 ff ff       	call   800c13 <sys_page_alloc>
  801afa:	89 c3                	mov    %eax,%ebx
  801afc:	83 c4 10             	add    $0x10,%esp
  801aff:	85 c0                	test   %eax,%eax
  801b01:	0f 88 82 00 00 00    	js     801b89 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b07:	83 ec 0c             	sub    $0xc,%esp
  801b0a:	ff 75 f0             	pushl  -0x10(%ebp)
  801b0d:	e8 67 f5 ff ff       	call   801079 <fd2data>
  801b12:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b19:	50                   	push   %eax
  801b1a:	6a 00                	push   $0x0
  801b1c:	56                   	push   %esi
  801b1d:	6a 00                	push   $0x0
  801b1f:	e8 36 f1 ff ff       	call   800c5a <sys_page_map>
  801b24:	89 c3                	mov    %eax,%ebx
  801b26:	83 c4 20             	add    $0x20,%esp
  801b29:	85 c0                	test   %eax,%eax
  801b2b:	78 4e                	js     801b7b <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801b2d:	a1 20 30 80 00       	mov    0x803020,%eax
  801b32:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b35:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801b37:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b3a:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801b41:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b44:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801b46:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b49:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801b50:	83 ec 0c             	sub    $0xc,%esp
  801b53:	ff 75 f4             	pushl  -0xc(%ebp)
  801b56:	e8 0a f5 ff ff       	call   801065 <fd2num>
  801b5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b5e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b60:	83 c4 04             	add    $0x4,%esp
  801b63:	ff 75 f0             	pushl  -0x10(%ebp)
  801b66:	e8 fa f4 ff ff       	call   801065 <fd2num>
  801b6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b6e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b71:	83 c4 10             	add    $0x10,%esp
  801b74:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b79:	eb 2e                	jmp    801ba9 <pipe+0x145>
	sys_page_unmap(0, va);
  801b7b:	83 ec 08             	sub    $0x8,%esp
  801b7e:	56                   	push   %esi
  801b7f:	6a 00                	push   $0x0
  801b81:	e8 1a f1 ff ff       	call   800ca0 <sys_page_unmap>
  801b86:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801b89:	83 ec 08             	sub    $0x8,%esp
  801b8c:	ff 75 f0             	pushl  -0x10(%ebp)
  801b8f:	6a 00                	push   $0x0
  801b91:	e8 0a f1 ff ff       	call   800ca0 <sys_page_unmap>
  801b96:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801b99:	83 ec 08             	sub    $0x8,%esp
  801b9c:	ff 75 f4             	pushl  -0xc(%ebp)
  801b9f:	6a 00                	push   $0x0
  801ba1:	e8 fa f0 ff ff       	call   800ca0 <sys_page_unmap>
  801ba6:	83 c4 10             	add    $0x10,%esp
}
  801ba9:	89 d8                	mov    %ebx,%eax
  801bab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bae:	5b                   	pop    %ebx
  801baf:	5e                   	pop    %esi
  801bb0:	5d                   	pop    %ebp
  801bb1:	c3                   	ret    

00801bb2 <pipeisclosed>:
{
  801bb2:	f3 0f 1e fb          	endbr32 
  801bb6:	55                   	push   %ebp
  801bb7:	89 e5                	mov    %esp,%ebp
  801bb9:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bbc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bbf:	50                   	push   %eax
  801bc0:	ff 75 08             	pushl  0x8(%ebp)
  801bc3:	e8 22 f5 ff ff       	call   8010ea <fd_lookup>
  801bc8:	83 c4 10             	add    $0x10,%esp
  801bcb:	85 c0                	test   %eax,%eax
  801bcd:	78 18                	js     801be7 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801bcf:	83 ec 0c             	sub    $0xc,%esp
  801bd2:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd5:	e8 9f f4 ff ff       	call   801079 <fd2data>
  801bda:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801bdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bdf:	e8 1f fd ff ff       	call   801903 <_pipeisclosed>
  801be4:	83 c4 10             	add    $0x10,%esp
}
  801be7:	c9                   	leave  
  801be8:	c3                   	ret    

00801be9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801be9:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801bed:	b8 00 00 00 00       	mov    $0x0,%eax
  801bf2:	c3                   	ret    

00801bf3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801bf3:	f3 0f 1e fb          	endbr32 
  801bf7:	55                   	push   %ebp
  801bf8:	89 e5                	mov    %esp,%ebp
  801bfa:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801bfd:	68 c0 27 80 00       	push   $0x8027c0
  801c02:	ff 75 0c             	pushl  0xc(%ebp)
  801c05:	e8 c7 eb ff ff       	call   8007d1 <strcpy>
	return 0;
}
  801c0a:	b8 00 00 00 00       	mov    $0x0,%eax
  801c0f:	c9                   	leave  
  801c10:	c3                   	ret    

00801c11 <devcons_write>:
{
  801c11:	f3 0f 1e fb          	endbr32 
  801c15:	55                   	push   %ebp
  801c16:	89 e5                	mov    %esp,%ebp
  801c18:	57                   	push   %edi
  801c19:	56                   	push   %esi
  801c1a:	53                   	push   %ebx
  801c1b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801c21:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801c26:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801c2c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c2f:	73 31                	jae    801c62 <devcons_write+0x51>
		m = n - tot;
  801c31:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c34:	29 f3                	sub    %esi,%ebx
  801c36:	83 fb 7f             	cmp    $0x7f,%ebx
  801c39:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801c3e:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801c41:	83 ec 04             	sub    $0x4,%esp
  801c44:	53                   	push   %ebx
  801c45:	89 f0                	mov    %esi,%eax
  801c47:	03 45 0c             	add    0xc(%ebp),%eax
  801c4a:	50                   	push   %eax
  801c4b:	57                   	push   %edi
  801c4c:	e8 36 ed ff ff       	call   800987 <memmove>
		sys_cputs(buf, m);
  801c51:	83 c4 08             	add    $0x8,%esp
  801c54:	53                   	push   %ebx
  801c55:	57                   	push   %edi
  801c56:	e8 e8 ee ff ff       	call   800b43 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801c5b:	01 de                	add    %ebx,%esi
  801c5d:	83 c4 10             	add    $0x10,%esp
  801c60:	eb ca                	jmp    801c2c <devcons_write+0x1b>
}
  801c62:	89 f0                	mov    %esi,%eax
  801c64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c67:	5b                   	pop    %ebx
  801c68:	5e                   	pop    %esi
  801c69:	5f                   	pop    %edi
  801c6a:	5d                   	pop    %ebp
  801c6b:	c3                   	ret    

00801c6c <devcons_read>:
{
  801c6c:	f3 0f 1e fb          	endbr32 
  801c70:	55                   	push   %ebp
  801c71:	89 e5                	mov    %esp,%ebp
  801c73:	83 ec 08             	sub    $0x8,%esp
  801c76:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801c7b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c7f:	74 21                	je     801ca2 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801c81:	e8 df ee ff ff       	call   800b65 <sys_cgetc>
  801c86:	85 c0                	test   %eax,%eax
  801c88:	75 07                	jne    801c91 <devcons_read+0x25>
		sys_yield();
  801c8a:	e8 61 ef ff ff       	call   800bf0 <sys_yield>
  801c8f:	eb f0                	jmp    801c81 <devcons_read+0x15>
	if (c < 0)
  801c91:	78 0f                	js     801ca2 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801c93:	83 f8 04             	cmp    $0x4,%eax
  801c96:	74 0c                	je     801ca4 <devcons_read+0x38>
	*(char*)vbuf = c;
  801c98:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c9b:	88 02                	mov    %al,(%edx)
	return 1;
  801c9d:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801ca2:	c9                   	leave  
  801ca3:	c3                   	ret    
		return 0;
  801ca4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca9:	eb f7                	jmp    801ca2 <devcons_read+0x36>

00801cab <cputchar>:
{
  801cab:	f3 0f 1e fb          	endbr32 
  801caf:	55                   	push   %ebp
  801cb0:	89 e5                	mov    %esp,%ebp
  801cb2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801cb5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb8:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801cbb:	6a 01                	push   $0x1
  801cbd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cc0:	50                   	push   %eax
  801cc1:	e8 7d ee ff ff       	call   800b43 <sys_cputs>
}
  801cc6:	83 c4 10             	add    $0x10,%esp
  801cc9:	c9                   	leave  
  801cca:	c3                   	ret    

00801ccb <getchar>:
{
  801ccb:	f3 0f 1e fb          	endbr32 
  801ccf:	55                   	push   %ebp
  801cd0:	89 e5                	mov    %esp,%ebp
  801cd2:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801cd5:	6a 01                	push   $0x1
  801cd7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cda:	50                   	push   %eax
  801cdb:	6a 00                	push   $0x0
  801cdd:	e8 8b f6 ff ff       	call   80136d <read>
	if (r < 0)
  801ce2:	83 c4 10             	add    $0x10,%esp
  801ce5:	85 c0                	test   %eax,%eax
  801ce7:	78 06                	js     801cef <getchar+0x24>
	if (r < 1)
  801ce9:	74 06                	je     801cf1 <getchar+0x26>
	return c;
  801ceb:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801cef:	c9                   	leave  
  801cf0:	c3                   	ret    
		return -E_EOF;
  801cf1:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801cf6:	eb f7                	jmp    801cef <getchar+0x24>

00801cf8 <iscons>:
{
  801cf8:	f3 0f 1e fb          	endbr32 
  801cfc:	55                   	push   %ebp
  801cfd:	89 e5                	mov    %esp,%ebp
  801cff:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d05:	50                   	push   %eax
  801d06:	ff 75 08             	pushl  0x8(%ebp)
  801d09:	e8 dc f3 ff ff       	call   8010ea <fd_lookup>
  801d0e:	83 c4 10             	add    $0x10,%esp
  801d11:	85 c0                	test   %eax,%eax
  801d13:	78 11                	js     801d26 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801d15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d18:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d1e:	39 10                	cmp    %edx,(%eax)
  801d20:	0f 94 c0             	sete   %al
  801d23:	0f b6 c0             	movzbl %al,%eax
}
  801d26:	c9                   	leave  
  801d27:	c3                   	ret    

00801d28 <opencons>:
{
  801d28:	f3 0f 1e fb          	endbr32 
  801d2c:	55                   	push   %ebp
  801d2d:	89 e5                	mov    %esp,%ebp
  801d2f:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801d32:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d35:	50                   	push   %eax
  801d36:	e8 59 f3 ff ff       	call   801094 <fd_alloc>
  801d3b:	83 c4 10             	add    $0x10,%esp
  801d3e:	85 c0                	test   %eax,%eax
  801d40:	78 3a                	js     801d7c <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d42:	83 ec 04             	sub    $0x4,%esp
  801d45:	68 07 04 00 00       	push   $0x407
  801d4a:	ff 75 f4             	pushl  -0xc(%ebp)
  801d4d:	6a 00                	push   $0x0
  801d4f:	e8 bf ee ff ff       	call   800c13 <sys_page_alloc>
  801d54:	83 c4 10             	add    $0x10,%esp
  801d57:	85 c0                	test   %eax,%eax
  801d59:	78 21                	js     801d7c <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d5e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d64:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d69:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d70:	83 ec 0c             	sub    $0xc,%esp
  801d73:	50                   	push   %eax
  801d74:	e8 ec f2 ff ff       	call   801065 <fd2num>
  801d79:	83 c4 10             	add    $0x10,%esp
}
  801d7c:	c9                   	leave  
  801d7d:	c3                   	ret    

00801d7e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d7e:	f3 0f 1e fb          	endbr32 
  801d82:	55                   	push   %ebp
  801d83:	89 e5                	mov    %esp,%ebp
  801d85:	56                   	push   %esi
  801d86:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d87:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d8a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d90:	e8 38 ee ff ff       	call   800bcd <sys_getenvid>
  801d95:	83 ec 0c             	sub    $0xc,%esp
  801d98:	ff 75 0c             	pushl  0xc(%ebp)
  801d9b:	ff 75 08             	pushl  0x8(%ebp)
  801d9e:	56                   	push   %esi
  801d9f:	50                   	push   %eax
  801da0:	68 cc 27 80 00       	push   $0x8027cc
  801da5:	e8 1e e4 ff ff       	call   8001c8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801daa:	83 c4 18             	add    $0x18,%esp
  801dad:	53                   	push   %ebx
  801dae:	ff 75 10             	pushl  0x10(%ebp)
  801db1:	e8 bd e3 ff ff       	call   800173 <vcprintf>
	cprintf("\n");
  801db6:	c7 04 24 b4 22 80 00 	movl   $0x8022b4,(%esp)
  801dbd:	e8 06 e4 ff ff       	call   8001c8 <cprintf>
  801dc2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801dc5:	cc                   	int3   
  801dc6:	eb fd                	jmp    801dc5 <_panic+0x47>

00801dc8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801dc8:	f3 0f 1e fb          	endbr32 
  801dcc:	55                   	push   %ebp
  801dcd:	89 e5                	mov    %esp,%ebp
  801dcf:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801dd2:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801dd9:	74 0a                	je     801de5 <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801ddb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dde:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801de3:	c9                   	leave  
  801de4:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  801de5:	83 ec 0c             	sub    $0xc,%esp
  801de8:	68 ef 27 80 00       	push   $0x8027ef
  801ded:	e8 d6 e3 ff ff       	call   8001c8 <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  801df2:	83 c4 0c             	add    $0xc,%esp
  801df5:	6a 07                	push   $0x7
  801df7:	68 00 f0 bf ee       	push   $0xeebff000
  801dfc:	6a 00                	push   $0x0
  801dfe:	e8 10 ee ff ff       	call   800c13 <sys_page_alloc>
  801e03:	83 c4 10             	add    $0x10,%esp
  801e06:	85 c0                	test   %eax,%eax
  801e08:	78 2a                	js     801e34 <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  801e0a:	83 ec 08             	sub    $0x8,%esp
  801e0d:	68 48 1e 80 00       	push   $0x801e48
  801e12:	6a 00                	push   $0x0
  801e14:	e8 59 ef ff ff       	call   800d72 <sys_env_set_pgfault_upcall>
  801e19:	83 c4 10             	add    $0x10,%esp
  801e1c:	85 c0                	test   %eax,%eax
  801e1e:	79 bb                	jns    801ddb <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  801e20:	83 ec 04             	sub    $0x4,%esp
  801e23:	68 2c 28 80 00       	push   $0x80282c
  801e28:	6a 25                	push   $0x25
  801e2a:	68 1c 28 80 00       	push   $0x80281c
  801e2f:	e8 4a ff ff ff       	call   801d7e <_panic>
            panic("Allocation of UXSTACK failed!");
  801e34:	83 ec 04             	sub    $0x4,%esp
  801e37:	68 fe 27 80 00       	push   $0x8027fe
  801e3c:	6a 22                	push   $0x22
  801e3e:	68 1c 28 80 00       	push   $0x80281c
  801e43:	e8 36 ff ff ff       	call   801d7e <_panic>

00801e48 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e48:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e49:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e4e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e50:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  801e53:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  801e57:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  801e5b:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  801e5e:	83 c4 08             	add    $0x8,%esp
    popa
  801e61:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

    add $0x4, %esp
  801e62:	83 c4 04             	add    $0x4,%esp
    popf
  801e65:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  801e66:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  801e69:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  801e6d:	c3                   	ret    

00801e6e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e6e:	f3 0f 1e fb          	endbr32 
  801e72:	55                   	push   %ebp
  801e73:	89 e5                	mov    %esp,%ebp
  801e75:	56                   	push   %esi
  801e76:	53                   	push   %ebx
  801e77:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801e7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e7d:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801e80:	85 c0                	test   %eax,%eax
  801e82:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801e87:	0f 44 c2             	cmove  %edx,%eax
  801e8a:	83 ec 0c             	sub    $0xc,%esp
  801e8d:	50                   	push   %eax
  801e8e:	e8 4c ef ff ff       	call   800ddf <sys_ipc_recv>
  801e93:	83 c4 10             	add    $0x10,%esp
  801e96:	85 c0                	test   %eax,%eax
  801e98:	78 24                	js     801ebe <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801e9a:	85 f6                	test   %esi,%esi
  801e9c:	74 0a                	je     801ea8 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801e9e:	a1 04 40 80 00       	mov    0x804004,%eax
  801ea3:	8b 40 78             	mov    0x78(%eax),%eax
  801ea6:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801ea8:	85 db                	test   %ebx,%ebx
  801eaa:	74 0a                	je     801eb6 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801eac:	a1 04 40 80 00       	mov    0x804004,%eax
  801eb1:	8b 40 74             	mov    0x74(%eax),%eax
  801eb4:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801eb6:	a1 04 40 80 00       	mov    0x804004,%eax
  801ebb:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ebe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ec1:	5b                   	pop    %ebx
  801ec2:	5e                   	pop    %esi
  801ec3:	5d                   	pop    %ebp
  801ec4:	c3                   	ret    

00801ec5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ec5:	f3 0f 1e fb          	endbr32 
  801ec9:	55                   	push   %ebp
  801eca:	89 e5                	mov    %esp,%ebp
  801ecc:	57                   	push   %edi
  801ecd:	56                   	push   %esi
  801ece:	53                   	push   %ebx
  801ecf:	83 ec 1c             	sub    $0x1c,%esp
  801ed2:	8b 45 10             	mov    0x10(%ebp),%eax
  801ed5:	85 c0                	test   %eax,%eax
  801ed7:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801edc:	0f 45 d0             	cmovne %eax,%edx
  801edf:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801ee1:	be 01 00 00 00       	mov    $0x1,%esi
  801ee6:	eb 1f                	jmp    801f07 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801ee8:	e8 03 ed ff ff       	call   800bf0 <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801eed:	83 c3 01             	add    $0x1,%ebx
  801ef0:	39 de                	cmp    %ebx,%esi
  801ef2:	7f f4                	jg     801ee8 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801ef4:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801ef6:	83 fe 11             	cmp    $0x11,%esi
  801ef9:	b8 01 00 00 00       	mov    $0x1,%eax
  801efe:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801f01:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801f05:	75 1c                	jne    801f23 <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801f07:	ff 75 14             	pushl  0x14(%ebp)
  801f0a:	57                   	push   %edi
  801f0b:	ff 75 0c             	pushl  0xc(%ebp)
  801f0e:	ff 75 08             	pushl  0x8(%ebp)
  801f11:	e8 a2 ee ff ff       	call   800db8 <sys_ipc_try_send>
  801f16:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801f19:	83 c4 10             	add    $0x10,%esp
  801f1c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f21:	eb cd                	jmp    801ef0 <ipc_send+0x2b>
}
  801f23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f26:	5b                   	pop    %ebx
  801f27:	5e                   	pop    %esi
  801f28:	5f                   	pop    %edi
  801f29:	5d                   	pop    %ebp
  801f2a:	c3                   	ret    

00801f2b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f2b:	f3 0f 1e fb          	endbr32 
  801f2f:	55                   	push   %ebp
  801f30:	89 e5                	mov    %esp,%ebp
  801f32:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f35:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f3a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f3d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f43:	8b 52 50             	mov    0x50(%edx),%edx
  801f46:	39 ca                	cmp    %ecx,%edx
  801f48:	74 11                	je     801f5b <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801f4a:	83 c0 01             	add    $0x1,%eax
  801f4d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f52:	75 e6                	jne    801f3a <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801f54:	b8 00 00 00 00       	mov    $0x0,%eax
  801f59:	eb 0b                	jmp    801f66 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801f5b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f5e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f63:	8b 40 48             	mov    0x48(%eax),%eax
}
  801f66:	5d                   	pop    %ebp
  801f67:	c3                   	ret    

00801f68 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f68:	f3 0f 1e fb          	endbr32 
  801f6c:	55                   	push   %ebp
  801f6d:	89 e5                	mov    %esp,%ebp
  801f6f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f72:	89 c2                	mov    %eax,%edx
  801f74:	c1 ea 16             	shr    $0x16,%edx
  801f77:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801f7e:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801f83:	f6 c1 01             	test   $0x1,%cl
  801f86:	74 1c                	je     801fa4 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801f88:	c1 e8 0c             	shr    $0xc,%eax
  801f8b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801f92:	a8 01                	test   $0x1,%al
  801f94:	74 0e                	je     801fa4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f96:	c1 e8 0c             	shr    $0xc,%eax
  801f99:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801fa0:	ef 
  801fa1:	0f b7 d2             	movzwl %dx,%edx
}
  801fa4:	89 d0                	mov    %edx,%eax
  801fa6:	5d                   	pop    %ebp
  801fa7:	c3                   	ret    
  801fa8:	66 90                	xchg   %ax,%ax
  801faa:	66 90                	xchg   %ax,%ax
  801fac:	66 90                	xchg   %ax,%ax
  801fae:	66 90                	xchg   %ax,%ax

00801fb0 <__udivdi3>:
  801fb0:	f3 0f 1e fb          	endbr32 
  801fb4:	55                   	push   %ebp
  801fb5:	57                   	push   %edi
  801fb6:	56                   	push   %esi
  801fb7:	53                   	push   %ebx
  801fb8:	83 ec 1c             	sub    $0x1c,%esp
  801fbb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801fbf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801fc3:	8b 74 24 34          	mov    0x34(%esp),%esi
  801fc7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801fcb:	85 d2                	test   %edx,%edx
  801fcd:	75 19                	jne    801fe8 <__udivdi3+0x38>
  801fcf:	39 f3                	cmp    %esi,%ebx
  801fd1:	76 4d                	jbe    802020 <__udivdi3+0x70>
  801fd3:	31 ff                	xor    %edi,%edi
  801fd5:	89 e8                	mov    %ebp,%eax
  801fd7:	89 f2                	mov    %esi,%edx
  801fd9:	f7 f3                	div    %ebx
  801fdb:	89 fa                	mov    %edi,%edx
  801fdd:	83 c4 1c             	add    $0x1c,%esp
  801fe0:	5b                   	pop    %ebx
  801fe1:	5e                   	pop    %esi
  801fe2:	5f                   	pop    %edi
  801fe3:	5d                   	pop    %ebp
  801fe4:	c3                   	ret    
  801fe5:	8d 76 00             	lea    0x0(%esi),%esi
  801fe8:	39 f2                	cmp    %esi,%edx
  801fea:	76 14                	jbe    802000 <__udivdi3+0x50>
  801fec:	31 ff                	xor    %edi,%edi
  801fee:	31 c0                	xor    %eax,%eax
  801ff0:	89 fa                	mov    %edi,%edx
  801ff2:	83 c4 1c             	add    $0x1c,%esp
  801ff5:	5b                   	pop    %ebx
  801ff6:	5e                   	pop    %esi
  801ff7:	5f                   	pop    %edi
  801ff8:	5d                   	pop    %ebp
  801ff9:	c3                   	ret    
  801ffa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802000:	0f bd fa             	bsr    %edx,%edi
  802003:	83 f7 1f             	xor    $0x1f,%edi
  802006:	75 48                	jne    802050 <__udivdi3+0xa0>
  802008:	39 f2                	cmp    %esi,%edx
  80200a:	72 06                	jb     802012 <__udivdi3+0x62>
  80200c:	31 c0                	xor    %eax,%eax
  80200e:	39 eb                	cmp    %ebp,%ebx
  802010:	77 de                	ja     801ff0 <__udivdi3+0x40>
  802012:	b8 01 00 00 00       	mov    $0x1,%eax
  802017:	eb d7                	jmp    801ff0 <__udivdi3+0x40>
  802019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802020:	89 d9                	mov    %ebx,%ecx
  802022:	85 db                	test   %ebx,%ebx
  802024:	75 0b                	jne    802031 <__udivdi3+0x81>
  802026:	b8 01 00 00 00       	mov    $0x1,%eax
  80202b:	31 d2                	xor    %edx,%edx
  80202d:	f7 f3                	div    %ebx
  80202f:	89 c1                	mov    %eax,%ecx
  802031:	31 d2                	xor    %edx,%edx
  802033:	89 f0                	mov    %esi,%eax
  802035:	f7 f1                	div    %ecx
  802037:	89 c6                	mov    %eax,%esi
  802039:	89 e8                	mov    %ebp,%eax
  80203b:	89 f7                	mov    %esi,%edi
  80203d:	f7 f1                	div    %ecx
  80203f:	89 fa                	mov    %edi,%edx
  802041:	83 c4 1c             	add    $0x1c,%esp
  802044:	5b                   	pop    %ebx
  802045:	5e                   	pop    %esi
  802046:	5f                   	pop    %edi
  802047:	5d                   	pop    %ebp
  802048:	c3                   	ret    
  802049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802050:	89 f9                	mov    %edi,%ecx
  802052:	b8 20 00 00 00       	mov    $0x20,%eax
  802057:	29 f8                	sub    %edi,%eax
  802059:	d3 e2                	shl    %cl,%edx
  80205b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80205f:	89 c1                	mov    %eax,%ecx
  802061:	89 da                	mov    %ebx,%edx
  802063:	d3 ea                	shr    %cl,%edx
  802065:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802069:	09 d1                	or     %edx,%ecx
  80206b:	89 f2                	mov    %esi,%edx
  80206d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802071:	89 f9                	mov    %edi,%ecx
  802073:	d3 e3                	shl    %cl,%ebx
  802075:	89 c1                	mov    %eax,%ecx
  802077:	d3 ea                	shr    %cl,%edx
  802079:	89 f9                	mov    %edi,%ecx
  80207b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80207f:	89 eb                	mov    %ebp,%ebx
  802081:	d3 e6                	shl    %cl,%esi
  802083:	89 c1                	mov    %eax,%ecx
  802085:	d3 eb                	shr    %cl,%ebx
  802087:	09 de                	or     %ebx,%esi
  802089:	89 f0                	mov    %esi,%eax
  80208b:	f7 74 24 08          	divl   0x8(%esp)
  80208f:	89 d6                	mov    %edx,%esi
  802091:	89 c3                	mov    %eax,%ebx
  802093:	f7 64 24 0c          	mull   0xc(%esp)
  802097:	39 d6                	cmp    %edx,%esi
  802099:	72 15                	jb     8020b0 <__udivdi3+0x100>
  80209b:	89 f9                	mov    %edi,%ecx
  80209d:	d3 e5                	shl    %cl,%ebp
  80209f:	39 c5                	cmp    %eax,%ebp
  8020a1:	73 04                	jae    8020a7 <__udivdi3+0xf7>
  8020a3:	39 d6                	cmp    %edx,%esi
  8020a5:	74 09                	je     8020b0 <__udivdi3+0x100>
  8020a7:	89 d8                	mov    %ebx,%eax
  8020a9:	31 ff                	xor    %edi,%edi
  8020ab:	e9 40 ff ff ff       	jmp    801ff0 <__udivdi3+0x40>
  8020b0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8020b3:	31 ff                	xor    %edi,%edi
  8020b5:	e9 36 ff ff ff       	jmp    801ff0 <__udivdi3+0x40>
  8020ba:	66 90                	xchg   %ax,%ax
  8020bc:	66 90                	xchg   %ax,%ax
  8020be:	66 90                	xchg   %ax,%ax

008020c0 <__umoddi3>:
  8020c0:	f3 0f 1e fb          	endbr32 
  8020c4:	55                   	push   %ebp
  8020c5:	57                   	push   %edi
  8020c6:	56                   	push   %esi
  8020c7:	53                   	push   %ebx
  8020c8:	83 ec 1c             	sub    $0x1c,%esp
  8020cb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8020cf:	8b 74 24 30          	mov    0x30(%esp),%esi
  8020d3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8020d7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020db:	85 c0                	test   %eax,%eax
  8020dd:	75 19                	jne    8020f8 <__umoddi3+0x38>
  8020df:	39 df                	cmp    %ebx,%edi
  8020e1:	76 5d                	jbe    802140 <__umoddi3+0x80>
  8020e3:	89 f0                	mov    %esi,%eax
  8020e5:	89 da                	mov    %ebx,%edx
  8020e7:	f7 f7                	div    %edi
  8020e9:	89 d0                	mov    %edx,%eax
  8020eb:	31 d2                	xor    %edx,%edx
  8020ed:	83 c4 1c             	add    $0x1c,%esp
  8020f0:	5b                   	pop    %ebx
  8020f1:	5e                   	pop    %esi
  8020f2:	5f                   	pop    %edi
  8020f3:	5d                   	pop    %ebp
  8020f4:	c3                   	ret    
  8020f5:	8d 76 00             	lea    0x0(%esi),%esi
  8020f8:	89 f2                	mov    %esi,%edx
  8020fa:	39 d8                	cmp    %ebx,%eax
  8020fc:	76 12                	jbe    802110 <__umoddi3+0x50>
  8020fe:	89 f0                	mov    %esi,%eax
  802100:	89 da                	mov    %ebx,%edx
  802102:	83 c4 1c             	add    $0x1c,%esp
  802105:	5b                   	pop    %ebx
  802106:	5e                   	pop    %esi
  802107:	5f                   	pop    %edi
  802108:	5d                   	pop    %ebp
  802109:	c3                   	ret    
  80210a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802110:	0f bd e8             	bsr    %eax,%ebp
  802113:	83 f5 1f             	xor    $0x1f,%ebp
  802116:	75 50                	jne    802168 <__umoddi3+0xa8>
  802118:	39 d8                	cmp    %ebx,%eax
  80211a:	0f 82 e0 00 00 00    	jb     802200 <__umoddi3+0x140>
  802120:	89 d9                	mov    %ebx,%ecx
  802122:	39 f7                	cmp    %esi,%edi
  802124:	0f 86 d6 00 00 00    	jbe    802200 <__umoddi3+0x140>
  80212a:	89 d0                	mov    %edx,%eax
  80212c:	89 ca                	mov    %ecx,%edx
  80212e:	83 c4 1c             	add    $0x1c,%esp
  802131:	5b                   	pop    %ebx
  802132:	5e                   	pop    %esi
  802133:	5f                   	pop    %edi
  802134:	5d                   	pop    %ebp
  802135:	c3                   	ret    
  802136:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80213d:	8d 76 00             	lea    0x0(%esi),%esi
  802140:	89 fd                	mov    %edi,%ebp
  802142:	85 ff                	test   %edi,%edi
  802144:	75 0b                	jne    802151 <__umoddi3+0x91>
  802146:	b8 01 00 00 00       	mov    $0x1,%eax
  80214b:	31 d2                	xor    %edx,%edx
  80214d:	f7 f7                	div    %edi
  80214f:	89 c5                	mov    %eax,%ebp
  802151:	89 d8                	mov    %ebx,%eax
  802153:	31 d2                	xor    %edx,%edx
  802155:	f7 f5                	div    %ebp
  802157:	89 f0                	mov    %esi,%eax
  802159:	f7 f5                	div    %ebp
  80215b:	89 d0                	mov    %edx,%eax
  80215d:	31 d2                	xor    %edx,%edx
  80215f:	eb 8c                	jmp    8020ed <__umoddi3+0x2d>
  802161:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802168:	89 e9                	mov    %ebp,%ecx
  80216a:	ba 20 00 00 00       	mov    $0x20,%edx
  80216f:	29 ea                	sub    %ebp,%edx
  802171:	d3 e0                	shl    %cl,%eax
  802173:	89 44 24 08          	mov    %eax,0x8(%esp)
  802177:	89 d1                	mov    %edx,%ecx
  802179:	89 f8                	mov    %edi,%eax
  80217b:	d3 e8                	shr    %cl,%eax
  80217d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802181:	89 54 24 04          	mov    %edx,0x4(%esp)
  802185:	8b 54 24 04          	mov    0x4(%esp),%edx
  802189:	09 c1                	or     %eax,%ecx
  80218b:	89 d8                	mov    %ebx,%eax
  80218d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802191:	89 e9                	mov    %ebp,%ecx
  802193:	d3 e7                	shl    %cl,%edi
  802195:	89 d1                	mov    %edx,%ecx
  802197:	d3 e8                	shr    %cl,%eax
  802199:	89 e9                	mov    %ebp,%ecx
  80219b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80219f:	d3 e3                	shl    %cl,%ebx
  8021a1:	89 c7                	mov    %eax,%edi
  8021a3:	89 d1                	mov    %edx,%ecx
  8021a5:	89 f0                	mov    %esi,%eax
  8021a7:	d3 e8                	shr    %cl,%eax
  8021a9:	89 e9                	mov    %ebp,%ecx
  8021ab:	89 fa                	mov    %edi,%edx
  8021ad:	d3 e6                	shl    %cl,%esi
  8021af:	09 d8                	or     %ebx,%eax
  8021b1:	f7 74 24 08          	divl   0x8(%esp)
  8021b5:	89 d1                	mov    %edx,%ecx
  8021b7:	89 f3                	mov    %esi,%ebx
  8021b9:	f7 64 24 0c          	mull   0xc(%esp)
  8021bd:	89 c6                	mov    %eax,%esi
  8021bf:	89 d7                	mov    %edx,%edi
  8021c1:	39 d1                	cmp    %edx,%ecx
  8021c3:	72 06                	jb     8021cb <__umoddi3+0x10b>
  8021c5:	75 10                	jne    8021d7 <__umoddi3+0x117>
  8021c7:	39 c3                	cmp    %eax,%ebx
  8021c9:	73 0c                	jae    8021d7 <__umoddi3+0x117>
  8021cb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8021cf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8021d3:	89 d7                	mov    %edx,%edi
  8021d5:	89 c6                	mov    %eax,%esi
  8021d7:	89 ca                	mov    %ecx,%edx
  8021d9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8021de:	29 f3                	sub    %esi,%ebx
  8021e0:	19 fa                	sbb    %edi,%edx
  8021e2:	89 d0                	mov    %edx,%eax
  8021e4:	d3 e0                	shl    %cl,%eax
  8021e6:	89 e9                	mov    %ebp,%ecx
  8021e8:	d3 eb                	shr    %cl,%ebx
  8021ea:	d3 ea                	shr    %cl,%edx
  8021ec:	09 d8                	or     %ebx,%eax
  8021ee:	83 c4 1c             	add    $0x1c,%esp
  8021f1:	5b                   	pop    %ebx
  8021f2:	5e                   	pop    %esi
  8021f3:	5f                   	pop    %edi
  8021f4:	5d                   	pop    %ebp
  8021f5:	c3                   	ret    
  8021f6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021fd:	8d 76 00             	lea    0x0(%esi),%esi
  802200:	29 fe                	sub    %edi,%esi
  802202:	19 c3                	sbb    %eax,%ebx
  802204:	89 f2                	mov    %esi,%edx
  802206:	89 d9                	mov    %ebx,%ecx
  802208:	e9 1d ff ff ff       	jmp    80212a <__umoddi3+0x6a>
