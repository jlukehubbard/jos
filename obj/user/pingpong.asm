
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
  800057:	e8 1f 10 00 00       	call   80107b <ipc_recv>
  80005c:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  80005e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800061:	e8 72 0b 00 00       	call   800bd8 <sys_getenvid>
  800066:	57                   	push   %edi
  800067:	53                   	push   %ebx
  800068:	50                   	push   %eax
  800069:	68 76 22 80 00       	push   $0x802276
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
  800086:	e8 47 10 00 00       	call   8010d2 <ipc_send>
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
  8000a7:	68 60 22 80 00       	push   $0x802260
  8000ac:	e8 22 01 00 00       	call   8001d3 <cprintf>
		ipc_send(who, 0, 0, 0);
  8000b1:	6a 00                	push   $0x0
  8000b3:	6a 00                	push   $0x0
  8000b5:	6a 00                	push   $0x0
  8000b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000ba:	e8 13 10 00 00       	call   8010d2 <ipc_send>
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
  800122:	e8 3d 12 00 00       	call   801364 <close_all>
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
  800239:	e8 b2 1d 00 00       	call   801ff0 <__udivdi3>
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
  800277:	e8 84 1e 00 00       	call   802100 <__umoddi3>
  80027c:	83 c4 14             	add    $0x14,%esp
  80027f:	0f be 80 93 22 80 00 	movsbl 0x802293(%eax),%eax
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
  800326:	3e ff 24 85 e0 23 80 	notrack jmp *0x8023e0(,%eax,4)
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
  8003f3:	8b 14 85 40 25 80 00 	mov    0x802540(,%eax,4),%edx
  8003fa:	85 d2                	test   %edx,%edx
  8003fc:	74 18                	je     800416 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8003fe:	52                   	push   %edx
  8003ff:	68 49 27 80 00       	push   $0x802749
  800404:	53                   	push   %ebx
  800405:	56                   	push   %esi
  800406:	e8 aa fe ff ff       	call   8002b5 <printfmt>
  80040b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80040e:	89 7d 14             	mov    %edi,0x14(%ebp)
  800411:	e9 22 02 00 00       	jmp    800638 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  800416:	50                   	push   %eax
  800417:	68 ab 22 80 00       	push   $0x8022ab
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
  80043e:	b8 a4 22 80 00       	mov    $0x8022a4,%eax
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
  800bc7:	68 9f 25 80 00       	push   $0x80259f
  800bcc:	6a 23                	push   $0x23
  800bce:	68 bc 25 80 00       	push   $0x8025bc
  800bd3:	e8 e2 12 00 00       	call   801eba <_panic>

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
  800c54:	68 9f 25 80 00       	push   $0x80259f
  800c59:	6a 23                	push   $0x23
  800c5b:	68 bc 25 80 00       	push   $0x8025bc
  800c60:	e8 55 12 00 00       	call   801eba <_panic>

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
  800c9a:	68 9f 25 80 00       	push   $0x80259f
  800c9f:	6a 23                	push   $0x23
  800ca1:	68 bc 25 80 00       	push   $0x8025bc
  800ca6:	e8 0f 12 00 00       	call   801eba <_panic>

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
  800ce0:	68 9f 25 80 00       	push   $0x80259f
  800ce5:	6a 23                	push   $0x23
  800ce7:	68 bc 25 80 00       	push   $0x8025bc
  800cec:	e8 c9 11 00 00       	call   801eba <_panic>

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
  800d26:	68 9f 25 80 00       	push   $0x80259f
  800d2b:	6a 23                	push   $0x23
  800d2d:	68 bc 25 80 00       	push   $0x8025bc
  800d32:	e8 83 11 00 00       	call   801eba <_panic>

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
  800d6c:	68 9f 25 80 00       	push   $0x80259f
  800d71:	6a 23                	push   $0x23
  800d73:	68 bc 25 80 00       	push   $0x8025bc
  800d78:	e8 3d 11 00 00       	call   801eba <_panic>

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
  800db2:	68 9f 25 80 00       	push   $0x80259f
  800db7:	6a 23                	push   $0x23
  800db9:	68 bc 25 80 00       	push   $0x8025bc
  800dbe:	e8 f7 10 00 00       	call   801eba <_panic>

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
  800e1e:	68 9f 25 80 00       	push   $0x80259f
  800e23:	6a 23                	push   $0x23
  800e25:	68 bc 25 80 00       	push   $0x8025bc
  800e2a:	e8 8b 10 00 00       	call   801eba <_panic>

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
  800ebd:	68 ca 25 80 00       	push   $0x8025ca
  800ec2:	6a 1e                	push   $0x1e
  800ec4:	68 e3 25 80 00       	push   $0x8025e3
  800ec9:	e8 ec 0f 00 00       	call   801eba <_panic>
        panic("sys_page_alloc failed %e\n", r);
  800ece:	50                   	push   %eax
  800ecf:	68 ee 25 80 00       	push   $0x8025ee
  800ed4:	6a 2a                	push   $0x2a
  800ed6:	68 e3 25 80 00       	push   $0x8025e3
  800edb:	e8 da 0f 00 00       	call   801eba <_panic>
        panic("sys_page_map failed %e\n", r);
  800ee0:	50                   	push   %eax
  800ee1:	68 08 26 80 00       	push   $0x802608
  800ee6:	6a 2f                	push   $0x2f
  800ee8:	68 e3 25 80 00       	push   $0x8025e3
  800eed:	e8 c8 0f 00 00       	call   801eba <_panic>
        panic("sys_page_unmap failed %e\n", r);
  800ef2:	50                   	push   %eax
  800ef3:	68 20 26 80 00       	push   $0x802620
  800ef8:	6a 32                	push   $0x32
  800efa:	68 e3 25 80 00       	push   $0x8025e3
  800eff:	e8 b6 0f 00 00       	call   801eba <_panic>

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
  800f16:	e8 e9 0f 00 00       	call   801f04 <set_pgfault_handler>
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
  800f38:	75 69                	jne    800fa3 <fork+0x9f>
        envid_t my_envid = sys_getenvid();
  800f3a:	e8 99 fc ff ff       	call   800bd8 <sys_getenvid>
        thisenv = &envs[ENVX(my_envid)];
  800f3f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f44:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f47:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f4c:	a3 04 40 80 00       	mov    %eax,0x804004
        return 0;
  800f51:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f54:	e9 fc 00 00 00       	jmp    801055 <fork+0x151>
        panic("fork, sys_exofork %e", envid);
  800f59:	50                   	push   %eax
  800f5a:	68 3a 26 80 00       	push   $0x80263a
  800f5f:	6a 7b                	push   $0x7b
  800f61:	68 e3 25 80 00       	push   $0x8025e3
  800f66:	e8 4f 0f 00 00       	call   801eba <_panic>
    if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0) {
  800f6b:	83 ec 0c             	sub    $0xc,%esp
  800f6e:	57                   	push   %edi
  800f6f:	56                   	push   %esi
  800f70:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f73:	56                   	push   %esi
  800f74:	6a 00                	push   $0x0
  800f76:	e8 ea fc ff ff       	call   800c65 <sys_page_map>
  800f7b:	83 c4 20             	add    $0x20,%esp
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	78 69                	js     800feb <fork+0xe7>
        if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0) {
  800f82:	83 ec 0c             	sub    $0xc,%esp
  800f85:	57                   	push   %edi
  800f86:	56                   	push   %esi
  800f87:	6a 00                	push   $0x0
  800f89:	56                   	push   %esi
  800f8a:	6a 00                	push   $0x0
  800f8c:	e8 d4 fc ff ff       	call   800c65 <sys_page_map>
  800f91:	83 c4 20             	add    $0x20,%esp
  800f94:	85 c0                	test   %eax,%eax
  800f96:	78 65                	js     800ffd <fork+0xf9>
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800f98:	83 c3 01             	add    $0x1,%ebx
  800f9b:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  800fa1:	74 6c                	je     80100f <fork+0x10b>
  800fa3:	89 de                	mov    %ebx,%esi
  800fa5:	c1 e6 0c             	shl    $0xc,%esi
            uintptr_t pgaddr = pn << PGSHIFT;
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800fa8:	89 f0                	mov    %esi,%eax
  800faa:	c1 e8 16             	shr    $0x16,%eax
  800fad:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fb4:	a8 01                	test   $0x1,%al
  800fb6:	74 e0                	je     800f98 <fork+0x94>
                    (uvpt[pn] & PTE_P) ) {
  800fb8:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800fbf:	a8 01                	test   $0x1,%al
  800fc1:	74 d5                	je     800f98 <fork+0x94>
    pte_t pte = uvpt[pn];
  800fc3:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
    int perm = PTE_U | PTE_P;
  800fca:	bf 05 00 00 00       	mov    $0x5,%edi
    if ( ((pte & PTE_W) || (pte & PTE_COW)) && !(pte & PTE_SHARE)) {
  800fcf:	a9 02 08 00 00       	test   $0x802,%eax
  800fd4:	74 95                	je     800f6b <fork+0x67>
  800fd6:	25 00 04 00 00       	and    $0x400,%eax
        perm |= PTE_COW;
  800fdb:	83 f8 01             	cmp    $0x1,%eax
  800fde:	19 ff                	sbb    %edi,%edi
  800fe0:	81 e7 00 08 00 00    	and    $0x800,%edi
  800fe6:	83 c7 05             	add    $0x5,%edi
  800fe9:	eb 80                	jmp    800f6b <fork+0x67>
        panic("sys_page_map others failed %e\n", r);
  800feb:	50                   	push   %eax
  800fec:	68 84 26 80 00       	push   $0x802684
  800ff1:	6a 51                	push   $0x51
  800ff3:	68 e3 25 80 00       	push   $0x8025e3
  800ff8:	e8 bd 0e 00 00       	call   801eba <_panic>
            panic("sys_page_map mine failed %e\n", r);
  800ffd:	50                   	push   %eax
  800ffe:	68 4f 26 80 00       	push   $0x80264f
  801003:	6a 56                	push   $0x56
  801005:	68 e3 25 80 00       	push   $0x8025e3
  80100a:	e8 ab 0e 00 00       	call   801eba <_panic>
            }
        }

        int r;

        if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE),
  80100f:	83 ec 04             	sub    $0x4,%esp
  801012:	6a 07                	push   $0x7
  801014:	68 00 f0 bf ee       	push   $0xeebff000
  801019:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80101c:	57                   	push   %edi
  80101d:	e8 fc fb ff ff       	call   800c1e <sys_page_alloc>
  801022:	83 c4 10             	add    $0x10,%esp
  801025:	85 c0                	test   %eax,%eax
  801027:	78 2c                	js     801055 <fork+0x151>
                    PTE_U | PTE_W | PTE_P)) < 0) {
            return r;
        }

        if ((r = sys_env_set_pgfault_upcall(envid,
                        thisenv->env_pgfault_upcall)) < 0) {
  801029:	a1 04 40 80 00       	mov    0x804004,%eax
        if ((r = sys_env_set_pgfault_upcall(envid,
  80102e:	8b 40 64             	mov    0x64(%eax),%eax
  801031:	83 ec 08             	sub    $0x8,%esp
  801034:	50                   	push   %eax
  801035:	57                   	push   %edi
  801036:	e8 42 fd ff ff       	call   800d7d <sys_env_set_pgfault_upcall>
  80103b:	83 c4 10             	add    $0x10,%esp
  80103e:	85 c0                	test   %eax,%eax
  801040:	78 13                	js     801055 <fork+0x151>
            return r;
        }

        if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  801042:	83 ec 08             	sub    $0x8,%esp
  801045:	6a 02                	push   $0x2
  801047:	57                   	push   %edi
  801048:	e8 a4 fc ff ff       	call   800cf1 <sys_env_set_status>
  80104d:	83 c4 10             	add    $0x10,%esp
            return r;
        }
        return envid;
  801050:	85 c0                	test   %eax,%eax
  801052:	0f 49 c7             	cmovns %edi,%eax
    }

}
  801055:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801058:	5b                   	pop    %ebx
  801059:	5e                   	pop    %esi
  80105a:	5f                   	pop    %edi
  80105b:	5d                   	pop    %ebp
  80105c:	c3                   	ret    

