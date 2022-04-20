
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
  80003f:	e8 63 0b 00 00       	call   800ba7 <sys_getenvid>
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
  80005c:	68 71 11 80 00       	push   $0x801171
  800061:	e8 3c 01 00 00       	call   8001a2 <cprintf>
  800066:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  800069:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  80006e:	6a 00                	push   $0x0
  800070:	6a 00                	push   $0x0
  800072:	6a 00                	push   $0x0
  800074:	50                   	push   %eax
  800075:	e8 95 0d 00 00       	call   800e0f <ipc_send>
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	eb ea                	jmp    800069 <umain+0x36>
			ipc_recv(&who, 0, 0);
  80007f:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800082:	83 ec 04             	sub    $0x4,%esp
  800085:	6a 00                	push   $0x0
  800087:	6a 00                	push   $0x0
  800089:	56                   	push   %esi
  80008a:	e8 29 0d 00 00       	call   800db8 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80008f:	83 c4 0c             	add    $0xc,%esp
  800092:	ff 75 f4             	pushl  -0xc(%ebp)
  800095:	53                   	push   %ebx
  800096:	68 60 11 80 00       	push   $0x801160
  80009b:	e8 02 01 00 00       	call   8001a2 <cprintf>
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
    envid_t envid = sys_getenvid();
  8000b4:	e8 ee 0a 00 00       	call   800ba7 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  8000b9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000be:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000c1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c6:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000cb:	85 db                	test   %ebx,%ebx
  8000cd:	7e 07                	jle    8000d6 <libmain+0x31>
		binaryname = argv[0];
  8000cf:	8b 06                	mov    (%esi),%eax
  8000d1:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000d6:	83 ec 08             	sub    $0x8,%esp
  8000d9:	56                   	push   %esi
  8000da:	53                   	push   %ebx
  8000db:	e8 53 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000e0:	e8 0a 00 00 00       	call   8000ef <exit>
}
  8000e5:	83 c4 10             	add    $0x10,%esp
  8000e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000eb:	5b                   	pop    %ebx
  8000ec:	5e                   	pop    %esi
  8000ed:	5d                   	pop    %ebp
  8000ee:	c3                   	ret    

008000ef <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ef:	f3 0f 1e fb          	endbr32 
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000f9:	6a 00                	push   $0x0
  8000fb:	e8 62 0a 00 00       	call   800b62 <sys_env_destroy>
}
  800100:	83 c4 10             	add    $0x10,%esp
  800103:	c9                   	leave  
  800104:	c3                   	ret    

00800105 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800105:	f3 0f 1e fb          	endbr32 
  800109:	55                   	push   %ebp
  80010a:	89 e5                	mov    %esp,%ebp
  80010c:	53                   	push   %ebx
  80010d:	83 ec 04             	sub    $0x4,%esp
  800110:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800113:	8b 13                	mov    (%ebx),%edx
  800115:	8d 42 01             	lea    0x1(%edx),%eax
  800118:	89 03                	mov    %eax,(%ebx)
  80011a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80011d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800121:	3d ff 00 00 00       	cmp    $0xff,%eax
  800126:	74 09                	je     800131 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800128:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80012c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80012f:	c9                   	leave  
  800130:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800131:	83 ec 08             	sub    $0x8,%esp
  800134:	68 ff 00 00 00       	push   $0xff
  800139:	8d 43 08             	lea    0x8(%ebx),%eax
  80013c:	50                   	push   %eax
  80013d:	e8 db 09 00 00       	call   800b1d <sys_cputs>
		b->idx = 0;
  800142:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	eb db                	jmp    800128 <putch+0x23>

0080014d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80014d:	f3 0f 1e fb          	endbr32 
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80015a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800161:	00 00 00 
	b.cnt = 0;
  800164:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80016b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016e:	ff 75 0c             	pushl  0xc(%ebp)
  800171:	ff 75 08             	pushl  0x8(%ebp)
  800174:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80017a:	50                   	push   %eax
  80017b:	68 05 01 80 00       	push   $0x800105
  800180:	e8 20 01 00 00       	call   8002a5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800185:	83 c4 08             	add    $0x8,%esp
  800188:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80018e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800194:	50                   	push   %eax
  800195:	e8 83 09 00 00       	call   800b1d <sys_cputs>

	return b.cnt;
}
  80019a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a0:	c9                   	leave  
  8001a1:	c3                   	ret    

008001a2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a2:	f3 0f 1e fb          	endbr32 
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ac:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001af:	50                   	push   %eax
  8001b0:	ff 75 08             	pushl  0x8(%ebp)
  8001b3:	e8 95 ff ff ff       	call   80014d <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b8:	c9                   	leave  
  8001b9:	c3                   	ret    

008001ba <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ba:	55                   	push   %ebp
  8001bb:	89 e5                	mov    %esp,%ebp
  8001bd:	57                   	push   %edi
  8001be:	56                   	push   %esi
  8001bf:	53                   	push   %ebx
  8001c0:	83 ec 1c             	sub    $0x1c,%esp
  8001c3:	89 c7                	mov    %eax,%edi
  8001c5:	89 d6                	mov    %edx,%esi
  8001c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001cd:	89 d1                	mov    %edx,%ecx
  8001cf:	89 c2                	mov    %eax,%edx
  8001d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001d7:	8b 45 10             	mov    0x10(%ebp),%eax
  8001da:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001e0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001e7:	39 c2                	cmp    %eax,%edx
  8001e9:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001ec:	72 3e                	jb     80022c <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ee:	83 ec 0c             	sub    $0xc,%esp
  8001f1:	ff 75 18             	pushl  0x18(%ebp)
  8001f4:	83 eb 01             	sub    $0x1,%ebx
  8001f7:	53                   	push   %ebx
  8001f8:	50                   	push   %eax
  8001f9:	83 ec 08             	sub    $0x8,%esp
  8001fc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ff:	ff 75 e0             	pushl  -0x20(%ebp)
  800202:	ff 75 dc             	pushl  -0x24(%ebp)
  800205:	ff 75 d8             	pushl  -0x28(%ebp)
  800208:	e8 f3 0c 00 00       	call   800f00 <__udivdi3>
  80020d:	83 c4 18             	add    $0x18,%esp
  800210:	52                   	push   %edx
  800211:	50                   	push   %eax
  800212:	89 f2                	mov    %esi,%edx
  800214:	89 f8                	mov    %edi,%eax
  800216:	e8 9f ff ff ff       	call   8001ba <printnum>
  80021b:	83 c4 20             	add    $0x20,%esp
  80021e:	eb 13                	jmp    800233 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800220:	83 ec 08             	sub    $0x8,%esp
  800223:	56                   	push   %esi
  800224:	ff 75 18             	pushl  0x18(%ebp)
  800227:	ff d7                	call   *%edi
  800229:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80022c:	83 eb 01             	sub    $0x1,%ebx
  80022f:	85 db                	test   %ebx,%ebx
  800231:	7f ed                	jg     800220 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800233:	83 ec 08             	sub    $0x8,%esp
  800236:	56                   	push   %esi
  800237:	83 ec 04             	sub    $0x4,%esp
  80023a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80023d:	ff 75 e0             	pushl  -0x20(%ebp)
  800240:	ff 75 dc             	pushl  -0x24(%ebp)
  800243:	ff 75 d8             	pushl  -0x28(%ebp)
  800246:	e8 c5 0d 00 00       	call   801010 <__umoddi3>
  80024b:	83 c4 14             	add    $0x14,%esp
  80024e:	0f be 80 92 11 80 00 	movsbl 0x801192(%eax),%eax
  800255:	50                   	push   %eax
  800256:	ff d7                	call   *%edi
}
  800258:	83 c4 10             	add    $0x10,%esp
  80025b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025e:	5b                   	pop    %ebx
  80025f:	5e                   	pop    %esi
  800260:	5f                   	pop    %edi
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800263:	f3 0f 1e fb          	endbr32 
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80026d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800271:	8b 10                	mov    (%eax),%edx
  800273:	3b 50 04             	cmp    0x4(%eax),%edx
  800276:	73 0a                	jae    800282 <sprintputch+0x1f>
		*b->buf++ = ch;
  800278:	8d 4a 01             	lea    0x1(%edx),%ecx
  80027b:	89 08                	mov    %ecx,(%eax)
  80027d:	8b 45 08             	mov    0x8(%ebp),%eax
  800280:	88 02                	mov    %al,(%edx)
}
  800282:	5d                   	pop    %ebp
  800283:	c3                   	ret    

00800284 <printfmt>:
{
  800284:	f3 0f 1e fb          	endbr32 
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80028e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800291:	50                   	push   %eax
  800292:	ff 75 10             	pushl  0x10(%ebp)
  800295:	ff 75 0c             	pushl  0xc(%ebp)
  800298:	ff 75 08             	pushl  0x8(%ebp)
  80029b:	e8 05 00 00 00       	call   8002a5 <vprintfmt>
}
  8002a0:	83 c4 10             	add    $0x10,%esp
  8002a3:	c9                   	leave  
  8002a4:	c3                   	ret    

