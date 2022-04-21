
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
  800040:	e8 bf 0e 00 00       	call   800f04 <fork>
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
  800057:	e8 14 10 00 00       	call   801070 <ipc_recv>
  80005c:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  80005e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800061:	e8 72 0b 00 00       	call   800bd8 <sys_getenvid>
  800066:	57                   	push   %edi
  800067:	53                   	push   %ebx
  800068:	50                   	push   %eax
  800069:	68 36 22 80 00       	push   $0x802236
  80006e:	e8 60 01 00 00       	call   8001d3 <cprintf>
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
  800086:	e8 3c 10 00 00       	call   8010c7 <ipc_send>
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
  80009d:	e8 36 0b 00 00       	call   800bd8 <sys_getenvid>
  8000a2:	83 ec 04             	sub    $0x4,%esp
  8000a5:	53                   	push   %ebx
  8000a6:	50                   	push   %eax
  8000a7:	68 20 22 80 00       	push   $0x802220
  8000ac:	e8 22 01 00 00       	call   8001d3 <cprintf>
		ipc_send(who, 0, 0, 0);
  8000b1:	6a 00                	push   $0x0
  8000b3:	6a 00                	push   $0x0
  8000b5:	6a 00                	push   $0x0
  8000b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000ba:	e8 08 10 00 00       	call   8010c7 <ipc_send>
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
  8000d3:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  8000da:	00 00 00 
    envid_t envid = sys_getenvid();
  8000dd:	e8 f6 0a 00 00       	call   800bd8 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  8000e2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000e7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000ea:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000ef:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f4:	85 db                	test   %ebx,%ebx
  8000f6:	7e 07                	jle    8000ff <libmain+0x3b>
		binaryname = argv[0];
  8000f8:	8b 06                	mov    (%esi),%eax
  8000fa:	a3 00 30 80 00       	mov    %eax,0x803000

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
  80011f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800122:	e8 32 12 00 00       	call   801359 <close_all>
	sys_env_destroy(0);
  800127:	83 ec 0c             	sub    $0xc,%esp
  80012a:	6a 00                	push   $0x0
  80012c:	e8 62 0a 00 00       	call   800b93 <sys_env_destroy>
}
  800131:	83 c4 10             	add    $0x10,%esp
  800134:	c9                   	leave  
  800135:	c3                   	ret    

00800136 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800136:	f3 0f 1e fb          	endbr32 
  80013a:	55                   	push   %ebp
  80013b:	89 e5                	mov    %esp,%ebp
  80013d:	53                   	push   %ebx
  80013e:	83 ec 04             	sub    $0x4,%esp
  800141:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800144:	8b 13                	mov    (%ebx),%edx
  800146:	8d 42 01             	lea    0x1(%edx),%eax
  800149:	89 03                	mov    %eax,(%ebx)
  80014b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80014e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800152:	3d ff 00 00 00       	cmp    $0xff,%eax
  800157:	74 09                	je     800162 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800159:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800160:	c9                   	leave  
  800161:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800162:	83 ec 08             	sub    $0x8,%esp
  800165:	68 ff 00 00 00       	push   $0xff
  80016a:	8d 43 08             	lea    0x8(%ebx),%eax
  80016d:	50                   	push   %eax
  80016e:	e8 db 09 00 00       	call   800b4e <sys_cputs>
		b->idx = 0;
  800173:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800179:	83 c4 10             	add    $0x10,%esp
  80017c:	eb db                	jmp    800159 <putch+0x23>

0080017e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80017e:	f3 0f 1e fb          	endbr32 
  800182:	55                   	push   %ebp
  800183:	89 e5                	mov    %esp,%ebp
  800185:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80018b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800192:	00 00 00 
	b.cnt = 0;
  800195:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80019c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80019f:	ff 75 0c             	pushl  0xc(%ebp)
  8001a2:	ff 75 08             	pushl  0x8(%ebp)
  8001a5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ab:	50                   	push   %eax
  8001ac:	68 36 01 80 00       	push   $0x800136
  8001b1:	e8 20 01 00 00       	call   8002d6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b6:	83 c4 08             	add    $0x8,%esp
  8001b9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001bf:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c5:	50                   	push   %eax
  8001c6:	e8 83 09 00 00       	call   800b4e <sys_cputs>

	return b.cnt;
}
  8001cb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d1:	c9                   	leave  
  8001d2:	c3                   	ret    

008001d3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d3:	f3 0f 1e fb          	endbr32 
  8001d7:	55                   	push   %ebp
  8001d8:	89 e5                	mov    %esp,%ebp
  8001da:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001dd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001e0:	50                   	push   %eax
  8001e1:	ff 75 08             	pushl  0x8(%ebp)
  8001e4:	e8 95 ff ff ff       	call   80017e <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e9:	c9                   	leave  
  8001ea:	c3                   	ret    

008001eb <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001eb:	55                   	push   %ebp
  8001ec:	89 e5                	mov    %esp,%ebp
  8001ee:	57                   	push   %edi
  8001ef:	56                   	push   %esi
  8001f0:	53                   	push   %ebx
  8001f1:	83 ec 1c             	sub    $0x1c,%esp
  8001f4:	89 c7                	mov    %eax,%edi
  8001f6:	89 d6                	mov    %edx,%esi
  8001f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001fe:	89 d1                	mov    %edx,%ecx
  800200:	89 c2                	mov    %eax,%edx
  800202:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800205:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800208:	8b 45 10             	mov    0x10(%ebp),%eax
  80020b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80020e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800211:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800218:	39 c2                	cmp    %eax,%edx
  80021a:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80021d:	72 3e                	jb     80025d <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80021f:	83 ec 0c             	sub    $0xc,%esp
  800222:	ff 75 18             	pushl  0x18(%ebp)
  800225:	83 eb 01             	sub    $0x1,%ebx
  800228:	53                   	push   %ebx
  800229:	50                   	push   %eax
  80022a:	83 ec 08             	sub    $0x8,%esp
  80022d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800230:	ff 75 e0             	pushl  -0x20(%ebp)
  800233:	ff 75 dc             	pushl  -0x24(%ebp)
  800236:	ff 75 d8             	pushl  -0x28(%ebp)
  800239:	e8 82 1d 00 00       	call   801fc0 <__udivdi3>
  80023e:	83 c4 18             	add    $0x18,%esp
  800241:	52                   	push   %edx
  800242:	50                   	push   %eax
  800243:	89 f2                	mov    %esi,%edx
  800245:	89 f8                	mov    %edi,%eax
  800247:	e8 9f ff ff ff       	call   8001eb <printnum>
  80024c:	83 c4 20             	add    $0x20,%esp
  80024f:	eb 13                	jmp    800264 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800251:	83 ec 08             	sub    $0x8,%esp
  800254:	56                   	push   %esi
  800255:	ff 75 18             	pushl  0x18(%ebp)
  800258:	ff d7                	call   *%edi
  80025a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80025d:	83 eb 01             	sub    $0x1,%ebx
  800260:	85 db                	test   %ebx,%ebx
  800262:	7f ed                	jg     800251 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800264:	83 ec 08             	sub    $0x8,%esp
  800267:	56                   	push   %esi
  800268:	83 ec 04             	sub    $0x4,%esp
  80026b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026e:	ff 75 e0             	pushl  -0x20(%ebp)
  800271:	ff 75 dc             	pushl  -0x24(%ebp)
  800274:	ff 75 d8             	pushl  -0x28(%ebp)
  800277:	e8 54 1e 00 00       	call   8020d0 <__umoddi3>
  80027c:	83 c4 14             	add    $0x14,%esp
  80027f:	0f be 80 53 22 80 00 	movsbl 0x802253(%eax),%eax
  800286:	50                   	push   %eax
  800287:	ff d7                	call   *%edi
}
  800289:	83 c4 10             	add    $0x10,%esp
  80028c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028f:	5b                   	pop    %ebx
  800290:	5e                   	pop    %esi
  800291:	5f                   	pop    %edi
  800292:	5d                   	pop    %ebp
  800293:	c3                   	ret    

00800294 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800294:	f3 0f 1e fb          	endbr32 
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80029e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002a2:	8b 10                	mov    (%eax),%edx
  8002a4:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a7:	73 0a                	jae    8002b3 <sprintputch+0x1f>
		*b->buf++ = ch;
  8002a9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ac:	89 08                	mov    %ecx,(%eax)
  8002ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b1:	88 02                	mov    %al,(%edx)
}
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    

008002b5 <printfmt>:
{
  8002b5:	f3 0f 1e fb          	endbr32 
  8002b9:	55                   	push   %ebp
  8002ba:	89 e5                	mov    %esp,%ebp
  8002bc:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002bf:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002c2:	50                   	push   %eax
  8002c3:	ff 75 10             	pushl  0x10(%ebp)
  8002c6:	ff 75 0c             	pushl  0xc(%ebp)
  8002c9:	ff 75 08             	pushl  0x8(%ebp)
  8002cc:	e8 05 00 00 00       	call   8002d6 <vprintfmt>
}
  8002d1:	83 c4 10             	add    $0x10,%esp
  8002d4:	c9                   	leave  
  8002d5:	c3                   	ret    

008002d6 <vprintfmt>:
{
  8002d6:	f3 0f 1e fb          	endbr32 
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
  8002dd:	57                   	push   %edi
  8002de:	56                   	push   %esi
  8002df:	53                   	push   %ebx
  8002e0:	83 ec 3c             	sub    $0x3c,%esp
  8002e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8002e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002e9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002ec:	e9 4a 03 00 00       	jmp    80063b <vprintfmt+0x365>
		padc = ' ';
  8002f1:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002f5:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002fc:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800303:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80030a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80030f:	8d 47 01             	lea    0x1(%edi),%eax
  800312:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800315:	0f b6 17             	movzbl (%edi),%edx
  800318:	8d 42 dd             	lea    -0x23(%edx),%eax
  80031b:	3c 55                	cmp    $0x55,%al
  80031d:	0f 87 de 03 00 00    	ja     800701 <vprintfmt+0x42b>
  800323:	0f b6 c0             	movzbl %al,%eax
  800326:	3e ff 24 85 a0 23 80 	notrack jmp *0x8023a0(,%eax,4)
  80032d:	00 
  80032e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800331:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800335:	eb d8                	jmp    80030f <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800337:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80033a:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80033e:	eb cf                	jmp    80030f <vprintfmt+0x39>
  800340:	0f b6 d2             	movzbl %dl,%edx
  800343:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800346:	b8 00 00 00 00       	mov    $0x0,%eax
  80034b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80034e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800351:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800355:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800358:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80035b:	83 f9 09             	cmp    $0x9,%ecx
  80035e:	77 55                	ja     8003b5 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800360:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800363:	eb e9                	jmp    80034e <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800365:	8b 45 14             	mov    0x14(%ebp),%eax
  800368:	8b 00                	mov    (%eax),%eax
  80036a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80036d:	8b 45 14             	mov    0x14(%ebp),%eax
  800370:	8d 40 04             	lea    0x4(%eax),%eax
  800373:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800376:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800379:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80037d:	79 90                	jns    80030f <vprintfmt+0x39>
				width = precision, precision = -1;
  80037f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800382:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800385:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80038c:	eb 81                	jmp    80030f <vprintfmt+0x39>
  80038e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800391:	85 c0                	test   %eax,%eax
  800393:	ba 00 00 00 00       	mov    $0x0,%edx
  800398:	0f 49 d0             	cmovns %eax,%edx
  80039b:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003a1:	e9 69 ff ff ff       	jmp    80030f <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003a9:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003b0:	e9 5a ff ff ff       	jmp    80030f <vprintfmt+0x39>
  8003b5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003bb:	eb bc                	jmp    800379 <vprintfmt+0xa3>
			lflag++;
  8003bd:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003c3:	e9 47 ff ff ff       	jmp    80030f <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cb:	8d 78 04             	lea    0x4(%eax),%edi
  8003ce:	83 ec 08             	sub    $0x8,%esp
  8003d1:	53                   	push   %ebx
  8003d2:	ff 30                	pushl  (%eax)
  8003d4:	ff d6                	call   *%esi
			break;
  8003d6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003d9:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003dc:	e9 57 02 00 00       	jmp    800638 <vprintfmt+0x362>
			err = va_arg(ap, int);
  8003e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e4:	8d 78 04             	lea    0x4(%eax),%edi
  8003e7:	8b 00                	mov    (%eax),%eax
  8003e9:	99                   	cltd   
  8003ea:	31 d0                	xor    %edx,%eax
  8003ec:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ee:	83 f8 0f             	cmp    $0xf,%eax
  8003f1:	7f 23                	jg     800416 <vprintfmt+0x140>
  8003f3:	8b 14 85 00 25 80 00 	mov    0x802500(,%eax,4),%edx
  8003fa:	85 d2                	test   %edx,%edx
  8003fc:	74 18                	je     800416 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8003fe:	52                   	push   %edx
  8003ff:	68 32 27 80 00       	push   $0x802732
  800404:	53                   	push   %ebx
  800405:	56                   	push   %esi
  800406:	e8 aa fe ff ff       	call   8002b5 <printfmt>
  80040b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80040e:	89 7d 14             	mov    %edi,0x14(%ebp)
  800411:	e9 22 02 00 00       	jmp    800638 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  800416:	50                   	push   %eax
  800417:	68 6b 22 80 00       	push   $0x80226b
  80041c:	53                   	push   %ebx
  80041d:	56                   	push   %esi
  80041e:	e8 92 fe ff ff       	call   8002b5 <printfmt>
  800423:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800426:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800429:	e9 0a 02 00 00       	jmp    800638 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  80042e:	8b 45 14             	mov    0x14(%ebp),%eax
  800431:	83 c0 04             	add    $0x4,%eax
  800434:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800437:	8b 45 14             	mov    0x14(%ebp),%eax
  80043a:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80043c:	85 d2                	test   %edx,%edx
  80043e:	b8 64 22 80 00       	mov    $0x802264,%eax
  800443:	0f 45 c2             	cmovne %edx,%eax
  800446:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800449:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80044d:	7e 06                	jle    800455 <vprintfmt+0x17f>
  80044f:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800453:	75 0d                	jne    800462 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800455:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800458:	89 c7                	mov    %eax,%edi
  80045a:	03 45 e0             	add    -0x20(%ebp),%eax
  80045d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800460:	eb 55                	jmp    8004b7 <vprintfmt+0x1e1>
  800462:	83 ec 08             	sub    $0x8,%esp
  800465:	ff 75 d8             	pushl  -0x28(%ebp)
  800468:	ff 75 cc             	pushl  -0x34(%ebp)
  80046b:	e8 45 03 00 00       	call   8007b5 <strnlen>
  800470:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800473:	29 c2                	sub    %eax,%edx
  800475:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800478:	83 c4 10             	add    $0x10,%esp
  80047b:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80047d:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800481:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800484:	85 ff                	test   %edi,%edi
  800486:	7e 11                	jle    800499 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800488:	83 ec 08             	sub    $0x8,%esp
  80048b:	53                   	push   %ebx
  80048c:	ff 75 e0             	pushl  -0x20(%ebp)
  80048f:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800491:	83 ef 01             	sub    $0x1,%edi
  800494:	83 c4 10             	add    $0x10,%esp
  800497:	eb eb                	jmp    800484 <vprintfmt+0x1ae>
  800499:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80049c:	85 d2                	test   %edx,%edx
  80049e:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a3:	0f 49 c2             	cmovns %edx,%eax
  8004a6:	29 c2                	sub    %eax,%edx
  8004a8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004ab:	eb a8                	jmp    800455 <vprintfmt+0x17f>
					putch(ch, putdat);
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	53                   	push   %ebx
  8004b1:	52                   	push   %edx
  8004b2:	ff d6                	call   *%esi
  8004b4:	83 c4 10             	add    $0x10,%esp
  8004b7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ba:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004bc:	83 c7 01             	add    $0x1,%edi
  8004bf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004c3:	0f be d0             	movsbl %al,%edx
  8004c6:	85 d2                	test   %edx,%edx
  8004c8:	74 4b                	je     800515 <vprintfmt+0x23f>
  8004ca:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ce:	78 06                	js     8004d6 <vprintfmt+0x200>
  8004d0:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004d4:	78 1e                	js     8004f4 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004d6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004da:	74 d1                	je     8004ad <vprintfmt+0x1d7>
  8004dc:	0f be c0             	movsbl %al,%eax
  8004df:	83 e8 20             	sub    $0x20,%eax
  8004e2:	83 f8 5e             	cmp    $0x5e,%eax
  8004e5:	76 c6                	jbe    8004ad <vprintfmt+0x1d7>
					putch('?', putdat);
  8004e7:	83 ec 08             	sub    $0x8,%esp
  8004ea:	53                   	push   %ebx
  8004eb:	6a 3f                	push   $0x3f
  8004ed:	ff d6                	call   *%esi
  8004ef:	83 c4 10             	add    $0x10,%esp
  8004f2:	eb c3                	jmp    8004b7 <vprintfmt+0x1e1>
  8004f4:	89 cf                	mov    %ecx,%edi
  8004f6:	eb 0e                	jmp    800506 <vprintfmt+0x230>
				putch(' ', putdat);
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	53                   	push   %ebx
  8004fc:	6a 20                	push   $0x20
  8004fe:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800500:	83 ef 01             	sub    $0x1,%edi
  800503:	83 c4 10             	add    $0x10,%esp
  800506:	85 ff                	test   %edi,%edi
  800508:	7f ee                	jg     8004f8 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80050a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80050d:	89 45 14             	mov    %eax,0x14(%ebp)
  800510:	e9 23 01 00 00       	jmp    800638 <vprintfmt+0x362>
  800515:	89 cf                	mov    %ecx,%edi
  800517:	eb ed                	jmp    800506 <vprintfmt+0x230>
	if (lflag >= 2)
  800519:	83 f9 01             	cmp    $0x1,%ecx
  80051c:	7f 1b                	jg     800539 <vprintfmt+0x263>
	else if (lflag)
  80051e:	85 c9                	test   %ecx,%ecx
  800520:	74 63                	je     800585 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	8b 00                	mov    (%eax),%eax
  800527:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80052a:	99                   	cltd   
  80052b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80052e:	8b 45 14             	mov    0x14(%ebp),%eax
  800531:	8d 40 04             	lea    0x4(%eax),%eax
  800534:	89 45 14             	mov    %eax,0x14(%ebp)
  800537:	eb 17                	jmp    800550 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800539:	8b 45 14             	mov    0x14(%ebp),%eax
  80053c:	8b 50 04             	mov    0x4(%eax),%edx
  80053f:	8b 00                	mov    (%eax),%eax
  800541:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800544:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800547:	8b 45 14             	mov    0x14(%ebp),%eax
  80054a:	8d 40 08             	lea    0x8(%eax),%eax
  80054d:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800550:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800553:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800556:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80055b:	85 c9                	test   %ecx,%ecx
  80055d:	0f 89 bb 00 00 00    	jns    80061e <vprintfmt+0x348>
				putch('-', putdat);
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	53                   	push   %ebx
  800567:	6a 2d                	push   $0x2d
  800569:	ff d6                	call   *%esi
				num = -(long long) num;
  80056b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80056e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800571:	f7 da                	neg    %edx
  800573:	83 d1 00             	adc    $0x0,%ecx
  800576:	f7 d9                	neg    %ecx
  800578:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80057b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800580:	e9 99 00 00 00       	jmp    80061e <vprintfmt+0x348>
		return va_arg(*ap, int);
  800585:	8b 45 14             	mov    0x14(%ebp),%eax
  800588:	8b 00                	mov    (%eax),%eax
  80058a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058d:	99                   	cltd   
  80058e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800591:	8b 45 14             	mov    0x14(%ebp),%eax
  800594:	8d 40 04             	lea    0x4(%eax),%eax
  800597:	89 45 14             	mov    %eax,0x14(%ebp)
  80059a:	eb b4                	jmp    800550 <vprintfmt+0x27a>
	if (lflag >= 2)
  80059c:	83 f9 01             	cmp    $0x1,%ecx
  80059f:	7f 1b                	jg     8005bc <vprintfmt+0x2e6>
	else if (lflag)
  8005a1:	85 c9                	test   %ecx,%ecx
  8005a3:	74 2c                	je     8005d1 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  8005a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a8:	8b 10                	mov    (%eax),%edx
  8005aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005af:	8d 40 04             	lea    0x4(%eax),%eax
  8005b2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005b5:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005ba:	eb 62                	jmp    80061e <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8005bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bf:	8b 10                	mov    (%eax),%edx
  8005c1:	8b 48 04             	mov    0x4(%eax),%ecx
  8005c4:	8d 40 08             	lea    0x8(%eax),%eax
  8005c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ca:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005cf:	eb 4d                	jmp    80061e <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8005d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d4:	8b 10                	mov    (%eax),%edx
  8005d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005db:	8d 40 04             	lea    0x4(%eax),%eax
  8005de:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e1:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8005e6:	eb 36                	jmp    80061e <vprintfmt+0x348>
	if (lflag >= 2)
  8005e8:	83 f9 01             	cmp    $0x1,%ecx
  8005eb:	7f 17                	jg     800604 <vprintfmt+0x32e>
	else if (lflag)
  8005ed:	85 c9                	test   %ecx,%ecx
  8005ef:	74 6e                	je     80065f <vprintfmt+0x389>
		return va_arg(*ap, long);
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8b 10                	mov    (%eax),%edx
  8005f6:	89 d0                	mov    %edx,%eax
  8005f8:	99                   	cltd   
  8005f9:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005fc:	8d 49 04             	lea    0x4(%ecx),%ecx
  8005ff:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800602:	eb 11                	jmp    800615 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8b 50 04             	mov    0x4(%eax),%edx
  80060a:	8b 00                	mov    (%eax),%eax
  80060c:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80060f:	8d 49 08             	lea    0x8(%ecx),%ecx
  800612:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800615:	89 d1                	mov    %edx,%ecx
  800617:	89 c2                	mov    %eax,%edx
            base = 8;
  800619:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  80061e:	83 ec 0c             	sub    $0xc,%esp
  800621:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800625:	57                   	push   %edi
  800626:	ff 75 e0             	pushl  -0x20(%ebp)
  800629:	50                   	push   %eax
  80062a:	51                   	push   %ecx
  80062b:	52                   	push   %edx
  80062c:	89 da                	mov    %ebx,%edx
  80062e:	89 f0                	mov    %esi,%eax
  800630:	e8 b6 fb ff ff       	call   8001eb <printnum>
			break;
  800635:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800638:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80063b:	83 c7 01             	add    $0x1,%edi
  80063e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800642:	83 f8 25             	cmp    $0x25,%eax
  800645:	0f 84 a6 fc ff ff    	je     8002f1 <vprintfmt+0x1b>
			if (ch == '\0')
  80064b:	85 c0                	test   %eax,%eax
  80064d:	0f 84 ce 00 00 00    	je     800721 <vprintfmt+0x44b>
			putch(ch, putdat);
  800653:	83 ec 08             	sub    $0x8,%esp
  800656:	53                   	push   %ebx
  800657:	50                   	push   %eax
  800658:	ff d6                	call   *%esi
  80065a:	83 c4 10             	add    $0x10,%esp
  80065d:	eb dc                	jmp    80063b <vprintfmt+0x365>
		return va_arg(*ap, int);
  80065f:	8b 45 14             	mov    0x14(%ebp),%eax
  800662:	8b 10                	mov    (%eax),%edx
  800664:	89 d0                	mov    %edx,%eax
  800666:	99                   	cltd   
  800667:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80066a:	8d 49 04             	lea    0x4(%ecx),%ecx
  80066d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800670:	eb a3                	jmp    800615 <vprintfmt+0x33f>
			putch('0', putdat);
  800672:	83 ec 08             	sub    $0x8,%esp
  800675:	53                   	push   %ebx
  800676:	6a 30                	push   $0x30
  800678:	ff d6                	call   *%esi
			putch('x', putdat);
  80067a:	83 c4 08             	add    $0x8,%esp
  80067d:	53                   	push   %ebx
  80067e:	6a 78                	push   $0x78
  800680:	ff d6                	call   *%esi
			num = (unsigned long long)
  800682:	8b 45 14             	mov    0x14(%ebp),%eax
  800685:	8b 10                	mov    (%eax),%edx
  800687:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80068c:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80068f:	8d 40 04             	lea    0x4(%eax),%eax
  800692:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800695:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80069a:	eb 82                	jmp    80061e <vprintfmt+0x348>
	if (lflag >= 2)
  80069c:	83 f9 01             	cmp    $0x1,%ecx
  80069f:	7f 1e                	jg     8006bf <vprintfmt+0x3e9>
	else if (lflag)
  8006a1:	85 c9                	test   %ecx,%ecx
  8006a3:	74 32                	je     8006d7 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  8006a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a8:	8b 10                	mov    (%eax),%edx
  8006aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006af:	8d 40 04             	lea    0x4(%eax),%eax
  8006b2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b5:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006ba:	e9 5f ff ff ff       	jmp    80061e <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8006bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c2:	8b 10                	mov    (%eax),%edx
  8006c4:	8b 48 04             	mov    0x4(%eax),%ecx
  8006c7:	8d 40 08             	lea    0x8(%eax),%eax
  8006ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006cd:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006d2:	e9 47 ff ff ff       	jmp    80061e <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8006d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006da:	8b 10                	mov    (%eax),%edx
  8006dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e1:	8d 40 04             	lea    0x4(%eax),%eax
  8006e4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e7:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006ec:	e9 2d ff ff ff       	jmp    80061e <vprintfmt+0x348>
			putch(ch, putdat);
  8006f1:	83 ec 08             	sub    $0x8,%esp
  8006f4:	53                   	push   %ebx
  8006f5:	6a 25                	push   $0x25
  8006f7:	ff d6                	call   *%esi
			break;
  8006f9:	83 c4 10             	add    $0x10,%esp
  8006fc:	e9 37 ff ff ff       	jmp    800638 <vprintfmt+0x362>
			putch('%', putdat);
  800701:	83 ec 08             	sub    $0x8,%esp
  800704:	53                   	push   %ebx
  800705:	6a 25                	push   $0x25
  800707:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800709:	83 c4 10             	add    $0x10,%esp
  80070c:	89 f8                	mov    %edi,%eax
  80070e:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800712:	74 05                	je     800719 <vprintfmt+0x443>
  800714:	83 e8 01             	sub    $0x1,%eax
  800717:	eb f5                	jmp    80070e <vprintfmt+0x438>
  800719:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80071c:	e9 17 ff ff ff       	jmp    800638 <vprintfmt+0x362>
}
  800721:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800724:	5b                   	pop    %ebx
  800725:	5e                   	pop    %esi
  800726:	5f                   	pop    %edi
  800727:	5d                   	pop    %ebp
  800728:	c3                   	ret    