0080105d <sfork>:

// Challenge!
int
sfork(void)
{
  80105d:	f3 0f 1e fb          	endbr32 
  801061:	55                   	push   %ebp
  801062:	89 e5                	mov    %esp,%ebp
  801064:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801067:	68 6c 26 80 00       	push   $0x80266c
  80106c:	68 a5 00 00 00       	push   $0xa5
  801071:	68 e3 25 80 00       	push   $0x8025e3
  801076:	e8 3f 0e 00 00       	call   801eba <_panic>

0080107b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80107b:	f3 0f 1e fb          	endbr32 
  80107f:	55                   	push   %ebp
  801080:	89 e5                	mov    %esp,%ebp
  801082:	56                   	push   %esi
  801083:	53                   	push   %ebx
  801084:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801087:	8b 45 0c             	mov    0xc(%ebp),%eax
  80108a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  80108d:	85 c0                	test   %eax,%eax
  80108f:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801094:	0f 44 c2             	cmove  %edx,%eax
  801097:	83 ec 0c             	sub    $0xc,%esp
  80109a:	50                   	push   %eax
  80109b:	e8 4a fd ff ff       	call   800dea <sys_ipc_recv>
  8010a0:	83 c4 10             	add    $0x10,%esp
  8010a3:	85 c0                	test   %eax,%eax
  8010a5:	78 24                	js     8010cb <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  8010a7:	85 f6                	test   %esi,%esi
  8010a9:	74 0a                	je     8010b5 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  8010ab:	a1 04 40 80 00       	mov    0x804004,%eax
  8010b0:	8b 40 78             	mov    0x78(%eax),%eax
  8010b3:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  8010b5:	85 db                	test   %ebx,%ebx
  8010b7:	74 0a                	je     8010c3 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  8010b9:	a1 04 40 80 00       	mov    0x804004,%eax
  8010be:	8b 40 74             	mov    0x74(%eax),%eax
  8010c1:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  8010c3:	a1 04 40 80 00       	mov    0x804004,%eax
  8010c8:	8b 40 70             	mov    0x70(%eax),%eax
}
  8010cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010ce:	5b                   	pop    %ebx
  8010cf:	5e                   	pop    %esi
  8010d0:	5d                   	pop    %ebp
  8010d1:	c3                   	ret    

008010d2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010d2:	f3 0f 1e fb          	endbr32 
  8010d6:	55                   	push   %ebp
  8010d7:	89 e5                	mov    %esp,%ebp
  8010d9:	57                   	push   %edi
  8010da:	56                   	push   %esi
  8010db:	53                   	push   %ebx
  8010dc:	83 ec 1c             	sub    $0x1c,%esp
  8010df:	8b 45 10             	mov    0x10(%ebp),%eax
  8010e2:	85 c0                	test   %eax,%eax
  8010e4:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8010e9:	0f 45 d0             	cmovne %eax,%edx
  8010ec:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  8010ee:	be 01 00 00 00       	mov    $0x1,%esi
  8010f3:	eb 1f                	jmp    801114 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  8010f5:	e8 01 fb ff ff       	call   800bfb <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  8010fa:	83 c3 01             	add    $0x1,%ebx
  8010fd:	39 de                	cmp    %ebx,%esi
  8010ff:	7f f4                	jg     8010f5 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801101:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801103:	83 fe 11             	cmp    $0x11,%esi
  801106:	b8 01 00 00 00       	mov    $0x1,%eax
  80110b:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  80110e:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801112:	75 1c                	jne    801130 <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801114:	ff 75 14             	pushl  0x14(%ebp)
  801117:	57                   	push   %edi
  801118:	ff 75 0c             	pushl  0xc(%ebp)
  80111b:	ff 75 08             	pushl  0x8(%ebp)
  80111e:	e8 a0 fc ff ff       	call   800dc3 <sys_ipc_try_send>
  801123:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801126:	83 c4 10             	add    $0x10,%esp
  801129:	bb 00 00 00 00       	mov    $0x0,%ebx
  80112e:	eb cd                	jmp    8010fd <ipc_send+0x2b>
}
  801130:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801133:	5b                   	pop    %ebx
  801134:	5e                   	pop    %esi
  801135:	5f                   	pop    %edi
  801136:	5d                   	pop    %ebp
  801137:	c3                   	ret    

00801138 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801138:	f3 0f 1e fb          	endbr32 
  80113c:	55                   	push   %ebp
  80113d:	89 e5                	mov    %esp,%ebp
  80113f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801142:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801147:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80114a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801150:	8b 52 50             	mov    0x50(%edx),%edx
  801153:	39 ca                	cmp    %ecx,%edx
  801155:	74 11                	je     801168 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801157:	83 c0 01             	add    $0x1,%eax
  80115a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80115f:	75 e6                	jne    801147 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801161:	b8 00 00 00 00       	mov    $0x0,%eax
  801166:	eb 0b                	jmp    801173 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801168:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80116b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801170:	8b 40 48             	mov    0x48(%eax),%eax
}
  801173:	5d                   	pop    %ebp
  801174:	c3                   	ret    

00801175 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801175:	f3 0f 1e fb          	endbr32 
  801179:	55                   	push   %ebp
  80117a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80117c:	8b 45 08             	mov    0x8(%ebp),%eax
  80117f:	05 00 00 00 30       	add    $0x30000000,%eax
  801184:	c1 e8 0c             	shr    $0xc,%eax
}
  801187:	5d                   	pop    %ebp
  801188:	c3                   	ret    

00801189 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801189:	f3 0f 1e fb          	endbr32 
  80118d:	55                   	push   %ebp
  80118e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801190:	8b 45 08             	mov    0x8(%ebp),%eax
  801193:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801198:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80119d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011a2:	5d                   	pop    %ebp
  8011a3:	c3                   	ret    

008011a4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011a4:	f3 0f 1e fb          	endbr32 
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
  8011ab:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011b0:	89 c2                	mov    %eax,%edx
  8011b2:	c1 ea 16             	shr    $0x16,%edx
  8011b5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011bc:	f6 c2 01             	test   $0x1,%dl
  8011bf:	74 2d                	je     8011ee <fd_alloc+0x4a>
  8011c1:	89 c2                	mov    %eax,%edx
  8011c3:	c1 ea 0c             	shr    $0xc,%edx
  8011c6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011cd:	f6 c2 01             	test   $0x1,%dl
  8011d0:	74 1c                	je     8011ee <fd_alloc+0x4a>
  8011d2:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8011d7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011dc:	75 d2                	jne    8011b0 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011de:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8011e7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8011ec:	eb 0a                	jmp    8011f8 <fd_alloc+0x54>
			*fd_store = fd;
  8011ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011f1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011f8:	5d                   	pop    %ebp
  8011f9:	c3                   	ret    

008011fa <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011fa:	f3 0f 1e fb          	endbr32 
  8011fe:	55                   	push   %ebp
  8011ff:	89 e5                	mov    %esp,%ebp
  801201:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801204:	83 f8 1f             	cmp    $0x1f,%eax
  801207:	77 30                	ja     801239 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801209:	c1 e0 0c             	shl    $0xc,%eax
  80120c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801211:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801217:	f6 c2 01             	test   $0x1,%dl
  80121a:	74 24                	je     801240 <fd_lookup+0x46>
  80121c:	89 c2                	mov    %eax,%edx
  80121e:	c1 ea 0c             	shr    $0xc,%edx
  801221:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801228:	f6 c2 01             	test   $0x1,%dl
  80122b:	74 1a                	je     801247 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80122d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801230:	89 02                	mov    %eax,(%edx)
	return 0;
  801232:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801237:	5d                   	pop    %ebp
  801238:	c3                   	ret    
		return -E_INVAL;
  801239:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80123e:	eb f7                	jmp    801237 <fd_lookup+0x3d>
		return -E_INVAL;
  801240:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801245:	eb f0                	jmp    801237 <fd_lookup+0x3d>
  801247:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80124c:	eb e9                	jmp    801237 <fd_lookup+0x3d>

0080124e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80124e:	f3 0f 1e fb          	endbr32 
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	83 ec 08             	sub    $0x8,%esp
  801258:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80125b:	ba 20 27 80 00       	mov    $0x802720,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801260:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  801265:	39 08                	cmp    %ecx,(%eax)
  801267:	74 33                	je     80129c <dev_lookup+0x4e>
  801269:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80126c:	8b 02                	mov    (%edx),%eax
  80126e:	85 c0                	test   %eax,%eax
  801270:	75 f3                	jne    801265 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801272:	a1 04 40 80 00       	mov    0x804004,%eax
  801277:	8b 40 48             	mov    0x48(%eax),%eax
  80127a:	83 ec 04             	sub    $0x4,%esp
  80127d:	51                   	push   %ecx
  80127e:	50                   	push   %eax
  80127f:	68 a4 26 80 00       	push   $0x8026a4
  801284:	e8 4a ef ff ff       	call   8001d3 <cprintf>
	*dev = 0;
  801289:	8b 45 0c             	mov    0xc(%ebp),%eax
  80128c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801292:	83 c4 10             	add    $0x10,%esp
  801295:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80129a:	c9                   	leave  
  80129b:	c3                   	ret    
			*dev = devtab[i];
  80129c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80129f:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a6:	eb f2                	jmp    80129a <dev_lookup+0x4c>

008012a8 <fd_close>:
{
  8012a8:	f3 0f 1e fb          	endbr32 
  8012ac:	55                   	push   %ebp
  8012ad:	89 e5                	mov    %esp,%ebp
  8012af:	57                   	push   %edi
  8012b0:	56                   	push   %esi
  8012b1:	53                   	push   %ebx
  8012b2:	83 ec 24             	sub    $0x24,%esp
  8012b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8012b8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012bb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012be:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012bf:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012c5:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012c8:	50                   	push   %eax
  8012c9:	e8 2c ff ff ff       	call   8011fa <fd_lookup>
  8012ce:	89 c3                	mov    %eax,%ebx
  8012d0:	83 c4 10             	add    $0x10,%esp
  8012d3:	85 c0                	test   %eax,%eax
  8012d5:	78 05                	js     8012dc <fd_close+0x34>
	    || fd != fd2)
  8012d7:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8012da:	74 16                	je     8012f2 <fd_close+0x4a>
		return (must_exist ? r : 0);
  8012dc:	89 f8                	mov    %edi,%eax
  8012de:	84 c0                	test   %al,%al
  8012e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e5:	0f 44 d8             	cmove  %eax,%ebx
}
  8012e8:	89 d8                	mov    %ebx,%eax
  8012ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012ed:	5b                   	pop    %ebx
  8012ee:	5e                   	pop    %esi
  8012ef:	5f                   	pop    %edi
  8012f0:	5d                   	pop    %ebp
  8012f1:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012f2:	83 ec 08             	sub    $0x8,%esp
  8012f5:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8012f8:	50                   	push   %eax
  8012f9:	ff 36                	pushl  (%esi)
  8012fb:	e8 4e ff ff ff       	call   80124e <dev_lookup>
  801300:	89 c3                	mov    %eax,%ebx
  801302:	83 c4 10             	add    $0x10,%esp
  801305:	85 c0                	test   %eax,%eax
  801307:	78 1a                	js     801323 <fd_close+0x7b>
		if (dev->dev_close)
  801309:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80130c:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80130f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801314:	85 c0                	test   %eax,%eax
  801316:	74 0b                	je     801323 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  801318:	83 ec 0c             	sub    $0xc,%esp
  80131b:	56                   	push   %esi
  80131c:	ff d0                	call   *%eax
  80131e:	89 c3                	mov    %eax,%ebx
  801320:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801323:	83 ec 08             	sub    $0x8,%esp
  801326:	56                   	push   %esi
  801327:	6a 00                	push   $0x0
  801329:	e8 7d f9 ff ff       	call   800cab <sys_page_unmap>
	return r;
  80132e:	83 c4 10             	add    $0x10,%esp
  801331:	eb b5                	jmp    8012e8 <fd_close+0x40>

