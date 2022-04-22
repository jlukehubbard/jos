
obj/user/fairness:     file format elf32-i386


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
  80002c:	e8 74 00 00 00       	call   8000a5 <libmain>
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
  80003a:	56                   	push   %esi
  80003b:	53                   	push   %ebx
  80003c:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003f:	e8 6d 0b 00 00       	call   800bb1 <sys_getenvid>
  800044:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800046:	81 3d 04 20 80 00 7c 	cmpl   $0xeec0007c,0x802004
  80004d:	00 c0 ee 
  800050:	74 2d                	je     80007f <umain+0x4c>
		while (1) {
			ipc_recv(&who, 0, 0);
			cprintf("%x recv from %x\n", id, who);
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800052:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800057:	83 ec 04             	sub    $0x4,%esp
  80005a:	50                   	push   %eax
  80005b:	53                   	push   %ebx
  80005c:	68 d1 11 80 00       	push   $0x8011d1
  800061:	e8 46 01 00 00       	call   8001ac <cprintf>
  800066:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  800069:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  80006e:	6a 00                	push   $0x0
  800070:	6a 00                	push   $0x0
  800072:	6a 00                	push   $0x0
  800074:	50                   	push   %eax
  800075:	e8 e5 0d 00 00       	call   800e5f <ipc_send>
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	eb ea                	jmp    800069 <umain+0x36>
			ipc_recv(&who, 0, 0);
  80007f:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800082:	83 ec 04             	sub    $0x4,%esp
  800085:	6a 00                	push   $0x0
  800087:	6a 00                	push   $0x0
  800089:	56                   	push   %esi
  80008a:	e8 79 0d 00 00       	call   800e08 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80008f:	83 c4 0c             	add    $0xc,%esp
  800092:	ff 75 f4             	pushl  -0xc(%ebp)
  800095:	53                   	push   %ebx
  800096:	68 c0 11 80 00       	push   $0x8011c0
  80009b:	e8 0c 01 00 00       	call   8001ac <cprintf>
  8000a0:	83 c4 10             	add    $0x10,%esp
  8000a3:	eb dd                	jmp    800082 <umain+0x4f>

008000a5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a5:	f3 0f 1e fb          	endbr32 
  8000a9:	55                   	push   %ebp
  8000aa:	89 e5                	mov    %esp,%ebp
  8000ac:	56                   	push   %esi
  8000ad:	53                   	push   %ebx
  8000ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000b1:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000b4:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000bb:	00 00 00 
    envid_t envid = sys_getenvid();
  8000be:	e8 ee 0a 00 00       	call   800bb1 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  8000c3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000c8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d0:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d5:	85 db                	test   %ebx,%ebx
  8000d7:	7e 07                	jle    8000e0 <libmain+0x3b>
		binaryname = argv[0];
  8000d9:	8b 06                	mov    (%esi),%eax
  8000db:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000e0:	83 ec 08             	sub    $0x8,%esp
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	e8 49 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ea:	e8 0a 00 00 00       	call   8000f9 <exit>
}
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f5:	5b                   	pop    %ebx
  8000f6:	5e                   	pop    %esi
  8000f7:	5d                   	pop    %ebp
  8000f8:	c3                   	ret    

008000f9 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f9:	f3 0f 1e fb          	endbr32 
  8000fd:	55                   	push   %ebp
  8000fe:	89 e5                	mov    %esp,%ebp
  800100:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  800103:	6a 00                	push   $0x0
  800105:	e8 62 0a 00 00       	call   800b6c <sys_env_destroy>
}
  80010a:	83 c4 10             	add    $0x10,%esp
  80010d:	c9                   	leave  
  80010e:	c3                   	ret    

0080010f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80010f:	f3 0f 1e fb          	endbr32 
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	53                   	push   %ebx
  800117:	83 ec 04             	sub    $0x4,%esp
  80011a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80011d:	8b 13                	mov    (%ebx),%edx
  80011f:	8d 42 01             	lea    0x1(%edx),%eax
  800122:	89 03                	mov    %eax,(%ebx)
  800124:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800127:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80012b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800130:	74 09                	je     80013b <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800132:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800136:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800139:	c9                   	leave  
  80013a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80013b:	83 ec 08             	sub    $0x8,%esp
  80013e:	68 ff 00 00 00       	push   $0xff
  800143:	8d 43 08             	lea    0x8(%ebx),%eax
  800146:	50                   	push   %eax
  800147:	e8 db 09 00 00       	call   800b27 <sys_cputs>
		b->idx = 0;
  80014c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800152:	83 c4 10             	add    $0x10,%esp
  800155:	eb db                	jmp    800132 <putch+0x23>

00800157 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800157:	f3 0f 1e fb          	endbr32 
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800164:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80016b:	00 00 00 
	b.cnt = 0;
  80016e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800175:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800178:	ff 75 0c             	pushl  0xc(%ebp)
  80017b:	ff 75 08             	pushl  0x8(%ebp)
  80017e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800184:	50                   	push   %eax
  800185:	68 0f 01 80 00       	push   $0x80010f
  80018a:	e8 20 01 00 00       	call   8002af <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018f:	83 c4 08             	add    $0x8,%esp
  800192:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800198:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019e:	50                   	push   %eax
  80019f:	e8 83 09 00 00       	call   800b27 <sys_cputs>

	return b.cnt;
}
  8001a4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001aa:	c9                   	leave  
  8001ab:	c3                   	ret    

008001ac <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ac:	f3 0f 1e fb          	endbr32 
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b9:	50                   	push   %eax
  8001ba:	ff 75 08             	pushl  0x8(%ebp)
  8001bd:	e8 95 ff ff ff       	call   800157 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c2:	c9                   	leave  
  8001c3:	c3                   	ret    

008001c4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	57                   	push   %edi
  8001c8:	56                   	push   %esi
  8001c9:	53                   	push   %ebx
  8001ca:	83 ec 1c             	sub    $0x1c,%esp
  8001cd:	89 c7                	mov    %eax,%edi
  8001cf:	89 d6                	mov    %edx,%esi
  8001d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d7:	89 d1                	mov    %edx,%ecx
  8001d9:	89 c2                	mov    %eax,%edx
  8001db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001de:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001e1:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ea:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001f1:	39 c2                	cmp    %eax,%edx
  8001f3:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001f6:	72 3e                	jb     800236 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f8:	83 ec 0c             	sub    $0xc,%esp
  8001fb:	ff 75 18             	pushl  0x18(%ebp)
  8001fe:	83 eb 01             	sub    $0x1,%ebx
  800201:	53                   	push   %ebx
  800202:	50                   	push   %eax
  800203:	83 ec 08             	sub    $0x8,%esp
  800206:	ff 75 e4             	pushl  -0x1c(%ebp)
  800209:	ff 75 e0             	pushl  -0x20(%ebp)
  80020c:	ff 75 dc             	pushl  -0x24(%ebp)
  80020f:	ff 75 d8             	pushl  -0x28(%ebp)
  800212:	e8 39 0d 00 00       	call   800f50 <__udivdi3>
  800217:	83 c4 18             	add    $0x18,%esp
  80021a:	52                   	push   %edx
  80021b:	50                   	push   %eax
  80021c:	89 f2                	mov    %esi,%edx
  80021e:	89 f8                	mov    %edi,%eax
  800220:	e8 9f ff ff ff       	call   8001c4 <printnum>
  800225:	83 c4 20             	add    $0x20,%esp
  800228:	eb 13                	jmp    80023d <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022a:	83 ec 08             	sub    $0x8,%esp
  80022d:	56                   	push   %esi
  80022e:	ff 75 18             	pushl  0x18(%ebp)
  800231:	ff d7                	call   *%edi
  800233:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800236:	83 eb 01             	sub    $0x1,%ebx
  800239:	85 db                	test   %ebx,%ebx
  80023b:	7f ed                	jg     80022a <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023d:	83 ec 08             	sub    $0x8,%esp
  800240:	56                   	push   %esi
  800241:	83 ec 04             	sub    $0x4,%esp
  800244:	ff 75 e4             	pushl  -0x1c(%ebp)
  800247:	ff 75 e0             	pushl  -0x20(%ebp)
  80024a:	ff 75 dc             	pushl  -0x24(%ebp)
  80024d:	ff 75 d8             	pushl  -0x28(%ebp)
  800250:	e8 0b 0e 00 00       	call   801060 <__umoddi3>
  800255:	83 c4 14             	add    $0x14,%esp
  800258:	0f be 80 f2 11 80 00 	movsbl 0x8011f2(%eax),%eax
  80025f:	50                   	push   %eax
  800260:	ff d7                	call   *%edi
}
  800262:	83 c4 10             	add    $0x10,%esp
  800265:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800268:	5b                   	pop    %ebx
  800269:	5e                   	pop    %esi
  80026a:	5f                   	pop    %edi
  80026b:	5d                   	pop    %ebp
  80026c:	c3                   	ret    

0080026d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80026d:	f3 0f 1e fb          	endbr32 
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800277:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80027b:	8b 10                	mov    (%eax),%edx
  80027d:	3b 50 04             	cmp    0x4(%eax),%edx
  800280:	73 0a                	jae    80028c <sprintputch+0x1f>
		*b->buf++ = ch;
  800282:	8d 4a 01             	lea    0x1(%edx),%ecx
  800285:	89 08                	mov    %ecx,(%eax)
  800287:	8b 45 08             	mov    0x8(%ebp),%eax
  80028a:	88 02                	mov    %al,(%edx)
}
  80028c:	5d                   	pop    %ebp
  80028d:	c3                   	ret    

0080028e <printfmt>:
{
  80028e:	f3 0f 1e fb          	endbr32 
  800292:	55                   	push   %ebp
  800293:	89 e5                	mov    %esp,%ebp
  800295:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800298:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80029b:	50                   	push   %eax
  80029c:	ff 75 10             	pushl  0x10(%ebp)
  80029f:	ff 75 0c             	pushl  0xc(%ebp)
  8002a2:	ff 75 08             	pushl  0x8(%ebp)
  8002a5:	e8 05 00 00 00       	call   8002af <vprintfmt>
}
  8002aa:	83 c4 10             	add    $0x10,%esp
  8002ad:	c9                   	leave  
  8002ae:	c3                   	ret    