00800729 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800729:	f3 0f 1e fb          	endbr32 
  80072d:	55                   	push   %ebp
  80072e:	89 e5                	mov    %esp,%ebp
  800730:	83 ec 18             	sub    $0x18,%esp
  800733:	8b 45 08             	mov    0x8(%ebp),%eax
  800736:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800739:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80073c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800740:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800743:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80074a:	85 c0                	test   %eax,%eax
  80074c:	74 26                	je     800774 <vsnprintf+0x4b>
  80074e:	85 d2                	test   %edx,%edx
  800750:	7e 22                	jle    800774 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800752:	ff 75 14             	pushl  0x14(%ebp)
  800755:	ff 75 10             	pushl  0x10(%ebp)
  800758:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80075b:	50                   	push   %eax
  80075c:	68 94 02 80 00       	push   $0x800294
  800761:	e8 70 fb ff ff       	call   8002d6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800766:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800769:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80076c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80076f:	83 c4 10             	add    $0x10,%esp
}
  800772:	c9                   	leave  
  800773:	c3                   	ret    
		return -E_INVAL;
  800774:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800779:	eb f7                	jmp    800772 <vsnprintf+0x49>

0080077b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80077b:	f3 0f 1e fb          	endbr32 
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800785:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800788:	50                   	push   %eax
  800789:	ff 75 10             	pushl  0x10(%ebp)
  80078c:	ff 75 0c             	pushl  0xc(%ebp)
  80078f:	ff 75 08             	pushl  0x8(%ebp)
  800792:	e8 92 ff ff ff       	call   800729 <vsnprintf>
	va_end(ap);

	return rc;
}
  800797:	c9                   	leave  
  800798:	c3                   	ret    

00800799 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800799:	f3 0f 1e fb          	endbr32 
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ac:	74 05                	je     8007b3 <strlen+0x1a>
		n++;
  8007ae:	83 c0 01             	add    $0x1,%eax
  8007b1:	eb f5                	jmp    8007a8 <strlen+0xf>
	return n;
}
  8007b3:	5d                   	pop    %ebp
  8007b4:	c3                   	ret    

008007b5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b5:	f3 0f 1e fb          	endbr32 
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007bf:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c7:	39 d0                	cmp    %edx,%eax
  8007c9:	74 0d                	je     8007d8 <strnlen+0x23>
  8007cb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007cf:	74 05                	je     8007d6 <strnlen+0x21>
		n++;
  8007d1:	83 c0 01             	add    $0x1,%eax
  8007d4:	eb f1                	jmp    8007c7 <strnlen+0x12>
  8007d6:	89 c2                	mov    %eax,%edx
	return n;
}
  8007d8:	89 d0                	mov    %edx,%eax
  8007da:	5d                   	pop    %ebp
  8007db:	c3                   	ret    

008007dc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007dc:	f3 0f 1e fb          	endbr32 
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	53                   	push   %ebx
  8007e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ef:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007f3:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007f6:	83 c0 01             	add    $0x1,%eax
  8007f9:	84 d2                	test   %dl,%dl
  8007fb:	75 f2                	jne    8007ef <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8007fd:	89 c8                	mov    %ecx,%eax
  8007ff:	5b                   	pop    %ebx
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    

00800802 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800802:	f3 0f 1e fb          	endbr32 
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	53                   	push   %ebx
  80080a:	83 ec 10             	sub    $0x10,%esp
  80080d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800810:	53                   	push   %ebx
  800811:	e8 83 ff ff ff       	call   800799 <strlen>
  800816:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800819:	ff 75 0c             	pushl  0xc(%ebp)
  80081c:	01 d8                	add    %ebx,%eax
  80081e:	50                   	push   %eax
  80081f:	e8 b8 ff ff ff       	call   8007dc <strcpy>
	return dst;
}
  800824:	89 d8                	mov    %ebx,%eax
  800826:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800829:	c9                   	leave  
  80082a:	c3                   	ret    

0080082b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80082b:	f3 0f 1e fb          	endbr32 
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	56                   	push   %esi
  800833:	53                   	push   %ebx
  800834:	8b 75 08             	mov    0x8(%ebp),%esi
  800837:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083a:	89 f3                	mov    %esi,%ebx
  80083c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80083f:	89 f0                	mov    %esi,%eax
  800841:	39 d8                	cmp    %ebx,%eax
  800843:	74 11                	je     800856 <strncpy+0x2b>
		*dst++ = *src;
  800845:	83 c0 01             	add    $0x1,%eax
  800848:	0f b6 0a             	movzbl (%edx),%ecx
  80084b:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80084e:	80 f9 01             	cmp    $0x1,%cl
  800851:	83 da ff             	sbb    $0xffffffff,%edx
  800854:	eb eb                	jmp    800841 <strncpy+0x16>
	}
	return ret;
}
  800856:	89 f0                	mov    %esi,%eax
  800858:	5b                   	pop    %ebx
  800859:	5e                   	pop    %esi
  80085a:	5d                   	pop    %ebp
  80085b:	c3                   	ret    

0080085c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80085c:	f3 0f 1e fb          	endbr32 
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	56                   	push   %esi
  800864:	53                   	push   %ebx
  800865:	8b 75 08             	mov    0x8(%ebp),%esi
  800868:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086b:	8b 55 10             	mov    0x10(%ebp),%edx
  80086e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800870:	85 d2                	test   %edx,%edx
  800872:	74 21                	je     800895 <strlcpy+0x39>
  800874:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800878:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80087a:	39 c2                	cmp    %eax,%edx
  80087c:	74 14                	je     800892 <strlcpy+0x36>
  80087e:	0f b6 19             	movzbl (%ecx),%ebx
  800881:	84 db                	test   %bl,%bl
  800883:	74 0b                	je     800890 <strlcpy+0x34>
			*dst++ = *src++;
  800885:	83 c1 01             	add    $0x1,%ecx
  800888:	83 c2 01             	add    $0x1,%edx
  80088b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80088e:	eb ea                	jmp    80087a <strlcpy+0x1e>
  800890:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800892:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800895:	29 f0                	sub    %esi,%eax
}
  800897:	5b                   	pop    %ebx
  800898:	5e                   	pop    %esi
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089b:	f3 0f 1e fb          	endbr32 
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a8:	0f b6 01             	movzbl (%ecx),%eax
  8008ab:	84 c0                	test   %al,%al
  8008ad:	74 0c                	je     8008bb <strcmp+0x20>
  8008af:	3a 02                	cmp    (%edx),%al
  8008b1:	75 08                	jne    8008bb <strcmp+0x20>
		p++, q++;
  8008b3:	83 c1 01             	add    $0x1,%ecx
  8008b6:	83 c2 01             	add    $0x1,%edx
  8008b9:	eb ed                	jmp    8008a8 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008bb:	0f b6 c0             	movzbl %al,%eax
  8008be:	0f b6 12             	movzbl (%edx),%edx
  8008c1:	29 d0                	sub    %edx,%eax
}
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c5:	f3 0f 1e fb          	endbr32 
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	53                   	push   %ebx
  8008cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d3:	89 c3                	mov    %eax,%ebx
  8008d5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d8:	eb 06                	jmp    8008e0 <strncmp+0x1b>
		n--, p++, q++;
  8008da:	83 c0 01             	add    $0x1,%eax
  8008dd:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008e0:	39 d8                	cmp    %ebx,%eax
  8008e2:	74 16                	je     8008fa <strncmp+0x35>
  8008e4:	0f b6 08             	movzbl (%eax),%ecx
  8008e7:	84 c9                	test   %cl,%cl
  8008e9:	74 04                	je     8008ef <strncmp+0x2a>
  8008eb:	3a 0a                	cmp    (%edx),%cl
  8008ed:	74 eb                	je     8008da <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ef:	0f b6 00             	movzbl (%eax),%eax
  8008f2:	0f b6 12             	movzbl (%edx),%edx
  8008f5:	29 d0                	sub    %edx,%eax
}
  8008f7:	5b                   	pop    %ebx
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    
		return 0;
  8008fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ff:	eb f6                	jmp    8008f7 <strncmp+0x32>

00800901 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800901:	f3 0f 1e fb          	endbr32 
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	8b 45 08             	mov    0x8(%ebp),%eax
  80090b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80090f:	0f b6 10             	movzbl (%eax),%edx
  800912:	84 d2                	test   %dl,%dl
  800914:	74 09                	je     80091f <strchr+0x1e>
		if (*s == c)
  800916:	38 ca                	cmp    %cl,%dl
  800918:	74 0a                	je     800924 <strchr+0x23>
	for (; *s; s++)
  80091a:	83 c0 01             	add    $0x1,%eax
  80091d:	eb f0                	jmp    80090f <strchr+0xe>
			return (char *) s;
	return 0;
  80091f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800926:	f3 0f 1e fb          	endbr32 
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800934:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800937:	38 ca                	cmp    %cl,%dl
  800939:	74 09                	je     800944 <strfind+0x1e>
  80093b:	84 d2                	test   %dl,%dl
  80093d:	74 05                	je     800944 <strfind+0x1e>
	for (; *s; s++)
  80093f:	83 c0 01             	add    $0x1,%eax
  800942:	eb f0                	jmp    800934 <strfind+0xe>
			break;
	return (char *) s;
}
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800946:	f3 0f 1e fb          	endbr32 
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	57                   	push   %edi
  80094e:	56                   	push   %esi
  80094f:	53                   	push   %ebx
  800950:	8b 7d 08             	mov    0x8(%ebp),%edi
  800953:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800956:	85 c9                	test   %ecx,%ecx
  800958:	74 31                	je     80098b <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80095a:	89 f8                	mov    %edi,%eax
  80095c:	09 c8                	or     %ecx,%eax
  80095e:	a8 03                	test   $0x3,%al
  800960:	75 23                	jne    800985 <memset+0x3f>
		c &= 0xFF;
  800962:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800966:	89 d3                	mov    %edx,%ebx
  800968:	c1 e3 08             	shl    $0x8,%ebx
  80096b:	89 d0                	mov    %edx,%eax
  80096d:	c1 e0 18             	shl    $0x18,%eax
  800970:	89 d6                	mov    %edx,%esi
  800972:	c1 e6 10             	shl    $0x10,%esi
  800975:	09 f0                	or     %esi,%eax
  800977:	09 c2                	or     %eax,%edx
  800979:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80097b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80097e:	89 d0                	mov    %edx,%eax
  800980:	fc                   	cld    
  800981:	f3 ab                	rep stos %eax,%es:(%edi)
  800983:	eb 06                	jmp    80098b <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800985:	8b 45 0c             	mov    0xc(%ebp),%eax
  800988:	fc                   	cld    
  800989:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80098b:	89 f8                	mov    %edi,%eax
  80098d:	5b                   	pop    %ebx
  80098e:	5e                   	pop    %esi
  80098f:	5f                   	pop    %edi
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800992:	f3 0f 1e fb          	endbr32 
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	57                   	push   %edi
  80099a:	56                   	push   %esi
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a4:	39 c6                	cmp    %eax,%esi
  8009a6:	73 32                	jae    8009da <memmove+0x48>
  8009a8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ab:	39 c2                	cmp    %eax,%edx
  8009ad:	76 2b                	jbe    8009da <memmove+0x48>
		s += n;
		d += n;
  8009af:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b2:	89 fe                	mov    %edi,%esi
  8009b4:	09 ce                	or     %ecx,%esi
  8009b6:	09 d6                	or     %edx,%esi
  8009b8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009be:	75 0e                	jne    8009ce <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009c0:	83 ef 04             	sub    $0x4,%edi
  8009c3:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009c9:	fd                   	std    
  8009ca:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009cc:	eb 09                	jmp    8009d7 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009ce:	83 ef 01             	sub    $0x1,%edi
  8009d1:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009d4:	fd                   	std    
  8009d5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009d7:	fc                   	cld    
  8009d8:	eb 1a                	jmp    8009f4 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009da:	89 c2                	mov    %eax,%edx
  8009dc:	09 ca                	or     %ecx,%edx
  8009de:	09 f2                	or     %esi,%edx
  8009e0:	f6 c2 03             	test   $0x3,%dl
  8009e3:	75 0a                	jne    8009ef <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009e5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009e8:	89 c7                	mov    %eax,%edi
  8009ea:	fc                   	cld    
  8009eb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ed:	eb 05                	jmp    8009f4 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8009ef:	89 c7                	mov    %eax,%edi
  8009f1:	fc                   	cld    
  8009f2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f4:	5e                   	pop    %esi
  8009f5:	5f                   	pop    %edi
  8009f6:	5d                   	pop    %ebp
  8009f7:	c3                   	ret    