00801333 <close>:

int
close(int fdnum)
{
  801333:	f3 0f 1e fb          	endbr32 
  801337:	55                   	push   %ebp
  801338:	89 e5                	mov    %esp,%ebp
  80133a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80133d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801340:	50                   	push   %eax
  801341:	ff 75 08             	pushl  0x8(%ebp)
  801344:	e8 b1 fe ff ff       	call   8011fa <fd_lookup>
  801349:	83 c4 10             	add    $0x10,%esp
  80134c:	85 c0                	test   %eax,%eax
  80134e:	79 02                	jns    801352 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801350:	c9                   	leave  
  801351:	c3                   	ret    
		return fd_close(fd, 1);
  801352:	83 ec 08             	sub    $0x8,%esp
  801355:	6a 01                	push   $0x1
  801357:	ff 75 f4             	pushl  -0xc(%ebp)
  80135a:	e8 49 ff ff ff       	call   8012a8 <fd_close>
  80135f:	83 c4 10             	add    $0x10,%esp
  801362:	eb ec                	jmp    801350 <close+0x1d>

00801364 <close_all>:

void
close_all(void)
{
  801364:	f3 0f 1e fb          	endbr32 
  801368:	55                   	push   %ebp
  801369:	89 e5                	mov    %esp,%ebp
  80136b:	53                   	push   %ebx
  80136c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80136f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801374:	83 ec 0c             	sub    $0xc,%esp
  801377:	53                   	push   %ebx
  801378:	e8 b6 ff ff ff       	call   801333 <close>
	for (i = 0; i < MAXFD; i++)
  80137d:	83 c3 01             	add    $0x1,%ebx
  801380:	83 c4 10             	add    $0x10,%esp
  801383:	83 fb 20             	cmp    $0x20,%ebx
  801386:	75 ec                	jne    801374 <close_all+0x10>
}
  801388:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80138b:	c9                   	leave  
  80138c:	c3                   	ret    

0080138d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80138d:	f3 0f 1e fb          	endbr32 
  801391:	55                   	push   %ebp
  801392:	89 e5                	mov    %esp,%ebp
  801394:	57                   	push   %edi
  801395:	56                   	push   %esi
  801396:	53                   	push   %ebx
  801397:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80139a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80139d:	50                   	push   %eax
  80139e:	ff 75 08             	pushl  0x8(%ebp)
  8013a1:	e8 54 fe ff ff       	call   8011fa <fd_lookup>
  8013a6:	89 c3                	mov    %eax,%ebx
  8013a8:	83 c4 10             	add    $0x10,%esp
  8013ab:	85 c0                	test   %eax,%eax
  8013ad:	0f 88 81 00 00 00    	js     801434 <dup+0xa7>
		return r;
	close(newfdnum);
  8013b3:	83 ec 0c             	sub    $0xc,%esp
  8013b6:	ff 75 0c             	pushl  0xc(%ebp)
  8013b9:	e8 75 ff ff ff       	call   801333 <close>

	newfd = INDEX2FD(newfdnum);
  8013be:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013c1:	c1 e6 0c             	shl    $0xc,%esi
  8013c4:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8013ca:	83 c4 04             	add    $0x4,%esp
  8013cd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013d0:	e8 b4 fd ff ff       	call   801189 <fd2data>
  8013d5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8013d7:	89 34 24             	mov    %esi,(%esp)
  8013da:	e8 aa fd ff ff       	call   801189 <fd2data>
  8013df:	83 c4 10             	add    $0x10,%esp
  8013e2:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013e4:	89 d8                	mov    %ebx,%eax
  8013e6:	c1 e8 16             	shr    $0x16,%eax
  8013e9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013f0:	a8 01                	test   $0x1,%al
  8013f2:	74 11                	je     801405 <dup+0x78>
  8013f4:	89 d8                	mov    %ebx,%eax
  8013f6:	c1 e8 0c             	shr    $0xc,%eax
  8013f9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801400:	f6 c2 01             	test   $0x1,%dl
  801403:	75 39                	jne    80143e <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801405:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801408:	89 d0                	mov    %edx,%eax
  80140a:	c1 e8 0c             	shr    $0xc,%eax
  80140d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801414:	83 ec 0c             	sub    $0xc,%esp
  801417:	25 07 0e 00 00       	and    $0xe07,%eax
  80141c:	50                   	push   %eax
  80141d:	56                   	push   %esi
  80141e:	6a 00                	push   $0x0
  801420:	52                   	push   %edx
  801421:	6a 00                	push   $0x0
  801423:	e8 3d f8 ff ff       	call   800c65 <sys_page_map>
  801428:	89 c3                	mov    %eax,%ebx
  80142a:	83 c4 20             	add    $0x20,%esp
  80142d:	85 c0                	test   %eax,%eax
  80142f:	78 31                	js     801462 <dup+0xd5>
		goto err;

	return newfdnum;
  801431:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801434:	89 d8                	mov    %ebx,%eax
  801436:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801439:	5b                   	pop    %ebx
  80143a:	5e                   	pop    %esi
  80143b:	5f                   	pop    %edi
  80143c:	5d                   	pop    %ebp
  80143d:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80143e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801445:	83 ec 0c             	sub    $0xc,%esp
  801448:	25 07 0e 00 00       	and    $0xe07,%eax
  80144d:	50                   	push   %eax
  80144e:	57                   	push   %edi
  80144f:	6a 00                	push   $0x0
  801451:	53                   	push   %ebx
  801452:	6a 00                	push   $0x0
  801454:	e8 0c f8 ff ff       	call   800c65 <sys_page_map>
  801459:	89 c3                	mov    %eax,%ebx
  80145b:	83 c4 20             	add    $0x20,%esp
  80145e:	85 c0                	test   %eax,%eax
  801460:	79 a3                	jns    801405 <dup+0x78>
	sys_page_unmap(0, newfd);
  801462:	83 ec 08             	sub    $0x8,%esp
  801465:	56                   	push   %esi
  801466:	6a 00                	push   $0x0
  801468:	e8 3e f8 ff ff       	call   800cab <sys_page_unmap>
	sys_page_unmap(0, nva);
  80146d:	83 c4 08             	add    $0x8,%esp
  801470:	57                   	push   %edi
  801471:	6a 00                	push   $0x0
  801473:	e8 33 f8 ff ff       	call   800cab <sys_page_unmap>
	return r;
  801478:	83 c4 10             	add    $0x10,%esp
  80147b:	eb b7                	jmp    801434 <dup+0xa7>

0080147d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80147d:	f3 0f 1e fb          	endbr32 
  801481:	55                   	push   %ebp
  801482:	89 e5                	mov    %esp,%ebp
  801484:	53                   	push   %ebx
  801485:	83 ec 1c             	sub    $0x1c,%esp
  801488:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80148b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80148e:	50                   	push   %eax
  80148f:	53                   	push   %ebx
  801490:	e8 65 fd ff ff       	call   8011fa <fd_lookup>
  801495:	83 c4 10             	add    $0x10,%esp
  801498:	85 c0                	test   %eax,%eax
  80149a:	78 3f                	js     8014db <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80149c:	83 ec 08             	sub    $0x8,%esp
  80149f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a2:	50                   	push   %eax
  8014a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a6:	ff 30                	pushl  (%eax)
  8014a8:	e8 a1 fd ff ff       	call   80124e <dev_lookup>
  8014ad:	83 c4 10             	add    $0x10,%esp
  8014b0:	85 c0                	test   %eax,%eax
  8014b2:	78 27                	js     8014db <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014b4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014b7:	8b 42 08             	mov    0x8(%edx),%eax
  8014ba:	83 e0 03             	and    $0x3,%eax
  8014bd:	83 f8 01             	cmp    $0x1,%eax
  8014c0:	74 1e                	je     8014e0 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8014c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c5:	8b 40 08             	mov    0x8(%eax),%eax
  8014c8:	85 c0                	test   %eax,%eax
  8014ca:	74 35                	je     801501 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014cc:	83 ec 04             	sub    $0x4,%esp
  8014cf:	ff 75 10             	pushl  0x10(%ebp)
  8014d2:	ff 75 0c             	pushl  0xc(%ebp)
  8014d5:	52                   	push   %edx
  8014d6:	ff d0                	call   *%eax
  8014d8:	83 c4 10             	add    $0x10,%esp
}
  8014db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014de:	c9                   	leave  
  8014df:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014e0:	a1 04 40 80 00       	mov    0x804004,%eax
  8014e5:	8b 40 48             	mov    0x48(%eax),%eax
  8014e8:	83 ec 04             	sub    $0x4,%esp
  8014eb:	53                   	push   %ebx
  8014ec:	50                   	push   %eax
  8014ed:	68 e5 26 80 00       	push   $0x8026e5
  8014f2:	e8 dc ec ff ff       	call   8001d3 <cprintf>
		return -E_INVAL;
  8014f7:	83 c4 10             	add    $0x10,%esp
  8014fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014ff:	eb da                	jmp    8014db <read+0x5e>
		return -E_NOT_SUPP;
  801501:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801506:	eb d3                	jmp    8014db <read+0x5e>

00801508 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801508:	f3 0f 1e fb          	endbr32 
  80150c:	55                   	push   %ebp
  80150d:	89 e5                	mov    %esp,%ebp
  80150f:	57                   	push   %edi
  801510:	56                   	push   %esi
  801511:	53                   	push   %ebx
  801512:	83 ec 0c             	sub    $0xc,%esp
  801515:	8b 7d 08             	mov    0x8(%ebp),%edi
  801518:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80151b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801520:	eb 02                	jmp    801524 <readn+0x1c>
  801522:	01 c3                	add    %eax,%ebx
  801524:	39 f3                	cmp    %esi,%ebx
  801526:	73 21                	jae    801549 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801528:	83 ec 04             	sub    $0x4,%esp
  80152b:	89 f0                	mov    %esi,%eax
  80152d:	29 d8                	sub    %ebx,%eax
  80152f:	50                   	push   %eax
  801530:	89 d8                	mov    %ebx,%eax
  801532:	03 45 0c             	add    0xc(%ebp),%eax
  801535:	50                   	push   %eax
  801536:	57                   	push   %edi
  801537:	e8 41 ff ff ff       	call   80147d <read>
		if (m < 0)
  80153c:	83 c4 10             	add    $0x10,%esp
  80153f:	85 c0                	test   %eax,%eax
  801541:	78 04                	js     801547 <readn+0x3f>
			return m;
		if (m == 0)
  801543:	75 dd                	jne    801522 <readn+0x1a>
  801545:	eb 02                	jmp    801549 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801547:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801549:	89 d8                	mov    %ebx,%eax
  80154b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80154e:	5b                   	pop    %ebx
  80154f:	5e                   	pop    %esi
  801550:	5f                   	pop    %edi
  801551:	5d                   	pop    %ebp
  801552:	c3                   	ret    