008002af <vprintfmt>:
{
  8002af:	f3 0f 1e fb          	endbr32 
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	57                   	push   %edi
  8002b7:	56                   	push   %esi
  8002b8:	53                   	push   %ebx
  8002b9:	83 ec 3c             	sub    $0x3c,%esp
  8002bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8002bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002c2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002c5:	e9 4a 03 00 00       	jmp    800614 <vprintfmt+0x365>
		padc = ' ';
  8002ca:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002ce:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002d5:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002dc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002e3:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002e8:	8d 47 01             	lea    0x1(%edi),%eax
  8002eb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ee:	0f b6 17             	movzbl (%edi),%edx
  8002f1:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002f4:	3c 55                	cmp    $0x55,%al
  8002f6:	0f 87 de 03 00 00    	ja     8006da <vprintfmt+0x42b>
  8002fc:	0f b6 c0             	movzbl %al,%eax
  8002ff:	3e ff 24 85 40 13 80 	notrack jmp *0x801340(,%eax,4)
  800306:	00 
  800307:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80030a:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80030e:	eb d8                	jmp    8002e8 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800310:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800313:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800317:	eb cf                	jmp    8002e8 <vprintfmt+0x39>
  800319:	0f b6 d2             	movzbl %dl,%edx
  80031c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80031f:	b8 00 00 00 00       	mov    $0x0,%eax
  800324:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800327:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80032a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80032e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800331:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800334:	83 f9 09             	cmp    $0x9,%ecx
  800337:	77 55                	ja     80038e <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800339:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80033c:	eb e9                	jmp    800327 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80033e:	8b 45 14             	mov    0x14(%ebp),%eax
  800341:	8b 00                	mov    (%eax),%eax
  800343:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800346:	8b 45 14             	mov    0x14(%ebp),%eax
  800349:	8d 40 04             	lea    0x4(%eax),%eax
  80034c:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80034f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800352:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800356:	79 90                	jns    8002e8 <vprintfmt+0x39>
				width = precision, precision = -1;
  800358:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80035b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80035e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800365:	eb 81                	jmp    8002e8 <vprintfmt+0x39>
  800367:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80036a:	85 c0                	test   %eax,%eax
  80036c:	ba 00 00 00 00       	mov    $0x0,%edx
  800371:	0f 49 d0             	cmovns %eax,%edx
  800374:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800377:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80037a:	e9 69 ff ff ff       	jmp    8002e8 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80037f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800382:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800389:	e9 5a ff ff ff       	jmp    8002e8 <vprintfmt+0x39>
  80038e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800391:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800394:	eb bc                	jmp    800352 <vprintfmt+0xa3>
			lflag++;
  800396:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800399:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80039c:	e9 47 ff ff ff       	jmp    8002e8 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a4:	8d 78 04             	lea    0x4(%eax),%edi
  8003a7:	83 ec 08             	sub    $0x8,%esp
  8003aa:	53                   	push   %ebx
  8003ab:	ff 30                	pushl  (%eax)
  8003ad:	ff d6                	call   *%esi
			break;
  8003af:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003b2:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003b5:	e9 57 02 00 00       	jmp    800611 <vprintfmt+0x362>
			err = va_arg(ap, int);
  8003ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bd:	8d 78 04             	lea    0x4(%eax),%edi
  8003c0:	8b 00                	mov    (%eax),%eax
  8003c2:	99                   	cltd   
  8003c3:	31 d0                	xor    %edx,%eax
  8003c5:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c7:	83 f8 0f             	cmp    $0xf,%eax
  8003ca:	7f 23                	jg     8003ef <vprintfmt+0x140>
  8003cc:	8b 14 85 a0 14 80 00 	mov    0x8014a0(,%eax,4),%edx
  8003d3:	85 d2                	test   %edx,%edx
  8003d5:	74 18                	je     8003ef <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8003d7:	52                   	push   %edx
  8003d8:	68 13 12 80 00       	push   $0x801213
  8003dd:	53                   	push   %ebx
  8003de:	56                   	push   %esi
  8003df:	e8 aa fe ff ff       	call   80028e <printfmt>
  8003e4:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003e7:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003ea:	e9 22 02 00 00       	jmp    800611 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8003ef:	50                   	push   %eax
  8003f0:	68 0a 12 80 00       	push   $0x80120a
  8003f5:	53                   	push   %ebx
  8003f6:	56                   	push   %esi
  8003f7:	e8 92 fe ff ff       	call   80028e <printfmt>
  8003fc:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003ff:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800402:	e9 0a 02 00 00       	jmp    800611 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  800407:	8b 45 14             	mov    0x14(%ebp),%eax
  80040a:	83 c0 04             	add    $0x4,%eax
  80040d:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800410:	8b 45 14             	mov    0x14(%ebp),%eax
  800413:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800415:	85 d2                	test   %edx,%edx
  800417:	b8 03 12 80 00       	mov    $0x801203,%eax
  80041c:	0f 45 c2             	cmovne %edx,%eax
  80041f:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800422:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800426:	7e 06                	jle    80042e <vprintfmt+0x17f>
  800428:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80042c:	75 0d                	jne    80043b <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80042e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800431:	89 c7                	mov    %eax,%edi
  800433:	03 45 e0             	add    -0x20(%ebp),%eax
  800436:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800439:	eb 55                	jmp    800490 <vprintfmt+0x1e1>
  80043b:	83 ec 08             	sub    $0x8,%esp
  80043e:	ff 75 d8             	pushl  -0x28(%ebp)
  800441:	ff 75 cc             	pushl  -0x34(%ebp)
  800444:	e8 45 03 00 00       	call   80078e <strnlen>
  800449:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80044c:	29 c2                	sub    %eax,%edx
  80044e:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800451:	83 c4 10             	add    $0x10,%esp
  800454:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800456:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80045a:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80045d:	85 ff                	test   %edi,%edi
  80045f:	7e 11                	jle    800472 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800461:	83 ec 08             	sub    $0x8,%esp
  800464:	53                   	push   %ebx
  800465:	ff 75 e0             	pushl  -0x20(%ebp)
  800468:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80046a:	83 ef 01             	sub    $0x1,%edi
  80046d:	83 c4 10             	add    $0x10,%esp
  800470:	eb eb                	jmp    80045d <vprintfmt+0x1ae>
  800472:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800475:	85 d2                	test   %edx,%edx
  800477:	b8 00 00 00 00       	mov    $0x0,%eax
  80047c:	0f 49 c2             	cmovns %edx,%eax
  80047f:	29 c2                	sub    %eax,%edx
  800481:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800484:	eb a8                	jmp    80042e <vprintfmt+0x17f>
					putch(ch, putdat);
  800486:	83 ec 08             	sub    $0x8,%esp
  800489:	53                   	push   %ebx
  80048a:	52                   	push   %edx
  80048b:	ff d6                	call   *%esi
  80048d:	83 c4 10             	add    $0x10,%esp
  800490:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800493:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800495:	83 c7 01             	add    $0x1,%edi
  800498:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80049c:	0f be d0             	movsbl %al,%edx
  80049f:	85 d2                	test   %edx,%edx
  8004a1:	74 4b                	je     8004ee <vprintfmt+0x23f>
  8004a3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004a7:	78 06                	js     8004af <vprintfmt+0x200>
  8004a9:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004ad:	78 1e                	js     8004cd <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004af:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004b3:	74 d1                	je     800486 <vprintfmt+0x1d7>
  8004b5:	0f be c0             	movsbl %al,%eax
  8004b8:	83 e8 20             	sub    $0x20,%eax
  8004bb:	83 f8 5e             	cmp    $0x5e,%eax
  8004be:	76 c6                	jbe    800486 <vprintfmt+0x1d7>
					putch('?', putdat);
  8004c0:	83 ec 08             	sub    $0x8,%esp
  8004c3:	53                   	push   %ebx
  8004c4:	6a 3f                	push   $0x3f
  8004c6:	ff d6                	call   *%esi
  8004c8:	83 c4 10             	add    $0x10,%esp
  8004cb:	eb c3                	jmp    800490 <vprintfmt+0x1e1>
  8004cd:	89 cf                	mov    %ecx,%edi
  8004cf:	eb 0e                	jmp    8004df <vprintfmt+0x230>
				putch(' ', putdat);
  8004d1:	83 ec 08             	sub    $0x8,%esp
  8004d4:	53                   	push   %ebx
  8004d5:	6a 20                	push   $0x20
  8004d7:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004d9:	83 ef 01             	sub    $0x1,%edi
  8004dc:	83 c4 10             	add    $0x10,%esp
  8004df:	85 ff                	test   %edi,%edi
  8004e1:	7f ee                	jg     8004d1 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8004e3:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004e6:	89 45 14             	mov    %eax,0x14(%ebp)
  8004e9:	e9 23 01 00 00       	jmp    800611 <vprintfmt+0x362>
  8004ee:	89 cf                	mov    %ecx,%edi
  8004f0:	eb ed                	jmp    8004df <vprintfmt+0x230>
	if (lflag >= 2)
  8004f2:	83 f9 01             	cmp    $0x1,%ecx
  8004f5:	7f 1b                	jg     800512 <vprintfmt+0x263>
	else if (lflag)
  8004f7:	85 c9                	test   %ecx,%ecx
  8004f9:	74 63                	je     80055e <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8004fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fe:	8b 00                	mov    (%eax),%eax
  800500:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800503:	99                   	cltd   
  800504:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800507:	8b 45 14             	mov    0x14(%ebp),%eax
  80050a:	8d 40 04             	lea    0x4(%eax),%eax
  80050d:	89 45 14             	mov    %eax,0x14(%ebp)
  800510:	eb 17                	jmp    800529 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800512:	8b 45 14             	mov    0x14(%ebp),%eax
  800515:	8b 50 04             	mov    0x4(%eax),%edx
  800518:	8b 00                	mov    (%eax),%eax
  80051a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800520:	8b 45 14             	mov    0x14(%ebp),%eax
  800523:	8d 40 08             	lea    0x8(%eax),%eax
  800526:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800529:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80052c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80052f:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800534:	85 c9                	test   %ecx,%ecx
  800536:	0f 89 bb 00 00 00    	jns    8005f7 <vprintfmt+0x348>
				putch('-', putdat);
  80053c:	83 ec 08             	sub    $0x8,%esp
  80053f:	53                   	push   %ebx
  800540:	6a 2d                	push   $0x2d
  800542:	ff d6                	call   *%esi
				num = -(long long) num;
  800544:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800547:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80054a:	f7 da                	neg    %edx
  80054c:	83 d1 00             	adc    $0x0,%ecx
  80054f:	f7 d9                	neg    %ecx
  800551:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800554:	b8 0a 00 00 00       	mov    $0xa,%eax
  800559:	e9 99 00 00 00       	jmp    8005f7 <vprintfmt+0x348>
		return va_arg(*ap, int);
  80055e:	8b 45 14             	mov    0x14(%ebp),%eax
  800561:	8b 00                	mov    (%eax),%eax
  800563:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800566:	99                   	cltd   
  800567:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80056a:	8b 45 14             	mov    0x14(%ebp),%eax
  80056d:	8d 40 04             	lea    0x4(%eax),%eax
  800570:	89 45 14             	mov    %eax,0x14(%ebp)
  800573:	eb b4                	jmp    800529 <vprintfmt+0x27a>
	if (lflag >= 2)
  800575:	83 f9 01             	cmp    $0x1,%ecx
  800578:	7f 1b                	jg     800595 <vprintfmt+0x2e6>
	else if (lflag)
  80057a:	85 c9                	test   %ecx,%ecx
  80057c:	74 2c                	je     8005aa <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  80057e:	8b 45 14             	mov    0x14(%ebp),%eax
  800581:	8b 10                	mov    (%eax),%edx
  800583:	b9 00 00 00 00       	mov    $0x0,%ecx
  800588:	8d 40 04             	lea    0x4(%eax),%eax
  80058b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80058e:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800593:	eb 62                	jmp    8005f7 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	8b 10                	mov    (%eax),%edx
  80059a:	8b 48 04             	mov    0x4(%eax),%ecx
  80059d:	8d 40 08             	lea    0x8(%eax),%eax
  8005a0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005a3:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005a8:	eb 4d                	jmp    8005f7 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8005aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ad:	8b 10                	mov    (%eax),%edx
  8005af:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b4:	8d 40 04             	lea    0x4(%eax),%eax
  8005b7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ba:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8005bf:	eb 36                	jmp    8005f7 <vprintfmt+0x348>
	if (lflag >= 2)
  8005c1:	83 f9 01             	cmp    $0x1,%ecx
  8005c4:	7f 17                	jg     8005dd <vprintfmt+0x32e>
	else if (lflag)
  8005c6:	85 c9                	test   %ecx,%ecx
  8005c8:	74 6e                	je     800638 <vprintfmt+0x389>
		return va_arg(*ap, long);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8b 10                	mov    (%eax),%edx
  8005cf:	89 d0                	mov    %edx,%eax
  8005d1:	99                   	cltd   
  8005d2:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005d5:	8d 49 04             	lea    0x4(%ecx),%ecx
  8005d8:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005db:	eb 11                	jmp    8005ee <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8b 50 04             	mov    0x4(%eax),%edx
  8005e3:	8b 00                	mov    (%eax),%eax
  8005e5:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005e8:	8d 49 08             	lea    0x8(%ecx),%ecx
  8005eb:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8005ee:	89 d1                	mov    %edx,%ecx
  8005f0:	89 c2                	mov    %eax,%edx
            base = 8;
  8005f2:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005f7:	83 ec 0c             	sub    $0xc,%esp
  8005fa:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005fe:	57                   	push   %edi
  8005ff:	ff 75 e0             	pushl  -0x20(%ebp)
  800602:	50                   	push   %eax
  800603:	51                   	push   %ecx
  800604:	52                   	push   %edx
  800605:	89 da                	mov    %ebx,%edx
  800607:	89 f0                	mov    %esi,%eax
  800609:	e8 b6 fb ff ff       	call   8001c4 <printnum>
			break;
  80060e:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800611:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800614:	83 c7 01             	add    $0x1,%edi
  800617:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80061b:	83 f8 25             	cmp    $0x25,%eax
  80061e:	0f 84 a6 fc ff ff    	je     8002ca <vprintfmt+0x1b>
			if (ch == '\0')
  800624:	85 c0                	test   %eax,%eax
  800626:	0f 84 ce 00 00 00    	je     8006fa <vprintfmt+0x44b>
			putch(ch, putdat);
  80062c:	83 ec 08             	sub    $0x8,%esp
  80062f:	53                   	push   %ebx
  800630:	50                   	push   %eax
  800631:	ff d6                	call   *%esi
  800633:	83 c4 10             	add    $0x10,%esp
  800636:	eb dc                	jmp    800614 <vprintfmt+0x365>
		return va_arg(*ap, int);
  800638:	8b 45 14             	mov    0x14(%ebp),%eax
  80063b:	8b 10                	mov    (%eax),%edx
  80063d:	89 d0                	mov    %edx,%eax
  80063f:	99                   	cltd   
  800640:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800643:	8d 49 04             	lea    0x4(%ecx),%ecx
  800646:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800649:	eb a3                	jmp    8005ee <vprintfmt+0x33f>
			putch('0', putdat);
  80064b:	83 ec 08             	sub    $0x8,%esp
  80064e:	53                   	push   %ebx
  80064f:	6a 30                	push   $0x30
  800651:	ff d6                	call   *%esi
			putch('x', putdat);
  800653:	83 c4 08             	add    $0x8,%esp
  800656:	53                   	push   %ebx
  800657:	6a 78                	push   $0x78
  800659:	ff d6                	call   *%esi
			num = (unsigned long long)
  80065b:	8b 45 14             	mov    0x14(%ebp),%eax
  80065e:	8b 10                	mov    (%eax),%edx
  800660:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800665:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800668:	8d 40 04             	lea    0x4(%eax),%eax
  80066b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80066e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800673:	eb 82                	jmp    8005f7 <vprintfmt+0x348>
	if (lflag >= 2)
  800675:	83 f9 01             	cmp    $0x1,%ecx
  800678:	7f 1e                	jg     800698 <vprintfmt+0x3e9>
	else if (lflag)
  80067a:	85 c9                	test   %ecx,%ecx
  80067c:	74 32                	je     8006b0 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8b 10                	mov    (%eax),%edx
  800683:	b9 00 00 00 00       	mov    $0x0,%ecx
  800688:	8d 40 04             	lea    0x4(%eax),%eax
  80068b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80068e:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800693:	e9 5f ff ff ff       	jmp    8005f7 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8b 10                	mov    (%eax),%edx
  80069d:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a0:	8d 40 08             	lea    0x8(%eax),%eax
  8006a3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a6:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006ab:	e9 47 ff ff ff       	jmp    8005f7 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8006b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b3:	8b 10                	mov    (%eax),%edx
  8006b5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ba:	8d 40 04             	lea    0x4(%eax),%eax
  8006bd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c0:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006c5:	e9 2d ff ff ff       	jmp    8005f7 <vprintfmt+0x348>
			putch(ch, putdat);
  8006ca:	83 ec 08             	sub    $0x8,%esp
  8006cd:	53                   	push   %ebx
  8006ce:	6a 25                	push   $0x25
  8006d0:	ff d6                	call   *%esi
			break;
  8006d2:	83 c4 10             	add    $0x10,%esp
  8006d5:	e9 37 ff ff ff       	jmp    800611 <vprintfmt+0x362>
			putch('%', putdat);
  8006da:	83 ec 08             	sub    $0x8,%esp
  8006dd:	53                   	push   %ebx
  8006de:	6a 25                	push   $0x25
  8006e0:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e2:	83 c4 10             	add    $0x10,%esp
  8006e5:	89 f8                	mov    %edi,%eax
  8006e7:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006eb:	74 05                	je     8006f2 <vprintfmt+0x443>
  8006ed:	83 e8 01             	sub    $0x1,%eax
  8006f0:	eb f5                	jmp    8006e7 <vprintfmt+0x438>
  8006f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006f5:	e9 17 ff ff ff       	jmp    800611 <vprintfmt+0x362>
}
  8006fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006fd:	5b                   	pop    %ebx
  8006fe:	5e                   	pop    %esi
  8006ff:	5f                   	pop    %edi
  800700:	5d                   	pop    %ebp
  800701:	c3                   	ret    

