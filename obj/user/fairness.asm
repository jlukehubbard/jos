
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
  80003f:	e8 75 0b 00 00       	call   800bb9 <sys_getenvid>
  800044:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800046:	81 3d 04 40 80 00 7c 	cmpl   $0xeec0007c,0x804004
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
  80005c:	68 51 1f 80 00       	push   $0x801f51
  800061:	e8 4e 01 00 00       	call   8001b4 <cprintf>
  800066:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  800069:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  80006e:	6a 00                	push   $0x0
  800070:	6a 00                	push   $0x0
  800072:	6a 00                	push   $0x0
  800074:	50                   	push   %eax
  800075:	e8 ed 0d 00 00       	call   800e67 <ipc_send>
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	eb ea                	jmp    800069 <umain+0x36>
			ipc_recv(&who, 0, 0);
  80007f:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800082:	83 ec 04             	sub    $0x4,%esp
  800085:	6a 00                	push   $0x0
  800087:	6a 00                	push   $0x0
  800089:	56                   	push   %esi
  80008a:	e8 81 0d 00 00       	call   800e10 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80008f:	83 c4 0c             	add    $0xc,%esp
  800092:	ff 75 f4             	pushl  -0xc(%ebp)
  800095:	53                   	push   %ebx
  800096:	68 40 1f 80 00       	push   $0x801f40
  80009b:	e8 14 01 00 00       	call   8001b4 <cprintf>
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
  8000b4:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  8000bb:	00 00 00 
    envid_t envid = sys_getenvid();
  8000be:	e8 f6 0a 00 00       	call   800bb9 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  8000c3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000c8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d0:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d5:	85 db                	test   %ebx,%ebx
  8000d7:	7e 07                	jle    8000e0 <libmain+0x3b>
		binaryname = argv[0];
  8000d9:	8b 06                	mov    (%esi),%eax
  8000db:	a3 00 30 80 00       	mov    %eax,0x803000

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
  800100:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800103:	e8 f1 0f 00 00       	call   8010f9 <close_all>
	sys_env_destroy(0);
  800108:	83 ec 0c             	sub    $0xc,%esp
  80010b:	6a 00                	push   $0x0
  80010d:	e8 62 0a 00 00       	call   800b74 <sys_env_destroy>
}
  800112:	83 c4 10             	add    $0x10,%esp
  800115:	c9                   	leave  
  800116:	c3                   	ret    

00800117 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800117:	f3 0f 1e fb          	endbr32 
  80011b:	55                   	push   %ebp
  80011c:	89 e5                	mov    %esp,%ebp
  80011e:	53                   	push   %ebx
  80011f:	83 ec 04             	sub    $0x4,%esp
  800122:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800125:	8b 13                	mov    (%ebx),%edx
  800127:	8d 42 01             	lea    0x1(%edx),%eax
  80012a:	89 03                	mov    %eax,(%ebx)
  80012c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80012f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800133:	3d ff 00 00 00       	cmp    $0xff,%eax
  800138:	74 09                	je     800143 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80013a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80013e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800141:	c9                   	leave  
  800142:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800143:	83 ec 08             	sub    $0x8,%esp
  800146:	68 ff 00 00 00       	push   $0xff
  80014b:	8d 43 08             	lea    0x8(%ebx),%eax
  80014e:	50                   	push   %eax
  80014f:	e8 db 09 00 00       	call   800b2f <sys_cputs>
		b->idx = 0;
  800154:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80015a:	83 c4 10             	add    $0x10,%esp
  80015d:	eb db                	jmp    80013a <putch+0x23>

0080015f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80015f:	f3 0f 1e fb          	endbr32 
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80016c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800173:	00 00 00 
	b.cnt = 0;
  800176:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800180:	ff 75 0c             	pushl  0xc(%ebp)
  800183:	ff 75 08             	pushl  0x8(%ebp)
  800186:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018c:	50                   	push   %eax
  80018d:	68 17 01 80 00       	push   $0x800117
  800192:	e8 20 01 00 00       	call   8002b7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800197:	83 c4 08             	add    $0x8,%esp
  80019a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a6:	50                   	push   %eax
  8001a7:	e8 83 09 00 00       	call   800b2f <sys_cputs>

	return b.cnt;
}
  8001ac:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b4:	f3 0f 1e fb          	endbr32 
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001be:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001c1:	50                   	push   %eax
  8001c2:	ff 75 08             	pushl  0x8(%ebp)
  8001c5:	e8 95 ff ff ff       	call   80015f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ca:	c9                   	leave  
  8001cb:	c3                   	ret    

008001cc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	57                   	push   %edi
  8001d0:	56                   	push   %esi
  8001d1:	53                   	push   %ebx
  8001d2:	83 ec 1c             	sub    $0x1c,%esp
  8001d5:	89 c7                	mov    %eax,%edi
  8001d7:	89 d6                	mov    %edx,%esi
  8001d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001df:	89 d1                	mov    %edx,%ecx
  8001e1:	89 c2                	mov    %eax,%edx
  8001e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001e6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ec:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001f2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001f9:	39 c2                	cmp    %eax,%edx
  8001fb:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001fe:	72 3e                	jb     80023e <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800200:	83 ec 0c             	sub    $0xc,%esp
  800203:	ff 75 18             	pushl  0x18(%ebp)
  800206:	83 eb 01             	sub    $0x1,%ebx
  800209:	53                   	push   %ebx
  80020a:	50                   	push   %eax
  80020b:	83 ec 08             	sub    $0x8,%esp
  80020e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800211:	ff 75 e0             	pushl  -0x20(%ebp)
  800214:	ff 75 dc             	pushl  -0x24(%ebp)
  800217:	ff 75 d8             	pushl  -0x28(%ebp)
  80021a:	e8 c1 1a 00 00       	call   801ce0 <__udivdi3>
  80021f:	83 c4 18             	add    $0x18,%esp
  800222:	52                   	push   %edx
  800223:	50                   	push   %eax
  800224:	89 f2                	mov    %esi,%edx
  800226:	89 f8                	mov    %edi,%eax
  800228:	e8 9f ff ff ff       	call   8001cc <printnum>
  80022d:	83 c4 20             	add    $0x20,%esp
  800230:	eb 13                	jmp    800245 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800232:	83 ec 08             	sub    $0x8,%esp
  800235:	56                   	push   %esi
  800236:	ff 75 18             	pushl  0x18(%ebp)
  800239:	ff d7                	call   *%edi
  80023b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80023e:	83 eb 01             	sub    $0x1,%ebx
  800241:	85 db                	test   %ebx,%ebx
  800243:	7f ed                	jg     800232 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800245:	83 ec 08             	sub    $0x8,%esp
  800248:	56                   	push   %esi
  800249:	83 ec 04             	sub    $0x4,%esp
  80024c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024f:	ff 75 e0             	pushl  -0x20(%ebp)
  800252:	ff 75 dc             	pushl  -0x24(%ebp)
  800255:	ff 75 d8             	pushl  -0x28(%ebp)
  800258:	e8 93 1b 00 00       	call   801df0 <__umoddi3>
  80025d:	83 c4 14             	add    $0x14,%esp
  800260:	0f be 80 72 1f 80 00 	movsbl 0x801f72(%eax),%eax
  800267:	50                   	push   %eax
  800268:	ff d7                	call   *%edi
}
  80026a:	83 c4 10             	add    $0x10,%esp
  80026d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800270:	5b                   	pop    %ebx
  800271:	5e                   	pop    %esi
  800272:	5f                   	pop    %edi
  800273:	5d                   	pop    %ebp
  800274:	c3                   	ret    

00800275 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800275:	f3 0f 1e fb          	endbr32 
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80027f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800283:	8b 10                	mov    (%eax),%edx
  800285:	3b 50 04             	cmp    0x4(%eax),%edx
  800288:	73 0a                	jae    800294 <sprintputch+0x1f>
		*b->buf++ = ch;
  80028a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80028d:	89 08                	mov    %ecx,(%eax)
  80028f:	8b 45 08             	mov    0x8(%ebp),%eax
  800292:	88 02                	mov    %al,(%edx)
}
  800294:	5d                   	pop    %ebp
  800295:	c3                   	ret    

00800296 <printfmt>:
{
  800296:	f3 0f 1e fb          	endbr32 
  80029a:	55                   	push   %ebp
  80029b:	89 e5                	mov    %esp,%ebp
  80029d:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002a0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002a3:	50                   	push   %eax
  8002a4:	ff 75 10             	pushl  0x10(%ebp)
  8002a7:	ff 75 0c             	pushl  0xc(%ebp)
  8002aa:	ff 75 08             	pushl  0x8(%ebp)
  8002ad:	e8 05 00 00 00       	call   8002b7 <vprintfmt>
}
  8002b2:	83 c4 10             	add    $0x10,%esp
  8002b5:	c9                   	leave  
  8002b6:	c3                   	ret    

