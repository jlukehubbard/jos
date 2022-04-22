
obj/user/yield:     file format elf32-i386


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
  80002c:	e8 6d 00 00 00       	call   80009e <libmain>
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
  80003b:	83 ec 0c             	sub    $0xc,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003e:	a1 04 40 80 00       	mov    0x804004,%eax
  800043:	8b 40 48             	mov    0x48(%eax),%eax
  800046:	50                   	push   %eax
  800047:	68 40 1f 80 00       	push   $0x801f40
  80004c:	e8 5c 01 00 00       	call   8001ad <cprintf>
  800051:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800054:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800059:	e8 77 0b 00 00       	call   800bd5 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005e:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("Back in environment %08x, iteration %d.\n",
  800063:	8b 40 48             	mov    0x48(%eax),%eax
  800066:	83 ec 04             	sub    $0x4,%esp
  800069:	53                   	push   %ebx
  80006a:	50                   	push   %eax
  80006b:	68 60 1f 80 00       	push   $0x801f60
  800070:	e8 38 01 00 00       	call   8001ad <cprintf>
	for (i = 0; i < 5; i++) {
  800075:	83 c3 01             	add    $0x1,%ebx
  800078:	83 c4 10             	add    $0x10,%esp
  80007b:	83 fb 05             	cmp    $0x5,%ebx
  80007e:	75 d9                	jne    800059 <umain+0x26>
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  800080:	a1 04 40 80 00       	mov    0x804004,%eax
  800085:	8b 40 48             	mov    0x48(%eax),%eax
  800088:	83 ec 08             	sub    $0x8,%esp
  80008b:	50                   	push   %eax
  80008c:	68 8c 1f 80 00       	push   $0x801f8c
  800091:	e8 17 01 00 00       	call   8001ad <cprintf>
}
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    

0080009e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009e:	f3 0f 1e fb          	endbr32 
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	56                   	push   %esi
  8000a6:	53                   	push   %ebx
  8000a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000aa:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000ad:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  8000b4:	00 00 00 
    envid_t envid = sys_getenvid();
  8000b7:	e8 f6 0a 00 00       	call   800bb2 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  8000bc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000c1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000c4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c9:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ce:	85 db                	test   %ebx,%ebx
  8000d0:	7e 07                	jle    8000d9 <libmain+0x3b>
		binaryname = argv[0];
  8000d2:	8b 06                	mov    (%esi),%eax
  8000d4:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000d9:	83 ec 08             	sub    $0x8,%esp
  8000dc:	56                   	push   %esi
  8000dd:	53                   	push   %ebx
  8000de:	e8 50 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000e3:	e8 0a 00 00 00       	call   8000f2 <exit>
}
  8000e8:	83 c4 10             	add    $0x10,%esp
  8000eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ee:	5b                   	pop    %ebx
  8000ef:	5e                   	pop    %esi
  8000f0:	5d                   	pop    %ebp
  8000f1:	c3                   	ret    

008000f2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f2:	f3 0f 1e fb          	endbr32 
  8000f6:	55                   	push   %ebp
  8000f7:	89 e5                	mov    %esp,%ebp
  8000f9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000fc:	e8 f7 0e 00 00       	call   800ff8 <close_all>
	sys_env_destroy(0);
  800101:	83 ec 0c             	sub    $0xc,%esp
  800104:	6a 00                	push   $0x0
  800106:	e8 62 0a 00 00       	call   800b6d <sys_env_destroy>
}
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	c9                   	leave  
  80010f:	c3                   	ret    

00800110 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800110:	f3 0f 1e fb          	endbr32 
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	53                   	push   %ebx
  800118:	83 ec 04             	sub    $0x4,%esp
  80011b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80011e:	8b 13                	mov    (%ebx),%edx
  800120:	8d 42 01             	lea    0x1(%edx),%eax
  800123:	89 03                	mov    %eax,(%ebx)
  800125:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800128:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80012c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800131:	74 09                	je     80013c <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800133:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800137:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80013c:	83 ec 08             	sub    $0x8,%esp
  80013f:	68 ff 00 00 00       	push   $0xff
  800144:	8d 43 08             	lea    0x8(%ebx),%eax
  800147:	50                   	push   %eax
  800148:	e8 db 09 00 00       	call   800b28 <sys_cputs>
		b->idx = 0;
  80014d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800153:	83 c4 10             	add    $0x10,%esp
  800156:	eb db                	jmp    800133 <putch+0x23>

00800158 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800158:	f3 0f 1e fb          	endbr32 
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800165:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80016c:	00 00 00 
	b.cnt = 0;
  80016f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800176:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800179:	ff 75 0c             	pushl  0xc(%ebp)
  80017c:	ff 75 08             	pushl  0x8(%ebp)
  80017f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800185:	50                   	push   %eax
  800186:	68 10 01 80 00       	push   $0x800110
  80018b:	e8 20 01 00 00       	call   8002b0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800190:	83 c4 08             	add    $0x8,%esp
  800193:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800199:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019f:	50                   	push   %eax
  8001a0:	e8 83 09 00 00       	call   800b28 <sys_cputs>

	return b.cnt;
}
  8001a5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ab:	c9                   	leave  
  8001ac:	c3                   	ret    

008001ad <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ad:	f3 0f 1e fb          	endbr32 
  8001b1:	55                   	push   %ebp
  8001b2:	89 e5                	mov    %esp,%ebp
  8001b4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ba:	50                   	push   %eax
  8001bb:	ff 75 08             	pushl  0x8(%ebp)
  8001be:	e8 95 ff ff ff       	call   800158 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    

008001c5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	57                   	push   %edi
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	83 ec 1c             	sub    $0x1c,%esp
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	89 d6                	mov    %edx,%esi
  8001d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d8:	89 d1                	mov    %edx,%ecx
  8001da:	89 c2                	mov    %eax,%edx
  8001dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001df:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001eb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001f2:	39 c2                	cmp    %eax,%edx
  8001f4:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001f7:	72 3e                	jb     800237 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f9:	83 ec 0c             	sub    $0xc,%esp
  8001fc:	ff 75 18             	pushl  0x18(%ebp)
  8001ff:	83 eb 01             	sub    $0x1,%ebx
  800202:	53                   	push   %ebx
  800203:	50                   	push   %eax
  800204:	83 ec 08             	sub    $0x8,%esp
  800207:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020a:	ff 75 e0             	pushl  -0x20(%ebp)
  80020d:	ff 75 dc             	pushl  -0x24(%ebp)
  800210:	ff 75 d8             	pushl  -0x28(%ebp)
  800213:	e8 c8 1a 00 00       	call   801ce0 <__udivdi3>
  800218:	83 c4 18             	add    $0x18,%esp
  80021b:	52                   	push   %edx
  80021c:	50                   	push   %eax
  80021d:	89 f2                	mov    %esi,%edx
  80021f:	89 f8                	mov    %edi,%eax
  800221:	e8 9f ff ff ff       	call   8001c5 <printnum>
  800226:	83 c4 20             	add    $0x20,%esp
  800229:	eb 13                	jmp    80023e <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022b:	83 ec 08             	sub    $0x8,%esp
  80022e:	56                   	push   %esi
  80022f:	ff 75 18             	pushl  0x18(%ebp)
  800232:	ff d7                	call   *%edi
  800234:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800237:	83 eb 01             	sub    $0x1,%ebx
  80023a:	85 db                	test   %ebx,%ebx
  80023c:	7f ed                	jg     80022b <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023e:	83 ec 08             	sub    $0x8,%esp
  800241:	56                   	push   %esi
  800242:	83 ec 04             	sub    $0x4,%esp
  800245:	ff 75 e4             	pushl  -0x1c(%ebp)
  800248:	ff 75 e0             	pushl  -0x20(%ebp)
  80024b:	ff 75 dc             	pushl  -0x24(%ebp)
  80024e:	ff 75 d8             	pushl  -0x28(%ebp)
  800251:	e8 9a 1b 00 00       	call   801df0 <__umoddi3>
  800256:	83 c4 14             	add    $0x14,%esp
  800259:	0f be 80 b5 1f 80 00 	movsbl 0x801fb5(%eax),%eax
  800260:	50                   	push   %eax
  800261:	ff d7                	call   *%edi
}
  800263:	83 c4 10             	add    $0x10,%esp
  800266:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800269:	5b                   	pop    %ebx
  80026a:	5e                   	pop    %esi
  80026b:	5f                   	pop    %edi
  80026c:	5d                   	pop    %ebp
  80026d:	c3                   	ret    

0080026e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80026e:	f3 0f 1e fb          	endbr32 
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
  800275:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800278:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80027c:	8b 10                	mov    (%eax),%edx
  80027e:	3b 50 04             	cmp    0x4(%eax),%edx
  800281:	73 0a                	jae    80028d <sprintputch+0x1f>
		*b->buf++ = ch;
  800283:	8d 4a 01             	lea    0x1(%edx),%ecx
  800286:	89 08                	mov    %ecx,(%eax)
  800288:	8b 45 08             	mov    0x8(%ebp),%eax
  80028b:	88 02                	mov    %al,(%edx)
}
  80028d:	5d                   	pop    %ebp
  80028e:	c3                   	ret    

0080028f <printfmt>:
{
  80028f:	f3 0f 1e fb          	endbr32 
  800293:	55                   	push   %ebp
  800294:	89 e5                	mov    %esp,%ebp
  800296:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800299:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80029c:	50                   	push   %eax
  80029d:	ff 75 10             	pushl  0x10(%ebp)
  8002a0:	ff 75 0c             	pushl  0xc(%ebp)
  8002a3:	ff 75 08             	pushl  0x8(%ebp)
  8002a6:	e8 05 00 00 00       	call   8002b0 <vprintfmt>
}
  8002ab:	83 c4 10             	add    $0x10,%esp
  8002ae:	c9                   	leave  
  8002af:	c3                   	ret    

