
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
  80004b:	68 40 22 80 00       	push   $0x802240
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
  8000a4:	68 51 22 80 00       	push   $0x802251
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
  8000e0:	68 50 22 80 00       	push   $0x802250
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
  80014d:	e8 38 11 00 00       	call   80128a <close_all>
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
  800264:	e8 77 1d 00 00       	call   801fe0 <__udivdi3>
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
  8002a2:	e8 49 1e 00 00       	call   8020f0 <__umoddi3>
  8002a7:	83 c4 14             	add    $0x14,%esp
  8002aa:	0f be 80 60 22 80 00 	movsbl 0x802260(%eax),%eax
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
  800351:	3e ff 24 85 a0 23 80 	notrack jmp *0x8023a0(,%eax,4)
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
  80041e:	8b 14 85 00 25 80 00 	mov    0x802500(,%eax,4),%edx
  800425:	85 d2                	test   %edx,%edx
  800427:	74 18                	je     800441 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800429:	52                   	push   %edx
  80042a:	68 32 27 80 00       	push   $0x802732
  80042f:	53                   	push   %ebx
  800430:	56                   	push   %esi
  800431:	e8 aa fe ff ff       	call   8002e0 <printfmt>
  800436:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800439:	89 7d 14             	mov    %edi,0x14(%ebp)
  80043c:	e9 22 02 00 00       	jmp    800663 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  800441:	50                   	push   %eax
  800442:	68 78 22 80 00       	push   $0x802278
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
  800469:	b8 71 22 80 00       	mov    $0x802271,%eax
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
  800bf2:	68 5f 25 80 00       	push   $0x80255f
  800bf7:	6a 23                	push   $0x23
  800bf9:	68 7c 25 80 00       	push   $0x80257c
  800bfe:	e8 b1 11 00 00       	call   801db4 <_panic>

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
  800c7f:	68 5f 25 80 00       	push   $0x80255f
  800c84:	6a 23                	push   $0x23
  800c86:	68 7c 25 80 00       	push   $0x80257c
  800c8b:	e8 24 11 00 00       	call   801db4 <_panic>

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
  800cc5:	68 5f 25 80 00       	push   $0x80255f
  800cca:	6a 23                	push   $0x23
  800ccc:	68 7c 25 80 00       	push   $0x80257c
  800cd1:	e8 de 10 00 00       	call   801db4 <_panic>

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
  800d0b:	68 5f 25 80 00       	push   $0x80255f
  800d10:	6a 23                	push   $0x23
  800d12:	68 7c 25 80 00       	push   $0x80257c
  800d17:	e8 98 10 00 00       	call   801db4 <_panic>

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
  800d51:	68 5f 25 80 00       	push   $0x80255f
  800d56:	6a 23                	push   $0x23
  800d58:	68 7c 25 80 00       	push   $0x80257c
  800d5d:	e8 52 10 00 00       	call   801db4 <_panic>

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
  800d97:	68 5f 25 80 00       	push   $0x80255f
  800d9c:	6a 23                	push   $0x23
  800d9e:	68 7c 25 80 00       	push   $0x80257c
  800da3:	e8 0c 10 00 00       	call   801db4 <_panic>

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
  800ddd:	68 5f 25 80 00       	push   $0x80255f
  800de2:	6a 23                	push   $0x23
  800de4:	68 7c 25 80 00       	push   $0x80257c
  800de9:	e8 c6 0f 00 00       	call   801db4 <_panic>

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
  800e49:	68 5f 25 80 00       	push   $0x80255f
  800e4e:	6a 23                	push   $0x23
  800e50:	68 7c 25 80 00       	push   $0x80257c
  800e55:	e8 5a 0f 00 00       	call   801db4 <_panic>

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
  800ee8:	68 8a 25 80 00       	push   $0x80258a
  800eed:	6a 1e                	push   $0x1e
  800eef:	68 a3 25 80 00       	push   $0x8025a3
  800ef4:	e8 bb 0e 00 00       	call   801db4 <_panic>
        panic("sys_page_alloc failed %e\n", r);
  800ef9:	50                   	push   %eax
  800efa:	68 ae 25 80 00       	push   $0x8025ae
  800eff:	6a 2a                	push   $0x2a
  800f01:	68 a3 25 80 00       	push   $0x8025a3
  800f06:	e8 a9 0e 00 00       	call   801db4 <_panic>
        panic("sys_page_map failed %e\n", r);
  800f0b:	50                   	push   %eax
  800f0c:	68 c8 25 80 00       	push   $0x8025c8
  800f11:	6a 2f                	push   $0x2f
  800f13:	68 a3 25 80 00       	push   $0x8025a3
  800f18:	e8 97 0e 00 00       	call   801db4 <_panic>
        panic("sys_page_unmap failed %e\n", r);
  800f1d:	50                   	push   %eax
  800f1e:	68 e0 25 80 00       	push   $0x8025e0
  800f23:	6a 32                	push   $0x32
  800f25:	68 a3 25 80 00       	push   $0x8025a3
  800f2a:	e8 85 0e 00 00       	call   801db4 <_panic>

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
  800f41:	e8 b8 0e 00 00       	call   801dfe <set_pgfault_handler>
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
  800f63:	75 4e                	jne    800fb3 <fork+0x84>
        envid_t my_envid = sys_getenvid();
  800f65:	e8 99 fc ff ff       	call   800c03 <sys_getenvid>
        thisenv = &envs[ENVX(my_envid)];
  800f6a:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f6f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f72:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f77:	a3 04 40 80 00       	mov    %eax,0x804004
        return 0;
  800f7c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f7f:	e9 f1 00 00 00       	jmp    801075 <fork+0x146>
        panic("fork, sys_exofork %e", envid);
  800f84:	50                   	push   %eax
  800f85:	68 fa 25 80 00       	push   $0x8025fa
  800f8a:	6a 7b                	push   $0x7b
  800f8c:	68 a3 25 80 00       	push   $0x8025a3
  800f91:	e8 1e 0e 00 00       	call   801db4 <_panic>
        panic("sys_page_map others failed %e\n", r);
  800f96:	50                   	push   %eax
  800f97:	68 44 26 80 00       	push   $0x802644
  800f9c:	6a 51                	push   $0x51
  800f9e:	68 a3 25 80 00       	push   $0x8025a3
  800fa3:	e8 0c 0e 00 00       	call   801db4 <_panic>
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800fa8:	83 c3 01             	add    $0x1,%ebx
  800fab:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  800fb1:	74 7c                	je     80102f <fork+0x100>
  800fb3:	89 de                	mov    %ebx,%esi
  800fb5:	c1 e6 0c             	shl    $0xc,%esi
            uintptr_t pgaddr = pn << PGSHIFT;
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800fb8:	89 f0                	mov    %esi,%eax
  800fba:	c1 e8 16             	shr    $0x16,%eax
  800fbd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fc4:	a8 01                	test   $0x1,%al
  800fc6:	74 e0                	je     800fa8 <fork+0x79>
                    (uvpt[pn] & PTE_P) ) {
  800fc8:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800fcf:	a8 01                	test   $0x1,%al
  800fd1:	74 d5                	je     800fa8 <fork+0x79>
    pte_t pte = uvpt[pn];
  800fd3:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
    if ( (pte & PTE_W) || (pte & PTE_COW) ) {
  800fda:	25 02 08 00 00       	and    $0x802,%eax
        perm |= PTE_COW;
  800fdf:	83 f8 01             	cmp    $0x1,%eax
  800fe2:	19 ff                	sbb    %edi,%edi
  800fe4:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  800fea:	81 c7 05 08 00 00    	add    $0x805,%edi
    if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0) {
  800ff0:	83 ec 0c             	sub    $0xc,%esp
  800ff3:	57                   	push   %edi
  800ff4:	56                   	push   %esi
  800ff5:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ff8:	56                   	push   %esi
  800ff9:	6a 00                	push   $0x0
  800ffb:	e8 90 fc ff ff       	call   800c90 <sys_page_map>
  801000:	83 c4 20             	add    $0x20,%esp
  801003:	85 c0                	test   %eax,%eax
  801005:	78 8f                	js     800f96 <fork+0x67>
        if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0) {
  801007:	83 ec 0c             	sub    $0xc,%esp
  80100a:	57                   	push   %edi
  80100b:	56                   	push   %esi
  80100c:	6a 00                	push   $0x0
  80100e:	56                   	push   %esi
  80100f:	6a 00                	push   $0x0
  801011:	e8 7a fc ff ff       	call   800c90 <sys_page_map>
  801016:	83 c4 20             	add    $0x20,%esp
  801019:	85 c0                	test   %eax,%eax
  80101b:	79 8b                	jns    800fa8 <fork+0x79>
            panic("sys_page_map mine failed %e\n", r);
  80101d:	50                   	push   %eax
  80101e:	68 0f 26 80 00       	push   $0x80260f
  801023:	6a 56                	push   $0x56
  801025:	68 a3 25 80 00       	push   $0x8025a3
  80102a:	e8 85 0d 00 00       	call   801db4 <_panic>
            }
        }

        int r;

        if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE),
  80102f:	83 ec 04             	sub    $0x4,%esp
  801032:	6a 07                	push   $0x7
  801034:	68 00 f0 bf ee       	push   $0xeebff000
  801039:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80103c:	57                   	push   %edi
  80103d:	e8 07 fc ff ff       	call   800c49 <sys_page_alloc>
  801042:	83 c4 10             	add    $0x10,%esp
  801045:	85 c0                	test   %eax,%eax
  801047:	78 2c                	js     801075 <fork+0x146>
                    PTE_U | PTE_W | PTE_P)) < 0) {
            return r;
        }

        if ((r = sys_env_set_pgfault_upcall(envid,
                        thisenv->env_pgfault_upcall)) < 0) {
  801049:	a1 04 40 80 00       	mov    0x804004,%eax
        if ((r = sys_env_set_pgfault_upcall(envid,
  80104e:	8b 40 64             	mov    0x64(%eax),%eax
  801051:	83 ec 08             	sub    $0x8,%esp
  801054:	50                   	push   %eax
  801055:	57                   	push   %edi
  801056:	e8 4d fd ff ff       	call   800da8 <sys_env_set_pgfault_upcall>
  80105b:	83 c4 10             	add    $0x10,%esp
  80105e:	85 c0                	test   %eax,%eax
  801060:	78 13                	js     801075 <fork+0x146>
            return r;
        }

        if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  801062:	83 ec 08             	sub    $0x8,%esp
  801065:	6a 02                	push   $0x2
  801067:	57                   	push   %edi
  801068:	e8 af fc ff ff       	call   800d1c <sys_env_set_status>
  80106d:	83 c4 10             	add    $0x10,%esp
            return r;
        }
        return envid;
  801070:	85 c0                	test   %eax,%eax
  801072:	0f 49 c7             	cmovns %edi,%eax
    }

}
  801075:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801078:	5b                   	pop    %ebx
  801079:	5e                   	pop    %esi
  80107a:	5f                   	pop    %edi
  80107b:	5d                   	pop    %ebp
  80107c:	c3                   	ret    

0080107d <sfork>:

// Challenge!
int
sfork(void)
{
  80107d:	f3 0f 1e fb          	endbr32 
  801081:	55                   	push   %ebp
  801082:	89 e5                	mov    %esp,%ebp
  801084:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801087:	68 2c 26 80 00       	push   $0x80262c
  80108c:	68 a5 00 00 00       	push   $0xa5
  801091:	68 a3 25 80 00       	push   $0x8025a3
  801096:	e8 19 0d 00 00       	call   801db4 <_panic>

0080109b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80109b:	f3 0f 1e fb          	endbr32 
  80109f:	55                   	push   %ebp
  8010a0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a5:	05 00 00 00 30       	add    $0x30000000,%eax
  8010aa:	c1 e8 0c             	shr    $0xc,%eax
}
  8010ad:	5d                   	pop    %ebp
  8010ae:	c3                   	ret    