008002b7 <vprintfmt>:
{
  8002b7:	f3 0f 1e fb          	endbr32 
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	57                   	push   %edi
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
  8002c1:	83 ec 3c             	sub    $0x3c,%esp
  8002c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8002c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ca:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002cd:	e9 4a 03 00 00       	jmp    80061c <vprintfmt+0x365>
		padc = ' ';
  8002d2:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002d6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002dd:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002e4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002eb:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002f0:	8d 47 01             	lea    0x1(%edi),%eax
  8002f3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002f6:	0f b6 17             	movzbl (%edi),%edx
  8002f9:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002fc:	3c 55                	cmp    $0x55,%al
  8002fe:	0f 87 de 03 00 00    	ja     8006e2 <vprintfmt+0x42b>
  800304:	0f b6 c0             	movzbl %al,%eax
  800307:	3e ff 24 85 c0 20 80 	notrack jmp *0x8020c0(,%eax,4)
  80030e:	00 
  80030f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800312:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800316:	eb d8                	jmp    8002f0 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800318:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80031b:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80031f:	eb cf                	jmp    8002f0 <vprintfmt+0x39>
  800321:	0f b6 d2             	movzbl %dl,%edx
  800324:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800327:	b8 00 00 00 00       	mov    $0x0,%eax
  80032c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80032f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800332:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800336:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800339:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80033c:	83 f9 09             	cmp    $0x9,%ecx
  80033f:	77 55                	ja     800396 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800341:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800344:	eb e9                	jmp    80032f <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800346:	8b 45 14             	mov    0x14(%ebp),%eax
  800349:	8b 00                	mov    (%eax),%eax
  80034b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80034e:	8b 45 14             	mov    0x14(%ebp),%eax
  800351:	8d 40 04             	lea    0x4(%eax),%eax
  800354:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800357:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80035a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80035e:	79 90                	jns    8002f0 <vprintfmt+0x39>
				width = precision, precision = -1;
  800360:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800363:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800366:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80036d:	eb 81                	jmp    8002f0 <vprintfmt+0x39>
  80036f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800372:	85 c0                	test   %eax,%eax
  800374:	ba 00 00 00 00       	mov    $0x0,%edx
  800379:	0f 49 d0             	cmovns %eax,%edx
  80037c:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80037f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800382:	e9 69 ff ff ff       	jmp    8002f0 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800387:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80038a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800391:	e9 5a ff ff ff       	jmp    8002f0 <vprintfmt+0x39>
  800396:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800399:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80039c:	eb bc                	jmp    80035a <vprintfmt+0xa3>
			lflag++;
  80039e:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003a4:	e9 47 ff ff ff       	jmp    8002f0 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ac:	8d 78 04             	lea    0x4(%eax),%edi
  8003af:	83 ec 08             	sub    $0x8,%esp
  8003b2:	53                   	push   %ebx
  8003b3:	ff 30                	pushl  (%eax)
  8003b5:	ff d6                	call   *%esi
			break;
  8003b7:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003ba:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003bd:	e9 57 02 00 00       	jmp    800619 <vprintfmt+0x362>
			err = va_arg(ap, int);
  8003c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c5:	8d 78 04             	lea    0x4(%eax),%edi
  8003c8:	8b 00                	mov    (%eax),%eax
  8003ca:	99                   	cltd   
  8003cb:	31 d0                	xor    %edx,%eax
  8003cd:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003cf:	83 f8 0f             	cmp    $0xf,%eax
  8003d2:	7f 23                	jg     8003f7 <vprintfmt+0x140>
  8003d4:	8b 14 85 20 22 80 00 	mov    0x802220(,%eax,4),%edx
  8003db:	85 d2                	test   %edx,%edx
  8003dd:	74 18                	je     8003f7 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8003df:	52                   	push   %edx
  8003e0:	68 51 23 80 00       	push   $0x802351
  8003e5:	53                   	push   %ebx
  8003e6:	56                   	push   %esi
  8003e7:	e8 aa fe ff ff       	call   800296 <printfmt>
  8003ec:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003ef:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003f2:	e9 22 02 00 00       	jmp    800619 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8003f7:	50                   	push   %eax
  8003f8:	68 8a 1f 80 00       	push   $0x801f8a
  8003fd:	53                   	push   %ebx
  8003fe:	56                   	push   %esi
  8003ff:	e8 92 fe ff ff       	call   800296 <printfmt>
  800404:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800407:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80040a:	e9 0a 02 00 00       	jmp    800619 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  80040f:	8b 45 14             	mov    0x14(%ebp),%eax
  800412:	83 c0 04             	add    $0x4,%eax
  800415:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800418:	8b 45 14             	mov    0x14(%ebp),%eax
  80041b:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80041d:	85 d2                	test   %edx,%edx
  80041f:	b8 83 1f 80 00       	mov    $0x801f83,%eax
  800424:	0f 45 c2             	cmovne %edx,%eax
  800427:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80042a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042e:	7e 06                	jle    800436 <vprintfmt+0x17f>
  800430:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800434:	75 0d                	jne    800443 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800436:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800439:	89 c7                	mov    %eax,%edi
  80043b:	03 45 e0             	add    -0x20(%ebp),%eax
  80043e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800441:	eb 55                	jmp    800498 <vprintfmt+0x1e1>
  800443:	83 ec 08             	sub    $0x8,%esp
  800446:	ff 75 d8             	pushl  -0x28(%ebp)
  800449:	ff 75 cc             	pushl  -0x34(%ebp)
  80044c:	e8 45 03 00 00       	call   800796 <strnlen>
  800451:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800454:	29 c2                	sub    %eax,%edx
  800456:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80045e:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800462:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800465:	85 ff                	test   %edi,%edi
  800467:	7e 11                	jle    80047a <vprintfmt+0x1c3>
					putch(padc, putdat);
  800469:	83 ec 08             	sub    $0x8,%esp
  80046c:	53                   	push   %ebx
  80046d:	ff 75 e0             	pushl  -0x20(%ebp)
  800470:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800472:	83 ef 01             	sub    $0x1,%edi
  800475:	83 c4 10             	add    $0x10,%esp
  800478:	eb eb                	jmp    800465 <vprintfmt+0x1ae>
  80047a:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80047d:	85 d2                	test   %edx,%edx
  80047f:	b8 00 00 00 00       	mov    $0x0,%eax
  800484:	0f 49 c2             	cmovns %edx,%eax
  800487:	29 c2                	sub    %eax,%edx
  800489:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80048c:	eb a8                	jmp    800436 <vprintfmt+0x17f>
					putch(ch, putdat);
  80048e:	83 ec 08             	sub    $0x8,%esp
  800491:	53                   	push   %ebx
  800492:	52                   	push   %edx
  800493:	ff d6                	call   *%esi
  800495:	83 c4 10             	add    $0x10,%esp
  800498:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80049b:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049d:	83 c7 01             	add    $0x1,%edi
  8004a0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004a4:	0f be d0             	movsbl %al,%edx
  8004a7:	85 d2                	test   %edx,%edx
  8004a9:	74 4b                	je     8004f6 <vprintfmt+0x23f>
  8004ab:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004af:	78 06                	js     8004b7 <vprintfmt+0x200>
  8004b1:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004b5:	78 1e                	js     8004d5 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004b7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004bb:	74 d1                	je     80048e <vprintfmt+0x1d7>
  8004bd:	0f be c0             	movsbl %al,%eax
  8004c0:	83 e8 20             	sub    $0x20,%eax
  8004c3:	83 f8 5e             	cmp    $0x5e,%eax
  8004c6:	76 c6                	jbe    80048e <vprintfmt+0x1d7>
					putch('?', putdat);
  8004c8:	83 ec 08             	sub    $0x8,%esp
  8004cb:	53                   	push   %ebx
  8004cc:	6a 3f                	push   $0x3f
  8004ce:	ff d6                	call   *%esi
  8004d0:	83 c4 10             	add    $0x10,%esp
  8004d3:	eb c3                	jmp    800498 <vprintfmt+0x1e1>
  8004d5:	89 cf                	mov    %ecx,%edi
  8004d7:	eb 0e                	jmp    8004e7 <vprintfmt+0x230>
				putch(' ', putdat);
  8004d9:	83 ec 08             	sub    $0x8,%esp
  8004dc:	53                   	push   %ebx
  8004dd:	6a 20                	push   $0x20
  8004df:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004e1:	83 ef 01             	sub    $0x1,%edi
  8004e4:	83 c4 10             	add    $0x10,%esp
  8004e7:	85 ff                	test   %edi,%edi
  8004e9:	7f ee                	jg     8004d9 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8004eb:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004ee:	89 45 14             	mov    %eax,0x14(%ebp)
  8004f1:	e9 23 01 00 00       	jmp    800619 <vprintfmt+0x362>
  8004f6:	89 cf                	mov    %ecx,%edi
  8004f8:	eb ed                	jmp    8004e7 <vprintfmt+0x230>
	if (lflag >= 2)
  8004fa:	83 f9 01             	cmp    $0x1,%ecx
  8004fd:	7f 1b                	jg     80051a <vprintfmt+0x263>
	else if (lflag)
  8004ff:	85 c9                	test   %ecx,%ecx
  800501:	74 63                	je     800566 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800503:	8b 45 14             	mov    0x14(%ebp),%eax
  800506:	8b 00                	mov    (%eax),%eax
  800508:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80050b:	99                   	cltd   
  80050c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80050f:	8b 45 14             	mov    0x14(%ebp),%eax
  800512:	8d 40 04             	lea    0x4(%eax),%eax
  800515:	89 45 14             	mov    %eax,0x14(%ebp)
  800518:	eb 17                	jmp    800531 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80051a:	8b 45 14             	mov    0x14(%ebp),%eax
  80051d:	8b 50 04             	mov    0x4(%eax),%edx
  800520:	8b 00                	mov    (%eax),%eax
  800522:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800525:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800528:	8b 45 14             	mov    0x14(%ebp),%eax
  80052b:	8d 40 08             	lea    0x8(%eax),%eax
  80052e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800531:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800534:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800537:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80053c:	85 c9                	test   %ecx,%ecx
  80053e:	0f 89 bb 00 00 00    	jns    8005ff <vprintfmt+0x348>
				putch('-', putdat);
  800544:	83 ec 08             	sub    $0x8,%esp
  800547:	53                   	push   %ebx
  800548:	6a 2d                	push   $0x2d
  80054a:	ff d6                	call   *%esi
				num = -(long long) num;
  80054c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80054f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800552:	f7 da                	neg    %edx
  800554:	83 d1 00             	adc    $0x0,%ecx
  800557:	f7 d9                	neg    %ecx
  800559:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80055c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800561:	e9 99 00 00 00       	jmp    8005ff <vprintfmt+0x348>
		return va_arg(*ap, int);
  800566:	8b 45 14             	mov    0x14(%ebp),%eax
  800569:	8b 00                	mov    (%eax),%eax
  80056b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056e:	99                   	cltd   
  80056f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800572:	8b 45 14             	mov    0x14(%ebp),%eax
  800575:	8d 40 04             	lea    0x4(%eax),%eax
  800578:	89 45 14             	mov    %eax,0x14(%ebp)
  80057b:	eb b4                	jmp    800531 <vprintfmt+0x27a>
	if (lflag >= 2)
  80057d:	83 f9 01             	cmp    $0x1,%ecx
  800580:	7f 1b                	jg     80059d <vprintfmt+0x2e6>
	else if (lflag)
  800582:	85 c9                	test   %ecx,%ecx
  800584:	74 2c                	je     8005b2 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8b 10                	mov    (%eax),%edx
  80058b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800590:	8d 40 04             	lea    0x4(%eax),%eax
  800593:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800596:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80059b:	eb 62                	jmp    8005ff <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80059d:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a0:	8b 10                	mov    (%eax),%edx
  8005a2:	8b 48 04             	mov    0x4(%eax),%ecx
  8005a5:	8d 40 08             	lea    0x8(%eax),%eax
  8005a8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ab:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005b0:	eb 4d                	jmp    8005ff <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8005b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b5:	8b 10                	mov    (%eax),%edx
  8005b7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005bc:	8d 40 04             	lea    0x4(%eax),%eax
  8005bf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005c2:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8005c7:	eb 36                	jmp    8005ff <vprintfmt+0x348>
	if (lflag >= 2)
  8005c9:	83 f9 01             	cmp    $0x1,%ecx
  8005cc:	7f 17                	jg     8005e5 <vprintfmt+0x32e>
	else if (lflag)
  8005ce:	85 c9                	test   %ecx,%ecx
  8005d0:	74 6e                	je     800640 <vprintfmt+0x389>
		return va_arg(*ap, long);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8b 10                	mov    (%eax),%edx
  8005d7:	89 d0                	mov    %edx,%eax
  8005d9:	99                   	cltd   
  8005da:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005dd:	8d 49 04             	lea    0x4(%ecx),%ecx
  8005e0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005e3:	eb 11                	jmp    8005f6 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8005e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e8:	8b 50 04             	mov    0x4(%eax),%edx
  8005eb:	8b 00                	mov    (%eax),%eax
  8005ed:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005f0:	8d 49 08             	lea    0x8(%ecx),%ecx
  8005f3:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8005f6:	89 d1                	mov    %edx,%ecx
  8005f8:	89 c2                	mov    %eax,%edx
            base = 8;
  8005fa:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005ff:	83 ec 0c             	sub    $0xc,%esp
  800602:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800606:	57                   	push   %edi
  800607:	ff 75 e0             	pushl  -0x20(%ebp)
  80060a:	50                   	push   %eax
  80060b:	51                   	push   %ecx
  80060c:	52                   	push   %edx
  80060d:	89 da                	mov    %ebx,%edx
  80060f:	89 f0                	mov    %esi,%eax
  800611:	e8 b6 fb ff ff       	call   8001cc <printnum>
			break;
  800616:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800619:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80061c:	83 c7 01             	add    $0x1,%edi
  80061f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800623:	83 f8 25             	cmp    $0x25,%eax
  800626:	0f 84 a6 fc ff ff    	je     8002d2 <vprintfmt+0x1b>
			if (ch == '\0')
  80062c:	85 c0                	test   %eax,%eax
  80062e:	0f 84 ce 00 00 00    	je     800702 <vprintfmt+0x44b>
			putch(ch, putdat);
  800634:	83 ec 08             	sub    $0x8,%esp
  800637:	53                   	push   %ebx
  800638:	50                   	push   %eax
  800639:	ff d6                	call   *%esi
  80063b:	83 c4 10             	add    $0x10,%esp
  80063e:	eb dc                	jmp    80061c <vprintfmt+0x365>
		return va_arg(*ap, int);
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8b 10                	mov    (%eax),%edx
  800645:	89 d0                	mov    %edx,%eax
  800647:	99                   	cltd   
  800648:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80064b:	8d 49 04             	lea    0x4(%ecx),%ecx
  80064e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800651:	eb a3                	jmp    8005f6 <vprintfmt+0x33f>
			putch('0', putdat);
  800653:	83 ec 08             	sub    $0x8,%esp
  800656:	53                   	push   %ebx
  800657:	6a 30                	push   $0x30
  800659:	ff d6                	call   *%esi
			putch('x', putdat);
  80065b:	83 c4 08             	add    $0x8,%esp
  80065e:	53                   	push   %ebx
  80065f:	6a 78                	push   $0x78
  800661:	ff d6                	call   *%esi
			num = (unsigned long long)
  800663:	8b 45 14             	mov    0x14(%ebp),%eax
  800666:	8b 10                	mov    (%eax),%edx
  800668:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80066d:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800670:	8d 40 04             	lea    0x4(%eax),%eax
  800673:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800676:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80067b:	eb 82                	jmp    8005ff <vprintfmt+0x348>
	if (lflag >= 2)
  80067d:	83 f9 01             	cmp    $0x1,%ecx
  800680:	7f 1e                	jg     8006a0 <vprintfmt+0x3e9>
	else if (lflag)
  800682:	85 c9                	test   %ecx,%ecx
  800684:	74 32                	je     8006b8 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800686:	8b 45 14             	mov    0x14(%ebp),%eax
  800689:	8b 10                	mov    (%eax),%edx
  80068b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800690:	8d 40 04             	lea    0x4(%eax),%eax
  800693:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800696:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80069b:	e9 5f ff ff ff       	jmp    8005ff <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8006a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a3:	8b 10                	mov    (%eax),%edx
  8006a5:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a8:	8d 40 08             	lea    0x8(%eax),%eax
  8006ab:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ae:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006b3:	e9 47 ff ff ff       	jmp    8005ff <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8006b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bb:	8b 10                	mov    (%eax),%edx
  8006bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c2:	8d 40 04             	lea    0x4(%eax),%eax
  8006c5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c8:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006cd:	e9 2d ff ff ff       	jmp    8005ff <vprintfmt+0x348>
			putch(ch, putdat);
  8006d2:	83 ec 08             	sub    $0x8,%esp
  8006d5:	53                   	push   %ebx
  8006d6:	6a 25                	push   $0x25
  8006d8:	ff d6                	call   *%esi
			break;
  8006da:	83 c4 10             	add    $0x10,%esp
  8006dd:	e9 37 ff ff ff       	jmp    800619 <vprintfmt+0x362>
			putch('%', putdat);
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	53                   	push   %ebx
  8006e6:	6a 25                	push   $0x25
  8006e8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ea:	83 c4 10             	add    $0x10,%esp
  8006ed:	89 f8                	mov    %edi,%eax
  8006ef:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006f3:	74 05                	je     8006fa <vprintfmt+0x443>
  8006f5:	83 e8 01             	sub    $0x1,%eax
  8006f8:	eb f5                	jmp    8006ef <vprintfmt+0x438>
  8006fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006fd:	e9 17 ff ff ff       	jmp    800619 <vprintfmt+0x362>
}
  800702:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800705:	5b                   	pop    %ebx
  800706:	5e                   	pop    %esi
  800707:	5f                   	pop    %edi
  800708:	5d                   	pop    %ebp
  800709:	c3                   	ret    

0080070a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80070a:	f3 0f 1e fb          	endbr32 
  80070e:	55                   	push   %ebp
  80070f:	89 e5                	mov    %esp,%ebp
  800711:	83 ec 18             	sub    $0x18,%esp
  800714:	8b 45 08             	mov    0x8(%ebp),%eax
  800717:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80071a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80071d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800721:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800724:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80072b:	85 c0                	test   %eax,%eax
  80072d:	74 26                	je     800755 <vsnprintf+0x4b>
  80072f:	85 d2                	test   %edx,%edx
  800731:	7e 22                	jle    800755 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800733:	ff 75 14             	pushl  0x14(%ebp)
  800736:	ff 75 10             	pushl  0x10(%ebp)
  800739:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80073c:	50                   	push   %eax
  80073d:	68 75 02 80 00       	push   $0x800275
  800742:	e8 70 fb ff ff       	call   8002b7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800747:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80074a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80074d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800750:	83 c4 10             	add    $0x10,%esp
}
  800753:	c9                   	leave  
  800754:	c3                   	ret    
		return -E_INVAL;
  800755:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80075a:	eb f7                	jmp    800753 <vsnprintf+0x49>

0080075c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80075c:	f3 0f 1e fb          	endbr32 
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800766:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800769:	50                   	push   %eax
  80076a:	ff 75 10             	pushl  0x10(%ebp)
  80076d:	ff 75 0c             	pushl  0xc(%ebp)
  800770:	ff 75 08             	pushl  0x8(%ebp)
  800773:	e8 92 ff ff ff       	call   80070a <vsnprintf>
	va_end(ap);

	return rc;
}
  800778:	c9                   	leave  
  800779:	c3                   	ret    

0080077a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80077a:	f3 0f 1e fb          	endbr32 
  80077e:	55                   	push   %ebp
  80077f:	89 e5                	mov    %esp,%ebp
  800781:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800784:	b8 00 00 00 00       	mov    $0x0,%eax
  800789:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80078d:	74 05                	je     800794 <strlen+0x1a>
		n++;
  80078f:	83 c0 01             	add    $0x1,%eax
  800792:	eb f5                	jmp    800789 <strlen+0xf>
	return n;
}
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800796:	f3 0f 1e fb          	endbr32 
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a0:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a8:	39 d0                	cmp    %edx,%eax
  8007aa:	74 0d                	je     8007b9 <strnlen+0x23>
  8007ac:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007b0:	74 05                	je     8007b7 <strnlen+0x21>
		n++;
  8007b2:	83 c0 01             	add    $0x1,%eax
  8007b5:	eb f1                	jmp    8007a8 <strnlen+0x12>
  8007b7:	89 c2                	mov    %eax,%edx
	return n;
}
  8007b9:	89 d0                	mov    %edx,%eax
  8007bb:	5d                   	pop    %ebp
  8007bc:	c3                   	ret    

008007bd <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007bd:	f3 0f 1e fb          	endbr32 
  8007c1:	55                   	push   %ebp
  8007c2:	89 e5                	mov    %esp,%ebp
  8007c4:	53                   	push   %ebx
  8007c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d0:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007d4:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007d7:	83 c0 01             	add    $0x1,%eax
  8007da:	84 d2                	test   %dl,%dl
  8007dc:	75 f2                	jne    8007d0 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8007de:	89 c8                	mov    %ecx,%eax
  8007e0:	5b                   	pop    %ebx
  8007e1:	5d                   	pop    %ebp
  8007e2:	c3                   	ret    

008007e3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e3:	f3 0f 1e fb          	endbr32 
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	53                   	push   %ebx
  8007eb:	83 ec 10             	sub    $0x10,%esp
  8007ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f1:	53                   	push   %ebx
  8007f2:	e8 83 ff ff ff       	call   80077a <strlen>
  8007f7:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007fa:	ff 75 0c             	pushl  0xc(%ebp)
  8007fd:	01 d8                	add    %ebx,%eax
  8007ff:	50                   	push   %eax
  800800:	e8 b8 ff ff ff       	call   8007bd <strcpy>
	return dst;
}
  800805:	89 d8                	mov    %ebx,%eax
  800807:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80080a:	c9                   	leave  
  80080b:	c3                   	ret    

0080080c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80080c:	f3 0f 1e fb          	endbr32 
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	56                   	push   %esi
  800814:	53                   	push   %ebx
  800815:	8b 75 08             	mov    0x8(%ebp),%esi
  800818:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081b:	89 f3                	mov    %esi,%ebx
  80081d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800820:	89 f0                	mov    %esi,%eax
  800822:	39 d8                	cmp    %ebx,%eax
  800824:	74 11                	je     800837 <strncpy+0x2b>
		*dst++ = *src;
  800826:	83 c0 01             	add    $0x1,%eax
  800829:	0f b6 0a             	movzbl (%edx),%ecx
  80082c:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80082f:	80 f9 01             	cmp    $0x1,%cl
  800832:	83 da ff             	sbb    $0xffffffff,%edx
  800835:	eb eb                	jmp    800822 <strncpy+0x16>
	}
	return ret;
}
  800837:	89 f0                	mov    %esi,%eax
  800839:	5b                   	pop    %ebx
  80083a:	5e                   	pop    %esi
  80083b:	5d                   	pop    %ebp
  80083c:	c3                   	ret    

0080083d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80083d:	f3 0f 1e fb          	endbr32 
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	56                   	push   %esi
  800845:	53                   	push   %ebx
  800846:	8b 75 08             	mov    0x8(%ebp),%esi
  800849:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80084c:	8b 55 10             	mov    0x10(%ebp),%edx
  80084f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800851:	85 d2                	test   %edx,%edx
  800853:	74 21                	je     800876 <strlcpy+0x39>
  800855:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800859:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80085b:	39 c2                	cmp    %eax,%edx
  80085d:	74 14                	je     800873 <strlcpy+0x36>
  80085f:	0f b6 19             	movzbl (%ecx),%ebx
  800862:	84 db                	test   %bl,%bl
  800864:	74 0b                	je     800871 <strlcpy+0x34>
			*dst++ = *src++;
  800866:	83 c1 01             	add    $0x1,%ecx
  800869:	83 c2 01             	add    $0x1,%edx
  80086c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80086f:	eb ea                	jmp    80085b <strlcpy+0x1e>
  800871:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800873:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800876:	29 f0                	sub    %esi,%eax
}
  800878:	5b                   	pop    %ebx
  800879:	5e                   	pop    %esi
  80087a:	5d                   	pop    %ebp
  80087b:	c3                   	ret    

0080087c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80087c:	f3 0f 1e fb          	endbr32 
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800886:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800889:	0f b6 01             	movzbl (%ecx),%eax
  80088c:	84 c0                	test   %al,%al
  80088e:	74 0c                	je     80089c <strcmp+0x20>
  800890:	3a 02                	cmp    (%edx),%al
  800892:	75 08                	jne    80089c <strcmp+0x20>
		p++, q++;
  800894:	83 c1 01             	add    $0x1,%ecx
  800897:	83 c2 01             	add    $0x1,%edx
  80089a:	eb ed                	jmp    800889 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80089c:	0f b6 c0             	movzbl %al,%eax
  80089f:	0f b6 12             	movzbl (%edx),%edx
  8008a2:	29 d0                	sub    %edx,%eax
}
  8008a4:	5d                   	pop    %ebp
  8008a5:	c3                   	ret    

008008a6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a6:	f3 0f 1e fb          	endbr32 
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	53                   	push   %ebx
  8008ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b4:	89 c3                	mov    %eax,%ebx
  8008b6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b9:	eb 06                	jmp    8008c1 <strncmp+0x1b>
		n--, p++, q++;
  8008bb:	83 c0 01             	add    $0x1,%eax
  8008be:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008c1:	39 d8                	cmp    %ebx,%eax
  8008c3:	74 16                	je     8008db <strncmp+0x35>
  8008c5:	0f b6 08             	movzbl (%eax),%ecx
  8008c8:	84 c9                	test   %cl,%cl
  8008ca:	74 04                	je     8008d0 <strncmp+0x2a>
  8008cc:	3a 0a                	cmp    (%edx),%cl
  8008ce:	74 eb                	je     8008bb <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d0:	0f b6 00             	movzbl (%eax),%eax
  8008d3:	0f b6 12             	movzbl (%edx),%edx
  8008d6:	29 d0                	sub    %edx,%eax
}
  8008d8:	5b                   	pop    %ebx
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    
		return 0;
  8008db:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e0:	eb f6                	jmp    8008d8 <strncmp+0x32>