008002a5 <vprintfmt>:
{
  8002a5:	f3 0f 1e fb          	endbr32 
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
  8002af:	83 ec 3c             	sub    $0x3c,%esp
  8002b2:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002b8:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002bb:	e9 4a 03 00 00       	jmp    80060a <vprintfmt+0x365>
		padc = ' ';
  8002c0:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002c4:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002cb:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002d2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002d9:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002de:	8d 47 01             	lea    0x1(%edi),%eax
  8002e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e4:	0f b6 17             	movzbl (%edi),%edx
  8002e7:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002ea:	3c 55                	cmp    $0x55,%al
  8002ec:	0f 87 de 03 00 00    	ja     8006d0 <vprintfmt+0x42b>
  8002f2:	0f b6 c0             	movzbl %al,%eax
  8002f5:	3e ff 24 85 60 12 80 	notrack jmp *0x801260(,%eax,4)
  8002fc:	00 
  8002fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800300:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800304:	eb d8                	jmp    8002de <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800306:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800309:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80030d:	eb cf                	jmp    8002de <vprintfmt+0x39>
  80030f:	0f b6 d2             	movzbl %dl,%edx
  800312:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800315:	b8 00 00 00 00       	mov    $0x0,%eax
  80031a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80031d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800320:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800324:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800327:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80032a:	83 f9 09             	cmp    $0x9,%ecx
  80032d:	77 55                	ja     800384 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80032f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800332:	eb e9                	jmp    80031d <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800334:	8b 45 14             	mov    0x14(%ebp),%eax
  800337:	8b 00                	mov    (%eax),%eax
  800339:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80033c:	8b 45 14             	mov    0x14(%ebp),%eax
  80033f:	8d 40 04             	lea    0x4(%eax),%eax
  800342:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800345:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800348:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80034c:	79 90                	jns    8002de <vprintfmt+0x39>
				width = precision, precision = -1;
  80034e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800351:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800354:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80035b:	eb 81                	jmp    8002de <vprintfmt+0x39>
  80035d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800360:	85 c0                	test   %eax,%eax
  800362:	ba 00 00 00 00       	mov    $0x0,%edx
  800367:	0f 49 d0             	cmovns %eax,%edx
  80036a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80036d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800370:	e9 69 ff ff ff       	jmp    8002de <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800378:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80037f:	e9 5a ff ff ff       	jmp    8002de <vprintfmt+0x39>
  800384:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800387:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80038a:	eb bc                	jmp    800348 <vprintfmt+0xa3>
			lflag++;
  80038c:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80038f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800392:	e9 47 ff ff ff       	jmp    8002de <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800397:	8b 45 14             	mov    0x14(%ebp),%eax
  80039a:	8d 78 04             	lea    0x4(%eax),%edi
  80039d:	83 ec 08             	sub    $0x8,%esp
  8003a0:	53                   	push   %ebx
  8003a1:	ff 30                	pushl  (%eax)
  8003a3:	ff d6                	call   *%esi
			break;
  8003a5:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003a8:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003ab:	e9 57 02 00 00       	jmp    800607 <vprintfmt+0x362>
			err = va_arg(ap, int);
  8003b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b3:	8d 78 04             	lea    0x4(%eax),%edi
  8003b6:	8b 00                	mov    (%eax),%eax
  8003b8:	99                   	cltd   
  8003b9:	31 d0                	xor    %edx,%eax
  8003bb:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003bd:	83 f8 08             	cmp    $0x8,%eax
  8003c0:	7f 23                	jg     8003e5 <vprintfmt+0x140>
  8003c2:	8b 14 85 c0 13 80 00 	mov    0x8013c0(,%eax,4),%edx
  8003c9:	85 d2                	test   %edx,%edx
  8003cb:	74 18                	je     8003e5 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8003cd:	52                   	push   %edx
  8003ce:	68 b3 11 80 00       	push   $0x8011b3
  8003d3:	53                   	push   %ebx
  8003d4:	56                   	push   %esi
  8003d5:	e8 aa fe ff ff       	call   800284 <printfmt>
  8003da:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003dd:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003e0:	e9 22 02 00 00       	jmp    800607 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8003e5:	50                   	push   %eax
  8003e6:	68 aa 11 80 00       	push   $0x8011aa
  8003eb:	53                   	push   %ebx
  8003ec:	56                   	push   %esi
  8003ed:	e8 92 fe ff ff       	call   800284 <printfmt>
  8003f2:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003f5:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003f8:	e9 0a 02 00 00       	jmp    800607 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8003fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800400:	83 c0 04             	add    $0x4,%eax
  800403:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800406:	8b 45 14             	mov    0x14(%ebp),%eax
  800409:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80040b:	85 d2                	test   %edx,%edx
  80040d:	b8 a3 11 80 00       	mov    $0x8011a3,%eax
  800412:	0f 45 c2             	cmovne %edx,%eax
  800415:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800418:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80041c:	7e 06                	jle    800424 <vprintfmt+0x17f>
  80041e:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800422:	75 0d                	jne    800431 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800424:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800427:	89 c7                	mov    %eax,%edi
  800429:	03 45 e0             	add    -0x20(%ebp),%eax
  80042c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80042f:	eb 55                	jmp    800486 <vprintfmt+0x1e1>
  800431:	83 ec 08             	sub    $0x8,%esp
  800434:	ff 75 d8             	pushl  -0x28(%ebp)
  800437:	ff 75 cc             	pushl  -0x34(%ebp)
  80043a:	e8 45 03 00 00       	call   800784 <strnlen>
  80043f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800442:	29 c2                	sub    %eax,%edx
  800444:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800447:	83 c4 10             	add    $0x10,%esp
  80044a:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80044c:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800450:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800453:	85 ff                	test   %edi,%edi
  800455:	7e 11                	jle    800468 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800457:	83 ec 08             	sub    $0x8,%esp
  80045a:	53                   	push   %ebx
  80045b:	ff 75 e0             	pushl  -0x20(%ebp)
  80045e:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800460:	83 ef 01             	sub    $0x1,%edi
  800463:	83 c4 10             	add    $0x10,%esp
  800466:	eb eb                	jmp    800453 <vprintfmt+0x1ae>
  800468:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80046b:	85 d2                	test   %edx,%edx
  80046d:	b8 00 00 00 00       	mov    $0x0,%eax
  800472:	0f 49 c2             	cmovns %edx,%eax
  800475:	29 c2                	sub    %eax,%edx
  800477:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80047a:	eb a8                	jmp    800424 <vprintfmt+0x17f>
					putch(ch, putdat);
  80047c:	83 ec 08             	sub    $0x8,%esp
  80047f:	53                   	push   %ebx
  800480:	52                   	push   %edx
  800481:	ff d6                	call   *%esi
  800483:	83 c4 10             	add    $0x10,%esp
  800486:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800489:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80048b:	83 c7 01             	add    $0x1,%edi
  80048e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800492:	0f be d0             	movsbl %al,%edx
  800495:	85 d2                	test   %edx,%edx
  800497:	74 4b                	je     8004e4 <vprintfmt+0x23f>
  800499:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80049d:	78 06                	js     8004a5 <vprintfmt+0x200>
  80049f:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004a3:	78 1e                	js     8004c3 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004a5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004a9:	74 d1                	je     80047c <vprintfmt+0x1d7>
  8004ab:	0f be c0             	movsbl %al,%eax
  8004ae:	83 e8 20             	sub    $0x20,%eax
  8004b1:	83 f8 5e             	cmp    $0x5e,%eax
  8004b4:	76 c6                	jbe    80047c <vprintfmt+0x1d7>
					putch('?', putdat);
  8004b6:	83 ec 08             	sub    $0x8,%esp
  8004b9:	53                   	push   %ebx
  8004ba:	6a 3f                	push   $0x3f
  8004bc:	ff d6                	call   *%esi
  8004be:	83 c4 10             	add    $0x10,%esp
  8004c1:	eb c3                	jmp    800486 <vprintfmt+0x1e1>
  8004c3:	89 cf                	mov    %ecx,%edi
  8004c5:	eb 0e                	jmp    8004d5 <vprintfmt+0x230>
				putch(' ', putdat);
  8004c7:	83 ec 08             	sub    $0x8,%esp
  8004ca:	53                   	push   %ebx
  8004cb:	6a 20                	push   $0x20
  8004cd:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004cf:	83 ef 01             	sub    $0x1,%edi
  8004d2:	83 c4 10             	add    $0x10,%esp
  8004d5:	85 ff                	test   %edi,%edi
  8004d7:	7f ee                	jg     8004c7 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8004d9:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004dc:	89 45 14             	mov    %eax,0x14(%ebp)
  8004df:	e9 23 01 00 00       	jmp    800607 <vprintfmt+0x362>
  8004e4:	89 cf                	mov    %ecx,%edi
  8004e6:	eb ed                	jmp    8004d5 <vprintfmt+0x230>
	if (lflag >= 2)
  8004e8:	83 f9 01             	cmp    $0x1,%ecx
  8004eb:	7f 1b                	jg     800508 <vprintfmt+0x263>
	else if (lflag)
  8004ed:	85 c9                	test   %ecx,%ecx
  8004ef:	74 63                	je     800554 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8004f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f4:	8b 00                	mov    (%eax),%eax
  8004f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004f9:	99                   	cltd   
  8004fa:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800500:	8d 40 04             	lea    0x4(%eax),%eax
  800503:	89 45 14             	mov    %eax,0x14(%ebp)
  800506:	eb 17                	jmp    80051f <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800508:	8b 45 14             	mov    0x14(%ebp),%eax
  80050b:	8b 50 04             	mov    0x4(%eax),%edx
  80050e:	8b 00                	mov    (%eax),%eax
  800510:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800513:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800516:	8b 45 14             	mov    0x14(%ebp),%eax
  800519:	8d 40 08             	lea    0x8(%eax),%eax
  80051c:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80051f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800522:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800525:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80052a:	85 c9                	test   %ecx,%ecx
  80052c:	0f 89 bb 00 00 00    	jns    8005ed <vprintfmt+0x348>
				putch('-', putdat);
  800532:	83 ec 08             	sub    $0x8,%esp
  800535:	53                   	push   %ebx
  800536:	6a 2d                	push   $0x2d
  800538:	ff d6                	call   *%esi
				num = -(long long) num;
  80053a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80053d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800540:	f7 da                	neg    %edx
  800542:	83 d1 00             	adc    $0x0,%ecx
  800545:	f7 d9                	neg    %ecx
  800547:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80054a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80054f:	e9 99 00 00 00       	jmp    8005ed <vprintfmt+0x348>
		return va_arg(*ap, int);
  800554:	8b 45 14             	mov    0x14(%ebp),%eax
  800557:	8b 00                	mov    (%eax),%eax
  800559:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055c:	99                   	cltd   
  80055d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800560:	8b 45 14             	mov    0x14(%ebp),%eax
  800563:	8d 40 04             	lea    0x4(%eax),%eax
  800566:	89 45 14             	mov    %eax,0x14(%ebp)
  800569:	eb b4                	jmp    80051f <vprintfmt+0x27a>
	if (lflag >= 2)
  80056b:	83 f9 01             	cmp    $0x1,%ecx
  80056e:	7f 1b                	jg     80058b <vprintfmt+0x2e6>
	else if (lflag)
  800570:	85 c9                	test   %ecx,%ecx
  800572:	74 2c                	je     8005a0 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8b 10                	mov    (%eax),%edx
  800579:	b9 00 00 00 00       	mov    $0x0,%ecx
  80057e:	8d 40 04             	lea    0x4(%eax),%eax
  800581:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800584:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800589:	eb 62                	jmp    8005ed <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80058b:	8b 45 14             	mov    0x14(%ebp),%eax
  80058e:	8b 10                	mov    (%eax),%edx
  800590:	8b 48 04             	mov    0x4(%eax),%ecx
  800593:	8d 40 08             	lea    0x8(%eax),%eax
  800596:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800599:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80059e:	eb 4d                	jmp    8005ed <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8005a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a3:	8b 10                	mov    (%eax),%edx
  8005a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005aa:	8d 40 04             	lea    0x4(%eax),%eax
  8005ad:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005b0:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8005b5:	eb 36                	jmp    8005ed <vprintfmt+0x348>
	if (lflag >= 2)
  8005b7:	83 f9 01             	cmp    $0x1,%ecx
  8005ba:	7f 17                	jg     8005d3 <vprintfmt+0x32e>
	else if (lflag)
  8005bc:	85 c9                	test   %ecx,%ecx
  8005be:	74 6e                	je     80062e <vprintfmt+0x389>
		return va_arg(*ap, long);
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8b 10                	mov    (%eax),%edx
  8005c5:	89 d0                	mov    %edx,%eax
  8005c7:	99                   	cltd   
  8005c8:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005cb:	8d 49 04             	lea    0x4(%ecx),%ecx
  8005ce:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005d1:	eb 11                	jmp    8005e4 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8b 50 04             	mov    0x4(%eax),%edx
  8005d9:	8b 00                	mov    (%eax),%eax
  8005db:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005de:	8d 49 08             	lea    0x8(%ecx),%ecx
  8005e1:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8005e4:	89 d1                	mov    %edx,%ecx
  8005e6:	89 c2                	mov    %eax,%edx
            base = 8;
  8005e8:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005ed:	83 ec 0c             	sub    $0xc,%esp
  8005f0:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005f4:	57                   	push   %edi
  8005f5:	ff 75 e0             	pushl  -0x20(%ebp)
  8005f8:	50                   	push   %eax
  8005f9:	51                   	push   %ecx
  8005fa:	52                   	push   %edx
  8005fb:	89 da                	mov    %ebx,%edx
  8005fd:	89 f0                	mov    %esi,%eax
  8005ff:	e8 b6 fb ff ff       	call   8001ba <printnum>
			break;
  800604:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800607:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80060a:	83 c7 01             	add    $0x1,%edi
  80060d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800611:	83 f8 25             	cmp    $0x25,%eax
  800614:	0f 84 a6 fc ff ff    	je     8002c0 <vprintfmt+0x1b>
			if (ch == '\0')
  80061a:	85 c0                	test   %eax,%eax
  80061c:	0f 84 ce 00 00 00    	je     8006f0 <vprintfmt+0x44b>
			putch(ch, putdat);
  800622:	83 ec 08             	sub    $0x8,%esp
  800625:	53                   	push   %ebx
  800626:	50                   	push   %eax
  800627:	ff d6                	call   *%esi
  800629:	83 c4 10             	add    $0x10,%esp
  80062c:	eb dc                	jmp    80060a <vprintfmt+0x365>
		return va_arg(*ap, int);
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8b 10                	mov    (%eax),%edx
  800633:	89 d0                	mov    %edx,%eax
  800635:	99                   	cltd   
  800636:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800639:	8d 49 04             	lea    0x4(%ecx),%ecx
  80063c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80063f:	eb a3                	jmp    8005e4 <vprintfmt+0x33f>
			putch('0', putdat);
  800641:	83 ec 08             	sub    $0x8,%esp
  800644:	53                   	push   %ebx
  800645:	6a 30                	push   $0x30
  800647:	ff d6                	call   *%esi
			putch('x', putdat);
  800649:	83 c4 08             	add    $0x8,%esp
  80064c:	53                   	push   %ebx
  80064d:	6a 78                	push   $0x78
  80064f:	ff d6                	call   *%esi
			num = (unsigned long long)
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8b 10                	mov    (%eax),%edx
  800656:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80065b:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80065e:	8d 40 04             	lea    0x4(%eax),%eax
  800661:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800664:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800669:	eb 82                	jmp    8005ed <vprintfmt+0x348>
	if (lflag >= 2)
  80066b:	83 f9 01             	cmp    $0x1,%ecx
  80066e:	7f 1e                	jg     80068e <vprintfmt+0x3e9>
	else if (lflag)
  800670:	85 c9                	test   %ecx,%ecx
  800672:	74 32                	je     8006a6 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800674:	8b 45 14             	mov    0x14(%ebp),%eax
  800677:	8b 10                	mov    (%eax),%edx
  800679:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067e:	8d 40 04             	lea    0x4(%eax),%eax
  800681:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800684:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800689:	e9 5f ff ff ff       	jmp    8005ed <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80068e:	8b 45 14             	mov    0x14(%ebp),%eax
  800691:	8b 10                	mov    (%eax),%edx
  800693:	8b 48 04             	mov    0x4(%eax),%ecx
  800696:	8d 40 08             	lea    0x8(%eax),%eax
  800699:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80069c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006a1:	e9 47 ff ff ff       	jmp    8005ed <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8b 10                	mov    (%eax),%edx
  8006ab:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b0:	8d 40 04             	lea    0x4(%eax),%eax
  8006b3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b6:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006bb:	e9 2d ff ff ff       	jmp    8005ed <vprintfmt+0x348>
			putch(ch, putdat);
  8006c0:	83 ec 08             	sub    $0x8,%esp
  8006c3:	53                   	push   %ebx
  8006c4:	6a 25                	push   $0x25
  8006c6:	ff d6                	call   *%esi
			break;
  8006c8:	83 c4 10             	add    $0x10,%esp
  8006cb:	e9 37 ff ff ff       	jmp    800607 <vprintfmt+0x362>
			putch('%', putdat);
  8006d0:	83 ec 08             	sub    $0x8,%esp
  8006d3:	53                   	push   %ebx
  8006d4:	6a 25                	push   $0x25
  8006d6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d8:	83 c4 10             	add    $0x10,%esp
  8006db:	89 f8                	mov    %edi,%eax
  8006dd:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006e1:	74 05                	je     8006e8 <vprintfmt+0x443>
  8006e3:	83 e8 01             	sub    $0x1,%eax
  8006e6:	eb f5                	jmp    8006dd <vprintfmt+0x438>
  8006e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006eb:	e9 17 ff ff ff       	jmp    800607 <vprintfmt+0x362>
}
  8006f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f3:	5b                   	pop    %ebx
  8006f4:	5e                   	pop    %esi
  8006f5:	5f                   	pop    %edi
  8006f6:	5d                   	pop    %ebp
  8006f7:	c3                   	ret    

