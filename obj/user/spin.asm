
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
  80003e:	68 c0 13 80 00       	push   $0x8013c0
  800043:	e8 78 01 00 00       	call   8001c0 <cprintf>
	if ((env = fork()) == 0) {
  800048:	e8 a4 0e 00 00       	call   800ef1 <fork>
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	85 c0                	test   %eax,%eax
  800052:	75 12                	jne    800066 <umain+0x33>
		cprintf("I am the child.  Spinning...\n");
  800054:	83 ec 0c             	sub    $0xc,%esp
  800057:	68 38 14 80 00       	push   $0x801438
  80005c:	e8 5f 01 00 00       	call   8001c0 <cprintf>
  800061:	83 c4 10             	add    $0x10,%esp
  800064:	eb fe                	jmp    800064 <umain+0x31>
  800066:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800068:	83 ec 0c             	sub    $0xc,%esp
  80006b:	68 e8 13 80 00       	push   $0x8013e8
  800070:	e8 4b 01 00 00       	call   8001c0 <cprintf>
	sys_yield();
  800075:	e8 6e 0b 00 00       	call   800be8 <sys_yield>
	sys_yield();
  80007a:	e8 69 0b 00 00       	call   800be8 <sys_yield>
	sys_yield();
  80007f:	e8 64 0b 00 00       	call   800be8 <sys_yield>
	sys_yield();
  800084:	e8 5f 0b 00 00       	call   800be8 <sys_yield>
	sys_yield();
  800089:	e8 5a 0b 00 00       	call   800be8 <sys_yield>
	sys_yield();
  80008e:	e8 55 0b 00 00       	call   800be8 <sys_yield>
	sys_yield();
  800093:	e8 50 0b 00 00       	call   800be8 <sys_yield>
	sys_yield();
  800098:	e8 4b 0b 00 00       	call   800be8 <sys_yield>

    cprintf("I am the parent.  Killing the child...\n");
  80009d:	c7 04 24 10 14 80 00 	movl   $0x801410,(%esp)
  8000a4:	e8 17 01 00 00       	call   8001c0 <cprintf>
	sys_env_destroy(env);
  8000a9:	89 1c 24             	mov    %ebx,(%esp)
  8000ac:	e8 cf 0a 00 00       	call   800b80 <sys_env_destroy>
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
  8000c8:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000cf:	00 00 00 
    envid_t envid = sys_getenvid();
  8000d2:	e8 ee 0a 00 00       	call   800bc5 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  8000d7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000dc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000df:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e4:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e9:	85 db                	test   %ebx,%ebx
  8000eb:	7e 07                	jle    8000f4 <libmain+0x3b>
		binaryname = argv[0];
  8000ed:	8b 06                	mov    (%esi),%eax
  8000ef:	a3 00 20 80 00       	mov    %eax,0x802000

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
  800114:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  800117:	6a 00                	push   $0x0
  800119:	e8 62 0a 00 00       	call   800b80 <sys_env_destroy>
}
  80011e:	83 c4 10             	add    $0x10,%esp
  800121:	c9                   	leave  
  800122:	c3                   	ret    

00800123 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800123:	f3 0f 1e fb          	endbr32 
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	53                   	push   %ebx
  80012b:	83 ec 04             	sub    $0x4,%esp
  80012e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800131:	8b 13                	mov    (%ebx),%edx
  800133:	8d 42 01             	lea    0x1(%edx),%eax
  800136:	89 03                	mov    %eax,(%ebx)
  800138:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80013b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80013f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800144:	74 09                	je     80014f <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800146:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80014a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80014f:	83 ec 08             	sub    $0x8,%esp
  800152:	68 ff 00 00 00       	push   $0xff
  800157:	8d 43 08             	lea    0x8(%ebx),%eax
  80015a:	50                   	push   %eax
  80015b:	e8 db 09 00 00       	call   800b3b <sys_cputs>
		b->idx = 0;
  800160:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800166:	83 c4 10             	add    $0x10,%esp
  800169:	eb db                	jmp    800146 <putch+0x23>

0080016b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80016b:	f3 0f 1e fb          	endbr32 
  80016f:	55                   	push   %ebp
  800170:	89 e5                	mov    %esp,%ebp
  800172:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800178:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80017f:	00 00 00 
	b.cnt = 0;
  800182:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800189:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80018c:	ff 75 0c             	pushl  0xc(%ebp)
  80018f:	ff 75 08             	pushl  0x8(%ebp)
  800192:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800198:	50                   	push   %eax
  800199:	68 23 01 80 00       	push   $0x800123
  80019e:	e8 20 01 00 00       	call   8002c3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a3:	83 c4 08             	add    $0x8,%esp
  8001a6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ac:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b2:	50                   	push   %eax
  8001b3:	e8 83 09 00 00       	call   800b3b <sys_cputs>

	return b.cnt;
}
  8001b8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001be:	c9                   	leave  
  8001bf:	c3                   	ret    

008001c0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c0:	f3 0f 1e fb          	endbr32 
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ca:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001cd:	50                   	push   %eax
  8001ce:	ff 75 08             	pushl  0x8(%ebp)
  8001d1:	e8 95 ff ff ff       	call   80016b <vcprintf>
	va_end(ap);

	return cnt;
}
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    

008001d8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	57                   	push   %edi
  8001dc:	56                   	push   %esi
  8001dd:	53                   	push   %ebx
  8001de:	83 ec 1c             	sub    $0x1c,%esp
  8001e1:	89 c7                	mov    %eax,%edi
  8001e3:	89 d6                	mov    %edx,%esi
  8001e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001eb:	89 d1                	mov    %edx,%ecx
  8001ed:	89 c2                	mov    %eax,%edx
  8001ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001f2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f8:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001fe:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800205:	39 c2                	cmp    %eax,%edx
  800207:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80020a:	72 3e                	jb     80024a <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80020c:	83 ec 0c             	sub    $0xc,%esp
  80020f:	ff 75 18             	pushl  0x18(%ebp)
  800212:	83 eb 01             	sub    $0x1,%ebx
  800215:	53                   	push   %ebx
  800216:	50                   	push   %eax
  800217:	83 ec 08             	sub    $0x8,%esp
  80021a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80021d:	ff 75 e0             	pushl  -0x20(%ebp)
  800220:	ff 75 dc             	pushl  -0x24(%ebp)
  800223:	ff 75 d8             	pushl  -0x28(%ebp)
  800226:	e8 35 0f 00 00       	call   801160 <__udivdi3>
  80022b:	83 c4 18             	add    $0x18,%esp
  80022e:	52                   	push   %edx
  80022f:	50                   	push   %eax
  800230:	89 f2                	mov    %esi,%edx
  800232:	89 f8                	mov    %edi,%eax
  800234:	e8 9f ff ff ff       	call   8001d8 <printnum>
  800239:	83 c4 20             	add    $0x20,%esp
  80023c:	eb 13                	jmp    800251 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80023e:	83 ec 08             	sub    $0x8,%esp
  800241:	56                   	push   %esi
  800242:	ff 75 18             	pushl  0x18(%ebp)
  800245:	ff d7                	call   *%edi
  800247:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80024a:	83 eb 01             	sub    $0x1,%ebx
  80024d:	85 db                	test   %ebx,%ebx
  80024f:	7f ed                	jg     80023e <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800251:	83 ec 08             	sub    $0x8,%esp
  800254:	56                   	push   %esi
  800255:	83 ec 04             	sub    $0x4,%esp
  800258:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025b:	ff 75 e0             	pushl  -0x20(%ebp)
  80025e:	ff 75 dc             	pushl  -0x24(%ebp)
  800261:	ff 75 d8             	pushl  -0x28(%ebp)
  800264:	e8 07 10 00 00       	call   801270 <__umoddi3>
  800269:	83 c4 14             	add    $0x14,%esp
  80026c:	0f be 80 60 14 80 00 	movsbl 0x801460(%eax),%eax
  800273:	50                   	push   %eax
  800274:	ff d7                	call   *%edi
}
  800276:	83 c4 10             	add    $0x10,%esp
  800279:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027c:	5b                   	pop    %ebx
  80027d:	5e                   	pop    %esi
  80027e:	5f                   	pop    %edi
  80027f:	5d                   	pop    %ebp
  800280:	c3                   	ret    

00800281 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800281:	f3 0f 1e fb          	endbr32 
  800285:	55                   	push   %ebp
  800286:	89 e5                	mov    %esp,%ebp
  800288:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80028b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80028f:	8b 10                	mov    (%eax),%edx
  800291:	3b 50 04             	cmp    0x4(%eax),%edx
  800294:	73 0a                	jae    8002a0 <sprintputch+0x1f>
		*b->buf++ = ch;
  800296:	8d 4a 01             	lea    0x1(%edx),%ecx
  800299:	89 08                	mov    %ecx,(%eax)
  80029b:	8b 45 08             	mov    0x8(%ebp),%eax
  80029e:	88 02                	mov    %al,(%edx)
}
  8002a0:	5d                   	pop    %ebp
  8002a1:	c3                   	ret    

008002a2 <printfmt>:
{
  8002a2:	f3 0f 1e fb          	endbr32 
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
  8002a9:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002ac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002af:	50                   	push   %eax
  8002b0:	ff 75 10             	pushl  0x10(%ebp)
  8002b3:	ff 75 0c             	pushl  0xc(%ebp)
  8002b6:	ff 75 08             	pushl  0x8(%ebp)
  8002b9:	e8 05 00 00 00       	call   8002c3 <vprintfmt>
}
  8002be:	83 c4 10             	add    $0x10,%esp
  8002c1:	c9                   	leave  
  8002c2:	c3                   	ret    