00801553 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801553:	f3 0f 1e fb          	endbr32 
  801557:	55                   	push   %ebp
  801558:	89 e5                	mov    %esp,%ebp
  80155a:	53                   	push   %ebx
  80155b:	83 ec 1c             	sub    $0x1c,%esp
  80155e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801561:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801564:	50                   	push   %eax
  801565:	53                   	push   %ebx
  801566:	e8 8f fc ff ff       	call   8011fa <fd_lookup>
  80156b:	83 c4 10             	add    $0x10,%esp
  80156e:	85 c0                	test   %eax,%eax
  801570:	78 3a                	js     8015ac <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801572:	83 ec 08             	sub    $0x8,%esp
  801575:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801578:	50                   	push   %eax
  801579:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80157c:	ff 30                	pushl  (%eax)
  80157e:	e8 cb fc ff ff       	call   80124e <dev_lookup>
  801583:	83 c4 10             	add    $0x10,%esp
  801586:	85 c0                	test   %eax,%eax
  801588:	78 22                	js     8015ac <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80158a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801591:	74 1e                	je     8015b1 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801593:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801596:	8b 52 0c             	mov    0xc(%edx),%edx
  801599:	85 d2                	test   %edx,%edx
  80159b:	74 35                	je     8015d2 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80159d:	83 ec 04             	sub    $0x4,%esp
  8015a0:	ff 75 10             	pushl  0x10(%ebp)
  8015a3:	ff 75 0c             	pushl  0xc(%ebp)
  8015a6:	50                   	push   %eax
  8015a7:	ff d2                	call   *%edx
  8015a9:	83 c4 10             	add    $0x10,%esp
}
  8015ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015af:	c9                   	leave  
  8015b0:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015b1:	a1 04 40 80 00       	mov    0x804004,%eax
  8015b6:	8b 40 48             	mov    0x48(%eax),%eax
  8015b9:	83 ec 04             	sub    $0x4,%esp
  8015bc:	53                   	push   %ebx
  8015bd:	50                   	push   %eax
  8015be:	68 01 27 80 00       	push   $0x802701
  8015c3:	e8 0b ec ff ff       	call   8001d3 <cprintf>
		return -E_INVAL;
  8015c8:	83 c4 10             	add    $0x10,%esp
  8015cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015d0:	eb da                	jmp    8015ac <write+0x59>
		return -E_NOT_SUPP;
  8015d2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015d7:	eb d3                	jmp    8015ac <write+0x59>

008015d9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015d9:	f3 0f 1e fb          	endbr32 
  8015dd:	55                   	push   %ebp
  8015de:	89 e5                	mov    %esp,%ebp
  8015e0:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e6:	50                   	push   %eax
  8015e7:	ff 75 08             	pushl  0x8(%ebp)
  8015ea:	e8 0b fc ff ff       	call   8011fa <fd_lookup>
  8015ef:	83 c4 10             	add    $0x10,%esp
  8015f2:	85 c0                	test   %eax,%eax
  8015f4:	78 0e                	js     801604 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8015f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015fc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801604:	c9                   	leave  
  801605:	c3                   	ret    

00801606 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801606:	f3 0f 1e fb          	endbr32 
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	53                   	push   %ebx
  80160e:	83 ec 1c             	sub    $0x1c,%esp
  801611:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801614:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801617:	50                   	push   %eax
  801618:	53                   	push   %ebx
  801619:	e8 dc fb ff ff       	call   8011fa <fd_lookup>
  80161e:	83 c4 10             	add    $0x10,%esp
  801621:	85 c0                	test   %eax,%eax
  801623:	78 37                	js     80165c <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801625:	83 ec 08             	sub    $0x8,%esp
  801628:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162b:	50                   	push   %eax
  80162c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162f:	ff 30                	pushl  (%eax)
  801631:	e8 18 fc ff ff       	call   80124e <dev_lookup>
  801636:	83 c4 10             	add    $0x10,%esp
  801639:	85 c0                	test   %eax,%eax
  80163b:	78 1f                	js     80165c <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80163d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801640:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801644:	74 1b                	je     801661 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801646:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801649:	8b 52 18             	mov    0x18(%edx),%edx
  80164c:	85 d2                	test   %edx,%edx
  80164e:	74 32                	je     801682 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801650:	83 ec 08             	sub    $0x8,%esp
  801653:	ff 75 0c             	pushl  0xc(%ebp)
  801656:	50                   	push   %eax
  801657:	ff d2                	call   *%edx
  801659:	83 c4 10             	add    $0x10,%esp
}
  80165c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165f:	c9                   	leave  
  801660:	c3                   	ret    
			thisenv->env_id, fdnum);
  801661:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801666:	8b 40 48             	mov    0x48(%eax),%eax
  801669:	83 ec 04             	sub    $0x4,%esp
  80166c:	53                   	push   %ebx
  80166d:	50                   	push   %eax
  80166e:	68 c4 26 80 00       	push   $0x8026c4
  801673:	e8 5b eb ff ff       	call   8001d3 <cprintf>
		return -E_INVAL;
  801678:	83 c4 10             	add    $0x10,%esp
  80167b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801680:	eb da                	jmp    80165c <ftruncate+0x56>
		return -E_NOT_SUPP;
  801682:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801687:	eb d3                	jmp    80165c <ftruncate+0x56>

00801689 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801689:	f3 0f 1e fb          	endbr32 
  80168d:	55                   	push   %ebp
  80168e:	89 e5                	mov    %esp,%ebp
  801690:	53                   	push   %ebx
  801691:	83 ec 1c             	sub    $0x1c,%esp
  801694:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801697:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80169a:	50                   	push   %eax
  80169b:	ff 75 08             	pushl  0x8(%ebp)
  80169e:	e8 57 fb ff ff       	call   8011fa <fd_lookup>
  8016a3:	83 c4 10             	add    $0x10,%esp
  8016a6:	85 c0                	test   %eax,%eax
  8016a8:	78 4b                	js     8016f5 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016aa:	83 ec 08             	sub    $0x8,%esp
  8016ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b0:	50                   	push   %eax
  8016b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b4:	ff 30                	pushl  (%eax)
  8016b6:	e8 93 fb ff ff       	call   80124e <dev_lookup>
  8016bb:	83 c4 10             	add    $0x10,%esp
  8016be:	85 c0                	test   %eax,%eax
  8016c0:	78 33                	js     8016f5 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8016c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016c9:	74 2f                	je     8016fa <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016cb:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016ce:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016d5:	00 00 00 
	stat->st_isdir = 0;
  8016d8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016df:	00 00 00 
	stat->st_dev = dev;
  8016e2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016e8:	83 ec 08             	sub    $0x8,%esp
  8016eb:	53                   	push   %ebx
  8016ec:	ff 75 f0             	pushl  -0x10(%ebp)
  8016ef:	ff 50 14             	call   *0x14(%eax)
  8016f2:	83 c4 10             	add    $0x10,%esp
}
  8016f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f8:	c9                   	leave  
  8016f9:	c3                   	ret    
		return -E_NOT_SUPP;
  8016fa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016ff:	eb f4                	jmp    8016f5 <fstat+0x6c>

00801701 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801701:	f3 0f 1e fb          	endbr32 
  801705:	55                   	push   %ebp
  801706:	89 e5                	mov    %esp,%ebp
  801708:	56                   	push   %esi
  801709:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80170a:	83 ec 08             	sub    $0x8,%esp
  80170d:	6a 00                	push   $0x0
  80170f:	ff 75 08             	pushl  0x8(%ebp)
  801712:	e8 fb 01 00 00       	call   801912 <open>
  801717:	89 c3                	mov    %eax,%ebx
  801719:	83 c4 10             	add    $0x10,%esp
  80171c:	85 c0                	test   %eax,%eax
  80171e:	78 1b                	js     80173b <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801720:	83 ec 08             	sub    $0x8,%esp
  801723:	ff 75 0c             	pushl  0xc(%ebp)
  801726:	50                   	push   %eax
  801727:	e8 5d ff ff ff       	call   801689 <fstat>
  80172c:	89 c6                	mov    %eax,%esi
	close(fd);
  80172e:	89 1c 24             	mov    %ebx,(%esp)
  801731:	e8 fd fb ff ff       	call   801333 <close>
	return r;
  801736:	83 c4 10             	add    $0x10,%esp
  801739:	89 f3                	mov    %esi,%ebx
}
  80173b:	89 d8                	mov    %ebx,%eax
  80173d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801740:	5b                   	pop    %ebx
  801741:	5e                   	pop    %esi
  801742:	5d                   	pop    %ebp
  801743:	c3                   	ret    

00801744 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801744:	55                   	push   %ebp
  801745:	89 e5                	mov    %esp,%ebp
  801747:	56                   	push   %esi
  801748:	53                   	push   %ebx
  801749:	89 c6                	mov    %eax,%esi
  80174b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80174d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801754:	74 27                	je     80177d <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801756:	6a 07                	push   $0x7
  801758:	68 00 50 80 00       	push   $0x805000
  80175d:	56                   	push   %esi
  80175e:	ff 35 00 40 80 00    	pushl  0x804000
  801764:	e8 69 f9 ff ff       	call   8010d2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801769:	83 c4 0c             	add    $0xc,%esp
  80176c:	6a 00                	push   $0x0
  80176e:	53                   	push   %ebx
  80176f:	6a 00                	push   $0x0
  801771:	e8 05 f9 ff ff       	call   80107b <ipc_recv>
}
  801776:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801779:	5b                   	pop    %ebx
  80177a:	5e                   	pop    %esi
  80177b:	5d                   	pop    %ebp
  80177c:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80177d:	83 ec 0c             	sub    $0xc,%esp
  801780:	6a 01                	push   $0x1
  801782:	e8 b1 f9 ff ff       	call   801138 <ipc_find_env>
  801787:	a3 00 40 80 00       	mov    %eax,0x804000
  80178c:	83 c4 10             	add    $0x10,%esp
  80178f:	eb c5                	jmp    801756 <fsipc+0x12>

00801791 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801791:	f3 0f 1e fb          	endbr32 
  801795:	55                   	push   %ebp
  801796:	89 e5                	mov    %esp,%ebp
  801798:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80179b:	8b 45 08             	mov    0x8(%ebp),%eax
  80179e:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b3:	b8 02 00 00 00       	mov    $0x2,%eax
  8017b8:	e8 87 ff ff ff       	call   801744 <fsipc>
}
  8017bd:	c9                   	leave  
  8017be:	c3                   	ret    

008017bf <devfile_flush>:
{
  8017bf:	f3 0f 1e fb          	endbr32 
  8017c3:	55                   	push   %ebp
  8017c4:	89 e5                	mov    %esp,%ebp
  8017c6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cc:	8b 40 0c             	mov    0xc(%eax),%eax
  8017cf:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d9:	b8 06 00 00 00       	mov    $0x6,%eax
  8017de:	e8 61 ff ff ff       	call   801744 <fsipc>
}
  8017e3:	c9                   	leave  
  8017e4:	c3                   	ret    