008010af <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010af:	f3 0f 1e fb          	endbr32 
  8010b3:	55                   	push   %ebp
  8010b4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b9:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8010be:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010c3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010c8:	5d                   	pop    %ebp
  8010c9:	c3                   	ret    

008010ca <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010ca:	f3 0f 1e fb          	endbr32 
  8010ce:	55                   	push   %ebp
  8010cf:	89 e5                	mov    %esp,%ebp
  8010d1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010d6:	89 c2                	mov    %eax,%edx
  8010d8:	c1 ea 16             	shr    $0x16,%edx
  8010db:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010e2:	f6 c2 01             	test   $0x1,%dl
  8010e5:	74 2d                	je     801114 <fd_alloc+0x4a>
  8010e7:	89 c2                	mov    %eax,%edx
  8010e9:	c1 ea 0c             	shr    $0xc,%edx
  8010ec:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010f3:	f6 c2 01             	test   $0x1,%dl
  8010f6:	74 1c                	je     801114 <fd_alloc+0x4a>
  8010f8:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8010fd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801102:	75 d2                	jne    8010d6 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801104:	8b 45 08             	mov    0x8(%ebp),%eax
  801107:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80110d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801112:	eb 0a                	jmp    80111e <fd_alloc+0x54>
			*fd_store = fd;
  801114:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801117:	89 01                	mov    %eax,(%ecx)
			return 0;
  801119:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80111e:	5d                   	pop    %ebp
  80111f:	c3                   	ret    

00801120 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801120:	f3 0f 1e fb          	endbr32 
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
  801127:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80112a:	83 f8 1f             	cmp    $0x1f,%eax
  80112d:	77 30                	ja     80115f <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80112f:	c1 e0 0c             	shl    $0xc,%eax
  801132:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801137:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80113d:	f6 c2 01             	test   $0x1,%dl
  801140:	74 24                	je     801166 <fd_lookup+0x46>
  801142:	89 c2                	mov    %eax,%edx
  801144:	c1 ea 0c             	shr    $0xc,%edx
  801147:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80114e:	f6 c2 01             	test   $0x1,%dl
  801151:	74 1a                	je     80116d <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801153:	8b 55 0c             	mov    0xc(%ebp),%edx
  801156:	89 02                	mov    %eax,(%edx)
	return 0;
  801158:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80115d:	5d                   	pop    %ebp
  80115e:	c3                   	ret    
		return -E_INVAL;
  80115f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801164:	eb f7                	jmp    80115d <fd_lookup+0x3d>
		return -E_INVAL;
  801166:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80116b:	eb f0                	jmp    80115d <fd_lookup+0x3d>
  80116d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801172:	eb e9                	jmp    80115d <fd_lookup+0x3d>

00801174 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801174:	f3 0f 1e fb          	endbr32 
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
  80117b:	83 ec 08             	sub    $0x8,%esp
  80117e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801181:	ba e0 26 80 00       	mov    $0x8026e0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801186:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  80118b:	39 08                	cmp    %ecx,(%eax)
  80118d:	74 33                	je     8011c2 <dev_lookup+0x4e>
  80118f:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801192:	8b 02                	mov    (%edx),%eax
  801194:	85 c0                	test   %eax,%eax
  801196:	75 f3                	jne    80118b <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801198:	a1 04 40 80 00       	mov    0x804004,%eax
  80119d:	8b 40 48             	mov    0x48(%eax),%eax
  8011a0:	83 ec 04             	sub    $0x4,%esp
  8011a3:	51                   	push   %ecx
  8011a4:	50                   	push   %eax
  8011a5:	68 64 26 80 00       	push   $0x802664
  8011aa:	e8 4f f0 ff ff       	call   8001fe <cprintf>
	*dev = 0;
  8011af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011b2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011b8:	83 c4 10             	add    $0x10,%esp
  8011bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011c0:	c9                   	leave  
  8011c1:	c3                   	ret    
			*dev = devtab[i];
  8011c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011c5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8011cc:	eb f2                	jmp    8011c0 <dev_lookup+0x4c>

008011ce <fd_close>:
{
  8011ce:	f3 0f 1e fb          	endbr32 
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
  8011d5:	57                   	push   %edi
  8011d6:	56                   	push   %esi
  8011d7:	53                   	push   %ebx
  8011d8:	83 ec 24             	sub    $0x24,%esp
  8011db:	8b 75 08             	mov    0x8(%ebp),%esi
  8011de:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011e1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011e4:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011e5:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011eb:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011ee:	50                   	push   %eax
  8011ef:	e8 2c ff ff ff       	call   801120 <fd_lookup>
  8011f4:	89 c3                	mov    %eax,%ebx
  8011f6:	83 c4 10             	add    $0x10,%esp
  8011f9:	85 c0                	test   %eax,%eax
  8011fb:	78 05                	js     801202 <fd_close+0x34>
	    || fd != fd2)
  8011fd:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801200:	74 16                	je     801218 <fd_close+0x4a>
		return (must_exist ? r : 0);
  801202:	89 f8                	mov    %edi,%eax
  801204:	84 c0                	test   %al,%al
  801206:	b8 00 00 00 00       	mov    $0x0,%eax
  80120b:	0f 44 d8             	cmove  %eax,%ebx
}
  80120e:	89 d8                	mov    %ebx,%eax
  801210:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801213:	5b                   	pop    %ebx
  801214:	5e                   	pop    %esi
  801215:	5f                   	pop    %edi
  801216:	5d                   	pop    %ebp
  801217:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801218:	83 ec 08             	sub    $0x8,%esp
  80121b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80121e:	50                   	push   %eax
  80121f:	ff 36                	pushl  (%esi)
  801221:	e8 4e ff ff ff       	call   801174 <dev_lookup>
  801226:	89 c3                	mov    %eax,%ebx
  801228:	83 c4 10             	add    $0x10,%esp
  80122b:	85 c0                	test   %eax,%eax
  80122d:	78 1a                	js     801249 <fd_close+0x7b>
		if (dev->dev_close)
  80122f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801232:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801235:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80123a:	85 c0                	test   %eax,%eax
  80123c:	74 0b                	je     801249 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  80123e:	83 ec 0c             	sub    $0xc,%esp
  801241:	56                   	push   %esi
  801242:	ff d0                	call   *%eax
  801244:	89 c3                	mov    %eax,%ebx
  801246:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801249:	83 ec 08             	sub    $0x8,%esp
  80124c:	56                   	push   %esi
  80124d:	6a 00                	push   $0x0
  80124f:	e8 82 fa ff ff       	call   800cd6 <sys_page_unmap>
	return r;
  801254:	83 c4 10             	add    $0x10,%esp
  801257:	eb b5                	jmp    80120e <fd_close+0x40>

00801259 <close>:

int
close(int fdnum)
{
  801259:	f3 0f 1e fb          	endbr32 
  80125d:	55                   	push   %ebp
  80125e:	89 e5                	mov    %esp,%ebp
  801260:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801263:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801266:	50                   	push   %eax
  801267:	ff 75 08             	pushl  0x8(%ebp)
  80126a:	e8 b1 fe ff ff       	call   801120 <fd_lookup>
  80126f:	83 c4 10             	add    $0x10,%esp
  801272:	85 c0                	test   %eax,%eax
  801274:	79 02                	jns    801278 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801276:	c9                   	leave  
  801277:	c3                   	ret    
		return fd_close(fd, 1);
  801278:	83 ec 08             	sub    $0x8,%esp
  80127b:	6a 01                	push   $0x1
  80127d:	ff 75 f4             	pushl  -0xc(%ebp)
  801280:	e8 49 ff ff ff       	call   8011ce <fd_close>
  801285:	83 c4 10             	add    $0x10,%esp
  801288:	eb ec                	jmp    801276 <close+0x1d>

0080128a <close_all>:

void
close_all(void)
{
  80128a:	f3 0f 1e fb          	endbr32 
  80128e:	55                   	push   %ebp
  80128f:	89 e5                	mov    %esp,%ebp
  801291:	53                   	push   %ebx
  801292:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801295:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80129a:	83 ec 0c             	sub    $0xc,%esp
  80129d:	53                   	push   %ebx
  80129e:	e8 b6 ff ff ff       	call   801259 <close>
	for (i = 0; i < MAXFD; i++)
  8012a3:	83 c3 01             	add    $0x1,%ebx
  8012a6:	83 c4 10             	add    $0x10,%esp
  8012a9:	83 fb 20             	cmp    $0x20,%ebx
  8012ac:	75 ec                	jne    80129a <close_all+0x10>
}
  8012ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b1:	c9                   	leave  
  8012b2:	c3                   	ret    

008012b3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012b3:	f3 0f 1e fb          	endbr32 
  8012b7:	55                   	push   %ebp
  8012b8:	89 e5                	mov    %esp,%ebp
  8012ba:	57                   	push   %edi
  8012bb:	56                   	push   %esi
  8012bc:	53                   	push   %ebx
  8012bd:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012c0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012c3:	50                   	push   %eax
  8012c4:	ff 75 08             	pushl  0x8(%ebp)
  8012c7:	e8 54 fe ff ff       	call   801120 <fd_lookup>
  8012cc:	89 c3                	mov    %eax,%ebx
  8012ce:	83 c4 10             	add    $0x10,%esp
  8012d1:	85 c0                	test   %eax,%eax
  8012d3:	0f 88 81 00 00 00    	js     80135a <dup+0xa7>
		return r;
	close(newfdnum);
  8012d9:	83 ec 0c             	sub    $0xc,%esp
  8012dc:	ff 75 0c             	pushl  0xc(%ebp)
  8012df:	e8 75 ff ff ff       	call   801259 <close>

	newfd = INDEX2FD(newfdnum);
  8012e4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012e7:	c1 e6 0c             	shl    $0xc,%esi
  8012ea:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8012f0:	83 c4 04             	add    $0x4,%esp
  8012f3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012f6:	e8 b4 fd ff ff       	call   8010af <fd2data>
  8012fb:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8012fd:	89 34 24             	mov    %esi,(%esp)
  801300:	e8 aa fd ff ff       	call   8010af <fd2data>
  801305:	83 c4 10             	add    $0x10,%esp
  801308:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80130a:	89 d8                	mov    %ebx,%eax
  80130c:	c1 e8 16             	shr    $0x16,%eax
  80130f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801316:	a8 01                	test   $0x1,%al
  801318:	74 11                	je     80132b <dup+0x78>
  80131a:	89 d8                	mov    %ebx,%eax
  80131c:	c1 e8 0c             	shr    $0xc,%eax
  80131f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801326:	f6 c2 01             	test   $0x1,%dl
  801329:	75 39                	jne    801364 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80132b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80132e:	89 d0                	mov    %edx,%eax
  801330:	c1 e8 0c             	shr    $0xc,%eax
  801333:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80133a:	83 ec 0c             	sub    $0xc,%esp
  80133d:	25 07 0e 00 00       	and    $0xe07,%eax
  801342:	50                   	push   %eax
  801343:	56                   	push   %esi
  801344:	6a 00                	push   $0x0
  801346:	52                   	push   %edx
  801347:	6a 00                	push   $0x0
  801349:	e8 42 f9 ff ff       	call   800c90 <sys_page_map>
  80134e:	89 c3                	mov    %eax,%ebx
  801350:	83 c4 20             	add    $0x20,%esp
  801353:	85 c0                	test   %eax,%eax
  801355:	78 31                	js     801388 <dup+0xd5>
		goto err;

	return newfdnum;
  801357:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80135a:	89 d8                	mov    %ebx,%eax
  80135c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80135f:	5b                   	pop    %ebx
  801360:	5e                   	pop    %esi
  801361:	5f                   	pop    %edi
  801362:	5d                   	pop    %ebp
  801363:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801364:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80136b:	83 ec 0c             	sub    $0xc,%esp
  80136e:	25 07 0e 00 00       	and    $0xe07,%eax
  801373:	50                   	push   %eax
  801374:	57                   	push   %edi
  801375:	6a 00                	push   $0x0
  801377:	53                   	push   %ebx
  801378:	6a 00                	push   $0x0
  80137a:	e8 11 f9 ff ff       	call   800c90 <sys_page_map>
  80137f:	89 c3                	mov    %eax,%ebx
  801381:	83 c4 20             	add    $0x20,%esp
  801384:	85 c0                	test   %eax,%eax
  801386:	79 a3                	jns    80132b <dup+0x78>
	sys_page_unmap(0, newfd);
  801388:	83 ec 08             	sub    $0x8,%esp
  80138b:	56                   	push   %esi
  80138c:	6a 00                	push   $0x0
  80138e:	e8 43 f9 ff ff       	call   800cd6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801393:	83 c4 08             	add    $0x8,%esp
  801396:	57                   	push   %edi
  801397:	6a 00                	push   $0x0
  801399:	e8 38 f9 ff ff       	call   800cd6 <sys_page_unmap>
	return r;
  80139e:	83 c4 10             	add    $0x10,%esp
  8013a1:	eb b7                	jmp    80135a <dup+0xa7>

008013a3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013a3:	f3 0f 1e fb          	endbr32 
  8013a7:	55                   	push   %ebp
  8013a8:	89 e5                	mov    %esp,%ebp
  8013aa:	53                   	push   %ebx
  8013ab:	83 ec 1c             	sub    $0x1c,%esp
  8013ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b4:	50                   	push   %eax
  8013b5:	53                   	push   %ebx
  8013b6:	e8 65 fd ff ff       	call   801120 <fd_lookup>
  8013bb:	83 c4 10             	add    $0x10,%esp
  8013be:	85 c0                	test   %eax,%eax
  8013c0:	78 3f                	js     801401 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c2:	83 ec 08             	sub    $0x8,%esp
  8013c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c8:	50                   	push   %eax
  8013c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013cc:	ff 30                	pushl  (%eax)
  8013ce:	e8 a1 fd ff ff       	call   801174 <dev_lookup>
  8013d3:	83 c4 10             	add    $0x10,%esp
  8013d6:	85 c0                	test   %eax,%eax
  8013d8:	78 27                	js     801401 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013da:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013dd:	8b 42 08             	mov    0x8(%edx),%eax
  8013e0:	83 e0 03             	and    $0x3,%eax
  8013e3:	83 f8 01             	cmp    $0x1,%eax
  8013e6:	74 1e                	je     801406 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8013e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013eb:	8b 40 08             	mov    0x8(%eax),%eax
  8013ee:	85 c0                	test   %eax,%eax
  8013f0:	74 35                	je     801427 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013f2:	83 ec 04             	sub    $0x4,%esp
  8013f5:	ff 75 10             	pushl  0x10(%ebp)
  8013f8:	ff 75 0c             	pushl  0xc(%ebp)
  8013fb:	52                   	push   %edx
  8013fc:	ff d0                	call   *%eax
  8013fe:	83 c4 10             	add    $0x10,%esp
}
  801401:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801404:	c9                   	leave  
  801405:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801406:	a1 04 40 80 00       	mov    0x804004,%eax
  80140b:	8b 40 48             	mov    0x48(%eax),%eax
  80140e:	83 ec 04             	sub    $0x4,%esp
  801411:	53                   	push   %ebx
  801412:	50                   	push   %eax
  801413:	68 a5 26 80 00       	push   $0x8026a5
  801418:	e8 e1 ed ff ff       	call   8001fe <cprintf>
		return -E_INVAL;
  80141d:	83 c4 10             	add    $0x10,%esp
  801420:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801425:	eb da                	jmp    801401 <read+0x5e>
		return -E_NOT_SUPP;
  801427:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80142c:	eb d3                	jmp    801401 <read+0x5e>