008006f8 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f8:	f3 0f 1e fb          	endbr32 
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	83 ec 18             	sub    $0x18,%esp
  800702:	8b 45 08             	mov    0x8(%ebp),%eax
  800705:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800708:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80070b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80070f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800712:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800719:	85 c0                	test   %eax,%eax
  80071b:	74 26                	je     800743 <vsnprintf+0x4b>
  80071d:	85 d2                	test   %edx,%edx
  80071f:	7e 22                	jle    800743 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800721:	ff 75 14             	pushl  0x14(%ebp)
  800724:	ff 75 10             	pushl  0x10(%ebp)
  800727:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80072a:	50                   	push   %eax
  80072b:	68 63 02 80 00       	push   $0x800263
  800730:	e8 70 fb ff ff       	call   8002a5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800735:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800738:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80073b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80073e:	83 c4 10             	add    $0x10,%esp
}
  800741:	c9                   	leave  
  800742:	c3                   	ret    
		return -E_INVAL;
  800743:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800748:	eb f7                	jmp    800741 <vsnprintf+0x49>

0080074a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80074a:	f3 0f 1e fb          	endbr32 
  80074e:	55                   	push   %ebp
  80074f:	89 e5                	mov    %esp,%ebp
  800751:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800754:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800757:	50                   	push   %eax
  800758:	ff 75 10             	pushl  0x10(%ebp)
  80075b:	ff 75 0c             	pushl  0xc(%ebp)
  80075e:	ff 75 08             	pushl  0x8(%ebp)
  800761:	e8 92 ff ff ff       	call   8006f8 <vsnprintf>
	va_end(ap);

	return rc;
}
  800766:	c9                   	leave  
  800767:	c3                   	ret    

