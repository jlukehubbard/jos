
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
  800041:	e8 b5 0b 00 00       	call   800bfb <sys_getenvid>
  800046:	83 ec 04             	sub    $0x4,%esp
  800049:	53                   	push   %ebx
  80004a:	50                   	push   %eax
  80004b:	68 00 14 80 00       	push   $0x801400
  800050:	e8 a1 01 00 00       	call   8001f6 <cprintf>

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
  800086:	e8 31 07 00 00       	call   8007bc <strlen>
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
  8000a4:	68 11 14 80 00       	push   $0x801411
  8000a9:	6a 04                	push   $0x4
  8000ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000ae:	50                   	push   %eax
  8000af:	e8 ea 06 00 00       	call   80079e <snprintf>
	if (fork() == 0) {
  8000b4:	83 c4 20             	add    $0x20,%esp
  8000b7:	e8 6b 0e 00 00       	call   800f27 <fork>
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
  8000e0:	68 10 14 80 00       	push   $0x801410
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
  8000fe:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800105:	00 00 00 
    envid_t envid = sys_getenvid();
  800108:	e8 ee 0a 00 00       	call   800bfb <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  80010d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800112:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800115:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011a:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011f:	85 db                	test   %ebx,%ebx
  800121:	7e 07                	jle    80012a <libmain+0x3b>
		binaryname = argv[0];
  800123:	8b 06                	mov    (%esi),%eax
  800125:	a3 00 20 80 00       	mov    %eax,0x802000

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
  80014a:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  80014d:	6a 00                	push   $0x0
  80014f:	e8 62 0a 00 00       	call   800bb6 <sys_env_destroy>
}
  800154:	83 c4 10             	add    $0x10,%esp
  800157:	c9                   	leave  
  800158:	c3                   	ret    

00800159 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800159:	f3 0f 1e fb          	endbr32 
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	53                   	push   %ebx
  800161:	83 ec 04             	sub    $0x4,%esp
  800164:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800167:	8b 13                	mov    (%ebx),%edx
  800169:	8d 42 01             	lea    0x1(%edx),%eax
  80016c:	89 03                	mov    %eax,(%ebx)
  80016e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800171:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800175:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017a:	74 09                	je     800185 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80017c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800180:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800183:	c9                   	leave  
  800184:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800185:	83 ec 08             	sub    $0x8,%esp
  800188:	68 ff 00 00 00       	push   $0xff
  80018d:	8d 43 08             	lea    0x8(%ebx),%eax
  800190:	50                   	push   %eax
  800191:	e8 db 09 00 00       	call   800b71 <sys_cputs>
		b->idx = 0;
  800196:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019c:	83 c4 10             	add    $0x10,%esp
  80019f:	eb db                	jmp    80017c <putch+0x23>

008001a1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a1:	f3 0f 1e fb          	endbr32 
  8001a5:	55                   	push   %ebp
  8001a6:	89 e5                	mov    %esp,%ebp
  8001a8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ae:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b5:	00 00 00 
	b.cnt = 0;
  8001b8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001bf:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c2:	ff 75 0c             	pushl  0xc(%ebp)
  8001c5:	ff 75 08             	pushl  0x8(%ebp)
  8001c8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ce:	50                   	push   %eax
  8001cf:	68 59 01 80 00       	push   $0x800159
  8001d4:	e8 20 01 00 00       	call   8002f9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d9:	83 c4 08             	add    $0x8,%esp
  8001dc:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e8:	50                   	push   %eax
  8001e9:	e8 83 09 00 00       	call   800b71 <sys_cputs>

	return b.cnt;
}
  8001ee:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f4:	c9                   	leave  
  8001f5:	c3                   	ret    

008001f6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f6:	f3 0f 1e fb          	endbr32 
  8001fa:	55                   	push   %ebp
  8001fb:	89 e5                	mov    %esp,%ebp
  8001fd:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800200:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800203:	50                   	push   %eax
  800204:	ff 75 08             	pushl  0x8(%ebp)
  800207:	e8 95 ff ff ff       	call   8001a1 <vcprintf>
	va_end(ap);

	return cnt;
}
  80020c:	c9                   	leave  
  80020d:	c3                   	ret    

0080020e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80020e:	55                   	push   %ebp
  80020f:	89 e5                	mov    %esp,%ebp
  800211:	57                   	push   %edi
  800212:	56                   	push   %esi
  800213:	53                   	push   %ebx
  800214:	83 ec 1c             	sub    $0x1c,%esp
  800217:	89 c7                	mov    %eax,%edi
  800219:	89 d6                	mov    %edx,%esi
  80021b:	8b 45 08             	mov    0x8(%ebp),%eax
  80021e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800221:	89 d1                	mov    %edx,%ecx
  800223:	89 c2                	mov    %eax,%edx
  800225:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800228:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80022b:	8b 45 10             	mov    0x10(%ebp),%eax
  80022e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800231:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800234:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80023b:	39 c2                	cmp    %eax,%edx
  80023d:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800240:	72 3e                	jb     800280 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800242:	83 ec 0c             	sub    $0xc,%esp
  800245:	ff 75 18             	pushl  0x18(%ebp)
  800248:	83 eb 01             	sub    $0x1,%ebx
  80024b:	53                   	push   %ebx
  80024c:	50                   	push   %eax
  80024d:	83 ec 08             	sub    $0x8,%esp
  800250:	ff 75 e4             	pushl  -0x1c(%ebp)
  800253:	ff 75 e0             	pushl  -0x20(%ebp)
  800256:	ff 75 dc             	pushl  -0x24(%ebp)
  800259:	ff 75 d8             	pushl  -0x28(%ebp)
  80025c:	e8 2f 0f 00 00       	call   801190 <__udivdi3>
  800261:	83 c4 18             	add    $0x18,%esp
  800264:	52                   	push   %edx
  800265:	50                   	push   %eax
  800266:	89 f2                	mov    %esi,%edx
  800268:	89 f8                	mov    %edi,%eax
  80026a:	e8 9f ff ff ff       	call   80020e <printnum>
  80026f:	83 c4 20             	add    $0x20,%esp
  800272:	eb 13                	jmp    800287 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800274:	83 ec 08             	sub    $0x8,%esp
  800277:	56                   	push   %esi
  800278:	ff 75 18             	pushl  0x18(%ebp)
  80027b:	ff d7                	call   *%edi
  80027d:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800280:	83 eb 01             	sub    $0x1,%ebx
  800283:	85 db                	test   %ebx,%ebx
  800285:	7f ed                	jg     800274 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800287:	83 ec 08             	sub    $0x8,%esp
  80028a:	56                   	push   %esi
  80028b:	83 ec 04             	sub    $0x4,%esp
  80028e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800291:	ff 75 e0             	pushl  -0x20(%ebp)
  800294:	ff 75 dc             	pushl  -0x24(%ebp)
  800297:	ff 75 d8             	pushl  -0x28(%ebp)
  80029a:	e8 01 10 00 00       	call   8012a0 <__umoddi3>
  80029f:	83 c4 14             	add    $0x14,%esp
  8002a2:	0f be 80 20 14 80 00 	movsbl 0x801420(%eax),%eax
  8002a9:	50                   	push   %eax
  8002aa:	ff d7                	call   *%edi
}
  8002ac:	83 c4 10             	add    $0x10,%esp
  8002af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b2:	5b                   	pop    %ebx
  8002b3:	5e                   	pop    %esi
  8002b4:	5f                   	pop    %edi
  8002b5:	5d                   	pop    %ebp
  8002b6:	c3                   	ret    

008002b7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b7:	f3 0f 1e fb          	endbr32 
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002c5:	8b 10                	mov    (%eax),%edx
  8002c7:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ca:	73 0a                	jae    8002d6 <sprintputch+0x1f>
		*b->buf++ = ch;
  8002cc:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002cf:	89 08                	mov    %ecx,(%eax)
  8002d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d4:	88 02                	mov    %al,(%edx)
}
  8002d6:	5d                   	pop    %ebp
  8002d7:	c3                   	ret    

008002d8 <printfmt>:
{
  8002d8:	f3 0f 1e fb          	endbr32 
  8002dc:	55                   	push   %ebp
  8002dd:	89 e5                	mov    %esp,%ebp
  8002df:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002e2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002e5:	50                   	push   %eax
  8002e6:	ff 75 10             	pushl  0x10(%ebp)
  8002e9:	ff 75 0c             	pushl  0xc(%ebp)
  8002ec:	ff 75 08             	pushl  0x8(%ebp)
  8002ef:	e8 05 00 00 00       	call   8002f9 <vprintfmt>
}
  8002f4:	83 c4 10             	add    $0x10,%esp
  8002f7:	c9                   	leave  
  8002f8:	c3                   	ret    

