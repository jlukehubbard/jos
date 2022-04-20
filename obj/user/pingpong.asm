
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
  800040:	e8 67 0e 00 00       	call   800eac <fork>
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
  800057:	e8 bc 0f 00 00       	call   801018 <ipc_recv>
  80005c:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  80005e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800061:	e8 60 0b 00 00       	call   800bc6 <sys_getenvid>
  800066:	57                   	push   %edi
  800067:	53                   	push   %ebx
  800068:	50                   	push   %eax
  800069:	68 96 14 80 00       	push   $0x801496
  80006e:	e8 4e 01 00 00       	call   8001c1 <cprintf>
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
  800086:	e8 e4 0f 00 00       	call   80106f <ipc_send>
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
  80009d:	e8 24 0b 00 00       	call   800bc6 <sys_getenvid>
  8000a2:	83 ec 04             	sub    $0x4,%esp
  8000a5:	53                   	push   %ebx
  8000a6:	50                   	push   %eax
  8000a7:	68 80 14 80 00       	push   $0x801480
  8000ac:	e8 10 01 00 00       	call   8001c1 <cprintf>
		ipc_send(who, 0, 0, 0);
  8000b1:	6a 00                	push   $0x0
  8000b3:	6a 00                	push   $0x0
  8000b5:	6a 00                	push   $0x0
  8000b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000ba:	e8 b0 0f 00 00       	call   80106f <ipc_send>
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
    envid_t envid = sys_getenvid();
  8000d3:	e8 ee 0a 00 00       	call   800bc6 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  8000d8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000dd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e5:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ea:	85 db                	test   %ebx,%ebx
  8000ec:	7e 07                	jle    8000f5 <libmain+0x31>
		binaryname = argv[0];
  8000ee:	8b 06                	mov    (%esi),%eax
  8000f0:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000f5:	83 ec 08             	sub    $0x8,%esp
  8000f8:	56                   	push   %esi
  8000f9:	53                   	push   %ebx
  8000fa:	e8 34 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ff:	e8 0a 00 00 00       	call   80010e <exit>
}
  800104:	83 c4 10             	add    $0x10,%esp
  800107:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010a:	5b                   	pop    %ebx
  80010b:	5e                   	pop    %esi
  80010c:	5d                   	pop    %ebp
  80010d:	c3                   	ret    

0080010e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80010e:	f3 0f 1e fb          	endbr32 
  800112:	55                   	push   %ebp
  800113:	89 e5                	mov    %esp,%ebp
  800115:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800118:	6a 00                	push   $0x0
  80011a:	e8 62 0a 00 00       	call   800b81 <sys_env_destroy>
}
  80011f:	83 c4 10             	add    $0x10,%esp
  800122:	c9                   	leave  
  800123:	c3                   	ret    

00800124 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800124:	f3 0f 1e fb          	endbr32 
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	53                   	push   %ebx
  80012c:	83 ec 04             	sub    $0x4,%esp
  80012f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800132:	8b 13                	mov    (%ebx),%edx
  800134:	8d 42 01             	lea    0x1(%edx),%eax
  800137:	89 03                	mov    %eax,(%ebx)
  800139:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80013c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800140:	3d ff 00 00 00       	cmp    $0xff,%eax
  800145:	74 09                	je     800150 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800147:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80014b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80014e:	c9                   	leave  
  80014f:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800150:	83 ec 08             	sub    $0x8,%esp
  800153:	68 ff 00 00 00       	push   $0xff
  800158:	8d 43 08             	lea    0x8(%ebx),%eax
  80015b:	50                   	push   %eax
  80015c:	e8 db 09 00 00       	call   800b3c <sys_cputs>
		b->idx = 0;
  800161:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800167:	83 c4 10             	add    $0x10,%esp
  80016a:	eb db                	jmp    800147 <putch+0x23>

0080016c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80016c:	f3 0f 1e fb          	endbr32 
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800179:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800180:	00 00 00 
	b.cnt = 0;
  800183:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80018a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80018d:	ff 75 0c             	pushl  0xc(%ebp)
  800190:	ff 75 08             	pushl  0x8(%ebp)
  800193:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800199:	50                   	push   %eax
  80019a:	68 24 01 80 00       	push   $0x800124
  80019f:	e8 20 01 00 00       	call   8002c4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a4:	83 c4 08             	add    $0x8,%esp
  8001a7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ad:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b3:	50                   	push   %eax
  8001b4:	e8 83 09 00 00       	call   800b3c <sys_cputs>

	return b.cnt;
}
  8001b9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001bf:	c9                   	leave  
  8001c0:	c3                   	ret    

008001c1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c1:	f3 0f 1e fb          	endbr32 
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001cb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ce:	50                   	push   %eax
  8001cf:	ff 75 08             	pushl  0x8(%ebp)
  8001d2:	e8 95 ff ff ff       	call   80016c <vcprintf>
	va_end(ap);

	return cnt;
}
  8001d7:	c9                   	leave  
  8001d8:	c3                   	ret    

008001d9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	57                   	push   %edi
  8001dd:	56                   	push   %esi
  8001de:	53                   	push   %ebx
  8001df:	83 ec 1c             	sub    $0x1c,%esp
  8001e2:	89 c7                	mov    %eax,%edi
  8001e4:	89 d6                	mov    %edx,%esi
  8001e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ec:	89 d1                	mov    %edx,%ecx
  8001ee:	89 c2                	mov    %eax,%edx
  8001f0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001f3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001fc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ff:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800206:	39 c2                	cmp    %eax,%edx
  800208:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80020b:	72 3e                	jb     80024b <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80020d:	83 ec 0c             	sub    $0xc,%esp
  800210:	ff 75 18             	pushl  0x18(%ebp)
  800213:	83 eb 01             	sub    $0x1,%ebx
  800216:	53                   	push   %ebx
  800217:	50                   	push   %eax
  800218:	83 ec 08             	sub    $0x8,%esp
  80021b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80021e:	ff 75 e0             	pushl  -0x20(%ebp)
  800221:	ff 75 dc             	pushl  -0x24(%ebp)
  800224:	ff 75 d8             	pushl  -0x28(%ebp)
  800227:	e8 e4 0f 00 00       	call   801210 <__udivdi3>
  80022c:	83 c4 18             	add    $0x18,%esp
  80022f:	52                   	push   %edx
  800230:	50                   	push   %eax
  800231:	89 f2                	mov    %esi,%edx
  800233:	89 f8                	mov    %edi,%eax
  800235:	e8 9f ff ff ff       	call   8001d9 <printnum>
  80023a:	83 c4 20             	add    $0x20,%esp
  80023d:	eb 13                	jmp    800252 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80023f:	83 ec 08             	sub    $0x8,%esp
  800242:	56                   	push   %esi
  800243:	ff 75 18             	pushl  0x18(%ebp)
  800246:	ff d7                	call   *%edi
  800248:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80024b:	83 eb 01             	sub    $0x1,%ebx
  80024e:	85 db                	test   %ebx,%ebx
  800250:	7f ed                	jg     80023f <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800252:	83 ec 08             	sub    $0x8,%esp
  800255:	56                   	push   %esi
  800256:	83 ec 04             	sub    $0x4,%esp
  800259:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025c:	ff 75 e0             	pushl  -0x20(%ebp)
  80025f:	ff 75 dc             	pushl  -0x24(%ebp)
  800262:	ff 75 d8             	pushl  -0x28(%ebp)
  800265:	e8 b6 10 00 00       	call   801320 <__umoddi3>
  80026a:	83 c4 14             	add    $0x14,%esp
  80026d:	0f be 80 b3 14 80 00 	movsbl 0x8014b3(%eax),%eax
  800274:	50                   	push   %eax
  800275:	ff d7                	call   *%edi
}
  800277:	83 c4 10             	add    $0x10,%esp
  80027a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027d:	5b                   	pop    %ebx
  80027e:	5e                   	pop    %esi
  80027f:	5f                   	pop    %edi
  800280:	5d                   	pop    %ebp
  800281:	c3                   	ret    

00800282 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800282:	f3 0f 1e fb          	endbr32 
  800286:	55                   	push   %ebp
  800287:	89 e5                	mov    %esp,%ebp
  800289:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80028c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800290:	8b 10                	mov    (%eax),%edx
  800292:	3b 50 04             	cmp    0x4(%eax),%edx
  800295:	73 0a                	jae    8002a1 <sprintputch+0x1f>
		*b->buf++ = ch;
  800297:	8d 4a 01             	lea    0x1(%edx),%ecx
  80029a:	89 08                	mov    %ecx,(%eax)
  80029c:	8b 45 08             	mov    0x8(%ebp),%eax
  80029f:	88 02                	mov    %al,(%edx)
}
  8002a1:	5d                   	pop    %ebp
  8002a2:	c3                   	ret    

008002a3 <printfmt>:
{
  8002a3:	f3 0f 1e fb          	endbr32 
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
  8002aa:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002ad:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b0:	50                   	push   %eax
  8002b1:	ff 75 10             	pushl  0x10(%ebp)
  8002b4:	ff 75 0c             	pushl  0xc(%ebp)
  8002b7:	ff 75 08             	pushl  0x8(%ebp)
  8002ba:	e8 05 00 00 00       	call   8002c4 <vprintfmt>
}
  8002bf:	83 c4 10             	add    $0x10,%esp
  8002c2:	c9                   	leave  
  8002c3:	c3                   	ret    

