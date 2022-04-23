
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
  80003e:	a1 04 20 80 00       	mov    0x802004,%eax
  800043:	8b 40 48             	mov    0x48(%eax),%eax
  800046:	50                   	push   %eax
  800047:	68 a0 10 80 00       	push   $0x8010a0
  80004c:	e8 54 01 00 00       	call   8001a5 <cprintf>
  800051:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800054:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800059:	e8 6f 0b 00 00       	call   800bcd <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005e:	a1 04 20 80 00       	mov    0x802004,%eax
		cprintf("Back in environment %08x, iteration %d.\n",
  800063:	8b 40 48             	mov    0x48(%eax),%eax
  800066:	83 ec 04             	sub    $0x4,%esp
  800069:	53                   	push   %ebx
  80006a:	50                   	push   %eax
  80006b:	68 c0 10 80 00       	push   $0x8010c0
  800070:	e8 30 01 00 00       	call   8001a5 <cprintf>
	for (i = 0; i < 5; i++) {
  800075:	83 c3 01             	add    $0x1,%ebx
  800078:	83 c4 10             	add    $0x10,%esp
  80007b:	83 fb 05             	cmp    $0x5,%ebx
  80007e:	75 d9                	jne    800059 <umain+0x26>
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  800080:	a1 04 20 80 00       	mov    0x802004,%eax
  800085:	8b 40 48             	mov    0x48(%eax),%eax
  800088:	83 ec 08             	sub    $0x8,%esp
  80008b:	50                   	push   %eax
  80008c:	68 ec 10 80 00       	push   $0x8010ec
  800091:	e8 0f 01 00 00       	call   8001a5 <cprintf>
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
  8000ad:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000b4:	00 00 00 
    envid_t envid = sys_getenvid();
  8000b7:	e8 ee 0a 00 00       	call   800baa <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  8000bc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000c1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000c4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c9:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ce:	85 db                	test   %ebx,%ebx
  8000d0:	7e 07                	jle    8000d9 <libmain+0x3b>
		binaryname = argv[0];
  8000d2:	8b 06                	mov    (%esi),%eax
  8000d4:	a3 00 20 80 00       	mov    %eax,0x802000

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
  8000f9:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  8000fc:	6a 00                	push   $0x0
  8000fe:	e8 62 0a 00 00       	call   800b65 <sys_env_destroy>
}
  800103:	83 c4 10             	add    $0x10,%esp
  800106:	c9                   	leave  
  800107:	c3                   	ret    

00800108 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800108:	f3 0f 1e fb          	endbr32 
  80010c:	55                   	push   %ebp
  80010d:	89 e5                	mov    %esp,%ebp
  80010f:	53                   	push   %ebx
  800110:	83 ec 04             	sub    $0x4,%esp
  800113:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800116:	8b 13                	mov    (%ebx),%edx
  800118:	8d 42 01             	lea    0x1(%edx),%eax
  80011b:	89 03                	mov    %eax,(%ebx)
  80011d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800120:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800124:	3d ff 00 00 00       	cmp    $0xff,%eax
  800129:	74 09                	je     800134 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80012b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80012f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800132:	c9                   	leave  
  800133:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800134:	83 ec 08             	sub    $0x8,%esp
  800137:	68 ff 00 00 00       	push   $0xff
  80013c:	8d 43 08             	lea    0x8(%ebx),%eax
  80013f:	50                   	push   %eax
  800140:	e8 db 09 00 00       	call   800b20 <sys_cputs>
		b->idx = 0;
  800145:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80014b:	83 c4 10             	add    $0x10,%esp
  80014e:	eb db                	jmp    80012b <putch+0x23>

00800150 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800150:	f3 0f 1e fb          	endbr32 
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80015d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800164:	00 00 00 
	b.cnt = 0;
  800167:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80016e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800171:	ff 75 0c             	pushl  0xc(%ebp)
  800174:	ff 75 08             	pushl  0x8(%ebp)
  800177:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80017d:	50                   	push   %eax
  80017e:	68 08 01 80 00       	push   $0x800108
  800183:	e8 20 01 00 00       	call   8002a8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800188:	83 c4 08             	add    $0x8,%esp
  80018b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800191:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800197:	50                   	push   %eax
  800198:	e8 83 09 00 00       	call   800b20 <sys_cputs>

	return b.cnt;
}
  80019d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a3:	c9                   	leave  
  8001a4:	c3                   	ret    

008001a5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a5:	f3 0f 1e fb          	endbr32 
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001af:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b2:	50                   	push   %eax
  8001b3:	ff 75 08             	pushl  0x8(%ebp)
  8001b6:	e8 95 ff ff ff       	call   800150 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001bb:	c9                   	leave  
  8001bc:	c3                   	ret    

008001bd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
  8001c0:	57                   	push   %edi
  8001c1:	56                   	push   %esi
  8001c2:	53                   	push   %ebx
  8001c3:	83 ec 1c             	sub    $0x1c,%esp
  8001c6:	89 c7                	mov    %eax,%edi
  8001c8:	89 d6                	mov    %edx,%esi
  8001ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d0:	89 d1                	mov    %edx,%ecx
  8001d2:	89 c2                	mov    %eax,%edx
  8001d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001da:	8b 45 10             	mov    0x10(%ebp),%eax
  8001dd:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001e3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001ea:	39 c2                	cmp    %eax,%edx
  8001ec:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001ef:	72 3e                	jb     80022f <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f1:	83 ec 0c             	sub    $0xc,%esp
  8001f4:	ff 75 18             	pushl  0x18(%ebp)
  8001f7:	83 eb 01             	sub    $0x1,%ebx
  8001fa:	53                   	push   %ebx
  8001fb:	50                   	push   %eax
  8001fc:	83 ec 08             	sub    $0x8,%esp
  8001ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  800202:	ff 75 e0             	pushl  -0x20(%ebp)
  800205:	ff 75 dc             	pushl  -0x24(%ebp)
  800208:	ff 75 d8             	pushl  -0x28(%ebp)
  80020b:	e8 20 0c 00 00       	call   800e30 <__udivdi3>
  800210:	83 c4 18             	add    $0x18,%esp
  800213:	52                   	push   %edx
  800214:	50                   	push   %eax
  800215:	89 f2                	mov    %esi,%edx
  800217:	89 f8                	mov    %edi,%eax
  800219:	e8 9f ff ff ff       	call   8001bd <printnum>
  80021e:	83 c4 20             	add    $0x20,%esp
  800221:	eb 13                	jmp    800236 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800223:	83 ec 08             	sub    $0x8,%esp
  800226:	56                   	push   %esi
  800227:	ff 75 18             	pushl  0x18(%ebp)
  80022a:	ff d7                	call   *%edi
  80022c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80022f:	83 eb 01             	sub    $0x1,%ebx
  800232:	85 db                	test   %ebx,%ebx
  800234:	7f ed                	jg     800223 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800236:	83 ec 08             	sub    $0x8,%esp
  800239:	56                   	push   %esi
  80023a:	83 ec 04             	sub    $0x4,%esp
  80023d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800240:	ff 75 e0             	pushl  -0x20(%ebp)
  800243:	ff 75 dc             	pushl  -0x24(%ebp)
  800246:	ff 75 d8             	pushl  -0x28(%ebp)
  800249:	e8 f2 0c 00 00       	call   800f40 <__umoddi3>
  80024e:	83 c4 14             	add    $0x14,%esp
  800251:	0f be 80 15 11 80 00 	movsbl 0x801115(%eax),%eax
  800258:	50                   	push   %eax
  800259:	ff d7                	call   *%edi
}
  80025b:	83 c4 10             	add    $0x10,%esp
  80025e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800261:	5b                   	pop    %ebx
  800262:	5e                   	pop    %esi
  800263:	5f                   	pop    %edi
  800264:	5d                   	pop    %ebp
  800265:	c3                   	ret    

00800266 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800266:	f3 0f 1e fb          	endbr32 
  80026a:	55                   	push   %ebp
  80026b:	89 e5                	mov    %esp,%ebp
  80026d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800270:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800274:	8b 10                	mov    (%eax),%edx
  800276:	3b 50 04             	cmp    0x4(%eax),%edx
  800279:	73 0a                	jae    800285 <sprintputch+0x1f>
		*b->buf++ = ch;
  80027b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80027e:	89 08                	mov    %ecx,(%eax)
  800280:	8b 45 08             	mov    0x8(%ebp),%eax
  800283:	88 02                	mov    %al,(%edx)
}
  800285:	5d                   	pop    %ebp
  800286:	c3                   	ret    

00800287 <printfmt>:
{
  800287:	f3 0f 1e fb          	endbr32 
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800291:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800294:	50                   	push   %eax
  800295:	ff 75 10             	pushl  0x10(%ebp)
  800298:	ff 75 0c             	pushl  0xc(%ebp)
  80029b:	ff 75 08             	pushl  0x8(%ebp)
  80029e:	e8 05 00 00 00       	call   8002a8 <vprintfmt>
}
  8002a3:	83 c4 10             	add    $0x10,%esp
  8002a6:	c9                   	leave  
  8002a7:	c3                   	ret    

