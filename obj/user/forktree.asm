
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
  800041:	e8 bd 0b 00 00       	call   800c03 <sys_getenvid>
  800046:	83 ec 04             	sub    $0x4,%esp
  800049:	53                   	push   %ebx
  80004a:	50                   	push   %eax
  80004b:	68 80 22 80 00       	push   $0x802280
  800050:	e8 a9 01 00 00       	call   8001fe <cprintf>

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
  800086:	e8 39 07 00 00       	call   8007c4 <strlen>
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
  8000a4:	68 91 22 80 00       	push   $0x802291
  8000a9:	6a 04                	push   $0x4
  8000ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000ae:	50                   	push   %eax
  8000af:	e8 f2 06 00 00       	call   8007a6 <snprintf>
	if (fork() == 0) {
  8000b4:	83 c4 20             	add    $0x20,%esp
  8000b7:	e8 73 0e 00 00       	call   800f2f <fork>
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	75 d3                	jne    800093 <forkchild+0x20>
		forktree(nxt);
  8000c0:	83 ec 0c             	sub    $0xc,%esp
  8000c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000c6:	50                   	push   %eax
  8000c7:	e8 67 ff ff ff       	call   800033 <forktree>
		exit();
  8000cc:	e8 72 00 00 00       	call   800143 <exit>
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
  8000e0:	68 90 22 80 00       	push   $0x802290
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
	thisenv = 0;
  8000fe:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800105:	00 00 00 
    envid_t envid = sys_getenvid();
  800108:	e8 f6 0a 00 00       	call   800c03 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  80010d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800112:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800115:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011a:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011f:	85 db                	test   %ebx,%ebx
  800121:	7e 07                	jle    80012a <libmain+0x3b>
		binaryname = argv[0];
  800123:	8b 06                	mov    (%esi),%eax
  800125:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80012a:	83 ec 08             	sub    $0x8,%esp
  80012d:	56                   	push   %esi
  80012e:	53                   	push   %ebx
  80012f:	e8 a2 ff ff ff       	call   8000d6 <umain>

	// exit gracefully
	exit();
  800134:	e8 0a 00 00 00       	call   800143 <exit>
}
  800139:	83 c4 10             	add    $0x10,%esp
  80013c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013f:	5b                   	pop    %ebx
  800140:	5e                   	pop    %esi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800143:	f3 0f 1e fb          	endbr32 
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80014d:	e8 43 11 00 00       	call   801295 <close_all>
	sys_env_destroy(0);
  800152:	83 ec 0c             	sub    $0xc,%esp
  800155:	6a 00                	push   $0x0
  800157:	e8 62 0a 00 00       	call   800bbe <sys_env_destroy>
}
  80015c:	83 c4 10             	add    $0x10,%esp
  80015f:	c9                   	leave  
  800160:	c3                   	ret    

00800161 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800161:	f3 0f 1e fb          	endbr32 
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	53                   	push   %ebx
  800169:	83 ec 04             	sub    $0x4,%esp
  80016c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016f:	8b 13                	mov    (%ebx),%edx
  800171:	8d 42 01             	lea    0x1(%edx),%eax
  800174:	89 03                	mov    %eax,(%ebx)
  800176:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800179:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80017d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800182:	74 09                	je     80018d <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800184:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800188:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80018b:	c9                   	leave  
  80018c:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80018d:	83 ec 08             	sub    $0x8,%esp
  800190:	68 ff 00 00 00       	push   $0xff
  800195:	8d 43 08             	lea    0x8(%ebx),%eax
  800198:	50                   	push   %eax
  800199:	e8 db 09 00 00       	call   800b79 <sys_cputs>
		b->idx = 0;
  80019e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a4:	83 c4 10             	add    $0x10,%esp
  8001a7:	eb db                	jmp    800184 <putch+0x23>

008001a9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a9:	f3 0f 1e fb          	endbr32 
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001bd:	00 00 00 
	b.cnt = 0;
  8001c0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ca:	ff 75 0c             	pushl  0xc(%ebp)
  8001cd:	ff 75 08             	pushl  0x8(%ebp)
  8001d0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d6:	50                   	push   %eax
  8001d7:	68 61 01 80 00       	push   $0x800161
  8001dc:	e8 20 01 00 00       	call   800301 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e1:	83 c4 08             	add    $0x8,%esp
  8001e4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ea:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f0:	50                   	push   %eax
  8001f1:	e8 83 09 00 00       	call   800b79 <sys_cputs>

	return b.cnt;
}
  8001f6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001fc:	c9                   	leave  
  8001fd:	c3                   	ret    

008001fe <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001fe:	f3 0f 1e fb          	endbr32 
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
  800205:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800208:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80020b:	50                   	push   %eax
  80020c:	ff 75 08             	pushl  0x8(%ebp)
  80020f:	e8 95 ff ff ff       	call   8001a9 <vcprintf>
	va_end(ap);

	return cnt;
}
  800214:	c9                   	leave  
  800215:	c3                   	ret    

00800216 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800216:	55                   	push   %ebp
  800217:	89 e5                	mov    %esp,%ebp
  800219:	57                   	push   %edi
  80021a:	56                   	push   %esi
  80021b:	53                   	push   %ebx
  80021c:	83 ec 1c             	sub    $0x1c,%esp
  80021f:	89 c7                	mov    %eax,%edi
  800221:	89 d6                	mov    %edx,%esi
  800223:	8b 45 08             	mov    0x8(%ebp),%eax
  800226:	8b 55 0c             	mov    0xc(%ebp),%edx
  800229:	89 d1                	mov    %edx,%ecx
  80022b:	89 c2                	mov    %eax,%edx
  80022d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800230:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800233:	8b 45 10             	mov    0x10(%ebp),%eax
  800236:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800239:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80023c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800243:	39 c2                	cmp    %eax,%edx
  800245:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800248:	72 3e                	jb     800288 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80024a:	83 ec 0c             	sub    $0xc,%esp
  80024d:	ff 75 18             	pushl  0x18(%ebp)
  800250:	83 eb 01             	sub    $0x1,%ebx
  800253:	53                   	push   %ebx
  800254:	50                   	push   %eax
  800255:	83 ec 08             	sub    $0x8,%esp
  800258:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025b:	ff 75 e0             	pushl  -0x20(%ebp)
  80025e:	ff 75 dc             	pushl  -0x24(%ebp)
  800261:	ff 75 d8             	pushl  -0x28(%ebp)
  800264:	e8 b7 1d 00 00       	call   802020 <__udivdi3>
  800269:	83 c4 18             	add    $0x18,%esp
  80026c:	52                   	push   %edx
  80026d:	50                   	push   %eax
  80026e:	89 f2                	mov    %esi,%edx
  800270:	89 f8                	mov    %edi,%eax
  800272:	e8 9f ff ff ff       	call   800216 <printnum>
  800277:	83 c4 20             	add    $0x20,%esp
  80027a:	eb 13                	jmp    80028f <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027c:	83 ec 08             	sub    $0x8,%esp
  80027f:	56                   	push   %esi
  800280:	ff 75 18             	pushl  0x18(%ebp)
  800283:	ff d7                	call   *%edi
  800285:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800288:	83 eb 01             	sub    $0x1,%ebx
  80028b:	85 db                	test   %ebx,%ebx
  80028d:	7f ed                	jg     80027c <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80028f:	83 ec 08             	sub    $0x8,%esp
  800292:	56                   	push   %esi
  800293:	83 ec 04             	sub    $0x4,%esp
  800296:	ff 75 e4             	pushl  -0x1c(%ebp)
  800299:	ff 75 e0             	pushl  -0x20(%ebp)
  80029c:	ff 75 dc             	pushl  -0x24(%ebp)
  80029f:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a2:	e8 89 1e 00 00       	call   802130 <__umoddi3>
  8002a7:	83 c4 14             	add    $0x14,%esp
  8002aa:	0f be 80 a0 22 80 00 	movsbl 0x8022a0(%eax),%eax
  8002b1:	50                   	push   %eax
  8002b2:	ff d7                	call   *%edi
}
  8002b4:	83 c4 10             	add    $0x10,%esp
  8002b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ba:	5b                   	pop    %ebx
  8002bb:	5e                   	pop    %esi
  8002bc:	5f                   	pop    %edi
  8002bd:	5d                   	pop    %ebp
  8002be:	c3                   	ret    

008002bf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002bf:	f3 0f 1e fb          	endbr32 
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002cd:	8b 10                	mov    (%eax),%edx
  8002cf:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d2:	73 0a                	jae    8002de <sprintputch+0x1f>
		*b->buf++ = ch;
  8002d4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002d7:	89 08                	mov    %ecx,(%eax)
  8002d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002dc:	88 02                	mov    %al,(%edx)
}
  8002de:	5d                   	pop    %ebp
  8002df:	c3                   	ret    

008002e0 <printfmt>:
{
  8002e0:	f3 0f 1e fb          	endbr32 
  8002e4:	55                   	push   %ebp
  8002e5:	89 e5                	mov    %esp,%ebp
  8002e7:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002ea:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ed:	50                   	push   %eax
  8002ee:	ff 75 10             	pushl  0x10(%ebp)
  8002f1:	ff 75 0c             	pushl  0xc(%ebp)
  8002f4:	ff 75 08             	pushl  0x8(%ebp)
  8002f7:	e8 05 00 00 00       	call   800301 <vprintfmt>
}
  8002fc:	83 c4 10             	add    $0x10,%esp
  8002ff:	c9                   	leave  
  800300:	c3                   	ret    

00800301 <vprintfmt>:
{
  800301:	f3 0f 1e fb          	endbr32 
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 3c             	sub    $0x3c,%esp
  80030e:	8b 75 08             	mov    0x8(%ebp),%esi
  800311:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800314:	8b 7d 10             	mov    0x10(%ebp),%edi
  800317:	e9 4a 03 00 00       	jmp    800666 <vprintfmt+0x365>
		padc = ' ';
  80031c:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800320:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800327:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80032e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800335:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	8d 47 01             	lea    0x1(%edi),%eax
  80033d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800340:	0f b6 17             	movzbl (%edi),%edx
  800343:	8d 42 dd             	lea    -0x23(%edx),%eax
  800346:	3c 55                	cmp    $0x55,%al
  800348:	0f 87 de 03 00 00    	ja     80072c <vprintfmt+0x42b>
  80034e:	0f b6 c0             	movzbl %al,%eax
  800351:	3e ff 24 85 e0 23 80 	notrack jmp *0x8023e0(,%eax,4)
  800358:	00 
  800359:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80035c:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800360:	eb d8                	jmp    80033a <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800362:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800365:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800369:	eb cf                	jmp    80033a <vprintfmt+0x39>
  80036b:	0f b6 d2             	movzbl %dl,%edx
  80036e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800371:	b8 00 00 00 00       	mov    $0x0,%eax
  800376:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800379:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80037c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800380:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800383:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800386:	83 f9 09             	cmp    $0x9,%ecx
  800389:	77 55                	ja     8003e0 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80038b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80038e:	eb e9                	jmp    800379 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800390:	8b 45 14             	mov    0x14(%ebp),%eax
  800393:	8b 00                	mov    (%eax),%eax
  800395:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800398:	8b 45 14             	mov    0x14(%ebp),%eax
  80039b:	8d 40 04             	lea    0x4(%eax),%eax
  80039e:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003a4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003a8:	79 90                	jns    80033a <vprintfmt+0x39>
				width = precision, precision = -1;
  8003aa:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b0:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003b7:	eb 81                	jmp    80033a <vprintfmt+0x39>
  8003b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003bc:	85 c0                	test   %eax,%eax
  8003be:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c3:	0f 49 d0             	cmovns %eax,%edx
  8003c6:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003cc:	e9 69 ff ff ff       	jmp    80033a <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003d4:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003db:	e9 5a ff ff ff       	jmp    80033a <vprintfmt+0x39>
  8003e0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003e6:	eb bc                	jmp    8003a4 <vprintfmt+0xa3>
			lflag++;
  8003e8:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003ee:	e9 47 ff ff ff       	jmp    80033a <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f6:	8d 78 04             	lea    0x4(%eax),%edi
  8003f9:	83 ec 08             	sub    $0x8,%esp
  8003fc:	53                   	push   %ebx
  8003fd:	ff 30                	pushl  (%eax)
  8003ff:	ff d6                	call   *%esi
			break;
  800401:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800404:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800407:	e9 57 02 00 00       	jmp    800663 <vprintfmt+0x362>
			err = va_arg(ap, int);
  80040c:	8b 45 14             	mov    0x14(%ebp),%eax
  80040f:	8d 78 04             	lea    0x4(%eax),%edi
  800412:	8b 00                	mov    (%eax),%eax
  800414:	99                   	cltd   
  800415:	31 d0                	xor    %edx,%eax
  800417:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800419:	83 f8 0f             	cmp    $0xf,%eax
  80041c:	7f 23                	jg     800441 <vprintfmt+0x140>
  80041e:	8b 14 85 40 25 80 00 	mov    0x802540(,%eax,4),%edx
  800425:	85 d2                	test   %edx,%edx
  800427:	74 18                	je     800441 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800429:	52                   	push   %edx
  80042a:	68 49 27 80 00       	push   $0x802749
  80042f:	53                   	push   %ebx
  800430:	56                   	push   %esi
  800431:	e8 aa fe ff ff       	call   8002e0 <printfmt>
  800436:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800439:	89 7d 14             	mov    %edi,0x14(%ebp)
  80043c:	e9 22 02 00 00       	jmp    800663 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  800441:	50                   	push   %eax
  800442:	68 b8 22 80 00       	push   $0x8022b8
  800447:	53                   	push   %ebx
  800448:	56                   	push   %esi
  800449:	e8 92 fe ff ff       	call   8002e0 <printfmt>
  80044e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800451:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800454:	e9 0a 02 00 00       	jmp    800663 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  800459:	8b 45 14             	mov    0x14(%ebp),%eax
  80045c:	83 c0 04             	add    $0x4,%eax
  80045f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800462:	8b 45 14             	mov    0x14(%ebp),%eax
  800465:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800467:	85 d2                	test   %edx,%edx
  800469:	b8 b1 22 80 00       	mov    $0x8022b1,%eax
  80046e:	0f 45 c2             	cmovne %edx,%eax
  800471:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800474:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800478:	7e 06                	jle    800480 <vprintfmt+0x17f>
  80047a:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80047e:	75 0d                	jne    80048d <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800480:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800483:	89 c7                	mov    %eax,%edi
  800485:	03 45 e0             	add    -0x20(%ebp),%eax
  800488:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80048b:	eb 55                	jmp    8004e2 <vprintfmt+0x1e1>
  80048d:	83 ec 08             	sub    $0x8,%esp
  800490:	ff 75 d8             	pushl  -0x28(%ebp)
  800493:	ff 75 cc             	pushl  -0x34(%ebp)
  800496:	e8 45 03 00 00       	call   8007e0 <strnlen>
  80049b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80049e:	29 c2                	sub    %eax,%edx
  8004a0:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004a8:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004af:	85 ff                	test   %edi,%edi
  8004b1:	7e 11                	jle    8004c4 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	53                   	push   %ebx
  8004b7:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ba:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bc:	83 ef 01             	sub    $0x1,%edi
  8004bf:	83 c4 10             	add    $0x10,%esp
  8004c2:	eb eb                	jmp    8004af <vprintfmt+0x1ae>
  8004c4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004c7:	85 d2                	test   %edx,%edx
  8004c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ce:	0f 49 c2             	cmovns %edx,%eax
  8004d1:	29 c2                	sub    %eax,%edx
  8004d3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004d6:	eb a8                	jmp    800480 <vprintfmt+0x17f>
					putch(ch, putdat);
  8004d8:	83 ec 08             	sub    $0x8,%esp
  8004db:	53                   	push   %ebx
  8004dc:	52                   	push   %edx
  8004dd:	ff d6                	call   *%esi
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004e5:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e7:	83 c7 01             	add    $0x1,%edi
  8004ea:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004ee:	0f be d0             	movsbl %al,%edx
  8004f1:	85 d2                	test   %edx,%edx
  8004f3:	74 4b                	je     800540 <vprintfmt+0x23f>
  8004f5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004f9:	78 06                	js     800501 <vprintfmt+0x200>
  8004fb:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004ff:	78 1e                	js     80051f <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800501:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800505:	74 d1                	je     8004d8 <vprintfmt+0x1d7>
  800507:	0f be c0             	movsbl %al,%eax
  80050a:	83 e8 20             	sub    $0x20,%eax
  80050d:	83 f8 5e             	cmp    $0x5e,%eax
  800510:	76 c6                	jbe    8004d8 <vprintfmt+0x1d7>
					putch('?', putdat);
  800512:	83 ec 08             	sub    $0x8,%esp
  800515:	53                   	push   %ebx
  800516:	6a 3f                	push   $0x3f
  800518:	ff d6                	call   *%esi
  80051a:	83 c4 10             	add    $0x10,%esp
  80051d:	eb c3                	jmp    8004e2 <vprintfmt+0x1e1>
  80051f:	89 cf                	mov    %ecx,%edi
  800521:	eb 0e                	jmp    800531 <vprintfmt+0x230>
				putch(' ', putdat);
  800523:	83 ec 08             	sub    $0x8,%esp
  800526:	53                   	push   %ebx
  800527:	6a 20                	push   $0x20
  800529:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80052b:	83 ef 01             	sub    $0x1,%edi
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	85 ff                	test   %edi,%edi
  800533:	7f ee                	jg     800523 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800535:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800538:	89 45 14             	mov    %eax,0x14(%ebp)
  80053b:	e9 23 01 00 00       	jmp    800663 <vprintfmt+0x362>
  800540:	89 cf                	mov    %ecx,%edi
  800542:	eb ed                	jmp    800531 <vprintfmt+0x230>
	if (lflag >= 2)
  800544:	83 f9 01             	cmp    $0x1,%ecx
  800547:	7f 1b                	jg     800564 <vprintfmt+0x263>
	else if (lflag)
  800549:	85 c9                	test   %ecx,%ecx
  80054b:	74 63                	je     8005b0 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80054d:	8b 45 14             	mov    0x14(%ebp),%eax
  800550:	8b 00                	mov    (%eax),%eax
  800552:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800555:	99                   	cltd   
  800556:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800559:	8b 45 14             	mov    0x14(%ebp),%eax
  80055c:	8d 40 04             	lea    0x4(%eax),%eax
  80055f:	89 45 14             	mov    %eax,0x14(%ebp)
  800562:	eb 17                	jmp    80057b <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800564:	8b 45 14             	mov    0x14(%ebp),%eax
  800567:	8b 50 04             	mov    0x4(%eax),%edx
  80056a:	8b 00                	mov    (%eax),%eax
  80056c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800572:	8b 45 14             	mov    0x14(%ebp),%eax
  800575:	8d 40 08             	lea    0x8(%eax),%eax
  800578:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80057b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80057e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800581:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800586:	85 c9                	test   %ecx,%ecx
  800588:	0f 89 bb 00 00 00    	jns    800649 <vprintfmt+0x348>
				putch('-', putdat);
  80058e:	83 ec 08             	sub    $0x8,%esp
  800591:	53                   	push   %ebx
  800592:	6a 2d                	push   $0x2d
  800594:	ff d6                	call   *%esi
				num = -(long long) num;
  800596:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800599:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80059c:	f7 da                	neg    %edx
  80059e:	83 d1 00             	adc    $0x0,%ecx
  8005a1:	f7 d9                	neg    %ecx
  8005a3:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005a6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ab:	e9 99 00 00 00       	jmp    800649 <vprintfmt+0x348>
		return va_arg(*ap, int);
  8005b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b3:	8b 00                	mov    (%eax),%eax
  8005b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b8:	99                   	cltd   
  8005b9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bf:	8d 40 04             	lea    0x4(%eax),%eax
  8005c2:	89 45 14             	mov    %eax,0x14(%ebp)
  8005c5:	eb b4                	jmp    80057b <vprintfmt+0x27a>
	if (lflag >= 2)
  8005c7:	83 f9 01             	cmp    $0x1,%ecx
  8005ca:	7f 1b                	jg     8005e7 <vprintfmt+0x2e6>
	else if (lflag)
  8005cc:	85 c9                	test   %ecx,%ecx
  8005ce:	74 2c                	je     8005fc <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  8005d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d3:	8b 10                	mov    (%eax),%edx
  8005d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005da:	8d 40 04             	lea    0x4(%eax),%eax
  8005dd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e0:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005e5:	eb 62                	jmp    800649 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8005e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ea:	8b 10                	mov    (%eax),%edx
  8005ec:	8b 48 04             	mov    0x4(%eax),%ecx
  8005ef:	8d 40 08             	lea    0x8(%eax),%eax
  8005f2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f5:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005fa:	eb 4d                	jmp    800649 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8005fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ff:	8b 10                	mov    (%eax),%edx
  800601:	b9 00 00 00 00       	mov    $0x0,%ecx
  800606:	8d 40 04             	lea    0x4(%eax),%eax
  800609:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80060c:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800611:	eb 36                	jmp    800649 <vprintfmt+0x348>
	if (lflag >= 2)
  800613:	83 f9 01             	cmp    $0x1,%ecx
  800616:	7f 17                	jg     80062f <vprintfmt+0x32e>
	else if (lflag)
  800618:	85 c9                	test   %ecx,%ecx
  80061a:	74 6e                	je     80068a <vprintfmt+0x389>
		return va_arg(*ap, long);
  80061c:	8b 45 14             	mov    0x14(%ebp),%eax
  80061f:	8b 10                	mov    (%eax),%edx
  800621:	89 d0                	mov    %edx,%eax
  800623:	99                   	cltd   
  800624:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800627:	8d 49 04             	lea    0x4(%ecx),%ecx
  80062a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80062d:	eb 11                	jmp    800640 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  80062f:	8b 45 14             	mov    0x14(%ebp),%eax
  800632:	8b 50 04             	mov    0x4(%eax),%edx
  800635:	8b 00                	mov    (%eax),%eax
  800637:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80063a:	8d 49 08             	lea    0x8(%ecx),%ecx
  80063d:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800640:	89 d1                	mov    %edx,%ecx
  800642:	89 c2                	mov    %eax,%edx
            base = 8;
  800644:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800649:	83 ec 0c             	sub    $0xc,%esp
  80064c:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800650:	57                   	push   %edi
  800651:	ff 75 e0             	pushl  -0x20(%ebp)
  800654:	50                   	push   %eax
  800655:	51                   	push   %ecx
  800656:	52                   	push   %edx
  800657:	89 da                	mov    %ebx,%edx
  800659:	89 f0                	mov    %esi,%eax
  80065b:	e8 b6 fb ff ff       	call   800216 <printnum>
			break;
  800660:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800663:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800666:	83 c7 01             	add    $0x1,%edi
  800669:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80066d:	83 f8 25             	cmp    $0x25,%eax
  800670:	0f 84 a6 fc ff ff    	je     80031c <vprintfmt+0x1b>
			if (ch == '\0')
  800676:	85 c0                	test   %eax,%eax
  800678:	0f 84 ce 00 00 00    	je     80074c <vprintfmt+0x44b>
			putch(ch, putdat);
  80067e:	83 ec 08             	sub    $0x8,%esp
  800681:	53                   	push   %ebx
  800682:	50                   	push   %eax
  800683:	ff d6                	call   *%esi
  800685:	83 c4 10             	add    $0x10,%esp
  800688:	eb dc                	jmp    800666 <vprintfmt+0x365>
		return va_arg(*ap, int);
  80068a:	8b 45 14             	mov    0x14(%ebp),%eax
  80068d:	8b 10                	mov    (%eax),%edx
  80068f:	89 d0                	mov    %edx,%eax
  800691:	99                   	cltd   
  800692:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800695:	8d 49 04             	lea    0x4(%ecx),%ecx
  800698:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80069b:	eb a3                	jmp    800640 <vprintfmt+0x33f>
			putch('0', putdat);
  80069d:	83 ec 08             	sub    $0x8,%esp
  8006a0:	53                   	push   %ebx
  8006a1:	6a 30                	push   $0x30
  8006a3:	ff d6                	call   *%esi
			putch('x', putdat);
  8006a5:	83 c4 08             	add    $0x8,%esp
  8006a8:	53                   	push   %ebx
  8006a9:	6a 78                	push   $0x78
  8006ab:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b0:	8b 10                	mov    (%eax),%edx
  8006b2:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006b7:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006ba:	8d 40 04             	lea    0x4(%eax),%eax
  8006bd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c0:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006c5:	eb 82                	jmp    800649 <vprintfmt+0x348>
	if (lflag >= 2)
  8006c7:	83 f9 01             	cmp    $0x1,%ecx
  8006ca:	7f 1e                	jg     8006ea <vprintfmt+0x3e9>
	else if (lflag)
  8006cc:	85 c9                	test   %ecx,%ecx
  8006ce:	74 32                	je     800702 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  8006d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d3:	8b 10                	mov    (%eax),%edx
  8006d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006da:	8d 40 04             	lea    0x4(%eax),%eax
  8006dd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e0:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006e5:	e9 5f ff ff ff       	jmp    800649 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8006ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ed:	8b 10                	mov    (%eax),%edx
  8006ef:	8b 48 04             	mov    0x4(%eax),%ecx
  8006f2:	8d 40 08             	lea    0x8(%eax),%eax
  8006f5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f8:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006fd:	e9 47 ff ff ff       	jmp    800649 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800702:	8b 45 14             	mov    0x14(%ebp),%eax
  800705:	8b 10                	mov    (%eax),%edx
  800707:	b9 00 00 00 00       	mov    $0x0,%ecx
  80070c:	8d 40 04             	lea    0x4(%eax),%eax
  80070f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800712:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800717:	e9 2d ff ff ff       	jmp    800649 <vprintfmt+0x348>
			putch(ch, putdat);
  80071c:	83 ec 08             	sub    $0x8,%esp
  80071f:	53                   	push   %ebx
  800720:	6a 25                	push   $0x25
  800722:	ff d6                	call   *%esi
			break;
  800724:	83 c4 10             	add    $0x10,%esp
  800727:	e9 37 ff ff ff       	jmp    800663 <vprintfmt+0x362>
			putch('%', putdat);
  80072c:	83 ec 08             	sub    $0x8,%esp
  80072f:	53                   	push   %ebx
  800730:	6a 25                	push   $0x25
  800732:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800734:	83 c4 10             	add    $0x10,%esp
  800737:	89 f8                	mov    %edi,%eax
  800739:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80073d:	74 05                	je     800744 <vprintfmt+0x443>
  80073f:	83 e8 01             	sub    $0x1,%eax
  800742:	eb f5                	jmp    800739 <vprintfmt+0x438>
  800744:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800747:	e9 17 ff ff ff       	jmp    800663 <vprintfmt+0x362>
}
  80074c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074f:	5b                   	pop    %ebx
  800750:	5e                   	pop    %esi
  800751:	5f                   	pop    %edi
  800752:	5d                   	pop    %ebp
  800753:	c3                   	ret    