00800768 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800768:	f3 0f 1e fb          	endbr32 
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800772:	b8 00 00 00 00       	mov    $0x0,%eax
  800777:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80077b:	74 05                	je     800782 <strlen+0x1a>
		n++;
  80077d:	83 c0 01             	add    $0x1,%eax
  800780:	eb f5                	jmp    800777 <strlen+0xf>
	return n;
}
  800782:	5d                   	pop    %ebp
  800783:	c3                   	ret    

00800784 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800784:	f3 0f 1e fb          	endbr32 
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80078e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800791:	b8 00 00 00 00       	mov    $0x0,%eax
  800796:	39 d0                	cmp    %edx,%eax
  800798:	74 0d                	je     8007a7 <strnlen+0x23>
  80079a:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80079e:	74 05                	je     8007a5 <strnlen+0x21>
		n++;
  8007a0:	83 c0 01             	add    $0x1,%eax
  8007a3:	eb f1                	jmp    800796 <strnlen+0x12>
  8007a5:	89 c2                	mov    %eax,%edx
	return n;
}
  8007a7:	89 d0                	mov    %edx,%eax
  8007a9:	5d                   	pop    %ebp
  8007aa:	c3                   	ret    

008007ab <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ab:	f3 0f 1e fb          	endbr32 
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	53                   	push   %ebx
  8007b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8007be:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007c2:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007c5:	83 c0 01             	add    $0x1,%eax
  8007c8:	84 d2                	test   %dl,%dl
  8007ca:	75 f2                	jne    8007be <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8007cc:	89 c8                	mov    %ecx,%eax
  8007ce:	5b                   	pop    %ebx
  8007cf:	5d                   	pop    %ebp
  8007d0:	c3                   	ret    

008007d1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d1:	f3 0f 1e fb          	endbr32 
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	53                   	push   %ebx
  8007d9:	83 ec 10             	sub    $0x10,%esp
  8007dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007df:	53                   	push   %ebx
  8007e0:	e8 83 ff ff ff       	call   800768 <strlen>
  8007e5:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007e8:	ff 75 0c             	pushl  0xc(%ebp)
  8007eb:	01 d8                	add    %ebx,%eax
  8007ed:	50                   	push   %eax
  8007ee:	e8 b8 ff ff ff       	call   8007ab <strcpy>
	return dst;
}
  8007f3:	89 d8                	mov    %ebx,%eax
  8007f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f8:	c9                   	leave  
  8007f9:	c3                   	ret    

008007fa <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007fa:	f3 0f 1e fb          	endbr32 
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	56                   	push   %esi
  800802:	53                   	push   %ebx
  800803:	8b 75 08             	mov    0x8(%ebp),%esi
  800806:	8b 55 0c             	mov    0xc(%ebp),%edx
  800809:	89 f3                	mov    %esi,%ebx
  80080b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080e:	89 f0                	mov    %esi,%eax
  800810:	39 d8                	cmp    %ebx,%eax
  800812:	74 11                	je     800825 <strncpy+0x2b>
		*dst++ = *src;
  800814:	83 c0 01             	add    $0x1,%eax
  800817:	0f b6 0a             	movzbl (%edx),%ecx
  80081a:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80081d:	80 f9 01             	cmp    $0x1,%cl
  800820:	83 da ff             	sbb    $0xffffffff,%edx
  800823:	eb eb                	jmp    800810 <strncpy+0x16>
	}
	return ret;
}
  800825:	89 f0                	mov    %esi,%eax
  800827:	5b                   	pop    %ebx
  800828:	5e                   	pop    %esi
  800829:	5d                   	pop    %ebp
  80082a:	c3                   	ret    

0080082b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80082b:	f3 0f 1e fb          	endbr32 
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	56                   	push   %esi
  800833:	53                   	push   %ebx
  800834:	8b 75 08             	mov    0x8(%ebp),%esi
  800837:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083a:	8b 55 10             	mov    0x10(%ebp),%edx
  80083d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80083f:	85 d2                	test   %edx,%edx
  800841:	74 21                	je     800864 <strlcpy+0x39>
  800843:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800847:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800849:	39 c2                	cmp    %eax,%edx
  80084b:	74 14                	je     800861 <strlcpy+0x36>
  80084d:	0f b6 19             	movzbl (%ecx),%ebx
  800850:	84 db                	test   %bl,%bl
  800852:	74 0b                	je     80085f <strlcpy+0x34>
			*dst++ = *src++;
  800854:	83 c1 01             	add    $0x1,%ecx
  800857:	83 c2 01             	add    $0x1,%edx
  80085a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80085d:	eb ea                	jmp    800849 <strlcpy+0x1e>
  80085f:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800861:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800864:	29 f0                	sub    %esi,%eax
}
  800866:	5b                   	pop    %ebx
  800867:	5e                   	pop    %esi
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80086a:	f3 0f 1e fb          	endbr32 
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800874:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800877:	0f b6 01             	movzbl (%ecx),%eax
  80087a:	84 c0                	test   %al,%al
  80087c:	74 0c                	je     80088a <strcmp+0x20>
  80087e:	3a 02                	cmp    (%edx),%al
  800880:	75 08                	jne    80088a <strcmp+0x20>
		p++, q++;
  800882:	83 c1 01             	add    $0x1,%ecx
  800885:	83 c2 01             	add    $0x1,%edx
  800888:	eb ed                	jmp    800877 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80088a:	0f b6 c0             	movzbl %al,%eax
  80088d:	0f b6 12             	movzbl (%edx),%edx
  800890:	29 d0                	sub    %edx,%eax
}
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800894:	f3 0f 1e fb          	endbr32 
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	53                   	push   %ebx
  80089c:	8b 45 08             	mov    0x8(%ebp),%eax
  80089f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a2:	89 c3                	mov    %eax,%ebx
  8008a4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008a7:	eb 06                	jmp    8008af <strncmp+0x1b>
		n--, p++, q++;
  8008a9:	83 c0 01             	add    $0x1,%eax
  8008ac:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008af:	39 d8                	cmp    %ebx,%eax
  8008b1:	74 16                	je     8008c9 <strncmp+0x35>
  8008b3:	0f b6 08             	movzbl (%eax),%ecx
  8008b6:	84 c9                	test   %cl,%cl
  8008b8:	74 04                	je     8008be <strncmp+0x2a>
  8008ba:	3a 0a                	cmp    (%edx),%cl
  8008bc:	74 eb                	je     8008a9 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008be:	0f b6 00             	movzbl (%eax),%eax
  8008c1:	0f b6 12             	movzbl (%edx),%edx
  8008c4:	29 d0                	sub    %edx,%eax
}
  8008c6:	5b                   	pop    %ebx
  8008c7:	5d                   	pop    %ebp
  8008c8:	c3                   	ret    
		return 0;
  8008c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ce:	eb f6                	jmp    8008c6 <strncmp+0x32>