008002f9 <vprintfmt>:
{
  8002f9:	f3 0f 1e fb          	endbr32 
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	57                   	push   %edi
  800301:	56                   	push   %esi
  800302:	53                   	push   %ebx
  800303:	83 ec 3c             	sub    $0x3c,%esp
  800306:	8b 75 08             	mov    0x8(%ebp),%esi
  800309:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80030c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80030f:	e9 4a 03 00 00       	jmp    80065e <vprintfmt+0x365>
		padc = ' ';
  800314:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800318:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80031f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800326:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80032d:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800332:	8d 47 01             	lea    0x1(%edi),%eax
  800335:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800338:	0f b6 17             	movzbl (%edi),%edx
  80033b:	8d 42 dd             	lea    -0x23(%edx),%eax
  80033e:	3c 55                	cmp    $0x55,%al
  800340:	0f 87 de 03 00 00    	ja     800724 <vprintfmt+0x42b>
  800346:	0f b6 c0             	movzbl %al,%eax
  800349:	3e ff 24 85 60 15 80 	notrack jmp *0x801560(,%eax,4)
  800350:	00 
  800351:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800354:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800358:	eb d8                	jmp    800332 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80035a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80035d:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800361:	eb cf                	jmp    800332 <vprintfmt+0x39>
  800363:	0f b6 d2             	movzbl %dl,%edx
  800366:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800369:	b8 00 00 00 00       	mov    $0x0,%eax
  80036e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800371:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800374:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800378:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80037b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80037e:	83 f9 09             	cmp    $0x9,%ecx
  800381:	77 55                	ja     8003d8 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800383:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800386:	eb e9                	jmp    800371 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800388:	8b 45 14             	mov    0x14(%ebp),%eax
  80038b:	8b 00                	mov    (%eax),%eax
  80038d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800390:	8b 45 14             	mov    0x14(%ebp),%eax
  800393:	8d 40 04             	lea    0x4(%eax),%eax
  800396:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800399:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80039c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003a0:	79 90                	jns    800332 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003a2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003af:	eb 81                	jmp    800332 <vprintfmt+0x39>
  8003b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003b4:	85 c0                	test   %eax,%eax
  8003b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8003bb:	0f 49 d0             	cmovns %eax,%edx
  8003be:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003c4:	e9 69 ff ff ff       	jmp    800332 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003cc:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003d3:	e9 5a ff ff ff       	jmp    800332 <vprintfmt+0x39>
  8003d8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003de:	eb bc                	jmp    80039c <vprintfmt+0xa3>
			lflag++;
  8003e0:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003e6:	e9 47 ff ff ff       	jmp    800332 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ee:	8d 78 04             	lea    0x4(%eax),%edi
  8003f1:	83 ec 08             	sub    $0x8,%esp
  8003f4:	53                   	push   %ebx
  8003f5:	ff 30                	pushl  (%eax)
  8003f7:	ff d6                	call   *%esi
			break;
  8003f9:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003fc:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003ff:	e9 57 02 00 00       	jmp    80065b <vprintfmt+0x362>
			err = va_arg(ap, int);
  800404:	8b 45 14             	mov    0x14(%ebp),%eax
  800407:	8d 78 04             	lea    0x4(%eax),%edi
  80040a:	8b 00                	mov    (%eax),%eax
  80040c:	99                   	cltd   
  80040d:	31 d0                	xor    %edx,%eax
  80040f:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800411:	83 f8 0f             	cmp    $0xf,%eax
  800414:	7f 23                	jg     800439 <vprintfmt+0x140>
  800416:	8b 14 85 c0 16 80 00 	mov    0x8016c0(,%eax,4),%edx
  80041d:	85 d2                	test   %edx,%edx
  80041f:	74 18                	je     800439 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800421:	52                   	push   %edx
  800422:	68 41 14 80 00       	push   $0x801441
  800427:	53                   	push   %ebx
  800428:	56                   	push   %esi
  800429:	e8 aa fe ff ff       	call   8002d8 <printfmt>
  80042e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800431:	89 7d 14             	mov    %edi,0x14(%ebp)
  800434:	e9 22 02 00 00       	jmp    80065b <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  800439:	50                   	push   %eax
  80043a:	68 38 14 80 00       	push   $0x801438
  80043f:	53                   	push   %ebx
  800440:	56                   	push   %esi
  800441:	e8 92 fe ff ff       	call   8002d8 <printfmt>
  800446:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800449:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80044c:	e9 0a 02 00 00       	jmp    80065b <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  800451:	8b 45 14             	mov    0x14(%ebp),%eax
  800454:	83 c0 04             	add    $0x4,%eax
  800457:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80045a:	8b 45 14             	mov    0x14(%ebp),%eax
  80045d:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80045f:	85 d2                	test   %edx,%edx
  800461:	b8 31 14 80 00       	mov    $0x801431,%eax
  800466:	0f 45 c2             	cmovne %edx,%eax
  800469:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80046c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800470:	7e 06                	jle    800478 <vprintfmt+0x17f>
  800472:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800476:	75 0d                	jne    800485 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800478:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80047b:	89 c7                	mov    %eax,%edi
  80047d:	03 45 e0             	add    -0x20(%ebp),%eax
  800480:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800483:	eb 55                	jmp    8004da <vprintfmt+0x1e1>
  800485:	83 ec 08             	sub    $0x8,%esp
  800488:	ff 75 d8             	pushl  -0x28(%ebp)
  80048b:	ff 75 cc             	pushl  -0x34(%ebp)
  80048e:	e8 45 03 00 00       	call   8007d8 <strnlen>
  800493:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800496:	29 c2                	sub    %eax,%edx
  800498:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80049b:	83 c4 10             	add    $0x10,%esp
  80049e:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004a0:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a7:	85 ff                	test   %edi,%edi
  8004a9:	7e 11                	jle    8004bc <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004ab:	83 ec 08             	sub    $0x8,%esp
  8004ae:	53                   	push   %ebx
  8004af:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b2:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b4:	83 ef 01             	sub    $0x1,%edi
  8004b7:	83 c4 10             	add    $0x10,%esp
  8004ba:	eb eb                	jmp    8004a7 <vprintfmt+0x1ae>
  8004bc:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004bf:	85 d2                	test   %edx,%edx
  8004c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c6:	0f 49 c2             	cmovns %edx,%eax
  8004c9:	29 c2                	sub    %eax,%edx
  8004cb:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004ce:	eb a8                	jmp    800478 <vprintfmt+0x17f>
					putch(ch, putdat);
  8004d0:	83 ec 08             	sub    $0x8,%esp
  8004d3:	53                   	push   %ebx
  8004d4:	52                   	push   %edx
  8004d5:	ff d6                	call   *%esi
  8004d7:	83 c4 10             	add    $0x10,%esp
  8004da:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004dd:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004df:	83 c7 01             	add    $0x1,%edi
  8004e2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004e6:	0f be d0             	movsbl %al,%edx
  8004e9:	85 d2                	test   %edx,%edx
  8004eb:	74 4b                	je     800538 <vprintfmt+0x23f>
  8004ed:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004f1:	78 06                	js     8004f9 <vprintfmt+0x200>
  8004f3:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004f7:	78 1e                	js     800517 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004f9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004fd:	74 d1                	je     8004d0 <vprintfmt+0x1d7>
  8004ff:	0f be c0             	movsbl %al,%eax
  800502:	83 e8 20             	sub    $0x20,%eax
  800505:	83 f8 5e             	cmp    $0x5e,%eax
  800508:	76 c6                	jbe    8004d0 <vprintfmt+0x1d7>
					putch('?', putdat);
  80050a:	83 ec 08             	sub    $0x8,%esp
  80050d:	53                   	push   %ebx
  80050e:	6a 3f                	push   $0x3f
  800510:	ff d6                	call   *%esi
  800512:	83 c4 10             	add    $0x10,%esp
  800515:	eb c3                	jmp    8004da <vprintfmt+0x1e1>
  800517:	89 cf                	mov    %ecx,%edi
  800519:	eb 0e                	jmp    800529 <vprintfmt+0x230>
				putch(' ', putdat);
  80051b:	83 ec 08             	sub    $0x8,%esp
  80051e:	53                   	push   %ebx
  80051f:	6a 20                	push   $0x20
  800521:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800523:	83 ef 01             	sub    $0x1,%edi
  800526:	83 c4 10             	add    $0x10,%esp
  800529:	85 ff                	test   %edi,%edi
  80052b:	7f ee                	jg     80051b <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80052d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800530:	89 45 14             	mov    %eax,0x14(%ebp)
  800533:	e9 23 01 00 00       	jmp    80065b <vprintfmt+0x362>
  800538:	89 cf                	mov    %ecx,%edi
  80053a:	eb ed                	jmp    800529 <vprintfmt+0x230>
	if (lflag >= 2)
  80053c:	83 f9 01             	cmp    $0x1,%ecx
  80053f:	7f 1b                	jg     80055c <vprintfmt+0x263>
	else if (lflag)
  800541:	85 c9                	test   %ecx,%ecx
  800543:	74 63                	je     8005a8 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800545:	8b 45 14             	mov    0x14(%ebp),%eax
  800548:	8b 00                	mov    (%eax),%eax
  80054a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054d:	99                   	cltd   
  80054e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800551:	8b 45 14             	mov    0x14(%ebp),%eax
  800554:	8d 40 04             	lea    0x4(%eax),%eax
  800557:	89 45 14             	mov    %eax,0x14(%ebp)
  80055a:	eb 17                	jmp    800573 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80055c:	8b 45 14             	mov    0x14(%ebp),%eax
  80055f:	8b 50 04             	mov    0x4(%eax),%edx
  800562:	8b 00                	mov    (%eax),%eax
  800564:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800567:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80056a:	8b 45 14             	mov    0x14(%ebp),%eax
  80056d:	8d 40 08             	lea    0x8(%eax),%eax
  800570:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800573:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800576:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800579:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80057e:	85 c9                	test   %ecx,%ecx
  800580:	0f 89 bb 00 00 00    	jns    800641 <vprintfmt+0x348>
				putch('-', putdat);
  800586:	83 ec 08             	sub    $0x8,%esp
  800589:	53                   	push   %ebx
  80058a:	6a 2d                	push   $0x2d
  80058c:	ff d6                	call   *%esi
				num = -(long long) num;
  80058e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800591:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800594:	f7 da                	neg    %edx
  800596:	83 d1 00             	adc    $0x0,%ecx
  800599:	f7 d9                	neg    %ecx
  80059b:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80059e:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a3:	e9 99 00 00 00       	jmp    800641 <vprintfmt+0x348>
		return va_arg(*ap, int);
  8005a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ab:	8b 00                	mov    (%eax),%eax
  8005ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b0:	99                   	cltd   
  8005b1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8d 40 04             	lea    0x4(%eax),%eax
  8005ba:	89 45 14             	mov    %eax,0x14(%ebp)
  8005bd:	eb b4                	jmp    800573 <vprintfmt+0x27a>
	if (lflag >= 2)
  8005bf:	83 f9 01             	cmp    $0x1,%ecx
  8005c2:	7f 1b                	jg     8005df <vprintfmt+0x2e6>
	else if (lflag)
  8005c4:	85 c9                	test   %ecx,%ecx
  8005c6:	74 2c                	je     8005f4 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8b 10                	mov    (%eax),%edx
  8005cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d2:	8d 40 04             	lea    0x4(%eax),%eax
  8005d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005d8:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005dd:	eb 62                	jmp    800641 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8b 10                	mov    (%eax),%edx
  8005e4:	8b 48 04             	mov    0x4(%eax),%ecx
  8005e7:	8d 40 08             	lea    0x8(%eax),%eax
  8005ea:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ed:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005f2:	eb 4d                	jmp    800641 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8b 10                	mov    (%eax),%edx
  8005f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005fe:	8d 40 04             	lea    0x4(%eax),%eax
  800601:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800604:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800609:	eb 36                	jmp    800641 <vprintfmt+0x348>
	if (lflag >= 2)
  80060b:	83 f9 01             	cmp    $0x1,%ecx
  80060e:	7f 17                	jg     800627 <vprintfmt+0x32e>
	else if (lflag)
  800610:	85 c9                	test   %ecx,%ecx
  800612:	74 6e                	je     800682 <vprintfmt+0x389>
		return va_arg(*ap, long);
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8b 10                	mov    (%eax),%edx
  800619:	89 d0                	mov    %edx,%eax
  80061b:	99                   	cltd   
  80061c:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80061f:	8d 49 04             	lea    0x4(%ecx),%ecx
  800622:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800625:	eb 11                	jmp    800638 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  800627:	8b 45 14             	mov    0x14(%ebp),%eax
  80062a:	8b 50 04             	mov    0x4(%eax),%edx
  80062d:	8b 00                	mov    (%eax),%eax
  80062f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800632:	8d 49 08             	lea    0x8(%ecx),%ecx
  800635:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800638:	89 d1                	mov    %edx,%ecx
  80063a:	89 c2                	mov    %eax,%edx
            base = 8;
  80063c:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800641:	83 ec 0c             	sub    $0xc,%esp
  800644:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800648:	57                   	push   %edi
  800649:	ff 75 e0             	pushl  -0x20(%ebp)
  80064c:	50                   	push   %eax
  80064d:	51                   	push   %ecx
  80064e:	52                   	push   %edx
  80064f:	89 da                	mov    %ebx,%edx
  800651:	89 f0                	mov    %esi,%eax
  800653:	e8 b6 fb ff ff       	call   80020e <printnum>
			break;
  800658:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80065b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80065e:	83 c7 01             	add    $0x1,%edi
  800661:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800665:	83 f8 25             	cmp    $0x25,%eax
  800668:	0f 84 a6 fc ff ff    	je     800314 <vprintfmt+0x1b>
			if (ch == '\0')
  80066e:	85 c0                	test   %eax,%eax
  800670:	0f 84 ce 00 00 00    	je     800744 <vprintfmt+0x44b>
			putch(ch, putdat);
  800676:	83 ec 08             	sub    $0x8,%esp
  800679:	53                   	push   %ebx
  80067a:	50                   	push   %eax
  80067b:	ff d6                	call   *%esi
  80067d:	83 c4 10             	add    $0x10,%esp
  800680:	eb dc                	jmp    80065e <vprintfmt+0x365>
		return va_arg(*ap, int);
  800682:	8b 45 14             	mov    0x14(%ebp),%eax
  800685:	8b 10                	mov    (%eax),%edx
  800687:	89 d0                	mov    %edx,%eax
  800689:	99                   	cltd   
  80068a:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80068d:	8d 49 04             	lea    0x4(%ecx),%ecx
  800690:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800693:	eb a3                	jmp    800638 <vprintfmt+0x33f>
			putch('0', putdat);
  800695:	83 ec 08             	sub    $0x8,%esp
  800698:	53                   	push   %ebx
  800699:	6a 30                	push   $0x30
  80069b:	ff d6                	call   *%esi
			putch('x', putdat);
  80069d:	83 c4 08             	add    $0x8,%esp
  8006a0:	53                   	push   %ebx
  8006a1:	6a 78                	push   $0x78
  8006a3:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a8:	8b 10                	mov    (%eax),%edx
  8006aa:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006af:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006b2:	8d 40 04             	lea    0x4(%eax),%eax
  8006b5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b8:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006bd:	eb 82                	jmp    800641 <vprintfmt+0x348>
	if (lflag >= 2)
  8006bf:	83 f9 01             	cmp    $0x1,%ecx
  8006c2:	7f 1e                	jg     8006e2 <vprintfmt+0x3e9>
	else if (lflag)
  8006c4:	85 c9                	test   %ecx,%ecx
  8006c6:	74 32                	je     8006fa <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  8006c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cb:	8b 10                	mov    (%eax),%edx
  8006cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d2:	8d 40 04             	lea    0x4(%eax),%eax
  8006d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d8:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006dd:	e9 5f ff ff ff       	jmp    800641 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8006e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e5:	8b 10                	mov    (%eax),%edx
  8006e7:	8b 48 04             	mov    0x4(%eax),%ecx
  8006ea:	8d 40 08             	lea    0x8(%eax),%eax
  8006ed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f0:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006f5:	e9 47 ff ff ff       	jmp    800641 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8006fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fd:	8b 10                	mov    (%eax),%edx
  8006ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800704:	8d 40 04             	lea    0x4(%eax),%eax
  800707:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80070a:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80070f:	e9 2d ff ff ff       	jmp    800641 <vprintfmt+0x348>
			putch(ch, putdat);
  800714:	83 ec 08             	sub    $0x8,%esp
  800717:	53                   	push   %ebx
  800718:	6a 25                	push   $0x25
  80071a:	ff d6                	call   *%esi
			break;
  80071c:	83 c4 10             	add    $0x10,%esp
  80071f:	e9 37 ff ff ff       	jmp    80065b <vprintfmt+0x362>
			putch('%', putdat);
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	53                   	push   %ebx
  800728:	6a 25                	push   $0x25
  80072a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80072c:	83 c4 10             	add    $0x10,%esp
  80072f:	89 f8                	mov    %edi,%eax
  800731:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800735:	74 05                	je     80073c <vprintfmt+0x443>
  800737:	83 e8 01             	sub    $0x1,%eax
  80073a:	eb f5                	jmp    800731 <vprintfmt+0x438>
  80073c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80073f:	e9 17 ff ff ff       	jmp    80065b <vprintfmt+0x362>
}
  800744:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800747:	5b                   	pop    %ebx
  800748:	5e                   	pop    %esi
  800749:	5f                   	pop    %edi
  80074a:	5d                   	pop    %ebp
  80074b:	c3                   	ret    