008008e2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e2:	f3 0f 1e fb          	endbr32 
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ec:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f0:	0f b6 10             	movzbl (%eax),%edx
  8008f3:	84 d2                	test   %dl,%dl
  8008f5:	74 09                	je     800900 <strchr+0x1e>
		if (*s == c)
  8008f7:	38 ca                	cmp    %cl,%dl
  8008f9:	74 0a                	je     800905 <strchr+0x23>
	for (; *s; s++)
  8008fb:	83 c0 01             	add    $0x1,%eax
  8008fe:	eb f0                	jmp    8008f0 <strchr+0xe>
			return (char *) s;
	return 0;
  800900:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800907:	f3 0f 1e fb          	endbr32 
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	8b 45 08             	mov    0x8(%ebp),%eax
  800911:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800915:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800918:	38 ca                	cmp    %cl,%dl
  80091a:	74 09                	je     800925 <strfind+0x1e>
  80091c:	84 d2                	test   %dl,%dl
  80091e:	74 05                	je     800925 <strfind+0x1e>
	for (; *s; s++)
  800920:	83 c0 01             	add    $0x1,%eax
  800923:	eb f0                	jmp    800915 <strfind+0xe>
			break;
	return (char *) s;
}
  800925:	5d                   	pop    %ebp
  800926:	c3                   	ret    

00800927 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800927:	f3 0f 1e fb          	endbr32 
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	57                   	push   %edi
  80092f:	56                   	push   %esi
  800930:	53                   	push   %ebx
  800931:	8b 7d 08             	mov    0x8(%ebp),%edi
  800934:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800937:	85 c9                	test   %ecx,%ecx
  800939:	74 31                	je     80096c <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80093b:	89 f8                	mov    %edi,%eax
  80093d:	09 c8                	or     %ecx,%eax
  80093f:	a8 03                	test   $0x3,%al
  800941:	75 23                	jne    800966 <memset+0x3f>
		c &= 0xFF;
  800943:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800947:	89 d3                	mov    %edx,%ebx
  800949:	c1 e3 08             	shl    $0x8,%ebx
  80094c:	89 d0                	mov    %edx,%eax
  80094e:	c1 e0 18             	shl    $0x18,%eax
  800951:	89 d6                	mov    %edx,%esi
  800953:	c1 e6 10             	shl    $0x10,%esi
  800956:	09 f0                	or     %esi,%eax
  800958:	09 c2                	or     %eax,%edx
  80095a:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80095c:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80095f:	89 d0                	mov    %edx,%eax
  800961:	fc                   	cld    
  800962:	f3 ab                	rep stos %eax,%es:(%edi)
  800964:	eb 06                	jmp    80096c <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800966:	8b 45 0c             	mov    0xc(%ebp),%eax
  800969:	fc                   	cld    
  80096a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80096c:	89 f8                	mov    %edi,%eax
  80096e:	5b                   	pop    %ebx
  80096f:	5e                   	pop    %esi
  800970:	5f                   	pop    %edi
  800971:	5d                   	pop    %ebp
  800972:	c3                   	ret    

00800973 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800973:	f3 0f 1e fb          	endbr32 
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	57                   	push   %edi
  80097b:	56                   	push   %esi
  80097c:	8b 45 08             	mov    0x8(%ebp),%eax
  80097f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800982:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800985:	39 c6                	cmp    %eax,%esi
  800987:	73 32                	jae    8009bb <memmove+0x48>
  800989:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80098c:	39 c2                	cmp    %eax,%edx
  80098e:	76 2b                	jbe    8009bb <memmove+0x48>
		s += n;
		d += n;
  800990:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800993:	89 fe                	mov    %edi,%esi
  800995:	09 ce                	or     %ecx,%esi
  800997:	09 d6                	or     %edx,%esi
  800999:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80099f:	75 0e                	jne    8009af <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009a1:	83 ef 04             	sub    $0x4,%edi
  8009a4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009aa:	fd                   	std    
  8009ab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ad:	eb 09                	jmp    8009b8 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009af:	83 ef 01             	sub    $0x1,%edi
  8009b2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009b5:	fd                   	std    
  8009b6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b8:	fc                   	cld    
  8009b9:	eb 1a                	jmp    8009d5 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009bb:	89 c2                	mov    %eax,%edx
  8009bd:	09 ca                	or     %ecx,%edx
  8009bf:	09 f2                	or     %esi,%edx
  8009c1:	f6 c2 03             	test   $0x3,%dl
  8009c4:	75 0a                	jne    8009d0 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009c6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009c9:	89 c7                	mov    %eax,%edi
  8009cb:	fc                   	cld    
  8009cc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ce:	eb 05                	jmp    8009d5 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8009d0:	89 c7                	mov    %eax,%edi
  8009d2:	fc                   	cld    
  8009d3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d5:	5e                   	pop    %esi
  8009d6:	5f                   	pop    %edi
  8009d7:	5d                   	pop    %ebp
  8009d8:	c3                   	ret    

008009d9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d9:	f3 0f 1e fb          	endbr32 
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009e3:	ff 75 10             	pushl  0x10(%ebp)
  8009e6:	ff 75 0c             	pushl  0xc(%ebp)
  8009e9:	ff 75 08             	pushl  0x8(%ebp)
  8009ec:	e8 82 ff ff ff       	call   800973 <memmove>
}
  8009f1:	c9                   	leave  
  8009f2:	c3                   	ret    

008009f3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f3:	f3 0f 1e fb          	endbr32 
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	56                   	push   %esi
  8009fb:	53                   	push   %ebx
  8009fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a02:	89 c6                	mov    %eax,%esi
  800a04:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a07:	39 f0                	cmp    %esi,%eax
  800a09:	74 1c                	je     800a27 <memcmp+0x34>
		if (*s1 != *s2)
  800a0b:	0f b6 08             	movzbl (%eax),%ecx
  800a0e:	0f b6 1a             	movzbl (%edx),%ebx
  800a11:	38 d9                	cmp    %bl,%cl
  800a13:	75 08                	jne    800a1d <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a15:	83 c0 01             	add    $0x1,%eax
  800a18:	83 c2 01             	add    $0x1,%edx
  800a1b:	eb ea                	jmp    800a07 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a1d:	0f b6 c1             	movzbl %cl,%eax
  800a20:	0f b6 db             	movzbl %bl,%ebx
  800a23:	29 d8                	sub    %ebx,%eax
  800a25:	eb 05                	jmp    800a2c <memcmp+0x39>
	}

	return 0;
  800a27:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2c:	5b                   	pop    %ebx
  800a2d:	5e                   	pop    %esi
  800a2e:	5d                   	pop    %ebp
  800a2f:	c3                   	ret    

00800a30 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a30:	f3 0f 1e fb          	endbr32 
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a3d:	89 c2                	mov    %eax,%edx
  800a3f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a42:	39 d0                	cmp    %edx,%eax
  800a44:	73 09                	jae    800a4f <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a46:	38 08                	cmp    %cl,(%eax)
  800a48:	74 05                	je     800a4f <memfind+0x1f>
	for (; s < ends; s++)
  800a4a:	83 c0 01             	add    $0x1,%eax
  800a4d:	eb f3                	jmp    800a42 <memfind+0x12>
			break;
	return (void *) s;
}
  800a4f:	5d                   	pop    %ebp
  800a50:	c3                   	ret    

00800a51 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a51:	f3 0f 1e fb          	endbr32 
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	57                   	push   %edi
  800a59:	56                   	push   %esi
  800a5a:	53                   	push   %ebx
  800a5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a61:	eb 03                	jmp    800a66 <strtol+0x15>
		s++;
  800a63:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a66:	0f b6 01             	movzbl (%ecx),%eax
  800a69:	3c 20                	cmp    $0x20,%al
  800a6b:	74 f6                	je     800a63 <strtol+0x12>
  800a6d:	3c 09                	cmp    $0x9,%al
  800a6f:	74 f2                	je     800a63 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a71:	3c 2b                	cmp    $0x2b,%al
  800a73:	74 2a                	je     800a9f <strtol+0x4e>
	int neg = 0;
  800a75:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a7a:	3c 2d                	cmp    $0x2d,%al
  800a7c:	74 2b                	je     800aa9 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a7e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a84:	75 0f                	jne    800a95 <strtol+0x44>
  800a86:	80 39 30             	cmpb   $0x30,(%ecx)
  800a89:	74 28                	je     800ab3 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a8b:	85 db                	test   %ebx,%ebx
  800a8d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a92:	0f 44 d8             	cmove  %eax,%ebx
  800a95:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a9d:	eb 46                	jmp    800ae5 <strtol+0x94>
		s++;
  800a9f:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800aa2:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa7:	eb d5                	jmp    800a7e <strtol+0x2d>
		s++, neg = 1;
  800aa9:	83 c1 01             	add    $0x1,%ecx
  800aac:	bf 01 00 00 00       	mov    $0x1,%edi
  800ab1:	eb cb                	jmp    800a7e <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ab7:	74 0e                	je     800ac7 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ab9:	85 db                	test   %ebx,%ebx
  800abb:	75 d8                	jne    800a95 <strtol+0x44>
		s++, base = 8;
  800abd:	83 c1 01             	add    $0x1,%ecx
  800ac0:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ac5:	eb ce                	jmp    800a95 <strtol+0x44>
		s += 2, base = 16;
  800ac7:	83 c1 02             	add    $0x2,%ecx
  800aca:	bb 10 00 00 00       	mov    $0x10,%ebx
  800acf:	eb c4                	jmp    800a95 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ad1:	0f be d2             	movsbl %dl,%edx
  800ad4:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ad7:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ada:	7d 3a                	jge    800b16 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800adc:	83 c1 01             	add    $0x1,%ecx
  800adf:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ae3:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ae5:	0f b6 11             	movzbl (%ecx),%edx
  800ae8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aeb:	89 f3                	mov    %esi,%ebx
  800aed:	80 fb 09             	cmp    $0x9,%bl
  800af0:	76 df                	jbe    800ad1 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800af2:	8d 72 9f             	lea    -0x61(%edx),%esi
  800af5:	89 f3                	mov    %esi,%ebx
  800af7:	80 fb 19             	cmp    $0x19,%bl
  800afa:	77 08                	ja     800b04 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800afc:	0f be d2             	movsbl %dl,%edx
  800aff:	83 ea 57             	sub    $0x57,%edx
  800b02:	eb d3                	jmp    800ad7 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b04:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b07:	89 f3                	mov    %esi,%ebx
  800b09:	80 fb 19             	cmp    $0x19,%bl
  800b0c:	77 08                	ja     800b16 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b0e:	0f be d2             	movsbl %dl,%edx
  800b11:	83 ea 37             	sub    $0x37,%edx
  800b14:	eb c1                	jmp    800ad7 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b16:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1a:	74 05                	je     800b21 <strtol+0xd0>
		*endptr = (char *) s;
  800b1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b1f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b21:	89 c2                	mov    %eax,%edx
  800b23:	f7 da                	neg    %edx
  800b25:	85 ff                	test   %edi,%edi
  800b27:	0f 45 c2             	cmovne %edx,%eax
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5f                   	pop    %edi
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b2f:	f3 0f 1e fb          	endbr32 
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
  800b36:	57                   	push   %edi
  800b37:	56                   	push   %esi
  800b38:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b39:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b44:	89 c3                	mov    %eax,%ebx
  800b46:	89 c7                	mov    %eax,%edi
  800b48:	89 c6                	mov    %eax,%esi
  800b4a:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b4c:	5b                   	pop    %ebx
  800b4d:	5e                   	pop    %esi
  800b4e:	5f                   	pop    %edi
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    

00800b51 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b51:	f3 0f 1e fb          	endbr32 
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	57                   	push   %edi
  800b59:	56                   	push   %esi
  800b5a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b60:	b8 01 00 00 00       	mov    $0x1,%eax
  800b65:	89 d1                	mov    %edx,%ecx
  800b67:	89 d3                	mov    %edx,%ebx
  800b69:	89 d7                	mov    %edx,%edi
  800b6b:	89 d6                	mov    %edx,%esi
  800b6d:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b6f:	5b                   	pop    %ebx
  800b70:	5e                   	pop    %esi
  800b71:	5f                   	pop    %edi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b74:	f3 0f 1e fb          	endbr32 
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	57                   	push   %edi
  800b7c:	56                   	push   %esi
  800b7d:	53                   	push   %ebx
  800b7e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b81:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b86:	8b 55 08             	mov    0x8(%ebp),%edx
  800b89:	b8 03 00 00 00       	mov    $0x3,%eax
  800b8e:	89 cb                	mov    %ecx,%ebx
  800b90:	89 cf                	mov    %ecx,%edi
  800b92:	89 ce                	mov    %ecx,%esi
  800b94:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b96:	85 c0                	test   %eax,%eax
  800b98:	7f 08                	jg     800ba2 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9d:	5b                   	pop    %ebx
  800b9e:	5e                   	pop    %esi
  800b9f:	5f                   	pop    %edi
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba2:	83 ec 0c             	sub    $0xc,%esp
  800ba5:	50                   	push   %eax
  800ba6:	6a 03                	push   $0x3
  800ba8:	68 7f 22 80 00       	push   $0x80227f
  800bad:	6a 23                	push   $0x23
  800baf:	68 9c 22 80 00       	push   $0x80229c
  800bb4:	e8 96 10 00 00       	call   801c4f <_panic>

00800bb9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bb9:	f3 0f 1e fb          	endbr32 
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	57                   	push   %edi
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bc3:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc8:	b8 02 00 00 00       	mov    $0x2,%eax
  800bcd:	89 d1                	mov    %edx,%ecx
  800bcf:	89 d3                	mov    %edx,%ebx
  800bd1:	89 d7                	mov    %edx,%edi
  800bd3:	89 d6                	mov    %edx,%esi
  800bd5:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd7:	5b                   	pop    %ebx
  800bd8:	5e                   	pop    %esi
  800bd9:	5f                   	pop    %edi
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <sys_yield>:

void
sys_yield(void)
{
  800bdc:	f3 0f 1e fb          	endbr32 
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	57                   	push   %edi
  800be4:	56                   	push   %esi
  800be5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800be6:	ba 00 00 00 00       	mov    $0x0,%edx
  800beb:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bf0:	89 d1                	mov    %edx,%ecx
  800bf2:	89 d3                	mov    %edx,%ebx
  800bf4:	89 d7                	mov    %edx,%edi
  800bf6:	89 d6                	mov    %edx,%esi
  800bf8:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bfa:	5b                   	pop    %ebx
  800bfb:	5e                   	pop    %esi
  800bfc:	5f                   	pop    %edi
  800bfd:	5d                   	pop    %ebp
  800bfe:	c3                   	ret    

00800bff <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bff:	f3 0f 1e fb          	endbr32 
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	57                   	push   %edi
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
  800c09:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c0c:	be 00 00 00 00       	mov    $0x0,%esi
  800c11:	8b 55 08             	mov    0x8(%ebp),%edx
  800c14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c17:	b8 04 00 00 00       	mov    $0x4,%eax
  800c1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1f:	89 f7                	mov    %esi,%edi
  800c21:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c23:	85 c0                	test   %eax,%eax
  800c25:	7f 08                	jg     800c2f <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2a:	5b                   	pop    %ebx
  800c2b:	5e                   	pop    %esi
  800c2c:	5f                   	pop    %edi
  800c2d:	5d                   	pop    %ebp
  800c2e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2f:	83 ec 0c             	sub    $0xc,%esp
  800c32:	50                   	push   %eax
  800c33:	6a 04                	push   $0x4
  800c35:	68 7f 22 80 00       	push   $0x80227f
  800c3a:	6a 23                	push   $0x23
  800c3c:	68 9c 22 80 00       	push   $0x80229c
  800c41:	e8 09 10 00 00       	call   801c4f <_panic>

00800c46 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c46:	f3 0f 1e fb          	endbr32 
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	57                   	push   %edi
  800c4e:	56                   	push   %esi
  800c4f:	53                   	push   %ebx
  800c50:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c53:	8b 55 08             	mov    0x8(%ebp),%edx
  800c56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c59:	b8 05 00 00 00       	mov    $0x5,%eax
  800c5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c61:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c64:	8b 75 18             	mov    0x18(%ebp),%esi
  800c67:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c69:	85 c0                	test   %eax,%eax
  800c6b:	7f 08                	jg     800c75 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c70:	5b                   	pop    %ebx
  800c71:	5e                   	pop    %esi
  800c72:	5f                   	pop    %edi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c75:	83 ec 0c             	sub    $0xc,%esp
  800c78:	50                   	push   %eax
  800c79:	6a 05                	push   $0x5
  800c7b:	68 7f 22 80 00       	push   $0x80227f
  800c80:	6a 23                	push   $0x23
  800c82:	68 9c 22 80 00       	push   $0x80229c
  800c87:	e8 c3 0f 00 00       	call   801c4f <_panic>

00800c8c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c8c:	f3 0f 1e fb          	endbr32 
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	57                   	push   %edi
  800c94:	56                   	push   %esi
  800c95:	53                   	push   %ebx
  800c96:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c99:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca4:	b8 06 00 00 00       	mov    $0x6,%eax
  800ca9:	89 df                	mov    %ebx,%edi
  800cab:	89 de                	mov    %ebx,%esi
  800cad:	cd 30                	int    $0x30
	if(check && ret > 0)
  800caf:	85 c0                	test   %eax,%eax
  800cb1:	7f 08                	jg     800cbb <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb6:	5b                   	pop    %ebx
  800cb7:	5e                   	pop    %esi
  800cb8:	5f                   	pop    %edi
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbb:	83 ec 0c             	sub    $0xc,%esp
  800cbe:	50                   	push   %eax
  800cbf:	6a 06                	push   $0x6
  800cc1:	68 7f 22 80 00       	push   $0x80227f
  800cc6:	6a 23                	push   $0x23
  800cc8:	68 9c 22 80 00       	push   $0x80229c
  800ccd:	e8 7d 0f 00 00       	call   801c4f <_panic>

00800cd2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cd2:	f3 0f 1e fb          	endbr32 
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	57                   	push   %edi
  800cda:	56                   	push   %esi
  800cdb:	53                   	push   %ebx
  800cdc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cdf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cea:	b8 08 00 00 00       	mov    $0x8,%eax
  800cef:	89 df                	mov    %ebx,%edi
  800cf1:	89 de                	mov    %ebx,%esi
  800cf3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf5:	85 c0                	test   %eax,%eax
  800cf7:	7f 08                	jg     800d01 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfc:	5b                   	pop    %ebx
  800cfd:	5e                   	pop    %esi
  800cfe:	5f                   	pop    %edi
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d01:	83 ec 0c             	sub    $0xc,%esp
  800d04:	50                   	push   %eax
  800d05:	6a 08                	push   $0x8
  800d07:	68 7f 22 80 00       	push   $0x80227f
  800d0c:	6a 23                	push   $0x23
  800d0e:	68 9c 22 80 00       	push   $0x80229c
  800d13:	e8 37 0f 00 00       	call   801c4f <_panic>

00800d18 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d18:	f3 0f 1e fb          	endbr32 
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	57                   	push   %edi
  800d20:	56                   	push   %esi
  800d21:	53                   	push   %ebx
  800d22:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d25:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d30:	b8 09 00 00 00       	mov    $0x9,%eax
  800d35:	89 df                	mov    %ebx,%edi
  800d37:	89 de                	mov    %ebx,%esi
  800d39:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d3b:	85 c0                	test   %eax,%eax
  800d3d:	7f 08                	jg     800d47 <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d42:	5b                   	pop    %ebx
  800d43:	5e                   	pop    %esi
  800d44:	5f                   	pop    %edi
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d47:	83 ec 0c             	sub    $0xc,%esp
  800d4a:	50                   	push   %eax
  800d4b:	6a 09                	push   $0x9
  800d4d:	68 7f 22 80 00       	push   $0x80227f
  800d52:	6a 23                	push   $0x23
  800d54:	68 9c 22 80 00       	push   $0x80229c
  800d59:	e8 f1 0e 00 00       	call   801c4f <_panic>

00800d5e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d5e:	f3 0f 1e fb          	endbr32 
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	57                   	push   %edi
  800d66:	56                   	push   %esi
  800d67:	53                   	push   %ebx
  800d68:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d6b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d70:	8b 55 08             	mov    0x8(%ebp),%edx
  800d73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d76:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d7b:	89 df                	mov    %ebx,%edi
  800d7d:	89 de                	mov    %ebx,%esi
  800d7f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d81:	85 c0                	test   %eax,%eax
  800d83:	7f 08                	jg     800d8d <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d88:	5b                   	pop    %ebx
  800d89:	5e                   	pop    %esi
  800d8a:	5f                   	pop    %edi
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8d:	83 ec 0c             	sub    $0xc,%esp
  800d90:	50                   	push   %eax
  800d91:	6a 0a                	push   $0xa
  800d93:	68 7f 22 80 00       	push   $0x80227f
  800d98:	6a 23                	push   $0x23
  800d9a:	68 9c 22 80 00       	push   $0x80229c
  800d9f:	e8 ab 0e 00 00       	call   801c4f <_panic>

00800da4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800da4:	f3 0f 1e fb          	endbr32 
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	57                   	push   %edi
  800dac:	56                   	push   %esi
  800dad:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dae:	8b 55 08             	mov    0x8(%ebp),%edx
  800db1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800db9:	be 00 00 00 00       	mov    $0x0,%esi
  800dbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dc1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dc4:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dc6:	5b                   	pop    %ebx
  800dc7:	5e                   	pop    %esi
  800dc8:	5f                   	pop    %edi
  800dc9:	5d                   	pop    %ebp
  800dca:	c3                   	ret    

00800dcb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dcb:	f3 0f 1e fb          	endbr32 
  800dcf:	55                   	push   %ebp
  800dd0:	89 e5                	mov    %esp,%ebp
  800dd2:	57                   	push   %edi
  800dd3:	56                   	push   %esi
  800dd4:	53                   	push   %ebx
  800dd5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dd8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ddd:	8b 55 08             	mov    0x8(%ebp),%edx
  800de0:	b8 0d 00 00 00       	mov    $0xd,%eax
  800de5:	89 cb                	mov    %ecx,%ebx
  800de7:	89 cf                	mov    %ecx,%edi
  800de9:	89 ce                	mov    %ecx,%esi
  800deb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ded:	85 c0                	test   %eax,%eax
  800def:	7f 08                	jg     800df9 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800df1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df4:	5b                   	pop    %ebx
  800df5:	5e                   	pop    %esi
  800df6:	5f                   	pop    %edi
  800df7:	5d                   	pop    %ebp
  800df8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800df9:	83 ec 0c             	sub    $0xc,%esp
  800dfc:	50                   	push   %eax
  800dfd:	6a 0d                	push   $0xd
  800dff:	68 7f 22 80 00       	push   $0x80227f
  800e04:	6a 23                	push   $0x23
  800e06:	68 9c 22 80 00       	push   $0x80229c
  800e0b:	e8 3f 0e 00 00       	call   801c4f <_panic>

00800e10 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800e10:	f3 0f 1e fb          	endbr32 
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	56                   	push   %esi
  800e18:	53                   	push   %ebx
  800e19:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e1f:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  800e22:	85 c0                	test   %eax,%eax
  800e24:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  800e29:	0f 44 c2             	cmove  %edx,%eax
  800e2c:	83 ec 0c             	sub    $0xc,%esp
  800e2f:	50                   	push   %eax
  800e30:	e8 96 ff ff ff       	call   800dcb <sys_ipc_recv>
  800e35:	83 c4 10             	add    $0x10,%esp
  800e38:	85 c0                	test   %eax,%eax
  800e3a:	78 24                	js     800e60 <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  800e3c:	85 f6                	test   %esi,%esi
  800e3e:	74 0a                	je     800e4a <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  800e40:	a1 04 40 80 00       	mov    0x804004,%eax
  800e45:	8b 40 78             	mov    0x78(%eax),%eax
  800e48:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  800e4a:	85 db                	test   %ebx,%ebx
  800e4c:	74 0a                	je     800e58 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  800e4e:	a1 04 40 80 00       	mov    0x804004,%eax
  800e53:	8b 40 74             	mov    0x74(%eax),%eax
  800e56:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  800e58:	a1 04 40 80 00       	mov    0x804004,%eax
  800e5d:	8b 40 70             	mov    0x70(%eax),%eax
}
  800e60:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e63:	5b                   	pop    %ebx
  800e64:	5e                   	pop    %esi
  800e65:	5d                   	pop    %ebp
  800e66:	c3                   	ret    

00800e67 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e67:	f3 0f 1e fb          	endbr32 
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	57                   	push   %edi
  800e6f:	56                   	push   %esi
  800e70:	53                   	push   %ebx
  800e71:	83 ec 1c             	sub    $0x1c,%esp
  800e74:	8b 45 10             	mov    0x10(%ebp),%eax
  800e77:	85 c0                	test   %eax,%eax
  800e79:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  800e7e:	0f 45 d0             	cmovne %eax,%edx
  800e81:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  800e83:	be 01 00 00 00       	mov    $0x1,%esi
  800e88:	eb 1f                	jmp    800ea9 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  800e8a:	e8 4d fd ff ff       	call   800bdc <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  800e8f:	83 c3 01             	add    $0x1,%ebx
  800e92:	39 de                	cmp    %ebx,%esi
  800e94:	7f f4                	jg     800e8a <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  800e96:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  800e98:	83 fe 11             	cmp    $0x11,%esi
  800e9b:	b8 01 00 00 00       	mov    $0x1,%eax
  800ea0:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  800ea3:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  800ea7:	75 1c                	jne    800ec5 <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  800ea9:	ff 75 14             	pushl  0x14(%ebp)
  800eac:	57                   	push   %edi
  800ead:	ff 75 0c             	pushl  0xc(%ebp)
  800eb0:	ff 75 08             	pushl  0x8(%ebp)
  800eb3:	e8 ec fe ff ff       	call   800da4 <sys_ipc_try_send>
  800eb8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  800ebb:	83 c4 10             	add    $0x10,%esp
  800ebe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec3:	eb cd                	jmp    800e92 <ipc_send+0x2b>
}
  800ec5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec8:	5b                   	pop    %ebx
  800ec9:	5e                   	pop    %esi
  800eca:	5f                   	pop    %edi
  800ecb:	5d                   	pop    %ebp
  800ecc:	c3                   	ret    

00800ecd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800ecd:	f3 0f 1e fb          	endbr32 
  800ed1:	55                   	push   %ebp
  800ed2:	89 e5                	mov    %esp,%ebp
  800ed4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800ed7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800edc:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800edf:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800ee5:	8b 52 50             	mov    0x50(%edx),%edx
  800ee8:	39 ca                	cmp    %ecx,%edx
  800eea:	74 11                	je     800efd <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  800eec:	83 c0 01             	add    $0x1,%eax
  800eef:	3d 00 04 00 00       	cmp    $0x400,%eax
  800ef4:	75 e6                	jne    800edc <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  800ef6:	b8 00 00 00 00       	mov    $0x0,%eax
  800efb:	eb 0b                	jmp    800f08 <ipc_find_env+0x3b>
			return envs[i].env_id;
  800efd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f00:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f05:	8b 40 48             	mov    0x48(%eax),%eax
}
  800f08:	5d                   	pop    %ebp
  800f09:	c3                   	ret    

00800f0a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f0a:	f3 0f 1e fb          	endbr32 
  800f0e:	55                   	push   %ebp
  800f0f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f11:	8b 45 08             	mov    0x8(%ebp),%eax
  800f14:	05 00 00 00 30       	add    $0x30000000,%eax
  800f19:	c1 e8 0c             	shr    $0xc,%eax
}
  800f1c:	5d                   	pop    %ebp
  800f1d:	c3                   	ret    

00800f1e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f1e:	f3 0f 1e fb          	endbr32 
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f25:	8b 45 08             	mov    0x8(%ebp),%eax
  800f28:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800f2d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f32:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f37:	5d                   	pop    %ebp
  800f38:	c3                   	ret    

00800f39 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f39:	f3 0f 1e fb          	endbr32 
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f45:	89 c2                	mov    %eax,%edx
  800f47:	c1 ea 16             	shr    $0x16,%edx
  800f4a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f51:	f6 c2 01             	test   $0x1,%dl
  800f54:	74 2d                	je     800f83 <fd_alloc+0x4a>
  800f56:	89 c2                	mov    %eax,%edx
  800f58:	c1 ea 0c             	shr    $0xc,%edx
  800f5b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f62:	f6 c2 01             	test   $0x1,%dl
  800f65:	74 1c                	je     800f83 <fd_alloc+0x4a>
  800f67:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800f6c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f71:	75 d2                	jne    800f45 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f73:	8b 45 08             	mov    0x8(%ebp),%eax
  800f76:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800f7c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800f81:	eb 0a                	jmp    800f8d <fd_alloc+0x54>
			*fd_store = fd;
  800f83:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f86:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f88:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f8d:	5d                   	pop    %ebp
  800f8e:	c3                   	ret    

00800f8f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f8f:	f3 0f 1e fb          	endbr32 
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f99:	83 f8 1f             	cmp    $0x1f,%eax
  800f9c:	77 30                	ja     800fce <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f9e:	c1 e0 0c             	shl    $0xc,%eax
  800fa1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fa6:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800fac:	f6 c2 01             	test   $0x1,%dl
  800faf:	74 24                	je     800fd5 <fd_lookup+0x46>
  800fb1:	89 c2                	mov    %eax,%edx
  800fb3:	c1 ea 0c             	shr    $0xc,%edx
  800fb6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fbd:	f6 c2 01             	test   $0x1,%dl
  800fc0:	74 1a                	je     800fdc <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fc2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fc5:	89 02                	mov    %eax,(%edx)
	return 0;
  800fc7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fcc:	5d                   	pop    %ebp
  800fcd:	c3                   	ret    
		return -E_INVAL;
  800fce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fd3:	eb f7                	jmp    800fcc <fd_lookup+0x3d>
		return -E_INVAL;
  800fd5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fda:	eb f0                	jmp    800fcc <fd_lookup+0x3d>
  800fdc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fe1:	eb e9                	jmp    800fcc <fd_lookup+0x3d>

00800fe3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fe3:	f3 0f 1e fb          	endbr32 
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	83 ec 08             	sub    $0x8,%esp
  800fed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ff0:	ba 28 23 80 00       	mov    $0x802328,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ff5:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800ffa:	39 08                	cmp    %ecx,(%eax)
  800ffc:	74 33                	je     801031 <dev_lookup+0x4e>
  800ffe:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801001:	8b 02                	mov    (%edx),%eax
  801003:	85 c0                	test   %eax,%eax
  801005:	75 f3                	jne    800ffa <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801007:	a1 04 40 80 00       	mov    0x804004,%eax
  80100c:	8b 40 48             	mov    0x48(%eax),%eax
  80100f:	83 ec 04             	sub    $0x4,%esp
  801012:	51                   	push   %ecx
  801013:	50                   	push   %eax
  801014:	68 ac 22 80 00       	push   $0x8022ac
  801019:	e8 96 f1 ff ff       	call   8001b4 <cprintf>
	*dev = 0;
  80101e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801021:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801027:	83 c4 10             	add    $0x10,%esp
  80102a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80102f:	c9                   	leave  
  801030:	c3                   	ret    
			*dev = devtab[i];
  801031:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801034:	89 01                	mov    %eax,(%ecx)
			return 0;
  801036:	b8 00 00 00 00       	mov    $0x0,%eax
  80103b:	eb f2                	jmp    80102f <dev_lookup+0x4c>

0080103d <fd_close>:
{
  80103d:	f3 0f 1e fb          	endbr32 
  801041:	55                   	push   %ebp
  801042:	89 e5                	mov    %esp,%ebp
  801044:	57                   	push   %edi
  801045:	56                   	push   %esi
  801046:	53                   	push   %ebx
  801047:	83 ec 24             	sub    $0x24,%esp
  80104a:	8b 75 08             	mov    0x8(%ebp),%esi
  80104d:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801050:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801053:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801054:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80105a:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80105d:	50                   	push   %eax
  80105e:	e8 2c ff ff ff       	call   800f8f <fd_lookup>
  801063:	89 c3                	mov    %eax,%ebx
  801065:	83 c4 10             	add    $0x10,%esp
  801068:	85 c0                	test   %eax,%eax
  80106a:	78 05                	js     801071 <fd_close+0x34>
	    || fd != fd2)
  80106c:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80106f:	74 16                	je     801087 <fd_close+0x4a>
		return (must_exist ? r : 0);
  801071:	89 f8                	mov    %edi,%eax
  801073:	84 c0                	test   %al,%al
  801075:	b8 00 00 00 00       	mov    $0x0,%eax
  80107a:	0f 44 d8             	cmove  %eax,%ebx
}
  80107d:	89 d8                	mov    %ebx,%eax
  80107f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801082:	5b                   	pop    %ebx
  801083:	5e                   	pop    %esi
  801084:	5f                   	pop    %edi
  801085:	5d                   	pop    %ebp
  801086:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801087:	83 ec 08             	sub    $0x8,%esp
  80108a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80108d:	50                   	push   %eax
  80108e:	ff 36                	pushl  (%esi)
  801090:	e8 4e ff ff ff       	call   800fe3 <dev_lookup>
  801095:	89 c3                	mov    %eax,%ebx
  801097:	83 c4 10             	add    $0x10,%esp
  80109a:	85 c0                	test   %eax,%eax
  80109c:	78 1a                	js     8010b8 <fd_close+0x7b>
		if (dev->dev_close)
  80109e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010a1:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8010a4:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8010a9:	85 c0                	test   %eax,%eax
  8010ab:	74 0b                	je     8010b8 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8010ad:	83 ec 0c             	sub    $0xc,%esp
  8010b0:	56                   	push   %esi
  8010b1:	ff d0                	call   *%eax
  8010b3:	89 c3                	mov    %eax,%ebx
  8010b5:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8010b8:	83 ec 08             	sub    $0x8,%esp
  8010bb:	56                   	push   %esi
  8010bc:	6a 00                	push   $0x0
  8010be:	e8 c9 fb ff ff       	call   800c8c <sys_page_unmap>
	return r;
  8010c3:	83 c4 10             	add    $0x10,%esp
  8010c6:	eb b5                	jmp    80107d <fd_close+0x40>

008010c8 <close>:

int
close(int fdnum)
{
  8010c8:	f3 0f 1e fb          	endbr32 
  8010cc:	55                   	push   %ebp
  8010cd:	89 e5                	mov    %esp,%ebp
  8010cf:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010d5:	50                   	push   %eax
  8010d6:	ff 75 08             	pushl  0x8(%ebp)
  8010d9:	e8 b1 fe ff ff       	call   800f8f <fd_lookup>
  8010de:	83 c4 10             	add    $0x10,%esp
  8010e1:	85 c0                	test   %eax,%eax
  8010e3:	79 02                	jns    8010e7 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8010e5:	c9                   	leave  
  8010e6:	c3                   	ret    
		return fd_close(fd, 1);
  8010e7:	83 ec 08             	sub    $0x8,%esp
  8010ea:	6a 01                	push   $0x1
  8010ec:	ff 75 f4             	pushl  -0xc(%ebp)
  8010ef:	e8 49 ff ff ff       	call   80103d <fd_close>
  8010f4:	83 c4 10             	add    $0x10,%esp
  8010f7:	eb ec                	jmp    8010e5 <close+0x1d>

008010f9 <close_all>:

void
close_all(void)
{
  8010f9:	f3 0f 1e fb          	endbr32 
  8010fd:	55                   	push   %ebp
  8010fe:	89 e5                	mov    %esp,%ebp
  801100:	53                   	push   %ebx
  801101:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801104:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801109:	83 ec 0c             	sub    $0xc,%esp
  80110c:	53                   	push   %ebx
  80110d:	e8 b6 ff ff ff       	call   8010c8 <close>
	for (i = 0; i < MAXFD; i++)
  801112:	83 c3 01             	add    $0x1,%ebx
  801115:	83 c4 10             	add    $0x10,%esp
  801118:	83 fb 20             	cmp    $0x20,%ebx
  80111b:	75 ec                	jne    801109 <close_all+0x10>
}
  80111d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801120:	c9                   	leave  
  801121:	c3                   	ret    

00801122 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801122:	f3 0f 1e fb          	endbr32 
  801126:	55                   	push   %ebp
  801127:	89 e5                	mov    %esp,%ebp
  801129:	57                   	push   %edi
  80112a:	56                   	push   %esi
  80112b:	53                   	push   %ebx
  80112c:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80112f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801132:	50                   	push   %eax
  801133:	ff 75 08             	pushl  0x8(%ebp)
  801136:	e8 54 fe ff ff       	call   800f8f <fd_lookup>
  80113b:	89 c3                	mov    %eax,%ebx
  80113d:	83 c4 10             	add    $0x10,%esp
  801140:	85 c0                	test   %eax,%eax
  801142:	0f 88 81 00 00 00    	js     8011c9 <dup+0xa7>
		return r;
	close(newfdnum);
  801148:	83 ec 0c             	sub    $0xc,%esp
  80114b:	ff 75 0c             	pushl  0xc(%ebp)
  80114e:	e8 75 ff ff ff       	call   8010c8 <close>

	newfd = INDEX2FD(newfdnum);
  801153:	8b 75 0c             	mov    0xc(%ebp),%esi
  801156:	c1 e6 0c             	shl    $0xc,%esi
  801159:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80115f:	83 c4 04             	add    $0x4,%esp
  801162:	ff 75 e4             	pushl  -0x1c(%ebp)
  801165:	e8 b4 fd ff ff       	call   800f1e <fd2data>
  80116a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80116c:	89 34 24             	mov    %esi,(%esp)
  80116f:	e8 aa fd ff ff       	call   800f1e <fd2data>
  801174:	83 c4 10             	add    $0x10,%esp
  801177:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801179:	89 d8                	mov    %ebx,%eax
  80117b:	c1 e8 16             	shr    $0x16,%eax
  80117e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801185:	a8 01                	test   $0x1,%al
  801187:	74 11                	je     80119a <dup+0x78>
  801189:	89 d8                	mov    %ebx,%eax
  80118b:	c1 e8 0c             	shr    $0xc,%eax
  80118e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801195:	f6 c2 01             	test   $0x1,%dl
  801198:	75 39                	jne    8011d3 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80119a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80119d:	89 d0                	mov    %edx,%eax
  80119f:	c1 e8 0c             	shr    $0xc,%eax
  8011a2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011a9:	83 ec 0c             	sub    $0xc,%esp
  8011ac:	25 07 0e 00 00       	and    $0xe07,%eax
  8011b1:	50                   	push   %eax
  8011b2:	56                   	push   %esi
  8011b3:	6a 00                	push   $0x0
  8011b5:	52                   	push   %edx
  8011b6:	6a 00                	push   $0x0
  8011b8:	e8 89 fa ff ff       	call   800c46 <sys_page_map>
  8011bd:	89 c3                	mov    %eax,%ebx
  8011bf:	83 c4 20             	add    $0x20,%esp
  8011c2:	85 c0                	test   %eax,%eax
  8011c4:	78 31                	js     8011f7 <dup+0xd5>
		goto err;

	return newfdnum;
  8011c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8011c9:	89 d8                	mov    %ebx,%eax
  8011cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ce:	5b                   	pop    %ebx
  8011cf:	5e                   	pop    %esi
  8011d0:	5f                   	pop    %edi
  8011d1:	5d                   	pop    %ebp
  8011d2:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011d3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011da:	83 ec 0c             	sub    $0xc,%esp
  8011dd:	25 07 0e 00 00       	and    $0xe07,%eax
  8011e2:	50                   	push   %eax
  8011e3:	57                   	push   %edi
  8011e4:	6a 00                	push   $0x0
  8011e6:	53                   	push   %ebx
  8011e7:	6a 00                	push   $0x0
  8011e9:	e8 58 fa ff ff       	call   800c46 <sys_page_map>
  8011ee:	89 c3                	mov    %eax,%ebx
  8011f0:	83 c4 20             	add    $0x20,%esp
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	79 a3                	jns    80119a <dup+0x78>
	sys_page_unmap(0, newfd);
  8011f7:	83 ec 08             	sub    $0x8,%esp
  8011fa:	56                   	push   %esi
  8011fb:	6a 00                	push   $0x0
  8011fd:	e8 8a fa ff ff       	call   800c8c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801202:	83 c4 08             	add    $0x8,%esp
  801205:	57                   	push   %edi
  801206:	6a 00                	push   $0x0
  801208:	e8 7f fa ff ff       	call   800c8c <sys_page_unmap>
	return r;
  80120d:	83 c4 10             	add    $0x10,%esp
  801210:	eb b7                	jmp    8011c9 <dup+0xa7>

00801212 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801212:	f3 0f 1e fb          	endbr32 
  801216:	55                   	push   %ebp
  801217:	89 e5                	mov    %esp,%ebp
  801219:	53                   	push   %ebx
  80121a:	83 ec 1c             	sub    $0x1c,%esp
  80121d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801220:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801223:	50                   	push   %eax
  801224:	53                   	push   %ebx
  801225:	e8 65 fd ff ff       	call   800f8f <fd_lookup>
  80122a:	83 c4 10             	add    $0x10,%esp
  80122d:	85 c0                	test   %eax,%eax
  80122f:	78 3f                	js     801270 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801231:	83 ec 08             	sub    $0x8,%esp
  801234:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801237:	50                   	push   %eax
  801238:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80123b:	ff 30                	pushl  (%eax)
  80123d:	e8 a1 fd ff ff       	call   800fe3 <dev_lookup>
  801242:	83 c4 10             	add    $0x10,%esp
  801245:	85 c0                	test   %eax,%eax
  801247:	78 27                	js     801270 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801249:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80124c:	8b 42 08             	mov    0x8(%edx),%eax
  80124f:	83 e0 03             	and    $0x3,%eax
  801252:	83 f8 01             	cmp    $0x1,%eax
  801255:	74 1e                	je     801275 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801257:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80125a:	8b 40 08             	mov    0x8(%eax),%eax
  80125d:	85 c0                	test   %eax,%eax
  80125f:	74 35                	je     801296 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801261:	83 ec 04             	sub    $0x4,%esp
  801264:	ff 75 10             	pushl  0x10(%ebp)
  801267:	ff 75 0c             	pushl  0xc(%ebp)
  80126a:	52                   	push   %edx
  80126b:	ff d0                	call   *%eax
  80126d:	83 c4 10             	add    $0x10,%esp
}
  801270:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801273:	c9                   	leave  
  801274:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801275:	a1 04 40 80 00       	mov    0x804004,%eax
  80127a:	8b 40 48             	mov    0x48(%eax),%eax
  80127d:	83 ec 04             	sub    $0x4,%esp
  801280:	53                   	push   %ebx
  801281:	50                   	push   %eax
  801282:	68 ed 22 80 00       	push   $0x8022ed
  801287:	e8 28 ef ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  80128c:	83 c4 10             	add    $0x10,%esp
  80128f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801294:	eb da                	jmp    801270 <read+0x5e>
		return -E_NOT_SUPP;
  801296:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80129b:	eb d3                	jmp    801270 <read+0x5e>

0080129d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80129d:	f3 0f 1e fb          	endbr32 
  8012a1:	55                   	push   %ebp
  8012a2:	89 e5                	mov    %esp,%ebp
  8012a4:	57                   	push   %edi
  8012a5:	56                   	push   %esi
  8012a6:	53                   	push   %ebx
  8012a7:	83 ec 0c             	sub    $0xc,%esp
  8012aa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012ad:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012b0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012b5:	eb 02                	jmp    8012b9 <readn+0x1c>
  8012b7:	01 c3                	add    %eax,%ebx
  8012b9:	39 f3                	cmp    %esi,%ebx
  8012bb:	73 21                	jae    8012de <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012bd:	83 ec 04             	sub    $0x4,%esp
  8012c0:	89 f0                	mov    %esi,%eax
  8012c2:	29 d8                	sub    %ebx,%eax
  8012c4:	50                   	push   %eax
  8012c5:	89 d8                	mov    %ebx,%eax
  8012c7:	03 45 0c             	add    0xc(%ebp),%eax
  8012ca:	50                   	push   %eax
  8012cb:	57                   	push   %edi
  8012cc:	e8 41 ff ff ff       	call   801212 <read>
		if (m < 0)
  8012d1:	83 c4 10             	add    $0x10,%esp
  8012d4:	85 c0                	test   %eax,%eax
  8012d6:	78 04                	js     8012dc <readn+0x3f>
			return m;
		if (m == 0)
  8012d8:	75 dd                	jne    8012b7 <readn+0x1a>
  8012da:	eb 02                	jmp    8012de <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012dc:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8012de:	89 d8                	mov    %ebx,%eax
  8012e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012e3:	5b                   	pop    %ebx
  8012e4:	5e                   	pop    %esi
  8012e5:	5f                   	pop    %edi
  8012e6:	5d                   	pop    %ebp
  8012e7:	c3                   	ret    

008012e8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012e8:	f3 0f 1e fb          	endbr32 
  8012ec:	55                   	push   %ebp
  8012ed:	89 e5                	mov    %esp,%ebp
  8012ef:	53                   	push   %ebx
  8012f0:	83 ec 1c             	sub    $0x1c,%esp
  8012f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f9:	50                   	push   %eax
  8012fa:	53                   	push   %ebx
  8012fb:	e8 8f fc ff ff       	call   800f8f <fd_lookup>
  801300:	83 c4 10             	add    $0x10,%esp
  801303:	85 c0                	test   %eax,%eax
  801305:	78 3a                	js     801341 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801307:	83 ec 08             	sub    $0x8,%esp
  80130a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130d:	50                   	push   %eax
  80130e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801311:	ff 30                	pushl  (%eax)
  801313:	e8 cb fc ff ff       	call   800fe3 <dev_lookup>
  801318:	83 c4 10             	add    $0x10,%esp
  80131b:	85 c0                	test   %eax,%eax
  80131d:	78 22                	js     801341 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80131f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801322:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801326:	74 1e                	je     801346 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801328:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80132b:	8b 52 0c             	mov    0xc(%edx),%edx
  80132e:	85 d2                	test   %edx,%edx
  801330:	74 35                	je     801367 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801332:	83 ec 04             	sub    $0x4,%esp
  801335:	ff 75 10             	pushl  0x10(%ebp)
  801338:	ff 75 0c             	pushl  0xc(%ebp)
  80133b:	50                   	push   %eax
  80133c:	ff d2                	call   *%edx
  80133e:	83 c4 10             	add    $0x10,%esp
}
  801341:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801344:	c9                   	leave  
  801345:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801346:	a1 04 40 80 00       	mov    0x804004,%eax
  80134b:	8b 40 48             	mov    0x48(%eax),%eax
  80134e:	83 ec 04             	sub    $0x4,%esp
  801351:	53                   	push   %ebx
  801352:	50                   	push   %eax
  801353:	68 09 23 80 00       	push   $0x802309
  801358:	e8 57 ee ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  80135d:	83 c4 10             	add    $0x10,%esp
  801360:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801365:	eb da                	jmp    801341 <write+0x59>
		return -E_NOT_SUPP;
  801367:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80136c:	eb d3                	jmp    801341 <write+0x59>

0080136e <seek>:

int
seek(int fdnum, off_t offset)
{
  80136e:	f3 0f 1e fb          	endbr32 
  801372:	55                   	push   %ebp
  801373:	89 e5                	mov    %esp,%ebp
  801375:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801378:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137b:	50                   	push   %eax
  80137c:	ff 75 08             	pushl  0x8(%ebp)
  80137f:	e8 0b fc ff ff       	call   800f8f <fd_lookup>
  801384:	83 c4 10             	add    $0x10,%esp
  801387:	85 c0                	test   %eax,%eax
  801389:	78 0e                	js     801399 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80138b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80138e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801391:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801394:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801399:	c9                   	leave  
  80139a:	c3                   	ret    

0080139b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80139b:	f3 0f 1e fb          	endbr32 
  80139f:	55                   	push   %ebp
  8013a0:	89 e5                	mov    %esp,%ebp
  8013a2:	53                   	push   %ebx
  8013a3:	83 ec 1c             	sub    $0x1c,%esp
  8013a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ac:	50                   	push   %eax
  8013ad:	53                   	push   %ebx
  8013ae:	e8 dc fb ff ff       	call   800f8f <fd_lookup>
  8013b3:	83 c4 10             	add    $0x10,%esp
  8013b6:	85 c0                	test   %eax,%eax
  8013b8:	78 37                	js     8013f1 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ba:	83 ec 08             	sub    $0x8,%esp
  8013bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c0:	50                   	push   %eax
  8013c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c4:	ff 30                	pushl  (%eax)
  8013c6:	e8 18 fc ff ff       	call   800fe3 <dev_lookup>
  8013cb:	83 c4 10             	add    $0x10,%esp
  8013ce:	85 c0                	test   %eax,%eax
  8013d0:	78 1f                	js     8013f1 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013d9:	74 1b                	je     8013f6 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8013db:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013de:	8b 52 18             	mov    0x18(%edx),%edx
  8013e1:	85 d2                	test   %edx,%edx
  8013e3:	74 32                	je     801417 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013e5:	83 ec 08             	sub    $0x8,%esp
  8013e8:	ff 75 0c             	pushl  0xc(%ebp)
  8013eb:	50                   	push   %eax
  8013ec:	ff d2                	call   *%edx
  8013ee:	83 c4 10             	add    $0x10,%esp
}
  8013f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f4:	c9                   	leave  
  8013f5:	c3                   	ret    
			thisenv->env_id, fdnum);
  8013f6:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013fb:	8b 40 48             	mov    0x48(%eax),%eax
  8013fe:	83 ec 04             	sub    $0x4,%esp
  801401:	53                   	push   %ebx
  801402:	50                   	push   %eax
  801403:	68 cc 22 80 00       	push   $0x8022cc
  801408:	e8 a7 ed ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  80140d:	83 c4 10             	add    $0x10,%esp
  801410:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801415:	eb da                	jmp    8013f1 <ftruncate+0x56>
		return -E_NOT_SUPP;
  801417:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80141c:	eb d3                	jmp    8013f1 <ftruncate+0x56>

0080141e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80141e:	f3 0f 1e fb          	endbr32 
  801422:	55                   	push   %ebp
  801423:	89 e5                	mov    %esp,%ebp
  801425:	53                   	push   %ebx
  801426:	83 ec 1c             	sub    $0x1c,%esp
  801429:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80142c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80142f:	50                   	push   %eax
  801430:	ff 75 08             	pushl  0x8(%ebp)
  801433:	e8 57 fb ff ff       	call   800f8f <fd_lookup>
  801438:	83 c4 10             	add    $0x10,%esp
  80143b:	85 c0                	test   %eax,%eax
  80143d:	78 4b                	js     80148a <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80143f:	83 ec 08             	sub    $0x8,%esp
  801442:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801445:	50                   	push   %eax
  801446:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801449:	ff 30                	pushl  (%eax)
  80144b:	e8 93 fb ff ff       	call   800fe3 <dev_lookup>
  801450:	83 c4 10             	add    $0x10,%esp
  801453:	85 c0                	test   %eax,%eax
  801455:	78 33                	js     80148a <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801457:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80145a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80145e:	74 2f                	je     80148f <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801460:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801463:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80146a:	00 00 00 
	stat->st_isdir = 0;
  80146d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801474:	00 00 00 
	stat->st_dev = dev;
  801477:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80147d:	83 ec 08             	sub    $0x8,%esp
  801480:	53                   	push   %ebx
  801481:	ff 75 f0             	pushl  -0x10(%ebp)
  801484:	ff 50 14             	call   *0x14(%eax)
  801487:	83 c4 10             	add    $0x10,%esp
}
  80148a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80148d:	c9                   	leave  
  80148e:	c3                   	ret    
		return -E_NOT_SUPP;
  80148f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801494:	eb f4                	jmp    80148a <fstat+0x6c>