00800754 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800754:	f3 0f 1e fb          	endbr32 
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	83 ec 18             	sub    $0x18,%esp
  80075e:	8b 45 08             	mov    0x8(%ebp),%eax
  800761:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800764:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800767:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80076b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80076e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800775:	85 c0                	test   %eax,%eax
  800777:	74 26                	je     80079f <vsnprintf+0x4b>
  800779:	85 d2                	test   %edx,%edx
  80077b:	7e 22                	jle    80079f <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80077d:	ff 75 14             	pushl  0x14(%ebp)
  800780:	ff 75 10             	pushl  0x10(%ebp)
  800783:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800786:	50                   	push   %eax
  800787:	68 bf 02 80 00       	push   $0x8002bf
  80078c:	e8 70 fb ff ff       	call   800301 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800791:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800794:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800797:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80079a:	83 c4 10             	add    $0x10,%esp
}
  80079d:	c9                   	leave  
  80079e:	c3                   	ret    
		return -E_INVAL;
  80079f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a4:	eb f7                	jmp    80079d <vsnprintf+0x49>

008007a6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a6:	f3 0f 1e fb          	endbr32 
  8007aa:	55                   	push   %ebp
  8007ab:	89 e5                	mov    %esp,%ebp
  8007ad:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b3:	50                   	push   %eax
  8007b4:	ff 75 10             	pushl  0x10(%ebp)
  8007b7:	ff 75 0c             	pushl  0xc(%ebp)
  8007ba:	ff 75 08             	pushl  0x8(%ebp)
  8007bd:	e8 92 ff ff ff       	call   800754 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c2:	c9                   	leave  
  8007c3:	c3                   	ret    

008007c4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c4:	f3 0f 1e fb          	endbr32 
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d7:	74 05                	je     8007de <strlen+0x1a>
		n++;
  8007d9:	83 c0 01             	add    $0x1,%eax
  8007dc:	eb f5                	jmp    8007d3 <strlen+0xf>
	return n;
}
  8007de:	5d                   	pop    %ebp
  8007df:	c3                   	ret    

008007e0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e0:	f3 0f 1e fb          	endbr32 
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ea:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f2:	39 d0                	cmp    %edx,%eax
  8007f4:	74 0d                	je     800803 <strnlen+0x23>
  8007f6:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007fa:	74 05                	je     800801 <strnlen+0x21>
		n++;
  8007fc:	83 c0 01             	add    $0x1,%eax
  8007ff:	eb f1                	jmp    8007f2 <strnlen+0x12>
  800801:	89 c2                	mov    %eax,%edx
	return n;
}
  800803:	89 d0                	mov    %edx,%eax
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800807:	f3 0f 1e fb          	endbr32 
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	53                   	push   %ebx
  80080f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800812:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800815:	b8 00 00 00 00       	mov    $0x0,%eax
  80081a:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80081e:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800821:	83 c0 01             	add    $0x1,%eax
  800824:	84 d2                	test   %dl,%dl
  800826:	75 f2                	jne    80081a <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800828:	89 c8                	mov    %ecx,%eax
  80082a:	5b                   	pop    %ebx
  80082b:	5d                   	pop    %ebp
  80082c:	c3                   	ret    

0080082d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80082d:	f3 0f 1e fb          	endbr32 
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	53                   	push   %ebx
  800835:	83 ec 10             	sub    $0x10,%esp
  800838:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80083b:	53                   	push   %ebx
  80083c:	e8 83 ff ff ff       	call   8007c4 <strlen>
  800841:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800844:	ff 75 0c             	pushl  0xc(%ebp)
  800847:	01 d8                	add    %ebx,%eax
  800849:	50                   	push   %eax
  80084a:	e8 b8 ff ff ff       	call   800807 <strcpy>
	return dst;
}
  80084f:	89 d8                	mov    %ebx,%eax
  800851:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800854:	c9                   	leave  
  800855:	c3                   	ret    

00800856 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800856:	f3 0f 1e fb          	endbr32 
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	56                   	push   %esi
  80085e:	53                   	push   %ebx
  80085f:	8b 75 08             	mov    0x8(%ebp),%esi
  800862:	8b 55 0c             	mov    0xc(%ebp),%edx
  800865:	89 f3                	mov    %esi,%ebx
  800867:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80086a:	89 f0                	mov    %esi,%eax
  80086c:	39 d8                	cmp    %ebx,%eax
  80086e:	74 11                	je     800881 <strncpy+0x2b>
		*dst++ = *src;
  800870:	83 c0 01             	add    $0x1,%eax
  800873:	0f b6 0a             	movzbl (%edx),%ecx
  800876:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800879:	80 f9 01             	cmp    $0x1,%cl
  80087c:	83 da ff             	sbb    $0xffffffff,%edx
  80087f:	eb eb                	jmp    80086c <strncpy+0x16>
	}
	return ret;
}
  800881:	89 f0                	mov    %esi,%eax
  800883:	5b                   	pop    %ebx
  800884:	5e                   	pop    %esi
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800887:	f3 0f 1e fb          	endbr32 
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	56                   	push   %esi
  80088f:	53                   	push   %ebx
  800890:	8b 75 08             	mov    0x8(%ebp),%esi
  800893:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800896:	8b 55 10             	mov    0x10(%ebp),%edx
  800899:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80089b:	85 d2                	test   %edx,%edx
  80089d:	74 21                	je     8008c0 <strlcpy+0x39>
  80089f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008a3:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008a5:	39 c2                	cmp    %eax,%edx
  8008a7:	74 14                	je     8008bd <strlcpy+0x36>
  8008a9:	0f b6 19             	movzbl (%ecx),%ebx
  8008ac:	84 db                	test   %bl,%bl
  8008ae:	74 0b                	je     8008bb <strlcpy+0x34>
			*dst++ = *src++;
  8008b0:	83 c1 01             	add    $0x1,%ecx
  8008b3:	83 c2 01             	add    $0x1,%edx
  8008b6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008b9:	eb ea                	jmp    8008a5 <strlcpy+0x1e>
  8008bb:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008bd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008c0:	29 f0                	sub    %esi,%eax
}
  8008c2:	5b                   	pop    %ebx
  8008c3:	5e                   	pop    %esi
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    

008008c6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008c6:	f3 0f 1e fb          	endbr32 
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008d3:	0f b6 01             	movzbl (%ecx),%eax
  8008d6:	84 c0                	test   %al,%al
  8008d8:	74 0c                	je     8008e6 <strcmp+0x20>
  8008da:	3a 02                	cmp    (%edx),%al
  8008dc:	75 08                	jne    8008e6 <strcmp+0x20>
		p++, q++;
  8008de:	83 c1 01             	add    $0x1,%ecx
  8008e1:	83 c2 01             	add    $0x1,%edx
  8008e4:	eb ed                	jmp    8008d3 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e6:	0f b6 c0             	movzbl %al,%eax
  8008e9:	0f b6 12             	movzbl (%edx),%edx
  8008ec:	29 d0                	sub    %edx,%eax
}
  8008ee:	5d                   	pop    %ebp
  8008ef:	c3                   	ret    

008008f0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008f0:	f3 0f 1e fb          	endbr32 
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	53                   	push   %ebx
  8008f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fe:	89 c3                	mov    %eax,%ebx
  800900:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800903:	eb 06                	jmp    80090b <strncmp+0x1b>
		n--, p++, q++;
  800905:	83 c0 01             	add    $0x1,%eax
  800908:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80090b:	39 d8                	cmp    %ebx,%eax
  80090d:	74 16                	je     800925 <strncmp+0x35>
  80090f:	0f b6 08             	movzbl (%eax),%ecx
  800912:	84 c9                	test   %cl,%cl
  800914:	74 04                	je     80091a <strncmp+0x2a>
  800916:	3a 0a                	cmp    (%edx),%cl
  800918:	74 eb                	je     800905 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80091a:	0f b6 00             	movzbl (%eax),%eax
  80091d:	0f b6 12             	movzbl (%edx),%edx
  800920:	29 d0                	sub    %edx,%eax
}
  800922:	5b                   	pop    %ebx
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    
		return 0;
  800925:	b8 00 00 00 00       	mov    $0x0,%eax
  80092a:	eb f6                	jmp    800922 <strncmp+0x32>

0080092c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80092c:	f3 0f 1e fb          	endbr32 
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	8b 45 08             	mov    0x8(%ebp),%eax
  800936:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80093a:	0f b6 10             	movzbl (%eax),%edx
  80093d:	84 d2                	test   %dl,%dl
  80093f:	74 09                	je     80094a <strchr+0x1e>
		if (*s == c)
  800941:	38 ca                	cmp    %cl,%dl
  800943:	74 0a                	je     80094f <strchr+0x23>
	for (; *s; s++)
  800945:	83 c0 01             	add    $0x1,%eax
  800948:	eb f0                	jmp    80093a <strchr+0xe>
			return (char *) s;
	return 0;
  80094a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800951:	f3 0f 1e fb          	endbr32 
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	8b 45 08             	mov    0x8(%ebp),%eax
  80095b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80095f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800962:	38 ca                	cmp    %cl,%dl
  800964:	74 09                	je     80096f <strfind+0x1e>
  800966:	84 d2                	test   %dl,%dl
  800968:	74 05                	je     80096f <strfind+0x1e>
	for (; *s; s++)
  80096a:	83 c0 01             	add    $0x1,%eax
  80096d:	eb f0                	jmp    80095f <strfind+0xe>
			break;
	return (char *) s;
}
  80096f:	5d                   	pop    %ebp
  800970:	c3                   	ret    

