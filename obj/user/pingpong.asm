
obj/user/pingpong:     file format elf32-i386


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
  80002c:	e8 93 00 00 00       	call   8000c4 <libmain>
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
  80003a:	57                   	push   %edi
  80003b:	56                   	push   %esi
  80003c:	53                   	push   %ebx
  80003d:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  800040:	e8 96 0e 00 00       	call   800edb <fork>
  800045:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800048:	85 c0                	test   %eax,%eax
  80004a:	75 4f                	jne    80009b <umain+0x68>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80004c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	6a 00                	push   $0x0
  800054:	6a 00                	push   $0x0
  800056:	56                   	push   %esi
  800057:	e8 29 10 00 00       	call   801085 <ipc_recv>
  80005c:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  80005e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800061:	e8 6a 0b 00 00       	call   800bd0 <sys_getenvid>
  800066:	57                   	push   %edi
  800067:	53                   	push   %ebx
  800068:	50                   	push   %eax
  800069:	68 f6 14 80 00       	push   $0x8014f6
  80006e:	e8 58 01 00 00       	call   8001cb <cprintf>
		if (i == 10)
  800073:	83 c4 20             	add    $0x20,%esp
  800076:	83 fb 0a             	cmp    $0xa,%ebx
  800079:	74 18                	je     800093 <umain+0x60>
			return;
		i++;
  80007b:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  80007e:	6a 00                	push   $0x0
  800080:	6a 00                	push   $0x0
  800082:	53                   	push   %ebx
  800083:	ff 75 e4             	pushl  -0x1c(%ebp)
  800086:	e8 51 10 00 00       	call   8010dc <ipc_send>
		if (i == 10)
  80008b:	83 c4 10             	add    $0x10,%esp
  80008e:	83 fb 0a             	cmp    $0xa,%ebx
  800091:	75 bc                	jne    80004f <umain+0x1c>
			return;
	}

}
  800093:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5f                   	pop    %edi
  800099:	5d                   	pop    %ebp
  80009a:	c3                   	ret    
  80009b:	89 c3                	mov    %eax,%ebx
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80009d:	e8 2e 0b 00 00       	call   800bd0 <sys_getenvid>
  8000a2:	83 ec 04             	sub    $0x4,%esp
  8000a5:	53                   	push   %ebx
  8000a6:	50                   	push   %eax
  8000a7:	68 e0 14 80 00       	push   $0x8014e0
  8000ac:	e8 1a 01 00 00       	call   8001cb <cprintf>
		ipc_send(who, 0, 0, 0);
  8000b1:	6a 00                	push   $0x0
  8000b3:	6a 00                	push   $0x0
  8000b5:	6a 00                	push   $0x0
  8000b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000ba:	e8 1d 10 00 00       	call   8010dc <ipc_send>
  8000bf:	83 c4 20             	add    $0x20,%esp
  8000c2:	eb 88                	jmp    80004c <umain+0x19>

008000c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c4:	f3 0f 1e fb          	endbr32 
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	56                   	push   %esi
  8000cc:	53                   	push   %ebx
  8000cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000d3:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000da:	00 00 00 
    envid_t envid = sys_getenvid();
  8000dd:	e8 ee 0a 00 00       	call   800bd0 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  8000e2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000e7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000ea:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000ef:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f4:	85 db                	test   %ebx,%ebx
  8000f6:	7e 07                	jle    8000ff <libmain+0x3b>
		binaryname = argv[0];
  8000f8:	8b 06                	mov    (%esi),%eax
  8000fa:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ff:	83 ec 08             	sub    $0x8,%esp
  800102:	56                   	push   %esi
  800103:	53                   	push   %ebx
  800104:	e8 2a ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800109:	e8 0a 00 00 00       	call   800118 <exit>
}
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800114:	5b                   	pop    %ebx
  800115:	5e                   	pop    %esi
  800116:	5d                   	pop    %ebp
  800117:	c3                   	ret    

00800118 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800118:	f3 0f 1e fb          	endbr32 
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  800122:	6a 00                	push   $0x0
  800124:	e8 62 0a 00 00       	call   800b8b <sys_env_destroy>
}
  800129:	83 c4 10             	add    $0x10,%esp
  80012c:	c9                   	leave  
  80012d:	c3                   	ret    

0080012e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80012e:	f3 0f 1e fb          	endbr32 
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	53                   	push   %ebx
  800136:	83 ec 04             	sub    $0x4,%esp
  800139:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80013c:	8b 13                	mov    (%ebx),%edx
  80013e:	8d 42 01             	lea    0x1(%edx),%eax
  800141:	89 03                	mov    %eax,(%ebx)
  800143:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800146:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80014a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80014f:	74 09                	je     80015a <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800151:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800155:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800158:	c9                   	leave  
  800159:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80015a:	83 ec 08             	sub    $0x8,%esp
  80015d:	68 ff 00 00 00       	push   $0xff
  800162:	8d 43 08             	lea    0x8(%ebx),%eax
  800165:	50                   	push   %eax
  800166:	e8 db 09 00 00       	call   800b46 <sys_cputs>
		b->idx = 0;
  80016b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800171:	83 c4 10             	add    $0x10,%esp
  800174:	eb db                	jmp    800151 <putch+0x23>

00800176 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800176:	f3 0f 1e fb          	endbr32 
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800183:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80018a:	00 00 00 
	b.cnt = 0;
  80018d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800194:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800197:	ff 75 0c             	pushl  0xc(%ebp)
  80019a:	ff 75 08             	pushl  0x8(%ebp)
  80019d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a3:	50                   	push   %eax
  8001a4:	68 2e 01 80 00       	push   $0x80012e
  8001a9:	e8 20 01 00 00       	call   8002ce <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ae:	83 c4 08             	add    $0x8,%esp
  8001b1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001b7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001bd:	50                   	push   %eax
  8001be:	e8 83 09 00 00       	call   800b46 <sys_cputs>

	return b.cnt;
}
  8001c3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001c9:	c9                   	leave  
  8001ca:	c3                   	ret    

008001cb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001cb:	f3 0f 1e fb          	endbr32 
  8001cf:	55                   	push   %ebp
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001d8:	50                   	push   %eax
  8001d9:	ff 75 08             	pushl  0x8(%ebp)
  8001dc:	e8 95 ff ff ff       	call   800176 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e1:	c9                   	leave  
  8001e2:	c3                   	ret    

008001e3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	57                   	push   %edi
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	83 ec 1c             	sub    $0x1c,%esp
  8001ec:	89 c7                	mov    %eax,%edi
  8001ee:	89 d6                	mov    %edx,%esi
  8001f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f6:	89 d1                	mov    %edx,%ecx
  8001f8:	89 c2                	mov    %eax,%edx
  8001fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001fd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800200:	8b 45 10             	mov    0x10(%ebp),%eax
  800203:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800206:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800209:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800210:	39 c2                	cmp    %eax,%edx
  800212:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800215:	72 3e                	jb     800255 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800217:	83 ec 0c             	sub    $0xc,%esp
  80021a:	ff 75 18             	pushl  0x18(%ebp)
  80021d:	83 eb 01             	sub    $0x1,%ebx
  800220:	53                   	push   %ebx
  800221:	50                   	push   %eax
  800222:	83 ec 08             	sub    $0x8,%esp
  800225:	ff 75 e4             	pushl  -0x1c(%ebp)
  800228:	ff 75 e0             	pushl  -0x20(%ebp)
  80022b:	ff 75 dc             	pushl  -0x24(%ebp)
  80022e:	ff 75 d8             	pushl  -0x28(%ebp)
  800231:	e8 3a 10 00 00       	call   801270 <__udivdi3>
  800236:	83 c4 18             	add    $0x18,%esp
  800239:	52                   	push   %edx
  80023a:	50                   	push   %eax
  80023b:	89 f2                	mov    %esi,%edx
  80023d:	89 f8                	mov    %edi,%eax
  80023f:	e8 9f ff ff ff       	call   8001e3 <printnum>
  800244:	83 c4 20             	add    $0x20,%esp
  800247:	eb 13                	jmp    80025c <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800249:	83 ec 08             	sub    $0x8,%esp
  80024c:	56                   	push   %esi
  80024d:	ff 75 18             	pushl  0x18(%ebp)
  800250:	ff d7                	call   *%edi
  800252:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800255:	83 eb 01             	sub    $0x1,%ebx
  800258:	85 db                	test   %ebx,%ebx
  80025a:	7f ed                	jg     800249 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80025c:	83 ec 08             	sub    $0x8,%esp
  80025f:	56                   	push   %esi
  800260:	83 ec 04             	sub    $0x4,%esp
  800263:	ff 75 e4             	pushl  -0x1c(%ebp)
  800266:	ff 75 e0             	pushl  -0x20(%ebp)
  800269:	ff 75 dc             	pushl  -0x24(%ebp)
  80026c:	ff 75 d8             	pushl  -0x28(%ebp)
  80026f:	e8 0c 11 00 00       	call   801380 <__umoddi3>
  800274:	83 c4 14             	add    $0x14,%esp
  800277:	0f be 80 13 15 80 00 	movsbl 0x801513(%eax),%eax
  80027e:	50                   	push   %eax
  80027f:	ff d7                	call   *%edi
}
  800281:	83 c4 10             	add    $0x10,%esp
  800284:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800287:	5b                   	pop    %ebx
  800288:	5e                   	pop    %esi
  800289:	5f                   	pop    %edi
  80028a:	5d                   	pop    %ebp
  80028b:	c3                   	ret    

0080028c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80028c:	f3 0f 1e fb          	endbr32 
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800296:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80029a:	8b 10                	mov    (%eax),%edx
  80029c:	3b 50 04             	cmp    0x4(%eax),%edx
  80029f:	73 0a                	jae    8002ab <sprintputch+0x1f>
		*b->buf++ = ch;
  8002a1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002a4:	89 08                	mov    %ecx,(%eax)
  8002a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a9:	88 02                	mov    %al,(%edx)
}
  8002ab:	5d                   	pop    %ebp
  8002ac:	c3                   	ret    

008002ad <printfmt>:
{
  8002ad:	f3 0f 1e fb          	endbr32 
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002b7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ba:	50                   	push   %eax
  8002bb:	ff 75 10             	pushl  0x10(%ebp)
  8002be:	ff 75 0c             	pushl  0xc(%ebp)
  8002c1:	ff 75 08             	pushl  0x8(%ebp)
  8002c4:	e8 05 00 00 00       	call   8002ce <vprintfmt>
}
  8002c9:	83 c4 10             	add    $0x10,%esp
  8002cc:	c9                   	leave  
  8002cd:	c3                   	ret    