00800702 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800702:	f3 0f 1e fb          	endbr32 
  800706:	55                   	push   %ebp
  800707:	89 e5                	mov    %esp,%ebp
  800709:	83 ec 18             	sub    $0x18,%esp
  80070c:	8b 45 08             	mov    0x8(%ebp),%eax
  80070f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800712:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800715:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800719:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80071c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800723:	85 c0                	test   %eax,%eax
  800725:	74 26                	je     80074d <vsnprintf+0x4b>
  800727:	85 d2                	test   %edx,%edx
  800729:	7e 22                	jle    80074d <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80072b:	ff 75 14             	pushl  0x14(%ebp)
  80072e:	ff 75 10             	pushl  0x10(%ebp)
  800731:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800734:	50                   	push   %eax
  800735:	68 6d 02 80 00       	push   $0x80026d
  80073a:	e8 70 fb ff ff       	call   8002af <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80073f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800742:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800745:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800748:	83 c4 10             	add    $0x10,%esp
}
  80074b:	c9                   	leave  
  80074c:	c3                   	ret    
		return -E_INVAL;
  80074d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800752:	eb f7                	jmp    80074b <vsnprintf+0x49>

00800754 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800754:	f3 0f 1e fb          	endbr32 
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800761:	50                   	push   %eax
  800762:	ff 75 10             	pushl  0x10(%ebp)
  800765:	ff 75 0c             	pushl  0xc(%ebp)
  800768:	ff 75 08             	pushl  0x8(%ebp)
  80076b:	e8 92 ff ff ff       	call   800702 <vsnprintf>
	va_end(ap);

	return rc;
}
  800770:	c9                   	leave  
  800771:	c3                   	ret    