008002b0 <vprintfmt>:
{
  8002b0:	f3 0f 1e fb          	endbr32 
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	57                   	push   %edi
  8002b8:	56                   	push   %esi
  8002b9:	53                   	push   %ebx
  8002ba:	83 ec 3c             	sub    $0x3c,%esp
  8002bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8002c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002c3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002c6:	e9 4a 03 00 00       	jmp    800615 <vprintfmt+0x365>
		padc = ' ';
  8002cb:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002cf:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002d6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002dd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002e4:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002e9:	8d 47 01             	lea    0x1(%edi),%eax
  8002ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ef:	0f b6 17             	movzbl (%edi),%edx
  8002f2:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002f5:	3c 55                	cmp    $0x55,%al
  8002f7:	0f 87 de 03 00 00    	ja     8006db <vprintfmt+0x42b>
  8002fd:	0f b6 c0             	movzbl %al,%eax
  800300:	3e ff 24 85 00 21 80 	notrack jmp *0x802100(,%eax,4)
  800307:	00 
  800308:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80030b:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80030f:	eb d8                	jmp    8002e9 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800311:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800314:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800318:	eb cf                	jmp    8002e9 <vprintfmt+0x39>
  80031a:	0f b6 d2             	movzbl %dl,%edx
  80031d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800320:	b8 00 00 00 00       	mov    $0x0,%eax
  800325:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800328:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80032b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80032f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800332:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800335:	83 f9 09             	cmp    $0x9,%ecx
  800338:	77 55                	ja     80038f <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80033a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80033d:	eb e9                	jmp    800328 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80033f:	8b 45 14             	mov    0x14(%ebp),%eax
  800342:	8b 00                	mov    (%eax),%eax
  800344:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800347:	8b 45 14             	mov    0x14(%ebp),%eax
  80034a:	8d 40 04             	lea    0x4(%eax),%eax
  80034d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800350:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800353:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800357:	79 90                	jns    8002e9 <vprintfmt+0x39>
				width = precision, precision = -1;
  800359:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80035c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80035f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800366:	eb 81                	jmp    8002e9 <vprintfmt+0x39>
  800368:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80036b:	85 c0                	test   %eax,%eax
  80036d:	ba 00 00 00 00       	mov    $0x0,%edx
  800372:	0f 49 d0             	cmovns %eax,%edx
  800375:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800378:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80037b:	e9 69 ff ff ff       	jmp    8002e9 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800380:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800383:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80038a:	e9 5a ff ff ff       	jmp    8002e9 <vprintfmt+0x39>
  80038f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800392:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800395:	eb bc                	jmp    800353 <vprintfmt+0xa3>
			lflag++;
  800397:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80039d:	e9 47 ff ff ff       	jmp    8002e9 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a5:	8d 78 04             	lea    0x4(%eax),%edi
  8003a8:	83 ec 08             	sub    $0x8,%esp
  8003ab:	53                   	push   %ebx
  8003ac:	ff 30                	pushl  (%eax)
  8003ae:	ff d6                	call   *%esi
			break;
  8003b0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003b3:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003b6:	e9 57 02 00 00       	jmp    800612 <vprintfmt+0x362>
			err = va_arg(ap, int);
  8003bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003be:	8d 78 04             	lea    0x4(%eax),%edi
  8003c1:	8b 00                	mov    (%eax),%eax
  8003c3:	99                   	cltd   
  8003c4:	31 d0                	xor    %edx,%eax
  8003c6:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c8:	83 f8 0f             	cmp    $0xf,%eax
  8003cb:	7f 23                	jg     8003f0 <vprintfmt+0x140>
  8003cd:	8b 14 85 60 22 80 00 	mov    0x802260(,%eax,4),%edx
  8003d4:	85 d2                	test   %edx,%edx
  8003d6:	74 18                	je     8003f0 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8003d8:	52                   	push   %edx
  8003d9:	68 91 23 80 00       	push   $0x802391
  8003de:	53                   	push   %ebx
  8003df:	56                   	push   %esi
  8003e0:	e8 aa fe ff ff       	call   80028f <printfmt>
  8003e5:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003e8:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003eb:	e9 22 02 00 00       	jmp    800612 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8003f0:	50                   	push   %eax
  8003f1:	68 cd 1f 80 00       	push   $0x801fcd
  8003f6:	53                   	push   %ebx
  8003f7:	56                   	push   %esi
  8003f8:	e8 92 fe ff ff       	call   80028f <printfmt>
  8003fd:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800400:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800403:	e9 0a 02 00 00       	jmp    800612 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  800408:	8b 45 14             	mov    0x14(%ebp),%eax
  80040b:	83 c0 04             	add    $0x4,%eax
  80040e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800411:	8b 45 14             	mov    0x14(%ebp),%eax
  800414:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800416:	85 d2                	test   %edx,%edx
  800418:	b8 c6 1f 80 00       	mov    $0x801fc6,%eax
  80041d:	0f 45 c2             	cmovne %edx,%eax
  800420:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800423:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800427:	7e 06                	jle    80042f <vprintfmt+0x17f>
  800429:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80042d:	75 0d                	jne    80043c <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80042f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800432:	89 c7                	mov    %eax,%edi
  800434:	03 45 e0             	add    -0x20(%ebp),%eax
  800437:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043a:	eb 55                	jmp    800491 <vprintfmt+0x1e1>
  80043c:	83 ec 08             	sub    $0x8,%esp
  80043f:	ff 75 d8             	pushl  -0x28(%ebp)
  800442:	ff 75 cc             	pushl  -0x34(%ebp)
  800445:	e8 45 03 00 00       	call   80078f <strnlen>
  80044a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80044d:	29 c2                	sub    %eax,%edx
  80044f:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800452:	83 c4 10             	add    $0x10,%esp
  800455:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800457:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80045b:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80045e:	85 ff                	test   %edi,%edi
  800460:	7e 11                	jle    800473 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800462:	83 ec 08             	sub    $0x8,%esp
  800465:	53                   	push   %ebx
  800466:	ff 75 e0             	pushl  -0x20(%ebp)
  800469:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80046b:	83 ef 01             	sub    $0x1,%edi
  80046e:	83 c4 10             	add    $0x10,%esp
  800471:	eb eb                	jmp    80045e <vprintfmt+0x1ae>
  800473:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800476:	85 d2                	test   %edx,%edx
  800478:	b8 00 00 00 00       	mov    $0x0,%eax
  80047d:	0f 49 c2             	cmovns %edx,%eax
  800480:	29 c2                	sub    %eax,%edx
  800482:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800485:	eb a8                	jmp    80042f <vprintfmt+0x17f>
					putch(ch, putdat);
  800487:	83 ec 08             	sub    $0x8,%esp
  80048a:	53                   	push   %ebx
  80048b:	52                   	push   %edx
  80048c:	ff d6                	call   *%esi
  80048e:	83 c4 10             	add    $0x10,%esp
  800491:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800494:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800496:	83 c7 01             	add    $0x1,%edi
  800499:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80049d:	0f be d0             	movsbl %al,%edx
  8004a0:	85 d2                	test   %edx,%edx
  8004a2:	74 4b                	je     8004ef <vprintfmt+0x23f>
  8004a4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004a8:	78 06                	js     8004b0 <vprintfmt+0x200>
  8004aa:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004ae:	78 1e                	js     8004ce <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004b0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004b4:	74 d1                	je     800487 <vprintfmt+0x1d7>
  8004b6:	0f be c0             	movsbl %al,%eax
  8004b9:	83 e8 20             	sub    $0x20,%eax
  8004bc:	83 f8 5e             	cmp    $0x5e,%eax
  8004bf:	76 c6                	jbe    800487 <vprintfmt+0x1d7>
					putch('?', putdat);
  8004c1:	83 ec 08             	sub    $0x8,%esp
  8004c4:	53                   	push   %ebx
  8004c5:	6a 3f                	push   $0x3f
  8004c7:	ff d6                	call   *%esi
  8004c9:	83 c4 10             	add    $0x10,%esp
  8004cc:	eb c3                	jmp    800491 <vprintfmt+0x1e1>
  8004ce:	89 cf                	mov    %ecx,%edi
  8004d0:	eb 0e                	jmp    8004e0 <vprintfmt+0x230>
				putch(' ', putdat);
  8004d2:	83 ec 08             	sub    $0x8,%esp
  8004d5:	53                   	push   %ebx
  8004d6:	6a 20                	push   $0x20
  8004d8:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004da:	83 ef 01             	sub    $0x1,%edi
  8004dd:	83 c4 10             	add    $0x10,%esp
  8004e0:	85 ff                	test   %edi,%edi
  8004e2:	7f ee                	jg     8004d2 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8004e4:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004e7:	89 45 14             	mov    %eax,0x14(%ebp)
  8004ea:	e9 23 01 00 00       	jmp    800612 <vprintfmt+0x362>
  8004ef:	89 cf                	mov    %ecx,%edi
  8004f1:	eb ed                	jmp    8004e0 <vprintfmt+0x230>
	if (lflag >= 2)
  8004f3:	83 f9 01             	cmp    $0x1,%ecx
  8004f6:	7f 1b                	jg     800513 <vprintfmt+0x263>
	else if (lflag)
  8004f8:	85 c9                	test   %ecx,%ecx
  8004fa:	74 63                	je     80055f <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8004fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ff:	8b 00                	mov    (%eax),%eax
  800501:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800504:	99                   	cltd   
  800505:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800508:	8b 45 14             	mov    0x14(%ebp),%eax
  80050b:	8d 40 04             	lea    0x4(%eax),%eax
  80050e:	89 45 14             	mov    %eax,0x14(%ebp)
  800511:	eb 17                	jmp    80052a <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800513:	8b 45 14             	mov    0x14(%ebp),%eax
  800516:	8b 50 04             	mov    0x4(%eax),%edx
  800519:	8b 00                	mov    (%eax),%eax
  80051b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800521:	8b 45 14             	mov    0x14(%ebp),%eax
  800524:	8d 40 08             	lea    0x8(%eax),%eax
  800527:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80052a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80052d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800530:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800535:	85 c9                	test   %ecx,%ecx
  800537:	0f 89 bb 00 00 00    	jns    8005f8 <vprintfmt+0x348>
				putch('-', putdat);
  80053d:	83 ec 08             	sub    $0x8,%esp
  800540:	53                   	push   %ebx
  800541:	6a 2d                	push   $0x2d
  800543:	ff d6                	call   *%esi
				num = -(long long) num;
  800545:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800548:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80054b:	f7 da                	neg    %edx
  80054d:	83 d1 00             	adc    $0x0,%ecx
  800550:	f7 d9                	neg    %ecx
  800552:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800555:	b8 0a 00 00 00       	mov    $0xa,%eax
  80055a:	e9 99 00 00 00       	jmp    8005f8 <vprintfmt+0x348>
		return va_arg(*ap, int);
  80055f:	8b 45 14             	mov    0x14(%ebp),%eax
  800562:	8b 00                	mov    (%eax),%eax
  800564:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800567:	99                   	cltd   
  800568:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80056b:	8b 45 14             	mov    0x14(%ebp),%eax
  80056e:	8d 40 04             	lea    0x4(%eax),%eax
  800571:	89 45 14             	mov    %eax,0x14(%ebp)
  800574:	eb b4                	jmp    80052a <vprintfmt+0x27a>
	if (lflag >= 2)
  800576:	83 f9 01             	cmp    $0x1,%ecx
  800579:	7f 1b                	jg     800596 <vprintfmt+0x2e6>
	else if (lflag)
  80057b:	85 c9                	test   %ecx,%ecx
  80057d:	74 2c                	je     8005ab <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  80057f:	8b 45 14             	mov    0x14(%ebp),%eax
  800582:	8b 10                	mov    (%eax),%edx
  800584:	b9 00 00 00 00       	mov    $0x0,%ecx
  800589:	8d 40 04             	lea    0x4(%eax),%eax
  80058c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80058f:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800594:	eb 62                	jmp    8005f8 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800596:	8b 45 14             	mov    0x14(%ebp),%eax
  800599:	8b 10                	mov    (%eax),%edx
  80059b:	8b 48 04             	mov    0x4(%eax),%ecx
  80059e:	8d 40 08             	lea    0x8(%eax),%eax
  8005a1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005a4:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005a9:	eb 4d                	jmp    8005f8 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8005ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ae:	8b 10                	mov    (%eax),%edx
  8005b0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b5:	8d 40 04             	lea    0x4(%eax),%eax
  8005b8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005bb:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8005c0:	eb 36                	jmp    8005f8 <vprintfmt+0x348>
	if (lflag >= 2)
  8005c2:	83 f9 01             	cmp    $0x1,%ecx
  8005c5:	7f 17                	jg     8005de <vprintfmt+0x32e>
	else if (lflag)
  8005c7:	85 c9                	test   %ecx,%ecx
  8005c9:	74 6e                	je     800639 <vprintfmt+0x389>
		return va_arg(*ap, long);
  8005cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ce:	8b 10                	mov    (%eax),%edx
  8005d0:	89 d0                	mov    %edx,%eax
  8005d2:	99                   	cltd   
  8005d3:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005d6:	8d 49 04             	lea    0x4(%ecx),%ecx
  8005d9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005dc:	eb 11                	jmp    8005ef <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8005de:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e1:	8b 50 04             	mov    0x4(%eax),%edx
  8005e4:	8b 00                	mov    (%eax),%eax
  8005e6:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005e9:	8d 49 08             	lea    0x8(%ecx),%ecx
  8005ec:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8005ef:	89 d1                	mov    %edx,%ecx
  8005f1:	89 c2                	mov    %eax,%edx
            base = 8;
  8005f3:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005f8:	83 ec 0c             	sub    $0xc,%esp
  8005fb:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005ff:	57                   	push   %edi
  800600:	ff 75 e0             	pushl  -0x20(%ebp)
  800603:	50                   	push   %eax
  800604:	51                   	push   %ecx
  800605:	52                   	push   %edx
  800606:	89 da                	mov    %ebx,%edx
  800608:	89 f0                	mov    %esi,%eax
  80060a:	e8 b6 fb ff ff       	call   8001c5 <printnum>
			break;
  80060f:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800612:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800615:	83 c7 01             	add    $0x1,%edi
  800618:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80061c:	83 f8 25             	cmp    $0x25,%eax
  80061f:	0f 84 a6 fc ff ff    	je     8002cb <vprintfmt+0x1b>
			if (ch == '\0')
  800625:	85 c0                	test   %eax,%eax
  800627:	0f 84 ce 00 00 00    	je     8006fb <vprintfmt+0x44b>
			putch(ch, putdat);
  80062d:	83 ec 08             	sub    $0x8,%esp
  800630:	53                   	push   %ebx
  800631:	50                   	push   %eax
  800632:	ff d6                	call   *%esi
  800634:	83 c4 10             	add    $0x10,%esp
  800637:	eb dc                	jmp    800615 <vprintfmt+0x365>
		return va_arg(*ap, int);
  800639:	8b 45 14             	mov    0x14(%ebp),%eax
  80063c:	8b 10                	mov    (%eax),%edx
  80063e:	89 d0                	mov    %edx,%eax
  800640:	99                   	cltd   
  800641:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800644:	8d 49 04             	lea    0x4(%ecx),%ecx
  800647:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80064a:	eb a3                	jmp    8005ef <vprintfmt+0x33f>
			putch('0', putdat);
  80064c:	83 ec 08             	sub    $0x8,%esp
  80064f:	53                   	push   %ebx
  800650:	6a 30                	push   $0x30
  800652:	ff d6                	call   *%esi
			putch('x', putdat);
  800654:	83 c4 08             	add    $0x8,%esp
  800657:	53                   	push   %ebx
  800658:	6a 78                	push   $0x78
  80065a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80065c:	8b 45 14             	mov    0x14(%ebp),%eax
  80065f:	8b 10                	mov    (%eax),%edx
  800661:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800666:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800669:	8d 40 04             	lea    0x4(%eax),%eax
  80066c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80066f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800674:	eb 82                	jmp    8005f8 <vprintfmt+0x348>
	if (lflag >= 2)
  800676:	83 f9 01             	cmp    $0x1,%ecx
  800679:	7f 1e                	jg     800699 <vprintfmt+0x3e9>
	else if (lflag)
  80067b:	85 c9                	test   %ecx,%ecx
  80067d:	74 32                	je     8006b1 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  80067f:	8b 45 14             	mov    0x14(%ebp),%eax
  800682:	8b 10                	mov    (%eax),%edx
  800684:	b9 00 00 00 00       	mov    $0x0,%ecx
  800689:	8d 40 04             	lea    0x4(%eax),%eax
  80068c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80068f:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800694:	e9 5f ff ff ff       	jmp    8005f8 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800699:	8b 45 14             	mov    0x14(%ebp),%eax
  80069c:	8b 10                	mov    (%eax),%edx
  80069e:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a1:	8d 40 08             	lea    0x8(%eax),%eax
  8006a4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a7:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006ac:	e9 47 ff ff ff       	jmp    8005f8 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8006b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b4:	8b 10                	mov    (%eax),%edx
  8006b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006bb:	8d 40 04             	lea    0x4(%eax),%eax
  8006be:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c1:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006c6:	e9 2d ff ff ff       	jmp    8005f8 <vprintfmt+0x348>
			putch(ch, putdat);
  8006cb:	83 ec 08             	sub    $0x8,%esp
  8006ce:	53                   	push   %ebx
  8006cf:	6a 25                	push   $0x25
  8006d1:	ff d6                	call   *%esi
			break;
  8006d3:	83 c4 10             	add    $0x10,%esp
  8006d6:	e9 37 ff ff ff       	jmp    800612 <vprintfmt+0x362>
			putch('%', putdat);
  8006db:	83 ec 08             	sub    $0x8,%esp
  8006de:	53                   	push   %ebx
  8006df:	6a 25                	push   $0x25
  8006e1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e3:	83 c4 10             	add    $0x10,%esp
  8006e6:	89 f8                	mov    %edi,%eax
  8006e8:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006ec:	74 05                	je     8006f3 <vprintfmt+0x443>
  8006ee:	83 e8 01             	sub    $0x1,%eax
  8006f1:	eb f5                	jmp    8006e8 <vprintfmt+0x438>
  8006f3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006f6:	e9 17 ff ff ff       	jmp    800612 <vprintfmt+0x362>
}
  8006fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006fe:	5b                   	pop    %ebx
  8006ff:	5e                   	pop    %esi
  800700:	5f                   	pop    %edi
  800701:	5d                   	pop    %ebp
  800702:	c3                   	ret    

00800703 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800703:	f3 0f 1e fb          	endbr32 
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	83 ec 18             	sub    $0x18,%esp
  80070d:	8b 45 08             	mov    0x8(%ebp),%eax
  800710:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800713:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800716:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80071a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80071d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800724:	85 c0                	test   %eax,%eax
  800726:	74 26                	je     80074e <vsnprintf+0x4b>
  800728:	85 d2                	test   %edx,%edx
  80072a:	7e 22                	jle    80074e <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80072c:	ff 75 14             	pushl  0x14(%ebp)
  80072f:	ff 75 10             	pushl  0x10(%ebp)
  800732:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800735:	50                   	push   %eax
  800736:	68 6e 02 80 00       	push   $0x80026e
  80073b:	e8 70 fb ff ff       	call   8002b0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800740:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800743:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800746:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800749:	83 c4 10             	add    $0x10,%esp
}
  80074c:	c9                   	leave  
  80074d:	c3                   	ret    
		return -E_INVAL;
  80074e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800753:	eb f7                	jmp    80074c <vsnprintf+0x49>

00800755 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800755:	f3 0f 1e fb          	endbr32 
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800762:	50                   	push   %eax
  800763:	ff 75 10             	pushl  0x10(%ebp)
  800766:	ff 75 0c             	pushl  0xc(%ebp)
  800769:	ff 75 08             	pushl  0x8(%ebp)
  80076c:	e8 92 ff ff ff       	call   800703 <vsnprintf>
	va_end(ap);

	return rc;
}
  800771:	c9                   	leave  
  800772:	c3                   	ret    

00800773 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800773:	f3 0f 1e fb          	endbr32 
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80077d:	b8 00 00 00 00       	mov    $0x0,%eax
  800782:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800786:	74 05                	je     80078d <strlen+0x1a>
		n++;
  800788:	83 c0 01             	add    $0x1,%eax
  80078b:	eb f5                	jmp    800782 <strlen+0xf>
	return n;
}
  80078d:	5d                   	pop    %ebp
  80078e:	c3                   	ret    

0080078f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80078f:	f3 0f 1e fb          	endbr32 
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800799:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079c:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a1:	39 d0                	cmp    %edx,%eax
  8007a3:	74 0d                	je     8007b2 <strnlen+0x23>
  8007a5:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007a9:	74 05                	je     8007b0 <strnlen+0x21>
		n++;
  8007ab:	83 c0 01             	add    $0x1,%eax
  8007ae:	eb f1                	jmp    8007a1 <strnlen+0x12>
  8007b0:	89 c2                	mov    %eax,%edx
	return n;
}
  8007b2:	89 d0                	mov    %edx,%eax
  8007b4:	5d                   	pop    %ebp
  8007b5:	c3                   	ret    

008007b6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b6:	f3 0f 1e fb          	endbr32 
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	53                   	push   %ebx
  8007be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c9:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007cd:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007d0:	83 c0 01             	add    $0x1,%eax
  8007d3:	84 d2                	test   %dl,%dl
  8007d5:	75 f2                	jne    8007c9 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8007d7:	89 c8                	mov    %ecx,%eax
  8007d9:	5b                   	pop    %ebx
  8007da:	5d                   	pop    %ebp
  8007db:	c3                   	ret    