008002ce <vprintfmt>:
{
  8002ce:	f3 0f 1e fb          	endbr32 
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	57                   	push   %edi
  8002d6:	56                   	push   %esi
  8002d7:	53                   	push   %ebx
  8002d8:	83 ec 3c             	sub    $0x3c,%esp
  8002db:	8b 75 08             	mov    0x8(%ebp),%esi
  8002de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002e1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002e4:	e9 4a 03 00 00       	jmp    800633 <vprintfmt+0x365>
		padc = ' ';
  8002e9:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002ed:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002f4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002fb:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800302:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800307:	8d 47 01             	lea    0x1(%edi),%eax
  80030a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80030d:	0f b6 17             	movzbl (%edi),%edx
  800310:	8d 42 dd             	lea    -0x23(%edx),%eax
  800313:	3c 55                	cmp    $0x55,%al
  800315:	0f 87 de 03 00 00    	ja     8006f9 <vprintfmt+0x42b>
  80031b:	0f b6 c0             	movzbl %al,%eax
  80031e:	3e ff 24 85 60 16 80 	notrack jmp *0x801660(,%eax,4)
  800325:	00 
  800326:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800329:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80032d:	eb d8                	jmp    800307 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80032f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800332:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800336:	eb cf                	jmp    800307 <vprintfmt+0x39>
  800338:	0f b6 d2             	movzbl %dl,%edx
  80033b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80033e:	b8 00 00 00 00       	mov    $0x0,%eax
  800343:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800346:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800349:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80034d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800350:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800353:	83 f9 09             	cmp    $0x9,%ecx
  800356:	77 55                	ja     8003ad <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800358:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80035b:	eb e9                	jmp    800346 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80035d:	8b 45 14             	mov    0x14(%ebp),%eax
  800360:	8b 00                	mov    (%eax),%eax
  800362:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800365:	8b 45 14             	mov    0x14(%ebp),%eax
  800368:	8d 40 04             	lea    0x4(%eax),%eax
  80036b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800371:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800375:	79 90                	jns    800307 <vprintfmt+0x39>
				width = precision, precision = -1;
  800377:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80037a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80037d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800384:	eb 81                	jmp    800307 <vprintfmt+0x39>
  800386:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800389:	85 c0                	test   %eax,%eax
  80038b:	ba 00 00 00 00       	mov    $0x0,%edx
  800390:	0f 49 d0             	cmovns %eax,%edx
  800393:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800396:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800399:	e9 69 ff ff ff       	jmp    800307 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003a1:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003a8:	e9 5a ff ff ff       	jmp    800307 <vprintfmt+0x39>
  8003ad:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003b3:	eb bc                	jmp    800371 <vprintfmt+0xa3>
			lflag++;
  8003b5:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003bb:	e9 47 ff ff ff       	jmp    800307 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c3:	8d 78 04             	lea    0x4(%eax),%edi
  8003c6:	83 ec 08             	sub    $0x8,%esp
  8003c9:	53                   	push   %ebx
  8003ca:	ff 30                	pushl  (%eax)
  8003cc:	ff d6                	call   *%esi
			break;
  8003ce:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003d1:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003d4:	e9 57 02 00 00       	jmp    800630 <vprintfmt+0x362>
			err = va_arg(ap, int);
  8003d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003dc:	8d 78 04             	lea    0x4(%eax),%edi
  8003df:	8b 00                	mov    (%eax),%eax
  8003e1:	99                   	cltd   
  8003e2:	31 d0                	xor    %edx,%eax
  8003e4:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e6:	83 f8 0f             	cmp    $0xf,%eax
  8003e9:	7f 23                	jg     80040e <vprintfmt+0x140>
  8003eb:	8b 14 85 c0 17 80 00 	mov    0x8017c0(,%eax,4),%edx
  8003f2:	85 d2                	test   %edx,%edx
  8003f4:	74 18                	je     80040e <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8003f6:	52                   	push   %edx
  8003f7:	68 34 15 80 00       	push   $0x801534
  8003fc:	53                   	push   %ebx
  8003fd:	56                   	push   %esi
  8003fe:	e8 aa fe ff ff       	call   8002ad <printfmt>
  800403:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800406:	89 7d 14             	mov    %edi,0x14(%ebp)
  800409:	e9 22 02 00 00       	jmp    800630 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  80040e:	50                   	push   %eax
  80040f:	68 2b 15 80 00       	push   $0x80152b
  800414:	53                   	push   %ebx
  800415:	56                   	push   %esi
  800416:	e8 92 fe ff ff       	call   8002ad <printfmt>
  80041b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80041e:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800421:	e9 0a 02 00 00       	jmp    800630 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  800426:	8b 45 14             	mov    0x14(%ebp),%eax
  800429:	83 c0 04             	add    $0x4,%eax
  80042c:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80042f:	8b 45 14             	mov    0x14(%ebp),%eax
  800432:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800434:	85 d2                	test   %edx,%edx
  800436:	b8 24 15 80 00       	mov    $0x801524,%eax
  80043b:	0f 45 c2             	cmovne %edx,%eax
  80043e:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800441:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800445:	7e 06                	jle    80044d <vprintfmt+0x17f>
  800447:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80044b:	75 0d                	jne    80045a <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80044d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800450:	89 c7                	mov    %eax,%edi
  800452:	03 45 e0             	add    -0x20(%ebp),%eax
  800455:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800458:	eb 55                	jmp    8004af <vprintfmt+0x1e1>
  80045a:	83 ec 08             	sub    $0x8,%esp
  80045d:	ff 75 d8             	pushl  -0x28(%ebp)
  800460:	ff 75 cc             	pushl  -0x34(%ebp)
  800463:	e8 45 03 00 00       	call   8007ad <strnlen>
  800468:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80046b:	29 c2                	sub    %eax,%edx
  80046d:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800470:	83 c4 10             	add    $0x10,%esp
  800473:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800475:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800479:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80047c:	85 ff                	test   %edi,%edi
  80047e:	7e 11                	jle    800491 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800480:	83 ec 08             	sub    $0x8,%esp
  800483:	53                   	push   %ebx
  800484:	ff 75 e0             	pushl  -0x20(%ebp)
  800487:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800489:	83 ef 01             	sub    $0x1,%edi
  80048c:	83 c4 10             	add    $0x10,%esp
  80048f:	eb eb                	jmp    80047c <vprintfmt+0x1ae>
  800491:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800494:	85 d2                	test   %edx,%edx
  800496:	b8 00 00 00 00       	mov    $0x0,%eax
  80049b:	0f 49 c2             	cmovns %edx,%eax
  80049e:	29 c2                	sub    %eax,%edx
  8004a0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004a3:	eb a8                	jmp    80044d <vprintfmt+0x17f>
					putch(ch, putdat);
  8004a5:	83 ec 08             	sub    $0x8,%esp
  8004a8:	53                   	push   %ebx
  8004a9:	52                   	push   %edx
  8004aa:	ff d6                	call   *%esi
  8004ac:	83 c4 10             	add    $0x10,%esp
  8004af:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b2:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004b4:	83 c7 01             	add    $0x1,%edi
  8004b7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004bb:	0f be d0             	movsbl %al,%edx
  8004be:	85 d2                	test   %edx,%edx
  8004c0:	74 4b                	je     80050d <vprintfmt+0x23f>
  8004c2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004c6:	78 06                	js     8004ce <vprintfmt+0x200>
  8004c8:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004cc:	78 1e                	js     8004ec <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ce:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004d2:	74 d1                	je     8004a5 <vprintfmt+0x1d7>
  8004d4:	0f be c0             	movsbl %al,%eax
  8004d7:	83 e8 20             	sub    $0x20,%eax
  8004da:	83 f8 5e             	cmp    $0x5e,%eax
  8004dd:	76 c6                	jbe    8004a5 <vprintfmt+0x1d7>
					putch('?', putdat);
  8004df:	83 ec 08             	sub    $0x8,%esp
  8004e2:	53                   	push   %ebx
  8004e3:	6a 3f                	push   $0x3f
  8004e5:	ff d6                	call   *%esi
  8004e7:	83 c4 10             	add    $0x10,%esp
  8004ea:	eb c3                	jmp    8004af <vprintfmt+0x1e1>
  8004ec:	89 cf                	mov    %ecx,%edi
  8004ee:	eb 0e                	jmp    8004fe <vprintfmt+0x230>
				putch(' ', putdat);
  8004f0:	83 ec 08             	sub    $0x8,%esp
  8004f3:	53                   	push   %ebx
  8004f4:	6a 20                	push   $0x20
  8004f6:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004f8:	83 ef 01             	sub    $0x1,%edi
  8004fb:	83 c4 10             	add    $0x10,%esp
  8004fe:	85 ff                	test   %edi,%edi
  800500:	7f ee                	jg     8004f0 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800502:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800505:	89 45 14             	mov    %eax,0x14(%ebp)
  800508:	e9 23 01 00 00       	jmp    800630 <vprintfmt+0x362>
  80050d:	89 cf                	mov    %ecx,%edi
  80050f:	eb ed                	jmp    8004fe <vprintfmt+0x230>
	if (lflag >= 2)
  800511:	83 f9 01             	cmp    $0x1,%ecx
  800514:	7f 1b                	jg     800531 <vprintfmt+0x263>
	else if (lflag)
  800516:	85 c9                	test   %ecx,%ecx
  800518:	74 63                	je     80057d <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80051a:	8b 45 14             	mov    0x14(%ebp),%eax
  80051d:	8b 00                	mov    (%eax),%eax
  80051f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800522:	99                   	cltd   
  800523:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800526:	8b 45 14             	mov    0x14(%ebp),%eax
  800529:	8d 40 04             	lea    0x4(%eax),%eax
  80052c:	89 45 14             	mov    %eax,0x14(%ebp)
  80052f:	eb 17                	jmp    800548 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800531:	8b 45 14             	mov    0x14(%ebp),%eax
  800534:	8b 50 04             	mov    0x4(%eax),%edx
  800537:	8b 00                	mov    (%eax),%eax
  800539:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80053f:	8b 45 14             	mov    0x14(%ebp),%eax
  800542:	8d 40 08             	lea    0x8(%eax),%eax
  800545:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800548:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80054b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80054e:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800553:	85 c9                	test   %ecx,%ecx
  800555:	0f 89 bb 00 00 00    	jns    800616 <vprintfmt+0x348>
				putch('-', putdat);
  80055b:	83 ec 08             	sub    $0x8,%esp
  80055e:	53                   	push   %ebx
  80055f:	6a 2d                	push   $0x2d
  800561:	ff d6                	call   *%esi
				num = -(long long) num;
  800563:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800566:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800569:	f7 da                	neg    %edx
  80056b:	83 d1 00             	adc    $0x0,%ecx
  80056e:	f7 d9                	neg    %ecx
  800570:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800573:	b8 0a 00 00 00       	mov    $0xa,%eax
  800578:	e9 99 00 00 00       	jmp    800616 <vprintfmt+0x348>
		return va_arg(*ap, int);
  80057d:	8b 45 14             	mov    0x14(%ebp),%eax
  800580:	8b 00                	mov    (%eax),%eax
  800582:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800585:	99                   	cltd   
  800586:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800589:	8b 45 14             	mov    0x14(%ebp),%eax
  80058c:	8d 40 04             	lea    0x4(%eax),%eax
  80058f:	89 45 14             	mov    %eax,0x14(%ebp)
  800592:	eb b4                	jmp    800548 <vprintfmt+0x27a>
	if (lflag >= 2)
  800594:	83 f9 01             	cmp    $0x1,%ecx
  800597:	7f 1b                	jg     8005b4 <vprintfmt+0x2e6>
	else if (lflag)
  800599:	85 c9                	test   %ecx,%ecx
  80059b:	74 2c                	je     8005c9 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  80059d:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a0:	8b 10                	mov    (%eax),%edx
  8005a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a7:	8d 40 04             	lea    0x4(%eax),%eax
  8005aa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ad:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005b2:	eb 62                	jmp    800616 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8b 10                	mov    (%eax),%edx
  8005b9:	8b 48 04             	mov    0x4(%eax),%ecx
  8005bc:	8d 40 08             	lea    0x8(%eax),%eax
  8005bf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005c2:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005c7:	eb 4d                	jmp    800616 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8005c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cc:	8b 10                	mov    (%eax),%edx
  8005ce:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d3:	8d 40 04             	lea    0x4(%eax),%eax
  8005d6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005d9:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8005de:	eb 36                	jmp    800616 <vprintfmt+0x348>
	if (lflag >= 2)
  8005e0:	83 f9 01             	cmp    $0x1,%ecx
  8005e3:	7f 17                	jg     8005fc <vprintfmt+0x32e>
	else if (lflag)
  8005e5:	85 c9                	test   %ecx,%ecx
  8005e7:	74 6e                	je     800657 <vprintfmt+0x389>
		return va_arg(*ap, long);
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	8b 10                	mov    (%eax),%edx
  8005ee:	89 d0                	mov    %edx,%eax
  8005f0:	99                   	cltd   
  8005f1:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005f4:	8d 49 04             	lea    0x4(%ecx),%ecx
  8005f7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005fa:	eb 11                	jmp    80060d <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8005fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ff:	8b 50 04             	mov    0x4(%eax),%edx
  800602:	8b 00                	mov    (%eax),%eax
  800604:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800607:	8d 49 08             	lea    0x8(%ecx),%ecx
  80060a:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  80060d:	89 d1                	mov    %edx,%ecx
  80060f:	89 c2                	mov    %eax,%edx
            base = 8;
  800611:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800616:	83 ec 0c             	sub    $0xc,%esp
  800619:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80061d:	57                   	push   %edi
  80061e:	ff 75 e0             	pushl  -0x20(%ebp)
  800621:	50                   	push   %eax
  800622:	51                   	push   %ecx
  800623:	52                   	push   %edx
  800624:	89 da                	mov    %ebx,%edx
  800626:	89 f0                	mov    %esi,%eax
  800628:	e8 b6 fb ff ff       	call   8001e3 <printnum>
			break;
  80062d:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800630:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800633:	83 c7 01             	add    $0x1,%edi
  800636:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80063a:	83 f8 25             	cmp    $0x25,%eax
  80063d:	0f 84 a6 fc ff ff    	je     8002e9 <vprintfmt+0x1b>
			if (ch == '\0')
  800643:	85 c0                	test   %eax,%eax
  800645:	0f 84 ce 00 00 00    	je     800719 <vprintfmt+0x44b>
			putch(ch, putdat);
  80064b:	83 ec 08             	sub    $0x8,%esp
  80064e:	53                   	push   %ebx
  80064f:	50                   	push   %eax
  800650:	ff d6                	call   *%esi
  800652:	83 c4 10             	add    $0x10,%esp
  800655:	eb dc                	jmp    800633 <vprintfmt+0x365>
		return va_arg(*ap, int);
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8b 10                	mov    (%eax),%edx
  80065c:	89 d0                	mov    %edx,%eax
  80065e:	99                   	cltd   
  80065f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800662:	8d 49 04             	lea    0x4(%ecx),%ecx
  800665:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800668:	eb a3                	jmp    80060d <vprintfmt+0x33f>
			putch('0', putdat);
  80066a:	83 ec 08             	sub    $0x8,%esp
  80066d:	53                   	push   %ebx
  80066e:	6a 30                	push   $0x30
  800670:	ff d6                	call   *%esi
			putch('x', putdat);
  800672:	83 c4 08             	add    $0x8,%esp
  800675:	53                   	push   %ebx
  800676:	6a 78                	push   $0x78
  800678:	ff d6                	call   *%esi
			num = (unsigned long long)
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8b 10                	mov    (%eax),%edx
  80067f:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800684:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800687:	8d 40 04             	lea    0x4(%eax),%eax
  80068a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80068d:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800692:	eb 82                	jmp    800616 <vprintfmt+0x348>
	if (lflag >= 2)
  800694:	83 f9 01             	cmp    $0x1,%ecx
  800697:	7f 1e                	jg     8006b7 <vprintfmt+0x3e9>
	else if (lflag)
  800699:	85 c9                	test   %ecx,%ecx
  80069b:	74 32                	je     8006cf <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  80069d:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a0:	8b 10                	mov    (%eax),%edx
  8006a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a7:	8d 40 04             	lea    0x4(%eax),%eax
  8006aa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ad:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006b2:	e9 5f ff ff ff       	jmp    800616 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8006b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ba:	8b 10                	mov    (%eax),%edx
  8006bc:	8b 48 04             	mov    0x4(%eax),%ecx
  8006bf:	8d 40 08             	lea    0x8(%eax),%eax
  8006c2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c5:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006ca:	e9 47 ff ff ff       	jmp    800616 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8006cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d2:	8b 10                	mov    (%eax),%edx
  8006d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d9:	8d 40 04             	lea    0x4(%eax),%eax
  8006dc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006df:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006e4:	e9 2d ff ff ff       	jmp    800616 <vprintfmt+0x348>
			putch(ch, putdat);
  8006e9:	83 ec 08             	sub    $0x8,%esp
  8006ec:	53                   	push   %ebx
  8006ed:	6a 25                	push   $0x25
  8006ef:	ff d6                	call   *%esi
			break;
  8006f1:	83 c4 10             	add    $0x10,%esp
  8006f4:	e9 37 ff ff ff       	jmp    800630 <vprintfmt+0x362>
			putch('%', putdat);
  8006f9:	83 ec 08             	sub    $0x8,%esp
  8006fc:	53                   	push   %ebx
  8006fd:	6a 25                	push   $0x25
  8006ff:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800701:	83 c4 10             	add    $0x10,%esp
  800704:	89 f8                	mov    %edi,%eax
  800706:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80070a:	74 05                	je     800711 <vprintfmt+0x443>
  80070c:	83 e8 01             	sub    $0x1,%eax
  80070f:	eb f5                	jmp    800706 <vprintfmt+0x438>
  800711:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800714:	e9 17 ff ff ff       	jmp    800630 <vprintfmt+0x362>
}
  800719:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80071c:	5b                   	pop    %ebx
  80071d:	5e                   	pop    %esi
  80071e:	5f                   	pop    %edi
  80071f:	5d                   	pop    %ebp
  800720:	c3                   	ret    