008009f8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f8:	f3 0f 1e fb          	endbr32 
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a02:	ff 75 10             	pushl  0x10(%ebp)
  800a05:	ff 75 0c             	pushl  0xc(%ebp)
  800a08:	ff 75 08             	pushl  0x8(%ebp)
  800a0b:	e8 82 ff ff ff       	call   800992 <memmove>
}
  800a10:	c9                   	leave  
  800a11:	c3                   	ret    

00800a12 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a12:	f3 0f 1e fb          	endbr32 
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	56                   	push   %esi
  800a1a:	53                   	push   %ebx
  800a1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a21:	89 c6                	mov    %eax,%esi
  800a23:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a26:	39 f0                	cmp    %esi,%eax
  800a28:	74 1c                	je     800a46 <memcmp+0x34>
		if (*s1 != *s2)
  800a2a:	0f b6 08             	movzbl (%eax),%ecx
  800a2d:	0f b6 1a             	movzbl (%edx),%ebx
  800a30:	38 d9                	cmp    %bl,%cl
  800a32:	75 08                	jne    800a3c <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a34:	83 c0 01             	add    $0x1,%eax
  800a37:	83 c2 01             	add    $0x1,%edx
  800a3a:	eb ea                	jmp    800a26 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a3c:	0f b6 c1             	movzbl %cl,%eax
  800a3f:	0f b6 db             	movzbl %bl,%ebx
  800a42:	29 d8                	sub    %ebx,%eax
  800a44:	eb 05                	jmp    800a4b <memcmp+0x39>
	}

	return 0;
  800a46:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4b:	5b                   	pop    %ebx
  800a4c:	5e                   	pop    %esi
  800a4d:	5d                   	pop    %ebp
  800a4e:	c3                   	ret    

00800a4f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a4f:	f3 0f 1e fb          	endbr32 
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
  800a56:	8b 45 08             	mov    0x8(%ebp),%eax
  800a59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a5c:	89 c2                	mov    %eax,%edx
  800a5e:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a61:	39 d0                	cmp    %edx,%eax
  800a63:	73 09                	jae    800a6e <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a65:	38 08                	cmp    %cl,(%eax)
  800a67:	74 05                	je     800a6e <memfind+0x1f>
	for (; s < ends; s++)
  800a69:	83 c0 01             	add    $0x1,%eax
  800a6c:	eb f3                	jmp    800a61 <memfind+0x12>
			break;
	return (void *) s;
}
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a70:	f3 0f 1e fb          	endbr32 
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	57                   	push   %edi
  800a78:	56                   	push   %esi
  800a79:	53                   	push   %ebx
  800a7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a80:	eb 03                	jmp    800a85 <strtol+0x15>
		s++;
  800a82:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a85:	0f b6 01             	movzbl (%ecx),%eax
  800a88:	3c 20                	cmp    $0x20,%al
  800a8a:	74 f6                	je     800a82 <strtol+0x12>
  800a8c:	3c 09                	cmp    $0x9,%al
  800a8e:	74 f2                	je     800a82 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a90:	3c 2b                	cmp    $0x2b,%al
  800a92:	74 2a                	je     800abe <strtol+0x4e>
	int neg = 0;
  800a94:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a99:	3c 2d                	cmp    $0x2d,%al
  800a9b:	74 2b                	je     800ac8 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a9d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aa3:	75 0f                	jne    800ab4 <strtol+0x44>
  800aa5:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa8:	74 28                	je     800ad2 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aaa:	85 db                	test   %ebx,%ebx
  800aac:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ab1:	0f 44 d8             	cmove  %eax,%ebx
  800ab4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800abc:	eb 46                	jmp    800b04 <strtol+0x94>
		s++;
  800abe:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ac1:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac6:	eb d5                	jmp    800a9d <strtol+0x2d>
		s++, neg = 1;
  800ac8:	83 c1 01             	add    $0x1,%ecx
  800acb:	bf 01 00 00 00       	mov    $0x1,%edi
  800ad0:	eb cb                	jmp    800a9d <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ad6:	74 0e                	je     800ae6 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ad8:	85 db                	test   %ebx,%ebx
  800ada:	75 d8                	jne    800ab4 <strtol+0x44>
		s++, base = 8;
  800adc:	83 c1 01             	add    $0x1,%ecx
  800adf:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ae4:	eb ce                	jmp    800ab4 <strtol+0x44>
		s += 2, base = 16;
  800ae6:	83 c1 02             	add    $0x2,%ecx
  800ae9:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aee:	eb c4                	jmp    800ab4 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800af0:	0f be d2             	movsbl %dl,%edx
  800af3:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800af6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800af9:	7d 3a                	jge    800b35 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800afb:	83 c1 01             	add    $0x1,%ecx
  800afe:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b02:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b04:	0f b6 11             	movzbl (%ecx),%edx
  800b07:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b0a:	89 f3                	mov    %esi,%ebx
  800b0c:	80 fb 09             	cmp    $0x9,%bl
  800b0f:	76 df                	jbe    800af0 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b11:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b14:	89 f3                	mov    %esi,%ebx
  800b16:	80 fb 19             	cmp    $0x19,%bl
  800b19:	77 08                	ja     800b23 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b1b:	0f be d2             	movsbl %dl,%edx
  800b1e:	83 ea 57             	sub    $0x57,%edx
  800b21:	eb d3                	jmp    800af6 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b23:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b26:	89 f3                	mov    %esi,%ebx
  800b28:	80 fb 19             	cmp    $0x19,%bl
  800b2b:	77 08                	ja     800b35 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b2d:	0f be d2             	movsbl %dl,%edx
  800b30:	83 ea 37             	sub    $0x37,%edx
  800b33:	eb c1                	jmp    800af6 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b35:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b39:	74 05                	je     800b40 <strtol+0xd0>
		*endptr = (char *) s;
  800b3b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b3e:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b40:	89 c2                	mov    %eax,%edx
  800b42:	f7 da                	neg    %edx
  800b44:	85 ff                	test   %edi,%edi
  800b46:	0f 45 c2             	cmovne %edx,%eax
}
  800b49:	5b                   	pop    %ebx
  800b4a:	5e                   	pop    %esi
  800b4b:	5f                   	pop    %edi
  800b4c:	5d                   	pop    %ebp
  800b4d:	c3                   	ret    

00800b4e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b4e:	f3 0f 1e fb          	endbr32 
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	57                   	push   %edi
  800b56:	56                   	push   %esi
  800b57:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b58:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b63:	89 c3                	mov    %eax,%ebx
  800b65:	89 c7                	mov    %eax,%edi
  800b67:	89 c6                	mov    %eax,%esi
  800b69:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b6b:	5b                   	pop    %ebx
  800b6c:	5e                   	pop    %esi
  800b6d:	5f                   	pop    %edi
  800b6e:	5d                   	pop    %ebp
  800b6f:	c3                   	ret    

00800b70 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b70:	f3 0f 1e fb          	endbr32 
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	57                   	push   %edi
  800b78:	56                   	push   %esi
  800b79:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b84:	89 d1                	mov    %edx,%ecx
  800b86:	89 d3                	mov    %edx,%ebx
  800b88:	89 d7                	mov    %edx,%edi
  800b8a:	89 d6                	mov    %edx,%esi
  800b8c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b8e:	5b                   	pop    %ebx
  800b8f:	5e                   	pop    %esi
  800b90:	5f                   	pop    %edi
  800b91:	5d                   	pop    %ebp
  800b92:	c3                   	ret    

00800b93 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b93:	f3 0f 1e fb          	endbr32 
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	57                   	push   %edi
  800b9b:	56                   	push   %esi
  800b9c:	53                   	push   %ebx
  800b9d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ba0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba8:	b8 03 00 00 00       	mov    $0x3,%eax
  800bad:	89 cb                	mov    %ecx,%ebx
  800baf:	89 cf                	mov    %ecx,%edi
  800bb1:	89 ce                	mov    %ecx,%esi
  800bb3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bb5:	85 c0                	test   %eax,%eax
  800bb7:	7f 08                	jg     800bc1 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbc:	5b                   	pop    %ebx
  800bbd:	5e                   	pop    %esi
  800bbe:	5f                   	pop    %edi
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc1:	83 ec 0c             	sub    $0xc,%esp
  800bc4:	50                   	push   %eax
  800bc5:	6a 03                	push   $0x3
  800bc7:	68 5f 25 80 00       	push   $0x80255f
  800bcc:	6a 23                	push   $0x23
  800bce:	68 7c 25 80 00       	push   $0x80257c
  800bd3:	e8 ab 12 00 00       	call   801e83 <_panic>

00800bd8 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bd8:	f3 0f 1e fb          	endbr32 
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	57                   	push   %edi
  800be0:	56                   	push   %esi
  800be1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800be2:	ba 00 00 00 00       	mov    $0x0,%edx
  800be7:	b8 02 00 00 00       	mov    $0x2,%eax
  800bec:	89 d1                	mov    %edx,%ecx
  800bee:	89 d3                	mov    %edx,%ebx
  800bf0:	89 d7                	mov    %edx,%edi
  800bf2:	89 d6                	mov    %edx,%esi
  800bf4:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bf6:	5b                   	pop    %ebx
  800bf7:	5e                   	pop    %esi
  800bf8:	5f                   	pop    %edi
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <sys_yield>:

void
sys_yield(void)
{
  800bfb:	f3 0f 1e fb          	endbr32 
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	57                   	push   %edi
  800c03:	56                   	push   %esi
  800c04:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c05:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c0f:	89 d1                	mov    %edx,%ecx
  800c11:	89 d3                	mov    %edx,%ebx
  800c13:	89 d7                	mov    %edx,%edi
  800c15:	89 d6                	mov    %edx,%esi
  800c17:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c1e:	f3 0f 1e fb          	endbr32 
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
  800c28:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c2b:	be 00 00 00 00       	mov    $0x0,%esi
  800c30:	8b 55 08             	mov    0x8(%ebp),%edx
  800c33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c36:	b8 04 00 00 00       	mov    $0x4,%eax
  800c3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c3e:	89 f7                	mov    %esi,%edi
  800c40:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c42:	85 c0                	test   %eax,%eax
  800c44:	7f 08                	jg     800c4e <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c49:	5b                   	pop    %ebx
  800c4a:	5e                   	pop    %esi
  800c4b:	5f                   	pop    %edi
  800c4c:	5d                   	pop    %ebp
  800c4d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4e:	83 ec 0c             	sub    $0xc,%esp
  800c51:	50                   	push   %eax
  800c52:	6a 04                	push   $0x4
  800c54:	68 5f 25 80 00       	push   $0x80255f
  800c59:	6a 23                	push   $0x23
  800c5b:	68 7c 25 80 00       	push   $0x80257c
  800c60:	e8 1e 12 00 00       	call   801e83 <_panic>

00800c65 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c65:	f3 0f 1e fb          	endbr32 
  800c69:	55                   	push   %ebp
  800c6a:	89 e5                	mov    %esp,%ebp
  800c6c:	57                   	push   %edi
  800c6d:	56                   	push   %esi
  800c6e:	53                   	push   %ebx
  800c6f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c72:	8b 55 08             	mov    0x8(%ebp),%edx
  800c75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c78:	b8 05 00 00 00       	mov    $0x5,%eax
  800c7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c80:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c83:	8b 75 18             	mov    0x18(%ebp),%esi
  800c86:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c88:	85 c0                	test   %eax,%eax
  800c8a:	7f 08                	jg     800c94 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c94:	83 ec 0c             	sub    $0xc,%esp
  800c97:	50                   	push   %eax
  800c98:	6a 05                	push   $0x5
  800c9a:	68 5f 25 80 00       	push   $0x80255f
  800c9f:	6a 23                	push   $0x23
  800ca1:	68 7c 25 80 00       	push   $0x80257c
  800ca6:	e8 d8 11 00 00       	call   801e83 <_panic>

00800cab <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cab:	f3 0f 1e fb          	endbr32 
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	57                   	push   %edi
  800cb3:	56                   	push   %esi
  800cb4:	53                   	push   %ebx
  800cb5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cb8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc3:	b8 06 00 00 00       	mov    $0x6,%eax
  800cc8:	89 df                	mov    %ebx,%edi
  800cca:	89 de                	mov    %ebx,%esi
  800ccc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cce:	85 c0                	test   %eax,%eax
  800cd0:	7f 08                	jg     800cda <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cda:	83 ec 0c             	sub    $0xc,%esp
  800cdd:	50                   	push   %eax
  800cde:	6a 06                	push   $0x6
  800ce0:	68 5f 25 80 00       	push   $0x80255f
  800ce5:	6a 23                	push   $0x23
  800ce7:	68 7c 25 80 00       	push   $0x80257c
  800cec:	e8 92 11 00 00       	call   801e83 <_panic>

00800cf1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cf1:	f3 0f 1e fb          	endbr32 
  800cf5:	55                   	push   %ebp
  800cf6:	89 e5                	mov    %esp,%ebp
  800cf8:	57                   	push   %edi
  800cf9:	56                   	push   %esi
  800cfa:	53                   	push   %ebx
  800cfb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cfe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d03:	8b 55 08             	mov    0x8(%ebp),%edx
  800d06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d09:	b8 08 00 00 00       	mov    $0x8,%eax
  800d0e:	89 df                	mov    %ebx,%edi
  800d10:	89 de                	mov    %ebx,%esi
  800d12:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d14:	85 c0                	test   %eax,%eax
  800d16:	7f 08                	jg     800d20 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1b:	5b                   	pop    %ebx
  800d1c:	5e                   	pop    %esi
  800d1d:	5f                   	pop    %edi
  800d1e:	5d                   	pop    %ebp
  800d1f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d20:	83 ec 0c             	sub    $0xc,%esp
  800d23:	50                   	push   %eax
  800d24:	6a 08                	push   $0x8
  800d26:	68 5f 25 80 00       	push   $0x80255f
  800d2b:	6a 23                	push   $0x23
  800d2d:	68 7c 25 80 00       	push   $0x80257c
  800d32:	e8 4c 11 00 00       	call   801e83 <_panic>

00800d37 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d37:	f3 0f 1e fb          	endbr32 
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
  800d41:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d44:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d49:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4f:	b8 09 00 00 00       	mov    $0x9,%eax
  800d54:	89 df                	mov    %ebx,%edi
  800d56:	89 de                	mov    %ebx,%esi
  800d58:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d5a:	85 c0                	test   %eax,%eax
  800d5c:	7f 08                	jg     800d66 <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d66:	83 ec 0c             	sub    $0xc,%esp
  800d69:	50                   	push   %eax
  800d6a:	6a 09                	push   $0x9
  800d6c:	68 5f 25 80 00       	push   $0x80255f
  800d71:	6a 23                	push   $0x23
  800d73:	68 7c 25 80 00       	push   $0x80257c
  800d78:	e8 06 11 00 00       	call   801e83 <_panic>

00800d7d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d7d:	f3 0f 1e fb          	endbr32 
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	57                   	push   %edi
  800d85:	56                   	push   %esi
  800d86:	53                   	push   %ebx
  800d87:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d95:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d9a:	89 df                	mov    %ebx,%edi
  800d9c:	89 de                	mov    %ebx,%esi
  800d9e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800da0:	85 c0                	test   %eax,%eax
  800da2:	7f 08                	jg     800dac <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800da4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da7:	5b                   	pop    %ebx
  800da8:	5e                   	pop    %esi
  800da9:	5f                   	pop    %edi
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dac:	83 ec 0c             	sub    $0xc,%esp
  800daf:	50                   	push   %eax
  800db0:	6a 0a                	push   $0xa
  800db2:	68 5f 25 80 00       	push   $0x80255f
  800db7:	6a 23                	push   $0x23
  800db9:	68 7c 25 80 00       	push   $0x80257c
  800dbe:	e8 c0 10 00 00       	call   801e83 <_panic>

00800dc3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dc3:	f3 0f 1e fb          	endbr32 
  800dc7:	55                   	push   %ebp
  800dc8:	89 e5                	mov    %esp,%ebp
  800dca:	57                   	push   %edi
  800dcb:	56                   	push   %esi
  800dcc:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dd8:	be 00 00 00 00       	mov    $0x0,%esi
  800ddd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de3:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800de5:	5b                   	pop    %ebx
  800de6:	5e                   	pop    %esi
  800de7:	5f                   	pop    %edi
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    

00800dea <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dea:	f3 0f 1e fb          	endbr32 
  800dee:	55                   	push   %ebp
  800def:	89 e5                	mov    %esp,%ebp
  800df1:	57                   	push   %edi
  800df2:	56                   	push   %esi
  800df3:	53                   	push   %ebx
  800df4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800df7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dff:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e04:	89 cb                	mov    %ecx,%ebx
  800e06:	89 cf                	mov    %ecx,%edi
  800e08:	89 ce                	mov    %ecx,%esi
  800e0a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e0c:	85 c0                	test   %eax,%eax
  800e0e:	7f 08                	jg     800e18 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e13:	5b                   	pop    %ebx
  800e14:	5e                   	pop    %esi
  800e15:	5f                   	pop    %edi
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e18:	83 ec 0c             	sub    $0xc,%esp
  800e1b:	50                   	push   %eax
  800e1c:	6a 0d                	push   $0xd
  800e1e:	68 5f 25 80 00       	push   $0x80255f
  800e23:	6a 23                	push   $0x23
  800e25:	68 7c 25 80 00       	push   $0x80257c
  800e2a:	e8 54 10 00 00       	call   801e83 <_panic>

00800e2f <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e2f:	f3 0f 1e fb          	endbr32 
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	53                   	push   %ebx
  800e37:	83 ec 04             	sub    $0x4,%esp
  800e3a:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e3d:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if ( !(err & FEC_WR) ||
  800e3f:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e43:	74 75                	je     800eba <pgfault+0x8b>
            !(uvpt[PGNUM(addr)] | PTE_COW) ) {
  800e45:	89 d8                	mov    %ebx,%eax
  800e47:	c1 e8 0c             	shr    $0xc,%eax
  800e4a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, (void *)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0) {
  800e51:	83 ec 04             	sub    $0x4,%esp
  800e54:	6a 07                	push   $0x7
  800e56:	68 00 f0 7f 00       	push   $0x7ff000
  800e5b:	6a 00                	push   $0x0
  800e5d:	e8 bc fd ff ff       	call   800c1e <sys_page_alloc>
  800e62:	83 c4 10             	add    $0x10,%esp
  800e65:	85 c0                	test   %eax,%eax
  800e67:	78 65                	js     800ece <pgfault+0x9f>
        panic("sys_page_alloc failed %e\n", r);
    }
    memmove((void *)PFTEMP, (void *)PTE_ADDR(addr), PGSIZE);
  800e69:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800e6f:	83 ec 04             	sub    $0x4,%esp
  800e72:	68 00 10 00 00       	push   $0x1000
  800e77:	53                   	push   %ebx
  800e78:	68 00 f0 7f 00       	push   $0x7ff000
  800e7d:	e8 10 fb ff ff       	call   800992 <memmove>
    if ((r = sys_page_map(0, (void *)PFTEMP,
  800e82:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e89:	53                   	push   %ebx
  800e8a:	6a 00                	push   $0x0
  800e8c:	68 00 f0 7f 00       	push   $0x7ff000
  800e91:	6a 00                	push   $0x0
  800e93:	e8 cd fd ff ff       	call   800c65 <sys_page_map>
  800e98:	83 c4 20             	add    $0x20,%esp
  800e9b:	85 c0                	test   %eax,%eax
  800e9d:	78 41                	js     800ee0 <pgfault+0xb1>
                0, (void *)PTE_ADDR(addr), PTE_P | PTE_U | PTE_W)) < 0) {
        panic("sys_page_map failed %e\n", r);
    }
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0) {
  800e9f:	83 ec 08             	sub    $0x8,%esp
  800ea2:	68 00 f0 7f 00       	push   $0x7ff000
  800ea7:	6a 00                	push   $0x0
  800ea9:	e8 fd fd ff ff       	call   800cab <sys_page_unmap>
  800eae:	83 c4 10             	add    $0x10,%esp
  800eb1:	85 c0                	test   %eax,%eax
  800eb3:	78 3d                	js     800ef2 <pgfault+0xc3>
        panic("sys_page_unmap failed %e\n", r);
    }

}
  800eb5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eb8:	c9                   	leave  
  800eb9:	c3                   	ret    
        panic("Not a copy-on-write page");
  800eba:	83 ec 04             	sub    $0x4,%esp
  800ebd:	68 8a 25 80 00       	push   $0x80258a
  800ec2:	6a 1e                	push   $0x1e
  800ec4:	68 a3 25 80 00       	push   $0x8025a3
  800ec9:	e8 b5 0f 00 00       	call   801e83 <_panic>
        panic("sys_page_alloc failed %e\n", r);
  800ece:	50                   	push   %eax
  800ecf:	68 ae 25 80 00       	push   $0x8025ae
  800ed4:	6a 2a                	push   $0x2a
  800ed6:	68 a3 25 80 00       	push   $0x8025a3
  800edb:	e8 a3 0f 00 00       	call   801e83 <_panic>
        panic("sys_page_map failed %e\n", r);
  800ee0:	50                   	push   %eax
  800ee1:	68 c8 25 80 00       	push   $0x8025c8
  800ee6:	6a 2f                	push   $0x2f
  800ee8:	68 a3 25 80 00       	push   $0x8025a3
  800eed:	e8 91 0f 00 00       	call   801e83 <_panic>
        panic("sys_page_unmap failed %e\n", r);
  800ef2:	50                   	push   %eax
  800ef3:	68 e0 25 80 00       	push   $0x8025e0
  800ef8:	6a 32                	push   $0x32
  800efa:	68 a3 25 80 00       	push   $0x8025a3
  800eff:	e8 7f 0f 00 00       	call   801e83 <_panic>