00801496 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801496:	f3 0f 1e fb          	endbr32 
  80149a:	55                   	push   %ebp
  80149b:	89 e5                	mov    %esp,%ebp
  80149d:	56                   	push   %esi
  80149e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80149f:	83 ec 08             	sub    $0x8,%esp
  8014a2:	6a 00                	push   $0x0
  8014a4:	ff 75 08             	pushl  0x8(%ebp)
  8014a7:	e8 fb 01 00 00       	call   8016a7 <open>
  8014ac:	89 c3                	mov    %eax,%ebx
  8014ae:	83 c4 10             	add    $0x10,%esp
  8014b1:	85 c0                	test   %eax,%eax
  8014b3:	78 1b                	js     8014d0 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8014b5:	83 ec 08             	sub    $0x8,%esp
  8014b8:	ff 75 0c             	pushl  0xc(%ebp)
  8014bb:	50                   	push   %eax
  8014bc:	e8 5d ff ff ff       	call   80141e <fstat>
  8014c1:	89 c6                	mov    %eax,%esi
	close(fd);
  8014c3:	89 1c 24             	mov    %ebx,(%esp)
  8014c6:	e8 fd fb ff ff       	call   8010c8 <close>
	return r;
  8014cb:	83 c4 10             	add    $0x10,%esp
  8014ce:	89 f3                	mov    %esi,%ebx
}
  8014d0:	89 d8                	mov    %ebx,%eax
  8014d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014d5:	5b                   	pop    %ebx
  8014d6:	5e                   	pop    %esi
  8014d7:	5d                   	pop    %ebp
  8014d8:	c3                   	ret    

008014d9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014d9:	55                   	push   %ebp
  8014da:	89 e5                	mov    %esp,%ebp
  8014dc:	56                   	push   %esi
  8014dd:	53                   	push   %ebx
  8014de:	89 c6                	mov    %eax,%esi
  8014e0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014e2:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014e9:	74 27                	je     801512 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014eb:	6a 07                	push   $0x7
  8014ed:	68 00 50 80 00       	push   $0x805000
  8014f2:	56                   	push   %esi
  8014f3:	ff 35 00 40 80 00    	pushl  0x804000
  8014f9:	e8 69 f9 ff ff       	call   800e67 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014fe:	83 c4 0c             	add    $0xc,%esp
  801501:	6a 00                	push   $0x0
  801503:	53                   	push   %ebx
  801504:	6a 00                	push   $0x0
  801506:	e8 05 f9 ff ff       	call   800e10 <ipc_recv>
}
  80150b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80150e:	5b                   	pop    %ebx
  80150f:	5e                   	pop    %esi
  801510:	5d                   	pop    %ebp
  801511:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801512:	83 ec 0c             	sub    $0xc,%esp
  801515:	6a 01                	push   $0x1
  801517:	e8 b1 f9 ff ff       	call   800ecd <ipc_find_env>
  80151c:	a3 00 40 80 00       	mov    %eax,0x804000
  801521:	83 c4 10             	add    $0x10,%esp
  801524:	eb c5                	jmp    8014eb <fsipc+0x12>

00801526 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801526:	f3 0f 1e fb          	endbr32 
  80152a:	55                   	push   %ebp
  80152b:	89 e5                	mov    %esp,%ebp
  80152d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801530:	8b 45 08             	mov    0x8(%ebp),%eax
  801533:	8b 40 0c             	mov    0xc(%eax),%eax
  801536:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80153b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80153e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801543:	ba 00 00 00 00       	mov    $0x0,%edx
  801548:	b8 02 00 00 00       	mov    $0x2,%eax
  80154d:	e8 87 ff ff ff       	call   8014d9 <fsipc>
}
  801552:	c9                   	leave  
  801553:	c3                   	ret    

00801554 <devfile_flush>:
{
  801554:	f3 0f 1e fb          	endbr32 
  801558:	55                   	push   %ebp
  801559:	89 e5                	mov    %esp,%ebp
  80155b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80155e:	8b 45 08             	mov    0x8(%ebp),%eax
  801561:	8b 40 0c             	mov    0xc(%eax),%eax
  801564:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801569:	ba 00 00 00 00       	mov    $0x0,%edx
  80156e:	b8 06 00 00 00       	mov    $0x6,%eax
  801573:	e8 61 ff ff ff       	call   8014d9 <fsipc>
}
  801578:	c9                   	leave  
  801579:	c3                   	ret    

0080157a <devfile_stat>:
{
  80157a:	f3 0f 1e fb          	endbr32 
  80157e:	55                   	push   %ebp
  80157f:	89 e5                	mov    %esp,%ebp
  801581:	53                   	push   %ebx
  801582:	83 ec 04             	sub    $0x4,%esp
  801585:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801588:	8b 45 08             	mov    0x8(%ebp),%eax
  80158b:	8b 40 0c             	mov    0xc(%eax),%eax
  80158e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801593:	ba 00 00 00 00       	mov    $0x0,%edx
  801598:	b8 05 00 00 00       	mov    $0x5,%eax
  80159d:	e8 37 ff ff ff       	call   8014d9 <fsipc>
  8015a2:	85 c0                	test   %eax,%eax
  8015a4:	78 2c                	js     8015d2 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015a6:	83 ec 08             	sub    $0x8,%esp
  8015a9:	68 00 50 80 00       	push   $0x805000
  8015ae:	53                   	push   %ebx
  8015af:	e8 09 f2 ff ff       	call   8007bd <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015b4:	a1 80 50 80 00       	mov    0x805080,%eax
  8015b9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015bf:	a1 84 50 80 00       	mov    0x805084,%eax
  8015c4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015ca:	83 c4 10             	add    $0x10,%esp
  8015cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d5:	c9                   	leave  
  8015d6:	c3                   	ret    

008015d7 <devfile_write>:
{
  8015d7:	f3 0f 1e fb          	endbr32 
  8015db:	55                   	push   %ebp
  8015dc:	89 e5                	mov    %esp,%ebp
  8015de:	83 ec 0c             	sub    $0xc,%esp
  8015e1:	8b 45 10             	mov    0x10(%ebp),%eax
	n = n > size_max ? size_max : n;
  8015e4:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8015e9:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8015ee:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8015f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8015f4:	8b 52 0c             	mov    0xc(%edx),%edx
  8015f7:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8015fd:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801602:	50                   	push   %eax
  801603:	ff 75 0c             	pushl  0xc(%ebp)
  801606:	68 08 50 80 00       	push   $0x805008
  80160b:	e8 63 f3 ff ff       	call   800973 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801610:	ba 00 00 00 00       	mov    $0x0,%edx
  801615:	b8 04 00 00 00       	mov    $0x4,%eax
  80161a:	e8 ba fe ff ff       	call   8014d9 <fsipc>
}
  80161f:	c9                   	leave  
  801620:	c3                   	ret    

00801621 <devfile_read>:
{
  801621:	f3 0f 1e fb          	endbr32 
  801625:	55                   	push   %ebp
  801626:	89 e5                	mov    %esp,%ebp
  801628:	56                   	push   %esi
  801629:	53                   	push   %ebx
  80162a:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80162d:	8b 45 08             	mov    0x8(%ebp),%eax
  801630:	8b 40 0c             	mov    0xc(%eax),%eax
  801633:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801638:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80163e:	ba 00 00 00 00       	mov    $0x0,%edx
  801643:	b8 03 00 00 00       	mov    $0x3,%eax
  801648:	e8 8c fe ff ff       	call   8014d9 <fsipc>
  80164d:	89 c3                	mov    %eax,%ebx
  80164f:	85 c0                	test   %eax,%eax
  801651:	78 1f                	js     801672 <devfile_read+0x51>
	assert(r <= n);
  801653:	39 f0                	cmp    %esi,%eax
  801655:	77 24                	ja     80167b <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801657:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80165c:	7f 33                	jg     801691 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80165e:	83 ec 04             	sub    $0x4,%esp
  801661:	50                   	push   %eax
  801662:	68 00 50 80 00       	push   $0x805000
  801667:	ff 75 0c             	pushl  0xc(%ebp)
  80166a:	e8 04 f3 ff ff       	call   800973 <memmove>
	return r;
  80166f:	83 c4 10             	add    $0x10,%esp
}
  801672:	89 d8                	mov    %ebx,%eax
  801674:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801677:	5b                   	pop    %ebx
  801678:	5e                   	pop    %esi
  801679:	5d                   	pop    %ebp
  80167a:	c3                   	ret    
	assert(r <= n);
  80167b:	68 38 23 80 00       	push   $0x802338
  801680:	68 3f 23 80 00       	push   $0x80233f
  801685:	6a 7c                	push   $0x7c
  801687:	68 54 23 80 00       	push   $0x802354
  80168c:	e8 be 05 00 00       	call   801c4f <_panic>
	assert(r <= PGSIZE);
  801691:	68 5f 23 80 00       	push   $0x80235f
  801696:	68 3f 23 80 00       	push   $0x80233f
  80169b:	6a 7d                	push   $0x7d
  80169d:	68 54 23 80 00       	push   $0x802354
  8016a2:	e8 a8 05 00 00       	call   801c4f <_panic>

008016a7 <open>:
{
  8016a7:	f3 0f 1e fb          	endbr32 
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	56                   	push   %esi
  8016af:	53                   	push   %ebx
  8016b0:	83 ec 1c             	sub    $0x1c,%esp
  8016b3:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8016b6:	56                   	push   %esi
  8016b7:	e8 be f0 ff ff       	call   80077a <strlen>
  8016bc:	83 c4 10             	add    $0x10,%esp
  8016bf:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016c4:	7f 6c                	jg     801732 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  8016c6:	83 ec 0c             	sub    $0xc,%esp
  8016c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016cc:	50                   	push   %eax
  8016cd:	e8 67 f8 ff ff       	call   800f39 <fd_alloc>
  8016d2:	89 c3                	mov    %eax,%ebx
  8016d4:	83 c4 10             	add    $0x10,%esp
  8016d7:	85 c0                	test   %eax,%eax
  8016d9:	78 3c                	js     801717 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  8016db:	83 ec 08             	sub    $0x8,%esp
  8016de:	56                   	push   %esi
  8016df:	68 00 50 80 00       	push   $0x805000
  8016e4:	e8 d4 f0 ff ff       	call   8007bd <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016ec:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8016f9:	e8 db fd ff ff       	call   8014d9 <fsipc>
  8016fe:	89 c3                	mov    %eax,%ebx
  801700:	83 c4 10             	add    $0x10,%esp
  801703:	85 c0                	test   %eax,%eax
  801705:	78 19                	js     801720 <open+0x79>
	return fd2num(fd);
  801707:	83 ec 0c             	sub    $0xc,%esp
  80170a:	ff 75 f4             	pushl  -0xc(%ebp)
  80170d:	e8 f8 f7 ff ff       	call   800f0a <fd2num>
  801712:	89 c3                	mov    %eax,%ebx
  801714:	83 c4 10             	add    $0x10,%esp
}
  801717:	89 d8                	mov    %ebx,%eax
  801719:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80171c:	5b                   	pop    %ebx
  80171d:	5e                   	pop    %esi
  80171e:	5d                   	pop    %ebp
  80171f:	c3                   	ret    
		fd_close(fd, 0);
  801720:	83 ec 08             	sub    $0x8,%esp
  801723:	6a 00                	push   $0x0
  801725:	ff 75 f4             	pushl  -0xc(%ebp)
  801728:	e8 10 f9 ff ff       	call   80103d <fd_close>
		return r;
  80172d:	83 c4 10             	add    $0x10,%esp
  801730:	eb e5                	jmp    801717 <open+0x70>
		return -E_BAD_PATH;
  801732:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801737:	eb de                	jmp    801717 <open+0x70>

00801739 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801739:	f3 0f 1e fb          	endbr32 
  80173d:	55                   	push   %ebp
  80173e:	89 e5                	mov    %esp,%ebp
  801740:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801743:	ba 00 00 00 00       	mov    $0x0,%edx
  801748:	b8 08 00 00 00       	mov    $0x8,%eax
  80174d:	e8 87 fd ff ff       	call   8014d9 <fsipc>
}
  801752:	c9                   	leave  
  801753:	c3                   	ret    

00801754 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801754:	f3 0f 1e fb          	endbr32 
  801758:	55                   	push   %ebp
  801759:	89 e5                	mov    %esp,%ebp
  80175b:	56                   	push   %esi
  80175c:	53                   	push   %ebx
  80175d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801760:	83 ec 0c             	sub    $0xc,%esp
  801763:	ff 75 08             	pushl  0x8(%ebp)
  801766:	e8 b3 f7 ff ff       	call   800f1e <fd2data>
  80176b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80176d:	83 c4 08             	add    $0x8,%esp
  801770:	68 6b 23 80 00       	push   $0x80236b
  801775:	53                   	push   %ebx
  801776:	e8 42 f0 ff ff       	call   8007bd <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80177b:	8b 46 04             	mov    0x4(%esi),%eax
  80177e:	2b 06                	sub    (%esi),%eax
  801780:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801786:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80178d:	00 00 00 
	stat->st_dev = &devpipe;
  801790:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801797:	30 80 00 
	return 0;
}
  80179a:	b8 00 00 00 00       	mov    $0x0,%eax
  80179f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017a2:	5b                   	pop    %ebx
  8017a3:	5e                   	pop    %esi
  8017a4:	5d                   	pop    %ebp
  8017a5:	c3                   	ret    

008017a6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8017a6:	f3 0f 1e fb          	endbr32 
  8017aa:	55                   	push   %ebp
  8017ab:	89 e5                	mov    %esp,%ebp
  8017ad:	53                   	push   %ebx
  8017ae:	83 ec 0c             	sub    $0xc,%esp
  8017b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8017b4:	53                   	push   %ebx
  8017b5:	6a 00                	push   $0x0
  8017b7:	e8 d0 f4 ff ff       	call   800c8c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8017bc:	89 1c 24             	mov    %ebx,(%esp)
  8017bf:	e8 5a f7 ff ff       	call   800f1e <fd2data>
  8017c4:	83 c4 08             	add    $0x8,%esp
  8017c7:	50                   	push   %eax
  8017c8:	6a 00                	push   $0x0
  8017ca:	e8 bd f4 ff ff       	call   800c8c <sys_page_unmap>
}
  8017cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d2:	c9                   	leave  
  8017d3:	c3                   	ret    

008017d4 <_pipeisclosed>:
{
  8017d4:	55                   	push   %ebp
  8017d5:	89 e5                	mov    %esp,%ebp
  8017d7:	57                   	push   %edi
  8017d8:	56                   	push   %esi
  8017d9:	53                   	push   %ebx
  8017da:	83 ec 1c             	sub    $0x1c,%esp
  8017dd:	89 c7                	mov    %eax,%edi
  8017df:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8017e1:	a1 04 40 80 00       	mov    0x804004,%eax
  8017e6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8017e9:	83 ec 0c             	sub    $0xc,%esp
  8017ec:	57                   	push   %edi
  8017ed:	e8 a7 04 00 00       	call   801c99 <pageref>
  8017f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8017f5:	89 34 24             	mov    %esi,(%esp)
  8017f8:	e8 9c 04 00 00       	call   801c99 <pageref>
		nn = thisenv->env_runs;
  8017fd:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801803:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801806:	83 c4 10             	add    $0x10,%esp
  801809:	39 cb                	cmp    %ecx,%ebx
  80180b:	74 1b                	je     801828 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  80180d:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801810:	75 cf                	jne    8017e1 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801812:	8b 42 58             	mov    0x58(%edx),%eax
  801815:	6a 01                	push   $0x1
  801817:	50                   	push   %eax
  801818:	53                   	push   %ebx
  801819:	68 72 23 80 00       	push   $0x802372
  80181e:	e8 91 e9 ff ff       	call   8001b4 <cprintf>
  801823:	83 c4 10             	add    $0x10,%esp
  801826:	eb b9                	jmp    8017e1 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801828:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80182b:	0f 94 c0             	sete   %al
  80182e:	0f b6 c0             	movzbl %al,%eax
}
  801831:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801834:	5b                   	pop    %ebx
  801835:	5e                   	pop    %esi
  801836:	5f                   	pop    %edi
  801837:	5d                   	pop    %ebp
  801838:	c3                   	ret    