008007dc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007dc:	f3 0f 1e fb          	endbr32 
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	53                   	push   %ebx
  8007e4:	83 ec 10             	sub    $0x10,%esp
  8007e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ea:	53                   	push   %ebx
  8007eb:	e8 83 ff ff ff       	call   800773 <strlen>
  8007f0:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007f3:	ff 75 0c             	pushl  0xc(%ebp)
  8007f6:	01 d8                	add    %ebx,%eax
  8007f8:	50                   	push   %eax
  8007f9:	e8 b8 ff ff ff       	call   8007b6 <strcpy>
	return dst;
}
  8007fe:	89 d8                	mov    %ebx,%eax
  800800:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800803:	c9                   	leave  
  800804:	c3                   	ret    

00800805 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800805:	f3 0f 1e fb          	endbr32 
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	56                   	push   %esi
  80080d:	53                   	push   %ebx
  80080e:	8b 75 08             	mov    0x8(%ebp),%esi
  800811:	8b 55 0c             	mov    0xc(%ebp),%edx
  800814:	89 f3                	mov    %esi,%ebx
  800816:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800819:	89 f0                	mov    %esi,%eax
  80081b:	39 d8                	cmp    %ebx,%eax
  80081d:	74 11                	je     800830 <strncpy+0x2b>
		*dst++ = *src;
  80081f:	83 c0 01             	add    $0x1,%eax
  800822:	0f b6 0a             	movzbl (%edx),%ecx
  800825:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800828:	80 f9 01             	cmp    $0x1,%cl
  80082b:	83 da ff             	sbb    $0xffffffff,%edx
  80082e:	eb eb                	jmp    80081b <strncpy+0x16>
	}
	return ret;
}
  800830:	89 f0                	mov    %esi,%eax
  800832:	5b                   	pop    %ebx
  800833:	5e                   	pop    %esi
  800834:	5d                   	pop    %ebp
  800835:	c3                   	ret    

00800836 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800836:	f3 0f 1e fb          	endbr32 
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	56                   	push   %esi
  80083e:	53                   	push   %ebx
  80083f:	8b 75 08             	mov    0x8(%ebp),%esi
  800842:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800845:	8b 55 10             	mov    0x10(%ebp),%edx
  800848:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80084a:	85 d2                	test   %edx,%edx
  80084c:	74 21                	je     80086f <strlcpy+0x39>
  80084e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800852:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800854:	39 c2                	cmp    %eax,%edx
  800856:	74 14                	je     80086c <strlcpy+0x36>
  800858:	0f b6 19             	movzbl (%ecx),%ebx
  80085b:	84 db                	test   %bl,%bl
  80085d:	74 0b                	je     80086a <strlcpy+0x34>
			*dst++ = *src++;
  80085f:	83 c1 01             	add    $0x1,%ecx
  800862:	83 c2 01             	add    $0x1,%edx
  800865:	88 5a ff             	mov    %bl,-0x1(%edx)
  800868:	eb ea                	jmp    800854 <strlcpy+0x1e>
  80086a:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80086c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80086f:	29 f0                	sub    %esi,%eax
}
  800871:	5b                   	pop    %ebx
  800872:	5e                   	pop    %esi
  800873:	5d                   	pop    %ebp
  800874:	c3                   	ret    

00800875 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800875:	f3 0f 1e fb          	endbr32 
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800882:	0f b6 01             	movzbl (%ecx),%eax
  800885:	84 c0                	test   %al,%al
  800887:	74 0c                	je     800895 <strcmp+0x20>
  800889:	3a 02                	cmp    (%edx),%al
  80088b:	75 08                	jne    800895 <strcmp+0x20>
		p++, q++;
  80088d:	83 c1 01             	add    $0x1,%ecx
  800890:	83 c2 01             	add    $0x1,%edx
  800893:	eb ed                	jmp    800882 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800895:	0f b6 c0             	movzbl %al,%eax
  800898:	0f b6 12             	movzbl (%edx),%edx
  80089b:	29 d0                	sub    %edx,%eax
}
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80089f:	f3 0f 1e fb          	endbr32 
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	53                   	push   %ebx
  8008a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ad:	89 c3                	mov    %eax,%ebx
  8008af:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b2:	eb 06                	jmp    8008ba <strncmp+0x1b>
		n--, p++, q++;
  8008b4:	83 c0 01             	add    $0x1,%eax
  8008b7:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008ba:	39 d8                	cmp    %ebx,%eax
  8008bc:	74 16                	je     8008d4 <strncmp+0x35>
  8008be:	0f b6 08             	movzbl (%eax),%ecx
  8008c1:	84 c9                	test   %cl,%cl
  8008c3:	74 04                	je     8008c9 <strncmp+0x2a>
  8008c5:	3a 0a                	cmp    (%edx),%cl
  8008c7:	74 eb                	je     8008b4 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c9:	0f b6 00             	movzbl (%eax),%eax
  8008cc:	0f b6 12             	movzbl (%edx),%edx
  8008cf:	29 d0                	sub    %edx,%eax
}
  8008d1:	5b                   	pop    %ebx
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    
		return 0;
  8008d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d9:	eb f6                	jmp    8008d1 <strncmp+0x32>

008008db <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008db:	f3 0f 1e fb          	endbr32 
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e9:	0f b6 10             	movzbl (%eax),%edx
  8008ec:	84 d2                	test   %dl,%dl
  8008ee:	74 09                	je     8008f9 <strchr+0x1e>
		if (*s == c)
  8008f0:	38 ca                	cmp    %cl,%dl
  8008f2:	74 0a                	je     8008fe <strchr+0x23>
	for (; *s; s++)
  8008f4:	83 c0 01             	add    $0x1,%eax
  8008f7:	eb f0                	jmp    8008e9 <strchr+0xe>
			return (char *) s;
	return 0;
  8008f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008fe:	5d                   	pop    %ebp
  8008ff:	c3                   	ret    

00800900 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800900:	f3 0f 1e fb          	endbr32 
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	8b 45 08             	mov    0x8(%ebp),%eax
  80090a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80090e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800911:	38 ca                	cmp    %cl,%dl
  800913:	74 09                	je     80091e <strfind+0x1e>
  800915:	84 d2                	test   %dl,%dl
  800917:	74 05                	je     80091e <strfind+0x1e>
	for (; *s; s++)
  800919:	83 c0 01             	add    $0x1,%eax
  80091c:	eb f0                	jmp    80090e <strfind+0xe>
			break;
	return (char *) s;
}
  80091e:	5d                   	pop    %ebp
  80091f:	c3                   	ret    

00800920 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800920:	f3 0f 1e fb          	endbr32 
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	57                   	push   %edi
  800928:	56                   	push   %esi
  800929:	53                   	push   %ebx
  80092a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800930:	85 c9                	test   %ecx,%ecx
  800932:	74 31                	je     800965 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800934:	89 f8                	mov    %edi,%eax
  800936:	09 c8                	or     %ecx,%eax
  800938:	a8 03                	test   $0x3,%al
  80093a:	75 23                	jne    80095f <memset+0x3f>
		c &= 0xFF;
  80093c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800940:	89 d3                	mov    %edx,%ebx
  800942:	c1 e3 08             	shl    $0x8,%ebx
  800945:	89 d0                	mov    %edx,%eax
  800947:	c1 e0 18             	shl    $0x18,%eax
  80094a:	89 d6                	mov    %edx,%esi
  80094c:	c1 e6 10             	shl    $0x10,%esi
  80094f:	09 f0                	or     %esi,%eax
  800951:	09 c2                	or     %eax,%edx
  800953:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800955:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800958:	89 d0                	mov    %edx,%eax
  80095a:	fc                   	cld    
  80095b:	f3 ab                	rep stos %eax,%es:(%edi)
  80095d:	eb 06                	jmp    800965 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80095f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800962:	fc                   	cld    
  800963:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800965:	89 f8                	mov    %edi,%eax
  800967:	5b                   	pop    %ebx
  800968:	5e                   	pop    %esi
  800969:	5f                   	pop    %edi
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80096c:	f3 0f 1e fb          	endbr32 
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	57                   	push   %edi
  800974:	56                   	push   %esi
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	8b 75 0c             	mov    0xc(%ebp),%esi
  80097b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80097e:	39 c6                	cmp    %eax,%esi
  800980:	73 32                	jae    8009b4 <memmove+0x48>
  800982:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800985:	39 c2                	cmp    %eax,%edx
  800987:	76 2b                	jbe    8009b4 <memmove+0x48>
		s += n;
		d += n;
  800989:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098c:	89 fe                	mov    %edi,%esi
  80098e:	09 ce                	or     %ecx,%esi
  800990:	09 d6                	or     %edx,%esi
  800992:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800998:	75 0e                	jne    8009a8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80099a:	83 ef 04             	sub    $0x4,%edi
  80099d:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009a3:	fd                   	std    
  8009a4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a6:	eb 09                	jmp    8009b1 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009a8:	83 ef 01             	sub    $0x1,%edi
  8009ab:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009ae:	fd                   	std    
  8009af:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b1:	fc                   	cld    
  8009b2:	eb 1a                	jmp    8009ce <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b4:	89 c2                	mov    %eax,%edx
  8009b6:	09 ca                	or     %ecx,%edx
  8009b8:	09 f2                	or     %esi,%edx
  8009ba:	f6 c2 03             	test   $0x3,%dl
  8009bd:	75 0a                	jne    8009c9 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009bf:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009c2:	89 c7                	mov    %eax,%edi
  8009c4:	fc                   	cld    
  8009c5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c7:	eb 05                	jmp    8009ce <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8009c9:	89 c7                	mov    %eax,%edi
  8009cb:	fc                   	cld    
  8009cc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ce:	5e                   	pop    %esi
  8009cf:	5f                   	pop    %edi
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    

008009d2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d2:	f3 0f 1e fb          	endbr32 
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009dc:	ff 75 10             	pushl  0x10(%ebp)
  8009df:	ff 75 0c             	pushl  0xc(%ebp)
  8009e2:	ff 75 08             	pushl  0x8(%ebp)
  8009e5:	e8 82 ff ff ff       	call   80096c <memmove>
}
  8009ea:	c9                   	leave  
  8009eb:	c3                   	ret    

008009ec <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ec:	f3 0f 1e fb          	endbr32 
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	56                   	push   %esi
  8009f4:	53                   	push   %ebx
  8009f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009fb:	89 c6                	mov    %eax,%esi
  8009fd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a00:	39 f0                	cmp    %esi,%eax
  800a02:	74 1c                	je     800a20 <memcmp+0x34>
		if (*s1 != *s2)
  800a04:	0f b6 08             	movzbl (%eax),%ecx
  800a07:	0f b6 1a             	movzbl (%edx),%ebx
  800a0a:	38 d9                	cmp    %bl,%cl
  800a0c:	75 08                	jne    800a16 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a0e:	83 c0 01             	add    $0x1,%eax
  800a11:	83 c2 01             	add    $0x1,%edx
  800a14:	eb ea                	jmp    800a00 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a16:	0f b6 c1             	movzbl %cl,%eax
  800a19:	0f b6 db             	movzbl %bl,%ebx
  800a1c:	29 d8                	sub    %ebx,%eax
  800a1e:	eb 05                	jmp    800a25 <memcmp+0x39>
	}

	return 0;
  800a20:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a25:	5b                   	pop    %ebx
  800a26:	5e                   	pop    %esi
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a29:	f3 0f 1e fb          	endbr32 
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	8b 45 08             	mov    0x8(%ebp),%eax
  800a33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a36:	89 c2                	mov    %eax,%edx
  800a38:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a3b:	39 d0                	cmp    %edx,%eax
  800a3d:	73 09                	jae    800a48 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a3f:	38 08                	cmp    %cl,(%eax)
  800a41:	74 05                	je     800a48 <memfind+0x1f>
	for (; s < ends; s++)
  800a43:	83 c0 01             	add    $0x1,%eax
  800a46:	eb f3                	jmp    800a3b <memfind+0x12>
			break;
	return (void *) s;
}
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a4a:	f3 0f 1e fb          	endbr32 
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	57                   	push   %edi
  800a52:	56                   	push   %esi
  800a53:	53                   	push   %ebx
  800a54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5a:	eb 03                	jmp    800a5f <strtol+0x15>
		s++;
  800a5c:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a5f:	0f b6 01             	movzbl (%ecx),%eax
  800a62:	3c 20                	cmp    $0x20,%al
  800a64:	74 f6                	je     800a5c <strtol+0x12>
  800a66:	3c 09                	cmp    $0x9,%al
  800a68:	74 f2                	je     800a5c <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a6a:	3c 2b                	cmp    $0x2b,%al
  800a6c:	74 2a                	je     800a98 <strtol+0x4e>
	int neg = 0;
  800a6e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a73:	3c 2d                	cmp    $0x2d,%al
  800a75:	74 2b                	je     800aa2 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a77:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a7d:	75 0f                	jne    800a8e <strtol+0x44>
  800a7f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a82:	74 28                	je     800aac <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a84:	85 db                	test   %ebx,%ebx
  800a86:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a8b:	0f 44 d8             	cmove  %eax,%ebx
  800a8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a93:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a96:	eb 46                	jmp    800ade <strtol+0x94>
		s++;
  800a98:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a9b:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa0:	eb d5                	jmp    800a77 <strtol+0x2d>
		s++, neg = 1;
  800aa2:	83 c1 01             	add    $0x1,%ecx
  800aa5:	bf 01 00 00 00       	mov    $0x1,%edi
  800aaa:	eb cb                	jmp    800a77 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aac:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ab0:	74 0e                	je     800ac0 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ab2:	85 db                	test   %ebx,%ebx
  800ab4:	75 d8                	jne    800a8e <strtol+0x44>
		s++, base = 8;
  800ab6:	83 c1 01             	add    $0x1,%ecx
  800ab9:	bb 08 00 00 00       	mov    $0x8,%ebx
  800abe:	eb ce                	jmp    800a8e <strtol+0x44>
		s += 2, base = 16;
  800ac0:	83 c1 02             	add    $0x2,%ecx
  800ac3:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac8:	eb c4                	jmp    800a8e <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800aca:	0f be d2             	movsbl %dl,%edx
  800acd:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ad0:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ad3:	7d 3a                	jge    800b0f <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ad5:	83 c1 01             	add    $0x1,%ecx
  800ad8:	0f af 45 10          	imul   0x10(%ebp),%eax
  800adc:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ade:	0f b6 11             	movzbl (%ecx),%edx
  800ae1:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ae4:	89 f3                	mov    %esi,%ebx
  800ae6:	80 fb 09             	cmp    $0x9,%bl
  800ae9:	76 df                	jbe    800aca <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800aeb:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aee:	89 f3                	mov    %esi,%ebx
  800af0:	80 fb 19             	cmp    $0x19,%bl
  800af3:	77 08                	ja     800afd <strtol+0xb3>
			dig = *s - 'a' + 10;
  800af5:	0f be d2             	movsbl %dl,%edx
  800af8:	83 ea 57             	sub    $0x57,%edx
  800afb:	eb d3                	jmp    800ad0 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800afd:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b00:	89 f3                	mov    %esi,%ebx
  800b02:	80 fb 19             	cmp    $0x19,%bl
  800b05:	77 08                	ja     800b0f <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b07:	0f be d2             	movsbl %dl,%edx
  800b0a:	83 ea 37             	sub    $0x37,%edx
  800b0d:	eb c1                	jmp    800ad0 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b0f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b13:	74 05                	je     800b1a <strtol+0xd0>
		*endptr = (char *) s;
  800b15:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b18:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b1a:	89 c2                	mov    %eax,%edx
  800b1c:	f7 da                	neg    %edx
  800b1e:	85 ff                	test   %edi,%edi
  800b20:	0f 45 c2             	cmovne %edx,%eax
}
  800b23:	5b                   	pop    %ebx
  800b24:	5e                   	pop    %esi
  800b25:	5f                   	pop    %edi
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    