0080074c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80074c:	f3 0f 1e fb          	endbr32 
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	83 ec 18             	sub    $0x18,%esp
  800756:	8b 45 08             	mov    0x8(%ebp),%eax
  800759:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80075f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800763:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800766:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076d:	85 c0                	test   %eax,%eax
  80076f:	74 26                	je     800797 <vsnprintf+0x4b>
  800771:	85 d2                	test   %edx,%edx
  800773:	7e 22                	jle    800797 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800775:	ff 75 14             	pushl  0x14(%ebp)
  800778:	ff 75 10             	pushl  0x10(%ebp)
  80077b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80077e:	50                   	push   %eax
  80077f:	68 b7 02 80 00       	push   $0x8002b7
  800784:	e8 70 fb ff ff       	call   8002f9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800789:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80078f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800792:	83 c4 10             	add    $0x10,%esp
}
  800795:	c9                   	leave  
  800796:	c3                   	ret    
		return -E_INVAL;
  800797:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80079c:	eb f7                	jmp    800795 <vsnprintf+0x49>

0080079e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80079e:	f3 0f 1e fb          	endbr32 
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ab:	50                   	push   %eax
  8007ac:	ff 75 10             	pushl  0x10(%ebp)
  8007af:	ff 75 0c             	pushl  0xc(%ebp)
  8007b2:	ff 75 08             	pushl  0x8(%ebp)
  8007b5:	e8 92 ff ff ff       	call   80074c <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ba:	c9                   	leave  
  8007bb:	c3                   	ret    

008007bc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007bc:	f3 0f 1e fb          	endbr32 
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007cf:	74 05                	je     8007d6 <strlen+0x1a>
		n++;
  8007d1:	83 c0 01             	add    $0x1,%eax
  8007d4:	eb f5                	jmp    8007cb <strlen+0xf>
	return n;
}
  8007d6:	5d                   	pop    %ebp
  8007d7:	c3                   	ret    

008007d8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d8:	f3 0f 1e fb          	endbr32 
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e2:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ea:	39 d0                	cmp    %edx,%eax
  8007ec:	74 0d                	je     8007fb <strnlen+0x23>
  8007ee:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007f2:	74 05                	je     8007f9 <strnlen+0x21>
		n++;
  8007f4:	83 c0 01             	add    $0x1,%eax
  8007f7:	eb f1                	jmp    8007ea <strnlen+0x12>
  8007f9:	89 c2                	mov    %eax,%edx
	return n;
}
  8007fb:	89 d0                	mov    %edx,%eax
  8007fd:	5d                   	pop    %ebp
  8007fe:	c3                   	ret    

008007ff <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ff:	f3 0f 1e fb          	endbr32 
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	53                   	push   %ebx
  800807:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80080d:	b8 00 00 00 00       	mov    $0x0,%eax
  800812:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800816:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800819:	83 c0 01             	add    $0x1,%eax
  80081c:	84 d2                	test   %dl,%dl
  80081e:	75 f2                	jne    800812 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800820:	89 c8                	mov    %ecx,%eax
  800822:	5b                   	pop    %ebx
  800823:	5d                   	pop    %ebp
  800824:	c3                   	ret    

00800825 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800825:	f3 0f 1e fb          	endbr32 
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
  80082c:	53                   	push   %ebx
  80082d:	83 ec 10             	sub    $0x10,%esp
  800830:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800833:	53                   	push   %ebx
  800834:	e8 83 ff ff ff       	call   8007bc <strlen>
  800839:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80083c:	ff 75 0c             	pushl  0xc(%ebp)
  80083f:	01 d8                	add    %ebx,%eax
  800841:	50                   	push   %eax
  800842:	e8 b8 ff ff ff       	call   8007ff <strcpy>
	return dst;
}
  800847:	89 d8                	mov    %ebx,%eax
  800849:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80084c:	c9                   	leave  
  80084d:	c3                   	ret    

0080084e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80084e:	f3 0f 1e fb          	endbr32 
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	56                   	push   %esi
  800856:	53                   	push   %ebx
  800857:	8b 75 08             	mov    0x8(%ebp),%esi
  80085a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085d:	89 f3                	mov    %esi,%ebx
  80085f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800862:	89 f0                	mov    %esi,%eax
  800864:	39 d8                	cmp    %ebx,%eax
  800866:	74 11                	je     800879 <strncpy+0x2b>
		*dst++ = *src;
  800868:	83 c0 01             	add    $0x1,%eax
  80086b:	0f b6 0a             	movzbl (%edx),%ecx
  80086e:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800871:	80 f9 01             	cmp    $0x1,%cl
  800874:	83 da ff             	sbb    $0xffffffff,%edx
  800877:	eb eb                	jmp    800864 <strncpy+0x16>
	}
	return ret;
}
  800879:	89 f0                	mov    %esi,%eax
  80087b:	5b                   	pop    %ebx
  80087c:	5e                   	pop    %esi
  80087d:	5d                   	pop    %ebp
  80087e:	c3                   	ret    

0080087f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80087f:	f3 0f 1e fb          	endbr32 
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	56                   	push   %esi
  800887:	53                   	push   %ebx
  800888:	8b 75 08             	mov    0x8(%ebp),%esi
  80088b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088e:	8b 55 10             	mov    0x10(%ebp),%edx
  800891:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800893:	85 d2                	test   %edx,%edx
  800895:	74 21                	je     8008b8 <strlcpy+0x39>
  800897:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80089b:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80089d:	39 c2                	cmp    %eax,%edx
  80089f:	74 14                	je     8008b5 <strlcpy+0x36>
  8008a1:	0f b6 19             	movzbl (%ecx),%ebx
  8008a4:	84 db                	test   %bl,%bl
  8008a6:	74 0b                	je     8008b3 <strlcpy+0x34>
			*dst++ = *src++;
  8008a8:	83 c1 01             	add    $0x1,%ecx
  8008ab:	83 c2 01             	add    $0x1,%edx
  8008ae:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008b1:	eb ea                	jmp    80089d <strlcpy+0x1e>
  8008b3:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008b5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008b8:	29 f0                	sub    %esi,%eax
}
  8008ba:	5b                   	pop    %ebx
  8008bb:	5e                   	pop    %esi
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008be:	f3 0f 1e fb          	endbr32 
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008cb:	0f b6 01             	movzbl (%ecx),%eax
  8008ce:	84 c0                	test   %al,%al
  8008d0:	74 0c                	je     8008de <strcmp+0x20>
  8008d2:	3a 02                	cmp    (%edx),%al
  8008d4:	75 08                	jne    8008de <strcmp+0x20>
		p++, q++;
  8008d6:	83 c1 01             	add    $0x1,%ecx
  8008d9:	83 c2 01             	add    $0x1,%edx
  8008dc:	eb ed                	jmp    8008cb <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008de:	0f b6 c0             	movzbl %al,%eax
  8008e1:	0f b6 12             	movzbl (%edx),%edx
  8008e4:	29 d0                	sub    %edx,%eax
}
  8008e6:	5d                   	pop    %ebp
  8008e7:	c3                   	ret    