008002c4 <vprintfmt>:
{
  8002c4:	f3 0f 1e fb          	endbr32 
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
  8002cb:	57                   	push   %edi
  8002cc:	56                   	push   %esi
  8002cd:	53                   	push   %ebx
  8002ce:	83 ec 3c             	sub    $0x3c,%esp
  8002d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002d7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002da:	e9 4a 03 00 00       	jmp    800629 <vprintfmt+0x365>
		padc = ' ';
  8002df:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002e3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002ea:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002f1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002f8:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002fd:	8d 47 01             	lea    0x1(%edi),%eax
  800300:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800303:	0f b6 17             	movzbl (%edi),%edx
  800306:	8d 42 dd             	lea    -0x23(%edx),%eax
  800309:	3c 55                	cmp    $0x55,%al
  80030b:	0f 87 de 03 00 00    	ja     8006ef <vprintfmt+0x42b>
  800311:	0f b6 c0             	movzbl %al,%eax
  800314:	3e ff 24 85 80 15 80 	notrack jmp *0x801580(,%eax,4)
  80031b:	00 
  80031c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80031f:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800323:	eb d8                	jmp    8002fd <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800325:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800328:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80032c:	eb cf                	jmp    8002fd <vprintfmt+0x39>
  80032e:	0f b6 d2             	movzbl %dl,%edx
  800331:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800334:	b8 00 00 00 00       	mov    $0x0,%eax
  800339:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80033c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80033f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800343:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800346:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800349:	83 f9 09             	cmp    $0x9,%ecx
  80034c:	77 55                	ja     8003a3 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80034e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800351:	eb e9                	jmp    80033c <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800353:	8b 45 14             	mov    0x14(%ebp),%eax
  800356:	8b 00                	mov    (%eax),%eax
  800358:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80035b:	8b 45 14             	mov    0x14(%ebp),%eax
  80035e:	8d 40 04             	lea    0x4(%eax),%eax
  800361:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800364:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800367:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80036b:	79 90                	jns    8002fd <vprintfmt+0x39>
				width = precision, precision = -1;
  80036d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800370:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800373:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80037a:	eb 81                	jmp    8002fd <vprintfmt+0x39>
  80037c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80037f:	85 c0                	test   %eax,%eax
  800381:	ba 00 00 00 00       	mov    $0x0,%edx
  800386:	0f 49 d0             	cmovns %eax,%edx
  800389:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80038f:	e9 69 ff ff ff       	jmp    8002fd <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800394:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800397:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80039e:	e9 5a ff ff ff       	jmp    8002fd <vprintfmt+0x39>
  8003a3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a9:	eb bc                	jmp    800367 <vprintfmt+0xa3>
			lflag++;
  8003ab:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003b1:	e9 47 ff ff ff       	jmp    8002fd <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b9:	8d 78 04             	lea    0x4(%eax),%edi
  8003bc:	83 ec 08             	sub    $0x8,%esp
  8003bf:	53                   	push   %ebx
  8003c0:	ff 30                	pushl  (%eax)
  8003c2:	ff d6                	call   *%esi
			break;
  8003c4:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003c7:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003ca:	e9 57 02 00 00       	jmp    800626 <vprintfmt+0x362>
			err = va_arg(ap, int);
  8003cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d2:	8d 78 04             	lea    0x4(%eax),%edi
  8003d5:	8b 00                	mov    (%eax),%eax
  8003d7:	99                   	cltd   
  8003d8:	31 d0                	xor    %edx,%eax
  8003da:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003dc:	83 f8 08             	cmp    $0x8,%eax
  8003df:	7f 23                	jg     800404 <vprintfmt+0x140>
  8003e1:	8b 14 85 e0 16 80 00 	mov    0x8016e0(,%eax,4),%edx
  8003e8:	85 d2                	test   %edx,%edx
  8003ea:	74 18                	je     800404 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8003ec:	52                   	push   %edx
  8003ed:	68 d4 14 80 00       	push   $0x8014d4
  8003f2:	53                   	push   %ebx
  8003f3:	56                   	push   %esi
  8003f4:	e8 aa fe ff ff       	call   8002a3 <printfmt>
  8003f9:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003fc:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003ff:	e9 22 02 00 00       	jmp    800626 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  800404:	50                   	push   %eax
  800405:	68 cb 14 80 00       	push   $0x8014cb
  80040a:	53                   	push   %ebx
  80040b:	56                   	push   %esi
  80040c:	e8 92 fe ff ff       	call   8002a3 <printfmt>
  800411:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800414:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800417:	e9 0a 02 00 00       	jmp    800626 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  80041c:	8b 45 14             	mov    0x14(%ebp),%eax
  80041f:	83 c0 04             	add    $0x4,%eax
  800422:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800425:	8b 45 14             	mov    0x14(%ebp),%eax
  800428:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80042a:	85 d2                	test   %edx,%edx
  80042c:	b8 c4 14 80 00       	mov    $0x8014c4,%eax
  800431:	0f 45 c2             	cmovne %edx,%eax
  800434:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800437:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80043b:	7e 06                	jle    800443 <vprintfmt+0x17f>
  80043d:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800441:	75 0d                	jne    800450 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800443:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800446:	89 c7                	mov    %eax,%edi
  800448:	03 45 e0             	add    -0x20(%ebp),%eax
  80044b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044e:	eb 55                	jmp    8004a5 <vprintfmt+0x1e1>
  800450:	83 ec 08             	sub    $0x8,%esp
  800453:	ff 75 d8             	pushl  -0x28(%ebp)
  800456:	ff 75 cc             	pushl  -0x34(%ebp)
  800459:	e8 45 03 00 00       	call   8007a3 <strnlen>
  80045e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800461:	29 c2                	sub    %eax,%edx
  800463:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800466:	83 c4 10             	add    $0x10,%esp
  800469:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80046b:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80046f:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800472:	85 ff                	test   %edi,%edi
  800474:	7e 11                	jle    800487 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800476:	83 ec 08             	sub    $0x8,%esp
  800479:	53                   	push   %ebx
  80047a:	ff 75 e0             	pushl  -0x20(%ebp)
  80047d:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80047f:	83 ef 01             	sub    $0x1,%edi
  800482:	83 c4 10             	add    $0x10,%esp
  800485:	eb eb                	jmp    800472 <vprintfmt+0x1ae>
  800487:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80048a:	85 d2                	test   %edx,%edx
  80048c:	b8 00 00 00 00       	mov    $0x0,%eax
  800491:	0f 49 c2             	cmovns %edx,%eax
  800494:	29 c2                	sub    %eax,%edx
  800496:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800499:	eb a8                	jmp    800443 <vprintfmt+0x17f>
					putch(ch, putdat);
  80049b:	83 ec 08             	sub    $0x8,%esp
  80049e:	53                   	push   %ebx
  80049f:	52                   	push   %edx
  8004a0:	ff d6                	call   *%esi
  8004a2:	83 c4 10             	add    $0x10,%esp
  8004a5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a8:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004aa:	83 c7 01             	add    $0x1,%edi
  8004ad:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004b1:	0f be d0             	movsbl %al,%edx
  8004b4:	85 d2                	test   %edx,%edx
  8004b6:	74 4b                	je     800503 <vprintfmt+0x23f>
  8004b8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004bc:	78 06                	js     8004c4 <vprintfmt+0x200>
  8004be:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004c2:	78 1e                	js     8004e2 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004c4:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004c8:	74 d1                	je     80049b <vprintfmt+0x1d7>
  8004ca:	0f be c0             	movsbl %al,%eax
  8004cd:	83 e8 20             	sub    $0x20,%eax
  8004d0:	83 f8 5e             	cmp    $0x5e,%eax
  8004d3:	76 c6                	jbe    80049b <vprintfmt+0x1d7>
					putch('?', putdat);
  8004d5:	83 ec 08             	sub    $0x8,%esp
  8004d8:	53                   	push   %ebx
  8004d9:	6a 3f                	push   $0x3f
  8004db:	ff d6                	call   *%esi
  8004dd:	83 c4 10             	add    $0x10,%esp
  8004e0:	eb c3                	jmp    8004a5 <vprintfmt+0x1e1>
  8004e2:	89 cf                	mov    %ecx,%edi
  8004e4:	eb 0e                	jmp    8004f4 <vprintfmt+0x230>
				putch(' ', putdat);
  8004e6:	83 ec 08             	sub    $0x8,%esp
  8004e9:	53                   	push   %ebx
  8004ea:	6a 20                	push   $0x20
  8004ec:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004ee:	83 ef 01             	sub    $0x1,%edi
  8004f1:	83 c4 10             	add    $0x10,%esp
  8004f4:	85 ff                	test   %edi,%edi
  8004f6:	7f ee                	jg     8004e6 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8004f8:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004fb:	89 45 14             	mov    %eax,0x14(%ebp)
  8004fe:	e9 23 01 00 00       	jmp    800626 <vprintfmt+0x362>
  800503:	89 cf                	mov    %ecx,%edi
  800505:	eb ed                	jmp    8004f4 <vprintfmt+0x230>
	if (lflag >= 2)
  800507:	83 f9 01             	cmp    $0x1,%ecx
  80050a:	7f 1b                	jg     800527 <vprintfmt+0x263>
	else if (lflag)
  80050c:	85 c9                	test   %ecx,%ecx
  80050e:	74 63                	je     800573 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800510:	8b 45 14             	mov    0x14(%ebp),%eax
  800513:	8b 00                	mov    (%eax),%eax
  800515:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800518:	99                   	cltd   
  800519:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80051c:	8b 45 14             	mov    0x14(%ebp),%eax
  80051f:	8d 40 04             	lea    0x4(%eax),%eax
  800522:	89 45 14             	mov    %eax,0x14(%ebp)
  800525:	eb 17                	jmp    80053e <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800527:	8b 45 14             	mov    0x14(%ebp),%eax
  80052a:	8b 50 04             	mov    0x4(%eax),%edx
  80052d:	8b 00                	mov    (%eax),%eax
  80052f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800532:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800535:	8b 45 14             	mov    0x14(%ebp),%eax
  800538:	8d 40 08             	lea    0x8(%eax),%eax
  80053b:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80053e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800541:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800544:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800549:	85 c9                	test   %ecx,%ecx
  80054b:	0f 89 bb 00 00 00    	jns    80060c <vprintfmt+0x348>
				putch('-', putdat);
  800551:	83 ec 08             	sub    $0x8,%esp
  800554:	53                   	push   %ebx
  800555:	6a 2d                	push   $0x2d
  800557:	ff d6                	call   *%esi
				num = -(long long) num;
  800559:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80055c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80055f:	f7 da                	neg    %edx
  800561:	83 d1 00             	adc    $0x0,%ecx
  800564:	f7 d9                	neg    %ecx
  800566:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800569:	b8 0a 00 00 00       	mov    $0xa,%eax
  80056e:	e9 99 00 00 00       	jmp    80060c <vprintfmt+0x348>
		return va_arg(*ap, int);
  800573:	8b 45 14             	mov    0x14(%ebp),%eax
  800576:	8b 00                	mov    (%eax),%eax
  800578:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057b:	99                   	cltd   
  80057c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057f:	8b 45 14             	mov    0x14(%ebp),%eax
  800582:	8d 40 04             	lea    0x4(%eax),%eax
  800585:	89 45 14             	mov    %eax,0x14(%ebp)
  800588:	eb b4                	jmp    80053e <vprintfmt+0x27a>
	if (lflag >= 2)
  80058a:	83 f9 01             	cmp    $0x1,%ecx
  80058d:	7f 1b                	jg     8005aa <vprintfmt+0x2e6>
	else if (lflag)
  80058f:	85 c9                	test   %ecx,%ecx
  800591:	74 2c                	je     8005bf <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800593:	8b 45 14             	mov    0x14(%ebp),%eax
  800596:	8b 10                	mov    (%eax),%edx
  800598:	b9 00 00 00 00       	mov    $0x0,%ecx
  80059d:	8d 40 04             	lea    0x4(%eax),%eax
  8005a0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005a3:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005a8:	eb 62                	jmp    80060c <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8005aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ad:	8b 10                	mov    (%eax),%edx
  8005af:	8b 48 04             	mov    0x4(%eax),%ecx
  8005b2:	8d 40 08             	lea    0x8(%eax),%eax
  8005b5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005b8:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005bd:	eb 4d                	jmp    80060c <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8005bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c2:	8b 10                	mov    (%eax),%edx
  8005c4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c9:	8d 40 04             	lea    0x4(%eax),%eax
  8005cc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005cf:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8005d4:	eb 36                	jmp    80060c <vprintfmt+0x348>
	if (lflag >= 2)
  8005d6:	83 f9 01             	cmp    $0x1,%ecx
  8005d9:	7f 17                	jg     8005f2 <vprintfmt+0x32e>
	else if (lflag)
  8005db:	85 c9                	test   %ecx,%ecx
  8005dd:	74 6e                	je     80064d <vprintfmt+0x389>
		return va_arg(*ap, long);
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8b 10                	mov    (%eax),%edx
  8005e4:	89 d0                	mov    %edx,%eax
  8005e6:	99                   	cltd   
  8005e7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005ea:	8d 49 04             	lea    0x4(%ecx),%ecx
  8005ed:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005f0:	eb 11                	jmp    800603 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8b 50 04             	mov    0x4(%eax),%edx
  8005f8:	8b 00                	mov    (%eax),%eax
  8005fa:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005fd:	8d 49 08             	lea    0x8(%ecx),%ecx
  800600:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800603:	89 d1                	mov    %edx,%ecx
  800605:	89 c2                	mov    %eax,%edx
            base = 8;
  800607:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  80060c:	83 ec 0c             	sub    $0xc,%esp
  80060f:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800613:	57                   	push   %edi
  800614:	ff 75 e0             	pushl  -0x20(%ebp)
  800617:	50                   	push   %eax
  800618:	51                   	push   %ecx
  800619:	52                   	push   %edx
  80061a:	89 da                	mov    %ebx,%edx
  80061c:	89 f0                	mov    %esi,%eax
  80061e:	e8 b6 fb ff ff       	call   8001d9 <printnum>
			break;
  800623:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800626:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800629:	83 c7 01             	add    $0x1,%edi
  80062c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800630:	83 f8 25             	cmp    $0x25,%eax
  800633:	0f 84 a6 fc ff ff    	je     8002df <vprintfmt+0x1b>
			if (ch == '\0')
  800639:	85 c0                	test   %eax,%eax
  80063b:	0f 84 ce 00 00 00    	je     80070f <vprintfmt+0x44b>
			putch(ch, putdat);
  800641:	83 ec 08             	sub    $0x8,%esp
  800644:	53                   	push   %ebx
  800645:	50                   	push   %eax
  800646:	ff d6                	call   *%esi
  800648:	83 c4 10             	add    $0x10,%esp
  80064b:	eb dc                	jmp    800629 <vprintfmt+0x365>
		return va_arg(*ap, int);
  80064d:	8b 45 14             	mov    0x14(%ebp),%eax
  800650:	8b 10                	mov    (%eax),%edx
  800652:	89 d0                	mov    %edx,%eax
  800654:	99                   	cltd   
  800655:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800658:	8d 49 04             	lea    0x4(%ecx),%ecx
  80065b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80065e:	eb a3                	jmp    800603 <vprintfmt+0x33f>
			putch('0', putdat);
  800660:	83 ec 08             	sub    $0x8,%esp
  800663:	53                   	push   %ebx
  800664:	6a 30                	push   $0x30
  800666:	ff d6                	call   *%esi
			putch('x', putdat);
  800668:	83 c4 08             	add    $0x8,%esp
  80066b:	53                   	push   %ebx
  80066c:	6a 78                	push   $0x78
  80066e:	ff d6                	call   *%esi
			num = (unsigned long long)
  800670:	8b 45 14             	mov    0x14(%ebp),%eax
  800673:	8b 10                	mov    (%eax),%edx
  800675:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80067a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80067d:	8d 40 04             	lea    0x4(%eax),%eax
  800680:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800683:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800688:	eb 82                	jmp    80060c <vprintfmt+0x348>
	if (lflag >= 2)
  80068a:	83 f9 01             	cmp    $0x1,%ecx
  80068d:	7f 1e                	jg     8006ad <vprintfmt+0x3e9>
	else if (lflag)
  80068f:	85 c9                	test   %ecx,%ecx
  800691:	74 32                	je     8006c5 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800693:	8b 45 14             	mov    0x14(%ebp),%eax
  800696:	8b 10                	mov    (%eax),%edx
  800698:	b9 00 00 00 00       	mov    $0x0,%ecx
  80069d:	8d 40 04             	lea    0x4(%eax),%eax
  8006a0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a3:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006a8:	e9 5f ff ff ff       	jmp    80060c <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8006ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b0:	8b 10                	mov    (%eax),%edx
  8006b2:	8b 48 04             	mov    0x4(%eax),%ecx
  8006b5:	8d 40 08             	lea    0x8(%eax),%eax
  8006b8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006bb:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006c0:	e9 47 ff ff ff       	jmp    80060c <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8006c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c8:	8b 10                	mov    (%eax),%edx
  8006ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006cf:	8d 40 04             	lea    0x4(%eax),%eax
  8006d2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d5:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006da:	e9 2d ff ff ff       	jmp    80060c <vprintfmt+0x348>
			putch(ch, putdat);
  8006df:	83 ec 08             	sub    $0x8,%esp
  8006e2:	53                   	push   %ebx
  8006e3:	6a 25                	push   $0x25
  8006e5:	ff d6                	call   *%esi
			break;
  8006e7:	83 c4 10             	add    $0x10,%esp
  8006ea:	e9 37 ff ff ff       	jmp    800626 <vprintfmt+0x362>
			putch('%', putdat);
  8006ef:	83 ec 08             	sub    $0x8,%esp
  8006f2:	53                   	push   %ebx
  8006f3:	6a 25                	push   $0x25
  8006f5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f7:	83 c4 10             	add    $0x10,%esp
  8006fa:	89 f8                	mov    %edi,%eax
  8006fc:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800700:	74 05                	je     800707 <vprintfmt+0x443>
  800702:	83 e8 01             	sub    $0x1,%eax
  800705:	eb f5                	jmp    8006fc <vprintfmt+0x438>
  800707:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80070a:	e9 17 ff ff ff       	jmp    800626 <vprintfmt+0x362>
}
  80070f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800712:	5b                   	pop    %ebx
  800713:	5e                   	pop    %esi
  800714:	5f                   	pop    %edi
  800715:	5d                   	pop    %ebp
  800716:	c3                   	ret    