0080142e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80142e:	f3 0f 1e fb          	endbr32 
  801432:	55                   	push   %ebp
  801433:	89 e5                	mov    %esp,%ebp
  801435:	57                   	push   %edi
  801436:	56                   	push   %esi
  801437:	53                   	push   %ebx
  801438:	83 ec 0c             	sub    $0xc,%esp
  80143b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80143e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801441:	bb 00 00 00 00       	mov    $0x0,%ebx
  801446:	eb 02                	jmp    80144a <readn+0x1c>
  801448:	01 c3                	add    %eax,%ebx
  80144a:	39 f3                	cmp    %esi,%ebx
  80144c:	73 21                	jae    80146f <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80144e:	83 ec 04             	sub    $0x4,%esp
  801451:	89 f0                	mov    %esi,%eax
  801453:	29 d8                	sub    %ebx,%eax
  801455:	50                   	push   %eax
  801456:	89 d8                	mov    %ebx,%eax
  801458:	03 45 0c             	add    0xc(%ebp),%eax
  80145b:	50                   	push   %eax
  80145c:	57                   	push   %edi
  80145d:	e8 41 ff ff ff       	call   8013a3 <read>
		if (m < 0)
  801462:	83 c4 10             	add    $0x10,%esp
  801465:	85 c0                	test   %eax,%eax
  801467:	78 04                	js     80146d <readn+0x3f>
			return m;
		if (m == 0)
  801469:	75 dd                	jne    801448 <readn+0x1a>
  80146b:	eb 02                	jmp    80146f <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80146d:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80146f:	89 d8                	mov    %ebx,%eax
  801471:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801474:	5b                   	pop    %ebx
  801475:	5e                   	pop    %esi
  801476:	5f                   	pop    %edi
  801477:	5d                   	pop    %ebp
  801478:	c3                   	ret    

00801479 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801479:	f3 0f 1e fb          	endbr32 
  80147d:	55                   	push   %ebp
  80147e:	89 e5                	mov    %esp,%ebp
  801480:	53                   	push   %ebx
  801481:	83 ec 1c             	sub    $0x1c,%esp
  801484:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801487:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80148a:	50                   	push   %eax
  80148b:	53                   	push   %ebx
  80148c:	e8 8f fc ff ff       	call   801120 <fd_lookup>
  801491:	83 c4 10             	add    $0x10,%esp
  801494:	85 c0                	test   %eax,%eax
  801496:	78 3a                	js     8014d2 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801498:	83 ec 08             	sub    $0x8,%esp
  80149b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80149e:	50                   	push   %eax
  80149f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a2:	ff 30                	pushl  (%eax)
  8014a4:	e8 cb fc ff ff       	call   801174 <dev_lookup>
  8014a9:	83 c4 10             	add    $0x10,%esp
  8014ac:	85 c0                	test   %eax,%eax
  8014ae:	78 22                	js     8014d2 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014b7:	74 1e                	je     8014d7 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014bc:	8b 52 0c             	mov    0xc(%edx),%edx
  8014bf:	85 d2                	test   %edx,%edx
  8014c1:	74 35                	je     8014f8 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014c3:	83 ec 04             	sub    $0x4,%esp
  8014c6:	ff 75 10             	pushl  0x10(%ebp)
  8014c9:	ff 75 0c             	pushl  0xc(%ebp)
  8014cc:	50                   	push   %eax
  8014cd:	ff d2                	call   *%edx
  8014cf:	83 c4 10             	add    $0x10,%esp
}
  8014d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014d5:	c9                   	leave  
  8014d6:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014d7:	a1 04 40 80 00       	mov    0x804004,%eax
  8014dc:	8b 40 48             	mov    0x48(%eax),%eax
  8014df:	83 ec 04             	sub    $0x4,%esp
  8014e2:	53                   	push   %ebx
  8014e3:	50                   	push   %eax
  8014e4:	68 c1 26 80 00       	push   $0x8026c1
  8014e9:	e8 10 ed ff ff       	call   8001fe <cprintf>
		return -E_INVAL;
  8014ee:	83 c4 10             	add    $0x10,%esp
  8014f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014f6:	eb da                	jmp    8014d2 <write+0x59>
		return -E_NOT_SUPP;
  8014f8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014fd:	eb d3                	jmp    8014d2 <write+0x59>

008014ff <seek>:

int
seek(int fdnum, off_t offset)
{
  8014ff:	f3 0f 1e fb          	endbr32 
  801503:	55                   	push   %ebp
  801504:	89 e5                	mov    %esp,%ebp
  801506:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801509:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80150c:	50                   	push   %eax
  80150d:	ff 75 08             	pushl  0x8(%ebp)
  801510:	e8 0b fc ff ff       	call   801120 <fd_lookup>
  801515:	83 c4 10             	add    $0x10,%esp
  801518:	85 c0                	test   %eax,%eax
  80151a:	78 0e                	js     80152a <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80151c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80151f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801522:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801525:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80152a:	c9                   	leave  
  80152b:	c3                   	ret    

0080152c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80152c:	f3 0f 1e fb          	endbr32 
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	53                   	push   %ebx
  801534:	83 ec 1c             	sub    $0x1c,%esp
  801537:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80153a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80153d:	50                   	push   %eax
  80153e:	53                   	push   %ebx
  80153f:	e8 dc fb ff ff       	call   801120 <fd_lookup>
  801544:	83 c4 10             	add    $0x10,%esp
  801547:	85 c0                	test   %eax,%eax
  801549:	78 37                	js     801582 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154b:	83 ec 08             	sub    $0x8,%esp
  80154e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801551:	50                   	push   %eax
  801552:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801555:	ff 30                	pushl  (%eax)
  801557:	e8 18 fc ff ff       	call   801174 <dev_lookup>
  80155c:	83 c4 10             	add    $0x10,%esp
  80155f:	85 c0                	test   %eax,%eax
  801561:	78 1f                	js     801582 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801563:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801566:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80156a:	74 1b                	je     801587 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80156c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80156f:	8b 52 18             	mov    0x18(%edx),%edx
  801572:	85 d2                	test   %edx,%edx
  801574:	74 32                	je     8015a8 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801576:	83 ec 08             	sub    $0x8,%esp
  801579:	ff 75 0c             	pushl  0xc(%ebp)
  80157c:	50                   	push   %eax
  80157d:	ff d2                	call   *%edx
  80157f:	83 c4 10             	add    $0x10,%esp
}
  801582:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801585:	c9                   	leave  
  801586:	c3                   	ret    
			thisenv->env_id, fdnum);
  801587:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80158c:	8b 40 48             	mov    0x48(%eax),%eax
  80158f:	83 ec 04             	sub    $0x4,%esp
  801592:	53                   	push   %ebx
  801593:	50                   	push   %eax
  801594:	68 84 26 80 00       	push   $0x802684
  801599:	e8 60 ec ff ff       	call   8001fe <cprintf>
		return -E_INVAL;
  80159e:	83 c4 10             	add    $0x10,%esp
  8015a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015a6:	eb da                	jmp    801582 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8015a8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015ad:	eb d3                	jmp    801582 <ftruncate+0x56>