00800772 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800772:	f3 0f 1e fb          	endbr32 
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80077c:	b8 00 00 00 00       	mov    $0x0,%eax
  800781:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800785:	74 05                	je     80078c <strlen+0x1a>
		n++;
  800787:	83 c0 01             	add    $0x1,%eax
  80078a:	eb f5                	jmp    800781 <strlen+0xf>
	return n;
}
  80078c:	5d                   	pop    %ebp
  80078d:	c3                   	ret    

0080078e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80078e:	f3 0f 1e fb          	endbr32 
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800798:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079b:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a0:	39 d0                	cmp    %edx,%eax
  8007a2:	74 0d                	je     8007b1 <strnlen+0x23>
  8007a4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007a8:	74 05                	je     8007af <strnlen+0x21>
		n++;
  8007aa:	83 c0 01             	add    $0x1,%eax
  8007ad:	eb f1                	jmp    8007a0 <strnlen+0x12>
  8007af:	89 c2                	mov    %eax,%edx
	return n;
}
  8007b1:	89 d0                	mov    %edx,%eax
  8007b3:	5d                   	pop    %ebp
  8007b4:	c3                   	ret    

008007b5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b5:	f3 0f 1e fb          	endbr32 
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	53                   	push   %ebx
  8007bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c8:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007cc:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007cf:	83 c0 01             	add    $0x1,%eax
  8007d2:	84 d2                	test   %dl,%dl
  8007d4:	75 f2                	jne    8007c8 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8007d6:	89 c8                	mov    %ecx,%eax
  8007d8:	5b                   	pop    %ebx
  8007d9:	5d                   	pop    %ebp
  8007da:	c3                   	ret    

008007db <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007db:	f3 0f 1e fb          	endbr32 
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	53                   	push   %ebx
  8007e3:	83 ec 10             	sub    $0x10,%esp
  8007e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e9:	53                   	push   %ebx
  8007ea:	e8 83 ff ff ff       	call   800772 <strlen>
  8007ef:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007f2:	ff 75 0c             	pushl  0xc(%ebp)
  8007f5:	01 d8                	add    %ebx,%eax
  8007f7:	50                   	push   %eax
  8007f8:	e8 b8 ff ff ff       	call   8007b5 <strcpy>
	return dst;
}
  8007fd:	89 d8                	mov    %ebx,%eax
  8007ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800802:	c9                   	leave  
  800803:	c3                   	ret    

00800804 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800804:	f3 0f 1e fb          	endbr32 
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	56                   	push   %esi
  80080c:	53                   	push   %ebx
  80080d:	8b 75 08             	mov    0x8(%ebp),%esi
  800810:	8b 55 0c             	mov    0xc(%ebp),%edx
  800813:	89 f3                	mov    %esi,%ebx
  800815:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800818:	89 f0                	mov    %esi,%eax
  80081a:	39 d8                	cmp    %ebx,%eax
  80081c:	74 11                	je     80082f <strncpy+0x2b>
		*dst++ = *src;
  80081e:	83 c0 01             	add    $0x1,%eax
  800821:	0f b6 0a             	movzbl (%edx),%ecx
  800824:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800827:	80 f9 01             	cmp    $0x1,%cl
  80082a:	83 da ff             	sbb    $0xffffffff,%edx
  80082d:	eb eb                	jmp    80081a <strncpy+0x16>
	}
	return ret;
}
  80082f:	89 f0                	mov    %esi,%eax
  800831:	5b                   	pop    %ebx
  800832:	5e                   	pop    %esi
  800833:	5d                   	pop    %ebp
  800834:	c3                   	ret    

00800835 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800835:	f3 0f 1e fb          	endbr32 
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	56                   	push   %esi
  80083d:	53                   	push   %ebx
  80083e:	8b 75 08             	mov    0x8(%ebp),%esi
  800841:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800844:	8b 55 10             	mov    0x10(%ebp),%edx
  800847:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800849:	85 d2                	test   %edx,%edx
  80084b:	74 21                	je     80086e <strlcpy+0x39>
  80084d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800851:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800853:	39 c2                	cmp    %eax,%edx
  800855:	74 14                	je     80086b <strlcpy+0x36>
  800857:	0f b6 19             	movzbl (%ecx),%ebx
  80085a:	84 db                	test   %bl,%bl
  80085c:	74 0b                	je     800869 <strlcpy+0x34>
			*dst++ = *src++;
  80085e:	83 c1 01             	add    $0x1,%ecx
  800861:	83 c2 01             	add    $0x1,%edx
  800864:	88 5a ff             	mov    %bl,-0x1(%edx)
  800867:	eb ea                	jmp    800853 <strlcpy+0x1e>
  800869:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80086b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80086e:	29 f0                	sub    %esi,%eax
}
  800870:	5b                   	pop    %ebx
  800871:	5e                   	pop    %esi
  800872:	5d                   	pop    %ebp
  800873:	c3                   	ret    

00800874 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800874:	f3 0f 1e fb          	endbr32 
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800881:	0f b6 01             	movzbl (%ecx),%eax
  800884:	84 c0                	test   %al,%al
  800886:	74 0c                	je     800894 <strcmp+0x20>
  800888:	3a 02                	cmp    (%edx),%al
  80088a:	75 08                	jne    800894 <strcmp+0x20>
		p++, q++;
  80088c:	83 c1 01             	add    $0x1,%ecx
  80088f:	83 c2 01             	add    $0x1,%edx
  800892:	eb ed                	jmp    800881 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800894:	0f b6 c0             	movzbl %al,%eax
  800897:	0f b6 12             	movzbl (%edx),%edx
  80089a:	29 d0                	sub    %edx,%eax
}
  80089c:	5d                   	pop    %ebp
  80089d:	c3                   	ret    

0080089e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80089e:	f3 0f 1e fb          	endbr32 
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	53                   	push   %ebx
  8008a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ac:	89 c3                	mov    %eax,%ebx
  8008ae:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b1:	eb 06                	jmp    8008b9 <strncmp+0x1b>
		n--, p++, q++;
  8008b3:	83 c0 01             	add    $0x1,%eax
  8008b6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008b9:	39 d8                	cmp    %ebx,%eax
  8008bb:	74 16                	je     8008d3 <strncmp+0x35>
  8008bd:	0f b6 08             	movzbl (%eax),%ecx
  8008c0:	84 c9                	test   %cl,%cl
  8008c2:	74 04                	je     8008c8 <strncmp+0x2a>
  8008c4:	3a 0a                	cmp    (%edx),%cl
  8008c6:	74 eb                	je     8008b3 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c8:	0f b6 00             	movzbl (%eax),%eax
  8008cb:	0f b6 12             	movzbl (%edx),%edx
  8008ce:	29 d0                	sub    %edx,%eax
}
  8008d0:	5b                   	pop    %ebx
  8008d1:	5d                   	pop    %ebp
  8008d2:	c3                   	ret    
		return 0;
  8008d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d8:	eb f6                	jmp    8008d0 <strncmp+0x32>

008008da <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008da:	f3 0f 1e fb          	endbr32 
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e8:	0f b6 10             	movzbl (%eax),%edx
  8008eb:	84 d2                	test   %dl,%dl
  8008ed:	74 09                	je     8008f8 <strchr+0x1e>
		if (*s == c)
  8008ef:	38 ca                	cmp    %cl,%dl
  8008f1:	74 0a                	je     8008fd <strchr+0x23>
	for (; *s; s++)
  8008f3:	83 c0 01             	add    $0x1,%eax
  8008f6:	eb f0                	jmp    8008e8 <strchr+0xe>
			return (char *) s;
	return 0;
  8008f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008fd:	5d                   	pop    %ebp
  8008fe:	c3                   	ret    

008008ff <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ff:	f3 0f 1e fb          	endbr32 
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	8b 45 08             	mov    0x8(%ebp),%eax
  800909:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80090d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800910:	38 ca                	cmp    %cl,%dl
  800912:	74 09                	je     80091d <strfind+0x1e>
  800914:	84 d2                	test   %dl,%dl
  800916:	74 05                	je     80091d <strfind+0x1e>
	for (; *s; s++)
  800918:	83 c0 01             	add    $0x1,%eax
  80091b:	eb f0                	jmp    80090d <strfind+0xe>
			break;
	return (char *) s;
}
  80091d:	5d                   	pop    %ebp
  80091e:	c3                   	ret    