00800717 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800717:	f3 0f 1e fb          	endbr32 
  80071b:	55                   	push   %ebp
  80071c:	89 e5                	mov    %esp,%ebp
  80071e:	83 ec 18             	sub    $0x18,%esp
  800721:	8b 45 08             	mov    0x8(%ebp),%eax
  800724:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800727:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80072a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80072e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800731:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800738:	85 c0                	test   %eax,%eax
  80073a:	74 26                	je     800762 <vsnprintf+0x4b>
  80073c:	85 d2                	test   %edx,%edx
  80073e:	7e 22                	jle    800762 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800740:	ff 75 14             	pushl  0x14(%ebp)
  800743:	ff 75 10             	pushl  0x10(%ebp)
  800746:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800749:	50                   	push   %eax
  80074a:	68 82 02 80 00       	push   $0x800282
  80074f:	e8 70 fb ff ff       	call   8002c4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800754:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800757:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80075a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80075d:	83 c4 10             	add    $0x10,%esp
}
  800760:	c9                   	leave  
  800761:	c3                   	ret    
		return -E_INVAL;
  800762:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800767:	eb f7                	jmp    800760 <vsnprintf+0x49>

00800769 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800769:	f3 0f 1e fb          	endbr32 
  80076d:	55                   	push   %ebp
  80076e:	89 e5                	mov    %esp,%ebp
  800770:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800773:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800776:	50                   	push   %eax
  800777:	ff 75 10             	pushl  0x10(%ebp)
  80077a:	ff 75 0c             	pushl  0xc(%ebp)
  80077d:	ff 75 08             	pushl  0x8(%ebp)
  800780:	e8 92 ff ff ff       	call   800717 <vsnprintf>
	va_end(ap);

	return rc;
}
  800785:	c9                   	leave  
  800786:	c3                   	ret    

00800787 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800787:	f3 0f 1e fb          	endbr32 
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800791:	b8 00 00 00 00       	mov    $0x0,%eax
  800796:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80079a:	74 05                	je     8007a1 <strlen+0x1a>
		n++;
  80079c:	83 c0 01             	add    $0x1,%eax
  80079f:	eb f5                	jmp    800796 <strlen+0xf>
	return n;
}
  8007a1:	5d                   	pop    %ebp
  8007a2:	c3                   	ret    

008007a3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007a3:	f3 0f 1e fb          	endbr32 
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ad:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b5:	39 d0                	cmp    %edx,%eax
  8007b7:	74 0d                	je     8007c6 <strnlen+0x23>
  8007b9:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007bd:	74 05                	je     8007c4 <strnlen+0x21>
		n++;
  8007bf:	83 c0 01             	add    $0x1,%eax
  8007c2:	eb f1                	jmp    8007b5 <strnlen+0x12>
  8007c4:	89 c2                	mov    %eax,%edx
	return n;
}
  8007c6:	89 d0                	mov    %edx,%eax
  8007c8:	5d                   	pop    %ebp
  8007c9:	c3                   	ret    

008007ca <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ca:	f3 0f 1e fb          	endbr32 
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	53                   	push   %ebx
  8007d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007dd:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007e1:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007e4:	83 c0 01             	add    $0x1,%eax
  8007e7:	84 d2                	test   %dl,%dl
  8007e9:	75 f2                	jne    8007dd <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8007eb:	89 c8                	mov    %ecx,%eax
  8007ed:	5b                   	pop    %ebx
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f0:	f3 0f 1e fb          	endbr32 
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	53                   	push   %ebx
  8007f8:	83 ec 10             	sub    $0x10,%esp
  8007fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007fe:	53                   	push   %ebx
  8007ff:	e8 83 ff ff ff       	call   800787 <strlen>
  800804:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800807:	ff 75 0c             	pushl  0xc(%ebp)
  80080a:	01 d8                	add    %ebx,%eax
  80080c:	50                   	push   %eax
  80080d:	e8 b8 ff ff ff       	call   8007ca <strcpy>
	return dst;
}
  800812:	89 d8                	mov    %ebx,%eax
  800814:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800817:	c9                   	leave  
  800818:	c3                   	ret    

00800819 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800819:	f3 0f 1e fb          	endbr32 
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	56                   	push   %esi
  800821:	53                   	push   %ebx
  800822:	8b 75 08             	mov    0x8(%ebp),%esi
  800825:	8b 55 0c             	mov    0xc(%ebp),%edx
  800828:	89 f3                	mov    %esi,%ebx
  80082a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80082d:	89 f0                	mov    %esi,%eax
  80082f:	39 d8                	cmp    %ebx,%eax
  800831:	74 11                	je     800844 <strncpy+0x2b>
		*dst++ = *src;
  800833:	83 c0 01             	add    $0x1,%eax
  800836:	0f b6 0a             	movzbl (%edx),%ecx
  800839:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80083c:	80 f9 01             	cmp    $0x1,%cl
  80083f:	83 da ff             	sbb    $0xffffffff,%edx
  800842:	eb eb                	jmp    80082f <strncpy+0x16>
	}
	return ret;
}
  800844:	89 f0                	mov    %esi,%eax
  800846:	5b                   	pop    %ebx
  800847:	5e                   	pop    %esi
  800848:	5d                   	pop    %ebp
  800849:	c3                   	ret    

0080084a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80084a:	f3 0f 1e fb          	endbr32 
  80084e:	55                   	push   %ebp
  80084f:	89 e5                	mov    %esp,%ebp
  800851:	56                   	push   %esi
  800852:	53                   	push   %ebx
  800853:	8b 75 08             	mov    0x8(%ebp),%esi
  800856:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800859:	8b 55 10             	mov    0x10(%ebp),%edx
  80085c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80085e:	85 d2                	test   %edx,%edx
  800860:	74 21                	je     800883 <strlcpy+0x39>
  800862:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800866:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800868:	39 c2                	cmp    %eax,%edx
  80086a:	74 14                	je     800880 <strlcpy+0x36>
  80086c:	0f b6 19             	movzbl (%ecx),%ebx
  80086f:	84 db                	test   %bl,%bl
  800871:	74 0b                	je     80087e <strlcpy+0x34>
			*dst++ = *src++;
  800873:	83 c1 01             	add    $0x1,%ecx
  800876:	83 c2 01             	add    $0x1,%edx
  800879:	88 5a ff             	mov    %bl,-0x1(%edx)
  80087c:	eb ea                	jmp    800868 <strlcpy+0x1e>
  80087e:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800880:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800883:	29 f0                	sub    %esi,%eax
}
  800885:	5b                   	pop    %ebx
  800886:	5e                   	pop    %esi
  800887:	5d                   	pop    %ebp
  800888:	c3                   	ret    