00800721 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800721:	f3 0f 1e fb          	endbr32 
  800725:	55                   	push   %ebp
  800726:	89 e5                	mov    %esp,%ebp
  800728:	83 ec 18             	sub    $0x18,%esp
  80072b:	8b 45 08             	mov    0x8(%ebp),%eax
  80072e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800731:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800734:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800738:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80073b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800742:	85 c0                	test   %eax,%eax
  800744:	74 26                	je     80076c <vsnprintf+0x4b>
  800746:	85 d2                	test   %edx,%edx
  800748:	7e 22                	jle    80076c <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80074a:	ff 75 14             	pushl  0x14(%ebp)
  80074d:	ff 75 10             	pushl  0x10(%ebp)
  800750:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800753:	50                   	push   %eax
  800754:	68 8c 02 80 00       	push   $0x80028c
  800759:	e8 70 fb ff ff       	call   8002ce <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80075e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800761:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800764:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800767:	83 c4 10             	add    $0x10,%esp
}
  80076a:	c9                   	leave  
  80076b:	c3                   	ret    
		return -E_INVAL;
  80076c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800771:	eb f7                	jmp    80076a <vsnprintf+0x49>

00800773 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800773:	f3 0f 1e fb          	endbr32 
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80077d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800780:	50                   	push   %eax
  800781:	ff 75 10             	pushl  0x10(%ebp)
  800784:	ff 75 0c             	pushl  0xc(%ebp)
  800787:	ff 75 08             	pushl  0x8(%ebp)
  80078a:	e8 92 ff ff ff       	call   800721 <vsnprintf>
	va_end(ap);

	return rc;
}
  80078f:	c9                   	leave  
  800790:	c3                   	ret    

00800791 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800791:	f3 0f 1e fb          	endbr32 
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80079b:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a4:	74 05                	je     8007ab <strlen+0x1a>
		n++;
  8007a6:	83 c0 01             	add    $0x1,%eax
  8007a9:	eb f5                	jmp    8007a0 <strlen+0xf>
	return n;
}
  8007ab:	5d                   	pop    %ebp
  8007ac:	c3                   	ret    

008007ad <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ad:	f3 0f 1e fb          	endbr32 
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b7:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bf:	39 d0                	cmp    %edx,%eax
  8007c1:	74 0d                	je     8007d0 <strnlen+0x23>
  8007c3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007c7:	74 05                	je     8007ce <strnlen+0x21>
		n++;
  8007c9:	83 c0 01             	add    $0x1,%eax
  8007cc:	eb f1                	jmp    8007bf <strnlen+0x12>
  8007ce:	89 c2                	mov    %eax,%edx
	return n;
}
  8007d0:	89 d0                	mov    %edx,%eax
  8007d2:	5d                   	pop    %ebp
  8007d3:	c3                   	ret    

008007d4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d4:	f3 0f 1e fb          	endbr32 
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	53                   	push   %ebx
  8007dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e7:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007eb:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007ee:	83 c0 01             	add    $0x1,%eax
  8007f1:	84 d2                	test   %dl,%dl
  8007f3:	75 f2                	jne    8007e7 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8007f5:	89 c8                	mov    %ecx,%eax
  8007f7:	5b                   	pop    %ebx
  8007f8:	5d                   	pop    %ebp
  8007f9:	c3                   	ret    

008007fa <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007fa:	f3 0f 1e fb          	endbr32 
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	53                   	push   %ebx
  800802:	83 ec 10             	sub    $0x10,%esp
  800805:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800808:	53                   	push   %ebx
  800809:	e8 83 ff ff ff       	call   800791 <strlen>
  80080e:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800811:	ff 75 0c             	pushl  0xc(%ebp)
  800814:	01 d8                	add    %ebx,%eax
  800816:	50                   	push   %eax
  800817:	e8 b8 ff ff ff       	call   8007d4 <strcpy>
	return dst;
}
  80081c:	89 d8                	mov    %ebx,%eax
  80081e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800821:	c9                   	leave  
  800822:	c3                   	ret    

00800823 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800823:	f3 0f 1e fb          	endbr32 
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	56                   	push   %esi
  80082b:	53                   	push   %ebx
  80082c:	8b 75 08             	mov    0x8(%ebp),%esi
  80082f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800832:	89 f3                	mov    %esi,%ebx
  800834:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800837:	89 f0                	mov    %esi,%eax
  800839:	39 d8                	cmp    %ebx,%eax
  80083b:	74 11                	je     80084e <strncpy+0x2b>
		*dst++ = *src;
  80083d:	83 c0 01             	add    $0x1,%eax
  800840:	0f b6 0a             	movzbl (%edx),%ecx
  800843:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800846:	80 f9 01             	cmp    $0x1,%cl
  800849:	83 da ff             	sbb    $0xffffffff,%edx
  80084c:	eb eb                	jmp    800839 <strncpy+0x16>
	}
	return ret;
}
  80084e:	89 f0                	mov    %esi,%eax
  800850:	5b                   	pop    %ebx
  800851:	5e                   	pop    %esi
  800852:	5d                   	pop    %ebp
  800853:	c3                   	ret    

00800854 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800854:	f3 0f 1e fb          	endbr32 
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	56                   	push   %esi
  80085c:	53                   	push   %ebx
  80085d:	8b 75 08             	mov    0x8(%ebp),%esi
  800860:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800863:	8b 55 10             	mov    0x10(%ebp),%edx
  800866:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800868:	85 d2                	test   %edx,%edx
  80086a:	74 21                	je     80088d <strlcpy+0x39>
  80086c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800870:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800872:	39 c2                	cmp    %eax,%edx
  800874:	74 14                	je     80088a <strlcpy+0x36>
  800876:	0f b6 19             	movzbl (%ecx),%ebx
  800879:	84 db                	test   %bl,%bl
  80087b:	74 0b                	je     800888 <strlcpy+0x34>
			*dst++ = *src++;
  80087d:	83 c1 01             	add    $0x1,%ecx
  800880:	83 c2 01             	add    $0x1,%edx
  800883:	88 5a ff             	mov    %bl,-0x1(%edx)
  800886:	eb ea                	jmp    800872 <strlcpy+0x1e>
  800888:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80088a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80088d:	29 f0                	sub    %esi,%eax
}
  80088f:	5b                   	pop    %ebx
  800890:	5e                   	pop    %esi
  800891:	5d                   	pop    %ebp
  800892:	c3                   	ret    