0080091f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80091f:	f3 0f 1e fb          	endbr32 
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	57                   	push   %edi
  800927:	56                   	push   %esi
  800928:	53                   	push   %ebx
  800929:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80092f:	85 c9                	test   %ecx,%ecx
  800931:	74 31                	je     800964 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800933:	89 f8                	mov    %edi,%eax
  800935:	09 c8                	or     %ecx,%eax
  800937:	a8 03                	test   $0x3,%al
  800939:	75 23                	jne    80095e <memset+0x3f>
		c &= 0xFF;
  80093b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80093f:	89 d3                	mov    %edx,%ebx
  800941:	c1 e3 08             	shl    $0x8,%ebx
  800944:	89 d0                	mov    %edx,%eax
  800946:	c1 e0 18             	shl    $0x18,%eax
  800949:	89 d6                	mov    %edx,%esi
  80094b:	c1 e6 10             	shl    $0x10,%esi
  80094e:	09 f0                	or     %esi,%eax
  800950:	09 c2                	or     %eax,%edx
  800952:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800954:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800957:	89 d0                	mov    %edx,%eax
  800959:	fc                   	cld    
  80095a:	f3 ab                	rep stos %eax,%es:(%edi)
  80095c:	eb 06                	jmp    800964 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80095e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800961:	fc                   	cld    
  800962:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800964:	89 f8                	mov    %edi,%eax
  800966:	5b                   	pop    %ebx
  800967:	5e                   	pop    %esi
  800968:	5f                   	pop    %edi
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80096b:	f3 0f 1e fb          	endbr32 
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	57                   	push   %edi
  800973:	56                   	push   %esi
  800974:	8b 45 08             	mov    0x8(%ebp),%eax
  800977:	8b 75 0c             	mov    0xc(%ebp),%esi
  80097a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80097d:	39 c6                	cmp    %eax,%esi
  80097f:	73 32                	jae    8009b3 <memmove+0x48>
  800981:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800984:	39 c2                	cmp    %eax,%edx
  800986:	76 2b                	jbe    8009b3 <memmove+0x48>
		s += n;
		d += n;
  800988:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098b:	89 fe                	mov    %edi,%esi
  80098d:	09 ce                	or     %ecx,%esi
  80098f:	09 d6                	or     %edx,%esi
  800991:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800997:	75 0e                	jne    8009a7 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800999:	83 ef 04             	sub    $0x4,%edi
  80099c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80099f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009a2:	fd                   	std    
  8009a3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a5:	eb 09                	jmp    8009b0 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009a7:	83 ef 01             	sub    $0x1,%edi
  8009aa:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009ad:	fd                   	std    
  8009ae:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b0:	fc                   	cld    
  8009b1:	eb 1a                	jmp    8009cd <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b3:	89 c2                	mov    %eax,%edx
  8009b5:	09 ca                	or     %ecx,%edx
  8009b7:	09 f2                	or     %esi,%edx
  8009b9:	f6 c2 03             	test   $0x3,%dl
  8009bc:	75 0a                	jne    8009c8 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009be:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009c1:	89 c7                	mov    %eax,%edi
  8009c3:	fc                   	cld    
  8009c4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c6:	eb 05                	jmp    8009cd <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8009c8:	89 c7                	mov    %eax,%edi
  8009ca:	fc                   	cld    
  8009cb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009cd:	5e                   	pop    %esi
  8009ce:	5f                   	pop    %edi
  8009cf:	5d                   	pop    %ebp
  8009d0:	c3                   	ret    

008009d1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d1:	f3 0f 1e fb          	endbr32 
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009db:	ff 75 10             	pushl  0x10(%ebp)
  8009de:	ff 75 0c             	pushl  0xc(%ebp)
  8009e1:	ff 75 08             	pushl  0x8(%ebp)
  8009e4:	e8 82 ff ff ff       	call   80096b <memmove>
}
  8009e9:	c9                   	leave  
  8009ea:	c3                   	ret    

008009eb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009eb:	f3 0f 1e fb          	endbr32 
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	56                   	push   %esi
  8009f3:	53                   	push   %ebx
  8009f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009fa:	89 c6                	mov    %eax,%esi
  8009fc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ff:	39 f0                	cmp    %esi,%eax
  800a01:	74 1c                	je     800a1f <memcmp+0x34>
		if (*s1 != *s2)
  800a03:	0f b6 08             	movzbl (%eax),%ecx
  800a06:	0f b6 1a             	movzbl (%edx),%ebx
  800a09:	38 d9                	cmp    %bl,%cl
  800a0b:	75 08                	jne    800a15 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a0d:	83 c0 01             	add    $0x1,%eax
  800a10:	83 c2 01             	add    $0x1,%edx
  800a13:	eb ea                	jmp    8009ff <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a15:	0f b6 c1             	movzbl %cl,%eax
  800a18:	0f b6 db             	movzbl %bl,%ebx
  800a1b:	29 d8                	sub    %ebx,%eax
  800a1d:	eb 05                	jmp    800a24 <memcmp+0x39>
	}

	return 0;
  800a1f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a24:	5b                   	pop    %ebx
  800a25:	5e                   	pop    %esi
  800a26:	5d                   	pop    %ebp
  800a27:	c3                   	ret    

00800a28 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a28:	f3 0f 1e fb          	endbr32 
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a35:	89 c2                	mov    %eax,%edx
  800a37:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a3a:	39 d0                	cmp    %edx,%eax
  800a3c:	73 09                	jae    800a47 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a3e:	38 08                	cmp    %cl,(%eax)
  800a40:	74 05                	je     800a47 <memfind+0x1f>
	for (; s < ends; s++)
  800a42:	83 c0 01             	add    $0x1,%eax
  800a45:	eb f3                	jmp    800a3a <memfind+0x12>
			break;
	return (void *) s;
}
  800a47:	5d                   	pop    %ebp
  800a48:	c3                   	ret    

00800a49 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a49:	f3 0f 1e fb          	endbr32 
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
  800a50:	57                   	push   %edi
  800a51:	56                   	push   %esi
  800a52:	53                   	push   %ebx
  800a53:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a56:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a59:	eb 03                	jmp    800a5e <strtol+0x15>
		s++;
  800a5b:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a5e:	0f b6 01             	movzbl (%ecx),%eax
  800a61:	3c 20                	cmp    $0x20,%al
  800a63:	74 f6                	je     800a5b <strtol+0x12>
  800a65:	3c 09                	cmp    $0x9,%al
  800a67:	74 f2                	je     800a5b <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a69:	3c 2b                	cmp    $0x2b,%al
  800a6b:	74 2a                	je     800a97 <strtol+0x4e>
	int neg = 0;
  800a6d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a72:	3c 2d                	cmp    $0x2d,%al
  800a74:	74 2b                	je     800aa1 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a76:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a7c:	75 0f                	jne    800a8d <strtol+0x44>
  800a7e:	80 39 30             	cmpb   $0x30,(%ecx)
  800a81:	74 28                	je     800aab <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a83:	85 db                	test   %ebx,%ebx
  800a85:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a8a:	0f 44 d8             	cmove  %eax,%ebx
  800a8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a92:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a95:	eb 46                	jmp    800add <strtol+0x94>
		s++;
  800a97:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a9a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a9f:	eb d5                	jmp    800a76 <strtol+0x2d>
		s++, neg = 1;
  800aa1:	83 c1 01             	add    $0x1,%ecx
  800aa4:	bf 01 00 00 00       	mov    $0x1,%edi
  800aa9:	eb cb                	jmp    800a76 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aab:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aaf:	74 0e                	je     800abf <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ab1:	85 db                	test   %ebx,%ebx
  800ab3:	75 d8                	jne    800a8d <strtol+0x44>
		s++, base = 8;
  800ab5:	83 c1 01             	add    $0x1,%ecx
  800ab8:	bb 08 00 00 00       	mov    $0x8,%ebx
  800abd:	eb ce                	jmp    800a8d <strtol+0x44>
		s += 2, base = 16;
  800abf:	83 c1 02             	add    $0x2,%ecx
  800ac2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac7:	eb c4                	jmp    800a8d <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ac9:	0f be d2             	movsbl %dl,%edx
  800acc:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800acf:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ad2:	7d 3a                	jge    800b0e <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ad4:	83 c1 01             	add    $0x1,%ecx
  800ad7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800adb:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800add:	0f b6 11             	movzbl (%ecx),%edx
  800ae0:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ae3:	89 f3                	mov    %esi,%ebx
  800ae5:	80 fb 09             	cmp    $0x9,%bl
  800ae8:	76 df                	jbe    800ac9 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800aea:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aed:	89 f3                	mov    %esi,%ebx
  800aef:	80 fb 19             	cmp    $0x19,%bl
  800af2:	77 08                	ja     800afc <strtol+0xb3>
			dig = *s - 'a' + 10;
  800af4:	0f be d2             	movsbl %dl,%edx
  800af7:	83 ea 57             	sub    $0x57,%edx
  800afa:	eb d3                	jmp    800acf <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800afc:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aff:	89 f3                	mov    %esi,%ebx
  800b01:	80 fb 19             	cmp    $0x19,%bl
  800b04:	77 08                	ja     800b0e <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b06:	0f be d2             	movsbl %dl,%edx
  800b09:	83 ea 37             	sub    $0x37,%edx
  800b0c:	eb c1                	jmp    800acf <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b0e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b12:	74 05                	je     800b19 <strtol+0xd0>
		*endptr = (char *) s;
  800b14:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b17:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b19:	89 c2                	mov    %eax,%edx
  800b1b:	f7 da                	neg    %edx
  800b1d:	85 ff                	test   %edi,%edi
  800b1f:	0f 45 c2             	cmovne %edx,%eax
}
  800b22:	5b                   	pop    %ebx
  800b23:	5e                   	pop    %esi
  800b24:	5f                   	pop    %edi
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b27:	f3 0f 1e fb          	endbr32 
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	57                   	push   %edi
  800b2f:	56                   	push   %esi
  800b30:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b31:	b8 00 00 00 00       	mov    $0x0,%eax
  800b36:	8b 55 08             	mov    0x8(%ebp),%edx
  800b39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3c:	89 c3                	mov    %eax,%ebx
  800b3e:	89 c7                	mov    %eax,%edi
  800b40:	89 c6                	mov    %eax,%esi
  800b42:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b44:	5b                   	pop    %ebx
  800b45:	5e                   	pop    %esi
  800b46:	5f                   	pop    %edi
  800b47:	5d                   	pop    %ebp
  800b48:	c3                   	ret    