00800971 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800971:	f3 0f 1e fb          	endbr32 
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	57                   	push   %edi
  800979:	56                   	push   %esi
  80097a:	53                   	push   %ebx
  80097b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80097e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800981:	85 c9                	test   %ecx,%ecx
  800983:	74 31                	je     8009b6 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800985:	89 f8                	mov    %edi,%eax
  800987:	09 c8                	or     %ecx,%eax
  800989:	a8 03                	test   $0x3,%al
  80098b:	75 23                	jne    8009b0 <memset+0x3f>
		c &= 0xFF;
  80098d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800991:	89 d3                	mov    %edx,%ebx
  800993:	c1 e3 08             	shl    $0x8,%ebx
  800996:	89 d0                	mov    %edx,%eax
  800998:	c1 e0 18             	shl    $0x18,%eax
  80099b:	89 d6                	mov    %edx,%esi
  80099d:	c1 e6 10             	shl    $0x10,%esi
  8009a0:	09 f0                	or     %esi,%eax
  8009a2:	09 c2                	or     %eax,%edx
  8009a4:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009a6:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009a9:	89 d0                	mov    %edx,%eax
  8009ab:	fc                   	cld    
  8009ac:	f3 ab                	rep stos %eax,%es:(%edi)
  8009ae:	eb 06                	jmp    8009b6 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b3:	fc                   	cld    
  8009b4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009b6:	89 f8                	mov    %edi,%eax
  8009b8:	5b                   	pop    %ebx
  8009b9:	5e                   	pop    %esi
  8009ba:	5f                   	pop    %edi
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009bd:	f3 0f 1e fb          	endbr32 
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	57                   	push   %edi
  8009c5:	56                   	push   %esi
  8009c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009cc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009cf:	39 c6                	cmp    %eax,%esi
  8009d1:	73 32                	jae    800a05 <memmove+0x48>
  8009d3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009d6:	39 c2                	cmp    %eax,%edx
  8009d8:	76 2b                	jbe    800a05 <memmove+0x48>
		s += n;
		d += n;
  8009da:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009dd:	89 fe                	mov    %edi,%esi
  8009df:	09 ce                	or     %ecx,%esi
  8009e1:	09 d6                	or     %edx,%esi
  8009e3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009e9:	75 0e                	jne    8009f9 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009eb:	83 ef 04             	sub    $0x4,%edi
  8009ee:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009f1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009f4:	fd                   	std    
  8009f5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f7:	eb 09                	jmp    800a02 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009f9:	83 ef 01             	sub    $0x1,%edi
  8009fc:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009ff:	fd                   	std    
  800a00:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a02:	fc                   	cld    
  800a03:	eb 1a                	jmp    800a1f <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a05:	89 c2                	mov    %eax,%edx
  800a07:	09 ca                	or     %ecx,%edx
  800a09:	09 f2                	or     %esi,%edx
  800a0b:	f6 c2 03             	test   $0x3,%dl
  800a0e:	75 0a                	jne    800a1a <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a10:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a13:	89 c7                	mov    %eax,%edi
  800a15:	fc                   	cld    
  800a16:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a18:	eb 05                	jmp    800a1f <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a1a:	89 c7                	mov    %eax,%edi
  800a1c:	fc                   	cld    
  800a1d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a1f:	5e                   	pop    %esi
  800a20:	5f                   	pop    %edi
  800a21:	5d                   	pop    %ebp
  800a22:	c3                   	ret    

00800a23 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a23:	f3 0f 1e fb          	endbr32 
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a2d:	ff 75 10             	pushl  0x10(%ebp)
  800a30:	ff 75 0c             	pushl  0xc(%ebp)
  800a33:	ff 75 08             	pushl  0x8(%ebp)
  800a36:	e8 82 ff ff ff       	call   8009bd <memmove>
}
  800a3b:	c9                   	leave  
  800a3c:	c3                   	ret    

00800a3d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a3d:	f3 0f 1e fb          	endbr32 
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	56                   	push   %esi
  800a45:	53                   	push   %ebx
  800a46:	8b 45 08             	mov    0x8(%ebp),%eax
  800a49:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4c:	89 c6                	mov    %eax,%esi
  800a4e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a51:	39 f0                	cmp    %esi,%eax
  800a53:	74 1c                	je     800a71 <memcmp+0x34>
		if (*s1 != *s2)
  800a55:	0f b6 08             	movzbl (%eax),%ecx
  800a58:	0f b6 1a             	movzbl (%edx),%ebx
  800a5b:	38 d9                	cmp    %bl,%cl
  800a5d:	75 08                	jne    800a67 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a5f:	83 c0 01             	add    $0x1,%eax
  800a62:	83 c2 01             	add    $0x1,%edx
  800a65:	eb ea                	jmp    800a51 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a67:	0f b6 c1             	movzbl %cl,%eax
  800a6a:	0f b6 db             	movzbl %bl,%ebx
  800a6d:	29 d8                	sub    %ebx,%eax
  800a6f:	eb 05                	jmp    800a76 <memcmp+0x39>
	}

	return 0;
  800a71:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a76:	5b                   	pop    %ebx
  800a77:	5e                   	pop    %esi
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a7a:	f3 0f 1e fb          	endbr32 
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	8b 45 08             	mov    0x8(%ebp),%eax
  800a84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a87:	89 c2                	mov    %eax,%edx
  800a89:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a8c:	39 d0                	cmp    %edx,%eax
  800a8e:	73 09                	jae    800a99 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a90:	38 08                	cmp    %cl,(%eax)
  800a92:	74 05                	je     800a99 <memfind+0x1f>
	for (; s < ends; s++)
  800a94:	83 c0 01             	add    $0x1,%eax
  800a97:	eb f3                	jmp    800a8c <memfind+0x12>
			break;
	return (void *) s;
}
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a9b:	f3 0f 1e fb          	endbr32 
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	57                   	push   %edi
  800aa3:	56                   	push   %esi
  800aa4:	53                   	push   %ebx
  800aa5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aab:	eb 03                	jmp    800ab0 <strtol+0x15>
		s++;
  800aad:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ab0:	0f b6 01             	movzbl (%ecx),%eax
  800ab3:	3c 20                	cmp    $0x20,%al
  800ab5:	74 f6                	je     800aad <strtol+0x12>
  800ab7:	3c 09                	cmp    $0x9,%al
  800ab9:	74 f2                	je     800aad <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800abb:	3c 2b                	cmp    $0x2b,%al
  800abd:	74 2a                	je     800ae9 <strtol+0x4e>
	int neg = 0;
  800abf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ac4:	3c 2d                	cmp    $0x2d,%al
  800ac6:	74 2b                	je     800af3 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ace:	75 0f                	jne    800adf <strtol+0x44>
  800ad0:	80 39 30             	cmpb   $0x30,(%ecx)
  800ad3:	74 28                	je     800afd <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ad5:	85 db                	test   %ebx,%ebx
  800ad7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800adc:	0f 44 d8             	cmove  %eax,%ebx
  800adf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae4:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ae7:	eb 46                	jmp    800b2f <strtol+0x94>
		s++;
  800ae9:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800aec:	bf 00 00 00 00       	mov    $0x0,%edi
  800af1:	eb d5                	jmp    800ac8 <strtol+0x2d>
		s++, neg = 1;
  800af3:	83 c1 01             	add    $0x1,%ecx
  800af6:	bf 01 00 00 00       	mov    $0x1,%edi
  800afb:	eb cb                	jmp    800ac8 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800afd:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b01:	74 0e                	je     800b11 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b03:	85 db                	test   %ebx,%ebx
  800b05:	75 d8                	jne    800adf <strtol+0x44>
		s++, base = 8;
  800b07:	83 c1 01             	add    $0x1,%ecx
  800b0a:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b0f:	eb ce                	jmp    800adf <strtol+0x44>
		s += 2, base = 16;
  800b11:	83 c1 02             	add    $0x2,%ecx
  800b14:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b19:	eb c4                	jmp    800adf <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b1b:	0f be d2             	movsbl %dl,%edx
  800b1e:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b21:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b24:	7d 3a                	jge    800b60 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b26:	83 c1 01             	add    $0x1,%ecx
  800b29:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b2d:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b2f:	0f b6 11             	movzbl (%ecx),%edx
  800b32:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b35:	89 f3                	mov    %esi,%ebx
  800b37:	80 fb 09             	cmp    $0x9,%bl
  800b3a:	76 df                	jbe    800b1b <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b3c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b3f:	89 f3                	mov    %esi,%ebx
  800b41:	80 fb 19             	cmp    $0x19,%bl
  800b44:	77 08                	ja     800b4e <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b46:	0f be d2             	movsbl %dl,%edx
  800b49:	83 ea 57             	sub    $0x57,%edx
  800b4c:	eb d3                	jmp    800b21 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b4e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b51:	89 f3                	mov    %esi,%ebx
  800b53:	80 fb 19             	cmp    $0x19,%bl
  800b56:	77 08                	ja     800b60 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b58:	0f be d2             	movsbl %dl,%edx
  800b5b:	83 ea 37             	sub    $0x37,%edx
  800b5e:	eb c1                	jmp    800b21 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b60:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b64:	74 05                	je     800b6b <strtol+0xd0>
		*endptr = (char *) s;
  800b66:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b69:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b6b:	89 c2                	mov    %eax,%edx
  800b6d:	f7 da                	neg    %edx
  800b6f:	85 ff                	test   %edi,%edi
  800b71:	0f 45 c2             	cmovne %edx,%eax
}
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5f                   	pop    %edi
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b79:	f3 0f 1e fb          	endbr32 
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	57                   	push   %edi
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b83:	b8 00 00 00 00       	mov    $0x0,%eax
  800b88:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8e:	89 c3                	mov    %eax,%ebx
  800b90:	89 c7                	mov    %eax,%edi
  800b92:	89 c6                	mov    %eax,%esi
  800b94:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <sys_cgetc>:

int
sys_cgetc(void)
{
  800b9b:	f3 0f 1e fb          	endbr32 
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	57                   	push   %edi
  800ba3:	56                   	push   %esi
  800ba4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ba5:	ba 00 00 00 00       	mov    $0x0,%edx
  800baa:	b8 01 00 00 00       	mov    $0x1,%eax
  800baf:	89 d1                	mov    %edx,%ecx
  800bb1:	89 d3                	mov    %edx,%ebx
  800bb3:	89 d7                	mov    %edx,%edi
  800bb5:	89 d6                	mov    %edx,%esi
  800bb7:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bbe:	f3 0f 1e fb          	endbr32 
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
  800bc8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bcb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd3:	b8 03 00 00 00       	mov    $0x3,%eax
  800bd8:	89 cb                	mov    %ecx,%ebx
  800bda:	89 cf                	mov    %ecx,%edi
  800bdc:	89 ce                	mov    %ecx,%esi
  800bde:	cd 30                	int    $0x30
	if(check && ret > 0)
  800be0:	85 c0                	test   %eax,%eax
  800be2:	7f 08                	jg     800bec <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800be4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be7:	5b                   	pop    %ebx
  800be8:	5e                   	pop    %esi
  800be9:	5f                   	pop    %edi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bec:	83 ec 0c             	sub    $0xc,%esp
  800bef:	50                   	push   %eax
  800bf0:	6a 03                	push   $0x3
  800bf2:	68 9f 25 80 00       	push   $0x80259f
  800bf7:	6a 23                	push   $0x23
  800bf9:	68 bc 25 80 00       	push   $0x8025bc
  800bfe:	e8 e8 11 00 00       	call   801deb <_panic>

00800c03 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c03:	f3 0f 1e fb          	endbr32 
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c12:	b8 02 00 00 00       	mov    $0x2,%eax
  800c17:	89 d1                	mov    %edx,%ecx
  800c19:	89 d3                	mov    %edx,%ebx
  800c1b:	89 d7                	mov    %edx,%edi
  800c1d:	89 d6                	mov    %edx,%esi
  800c1f:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <sys_yield>:

void
sys_yield(void)
{
  800c26:	f3 0f 1e fb          	endbr32 
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	57                   	push   %edi
  800c2e:	56                   	push   %esi
  800c2f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c30:	ba 00 00 00 00       	mov    $0x0,%edx
  800c35:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c3a:	89 d1                	mov    %edx,%ecx
  800c3c:	89 d3                	mov    %edx,%ebx
  800c3e:	89 d7                	mov    %edx,%edi
  800c40:	89 d6                	mov    %edx,%esi
  800c42:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c44:	5b                   	pop    %ebx
  800c45:	5e                   	pop    %esi
  800c46:	5f                   	pop    %edi
  800c47:	5d                   	pop    %ebp
  800c48:	c3                   	ret    

00800c49 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c49:	f3 0f 1e fb          	endbr32 
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	57                   	push   %edi
  800c51:	56                   	push   %esi
  800c52:	53                   	push   %ebx
  800c53:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c56:	be 00 00 00 00       	mov    $0x0,%esi
  800c5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c61:	b8 04 00 00 00       	mov    $0x4,%eax
  800c66:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c69:	89 f7                	mov    %esi,%edi
  800c6b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c6d:	85 c0                	test   %eax,%eax
  800c6f:	7f 08                	jg     800c79 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c74:	5b                   	pop    %ebx
  800c75:	5e                   	pop    %esi
  800c76:	5f                   	pop    %edi
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c79:	83 ec 0c             	sub    $0xc,%esp
  800c7c:	50                   	push   %eax
  800c7d:	6a 04                	push   $0x4
  800c7f:	68 9f 25 80 00       	push   $0x80259f
  800c84:	6a 23                	push   $0x23
  800c86:	68 bc 25 80 00       	push   $0x8025bc
  800c8b:	e8 5b 11 00 00       	call   801deb <_panic>

00800c90 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c90:	f3 0f 1e fb          	endbr32 
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	57                   	push   %edi
  800c98:	56                   	push   %esi
  800c99:	53                   	push   %ebx
  800c9a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca3:	b8 05 00 00 00       	mov    $0x5,%eax
  800ca8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cab:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cae:	8b 75 18             	mov    0x18(%ebp),%esi
  800cb1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	7f 08                	jg     800cbf <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cba:	5b                   	pop    %ebx
  800cbb:	5e                   	pop    %esi
  800cbc:	5f                   	pop    %edi
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbf:	83 ec 0c             	sub    $0xc,%esp
  800cc2:	50                   	push   %eax
  800cc3:	6a 05                	push   $0x5
  800cc5:	68 9f 25 80 00       	push   $0x80259f
  800cca:	6a 23                	push   $0x23
  800ccc:	68 bc 25 80 00       	push   $0x8025bc
  800cd1:	e8 15 11 00 00       	call   801deb <_panic>

00800cd6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cd6:	f3 0f 1e fb          	endbr32 
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
  800ce0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ce3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ceb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cee:	b8 06 00 00 00       	mov    $0x6,%eax
  800cf3:	89 df                	mov    %ebx,%edi
  800cf5:	89 de                	mov    %ebx,%esi
  800cf7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	7f 08                	jg     800d05 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d00:	5b                   	pop    %ebx
  800d01:	5e                   	pop    %esi
  800d02:	5f                   	pop    %edi
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d05:	83 ec 0c             	sub    $0xc,%esp
  800d08:	50                   	push   %eax
  800d09:	6a 06                	push   $0x6
  800d0b:	68 9f 25 80 00       	push   $0x80259f
  800d10:	6a 23                	push   $0x23
  800d12:	68 bc 25 80 00       	push   $0x8025bc
  800d17:	e8 cf 10 00 00       	call   801deb <_panic>

00800d1c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d1c:	f3 0f 1e fb          	endbr32 
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	57                   	push   %edi
  800d24:	56                   	push   %esi
  800d25:	53                   	push   %ebx
  800d26:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d29:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d34:	b8 08 00 00 00       	mov    $0x8,%eax
  800d39:	89 df                	mov    %ebx,%edi
  800d3b:	89 de                	mov    %ebx,%esi
  800d3d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d3f:	85 c0                	test   %eax,%eax
  800d41:	7f 08                	jg     800d4b <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d46:	5b                   	pop    %ebx
  800d47:	5e                   	pop    %esi
  800d48:	5f                   	pop    %edi
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4b:	83 ec 0c             	sub    $0xc,%esp
  800d4e:	50                   	push   %eax
  800d4f:	6a 08                	push   $0x8
  800d51:	68 9f 25 80 00       	push   $0x80259f
  800d56:	6a 23                	push   $0x23
  800d58:	68 bc 25 80 00       	push   $0x8025bc
  800d5d:	e8 89 10 00 00       	call   801deb <_panic>

00800d62 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d62:	f3 0f 1e fb          	endbr32 
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	57                   	push   %edi
  800d6a:	56                   	push   %esi
  800d6b:	53                   	push   %ebx
  800d6c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d74:	8b 55 08             	mov    0x8(%ebp),%edx
  800d77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7a:	b8 09 00 00 00       	mov    $0x9,%eax
  800d7f:	89 df                	mov    %ebx,%edi
  800d81:	89 de                	mov    %ebx,%esi
  800d83:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d85:	85 c0                	test   %eax,%eax
  800d87:	7f 08                	jg     800d91 <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8c:	5b                   	pop    %ebx
  800d8d:	5e                   	pop    %esi
  800d8e:	5f                   	pop    %edi
  800d8f:	5d                   	pop    %ebp
  800d90:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d91:	83 ec 0c             	sub    $0xc,%esp
  800d94:	50                   	push   %eax
  800d95:	6a 09                	push   $0x9
  800d97:	68 9f 25 80 00       	push   $0x80259f
  800d9c:	6a 23                	push   $0x23
  800d9e:	68 bc 25 80 00       	push   $0x8025bc
  800da3:	e8 43 10 00 00       	call   801deb <_panic>

00800da8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800da8:	f3 0f 1e fb          	endbr32 
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	57                   	push   %edi
  800db0:	56                   	push   %esi
  800db1:	53                   	push   %ebx
  800db2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800db5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dba:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dc5:	89 df                	mov    %ebx,%edi
  800dc7:	89 de                	mov    %ebx,%esi
  800dc9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dcb:	85 c0                	test   %eax,%eax
  800dcd:	7f 08                	jg     800dd7 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dcf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd2:	5b                   	pop    %ebx
  800dd3:	5e                   	pop    %esi
  800dd4:	5f                   	pop    %edi
  800dd5:	5d                   	pop    %ebp
  800dd6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd7:	83 ec 0c             	sub    $0xc,%esp
  800dda:	50                   	push   %eax
  800ddb:	6a 0a                	push   $0xa
  800ddd:	68 9f 25 80 00       	push   $0x80259f
  800de2:	6a 23                	push   $0x23
  800de4:	68 bc 25 80 00       	push   $0x8025bc
  800de9:	e8 fd 0f 00 00       	call   801deb <_panic>

00800dee <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dee:	f3 0f 1e fb          	endbr32 
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	57                   	push   %edi
  800df6:	56                   	push   %esi
  800df7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800df8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfe:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e03:	be 00 00 00 00       	mov    $0x0,%esi
  800e08:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e0b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e0e:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e10:	5b                   	pop    %ebx
  800e11:	5e                   	pop    %esi
  800e12:	5f                   	pop    %edi
  800e13:	5d                   	pop    %ebp
  800e14:	c3                   	ret    

00800e15 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e15:	f3 0f 1e fb          	endbr32 
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	57                   	push   %edi
  800e1d:	56                   	push   %esi
  800e1e:	53                   	push   %ebx
  800e1f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e22:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e27:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e2f:	89 cb                	mov    %ecx,%ebx
  800e31:	89 cf                	mov    %ecx,%edi
  800e33:	89 ce                	mov    %ecx,%esi
  800e35:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e37:	85 c0                	test   %eax,%eax
  800e39:	7f 08                	jg     800e43 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3e:	5b                   	pop    %ebx
  800e3f:	5e                   	pop    %esi
  800e40:	5f                   	pop    %edi
  800e41:	5d                   	pop    %ebp
  800e42:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e43:	83 ec 0c             	sub    $0xc,%esp
  800e46:	50                   	push   %eax
  800e47:	6a 0d                	push   $0xd
  800e49:	68 9f 25 80 00       	push   $0x80259f
  800e4e:	6a 23                	push   $0x23
  800e50:	68 bc 25 80 00       	push   $0x8025bc
  800e55:	e8 91 0f 00 00       	call   801deb <_panic>

00800e5a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e5a:	f3 0f 1e fb          	endbr32 
  800e5e:	55                   	push   %ebp
  800e5f:	89 e5                	mov    %esp,%ebp
  800e61:	53                   	push   %ebx
  800e62:	83 ec 04             	sub    $0x4,%esp
  800e65:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e68:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if ( !(err & FEC_WR) ||
  800e6a:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e6e:	74 75                	je     800ee5 <pgfault+0x8b>
            !(uvpt[PGNUM(addr)] | PTE_COW) ) {
  800e70:	89 d8                	mov    %ebx,%eax
  800e72:	c1 e8 0c             	shr    $0xc,%eax
  800e75:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, (void *)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0) {
  800e7c:	83 ec 04             	sub    $0x4,%esp
  800e7f:	6a 07                	push   $0x7
  800e81:	68 00 f0 7f 00       	push   $0x7ff000
  800e86:	6a 00                	push   $0x0
  800e88:	e8 bc fd ff ff       	call   800c49 <sys_page_alloc>
  800e8d:	83 c4 10             	add    $0x10,%esp
  800e90:	85 c0                	test   %eax,%eax
  800e92:	78 65                	js     800ef9 <pgfault+0x9f>
        panic("sys_page_alloc failed %e\n", r);
    }
    memmove((void *)PFTEMP, (void *)PTE_ADDR(addr), PGSIZE);
  800e94:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800e9a:	83 ec 04             	sub    $0x4,%esp
  800e9d:	68 00 10 00 00       	push   $0x1000
  800ea2:	53                   	push   %ebx
  800ea3:	68 00 f0 7f 00       	push   $0x7ff000
  800ea8:	e8 10 fb ff ff       	call   8009bd <memmove>
    if ((r = sys_page_map(0, (void *)PFTEMP,
  800ead:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800eb4:	53                   	push   %ebx
  800eb5:	6a 00                	push   $0x0
  800eb7:	68 00 f0 7f 00       	push   $0x7ff000
  800ebc:	6a 00                	push   $0x0
  800ebe:	e8 cd fd ff ff       	call   800c90 <sys_page_map>
  800ec3:	83 c4 20             	add    $0x20,%esp
  800ec6:	85 c0                	test   %eax,%eax
  800ec8:	78 41                	js     800f0b <pgfault+0xb1>
                0, (void *)PTE_ADDR(addr), PTE_P | PTE_U | PTE_W)) < 0) {
        panic("sys_page_map failed %e\n", r);
    }
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0) {
  800eca:	83 ec 08             	sub    $0x8,%esp
  800ecd:	68 00 f0 7f 00       	push   $0x7ff000
  800ed2:	6a 00                	push   $0x0
  800ed4:	e8 fd fd ff ff       	call   800cd6 <sys_page_unmap>
  800ed9:	83 c4 10             	add    $0x10,%esp
  800edc:	85 c0                	test   %eax,%eax
  800ede:	78 3d                	js     800f1d <pgfault+0xc3>
        panic("sys_page_unmap failed %e\n", r);
    }

}
  800ee0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ee3:	c9                   	leave  
  800ee4:	c3                   	ret    
        panic("Not a copy-on-write page");
  800ee5:	83 ec 04             	sub    $0x4,%esp
  800ee8:	68 ca 25 80 00       	push   $0x8025ca
  800eed:	6a 1e                	push   $0x1e
  800eef:	68 e3 25 80 00       	push   $0x8025e3
  800ef4:	e8 f2 0e 00 00       	call   801deb <_panic>
        panic("sys_page_alloc failed %e\n", r);
  800ef9:	50                   	push   %eax
  800efa:	68 ee 25 80 00       	push   $0x8025ee
  800eff:	6a 2a                	push   $0x2a
  800f01:	68 e3 25 80 00       	push   $0x8025e3
  800f06:	e8 e0 0e 00 00       	call   801deb <_panic>
        panic("sys_page_map failed %e\n", r);
  800f0b:	50                   	push   %eax
  800f0c:	68 08 26 80 00       	push   $0x802608
  800f11:	6a 2f                	push   $0x2f
  800f13:	68 e3 25 80 00       	push   $0x8025e3
  800f18:	e8 ce 0e 00 00       	call   801deb <_panic>
        panic("sys_page_unmap failed %e\n", r);
  800f1d:	50                   	push   %eax
  800f1e:	68 20 26 80 00       	push   $0x802620
  800f23:	6a 32                	push   $0x32
  800f25:	68 e3 25 80 00       	push   $0x8025e3
  800f2a:	e8 bc 0e 00 00       	call   801deb <_panic>