00800893 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800893:	f3 0f 1e fb          	endbr32 
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a0:	0f b6 01             	movzbl (%ecx),%eax
  8008a3:	84 c0                	test   %al,%al
  8008a5:	74 0c                	je     8008b3 <strcmp+0x20>
  8008a7:	3a 02                	cmp    (%edx),%al
  8008a9:	75 08                	jne    8008b3 <strcmp+0x20>
		p++, q++;
  8008ab:	83 c1 01             	add    $0x1,%ecx
  8008ae:	83 c2 01             	add    $0x1,%edx
  8008b1:	eb ed                	jmp    8008a0 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b3:	0f b6 c0             	movzbl %al,%eax
  8008b6:	0f b6 12             	movzbl (%edx),%edx
  8008b9:	29 d0                	sub    %edx,%eax
}
  8008bb:	5d                   	pop    %ebp
  8008bc:	c3                   	ret    

008008bd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008bd:	f3 0f 1e fb          	endbr32 
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	53                   	push   %ebx
  8008c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cb:	89 c3                	mov    %eax,%ebx
  8008cd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d0:	eb 06                	jmp    8008d8 <strncmp+0x1b>
		n--, p++, q++;
  8008d2:	83 c0 01             	add    $0x1,%eax
  8008d5:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008d8:	39 d8                	cmp    %ebx,%eax
  8008da:	74 16                	je     8008f2 <strncmp+0x35>
  8008dc:	0f b6 08             	movzbl (%eax),%ecx
  8008df:	84 c9                	test   %cl,%cl
  8008e1:	74 04                	je     8008e7 <strncmp+0x2a>
  8008e3:	3a 0a                	cmp    (%edx),%cl
  8008e5:	74 eb                	je     8008d2 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e7:	0f b6 00             	movzbl (%eax),%eax
  8008ea:	0f b6 12             	movzbl (%edx),%edx
  8008ed:	29 d0                	sub    %edx,%eax
}
  8008ef:	5b                   	pop    %ebx
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    
		return 0;
  8008f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f7:	eb f6                	jmp    8008ef <strncmp+0x32>

008008f9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f9:	f3 0f 1e fb          	endbr32 
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	8b 45 08             	mov    0x8(%ebp),%eax
  800903:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800907:	0f b6 10             	movzbl (%eax),%edx
  80090a:	84 d2                	test   %dl,%dl
  80090c:	74 09                	je     800917 <strchr+0x1e>
		if (*s == c)
  80090e:	38 ca                	cmp    %cl,%dl
  800910:	74 0a                	je     80091c <strchr+0x23>
	for (; *s; s++)
  800912:	83 c0 01             	add    $0x1,%eax
  800915:	eb f0                	jmp    800907 <strchr+0xe>
			return (char *) s;
	return 0;
  800917:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091e:	f3 0f 1e fb          	endbr32 
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	8b 45 08             	mov    0x8(%ebp),%eax
  800928:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80092c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80092f:	38 ca                	cmp    %cl,%dl
  800931:	74 09                	je     80093c <strfind+0x1e>
  800933:	84 d2                	test   %dl,%dl
  800935:	74 05                	je     80093c <strfind+0x1e>
	for (; *s; s++)
  800937:	83 c0 01             	add    $0x1,%eax
  80093a:	eb f0                	jmp    80092c <strfind+0xe>
			break;
	return (char *) s;
}
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80093e:	f3 0f 1e fb          	endbr32 
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	57                   	push   %edi
  800946:	56                   	push   %esi
  800947:	53                   	push   %ebx
  800948:	8b 7d 08             	mov    0x8(%ebp),%edi
  80094b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80094e:	85 c9                	test   %ecx,%ecx
  800950:	74 31                	je     800983 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800952:	89 f8                	mov    %edi,%eax
  800954:	09 c8                	or     %ecx,%eax
  800956:	a8 03                	test   $0x3,%al
  800958:	75 23                	jne    80097d <memset+0x3f>
		c &= 0xFF;
  80095a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80095e:	89 d3                	mov    %edx,%ebx
  800960:	c1 e3 08             	shl    $0x8,%ebx
  800963:	89 d0                	mov    %edx,%eax
  800965:	c1 e0 18             	shl    $0x18,%eax
  800968:	89 d6                	mov    %edx,%esi
  80096a:	c1 e6 10             	shl    $0x10,%esi
  80096d:	09 f0                	or     %esi,%eax
  80096f:	09 c2                	or     %eax,%edx
  800971:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800973:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800976:	89 d0                	mov    %edx,%eax
  800978:	fc                   	cld    
  800979:	f3 ab                	rep stos %eax,%es:(%edi)
  80097b:	eb 06                	jmp    800983 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80097d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800980:	fc                   	cld    
  800981:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800983:	89 f8                	mov    %edi,%eax
  800985:	5b                   	pop    %ebx
  800986:	5e                   	pop    %esi
  800987:	5f                   	pop    %edi
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80098a:	f3 0f 1e fb          	endbr32 
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	57                   	push   %edi
  800992:	56                   	push   %esi
  800993:	8b 45 08             	mov    0x8(%ebp),%eax
  800996:	8b 75 0c             	mov    0xc(%ebp),%esi
  800999:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80099c:	39 c6                	cmp    %eax,%esi
  80099e:	73 32                	jae    8009d2 <memmove+0x48>
  8009a0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a3:	39 c2                	cmp    %eax,%edx
  8009a5:	76 2b                	jbe    8009d2 <memmove+0x48>
		s += n;
		d += n;
  8009a7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009aa:	89 fe                	mov    %edi,%esi
  8009ac:	09 ce                	or     %ecx,%esi
  8009ae:	09 d6                	or     %edx,%esi
  8009b0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b6:	75 0e                	jne    8009c6 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b8:	83 ef 04             	sub    $0x4,%edi
  8009bb:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009be:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009c1:	fd                   	std    
  8009c2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c4:	eb 09                	jmp    8009cf <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c6:	83 ef 01             	sub    $0x1,%edi
  8009c9:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009cc:	fd                   	std    
  8009cd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009cf:	fc                   	cld    
  8009d0:	eb 1a                	jmp    8009ec <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d2:	89 c2                	mov    %eax,%edx
  8009d4:	09 ca                	or     %ecx,%edx
  8009d6:	09 f2                	or     %esi,%edx
  8009d8:	f6 c2 03             	test   $0x3,%dl
  8009db:	75 0a                	jne    8009e7 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009dd:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009e0:	89 c7                	mov    %eax,%edi
  8009e2:	fc                   	cld    
  8009e3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e5:	eb 05                	jmp    8009ec <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8009e7:	89 c7                	mov    %eax,%edi
  8009e9:	fc                   	cld    
  8009ea:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ec:	5e                   	pop    %esi
  8009ed:	5f                   	pop    %edi
  8009ee:	5d                   	pop    %ebp
  8009ef:	c3                   	ret    

008009f0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f0:	f3 0f 1e fb          	endbr32 
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009fa:	ff 75 10             	pushl  0x10(%ebp)
  8009fd:	ff 75 0c             	pushl  0xc(%ebp)
  800a00:	ff 75 08             	pushl  0x8(%ebp)
  800a03:	e8 82 ff ff ff       	call   80098a <memmove>
}
  800a08:	c9                   	leave  
  800a09:	c3                   	ret    

00800a0a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a0a:	f3 0f 1e fb          	endbr32 
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	56                   	push   %esi
  800a12:	53                   	push   %ebx
  800a13:	8b 45 08             	mov    0x8(%ebp),%eax
  800a16:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a19:	89 c6                	mov    %eax,%esi
  800a1b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1e:	39 f0                	cmp    %esi,%eax
  800a20:	74 1c                	je     800a3e <memcmp+0x34>
		if (*s1 != *s2)
  800a22:	0f b6 08             	movzbl (%eax),%ecx
  800a25:	0f b6 1a             	movzbl (%edx),%ebx
  800a28:	38 d9                	cmp    %bl,%cl
  800a2a:	75 08                	jne    800a34 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a2c:	83 c0 01             	add    $0x1,%eax
  800a2f:	83 c2 01             	add    $0x1,%edx
  800a32:	eb ea                	jmp    800a1e <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a34:	0f b6 c1             	movzbl %cl,%eax
  800a37:	0f b6 db             	movzbl %bl,%ebx
  800a3a:	29 d8                	sub    %ebx,%eax
  800a3c:	eb 05                	jmp    800a43 <memcmp+0x39>
	}

	return 0;
  800a3e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a43:	5b                   	pop    %ebx
  800a44:	5e                   	pop    %esi
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    

00800a47 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a47:	f3 0f 1e fb          	endbr32 
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a54:	89 c2                	mov    %eax,%edx
  800a56:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a59:	39 d0                	cmp    %edx,%eax
  800a5b:	73 09                	jae    800a66 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a5d:	38 08                	cmp    %cl,(%eax)
  800a5f:	74 05                	je     800a66 <memfind+0x1f>
	for (; s < ends; s++)
  800a61:	83 c0 01             	add    $0x1,%eax
  800a64:	eb f3                	jmp    800a59 <memfind+0x12>
			break;
	return (void *) s;
}
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a68:	f3 0f 1e fb          	endbr32 
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	57                   	push   %edi
  800a70:	56                   	push   %esi
  800a71:	53                   	push   %ebx
  800a72:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a75:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a78:	eb 03                	jmp    800a7d <strtol+0x15>
		s++;
  800a7a:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a7d:	0f b6 01             	movzbl (%ecx),%eax
  800a80:	3c 20                	cmp    $0x20,%al
  800a82:	74 f6                	je     800a7a <strtol+0x12>
  800a84:	3c 09                	cmp    $0x9,%al
  800a86:	74 f2                	je     800a7a <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a88:	3c 2b                	cmp    $0x2b,%al
  800a8a:	74 2a                	je     800ab6 <strtol+0x4e>
	int neg = 0;
  800a8c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a91:	3c 2d                	cmp    $0x2d,%al
  800a93:	74 2b                	je     800ac0 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a95:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a9b:	75 0f                	jne    800aac <strtol+0x44>
  800a9d:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa0:	74 28                	je     800aca <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aa2:	85 db                	test   %ebx,%ebx
  800aa4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aa9:	0f 44 d8             	cmove  %eax,%ebx
  800aac:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab1:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ab4:	eb 46                	jmp    800afc <strtol+0x94>
		s++;
  800ab6:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ab9:	bf 00 00 00 00       	mov    $0x0,%edi
  800abe:	eb d5                	jmp    800a95 <strtol+0x2d>
		s++, neg = 1;
  800ac0:	83 c1 01             	add    $0x1,%ecx
  800ac3:	bf 01 00 00 00       	mov    $0x1,%edi
  800ac8:	eb cb                	jmp    800a95 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aca:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ace:	74 0e                	je     800ade <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ad0:	85 db                	test   %ebx,%ebx
  800ad2:	75 d8                	jne    800aac <strtol+0x44>
		s++, base = 8;
  800ad4:	83 c1 01             	add    $0x1,%ecx
  800ad7:	bb 08 00 00 00       	mov    $0x8,%ebx
  800adc:	eb ce                	jmp    800aac <strtol+0x44>
		s += 2, base = 16;
  800ade:	83 c1 02             	add    $0x2,%ecx
  800ae1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ae6:	eb c4                	jmp    800aac <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ae8:	0f be d2             	movsbl %dl,%edx
  800aeb:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aee:	3b 55 10             	cmp    0x10(%ebp),%edx
  800af1:	7d 3a                	jge    800b2d <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800af3:	83 c1 01             	add    $0x1,%ecx
  800af6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800afa:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800afc:	0f b6 11             	movzbl (%ecx),%edx
  800aff:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b02:	89 f3                	mov    %esi,%ebx
  800b04:	80 fb 09             	cmp    $0x9,%bl
  800b07:	76 df                	jbe    800ae8 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b09:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b0c:	89 f3                	mov    %esi,%ebx
  800b0e:	80 fb 19             	cmp    $0x19,%bl
  800b11:	77 08                	ja     800b1b <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b13:	0f be d2             	movsbl %dl,%edx
  800b16:	83 ea 57             	sub    $0x57,%edx
  800b19:	eb d3                	jmp    800aee <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b1b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b1e:	89 f3                	mov    %esi,%ebx
  800b20:	80 fb 19             	cmp    $0x19,%bl
  800b23:	77 08                	ja     800b2d <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b25:	0f be d2             	movsbl %dl,%edx
  800b28:	83 ea 37             	sub    $0x37,%edx
  800b2b:	eb c1                	jmp    800aee <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b2d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b31:	74 05                	je     800b38 <strtol+0xd0>
		*endptr = (char *) s;
  800b33:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b36:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b38:	89 c2                	mov    %eax,%edx
  800b3a:	f7 da                	neg    %edx
  800b3c:	85 ff                	test   %edi,%edi
  800b3e:	0f 45 c2             	cmovne %edx,%eax
}
  800b41:	5b                   	pop    %ebx
  800b42:	5e                   	pop    %esi
  800b43:	5f                   	pop    %edi
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b46:	f3 0f 1e fb          	endbr32 
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	57                   	push   %edi
  800b4e:	56                   	push   %esi
  800b4f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b50:	b8 00 00 00 00       	mov    $0x0,%eax
  800b55:	8b 55 08             	mov    0x8(%ebp),%edx
  800b58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5b:	89 c3                	mov    %eax,%ebx
  800b5d:	89 c7                	mov    %eax,%edi
  800b5f:	89 c6                	mov    %eax,%esi
  800b61:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b63:	5b                   	pop    %ebx
  800b64:	5e                   	pop    %esi
  800b65:	5f                   	pop    %edi
  800b66:	5d                   	pop    %ebp
  800b67:	c3                   	ret    