008002c3 <vprintfmt>:
{
  8002c3:	f3 0f 1e fb          	endbr32 
  8002c7:	55                   	push   %ebp
  8002c8:	89 e5                	mov    %esp,%ebp
  8002ca:	57                   	push   %edi
  8002cb:	56                   	push   %esi
  8002cc:	53                   	push   %ebx
  8002cd:	83 ec 3c             	sub    $0x3c,%esp
  8002d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002d6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002d9:	e9 4a 03 00 00       	jmp    800628 <vprintfmt+0x365>
		padc = ' ';
  8002de:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002e2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002e9:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002f0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002f7:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002fc:	8d 47 01             	lea    0x1(%edi),%eax
  8002ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800302:	0f b6 17             	movzbl (%edi),%edx
  800305:	8d 42 dd             	lea    -0x23(%edx),%eax
  800308:	3c 55                	cmp    $0x55,%al
  80030a:	0f 87 de 03 00 00    	ja     8006ee <vprintfmt+0x42b>
  800310:	0f b6 c0             	movzbl %al,%eax
  800313:	3e ff 24 85 a0 15 80 	notrack jmp *0x8015a0(,%eax,4)
  80031a:	00 
  80031b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80031e:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800322:	eb d8                	jmp    8002fc <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800324:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800327:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80032b:	eb cf                	jmp    8002fc <vprintfmt+0x39>
  80032d:	0f b6 d2             	movzbl %dl,%edx
  800330:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800333:	b8 00 00 00 00       	mov    $0x0,%eax
  800338:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80033b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80033e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800342:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800345:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800348:	83 f9 09             	cmp    $0x9,%ecx
  80034b:	77 55                	ja     8003a2 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80034d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800350:	eb e9                	jmp    80033b <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800352:	8b 45 14             	mov    0x14(%ebp),%eax
  800355:	8b 00                	mov    (%eax),%eax
  800357:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80035a:	8b 45 14             	mov    0x14(%ebp),%eax
  80035d:	8d 40 04             	lea    0x4(%eax),%eax
  800360:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800363:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800366:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80036a:	79 90                	jns    8002fc <vprintfmt+0x39>
				width = precision, precision = -1;
  80036c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80036f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800372:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800379:	eb 81                	jmp    8002fc <vprintfmt+0x39>
  80037b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80037e:	85 c0                	test   %eax,%eax
  800380:	ba 00 00 00 00       	mov    $0x0,%edx
  800385:	0f 49 d0             	cmovns %eax,%edx
  800388:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80038b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80038e:	e9 69 ff ff ff       	jmp    8002fc <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800393:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800396:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80039d:	e9 5a ff ff ff       	jmp    8002fc <vprintfmt+0x39>
  8003a2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a8:	eb bc                	jmp    800366 <vprintfmt+0xa3>
			lflag++;
  8003aa:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003b0:	e9 47 ff ff ff       	jmp    8002fc <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b8:	8d 78 04             	lea    0x4(%eax),%edi
  8003bb:	83 ec 08             	sub    $0x8,%esp
  8003be:	53                   	push   %ebx
  8003bf:	ff 30                	pushl  (%eax)
  8003c1:	ff d6                	call   *%esi
			break;
  8003c3:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003c6:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003c9:	e9 57 02 00 00       	jmp    800625 <vprintfmt+0x362>
			err = va_arg(ap, int);
  8003ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d1:	8d 78 04             	lea    0x4(%eax),%edi
  8003d4:	8b 00                	mov    (%eax),%eax
  8003d6:	99                   	cltd   
  8003d7:	31 d0                	xor    %edx,%eax
  8003d9:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003db:	83 f8 0f             	cmp    $0xf,%eax
  8003de:	7f 23                	jg     800403 <vprintfmt+0x140>
  8003e0:	8b 14 85 00 17 80 00 	mov    0x801700(,%eax,4),%edx
  8003e7:	85 d2                	test   %edx,%edx
  8003e9:	74 18                	je     800403 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8003eb:	52                   	push   %edx
  8003ec:	68 81 14 80 00       	push   $0x801481
  8003f1:	53                   	push   %ebx
  8003f2:	56                   	push   %esi
  8003f3:	e8 aa fe ff ff       	call   8002a2 <printfmt>
  8003f8:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003fb:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003fe:	e9 22 02 00 00       	jmp    800625 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  800403:	50                   	push   %eax
  800404:	68 78 14 80 00       	push   $0x801478
  800409:	53                   	push   %ebx
  80040a:	56                   	push   %esi
  80040b:	e8 92 fe ff ff       	call   8002a2 <printfmt>
  800410:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800413:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800416:	e9 0a 02 00 00       	jmp    800625 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  80041b:	8b 45 14             	mov    0x14(%ebp),%eax
  80041e:	83 c0 04             	add    $0x4,%eax
  800421:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800424:	8b 45 14             	mov    0x14(%ebp),%eax
  800427:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800429:	85 d2                	test   %edx,%edx
  80042b:	b8 71 14 80 00       	mov    $0x801471,%eax
  800430:	0f 45 c2             	cmovne %edx,%eax
  800433:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800436:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80043a:	7e 06                	jle    800442 <vprintfmt+0x17f>
  80043c:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800440:	75 0d                	jne    80044f <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800442:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800445:	89 c7                	mov    %eax,%edi
  800447:	03 45 e0             	add    -0x20(%ebp),%eax
  80044a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044d:	eb 55                	jmp    8004a4 <vprintfmt+0x1e1>
  80044f:	83 ec 08             	sub    $0x8,%esp
  800452:	ff 75 d8             	pushl  -0x28(%ebp)
  800455:	ff 75 cc             	pushl  -0x34(%ebp)
  800458:	e8 45 03 00 00       	call   8007a2 <strnlen>
  80045d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800460:	29 c2                	sub    %eax,%edx
  800462:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800465:	83 c4 10             	add    $0x10,%esp
  800468:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80046a:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80046e:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800471:	85 ff                	test   %edi,%edi
  800473:	7e 11                	jle    800486 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800475:	83 ec 08             	sub    $0x8,%esp
  800478:	53                   	push   %ebx
  800479:	ff 75 e0             	pushl  -0x20(%ebp)
  80047c:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80047e:	83 ef 01             	sub    $0x1,%edi
  800481:	83 c4 10             	add    $0x10,%esp
  800484:	eb eb                	jmp    800471 <vprintfmt+0x1ae>
  800486:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800489:	85 d2                	test   %edx,%edx
  80048b:	b8 00 00 00 00       	mov    $0x0,%eax
  800490:	0f 49 c2             	cmovns %edx,%eax
  800493:	29 c2                	sub    %eax,%edx
  800495:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800498:	eb a8                	jmp    800442 <vprintfmt+0x17f>
					putch(ch, putdat);
  80049a:	83 ec 08             	sub    $0x8,%esp
  80049d:	53                   	push   %ebx
  80049e:	52                   	push   %edx
  80049f:	ff d6                	call   *%esi
  8004a1:	83 c4 10             	add    $0x10,%esp
  8004a4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a7:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a9:	83 c7 01             	add    $0x1,%edi
  8004ac:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004b0:	0f be d0             	movsbl %al,%edx
  8004b3:	85 d2                	test   %edx,%edx
  8004b5:	74 4b                	je     800502 <vprintfmt+0x23f>
  8004b7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004bb:	78 06                	js     8004c3 <vprintfmt+0x200>
  8004bd:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004c1:	78 1e                	js     8004e1 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004c3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004c7:	74 d1                	je     80049a <vprintfmt+0x1d7>
  8004c9:	0f be c0             	movsbl %al,%eax
  8004cc:	83 e8 20             	sub    $0x20,%eax
  8004cf:	83 f8 5e             	cmp    $0x5e,%eax
  8004d2:	76 c6                	jbe    80049a <vprintfmt+0x1d7>
					putch('?', putdat);
  8004d4:	83 ec 08             	sub    $0x8,%esp
  8004d7:	53                   	push   %ebx
  8004d8:	6a 3f                	push   $0x3f
  8004da:	ff d6                	call   *%esi
  8004dc:	83 c4 10             	add    $0x10,%esp
  8004df:	eb c3                	jmp    8004a4 <vprintfmt+0x1e1>
  8004e1:	89 cf                	mov    %ecx,%edi
  8004e3:	eb 0e                	jmp    8004f3 <vprintfmt+0x230>
				putch(' ', putdat);
  8004e5:	83 ec 08             	sub    $0x8,%esp
  8004e8:	53                   	push   %ebx
  8004e9:	6a 20                	push   $0x20
  8004eb:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004ed:	83 ef 01             	sub    $0x1,%edi
  8004f0:	83 c4 10             	add    $0x10,%esp
  8004f3:	85 ff                	test   %edi,%edi
  8004f5:	7f ee                	jg     8004e5 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8004f7:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004fa:	89 45 14             	mov    %eax,0x14(%ebp)
  8004fd:	e9 23 01 00 00       	jmp    800625 <vprintfmt+0x362>
  800502:	89 cf                	mov    %ecx,%edi
  800504:	eb ed                	jmp    8004f3 <vprintfmt+0x230>
	if (lflag >= 2)
  800506:	83 f9 01             	cmp    $0x1,%ecx
  800509:	7f 1b                	jg     800526 <vprintfmt+0x263>
	else if (lflag)
  80050b:	85 c9                	test   %ecx,%ecx
  80050d:	74 63                	je     800572 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80050f:	8b 45 14             	mov    0x14(%ebp),%eax
  800512:	8b 00                	mov    (%eax),%eax
  800514:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800517:	99                   	cltd   
  800518:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80051b:	8b 45 14             	mov    0x14(%ebp),%eax
  80051e:	8d 40 04             	lea    0x4(%eax),%eax
  800521:	89 45 14             	mov    %eax,0x14(%ebp)
  800524:	eb 17                	jmp    80053d <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800526:	8b 45 14             	mov    0x14(%ebp),%eax
  800529:	8b 50 04             	mov    0x4(%eax),%edx
  80052c:	8b 00                	mov    (%eax),%eax
  80052e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800531:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800534:	8b 45 14             	mov    0x14(%ebp),%eax
  800537:	8d 40 08             	lea    0x8(%eax),%eax
  80053a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80053d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800540:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800543:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800548:	85 c9                	test   %ecx,%ecx
  80054a:	0f 89 bb 00 00 00    	jns    80060b <vprintfmt+0x348>
				putch('-', putdat);
  800550:	83 ec 08             	sub    $0x8,%esp
  800553:	53                   	push   %ebx
  800554:	6a 2d                	push   $0x2d
  800556:	ff d6                	call   *%esi
				num = -(long long) num;
  800558:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80055b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80055e:	f7 da                	neg    %edx
  800560:	83 d1 00             	adc    $0x0,%ecx
  800563:	f7 d9                	neg    %ecx
  800565:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800568:	b8 0a 00 00 00       	mov    $0xa,%eax
  80056d:	e9 99 00 00 00       	jmp    80060b <vprintfmt+0x348>
		return va_arg(*ap, int);
  800572:	8b 45 14             	mov    0x14(%ebp),%eax
  800575:	8b 00                	mov    (%eax),%eax
  800577:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057a:	99                   	cltd   
  80057b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057e:	8b 45 14             	mov    0x14(%ebp),%eax
  800581:	8d 40 04             	lea    0x4(%eax),%eax
  800584:	89 45 14             	mov    %eax,0x14(%ebp)
  800587:	eb b4                	jmp    80053d <vprintfmt+0x27a>
	if (lflag >= 2)
  800589:	83 f9 01             	cmp    $0x1,%ecx
  80058c:	7f 1b                	jg     8005a9 <vprintfmt+0x2e6>
	else if (lflag)
  80058e:	85 c9                	test   %ecx,%ecx
  800590:	74 2c                	je     8005be <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8b 10                	mov    (%eax),%edx
  800597:	b9 00 00 00 00       	mov    $0x0,%ecx
  80059c:	8d 40 04             	lea    0x4(%eax),%eax
  80059f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005a2:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005a7:	eb 62                	jmp    80060b <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8b 10                	mov    (%eax),%edx
  8005ae:	8b 48 04             	mov    0x4(%eax),%ecx
  8005b1:	8d 40 08             	lea    0x8(%eax),%eax
  8005b4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005b7:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005bc:	eb 4d                	jmp    80060b <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8b 10                	mov    (%eax),%edx
  8005c3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c8:	8d 40 04             	lea    0x4(%eax),%eax
  8005cb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ce:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8005d3:	eb 36                	jmp    80060b <vprintfmt+0x348>
	if (lflag >= 2)
  8005d5:	83 f9 01             	cmp    $0x1,%ecx
  8005d8:	7f 17                	jg     8005f1 <vprintfmt+0x32e>
	else if (lflag)
  8005da:	85 c9                	test   %ecx,%ecx
  8005dc:	74 6e                	je     80064c <vprintfmt+0x389>
		return va_arg(*ap, long);
  8005de:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e1:	8b 10                	mov    (%eax),%edx
  8005e3:	89 d0                	mov    %edx,%eax
  8005e5:	99                   	cltd   
  8005e6:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005e9:	8d 49 04             	lea    0x4(%ecx),%ecx
  8005ec:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005ef:	eb 11                	jmp    800602 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8b 50 04             	mov    0x4(%eax),%edx
  8005f7:	8b 00                	mov    (%eax),%eax
  8005f9:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005fc:	8d 49 08             	lea    0x8(%ecx),%ecx
  8005ff:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800602:	89 d1                	mov    %edx,%ecx
  800604:	89 c2                	mov    %eax,%edx
            base = 8;
  800606:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  80060b:	83 ec 0c             	sub    $0xc,%esp
  80060e:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800612:	57                   	push   %edi
  800613:	ff 75 e0             	pushl  -0x20(%ebp)
  800616:	50                   	push   %eax
  800617:	51                   	push   %ecx
  800618:	52                   	push   %edx
  800619:	89 da                	mov    %ebx,%edx
  80061b:	89 f0                	mov    %esi,%eax
  80061d:	e8 b6 fb ff ff       	call   8001d8 <printnum>
			break;
  800622:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800625:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800628:	83 c7 01             	add    $0x1,%edi
  80062b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80062f:	83 f8 25             	cmp    $0x25,%eax
  800632:	0f 84 a6 fc ff ff    	je     8002de <vprintfmt+0x1b>
			if (ch == '\0')
  800638:	85 c0                	test   %eax,%eax
  80063a:	0f 84 ce 00 00 00    	je     80070e <vprintfmt+0x44b>
			putch(ch, putdat);
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	53                   	push   %ebx
  800644:	50                   	push   %eax
  800645:	ff d6                	call   *%esi
  800647:	83 c4 10             	add    $0x10,%esp
  80064a:	eb dc                	jmp    800628 <vprintfmt+0x365>
		return va_arg(*ap, int);
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8b 10                	mov    (%eax),%edx
  800651:	89 d0                	mov    %edx,%eax
  800653:	99                   	cltd   
  800654:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800657:	8d 49 04             	lea    0x4(%ecx),%ecx
  80065a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80065d:	eb a3                	jmp    800602 <vprintfmt+0x33f>
			putch('0', putdat);
  80065f:	83 ec 08             	sub    $0x8,%esp
  800662:	53                   	push   %ebx
  800663:	6a 30                	push   $0x30
  800665:	ff d6                	call   *%esi
			putch('x', putdat);
  800667:	83 c4 08             	add    $0x8,%esp
  80066a:	53                   	push   %ebx
  80066b:	6a 78                	push   $0x78
  80066d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80066f:	8b 45 14             	mov    0x14(%ebp),%eax
  800672:	8b 10                	mov    (%eax),%edx
  800674:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800679:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80067c:	8d 40 04             	lea    0x4(%eax),%eax
  80067f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800682:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800687:	eb 82                	jmp    80060b <vprintfmt+0x348>
	if (lflag >= 2)
  800689:	83 f9 01             	cmp    $0x1,%ecx
  80068c:	7f 1e                	jg     8006ac <vprintfmt+0x3e9>
	else if (lflag)
  80068e:	85 c9                	test   %ecx,%ecx
  800690:	74 32                	je     8006c4 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800692:	8b 45 14             	mov    0x14(%ebp),%eax
  800695:	8b 10                	mov    (%eax),%edx
  800697:	b9 00 00 00 00       	mov    $0x0,%ecx
  80069c:	8d 40 04             	lea    0x4(%eax),%eax
  80069f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a2:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006a7:	e9 5f ff ff ff       	jmp    80060b <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8b 10                	mov    (%eax),%edx
  8006b1:	8b 48 04             	mov    0x4(%eax),%ecx
  8006b4:	8d 40 08             	lea    0x8(%eax),%eax
  8006b7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ba:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006bf:	e9 47 ff ff ff       	jmp    80060b <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8006c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c7:	8b 10                	mov    (%eax),%edx
  8006c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ce:	8d 40 04             	lea    0x4(%eax),%eax
  8006d1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d4:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006d9:	e9 2d ff ff ff       	jmp    80060b <vprintfmt+0x348>
			putch(ch, putdat);
  8006de:	83 ec 08             	sub    $0x8,%esp
  8006e1:	53                   	push   %ebx
  8006e2:	6a 25                	push   $0x25
  8006e4:	ff d6                	call   *%esi
			break;
  8006e6:	83 c4 10             	add    $0x10,%esp
  8006e9:	e9 37 ff ff ff       	jmp    800625 <vprintfmt+0x362>
			putch('%', putdat);
  8006ee:	83 ec 08             	sub    $0x8,%esp
  8006f1:	53                   	push   %ebx
  8006f2:	6a 25                	push   $0x25
  8006f4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f6:	83 c4 10             	add    $0x10,%esp
  8006f9:	89 f8                	mov    %edi,%eax
  8006fb:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006ff:	74 05                	je     800706 <vprintfmt+0x443>
  800701:	83 e8 01             	sub    $0x1,%eax
  800704:	eb f5                	jmp    8006fb <vprintfmt+0x438>
  800706:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800709:	e9 17 ff ff ff       	jmp    800625 <vprintfmt+0x362>
}
  80070e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800711:	5b                   	pop    %ebx
  800712:	5e                   	pop    %esi
  800713:	5f                   	pop    %edi
  800714:	5d                   	pop    %ebp
  800715:	c3                   	ret    