00800f04 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f04:	f3 0f 1e fb          	endbr32 
  800f08:	55                   	push   %ebp
  800f09:	89 e5                	mov    %esp,%ebp
  800f0b:	57                   	push   %edi
  800f0c:	56                   	push   %esi
  800f0d:	53                   	push   %ebx
  800f0e:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");

    // 1. set pgfault handler.
    set_pgfault_handler(pgfault);
  800f11:	68 2f 0e 80 00       	push   $0x800e2f
  800f16:	e8 b2 0f 00 00       	call   801ecd <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f1b:	b8 07 00 00 00       	mov    $0x7,%eax
  800f20:	cd 30                	int    $0x30
  800f22:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f25:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    // 2. exofork.
    envid_t envid = sys_exofork();

    if (envid < 0)
  800f28:	83 c4 10             	add    $0x10,%esp
  800f2b:	85 c0                	test   %eax,%eax
  800f2d:	78 2a                	js     800f59 <fork+0x55>
        thisenv = &envs[ENVX(my_envid)];
        return 0;
    }
    else {
        // parent
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800f2f:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (envid == 0) {
  800f34:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800f38:	75 4e                	jne    800f88 <fork+0x84>
        envid_t my_envid = sys_getenvid();
  800f3a:	e8 99 fc ff ff       	call   800bd8 <sys_getenvid>
        thisenv = &envs[ENVX(my_envid)];
  800f3f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f44:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f47:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f4c:	a3 04 40 80 00       	mov    %eax,0x804004
        return 0;
  800f51:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f54:	e9 f1 00 00 00       	jmp    80104a <fork+0x146>
        panic("fork, sys_exofork %e", envid);
  800f59:	50                   	push   %eax
  800f5a:	68 fa 25 80 00       	push   $0x8025fa
  800f5f:	6a 7b                	push   $0x7b
  800f61:	68 a3 25 80 00       	push   $0x8025a3
  800f66:	e8 18 0f 00 00       	call   801e83 <_panic>
        panic("sys_page_map others failed %e\n", r);
  800f6b:	50                   	push   %eax
  800f6c:	68 44 26 80 00       	push   $0x802644
  800f71:	6a 51                	push   $0x51
  800f73:	68 a3 25 80 00       	push   $0x8025a3
  800f78:	e8 06 0f 00 00       	call   801e83 <_panic>
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800f7d:	83 c3 01             	add    $0x1,%ebx
  800f80:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  800f86:	74 7c                	je     801004 <fork+0x100>
  800f88:	89 de                	mov    %ebx,%esi
  800f8a:	c1 e6 0c             	shl    $0xc,%esi
            uintptr_t pgaddr = pn << PGSHIFT;
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800f8d:	89 f0                	mov    %esi,%eax
  800f8f:	c1 e8 16             	shr    $0x16,%eax
  800f92:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f99:	a8 01                	test   $0x1,%al
  800f9b:	74 e0                	je     800f7d <fork+0x79>
                    (uvpt[pn] & PTE_P) ) {
  800f9d:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800fa4:	a8 01                	test   $0x1,%al
  800fa6:	74 d5                	je     800f7d <fork+0x79>
    pte_t pte = uvpt[pn];
  800fa8:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
    if ( (pte & PTE_W) || (pte & PTE_COW) ) {
  800faf:	25 02 08 00 00       	and    $0x802,%eax
        perm |= PTE_COW;
  800fb4:	83 f8 01             	cmp    $0x1,%eax
  800fb7:	19 ff                	sbb    %edi,%edi
  800fb9:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  800fbf:	81 c7 05 08 00 00    	add    $0x805,%edi
    if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0) {
  800fc5:	83 ec 0c             	sub    $0xc,%esp
  800fc8:	57                   	push   %edi
  800fc9:	56                   	push   %esi
  800fca:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fcd:	56                   	push   %esi
  800fce:	6a 00                	push   $0x0
  800fd0:	e8 90 fc ff ff       	call   800c65 <sys_page_map>
  800fd5:	83 c4 20             	add    $0x20,%esp
  800fd8:	85 c0                	test   %eax,%eax
  800fda:	78 8f                	js     800f6b <fork+0x67>
        if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0) {
  800fdc:	83 ec 0c             	sub    $0xc,%esp
  800fdf:	57                   	push   %edi
  800fe0:	56                   	push   %esi
  800fe1:	6a 00                	push   $0x0
  800fe3:	56                   	push   %esi
  800fe4:	6a 00                	push   $0x0
  800fe6:	e8 7a fc ff ff       	call   800c65 <sys_page_map>
  800feb:	83 c4 20             	add    $0x20,%esp
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	79 8b                	jns    800f7d <fork+0x79>
            panic("sys_page_map mine failed %e\n", r);
  800ff2:	50                   	push   %eax
  800ff3:	68 0f 26 80 00       	push   $0x80260f
  800ff8:	6a 56                	push   $0x56
  800ffa:	68 a3 25 80 00       	push   $0x8025a3
  800fff:	e8 7f 0e 00 00       	call   801e83 <_panic>
            }
        }

        int r;

        if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE),
  801004:	83 ec 04             	sub    $0x4,%esp
  801007:	6a 07                	push   $0x7
  801009:	68 00 f0 bf ee       	push   $0xeebff000
  80100e:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801011:	57                   	push   %edi
  801012:	e8 07 fc ff ff       	call   800c1e <sys_page_alloc>
  801017:	83 c4 10             	add    $0x10,%esp
  80101a:	85 c0                	test   %eax,%eax
  80101c:	78 2c                	js     80104a <fork+0x146>
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
  80102b:	e8 4d fd ff ff       	call   800d7d <sys_env_set_pgfault_upcall>
  801030:	83 c4 10             	add    $0x10,%esp
  801033:	85 c0                	test   %eax,%eax
  801035:	78 13                	js     80104a <fork+0x146>
            return r;
        }

        if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  801037:	83 ec 08             	sub    $0x8,%esp
  80103a:	6a 02                	push   $0x2
  80103c:	57                   	push   %edi
  80103d:	e8 af fc ff ff       	call   800cf1 <sys_env_set_status>
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
  80105c:	68 2c 26 80 00       	push   $0x80262c
  801061:	68 a5 00 00 00       	push   $0xa5
  801066:	68 a3 25 80 00       	push   $0x8025a3
  80106b:	e8 13 0e 00 00       	call   801e83 <_panic>

00801070 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801070:	f3 0f 1e fb          	endbr32 
  801074:	55                   	push   %ebp
  801075:	89 e5                	mov    %esp,%ebp
  801077:	56                   	push   %esi
  801078:	53                   	push   %ebx
  801079:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80107c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80107f:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801082:	85 c0                	test   %eax,%eax
  801084:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801089:	0f 44 c2             	cmove  %edx,%eax
  80108c:	83 ec 0c             	sub    $0xc,%esp
  80108f:	50                   	push   %eax
  801090:	e8 55 fd ff ff       	call   800dea <sys_ipc_recv>
  801095:	83 c4 10             	add    $0x10,%esp
  801098:	85 c0                	test   %eax,%eax
  80109a:	78 24                	js     8010c0 <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  80109c:	85 f6                	test   %esi,%esi
  80109e:	74 0a                	je     8010aa <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  8010a0:	a1 04 40 80 00       	mov    0x804004,%eax
  8010a5:	8b 40 78             	mov    0x78(%eax),%eax
  8010a8:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  8010aa:	85 db                	test   %ebx,%ebx
  8010ac:	74 0a                	je     8010b8 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  8010ae:	a1 04 40 80 00       	mov    0x804004,%eax
  8010b3:	8b 40 74             	mov    0x74(%eax),%eax
  8010b6:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  8010b8:	a1 04 40 80 00       	mov    0x804004,%eax
  8010bd:	8b 40 70             	mov    0x70(%eax),%eax
}
  8010c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010c3:	5b                   	pop    %ebx
  8010c4:	5e                   	pop    %esi
  8010c5:	5d                   	pop    %ebp
  8010c6:	c3                   	ret    

008010c7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010c7:	f3 0f 1e fb          	endbr32 
  8010cb:	55                   	push   %ebp
  8010cc:	89 e5                	mov    %esp,%ebp
  8010ce:	57                   	push   %edi
  8010cf:	56                   	push   %esi
  8010d0:	53                   	push   %ebx
  8010d1:	83 ec 1c             	sub    $0x1c,%esp
  8010d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8010d7:	85 c0                	test   %eax,%eax
  8010d9:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8010de:	0f 45 d0             	cmovne %eax,%edx
  8010e1:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  8010e3:	be 01 00 00 00       	mov    $0x1,%esi
  8010e8:	eb 1f                	jmp    801109 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  8010ea:	e8 0c fb ff ff       	call   800bfb <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  8010ef:	83 c3 01             	add    $0x1,%ebx
  8010f2:	39 de                	cmp    %ebx,%esi
  8010f4:	7f f4                	jg     8010ea <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  8010f6:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  8010f8:	83 fe 11             	cmp    $0x11,%esi
  8010fb:	b8 01 00 00 00       	mov    $0x1,%eax
  801100:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801103:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801107:	75 1c                	jne    801125 <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801109:	ff 75 14             	pushl  0x14(%ebp)
  80110c:	57                   	push   %edi
  80110d:	ff 75 0c             	pushl  0xc(%ebp)
  801110:	ff 75 08             	pushl  0x8(%ebp)
  801113:	e8 ab fc ff ff       	call   800dc3 <sys_ipc_try_send>
  801118:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  80111b:	83 c4 10             	add    $0x10,%esp
  80111e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801123:	eb cd                	jmp    8010f2 <ipc_send+0x2b>
}
  801125:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801128:	5b                   	pop    %ebx
  801129:	5e                   	pop    %esi
  80112a:	5f                   	pop    %edi
  80112b:	5d                   	pop    %ebp
  80112c:	c3                   	ret    

0080112d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80112d:	f3 0f 1e fb          	endbr32 
  801131:	55                   	push   %ebp
  801132:	89 e5                	mov    %esp,%ebp
  801134:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801137:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80113c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80113f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801145:	8b 52 50             	mov    0x50(%edx),%edx
  801148:	39 ca                	cmp    %ecx,%edx
  80114a:	74 11                	je     80115d <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  80114c:	83 c0 01             	add    $0x1,%eax
  80114f:	3d 00 04 00 00       	cmp    $0x400,%eax
  801154:	75 e6                	jne    80113c <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801156:	b8 00 00 00 00       	mov    $0x0,%eax
  80115b:	eb 0b                	jmp    801168 <ipc_find_env+0x3b>
			return envs[i].env_id;
  80115d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801160:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801165:	8b 40 48             	mov    0x48(%eax),%eax
}
  801168:	5d                   	pop    %ebp
  801169:	c3                   	ret    

0080116a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80116a:	f3 0f 1e fb          	endbr32 
  80116e:	55                   	push   %ebp
  80116f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801171:	8b 45 08             	mov    0x8(%ebp),%eax
  801174:	05 00 00 00 30       	add    $0x30000000,%eax
  801179:	c1 e8 0c             	shr    $0xc,%eax
}
  80117c:	5d                   	pop    %ebp
  80117d:	c3                   	ret    

0080117e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80117e:	f3 0f 1e fb          	endbr32 
  801182:	55                   	push   %ebp
  801183:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801185:	8b 45 08             	mov    0x8(%ebp),%eax
  801188:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80118d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801192:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801197:	5d                   	pop    %ebp
  801198:	c3                   	ret    

00801199 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801199:	f3 0f 1e fb          	endbr32 
  80119d:	55                   	push   %ebp
  80119e:	89 e5                	mov    %esp,%ebp
  8011a0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011a5:	89 c2                	mov    %eax,%edx
  8011a7:	c1 ea 16             	shr    $0x16,%edx
  8011aa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011b1:	f6 c2 01             	test   $0x1,%dl
  8011b4:	74 2d                	je     8011e3 <fd_alloc+0x4a>
  8011b6:	89 c2                	mov    %eax,%edx
  8011b8:	c1 ea 0c             	shr    $0xc,%edx
  8011bb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011c2:	f6 c2 01             	test   $0x1,%dl
  8011c5:	74 1c                	je     8011e3 <fd_alloc+0x4a>
  8011c7:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8011cc:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011d1:	75 d2                	jne    8011a5 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8011dc:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8011e1:	eb 0a                	jmp    8011ed <fd_alloc+0x54>
			*fd_store = fd;
  8011e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011e6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011ed:	5d                   	pop    %ebp
  8011ee:	c3                   	ret    

008011ef <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011ef:	f3 0f 1e fb          	endbr32 
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011f9:	83 f8 1f             	cmp    $0x1f,%eax
  8011fc:	77 30                	ja     80122e <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011fe:	c1 e0 0c             	shl    $0xc,%eax
  801201:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801206:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80120c:	f6 c2 01             	test   $0x1,%dl
  80120f:	74 24                	je     801235 <fd_lookup+0x46>
  801211:	89 c2                	mov    %eax,%edx
  801213:	c1 ea 0c             	shr    $0xc,%edx
  801216:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80121d:	f6 c2 01             	test   $0x1,%dl
  801220:	74 1a                	je     80123c <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801222:	8b 55 0c             	mov    0xc(%ebp),%edx
  801225:	89 02                	mov    %eax,(%edx)
	return 0;
  801227:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80122c:	5d                   	pop    %ebp
  80122d:	c3                   	ret    
		return -E_INVAL;
  80122e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801233:	eb f7                	jmp    80122c <fd_lookup+0x3d>
		return -E_INVAL;
  801235:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80123a:	eb f0                	jmp    80122c <fd_lookup+0x3d>
  80123c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801241:	eb e9                	jmp    80122c <fd_lookup+0x3d>