00800b68 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b68:	f3 0f 1e fb          	endbr32 
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	57                   	push   %edi
  800b70:	56                   	push   %esi
  800b71:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b72:	ba 00 00 00 00       	mov    $0x0,%edx
  800b77:	b8 01 00 00 00       	mov    $0x1,%eax
  800b7c:	89 d1                	mov    %edx,%ecx
  800b7e:	89 d3                	mov    %edx,%ebx
  800b80:	89 d7                	mov    %edx,%edi
  800b82:	89 d6                	mov    %edx,%esi
  800b84:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b86:	5b                   	pop    %ebx
  800b87:	5e                   	pop    %esi
  800b88:	5f                   	pop    %edi
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    

00800b8b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b8b:	f3 0f 1e fb          	endbr32 
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	57                   	push   %edi
  800b93:	56                   	push   %esi
  800b94:	53                   	push   %ebx
  800b95:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b98:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba0:	b8 03 00 00 00       	mov    $0x3,%eax
  800ba5:	89 cb                	mov    %ecx,%ebx
  800ba7:	89 cf                	mov    %ecx,%edi
  800ba9:	89 ce                	mov    %ecx,%esi
  800bab:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bad:	85 c0                	test   %eax,%eax
  800baf:	7f 08                	jg     800bb9 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb9:	83 ec 0c             	sub    $0xc,%esp
  800bbc:	50                   	push   %eax
  800bbd:	6a 03                	push   $0x3
  800bbf:	68 1f 18 80 00       	push   $0x80181f
  800bc4:	6a 23                	push   $0x23
  800bc6:	68 3c 18 80 00       	push   $0x80183c
  800bcb:	e8 af 05 00 00       	call   80117f <_panic>

00800bd0 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bd0:	f3 0f 1e fb          	endbr32 
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	57                   	push   %edi
  800bd8:	56                   	push   %esi
  800bd9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bda:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdf:	b8 02 00 00 00       	mov    $0x2,%eax
  800be4:	89 d1                	mov    %edx,%ecx
  800be6:	89 d3                	mov    %edx,%ebx
  800be8:	89 d7                	mov    %edx,%edi
  800bea:	89 d6                	mov    %edx,%esi
  800bec:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bee:	5b                   	pop    %ebx
  800bef:	5e                   	pop    %esi
  800bf0:	5f                   	pop    %edi
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    

00800bf3 <sys_yield>:

void
sys_yield(void)
{
  800bf3:	f3 0f 1e fb          	endbr32 
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	57                   	push   %edi
  800bfb:	56                   	push   %esi
  800bfc:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bfd:	ba 00 00 00 00       	mov    $0x0,%edx
  800c02:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c07:	89 d1                	mov    %edx,%ecx
  800c09:	89 d3                	mov    %edx,%ebx
  800c0b:	89 d7                	mov    %edx,%edi
  800c0d:	89 d6                	mov    %edx,%esi
  800c0f:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c11:	5b                   	pop    %ebx
  800c12:	5e                   	pop    %esi
  800c13:	5f                   	pop    %edi
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    

00800c16 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c16:	f3 0f 1e fb          	endbr32 
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	57                   	push   %edi
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
  800c20:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c23:	be 00 00 00 00       	mov    $0x0,%esi
  800c28:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2e:	b8 04 00 00 00       	mov    $0x4,%eax
  800c33:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c36:	89 f7                	mov    %esi,%edi
  800c38:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c3a:	85 c0                	test   %eax,%eax
  800c3c:	7f 08                	jg     800c46 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c46:	83 ec 0c             	sub    $0xc,%esp
  800c49:	50                   	push   %eax
  800c4a:	6a 04                	push   $0x4
  800c4c:	68 1f 18 80 00       	push   $0x80181f
  800c51:	6a 23                	push   $0x23
  800c53:	68 3c 18 80 00       	push   $0x80183c
  800c58:	e8 22 05 00 00       	call   80117f <_panic>

00800c5d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c5d:	f3 0f 1e fb          	endbr32 
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	57                   	push   %edi
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
  800c67:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c70:	b8 05 00 00 00       	mov    $0x5,%eax
  800c75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c78:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c7b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c7e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c80:	85 c0                	test   %eax,%eax
  800c82:	7f 08                	jg     800c8c <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c87:	5b                   	pop    %ebx
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8c:	83 ec 0c             	sub    $0xc,%esp
  800c8f:	50                   	push   %eax
  800c90:	6a 05                	push   $0x5
  800c92:	68 1f 18 80 00       	push   $0x80181f
  800c97:	6a 23                	push   $0x23
  800c99:	68 3c 18 80 00       	push   $0x80183c
  800c9e:	e8 dc 04 00 00       	call   80117f <_panic>

00800ca3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ca3:	f3 0f 1e fb          	endbr32 
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	57                   	push   %edi
  800cab:	56                   	push   %esi
  800cac:	53                   	push   %ebx
  800cad:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cb0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbb:	b8 06 00 00 00       	mov    $0x6,%eax
  800cc0:	89 df                	mov    %ebx,%edi
  800cc2:	89 de                	mov    %ebx,%esi
  800cc4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cc6:	85 c0                	test   %eax,%eax
  800cc8:	7f 08                	jg     800cd2 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccd:	5b                   	pop    %ebx
  800cce:	5e                   	pop    %esi
  800ccf:	5f                   	pop    %edi
  800cd0:	5d                   	pop    %ebp
  800cd1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd2:	83 ec 0c             	sub    $0xc,%esp
  800cd5:	50                   	push   %eax
  800cd6:	6a 06                	push   $0x6
  800cd8:	68 1f 18 80 00       	push   $0x80181f
  800cdd:	6a 23                	push   $0x23
  800cdf:	68 3c 18 80 00       	push   $0x80183c
  800ce4:	e8 96 04 00 00       	call   80117f <_panic>

00800ce9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ce9:	f3 0f 1e fb          	endbr32 
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
  800cf0:	57                   	push   %edi
  800cf1:	56                   	push   %esi
  800cf2:	53                   	push   %ebx
  800cf3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cf6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d01:	b8 08 00 00 00       	mov    $0x8,%eax
  800d06:	89 df                	mov    %ebx,%edi
  800d08:	89 de                	mov    %ebx,%esi
  800d0a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d0c:	85 c0                	test   %eax,%eax
  800d0e:	7f 08                	jg     800d18 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d13:	5b                   	pop    %ebx
  800d14:	5e                   	pop    %esi
  800d15:	5f                   	pop    %edi
  800d16:	5d                   	pop    %ebp
  800d17:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d18:	83 ec 0c             	sub    $0xc,%esp
  800d1b:	50                   	push   %eax
  800d1c:	6a 08                	push   $0x8
  800d1e:	68 1f 18 80 00       	push   $0x80181f
  800d23:	6a 23                	push   $0x23
  800d25:	68 3c 18 80 00       	push   $0x80183c
  800d2a:	e8 50 04 00 00       	call   80117f <_panic>

00800d2f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d2f:	f3 0f 1e fb          	endbr32 
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	57                   	push   %edi
  800d37:	56                   	push   %esi
  800d38:	53                   	push   %ebx
  800d39:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d41:	8b 55 08             	mov    0x8(%ebp),%edx
  800d44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d47:	b8 09 00 00 00       	mov    $0x9,%eax
  800d4c:	89 df                	mov    %ebx,%edi
  800d4e:	89 de                	mov    %ebx,%esi
  800d50:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d52:	85 c0                	test   %eax,%eax
  800d54:	7f 08                	jg     800d5e <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
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
  800d62:	6a 09                	push   $0x9
  800d64:	68 1f 18 80 00       	push   $0x80181f
  800d69:	6a 23                	push   $0x23
  800d6b:	68 3c 18 80 00       	push   $0x80183c
  800d70:	e8 0a 04 00 00       	call   80117f <_panic>

00800d75 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d75:	f3 0f 1e fb          	endbr32 
  800d79:	55                   	push   %ebp
  800d7a:	89 e5                	mov    %esp,%ebp
  800d7c:	57                   	push   %edi
  800d7d:	56                   	push   %esi
  800d7e:	53                   	push   %ebx
  800d7f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d82:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d87:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d92:	89 df                	mov    %ebx,%edi
  800d94:	89 de                	mov    %ebx,%esi
  800d96:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d98:	85 c0                	test   %eax,%eax
  800d9a:	7f 08                	jg     800da4 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9f:	5b                   	pop    %ebx
  800da0:	5e                   	pop    %esi
  800da1:	5f                   	pop    %edi
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800da4:	83 ec 0c             	sub    $0xc,%esp
  800da7:	50                   	push   %eax
  800da8:	6a 0a                	push   $0xa
  800daa:	68 1f 18 80 00       	push   $0x80181f
  800daf:	6a 23                	push   $0x23
  800db1:	68 3c 18 80 00       	push   $0x80183c
  800db6:	e8 c4 03 00 00       	call   80117f <_panic>

00800dbb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dbb:	f3 0f 1e fb          	endbr32 
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	57                   	push   %edi
  800dc3:	56                   	push   %esi
  800dc4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dd0:	be 00 00 00 00       	mov    $0x0,%esi
  800dd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ddb:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800de2:	f3 0f 1e fb          	endbr32 
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	57                   	push   %edi
  800dea:	56                   	push   %esi
  800deb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dec:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df1:	8b 55 08             	mov    0x8(%ebp),%edx
  800df4:	b8 0d 00 00 00       	mov    $0xd,%eax
  800df9:	89 cb                	mov    %ecx,%ebx
  800dfb:	89 cf                	mov    %ecx,%edi
  800dfd:	89 ce                	mov    %ecx,%esi
  800dff:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 0, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e01:	5b                   	pop    %ebx
  800e02:	5e                   	pop    %esi
  800e03:	5f                   	pop    %edi
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    

00800e06 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e06:	f3 0f 1e fb          	endbr32 
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	53                   	push   %ebx
  800e0e:	83 ec 04             	sub    $0x4,%esp
  800e11:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e14:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if ( !(err & FEC_WR) ||
  800e16:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e1a:	74 75                	je     800e91 <pgfault+0x8b>
            !(uvpt[PGNUM(addr)] | PTE_COW) ) {
  800e1c:	89 d8                	mov    %ebx,%eax
  800e1e:	c1 e8 0c             	shr    $0xc,%eax
  800e21:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, (void *)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0) {
  800e28:	83 ec 04             	sub    $0x4,%esp
  800e2b:	6a 07                	push   $0x7
  800e2d:	68 00 f0 7f 00       	push   $0x7ff000
  800e32:	6a 00                	push   $0x0
  800e34:	e8 dd fd ff ff       	call   800c16 <sys_page_alloc>
  800e39:	83 c4 10             	add    $0x10,%esp
  800e3c:	85 c0                	test   %eax,%eax
  800e3e:	78 65                	js     800ea5 <pgfault+0x9f>
        panic("sys_page_alloc failed %e\n", r);
    }
    memmove((void *)PFTEMP, (void *)PTE_ADDR(addr), PGSIZE);
  800e40:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800e46:	83 ec 04             	sub    $0x4,%esp
  800e49:	68 00 10 00 00       	push   $0x1000
  800e4e:	53                   	push   %ebx
  800e4f:	68 00 f0 7f 00       	push   $0x7ff000
  800e54:	e8 31 fb ff ff       	call   80098a <memmove>
    if ((r = sys_page_map(0, (void *)PFTEMP,
  800e59:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e60:	53                   	push   %ebx
  800e61:	6a 00                	push   $0x0
  800e63:	68 00 f0 7f 00       	push   $0x7ff000
  800e68:	6a 00                	push   $0x0
  800e6a:	e8 ee fd ff ff       	call   800c5d <sys_page_map>
  800e6f:	83 c4 20             	add    $0x20,%esp
  800e72:	85 c0                	test   %eax,%eax
  800e74:	78 41                	js     800eb7 <pgfault+0xb1>
                0, (void *)PTE_ADDR(addr), PTE_P | PTE_U | PTE_W)) < 0) {
        panic("sys_page_map failed %e\n", r);
    }
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0) {
  800e76:	83 ec 08             	sub    $0x8,%esp
  800e79:	68 00 f0 7f 00       	push   $0x7ff000
  800e7e:	6a 00                	push   $0x0
  800e80:	e8 1e fe ff ff       	call   800ca3 <sys_page_unmap>
  800e85:	83 c4 10             	add    $0x10,%esp
  800e88:	85 c0                	test   %eax,%eax
  800e8a:	78 3d                	js     800ec9 <pgfault+0xc3>
        panic("sys_page_unmap failed %e\n", r);
    }

}
  800e8c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e8f:	c9                   	leave  
  800e90:	c3                   	ret    
        panic("Not a copy-on-write page");
  800e91:	83 ec 04             	sub    $0x4,%esp
  800e94:	68 4a 18 80 00       	push   $0x80184a
  800e99:	6a 1e                	push   $0x1e
  800e9b:	68 63 18 80 00       	push   $0x801863
  800ea0:	e8 da 02 00 00       	call   80117f <_panic>
        panic("sys_page_alloc failed %e\n", r);
  800ea5:	50                   	push   %eax
  800ea6:	68 6e 18 80 00       	push   $0x80186e
  800eab:	6a 2a                	push   $0x2a
  800ead:	68 63 18 80 00       	push   $0x801863
  800eb2:	e8 c8 02 00 00       	call   80117f <_panic>
        panic("sys_page_map failed %e\n", r);
  800eb7:	50                   	push   %eax
  800eb8:	68 88 18 80 00       	push   $0x801888
  800ebd:	6a 2f                	push   $0x2f
  800ebf:	68 63 18 80 00       	push   $0x801863
  800ec4:	e8 b6 02 00 00       	call   80117f <_panic>
        panic("sys_page_unmap failed %e\n", r);
  800ec9:	50                   	push   %eax
  800eca:	68 a0 18 80 00       	push   $0x8018a0
  800ecf:	6a 32                	push   $0x32
  800ed1:	68 63 18 80 00       	push   $0x801863
  800ed6:	e8 a4 02 00 00       	call   80117f <_panic>