00800b49 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b49:	f3 0f 1e fb          	endbr32 
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	57                   	push   %edi
  800b51:	56                   	push   %esi
  800b52:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b53:	ba 00 00 00 00       	mov    $0x0,%edx
  800b58:	b8 01 00 00 00       	mov    $0x1,%eax
  800b5d:	89 d1                	mov    %edx,%ecx
  800b5f:	89 d3                	mov    %edx,%ebx
  800b61:	89 d7                	mov    %edx,%edi
  800b63:	89 d6                	mov    %edx,%esi
  800b65:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b67:	5b                   	pop    %ebx
  800b68:	5e                   	pop    %esi
  800b69:	5f                   	pop    %edi
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b6c:	f3 0f 1e fb          	endbr32 
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	57                   	push   %edi
  800b74:	56                   	push   %esi
  800b75:	53                   	push   %ebx
  800b76:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b79:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b81:	b8 03 00 00 00       	mov    $0x3,%eax
  800b86:	89 cb                	mov    %ecx,%ebx
  800b88:	89 cf                	mov    %ecx,%edi
  800b8a:	89 ce                	mov    %ecx,%esi
  800b8c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b8e:	85 c0                	test   %eax,%eax
  800b90:	7f 08                	jg     800b9a <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9a:	83 ec 0c             	sub    $0xc,%esp
  800b9d:	50                   	push   %eax
  800b9e:	6a 03                	push   $0x3
  800ba0:	68 ff 14 80 00       	push   $0x8014ff
  800ba5:	6a 23                	push   $0x23
  800ba7:	68 1c 15 80 00       	push   $0x80151c
  800bac:	e8 51 03 00 00       	call   800f02 <_panic>

00800bb1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bb1:	f3 0f 1e fb          	endbr32 
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	57                   	push   %edi
  800bb9:	56                   	push   %esi
  800bba:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bbb:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc0:	b8 02 00 00 00       	mov    $0x2,%eax
  800bc5:	89 d1                	mov    %edx,%ecx
  800bc7:	89 d3                	mov    %edx,%ebx
  800bc9:	89 d7                	mov    %edx,%edi
  800bcb:	89 d6                	mov    %edx,%esi
  800bcd:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bcf:	5b                   	pop    %ebx
  800bd0:	5e                   	pop    %esi
  800bd1:	5f                   	pop    %edi
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <sys_yield>:

void
sys_yield(void)
{
  800bd4:	f3 0f 1e fb          	endbr32 
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	57                   	push   %edi
  800bdc:	56                   	push   %esi
  800bdd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bde:	ba 00 00 00 00       	mov    $0x0,%edx
  800be3:	b8 0b 00 00 00       	mov    $0xb,%eax
  800be8:	89 d1                	mov    %edx,%ecx
  800bea:	89 d3                	mov    %edx,%ebx
  800bec:	89 d7                	mov    %edx,%edi
  800bee:	89 d6                	mov    %edx,%esi
  800bf0:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bf2:	5b                   	pop    %ebx
  800bf3:	5e                   	pop    %esi
  800bf4:	5f                   	pop    %edi
  800bf5:	5d                   	pop    %ebp
  800bf6:	c3                   	ret    

00800bf7 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bf7:	f3 0f 1e fb          	endbr32 
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	57                   	push   %edi
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
  800c01:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c04:	be 00 00 00 00       	mov    $0x0,%esi
  800c09:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c14:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c17:	89 f7                	mov    %esi,%edi
  800c19:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c1b:	85 c0                	test   %eax,%eax
  800c1d:	7f 08                	jg     800c27 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c22:	5b                   	pop    %ebx
  800c23:	5e                   	pop    %esi
  800c24:	5f                   	pop    %edi
  800c25:	5d                   	pop    %ebp
  800c26:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c27:	83 ec 0c             	sub    $0xc,%esp
  800c2a:	50                   	push   %eax
  800c2b:	6a 04                	push   $0x4
  800c2d:	68 ff 14 80 00       	push   $0x8014ff
  800c32:	6a 23                	push   $0x23
  800c34:	68 1c 15 80 00       	push   $0x80151c
  800c39:	e8 c4 02 00 00       	call   800f02 <_panic>

00800c3e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c3e:	f3 0f 1e fb          	endbr32 
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	57                   	push   %edi
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
  800c48:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c51:	b8 05 00 00 00       	mov    $0x5,%eax
  800c56:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c59:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c5c:	8b 75 18             	mov    0x18(%ebp),%esi
  800c5f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c61:	85 c0                	test   %eax,%eax
  800c63:	7f 08                	jg     800c6d <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c68:	5b                   	pop    %ebx
  800c69:	5e                   	pop    %esi
  800c6a:	5f                   	pop    %edi
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6d:	83 ec 0c             	sub    $0xc,%esp
  800c70:	50                   	push   %eax
  800c71:	6a 05                	push   $0x5
  800c73:	68 ff 14 80 00       	push   $0x8014ff
  800c78:	6a 23                	push   $0x23
  800c7a:	68 1c 15 80 00       	push   $0x80151c
  800c7f:	e8 7e 02 00 00       	call   800f02 <_panic>

00800c84 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c84:	f3 0f 1e fb          	endbr32 
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	57                   	push   %edi
  800c8c:	56                   	push   %esi
  800c8d:	53                   	push   %ebx
  800c8e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c91:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c96:	8b 55 08             	mov    0x8(%ebp),%edx
  800c99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9c:	b8 06 00 00 00       	mov    $0x6,%eax
  800ca1:	89 df                	mov    %ebx,%edi
  800ca3:	89 de                	mov    %ebx,%esi
  800ca5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca7:	85 c0                	test   %eax,%eax
  800ca9:	7f 08                	jg     800cb3 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cae:	5b                   	pop    %ebx
  800caf:	5e                   	pop    %esi
  800cb0:	5f                   	pop    %edi
  800cb1:	5d                   	pop    %ebp
  800cb2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb3:	83 ec 0c             	sub    $0xc,%esp
  800cb6:	50                   	push   %eax
  800cb7:	6a 06                	push   $0x6
  800cb9:	68 ff 14 80 00       	push   $0x8014ff
  800cbe:	6a 23                	push   $0x23
  800cc0:	68 1c 15 80 00       	push   $0x80151c
  800cc5:	e8 38 02 00 00       	call   800f02 <_panic>

00800cca <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cca:	f3 0f 1e fb          	endbr32 
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	53                   	push   %ebx
  800cd4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce2:	b8 08 00 00 00       	mov    $0x8,%eax
  800ce7:	89 df                	mov    %ebx,%edi
  800ce9:	89 de                	mov    %ebx,%esi
  800ceb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ced:	85 c0                	test   %eax,%eax
  800cef:	7f 08                	jg     800cf9 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf9:	83 ec 0c             	sub    $0xc,%esp
  800cfc:	50                   	push   %eax
  800cfd:	6a 08                	push   $0x8
  800cff:	68 ff 14 80 00       	push   $0x8014ff
  800d04:	6a 23                	push   $0x23
  800d06:	68 1c 15 80 00       	push   $0x80151c
  800d0b:	e8 f2 01 00 00       	call   800f02 <_panic>

00800d10 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d10:	f3 0f 1e fb          	endbr32 
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	57                   	push   %edi
  800d18:	56                   	push   %esi
  800d19:	53                   	push   %ebx
  800d1a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d22:	8b 55 08             	mov    0x8(%ebp),%edx
  800d25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d28:	b8 09 00 00 00       	mov    $0x9,%eax
  800d2d:	89 df                	mov    %ebx,%edi
  800d2f:	89 de                	mov    %ebx,%esi
  800d31:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d33:	85 c0                	test   %eax,%eax
  800d35:	7f 08                	jg     800d3f <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3a:	5b                   	pop    %ebx
  800d3b:	5e                   	pop    %esi
  800d3c:	5f                   	pop    %edi
  800d3d:	5d                   	pop    %ebp
  800d3e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3f:	83 ec 0c             	sub    $0xc,%esp
  800d42:	50                   	push   %eax
  800d43:	6a 09                	push   $0x9
  800d45:	68 ff 14 80 00       	push   $0x8014ff
  800d4a:	6a 23                	push   $0x23
  800d4c:	68 1c 15 80 00       	push   $0x80151c
  800d51:	e8 ac 01 00 00       	call   800f02 <_panic>

00800d56 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d56:	f3 0f 1e fb          	endbr32 
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	57                   	push   %edi
  800d5e:	56                   	push   %esi
  800d5f:	53                   	push   %ebx
  800d60:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d68:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d73:	89 df                	mov    %ebx,%edi
  800d75:	89 de                	mov    %ebx,%esi
  800d77:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	7f 08                	jg     800d85 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d85:	83 ec 0c             	sub    $0xc,%esp
  800d88:	50                   	push   %eax
  800d89:	6a 0a                	push   $0xa
  800d8b:	68 ff 14 80 00       	push   $0x8014ff
  800d90:	6a 23                	push   $0x23
  800d92:	68 1c 15 80 00       	push   $0x80151c
  800d97:	e8 66 01 00 00       	call   800f02 <_panic>

00800d9c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d9c:	f3 0f 1e fb          	endbr32 
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800da6:	8b 55 08             	mov    0x8(%ebp),%edx
  800da9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dac:	b8 0c 00 00 00       	mov    $0xc,%eax
  800db1:	be 00 00 00 00       	mov    $0x0,%esi
  800db6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dbc:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dbe:	5b                   	pop    %ebx
  800dbf:	5e                   	pop    %esi
  800dc0:	5f                   	pop    %edi
  800dc1:	5d                   	pop    %ebp
  800dc2:	c3                   	ret    

00800dc3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dc3:	f3 0f 1e fb          	endbr32 
  800dc7:	55                   	push   %ebp
  800dc8:	89 e5                	mov    %esp,%ebp
  800dca:	57                   	push   %edi
  800dcb:	56                   	push   %esi
  800dcc:	53                   	push   %ebx
  800dcd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dd0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd8:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ddd:	89 cb                	mov    %ecx,%ebx
  800ddf:	89 cf                	mov    %ecx,%edi
  800de1:	89 ce                	mov    %ecx,%esi
  800de3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800de5:	85 c0                	test   %eax,%eax
  800de7:	7f 08                	jg     800df1 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800de9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dec:	5b                   	pop    %ebx
  800ded:	5e                   	pop    %esi
  800dee:	5f                   	pop    %edi
  800def:	5d                   	pop    %ebp
  800df0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800df1:	83 ec 0c             	sub    $0xc,%esp
  800df4:	50                   	push   %eax
  800df5:	6a 0d                	push   $0xd
  800df7:	68 ff 14 80 00       	push   $0x8014ff
  800dfc:	6a 23                	push   $0x23
  800dfe:	68 1c 15 80 00       	push   $0x80151c
  800e03:	e8 fa 00 00 00       	call   800f02 <_panic>

00800e08 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800e08:	f3 0f 1e fb          	endbr32 
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	56                   	push   %esi
  800e10:	53                   	push   %ebx
  800e11:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e14:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e17:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  800e1a:	85 c0                	test   %eax,%eax
  800e1c:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  800e21:	0f 44 c2             	cmove  %edx,%eax
  800e24:	83 ec 0c             	sub    $0xc,%esp
  800e27:	50                   	push   %eax
  800e28:	e8 96 ff ff ff       	call   800dc3 <sys_ipc_recv>
  800e2d:	83 c4 10             	add    $0x10,%esp
  800e30:	85 c0                	test   %eax,%eax
  800e32:	78 24                	js     800e58 <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  800e34:	85 f6                	test   %esi,%esi
  800e36:	74 0a                	je     800e42 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  800e38:	a1 04 20 80 00       	mov    0x802004,%eax
  800e3d:	8b 40 78             	mov    0x78(%eax),%eax
  800e40:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  800e42:	85 db                	test   %ebx,%ebx
  800e44:	74 0a                	je     800e50 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  800e46:	a1 04 20 80 00       	mov    0x802004,%eax
  800e4b:	8b 40 74             	mov    0x74(%eax),%eax
  800e4e:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  800e50:	a1 04 20 80 00       	mov    0x802004,%eax
  800e55:	8b 40 70             	mov    0x70(%eax),%eax
}
  800e58:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e5b:	5b                   	pop    %ebx
  800e5c:	5e                   	pop    %esi
  800e5d:	5d                   	pop    %ebp
  800e5e:	c3                   	ret    