00800b28 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b28:	f3 0f 1e fb          	endbr32 
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	57                   	push   %edi
  800b30:	56                   	push   %esi
  800b31:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b32:	b8 00 00 00 00       	mov    $0x0,%eax
  800b37:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3d:	89 c3                	mov    %eax,%ebx
  800b3f:	89 c7                	mov    %eax,%edi
  800b41:	89 c6                	mov    %eax,%esi
  800b43:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b45:	5b                   	pop    %ebx
  800b46:	5e                   	pop    %esi
  800b47:	5f                   	pop    %edi
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    

00800b4a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b4a:	f3 0f 1e fb          	endbr32 
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	57                   	push   %edi
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b54:	ba 00 00 00 00       	mov    $0x0,%edx
  800b59:	b8 01 00 00 00       	mov    $0x1,%eax
  800b5e:	89 d1                	mov    %edx,%ecx
  800b60:	89 d3                	mov    %edx,%ebx
  800b62:	89 d7                	mov    %edx,%edi
  800b64:	89 d6                	mov    %edx,%esi
  800b66:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b68:	5b                   	pop    %ebx
  800b69:	5e                   	pop    %esi
  800b6a:	5f                   	pop    %edi
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    

00800b6d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b6d:	f3 0f 1e fb          	endbr32 
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	57                   	push   %edi
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
  800b77:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b7a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b82:	b8 03 00 00 00       	mov    $0x3,%eax
  800b87:	89 cb                	mov    %ecx,%ebx
  800b89:	89 cf                	mov    %ecx,%edi
  800b8b:	89 ce                	mov    %ecx,%esi
  800b8d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b8f:	85 c0                	test   %eax,%eax
  800b91:	7f 08                	jg     800b9b <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9b:	83 ec 0c             	sub    $0xc,%esp
  800b9e:	50                   	push   %eax
  800b9f:	6a 03                	push   $0x3
  800ba1:	68 bf 22 80 00       	push   $0x8022bf
  800ba6:	6a 23                	push   $0x23
  800ba8:	68 dc 22 80 00       	push   $0x8022dc
  800bad:	e8 9c 0f 00 00       	call   801b4e <_panic>

00800bb2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bb2:	f3 0f 1e fb          	endbr32 
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	57                   	push   %edi
  800bba:	56                   	push   %esi
  800bbb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bbc:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc1:	b8 02 00 00 00       	mov    $0x2,%eax
  800bc6:	89 d1                	mov    %edx,%ecx
  800bc8:	89 d3                	mov    %edx,%ebx
  800bca:	89 d7                	mov    %edx,%edi
  800bcc:	89 d6                	mov    %edx,%esi
  800bce:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd0:	5b                   	pop    %ebx
  800bd1:	5e                   	pop    %esi
  800bd2:	5f                   	pop    %edi
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    

00800bd5 <sys_yield>:

void
sys_yield(void)
{
  800bd5:	f3 0f 1e fb          	endbr32 
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	57                   	push   %edi
  800bdd:	56                   	push   %esi
  800bde:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bdf:	ba 00 00 00 00       	mov    $0x0,%edx
  800be4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800be9:	89 d1                	mov    %edx,%ecx
  800beb:	89 d3                	mov    %edx,%ebx
  800bed:	89 d7                	mov    %edx,%edi
  800bef:	89 d6                	mov    %edx,%esi
  800bf1:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bf3:	5b                   	pop    %ebx
  800bf4:	5e                   	pop    %esi
  800bf5:	5f                   	pop    %edi
  800bf6:	5d                   	pop    %ebp
  800bf7:	c3                   	ret    

00800bf8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bf8:	f3 0f 1e fb          	endbr32 
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
  800c02:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c05:	be 00 00 00 00       	mov    $0x0,%esi
  800c0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c10:	b8 04 00 00 00       	mov    $0x4,%eax
  800c15:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c18:	89 f7                	mov    %esi,%edi
  800c1a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c1c:	85 c0                	test   %eax,%eax
  800c1e:	7f 08                	jg     800c28 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c23:	5b                   	pop    %ebx
  800c24:	5e                   	pop    %esi
  800c25:	5f                   	pop    %edi
  800c26:	5d                   	pop    %ebp
  800c27:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c28:	83 ec 0c             	sub    $0xc,%esp
  800c2b:	50                   	push   %eax
  800c2c:	6a 04                	push   $0x4
  800c2e:	68 bf 22 80 00       	push   $0x8022bf
  800c33:	6a 23                	push   $0x23
  800c35:	68 dc 22 80 00       	push   $0x8022dc
  800c3a:	e8 0f 0f 00 00       	call   801b4e <_panic>

00800c3f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c3f:	f3 0f 1e fb          	endbr32 
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c52:	b8 05 00 00 00       	mov    $0x5,%eax
  800c57:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c5a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c5d:	8b 75 18             	mov    0x18(%ebp),%esi
  800c60:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c62:	85 c0                	test   %eax,%eax
  800c64:	7f 08                	jg     800c6e <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c69:	5b                   	pop    %ebx
  800c6a:	5e                   	pop    %esi
  800c6b:	5f                   	pop    %edi
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6e:	83 ec 0c             	sub    $0xc,%esp
  800c71:	50                   	push   %eax
  800c72:	6a 05                	push   $0x5
  800c74:	68 bf 22 80 00       	push   $0x8022bf
  800c79:	6a 23                	push   $0x23
  800c7b:	68 dc 22 80 00       	push   $0x8022dc
  800c80:	e8 c9 0e 00 00       	call   801b4e <_panic>

00800c85 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c85:	f3 0f 1e fb          	endbr32 
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	57                   	push   %edi
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
  800c8f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c92:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c97:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9d:	b8 06 00 00 00       	mov    $0x6,%eax
  800ca2:	89 df                	mov    %ebx,%edi
  800ca4:	89 de                	mov    %ebx,%esi
  800ca6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca8:	85 c0                	test   %eax,%eax
  800caa:	7f 08                	jg     800cb4 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb4:	83 ec 0c             	sub    $0xc,%esp
  800cb7:	50                   	push   %eax
  800cb8:	6a 06                	push   $0x6
  800cba:	68 bf 22 80 00       	push   $0x8022bf
  800cbf:	6a 23                	push   $0x23
  800cc1:	68 dc 22 80 00       	push   $0x8022dc
  800cc6:	e8 83 0e 00 00       	call   801b4e <_panic>

00800ccb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ccb:	f3 0f 1e fb          	endbr32 
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	57                   	push   %edi
  800cd3:	56                   	push   %esi
  800cd4:	53                   	push   %ebx
  800cd5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce3:	b8 08 00 00 00       	mov    $0x8,%eax
  800ce8:	89 df                	mov    %ebx,%edi
  800cea:	89 de                	mov    %ebx,%esi
  800cec:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cee:	85 c0                	test   %eax,%eax
  800cf0:	7f 08                	jg     800cfa <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cf2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf5:	5b                   	pop    %ebx
  800cf6:	5e                   	pop    %esi
  800cf7:	5f                   	pop    %edi
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfa:	83 ec 0c             	sub    $0xc,%esp
  800cfd:	50                   	push   %eax
  800cfe:	6a 08                	push   $0x8
  800d00:	68 bf 22 80 00       	push   $0x8022bf
  800d05:	6a 23                	push   $0x23
  800d07:	68 dc 22 80 00       	push   $0x8022dc
  800d0c:	e8 3d 0e 00 00       	call   801b4e <_panic>

00800d11 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d11:	f3 0f 1e fb          	endbr32 
  800d15:	55                   	push   %ebp
  800d16:	89 e5                	mov    %esp,%ebp
  800d18:	57                   	push   %edi
  800d19:	56                   	push   %esi
  800d1a:	53                   	push   %ebx
  800d1b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d23:	8b 55 08             	mov    0x8(%ebp),%edx
  800d26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d29:	b8 09 00 00 00       	mov    $0x9,%eax
  800d2e:	89 df                	mov    %ebx,%edi
  800d30:	89 de                	mov    %ebx,%esi
  800d32:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d34:	85 c0                	test   %eax,%eax
  800d36:	7f 08                	jg     800d40 <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d40:	83 ec 0c             	sub    $0xc,%esp
  800d43:	50                   	push   %eax
  800d44:	6a 09                	push   $0x9
  800d46:	68 bf 22 80 00       	push   $0x8022bf
  800d4b:	6a 23                	push   $0x23
  800d4d:	68 dc 22 80 00       	push   $0x8022dc
  800d52:	e8 f7 0d 00 00       	call   801b4e <_panic>

00800d57 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d57:	f3 0f 1e fb          	endbr32 
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	57                   	push   %edi
  800d5f:	56                   	push   %esi
  800d60:	53                   	push   %ebx
  800d61:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d64:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d69:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d74:	89 df                	mov    %ebx,%edi
  800d76:	89 de                	mov    %ebx,%esi
  800d78:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d7a:	85 c0                	test   %eax,%eax
  800d7c:	7f 08                	jg     800d86 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d81:	5b                   	pop    %ebx
  800d82:	5e                   	pop    %esi
  800d83:	5f                   	pop    %edi
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d86:	83 ec 0c             	sub    $0xc,%esp
  800d89:	50                   	push   %eax
  800d8a:	6a 0a                	push   $0xa
  800d8c:	68 bf 22 80 00       	push   $0x8022bf
  800d91:	6a 23                	push   $0x23
  800d93:	68 dc 22 80 00       	push   $0x8022dc
  800d98:	e8 b1 0d 00 00       	call   801b4e <_panic>

00800d9d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d9d:	f3 0f 1e fb          	endbr32 
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	57                   	push   %edi
  800da5:	56                   	push   %esi
  800da6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800da7:	8b 55 08             	mov    0x8(%ebp),%edx
  800daa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dad:	b8 0c 00 00 00       	mov    $0xc,%eax
  800db2:	be 00 00 00 00       	mov    $0x0,%esi
  800db7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dba:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dbd:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dc4:	f3 0f 1e fb          	endbr32 
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	57                   	push   %edi
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
  800dce:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dd1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dde:	89 cb                	mov    %ecx,%ebx
  800de0:	89 cf                	mov    %ecx,%edi
  800de2:	89 ce                	mov    %ecx,%esi
  800de4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800de6:	85 c0                	test   %eax,%eax
  800de8:	7f 08                	jg     800df2 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ded:	5b                   	pop    %ebx
  800dee:	5e                   	pop    %esi
  800def:	5f                   	pop    %edi
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800df2:	83 ec 0c             	sub    $0xc,%esp
  800df5:	50                   	push   %eax
  800df6:	6a 0d                	push   $0xd
  800df8:	68 bf 22 80 00       	push   $0x8022bf
  800dfd:	6a 23                	push   $0x23
  800dff:	68 dc 22 80 00       	push   $0x8022dc
  800e04:	e8 45 0d 00 00       	call   801b4e <_panic>

00800e09 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e09:	f3 0f 1e fb          	endbr32 
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e10:	8b 45 08             	mov    0x8(%ebp),%eax
  800e13:	05 00 00 00 30       	add    $0x30000000,%eax
  800e18:	c1 e8 0c             	shr    $0xc,%eax
}
  800e1b:	5d                   	pop    %ebp
  800e1c:	c3                   	ret    

00800e1d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e1d:	f3 0f 1e fb          	endbr32 
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e24:	8b 45 08             	mov    0x8(%ebp),%eax
  800e27:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800e2c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e31:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e36:	5d                   	pop    %ebp
  800e37:	c3                   	ret    

00800e38 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e38:	f3 0f 1e fb          	endbr32 
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
  800e3f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e44:	89 c2                	mov    %eax,%edx
  800e46:	c1 ea 16             	shr    $0x16,%edx
  800e49:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e50:	f6 c2 01             	test   $0x1,%dl
  800e53:	74 2d                	je     800e82 <fd_alloc+0x4a>
  800e55:	89 c2                	mov    %eax,%edx
  800e57:	c1 ea 0c             	shr    $0xc,%edx
  800e5a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e61:	f6 c2 01             	test   $0x1,%dl
  800e64:	74 1c                	je     800e82 <fd_alloc+0x4a>
  800e66:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800e6b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e70:	75 d2                	jne    800e44 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e72:	8b 45 08             	mov    0x8(%ebp),%eax
  800e75:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800e7b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800e80:	eb 0a                	jmp    800e8c <fd_alloc+0x54>
			*fd_store = fd;
  800e82:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e85:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e87:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e8c:	5d                   	pop    %ebp
  800e8d:	c3                   	ret    

00800e8e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e8e:	f3 0f 1e fb          	endbr32 
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
  800e95:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e98:	83 f8 1f             	cmp    $0x1f,%eax
  800e9b:	77 30                	ja     800ecd <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e9d:	c1 e0 0c             	shl    $0xc,%eax
  800ea0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ea5:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800eab:	f6 c2 01             	test   $0x1,%dl
  800eae:	74 24                	je     800ed4 <fd_lookup+0x46>
  800eb0:	89 c2                	mov    %eax,%edx
  800eb2:	c1 ea 0c             	shr    $0xc,%edx
  800eb5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ebc:	f6 c2 01             	test   $0x1,%dl
  800ebf:	74 1a                	je     800edb <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ec1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ec4:	89 02                	mov    %eax,(%edx)
	return 0;
  800ec6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ecb:	5d                   	pop    %ebp
  800ecc:	c3                   	ret    
		return -E_INVAL;
  800ecd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ed2:	eb f7                	jmp    800ecb <fd_lookup+0x3d>
		return -E_INVAL;
  800ed4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ed9:	eb f0                	jmp    800ecb <fd_lookup+0x3d>
  800edb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ee0:	eb e9                	jmp    800ecb <fd_lookup+0x3d>

00800ee2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ee2:	f3 0f 1e fb          	endbr32 
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	83 ec 08             	sub    $0x8,%esp
  800eec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eef:	ba 68 23 80 00       	mov    $0x802368,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ef4:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800ef9:	39 08                	cmp    %ecx,(%eax)
  800efb:	74 33                	je     800f30 <dev_lookup+0x4e>
  800efd:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800f00:	8b 02                	mov    (%edx),%eax
  800f02:	85 c0                	test   %eax,%eax
  800f04:	75 f3                	jne    800ef9 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f06:	a1 04 40 80 00       	mov    0x804004,%eax
  800f0b:	8b 40 48             	mov    0x48(%eax),%eax
  800f0e:	83 ec 04             	sub    $0x4,%esp
  800f11:	51                   	push   %ecx
  800f12:	50                   	push   %eax
  800f13:	68 ec 22 80 00       	push   $0x8022ec
  800f18:	e8 90 f2 ff ff       	call   8001ad <cprintf>
	*dev = 0;
  800f1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f20:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f26:	83 c4 10             	add    $0x10,%esp
  800f29:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f2e:	c9                   	leave  
  800f2f:	c3                   	ret    
			*dev = devtab[i];
  800f30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f33:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f35:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3a:	eb f2                	jmp    800f2e <dev_lookup+0x4c>

