
obj/user/forktree:     file format elf32-i386


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
  80002c:	e8 be 00 00 00       	call   8000ef <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	53                   	push   %ebx
  80003b:	83 ec 04             	sub    $0x4,%esp
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  800041:	e8 ab 0b 00 00       	call   800bf1 <sys_getenvid>
  800046:	83 ec 04             	sub    $0x4,%esp
  800049:	53                   	push   %ebx
  80004a:	50                   	push   %eax
  80004b:	68 a0 13 80 00       	push   $0x8013a0
  800050:	e8 97 01 00 00       	call   8001ec <cprintf>

	forkchild(cur, '0');
  800055:	83 c4 08             	add    $0x8,%esp
  800058:	6a 30                	push   $0x30
  80005a:	53                   	push   %ebx
  80005b:	e8 13 00 00 00       	call   800073 <forkchild>
	forkchild(cur, '1');
  800060:	83 c4 08             	add    $0x8,%esp
  800063:	6a 31                	push   $0x31
  800065:	53                   	push   %ebx
  800066:	e8 08 00 00 00       	call   800073 <forkchild>
}
  80006b:	83 c4 10             	add    $0x10,%esp
  80006e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800071:	c9                   	leave  
  800072:	c3                   	ret    

00800073 <forkchild>:
{
  800073:	f3 0f 1e fb          	endbr32 
  800077:	55                   	push   %ebp
  800078:	89 e5                	mov    %esp,%ebp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	83 ec 1c             	sub    $0x1c,%esp
  80007f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800082:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (strlen(cur) >= DEPTH)
  800085:	53                   	push   %ebx
  800086:	e8 27 07 00 00       	call   8007b2 <strlen>
  80008b:	83 c4 10             	add    $0x10,%esp
  80008e:	83 f8 02             	cmp    $0x2,%eax
  800091:	7e 07                	jle    80009a <forkchild+0x27>
}
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    
	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	89 f0                	mov    %esi,%eax
  80009f:	0f be f0             	movsbl %al,%esi
  8000a2:	56                   	push   %esi
  8000a3:	53                   	push   %ebx
  8000a4:	68 b1 13 80 00       	push   $0x8013b1
  8000a9:	6a 04                	push   $0x4
  8000ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000ae:	50                   	push   %eax
  8000af:	e8 e0 06 00 00       	call   800794 <snprintf>
	if (fork() == 0) {
  8000b4:	83 c4 20             	add    $0x20,%esp
  8000b7:	e8 1b 0e 00 00       	call   800ed7 <fork>
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	75 d3                	jne    800093 <forkchild+0x20>
		forktree(nxt);
  8000c0:	83 ec 0c             	sub    $0xc,%esp
  8000c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000c6:	50                   	push   %eax
  8000c7:	e8 67 ff ff ff       	call   800033 <forktree>
		exit();
  8000cc:	e8 68 00 00 00       	call   800139 <exit>
  8000d1:	83 c4 10             	add    $0x10,%esp
  8000d4:	eb bd                	jmp    800093 <forkchild+0x20>

008000d6 <umain>:

void
umain(int argc, char **argv)
{
  8000d6:	f3 0f 1e fb          	endbr32 
  8000da:	55                   	push   %ebp
  8000db:	89 e5                	mov    %esp,%ebp
  8000dd:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000e0:	68 b0 13 80 00       	push   $0x8013b0
  8000e5:	e8 49 ff ff ff       	call   800033 <forktree>
}
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	c9                   	leave  
  8000ee:	c3                   	ret    

008000ef <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ef:	f3 0f 1e fb          	endbr32 
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	56                   	push   %esi
  8000f7:	53                   	push   %ebx
  8000f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000fb:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    envid_t envid = sys_getenvid();
  8000fe:	e8 ee 0a 00 00       	call   800bf1 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
  800108:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800110:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800115:	85 db                	test   %ebx,%ebx
  800117:	7e 07                	jle    800120 <libmain+0x31>
		binaryname = argv[0];
  800119:	8b 06                	mov    (%esi),%eax
  80011b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800120:	83 ec 08             	sub    $0x8,%esp
  800123:	56                   	push   %esi
  800124:	53                   	push   %ebx
  800125:	e8 ac ff ff ff       	call   8000d6 <umain>

	// exit gracefully
	exit();
  80012a:	e8 0a 00 00 00       	call   800139 <exit>
}
  80012f:	83 c4 10             	add    $0x10,%esp
  800132:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800135:	5b                   	pop    %ebx
  800136:	5e                   	pop    %esi
  800137:	5d                   	pop    %ebp
  800138:	c3                   	ret    

00800139 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800139:	f3 0f 1e fb          	endbr32 
  80013d:	55                   	push   %ebp
  80013e:	89 e5                	mov    %esp,%ebp
  800140:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800143:	6a 00                	push   $0x0
  800145:	e8 62 0a 00 00       	call   800bac <sys_env_destroy>
}
  80014a:	83 c4 10             	add    $0x10,%esp
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80014f:	f3 0f 1e fb          	endbr32 
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	53                   	push   %ebx
  800157:	83 ec 04             	sub    $0x4,%esp
  80015a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80015d:	8b 13                	mov    (%ebx),%edx
  80015f:	8d 42 01             	lea    0x1(%edx),%eax
  800162:	89 03                	mov    %eax,(%ebx)
  800164:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800167:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80016b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800170:	74 09                	je     80017b <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800172:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800176:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800179:	c9                   	leave  
  80017a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80017b:	83 ec 08             	sub    $0x8,%esp
  80017e:	68 ff 00 00 00       	push   $0xff
  800183:	8d 43 08             	lea    0x8(%ebx),%eax
  800186:	50                   	push   %eax
  800187:	e8 db 09 00 00       	call   800b67 <sys_cputs>
		b->idx = 0;
  80018c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800192:	83 c4 10             	add    $0x10,%esp
  800195:	eb db                	jmp    800172 <putch+0x23>

00800197 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800197:	f3 0f 1e fb          	endbr32 
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ab:	00 00 00 
	b.cnt = 0;
  8001ae:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b8:	ff 75 0c             	pushl  0xc(%ebp)
  8001bb:	ff 75 08             	pushl  0x8(%ebp)
  8001be:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c4:	50                   	push   %eax
  8001c5:	68 4f 01 80 00       	push   $0x80014f
  8001ca:	e8 20 01 00 00       	call   8002ef <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001cf:	83 c4 08             	add    $0x8,%esp
  8001d2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001d8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001de:	50                   	push   %eax
  8001df:	e8 83 09 00 00       	call   800b67 <sys_cputs>

	return b.cnt;
}
  8001e4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ea:	c9                   	leave  
  8001eb:	c3                   	ret    

008001ec <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ec:	f3 0f 1e fb          	endbr32 
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f9:	50                   	push   %eax
  8001fa:	ff 75 08             	pushl  0x8(%ebp)
  8001fd:	e8 95 ff ff ff       	call   800197 <vcprintf>
	va_end(ap);

	return cnt;
}
  800202:	c9                   	leave  
  800203:	c3                   	ret    

00800204 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	57                   	push   %edi
  800208:	56                   	push   %esi
  800209:	53                   	push   %ebx
  80020a:	83 ec 1c             	sub    $0x1c,%esp
  80020d:	89 c7                	mov    %eax,%edi
  80020f:	89 d6                	mov    %edx,%esi
  800211:	8b 45 08             	mov    0x8(%ebp),%eax
  800214:	8b 55 0c             	mov    0xc(%ebp),%edx
  800217:	89 d1                	mov    %edx,%ecx
  800219:	89 c2                	mov    %eax,%edx
  80021b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80021e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800221:	8b 45 10             	mov    0x10(%ebp),%eax
  800224:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800227:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80022a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800231:	39 c2                	cmp    %eax,%edx
  800233:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800236:	72 3e                	jb     800276 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800238:	83 ec 0c             	sub    $0xc,%esp
  80023b:	ff 75 18             	pushl  0x18(%ebp)
  80023e:	83 eb 01             	sub    $0x1,%ebx
  800241:	53                   	push   %ebx
  800242:	50                   	push   %eax
  800243:	83 ec 08             	sub    $0x8,%esp
  800246:	ff 75 e4             	pushl  -0x1c(%ebp)
  800249:	ff 75 e0             	pushl  -0x20(%ebp)
  80024c:	ff 75 dc             	pushl  -0x24(%ebp)
  80024f:	ff 75 d8             	pushl  -0x28(%ebp)
  800252:	e8 e9 0e 00 00       	call   801140 <__udivdi3>
  800257:	83 c4 18             	add    $0x18,%esp
  80025a:	52                   	push   %edx
  80025b:	50                   	push   %eax
  80025c:	89 f2                	mov    %esi,%edx
  80025e:	89 f8                	mov    %edi,%eax
  800260:	e8 9f ff ff ff       	call   800204 <printnum>
  800265:	83 c4 20             	add    $0x20,%esp
  800268:	eb 13                	jmp    80027d <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026a:	83 ec 08             	sub    $0x8,%esp
  80026d:	56                   	push   %esi
  80026e:	ff 75 18             	pushl  0x18(%ebp)
  800271:	ff d7                	call   *%edi
  800273:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800276:	83 eb 01             	sub    $0x1,%ebx
  800279:	85 db                	test   %ebx,%ebx
  80027b:	7f ed                	jg     80026a <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80027d:	83 ec 08             	sub    $0x8,%esp
  800280:	56                   	push   %esi
  800281:	83 ec 04             	sub    $0x4,%esp
  800284:	ff 75 e4             	pushl  -0x1c(%ebp)
  800287:	ff 75 e0             	pushl  -0x20(%ebp)
  80028a:	ff 75 dc             	pushl  -0x24(%ebp)
  80028d:	ff 75 d8             	pushl  -0x28(%ebp)
  800290:	e8 bb 0f 00 00       	call   801250 <__umoddi3>
  800295:	83 c4 14             	add    $0x14,%esp
  800298:	0f be 80 c0 13 80 00 	movsbl 0x8013c0(%eax),%eax
  80029f:	50                   	push   %eax
  8002a0:	ff d7                	call   *%edi
}
  8002a2:	83 c4 10             	add    $0x10,%esp
  8002a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a8:	5b                   	pop    %ebx
  8002a9:	5e                   	pop    %esi
  8002aa:	5f                   	pop    %edi
  8002ab:	5d                   	pop    %ebp
  8002ac:	c3                   	ret    

008002ad <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ad:	f3 0f 1e fb          	endbr32 
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002bb:	8b 10                	mov    (%eax),%edx
  8002bd:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c0:	73 0a                	jae    8002cc <sprintputch+0x1f>
		*b->buf++ = ch;
  8002c2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ca:	88 02                	mov    %al,(%edx)
}
  8002cc:	5d                   	pop    %ebp
  8002cd:	c3                   	ret    