008015af <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015af:	f3 0f 1e fb          	endbr32 
  8015b3:	55                   	push   %ebp
  8015b4:	89 e5                	mov    %esp,%ebp
  8015b6:	53                   	push   %ebx
  8015b7:	83 ec 1c             	sub    $0x1c,%esp
  8015ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c0:	50                   	push   %eax
  8015c1:	ff 75 08             	pushl  0x8(%ebp)
  8015c4:	e8 57 fb ff ff       	call   801120 <fd_lookup>
  8015c9:	83 c4 10             	add    $0x10,%esp
  8015cc:	85 c0                	test   %eax,%eax
  8015ce:	78 4b                	js     80161b <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d0:	83 ec 08             	sub    $0x8,%esp
  8015d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d6:	50                   	push   %eax
  8015d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015da:	ff 30                	pushl  (%eax)
  8015dc:	e8 93 fb ff ff       	call   801174 <dev_lookup>
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	78 33                	js     80161b <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8015e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015eb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015ef:	74 2f                	je     801620 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015f1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015f4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015fb:	00 00 00 
	stat->st_isdir = 0;
  8015fe:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801605:	00 00 00 
	stat->st_dev = dev;
  801608:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80160e:	83 ec 08             	sub    $0x8,%esp
  801611:	53                   	push   %ebx
  801612:	ff 75 f0             	pushl  -0x10(%ebp)
  801615:	ff 50 14             	call   *0x14(%eax)
  801618:	83 c4 10             	add    $0x10,%esp
}
  80161b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161e:	c9                   	leave  
  80161f:	c3                   	ret    
		return -E_NOT_SUPP;
  801620:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801625:	eb f4                	jmp    80161b <fstat+0x6c>

00801627 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801627:	f3 0f 1e fb          	endbr32 
  80162b:	55                   	push   %ebp
  80162c:	89 e5                	mov    %esp,%ebp
  80162e:	56                   	push   %esi
  80162f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801630:	83 ec 08             	sub    $0x8,%esp
  801633:	6a 00                	push   $0x0
  801635:	ff 75 08             	pushl  0x8(%ebp)
  801638:	e8 cf 01 00 00       	call   80180c <open>
  80163d:	89 c3                	mov    %eax,%ebx
  80163f:	83 c4 10             	add    $0x10,%esp
  801642:	85 c0                	test   %eax,%eax
  801644:	78 1b                	js     801661 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801646:	83 ec 08             	sub    $0x8,%esp
  801649:	ff 75 0c             	pushl  0xc(%ebp)
  80164c:	50                   	push   %eax
  80164d:	e8 5d ff ff ff       	call   8015af <fstat>
  801652:	89 c6                	mov    %eax,%esi
	close(fd);
  801654:	89 1c 24             	mov    %ebx,(%esp)
  801657:	e8 fd fb ff ff       	call   801259 <close>
	return r;
  80165c:	83 c4 10             	add    $0x10,%esp
  80165f:	89 f3                	mov    %esi,%ebx
}
  801661:	89 d8                	mov    %ebx,%eax
  801663:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801666:	5b                   	pop    %ebx
  801667:	5e                   	pop    %esi
  801668:	5d                   	pop    %ebp
  801669:	c3                   	ret    

0080166a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80166a:	55                   	push   %ebp
  80166b:	89 e5                	mov    %esp,%ebp
  80166d:	56                   	push   %esi
  80166e:	53                   	push   %ebx
  80166f:	89 c6                	mov    %eax,%esi
  801671:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801673:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80167a:	74 27                	je     8016a3 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80167c:	6a 07                	push   $0x7
  80167e:	68 00 50 80 00       	push   $0x805000
  801683:	56                   	push   %esi
  801684:	ff 35 00 40 80 00    	pushl  0x804000
  80168a:	e8 6c 08 00 00       	call   801efb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80168f:	83 c4 0c             	add    $0xc,%esp
  801692:	6a 00                	push   $0x0
  801694:	53                   	push   %ebx
  801695:	6a 00                	push   $0x0
  801697:	e8 08 08 00 00       	call   801ea4 <ipc_recv>
}
  80169c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80169f:	5b                   	pop    %ebx
  8016a0:	5e                   	pop    %esi
  8016a1:	5d                   	pop    %ebp
  8016a2:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016a3:	83 ec 0c             	sub    $0xc,%esp
  8016a6:	6a 01                	push   $0x1
  8016a8:	e8 b4 08 00 00       	call   801f61 <ipc_find_env>
  8016ad:	a3 00 40 80 00       	mov    %eax,0x804000
  8016b2:	83 c4 10             	add    $0x10,%esp
  8016b5:	eb c5                	jmp    80167c <fsipc+0x12>

008016b7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016b7:	f3 0f 1e fb          	endbr32 
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c4:	8b 40 0c             	mov    0xc(%eax),%eax
  8016c7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016cf:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d9:	b8 02 00 00 00       	mov    $0x2,%eax
  8016de:	e8 87 ff ff ff       	call   80166a <fsipc>
}
  8016e3:	c9                   	leave  
  8016e4:	c3                   	ret    

008016e5 <devfile_flush>:
{
  8016e5:	f3 0f 1e fb          	endbr32 
  8016e9:	55                   	push   %ebp
  8016ea:	89 e5                	mov    %esp,%ebp
  8016ec:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f2:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f5:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ff:	b8 06 00 00 00       	mov    $0x6,%eax
  801704:	e8 61 ff ff ff       	call   80166a <fsipc>
}
  801709:	c9                   	leave  
  80170a:	c3                   	ret    

0080170b <devfile_stat>:
{
  80170b:	f3 0f 1e fb          	endbr32 
  80170f:	55                   	push   %ebp
  801710:	89 e5                	mov    %esp,%ebp
  801712:	53                   	push   %ebx
  801713:	83 ec 04             	sub    $0x4,%esp
  801716:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801719:	8b 45 08             	mov    0x8(%ebp),%eax
  80171c:	8b 40 0c             	mov    0xc(%eax),%eax
  80171f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801724:	ba 00 00 00 00       	mov    $0x0,%edx
  801729:	b8 05 00 00 00       	mov    $0x5,%eax
  80172e:	e8 37 ff ff ff       	call   80166a <fsipc>
  801733:	85 c0                	test   %eax,%eax
  801735:	78 2c                	js     801763 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801737:	83 ec 08             	sub    $0x8,%esp
  80173a:	68 00 50 80 00       	push   $0x805000
  80173f:	53                   	push   %ebx
  801740:	e8 c2 f0 ff ff       	call   800807 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801745:	a1 80 50 80 00       	mov    0x805080,%eax
  80174a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801750:	a1 84 50 80 00       	mov    0x805084,%eax
  801755:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80175b:	83 c4 10             	add    $0x10,%esp
  80175e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801763:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801766:	c9                   	leave  
  801767:	c3                   	ret    

00801768 <devfile_write>:
{
  801768:	f3 0f 1e fb          	endbr32 
  80176c:	55                   	push   %ebp
  80176d:	89 e5                	mov    %esp,%ebp
  80176f:	83 ec 0c             	sub    $0xc,%esp
	panic("devfile_write not implemented");
  801772:	68 f0 26 80 00       	push   $0x8026f0
  801777:	68 90 00 00 00       	push   $0x90
  80177c:	68 0e 27 80 00       	push   $0x80270e
  801781:	e8 2e 06 00 00       	call   801db4 <_panic>

00801786 <devfile_read>:
{
  801786:	f3 0f 1e fb          	endbr32 
  80178a:	55                   	push   %ebp
  80178b:	89 e5                	mov    %esp,%ebp
  80178d:	56                   	push   %esi
  80178e:	53                   	push   %ebx
  80178f:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801792:	8b 45 08             	mov    0x8(%ebp),%eax
  801795:	8b 40 0c             	mov    0xc(%eax),%eax
  801798:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80179d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a8:	b8 03 00 00 00       	mov    $0x3,%eax
  8017ad:	e8 b8 fe ff ff       	call   80166a <fsipc>
  8017b2:	89 c3                	mov    %eax,%ebx
  8017b4:	85 c0                	test   %eax,%eax
  8017b6:	78 1f                	js     8017d7 <devfile_read+0x51>
	assert(r <= n);
  8017b8:	39 f0                	cmp    %esi,%eax
  8017ba:	77 24                	ja     8017e0 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8017bc:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017c1:	7f 33                	jg     8017f6 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017c3:	83 ec 04             	sub    $0x4,%esp
  8017c6:	50                   	push   %eax
  8017c7:	68 00 50 80 00       	push   $0x805000
  8017cc:	ff 75 0c             	pushl  0xc(%ebp)
  8017cf:	e8 e9 f1 ff ff       	call   8009bd <memmove>
	return r;
  8017d4:	83 c4 10             	add    $0x10,%esp
}
  8017d7:	89 d8                	mov    %ebx,%eax
  8017d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017dc:	5b                   	pop    %ebx
  8017dd:	5e                   	pop    %esi
  8017de:	5d                   	pop    %ebp
  8017df:	c3                   	ret    
	assert(r <= n);
  8017e0:	68 19 27 80 00       	push   $0x802719
  8017e5:	68 20 27 80 00       	push   $0x802720
  8017ea:	6a 7c                	push   $0x7c
  8017ec:	68 0e 27 80 00       	push   $0x80270e
  8017f1:	e8 be 05 00 00       	call   801db4 <_panic>
	assert(r <= PGSIZE);
  8017f6:	68 35 27 80 00       	push   $0x802735
  8017fb:	68 20 27 80 00       	push   $0x802720
  801800:	6a 7d                	push   $0x7d
  801802:	68 0e 27 80 00       	push   $0x80270e
  801807:	e8 a8 05 00 00       	call   801db4 <_panic>

0080180c <open>:
{
  80180c:	f3 0f 1e fb          	endbr32 
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	56                   	push   %esi
  801814:	53                   	push   %ebx
  801815:	83 ec 1c             	sub    $0x1c,%esp
  801818:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80181b:	56                   	push   %esi
  80181c:	e8 a3 ef ff ff       	call   8007c4 <strlen>
  801821:	83 c4 10             	add    $0x10,%esp
  801824:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801829:	7f 6c                	jg     801897 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  80182b:	83 ec 0c             	sub    $0xc,%esp
  80182e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801831:	50                   	push   %eax
  801832:	e8 93 f8 ff ff       	call   8010ca <fd_alloc>
  801837:	89 c3                	mov    %eax,%ebx
  801839:	83 c4 10             	add    $0x10,%esp
  80183c:	85 c0                	test   %eax,%eax
  80183e:	78 3c                	js     80187c <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801840:	83 ec 08             	sub    $0x8,%esp
  801843:	56                   	push   %esi
  801844:	68 00 50 80 00       	push   $0x805000
  801849:	e8 b9 ef ff ff       	call   800807 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80184e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801851:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801856:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801859:	b8 01 00 00 00       	mov    $0x1,%eax
  80185e:	e8 07 fe ff ff       	call   80166a <fsipc>
  801863:	89 c3                	mov    %eax,%ebx
  801865:	83 c4 10             	add    $0x10,%esp
  801868:	85 c0                	test   %eax,%eax
  80186a:	78 19                	js     801885 <open+0x79>
	return fd2num(fd);
  80186c:	83 ec 0c             	sub    $0xc,%esp
  80186f:	ff 75 f4             	pushl  -0xc(%ebp)
  801872:	e8 24 f8 ff ff       	call   80109b <fd2num>
  801877:	89 c3                	mov    %eax,%ebx
  801879:	83 c4 10             	add    $0x10,%esp
}
  80187c:	89 d8                	mov    %ebx,%eax
  80187e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801881:	5b                   	pop    %ebx
  801882:	5e                   	pop    %esi
  801883:	5d                   	pop    %ebp
  801884:	c3                   	ret    
		fd_close(fd, 0);
  801885:	83 ec 08             	sub    $0x8,%esp
  801888:	6a 00                	push   $0x0
  80188a:	ff 75 f4             	pushl  -0xc(%ebp)
  80188d:	e8 3c f9 ff ff       	call   8011ce <fd_close>
		return r;
  801892:	83 c4 10             	add    $0x10,%esp
  801895:	eb e5                	jmp    80187c <open+0x70>
		return -E_BAD_PATH;
  801897:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80189c:	eb de                	jmp    80187c <open+0x70>

0080189e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80189e:	f3 0f 1e fb          	endbr32 
  8018a2:	55                   	push   %ebp
  8018a3:	89 e5                	mov    %esp,%ebp
  8018a5:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ad:	b8 08 00 00 00       	mov    $0x8,%eax
  8018b2:	e8 b3 fd ff ff       	call   80166a <fsipc>
}
  8018b7:	c9                   	leave  
  8018b8:	c3                   	ret    

008018b9 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018b9:	f3 0f 1e fb          	endbr32 
  8018bd:	55                   	push   %ebp
  8018be:	89 e5                	mov    %esp,%ebp
  8018c0:	56                   	push   %esi
  8018c1:	53                   	push   %ebx
  8018c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018c5:	83 ec 0c             	sub    $0xc,%esp
  8018c8:	ff 75 08             	pushl  0x8(%ebp)
  8018cb:	e8 df f7 ff ff       	call   8010af <fd2data>
  8018d0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018d2:	83 c4 08             	add    $0x8,%esp
  8018d5:	68 41 27 80 00       	push   $0x802741
  8018da:	53                   	push   %ebx
  8018db:	e8 27 ef ff ff       	call   800807 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018e0:	8b 46 04             	mov    0x4(%esi),%eax
  8018e3:	2b 06                	sub    (%esi),%eax
  8018e5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018eb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018f2:	00 00 00 
	stat->st_dev = &devpipe;
  8018f5:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018fc:	30 80 00 
	return 0;
}
  8018ff:	b8 00 00 00 00       	mov    $0x0,%eax
  801904:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801907:	5b                   	pop    %ebx
  801908:	5e                   	pop    %esi
  801909:	5d                   	pop    %ebp
  80190a:	c3                   	ret    