00800f3c <fd_close>:
{
  800f3c:	f3 0f 1e fb          	endbr32 
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	57                   	push   %edi
  800f44:	56                   	push   %esi
  800f45:	53                   	push   %ebx
  800f46:	83 ec 24             	sub    $0x24,%esp
  800f49:	8b 75 08             	mov    0x8(%ebp),%esi
  800f4c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f4f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f52:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f53:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f59:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f5c:	50                   	push   %eax
  800f5d:	e8 2c ff ff ff       	call   800e8e <fd_lookup>
  800f62:	89 c3                	mov    %eax,%ebx
  800f64:	83 c4 10             	add    $0x10,%esp
  800f67:	85 c0                	test   %eax,%eax
  800f69:	78 05                	js     800f70 <fd_close+0x34>
	    || fd != fd2)
  800f6b:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800f6e:	74 16                	je     800f86 <fd_close+0x4a>
		return (must_exist ? r : 0);
  800f70:	89 f8                	mov    %edi,%eax
  800f72:	84 c0                	test   %al,%al
  800f74:	b8 00 00 00 00       	mov    $0x0,%eax
  800f79:	0f 44 d8             	cmove  %eax,%ebx
}
  800f7c:	89 d8                	mov    %ebx,%eax
  800f7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f81:	5b                   	pop    %ebx
  800f82:	5e                   	pop    %esi
  800f83:	5f                   	pop    %edi
  800f84:	5d                   	pop    %ebp
  800f85:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f86:	83 ec 08             	sub    $0x8,%esp
  800f89:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f8c:	50                   	push   %eax
  800f8d:	ff 36                	pushl  (%esi)
  800f8f:	e8 4e ff ff ff       	call   800ee2 <dev_lookup>
  800f94:	89 c3                	mov    %eax,%ebx
  800f96:	83 c4 10             	add    $0x10,%esp
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	78 1a                	js     800fb7 <fd_close+0x7b>
		if (dev->dev_close)
  800f9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fa0:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800fa3:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800fa8:	85 c0                	test   %eax,%eax
  800faa:	74 0b                	je     800fb7 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800fac:	83 ec 0c             	sub    $0xc,%esp
  800faf:	56                   	push   %esi
  800fb0:	ff d0                	call   *%eax
  800fb2:	89 c3                	mov    %eax,%ebx
  800fb4:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800fb7:	83 ec 08             	sub    $0x8,%esp
  800fba:	56                   	push   %esi
  800fbb:	6a 00                	push   $0x0
  800fbd:	e8 c3 fc ff ff       	call   800c85 <sys_page_unmap>
	return r;
  800fc2:	83 c4 10             	add    $0x10,%esp
  800fc5:	eb b5                	jmp    800f7c <fd_close+0x40>

00800fc7 <close>:

int
close(int fdnum)
{
  800fc7:	f3 0f 1e fb          	endbr32 
  800fcb:	55                   	push   %ebp
  800fcc:	89 e5                	mov    %esp,%ebp
  800fce:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fd1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd4:	50                   	push   %eax
  800fd5:	ff 75 08             	pushl  0x8(%ebp)
  800fd8:	e8 b1 fe ff ff       	call   800e8e <fd_lookup>
  800fdd:	83 c4 10             	add    $0x10,%esp
  800fe0:	85 c0                	test   %eax,%eax
  800fe2:	79 02                	jns    800fe6 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  800fe4:	c9                   	leave  
  800fe5:	c3                   	ret    
		return fd_close(fd, 1);
  800fe6:	83 ec 08             	sub    $0x8,%esp
  800fe9:	6a 01                	push   $0x1
  800feb:	ff 75 f4             	pushl  -0xc(%ebp)
  800fee:	e8 49 ff ff ff       	call   800f3c <fd_close>
  800ff3:	83 c4 10             	add    $0x10,%esp
  800ff6:	eb ec                	jmp    800fe4 <close+0x1d>

00800ff8 <close_all>:

void
close_all(void)
{
  800ff8:	f3 0f 1e fb          	endbr32 
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	53                   	push   %ebx
  801000:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801003:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801008:	83 ec 0c             	sub    $0xc,%esp
  80100b:	53                   	push   %ebx
  80100c:	e8 b6 ff ff ff       	call   800fc7 <close>
	for (i = 0; i < MAXFD; i++)
  801011:	83 c3 01             	add    $0x1,%ebx
  801014:	83 c4 10             	add    $0x10,%esp
  801017:	83 fb 20             	cmp    $0x20,%ebx
  80101a:	75 ec                	jne    801008 <close_all+0x10>
}
  80101c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80101f:	c9                   	leave  
  801020:	c3                   	ret    

00801021 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801021:	f3 0f 1e fb          	endbr32 
  801025:	55                   	push   %ebp
  801026:	89 e5                	mov    %esp,%ebp
  801028:	57                   	push   %edi
  801029:	56                   	push   %esi
  80102a:	53                   	push   %ebx
  80102b:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80102e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801031:	50                   	push   %eax
  801032:	ff 75 08             	pushl  0x8(%ebp)
  801035:	e8 54 fe ff ff       	call   800e8e <fd_lookup>
  80103a:	89 c3                	mov    %eax,%ebx
  80103c:	83 c4 10             	add    $0x10,%esp
  80103f:	85 c0                	test   %eax,%eax
  801041:	0f 88 81 00 00 00    	js     8010c8 <dup+0xa7>
		return r;
	close(newfdnum);
  801047:	83 ec 0c             	sub    $0xc,%esp
  80104a:	ff 75 0c             	pushl  0xc(%ebp)
  80104d:	e8 75 ff ff ff       	call   800fc7 <close>

	newfd = INDEX2FD(newfdnum);
  801052:	8b 75 0c             	mov    0xc(%ebp),%esi
  801055:	c1 e6 0c             	shl    $0xc,%esi
  801058:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80105e:	83 c4 04             	add    $0x4,%esp
  801061:	ff 75 e4             	pushl  -0x1c(%ebp)
  801064:	e8 b4 fd ff ff       	call   800e1d <fd2data>
  801069:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80106b:	89 34 24             	mov    %esi,(%esp)
  80106e:	e8 aa fd ff ff       	call   800e1d <fd2data>
  801073:	83 c4 10             	add    $0x10,%esp
  801076:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801078:	89 d8                	mov    %ebx,%eax
  80107a:	c1 e8 16             	shr    $0x16,%eax
  80107d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801084:	a8 01                	test   $0x1,%al
  801086:	74 11                	je     801099 <dup+0x78>
  801088:	89 d8                	mov    %ebx,%eax
  80108a:	c1 e8 0c             	shr    $0xc,%eax
  80108d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801094:	f6 c2 01             	test   $0x1,%dl
  801097:	75 39                	jne    8010d2 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801099:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80109c:	89 d0                	mov    %edx,%eax
  80109e:	c1 e8 0c             	shr    $0xc,%eax
  8010a1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010a8:	83 ec 0c             	sub    $0xc,%esp
  8010ab:	25 07 0e 00 00       	and    $0xe07,%eax
  8010b0:	50                   	push   %eax
  8010b1:	56                   	push   %esi
  8010b2:	6a 00                	push   $0x0
  8010b4:	52                   	push   %edx
  8010b5:	6a 00                	push   $0x0
  8010b7:	e8 83 fb ff ff       	call   800c3f <sys_page_map>
  8010bc:	89 c3                	mov    %eax,%ebx
  8010be:	83 c4 20             	add    $0x20,%esp
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	78 31                	js     8010f6 <dup+0xd5>
		goto err;

	return newfdnum;
  8010c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010c8:	89 d8                	mov    %ebx,%eax
  8010ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010cd:	5b                   	pop    %ebx
  8010ce:	5e                   	pop    %esi
  8010cf:	5f                   	pop    %edi
  8010d0:	5d                   	pop    %ebp
  8010d1:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010d2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010d9:	83 ec 0c             	sub    $0xc,%esp
  8010dc:	25 07 0e 00 00       	and    $0xe07,%eax
  8010e1:	50                   	push   %eax
  8010e2:	57                   	push   %edi
  8010e3:	6a 00                	push   $0x0
  8010e5:	53                   	push   %ebx
  8010e6:	6a 00                	push   $0x0
  8010e8:	e8 52 fb ff ff       	call   800c3f <sys_page_map>
  8010ed:	89 c3                	mov    %eax,%ebx
  8010ef:	83 c4 20             	add    $0x20,%esp
  8010f2:	85 c0                	test   %eax,%eax
  8010f4:	79 a3                	jns    801099 <dup+0x78>
	sys_page_unmap(0, newfd);
  8010f6:	83 ec 08             	sub    $0x8,%esp
  8010f9:	56                   	push   %esi
  8010fa:	6a 00                	push   $0x0
  8010fc:	e8 84 fb ff ff       	call   800c85 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801101:	83 c4 08             	add    $0x8,%esp
  801104:	57                   	push   %edi
  801105:	6a 00                	push   $0x0
  801107:	e8 79 fb ff ff       	call   800c85 <sys_page_unmap>
	return r;
  80110c:	83 c4 10             	add    $0x10,%esp
  80110f:	eb b7                	jmp    8010c8 <dup+0xa7>

00801111 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801111:	f3 0f 1e fb          	endbr32 
  801115:	55                   	push   %ebp
  801116:	89 e5                	mov    %esp,%ebp
  801118:	53                   	push   %ebx
  801119:	83 ec 1c             	sub    $0x1c,%esp
  80111c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80111f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801122:	50                   	push   %eax
  801123:	53                   	push   %ebx
  801124:	e8 65 fd ff ff       	call   800e8e <fd_lookup>
  801129:	83 c4 10             	add    $0x10,%esp
  80112c:	85 c0                	test   %eax,%eax
  80112e:	78 3f                	js     80116f <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801130:	83 ec 08             	sub    $0x8,%esp
  801133:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801136:	50                   	push   %eax
  801137:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80113a:	ff 30                	pushl  (%eax)
  80113c:	e8 a1 fd ff ff       	call   800ee2 <dev_lookup>
  801141:	83 c4 10             	add    $0x10,%esp
  801144:	85 c0                	test   %eax,%eax
  801146:	78 27                	js     80116f <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801148:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80114b:	8b 42 08             	mov    0x8(%edx),%eax
  80114e:	83 e0 03             	and    $0x3,%eax
  801151:	83 f8 01             	cmp    $0x1,%eax
  801154:	74 1e                	je     801174 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801156:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801159:	8b 40 08             	mov    0x8(%eax),%eax
  80115c:	85 c0                	test   %eax,%eax
  80115e:	74 35                	je     801195 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801160:	83 ec 04             	sub    $0x4,%esp
  801163:	ff 75 10             	pushl  0x10(%ebp)
  801166:	ff 75 0c             	pushl  0xc(%ebp)
  801169:	52                   	push   %edx
  80116a:	ff d0                	call   *%eax
  80116c:	83 c4 10             	add    $0x10,%esp
}
  80116f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801172:	c9                   	leave  
  801173:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801174:	a1 04 40 80 00       	mov    0x804004,%eax
  801179:	8b 40 48             	mov    0x48(%eax),%eax
  80117c:	83 ec 04             	sub    $0x4,%esp
  80117f:	53                   	push   %ebx
  801180:	50                   	push   %eax
  801181:	68 2d 23 80 00       	push   $0x80232d
  801186:	e8 22 f0 ff ff       	call   8001ad <cprintf>
		return -E_INVAL;
  80118b:	83 c4 10             	add    $0x10,%esp
  80118e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801193:	eb da                	jmp    80116f <read+0x5e>
		return -E_NOT_SUPP;
  801195:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80119a:	eb d3                	jmp    80116f <read+0x5e>

0080119c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80119c:	f3 0f 1e fb          	endbr32 
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
  8011a3:	57                   	push   %edi
  8011a4:	56                   	push   %esi
  8011a5:	53                   	push   %ebx
  8011a6:	83 ec 0c             	sub    $0xc,%esp
  8011a9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011ac:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011af:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b4:	eb 02                	jmp    8011b8 <readn+0x1c>
  8011b6:	01 c3                	add    %eax,%ebx
  8011b8:	39 f3                	cmp    %esi,%ebx
  8011ba:	73 21                	jae    8011dd <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011bc:	83 ec 04             	sub    $0x4,%esp
  8011bf:	89 f0                	mov    %esi,%eax
  8011c1:	29 d8                	sub    %ebx,%eax
  8011c3:	50                   	push   %eax
  8011c4:	89 d8                	mov    %ebx,%eax
  8011c6:	03 45 0c             	add    0xc(%ebp),%eax
  8011c9:	50                   	push   %eax
  8011ca:	57                   	push   %edi
  8011cb:	e8 41 ff ff ff       	call   801111 <read>
		if (m < 0)
  8011d0:	83 c4 10             	add    $0x10,%esp
  8011d3:	85 c0                	test   %eax,%eax
  8011d5:	78 04                	js     8011db <readn+0x3f>
			return m;
		if (m == 0)
  8011d7:	75 dd                	jne    8011b6 <readn+0x1a>
  8011d9:	eb 02                	jmp    8011dd <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011db:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8011dd:	89 d8                	mov    %ebx,%eax
  8011df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e2:	5b                   	pop    %ebx
  8011e3:	5e                   	pop    %esi
  8011e4:	5f                   	pop    %edi
  8011e5:	5d                   	pop    %ebp
  8011e6:	c3                   	ret    

008011e7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011e7:	f3 0f 1e fb          	endbr32 
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
  8011ee:	53                   	push   %ebx
  8011ef:	83 ec 1c             	sub    $0x1c,%esp
  8011f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f8:	50                   	push   %eax
  8011f9:	53                   	push   %ebx
  8011fa:	e8 8f fc ff ff       	call   800e8e <fd_lookup>
  8011ff:	83 c4 10             	add    $0x10,%esp
  801202:	85 c0                	test   %eax,%eax
  801204:	78 3a                	js     801240 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801206:	83 ec 08             	sub    $0x8,%esp
  801209:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80120c:	50                   	push   %eax
  80120d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801210:	ff 30                	pushl  (%eax)
  801212:	e8 cb fc ff ff       	call   800ee2 <dev_lookup>
  801217:	83 c4 10             	add    $0x10,%esp
  80121a:	85 c0                	test   %eax,%eax
  80121c:	78 22                	js     801240 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80121e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801221:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801225:	74 1e                	je     801245 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801227:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80122a:	8b 52 0c             	mov    0xc(%edx),%edx
  80122d:	85 d2                	test   %edx,%edx
  80122f:	74 35                	je     801266 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801231:	83 ec 04             	sub    $0x4,%esp
  801234:	ff 75 10             	pushl  0x10(%ebp)
  801237:	ff 75 0c             	pushl  0xc(%ebp)
  80123a:	50                   	push   %eax
  80123b:	ff d2                	call   *%edx
  80123d:	83 c4 10             	add    $0x10,%esp
}
  801240:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801243:	c9                   	leave  
  801244:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801245:	a1 04 40 80 00       	mov    0x804004,%eax
  80124a:	8b 40 48             	mov    0x48(%eax),%eax
  80124d:	83 ec 04             	sub    $0x4,%esp
  801250:	53                   	push   %ebx
  801251:	50                   	push   %eax
  801252:	68 49 23 80 00       	push   $0x802349
  801257:	e8 51 ef ff ff       	call   8001ad <cprintf>
		return -E_INVAL;
  80125c:	83 c4 10             	add    $0x10,%esp
  80125f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801264:	eb da                	jmp    801240 <write+0x59>
		return -E_NOT_SUPP;
  801266:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80126b:	eb d3                	jmp    801240 <write+0x59>

0080126d <seek>:

int
seek(int fdnum, off_t offset)
{
  80126d:	f3 0f 1e fb          	endbr32 
  801271:	55                   	push   %ebp
  801272:	89 e5                	mov    %esp,%ebp
  801274:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801277:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127a:	50                   	push   %eax
  80127b:	ff 75 08             	pushl  0x8(%ebp)
  80127e:	e8 0b fc ff ff       	call   800e8e <fd_lookup>
  801283:	83 c4 10             	add    $0x10,%esp
  801286:	85 c0                	test   %eax,%eax
  801288:	78 0e                	js     801298 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80128a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80128d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801290:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801293:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801298:	c9                   	leave  
  801299:	c3                   	ret    

0080129a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80129a:	f3 0f 1e fb          	endbr32 
  80129e:	55                   	push   %ebp
  80129f:	89 e5                	mov    %esp,%ebp
  8012a1:	53                   	push   %ebx
  8012a2:	83 ec 1c             	sub    $0x1c,%esp
  8012a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ab:	50                   	push   %eax
  8012ac:	53                   	push   %ebx
  8012ad:	e8 dc fb ff ff       	call   800e8e <fd_lookup>
  8012b2:	83 c4 10             	add    $0x10,%esp
  8012b5:	85 c0                	test   %eax,%eax
  8012b7:	78 37                	js     8012f0 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b9:	83 ec 08             	sub    $0x8,%esp
  8012bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012bf:	50                   	push   %eax
  8012c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c3:	ff 30                	pushl  (%eax)
  8012c5:	e8 18 fc ff ff       	call   800ee2 <dev_lookup>
  8012ca:	83 c4 10             	add    $0x10,%esp
  8012cd:	85 c0                	test   %eax,%eax
  8012cf:	78 1f                	js     8012f0 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012d8:	74 1b                	je     8012f5 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8012da:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012dd:	8b 52 18             	mov    0x18(%edx),%edx
  8012e0:	85 d2                	test   %edx,%edx
  8012e2:	74 32                	je     801316 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012e4:	83 ec 08             	sub    $0x8,%esp
  8012e7:	ff 75 0c             	pushl  0xc(%ebp)
  8012ea:	50                   	push   %eax
  8012eb:	ff d2                	call   *%edx
  8012ed:	83 c4 10             	add    $0x10,%esp
}
  8012f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f3:	c9                   	leave  
  8012f4:	c3                   	ret    
			thisenv->env_id, fdnum);
  8012f5:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012fa:	8b 40 48             	mov    0x48(%eax),%eax
  8012fd:	83 ec 04             	sub    $0x4,%esp
  801300:	53                   	push   %ebx
  801301:	50                   	push   %eax
  801302:	68 0c 23 80 00       	push   $0x80230c
  801307:	e8 a1 ee ff ff       	call   8001ad <cprintf>
		return -E_INVAL;
  80130c:	83 c4 10             	add    $0x10,%esp
  80130f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801314:	eb da                	jmp    8012f0 <ftruncate+0x56>
		return -E_NOT_SUPP;
  801316:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80131b:	eb d3                	jmp    8012f0 <ftruncate+0x56>

0080131d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80131d:	f3 0f 1e fb          	endbr32 
  801321:	55                   	push   %ebp
  801322:	89 e5                	mov    %esp,%ebp
  801324:	53                   	push   %ebx
  801325:	83 ec 1c             	sub    $0x1c,%esp
  801328:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80132b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80132e:	50                   	push   %eax
  80132f:	ff 75 08             	pushl  0x8(%ebp)
  801332:	e8 57 fb ff ff       	call   800e8e <fd_lookup>
  801337:	83 c4 10             	add    $0x10,%esp
  80133a:	85 c0                	test   %eax,%eax
  80133c:	78 4b                	js     801389 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80133e:	83 ec 08             	sub    $0x8,%esp
  801341:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801344:	50                   	push   %eax
  801345:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801348:	ff 30                	pushl  (%eax)
  80134a:	e8 93 fb ff ff       	call   800ee2 <dev_lookup>
  80134f:	83 c4 10             	add    $0x10,%esp
  801352:	85 c0                	test   %eax,%eax
  801354:	78 33                	js     801389 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801356:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801359:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80135d:	74 2f                	je     80138e <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80135f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801362:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801369:	00 00 00 
	stat->st_isdir = 0;
  80136c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801373:	00 00 00 
	stat->st_dev = dev;
  801376:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80137c:	83 ec 08             	sub    $0x8,%esp
  80137f:	53                   	push   %ebx
  801380:	ff 75 f0             	pushl  -0x10(%ebp)
  801383:	ff 50 14             	call   *0x14(%eax)
  801386:	83 c4 10             	add    $0x10,%esp
}
  801389:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80138c:	c9                   	leave  
  80138d:	c3                   	ret    
		return -E_NOT_SUPP;
  80138e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801393:	eb f4                	jmp    801389 <fstat+0x6c>

00801395 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801395:	f3 0f 1e fb          	endbr32 
  801399:	55                   	push   %ebp
  80139a:	89 e5                	mov    %esp,%ebp
  80139c:	56                   	push   %esi
  80139d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80139e:	83 ec 08             	sub    $0x8,%esp
  8013a1:	6a 00                	push   $0x0
  8013a3:	ff 75 08             	pushl  0x8(%ebp)
  8013a6:	e8 fb 01 00 00       	call   8015a6 <open>
  8013ab:	89 c3                	mov    %eax,%ebx
  8013ad:	83 c4 10             	add    $0x10,%esp
  8013b0:	85 c0                	test   %eax,%eax
  8013b2:	78 1b                	js     8013cf <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8013b4:	83 ec 08             	sub    $0x8,%esp
  8013b7:	ff 75 0c             	pushl  0xc(%ebp)
  8013ba:	50                   	push   %eax
  8013bb:	e8 5d ff ff ff       	call   80131d <fstat>
  8013c0:	89 c6                	mov    %eax,%esi
	close(fd);
  8013c2:	89 1c 24             	mov    %ebx,(%esp)
  8013c5:	e8 fd fb ff ff       	call   800fc7 <close>
	return r;
  8013ca:	83 c4 10             	add    $0x10,%esp
  8013cd:	89 f3                	mov    %esi,%ebx
}
  8013cf:	89 d8                	mov    %ebx,%eax
  8013d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013d4:	5b                   	pop    %ebx
  8013d5:	5e                   	pop    %esi
  8013d6:	5d                   	pop    %ebp
  8013d7:	c3                   	ret    

008013d8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013d8:	55                   	push   %ebp
  8013d9:	89 e5                	mov    %esp,%ebp
  8013db:	56                   	push   %esi
  8013dc:	53                   	push   %ebx
  8013dd:	89 c6                	mov    %eax,%esi
  8013df:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013e1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013e8:	74 27                	je     801411 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013ea:	6a 07                	push   $0x7
  8013ec:	68 00 50 80 00       	push   $0x805000
  8013f1:	56                   	push   %esi
  8013f2:	ff 35 00 40 80 00    	pushl  0x804000
  8013f8:	e8 f2 07 00 00       	call   801bef <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013fd:	83 c4 0c             	add    $0xc,%esp
  801400:	6a 00                	push   $0x0
  801402:	53                   	push   %ebx
  801403:	6a 00                	push   $0x0
  801405:	e8 8e 07 00 00       	call   801b98 <ipc_recv>
}
  80140a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80140d:	5b                   	pop    %ebx
  80140e:	5e                   	pop    %esi
  80140f:	5d                   	pop    %ebp
  801410:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801411:	83 ec 0c             	sub    $0xc,%esp
  801414:	6a 01                	push   $0x1
  801416:	e8 3a 08 00 00       	call   801c55 <ipc_find_env>
  80141b:	a3 00 40 80 00       	mov    %eax,0x804000
  801420:	83 c4 10             	add    $0x10,%esp
  801423:	eb c5                	jmp    8013ea <fsipc+0x12>

00801425 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801425:	f3 0f 1e fb          	endbr32 
  801429:	55                   	push   %ebp
  80142a:	89 e5                	mov    %esp,%ebp
  80142c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80142f:	8b 45 08             	mov    0x8(%ebp),%eax
  801432:	8b 40 0c             	mov    0xc(%eax),%eax
  801435:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80143a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80143d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801442:	ba 00 00 00 00       	mov    $0x0,%edx
  801447:	b8 02 00 00 00       	mov    $0x2,%eax
  80144c:	e8 87 ff ff ff       	call   8013d8 <fsipc>
}
  801451:	c9                   	leave  
  801452:	c3                   	ret    

00801453 <devfile_flush>:
{
  801453:	f3 0f 1e fb          	endbr32 
  801457:	55                   	push   %ebp
  801458:	89 e5                	mov    %esp,%ebp
  80145a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80145d:	8b 45 08             	mov    0x8(%ebp),%eax
  801460:	8b 40 0c             	mov    0xc(%eax),%eax
  801463:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801468:	ba 00 00 00 00       	mov    $0x0,%edx
  80146d:	b8 06 00 00 00       	mov    $0x6,%eax
  801472:	e8 61 ff ff ff       	call   8013d8 <fsipc>
}
  801477:	c9                   	leave  
  801478:	c3                   	ret    

00801479 <devfile_stat>:
{
  801479:	f3 0f 1e fb          	endbr32 
  80147d:	55                   	push   %ebp
  80147e:	89 e5                	mov    %esp,%ebp
  801480:	53                   	push   %ebx
  801481:	83 ec 04             	sub    $0x4,%esp
  801484:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801487:	8b 45 08             	mov    0x8(%ebp),%eax
  80148a:	8b 40 0c             	mov    0xc(%eax),%eax
  80148d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801492:	ba 00 00 00 00       	mov    $0x0,%edx
  801497:	b8 05 00 00 00       	mov    $0x5,%eax
  80149c:	e8 37 ff ff ff       	call   8013d8 <fsipc>
  8014a1:	85 c0                	test   %eax,%eax
  8014a3:	78 2c                	js     8014d1 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014a5:	83 ec 08             	sub    $0x8,%esp
  8014a8:	68 00 50 80 00       	push   $0x805000
  8014ad:	53                   	push   %ebx
  8014ae:	e8 03 f3 ff ff       	call   8007b6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014b3:	a1 80 50 80 00       	mov    0x805080,%eax
  8014b8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014be:	a1 84 50 80 00       	mov    0x805084,%eax
  8014c3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014c9:	83 c4 10             	add    $0x10,%esp
  8014cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014d4:	c9                   	leave  
  8014d5:	c3                   	ret    

008014d6 <devfile_write>:
{
  8014d6:	f3 0f 1e fb          	endbr32 
  8014da:	55                   	push   %ebp
  8014db:	89 e5                	mov    %esp,%ebp
  8014dd:	83 ec 0c             	sub    $0xc,%esp
  8014e0:	8b 45 10             	mov    0x10(%ebp),%eax
	n = n > size_max ? size_max : n;
  8014e3:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014e8:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8014ed:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8014f3:	8b 52 0c             	mov    0xc(%edx),%edx
  8014f6:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014fc:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801501:	50                   	push   %eax
  801502:	ff 75 0c             	pushl  0xc(%ebp)
  801505:	68 08 50 80 00       	push   $0x805008
  80150a:	e8 5d f4 ff ff       	call   80096c <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80150f:	ba 00 00 00 00       	mov    $0x0,%edx
  801514:	b8 04 00 00 00       	mov    $0x4,%eax
  801519:	e8 ba fe ff ff       	call   8013d8 <fsipc>
}
  80151e:	c9                   	leave  
  80151f:	c3                   	ret    

00801520 <devfile_read>:
{
  801520:	f3 0f 1e fb          	endbr32 
  801524:	55                   	push   %ebp
  801525:	89 e5                	mov    %esp,%ebp
  801527:	56                   	push   %esi
  801528:	53                   	push   %ebx
  801529:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80152c:	8b 45 08             	mov    0x8(%ebp),%eax
  80152f:	8b 40 0c             	mov    0xc(%eax),%eax
  801532:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801537:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80153d:	ba 00 00 00 00       	mov    $0x0,%edx
  801542:	b8 03 00 00 00       	mov    $0x3,%eax
  801547:	e8 8c fe ff ff       	call   8013d8 <fsipc>
  80154c:	89 c3                	mov    %eax,%ebx
  80154e:	85 c0                	test   %eax,%eax
  801550:	78 1f                	js     801571 <devfile_read+0x51>
	assert(r <= n);
  801552:	39 f0                	cmp    %esi,%eax
  801554:	77 24                	ja     80157a <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801556:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80155b:	7f 33                	jg     801590 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80155d:	83 ec 04             	sub    $0x4,%esp
  801560:	50                   	push   %eax
  801561:	68 00 50 80 00       	push   $0x805000
  801566:	ff 75 0c             	pushl  0xc(%ebp)
  801569:	e8 fe f3 ff ff       	call   80096c <memmove>
	return r;
  80156e:	83 c4 10             	add    $0x10,%esp
}
  801571:	89 d8                	mov    %ebx,%eax
  801573:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801576:	5b                   	pop    %ebx
  801577:	5e                   	pop    %esi
  801578:	5d                   	pop    %ebp
  801579:	c3                   	ret    
	assert(r <= n);
  80157a:	68 78 23 80 00       	push   $0x802378
  80157f:	68 7f 23 80 00       	push   $0x80237f
  801584:	6a 7c                	push   $0x7c
  801586:	68 94 23 80 00       	push   $0x802394
  80158b:	e8 be 05 00 00       	call   801b4e <_panic>
	assert(r <= PGSIZE);
  801590:	68 9f 23 80 00       	push   $0x80239f
  801595:	68 7f 23 80 00       	push   $0x80237f
  80159a:	6a 7d                	push   $0x7d
  80159c:	68 94 23 80 00       	push   $0x802394
  8015a1:	e8 a8 05 00 00       	call   801b4e <_panic>

008015a6 <open>:
{
  8015a6:	f3 0f 1e fb          	endbr32 
  8015aa:	55                   	push   %ebp
  8015ab:	89 e5                	mov    %esp,%ebp
  8015ad:	56                   	push   %esi
  8015ae:	53                   	push   %ebx
  8015af:	83 ec 1c             	sub    $0x1c,%esp
  8015b2:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8015b5:	56                   	push   %esi
  8015b6:	e8 b8 f1 ff ff       	call   800773 <strlen>
  8015bb:	83 c4 10             	add    $0x10,%esp
  8015be:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015c3:	7f 6c                	jg     801631 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  8015c5:	83 ec 0c             	sub    $0xc,%esp
  8015c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015cb:	50                   	push   %eax
  8015cc:	e8 67 f8 ff ff       	call   800e38 <fd_alloc>
  8015d1:	89 c3                	mov    %eax,%ebx
  8015d3:	83 c4 10             	add    $0x10,%esp
  8015d6:	85 c0                	test   %eax,%eax
  8015d8:	78 3c                	js     801616 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  8015da:	83 ec 08             	sub    $0x8,%esp
  8015dd:	56                   	push   %esi
  8015de:	68 00 50 80 00       	push   $0x805000
  8015e3:	e8 ce f1 ff ff       	call   8007b6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015eb:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8015f8:	e8 db fd ff ff       	call   8013d8 <fsipc>
  8015fd:	89 c3                	mov    %eax,%ebx
  8015ff:	83 c4 10             	add    $0x10,%esp
  801602:	85 c0                	test   %eax,%eax
  801604:	78 19                	js     80161f <open+0x79>
	return fd2num(fd);
  801606:	83 ec 0c             	sub    $0xc,%esp
  801609:	ff 75 f4             	pushl  -0xc(%ebp)
  80160c:	e8 f8 f7 ff ff       	call   800e09 <fd2num>
  801611:	89 c3                	mov    %eax,%ebx
  801613:	83 c4 10             	add    $0x10,%esp
}
  801616:	89 d8                	mov    %ebx,%eax
  801618:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80161b:	5b                   	pop    %ebx
  80161c:	5e                   	pop    %esi
  80161d:	5d                   	pop    %ebp
  80161e:	c3                   	ret    
		fd_close(fd, 0);
  80161f:	83 ec 08             	sub    $0x8,%esp
  801622:	6a 00                	push   $0x0
  801624:	ff 75 f4             	pushl  -0xc(%ebp)
  801627:	e8 10 f9 ff ff       	call   800f3c <fd_close>
		return r;
  80162c:	83 c4 10             	add    $0x10,%esp
  80162f:	eb e5                	jmp    801616 <open+0x70>
		return -E_BAD_PATH;
  801631:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801636:	eb de                	jmp    801616 <open+0x70>

00801638 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801638:	f3 0f 1e fb          	endbr32 
  80163c:	55                   	push   %ebp
  80163d:	89 e5                	mov    %esp,%ebp
  80163f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801642:	ba 00 00 00 00       	mov    $0x0,%edx
  801647:	b8 08 00 00 00       	mov    $0x8,%eax
  80164c:	e8 87 fd ff ff       	call   8013d8 <fsipc>
}
  801651:	c9                   	leave  
  801652:	c3                   	ret    