00800edb <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800edb:	f3 0f 1e fb          	endbr32 
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
  800ee2:	57                   	push   %edi
  800ee3:	56                   	push   %esi
  800ee4:	53                   	push   %ebx
  800ee5:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");

    // 1. set pgfault handler.
    set_pgfault_handler(pgfault);
  800ee8:	68 06 0e 80 00       	push   $0x800e06
  800eed:	e8 d7 02 00 00       	call   8011c9 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ef2:	b8 07 00 00 00       	mov    $0x7,%eax
  800ef7:	cd 30                	int    $0x30
  800ef9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800efc:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    // 2. exofork.
    envid_t envid = sys_exofork();

    if (envid < 0)
  800eff:	83 c4 10             	add    $0x10,%esp
  800f02:	85 c0                	test   %eax,%eax
  800f04:	78 2a                	js     800f30 <fork+0x55>
        thisenv = &envs[ENVX(my_envid)];
        return 0;
    }
    else {
        // parent
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800f06:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (envid == 0) {
  800f0b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800f0f:	75 63                	jne    800f74 <fork+0x99>
        envid_t my_envid = sys_getenvid();
  800f11:	e8 ba fc ff ff       	call   800bd0 <sys_getenvid>
        thisenv = &envs[ENVX(my_envid)];
  800f16:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f1b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f1e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f23:	a3 04 20 80 00       	mov    %eax,0x802004
        return 0;
  800f28:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f2b:	e9 2f 01 00 00       	jmp    80105f <fork+0x184>
        panic("fork, sys_exofork %e", envid);
  800f30:	50                   	push   %eax
  800f31:	68 ba 18 80 00       	push   $0x8018ba
  800f36:	68 82 00 00 00       	push   $0x82
  800f3b:	68 63 18 80 00       	push   $0x801863
  800f40:	e8 3a 02 00 00       	call   80117f <_panic>
    	if ((r = sys_page_map(0, addr, envid, addr, pte & PTE_SYSCALL)) < 0) {
  800f45:	83 ec 0c             	sub    $0xc,%esp
  800f48:	25 07 0e 00 00       	and    $0xe07,%eax
  800f4d:	50                   	push   %eax
  800f4e:	56                   	push   %esi
  800f4f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f52:	56                   	push   %esi
  800f53:	6a 00                	push   $0x0
  800f55:	e8 03 fd ff ff       	call   800c5d <sys_page_map>
  800f5a:	83 c4 20             	add    $0x20,%esp
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	0f 88 90 00 00 00    	js     800ff5 <fork+0x11a>
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800f65:	83 c3 01             	add    $0x1,%ebx
  800f68:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  800f6e:	0f 84 a5 00 00 00    	je     801019 <fork+0x13e>
  800f74:	89 de                	mov    %ebx,%esi
  800f76:	c1 e6 0c             	shl    $0xc,%esi
            uintptr_t pgaddr = pn << PGSHIFT;
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800f79:	89 f0                	mov    %esi,%eax
  800f7b:	c1 e8 16             	shr    $0x16,%eax
  800f7e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f85:	a8 01                	test   $0x1,%al
  800f87:	74 dc                	je     800f65 <fork+0x8a>
                    (uvpt[pn] & PTE_P) ) {
  800f89:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800f90:	a8 01                	test   $0x1,%al
  800f92:	74 d1                	je     800f65 <fork+0x8a>
    pte_t pte = uvpt[pn];
  800f94:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
    if ( pte & PTE_SHARE) {
  800f9b:	f6 c4 04             	test   $0x4,%ah
  800f9e:	75 a5                	jne    800f45 <fork+0x6a>
    if ( ((pte & PTE_W) || (pte & PTE_COW)) && !(pte & PTE_SHARE)) {
  800fa0:	25 02 08 00 00       	and    $0x802,%eax
        perm |= PTE_COW;
  800fa5:	83 f8 01             	cmp    $0x1,%eax
  800fa8:	19 ff                	sbb    %edi,%edi
  800faa:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  800fb0:	81 c7 05 08 00 00    	add    $0x805,%edi
    if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0) {
  800fb6:	83 ec 0c             	sub    $0xc,%esp
  800fb9:	57                   	push   %edi
  800fba:	56                   	push   %esi
  800fbb:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fbe:	56                   	push   %esi
  800fbf:	6a 00                	push   $0x0
  800fc1:	e8 97 fc ff ff       	call   800c5d <sys_page_map>
  800fc6:	83 c4 20             	add    $0x20,%esp
  800fc9:	85 c0                	test   %eax,%eax
  800fcb:	78 3a                	js     801007 <fork+0x12c>
        if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0) {
  800fcd:	83 ec 0c             	sub    $0xc,%esp
  800fd0:	57                   	push   %edi
  800fd1:	56                   	push   %esi
  800fd2:	6a 00                	push   $0x0
  800fd4:	56                   	push   %esi
  800fd5:	6a 00                	push   $0x0
  800fd7:	e8 81 fc ff ff       	call   800c5d <sys_page_map>
  800fdc:	83 c4 20             	add    $0x20,%esp
  800fdf:	85 c0                	test   %eax,%eax
  800fe1:	79 82                	jns    800f65 <fork+0x8a>
            panic("sys_page_map mine failed %e\n", r);
  800fe3:	50                   	push   %eax
  800fe4:	68 cf 18 80 00       	push   $0x8018cf
  800fe9:	6a 5d                	push   $0x5d
  800feb:	68 63 18 80 00       	push   $0x801863
  800ff0:	e8 8a 01 00 00       	call   80117f <_panic>
    	    panic("sys_page_map others failed %e\n", r);
  800ff5:	50                   	push   %eax
  800ff6:	68 04 19 80 00       	push   $0x801904
  800ffb:	6a 4d                	push   $0x4d
  800ffd:	68 63 18 80 00       	push   $0x801863
  801002:	e8 78 01 00 00       	call   80117f <_panic>
        panic("sys_page_map others failed %e\n", r);
  801007:	50                   	push   %eax
  801008:	68 04 19 80 00       	push   $0x801904
  80100d:	6a 58                	push   $0x58
  80100f:	68 63 18 80 00       	push   $0x801863
  801014:	e8 66 01 00 00       	call   80117f <_panic>
            }
        }

        int r;

        if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE),
  801019:	83 ec 04             	sub    $0x4,%esp
  80101c:	6a 07                	push   $0x7
  80101e:	68 00 f0 bf ee       	push   $0xeebff000
  801023:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801026:	57                   	push   %edi
  801027:	e8 ea fb ff ff       	call   800c16 <sys_page_alloc>
  80102c:	83 c4 10             	add    $0x10,%esp
  80102f:	85 c0                	test   %eax,%eax
  801031:	78 2c                	js     80105f <fork+0x184>
                    PTE_U | PTE_W | PTE_P)) < 0) {
            return r;
        }

        if ((r = sys_env_set_pgfault_upcall(envid,
                        thisenv->env_pgfault_upcall)) < 0) {
  801033:	a1 04 20 80 00       	mov    0x802004,%eax
        if ((r = sys_env_set_pgfault_upcall(envid,
  801038:	8b 40 64             	mov    0x64(%eax),%eax
  80103b:	83 ec 08             	sub    $0x8,%esp
  80103e:	50                   	push   %eax
  80103f:	57                   	push   %edi
  801040:	e8 30 fd ff ff       	call   800d75 <sys_env_set_pgfault_upcall>
  801045:	83 c4 10             	add    $0x10,%esp
  801048:	85 c0                	test   %eax,%eax
  80104a:	78 13                	js     80105f <fork+0x184>
            return r;
        }

        if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  80104c:	83 ec 08             	sub    $0x8,%esp
  80104f:	6a 02                	push   $0x2
  801051:	57                   	push   %edi
  801052:	e8 92 fc ff ff       	call   800ce9 <sys_env_set_status>
  801057:	83 c4 10             	add    $0x10,%esp
            return r;
        }
        return envid;
  80105a:	85 c0                	test   %eax,%eax
  80105c:	0f 49 c7             	cmovns %edi,%eax
    }

}
  80105f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801062:	5b                   	pop    %ebx
  801063:	5e                   	pop    %esi
  801064:	5f                   	pop    %edi
  801065:	5d                   	pop    %ebp
  801066:	c3                   	ret    