00800889 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800889:	f3 0f 1e fb          	endbr32 
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800893:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800896:	0f b6 01             	movzbl (%ecx),%eax
  800899:	84 c0                	test   %al,%al
  80089b:	74 0c                	je     8008a9 <strcmp+0x20>
  80089d:	3a 02                	cmp    (%edx),%al
  80089f:	75 08                	jne    8008a9 <strcmp+0x20>
		p++, q++;
  8008a1:	83 c1 01             	add    $0x1,%ecx
  8008a4:	83 c2 01             	add    $0x1,%edx
  8008a7:	eb ed                	jmp    800896 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a9:	0f b6 c0             	movzbl %al,%eax
  8008ac:	0f b6 12             	movzbl (%edx),%edx
  8008af:	29 d0                	sub    %edx,%eax
}
  8008b1:	5d                   	pop    %ebp
  8008b2:	c3                   	ret    

008008b3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b3:	f3 0f 1e fb          	endbr32 
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	53                   	push   %ebx
  8008bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c1:	89 c3                	mov    %eax,%ebx
  8008c3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008c6:	eb 06                	jmp    8008ce <strncmp+0x1b>
		n--, p++, q++;
  8008c8:	83 c0 01             	add    $0x1,%eax
  8008cb:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008ce:	39 d8                	cmp    %ebx,%eax
  8008d0:	74 16                	je     8008e8 <strncmp+0x35>
  8008d2:	0f b6 08             	movzbl (%eax),%ecx
  8008d5:	84 c9                	test   %cl,%cl
  8008d7:	74 04                	je     8008dd <strncmp+0x2a>
  8008d9:	3a 0a                	cmp    (%edx),%cl
  8008db:	74 eb                	je     8008c8 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008dd:	0f b6 00             	movzbl (%eax),%eax
  8008e0:	0f b6 12             	movzbl (%edx),%edx
  8008e3:	29 d0                	sub    %edx,%eax
}
  8008e5:	5b                   	pop    %ebx
  8008e6:	5d                   	pop    %ebp
  8008e7:	c3                   	ret    
		return 0;
  8008e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ed:	eb f6                	jmp    8008e5 <strncmp+0x32>

008008ef <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ef:	f3 0f 1e fb          	endbr32 
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008fd:	0f b6 10             	movzbl (%eax),%edx
  800900:	84 d2                	test   %dl,%dl
  800902:	74 09                	je     80090d <strchr+0x1e>
		if (*s == c)
  800904:	38 ca                	cmp    %cl,%dl
  800906:	74 0a                	je     800912 <strchr+0x23>
	for (; *s; s++)
  800908:	83 c0 01             	add    $0x1,%eax
  80090b:	eb f0                	jmp    8008fd <strchr+0xe>
			return (char *) s;
	return 0;
  80090d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800914:	f3 0f 1e fb          	endbr32 
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	8b 45 08             	mov    0x8(%ebp),%eax
  80091e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800922:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800925:	38 ca                	cmp    %cl,%dl
  800927:	74 09                	je     800932 <strfind+0x1e>
  800929:	84 d2                	test   %dl,%dl
  80092b:	74 05                	je     800932 <strfind+0x1e>
	for (; *s; s++)
  80092d:	83 c0 01             	add    $0x1,%eax
  800930:	eb f0                	jmp    800922 <strfind+0xe>
			break;
	return (char *) s;
}
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800934:	f3 0f 1e fb          	endbr32 
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	57                   	push   %edi
  80093c:	56                   	push   %esi
  80093d:	53                   	push   %ebx
  80093e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800941:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800944:	85 c9                	test   %ecx,%ecx
  800946:	74 31                	je     800979 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800948:	89 f8                	mov    %edi,%eax
  80094a:	09 c8                	or     %ecx,%eax
  80094c:	a8 03                	test   $0x3,%al
  80094e:	75 23                	jne    800973 <memset+0x3f>
		c &= 0xFF;
  800950:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800954:	89 d3                	mov    %edx,%ebx
  800956:	c1 e3 08             	shl    $0x8,%ebx
  800959:	89 d0                	mov    %edx,%eax
  80095b:	c1 e0 18             	shl    $0x18,%eax
  80095e:	89 d6                	mov    %edx,%esi
  800960:	c1 e6 10             	shl    $0x10,%esi
  800963:	09 f0                	or     %esi,%eax
  800965:	09 c2                	or     %eax,%edx
  800967:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800969:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80096c:	89 d0                	mov    %edx,%eax
  80096e:	fc                   	cld    
  80096f:	f3 ab                	rep stos %eax,%es:(%edi)
  800971:	eb 06                	jmp    800979 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800973:	8b 45 0c             	mov    0xc(%ebp),%eax
  800976:	fc                   	cld    
  800977:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800979:	89 f8                	mov    %edi,%eax
  80097b:	5b                   	pop    %ebx
  80097c:	5e                   	pop    %esi
  80097d:	5f                   	pop    %edi
  80097e:	5d                   	pop    %ebp
  80097f:	c3                   	ret    

00800980 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800980:	f3 0f 1e fb          	endbr32 
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	57                   	push   %edi
  800988:	56                   	push   %esi
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800992:	39 c6                	cmp    %eax,%esi
  800994:	73 32                	jae    8009c8 <memmove+0x48>
  800996:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800999:	39 c2                	cmp    %eax,%edx
  80099b:	76 2b                	jbe    8009c8 <memmove+0x48>
		s += n;
		d += n;
  80099d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a0:	89 fe                	mov    %edi,%esi
  8009a2:	09 ce                	or     %ecx,%esi
  8009a4:	09 d6                	or     %edx,%esi
  8009a6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ac:	75 0e                	jne    8009bc <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009ae:	83 ef 04             	sub    $0x4,%edi
  8009b1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009b7:	fd                   	std    
  8009b8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ba:	eb 09                	jmp    8009c5 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009bc:	83 ef 01             	sub    $0x1,%edi
  8009bf:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009c2:	fd                   	std    
  8009c3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c5:	fc                   	cld    
  8009c6:	eb 1a                	jmp    8009e2 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c8:	89 c2                	mov    %eax,%edx
  8009ca:	09 ca                	or     %ecx,%edx
  8009cc:	09 f2                	or     %esi,%edx
  8009ce:	f6 c2 03             	test   $0x3,%dl
  8009d1:	75 0a                	jne    8009dd <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009d3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009d6:	89 c7                	mov    %eax,%edi
  8009d8:	fc                   	cld    
  8009d9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009db:	eb 05                	jmp    8009e2 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8009dd:	89 c7                	mov    %eax,%edi
  8009df:	fc                   	cld    
  8009e0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e2:	5e                   	pop    %esi
  8009e3:	5f                   	pop    %edi
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    

008009e6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009e6:	f3 0f 1e fb          	endbr32 
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009f0:	ff 75 10             	pushl  0x10(%ebp)
  8009f3:	ff 75 0c             	pushl  0xc(%ebp)
  8009f6:	ff 75 08             	pushl  0x8(%ebp)
  8009f9:	e8 82 ff ff ff       	call   800980 <memmove>
}
  8009fe:	c9                   	leave  
  8009ff:	c3                   	ret    

00800a00 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a00:	f3 0f 1e fb          	endbr32 
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	56                   	push   %esi
  800a08:	53                   	push   %ebx
  800a09:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0f:	89 c6                	mov    %eax,%esi
  800a11:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a14:	39 f0                	cmp    %esi,%eax
  800a16:	74 1c                	je     800a34 <memcmp+0x34>
		if (*s1 != *s2)
  800a18:	0f b6 08             	movzbl (%eax),%ecx
  800a1b:	0f b6 1a             	movzbl (%edx),%ebx
  800a1e:	38 d9                	cmp    %bl,%cl
  800a20:	75 08                	jne    800a2a <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a22:	83 c0 01             	add    $0x1,%eax
  800a25:	83 c2 01             	add    $0x1,%edx
  800a28:	eb ea                	jmp    800a14 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a2a:	0f b6 c1             	movzbl %cl,%eax
  800a2d:	0f b6 db             	movzbl %bl,%ebx
  800a30:	29 d8                	sub    %ebx,%eax
  800a32:	eb 05                	jmp    800a39 <memcmp+0x39>
	}

	return 0;
  800a34:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a39:	5b                   	pop    %ebx
  800a3a:	5e                   	pop    %esi
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a3d:	f3 0f 1e fb          	endbr32 
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
  800a47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a4a:	89 c2                	mov    %eax,%edx
  800a4c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a4f:	39 d0                	cmp    %edx,%eax
  800a51:	73 09                	jae    800a5c <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a53:	38 08                	cmp    %cl,(%eax)
  800a55:	74 05                	je     800a5c <memfind+0x1f>
	for (; s < ends; s++)
  800a57:	83 c0 01             	add    $0x1,%eax
  800a5a:	eb f3                	jmp    800a4f <memfind+0x12>
			break;
	return (void *) s;
}
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a5e:	f3 0f 1e fb          	endbr32 
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	57                   	push   %edi
  800a66:	56                   	push   %esi
  800a67:	53                   	push   %ebx
  800a68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6e:	eb 03                	jmp    800a73 <strtol+0x15>
		s++;
  800a70:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a73:	0f b6 01             	movzbl (%ecx),%eax
  800a76:	3c 20                	cmp    $0x20,%al
  800a78:	74 f6                	je     800a70 <strtol+0x12>
  800a7a:	3c 09                	cmp    $0x9,%al
  800a7c:	74 f2                	je     800a70 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a7e:	3c 2b                	cmp    $0x2b,%al
  800a80:	74 2a                	je     800aac <strtol+0x4e>
	int neg = 0;
  800a82:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a87:	3c 2d                	cmp    $0x2d,%al
  800a89:	74 2b                	je     800ab6 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a91:	75 0f                	jne    800aa2 <strtol+0x44>
  800a93:	80 39 30             	cmpb   $0x30,(%ecx)
  800a96:	74 28                	je     800ac0 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a98:	85 db                	test   %ebx,%ebx
  800a9a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a9f:	0f 44 d8             	cmove  %eax,%ebx
  800aa2:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa7:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800aaa:	eb 46                	jmp    800af2 <strtol+0x94>
		s++;
  800aac:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800aaf:	bf 00 00 00 00       	mov    $0x0,%edi
  800ab4:	eb d5                	jmp    800a8b <strtol+0x2d>
		s++, neg = 1;
  800ab6:	83 c1 01             	add    $0x1,%ecx
  800ab9:	bf 01 00 00 00       	mov    $0x1,%edi
  800abe:	eb cb                	jmp    800a8b <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ac4:	74 0e                	je     800ad4 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ac6:	85 db                	test   %ebx,%ebx
  800ac8:	75 d8                	jne    800aa2 <strtol+0x44>
		s++, base = 8;
  800aca:	83 c1 01             	add    $0x1,%ecx
  800acd:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ad2:	eb ce                	jmp    800aa2 <strtol+0x44>
		s += 2, base = 16;
  800ad4:	83 c1 02             	add    $0x2,%ecx
  800ad7:	bb 10 00 00 00       	mov    $0x10,%ebx
  800adc:	eb c4                	jmp    800aa2 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ade:	0f be d2             	movsbl %dl,%edx
  800ae1:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ae4:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ae7:	7d 3a                	jge    800b23 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ae9:	83 c1 01             	add    $0x1,%ecx
  800aec:	0f af 45 10          	imul   0x10(%ebp),%eax
  800af0:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800af2:	0f b6 11             	movzbl (%ecx),%edx
  800af5:	8d 72 d0             	lea    -0x30(%edx),%esi
  800af8:	89 f3                	mov    %esi,%ebx
  800afa:	80 fb 09             	cmp    $0x9,%bl
  800afd:	76 df                	jbe    800ade <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800aff:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b02:	89 f3                	mov    %esi,%ebx
  800b04:	80 fb 19             	cmp    $0x19,%bl
  800b07:	77 08                	ja     800b11 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b09:	0f be d2             	movsbl %dl,%edx
  800b0c:	83 ea 57             	sub    $0x57,%edx
  800b0f:	eb d3                	jmp    800ae4 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b11:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b14:	89 f3                	mov    %esi,%ebx
  800b16:	80 fb 19             	cmp    $0x19,%bl
  800b19:	77 08                	ja     800b23 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b1b:	0f be d2             	movsbl %dl,%edx
  800b1e:	83 ea 37             	sub    $0x37,%edx
  800b21:	eb c1                	jmp    800ae4 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b23:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b27:	74 05                	je     800b2e <strtol+0xd0>
		*endptr = (char *) s;
  800b29:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b2c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b2e:	89 c2                	mov    %eax,%edx
  800b30:	f7 da                	neg    %edx
  800b32:	85 ff                	test   %edi,%edi
  800b34:	0f 45 c2             	cmovne %edx,%eax
}
  800b37:	5b                   	pop    %ebx
  800b38:	5e                   	pop    %esi
  800b39:	5f                   	pop    %edi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b3c:	f3 0f 1e fb          	endbr32 
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b46:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b51:	89 c3                	mov    %eax,%ebx
  800b53:	89 c7                	mov    %eax,%edi
  800b55:	89 c6                	mov    %eax,%esi
  800b57:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b59:	5b                   	pop    %ebx
  800b5a:	5e                   	pop    %esi
  800b5b:	5f                   	pop    %edi
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b5e:	f3 0f 1e fb          	endbr32 
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b68:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b72:	89 d1                	mov    %edx,%ecx
  800b74:	89 d3                	mov    %edx,%ebx
  800b76:	89 d7                	mov    %edx,%edi
  800b78:	89 d6                	mov    %edx,%esi
  800b7a:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b7c:	5b                   	pop    %ebx
  800b7d:	5e                   	pop    %esi
  800b7e:	5f                   	pop    %edi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b81:	f3 0f 1e fb          	endbr32 
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	57                   	push   %edi
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
  800b8b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b8e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b93:	8b 55 08             	mov    0x8(%ebp),%edx
  800b96:	b8 03 00 00 00       	mov    $0x3,%eax
  800b9b:	89 cb                	mov    %ecx,%ebx
  800b9d:	89 cf                	mov    %ecx,%edi
  800b9f:	89 ce                	mov    %ecx,%esi
  800ba1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ba3:	85 c0                	test   %eax,%eax
  800ba5:	7f 08                	jg     800baf <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ba7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5f                   	pop    %edi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800baf:	83 ec 0c             	sub    $0xc,%esp
  800bb2:	50                   	push   %eax
  800bb3:	6a 03                	push   $0x3
  800bb5:	68 04 17 80 00       	push   $0x801704
  800bba:	6a 23                	push   $0x23
  800bbc:	68 21 17 80 00       	push   $0x801721
  800bc1:	e8 4c 05 00 00       	call   801112 <_panic>