008017e5 <devfile_stat>:
{
  8017e5:	f3 0f 1e fb          	endbr32 
  8017e9:	55                   	push   %ebp
  8017ea:	89 e5                	mov    %esp,%ebp
  8017ec:	53                   	push   %ebx
  8017ed:	83 ec 04             	sub    $0x4,%esp
  8017f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f6:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801803:	b8 05 00 00 00       	mov    $0x5,%eax
  801808:	e8 37 ff ff ff       	call   801744 <fsipc>
  80180d:	85 c0                	test   %eax,%eax
  80180f:	78 2c                	js     80183d <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801811:	83 ec 08             	sub    $0x8,%esp
  801814:	68 00 50 80 00       	push   $0x805000
  801819:	53                   	push   %ebx
  80181a:	e8 bd ef ff ff       	call   8007dc <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80181f:	a1 80 50 80 00       	mov    0x805080,%eax
  801824:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80182a:	a1 84 50 80 00       	mov    0x805084,%eax
  80182f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801835:	83 c4 10             	add    $0x10,%esp
  801838:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80183d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801840:	c9                   	leave  
  801841:	c3                   	ret    

00801842 <devfile_write>:
{
  801842:	f3 0f 1e fb          	endbr32 
  801846:	55                   	push   %ebp
  801847:	89 e5                	mov    %esp,%ebp
  801849:	83 ec 0c             	sub    $0xc,%esp
  80184c:	8b 45 10             	mov    0x10(%ebp),%eax
	n = n > size_max ? size_max : n;
  80184f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801854:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801859:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80185c:	8b 55 08             	mov    0x8(%ebp),%edx
  80185f:	8b 52 0c             	mov    0xc(%edx),%edx
  801862:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801868:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80186d:	50                   	push   %eax
  80186e:	ff 75 0c             	pushl  0xc(%ebp)
  801871:	68 08 50 80 00       	push   $0x805008
  801876:	e8 17 f1 ff ff       	call   800992 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80187b:	ba 00 00 00 00       	mov    $0x0,%edx
  801880:	b8 04 00 00 00       	mov    $0x4,%eax
  801885:	e8 ba fe ff ff       	call   801744 <fsipc>
}
  80188a:	c9                   	leave  
  80188b:	c3                   	ret    

0080188c <devfile_read>:
{
  80188c:	f3 0f 1e fb          	endbr32 
  801890:	55                   	push   %ebp
  801891:	89 e5                	mov    %esp,%ebp
  801893:	56                   	push   %esi
  801894:	53                   	push   %ebx
  801895:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801898:	8b 45 08             	mov    0x8(%ebp),%eax
  80189b:	8b 40 0c             	mov    0xc(%eax),%eax
  80189e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018a3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ae:	b8 03 00 00 00       	mov    $0x3,%eax
  8018b3:	e8 8c fe ff ff       	call   801744 <fsipc>
  8018b8:	89 c3                	mov    %eax,%ebx
  8018ba:	85 c0                	test   %eax,%eax
  8018bc:	78 1f                	js     8018dd <devfile_read+0x51>
	assert(r <= n);
  8018be:	39 f0                	cmp    %esi,%eax
  8018c0:	77 24                	ja     8018e6 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8018c2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018c7:	7f 33                	jg     8018fc <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018c9:	83 ec 04             	sub    $0x4,%esp
  8018cc:	50                   	push   %eax
  8018cd:	68 00 50 80 00       	push   $0x805000
  8018d2:	ff 75 0c             	pushl  0xc(%ebp)
  8018d5:	e8 b8 f0 ff ff       	call   800992 <memmove>
	return r;
  8018da:	83 c4 10             	add    $0x10,%esp
}
  8018dd:	89 d8                	mov    %ebx,%eax
  8018df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018e2:	5b                   	pop    %ebx
  8018e3:	5e                   	pop    %esi
  8018e4:	5d                   	pop    %ebp
  8018e5:	c3                   	ret    
	assert(r <= n);
  8018e6:	68 30 27 80 00       	push   $0x802730
  8018eb:	68 37 27 80 00       	push   $0x802737
  8018f0:	6a 7c                	push   $0x7c
  8018f2:	68 4c 27 80 00       	push   $0x80274c
  8018f7:	e8 be 05 00 00       	call   801eba <_panic>
	assert(r <= PGSIZE);
  8018fc:	68 57 27 80 00       	push   $0x802757
  801901:	68 37 27 80 00       	push   $0x802737
  801906:	6a 7d                	push   $0x7d
  801908:	68 4c 27 80 00       	push   $0x80274c
  80190d:	e8 a8 05 00 00       	call   801eba <_panic>

00801912 <open>:
{
  801912:	f3 0f 1e fb          	endbr32 
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
  801919:	56                   	push   %esi
  80191a:	53                   	push   %ebx
  80191b:	83 ec 1c             	sub    $0x1c,%esp
  80191e:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801921:	56                   	push   %esi
  801922:	e8 72 ee ff ff       	call   800799 <strlen>
  801927:	83 c4 10             	add    $0x10,%esp
  80192a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80192f:	7f 6c                	jg     80199d <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801931:	83 ec 0c             	sub    $0xc,%esp
  801934:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801937:	50                   	push   %eax
  801938:	e8 67 f8 ff ff       	call   8011a4 <fd_alloc>
  80193d:	89 c3                	mov    %eax,%ebx
  80193f:	83 c4 10             	add    $0x10,%esp
  801942:	85 c0                	test   %eax,%eax
  801944:	78 3c                	js     801982 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801946:	83 ec 08             	sub    $0x8,%esp
  801949:	56                   	push   %esi
  80194a:	68 00 50 80 00       	push   $0x805000
  80194f:	e8 88 ee ff ff       	call   8007dc <strcpy>
	fsipcbuf.open.req_omode = mode;
  801954:	8b 45 0c             	mov    0xc(%ebp),%eax
  801957:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80195c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80195f:	b8 01 00 00 00       	mov    $0x1,%eax
  801964:	e8 db fd ff ff       	call   801744 <fsipc>
  801969:	89 c3                	mov    %eax,%ebx
  80196b:	83 c4 10             	add    $0x10,%esp
  80196e:	85 c0                	test   %eax,%eax
  801970:	78 19                	js     80198b <open+0x79>
	return fd2num(fd);
  801972:	83 ec 0c             	sub    $0xc,%esp
  801975:	ff 75 f4             	pushl  -0xc(%ebp)
  801978:	e8 f8 f7 ff ff       	call   801175 <fd2num>
  80197d:	89 c3                	mov    %eax,%ebx
  80197f:	83 c4 10             	add    $0x10,%esp
}
  801982:	89 d8                	mov    %ebx,%eax
  801984:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801987:	5b                   	pop    %ebx
  801988:	5e                   	pop    %esi
  801989:	5d                   	pop    %ebp
  80198a:	c3                   	ret    
		fd_close(fd, 0);
  80198b:	83 ec 08             	sub    $0x8,%esp
  80198e:	6a 00                	push   $0x0
  801990:	ff 75 f4             	pushl  -0xc(%ebp)
  801993:	e8 10 f9 ff ff       	call   8012a8 <fd_close>
		return r;
  801998:	83 c4 10             	add    $0x10,%esp
  80199b:	eb e5                	jmp    801982 <open+0x70>
		return -E_BAD_PATH;
  80199d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8019a2:	eb de                	jmp    801982 <open+0x70>

008019a4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019a4:	f3 0f 1e fb          	endbr32 
  8019a8:	55                   	push   %ebp
  8019a9:	89 e5                	mov    %esp,%ebp
  8019ab:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b3:	b8 08 00 00 00       	mov    $0x8,%eax
  8019b8:	e8 87 fd ff ff       	call   801744 <fsipc>
}
  8019bd:	c9                   	leave  
  8019be:	c3                   	ret    

008019bf <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019bf:	f3 0f 1e fb          	endbr32 
  8019c3:	55                   	push   %ebp
  8019c4:	89 e5                	mov    %esp,%ebp
  8019c6:	56                   	push   %esi
  8019c7:	53                   	push   %ebx
  8019c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019cb:	83 ec 0c             	sub    $0xc,%esp
  8019ce:	ff 75 08             	pushl  0x8(%ebp)
  8019d1:	e8 b3 f7 ff ff       	call   801189 <fd2data>
  8019d6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019d8:	83 c4 08             	add    $0x8,%esp
  8019db:	68 63 27 80 00       	push   $0x802763
  8019e0:	53                   	push   %ebx
  8019e1:	e8 f6 ed ff ff       	call   8007dc <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019e6:	8b 46 04             	mov    0x4(%esi),%eax
  8019e9:	2b 06                	sub    (%esi),%eax
  8019eb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019f1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019f8:	00 00 00 
	stat->st_dev = &devpipe;
  8019fb:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a02:	30 80 00 
	return 0;
}
  801a05:	b8 00 00 00 00       	mov    $0x0,%eax
  801a0a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a0d:	5b                   	pop    %ebx
  801a0e:	5e                   	pop    %esi
  801a0f:	5d                   	pop    %ebp
  801a10:	c3                   	ret    

00801a11 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a11:	f3 0f 1e fb          	endbr32 
  801a15:	55                   	push   %ebp
  801a16:	89 e5                	mov    %esp,%ebp
  801a18:	53                   	push   %ebx
  801a19:	83 ec 0c             	sub    $0xc,%esp
  801a1c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a1f:	53                   	push   %ebx
  801a20:	6a 00                	push   $0x0
  801a22:	e8 84 f2 ff ff       	call   800cab <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a27:	89 1c 24             	mov    %ebx,(%esp)
  801a2a:	e8 5a f7 ff ff       	call   801189 <fd2data>
  801a2f:	83 c4 08             	add    $0x8,%esp
  801a32:	50                   	push   %eax
  801a33:	6a 00                	push   $0x0
  801a35:	e8 71 f2 ff ff       	call   800cab <sys_page_unmap>
}
  801a3a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a3d:	c9                   	leave  
  801a3e:	c3                   	ret    

00801a3f <_pipeisclosed>:
{
  801a3f:	55                   	push   %ebp
  801a40:	89 e5                	mov    %esp,%ebp
  801a42:	57                   	push   %edi
  801a43:	56                   	push   %esi
  801a44:	53                   	push   %ebx
  801a45:	83 ec 1c             	sub    $0x1c,%esp
  801a48:	89 c7                	mov    %eax,%edi
  801a4a:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801a4c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a51:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a54:	83 ec 0c             	sub    $0xc,%esp
  801a57:	57                   	push   %edi
  801a58:	e8 4d 05 00 00       	call   801faa <pageref>
  801a5d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a60:	89 34 24             	mov    %esi,(%esp)
  801a63:	e8 42 05 00 00       	call   801faa <pageref>
		nn = thisenv->env_runs;
  801a68:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a6e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a71:	83 c4 10             	add    $0x10,%esp
  801a74:	39 cb                	cmp    %ecx,%ebx
  801a76:	74 1b                	je     801a93 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801a78:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a7b:	75 cf                	jne    801a4c <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a7d:	8b 42 58             	mov    0x58(%edx),%eax
  801a80:	6a 01                	push   $0x1
  801a82:	50                   	push   %eax
  801a83:	53                   	push   %ebx
  801a84:	68 6a 27 80 00       	push   $0x80276a
  801a89:	e8 45 e7 ff ff       	call   8001d3 <cprintf>
  801a8e:	83 c4 10             	add    $0x10,%esp
  801a91:	eb b9                	jmp    801a4c <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801a93:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a96:	0f 94 c0             	sete   %al
  801a99:	0f b6 c0             	movzbl %al,%eax
}
  801a9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a9f:	5b                   	pop    %ebx
  801aa0:	5e                   	pop    %esi
  801aa1:	5f                   	pop    %edi
  801aa2:	5d                   	pop    %ebp
  801aa3:	c3                   	ret    