00800e5f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e5f:	f3 0f 1e fb          	endbr32 
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	57                   	push   %edi
  800e67:	56                   	push   %esi
  800e68:	53                   	push   %ebx
  800e69:	83 ec 1c             	sub    $0x1c,%esp
  800e6c:	8b 45 10             	mov    0x10(%ebp),%eax
  800e6f:	85 c0                	test   %eax,%eax
  800e71:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  800e76:	0f 45 d0             	cmovne %eax,%edx
  800e79:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  800e7b:	be 01 00 00 00       	mov    $0x1,%esi
  800e80:	eb 1f                	jmp    800ea1 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  800e82:	e8 4d fd ff ff       	call   800bd4 <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  800e87:	83 c3 01             	add    $0x1,%ebx
  800e8a:	39 de                	cmp    %ebx,%esi
  800e8c:	7f f4                	jg     800e82 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  800e8e:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  800e90:	83 fe 11             	cmp    $0x11,%esi
  800e93:	b8 01 00 00 00       	mov    $0x1,%eax
  800e98:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  800e9b:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  800e9f:	75 1c                	jne    800ebd <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  800ea1:	ff 75 14             	pushl  0x14(%ebp)
  800ea4:	57                   	push   %edi
  800ea5:	ff 75 0c             	pushl  0xc(%ebp)
  800ea8:	ff 75 08             	pushl  0x8(%ebp)
  800eab:	e8 ec fe ff ff       	call   800d9c <sys_ipc_try_send>
  800eb0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  800eb3:	83 c4 10             	add    $0x10,%esp
  800eb6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ebb:	eb cd                	jmp    800e8a <ipc_send+0x2b>
}
  800ebd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec0:	5b                   	pop    %ebx
  800ec1:	5e                   	pop    %esi
  800ec2:	5f                   	pop    %edi
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    

00800ec5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800ec5:	f3 0f 1e fb          	endbr32 
  800ec9:	55                   	push   %ebp
  800eca:	89 e5                	mov    %esp,%ebp
  800ecc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800ecf:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800ed4:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800ed7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800edd:	8b 52 50             	mov    0x50(%edx),%edx
  800ee0:	39 ca                	cmp    %ecx,%edx
  800ee2:	74 11                	je     800ef5 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  800ee4:	83 c0 01             	add    $0x1,%eax
  800ee7:	3d 00 04 00 00       	cmp    $0x400,%eax
  800eec:	75 e6                	jne    800ed4 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  800eee:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef3:	eb 0b                	jmp    800f00 <ipc_find_env+0x3b>
			return envs[i].env_id;
  800ef5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ef8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800efd:	8b 40 48             	mov    0x48(%eax),%eax
}
  800f00:	5d                   	pop    %ebp
  800f01:	c3                   	ret    

00800f02 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f02:	f3 0f 1e fb          	endbr32 
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	56                   	push   %esi
  800f0a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800f0b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f0e:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800f14:	e8 98 fc ff ff       	call   800bb1 <sys_getenvid>
  800f19:	83 ec 0c             	sub    $0xc,%esp
  800f1c:	ff 75 0c             	pushl  0xc(%ebp)
  800f1f:	ff 75 08             	pushl  0x8(%ebp)
  800f22:	56                   	push   %esi
  800f23:	50                   	push   %eax
  800f24:	68 2c 15 80 00       	push   $0x80152c
  800f29:	e8 7e f2 ff ff       	call   8001ac <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f2e:	83 c4 18             	add    $0x18,%esp
  800f31:	53                   	push   %ebx
  800f32:	ff 75 10             	pushl  0x10(%ebp)
  800f35:	e8 1d f2 ff ff       	call   800157 <vcprintf>
	cprintf("\n");
  800f3a:	c7 04 24 cf 11 80 00 	movl   $0x8011cf,(%esp)
  800f41:	e8 66 f2 ff ff       	call   8001ac <cprintf>
  800f46:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800f49:	cc                   	int3   
  800f4a:	eb fd                	jmp    800f49 <_panic+0x47>
  800f4c:	66 90                	xchg   %ax,%ax
  800f4e:	66 90                	xchg   %ax,%ax

00800f50 <__udivdi3>:
  800f50:	f3 0f 1e fb          	endbr32 
  800f54:	55                   	push   %ebp
  800f55:	57                   	push   %edi
  800f56:	56                   	push   %esi
  800f57:	53                   	push   %ebx
  800f58:	83 ec 1c             	sub    $0x1c,%esp
  800f5b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f5f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800f63:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f67:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800f6b:	85 d2                	test   %edx,%edx
  800f6d:	75 19                	jne    800f88 <__udivdi3+0x38>
  800f6f:	39 f3                	cmp    %esi,%ebx
  800f71:	76 4d                	jbe    800fc0 <__udivdi3+0x70>
  800f73:	31 ff                	xor    %edi,%edi
  800f75:	89 e8                	mov    %ebp,%eax
  800f77:	89 f2                	mov    %esi,%edx
  800f79:	f7 f3                	div    %ebx
  800f7b:	89 fa                	mov    %edi,%edx
  800f7d:	83 c4 1c             	add    $0x1c,%esp
  800f80:	5b                   	pop    %ebx
  800f81:	5e                   	pop    %esi
  800f82:	5f                   	pop    %edi
  800f83:	5d                   	pop    %ebp
  800f84:	c3                   	ret    
  800f85:	8d 76 00             	lea    0x0(%esi),%esi
  800f88:	39 f2                	cmp    %esi,%edx
  800f8a:	76 14                	jbe    800fa0 <__udivdi3+0x50>
  800f8c:	31 ff                	xor    %edi,%edi
  800f8e:	31 c0                	xor    %eax,%eax
  800f90:	89 fa                	mov    %edi,%edx
  800f92:	83 c4 1c             	add    $0x1c,%esp
  800f95:	5b                   	pop    %ebx
  800f96:	5e                   	pop    %esi
  800f97:	5f                   	pop    %edi
  800f98:	5d                   	pop    %ebp
  800f99:	c3                   	ret    
  800f9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fa0:	0f bd fa             	bsr    %edx,%edi
  800fa3:	83 f7 1f             	xor    $0x1f,%edi
  800fa6:	75 48                	jne    800ff0 <__udivdi3+0xa0>
  800fa8:	39 f2                	cmp    %esi,%edx
  800faa:	72 06                	jb     800fb2 <__udivdi3+0x62>
  800fac:	31 c0                	xor    %eax,%eax
  800fae:	39 eb                	cmp    %ebp,%ebx
  800fb0:	77 de                	ja     800f90 <__udivdi3+0x40>
  800fb2:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb7:	eb d7                	jmp    800f90 <__udivdi3+0x40>
  800fb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fc0:	89 d9                	mov    %ebx,%ecx
  800fc2:	85 db                	test   %ebx,%ebx
  800fc4:	75 0b                	jne    800fd1 <__udivdi3+0x81>
  800fc6:	b8 01 00 00 00       	mov    $0x1,%eax
  800fcb:	31 d2                	xor    %edx,%edx
  800fcd:	f7 f3                	div    %ebx
  800fcf:	89 c1                	mov    %eax,%ecx
  800fd1:	31 d2                	xor    %edx,%edx
  800fd3:	89 f0                	mov    %esi,%eax
  800fd5:	f7 f1                	div    %ecx
  800fd7:	89 c6                	mov    %eax,%esi
  800fd9:	89 e8                	mov    %ebp,%eax
  800fdb:	89 f7                	mov    %esi,%edi
  800fdd:	f7 f1                	div    %ecx
  800fdf:	89 fa                	mov    %edi,%edx
  800fe1:	83 c4 1c             	add    $0x1c,%esp
  800fe4:	5b                   	pop    %ebx
  800fe5:	5e                   	pop    %esi
  800fe6:	5f                   	pop    %edi
  800fe7:	5d                   	pop    %ebp
  800fe8:	c3                   	ret    
  800fe9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ff0:	89 f9                	mov    %edi,%ecx
  800ff2:	b8 20 00 00 00       	mov    $0x20,%eax
  800ff7:	29 f8                	sub    %edi,%eax
  800ff9:	d3 e2                	shl    %cl,%edx
  800ffb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800fff:	89 c1                	mov    %eax,%ecx
  801001:	89 da                	mov    %ebx,%edx
  801003:	d3 ea                	shr    %cl,%edx
  801005:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801009:	09 d1                	or     %edx,%ecx
  80100b:	89 f2                	mov    %esi,%edx
  80100d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801011:	89 f9                	mov    %edi,%ecx
  801013:	d3 e3                	shl    %cl,%ebx
  801015:	89 c1                	mov    %eax,%ecx
  801017:	d3 ea                	shr    %cl,%edx
  801019:	89 f9                	mov    %edi,%ecx
  80101b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80101f:	89 eb                	mov    %ebp,%ebx
  801021:	d3 e6                	shl    %cl,%esi
  801023:	89 c1                	mov    %eax,%ecx
  801025:	d3 eb                	shr    %cl,%ebx
  801027:	09 de                	or     %ebx,%esi
  801029:	89 f0                	mov    %esi,%eax
  80102b:	f7 74 24 08          	divl   0x8(%esp)
  80102f:	89 d6                	mov    %edx,%esi
  801031:	89 c3                	mov    %eax,%ebx
  801033:	f7 64 24 0c          	mull   0xc(%esp)
  801037:	39 d6                	cmp    %edx,%esi
  801039:	72 15                	jb     801050 <__udivdi3+0x100>
  80103b:	89 f9                	mov    %edi,%ecx
  80103d:	d3 e5                	shl    %cl,%ebp
  80103f:	39 c5                	cmp    %eax,%ebp
  801041:	73 04                	jae    801047 <__udivdi3+0xf7>
  801043:	39 d6                	cmp    %edx,%esi
  801045:	74 09                	je     801050 <__udivdi3+0x100>
  801047:	89 d8                	mov    %ebx,%eax
  801049:	31 ff                	xor    %edi,%edi
  80104b:	e9 40 ff ff ff       	jmp    800f90 <__udivdi3+0x40>
  801050:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801053:	31 ff                	xor    %edi,%edi
  801055:	e9 36 ff ff ff       	jmp    800f90 <__udivdi3+0x40>
  80105a:	66 90                	xchg   %ax,%ax
  80105c:	66 90                	xchg   %ax,%ax
  80105e:	66 90                	xchg   %ax,%ax