008002ce <printfmt>:
{
  8002ce:	f3 0f 1e fb          	endbr32 
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002d8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002db:	50                   	push   %eax
  8002dc:	ff 75 10             	pushl  0x10(%ebp)
  8002df:	ff 75 0c             	pushl  0xc(%ebp)
  8002e2:	ff 75 08             	pushl  0x8(%ebp)
  8002e5:	e8 05 00 00 00       	call   8002ef <vprintfmt>
}
  8002ea:	83 c4 10             	add    $0x10,%esp
  8002ed:	c9                   	leave  
  8002ee:	c3                   	ret    

008002ef <vprintfmt>:
{
  8002ef:	f3 0f 1e fb          	endbr32 
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	57                   	push   %edi
  8002f7:	56                   	push   %esi
  8002f8:	53                   	push   %ebx
  8002f9:	83 ec 3c             	sub    $0x3c,%esp
  8002fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8002ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800302:	8b 7d 10             	mov    0x10(%ebp),%edi
  800305:	e9 4a 03 00 00       	jmp    800654 <vprintfmt+0x365>
		padc = ' ';
  80030a:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80030e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800315:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80031c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800323:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800328:	8d 47 01             	lea    0x1(%edi),%eax
  80032b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80032e:	0f b6 17             	movzbl (%edi),%edx
  800331:	8d 42 dd             	lea    -0x23(%edx),%eax
  800334:	3c 55                	cmp    $0x55,%al
  800336:	0f 87 de 03 00 00    	ja     80071a <vprintfmt+0x42b>
  80033c:	0f b6 c0             	movzbl %al,%eax
  80033f:	3e ff 24 85 80 14 80 	notrack jmp *0x801480(,%eax,4)
  800346:	00 
  800347:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80034a:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80034e:	eb d8                	jmp    800328 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800350:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800353:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800357:	eb cf                	jmp    800328 <vprintfmt+0x39>
  800359:	0f b6 d2             	movzbl %dl,%edx
  80035c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80035f:	b8 00 00 00 00       	mov    $0x0,%eax
  800364:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800367:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80036a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80036e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800371:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800374:	83 f9 09             	cmp    $0x9,%ecx
  800377:	77 55                	ja     8003ce <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800379:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80037c:	eb e9                	jmp    800367 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80037e:	8b 45 14             	mov    0x14(%ebp),%eax
  800381:	8b 00                	mov    (%eax),%eax
  800383:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800386:	8b 45 14             	mov    0x14(%ebp),%eax
  800389:	8d 40 04             	lea    0x4(%eax),%eax
  80038c:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80038f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800392:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800396:	79 90                	jns    800328 <vprintfmt+0x39>
				width = precision, precision = -1;
  800398:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80039b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80039e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003a5:	eb 81                	jmp    800328 <vprintfmt+0x39>
  8003a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003aa:	85 c0                	test   %eax,%eax
  8003ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b1:	0f 49 d0             	cmovns %eax,%edx
  8003b4:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003ba:	e9 69 ff ff ff       	jmp    800328 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003c2:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003c9:	e9 5a ff ff ff       	jmp    800328 <vprintfmt+0x39>
  8003ce:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003d4:	eb bc                	jmp    800392 <vprintfmt+0xa3>
			lflag++;
  8003d6:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003dc:	e9 47 ff ff ff       	jmp    800328 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e4:	8d 78 04             	lea    0x4(%eax),%edi
  8003e7:	83 ec 08             	sub    $0x8,%esp
  8003ea:	53                   	push   %ebx
  8003eb:	ff 30                	pushl  (%eax)
  8003ed:	ff d6                	call   *%esi
			break;
  8003ef:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003f2:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003f5:	e9 57 02 00 00       	jmp    800651 <vprintfmt+0x362>
			err = va_arg(ap, int);
  8003fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fd:	8d 78 04             	lea    0x4(%eax),%edi
  800400:	8b 00                	mov    (%eax),%eax
  800402:	99                   	cltd   
  800403:	31 d0                	xor    %edx,%eax
  800405:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800407:	83 f8 08             	cmp    $0x8,%eax
  80040a:	7f 23                	jg     80042f <vprintfmt+0x140>
  80040c:	8b 14 85 e0 15 80 00 	mov    0x8015e0(,%eax,4),%edx
  800413:	85 d2                	test   %edx,%edx
  800415:	74 18                	je     80042f <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800417:	52                   	push   %edx
  800418:	68 e1 13 80 00       	push   $0x8013e1
  80041d:	53                   	push   %ebx
  80041e:	56                   	push   %esi
  80041f:	e8 aa fe ff ff       	call   8002ce <printfmt>
  800424:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800427:	89 7d 14             	mov    %edi,0x14(%ebp)
  80042a:	e9 22 02 00 00       	jmp    800651 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  80042f:	50                   	push   %eax
  800430:	68 d8 13 80 00       	push   $0x8013d8
  800435:	53                   	push   %ebx
  800436:	56                   	push   %esi
  800437:	e8 92 fe ff ff       	call   8002ce <printfmt>
  80043c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80043f:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800442:	e9 0a 02 00 00       	jmp    800651 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	83 c0 04             	add    $0x4,%eax
  80044d:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800450:	8b 45 14             	mov    0x14(%ebp),%eax
  800453:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800455:	85 d2                	test   %edx,%edx
  800457:	b8 d1 13 80 00       	mov    $0x8013d1,%eax
  80045c:	0f 45 c2             	cmovne %edx,%eax
  80045f:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800462:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800466:	7e 06                	jle    80046e <vprintfmt+0x17f>
  800468:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80046c:	75 0d                	jne    80047b <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80046e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800471:	89 c7                	mov    %eax,%edi
  800473:	03 45 e0             	add    -0x20(%ebp),%eax
  800476:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800479:	eb 55                	jmp    8004d0 <vprintfmt+0x1e1>
  80047b:	83 ec 08             	sub    $0x8,%esp
  80047e:	ff 75 d8             	pushl  -0x28(%ebp)
  800481:	ff 75 cc             	pushl  -0x34(%ebp)
  800484:	e8 45 03 00 00       	call   8007ce <strnlen>
  800489:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80048c:	29 c2                	sub    %eax,%edx
  80048e:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800491:	83 c4 10             	add    $0x10,%esp
  800494:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800496:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80049a:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80049d:	85 ff                	test   %edi,%edi
  80049f:	7e 11                	jle    8004b2 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004a1:	83 ec 08             	sub    $0x8,%esp
  8004a4:	53                   	push   %ebx
  8004a5:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a8:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004aa:	83 ef 01             	sub    $0x1,%edi
  8004ad:	83 c4 10             	add    $0x10,%esp
  8004b0:	eb eb                	jmp    80049d <vprintfmt+0x1ae>
  8004b2:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004b5:	85 d2                	test   %edx,%edx
  8004b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004bc:	0f 49 c2             	cmovns %edx,%eax
  8004bf:	29 c2                	sub    %eax,%edx
  8004c1:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004c4:	eb a8                	jmp    80046e <vprintfmt+0x17f>
					putch(ch, putdat);
  8004c6:	83 ec 08             	sub    $0x8,%esp
  8004c9:	53                   	push   %ebx
  8004ca:	52                   	push   %edx
  8004cb:	ff d6                	call   *%esi
  8004cd:	83 c4 10             	add    $0x10,%esp
  8004d0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d3:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d5:	83 c7 01             	add    $0x1,%edi
  8004d8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004dc:	0f be d0             	movsbl %al,%edx
  8004df:	85 d2                	test   %edx,%edx
  8004e1:	74 4b                	je     80052e <vprintfmt+0x23f>
  8004e3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e7:	78 06                	js     8004ef <vprintfmt+0x200>
  8004e9:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004ed:	78 1e                	js     80050d <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ef:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004f3:	74 d1                	je     8004c6 <vprintfmt+0x1d7>
  8004f5:	0f be c0             	movsbl %al,%eax
  8004f8:	83 e8 20             	sub    $0x20,%eax
  8004fb:	83 f8 5e             	cmp    $0x5e,%eax
  8004fe:	76 c6                	jbe    8004c6 <vprintfmt+0x1d7>
					putch('?', putdat);
  800500:	83 ec 08             	sub    $0x8,%esp
  800503:	53                   	push   %ebx
  800504:	6a 3f                	push   $0x3f
  800506:	ff d6                	call   *%esi
  800508:	83 c4 10             	add    $0x10,%esp
  80050b:	eb c3                	jmp    8004d0 <vprintfmt+0x1e1>
  80050d:	89 cf                	mov    %ecx,%edi
  80050f:	eb 0e                	jmp    80051f <vprintfmt+0x230>
				putch(' ', putdat);
  800511:	83 ec 08             	sub    $0x8,%esp
  800514:	53                   	push   %ebx
  800515:	6a 20                	push   $0x20
  800517:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800519:	83 ef 01             	sub    $0x1,%edi
  80051c:	83 c4 10             	add    $0x10,%esp
  80051f:	85 ff                	test   %edi,%edi
  800521:	7f ee                	jg     800511 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800523:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800526:	89 45 14             	mov    %eax,0x14(%ebp)
  800529:	e9 23 01 00 00       	jmp    800651 <vprintfmt+0x362>
  80052e:	89 cf                	mov    %ecx,%edi
  800530:	eb ed                	jmp    80051f <vprintfmt+0x230>
	if (lflag >= 2)
  800532:	83 f9 01             	cmp    $0x1,%ecx
  800535:	7f 1b                	jg     800552 <vprintfmt+0x263>
	else if (lflag)
  800537:	85 c9                	test   %ecx,%ecx
  800539:	74 63                	je     80059e <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80053b:	8b 45 14             	mov    0x14(%ebp),%eax
  80053e:	8b 00                	mov    (%eax),%eax
  800540:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800543:	99                   	cltd   
  800544:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800547:	8b 45 14             	mov    0x14(%ebp),%eax
  80054a:	8d 40 04             	lea    0x4(%eax),%eax
  80054d:	89 45 14             	mov    %eax,0x14(%ebp)
  800550:	eb 17                	jmp    800569 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800552:	8b 45 14             	mov    0x14(%ebp),%eax
  800555:	8b 50 04             	mov    0x4(%eax),%edx
  800558:	8b 00                	mov    (%eax),%eax
  80055a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800560:	8b 45 14             	mov    0x14(%ebp),%eax
  800563:	8d 40 08             	lea    0x8(%eax),%eax
  800566:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800569:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80056c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80056f:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800574:	85 c9                	test   %ecx,%ecx
  800576:	0f 89 bb 00 00 00    	jns    800637 <vprintfmt+0x348>
				putch('-', putdat);
  80057c:	83 ec 08             	sub    $0x8,%esp
  80057f:	53                   	push   %ebx
  800580:	6a 2d                	push   $0x2d
  800582:	ff d6                	call   *%esi
				num = -(long long) num;
  800584:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800587:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80058a:	f7 da                	neg    %edx
  80058c:	83 d1 00             	adc    $0x0,%ecx
  80058f:	f7 d9                	neg    %ecx
  800591:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800594:	b8 0a 00 00 00       	mov    $0xa,%eax
  800599:	e9 99 00 00 00       	jmp    800637 <vprintfmt+0x348>
		return va_arg(*ap, int);
  80059e:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a1:	8b 00                	mov    (%eax),%eax
  8005a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a6:	99                   	cltd   
  8005a7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ad:	8d 40 04             	lea    0x4(%eax),%eax
  8005b0:	89 45 14             	mov    %eax,0x14(%ebp)
  8005b3:	eb b4                	jmp    800569 <vprintfmt+0x27a>
	if (lflag >= 2)
  8005b5:	83 f9 01             	cmp    $0x1,%ecx
  8005b8:	7f 1b                	jg     8005d5 <vprintfmt+0x2e6>
	else if (lflag)
  8005ba:	85 c9                	test   %ecx,%ecx
  8005bc:	74 2c                	je     8005ea <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8b 10                	mov    (%eax),%edx
  8005c3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c8:	8d 40 04             	lea    0x4(%eax),%eax
  8005cb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ce:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005d3:	eb 62                	jmp    800637 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8005d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d8:	8b 10                	mov    (%eax),%edx
  8005da:	8b 48 04             	mov    0x4(%eax),%ecx
  8005dd:	8d 40 08             	lea    0x8(%eax),%eax
  8005e0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e3:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005e8:	eb 4d                	jmp    800637 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8005ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ed:	8b 10                	mov    (%eax),%edx
  8005ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f4:	8d 40 04             	lea    0x4(%eax),%eax
  8005f7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005fa:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8005ff:	eb 36                	jmp    800637 <vprintfmt+0x348>
	if (lflag >= 2)
  800601:	83 f9 01             	cmp    $0x1,%ecx
  800604:	7f 17                	jg     80061d <vprintfmt+0x32e>
	else if (lflag)
  800606:	85 c9                	test   %ecx,%ecx
  800608:	74 6e                	je     800678 <vprintfmt+0x389>
		return va_arg(*ap, long);
  80060a:	8b 45 14             	mov    0x14(%ebp),%eax
  80060d:	8b 10                	mov    (%eax),%edx
  80060f:	89 d0                	mov    %edx,%eax
  800611:	99                   	cltd   
  800612:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800615:	8d 49 04             	lea    0x4(%ecx),%ecx
  800618:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80061b:	eb 11                	jmp    80062e <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  80061d:	8b 45 14             	mov    0x14(%ebp),%eax
  800620:	8b 50 04             	mov    0x4(%eax),%edx
  800623:	8b 00                	mov    (%eax),%eax
  800625:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800628:	8d 49 08             	lea    0x8(%ecx),%ecx
  80062b:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  80062e:	89 d1                	mov    %edx,%ecx
  800630:	89 c2                	mov    %eax,%edx
            base = 8;
  800632:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800637:	83 ec 0c             	sub    $0xc,%esp
  80063a:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80063e:	57                   	push   %edi
  80063f:	ff 75 e0             	pushl  -0x20(%ebp)
  800642:	50                   	push   %eax
  800643:	51                   	push   %ecx
  800644:	52                   	push   %edx
  800645:	89 da                	mov    %ebx,%edx
  800647:	89 f0                	mov    %esi,%eax
  800649:	e8 b6 fb ff ff       	call   800204 <printnum>
			break;
  80064e:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800651:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800654:	83 c7 01             	add    $0x1,%edi
  800657:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80065b:	83 f8 25             	cmp    $0x25,%eax
  80065e:	0f 84 a6 fc ff ff    	je     80030a <vprintfmt+0x1b>
			if (ch == '\0')
  800664:	85 c0                	test   %eax,%eax
  800666:	0f 84 ce 00 00 00    	je     80073a <vprintfmt+0x44b>
			putch(ch, putdat);
  80066c:	83 ec 08             	sub    $0x8,%esp
  80066f:	53                   	push   %ebx
  800670:	50                   	push   %eax
  800671:	ff d6                	call   *%esi
  800673:	83 c4 10             	add    $0x10,%esp
  800676:	eb dc                	jmp    800654 <vprintfmt+0x365>
		return va_arg(*ap, int);
  800678:	8b 45 14             	mov    0x14(%ebp),%eax
  80067b:	8b 10                	mov    (%eax),%edx
  80067d:	89 d0                	mov    %edx,%eax
  80067f:	99                   	cltd   
  800680:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800683:	8d 49 04             	lea    0x4(%ecx),%ecx
  800686:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800689:	eb a3                	jmp    80062e <vprintfmt+0x33f>
			putch('0', putdat);
  80068b:	83 ec 08             	sub    $0x8,%esp
  80068e:	53                   	push   %ebx
  80068f:	6a 30                	push   $0x30
  800691:	ff d6                	call   *%esi
			putch('x', putdat);
  800693:	83 c4 08             	add    $0x8,%esp
  800696:	53                   	push   %ebx
  800697:	6a 78                	push   $0x78
  800699:	ff d6                	call   *%esi
			num = (unsigned long long)
  80069b:	8b 45 14             	mov    0x14(%ebp),%eax
  80069e:	8b 10                	mov    (%eax),%edx
  8006a0:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006a5:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006a8:	8d 40 04             	lea    0x4(%eax),%eax
  8006ab:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ae:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006b3:	eb 82                	jmp    800637 <vprintfmt+0x348>
	if (lflag >= 2)
  8006b5:	83 f9 01             	cmp    $0x1,%ecx
  8006b8:	7f 1e                	jg     8006d8 <vprintfmt+0x3e9>
	else if (lflag)
  8006ba:	85 c9                	test   %ecx,%ecx
  8006bc:	74 32                	je     8006f0 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  8006be:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c1:	8b 10                	mov    (%eax),%edx
  8006c3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c8:	8d 40 04             	lea    0x4(%eax),%eax
  8006cb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ce:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006d3:	e9 5f ff ff ff       	jmp    800637 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8006d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006db:	8b 10                	mov    (%eax),%edx
  8006dd:	8b 48 04             	mov    0x4(%eax),%ecx
  8006e0:	8d 40 08             	lea    0x8(%eax),%eax
  8006e3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e6:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006eb:	e9 47 ff ff ff       	jmp    800637 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8006f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f3:	8b 10                	mov    (%eax),%edx
  8006f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006fa:	8d 40 04             	lea    0x4(%eax),%eax
  8006fd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800700:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800705:	e9 2d ff ff ff       	jmp    800637 <vprintfmt+0x348>
			putch(ch, putdat);
  80070a:	83 ec 08             	sub    $0x8,%esp
  80070d:	53                   	push   %ebx
  80070e:	6a 25                	push   $0x25
  800710:	ff d6                	call   *%esi
			break;
  800712:	83 c4 10             	add    $0x10,%esp
  800715:	e9 37 ff ff ff       	jmp    800651 <vprintfmt+0x362>
			putch('%', putdat);
  80071a:	83 ec 08             	sub    $0x8,%esp
  80071d:	53                   	push   %ebx
  80071e:	6a 25                	push   $0x25
  800720:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800722:	83 c4 10             	add    $0x10,%esp
  800725:	89 f8                	mov    %edi,%eax
  800727:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80072b:	74 05                	je     800732 <vprintfmt+0x443>
  80072d:	83 e8 01             	sub    $0x1,%eax
  800730:	eb f5                	jmp    800727 <vprintfmt+0x438>
  800732:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800735:	e9 17 ff ff ff       	jmp    800651 <vprintfmt+0x362>
}
  80073a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80073d:	5b                   	pop    %ebx
  80073e:	5e                   	pop    %esi
  80073f:	5f                   	pop    %edi
  800740:	5d                   	pop    %ebp
  800741:	c3                   	ret    