008008e8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e8:	f3 0f 1e fb          	endbr32 
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	53                   	push   %ebx
  8008f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f6:	89 c3                	mov    %eax,%ebx
  8008f8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008fb:	eb 06                	jmp    800903 <strncmp+0x1b>
		n--, p++, q++;
  8008fd:	83 c0 01             	add    $0x1,%eax
  800900:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800903:	39 d8                	cmp    %ebx,%eax
  800905:	74 16                	je     80091d <strncmp+0x35>
  800907:	0f b6 08             	movzbl (%eax),%ecx
  80090a:	84 c9                	test   %cl,%cl
  80090c:	74 04                	je     800912 <strncmp+0x2a>
  80090e:	3a 0a                	cmp    (%edx),%cl
  800910:	74 eb                	je     8008fd <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800912:	0f b6 00             	movzbl (%eax),%eax
  800915:	0f b6 12             	movzbl (%edx),%edx
  800918:	29 d0                	sub    %edx,%eax
}
  80091a:	5b                   	pop    %ebx
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    
		return 0;
  80091d:	b8 00 00 00 00       	mov    $0x0,%eax
  800922:	eb f6                	jmp    80091a <strncmp+0x32>

00800924 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800924:	f3 0f 1e fb          	endbr32 
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800932:	0f b6 10             	movzbl (%eax),%edx
  800935:	84 d2                	test   %dl,%dl
  800937:	74 09                	je     800942 <strchr+0x1e>
		if (*s == c)
  800939:	38 ca                	cmp    %cl,%dl
  80093b:	74 0a                	je     800947 <strchr+0x23>
	for (; *s; s++)
  80093d:	83 c0 01             	add    $0x1,%eax
  800940:	eb f0                	jmp    800932 <strchr+0xe>
			return (char *) s;
	return 0;
  800942:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    

00800949 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800949:	f3 0f 1e fb          	endbr32 
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	8b 45 08             	mov    0x8(%ebp),%eax
  800953:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800957:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80095a:	38 ca                	cmp    %cl,%dl
  80095c:	74 09                	je     800967 <strfind+0x1e>
  80095e:	84 d2                	test   %dl,%dl
  800960:	74 05                	je     800967 <strfind+0x1e>
	for (; *s; s++)
  800962:	83 c0 01             	add    $0x1,%eax
  800965:	eb f0                	jmp    800957 <strfind+0xe>
			break;
	return (char *) s;
}
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    

00800969 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800969:	f3 0f 1e fb          	endbr32 
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	57                   	push   %edi
  800971:	56                   	push   %esi
  800972:	53                   	push   %ebx
  800973:	8b 7d 08             	mov    0x8(%ebp),%edi
  800976:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800979:	85 c9                	test   %ecx,%ecx
  80097b:	74 31                	je     8009ae <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80097d:	89 f8                	mov    %edi,%eax
  80097f:	09 c8                	or     %ecx,%eax
  800981:	a8 03                	test   $0x3,%al
  800983:	75 23                	jne    8009a8 <memset+0x3f>
		c &= 0xFF;
  800985:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800989:	89 d3                	mov    %edx,%ebx
  80098b:	c1 e3 08             	shl    $0x8,%ebx
  80098e:	89 d0                	mov    %edx,%eax
  800990:	c1 e0 18             	shl    $0x18,%eax
  800993:	89 d6                	mov    %edx,%esi
  800995:	c1 e6 10             	shl    $0x10,%esi
  800998:	09 f0                	or     %esi,%eax
  80099a:	09 c2                	or     %eax,%edx
  80099c:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80099e:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009a1:	89 d0                	mov    %edx,%eax
  8009a3:	fc                   	cld    
  8009a4:	f3 ab                	rep stos %eax,%es:(%edi)
  8009a6:	eb 06                	jmp    8009ae <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ab:	fc                   	cld    
  8009ac:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ae:	89 f8                	mov    %edi,%eax
  8009b0:	5b                   	pop    %ebx
  8009b1:	5e                   	pop    %esi
  8009b2:	5f                   	pop    %edi
  8009b3:	5d                   	pop    %ebp
  8009b4:	c3                   	ret    

008009b5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009b5:	f3 0f 1e fb          	endbr32 
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	57                   	push   %edi
  8009bd:	56                   	push   %esi
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009c4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009c7:	39 c6                	cmp    %eax,%esi
  8009c9:	73 32                	jae    8009fd <memmove+0x48>
  8009cb:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ce:	39 c2                	cmp    %eax,%edx
  8009d0:	76 2b                	jbe    8009fd <memmove+0x48>
		s += n;
		d += n;
  8009d2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d5:	89 fe                	mov    %edi,%esi
  8009d7:	09 ce                	or     %ecx,%esi
  8009d9:	09 d6                	or     %edx,%esi
  8009db:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009e1:	75 0e                	jne    8009f1 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009e3:	83 ef 04             	sub    $0x4,%edi
  8009e6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009e9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009ec:	fd                   	std    
  8009ed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ef:	eb 09                	jmp    8009fa <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009f1:	83 ef 01             	sub    $0x1,%edi
  8009f4:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009f7:	fd                   	std    
  8009f8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009fa:	fc                   	cld    
  8009fb:	eb 1a                	jmp    800a17 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009fd:	89 c2                	mov    %eax,%edx
  8009ff:	09 ca                	or     %ecx,%edx
  800a01:	09 f2                	or     %esi,%edx
  800a03:	f6 c2 03             	test   $0x3,%dl
  800a06:	75 0a                	jne    800a12 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a08:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a0b:	89 c7                	mov    %eax,%edi
  800a0d:	fc                   	cld    
  800a0e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a10:	eb 05                	jmp    800a17 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a12:	89 c7                	mov    %eax,%edi
  800a14:	fc                   	cld    
  800a15:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a17:	5e                   	pop    %esi
  800a18:	5f                   	pop    %edi
  800a19:	5d                   	pop    %ebp
  800a1a:	c3                   	ret    

00800a1b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a1b:	f3 0f 1e fb          	endbr32 
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a25:	ff 75 10             	pushl  0x10(%ebp)
  800a28:	ff 75 0c             	pushl  0xc(%ebp)
  800a2b:	ff 75 08             	pushl  0x8(%ebp)
  800a2e:	e8 82 ff ff ff       	call   8009b5 <memmove>
}
  800a33:	c9                   	leave  
  800a34:	c3                   	ret    

00800a35 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a35:	f3 0f 1e fb          	endbr32 
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	56                   	push   %esi
  800a3d:	53                   	push   %ebx
  800a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a41:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a44:	89 c6                	mov    %eax,%esi
  800a46:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a49:	39 f0                	cmp    %esi,%eax
  800a4b:	74 1c                	je     800a69 <memcmp+0x34>
		if (*s1 != *s2)
  800a4d:	0f b6 08             	movzbl (%eax),%ecx
  800a50:	0f b6 1a             	movzbl (%edx),%ebx
  800a53:	38 d9                	cmp    %bl,%cl
  800a55:	75 08                	jne    800a5f <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a57:	83 c0 01             	add    $0x1,%eax
  800a5a:	83 c2 01             	add    $0x1,%edx
  800a5d:	eb ea                	jmp    800a49 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a5f:	0f b6 c1             	movzbl %cl,%eax
  800a62:	0f b6 db             	movzbl %bl,%ebx
  800a65:	29 d8                	sub    %ebx,%eax
  800a67:	eb 05                	jmp    800a6e <memcmp+0x39>
	}

	return 0;
  800a69:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a6e:	5b                   	pop    %ebx
  800a6f:	5e                   	pop    %esi
  800a70:	5d                   	pop    %ebp
  800a71:	c3                   	ret    

00800a72 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a72:	f3 0f 1e fb          	endbr32 
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a7f:	89 c2                	mov    %eax,%edx
  800a81:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a84:	39 d0                	cmp    %edx,%eax
  800a86:	73 09                	jae    800a91 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a88:	38 08                	cmp    %cl,(%eax)
  800a8a:	74 05                	je     800a91 <memfind+0x1f>
	for (; s < ends; s++)
  800a8c:	83 c0 01             	add    $0x1,%eax
  800a8f:	eb f3                	jmp    800a84 <memfind+0x12>
			break;
	return (void *) s;
}
  800a91:	5d                   	pop    %ebp
  800a92:	c3                   	ret    