0080190b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80190b:	f3 0f 1e fb          	endbr32 
  80190f:	55                   	push   %ebp
  801910:	89 e5                	mov    %esp,%ebp
  801912:	53                   	push   %ebx
  801913:	83 ec 0c             	sub    $0xc,%esp
  801916:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801919:	53                   	push   %ebx
  80191a:	6a 00                	push   $0x0
  80191c:	e8 b5 f3 ff ff       	call   800cd6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801921:	89 1c 24             	mov    %ebx,(%esp)
  801924:	e8 86 f7 ff ff       	call   8010af <fd2data>
  801929:	83 c4 08             	add    $0x8,%esp
  80192c:	50                   	push   %eax
  80192d:	6a 00                	push   $0x0
  80192f:	e8 a2 f3 ff ff       	call   800cd6 <sys_page_unmap>
}
  801934:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801937:	c9                   	leave  
  801938:	c3                   	ret    

00801939 <_pipeisclosed>:
{
  801939:	55                   	push   %ebp
  80193a:	89 e5                	mov    %esp,%ebp
  80193c:	57                   	push   %edi
  80193d:	56                   	push   %esi
  80193e:	53                   	push   %ebx
  80193f:	83 ec 1c             	sub    $0x1c,%esp
  801942:	89 c7                	mov    %eax,%edi
  801944:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801946:	a1 04 40 80 00       	mov    0x804004,%eax
  80194b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80194e:	83 ec 0c             	sub    $0xc,%esp
  801951:	57                   	push   %edi
  801952:	e8 47 06 00 00       	call   801f9e <pageref>
  801957:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80195a:	89 34 24             	mov    %esi,(%esp)
  80195d:	e8 3c 06 00 00       	call   801f9e <pageref>
		nn = thisenv->env_runs;
  801962:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801968:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80196b:	83 c4 10             	add    $0x10,%esp
  80196e:	39 cb                	cmp    %ecx,%ebx
  801970:	74 1b                	je     80198d <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801972:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801975:	75 cf                	jne    801946 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801977:	8b 42 58             	mov    0x58(%edx),%eax
  80197a:	6a 01                	push   $0x1
  80197c:	50                   	push   %eax
  80197d:	53                   	push   %ebx
  80197e:	68 48 27 80 00       	push   $0x802748
  801983:	e8 76 e8 ff ff       	call   8001fe <cprintf>
  801988:	83 c4 10             	add    $0x10,%esp
  80198b:	eb b9                	jmp    801946 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  80198d:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801990:	0f 94 c0             	sete   %al
  801993:	0f b6 c0             	movzbl %al,%eax
}
  801996:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801999:	5b                   	pop    %ebx
  80199a:	5e                   	pop    %esi
  80199b:	5f                   	pop    %edi
  80199c:	5d                   	pop    %ebp
  80199d:	c3                   	ret    

0080199e <devpipe_write>:
{
  80199e:	f3 0f 1e fb          	endbr32 
  8019a2:	55                   	push   %ebp
  8019a3:	89 e5                	mov    %esp,%ebp
  8019a5:	57                   	push   %edi
  8019a6:	56                   	push   %esi
  8019a7:	53                   	push   %ebx
  8019a8:	83 ec 28             	sub    $0x28,%esp
  8019ab:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8019ae:	56                   	push   %esi
  8019af:	e8 fb f6 ff ff       	call   8010af <fd2data>
  8019b4:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8019b6:	83 c4 10             	add    $0x10,%esp
  8019b9:	bf 00 00 00 00       	mov    $0x0,%edi
  8019be:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019c1:	74 4f                	je     801a12 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019c3:	8b 43 04             	mov    0x4(%ebx),%eax
  8019c6:	8b 0b                	mov    (%ebx),%ecx
  8019c8:	8d 51 20             	lea    0x20(%ecx),%edx
  8019cb:	39 d0                	cmp    %edx,%eax
  8019cd:	72 14                	jb     8019e3 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  8019cf:	89 da                	mov    %ebx,%edx
  8019d1:	89 f0                	mov    %esi,%eax
  8019d3:	e8 61 ff ff ff       	call   801939 <_pipeisclosed>
  8019d8:	85 c0                	test   %eax,%eax
  8019da:	75 3b                	jne    801a17 <devpipe_write+0x79>
			sys_yield();
  8019dc:	e8 45 f2 ff ff       	call   800c26 <sys_yield>
  8019e1:	eb e0                	jmp    8019c3 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019e6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019ea:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019ed:	89 c2                	mov    %eax,%edx
  8019ef:	c1 fa 1f             	sar    $0x1f,%edx
  8019f2:	89 d1                	mov    %edx,%ecx
  8019f4:	c1 e9 1b             	shr    $0x1b,%ecx
  8019f7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019fa:	83 e2 1f             	and    $0x1f,%edx
  8019fd:	29 ca                	sub    %ecx,%edx
  8019ff:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a03:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a07:	83 c0 01             	add    $0x1,%eax
  801a0a:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801a0d:	83 c7 01             	add    $0x1,%edi
  801a10:	eb ac                	jmp    8019be <devpipe_write+0x20>
	return i;
  801a12:	8b 45 10             	mov    0x10(%ebp),%eax
  801a15:	eb 05                	jmp    801a1c <devpipe_write+0x7e>
				return 0;
  801a17:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a1f:	5b                   	pop    %ebx
  801a20:	5e                   	pop    %esi
  801a21:	5f                   	pop    %edi
  801a22:	5d                   	pop    %ebp
  801a23:	c3                   	ret    

00801a24 <devpipe_read>:
{
  801a24:	f3 0f 1e fb          	endbr32 
  801a28:	55                   	push   %ebp
  801a29:	89 e5                	mov    %esp,%ebp
  801a2b:	57                   	push   %edi
  801a2c:	56                   	push   %esi
  801a2d:	53                   	push   %ebx
  801a2e:	83 ec 18             	sub    $0x18,%esp
  801a31:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801a34:	57                   	push   %edi
  801a35:	e8 75 f6 ff ff       	call   8010af <fd2data>
  801a3a:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801a3c:	83 c4 10             	add    $0x10,%esp
  801a3f:	be 00 00 00 00       	mov    $0x0,%esi
  801a44:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a47:	75 14                	jne    801a5d <devpipe_read+0x39>
	return i;
  801a49:	8b 45 10             	mov    0x10(%ebp),%eax
  801a4c:	eb 02                	jmp    801a50 <devpipe_read+0x2c>
				return i;
  801a4e:	89 f0                	mov    %esi,%eax
}
  801a50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a53:	5b                   	pop    %ebx
  801a54:	5e                   	pop    %esi
  801a55:	5f                   	pop    %edi
  801a56:	5d                   	pop    %ebp
  801a57:	c3                   	ret    
			sys_yield();
  801a58:	e8 c9 f1 ff ff       	call   800c26 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801a5d:	8b 03                	mov    (%ebx),%eax
  801a5f:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a62:	75 18                	jne    801a7c <devpipe_read+0x58>
			if (i > 0)
  801a64:	85 f6                	test   %esi,%esi
  801a66:	75 e6                	jne    801a4e <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801a68:	89 da                	mov    %ebx,%edx
  801a6a:	89 f8                	mov    %edi,%eax
  801a6c:	e8 c8 fe ff ff       	call   801939 <_pipeisclosed>
  801a71:	85 c0                	test   %eax,%eax
  801a73:	74 e3                	je     801a58 <devpipe_read+0x34>
				return 0;
  801a75:	b8 00 00 00 00       	mov    $0x0,%eax
  801a7a:	eb d4                	jmp    801a50 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a7c:	99                   	cltd   
  801a7d:	c1 ea 1b             	shr    $0x1b,%edx
  801a80:	01 d0                	add    %edx,%eax
  801a82:	83 e0 1f             	and    $0x1f,%eax
  801a85:	29 d0                	sub    %edx,%eax
  801a87:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801a8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a8f:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801a92:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801a95:	83 c6 01             	add    $0x1,%esi
  801a98:	eb aa                	jmp    801a44 <devpipe_read+0x20>

00801a9a <pipe>:
{
  801a9a:	f3 0f 1e fb          	endbr32 
  801a9e:	55                   	push   %ebp
  801a9f:	89 e5                	mov    %esp,%ebp
  801aa1:	56                   	push   %esi
  801aa2:	53                   	push   %ebx
  801aa3:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801aa6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa9:	50                   	push   %eax
  801aaa:	e8 1b f6 ff ff       	call   8010ca <fd_alloc>
  801aaf:	89 c3                	mov    %eax,%ebx
  801ab1:	83 c4 10             	add    $0x10,%esp
  801ab4:	85 c0                	test   %eax,%eax
  801ab6:	0f 88 23 01 00 00    	js     801bdf <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801abc:	83 ec 04             	sub    $0x4,%esp
  801abf:	68 07 04 00 00       	push   $0x407
  801ac4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ac7:	6a 00                	push   $0x0
  801ac9:	e8 7b f1 ff ff       	call   800c49 <sys_page_alloc>
  801ace:	89 c3                	mov    %eax,%ebx
  801ad0:	83 c4 10             	add    $0x10,%esp
  801ad3:	85 c0                	test   %eax,%eax
  801ad5:	0f 88 04 01 00 00    	js     801bdf <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801adb:	83 ec 0c             	sub    $0xc,%esp
  801ade:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ae1:	50                   	push   %eax
  801ae2:	e8 e3 f5 ff ff       	call   8010ca <fd_alloc>
  801ae7:	89 c3                	mov    %eax,%ebx
  801ae9:	83 c4 10             	add    $0x10,%esp
  801aec:	85 c0                	test   %eax,%eax
  801aee:	0f 88 db 00 00 00    	js     801bcf <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801af4:	83 ec 04             	sub    $0x4,%esp
  801af7:	68 07 04 00 00       	push   $0x407
  801afc:	ff 75 f0             	pushl  -0x10(%ebp)
  801aff:	6a 00                	push   $0x0
  801b01:	e8 43 f1 ff ff       	call   800c49 <sys_page_alloc>
  801b06:	89 c3                	mov    %eax,%ebx
  801b08:	83 c4 10             	add    $0x10,%esp
  801b0b:	85 c0                	test   %eax,%eax
  801b0d:	0f 88 bc 00 00 00    	js     801bcf <pipe+0x135>
	va = fd2data(fd0);
  801b13:	83 ec 0c             	sub    $0xc,%esp
  801b16:	ff 75 f4             	pushl  -0xc(%ebp)
  801b19:	e8 91 f5 ff ff       	call   8010af <fd2data>
  801b1e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b20:	83 c4 0c             	add    $0xc,%esp
  801b23:	68 07 04 00 00       	push   $0x407
  801b28:	50                   	push   %eax
  801b29:	6a 00                	push   $0x0
  801b2b:	e8 19 f1 ff ff       	call   800c49 <sys_page_alloc>
  801b30:	89 c3                	mov    %eax,%ebx
  801b32:	83 c4 10             	add    $0x10,%esp
  801b35:	85 c0                	test   %eax,%eax
  801b37:	0f 88 82 00 00 00    	js     801bbf <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b3d:	83 ec 0c             	sub    $0xc,%esp
  801b40:	ff 75 f0             	pushl  -0x10(%ebp)
  801b43:	e8 67 f5 ff ff       	call   8010af <fd2data>
  801b48:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b4f:	50                   	push   %eax
  801b50:	6a 00                	push   $0x0
  801b52:	56                   	push   %esi
  801b53:	6a 00                	push   $0x0
  801b55:	e8 36 f1 ff ff       	call   800c90 <sys_page_map>
  801b5a:	89 c3                	mov    %eax,%ebx
  801b5c:	83 c4 20             	add    $0x20,%esp
  801b5f:	85 c0                	test   %eax,%eax
  801b61:	78 4e                	js     801bb1 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801b63:	a1 20 30 80 00       	mov    0x803020,%eax
  801b68:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b6b:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801b6d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b70:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801b77:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b7a:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801b7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b7f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801b86:	83 ec 0c             	sub    $0xc,%esp
  801b89:	ff 75 f4             	pushl  -0xc(%ebp)
  801b8c:	e8 0a f5 ff ff       	call   80109b <fd2num>
  801b91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b94:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b96:	83 c4 04             	add    $0x4,%esp
  801b99:	ff 75 f0             	pushl  -0x10(%ebp)
  801b9c:	e8 fa f4 ff ff       	call   80109b <fd2num>
  801ba1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ba4:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ba7:	83 c4 10             	add    $0x10,%esp
  801baa:	bb 00 00 00 00       	mov    $0x0,%ebx
  801baf:	eb 2e                	jmp    801bdf <pipe+0x145>
	sys_page_unmap(0, va);
  801bb1:	83 ec 08             	sub    $0x8,%esp
  801bb4:	56                   	push   %esi
  801bb5:	6a 00                	push   $0x0
  801bb7:	e8 1a f1 ff ff       	call   800cd6 <sys_page_unmap>
  801bbc:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801bbf:	83 ec 08             	sub    $0x8,%esp
  801bc2:	ff 75 f0             	pushl  -0x10(%ebp)
  801bc5:	6a 00                	push   $0x0
  801bc7:	e8 0a f1 ff ff       	call   800cd6 <sys_page_unmap>
  801bcc:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801bcf:	83 ec 08             	sub    $0x8,%esp
  801bd2:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd5:	6a 00                	push   $0x0
  801bd7:	e8 fa f0 ff ff       	call   800cd6 <sys_page_unmap>
  801bdc:	83 c4 10             	add    $0x10,%esp
}
  801bdf:	89 d8                	mov    %ebx,%eax
  801be1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801be4:	5b                   	pop    %ebx
  801be5:	5e                   	pop    %esi
  801be6:	5d                   	pop    %ebp
  801be7:	c3                   	ret    

00801be8 <pipeisclosed>:
{
  801be8:	f3 0f 1e fb          	endbr32 
  801bec:	55                   	push   %ebp
  801bed:	89 e5                	mov    %esp,%ebp
  801bef:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bf2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf5:	50                   	push   %eax
  801bf6:	ff 75 08             	pushl  0x8(%ebp)
  801bf9:	e8 22 f5 ff ff       	call   801120 <fd_lookup>
  801bfe:	83 c4 10             	add    $0x10,%esp
  801c01:	85 c0                	test   %eax,%eax
  801c03:	78 18                	js     801c1d <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801c05:	83 ec 0c             	sub    $0xc,%esp
  801c08:	ff 75 f4             	pushl  -0xc(%ebp)
  801c0b:	e8 9f f4 ff ff       	call   8010af <fd2data>
  801c10:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801c12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c15:	e8 1f fd ff ff       	call   801939 <_pipeisclosed>
  801c1a:	83 c4 10             	add    $0x10,%esp
}
  801c1d:	c9                   	leave  
  801c1e:	c3                   	ret    

00801c1f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c1f:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801c23:	b8 00 00 00 00       	mov    $0x0,%eax
  801c28:	c3                   	ret    

00801c29 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c29:	f3 0f 1e fb          	endbr32 
  801c2d:	55                   	push   %ebp
  801c2e:	89 e5                	mov    %esp,%ebp
  801c30:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c33:	68 60 27 80 00       	push   $0x802760
  801c38:	ff 75 0c             	pushl  0xc(%ebp)
  801c3b:	e8 c7 eb ff ff       	call   800807 <strcpy>
	return 0;
}
  801c40:	b8 00 00 00 00       	mov    $0x0,%eax
  801c45:	c9                   	leave  
  801c46:	c3                   	ret    