00800f2f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f2f:	f3 0f 1e fb          	endbr32 
  800f33:	55                   	push   %ebp
  800f34:	89 e5                	mov    %esp,%ebp
  800f36:	57                   	push   %edi
  800f37:	56                   	push   %esi
  800f38:	53                   	push   %ebx
  800f39:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");

    // 1. set pgfault handler.
    set_pgfault_handler(pgfault);
  800f3c:	68 5a 0e 80 00       	push   $0x800e5a
  800f41:	e8 ef 0e 00 00       	call   801e35 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f46:	b8 07 00 00 00       	mov    $0x7,%eax
  800f4b:	cd 30                	int    $0x30
  800f4d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f50:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    // 2. exofork.
    envid_t envid = sys_exofork();

    if (envid < 0)
  800f53:	83 c4 10             	add    $0x10,%esp
  800f56:	85 c0                	test   %eax,%eax
  800f58:	78 2a                	js     800f84 <fork+0x55>
        thisenv = &envs[ENVX(my_envid)];
        return 0;
    }
    else {
        // parent
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800f5a:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (envid == 0) {
  800f5f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800f63:	75 69                	jne    800fce <fork+0x9f>
        envid_t my_envid = sys_getenvid();
  800f65:	e8 99 fc ff ff       	call   800c03 <sys_getenvid>
        thisenv = &envs[ENVX(my_envid)];
  800f6a:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f6f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f72:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f77:	a3 04 40 80 00       	mov    %eax,0x804004
        return 0;
  800f7c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f7f:	e9 fc 00 00 00       	jmp    801080 <fork+0x151>
        panic("fork, sys_exofork %e", envid);
  800f84:	50                   	push   %eax
  800f85:	68 3a 26 80 00       	push   $0x80263a
  800f8a:	6a 7b                	push   $0x7b
  800f8c:	68 e3 25 80 00       	push   $0x8025e3
  800f91:	e8 55 0e 00 00       	call   801deb <_panic>
    if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0) {
  800f96:	83 ec 0c             	sub    $0xc,%esp
  800f99:	57                   	push   %edi
  800f9a:	56                   	push   %esi
  800f9b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f9e:	56                   	push   %esi
  800f9f:	6a 00                	push   $0x0
  800fa1:	e8 ea fc ff ff       	call   800c90 <sys_page_map>
  800fa6:	83 c4 20             	add    $0x20,%esp
  800fa9:	85 c0                	test   %eax,%eax
  800fab:	78 69                	js     801016 <fork+0xe7>
        if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0) {
  800fad:	83 ec 0c             	sub    $0xc,%esp
  800fb0:	57                   	push   %edi
  800fb1:	56                   	push   %esi
  800fb2:	6a 00                	push   $0x0
  800fb4:	56                   	push   %esi
  800fb5:	6a 00                	push   $0x0
  800fb7:	e8 d4 fc ff ff       	call   800c90 <sys_page_map>
  800fbc:	83 c4 20             	add    $0x20,%esp
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	78 65                	js     801028 <fork+0xf9>
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800fc3:	83 c3 01             	add    $0x1,%ebx
  800fc6:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  800fcc:	74 6c                	je     80103a <fork+0x10b>
  800fce:	89 de                	mov    %ebx,%esi
  800fd0:	c1 e6 0c             	shl    $0xc,%esi
            uintptr_t pgaddr = pn << PGSHIFT;
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800fd3:	89 f0                	mov    %esi,%eax
  800fd5:	c1 e8 16             	shr    $0x16,%eax
  800fd8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fdf:	a8 01                	test   $0x1,%al
  800fe1:	74 e0                	je     800fc3 <fork+0x94>
                    (uvpt[pn] & PTE_P) ) {
  800fe3:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800fea:	a8 01                	test   $0x1,%al
  800fec:	74 d5                	je     800fc3 <fork+0x94>
    pte_t pte = uvpt[pn];
  800fee:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
    int perm = PTE_U | PTE_P;
  800ff5:	bf 05 00 00 00       	mov    $0x5,%edi
    if ( ((pte & PTE_W) || (pte & PTE_COW)) && !(pte & PTE_SHARE)) {
  800ffa:	a9 02 08 00 00       	test   $0x802,%eax
  800fff:	74 95                	je     800f96 <fork+0x67>
  801001:	25 00 04 00 00       	and    $0x400,%eax
        perm |= PTE_COW;
  801006:	83 f8 01             	cmp    $0x1,%eax
  801009:	19 ff                	sbb    %edi,%edi
  80100b:	81 e7 00 08 00 00    	and    $0x800,%edi
  801011:	83 c7 05             	add    $0x5,%edi
  801014:	eb 80                	jmp    800f96 <fork+0x67>
        panic("sys_page_map others failed %e\n", r);
  801016:	50                   	push   %eax
  801017:	68 84 26 80 00       	push   $0x802684
  80101c:	6a 51                	push   $0x51
  80101e:	68 e3 25 80 00       	push   $0x8025e3
  801023:	e8 c3 0d 00 00       	call   801deb <_panic>
            panic("sys_page_map mine failed %e\n", r);
  801028:	50                   	push   %eax
  801029:	68 4f 26 80 00       	push   $0x80264f
  80102e:	6a 56                	push   $0x56
  801030:	68 e3 25 80 00       	push   $0x8025e3
  801035:	e8 b1 0d 00 00       	call   801deb <_panic>
            }
        }

        int r;

        if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE),
  80103a:	83 ec 04             	sub    $0x4,%esp
  80103d:	6a 07                	push   $0x7
  80103f:	68 00 f0 bf ee       	push   $0xeebff000
  801044:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801047:	57                   	push   %edi
  801048:	e8 fc fb ff ff       	call   800c49 <sys_page_alloc>
  80104d:	83 c4 10             	add    $0x10,%esp
  801050:	85 c0                	test   %eax,%eax
  801052:	78 2c                	js     801080 <fork+0x151>
                    PTE_U | PTE_W | PTE_P)) < 0) {
            return r;
        }

        if ((r = sys_env_set_pgfault_upcall(envid,
                        thisenv->env_pgfault_upcall)) < 0) {
  801054:	a1 04 40 80 00       	mov    0x804004,%eax
        if ((r = sys_env_set_pgfault_upcall(envid,
  801059:	8b 40 64             	mov    0x64(%eax),%eax
  80105c:	83 ec 08             	sub    $0x8,%esp
  80105f:	50                   	push   %eax
  801060:	57                   	push   %edi
  801061:	e8 42 fd ff ff       	call   800da8 <sys_env_set_pgfault_upcall>
  801066:	83 c4 10             	add    $0x10,%esp
  801069:	85 c0                	test   %eax,%eax
  80106b:	78 13                	js     801080 <fork+0x151>
            return r;
        }

        if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  80106d:	83 ec 08             	sub    $0x8,%esp
  801070:	6a 02                	push   $0x2
  801072:	57                   	push   %edi
  801073:	e8 a4 fc ff ff       	call   800d1c <sys_env_set_status>
  801078:	83 c4 10             	add    $0x10,%esp
            return r;
        }
        return envid;
  80107b:	85 c0                	test   %eax,%eax
  80107d:	0f 49 c7             	cmovns %edi,%eax
    }

}
  801080:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801083:	5b                   	pop    %ebx
  801084:	5e                   	pop    %esi
  801085:	5f                   	pop    %edi
  801086:	5d                   	pop    %ebp
  801087:	c3                   	ret    

00801088 <sfork>:

// Challenge!
int
sfork(void)
{
  801088:	f3 0f 1e fb          	endbr32 
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801092:	68 6c 26 80 00       	push   $0x80266c
  801097:	68 a5 00 00 00       	push   $0xa5
  80109c:	68 e3 25 80 00       	push   $0x8025e3
  8010a1:	e8 45 0d 00 00       	call   801deb <_panic>

008010a6 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010a6:	f3 0f 1e fb          	endbr32 
  8010aa:	55                   	push   %ebp
  8010ab:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b0:	05 00 00 00 30       	add    $0x30000000,%eax
  8010b5:	c1 e8 0c             	shr    $0xc,%eax
}
  8010b8:	5d                   	pop    %ebp
  8010b9:	c3                   	ret    

008010ba <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010ba:	f3 0f 1e fb          	endbr32 
  8010be:	55                   	push   %ebp
  8010bf:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c4:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8010c9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010ce:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010d3:	5d                   	pop    %ebp
  8010d4:	c3                   	ret    

008010d5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010d5:	f3 0f 1e fb          	endbr32 
  8010d9:	55                   	push   %ebp
  8010da:	89 e5                	mov    %esp,%ebp
  8010dc:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010e1:	89 c2                	mov    %eax,%edx
  8010e3:	c1 ea 16             	shr    $0x16,%edx
  8010e6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010ed:	f6 c2 01             	test   $0x1,%dl
  8010f0:	74 2d                	je     80111f <fd_alloc+0x4a>
  8010f2:	89 c2                	mov    %eax,%edx
  8010f4:	c1 ea 0c             	shr    $0xc,%edx
  8010f7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010fe:	f6 c2 01             	test   $0x1,%dl
  801101:	74 1c                	je     80111f <fd_alloc+0x4a>
  801103:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801108:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80110d:	75 d2                	jne    8010e1 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80110f:	8b 45 08             	mov    0x8(%ebp),%eax
  801112:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801118:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80111d:	eb 0a                	jmp    801129 <fd_alloc+0x54>
			*fd_store = fd;
  80111f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801122:	89 01                	mov    %eax,(%ecx)
			return 0;
  801124:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801129:	5d                   	pop    %ebp
  80112a:	c3                   	ret    

0080112b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80112b:	f3 0f 1e fb          	endbr32 
  80112f:	55                   	push   %ebp
  801130:	89 e5                	mov    %esp,%ebp
  801132:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801135:	83 f8 1f             	cmp    $0x1f,%eax
  801138:	77 30                	ja     80116a <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80113a:	c1 e0 0c             	shl    $0xc,%eax
  80113d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801142:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801148:	f6 c2 01             	test   $0x1,%dl
  80114b:	74 24                	je     801171 <fd_lookup+0x46>
  80114d:	89 c2                	mov    %eax,%edx
  80114f:	c1 ea 0c             	shr    $0xc,%edx
  801152:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801159:	f6 c2 01             	test   $0x1,%dl
  80115c:	74 1a                	je     801178 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80115e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801161:	89 02                	mov    %eax,(%edx)
	return 0;
  801163:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801168:	5d                   	pop    %ebp
  801169:	c3                   	ret    
		return -E_INVAL;
  80116a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80116f:	eb f7                	jmp    801168 <fd_lookup+0x3d>
		return -E_INVAL;
  801171:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801176:	eb f0                	jmp    801168 <fd_lookup+0x3d>
  801178:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80117d:	eb e9                	jmp    801168 <fd_lookup+0x3d>

0080117f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80117f:	f3 0f 1e fb          	endbr32 
  801183:	55                   	push   %ebp
  801184:	89 e5                	mov    %esp,%ebp
  801186:	83 ec 08             	sub    $0x8,%esp
  801189:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80118c:	ba 20 27 80 00       	mov    $0x802720,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801191:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  801196:	39 08                	cmp    %ecx,(%eax)
  801198:	74 33                	je     8011cd <dev_lookup+0x4e>
  80119a:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80119d:	8b 02                	mov    (%edx),%eax
  80119f:	85 c0                	test   %eax,%eax
  8011a1:	75 f3                	jne    801196 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011a3:	a1 04 40 80 00       	mov    0x804004,%eax
  8011a8:	8b 40 48             	mov    0x48(%eax),%eax
  8011ab:	83 ec 04             	sub    $0x4,%esp
  8011ae:	51                   	push   %ecx
  8011af:	50                   	push   %eax
  8011b0:	68 a4 26 80 00       	push   $0x8026a4
  8011b5:	e8 44 f0 ff ff       	call   8001fe <cprintf>
	*dev = 0;
  8011ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011bd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011c3:	83 c4 10             	add    $0x10,%esp
  8011c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011cb:	c9                   	leave  
  8011cc:	c3                   	ret    
			*dev = devtab[i];
  8011cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d7:	eb f2                	jmp    8011cb <dev_lookup+0x4c>

008011d9 <fd_close>:
{
  8011d9:	f3 0f 1e fb          	endbr32 
  8011dd:	55                   	push   %ebp
  8011de:	89 e5                	mov    %esp,%ebp
  8011e0:	57                   	push   %edi
  8011e1:	56                   	push   %esi
  8011e2:	53                   	push   %ebx
  8011e3:	83 ec 24             	sub    $0x24,%esp
  8011e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8011e9:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011ec:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011ef:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011f0:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011f6:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011f9:	50                   	push   %eax
  8011fa:	e8 2c ff ff ff       	call   80112b <fd_lookup>
  8011ff:	89 c3                	mov    %eax,%ebx
  801201:	83 c4 10             	add    $0x10,%esp
  801204:	85 c0                	test   %eax,%eax
  801206:	78 05                	js     80120d <fd_close+0x34>
	    || fd != fd2)
  801208:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80120b:	74 16                	je     801223 <fd_close+0x4a>
		return (must_exist ? r : 0);
  80120d:	89 f8                	mov    %edi,%eax
  80120f:	84 c0                	test   %al,%al
  801211:	b8 00 00 00 00       	mov    $0x0,%eax
  801216:	0f 44 d8             	cmove  %eax,%ebx
}
  801219:	89 d8                	mov    %ebx,%eax
  80121b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80121e:	5b                   	pop    %ebx
  80121f:	5e                   	pop    %esi
  801220:	5f                   	pop    %edi
  801221:	5d                   	pop    %ebp
  801222:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801223:	83 ec 08             	sub    $0x8,%esp
  801226:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801229:	50                   	push   %eax
  80122a:	ff 36                	pushl  (%esi)
  80122c:	e8 4e ff ff ff       	call   80117f <dev_lookup>
  801231:	89 c3                	mov    %eax,%ebx
  801233:	83 c4 10             	add    $0x10,%esp
  801236:	85 c0                	test   %eax,%eax
  801238:	78 1a                	js     801254 <fd_close+0x7b>
		if (dev->dev_close)
  80123a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80123d:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801240:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801245:	85 c0                	test   %eax,%eax
  801247:	74 0b                	je     801254 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  801249:	83 ec 0c             	sub    $0xc,%esp
  80124c:	56                   	push   %esi
  80124d:	ff d0                	call   *%eax
  80124f:	89 c3                	mov    %eax,%ebx
  801251:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801254:	83 ec 08             	sub    $0x8,%esp
  801257:	56                   	push   %esi
  801258:	6a 00                	push   $0x0
  80125a:	e8 77 fa ff ff       	call   800cd6 <sys_page_unmap>
	return r;
  80125f:	83 c4 10             	add    $0x10,%esp
  801262:	eb b5                	jmp    801219 <fd_close+0x40>

00801264 <close>:

int
close(int fdnum)
{
  801264:	f3 0f 1e fb          	endbr32 
  801268:	55                   	push   %ebp
  801269:	89 e5                	mov    %esp,%ebp
  80126b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80126e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801271:	50                   	push   %eax
  801272:	ff 75 08             	pushl  0x8(%ebp)
  801275:	e8 b1 fe ff ff       	call   80112b <fd_lookup>
  80127a:	83 c4 10             	add    $0x10,%esp
  80127d:	85 c0                	test   %eax,%eax
  80127f:	79 02                	jns    801283 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801281:	c9                   	leave  
  801282:	c3                   	ret    
		return fd_close(fd, 1);
  801283:	83 ec 08             	sub    $0x8,%esp
  801286:	6a 01                	push   $0x1
  801288:	ff 75 f4             	pushl  -0xc(%ebp)
  80128b:	e8 49 ff ff ff       	call   8011d9 <fd_close>
  801290:	83 c4 10             	add    $0x10,%esp
  801293:	eb ec                	jmp    801281 <close+0x1d>

00801295 <close_all>:

void
close_all(void)
{
  801295:	f3 0f 1e fb          	endbr32 
  801299:	55                   	push   %ebp
  80129a:	89 e5                	mov    %esp,%ebp
  80129c:	53                   	push   %ebx
  80129d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012a0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012a5:	83 ec 0c             	sub    $0xc,%esp
  8012a8:	53                   	push   %ebx
  8012a9:	e8 b6 ff ff ff       	call   801264 <close>
	for (i = 0; i < MAXFD; i++)
  8012ae:	83 c3 01             	add    $0x1,%ebx
  8012b1:	83 c4 10             	add    $0x10,%esp
  8012b4:	83 fb 20             	cmp    $0x20,%ebx
  8012b7:	75 ec                	jne    8012a5 <close_all+0x10>
}
  8012b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012bc:	c9                   	leave  
  8012bd:	c3                   	ret    

008012be <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012be:	f3 0f 1e fb          	endbr32 
  8012c2:	55                   	push   %ebp
  8012c3:	89 e5                	mov    %esp,%ebp
  8012c5:	57                   	push   %edi
  8012c6:	56                   	push   %esi
  8012c7:	53                   	push   %ebx
  8012c8:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012cb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012ce:	50                   	push   %eax
  8012cf:	ff 75 08             	pushl  0x8(%ebp)
  8012d2:	e8 54 fe ff ff       	call   80112b <fd_lookup>
  8012d7:	89 c3                	mov    %eax,%ebx
  8012d9:	83 c4 10             	add    $0x10,%esp
  8012dc:	85 c0                	test   %eax,%eax
  8012de:	0f 88 81 00 00 00    	js     801365 <dup+0xa7>
		return r;
	close(newfdnum);
  8012e4:	83 ec 0c             	sub    $0xc,%esp
  8012e7:	ff 75 0c             	pushl  0xc(%ebp)
  8012ea:	e8 75 ff ff ff       	call   801264 <close>

	newfd = INDEX2FD(newfdnum);
  8012ef:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012f2:	c1 e6 0c             	shl    $0xc,%esi
  8012f5:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8012fb:	83 c4 04             	add    $0x4,%esp
  8012fe:	ff 75 e4             	pushl  -0x1c(%ebp)
  801301:	e8 b4 fd ff ff       	call   8010ba <fd2data>
  801306:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801308:	89 34 24             	mov    %esi,(%esp)
  80130b:	e8 aa fd ff ff       	call   8010ba <fd2data>
  801310:	83 c4 10             	add    $0x10,%esp
  801313:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801315:	89 d8                	mov    %ebx,%eax
  801317:	c1 e8 16             	shr    $0x16,%eax
  80131a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801321:	a8 01                	test   $0x1,%al
  801323:	74 11                	je     801336 <dup+0x78>
  801325:	89 d8                	mov    %ebx,%eax
  801327:	c1 e8 0c             	shr    $0xc,%eax
  80132a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801331:	f6 c2 01             	test   $0x1,%dl
  801334:	75 39                	jne    80136f <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801336:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801339:	89 d0                	mov    %edx,%eax
  80133b:	c1 e8 0c             	shr    $0xc,%eax
  80133e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801345:	83 ec 0c             	sub    $0xc,%esp
  801348:	25 07 0e 00 00       	and    $0xe07,%eax
  80134d:	50                   	push   %eax
  80134e:	56                   	push   %esi
  80134f:	6a 00                	push   $0x0
  801351:	52                   	push   %edx
  801352:	6a 00                	push   $0x0
  801354:	e8 37 f9 ff ff       	call   800c90 <sys_page_map>
  801359:	89 c3                	mov    %eax,%ebx
  80135b:	83 c4 20             	add    $0x20,%esp
  80135e:	85 c0                	test   %eax,%eax
  801360:	78 31                	js     801393 <dup+0xd5>
		goto err;

	return newfdnum;
  801362:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801365:	89 d8                	mov    %ebx,%eax
  801367:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80136a:	5b                   	pop    %ebx
  80136b:	5e                   	pop    %esi
  80136c:	5f                   	pop    %edi
  80136d:	5d                   	pop    %ebp
  80136e:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80136f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801376:	83 ec 0c             	sub    $0xc,%esp
  801379:	25 07 0e 00 00       	and    $0xe07,%eax
  80137e:	50                   	push   %eax
  80137f:	57                   	push   %edi
  801380:	6a 00                	push   $0x0
  801382:	53                   	push   %ebx
  801383:	6a 00                	push   $0x0
  801385:	e8 06 f9 ff ff       	call   800c90 <sys_page_map>
  80138a:	89 c3                	mov    %eax,%ebx
  80138c:	83 c4 20             	add    $0x20,%esp
  80138f:	85 c0                	test   %eax,%eax
  801391:	79 a3                	jns    801336 <dup+0x78>
	sys_page_unmap(0, newfd);
  801393:	83 ec 08             	sub    $0x8,%esp
  801396:	56                   	push   %esi
  801397:	6a 00                	push   $0x0
  801399:	e8 38 f9 ff ff       	call   800cd6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80139e:	83 c4 08             	add    $0x8,%esp
  8013a1:	57                   	push   %edi
  8013a2:	6a 00                	push   $0x0
  8013a4:	e8 2d f9 ff ff       	call   800cd6 <sys_page_unmap>
	return r;
  8013a9:	83 c4 10             	add    $0x10,%esp
  8013ac:	eb b7                	jmp    801365 <dup+0xa7>

008013ae <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013ae:	f3 0f 1e fb          	endbr32 
  8013b2:	55                   	push   %ebp
  8013b3:	89 e5                	mov    %esp,%ebp
  8013b5:	53                   	push   %ebx
  8013b6:	83 ec 1c             	sub    $0x1c,%esp
  8013b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013bf:	50                   	push   %eax
  8013c0:	53                   	push   %ebx
  8013c1:	e8 65 fd ff ff       	call   80112b <fd_lookup>
  8013c6:	83 c4 10             	add    $0x10,%esp
  8013c9:	85 c0                	test   %eax,%eax
  8013cb:	78 3f                	js     80140c <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013cd:	83 ec 08             	sub    $0x8,%esp
  8013d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d3:	50                   	push   %eax
  8013d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d7:	ff 30                	pushl  (%eax)
  8013d9:	e8 a1 fd ff ff       	call   80117f <dev_lookup>
  8013de:	83 c4 10             	add    $0x10,%esp
  8013e1:	85 c0                	test   %eax,%eax
  8013e3:	78 27                	js     80140c <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013e5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013e8:	8b 42 08             	mov    0x8(%edx),%eax
  8013eb:	83 e0 03             	and    $0x3,%eax
  8013ee:	83 f8 01             	cmp    $0x1,%eax
  8013f1:	74 1e                	je     801411 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8013f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013f6:	8b 40 08             	mov    0x8(%eax),%eax
  8013f9:	85 c0                	test   %eax,%eax
  8013fb:	74 35                	je     801432 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013fd:	83 ec 04             	sub    $0x4,%esp
  801400:	ff 75 10             	pushl  0x10(%ebp)
  801403:	ff 75 0c             	pushl  0xc(%ebp)
  801406:	52                   	push   %edx
  801407:	ff d0                	call   *%eax
  801409:	83 c4 10             	add    $0x10,%esp
}
  80140c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80140f:	c9                   	leave  
  801410:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801411:	a1 04 40 80 00       	mov    0x804004,%eax
  801416:	8b 40 48             	mov    0x48(%eax),%eax
  801419:	83 ec 04             	sub    $0x4,%esp
  80141c:	53                   	push   %ebx
  80141d:	50                   	push   %eax
  80141e:	68 e5 26 80 00       	push   $0x8026e5
  801423:	e8 d6 ed ff ff       	call   8001fe <cprintf>
		return -E_INVAL;
  801428:	83 c4 10             	add    $0x10,%esp
  80142b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801430:	eb da                	jmp    80140c <read+0x5e>
		return -E_NOT_SUPP;
  801432:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801437:	eb d3                	jmp    80140c <read+0x5e>

00801439 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801439:	f3 0f 1e fb          	endbr32 
  80143d:	55                   	push   %ebp
  80143e:	89 e5                	mov    %esp,%ebp
  801440:	57                   	push   %edi
  801441:	56                   	push   %esi
  801442:	53                   	push   %ebx
  801443:	83 ec 0c             	sub    $0xc,%esp
  801446:	8b 7d 08             	mov    0x8(%ebp),%edi
  801449:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80144c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801451:	eb 02                	jmp    801455 <readn+0x1c>
  801453:	01 c3                	add    %eax,%ebx
  801455:	39 f3                	cmp    %esi,%ebx
  801457:	73 21                	jae    80147a <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801459:	83 ec 04             	sub    $0x4,%esp
  80145c:	89 f0                	mov    %esi,%eax
  80145e:	29 d8                	sub    %ebx,%eax
  801460:	50                   	push   %eax
  801461:	89 d8                	mov    %ebx,%eax
  801463:	03 45 0c             	add    0xc(%ebp),%eax
  801466:	50                   	push   %eax
  801467:	57                   	push   %edi
  801468:	e8 41 ff ff ff       	call   8013ae <read>
		if (m < 0)
  80146d:	83 c4 10             	add    $0x10,%esp
  801470:	85 c0                	test   %eax,%eax
  801472:	78 04                	js     801478 <readn+0x3f>
			return m;
		if (m == 0)
  801474:	75 dd                	jne    801453 <readn+0x1a>
  801476:	eb 02                	jmp    80147a <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801478:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80147a:	89 d8                	mov    %ebx,%eax
  80147c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80147f:	5b                   	pop    %ebx
  801480:	5e                   	pop    %esi
  801481:	5f                   	pop    %edi
  801482:	5d                   	pop    %ebp
  801483:	c3                   	ret    

00801484 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801484:	f3 0f 1e fb          	endbr32 
  801488:	55                   	push   %ebp
  801489:	89 e5                	mov    %esp,%ebp
  80148b:	53                   	push   %ebx
  80148c:	83 ec 1c             	sub    $0x1c,%esp
  80148f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801492:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801495:	50                   	push   %eax
  801496:	53                   	push   %ebx
  801497:	e8 8f fc ff ff       	call   80112b <fd_lookup>
  80149c:	83 c4 10             	add    $0x10,%esp
  80149f:	85 c0                	test   %eax,%eax
  8014a1:	78 3a                	js     8014dd <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a3:	83 ec 08             	sub    $0x8,%esp
  8014a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a9:	50                   	push   %eax
  8014aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ad:	ff 30                	pushl  (%eax)
  8014af:	e8 cb fc ff ff       	call   80117f <dev_lookup>
  8014b4:	83 c4 10             	add    $0x10,%esp
  8014b7:	85 c0                	test   %eax,%eax
  8014b9:	78 22                	js     8014dd <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014be:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014c2:	74 1e                	je     8014e2 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014c7:	8b 52 0c             	mov    0xc(%edx),%edx
  8014ca:	85 d2                	test   %edx,%edx
  8014cc:	74 35                	je     801503 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014ce:	83 ec 04             	sub    $0x4,%esp
  8014d1:	ff 75 10             	pushl  0x10(%ebp)
  8014d4:	ff 75 0c             	pushl  0xc(%ebp)
  8014d7:	50                   	push   %eax
  8014d8:	ff d2                	call   *%edx
  8014da:	83 c4 10             	add    $0x10,%esp
}
  8014dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e0:	c9                   	leave  
  8014e1:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014e2:	a1 04 40 80 00       	mov    0x804004,%eax
  8014e7:	8b 40 48             	mov    0x48(%eax),%eax
  8014ea:	83 ec 04             	sub    $0x4,%esp
  8014ed:	53                   	push   %ebx
  8014ee:	50                   	push   %eax
  8014ef:	68 01 27 80 00       	push   $0x802701
  8014f4:	e8 05 ed ff ff       	call   8001fe <cprintf>
		return -E_INVAL;
  8014f9:	83 c4 10             	add    $0x10,%esp
  8014fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801501:	eb da                	jmp    8014dd <write+0x59>
		return -E_NOT_SUPP;
  801503:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801508:	eb d3                	jmp    8014dd <write+0x59>

0080150a <seek>:

int
seek(int fdnum, off_t offset)
{
  80150a:	f3 0f 1e fb          	endbr32 
  80150e:	55                   	push   %ebp
  80150f:	89 e5                	mov    %esp,%ebp
  801511:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801514:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801517:	50                   	push   %eax
  801518:	ff 75 08             	pushl  0x8(%ebp)
  80151b:	e8 0b fc ff ff       	call   80112b <fd_lookup>
  801520:	83 c4 10             	add    $0x10,%esp
  801523:	85 c0                	test   %eax,%eax
  801525:	78 0e                	js     801535 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801527:	8b 55 0c             	mov    0xc(%ebp),%edx
  80152a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80152d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801530:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801535:	c9                   	leave  
  801536:	c3                   	ret    

00801537 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801537:	f3 0f 1e fb          	endbr32 
  80153b:	55                   	push   %ebp
  80153c:	89 e5                	mov    %esp,%ebp
  80153e:	53                   	push   %ebx
  80153f:	83 ec 1c             	sub    $0x1c,%esp
  801542:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801545:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801548:	50                   	push   %eax
  801549:	53                   	push   %ebx
  80154a:	e8 dc fb ff ff       	call   80112b <fd_lookup>
  80154f:	83 c4 10             	add    $0x10,%esp
  801552:	85 c0                	test   %eax,%eax
  801554:	78 37                	js     80158d <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801556:	83 ec 08             	sub    $0x8,%esp
  801559:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155c:	50                   	push   %eax
  80155d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801560:	ff 30                	pushl  (%eax)
  801562:	e8 18 fc ff ff       	call   80117f <dev_lookup>
  801567:	83 c4 10             	add    $0x10,%esp
  80156a:	85 c0                	test   %eax,%eax
  80156c:	78 1f                	js     80158d <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80156e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801571:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801575:	74 1b                	je     801592 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801577:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80157a:	8b 52 18             	mov    0x18(%edx),%edx
  80157d:	85 d2                	test   %edx,%edx
  80157f:	74 32                	je     8015b3 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801581:	83 ec 08             	sub    $0x8,%esp
  801584:	ff 75 0c             	pushl  0xc(%ebp)
  801587:	50                   	push   %eax
  801588:	ff d2                	call   *%edx
  80158a:	83 c4 10             	add    $0x10,%esp
}
  80158d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801590:	c9                   	leave  
  801591:	c3                   	ret    
			thisenv->env_id, fdnum);
  801592:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801597:	8b 40 48             	mov    0x48(%eax),%eax
  80159a:	83 ec 04             	sub    $0x4,%esp
  80159d:	53                   	push   %ebx
  80159e:	50                   	push   %eax
  80159f:	68 c4 26 80 00       	push   $0x8026c4
  8015a4:	e8 55 ec ff ff       	call   8001fe <cprintf>
		return -E_INVAL;
  8015a9:	83 c4 10             	add    $0x10,%esp
  8015ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015b1:	eb da                	jmp    80158d <ftruncate+0x56>
		return -E_NOT_SUPP;
  8015b3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015b8:	eb d3                	jmp    80158d <ftruncate+0x56>

008015ba <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015ba:	f3 0f 1e fb          	endbr32 
  8015be:	55                   	push   %ebp
  8015bf:	89 e5                	mov    %esp,%ebp
  8015c1:	53                   	push   %ebx
  8015c2:	83 ec 1c             	sub    $0x1c,%esp
  8015c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015cb:	50                   	push   %eax
  8015cc:	ff 75 08             	pushl  0x8(%ebp)
  8015cf:	e8 57 fb ff ff       	call   80112b <fd_lookup>
  8015d4:	83 c4 10             	add    $0x10,%esp
  8015d7:	85 c0                	test   %eax,%eax
  8015d9:	78 4b                	js     801626 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015db:	83 ec 08             	sub    $0x8,%esp
  8015de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e1:	50                   	push   %eax
  8015e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e5:	ff 30                	pushl  (%eax)
  8015e7:	e8 93 fb ff ff       	call   80117f <dev_lookup>
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	85 c0                	test   %eax,%eax
  8015f1:	78 33                	js     801626 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8015f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015f6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015fa:	74 2f                	je     80162b <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015fc:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015ff:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801606:	00 00 00 
	stat->st_isdir = 0;
  801609:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801610:	00 00 00 
	stat->st_dev = dev;
  801613:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801619:	83 ec 08             	sub    $0x8,%esp
  80161c:	53                   	push   %ebx
  80161d:	ff 75 f0             	pushl  -0x10(%ebp)
  801620:	ff 50 14             	call   *0x14(%eax)
  801623:	83 c4 10             	add    $0x10,%esp
}
  801626:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801629:	c9                   	leave  
  80162a:	c3                   	ret    
		return -E_NOT_SUPP;
  80162b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801630:	eb f4                	jmp    801626 <fstat+0x6c>

00801632 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801632:	f3 0f 1e fb          	endbr32 
  801636:	55                   	push   %ebp
  801637:	89 e5                	mov    %esp,%ebp
  801639:	56                   	push   %esi
  80163a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80163b:	83 ec 08             	sub    $0x8,%esp
  80163e:	6a 00                	push   $0x0
  801640:	ff 75 08             	pushl  0x8(%ebp)
  801643:	e8 fb 01 00 00       	call   801843 <open>
  801648:	89 c3                	mov    %eax,%ebx
  80164a:	83 c4 10             	add    $0x10,%esp
  80164d:	85 c0                	test   %eax,%eax
  80164f:	78 1b                	js     80166c <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801651:	83 ec 08             	sub    $0x8,%esp
  801654:	ff 75 0c             	pushl  0xc(%ebp)
  801657:	50                   	push   %eax
  801658:	e8 5d ff ff ff       	call   8015ba <fstat>
  80165d:	89 c6                	mov    %eax,%esi
	close(fd);
  80165f:	89 1c 24             	mov    %ebx,(%esp)
  801662:	e8 fd fb ff ff       	call   801264 <close>
	return r;
  801667:	83 c4 10             	add    $0x10,%esp
  80166a:	89 f3                	mov    %esi,%ebx
}
  80166c:	89 d8                	mov    %ebx,%eax
  80166e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801671:	5b                   	pop    %ebx
  801672:	5e                   	pop    %esi
  801673:	5d                   	pop    %ebp
  801674:	c3                   	ret    