00800716 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800716:	f3 0f 1e fb          	endbr32 
  80071a:	55                   	push   %ebp
  80071b:	89 e5                	mov    %esp,%ebp
  80071d:	83 ec 18             	sub    $0x18,%esp
  800720:	8b 45 08             	mov    0x8(%ebp),%eax
  800723:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800726:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800729:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80072d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800730:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800737:	85 c0                	test   %eax,%eax
  800739:	74 26                	je     800761 <vsnprintf+0x4b>
  80073b:	85 d2                	test   %edx,%edx
  80073d:	7e 22                	jle    800761 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073f:	ff 75 14             	pushl  0x14(%ebp)
  800742:	ff 75 10             	pushl  0x10(%ebp)
  800745:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800748:	50                   	push   %eax
  800749:	68 81 02 80 00       	push   $0x800281
  80074e:	e8 70 fb ff ff       	call   8002c3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800753:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800756:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800759:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80075c:	83 c4 10             	add    $0x10,%esp
}
  80075f:	c9                   	leave  
  800760:	c3                   	ret    
		return -E_INVAL;
  800761:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800766:	eb f7                	jmp    80075f <vsnprintf+0x49>

00800768 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800768:	f3 0f 1e fb          	endbr32 
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800772:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800775:	50                   	push   %eax
  800776:	ff 75 10             	pushl  0x10(%ebp)
  800779:	ff 75 0c             	pushl  0xc(%ebp)
  80077c:	ff 75 08             	pushl  0x8(%ebp)
  80077f:	e8 92 ff ff ff       	call   800716 <vsnprintf>
	va_end(ap);

	return rc;
}
  800784:	c9                   	leave  
  800785:	c3                   	ret    

00800786 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800786:	f3 0f 1e fb          	endbr32 
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800790:	b8 00 00 00 00       	mov    $0x0,%eax
  800795:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800799:	74 05                	je     8007a0 <strlen+0x1a>
		n++;
  80079b:	83 c0 01             	add    $0x1,%eax
  80079e:	eb f5                	jmp    800795 <strlen+0xf>
	return n;
}
  8007a0:	5d                   	pop    %ebp
  8007a1:	c3                   	ret    

008007a2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007a2:	f3 0f 1e fb          	endbr32 
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ac:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007af:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b4:	39 d0                	cmp    %edx,%eax
  8007b6:	74 0d                	je     8007c5 <strnlen+0x23>
  8007b8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007bc:	74 05                	je     8007c3 <strnlen+0x21>
		n++;
  8007be:	83 c0 01             	add    $0x1,%eax
  8007c1:	eb f1                	jmp    8007b4 <strnlen+0x12>
  8007c3:	89 c2                	mov    %eax,%edx
	return n;
}
  8007c5:	89 d0                	mov    %edx,%eax
  8007c7:	5d                   	pop    %ebp
  8007c8:	c3                   	ret    

008007c9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c9:	f3 0f 1e fb          	endbr32 
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	53                   	push   %ebx
  8007d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007dc:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007e0:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007e3:	83 c0 01             	add    $0x1,%eax
  8007e6:	84 d2                	test   %dl,%dl
  8007e8:	75 f2                	jne    8007dc <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8007ea:	89 c8                	mov    %ecx,%eax
  8007ec:	5b                   	pop    %ebx
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ef:	f3 0f 1e fb          	endbr32 
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	53                   	push   %ebx
  8007f7:	83 ec 10             	sub    $0x10,%esp
  8007fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007fd:	53                   	push   %ebx
  8007fe:	e8 83 ff ff ff       	call   800786 <strlen>
  800803:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800806:	ff 75 0c             	pushl  0xc(%ebp)
  800809:	01 d8                	add    %ebx,%eax
  80080b:	50                   	push   %eax
  80080c:	e8 b8 ff ff ff       	call   8007c9 <strcpy>
	return dst;
}
  800811:	89 d8                	mov    %ebx,%eax
  800813:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800816:	c9                   	leave  
  800817:	c3                   	ret    

00800818 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800818:	f3 0f 1e fb          	endbr32 
  80081c:	55                   	push   %ebp
  80081d:	89 e5                	mov    %esp,%ebp
  80081f:	56                   	push   %esi
  800820:	53                   	push   %ebx
  800821:	8b 75 08             	mov    0x8(%ebp),%esi
  800824:	8b 55 0c             	mov    0xc(%ebp),%edx
  800827:	89 f3                	mov    %esi,%ebx
  800829:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80082c:	89 f0                	mov    %esi,%eax
  80082e:	39 d8                	cmp    %ebx,%eax
  800830:	74 11                	je     800843 <strncpy+0x2b>
		*dst++ = *src;
  800832:	83 c0 01             	add    $0x1,%eax
  800835:	0f b6 0a             	movzbl (%edx),%ecx
  800838:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80083b:	80 f9 01             	cmp    $0x1,%cl
  80083e:	83 da ff             	sbb    $0xffffffff,%edx
  800841:	eb eb                	jmp    80082e <strncpy+0x16>
	}
	return ret;
}
  800843:	89 f0                	mov    %esi,%eax
  800845:	5b                   	pop    %ebx
  800846:	5e                   	pop    %esi
  800847:	5d                   	pop    %ebp
  800848:	c3                   	ret    