008002a8 <vprintfmt>:
{
  8002a8:	f3 0f 1e fb          	endbr32 
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
  8002af:	57                   	push   %edi
  8002b0:	56                   	push   %esi
  8002b1:	53                   	push   %ebx
  8002b2:	83 ec 3c             	sub    $0x3c,%esp
  8002b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002bb:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002be:	e9 4a 03 00 00       	jmp    80060d <vprintfmt+0x365>
		padc = ' ';
  8002c3:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002c7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002ce:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002d5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002dc:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002e1:	8d 47 01             	lea    0x1(%edi),%eax
  8002e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e7:	0f b6 17             	movzbl (%edi),%edx
  8002ea:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002ed:	3c 55                	cmp    $0x55,%al
  8002ef:	0f 87 de 03 00 00    	ja     8006d3 <vprintfmt+0x42b>
  8002f5:	0f b6 c0             	movzbl %al,%eax
  8002f8:	3e ff 24 85 60 12 80 	notrack jmp *0x801260(,%eax,4)
  8002ff:	00 
  800300:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800303:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800307:	eb d8                	jmp    8002e1 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800309:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80030c:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800310:	eb cf                	jmp    8002e1 <vprintfmt+0x39>
  800312:	0f b6 d2             	movzbl %dl,%edx
  800315:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800318:	b8 00 00 00 00       	mov    $0x0,%eax
  80031d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800320:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800323:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800327:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80032a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80032d:	83 f9 09             	cmp    $0x9,%ecx
  800330:	77 55                	ja     800387 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800332:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800335:	eb e9                	jmp    800320 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800337:	8b 45 14             	mov    0x14(%ebp),%eax
  80033a:	8b 00                	mov    (%eax),%eax
  80033c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80033f:	8b 45 14             	mov    0x14(%ebp),%eax
  800342:	8d 40 04             	lea    0x4(%eax),%eax
  800345:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800348:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80034b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80034f:	79 90                	jns    8002e1 <vprintfmt+0x39>
				width = precision, precision = -1;
  800351:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800354:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800357:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80035e:	eb 81                	jmp    8002e1 <vprintfmt+0x39>
  800360:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800363:	85 c0                	test   %eax,%eax
  800365:	ba 00 00 00 00       	mov    $0x0,%edx
  80036a:	0f 49 d0             	cmovns %eax,%edx
  80036d:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800370:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800373:	e9 69 ff ff ff       	jmp    8002e1 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800378:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80037b:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800382:	e9 5a ff ff ff       	jmp    8002e1 <vprintfmt+0x39>
  800387:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80038a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80038d:	eb bc                	jmp    80034b <vprintfmt+0xa3>
			lflag++;
  80038f:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800392:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800395:	e9 47 ff ff ff       	jmp    8002e1 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80039a:	8b 45 14             	mov    0x14(%ebp),%eax
  80039d:	8d 78 04             	lea    0x4(%eax),%edi
  8003a0:	83 ec 08             	sub    $0x8,%esp
  8003a3:	53                   	push   %ebx
  8003a4:	ff 30                	pushl  (%eax)
  8003a6:	ff d6                	call   *%esi
			break;
  8003a8:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003ab:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003ae:	e9 57 02 00 00       	jmp    80060a <vprintfmt+0x362>
			err = va_arg(ap, int);
  8003b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b6:	8d 78 04             	lea    0x4(%eax),%edi
  8003b9:	8b 00                	mov    (%eax),%eax
  8003bb:	99                   	cltd   
  8003bc:	31 d0                	xor    %edx,%eax
  8003be:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c0:	83 f8 0f             	cmp    $0xf,%eax
  8003c3:	7f 23                	jg     8003e8 <vprintfmt+0x140>
  8003c5:	8b 14 85 c0 13 80 00 	mov    0x8013c0(,%eax,4),%edx
  8003cc:	85 d2                	test   %edx,%edx
  8003ce:	74 18                	je     8003e8 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8003d0:	52                   	push   %edx
  8003d1:	68 36 11 80 00       	push   $0x801136
  8003d6:	53                   	push   %ebx
  8003d7:	56                   	push   %esi
  8003d8:	e8 aa fe ff ff       	call   800287 <printfmt>
  8003dd:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003e0:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003e3:	e9 22 02 00 00       	jmp    80060a <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8003e8:	50                   	push   %eax
  8003e9:	68 2d 11 80 00       	push   $0x80112d
  8003ee:	53                   	push   %ebx
  8003ef:	56                   	push   %esi
  8003f0:	e8 92 fe ff ff       	call   800287 <printfmt>
  8003f5:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003f8:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003fb:	e9 0a 02 00 00       	jmp    80060a <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  800400:	8b 45 14             	mov    0x14(%ebp),%eax
  800403:	83 c0 04             	add    $0x4,%eax
  800406:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800409:	8b 45 14             	mov    0x14(%ebp),%eax
  80040c:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80040e:	85 d2                	test   %edx,%edx
  800410:	b8 26 11 80 00       	mov    $0x801126,%eax
  800415:	0f 45 c2             	cmovne %edx,%eax
  800418:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80041b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80041f:	7e 06                	jle    800427 <vprintfmt+0x17f>
  800421:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800425:	75 0d                	jne    800434 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800427:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80042a:	89 c7                	mov    %eax,%edi
  80042c:	03 45 e0             	add    -0x20(%ebp),%eax
  80042f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800432:	eb 55                	jmp    800489 <vprintfmt+0x1e1>
  800434:	83 ec 08             	sub    $0x8,%esp
  800437:	ff 75 d8             	pushl  -0x28(%ebp)
  80043a:	ff 75 cc             	pushl  -0x34(%ebp)
  80043d:	e8 45 03 00 00       	call   800787 <strnlen>
  800442:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800445:	29 c2                	sub    %eax,%edx
  800447:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80044a:	83 c4 10             	add    $0x10,%esp
  80044d:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80044f:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800453:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800456:	85 ff                	test   %edi,%edi
  800458:	7e 11                	jle    80046b <vprintfmt+0x1c3>
					putch(padc, putdat);
  80045a:	83 ec 08             	sub    $0x8,%esp
  80045d:	53                   	push   %ebx
  80045e:	ff 75 e0             	pushl  -0x20(%ebp)
  800461:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800463:	83 ef 01             	sub    $0x1,%edi
  800466:	83 c4 10             	add    $0x10,%esp
  800469:	eb eb                	jmp    800456 <vprintfmt+0x1ae>
  80046b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80046e:	85 d2                	test   %edx,%edx
  800470:	b8 00 00 00 00       	mov    $0x0,%eax
  800475:	0f 49 c2             	cmovns %edx,%eax
  800478:	29 c2                	sub    %eax,%edx
  80047a:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80047d:	eb a8                	jmp    800427 <vprintfmt+0x17f>
					putch(ch, putdat);
  80047f:	83 ec 08             	sub    $0x8,%esp
  800482:	53                   	push   %ebx
  800483:	52                   	push   %edx
  800484:	ff d6                	call   *%esi
  800486:	83 c4 10             	add    $0x10,%esp
  800489:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80048c:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80048e:	83 c7 01             	add    $0x1,%edi
  800491:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800495:	0f be d0             	movsbl %al,%edx
  800498:	85 d2                	test   %edx,%edx
  80049a:	74 4b                	je     8004e7 <vprintfmt+0x23f>
  80049c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004a0:	78 06                	js     8004a8 <vprintfmt+0x200>
  8004a2:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004a6:	78 1e                	js     8004c6 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004a8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004ac:	74 d1                	je     80047f <vprintfmt+0x1d7>
  8004ae:	0f be c0             	movsbl %al,%eax
  8004b1:	83 e8 20             	sub    $0x20,%eax
  8004b4:	83 f8 5e             	cmp    $0x5e,%eax
  8004b7:	76 c6                	jbe    80047f <vprintfmt+0x1d7>
					putch('?', putdat);
  8004b9:	83 ec 08             	sub    $0x8,%esp
  8004bc:	53                   	push   %ebx
  8004bd:	6a 3f                	push   $0x3f
  8004bf:	ff d6                	call   *%esi
  8004c1:	83 c4 10             	add    $0x10,%esp
  8004c4:	eb c3                	jmp    800489 <vprintfmt+0x1e1>
  8004c6:	89 cf                	mov    %ecx,%edi
  8004c8:	eb 0e                	jmp    8004d8 <vprintfmt+0x230>
				putch(' ', putdat);
  8004ca:	83 ec 08             	sub    $0x8,%esp
  8004cd:	53                   	push   %ebx
  8004ce:	6a 20                	push   $0x20
  8004d0:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004d2:	83 ef 01             	sub    $0x1,%edi
  8004d5:	83 c4 10             	add    $0x10,%esp
  8004d8:	85 ff                	test   %edi,%edi
  8004da:	7f ee                	jg     8004ca <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8004dc:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004df:	89 45 14             	mov    %eax,0x14(%ebp)
  8004e2:	e9 23 01 00 00       	jmp    80060a <vprintfmt+0x362>
  8004e7:	89 cf                	mov    %ecx,%edi
  8004e9:	eb ed                	jmp    8004d8 <vprintfmt+0x230>
	if (lflag >= 2)
  8004eb:	83 f9 01             	cmp    $0x1,%ecx
  8004ee:	7f 1b                	jg     80050b <vprintfmt+0x263>
	else if (lflag)
  8004f0:	85 c9                	test   %ecx,%ecx
  8004f2:	74 63                	je     800557 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8004f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f7:	8b 00                	mov    (%eax),%eax
  8004f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004fc:	99                   	cltd   
  8004fd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800500:	8b 45 14             	mov    0x14(%ebp),%eax
  800503:	8d 40 04             	lea    0x4(%eax),%eax
  800506:	89 45 14             	mov    %eax,0x14(%ebp)
  800509:	eb 17                	jmp    800522 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80050b:	8b 45 14             	mov    0x14(%ebp),%eax
  80050e:	8b 50 04             	mov    0x4(%eax),%edx
  800511:	8b 00                	mov    (%eax),%eax
  800513:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800516:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800519:	8b 45 14             	mov    0x14(%ebp),%eax
  80051c:	8d 40 08             	lea    0x8(%eax),%eax
  80051f:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800522:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800525:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800528:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80052d:	85 c9                	test   %ecx,%ecx
  80052f:	0f 89 bb 00 00 00    	jns    8005f0 <vprintfmt+0x348>
				putch('-', putdat);
  800535:	83 ec 08             	sub    $0x8,%esp
  800538:	53                   	push   %ebx
  800539:	6a 2d                	push   $0x2d
  80053b:	ff d6                	call   *%esi
				num = -(long long) num;
  80053d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800540:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800543:	f7 da                	neg    %edx
  800545:	83 d1 00             	adc    $0x0,%ecx
  800548:	f7 d9                	neg    %ecx
  80054a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80054d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800552:	e9 99 00 00 00       	jmp    8005f0 <vprintfmt+0x348>
		return va_arg(*ap, int);
  800557:	8b 45 14             	mov    0x14(%ebp),%eax
  80055a:	8b 00                	mov    (%eax),%eax
  80055c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055f:	99                   	cltd   
  800560:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800563:	8b 45 14             	mov    0x14(%ebp),%eax
  800566:	8d 40 04             	lea    0x4(%eax),%eax
  800569:	89 45 14             	mov    %eax,0x14(%ebp)
  80056c:	eb b4                	jmp    800522 <vprintfmt+0x27a>
	if (lflag >= 2)
  80056e:	83 f9 01             	cmp    $0x1,%ecx
  800571:	7f 1b                	jg     80058e <vprintfmt+0x2e6>
	else if (lflag)
  800573:	85 c9                	test   %ecx,%ecx
  800575:	74 2c                	je     8005a3 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8b 10                	mov    (%eax),%edx
  80057c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800581:	8d 40 04             	lea    0x4(%eax),%eax
  800584:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800587:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80058c:	eb 62                	jmp    8005f0 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80058e:	8b 45 14             	mov    0x14(%ebp),%eax
  800591:	8b 10                	mov    (%eax),%edx
  800593:	8b 48 04             	mov    0x4(%eax),%ecx
  800596:	8d 40 08             	lea    0x8(%eax),%eax
  800599:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80059c:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005a1:	eb 4d                	jmp    8005f0 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8005a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a6:	8b 10                	mov    (%eax),%edx
  8005a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ad:	8d 40 04             	lea    0x4(%eax),%eax
  8005b0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005b3:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8005b8:	eb 36                	jmp    8005f0 <vprintfmt+0x348>
	if (lflag >= 2)
  8005ba:	83 f9 01             	cmp    $0x1,%ecx
  8005bd:	7f 17                	jg     8005d6 <vprintfmt+0x32e>
	else if (lflag)
  8005bf:	85 c9                	test   %ecx,%ecx
  8005c1:	74 6e                	je     800631 <vprintfmt+0x389>
		return va_arg(*ap, long);
  8005c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c6:	8b 10                	mov    (%eax),%edx
  8005c8:	89 d0                	mov    %edx,%eax
  8005ca:	99                   	cltd   
  8005cb:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005ce:	8d 49 04             	lea    0x4(%ecx),%ecx
  8005d1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005d4:	eb 11                	jmp    8005e7 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8005d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d9:	8b 50 04             	mov    0x4(%eax),%edx
  8005dc:	8b 00                	mov    (%eax),%eax
  8005de:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005e1:	8d 49 08             	lea    0x8(%ecx),%ecx
  8005e4:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8005e7:	89 d1                	mov    %edx,%ecx
  8005e9:	89 c2                	mov    %eax,%edx
            base = 8;
  8005eb:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005f0:	83 ec 0c             	sub    $0xc,%esp
  8005f3:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005f7:	57                   	push   %edi
  8005f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8005fb:	50                   	push   %eax
  8005fc:	51                   	push   %ecx
  8005fd:	52                   	push   %edx
  8005fe:	89 da                	mov    %ebx,%edx
  800600:	89 f0                	mov    %esi,%eax
  800602:	e8 b6 fb ff ff       	call   8001bd <printnum>
			break;
  800607:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80060a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80060d:	83 c7 01             	add    $0x1,%edi
  800610:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800614:	83 f8 25             	cmp    $0x25,%eax
  800617:	0f 84 a6 fc ff ff    	je     8002c3 <vprintfmt+0x1b>
			if (ch == '\0')
  80061d:	85 c0                	test   %eax,%eax
  80061f:	0f 84 ce 00 00 00    	je     8006f3 <vprintfmt+0x44b>
			putch(ch, putdat);
  800625:	83 ec 08             	sub    $0x8,%esp
  800628:	53                   	push   %ebx
  800629:	50                   	push   %eax
  80062a:	ff d6                	call   *%esi
  80062c:	83 c4 10             	add    $0x10,%esp
  80062f:	eb dc                	jmp    80060d <vprintfmt+0x365>
		return va_arg(*ap, int);
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8b 10                	mov    (%eax),%edx
  800636:	89 d0                	mov    %edx,%eax
  800638:	99                   	cltd   
  800639:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80063c:	8d 49 04             	lea    0x4(%ecx),%ecx
  80063f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800642:	eb a3                	jmp    8005e7 <vprintfmt+0x33f>
			putch('0', putdat);
  800644:	83 ec 08             	sub    $0x8,%esp
  800647:	53                   	push   %ebx
  800648:	6a 30                	push   $0x30
  80064a:	ff d6                	call   *%esi
			putch('x', putdat);
  80064c:	83 c4 08             	add    $0x8,%esp
  80064f:	53                   	push   %ebx
  800650:	6a 78                	push   $0x78
  800652:	ff d6                	call   *%esi
			num = (unsigned long long)
  800654:	8b 45 14             	mov    0x14(%ebp),%eax
  800657:	8b 10                	mov    (%eax),%edx
  800659:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80065e:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800661:	8d 40 04             	lea    0x4(%eax),%eax
  800664:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800667:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80066c:	eb 82                	jmp    8005f0 <vprintfmt+0x348>
	if (lflag >= 2)
  80066e:	83 f9 01             	cmp    $0x1,%ecx
  800671:	7f 1e                	jg     800691 <vprintfmt+0x3e9>
	else if (lflag)
  800673:	85 c9                	test   %ecx,%ecx
  800675:	74 32                	je     8006a9 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	8b 10                	mov    (%eax),%edx
  80067c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800681:	8d 40 04             	lea    0x4(%eax),%eax
  800684:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800687:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80068c:	e9 5f ff ff ff       	jmp    8005f0 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800691:	8b 45 14             	mov    0x14(%ebp),%eax
  800694:	8b 10                	mov    (%eax),%edx
  800696:	8b 48 04             	mov    0x4(%eax),%ecx
  800699:	8d 40 08             	lea    0x8(%eax),%eax
  80069c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80069f:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006a4:	e9 47 ff ff ff       	jmp    8005f0 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8006a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ac:	8b 10                	mov    (%eax),%edx
  8006ae:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b3:	8d 40 04             	lea    0x4(%eax),%eax
  8006b6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b9:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006be:	e9 2d ff ff ff       	jmp    8005f0 <vprintfmt+0x348>
			putch(ch, putdat);
  8006c3:	83 ec 08             	sub    $0x8,%esp
  8006c6:	53                   	push   %ebx
  8006c7:	6a 25                	push   $0x25
  8006c9:	ff d6                	call   *%esi
			break;
  8006cb:	83 c4 10             	add    $0x10,%esp
  8006ce:	e9 37 ff ff ff       	jmp    80060a <vprintfmt+0x362>
			putch('%', putdat);
  8006d3:	83 ec 08             	sub    $0x8,%esp
  8006d6:	53                   	push   %ebx
  8006d7:	6a 25                	push   $0x25
  8006d9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006db:	83 c4 10             	add    $0x10,%esp
  8006de:	89 f8                	mov    %edi,%eax
  8006e0:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006e4:	74 05                	je     8006eb <vprintfmt+0x443>
  8006e6:	83 e8 01             	sub    $0x1,%eax
  8006e9:	eb f5                	jmp    8006e0 <vprintfmt+0x438>
  8006eb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006ee:	e9 17 ff ff ff       	jmp    80060a <vprintfmt+0x362>
}
  8006f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f6:	5b                   	pop    %ebx
  8006f7:	5e                   	pop    %esi
  8006f8:	5f                   	pop    %edi
  8006f9:	5d                   	pop    %ebp
  8006fa:	c3                   	ret    