00801675 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801675:	55                   	push   %ebp
  801676:	89 e5                	mov    %esp,%ebp
  801678:	56                   	push   %esi
  801679:	53                   	push   %ebx
  80167a:	89 c6                	mov    %eax,%esi
  80167c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80167e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801685:	74 27                	je     8016ae <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801687:	6a 07                	push   $0x7
  801689:	68 00 50 80 00       	push   $0x805000
  80168e:	56                   	push   %esi
  80168f:	ff 35 00 40 80 00    	pushl  0x804000
  801695:	e8 98 08 00 00       	call   801f32 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80169a:	83 c4 0c             	add    $0xc,%esp
  80169d:	6a 00                	push   $0x0
  80169f:	53                   	push   %ebx
  8016a0:	6a 00                	push   $0x0
  8016a2:	e8 34 08 00 00       	call   801edb <ipc_recv>
}
  8016a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016aa:	5b                   	pop    %ebx
  8016ab:	5e                   	pop    %esi
  8016ac:	5d                   	pop    %ebp
  8016ad:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016ae:	83 ec 0c             	sub    $0xc,%esp
  8016b1:	6a 01                	push   $0x1
  8016b3:	e8 e0 08 00 00       	call   801f98 <ipc_find_env>
  8016b8:	a3 00 40 80 00       	mov    %eax,0x804000
  8016bd:	83 c4 10             	add    $0x10,%esp
  8016c0:	eb c5                	jmp    801687 <fsipc+0x12>

008016c2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016c2:	f3 0f 1e fb          	endbr32 
  8016c6:	55                   	push   %ebp
  8016c7:	89 e5                	mov    %esp,%ebp
  8016c9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cf:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016da:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016df:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e4:	b8 02 00 00 00       	mov    $0x2,%eax
  8016e9:	e8 87 ff ff ff       	call   801675 <fsipc>
}
  8016ee:	c9                   	leave  
  8016ef:	c3                   	ret    

008016f0 <devfile_flush>:
{
  8016f0:	f3 0f 1e fb          	endbr32 
  8016f4:	55                   	push   %ebp
  8016f5:	89 e5                	mov    %esp,%ebp
  8016f7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fd:	8b 40 0c             	mov    0xc(%eax),%eax
  801700:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801705:	ba 00 00 00 00       	mov    $0x0,%edx
  80170a:	b8 06 00 00 00       	mov    $0x6,%eax
  80170f:	e8 61 ff ff ff       	call   801675 <fsipc>
}
  801714:	c9                   	leave  
  801715:	c3                   	ret    

00801716 <devfile_stat>:
{
  801716:	f3 0f 1e fb          	endbr32 
  80171a:	55                   	push   %ebp
  80171b:	89 e5                	mov    %esp,%ebp
  80171d:	53                   	push   %ebx
  80171e:	83 ec 04             	sub    $0x4,%esp
  801721:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801724:	8b 45 08             	mov    0x8(%ebp),%eax
  801727:	8b 40 0c             	mov    0xc(%eax),%eax
  80172a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80172f:	ba 00 00 00 00       	mov    $0x0,%edx
  801734:	b8 05 00 00 00       	mov    $0x5,%eax
  801739:	e8 37 ff ff ff       	call   801675 <fsipc>
  80173e:	85 c0                	test   %eax,%eax
  801740:	78 2c                	js     80176e <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801742:	83 ec 08             	sub    $0x8,%esp
  801745:	68 00 50 80 00       	push   $0x805000
  80174a:	53                   	push   %ebx
  80174b:	e8 b7 f0 ff ff       	call   800807 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801750:	a1 80 50 80 00       	mov    0x805080,%eax
  801755:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80175b:	a1 84 50 80 00       	mov    0x805084,%eax
  801760:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801766:	83 c4 10             	add    $0x10,%esp
  801769:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80176e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801771:	c9                   	leave  
  801772:	c3                   	ret    

00801773 <devfile_write>:
{
  801773:	f3 0f 1e fb          	endbr32 
  801777:	55                   	push   %ebp
  801778:	89 e5                	mov    %esp,%ebp
  80177a:	83 ec 0c             	sub    $0xc,%esp
  80177d:	8b 45 10             	mov    0x10(%ebp),%eax
	n = n > size_max ? size_max : n;
  801780:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801785:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80178a:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80178d:	8b 55 08             	mov    0x8(%ebp),%edx
  801790:	8b 52 0c             	mov    0xc(%edx),%edx
  801793:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801799:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80179e:	50                   	push   %eax
  80179f:	ff 75 0c             	pushl  0xc(%ebp)
  8017a2:	68 08 50 80 00       	push   $0x805008
  8017a7:	e8 11 f2 ff ff       	call   8009bd <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8017ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b1:	b8 04 00 00 00       	mov    $0x4,%eax
  8017b6:	e8 ba fe ff ff       	call   801675 <fsipc>
}
  8017bb:	c9                   	leave  
  8017bc:	c3                   	ret    

008017bd <devfile_read>:
{
  8017bd:	f3 0f 1e fb          	endbr32 
  8017c1:	55                   	push   %ebp
  8017c2:	89 e5                	mov    %esp,%ebp
  8017c4:	56                   	push   %esi
  8017c5:	53                   	push   %ebx
  8017c6:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cc:	8b 40 0c             	mov    0xc(%eax),%eax
  8017cf:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017d4:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017da:	ba 00 00 00 00       	mov    $0x0,%edx
  8017df:	b8 03 00 00 00       	mov    $0x3,%eax
  8017e4:	e8 8c fe ff ff       	call   801675 <fsipc>
  8017e9:	89 c3                	mov    %eax,%ebx
  8017eb:	85 c0                	test   %eax,%eax
  8017ed:	78 1f                	js     80180e <devfile_read+0x51>
	assert(r <= n);
  8017ef:	39 f0                	cmp    %esi,%eax
  8017f1:	77 24                	ja     801817 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8017f3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017f8:	7f 33                	jg     80182d <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017fa:	83 ec 04             	sub    $0x4,%esp
  8017fd:	50                   	push   %eax
  8017fe:	68 00 50 80 00       	push   $0x805000
  801803:	ff 75 0c             	pushl  0xc(%ebp)
  801806:	e8 b2 f1 ff ff       	call   8009bd <memmove>
	return r;
  80180b:	83 c4 10             	add    $0x10,%esp
}
  80180e:	89 d8                	mov    %ebx,%eax
  801810:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801813:	5b                   	pop    %ebx
  801814:	5e                   	pop    %esi
  801815:	5d                   	pop    %ebp
  801816:	c3                   	ret    
	assert(r <= n);
  801817:	68 30 27 80 00       	push   $0x802730
  80181c:	68 37 27 80 00       	push   $0x802737
  801821:	6a 7c                	push   $0x7c
  801823:	68 4c 27 80 00       	push   $0x80274c
  801828:	e8 be 05 00 00       	call   801deb <_panic>
	assert(r <= PGSIZE);
  80182d:	68 57 27 80 00       	push   $0x802757
  801832:	68 37 27 80 00       	push   $0x802737
  801837:	6a 7d                	push   $0x7d
  801839:	68 4c 27 80 00       	push   $0x80274c
  80183e:	e8 a8 05 00 00       	call   801deb <_panic>

00801843 <open>:
{
  801843:	f3 0f 1e fb          	endbr32 
  801847:	55                   	push   %ebp
  801848:	89 e5                	mov    %esp,%ebp
  80184a:	56                   	push   %esi
  80184b:	53                   	push   %ebx
  80184c:	83 ec 1c             	sub    $0x1c,%esp
  80184f:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801852:	56                   	push   %esi
  801853:	e8 6c ef ff ff       	call   8007c4 <strlen>
  801858:	83 c4 10             	add    $0x10,%esp
  80185b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801860:	7f 6c                	jg     8018ce <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801862:	83 ec 0c             	sub    $0xc,%esp
  801865:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801868:	50                   	push   %eax
  801869:	e8 67 f8 ff ff       	call   8010d5 <fd_alloc>
  80186e:	89 c3                	mov    %eax,%ebx
  801870:	83 c4 10             	add    $0x10,%esp
  801873:	85 c0                	test   %eax,%eax
  801875:	78 3c                	js     8018b3 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801877:	83 ec 08             	sub    $0x8,%esp
  80187a:	56                   	push   %esi
  80187b:	68 00 50 80 00       	push   $0x805000
  801880:	e8 82 ef ff ff       	call   800807 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801885:	8b 45 0c             	mov    0xc(%ebp),%eax
  801888:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80188d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801890:	b8 01 00 00 00       	mov    $0x1,%eax
  801895:	e8 db fd ff ff       	call   801675 <fsipc>
  80189a:	89 c3                	mov    %eax,%ebx
  80189c:	83 c4 10             	add    $0x10,%esp
  80189f:	85 c0                	test   %eax,%eax
  8018a1:	78 19                	js     8018bc <open+0x79>
	return fd2num(fd);
  8018a3:	83 ec 0c             	sub    $0xc,%esp
  8018a6:	ff 75 f4             	pushl  -0xc(%ebp)
  8018a9:	e8 f8 f7 ff ff       	call   8010a6 <fd2num>
  8018ae:	89 c3                	mov    %eax,%ebx
  8018b0:	83 c4 10             	add    $0x10,%esp
}
  8018b3:	89 d8                	mov    %ebx,%eax
  8018b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b8:	5b                   	pop    %ebx
  8018b9:	5e                   	pop    %esi
  8018ba:	5d                   	pop    %ebp
  8018bb:	c3                   	ret    
		fd_close(fd, 0);
  8018bc:	83 ec 08             	sub    $0x8,%esp
  8018bf:	6a 00                	push   $0x0
  8018c1:	ff 75 f4             	pushl  -0xc(%ebp)
  8018c4:	e8 10 f9 ff ff       	call   8011d9 <fd_close>
		return r;
  8018c9:	83 c4 10             	add    $0x10,%esp
  8018cc:	eb e5                	jmp    8018b3 <open+0x70>
		return -E_BAD_PATH;
  8018ce:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8018d3:	eb de                	jmp    8018b3 <open+0x70>

008018d5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018d5:	f3 0f 1e fb          	endbr32 
  8018d9:	55                   	push   %ebp
  8018da:	89 e5                	mov    %esp,%ebp
  8018dc:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018df:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e4:	b8 08 00 00 00       	mov    $0x8,%eax
  8018e9:	e8 87 fd ff ff       	call   801675 <fsipc>
}
  8018ee:	c9                   	leave  
  8018ef:	c3                   	ret    

008018f0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018f0:	f3 0f 1e fb          	endbr32 
  8018f4:	55                   	push   %ebp
  8018f5:	89 e5                	mov    %esp,%ebp
  8018f7:	56                   	push   %esi
  8018f8:	53                   	push   %ebx
  8018f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018fc:	83 ec 0c             	sub    $0xc,%esp
  8018ff:	ff 75 08             	pushl  0x8(%ebp)
  801902:	e8 b3 f7 ff ff       	call   8010ba <fd2data>
  801907:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801909:	83 c4 08             	add    $0x8,%esp
  80190c:	68 63 27 80 00       	push   $0x802763
  801911:	53                   	push   %ebx
  801912:	e8 f0 ee ff ff       	call   800807 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801917:	8b 46 04             	mov    0x4(%esi),%eax
  80191a:	2b 06                	sub    (%esi),%eax
  80191c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801922:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801929:	00 00 00 
	stat->st_dev = &devpipe;
  80192c:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801933:	30 80 00 
	return 0;
}
  801936:	b8 00 00 00 00       	mov    $0x0,%eax
  80193b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80193e:	5b                   	pop    %ebx
  80193f:	5e                   	pop    %esi
  801940:	5d                   	pop    %ebp
  801941:	c3                   	ret    

00801942 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801942:	f3 0f 1e fb          	endbr32 
  801946:	55                   	push   %ebp
  801947:	89 e5                	mov    %esp,%ebp
  801949:	53                   	push   %ebx
  80194a:	83 ec 0c             	sub    $0xc,%esp
  80194d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801950:	53                   	push   %ebx
  801951:	6a 00                	push   $0x0
  801953:	e8 7e f3 ff ff       	call   800cd6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801958:	89 1c 24             	mov    %ebx,(%esp)
  80195b:	e8 5a f7 ff ff       	call   8010ba <fd2data>
  801960:	83 c4 08             	add    $0x8,%esp
  801963:	50                   	push   %eax
  801964:	6a 00                	push   $0x0
  801966:	e8 6b f3 ff ff       	call   800cd6 <sys_page_unmap>
}
  80196b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80196e:	c9                   	leave  
  80196f:	c3                   	ret    

00801970 <_pipeisclosed>:
{
  801970:	55                   	push   %ebp
  801971:	89 e5                	mov    %esp,%ebp
  801973:	57                   	push   %edi
  801974:	56                   	push   %esi
  801975:	53                   	push   %ebx
  801976:	83 ec 1c             	sub    $0x1c,%esp
  801979:	89 c7                	mov    %eax,%edi
  80197b:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80197d:	a1 04 40 80 00       	mov    0x804004,%eax
  801982:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801985:	83 ec 0c             	sub    $0xc,%esp
  801988:	57                   	push   %edi
  801989:	e8 47 06 00 00       	call   801fd5 <pageref>
  80198e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801991:	89 34 24             	mov    %esi,(%esp)
  801994:	e8 3c 06 00 00       	call   801fd5 <pageref>
		nn = thisenv->env_runs;
  801999:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80199f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019a2:	83 c4 10             	add    $0x10,%esp
  8019a5:	39 cb                	cmp    %ecx,%ebx
  8019a7:	74 1b                	je     8019c4 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8019a9:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8019ac:	75 cf                	jne    80197d <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019ae:	8b 42 58             	mov    0x58(%edx),%eax
  8019b1:	6a 01                	push   $0x1
  8019b3:	50                   	push   %eax
  8019b4:	53                   	push   %ebx
  8019b5:	68 6a 27 80 00       	push   $0x80276a
  8019ba:	e8 3f e8 ff ff       	call   8001fe <cprintf>
  8019bf:	83 c4 10             	add    $0x10,%esp
  8019c2:	eb b9                	jmp    80197d <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8019c4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8019c7:	0f 94 c0             	sete   %al
  8019ca:	0f b6 c0             	movzbl %al,%eax
}
  8019cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019d0:	5b                   	pop    %ebx
  8019d1:	5e                   	pop    %esi
  8019d2:	5f                   	pop    %edi
  8019d3:	5d                   	pop    %ebp
  8019d4:	c3                   	ret    