00801c47 <devcons_write>:
{
  801c47:	f3 0f 1e fb          	endbr32 
  801c4b:	55                   	push   %ebp
  801c4c:	89 e5                	mov    %esp,%ebp
  801c4e:	57                   	push   %edi
  801c4f:	56                   	push   %esi
  801c50:	53                   	push   %ebx
  801c51:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801c57:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801c5c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801c62:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c65:	73 31                	jae    801c98 <devcons_write+0x51>
		m = n - tot;
  801c67:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c6a:	29 f3                	sub    %esi,%ebx
  801c6c:	83 fb 7f             	cmp    $0x7f,%ebx
  801c6f:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801c74:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801c77:	83 ec 04             	sub    $0x4,%esp
  801c7a:	53                   	push   %ebx
  801c7b:	89 f0                	mov    %esi,%eax
  801c7d:	03 45 0c             	add    0xc(%ebp),%eax
  801c80:	50                   	push   %eax
  801c81:	57                   	push   %edi
  801c82:	e8 36 ed ff ff       	call   8009bd <memmove>
		sys_cputs(buf, m);
  801c87:	83 c4 08             	add    $0x8,%esp
  801c8a:	53                   	push   %ebx
  801c8b:	57                   	push   %edi
  801c8c:	e8 e8 ee ff ff       	call   800b79 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801c91:	01 de                	add    %ebx,%esi
  801c93:	83 c4 10             	add    $0x10,%esp
  801c96:	eb ca                	jmp    801c62 <devcons_write+0x1b>
}
  801c98:	89 f0                	mov    %esi,%eax
  801c9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c9d:	5b                   	pop    %ebx
  801c9e:	5e                   	pop    %esi
  801c9f:	5f                   	pop    %edi
  801ca0:	5d                   	pop    %ebp
  801ca1:	c3                   	ret    