00800742 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800742:	f3 0f 1e fb          	endbr32 
  800746:	55                   	push   %ebp
  800747:	89 e5                	mov    %esp,%ebp
  800749:	83 ec 18             	sub    $0x18,%esp
  80074c:	8b 45 08             	mov    0x8(%ebp),%eax
  80074f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800752:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800755:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800759:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80075c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800763:	85 c0                	test   %eax,%eax
  800765:	74 26                	je     80078d <vsnprintf+0x4b>
  800767:	85 d2                	test   %edx,%edx
  800769:	7e 22                	jle    80078d <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80076b:	ff 75 14             	pushl  0x14(%ebp)
  80076e:	ff 75 10             	pushl  0x10(%ebp)
  800771:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800774:	50                   	push   %eax
  800775:	68 ad 02 80 00       	push   $0x8002ad
  80077a:	e8 70 fb ff ff       	call   8002ef <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80077f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800782:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800785:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800788:	83 c4 10             	add    $0x10,%esp
}
  80078b:	c9                   	leave  
  80078c:	c3                   	ret    
		return -E_INVAL;
  80078d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800792:	eb f7                	jmp    80078b <vsnprintf+0x49>

00800794 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800794:	f3 0f 1e fb          	endbr32 
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80079e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a1:	50                   	push   %eax
  8007a2:	ff 75 10             	pushl  0x10(%ebp)
  8007a5:	ff 75 0c             	pushl  0xc(%ebp)
  8007a8:	ff 75 08             	pushl  0x8(%ebp)
  8007ab:	e8 92 ff ff ff       	call   800742 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b0:	c9                   	leave  
  8007b1:	c3                   	ret    

008007b2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b2:	f3 0f 1e fb          	endbr32 
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007c5:	74 05                	je     8007cc <strlen+0x1a>
		n++;
  8007c7:	83 c0 01             	add    $0x1,%eax
  8007ca:	eb f5                	jmp    8007c1 <strlen+0xf>
	return n;
}
  8007cc:	5d                   	pop    %ebp
  8007cd:	c3                   	ret    

008007ce <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ce:	f3 0f 1e fb          	endbr32 
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007db:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e0:	39 d0                	cmp    %edx,%eax
  8007e2:	74 0d                	je     8007f1 <strnlen+0x23>
  8007e4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007e8:	74 05                	je     8007ef <strnlen+0x21>
		n++;
  8007ea:	83 c0 01             	add    $0x1,%eax
  8007ed:	eb f1                	jmp    8007e0 <strnlen+0x12>
  8007ef:	89 c2                	mov    %eax,%edx
	return n;
}
  8007f1:	89 d0                	mov    %edx,%eax
  8007f3:	5d                   	pop    %ebp
  8007f4:	c3                   	ret    

008007f5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f5:	f3 0f 1e fb          	endbr32 
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	53                   	push   %ebx
  8007fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800800:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800803:	b8 00 00 00 00       	mov    $0x0,%eax
  800808:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80080c:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80080f:	83 c0 01             	add    $0x1,%eax
  800812:	84 d2                	test   %dl,%dl
  800814:	75 f2                	jne    800808 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800816:	89 c8                	mov    %ecx,%eax
  800818:	5b                   	pop    %ebx
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80081b:	f3 0f 1e fb          	endbr32 
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	53                   	push   %ebx
  800823:	83 ec 10             	sub    $0x10,%esp
  800826:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800829:	53                   	push   %ebx
  80082a:	e8 83 ff ff ff       	call   8007b2 <strlen>
  80082f:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800832:	ff 75 0c             	pushl  0xc(%ebp)
  800835:	01 d8                	add    %ebx,%eax
  800837:	50                   	push   %eax
  800838:	e8 b8 ff ff ff       	call   8007f5 <strcpy>
	return dst;
}
  80083d:	89 d8                	mov    %ebx,%eax
  80083f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800842:	c9                   	leave  
  800843:	c3                   	ret    