008008d0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d0:	f3 0f 1e fb          	endbr32 
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008da:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008de:	0f b6 10             	movzbl (%eax),%edx
  8008e1:	84 d2                	test   %dl,%dl
  8008e3:	74 09                	je     8008ee <strchr+0x1e>
		if (*s == c)
  8008e5:	38 ca                	cmp    %cl,%dl
  8008e7:	74 0a                	je     8008f3 <strchr+0x23>
	for (; *s; s++)
  8008e9:	83 c0 01             	add    $0x1,%eax
  8008ec:	eb f0                	jmp    8008de <strchr+0xe>
			return (char *) s;
	return 0;
  8008ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f5:	f3 0f 1e fb          	endbr32 
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ff:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800903:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800906:	38 ca                	cmp    %cl,%dl
  800908:	74 09                	je     800913 <strfind+0x1e>
  80090a:	84 d2                	test   %dl,%dl
  80090c:	74 05                	je     800913 <strfind+0x1e>
	for (; *s; s++)
  80090e:	83 c0 01             	add    $0x1,%eax
  800911:	eb f0                	jmp    800903 <strfind+0xe>
			break;
	return (char *) s;
}
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800915:	f3 0f 1e fb          	endbr32 
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	57                   	push   %edi
  80091d:	56                   	push   %esi
  80091e:	53                   	push   %ebx
  80091f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800922:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800925:	85 c9                	test   %ecx,%ecx
  800927:	74 31                	je     80095a <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800929:	89 f8                	mov    %edi,%eax
  80092b:	09 c8                	or     %ecx,%eax
  80092d:	a8 03                	test   $0x3,%al
  80092f:	75 23                	jne    800954 <memset+0x3f>
		c &= 0xFF;
  800931:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800935:	89 d3                	mov    %edx,%ebx
  800937:	c1 e3 08             	shl    $0x8,%ebx
  80093a:	89 d0                	mov    %edx,%eax
  80093c:	c1 e0 18             	shl    $0x18,%eax
  80093f:	89 d6                	mov    %edx,%esi
  800941:	c1 e6 10             	shl    $0x10,%esi
  800944:	09 f0                	or     %esi,%eax
  800946:	09 c2                	or     %eax,%edx
  800948:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80094a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80094d:	89 d0                	mov    %edx,%eax
  80094f:	fc                   	cld    
  800950:	f3 ab                	rep stos %eax,%es:(%edi)
  800952:	eb 06                	jmp    80095a <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800954:	8b 45 0c             	mov    0xc(%ebp),%eax
  800957:	fc                   	cld    
  800958:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80095a:	89 f8                	mov    %edi,%eax
  80095c:	5b                   	pop    %ebx
  80095d:	5e                   	pop    %esi
  80095e:	5f                   	pop    %edi
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800961:	f3 0f 1e fb          	endbr32 
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	57                   	push   %edi
  800969:	56                   	push   %esi
  80096a:	8b 45 08             	mov    0x8(%ebp),%eax
  80096d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800970:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800973:	39 c6                	cmp    %eax,%esi
  800975:	73 32                	jae    8009a9 <memmove+0x48>
  800977:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80097a:	39 c2                	cmp    %eax,%edx
  80097c:	76 2b                	jbe    8009a9 <memmove+0x48>
		s += n;
		d += n;
  80097e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800981:	89 fe                	mov    %edi,%esi
  800983:	09 ce                	or     %ecx,%esi
  800985:	09 d6                	or     %edx,%esi
  800987:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80098d:	75 0e                	jne    80099d <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80098f:	83 ef 04             	sub    $0x4,%edi
  800992:	8d 72 fc             	lea    -0x4(%edx),%esi
  800995:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800998:	fd                   	std    
  800999:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099b:	eb 09                	jmp    8009a6 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80099d:	83 ef 01             	sub    $0x1,%edi
  8009a0:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009a3:	fd                   	std    
  8009a4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009a6:	fc                   	cld    
  8009a7:	eb 1a                	jmp    8009c3 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a9:	89 c2                	mov    %eax,%edx
  8009ab:	09 ca                	or     %ecx,%edx
  8009ad:	09 f2                	or     %esi,%edx
  8009af:	f6 c2 03             	test   $0x3,%dl
  8009b2:	75 0a                	jne    8009be <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009b4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009b7:	89 c7                	mov    %eax,%edi
  8009b9:	fc                   	cld    
  8009ba:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bc:	eb 05                	jmp    8009c3 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8009be:	89 c7                	mov    %eax,%edi
  8009c0:	fc                   	cld    
  8009c1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009c3:	5e                   	pop    %esi
  8009c4:	5f                   	pop    %edi
  8009c5:	5d                   	pop    %ebp
  8009c6:	c3                   	ret    

008009c7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009c7:	f3 0f 1e fb          	endbr32 
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009d1:	ff 75 10             	pushl  0x10(%ebp)
  8009d4:	ff 75 0c             	pushl  0xc(%ebp)
  8009d7:	ff 75 08             	pushl  0x8(%ebp)
  8009da:	e8 82 ff ff ff       	call   800961 <memmove>
}
  8009df:	c9                   	leave  
  8009e0:	c3                   	ret    

008009e1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e1:	f3 0f 1e fb          	endbr32 
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	56                   	push   %esi
  8009e9:	53                   	push   %ebx
  8009ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f0:	89 c6                	mov    %eax,%esi
  8009f2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f5:	39 f0                	cmp    %esi,%eax
  8009f7:	74 1c                	je     800a15 <memcmp+0x34>
		if (*s1 != *s2)
  8009f9:	0f b6 08             	movzbl (%eax),%ecx
  8009fc:	0f b6 1a             	movzbl (%edx),%ebx
  8009ff:	38 d9                	cmp    %bl,%cl
  800a01:	75 08                	jne    800a0b <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a03:	83 c0 01             	add    $0x1,%eax
  800a06:	83 c2 01             	add    $0x1,%edx
  800a09:	eb ea                	jmp    8009f5 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a0b:	0f b6 c1             	movzbl %cl,%eax
  800a0e:	0f b6 db             	movzbl %bl,%ebx
  800a11:	29 d8                	sub    %ebx,%eax
  800a13:	eb 05                	jmp    800a1a <memcmp+0x39>
	}

	return 0;
  800a15:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1a:	5b                   	pop    %ebx
  800a1b:	5e                   	pop    %esi
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a1e:	f3 0f 1e fb          	endbr32 
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	8b 45 08             	mov    0x8(%ebp),%eax
  800a28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a2b:	89 c2                	mov    %eax,%edx
  800a2d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a30:	39 d0                	cmp    %edx,%eax
  800a32:	73 09                	jae    800a3d <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a34:	38 08                	cmp    %cl,(%eax)
  800a36:	74 05                	je     800a3d <memfind+0x1f>
	for (; s < ends; s++)
  800a38:	83 c0 01             	add    $0x1,%eax
  800a3b:	eb f3                	jmp    800a30 <memfind+0x12>
			break;
	return (void *) s;
}
  800a3d:	5d                   	pop    %ebp
  800a3e:	c3                   	ret    

00800a3f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a3f:	f3 0f 1e fb          	endbr32 
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	57                   	push   %edi
  800a47:	56                   	push   %esi
  800a48:	53                   	push   %ebx
  800a49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4f:	eb 03                	jmp    800a54 <strtol+0x15>
		s++;
  800a51:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a54:	0f b6 01             	movzbl (%ecx),%eax
  800a57:	3c 20                	cmp    $0x20,%al
  800a59:	74 f6                	je     800a51 <strtol+0x12>
  800a5b:	3c 09                	cmp    $0x9,%al
  800a5d:	74 f2                	je     800a51 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a5f:	3c 2b                	cmp    $0x2b,%al
  800a61:	74 2a                	je     800a8d <strtol+0x4e>
	int neg = 0;
  800a63:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a68:	3c 2d                	cmp    $0x2d,%al
  800a6a:	74 2b                	je     800a97 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a6c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a72:	75 0f                	jne    800a83 <strtol+0x44>
  800a74:	80 39 30             	cmpb   $0x30,(%ecx)
  800a77:	74 28                	je     800aa1 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a79:	85 db                	test   %ebx,%ebx
  800a7b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a80:	0f 44 d8             	cmove  %eax,%ebx
  800a83:	b8 00 00 00 00       	mov    $0x0,%eax
  800a88:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a8b:	eb 46                	jmp    800ad3 <strtol+0x94>
		s++;
  800a8d:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a90:	bf 00 00 00 00       	mov    $0x0,%edi
  800a95:	eb d5                	jmp    800a6c <strtol+0x2d>
		s++, neg = 1;
  800a97:	83 c1 01             	add    $0x1,%ecx
  800a9a:	bf 01 00 00 00       	mov    $0x1,%edi
  800a9f:	eb cb                	jmp    800a6c <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aa5:	74 0e                	je     800ab5 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800aa7:	85 db                	test   %ebx,%ebx
  800aa9:	75 d8                	jne    800a83 <strtol+0x44>
		s++, base = 8;
  800aab:	83 c1 01             	add    $0x1,%ecx
  800aae:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ab3:	eb ce                	jmp    800a83 <strtol+0x44>
		s += 2, base = 16;
  800ab5:	83 c1 02             	add    $0x2,%ecx
  800ab8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800abd:	eb c4                	jmp    800a83 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800abf:	0f be d2             	movsbl %dl,%edx
  800ac2:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ac5:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ac8:	7d 3a                	jge    800b04 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800aca:	83 c1 01             	add    $0x1,%ecx
  800acd:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ad1:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ad3:	0f b6 11             	movzbl (%ecx),%edx
  800ad6:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ad9:	89 f3                	mov    %esi,%ebx
  800adb:	80 fb 09             	cmp    $0x9,%bl
  800ade:	76 df                	jbe    800abf <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800ae0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ae3:	89 f3                	mov    %esi,%ebx
  800ae5:	80 fb 19             	cmp    $0x19,%bl
  800ae8:	77 08                	ja     800af2 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800aea:	0f be d2             	movsbl %dl,%edx
  800aed:	83 ea 57             	sub    $0x57,%edx
  800af0:	eb d3                	jmp    800ac5 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800af2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800af5:	89 f3                	mov    %esi,%ebx
  800af7:	80 fb 19             	cmp    $0x19,%bl
  800afa:	77 08                	ja     800b04 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800afc:	0f be d2             	movsbl %dl,%edx
  800aff:	83 ea 37             	sub    $0x37,%edx
  800b02:	eb c1                	jmp    800ac5 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b04:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b08:	74 05                	je     800b0f <strtol+0xd0>
		*endptr = (char *) s;
  800b0a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b0d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b0f:	89 c2                	mov    %eax,%edx
  800b11:	f7 da                	neg    %edx
  800b13:	85 ff                	test   %edi,%edi
  800b15:	0f 45 c2             	cmovne %edx,%eax
}
  800b18:	5b                   	pop    %ebx
  800b19:	5e                   	pop    %esi
  800b1a:	5f                   	pop    %edi
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    

00800b1d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b1d:	f3 0f 1e fb          	endbr32 
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	57                   	push   %edi
  800b25:	56                   	push   %esi
  800b26:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b27:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b32:	89 c3                	mov    %eax,%ebx
  800b34:	89 c7                	mov    %eax,%edi
  800b36:	89 c6                	mov    %eax,%esi
  800b38:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5f                   	pop    %edi
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    