00800849 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800849:	f3 0f 1e fb          	endbr32 
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	56                   	push   %esi
  800851:	53                   	push   %ebx
  800852:	8b 75 08             	mov    0x8(%ebp),%esi
  800855:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800858:	8b 55 10             	mov    0x10(%ebp),%edx
  80085b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80085d:	85 d2                	test   %edx,%edx
  80085f:	74 21                	je     800882 <strlcpy+0x39>
  800861:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800865:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800867:	39 c2                	cmp    %eax,%edx
  800869:	74 14                	je     80087f <strlcpy+0x36>
  80086b:	0f b6 19             	movzbl (%ecx),%ebx
  80086e:	84 db                	test   %bl,%bl
  800870:	74 0b                	je     80087d <strlcpy+0x34>
			*dst++ = *src++;
  800872:	83 c1 01             	add    $0x1,%ecx
  800875:	83 c2 01             	add    $0x1,%edx
  800878:	88 5a ff             	mov    %bl,-0x1(%edx)
  80087b:	eb ea                	jmp    800867 <strlcpy+0x1e>
  80087d:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80087f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800882:	29 f0                	sub    %esi,%eax
}
  800884:	5b                   	pop    %ebx
  800885:	5e                   	pop    %esi
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800888:	f3 0f 1e fb          	endbr32 
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800892:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800895:	0f b6 01             	movzbl (%ecx),%eax
  800898:	84 c0                	test   %al,%al
  80089a:	74 0c                	je     8008a8 <strcmp+0x20>
  80089c:	3a 02                	cmp    (%edx),%al
  80089e:	75 08                	jne    8008a8 <strcmp+0x20>
		p++, q++;
  8008a0:	83 c1 01             	add    $0x1,%ecx
  8008a3:	83 c2 01             	add    $0x1,%edx
  8008a6:	eb ed                	jmp    800895 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a8:	0f b6 c0             	movzbl %al,%eax
  8008ab:	0f b6 12             	movzbl (%edx),%edx
  8008ae:	29 d0                	sub    %edx,%eax
}
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b2:	f3 0f 1e fb          	endbr32 
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	53                   	push   %ebx
  8008ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c0:	89 c3                	mov    %eax,%ebx
  8008c2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008c5:	eb 06                	jmp    8008cd <strncmp+0x1b>
		n--, p++, q++;
  8008c7:	83 c0 01             	add    $0x1,%eax
  8008ca:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008cd:	39 d8                	cmp    %ebx,%eax
  8008cf:	74 16                	je     8008e7 <strncmp+0x35>
  8008d1:	0f b6 08             	movzbl (%eax),%ecx
  8008d4:	84 c9                	test   %cl,%cl
  8008d6:	74 04                	je     8008dc <strncmp+0x2a>
  8008d8:	3a 0a                	cmp    (%edx),%cl
  8008da:	74 eb                	je     8008c7 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008dc:	0f b6 00             	movzbl (%eax),%eax
  8008df:	0f b6 12             	movzbl (%edx),%edx
  8008e2:	29 d0                	sub    %edx,%eax
}
  8008e4:	5b                   	pop    %ebx
  8008e5:	5d                   	pop    %ebp
  8008e6:	c3                   	ret    
		return 0;
  8008e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ec:	eb f6                	jmp    8008e4 <strncmp+0x32>

008008ee <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ee:	f3 0f 1e fb          	endbr32 
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008fc:	0f b6 10             	movzbl (%eax),%edx
  8008ff:	84 d2                	test   %dl,%dl
  800901:	74 09                	je     80090c <strchr+0x1e>
		if (*s == c)
  800903:	38 ca                	cmp    %cl,%dl
  800905:	74 0a                	je     800911 <strchr+0x23>
	for (; *s; s++)
  800907:	83 c0 01             	add    $0x1,%eax
  80090a:	eb f0                	jmp    8008fc <strchr+0xe>
			return (char *) s;
	return 0;
  80090c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800911:	5d                   	pop    %ebp
  800912:	c3                   	ret    

00800913 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800913:	f3 0f 1e fb          	endbr32 
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	8b 45 08             	mov    0x8(%ebp),%eax
  80091d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800921:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800924:	38 ca                	cmp    %cl,%dl
  800926:	74 09                	je     800931 <strfind+0x1e>
  800928:	84 d2                	test   %dl,%dl
  80092a:	74 05                	je     800931 <strfind+0x1e>
	for (; *s; s++)
  80092c:	83 c0 01             	add    $0x1,%eax
  80092f:	eb f0                	jmp    800921 <strfind+0xe>
			break;
	return (char *) s;
}
  800931:	5d                   	pop    %ebp
  800932:	c3                   	ret    

00800933 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800933:	f3 0f 1e fb          	endbr32 
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	57                   	push   %edi
  80093b:	56                   	push   %esi
  80093c:	53                   	push   %ebx
  80093d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800940:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800943:	85 c9                	test   %ecx,%ecx
  800945:	74 31                	je     800978 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800947:	89 f8                	mov    %edi,%eax
  800949:	09 c8                	or     %ecx,%eax
  80094b:	a8 03                	test   $0x3,%al
  80094d:	75 23                	jne    800972 <memset+0x3f>
		c &= 0xFF;
  80094f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800953:	89 d3                	mov    %edx,%ebx
  800955:	c1 e3 08             	shl    $0x8,%ebx
  800958:	89 d0                	mov    %edx,%eax
  80095a:	c1 e0 18             	shl    $0x18,%eax
  80095d:	89 d6                	mov    %edx,%esi
  80095f:	c1 e6 10             	shl    $0x10,%esi
  800962:	09 f0                	or     %esi,%eax
  800964:	09 c2                	or     %eax,%edx
  800966:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800968:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80096b:	89 d0                	mov    %edx,%eax
  80096d:	fc                   	cld    
  80096e:	f3 ab                	rep stos %eax,%es:(%edi)
  800970:	eb 06                	jmp    800978 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800972:	8b 45 0c             	mov    0xc(%ebp),%eax
  800975:	fc                   	cld    
  800976:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800978:	89 f8                	mov    %edi,%eax
  80097a:	5b                   	pop    %ebx
  80097b:	5e                   	pop    %esi
  80097c:	5f                   	pop    %edi
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80097f:	f3 0f 1e fb          	endbr32 
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	57                   	push   %edi
  800987:	56                   	push   %esi
  800988:	8b 45 08             	mov    0x8(%ebp),%eax
  80098b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800991:	39 c6                	cmp    %eax,%esi
  800993:	73 32                	jae    8009c7 <memmove+0x48>
  800995:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800998:	39 c2                	cmp    %eax,%edx
  80099a:	76 2b                	jbe    8009c7 <memmove+0x48>
		s += n;
		d += n;
  80099c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099f:	89 fe                	mov    %edi,%esi
  8009a1:	09 ce                	or     %ecx,%esi
  8009a3:	09 d6                	or     %edx,%esi
  8009a5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ab:	75 0e                	jne    8009bb <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009ad:	83 ef 04             	sub    $0x4,%edi
  8009b0:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009b6:	fd                   	std    
  8009b7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b9:	eb 09                	jmp    8009c4 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009bb:	83 ef 01             	sub    $0x1,%edi
  8009be:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009c1:	fd                   	std    
  8009c2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c4:	fc                   	cld    
  8009c5:	eb 1a                	jmp    8009e1 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c7:	89 c2                	mov    %eax,%edx
  8009c9:	09 ca                	or     %ecx,%edx
  8009cb:	09 f2                	or     %esi,%edx
  8009cd:	f6 c2 03             	test   $0x3,%dl
  8009d0:	75 0a                	jne    8009dc <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009d2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009d5:	89 c7                	mov    %eax,%edi
  8009d7:	fc                   	cld    
  8009d8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009da:	eb 05                	jmp    8009e1 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8009dc:	89 c7                	mov    %eax,%edi
  8009de:	fc                   	cld    
  8009df:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e1:	5e                   	pop    %esi
  8009e2:	5f                   	pop    %edi
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    

008009e5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009e5:	f3 0f 1e fb          	endbr32 
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009ef:	ff 75 10             	pushl  0x10(%ebp)
  8009f2:	ff 75 0c             	pushl  0xc(%ebp)
  8009f5:	ff 75 08             	pushl  0x8(%ebp)
  8009f8:	e8 82 ff ff ff       	call   80097f <memmove>
}
  8009fd:	c9                   	leave  
  8009fe:	c3                   	ret    

008009ff <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ff:	f3 0f 1e fb          	endbr32 
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	56                   	push   %esi
  800a07:	53                   	push   %ebx
  800a08:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0e:	89 c6                	mov    %eax,%esi
  800a10:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a13:	39 f0                	cmp    %esi,%eax
  800a15:	74 1c                	je     800a33 <memcmp+0x34>
		if (*s1 != *s2)
  800a17:	0f b6 08             	movzbl (%eax),%ecx
  800a1a:	0f b6 1a             	movzbl (%edx),%ebx
  800a1d:	38 d9                	cmp    %bl,%cl
  800a1f:	75 08                	jne    800a29 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a21:	83 c0 01             	add    $0x1,%eax
  800a24:	83 c2 01             	add    $0x1,%edx
  800a27:	eb ea                	jmp    800a13 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a29:	0f b6 c1             	movzbl %cl,%eax
  800a2c:	0f b6 db             	movzbl %bl,%ebx
  800a2f:	29 d8                	sub    %ebx,%eax
  800a31:	eb 05                	jmp    800a38 <memcmp+0x39>
	}

	return 0;
  800a33:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a38:	5b                   	pop    %ebx
  800a39:	5e                   	pop    %esi
  800a3a:	5d                   	pop    %ebp
  800a3b:	c3                   	ret    