00800844 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800844:	f3 0f 1e fb          	endbr32 
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	56                   	push   %esi
  80084c:	53                   	push   %ebx
  80084d:	8b 75 08             	mov    0x8(%ebp),%esi
  800850:	8b 55 0c             	mov    0xc(%ebp),%edx
  800853:	89 f3                	mov    %esi,%ebx
  800855:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800858:	89 f0                	mov    %esi,%eax
  80085a:	39 d8                	cmp    %ebx,%eax
  80085c:	74 11                	je     80086f <strncpy+0x2b>
		*dst++ = *src;
  80085e:	83 c0 01             	add    $0x1,%eax
  800861:	0f b6 0a             	movzbl (%edx),%ecx
  800864:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800867:	80 f9 01             	cmp    $0x1,%cl
  80086a:	83 da ff             	sbb    $0xffffffff,%edx
  80086d:	eb eb                	jmp    80085a <strncpy+0x16>
	}
	return ret;
}
  80086f:	89 f0                	mov    %esi,%eax
  800871:	5b                   	pop    %ebx
  800872:	5e                   	pop    %esi
  800873:	5d                   	pop    %ebp
  800874:	c3                   	ret    

00800875 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800875:	f3 0f 1e fb          	endbr32 
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	56                   	push   %esi
  80087d:	53                   	push   %ebx
  80087e:	8b 75 08             	mov    0x8(%ebp),%esi
  800881:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800884:	8b 55 10             	mov    0x10(%ebp),%edx
  800887:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800889:	85 d2                	test   %edx,%edx
  80088b:	74 21                	je     8008ae <strlcpy+0x39>
  80088d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800891:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800893:	39 c2                	cmp    %eax,%edx
  800895:	74 14                	je     8008ab <strlcpy+0x36>
  800897:	0f b6 19             	movzbl (%ecx),%ebx
  80089a:	84 db                	test   %bl,%bl
  80089c:	74 0b                	je     8008a9 <strlcpy+0x34>
			*dst++ = *src++;
  80089e:	83 c1 01             	add    $0x1,%ecx
  8008a1:	83 c2 01             	add    $0x1,%edx
  8008a4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008a7:	eb ea                	jmp    800893 <strlcpy+0x1e>
  8008a9:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008ab:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008ae:	29 f0                	sub    %esi,%eax
}
  8008b0:	5b                   	pop    %ebx
  8008b1:	5e                   	pop    %esi
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b4:	f3 0f 1e fb          	endbr32 
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008be:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c1:	0f b6 01             	movzbl (%ecx),%eax
  8008c4:	84 c0                	test   %al,%al
  8008c6:	74 0c                	je     8008d4 <strcmp+0x20>
  8008c8:	3a 02                	cmp    (%edx),%al
  8008ca:	75 08                	jne    8008d4 <strcmp+0x20>
		p++, q++;
  8008cc:	83 c1 01             	add    $0x1,%ecx
  8008cf:	83 c2 01             	add    $0x1,%edx
  8008d2:	eb ed                	jmp    8008c1 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d4:	0f b6 c0             	movzbl %al,%eax
  8008d7:	0f b6 12             	movzbl (%edx),%edx
  8008da:	29 d0                	sub    %edx,%eax
}
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008de:	f3 0f 1e fb          	endbr32 
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	53                   	push   %ebx
  8008e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ec:	89 c3                	mov    %eax,%ebx
  8008ee:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008f1:	eb 06                	jmp    8008f9 <strncmp+0x1b>
		n--, p++, q++;
  8008f3:	83 c0 01             	add    $0x1,%eax
  8008f6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008f9:	39 d8                	cmp    %ebx,%eax
  8008fb:	74 16                	je     800913 <strncmp+0x35>
  8008fd:	0f b6 08             	movzbl (%eax),%ecx
  800900:	84 c9                	test   %cl,%cl
  800902:	74 04                	je     800908 <strncmp+0x2a>
  800904:	3a 0a                	cmp    (%edx),%cl
  800906:	74 eb                	je     8008f3 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800908:	0f b6 00             	movzbl (%eax),%eax
  80090b:	0f b6 12             	movzbl (%edx),%edx
  80090e:	29 d0                	sub    %edx,%eax
}
  800910:	5b                   	pop    %ebx
  800911:	5d                   	pop    %ebp
  800912:	c3                   	ret    
		return 0;
  800913:	b8 00 00 00 00       	mov    $0x0,%eax
  800918:	eb f6                	jmp    800910 <strncmp+0x32>

0080091a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80091a:	f3 0f 1e fb          	endbr32 
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	8b 45 08             	mov    0x8(%ebp),%eax
  800924:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800928:	0f b6 10             	movzbl (%eax),%edx
  80092b:	84 d2                	test   %dl,%dl
  80092d:	74 09                	je     800938 <strchr+0x1e>
		if (*s == c)
  80092f:	38 ca                	cmp    %cl,%dl
  800931:	74 0a                	je     80093d <strchr+0x23>
	for (; *s; s++)
  800933:	83 c0 01             	add    $0x1,%eax
  800936:	eb f0                	jmp    800928 <strchr+0xe>
			return (char *) s;
	return 0;
  800938:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    

0080093f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093f:	f3 0f 1e fb          	endbr32 
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	8b 45 08             	mov    0x8(%ebp),%eax
  800949:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80094d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800950:	38 ca                	cmp    %cl,%dl
  800952:	74 09                	je     80095d <strfind+0x1e>
  800954:	84 d2                	test   %dl,%dl
  800956:	74 05                	je     80095d <strfind+0x1e>
	for (; *s; s++)
  800958:	83 c0 01             	add    $0x1,%eax
  80095b:	eb f0                	jmp    80094d <strfind+0xe>
			break;
	return (char *) s;
}
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80095f:	f3 0f 1e fb          	endbr32 
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	57                   	push   %edi
  800967:	56                   	push   %esi
  800968:	53                   	push   %ebx
  800969:	8b 7d 08             	mov    0x8(%ebp),%edi
  80096c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80096f:	85 c9                	test   %ecx,%ecx
  800971:	74 31                	je     8009a4 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800973:	89 f8                	mov    %edi,%eax
  800975:	09 c8                	or     %ecx,%eax
  800977:	a8 03                	test   $0x3,%al
  800979:	75 23                	jne    80099e <memset+0x3f>
		c &= 0xFF;
  80097b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80097f:	89 d3                	mov    %edx,%ebx
  800981:	c1 e3 08             	shl    $0x8,%ebx
  800984:	89 d0                	mov    %edx,%eax
  800986:	c1 e0 18             	shl    $0x18,%eax
  800989:	89 d6                	mov    %edx,%esi
  80098b:	c1 e6 10             	shl    $0x10,%esi
  80098e:	09 f0                	or     %esi,%eax
  800990:	09 c2                	or     %eax,%edx
  800992:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800994:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800997:	89 d0                	mov    %edx,%eax
  800999:	fc                   	cld    
  80099a:	f3 ab                	rep stos %eax,%es:(%edi)
  80099c:	eb 06                	jmp    8009a4 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80099e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a1:	fc                   	cld    
  8009a2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009a4:	89 f8                	mov    %edi,%eax
  8009a6:	5b                   	pop    %ebx
  8009a7:	5e                   	pop    %esi
  8009a8:	5f                   	pop    %edi
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009ab:	f3 0f 1e fb          	endbr32 
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	57                   	push   %edi
  8009b3:	56                   	push   %esi
  8009b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009bd:	39 c6                	cmp    %eax,%esi
  8009bf:	73 32                	jae    8009f3 <memmove+0x48>
  8009c1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009c4:	39 c2                	cmp    %eax,%edx
  8009c6:	76 2b                	jbe    8009f3 <memmove+0x48>
		s += n;
		d += n;
  8009c8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cb:	89 fe                	mov    %edi,%esi
  8009cd:	09 ce                	or     %ecx,%esi
  8009cf:	09 d6                	or     %edx,%esi
  8009d1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d7:	75 0e                	jne    8009e7 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009d9:	83 ef 04             	sub    $0x4,%edi
  8009dc:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009df:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009e2:	fd                   	std    
  8009e3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e5:	eb 09                	jmp    8009f0 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009e7:	83 ef 01             	sub    $0x1,%edi
  8009ea:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009ed:	fd                   	std    
  8009ee:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009f0:	fc                   	cld    
  8009f1:	eb 1a                	jmp    800a0d <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f3:	89 c2                	mov    %eax,%edx
  8009f5:	09 ca                	or     %ecx,%edx
  8009f7:	09 f2                	or     %esi,%edx
  8009f9:	f6 c2 03             	test   $0x3,%dl
  8009fc:	75 0a                	jne    800a08 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009fe:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a01:	89 c7                	mov    %eax,%edi
  800a03:	fc                   	cld    
  800a04:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a06:	eb 05                	jmp    800a0d <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a08:	89 c7                	mov    %eax,%edi
  800a0a:	fc                   	cld    
  800a0b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a0d:	5e                   	pop    %esi
  800a0e:	5f                   	pop    %edi
  800a0f:	5d                   	pop    %ebp
  800a10:	c3                   	ret    

00800a11 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a11:	f3 0f 1e fb          	endbr32 
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a1b:	ff 75 10             	pushl  0x10(%ebp)
  800a1e:	ff 75 0c             	pushl  0xc(%ebp)
  800a21:	ff 75 08             	pushl  0x8(%ebp)
  800a24:	e8 82 ff ff ff       	call   8009ab <memmove>
}
  800a29:	c9                   	leave  
  800a2a:	c3                   	ret    

00800a2b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a2b:	f3 0f 1e fb          	endbr32 
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	56                   	push   %esi
  800a33:	53                   	push   %ebx
  800a34:	8b 45 08             	mov    0x8(%ebp),%eax
  800a37:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a3a:	89 c6                	mov    %eax,%esi
  800a3c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3f:	39 f0                	cmp    %esi,%eax
  800a41:	74 1c                	je     800a5f <memcmp+0x34>
		if (*s1 != *s2)
  800a43:	0f b6 08             	movzbl (%eax),%ecx
  800a46:	0f b6 1a             	movzbl (%edx),%ebx
  800a49:	38 d9                	cmp    %bl,%cl
  800a4b:	75 08                	jne    800a55 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a4d:	83 c0 01             	add    $0x1,%eax
  800a50:	83 c2 01             	add    $0x1,%edx
  800a53:	eb ea                	jmp    800a3f <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a55:	0f b6 c1             	movzbl %cl,%eax
  800a58:	0f b6 db             	movzbl %bl,%ebx
  800a5b:	29 d8                	sub    %ebx,%eax
  800a5d:	eb 05                	jmp    800a64 <memcmp+0x39>
	}

	return 0;
  800a5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a64:	5b                   	pop    %ebx
  800a65:	5e                   	pop    %esi
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a68:	f3 0f 1e fb          	endbr32 
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a75:	89 c2                	mov    %eax,%edx
  800a77:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a7a:	39 d0                	cmp    %edx,%eax
  800a7c:	73 09                	jae    800a87 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a7e:	38 08                	cmp    %cl,(%eax)
  800a80:	74 05                	je     800a87 <memfind+0x1f>
	for (; s < ends; s++)
  800a82:	83 c0 01             	add    $0x1,%eax
  800a85:	eb f3                	jmp    800a7a <memfind+0x12>
			break;
	return (void *) s;
}
  800a87:	5d                   	pop    %ebp
  800a88:	c3                   	ret    