00801243 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801243:	f3 0f 1e fb          	endbr32 
  801247:	55                   	push   %ebp
  801248:	89 e5                	mov    %esp,%ebp
  80124a:	83 ec 08             	sub    $0x8,%esp
  80124d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801250:	ba e0 26 80 00       	mov    $0x8026e0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801255:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  80125a:	39 08                	cmp    %ecx,(%eax)
  80125c:	74 33                	je     801291 <dev_lookup+0x4e>
  80125e:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801261:	8b 02                	mov    (%edx),%eax
  801263:	85 c0                	test   %eax,%eax
  801265:	75 f3                	jne    80125a <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801267:	a1 04 40 80 00       	mov    0x804004,%eax
  80126c:	8b 40 48             	mov    0x48(%eax),%eax
  80126f:	83 ec 04             	sub    $0x4,%esp
  801272:	51                   	push   %ecx
  801273:	50                   	push   %eax
  801274:	68 64 26 80 00       	push   $0x802664
  801279:	e8 55 ef ff ff       	call   8001d3 <cprintf>
	*dev = 0;
  80127e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801281:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801287:	83 c4 10             	add    $0x10,%esp
  80128a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80128f:	c9                   	leave  
  801290:	c3                   	ret    
			*dev = devtab[i];
  801291:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801294:	89 01                	mov    %eax,(%ecx)
			return 0;
  801296:	b8 00 00 00 00       	mov    $0x0,%eax
  80129b:	eb f2                	jmp    80128f <dev_lookup+0x4c>

0080129d <fd_close>:
{
  80129d:	f3 0f 1e fb          	endbr32 
  8012a1:	55                   	push   %ebp
  8012a2:	89 e5                	mov    %esp,%ebp
  8012a4:	57                   	push   %edi
  8012a5:	56                   	push   %esi
  8012a6:	53                   	push   %ebx
  8012a7:	83 ec 24             	sub    $0x24,%esp
  8012aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8012ad:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012b0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012b3:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012b4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012ba:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012bd:	50                   	push   %eax
  8012be:	e8 2c ff ff ff       	call   8011ef <fd_lookup>
  8012c3:	89 c3                	mov    %eax,%ebx
  8012c5:	83 c4 10             	add    $0x10,%esp
  8012c8:	85 c0                	test   %eax,%eax
  8012ca:	78 05                	js     8012d1 <fd_close+0x34>
	    || fd != fd2)
  8012cc:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8012cf:	74 16                	je     8012e7 <fd_close+0x4a>
		return (must_exist ? r : 0);
  8012d1:	89 f8                	mov    %edi,%eax
  8012d3:	84 c0                	test   %al,%al
  8012d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8012da:	0f 44 d8             	cmove  %eax,%ebx
}
  8012dd:	89 d8                	mov    %ebx,%eax
  8012df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012e2:	5b                   	pop    %ebx
  8012e3:	5e                   	pop    %esi
  8012e4:	5f                   	pop    %edi
  8012e5:	5d                   	pop    %ebp
  8012e6:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012e7:	83 ec 08             	sub    $0x8,%esp
  8012ea:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8012ed:	50                   	push   %eax
  8012ee:	ff 36                	pushl  (%esi)
  8012f0:	e8 4e ff ff ff       	call   801243 <dev_lookup>
  8012f5:	89 c3                	mov    %eax,%ebx
  8012f7:	83 c4 10             	add    $0x10,%esp
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	78 1a                	js     801318 <fd_close+0x7b>
		if (dev->dev_close)
  8012fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801301:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801304:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801309:	85 c0                	test   %eax,%eax
  80130b:	74 0b                	je     801318 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  80130d:	83 ec 0c             	sub    $0xc,%esp
  801310:	56                   	push   %esi
  801311:	ff d0                	call   *%eax
  801313:	89 c3                	mov    %eax,%ebx
  801315:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801318:	83 ec 08             	sub    $0x8,%esp
  80131b:	56                   	push   %esi
  80131c:	6a 00                	push   $0x0
  80131e:	e8 88 f9 ff ff       	call   800cab <sys_page_unmap>
	return r;
  801323:	83 c4 10             	add    $0x10,%esp
  801326:	eb b5                	jmp    8012dd <fd_close+0x40>

00801328 <close>:

int
close(int fdnum)
{
  801328:	f3 0f 1e fb          	endbr32 
  80132c:	55                   	push   %ebp
  80132d:	89 e5                	mov    %esp,%ebp
  80132f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801332:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801335:	50                   	push   %eax
  801336:	ff 75 08             	pushl  0x8(%ebp)
  801339:	e8 b1 fe ff ff       	call   8011ef <fd_lookup>
  80133e:	83 c4 10             	add    $0x10,%esp
  801341:	85 c0                	test   %eax,%eax
  801343:	79 02                	jns    801347 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801345:	c9                   	leave  
  801346:	c3                   	ret    
		return fd_close(fd, 1);
  801347:	83 ec 08             	sub    $0x8,%esp
  80134a:	6a 01                	push   $0x1
  80134c:	ff 75 f4             	pushl  -0xc(%ebp)
  80134f:	e8 49 ff ff ff       	call   80129d <fd_close>
  801354:	83 c4 10             	add    $0x10,%esp
  801357:	eb ec                	jmp    801345 <close+0x1d>

00801359 <close_all>:

void
close_all(void)
{
  801359:	f3 0f 1e fb          	endbr32 
  80135d:	55                   	push   %ebp
  80135e:	89 e5                	mov    %esp,%ebp
  801360:	53                   	push   %ebx
  801361:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801364:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801369:	83 ec 0c             	sub    $0xc,%esp
  80136c:	53                   	push   %ebx
  80136d:	e8 b6 ff ff ff       	call   801328 <close>
	for (i = 0; i < MAXFD; i++)
  801372:	83 c3 01             	add    $0x1,%ebx
  801375:	83 c4 10             	add    $0x10,%esp
  801378:	83 fb 20             	cmp    $0x20,%ebx
  80137b:	75 ec                	jne    801369 <close_all+0x10>
}
  80137d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801380:	c9                   	leave  
  801381:	c3                   	ret    

00801382 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801382:	f3 0f 1e fb          	endbr32 
  801386:	55                   	push   %ebp
  801387:	89 e5                	mov    %esp,%ebp
  801389:	57                   	push   %edi
  80138a:	56                   	push   %esi
  80138b:	53                   	push   %ebx
  80138c:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80138f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801392:	50                   	push   %eax
  801393:	ff 75 08             	pushl  0x8(%ebp)
  801396:	e8 54 fe ff ff       	call   8011ef <fd_lookup>
  80139b:	89 c3                	mov    %eax,%ebx
  80139d:	83 c4 10             	add    $0x10,%esp
  8013a0:	85 c0                	test   %eax,%eax
  8013a2:	0f 88 81 00 00 00    	js     801429 <dup+0xa7>
		return r;
	close(newfdnum);
  8013a8:	83 ec 0c             	sub    $0xc,%esp
  8013ab:	ff 75 0c             	pushl  0xc(%ebp)
  8013ae:	e8 75 ff ff ff       	call   801328 <close>

	newfd = INDEX2FD(newfdnum);
  8013b3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013b6:	c1 e6 0c             	shl    $0xc,%esi
  8013b9:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8013bf:	83 c4 04             	add    $0x4,%esp
  8013c2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013c5:	e8 b4 fd ff ff       	call   80117e <fd2data>
  8013ca:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8013cc:	89 34 24             	mov    %esi,(%esp)
  8013cf:	e8 aa fd ff ff       	call   80117e <fd2data>
  8013d4:	83 c4 10             	add    $0x10,%esp
  8013d7:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013d9:	89 d8                	mov    %ebx,%eax
  8013db:	c1 e8 16             	shr    $0x16,%eax
  8013de:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013e5:	a8 01                	test   $0x1,%al
  8013e7:	74 11                	je     8013fa <dup+0x78>
  8013e9:	89 d8                	mov    %ebx,%eax
  8013eb:	c1 e8 0c             	shr    $0xc,%eax
  8013ee:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013f5:	f6 c2 01             	test   $0x1,%dl
  8013f8:	75 39                	jne    801433 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013fa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013fd:	89 d0                	mov    %edx,%eax
  8013ff:	c1 e8 0c             	shr    $0xc,%eax
  801402:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801409:	83 ec 0c             	sub    $0xc,%esp
  80140c:	25 07 0e 00 00       	and    $0xe07,%eax
  801411:	50                   	push   %eax
  801412:	56                   	push   %esi
  801413:	6a 00                	push   $0x0
  801415:	52                   	push   %edx
  801416:	6a 00                	push   $0x0
  801418:	e8 48 f8 ff ff       	call   800c65 <sys_page_map>
  80141d:	89 c3                	mov    %eax,%ebx
  80141f:	83 c4 20             	add    $0x20,%esp
  801422:	85 c0                	test   %eax,%eax
  801424:	78 31                	js     801457 <dup+0xd5>
		goto err;

	return newfdnum;
  801426:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801429:	89 d8                	mov    %ebx,%eax
  80142b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80142e:	5b                   	pop    %ebx
  80142f:	5e                   	pop    %esi
  801430:	5f                   	pop    %edi
  801431:	5d                   	pop    %ebp
  801432:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801433:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80143a:	83 ec 0c             	sub    $0xc,%esp
  80143d:	25 07 0e 00 00       	and    $0xe07,%eax
  801442:	50                   	push   %eax
  801443:	57                   	push   %edi
  801444:	6a 00                	push   $0x0
  801446:	53                   	push   %ebx
  801447:	6a 00                	push   $0x0
  801449:	e8 17 f8 ff ff       	call   800c65 <sys_page_map>
  80144e:	89 c3                	mov    %eax,%ebx
  801450:	83 c4 20             	add    $0x20,%esp
  801453:	85 c0                	test   %eax,%eax
  801455:	79 a3                	jns    8013fa <dup+0x78>
	sys_page_unmap(0, newfd);
  801457:	83 ec 08             	sub    $0x8,%esp
  80145a:	56                   	push   %esi
  80145b:	6a 00                	push   $0x0
  80145d:	e8 49 f8 ff ff       	call   800cab <sys_page_unmap>
	sys_page_unmap(0, nva);
  801462:	83 c4 08             	add    $0x8,%esp
  801465:	57                   	push   %edi
  801466:	6a 00                	push   $0x0
  801468:	e8 3e f8 ff ff       	call   800cab <sys_page_unmap>
	return r;
  80146d:	83 c4 10             	add    $0x10,%esp
  801470:	eb b7                	jmp    801429 <dup+0xa7>

00801472 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801472:	f3 0f 1e fb          	endbr32 
  801476:	55                   	push   %ebp
  801477:	89 e5                	mov    %esp,%ebp
  801479:	53                   	push   %ebx
  80147a:	83 ec 1c             	sub    $0x1c,%esp
  80147d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801480:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801483:	50                   	push   %eax
  801484:	53                   	push   %ebx
  801485:	e8 65 fd ff ff       	call   8011ef <fd_lookup>
  80148a:	83 c4 10             	add    $0x10,%esp
  80148d:	85 c0                	test   %eax,%eax
  80148f:	78 3f                	js     8014d0 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801491:	83 ec 08             	sub    $0x8,%esp
  801494:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801497:	50                   	push   %eax
  801498:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80149b:	ff 30                	pushl  (%eax)
  80149d:	e8 a1 fd ff ff       	call   801243 <dev_lookup>
  8014a2:	83 c4 10             	add    $0x10,%esp
  8014a5:	85 c0                	test   %eax,%eax
  8014a7:	78 27                	js     8014d0 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014a9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014ac:	8b 42 08             	mov    0x8(%edx),%eax
  8014af:	83 e0 03             	and    $0x3,%eax
  8014b2:	83 f8 01             	cmp    $0x1,%eax
  8014b5:	74 1e                	je     8014d5 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8014b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ba:	8b 40 08             	mov    0x8(%eax),%eax
  8014bd:	85 c0                	test   %eax,%eax
  8014bf:	74 35                	je     8014f6 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014c1:	83 ec 04             	sub    $0x4,%esp
  8014c4:	ff 75 10             	pushl  0x10(%ebp)
  8014c7:	ff 75 0c             	pushl  0xc(%ebp)
  8014ca:	52                   	push   %edx
  8014cb:	ff d0                	call   *%eax
  8014cd:	83 c4 10             	add    $0x10,%esp
}
  8014d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014d3:	c9                   	leave  
  8014d4:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014d5:	a1 04 40 80 00       	mov    0x804004,%eax
  8014da:	8b 40 48             	mov    0x48(%eax),%eax
  8014dd:	83 ec 04             	sub    $0x4,%esp
  8014e0:	53                   	push   %ebx
  8014e1:	50                   	push   %eax
  8014e2:	68 a5 26 80 00       	push   $0x8026a5
  8014e7:	e8 e7 ec ff ff       	call   8001d3 <cprintf>
		return -E_INVAL;
  8014ec:	83 c4 10             	add    $0x10,%esp
  8014ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014f4:	eb da                	jmp    8014d0 <read+0x5e>
		return -E_NOT_SUPP;
  8014f6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014fb:	eb d3                	jmp    8014d0 <read+0x5e>

008014fd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014fd:	f3 0f 1e fb          	endbr32 
  801501:	55                   	push   %ebp
  801502:	89 e5                	mov    %esp,%ebp
  801504:	57                   	push   %edi
  801505:	56                   	push   %esi
  801506:	53                   	push   %ebx
  801507:	83 ec 0c             	sub    $0xc,%esp
  80150a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80150d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801510:	bb 00 00 00 00       	mov    $0x0,%ebx
  801515:	eb 02                	jmp    801519 <readn+0x1c>
  801517:	01 c3                	add    %eax,%ebx
  801519:	39 f3                	cmp    %esi,%ebx
  80151b:	73 21                	jae    80153e <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80151d:	83 ec 04             	sub    $0x4,%esp
  801520:	89 f0                	mov    %esi,%eax
  801522:	29 d8                	sub    %ebx,%eax
  801524:	50                   	push   %eax
  801525:	89 d8                	mov    %ebx,%eax
  801527:	03 45 0c             	add    0xc(%ebp),%eax
  80152a:	50                   	push   %eax
  80152b:	57                   	push   %edi
  80152c:	e8 41 ff ff ff       	call   801472 <read>
		if (m < 0)
  801531:	83 c4 10             	add    $0x10,%esp
  801534:	85 c0                	test   %eax,%eax
  801536:	78 04                	js     80153c <readn+0x3f>
			return m;
		if (m == 0)
  801538:	75 dd                	jne    801517 <readn+0x1a>
  80153a:	eb 02                	jmp    80153e <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80153c:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80153e:	89 d8                	mov    %ebx,%eax
  801540:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801543:	5b                   	pop    %ebx
  801544:	5e                   	pop    %esi
  801545:	5f                   	pop    %edi
  801546:	5d                   	pop    %ebp
  801547:	c3                   	ret    

00801548 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801548:	f3 0f 1e fb          	endbr32 
  80154c:	55                   	push   %ebp
  80154d:	89 e5                	mov    %esp,%ebp
  80154f:	53                   	push   %ebx
  801550:	83 ec 1c             	sub    $0x1c,%esp
  801553:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801556:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801559:	50                   	push   %eax
  80155a:	53                   	push   %ebx
  80155b:	e8 8f fc ff ff       	call   8011ef <fd_lookup>
  801560:	83 c4 10             	add    $0x10,%esp
  801563:	85 c0                	test   %eax,%eax
  801565:	78 3a                	js     8015a1 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801567:	83 ec 08             	sub    $0x8,%esp
  80156a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80156d:	50                   	push   %eax
  80156e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801571:	ff 30                	pushl  (%eax)
  801573:	e8 cb fc ff ff       	call   801243 <dev_lookup>
  801578:	83 c4 10             	add    $0x10,%esp
  80157b:	85 c0                	test   %eax,%eax
  80157d:	78 22                	js     8015a1 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80157f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801582:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801586:	74 1e                	je     8015a6 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801588:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80158b:	8b 52 0c             	mov    0xc(%edx),%edx
  80158e:	85 d2                	test   %edx,%edx
  801590:	74 35                	je     8015c7 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801592:	83 ec 04             	sub    $0x4,%esp
  801595:	ff 75 10             	pushl  0x10(%ebp)
  801598:	ff 75 0c             	pushl  0xc(%ebp)
  80159b:	50                   	push   %eax
  80159c:	ff d2                	call   *%edx
  80159e:	83 c4 10             	add    $0x10,%esp
}
  8015a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a4:	c9                   	leave  
  8015a5:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8015ab:	8b 40 48             	mov    0x48(%eax),%eax
  8015ae:	83 ec 04             	sub    $0x4,%esp
  8015b1:	53                   	push   %ebx
  8015b2:	50                   	push   %eax
  8015b3:	68 c1 26 80 00       	push   $0x8026c1
  8015b8:	e8 16 ec ff ff       	call   8001d3 <cprintf>
		return -E_INVAL;
  8015bd:	83 c4 10             	add    $0x10,%esp
  8015c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015c5:	eb da                	jmp    8015a1 <write+0x59>
		return -E_NOT_SUPP;
  8015c7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015cc:	eb d3                	jmp    8015a1 <write+0x59>

008015ce <seek>:

int
seek(int fdnum, off_t offset)
{
  8015ce:	f3 0f 1e fb          	endbr32 
  8015d2:	55                   	push   %ebp
  8015d3:	89 e5                	mov    %esp,%ebp
  8015d5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015db:	50                   	push   %eax
  8015dc:	ff 75 08             	pushl  0x8(%ebp)
  8015df:	e8 0b fc ff ff       	call   8011ef <fd_lookup>
  8015e4:	83 c4 10             	add    $0x10,%esp
  8015e7:	85 c0                	test   %eax,%eax
  8015e9:	78 0e                	js     8015f9 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8015eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015f1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015f9:	c9                   	leave  
  8015fa:	c3                   	ret    

008015fb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015fb:	f3 0f 1e fb          	endbr32 
  8015ff:	55                   	push   %ebp
  801600:	89 e5                	mov    %esp,%ebp
  801602:	53                   	push   %ebx
  801603:	83 ec 1c             	sub    $0x1c,%esp
  801606:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801609:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80160c:	50                   	push   %eax
  80160d:	53                   	push   %ebx
  80160e:	e8 dc fb ff ff       	call   8011ef <fd_lookup>
  801613:	83 c4 10             	add    $0x10,%esp
  801616:	85 c0                	test   %eax,%eax
  801618:	78 37                	js     801651 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161a:	83 ec 08             	sub    $0x8,%esp
  80161d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801620:	50                   	push   %eax
  801621:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801624:	ff 30                	pushl  (%eax)
  801626:	e8 18 fc ff ff       	call   801243 <dev_lookup>
  80162b:	83 c4 10             	add    $0x10,%esp
  80162e:	85 c0                	test   %eax,%eax
  801630:	78 1f                	js     801651 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801632:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801635:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801639:	74 1b                	je     801656 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80163b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80163e:	8b 52 18             	mov    0x18(%edx),%edx
  801641:	85 d2                	test   %edx,%edx
  801643:	74 32                	je     801677 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801645:	83 ec 08             	sub    $0x8,%esp
  801648:	ff 75 0c             	pushl  0xc(%ebp)
  80164b:	50                   	push   %eax
  80164c:	ff d2                	call   *%edx
  80164e:	83 c4 10             	add    $0x10,%esp
}
  801651:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801654:	c9                   	leave  
  801655:	c3                   	ret    
			thisenv->env_id, fdnum);
  801656:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80165b:	8b 40 48             	mov    0x48(%eax),%eax
  80165e:	83 ec 04             	sub    $0x4,%esp
  801661:	53                   	push   %ebx
  801662:	50                   	push   %eax
  801663:	68 84 26 80 00       	push   $0x802684
  801668:	e8 66 eb ff ff       	call   8001d3 <cprintf>
		return -E_INVAL;
  80166d:	83 c4 10             	add    $0x10,%esp
  801670:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801675:	eb da                	jmp    801651 <ftruncate+0x56>
		return -E_NOT_SUPP;
  801677:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80167c:	eb d3                	jmp    801651 <ftruncate+0x56>