00800a3c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a3c:	f3 0f 1e fb          	endbr32 
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	8b 45 08             	mov    0x8(%ebp),%eax
  800a46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a49:	89 c2                	mov    %eax,%edx
  800a4b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a4e:	39 d0                	cmp    %edx,%eax
  800a50:	73 09                	jae    800a5b <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a52:	38 08                	cmp    %cl,(%eax)
  800a54:	74 05                	je     800a5b <memfind+0x1f>
	for (; s < ends; s++)
  800a56:	83 c0 01             	add    $0x1,%eax
  800a59:	eb f3                	jmp    800a4e <memfind+0x12>
			break;
	return (void *) s;
}
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a5d:	f3 0f 1e fb          	endbr32 
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	57                   	push   %edi
  800a65:	56                   	push   %esi
  800a66:	53                   	push   %ebx
  800a67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6d:	eb 03                	jmp    800a72 <strtol+0x15>
		s++;
  800a6f:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a72:	0f b6 01             	movzbl (%ecx),%eax
  800a75:	3c 20                	cmp    $0x20,%al
  800a77:	74 f6                	je     800a6f <strtol+0x12>
  800a79:	3c 09                	cmp    $0x9,%al
  800a7b:	74 f2                	je     800a6f <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a7d:	3c 2b                	cmp    $0x2b,%al
  800a7f:	74 2a                	je     800aab <strtol+0x4e>
	int neg = 0;
  800a81:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a86:	3c 2d                	cmp    $0x2d,%al
  800a88:	74 2b                	je     800ab5 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a90:	75 0f                	jne    800aa1 <strtol+0x44>
  800a92:	80 39 30             	cmpb   $0x30,(%ecx)
  800a95:	74 28                	je     800abf <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a97:	85 db                	test   %ebx,%ebx
  800a99:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a9e:	0f 44 d8             	cmove  %eax,%ebx
  800aa1:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa6:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800aa9:	eb 46                	jmp    800af1 <strtol+0x94>
		s++;
  800aab:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800aae:	bf 00 00 00 00       	mov    $0x0,%edi
  800ab3:	eb d5                	jmp    800a8a <strtol+0x2d>
		s++, neg = 1;
  800ab5:	83 c1 01             	add    $0x1,%ecx
  800ab8:	bf 01 00 00 00       	mov    $0x1,%edi
  800abd:	eb cb                	jmp    800a8a <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800abf:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ac3:	74 0e                	je     800ad3 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ac5:	85 db                	test   %ebx,%ebx
  800ac7:	75 d8                	jne    800aa1 <strtol+0x44>
		s++, base = 8;
  800ac9:	83 c1 01             	add    $0x1,%ecx
  800acc:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ad1:	eb ce                	jmp    800aa1 <strtol+0x44>
		s += 2, base = 16;
  800ad3:	83 c1 02             	add    $0x2,%ecx
  800ad6:	bb 10 00 00 00       	mov    $0x10,%ebx
  800adb:	eb c4                	jmp    800aa1 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800add:	0f be d2             	movsbl %dl,%edx
  800ae0:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ae3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ae6:	7d 3a                	jge    800b22 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ae8:	83 c1 01             	add    $0x1,%ecx
  800aeb:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aef:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800af1:	0f b6 11             	movzbl (%ecx),%edx
  800af4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800af7:	89 f3                	mov    %esi,%ebx
  800af9:	80 fb 09             	cmp    $0x9,%bl
  800afc:	76 df                	jbe    800add <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800afe:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b01:	89 f3                	mov    %esi,%ebx
  800b03:	80 fb 19             	cmp    $0x19,%bl
  800b06:	77 08                	ja     800b10 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b08:	0f be d2             	movsbl %dl,%edx
  800b0b:	83 ea 57             	sub    $0x57,%edx
  800b0e:	eb d3                	jmp    800ae3 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b10:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b13:	89 f3                	mov    %esi,%ebx
  800b15:	80 fb 19             	cmp    $0x19,%bl
  800b18:	77 08                	ja     800b22 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b1a:	0f be d2             	movsbl %dl,%edx
  800b1d:	83 ea 37             	sub    $0x37,%edx
  800b20:	eb c1                	jmp    800ae3 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b22:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b26:	74 05                	je     800b2d <strtol+0xd0>
		*endptr = (char *) s;
  800b28:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b2b:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b2d:	89 c2                	mov    %eax,%edx
  800b2f:	f7 da                	neg    %edx
  800b31:	85 ff                	test   %edi,%edi
  800b33:	0f 45 c2             	cmovne %edx,%eax
}
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5f                   	pop    %edi
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b3b:	f3 0f 1e fb          	endbr32 
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	57                   	push   %edi
  800b43:	56                   	push   %esi
  800b44:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b45:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b50:	89 c3                	mov    %eax,%ebx
  800b52:	89 c7                	mov    %eax,%edi
  800b54:	89 c6                	mov    %eax,%esi
  800b56:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <sys_cgetc>:

int
sys_cgetc(void)
{
  800b5d:	f3 0f 1e fb          	endbr32 
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	57                   	push   %edi
  800b65:	56                   	push   %esi
  800b66:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b67:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b71:	89 d1                	mov    %edx,%ecx
  800b73:	89 d3                	mov    %edx,%ebx
  800b75:	89 d7                	mov    %edx,%edi
  800b77:	89 d6                	mov    %edx,%esi
  800b79:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5f                   	pop    %edi
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b80:	f3 0f 1e fb          	endbr32 
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	57                   	push   %edi
  800b88:	56                   	push   %esi
  800b89:	53                   	push   %ebx
  800b8a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b8d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b92:	8b 55 08             	mov    0x8(%ebp),%edx
  800b95:	b8 03 00 00 00       	mov    $0x3,%eax
  800b9a:	89 cb                	mov    %ecx,%ebx
  800b9c:	89 cf                	mov    %ecx,%edi
  800b9e:	89 ce                	mov    %ecx,%esi
  800ba0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ba2:	85 c0                	test   %eax,%eax
  800ba4:	7f 08                	jg     800bae <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ba6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bae:	83 ec 0c             	sub    $0xc,%esp
  800bb1:	50                   	push   %eax
  800bb2:	6a 03                	push   $0x3
  800bb4:	68 5f 17 80 00       	push   $0x80175f
  800bb9:	6a 23                	push   $0x23
  800bbb:	68 7c 17 80 00       	push   $0x80177c
  800bc0:	e8 a3 04 00 00       	call   801068 <_panic>

00800bc5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc5:	f3 0f 1e fb          	endbr32 
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	57                   	push   %edi
  800bcd:	56                   	push   %esi
  800bce:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bcf:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd4:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd9:	89 d1                	mov    %edx,%ecx
  800bdb:	89 d3                	mov    %edx,%ebx
  800bdd:	89 d7                	mov    %edx,%edi
  800bdf:	89 d6                	mov    %edx,%esi
  800be1:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be3:	5b                   	pop    %ebx
  800be4:	5e                   	pop    %esi
  800be5:	5f                   	pop    %edi
  800be6:	5d                   	pop    %ebp
  800be7:	c3                   	ret    

00800be8 <sys_yield>:

void
sys_yield(void)
{
  800be8:	f3 0f 1e fb          	endbr32 
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	57                   	push   %edi
  800bf0:	56                   	push   %esi
  800bf1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bf2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bfc:	89 d1                	mov    %edx,%ecx
  800bfe:	89 d3                	mov    %edx,%ebx
  800c00:	89 d7                	mov    %edx,%edi
  800c02:	89 d6                	mov    %edx,%esi
  800c04:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c06:	5b                   	pop    %ebx
  800c07:	5e                   	pop    %esi
  800c08:	5f                   	pop    %edi
  800c09:	5d                   	pop    %ebp
  800c0a:	c3                   	ret    

00800c0b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c0b:	f3 0f 1e fb          	endbr32 
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	57                   	push   %edi
  800c13:	56                   	push   %esi
  800c14:	53                   	push   %ebx
  800c15:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c18:	be 00 00 00 00       	mov    $0x0,%esi
  800c1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c23:	b8 04 00 00 00       	mov    $0x4,%eax
  800c28:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c2b:	89 f7                	mov    %esi,%edi
  800c2d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c2f:	85 c0                	test   %eax,%eax
  800c31:	7f 08                	jg     800c3b <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3b:	83 ec 0c             	sub    $0xc,%esp
  800c3e:	50                   	push   %eax
  800c3f:	6a 04                	push   $0x4
  800c41:	68 5f 17 80 00       	push   $0x80175f
  800c46:	6a 23                	push   $0x23
  800c48:	68 7c 17 80 00       	push   $0x80177c
  800c4d:	e8 16 04 00 00       	call   801068 <_panic>

00800c52 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c52:	f3 0f 1e fb          	endbr32 
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	57                   	push   %edi
  800c5a:	56                   	push   %esi
  800c5b:	53                   	push   %ebx
  800c5c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c65:	b8 05 00 00 00       	mov    $0x5,%eax
  800c6a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c70:	8b 75 18             	mov    0x18(%ebp),%esi
  800c73:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c75:	85 c0                	test   %eax,%eax
  800c77:	7f 08                	jg     800c81 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7c:	5b                   	pop    %ebx
  800c7d:	5e                   	pop    %esi
  800c7e:	5f                   	pop    %edi
  800c7f:	5d                   	pop    %ebp
  800c80:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c81:	83 ec 0c             	sub    $0xc,%esp
  800c84:	50                   	push   %eax
  800c85:	6a 05                	push   $0x5
  800c87:	68 5f 17 80 00       	push   $0x80175f
  800c8c:	6a 23                	push   $0x23
  800c8e:	68 7c 17 80 00       	push   $0x80177c
  800c93:	e8 d0 03 00 00       	call   801068 <_panic>

00800c98 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c98:	f3 0f 1e fb          	endbr32 
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	57                   	push   %edi
  800ca0:	56                   	push   %esi
  800ca1:	53                   	push   %ebx
  800ca2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ca5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800caa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb0:	b8 06 00 00 00       	mov    $0x6,%eax
  800cb5:	89 df                	mov    %ebx,%edi
  800cb7:	89 de                	mov    %ebx,%esi
  800cb9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cbb:	85 c0                	test   %eax,%eax
  800cbd:	7f 08                	jg     800cc7 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc2:	5b                   	pop    %ebx
  800cc3:	5e                   	pop    %esi
  800cc4:	5f                   	pop    %edi
  800cc5:	5d                   	pop    %ebp
  800cc6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc7:	83 ec 0c             	sub    $0xc,%esp
  800cca:	50                   	push   %eax
  800ccb:	6a 06                	push   $0x6
  800ccd:	68 5f 17 80 00       	push   $0x80175f
  800cd2:	6a 23                	push   $0x23
  800cd4:	68 7c 17 80 00       	push   $0x80177c
  800cd9:	e8 8a 03 00 00       	call   801068 <_panic>

00800cde <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cde:	f3 0f 1e fb          	endbr32 
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	57                   	push   %edi
  800ce6:	56                   	push   %esi
  800ce7:	53                   	push   %ebx
  800ce8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ceb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf6:	b8 08 00 00 00       	mov    $0x8,%eax
  800cfb:	89 df                	mov    %ebx,%edi
  800cfd:	89 de                	mov    %ebx,%esi
  800cff:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d01:	85 c0                	test   %eax,%eax
  800d03:	7f 08                	jg     800d0d <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d08:	5b                   	pop    %ebx
  800d09:	5e                   	pop    %esi
  800d0a:	5f                   	pop    %edi
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0d:	83 ec 0c             	sub    $0xc,%esp
  800d10:	50                   	push   %eax
  800d11:	6a 08                	push   $0x8
  800d13:	68 5f 17 80 00       	push   $0x80175f
  800d18:	6a 23                	push   $0x23
  800d1a:	68 7c 17 80 00       	push   $0x80177c
  800d1f:	e8 44 03 00 00       	call   801068 <_panic>

00800d24 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d24:	f3 0f 1e fb          	endbr32 
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	57                   	push   %edi
  800d2c:	56                   	push   %esi
  800d2d:	53                   	push   %ebx
  800d2e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d31:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d36:	8b 55 08             	mov    0x8(%ebp),%edx
  800d39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3c:	b8 09 00 00 00       	mov    $0x9,%eax
  800d41:	89 df                	mov    %ebx,%edi
  800d43:	89 de                	mov    %ebx,%esi
  800d45:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d47:	85 c0                	test   %eax,%eax
  800d49:	7f 08                	jg     800d53 <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5f                   	pop    %edi
  800d51:	5d                   	pop    %ebp
  800d52:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d53:	83 ec 0c             	sub    $0xc,%esp
  800d56:	50                   	push   %eax
  800d57:	6a 09                	push   $0x9
  800d59:	68 5f 17 80 00       	push   $0x80175f
  800d5e:	6a 23                	push   $0x23
  800d60:	68 7c 17 80 00       	push   $0x80177c
  800d65:	e8 fe 02 00 00       	call   801068 <_panic>

00800d6a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d6a:	f3 0f 1e fb          	endbr32 
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	57                   	push   %edi
  800d72:	56                   	push   %esi
  800d73:	53                   	push   %ebx
  800d74:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d77:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d82:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d87:	89 df                	mov    %ebx,%edi
  800d89:	89 de                	mov    %ebx,%esi
  800d8b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d8d:	85 c0                	test   %eax,%eax
  800d8f:	7f 08                	jg     800d99 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d94:	5b                   	pop    %ebx
  800d95:	5e                   	pop    %esi
  800d96:	5f                   	pop    %edi
  800d97:	5d                   	pop    %ebp
  800d98:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d99:	83 ec 0c             	sub    $0xc,%esp
  800d9c:	50                   	push   %eax
  800d9d:	6a 0a                	push   $0xa
  800d9f:	68 5f 17 80 00       	push   $0x80175f
  800da4:	6a 23                	push   $0x23
  800da6:	68 7c 17 80 00       	push   $0x80177c
  800dab:	e8 b8 02 00 00       	call   801068 <_panic>

00800db0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800db0:	f3 0f 1e fb          	endbr32 
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	57                   	push   %edi
  800db8:	56                   	push   %esi
  800db9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dba:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc0:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dc5:	be 00 00 00 00       	mov    $0x0,%esi
  800dca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dcd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dd0:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dd2:	5b                   	pop    %ebx
  800dd3:	5e                   	pop    %esi
  800dd4:	5f                   	pop    %edi
  800dd5:	5d                   	pop    %ebp
  800dd6:	c3                   	ret    

00800dd7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dd7:	f3 0f 1e fb          	endbr32 
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	57                   	push   %edi
  800ddf:	56                   	push   %esi
  800de0:	53                   	push   %ebx
  800de1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800de4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800de9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dec:	b8 0d 00 00 00       	mov    $0xd,%eax
  800df1:	89 cb                	mov    %ecx,%ebx
  800df3:	89 cf                	mov    %ecx,%edi
  800df5:	89 ce                	mov    %ecx,%esi
  800df7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800df9:	85 c0                	test   %eax,%eax
  800dfb:	7f 08                	jg     800e05 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e05:	83 ec 0c             	sub    $0xc,%esp
  800e08:	50                   	push   %eax
  800e09:	6a 0d                	push   $0xd
  800e0b:	68 5f 17 80 00       	push   $0x80175f
  800e10:	6a 23                	push   $0x23
  800e12:	68 7c 17 80 00       	push   $0x80177c
  800e17:	e8 4c 02 00 00       	call   801068 <_panic>

00800e1c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e1c:	f3 0f 1e fb          	endbr32 
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
  800e23:	53                   	push   %ebx
  800e24:	83 ec 04             	sub    $0x4,%esp
  800e27:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e2a:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if ( !(err & FEC_WR) ||
  800e2c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e30:	74 75                	je     800ea7 <pgfault+0x8b>
            !(uvpt[PGNUM(addr)] | PTE_COW) ) {
  800e32:	89 d8                	mov    %ebx,%eax
  800e34:	c1 e8 0c             	shr    $0xc,%eax
  800e37:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, (void *)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0) {
  800e3e:	83 ec 04             	sub    $0x4,%esp
  800e41:	6a 07                	push   $0x7
  800e43:	68 00 f0 7f 00       	push   $0x7ff000
  800e48:	6a 00                	push   $0x0
  800e4a:	e8 bc fd ff ff       	call   800c0b <sys_page_alloc>
  800e4f:	83 c4 10             	add    $0x10,%esp
  800e52:	85 c0                	test   %eax,%eax
  800e54:	78 65                	js     800ebb <pgfault+0x9f>
        panic("sys_page_alloc failed %e\n", r);
    }
    memmove((void *)PFTEMP, (void *)PTE_ADDR(addr), PGSIZE);
  800e56:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800e5c:	83 ec 04             	sub    $0x4,%esp
  800e5f:	68 00 10 00 00       	push   $0x1000
  800e64:	53                   	push   %ebx
  800e65:	68 00 f0 7f 00       	push   $0x7ff000
  800e6a:	e8 10 fb ff ff       	call   80097f <memmove>
    if ((r = sys_page_map(0, (void *)PFTEMP,
  800e6f:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e76:	53                   	push   %ebx
  800e77:	6a 00                	push   $0x0
  800e79:	68 00 f0 7f 00       	push   $0x7ff000
  800e7e:	6a 00                	push   $0x0
  800e80:	e8 cd fd ff ff       	call   800c52 <sys_page_map>
  800e85:	83 c4 20             	add    $0x20,%esp
  800e88:	85 c0                	test   %eax,%eax
  800e8a:	78 41                	js     800ecd <pgfault+0xb1>
                0, (void *)PTE_ADDR(addr), PTE_P | PTE_U | PTE_W)) < 0) {
        panic("sys_page_map failed %e\n", r);
    }
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0) {
  800e8c:	83 ec 08             	sub    $0x8,%esp
  800e8f:	68 00 f0 7f 00       	push   $0x7ff000
  800e94:	6a 00                	push   $0x0
  800e96:	e8 fd fd ff ff       	call   800c98 <sys_page_unmap>
  800e9b:	83 c4 10             	add    $0x10,%esp
  800e9e:	85 c0                	test   %eax,%eax
  800ea0:	78 3d                	js     800edf <pgfault+0xc3>
        panic("sys_page_unmap failed %e\n", r);
    }

}
  800ea2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ea5:	c9                   	leave  
  800ea6:	c3                   	ret    
        panic("Not a copy-on-write page");
  800ea7:	83 ec 04             	sub    $0x4,%esp
  800eaa:	68 8a 17 80 00       	push   $0x80178a
  800eaf:	6a 1e                	push   $0x1e
  800eb1:	68 a3 17 80 00       	push   $0x8017a3
  800eb6:	e8 ad 01 00 00       	call   801068 <_panic>
        panic("sys_page_alloc failed %e\n", r);
  800ebb:	50                   	push   %eax
  800ebc:	68 ae 17 80 00       	push   $0x8017ae
  800ec1:	6a 2a                	push   $0x2a
  800ec3:	68 a3 17 80 00       	push   $0x8017a3
  800ec8:	e8 9b 01 00 00       	call   801068 <_panic>
        panic("sys_page_map failed %e\n", r);
  800ecd:	50                   	push   %eax
  800ece:	68 c8 17 80 00       	push   $0x8017c8
  800ed3:	6a 2f                	push   $0x2f
  800ed5:	68 a3 17 80 00       	push   $0x8017a3
  800eda:	e8 89 01 00 00       	call   801068 <_panic>
        panic("sys_page_unmap failed %e\n", r);
  800edf:	50                   	push   %eax
  800ee0:	68 e0 17 80 00       	push   $0x8017e0
  800ee5:	6a 32                	push   $0x32
  800ee7:	68 a3 17 80 00       	push   $0x8017a3
  800eec:	e8 77 01 00 00       	call   801068 <_panic>