00801067 <sfork>:

// Challenge!
int
sfork(void)
{
  801067:	f3 0f 1e fb          	endbr32 
  80106b:	55                   	push   %ebp
  80106c:	89 e5                	mov    %esp,%ebp
  80106e:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801071:	68 ec 18 80 00       	push   $0x8018ec
  801076:	68 ac 00 00 00       	push   $0xac
  80107b:	68 63 18 80 00       	push   $0x801863
  801080:	e8 fa 00 00 00       	call   80117f <_panic>

00801085 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801085:	f3 0f 1e fb          	endbr32 
  801089:	55                   	push   %ebp
  80108a:	89 e5                	mov    %esp,%ebp
  80108c:	56                   	push   %esi
  80108d:	53                   	push   %ebx
  80108e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801091:	8b 45 0c             	mov    0xc(%ebp),%eax
  801094:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)KERNBASE : pg)) < 0) {
  801097:	85 c0                	test   %eax,%eax
  801099:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  80109e:	0f 44 c2             	cmove  %edx,%eax
  8010a1:	83 ec 0c             	sub    $0xc,%esp
  8010a4:	50                   	push   %eax
  8010a5:	e8 38 fd ff ff       	call   800de2 <sys_ipc_recv>
  8010aa:	83 c4 10             	add    $0x10,%esp
  8010ad:	85 c0                	test   %eax,%eax
  8010af:	78 24                	js     8010d5 <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  8010b1:	85 f6                	test   %esi,%esi
  8010b3:	74 0a                	je     8010bf <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  8010b5:	a1 04 20 80 00       	mov    0x802004,%eax
  8010ba:	8b 40 78             	mov    0x78(%eax),%eax
  8010bd:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  8010bf:	85 db                	test   %ebx,%ebx
  8010c1:	74 0a                	je     8010cd <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  8010c3:	a1 04 20 80 00       	mov    0x802004,%eax
  8010c8:	8b 40 74             	mov    0x74(%eax),%eax
  8010cb:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  8010cd:	a1 04 20 80 00       	mov    0x802004,%eax
  8010d2:	8b 40 70             	mov    0x70(%eax),%eax
}
  8010d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010d8:	5b                   	pop    %ebx
  8010d9:	5e                   	pop    %esi
  8010da:	5d                   	pop    %ebp
  8010db:	c3                   	ret    

008010dc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010dc:	f3 0f 1e fb          	endbr32 
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	57                   	push   %edi
  8010e4:	56                   	push   %esi
  8010e5:	53                   	push   %ebx
  8010e6:	83 ec 1c             	sub    $0x1c,%esp
  8010e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8010ec:	85 c0                	test   %eax,%eax
  8010ee:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8010f3:	0f 45 d0             	cmovne %eax,%edx
  8010f6:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  8010f8:	be 01 00 00 00       	mov    $0x1,%esi
  8010fd:	eb 1f                	jmp    80111e <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  8010ff:	e8 ef fa ff ff       	call   800bf3 <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801104:	83 c3 01             	add    $0x1,%ebx
  801107:	39 de                	cmp    %ebx,%esi
  801109:	7f f4                	jg     8010ff <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  80110b:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  80110d:	83 fe 11             	cmp    $0x11,%esi
  801110:	b8 01 00 00 00       	mov    $0x1,%eax
  801115:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801118:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  80111c:	75 1c                	jne    80113a <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  80111e:	ff 75 14             	pushl  0x14(%ebp)
  801121:	57                   	push   %edi
  801122:	ff 75 0c             	pushl  0xc(%ebp)
  801125:	ff 75 08             	pushl  0x8(%ebp)
  801128:	e8 8e fc ff ff       	call   800dbb <sys_ipc_try_send>
  80112d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801130:	83 c4 10             	add    $0x10,%esp
  801133:	bb 00 00 00 00       	mov    $0x0,%ebx
  801138:	eb cd                	jmp    801107 <ipc_send+0x2b>
}
  80113a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113d:	5b                   	pop    %ebx
  80113e:	5e                   	pop    %esi
  80113f:	5f                   	pop    %edi
  801140:	5d                   	pop    %ebp
  801141:	c3                   	ret    

00801142 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801142:	f3 0f 1e fb          	endbr32 
  801146:	55                   	push   %ebp
  801147:	89 e5                	mov    %esp,%ebp
  801149:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80114c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801151:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801154:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80115a:	8b 52 50             	mov    0x50(%edx),%edx
  80115d:	39 ca                	cmp    %ecx,%edx
  80115f:	74 11                	je     801172 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801161:	83 c0 01             	add    $0x1,%eax
  801164:	3d 00 04 00 00       	cmp    $0x400,%eax
  801169:	75 e6                	jne    801151 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  80116b:	b8 00 00 00 00       	mov    $0x0,%eax
  801170:	eb 0b                	jmp    80117d <ipc_find_env+0x3b>
			return envs[i].env_id;
  801172:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801175:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80117a:	8b 40 48             	mov    0x48(%eax),%eax
}
  80117d:	5d                   	pop    %ebp
  80117e:	c3                   	ret    

0080117f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80117f:	f3 0f 1e fb          	endbr32 
  801183:	55                   	push   %ebp
  801184:	89 e5                	mov    %esp,%ebp
  801186:	56                   	push   %esi
  801187:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801188:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80118b:	8b 35 00 20 80 00    	mov    0x802000,%esi
  801191:	e8 3a fa ff ff       	call   800bd0 <sys_getenvid>
  801196:	83 ec 0c             	sub    $0xc,%esp
  801199:	ff 75 0c             	pushl  0xc(%ebp)
  80119c:	ff 75 08             	pushl  0x8(%ebp)
  80119f:	56                   	push   %esi
  8011a0:	50                   	push   %eax
  8011a1:	68 24 19 80 00       	push   $0x801924
  8011a6:	e8 20 f0 ff ff       	call   8001cb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8011ab:	83 c4 18             	add    $0x18,%esp
  8011ae:	53                   	push   %ebx
  8011af:	ff 75 10             	pushl  0x10(%ebp)
  8011b2:	e8 bf ef ff ff       	call   800176 <vcprintf>
	cprintf("\n");
  8011b7:	c7 04 24 54 19 80 00 	movl   $0x801954,(%esp)
  8011be:	e8 08 f0 ff ff       	call   8001cb <cprintf>
  8011c3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011c6:	cc                   	int3   
  8011c7:	eb fd                	jmp    8011c6 <_panic+0x47>

008011c9 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8011c9:	f3 0f 1e fb          	endbr32 
  8011cd:	55                   	push   %ebp
  8011ce:	89 e5                	mov    %esp,%ebp
  8011d0:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8011d3:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  8011da:	74 0a                	je     8011e6 <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8011dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8011df:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8011e4:	c9                   	leave  
  8011e5:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  8011e6:	83 ec 0c             	sub    $0xc,%esp
  8011e9:	68 47 19 80 00       	push   $0x801947
  8011ee:	e8 d8 ef ff ff       	call   8001cb <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  8011f3:	83 c4 0c             	add    $0xc,%esp
  8011f6:	6a 07                	push   $0x7
  8011f8:	68 00 f0 bf ee       	push   $0xeebff000
  8011fd:	6a 00                	push   $0x0
  8011ff:	e8 12 fa ff ff       	call   800c16 <sys_page_alloc>
  801204:	83 c4 10             	add    $0x10,%esp
  801207:	85 c0                	test   %eax,%eax
  801209:	78 2a                	js     801235 <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  80120b:	83 ec 08             	sub    $0x8,%esp
  80120e:	68 49 12 80 00       	push   $0x801249
  801213:	6a 00                	push   $0x0
  801215:	e8 5b fb ff ff       	call   800d75 <sys_env_set_pgfault_upcall>
  80121a:	83 c4 10             	add    $0x10,%esp
  80121d:	85 c0                	test   %eax,%eax
  80121f:	79 bb                	jns    8011dc <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  801221:	83 ec 04             	sub    $0x4,%esp
  801224:	68 84 19 80 00       	push   $0x801984
  801229:	6a 25                	push   $0x25
  80122b:	68 74 19 80 00       	push   $0x801974
  801230:	e8 4a ff ff ff       	call   80117f <_panic>
            panic("Allocation of UXSTACK failed!");
  801235:	83 ec 04             	sub    $0x4,%esp
  801238:	68 56 19 80 00       	push   $0x801956
  80123d:	6a 22                	push   $0x22
  80123f:	68 74 19 80 00       	push   $0x801974
  801244:	e8 36 ff ff ff       	call   80117f <_panic>

00801249 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801249:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80124a:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80124f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801251:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  801254:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  801258:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  80125c:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  80125f:	83 c4 08             	add    $0x8,%esp
    popa
  801262:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

    add $0x4, %esp
  801263:	83 c4 04             	add    $0x4,%esp
    popf
  801266:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  801267:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  80126a:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  80126e:	c3                   	ret    
  80126f:	90                   	nop