008006fb <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006fb:	f3 0f 1e fb          	endbr32 
  8006ff:	55                   	push   %ebp
  800700:	89 e5                	mov    %esp,%ebp
  800702:	83 ec 18             	sub    $0x18,%esp
  800705:	8b 45 08             	mov    0x8(%ebp),%eax
  800708:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80070b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80070e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800712:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800715:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80071c:	85 c0                	test   %eax,%eax
  80071e:	74 26                	je     800746 <vsnprintf+0x4b>
  800720:	85 d2                	test   %edx,%edx
  800722:	7e 22                	jle    800746 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800724:	ff 75 14             	pushl  0x14(%ebp)
  800727:	ff 75 10             	pushl  0x10(%ebp)
  80072a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80072d:	50                   	push   %eax
  80072e:	68 66 02 80 00       	push   $0x800266
  800733:	e8 70 fb ff ff       	call   8002a8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800738:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80073b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80073e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800741:	83 c4 10             	add    $0x10,%esp
}
  800744:	c9                   	leave  
  800745:	c3                   	ret    
		return -E_INVAL;
  800746:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80074b:	eb f7                	jmp    800744 <vsnprintf+0x49>

0080074d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80074d:	f3 0f 1e fb          	endbr32 
  800751:	55                   	push   %ebp
  800752:	89 e5                	mov    %esp,%ebp
  800754:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800757:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80075a:	50                   	push   %eax
  80075b:	ff 75 10             	pushl  0x10(%ebp)
  80075e:	ff 75 0c             	pushl  0xc(%ebp)
  800761:	ff 75 08             	pushl  0x8(%ebp)
  800764:	e8 92 ff ff ff       	call   8006fb <vsnprintf>
	va_end(ap);

	return rc;
}
  800769:	c9                   	leave  
  80076a:	c3                   	ret    