0080167e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80167e:	f3 0f 1e fb          	endbr32 
  801682:	55                   	push   %ebp
  801683:	89 e5                	mov    %esp,%ebp
  801685:	53                   	push   %ebx
  801686:	83 ec 1c             	sub    $0x1c,%esp
  801689:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80168f:	50                   	push   %eax
  801690:	ff 75 08             	pushl  0x8(%ebp)
  801693:	e8 57 fb ff ff       	call   8011ef <fd_lookup>
  801698:	83 c4 10             	add    $0x10,%esp
  80169b:	85 c0                	test   %eax,%eax
  80169d:	78 4b                	js     8016ea <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169f:	83 ec 08             	sub    $0x8,%esp
  8016a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a5:	50                   	push   %eax
  8016a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a9:	ff 30                	pushl  (%eax)
  8016ab:	e8 93 fb ff ff       	call   801243 <dev_lookup>
  8016b0:	83 c4 10             	add    $0x10,%esp
  8016b3:	85 c0                	test   %eax,%eax
  8016b5:	78 33                	js     8016ea <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8016b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ba:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016be:	74 2f                	je     8016ef <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016c0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016c3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016ca:	00 00 00 
	stat->st_isdir = 0;
  8016cd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016d4:	00 00 00 
	stat->st_dev = dev;
  8016d7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016dd:	83 ec 08             	sub    $0x8,%esp
  8016e0:	53                   	push   %ebx
  8016e1:	ff 75 f0             	pushl  -0x10(%ebp)
  8016e4:	ff 50 14             	call   *0x14(%eax)
  8016e7:	83 c4 10             	add    $0x10,%esp
}
  8016ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ed:	c9                   	leave  
  8016ee:	c3                   	ret    
		return -E_NOT_SUPP;
  8016ef:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016f4:	eb f4                	jmp    8016ea <fstat+0x6c>

008016f6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016f6:	f3 0f 1e fb          	endbr32 
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	56                   	push   %esi
  8016fe:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016ff:	83 ec 08             	sub    $0x8,%esp
  801702:	6a 00                	push   $0x0
  801704:	ff 75 08             	pushl  0x8(%ebp)
  801707:	e8 cf 01 00 00       	call   8018db <open>
  80170c:	89 c3                	mov    %eax,%ebx
  80170e:	83 c4 10             	add    $0x10,%esp
  801711:	85 c0                	test   %eax,%eax
  801713:	78 1b                	js     801730 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801715:	83 ec 08             	sub    $0x8,%esp
  801718:	ff 75 0c             	pushl  0xc(%ebp)
  80171b:	50                   	push   %eax
  80171c:	e8 5d ff ff ff       	call   80167e <fstat>
  801721:	89 c6                	mov    %eax,%esi
	close(fd);
  801723:	89 1c 24             	mov    %ebx,(%esp)
  801726:	e8 fd fb ff ff       	call   801328 <close>
	return r;
  80172b:	83 c4 10             	add    $0x10,%esp
  80172e:	89 f3                	mov    %esi,%ebx
}
  801730:	89 d8                	mov    %ebx,%eax
  801732:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801735:	5b                   	pop    %ebx
  801736:	5e                   	pop    %esi
  801737:	5d                   	pop    %ebp
  801738:	c3                   	ret    

00801739 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801739:	55                   	push   %ebp
  80173a:	89 e5                	mov    %esp,%ebp
  80173c:	56                   	push   %esi
  80173d:	53                   	push   %ebx
  80173e:	89 c6                	mov    %eax,%esi
  801740:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801742:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801749:	74 27                	je     801772 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80174b:	6a 07                	push   $0x7
  80174d:	68 00 50 80 00       	push   $0x805000
  801752:	56                   	push   %esi
  801753:	ff 35 00 40 80 00    	pushl  0x804000
  801759:	e8 69 f9 ff ff       	call   8010c7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80175e:	83 c4 0c             	add    $0xc,%esp
  801761:	6a 00                	push   $0x0
  801763:	53                   	push   %ebx
  801764:	6a 00                	push   $0x0
  801766:	e8 05 f9 ff ff       	call   801070 <ipc_recv>
}
  80176b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80176e:	5b                   	pop    %ebx
  80176f:	5e                   	pop    %esi
  801770:	5d                   	pop    %ebp
  801771:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801772:	83 ec 0c             	sub    $0xc,%esp
  801775:	6a 01                	push   $0x1
  801777:	e8 b1 f9 ff ff       	call   80112d <ipc_find_env>
  80177c:	a3 00 40 80 00       	mov    %eax,0x804000
  801781:	83 c4 10             	add    $0x10,%esp
  801784:	eb c5                	jmp    80174b <fsipc+0x12>

00801786 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801786:	f3 0f 1e fb          	endbr32 
  80178a:	55                   	push   %ebp
  80178b:	89 e5                	mov    %esp,%ebp
  80178d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801790:	8b 45 08             	mov    0x8(%ebp),%eax
  801793:	8b 40 0c             	mov    0xc(%eax),%eax
  801796:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80179b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80179e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a8:	b8 02 00 00 00       	mov    $0x2,%eax
  8017ad:	e8 87 ff ff ff       	call   801739 <fsipc>
}
  8017b2:	c9                   	leave  
  8017b3:	c3                   	ret    

008017b4 <devfile_flush>:
{
  8017b4:	f3 0f 1e fb          	endbr32 
  8017b8:	55                   	push   %ebp
  8017b9:	89 e5                	mov    %esp,%ebp
  8017bb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017be:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c1:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ce:	b8 06 00 00 00       	mov    $0x6,%eax
  8017d3:	e8 61 ff ff ff       	call   801739 <fsipc>
}
  8017d8:	c9                   	leave  
  8017d9:	c3                   	ret    

008017da <devfile_stat>:
{
  8017da:	f3 0f 1e fb          	endbr32 
  8017de:	55                   	push   %ebp
  8017df:	89 e5                	mov    %esp,%ebp
  8017e1:	53                   	push   %ebx
  8017e2:	83 ec 04             	sub    $0x4,%esp
  8017e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017eb:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ee:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f8:	b8 05 00 00 00       	mov    $0x5,%eax
  8017fd:	e8 37 ff ff ff       	call   801739 <fsipc>
  801802:	85 c0                	test   %eax,%eax
  801804:	78 2c                	js     801832 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801806:	83 ec 08             	sub    $0x8,%esp
  801809:	68 00 50 80 00       	push   $0x805000
  80180e:	53                   	push   %ebx
  80180f:	e8 c8 ef ff ff       	call   8007dc <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801814:	a1 80 50 80 00       	mov    0x805080,%eax
  801819:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80181f:	a1 84 50 80 00       	mov    0x805084,%eax
  801824:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80182a:	83 c4 10             	add    $0x10,%esp
  80182d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801832:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801835:	c9                   	leave  
  801836:	c3                   	ret    

00801837 <devfile_write>:
{
  801837:	f3 0f 1e fb          	endbr32 
  80183b:	55                   	push   %ebp
  80183c:	89 e5                	mov    %esp,%ebp
  80183e:	83 ec 0c             	sub    $0xc,%esp
	panic("devfile_write not implemented");
  801841:	68 f0 26 80 00       	push   $0x8026f0
  801846:	68 90 00 00 00       	push   $0x90
  80184b:	68 0e 27 80 00       	push   $0x80270e
  801850:	e8 2e 06 00 00       	call   801e83 <_panic>

00801855 <devfile_read>:
{
  801855:	f3 0f 1e fb          	endbr32 
  801859:	55                   	push   %ebp
  80185a:	89 e5                	mov    %esp,%ebp
  80185c:	56                   	push   %esi
  80185d:	53                   	push   %ebx
  80185e:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801861:	8b 45 08             	mov    0x8(%ebp),%eax
  801864:	8b 40 0c             	mov    0xc(%eax),%eax
  801867:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80186c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801872:	ba 00 00 00 00       	mov    $0x0,%edx
  801877:	b8 03 00 00 00       	mov    $0x3,%eax
  80187c:	e8 b8 fe ff ff       	call   801739 <fsipc>
  801881:	89 c3                	mov    %eax,%ebx
  801883:	85 c0                	test   %eax,%eax
  801885:	78 1f                	js     8018a6 <devfile_read+0x51>
	assert(r <= n);
  801887:	39 f0                	cmp    %esi,%eax
  801889:	77 24                	ja     8018af <devfile_read+0x5a>
	assert(r <= PGSIZE);
  80188b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801890:	7f 33                	jg     8018c5 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801892:	83 ec 04             	sub    $0x4,%esp
  801895:	50                   	push   %eax
  801896:	68 00 50 80 00       	push   $0x805000
  80189b:	ff 75 0c             	pushl  0xc(%ebp)
  80189e:	e8 ef f0 ff ff       	call   800992 <memmove>
	return r;
  8018a3:	83 c4 10             	add    $0x10,%esp
}
  8018a6:	89 d8                	mov    %ebx,%eax
  8018a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ab:	5b                   	pop    %ebx
  8018ac:	5e                   	pop    %esi
  8018ad:	5d                   	pop    %ebp
  8018ae:	c3                   	ret    
	assert(r <= n);
  8018af:	68 19 27 80 00       	push   $0x802719
  8018b4:	68 20 27 80 00       	push   $0x802720
  8018b9:	6a 7c                	push   $0x7c
  8018bb:	68 0e 27 80 00       	push   $0x80270e
  8018c0:	e8 be 05 00 00       	call   801e83 <_panic>
	assert(r <= PGSIZE);
  8018c5:	68 35 27 80 00       	push   $0x802735
  8018ca:	68 20 27 80 00       	push   $0x802720
  8018cf:	6a 7d                	push   $0x7d
  8018d1:	68 0e 27 80 00       	push   $0x80270e
  8018d6:	e8 a8 05 00 00       	call   801e83 <_panic>

008018db <open>:
{
  8018db:	f3 0f 1e fb          	endbr32 
  8018df:	55                   	push   %ebp
  8018e0:	89 e5                	mov    %esp,%ebp
  8018e2:	56                   	push   %esi
  8018e3:	53                   	push   %ebx
  8018e4:	83 ec 1c             	sub    $0x1c,%esp
  8018e7:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8018ea:	56                   	push   %esi
  8018eb:	e8 a9 ee ff ff       	call   800799 <strlen>
  8018f0:	83 c4 10             	add    $0x10,%esp
  8018f3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018f8:	7f 6c                	jg     801966 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  8018fa:	83 ec 0c             	sub    $0xc,%esp
  8018fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801900:	50                   	push   %eax
  801901:	e8 93 f8 ff ff       	call   801199 <fd_alloc>
  801906:	89 c3                	mov    %eax,%ebx
  801908:	83 c4 10             	add    $0x10,%esp
  80190b:	85 c0                	test   %eax,%eax
  80190d:	78 3c                	js     80194b <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  80190f:	83 ec 08             	sub    $0x8,%esp
  801912:	56                   	push   %esi
  801913:	68 00 50 80 00       	push   $0x805000
  801918:	e8 bf ee ff ff       	call   8007dc <strcpy>
	fsipcbuf.open.req_omode = mode;
  80191d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801920:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801925:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801928:	b8 01 00 00 00       	mov    $0x1,%eax
  80192d:	e8 07 fe ff ff       	call   801739 <fsipc>
  801932:	89 c3                	mov    %eax,%ebx
  801934:	83 c4 10             	add    $0x10,%esp
  801937:	85 c0                	test   %eax,%eax
  801939:	78 19                	js     801954 <open+0x79>
	return fd2num(fd);
  80193b:	83 ec 0c             	sub    $0xc,%esp
  80193e:	ff 75 f4             	pushl  -0xc(%ebp)
  801941:	e8 24 f8 ff ff       	call   80116a <fd2num>
  801946:	89 c3                	mov    %eax,%ebx
  801948:	83 c4 10             	add    $0x10,%esp
}
  80194b:	89 d8                	mov    %ebx,%eax
  80194d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801950:	5b                   	pop    %ebx
  801951:	5e                   	pop    %esi
  801952:	5d                   	pop    %ebp
  801953:	c3                   	ret    
		fd_close(fd, 0);
  801954:	83 ec 08             	sub    $0x8,%esp
  801957:	6a 00                	push   $0x0
  801959:	ff 75 f4             	pushl  -0xc(%ebp)
  80195c:	e8 3c f9 ff ff       	call   80129d <fd_close>
		return r;
  801961:	83 c4 10             	add    $0x10,%esp
  801964:	eb e5                	jmp    80194b <open+0x70>
		return -E_BAD_PATH;
  801966:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80196b:	eb de                	jmp    80194b <open+0x70>

0080196d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80196d:	f3 0f 1e fb          	endbr32 
  801971:	55                   	push   %ebp
  801972:	89 e5                	mov    %esp,%ebp
  801974:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801977:	ba 00 00 00 00       	mov    $0x0,%edx
  80197c:	b8 08 00 00 00       	mov    $0x8,%eax
  801981:	e8 b3 fd ff ff       	call   801739 <fsipc>
}
  801986:	c9                   	leave  
  801987:	c3                   	ret    

00801988 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801988:	f3 0f 1e fb          	endbr32 
  80198c:	55                   	push   %ebp
  80198d:	89 e5                	mov    %esp,%ebp
  80198f:	56                   	push   %esi
  801990:	53                   	push   %ebx
  801991:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801994:	83 ec 0c             	sub    $0xc,%esp
  801997:	ff 75 08             	pushl  0x8(%ebp)
  80199a:	e8 df f7 ff ff       	call   80117e <fd2data>
  80199f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019a1:	83 c4 08             	add    $0x8,%esp
  8019a4:	68 41 27 80 00       	push   $0x802741
  8019a9:	53                   	push   %ebx
  8019aa:	e8 2d ee ff ff       	call   8007dc <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019af:	8b 46 04             	mov    0x4(%esi),%eax
  8019b2:	2b 06                	sub    (%esi),%eax
  8019b4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019ba:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019c1:	00 00 00 
	stat->st_dev = &devpipe;
  8019c4:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019cb:	30 80 00 
	return 0;
}
  8019ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8019d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d6:	5b                   	pop    %ebx
  8019d7:	5e                   	pop    %esi
  8019d8:	5d                   	pop    %ebp
  8019d9:	c3                   	ret    

008019da <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019da:	f3 0f 1e fb          	endbr32 
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	53                   	push   %ebx
  8019e2:	83 ec 0c             	sub    $0xc,%esp
  8019e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019e8:	53                   	push   %ebx
  8019e9:	6a 00                	push   $0x0
  8019eb:	e8 bb f2 ff ff       	call   800cab <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019f0:	89 1c 24             	mov    %ebx,(%esp)
  8019f3:	e8 86 f7 ff ff       	call   80117e <fd2data>
  8019f8:	83 c4 08             	add    $0x8,%esp
  8019fb:	50                   	push   %eax
  8019fc:	6a 00                	push   $0x0
  8019fe:	e8 a8 f2 ff ff       	call   800cab <sys_page_unmap>
}
  801a03:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a06:	c9                   	leave  
  801a07:	c3                   	ret    

00801a08 <_pipeisclosed>:
{
  801a08:	55                   	push   %ebp
  801a09:	89 e5                	mov    %esp,%ebp
  801a0b:	57                   	push   %edi
  801a0c:	56                   	push   %esi
  801a0d:	53                   	push   %ebx
  801a0e:	83 ec 1c             	sub    $0x1c,%esp
  801a11:	89 c7                	mov    %eax,%edi
  801a13:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801a15:	a1 04 40 80 00       	mov    0x804004,%eax
  801a1a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a1d:	83 ec 0c             	sub    $0xc,%esp
  801a20:	57                   	push   %edi
  801a21:	e8 4d 05 00 00       	call   801f73 <pageref>
  801a26:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a29:	89 34 24             	mov    %esi,(%esp)
  801a2c:	e8 42 05 00 00       	call   801f73 <pageref>
		nn = thisenv->env_runs;
  801a31:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a37:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a3a:	83 c4 10             	add    $0x10,%esp
  801a3d:	39 cb                	cmp    %ecx,%ebx
  801a3f:	74 1b                	je     801a5c <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801a41:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a44:	75 cf                	jne    801a15 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a46:	8b 42 58             	mov    0x58(%edx),%eax
  801a49:	6a 01                	push   $0x1
  801a4b:	50                   	push   %eax
  801a4c:	53                   	push   %ebx
  801a4d:	68 48 27 80 00       	push   $0x802748
  801a52:	e8 7c e7 ff ff       	call   8001d3 <cprintf>
  801a57:	83 c4 10             	add    $0x10,%esp
  801a5a:	eb b9                	jmp    801a15 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801a5c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a5f:	0f 94 c0             	sete   %al
  801a62:	0f b6 c0             	movzbl %al,%eax
}
  801a65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a68:	5b                   	pop    %ebx
  801a69:	5e                   	pop    %esi
  801a6a:	5f                   	pop    %edi
  801a6b:	5d                   	pop    %ebp
  801a6c:	c3                   	ret    