00801060 <__umoddi3>:
  801060:	f3 0f 1e fb          	endbr32 
  801064:	55                   	push   %ebp
  801065:	57                   	push   %edi
  801066:	56                   	push   %esi
  801067:	53                   	push   %ebx
  801068:	83 ec 1c             	sub    $0x1c,%esp
  80106b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80106f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801073:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801077:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80107b:	85 c0                	test   %eax,%eax
  80107d:	75 19                	jne    801098 <__umoddi3+0x38>
  80107f:	39 df                	cmp    %ebx,%edi
  801081:	76 5d                	jbe    8010e0 <__umoddi3+0x80>
  801083:	89 f0                	mov    %esi,%eax
  801085:	89 da                	mov    %ebx,%edx
  801087:	f7 f7                	div    %edi
  801089:	89 d0                	mov    %edx,%eax
  80108b:	31 d2                	xor    %edx,%edx
  80108d:	83 c4 1c             	add    $0x1c,%esp
  801090:	5b                   	pop    %ebx
  801091:	5e                   	pop    %esi
  801092:	5f                   	pop    %edi
  801093:	5d                   	pop    %ebp
  801094:	c3                   	ret    
  801095:	8d 76 00             	lea    0x0(%esi),%esi
  801098:	89 f2                	mov    %esi,%edx
  80109a:	39 d8                	cmp    %ebx,%eax
  80109c:	76 12                	jbe    8010b0 <__umoddi3+0x50>
  80109e:	89 f0                	mov    %esi,%eax
  8010a0:	89 da                	mov    %ebx,%edx
  8010a2:	83 c4 1c             	add    $0x1c,%esp
  8010a5:	5b                   	pop    %ebx
  8010a6:	5e                   	pop    %esi
  8010a7:	5f                   	pop    %edi
  8010a8:	5d                   	pop    %ebp
  8010a9:	c3                   	ret    
  8010aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010b0:	0f bd e8             	bsr    %eax,%ebp
  8010b3:	83 f5 1f             	xor    $0x1f,%ebp
  8010b6:	75 50                	jne    801108 <__umoddi3+0xa8>
  8010b8:	39 d8                	cmp    %ebx,%eax
  8010ba:	0f 82 e0 00 00 00    	jb     8011a0 <__umoddi3+0x140>
  8010c0:	89 d9                	mov    %ebx,%ecx
  8010c2:	39 f7                	cmp    %esi,%edi
  8010c4:	0f 86 d6 00 00 00    	jbe    8011a0 <__umoddi3+0x140>
  8010ca:	89 d0                	mov    %edx,%eax
  8010cc:	89 ca                	mov    %ecx,%edx
  8010ce:	83 c4 1c             	add    $0x1c,%esp
  8010d1:	5b                   	pop    %ebx
  8010d2:	5e                   	pop    %esi
  8010d3:	5f                   	pop    %edi
  8010d4:	5d                   	pop    %ebp
  8010d5:	c3                   	ret    
  8010d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010dd:	8d 76 00             	lea    0x0(%esi),%esi
  8010e0:	89 fd                	mov    %edi,%ebp
  8010e2:	85 ff                	test   %edi,%edi
  8010e4:	75 0b                	jne    8010f1 <__umoddi3+0x91>
  8010e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8010eb:	31 d2                	xor    %edx,%edx
  8010ed:	f7 f7                	div    %edi
  8010ef:	89 c5                	mov    %eax,%ebp
  8010f1:	89 d8                	mov    %ebx,%eax
  8010f3:	31 d2                	xor    %edx,%edx
  8010f5:	f7 f5                	div    %ebp
  8010f7:	89 f0                	mov    %esi,%eax
  8010f9:	f7 f5                	div    %ebp
  8010fb:	89 d0                	mov    %edx,%eax
  8010fd:	31 d2                	xor    %edx,%edx
  8010ff:	eb 8c                	jmp    80108d <__umoddi3+0x2d>
  801101:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801108:	89 e9                	mov    %ebp,%ecx
  80110a:	ba 20 00 00 00       	mov    $0x20,%edx
  80110f:	29 ea                	sub    %ebp,%edx
  801111:	d3 e0                	shl    %cl,%eax
  801113:	89 44 24 08          	mov    %eax,0x8(%esp)
  801117:	89 d1                	mov    %edx,%ecx
  801119:	89 f8                	mov    %edi,%eax
  80111b:	d3 e8                	shr    %cl,%eax
  80111d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801121:	89 54 24 04          	mov    %edx,0x4(%esp)
  801125:	8b 54 24 04          	mov    0x4(%esp),%edx
  801129:	09 c1                	or     %eax,%ecx
  80112b:	89 d8                	mov    %ebx,%eax
  80112d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801131:	89 e9                	mov    %ebp,%ecx
  801133:	d3 e7                	shl    %cl,%edi
  801135:	89 d1                	mov    %edx,%ecx
  801137:	d3 e8                	shr    %cl,%eax
  801139:	89 e9                	mov    %ebp,%ecx
  80113b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80113f:	d3 e3                	shl    %cl,%ebx
  801141:	89 c7                	mov    %eax,%edi
  801143:	89 d1                	mov    %edx,%ecx
  801145:	89 f0                	mov    %esi,%eax
  801147:	d3 e8                	shr    %cl,%eax
  801149:	89 e9                	mov    %ebp,%ecx
  80114b:	89 fa                	mov    %edi,%edx
  80114d:	d3 e6                	shl    %cl,%esi
  80114f:	09 d8                	or     %ebx,%eax
  801151:	f7 74 24 08          	divl   0x8(%esp)
  801155:	89 d1                	mov    %edx,%ecx
  801157:	89 f3                	mov    %esi,%ebx
  801159:	f7 64 24 0c          	mull   0xc(%esp)
  80115d:	89 c6                	mov    %eax,%esi
  80115f:	89 d7                	mov    %edx,%edi
  801161:	39 d1                	cmp    %edx,%ecx
  801163:	72 06                	jb     80116b <__umoddi3+0x10b>
  801165:	75 10                	jne    801177 <__umoddi3+0x117>
  801167:	39 c3                	cmp    %eax,%ebx
  801169:	73 0c                	jae    801177 <__umoddi3+0x117>
  80116b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80116f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801173:	89 d7                	mov    %edx,%edi
  801175:	89 c6                	mov    %eax,%esi
  801177:	89 ca                	mov    %ecx,%edx
  801179:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80117e:	29 f3                	sub    %esi,%ebx
  801180:	19 fa                	sbb    %edi,%edx
  801182:	89 d0                	mov    %edx,%eax
  801184:	d3 e0                	shl    %cl,%eax
  801186:	89 e9                	mov    %ebp,%ecx
  801188:	d3 eb                	shr    %cl,%ebx
  80118a:	d3 ea                	shr    %cl,%edx
  80118c:	09 d8                	or     %ebx,%eax
  80118e:	83 c4 1c             	add    $0x1c,%esp
  801191:	5b                   	pop    %ebx
  801192:	5e                   	pop    %esi
  801193:	5f                   	pop    %edi
  801194:	5d                   	pop    %ebp
  801195:	c3                   	ret    
  801196:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80119d:	8d 76 00             	lea    0x0(%esi),%esi
  8011a0:	29 fe                	sub    %edi,%esi
  8011a2:	19 c3                	sbb    %eax,%ebx
  8011a4:	89 f2                	mov    %esi,%edx
  8011a6:	89 d9                	mov    %ebx,%ecx
  8011a8:	e9 1d ff ff ff       	jmp    8010ca <__umoddi3+0x6a>