00800b3f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b3f:	f3 0f 1e fb          	endbr32 
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	57                   	push   %edi
  800b47:	56                   	push   %esi
  800b48:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b49:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b53:	89 d1                	mov    %edx,%ecx
  800b55:	89 d3                	mov    %edx,%ebx
  800b57:	89 d7                	mov    %edx,%edi
  800b59:	89 d6                	mov    %edx,%esi
  800b5b:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b5d:	5b                   	pop    %ebx
  800b5e:	5e                   	pop    %esi
  800b5f:	5f                   	pop    %edi
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b62:	f3 0f 1e fb          	endbr32 
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	57                   	push   %edi
  800b6a:	56                   	push   %esi
  800b6b:	53                   	push   %ebx
  800b6c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b6f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b74:	8b 55 08             	mov    0x8(%ebp),%edx
  800b77:	b8 03 00 00 00       	mov    $0x3,%eax
  800b7c:	89 cb                	mov    %ecx,%ebx
  800b7e:	89 cf                	mov    %ecx,%edi
  800b80:	89 ce                	mov    %ecx,%esi
  800b82:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b84:	85 c0                	test   %eax,%eax
  800b86:	7f 08                	jg     800b90 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8b:	5b                   	pop    %ebx
  800b8c:	5e                   	pop    %esi
  800b8d:	5f                   	pop    %edi
  800b8e:	5d                   	pop    %ebp
  800b8f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b90:	83 ec 0c             	sub    $0xc,%esp
  800b93:	50                   	push   %eax
  800b94:	6a 03                	push   $0x3
  800b96:	68 e4 13 80 00       	push   $0x8013e4
  800b9b:	6a 23                	push   $0x23
  800b9d:	68 01 14 80 00       	push   $0x801401
  800ba2:	e8 0b 03 00 00       	call   800eb2 <_panic>

00800ba7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ba7:	f3 0f 1e fb          	endbr32 
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	57                   	push   %edi
  800baf:	56                   	push   %esi
  800bb0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb1:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb6:	b8 02 00 00 00       	mov    $0x2,%eax
  800bbb:	89 d1                	mov    %edx,%ecx
  800bbd:	89 d3                	mov    %edx,%ebx
  800bbf:	89 d7                	mov    %edx,%edi
  800bc1:	89 d6                	mov    %edx,%esi
  800bc3:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bc5:	5b                   	pop    %ebx
  800bc6:	5e                   	pop    %esi
  800bc7:	5f                   	pop    %edi
  800bc8:	5d                   	pop    %ebp
  800bc9:	c3                   	ret    

00800bca <sys_yield>:

void
sys_yield(void)
{
  800bca:	f3 0f 1e fb          	endbr32 
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	57                   	push   %edi
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bde:	89 d1                	mov    %edx,%ecx
  800be0:	89 d3                	mov    %edx,%ebx
  800be2:	89 d7                	mov    %edx,%edi
  800be4:	89 d6                	mov    %edx,%esi
  800be6:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5f                   	pop    %edi
  800beb:	5d                   	pop    %ebp
  800bec:	c3                   	ret    

00800bed <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bed:	f3 0f 1e fb          	endbr32 
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	53                   	push   %ebx
  800bf7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bfa:	be 00 00 00 00       	mov    $0x0,%esi
  800bff:	8b 55 08             	mov    0x8(%ebp),%edx
  800c02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c05:	b8 04 00 00 00       	mov    $0x4,%eax
  800c0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c0d:	89 f7                	mov    %esi,%edi
  800c0f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c11:	85 c0                	test   %eax,%eax
  800c13:	7f 08                	jg     800c1d <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c18:	5b                   	pop    %ebx
  800c19:	5e                   	pop    %esi
  800c1a:	5f                   	pop    %edi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1d:	83 ec 0c             	sub    $0xc,%esp
  800c20:	50                   	push   %eax
  800c21:	6a 04                	push   $0x4
  800c23:	68 e4 13 80 00       	push   $0x8013e4
  800c28:	6a 23                	push   $0x23
  800c2a:	68 01 14 80 00       	push   $0x801401
  800c2f:	e8 7e 02 00 00       	call   800eb2 <_panic>

00800c34 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c34:	f3 0f 1e fb          	endbr32 
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	57                   	push   %edi
  800c3c:	56                   	push   %esi
  800c3d:	53                   	push   %ebx
  800c3e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c41:	8b 55 08             	mov    0x8(%ebp),%edx
  800c44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c47:	b8 05 00 00 00       	mov    $0x5,%eax
  800c4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c52:	8b 75 18             	mov    0x18(%ebp),%esi
  800c55:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c57:	85 c0                	test   %eax,%eax
  800c59:	7f 08                	jg     800c63 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c63:	83 ec 0c             	sub    $0xc,%esp
  800c66:	50                   	push   %eax
  800c67:	6a 05                	push   $0x5
  800c69:	68 e4 13 80 00       	push   $0x8013e4
  800c6e:	6a 23                	push   $0x23
  800c70:	68 01 14 80 00       	push   $0x801401
  800c75:	e8 38 02 00 00       	call   800eb2 <_panic>

00800c7a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c7a:	f3 0f 1e fb          	endbr32 
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	57                   	push   %edi
  800c82:	56                   	push   %esi
  800c83:	53                   	push   %ebx
  800c84:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c87:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c92:	b8 06 00 00 00       	mov    $0x6,%eax
  800c97:	89 df                	mov    %ebx,%edi
  800c99:	89 de                	mov    %ebx,%esi
  800c9b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c9d:	85 c0                	test   %eax,%eax
  800c9f:	7f 08                	jg     800ca9 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ca1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca9:	83 ec 0c             	sub    $0xc,%esp
  800cac:	50                   	push   %eax
  800cad:	6a 06                	push   $0x6
  800caf:	68 e4 13 80 00       	push   $0x8013e4
  800cb4:	6a 23                	push   $0x23
  800cb6:	68 01 14 80 00       	push   $0x801401
  800cbb:	e8 f2 01 00 00       	call   800eb2 <_panic>

00800cc0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cc0:	f3 0f 1e fb          	endbr32 
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
  800cca:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ccd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd8:	b8 08 00 00 00       	mov    $0x8,%eax
  800cdd:	89 df                	mov    %ebx,%edi
  800cdf:	89 de                	mov    %ebx,%esi
  800ce1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	7f 08                	jg     800cef <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ce7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cea:	5b                   	pop    %ebx
  800ceb:	5e                   	pop    %esi
  800cec:	5f                   	pop    %edi
  800ced:	5d                   	pop    %ebp
  800cee:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cef:	83 ec 0c             	sub    $0xc,%esp
  800cf2:	50                   	push   %eax
  800cf3:	6a 08                	push   $0x8
  800cf5:	68 e4 13 80 00       	push   $0x8013e4
  800cfa:	6a 23                	push   $0x23
  800cfc:	68 01 14 80 00       	push   $0x801401
  800d01:	e8 ac 01 00 00       	call   800eb2 <_panic>

00800d06 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d06:	f3 0f 1e fb          	endbr32 
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	57                   	push   %edi
  800d0e:	56                   	push   %esi
  800d0f:	53                   	push   %ebx
  800d10:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d18:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1e:	b8 09 00 00 00       	mov    $0x9,%eax
  800d23:	89 df                	mov    %ebx,%edi
  800d25:	89 de                	mov    %ebx,%esi
  800d27:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d29:	85 c0                	test   %eax,%eax
  800d2b:	7f 08                	jg     800d35 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5f                   	pop    %edi
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d35:	83 ec 0c             	sub    $0xc,%esp
  800d38:	50                   	push   %eax
  800d39:	6a 09                	push   $0x9
  800d3b:	68 e4 13 80 00       	push   $0x8013e4
  800d40:	6a 23                	push   $0x23
  800d42:	68 01 14 80 00       	push   $0x801401
  800d47:	e8 66 01 00 00       	call   800eb2 <_panic>

00800d4c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d4c:	f3 0f 1e fb          	endbr32 
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	57                   	push   %edi
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d56:	8b 55 08             	mov    0x8(%ebp),%edx
  800d59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d61:	be 00 00 00 00       	mov    $0x0,%esi
  800d66:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d69:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d6c:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d6e:	5b                   	pop    %ebx
  800d6f:	5e                   	pop    %esi
  800d70:	5f                   	pop    %edi
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d73:	f3 0f 1e fb          	endbr32 
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
  800d7a:	57                   	push   %edi
  800d7b:	56                   	push   %esi
  800d7c:	53                   	push   %ebx
  800d7d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d80:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d85:	8b 55 08             	mov    0x8(%ebp),%edx
  800d88:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d8d:	89 cb                	mov    %ecx,%ebx
  800d8f:	89 cf                	mov    %ecx,%edi
  800d91:	89 ce                	mov    %ecx,%esi
  800d93:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d95:	85 c0                	test   %eax,%eax
  800d97:	7f 08                	jg     800da1 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
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
  800da5:	6a 0c                	push   $0xc
  800da7:	68 e4 13 80 00       	push   $0x8013e4
  800dac:	6a 23                	push   $0x23
  800dae:	68 01 14 80 00       	push   $0x801401
  800db3:	e8 fa 00 00 00       	call   800eb2 <_panic>

00800db8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800db8:	f3 0f 1e fb          	endbr32 
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	56                   	push   %esi
  800dc0:	53                   	push   %ebx
  800dc1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800dc4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dc7:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  800dca:	85 c0                	test   %eax,%eax
  800dcc:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  800dd1:	0f 44 c2             	cmove  %edx,%eax
  800dd4:	83 ec 0c             	sub    $0xc,%esp
  800dd7:	50                   	push   %eax
  800dd8:	e8 96 ff ff ff       	call   800d73 <sys_ipc_recv>
  800ddd:	83 c4 10             	add    $0x10,%esp
  800de0:	85 c0                	test   %eax,%eax
  800de2:	78 24                	js     800e08 <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  800de4:	85 f6                	test   %esi,%esi
  800de6:	74 0a                	je     800df2 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  800de8:	a1 04 20 80 00       	mov    0x802004,%eax
  800ded:	8b 40 78             	mov    0x78(%eax),%eax
  800df0:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  800df2:	85 db                	test   %ebx,%ebx
  800df4:	74 0a                	je     800e00 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  800df6:	a1 04 20 80 00       	mov    0x802004,%eax
  800dfb:	8b 40 74             	mov    0x74(%eax),%eax
  800dfe:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  800e00:	a1 04 20 80 00       	mov    0x802004,%eax
  800e05:	8b 40 70             	mov    0x70(%eax),%eax
}
  800e08:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e0b:	5b                   	pop    %ebx
  800e0c:	5e                   	pop    %esi
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    