00801839 <devpipe_write>:
{
  801839:	f3 0f 1e fb          	endbr32 
  80183d:	55                   	push   %ebp
  80183e:	89 e5                	mov    %esp,%ebp
  801840:	57                   	push   %edi
  801841:	56                   	push   %esi
  801842:	53                   	push   %ebx
  801843:	83 ec 28             	sub    $0x28,%esp
  801846:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801849:	56                   	push   %esi
  80184a:	e8 cf f6 ff ff       	call   800f1e <fd2data>
  80184f:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801851:	83 c4 10             	add    $0x10,%esp
  801854:	bf 00 00 00 00       	mov    $0x0,%edi
  801859:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80185c:	74 4f                	je     8018ad <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80185e:	8b 43 04             	mov    0x4(%ebx),%eax
  801861:	8b 0b                	mov    (%ebx),%ecx
  801863:	8d 51 20             	lea    0x20(%ecx),%edx
  801866:	39 d0                	cmp    %edx,%eax
  801868:	72 14                	jb     80187e <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  80186a:	89 da                	mov    %ebx,%edx
  80186c:	89 f0                	mov    %esi,%eax
  80186e:	e8 61 ff ff ff       	call   8017d4 <_pipeisclosed>
  801873:	85 c0                	test   %eax,%eax
  801875:	75 3b                	jne    8018b2 <devpipe_write+0x79>
			sys_yield();
  801877:	e8 60 f3 ff ff       	call   800bdc <sys_yield>
  80187c:	eb e0                	jmp    80185e <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80187e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801881:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801885:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801888:	89 c2                	mov    %eax,%edx
  80188a:	c1 fa 1f             	sar    $0x1f,%edx
  80188d:	89 d1                	mov    %edx,%ecx
  80188f:	c1 e9 1b             	shr    $0x1b,%ecx
  801892:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801895:	83 e2 1f             	and    $0x1f,%edx
  801898:	29 ca                	sub    %ecx,%edx
  80189a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80189e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8018a2:	83 c0 01             	add    $0x1,%eax
  8018a5:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8018a8:	83 c7 01             	add    $0x1,%edi
  8018ab:	eb ac                	jmp    801859 <devpipe_write+0x20>
	return i;
  8018ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8018b0:	eb 05                	jmp    8018b7 <devpipe_write+0x7e>
				return 0;
  8018b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018ba:	5b                   	pop    %ebx
  8018bb:	5e                   	pop    %esi
  8018bc:	5f                   	pop    %edi
  8018bd:	5d                   	pop    %ebp
  8018be:	c3                   	ret    

008018bf <devpipe_read>:
{
  8018bf:	f3 0f 1e fb          	endbr32 
  8018c3:	55                   	push   %ebp
  8018c4:	89 e5                	mov    %esp,%ebp
  8018c6:	57                   	push   %edi
  8018c7:	56                   	push   %esi
  8018c8:	53                   	push   %ebx
  8018c9:	83 ec 18             	sub    $0x18,%esp
  8018cc:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8018cf:	57                   	push   %edi
  8018d0:	e8 49 f6 ff ff       	call   800f1e <fd2data>
  8018d5:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8018d7:	83 c4 10             	add    $0x10,%esp
  8018da:	be 00 00 00 00       	mov    $0x0,%esi
  8018df:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018e2:	75 14                	jne    8018f8 <devpipe_read+0x39>
	return i;
  8018e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8018e7:	eb 02                	jmp    8018eb <devpipe_read+0x2c>
				return i;
  8018e9:	89 f0                	mov    %esi,%eax
}
  8018eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018ee:	5b                   	pop    %ebx
  8018ef:	5e                   	pop    %esi
  8018f0:	5f                   	pop    %edi
  8018f1:	5d                   	pop    %ebp
  8018f2:	c3                   	ret    
			sys_yield();
  8018f3:	e8 e4 f2 ff ff       	call   800bdc <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8018f8:	8b 03                	mov    (%ebx),%eax
  8018fa:	3b 43 04             	cmp    0x4(%ebx),%eax
  8018fd:	75 18                	jne    801917 <devpipe_read+0x58>
			if (i > 0)
  8018ff:	85 f6                	test   %esi,%esi
  801901:	75 e6                	jne    8018e9 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801903:	89 da                	mov    %ebx,%edx
  801905:	89 f8                	mov    %edi,%eax
  801907:	e8 c8 fe ff ff       	call   8017d4 <_pipeisclosed>
  80190c:	85 c0                	test   %eax,%eax
  80190e:	74 e3                	je     8018f3 <devpipe_read+0x34>
				return 0;
  801910:	b8 00 00 00 00       	mov    $0x0,%eax
  801915:	eb d4                	jmp    8018eb <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801917:	99                   	cltd   
  801918:	c1 ea 1b             	shr    $0x1b,%edx
  80191b:	01 d0                	add    %edx,%eax
  80191d:	83 e0 1f             	and    $0x1f,%eax
  801920:	29 d0                	sub    %edx,%eax
  801922:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801927:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80192a:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80192d:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801930:	83 c6 01             	add    $0x1,%esi
  801933:	eb aa                	jmp    8018df <devpipe_read+0x20>

00801935 <pipe>:
{
  801935:	f3 0f 1e fb          	endbr32 
  801939:	55                   	push   %ebp
  80193a:	89 e5                	mov    %esp,%ebp
  80193c:	56                   	push   %esi
  80193d:	53                   	push   %ebx
  80193e:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801941:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801944:	50                   	push   %eax
  801945:	e8 ef f5 ff ff       	call   800f39 <fd_alloc>
  80194a:	89 c3                	mov    %eax,%ebx
  80194c:	83 c4 10             	add    $0x10,%esp
  80194f:	85 c0                	test   %eax,%eax
  801951:	0f 88 23 01 00 00    	js     801a7a <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801957:	83 ec 04             	sub    $0x4,%esp
  80195a:	68 07 04 00 00       	push   $0x407
  80195f:	ff 75 f4             	pushl  -0xc(%ebp)
  801962:	6a 00                	push   $0x0
  801964:	e8 96 f2 ff ff       	call   800bff <sys_page_alloc>
  801969:	89 c3                	mov    %eax,%ebx
  80196b:	83 c4 10             	add    $0x10,%esp
  80196e:	85 c0                	test   %eax,%eax
  801970:	0f 88 04 01 00 00    	js     801a7a <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801976:	83 ec 0c             	sub    $0xc,%esp
  801979:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80197c:	50                   	push   %eax
  80197d:	e8 b7 f5 ff ff       	call   800f39 <fd_alloc>
  801982:	89 c3                	mov    %eax,%ebx
  801984:	83 c4 10             	add    $0x10,%esp
  801987:	85 c0                	test   %eax,%eax
  801989:	0f 88 db 00 00 00    	js     801a6a <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80198f:	83 ec 04             	sub    $0x4,%esp
  801992:	68 07 04 00 00       	push   $0x407
  801997:	ff 75 f0             	pushl  -0x10(%ebp)
  80199a:	6a 00                	push   $0x0
  80199c:	e8 5e f2 ff ff       	call   800bff <sys_page_alloc>
  8019a1:	89 c3                	mov    %eax,%ebx
  8019a3:	83 c4 10             	add    $0x10,%esp
  8019a6:	85 c0                	test   %eax,%eax
  8019a8:	0f 88 bc 00 00 00    	js     801a6a <pipe+0x135>
	va = fd2data(fd0);
  8019ae:	83 ec 0c             	sub    $0xc,%esp
  8019b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b4:	e8 65 f5 ff ff       	call   800f1e <fd2data>
  8019b9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019bb:	83 c4 0c             	add    $0xc,%esp
  8019be:	68 07 04 00 00       	push   $0x407
  8019c3:	50                   	push   %eax
  8019c4:	6a 00                	push   $0x0
  8019c6:	e8 34 f2 ff ff       	call   800bff <sys_page_alloc>
  8019cb:	89 c3                	mov    %eax,%ebx
  8019cd:	83 c4 10             	add    $0x10,%esp
  8019d0:	85 c0                	test   %eax,%eax
  8019d2:	0f 88 82 00 00 00    	js     801a5a <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019d8:	83 ec 0c             	sub    $0xc,%esp
  8019db:	ff 75 f0             	pushl  -0x10(%ebp)
  8019de:	e8 3b f5 ff ff       	call   800f1e <fd2data>
  8019e3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8019ea:	50                   	push   %eax
  8019eb:	6a 00                	push   $0x0
  8019ed:	56                   	push   %esi
  8019ee:	6a 00                	push   $0x0
  8019f0:	e8 51 f2 ff ff       	call   800c46 <sys_page_map>
  8019f5:	89 c3                	mov    %eax,%ebx
  8019f7:	83 c4 20             	add    $0x20,%esp
  8019fa:	85 c0                	test   %eax,%eax
  8019fc:	78 4e                	js     801a4c <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  8019fe:	a1 20 30 80 00       	mov    0x803020,%eax
  801a03:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a06:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801a08:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a0b:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801a12:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a15:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801a17:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a1a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801a21:	83 ec 0c             	sub    $0xc,%esp
  801a24:	ff 75 f4             	pushl  -0xc(%ebp)
  801a27:	e8 de f4 ff ff       	call   800f0a <fd2num>
  801a2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a2f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801a31:	83 c4 04             	add    $0x4,%esp
  801a34:	ff 75 f0             	pushl  -0x10(%ebp)
  801a37:	e8 ce f4 ff ff       	call   800f0a <fd2num>
  801a3c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a3f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801a42:	83 c4 10             	add    $0x10,%esp
  801a45:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a4a:	eb 2e                	jmp    801a7a <pipe+0x145>
	sys_page_unmap(0, va);
  801a4c:	83 ec 08             	sub    $0x8,%esp
  801a4f:	56                   	push   %esi
  801a50:	6a 00                	push   $0x0
  801a52:	e8 35 f2 ff ff       	call   800c8c <sys_page_unmap>
  801a57:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801a5a:	83 ec 08             	sub    $0x8,%esp
  801a5d:	ff 75 f0             	pushl  -0x10(%ebp)
  801a60:	6a 00                	push   $0x0
  801a62:	e8 25 f2 ff ff       	call   800c8c <sys_page_unmap>
  801a67:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801a6a:	83 ec 08             	sub    $0x8,%esp
  801a6d:	ff 75 f4             	pushl  -0xc(%ebp)
  801a70:	6a 00                	push   $0x0
  801a72:	e8 15 f2 ff ff       	call   800c8c <sys_page_unmap>
  801a77:	83 c4 10             	add    $0x10,%esp
}
  801a7a:	89 d8                	mov    %ebx,%eax
  801a7c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a7f:	5b                   	pop    %ebx
  801a80:	5e                   	pop    %esi
  801a81:	5d                   	pop    %ebp
  801a82:	c3                   	ret    

00801a83 <pipeisclosed>:
{
  801a83:	f3 0f 1e fb          	endbr32 
  801a87:	55                   	push   %ebp
  801a88:	89 e5                	mov    %esp,%ebp
  801a8a:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a8d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a90:	50                   	push   %eax
  801a91:	ff 75 08             	pushl  0x8(%ebp)
  801a94:	e8 f6 f4 ff ff       	call   800f8f <fd_lookup>
  801a99:	83 c4 10             	add    $0x10,%esp
  801a9c:	85 c0                	test   %eax,%eax
  801a9e:	78 18                	js     801ab8 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801aa0:	83 ec 0c             	sub    $0xc,%esp
  801aa3:	ff 75 f4             	pushl  -0xc(%ebp)
  801aa6:	e8 73 f4 ff ff       	call   800f1e <fd2data>
  801aab:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab0:	e8 1f fd ff ff       	call   8017d4 <_pipeisclosed>
  801ab5:	83 c4 10             	add    $0x10,%esp
}
  801ab8:	c9                   	leave  
  801ab9:	c3                   	ret    

00801aba <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801aba:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801abe:	b8 00 00 00 00       	mov    $0x0,%eax
  801ac3:	c3                   	ret    

00801ac4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ac4:	f3 0f 1e fb          	endbr32 
  801ac8:	55                   	push   %ebp
  801ac9:	89 e5                	mov    %esp,%ebp
  801acb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ace:	68 8a 23 80 00       	push   $0x80238a
  801ad3:	ff 75 0c             	pushl  0xc(%ebp)
  801ad6:	e8 e2 ec ff ff       	call   8007bd <strcpy>
	return 0;
}
  801adb:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae0:	c9                   	leave  
  801ae1:	c3                   	ret    

00801ae2 <devcons_write>:
{
  801ae2:	f3 0f 1e fb          	endbr32 
  801ae6:	55                   	push   %ebp
  801ae7:	89 e5                	mov    %esp,%ebp
  801ae9:	57                   	push   %edi
  801aea:	56                   	push   %esi
  801aeb:	53                   	push   %ebx
  801aec:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801af2:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801af7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801afd:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b00:	73 31                	jae    801b33 <devcons_write+0x51>
		m = n - tot;
  801b02:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b05:	29 f3                	sub    %esi,%ebx
  801b07:	83 fb 7f             	cmp    $0x7f,%ebx
  801b0a:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801b0f:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801b12:	83 ec 04             	sub    $0x4,%esp
  801b15:	53                   	push   %ebx
  801b16:	89 f0                	mov    %esi,%eax
  801b18:	03 45 0c             	add    0xc(%ebp),%eax
  801b1b:	50                   	push   %eax
  801b1c:	57                   	push   %edi
  801b1d:	e8 51 ee ff ff       	call   800973 <memmove>
		sys_cputs(buf, m);
  801b22:	83 c4 08             	add    $0x8,%esp
  801b25:	53                   	push   %ebx
  801b26:	57                   	push   %edi
  801b27:	e8 03 f0 ff ff       	call   800b2f <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801b2c:	01 de                	add    %ebx,%esi
  801b2e:	83 c4 10             	add    $0x10,%esp
  801b31:	eb ca                	jmp    801afd <devcons_write+0x1b>
}
  801b33:	89 f0                	mov    %esi,%eax
  801b35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b38:	5b                   	pop    %ebx
  801b39:	5e                   	pop    %esi
  801b3a:	5f                   	pop    %edi
  801b3b:	5d                   	pop    %ebp
  801b3c:	c3                   	ret    