00801653 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801653:	f3 0f 1e fb          	endbr32 
  801657:	55                   	push   %ebp
  801658:	89 e5                	mov    %esp,%ebp
  80165a:	56                   	push   %esi
  80165b:	53                   	push   %ebx
  80165c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80165f:	83 ec 0c             	sub    $0xc,%esp
  801662:	ff 75 08             	pushl  0x8(%ebp)
  801665:	e8 b3 f7 ff ff       	call   800e1d <fd2data>
  80166a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80166c:	83 c4 08             	add    $0x8,%esp
  80166f:	68 ab 23 80 00       	push   $0x8023ab
  801674:	53                   	push   %ebx
  801675:	e8 3c f1 ff ff       	call   8007b6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80167a:	8b 46 04             	mov    0x4(%esi),%eax
  80167d:	2b 06                	sub    (%esi),%eax
  80167f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801685:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80168c:	00 00 00 
	stat->st_dev = &devpipe;
  80168f:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801696:	30 80 00 
	return 0;
}
  801699:	b8 00 00 00 00       	mov    $0x0,%eax
  80169e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016a1:	5b                   	pop    %ebx
  8016a2:	5e                   	pop    %esi
  8016a3:	5d                   	pop    %ebp
  8016a4:	c3                   	ret    

008016a5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016a5:	f3 0f 1e fb          	endbr32 
  8016a9:	55                   	push   %ebp
  8016aa:	89 e5                	mov    %esp,%ebp
  8016ac:	53                   	push   %ebx
  8016ad:	83 ec 0c             	sub    $0xc,%esp
  8016b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016b3:	53                   	push   %ebx
  8016b4:	6a 00                	push   $0x0
  8016b6:	e8 ca f5 ff ff       	call   800c85 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016bb:	89 1c 24             	mov    %ebx,(%esp)
  8016be:	e8 5a f7 ff ff       	call   800e1d <fd2data>
  8016c3:	83 c4 08             	add    $0x8,%esp
  8016c6:	50                   	push   %eax
  8016c7:	6a 00                	push   $0x0
  8016c9:	e8 b7 f5 ff ff       	call   800c85 <sys_page_unmap>
}
  8016ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d1:	c9                   	leave  
  8016d2:	c3                   	ret    

008016d3 <_pipeisclosed>:
{
  8016d3:	55                   	push   %ebp
  8016d4:	89 e5                	mov    %esp,%ebp
  8016d6:	57                   	push   %edi
  8016d7:	56                   	push   %esi
  8016d8:	53                   	push   %ebx
  8016d9:	83 ec 1c             	sub    $0x1c,%esp
  8016dc:	89 c7                	mov    %eax,%edi
  8016de:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8016e0:	a1 04 40 80 00       	mov    0x804004,%eax
  8016e5:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8016e8:	83 ec 0c             	sub    $0xc,%esp
  8016eb:	57                   	push   %edi
  8016ec:	e8 a1 05 00 00       	call   801c92 <pageref>
  8016f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016f4:	89 34 24             	mov    %esi,(%esp)
  8016f7:	e8 96 05 00 00       	call   801c92 <pageref>
		nn = thisenv->env_runs;
  8016fc:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801702:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801705:	83 c4 10             	add    $0x10,%esp
  801708:	39 cb                	cmp    %ecx,%ebx
  80170a:	74 1b                	je     801727 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  80170c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80170f:	75 cf                	jne    8016e0 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801711:	8b 42 58             	mov    0x58(%edx),%eax
  801714:	6a 01                	push   $0x1
  801716:	50                   	push   %eax
  801717:	53                   	push   %ebx
  801718:	68 b2 23 80 00       	push   $0x8023b2
  80171d:	e8 8b ea ff ff       	call   8001ad <cprintf>
  801722:	83 c4 10             	add    $0x10,%esp
  801725:	eb b9                	jmp    8016e0 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801727:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80172a:	0f 94 c0             	sete   %al
  80172d:	0f b6 c0             	movzbl %al,%eax
}
  801730:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801733:	5b                   	pop    %ebx
  801734:	5e                   	pop    %esi
  801735:	5f                   	pop    %edi
  801736:	5d                   	pop    %ebp
  801737:	c3                   	ret    

00801738 <devpipe_write>:
{
  801738:	f3 0f 1e fb          	endbr32 
  80173c:	55                   	push   %ebp
  80173d:	89 e5                	mov    %esp,%ebp
  80173f:	57                   	push   %edi
  801740:	56                   	push   %esi
  801741:	53                   	push   %ebx
  801742:	83 ec 28             	sub    $0x28,%esp
  801745:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801748:	56                   	push   %esi
  801749:	e8 cf f6 ff ff       	call   800e1d <fd2data>
  80174e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801750:	83 c4 10             	add    $0x10,%esp
  801753:	bf 00 00 00 00       	mov    $0x0,%edi
  801758:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80175b:	74 4f                	je     8017ac <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80175d:	8b 43 04             	mov    0x4(%ebx),%eax
  801760:	8b 0b                	mov    (%ebx),%ecx
  801762:	8d 51 20             	lea    0x20(%ecx),%edx
  801765:	39 d0                	cmp    %edx,%eax
  801767:	72 14                	jb     80177d <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801769:	89 da                	mov    %ebx,%edx
  80176b:	89 f0                	mov    %esi,%eax
  80176d:	e8 61 ff ff ff       	call   8016d3 <_pipeisclosed>
  801772:	85 c0                	test   %eax,%eax
  801774:	75 3b                	jne    8017b1 <devpipe_write+0x79>
			sys_yield();
  801776:	e8 5a f4 ff ff       	call   800bd5 <sys_yield>
  80177b:	eb e0                	jmp    80175d <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80177d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801780:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801784:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801787:	89 c2                	mov    %eax,%edx
  801789:	c1 fa 1f             	sar    $0x1f,%edx
  80178c:	89 d1                	mov    %edx,%ecx
  80178e:	c1 e9 1b             	shr    $0x1b,%ecx
  801791:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801794:	83 e2 1f             	and    $0x1f,%edx
  801797:	29 ca                	sub    %ecx,%edx
  801799:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80179d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017a1:	83 c0 01             	add    $0x1,%eax
  8017a4:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8017a7:	83 c7 01             	add    $0x1,%edi
  8017aa:	eb ac                	jmp    801758 <devpipe_write+0x20>
	return i;
  8017ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8017af:	eb 05                	jmp    8017b6 <devpipe_write+0x7e>
				return 0;
  8017b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017b9:	5b                   	pop    %ebx
  8017ba:	5e                   	pop    %esi
  8017bb:	5f                   	pop    %edi
  8017bc:	5d                   	pop    %ebp
  8017bd:	c3                   	ret    

008017be <devpipe_read>:
{
  8017be:	f3 0f 1e fb          	endbr32 
  8017c2:	55                   	push   %ebp
  8017c3:	89 e5                	mov    %esp,%ebp
  8017c5:	57                   	push   %edi
  8017c6:	56                   	push   %esi
  8017c7:	53                   	push   %ebx
  8017c8:	83 ec 18             	sub    $0x18,%esp
  8017cb:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8017ce:	57                   	push   %edi
  8017cf:	e8 49 f6 ff ff       	call   800e1d <fd2data>
  8017d4:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8017d6:	83 c4 10             	add    $0x10,%esp
  8017d9:	be 00 00 00 00       	mov    $0x0,%esi
  8017de:	3b 75 10             	cmp    0x10(%ebp),%esi
  8017e1:	75 14                	jne    8017f7 <devpipe_read+0x39>
	return i;
  8017e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8017e6:	eb 02                	jmp    8017ea <devpipe_read+0x2c>
				return i;
  8017e8:	89 f0                	mov    %esi,%eax
}
  8017ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017ed:	5b                   	pop    %ebx
  8017ee:	5e                   	pop    %esi
  8017ef:	5f                   	pop    %edi
  8017f0:	5d                   	pop    %ebp
  8017f1:	c3                   	ret    
			sys_yield();
  8017f2:	e8 de f3 ff ff       	call   800bd5 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8017f7:	8b 03                	mov    (%ebx),%eax
  8017f9:	3b 43 04             	cmp    0x4(%ebx),%eax
  8017fc:	75 18                	jne    801816 <devpipe_read+0x58>
			if (i > 0)
  8017fe:	85 f6                	test   %esi,%esi
  801800:	75 e6                	jne    8017e8 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801802:	89 da                	mov    %ebx,%edx
  801804:	89 f8                	mov    %edi,%eax
  801806:	e8 c8 fe ff ff       	call   8016d3 <_pipeisclosed>
  80180b:	85 c0                	test   %eax,%eax
  80180d:	74 e3                	je     8017f2 <devpipe_read+0x34>
				return 0;
  80180f:	b8 00 00 00 00       	mov    $0x0,%eax
  801814:	eb d4                	jmp    8017ea <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801816:	99                   	cltd   
  801817:	c1 ea 1b             	shr    $0x1b,%edx
  80181a:	01 d0                	add    %edx,%eax
  80181c:	83 e0 1f             	and    $0x1f,%eax
  80181f:	29 d0                	sub    %edx,%eax
  801821:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801826:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801829:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80182c:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80182f:	83 c6 01             	add    $0x1,%esi
  801832:	eb aa                	jmp    8017de <devpipe_read+0x20>

00801834 <pipe>:
{
  801834:	f3 0f 1e fb          	endbr32 
  801838:	55                   	push   %ebp
  801839:	89 e5                	mov    %esp,%ebp
  80183b:	56                   	push   %esi
  80183c:	53                   	push   %ebx
  80183d:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801840:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801843:	50                   	push   %eax
  801844:	e8 ef f5 ff ff       	call   800e38 <fd_alloc>
  801849:	89 c3                	mov    %eax,%ebx
  80184b:	83 c4 10             	add    $0x10,%esp
  80184e:	85 c0                	test   %eax,%eax
  801850:	0f 88 23 01 00 00    	js     801979 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801856:	83 ec 04             	sub    $0x4,%esp
  801859:	68 07 04 00 00       	push   $0x407
  80185e:	ff 75 f4             	pushl  -0xc(%ebp)
  801861:	6a 00                	push   $0x0
  801863:	e8 90 f3 ff ff       	call   800bf8 <sys_page_alloc>
  801868:	89 c3                	mov    %eax,%ebx
  80186a:	83 c4 10             	add    $0x10,%esp
  80186d:	85 c0                	test   %eax,%eax
  80186f:	0f 88 04 01 00 00    	js     801979 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801875:	83 ec 0c             	sub    $0xc,%esp
  801878:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80187b:	50                   	push   %eax
  80187c:	e8 b7 f5 ff ff       	call   800e38 <fd_alloc>
  801881:	89 c3                	mov    %eax,%ebx
  801883:	83 c4 10             	add    $0x10,%esp
  801886:	85 c0                	test   %eax,%eax
  801888:	0f 88 db 00 00 00    	js     801969 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80188e:	83 ec 04             	sub    $0x4,%esp
  801891:	68 07 04 00 00       	push   $0x407
  801896:	ff 75 f0             	pushl  -0x10(%ebp)
  801899:	6a 00                	push   $0x0
  80189b:	e8 58 f3 ff ff       	call   800bf8 <sys_page_alloc>
  8018a0:	89 c3                	mov    %eax,%ebx
  8018a2:	83 c4 10             	add    $0x10,%esp
  8018a5:	85 c0                	test   %eax,%eax
  8018a7:	0f 88 bc 00 00 00    	js     801969 <pipe+0x135>
	va = fd2data(fd0);
  8018ad:	83 ec 0c             	sub    $0xc,%esp
  8018b0:	ff 75 f4             	pushl  -0xc(%ebp)
  8018b3:	e8 65 f5 ff ff       	call   800e1d <fd2data>
  8018b8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018ba:	83 c4 0c             	add    $0xc,%esp
  8018bd:	68 07 04 00 00       	push   $0x407
  8018c2:	50                   	push   %eax
  8018c3:	6a 00                	push   $0x0
  8018c5:	e8 2e f3 ff ff       	call   800bf8 <sys_page_alloc>
  8018ca:	89 c3                	mov    %eax,%ebx
  8018cc:	83 c4 10             	add    $0x10,%esp
  8018cf:	85 c0                	test   %eax,%eax
  8018d1:	0f 88 82 00 00 00    	js     801959 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018d7:	83 ec 0c             	sub    $0xc,%esp
  8018da:	ff 75 f0             	pushl  -0x10(%ebp)
  8018dd:	e8 3b f5 ff ff       	call   800e1d <fd2data>
  8018e2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018e9:	50                   	push   %eax
  8018ea:	6a 00                	push   $0x0
  8018ec:	56                   	push   %esi
  8018ed:	6a 00                	push   $0x0
  8018ef:	e8 4b f3 ff ff       	call   800c3f <sys_page_map>
  8018f4:	89 c3                	mov    %eax,%ebx
  8018f6:	83 c4 20             	add    $0x20,%esp
  8018f9:	85 c0                	test   %eax,%eax
  8018fb:	78 4e                	js     80194b <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  8018fd:	a1 20 30 80 00       	mov    0x803020,%eax
  801902:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801905:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801907:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80190a:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801911:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801914:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801916:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801919:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801920:	83 ec 0c             	sub    $0xc,%esp
  801923:	ff 75 f4             	pushl  -0xc(%ebp)
  801926:	e8 de f4 ff ff       	call   800e09 <fd2num>
  80192b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80192e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801930:	83 c4 04             	add    $0x4,%esp
  801933:	ff 75 f0             	pushl  -0x10(%ebp)
  801936:	e8 ce f4 ff ff       	call   800e09 <fd2num>
  80193b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80193e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801941:	83 c4 10             	add    $0x10,%esp
  801944:	bb 00 00 00 00       	mov    $0x0,%ebx
  801949:	eb 2e                	jmp    801979 <pipe+0x145>
	sys_page_unmap(0, va);
  80194b:	83 ec 08             	sub    $0x8,%esp
  80194e:	56                   	push   %esi
  80194f:	6a 00                	push   $0x0
  801951:	e8 2f f3 ff ff       	call   800c85 <sys_page_unmap>
  801956:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801959:	83 ec 08             	sub    $0x8,%esp
  80195c:	ff 75 f0             	pushl  -0x10(%ebp)
  80195f:	6a 00                	push   $0x0
  801961:	e8 1f f3 ff ff       	call   800c85 <sys_page_unmap>
  801966:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801969:	83 ec 08             	sub    $0x8,%esp
  80196c:	ff 75 f4             	pushl  -0xc(%ebp)
  80196f:	6a 00                	push   $0x0
  801971:	e8 0f f3 ff ff       	call   800c85 <sys_page_unmap>
  801976:	83 c4 10             	add    $0x10,%esp
}
  801979:	89 d8                	mov    %ebx,%eax
  80197b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80197e:	5b                   	pop    %ebx
  80197f:	5e                   	pop    %esi
  801980:	5d                   	pop    %ebp
  801981:	c3                   	ret    

00801982 <pipeisclosed>:
{
  801982:	f3 0f 1e fb          	endbr32 
  801986:	55                   	push   %ebp
  801987:	89 e5                	mov    %esp,%ebp
  801989:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80198c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80198f:	50                   	push   %eax
  801990:	ff 75 08             	pushl  0x8(%ebp)
  801993:	e8 f6 f4 ff ff       	call   800e8e <fd_lookup>
  801998:	83 c4 10             	add    $0x10,%esp
  80199b:	85 c0                	test   %eax,%eax
  80199d:	78 18                	js     8019b7 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  80199f:	83 ec 0c             	sub    $0xc,%esp
  8019a2:	ff 75 f4             	pushl  -0xc(%ebp)
  8019a5:	e8 73 f4 ff ff       	call   800e1d <fd2data>
  8019aa:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  8019ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019af:	e8 1f fd ff ff       	call   8016d3 <_pipeisclosed>
  8019b4:	83 c4 10             	add    $0x10,%esp
}
  8019b7:	c9                   	leave  
  8019b8:	c3                   	ret    

008019b9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019b9:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  8019bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c2:	c3                   	ret    

008019c3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019c3:	f3 0f 1e fb          	endbr32 
  8019c7:	55                   	push   %ebp
  8019c8:	89 e5                	mov    %esp,%ebp
  8019ca:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019cd:	68 ca 23 80 00       	push   $0x8023ca
  8019d2:	ff 75 0c             	pushl  0xc(%ebp)
  8019d5:	e8 dc ed ff ff       	call   8007b6 <strcpy>
	return 0;
}
  8019da:	b8 00 00 00 00       	mov    $0x0,%eax
  8019df:	c9                   	leave  
  8019e0:	c3                   	ret    