00801a6d <devpipe_write>:
{
  801a6d:	f3 0f 1e fb          	endbr32 
  801a71:	55                   	push   %ebp
  801a72:	89 e5                	mov    %esp,%ebp
  801a74:	57                   	push   %edi
  801a75:	56                   	push   %esi
  801a76:	53                   	push   %ebx
  801a77:	83 ec 28             	sub    $0x28,%esp
  801a7a:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801a7d:	56                   	push   %esi
  801a7e:	e8 fb f6 ff ff       	call   80117e <fd2data>
  801a83:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801a85:	83 c4 10             	add    $0x10,%esp
  801a88:	bf 00 00 00 00       	mov    $0x0,%edi
  801a8d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a90:	74 4f                	je     801ae1 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a92:	8b 43 04             	mov    0x4(%ebx),%eax
  801a95:	8b 0b                	mov    (%ebx),%ecx
  801a97:	8d 51 20             	lea    0x20(%ecx),%edx
  801a9a:	39 d0                	cmp    %edx,%eax
  801a9c:	72 14                	jb     801ab2 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801a9e:	89 da                	mov    %ebx,%edx
  801aa0:	89 f0                	mov    %esi,%eax
  801aa2:	e8 61 ff ff ff       	call   801a08 <_pipeisclosed>
  801aa7:	85 c0                	test   %eax,%eax
  801aa9:	75 3b                	jne    801ae6 <devpipe_write+0x79>
			sys_yield();
  801aab:	e8 4b f1 ff ff       	call   800bfb <sys_yield>
  801ab0:	eb e0                	jmp    801a92 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ab2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ab5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ab9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801abc:	89 c2                	mov    %eax,%edx
  801abe:	c1 fa 1f             	sar    $0x1f,%edx
  801ac1:	89 d1                	mov    %edx,%ecx
  801ac3:	c1 e9 1b             	shr    $0x1b,%ecx
  801ac6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ac9:	83 e2 1f             	and    $0x1f,%edx
  801acc:	29 ca                	sub    %ecx,%edx
  801ace:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ad2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ad6:	83 c0 01             	add    $0x1,%eax
  801ad9:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801adc:	83 c7 01             	add    $0x1,%edi
  801adf:	eb ac                	jmp    801a8d <devpipe_write+0x20>
	return i;
  801ae1:	8b 45 10             	mov    0x10(%ebp),%eax
  801ae4:	eb 05                	jmp    801aeb <devpipe_write+0x7e>
				return 0;
  801ae6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801aeb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aee:	5b                   	pop    %ebx
  801aef:	5e                   	pop    %esi
  801af0:	5f                   	pop    %edi
  801af1:	5d                   	pop    %ebp
  801af2:	c3                   	ret    

00801af3 <devpipe_read>:
{
  801af3:	f3 0f 1e fb          	endbr32 
  801af7:	55                   	push   %ebp
  801af8:	89 e5                	mov    %esp,%ebp
  801afa:	57                   	push   %edi
  801afb:	56                   	push   %esi
  801afc:	53                   	push   %ebx
  801afd:	83 ec 18             	sub    $0x18,%esp
  801b00:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801b03:	57                   	push   %edi
  801b04:	e8 75 f6 ff ff       	call   80117e <fd2data>
  801b09:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b0b:	83 c4 10             	add    $0x10,%esp
  801b0e:	be 00 00 00 00       	mov    $0x0,%esi
  801b13:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b16:	75 14                	jne    801b2c <devpipe_read+0x39>
	return i;
  801b18:	8b 45 10             	mov    0x10(%ebp),%eax
  801b1b:	eb 02                	jmp    801b1f <devpipe_read+0x2c>
				return i;
  801b1d:	89 f0                	mov    %esi,%eax
}
  801b1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b22:	5b                   	pop    %ebx
  801b23:	5e                   	pop    %esi
  801b24:	5f                   	pop    %edi
  801b25:	5d                   	pop    %ebp
  801b26:	c3                   	ret    
			sys_yield();
  801b27:	e8 cf f0 ff ff       	call   800bfb <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801b2c:	8b 03                	mov    (%ebx),%eax
  801b2e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b31:	75 18                	jne    801b4b <devpipe_read+0x58>
			if (i > 0)
  801b33:	85 f6                	test   %esi,%esi
  801b35:	75 e6                	jne    801b1d <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801b37:	89 da                	mov    %ebx,%edx
  801b39:	89 f8                	mov    %edi,%eax
  801b3b:	e8 c8 fe ff ff       	call   801a08 <_pipeisclosed>
  801b40:	85 c0                	test   %eax,%eax
  801b42:	74 e3                	je     801b27 <devpipe_read+0x34>
				return 0;
  801b44:	b8 00 00 00 00       	mov    $0x0,%eax
  801b49:	eb d4                	jmp    801b1f <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b4b:	99                   	cltd   
  801b4c:	c1 ea 1b             	shr    $0x1b,%edx
  801b4f:	01 d0                	add    %edx,%eax
  801b51:	83 e0 1f             	and    $0x1f,%eax
  801b54:	29 d0                	sub    %edx,%eax
  801b56:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801b5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b5e:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801b61:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801b64:	83 c6 01             	add    $0x1,%esi
  801b67:	eb aa                	jmp    801b13 <devpipe_read+0x20>

00801b69 <pipe>:
{
  801b69:	f3 0f 1e fb          	endbr32 
  801b6d:	55                   	push   %ebp
  801b6e:	89 e5                	mov    %esp,%ebp
  801b70:	56                   	push   %esi
  801b71:	53                   	push   %ebx
  801b72:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801b75:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b78:	50                   	push   %eax
  801b79:	e8 1b f6 ff ff       	call   801199 <fd_alloc>
  801b7e:	89 c3                	mov    %eax,%ebx
  801b80:	83 c4 10             	add    $0x10,%esp
  801b83:	85 c0                	test   %eax,%eax
  801b85:	0f 88 23 01 00 00    	js     801cae <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b8b:	83 ec 04             	sub    $0x4,%esp
  801b8e:	68 07 04 00 00       	push   $0x407
  801b93:	ff 75 f4             	pushl  -0xc(%ebp)
  801b96:	6a 00                	push   $0x0
  801b98:	e8 81 f0 ff ff       	call   800c1e <sys_page_alloc>
  801b9d:	89 c3                	mov    %eax,%ebx
  801b9f:	83 c4 10             	add    $0x10,%esp
  801ba2:	85 c0                	test   %eax,%eax
  801ba4:	0f 88 04 01 00 00    	js     801cae <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801baa:	83 ec 0c             	sub    $0xc,%esp
  801bad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bb0:	50                   	push   %eax
  801bb1:	e8 e3 f5 ff ff       	call   801199 <fd_alloc>
  801bb6:	89 c3                	mov    %eax,%ebx
  801bb8:	83 c4 10             	add    $0x10,%esp
  801bbb:	85 c0                	test   %eax,%eax
  801bbd:	0f 88 db 00 00 00    	js     801c9e <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc3:	83 ec 04             	sub    $0x4,%esp
  801bc6:	68 07 04 00 00       	push   $0x407
  801bcb:	ff 75 f0             	pushl  -0x10(%ebp)
  801bce:	6a 00                	push   $0x0
  801bd0:	e8 49 f0 ff ff       	call   800c1e <sys_page_alloc>
  801bd5:	89 c3                	mov    %eax,%ebx
  801bd7:	83 c4 10             	add    $0x10,%esp
  801bda:	85 c0                	test   %eax,%eax
  801bdc:	0f 88 bc 00 00 00    	js     801c9e <pipe+0x135>
	va = fd2data(fd0);
  801be2:	83 ec 0c             	sub    $0xc,%esp
  801be5:	ff 75 f4             	pushl  -0xc(%ebp)
  801be8:	e8 91 f5 ff ff       	call   80117e <fd2data>
  801bed:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bef:	83 c4 0c             	add    $0xc,%esp
  801bf2:	68 07 04 00 00       	push   $0x407
  801bf7:	50                   	push   %eax
  801bf8:	6a 00                	push   $0x0
  801bfa:	e8 1f f0 ff ff       	call   800c1e <sys_page_alloc>
  801bff:	89 c3                	mov    %eax,%ebx
  801c01:	83 c4 10             	add    $0x10,%esp
  801c04:	85 c0                	test   %eax,%eax
  801c06:	0f 88 82 00 00 00    	js     801c8e <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c0c:	83 ec 0c             	sub    $0xc,%esp
  801c0f:	ff 75 f0             	pushl  -0x10(%ebp)
  801c12:	e8 67 f5 ff ff       	call   80117e <fd2data>
  801c17:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c1e:	50                   	push   %eax
  801c1f:	6a 00                	push   $0x0
  801c21:	56                   	push   %esi
  801c22:	6a 00                	push   $0x0
  801c24:	e8 3c f0 ff ff       	call   800c65 <sys_page_map>
  801c29:	89 c3                	mov    %eax,%ebx
  801c2b:	83 c4 20             	add    $0x20,%esp
  801c2e:	85 c0                	test   %eax,%eax
  801c30:	78 4e                	js     801c80 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801c32:	a1 20 30 80 00       	mov    0x803020,%eax
  801c37:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c3a:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801c3c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c3f:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801c46:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c49:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801c4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c4e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801c55:	83 ec 0c             	sub    $0xc,%esp
  801c58:	ff 75 f4             	pushl  -0xc(%ebp)
  801c5b:	e8 0a f5 ff ff       	call   80116a <fd2num>
  801c60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c63:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c65:	83 c4 04             	add    $0x4,%esp
  801c68:	ff 75 f0             	pushl  -0x10(%ebp)
  801c6b:	e8 fa f4 ff ff       	call   80116a <fd2num>
  801c70:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c73:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c76:	83 c4 10             	add    $0x10,%esp
  801c79:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c7e:	eb 2e                	jmp    801cae <pipe+0x145>
	sys_page_unmap(0, va);
  801c80:	83 ec 08             	sub    $0x8,%esp
  801c83:	56                   	push   %esi
  801c84:	6a 00                	push   $0x0
  801c86:	e8 20 f0 ff ff       	call   800cab <sys_page_unmap>
  801c8b:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801c8e:	83 ec 08             	sub    $0x8,%esp
  801c91:	ff 75 f0             	pushl  -0x10(%ebp)
  801c94:	6a 00                	push   $0x0
  801c96:	e8 10 f0 ff ff       	call   800cab <sys_page_unmap>
  801c9b:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801c9e:	83 ec 08             	sub    $0x8,%esp
  801ca1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca4:	6a 00                	push   $0x0
  801ca6:	e8 00 f0 ff ff       	call   800cab <sys_page_unmap>
  801cab:	83 c4 10             	add    $0x10,%esp
}
  801cae:	89 d8                	mov    %ebx,%eax
  801cb0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cb3:	5b                   	pop    %ebx
  801cb4:	5e                   	pop    %esi
  801cb5:	5d                   	pop    %ebp
  801cb6:	c3                   	ret    

00801cb7 <pipeisclosed>:
{
  801cb7:	f3 0f 1e fb          	endbr32 
  801cbb:	55                   	push   %ebp
  801cbc:	89 e5                	mov    %esp,%ebp
  801cbe:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cc1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cc4:	50                   	push   %eax
  801cc5:	ff 75 08             	pushl  0x8(%ebp)
  801cc8:	e8 22 f5 ff ff       	call   8011ef <fd_lookup>
  801ccd:	83 c4 10             	add    $0x10,%esp
  801cd0:	85 c0                	test   %eax,%eax
  801cd2:	78 18                	js     801cec <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801cd4:	83 ec 0c             	sub    $0xc,%esp
  801cd7:	ff 75 f4             	pushl  -0xc(%ebp)
  801cda:	e8 9f f4 ff ff       	call   80117e <fd2data>
  801cdf:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801ce1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce4:	e8 1f fd ff ff       	call   801a08 <_pipeisclosed>
  801ce9:	83 c4 10             	add    $0x10,%esp
}
  801cec:	c9                   	leave  
  801ced:	c3                   	ret    

00801cee <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cee:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801cf2:	b8 00 00 00 00       	mov    $0x0,%eax
  801cf7:	c3                   	ret    

00801cf8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cf8:	f3 0f 1e fb          	endbr32 
  801cfc:	55                   	push   %ebp
  801cfd:	89 e5                	mov    %esp,%ebp
  801cff:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d02:	68 60 27 80 00       	push   $0x802760
  801d07:	ff 75 0c             	pushl  0xc(%ebp)
  801d0a:	e8 cd ea ff ff       	call   8007dc <strcpy>
	return 0;
}
  801d0f:	b8 00 00 00 00       	mov    $0x0,%eax
  801d14:	c9                   	leave  
  801d15:	c3                   	ret    

00801d16 <devcons_write>:
{
  801d16:	f3 0f 1e fb          	endbr32 
  801d1a:	55                   	push   %ebp
  801d1b:	89 e5                	mov    %esp,%ebp
  801d1d:	57                   	push   %edi
  801d1e:	56                   	push   %esi
  801d1f:	53                   	push   %ebx
  801d20:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801d26:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801d2b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801d31:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d34:	73 31                	jae    801d67 <devcons_write+0x51>
		m = n - tot;
  801d36:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d39:	29 f3                	sub    %esi,%ebx
  801d3b:	83 fb 7f             	cmp    $0x7f,%ebx
  801d3e:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801d43:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d46:	83 ec 04             	sub    $0x4,%esp
  801d49:	53                   	push   %ebx
  801d4a:	89 f0                	mov    %esi,%eax
  801d4c:	03 45 0c             	add    0xc(%ebp),%eax
  801d4f:	50                   	push   %eax
  801d50:	57                   	push   %edi
  801d51:	e8 3c ec ff ff       	call   800992 <memmove>
		sys_cputs(buf, m);
  801d56:	83 c4 08             	add    $0x8,%esp
  801d59:	53                   	push   %ebx
  801d5a:	57                   	push   %edi
  801d5b:	e8 ee ed ff ff       	call   800b4e <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801d60:	01 de                	add    %ebx,%esi
  801d62:	83 c4 10             	add    $0x10,%esp
  801d65:	eb ca                	jmp    801d31 <devcons_write+0x1b>
}
  801d67:	89 f0                	mov    %esi,%eax
  801d69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d6c:	5b                   	pop    %ebx
  801d6d:	5e                   	pop    %esi
  801d6e:	5f                   	pop    %edi
  801d6f:	5d                   	pop    %ebp
  801d70:	c3                   	ret    