00801ca2 <devcons_read>:
{
  801ca2:	f3 0f 1e fb          	endbr32 
  801ca6:	55                   	push   %ebp
  801ca7:	89 e5                	mov    %esp,%ebp
  801ca9:	83 ec 08             	sub    $0x8,%esp
  801cac:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801cb1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cb5:	74 21                	je     801cd8 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801cb7:	e8 df ee ff ff       	call   800b9b <sys_cgetc>
  801cbc:	85 c0                	test   %eax,%eax
  801cbe:	75 07                	jne    801cc7 <devcons_read+0x25>
		sys_yield();
  801cc0:	e8 61 ef ff ff       	call   800c26 <sys_yield>
  801cc5:	eb f0                	jmp    801cb7 <devcons_read+0x15>
	if (c < 0)
  801cc7:	78 0f                	js     801cd8 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801cc9:	83 f8 04             	cmp    $0x4,%eax
  801ccc:	74 0c                	je     801cda <devcons_read+0x38>
	*(char*)vbuf = c;
  801cce:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cd1:	88 02                	mov    %al,(%edx)
	return 1;
  801cd3:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801cd8:	c9                   	leave  
  801cd9:	c3                   	ret    
		return 0;
  801cda:	b8 00 00 00 00       	mov    $0x0,%eax
  801cdf:	eb f7                	jmp    801cd8 <devcons_read+0x36>

00801ce1 <cputchar>:
{
  801ce1:	f3 0f 1e fb          	endbr32 
  801ce5:	55                   	push   %ebp
  801ce6:	89 e5                	mov    %esp,%ebp
  801ce8:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ceb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cee:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801cf1:	6a 01                	push   $0x1
  801cf3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cf6:	50                   	push   %eax
  801cf7:	e8 7d ee ff ff       	call   800b79 <sys_cputs>
}
  801cfc:	83 c4 10             	add    $0x10,%esp
  801cff:	c9                   	leave  
  801d00:	c3                   	ret    

00801d01 <getchar>:
{
  801d01:	f3 0f 1e fb          	endbr32 
  801d05:	55                   	push   %ebp
  801d06:	89 e5                	mov    %esp,%ebp
  801d08:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801d0b:	6a 01                	push   $0x1
  801d0d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d10:	50                   	push   %eax
  801d11:	6a 00                	push   $0x0
  801d13:	e8 8b f6 ff ff       	call   8013a3 <read>
	if (r < 0)
  801d18:	83 c4 10             	add    $0x10,%esp
  801d1b:	85 c0                	test   %eax,%eax
  801d1d:	78 06                	js     801d25 <getchar+0x24>
	if (r < 1)
  801d1f:	74 06                	je     801d27 <getchar+0x26>
	return c;
  801d21:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801d25:	c9                   	leave  
  801d26:	c3                   	ret    
		return -E_EOF;
  801d27:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801d2c:	eb f7                	jmp    801d25 <getchar+0x24>

00801d2e <iscons>:
{
  801d2e:	f3 0f 1e fb          	endbr32 
  801d32:	55                   	push   %ebp
  801d33:	89 e5                	mov    %esp,%ebp
  801d35:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d38:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d3b:	50                   	push   %eax
  801d3c:	ff 75 08             	pushl  0x8(%ebp)
  801d3f:	e8 dc f3 ff ff       	call   801120 <fd_lookup>
  801d44:	83 c4 10             	add    $0x10,%esp
  801d47:	85 c0                	test   %eax,%eax
  801d49:	78 11                	js     801d5c <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801d4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d54:	39 10                	cmp    %edx,(%eax)
  801d56:	0f 94 c0             	sete   %al
  801d59:	0f b6 c0             	movzbl %al,%eax
}
  801d5c:	c9                   	leave  
  801d5d:	c3                   	ret    

00801d5e <opencons>:
{
  801d5e:	f3 0f 1e fb          	endbr32 
  801d62:	55                   	push   %ebp
  801d63:	89 e5                	mov    %esp,%ebp
  801d65:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801d68:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d6b:	50                   	push   %eax
  801d6c:	e8 59 f3 ff ff       	call   8010ca <fd_alloc>
  801d71:	83 c4 10             	add    $0x10,%esp
  801d74:	85 c0                	test   %eax,%eax
  801d76:	78 3a                	js     801db2 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d78:	83 ec 04             	sub    $0x4,%esp
  801d7b:	68 07 04 00 00       	push   $0x407
  801d80:	ff 75 f4             	pushl  -0xc(%ebp)
  801d83:	6a 00                	push   $0x0
  801d85:	e8 bf ee ff ff       	call   800c49 <sys_page_alloc>
  801d8a:	83 c4 10             	add    $0x10,%esp
  801d8d:	85 c0                	test   %eax,%eax
  801d8f:	78 21                	js     801db2 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801d91:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d94:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d9a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801da6:	83 ec 0c             	sub    $0xc,%esp
  801da9:	50                   	push   %eax
  801daa:	e8 ec f2 ff ff       	call   80109b <fd2num>
  801daf:	83 c4 10             	add    $0x10,%esp
}
  801db2:	c9                   	leave  
  801db3:	c3                   	ret    

00801db4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801db4:	f3 0f 1e fb          	endbr32 
  801db8:	55                   	push   %ebp
  801db9:	89 e5                	mov    %esp,%ebp
  801dbb:	56                   	push   %esi
  801dbc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801dbd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801dc0:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801dc6:	e8 38 ee ff ff       	call   800c03 <sys_getenvid>
  801dcb:	83 ec 0c             	sub    $0xc,%esp
  801dce:	ff 75 0c             	pushl  0xc(%ebp)
  801dd1:	ff 75 08             	pushl  0x8(%ebp)
  801dd4:	56                   	push   %esi
  801dd5:	50                   	push   %eax
  801dd6:	68 6c 27 80 00       	push   $0x80276c
  801ddb:	e8 1e e4 ff ff       	call   8001fe <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801de0:	83 c4 18             	add    $0x18,%esp
  801de3:	53                   	push   %ebx
  801de4:	ff 75 10             	pushl  0x10(%ebp)
  801de7:	e8 bd e3 ff ff       	call   8001a9 <vcprintf>
	cprintf("\n");
  801dec:	c7 04 24 4f 22 80 00 	movl   $0x80224f,(%esp)
  801df3:	e8 06 e4 ff ff       	call   8001fe <cprintf>
  801df8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801dfb:	cc                   	int3   
  801dfc:	eb fd                	jmp    801dfb <_panic+0x47>

00801dfe <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801dfe:	f3 0f 1e fb          	endbr32 
  801e02:	55                   	push   %ebp
  801e03:	89 e5                	mov    %esp,%ebp
  801e05:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e08:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e0f:	74 0a                	je     801e1b <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e11:	8b 45 08             	mov    0x8(%ebp),%eax
  801e14:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e19:	c9                   	leave  
  801e1a:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  801e1b:	83 ec 0c             	sub    $0xc,%esp
  801e1e:	68 8f 27 80 00       	push   $0x80278f
  801e23:	e8 d6 e3 ff ff       	call   8001fe <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  801e28:	83 c4 0c             	add    $0xc,%esp
  801e2b:	6a 07                	push   $0x7
  801e2d:	68 00 f0 bf ee       	push   $0xeebff000
  801e32:	6a 00                	push   $0x0
  801e34:	e8 10 ee ff ff       	call   800c49 <sys_page_alloc>
  801e39:	83 c4 10             	add    $0x10,%esp
  801e3c:	85 c0                	test   %eax,%eax
  801e3e:	78 2a                	js     801e6a <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  801e40:	83 ec 08             	sub    $0x8,%esp
  801e43:	68 7e 1e 80 00       	push   $0x801e7e
  801e48:	6a 00                	push   $0x0
  801e4a:	e8 59 ef ff ff       	call   800da8 <sys_env_set_pgfault_upcall>
  801e4f:	83 c4 10             	add    $0x10,%esp
  801e52:	85 c0                	test   %eax,%eax
  801e54:	79 bb                	jns    801e11 <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  801e56:	83 ec 04             	sub    $0x4,%esp
  801e59:	68 cc 27 80 00       	push   $0x8027cc
  801e5e:	6a 25                	push   $0x25
  801e60:	68 bc 27 80 00       	push   $0x8027bc
  801e65:	e8 4a ff ff ff       	call   801db4 <_panic>
            panic("Allocation of UXSTACK failed!");
  801e6a:	83 ec 04             	sub    $0x4,%esp
  801e6d:	68 9e 27 80 00       	push   $0x80279e
  801e72:	6a 22                	push   $0x22
  801e74:	68 bc 27 80 00       	push   $0x8027bc
  801e79:	e8 36 ff ff ff       	call   801db4 <_panic>

00801e7e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e7e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e7f:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e84:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e86:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  801e89:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  801e8d:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  801e91:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  801e94:	83 c4 08             	add    $0x8,%esp
    popa
  801e97:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

    add $0x4, %esp
  801e98:	83 c4 04             	add    $0x4,%esp
    popf
  801e9b:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  801e9c:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  801e9f:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  801ea3:	c3                   	ret    

00801ea4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ea4:	f3 0f 1e fb          	endbr32 
  801ea8:	55                   	push   %ebp
  801ea9:	89 e5                	mov    %esp,%ebp
  801eab:	56                   	push   %esi
  801eac:	53                   	push   %ebx
  801ead:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801eb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eb3:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801eb6:	85 c0                	test   %eax,%eax
  801eb8:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801ebd:	0f 44 c2             	cmove  %edx,%eax
  801ec0:	83 ec 0c             	sub    $0xc,%esp
  801ec3:	50                   	push   %eax
  801ec4:	e8 4c ef ff ff       	call   800e15 <sys_ipc_recv>
  801ec9:	83 c4 10             	add    $0x10,%esp
  801ecc:	85 c0                	test   %eax,%eax
  801ece:	78 24                	js     801ef4 <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801ed0:	85 f6                	test   %esi,%esi
  801ed2:	74 0a                	je     801ede <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801ed4:	a1 04 40 80 00       	mov    0x804004,%eax
  801ed9:	8b 40 78             	mov    0x78(%eax),%eax
  801edc:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801ede:	85 db                	test   %ebx,%ebx
  801ee0:	74 0a                	je     801eec <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801ee2:	a1 04 40 80 00       	mov    0x804004,%eax
  801ee7:	8b 40 74             	mov    0x74(%eax),%eax
  801eea:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801eec:	a1 04 40 80 00       	mov    0x804004,%eax
  801ef1:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ef4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ef7:	5b                   	pop    %ebx
  801ef8:	5e                   	pop    %esi
  801ef9:	5d                   	pop    %ebp
  801efa:	c3                   	ret    

00801efb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801efb:	f3 0f 1e fb          	endbr32 
  801eff:	55                   	push   %ebp
  801f00:	89 e5                	mov    %esp,%ebp
  801f02:	57                   	push   %edi
  801f03:	56                   	push   %esi
  801f04:	53                   	push   %ebx
  801f05:	83 ec 1c             	sub    $0x1c,%esp
  801f08:	8b 45 10             	mov    0x10(%ebp),%eax
  801f0b:	85 c0                	test   %eax,%eax
  801f0d:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801f12:	0f 45 d0             	cmovne %eax,%edx
  801f15:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801f17:	be 01 00 00 00       	mov    $0x1,%esi
  801f1c:	eb 1f                	jmp    801f3d <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801f1e:	e8 03 ed ff ff       	call   800c26 <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801f23:	83 c3 01             	add    $0x1,%ebx
  801f26:	39 de                	cmp    %ebx,%esi
  801f28:	7f f4                	jg     801f1e <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801f2a:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801f2c:	83 fe 11             	cmp    $0x11,%esi
  801f2f:	b8 01 00 00 00       	mov    $0x1,%eax
  801f34:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801f37:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801f3b:	75 1c                	jne    801f59 <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801f3d:	ff 75 14             	pushl  0x14(%ebp)
  801f40:	57                   	push   %edi
  801f41:	ff 75 0c             	pushl  0xc(%ebp)
  801f44:	ff 75 08             	pushl  0x8(%ebp)
  801f47:	e8 a2 ee ff ff       	call   800dee <sys_ipc_try_send>
  801f4c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801f4f:	83 c4 10             	add    $0x10,%esp
  801f52:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f57:	eb cd                	jmp    801f26 <ipc_send+0x2b>
}
  801f59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f5c:	5b                   	pop    %ebx
  801f5d:	5e                   	pop    %esi
  801f5e:	5f                   	pop    %edi
  801f5f:	5d                   	pop    %ebp
  801f60:	c3                   	ret    

00801f61 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f61:	f3 0f 1e fb          	endbr32 
  801f65:	55                   	push   %ebp
  801f66:	89 e5                	mov    %esp,%ebp
  801f68:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f6b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f70:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f73:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f79:	8b 52 50             	mov    0x50(%edx),%edx
  801f7c:	39 ca                	cmp    %ecx,%edx
  801f7e:	74 11                	je     801f91 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801f80:	83 c0 01             	add    $0x1,%eax
  801f83:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f88:	75 e6                	jne    801f70 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801f8a:	b8 00 00 00 00       	mov    $0x0,%eax
  801f8f:	eb 0b                	jmp    801f9c <ipc_find_env+0x3b>
			return envs[i].env_id;
  801f91:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f94:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f99:	8b 40 48             	mov    0x48(%eax),%eax
}
  801f9c:	5d                   	pop    %ebp
  801f9d:	c3                   	ret    

00801f9e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f9e:	f3 0f 1e fb          	endbr32 
  801fa2:	55                   	push   %ebp
  801fa3:	89 e5                	mov    %esp,%ebp
  801fa5:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fa8:	89 c2                	mov    %eax,%edx
  801faa:	c1 ea 16             	shr    $0x16,%edx
  801fad:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801fb4:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801fb9:	f6 c1 01             	test   $0x1,%cl
  801fbc:	74 1c                	je     801fda <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801fbe:	c1 e8 0c             	shr    $0xc,%eax
  801fc1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801fc8:	a8 01                	test   $0x1,%al
  801fca:	74 0e                	je     801fda <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fcc:	c1 e8 0c             	shr    $0xc,%eax
  801fcf:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801fd6:	ef 
  801fd7:	0f b7 d2             	movzwl %dx,%edx
}
  801fda:	89 d0                	mov    %edx,%eax
  801fdc:	5d                   	pop    %ebp
  801fdd:	c3                   	ret    
  801fde:	66 90                	xchg   %ax,%ax