0080076b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80076b:	f3 0f 1e fb          	endbr32 
  80076f:	55                   	push   %ebp
  800770:	89 e5                	mov    %esp,%ebp
  800772:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800775:	b8 00 00 00 00       	mov    $0x0,%eax
  80077a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80077e:	74 05                	je     800785 <strlen+0x1a>
		n++;
  800780:	83 c0 01             	add    $0x1,%eax
  800783:	eb f5                	jmp    80077a <strlen+0xf>
	return n;
}
  800785:	5d                   	pop    %ebp
  800786:	c3                   	ret    

00800787 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800787:	f3 0f 1e fb          	endbr32 
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800791:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800794:	b8 00 00 00 00       	mov    $0x0,%eax
  800799:	39 d0                	cmp    %edx,%eax
  80079b:	74 0d                	je     8007aa <strnlen+0x23>
  80079d:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007a1:	74 05                	je     8007a8 <strnlen+0x21>
		n++;
  8007a3:	83 c0 01             	add    $0x1,%eax
  8007a6:	eb f1                	jmp    800799 <strnlen+0x12>
  8007a8:	89 c2                	mov    %eax,%edx
	return n;
}
  8007aa:	89 d0                	mov    %edx,%eax
  8007ac:	5d                   	pop    %ebp
  8007ad:	c3                   	ret    

008007ae <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ae:	f3 0f 1e fb          	endbr32 
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	53                   	push   %ebx
  8007b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c1:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007c5:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007c8:	83 c0 01             	add    $0x1,%eax
  8007cb:	84 d2                	test   %dl,%dl
  8007cd:	75 f2                	jne    8007c1 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8007cf:	89 c8                	mov    %ecx,%eax
  8007d1:	5b                   	pop    %ebx
  8007d2:	5d                   	pop    %ebp
  8007d3:	c3                   	ret    

008007d4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d4:	f3 0f 1e fb          	endbr32 
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	53                   	push   %ebx
  8007dc:	83 ec 10             	sub    $0x10,%esp
  8007df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e2:	53                   	push   %ebx
  8007e3:	e8 83 ff ff ff       	call   80076b <strlen>
  8007e8:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007eb:	ff 75 0c             	pushl  0xc(%ebp)
  8007ee:	01 d8                	add    %ebx,%eax
  8007f0:	50                   	push   %eax
  8007f1:	e8 b8 ff ff ff       	call   8007ae <strcpy>
	return dst;
}
  8007f6:	89 d8                	mov    %ebx,%eax
  8007f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007fb:	c9                   	leave  
  8007fc:	c3                   	ret    

008007fd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007fd:	f3 0f 1e fb          	endbr32 
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	56                   	push   %esi
  800805:	53                   	push   %ebx
  800806:	8b 75 08             	mov    0x8(%ebp),%esi
  800809:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080c:	89 f3                	mov    %esi,%ebx
  80080e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800811:	89 f0                	mov    %esi,%eax
  800813:	39 d8                	cmp    %ebx,%eax
  800815:	74 11                	je     800828 <strncpy+0x2b>
		*dst++ = *src;
  800817:	83 c0 01             	add    $0x1,%eax
  80081a:	0f b6 0a             	movzbl (%edx),%ecx
  80081d:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800820:	80 f9 01             	cmp    $0x1,%cl
  800823:	83 da ff             	sbb    $0xffffffff,%edx
  800826:	eb eb                	jmp    800813 <strncpy+0x16>
	}
	return ret;
}
  800828:	89 f0                	mov    %esi,%eax
  80082a:	5b                   	pop    %ebx
  80082b:	5e                   	pop    %esi
  80082c:	5d                   	pop    %ebp
  80082d:	c3                   	ret    

0080082e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80082e:	f3 0f 1e fb          	endbr32 
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	56                   	push   %esi
  800836:	53                   	push   %ebx
  800837:	8b 75 08             	mov    0x8(%ebp),%esi
  80083a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083d:	8b 55 10             	mov    0x10(%ebp),%edx
  800840:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800842:	85 d2                	test   %edx,%edx
  800844:	74 21                	je     800867 <strlcpy+0x39>
  800846:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80084a:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80084c:	39 c2                	cmp    %eax,%edx
  80084e:	74 14                	je     800864 <strlcpy+0x36>
  800850:	0f b6 19             	movzbl (%ecx),%ebx
  800853:	84 db                	test   %bl,%bl
  800855:	74 0b                	je     800862 <strlcpy+0x34>
			*dst++ = *src++;
  800857:	83 c1 01             	add    $0x1,%ecx
  80085a:	83 c2 01             	add    $0x1,%edx
  80085d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800860:	eb ea                	jmp    80084c <strlcpy+0x1e>
  800862:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800864:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800867:	29 f0                	sub    %esi,%eax
}
  800869:	5b                   	pop    %ebx
  80086a:	5e                   	pop    %esi
  80086b:	5d                   	pop    %ebp
  80086c:	c3                   	ret    

0080086d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80086d:	f3 0f 1e fb          	endbr32 
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800877:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80087a:	0f b6 01             	movzbl (%ecx),%eax
  80087d:	84 c0                	test   %al,%al
  80087f:	74 0c                	je     80088d <strcmp+0x20>
  800881:	3a 02                	cmp    (%edx),%al
  800883:	75 08                	jne    80088d <strcmp+0x20>
		p++, q++;
  800885:	83 c1 01             	add    $0x1,%ecx
  800888:	83 c2 01             	add    $0x1,%edx
  80088b:	eb ed                	jmp    80087a <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80088d:	0f b6 c0             	movzbl %al,%eax
  800890:	0f b6 12             	movzbl (%edx),%edx
  800893:	29 d0                	sub    %edx,%eax
}
  800895:	5d                   	pop    %ebp
  800896:	c3                   	ret    

00800897 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800897:	f3 0f 1e fb          	endbr32 
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	53                   	push   %ebx
  80089f:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a5:	89 c3                	mov    %eax,%ebx
  8008a7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008aa:	eb 06                	jmp    8008b2 <strncmp+0x1b>
		n--, p++, q++;
  8008ac:	83 c0 01             	add    $0x1,%eax
  8008af:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008b2:	39 d8                	cmp    %ebx,%eax
  8008b4:	74 16                	je     8008cc <strncmp+0x35>
  8008b6:	0f b6 08             	movzbl (%eax),%ecx
  8008b9:	84 c9                	test   %cl,%cl
  8008bb:	74 04                	je     8008c1 <strncmp+0x2a>
  8008bd:	3a 0a                	cmp    (%edx),%cl
  8008bf:	74 eb                	je     8008ac <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c1:	0f b6 00             	movzbl (%eax),%eax
  8008c4:	0f b6 12             	movzbl (%edx),%edx
  8008c7:	29 d0                	sub    %edx,%eax
}
  8008c9:	5b                   	pop    %ebx
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    
		return 0;
  8008cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d1:	eb f6                	jmp    8008c9 <strncmp+0x32>

008008d3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d3:	f3 0f 1e fb          	endbr32 
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e1:	0f b6 10             	movzbl (%eax),%edx
  8008e4:	84 d2                	test   %dl,%dl
  8008e6:	74 09                	je     8008f1 <strchr+0x1e>
		if (*s == c)
  8008e8:	38 ca                	cmp    %cl,%dl
  8008ea:	74 0a                	je     8008f6 <strchr+0x23>
	for (; *s; s++)
  8008ec:	83 c0 01             	add    $0x1,%eax
  8008ef:	eb f0                	jmp    8008e1 <strchr+0xe>
			return (char *) s;
	return 0;
  8008f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f6:	5d                   	pop    %ebp
  8008f7:	c3                   	ret    