00801aa4 <devpipe_write>:
{
  801aa4:	f3 0f 1e fb          	endbr32 
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
  801aab:	57                   	push   %edi
  801aac:	56                   	push   %esi
  801aad:	53                   	push   %ebx
  801aae:	83 ec 28             	sub    $0x28,%esp
  801ab1:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801ab4:	56                   	push   %esi
  801ab5:	e8 cf f6 ff ff       	call   801189 <fd2data>
  801aba:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801abc:	83 c4 10             	add    $0x10,%esp
  801abf:	bf 00 00 00 00       	mov    $0x0,%edi
  801ac4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ac7:	74 4f                	je     801b18 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ac9:	8b 43 04             	mov    0x4(%ebx),%eax
  801acc:	8b 0b                	mov    (%ebx),%ecx
  801ace:	8d 51 20             	lea    0x20(%ecx),%edx
  801ad1:	39 d0                	cmp    %edx,%eax
  801ad3:	72 14                	jb     801ae9 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801ad5:	89 da                	mov    %ebx,%edx
  801ad7:	89 f0                	mov    %esi,%eax
  801ad9:	e8 61 ff ff ff       	call   801a3f <_pipeisclosed>
  801ade:	85 c0                	test   %eax,%eax
  801ae0:	75 3b                	jne    801b1d <devpipe_write+0x79>
			sys_yield();
  801ae2:	e8 14 f1 ff ff       	call   800bfb <sys_yield>
  801ae7:	eb e0                	jmp    801ac9 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ae9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aec:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801af0:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801af3:	89 c2                	mov    %eax,%edx
  801af5:	c1 fa 1f             	sar    $0x1f,%edx
  801af8:	89 d1                	mov    %edx,%ecx
  801afa:	c1 e9 1b             	shr    $0x1b,%ecx
  801afd:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b00:	83 e2 1f             	and    $0x1f,%edx
  801b03:	29 ca                	sub    %ecx,%edx
  801b05:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b09:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b0d:	83 c0 01             	add    $0x1,%eax
  801b10:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801b13:	83 c7 01             	add    $0x1,%edi
  801b16:	eb ac                	jmp    801ac4 <devpipe_write+0x20>
	return i;
  801b18:	8b 45 10             	mov    0x10(%ebp),%eax
  801b1b:	eb 05                	jmp    801b22 <devpipe_write+0x7e>
				return 0;
  801b1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b25:	5b                   	pop    %ebx
  801b26:	5e                   	pop    %esi
  801b27:	5f                   	pop    %edi
  801b28:	5d                   	pop    %ebp
  801b29:	c3                   	ret    

00801b2a <devpipe_read>:
{
  801b2a:	f3 0f 1e fb          	endbr32 
  801b2e:	55                   	push   %ebp
  801b2f:	89 e5                	mov    %esp,%ebp
  801b31:	57                   	push   %edi
  801b32:	56                   	push   %esi
  801b33:	53                   	push   %ebx
  801b34:	83 ec 18             	sub    $0x18,%esp
  801b37:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801b3a:	57                   	push   %edi
  801b3b:	e8 49 f6 ff ff       	call   801189 <fd2data>
  801b40:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b42:	83 c4 10             	add    $0x10,%esp
  801b45:	be 00 00 00 00       	mov    $0x0,%esi
  801b4a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b4d:	75 14                	jne    801b63 <devpipe_read+0x39>
	return i;
  801b4f:	8b 45 10             	mov    0x10(%ebp),%eax
  801b52:	eb 02                	jmp    801b56 <devpipe_read+0x2c>
				return i;
  801b54:	89 f0                	mov    %esi,%eax
}
  801b56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b59:	5b                   	pop    %ebx
  801b5a:	5e                   	pop    %esi
  801b5b:	5f                   	pop    %edi
  801b5c:	5d                   	pop    %ebp
  801b5d:	c3                   	ret    
			sys_yield();
  801b5e:	e8 98 f0 ff ff       	call   800bfb <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801b63:	8b 03                	mov    (%ebx),%eax
  801b65:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b68:	75 18                	jne    801b82 <devpipe_read+0x58>
			if (i > 0)
  801b6a:	85 f6                	test   %esi,%esi
  801b6c:	75 e6                	jne    801b54 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801b6e:	89 da                	mov    %ebx,%edx
  801b70:	89 f8                	mov    %edi,%eax
  801b72:	e8 c8 fe ff ff       	call   801a3f <_pipeisclosed>
  801b77:	85 c0                	test   %eax,%eax
  801b79:	74 e3                	je     801b5e <devpipe_read+0x34>
				return 0;
  801b7b:	b8 00 00 00 00       	mov    $0x0,%eax
  801b80:	eb d4                	jmp    801b56 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b82:	99                   	cltd   
  801b83:	c1 ea 1b             	shr    $0x1b,%edx
  801b86:	01 d0                	add    %edx,%eax
  801b88:	83 e0 1f             	and    $0x1f,%eax
  801b8b:	29 d0                	sub    %edx,%eax
  801b8d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801b92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b95:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801b98:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801b9b:	83 c6 01             	add    $0x1,%esi
  801b9e:	eb aa                	jmp    801b4a <devpipe_read+0x20>

00801ba0 <pipe>:
{
  801ba0:	f3 0f 1e fb          	endbr32 
  801ba4:	55                   	push   %ebp
  801ba5:	89 e5                	mov    %esp,%ebp
  801ba7:	56                   	push   %esi
  801ba8:	53                   	push   %ebx
  801ba9:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801bac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801baf:	50                   	push   %eax
  801bb0:	e8 ef f5 ff ff       	call   8011a4 <fd_alloc>
  801bb5:	89 c3                	mov    %eax,%ebx
  801bb7:	83 c4 10             	add    $0x10,%esp
  801bba:	85 c0                	test   %eax,%eax
  801bbc:	0f 88 23 01 00 00    	js     801ce5 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc2:	83 ec 04             	sub    $0x4,%esp
  801bc5:	68 07 04 00 00       	push   $0x407
  801bca:	ff 75 f4             	pushl  -0xc(%ebp)
  801bcd:	6a 00                	push   $0x0
  801bcf:	e8 4a f0 ff ff       	call   800c1e <sys_page_alloc>
  801bd4:	89 c3                	mov    %eax,%ebx
  801bd6:	83 c4 10             	add    $0x10,%esp
  801bd9:	85 c0                	test   %eax,%eax
  801bdb:	0f 88 04 01 00 00    	js     801ce5 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801be1:	83 ec 0c             	sub    $0xc,%esp
  801be4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801be7:	50                   	push   %eax
  801be8:	e8 b7 f5 ff ff       	call   8011a4 <fd_alloc>
  801bed:	89 c3                	mov    %eax,%ebx
  801bef:	83 c4 10             	add    $0x10,%esp
  801bf2:	85 c0                	test   %eax,%eax
  801bf4:	0f 88 db 00 00 00    	js     801cd5 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bfa:	83 ec 04             	sub    $0x4,%esp
  801bfd:	68 07 04 00 00       	push   $0x407
  801c02:	ff 75 f0             	pushl  -0x10(%ebp)
  801c05:	6a 00                	push   $0x0
  801c07:	e8 12 f0 ff ff       	call   800c1e <sys_page_alloc>
  801c0c:	89 c3                	mov    %eax,%ebx
  801c0e:	83 c4 10             	add    $0x10,%esp
  801c11:	85 c0                	test   %eax,%eax
  801c13:	0f 88 bc 00 00 00    	js     801cd5 <pipe+0x135>
	va = fd2data(fd0);
  801c19:	83 ec 0c             	sub    $0xc,%esp
  801c1c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c1f:	e8 65 f5 ff ff       	call   801189 <fd2data>
  801c24:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c26:	83 c4 0c             	add    $0xc,%esp
  801c29:	68 07 04 00 00       	push   $0x407
  801c2e:	50                   	push   %eax
  801c2f:	6a 00                	push   $0x0
  801c31:	e8 e8 ef ff ff       	call   800c1e <sys_page_alloc>
  801c36:	89 c3                	mov    %eax,%ebx
  801c38:	83 c4 10             	add    $0x10,%esp
  801c3b:	85 c0                	test   %eax,%eax
  801c3d:	0f 88 82 00 00 00    	js     801cc5 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c43:	83 ec 0c             	sub    $0xc,%esp
  801c46:	ff 75 f0             	pushl  -0x10(%ebp)
  801c49:	e8 3b f5 ff ff       	call   801189 <fd2data>
  801c4e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c55:	50                   	push   %eax
  801c56:	6a 00                	push   $0x0
  801c58:	56                   	push   %esi
  801c59:	6a 00                	push   $0x0
  801c5b:	e8 05 f0 ff ff       	call   800c65 <sys_page_map>
  801c60:	89 c3                	mov    %eax,%ebx
  801c62:	83 c4 20             	add    $0x20,%esp
  801c65:	85 c0                	test   %eax,%eax
  801c67:	78 4e                	js     801cb7 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801c69:	a1 20 30 80 00       	mov    0x803020,%eax
  801c6e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c71:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801c73:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c76:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801c7d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c80:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801c82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c85:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801c8c:	83 ec 0c             	sub    $0xc,%esp
  801c8f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c92:	e8 de f4 ff ff       	call   801175 <fd2num>
  801c97:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c9a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c9c:	83 c4 04             	add    $0x4,%esp
  801c9f:	ff 75 f0             	pushl  -0x10(%ebp)
  801ca2:	e8 ce f4 ff ff       	call   801175 <fd2num>
  801ca7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801caa:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cad:	83 c4 10             	add    $0x10,%esp
  801cb0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cb5:	eb 2e                	jmp    801ce5 <pipe+0x145>
	sys_page_unmap(0, va);
  801cb7:	83 ec 08             	sub    $0x8,%esp
  801cba:	56                   	push   %esi
  801cbb:	6a 00                	push   $0x0
  801cbd:	e8 e9 ef ff ff       	call   800cab <sys_page_unmap>
  801cc2:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801cc5:	83 ec 08             	sub    $0x8,%esp
  801cc8:	ff 75 f0             	pushl  -0x10(%ebp)
  801ccb:	6a 00                	push   $0x0
  801ccd:	e8 d9 ef ff ff       	call   800cab <sys_page_unmap>
  801cd2:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801cd5:	83 ec 08             	sub    $0x8,%esp
  801cd8:	ff 75 f4             	pushl  -0xc(%ebp)
  801cdb:	6a 00                	push   $0x0
  801cdd:	e8 c9 ef ff ff       	call   800cab <sys_page_unmap>
  801ce2:	83 c4 10             	add    $0x10,%esp
}
  801ce5:	89 d8                	mov    %ebx,%eax
  801ce7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cea:	5b                   	pop    %ebx
  801ceb:	5e                   	pop    %esi
  801cec:	5d                   	pop    %ebp
  801ced:	c3                   	ret    

00801cee <pipeisclosed>:
{
  801cee:	f3 0f 1e fb          	endbr32 
  801cf2:	55                   	push   %ebp
  801cf3:	89 e5                	mov    %esp,%ebp
  801cf5:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cf8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cfb:	50                   	push   %eax
  801cfc:	ff 75 08             	pushl  0x8(%ebp)
  801cff:	e8 f6 f4 ff ff       	call   8011fa <fd_lookup>
  801d04:	83 c4 10             	add    $0x10,%esp
  801d07:	85 c0                	test   %eax,%eax
  801d09:	78 18                	js     801d23 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801d0b:	83 ec 0c             	sub    $0xc,%esp
  801d0e:	ff 75 f4             	pushl  -0xc(%ebp)
  801d11:	e8 73 f4 ff ff       	call   801189 <fd2data>
  801d16:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1b:	e8 1f fd ff ff       	call   801a3f <_pipeisclosed>
  801d20:	83 c4 10             	add    $0x10,%esp
}
  801d23:	c9                   	leave  
  801d24:	c3                   	ret    

00801d25 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d25:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801d29:	b8 00 00 00 00       	mov    $0x0,%eax
  801d2e:	c3                   	ret    

00801d2f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d2f:	f3 0f 1e fb          	endbr32 
  801d33:	55                   	push   %ebp
  801d34:	89 e5                	mov    %esp,%ebp
  801d36:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d39:	68 82 27 80 00       	push   $0x802782
  801d3e:	ff 75 0c             	pushl  0xc(%ebp)
  801d41:	e8 96 ea ff ff       	call   8007dc <strcpy>
	return 0;
}
  801d46:	b8 00 00 00 00       	mov    $0x0,%eax
  801d4b:	c9                   	leave  
  801d4c:	c3                   	ret    

00801d4d <devcons_write>:
{
  801d4d:	f3 0f 1e fb          	endbr32 
  801d51:	55                   	push   %ebp
  801d52:	89 e5                	mov    %esp,%ebp
  801d54:	57                   	push   %edi
  801d55:	56                   	push   %esi
  801d56:	53                   	push   %ebx
  801d57:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801d5d:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801d62:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801d68:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d6b:	73 31                	jae    801d9e <devcons_write+0x51>
		m = n - tot;
  801d6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d70:	29 f3                	sub    %esi,%ebx
  801d72:	83 fb 7f             	cmp    $0x7f,%ebx
  801d75:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801d7a:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d7d:	83 ec 04             	sub    $0x4,%esp
  801d80:	53                   	push   %ebx
  801d81:	89 f0                	mov    %esi,%eax
  801d83:	03 45 0c             	add    0xc(%ebp),%eax
  801d86:	50                   	push   %eax
  801d87:	57                   	push   %edi
  801d88:	e8 05 ec ff ff       	call   800992 <memmove>
		sys_cputs(buf, m);
  801d8d:	83 c4 08             	add    $0x8,%esp
  801d90:	53                   	push   %ebx
  801d91:	57                   	push   %edi
  801d92:	e8 b7 ed ff ff       	call   800b4e <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801d97:	01 de                	add    %ebx,%esi
  801d99:	83 c4 10             	add    $0x10,%esp
  801d9c:	eb ca                	jmp    801d68 <devcons_write+0x1b>
}
  801d9e:	89 f0                	mov    %esi,%eax
  801da0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801da3:	5b                   	pop    %ebx
  801da4:	5e                   	pop    %esi
  801da5:	5f                   	pop    %edi
  801da6:	5d                   	pop    %ebp
  801da7:	c3                   	ret    