00800bc6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc6:	f3 0f 1e fb          	endbr32 
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	57                   	push   %edi
  800bce:	56                   	push   %esi
  800bcf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd5:	b8 02 00 00 00       	mov    $0x2,%eax
  800bda:	89 d1                	mov    %edx,%ecx
  800bdc:	89 d3                	mov    %edx,%ebx
  800bde:	89 d7                	mov    %edx,%edi
  800be0:	89 d6                	mov    %edx,%esi
  800be2:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <sys_yield>:

void
sys_yield(void)
{
  800be9:	f3 0f 1e fb          	endbr32 
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	57                   	push   %edi
  800bf1:	56                   	push   %esi
  800bf2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bf3:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bfd:	89 d1                	mov    %edx,%ecx
  800bff:	89 d3                	mov    %edx,%ebx
  800c01:	89 d7                	mov    %edx,%edi
  800c03:	89 d6                	mov    %edx,%esi
  800c05:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c07:	5b                   	pop    %ebx
  800c08:	5e                   	pop    %esi
  800c09:	5f                   	pop    %edi
  800c0a:	5d                   	pop    %ebp
  800c0b:	c3                   	ret    

00800c0c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c0c:	f3 0f 1e fb          	endbr32 
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	57                   	push   %edi
  800c14:	56                   	push   %esi
  800c15:	53                   	push   %ebx
  800c16:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c19:	be 00 00 00 00       	mov    $0x0,%esi
  800c1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c24:	b8 04 00 00 00       	mov    $0x4,%eax
  800c29:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c2c:	89 f7                	mov    %esi,%edi
  800c2e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c30:	85 c0                	test   %eax,%eax
  800c32:	7f 08                	jg     800c3c <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c37:	5b                   	pop    %ebx
  800c38:	5e                   	pop    %esi
  800c39:	5f                   	pop    %edi
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3c:	83 ec 0c             	sub    $0xc,%esp
  800c3f:	50                   	push   %eax
  800c40:	6a 04                	push   $0x4
  800c42:	68 04 17 80 00       	push   $0x801704
  800c47:	6a 23                	push   $0x23
  800c49:	68 21 17 80 00       	push   $0x801721
  800c4e:	e8 bf 04 00 00       	call   801112 <_panic>

00800c53 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c53:	f3 0f 1e fb          	endbr32 
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c60:	8b 55 08             	mov    0x8(%ebp),%edx
  800c63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c66:	b8 05 00 00 00       	mov    $0x5,%eax
  800c6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c71:	8b 75 18             	mov    0x18(%ebp),%esi
  800c74:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c76:	85 c0                	test   %eax,%eax
  800c78:	7f 08                	jg     800c82 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c82:	83 ec 0c             	sub    $0xc,%esp
  800c85:	50                   	push   %eax
  800c86:	6a 05                	push   $0x5
  800c88:	68 04 17 80 00       	push   $0x801704
  800c8d:	6a 23                	push   $0x23
  800c8f:	68 21 17 80 00       	push   $0x801721
  800c94:	e8 79 04 00 00       	call   801112 <_panic>

00800c99 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c99:	f3 0f 1e fb          	endbr32 
  800c9d:	55                   	push   %ebp
  800c9e:	89 e5                	mov    %esp,%ebp
  800ca0:	57                   	push   %edi
  800ca1:	56                   	push   %esi
  800ca2:	53                   	push   %ebx
  800ca3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ca6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cab:	8b 55 08             	mov    0x8(%ebp),%edx
  800cae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb1:	b8 06 00 00 00       	mov    $0x6,%eax
  800cb6:	89 df                	mov    %ebx,%edi
  800cb8:	89 de                	mov    %ebx,%esi
  800cba:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cbc:	85 c0                	test   %eax,%eax
  800cbe:	7f 08                	jg     800cc8 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc3:	5b                   	pop    %ebx
  800cc4:	5e                   	pop    %esi
  800cc5:	5f                   	pop    %edi
  800cc6:	5d                   	pop    %ebp
  800cc7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc8:	83 ec 0c             	sub    $0xc,%esp
  800ccb:	50                   	push   %eax
  800ccc:	6a 06                	push   $0x6
  800cce:	68 04 17 80 00       	push   $0x801704
  800cd3:	6a 23                	push   $0x23
  800cd5:	68 21 17 80 00       	push   $0x801721
  800cda:	e8 33 04 00 00       	call   801112 <_panic>

00800cdf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cdf:	f3 0f 1e fb          	endbr32 
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	57                   	push   %edi
  800ce7:	56                   	push   %esi
  800ce8:	53                   	push   %ebx
  800ce9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cec:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf7:	b8 08 00 00 00       	mov    $0x8,%eax
  800cfc:	89 df                	mov    %ebx,%edi
  800cfe:	89 de                	mov    %ebx,%esi
  800d00:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d02:	85 c0                	test   %eax,%eax
  800d04:	7f 08                	jg     800d0e <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d09:	5b                   	pop    %ebx
  800d0a:	5e                   	pop    %esi
  800d0b:	5f                   	pop    %edi
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0e:	83 ec 0c             	sub    $0xc,%esp
  800d11:	50                   	push   %eax
  800d12:	6a 08                	push   $0x8
  800d14:	68 04 17 80 00       	push   $0x801704
  800d19:	6a 23                	push   $0x23
  800d1b:	68 21 17 80 00       	push   $0x801721
  800d20:	e8 ed 03 00 00       	call   801112 <_panic>

00800d25 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d25:	f3 0f 1e fb          	endbr32 
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	57                   	push   %edi
  800d2d:	56                   	push   %esi
  800d2e:	53                   	push   %ebx
  800d2f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d32:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d37:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3d:	b8 09 00 00 00       	mov    $0x9,%eax
  800d42:	89 df                	mov    %ebx,%edi
  800d44:	89 de                	mov    %ebx,%esi
  800d46:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d48:	85 c0                	test   %eax,%eax
  800d4a:	7f 08                	jg     800d54 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4f:	5b                   	pop    %ebx
  800d50:	5e                   	pop    %esi
  800d51:	5f                   	pop    %edi
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d54:	83 ec 0c             	sub    $0xc,%esp
  800d57:	50                   	push   %eax
  800d58:	6a 09                	push   $0x9
  800d5a:	68 04 17 80 00       	push   $0x801704
  800d5f:	6a 23                	push   $0x23
  800d61:	68 21 17 80 00       	push   $0x801721
  800d66:	e8 a7 03 00 00       	call   801112 <_panic>

00800d6b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d6b:	f3 0f 1e fb          	endbr32 
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	57                   	push   %edi
  800d73:	56                   	push   %esi
  800d74:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d75:	8b 55 08             	mov    0x8(%ebp),%edx
  800d78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d80:	be 00 00 00 00       	mov    $0x0,%esi
  800d85:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d88:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d8b:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d8d:	5b                   	pop    %ebx
  800d8e:	5e                   	pop    %esi
  800d8f:	5f                   	pop    %edi
  800d90:	5d                   	pop    %ebp
  800d91:	c3                   	ret    

00800d92 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d92:	f3 0f 1e fb          	endbr32 
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	57                   	push   %edi
  800d9a:	56                   	push   %esi
  800d9b:	53                   	push   %ebx
  800d9c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d9f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800da4:	8b 55 08             	mov    0x8(%ebp),%edx
  800da7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dac:	89 cb                	mov    %ecx,%ebx
  800dae:	89 cf                	mov    %ecx,%edi
  800db0:	89 ce                	mov    %ecx,%esi
  800db2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800db4:	85 c0                	test   %eax,%eax
  800db6:	7f 08                	jg     800dc0 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800db8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbb:	5b                   	pop    %ebx
  800dbc:	5e                   	pop    %esi
  800dbd:	5f                   	pop    %edi
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc0:	83 ec 0c             	sub    $0xc,%esp
  800dc3:	50                   	push   %eax
  800dc4:	6a 0c                	push   $0xc
  800dc6:	68 04 17 80 00       	push   $0x801704
  800dcb:	6a 23                	push   $0x23
  800dcd:	68 21 17 80 00       	push   $0x801721
  800dd2:	e8 3b 03 00 00       	call   801112 <_panic>

00800dd7 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dd7:	f3 0f 1e fb          	endbr32 
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	53                   	push   %ebx
  800ddf:	83 ec 04             	sub    $0x4,%esp
  800de2:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800de5:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if ( !(err & FEC_WR) ||
  800de7:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800deb:	74 75                	je     800e62 <pgfault+0x8b>
            !(uvpt[PGNUM(addr)] | PTE_COW) ) {
  800ded:	89 d8                	mov    %ebx,%eax
  800def:	c1 e8 0c             	shr    $0xc,%eax
  800df2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, (void *)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0) {
  800df9:	83 ec 04             	sub    $0x4,%esp
  800dfc:	6a 07                	push   $0x7
  800dfe:	68 00 f0 7f 00       	push   $0x7ff000
  800e03:	6a 00                	push   $0x0
  800e05:	e8 02 fe ff ff       	call   800c0c <sys_page_alloc>
  800e0a:	83 c4 10             	add    $0x10,%esp
  800e0d:	85 c0                	test   %eax,%eax
  800e0f:	78 65                	js     800e76 <pgfault+0x9f>
        panic("sys_page_alloc failed %e\n", r);
    }
    memmove((void *)PFTEMP, (void *)PTE_ADDR(addr), PGSIZE);
  800e11:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800e17:	83 ec 04             	sub    $0x4,%esp
  800e1a:	68 00 10 00 00       	push   $0x1000
  800e1f:	53                   	push   %ebx
  800e20:	68 00 f0 7f 00       	push   $0x7ff000
  800e25:	e8 56 fb ff ff       	call   800980 <memmove>
    if ((r = sys_page_map(0, (void *)PFTEMP,
  800e2a:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e31:	53                   	push   %ebx
  800e32:	6a 00                	push   $0x0
  800e34:	68 00 f0 7f 00       	push   $0x7ff000
  800e39:	6a 00                	push   $0x0
  800e3b:	e8 13 fe ff ff       	call   800c53 <sys_page_map>
  800e40:	83 c4 20             	add    $0x20,%esp
  800e43:	85 c0                	test   %eax,%eax
  800e45:	78 41                	js     800e88 <pgfault+0xb1>
                0, (void *)PTE_ADDR(addr), PTE_P | PTE_U | PTE_W)) < 0) {
        panic("sys_page_map failed %e\n", r);
    }
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0) {
  800e47:	83 ec 08             	sub    $0x8,%esp
  800e4a:	68 00 f0 7f 00       	push   $0x7ff000
  800e4f:	6a 00                	push   $0x0
  800e51:	e8 43 fe ff ff       	call   800c99 <sys_page_unmap>
  800e56:	83 c4 10             	add    $0x10,%esp
  800e59:	85 c0                	test   %eax,%eax
  800e5b:	78 3d                	js     800e9a <pgfault+0xc3>
        panic("sys_page_unmap failed %e\n", r);
    }

}
  800e5d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e60:	c9                   	leave  
  800e61:	c3                   	ret    
        panic("Not a copy-on-write page");
  800e62:	83 ec 04             	sub    $0x4,%esp
  800e65:	68 2f 17 80 00       	push   $0x80172f
  800e6a:	6a 1e                	push   $0x1e
  800e6c:	68 48 17 80 00       	push   $0x801748
  800e71:	e8 9c 02 00 00       	call   801112 <_panic>
        panic("sys_page_alloc failed %e\n", r);
  800e76:	50                   	push   %eax
  800e77:	68 53 17 80 00       	push   $0x801753
  800e7c:	6a 2a                	push   $0x2a
  800e7e:	68 48 17 80 00       	push   $0x801748
  800e83:	e8 8a 02 00 00       	call   801112 <_panic>
        panic("sys_page_map failed %e\n", r);
  800e88:	50                   	push   %eax
  800e89:	68 6d 17 80 00       	push   $0x80176d
  800e8e:	6a 2f                	push   $0x2f
  800e90:	68 48 17 80 00       	push   $0x801748
  800e95:	e8 78 02 00 00       	call   801112 <_panic>
        panic("sys_page_unmap failed %e\n", r);
  800e9a:	50                   	push   %eax
  800e9b:	68 85 17 80 00       	push   $0x801785
  800ea0:	6a 32                	push   $0x32
  800ea2:	68 48 17 80 00       	push   $0x801748
  800ea7:	e8 66 02 00 00       	call   801112 <_panic>