008008f8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f8:	f3 0f 1e fb          	endbr32 
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800902:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800906:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800909:	38 ca                	cmp    %cl,%dl
  80090b:	74 09                	je     800916 <strfind+0x1e>
  80090d:	84 d2                	test   %dl,%dl
  80090f:	74 05                	je     800916 <strfind+0x1e>
	for (; *s; s++)
  800911:	83 c0 01             	add    $0x1,%eax
  800914:	eb f0                	jmp    800906 <strfind+0xe>
			break;
	return (char *) s;
}
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    

00800918 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800918:	f3 0f 1e fb          	endbr32 
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	57                   	push   %edi
  800920:	56                   	push   %esi
  800921:	53                   	push   %ebx
  800922:	8b 7d 08             	mov    0x8(%ebp),%edi
  800925:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800928:	85 c9                	test   %ecx,%ecx
  80092a:	74 31                	je     80095d <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80092c:	89 f8                	mov    %edi,%eax
  80092e:	09 c8                	or     %ecx,%eax
  800930:	a8 03                	test   $0x3,%al
  800932:	75 23                	jne    800957 <memset+0x3f>
		c &= 0xFF;
  800934:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800938:	89 d3                	mov    %edx,%ebx
  80093a:	c1 e3 08             	shl    $0x8,%ebx
  80093d:	89 d0                	mov    %edx,%eax
  80093f:	c1 e0 18             	shl    $0x18,%eax
  800942:	89 d6                	mov    %edx,%esi
  800944:	c1 e6 10             	shl    $0x10,%esi
  800947:	09 f0                	or     %esi,%eax
  800949:	09 c2                	or     %eax,%edx
  80094b:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80094d:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800950:	89 d0                	mov    %edx,%eax
  800952:	fc                   	cld    
  800953:	f3 ab                	rep stos %eax,%es:(%edi)
  800955:	eb 06                	jmp    80095d <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800957:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095a:	fc                   	cld    
  80095b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80095d:	89 f8                	mov    %edi,%eax
  80095f:	5b                   	pop    %ebx
  800960:	5e                   	pop    %esi
  800961:	5f                   	pop    %edi
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800964:	f3 0f 1e fb          	endbr32 
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	57                   	push   %edi
  80096c:	56                   	push   %esi
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	8b 75 0c             	mov    0xc(%ebp),%esi
  800973:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800976:	39 c6                	cmp    %eax,%esi
  800978:	73 32                	jae    8009ac <memmove+0x48>
  80097a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80097d:	39 c2                	cmp    %eax,%edx
  80097f:	76 2b                	jbe    8009ac <memmove+0x48>
		s += n;
		d += n;
  800981:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800984:	89 fe                	mov    %edi,%esi
  800986:	09 ce                	or     %ecx,%esi
  800988:	09 d6                	or     %edx,%esi
  80098a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800990:	75 0e                	jne    8009a0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800992:	83 ef 04             	sub    $0x4,%edi
  800995:	8d 72 fc             	lea    -0x4(%edx),%esi
  800998:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80099b:	fd                   	std    
  80099c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099e:	eb 09                	jmp    8009a9 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009a0:	83 ef 01             	sub    $0x1,%edi
  8009a3:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009a6:	fd                   	std    
  8009a7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009a9:	fc                   	cld    
  8009aa:	eb 1a                	jmp    8009c6 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ac:	89 c2                	mov    %eax,%edx
  8009ae:	09 ca                	or     %ecx,%edx
  8009b0:	09 f2                	or     %esi,%edx
  8009b2:	f6 c2 03             	test   $0x3,%dl
  8009b5:	75 0a                	jne    8009c1 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009b7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009ba:	89 c7                	mov    %eax,%edi
  8009bc:	fc                   	cld    
  8009bd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bf:	eb 05                	jmp    8009c6 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8009c1:	89 c7                	mov    %eax,%edi
  8009c3:	fc                   	cld    
  8009c4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009c6:	5e                   	pop    %esi
  8009c7:	5f                   	pop    %edi
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ca:	f3 0f 1e fb          	endbr32 
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009d4:	ff 75 10             	pushl  0x10(%ebp)
  8009d7:	ff 75 0c             	pushl  0xc(%ebp)
  8009da:	ff 75 08             	pushl  0x8(%ebp)
  8009dd:	e8 82 ff ff ff       	call   800964 <memmove>
}
  8009e2:	c9                   	leave  
  8009e3:	c3                   	ret    

008009e4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e4:	f3 0f 1e fb          	endbr32 
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	56                   	push   %esi
  8009ec:	53                   	push   %ebx
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f3:	89 c6                	mov    %eax,%esi
  8009f5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f8:	39 f0                	cmp    %esi,%eax
  8009fa:	74 1c                	je     800a18 <memcmp+0x34>
		if (*s1 != *s2)
  8009fc:	0f b6 08             	movzbl (%eax),%ecx
  8009ff:	0f b6 1a             	movzbl (%edx),%ebx
  800a02:	38 d9                	cmp    %bl,%cl
  800a04:	75 08                	jne    800a0e <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a06:	83 c0 01             	add    $0x1,%eax
  800a09:	83 c2 01             	add    $0x1,%edx
  800a0c:	eb ea                	jmp    8009f8 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a0e:	0f b6 c1             	movzbl %cl,%eax
  800a11:	0f b6 db             	movzbl %bl,%ebx
  800a14:	29 d8                	sub    %ebx,%eax
  800a16:	eb 05                	jmp    800a1d <memcmp+0x39>
	}

	return 0;
  800a18:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1d:	5b                   	pop    %ebx
  800a1e:	5e                   	pop    %esi
  800a1f:	5d                   	pop    %ebp
  800a20:	c3                   	ret    

00800a21 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a21:	f3 0f 1e fb          	endbr32 
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a2e:	89 c2                	mov    %eax,%edx
  800a30:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a33:	39 d0                	cmp    %edx,%eax
  800a35:	73 09                	jae    800a40 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a37:	38 08                	cmp    %cl,(%eax)
  800a39:	74 05                	je     800a40 <memfind+0x1f>
	for (; s < ends; s++)
  800a3b:	83 c0 01             	add    $0x1,%eax
  800a3e:	eb f3                	jmp    800a33 <memfind+0x12>
			break;
	return (void *) s;
}
  800a40:	5d                   	pop    %ebp
  800a41:	c3                   	ret    

00800a42 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a42:	f3 0f 1e fb          	endbr32 
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	57                   	push   %edi
  800a4a:	56                   	push   %esi
  800a4b:	53                   	push   %ebx
  800a4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a52:	eb 03                	jmp    800a57 <strtol+0x15>
		s++;
  800a54:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a57:	0f b6 01             	movzbl (%ecx),%eax
  800a5a:	3c 20                	cmp    $0x20,%al
  800a5c:	74 f6                	je     800a54 <strtol+0x12>
  800a5e:	3c 09                	cmp    $0x9,%al
  800a60:	74 f2                	je     800a54 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a62:	3c 2b                	cmp    $0x2b,%al
  800a64:	74 2a                	je     800a90 <strtol+0x4e>
	int neg = 0;
  800a66:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a6b:	3c 2d                	cmp    $0x2d,%al
  800a6d:	74 2b                	je     800a9a <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a6f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a75:	75 0f                	jne    800a86 <strtol+0x44>
  800a77:	80 39 30             	cmpb   $0x30,(%ecx)
  800a7a:	74 28                	je     800aa4 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a7c:	85 db                	test   %ebx,%ebx
  800a7e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a83:	0f 44 d8             	cmove  %eax,%ebx
  800a86:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a8e:	eb 46                	jmp    800ad6 <strtol+0x94>
		s++;
  800a90:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a93:	bf 00 00 00 00       	mov    $0x0,%edi
  800a98:	eb d5                	jmp    800a6f <strtol+0x2d>
		s++, neg = 1;
  800a9a:	83 c1 01             	add    $0x1,%ecx
  800a9d:	bf 01 00 00 00       	mov    $0x1,%edi
  800aa2:	eb cb                	jmp    800a6f <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aa8:	74 0e                	je     800ab8 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800aaa:	85 db                	test   %ebx,%ebx
  800aac:	75 d8                	jne    800a86 <strtol+0x44>
		s++, base = 8;
  800aae:	83 c1 01             	add    $0x1,%ecx
  800ab1:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ab6:	eb ce                	jmp    800a86 <strtol+0x44>
		s += 2, base = 16;
  800ab8:	83 c1 02             	add    $0x2,%ecx
  800abb:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac0:	eb c4                	jmp    800a86 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ac2:	0f be d2             	movsbl %dl,%edx
  800ac5:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ac8:	3b 55 10             	cmp    0x10(%ebp),%edx
  800acb:	7d 3a                	jge    800b07 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800acd:	83 c1 01             	add    $0x1,%ecx
  800ad0:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ad4:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ad6:	0f b6 11             	movzbl (%ecx),%edx
  800ad9:	8d 72 d0             	lea    -0x30(%edx),%esi
  800adc:	89 f3                	mov    %esi,%ebx
  800ade:	80 fb 09             	cmp    $0x9,%bl
  800ae1:	76 df                	jbe    800ac2 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800ae3:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ae6:	89 f3                	mov    %esi,%ebx
  800ae8:	80 fb 19             	cmp    $0x19,%bl
  800aeb:	77 08                	ja     800af5 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800aed:	0f be d2             	movsbl %dl,%edx
  800af0:	83 ea 57             	sub    $0x57,%edx
  800af3:	eb d3                	jmp    800ac8 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800af5:	8d 72 bf             	lea    -0x41(%edx),%esi
  800af8:	89 f3                	mov    %esi,%ebx
  800afa:	80 fb 19             	cmp    $0x19,%bl
  800afd:	77 08                	ja     800b07 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800aff:	0f be d2             	movsbl %dl,%edx
  800b02:	83 ea 37             	sub    $0x37,%edx
  800b05:	eb c1                	jmp    800ac8 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b07:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b0b:	74 05                	je     800b12 <strtol+0xd0>
		*endptr = (char *) s;
  800b0d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b10:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b12:	89 c2                	mov    %eax,%edx
  800b14:	f7 da                	neg    %edx
  800b16:	85 ff                	test   %edi,%edi
  800b18:	0f 45 c2             	cmovne %edx,%eax
}
  800b1b:	5b                   	pop    %ebx
  800b1c:	5e                   	pop    %esi
  800b1d:	5f                   	pop    %edi
  800b1e:	5d                   	pop    %ebp
  800b1f:	c3                   	ret    