00801b3d <devcons_read>:
{
  801b3d:	f3 0f 1e fb          	endbr32 
  801b41:	55                   	push   %ebp
  801b42:	89 e5                	mov    %esp,%ebp
  801b44:	83 ec 08             	sub    $0x8,%esp
  801b47:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801b4c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b50:	74 21                	je     801b73 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801b52:	e8 fa ef ff ff       	call   800b51 <sys_cgetc>
  801b57:	85 c0                	test   %eax,%eax
  801b59:	75 07                	jne    801b62 <devcons_read+0x25>
		sys_yield();
  801b5b:	e8 7c f0 ff ff       	call   800bdc <sys_yield>
  801b60:	eb f0                	jmp    801b52 <devcons_read+0x15>
	if (c < 0)
  801b62:	78 0f                	js     801b73 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801b64:	83 f8 04             	cmp    $0x4,%eax
  801b67:	74 0c                	je     801b75 <devcons_read+0x38>
	*(char*)vbuf = c;
  801b69:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b6c:	88 02                	mov    %al,(%edx)
	return 1;
  801b6e:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801b73:	c9                   	leave  
  801b74:	c3                   	ret    
		return 0;
  801b75:	b8 00 00 00 00       	mov    $0x0,%eax
  801b7a:	eb f7                	jmp    801b73 <devcons_read+0x36>

00801b7c <cputchar>:
{
  801b7c:	f3 0f 1e fb          	endbr32 
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b86:	8b 45 08             	mov    0x8(%ebp),%eax
  801b89:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801b8c:	6a 01                	push   $0x1
  801b8e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b91:	50                   	push   %eax
  801b92:	e8 98 ef ff ff       	call   800b2f <sys_cputs>
}
  801b97:	83 c4 10             	add    $0x10,%esp
  801b9a:	c9                   	leave  
  801b9b:	c3                   	ret    

00801b9c <getchar>:
{
  801b9c:	f3 0f 1e fb          	endbr32 
  801ba0:	55                   	push   %ebp
  801ba1:	89 e5                	mov    %esp,%ebp
  801ba3:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801ba6:	6a 01                	push   $0x1
  801ba8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bab:	50                   	push   %eax
  801bac:	6a 00                	push   $0x0
  801bae:	e8 5f f6 ff ff       	call   801212 <read>
	if (r < 0)
  801bb3:	83 c4 10             	add    $0x10,%esp
  801bb6:	85 c0                	test   %eax,%eax
  801bb8:	78 06                	js     801bc0 <getchar+0x24>
	if (r < 1)
  801bba:	74 06                	je     801bc2 <getchar+0x26>
	return c;
  801bbc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801bc0:	c9                   	leave  
  801bc1:	c3                   	ret    
		return -E_EOF;
  801bc2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801bc7:	eb f7                	jmp    801bc0 <getchar+0x24>

00801bc9 <iscons>:
{
  801bc9:	f3 0f 1e fb          	endbr32 
  801bcd:	55                   	push   %ebp
  801bce:	89 e5                	mov    %esp,%ebp
  801bd0:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bd3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bd6:	50                   	push   %eax
  801bd7:	ff 75 08             	pushl  0x8(%ebp)
  801bda:	e8 b0 f3 ff ff       	call   800f8f <fd_lookup>
  801bdf:	83 c4 10             	add    $0x10,%esp
  801be2:	85 c0                	test   %eax,%eax
  801be4:	78 11                	js     801bf7 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801be6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bef:	39 10                	cmp    %edx,(%eax)
  801bf1:	0f 94 c0             	sete   %al
  801bf4:	0f b6 c0             	movzbl %al,%eax
}
  801bf7:	c9                   	leave  
  801bf8:	c3                   	ret    

00801bf9 <opencons>:
{
  801bf9:	f3 0f 1e fb          	endbr32 
  801bfd:	55                   	push   %ebp
  801bfe:	89 e5                	mov    %esp,%ebp
  801c00:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801c03:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c06:	50                   	push   %eax
  801c07:	e8 2d f3 ff ff       	call   800f39 <fd_alloc>
  801c0c:	83 c4 10             	add    $0x10,%esp
  801c0f:	85 c0                	test   %eax,%eax
  801c11:	78 3a                	js     801c4d <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c13:	83 ec 04             	sub    $0x4,%esp
  801c16:	68 07 04 00 00       	push   $0x407
  801c1b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c1e:	6a 00                	push   $0x0
  801c20:	e8 da ef ff ff       	call   800bff <sys_page_alloc>
  801c25:	83 c4 10             	add    $0x10,%esp
  801c28:	85 c0                	test   %eax,%eax
  801c2a:	78 21                	js     801c4d <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c2f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c35:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c3a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c41:	83 ec 0c             	sub    $0xc,%esp
  801c44:	50                   	push   %eax
  801c45:	e8 c0 f2 ff ff       	call   800f0a <fd2num>
  801c4a:	83 c4 10             	add    $0x10,%esp
}
  801c4d:	c9                   	leave  
  801c4e:	c3                   	ret    

00801c4f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801c4f:	f3 0f 1e fb          	endbr32 
  801c53:	55                   	push   %ebp
  801c54:	89 e5                	mov    %esp,%ebp
  801c56:	56                   	push   %esi
  801c57:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801c58:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801c5b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801c61:	e8 53 ef ff ff       	call   800bb9 <sys_getenvid>
  801c66:	83 ec 0c             	sub    $0xc,%esp
  801c69:	ff 75 0c             	pushl  0xc(%ebp)
  801c6c:	ff 75 08             	pushl  0x8(%ebp)
  801c6f:	56                   	push   %esi
  801c70:	50                   	push   %eax
  801c71:	68 98 23 80 00       	push   $0x802398
  801c76:	e8 39 e5 ff ff       	call   8001b4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801c7b:	83 c4 18             	add    $0x18,%esp
  801c7e:	53                   	push   %ebx
  801c7f:	ff 75 10             	pushl  0x10(%ebp)
  801c82:	e8 d8 e4 ff ff       	call   80015f <vcprintf>
	cprintf("\n");
  801c87:	c7 04 24 83 23 80 00 	movl   $0x802383,(%esp)
  801c8e:	e8 21 e5 ff ff       	call   8001b4 <cprintf>
  801c93:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801c96:	cc                   	int3   
  801c97:	eb fd                	jmp    801c96 <_panic+0x47>

00801c99 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c99:	f3 0f 1e fb          	endbr32 
  801c9d:	55                   	push   %ebp
  801c9e:	89 e5                	mov    %esp,%ebp
  801ca0:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ca3:	89 c2                	mov    %eax,%edx
  801ca5:	c1 ea 16             	shr    $0x16,%edx
  801ca8:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801caf:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801cb4:	f6 c1 01             	test   $0x1,%cl
  801cb7:	74 1c                	je     801cd5 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801cb9:	c1 e8 0c             	shr    $0xc,%eax
  801cbc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801cc3:	a8 01                	test   $0x1,%al
  801cc5:	74 0e                	je     801cd5 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801cc7:	c1 e8 0c             	shr    $0xc,%eax
  801cca:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801cd1:	ef 
  801cd2:	0f b7 d2             	movzwl %dx,%edx
}
  801cd5:	89 d0                	mov    %edx,%eax
  801cd7:	5d                   	pop    %ebp
  801cd8:	c3                   	ret    
  801cd9:	66 90                	xchg   %ax,%ax
  801cdb:	66 90                	xchg   %ax,%ax
  801cdd:	66 90                	xchg   %ax,%ax
  801cdf:	90                   	nop

00801ce0 <__udivdi3>:
  801ce0:	f3 0f 1e fb          	endbr32 
  801ce4:	55                   	push   %ebp
  801ce5:	57                   	push   %edi
  801ce6:	56                   	push   %esi
  801ce7:	53                   	push   %ebx
  801ce8:	83 ec 1c             	sub    $0x1c,%esp
  801ceb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801cef:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801cf3:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cf7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801cfb:	85 d2                	test   %edx,%edx
  801cfd:	75 19                	jne    801d18 <__udivdi3+0x38>
  801cff:	39 f3                	cmp    %esi,%ebx
  801d01:	76 4d                	jbe    801d50 <__udivdi3+0x70>
  801d03:	31 ff                	xor    %edi,%edi
  801d05:	89 e8                	mov    %ebp,%eax
  801d07:	89 f2                	mov    %esi,%edx
  801d09:	f7 f3                	div    %ebx
  801d0b:	89 fa                	mov    %edi,%edx
  801d0d:	83 c4 1c             	add    $0x1c,%esp
  801d10:	5b                   	pop    %ebx
  801d11:	5e                   	pop    %esi
  801d12:	5f                   	pop    %edi
  801d13:	5d                   	pop    %ebp
  801d14:	c3                   	ret    
  801d15:	8d 76 00             	lea    0x0(%esi),%esi
  801d18:	39 f2                	cmp    %esi,%edx
  801d1a:	76 14                	jbe    801d30 <__udivdi3+0x50>
  801d1c:	31 ff                	xor    %edi,%edi
  801d1e:	31 c0                	xor    %eax,%eax
  801d20:	89 fa                	mov    %edi,%edx
  801d22:	83 c4 1c             	add    $0x1c,%esp
  801d25:	5b                   	pop    %ebx
  801d26:	5e                   	pop    %esi
  801d27:	5f                   	pop    %edi
  801d28:	5d                   	pop    %ebp
  801d29:	c3                   	ret    
  801d2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d30:	0f bd fa             	bsr    %edx,%edi
  801d33:	83 f7 1f             	xor    $0x1f,%edi
  801d36:	75 48                	jne    801d80 <__udivdi3+0xa0>
  801d38:	39 f2                	cmp    %esi,%edx
  801d3a:	72 06                	jb     801d42 <__udivdi3+0x62>
  801d3c:	31 c0                	xor    %eax,%eax
  801d3e:	39 eb                	cmp    %ebp,%ebx
  801d40:	77 de                	ja     801d20 <__udivdi3+0x40>
  801d42:	b8 01 00 00 00       	mov    $0x1,%eax
  801d47:	eb d7                	jmp    801d20 <__udivdi3+0x40>
  801d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d50:	89 d9                	mov    %ebx,%ecx
  801d52:	85 db                	test   %ebx,%ebx
  801d54:	75 0b                	jne    801d61 <__udivdi3+0x81>
  801d56:	b8 01 00 00 00       	mov    $0x1,%eax
  801d5b:	31 d2                	xor    %edx,%edx
  801d5d:	f7 f3                	div    %ebx
  801d5f:	89 c1                	mov    %eax,%ecx
  801d61:	31 d2                	xor    %edx,%edx
  801d63:	89 f0                	mov    %esi,%eax
  801d65:	f7 f1                	div    %ecx
  801d67:	89 c6                	mov    %eax,%esi
  801d69:	89 e8                	mov    %ebp,%eax
  801d6b:	89 f7                	mov    %esi,%edi
  801d6d:	f7 f1                	div    %ecx
  801d6f:	89 fa                	mov    %edi,%edx
  801d71:	83 c4 1c             	add    $0x1c,%esp
  801d74:	5b                   	pop    %ebx
  801d75:	5e                   	pop    %esi
  801d76:	5f                   	pop    %edi
  801d77:	5d                   	pop    %ebp
  801d78:	c3                   	ret    
  801d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d80:	89 f9                	mov    %edi,%ecx
  801d82:	b8 20 00 00 00       	mov    $0x20,%eax
  801d87:	29 f8                	sub    %edi,%eax
  801d89:	d3 e2                	shl    %cl,%edx
  801d8b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d8f:	89 c1                	mov    %eax,%ecx
  801d91:	89 da                	mov    %ebx,%edx
  801d93:	d3 ea                	shr    %cl,%edx
  801d95:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801d99:	09 d1                	or     %edx,%ecx
  801d9b:	89 f2                	mov    %esi,%edx
  801d9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801da1:	89 f9                	mov    %edi,%ecx
  801da3:	d3 e3                	shl    %cl,%ebx
  801da5:	89 c1                	mov    %eax,%ecx
  801da7:	d3 ea                	shr    %cl,%edx
  801da9:	89 f9                	mov    %edi,%ecx
  801dab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801daf:	89 eb                	mov    %ebp,%ebx
  801db1:	d3 e6                	shl    %cl,%esi
  801db3:	89 c1                	mov    %eax,%ecx
  801db5:	d3 eb                	shr    %cl,%ebx
  801db7:	09 de                	or     %ebx,%esi
  801db9:	89 f0                	mov    %esi,%eax
  801dbb:	f7 74 24 08          	divl   0x8(%esp)
  801dbf:	89 d6                	mov    %edx,%esi
  801dc1:	89 c3                	mov    %eax,%ebx
  801dc3:	f7 64 24 0c          	mull   0xc(%esp)
  801dc7:	39 d6                	cmp    %edx,%esi
  801dc9:	72 15                	jb     801de0 <__udivdi3+0x100>
  801dcb:	89 f9                	mov    %edi,%ecx
  801dcd:	d3 e5                	shl    %cl,%ebp
  801dcf:	39 c5                	cmp    %eax,%ebp
  801dd1:	73 04                	jae    801dd7 <__udivdi3+0xf7>
  801dd3:	39 d6                	cmp    %edx,%esi
  801dd5:	74 09                	je     801de0 <__udivdi3+0x100>
  801dd7:	89 d8                	mov    %ebx,%eax
  801dd9:	31 ff                	xor    %edi,%edi
  801ddb:	e9 40 ff ff ff       	jmp    801d20 <__udivdi3+0x40>
  801de0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801de3:	31 ff                	xor    %edi,%edi
  801de5:	e9 36 ff ff ff       	jmp    801d20 <__udivdi3+0x40>
  801dea:	66 90                	xchg   %ax,%ax
  801dec:	66 90                	xchg   %ax,%ax
  801dee:	66 90                	xchg   %ax,%ax

00801df0 <__umoddi3>:
  801df0:	f3 0f 1e fb          	endbr32 
  801df4:	55                   	push   %ebp
  801df5:	57                   	push   %edi
  801df6:	56                   	push   %esi
  801df7:	53                   	push   %ebx
  801df8:	83 ec 1c             	sub    $0x1c,%esp
  801dfb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801dff:	8b 74 24 30          	mov    0x30(%esp),%esi
  801e03:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801e07:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e0b:	85 c0                	test   %eax,%eax
  801e0d:	75 19                	jne    801e28 <__umoddi3+0x38>
  801e0f:	39 df                	cmp    %ebx,%edi
  801e11:	76 5d                	jbe    801e70 <__umoddi3+0x80>
  801e13:	89 f0                	mov    %esi,%eax
  801e15:	89 da                	mov    %ebx,%edx
  801e17:	f7 f7                	div    %edi
  801e19:	89 d0                	mov    %edx,%eax
  801e1b:	31 d2                	xor    %edx,%edx
  801e1d:	83 c4 1c             	add    $0x1c,%esp
  801e20:	5b                   	pop    %ebx
  801e21:	5e                   	pop    %esi
  801e22:	5f                   	pop    %edi
  801e23:	5d                   	pop    %ebp
  801e24:	c3                   	ret    
  801e25:	8d 76 00             	lea    0x0(%esi),%esi
  801e28:	89 f2                	mov    %esi,%edx
  801e2a:	39 d8                	cmp    %ebx,%eax
  801e2c:	76 12                	jbe    801e40 <__umoddi3+0x50>
  801e2e:	89 f0                	mov    %esi,%eax
  801e30:	89 da                	mov    %ebx,%edx
  801e32:	83 c4 1c             	add    $0x1c,%esp
  801e35:	5b                   	pop    %ebx
  801e36:	5e                   	pop    %esi
  801e37:	5f                   	pop    %edi
  801e38:	5d                   	pop    %ebp
  801e39:	c3                   	ret    
  801e3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e40:	0f bd e8             	bsr    %eax,%ebp
  801e43:	83 f5 1f             	xor    $0x1f,%ebp
  801e46:	75 50                	jne    801e98 <__umoddi3+0xa8>
  801e48:	39 d8                	cmp    %ebx,%eax
  801e4a:	0f 82 e0 00 00 00    	jb     801f30 <__umoddi3+0x140>
  801e50:	89 d9                	mov    %ebx,%ecx
  801e52:	39 f7                	cmp    %esi,%edi
  801e54:	0f 86 d6 00 00 00    	jbe    801f30 <__umoddi3+0x140>
  801e5a:	89 d0                	mov    %edx,%eax
  801e5c:	89 ca                	mov    %ecx,%edx
  801e5e:	83 c4 1c             	add    $0x1c,%esp
  801e61:	5b                   	pop    %ebx
  801e62:	5e                   	pop    %esi
  801e63:	5f                   	pop    %edi
  801e64:	5d                   	pop    %ebp
  801e65:	c3                   	ret    
  801e66:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e6d:	8d 76 00             	lea    0x0(%esi),%esi
  801e70:	89 fd                	mov    %edi,%ebp
  801e72:	85 ff                	test   %edi,%edi
  801e74:	75 0b                	jne    801e81 <__umoddi3+0x91>
  801e76:	b8 01 00 00 00       	mov    $0x1,%eax
  801e7b:	31 d2                	xor    %edx,%edx
  801e7d:	f7 f7                	div    %edi
  801e7f:	89 c5                	mov    %eax,%ebp
  801e81:	89 d8                	mov    %ebx,%eax
  801e83:	31 d2                	xor    %edx,%edx
  801e85:	f7 f5                	div    %ebp
  801e87:	89 f0                	mov    %esi,%eax
  801e89:	f7 f5                	div    %ebp
  801e8b:	89 d0                	mov    %edx,%eax
  801e8d:	31 d2                	xor    %edx,%edx
  801e8f:	eb 8c                	jmp    801e1d <__umoddi3+0x2d>
  801e91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e98:	89 e9                	mov    %ebp,%ecx
  801e9a:	ba 20 00 00 00       	mov    $0x20,%edx
  801e9f:	29 ea                	sub    %ebp,%edx
  801ea1:	d3 e0                	shl    %cl,%eax
  801ea3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ea7:	89 d1                	mov    %edx,%ecx
  801ea9:	89 f8                	mov    %edi,%eax
  801eab:	d3 e8                	shr    %cl,%eax
  801ead:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801eb1:	89 54 24 04          	mov    %edx,0x4(%esp)
  801eb5:	8b 54 24 04          	mov    0x4(%esp),%edx
  801eb9:	09 c1                	or     %eax,%ecx
  801ebb:	89 d8                	mov    %ebx,%eax
  801ebd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ec1:	89 e9                	mov    %ebp,%ecx
  801ec3:	d3 e7                	shl    %cl,%edi
  801ec5:	89 d1                	mov    %edx,%ecx
  801ec7:	d3 e8                	shr    %cl,%eax
  801ec9:	89 e9                	mov    %ebp,%ecx
  801ecb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ecf:	d3 e3                	shl    %cl,%ebx
  801ed1:	89 c7                	mov    %eax,%edi
  801ed3:	89 d1                	mov    %edx,%ecx
  801ed5:	89 f0                	mov    %esi,%eax
  801ed7:	d3 e8                	shr    %cl,%eax
  801ed9:	89 e9                	mov    %ebp,%ecx
  801edb:	89 fa                	mov    %edi,%edx
  801edd:	d3 e6                	shl    %cl,%esi
  801edf:	09 d8                	or     %ebx,%eax
  801ee1:	f7 74 24 08          	divl   0x8(%esp)
  801ee5:	89 d1                	mov    %edx,%ecx
  801ee7:	89 f3                	mov    %esi,%ebx
  801ee9:	f7 64 24 0c          	mull   0xc(%esp)
  801eed:	89 c6                	mov    %eax,%esi
  801eef:	89 d7                	mov    %edx,%edi
  801ef1:	39 d1                	cmp    %edx,%ecx
  801ef3:	72 06                	jb     801efb <__umoddi3+0x10b>
  801ef5:	75 10                	jne    801f07 <__umoddi3+0x117>
  801ef7:	39 c3                	cmp    %eax,%ebx
  801ef9:	73 0c                	jae    801f07 <__umoddi3+0x117>
  801efb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801eff:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801f03:	89 d7                	mov    %edx,%edi
  801f05:	89 c6                	mov    %eax,%esi
  801f07:	89 ca                	mov    %ecx,%edx
  801f09:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801f0e:	29 f3                	sub    %esi,%ebx
  801f10:	19 fa                	sbb    %edi,%edx
  801f12:	89 d0                	mov    %edx,%eax
  801f14:	d3 e0                	shl    %cl,%eax
  801f16:	89 e9                	mov    %ebp,%ecx
  801f18:	d3 eb                	shr    %cl,%ebx
  801f1a:	d3 ea                	shr    %cl,%edx
  801f1c:	09 d8                	or     %ebx,%eax
  801f1e:	83 c4 1c             	add    $0x1c,%esp
  801f21:	5b                   	pop    %ebx
  801f22:	5e                   	pop    %esi
  801f23:	5f                   	pop    %edi
  801f24:	5d                   	pop    %ebp
  801f25:	c3                   	ret    
  801f26:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f2d:	8d 76 00             	lea    0x0(%esi),%esi
  801f30:	29 fe                	sub    %edi,%esi
  801f32:	19 c3                	sbb    %eax,%ebx
  801f34:	89 f2                	mov    %esi,%edx
  801f36:	89 d9                	mov    %ebx,%ecx
  801f38:	e9 1d ff ff ff       	jmp    801e5a <__umoddi3+0x6a>