00800a89 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a89:	f3 0f 1e fb          	endbr32 
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	57                   	push   %edi
  800a91:	56                   	push   %esi
  800a92:	53                   	push   %ebx
  800a93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a96:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a99:	eb 03                	jmp    800a9e <strtol+0x15>
		s++;
  800a9b:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a9e:	0f b6 01             	movzbl (%ecx),%eax
  800aa1:	3c 20                	cmp    $0x20,%al
  800aa3:	74 f6                	je     800a9b <strtol+0x12>
  800aa5:	3c 09                	cmp    $0x9,%al
  800aa7:	74 f2                	je     800a9b <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800aa9:	3c 2b                	cmp    $0x2b,%al
  800aab:	74 2a                	je     800ad7 <strtol+0x4e>
	int neg = 0;
  800aad:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ab2:	3c 2d                	cmp    $0x2d,%al
  800ab4:	74 2b                	je     800ae1 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800abc:	75 0f                	jne    800acd <strtol+0x44>
  800abe:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac1:	74 28                	je     800aeb <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ac3:	85 db                	test   %ebx,%ebx
  800ac5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aca:	0f 44 d8             	cmove  %eax,%ebx
  800acd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad2:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ad5:	eb 46                	jmp    800b1d <strtol+0x94>
		s++;
  800ad7:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ada:	bf 00 00 00 00       	mov    $0x0,%edi
  800adf:	eb d5                	jmp    800ab6 <strtol+0x2d>
		s++, neg = 1;
  800ae1:	83 c1 01             	add    $0x1,%ecx
  800ae4:	bf 01 00 00 00       	mov    $0x1,%edi
  800ae9:	eb cb                	jmp    800ab6 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aeb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aef:	74 0e                	je     800aff <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800af1:	85 db                	test   %ebx,%ebx
  800af3:	75 d8                	jne    800acd <strtol+0x44>
		s++, base = 8;
  800af5:	83 c1 01             	add    $0x1,%ecx
  800af8:	bb 08 00 00 00       	mov    $0x8,%ebx
  800afd:	eb ce                	jmp    800acd <strtol+0x44>
		s += 2, base = 16;
  800aff:	83 c1 02             	add    $0x2,%ecx
  800b02:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b07:	eb c4                	jmp    800acd <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b09:	0f be d2             	movsbl %dl,%edx
  800b0c:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b0f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b12:	7d 3a                	jge    800b4e <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b14:	83 c1 01             	add    $0x1,%ecx
  800b17:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b1b:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b1d:	0f b6 11             	movzbl (%ecx),%edx
  800b20:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b23:	89 f3                	mov    %esi,%ebx
  800b25:	80 fb 09             	cmp    $0x9,%bl
  800b28:	76 df                	jbe    800b09 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b2a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b2d:	89 f3                	mov    %esi,%ebx
  800b2f:	80 fb 19             	cmp    $0x19,%bl
  800b32:	77 08                	ja     800b3c <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b34:	0f be d2             	movsbl %dl,%edx
  800b37:	83 ea 57             	sub    $0x57,%edx
  800b3a:	eb d3                	jmp    800b0f <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b3c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b3f:	89 f3                	mov    %esi,%ebx
  800b41:	80 fb 19             	cmp    $0x19,%bl
  800b44:	77 08                	ja     800b4e <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b46:	0f be d2             	movsbl %dl,%edx
  800b49:	83 ea 37             	sub    $0x37,%edx
  800b4c:	eb c1                	jmp    800b0f <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b4e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b52:	74 05                	je     800b59 <strtol+0xd0>
		*endptr = (char *) s;
  800b54:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b57:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b59:	89 c2                	mov    %eax,%edx
  800b5b:	f7 da                	neg    %edx
  800b5d:	85 ff                	test   %edi,%edi
  800b5f:	0f 45 c2             	cmovne %edx,%eax
}
  800b62:	5b                   	pop    %ebx
  800b63:	5e                   	pop    %esi
  800b64:	5f                   	pop    %edi
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    

00800b67 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b67:	f3 0f 1e fb          	endbr32 
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	57                   	push   %edi
  800b6f:	56                   	push   %esi
  800b70:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b71:	b8 00 00 00 00       	mov    $0x0,%eax
  800b76:	8b 55 08             	mov    0x8(%ebp),%edx
  800b79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7c:	89 c3                	mov    %eax,%ebx
  800b7e:	89 c7                	mov    %eax,%edi
  800b80:	89 c6                	mov    %eax,%esi
  800b82:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5f                   	pop    %edi
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    

00800b89 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b89:	f3 0f 1e fb          	endbr32 
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	57                   	push   %edi
  800b91:	56                   	push   %esi
  800b92:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b93:	ba 00 00 00 00       	mov    $0x0,%edx
  800b98:	b8 01 00 00 00       	mov    $0x1,%eax
  800b9d:	89 d1                	mov    %edx,%ecx
  800b9f:	89 d3                	mov    %edx,%ebx
  800ba1:	89 d7                	mov    %edx,%edi
  800ba3:	89 d6                	mov    %edx,%esi
  800ba5:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ba7:	5b                   	pop    %ebx
  800ba8:	5e                   	pop    %esi
  800ba9:	5f                   	pop    %edi
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bac:	f3 0f 1e fb          	endbr32 
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	57                   	push   %edi
  800bb4:	56                   	push   %esi
  800bb5:	53                   	push   %ebx
  800bb6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bb9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc1:	b8 03 00 00 00       	mov    $0x3,%eax
  800bc6:	89 cb                	mov    %ecx,%ebx
  800bc8:	89 cf                	mov    %ecx,%edi
  800bca:	89 ce                	mov    %ecx,%esi
  800bcc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bce:	85 c0                	test   %eax,%eax
  800bd0:	7f 08                	jg     800bda <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd5:	5b                   	pop    %ebx
  800bd6:	5e                   	pop    %esi
  800bd7:	5f                   	pop    %edi
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bda:	83 ec 0c             	sub    $0xc,%esp
  800bdd:	50                   	push   %eax
  800bde:	6a 03                	push   $0x3
  800be0:	68 04 16 80 00       	push   $0x801604
  800be5:	6a 23                	push   $0x23
  800be7:	68 21 16 80 00       	push   $0x801621
  800bec:	e8 52 04 00 00       	call   801043 <_panic>

00800bf1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bf1:	f3 0f 1e fb          	endbr32 
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bfb:	ba 00 00 00 00       	mov    $0x0,%edx
  800c00:	b8 02 00 00 00       	mov    $0x2,%eax
  800c05:	89 d1                	mov    %edx,%ecx
  800c07:	89 d3                	mov    %edx,%ebx
  800c09:	89 d7                	mov    %edx,%edi
  800c0b:	89 d6                	mov    %edx,%esi
  800c0d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <sys_yield>:

void
sys_yield(void)
{
  800c14:	f3 0f 1e fb          	endbr32 
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	57                   	push   %edi
  800c1c:	56                   	push   %esi
  800c1d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c23:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c28:	89 d1                	mov    %edx,%ecx
  800c2a:	89 d3                	mov    %edx,%ebx
  800c2c:	89 d7                	mov    %edx,%edi
  800c2e:	89 d6                	mov    %edx,%esi
  800c30:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c32:	5b                   	pop    %ebx
  800c33:	5e                   	pop    %esi
  800c34:	5f                   	pop    %edi
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    

00800c37 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c37:	f3 0f 1e fb          	endbr32 
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
  800c41:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c44:	be 00 00 00 00       	mov    $0x0,%esi
  800c49:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c54:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c57:	89 f7                	mov    %esi,%edi
  800c59:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c5b:	85 c0                	test   %eax,%eax
  800c5d:	7f 08                	jg     800c67 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5f                   	pop    %edi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c67:	83 ec 0c             	sub    $0xc,%esp
  800c6a:	50                   	push   %eax
  800c6b:	6a 04                	push   $0x4
  800c6d:	68 04 16 80 00       	push   $0x801604
  800c72:	6a 23                	push   $0x23
  800c74:	68 21 16 80 00       	push   $0x801621
  800c79:	e8 c5 03 00 00       	call   801043 <_panic>

00800c7e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c7e:	f3 0f 1e fb          	endbr32 
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c91:	b8 05 00 00 00       	mov    $0x5,%eax
  800c96:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c99:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c9c:	8b 75 18             	mov    0x18(%ebp),%esi
  800c9f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	7f 08                	jg     800cad <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ca5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5f                   	pop    %edi
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cad:	83 ec 0c             	sub    $0xc,%esp
  800cb0:	50                   	push   %eax
  800cb1:	6a 05                	push   $0x5
  800cb3:	68 04 16 80 00       	push   $0x801604
  800cb8:	6a 23                	push   $0x23
  800cba:	68 21 16 80 00       	push   $0x801621
  800cbf:	e8 7f 03 00 00       	call   801043 <_panic>

00800cc4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cc4:	f3 0f 1e fb          	endbr32 
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	57                   	push   %edi
  800ccc:	56                   	push   %esi
  800ccd:	53                   	push   %ebx
  800cce:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdc:	b8 06 00 00 00       	mov    $0x6,%eax
  800ce1:	89 df                	mov    %ebx,%edi
  800ce3:	89 de                	mov    %ebx,%esi
  800ce5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce7:	85 c0                	test   %eax,%eax
  800ce9:	7f 08                	jg     800cf3 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ceb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cee:	5b                   	pop    %ebx
  800cef:	5e                   	pop    %esi
  800cf0:	5f                   	pop    %edi
  800cf1:	5d                   	pop    %ebp
  800cf2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf3:	83 ec 0c             	sub    $0xc,%esp
  800cf6:	50                   	push   %eax
  800cf7:	6a 06                	push   $0x6
  800cf9:	68 04 16 80 00       	push   $0x801604
  800cfe:	6a 23                	push   $0x23
  800d00:	68 21 16 80 00       	push   $0x801621
  800d05:	e8 39 03 00 00       	call   801043 <_panic>

00800d0a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d0a:	f3 0f 1e fb          	endbr32 
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
  800d14:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d17:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d22:	b8 08 00 00 00       	mov    $0x8,%eax
  800d27:	89 df                	mov    %ebx,%edi
  800d29:	89 de                	mov    %ebx,%esi
  800d2b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d2d:	85 c0                	test   %eax,%eax
  800d2f:	7f 08                	jg     800d39 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d34:	5b                   	pop    %ebx
  800d35:	5e                   	pop    %esi
  800d36:	5f                   	pop    %edi
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d39:	83 ec 0c             	sub    $0xc,%esp
  800d3c:	50                   	push   %eax
  800d3d:	6a 08                	push   $0x8
  800d3f:	68 04 16 80 00       	push   $0x801604
  800d44:	6a 23                	push   $0x23
  800d46:	68 21 16 80 00       	push   $0x801621
  800d4b:	e8 f3 02 00 00       	call   801043 <_panic>

00800d50 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d50:	f3 0f 1e fb          	endbr32 
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	57                   	push   %edi
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
  800d5a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d5d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d62:	8b 55 08             	mov    0x8(%ebp),%edx
  800d65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d68:	b8 09 00 00 00       	mov    $0x9,%eax
  800d6d:	89 df                	mov    %ebx,%edi
  800d6f:	89 de                	mov    %ebx,%esi
  800d71:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d73:	85 c0                	test   %eax,%eax
  800d75:	7f 08                	jg     800d7f <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7a:	5b                   	pop    %ebx
  800d7b:	5e                   	pop    %esi
  800d7c:	5f                   	pop    %edi
  800d7d:	5d                   	pop    %ebp
  800d7e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7f:	83 ec 0c             	sub    $0xc,%esp
  800d82:	50                   	push   %eax
  800d83:	6a 09                	push   $0x9
  800d85:	68 04 16 80 00       	push   $0x801604
  800d8a:	6a 23                	push   $0x23
  800d8c:	68 21 16 80 00       	push   $0x801621
  800d91:	e8 ad 02 00 00       	call   801043 <_panic>

00800d96 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d96:	f3 0f 1e fb          	endbr32 
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
  800d9d:	57                   	push   %edi
  800d9e:	56                   	push   %esi
  800d9f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800da0:	8b 55 08             	mov    0x8(%ebp),%edx
  800da3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dab:	be 00 00 00 00       	mov    $0x0,%esi
  800db0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800db6:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800db8:	5b                   	pop    %ebx
  800db9:	5e                   	pop    %esi
  800dba:	5f                   	pop    %edi
  800dbb:	5d                   	pop    %ebp
  800dbc:	c3                   	ret    

00800dbd <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dbd:	f3 0f 1e fb          	endbr32 
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
  800dc4:	57                   	push   %edi
  800dc5:	56                   	push   %esi
  800dc6:	53                   	push   %ebx
  800dc7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dca:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dcf:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dd7:	89 cb                	mov    %ecx,%ebx
  800dd9:	89 cf                	mov    %ecx,%edi
  800ddb:	89 ce                	mov    %ecx,%esi
  800ddd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ddf:	85 c0                	test   %eax,%eax
  800de1:	7f 08                	jg     800deb <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800de3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de6:	5b                   	pop    %ebx
  800de7:	5e                   	pop    %esi
  800de8:	5f                   	pop    %edi
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800deb:	83 ec 0c             	sub    $0xc,%esp
  800dee:	50                   	push   %eax
  800def:	6a 0c                	push   $0xc
  800df1:	68 04 16 80 00       	push   $0x801604
  800df6:	6a 23                	push   $0x23
  800df8:	68 21 16 80 00       	push   $0x801621
  800dfd:	e8 41 02 00 00       	call   801043 <_panic>

00800e02 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e02:	f3 0f 1e fb          	endbr32 
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	53                   	push   %ebx
  800e0a:	83 ec 04             	sub    $0x4,%esp
  800e0d:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e10:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if ( !(err & FEC_WR) ||
  800e12:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e16:	74 75                	je     800e8d <pgfault+0x8b>
            !(uvpt[PGNUM(addr)] | PTE_COW) ) {
  800e18:	89 d8                	mov    %ebx,%eax
  800e1a:	c1 e8 0c             	shr    $0xc,%eax
  800e1d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, (void *)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0) {
  800e24:	83 ec 04             	sub    $0x4,%esp
  800e27:	6a 07                	push   $0x7
  800e29:	68 00 f0 7f 00       	push   $0x7ff000
  800e2e:	6a 00                	push   $0x0
  800e30:	e8 02 fe ff ff       	call   800c37 <sys_page_alloc>
  800e35:	83 c4 10             	add    $0x10,%esp
  800e38:	85 c0                	test   %eax,%eax
  800e3a:	78 65                	js     800ea1 <pgfault+0x9f>
        panic("sys_page_alloc failed %e\n", r);
    }
    memmove((void *)PFTEMP, (void *)PTE_ADDR(addr), PGSIZE);
  800e3c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800e42:	83 ec 04             	sub    $0x4,%esp
  800e45:	68 00 10 00 00       	push   $0x1000
  800e4a:	53                   	push   %ebx
  800e4b:	68 00 f0 7f 00       	push   $0x7ff000
  800e50:	e8 56 fb ff ff       	call   8009ab <memmove>
    if ((r = sys_page_map(0, (void *)PFTEMP,
  800e55:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e5c:	53                   	push   %ebx
  800e5d:	6a 00                	push   $0x0
  800e5f:	68 00 f0 7f 00       	push   $0x7ff000
  800e64:	6a 00                	push   $0x0
  800e66:	e8 13 fe ff ff       	call   800c7e <sys_page_map>
  800e6b:	83 c4 20             	add    $0x20,%esp
  800e6e:	85 c0                	test   %eax,%eax
  800e70:	78 41                	js     800eb3 <pgfault+0xb1>
                0, (void *)PTE_ADDR(addr), PTE_P | PTE_U | PTE_W)) < 0) {
        panic("sys_page_map failed %e\n", r);
    }
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0) {
  800e72:	83 ec 08             	sub    $0x8,%esp
  800e75:	68 00 f0 7f 00       	push   $0x7ff000
  800e7a:	6a 00                	push   $0x0
  800e7c:	e8 43 fe ff ff       	call   800cc4 <sys_page_unmap>
  800e81:	83 c4 10             	add    $0x10,%esp
  800e84:	85 c0                	test   %eax,%eax
  800e86:	78 3d                	js     800ec5 <pgfault+0xc3>
        panic("sys_page_unmap failed %e\n", r);
    }

}
  800e88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e8b:	c9                   	leave  
  800e8c:	c3                   	ret    
        panic("Not a copy-on-write page");
  800e8d:	83 ec 04             	sub    $0x4,%esp
  800e90:	68 2f 16 80 00       	push   $0x80162f
  800e95:	6a 1e                	push   $0x1e
  800e97:	68 48 16 80 00       	push   $0x801648
  800e9c:	e8 a2 01 00 00       	call   801043 <_panic>
        panic("sys_page_alloc failed %e\n", r);
  800ea1:	50                   	push   %eax
  800ea2:	68 53 16 80 00       	push   $0x801653
  800ea7:	6a 2a                	push   $0x2a
  800ea9:	68 48 16 80 00       	push   $0x801648
  800eae:	e8 90 01 00 00       	call   801043 <_panic>
        panic("sys_page_map failed %e\n", r);
  800eb3:	50                   	push   %eax
  800eb4:	68 6d 16 80 00       	push   $0x80166d
  800eb9:	6a 2f                	push   $0x2f
  800ebb:	68 48 16 80 00       	push   $0x801648
  800ec0:	e8 7e 01 00 00       	call   801043 <_panic>
        panic("sys_page_unmap failed %e\n", r);
  800ec5:	50                   	push   %eax
  800ec6:	68 85 16 80 00       	push   $0x801685
  800ecb:	6a 32                	push   $0x32
  800ecd:	68 48 16 80 00       	push   $0x801648
  800ed2:	e8 6c 01 00 00       	call   801043 <_panic>