00800ef1 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ef1:	f3 0f 1e fb          	endbr32 
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
  800ef8:	57                   	push   %edi
  800ef9:	56                   	push   %esi
  800efa:	53                   	push   %ebx
  800efb:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");

    // 1. set pgfault handler.
    set_pgfault_handler(pgfault);
  800efe:	68 1c 0e 80 00       	push   $0x800e1c
  800f03:	e8 aa 01 00 00       	call   8010b2 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f08:	b8 07 00 00 00       	mov    $0x7,%eax
  800f0d:	cd 30                	int    $0x30
  800f0f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f12:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    // 2. exofork.
    envid_t envid = sys_exofork();

    if (envid < 0)
  800f15:	83 c4 10             	add    $0x10,%esp
  800f18:	85 c0                	test   %eax,%eax
  800f1a:	78 2a                	js     800f46 <fork+0x55>
        thisenv = &envs[ENVX(my_envid)];
        return 0;
    }
    else {
        // parent
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800f1c:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (envid == 0) {
  800f21:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800f25:	75 69                	jne    800f90 <fork+0x9f>
        envid_t my_envid = sys_getenvid();
  800f27:	e8 99 fc ff ff       	call   800bc5 <sys_getenvid>
        thisenv = &envs[ENVX(my_envid)];
  800f2c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f31:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f34:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f39:	a3 04 20 80 00       	mov    %eax,0x802004
        return 0;
  800f3e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f41:	e9 fc 00 00 00       	jmp    801042 <fork+0x151>
        panic("fork, sys_exofork %e", envid);
  800f46:	50                   	push   %eax
  800f47:	68 fa 17 80 00       	push   $0x8017fa
  800f4c:	6a 7b                	push   $0x7b
  800f4e:	68 a3 17 80 00       	push   $0x8017a3
  800f53:	e8 10 01 00 00       	call   801068 <_panic>
    if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0) {
  800f58:	83 ec 0c             	sub    $0xc,%esp
  800f5b:	57                   	push   %edi
  800f5c:	56                   	push   %esi
  800f5d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f60:	56                   	push   %esi
  800f61:	6a 00                	push   $0x0
  800f63:	e8 ea fc ff ff       	call   800c52 <sys_page_map>
  800f68:	83 c4 20             	add    $0x20,%esp
  800f6b:	85 c0                	test   %eax,%eax
  800f6d:	78 69                	js     800fd8 <fork+0xe7>
        if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0) {
  800f6f:	83 ec 0c             	sub    $0xc,%esp
  800f72:	57                   	push   %edi
  800f73:	56                   	push   %esi
  800f74:	6a 00                	push   $0x0
  800f76:	56                   	push   %esi
  800f77:	6a 00                	push   $0x0
  800f79:	e8 d4 fc ff ff       	call   800c52 <sys_page_map>
  800f7e:	83 c4 20             	add    $0x20,%esp
  800f81:	85 c0                	test   %eax,%eax
  800f83:	78 65                	js     800fea <fork+0xf9>
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800f85:	83 c3 01             	add    $0x1,%ebx
  800f88:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  800f8e:	74 6c                	je     800ffc <fork+0x10b>
  800f90:	89 de                	mov    %ebx,%esi
  800f92:	c1 e6 0c             	shl    $0xc,%esi
            uintptr_t pgaddr = pn << PGSHIFT;
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800f95:	89 f0                	mov    %esi,%eax
  800f97:	c1 e8 16             	shr    $0x16,%eax
  800f9a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fa1:	a8 01                	test   $0x1,%al
  800fa3:	74 e0                	je     800f85 <fork+0x94>
                    (uvpt[pn] & PTE_P) ) {
  800fa5:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800fac:	a8 01                	test   $0x1,%al
  800fae:	74 d5                	je     800f85 <fork+0x94>
    pte_t pte = uvpt[pn];
  800fb0:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
    int perm = PTE_U | PTE_P;
  800fb7:	bf 05 00 00 00       	mov    $0x5,%edi
    if ( ((pte & PTE_W) || (pte & PTE_COW)) && !(pte & PTE_SHARE)) {
  800fbc:	a9 02 08 00 00       	test   $0x802,%eax
  800fc1:	74 95                	je     800f58 <fork+0x67>
  800fc3:	25 00 04 00 00       	and    $0x400,%eax
        perm |= PTE_COW;
  800fc8:	83 f8 01             	cmp    $0x1,%eax
  800fcb:	19 ff                	sbb    %edi,%edi
  800fcd:	81 e7 00 08 00 00    	and    $0x800,%edi
  800fd3:	83 c7 05             	add    $0x5,%edi
  800fd6:	eb 80                	jmp    800f58 <fork+0x67>
        panic("sys_page_map others failed %e\n", r);
  800fd8:	50                   	push   %eax
  800fd9:	68 44 18 80 00       	push   $0x801844
  800fde:	6a 51                	push   $0x51
  800fe0:	68 a3 17 80 00       	push   $0x8017a3
  800fe5:	e8 7e 00 00 00       	call   801068 <_panic>
            panic("sys_page_map mine failed %e\n", r);
  800fea:	50                   	push   %eax
  800feb:	68 0f 18 80 00       	push   $0x80180f
  800ff0:	6a 56                	push   $0x56
  800ff2:	68 a3 17 80 00       	push   $0x8017a3
  800ff7:	e8 6c 00 00 00       	call   801068 <_panic>
            }
        }

        int r;

        if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE),
  800ffc:	83 ec 04             	sub    $0x4,%esp
  800fff:	6a 07                	push   $0x7
  801001:	68 00 f0 bf ee       	push   $0xeebff000
  801006:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801009:	57                   	push   %edi
  80100a:	e8 fc fb ff ff       	call   800c0b <sys_page_alloc>
  80100f:	83 c4 10             	add    $0x10,%esp
  801012:	85 c0                	test   %eax,%eax
  801014:	78 2c                	js     801042 <fork+0x151>
                    PTE_U | PTE_W | PTE_P)) < 0) {
            return r;
        }

        if ((r = sys_env_set_pgfault_upcall(envid,
                        thisenv->env_pgfault_upcall)) < 0) {
  801016:	a1 04 20 80 00       	mov    0x802004,%eax
        if ((r = sys_env_set_pgfault_upcall(envid,
  80101b:	8b 40 64             	mov    0x64(%eax),%eax
  80101e:	83 ec 08             	sub    $0x8,%esp
  801021:	50                   	push   %eax
  801022:	57                   	push   %edi
  801023:	e8 42 fd ff ff       	call   800d6a <sys_env_set_pgfault_upcall>
  801028:	83 c4 10             	add    $0x10,%esp
  80102b:	85 c0                	test   %eax,%eax
  80102d:	78 13                	js     801042 <fork+0x151>
            return r;
        }

        if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  80102f:	83 ec 08             	sub    $0x8,%esp
  801032:	6a 02                	push   $0x2
  801034:	57                   	push   %edi
  801035:	e8 a4 fc ff ff       	call   800cde <sys_env_set_status>
  80103a:	83 c4 10             	add    $0x10,%esp
            return r;
        }
        return envid;
  80103d:	85 c0                	test   %eax,%eax
  80103f:	0f 49 c7             	cmovns %edi,%eax
    }

}
  801042:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801045:	5b                   	pop    %ebx
  801046:	5e                   	pop    %esi
  801047:	5f                   	pop    %edi
  801048:	5d                   	pop    %ebp
  801049:	c3                   	ret    

0080104a <sfork>:

// Challenge!
int
sfork(void)
{
  80104a:	f3 0f 1e fb          	endbr32 
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
  801051:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801054:	68 2c 18 80 00       	push   $0x80182c
  801059:	68 a5 00 00 00       	push   $0xa5
  80105e:	68 a3 17 80 00       	push   $0x8017a3
  801063:	e8 00 00 00 00       	call   801068 <_panic>

00801068 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801068:	f3 0f 1e fb          	endbr32 
  80106c:	55                   	push   %ebp
  80106d:	89 e5                	mov    %esp,%ebp
  80106f:	56                   	push   %esi
  801070:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801071:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801074:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80107a:	e8 46 fb ff ff       	call   800bc5 <sys_getenvid>
  80107f:	83 ec 0c             	sub    $0xc,%esp
  801082:	ff 75 0c             	pushl  0xc(%ebp)
  801085:	ff 75 08             	pushl  0x8(%ebp)
  801088:	56                   	push   %esi
  801089:	50                   	push   %eax
  80108a:	68 64 18 80 00       	push   $0x801864
  80108f:	e8 2c f1 ff ff       	call   8001c0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801094:	83 c4 18             	add    $0x18,%esp
  801097:	53                   	push   %ebx
  801098:	ff 75 10             	pushl  0x10(%ebp)
  80109b:	e8 cb f0 ff ff       	call   80016b <vcprintf>
	cprintf("\n");
  8010a0:	c7 04 24 54 14 80 00 	movl   $0x801454,(%esp)
  8010a7:	e8 14 f1 ff ff       	call   8001c0 <cprintf>
  8010ac:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010af:	cc                   	int3   
  8010b0:	eb fd                	jmp    8010af <_panic+0x47>

008010b2 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8010b2:	f3 0f 1e fb          	endbr32 
  8010b6:	55                   	push   %ebp
  8010b7:	89 e5                	mov    %esp,%ebp
  8010b9:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8010bc:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  8010c3:	74 0a                	je     8010cf <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8010c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c8:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8010cd:	c9                   	leave  
  8010ce:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  8010cf:	83 ec 0c             	sub    $0xc,%esp
  8010d2:	68 87 18 80 00       	push   $0x801887
  8010d7:	e8 e4 f0 ff ff       	call   8001c0 <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  8010dc:	83 c4 0c             	add    $0xc,%esp
  8010df:	6a 07                	push   $0x7
  8010e1:	68 00 f0 bf ee       	push   $0xeebff000
  8010e6:	6a 00                	push   $0x0
  8010e8:	e8 1e fb ff ff       	call   800c0b <sys_page_alloc>
  8010ed:	83 c4 10             	add    $0x10,%esp
  8010f0:	85 c0                	test   %eax,%eax
  8010f2:	78 2a                	js     80111e <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  8010f4:	83 ec 08             	sub    $0x8,%esp
  8010f7:	68 32 11 80 00       	push   $0x801132
  8010fc:	6a 00                	push   $0x0
  8010fe:	e8 67 fc ff ff       	call   800d6a <sys_env_set_pgfault_upcall>
  801103:	83 c4 10             	add    $0x10,%esp
  801106:	85 c0                	test   %eax,%eax
  801108:	79 bb                	jns    8010c5 <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  80110a:	83 ec 04             	sub    $0x4,%esp
  80110d:	68 c4 18 80 00       	push   $0x8018c4
  801112:	6a 25                	push   $0x25
  801114:	68 b4 18 80 00       	push   $0x8018b4
  801119:	e8 4a ff ff ff       	call   801068 <_panic>
            panic("Allocation of UXSTACK failed!");
  80111e:	83 ec 04             	sub    $0x4,%esp
  801121:	68 96 18 80 00       	push   $0x801896
  801126:	6a 22                	push   $0x22
  801128:	68 b4 18 80 00       	push   $0x8018b4
  80112d:	e8 36 ff ff ff       	call   801068 <_panic>

00801132 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801132:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801133:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801138:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80113a:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  80113d:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  801141:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  801145:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  801148:	83 c4 08             	add    $0x8,%esp
    popa
  80114b:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

    add $0x4, %esp
  80114c:	83 c4 04             	add    $0x4,%esp
    popf
  80114f:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  801150:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  801153:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  801157:	c3                   	ret    
  801158:	66 90                	xchg   %ax,%ax
  80115a:	66 90                	xchg   %ax,%ax
  80115c:	66 90                	xchg   %ax,%ax
  80115e:	66 90                	xchg   %ax,%ax

00801160 <__udivdi3>:
  801160:	f3 0f 1e fb          	endbr32 
  801164:	55                   	push   %ebp
  801165:	57                   	push   %edi
  801166:	56                   	push   %esi
  801167:	53                   	push   %ebx
  801168:	83 ec 1c             	sub    $0x1c,%esp
  80116b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80116f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801173:	8b 74 24 34          	mov    0x34(%esp),%esi
  801177:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80117b:	85 d2                	test   %edx,%edx
  80117d:	75 19                	jne    801198 <__udivdi3+0x38>
  80117f:	39 f3                	cmp    %esi,%ebx
  801181:	76 4d                	jbe    8011d0 <__udivdi3+0x70>
  801183:	31 ff                	xor    %edi,%edi
  801185:	89 e8                	mov    %ebp,%eax
  801187:	89 f2                	mov    %esi,%edx
  801189:	f7 f3                	div    %ebx
  80118b:	89 fa                	mov    %edi,%edx
  80118d:	83 c4 1c             	add    $0x1c,%esp
  801190:	5b                   	pop    %ebx
  801191:	5e                   	pop    %esi
  801192:	5f                   	pop    %edi
  801193:	5d                   	pop    %ebp
  801194:	c3                   	ret    
  801195:	8d 76 00             	lea    0x0(%esi),%esi
  801198:	39 f2                	cmp    %esi,%edx
  80119a:	76 14                	jbe    8011b0 <__udivdi3+0x50>
  80119c:	31 ff                	xor    %edi,%edi
  80119e:	31 c0                	xor    %eax,%eax
  8011a0:	89 fa                	mov    %edi,%edx
  8011a2:	83 c4 1c             	add    $0x1c,%esp
  8011a5:	5b                   	pop    %ebx
  8011a6:	5e                   	pop    %esi
  8011a7:	5f                   	pop    %edi
  8011a8:	5d                   	pop    %ebp
  8011a9:	c3                   	ret    
  8011aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011b0:	0f bd fa             	bsr    %edx,%edi
  8011b3:	83 f7 1f             	xor    $0x1f,%edi
  8011b6:	75 48                	jne    801200 <__udivdi3+0xa0>
  8011b8:	39 f2                	cmp    %esi,%edx
  8011ba:	72 06                	jb     8011c2 <__udivdi3+0x62>
  8011bc:	31 c0                	xor    %eax,%eax
  8011be:	39 eb                	cmp    %ebp,%ebx
  8011c0:	77 de                	ja     8011a0 <__udivdi3+0x40>
  8011c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8011c7:	eb d7                	jmp    8011a0 <__udivdi3+0x40>
  8011c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011d0:	89 d9                	mov    %ebx,%ecx
  8011d2:	85 db                	test   %ebx,%ebx
  8011d4:	75 0b                	jne    8011e1 <__udivdi3+0x81>
  8011d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8011db:	31 d2                	xor    %edx,%edx
  8011dd:	f7 f3                	div    %ebx
  8011df:	89 c1                	mov    %eax,%ecx
  8011e1:	31 d2                	xor    %edx,%edx
  8011e3:	89 f0                	mov    %esi,%eax
  8011e5:	f7 f1                	div    %ecx
  8011e7:	89 c6                	mov    %eax,%esi
  8011e9:	89 e8                	mov    %ebp,%eax
  8011eb:	89 f7                	mov    %esi,%edi
  8011ed:	f7 f1                	div    %ecx
  8011ef:	89 fa                	mov    %edi,%edx
  8011f1:	83 c4 1c             	add    $0x1c,%esp
  8011f4:	5b                   	pop    %ebx
  8011f5:	5e                   	pop    %esi
  8011f6:	5f                   	pop    %edi
  8011f7:	5d                   	pop    %ebp
  8011f8:	c3                   	ret    
  8011f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801200:	89 f9                	mov    %edi,%ecx
  801202:	b8 20 00 00 00       	mov    $0x20,%eax
  801207:	29 f8                	sub    %edi,%eax
  801209:	d3 e2                	shl    %cl,%edx
  80120b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80120f:	89 c1                	mov    %eax,%ecx
  801211:	89 da                	mov    %ebx,%edx
  801213:	d3 ea                	shr    %cl,%edx
  801215:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801219:	09 d1                	or     %edx,%ecx
  80121b:	89 f2                	mov    %esi,%edx
  80121d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801221:	89 f9                	mov    %edi,%ecx
  801223:	d3 e3                	shl    %cl,%ebx
  801225:	89 c1                	mov    %eax,%ecx
  801227:	d3 ea                	shr    %cl,%edx
  801229:	89 f9                	mov    %edi,%ecx
  80122b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80122f:	89 eb                	mov    %ebp,%ebx
  801231:	d3 e6                	shl    %cl,%esi
  801233:	89 c1                	mov    %eax,%ecx
  801235:	d3 eb                	shr    %cl,%ebx
  801237:	09 de                	or     %ebx,%esi
  801239:	89 f0                	mov    %esi,%eax
  80123b:	f7 74 24 08          	divl   0x8(%esp)
  80123f:	89 d6                	mov    %edx,%esi
  801241:	89 c3                	mov    %eax,%ebx
  801243:	f7 64 24 0c          	mull   0xc(%esp)
  801247:	39 d6                	cmp    %edx,%esi
  801249:	72 15                	jb     801260 <__udivdi3+0x100>
  80124b:	89 f9                	mov    %edi,%ecx
  80124d:	d3 e5                	shl    %cl,%ebp
  80124f:	39 c5                	cmp    %eax,%ebp
  801251:	73 04                	jae    801257 <__udivdi3+0xf7>
  801253:	39 d6                	cmp    %edx,%esi
  801255:	74 09                	je     801260 <__udivdi3+0x100>
  801257:	89 d8                	mov    %ebx,%eax
  801259:	31 ff                	xor    %edi,%edi
  80125b:	e9 40 ff ff ff       	jmp    8011a0 <__udivdi3+0x40>
  801260:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801263:	31 ff                	xor    %edi,%edi
  801265:	e9 36 ff ff ff       	jmp    8011a0 <__udivdi3+0x40>
  80126a:	66 90                	xchg   %ax,%ax
  80126c:	66 90                	xchg   %ax,%ax
  80126e:	66 90                	xchg   %ax,%ax

00801270 <__umoddi3>:
  801270:	f3 0f 1e fb          	endbr32 
  801274:	55                   	push   %ebp
  801275:	57                   	push   %edi
  801276:	56                   	push   %esi
  801277:	53                   	push   %ebx
  801278:	83 ec 1c             	sub    $0x1c,%esp
  80127b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80127f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801283:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801287:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80128b:	85 c0                	test   %eax,%eax
  80128d:	75 19                	jne    8012a8 <__umoddi3+0x38>
  80128f:	39 df                	cmp    %ebx,%edi
  801291:	76 5d                	jbe    8012f0 <__umoddi3+0x80>
  801293:	89 f0                	mov    %esi,%eax
  801295:	89 da                	mov    %ebx,%edx
  801297:	f7 f7                	div    %edi
  801299:	89 d0                	mov    %edx,%eax
  80129b:	31 d2                	xor    %edx,%edx
  80129d:	83 c4 1c             	add    $0x1c,%esp
  8012a0:	5b                   	pop    %ebx
  8012a1:	5e                   	pop    %esi
  8012a2:	5f                   	pop    %edi
  8012a3:	5d                   	pop    %ebp
  8012a4:	c3                   	ret    
  8012a5:	8d 76 00             	lea    0x0(%esi),%esi
  8012a8:	89 f2                	mov    %esi,%edx
  8012aa:	39 d8                	cmp    %ebx,%eax
  8012ac:	76 12                	jbe    8012c0 <__umoddi3+0x50>
  8012ae:	89 f0                	mov    %esi,%eax
  8012b0:	89 da                	mov    %ebx,%edx
  8012b2:	83 c4 1c             	add    $0x1c,%esp
  8012b5:	5b                   	pop    %ebx
  8012b6:	5e                   	pop    %esi
  8012b7:	5f                   	pop    %edi
  8012b8:	5d                   	pop    %ebp
  8012b9:	c3                   	ret    
  8012ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012c0:	0f bd e8             	bsr    %eax,%ebp
  8012c3:	83 f5 1f             	xor    $0x1f,%ebp
  8012c6:	75 50                	jne    801318 <__umoddi3+0xa8>
  8012c8:	39 d8                	cmp    %ebx,%eax
  8012ca:	0f 82 e0 00 00 00    	jb     8013b0 <__umoddi3+0x140>
  8012d0:	89 d9                	mov    %ebx,%ecx
  8012d2:	39 f7                	cmp    %esi,%edi
  8012d4:	0f 86 d6 00 00 00    	jbe    8013b0 <__umoddi3+0x140>
  8012da:	89 d0                	mov    %edx,%eax
  8012dc:	89 ca                	mov    %ecx,%edx
  8012de:	83 c4 1c             	add    $0x1c,%esp
  8012e1:	5b                   	pop    %ebx
  8012e2:	5e                   	pop    %esi
  8012e3:	5f                   	pop    %edi
  8012e4:	5d                   	pop    %ebp
  8012e5:	c3                   	ret    
  8012e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012ed:	8d 76 00             	lea    0x0(%esi),%esi
  8012f0:	89 fd                	mov    %edi,%ebp
  8012f2:	85 ff                	test   %edi,%edi
  8012f4:	75 0b                	jne    801301 <__umoddi3+0x91>
  8012f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8012fb:	31 d2                	xor    %edx,%edx
  8012fd:	f7 f7                	div    %edi
  8012ff:	89 c5                	mov    %eax,%ebp
  801301:	89 d8                	mov    %ebx,%eax
  801303:	31 d2                	xor    %edx,%edx
  801305:	f7 f5                	div    %ebp
  801307:	89 f0                	mov    %esi,%eax
  801309:	f7 f5                	div    %ebp
  80130b:	89 d0                	mov    %edx,%eax
  80130d:	31 d2                	xor    %edx,%edx
  80130f:	eb 8c                	jmp    80129d <__umoddi3+0x2d>
  801311:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801318:	89 e9                	mov    %ebp,%ecx
  80131a:	ba 20 00 00 00       	mov    $0x20,%edx
  80131f:	29 ea                	sub    %ebp,%edx
  801321:	d3 e0                	shl    %cl,%eax
  801323:	89 44 24 08          	mov    %eax,0x8(%esp)
  801327:	89 d1                	mov    %edx,%ecx
  801329:	89 f8                	mov    %edi,%eax
  80132b:	d3 e8                	shr    %cl,%eax
  80132d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801331:	89 54 24 04          	mov    %edx,0x4(%esp)
  801335:	8b 54 24 04          	mov    0x4(%esp),%edx
  801339:	09 c1                	or     %eax,%ecx
  80133b:	89 d8                	mov    %ebx,%eax
  80133d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801341:	89 e9                	mov    %ebp,%ecx
  801343:	d3 e7                	shl    %cl,%edi
  801345:	89 d1                	mov    %edx,%ecx
  801347:	d3 e8                	shr    %cl,%eax
  801349:	89 e9                	mov    %ebp,%ecx
  80134b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80134f:	d3 e3                	shl    %cl,%ebx
  801351:	89 c7                	mov    %eax,%edi
  801353:	89 d1                	mov    %edx,%ecx
  801355:	89 f0                	mov    %esi,%eax
  801357:	d3 e8                	shr    %cl,%eax
  801359:	89 e9                	mov    %ebp,%ecx
  80135b:	89 fa                	mov    %edi,%edx
  80135d:	d3 e6                	shl    %cl,%esi
  80135f:	09 d8                	or     %ebx,%eax
  801361:	f7 74 24 08          	divl   0x8(%esp)
  801365:	89 d1                	mov    %edx,%ecx
  801367:	89 f3                	mov    %esi,%ebx
  801369:	f7 64 24 0c          	mull   0xc(%esp)
  80136d:	89 c6                	mov    %eax,%esi
  80136f:	89 d7                	mov    %edx,%edi
  801371:	39 d1                	cmp    %edx,%ecx
  801373:	72 06                	jb     80137b <__umoddi3+0x10b>
  801375:	75 10                	jne    801387 <__umoddi3+0x117>
  801377:	39 c3                	cmp    %eax,%ebx
  801379:	73 0c                	jae    801387 <__umoddi3+0x117>
  80137b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80137f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801383:	89 d7                	mov    %edx,%edi
  801385:	89 c6                	mov    %eax,%esi
  801387:	89 ca                	mov    %ecx,%edx
  801389:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80138e:	29 f3                	sub    %esi,%ebx
  801390:	19 fa                	sbb    %edi,%edx
  801392:	89 d0                	mov    %edx,%eax
  801394:	d3 e0                	shl    %cl,%eax
  801396:	89 e9                	mov    %ebp,%ecx
  801398:	d3 eb                	shr    %cl,%ebx
  80139a:	d3 ea                	shr    %cl,%edx
  80139c:	09 d8                	or     %ebx,%eax
  80139e:	83 c4 1c             	add    $0x1c,%esp
  8013a1:	5b                   	pop    %ebx
  8013a2:	5e                   	pop    %esi
  8013a3:	5f                   	pop    %edi
  8013a4:	5d                   	pop    %ebp
  8013a5:	c3                   	ret    
  8013a6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013ad:	8d 76 00             	lea    0x0(%esi),%esi
  8013b0:	29 fe                	sub    %edi,%esi
  8013b2:	19 c3                	sbb    %eax,%ebx
  8013b4:	89 f2                	mov    %esi,%edx
  8013b6:	89 d9                	mov    %ebx,%ecx
  8013b8:	e9 1d ff ff ff       	jmp    8012da <__umoddi3+0x6a>