00800e0f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e0f:	f3 0f 1e fb          	endbr32 
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	57                   	push   %edi
  800e17:	56                   	push   %esi
  800e18:	53                   	push   %ebx
  800e19:	83 ec 1c             	sub    $0x1c,%esp
  800e1c:	8b 45 10             	mov    0x10(%ebp),%eax
  800e1f:	85 c0                	test   %eax,%eax
  800e21:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  800e26:	0f 45 d0             	cmovne %eax,%edx
  800e29:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  800e2b:	be 01 00 00 00       	mov    $0x1,%esi
  800e30:	eb 1f                	jmp    800e51 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  800e32:	e8 93 fd ff ff       	call   800bca <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  800e37:	83 c3 01             	add    $0x1,%ebx
  800e3a:	39 de                	cmp    %ebx,%esi
  800e3c:	7f f4                	jg     800e32 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  800e3e:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  800e40:	83 fe 11             	cmp    $0x11,%esi
  800e43:	b8 01 00 00 00       	mov    $0x1,%eax
  800e48:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  800e4b:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  800e4f:	75 1c                	jne    800e6d <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  800e51:	ff 75 14             	pushl  0x14(%ebp)
  800e54:	57                   	push   %edi
  800e55:	ff 75 0c             	pushl  0xc(%ebp)
  800e58:	ff 75 08             	pushl  0x8(%ebp)
  800e5b:	e8 ec fe ff ff       	call   800d4c <sys_ipc_try_send>
  800e60:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  800e63:	83 c4 10             	add    $0x10,%esp
  800e66:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e6b:	eb cd                	jmp    800e3a <ipc_send+0x2b>
}
  800e6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e70:	5b                   	pop    %ebx
  800e71:	5e                   	pop    %esi
  800e72:	5f                   	pop    %edi
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    

00800e75 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800e75:	f3 0f 1e fb          	endbr32 
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800e7f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800e84:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800e87:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800e8d:	8b 52 50             	mov    0x50(%edx),%edx
  800e90:	39 ca                	cmp    %ecx,%edx
  800e92:	74 11                	je     800ea5 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  800e94:	83 c0 01             	add    $0x1,%eax
  800e97:	3d 00 04 00 00       	cmp    $0x400,%eax
  800e9c:	75 e6                	jne    800e84 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  800e9e:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea3:	eb 0b                	jmp    800eb0 <ipc_find_env+0x3b>
			return envs[i].env_id;
  800ea5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ea8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ead:	8b 40 48             	mov    0x48(%eax),%eax
}
  800eb0:	5d                   	pop    %ebp
  800eb1:	c3                   	ret    

00800eb2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800eb2:	f3 0f 1e fb          	endbr32 
  800eb6:	55                   	push   %ebp
  800eb7:	89 e5                	mov    %esp,%ebp
  800eb9:	56                   	push   %esi
  800eba:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ebb:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ebe:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800ec4:	e8 de fc ff ff       	call   800ba7 <sys_getenvid>
  800ec9:	83 ec 0c             	sub    $0xc,%esp
  800ecc:	ff 75 0c             	pushl  0xc(%ebp)
  800ecf:	ff 75 08             	pushl  0x8(%ebp)
  800ed2:	56                   	push   %esi
  800ed3:	50                   	push   %eax
  800ed4:	68 10 14 80 00       	push   $0x801410
  800ed9:	e8 c4 f2 ff ff       	call   8001a2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ede:	83 c4 18             	add    $0x18,%esp
  800ee1:	53                   	push   %ebx
  800ee2:	ff 75 10             	pushl  0x10(%ebp)
  800ee5:	e8 63 f2 ff ff       	call   80014d <vcprintf>
	cprintf("\n");
  800eea:	c7 04 24 6f 11 80 00 	movl   $0x80116f,(%esp)
  800ef1:	e8 ac f2 ff ff       	call   8001a2 <cprintf>
  800ef6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800ef9:	cc                   	int3   
  800efa:	eb fd                	jmp    800ef9 <_panic+0x47>
  800efc:	66 90                	xchg   %ax,%ax
  800efe:	66 90                	xchg   %ax,%ax

00800f00 <__udivdi3>:
  800f00:	f3 0f 1e fb          	endbr32 
  800f04:	55                   	push   %ebp
  800f05:	57                   	push   %edi
  800f06:	56                   	push   %esi
  800f07:	53                   	push   %ebx
  800f08:	83 ec 1c             	sub    $0x1c,%esp
  800f0b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f0f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800f13:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f17:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800f1b:	85 d2                	test   %edx,%edx
  800f1d:	75 19                	jne    800f38 <__udivdi3+0x38>
  800f1f:	39 f3                	cmp    %esi,%ebx
  800f21:	76 4d                	jbe    800f70 <__udivdi3+0x70>
  800f23:	31 ff                	xor    %edi,%edi
  800f25:	89 e8                	mov    %ebp,%eax
  800f27:	89 f2                	mov    %esi,%edx
  800f29:	f7 f3                	div    %ebx
  800f2b:	89 fa                	mov    %edi,%edx
  800f2d:	83 c4 1c             	add    $0x1c,%esp
  800f30:	5b                   	pop    %ebx
  800f31:	5e                   	pop    %esi
  800f32:	5f                   	pop    %edi
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    
  800f35:	8d 76 00             	lea    0x0(%esi),%esi
  800f38:	39 f2                	cmp    %esi,%edx
  800f3a:	76 14                	jbe    800f50 <__udivdi3+0x50>
  800f3c:	31 ff                	xor    %edi,%edi
  800f3e:	31 c0                	xor    %eax,%eax
  800f40:	89 fa                	mov    %edi,%edx
  800f42:	83 c4 1c             	add    $0x1c,%esp
  800f45:	5b                   	pop    %ebx
  800f46:	5e                   	pop    %esi
  800f47:	5f                   	pop    %edi
  800f48:	5d                   	pop    %ebp
  800f49:	c3                   	ret    
  800f4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f50:	0f bd fa             	bsr    %edx,%edi
  800f53:	83 f7 1f             	xor    $0x1f,%edi
  800f56:	75 48                	jne    800fa0 <__udivdi3+0xa0>
  800f58:	39 f2                	cmp    %esi,%edx
  800f5a:	72 06                	jb     800f62 <__udivdi3+0x62>
  800f5c:	31 c0                	xor    %eax,%eax
  800f5e:	39 eb                	cmp    %ebp,%ebx
  800f60:	77 de                	ja     800f40 <__udivdi3+0x40>
  800f62:	b8 01 00 00 00       	mov    $0x1,%eax
  800f67:	eb d7                	jmp    800f40 <__udivdi3+0x40>
  800f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f70:	89 d9                	mov    %ebx,%ecx
  800f72:	85 db                	test   %ebx,%ebx
  800f74:	75 0b                	jne    800f81 <__udivdi3+0x81>
  800f76:	b8 01 00 00 00       	mov    $0x1,%eax
  800f7b:	31 d2                	xor    %edx,%edx
  800f7d:	f7 f3                	div    %ebx
  800f7f:	89 c1                	mov    %eax,%ecx
  800f81:	31 d2                	xor    %edx,%edx
  800f83:	89 f0                	mov    %esi,%eax
  800f85:	f7 f1                	div    %ecx
  800f87:	89 c6                	mov    %eax,%esi
  800f89:	89 e8                	mov    %ebp,%eax
  800f8b:	89 f7                	mov    %esi,%edi
  800f8d:	f7 f1                	div    %ecx
  800f8f:	89 fa                	mov    %edi,%edx
  800f91:	83 c4 1c             	add    $0x1c,%esp
  800f94:	5b                   	pop    %ebx
  800f95:	5e                   	pop    %esi
  800f96:	5f                   	pop    %edi
  800f97:	5d                   	pop    %ebp
  800f98:	c3                   	ret    
  800f99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fa0:	89 f9                	mov    %edi,%ecx
  800fa2:	b8 20 00 00 00       	mov    $0x20,%eax
  800fa7:	29 f8                	sub    %edi,%eax
  800fa9:	d3 e2                	shl    %cl,%edx
  800fab:	89 54 24 08          	mov    %edx,0x8(%esp)
  800faf:	89 c1                	mov    %eax,%ecx
  800fb1:	89 da                	mov    %ebx,%edx
  800fb3:	d3 ea                	shr    %cl,%edx
  800fb5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800fb9:	09 d1                	or     %edx,%ecx
  800fbb:	89 f2                	mov    %esi,%edx
  800fbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fc1:	89 f9                	mov    %edi,%ecx
  800fc3:	d3 e3                	shl    %cl,%ebx
  800fc5:	89 c1                	mov    %eax,%ecx
  800fc7:	d3 ea                	shr    %cl,%edx
  800fc9:	89 f9                	mov    %edi,%ecx
  800fcb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800fcf:	89 eb                	mov    %ebp,%ebx
  800fd1:	d3 e6                	shl    %cl,%esi
  800fd3:	89 c1                	mov    %eax,%ecx
  800fd5:	d3 eb                	shr    %cl,%ebx
  800fd7:	09 de                	or     %ebx,%esi
  800fd9:	89 f0                	mov    %esi,%eax
  800fdb:	f7 74 24 08          	divl   0x8(%esp)
  800fdf:	89 d6                	mov    %edx,%esi
  800fe1:	89 c3                	mov    %eax,%ebx
  800fe3:	f7 64 24 0c          	mull   0xc(%esp)
  800fe7:	39 d6                	cmp    %edx,%esi
  800fe9:	72 15                	jb     801000 <__udivdi3+0x100>
  800feb:	89 f9                	mov    %edi,%ecx
  800fed:	d3 e5                	shl    %cl,%ebp
  800fef:	39 c5                	cmp    %eax,%ebp
  800ff1:	73 04                	jae    800ff7 <__udivdi3+0xf7>
  800ff3:	39 d6                	cmp    %edx,%esi
  800ff5:	74 09                	je     801000 <__udivdi3+0x100>
  800ff7:	89 d8                	mov    %ebx,%eax
  800ff9:	31 ff                	xor    %edi,%edi
  800ffb:	e9 40 ff ff ff       	jmp    800f40 <__udivdi3+0x40>
  801000:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801003:	31 ff                	xor    %edi,%edi
  801005:	e9 36 ff ff ff       	jmp    800f40 <__udivdi3+0x40>
  80100a:	66 90                	xchg   %ax,%ax
  80100c:	66 90                	xchg   %ax,%ax
  80100e:	66 90                	xchg   %ax,%ax