00800ed7 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ed7:	f3 0f 1e fb          	endbr32 
  800edb:	55                   	push   %ebp
  800edc:	89 e5                	mov    %esp,%ebp
  800ede:	57                   	push   %edi
  800edf:	56                   	push   %esi
  800ee0:	53                   	push   %ebx
  800ee1:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");

    // 1. set pgfault handler.
    set_pgfault_handler(pgfault);
  800ee4:	68 02 0e 80 00       	push   $0x800e02
  800ee9:	e8 9f 01 00 00       	call   80108d <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800eee:	b8 07 00 00 00       	mov    $0x7,%eax
  800ef3:	cd 30                	int    $0x30
  800ef5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ef8:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    // 2. exofork.
    envid_t envid = sys_exofork();

    if (envid < 0)
  800efb:	83 c4 10             	add    $0x10,%esp
  800efe:	85 c0                	test   %eax,%eax
  800f00:	78 2a                	js     800f2c <fork+0x55>
        thisenv = &envs[ENVX(my_envid)];
        return 0;
    }
    else {
        // parent
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800f02:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (envid == 0) {
  800f07:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800f0b:	75 4e                	jne    800f5b <fork+0x84>
        envid_t my_envid = sys_getenvid();
  800f0d:	e8 df fc ff ff       	call   800bf1 <sys_getenvid>
        thisenv = &envs[ENVX(my_envid)];
  800f12:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f17:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f1a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f1f:	a3 04 20 80 00       	mov    %eax,0x802004
        return 0;
  800f24:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f27:	e9 f1 00 00 00       	jmp    80101d <fork+0x146>
        panic("fork, sys_exofork %e", envid);
  800f2c:	50                   	push   %eax
  800f2d:	68 9f 16 80 00       	push   $0x80169f
  800f32:	6a 7b                	push   $0x7b
  800f34:	68 48 16 80 00       	push   $0x801648
  800f39:	e8 05 01 00 00       	call   801043 <_panic>
        panic("sys_page_map others failed %e\n", r);
  800f3e:	50                   	push   %eax
  800f3f:	68 e8 16 80 00       	push   $0x8016e8
  800f44:	6a 51                	push   $0x51
  800f46:	68 48 16 80 00       	push   $0x801648
  800f4b:	e8 f3 00 00 00       	call   801043 <_panic>
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800f50:	83 c3 01             	add    $0x1,%ebx
  800f53:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  800f59:	74 7c                	je     800fd7 <fork+0x100>
  800f5b:	89 de                	mov    %ebx,%esi
  800f5d:	c1 e6 0c             	shl    $0xc,%esi
            uintptr_t pgaddr = pn << PGSHIFT;
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800f60:	89 f0                	mov    %esi,%eax
  800f62:	c1 e8 16             	shr    $0x16,%eax
  800f65:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f6c:	a8 01                	test   $0x1,%al
  800f6e:	74 e0                	je     800f50 <fork+0x79>
                    (uvpt[pn] & PTE_P) ) {
  800f70:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800f77:	a8 01                	test   $0x1,%al
  800f79:	74 d5                	je     800f50 <fork+0x79>
    pte_t pte = uvpt[pn];
  800f7b:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
    if ( (pte & PTE_W) || (pte & PTE_COW) ) {
  800f82:	25 02 08 00 00       	and    $0x802,%eax
        perm |= PTE_COW;
  800f87:	83 f8 01             	cmp    $0x1,%eax
  800f8a:	19 ff                	sbb    %edi,%edi
  800f8c:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  800f92:	81 c7 05 08 00 00    	add    $0x805,%edi
    if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0) {
  800f98:	83 ec 0c             	sub    $0xc,%esp
  800f9b:	57                   	push   %edi
  800f9c:	56                   	push   %esi
  800f9d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fa0:	56                   	push   %esi
  800fa1:	6a 00                	push   $0x0
  800fa3:	e8 d6 fc ff ff       	call   800c7e <sys_page_map>
  800fa8:	83 c4 20             	add    $0x20,%esp
  800fab:	85 c0                	test   %eax,%eax
  800fad:	78 8f                	js     800f3e <fork+0x67>
        if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0) {
  800faf:	83 ec 0c             	sub    $0xc,%esp
  800fb2:	57                   	push   %edi
  800fb3:	56                   	push   %esi
  800fb4:	6a 00                	push   $0x0
  800fb6:	56                   	push   %esi
  800fb7:	6a 00                	push   $0x0
  800fb9:	e8 c0 fc ff ff       	call   800c7e <sys_page_map>
  800fbe:	83 c4 20             	add    $0x20,%esp
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	79 8b                	jns    800f50 <fork+0x79>
            panic("sys_page_map mine failed %e\n", r);
  800fc5:	50                   	push   %eax
  800fc6:	68 b4 16 80 00       	push   $0x8016b4
  800fcb:	6a 56                	push   $0x56
  800fcd:	68 48 16 80 00       	push   $0x801648
  800fd2:	e8 6c 00 00 00       	call   801043 <_panic>
            }
        }

        int r;

        if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE),
  800fd7:	83 ec 04             	sub    $0x4,%esp
  800fda:	6a 07                	push   $0x7
  800fdc:	68 00 f0 bf ee       	push   $0xeebff000
  800fe1:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800fe4:	57                   	push   %edi
  800fe5:	e8 4d fc ff ff       	call   800c37 <sys_page_alloc>
  800fea:	83 c4 10             	add    $0x10,%esp
  800fed:	85 c0                	test   %eax,%eax
  800fef:	78 2c                	js     80101d <fork+0x146>
                    PTE_U | PTE_W | PTE_P)) < 0) {
            return r;
        }

        if ((r = sys_env_set_pgfault_upcall(envid,
                        thisenv->env_pgfault_upcall)) < 0) {
  800ff1:	a1 04 20 80 00       	mov    0x802004,%eax
        if ((r = sys_env_set_pgfault_upcall(envid,
  800ff6:	8b 40 64             	mov    0x64(%eax),%eax
  800ff9:	83 ec 08             	sub    $0x8,%esp
  800ffc:	50                   	push   %eax
  800ffd:	57                   	push   %edi
  800ffe:	e8 4d fd ff ff       	call   800d50 <sys_env_set_pgfault_upcall>
  801003:	83 c4 10             	add    $0x10,%esp
  801006:	85 c0                	test   %eax,%eax
  801008:	78 13                	js     80101d <fork+0x146>
            return r;
        }

        if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  80100a:	83 ec 08             	sub    $0x8,%esp
  80100d:	6a 02                	push   $0x2
  80100f:	57                   	push   %edi
  801010:	e8 f5 fc ff ff       	call   800d0a <sys_env_set_status>
  801015:	83 c4 10             	add    $0x10,%esp
            return r;
        }
        return envid;
  801018:	85 c0                	test   %eax,%eax
  80101a:	0f 49 c7             	cmovns %edi,%eax
    }

}
  80101d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801020:	5b                   	pop    %ebx
  801021:	5e                   	pop    %esi
  801022:	5f                   	pop    %edi
  801023:	5d                   	pop    %ebp
  801024:	c3                   	ret    

00801025 <sfork>:

// Challenge!
int
sfork(void)
{
  801025:	f3 0f 1e fb          	endbr32 
  801029:	55                   	push   %ebp
  80102a:	89 e5                	mov    %esp,%ebp
  80102c:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80102f:	68 d1 16 80 00       	push   $0x8016d1
  801034:	68 a5 00 00 00       	push   $0xa5
  801039:	68 48 16 80 00       	push   $0x801648
  80103e:	e8 00 00 00 00       	call   801043 <_panic>

00801043 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801043:	f3 0f 1e fb          	endbr32 
  801047:	55                   	push   %ebp
  801048:	89 e5                	mov    %esp,%ebp
  80104a:	56                   	push   %esi
  80104b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80104c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80104f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  801055:	e8 97 fb ff ff       	call   800bf1 <sys_getenvid>
  80105a:	83 ec 0c             	sub    $0xc,%esp
  80105d:	ff 75 0c             	pushl  0xc(%ebp)
  801060:	ff 75 08             	pushl  0x8(%ebp)
  801063:	56                   	push   %esi
  801064:	50                   	push   %eax
  801065:	68 08 17 80 00       	push   $0x801708
  80106a:	e8 7d f1 ff ff       	call   8001ec <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80106f:	83 c4 18             	add    $0x18,%esp
  801072:	53                   	push   %ebx
  801073:	ff 75 10             	pushl  0x10(%ebp)
  801076:	e8 1c f1 ff ff       	call   800197 <vcprintf>
	cprintf("\n");
  80107b:	c7 04 24 af 13 80 00 	movl   $0x8013af,(%esp)
  801082:	e8 65 f1 ff ff       	call   8001ec <cprintf>
  801087:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80108a:	cc                   	int3   
  80108b:	eb fd                	jmp    80108a <_panic+0x47>

0080108d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80108d:	f3 0f 1e fb          	endbr32 
  801091:	55                   	push   %ebp
  801092:	89 e5                	mov    %esp,%ebp
  801094:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801097:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  80109e:	74 0a                	je     8010aa <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8010a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a3:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8010a8:	c9                   	leave  
  8010a9:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  8010aa:	83 ec 0c             	sub    $0xc,%esp
  8010ad:	68 2b 17 80 00       	push   $0x80172b
  8010b2:	e8 35 f1 ff ff       	call   8001ec <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  8010b7:	83 c4 0c             	add    $0xc,%esp
  8010ba:	6a 07                	push   $0x7
  8010bc:	68 00 f0 bf ee       	push   $0xeebff000
  8010c1:	6a 00                	push   $0x0
  8010c3:	e8 6f fb ff ff       	call   800c37 <sys_page_alloc>
  8010c8:	83 c4 10             	add    $0x10,%esp
  8010cb:	85 c0                	test   %eax,%eax
  8010cd:	78 2a                	js     8010f9 <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  8010cf:	83 ec 08             	sub    $0x8,%esp
  8010d2:	68 0d 11 80 00       	push   $0x80110d
  8010d7:	6a 00                	push   $0x0
  8010d9:	e8 72 fc ff ff       	call   800d50 <sys_env_set_pgfault_upcall>
  8010de:	83 c4 10             	add    $0x10,%esp
  8010e1:	85 c0                	test   %eax,%eax
  8010e3:	79 bb                	jns    8010a0 <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  8010e5:	83 ec 04             	sub    $0x4,%esp
  8010e8:	68 68 17 80 00       	push   $0x801768
  8010ed:	6a 25                	push   $0x25
  8010ef:	68 58 17 80 00       	push   $0x801758
  8010f4:	e8 4a ff ff ff       	call   801043 <_panic>
            panic("Allocation of UXSTACK failed!");
  8010f9:	83 ec 04             	sub    $0x4,%esp
  8010fc:	68 3a 17 80 00       	push   $0x80173a
  801101:	6a 22                	push   $0x22
  801103:	68 58 17 80 00       	push   $0x801758
  801108:	e8 36 ff ff ff       	call   801043 <_panic>

0080110d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80110d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80110e:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801113:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801115:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  801118:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  80111c:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  801120:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  801123:	83 c4 08             	add    $0x8,%esp
    popa
  801126:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $0x4, %esp
  801127:	83 c4 04             	add    $0x4,%esp
    popf
  80112a:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  80112b:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  80112e:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  801132:	c3                   	ret    
  801133:	66 90                	xchg   %ax,%ax
  801135:	66 90                	xchg   %ax,%ax
  801137:	66 90                	xchg   %ax,%ax
  801139:	66 90                	xchg   %ax,%ax
  80113b:	66 90                	xchg   %ax,%ax
  80113d:	66 90                	xchg   %ax,%ax
  80113f:	90                   	nop

00801140 <__udivdi3>:
  801140:	f3 0f 1e fb          	endbr32 
  801144:	55                   	push   %ebp
  801145:	57                   	push   %edi
  801146:	56                   	push   %esi
  801147:	53                   	push   %ebx
  801148:	83 ec 1c             	sub    $0x1c,%esp
  80114b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80114f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801153:	8b 74 24 34          	mov    0x34(%esp),%esi
  801157:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80115b:	85 d2                	test   %edx,%edx
  80115d:	75 19                	jne    801178 <__udivdi3+0x38>
  80115f:	39 f3                	cmp    %esi,%ebx
  801161:	76 4d                	jbe    8011b0 <__udivdi3+0x70>
  801163:	31 ff                	xor    %edi,%edi
  801165:	89 e8                	mov    %ebp,%eax
  801167:	89 f2                	mov    %esi,%edx
  801169:	f7 f3                	div    %ebx
  80116b:	89 fa                	mov    %edi,%edx
  80116d:	83 c4 1c             	add    $0x1c,%esp
  801170:	5b                   	pop    %ebx
  801171:	5e                   	pop    %esi
  801172:	5f                   	pop    %edi
  801173:	5d                   	pop    %ebp
  801174:	c3                   	ret    
  801175:	8d 76 00             	lea    0x0(%esi),%esi
  801178:	39 f2                	cmp    %esi,%edx
  80117a:	76 14                	jbe    801190 <__udivdi3+0x50>
  80117c:	31 ff                	xor    %edi,%edi
  80117e:	31 c0                	xor    %eax,%eax
  801180:	89 fa                	mov    %edi,%edx
  801182:	83 c4 1c             	add    $0x1c,%esp
  801185:	5b                   	pop    %ebx
  801186:	5e                   	pop    %esi
  801187:	5f                   	pop    %edi
  801188:	5d                   	pop    %ebp
  801189:	c3                   	ret    
  80118a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801190:	0f bd fa             	bsr    %edx,%edi
  801193:	83 f7 1f             	xor    $0x1f,%edi
  801196:	75 48                	jne    8011e0 <__udivdi3+0xa0>
  801198:	39 f2                	cmp    %esi,%edx
  80119a:	72 06                	jb     8011a2 <__udivdi3+0x62>
  80119c:	31 c0                	xor    %eax,%eax
  80119e:	39 eb                	cmp    %ebp,%ebx
  8011a0:	77 de                	ja     801180 <__udivdi3+0x40>
  8011a2:	b8 01 00 00 00       	mov    $0x1,%eax
  8011a7:	eb d7                	jmp    801180 <__udivdi3+0x40>
  8011a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011b0:	89 d9                	mov    %ebx,%ecx
  8011b2:	85 db                	test   %ebx,%ebx
  8011b4:	75 0b                	jne    8011c1 <__udivdi3+0x81>
  8011b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8011bb:	31 d2                	xor    %edx,%edx
  8011bd:	f7 f3                	div    %ebx
  8011bf:	89 c1                	mov    %eax,%ecx
  8011c1:	31 d2                	xor    %edx,%edx
  8011c3:	89 f0                	mov    %esi,%eax
  8011c5:	f7 f1                	div    %ecx
  8011c7:	89 c6                	mov    %eax,%esi
  8011c9:	89 e8                	mov    %ebp,%eax
  8011cb:	89 f7                	mov    %esi,%edi
  8011cd:	f7 f1                	div    %ecx
  8011cf:	89 fa                	mov    %edi,%edx
  8011d1:	83 c4 1c             	add    $0x1c,%esp
  8011d4:	5b                   	pop    %ebx
  8011d5:	5e                   	pop    %esi
  8011d6:	5f                   	pop    %edi
  8011d7:	5d                   	pop    %ebp
  8011d8:	c3                   	ret    
  8011d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011e0:	89 f9                	mov    %edi,%ecx
  8011e2:	b8 20 00 00 00       	mov    $0x20,%eax
  8011e7:	29 f8                	sub    %edi,%eax
  8011e9:	d3 e2                	shl    %cl,%edx
  8011eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8011ef:	89 c1                	mov    %eax,%ecx
  8011f1:	89 da                	mov    %ebx,%edx
  8011f3:	d3 ea                	shr    %cl,%edx
  8011f5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8011f9:	09 d1                	or     %edx,%ecx
  8011fb:	89 f2                	mov    %esi,%edx
  8011fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801201:	89 f9                	mov    %edi,%ecx
  801203:	d3 e3                	shl    %cl,%ebx
  801205:	89 c1                	mov    %eax,%ecx
  801207:	d3 ea                	shr    %cl,%edx
  801209:	89 f9                	mov    %edi,%ecx
  80120b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80120f:	89 eb                	mov    %ebp,%ebx
  801211:	d3 e6                	shl    %cl,%esi
  801213:	89 c1                	mov    %eax,%ecx
  801215:	d3 eb                	shr    %cl,%ebx
  801217:	09 de                	or     %ebx,%esi
  801219:	89 f0                	mov    %esi,%eax
  80121b:	f7 74 24 08          	divl   0x8(%esp)
  80121f:	89 d6                	mov    %edx,%esi
  801221:	89 c3                	mov    %eax,%ebx
  801223:	f7 64 24 0c          	mull   0xc(%esp)
  801227:	39 d6                	cmp    %edx,%esi
  801229:	72 15                	jb     801240 <__udivdi3+0x100>
  80122b:	89 f9                	mov    %edi,%ecx
  80122d:	d3 e5                	shl    %cl,%ebp
  80122f:	39 c5                	cmp    %eax,%ebp
  801231:	73 04                	jae    801237 <__udivdi3+0xf7>
  801233:	39 d6                	cmp    %edx,%esi
  801235:	74 09                	je     801240 <__udivdi3+0x100>
  801237:	89 d8                	mov    %ebx,%eax
  801239:	31 ff                	xor    %edi,%edi
  80123b:	e9 40 ff ff ff       	jmp    801180 <__udivdi3+0x40>
  801240:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801243:	31 ff                	xor    %edi,%edi
  801245:	e9 36 ff ff ff       	jmp    801180 <__udivdi3+0x40>
  80124a:	66 90                	xchg   %ax,%ax
  80124c:	66 90                	xchg   %ax,%ax
  80124e:	66 90                	xchg   %ax,%ax

00801250 <__umoddi3>:
  801250:	f3 0f 1e fb          	endbr32 
  801254:	55                   	push   %ebp
  801255:	57                   	push   %edi
  801256:	56                   	push   %esi
  801257:	53                   	push   %ebx
  801258:	83 ec 1c             	sub    $0x1c,%esp
  80125b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80125f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801263:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801267:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80126b:	85 c0                	test   %eax,%eax
  80126d:	75 19                	jne    801288 <__umoddi3+0x38>
  80126f:	39 df                	cmp    %ebx,%edi
  801271:	76 5d                	jbe    8012d0 <__umoddi3+0x80>
  801273:	89 f0                	mov    %esi,%eax
  801275:	89 da                	mov    %ebx,%edx
  801277:	f7 f7                	div    %edi
  801279:	89 d0                	mov    %edx,%eax
  80127b:	31 d2                	xor    %edx,%edx
  80127d:	83 c4 1c             	add    $0x1c,%esp
  801280:	5b                   	pop    %ebx
  801281:	5e                   	pop    %esi
  801282:	5f                   	pop    %edi
  801283:	5d                   	pop    %ebp
  801284:	c3                   	ret    
  801285:	8d 76 00             	lea    0x0(%esi),%esi
  801288:	89 f2                	mov    %esi,%edx
  80128a:	39 d8                	cmp    %ebx,%eax
  80128c:	76 12                	jbe    8012a0 <__umoddi3+0x50>
  80128e:	89 f0                	mov    %esi,%eax
  801290:	89 da                	mov    %ebx,%edx
  801292:	83 c4 1c             	add    $0x1c,%esp
  801295:	5b                   	pop    %ebx
  801296:	5e                   	pop    %esi
  801297:	5f                   	pop    %edi
  801298:	5d                   	pop    %ebp
  801299:	c3                   	ret    
  80129a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012a0:	0f bd e8             	bsr    %eax,%ebp
  8012a3:	83 f5 1f             	xor    $0x1f,%ebp
  8012a6:	75 50                	jne    8012f8 <__umoddi3+0xa8>
  8012a8:	39 d8                	cmp    %ebx,%eax
  8012aa:	0f 82 e0 00 00 00    	jb     801390 <__umoddi3+0x140>
  8012b0:	89 d9                	mov    %ebx,%ecx
  8012b2:	39 f7                	cmp    %esi,%edi
  8012b4:	0f 86 d6 00 00 00    	jbe    801390 <__umoddi3+0x140>
  8012ba:	89 d0                	mov    %edx,%eax
  8012bc:	89 ca                	mov    %ecx,%edx
  8012be:	83 c4 1c             	add    $0x1c,%esp
  8012c1:	5b                   	pop    %ebx
  8012c2:	5e                   	pop    %esi
  8012c3:	5f                   	pop    %edi
  8012c4:	5d                   	pop    %ebp
  8012c5:	c3                   	ret    
  8012c6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012cd:	8d 76 00             	lea    0x0(%esi),%esi
  8012d0:	89 fd                	mov    %edi,%ebp
  8012d2:	85 ff                	test   %edi,%edi
  8012d4:	75 0b                	jne    8012e1 <__umoddi3+0x91>
  8012d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8012db:	31 d2                	xor    %edx,%edx
  8012dd:	f7 f7                	div    %edi
  8012df:	89 c5                	mov    %eax,%ebp
  8012e1:	89 d8                	mov    %ebx,%eax
  8012e3:	31 d2                	xor    %edx,%edx
  8012e5:	f7 f5                	div    %ebp
  8012e7:	89 f0                	mov    %esi,%eax
  8012e9:	f7 f5                	div    %ebp
  8012eb:	89 d0                	mov    %edx,%eax
  8012ed:	31 d2                	xor    %edx,%edx
  8012ef:	eb 8c                	jmp    80127d <__umoddi3+0x2d>
  8012f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012f8:	89 e9                	mov    %ebp,%ecx
  8012fa:	ba 20 00 00 00       	mov    $0x20,%edx
  8012ff:	29 ea                	sub    %ebp,%edx
  801301:	d3 e0                	shl    %cl,%eax
  801303:	89 44 24 08          	mov    %eax,0x8(%esp)
  801307:	89 d1                	mov    %edx,%ecx
  801309:	89 f8                	mov    %edi,%eax
  80130b:	d3 e8                	shr    %cl,%eax
  80130d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801311:	89 54 24 04          	mov    %edx,0x4(%esp)
  801315:	8b 54 24 04          	mov    0x4(%esp),%edx
  801319:	09 c1                	or     %eax,%ecx
  80131b:	89 d8                	mov    %ebx,%eax
  80131d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801321:	89 e9                	mov    %ebp,%ecx
  801323:	d3 e7                	shl    %cl,%edi
  801325:	89 d1                	mov    %edx,%ecx
  801327:	d3 e8                	shr    %cl,%eax
  801329:	89 e9                	mov    %ebp,%ecx
  80132b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80132f:	d3 e3                	shl    %cl,%ebx
  801331:	89 c7                	mov    %eax,%edi
  801333:	89 d1                	mov    %edx,%ecx
  801335:	89 f0                	mov    %esi,%eax
  801337:	d3 e8                	shr    %cl,%eax
  801339:	89 e9                	mov    %ebp,%ecx
  80133b:	89 fa                	mov    %edi,%edx
  80133d:	d3 e6                	shl    %cl,%esi
  80133f:	09 d8                	or     %ebx,%eax
  801341:	f7 74 24 08          	divl   0x8(%esp)
  801345:	89 d1                	mov    %edx,%ecx
  801347:	89 f3                	mov    %esi,%ebx
  801349:	f7 64 24 0c          	mull   0xc(%esp)
  80134d:	89 c6                	mov    %eax,%esi
  80134f:	89 d7                	mov    %edx,%edi
  801351:	39 d1                	cmp    %edx,%ecx
  801353:	72 06                	jb     80135b <__umoddi3+0x10b>
  801355:	75 10                	jne    801367 <__umoddi3+0x117>
  801357:	39 c3                	cmp    %eax,%ebx
  801359:	73 0c                	jae    801367 <__umoddi3+0x117>
  80135b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80135f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801363:	89 d7                	mov    %edx,%edi
  801365:	89 c6                	mov    %eax,%esi
  801367:	89 ca                	mov    %ecx,%edx
  801369:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80136e:	29 f3                	sub    %esi,%ebx
  801370:	19 fa                	sbb    %edi,%edx
  801372:	89 d0                	mov    %edx,%eax
  801374:	d3 e0                	shl    %cl,%eax
  801376:	89 e9                	mov    %ebp,%ecx
  801378:	d3 eb                	shr    %cl,%ebx
  80137a:	d3 ea                	shr    %cl,%edx
  80137c:	09 d8                	or     %ebx,%eax
  80137e:	83 c4 1c             	add    $0x1c,%esp
  801381:	5b                   	pop    %ebx
  801382:	5e                   	pop    %esi
  801383:	5f                   	pop    %edi
  801384:	5d                   	pop    %ebp
  801385:	c3                   	ret    
  801386:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80138d:	8d 76 00             	lea    0x0(%esi),%esi
  801390:	29 fe                	sub    %edi,%esi
  801392:	19 c3                	sbb    %eax,%ebx
  801394:	89 f2                	mov    %esi,%edx
  801396:	89 d9                	mov    %ebx,%ecx
  801398:	e9 1d ff ff ff       	jmp    8012ba <__umoddi3+0x6a>