00800eac <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800eac:	f3 0f 1e fb          	endbr32 
  800eb0:	55                   	push   %ebp
  800eb1:	89 e5                	mov    %esp,%ebp
  800eb3:	57                   	push   %edi
  800eb4:	56                   	push   %esi
  800eb5:	53                   	push   %ebx
  800eb6:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");

    // 1. set pgfault handler.
    set_pgfault_handler(pgfault);
  800eb9:	68 d7 0d 80 00       	push   $0x800dd7
  800ebe:	e8 99 02 00 00       	call   80115c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ec3:	b8 07 00 00 00       	mov    $0x7,%eax
  800ec8:	cd 30                	int    $0x30
  800eca:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ecd:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    // 2. exofork.
    envid_t envid = sys_exofork();

    if (envid < 0)
  800ed0:	83 c4 10             	add    $0x10,%esp
  800ed3:	85 c0                	test   %eax,%eax
  800ed5:	78 2a                	js     800f01 <fork+0x55>
        thisenv = &envs[ENVX(my_envid)];
        return 0;
    }
    else {
        // parent
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800ed7:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (envid == 0) {
  800edc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800ee0:	75 4e                	jne    800f30 <fork+0x84>
        envid_t my_envid = sys_getenvid();
  800ee2:	e8 df fc ff ff       	call   800bc6 <sys_getenvid>
        thisenv = &envs[ENVX(my_envid)];
  800ee7:	25 ff 03 00 00       	and    $0x3ff,%eax
  800eec:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800eef:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ef4:	a3 04 20 80 00       	mov    %eax,0x802004
        return 0;
  800ef9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800efc:	e9 f1 00 00 00       	jmp    800ff2 <fork+0x146>
        panic("fork, sys_exofork %e", envid);
  800f01:	50                   	push   %eax
  800f02:	68 9f 17 80 00       	push   $0x80179f
  800f07:	6a 7b                	push   $0x7b
  800f09:	68 48 17 80 00       	push   $0x801748
  800f0e:	e8 ff 01 00 00       	call   801112 <_panic>
        panic("sys_page_map others failed %e\n", r);
  800f13:	50                   	push   %eax
  800f14:	68 e8 17 80 00       	push   $0x8017e8
  800f19:	6a 51                	push   $0x51
  800f1b:	68 48 17 80 00       	push   $0x801748
  800f20:	e8 ed 01 00 00       	call   801112 <_panic>
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800f25:	83 c3 01             	add    $0x1,%ebx
  800f28:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  800f2e:	74 7c                	je     800fac <fork+0x100>
  800f30:	89 de                	mov    %ebx,%esi
  800f32:	c1 e6 0c             	shl    $0xc,%esi
            uintptr_t pgaddr = pn << PGSHIFT;
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800f35:	89 f0                	mov    %esi,%eax
  800f37:	c1 e8 16             	shr    $0x16,%eax
  800f3a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f41:	a8 01                	test   $0x1,%al
  800f43:	74 e0                	je     800f25 <fork+0x79>
                    (uvpt[pn] & PTE_P) ) {
  800f45:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800f4c:	a8 01                	test   $0x1,%al
  800f4e:	74 d5                	je     800f25 <fork+0x79>
    pte_t pte = uvpt[pn];
  800f50:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
    if ( (pte & PTE_W) || (pte & PTE_COW) ) {
  800f57:	25 02 08 00 00       	and    $0x802,%eax
        perm |= PTE_COW;
  800f5c:	83 f8 01             	cmp    $0x1,%eax
  800f5f:	19 ff                	sbb    %edi,%edi
  800f61:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  800f67:	81 c7 05 08 00 00    	add    $0x805,%edi
    if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0) {
  800f6d:	83 ec 0c             	sub    $0xc,%esp
  800f70:	57                   	push   %edi
  800f71:	56                   	push   %esi
  800f72:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f75:	56                   	push   %esi
  800f76:	6a 00                	push   $0x0
  800f78:	e8 d6 fc ff ff       	call   800c53 <sys_page_map>
  800f7d:	83 c4 20             	add    $0x20,%esp
  800f80:	85 c0                	test   %eax,%eax
  800f82:	78 8f                	js     800f13 <fork+0x67>
        if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0) {
  800f84:	83 ec 0c             	sub    $0xc,%esp
  800f87:	57                   	push   %edi
  800f88:	56                   	push   %esi
  800f89:	6a 00                	push   $0x0
  800f8b:	56                   	push   %esi
  800f8c:	6a 00                	push   $0x0
  800f8e:	e8 c0 fc ff ff       	call   800c53 <sys_page_map>
  800f93:	83 c4 20             	add    $0x20,%esp
  800f96:	85 c0                	test   %eax,%eax
  800f98:	79 8b                	jns    800f25 <fork+0x79>
            panic("sys_page_map mine failed %e\n", r);
  800f9a:	50                   	push   %eax
  800f9b:	68 b4 17 80 00       	push   $0x8017b4
  800fa0:	6a 56                	push   $0x56
  800fa2:	68 48 17 80 00       	push   $0x801748
  800fa7:	e8 66 01 00 00       	call   801112 <_panic>
            }
        }

        int r;

        if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE),
  800fac:	83 ec 04             	sub    $0x4,%esp
  800faf:	6a 07                	push   $0x7
  800fb1:	68 00 f0 bf ee       	push   $0xeebff000
  800fb6:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800fb9:	57                   	push   %edi
  800fba:	e8 4d fc ff ff       	call   800c0c <sys_page_alloc>
  800fbf:	83 c4 10             	add    $0x10,%esp
  800fc2:	85 c0                	test   %eax,%eax
  800fc4:	78 2c                	js     800ff2 <fork+0x146>
                    PTE_U | PTE_W | PTE_P)) < 0) {
            return r;
        }

        if ((r = sys_env_set_pgfault_upcall(envid,
                        thisenv->env_pgfault_upcall)) < 0) {
  800fc6:	a1 04 20 80 00       	mov    0x802004,%eax
        if ((r = sys_env_set_pgfault_upcall(envid,
  800fcb:	8b 40 64             	mov    0x64(%eax),%eax
  800fce:	83 ec 08             	sub    $0x8,%esp
  800fd1:	50                   	push   %eax
  800fd2:	57                   	push   %edi
  800fd3:	e8 4d fd ff ff       	call   800d25 <sys_env_set_pgfault_upcall>
  800fd8:	83 c4 10             	add    $0x10,%esp
  800fdb:	85 c0                	test   %eax,%eax
  800fdd:	78 13                	js     800ff2 <fork+0x146>
            return r;
        }

        if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  800fdf:	83 ec 08             	sub    $0x8,%esp
  800fe2:	6a 02                	push   $0x2
  800fe4:	57                   	push   %edi
  800fe5:	e8 f5 fc ff ff       	call   800cdf <sys_env_set_status>
  800fea:	83 c4 10             	add    $0x10,%esp
            return r;
        }
        return envid;
  800fed:	85 c0                	test   %eax,%eax
  800fef:	0f 49 c7             	cmovns %edi,%eax
    }

}
  800ff2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ff5:	5b                   	pop    %ebx
  800ff6:	5e                   	pop    %esi
  800ff7:	5f                   	pop    %edi
  800ff8:	5d                   	pop    %ebp
  800ff9:	c3                   	ret    