00801d71 <devcons_read>:
{
  801d71:	f3 0f 1e fb          	endbr32 
  801d75:	55                   	push   %ebp
  801d76:	89 e5                	mov    %esp,%ebp
  801d78:	83 ec 08             	sub    $0x8,%esp
  801d7b:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801d80:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d84:	74 21                	je     801da7 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801d86:	e8 e5 ed ff ff       	call   800b70 <sys_cgetc>
  801d8b:	85 c0                	test   %eax,%eax
  801d8d:	75 07                	jne    801d96 <devcons_read+0x25>
		sys_yield();
  801d8f:	e8 67 ee ff ff       	call   800bfb <sys_yield>
  801d94:	eb f0                	jmp    801d86 <devcons_read+0x15>
	if (c < 0)
  801d96:	78 0f                	js     801da7 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801d98:	83 f8 04             	cmp    $0x4,%eax
  801d9b:	74 0c                	je     801da9 <devcons_read+0x38>
	*(char*)vbuf = c;
  801d9d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801da0:	88 02                	mov    %al,(%edx)
	return 1;
  801da2:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801da7:	c9                   	leave  
  801da8:	c3                   	ret    
		return 0;
  801da9:	b8 00 00 00 00       	mov    $0x0,%eax
  801dae:	eb f7                	jmp    801da7 <devcons_read+0x36>

00801db0 <cputchar>:
{
  801db0:	f3 0f 1e fb          	endbr32 
  801db4:	55                   	push   %ebp
  801db5:	89 e5                	mov    %esp,%ebp
  801db7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dba:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbd:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801dc0:	6a 01                	push   $0x1
  801dc2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dc5:	50                   	push   %eax
  801dc6:	e8 83 ed ff ff       	call   800b4e <sys_cputs>
}
  801dcb:	83 c4 10             	add    $0x10,%esp
  801dce:	c9                   	leave  
  801dcf:	c3                   	ret    

00801dd0 <getchar>:
{
  801dd0:	f3 0f 1e fb          	endbr32 
  801dd4:	55                   	push   %ebp
  801dd5:	89 e5                	mov    %esp,%ebp
  801dd7:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801dda:	6a 01                	push   $0x1
  801ddc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ddf:	50                   	push   %eax
  801de0:	6a 00                	push   $0x0
  801de2:	e8 8b f6 ff ff       	call   801472 <read>
	if (r < 0)
  801de7:	83 c4 10             	add    $0x10,%esp
  801dea:	85 c0                	test   %eax,%eax
  801dec:	78 06                	js     801df4 <getchar+0x24>
	if (r < 1)
  801dee:	74 06                	je     801df6 <getchar+0x26>
	return c;
  801df0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801df4:	c9                   	leave  
  801df5:	c3                   	ret    
		return -E_EOF;
  801df6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801dfb:	eb f7                	jmp    801df4 <getchar+0x24>

00801dfd <iscons>:
{
  801dfd:	f3 0f 1e fb          	endbr32 
  801e01:	55                   	push   %ebp
  801e02:	89 e5                	mov    %esp,%ebp
  801e04:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e07:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e0a:	50                   	push   %eax
  801e0b:	ff 75 08             	pushl  0x8(%ebp)
  801e0e:	e8 dc f3 ff ff       	call   8011ef <fd_lookup>
  801e13:	83 c4 10             	add    $0x10,%esp
  801e16:	85 c0                	test   %eax,%eax
  801e18:	78 11                	js     801e2b <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801e1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e1d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e23:	39 10                	cmp    %edx,(%eax)
  801e25:	0f 94 c0             	sete   %al
  801e28:	0f b6 c0             	movzbl %al,%eax
}
  801e2b:	c9                   	leave  
  801e2c:	c3                   	ret    

00801e2d <opencons>:
{
  801e2d:	f3 0f 1e fb          	endbr32 
  801e31:	55                   	push   %ebp
  801e32:	89 e5                	mov    %esp,%ebp
  801e34:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801e37:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e3a:	50                   	push   %eax
  801e3b:	e8 59 f3 ff ff       	call   801199 <fd_alloc>
  801e40:	83 c4 10             	add    $0x10,%esp
  801e43:	85 c0                	test   %eax,%eax
  801e45:	78 3a                	js     801e81 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e47:	83 ec 04             	sub    $0x4,%esp
  801e4a:	68 07 04 00 00       	push   $0x407
  801e4f:	ff 75 f4             	pushl  -0xc(%ebp)
  801e52:	6a 00                	push   $0x0
  801e54:	e8 c5 ed ff ff       	call   800c1e <sys_page_alloc>
  801e59:	83 c4 10             	add    $0x10,%esp
  801e5c:	85 c0                	test   %eax,%eax
  801e5e:	78 21                	js     801e81 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801e60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e63:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e69:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e6e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e75:	83 ec 0c             	sub    $0xc,%esp
  801e78:	50                   	push   %eax
  801e79:	e8 ec f2 ff ff       	call   80116a <fd2num>
  801e7e:	83 c4 10             	add    $0x10,%esp
}
  801e81:	c9                   	leave  
  801e82:	c3                   	ret    

00801e83 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e83:	f3 0f 1e fb          	endbr32 
  801e87:	55                   	push   %ebp
  801e88:	89 e5                	mov    %esp,%ebp
  801e8a:	56                   	push   %esi
  801e8b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e8c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e8f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e95:	e8 3e ed ff ff       	call   800bd8 <sys_getenvid>
  801e9a:	83 ec 0c             	sub    $0xc,%esp
  801e9d:	ff 75 0c             	pushl  0xc(%ebp)
  801ea0:	ff 75 08             	pushl  0x8(%ebp)
  801ea3:	56                   	push   %esi
  801ea4:	50                   	push   %eax
  801ea5:	68 6c 27 80 00       	push   $0x80276c
  801eaa:	e8 24 e3 ff ff       	call   8001d3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801eaf:	83 c4 18             	add    $0x18,%esp
  801eb2:	53                   	push   %ebx
  801eb3:	ff 75 10             	pushl  0x10(%ebp)
  801eb6:	e8 c3 e2 ff ff       	call   80017e <vcprintf>
	cprintf("\n");
  801ebb:	c7 04 24 9c 27 80 00 	movl   $0x80279c,(%esp)
  801ec2:	e8 0c e3 ff ff       	call   8001d3 <cprintf>
  801ec7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801eca:	cc                   	int3   
  801ecb:	eb fd                	jmp    801eca <_panic+0x47>

00801ecd <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ecd:	f3 0f 1e fb          	endbr32 
  801ed1:	55                   	push   %ebp
  801ed2:	89 e5                	mov    %esp,%ebp
  801ed4:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ed7:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ede:	74 0a                	je     801eea <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801ee0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee3:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801ee8:	c9                   	leave  
  801ee9:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  801eea:	83 ec 0c             	sub    $0xc,%esp
  801eed:	68 8f 27 80 00       	push   $0x80278f
  801ef2:	e8 dc e2 ff ff       	call   8001d3 <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  801ef7:	83 c4 0c             	add    $0xc,%esp
  801efa:	6a 07                	push   $0x7
  801efc:	68 00 f0 bf ee       	push   $0xeebff000
  801f01:	6a 00                	push   $0x0
  801f03:	e8 16 ed ff ff       	call   800c1e <sys_page_alloc>
  801f08:	83 c4 10             	add    $0x10,%esp
  801f0b:	85 c0                	test   %eax,%eax
  801f0d:	78 2a                	js     801f39 <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  801f0f:	83 ec 08             	sub    $0x8,%esp
  801f12:	68 4d 1f 80 00       	push   $0x801f4d
  801f17:	6a 00                	push   $0x0
  801f19:	e8 5f ee ff ff       	call   800d7d <sys_env_set_pgfault_upcall>
  801f1e:	83 c4 10             	add    $0x10,%esp
  801f21:	85 c0                	test   %eax,%eax
  801f23:	79 bb                	jns    801ee0 <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  801f25:	83 ec 04             	sub    $0x4,%esp
  801f28:	68 cc 27 80 00       	push   $0x8027cc
  801f2d:	6a 25                	push   $0x25
  801f2f:	68 bc 27 80 00       	push   $0x8027bc
  801f34:	e8 4a ff ff ff       	call   801e83 <_panic>
            panic("Allocation of UXSTACK failed!");
  801f39:	83 ec 04             	sub    $0x4,%esp
  801f3c:	68 9e 27 80 00       	push   $0x80279e
  801f41:	6a 22                	push   $0x22
  801f43:	68 bc 27 80 00       	push   $0x8027bc
  801f48:	e8 36 ff ff ff       	call   801e83 <_panic>

00801f4d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f4d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f4e:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f53:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f55:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  801f58:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  801f5c:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  801f60:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  801f63:	83 c4 08             	add    $0x8,%esp
    popa
  801f66:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

    add $0x4, %esp
  801f67:	83 c4 04             	add    $0x4,%esp
    popf
  801f6a:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  801f6b:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  801f6e:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  801f72:	c3                   	ret    

00801f73 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f73:	f3 0f 1e fb          	endbr32 
  801f77:	55                   	push   %ebp
  801f78:	89 e5                	mov    %esp,%ebp
  801f7a:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f7d:	89 c2                	mov    %eax,%edx
  801f7f:	c1 ea 16             	shr    $0x16,%edx
  801f82:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801f89:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801f8e:	f6 c1 01             	test   $0x1,%cl
  801f91:	74 1c                	je     801faf <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801f93:	c1 e8 0c             	shr    $0xc,%eax
  801f96:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801f9d:	a8 01                	test   $0x1,%al
  801f9f:	74 0e                	je     801faf <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fa1:	c1 e8 0c             	shr    $0xc,%eax
  801fa4:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801fab:	ef 
  801fac:	0f b7 d2             	movzwl %dx,%edx
}
  801faf:	89 d0                	mov    %edx,%eax
  801fb1:	5d                   	pop    %ebp
  801fb2:	c3                   	ret    
  801fb3:	66 90                	xchg   %ax,%ax
  801fb5:	66 90                	xchg   %ax,%ax
  801fb7:	66 90                	xchg   %ax,%ax
  801fb9:	66 90                	xchg   %ax,%ax
  801fbb:	66 90                	xchg   %ax,%ax
  801fbd:	66 90                	xchg   %ax,%ax
  801fbf:	90                   	nop

00801fc0 <__udivdi3>:
  801fc0:	f3 0f 1e fb          	endbr32 
  801fc4:	55                   	push   %ebp
  801fc5:	57                   	push   %edi
  801fc6:	56                   	push   %esi
  801fc7:	53                   	push   %ebx
  801fc8:	83 ec 1c             	sub    $0x1c,%esp
  801fcb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801fcf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801fd3:	8b 74 24 34          	mov    0x34(%esp),%esi
  801fd7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801fdb:	85 d2                	test   %edx,%edx
  801fdd:	75 19                	jne    801ff8 <__udivdi3+0x38>
  801fdf:	39 f3                	cmp    %esi,%ebx
  801fe1:	76 4d                	jbe    802030 <__udivdi3+0x70>
  801fe3:	31 ff                	xor    %edi,%edi
  801fe5:	89 e8                	mov    %ebp,%eax
  801fe7:	89 f2                	mov    %esi,%edx
  801fe9:	f7 f3                	div    %ebx
  801feb:	89 fa                	mov    %edi,%edx
  801fed:	83 c4 1c             	add    $0x1c,%esp
  801ff0:	5b                   	pop    %ebx
  801ff1:	5e                   	pop    %esi
  801ff2:	5f                   	pop    %edi
  801ff3:	5d                   	pop    %ebp
  801ff4:	c3                   	ret    
  801ff5:	8d 76 00             	lea    0x0(%esi),%esi
  801ff8:	39 f2                	cmp    %esi,%edx
  801ffa:	76 14                	jbe    802010 <__udivdi3+0x50>
  801ffc:	31 ff                	xor    %edi,%edi
  801ffe:	31 c0                	xor    %eax,%eax
  802000:	89 fa                	mov    %edi,%edx
  802002:	83 c4 1c             	add    $0x1c,%esp
  802005:	5b                   	pop    %ebx
  802006:	5e                   	pop    %esi
  802007:	5f                   	pop    %edi
  802008:	5d                   	pop    %ebp
  802009:	c3                   	ret    
  80200a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802010:	0f bd fa             	bsr    %edx,%edi
  802013:	83 f7 1f             	xor    $0x1f,%edi
  802016:	75 48                	jne    802060 <__udivdi3+0xa0>
  802018:	39 f2                	cmp    %esi,%edx
  80201a:	72 06                	jb     802022 <__udivdi3+0x62>
  80201c:	31 c0                	xor    %eax,%eax
  80201e:	39 eb                	cmp    %ebp,%ebx
  802020:	77 de                	ja     802000 <__udivdi3+0x40>
  802022:	b8 01 00 00 00       	mov    $0x1,%eax
  802027:	eb d7                	jmp    802000 <__udivdi3+0x40>
  802029:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802030:	89 d9                	mov    %ebx,%ecx
  802032:	85 db                	test   %ebx,%ebx
  802034:	75 0b                	jne    802041 <__udivdi3+0x81>
  802036:	b8 01 00 00 00       	mov    $0x1,%eax
  80203b:	31 d2                	xor    %edx,%edx
  80203d:	f7 f3                	div    %ebx
  80203f:	89 c1                	mov    %eax,%ecx
  802041:	31 d2                	xor    %edx,%edx
  802043:	89 f0                	mov    %esi,%eax
  802045:	f7 f1                	div    %ecx
  802047:	89 c6                	mov    %eax,%esi
  802049:	89 e8                	mov    %ebp,%eax
  80204b:	89 f7                	mov    %esi,%edi
  80204d:	f7 f1                	div    %ecx
  80204f:	89 fa                	mov    %edi,%edx
  802051:	83 c4 1c             	add    $0x1c,%esp
  802054:	5b                   	pop    %ebx
  802055:	5e                   	pop    %esi
  802056:	5f                   	pop    %edi
  802057:	5d                   	pop    %ebp
  802058:	c3                   	ret    
  802059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802060:	89 f9                	mov    %edi,%ecx
  802062:	b8 20 00 00 00       	mov    $0x20,%eax
  802067:	29 f8                	sub    %edi,%eax
  802069:	d3 e2                	shl    %cl,%edx
  80206b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80206f:	89 c1                	mov    %eax,%ecx
  802071:	89 da                	mov    %ebx,%edx
  802073:	d3 ea                	shr    %cl,%edx
  802075:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802079:	09 d1                	or     %edx,%ecx
  80207b:	89 f2                	mov    %esi,%edx
  80207d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802081:	89 f9                	mov    %edi,%ecx
  802083:	d3 e3                	shl    %cl,%ebx
  802085:	89 c1                	mov    %eax,%ecx
  802087:	d3 ea                	shr    %cl,%edx
  802089:	89 f9                	mov    %edi,%ecx
  80208b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80208f:	89 eb                	mov    %ebp,%ebx
  802091:	d3 e6                	shl    %cl,%esi
  802093:	89 c1                	mov    %eax,%ecx
  802095:	d3 eb                	shr    %cl,%ebx
  802097:	09 de                	or     %ebx,%esi
  802099:	89 f0                	mov    %esi,%eax
  80209b:	f7 74 24 08          	divl   0x8(%esp)
  80209f:	89 d6                	mov    %edx,%esi
  8020a1:	89 c3                	mov    %eax,%ebx
  8020a3:	f7 64 24 0c          	mull   0xc(%esp)
  8020a7:	39 d6                	cmp    %edx,%esi
  8020a9:	72 15                	jb     8020c0 <__udivdi3+0x100>
  8020ab:	89 f9                	mov    %edi,%ecx
  8020ad:	d3 e5                	shl    %cl,%ebp
  8020af:	39 c5                	cmp    %eax,%ebp
  8020b1:	73 04                	jae    8020b7 <__udivdi3+0xf7>
  8020b3:	39 d6                	cmp    %edx,%esi
  8020b5:	74 09                	je     8020c0 <__udivdi3+0x100>
  8020b7:	89 d8                	mov    %ebx,%eax
  8020b9:	31 ff                	xor    %edi,%edi
  8020bb:	e9 40 ff ff ff       	jmp    802000 <__udivdi3+0x40>
  8020c0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8020c3:	31 ff                	xor    %edi,%edi
  8020c5:	e9 36 ff ff ff       	jmp    802000 <__udivdi3+0x40>
  8020ca:	66 90                	xchg   %ax,%ax
  8020cc:	66 90                	xchg   %ax,%ax
  8020ce:	66 90                	xchg   %ax,%ax

008020d0 <__umoddi3>:
  8020d0:	f3 0f 1e fb          	endbr32 
  8020d4:	55                   	push   %ebp
  8020d5:	57                   	push   %edi
  8020d6:	56                   	push   %esi
  8020d7:	53                   	push   %ebx
  8020d8:	83 ec 1c             	sub    $0x1c,%esp
  8020db:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8020df:	8b 74 24 30          	mov    0x30(%esp),%esi
  8020e3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8020e7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020eb:	85 c0                	test   %eax,%eax
  8020ed:	75 19                	jne    802108 <__umoddi3+0x38>
  8020ef:	39 df                	cmp    %ebx,%edi
  8020f1:	76 5d                	jbe    802150 <__umoddi3+0x80>
  8020f3:	89 f0                	mov    %esi,%eax
  8020f5:	89 da                	mov    %ebx,%edx
  8020f7:	f7 f7                	div    %edi
  8020f9:	89 d0                	mov    %edx,%eax
  8020fb:	31 d2                	xor    %edx,%edx
  8020fd:	83 c4 1c             	add    $0x1c,%esp
  802100:	5b                   	pop    %ebx
  802101:	5e                   	pop    %esi
  802102:	5f                   	pop    %edi
  802103:	5d                   	pop    %ebp
  802104:	c3                   	ret    
  802105:	8d 76 00             	lea    0x0(%esi),%esi
  802108:	89 f2                	mov    %esi,%edx
  80210a:	39 d8                	cmp    %ebx,%eax
  80210c:	76 12                	jbe    802120 <__umoddi3+0x50>
  80210e:	89 f0                	mov    %esi,%eax
  802110:	89 da                	mov    %ebx,%edx
  802112:	83 c4 1c             	add    $0x1c,%esp
  802115:	5b                   	pop    %ebx
  802116:	5e                   	pop    %esi
  802117:	5f                   	pop    %edi
  802118:	5d                   	pop    %ebp
  802119:	c3                   	ret    
  80211a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802120:	0f bd e8             	bsr    %eax,%ebp
  802123:	83 f5 1f             	xor    $0x1f,%ebp
  802126:	75 50                	jne    802178 <__umoddi3+0xa8>
  802128:	39 d8                	cmp    %ebx,%eax
  80212a:	0f 82 e0 00 00 00    	jb     802210 <__umoddi3+0x140>
  802130:	89 d9                	mov    %ebx,%ecx
  802132:	39 f7                	cmp    %esi,%edi
  802134:	0f 86 d6 00 00 00    	jbe    802210 <__umoddi3+0x140>
  80213a:	89 d0                	mov    %edx,%eax
  80213c:	89 ca                	mov    %ecx,%edx
  80213e:	83 c4 1c             	add    $0x1c,%esp
  802141:	5b                   	pop    %ebx
  802142:	5e                   	pop    %esi
  802143:	5f                   	pop    %edi
  802144:	5d                   	pop    %ebp
  802145:	c3                   	ret    
  802146:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80214d:	8d 76 00             	lea    0x0(%esi),%esi
  802150:	89 fd                	mov    %edi,%ebp
  802152:	85 ff                	test   %edi,%edi
  802154:	75 0b                	jne    802161 <__umoddi3+0x91>
  802156:	b8 01 00 00 00       	mov    $0x1,%eax
  80215b:	31 d2                	xor    %edx,%edx
  80215d:	f7 f7                	div    %edi
  80215f:	89 c5                	mov    %eax,%ebp
  802161:	89 d8                	mov    %ebx,%eax
  802163:	31 d2                	xor    %edx,%edx
  802165:	f7 f5                	div    %ebp
  802167:	89 f0                	mov    %esi,%eax
  802169:	f7 f5                	div    %ebp
  80216b:	89 d0                	mov    %edx,%eax
  80216d:	31 d2                	xor    %edx,%edx
  80216f:	eb 8c                	jmp    8020fd <__umoddi3+0x2d>
  802171:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802178:	89 e9                	mov    %ebp,%ecx
  80217a:	ba 20 00 00 00       	mov    $0x20,%edx
  80217f:	29 ea                	sub    %ebp,%edx
  802181:	d3 e0                	shl    %cl,%eax
  802183:	89 44 24 08          	mov    %eax,0x8(%esp)
  802187:	89 d1                	mov    %edx,%ecx
  802189:	89 f8                	mov    %edi,%eax
  80218b:	d3 e8                	shr    %cl,%eax
  80218d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802191:	89 54 24 04          	mov    %edx,0x4(%esp)
  802195:	8b 54 24 04          	mov    0x4(%esp),%edx
  802199:	09 c1                	or     %eax,%ecx
  80219b:	89 d8                	mov    %ebx,%eax
  80219d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021a1:	89 e9                	mov    %ebp,%ecx
  8021a3:	d3 e7                	shl    %cl,%edi
  8021a5:	89 d1                	mov    %edx,%ecx
  8021a7:	d3 e8                	shr    %cl,%eax
  8021a9:	89 e9                	mov    %ebp,%ecx
  8021ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8021af:	d3 e3                	shl    %cl,%ebx
  8021b1:	89 c7                	mov    %eax,%edi
  8021b3:	89 d1                	mov    %edx,%ecx
  8021b5:	89 f0                	mov    %esi,%eax
  8021b7:	d3 e8                	shr    %cl,%eax
  8021b9:	89 e9                	mov    %ebp,%ecx
  8021bb:	89 fa                	mov    %edi,%edx
  8021bd:	d3 e6                	shl    %cl,%esi
  8021bf:	09 d8                	or     %ebx,%eax
  8021c1:	f7 74 24 08          	divl   0x8(%esp)
  8021c5:	89 d1                	mov    %edx,%ecx
  8021c7:	89 f3                	mov    %esi,%ebx
  8021c9:	f7 64 24 0c          	mull   0xc(%esp)
  8021cd:	89 c6                	mov    %eax,%esi
  8021cf:	89 d7                	mov    %edx,%edi
  8021d1:	39 d1                	cmp    %edx,%ecx
  8021d3:	72 06                	jb     8021db <__umoddi3+0x10b>
  8021d5:	75 10                	jne    8021e7 <__umoddi3+0x117>
  8021d7:	39 c3                	cmp    %eax,%ebx
  8021d9:	73 0c                	jae    8021e7 <__umoddi3+0x117>
  8021db:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8021df:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8021e3:	89 d7                	mov    %edx,%edi
  8021e5:	89 c6                	mov    %eax,%esi
  8021e7:	89 ca                	mov    %ecx,%edx
  8021e9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8021ee:	29 f3                	sub    %esi,%ebx
  8021f0:	19 fa                	sbb    %edi,%edx
  8021f2:	89 d0                	mov    %edx,%eax
  8021f4:	d3 e0                	shl    %cl,%eax
  8021f6:	89 e9                	mov    %ebp,%ecx
  8021f8:	d3 eb                	shr    %cl,%ebx
  8021fa:	d3 ea                	shr    %cl,%edx
  8021fc:	09 d8                	or     %ebx,%eax
  8021fe:	83 c4 1c             	add    $0x1c,%esp
  802201:	5b                   	pop    %ebx
  802202:	5e                   	pop    %esi
  802203:	5f                   	pop    %edi
  802204:	5d                   	pop    %ebp
  802205:	c3                   	ret    
  802206:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80220d:	8d 76 00             	lea    0x0(%esi),%esi
  802210:	29 fe                	sub    %edi,%esi
  802212:	19 c3                	sbb    %eax,%ebx
  802214:	89 f2                	mov    %esi,%edx
  802216:	89 d9                	mov    %ebx,%ecx
  802218:	e9 1d ff ff ff       	jmp    80213a <__umoddi3+0x6a>