00800a93 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a93:	f3 0f 1e fb          	endbr32 
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	57                   	push   %edi
  800a9b:	56                   	push   %esi
  800a9c:	53                   	push   %ebx
  800a9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa3:	eb 03                	jmp    800aa8 <strtol+0x15>
		s++;
  800aa5:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800aa8:	0f b6 01             	movzbl (%ecx),%eax
  800aab:	3c 20                	cmp    $0x20,%al
  800aad:	74 f6                	je     800aa5 <strtol+0x12>
  800aaf:	3c 09                	cmp    $0x9,%al
  800ab1:	74 f2                	je     800aa5 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800ab3:	3c 2b                	cmp    $0x2b,%al
  800ab5:	74 2a                	je     800ae1 <strtol+0x4e>
	int neg = 0;
  800ab7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800abc:	3c 2d                	cmp    $0x2d,%al
  800abe:	74 2b                	je     800aeb <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ac6:	75 0f                	jne    800ad7 <strtol+0x44>
  800ac8:	80 39 30             	cmpb   $0x30,(%ecx)
  800acb:	74 28                	je     800af5 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800acd:	85 db                	test   %ebx,%ebx
  800acf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ad4:	0f 44 d8             	cmove  %eax,%ebx
  800ad7:	b8 00 00 00 00       	mov    $0x0,%eax
  800adc:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800adf:	eb 46                	jmp    800b27 <strtol+0x94>
		s++;
  800ae1:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ae4:	bf 00 00 00 00       	mov    $0x0,%edi
  800ae9:	eb d5                	jmp    800ac0 <strtol+0x2d>
		s++, neg = 1;
  800aeb:	83 c1 01             	add    $0x1,%ecx
  800aee:	bf 01 00 00 00       	mov    $0x1,%edi
  800af3:	eb cb                	jmp    800ac0 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800af5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800af9:	74 0e                	je     800b09 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800afb:	85 db                	test   %ebx,%ebx
  800afd:	75 d8                	jne    800ad7 <strtol+0x44>
		s++, base = 8;
  800aff:	83 c1 01             	add    $0x1,%ecx
  800b02:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b07:	eb ce                	jmp    800ad7 <strtol+0x44>
		s += 2, base = 16;
  800b09:	83 c1 02             	add    $0x2,%ecx
  800b0c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b11:	eb c4                	jmp    800ad7 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b13:	0f be d2             	movsbl %dl,%edx
  800b16:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b19:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b1c:	7d 3a                	jge    800b58 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b1e:	83 c1 01             	add    $0x1,%ecx
  800b21:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b25:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b27:	0f b6 11             	movzbl (%ecx),%edx
  800b2a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b2d:	89 f3                	mov    %esi,%ebx
  800b2f:	80 fb 09             	cmp    $0x9,%bl
  800b32:	76 df                	jbe    800b13 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b34:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b37:	89 f3                	mov    %esi,%ebx
  800b39:	80 fb 19             	cmp    $0x19,%bl
  800b3c:	77 08                	ja     800b46 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b3e:	0f be d2             	movsbl %dl,%edx
  800b41:	83 ea 57             	sub    $0x57,%edx
  800b44:	eb d3                	jmp    800b19 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b46:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b49:	89 f3                	mov    %esi,%ebx
  800b4b:	80 fb 19             	cmp    $0x19,%bl
  800b4e:	77 08                	ja     800b58 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b50:	0f be d2             	movsbl %dl,%edx
  800b53:	83 ea 37             	sub    $0x37,%edx
  800b56:	eb c1                	jmp    800b19 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b58:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b5c:	74 05                	je     800b63 <strtol+0xd0>
		*endptr = (char *) s;
  800b5e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b61:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b63:	89 c2                	mov    %eax,%edx
  800b65:	f7 da                	neg    %edx
  800b67:	85 ff                	test   %edi,%edi
  800b69:	0f 45 c2             	cmovne %edx,%eax
}
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5f                   	pop    %edi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b71:	f3 0f 1e fb          	endbr32 
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	57                   	push   %edi
  800b79:	56                   	push   %esi
  800b7a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b80:	8b 55 08             	mov    0x8(%ebp),%edx
  800b83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b86:	89 c3                	mov    %eax,%ebx
  800b88:	89 c7                	mov    %eax,%edi
  800b8a:	89 c6                	mov    %eax,%esi
  800b8c:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b8e:	5b                   	pop    %ebx
  800b8f:	5e                   	pop    %esi
  800b90:	5f                   	pop    %edi
  800b91:	5d                   	pop    %ebp
  800b92:	c3                   	ret    

00800b93 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b93:	f3 0f 1e fb          	endbr32 
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	57                   	push   %edi
  800b9b:	56                   	push   %esi
  800b9c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ba7:	89 d1                	mov    %edx,%ecx
  800ba9:	89 d3                	mov    %edx,%ebx
  800bab:	89 d7                	mov    %edx,%edi
  800bad:	89 d6                	mov    %edx,%esi
  800baf:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5f                   	pop    %edi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bb6:	f3 0f 1e fb          	endbr32 
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	57                   	push   %edi
  800bbe:	56                   	push   %esi
  800bbf:	53                   	push   %ebx
  800bc0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bc3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcb:	b8 03 00 00 00       	mov    $0x3,%eax
  800bd0:	89 cb                	mov    %ecx,%ebx
  800bd2:	89 cf                	mov    %ecx,%edi
  800bd4:	89 ce                	mov    %ecx,%esi
  800bd6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bd8:	85 c0                	test   %eax,%eax
  800bda:	7f 08                	jg     800be4 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdf:	5b                   	pop    %ebx
  800be0:	5e                   	pop    %esi
  800be1:	5f                   	pop    %edi
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800be4:	83 ec 0c             	sub    $0xc,%esp
  800be7:	50                   	push   %eax
  800be8:	6a 03                	push   $0x3
  800bea:	68 1f 17 80 00       	push   $0x80171f
  800bef:	6a 23                	push   $0x23
  800bf1:	68 3c 17 80 00       	push   $0x80173c
  800bf6:	e8 a3 04 00 00       	call   80109e <_panic>

00800bfb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bfb:	f3 0f 1e fb          	endbr32 
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	57                   	push   %edi
  800c03:	56                   	push   %esi
  800c04:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c05:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0a:	b8 02 00 00 00       	mov    $0x2,%eax
  800c0f:	89 d1                	mov    %edx,%ecx
  800c11:	89 d3                	mov    %edx,%ebx
  800c13:	89 d7                	mov    %edx,%edi
  800c15:	89 d6                	mov    %edx,%esi
  800c17:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <sys_yield>:

void
sys_yield(void)
{
  800c1e:	f3 0f 1e fb          	endbr32 
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c28:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c32:	89 d1                	mov    %edx,%ecx
  800c34:	89 d3                	mov    %edx,%ebx
  800c36:	89 d7                	mov    %edx,%edi
  800c38:	89 d6                	mov    %edx,%esi
  800c3a:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c3c:	5b                   	pop    %ebx
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c41:	f3 0f 1e fb          	endbr32 
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	57                   	push   %edi
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
  800c4b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c4e:	be 00 00 00 00       	mov    $0x0,%esi
  800c53:	8b 55 08             	mov    0x8(%ebp),%edx
  800c56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c59:	b8 04 00 00 00       	mov    $0x4,%eax
  800c5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c61:	89 f7                	mov    %esi,%edi
  800c63:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c65:	85 c0                	test   %eax,%eax
  800c67:	7f 08                	jg     800c71 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6c:	5b                   	pop    %ebx
  800c6d:	5e                   	pop    %esi
  800c6e:	5f                   	pop    %edi
  800c6f:	5d                   	pop    %ebp
  800c70:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c71:	83 ec 0c             	sub    $0xc,%esp
  800c74:	50                   	push   %eax
  800c75:	6a 04                	push   $0x4
  800c77:	68 1f 17 80 00       	push   $0x80171f
  800c7c:	6a 23                	push   $0x23
  800c7e:	68 3c 17 80 00       	push   $0x80173c
  800c83:	e8 16 04 00 00       	call   80109e <_panic>

00800c88 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c88:	f3 0f 1e fb          	endbr32 
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	57                   	push   %edi
  800c90:	56                   	push   %esi
  800c91:	53                   	push   %ebx
  800c92:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c95:	8b 55 08             	mov    0x8(%ebp),%edx
  800c98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9b:	b8 05 00 00 00       	mov    $0x5,%eax
  800ca0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca6:	8b 75 18             	mov    0x18(%ebp),%esi
  800ca9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cab:	85 c0                	test   %eax,%eax
  800cad:	7f 08                	jg     800cb7 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800caf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb2:	5b                   	pop    %ebx
  800cb3:	5e                   	pop    %esi
  800cb4:	5f                   	pop    %edi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb7:	83 ec 0c             	sub    $0xc,%esp
  800cba:	50                   	push   %eax
  800cbb:	6a 05                	push   $0x5
  800cbd:	68 1f 17 80 00       	push   $0x80171f
  800cc2:	6a 23                	push   $0x23
  800cc4:	68 3c 17 80 00       	push   $0x80173c
  800cc9:	e8 d0 03 00 00       	call   80109e <_panic>

00800cce <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cce:	f3 0f 1e fb          	endbr32 
  800cd2:	55                   	push   %ebp
  800cd3:	89 e5                	mov    %esp,%ebp
  800cd5:	57                   	push   %edi
  800cd6:	56                   	push   %esi
  800cd7:	53                   	push   %ebx
  800cd8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cdb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce6:	b8 06 00 00 00       	mov    $0x6,%eax
  800ceb:	89 df                	mov    %ebx,%edi
  800ced:	89 de                	mov    %ebx,%esi
  800cef:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf1:	85 c0                	test   %eax,%eax
  800cf3:	7f 08                	jg     800cfd <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf8:	5b                   	pop    %ebx
  800cf9:	5e                   	pop    %esi
  800cfa:	5f                   	pop    %edi
  800cfb:	5d                   	pop    %ebp
  800cfc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfd:	83 ec 0c             	sub    $0xc,%esp
  800d00:	50                   	push   %eax
  800d01:	6a 06                	push   $0x6
  800d03:	68 1f 17 80 00       	push   $0x80171f
  800d08:	6a 23                	push   $0x23
  800d0a:	68 3c 17 80 00       	push   $0x80173c
  800d0f:	e8 8a 03 00 00       	call   80109e <_panic>

00800d14 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d14:	f3 0f 1e fb          	endbr32 
  800d18:	55                   	push   %ebp
  800d19:	89 e5                	mov    %esp,%ebp
  800d1b:	57                   	push   %edi
  800d1c:	56                   	push   %esi
  800d1d:	53                   	push   %ebx
  800d1e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d21:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d26:	8b 55 08             	mov    0x8(%ebp),%edx
  800d29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2c:	b8 08 00 00 00       	mov    $0x8,%eax
  800d31:	89 df                	mov    %ebx,%edi
  800d33:	89 de                	mov    %ebx,%esi
  800d35:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d37:	85 c0                	test   %eax,%eax
  800d39:	7f 08                	jg     800d43 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3e:	5b                   	pop    %ebx
  800d3f:	5e                   	pop    %esi
  800d40:	5f                   	pop    %edi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d43:	83 ec 0c             	sub    $0xc,%esp
  800d46:	50                   	push   %eax
  800d47:	6a 08                	push   $0x8
  800d49:	68 1f 17 80 00       	push   $0x80171f
  800d4e:	6a 23                	push   $0x23
  800d50:	68 3c 17 80 00       	push   $0x80173c
  800d55:	e8 44 03 00 00       	call   80109e <_panic>

00800d5a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d5a:	f3 0f 1e fb          	endbr32 
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d67:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d72:	b8 09 00 00 00       	mov    $0x9,%eax
  800d77:	89 df                	mov    %ebx,%edi
  800d79:	89 de                	mov    %ebx,%esi
  800d7b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	7f 08                	jg     800d89 <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5f                   	pop    %edi
  800d87:	5d                   	pop    %ebp
  800d88:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d89:	83 ec 0c             	sub    $0xc,%esp
  800d8c:	50                   	push   %eax
  800d8d:	6a 09                	push   $0x9
  800d8f:	68 1f 17 80 00       	push   $0x80171f
  800d94:	6a 23                	push   $0x23
  800d96:	68 3c 17 80 00       	push   $0x80173c
  800d9b:	e8 fe 02 00 00       	call   80109e <_panic>

00800da0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800da0:	f3 0f 1e fb          	endbr32 
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	57                   	push   %edi
  800da8:	56                   	push   %esi
  800da9:	53                   	push   %ebx
  800daa:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dad:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db2:	8b 55 08             	mov    0x8(%ebp),%edx
  800db5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dbd:	89 df                	mov    %ebx,%edi
  800dbf:	89 de                	mov    %ebx,%esi
  800dc1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dc3:	85 c0                	test   %eax,%eax
  800dc5:	7f 08                	jg     800dcf <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dca:	5b                   	pop    %ebx
  800dcb:	5e                   	pop    %esi
  800dcc:	5f                   	pop    %edi
  800dcd:	5d                   	pop    %ebp
  800dce:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcf:	83 ec 0c             	sub    $0xc,%esp
  800dd2:	50                   	push   %eax
  800dd3:	6a 0a                	push   $0xa
  800dd5:	68 1f 17 80 00       	push   $0x80171f
  800dda:	6a 23                	push   $0x23
  800ddc:	68 3c 17 80 00       	push   $0x80173c
  800de1:	e8 b8 02 00 00       	call   80109e <_panic>

00800de6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800de6:	f3 0f 1e fb          	endbr32 
  800dea:	55                   	push   %ebp
  800deb:	89 e5                	mov    %esp,%ebp
  800ded:	57                   	push   %edi
  800dee:	56                   	push   %esi
  800def:	53                   	push   %ebx
	asm volatile("int %1\n"
  800df0:	8b 55 08             	mov    0x8(%ebp),%edx
  800df3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dfb:	be 00 00 00 00       	mov    $0x0,%esi
  800e00:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e03:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e06:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e08:	5b                   	pop    %ebx
  800e09:	5e                   	pop    %esi
  800e0a:	5f                   	pop    %edi
  800e0b:	5d                   	pop    %ebp
  800e0c:	c3                   	ret    

00800e0d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e0d:	f3 0f 1e fb          	endbr32 
  800e11:	55                   	push   %ebp
  800e12:	89 e5                	mov    %esp,%ebp
  800e14:	57                   	push   %edi
  800e15:	56                   	push   %esi
  800e16:	53                   	push   %ebx
  800e17:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e1a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e22:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e27:	89 cb                	mov    %ecx,%ebx
  800e29:	89 cf                	mov    %ecx,%edi
  800e2b:	89 ce                	mov    %ecx,%esi
  800e2d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e2f:	85 c0                	test   %eax,%eax
  800e31:	7f 08                	jg     800e3b <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e36:	5b                   	pop    %ebx
  800e37:	5e                   	pop    %esi
  800e38:	5f                   	pop    %edi
  800e39:	5d                   	pop    %ebp
  800e3a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3b:	83 ec 0c             	sub    $0xc,%esp
  800e3e:	50                   	push   %eax
  800e3f:	6a 0d                	push   $0xd
  800e41:	68 1f 17 80 00       	push   $0x80171f
  800e46:	6a 23                	push   $0x23
  800e48:	68 3c 17 80 00       	push   $0x80173c
  800e4d:	e8 4c 02 00 00       	call   80109e <_panic>

00800e52 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e52:	f3 0f 1e fb          	endbr32 
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	53                   	push   %ebx
  800e5a:	83 ec 04             	sub    $0x4,%esp
  800e5d:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e60:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if ( !(err & FEC_WR) ||
  800e62:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e66:	74 75                	je     800edd <pgfault+0x8b>
            !(uvpt[PGNUM(addr)] | PTE_COW) ) {
  800e68:	89 d8                	mov    %ebx,%eax
  800e6a:	c1 e8 0c             	shr    $0xc,%eax
  800e6d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, (void *)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0) {
  800e74:	83 ec 04             	sub    $0x4,%esp
  800e77:	6a 07                	push   $0x7
  800e79:	68 00 f0 7f 00       	push   $0x7ff000
  800e7e:	6a 00                	push   $0x0
  800e80:	e8 bc fd ff ff       	call   800c41 <sys_page_alloc>
  800e85:	83 c4 10             	add    $0x10,%esp
  800e88:	85 c0                	test   %eax,%eax
  800e8a:	78 65                	js     800ef1 <pgfault+0x9f>
        panic("sys_page_alloc failed %e\n", r);
    }
    memmove((void *)PFTEMP, (void *)PTE_ADDR(addr), PGSIZE);
  800e8c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800e92:	83 ec 04             	sub    $0x4,%esp
  800e95:	68 00 10 00 00       	push   $0x1000
  800e9a:	53                   	push   %ebx
  800e9b:	68 00 f0 7f 00       	push   $0x7ff000
  800ea0:	e8 10 fb ff ff       	call   8009b5 <memmove>
    if ((r = sys_page_map(0, (void *)PFTEMP,
  800ea5:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800eac:	53                   	push   %ebx
  800ead:	6a 00                	push   $0x0
  800eaf:	68 00 f0 7f 00       	push   $0x7ff000
  800eb4:	6a 00                	push   $0x0
  800eb6:	e8 cd fd ff ff       	call   800c88 <sys_page_map>
  800ebb:	83 c4 20             	add    $0x20,%esp
  800ebe:	85 c0                	test   %eax,%eax
  800ec0:	78 41                	js     800f03 <pgfault+0xb1>
                0, (void *)PTE_ADDR(addr), PTE_P | PTE_U | PTE_W)) < 0) {
        panic("sys_page_map failed %e\n", r);
    }
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0) {
  800ec2:	83 ec 08             	sub    $0x8,%esp
  800ec5:	68 00 f0 7f 00       	push   $0x7ff000
  800eca:	6a 00                	push   $0x0
  800ecc:	e8 fd fd ff ff       	call   800cce <sys_page_unmap>
  800ed1:	83 c4 10             	add    $0x10,%esp
  800ed4:	85 c0                	test   %eax,%eax
  800ed6:	78 3d                	js     800f15 <pgfault+0xc3>
        panic("sys_page_unmap failed %e\n", r);
    }

}
  800ed8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800edb:	c9                   	leave  
  800edc:	c3                   	ret    
        panic("Not a copy-on-write page");
  800edd:	83 ec 04             	sub    $0x4,%esp
  800ee0:	68 4a 17 80 00       	push   $0x80174a
  800ee5:	6a 1e                	push   $0x1e
  800ee7:	68 63 17 80 00       	push   $0x801763
  800eec:	e8 ad 01 00 00       	call   80109e <_panic>
        panic("sys_page_alloc failed %e\n", r);
  800ef1:	50                   	push   %eax
  800ef2:	68 6e 17 80 00       	push   $0x80176e
  800ef7:	6a 2a                	push   $0x2a
  800ef9:	68 63 17 80 00       	push   $0x801763
  800efe:	e8 9b 01 00 00       	call   80109e <_panic>
        panic("sys_page_map failed %e\n", r);
  800f03:	50                   	push   %eax
  800f04:	68 88 17 80 00       	push   $0x801788
  800f09:	6a 2f                	push   $0x2f
  800f0b:	68 63 17 80 00       	push   $0x801763
  800f10:	e8 89 01 00 00       	call   80109e <_panic>
        panic("sys_page_unmap failed %e\n", r);
  800f15:	50                   	push   %eax
  800f16:	68 a0 17 80 00       	push   $0x8017a0
  800f1b:	6a 32                	push   $0x32
  800f1d:	68 63 17 80 00       	push   $0x801763
  800f22:	e8 77 01 00 00       	call   80109e <_panic>

00800f27 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f27:	f3 0f 1e fb          	endbr32 
  800f2b:	55                   	push   %ebp
  800f2c:	89 e5                	mov    %esp,%ebp
  800f2e:	57                   	push   %edi
  800f2f:	56                   	push   %esi
  800f30:	53                   	push   %ebx
  800f31:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");

    // 1. set pgfault handler.
    set_pgfault_handler(pgfault);
  800f34:	68 52 0e 80 00       	push   $0x800e52
  800f39:	e8 aa 01 00 00       	call   8010e8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f3e:	b8 07 00 00 00       	mov    $0x7,%eax
  800f43:	cd 30                	int    $0x30
  800f45:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f48:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    // 2. exofork.
    envid_t envid = sys_exofork();

    if (envid < 0)
  800f4b:	83 c4 10             	add    $0x10,%esp
  800f4e:	85 c0                	test   %eax,%eax
  800f50:	78 2a                	js     800f7c <fork+0x55>
        thisenv = &envs[ENVX(my_envid)];
        return 0;
    }
    else {
        // parent
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800f52:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (envid == 0) {
  800f57:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800f5b:	75 69                	jne    800fc6 <fork+0x9f>
        envid_t my_envid = sys_getenvid();
  800f5d:	e8 99 fc ff ff       	call   800bfb <sys_getenvid>
        thisenv = &envs[ENVX(my_envid)];
  800f62:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f67:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f6a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f6f:	a3 04 20 80 00       	mov    %eax,0x802004
        return 0;
  800f74:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f77:	e9 fc 00 00 00       	jmp    801078 <fork+0x151>
        panic("fork, sys_exofork %e", envid);
  800f7c:	50                   	push   %eax
  800f7d:	68 ba 17 80 00       	push   $0x8017ba
  800f82:	6a 7b                	push   $0x7b
  800f84:	68 63 17 80 00       	push   $0x801763
  800f89:	e8 10 01 00 00       	call   80109e <_panic>
    if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0) {
  800f8e:	83 ec 0c             	sub    $0xc,%esp
  800f91:	57                   	push   %edi
  800f92:	56                   	push   %esi
  800f93:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f96:	56                   	push   %esi
  800f97:	6a 00                	push   $0x0
  800f99:	e8 ea fc ff ff       	call   800c88 <sys_page_map>
  800f9e:	83 c4 20             	add    $0x20,%esp
  800fa1:	85 c0                	test   %eax,%eax
  800fa3:	78 69                	js     80100e <fork+0xe7>
        if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0) {
  800fa5:	83 ec 0c             	sub    $0xc,%esp
  800fa8:	57                   	push   %edi
  800fa9:	56                   	push   %esi
  800faa:	6a 00                	push   $0x0
  800fac:	56                   	push   %esi
  800fad:	6a 00                	push   $0x0
  800faf:	e8 d4 fc ff ff       	call   800c88 <sys_page_map>
  800fb4:	83 c4 20             	add    $0x20,%esp
  800fb7:	85 c0                	test   %eax,%eax
  800fb9:	78 65                	js     801020 <fork+0xf9>
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800fbb:	83 c3 01             	add    $0x1,%ebx
  800fbe:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  800fc4:	74 6c                	je     801032 <fork+0x10b>
  800fc6:	89 de                	mov    %ebx,%esi
  800fc8:	c1 e6 0c             	shl    $0xc,%esi
            uintptr_t pgaddr = pn << PGSHIFT;
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800fcb:	89 f0                	mov    %esi,%eax
  800fcd:	c1 e8 16             	shr    $0x16,%eax
  800fd0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fd7:	a8 01                	test   $0x1,%al
  800fd9:	74 e0                	je     800fbb <fork+0x94>
                    (uvpt[pn] & PTE_P) ) {
  800fdb:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800fe2:	a8 01                	test   $0x1,%al
  800fe4:	74 d5                	je     800fbb <fork+0x94>
    pte_t pte = uvpt[pn];
  800fe6:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
    int perm = PTE_U | PTE_P;
  800fed:	bf 05 00 00 00       	mov    $0x5,%edi
    if ( ((pte & PTE_W) || (pte & PTE_COW)) && !(pte & PTE_SHARE)) {
  800ff2:	a9 02 08 00 00       	test   $0x802,%eax
  800ff7:	74 95                	je     800f8e <fork+0x67>
  800ff9:	25 00 04 00 00       	and    $0x400,%eax
        perm |= PTE_COW;
  800ffe:	83 f8 01             	cmp    $0x1,%eax
  801001:	19 ff                	sbb    %edi,%edi
  801003:	81 e7 00 08 00 00    	and    $0x800,%edi
  801009:	83 c7 05             	add    $0x5,%edi
  80100c:	eb 80                	jmp    800f8e <fork+0x67>
        panic("sys_page_map others failed %e\n", r);
  80100e:	50                   	push   %eax
  80100f:	68 04 18 80 00       	push   $0x801804
  801014:	6a 51                	push   $0x51
  801016:	68 63 17 80 00       	push   $0x801763
  80101b:	e8 7e 00 00 00       	call   80109e <_panic>
            panic("sys_page_map mine failed %e\n", r);
  801020:	50                   	push   %eax
  801021:	68 cf 17 80 00       	push   $0x8017cf
  801026:	6a 56                	push   $0x56
  801028:	68 63 17 80 00       	push   $0x801763
  80102d:	e8 6c 00 00 00       	call   80109e <_panic>
            }
        }

        int r;

        if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE),
  801032:	83 ec 04             	sub    $0x4,%esp
  801035:	6a 07                	push   $0x7
  801037:	68 00 f0 bf ee       	push   $0xeebff000
  80103c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80103f:	57                   	push   %edi
  801040:	e8 fc fb ff ff       	call   800c41 <sys_page_alloc>
  801045:	83 c4 10             	add    $0x10,%esp
  801048:	85 c0                	test   %eax,%eax
  80104a:	78 2c                	js     801078 <fork+0x151>
                    PTE_U | PTE_W | PTE_P)) < 0) {
            return r;
        }

        if ((r = sys_env_set_pgfault_upcall(envid,
                        thisenv->env_pgfault_upcall)) < 0) {
  80104c:	a1 04 20 80 00       	mov    0x802004,%eax
        if ((r = sys_env_set_pgfault_upcall(envid,
  801051:	8b 40 64             	mov    0x64(%eax),%eax
  801054:	83 ec 08             	sub    $0x8,%esp
  801057:	50                   	push   %eax
  801058:	57                   	push   %edi
  801059:	e8 42 fd ff ff       	call   800da0 <sys_env_set_pgfault_upcall>
  80105e:	83 c4 10             	add    $0x10,%esp
  801061:	85 c0                	test   %eax,%eax
  801063:	78 13                	js     801078 <fork+0x151>
            return r;
        }

        if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  801065:	83 ec 08             	sub    $0x8,%esp
  801068:	6a 02                	push   $0x2
  80106a:	57                   	push   %edi
  80106b:	e8 a4 fc ff ff       	call   800d14 <sys_env_set_status>
  801070:	83 c4 10             	add    $0x10,%esp
            return r;
        }
        return envid;
  801073:	85 c0                	test   %eax,%eax
  801075:	0f 49 c7             	cmovns %edi,%eax
    }

}
  801078:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80107b:	5b                   	pop    %ebx
  80107c:	5e                   	pop    %esi
  80107d:	5f                   	pop    %edi
  80107e:	5d                   	pop    %ebp
  80107f:	c3                   	ret    