008019e1 <devcons_write>:
{
  8019e1:	f3 0f 1e fb          	endbr32 
  8019e5:	55                   	push   %ebp
  8019e6:	89 e5                	mov    %esp,%ebp
  8019e8:	57                   	push   %edi
  8019e9:	56                   	push   %esi
  8019ea:	53                   	push   %ebx
  8019eb:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8019f1:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8019f6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8019fc:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019ff:	73 31                	jae    801a32 <devcons_write+0x51>
		m = n - tot;
  801a01:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a04:	29 f3                	sub    %esi,%ebx
  801a06:	83 fb 7f             	cmp    $0x7f,%ebx
  801a09:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801a0e:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801a11:	83 ec 04             	sub    $0x4,%esp
  801a14:	53                   	push   %ebx
  801a15:	89 f0                	mov    %esi,%eax
  801a17:	03 45 0c             	add    0xc(%ebp),%eax
  801a1a:	50                   	push   %eax
  801a1b:	57                   	push   %edi
  801a1c:	e8 4b ef ff ff       	call   80096c <memmove>
		sys_cputs(buf, m);
  801a21:	83 c4 08             	add    $0x8,%esp
  801a24:	53                   	push   %ebx
  801a25:	57                   	push   %edi
  801a26:	e8 fd f0 ff ff       	call   800b28 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801a2b:	01 de                	add    %ebx,%esi
  801a2d:	83 c4 10             	add    $0x10,%esp
  801a30:	eb ca                	jmp    8019fc <devcons_write+0x1b>
}
  801a32:	89 f0                	mov    %esi,%eax
  801a34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a37:	5b                   	pop    %ebx
  801a38:	5e                   	pop    %esi
  801a39:	5f                   	pop    %edi
  801a3a:	5d                   	pop    %ebp
  801a3b:	c3                   	ret    

00801a3c <devcons_read>:
{
  801a3c:	f3 0f 1e fb          	endbr32 
  801a40:	55                   	push   %ebp
  801a41:	89 e5                	mov    %esp,%ebp
  801a43:	83 ec 08             	sub    $0x8,%esp
  801a46:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801a4b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a4f:	74 21                	je     801a72 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801a51:	e8 f4 f0 ff ff       	call   800b4a <sys_cgetc>
  801a56:	85 c0                	test   %eax,%eax
  801a58:	75 07                	jne    801a61 <devcons_read+0x25>
		sys_yield();
  801a5a:	e8 76 f1 ff ff       	call   800bd5 <sys_yield>
  801a5f:	eb f0                	jmp    801a51 <devcons_read+0x15>
	if (c < 0)
  801a61:	78 0f                	js     801a72 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801a63:	83 f8 04             	cmp    $0x4,%eax
  801a66:	74 0c                	je     801a74 <devcons_read+0x38>
	*(char*)vbuf = c;
  801a68:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a6b:	88 02                	mov    %al,(%edx)
	return 1;
  801a6d:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801a72:	c9                   	leave  
  801a73:	c3                   	ret    
		return 0;
  801a74:	b8 00 00 00 00       	mov    $0x0,%eax
  801a79:	eb f7                	jmp    801a72 <devcons_read+0x36>

00801a7b <cputchar>:
{
  801a7b:	f3 0f 1e fb          	endbr32 
  801a7f:	55                   	push   %ebp
  801a80:	89 e5                	mov    %esp,%ebp
  801a82:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a85:	8b 45 08             	mov    0x8(%ebp),%eax
  801a88:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801a8b:	6a 01                	push   $0x1
  801a8d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a90:	50                   	push   %eax
  801a91:	e8 92 f0 ff ff       	call   800b28 <sys_cputs>
}
  801a96:	83 c4 10             	add    $0x10,%esp
  801a99:	c9                   	leave  
  801a9a:	c3                   	ret    

00801a9b <getchar>:
{
  801a9b:	f3 0f 1e fb          	endbr32 
  801a9f:	55                   	push   %ebp
  801aa0:	89 e5                	mov    %esp,%ebp
  801aa2:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801aa5:	6a 01                	push   $0x1
  801aa7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801aaa:	50                   	push   %eax
  801aab:	6a 00                	push   $0x0
  801aad:	e8 5f f6 ff ff       	call   801111 <read>
	if (r < 0)
  801ab2:	83 c4 10             	add    $0x10,%esp
  801ab5:	85 c0                	test   %eax,%eax
  801ab7:	78 06                	js     801abf <getchar+0x24>
	if (r < 1)
  801ab9:	74 06                	je     801ac1 <getchar+0x26>
	return c;
  801abb:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801abf:	c9                   	leave  
  801ac0:	c3                   	ret    
		return -E_EOF;
  801ac1:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801ac6:	eb f7                	jmp    801abf <getchar+0x24>

00801ac8 <iscons>:
{
  801ac8:	f3 0f 1e fb          	endbr32 
  801acc:	55                   	push   %ebp
  801acd:	89 e5                	mov    %esp,%ebp
  801acf:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ad2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ad5:	50                   	push   %eax
  801ad6:	ff 75 08             	pushl  0x8(%ebp)
  801ad9:	e8 b0 f3 ff ff       	call   800e8e <fd_lookup>
  801ade:	83 c4 10             	add    $0x10,%esp
  801ae1:	85 c0                	test   %eax,%eax
  801ae3:	78 11                	js     801af6 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801aee:	39 10                	cmp    %edx,(%eax)
  801af0:	0f 94 c0             	sete   %al
  801af3:	0f b6 c0             	movzbl %al,%eax
}
  801af6:	c9                   	leave  
  801af7:	c3                   	ret    

00801af8 <opencons>:
{
  801af8:	f3 0f 1e fb          	endbr32 
  801afc:	55                   	push   %ebp
  801afd:	89 e5                	mov    %esp,%ebp
  801aff:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801b02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b05:	50                   	push   %eax
  801b06:	e8 2d f3 ff ff       	call   800e38 <fd_alloc>
  801b0b:	83 c4 10             	add    $0x10,%esp
  801b0e:	85 c0                	test   %eax,%eax
  801b10:	78 3a                	js     801b4c <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b12:	83 ec 04             	sub    $0x4,%esp
  801b15:	68 07 04 00 00       	push   $0x407
  801b1a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b1d:	6a 00                	push   $0x0
  801b1f:	e8 d4 f0 ff ff       	call   800bf8 <sys_page_alloc>
  801b24:	83 c4 10             	add    $0x10,%esp
  801b27:	85 c0                	test   %eax,%eax
  801b29:	78 21                	js     801b4c <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b2e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b34:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b39:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b40:	83 ec 0c             	sub    $0xc,%esp
  801b43:	50                   	push   %eax
  801b44:	e8 c0 f2 ff ff       	call   800e09 <fd2num>
  801b49:	83 c4 10             	add    $0x10,%esp
}
  801b4c:	c9                   	leave  
  801b4d:	c3                   	ret    

00801b4e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b4e:	f3 0f 1e fb          	endbr32 
  801b52:	55                   	push   %ebp
  801b53:	89 e5                	mov    %esp,%ebp
  801b55:	56                   	push   %esi
  801b56:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801b57:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b5a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801b60:	e8 4d f0 ff ff       	call   800bb2 <sys_getenvid>
  801b65:	83 ec 0c             	sub    $0xc,%esp
  801b68:	ff 75 0c             	pushl  0xc(%ebp)
  801b6b:	ff 75 08             	pushl  0x8(%ebp)
  801b6e:	56                   	push   %esi
  801b6f:	50                   	push   %eax
  801b70:	68 d8 23 80 00       	push   $0x8023d8
  801b75:	e8 33 e6 ff ff       	call   8001ad <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b7a:	83 c4 18             	add    $0x18,%esp
  801b7d:	53                   	push   %ebx
  801b7e:	ff 75 10             	pushl  0x10(%ebp)
  801b81:	e8 d2 e5 ff ff       	call   800158 <vcprintf>
	cprintf("\n");
  801b86:	c7 04 24 c3 23 80 00 	movl   $0x8023c3,(%esp)
  801b8d:	e8 1b e6 ff ff       	call   8001ad <cprintf>
  801b92:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b95:	cc                   	int3   
  801b96:	eb fd                	jmp    801b95 <_panic+0x47>

00801b98 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b98:	f3 0f 1e fb          	endbr32 
  801b9c:	55                   	push   %ebp
  801b9d:	89 e5                	mov    %esp,%ebp
  801b9f:	56                   	push   %esi
  801ba0:	53                   	push   %ebx
  801ba1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801ba4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba7:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801baa:	85 c0                	test   %eax,%eax
  801bac:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801bb1:	0f 44 c2             	cmove  %edx,%eax
  801bb4:	83 ec 0c             	sub    $0xc,%esp
  801bb7:	50                   	push   %eax
  801bb8:	e8 07 f2 ff ff       	call   800dc4 <sys_ipc_recv>
  801bbd:	83 c4 10             	add    $0x10,%esp
  801bc0:	85 c0                	test   %eax,%eax
  801bc2:	78 24                	js     801be8 <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801bc4:	85 f6                	test   %esi,%esi
  801bc6:	74 0a                	je     801bd2 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801bc8:	a1 04 40 80 00       	mov    0x804004,%eax
  801bcd:	8b 40 78             	mov    0x78(%eax),%eax
  801bd0:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801bd2:	85 db                	test   %ebx,%ebx
  801bd4:	74 0a                	je     801be0 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801bd6:	a1 04 40 80 00       	mov    0x804004,%eax
  801bdb:	8b 40 74             	mov    0x74(%eax),%eax
  801bde:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801be0:	a1 04 40 80 00       	mov    0x804004,%eax
  801be5:	8b 40 70             	mov    0x70(%eax),%eax
}
  801be8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801beb:	5b                   	pop    %ebx
  801bec:	5e                   	pop    %esi
  801bed:	5d                   	pop    %ebp
  801bee:	c3                   	ret    

00801bef <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bef:	f3 0f 1e fb          	endbr32 
  801bf3:	55                   	push   %ebp
  801bf4:	89 e5                	mov    %esp,%ebp
  801bf6:	57                   	push   %edi
  801bf7:	56                   	push   %esi
  801bf8:	53                   	push   %ebx
  801bf9:	83 ec 1c             	sub    $0x1c,%esp
  801bfc:	8b 45 10             	mov    0x10(%ebp),%eax
  801bff:	85 c0                	test   %eax,%eax
  801c01:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801c06:	0f 45 d0             	cmovne %eax,%edx
  801c09:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801c0b:	be 01 00 00 00       	mov    $0x1,%esi
  801c10:	eb 1f                	jmp    801c31 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801c12:	e8 be ef ff ff       	call   800bd5 <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801c17:	83 c3 01             	add    $0x1,%ebx
  801c1a:	39 de                	cmp    %ebx,%esi
  801c1c:	7f f4                	jg     801c12 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801c1e:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801c20:	83 fe 11             	cmp    $0x11,%esi
  801c23:	b8 01 00 00 00       	mov    $0x1,%eax
  801c28:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801c2b:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801c2f:	75 1c                	jne    801c4d <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801c31:	ff 75 14             	pushl  0x14(%ebp)
  801c34:	57                   	push   %edi
  801c35:	ff 75 0c             	pushl  0xc(%ebp)
  801c38:	ff 75 08             	pushl  0x8(%ebp)
  801c3b:	e8 5d f1 ff ff       	call   800d9d <sys_ipc_try_send>
  801c40:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801c43:	83 c4 10             	add    $0x10,%esp
  801c46:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c4b:	eb cd                	jmp    801c1a <ipc_send+0x2b>
}
  801c4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c50:	5b                   	pop    %ebx
  801c51:	5e                   	pop    %esi
  801c52:	5f                   	pop    %edi
  801c53:	5d                   	pop    %ebp
  801c54:	c3                   	ret    

00801c55 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c55:	f3 0f 1e fb          	endbr32 
  801c59:	55                   	push   %ebp
  801c5a:	89 e5                	mov    %esp,%ebp
  801c5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c5f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c64:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c67:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c6d:	8b 52 50             	mov    0x50(%edx),%edx
  801c70:	39 ca                	cmp    %ecx,%edx
  801c72:	74 11                	je     801c85 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801c74:	83 c0 01             	add    $0x1,%eax
  801c77:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c7c:	75 e6                	jne    801c64 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801c7e:	b8 00 00 00 00       	mov    $0x0,%eax
  801c83:	eb 0b                	jmp    801c90 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801c85:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c88:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c8d:	8b 40 48             	mov    0x48(%eax),%eax
}
  801c90:	5d                   	pop    %ebp
  801c91:	c3                   	ret    

00801c92 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c92:	f3 0f 1e fb          	endbr32 
  801c96:	55                   	push   %ebp
  801c97:	89 e5                	mov    %esp,%ebp
  801c99:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c9c:	89 c2                	mov    %eax,%edx
  801c9e:	c1 ea 16             	shr    $0x16,%edx
  801ca1:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801ca8:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801cad:	f6 c1 01             	test   $0x1,%cl
  801cb0:	74 1c                	je     801cce <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801cb2:	c1 e8 0c             	shr    $0xc,%eax
  801cb5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801cbc:	a8 01                	test   $0x1,%al
  801cbe:	74 0e                	je     801cce <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801cc0:	c1 e8 0c             	shr    $0xc,%eax
  801cc3:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801cca:	ef 
  801ccb:	0f b7 d2             	movzwl %dx,%edx
}
  801cce:	89 d0                	mov    %edx,%eax
  801cd0:	5d                   	pop    %ebp
  801cd1:	c3                   	ret    
  801cd2:	66 90                	xchg   %ax,%ax
  801cd4:	66 90                	xchg   %ax,%ax
  801cd6:	66 90                	xchg   %ax,%ax
  801cd8:	66 90                	xchg   %ax,%ax
  801cda:	66 90                	xchg   %ax,%ax
  801cdc:	66 90                	xchg   %ax,%ax
  801cde:	66 90                	xchg   %ax,%ax

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