00801fe0 <__udivdi3>:
  801fe0:	f3 0f 1e fb          	endbr32 
  801fe4:	55                   	push   %ebp
  801fe5:	57                   	push   %edi
  801fe6:	56                   	push   %esi
  801fe7:	53                   	push   %ebx
  801fe8:	83 ec 1c             	sub    $0x1c,%esp
  801feb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801fef:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801ff3:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ff7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801ffb:	85 d2                	test   %edx,%edx
  801ffd:	75 19                	jne    802018 <__udivdi3+0x38>
  801fff:	39 f3                	cmp    %esi,%ebx
  802001:	76 4d                	jbe    802050 <__udivdi3+0x70>
  802003:	31 ff                	xor    %edi,%edi
  802005:	89 e8                	mov    %ebp,%eax
  802007:	89 f2                	mov    %esi,%edx
  802009:	f7 f3                	div    %ebx
  80200b:	89 fa                	mov    %edi,%edx
  80200d:	83 c4 1c             	add    $0x1c,%esp
  802010:	5b                   	pop    %ebx
  802011:	5e                   	pop    %esi
  802012:	5f                   	pop    %edi
  802013:	5d                   	pop    %ebp
  802014:	c3                   	ret    
  802015:	8d 76 00             	lea    0x0(%esi),%esi
  802018:	39 f2                	cmp    %esi,%edx
  80201a:	76 14                	jbe    802030 <__udivdi3+0x50>
  80201c:	31 ff                	xor    %edi,%edi
  80201e:	31 c0                	xor    %eax,%eax
  802020:	89 fa                	mov    %edi,%edx
  802022:	83 c4 1c             	add    $0x1c,%esp
  802025:	5b                   	pop    %ebx
  802026:	5e                   	pop    %esi
  802027:	5f                   	pop    %edi
  802028:	5d                   	pop    %ebp
  802029:	c3                   	ret    
  80202a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802030:	0f bd fa             	bsr    %edx,%edi
  802033:	83 f7 1f             	xor    $0x1f,%edi
  802036:	75 48                	jne    802080 <__udivdi3+0xa0>
  802038:	39 f2                	cmp    %esi,%edx
  80203a:	72 06                	jb     802042 <__udivdi3+0x62>
  80203c:	31 c0                	xor    %eax,%eax
  80203e:	39 eb                	cmp    %ebp,%ebx
  802040:	77 de                	ja     802020 <__udivdi3+0x40>
  802042:	b8 01 00 00 00       	mov    $0x1,%eax
  802047:	eb d7                	jmp    802020 <__udivdi3+0x40>
  802049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802050:	89 d9                	mov    %ebx,%ecx
  802052:	85 db                	test   %ebx,%ebx
  802054:	75 0b                	jne    802061 <__udivdi3+0x81>
  802056:	b8 01 00 00 00       	mov    $0x1,%eax
  80205b:	31 d2                	xor    %edx,%edx
  80205d:	f7 f3                	div    %ebx
  80205f:	89 c1                	mov    %eax,%ecx
  802061:	31 d2                	xor    %edx,%edx
  802063:	89 f0                	mov    %esi,%eax
  802065:	f7 f1                	div    %ecx
  802067:	89 c6                	mov    %eax,%esi
  802069:	89 e8                	mov    %ebp,%eax
  80206b:	89 f7                	mov    %esi,%edi
  80206d:	f7 f1                	div    %ecx
  80206f:	89 fa                	mov    %edi,%edx
  802071:	83 c4 1c             	add    $0x1c,%esp
  802074:	5b                   	pop    %ebx
  802075:	5e                   	pop    %esi
  802076:	5f                   	pop    %edi
  802077:	5d                   	pop    %ebp
  802078:	c3                   	ret    
  802079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802080:	89 f9                	mov    %edi,%ecx
  802082:	b8 20 00 00 00       	mov    $0x20,%eax
  802087:	29 f8                	sub    %edi,%eax
  802089:	d3 e2                	shl    %cl,%edx
  80208b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80208f:	89 c1                	mov    %eax,%ecx
  802091:	89 da                	mov    %ebx,%edx
  802093:	d3 ea                	shr    %cl,%edx
  802095:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802099:	09 d1                	or     %edx,%ecx
  80209b:	89 f2                	mov    %esi,%edx
  80209d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020a1:	89 f9                	mov    %edi,%ecx
  8020a3:	d3 e3                	shl    %cl,%ebx
  8020a5:	89 c1                	mov    %eax,%ecx
  8020a7:	d3 ea                	shr    %cl,%edx
  8020a9:	89 f9                	mov    %edi,%ecx
  8020ab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8020af:	89 eb                	mov    %ebp,%ebx
  8020b1:	d3 e6                	shl    %cl,%esi
  8020b3:	89 c1                	mov    %eax,%ecx
  8020b5:	d3 eb                	shr    %cl,%ebx
  8020b7:	09 de                	or     %ebx,%esi
  8020b9:	89 f0                	mov    %esi,%eax
  8020bb:	f7 74 24 08          	divl   0x8(%esp)
  8020bf:	89 d6                	mov    %edx,%esi
  8020c1:	89 c3                	mov    %eax,%ebx
  8020c3:	f7 64 24 0c          	mull   0xc(%esp)
  8020c7:	39 d6                	cmp    %edx,%esi
  8020c9:	72 15                	jb     8020e0 <__udivdi3+0x100>
  8020cb:	89 f9                	mov    %edi,%ecx
  8020cd:	d3 e5                	shl    %cl,%ebp
  8020cf:	39 c5                	cmp    %eax,%ebp
  8020d1:	73 04                	jae    8020d7 <__udivdi3+0xf7>
  8020d3:	39 d6                	cmp    %edx,%esi
  8020d5:	74 09                	je     8020e0 <__udivdi3+0x100>
  8020d7:	89 d8                	mov    %ebx,%eax
  8020d9:	31 ff                	xor    %edi,%edi
  8020db:	e9 40 ff ff ff       	jmp    802020 <__udivdi3+0x40>
  8020e0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8020e3:	31 ff                	xor    %edi,%edi
  8020e5:	e9 36 ff ff ff       	jmp    802020 <__udivdi3+0x40>
  8020ea:	66 90                	xchg   %ax,%ax
  8020ec:	66 90                	xchg   %ax,%ax
  8020ee:	66 90                	xchg   %ax,%ax

008020f0 <__umoddi3>:
  8020f0:	f3 0f 1e fb          	endbr32 
  8020f4:	55                   	push   %ebp
  8020f5:	57                   	push   %edi
  8020f6:	56                   	push   %esi
  8020f7:	53                   	push   %ebx
  8020f8:	83 ec 1c             	sub    $0x1c,%esp
  8020fb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8020ff:	8b 74 24 30          	mov    0x30(%esp),%esi
  802103:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802107:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80210b:	85 c0                	test   %eax,%eax
  80210d:	75 19                	jne    802128 <__umoddi3+0x38>
  80210f:	39 df                	cmp    %ebx,%edi
  802111:	76 5d                	jbe    802170 <__umoddi3+0x80>
  802113:	89 f0                	mov    %esi,%eax
  802115:	89 da                	mov    %ebx,%edx
  802117:	f7 f7                	div    %edi
  802119:	89 d0                	mov    %edx,%eax
  80211b:	31 d2                	xor    %edx,%edx
  80211d:	83 c4 1c             	add    $0x1c,%esp
  802120:	5b                   	pop    %ebx
  802121:	5e                   	pop    %esi
  802122:	5f                   	pop    %edi
  802123:	5d                   	pop    %ebp
  802124:	c3                   	ret    
  802125:	8d 76 00             	lea    0x0(%esi),%esi
  802128:	89 f2                	mov    %esi,%edx
  80212a:	39 d8                	cmp    %ebx,%eax
  80212c:	76 12                	jbe    802140 <__umoddi3+0x50>
  80212e:	89 f0                	mov    %esi,%eax
  802130:	89 da                	mov    %ebx,%edx
  802132:	83 c4 1c             	add    $0x1c,%esp
  802135:	5b                   	pop    %ebx
  802136:	5e                   	pop    %esi
  802137:	5f                   	pop    %edi
  802138:	5d                   	pop    %ebp
  802139:	c3                   	ret    
  80213a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802140:	0f bd e8             	bsr    %eax,%ebp
  802143:	83 f5 1f             	xor    $0x1f,%ebp
  802146:	75 50                	jne    802198 <__umoddi3+0xa8>
  802148:	39 d8                	cmp    %ebx,%eax
  80214a:	0f 82 e0 00 00 00    	jb     802230 <__umoddi3+0x140>
  802150:	89 d9                	mov    %ebx,%ecx
  802152:	39 f7                	cmp    %esi,%edi
  802154:	0f 86 d6 00 00 00    	jbe    802230 <__umoddi3+0x140>
  80215a:	89 d0                	mov    %edx,%eax
  80215c:	89 ca                	mov    %ecx,%edx
  80215e:	83 c4 1c             	add    $0x1c,%esp
  802161:	5b                   	pop    %ebx
  802162:	5e                   	pop    %esi
  802163:	5f                   	pop    %edi
  802164:	5d                   	pop    %ebp
  802165:	c3                   	ret    
  802166:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80216d:	8d 76 00             	lea    0x0(%esi),%esi
  802170:	89 fd                	mov    %edi,%ebp
  802172:	85 ff                	test   %edi,%edi
  802174:	75 0b                	jne    802181 <__umoddi3+0x91>
  802176:	b8 01 00 00 00       	mov    $0x1,%eax
  80217b:	31 d2                	xor    %edx,%edx
  80217d:	f7 f7                	div    %edi
  80217f:	89 c5                	mov    %eax,%ebp
  802181:	89 d8                	mov    %ebx,%eax
  802183:	31 d2                	xor    %edx,%edx
  802185:	f7 f5                	div    %ebp
  802187:	89 f0                	mov    %esi,%eax
  802189:	f7 f5                	div    %ebp
  80218b:	89 d0                	mov    %edx,%eax
  80218d:	31 d2                	xor    %edx,%edx
  80218f:	eb 8c                	jmp    80211d <__umoddi3+0x2d>
  802191:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802198:	89 e9                	mov    %ebp,%ecx
  80219a:	ba 20 00 00 00       	mov    $0x20,%edx
  80219f:	29 ea                	sub    %ebp,%edx
  8021a1:	d3 e0                	shl    %cl,%eax
  8021a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021a7:	89 d1                	mov    %edx,%ecx
  8021a9:	89 f8                	mov    %edi,%eax
  8021ab:	d3 e8                	shr    %cl,%eax
  8021ad:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8021b1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021b5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021b9:	09 c1                	or     %eax,%ecx
  8021bb:	89 d8                	mov    %ebx,%eax
  8021bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021c1:	89 e9                	mov    %ebp,%ecx
  8021c3:	d3 e7                	shl    %cl,%edi
  8021c5:	89 d1                	mov    %edx,%ecx
  8021c7:	d3 e8                	shr    %cl,%eax
  8021c9:	89 e9                	mov    %ebp,%ecx
  8021cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8021cf:	d3 e3                	shl    %cl,%ebx
  8021d1:	89 c7                	mov    %eax,%edi
  8021d3:	89 d1                	mov    %edx,%ecx
  8021d5:	89 f0                	mov    %esi,%eax
  8021d7:	d3 e8                	shr    %cl,%eax
  8021d9:	89 e9                	mov    %ebp,%ecx
  8021db:	89 fa                	mov    %edi,%edx
  8021dd:	d3 e6                	shl    %cl,%esi
  8021df:	09 d8                	or     %ebx,%eax
  8021e1:	f7 74 24 08          	divl   0x8(%esp)
  8021e5:	89 d1                	mov    %edx,%ecx
  8021e7:	89 f3                	mov    %esi,%ebx
  8021e9:	f7 64 24 0c          	mull   0xc(%esp)
  8021ed:	89 c6                	mov    %eax,%esi
  8021ef:	89 d7                	mov    %edx,%edi
  8021f1:	39 d1                	cmp    %edx,%ecx
  8021f3:	72 06                	jb     8021fb <__umoddi3+0x10b>
  8021f5:	75 10                	jne    802207 <__umoddi3+0x117>
  8021f7:	39 c3                	cmp    %eax,%ebx
  8021f9:	73 0c                	jae    802207 <__umoddi3+0x117>
  8021fb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8021ff:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802203:	89 d7                	mov    %edx,%edi
  802205:	89 c6                	mov    %eax,%esi
  802207:	89 ca                	mov    %ecx,%edx
  802209:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80220e:	29 f3                	sub    %esi,%ebx
  802210:	19 fa                	sbb    %edi,%edx
  802212:	89 d0                	mov    %edx,%eax
  802214:	d3 e0                	shl    %cl,%eax
  802216:	89 e9                	mov    %ebp,%ecx
  802218:	d3 eb                	shr    %cl,%ebx
  80221a:	d3 ea                	shr    %cl,%edx
  80221c:	09 d8                	or     %ebx,%eax
  80221e:	83 c4 1c             	add    $0x1c,%esp
  802221:	5b                   	pop    %ebx
  802222:	5e                   	pop    %esi
  802223:	5f                   	pop    %edi
  802224:	5d                   	pop    %ebp
  802225:	c3                   	ret    
  802226:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80222d:	8d 76 00             	lea    0x0(%esi),%esi
  802230:	29 fe                	sub    %edi,%esi
  802232:	19 c3                	sbb    %eax,%ebx
  802234:	89 f2                	mov    %esi,%edx
  802236:	89 d9                	mov    %ebx,%ecx
  802238:	e9 1d ff ff ff       	jmp    80215a <__umoddi3+0x6a>