00801270 <__udivdi3>:
  801270:	f3 0f 1e fb          	endbr32 
  801274:	55                   	push   %ebp
  801275:	57                   	push   %edi
  801276:	56                   	push   %esi
  801277:	53                   	push   %ebx
  801278:	83 ec 1c             	sub    $0x1c,%esp
  80127b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80127f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801283:	8b 74 24 34          	mov    0x34(%esp),%esi
  801287:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80128b:	85 d2                	test   %edx,%edx
  80128d:	75 19                	jne    8012a8 <__udivdi3+0x38>
  80128f:	39 f3                	cmp    %esi,%ebx
  801291:	76 4d                	jbe    8012e0 <__udivdi3+0x70>
  801293:	31 ff                	xor    %edi,%edi
  801295:	89 e8                	mov    %ebp,%eax
  801297:	89 f2                	mov    %esi,%edx
  801299:	f7 f3                	div    %ebx
  80129b:	89 fa                	mov    %edi,%edx
  80129d:	83 c4 1c             	add    $0x1c,%esp
  8012a0:	5b                   	pop    %ebx
  8012a1:	5e                   	pop    %esi
  8012a2:	5f                   	pop    %edi
  8012a3:	5d                   	pop    %ebp
  8012a4:	c3                   	ret    
  8012a5:	8d 76 00             	lea    0x0(%esi),%esi
  8012a8:	39 f2                	cmp    %esi,%edx
  8012aa:	76 14                	jbe    8012c0 <__udivdi3+0x50>
  8012ac:	31 ff                	xor    %edi,%edi
  8012ae:	31 c0                	xor    %eax,%eax
  8012b0:	89 fa                	mov    %edi,%edx
  8012b2:	83 c4 1c             	add    $0x1c,%esp
  8012b5:	5b                   	pop    %ebx
  8012b6:	5e                   	pop    %esi
  8012b7:	5f                   	pop    %edi
  8012b8:	5d                   	pop    %ebp
  8012b9:	c3                   	ret    
  8012ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012c0:	0f bd fa             	bsr    %edx,%edi
  8012c3:	83 f7 1f             	xor    $0x1f,%edi
  8012c6:	75 48                	jne    801310 <__udivdi3+0xa0>
  8012c8:	39 f2                	cmp    %esi,%edx
  8012ca:	72 06                	jb     8012d2 <__udivdi3+0x62>
  8012cc:	31 c0                	xor    %eax,%eax
  8012ce:	39 eb                	cmp    %ebp,%ebx
  8012d0:	77 de                	ja     8012b0 <__udivdi3+0x40>
  8012d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8012d7:	eb d7                	jmp    8012b0 <__udivdi3+0x40>
  8012d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012e0:	89 d9                	mov    %ebx,%ecx
  8012e2:	85 db                	test   %ebx,%ebx
  8012e4:	75 0b                	jne    8012f1 <__udivdi3+0x81>
  8012e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8012eb:	31 d2                	xor    %edx,%edx
  8012ed:	f7 f3                	div    %ebx
  8012ef:	89 c1                	mov    %eax,%ecx
  8012f1:	31 d2                	xor    %edx,%edx
  8012f3:	89 f0                	mov    %esi,%eax
  8012f5:	f7 f1                	div    %ecx
  8012f7:	89 c6                	mov    %eax,%esi
  8012f9:	89 e8                	mov    %ebp,%eax
  8012fb:	89 f7                	mov    %esi,%edi
  8012fd:	f7 f1                	div    %ecx
  8012ff:	89 fa                	mov    %edi,%edx
  801301:	83 c4 1c             	add    $0x1c,%esp
  801304:	5b                   	pop    %ebx
  801305:	5e                   	pop    %esi
  801306:	5f                   	pop    %edi
  801307:	5d                   	pop    %ebp
  801308:	c3                   	ret    
  801309:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801310:	89 f9                	mov    %edi,%ecx
  801312:	b8 20 00 00 00       	mov    $0x20,%eax
  801317:	29 f8                	sub    %edi,%eax
  801319:	d3 e2                	shl    %cl,%edx
  80131b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80131f:	89 c1                	mov    %eax,%ecx
  801321:	89 da                	mov    %ebx,%edx
  801323:	d3 ea                	shr    %cl,%edx
  801325:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801329:	09 d1                	or     %edx,%ecx
  80132b:	89 f2                	mov    %esi,%edx
  80132d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801331:	89 f9                	mov    %edi,%ecx
  801333:	d3 e3                	shl    %cl,%ebx
  801335:	89 c1                	mov    %eax,%ecx
  801337:	d3 ea                	shr    %cl,%edx
  801339:	89 f9                	mov    %edi,%ecx
  80133b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80133f:	89 eb                	mov    %ebp,%ebx
  801341:	d3 e6                	shl    %cl,%esi
  801343:	89 c1                	mov    %eax,%ecx
  801345:	d3 eb                	shr    %cl,%ebx
  801347:	09 de                	or     %ebx,%esi
  801349:	89 f0                	mov    %esi,%eax
  80134b:	f7 74 24 08          	divl   0x8(%esp)
  80134f:	89 d6                	mov    %edx,%esi
  801351:	89 c3                	mov    %eax,%ebx
  801353:	f7 64 24 0c          	mull   0xc(%esp)
  801357:	39 d6                	cmp    %edx,%esi
  801359:	72 15                	jb     801370 <__udivdi3+0x100>
  80135b:	89 f9                	mov    %edi,%ecx
  80135d:	d3 e5                	shl    %cl,%ebp
  80135f:	39 c5                	cmp    %eax,%ebp
  801361:	73 04                	jae    801367 <__udivdi3+0xf7>
  801363:	39 d6                	cmp    %edx,%esi
  801365:	74 09                	je     801370 <__udivdi3+0x100>
  801367:	89 d8                	mov    %ebx,%eax
  801369:	31 ff                	xor    %edi,%edi
  80136b:	e9 40 ff ff ff       	jmp    8012b0 <__udivdi3+0x40>
  801370:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801373:	31 ff                	xor    %edi,%edi
  801375:	e9 36 ff ff ff       	jmp    8012b0 <__udivdi3+0x40>
  80137a:	66 90                	xchg   %ax,%ax
  80137c:	66 90                	xchg   %ax,%ax
  80137e:	66 90                	xchg   %ax,%ax

00801380 <__umoddi3>:
  801380:	f3 0f 1e fb          	endbr32 
  801384:	55                   	push   %ebp
  801385:	57                   	push   %edi
  801386:	56                   	push   %esi
  801387:	53                   	push   %ebx
  801388:	83 ec 1c             	sub    $0x1c,%esp
  80138b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80138f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801393:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801397:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80139b:	85 c0                	test   %eax,%eax
  80139d:	75 19                	jne    8013b8 <__umoddi3+0x38>
  80139f:	39 df                	cmp    %ebx,%edi
  8013a1:	76 5d                	jbe    801400 <__umoddi3+0x80>
  8013a3:	89 f0                	mov    %esi,%eax
  8013a5:	89 da                	mov    %ebx,%edx
  8013a7:	f7 f7                	div    %edi
  8013a9:	89 d0                	mov    %edx,%eax
  8013ab:	31 d2                	xor    %edx,%edx
  8013ad:	83 c4 1c             	add    $0x1c,%esp
  8013b0:	5b                   	pop    %ebx
  8013b1:	5e                   	pop    %esi
  8013b2:	5f                   	pop    %edi
  8013b3:	5d                   	pop    %ebp
  8013b4:	c3                   	ret    
  8013b5:	8d 76 00             	lea    0x0(%esi),%esi
  8013b8:	89 f2                	mov    %esi,%edx
  8013ba:	39 d8                	cmp    %ebx,%eax
  8013bc:	76 12                	jbe    8013d0 <__umoddi3+0x50>
  8013be:	89 f0                	mov    %esi,%eax
  8013c0:	89 da                	mov    %ebx,%edx
  8013c2:	83 c4 1c             	add    $0x1c,%esp
  8013c5:	5b                   	pop    %ebx
  8013c6:	5e                   	pop    %esi
  8013c7:	5f                   	pop    %edi
  8013c8:	5d                   	pop    %ebp
  8013c9:	c3                   	ret    
  8013ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013d0:	0f bd e8             	bsr    %eax,%ebp
  8013d3:	83 f5 1f             	xor    $0x1f,%ebp
  8013d6:	75 50                	jne    801428 <__umoddi3+0xa8>
  8013d8:	39 d8                	cmp    %ebx,%eax
  8013da:	0f 82 e0 00 00 00    	jb     8014c0 <__umoddi3+0x140>
  8013e0:	89 d9                	mov    %ebx,%ecx
  8013e2:	39 f7                	cmp    %esi,%edi
  8013e4:	0f 86 d6 00 00 00    	jbe    8014c0 <__umoddi3+0x140>
  8013ea:	89 d0                	mov    %edx,%eax
  8013ec:	89 ca                	mov    %ecx,%edx
  8013ee:	83 c4 1c             	add    $0x1c,%esp
  8013f1:	5b                   	pop    %ebx
  8013f2:	5e                   	pop    %esi
  8013f3:	5f                   	pop    %edi
  8013f4:	5d                   	pop    %ebp
  8013f5:	c3                   	ret    
  8013f6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013fd:	8d 76 00             	lea    0x0(%esi),%esi
  801400:	89 fd                	mov    %edi,%ebp
  801402:	85 ff                	test   %edi,%edi
  801404:	75 0b                	jne    801411 <__umoddi3+0x91>
  801406:	b8 01 00 00 00       	mov    $0x1,%eax
  80140b:	31 d2                	xor    %edx,%edx
  80140d:	f7 f7                	div    %edi
  80140f:	89 c5                	mov    %eax,%ebp
  801411:	89 d8                	mov    %ebx,%eax
  801413:	31 d2                	xor    %edx,%edx
  801415:	f7 f5                	div    %ebp
  801417:	89 f0                	mov    %esi,%eax
  801419:	f7 f5                	div    %ebp
  80141b:	89 d0                	mov    %edx,%eax
  80141d:	31 d2                	xor    %edx,%edx
  80141f:	eb 8c                	jmp    8013ad <__umoddi3+0x2d>
  801421:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801428:	89 e9                	mov    %ebp,%ecx
  80142a:	ba 20 00 00 00       	mov    $0x20,%edx
  80142f:	29 ea                	sub    %ebp,%edx
  801431:	d3 e0                	shl    %cl,%eax
  801433:	89 44 24 08          	mov    %eax,0x8(%esp)
  801437:	89 d1                	mov    %edx,%ecx
  801439:	89 f8                	mov    %edi,%eax
  80143b:	d3 e8                	shr    %cl,%eax
  80143d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801441:	89 54 24 04          	mov    %edx,0x4(%esp)
  801445:	8b 54 24 04          	mov    0x4(%esp),%edx
  801449:	09 c1                	or     %eax,%ecx
  80144b:	89 d8                	mov    %ebx,%eax
  80144d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801451:	89 e9                	mov    %ebp,%ecx
  801453:	d3 e7                	shl    %cl,%edi
  801455:	89 d1                	mov    %edx,%ecx
  801457:	d3 e8                	shr    %cl,%eax
  801459:	89 e9                	mov    %ebp,%ecx
  80145b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80145f:	d3 e3                	shl    %cl,%ebx
  801461:	89 c7                	mov    %eax,%edi
  801463:	89 d1                	mov    %edx,%ecx
  801465:	89 f0                	mov    %esi,%eax
  801467:	d3 e8                	shr    %cl,%eax
  801469:	89 e9                	mov    %ebp,%ecx
  80146b:	89 fa                	mov    %edi,%edx
  80146d:	d3 e6                	shl    %cl,%esi
  80146f:	09 d8                	or     %ebx,%eax
  801471:	f7 74 24 08          	divl   0x8(%esp)
  801475:	89 d1                	mov    %edx,%ecx
  801477:	89 f3                	mov    %esi,%ebx
  801479:	f7 64 24 0c          	mull   0xc(%esp)
  80147d:	89 c6                	mov    %eax,%esi
  80147f:	89 d7                	mov    %edx,%edi
  801481:	39 d1                	cmp    %edx,%ecx
  801483:	72 06                	jb     80148b <__umoddi3+0x10b>
  801485:	75 10                	jne    801497 <__umoddi3+0x117>
  801487:	39 c3                	cmp    %eax,%ebx
  801489:	73 0c                	jae    801497 <__umoddi3+0x117>
  80148b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80148f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801493:	89 d7                	mov    %edx,%edi
  801495:	89 c6                	mov    %eax,%esi
  801497:	89 ca                	mov    %ecx,%edx
  801499:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80149e:	29 f3                	sub    %esi,%ebx
  8014a0:	19 fa                	sbb    %edi,%edx
  8014a2:	89 d0                	mov    %edx,%eax
  8014a4:	d3 e0                	shl    %cl,%eax
  8014a6:	89 e9                	mov    %ebp,%ecx
  8014a8:	d3 eb                	shr    %cl,%ebx
  8014aa:	d3 ea                	shr    %cl,%edx
  8014ac:	09 d8                	or     %ebx,%eax
  8014ae:	83 c4 1c             	add    $0x1c,%esp
  8014b1:	5b                   	pop    %ebx
  8014b2:	5e                   	pop    %esi
  8014b3:	5f                   	pop    %edi
  8014b4:	5d                   	pop    %ebp
  8014b5:	c3                   	ret    
  8014b6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8014bd:	8d 76 00             	lea    0x0(%esi),%esi
  8014c0:	29 fe                	sub    %edi,%esi
  8014c2:	19 c3                	sbb    %eax,%ebx
  8014c4:	89 f2                	mov    %esi,%edx
  8014c6:	89 d9                	mov    %ebx,%ecx
  8014c8:	e9 1d ff ff ff       	jmp    8013ea <__umoddi3+0x6a>