008019d5 <devpipe_write>:
{
  8019d5:	f3 0f 1e fb          	endbr32 
  8019d9:	55                   	push   %ebp
  8019da:	89 e5                	mov    %esp,%ebp
  8019dc:	57                   	push   %edi
  8019dd:	56                   	push   %esi
  8019de:	53                   	push   %ebx
  8019df:	83 ec 28             	sub    $0x28,%esp
  8019e2:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8019e5:	56                   	push   %esi
  8019e6:	e8 cf f6 ff ff       	call   8010ba <fd2data>
  8019eb:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8019ed:	83 c4 10             	add    $0x10,%esp
  8019f0:	bf 00 00 00 00       	mov    $0x0,%edi
  8019f5:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019f8:	74 4f                	je     801a49 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019fa:	8b 43 04             	mov    0x4(%ebx),%eax
  8019fd:	8b 0b                	mov    (%ebx),%ecx
  8019ff:	8d 51 20             	lea    0x20(%ecx),%edx
  801a02:	39 d0                	cmp    %edx,%eax
  801a04:	72 14                	jb     801a1a <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801a06:	89 da                	mov    %ebx,%edx
  801a08:	89 f0                	mov    %esi,%eax
  801a0a:	e8 61 ff ff ff       	call   801970 <_pipeisclosed>
  801a0f:	85 c0                	test   %eax,%eax
  801a11:	75 3b                	jne    801a4e <devpipe_write+0x79>
			sys_yield();
  801a13:	e8 0e f2 ff ff       	call   800c26 <sys_yield>
  801a18:	eb e0                	jmp    8019fa <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a1d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a21:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a24:	89 c2                	mov    %eax,%edx
  801a26:	c1 fa 1f             	sar    $0x1f,%edx
  801a29:	89 d1                	mov    %edx,%ecx
  801a2b:	c1 e9 1b             	shr    $0x1b,%ecx
  801a2e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a31:	83 e2 1f             	and    $0x1f,%edx
  801a34:	29 ca                	sub    %ecx,%edx
  801a36:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a3a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a3e:	83 c0 01             	add    $0x1,%eax
  801a41:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801a44:	83 c7 01             	add    $0x1,%edi
  801a47:	eb ac                	jmp    8019f5 <devpipe_write+0x20>
	return i;
  801a49:	8b 45 10             	mov    0x10(%ebp),%eax
  801a4c:	eb 05                	jmp    801a53 <devpipe_write+0x7e>
				return 0;
  801a4e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a56:	5b                   	pop    %ebx
  801a57:	5e                   	pop    %esi
  801a58:	5f                   	pop    %edi
  801a59:	5d                   	pop    %ebp
  801a5a:	c3                   	ret    

00801a5b <devpipe_read>:
{
  801a5b:	f3 0f 1e fb          	endbr32 
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	57                   	push   %edi
  801a63:	56                   	push   %esi
  801a64:	53                   	push   %ebx
  801a65:	83 ec 18             	sub    $0x18,%esp
  801a68:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801a6b:	57                   	push   %edi
  801a6c:	e8 49 f6 ff ff       	call   8010ba <fd2data>
  801a71:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801a73:	83 c4 10             	add    $0x10,%esp
  801a76:	be 00 00 00 00       	mov    $0x0,%esi
  801a7b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a7e:	75 14                	jne    801a94 <devpipe_read+0x39>
	return i;
  801a80:	8b 45 10             	mov    0x10(%ebp),%eax
  801a83:	eb 02                	jmp    801a87 <devpipe_read+0x2c>
				return i;
  801a85:	89 f0                	mov    %esi,%eax
}
  801a87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a8a:	5b                   	pop    %ebx
  801a8b:	5e                   	pop    %esi
  801a8c:	5f                   	pop    %edi
  801a8d:	5d                   	pop    %ebp
  801a8e:	c3                   	ret    
			sys_yield();
  801a8f:	e8 92 f1 ff ff       	call   800c26 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801a94:	8b 03                	mov    (%ebx),%eax
  801a96:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a99:	75 18                	jne    801ab3 <devpipe_read+0x58>
			if (i > 0)
  801a9b:	85 f6                	test   %esi,%esi
  801a9d:	75 e6                	jne    801a85 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801a9f:	89 da                	mov    %ebx,%edx
  801aa1:	89 f8                	mov    %edi,%eax
  801aa3:	e8 c8 fe ff ff       	call   801970 <_pipeisclosed>
  801aa8:	85 c0                	test   %eax,%eax
  801aaa:	74 e3                	je     801a8f <devpipe_read+0x34>
				return 0;
  801aac:	b8 00 00 00 00       	mov    $0x0,%eax
  801ab1:	eb d4                	jmp    801a87 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ab3:	99                   	cltd   
  801ab4:	c1 ea 1b             	shr    $0x1b,%edx
  801ab7:	01 d0                	add    %edx,%eax
  801ab9:	83 e0 1f             	and    $0x1f,%eax
  801abc:	29 d0                	sub    %edx,%eax
  801abe:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801ac3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ac6:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801ac9:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801acc:	83 c6 01             	add    $0x1,%esi
  801acf:	eb aa                	jmp    801a7b <devpipe_read+0x20>

00801ad1 <pipe>:
{
  801ad1:	f3 0f 1e fb          	endbr32 
  801ad5:	55                   	push   %ebp
  801ad6:	89 e5                	mov    %esp,%ebp
  801ad8:	56                   	push   %esi
  801ad9:	53                   	push   %ebx
  801ada:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801add:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ae0:	50                   	push   %eax
  801ae1:	e8 ef f5 ff ff       	call   8010d5 <fd_alloc>
  801ae6:	89 c3                	mov    %eax,%ebx
  801ae8:	83 c4 10             	add    $0x10,%esp
  801aeb:	85 c0                	test   %eax,%eax
  801aed:	0f 88 23 01 00 00    	js     801c16 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801af3:	83 ec 04             	sub    $0x4,%esp
  801af6:	68 07 04 00 00       	push   $0x407
  801afb:	ff 75 f4             	pushl  -0xc(%ebp)
  801afe:	6a 00                	push   $0x0
  801b00:	e8 44 f1 ff ff       	call   800c49 <sys_page_alloc>
  801b05:	89 c3                	mov    %eax,%ebx
  801b07:	83 c4 10             	add    $0x10,%esp
  801b0a:	85 c0                	test   %eax,%eax
  801b0c:	0f 88 04 01 00 00    	js     801c16 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801b12:	83 ec 0c             	sub    $0xc,%esp
  801b15:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b18:	50                   	push   %eax
  801b19:	e8 b7 f5 ff ff       	call   8010d5 <fd_alloc>
  801b1e:	89 c3                	mov    %eax,%ebx
  801b20:	83 c4 10             	add    $0x10,%esp
  801b23:	85 c0                	test   %eax,%eax
  801b25:	0f 88 db 00 00 00    	js     801c06 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b2b:	83 ec 04             	sub    $0x4,%esp
  801b2e:	68 07 04 00 00       	push   $0x407
  801b33:	ff 75 f0             	pushl  -0x10(%ebp)
  801b36:	6a 00                	push   $0x0
  801b38:	e8 0c f1 ff ff       	call   800c49 <sys_page_alloc>
  801b3d:	89 c3                	mov    %eax,%ebx
  801b3f:	83 c4 10             	add    $0x10,%esp
  801b42:	85 c0                	test   %eax,%eax
  801b44:	0f 88 bc 00 00 00    	js     801c06 <pipe+0x135>
	va = fd2data(fd0);
  801b4a:	83 ec 0c             	sub    $0xc,%esp
  801b4d:	ff 75 f4             	pushl  -0xc(%ebp)
  801b50:	e8 65 f5 ff ff       	call   8010ba <fd2data>
  801b55:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b57:	83 c4 0c             	add    $0xc,%esp
  801b5a:	68 07 04 00 00       	push   $0x407
  801b5f:	50                   	push   %eax
  801b60:	6a 00                	push   $0x0
  801b62:	e8 e2 f0 ff ff       	call   800c49 <sys_page_alloc>
  801b67:	89 c3                	mov    %eax,%ebx
  801b69:	83 c4 10             	add    $0x10,%esp
  801b6c:	85 c0                	test   %eax,%eax
  801b6e:	0f 88 82 00 00 00    	js     801bf6 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b74:	83 ec 0c             	sub    $0xc,%esp
  801b77:	ff 75 f0             	pushl  -0x10(%ebp)
  801b7a:	e8 3b f5 ff ff       	call   8010ba <fd2data>
  801b7f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b86:	50                   	push   %eax
  801b87:	6a 00                	push   $0x0
  801b89:	56                   	push   %esi
  801b8a:	6a 00                	push   $0x0
  801b8c:	e8 ff f0 ff ff       	call   800c90 <sys_page_map>
  801b91:	89 c3                	mov    %eax,%ebx
  801b93:	83 c4 20             	add    $0x20,%esp
  801b96:	85 c0                	test   %eax,%eax
  801b98:	78 4e                	js     801be8 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801b9a:	a1 20 30 80 00       	mov    0x803020,%eax
  801b9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ba2:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801ba4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ba7:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801bae:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bb1:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801bb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bb6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801bbd:	83 ec 0c             	sub    $0xc,%esp
  801bc0:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc3:	e8 de f4 ff ff       	call   8010a6 <fd2num>
  801bc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bcb:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bcd:	83 c4 04             	add    $0x4,%esp
  801bd0:	ff 75 f0             	pushl  -0x10(%ebp)
  801bd3:	e8 ce f4 ff ff       	call   8010a6 <fd2num>
  801bd8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bdb:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801bde:	83 c4 10             	add    $0x10,%esp
  801be1:	bb 00 00 00 00       	mov    $0x0,%ebx
  801be6:	eb 2e                	jmp    801c16 <pipe+0x145>
	sys_page_unmap(0, va);
  801be8:	83 ec 08             	sub    $0x8,%esp
  801beb:	56                   	push   %esi
  801bec:	6a 00                	push   $0x0
  801bee:	e8 e3 f0 ff ff       	call   800cd6 <sys_page_unmap>
  801bf3:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801bf6:	83 ec 08             	sub    $0x8,%esp
  801bf9:	ff 75 f0             	pushl  -0x10(%ebp)
  801bfc:	6a 00                	push   $0x0
  801bfe:	e8 d3 f0 ff ff       	call   800cd6 <sys_page_unmap>
  801c03:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801c06:	83 ec 08             	sub    $0x8,%esp
  801c09:	ff 75 f4             	pushl  -0xc(%ebp)
  801c0c:	6a 00                	push   $0x0
  801c0e:	e8 c3 f0 ff ff       	call   800cd6 <sys_page_unmap>
  801c13:	83 c4 10             	add    $0x10,%esp
}
  801c16:	89 d8                	mov    %ebx,%eax
  801c18:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c1b:	5b                   	pop    %ebx
  801c1c:	5e                   	pop    %esi
  801c1d:	5d                   	pop    %ebp
  801c1e:	c3                   	ret    

00801c1f <pipeisclosed>:
{
  801c1f:	f3 0f 1e fb          	endbr32 
  801c23:	55                   	push   %ebp
  801c24:	89 e5                	mov    %esp,%ebp
  801c26:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c29:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c2c:	50                   	push   %eax
  801c2d:	ff 75 08             	pushl  0x8(%ebp)
  801c30:	e8 f6 f4 ff ff       	call   80112b <fd_lookup>
  801c35:	83 c4 10             	add    $0x10,%esp
  801c38:	85 c0                	test   %eax,%eax
  801c3a:	78 18                	js     801c54 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801c3c:	83 ec 0c             	sub    $0xc,%esp
  801c3f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c42:	e8 73 f4 ff ff       	call   8010ba <fd2data>
  801c47:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c4c:	e8 1f fd ff ff       	call   801970 <_pipeisclosed>
  801c51:	83 c4 10             	add    $0x10,%esp
}
  801c54:	c9                   	leave  
  801c55:	c3                   	ret    

00801c56 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c56:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801c5a:	b8 00 00 00 00       	mov    $0x0,%eax
  801c5f:	c3                   	ret    

00801c60 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c60:	f3 0f 1e fb          	endbr32 
  801c64:	55                   	push   %ebp
  801c65:	89 e5                	mov    %esp,%ebp
  801c67:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c6a:	68 82 27 80 00       	push   $0x802782
  801c6f:	ff 75 0c             	pushl  0xc(%ebp)
  801c72:	e8 90 eb ff ff       	call   800807 <strcpy>
	return 0;
}
  801c77:	b8 00 00 00 00       	mov    $0x0,%eax
  801c7c:	c9                   	leave  
  801c7d:	c3                   	ret    

00801c7e <devcons_write>:
{
  801c7e:	f3 0f 1e fb          	endbr32 
  801c82:	55                   	push   %ebp
  801c83:	89 e5                	mov    %esp,%ebp
  801c85:	57                   	push   %edi
  801c86:	56                   	push   %esi
  801c87:	53                   	push   %ebx
  801c88:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801c8e:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801c93:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801c99:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c9c:	73 31                	jae    801ccf <devcons_write+0x51>
		m = n - tot;
  801c9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ca1:	29 f3                	sub    %esi,%ebx
  801ca3:	83 fb 7f             	cmp    $0x7f,%ebx
  801ca6:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801cab:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801cae:	83 ec 04             	sub    $0x4,%esp
  801cb1:	53                   	push   %ebx
  801cb2:	89 f0                	mov    %esi,%eax
  801cb4:	03 45 0c             	add    0xc(%ebp),%eax
  801cb7:	50                   	push   %eax
  801cb8:	57                   	push   %edi
  801cb9:	e8 ff ec ff ff       	call   8009bd <memmove>
		sys_cputs(buf, m);
  801cbe:	83 c4 08             	add    $0x8,%esp
  801cc1:	53                   	push   %ebx
  801cc2:	57                   	push   %edi
  801cc3:	e8 b1 ee ff ff       	call   800b79 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801cc8:	01 de                	add    %ebx,%esi
  801cca:	83 c4 10             	add    $0x10,%esp
  801ccd:	eb ca                	jmp    801c99 <devcons_write+0x1b>
}
  801ccf:	89 f0                	mov    %esi,%eax
  801cd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cd4:	5b                   	pop    %ebx
  801cd5:	5e                   	pop    %esi
  801cd6:	5f                   	pop    %edi
  801cd7:	5d                   	pop    %ebp
  801cd8:	c3                   	ret    

00801cd9 <devcons_read>:
{
  801cd9:	f3 0f 1e fb          	endbr32 
  801cdd:	55                   	push   %ebp
  801cde:	89 e5                	mov    %esp,%ebp
  801ce0:	83 ec 08             	sub    $0x8,%esp
  801ce3:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801ce8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cec:	74 21                	je     801d0f <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801cee:	e8 a8 ee ff ff       	call   800b9b <sys_cgetc>
  801cf3:	85 c0                	test   %eax,%eax
  801cf5:	75 07                	jne    801cfe <devcons_read+0x25>
		sys_yield();
  801cf7:	e8 2a ef ff ff       	call   800c26 <sys_yield>
  801cfc:	eb f0                	jmp    801cee <devcons_read+0x15>
	if (c < 0)
  801cfe:	78 0f                	js     801d0f <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801d00:	83 f8 04             	cmp    $0x4,%eax
  801d03:	74 0c                	je     801d11 <devcons_read+0x38>
	*(char*)vbuf = c;
  801d05:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d08:	88 02                	mov    %al,(%edx)
	return 1;
  801d0a:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801d0f:	c9                   	leave  
  801d10:	c3                   	ret    
		return 0;
  801d11:	b8 00 00 00 00       	mov    $0x0,%eax
  801d16:	eb f7                	jmp    801d0f <devcons_read+0x36>

00801d18 <cputchar>:
{
  801d18:	f3 0f 1e fb          	endbr32 
  801d1c:	55                   	push   %ebp
  801d1d:	89 e5                	mov    %esp,%ebp
  801d1f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d22:	8b 45 08             	mov    0x8(%ebp),%eax
  801d25:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801d28:	6a 01                	push   $0x1
  801d2a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d2d:	50                   	push   %eax
  801d2e:	e8 46 ee ff ff       	call   800b79 <sys_cputs>
}
  801d33:	83 c4 10             	add    $0x10,%esp
  801d36:	c9                   	leave  
  801d37:	c3                   	ret    

00801d38 <getchar>:
{
  801d38:	f3 0f 1e fb          	endbr32 
  801d3c:	55                   	push   %ebp
  801d3d:	89 e5                	mov    %esp,%ebp
  801d3f:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801d42:	6a 01                	push   $0x1
  801d44:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d47:	50                   	push   %eax
  801d48:	6a 00                	push   $0x0
  801d4a:	e8 5f f6 ff ff       	call   8013ae <read>
	if (r < 0)
  801d4f:	83 c4 10             	add    $0x10,%esp
  801d52:	85 c0                	test   %eax,%eax
  801d54:	78 06                	js     801d5c <getchar+0x24>
	if (r < 1)
  801d56:	74 06                	je     801d5e <getchar+0x26>
	return c;
  801d58:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801d5c:	c9                   	leave  
  801d5d:	c3                   	ret    
		return -E_EOF;
  801d5e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801d63:	eb f7                	jmp    801d5c <getchar+0x24>

00801d65 <iscons>:
{
  801d65:	f3 0f 1e fb          	endbr32 
  801d69:	55                   	push   %ebp
  801d6a:	89 e5                	mov    %esp,%ebp
  801d6c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d6f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d72:	50                   	push   %eax
  801d73:	ff 75 08             	pushl  0x8(%ebp)
  801d76:	e8 b0 f3 ff ff       	call   80112b <fd_lookup>
  801d7b:	83 c4 10             	add    $0x10,%esp
  801d7e:	85 c0                	test   %eax,%eax
  801d80:	78 11                	js     801d93 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801d82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d85:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d8b:	39 10                	cmp    %edx,(%eax)
  801d8d:	0f 94 c0             	sete   %al
  801d90:	0f b6 c0             	movzbl %al,%eax
}
  801d93:	c9                   	leave  
  801d94:	c3                   	ret    

00801d95 <opencons>:
{
  801d95:	f3 0f 1e fb          	endbr32 
  801d99:	55                   	push   %ebp
  801d9a:	89 e5                	mov    %esp,%ebp
  801d9c:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801d9f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801da2:	50                   	push   %eax
  801da3:	e8 2d f3 ff ff       	call   8010d5 <fd_alloc>
  801da8:	83 c4 10             	add    $0x10,%esp
  801dab:	85 c0                	test   %eax,%eax
  801dad:	78 3a                	js     801de9 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801daf:	83 ec 04             	sub    $0x4,%esp
  801db2:	68 07 04 00 00       	push   $0x407
  801db7:	ff 75 f4             	pushl  -0xc(%ebp)
  801dba:	6a 00                	push   $0x0
  801dbc:	e8 88 ee ff ff       	call   800c49 <sys_page_alloc>
  801dc1:	83 c4 10             	add    $0x10,%esp
  801dc4:	85 c0                	test   %eax,%eax
  801dc6:	78 21                	js     801de9 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801dc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dcb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dd1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801dd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ddd:	83 ec 0c             	sub    $0xc,%esp
  801de0:	50                   	push   %eax
  801de1:	e8 c0 f2 ff ff       	call   8010a6 <fd2num>
  801de6:	83 c4 10             	add    $0x10,%esp
}
  801de9:	c9                   	leave  
  801dea:	c3                   	ret    

00801deb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801deb:	f3 0f 1e fb          	endbr32 
  801def:	55                   	push   %ebp
  801df0:	89 e5                	mov    %esp,%ebp
  801df2:	56                   	push   %esi
  801df3:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801df4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801df7:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801dfd:	e8 01 ee ff ff       	call   800c03 <sys_getenvid>
  801e02:	83 ec 0c             	sub    $0xc,%esp
  801e05:	ff 75 0c             	pushl  0xc(%ebp)
  801e08:	ff 75 08             	pushl  0x8(%ebp)
  801e0b:	56                   	push   %esi
  801e0c:	50                   	push   %eax
  801e0d:	68 90 27 80 00       	push   $0x802790
  801e12:	e8 e7 e3 ff ff       	call   8001fe <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e17:	83 c4 18             	add    $0x18,%esp
  801e1a:	53                   	push   %ebx
  801e1b:	ff 75 10             	pushl  0x10(%ebp)
  801e1e:	e8 86 e3 ff ff       	call   8001a9 <vcprintf>
	cprintf("\n");
  801e23:	c7 04 24 8f 22 80 00 	movl   $0x80228f,(%esp)
  801e2a:	e8 cf e3 ff ff       	call   8001fe <cprintf>
  801e2f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e32:	cc                   	int3   
  801e33:	eb fd                	jmp    801e32 <_panic+0x47>

00801e35 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e35:	f3 0f 1e fb          	endbr32 
  801e39:	55                   	push   %ebp
  801e3a:	89 e5                	mov    %esp,%ebp
  801e3c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e3f:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e46:	74 0a                	je     801e52 <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e48:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4b:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e50:	c9                   	leave  
  801e51:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  801e52:	83 ec 0c             	sub    $0xc,%esp
  801e55:	68 b3 27 80 00       	push   $0x8027b3
  801e5a:	e8 9f e3 ff ff       	call   8001fe <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  801e5f:	83 c4 0c             	add    $0xc,%esp
  801e62:	6a 07                	push   $0x7
  801e64:	68 00 f0 bf ee       	push   $0xeebff000
  801e69:	6a 00                	push   $0x0
  801e6b:	e8 d9 ed ff ff       	call   800c49 <sys_page_alloc>
  801e70:	83 c4 10             	add    $0x10,%esp
  801e73:	85 c0                	test   %eax,%eax
  801e75:	78 2a                	js     801ea1 <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  801e77:	83 ec 08             	sub    $0x8,%esp
  801e7a:	68 b5 1e 80 00       	push   $0x801eb5
  801e7f:	6a 00                	push   $0x0
  801e81:	e8 22 ef ff ff       	call   800da8 <sys_env_set_pgfault_upcall>
  801e86:	83 c4 10             	add    $0x10,%esp
  801e89:	85 c0                	test   %eax,%eax
  801e8b:	79 bb                	jns    801e48 <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  801e8d:	83 ec 04             	sub    $0x4,%esp
  801e90:	68 f0 27 80 00       	push   $0x8027f0
  801e95:	6a 25                	push   $0x25
  801e97:	68 e0 27 80 00       	push   $0x8027e0
  801e9c:	e8 4a ff ff ff       	call   801deb <_panic>
            panic("Allocation of UXSTACK failed!");
  801ea1:	83 ec 04             	sub    $0x4,%esp
  801ea4:	68 c2 27 80 00       	push   $0x8027c2
  801ea9:	6a 22                	push   $0x22
  801eab:	68 e0 27 80 00       	push   $0x8027e0
  801eb0:	e8 36 ff ff ff       	call   801deb <_panic>

00801eb5 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801eb5:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801eb6:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801ebb:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801ebd:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  801ec0:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  801ec4:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  801ec8:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  801ecb:	83 c4 08             	add    $0x8,%esp
    popa
  801ece:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

    add $0x4, %esp
  801ecf:	83 c4 04             	add    $0x4,%esp
    popf
  801ed2:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  801ed3:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  801ed6:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  801eda:	c3                   	ret    

00801edb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801edb:	f3 0f 1e fb          	endbr32 
  801edf:	55                   	push   %ebp
  801ee0:	89 e5                	mov    %esp,%ebp
  801ee2:	56                   	push   %esi
  801ee3:	53                   	push   %ebx
  801ee4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801ee7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eea:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801eed:	85 c0                	test   %eax,%eax
  801eef:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801ef4:	0f 44 c2             	cmove  %edx,%eax
  801ef7:	83 ec 0c             	sub    $0xc,%esp
  801efa:	50                   	push   %eax
  801efb:	e8 15 ef ff ff       	call   800e15 <sys_ipc_recv>
  801f00:	83 c4 10             	add    $0x10,%esp
  801f03:	85 c0                	test   %eax,%eax
  801f05:	78 24                	js     801f2b <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801f07:	85 f6                	test   %esi,%esi
  801f09:	74 0a                	je     801f15 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801f0b:	a1 04 40 80 00       	mov    0x804004,%eax
  801f10:	8b 40 78             	mov    0x78(%eax),%eax
  801f13:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801f15:	85 db                	test   %ebx,%ebx
  801f17:	74 0a                	je     801f23 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801f19:	a1 04 40 80 00       	mov    0x804004,%eax
  801f1e:	8b 40 74             	mov    0x74(%eax),%eax
  801f21:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801f23:	a1 04 40 80 00       	mov    0x804004,%eax
  801f28:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f2b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f2e:	5b                   	pop    %ebx
  801f2f:	5e                   	pop    %esi
  801f30:	5d                   	pop    %ebp
  801f31:	c3                   	ret    

00801f32 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f32:	f3 0f 1e fb          	endbr32 
  801f36:	55                   	push   %ebp
  801f37:	89 e5                	mov    %esp,%ebp
  801f39:	57                   	push   %edi
  801f3a:	56                   	push   %esi
  801f3b:	53                   	push   %ebx
  801f3c:	83 ec 1c             	sub    $0x1c,%esp
  801f3f:	8b 45 10             	mov    0x10(%ebp),%eax
  801f42:	85 c0                	test   %eax,%eax
  801f44:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801f49:	0f 45 d0             	cmovne %eax,%edx
  801f4c:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801f4e:	be 01 00 00 00       	mov    $0x1,%esi
  801f53:	eb 1f                	jmp    801f74 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801f55:	e8 cc ec ff ff       	call   800c26 <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801f5a:	83 c3 01             	add    $0x1,%ebx
  801f5d:	39 de                	cmp    %ebx,%esi
  801f5f:	7f f4                	jg     801f55 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801f61:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801f63:	83 fe 11             	cmp    $0x11,%esi
  801f66:	b8 01 00 00 00       	mov    $0x1,%eax
  801f6b:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801f6e:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801f72:	75 1c                	jne    801f90 <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801f74:	ff 75 14             	pushl  0x14(%ebp)
  801f77:	57                   	push   %edi
  801f78:	ff 75 0c             	pushl  0xc(%ebp)
  801f7b:	ff 75 08             	pushl  0x8(%ebp)
  801f7e:	e8 6b ee ff ff       	call   800dee <sys_ipc_try_send>
  801f83:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801f86:	83 c4 10             	add    $0x10,%esp
  801f89:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f8e:	eb cd                	jmp    801f5d <ipc_send+0x2b>
}
  801f90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f93:	5b                   	pop    %ebx
  801f94:	5e                   	pop    %esi
  801f95:	5f                   	pop    %edi
  801f96:	5d                   	pop    %ebp
  801f97:	c3                   	ret    

00801f98 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f98:	f3 0f 1e fb          	endbr32 
  801f9c:	55                   	push   %ebp
  801f9d:	89 e5                	mov    %esp,%ebp
  801f9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fa2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fa7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801faa:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fb0:	8b 52 50             	mov    0x50(%edx),%edx
  801fb3:	39 ca                	cmp    %ecx,%edx
  801fb5:	74 11                	je     801fc8 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801fb7:	83 c0 01             	add    $0x1,%eax
  801fba:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fbf:	75 e6                	jne    801fa7 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801fc1:	b8 00 00 00 00       	mov    $0x0,%eax
  801fc6:	eb 0b                	jmp    801fd3 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801fc8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fcb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fd0:	8b 40 48             	mov    0x48(%eax),%eax
}
  801fd3:	5d                   	pop    %ebp
  801fd4:	c3                   	ret    