00801da8 <devcons_read>:
{
  801da8:	f3 0f 1e fb          	endbr32 
  801dac:	55                   	push   %ebp
  801dad:	89 e5                	mov    %esp,%ebp
  801daf:	83 ec 08             	sub    $0x8,%esp
  801db2:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801db7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dbb:	74 21                	je     801dde <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801dbd:	e8 ae ed ff ff       	call   800b70 <sys_cgetc>
  801dc2:	85 c0                	test   %eax,%eax
  801dc4:	75 07                	jne    801dcd <devcons_read+0x25>
		sys_yield();
  801dc6:	e8 30 ee ff ff       	call   800bfb <sys_yield>
  801dcb:	eb f0                	jmp    801dbd <devcons_read+0x15>
	if (c < 0)
  801dcd:	78 0f                	js     801dde <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801dcf:	83 f8 04             	cmp    $0x4,%eax
  801dd2:	74 0c                	je     801de0 <devcons_read+0x38>
	*(char*)vbuf = c;
  801dd4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dd7:	88 02                	mov    %al,(%edx)
	return 1;
  801dd9:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801dde:	c9                   	leave  
  801ddf:	c3                   	ret    
		return 0;
  801de0:	b8 00 00 00 00       	mov    $0x0,%eax
  801de5:	eb f7                	jmp    801dde <devcons_read+0x36>

00801de7 <cputchar>:
{
  801de7:	f3 0f 1e fb          	endbr32 
  801deb:	55                   	push   %ebp
  801dec:	89 e5                	mov    %esp,%ebp
  801dee:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801df1:	8b 45 08             	mov    0x8(%ebp),%eax
  801df4:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801df7:	6a 01                	push   $0x1
  801df9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dfc:	50                   	push   %eax
  801dfd:	e8 4c ed ff ff       	call   800b4e <sys_cputs>
}
  801e02:	83 c4 10             	add    $0x10,%esp
  801e05:	c9                   	leave  
  801e06:	c3                   	ret    

00801e07 <getchar>:
{
  801e07:	f3 0f 1e fb          	endbr32 
  801e0b:	55                   	push   %ebp
  801e0c:	89 e5                	mov    %esp,%ebp
  801e0e:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801e11:	6a 01                	push   $0x1
  801e13:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e16:	50                   	push   %eax
  801e17:	6a 00                	push   $0x0
  801e19:	e8 5f f6 ff ff       	call   80147d <read>
	if (r < 0)
  801e1e:	83 c4 10             	add    $0x10,%esp
  801e21:	85 c0                	test   %eax,%eax
  801e23:	78 06                	js     801e2b <getchar+0x24>
	if (r < 1)
  801e25:	74 06                	je     801e2d <getchar+0x26>
	return c;
  801e27:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801e2b:	c9                   	leave  
  801e2c:	c3                   	ret    
		return -E_EOF;
  801e2d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801e32:	eb f7                	jmp    801e2b <getchar+0x24>

00801e34 <iscons>:
{
  801e34:	f3 0f 1e fb          	endbr32 
  801e38:	55                   	push   %ebp
  801e39:	89 e5                	mov    %esp,%ebp
  801e3b:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e3e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e41:	50                   	push   %eax
  801e42:	ff 75 08             	pushl  0x8(%ebp)
  801e45:	e8 b0 f3 ff ff       	call   8011fa <fd_lookup>
  801e4a:	83 c4 10             	add    $0x10,%esp
  801e4d:	85 c0                	test   %eax,%eax
  801e4f:	78 11                	js     801e62 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801e51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e54:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e5a:	39 10                	cmp    %edx,(%eax)
  801e5c:	0f 94 c0             	sete   %al
  801e5f:	0f b6 c0             	movzbl %al,%eax
}
  801e62:	c9                   	leave  
  801e63:	c3                   	ret    

00801e64 <opencons>:
{
  801e64:	f3 0f 1e fb          	endbr32 
  801e68:	55                   	push   %ebp
  801e69:	89 e5                	mov    %esp,%ebp
  801e6b:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801e6e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e71:	50                   	push   %eax
  801e72:	e8 2d f3 ff ff       	call   8011a4 <fd_alloc>
  801e77:	83 c4 10             	add    $0x10,%esp
  801e7a:	85 c0                	test   %eax,%eax
  801e7c:	78 3a                	js     801eb8 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e7e:	83 ec 04             	sub    $0x4,%esp
  801e81:	68 07 04 00 00       	push   $0x407
  801e86:	ff 75 f4             	pushl  -0xc(%ebp)
  801e89:	6a 00                	push   $0x0
  801e8b:	e8 8e ed ff ff       	call   800c1e <sys_page_alloc>
  801e90:	83 c4 10             	add    $0x10,%esp
  801e93:	85 c0                	test   %eax,%eax
  801e95:	78 21                	js     801eb8 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801e97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e9a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ea0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ea2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801eac:	83 ec 0c             	sub    $0xc,%esp
  801eaf:	50                   	push   %eax
  801eb0:	e8 c0 f2 ff ff       	call   801175 <fd2num>
  801eb5:	83 c4 10             	add    $0x10,%esp
}
  801eb8:	c9                   	leave  
  801eb9:	c3                   	ret    

00801eba <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801eba:	f3 0f 1e fb          	endbr32 
  801ebe:	55                   	push   %ebp
  801ebf:	89 e5                	mov    %esp,%ebp
  801ec1:	56                   	push   %esi
  801ec2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ec3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ec6:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ecc:	e8 07 ed ff ff       	call   800bd8 <sys_getenvid>
  801ed1:	83 ec 0c             	sub    $0xc,%esp
  801ed4:	ff 75 0c             	pushl  0xc(%ebp)
  801ed7:	ff 75 08             	pushl  0x8(%ebp)
  801eda:	56                   	push   %esi
  801edb:	50                   	push   %eax
  801edc:	68 90 27 80 00       	push   $0x802790
  801ee1:	e8 ed e2 ff ff       	call   8001d3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ee6:	83 c4 18             	add    $0x18,%esp
  801ee9:	53                   	push   %ebx
  801eea:	ff 75 10             	pushl  0x10(%ebp)
  801eed:	e8 8c e2 ff ff       	call   80017e <vcprintf>
	cprintf("\n");
  801ef2:	c7 04 24 c0 27 80 00 	movl   $0x8027c0,(%esp)
  801ef9:	e8 d5 e2 ff ff       	call   8001d3 <cprintf>
  801efe:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f01:	cc                   	int3   
  801f02:	eb fd                	jmp    801f01 <_panic+0x47>

00801f04 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f04:	f3 0f 1e fb          	endbr32 
  801f08:	55                   	push   %ebp
  801f09:	89 e5                	mov    %esp,%ebp
  801f0b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f0e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f15:	74 0a                	je     801f21 <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f17:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1a:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f1f:	c9                   	leave  
  801f20:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  801f21:	83 ec 0c             	sub    $0xc,%esp
  801f24:	68 b3 27 80 00       	push   $0x8027b3
  801f29:	e8 a5 e2 ff ff       	call   8001d3 <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  801f2e:	83 c4 0c             	add    $0xc,%esp
  801f31:	6a 07                	push   $0x7
  801f33:	68 00 f0 bf ee       	push   $0xeebff000
  801f38:	6a 00                	push   $0x0
  801f3a:	e8 df ec ff ff       	call   800c1e <sys_page_alloc>
  801f3f:	83 c4 10             	add    $0x10,%esp
  801f42:	85 c0                	test   %eax,%eax
  801f44:	78 2a                	js     801f70 <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  801f46:	83 ec 08             	sub    $0x8,%esp
  801f49:	68 84 1f 80 00       	push   $0x801f84
  801f4e:	6a 00                	push   $0x0
  801f50:	e8 28 ee ff ff       	call   800d7d <sys_env_set_pgfault_upcall>
  801f55:	83 c4 10             	add    $0x10,%esp
  801f58:	85 c0                	test   %eax,%eax
  801f5a:	79 bb                	jns    801f17 <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  801f5c:	83 ec 04             	sub    $0x4,%esp
  801f5f:	68 f0 27 80 00       	push   $0x8027f0
  801f64:	6a 25                	push   $0x25
  801f66:	68 e0 27 80 00       	push   $0x8027e0
  801f6b:	e8 4a ff ff ff       	call   801eba <_panic>
            panic("Allocation of UXSTACK failed!");
  801f70:	83 ec 04             	sub    $0x4,%esp
  801f73:	68 c2 27 80 00       	push   $0x8027c2
  801f78:	6a 22                	push   $0x22
  801f7a:	68 e0 27 80 00       	push   $0x8027e0
  801f7f:	e8 36 ff ff ff       	call   801eba <_panic>

00801f84 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f84:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f85:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f8a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f8c:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  801f8f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  801f93:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  801f97:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  801f9a:	83 c4 08             	add    $0x8,%esp
    popa
  801f9d:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

    add $0x4, %esp
  801f9e:	83 c4 04             	add    $0x4,%esp
    popf
  801fa1:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  801fa2:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  801fa5:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  801fa9:	c3                   	ret    

00801faa <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801faa:	f3 0f 1e fb          	endbr32 
  801fae:	55                   	push   %ebp
  801faf:	89 e5                	mov    %esp,%ebp
  801fb1:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fb4:	89 c2                	mov    %eax,%edx
  801fb6:	c1 ea 16             	shr    $0x16,%edx
  801fb9:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801fc0:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801fc5:	f6 c1 01             	test   $0x1,%cl
  801fc8:	74 1c                	je     801fe6 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801fca:	c1 e8 0c             	shr    $0xc,%eax
  801fcd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801fd4:	a8 01                	test   $0x1,%al
  801fd6:	74 0e                	je     801fe6 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fd8:	c1 e8 0c             	shr    $0xc,%eax
  801fdb:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801fe2:	ef 
  801fe3:	0f b7 d2             	movzwl %dx,%edx
}
  801fe6:	89 d0                	mov    %edx,%eax
  801fe8:	5d                   	pop    %ebp
  801fe9:	c3                   	ret    
  801fea:	66 90                	xchg   %ax,%ax
  801fec:	66 90                	xchg   %ax,%ax
  801fee:	66 90                	xchg   %ax,%ax

00801ff0 <__udivdi3>:
  801ff0:	f3 0f 1e fb          	endbr32 
  801ff4:	55                   	push   %ebp
  801ff5:	57                   	push   %edi
  801ff6:	56                   	push   %esi
  801ff7:	53                   	push   %ebx
  801ff8:	83 ec 1c             	sub    $0x1c,%esp
  801ffb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801fff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802003:	8b 74 24 34          	mov    0x34(%esp),%esi
  802007:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80200b:	85 d2                	test   %edx,%edx
  80200d:	75 19                	jne    802028 <__udivdi3+0x38>
  80200f:	39 f3                	cmp    %esi,%ebx
  802011:	76 4d                	jbe    802060 <__udivdi3+0x70>
  802013:	31 ff                	xor    %edi,%edi
  802015:	89 e8                	mov    %ebp,%eax
  802017:	89 f2                	mov    %esi,%edx
  802019:	f7 f3                	div    %ebx
  80201b:	89 fa                	mov    %edi,%edx
  80201d:	83 c4 1c             	add    $0x1c,%esp
  802020:	5b                   	pop    %ebx
  802021:	5e                   	pop    %esi
  802022:	5f                   	pop    %edi
  802023:	5d                   	pop    %ebp
  802024:	c3                   	ret    
  802025:	8d 76 00             	lea    0x0(%esi),%esi
  802028:	39 f2                	cmp    %esi,%edx
  80202a:	76 14                	jbe    802040 <__udivdi3+0x50>
  80202c:	31 ff                	xor    %edi,%edi
  80202e:	31 c0                	xor    %eax,%eax
  802030:	89 fa                	mov    %edi,%edx
  802032:	83 c4 1c             	add    $0x1c,%esp
  802035:	5b                   	pop    %ebx
  802036:	5e                   	pop    %esi
  802037:	5f                   	pop    %edi
  802038:	5d                   	pop    %ebp
  802039:	c3                   	ret    
  80203a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802040:	0f bd fa             	bsr    %edx,%edi
  802043:	83 f7 1f             	xor    $0x1f,%edi
  802046:	75 48                	jne    802090 <__udivdi3+0xa0>
  802048:	39 f2                	cmp    %esi,%edx
  80204a:	72 06                	jb     802052 <__udivdi3+0x62>
  80204c:	31 c0                	xor    %eax,%eax
  80204e:	39 eb                	cmp    %ebp,%ebx
  802050:	77 de                	ja     802030 <__udivdi3+0x40>
  802052:	b8 01 00 00 00       	mov    $0x1,%eax
  802057:	eb d7                	jmp    802030 <__udivdi3+0x40>
  802059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802060:	89 d9                	mov    %ebx,%ecx
  802062:	85 db                	test   %ebx,%ebx
  802064:	75 0b                	jne    802071 <__udivdi3+0x81>
  802066:	b8 01 00 00 00       	mov    $0x1,%eax
  80206b:	31 d2                	xor    %edx,%edx
  80206d:	f7 f3                	div    %ebx
  80206f:	89 c1                	mov    %eax,%ecx
  802071:	31 d2                	xor    %edx,%edx
  802073:	89 f0                	mov    %esi,%eax
  802075:	f7 f1                	div    %ecx
  802077:	89 c6                	mov    %eax,%esi
  802079:	89 e8                	mov    %ebp,%eax
  80207b:	89 f7                	mov    %esi,%edi
  80207d:	f7 f1                	div    %ecx
  80207f:	89 fa                	mov    %edi,%edx
  802081:	83 c4 1c             	add    $0x1c,%esp
  802084:	5b                   	pop    %ebx
  802085:	5e                   	pop    %esi
  802086:	5f                   	pop    %edi
  802087:	5d                   	pop    %ebp
  802088:	c3                   	ret    
  802089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802090:	89 f9                	mov    %edi,%ecx
  802092:	b8 20 00 00 00       	mov    $0x20,%eax
  802097:	29 f8                	sub    %edi,%eax
  802099:	d3 e2                	shl    %cl,%edx
  80209b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80209f:	89 c1                	mov    %eax,%ecx
  8020a1:	89 da                	mov    %ebx,%edx
  8020a3:	d3 ea                	shr    %cl,%edx
  8020a5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8020a9:	09 d1                	or     %edx,%ecx
  8020ab:	89 f2                	mov    %esi,%edx
  8020ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020b1:	89 f9                	mov    %edi,%ecx
  8020b3:	d3 e3                	shl    %cl,%ebx
  8020b5:	89 c1                	mov    %eax,%ecx
  8020b7:	d3 ea                	shr    %cl,%edx
  8020b9:	89 f9                	mov    %edi,%ecx
  8020bb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8020bf:	89 eb                	mov    %ebp,%ebx
  8020c1:	d3 e6                	shl    %cl,%esi
  8020c3:	89 c1                	mov    %eax,%ecx
  8020c5:	d3 eb                	shr    %cl,%ebx
  8020c7:	09 de                	or     %ebx,%esi
  8020c9:	89 f0                	mov    %esi,%eax
  8020cb:	f7 74 24 08          	divl   0x8(%esp)
  8020cf:	89 d6                	mov    %edx,%esi
  8020d1:	89 c3                	mov    %eax,%ebx
  8020d3:	f7 64 24 0c          	mull   0xc(%esp)
  8020d7:	39 d6                	cmp    %edx,%esi
  8020d9:	72 15                	jb     8020f0 <__udivdi3+0x100>
  8020db:	89 f9                	mov    %edi,%ecx
  8020dd:	d3 e5                	shl    %cl,%ebp
  8020df:	39 c5                	cmp    %eax,%ebp
  8020e1:	73 04                	jae    8020e7 <__udivdi3+0xf7>
  8020e3:	39 d6                	cmp    %edx,%esi
  8020e5:	74 09                	je     8020f0 <__udivdi3+0x100>
  8020e7:	89 d8                	mov    %ebx,%eax
  8020e9:	31 ff                	xor    %edi,%edi
  8020eb:	e9 40 ff ff ff       	jmp    802030 <__udivdi3+0x40>
  8020f0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8020f3:	31 ff                	xor    %edi,%edi
  8020f5:	e9 36 ff ff ff       	jmp    802030 <__udivdi3+0x40>
  8020fa:	66 90                	xchg   %ax,%ax
  8020fc:	66 90                	xchg   %ax,%ax
  8020fe:	66 90                	xchg   %ax,%ax

00802100 <__umoddi3>:
  802100:	f3 0f 1e fb          	endbr32 
  802104:	55                   	push   %ebp
  802105:	57                   	push   %edi
  802106:	56                   	push   %esi
  802107:	53                   	push   %ebx
  802108:	83 ec 1c             	sub    $0x1c,%esp
  80210b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80210f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802113:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802117:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80211b:	85 c0                	test   %eax,%eax
  80211d:	75 19                	jne    802138 <__umoddi3+0x38>
  80211f:	39 df                	cmp    %ebx,%edi
  802121:	76 5d                	jbe    802180 <__umoddi3+0x80>
  802123:	89 f0                	mov    %esi,%eax
  802125:	89 da                	mov    %ebx,%edx
  802127:	f7 f7                	div    %edi
  802129:	89 d0                	mov    %edx,%eax
  80212b:	31 d2                	xor    %edx,%edx
  80212d:	83 c4 1c             	add    $0x1c,%esp
  802130:	5b                   	pop    %ebx
  802131:	5e                   	pop    %esi
  802132:	5f                   	pop    %edi
  802133:	5d                   	pop    %ebp
  802134:	c3                   	ret    
  802135:	8d 76 00             	lea    0x0(%esi),%esi
  802138:	89 f2                	mov    %esi,%edx
  80213a:	39 d8                	cmp    %ebx,%eax
  80213c:	76 12                	jbe    802150 <__umoddi3+0x50>
  80213e:	89 f0                	mov    %esi,%eax
  802140:	89 da                	mov    %ebx,%edx
  802142:	83 c4 1c             	add    $0x1c,%esp
  802145:	5b                   	pop    %ebx
  802146:	5e                   	pop    %esi
  802147:	5f                   	pop    %edi
  802148:	5d                   	pop    %ebp
  802149:	c3                   	ret    
  80214a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802150:	0f bd e8             	bsr    %eax,%ebp
  802153:	83 f5 1f             	xor    $0x1f,%ebp
  802156:	75 50                	jne    8021a8 <__umoddi3+0xa8>
  802158:	39 d8                	cmp    %ebx,%eax
  80215a:	0f 82 e0 00 00 00    	jb     802240 <__umoddi3+0x140>
  802160:	89 d9                	mov    %ebx,%ecx
  802162:	39 f7                	cmp    %esi,%edi
  802164:	0f 86 d6 00 00 00    	jbe    802240 <__umoddi3+0x140>
  80216a:	89 d0                	mov    %edx,%eax
  80216c:	89 ca                	mov    %ecx,%edx
  80216e:	83 c4 1c             	add    $0x1c,%esp
  802171:	5b                   	pop    %ebx
  802172:	5e                   	pop    %esi
  802173:	5f                   	pop    %edi
  802174:	5d                   	pop    %ebp
  802175:	c3                   	ret    
  802176:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80217d:	8d 76 00             	lea    0x0(%esi),%esi
  802180:	89 fd                	mov    %edi,%ebp
  802182:	85 ff                	test   %edi,%edi
  802184:	75 0b                	jne    802191 <__umoddi3+0x91>
  802186:	b8 01 00 00 00       	mov    $0x1,%eax
  80218b:	31 d2                	xor    %edx,%edx
  80218d:	f7 f7                	div    %edi
  80218f:	89 c5                	mov    %eax,%ebp
  802191:	89 d8                	mov    %ebx,%eax
  802193:	31 d2                	xor    %edx,%edx
  802195:	f7 f5                	div    %ebp
  802197:	89 f0                	mov    %esi,%eax
  802199:	f7 f5                	div    %ebp
  80219b:	89 d0                	mov    %edx,%eax
  80219d:	31 d2                	xor    %edx,%edx
  80219f:	eb 8c                	jmp    80212d <__umoddi3+0x2d>
  8021a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a8:	89 e9                	mov    %ebp,%ecx
  8021aa:	ba 20 00 00 00       	mov    $0x20,%edx
  8021af:	29 ea                	sub    %ebp,%edx
  8021b1:	d3 e0                	shl    %cl,%eax
  8021b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021b7:	89 d1                	mov    %edx,%ecx
  8021b9:	89 f8                	mov    %edi,%eax
  8021bb:	d3 e8                	shr    %cl,%eax
  8021bd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8021c1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021c5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021c9:	09 c1                	or     %eax,%ecx
  8021cb:	89 d8                	mov    %ebx,%eax
  8021cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021d1:	89 e9                	mov    %ebp,%ecx
  8021d3:	d3 e7                	shl    %cl,%edi
  8021d5:	89 d1                	mov    %edx,%ecx
  8021d7:	d3 e8                	shr    %cl,%eax
  8021d9:	89 e9                	mov    %ebp,%ecx
  8021db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8021df:	d3 e3                	shl    %cl,%ebx
  8021e1:	89 c7                	mov    %eax,%edi
  8021e3:	89 d1                	mov    %edx,%ecx
  8021e5:	89 f0                	mov    %esi,%eax
  8021e7:	d3 e8                	shr    %cl,%eax
  8021e9:	89 e9                	mov    %ebp,%ecx
  8021eb:	89 fa                	mov    %edi,%edx
  8021ed:	d3 e6                	shl    %cl,%esi
  8021ef:	09 d8                	or     %ebx,%eax
  8021f1:	f7 74 24 08          	divl   0x8(%esp)
  8021f5:	89 d1                	mov    %edx,%ecx
  8021f7:	89 f3                	mov    %esi,%ebx
  8021f9:	f7 64 24 0c          	mull   0xc(%esp)
  8021fd:	89 c6                	mov    %eax,%esi
  8021ff:	89 d7                	mov    %edx,%edi
  802201:	39 d1                	cmp    %edx,%ecx
  802203:	72 06                	jb     80220b <__umoddi3+0x10b>
  802205:	75 10                	jne    802217 <__umoddi3+0x117>
  802207:	39 c3                	cmp    %eax,%ebx
  802209:	73 0c                	jae    802217 <__umoddi3+0x117>
  80220b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80220f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802213:	89 d7                	mov    %edx,%edi
  802215:	89 c6                	mov    %eax,%esi
  802217:	89 ca                	mov    %ecx,%edx
  802219:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80221e:	29 f3                	sub    %esi,%ebx
  802220:	19 fa                	sbb    %edi,%edx
  802222:	89 d0                	mov    %edx,%eax
  802224:	d3 e0                	shl    %cl,%eax
  802226:	89 e9                	mov    %ebp,%ecx
  802228:	d3 eb                	shr    %cl,%ebx
  80222a:	d3 ea                	shr    %cl,%edx
  80222c:	09 d8                	or     %ebx,%eax
  80222e:	83 c4 1c             	add    $0x1c,%esp
  802231:	5b                   	pop    %ebx
  802232:	5e                   	pop    %esi
  802233:	5f                   	pop    %edi
  802234:	5d                   	pop    %ebp
  802235:	c3                   	ret    
  802236:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80223d:	8d 76 00             	lea    0x0(%esi),%esi
  802240:	29 fe                	sub    %edi,%esi
  802242:	19 c3                	sbb    %eax,%ebx
  802244:	89 f2                	mov    %esi,%edx
  802246:	89 d9                	mov    %ebx,%ecx
  802248:	e9 1d ff ff ff       	jmp    80216a <__umoddi3+0x6a>