00800ffa <sfork>:

// Challenge!
int
sfork(void)
{
  800ffa:	f3 0f 1e fb          	endbr32 
  800ffe:	55                   	push   %ebp
  800fff:	89 e5                	mov    %esp,%ebp
  801001:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801004:	68 d1 17 80 00       	push   $0x8017d1
  801009:	68 a5 00 00 00       	push   $0xa5
  80100e:	68 48 17 80 00       	push   $0x801748
  801013:	e8 fa 00 00 00       	call   801112 <_panic>

00801018 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801018:	f3 0f 1e fb          	endbr32 
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	56                   	push   %esi
  801020:	53                   	push   %ebx
  801021:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801024:	8b 45 0c             	mov    0xc(%ebp),%eax
  801027:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  80102a:	85 c0                	test   %eax,%eax
  80102c:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801031:	0f 44 c2             	cmove  %edx,%eax
  801034:	83 ec 0c             	sub    $0xc,%esp
  801037:	50                   	push   %eax
  801038:	e8 55 fd ff ff       	call   800d92 <sys_ipc_recv>
  80103d:	83 c4 10             	add    $0x10,%esp
  801040:	85 c0                	test   %eax,%eax
  801042:	78 24                	js     801068 <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801044:	85 f6                	test   %esi,%esi
  801046:	74 0a                	je     801052 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801048:	a1 04 20 80 00       	mov    0x802004,%eax
  80104d:	8b 40 78             	mov    0x78(%eax),%eax
  801050:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801052:	85 db                	test   %ebx,%ebx
  801054:	74 0a                	je     801060 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801056:	a1 04 20 80 00       	mov    0x802004,%eax
  80105b:	8b 40 74             	mov    0x74(%eax),%eax
  80105e:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801060:	a1 04 20 80 00       	mov    0x802004,%eax
  801065:	8b 40 70             	mov    0x70(%eax),%eax
}
  801068:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80106b:	5b                   	pop    %ebx
  80106c:	5e                   	pop    %esi
  80106d:	5d                   	pop    %ebp
  80106e:	c3                   	ret    

0080106f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80106f:	f3 0f 1e fb          	endbr32 
  801073:	55                   	push   %ebp
  801074:	89 e5                	mov    %esp,%ebp
  801076:	57                   	push   %edi
  801077:	56                   	push   %esi
  801078:	53                   	push   %ebx
  801079:	83 ec 1c             	sub    $0x1c,%esp
  80107c:	8b 45 10             	mov    0x10(%ebp),%eax
  80107f:	85 c0                	test   %eax,%eax
  801081:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801086:	0f 45 d0             	cmovne %eax,%edx
  801089:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  80108b:	be 01 00 00 00       	mov    $0x1,%esi
  801090:	eb 1f                	jmp    8010b1 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801092:	e8 52 fb ff ff       	call   800be9 <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801097:	83 c3 01             	add    $0x1,%ebx
  80109a:	39 de                	cmp    %ebx,%esi
  80109c:	7f f4                	jg     801092 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  80109e:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  8010a0:	83 fe 11             	cmp    $0x11,%esi
  8010a3:	b8 01 00 00 00       	mov    $0x1,%eax
  8010a8:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  8010ab:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  8010af:	75 1c                	jne    8010cd <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  8010b1:	ff 75 14             	pushl  0x14(%ebp)
  8010b4:	57                   	push   %edi
  8010b5:	ff 75 0c             	pushl  0xc(%ebp)
  8010b8:	ff 75 08             	pushl  0x8(%ebp)
  8010bb:	e8 ab fc ff ff       	call   800d6b <sys_ipc_try_send>
  8010c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  8010c3:	83 c4 10             	add    $0x10,%esp
  8010c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010cb:	eb cd                	jmp    80109a <ipc_send+0x2b>
}
  8010cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d0:	5b                   	pop    %ebx
  8010d1:	5e                   	pop    %esi
  8010d2:	5f                   	pop    %edi
  8010d3:	5d                   	pop    %ebp
  8010d4:	c3                   	ret    

008010d5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8010d5:	f3 0f 1e fb          	endbr32 
  8010d9:	55                   	push   %ebp
  8010da:	89 e5                	mov    %esp,%ebp
  8010dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8010df:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8010e4:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8010e7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8010ed:	8b 52 50             	mov    0x50(%edx),%edx
  8010f0:	39 ca                	cmp    %ecx,%edx
  8010f2:	74 11                	je     801105 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8010f4:	83 c0 01             	add    $0x1,%eax
  8010f7:	3d 00 04 00 00       	cmp    $0x400,%eax
  8010fc:	75 e6                	jne    8010e4 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8010fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801103:	eb 0b                	jmp    801110 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801105:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801108:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80110d:	8b 40 48             	mov    0x48(%eax),%eax
}
  801110:	5d                   	pop    %ebp
  801111:	c3                   	ret    

00801112 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801112:	f3 0f 1e fb          	endbr32 
  801116:	55                   	push   %ebp
  801117:	89 e5                	mov    %esp,%ebp
  801119:	56                   	push   %esi
  80111a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80111b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80111e:	8b 35 00 20 80 00    	mov    0x802000,%esi
  801124:	e8 9d fa ff ff       	call   800bc6 <sys_getenvid>
  801129:	83 ec 0c             	sub    $0xc,%esp
  80112c:	ff 75 0c             	pushl  0xc(%ebp)
  80112f:	ff 75 08             	pushl  0x8(%ebp)
  801132:	56                   	push   %esi
  801133:	50                   	push   %eax
  801134:	68 08 18 80 00       	push   $0x801808
  801139:	e8 83 f0 ff ff       	call   8001c1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80113e:	83 c4 18             	add    $0x18,%esp
  801141:	53                   	push   %ebx
  801142:	ff 75 10             	pushl  0x10(%ebp)
  801145:	e8 22 f0 ff ff       	call   80016c <vcprintf>
	cprintf("\n");
  80114a:	c7 04 24 38 18 80 00 	movl   $0x801838,(%esp)
  801151:	e8 6b f0 ff ff       	call   8001c1 <cprintf>
  801156:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801159:	cc                   	int3   
  80115a:	eb fd                	jmp    801159 <_panic+0x47>

0080115c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80115c:	f3 0f 1e fb          	endbr32 
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
  801163:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801166:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  80116d:	74 0a                	je     801179 <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80116f:	8b 45 08             	mov    0x8(%ebp),%eax
  801172:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801177:	c9                   	leave  
  801178:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  801179:	83 ec 0c             	sub    $0xc,%esp
  80117c:	68 2b 18 80 00       	push   $0x80182b
  801181:	e8 3b f0 ff ff       	call   8001c1 <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  801186:	83 c4 0c             	add    $0xc,%esp
  801189:	6a 07                	push   $0x7
  80118b:	68 00 f0 bf ee       	push   $0xeebff000
  801190:	6a 00                	push   $0x0
  801192:	e8 75 fa ff ff       	call   800c0c <sys_page_alloc>
  801197:	83 c4 10             	add    $0x10,%esp
  80119a:	85 c0                	test   %eax,%eax
  80119c:	78 2a                	js     8011c8 <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  80119e:	83 ec 08             	sub    $0x8,%esp
  8011a1:	68 dc 11 80 00       	push   $0x8011dc
  8011a6:	6a 00                	push   $0x0
  8011a8:	e8 78 fb ff ff       	call   800d25 <sys_env_set_pgfault_upcall>
  8011ad:	83 c4 10             	add    $0x10,%esp
  8011b0:	85 c0                	test   %eax,%eax
  8011b2:	79 bb                	jns    80116f <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  8011b4:	83 ec 04             	sub    $0x4,%esp
  8011b7:	68 68 18 80 00       	push   $0x801868
  8011bc:	6a 25                	push   $0x25
  8011be:	68 58 18 80 00       	push   $0x801858
  8011c3:	e8 4a ff ff ff       	call   801112 <_panic>
            panic("Allocation of UXSTACK failed!");
  8011c8:	83 ec 04             	sub    $0x4,%esp
  8011cb:	68 3a 18 80 00       	push   $0x80183a
  8011d0:	6a 22                	push   $0x22
  8011d2:	68 58 18 80 00       	push   $0x801858
  8011d7:	e8 36 ff ff ff       	call   801112 <_panic>

008011dc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8011dc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8011dd:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8011e2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8011e4:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  8011e7:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  8011eb:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  8011ef:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  8011f2:	83 c4 08             	add    $0x8,%esp
    popa
  8011f5:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $0x4, %esp
  8011f6:	83 c4 04             	add    $0x4,%esp
    popf
  8011f9:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  8011fa:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  8011fd:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  801201:	c3                   	ret    
  801202:	66 90                	xchg   %ax,%ax
  801204:	66 90                	xchg   %ax,%ax
  801206:	66 90                	xchg   %ax,%ax
  801208:	66 90                	xchg   %ax,%ax
  80120a:	66 90                	xchg   %ax,%ax
  80120c:	66 90                	xchg   %ax,%ax
  80120e:	66 90                	xchg   %ax,%ax