00801fd5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fd5:	f3 0f 1e fb          	endbr32 
  801fd9:	55                   	push   %ebp
  801fda:	89 e5                	mov    %esp,%ebp
  801fdc:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fdf:	89 c2                	mov    %eax,%edx
  801fe1:	c1 ea 16             	shr    $0x16,%edx
  801fe4:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801feb:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801ff0:	f6 c1 01             	test   $0x1,%cl
  801ff3:	74 1c                	je     802011 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801ff5:	c1 e8 0c             	shr    $0xc,%eax
  801ff8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801fff:	a8 01                	test   $0x1,%al
  802001:	74 0e                	je     802011 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802003:	c1 e8 0c             	shr    $0xc,%eax
  802006:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80200d:	ef 
  80200e:	0f b7 d2             	movzwl %dx,%edx
}
  802011:	89 d0                	mov    %edx,%eax
  802013:	5d                   	pop    %ebp
  802014:	c3                   	ret    
  802015:	66 90                	xchg   %ax,%ax
  802017:	66 90                	xchg   %ax,%ax
  802019:	66 90                	xchg   %ax,%ax
  80201b:	66 90                	xchg   %ax,%ax
  80201d:	66 90                	xchg   %ax,%ax
  80201f:	90                   	nop

00802020 <__udivdi3>:
  802020:	f3 0f 1e fb          	endbr32 
  802024:	55                   	push   %ebp
  802025:	57                   	push   %edi
  802026:	56                   	push   %esi
  802027:	53                   	push   %ebx
  802028:	83 ec 1c             	sub    $0x1c,%esp
  80202b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80202f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802033:	8b 74 24 34          	mov    0x34(%esp),%esi
  802037:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80203b:	85 d2                	test   %edx,%edx
  80203d:	75 19                	jne    802058 <__udivdi3+0x38>
  80203f:	39 f3                	cmp    %esi,%ebx
  802041:	76 4d                	jbe    802090 <__udivdi3+0x70>
  802043:	31 ff                	xor    %edi,%edi
  802045:	89 e8                	mov    %ebp,%eax
  802047:	89 f2                	mov    %esi,%edx
  802049:	f7 f3                	div    %ebx
  80204b:	89 fa                	mov    %edi,%edx
  80204d:	83 c4 1c             	add    $0x1c,%esp
  802050:	5b                   	pop    %ebx
  802051:	5e                   	pop    %esi
  802052:	5f                   	pop    %edi
  802053:	5d                   	pop    %ebp
  802054:	c3                   	ret    
  802055:	8d 76 00             	lea    0x0(%esi),%esi
  802058:	39 f2                	cmp    %esi,%edx
  80205a:	76 14                	jbe    802070 <__udivdi3+0x50>
  80205c:	31 ff                	xor    %edi,%edi
  80205e:	31 c0                	xor    %eax,%eax
  802060:	89 fa                	mov    %edi,%edx
  802062:	83 c4 1c             	add    $0x1c,%esp
  802065:	5b                   	pop    %ebx
  802066:	5e                   	pop    %esi
  802067:	5f                   	pop    %edi
  802068:	5d                   	pop    %ebp
  802069:	c3                   	ret    
  80206a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802070:	0f bd fa             	bsr    %edx,%edi
  802073:	83 f7 1f             	xor    $0x1f,%edi
  802076:	75 48                	jne    8020c0 <__udivdi3+0xa0>
  802078:	39 f2                	cmp    %esi,%edx
  80207a:	72 06                	jb     802082 <__udivdi3+0x62>
  80207c:	31 c0                	xor    %eax,%eax
  80207e:	39 eb                	cmp    %ebp,%ebx
  802080:	77 de                	ja     802060 <__udivdi3+0x40>
  802082:	b8 01 00 00 00       	mov    $0x1,%eax
  802087:	eb d7                	jmp    802060 <__udivdi3+0x40>
  802089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802090:	89 d9                	mov    %ebx,%ecx
  802092:	85 db                	test   %ebx,%ebx
  802094:	75 0b                	jne    8020a1 <__udivdi3+0x81>
  802096:	b8 01 00 00 00       	mov    $0x1,%eax
  80209b:	31 d2                	xor    %edx,%edx
  80209d:	f7 f3                	div    %ebx
  80209f:	89 c1                	mov    %eax,%ecx
  8020a1:	31 d2                	xor    %edx,%edx
  8020a3:	89 f0                	mov    %esi,%eax
  8020a5:	f7 f1                	div    %ecx
  8020a7:	89 c6                	mov    %eax,%esi
  8020a9:	89 e8                	mov    %ebp,%eax
  8020ab:	89 f7                	mov    %esi,%edi
  8020ad:	f7 f1                	div    %ecx
  8020af:	89 fa                	mov    %edi,%edx
  8020b1:	83 c4 1c             	add    $0x1c,%esp
  8020b4:	5b                   	pop    %ebx
  8020b5:	5e                   	pop    %esi
  8020b6:	5f                   	pop    %edi
  8020b7:	5d                   	pop    %ebp
  8020b8:	c3                   	ret    
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	89 f9                	mov    %edi,%ecx
  8020c2:	b8 20 00 00 00       	mov    $0x20,%eax
  8020c7:	29 f8                	sub    %edi,%eax
  8020c9:	d3 e2                	shl    %cl,%edx
  8020cb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020cf:	89 c1                	mov    %eax,%ecx
  8020d1:	89 da                	mov    %ebx,%edx
  8020d3:	d3 ea                	shr    %cl,%edx
  8020d5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8020d9:	09 d1                	or     %edx,%ecx
  8020db:	89 f2                	mov    %esi,%edx
  8020dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020e1:	89 f9                	mov    %edi,%ecx
  8020e3:	d3 e3                	shl    %cl,%ebx
  8020e5:	89 c1                	mov    %eax,%ecx
  8020e7:	d3 ea                	shr    %cl,%edx
  8020e9:	89 f9                	mov    %edi,%ecx
  8020eb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8020ef:	89 eb                	mov    %ebp,%ebx
  8020f1:	d3 e6                	shl    %cl,%esi
  8020f3:	89 c1                	mov    %eax,%ecx
  8020f5:	d3 eb                	shr    %cl,%ebx
  8020f7:	09 de                	or     %ebx,%esi
  8020f9:	89 f0                	mov    %esi,%eax
  8020fb:	f7 74 24 08          	divl   0x8(%esp)
  8020ff:	89 d6                	mov    %edx,%esi
  802101:	89 c3                	mov    %eax,%ebx
  802103:	f7 64 24 0c          	mull   0xc(%esp)
  802107:	39 d6                	cmp    %edx,%esi
  802109:	72 15                	jb     802120 <__udivdi3+0x100>
  80210b:	89 f9                	mov    %edi,%ecx
  80210d:	d3 e5                	shl    %cl,%ebp
  80210f:	39 c5                	cmp    %eax,%ebp
  802111:	73 04                	jae    802117 <__udivdi3+0xf7>
  802113:	39 d6                	cmp    %edx,%esi
  802115:	74 09                	je     802120 <__udivdi3+0x100>
  802117:	89 d8                	mov    %ebx,%eax
  802119:	31 ff                	xor    %edi,%edi
  80211b:	e9 40 ff ff ff       	jmp    802060 <__udivdi3+0x40>
  802120:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802123:	31 ff                	xor    %edi,%edi
  802125:	e9 36 ff ff ff       	jmp    802060 <__udivdi3+0x40>
  80212a:	66 90                	xchg   %ax,%ax
  80212c:	66 90                	xchg   %ax,%ax
  80212e:	66 90                	xchg   %ax,%ax

00802130 <__umoddi3>:
  802130:	f3 0f 1e fb          	endbr32 
  802134:	55                   	push   %ebp
  802135:	57                   	push   %edi
  802136:	56                   	push   %esi
  802137:	53                   	push   %ebx
  802138:	83 ec 1c             	sub    $0x1c,%esp
  80213b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80213f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802143:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802147:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80214b:	85 c0                	test   %eax,%eax
  80214d:	75 19                	jne    802168 <__umoddi3+0x38>
  80214f:	39 df                	cmp    %ebx,%edi
  802151:	76 5d                	jbe    8021b0 <__umoddi3+0x80>
  802153:	89 f0                	mov    %esi,%eax
  802155:	89 da                	mov    %ebx,%edx
  802157:	f7 f7                	div    %edi
  802159:	89 d0                	mov    %edx,%eax
  80215b:	31 d2                	xor    %edx,%edx
  80215d:	83 c4 1c             	add    $0x1c,%esp
  802160:	5b                   	pop    %ebx
  802161:	5e                   	pop    %esi
  802162:	5f                   	pop    %edi
  802163:	5d                   	pop    %ebp
  802164:	c3                   	ret    
  802165:	8d 76 00             	lea    0x0(%esi),%esi
  802168:	89 f2                	mov    %esi,%edx
  80216a:	39 d8                	cmp    %ebx,%eax
  80216c:	76 12                	jbe    802180 <__umoddi3+0x50>
  80216e:	89 f0                	mov    %esi,%eax
  802170:	89 da                	mov    %ebx,%edx
  802172:	83 c4 1c             	add    $0x1c,%esp
  802175:	5b                   	pop    %ebx
  802176:	5e                   	pop    %esi
  802177:	5f                   	pop    %edi
  802178:	5d                   	pop    %ebp
  802179:	c3                   	ret    
  80217a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802180:	0f bd e8             	bsr    %eax,%ebp
  802183:	83 f5 1f             	xor    $0x1f,%ebp
  802186:	75 50                	jne    8021d8 <__umoddi3+0xa8>
  802188:	39 d8                	cmp    %ebx,%eax
  80218a:	0f 82 e0 00 00 00    	jb     802270 <__umoddi3+0x140>
  802190:	89 d9                	mov    %ebx,%ecx
  802192:	39 f7                	cmp    %esi,%edi
  802194:	0f 86 d6 00 00 00    	jbe    802270 <__umoddi3+0x140>
  80219a:	89 d0                	mov    %edx,%eax
  80219c:	89 ca                	mov    %ecx,%edx
  80219e:	83 c4 1c             	add    $0x1c,%esp
  8021a1:	5b                   	pop    %ebx
  8021a2:	5e                   	pop    %esi
  8021a3:	5f                   	pop    %edi
  8021a4:	5d                   	pop    %ebp
  8021a5:	c3                   	ret    
  8021a6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021ad:	8d 76 00             	lea    0x0(%esi),%esi
  8021b0:	89 fd                	mov    %edi,%ebp
  8021b2:	85 ff                	test   %edi,%edi
  8021b4:	75 0b                	jne    8021c1 <__umoddi3+0x91>
  8021b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021bb:	31 d2                	xor    %edx,%edx
  8021bd:	f7 f7                	div    %edi
  8021bf:	89 c5                	mov    %eax,%ebp
  8021c1:	89 d8                	mov    %ebx,%eax
  8021c3:	31 d2                	xor    %edx,%edx
  8021c5:	f7 f5                	div    %ebp
  8021c7:	89 f0                	mov    %esi,%eax
  8021c9:	f7 f5                	div    %ebp
  8021cb:	89 d0                	mov    %edx,%eax
  8021cd:	31 d2                	xor    %edx,%edx
  8021cf:	eb 8c                	jmp    80215d <__umoddi3+0x2d>
  8021d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d8:	89 e9                	mov    %ebp,%ecx
  8021da:	ba 20 00 00 00       	mov    $0x20,%edx
  8021df:	29 ea                	sub    %ebp,%edx
  8021e1:	d3 e0                	shl    %cl,%eax
  8021e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021e7:	89 d1                	mov    %edx,%ecx
  8021e9:	89 f8                	mov    %edi,%eax
  8021eb:	d3 e8                	shr    %cl,%eax
  8021ed:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8021f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021f5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021f9:	09 c1                	or     %eax,%ecx
  8021fb:	89 d8                	mov    %ebx,%eax
  8021fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802201:	89 e9                	mov    %ebp,%ecx
  802203:	d3 e7                	shl    %cl,%edi
  802205:	89 d1                	mov    %edx,%ecx
  802207:	d3 e8                	shr    %cl,%eax
  802209:	89 e9                	mov    %ebp,%ecx
  80220b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80220f:	d3 e3                	shl    %cl,%ebx
  802211:	89 c7                	mov    %eax,%edi
  802213:	89 d1                	mov    %edx,%ecx
  802215:	89 f0                	mov    %esi,%eax
  802217:	d3 e8                	shr    %cl,%eax
  802219:	89 e9                	mov    %ebp,%ecx
  80221b:	89 fa                	mov    %edi,%edx
  80221d:	d3 e6                	shl    %cl,%esi
  80221f:	09 d8                	or     %ebx,%eax
  802221:	f7 74 24 08          	divl   0x8(%esp)
  802225:	89 d1                	mov    %edx,%ecx
  802227:	89 f3                	mov    %esi,%ebx
  802229:	f7 64 24 0c          	mull   0xc(%esp)
  80222d:	89 c6                	mov    %eax,%esi
  80222f:	89 d7                	mov    %edx,%edi
  802231:	39 d1                	cmp    %edx,%ecx
  802233:	72 06                	jb     80223b <__umoddi3+0x10b>
  802235:	75 10                	jne    802247 <__umoddi3+0x117>
  802237:	39 c3                	cmp    %eax,%ebx
  802239:	73 0c                	jae    802247 <__umoddi3+0x117>
  80223b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80223f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802243:	89 d7                	mov    %edx,%edi
  802245:	89 c6                	mov    %eax,%esi
  802247:	89 ca                	mov    %ecx,%edx
  802249:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80224e:	29 f3                	sub    %esi,%ebx
  802250:	19 fa                	sbb    %edi,%edx
  802252:	89 d0                	mov    %edx,%eax
  802254:	d3 e0                	shl    %cl,%eax
  802256:	89 e9                	mov    %ebp,%ecx
  802258:	d3 eb                	shr    %cl,%ebx
  80225a:	d3 ea                	shr    %cl,%edx
  80225c:	09 d8                	or     %ebx,%eax
  80225e:	83 c4 1c             	add    $0x1c,%esp
  802261:	5b                   	pop    %ebx
  802262:	5e                   	pop    %esi
  802263:	5f                   	pop    %edi
  802264:	5d                   	pop    %ebp
  802265:	c3                   	ret    
  802266:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80226d:	8d 76 00             	lea    0x0(%esi),%esi
  802270:	29 fe                	sub    %edi,%esi
  802272:	19 c3                	sbb    %eax,%ebx
  802274:	89 f2                	mov    %esi,%edx
  802276:	89 d9                	mov    %ebx,%ecx
  802278:	e9 1d ff ff ff       	jmp    80219a <__umoddi3+0x6a>