00800b20 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b20:	f3 0f 1e fb          	endbr32 
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	57                   	push   %edi
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b2a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b35:	89 c3                	mov    %eax,%ebx
  800b37:	89 c7                	mov    %eax,%edi
  800b39:	89 c6                	mov    %eax,%esi
  800b3b:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b3d:	5b                   	pop    %ebx
  800b3e:	5e                   	pop    %esi
  800b3f:	5f                   	pop    %edi
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b42:	f3 0f 1e fb          	endbr32 
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	57                   	push   %edi
  800b4a:	56                   	push   %esi
  800b4b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b51:	b8 01 00 00 00       	mov    $0x1,%eax
  800b56:	89 d1                	mov    %edx,%ecx
  800b58:	89 d3                	mov    %edx,%ebx
  800b5a:	89 d7                	mov    %edx,%edi
  800b5c:	89 d6                	mov    %edx,%esi
  800b5e:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b60:	5b                   	pop    %ebx
  800b61:	5e                   	pop    %esi
  800b62:	5f                   	pop    %edi
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b65:	f3 0f 1e fb          	endbr32 
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	57                   	push   %edi
  800b6d:	56                   	push   %esi
  800b6e:	53                   	push   %ebx
  800b6f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b72:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b77:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b7f:	89 cb                	mov    %ecx,%ebx
  800b81:	89 cf                	mov    %ecx,%edi
  800b83:	89 ce                	mov    %ecx,%esi
  800b85:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b87:	85 c0                	test   %eax,%eax
  800b89:	7f 08                	jg     800b93 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8e:	5b                   	pop    %ebx
  800b8f:	5e                   	pop    %esi
  800b90:	5f                   	pop    %edi
  800b91:	5d                   	pop    %ebp
  800b92:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b93:	83 ec 0c             	sub    $0xc,%esp
  800b96:	50                   	push   %eax
  800b97:	6a 03                	push   $0x3
  800b99:	68 1f 14 80 00       	push   $0x80141f
  800b9e:	6a 23                	push   $0x23
  800ba0:	68 3c 14 80 00       	push   $0x80143c
  800ba5:	e8 36 02 00 00       	call   800de0 <_panic>

00800baa <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800baa:	f3 0f 1e fb          	endbr32 
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb9:	b8 02 00 00 00       	mov    $0x2,%eax
  800bbe:	89 d1                	mov    %edx,%ecx
  800bc0:	89 d3                	mov    %edx,%ebx
  800bc2:	89 d7                	mov    %edx,%edi
  800bc4:	89 d6                	mov    %edx,%esi
  800bc6:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bc8:	5b                   	pop    %ebx
  800bc9:	5e                   	pop    %esi
  800bca:	5f                   	pop    %edi
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    

00800bcd <sys_yield>:

void
sys_yield(void)
{
  800bcd:	f3 0f 1e fb          	endbr32 
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	57                   	push   %edi
  800bd5:	56                   	push   %esi
  800bd6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdc:	b8 0b 00 00 00       	mov    $0xb,%eax
  800be1:	89 d1                	mov    %edx,%ecx
  800be3:	89 d3                	mov    %edx,%ebx
  800be5:	89 d7                	mov    %edx,%edi
  800be7:	89 d6                	mov    %edx,%esi
  800be9:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800beb:	5b                   	pop    %ebx
  800bec:	5e                   	pop    %esi
  800bed:	5f                   	pop    %edi
  800bee:	5d                   	pop    %ebp
  800bef:	c3                   	ret    

00800bf0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bf0:	f3 0f 1e fb          	endbr32 
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	57                   	push   %edi
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
  800bfa:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bfd:	be 00 00 00 00       	mov    $0x0,%esi
  800c02:	8b 55 08             	mov    0x8(%ebp),%edx
  800c05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c08:	b8 04 00 00 00       	mov    $0x4,%eax
  800c0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c10:	89 f7                	mov    %esi,%edi
  800c12:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c14:	85 c0                	test   %eax,%eax
  800c16:	7f 08                	jg     800c20 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1b:	5b                   	pop    %ebx
  800c1c:	5e                   	pop    %esi
  800c1d:	5f                   	pop    %edi
  800c1e:	5d                   	pop    %ebp
  800c1f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c20:	83 ec 0c             	sub    $0xc,%esp
  800c23:	50                   	push   %eax
  800c24:	6a 04                	push   $0x4
  800c26:	68 1f 14 80 00       	push   $0x80141f
  800c2b:	6a 23                	push   $0x23
  800c2d:	68 3c 14 80 00       	push   $0x80143c
  800c32:	e8 a9 01 00 00       	call   800de0 <_panic>

00800c37 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c37:	f3 0f 1e fb          	endbr32 
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
  800c41:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c44:	8b 55 08             	mov    0x8(%ebp),%edx
  800c47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c52:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c55:	8b 75 18             	mov    0x18(%ebp),%esi
  800c58:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c5a:	85 c0                	test   %eax,%eax
  800c5c:	7f 08                	jg     800c66 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c61:	5b                   	pop    %ebx
  800c62:	5e                   	pop    %esi
  800c63:	5f                   	pop    %edi
  800c64:	5d                   	pop    %ebp
  800c65:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c66:	83 ec 0c             	sub    $0xc,%esp
  800c69:	50                   	push   %eax
  800c6a:	6a 05                	push   $0x5
  800c6c:	68 1f 14 80 00       	push   $0x80141f
  800c71:	6a 23                	push   $0x23
  800c73:	68 3c 14 80 00       	push   $0x80143c
  800c78:	e8 63 01 00 00       	call   800de0 <_panic>

00800c7d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c7d:	f3 0f 1e fb          	endbr32 
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	57                   	push   %edi
  800c85:	56                   	push   %esi
  800c86:	53                   	push   %ebx
  800c87:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c95:	b8 06 00 00 00       	mov    $0x6,%eax
  800c9a:	89 df                	mov    %ebx,%edi
  800c9c:	89 de                	mov    %ebx,%esi
  800c9e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca0:	85 c0                	test   %eax,%eax
  800ca2:	7f 08                	jg     800cac <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ca4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca7:	5b                   	pop    %ebx
  800ca8:	5e                   	pop    %esi
  800ca9:	5f                   	pop    %edi
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cac:	83 ec 0c             	sub    $0xc,%esp
  800caf:	50                   	push   %eax
  800cb0:	6a 06                	push   $0x6
  800cb2:	68 1f 14 80 00       	push   $0x80141f
  800cb7:	6a 23                	push   $0x23
  800cb9:	68 3c 14 80 00       	push   $0x80143c
  800cbe:	e8 1d 01 00 00       	call   800de0 <_panic>

00800cc3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cc3:	f3 0f 1e fb          	endbr32 
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	57                   	push   %edi
  800ccb:	56                   	push   %esi
  800ccc:	53                   	push   %ebx
  800ccd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdb:	b8 08 00 00 00       	mov    $0x8,%eax
  800ce0:	89 df                	mov    %ebx,%edi
  800ce2:	89 de                	mov    %ebx,%esi
  800ce4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce6:	85 c0                	test   %eax,%eax
  800ce8:	7f 08                	jg     800cf2 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ced:	5b                   	pop    %ebx
  800cee:	5e                   	pop    %esi
  800cef:	5f                   	pop    %edi
  800cf0:	5d                   	pop    %ebp
  800cf1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf2:	83 ec 0c             	sub    $0xc,%esp
  800cf5:	50                   	push   %eax
  800cf6:	6a 08                	push   $0x8
  800cf8:	68 1f 14 80 00       	push   $0x80141f
  800cfd:	6a 23                	push   $0x23
  800cff:	68 3c 14 80 00       	push   $0x80143c
  800d04:	e8 d7 00 00 00       	call   800de0 <_panic>

00800d09 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d09:	f3 0f 1e fb          	endbr32 
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
  800d13:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d16:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d21:	b8 09 00 00 00       	mov    $0x9,%eax
  800d26:	89 df                	mov    %ebx,%edi
  800d28:	89 de                	mov    %ebx,%esi
  800d2a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d2c:	85 c0                	test   %eax,%eax
  800d2e:	7f 08                	jg     800d38 <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d33:	5b                   	pop    %ebx
  800d34:	5e                   	pop    %esi
  800d35:	5f                   	pop    %edi
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d38:	83 ec 0c             	sub    $0xc,%esp
  800d3b:	50                   	push   %eax
  800d3c:	6a 09                	push   $0x9
  800d3e:	68 1f 14 80 00       	push   $0x80141f
  800d43:	6a 23                	push   $0x23
  800d45:	68 3c 14 80 00       	push   $0x80143c
  800d4a:	e8 91 00 00 00       	call   800de0 <_panic>

00800d4f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d4f:	f3 0f 1e fb          	endbr32 
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	57                   	push   %edi
  800d57:	56                   	push   %esi
  800d58:	53                   	push   %ebx
  800d59:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d5c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d61:	8b 55 08             	mov    0x8(%ebp),%edx
  800d64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d67:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d6c:	89 df                	mov    %ebx,%edi
  800d6e:	89 de                	mov    %ebx,%esi
  800d70:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d72:	85 c0                	test   %eax,%eax
  800d74:	7f 08                	jg     800d7e <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5f                   	pop    %edi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7e:	83 ec 0c             	sub    $0xc,%esp
  800d81:	50                   	push   %eax
  800d82:	6a 0a                	push   $0xa
  800d84:	68 1f 14 80 00       	push   $0x80141f
  800d89:	6a 23                	push   $0x23
  800d8b:	68 3c 14 80 00       	push   $0x80143c
  800d90:	e8 4b 00 00 00       	call   800de0 <_panic>

00800d95 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d95:	f3 0f 1e fb          	endbr32 
  800d99:	55                   	push   %ebp
  800d9a:	89 e5                	mov    %esp,%ebp
  800d9c:	57                   	push   %edi
  800d9d:	56                   	push   %esi
  800d9e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800da2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da5:	b8 0c 00 00 00       	mov    $0xc,%eax
  800daa:	be 00 00 00 00       	mov    $0x0,%esi
  800daf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800db5:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800db7:	5b                   	pop    %ebx
  800db8:	5e                   	pop    %esi
  800db9:	5f                   	pop    %edi
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    

00800dbc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dbc:	f3 0f 1e fb          	endbr32 
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	57                   	push   %edi
  800dc4:	56                   	push   %esi
  800dc5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dc6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dce:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dd3:	89 cb                	mov    %ecx,%ebx
  800dd5:	89 cf                	mov    %ecx,%edi
  800dd7:	89 ce                	mov    %ecx,%esi
  800dd9:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 0, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ddb:	5b                   	pop    %ebx
  800ddc:	5e                   	pop    %esi
  800ddd:	5f                   	pop    %edi
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    

00800de0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800de0:	f3 0f 1e fb          	endbr32 
  800de4:	55                   	push   %ebp
  800de5:	89 e5                	mov    %esp,%ebp
  800de7:	56                   	push   %esi
  800de8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800de9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800dec:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800df2:	e8 b3 fd ff ff       	call   800baa <sys_getenvid>
  800df7:	83 ec 0c             	sub    $0xc,%esp
  800dfa:	ff 75 0c             	pushl  0xc(%ebp)
  800dfd:	ff 75 08             	pushl  0x8(%ebp)
  800e00:	56                   	push   %esi
  800e01:	50                   	push   %eax
  800e02:	68 4c 14 80 00       	push   $0x80144c
  800e07:	e8 99 f3 ff ff       	call   8001a5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e0c:	83 c4 18             	add    $0x18,%esp
  800e0f:	53                   	push   %ebx
  800e10:	ff 75 10             	pushl  0x10(%ebp)
  800e13:	e8 38 f3 ff ff       	call   800150 <vcprintf>
	cprintf("\n");
  800e18:	c7 04 24 6f 14 80 00 	movl   $0x80146f,(%esp)
  800e1f:	e8 81 f3 ff ff       	call   8001a5 <cprintf>
  800e24:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e27:	cc                   	int3   
  800e28:	eb fd                	jmp    800e27 <_panic+0x47>
  800e2a:	66 90                	xchg   %ax,%ax
  800e2c:	66 90                	xchg   %ax,%ax
  800e2e:	66 90                	xchg   %ax,%ax

00800e30 <__udivdi3>:
  800e30:	f3 0f 1e fb          	endbr32 
  800e34:	55                   	push   %ebp
  800e35:	57                   	push   %edi
  800e36:	56                   	push   %esi
  800e37:	53                   	push   %ebx
  800e38:	83 ec 1c             	sub    $0x1c,%esp
  800e3b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e3f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e43:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e47:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e4b:	85 d2                	test   %edx,%edx
  800e4d:	75 19                	jne    800e68 <__udivdi3+0x38>
  800e4f:	39 f3                	cmp    %esi,%ebx
  800e51:	76 4d                	jbe    800ea0 <__udivdi3+0x70>
  800e53:	31 ff                	xor    %edi,%edi
  800e55:	89 e8                	mov    %ebp,%eax
  800e57:	89 f2                	mov    %esi,%edx
  800e59:	f7 f3                	div    %ebx
  800e5b:	89 fa                	mov    %edi,%edx
  800e5d:	83 c4 1c             	add    $0x1c,%esp
  800e60:	5b                   	pop    %ebx
  800e61:	5e                   	pop    %esi
  800e62:	5f                   	pop    %edi
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    
  800e65:	8d 76 00             	lea    0x0(%esi),%esi
  800e68:	39 f2                	cmp    %esi,%edx
  800e6a:	76 14                	jbe    800e80 <__udivdi3+0x50>
  800e6c:	31 ff                	xor    %edi,%edi
  800e6e:	31 c0                	xor    %eax,%eax
  800e70:	89 fa                	mov    %edi,%edx
  800e72:	83 c4 1c             	add    $0x1c,%esp
  800e75:	5b                   	pop    %ebx
  800e76:	5e                   	pop    %esi
  800e77:	5f                   	pop    %edi
  800e78:	5d                   	pop    %ebp
  800e79:	c3                   	ret    
  800e7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e80:	0f bd fa             	bsr    %edx,%edi
  800e83:	83 f7 1f             	xor    $0x1f,%edi
  800e86:	75 48                	jne    800ed0 <__udivdi3+0xa0>
  800e88:	39 f2                	cmp    %esi,%edx
  800e8a:	72 06                	jb     800e92 <__udivdi3+0x62>
  800e8c:	31 c0                	xor    %eax,%eax
  800e8e:	39 eb                	cmp    %ebp,%ebx
  800e90:	77 de                	ja     800e70 <__udivdi3+0x40>
  800e92:	b8 01 00 00 00       	mov    $0x1,%eax
  800e97:	eb d7                	jmp    800e70 <__udivdi3+0x40>
  800e99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ea0:	89 d9                	mov    %ebx,%ecx
  800ea2:	85 db                	test   %ebx,%ebx
  800ea4:	75 0b                	jne    800eb1 <__udivdi3+0x81>
  800ea6:	b8 01 00 00 00       	mov    $0x1,%eax
  800eab:	31 d2                	xor    %edx,%edx
  800ead:	f7 f3                	div    %ebx
  800eaf:	89 c1                	mov    %eax,%ecx
  800eb1:	31 d2                	xor    %edx,%edx
  800eb3:	89 f0                	mov    %esi,%eax
  800eb5:	f7 f1                	div    %ecx
  800eb7:	89 c6                	mov    %eax,%esi
  800eb9:	89 e8                	mov    %ebp,%eax
  800ebb:	89 f7                	mov    %esi,%edi
  800ebd:	f7 f1                	div    %ecx
  800ebf:	89 fa                	mov    %edi,%edx
  800ec1:	83 c4 1c             	add    $0x1c,%esp
  800ec4:	5b                   	pop    %ebx
  800ec5:	5e                   	pop    %esi
  800ec6:	5f                   	pop    %edi
  800ec7:	5d                   	pop    %ebp
  800ec8:	c3                   	ret    
  800ec9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ed0:	89 f9                	mov    %edi,%ecx
  800ed2:	b8 20 00 00 00       	mov    $0x20,%eax
  800ed7:	29 f8                	sub    %edi,%eax
  800ed9:	d3 e2                	shl    %cl,%edx
  800edb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800edf:	89 c1                	mov    %eax,%ecx
  800ee1:	89 da                	mov    %ebx,%edx
  800ee3:	d3 ea                	shr    %cl,%edx
  800ee5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ee9:	09 d1                	or     %edx,%ecx
  800eeb:	89 f2                	mov    %esi,%edx
  800eed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ef1:	89 f9                	mov    %edi,%ecx
  800ef3:	d3 e3                	shl    %cl,%ebx
  800ef5:	89 c1                	mov    %eax,%ecx
  800ef7:	d3 ea                	shr    %cl,%edx
  800ef9:	89 f9                	mov    %edi,%ecx
  800efb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800eff:	89 eb                	mov    %ebp,%ebx
  800f01:	d3 e6                	shl    %cl,%esi
  800f03:	89 c1                	mov    %eax,%ecx
  800f05:	d3 eb                	shr    %cl,%ebx
  800f07:	09 de                	or     %ebx,%esi
  800f09:	89 f0                	mov    %esi,%eax
  800f0b:	f7 74 24 08          	divl   0x8(%esp)
  800f0f:	89 d6                	mov    %edx,%esi
  800f11:	89 c3                	mov    %eax,%ebx
  800f13:	f7 64 24 0c          	mull   0xc(%esp)
  800f17:	39 d6                	cmp    %edx,%esi
  800f19:	72 15                	jb     800f30 <__udivdi3+0x100>
  800f1b:	89 f9                	mov    %edi,%ecx
  800f1d:	d3 e5                	shl    %cl,%ebp
  800f1f:	39 c5                	cmp    %eax,%ebp
  800f21:	73 04                	jae    800f27 <__udivdi3+0xf7>
  800f23:	39 d6                	cmp    %edx,%esi
  800f25:	74 09                	je     800f30 <__udivdi3+0x100>
  800f27:	89 d8                	mov    %ebx,%eax
  800f29:	31 ff                	xor    %edi,%edi
  800f2b:	e9 40 ff ff ff       	jmp    800e70 <__udivdi3+0x40>
  800f30:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800f33:	31 ff                	xor    %edi,%edi
  800f35:	e9 36 ff ff ff       	jmp    800e70 <__udivdi3+0x40>
  800f3a:	66 90                	xchg   %ax,%ax
  800f3c:	66 90                	xchg   %ax,%ax
  800f3e:	66 90                	xchg   %ax,%ax

00800f40 <__umoddi3>:
  800f40:	f3 0f 1e fb          	endbr32 
  800f44:	55                   	push   %ebp
  800f45:	57                   	push   %edi
  800f46:	56                   	push   %esi
  800f47:	53                   	push   %ebx
  800f48:	83 ec 1c             	sub    $0x1c,%esp
  800f4b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800f4f:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f53:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f57:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f5b:	85 c0                	test   %eax,%eax
  800f5d:	75 19                	jne    800f78 <__umoddi3+0x38>
  800f5f:	39 df                	cmp    %ebx,%edi
  800f61:	76 5d                	jbe    800fc0 <__umoddi3+0x80>
  800f63:	89 f0                	mov    %esi,%eax
  800f65:	89 da                	mov    %ebx,%edx
  800f67:	f7 f7                	div    %edi
  800f69:	89 d0                	mov    %edx,%eax
  800f6b:	31 d2                	xor    %edx,%edx
  800f6d:	83 c4 1c             	add    $0x1c,%esp
  800f70:	5b                   	pop    %ebx
  800f71:	5e                   	pop    %esi
  800f72:	5f                   	pop    %edi
  800f73:	5d                   	pop    %ebp
  800f74:	c3                   	ret    
  800f75:	8d 76 00             	lea    0x0(%esi),%esi
  800f78:	89 f2                	mov    %esi,%edx
  800f7a:	39 d8                	cmp    %ebx,%eax
  800f7c:	76 12                	jbe    800f90 <__umoddi3+0x50>
  800f7e:	89 f0                	mov    %esi,%eax
  800f80:	89 da                	mov    %ebx,%edx
  800f82:	83 c4 1c             	add    $0x1c,%esp
  800f85:	5b                   	pop    %ebx
  800f86:	5e                   	pop    %esi
  800f87:	5f                   	pop    %edi
  800f88:	5d                   	pop    %ebp
  800f89:	c3                   	ret    
  800f8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f90:	0f bd e8             	bsr    %eax,%ebp
  800f93:	83 f5 1f             	xor    $0x1f,%ebp
  800f96:	75 50                	jne    800fe8 <__umoddi3+0xa8>
  800f98:	39 d8                	cmp    %ebx,%eax
  800f9a:	0f 82 e0 00 00 00    	jb     801080 <__umoddi3+0x140>
  800fa0:	89 d9                	mov    %ebx,%ecx
  800fa2:	39 f7                	cmp    %esi,%edi
  800fa4:	0f 86 d6 00 00 00    	jbe    801080 <__umoddi3+0x140>
  800faa:	89 d0                	mov    %edx,%eax
  800fac:	89 ca                	mov    %ecx,%edx
  800fae:	83 c4 1c             	add    $0x1c,%esp
  800fb1:	5b                   	pop    %ebx
  800fb2:	5e                   	pop    %esi
  800fb3:	5f                   	pop    %edi
  800fb4:	5d                   	pop    %ebp
  800fb5:	c3                   	ret    
  800fb6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fbd:	8d 76 00             	lea    0x0(%esi),%esi
  800fc0:	89 fd                	mov    %edi,%ebp
  800fc2:	85 ff                	test   %edi,%edi
  800fc4:	75 0b                	jne    800fd1 <__umoddi3+0x91>
  800fc6:	b8 01 00 00 00       	mov    $0x1,%eax
  800fcb:	31 d2                	xor    %edx,%edx
  800fcd:	f7 f7                	div    %edi
  800fcf:	89 c5                	mov    %eax,%ebp
  800fd1:	89 d8                	mov    %ebx,%eax
  800fd3:	31 d2                	xor    %edx,%edx
  800fd5:	f7 f5                	div    %ebp
  800fd7:	89 f0                	mov    %esi,%eax
  800fd9:	f7 f5                	div    %ebp
  800fdb:	89 d0                	mov    %edx,%eax
  800fdd:	31 d2                	xor    %edx,%edx
  800fdf:	eb 8c                	jmp    800f6d <__umoddi3+0x2d>
  800fe1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fe8:	89 e9                	mov    %ebp,%ecx
  800fea:	ba 20 00 00 00       	mov    $0x20,%edx
  800fef:	29 ea                	sub    %ebp,%edx
  800ff1:	d3 e0                	shl    %cl,%eax
  800ff3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ff7:	89 d1                	mov    %edx,%ecx
  800ff9:	89 f8                	mov    %edi,%eax
  800ffb:	d3 e8                	shr    %cl,%eax
  800ffd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801001:	89 54 24 04          	mov    %edx,0x4(%esp)
  801005:	8b 54 24 04          	mov    0x4(%esp),%edx
  801009:	09 c1                	or     %eax,%ecx
  80100b:	89 d8                	mov    %ebx,%eax
  80100d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801011:	89 e9                	mov    %ebp,%ecx
  801013:	d3 e7                	shl    %cl,%edi
  801015:	89 d1                	mov    %edx,%ecx
  801017:	d3 e8                	shr    %cl,%eax
  801019:	89 e9                	mov    %ebp,%ecx
  80101b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80101f:	d3 e3                	shl    %cl,%ebx
  801021:	89 c7                	mov    %eax,%edi
  801023:	89 d1                	mov    %edx,%ecx
  801025:	89 f0                	mov    %esi,%eax
  801027:	d3 e8                	shr    %cl,%eax
  801029:	89 e9                	mov    %ebp,%ecx
  80102b:	89 fa                	mov    %edi,%edx
  80102d:	d3 e6                	shl    %cl,%esi
  80102f:	09 d8                	or     %ebx,%eax
  801031:	f7 74 24 08          	divl   0x8(%esp)
  801035:	89 d1                	mov    %edx,%ecx
  801037:	89 f3                	mov    %esi,%ebx
  801039:	f7 64 24 0c          	mull   0xc(%esp)
  80103d:	89 c6                	mov    %eax,%esi
  80103f:	89 d7                	mov    %edx,%edi
  801041:	39 d1                	cmp    %edx,%ecx
  801043:	72 06                	jb     80104b <__umoddi3+0x10b>
  801045:	75 10                	jne    801057 <__umoddi3+0x117>
  801047:	39 c3                	cmp    %eax,%ebx
  801049:	73 0c                	jae    801057 <__umoddi3+0x117>
  80104b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80104f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801053:	89 d7                	mov    %edx,%edi
  801055:	89 c6                	mov    %eax,%esi
  801057:	89 ca                	mov    %ecx,%edx
  801059:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80105e:	29 f3                	sub    %esi,%ebx
  801060:	19 fa                	sbb    %edi,%edx
  801062:	89 d0                	mov    %edx,%eax
  801064:	d3 e0                	shl    %cl,%eax
  801066:	89 e9                	mov    %ebp,%ecx
  801068:	d3 eb                	shr    %cl,%ebx
  80106a:	d3 ea                	shr    %cl,%edx
  80106c:	09 d8                	or     %ebx,%eax
  80106e:	83 c4 1c             	add    $0x1c,%esp
  801071:	5b                   	pop    %ebx
  801072:	5e                   	pop    %esi
  801073:	5f                   	pop    %edi
  801074:	5d                   	pop    %ebp
  801075:	c3                   	ret    
  801076:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80107d:	8d 76 00             	lea    0x0(%esi),%esi
  801080:	29 fe                	sub    %edi,%esi
  801082:	19 c3                	sbb    %eax,%ebx
  801084:	89 f2                	mov    %esi,%edx
  801086:	89 d9                	mov    %ebx,%ecx
  801088:	e9 1d ff ff ff       	jmp    800faa <__umoddi3+0x6a>