00801010 <__umoddi3>:
  801010:	f3 0f 1e fb          	endbr32 
  801014:	55                   	push   %ebp
  801015:	57                   	push   %edi
  801016:	56                   	push   %esi
  801017:	53                   	push   %ebx
  801018:	83 ec 1c             	sub    $0x1c,%esp
  80101b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80101f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801023:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801027:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80102b:	85 c0                	test   %eax,%eax
  80102d:	75 19                	jne    801048 <__umoddi3+0x38>
  80102f:	39 df                	cmp    %ebx,%edi
  801031:	76 5d                	jbe    801090 <__umoddi3+0x80>
  801033:	89 f0                	mov    %esi,%eax
  801035:	89 da                	mov    %ebx,%edx
  801037:	f7 f7                	div    %edi
  801039:	89 d0                	mov    %edx,%eax
  80103b:	31 d2                	xor    %edx,%edx
  80103d:	83 c4 1c             	add    $0x1c,%esp
  801040:	5b                   	pop    %ebx
  801041:	5e                   	pop    %esi
  801042:	5f                   	pop    %edi
  801043:	5d                   	pop    %ebp
  801044:	c3                   	ret    
  801045:	8d 76 00             	lea    0x0(%esi),%esi
  801048:	89 f2                	mov    %esi,%edx
  80104a:	39 d8                	cmp    %ebx,%eax
  80104c:	76 12                	jbe    801060 <__umoddi3+0x50>
  80104e:	89 f0                	mov    %esi,%eax
  801050:	89 da                	mov    %ebx,%edx
  801052:	83 c4 1c             	add    $0x1c,%esp
  801055:	5b                   	pop    %ebx
  801056:	5e                   	pop    %esi
  801057:	5f                   	pop    %edi
  801058:	5d                   	pop    %ebp
  801059:	c3                   	ret    
  80105a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801060:	0f bd e8             	bsr    %eax,%ebp
  801063:	83 f5 1f             	xor    $0x1f,%ebp
  801066:	75 50                	jne    8010b8 <__umoddi3+0xa8>
  801068:	39 d8                	cmp    %ebx,%eax
  80106a:	0f 82 e0 00 00 00    	jb     801150 <__umoddi3+0x140>
  801070:	89 d9                	mov    %ebx,%ecx
  801072:	39 f7                	cmp    %esi,%edi
  801074:	0f 86 d6 00 00 00    	jbe    801150 <__umoddi3+0x140>
  80107a:	89 d0                	mov    %edx,%eax
  80107c:	89 ca                	mov    %ecx,%edx
  80107e:	83 c4 1c             	add    $0x1c,%esp
  801081:	5b                   	pop    %ebx
  801082:	5e                   	pop    %esi
  801083:	5f                   	pop    %edi
  801084:	5d                   	pop    %ebp
  801085:	c3                   	ret    
  801086:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80108d:	8d 76 00             	lea    0x0(%esi),%esi
  801090:	89 fd                	mov    %edi,%ebp
  801092:	85 ff                	test   %edi,%edi
  801094:	75 0b                	jne    8010a1 <__umoddi3+0x91>
  801096:	b8 01 00 00 00       	mov    $0x1,%eax
  80109b:	31 d2                	xor    %edx,%edx
  80109d:	f7 f7                	div    %edi
  80109f:	89 c5                	mov    %eax,%ebp
  8010a1:	89 d8                	mov    %ebx,%eax
  8010a3:	31 d2                	xor    %edx,%edx
  8010a5:	f7 f5                	div    %ebp
  8010a7:	89 f0                	mov    %esi,%eax
  8010a9:	f7 f5                	div    %ebp
  8010ab:	89 d0                	mov    %edx,%eax
  8010ad:	31 d2                	xor    %edx,%edx
  8010af:	eb 8c                	jmp    80103d <__umoddi3+0x2d>
  8010b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010b8:	89 e9                	mov    %ebp,%ecx
  8010ba:	ba 20 00 00 00       	mov    $0x20,%edx
  8010bf:	29 ea                	sub    %ebp,%edx
  8010c1:	d3 e0                	shl    %cl,%eax
  8010c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010c7:	89 d1                	mov    %edx,%ecx
  8010c9:	89 f8                	mov    %edi,%eax
  8010cb:	d3 e8                	shr    %cl,%eax
  8010cd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8010d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010d5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8010d9:	09 c1                	or     %eax,%ecx
  8010db:	89 d8                	mov    %ebx,%eax
  8010dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010e1:	89 e9                	mov    %ebp,%ecx
  8010e3:	d3 e7                	shl    %cl,%edi
  8010e5:	89 d1                	mov    %edx,%ecx
  8010e7:	d3 e8                	shr    %cl,%eax
  8010e9:	89 e9                	mov    %ebp,%ecx
  8010eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010ef:	d3 e3                	shl    %cl,%ebx
  8010f1:	89 c7                	mov    %eax,%edi
  8010f3:	89 d1                	mov    %edx,%ecx
  8010f5:	89 f0                	mov    %esi,%eax
  8010f7:	d3 e8                	shr    %cl,%eax
  8010f9:	89 e9                	mov    %ebp,%ecx
  8010fb:	89 fa                	mov    %edi,%edx
  8010fd:	d3 e6                	shl    %cl,%esi
  8010ff:	09 d8                	or     %ebx,%eax
  801101:	f7 74 24 08          	divl   0x8(%esp)
  801105:	89 d1                	mov    %edx,%ecx
  801107:	89 f3                	mov    %esi,%ebx
  801109:	f7 64 24 0c          	mull   0xc(%esp)
  80110d:	89 c6                	mov    %eax,%esi
  80110f:	89 d7                	mov    %edx,%edi
  801111:	39 d1                	cmp    %edx,%ecx
  801113:	72 06                	jb     80111b <__umoddi3+0x10b>
  801115:	75 10                	jne    801127 <__umoddi3+0x117>
  801117:	39 c3                	cmp    %eax,%ebx
  801119:	73 0c                	jae    801127 <__umoddi3+0x117>
  80111b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80111f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801123:	89 d7                	mov    %edx,%edi
  801125:	89 c6                	mov    %eax,%esi
  801127:	89 ca                	mov    %ecx,%edx
  801129:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80112e:	29 f3                	sub    %esi,%ebx
  801130:	19 fa                	sbb    %edi,%edx
  801132:	89 d0                	mov    %edx,%eax
  801134:	d3 e0                	shl    %cl,%eax
  801136:	89 e9                	mov    %ebp,%ecx
  801138:	d3 eb                	shr    %cl,%ebx
  80113a:	d3 ea                	shr    %cl,%edx
  80113c:	09 d8                	or     %ebx,%eax
  80113e:	83 c4 1c             	add    $0x1c,%esp
  801141:	5b                   	pop    %ebx
  801142:	5e                   	pop    %esi
  801143:	5f                   	pop    %edi
  801144:	5d                   	pop    %ebp
  801145:	c3                   	ret    
  801146:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80114d:	8d 76 00             	lea    0x0(%esi),%esi
  801150:	29 fe                	sub    %edi,%esi
  801152:	19 c3                	sbb    %eax,%ebx
  801154:	89 f2                	mov    %esi,%edx
  801156:	89 d9                	mov    %ebx,%ecx
  801158:	e9 1d ff ff ff       	jmp    80107a <__umoddi3+0x6a>