00801080 <sfork>:

// Challenge!
int
sfork(void)
{
  801080:	f3 0f 1e fb          	endbr32 
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
  801087:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80108a:	68 ec 17 80 00       	push   $0x8017ec
  80108f:	68 a5 00 00 00       	push   $0xa5
  801094:	68 63 17 80 00       	push   $0x801763
  801099:	e8 00 00 00 00       	call   80109e <_panic>

0080109e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80109e:	f3 0f 1e fb          	endbr32 
  8010a2:	55                   	push   %ebp
  8010a3:	89 e5                	mov    %esp,%ebp
  8010a5:	56                   	push   %esi
  8010a6:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010a7:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010aa:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8010b0:	e8 46 fb ff ff       	call   800bfb <sys_getenvid>
  8010b5:	83 ec 0c             	sub    $0xc,%esp
  8010b8:	ff 75 0c             	pushl  0xc(%ebp)
  8010bb:	ff 75 08             	pushl  0x8(%ebp)
  8010be:	56                   	push   %esi
  8010bf:	50                   	push   %eax
  8010c0:	68 24 18 80 00       	push   $0x801824
  8010c5:	e8 2c f1 ff ff       	call   8001f6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010ca:	83 c4 18             	add    $0x18,%esp
  8010cd:	53                   	push   %ebx
  8010ce:	ff 75 10             	pushl  0x10(%ebp)
  8010d1:	e8 cb f0 ff ff       	call   8001a1 <vcprintf>
	cprintf("\n");
  8010d6:	c7 04 24 0f 14 80 00 	movl   $0x80140f,(%esp)
  8010dd:	e8 14 f1 ff ff       	call   8001f6 <cprintf>
  8010e2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010e5:	cc                   	int3   
  8010e6:	eb fd                	jmp    8010e5 <_panic+0x47>

008010e8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8010e8:	f3 0f 1e fb          	endbr32 
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
  8010ef:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8010f2:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  8010f9:	74 0a                	je     801105 <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8010fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fe:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801103:	c9                   	leave  
  801104:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  801105:	83 ec 0c             	sub    $0xc,%esp
  801108:	68 47 18 80 00       	push   $0x801847
  80110d:	e8 e4 f0 ff ff       	call   8001f6 <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  801112:	83 c4 0c             	add    $0xc,%esp
  801115:	6a 07                	push   $0x7
  801117:	68 00 f0 bf ee       	push   $0xeebff000
  80111c:	6a 00                	push   $0x0
  80111e:	e8 1e fb ff ff       	call   800c41 <sys_page_alloc>
  801123:	83 c4 10             	add    $0x10,%esp
  801126:	85 c0                	test   %eax,%eax
  801128:	78 2a                	js     801154 <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  80112a:	83 ec 08             	sub    $0x8,%esp
  80112d:	68 68 11 80 00       	push   $0x801168
  801132:	6a 00                	push   $0x0
  801134:	e8 67 fc ff ff       	call   800da0 <sys_env_set_pgfault_upcall>
  801139:	83 c4 10             	add    $0x10,%esp
  80113c:	85 c0                	test   %eax,%eax
  80113e:	79 bb                	jns    8010fb <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  801140:	83 ec 04             	sub    $0x4,%esp
  801143:	68 84 18 80 00       	push   $0x801884
  801148:	6a 25                	push   $0x25
  80114a:	68 74 18 80 00       	push   $0x801874
  80114f:	e8 4a ff ff ff       	call   80109e <_panic>
            panic("Allocation of UXSTACK failed!");
  801154:	83 ec 04             	sub    $0x4,%esp
  801157:	68 56 18 80 00       	push   $0x801856
  80115c:	6a 22                	push   $0x22
  80115e:	68 74 18 80 00       	push   $0x801874
  801163:	e8 36 ff ff ff       	call   80109e <_panic>

00801168 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801168:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801169:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80116e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801170:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  801173:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  801177:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  80117b:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  80117e:	83 c4 08             	add    $0x8,%esp
    popa
  801181:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

    add $0x4, %esp
  801182:	83 c4 04             	add    $0x4,%esp
    popf
  801185:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  801186:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  801189:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  80118d:	c3                   	ret    
  80118e:	66 90                	xchg   %ax,%ax

00801190 <__udivdi3>:
  801190:	f3 0f 1e fb          	endbr32 
  801194:	55                   	push   %ebp
  801195:	57                   	push   %edi
  801196:	56                   	push   %esi
  801197:	53                   	push   %ebx
  801198:	83 ec 1c             	sub    $0x1c,%esp
  80119b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80119f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8011a3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8011a7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8011ab:	85 d2                	test   %edx,%edx
  8011ad:	75 19                	jne    8011c8 <__udivdi3+0x38>
  8011af:	39 f3                	cmp    %esi,%ebx
  8011b1:	76 4d                	jbe    801200 <__udivdi3+0x70>
  8011b3:	31 ff                	xor    %edi,%edi
  8011b5:	89 e8                	mov    %ebp,%eax
  8011b7:	89 f2                	mov    %esi,%edx
  8011b9:	f7 f3                	div    %ebx
  8011bb:	89 fa                	mov    %edi,%edx
  8011bd:	83 c4 1c             	add    $0x1c,%esp
  8011c0:	5b                   	pop    %ebx
  8011c1:	5e                   	pop    %esi
  8011c2:	5f                   	pop    %edi
  8011c3:	5d                   	pop    %ebp
  8011c4:	c3                   	ret    
  8011c5:	8d 76 00             	lea    0x0(%esi),%esi
  8011c8:	39 f2                	cmp    %esi,%edx
  8011ca:	76 14                	jbe    8011e0 <__udivdi3+0x50>
  8011cc:	31 ff                	xor    %edi,%edi
  8011ce:	31 c0                	xor    %eax,%eax
  8011d0:	89 fa                	mov    %edi,%edx
  8011d2:	83 c4 1c             	add    $0x1c,%esp
  8011d5:	5b                   	pop    %ebx
  8011d6:	5e                   	pop    %esi
  8011d7:	5f                   	pop    %edi
  8011d8:	5d                   	pop    %ebp
  8011d9:	c3                   	ret    
  8011da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011e0:	0f bd fa             	bsr    %edx,%edi
  8011e3:	83 f7 1f             	xor    $0x1f,%edi
  8011e6:	75 48                	jne    801230 <__udivdi3+0xa0>
  8011e8:	39 f2                	cmp    %esi,%edx
  8011ea:	72 06                	jb     8011f2 <__udivdi3+0x62>
  8011ec:	31 c0                	xor    %eax,%eax
  8011ee:	39 eb                	cmp    %ebp,%ebx
  8011f0:	77 de                	ja     8011d0 <__udivdi3+0x40>
  8011f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8011f7:	eb d7                	jmp    8011d0 <__udivdi3+0x40>
  8011f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801200:	89 d9                	mov    %ebx,%ecx
  801202:	85 db                	test   %ebx,%ebx
  801204:	75 0b                	jne    801211 <__udivdi3+0x81>
  801206:	b8 01 00 00 00       	mov    $0x1,%eax
  80120b:	31 d2                	xor    %edx,%edx
  80120d:	f7 f3                	div    %ebx
  80120f:	89 c1                	mov    %eax,%ecx
  801211:	31 d2                	xor    %edx,%edx
  801213:	89 f0                	mov    %esi,%eax
  801215:	f7 f1                	div    %ecx
  801217:	89 c6                	mov    %eax,%esi
  801219:	89 e8                	mov    %ebp,%eax
  80121b:	89 f7                	mov    %esi,%edi
  80121d:	f7 f1                	div    %ecx
  80121f:	89 fa                	mov    %edi,%edx
  801221:	83 c4 1c             	add    $0x1c,%esp
  801224:	5b                   	pop    %ebx
  801225:	5e                   	pop    %esi
  801226:	5f                   	pop    %edi
  801227:	5d                   	pop    %ebp
  801228:	c3                   	ret    
  801229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801230:	89 f9                	mov    %edi,%ecx
  801232:	b8 20 00 00 00       	mov    $0x20,%eax
  801237:	29 f8                	sub    %edi,%eax
  801239:	d3 e2                	shl    %cl,%edx
  80123b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80123f:	89 c1                	mov    %eax,%ecx
  801241:	89 da                	mov    %ebx,%edx
  801243:	d3 ea                	shr    %cl,%edx
  801245:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801249:	09 d1                	or     %edx,%ecx
  80124b:	89 f2                	mov    %esi,%edx
  80124d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801251:	89 f9                	mov    %edi,%ecx
  801253:	d3 e3                	shl    %cl,%ebx
  801255:	89 c1                	mov    %eax,%ecx
  801257:	d3 ea                	shr    %cl,%edx
  801259:	89 f9                	mov    %edi,%ecx
  80125b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80125f:	89 eb                	mov    %ebp,%ebx
  801261:	d3 e6                	shl    %cl,%esi
  801263:	89 c1                	mov    %eax,%ecx
  801265:	d3 eb                	shr    %cl,%ebx
  801267:	09 de                	or     %ebx,%esi
  801269:	89 f0                	mov    %esi,%eax
  80126b:	f7 74 24 08          	divl   0x8(%esp)
  80126f:	89 d6                	mov    %edx,%esi
  801271:	89 c3                	mov    %eax,%ebx
  801273:	f7 64 24 0c          	mull   0xc(%esp)
  801277:	39 d6                	cmp    %edx,%esi
  801279:	72 15                	jb     801290 <__udivdi3+0x100>
  80127b:	89 f9                	mov    %edi,%ecx
  80127d:	d3 e5                	shl    %cl,%ebp
  80127f:	39 c5                	cmp    %eax,%ebp
  801281:	73 04                	jae    801287 <__udivdi3+0xf7>
  801283:	39 d6                	cmp    %edx,%esi
  801285:	74 09                	je     801290 <__udivdi3+0x100>
  801287:	89 d8                	mov    %ebx,%eax
  801289:	31 ff                	xor    %edi,%edi
  80128b:	e9 40 ff ff ff       	jmp    8011d0 <__udivdi3+0x40>
  801290:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801293:	31 ff                	xor    %edi,%edi
  801295:	e9 36 ff ff ff       	jmp    8011d0 <__udivdi3+0x40>
  80129a:	66 90                	xchg   %ax,%ax
  80129c:	66 90                	xchg   %ax,%ax
  80129e:	66 90                	xchg   %ax,%ax

008012a0 <__umoddi3>:
  8012a0:	f3 0f 1e fb          	endbr32 
  8012a4:	55                   	push   %ebp
  8012a5:	57                   	push   %edi
  8012a6:	56                   	push   %esi
  8012a7:	53                   	push   %ebx
  8012a8:	83 ec 1c             	sub    $0x1c,%esp
  8012ab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8012af:	8b 74 24 30          	mov    0x30(%esp),%esi
  8012b3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8012b7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8012bb:	85 c0                	test   %eax,%eax
  8012bd:	75 19                	jne    8012d8 <__umoddi3+0x38>
  8012bf:	39 df                	cmp    %ebx,%edi
  8012c1:	76 5d                	jbe    801320 <__umoddi3+0x80>
  8012c3:	89 f0                	mov    %esi,%eax
  8012c5:	89 da                	mov    %ebx,%edx
  8012c7:	f7 f7                	div    %edi
  8012c9:	89 d0                	mov    %edx,%eax
  8012cb:	31 d2                	xor    %edx,%edx
  8012cd:	83 c4 1c             	add    $0x1c,%esp
  8012d0:	5b                   	pop    %ebx
  8012d1:	5e                   	pop    %esi
  8012d2:	5f                   	pop    %edi
  8012d3:	5d                   	pop    %ebp
  8012d4:	c3                   	ret    
  8012d5:	8d 76 00             	lea    0x0(%esi),%esi
  8012d8:	89 f2                	mov    %esi,%edx
  8012da:	39 d8                	cmp    %ebx,%eax
  8012dc:	76 12                	jbe    8012f0 <__umoddi3+0x50>
  8012de:	89 f0                	mov    %esi,%eax
  8012e0:	89 da                	mov    %ebx,%edx
  8012e2:	83 c4 1c             	add    $0x1c,%esp
  8012e5:	5b                   	pop    %ebx
  8012e6:	5e                   	pop    %esi
  8012e7:	5f                   	pop    %edi
  8012e8:	5d                   	pop    %ebp
  8012e9:	c3                   	ret    
  8012ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012f0:	0f bd e8             	bsr    %eax,%ebp
  8012f3:	83 f5 1f             	xor    $0x1f,%ebp
  8012f6:	75 50                	jne    801348 <__umoddi3+0xa8>
  8012f8:	39 d8                	cmp    %ebx,%eax
  8012fa:	0f 82 e0 00 00 00    	jb     8013e0 <__umoddi3+0x140>
  801300:	89 d9                	mov    %ebx,%ecx
  801302:	39 f7                	cmp    %esi,%edi
  801304:	0f 86 d6 00 00 00    	jbe    8013e0 <__umoddi3+0x140>
  80130a:	89 d0                	mov    %edx,%eax
  80130c:	89 ca                	mov    %ecx,%edx
  80130e:	83 c4 1c             	add    $0x1c,%esp
  801311:	5b                   	pop    %ebx
  801312:	5e                   	pop    %esi
  801313:	5f                   	pop    %edi
  801314:	5d                   	pop    %ebp
  801315:	c3                   	ret    
  801316:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80131d:	8d 76 00             	lea    0x0(%esi),%esi
  801320:	89 fd                	mov    %edi,%ebp
  801322:	85 ff                	test   %edi,%edi
  801324:	75 0b                	jne    801331 <__umoddi3+0x91>
  801326:	b8 01 00 00 00       	mov    $0x1,%eax
  80132b:	31 d2                	xor    %edx,%edx
  80132d:	f7 f7                	div    %edi
  80132f:	89 c5                	mov    %eax,%ebp
  801331:	89 d8                	mov    %ebx,%eax
  801333:	31 d2                	xor    %edx,%edx
  801335:	f7 f5                	div    %ebp
  801337:	89 f0                	mov    %esi,%eax
  801339:	f7 f5                	div    %ebp
  80133b:	89 d0                	mov    %edx,%eax
  80133d:	31 d2                	xor    %edx,%edx
  80133f:	eb 8c                	jmp    8012cd <__umoddi3+0x2d>
  801341:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801348:	89 e9                	mov    %ebp,%ecx
  80134a:	ba 20 00 00 00       	mov    $0x20,%edx
  80134f:	29 ea                	sub    %ebp,%edx
  801351:	d3 e0                	shl    %cl,%eax
  801353:	89 44 24 08          	mov    %eax,0x8(%esp)
  801357:	89 d1                	mov    %edx,%ecx
  801359:	89 f8                	mov    %edi,%eax
  80135b:	d3 e8                	shr    %cl,%eax
  80135d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801361:	89 54 24 04          	mov    %edx,0x4(%esp)
  801365:	8b 54 24 04          	mov    0x4(%esp),%edx
  801369:	09 c1                	or     %eax,%ecx
  80136b:	89 d8                	mov    %ebx,%eax
  80136d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801371:	89 e9                	mov    %ebp,%ecx
  801373:	d3 e7                	shl    %cl,%edi
  801375:	89 d1                	mov    %edx,%ecx
  801377:	d3 e8                	shr    %cl,%eax
  801379:	89 e9                	mov    %ebp,%ecx
  80137b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80137f:	d3 e3                	shl    %cl,%ebx
  801381:	89 c7                	mov    %eax,%edi
  801383:	89 d1                	mov    %edx,%ecx
  801385:	89 f0                	mov    %esi,%eax
  801387:	d3 e8                	shr    %cl,%eax
  801389:	89 e9                	mov    %ebp,%ecx
  80138b:	89 fa                	mov    %edi,%edx
  80138d:	d3 e6                	shl    %cl,%esi
  80138f:	09 d8                	or     %ebx,%eax
  801391:	f7 74 24 08          	divl   0x8(%esp)
  801395:	89 d1                	mov    %edx,%ecx
  801397:	89 f3                	mov    %esi,%ebx
  801399:	f7 64 24 0c          	mull   0xc(%esp)
  80139d:	89 c6                	mov    %eax,%esi
  80139f:	89 d7                	mov    %edx,%edi
  8013a1:	39 d1                	cmp    %edx,%ecx
  8013a3:	72 06                	jb     8013ab <__umoddi3+0x10b>
  8013a5:	75 10                	jne    8013b7 <__umoddi3+0x117>
  8013a7:	39 c3                	cmp    %eax,%ebx
  8013a9:	73 0c                	jae    8013b7 <__umoddi3+0x117>
  8013ab:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8013af:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8013b3:	89 d7                	mov    %edx,%edi
  8013b5:	89 c6                	mov    %eax,%esi
  8013b7:	89 ca                	mov    %ecx,%edx
  8013b9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8013be:	29 f3                	sub    %esi,%ebx
  8013c0:	19 fa                	sbb    %edi,%edx
  8013c2:	89 d0                	mov    %edx,%eax
  8013c4:	d3 e0                	shl    %cl,%eax
  8013c6:	89 e9                	mov    %ebp,%ecx
  8013c8:	d3 eb                	shr    %cl,%ebx
  8013ca:	d3 ea                	shr    %cl,%edx
  8013cc:	09 d8                	or     %ebx,%eax
  8013ce:	83 c4 1c             	add    $0x1c,%esp
  8013d1:	5b                   	pop    %ebx
  8013d2:	5e                   	pop    %esi
  8013d3:	5f                   	pop    %edi
  8013d4:	5d                   	pop    %ebp
  8013d5:	c3                   	ret    
  8013d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013dd:	8d 76 00             	lea    0x0(%esi),%esi
  8013e0:	29 fe                	sub    %edi,%esi
  8013e2:	19 c3                	sbb    %eax,%ebx
  8013e4:	89 f2                	mov    %esi,%edx
  8013e6:	89 d9                	mov    %ebx,%ecx
  8013e8:	e9 1d ff ff ff       	jmp    80130a <__umoddi3+0x6a>