00801210 <__udivdi3>:
  801210:	f3 0f 1e fb          	endbr32 
  801214:	55                   	push   %ebp
  801215:	57                   	push   %edi
  801216:	56                   	push   %esi
  801217:	53                   	push   %ebx
  801218:	83 ec 1c             	sub    $0x1c,%esp
  80121b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80121f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801223:	8b 74 24 34          	mov    0x34(%esp),%esi
  801227:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80122b:	85 d2                	test   %edx,%edx
  80122d:	75 19                	jne    801248 <__udivdi3+0x38>
  80122f:	39 f3                	cmp    %esi,%ebx
  801231:	76 4d                	jbe    801280 <__udivdi3+0x70>
  801233:	31 ff                	xor    %edi,%edi
  801235:	89 e8                	mov    %ebp,%eax
  801237:	89 f2                	mov    %esi,%edx
  801239:	f7 f3                	div    %ebx
  80123b:	89 fa                	mov    %edi,%edx
  80123d:	83 c4 1c             	add    $0x1c,%esp
  801240:	5b                   	pop    %ebx
  801241:	5e                   	pop    %esi
  801242:	5f                   	pop    %edi
  801243:	5d                   	pop    %ebp
  801244:	c3                   	ret    
  801245:	8d 76 00             	lea    0x0(%esi),%esi
  801248:	39 f2                	cmp    %esi,%edx
  80124a:	76 14                	jbe    801260 <__udivdi3+0x50>
  80124c:	31 ff                	xor    %edi,%edi
  80124e:	31 c0                	xor    %eax,%eax
  801250:	89 fa                	mov    %edi,%edx
  801252:	83 c4 1c             	add    $0x1c,%esp
  801255:	5b                   	pop    %ebx
  801256:	5e                   	pop    %esi
  801257:	5f                   	pop    %edi
  801258:	5d                   	pop    %ebp
  801259:	c3                   	ret    
  80125a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801260:	0f bd fa             	bsr    %edx,%edi
  801263:	83 f7 1f             	xor    $0x1f,%edi
  801266:	75 48                	jne    8012b0 <__udivdi3+0xa0>
  801268:	39 f2                	cmp    %esi,%edx
  80126a:	72 06                	jb     801272 <__udivdi3+0x62>
  80126c:	31 c0                	xor    %eax,%eax
  80126e:	39 eb                	cmp    %ebp,%ebx
  801270:	77 de                	ja     801250 <__udivdi3+0x40>
  801272:	b8 01 00 00 00       	mov    $0x1,%eax
  801277:	eb d7                	jmp    801250 <__udivdi3+0x40>
  801279:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801280:	89 d9                	mov    %ebx,%ecx
  801282:	85 db                	test   %ebx,%ebx
  801284:	75 0b                	jne    801291 <__udivdi3+0x81>
  801286:	b8 01 00 00 00       	mov    $0x1,%eax
  80128b:	31 d2                	xor    %edx,%edx
  80128d:	f7 f3                	div    %ebx
  80128f:	89 c1                	mov    %eax,%ecx
  801291:	31 d2                	xor    %edx,%edx
  801293:	89 f0                	mov    %esi,%eax
  801295:	f7 f1                	div    %ecx
  801297:	89 c6                	mov    %eax,%esi
  801299:	89 e8                	mov    %ebp,%eax
  80129b:	89 f7                	mov    %esi,%edi
  80129d:	f7 f1                	div    %ecx
  80129f:	89 fa                	mov    %edi,%edx
  8012a1:	83 c4 1c             	add    $0x1c,%esp
  8012a4:	5b                   	pop    %ebx
  8012a5:	5e                   	pop    %esi
  8012a6:	5f                   	pop    %edi
  8012a7:	5d                   	pop    %ebp
  8012a8:	c3                   	ret    
  8012a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012b0:	89 f9                	mov    %edi,%ecx
  8012b2:	b8 20 00 00 00       	mov    $0x20,%eax
  8012b7:	29 f8                	sub    %edi,%eax
  8012b9:	d3 e2                	shl    %cl,%edx
  8012bb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8012bf:	89 c1                	mov    %eax,%ecx
  8012c1:	89 da                	mov    %ebx,%edx
  8012c3:	d3 ea                	shr    %cl,%edx
  8012c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8012c9:	09 d1                	or     %edx,%ecx
  8012cb:	89 f2                	mov    %esi,%edx
  8012cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012d1:	89 f9                	mov    %edi,%ecx
  8012d3:	d3 e3                	shl    %cl,%ebx
  8012d5:	89 c1                	mov    %eax,%ecx
  8012d7:	d3 ea                	shr    %cl,%edx
  8012d9:	89 f9                	mov    %edi,%ecx
  8012db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012df:	89 eb                	mov    %ebp,%ebx
  8012e1:	d3 e6                	shl    %cl,%esi
  8012e3:	89 c1                	mov    %eax,%ecx
  8012e5:	d3 eb                	shr    %cl,%ebx
  8012e7:	09 de                	or     %ebx,%esi
  8012e9:	89 f0                	mov    %esi,%eax
  8012eb:	f7 74 24 08          	divl   0x8(%esp)
  8012ef:	89 d6                	mov    %edx,%esi
  8012f1:	89 c3                	mov    %eax,%ebx
  8012f3:	f7 64 24 0c          	mull   0xc(%esp)
  8012f7:	39 d6                	cmp    %edx,%esi
  8012f9:	72 15                	jb     801310 <__udivdi3+0x100>
  8012fb:	89 f9                	mov    %edi,%ecx
  8012fd:	d3 e5                	shl    %cl,%ebp
  8012ff:	39 c5                	cmp    %eax,%ebp
  801301:	73 04                	jae    801307 <__udivdi3+0xf7>
  801303:	39 d6                	cmp    %edx,%esi
  801305:	74 09                	je     801310 <__udivdi3+0x100>
  801307:	89 d8                	mov    %ebx,%eax
  801309:	31 ff                	xor    %edi,%edi
  80130b:	e9 40 ff ff ff       	jmp    801250 <__udivdi3+0x40>
  801310:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801313:	31 ff                	xor    %edi,%edi
  801315:	e9 36 ff ff ff       	jmp    801250 <__udivdi3+0x40>
  80131a:	66 90                	xchg   %ax,%ax
  80131c:	66 90                	xchg   %ax,%ax
  80131e:	66 90                	xchg   %ax,%ax

00801320 <__umoddi3>:
  801320:	f3 0f 1e fb          	endbr32 
  801324:	55                   	push   %ebp
  801325:	57                   	push   %edi
  801326:	56                   	push   %esi
  801327:	53                   	push   %ebx
  801328:	83 ec 1c             	sub    $0x1c,%esp
  80132b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80132f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801333:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801337:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80133b:	85 c0                	test   %eax,%eax
  80133d:	75 19                	jne    801358 <__umoddi3+0x38>
  80133f:	39 df                	cmp    %ebx,%edi
  801341:	76 5d                	jbe    8013a0 <__umoddi3+0x80>
  801343:	89 f0                	mov    %esi,%eax
  801345:	89 da                	mov    %ebx,%edx
  801347:	f7 f7                	div    %edi
  801349:	89 d0                	mov    %edx,%eax
  80134b:	31 d2                	xor    %edx,%edx
  80134d:	83 c4 1c             	add    $0x1c,%esp
  801350:	5b                   	pop    %ebx
  801351:	5e                   	pop    %esi
  801352:	5f                   	pop    %edi
  801353:	5d                   	pop    %ebp
  801354:	c3                   	ret    
  801355:	8d 76 00             	lea    0x0(%esi),%esi
  801358:	89 f2                	mov    %esi,%edx
  80135a:	39 d8                	cmp    %ebx,%eax
  80135c:	76 12                	jbe    801370 <__umoddi3+0x50>
  80135e:	89 f0                	mov    %esi,%eax
  801360:	89 da                	mov    %ebx,%edx
  801362:	83 c4 1c             	add    $0x1c,%esp
  801365:	5b                   	pop    %ebx
  801366:	5e                   	pop    %esi
  801367:	5f                   	pop    %edi
  801368:	5d                   	pop    %ebp
  801369:	c3                   	ret    
  80136a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801370:	0f bd e8             	bsr    %eax,%ebp
  801373:	83 f5 1f             	xor    $0x1f,%ebp
  801376:	75 50                	jne    8013c8 <__umoddi3+0xa8>
  801378:	39 d8                	cmp    %ebx,%eax
  80137a:	0f 82 e0 00 00 00    	jb     801460 <__umoddi3+0x140>
  801380:	89 d9                	mov    %ebx,%ecx
  801382:	39 f7                	cmp    %esi,%edi
  801384:	0f 86 d6 00 00 00    	jbe    801460 <__umoddi3+0x140>
  80138a:	89 d0                	mov    %edx,%eax
  80138c:	89 ca                	mov    %ecx,%edx
  80138e:	83 c4 1c             	add    $0x1c,%esp
  801391:	5b                   	pop    %ebx
  801392:	5e                   	pop    %esi
  801393:	5f                   	pop    %edi
  801394:	5d                   	pop    %ebp
  801395:	c3                   	ret    
  801396:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80139d:	8d 76 00             	lea    0x0(%esi),%esi
  8013a0:	89 fd                	mov    %edi,%ebp
  8013a2:	85 ff                	test   %edi,%edi
  8013a4:	75 0b                	jne    8013b1 <__umoddi3+0x91>
  8013a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013ab:	31 d2                	xor    %edx,%edx
  8013ad:	f7 f7                	div    %edi
  8013af:	89 c5                	mov    %eax,%ebp
  8013b1:	89 d8                	mov    %ebx,%eax
  8013b3:	31 d2                	xor    %edx,%edx
  8013b5:	f7 f5                	div    %ebp
  8013b7:	89 f0                	mov    %esi,%eax
  8013b9:	f7 f5                	div    %ebp
  8013bb:	89 d0                	mov    %edx,%eax
  8013bd:	31 d2                	xor    %edx,%edx
  8013bf:	eb 8c                	jmp    80134d <__umoddi3+0x2d>
  8013c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013c8:	89 e9                	mov    %ebp,%ecx
  8013ca:	ba 20 00 00 00       	mov    $0x20,%edx
  8013cf:	29 ea                	sub    %ebp,%edx
  8013d1:	d3 e0                	shl    %cl,%eax
  8013d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013d7:	89 d1                	mov    %edx,%ecx
  8013d9:	89 f8                	mov    %edi,%eax
  8013db:	d3 e8                	shr    %cl,%eax
  8013dd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8013e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013e5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8013e9:	09 c1                	or     %eax,%ecx
  8013eb:	89 d8                	mov    %ebx,%eax
  8013ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013f1:	89 e9                	mov    %ebp,%ecx
  8013f3:	d3 e7                	shl    %cl,%edi
  8013f5:	89 d1                	mov    %edx,%ecx
  8013f7:	d3 e8                	shr    %cl,%eax
  8013f9:	89 e9                	mov    %ebp,%ecx
  8013fb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013ff:	d3 e3                	shl    %cl,%ebx
  801401:	89 c7                	mov    %eax,%edi
  801403:	89 d1                	mov    %edx,%ecx
  801405:	89 f0                	mov    %esi,%eax
  801407:	d3 e8                	shr    %cl,%eax
  801409:	89 e9                	mov    %ebp,%ecx
  80140b:	89 fa                	mov    %edi,%edx
  80140d:	d3 e6                	shl    %cl,%esi
  80140f:	09 d8                	or     %ebx,%eax
  801411:	f7 74 24 08          	divl   0x8(%esp)
  801415:	89 d1                	mov    %edx,%ecx
  801417:	89 f3                	mov    %esi,%ebx
  801419:	f7 64 24 0c          	mull   0xc(%esp)
  80141d:	89 c6                	mov    %eax,%esi
  80141f:	89 d7                	mov    %edx,%edi
  801421:	39 d1                	cmp    %edx,%ecx
  801423:	72 06                	jb     80142b <__umoddi3+0x10b>
  801425:	75 10                	jne    801437 <__umoddi3+0x117>
  801427:	39 c3                	cmp    %eax,%ebx
  801429:	73 0c                	jae    801437 <__umoddi3+0x117>
  80142b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80142f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801433:	89 d7                	mov    %edx,%edi
  801435:	89 c6                	mov    %eax,%esi
  801437:	89 ca                	mov    %ecx,%edx
  801439:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80143e:	29 f3                	sub    %esi,%ebx
  801440:	19 fa                	sbb    %edi,%edx
  801442:	89 d0                	mov    %edx,%eax
  801444:	d3 e0                	shl    %cl,%eax
  801446:	89 e9                	mov    %ebp,%ecx
  801448:	d3 eb                	shr    %cl,%ebx
  80144a:	d3 ea                	shr    %cl,%edx
  80144c:	09 d8                	or     %ebx,%eax
  80144e:	83 c4 1c             	add    $0x1c,%esp
  801451:	5b                   	pop    %ebx
  801452:	5e                   	pop    %esi
  801453:	5f                   	pop    %edi
  801454:	5d                   	pop    %ebp
  801455:	c3                   	ret    
  801456:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80145d:	8d 76 00             	lea    0x0(%esi),%esi
  801460:	29 fe                	sub    %edi,%esi
  801462:	19 c3                	sbb    %eax,%ebx
  801464:	89 f2                	mov    %esi,%edx
  801466:	89 d9                	mov    %ebx,%ecx
  801468:	e9 1d ff ff ff       	jmp    80138a <__umoddi3+0x6a>
